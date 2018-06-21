syntax on

set nobackup
set noswapfile
set autoread
set hidden
set mouse=a

set number
set ruler
set cursorline

set autoindent
set tabstop=2
set shiftwidth=2
set expandtab
set softtabstop=2
set smarttab
set smartindent

set ambiwidth=double

set incsearch
set ignorecase
set smartcase
set hlsearch

set showcmd
set showmatch

set wildmenu
set history=5000

nnoremap j gj
nnoremap k gk

nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

colorscheme railscasts

" indent setting.
if &term =~ "xterm"
  let &t_SI .= "\e[?2004h"
  let &t_EI .= "\e[?2004l"
  let &pastetoggle = "\e[201~"

  function XTermPasteBegin(ret)
    set paste
    return a:ret
  endfunction

  inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif

" Terraform
"let g:terraform_align=1
"let g:terraform_fold_sections=1
"let g:terraform_remap_spacebar=1
let g:terraform_fmt_on_save=1

"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shugo/dein.vim'
let s:toml_dir = expand('~/.config/nvim')
let s:toml_file = s:toml_dir . '/dein.toml'
let g:python3_host_prog = expand('/usr/local/bin/python3')

if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  call dein#load_toml(s:toml_file, {'lazy': 0})
  call dein#end()
  call dein#save_state() 
endif

" Required:
filetype plugin indent on

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------
