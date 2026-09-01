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

# Folding
setlocal foldmethod=expr
setlocal foldexpr=g:GetPythonFold(v:lnum)
setlocal foldtext=g:PythonFoldText()

def g:PythonFoldText(): string
    var line = getline(v:foldstart)
    if line =~ '{{{ '
        return line .. ' }}}'
    endif
    var nnum = nextnonblank(v:foldstart + 1)
    var nextline = getline(nnum)
    if nextline =~ '^\s\+"""$'
        line = line .. getline(nnum + 1)
    elseif nextline =~ '^\s\+"""'
        line = line .. ' ' .. matchstr(nextline, '"""\zs.\{-}\ze\("""\)\?$')
    elseif nextline =~ '^\s\+"[^"]\+"$'
        line = line .. ' ' .. matchstr(nextline, '"\zs.*\ze"')
    elseif nextline =~ '^\s\+pass\s*$'
        line = line .. ' pass'
    endif
    return line
enddef

def g:GetPythonFold(lnum: number): string
    # Determine folding level in Python source
    var line = getline(lnum)
    var ind  = indent(lnum)

    # Ignore blank lines, triple quoted strings and continuation lines
    if line =~ '\(^\s*$\|"""\|''''''\|\\$\)'
        return "="
    endif

    # Support markers
    if line =~ '{{{'
        return "a1"
    elseif line =~ '}}}'
        return "s1"
    endif

    # Classes and functions get their own folds
    if line =~ '^\s*\(class\|\(async\s\+\)\?def\)\s'
        return ">" .. (ind / &sw + 1)
    endif

    var pnum = prevnonblank(lnum - 1)

    # Hit start of file
    if pnum == 0
        return "0"
    endif

    # If the previous line has foldlevel zero, and we haven't increased it,
    # we should have foldlevel zero also
    if foldlevel(pnum) == 0
        return "0"
    endif

    # The end of a fold is determined through a difference in indentation
    # between this line and the next.
    # So first look for next line
    var nnum = nextnonblank(lnum + 1)
    if nnum == 0
        return "="
    endif

    # First I check for some common cases where this algorithm would
    # otherwise fail. (This is all a hack)
    #var nline = getline(nnum)
    #if nline =~ '^\s*\(except\|else\|elif\)'
    #    return "="
    #endif

    # Python programmers love their readable code, so they're usually
    # going to have blank lines at the ends of functions or classes
    # If the next line isn't blank, we probably don't need to end a fold
    if nnum == lnum + 1
        return "="
    endif

    # If next line has less indentation we end a fold.
    # This ends folds that aren't there a lot of the time, and this sometimes
    # confuses vim.  Luckily only rarely.
    var nind = indent(nnum)
    if nind < ind
        return "<" .. (nind / &sw + 1)
    endif

    # If none of the above apply, keep the indentation
    return "="
enddef
