% Filename: view_manuals.sl
% Version: 0.9.3
% Author: Troy Piggins

% 0.9.3 - added user defineable pager
% 0.9.2 - added slang help files
% 0.9.1 - initial release

define view_manuals() {

% set the path to your favourite pager here
variable pager="/usr/bin/less";
% variable pager="/usr/local/share/vim/vim70/macros/less.sh";
% variable pager="/usr/local/bin/most";

% be sure to check the path to your slrn docs with trailing "/"
% default is /usr/local/share/doc/slrn/

  variable docpath="/usr/share/doc/slrn/";

  variable man=select_list_box( "slrn docs", "man page", 
    "slrn manual", "score help", "slrnfuns help", 
    "slang help", "slangfuns help", 6, 1);

  switch (man)
    { case "man page" : system( "man slrn");}
    { case "slrn manual" : system( pager+" "+docpath+"manual.txt.gz");}
    { case "score help" : system( pager+" "+docpath+"score.txt.gz");}
    { case "slrnfuns help" : system( pager+" "+docpath+"slrnfuns.txt.gz");}
    { case "slang help" : system( pager+" /usr/share/doc/libslang2/slang.txt.gz");}
    { case "slangfuns help" : system( pager+" /usr/share/doc/libslang2/slangfun.txt");}
    { message ("Error in doc selection");}

}

definekey ( "view_manuals", "<f1>", "article");
definekey ( "view_manuals", "<f1>", "group");
