
require("osagie.core.options")


local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end


require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' 
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'neovim/nvim-lspconfig' 
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer' 
  use 'hrsh7th/cmp-path' 
  use 'hrsh7th/cmp-cmdline'
  use 'L3MON4D3/LuaSnip' 
  use 'saadparwaiz1/cmp_luasnip' 
  use {
    'xiyaowong/nvim-transparent', 
    config = function()
      require('transparent').setup({
        enable = true, 
        extra_groups = { 
          'NormalFloat',
          'NvimTreeNormal', 
          'Normal',
          'EndOfBuffer',
          'LineNr',
          'CursorLineNr',
          'SignColumn',
          'StatusLine',
          'StatusLineNC'
        },
        exclude = {},
      })
    end
  }
  use {
    'ellisonleao/gruvbox.nvim',
    requires = { 'rktjmp/lush.nvim' } 
  }
end)

vim.g.gruvbox_transparent_bg = true
vim.cmd [[
  augroup load_colorscheme
    autocmd!
    autocmd User PackerComplete ++once lua vim.cmd("colorscheme gruvbox")
  augroup end
]]

vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
vim.cmd("highlight LineNr guibg=NONE ctermbg=NONE")
vim.cmd("highlight SignColumn guibg=NONE ctermbg=NONE")
vim.cmd("highlight EndOfBuffer guibg=NONE ctermbg=NONE")

require'nvim-treesitter.configs'.setup {
  ensure_installed = {"go", "odin", "c", "cpp", "lua", "javascript"}, -- Add other languages as needed
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

local lspconfig = require'lspconfig'

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local opts = { noremap=true, silent=true }

buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting_sync()<CR>', opts)
end

lspconfig.gopls.setup{
  on_attach = on_attach,
  settings = {
    gopls = {
      gofumpt = true,
    },
  },
}

lspconfig.ols.setup({
  cmd = {"C:\\ols\\ols.exe"}
})

lspconfig.clangd.setup{
  on_attach = on_attach,
}

lspconfig.lua_ls.setup {
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = vim.split(package.path, ';')
      },
      diagnostics = {
        globals = {'vim'}
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        maxPreload = 2000,
        preloadFileSize = 1000,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

lspconfig.ts_ls.setup{
  on_attach = on_attach,
}

local cmp = require'cmp'
local luasnip = require'luasnip'

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
})

vim.o.completeopt = 'menuone,noselect'

