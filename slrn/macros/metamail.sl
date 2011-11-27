% Filename: ~/.slrn/metamail.sl
% Purpose: pipe article from slrn to metamail
% Availability: <URL:http://www.michael-prokop.at/computer/config/.slrn/metamail.sl>
% Author: Michael Prokop - <http://www.michael-prokop.at/> - <online@michael-prokop.at>
% -> Idea from Thomas Schultz (tststs@gmx.de) in:
% http://groups.google.com/groups?hl=de&lr=&ie=UTF-8&selm=slrn7infgc.2ql.tststs%40starflower.tststs.ddns.org
% Latest change: Son Mär 16 18:47:12 CET 2003
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Don't forget to define the following in your "$HOME/.slrnrc":
%
% setkey article pipe_to_metamail "m"
% set metamail_command "metamail"
%
% in your $HOME/.slrnrc !!!
% 
% Maybe (only if slrn can not handle MIME-Stuff!) you also want to define:
% set use_metamail 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

define pipe_to_metamail ()
{
   variable metamail;
   metamail = get_variable_value ("metamail_command");
   pipe_article (metamail);
}
