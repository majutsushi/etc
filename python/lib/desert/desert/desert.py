# -*- coding: utf-8 -*-
"""
    Desert Colorscheme
"""
from pygments.style import Style
from pygments.token import Token, Comment, Name, Keyword, Generic, Number, Operator, String, Punctuation

class DesertStyle(Style):

    background_color = '#333333'

    styles = {
        Token:              '#ffffff bg:#333333',

        Comment:            '#87ceeb',
        Comment.Preproc:    '#cd5c5c',

        Keyword:            'bold #f0e68c',
        Keyword.Type:       'bold #bdb76b',
        Keyword.Namespace:  'nobold #cd5c5c',

        Punctuation:        '#98fb98',

        Operator:           'bold #f0e68c',

        # Name.Attribute:     '#98fb98',
        Name.Builtin:       'bold #f0e68c',
        Name.Constant:      '#ffa0a0',
        Name.Decorator:     '#cd5c5c',
        Name.Entity:        '#ffdead',
        Name.Function:      '#98fb98',
        Name.Tag:           'bold #f0e68c',
        Name.Variable:      '#98fb98',

        Number:             '#ffa0a0',

        String:             '#ffa0a0',

        Generic.Heading:    '#eeeeec bold',
        Generic.Subheading: '#ffd700',
        Generic.Deleted:    '#d75f5f',
        Generic.Inserted:   '#87ff87',
        Generic.Emph:       '#c000c0 underline',
        Generic.Output:     '#add8e6 bg:#4d4d4d bold',
        Generic.Traceback:  '#c0c0c0 bg:#c00000 bold',
        Generic.Error:      '#c0c0c0 bg:#c00000 bold',
    }
