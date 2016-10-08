require "fileinto";
require "imap4flags";
require "mailbox";
# require "mboxmetadata";
require "regex";
require "variables";
require "vnd.dovecot.execute";

if header :contains "X-Spam-Level" "**********" {
    discard;
    stop;
} elsif header :contains "X-Spam-Flag" "YES" {
    fileinto :flags "\\Seen" "Spam";
    stop;
}

if allof (not address :is :domain "from" "github.com",
          # anyof (header :regex "list-post" ".*<mailto:([^@]+).*",
          #        header :regex "x-mailing-list" ".*<([^@]+).*",
          #        header :regex "x-beenthere" "([^@]+).*",
          #        header :regex "x-loop" "([^@]+).*")) {
          anyof (allof (not header :matches "list-post" "*@reply.github.com*",
                        header :regex "list-post" ".*<mailto:([^>]+).*"),
                 header :regex "x-mailing-list" ".*<([^>]+).*",
                 header :regex "x-beenthere" "(.*)",
                 header :regex "x-loop" "(.*)",
                 header :regex "mailing-list" "list +([^ ;]+).*")) {
    set :lower "listname" "${1}";

    execute :input "${listname}" :output "listname" "tr" [".", "_"];

    if header :matches "references" "?*" {
        set "references" "${1}${2}";
        # if metadata :matches "INBOX" "/private/killedthreads" "?*" {
        #     set "killedthreads" "${1}${2}";
        #     execute :input "${killedthreads}" :output "killed" "checkkilled" ["${references}"];
        #     if string :is "${killed}" "killed" {
        #         setflag "killedflag" "\\Seen";
        #     }
        # }
        execute :output "killed" "checkkilled" ["${references}", "/home/jan/Maildir/dovecot-attributes"];
        if string :is "${killed}" "killed" {
            setflag "killedflag" "\\Seen";
        }
    }

    fileinto :create :flags "${killedflag}" "lists.${listname}";
    stop;
}

keep;
