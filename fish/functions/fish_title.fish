function fish_title
    set -q argv[1]; or set argv fish

    echo \> $argv [( prompt_pwd --full-length-dirs=3 )]
end
