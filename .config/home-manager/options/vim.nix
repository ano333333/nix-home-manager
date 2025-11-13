{
  vimPlugins,
  ...
}: 
{
  enable = true;
  defaultEditor = true;
  plugins = vimPlugins;
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
  '';
}
