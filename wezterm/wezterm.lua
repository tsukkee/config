local wezterm = require 'wezterm'

return {
    font = wezterm.font_with_fallback({
        { family = "0xProto" },
        { family = "IBM Plex Sans JP" },
        { family = "Noto Emoji", assume_emoji_presentation = true},
    }),
    use_ime = true,
    use_dead_keys = false,
    macos_forward_to_ime_modifier_mask = "SHIFT|CTRL",
    font_size = 18.0,
    color_scheme = "nord",
    keys = {
        {key="¥",  action=wezterm.action.SendKey { key = '\\' }}
    },
    enable_tab_bar = false,
    window_padding = {
        left = "0.5cell",
        right = "0.5cell",
        top = 0,
        bottom = 0,
    },
    term = "wezterm",
    audible_bell = "Disabled",
    -- debug_key_events = true
}
