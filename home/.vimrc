set nocompatible
filetype on
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'chriskempson/base16-vim'
"Plugin 'Lokaltog/vim-powerline'
"Plugin 'kien/ctrlp.vim'
"Plugin 'scrooloose/nerdtree'
"Plugin 'fatih/vim-go'
"Plugin 'majutsushi/tagbar'
"Plugin 'xolox/vim-misc'
"Plugin 'xolox/vim-easytags'
"Plugin 'scrooloose/syntastic'
"Plugin 'Valloric/YouCompleteMe'
"Plugin 'rbgrouleff/bclose.vim'
call vundle#end()

syntax on
filetype plugin indent on

if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
  set t_Co=256
endif

" Color scheme
set background=dark
colorscheme base16-default

set smartindent
set tabstop=2
set shiftwidth=2
set expandtab

if has('gui_running')
  set guifont=Monaco:h13
  set guioptions-=m  "remove menu bar
  set guioptions-=T  "remove toolbar
  set guioptions-=r  "remove right-hand scroll bar
  set guioptions-=L  "remove left-hand scroll bar
  autocmd GUIEnter * set vb t_vb= " disable blinking
  
  vmap <C-c> "+yi
  vmap <C-v> c<ESC>"+p
  imap <C-v> <C-r><C-o>+
endif

" turn this stuff off since it's so damned slow
" let loaded_matchparen=1
" set nocursorline

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
set ttyfast
set backspace=indent,eol,start
set laststatus=2
set noswapfile
set nu

set omnifunc=syntaxcomplete#Complete

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

" Easier mode key
nnoremap ; :

" Easier escape
inoremap jj <ESC>

noremap <C-W> :Bclose<CR>

" Ctrl-P configuration
nmap ' :CtrlPBuffer<CR>
nmap " :CtrlPBufTag<CR>
" let g:ctrlp_map = '<Leader>t'
let g:ctrlp_match_window_bottom = 0
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_dotfiles = 0
let g:ctrlp_switch_buffer = 0
let g:ctrlp_follow_symlinks = 1

let g:ctrlp_extensions = ['tag', 'buffertag']

let g:ctrlp_buftag_types = {
    \ 'go' : {
      \ 'bin': '/Users/dan/Projects/go/bin/gotags',
      \ 'args': '-sort -silent'
      \ }
    \ }

" Nerdtree configuration
nmap t :NERDTreeToggle<CR>
let g:NERDTreeWinSize=26
let g:NERDTreeMouseMode=2

" Go bindings
au FileType go nmap gd <Plug>(go-def)
au FileType go nmap gb <Plug>(go-build)
au FileType go nmap <Leader>gd <Plug>(go-doc)
let g:go_auto_type_info = 1

" Easytags
let g:easytags_cmd=''
let g:easytags_languages = {
      \   'go': {
      \     'cmd': '/Users/dan/Projects/go/bin/gotags',
      \       'args': ['-sort', '-silent'],
      \       'stdout_opt': '',
      \   }
      \}

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
 

" YouCompleteMe config
let g:ycm_auto_trigger = 0
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
set completeopt-=preview

" Easy split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

set splitbelow
set splitright


