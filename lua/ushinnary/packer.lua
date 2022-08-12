return require("packer").startup(function()
	use("wbthomason/packer.nvim")
	use("nvim-lua/plenary.nvim")
	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.0',
		requires = { {'nvim-lua/plenary.nvim'} }
	}
	use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary/nvim' }
	use("sbdchd/neoformat")
	--Themes
	use("shaunsingh/nord.nvim")
	use("folke/tokyonight.nvim")
	use("gruvbox-community/gruvbox")
	--Coding plug-ins
	use("neovim/nvim-lspconfig")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")
	--Bottom status line
	use {
  'nvim-lualine/lualine.nvim',
  requires = { 'kyazdani42/nvim-web-devicons', opt = true }
}
end)
