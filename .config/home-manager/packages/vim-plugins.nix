{
  pkgs,
  ...
}: 
with pkgs.vimPlugins; [
  vim-sensible
  vim-airline
  vim-airline-themes
  vim-devicons
  fzf-vim
]
