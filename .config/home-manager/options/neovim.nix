{
  neovimPlugins,
  ...
}: 
{
  enable = true;
  defaultEditor = true;
  plugins = neovimPlugins;
  extraConfig = ''
    " wildmenu
    set wildmenu

    " クリップボード連携
    " set clipboard+=unnamed,autoselect
    set clipboard=unnamedplus

    " マウスサポート
    set mouse=a

    " 水平方向の分割を下に設定する
    set splitbelow
    " 垂直方向の分割を右に設定する
    set splitright

    " スワップファイル無効
    set noswapfile

    " ----------------------------------------
    " insert mode
    " ----------------------------------------
    " タブをスペースに展開
    set expandtab
    " バックスペース削除
    set backspace=indent,eol,start

    " ----------------------------------------
    " virtual edit
    " ----------------------------------------
    " 矩形選択で文字がない箇所も進める
    set virtualedit=block

    " ----------------------------------------
    " 表示
    " ----------------------------------------
    " 行番号表示
    set number
    " 現在の行をハイライトする
    set cursorline
    " タイトルの表示
    set title
    " タブストップ
    set tabstop=2
    " シフト幅
    set shiftwidth=2
    " 全角文字
    set ambiwidth=double
    " シンタックスハイライト
    syntax on
    " 対応するカッコやブレースを表示
    set showmatch matchtime=1
    " メッセージ表示欄2行
    set cmdheight=2
    " ステータス行を常に表示
    set laststatus=2
    " 行末のスペースの可視化
    set listchars=tab:^\ ,trail:~
    " コメントを水色で表示
    hi Comment ctermfg=3
    " 検索結果をハイライト表示
    set hlsearch
    " 単語の途中で折り返さないようにする
    set linebreak
    " 折返しの表示
    set showbreak=>>>
    " シンタックスに基づいて折りたたみを設定する
    set foldmethod=syntax

    " ----------------------------------------
    " HTML/XML閉じタグ自動補完
    " ----------------------------------------
    augroup htmlXmlAutoClose
      autocmd!
      autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o>
      autocmd Filetype html inoremap <buffer> </ </<C-x><C-o>
    augroup END

    " ----------------------------------------
    " nnoremap(pluginに関わるものを除く)
    " ----------------------------------------
    " <leader>wに<C-w>を割り当て(window操作用)
    nnoremap <leader>w <C-w>

    " ----------------------------------------
    " tnoremap(pluginに関わるものを除く)
    " ----------------------------------------
    " Escでノーマルモード
    tnoremap <Esc> <C-w>N

    " ----------------------------------------
    " 独自コマンド
    " ----------------------------------------
    command! Vterm vert term

    " ----------------------------------------
    " plugins(general)
    " ----------------------------------------
    filetype plugin indent on

    " ----------------------------------------
    " plugins(airline)
    " ----------------------------------------
    " themeをsolarized darkに設定
    let g:airline_theme='solarized'
    let g:airline_solarized_bg='dark'
    " powerline-fonts有効化
    let g:airline_powerline_fonts=1

    " ----------------------------------------
    " plugins(nerdtree)
    " ----------------------------------------
    " <leader>nでNERDTreeにフォーカスする
    nnoremap <leader>n :NERDTreeFocus<CR>
    " <C-t>でNERDTreeをトグルする
    nnoremap <C-t> :NERDTreeToggle<CR>

    " ----------------------------------------
    " plugins(nerdtree-git-plugin)
    " ----------------------------------------
    " nerdfontsのpredefined mapを使う
    let g:NERDTreeGitStatusUseNerdFonts = 1
    " ignoredファイルを表示する
    let g:NERDTreeGitStaatusShowIgnored = 1

    " ----------------------------------------
    " plugins(barbar.nvim)
    " ----------------------------------------
    " 前後のバッファへ移動
    nnoremap <silent> <A-,> <Cmd>BufferPrevious<CR>
    nnoremap <silent> <A-.> <Cmd>BufferNext<CR>

    " 指定位置のバッファへ移動
    nnoremap <silent> <A-1> <Cmd>BufferGoto 1<CR>
    nnoremap <silent> <A-2> <Cmd>BufferGoto 2<CR>
    nnoremap <silent> <A-3> <Cmd>BufferGoto 3<CR>
    nnoremap <silent> <A-4> <Cmd>BufferGoto 4<CR>
    nnoremap <silent> <A-5> <Cmd>BufferGoto 5<CR>
    nnoremap <silent> <A-6> <Cmd>BufferGoto 6<CR>
    nnoremap <silent> <A-7> <Cmd>BufferGoto 7<CR>
    nnoremap <silent> <A-8> <Cmd>BufferGoto 8<CR>
    nnoremap <silent> <A-9> <Cmd>BufferGoto 9<CR>
    " 末尾のバッファへ移動
    nnoremap <silent> <A-0> <Cmd>BufferLast<CR>
  '';
}
