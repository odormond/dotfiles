vim9script

# Python tooling
g:python_indent = {
  continue: 'shiftwidth()',
  open_paren: 'shiftwidth()',
  closed_paren_align_last_line: false,
}

def ShowRuffRule(): void
  var diag = lsp#diag#GetDiagByPos(bufnr(), line('.'), charcol('.'))
  if !diag->empty() && diag->has_key('source') && diag.source == 'Ruff'
    var code = diag['code']
    var explanation = systemlist("ruff rule " .. code)
    popup_atcursor(
      lsp#markdown#ParseMarkdown(explanation).content, {maxwidth: 80, padding: [0, 1, 0, 1]}
    )
  else
    echo "No ruff diagnostic found"
  endif
enddef

def PythonJump(mode: string, motion: string, flags: string, count: number, startofline=true): void
    if mode == 'x'
        normal! gv
    endif

    if startofline
        normal! 0
    endif

    mark '
    var cnt = count
    while cnt > 0
        search(motion, flags)
        cnt = cnt - 1
    endwhile

    if startofline
        normal! ^
    endif
enddef

setlocal makeprg=ruff\ check\ --output-format\ concise\ --config\ ~/.ruff.toml\ --fix\ %

nnoremap <silent><buffer> <leader>r :<C-U>vim9 <SID>ShowRuffRule()<CR>
# previous and next function or class
nnoremap <silent><buffer> [[ :<C-U>call <SID>PythonJump('n', '\v^\s*<((async )?def\|class)>', 'Wb', v:count1)<CR>
onoremap <silent><buffer> [[ :call <SID>PythonJump('n', '\v^\s*<((async )?def\|class)>', 'Wb', v:count1)<CR>
xnoremap <silent><buffer> [[ :call <SID>PythonJump('n', '\v^\s*<((async )?def\|class)>', 'Wb', v:count1)<CR>
nnoremap <silent><buffer> ]] :<C-U>call <SID>PythonJump('n', '\v^\s*<((async )?def\|class)>', 'W', v:count1)<CR>
onoremap <silent><buffer> ]] :call <SID>PythonJump('n', '\v^\s*<((async )?def\|class)>', 'W', v:count1)<CR>
xnoremap <silent><buffer> ]] :call <SID>PythonJump('n', '\v^\s*<((async )?def\|class)>', 'W', v:count1)<CR>
# previous and next function only
nnoremap <silent><buffer> [d :<C-U>call <SID>PythonJump('n', '\v^\s*<(async )?def>', 'Wb', v:count1)<CR>
onoremap <silent><buffer> [d :call <SID>PythonJump('n', '\v^\s*<(async )?def>', 'Wb', v:count1)<CR>
xnoremap <silent><buffer> [d :call <SID>PythonJump('n', '\v^\s*<(async )?def>', 'Wb', v:count1)<CR>
nnoremap <silent><buffer> ]d :<C-U>call <SID>PythonJump('n', '\v^\s*<(async )?def>', 'W', v:count1)<CR>
onoremap <silent><buffer> ]d :call <SID>PythonJump('n', '\v^\s*<(async )?def>', 'W', v:count1)<CR>
xnoremap <silent><buffer> ]d :call <SID>PythonJump('n', '\v^\s*<(async )?def>', 'W', v:count1)<CR>
# previous and next class only
nnoremap <silent><buffer> [c :<C-U>call <SID>PythonJump('n', '\v^\s*<class>', 'Wb', v:count1)<CR>
onoremap <silent><buffer> [c :call <SID>PythonJump('n', '\v^\s*<class>', 'Wb', v:count1)<CR>
xnoremap <silent><buffer> [c :call <SID>PythonJump('n', '\v^\s*<class>', 'Wb', v:count1)<CR>
nnoremap <silent><buffer> ]c :<C-U>call <SID>PythonJump('n', '\v^\s*<class>', 'W', v:count1)<CR>
onoremap <silent><buffer> ]c :call <SID>PythonJump('n', '\v^\s*<class>', 'W', v:count1)<CR>
xnoremap <silent><buffer> ]c :call <SID>PythonJump('n', '\v^\s*<class>', 'W', v:count1)<CR>
