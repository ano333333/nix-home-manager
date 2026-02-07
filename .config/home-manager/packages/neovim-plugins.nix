{ pkgs, pkgs-yazi, ... }:
with pkgs.vimPlugins;
[
  lualine-nvim
  vim-devicons
  fzf-lua
  gitsigns-nvim
  tint-nvim
  nvim-web-devicons
  barbar-nvim
  nvim-autopairs
  nvim-lspconfig
  quicker-nvim
  typescript-tools-nvim
  comment-nvim
  vim-sandwich
  (nvim-treesitter.withPlugins (p: [
    p.lua
    p.go
    p.rust
    p.nix
    p.typescript
    p.javascript
    p.tsx
    p.html
    p.svelte
  ]))
  nvim-treesitter-textobjects
  nvim-treesitter-context
  rainbow-delimiters-nvim
  indent-blankline-nvim
  nvim-ts-autotag
  blink-cmp
  trouble-nvim
  conform-nvim
  todo-comments-nvim
] ++ (with pkgs-yazi.vimPlugins; [ yazi-nvim ])
