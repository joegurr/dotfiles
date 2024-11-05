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
" needs testing
function! OpenNoteForDay(offset)
  " Get the current buffer's file path
  let l:current_file = expand('%:p')

  " Get the path to the notes directory from an environment variable
  let l:notes_dir = $NOTES_DIR
  if empty(l:notes_dir)
    let l:notes_dir = '~/Documents/notes'
  endif

  " Check if the current buffer is in the correct location
  if l:current_file =~ printf('%s/\d\{4}-\d\{2}-\d\{2}\.md$', l:notes_dir)
    " Extract the date from the current buffer's filename
    let l:date_parts = matchlist(l:current_file, printf('%s/\(\d\{4}\)-\(\d\{2}\)-\(\d\{2}\)\.md$', l:notes_dir))
    let l:year = str2nr(l:date_parts[1])
    let l:month = str2nr(l:date_parts[2])
    let l:day = str2nr(l:date_parts[3])

    " Calculate the new date based on the offset
    let l:new_day = l:day + a:offset
    let l:new_month = l:month
    let l:new_year = l:year

    " Normalize the date
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
  else
    echo "Current buffer is not a valid note file."
  endif
endfunction

command! -nargs=1 Note call OpenNoteForDay(<args>)
