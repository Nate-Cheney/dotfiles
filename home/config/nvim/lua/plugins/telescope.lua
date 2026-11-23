return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },

    keys = {
        { "<C-p>", function() require("telescope.builtin").git_files() end, desc = "Telescope find files tracked by git" },
        { "<leader>pf", function() require("telescope.builtin").find_files() end, desc = "Telescope find [project] files" },
        { "<leader>ps", function() require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") }) end, desc = "Telescope grep"},
    },
}
