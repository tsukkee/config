function fish_user_key_bindings -d "Define user key bindings"
    bind -M insert \cp up-or-search
    bind -M insert \cn down-or-search
    bind -M insert \cf accept-autosuggestion

    bind u undo
    bind \cr redo
end
