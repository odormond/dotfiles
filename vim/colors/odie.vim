" Vim color file
" Maintainer:   Olivier Dormond <olivier.dormond@gmail.com>
" Last Change:  2013-03-03
" URL:      

" cool help screens
" :he group-name
" :he highlight-groups
" :he cterm-colors

" your pick:
set background=dark " or light
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="odie"

hi Normal gui=NONE guibg=#000000 ctermbg=0 guifg=#dadada ctermfg=7
hi ColorColumn gui=NONE guibg=#1c1c1c ctermbg=234 guifg=NONE ctermfg=NONE

" A good way to see what your colorscheme does is to follow this procedure:
" :w 
" :so % 
"
" Then to see what the current setting is use the highlight command.  
" For example,
"   :hi Cursor
" gives
"   Cursor         xxx guifg=bg guibg=fg 
    
" Uncomment and complete the commands you want to change from the default.

"hi Cursor        gui=NONE  guifg=NONE  guibg=NONE
"hi CursorIM      gui=NONE  guifg=NONE  guibg=NONE
"hi Directory     gui=NONE  guifg=NONE  guibg=NONE
"hi DiffAdd       gui=NONE  guifg=NONE  guibg=NONE
"hi DiffChange    gui=NONE  guifg=NONE  guibg=NONE
"hi DiffDelete    gui=NONE  guifg=NONE  guibg=NONE
"hi DiffText      gui=NONE  guifg=NONE  guibg=NONE
"hi ErrorMsg      gui=NONE  guifg=NONE  guibg=NONE
"hi VertSplit     gui=NONE  guifg=NONE  guibg=NONE
"hi FoldColumn    gui=NONE  guifg=NONE  guibg=NONE
"hi IncSearch     gui=NONE  guifg=NONE  guibg=NONE
hi LineNr        gui=NONE cterm=NONE guifg=#6c6c6c ctermfg=242 guibg=NONE ctermbg=NONE
hi MatchParen    gui=NONE cterm=bold guifg=#000000 ctermfg=0 guibg=#8a8a8a ctermbg=245
"hi ModeMsg       gui=NONE  guifg=NONE  guibg=NONE
"hi MoreMsg       gui=NONE  guifg=NONE  guibg=NONE
"hi NonText       gui=NONE  guifg=NONE  guibg=NONE
"hi Question      gui=NONE  guifg=NONE  guibg=NONE
hi Search        gui=NONE cterm=NONE guifg=NONE ctermfg=NONE guibg=#444444 ctermbg=238
hi SearchHl      gui=NONE cterm=NONE guifg=NONE ctermfg=NONE guibg=#808080 ctermbg=244
"hi SpecialKey    gui=NONE  guifg=NONE  guibg=NONE
"hi StatusLine    gui=NONE  guifg=NONE  guibg=NONE
"hi StatusLineNC  gui=NONE  guifg=NONE  guibg=NONE
"hi Title         gui=NONE  guifg=NONE  guibg=NONE
"hi Visual        gui=NONE  guifg=NONE  guibg=NONE
"hi VisualNOS     gui=NONE  guifg=NONE  guibg=NONE
"hi WarningMsg    gui=NONE  guifg=NONE  guibg=NONE
hi WildMenu      gui=bold cterm=bold guifg=black ctermfg=16 guibg=#00d7ff ctermbg=45
"hi Menu          gui=NONE  guifg=NONE  guibg=NONE
"hi Scrollbar     gui=NONE  guifg=NONE  guibg=NONE
"hi Tooltip       gui=NONE  guifg=NONE  guibg=NONE
hi Folded        gui=NONE cterm=NONE guifg=#00ffff ctermfg=11   guibg=NONE    ctermbg=NONE

hi Pmenu         gui=NONE cterm=NONE guifg=#bcbcbc ctermfg=250  guibg=#1c1c1c ctermbg=234
hi PmenuSel      gui=bold cterm=bold guifg=#c6c6c6 ctermfg=251  guibg=#262626 ctermbg=235
hi PmenuSBar     gui=NONE cterm=NONE guifg=NONE    ctermfg=NONE guibg=#000087 ctermbg=18
hi PmenuThumb    gui=NONE cterm=NONE guifg=#0000ff ctermfg=21   guibg=NONE    ctermbg=NONE

" syntax highlighting groups   
hi Comment       gui=NONE cterm=NONE guifg=#87afff ctermfg=111 guibg=NONE ctermbg=NONE
hi Constant      gui=NONE cterm=NONE guifg=#ffafaf ctermfg=217 guibg=NONE ctermbg=NONE
"hi Error         gui=NONE cterm=NONE guifg=NONE  guibg=NONE
hi Identifier    gui=NONE cterm=NONE guifg=#5fffff ctermfg=87  guibg=NONE ctermbg=NONE
"hi Ignore        gui=NONE cterm=NONE guifg=NONE  guibg=NONE
hi Operator      gui=NONE cterm=NONE guifg=#87ff87 ctermfg=120 guibg=NONE ctermbg=NONE
hi PreProc       gui=NONE cterm=NONE guifg=#ff87ff ctermfg=213 guibg=NONE ctermbg=NONE
hi Type          gui=NONE cterm=NONE guifg=#5fff5f ctermfg=83  guibg=NONE ctermbg=NONE
hi Special       gui=NONE cterm=NONE guifg=#ff5f00 ctermfg=202 guibg=NONE ctermbg=NONE
hi Statement     gui=NONE cterm=NONE guifg=#ffff5f ctermfg=227 guibg=NONE ctermbg=NONE
"hi Todo          gui=NONE cterm=NONE guifg=NONE  guibg=NONE
"hi Underlined    gui=NONE cterm=NONE guifg=NONE  guibg=NONE

hi ShowMarksHLl gui=NONE cterm=NONE ctermbg=242 ctermfg=0
hi ShowMarksHLu gui=NONE cterm=NONE ctermbg=242 ctermfg=0
hi ShowMarksHLo gui=NONE cterm=NONE ctermbg=242 ctermfg=0
hi ShowMarksHLm gui=NONE cterm=NONE ctermbg=242 ctermfg=15

" 256 color terms use the following base componant values:
" 00, 5f, 87, af, d7, ff
" For the grayscale ramp:
" 08, 12, 1c, 26, 30, 3a, 44, 4e, 58, 62, 6c, 76, 80, 8a, 94, 9e, a8, b2, bc, c6, d0, da, e4, ee

