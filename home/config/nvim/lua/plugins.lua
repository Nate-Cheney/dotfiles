return require("packer").startup(function(use)
	-- Packer can manage itself
	use { "wbthomason/packer.nvim" }
    
    -- Required for configuring LSPs
    use { "neovim/nvim-lspconfig" }

    -- Requred for nvim plugins
    use { "nvim-lua/plenary.nvim" }

    -- Blink
    use {
        "saghen/blink.cmp",
        branch = "v1",
        run = "cargo build --release"
    }

	-- Harpoon
    use {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        requires = { {"nvim-lua/plenary.nvim"} }
    }

    -- Markview
    use {
        "OXY2DEV/markview.nvim",
        requires = { {"saghen/blink.cmp"} }
    }

    -- Mason
    use {
        "williamboman/mason.nvim",
        run = ":MasonUpdate"
    }
    use {
        "williamboman/mason-lspconfig.nvim",
        requires = { "williamboman/mason.nvim" },
    }
    use {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        requires = { "williamboman/mason.nvim" },
    }

    -- Theme
	use { "catppuccin/nvim", as = "catppuccin" }

	-- Telescope
    use {
        "nvim-telescope/telescope.nvim",
        requires = { {"nvim-lua/plenary.nvim"} }
    }

    -- Treesitter
    use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
    }

    -- Undotree
	use { "mbbill/undotree" }
end)
