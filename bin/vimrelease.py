#!/usr/bin/python

import sys
import os
import re
from time import strftime, localtime
import mechanize
import gnomekeyring as gkey
from subprocess import Popen, PIPE
import shlex

br = mechanize.Browser()

def system(cmd):
    (stdout, stderr) = \
        Popen(shlex.split(cmd), stdout=PIPE, stderr=PIPE).communicate()

    if len(stderr) != 0:
        print stderr,

    return stdout.splitlines()

def get_script_files():
    def is_not_ignored(file):
        output = system('git check-attr export-ignore ' + file)[0]
        return output.split()[-1] != 'set'

    files = system('git ls-files --cached')
    return [file for file in files if is_not_ignored(file)]

def update_files(scrver):
    pat = re.compile(r'^(?P<text>(" )?Version:\s+)[0-9.]+$')
    files = get_script_files()

    for fname in files:
        with open(fname) as f:
            out_fname = fname + '.tmp'
            out = open(out_fname, 'w')
            for line in f:
                out.write(re.sub(pat, lambda m: m.group('text') + scrver, line))
            out.close()
            os.rename(out_fname, fname)

def update_gh_site(scrver, scrcommfile):
    system('git checkout gh-pages')
    out_fname = '_posts/' + \
                strftime('%Y-%m-%d', localtime()) + '-' + scrver + '.markdown'

    with open(out_fname, 'w') as outf:
        outf.write('---\n')
        outf.write('title: ' + scrver + '\n')
        outf.write('---\n\n')

        with open(scrcommfile) as inf:
            for line in inf:
                outf.write(line)

    system('git add ' + out_fname)
    system('git commit -m "Version ' + scrver + '"')
#    system('git push')
    system('git checkout master')

def login():
    print 'Logging in...',

    pwdata = gkey.find_network_password_sync(server = 'www.vim.org',
                                             user = 'majutsushi')[0]

    br.open('http://www.vim.org/login.php')
    br.select_form(name = 'login')
    br.form['userName'] = pwdata['user']
    br.form['password'] = pwdata['password']
    br.submit()

    print 'done.'

def upload_script(scrid, scrfile, vimver, scrver, scrcomment):
    print 'Uploading script file ' + scrfile + '...',

    br.open('http://www.vim.org/scripts/script.php?script_id=' + scrid)
    br.follow_link(text = 'upload new version')
    br.select_form(name = 'script')
    br.form.add_file(open(scrfile), content_type = 'text/plain',
                     filename = scrfile, name = 'script_file')
    br.form['vim_version'] = [str(vimver)]
    br.form['script_version'] = scrver
    br.form['version_comment'] = scrcomment
    br.submit(label = 'upload')

    print 'done.'

def make_vimball(scrname):
    print 'Creating Vimball...',

    export = get_script_files()

    filecmds = ''
    for file in export:
        filecmds += ' -c ":put =\'' + file + '\'" '

    cmd = 'vim ' + filecmds + \
                 ' -c ":g/^$/d" ' + \
                 ' -c ":let g:vimball_home = \'.\'" ' + \
                 ' -c ":%MkVimball! ' + scrname + '"' + \
                 ' -c ":q!"'
    system(cmd)
    print 'done.'
    return os.path.abspath(scrname + '.vmb')

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print 'Usage: ' + sys.argv[0] + ' scrver scrcommfile [vimver]'
        exit()

    scrver = sys.argv[1]

    scrcommfile = os.path.abspath(sys.argv[2])
    with open(scrcommfile) as f:
        scrcomment = f.read()

    if len(sys.argv) == 4:
        vimver = sys.argv[3]
    else:
        vimver = 7.0

    with open('.info') as infofile:
        info    = infofile.readlines()
        scrname = info[0].strip()
        scrid   = info[1].strip()

    update_files(scrver)
    system('git commit -a -m "Version ' + scrver + '"')

    update_gh_site(scrver, scrcommfile)

    vimball = make_vimball(scrname)
    login()
    upload_script(scrid, vimball, vimver, scrver, scrcomment)
    os.unlink(vimball)
