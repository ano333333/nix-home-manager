{
  pkgs,
  ...
}: 
with pkgs.vimPlugins; [
  vim-airline
  vim-airline-themes
  vim-devicons
  fzf-lua
  vim-gitgutter
  nerdtree
  nerdtree-git-plugin
]
