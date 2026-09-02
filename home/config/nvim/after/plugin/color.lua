-- Set the colorscheme to catppuccin
vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha

-- Load the colorscheme
require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin"

-- Make Window Transparent
vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
]]

