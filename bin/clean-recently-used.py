#!/usr/bin/python
#
# Copyright (C) 2008  German Poo-Caaman~o <gpoo@ubiobio.cl>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

import gtk
import sys
import time
import operator
import optparse

import pygtk
pygtk.require('2.0')

def load_recents_by_application(manager, n=10):
    '''Load all files in the Recent Manager with the last
       time visited.

    result is a list with all files in stored in the manager. 
            This list contains the URI and the last time visited.
    recent_files is a list to store all those files to NOT be 
                 removed.
    Rationale: We want to remove all those files that are not
               in the very recent access (let's say X).
               But a file could be in the position X+1 in one 
               application (candidate to be deleted), but in 
               another application could be the last file 
               opened (1st position).
    '''
    result = {}
    recent_files = []
    for item in manager.get_items():
        for app in item.get_applications():
            if result.has_key(app):
                result[app] += [(item.get_uri(), item.get_visited())]
            else:
                result[app] = [(item.get_uri(), item.get_visited())]

    for (app, data) in result.iteritems():
        # Get the last files opened by the application
        recent_files += [x for x,y in
                         sorted(data, key=operator.itemgetter(1))[-n:]]

    return (result, recent_files)

def remove_unused(manager):
    ''' Remove those file that does not exist in the system '''
    for i in manager.get_items():
        uri = i.get_uri()
        if not i.exists():
            manager.remove_item(uri)

def remove_not_so_recent(manager, all_files, recent_files):
    ''' Proceed to delete the very recent files.
        We avoid trying to delete a item twice, because the
        second time it will not exists in the manager.
    '''
    deleted = {}
    for (app, data) in all_files.iteritems():
        for uri, visited in data:
            if uri not in recent_files and not deleted.has_key(uri):
                manager.remove_item(uri)
                deleted[uri] = 0

def show_summary(all_files, n=10):
    ''' Show the last 'n' recent items and a summary of how
        many 'recent files' has every application using the
        Recent Manager.
    '''
    recent_files = []

    if n > 0:
        for (app, data) in all_files.iteritems():
            print "%s" % (app)

            # Get the last 'n' files opened by the application
            for (name, epoch) in sorted(data, key=operator.itemgetter(1),
                                        reverse=True)[:n]:
                last_visited = time.strftime("%Y-%m-%d %H:%S",
                                             time.gmtime(epoch))
                print '    %s, %s' % (last_visited, name)

    summary = {}
    # Determine how many 'recent files' has every application
    for app in all_files.iterkeys():
        summary[app] = len(all_files[app])

    print '\nSummary:'
    for k, v  in sorted(summary.items(), key=operator.itemgetter(1)):
        print "%6d %s" % (v, k)


if __name__ == '__main__':
    option_parser = optparse.OptionParser(
            usage='usage: %prog [options]')
    option_parser.add_option('-n', '--last',
            dest='n', type='int', default=10,
            help='Define how many last "recent files" to keep.')
    option_parser.add_option('-v', '--verbose',
            action='count', dest='verbose',
            help='Show a summary of use of Recent Manager.')
    option_parser.add_option('-u', '--remove-unused',
            action='store_true', dest='remove_unused', default=False,
            help='Remove the files that does not exists in the system.')
    option_parser.add_option('-r', '--remove-no-recents',
            action='store_true', dest='remove_no_recents', default=False,
            help='Remove those files that are not between the -n recents.')

    (options, args) = option_parser.parse_args(sys.argv)

    manager = gtk.recent_manager_get_default()
    (all_files, recent_files) = load_recents_by_application(manager)

    if options.verbose == 1:
        show_summary(all_files, 0)
    elif options.verbose > 1:
        show_summary(all_files, options.n)

    if options.remove_unused:
        remove_unused(manager)

    if options.remove_no_recents:
        remove_not_so_recent(manager, all_files, recent_files)
