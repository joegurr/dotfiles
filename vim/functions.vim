" Replace NERDTree
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
let g:NetrwIsOpen=0

function! ToggleNetrw()
    if g:NetrwIsOpen
        let i = bufnr("$")
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                silent exe "bwipeout " . i
            endif
            let i-=1
        endwhile
        let g:NetrwIsOpen=0
    else
        let g:NetrwIsOpen=1
        silent Lexplore
    endif
endfunction

noremap <F2> :call ToggleNetrw()<CR>

" Blog template
function! CreateBlogHTMLTemplate()
    call append(0, [
        \ '<!DOCTYPE html>',
        \ '<html lang="en">',
        \ '',
        \ '<head>',
        \ '  <meta charset="UTF-8" />',
        \ '  <meta name="viewport" content="width=device-width, initial-scale=1.0" />',
        \ '  <title>TITLE</title>',
        \ '  <link rel="stylesheet" href="../style.css" />',
        \ '  <link rel="alternate" type="application/rss+xml" title="Joe Gurr RSS Feed" href="https://www.joegurr.com/feed.xml">',
        \ '</head>',
        \ '',
        \ '<body>',
        \ '  <header>',
        \ '    <h1>',
        \ '      <a href="/" rel="home">Joe Gurr</a>',
        \ '    </h1>',
        \ '  </header>',
        \ '  <main>',
        \ '    <h3>TITLE</h3>',
        \ '  </main>',
        \ '  <footer></footer>',
        \ '</body>',
        \ '',
        \ '</html>',
        \ ])
endfunction

command! Blog :call CreateBlogHTMLTemplate()

" Extend ,n
" Needs testing
function! OpenNoteForDay(offset)
  " Get the current buffer's file path
  let l:current_file = expand('%:p')

  " Get the path to the notes directory from an environment variable
  let l:notes_dir = expand('$NOTES_DIR')

  if empty(l:notes_dir)
    let l:notes_dir = expand('~/.Documents/notes')
  endif

  " Expand the notes directory to make sure it's absolute
  let l:notes_dir = expand(l:notes_dir)

  " Debugging: Print the current file and notes directory
  " echo "Current file: " . l:current_file
  " echo "Notes directory: " . l:notes_dir

  " Extract the filename (2024-11-05.md)
  let l:filename = fnamemodify(l:current_file, ':t')

  " Debugging: Print the filename
  " echo "Filename: " . l:filename

  " Construct the regex pattern to match the date in the filename (e.g., 2024-11-05.md)
  let l:notes_pattern = '\v(\d{4})-(\d{2})-(\d{2})\.md$'

  " Debugging: Print the regular expression pattern
  " echo "Notes pattern: " . l:notes_pattern

  " Check if the current buffer's filename matches the note file pattern
  let l:date_parts = matchlist(l:filename, l:notes_pattern)

  " If the pattern doesn't match, output an error
  if len(l:date_parts) == 0
    echo "Current buffer is not a valid note file."
    return
  endif

  " Extract the date from the current buffer's filename
  let l:year = str2nr(l:date_parts[1])
  let l:month = str2nr(l:date_parts[2])
  let l:day = str2nr(l:date_parts[3])

  " Calculate the new date based on the offset
  let l:new_day = l:day + a:offset
  let l:new_month = l:month
  let l:new_year = l:year

  " Normalize the date (this is a simple way to move through months)
  while l:new_day < 1
    let l:new_day += 31
    let l:new_month -= 1
    if l:new_month < 1
      let l:new_month = 12
      let l:new_year -= 1
    endif
  endwhile

  while l:new_day > 31
    let l:new_day -= 31
    let l:new_month += 1
    if l:new_month > 12
      let l:new_month = 1
      let l:new_year += 1
    endif
  endwhile

  " Build the new file path
  let l:new_file = printf('%s/%04d-%02d-%02d.md', l:notes_dir, l:new_year, l:new_month, l:new_day)

  " Open the new file
  execute 'edit ' . l:new_file
endfunction

command! -nargs=1 Note call OpenNoteForDay(<args>)

function! ShowDocumentation()
    if CocAction('hasProvider','hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K','in')
    endif
endfunction

nnoremap <silent> K :call ShowDocumentation()<CR>

" Scroll popup window, inspired by (stolen from):
" https://vi.stackexchange.com/a/40085
function! ScrollPopup(nlines)
    let winids = popup_list()
    if len(winids) == 0
        return
    endif

    " Ignore hidden popups
    let prop = popup_getpos(winids[0])
    if prop.visible != 1
        return
    endif

    let firstline = prop.firstline + a:nlines
    let buf_lastline = str2nr(trim(win_execute(winids[0], "echo line('$')")))
    if firstline < 1
        let firstline = 1
    elseif prop.lastline + a:nlines > buf_lastline
        let firstline = buf_lastline + prop.firstline - prop.lastline
    endif

    call popup_setoptions(winids[0], {'firstline': firstline})
endfunction

nnoremap <C-j> :call ScrollPopup(3)<CR>
nnoremap <C-k> :call ScrollPopup(-3)<CR>

