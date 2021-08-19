# env
set -x LANG ja_JP.UTF-8
set -x __CF_USER_TEXT_ENCODING '0x1F5:0x08000100:14'
set -x BLOCKSIZE k

set -x MANPATH /usr/local/*/man /usr/*/man $MANPATH
set -x PATH /usr/local/opt/gnu-tar/libexec/gnubin $HOME/.cargo/bin /usr/local/bin /opt/local/bin /opt/local/sbin /usr/X11/bin $PATH

if test -x /usr/local/bin/vim
    set -x EDITOR /usr/local/bin/vim
else
    set -x EDITOR /usr/bin/vim
end

set -x BAT_THEME Nord

# prompt
starship init fish | source

# git
# set __fish_git_prompt_showcolorhints true

# key bindings
fish_vi_key_bindings

# alias
alias ls="ls -GF"

if test -f $HOME/.config.fish.local
    source $HOME/.config.fish.local
end
