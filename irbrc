require 'rubygems'
require 'irb/completion'
require 'irb/ext/save-history'
require 'wirble'
require 'interactive_editor'

IRB.conf[:USE_READLINE] = true
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = File::expand_path("~/.irb_history")

Wirble.init
Wirble.colorize
