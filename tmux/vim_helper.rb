#!/usr/bin/env ruby

current = `tmux display-message -p "#I:#P"`

open(ENV['HOME'] + "/vim_pane_save").each do |i|
  if i == current
    `tmux set-option -g prefix C-f`
  end
end
