#!/usr/bin/env python

import keyring

def get_password():
    return keyring.get_password("majutsushi.net", "jan")
