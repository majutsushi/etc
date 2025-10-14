#!/usr/bin/env python3

import platform

if platform.system() == "Darwin":
    print("listen_on unix:${TMPDIR}/kitty")
else:
    print("listen_on unix:@kitty")
