" Vim syntax file
" Language: VPoker
" Maintainer: Vinh Tran
" Latest Revision: 26 April 2010

setlocal foldmethod=marker
setlocal foldmarker=[,]
set foldtext=VPKFoldText()
  set fillchars=fold:\ "(there's a space after that \)
  highlight Folded ctermfg=White ctermbg=Black

function! VPKFoldText()
  let line = getline(v:foldstart)
  return line . " ... ]" 
endfunction

if exists("b:current_syntax")
  finish
endif

syntax clear
syn region  lineComment start='--' end='\n'
syn region  todoComment start='---#' end='\n'
syn region  colComment start='| --' end='|'

syn keyword headers Bet Action Round Hole Cards Flop Turn River Hand Preflop Betting Player Position Action Board
syn keyword betRound preflop flop turn river
syn keyword actionRound 1 2 3 4
syn keyword betting nobet check bet raise reraise fold bettor call continue check_or_fold apply
syn keyword handRank pair 1 2 pair possible draw two pairs trip set fullhouse quad straight flush cards card suited connected different
syn keyword playerCond player remain behind
syn keyword condition no not or

hi def link headers             Type
hi def link betRound            Constant
hi def link actionRound         Constant
hi def link betting             Constant
hi def link handRank            Constant
hi def link playerCond          Constant
hi def link lineComment         Comment
hi def link colComment          Comment
hi def link todoComment         Comment
hi def link condition           Statement
