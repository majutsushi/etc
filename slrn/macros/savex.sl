% -*- mode: slang; mode: fold; -*-
% Description:                                                          %{{{
% SAVE AS "SUBJECT" [slrn] - when saving a chosen article to a file the
% suggested filename is the subject of the post, not the newsgroup.
% USAGE:
% Put this in /usr/share/macros/macros.sl (or wherever you wish),
% and add the following to .slrnrc:
%         set macro_directory "/usr/share/macros"
%         interpret "macros.sl"
%         setkey article savex "b"
% and save articles by pressing "b".
%
% by tsca@cryogen.com, more @ http://www.geocities.com/tsca.geo/slang.html
% Thanks to Leon <d@z.pl> for comments.
%                                                                       %}}}

 define savex()
  {
    variable sted = getenv("HOME")+"/"+get_variable_value ("save_directory"),
             pliknavn = extract_article_header ("Subject"),
             mnavn = read_mini ("Save as (^G aborts)","",pliknavn);

    save_current_article (Sprintf ("%s/%s",sted,mnavn,2));
  }
