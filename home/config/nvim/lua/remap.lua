vim.g.mapleader = " "

-- Normal mode
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>gh", "<cmd>!/$HOME/.config/nvim/bin/open-github.sh<CR>", { desc = "Open the project in GitHub" })

-- Insert mode
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode with jj" })

