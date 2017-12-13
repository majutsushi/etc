require "editheader";
require "fileinto";
require "imap4flags";
require "mailbox";
require "mboxmetadata";
require "regex";
require "variables";
require "vnd.dovecot.execute";

if header :contains "X-Spam-Flag" "YES" {
    fileinto :flags "\\Seen" "Spam";
    stop;
}

if address :is :all "from" "notifications@github.com" {
    if header :regex "list-id" "<([^.]+)\.(majutsushi)\.github\.com>" {
        fileinto :create "GitHub.${2}.${1}";
    } else {
        fileinto :create "GitHub.other";
    }
    stop;
}

# File Debian bug mail into a common folder
if header :matches "list-post" "<*@bugs.debian.org>" {
    fileinto :create "lists.owner@bugs_debian_org";
    stop;
}

if allof (not address :is :domain "from" "github.com",
          anyof (allof (not header :matches "list-post" "*github.com*",
                        header :regex "list-post" ".*<mailto:([^>]+).*"),
                 header :regex "x-mailing-list" ".*<([^>]+).*",
                 header :regex "x-beenthere" "(.*)",
                 header :regex "x-loop" "(.*)",
                 header :regex "mailing-list" "list +([^ ;]+).*")) {
    set :lower "listname" "${1}";

    # Occasionally used by spam that gets through
    deleteheader "x-priority";
    deleteheader "x-msmail-priority";

    execute :input "${listname}" :output "listname" "tr" [".", "_"];

    if header :matches "references" "?*" {
        set "references" "${1}${2}";
        if metadata :matches "INBOX" "/private/killedthreads" "?*" {
            set "killedthreads" "${1}${2}";
            execute :input "${killedthreads}" :output "killed" "checkkilled" ["${references}"];
            if string :is "${killed}" "killed" {
                setflag "killedflag" "\\Seen";
            }
        }
    }

    fileinto :create :flags "${killedflag}" "lists.${listname}";
    stop;
}

keep;
