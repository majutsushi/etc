"""
" Copyright (C) 2009-2010 Romain Bignon
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
" Version:      1.4.3
" Last Change:  2010 January 01


runtime! passwords.vim
command! -bang -nargs=* Blogit exec('py blogit.command("<bang>", <f-args>)')

let s:used_categories = []
let s:used_tags = []

function! BlogItComplete(findstart, base)
    " based on code from :he complete-functions
    if a:findstart
        " locate the start of the word
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] =~ '\S'
            let start -= 1
        endwhile
        return start
    else
        let sep = ', '
        if getline('.') =~# '^Categories: '
            let L = s:used_categories
        elseif getline('.') =~# '^Tags: '
            let L = s:used_tags
        elseif getline('.') =~# '^Status: ' && exists('b:blog_post_type')
            if b:blog_post_type == 'comments'
                let L = [ 'approve', 'spam', 'hold', 'new', 'rm' ]
            elseif b:blog_post_type == 'post'
                let L = [ 'draft', 'publish', 'private', 'pending', 'new', 'rm' ]
            else
                let L = [ ]
            endif
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

function! BlogItCommentsFoldText()
    let line_no = v:foldstart
    if v:foldlevel > 1
        while getline(line_no) !~ '^\s*$'
            let line_no += 1
        endwhile
        let title = getline(line_no + 1)
    else
        let title = substitute(getline(line_no + 1), '^ *', '', '')
    endif
    return '+' . v:folddashes . title
endfunction

python <<EOF
# Lets the python unit test ignore everything above this line (docstring). """

import xmlrpclib
import sys
import re
from time import mktime, strptime, strftime, localtime, gmtime
from locale import getpreferredencoding
from calendar import timegm
from subprocess import Popen, CalledProcessError, PIPE
from xmlrpclib import DateTime, Fault, MultiCall
from inspect import getargspec
import webbrowser
import tempfile
import warnings
import gettext
from functools import partial

gettext.textdomain('blogit')
_ = gettext.gettext

try:
    import vim
except ImportError:
    # Used outside of vim (for testing)
    from minimock import Mock, mock
    import minimock
    import doctest
    from mock_vim import vim
else:
    doctest = None

#warnings.simplefilter('ignore', Warning)
warnings.simplefilter('always', UnicodeWarning)


