vim9script noclear
# Vim global plugin for dragging virtual blocks
# Initially written by Damian Conway and eventually rewritten in vim9script by Olivier Dormond
# License:	This file is placed in the public domain.

#########################################################################
##                                                                     ##
##  Add the following (uncommented) to your .vimrc...                  ##
##                                                                     ##
##     runtime plugin/dragvisuals.vim                                  ##
##                                                                     ##
##     vnoremap  <LEFT>   <ScriptCmd>g:DVB_Drag('left')<CR>            ##
##     vnoremap  <RIGHT>  <ScriptCmd>g:DVB_Drag('right')<CR>           ##
##     vnoremap  <DOWN>   <ScriptCmd>g:DVB_Drag('down')<CR>            ##
##     vnoremap  <UP>     <ScriptCmd>g:DVB_Drag('up')<CR>              ##
##     vnoremap  D        <ScriptCmd>g:DVB_Duplicate()<CR>             ##
##                                                                     ##
##     " Remove any introduced trailing whitespace after moving...     ##
##     let g:DVB_TrimWS = 1                                            ##
##                                                                     ##
#########################################################################


# If already loaded, we're done...
if exists("g:loaded_dragvirtualblocks")
    finish
endif
g:loaded_dragvirtualblocks = 1

# Preserve external compatibility options, then enable full vim compatibility...
var save_cpo = &cpo
set cpo&vim

#====[ Implementation ]====================================

# Toggle this to stop trimming on drags...
if !exists('g:DVB_TrimWS')
    g:DVB_TrimWS = 1
endif

def g:DVB_Drag(dir: string)
    # No-op in Visual mode
    if mode() ==# "v"
        return
    endif

    # Visual Line drag or visual block drag
    DVB_wrapper(mode() ==# 'V' ? () => Drag_Lines(dir) : () => Drag_Block(dir))
enddef

# Duplicate selected block and place to the right...
def g:DVB_Duplicate()
    DVB_wrapper(() => Duplicate_Block())
enddef

def DVB_wrapper(Fn: func(): string)
    var saved_report = &report
    var saved_reg_v = @v
    var saved_virtualedit = &virtualedit

    # Silent reporting count of changed lines
    &report = 1000000000

    # Ensure cursor is on the right so we can properly square up the selection.
    var [_, _, start_col, start_offset] = getpos("v")
    var [_, _, cursor_col, cursor_offset] = getpos(".")
    var swap_start_and_cursor = start_col + start_offset > cursor_col + cursor_offset
    if swap_start_and_cursor
        normal! o
    endif

    # Capture visual selection into register. This force updates the marks '< and '>.
    # In bloc mode, it is used to find the actual size of the block as $ can extend it beyond the
    # cursor position.
    normal! "vy

    var seq = Fn()
    exec "silent normal! " .. seq

    nohlsearch

    # Restore stuffs
    if swap_start_and_cursor
        normal! o
    endif
    &virtualedit = saved_virtualedit
    @v = saved_reg_v
    &report = saved_report
enddef

# Drag in specified direction in Visual Line mode...
def Drag_Lines(dir: string): string
    # Locate block being shifted...
    var [_, line_left,  col_left,  offset_left ] = getpos("'<")
    var [_, line_right, col_right, offset_right] = getpos("'>")

    if dir == 'left'
        # Are all lines indented at least one space???
        var lines        = getline(line_left, line_right)
        var all_indented = match(lines, '^[^ ]') == -1

        # Drag left by removing one space from start of each line unless a line is not indented.
        return all_indented ? ":'<,'>s/^ //\<CR>gv" : "gv"

    elseif dir == 'right'
        return ":'<,'>s/^/ /\<CR>gv"

    elseif dir == 'up'
        # Can't drag up if at first line...
        if line_left == 1 || line_right == 1
            return "gv"
        endif

        # This is how much extra we're going to have to reselect...
        var height = line_right - line_left
        var select_extra = height > 0 ? height .. 'j' : ""
        # Needs special handling at EOF (because cursor moves up on delete)...
        var EOF = line('$')
        return "gv" .. (line_left == EOF || line_right == EOF ? "xP" : "xkP") .. "V" .. select_extra

    elseif dir == 'down'
        # This is how much extra we're going to have to reselect...
        var height = line_right - line_left
        var select_extra = height > 0 ? height .. 'j' : ""

        # Needs special handling at EOF (to push selection down into new space)...
        var EOF = line('$')
        if line_left == EOF || line_right == EOF
            return "O\<ESC>gv"

        # Otherwise, just cut-move-paste-reselect...
        else 
            return "gvxpV" .. select_extra
        endif

    # Unknown direction
    else
        echoerr "Invalid argument: " .. dir .. ". Allowed values are 'left', 'right', 'up' and 'down'"
        return "gv"
    endif
enddef

# Drag in specified direction in Visual Block mode...
def Drag_Block(dir: string): string
    # Locate block being shifted...
    var [_, line_left,  col_left,  offset_left ] = getpos("'<")
    var [_, line_right, col_right, offset_right] = getpos("'>")

    # Can't drag upwards at top margin or left at left margin.
    if (dir == 'up' && (line_left == 1 || line_right == 1))
        || (dir == 'left' && (col_left == 1 || col_right == 1))
        return "gv"
    endif

    var [start_col, visual_width, dollar_block, square_up] = Size_Block(col_left, offset_left, col_right, offset_right)

    var initial_trim_ws = g:DVB_TrimWS ? ":'<,'>s/\\s*$//\<CR>" : ""
    var final_trim_ws = g:DVB_TrimWS ? ":s/\\s*$//\<CR>gv" : ""
    # May need to be able to temporarily step past EOL...
    set virtualedit=all

    var key = {"left": "h", "right": "l", "up": "k", "down": "j"}[dir]
    return square_up .. "x" .. key .. "P" .. initial_trim_ws .. square_up .. key .. "o" .. key .. "o" .. final_trim_ws
enddef

def Duplicate_Block(): string
    var [_, _, col_left,  offset_left ] = getpos("'<")
    var [_, _, col_right, offset_right] = getpos("'>")

    var [start_col, visual_width, dollar_block, square_up] = Size_Block(col_left, offset_left, col_right, offset_right)
    visual_width -= dollar_block
    set virtualedit=all
    return square_up .. 'yPgv' .. visual_width .. 'lo' .. visual_width .. 'loygv' .. (dollar_block ? 'o$' : '')
enddef

def Size_Block(col_left: number, offset_left: number, col_right: number, offset_right: number): list<any>
    # Identify special '$' blocks...
    var dollar_block = 0
    var start_col    = min([col_left + offset_left, col_right + offset_right])
    var end_col      = max([col_left + offset_left, col_right + offset_right])
    var visual_width = end_col - start_col + 1
    for visual_line in split(getreg("v"), "\n")
        if strlen(visual_line) > visual_width
            dollar_block = 1
            visual_width = strlen(visual_line)
        endif
    endfor
    var square_up = "gv" .. (start_col + visual_width - 1 - dollar_block) .. "|"
    return [start_col, visual_width, dollar_block, square_up]
enddef

# Restore previous external compatibility options
&cpo = save_cpo
