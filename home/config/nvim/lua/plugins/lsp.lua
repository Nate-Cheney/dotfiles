return {
    {
        "saghen/blink.cmp",
        version = "1.*",
        --build = "cargo build --release",
        lazy = false,

        -- lets other specs (e.g. markview) extend sources.default without overwriting list
        opts_extend = { "sources.default" },

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            fuzzy = { implementation = "lua" },

            -- 'default' maps standard keys (e.g., <C-space> to trigger, <C-y> to accept)
            keymap = {
                preset = "default",
                ["<C-a>"] = { "show", "show_documentation", "hide_documentation" },

                -- Cover both encodings of Ctrl+Space
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-@>"]     = { "show", "show_documentation", "hide_documentation" },
            },

            appearance = {
                use_nvim_cmp_as_default = true,

                nerd_font_variant = "mono",  -- use 'normal' if render issues
            },

            completion = {
                menu = {
                    -- Stops the menu from popping up automatically
                    auto_show = false,
                },
                trigger = {
                    -- Stops the engine from triggering when typing normal words
                    show_on_keyword = false,
                    -- Stops the engine from triggering when typing characters like '.' or ':'
                    show_on_trigger_character = false,
                },
            },

            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },

            -- Experimental signature help (shows function arguments as you type)
            signature = { enabled = true },
        },
    },

    -- LSP server installer UI
    {
        "mason-org/mason.nvim",
        build = ":MasonUpdate",
        opts = {},
    },

    -- Bridges Mason <-> nvim-lspconfig: auto-installs ensure_installed servers.
    -- v2 has no handlers option; per-server settings live in after/lsp/*.lua.
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        opts = {
            ensure_installed = {
                "bashls",
                "jsonls",
                "lua_ls",
                "pyright",
                "terraformls",
                "yamlls",
            },
            automatic_enable = false,
        },
    },

    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.lsp.enable({
                "bashls",
                "jsonls",
                "lua_ls",
                "pyright",
                "terraformls",
                "yamlls",
            })
        end,
    },

    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = {
                "tflint",
                "yamllint",
                "shellcheck"
            },
            auto_update = true,
            run_on_start = true,
        },
    },
}
