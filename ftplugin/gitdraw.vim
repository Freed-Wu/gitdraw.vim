setlocal nocursorcolumn
setlocal nocursorline
setlocal textwidth=106

command! -buffer -nargs=? -complete=customlist,gitdraw#complete Template call gitdraw#template(<f-args>)
command! -buffer -nargs=? -complete=customlist,gitdraw#complete Compile call gitdraw#compile(<f-args>)
command! -buffer -nargs=? Clean call gitdraw#clean(<f-args>)
command! -buffer -nargs=? Upload call gitdraw#upload(<f-args>)

nnoremap <plug>gitdraw-add ylv"=gitdraw#add(@0)<CR>p
nnoremap <plug>gitdraw-delete ylv"=gitdraw#delete(@0)<CR>p
nmap <buffer> <C-a> <plug>gitdraw-add
nmap <buffer> <C-x> <plug>gitdraw-delete

