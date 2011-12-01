% Filename: view_my_posts.sl
% Version: 0.9.1
% Author: Troy Piggins

% assumes you are have mutt mail reader
% check the paths to "save_posts" and "save_replies" are correct

define view_my_posts() {

% path to your posts, ie the value of "save_posts" in your .slrnrc
  variable postpath= "$HOME/News/sent";

  () = system ("mutt -f "+postpath);

}

definekey ("view_my_posts", "^S", "article");
definekey ("view_my_posts", "^S", "group");

%define view_my_mails() {

%% path to your mails, ie the value of "save_replies" in your .slrnrc
%  variable mailpath= "$HOME/news/My_Replies";

%  () = system ("mutt -f "+mailpath);

%} 

%definekey ("view_my_mails", "^R", "article");
%definekey ("view_my_mails", "^R", "group");
