#!/usr/bin/python

import sys
import re
from email.parser import Parser
from subprocess import Popen, PIPE
import shlex
import time

taskbin = 'task rc._forcecolor=no rc.defaultwidth=0 '

def system(cmd):
    p = Popen(shlex.split(cmd), stdout=PIPE, stderr=PIPE)
    (stdout, stderr) = p.communicate()

    if p.returncode != 0:
        print 'Error executing "' + cmd + '"!'
        print stderr
        exit()

    return stdout.splitlines()

headers = Parser().parse(sys.stdin)

# switch to terminal for stdin
sys.stdin = open('/dev/tty')
desc = raw_input('Enter task description: ')

output = system(taskbin + ' add ' + desc)
tid = re.match(r'Created task (?P<id>\d+)\.', output[0]).group('id')

# sleep in between adding annotations because they are uniquely identified in
# 'second' coarseness (ugh)
system(taskbin + tid + ' annotate "Subject: ' + headers['subject'] + '"')
time.sleep(1)
system(taskbin + tid + ' annotate "From: ' + headers['from'] + '"')
time.sleep(1)
system(taskbin + tid + ' annotate "Message-ID: ' + headers['message-id'].strip('<>') + '"')
