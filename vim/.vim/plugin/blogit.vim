"""
" Copyright (C) 2009 Romain Bignon
"
" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, version 3 of the License.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program; if not, write to the Free Software
" Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
"
" Maintainer:   Romain Bignon
" Contributor:  Adam Schmalhofer
" URL:          http://symlink.me/wiki/blogit
" Version:      1.3
" Last Change:  2009 August 16
"
" Commands :
" ":Blogit ls"
"   Lists all articles in the blog
" ":Blogit new"
"   Opens page to write new article
" ":Blogit this"
"   Make current buffer a blog post
" ":Blogit edit <id>"
"   Opens the article <id> for edition
" ":Blogit commit"
"   Saves the article to the blog
" ":Blogit push"
"   Publish article
" ":Blogit unpush"
"   Unpublish article
" ":Blogit rm <id>"
"   Remove an article
" ":Blogit tags"
"   Show tags and categories list
" ":Blogit preview"
"   Preview current post locally
" ":Blogit help"
"   Display help
"
" Note that preview might not word on all platforms. This is because we have
" to rely on unsupported and non-portable functionality from the python
" standard library.
"
"
" Configuration :
"   Create a file called passwords.vim somewhere in your 'runtimepath'
"   (preferred location is "~/.vim/"). Don't forget to set the permissions so
"   only you can read it. This file should include:
"
"       let blogit_username='Your blog user name'
"       let blogit_password='Your blog password. Not the API-key.'
"       let blogit_url='https://your.path.to/xmlrpc.php'
"
"   In addition you can set these settings in your vimrc:
"
"       let blogit_unformat='pandoc --from=html --to=rst --reference-links'
"       let blogit_format='pandoc --from=rst --to=html --no-wrap'
"
"   The blogit_format and blogit_unformat each contain a shell command to
"   filter the blog entry text (no meta data) before a commit and after an
"   edit, respectively. In the example we use pandoc[1] to edit the blog in
"   reStructuredText[2].
"
"   If you have multible blogs replace 'blogit' in 'blogit_username' etc. by a
"   name of your choice (e.g. 'your_blog_name') and use:
"
"       let blog_name='your_blog_name'
"   or
"       let b:blog_name='your_blog_name'
"
"   to switch between them.
"
" Usage :
"   Just fill in the blanks, do not modify the highlighted parts and everything
"   should be ok.
"
"   gf or <enter> in the ':Blogit ls' buffer edits the blog post in the
"   current line.
"
"   Categories and tags can be omni completed via *compl-function* (usually
"   CTRL-X_CTRL-U). The list of them is gotten automatically on first
"   ":Blogit edit" and can be updated with ":Blogit tags".
"
"   To use tags your WordPress needs to have the UTW-RPC[3] plugin installed
"   (WordPress.com does).
"
" [1] http://johnmacfarlane.net/pandoc/
" [2] http://docutils.sourceforge.net/docs/ref/rst/introduction.html
" [3] http://blog.circlesixdesign.com/download/utw-rpc-autotag/
"
" vim: set et softtabstop=4 cinoptions=4 shiftwidth=4 ts=4 ai

runtime! passwords.vim
command! -nargs=* Blogit exec('py blogit.command(<f-args>)')

let s:used_categories = []
let s:used_tags = []

function BlogitComplete(findstart, base)
    " based on code from :he complete-functions
    if a:findstart
        " locate the start of the word
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] =~ '\a'
            let start -= 1
        endwhile
        return start
    else
        let sep = ', '
        if getline('.') =~# '^Categories: '
            let L = s:used_categories
        elseif getline('.') =~# '^Tags: '
            let L = s:used_tags
        elseif getline('.') =~# '^Status: '
            " for comments
            let L = [ 'approve', 'spam', 'hold', 'new', 'rm' ]
            let sep = ''
        else
            return []
        endif
	    let res = []
	    for m in L
	        if m =~ '^' . a:base
		        call add(res, m . sep)
	        endif
	    endfor
	    return res
    endif
endfunction

function CommentsFoldText()
    let line_no = v:foldstart
    if v:foldlevel > 1
        while getline(line_no) !~ '^\s*$'
            let line_no += 1
        endwhile
    endif
    return '+' . v:folddashes . getline(line_no + 1)
endfunction

python <<EOF
# -*- coding: utf-8 -*-
# Lets the python unit test ignore eveything above this line (docstring). """
import xmlrpclib, sys, re
from time import mktime, strptime, strftime, localtime, gmtime
from calendar import timegm
from subprocess import Popen, CalledProcessError, PIPE
from xmlrpclib import DateTime, Fault, MultiCall
from inspect import getargspec
import webbrowser, tempfile

try:
    import vim
except ImportError:
    # Used outside of vim (for testing)
    from minimock import Mock, mock
    import minimock, doctest
    from mock_vim import vim
else:
    doctest = False

#####################
# Do not edit below #
#####################

