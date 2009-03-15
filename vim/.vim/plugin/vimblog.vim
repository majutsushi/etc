" Requirements:
"   - you'll need VIM compiled with Ruby scripting support
"     - example: for Debian/Ubuntu: sudo apt-get install vim-ruby
"   - please, copy this file to one of your VIM dir
"     - example: to your .vim home folder: $HOME/.vim/vimlog.vim
"   - please, add this code to your .vimrc file:
"
"       if !exists('*Wordpress_vim')
"         runtime vimlog.vim
"       endif
"
"   - change your blog login/password info on the get_personal_data
"     function bellow. 
"   - make sure you have xmlrpc.php file in your / blog dir. If not, 
"     change the @xml variable to find it.
"   - testing: open vim, and do 
"       :Blog rp 
"     to get your recent 10 posts.
"   - Questions ? e-mail please ;)
"   - Using it ? please, leave a word ;)


if !has('ruby')
    echo "---------------------------------------"
    echo "Error: Required vim compiled with +ruby"
    echo "---------------------------------------"
    finish
endif

" Vim syntax functions
" Language:     wordpress_vim
" Maintainer:   pedro mg <pedro.mota [at] gmail.com>
" Version:      1.1
" Last Change:  2008 Apr 10
" Remark:       Simple functions for vim blogging bundle in ruby.
" Remark:       Please, if you fine tune this code, send it back  
" Remark:       for version upgrade ;)

function! Blog_syn_hl()    " {{{2
  :syntax clear
  :syntax keyword wpType Post Title Date
  :syntax region wpTitle start=/"/ end=/$/ 
  :syntax region wpPostId start=/\[/ end=/\]/ 
  :highlight wpType ctermfg=Green guifg=LightGreen
  :highlight wpTitle cterm=bold ctermfg=Blue guifg=Blue guibg=LightCyan gui=bold
  :highlight wpPostId ctermfg=Red guifg=Red
endfunction
" }}}2

function! Post_syn_hl()    " {{{3
  :syntax clear
  :runtime! syntax/html.vim   " content syntax is html hl, except for headers
  :syntax keyword wpType Post Title Date Author Link Permalink Allow Comments Allow Pings Categs  
  :syntax region wpPostId start=/\[/ end=/\]/ contained
  :syntax match wpFields /: .*/hs=s+2 contains=wpPostId 
  :highlight wpType ctermfg=Green guifg=LightGreen gui=bold
  :highlight wpPostId ctermfg=Red guifg=Red
  :highlight wpFields ctermfg=Blue guifg=Blue guibg=LightCyan
endfunction
" }}}3

" Vim blogging function
" Language:     vim script 
" Interface:    ruby
" Maintainer:   pedro mg <pedro.mota [at] gmail.com>
" Version:      1.0
" Last Change:  2007 Mar 02
" Remark:       script function for vim blogging bundle in ruby.
" Remark:       Please, if you fine tune this code, send it back  
" Remark:       for version upgrade ;)

:command -nargs=* Blog call Wordpress_vim(<f-args>)

function! Wordpress_vim(start, ...)    " {{{1
  call Blog_syn_hl() " comment if you don't wish syntax highlight activation
  try
