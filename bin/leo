#!/usr/bin/env python
# Author: Jan Larres <jan@majutsushi.net>
# License: MIT/X11

import urllib
import urllib2
import sys
import re
from BeautifulSoup import BeautifulSoup

sgr0 = ''
bold = ''
rev = ''
sitm = ''
ritm = ''
smul = ''
rmul = ''

if sys.stdout.isatty():
    try:
        import curses
        curses.setupterm()
        sgr0 = curses.tigetstr('sgr0')
        bold = curses.tigetstr('bold')
        rev  = curses.tigetstr('rev')
        sitm = curses.tigetstr('sitm')
        ritm = curses.tigetstr('ritm')
        smul = curses.tigetstr('smul')
        rmul = curses.tigetstr('rmul')
    except:
        sgr0 = '\033[0m'
        bold = '\033[1m'
        rev  = '\033[7m'
        sitm = '\033[3m'
        ritm = '\033[23m'
        smul = '\033[4m'
        rmul = '\033[24m'

if len(sys.argv) == 1:
    print 'Usage: leo <words>'
    exit()

words = ' '.join(sys.argv[1:])

def process(s):
    s = re.sub(r'<b>',       bold, s)
    s = re.sub(r'</b>',      sgr0, s)
    s = re.sub(r'<i>',       sitm, s)
    s = re.sub(r'</i>',      ritm, s)
    s = re.sub(r'<small>',   '',   s)
    s = re.sub(r'</small>',  '',   s)
    s = re.sub(r'<sup>',     '<',  s)
    s = re.sub(r'</sup>',    '>',  s)
    s = re.sub(r'<a[^>]*?>', '',   s)
    s = re.sub(r'</a>',      '',   s)
    # s = re.sub(r'<[^>]+?>', '', s)
    s = re.sub(r'&#160;', '', s)
    s = re.sub(r'&nbsp;', '', s)
    s = re.sub(r'\*\)$', '', s)
    return s

print 'Searching for "' + words + '" ...'

params = {'lp'         : 'ende',
          'lang'       : 'en',
          'searchLoc'  : '0',
          'cmpType'    : 'relaxed',
          'relink'     : 'off',
          'sectHdr'    : 'on',
          'spellToler' : 'std',
          'search'     : words}

url = 'http://pda.leo.org/' + '?' + urllib.urlencode(params)

user_agent = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:15.0) Gecko/20100101 Firefox/15.0.1'
headers = {'User-Agent' : user_agent}

request = urllib2.Request(url, headers=headers)
response = urllib2.urlopen(request)
content = response.read()

soup = BeautifulSoup(content, fromEncoding='utf-8')
results = soup.findAll('table', attrs={'class' : 'result'})

if len(results) == 0:
    print("No results found.")
    exit()

restable = results[0]

rows = restable.findAll('tr')
for row in rows:
    if len(row.findAll('th')) == 2:
        # header
        continue
    elif row.find('th') != None:
        # subheader
        contents = row.find('th').renderContents()
        if contents.find('No base forms found') != -1:
            continue
        print '\n' + rev + re.sub(r' +$', '', contents) + sgr0
    elif row.find('ul') != None:
        # base forms
        forms = row.findAll('li')
        for form in forms:
            print process(form.renderContents())
    elif len(row.findAll('td')) == 1:
        # section header
        info = row.find('td')
        info = process(info.getText())
        if re.match(r'^more ', info):
            continue
        print smul + info + rmul
    else:
        # entry
        words = row.findAll('td')
        wordl = process(words[0].renderContents(encoding=None))

        esclen = 0
        for escseq in [bold, sgr0, sitm, ritm]:
            l = re.findall(re.escape(escseq), wordl)
            esclen += len(l) * len(escseq)

        wordr = process(words[1].renderContents(encoding=None))

        print u'{0: <{width}}{1}'.format(wordl, wordr, width=40 + esclen)
