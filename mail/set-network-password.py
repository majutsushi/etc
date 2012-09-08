#!/usr/bin/python

import sys
import os
import getpass
import gnomekeyring as gkey

keyring = gkey.get_default_keyring_sync()

def has_item(user, server, protocol):
    try:
        gkey.find_network_password_sync(user = user, server = server, protocol = protocol)
    except gkey.NoMatchError:
        return False

    return True

def del_item(user, server, protocol):
    results = gkey.find_network_password_sync(user = username,
                                              server = server,
                                              protocol = protocol)

    gkey.item_delete_sync(keyring, results[0]['item_id'])

def add_item(user, password,  server, protocol):
    description = '%s password for %s at %s' % (protocol, user, server)
    type = gkey.ITEM_NETWORK_PASSWORD
    usr_attrs = {'user'     : user,
                 'server'   : server,
                 'protocol' : protocol}

    id = gkey.item_create_sync(keyring, type, description, usr_attrs, password, False)
    return id is not None

protocols_default = 'smtp,imap'

server = raw_input('Server: ')
protocols = raw_input('Protocols [' + protocols_default + ']: ')
if len(protocols) == 0:
    protocols = protocols_default
username = raw_input('Username: ')

while True:
    password = getpass.getpass(prompt = 'Password: ')
    p2 = getpass.getpass(prompt = 'Verify Password: ')
    if p2 != password:
        print "Passwords don't match."
    else:
        break

for protocol in protocols.split(','):
    if has_item(username, server, protocol):
        del_item(username, server, protocol)
    add_item(username, password, server, protocol)
