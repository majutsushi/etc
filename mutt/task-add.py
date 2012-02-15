#!/usr/bin/python

import sys
import re
from email.parser import Parser
from subprocess import Popen, PIPE
import shlex
import time
import readline

taskbin = 'task rc._forcecolor=no rc.defaultwidth=0 '
ann = ''

def system(cmd):
    p = Popen(shlex.split(cmd), stdout=PIPE, stderr=PIPE)
    (stdout, stderr) = p.communicate()

    if p.returncode != 0:
        print 'Error executing "' + cmd + '"!'
        print stderr
        exit()

    return stdout.splitlines()


msg     = Parser().parse(sys.stdin)
body    = msg.get_payload().splitlines()
subject = msg['subject']


# if mail is an issue report from github, use the issue url as annotation
# instead of the message-id
ghurl = re.match(r'^(?P<url>https://github\.com/\w+/\w+/issues/\d+)(#.*)?$', body[-1])
if ghurl:
    ann = ghurl.group('url')
    # convert '[repo]' into 'project:repo'
    subject = re.sub(r'^\[(\w+)\] ', r'project:\1 ', subject)


# switch to terminal for stdin
sys.stdin = open('/dev/tty')

# pre-populate description prompt with mail subject
def pre_input_hook():
    sys.stdout.write('\033[m')
    readline.insert_text(subject)
    readline.redisplay()
readline.set_pre_input_hook(pre_input_hook)

# get task description
readline.parse_and_bind('set editing-mode emacs')
try:
    # display prompt in bold. use stdout.write instead of print so the prompt
    # won't start with a space, see
    # http://docs.python.org/reference/simple_stmts.html#the-print-statement
    sys.stdout.write('\033[1m')
    desc = raw_input('Task description: ')
except KeyboardInterrupt:
    print
    print 'Aborted'
    exit()

# create task
output = system(taskbin + ' add ' + desc)
tid = re.match(r'Created task (?P<id>\d+)\.', output[0]).group('id')

# add annotation(s)
if ann != '':
    system(taskbin + tid + ' annotate "' + ann + '"')
else:
    # sleep in between adding annotations because they are uniquely identified in
    # 'second' coarseness (ugh)
    system(taskbin + tid + ' annotate "Subject: ' + msg['subject'] + '"')
    time.sleep(1)
    system(taskbin + tid + ' annotate "From: ' + msg['from'] + '"')
    time.sleep(1)
    system(taskbin + tid + ' annotate "Message-ID: ' + msg['message-id'].strip('<>') + '"')
