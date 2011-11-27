% Notify the user about postponed articles.  % -*- mode: slang; mode: fold -*-
%
% Copyright © 1998-2001 J.B. Nicholson-Owens
% Author: J.B. Nicholson-Owens <jbn@forestfield.org>
% Title: Notify postponed posts
% Version: 1.03
% License: GNU GPL
% Last tested with: slrn 0.9.7.3 & S-Lang 1.4.4
%
%{{{
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  You may
% also download a copy of the applicable license from
% <URL:http://forestfield.org/gpl.txt>.
%}}}

#iffalse % Documentation                                                %{{{

% This macro set notifies you the first time you enter group mode if
% there are files in your postpone_directory.  You can customize the
% notification by setting a message or executing a function.
% 
% This macro essentially provides a huge wrapper to the simplest
% functionality.  If you are comfortable writing S-Lang macros you
% probably should do that directly rather than using this macro.  This
% macro set is really not as big a deal as its filesize might suggest.
% 
% To install:
% 
% (1) Save a copy of this file (or this article if you're getting this from
%     Usenet) as "notify_postponed.sl".  Place this file somewhere so slrn
%     can find it.  Your home directory will do if you don't have a better
%     place for it.
% 
% (2) Append the following lines to your slrn.rc ($HOME/.slrnrc on Unix) to
%     make slrn load this file and set up some keys to access the functions:
% 
%        interpret "notify_postponed.sl"
% 
% (3) Quit slrn and restart slrn.
% 
% To uninstall:
% 
% (1) Edit your slrnrc to comment out or remove the interpret line:
% 
%        % interpret "notify_postponed.sl"
% 
% (2) Quit and restart slrn.  You will no longer be notified about
%     postponed posts by this macro set.  You may delete
%     notify_postponed.sl from your system at your option.
% 
% Preferences (options):
% 
% Notify_Postponed->set_preference ("custom", x Ref_Type);
% Notify_Postponed->set_preference ("custom", x String_Type);
% 
%   If you want something besides a simple message to be done when this
%   macro set detects postponed articles, create a function and set this
%   macro set's 'custom' preference to a pointer to that function.  Or
%   specify a string to be displayed (if all you want is a different
%   message).
%
%   See below about the two percent escapes for the string custom message. 
%
% Notify_Postponed->now();
% Notify_Postponed->now([custom Ref_Type]);
% Notify_Postponed->now([custom String_Type]);
% 
%   Specifying the custom function or a custom message when running
%   Notify_Postponed->now() is another way to do the same thing as the
%   above preference.
%   
%   This has higher precedence than the 'custom' preference, so if both are
%   set (if you supply an argument and specify a custom preference)
%   the argument given to this function will be acted on and the
%   preference will be ignored.  This is handy for one-time checks where
%   you want something unique to happen.
%   
%   Notify_Postponed->now() will use the postponed_directory slrn preference
%   relative to your homedir unless you specify a fully-qualified path (a
%   path starting with the root dir) or a relative path (a path starting with
%   "." or "..").
%
% When you use the custom preference to set a string message you can also use
% "%d" to stand for the number of postponed articles and "%%" to stand for the
% percent sign.  For example either of the following:
% 
%   Notify_Postponed->set_preference ("custom", "You have %d postponed articles.");
%   Notify_Postponed->now ("You have %d postponed articles.");
% 
% will give you the message 'You have 47 postponed articles.' if you have 47
% postponed articles.
%
% Version history:
% 1.0:   Released.
% 1.01:  Cleaned up some diagnostic code.
%        Added a minor bit of documentation about Notify_Postponed->now().
%        Fixed small typo in Notify_Postponed->set_preference().
% 1.02:  Added %d and %% escapes to the custom message. (TS)
%        Moved the notification from startup_hook to group_mode_startup_hook(). (TS)
%        Thanks to Thomas Schultz <tststs@gmx.de> for these suggestions!
%        Changed default message to be plural on 2 or more items in postpone_directory.
% 1.03:  Changed now() to make the postpone_dir relative to $HOME if not a full path
%        or relative path.  Thanks to Thomas Schultz <tststs@gmx.de> for the patch!

#endif %}}}

implements ("Notify_Postponed");

private variable
  prefs = Assoc_Type[],
  preference_check = Assoc_Type[Ref_Type];

prefs["custom"] = NULL;
private define check_custom (v)                                         %{{{
{
   variable t = typeof (v);
   return (andelse { t != String_Type } { t != Ref_Type });
}
preference_check["custom"] = &check_custom;

%}}}

static define set_preference (preference, value)                        %{{{
{
   preference = string (preference);
   !if (assoc_key_exists (prefs, preference))
     error ("Preference does not exist: " + preference);

   variable desired_type = typeof (prefs[preference]);
   if (andelse
         { desired_type != Null_Type }
         { typeof (value) != desired_type })
     {
        verror ("Wrong type for %s: This preference wants %S not %S",
                preference, desired_type, typeof (value));
     }
   if (andelse
        { assoc_key_exists (preference_check, preference) }
        { @preference_check[preference] (value) })
     {
        vmessage ("Warning: Invalid setting for %s -- using %S instead",
                  preference, prefs[preference]);
        return ();
     }

   prefs[preference] = value;
}
%}}}
static define now ()                                                    %{{{
{
   variable pd = make_home_filename (get_variable_value ("postpone_directory"));

   if (pd == "") { return (); }

   variable st = stat_file (pd);

   if (st == NULL)
     {
        verror ("Notify_Postponed: Warning: Could not find %S\nNotify_Postponed: %S", pd, errno_string (errno ()));
     }

   variable num_postponed_articles = length (listdir (pd));

   if (andelse
         { stat_is ("dir", st.st_mode) }         % it's a directory.
         { num_postponed_articles })             % there's somethin' in there.
     {
        variable m = prefs["custom"];
        if (_NARGS) m = ();

        switch (typeof (m))
          { case (String_Type) :
             variable count = 0, len = strlen (m);

             if (string_match (m, "[^%]%$", 1))
               {
                  m += "%";                                % "%" -> "%%" at end of str.
                  len++;
               }
             (m, ) = strreplace (m, "%D", "%d", len);      % replace "%D" with "%d".
             (, count) = strreplace (m, "%d", "%d", len);  % count the "%d"'s.
             loop (count) num_postponed_articles;          % push the %d expansions.
             m;                                            % push the message.
             vmessage ();                                  % output the custom msg.
          }
          { case (Ref_Type)    : @prefs["custom"]; }
          { 
             m = "You have %d postponed article";
             if (num_postponed_articles == 1) m += ".";
             else m += "s.";
             vmessage (m, num_postponed_articles);
          }
     }
}
!if (register_hook ("group_mode_startup_hook", "Notify_Postponed->now"))
  message ("Notify Postponed: Warning: Could not register for group_mode_startup_hook!");

%}}}
static define version () { return (1.03); }
