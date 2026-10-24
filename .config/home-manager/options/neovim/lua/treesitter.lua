local M = {}

function M.initTreesitter()
  local g = vim.g
  -- ========================================
  -- plugins(nvim-treesitter)
  -- ========================================
  -- パーサーはNixで管理し、インストール済みの言語だけ有効化する。
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("NixTreesitter", { clear = true }),
    callback = function(event)
      local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
      if not lang or not vim.treesitter.language.add(lang) then
        return
      end
      vim.treesitter.start(event.buf, lang)
      vim.bo[event.buf].indentexpr =
        "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })

  require("nvim-treesitter-textobjects").setup({
    select = { lookahead = true },
    move = { set_jumps = true },
  })

  for key, query in pairs({
    af = "@function.outer",
    ["if"] = "@function.inner",
    ac = "@class.outer",
    ic = "@class.inner",
  }) do
    vim.keymap.set({ "x", "o" }, key, function()
      require("nvim-treesitter-textobjects.select").select_textobject(
        query,
        "textobjects"
      )
    end)
  end

  for key, mapping in pairs({
    ["]m"] = { "goto_next_start", "@function.outer" },
    ["]c"] = { "goto_next_start", "@class.outer" },
    ["[m"] = { "goto_previous_start", "@function.outer" },
    ["[c"] = { "goto_previous_start", "@class.outer" },
  }) do
    vim.keymap.set({ "n", "x", "o" }, key, function()
      require("nvim-treesitter-textobjects.move")[mapping[1]](
        mapping[2],
        "textobjects"
      )
    end)
  end

  -- ========================================
  -- plugins(nvim-treesitter-context)
  -- ========================================
  require("treesitter-context").setup({
    enable = true,
    max_lines = 0,
    mode = "cursor",
  })

  -- ========================================
  -- plugins(rainbow-delimiters.nvim)
  -- ========================================
  g.rainbow_delimiters = {
    strategy = {
      [""] = require("rainbow-delimiters").strategy["global"],
    },
    query = {
      [""] = "rainbow-delimiters",
    },
    highlight = {
      "RainbowDelimiterRed",
      "RainbowDelimiterYellow",
      "RainbowDelimiterBlue",
      "RainbowDelimiterOrange",
      "RainbowDelimiterGreen",
      "RainbowDelimiterViolet",
      "RainbowDelimiterCyan",
    },
  }

  -- ========================================
  -- plugins(indent-blankline.nvim)
  -- ========================================
  require("ibl").setup()

  -- ========================================
  -- plugins(nvim-ts-autotag)
  -- ========================================
  require("nvim-ts-autotag").setup({
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = false,
    },
  })
end

return M
