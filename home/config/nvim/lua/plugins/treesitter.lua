return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "lua", "vim", "vimdoc" },
            callback = function() vim.treesitter.start() end,
        })
    end,
}
