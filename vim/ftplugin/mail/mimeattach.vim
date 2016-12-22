" MIME Attach files to a vim email buffer. Useful for slrn.
" Source: http://permalink.gmane.org/gmane.network.slrn.user/2716

" Python Function here:

python3 << EOF
#!/usr/bin/python3

# min length for displaying text files inline.
# -1 for never inline, 0 for always inline.
INLINE_LENGTH=150*1024

import sys
import os
import io

# Guess text file encoding from a list of given encodings
encodinglist=['utf-8']
fsencoding = sys.getfilesystemencoding()
if fsencoding and fsencoding not in encodinglist:
    encodinglist.append(fsencoding.lower())

# extra encoding guess based on locales
import locale
locale.setlocale(locale.LC_ALL, '')
lang = locale.getlocale(locale.LC_CTYPE)[0]
if lang.lower() in ['zh_cn', 'zh_sg'] and 'gbk' not in encodinglist:
    encodinglist.append('gbk')
elif lang.lower() in ['zh_tw', 'zh_hk', 'zh_mo'] and 'big5' not in encodinglist:
    encodinglist.append('big5')

import email
import mimetypes
from email import encoders
from email.generator import Generator
from email.message import Message
from email.mime.audio import MIMEAudio
from email.mime.base import MIMEBase
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

import vim

def parse_bare_email(text, charset=None):
    '''Parse the existing vim email buffer to a orginal Message object.'''
    mymail = email.message_from_string(text)
    if not mymail.is_multipart():
        mymail = single2multi(mymail, charset)
    return mymail

def single2multi(amail, charset):
    '''Convert a non-multipart Message to a Multipart Message Object.'''
    nmail = MIMEMultipart()
    for k, v in amail.items():
        if k.lower() not in ['content-type', 'mime-versoin']:
            nmail[k] = v
    msg = MIMEText(amail.get_payload(), _subtype='plain', _charset=None)
    # I don't want to base64 or quoted encode text files.
    if charset:
        cs = email.charset.Charset(charset)
        # cs.output_charset = charset
        # Not standard but I don't like encoded header and bodys
        # apparently, email module don't care about header_encoding
        cs.body_encoding=None
        cs.header_encoding=None
        msg.set_charset(cs)
    msg.add_header("Content-Disposition", "inline")
    nmail.attach(msg)
    return nmail

def guess_text_encoding(text, n=0):
    '''Guess text encoding.
    Recursive.'''
    try:
        enc = encodinglist[n]
        text.decode(enc)
        return enc
    except UnicodeError:
        n+=1
        if n >= len(encodinglist):
            return None
        else:
            return guess_text_encoding(text, n)

def attach_file(amail, path):
    '''Attach a file at path to the Message object.
    Mostly copied from the python reference example.'''
    if not os.path.isfile(path):
        return
    filename = os.path.basename(path)
    # Guess the content type based on the file's extension.  Encoding
    # will be ignored, although we should check for simple things like
    # gzip'd or compressed files.
    ctype, encoding = mimetypes.guess_type(path)

    if ctype is None or encoding is not None:
        p, e = os.path.splitext(path)
        if e.lower() == '.vim':
            ctype = 'text/plain'
        else:
            # No guess could be made, or the file is encoded (compressed), so
            # use a generic bag-of-bits type.
            ctype = 'application/octet-stream'
    maintype, subtype = ctype.split('/', 1)
    if maintype == 'text':
        fp = open(path)
        text = fp.read()
        fp.close()
        # Note: we should handle calculating the charset
        charset = guess_text_encoding(text)
        msg = MIMEText(text, _subtype=subtype, _charset=None)
        if charset:
            cs = email.charset.Charset(charset)
            # Not standard but I don't like encoded header and bodys
            # apparently, email module don't care about header_encoding
            cs.body_encoding=None
            cs.header_encoding=None
            msg.set_charset(cs)
    elif maintype == 'image':
        fp = open(path, 'rb')
        msg = MIMEImage(fp.read(), _subtype=subtype)
        fp.close()
    elif maintype == 'audio':
        fp = open(path, 'rb')
        msg = MIMEAudio(fp.read(), _subtype=subtype)
        fp.close()
    else:
        # unknown bitstream
        fp = open(path, 'rb')
        msg = MIMEBase(maintype, subtype)
        msg.set_payload(fp.read())
        fp.close()
        # Encode the payload using Base64
        encoders.encode_base64(msg)

    # Set the filename parameter
    disp_type = 'attachment'
    # Try to inline short text files for easier display
    if maintype == 'text' and INLINE_LENGTH >= 0 and (
        INLINE_LENGTH==0 or len(text) <= INLINE_LENGTH):
        disp_type = 'inline'
    msg.add_header('Content-Disposition', disp_type, filename=filename)
    amail.attach(msg)

def main():
    '''Test program.'''
    files = sys.argv[1:]
    main_text = open(files[0]).read()
    amail = parse_bare_email(main_text)
    for f in files[1:]:
        attach_file(amail, f)
    print(amail)

def pAttachFile(paths):
    '''Interface to vim function.'''
    # path = vim.eval('input("Attachment Path: ", "", "file")')

    enc = None
    # We will not encode the main text
    enc = vim.eval("&fileencoding")
    if not enc:
        enc = vim.eval ("&encoding")
    if not paths:
        vim.command('return 1')
        return

    # create Message object
    buf = vim.current.buffer
    text = '\n'.join(buf)
    amail = parse_bare_email(text.lstrip(), enc)

    # attach files.
    for path in paths:
        path = os.path.expanduser(path)
        if not os.path.exists(path):
            print("Error: %s does not exist..." % path)
            print("Error: %s does not exist..." % path)
            continue
        attach_file(amail, path)

    # get back text to vim buffer
    fp = io.StringIO()
    g = Generator(fp, mangle_from_=False, maxheaderlen=60)
    g.flatten(amail, False)
    text = fp.getvalue()
    if text:
        vim.current.buffer[:] = text.splitlines()
    vim.command('return 0')

EOF

" vim function to interface python function. Variable length arguments
" for input filenames
function! AttachFile_Func(...)
python3 << EOF
paths = vim.eval('a:000')
pAttachFile(paths)
EOF

endfunction

" Create vim command with file completion and variable arguments
command! -nargs=+ -complete=file MimeAttachFile :call AttachFile_Func(<f-args>)

" vim:ts=8:sw=4:expandtab:encoding=utf-8