ruby <<EOF
  require 'xmlrpc/client.rb'
  require 'time.rb'
  class Wp_vim
    
    #######
    # class initialization. Instantiates the @blog class variable to
    # retain blog site information for future api calls
    #
    def initialize
      begin
        get_personal_data
        @blog = XMLRPC::Client.new(@site, @xml, @port)
        self.send("blog_"+VIM::evaluate("a:start"))
      rescue XMLRPC::FaultException => e
        xmlrpc_flt_xcptn(e)
      end
    end
    
    #######
    # class variables for personnal data. Please *change* them accordingly.
    # CHANGE HERE:
    def get_personal_data  
      @login = "" # insert your login here
      @passwd = "" # insert your password here
      @site = "" # insert your blog url here, but do not use http://
      @xml = "/xmlrpc.php" # change if necessary
      @port = 80 # change if necessary
      @blog_id = 0
      @user =  1
    end

    def get_post_content
      post_content = {}
      new_post = VIM::Buffer.current[1][0..4].upcase == "Title".upcase
      post_content['new_post'] = new_post
      case new_post
      when true
        post_content['title'] = (VIM::Buffer.current[1]).gsub(/Title *:/, '').strip
        post_content['dateCreated'] = Time.parse(((VIM::Buffer.current[2]).gsub(/Date *:/, '')).strip)
        post_content['mt_allow_comments'] = (VIM::Buffer.current[3]).gsub(/Comments *:/, '')
        post_content['mt_allow_pings'] = (VIM::Buffer.current[4]).gsub(/Pings *:/, '')
        post_content['categories'] = (VIM::Buffer.current[5]).gsub(/Categs *:/, '').split
        body = [] # from line 8 to the end, grab the post body content
        8.upto(VIM::Buffer.current.count) { |line| body << VIM::Buffer.current[line] }
	post_content['description'] = body.join("\r")
      else
        post_content['post_id'] = ((VIM::Buffer.current[1]).gsub(/Post.*\[/, '')).strip.chop
        post_content['title'] = (VIM::Buffer.current[2]).gsub(/Title *:/, '')
        post_content['dateCreated'] = Time.parse(((VIM::Buffer.current[3]).gsub(/Date *:/, '')).strip)
        post_content['mt_allow_comments'] = (VIM::Buffer.current[7]).gsub(/Comments *:/, '')
        post_content['mt_allow_pings'] = (VIM::Buffer.current[8]).gsub(/Pings *:/, '')
        post_content['categories'] = (VIM::Buffer.current[9]).gsub(/Categs *:/, '').split 
	body = [] # from line 11 to the end, grab the post body content
        11.upto(VIM::Buffer.current.count) { |line| body << VIM::Buffer.current[line] }
	post_content['description'] = body.join("\r")
      end
      post_content['mt_exceprt'] = ''
      post_content['mt_text_more'] = ''
      post_content['mt_tb_ping_urls'] = []
      return post_content
    end  

    #######
    # publish the post. Verifies if it is new post, or an editied existing one.
    #
    def blog_publish
      p = get_post_content
      resp = blog_api("publish", p, true, p['new_post']) 
      if (p['new_post'] and resp['post_id'])
      then
        VIM::command("enew!")
        VIM::command("Blog gp #{resp['post_id']}")
      end
    end

    #######
    # save post as draft. Verifies if it is new post, or an editied existing one.
    #
    def blog_draft
      p = get_post_content
      resp = blog_api("draft", p, false, p['new_post']) 
      if (p['new_post'] and resp['post_id'])
      then
        VIM::command("enew!")
        VIM::command("Blog gp #{resp['post_id']}")
      end
    end

    #######
    # new post. Creates a template for a new post.
    #
    def blog_np
      @post_date = same_dt_fmt(Time.now)
      @post_author = @user
      VIM::command("call Post_syn_hl()")
      v = VIM::Buffer.current
      v.append(v.count-1, "Title    : ")
      v.append(v.count-1, "Date     : #{@post_date}")  
      v.append(v.count-1, "Comments : 1")
      v.append(v.count-1, "Pings    : 1")
      v.append(v.count-1, "Categs   : ")
      v.append(v.count-1, " ")
      v.append(v.count-1, " ")
      v.append(v.count-1, "<type from here...> ")
    end

    #######
    # list of categories. Is opened in a new temporary window, because may me for assistance on
    # creating/editing a post.
    #
    def blog_cl
      resp = blog_api("cl")
      # create a new window with syntax highlight.
      # this allows you to rapidelly close the window (:q!) and continue blogging.
      VIM::command(":new")
      VIM::command("call Blog_syn_hl()")
      VIM::command(":set wrap")
      v = VIM::Buffer.current
      v.append(v.count, "CATEGORIES LIST: ")
      v.append(v.count, " ")
      v.append(v.count, "\"#{resp.join('  ')}\"")
    end

    #######
    # recent [num] posts. Gets some info for the most recent [num] or 10 posts
    #
    def blog_rp
      VIM::evaluate("a:0").to_i > 0 ? ((num = VIM::evaluate("a:1")).to_i ? num.to_i : num = 10) : num = 10
      resp = blog_api("rp", num)
      # create a new window with syntax highlight.
      # this allows you to rapidely close the window (:q!) and get that post id.
      VIM::command(":new")
      VIM::command("call Blog_syn_hl()")
      v = VIM::Buffer.current
      v.append(v.count, "MOST RECENT #{num} POSTS: ")
      v.append(v.count, " ")
      resp.each { |r|
        v.append(v.count, "Post : [#{r['post_id']}]  Date: #{r['post_date']}")
        v.append(v.count, "Title: \"#{r['post_title']}\"")
        v.append(v.count, " ")
      }
    end

    #######
    # get post [id]. Fetches blog post with id [id], or the last one.
    #
    def blog_gp
      VIM::command("call Post_syn_hl()")
      VIM::evaluate("a:0").to_i > 0 ? ((id = VIM::evaluate("a:1")) ? id : id = nil) : id = nil
      resp = blog_api("gp", id)
      v = VIM::Buffer.current
      v.append(v.count-1, "Post     : [#{resp['post_id']}]")
      v.append(v.count-1, "Title    : #{resp['post_title']}")
      v.append(v.count-1, "Date     : #{resp['post_date']}")
      v.append(v.count-1, "Link     : #{resp['post_link']}")
      v.append(v.count-1, "Permalink: #{resp['post_permaLink']}")
      v.append(v.count-1, "Author   : #{resp['post_author']}")
      v.append(v.count-1, "Comments : #{resp['post_allow_comments']}")
      v.append(v.count-1, "Pings    : #{resp['post_allow_pings']}")
      v.append(v.count-1, "Categs   : #{resp['post_categories']}")
      v.append(v.count-1, " ")
      v.append(v.count-1, " ")
      resp['post_body'].each_line { |l| v.append(v.count-1, l.strip)}
    end

    #######
    # delete post with id [id]. Asks for confirmation first
    #
    def blog_del
      VIM::evaluate("a:0").to_i > 0 ? ((id = VIM::evaluate("a:1")) ? id : id = nil) : id = nil
      resp = blog_api("del", id)
      resp ? VIM.command("echo \"Blog post ##{id} successfully deleted\"") : VIM.command("echo \"Deletion problem for post id ##{id}\"")
    end

    #######
    # api calls. Allways returns an hash so that if api is changed, only this
    # function needs to be changed. One can use between Blogger, metaWeblog or
    # MovableType very easilly. 
    #
    def blog_api(fn_api, *args)
      begin
        case fn_api

        when "gp"
          resp = @blog.call("metaWeblog.getPost", args[0], @login, @passwd)
	  @post_id = resp['postid']
          return { 'post_id' => resp['postid'],
            'post_title' => resp['title'],
            'post_date' => same_dt_fmt(resp['dateCreated'].to_time),
            'post_link' => resp['link'],
            'post_permalink' => resp['permalink'],
            'post_author' => resp['userid'],
            'post_allow_comments' => resp['mt_allow_comments'],
            'post_comment_status' => resp['comment_status'],
            'post_allow_pings' => resp['mt_allow_pings'],
            'post_ping_status' => resp['mt_ping_status'],
            'post_categories' => resp['categories'].join(' '),
            'post_body' => resp['description']
          }

	when "rp"
          resp = @blog.call("mt.getRecentPostTitles", @blog_id, @login, @passwd, args[0])
	  arr_hash = []
          resp.each { |r| arr_hash << { 'post_id' => r['postid'],
                                        'post_title' => r['title'],
                                        'post_date' => r['dateCreated'].to_time }
	  }
	  return arr_hash

	when "cl"
          resp = @blog.call("mt.getCategoryList", @blog_id, @login, @passwd)
	  arr_hash = []
          resp.each { |r| arr_hash << r['categoryName'] }
	  return arr_hash

	when "draft"
	  args[2] ? call = "metaWeblog.newPost" : call = "metaWeblog.editPost" 
	  args[2] ? which_id = @blog_id :  which_id = args[0]['post_id']
          resp = @blog.call(call, which_id, @login, @passwd, args[0], args[1])  # hash content, boolean state ("publish"|"draft")
          return { 'post_id' => resp }
	
        when "publish"
	  args[2] ? call = "metaWeblog.newPost" : call = "metaWeblog.editPost" 
	  args[2] ? which_id = @blog_id :  which_id = args[0]['post_id']
          resp = @blog.call(call, which_id, @login, @passwd, args[0], args[1])  # hash content, boolean state ("publish"|"draft")
          return { 'post_id' => resp }
  
         when "del"
          resp = @blog.call("metaWeblog.deletePost", "1234567890ABCDE", args[0], @login, @passwd)
          return resp

       end
      rescue XMLRPC::FaultException => e
        xmlrpc_flt_xcptn(e)
      end
    end

    #######
    # same datetime format for dates
    #
    def same_dt_fmt(dt)
      dt.strftime('%m/%d/%Y %H:%M:%S %Z')
    end

    #######
    # exception handling error display message for communication problems 
    #
    def xmlrpc_flt_xcptn(excpt)
      msg = "Error code: #{excpt.faultCode} :: Error msg.:#{excpt.faultString}"
      VIM::command("echo \"#{msg}\"")
    end
  
  end # class Wp_vim
  Wp_vim.new
EOF
  catch /del/
    :echo "Usage for deleting a post:"
    :echo "  :Blog del id"
  catch /draft/
    :echo "Usage for saving a draft of a post:"
    :echo "  :Blog draft"
  catch /publish/
    :echo "Usage for Publishing a post:"
    :echo "  :Blog publish"
  catch /gc/
    :echo "Usage for getting the list of Categories <new window>:"
    :echo "  :Blog cl"
  catch /gp/
    :echo "Usage for Get Post [id]:"
    :echo "  :Blog gp id"
  catch /np/
    :echo "Usage for New Post:"
    :echo "  :Blog np"
  catch /rp/
    :echo "Usage for Recent [x] Posts (defaults to last 10): <new window>"
    :echo "  :Blog rp [x]"
  catch //
    :echo "Usage is :Blog option [arg]"
    :echo " switches:"
    :echo "  - rp [x]   => show recent [x] posts"
    :echo "  - gp id    => get post with identification id"
    :echo "  - np       => create a new post"
    :echo "  - publish  => publish an edited/new post" 
    :echo "  - draft    => save edited/new post as draft"
    :echo "  - gc       => get the list of categories"
    :echo "  - del id   => delete post with identification id"
  endtry
endfunction 
" }}}1


