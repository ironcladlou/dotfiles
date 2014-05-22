set nocompatible
filetype on
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'Lokaltog/vim-powerline'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'fatih/vim-go'
Plugin 'majutsushi/tagbar'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-easytags'
Plugin 'chriskempson/base16-vim'
Plugin 'scrooloose/syntastic'

call vundle#end()

syntax on
filetype plugin indent on

if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
  set t_Co=256
endif

" Color scheme
set background=dark
let base16colorspace=256
colorscheme base16-ocean

set smartindent
set tabstop=2
set shiftwidth=2
set expandtab

if has('gui_running')
  set guifont=Inconsolata\ Medium\ 11
  set guioptions-=m  "remove menu bar
  set guioptions-=T  "remove toolbar
  set guioptions-=r  "remove right-hand scroll bar
  set guioptions-=L  "remove left-hand scroll bar
  autocmd GUIEnter * set vb t_vb= " disable blinking
  set lines=63
  set columns=143
  
  vmap <C-c> "+yi
  vmap <C-v> c<ESC>"+p
  imap <C-v> <C-r><C-o>+
endif

" turn this stuff off since it's so damned slow
let loaded_matchparen = 1
set nocursorline

" other prefs
set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
"set cursorline
set ttyfast
set backspace=indent,eol,start
set laststatus=2
set noswapfile

" space leader
let mapleader=" "

" Prevent omnicomplete from selecting the first thing it finds
set completeopt+=longest

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" Movement won't skip wrapped lines
nmap j gj
nmap k gk

" Wrapping
set wrap
set textwidth=79
set formatoptions=qrn1

" Search setup
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
nnoremap <leader><space> :noh<cr>
nnoremap <tab> %
vnoremap <tab> %

if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  let g:ctrlp_use_caching = 0
endif

" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cwindow<CR>

" bind \ to grep shortcut
command! -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
nnoremap \ :Ag<SPACE>


" Training wheels
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" Easier mode key
nnoremap ; :

inoremap jj <ESC>

" Ctrl-P configuration
nmap ' :CtrlPBuffer<CR>
" let g:ctrlp_map = '<Leader>t'
let g:ctrlp_match_window_bottom = 0
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_dotfiles = 0
let g:ctrlp_switch_buffer = 0
let g:ctrlp_follow_symlinks = 1

" Nerdtree configuration
nmap t :NERDTreeToggle<CR>
let g:NERDTreeWinSize=26
let g:NERDTreeMouseMode=2

" Go bindings
au FileType go nmap gd <Plug>(go-def)
au FileType go nmap gb <Plug>(go-build)
au FileType go nmap <Leader>gd <Plug>(go-doc)
let g:go_auto_type_info = 1

" Tagbar configuration
nmap <leader>c :TagbarToggle<CR>

let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
    \ }
 
call xolox#easytags#map_filetypes('go', 'go')

" Easy split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

set splitbelow
set splitright


