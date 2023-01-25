function fish_user_key_bindings -d "Define user key bindings"
    bind -M insert \cp up-or-search
    bind -M insert \cn down-or-search
    bind -M insert \cr history-pager
    bind -M insert \cf accept-autosuggestion
    bind -M insert \cd delete-char

    bind u undo
    bind \cr redo
    bind \cd delete-char
end
