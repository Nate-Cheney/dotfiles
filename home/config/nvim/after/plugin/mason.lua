local blink_ok, blink = pcall(require, "blink.cmp")
if not blink_ok then
    return
end

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show line diagnostics' })

-- 1. Bootstrap Mason
require("mason").setup()

-- 2. Shared capabilities from Blink
local capabilities = blink.get_lsp_capabilities()
local lspconfig = require("lspconfig")

-- 3. Setup mason-lspconfig (v2 API)
require("mason-lspconfig").setup({
    ensure_installed = {
        "bashls",
        "jsonls",
        "lua_ls",
        "pyright",
        "terraformls",
        "yamlls",
    },
    automatic_installation = true,

    -- handlers replaces the old setup_handlers() call
    handlers = {
        -- Default handler for every server that doesn't have a custom one below
        function(server_name)
            lspconfig[server_name].setup({
                capabilities = capabilities,
            })
        end,

        -- Custom override for lua_ls (e.g. to recognize 'vim' global)
        ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            })
        end,
    },
})

require("mason-tool-installer").setup({
    ensure_installed = {
        "tflint",
        "yamllint",
        "shellcheck",
    },
    auto_update = true,
    run_on_start = true,
})

