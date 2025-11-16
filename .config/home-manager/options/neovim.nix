{
  neovimPlugins,
  ...
}: 
{
  enable = true;
  defaultEditor = true;
  plugins = neovimPlugins;
  extraLuaConfig = ''
-- ========================================
-- 基本オプション
-- ========================================
local opt = vim.opt
local g   = vim.g
local keymap = vim.keymap

-- wildmenu
opt.wildmenu = true

-- クリップボード連携
opt.clipboard = "unnamedplus"

-- マウスサポート
opt.mouse = "a"

-- 分割方向
opt.splitbelow = true
opt.splitright = true

-- スワップファイル無効
opt.swapfile = false

-- ----------------------------------------
-- insert mode / インデントまわり
-- ----------------------------------------
-- タブをスペースに展開
opt.expandtab = true
-- バックスペース削除
opt.backspace = { "indent", "eol", "start" }

-- ----------------------------------------
-- virtual edit
-- ----------------------------------------
-- 矩形選択で文字がない箇所も進める
opt.virtualedit = "block"

-- ----------------------------------------
-- 表示
-- ----------------------------------------
-- 行番号表示
opt.number = true
-- 現在の行をハイライトする
opt.cursorline = true
-- タイトルの表示
opt.title = true
-- タブストップ
opt.tabstop = 2
-- シフト幅
opt.shiftwidth = 2
-- 全角文字
opt.ambiwidth = "double"
-- シンタックスハイライト
vim.cmd("syntax on")
-- 対応するカッコやブレースを表示 + 時間
opt.showmatch = true
opt.matchtime = 1
-- メッセージ表示欄2行
opt.cmdheight = 2
-- ステータス行を常に表示
opt.laststatus = 2
-- 行末のスペースの可視化
opt.listchars = "tab:^\\ ,trail:~"
-- コメントを水色で表示
vim.cmd("highlight Comment ctermfg=3")
-- 検索結果をハイライト表示
opt.hlsearch = true
-- 単語の途中で折り返さないようにする
opt.linebreak = true
-- 折返しの表示
opt.showbreak = ">>>"
-- シンタックスに基づいて折りたたみを設定する
opt.foldmethod = "syntax"

-- ========================================
-- HTML/XML 閉じタグ自動補完
-- ========================================
do
local group = vim.api.nvim_create_augroup("htmlXmlAutoClose", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
group = group,
pattern = { "html", "xml" },
callback = function()
-- inoremap <buffer> </ </<C-x><C-o>
vim.api.nvim_buf_set_keymap(
0,
"i",
"</",
[[</<C-x><C-o>]],
{ noremap = true, silent = true }
)
end,
})
end

-- ========================================
-- キーマップ（プラグイン非依存のもの）
-- ========================================

-- <leader> はデフォルトで "\" ですが、
-- もしスペースにしたいなら:
-- vim.g.mapleader = " "

-- <leader>w に <C-w> を割り当て (window 操作用)
keymap.set("n", "<leader>w", "<C-w>", { noremap = true })

-- terminal モード: Esc でノーマルモード
-- 元設定と同じく <C-\><C-N> を送る
keymap.set("t", "<Esc>", [[<C-\><C-N>]], { noremap = true })

-- ========================================
-- 独自コマンド
-- ========================================
-- :Vterm で縦分割ターミナルを開く
vim.api.nvim_create_user_command("Vterm", function()
vim.cmd("vert term")
end, {})

-- ========================================
-- plugins(general)
-- ========================================
vim.cmd("filetype plugin indent on")

-- ========================================
-- plugins(airline)
-- ========================================
g.airline_theme = "solarized"
g.airline_solarized_bg = "dark"
g.airline_powerline_fonts = 1

-- ========================================
-- plugins(nerdtree)
-- ========================================

-- <leader>n で NERDTree にフォーカス
keymap.set("n", "<leader>n", ":NERDTreeFocus<CR>", { noremap = true, silent = true })

-- <C-t> で NERDTree をトグル
keymap.set("n", "<C-t>", ":NERDTreeToggle<CR>", { noremap = true, silent = true })

-- ========================================
-- plugins(nerdtree-git-plugin)
-- ========================================
-- nerdfonts の predefined map を使う
g.NERDTreeGitStatusUseNerdFonts = 1
-- ignored ファイルを表示する
-- (元の設定は Staatus と typo があったので Status に直しています)
g.NERDTreeGitStatusShowIgnored = 1

-- ========================================
-- plugins(barbar.nvim)
-- ========================================

-- 前後のバッファへ移動
keymap.set("n", "<A-,>", "<Cmd>BufferPrevious<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-.>", "<Cmd>BufferNext<CR>",     { noremap = true, silent = true })

-- 指定位置のバッファへ移動
keymap.set("n", "<A-1>", "<Cmd>BufferGoto 1<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-2>", "<Cmd>BufferGoto 2<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-3>", "<Cmd>BufferGoto 3<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-4>", "<Cmd>BufferGoto 4<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-5>", "<Cmd>BufferGoto 5<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-6>", "<Cmd>BufferGoto 6<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-7>", "<Cmd>BufferGoto 7<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-8>", "<Cmd>BufferGoto 8<CR>", { noremap = true, silent = true })
keymap.set("n", "<A-9>", "<Cmd>BufferGoto 9<CR>", { noremap = true, silent = true })
-- 末尾のバッファへ移動
keymap.set("n", "<A-0>", "<Cmd>BufferLast<CR>",   { noremap = true, silent = true })
-- バッファを閉じる
keymap.set("n", "<A-c>", "<Cmd>BufferClose<CR>",  { noremap = true, silent = true})
  '';
}
