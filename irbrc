#IRB.conf[:AUTO_INDENT] = true
IRB.conf[:USE_READLINE] = true
IRB.conf[:SAVE_HISTORY] = 5000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.var/lib/irb_history"

IRB.conf[:PROMPT][:MY_PROMPT] = {
      :PROMPT_I => "%N(%m):%03n:%i> ",
      :PROMPT_N => "%N(%m):%03n:%i> ",
      :PROMPT_S => "%N(%m):%03n:%i%l ",
      :PROMPT_C => "%N(%m):%03n:%i* ",
      :RETURN => "=> %s\n"
}
IRB.conf[:PROMPT_MODE] = :MY_PROMPT
#IRB.conf[:PROMPT_MODE] = :SIMPLE

require 'irb/completion'
require 'irb/ext/save-history'
require 'pp'

# load rubygems and wirble
require 'rubygems' rescue nil
require 'wirble'
require 'utility_belt'

# load wirble
Wirble.init
Wirble.colorize
