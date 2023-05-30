###############################################################################
#
# Copyright (c) 2008 by GolemJ <golemj@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
###############################################################################
#
# Log highlights msg to core buffer
# You need to set "notify" to "yes" and "command" to proper command to run
# external command. You also need "shell" script to run external command.
#
# History:
#   2010-06-20, GolemJ <golemj@gmail.com>
#       version 0.8, add posibility to execute command for notification
#   2010-02-14, Emmanuel Bouthenot <kolter@openics.org>
#       version 0.7, add colors and notifications support
#   2009-05-02, FlashCode <flashcode@flashtux.org>:
#       version 0.6, sync with last API changes
#   2008-11-30, GolemJ <golemj@gmail.com>:
#       version 0.5, conversion to WeeChat 0.3.0+
#
###############################################################################

use strict;

weechat::register( "awaylog", "Jiri Golembiovsky", "0.8", "GPL", "Prints highlights to core buffer", "", "" );
weechat::hook_print( "", "", "", 1, "highlight_cb", "" );

if( weechat::config_get_plugin( "on_away_only" ) eq "" ) {
  weechat::config_set_plugin( "on_away_only", "off" );
}

if( weechat::config_get_plugin( "plugin_color" ) eq "" ) {
  weechat::config_set_plugin( "plugin_color", "default" );
}

if( weechat::config_get_plugin( "name_color" ) eq "" ) {
  weechat::config_set_plugin( "name_color", "default" );
}

if( weechat::config_get_plugin( "notify" ) eq "" ) {
  weechat::config_set_plugin( "notify", "off" );
}

if( weechat::config_get_plugin( "command" ) eq "") {
  weechat::config_set_plugin( "command", "" );
}

sub highlight_cb {
  if( $_[5] == 1 ) {
    my $away = weechat::buffer_get_string($_[1], "localvar_away");
    if (($away ne "") || (weechat::config_get_plugin( "on_away_only" ) ne "on"))
    {
        my $buffer_color =  weechat::color(weechat::config_get_plugin( "plugin_color"))
                    . weechat::buffer_get_string($_[1], "plugin")
                    . "."
                    . weechat::buffer_get_string($_[1], "name")
                    . weechat::color("default");
        my $buffer = weechat::buffer_get_string($_[1], "plugin")
                    . "."
                    . weechat::buffer_get_string($_[1], "name");
        my $name_color =  weechat::color(weechat::config_get_plugin( "name_color"))
                    . $_[6]
                    . weechat::color("default");
        my $name   = $_[6];
        my $message_color = "${buffer_color} -- ${name_color} :: $_[7]";
        my $message = "${buffer} -- ${name} :: $_[7]";
        if( weechat::config_get_plugin( "notify" ) ne "on" ) {
          my $command = weechat::config_get_plugin( "command" );
          if( $command ne "" ) {
            if( $command =~ /\$msg/ ) {
              $command =~ s/\$msg/\'$message\'/;
            } else {
              $command = "$command '$message'";
            }
            weechat::command( "", "/shell $command" );
          } else {
            weechat::print("", $message_color);
          }
        } else {
            weechat::print_date_tags("", 0, "notify_highlight", $message_color);
        }
    }
  }

  return weechat::WEECHAT_RC_OK;
}
