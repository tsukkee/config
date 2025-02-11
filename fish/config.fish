# env
set -x LANG ja_JP.UTF-8
set -x __CF_USER_TEXT_ENCODING '0x1F5:0x08000100:14'
set -x BLOCKSIZE k

# pnpm
set -x PNPM_HOME "/Users/tsukkee/Library/pnpm"

# path
set -x MANPATH /usr/local/*/man /usr/*/man $MANPATH
set -x PATH $PNPM_HOME $HOME/.local/bin /usr/local/opt/gnu-tar/libexec/gnubin $HOME/.cargo/bin $HOME/go/bin /usr/local/bin /opt/local/bin /opt/local/sbin /usr/X11/bin $PATH
set -x XDG_CONFIG_HOME $HOME/.config

# mise
# mise activate fish | source # this will be done by mise itself
set -x PATH $HOME/.local/share/mise/shims $PATH

# editor
if test -x /usr/local/bin/vim
    set -x EDITOR /usr/local/bin/vim
else
    set -x EDITOR /usr/bin/vim
end

# bat
set -x BAT_THEME Nord

# prompt
starship init fish | source

# key bindings
fish_vi_key_bindings
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_replace underscore
set fish_cursor_external line
set fish_cursor_visual block

# alias
alias ls="ls -GF"

if test -f $HOME/.config.fish.local
    source $HOME/.config.fish.local
end
