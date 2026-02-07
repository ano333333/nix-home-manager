local M = {}

function M.initLsp()
  local keymap = vim.keymap
  -- ========================================
  -- plugins(LSP/lspconfig)
  -- ========================================

  -- 補完オプションの設定
  vim.opt.completeopt = { "menu", "menuone", "noselect" }
  vim.opt.pumheight = 15 -- ポップアップメニューの最大高さ
  vim.opt.shortmess:append("c") -- 補完メッセージを短くする

  -- 補完の動作を設定
  vim.lsp.completion.default_config = {
    -- 文字を入力したときに補完候補を自動的にフィルタリング
    filter_completions = true,
  }

  keymap.set("n", "H", function()
    vim.lsp.buf.hover()
  end)
  keymap.set("n", "gd", function()
    vim.lsp.buf.definition()
  end)
  keymap.set("n", "gc", function()
    vim.lsp.buf.declaration()
  end)
  keymap.set("n", "gt", function()
    vim.lsp.buf.type_definition()
  end)
  keymap.set("n", "ge", function()
    vim.lsp.buf.references()
  end)
  keymap.set("n", "gr", function()
    vim.lsp.buf.rename()
  end)
  keymap.set("n", "ga", function()
    vim.lsp.buf.code_action()
  end)
  -- Ctrl+Space で LSP 補完をトリガー
  -- 入力した文字列で自動的にフィルタリングされる
  keymap.set("i", "<C-Space>", "<C-x><C-o>", { noremap = true, silent = true })

  -- 補完候補の選択
  -- Ctrl+j で次の候補、Ctrl+k で前の候補
  -- pumvisible(): ポップアップメニュー（補完候補リスト）が表示されているかを確認する関数
  --   戻り値: 1 = 表示中, 0 = 非表示
  keymap.set("i", "<C-j>", function()
    -- 補完メニューが表示されている場合は次の候補へ移動
    if vim.fn.pumvisible() == 1 then
      return "<C-n>"
    else
      -- 補完メニューが表示されていない場合は通常のCtrl+jの動作
      return "<C-j>"
    end
  end, { expr = true, noremap = true, silent = true })

  keymap.set("i", "<C-k>", function()
    -- 補完メニューが表示されている場合は前の候補へ移動
    if vim.fn.pumvisible() == 1 then
      return "<C-p>"
    else
      -- 補完メニューが表示されていない場合は通常のCtrl+kの動作
      return "<C-k>"
    end
  end, { expr = true, noremap = true, silent = true })

  -- 補完メニューの動作をカスタマイズ
  vim.api.nvim_create_autocmd("CompleteDone", {
    callback = function()
      -- 補完完了後の処理（必要に応じて）
    end,
  })

  -- Insert モードでの文字入力時に補完候補を自動的にフィルタリング
  vim.api.nvim_create_autocmd("TextChangedI", {
    callback = function()
      if vim.fn.pumvisible() == 1 then
        -- ポップアップメニューが表示されている場合、
        -- 入力に応じて候補をフィルタリング（Neovim 0.11では自動）
      end
    end,
  })

  -- 診断の表示設定
  vim.diagnostic.config({
    virtual_text = {
      -- 診断メッセージをインラインで表示
      spacing = 4,
      source = "if_many",
      prefix = "●",
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "✘",
        [vim.diagnostic.severity.WARN] = "▲",
        [vim.diagnostic.severity.HINT] = "⚑",
        [vim.diagnostic.severity.INFO] = "»",
      },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    -- フロートウィンドウで診断の詳細を表示
    float = {
      source = "if_many",
      border = "rounded",
    },
  })

  -- ========================================
  -- plugins(LSP/lua-language-server)
  -- ========================================

  vim.lsp.config["luals"] = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    -- Sets the "root directory" to the parent directory of the file in the
    -- current buffer that contains either a ".luarc.json" or a
    -- ".luarc.jsonc" file. Files that share a root directory will reuse
    -- the connection to the same LSP server.
    -- Nested lists indicate equal priority, see |vim.lsp.Config|.
    root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },

    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim" },
          undefined_globals = false,
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
      },
    },

    on_attach = function(client, bufnr)
      -- omnifunc を設定して、<C-x><C-o> で補完できるようにする
      vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

      -- 新しいLSP補完APIも有効にする（自動トリガー用）
      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true,
        convert = function(item)
          return {
            abbr = item.label:gsub("%b()", ""),
          }
        end,
      })
    end,
  }
  vim.lsp.enable("luals")

  -- ========================================
  -- plugins(LSP/gopls)
  -- ========================================

  vim.lsp.config["gopls"] = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },

    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        gofumpt = true,
      },
    },

    on_attach = function(client, bufnr)
      -- omnifunc を設定して、<C-x><C-o> で補完できるようにする
      vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

      -- 新しいLSP補完APIも有効にする（自動トリガー用）
      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true,
      })
    end,
  }
  vim.lsp.enable("gopls")

  -- ========================================
  -- plugins(LSP/rust-analyzer)
  -- ========================================

  local on_attach = function(client, bufnr)
    -- omnifunc を設定して、<C-x><C-o> で補完できるようにする
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    vim.lsp.completion.enable(true, client.id, bufnr, {
      autotrigger = true,
    })

    -- LSP接続完了後に診断を表示
    vim.schedule(function()
      vim.diagnostic.show(nil, bufnr)
    end)
  end

  vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
    on_attach = on_attach,
    settings = {
      ["rust-analyzer"] = {
        imports = {
          granularity = {
            group = "module",
          },
          prefix = "self",
        },
        cargo = {
          buildScripts = {
            enable = true,
          },
          allFeatures = true,
        },
        procMacro = {
          enable = true,
        },
        check = {
          command = "clippy",
        },
        diagnostics = {
          enable = true,
          experimental = {
            enable = true,
          },
          -- 無効化する診断を指定（空の場合は全て有効）
          disabled = {},
          -- 警告レベルの診断も表示
          warningsAsHint = {},
          warningsAsInfo = {},
        },
        -- インポート関連の診断を強化
        checkOnSave = {
          enable = true,
          command = "clippy",
          allTargets = true,
        },
      },
    },
  })
  vim.lsp.enable("rust_analyzer")

  -- ========================================
  -- plugins(LSP/nil_ls for nix)
  -- ========================================

  vim.lsp.config["nil_ls"] = {
    cmd = { "nil" },
    filetypes = { "nix" },
    root_markers = { "flake.nix", "flake.lock", ".git" },

    settings = {
      ["nil"] = {
        formatting = {
          command = { "nixfmt" },
        },
      },
    },

    on_attach = function(client, bufnr)
      vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true,
      })
    end,
  }
  vim.lsp.enable("nil_ls")

  -- ========================================
  -- plugins(LSP/vtsls, denols)
  -- ========================================

  vim.lsp.enable("htmx")

  vim.lsp.enable("vtsls")

  vim.lsp.config("denols", {
    root_dir = function(bufnr, on_dir)
      -- The project root is where the LSP can be started from
      local root_markers = { "deno.lock" }
      local project_root = vim.fs.root(bufnr, root_markers)
      -- consider "\" as *Deno* project root if bufnr has no deno.lock as its parent
      project_root = not project_root and "\\" or project_root
      -- exclude non-deno projects (npm, yarn, pnpm, bun)
      local non_deno_path = vim.fs.root(bufnr, {
        "package.json",
        "package-lock.json",
        "yarn.lock",
        "pnpm-lock.yaml",
        "bun.lockb",
        "bun.lock",
      })
      -- same trick as project_root
      non_deno_path = not non_deno_path and "\\" or non_deno_path
      if #non_deno_path >= #project_root then
        return
      end
      -- We fallback to the current working directory if no project root is found
      on_dir(project_root or vim.fn.getcwd())
    end,
  })
  vim.lsp.enable("denols")

  -- only for svelte-language-server
  vim.lsp.config("ts_ls", {
    root_markers = { "pacakge.json" },
    filetypes = {
      "svelte",
    },
  })
  vim.lsp.enable("ts_ls")

  vim.lsp.enable("svelte")

  -- ========================================
  -- plugins(LSP/lsp-ai)
  -- (https://github.com/SilasMarvin/lsp-ai/wiki/Configuration)
  -- ========================================

  vim.lsp.config("lsp_ai", {
    filetypes = {
      "nix",
      "lua",
      "javascript",
      "typescript",
      "css",
      "html",
      "json",
    },
    init_options = {
      models = {
        model1 = {
          type = "ollama",
          model = "qwen2.5-coder:7b",
        },
      },
      completion = {
        model = "model1",
        parameters = {
          max_context = 1800,
          options = {
            num_predict = 50,
          },
        },
      },
    },
  })
  vim.lsp.enable("lsp_ai")
end

return M
