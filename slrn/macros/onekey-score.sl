% -*- mode: slang; mode: fold -*-

% onekey-score.sl - create scorefile entries by pressing one single key

% Copyright (C) 1999-2002 Thomas Schultz <tststs@gmx.de>
% set_preference() mechanism borrowed from J.B. Nicholson-Owens
% 
% This file may be redistributed and / or modified under the terms of the
% GNU General Public License, version 2, as published by the Free Software
% Foundation.

#iffalse % Documentation %{{{
Description:

This file contains macros that allow you to create scorefile entries based
on the current article via a single function call / keystroke. Two
interfaces are available - the first is very simple and can be used to
watch or ignore subthreads. The second is more complex, but also more
versatile: It can put a score on subjects, "From:" lines or references.

If you regularly use these functions, your scorefile will become quite
large, so I recommend the perl-script cleanscore that can automatically
remove expired entries.

Installation:

To use the simple interface, bind the functions watch_subthread() and/or
ignore_subthread() to whatever keys you prefer. The corresponding lines in
your slrnrc file should look like this:

  setkey article OneKeyScore->ignore_subthread "^K"
  setkey article OneKeyScore->watch_subthread "^W"

If you do not only want to watch or ignore a subthread, you can use the
more complex interface by calling create_score() directly (the two simpler
functions are really wrappers around it). An example would be:

  setkey article "OneKeyScore->create_score('f', -100, 't', 30, 1);" "^X"

Please note that it is important to quote the second argument of setkey in
this case. You can pass the following options to create_score():

  1. score type - can be 's' for "Subject", 'f' for "From" or 'r' for
     "References"
  2. score value - the score for the entry
  3. scope - 't' if the entry should apply to the current ("This") group,
     'a' if it should have an effect in all groups.
  4. date of expiry - can either be a date string (in format MM/DD/YYYY or
     DD-MM-YYYY) or an integer. If it is an integer, it will be
     interpreted as how long from now (in days) the entry should remain
     valid; if it is zero (or negative), the entry will never expire.
  5. apply immediately - if non-zero, the scorefile is reloaded, so the
     new entry is applied immediately.

Thus, the example above would put a score of -100 on the author of the
current article for 30 days from now, but only in the current group; the
new entry would be applied immediately.

Preferences:

You can use the set_preference() function to customize the behaviour of
the simple interface. To do this, put calls to this function in a file and
load it after this file is loaded. The following examples show the default
values:

OneKeyScore->set_preference("ignore_value", -1000);
OneKeyScore->set_preference("watch_value", 250);

  The score ignore_subthread() and watch_subthread() will assign to the
  current subthread when they are called.

OneKeyScore->set_preference("ignore_expiry", 14);
OneKeyScore->set_preference("watch_expiry", 21);

  How long (in days from date of creation) the new scorefile entries will
  be active.

OneKeyScore->set_preference("ignore_immediately", 0);
OneKeyScore->set_preference("watch_immediately", 0);

  If set to a non-zero value, the scorefile will be applied immediately
  when a new entry was created.

OneKeyScore->set_preference("affect_article_at_cursor", 0);

  By default, these macros affect the currently visible article. If you set
  this variable to 1, the scorefile entries will instead be based on the
  header the cursor points at.
  Note: This was the default before slrn 0.9.7.0
#endif %}}}

implements ("OneKeyScore");

private variable
  Prefs = Assoc_Type [];

% Set preferences %{{{
Prefs["ignore_value"] = -1000;
Prefs["watch_value"] = 250;
Prefs["ignore_expiry"] = 14;
Prefs["watch_expiry"] = 21;
Prefs["ignore_immediately"] = 0;
Prefs["watch_immediately"] = 0;
Prefs["affect_article_at_cursor"] = 0;
%}}}

static define set_preference (preference, value) %{{{
{
   !if (assoc_key_exists (Prefs, preference))
     error ("Preference does not exist: " + string (preference));
   variable desired_type = typeof (Prefs[preference]);
   if (typeof (value) != desired_type)
     verror ("Wrong type for %s: This preference wants %s not %s",
             string (preference),
             string (desired_type),
             string (typeof (value)));
   Prefs[preference] = value;
} %}}}

static define create_score (type, score, scope, expiry, apply) %{{{
{
   if (is_group_mode ())
     error (_function_name () + " doesn\'t work in group mode!");

   % Some basic sanity checks...
   if (typeof(type) == UChar_Type)
     type = sprintf("%c", type);
   if (typeof(scope) == UChar_Type)
     scope = sprintf("%c", scope);
   type = typecast(type, String_Type);
   !if (is_substr("sfr",strlow(type)))
     error ("Unknown score type: " + type);
   !if (is_substr("ta",scope))
     error ("Unknown score scope: " + scope);
   
   if (apply)
     apply = "y";
   else
     apply = "n";
   
   if (typeof(expiry) == Integer_Type) 
     {
	if (expiry > 0) 
	  {
	     variable expiry_date = localtime(_time() + expiry * 24 * 3600);
	     expiry = string(expiry_date.tm_mon+1)+"/"+
	              string(expiry_date.tm_mday)+"/"+
	              string(expiry_date.tm_year+1900);
	  }
	else
	  expiry = "";
     }
   
   if (andelse { Prefs["affect_article_at_cursor"] != 0 }
	 { is_article_visible () == 1 })
     call ("hide_article");
   set_input_string (string(score) + "\n" + expiry);
   set_input_chars (type + scope + apply);
   call ("create_score");
   
   message_now("");
}%}}}

static define ignore_subthread () %{{{
{
   create_score("r", Prefs["ignore_value"], "t", Prefs["ignore_expiry"],
		Prefs["ignore_immediately"]);
   message ("Ignoring subthread ...");
}%}}}

static define watch_subthread () %{{{
{
   create_score("r", Prefs["watch_value"], "t", Prefs["watch_expiry"],
		Prefs["watch_immediately"]);
   message ("Watching subthread ...");
}%}}}
