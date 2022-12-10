local wezterm = require 'wezterm'

return {
    font = wezterm.font("PlemolJP Console NF"),
    use_ime = true,
    use_dead_keys = false,
    font_size = 19.0,
    color_scheme = "nord",
    keys = {
        {key="¥",  action=wezterm.action.SendKey { key = '\\' }}
    },
    enable_tab_bar = false,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    -- debug_key_events = true
}

