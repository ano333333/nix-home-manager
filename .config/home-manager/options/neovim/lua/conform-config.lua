local M = {}
local util = require("conform.util")

function M.initConform()
  require("conform").setup({
    formatters = {
      biome = {
        -- biome.json / biome.jsonc があるプロジェクトでのみ Biome を有効化
        require_cwd = true,
        cwd = util.root_file({ "biome.json", "biome.jsonc" }),
      },
    },

    formatters_by_ft = {
      -- Lua
      lua = { "stylua" },

      -- Go
      go = { "gofumpt", "goimports" },

      -- Rust
      rust = { "rustfmt" },

      -- Nix
      nix = { "nixfmt" },

      -- TS/JS: まず Biome、使えない場合のみ Prettier
      javascript = { "biome", "prettier", stop_after_first = true },
      typescript = { "biome", "prettier", stop_after_first = true },
      javascriptreact = { "biome", "prettier", stop_after_first = true },
      typescriptreact = { "biome", "prettier", stop_after_first = true },

      -- Svelte
      svelte = { "prettier" },

      -- HTML/CSS/JSON
      html = { "prettier" },
      css = { "prettier" },
      json = { "prettier" },

      -- その他のWeb関連
      markdown = { "prettier" },
      yaml = { "prettier" },
    },

    -- 保存時に自動フォーマット
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },
  })

  -- gfキーマッピングをconformのformatに変更
  vim.keymap.set("n", "gf", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
  end, { noremap = true, silent = true, desc = "Format buffer" })

  -- 範囲選択したところだけフォーマット
  vim.keymap.set("v", "gf", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
  end, { noremap = true, silent = true, desc = "Format selection" })
end

return M
