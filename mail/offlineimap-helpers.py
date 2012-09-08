#!/usr/bin/env python

import gnomekeyring as gkey

def get_username(server):
    pwdata = gkey.find_network_password_sync(server = server, protocol = 'imap')[0]
    return pwdata['user']

def get_password(server):
    pwdata = gkey.find_network_password_sync(server = server, protocol = 'imap')[0]
    return pwdata['password']
