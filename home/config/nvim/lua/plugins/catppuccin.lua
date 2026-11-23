return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- load before other UI plugins
  config = function()
    vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha

    require("catppuccin").setup({
      transparent_background = true,
    })

    vim.cmd.colorscheme("catppuccin")

    -- Extra fallback highlights for non-transparent elements if needed
    vim.api.nvim_set_hl(0, "Normal", { bg = "none", ctermbg = "none" })
    vim.api.nvim_set_hl(0, "NonText", { bg = "none", ctermbg = "none" })
  end,
}
