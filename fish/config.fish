# env
set -x LANG ja_JP.UTF-8
set -x __CF_USER_TEXT_ENCODING '0x1F5:0x08000100:14'
set -x BLOCKSIZE k

# path
eval (/opt/homebrew/bin/brew shellenv)
fish_add_path --path $HOME/.local/bin
fish_add_path --path $HOME/.cargo/bin
fish_add_path --path $HOME/go/bin
fish_add_path --path /opt/homebrew/opt/gnu-tar/libexec/gnubin
set -x XDG_CONFIG_HOME $HOME/.config
# homebrew環境だとmiseは自動的に読み込まれるのでここには設定がない

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
