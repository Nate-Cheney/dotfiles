local status_ok, blink = pcall(require, "blink.cmp")
if not status_ok then
    return
end

blink.setup({
    -- 'default' maps standard keys (e.g., <C-space> to trigger, <C-y> to accept)
    -- Other options include 'super-tab', 'enter', or defining your own
    keymap = { 
        preset = "default",
        ["<C-a>"] = { "show", "show_documentation", "hide_documentation" },

        -- Cover both encodings of Ctrl+Space
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-@>"]     = { "show", "show_documentation", "hide_documentation" },
    },
    
    appearance = {
        use_nvim_cmp_as_default = true,
        
        -- Adjust to 'normal' if terminal font doesn't render Nerd Font mono properly
        nerd_font_variant = "mono"
    },

    completion = {
        menu = {
            -- Stops the menu from popping up automatically
            auto_show = false,
        },
        trigger = {
            -- Stops the engine from triggering when you type normal words
            show_on_keyword = false,
            -- Stops the engine from triggering when you type characters like '.' or ':'
            show_on_trigger_character = false,
        }
    },
    
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },
    
    -- Experimental signature help (shows function arguments as you type)
    signature = { enabled = true }
})

