#!/usr/bin/env python
from minimock import Mock, AbstractTracker
import minimock, doctest

class Mock_Buffer(list):
    number = 3

    def __init__(self, *args, **kw):
        super(Mock_Buffer, self).__init__(*args, **kw)
        self._buffers = {}
        if self[:] == []:
            self[:] = ['']
        self._buffers[self.number] = self

    def change_buffer(self, number):
        """
        >>> b = Mock_Buffer()
        >>> b.number
        3
        >>> b.change_buffer(7)
        >>> b.number
        7
        """
        self._buffers[self.number] = self[:]
        try:
            self[:] = self._buffers[number]
        except KeyError:
            self[:] = ['']
        self._buffers[number] = self
        self.number = number

class FailTracker(AbstractTracker):
    """ A Mock Tracker that fails on every call. """
    def __init__(self, *args, **kw):
        pass

class MockVim(object):
    """ Creates a mock for the vim module.

    Use mock_vim() to create objects from MockVim.

    vim.eval calls to blogit_(username|password|url|name) are so frequent
    that we don't want to pollute doctest output with it.

    Holds the variables set as well as the buffers. mocked_eval is a hook
    for other calls to eval.
    """
    DUMMY_VIM_VARS = { 'blog_name': 'blogit',
                       'blogit_username': 'user',
                       'blogit_password': 'password',
                       'blogit_url': 'http://example.com',
                     }

    def __init__(self, vim, vim_vars=None):
        self.mocked_vim = vim
        if vim_vars is None:
            vim_vars = self.DUMMY_VIM_VARS
        self.vim_vars = vim_vars
        self.update_eval_commands()
        vim.eval = self.vim_eval

    def vim_eval(self, command):
        try:
            return self.eval_command_dict[command]
        except KeyError:
            return self.mocked_vim.mocked_eval(command)

    def update_eval_commands(self):
        self.eval_command_dict = self.vim_vars.copy()
        for var_name in self.vim_vars.keys():
            self.eval_command_dict["exists('%s')" % var_name] = '1'
            self.eval_command_dict["exists('b:%s')" % var_name] = '0'

def mock_vim(vim=None, vim_vars=None, vim_buffer=None, **kw):
    """ Factory for MockVim. """
    if vim is None:
        vim = Mock('vim', **kw)
    if vim_buffer is None:
        vim_buffer = Mock_Buffer()
    vim.current.buffer = vim_buffer
    vim.vim_imitation = MockVim(vim, vim_vars)
    return vim

vim = mock_vim(tracker=FailTracker())

if __name__ == '__main__':
    doctest.testmod()
