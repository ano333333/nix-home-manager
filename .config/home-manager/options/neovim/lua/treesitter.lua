local M = {}

function M.initTreesitter()
  local g = vim.g
  -- ========================================
  -- plugins(nvim-treesitter)
  -- ========================================
  require('nvim-treesitter.configs').setup {
    -- 自動インストールを無効化（Nixで宣言的に管理）
    auto_install = false,

    -- シンタックスハイライトを有効化
    highlight = {
      enable = true,
      -- Vimのシンタックスを無効化（Treesitterを優先）
      additional_vim_regex_highlighting = false,
    },

    -- インデントを有効化
    indent = {
      enable = true,
    },

    -- テキストオブジェクト
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]c"] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[c"] = "@class.outer",
        },
      },
    },
  }

  -- ========================================
  -- plugins(nvim-treesitter-context)
  -- ========================================
  require('treesitter-context').setup {
    enable = true,
    max_lines = 0,
    mode = 'cursor',
  }

  -- ========================================
  -- plugins(rainbow-delimiters.nvim)
  -- ========================================
  g.rainbow_delimiters = {
    strategy = {
      [''] = require('rainbow-delimiters').strategy['global'],
    },
    query = {
      [''] = 'rainbow-delimiters',
    },
    highlight = {
      'RainbowDelimiterRed',
      'RainbowDelimiterYellow',
      'RainbowDelimiterBlue',
      'RainbowDelimiterOrange',
      'RainbowDelimiterGreen',
      'RainbowDelimiterViolet',
      'RainbowDelimiterCyan',
    },
  }

  -- ========================================
  -- plugins(indent-blankline.nvim)
  -- ========================================
  require("ibl").setup()

  -- ========================================
  -- plugins(nvim-ts-autotag)
  -- ========================================
  require('nvim-ts-autotag').setup({
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = false,
    },
  })
end

return M
