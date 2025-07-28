-- ======================
-- | TEXT EDITOR CONFIG |
-- ======================
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- don't wrap my text, mate
vim.opt.wrap = false

-- tab indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- disable swap files
vim.opt.swapfile = false

-- use the sign columns, always
vim.opt.signcolumn = "yes"

-- use system clipboard
vim.o.clipboard = "unnamedplus"

-- popup borders
vim.o.winborder = "rounded"

-- pretty collors oh ma gawd
vim.opt.termguicolors = true

-- ===================
-- | KEYBINDS CONFIG |
-- ===================

-- use space as leader key
vim.g.mapleader = " "

-- update and source config
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')

-- format and write
vim.keymap.set('n', '<leader>w', function()
    vim.lsp.buf.format()
    vim.cmd("write")
end
)

-- force format
vim.keymap.set('n', '<leader>lf', function()
    vim.lsp.buf.format({ async = true })
end)

-- find me files pls
vim.keymap.set('n', '<leader>f', ":Pick files<CR>")

-- i need file tree pls
vim.keymap.set('n', '<leader>e', ":NvimTreeToggle<CR>")

-- ==================
-- | PLUGINS CONFIG |
-- ==================
vim.pack.add({
    -- catppuccin theme
    { src = 'https://github.com/catppuccin/nvim' },

    -- lsp stuff
    { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/ray-x/lsp_signature.nvim' },
    { src = 'https://github.com/RRethy/vim-illuminate' },
    { src = 'https://github.com/windwp/nvim-autopairs' },

    -- mini fuzzy finder
    { src = 'https://github.com/echasnovski/mini.pick' },

    -- cmp
    { src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
    { src = 'https://github.com/hrsh7th/cmp-buffer' },
    { src = 'https://github.com/hrsh7th/cmp-path' },
    { src = 'https://github.com/hrsh7th/cmp-cmdline' },
    { src = 'https://github.com/hrsh7th/nvim-cmp' },

    -- give me file explorer
    { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },

    -- git stuffs
    { src = 'https://github.com/tpope/vim-fugitive' },
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
})

require("nvim-autopairs").setup()

require("nvim-tree").setup({
    view = {
        width = 30
    },
    filters = {
        dotfiles = true
    }
})

require("mason").setup()

-- Configure mason-lspconfig to automatically set up LSP servers
require("mason-lspconfig").setup({
    ensure_installed = {},
    handlers = {
        function(server_name)
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            require('lspconfig')[server_name].setup({
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    if client:supports_method('textDocument/completion') then
                        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
                    end
                    local buf_map = function(mode, lhs, rhs, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, lhs, rhs, opts)
                    end

                    buf_map('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to Declaration' })
                    buf_map('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to Definition' })
                    buf_map('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation' })
                    buf_map('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to Implementation' })
                    buf_map('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })
                    buf_map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
                    buf_map('n', 'gr', vim.lsp.buf.references, { desc = 'Go to References' })
                    buf_map('n', '<leader>D', vim.lsp.buf.type_definition,
                        { desc = 'Go to Type Definition' })
                    buf_map('n', '<leader>wa', vim.lsp.buf.add_workspace_folder,
                        { desc = 'Add Workspace Folder' })
                    buf_map('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder,
                        { desc = 'Remove Workspace Folder' })
                    buf_map('n', '<leader>wl', function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, { desc = 'List Workspace Folders' })
                end,
            })
        end,
    }
})

require("mini.pick").setup()

local cmp = require "cmp"
cmp.setup({
    snippet = {
        expand = function(args)
            return
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' }, -- This makes cmp aware of LSP suggestions
        { name = 'buffer' },   -- Suggests words from current buffer
        { name = 'path' },     -- Suggests file paths
    }),
})

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
})

vim.cmd("set completeopt+=noselect")

-- style
vim.cmd("colorscheme catppuccin-mocha")
vim.cmd(":hi statusline guibg=NONE")
