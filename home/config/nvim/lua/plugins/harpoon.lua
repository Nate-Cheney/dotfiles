return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },

    opts = {},

    keys = {
        -- Add and clear
        { "<leader>a", function() require("harpoon"):list():add() end, desc = "Add file to Harpoon list" },
        { "<leader>hc", function() require("harpoon"):list():clear() end, desc = "Clear Harpoon list" },

        -- Menu
        { "<C-e>", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Toggle Harpoon menu" },

        -- Navigation
        { "<M-1>", function() require("harpoon"):list():select(1) end, desc = "Open Harpoon list index 1" },
        { "<M-2>", function() require("harpoon"):list():select(2) end, desc = "Open Harpoon list index 2" },
        { "<M-3>", function() require("harpoon"):list():select(3) end, desc = "Open Harpoon list index 3" },
        { "<M-4>", function() require("harpoon"):list():select(4) end, desc = "Open Harpoon list index 4" },
        { "<M-5>", function() require("harpoon"):list():select(5) end, desc = "Open Harpoon list index 5" },

        -- Toggle previous & next buffers stored within Harpoon list
        { "<C-S-P>", function() require("harpoon"):list():prev() end, desc = "Open previous Harpoon buffer" },
        { "<C-S-N>", function() require("harpoon"):list():next() end, desc = "Open next Harpoon buffer" },
    },
}