class BlogIt(object):

    @staticmethod
    def enc(text):
        r""" Helper function to encode ascii or unicode strings.

        Used when communicating with Vim buffers and commands.
        """
        try:
            return text.encode('utf-8')
        except UnicodeDecodeError:
            return text


    @staticmethod
    def to_vim_list(L):
        """ Helper function to encode a List for ":let L = [ 'a', 'b' ]" """
        L = ['"%s"' % BlogIt.enc(item).replace('\\', '\\\\')
             .replace('"', r'\"') for item in L]
        return '[ %s ]' % ', '.join(L)


    class BlogItException(Exception):
        pass


    class NoPostException(BlogItException):
        pass


    class BlogItBug(BlogItException):
        pass


    class PostListingEmptyException(BlogItException):
        pass


    class FilterException(BlogItException):

        def __init__(self, message, input_text, filter):
            self.message = "Blogit: Error happend while filtering with:" + \
                    filter + '\n' + message
            self.input_text = input_text
            self.filter = filter


    class VimVars(object):

        def __init__(self, blog_name=None):
            if blog_name is None:
                blog_name = self.vim_blog_name
            self.blog_name = blog_name

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
            >>> BlogIt.VimVars().blog_url
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
            """ Bool: Include unformated version of a post in an html comment.

            If the program only converts to html, you can have blogit save the
            "source" in an html comment (Warning: This doesn't work reliably
            with Wordpress. Use at your own risk).

                let blogit_postsource=1
            """
            return self.vim_variable('postsource') == '1'

        @property
        def vim_blog_name(self):
            for var_name in ('b:blog_name', 'blog_name'):
                var_value = self.vim_variable(var_name, prefix=False)
                if var_value is not None:
                    return var_value
            return 'blogit'

        def vim_variable(self, var_name, prefix=True):
            """ Simplefy access to vim-variables. """
            if prefix:
                var_name = '_'.join((self.blog_name, var_name))
            if vim.eval("exists('%s')" % var_name) == '1':
                return vim.eval('%s' % var_name)
            else:
                return None

        def export_blog_name(self):
            vim.command("let b:blog_name='%s'" % self.blog_name)

        def export_post_type(self, post):
            vim.command("let b:blog_post_type='%s'" % post.POST_TYPE)


    class NoPost(object):
        BLOG_POST_ID = ''

        @property
        def client(self):
            return xmlrpclib.ServerProxy(self.vim_vars.blog_url)

        @property
        def vim_vars(self):
            return BlogIt.VimVars()

        def __getattr__(self, name):
            raise BlogIt.NoPostException


    class AbstractBufferIO(object):

        def refresh_vim_buffer(self):
            vim.current.buffer[:] = [BlogIt.enc(line)
                                            for line in self.display()]
            vim.command('setlocal nomodified')

        def init_vim_buffer(self):
            vim.command('setlocal encoding=utf-8')
            self.refresh_vim_buffer()

        def send(self, lines=[], push=None):
            self.read_post(lines)
            self.do_send(push)

        def do_send(self, push=None):
            raise BlogIt.NoPostException


    class PostListing(AbstractBufferIO):
        POST_TYPE = 'list'

        def __init__(self, vim_vars=None, client=None, row_types=None):
            if vim_vars is None:
                vim_vars = BlogIt.VimVars()
            self.vim_vars = vim_vars
            if client is None:
                client = xmlrpclib.ServerProxy(self.vim_vars.blog_url)
            self.client = client
            self.post_data = None
            if row_types is None:
                row_types = (BlogIt.MetaWeblogPostListingPosts,
                             BlogIt.WordPressPostListingPages)
            self.row_groups = [group(vim_vars) for group in row_types]

        @classmethod
        def create_new_post(cls, vim_vars, body_lines=['']):
            b = cls(vim_vars=vim_vars)
            b.getPost()
            b.init_vim_buffer()
            return b

        def init_vim_buffer(self):
            super(BlogIt.PostListing, self).init_vim_buffer()
            vim.command('setlocal buftype=nofile bufhidden=wipe nobuflisted ' +
                    'noswapfile syntax=blogsyntax nomodifiable nowrap')
            vim.current.window.cursor = (2, 0)
            vim.command('nnoremap <buffer> <enter> :Blogit! list_edit<cr>')
            vim.command('nnoremap <buffer> gf :Blogit! list_edit<cr>')

        def display(self):
            """ Yields the rows of a table displaying the posts (at least one).

            >>> p = BlogIt.PostListing()
            >>> p.display().next()       #doctest: +ELLIPSIS
            Traceback (most recent call last):
              [...]
            PostListingEmptyException
            >>> p.row_groups[0].post_data = [ {'postid': '1',
            ...     'date_created_gmt': DateTime('20090628T17:38:58'),
            ...     'title': 'A title'} ]
            >>> list(p.display())    #doctest: +NORMALIZE_WHITESPACE
            ['ID    Date        Title',
            u' 1    06/28/09    A title']
            >>> p.row_groups[0].post_data = [{'postid': id,
            ...     'date_created_gmt': DateTime(d), 'title': t}
            ...     for id, d, t in zip(( '7', '42' ),
            ...         ( '20090628T17:38:58', '20100628T17:38:58' ),
            ...         ( 'First Title', 'Second Title' )
            ...     )]
            >>> list(p.display())    #doctest: +NORMALIZE_WHITESPACE
            ['ID    Date        Title',
            u' 7    06/28/09    First Title',
            u'42    06/28/10    Second Title']

            """
            for row_group in self.row_groups:
                if not row_group.is_empty:
                    break
            else:
                raise BlogIt.PostListingEmptyException
            id_column_width = max(2, *[p.min_id_column_width
                                            for p in self.row_groups])
            yield "%sID    Date%sTitle" % (' ' * (id_column_width - 2),
                    ' ' * len(BlogIt.DateTime_to_str(DateTime(), '%x')))
            format = '%%%dd    %%s    %%s' % id_column_width
            for row_group in self.row_groups:
                for post_id, date, title in row_group.rows_data():
                    yield format % (int(post_id),
                                    BlogIt.DateTime_to_str(date, '%x'),
                                    title)

        def getPost(self):
            multicall = xmlrpclib.MultiCall(self.client)
            for row_group in self.row_groups:
                row_group.xmlrpc_call__getPost(multicall)
            for row_group, response in zip(self.row_groups, multicall()):
                row_group.getPost(response)

        def open_row(self, n):
            n -= 2    # Table header & vim_buffer lines start at 1
            for row_group in self.row_groups:
                if n < len(row_group.post_data):
                    return row_group.open_row(n)
                else:
                    n -= len(row_group.post_data)


    class AbstractPostListingSource(object):

        def __init__(self, id_date_title_tags, vim_vars):
            self.id_date_title_tags = id_date_title_tags
            self.vim_vars = vim_vars
            self.post_data = []

        def getPost(self, server_response):
            self.post_data = server_response

        @property
        def is_empty(self):
            return len(self.post_data) == 0

        @property
        def min_id_column_width(self):
            return max(-1, -1,    # Work-around max(-1, *[]) not-iterable.
                       *[len(str(p[self.id_date_title_tags[0]]))
                                                for p in self.post_data])

        def rows_data(self):
            post_id, date, title = self.id_date_title_tags
            for p in self.post_data:
                yield (p[post_id], p[date], p[title])


    class MetaWeblogPostListingPosts(AbstractPostListingSource):

        def __init__(self, vim_vars):
            super(BlogIt.MetaWeblogPostListingPosts,
                  self).__init__(('postid', 'date_created_gmt', 'title'),
                                 vim_vars)

        def xmlrpc_call__getPost(self, multicall):
            multicall.metaWeblog.getRecentPosts('',
                    self.vim_vars.blog_username, self.vim_vars.blog_password)

        def open_row(self, n):
            id = self.post_data[n]['postid']
            return BlogIt.WordPressBlogPost(id, vim_vars=self.vim_vars)


    class WordPressPostListingPages(AbstractPostListingSource):

        def __init__(self, vim_vars):
            super(BlogIt.WordPressPostListingPages,
                  self).__init__(('page_id', 'dateCreated', 'page_title'),
                                 vim_vars)

        def xmlrpc_call__getPost(self, multicall):
            multicall.wp.getPageList('',
                    self.vim_vars.blog_username, self.vim_vars.blog_password)

        def open_row(self, n):
            id = self.post_data[n]['page_id']
            return BlogIt.WordPressPage(id, vim_vars=self.vim_vars)

    class PostModel(object):

        def __init__(self, post_data, meta_data_dict, headers, post_body):
            self.post_data = post_data
            self.meta_data_dict = meta_data_dict
            self.headers = headers
            self.post_body = post_body


    class AbstractPost(AbstractBufferIO):

        class BlogItServerVarUndefined(Exception):

            def __init__(self, label):
                super(BlogIt.AbstractPost.BlogItServerVarUndefined,
                      self).__init__('Unknown: %s.' % label)
                self.label = label

        def __init__(self, post_data={}, meta_data_dict={}, headers=[],
                     post_body=''):
            """
            >>> BlogIt.AbstractPost(headers=['a', 'b', 'c']).meta_data_dict
            {'Body': '', 'a': 'a', 'c': 'c', 'b': 'b'}
            """
            self.post_data = post_data
            self.new_post_data = {}
            self.meta_data_dict = {'Body': post_body}
            for h in headers:
                self.meta_data_dict[h] = h
            self.meta_data_dict.update(meta_data_dict)
            self.meta_data_dict['Body'] = post_body
            self.HEADERS = headers
            self.POST_BODY = post_body   # for transition

        def __getattr__(self, name):
            """

            >>> p = BlogIt.AbstractPost()
            >>> mock('p.get_server_var_default', tracker=None)
            >>> mock('p.display_header_default', tracker=None)
            >>> p.get_server_var__foo() == p.get_server_var_default('foo')
            True
            >>> p.get_server_var__A() == p.get_server_var_default('A')
            True
            >>> p.display_header__A() == p.display_header_default('A')
            True
            >>> minimock.restore()
            """

            def base_name():
                start = name.find('__') + 2
                return name[start:]
            if name.startswith('get_server_var__'):
                return lambda: self.get_server_var_default(base_name())
            elif name.startswith('set_server_var__'):
                return lambda val: \
                        self.set_server_var_default(base_name(), val)
            elif name.startswith('display_header__'):
                return lambda: self.display_header_default(base_name())
            elif name.startswith('read_header__'):
                return lambda val: self.read_header_default(base_name(), val)
            raise AttributeError

        def read_header(self, line):
            """ Reads the meta-data line as used in a vim buffer.

            >>> mock('BlogIt.AbstractPost.read_header_default')
            >>> BlogIt.AbstractPost().read_header('tag: value')
            Called BlogIt.AbstractPost.read_header_default('tag', u'value')
            >>> minimock.restore()
            """
            r = re.compile('^(.*?): (.*)$')
            m = r.match(line)
            label, v = m.group(1, 2)
            getattr(self, 'read_header__' + label)(unicode(v.strip(), 'utf-8'))

        def read_body(self, lines):
            r"""
            >>> mock('BlogIt.AbstractPost.read_header_default')
            >>> BlogIt.AbstractPost().read_body(['one', 'two'])
            Called BlogIt.AbstractPost.read_header_default('Body', 'one\ntwo')
            >>> minimock.restore()
            """
            self.read_header__Body('\n'.join(lines).strip())

        def read_post(self, lines):
            r""" Returns the dict from given text of the post.

            >>> BlogIt.AbstractPost(post_body='content', headers=['Tag']
            ...                    ).read_post(['Tag:  Value  ', '',
            ...                                 'Some Text', 'in two lines.' ])
            {'content': 'Some Text\nin two lines.', 'Tag': u'Value'}
            """
            self.set_server_var__Body('')
            for i, line in enumerate(lines):
                if line.strip() == '':
                    self.read_body(lines[i + 1:])
                    break
                self.read_header(line)
            return self.new_post_data

        def display(self):
            for label in self.HEADERS:
                yield self.display_header(label)
            yield ''
            for line in self.display_body():
                yield line

        def display_header(self, label):
            """
            Returns a header line formated as it will be displayed to the user.

            >>> blogit.AbstractPost().display_header('A')
            'A: <A>'
            >>> blogit.AbstractPost(meta_data_dict={'A': 'a'}
            ...                    ).display_header('A')
            'A: <A>'
            >>> blogit.AbstractPost(post_data={'b': 'two'},
            ...     meta_data_dict={'A': 'a'}).display_header('A')
            'A: <A>'
            >>> blogit.AbstractPost(post_data={'a': 'one', 'b': 'two'},
            ...     meta_data_dict={'A': 'a'}).display_header('A')
            'A: one'

            >>> class B(BlogIt.AbstractPost):
            ...     def display_header__to_be_tested(self):
            ...         return 'text'
            >>> B().display_header('to_be_tested')
            'to_be_tested: text'

            >>> BlogIt.AbstractPost().display_header__foo()
            '<foo>'
            """
            text = getattr(self, 'display_header__' + label)()
            return '%s: %s' % (label, unicode(text).encode('utf-8'))

        def display_header_default(self, label):
            return getattr(self, 'get_server_var__' + label)()

        def read_header_default(self, label, text):
            getattr(self, 'set_server_var__' + label)(text.strip())

        def get_server_var_default(self, label):
            """

            >>> BlogIt.AbstractPost().get_server_var_default('foo')
            '<foo>'
            >>> BlogIt.AbstractPost().get_server_var_default('foo_AS_bar'
            ... )     #doctest: +ELLIPSIS
            Traceback (most recent call last):
                ...
            BlogItServerVarUndefined: Unknown: foo_AS_bar.
            """
            try:
                try:
                    return self.post_data[self.meta_data_dict[label]]
                except KeyError:
                    return self.post_data[label]
            except KeyError:
                if '_AS_' in label:
                    raise self.BlogItServerVarUndefined(label)
                else:
                    return self.get_server_var_not_found(label)

        def get_server_var_not_found(self, label):
            return '<%s>' % label

        def get_server_var_different_type(self, label, from_type):
            """
            >>> blogit.AbstractPost(post_data={'a': 'one, two, three' },
            ...     meta_data_dict={'Tags': 'a'}).display_header('Tags')
            'Tags: one, two, three'
            >>> blogit.AbstractPost({'a': [ 'one', 'two', 'three' ]},
            ...                     {'Tags_AS_list': 'a'}
            ...                    ).display_header('Tags')
            'Tags: one, two, three'
            >>> blogit.AbstractPost({}).display_header('Tags')
            'Tags: <Tags>'
            """
            try:
                val = getattr(self, 'get_server_var__%s_AS_%s' %
                                    (label, from_type))()
            except self.BlogItServerVarUndefined:
                return self.get_server_var_default(label)
            else:
                return getattr(self, 'server_var_from__' + from_type)(val)

        def set_server_var_different_type(self, label, from_type, str_val):
            """
            >>> p = blogit.AbstractPost(post_data={'a': 'b'},
            ...     meta_data_dict={'Tags': 'a'})
            >>> p.set_server_var__Tags('one, two, three')
            >>> p.new_post_data
            {'a': 'one, two, three'}
            >>> p = blogit.AbstractPost({'a': [ 'b' ]},
            ...                         {'Tags_AS_list': 'a'})
            >>> p.set_server_var__Tags('one, two, three')
            >>> p.new_post_data
            {'a': ['one', 'two', 'three']}
            """
            val = getattr(self, 'server_var_to__' + from_type)(str_val)
            try:
                getattr(self, 'set_server_var__%s_AS_%s' % (label,
                                                            from_type))(val)
            except self.BlogItServerVarUndefined:
                self.set_server_var_default(label, str_val)

        def get_server_var__Date(self):
            return self.get_server_var_different_type('Date', 'DateTime')

        def set_server_var__Date(self, val):
            try:
                self.set_server_var_different_type('Date', 'DateTime', val)
            except ValueError:
                pass

        def get_server_var__Categories(self):
            return self.get_server_var_different_type('Categories', 'list')

        def set_server_var__Categories(self, val):
            self.set_server_var_different_type('Categories', 'list', val)

        def get_server_var__Tags(self):
            return self.get_server_var_different_type('Tags', 'list')

        def set_server_var__Tags(self, val):
            self.set_server_var_different_type('Tags', 'list', val)

        def server_var_to__DateTime(self, str_val):
            return BlogIt.str_to_DateTime(str_val)

        def server_var_from__DateTime(self, val):
            return BlogIt.DateTime_to_str(val)

        def server_var_to__list(self, str_val):
            return [s.strip() for s in str_val.split(',')]

        def server_var_from__list(self, val):
            return ', '.join(val)

        def set_server_var_default(self, label, val):
            try:
                self.new_post_data[self.meta_data_dict[label]] = val
            except KeyError:
                raise self.BlogItServerVarUndefined(label)


    class BlogPost(AbstractPost):
        POST_TYPE = 'post'

        def __init__(self, blog_post_id, post_data={}, meta_data_dict={},
                     headers=None, post_body='description', vim_vars=None):
            if headers is None:
                headers = ['From', 'Id', 'Subject', 'Status',
                           'Categories', 'Tags', 'Date']
            if vim_vars is None:
                vim_vars = BlogIt.VimVars()
            super(BlogIt.BlogPost, self).__init__(post_data, meta_data_dict,
                     headers, post_body)
            self.vim_vars = vim_vars
            self.BLOG_POST_ID = blog_post_id

        def display_header__Status(self):
            d = self.get_server_var__Status_AS_dict()
            if d == '':
                return u'new'
            comment_typ_count = ['%s %s' % (d[key], text)
                    for key, text in (('awaiting_moderation', 'awaiting'),
                                      ('spam', 'spam'))
                    if d[key] > 0]
            if comment_typ_count == []:
                s = u''
            else:
                s = u' (%s)' % ', '.join(comment_typ_count)
            return (u'%(post_status)s \u2013 %(total_comments)s Comments'
                    + s) % d

        def init_vim_buffer(self):
            super(BlogIt.BlogPost, self).init_vim_buffer()
            vim.command('nnoremap <buffer> gf :Blogit! list_comments<cr>')
            vim.command('setlocal ft=mail textwidth=0 ' +
                                 'completefunc=BlogItComplete')
            vim.current.window.cursor = (8, 0)

        def read_header__Body(self, text):
            """
            >>> mock('BlogIt.BlogPost.format', returns='text', tracker=None)
            >>> p = BlogIt.BlogPost('')
            >>> p.read_header__Body('text'); p.new_post_data
            {'description': 'text'}
            >>> minimock.restore()
            """
            L = map(self.format, text.split('\n<!--more-->\n\n'))
            #super(BlogIt.BlogPost, self).read_header__Body(L[0])
            BlogIt.AbstractPost.read_header_default(self, 'Body', L[0])
            if len(L) == 2:
                self.read_header__Body_mt_more(L[1])

        def unformat(self, text):
            r"""
            >>> mock('vim.mocked_eval', returns_iter=[ '1', 'false' ])
            >>> mock('sys.stderr')
            >>> BlogIt.BlogPost(42).unformat('some random text')
            ...         #doctest: +NORMALIZE_WHITESPACE
            Called vim.mocked_eval("exists('blogit_unformat')")
            Called vim.mocked_eval('blogit_unformat')
            Called sys.stderr.write('Blogit: Error happend while filtering
                    with:false\n')
            'some random text'

            >>> BlogIt.BlogPost(42).unformat('''\n\n \n
            ...         <!--blogit-- Post Source --blogit--> <h1>HTML</h1>''')
            'Post Source'

            >>> minimock.restore()
            """
            if text.lstrip().startswith('<!--blogit-- '):
                return (text.replace('<!--blogit--', '',
                                     1).split(' --blogit-->', 1)[0].strip())
            try:
                return self.filter(text, 'unformat')
            except BlogIt.FilterException, e:
                sys.stderr.write(e.message)
                return e.input_text

        def format(self, text):
            r"""

            Can raise FilterException.

            >>> mock('vim.mocked_eval')

            >>> blogit.BlogPost(42).format('one\ntwo\ntree\nfour')
            Called vim.mocked_eval("exists('blogit_format')")
            Called vim.mocked_eval("exists('blogit_postsource')")
            'one\ntwo\ntree\nfour'

            >>> mock('vim.mocked_eval', returns_iter=['1', 'sort', '0'])
            >>> blogit.BlogPost(42).format('one\ntwo\ntree\nfour')
            Called vim.mocked_eval("exists('blogit_format')")
            Called vim.mocked_eval('blogit_format')
            Called vim.mocked_eval("exists('blogit_postsource')")
            'four\none\ntree\ntwo\n'

            >>> mock('vim.mocked_eval', returns_iter=['1', 'false'])
            >>> blogit.BlogPost(42).format('one\ntwo\ntree\nfour')
            Traceback (most recent call last):
                ...
            FilterException

            >>> minimock.restore()
            """
            formated = self.filter(text, 'format')
            if self.vim_vars.blog_postsource:
                formated = "<!--blogit--\n%s\n--blogit-->\n%s" % (text,
                                                                  formated)
            return formated

        def filter(self, text, vim_var='format'):
            r""" Filter text with command in vim_var.

            Can raise FilterException.

            >>> mock('vim.mocked_eval')
            >>> BlogIt.BlogPost(42).filter('some random text')
            Called vim.mocked_eval("exists('blogit_format')")
            'some random text'

            >>> mock('vim.mocked_eval', returns_iter=[ '1', 'false' ])
            >>> BlogIt.BlogPost(42).filter('some random text')
            Traceback (most recent call last):
                ...
            FilterException

            >>> mock('vim.mocked_eval', returns_iter=[ '1', 'rev' ])
            >>> BlogIt.BlogPost(42).filter('')
            Called vim.mocked_eval("exists('blogit_format')")
            Called vim.mocked_eval('blogit_format')
            ''

            >>> mock('vim.mocked_eval', returns_iter=[ '1', 'rev' ])
            >>> BlogIt.BlogPost(42).filter('some random text')
            Called vim.mocked_eval("exists('blogit_format')")
            Called vim.mocked_eval('blogit_format')
            'txet modnar emos\n'

            >>> mock('vim.mocked_eval', returns_iter=[ '1', 'rev' ])
            >>> BlogIt.BlogPost(42).filter(
            ...         'some random text\nwith a second line')
            Called vim.mocked_eval("exists('blogit_format')")
            Called vim.mocked_eval('blogit_format')
            'txet modnar emos\nenil dnoces a htiw\n'

            >>> minimock.restore()

            """
            filter = self.vim_vars.vim_variable(vim_var)
            if filter is None:
                return text
            try:
                p = Popen(filter, shell=True, stdin=PIPE, stdout=PIPE,
                          stderr=PIPE)
                try:
                    p.stdin.write(text.encode(getpreferredencoding()))
                except UnicodeDecodeError:
                    p.stdin.write(text.decode('utf-8')\
                                      .encode(getpreferredencoding()))
                p.stdin.close()
                if p.wait():
                    raise BlogIt.FilterException(p.stderr.read(), text, filter)
                return p.stdout.read().decode(getpreferredencoding())\
                                      .encode('utf-8')
            except BlogIt.FilterException:
                raise
            except Exception, e:
                raise BlogIt.FilterException(e.message, text, filter)

        def display_body(self):
            """
            Yields the lines of a post body.
            """
            content = self.unformat(self.post_data.get(self.POST_BODY, ''))
            for line in content.splitlines():
                yield line

            if self.post_data.get('mt_text_more'):
                yield ''
                yield '<!--more-->'
                yield ''
                content = self.unformat(self.post_data["mt_text_more"])
                for line in content.splitlines():
                    yield line


    class WordPressBlogPost(BlogPost):

        def __init__(self, blog_post_id, post_data={}, meta_data_dict=None,
                     headers=None, post_body='description', vim_vars=None,
                     client=None):
            if meta_data_dict is None:
                meta_data_dict = {'From': 'wp_author_display_name',
                                  'Id': 'postid',
                                  'Subject': 'title',
                                  'Categories_AS_list': 'categories',
                                  'Tags': 'mt_keywords',
                                  'Date_AS_DateTime': 'date_created_gmt',
                                  'Status_AS_dict': 'blogit_status',
                                 }
            super(BlogIt.WordPressBlogPost,
                  self).__init__(blog_post_id, post_data, meta_data_dict,
                                 headers, post_body, vim_vars)
            if client is None:
                client = xmlrpclib.ServerProxy(self.vim_vars.blog_url)
            self.client = client

        def do_send(self, push=None):
            """ Send post to server.

            >>> mock('sys.stderr')
            >>> p = BlogIt.WordPressBlogPost(42,
            ...         {'post_status': 'new', 'postid': 42})
            >>> mock('p.client'); mock('p.getPost'); mock('p.display')
            >>> mock('vim.mocked_eval', tracker=None)
            >>> p.send(['', 'text'])    #doctest: +NORMALIZE_WHITESPACE
            Called p.client.metaWeblog.editPost( 42, 'user', 'password',
                    {'post_status': 'new', 'postid': 42,
                     'description': 'text'}, 0)
            Called p.getPost()
            >>> minimock.restore()
            """

            def sendPost(push):
                """ Unify newPost and editPost from the metaWeblog API. """
                if self.BLOG_POST_ID == '':
                    self.BLOG_POST_ID = self.client.metaWeblog.newPost('',
                            self.vim_vars.blog_username,
                            self.vim_vars.blog_password, self.post_data, push)
                else:
                    self.client.metaWeblog.editPost(self.BLOG_POST_ID,
                            self.vim_vars.blog_username,
                            self.vim_vars.blog_password, self.post_data, push)

            if push == 0 or self.get_server_var__post_status() == 'draft':
                self.set_server_var__Date_AS_DateTime(DateTime())
            self.post_data.update(self.new_post_data)
            push_dict = {0: 'draft', 1: 'publish',
                         None: self.post_data['post_status']}
            self.post_data['post_status'] = push_dict[push]
            if push is None:
                push = 0
            try:
                sendPost(push)
            except Fault, e:
                sys.stderr.write(e.faultString)
            self.getPost()

        def getPost(self):
            """
            >>> mock('xmlrpclib.MultiCall', returns=Mock(
            ...         'multicall', returns=[{'post_status': 'draft'}, {}]))
            >>> mock('vim.mocked_eval')

            >>> p = BlogIt.WordPressBlogPost(42)
            >>> p.getPost()    #doctest: +NORMALIZE_WHITESPACE
            Called xmlrpclib.MultiCall(<ServerProxy for example.com/RPC2>)
            Called multicall.metaWeblog.getPost(42, 'user', 'password')
            Called multicall.wp.getCommentCount('', 'user', 'password', 42)
            Called vim.mocked_eval('s:used_tags == [] ||
                                    s:used_categories == []')
            Called multicall()
            >>> sorted(p.post_data.items())    #doctest: +NORMALIZE_WHITESPACE
            [('blogit_status', {'post_status': 'draft'}),
             ('post_status', 'draft')]
            >>> minimock.restore()

            """
            username = self.vim_vars.blog_username
            password = self.vim_vars.blog_password

            multicall = xmlrpclib.MultiCall(self.client)
            multicall.metaWeblog.getPost(self.BLOG_POST_ID, username, password)
            multicall.wp.getCommentCount('', username, password,
                                         self.BLOG_POST_ID)
            if vim.eval('s:used_tags == [] || s:used_categories == []') == '1':
                multicall.wp.getCategories('', username, password)
                multicall.wp.getTags('', username, password)
                d, comments, categories, tags = tuple(multicall())
                vim.command('let s:used_tags = %s' % BlogIt.to_vim_list(
                        [tag['name'] for tag in tags]))
                vim.command('let s:used_categories = %s' %
                            BlogIt.to_vim_list([cat['categoryName']
                                                    for cat in categories]))
            else:
                d, comments = tuple(multicall())
            comments['post_status'] = d['post_status']
            d['blogit_status'] = comments
            self.post_data = d

        @classmethod
        def create_new_post(cls, vim_vars, body_lines=['']):
            """
            >>> mock('vim.command', tracker=None)
            >>> mock('vim.mocked_eval', tracker=None)
            >>> BlogIt.WordPressBlogPost.create_new_post(BlogIt.VimVars()
            ... )     #doctest: +ELLIPSIS
            <testing.blogit.WordPressBlogPost object at 0x...>
            >>> minimock.restore()
            """
            b = cls('', post_data={'post_status': 'draft', 'description': '',
                    'wp_author_display_name': vim_vars.blog_username,
                    'postid': '', 'categories': [], 'mt_keywords': '',
                    'date_created_gmt': '', 'title': '',
                    'Status_AS_dict': {'awaiting_moderation': 0, 'spam': 0,
                                       'post_status': 'draft',
                                       'total_comments': 0, }},
                    vim_vars=vim_vars)
            b.init_vim_buffer()
            if body_lines != ['']:
                vim.current.buffer[-1:] = body_lines
            return b


    class Page(BlogPost):
        POST_TYPE = 'page'

        def __init__(self, blog_post_id, post_data={}, meta_data_dict={},
                     headers=None, post_body='description', vim_vars=None,
                     client=None):
            if headers is None:
                headers = ['From', 'Id', 'Subject', 'Status', 'Categories',
                           'Date']
            super(BlogIt.Page, self).__init__(blog_post_id, post_data,
                                              meta_data_dict, headers,
                                              post_body, vim_vars)

        def read_header__Id(self, text):
            """
            >>> mock('BlogIt.BlogPost.set_server_var_default')
            >>> BlogIt.Page(42).read_header__Id('42 (about)')
            Called BlogIt.BlogPost.set_server_var_default('Page', 'about')
            Called BlogIt.BlogPost.set_server_var_default('Id', '42')
            >>> BlogIt.Page(42).read_header__Id(' (about)')
            Called BlogIt.BlogPost.set_server_var_default('Page', 'about')
            Called BlogIt.BlogPost.set_server_var_default('Id', '')
            >>> minimock.restore()
            """
            id, page = re.match('(\d*) *\((.*)\)', text).group(1, 2)
            self.set_server_var__Page(page)
            #super(BlogIt.Page, self).read_header__Id(id)
            BlogIt.BlogPost.read_header_default(self, 'Id', id)

        def display_header__Id(self):
            """
            >>> mock('BlogIt.BlogPost.get_server_var_default',
            ...      returns_iter=[42, 'about'], tracker=None)
            >>> BlogIt.Page(42).display_header__Id()
            '42 (about)'
            >>> minimock.restore()
            """
            #super(BlogIt.Page, self).display_header__Id()
            return '%s (%s)' % (BlogIt.BlogPost.display_header_default(self,
                                                                       'Id'),
                                self.get_server_var__Page())


    class WordPressPage(Page):

        def __init__(self, blog_post_id, post_data={}, meta_data_dict=None,
                     headers=None, post_body='description', vim_vars=None,
                     client=None):
            if meta_data_dict is None:
                meta_data_dict = {'From': 'wp_author_display_name',
                                  'Id': 'page_id',
                                  'Subject': 'title',
                                  'Categories_AS_list': 'categories',
                                  'Date_AS_DateTime': 'dateCreated',
                                  'Status_AS_dict': 'blogit_status',
                                  'Page': 'wp_slug',
                                  'Status_post': 'page_status',
                                 }
            super(BlogIt.WordPressPage,
                  self).__init__(blog_post_id, post_data, meta_data_dict,
                                 headers, post_body, vim_vars)
            if client is None:
                client = xmlrpclib.ServerProxy(self.vim_vars.blog_url)
            self.client = client

        def do_send(self, push=None):
            if push == 1:
                self.set_server_var__Date_AS_DateTime(DateTime())
                self.set_server_var__Status_post('publish')
            elif push == 0:
                self.set_server_var__Date_AS_DateTime(DateTime())
                self.set_server_var__Status_post('draft')
            self.post_data.update(self.new_post_data)
            if self.BLOG_POST_ID == '':
                self.BLOG_POST_ID = self.client.wp.newPage('',
                                                 self.vim_vars.blog_username,
                                                 self.vim_vars.blog_password,
                                                 self.post_data)
            else:
                self.client.wp.editPage('', self.BLOG_POST_ID,
                                        self.vim_vars.blog_username,
                                        self.vim_vars.blog_password,
                                        self.post_data)
            self.getPost()

        def getPost(self):
            username = self.vim_vars.blog_username
            password = self.vim_vars.blog_password

            multicall = xmlrpclib.MultiCall(self.client)
            multicall.wp.getPage('', self.BLOG_POST_ID, username, password)
            multicall.wp.getCommentCount('', username, password,
                                         self.BLOG_POST_ID)
            d, comments = tuple(multicall())
            comments['post_status'] = d['page_status']
            d['blogit_status'] = comments
            self.post_data = d

        @classmethod
        def create_new_post(cls, vim_vars, body_lines=['']):
            """
            >>> mock('vim.command', tracker=None)
            >>> mock('vim.mocked_eval', tracker=None)
            >>> BlogIt.WordPressPage.create_new_post(BlogIt.VimVars()
            ... )     #doctest: +ELLIPSIS
            <testing.blogit.WordPressPage object at 0x...>
            >>> minimock.restore()
            """
            b = cls('', post_data={'page_status': 'draft', 'description': '',
                    'wp_author_display_name': vim_vars.blog_username,
                    'page_id': '', 'wp_slug': '', 'title': '',
                    'categories': [], 'dateCreated': '',
                    'Status_AS_dict': {'awaiting_moderation': 0, 'spam': 0,
                                       'post_status': 'draft',
                                       'total_comments': 0}},
                    vim_vars=vim_vars)
            b.init_vim_buffer()
            if body_lines != ['']:
                vim.current.buffer[-1:] = body_lines
            return b


    class Comment(AbstractPost):

        def __init__(self, post_data={}, meta_data_dict={}, headers=None,
                     post_body='content'):
            if headers is None:
                headers = ['Status', 'Author', 'ID', 'Parent', 'Date', 'Type']
            super(BlogIt.Comment, self).__init__(post_data, meta_data_dict,
                     headers, post_body)

        def display_body(self):
            """
            Yields the lines of a post body.
            """
            content = self.post_data.get(self.POST_BODY, '')
            for line in content.split('\n'):
                # not splitlines to preserve \r\n in comments.
                yield line

        @classmethod
        def create_emtpy_comment(cls, *a, **d):
            c = cls(*a, **d)
            c.read_post(['Status: new', 'Author: ', 'ID: ', 'Parent: 0',
                         'Date: ', 'Type: ', '', ''])
            c.post_data = c.new_post_data
            return c


    class CommentList(Comment):
        POST_TYPE = 'comments'

        def __init__(self, meta_data_dict={}, headers=None,
                     post_body='content', comment_categories=None):
            super(BlogIt.CommentList, self).__init__({}, meta_data_dict,
                     headers, post_body)
            if comment_categories is None:
                comment_categories = ('New', 'In Moderadation', 'Spam',
                                      'Published')
            self.comment_categories = comment_categories
            self.empty_comment_list()

        def init_vim_buffer(self):
            super(BlogIt.CommentList, self).init_vim_buffer()
            vim.command('setlocal linebreak completefunc=BlogItComplete ' +
                               'foldmethod=marker ' +
                               'foldtext=BlogItCommentsFoldText()')

        def empty_comment_list(self):
            self.comment_list = {}
            self.comments_by_category = {}
            empty_comment = BlogIt.Comment.create_emtpy_comment({},
                             self.meta_data_dict, self.HEADERS, self.POST_BODY)
            self.add_comment('New', empty_comment.post_data)

        def add_comment(self, category, comment_dict):
            """ Callee must garanty that no comment with same id is in list.

            >>> cl = BlogIt.CommentList()
            >>> cl.add_comment('hold', {'ID': '1',
            ...                         'content': 'Some Text',
            ...                         'Status': 'hold'})
            >>> [ (id, c.post_data) for id, c in cl.comment_list.iteritems()
            ... ]    #doctest: +NORMALIZE_WHITESPACE +ELLIPSIS
            [(u'', {'Status': u'new', 'Parent': u'0', 'Author': u'',
              'content': '', 'Date': u'', 'Type': u'', 'ID': u''}),
             ('1', {'content': 'Some Text', 'Status': 'hold', 'ID': '1'})]
            >>> [ (cat, [ c.post_data['ID'] for c in L ])
            ...         for cat, L in cl.comments_by_category.iteritems()
            ... ]    #doctest: +NORMALIZE_WHITESPACE
            [('New', [u'']), ('hold', ['1'])]
            >>> cl.add_comment('spam', {'ID': '1'}
            ...               )    #doctest: +ELLIPSIS
            Traceback (most recent call last):
                ...
            AssertionError...
            """
            comment = BlogIt.Comment(comment_dict, self.meta_data_dict,
                                     self.HEADERS, self.POST_BODY)
            assert not comment.get_server_var__ID() in self.comment_list
            self.comment_list[comment.get_server_var__ID()] = comment
            try:
                self.comments_by_category[category].append(comment)
            except KeyError:
                self.comments_by_category[category] = [comment]

        def display(self):
            """

            >>> list(BlogIt.CommentList().display())
            ...     #doctest: +NORMALIZE_WHITESPACE
            ['======================================================================== {{{1',
             '     New',
             '======================================================================== {{{2',
             'Status: new',
             'Author: ',
             'ID: ',
             'Parent: 0',
             'Date: ',
             'Type: ',
             '',
             '',
             '']
            """
            for heading in self.comment_categories:
                try:
                    comments = self.comments_by_category[heading]
                except KeyError:
                    continue

                yield 72 * '=' + ' {{{1'
                yield 5 * ' ' + heading.capitalize()

                fold_levels = {}
                for comment in reversed(comments):
                    try:
                        fold = fold_levels[comment.post_data['parent']] + 2
                    except KeyError:
                        fold = 2
                    fold_levels[comment.get_server_var__ID()] = fold
                    yield 72 * '=' + ' {{{%s' % fold
                    for line in comment.display():
                        yield line
                    yield ''

        def _read_post__read_comment(self, lines):
            self.new_post_data = {}
            new_post_data = super(BlogIt.CommentList, self).read_post(lines)
            return BlogIt.Comment(new_post_data, self.meta_data_dict,
                                  self.HEADERS, self.POST_BODY)

        def read_post(self, lines):
            r""" Yields a dict for each comment in the current buffer.

            >>> cl = BlogIt.CommentList().read_post([
            ...     60 * '=', 'ID: 1 ', 'Status: hold', '', 'Text',
            ...     60 * '=', 'ID:  ', 'Status: hold', '', 'Text',
            ...     60 * '=', 'ID: 3', 'Status: spam', '', 'Text' ])
            >>> [ c.post_data for c in cl ]     #doctest: +NORMALIZE_WHITESPACE
            [{'content': 'Text', 'Status': u'hold', 'ID': u'1'},
             {'content': 'Text', 'Status': u'hold', 'ID': u''},
             {'content': 'Text', 'Status': u'spam', 'ID': u'3'}]

            >>> mock('BlogIt.Comment.create_emtpy_comment',
            ...      returns=BlogIt.Comment(headers=['Tag', 'Tag2']))
            >>> cl = BlogIt.CommentList(headers=['Tag', 'Tag2']).read_post([
            ...     60 * '=', 'Tag2: Val2 ', '',
            ...     60 * '=',
            ...     'Tag:  Value  ', '', 'Some Text', 'in two lines.   ' ])
            Called BlogIt.Comment.create_emtpy_comment(
                {},
                {'Body': 'content', 'Tag': 'Tag', 'Tag2': 'Tag2'},
                ['Tag', 'Tag2'],
                'content')
            >>> [ c.post_data for c in cl ]     #doctest: +NORMALIZE_WHITESPACE
            [{'content': '', 'Tag2': u'Val2'},
             {'content': 'Some Text\nin two lines.', 'Tag': u'Value'}]
            >>> minimock.restore()
            """
            j = 0
            lines = list(lines)
            for i, line in enumerate(lines):
                if line.startswith(60 * '='):
                    if i - j > 1:
                        yield self._read_post__read_comment(lines[j:i])
                    j = i + 1
            yield self._read_post__read_comment(lines[j:])

        def changed_comments(self, lines):
            """ Yields comments with changes made to in the vim buffer.

            >>> cl = BlogIt.CommentList()
            >>> for comment_dict in [
            ...         {'ID': '1', 'content': 'Old Text',
            ...          'Status': 'hold', 'unknown': 'tag'},
            ...         {'ID': '2', 'content': 'Same Text',
            ...          'Date': 'old', 'Status': 'hold'},
            ...         {'ID': '3', 'content': 'Same Again',
            ...          'Status': 'hold'}]:
            ...     cl.add_comment('', comment_dict)
            >>> [ c.post_data for c in cl.changed_comments([
            ...     60 * '=', 'ID: 1 ', 'Status: hold', '', 'Changed Text',
            ...     60 * '=', 'ID:  ', 'Status: hold', '', 'New Text',
            ...     60 * '=', 'ID: 2', 'Status: hold', 'Date: new', '',
            ...             'Same Text',
            ...     60 * '=', 'ID: 3', 'Status: spam', '', 'Same Again' ])
            ... ]      #doctest: +NORMALIZE_WHITESPACE +ELLIPSIS
            [{'content': 'Changed Text', 'Status': u'hold', 'unknown': 'tag',
              'ID': u'1'},
             {'Status': u'hold', 'content': 'New Text', 'Parent': u'0',
              'Author': u'', 'Date': u'', 'Type': u'', 'ID': u''},
             {'content': 'Same Again', 'Status': u'spam', 'ID': u'3'}]

            """

            for comment in self.read_post(lines):
                original_comment = self.comment_list[
                        comment.get_server_var__ID()].post_data
                new_comment = original_comment.copy()
                new_comment.update(comment.post_data)
                if original_comment != new_comment:
                    comment.post_data = new_comment
                    yield comment

        @classmethod
        def create_from_post(cls, blog_post):
            return cls(blog_post.BLOG_POST_ID, vim_vars=blog_post.vim_vars)


    class WordPressCommentList(CommentList):

        def __init__(self, blog_post_id, meta_data_dict=None, headers=None,
                     post_body='content', vim_vars=None, client=None,
                     comment_categories=None):
            if meta_data_dict is None:
                meta_data_dict = {'Status': 'status', 'Author': 'author',
                                  'ID': 'comment_id', 'Parent': 'parent',
                                  'Date_AS_DateTime': 'date_created_gmt',
                                  'Type': 'type', 'content': 'content',
                                 }
            super(BlogIt.WordPressCommentList, self).__init__(
                    meta_data_dict, headers, post_body, comment_categories)
            if vim_vars is None:
                vim_vars = BlogIt.VimVars()
            self.vim_vars = vim_vars
            if client is None:
                client = xmlrpclib.ServerProxy(self.vim_vars.blog_url)
            self.client = client
            self.BLOG_POST_ID = blog_post_id

        def send(self, lines):
            """ Send changed and new comments to server.

            >>> c = BlogIt.WordPressCommentList(42)
            >>> mock('sys.stderr')
            >>> mock('c.getComments')
            >>> mock('c.changed_comments',
            ...         returns=[ BlogIt.Comment(post_data, c.meta_data_dict)
            ...             for post_data in
            ...                 { 'status': 'new', 'content': 'New Text' },
            ...                 { 'status': 'will fail', 'comment_id': 13 },
            ...                 { 'status': 'will succeed', 'comment_id': 7 },
            ...                 { 'status': 'rm', 'comment_id': 100 } ])
            >>> mock('xmlrpclib.MultiCall', returns=Mock(
            ...         'multicall', returns=[ 200, False, True, True ]))
            >>> c.send(None)    #doctest: +NORMALIZE_WHITESPACE
            Called xmlrpclib.MultiCall(<ServerProxy for example.com/RPC2>)
            Called c.changed_comments(None)
            Called multicall.wp.newComment( '', 'user', 'password', 42,
                {'status': 'approve', 'content': 'New Text'})
            Called multicall.wp.editComment( '', 'user', 'password', 13,
                {'status': 'will fail', 'comment_id': 13})
            Called multicall.wp.editComment( '', 'user', 'password', 7,
                 {'status': 'will succeed', 'comment_id': 7})
            Called multicall.wp.deleteComment('', 'user', 'password', 100)
            Called multicall()
            Called sys.stderr.write('Server refuses update to 13.')
            Called c.getComments()

            >>> vim.current.buffer.change_buffer()
            >>> minimock.restore()

            """
            multicall = xmlrpclib.MultiCall(self.client)
            username, password = (self.vim_vars.blog_username,
                                  self.vim_vars.blog_password)
            multicall_log = []
            for comment in self.changed_comments(lines):
                if comment.get_server_var__Status() == 'new':
                    comment.set_server_var__Status('approve')
                    comment.post_data.update(comment.new_post_data)
                    multicall.wp.newComment('', username, password,
                                            self.BLOG_POST_ID,
                                            comment.post_data)
                    multicall_log.append('new')
                elif comment.get_server_var__Status() == 'rm':
                    multicall.wp.deleteComment('', username, password,
                                               comment.get_server_var__ID())
                else:
                    comment_id = comment.get_server_var__ID()
                    multicall.wp.editComment('', username, password,
                                             comment_id, comment.post_data)
                    multicall_log.append(comment_id)
            for accepted, comment_id in zip(multicall(), multicall_log):
                if comment_id != 'new' and not accepted:
                    sys.stderr.write('Server refuses update to %s.' %
                                     comment_id)
            return self.getComments()

        def _no_send(self, lines=[], push=None):
            """ Replace send() with this to prevent the user from commiting.
            """
            raise BlogIt.NoPostException

        def getComments(self, offset=0):
            """ Lists the comments to a post with given id in a new buffer.

            >>> mock('xmlrpclib.MultiCall', returns=Mock(
            ...         'multicall', returns=[], tracker=None))
            >>> c = BlogIt.WordPressCommentList(42)
            >>> mock('c.display', returns=[])
            >>> mock('c.changed_comments', returns=[])
            >>> c.getComments()   #doctest: +NORMALIZE_WHITESPACE
            Called xmlrpclib.MultiCall(<ServerProxy for example.com/RPC2>)
            Called c.display()
            Called c.changed_comments([])

            >>> minimock.restore()
            """
            multicall = xmlrpclib.MultiCall(self.client)
            for comment_typ in ('hold', 'spam', 'approve'):
                multicall.wp.getComments('', self.vim_vars.blog_username,
                        self.vim_vars.blog_password,
                        {'post_id': self.BLOG_POST_ID, 'status': comment_typ,
                         'offset': offset, 'number': 1000})
            self.empty_comment_list()
            for comments, heading in zip(multicall(),
                    ('In Moderadation', 'Spam', 'Published')):
                for comment_dict in comments:
                    self.add_comment(heading, comment_dict)
            if list(self.changed_comments(self.display())) != []:
                msg = 'Bug in BlogIt: Deactivating comment editing:\n'
                for d in self.changed_comments(self.display()):
                    msg += "  '%s'" % d['comment_id']
                    msg += str(list(self.changed_comments(self.display())))
                self.send = self._no_send
                raise BlogIt.BlogItBug(msg)


    def __init__(self):
        self._posts = {}
        self.prev_file = None
        self.NO_POST = BlogIt.NoPost()

    def _get_current_post(self):
        try:
            return self._posts[vim.current.buffer.number]
        except KeyError:
            return self.NO_POST

    def _set_current_post(self, post):
        """
        >>> vim.current.buffer.change_buffer(3)
        >>> blogit.current_post = Mock('post@buffer_3_', tracker=None)
        >>> vim.current.buffer.change_buffer(7)
        >>> blogit.current_post    #doctest: +ELLIPSIS
        <testing.blogit.NoPost object at 0x...>
        >>> blogit.current_post = Mock('post@buffer_7_', tracker=None)
        >>> vim.current.buffer.change_buffer(3)
        >>> blogit.current_post    #doctest: +ELLIPSIS
        <Mock 0x... post@buffer_3_>
        >>> vim.current.buffer.change_buffer(42)
        """
        self._posts[vim.current.buffer.number] = post
        post.vim_vars.export_blog_name()
        post.vim_vars.export_post_type(post)

    current_post = property(_get_current_post, _set_current_post)

    vimcommand_help = []

    def command(self, bang='', command='help', *args):
        """ Interface called by vim user-function ':Blogit'.

        >>> mock('xmlrpclib')
        >>> mock('sys.stderr')
        >>> blogit.command('', 'non-existant')
        Called sys.stderr.write('No such command: non-existant.')

        >>> def f(x): print 'got %s' % x
        >>> blogit.command_mocktest = f
        >>> blogit.command('', 'mo')
        Called sys.stderr.write('Command mo takes 0 arguments.')

        >>> blogit.command('', 'mo', 2)
        got 2

        >>> blogit.command_mockambiguous = f
        >>> blogit.command('', 'mo')    #doctest: +NORMALIZE_WHITESPACE
        Called sys.stderr.write('Ambiguious command mo:
                mockambiguous, mocktest.')

        >>> mock('blogit.list_edit')
        >>> blogit.command('!', 'list_edit')
        Called blogit.list_edit()

        >>> minimock.restore()
        """
        if bang == '!':
            # Workaround limit to access vim s:variables when
            # called via :python.
            getattr(self, command)()
            return

        def f(x):
            return x.startswith('command_' + command)

        matching_commands = filter(f, dir(self))

        if len(matching_commands) == 0:
            sys.stderr.write("No such command: %s." % command)
        elif len(matching_commands) == 1:
            try:
                getattr(self, matching_commands[0])(*args)
            except BlogIt.NoPostException:
                sys.stderr.write('No Post in current buffer.')
            except TypeError, e:
                try:
                    sys.stderr.write("Command %s takes %s arguments." % \
                            (command, int(str(e).split(' ')[3]) - 1))
                except:
                    sys.stderr.write('%s' % e)
            except Exception, e:
                sys.stderr.write(e.message)
        else:
            sys.stderr.write("Ambiguious command %s: %s." %
                             (command,
                              ', '.join([s.replace('command_', '', 1)
                                                for s in matching_commands])))

    def list_comments(self):
        if vim.current.line.startswith('Status: '):
            p = BlogIt.WordPressCommentList.create_from_post(self.current_post)
            vim.command('enew')
            self.current_post = p
            try:
                p.getComments()
            except BlogIt.BlogItBug, e:
                p.init_vim_buffer()
                vim.command('setlocal nomodifiable')
                sys.stderr.write(e.message)
            else:
                p.init_vim_buffer()

    def list_edit(self):
        row, col = vim.current.window.cursor
        post = self.current_post.open_row(row)
        post.getPost()
        vim.command('bdelete')
        vim.command('enew')
        post.init_vim_buffer()
        self.current_post = post

    @staticmethod
    def str_to_DateTime(text='', format='%c'):
        if text == '':
            return DateTime('')
        else:
            try:
                text = text.encode(getpreferredencoding())
            except UnicodeDecodeError:
                text = text.decode('utf-8').encode(getpreferredencoding())
            text = strptime(text, format)
        return DateTime(strftime('%Y%m%dT%H:%M:%S', text))

    @staticmethod
    def DateTime_to_str(date, format='%c'):
        try:
            return unicode(strftime(format,
                                    strptime(str(date), '%Y%m%dT%H:%M:%S')),
                           getpreferredencoding(), 'ignore')
        except ValueError:
            return ''

    def register_vimcommand(f, doc_string, register_to=vimcommand_help):
        r"""
        >>> class C:
        ...     def command_f(self):
        ...         ' A method. '
        ...         print "f should not be executed."
        ...     def command_g(self, one, two):
        ...         ' A method with arguments. '
        ...         print "g should not be executed."
        ...     def command_h(self, one, two=None):
        ...         ' A method with an optional arguments. '
        >>> L = []
        >>> vim_cmd = lambda f, L: BlogIt.register_vimcommand(f, f.__doc__, L)
        >>> vim_cmd(C.command_f, L)
        <unbound method C.command_f>
        >>> L
        [':Blogit f                  A method. \n']

        >>> vim_cmd(C.command_g, L)
        <unbound method C.command_g>
        >>> L     #doctest: +NORMALIZE_WHITESPACE
        [':Blogit f                  A method. \n',
         ':Blogit g {one} {two}      A method with arguments. \n']
        >>> vim_cmd(C.command_h, L)
        <unbound method C.command_h>
        >>> L     #doctest: +NORMALIZE_WHITESPACE
        [':Blogit f                  A method. \n',
         ':Blogit g {one} {two}      A method with arguments. \n',
         ':Blogit h {one} [two]      A method with an optional arguments. \n']

        """

        def getArguments(func, skip=0):
            """
            Get arguments of a function as a string.
            skip is the number of skipped arguments.
            """
            skip += 1
            args, varargs, varkw, defaults = getargspec(func)
            cut = len(args)
            if defaults:
                cut -= len(defaults)
            args = ["{%s}" % a for a in args[skip:cut]] + \
                   ["[%s]" % a for a in args[cut:]]
            if varargs:
                args.append("[*%s]" % varargs)
            if varkw:
                args.append("[**%s]" % varkw)
            return " ".join(args)

        command = '%s %s' % (f.func_name.replace('command_', ':Blogit '),
                             getArguments(f))
        register_to.append('%-25s %s\n' % (command, doc_string))
        return f

    def vimcommand(doc_string, f=register_vimcommand):
        return partial(f, doc_string=doc_string)

    def get_vim_vars(self, blog_name=None):
        if blog_name is not None:
            return BlogIt.VimVars(blog_name)
        else:
            return self.current_post.vim_vars

    @vimcommand(_("list all posts"))
    def command_ls(self, blog=None):
        vim_vars = self.get_vim_vars(blog)
        vim.command('botright new')
        try:
            self.current_post = BlogIt.PostListing.create_new_post(vim_vars)
        except BlogIt.PostListingEmptyException:
            vim.command('bdelete')
            sys.stderr.write("There are no posts.")

    @vimcommand(_("create a new post"))
    def command_new(self, blog=None):
        vim_vars = self.get_vim_vars(blog)
        vim.command('enew')
        self.current_post = BlogIt.WordPressBlogPost.create_new_post(vim_vars)

    @vimcommand(_("make this a blog post"))
    def command_this(self, blog=None):
        if self.current_post is self.NO_POST:
            vim_vars = self.get_vim_vars(blog)
            self.current_post = BlogIt.WordPressBlogPost.create_new_post(
                    vim_vars, vim.current.buffer[:])
        else:
            sys.stderr.write("Already editing a post.")

    @vimcommand(_("edit a post"))
    def command_edit(self, id, blog=None):
        vim_vars = self.get_vim_vars(blog)
        try:
            id = int(id)
        except ValueError:
            if id in ['this', 'new']:
                self.command(id, blog)
                return
            sys.stderr.write(
                    "'id' must be an integer value or 'this' or 'new'.")
            return

        post = BlogIt.WordPressBlogPost(id, vim_vars=vim_vars)
        try:
            post.getPost()
        except Fault, e:
            sys.stderr.write('Blogit Fault: ' + e.faultString)
        else:
            vim.command('enew')
            post.init_vim_buffer()
            self.current_post = post

    @vimcommand(_("edit a page"))
    def command_page(self, id, blog=None):
        # copied from command_edit
        vim_vars = self.get_vim_vars(blog)

        if id == 'new':
            vim.command('enew')
            post = BlogIt.WordPressPage.create_new_post(vim_vars)
        elif id == 'this':
            if self.current_post is not self.NO_POST:
                sys.stderr.write("Already editing a post.")
                return
            post = BlogIt.WordPressPage.create_new_post(vim_vars,
                                                        vim.buffer[:])
        else:
            try:
                id = int(id)
            except ValueError:
                sys.stderr.write("'id' must be an integer value or 'new'.")
                return
            post = BlogIt.WordPressPage(id, vim_vars=vim_vars)
            try:
                post.getPost()
            except Fault, e:
                sys.stderr.write('Blogit Fault: ' + e.faultString)
                return
            vim.command('enew')
            post.init_vim_buffer()
        self.current_post = post

    @vimcommand(_("save article"))
    def command_commit(self):
        p = self.current_post
        p.send(vim.current.buffer[:])
        p.refresh_vim_buffer()

    @vimcommand(_("publish article"))
    def command_push(self):
        p = self.current_post
        p.send(vim.current.buffer[:], push=1)
        p.refresh_vim_buffer()

    @vimcommand(_("unpublish article (save as draft)"))
    def command_unpush(self):
        p = self.current_post
        p.send(vim.current.buffer[:], push=0)
        p.refresh_vim_buffer()

    @vimcommand(_("remove a post"))
    def command_rm(self, id):
        p = self.current_post
        try:
            id = int(id)
        except ValueError:
            sys.stderr.write("'id' must be an integer value.")
            return

        if p.BLOG_POST_ID == id:
            self.current_post = self.NO_POST
            vim.command('bdelete')
        try:
            p.client.metaWeblog.deletePost('', id, p.vim_vars.blog_username,
                                              p.vim_vars.blog_password)
        except Fault, e:
            sys.stderr.write(e.faultString)
            return
        sys.stdout.write('Article removed')

    @vimcommand(_("update and list tags and categories"))
    def command_tags(self):
        p = self.current_post
        username, password = p.vim_vars.blog_username, p.vim_vars.blog_password
        multicall = xmlrpclib.MultiCall(p.client)
        multicall.wp.getCategories('', username, password)
        multicall.wp.getTags('', username, password)
        categories, tags = tuple(multicall())
        tags = [BlogIt.enc(tag['name']) for tag in tags]
        categories = [BlogIt.enc(cat['categoryName']) for cat in categories]
        vim.command('let s:used_tags = %s' % BlogIt.to_vim_list(tags))
        vim.command('let s:used_categories = %s' %
                            BlogIt.to_vim_list(categories))
        sys.stdout.write('\n \n \nCategories\n==========\n \n' +
                         ', '.join(categories))
        sys.stdout.write('\n \n \nTags\n====\n \n' + ', '.join(tags))

    @vimcommand(_("preview article in browser"))
    def command_preview(self):
        p = self.current_post
        if isinstance(p, BlogIt.CommentList):
            raise Blogit.NoPostException
        if self.prev_file is None:
            self.prev_file = tempfile.mkstemp('.html', 'blogit')[1]
        f = open(self.prev_file, 'w')
        f.write(p.read_post(vim.current.buffer[:])[p.POST_BODY])
        f.flush()
        f.close()
        webbrowser.open(self.prev_file)

    @vimcommand(_("display this notice"))
    def command_help(self):
        sys.stdout.write("Available commands:\n")
        for f in self.vimcommand_help:
            sys.stdout.write('   ' + f)

    # needed for testing. Prevents beeing used as a decorator if it isn't at
    # the end.
    register_vimcommand = staticmethod(register_vimcommand)


blogit = BlogIt()

if doctest is not None:
    doctest.testmod()