class BlogIt(object):
    class BlogItException(Exception):
        pass

    class FilterException(BlogItException):
        def __init__(self, message, input_text, filter):
            self.message = "Blogit: Error happend while filtering with:" + \
                    filter + '\n' + message
            self.input_text = input_text
            self.filter = filter

    def __init__(self):
        self.client = None
        self._posts = {}
        self.prev_file = None

    def connect(self):
        self.client = xmlrpclib.ServerProxy(self.blog_url)

    def _get_current_data(self, page_type):
        try:
            t, data = self._posts[vim.current.buffer.number]
        except KeyError:
            return None
        else:
            if t != page_type:
                raise self.BlogItException(
                        'This buffer stores "%s" not "%s".' % ( t, page_type ))
            return data

    def _set_current_data(self, page_type, value):
        """
        >>> vim.current.buffer.change_buffer(3)
        >>> blogit.current_post = { 'p3': 3 }
        >>> vim.current.buffer.change_buffer(7)
        >>> blogit.current_post
        >>> blogit.current_post = { 'p7': 42 }
        >>> vim.current.buffer.change_buffer(3)
        >>> blogit.current_comments    #doctest: +ELLIPSIS
        Traceback (most recent call last):
        ...
        BlogItException: This buffer stores "post" not "comments".
        >>> blogit.current_post
        {'p3': 3}
        """
        self._posts[vim.current.buffer.number] = ( page_type, value )

    def _get_current_post(self):
        return self._get_current_data('post')

    def _set_current_post(self, value):
        return self._set_current_data('post', value)

    def _get_current_comments(self):
        return self._get_current_data('comments')

    def _set_current_comments(self, value):
        return self._set_current_data('comments', value)

    @property
    def current_post_type(self):
        try:
            t, data = self._posts[vim.current.buffer.number]
        except KeyError:
            return None
        return t

    current_post = property(_get_current_post, _set_current_post)
    current_comments = property(_get_current_comments, _set_current_comments)

    meta_data_dict = { 'From': 'wp_author_display_name', 'Post-Id': 'postid',
            'Subject': 'title', 'Categories': 'categories',
            'Tags': 'mt_keywords', 'Date': 'date_created_gmt',
            'Status': 'blogit_status',
           }

    comments_meta_data_dict = { 'Status': 'status', 'Author': 'author',
            'ID': 'comment_id', 'Parent': 'parent',
            'Date': 'date_created_gmt', 'Type': 'type', 'content': 'content',
           }

    vimcommand_help = []

    def command(self, command='help', *args):
        """
        >>> mock('xmlrpclib')
        >>> mock('sys.stderr')
        >>> blogit.command('non-existant')
        Called sys.stderr.write('No such command: non-existant.')

        >>> def f(x): print 'got %s' % x
        >>> blogit.command_mocktest = f
        >>> blogit.command('mo')
        Called sys.stderr.write('Command mo takes 0 arguments.')

        >>> blogit.command('mo', 2)
        got 2

        >>> blogit.command_mockambiguous = f
        >>> blogit.command('mo')    #doctest: +NORMALIZE_WHITESPACE
        Called sys.stderr.write('Ambiguious command mo:
                mockambiguous, mocktest.')

        >>> minimock.restore()
        """
        if self.client is None:
            self.connect()
        def f(x): return x.startswith('command_' + command)
        matching_commands = filter(f, dir(self))

        if len(matching_commands) == 0:
            sys.stderr.write("No such command: %s." % command)
        elif len(matching_commands) == 1:
            try:
                getattr(self, matching_commands[0])(*args)
            except TypeError, e:
                try:
                    sys.stderr.write("Command %s takes %s arguments." % \
                            (command, int(str(e).split(' ')[3]) - 1))
                except:
                    sys.stderr.write('%s' % e)
        else:
            sys.stderr.write("Ambiguious command %s: %s." % ( command,
                    ', '.join([ s.replace('command_', '', 1)
                        for s in matching_commands ]) ))

    def list_comments(self):
        if vim.current.line.startswith('Status: '):
            self.getComments(self.current_post['postid'])

    def list_edit(self):
        """
        >>> mock('vim.command')
        >>> vim.current.window.cursor = (1, 2)
        >>> vim.current.buffer[:] = [ '12 random text' ]
        >>> blogit.list_edit()
        Called vim.command('bdelete')
        Called vim.command('Blogit edit 12')

        >>> vim.current.buffer[:] = [ 'no blog id 12' ]
        >>> mock('blogit.command_new')
        >>> blogit.list_edit()
        Called vim.command('bdelete')
        Called blogit.command_new()

        >>> minimock.restore()
        """
        row, col = vim.current.window.cursor
        id = vim.current.buffer[row-1].split()[0]
        try:
            id = int(id)
        except ValueError:
            vim.command('bdelete')
            self.command_new()
        else:
            vim.command('bdelete')
            # To access vim s:variables we can't call this directly
            # via command_edit
            vim.command('Blogit edit %s' % id)

    def format_header(self, post_data, label,
            meta_data_dict, meta_data_f_dict={}):
        """
        Returns a header line formated as it will be displayed to the user.
        """
        try:
            val = post_data[meta_data_dict[label]]
        except KeyError:
            val = ''
        if label in meta_data_f_dict:
            val = meta_data_f_dict[label](val)
        return '%s: %s' % ( label, unicode(val).encode('utf-8') )

    def format_body(self, post_data, post_body,
            meta_data_dict, meta_data_f_dict={}, unformat=False):
        """
        Yields the lines of a post body.
        """
        content = post_data.get(post_body, '').encode('utf-8')
        if unformat:
            content = self.unformat(content)
        for line in content.split('\n'):
            # not splitlines to preserve \r\n in comments.
            yield line

        if post_data.get('mt_text_more'):
            yield ''
            yield '<!--more-->'
            yield ''
            content = self.unformat(post_data["mt_text_more"].encode("utf-8"))
            for line in content.split('\n'):
                # not splitlines to preserve \r\n in comments.
                yield line.encode('utf-8')

    def append_post(self, post_data, post_body, headers,
            meta_data_dict, meta_data_f_dict={}, unformat=False):
        """
        Append a post or comment to the vim buffer.
        """
        post = ([ self.format_header(post_data, label,
                    meta_data_dict, meta_data_f_dict) for label in headers ] +
                [ '' ] +
                list( self.format_body(post_data, post_body, meta_data_dict,
                        meta_data_f_dict, unformat))  )
        if vim.current.buffer[:] != ['']:
            # work around empty buffer has one line.
            vim.current.buffer.append('')
        vim.current.buffer[-1:] = post

    def display_post(self, post={}, new_text=None):
        def display_comment_count(d):
            if d == '':
                return u'new'
            comment_typ_count = [ '%s %s' % (d[key], text)
                    for key, text in ( ( 'awaiting_moderation', 'awaiting' ),
                            ( 'spam', 'spam' ) )
                    if d[key] > 0 ]
            if comment_typ_count == []:
                s = u''
            else:
                s = u' (%s)' % ', '.join(comment_typ_count)
            return ( u'%(post_status)s \u2013 %(total_comments)s Comments' + s ) % d

        do_unformat = True
        default_post = { 'post_status': 'draft',
                         self.meta_data_dict['From']: self.blog_username }
        default_post.update(post)
        post = default_post
        self.current_post = post
        meta_data_f_dict = { 'Date': self.DateTime_to_str,
                   'Categories': lambda L: ', '.join(L),
                   'Status': display_comment_count
                 }
        vim.current.buffer[:] = None
        if new_text is not None:
            post['description'] = new_text
            do_unformat = False
        self.append_post(post, 'description',
                [ 'From', 'Post-Id', 'Subject', 'Status', 'Categories',
                    'Tags', 'Date'
                ], self.meta_data_dict, meta_data_f_dict, do_unformat)
        self.current_post = post
        vim.command('nnoremap <buffer> gf :py blogit.list_comments()<cr>')
        vim.command('setlocal nomodified ft=mail textwidth=0 ' +
                             'completefunc=BlogitComplete')
        vim.current.window.cursor = (8, 0)

    @staticmethod
    def str_to_DateTime(text='', format='%c'):
        """
        >>> BlogIt.str_to_DateTime()                    #doctest: +ELLIPSIS
        <DateTime ...>

        >>> BlogIt.str_to_DateTime('Sun Jun 28 19:38:58 2009',
        ...         '%a %b %d %H:%M:%S %Y')             #doctest: +ELLIPSIS
        <DateTime '20090628T17:38:58' at ...>

        >>> BlogIt.str_to_DateTime(BlogIt.DateTime_to_str(
        ...         DateTime('20090628T17:38:58')))     #doctest: +ELLIPSIS
        <DateTime '20090628T17:38:58' at ...>
        """
        if text == '':
            text = localtime()
        else:
            text = strptime(text, format)
        return DateTime(strftime('%Y%m%dT%H:%M:%S', gmtime(mktime(text))))

    @staticmethod
    def DateTime_to_str(date, format='%c'):
        """
        >>> BlogIt.DateTime_to_str(DateTime('20090628T17:38:58'),
        ...         '%a %b %d %H:%M:%S %Y')
        'Sun Jun 28 19:38:58 2009'

        >>> BlogIt.DateTime_to_str('invalid input')
        ''
        """
        try:
            return strftime(format, localtime(timegm(strptime(str(date),
                                              '%Y%m%dT%H:%M:%S'))))
        except ValueError:
            return ''

    def getPost(self, id):
        """
        >>> mock('xmlrpclib.MultiCall', returns=Mock(
        ...         'multicall', returns=[{'post_status': 'draft'}, {}]))
        >>> mock('vim.mocked_eval')

        >>> d = blogit.getPost(42)
        Called xmlrpclib.MultiCall(<ServerProxy for example.com/RPC2>)
        Called multicall.metaWeblog.getPost(42, 'user', 'password')
        Called multicall.wp.getCommentCount('', 'user', 'password', 42)
        Called vim.mocked_eval('s:used_tags == [] || s:used_categories == []')
        Called multicall()
        >>> sorted(d.items())
        [('blogit_status', {'post_status': 'draft'}), ('post_status', 'draft')]

        >>> minimock.restore()

        """
        username, password = self.blog_username, self.blog_password
        multicall = xmlrpclib.MultiCall(self.client)
        multicall.metaWeblog.getPost(id, username, password)
        multicall.wp.getCommentCount('', username, password, id)
        if vim.eval('s:used_tags == [] || s:used_categories == []') == '1':
            multicall.wp.getCategories('', username, password)
            multicall.wp.getTags('', username, password)
            d, comments, categories, tags = tuple(multicall())
            vim.command('let s:used_tags = %s' % [ tag['name']
                    for tag in tags ])
            vim.command('let s:used_categories = %s' % [ cat['categoryName']
                    for cat in categories ])
        else:
            d, comments = tuple(multicall())
        comments['post_status'] = d['post_status']
        d['blogit_status'] = comments
        return d

    def getComments(self, id=None, offset=0):
        """ Lists the comments to a post with given id in a new buffer.

        >>> mock('xmlrpclib.MultiCall', returns=Mock(
        ...         'multicall', returns=[], tracker=None))
        >>> mock('vim.command')
        >>> mock('blogit.append_comment_to_buffer')
        >>> mock('blogit.changed_comments', returns=[])
        >>> blogit.getComments(42)   #doctest: +NORMALIZE_WHITESPACE
        Called vim.command('enew')
        Called xmlrpclib.MultiCall(<ServerProxy for example.com/RPC2>)
        Called blogit.append_comment_to_buffer()
        Called vim.command(
            'setlocal nomodified linebreak
                      foldmethod=marker foldtext=CommentsFoldText()
                      completefunc=BlogitComplete')
        Called blogit.changed_comments()

        >>> minimock.restore()
        """
        if id is None:
            id = self.current_comments['blog_id']
            vim.current.buffer[:] = None
        else:
            vim.command('enew')
        self.current_comments = { 'blog_id': id }
        multicall = xmlrpclib.MultiCall(self.client)
        for comment_typ in ( 'hold', 'spam', 'approve' ):
            multicall.wp.getComments('',
                    self.blog_username, self.blog_password,
                    { 'post_id': id, 'status': comment_typ,
                      'offset': offset, 'number': 1000 })
        self.append_comment_to_buffer()
        for comments, heading in zip(multicall(),
                ( 'In Moderadation', 'Spam', 'Published' )):
            if comments == []:
                continue

            vim.current.buffer[-1] = 72 * '=' + ' {{{1'
            vim.current.buffer.append(5 * ' ' + heading)
            vim.current.buffer.append('')

            fold_levels = {}
            for comment in reversed(comments):
                try:
                    fold = fold_levels[comment['parent']] + 2
                except KeyError:
                    fold = 2
                fold_levels[comment['post_id']] = fold
                self.append_comment_to_buffer(comment, fold)
        vim.command('setlocal nomodified linebreak ' +
            'foldmethod=marker foldtext=CommentsFoldText() ' +
            'completefunc=BlogitComplete')
        if type(self.current_comments['blog_id']) == dict:
            # no comment should have id 'blog_id'.
            sys.stderr.write('A comment used reserved id "blog_id"')
        elif list(self.changed_comments()) != []:
            sys.stderr.write('Bug in BlogIt: Deactivating comment editing:\n')
            for d in self.changed_comments():
                sys.stderr.write('  %s' % d['comment_id'])
                #print list(self.changed_comments())
        else:
            return
        vim.command('setlocal nomodifiable')
        self.current_comments = None

    def changed_comments(self):
        """ Yields comments with changes made to in the vim buffer.

        >>> blogit.current_comments = { '': { 'status': 'new'},
        ...     '1': { 'content': 'Old Text', 'status': 'hold',
        ...             'unknown': 'tag'},
        ...     '2': { 'content': 'Same Text', 'Date': 'old', 'status': 'hold'},
        ...     '3': { 'content': 'Same Again', 'status': 'hold'} }
        >>> vim.current.buffer[:] = [
        ...     60 * '=', 'ID: 1 ', 'Status: hold', '', 'Changed Text',
        ...     60 * '=', 'ID:  ', 'Status: hold', '', 'New Text',
        ...     60 * '=', 'ID: 2', 'Status: hold', 'Date: new', '', 'Same Text',
        ...     60 * '=', 'ID: 3', 'Status: spam', '', 'Same Again',
        ... ]
        >>> list(blogit.changed_comments())    #doctest: +NORMALIZE_WHITESPACE
        [{'content': u'Changed Text', 'status': u'hold', 'unknown': 'tag'},
         {'status': u'hold', 'content': u'New Text'},
         {'content': u'Same Again', 'status': u'spam'}]
        """
        ignored_tags = set([ 'ID', 'Date' ])

        for comment in self.read_comments():
            original_comment = self.current_comments[comment['ID']]
            updated_comment = original_comment.copy()
            for t in comment.keys():
                if t in ignored_tags:
                    continue
                updated_comment[self.comments_meta_data_dict[t]] = \
                        comment[t].decode('utf-8')
            if original_comment != updated_comment:
                yield updated_comment

    def read_comments(self):
        r""" Yields a dict for each comment in the current buffer.

        >>> vim.current.buffer[:] = [
        ...     60 * '=', 'section header',
        ...     60 * '=', 'Tag2: Val2 ',
        ...     60 * '=',
        ...     'Tag:  Value  ', '', 'Some Text', 'in two lines.', '', '',
        ... ]
        >>> list(blogit.read_comments())
        [{'content': 'Some Text\nin two lines.', 'Tag': 'Value'}]
        """

        def process_comment(headers, body):
            body = '\n'.join(body).strip()
            if body == '':
                return None
            d = { 'content': body }
            for t, v in map(self.getMeta, headers):
                d[t.strip()] = v.strip()
            return d

        headers = []
        body = []
        current_section = headers
        for line in vim.current.buffer:
            if line.startswith(60 * '='):
                c = process_comment(headers, body)
                headers, body = [], []
                current_section = headers
                if c is not None:
                    yield c
                continue
            if current_section == headers and line.strip() == '':
                current_section = body
                continue
            current_section.append(line)
        c = process_comment(headers, body)
        if c is not None:
            yield c

    def append_comment_to_buffer(self, comment=None, fold_level=1):
        """
        Formats and appends a given comment to the current buffer. Appends
        an comment template if None is given.

        >>> vim.current.buffer[:] = ['']
        >>> blogit.current_comments = { 'blog_id': 0 }
        >>> blogit.append_comment_to_buffer()
        >>> vim.current.buffer   #doctest: +NORMALIZE_WHITESPACE
        ['======================================================================== {{{1',
        'Status: new',
        'Author: user',
        'ID: ',
        'Parent: 0',
        'Date: ',
        'Type: ',
        '',
        '',
        '',
        '']
        """
        meta_data_f_dict = { 'Date': self.DateTime_to_str }
        if comment is None:
            comment = { 'status': 'new', 'author': self.blog_username,
                        'comment_id': '', 'parent': '0',
                        'date_created_gmt': '', 'type': '', 'content': ''
                      }
        vim.current.buffer[-1] = 72 * '=' + ' {{{%s' % fold_level
        self.append_post(comment, 'content', [ 'Status', 'Author',
                'ID', 'Parent', 'Date', 'Type' ],
                self.comments_meta_data_dict, meta_data_f_dict)
        vim.current.buffer.append('')
        vim.current.buffer.append('')
        vim.current.buffer.append('')
        self.current_comments[str(comment['comment_id'])] = comment

    def getMeta(self, line):
        """
        Reads the meta-data in the current buffer. Outputed as dictionary.

        >>> blogit.getMeta('tag: value')
        ('tag', 'value')
        """
        r = re.compile('^(.*?): (.*)$')
        m = r.match(line)
        return m.group(1, 2)

    def getText(self, lines):
        r"""
        Read the blog text from vim buffer. start_line is the first
        line which is part of the test (not headers). Text is then formated
        as defined by vim variable blogit_format.

        Can raise FilterException.

        >>> mock('vim.mocked_eval')

        >>> blogit.getText([ 'one', 'two', 'tree', 'four' ])
        Called vim.mocked_eval("exists('blogit_format')")
        Called vim.mocked_eval("exists('blogit_postsource')")
        ['one\ntwo\ntree\nfour']

        >>> mock('vim.mocked_eval', returns_iter=['1', 'sort', '0'])
        >>> blogit.getText([ 'one', 'two', 'tree', 'four' ])
        Called vim.mocked_eval("exists('blogit_format')")
        Called vim.mocked_eval('blogit_format')
        Called vim.mocked_eval("exists('blogit_postsource')")
        ['four\none\ntree\ntwo\n']

        >>> mock('vim.mocked_eval', returns_iter=['1', 'false'])
        >>> blogit.getText([ 'one', 'two', 'tree', 'four' ])
        Traceback (most recent call last):
            ...
        FilterException

        >>> minimock.restore()
        """
        text = '\n'.join(lines)
        return map(self.format, text.split('\n<!--more-->\n\n'))

    def unformat(self, text):
        r"""
        >>> mock('vim.mocked_eval', returns_iter=[ '1', 'false' ])
        >>> mock('sys.stderr')
        >>> blogit.unformat('some random text')
        ...         #doctest: +NORMALIZE_WHITESPACE
        Called vim.mocked_eval("exists('blogit_unformat')")
        Called vim.mocked_eval('blogit_unformat')
        Called sys.stderr.write('Blogit: Error happend while filtering
                with:false\n')
        'some random text'

        >>> blogit.unformat('''\n\n
        ...         \n <!--blogit-- Post Source --blogit--> <h1>HTML</h1>''')
        'Post Source'

        >>> minimock.restore()
        """
        if text.lstrip().startswith('<!--blogit-- '):
            return ( text.replace('<!--blogit--', '', 1).
                    split(' --blogit-->', 1)[0].strip() )
        try:
            return self.filter(text, 'unformat')
        except self.FilterException, e:
            sys.stderr.write(e.message)
            return e.input_text

    def format(self, text):
        formated = self.filter(text, 'format')
        if self.blog_postsource:
            formated = "<!--blogit--\n%s\n--blogit-->\n%s" % ( text, formated )
        return formated

    def filter(self, text, vim_var='format'):
        r""" Filter text with command in vim_var.

        Can raise FilterException.

        >>> mock('vim.mocked_eval')
        >>> blogit.filter('some random text')
        Called vim.mocked_eval("exists('blogit_format')")
        'some random text'

        >>> mock('vim.mocked_eval', returns_iter=[ '1', 'false' ])
        >>> blogit.filter('some random text')
        Traceback (most recent call last):
            ...
        FilterException

        >>> mock('vim.mocked_eval', returns_iter=[ '1', 'rev' ])
        >>> blogit.filter('')
        Called vim.mocked_eval("exists('blogit_format')")
        Called vim.mocked_eval('blogit_format')
        ''

        >>> mock('vim.mocked_eval', returns_iter=[ '1', 'rev' ])
        >>> blogit.filter('some random text')
        Called vim.mocked_eval("exists('blogit_format')")
        Called vim.mocked_eval('blogit_format')
        'txet modnar emos\n'

        >>> mock('vim.mocked_eval', returns_iter=[ '1', 'rev' ])
        >>> blogit.filter('some random text\nwith a second line')
        Called vim.mocked_eval("exists('blogit_format')")
        Called vim.mocked_eval('blogit_format')
        'txet modnar emos\nenil dnoces a htiw\n'

        >>> minimock.restore()

        """
        filter = self.vim_variable(vim_var)
        if filter is None:
            return text
        try:
            p = Popen(filter, shell=True, stdin=PIPE, stdout=PIPE, stderr=PIPE)
            p.stdin.write(text)
            p.stdin.close()
            if p.wait():
                raise self.FilterException(p.stderr.read(), text, filter)
            return p.stdout.read()
        except self.FilterException:
            raise
        except Exception, e:
            raise self.FilterException(e.message, text, filter)

    def sendArticle(self, push=None):

        def sendPost(postid, post, push):
            """ Unify newPost and editPost from the metaWeblog API. """
            if postid == '':
                postid = self.client.metaWeblog.newPost('', self.blog_username,
                                                self.blog_password, post, push)
            else:
                self.client.metaWeblog.editPost(postid, self.blog_username,
                                                self.blog_password, post, push)
            return postid

        def date_from_meta(str_date):
            if push is None and self.current_post['post_status'] == 'publish':
                return self.str_to_DateTime(str_date)
            return self.str_to_DateTime()

        def split_comma(x): return x.split(', ')

        if self.current_post_type is not 'post':
            sys.stderr.write("Not editing a post.")
            return
        vim.command('set nomodified')

        post = self.current_post.copy()
        meta_data_f_dict = { 'Categories': split_comma,
                             'Date': date_from_meta }
        push_dict = { 0: 'draft', 1: 'publish',
                      None: self.current_post['post_status'] }
        post['post_status'] = push_dict[push]
        for start_text, line in enumerate(vim.current.buffer):
            if line == '':
                start_text += 1
                break
            label, value = self.getMeta(line)
            if self.meta_data_dict[label].startswith('blogit_'):
                continue
            if label in meta_data_f_dict:
                value = meta_data_f_dict[label](value)
            post[self.meta_data_dict[label]] = value
        if push is None:
            push = 0
        try:
            textl = self.getText(vim.current.buffer[start_text:])
        except self.FilterException, e:
            sys.stderr.write(e.message)
        else:
            post['description'] = textl[0]
            if len(textl) > 1:
                post['mt_text_more'] = textl[1]
        try:
            postid = sendPost(post['postid'], post, push)
        except Fault, e:
            sys.stderr.write(e.faultString)
        else:
            self.display_post(self.getPost(postid))

    def sendComments(self):
        """ Send changed and new comments to server.

        >>> blogit.current_comment = { 'blog_id': 42 }
        >>> mock('sys.stderr')
        >>> mock('blogit.getComments')
        >>> mock('blogit.changed_comments',
        ...         returns=[ { 'status': 'new', 'content': 'New Text' },
        ...             { 'status': 'will fail', 'comment_id': 13 },
        ...             { 'status': 'will succeed', 'comment_id': 7 },
        ...             { 'status': 'rm', 'comment_id': 100 } ])
        >>> mock('xmlrpclib.MultiCall', returns=Mock(
        ...         'multicall', returns=[ 200, False, True, True ]))
        >>> blogit.sendComments()    #doctest: +NORMALIZE_WHITESPACE
        Called xmlrpclib.MultiCall(<ServerProxy for example.com/RPC2>)
        Called blogit.changed_comments()
        Called multicall.wp.newComment(
            '', 'user', 'password', 42,
            {'status': 'approve', 'content': 'New Text'})
        Called multicall.wp.editComment(
            '', 'user', 'password', 13, {'status': 'will fail'})
        Called multicall.wp.editComment(
            '', 'user', 'password', 7, {'status': 'will succeed'})
        Called multicall.wp.deleteComment('', 'user', 'password', 100)
        Called multicall()
        Called sys.stderr.write('Server refuses update to 13.')
        Called blogit.getComments()

        >>> minimock.restore()

        """
        multicall = xmlrpclib.MultiCall(self.client)
        username, password = self.blog_username, self.blog_password
        blog_id = self.current_comments['blog_id']
        multicall_log = []
        for comment in self.changed_comments():
            if comment['status'] == 'new':
                comment['status'] = 'approve'
                multicall.wp.newComment(
                        '', username, password, blog_id, comment)
                multicall_log.append('new')
            elif comment['status'] == 'rm':
                multicall.wp.deleteComment(
                        '', username, password, comment['comment_id'])
            else:
                comment_id = comment['comment_id']
                del comment['comment_id']
                multicall.wp.editComment(
                        '', username, password, comment_id, comment)
                multicall_log.append(comment_id)
        for accepted, comment_id in zip(multicall(), multicall_log):
            if comment_id != 'new' and not accepted:
                sys.stderr.write('Server refuses update to %s.' % comment_id)
        self.getComments()

    @property
    def blog_username(self):
        return self.vim_variable('username')

    @property
    def blog_password(self):
        return self.vim_variable('password')

    @property
    def blog_url(self):
        """
        >>> mock('vim.eval',
        ...      returns_iter=[ '0', '0', '1', 'http://example.com/' ])
        >>> blogit.blog_url
        Called vim.eval("exists('b:blog_name')")
        Called vim.eval("exists('blog_name')")
        Called vim.eval("exists('blogit_url')")
        Called vim.eval('blogit_url')
        'http://example.com/'
        >>> minimock.restore()
        """
        return self.vim_variable('url')

    @property
    def blog_postsource(self):
        """ Bool: Include the unformated version of a post in an html comment.

        If the program only converts to html, you can have blogit save the
        "source" in an html comment (Warning: This doesn't work reliably with
        Wordpress. Use at your own risk).

            let blogit_postsource=1
        """
        return self.vim_variable('postsource') == '1'

    @property
    def blog_name(self):
        for var_name in ( 'b:blog_name', 'blog_name' ):
            var_value = self.vim_variable(var_name, prefix=False)
            if var_value is not None:
                return var_value
        return 'blogit'

    def vim_variable(self, var_name, prefix=True):
        """ Simplefy access to vim-variables. """
        if prefix:
            var_name = '_'.join(( self.blog_name, var_name ))
        if vim.eval("exists('%s')" % var_name) == '1':
            return vim.eval('%s' % var_name)
        else:
            return None

    def vimcommand(f, register_to=vimcommand_help):
        r"""
        >>> class C:
        ...     def command_f(self):
        ...         ' A method. '
        ...         print "f should not be executed."
        ...     def command_g(self, one, two):
        ...         ' A method with options. '
        ...         print "g should not be executed."
        ...
        >>> L = []
        >>> BlogIt.vimcommand(C.command_f, L)
        <unbound method C.command_f>
        >>> L
        [':Blogit f                  A method. \n']

        >>> BlogIt.vimcommand(C.command_g, L)
        <unbound method C.command_g>
        >>> L     #doctest: +NORMALIZE_WHITESPACE
        [':Blogit f                  A method. \n',
         ':Blogit g <one> <two>      A method with options. \n']

        """

        def getArguments(func, skip=0):
            """
            Get arguments of a function as a string.
            skip is the number of skipped arguments.
            """
            skip += 1
            args, varargs, varkw, defaults = getargspec(func)
            arguments = list(args)
            if defaults:
                index = len(arguments)-1
                for default in reversed(defaults):
                    arguments[index] += "=%s" % default
                    index -= 1
            if varargs:
                arguments.append("*" + varargs)
            if varkw:
                arguments.append("**" + varkw)
            return "".join((" <%s>" % s for s in arguments[skip:]))

        command = ( f.func_name.replace('command_', ':Blogit ') +
                getArguments(f) )
        register_to.append('%-25s %s\n' % ( command, f.__doc__ ))
        return f

    @vimcommand
    def command_ls(self):
        """ list all posts """
        try:
            allposts = self.client.metaWeblog.getRecentPosts('',
                    self.blog_username, self.blog_password)
            if not allposts:
                sys.stderr.write("There are no posts.")
                return
            vim.command('botright new')
            self.current_post = None
            vim.current.buffer[0] = "%sID    Date%sTitle" % \
                    ( ' ' * ( len(allposts[0]['postid']) - 2 ),
                    ( ' ' * len(self.DateTime_to_str(
                    allposts[0]['date_created_gmt'], '%x')) ) )
            format = '%%%dd    %%s    %%s' % max(2, len(allposts[0]['postid']))
            for p in allposts:
                vim.current.buffer.append(format % (int(p['postid']),
                        self.DateTime_to_str(p['date_created_gmt'], '%x'),
                        p['title'].encode('utf-8')))
            vim.command('setlocal buftype=nofile bufhidden=wipe nobuflisted ' +
                    'noswapfile syntax=blogsyntax nomodifiable nowrap')
            vim.current.window.cursor = (2, 0)
            vim.command('nnoremap <buffer> <enter> :py blogit.list_edit()<cr>')
            vim.command('nnoremap <buffer> gf :py blogit.list_edit()<cr>')
        except Exception, err:
            sys.stderr.write("An error has occured: %s" % err)

    @vimcommand
    def command_new(self):
        """ create a new post """
        vim.command('enew')
        self.display_post()

    @vimcommand
    def command_this(self):
        """ make this a blog post """
        if self.current_post_type is None:
            self.display_post(new_text='\n'.join(
                [ line for line in vim.current.buffer[:] ]))
        else:
            sys.stderr.write("Already editing a post.")

    @vimcommand
    def command_edit(self, id):
        """ edit a post """
        try:
            id = int(id)
        except ValueError:
            sys.stderr.write("'id' must be an integer value.")
            return

        try:
            post = self.getPost(id)
        except Fault, e:
            sys.stderr.write('Blogit Fault: ' + e.faultString)
        else:
            vim.command('enew')
            self.display_post(post)

    @vimcommand
    def command_commit(self):
        """ commit current post or comments """
        if self.current_post_type == 'comments':
            self.sendComments()
        else:
            self.sendArticle()

    @vimcommand
    def command_push(self):
        """ publish post """
        self.sendArticle(push=1)

    @vimcommand
    def command_unpush(self):
        """ unpublish post """
        self.sendArticle(push=0)

    @vimcommand
    def command_rm(self, id):
        """ remove a post """
        try:
            id = int(id)
        except ValueError:
            sys.stderr.write("'id' must be an integer value.")
            return

        if self.current_post and int(self.current_post['postid']) == int(id):
            vim.command('bdelete')
            self.current_post = None
        try:
            self.client.metaWeblog.deletePost('', id, self.blog_username,
                                              self.blog_password)
        except Fault, e:
            sys.stderr.write(e.faultString)
            return
        sys.stdout.write('Article removed')

    @vimcommand
    def command_tags(self):
        """ update and list tags and categories"""
        username, password = self.blog_username, self.blog_password
        multicall = xmlrpclib.MultiCall(self.client)
        multicall.wp.getCategories('', username, password)
        multicall.wp.getTags('', username, password)
        categories, tags = tuple(multicall())
        tags = [ tag['name'] for tag in tags ]
        categories = [ cat['categoryName'] for cat in categories ]
        vim.command('let s:used_tags = %s' % tags)
        vim.command('let s:used_categories = %s' % categories)
        sys.stdout.write('\n \n \nCategories\n==========\n \n' + ', '.join(categories))
        sys.stdout.write('\n \n \nTags\n====\n \n' + ', '.join(tags))

    @vimcommand
    def command_preview(self):
        """ preview current post locally """
        if self.prev_file is None:
            self.prev_file = tempfile.mkstemp('.html', 'blogit')[1]
        f = open(self.prev_file, 'w')
        start_text = 0
        for line in vim.current.buffer:
            start_text += 1
            if line == '':
                break
        f.write('<br/>'.join(self.getText(vim.current.buffer[start_text:])))
        f.flush()
        f.close()
        webbrowser.open(self.prev_file)

    @vimcommand
    def command_help(self):
        """ display this notice """
        sys.stdout.write("Available commands:\n")
        for f in self.vimcommand_help:
            sys.stdout.write('   ' + f)

    # needed for testing. Prevents beeing used as a decorator if it isn't at
    # the end.
    vimcommand = staticmethod(vimcommand)


blogit = BlogIt()

if doctest:
    doctest.testmod()
