let s:nr_max = len(g:gitdraw#convert_rule) - 1
let g:gitdraw#template_dir = get(g:, 'g:gitdraw#template_dir', expand('<sfile>:p:h:h') .. '/template')
let g:gitdraw#repeat_number = get(g:, 'gitdraw#repeat_number', 1)
let g:gitdraw#author_name = get(g:, 'gitdraw#author_name', executable('git') ?
			\ trim(system('git config --global user.name')) :
			\ expand('$USER'))
let g:gitdraw#repo_path = get(g:, 'gitdraw#repo_path', '~/.vim/repos/' .. g:gitdraw#author_name .. '/git-drawing')
let g:gitdraw#website = get(g:, 'gitdraw#website', 'git@github.com:' .. g:gitdraw#author_name .. '/git-drawing')
let g:gitdraw#origin_name = get(g:, 'gitdraw#origin_name', 'origin')
let g:gitdraw#import_files = get(g:, 'gitdraw#import_files', [g:gitdraw#template_dir .. '/README.md', g:gitdraw#template_dir .. '/../LICENSE'])
let g:gitdraw#commit_message = get(g:, 'gitdraw#commit_message', 'gitdraw')
let g:gitdraw#isupload = get(g:, 'gitdraw#isupload', 1)

function! gitdraw#clean(...) abort
	if a:0
		let l:file = a:1
	else
		let l:file = g:gitdraw#repo_path
	endif
	call delete(g:gitdraw#repo_path, 'rf')
endfunction

function! gitdraw#complete(arglead, cmdline, cursorpos) abort
	return filter(
				\ map(
				\ glob(g:gitdraw#template_dir .. '/*.gitdraw', 0, 1),
				\ {_, v -> fnamemodify(v, ':t:r')}
				\ ),
				\ {_, v -> v =~ '^' .. a:arglead}
				\ )
endfunction

function! gitdraw#template(...) abort
	if a:0
		let l:file = g:gitdraw#template_dir .. '/' .. a:1 .. '.gitdraw'
	else
		let l:file = g:gitdraw#template_dir .. '/main.gitdraw'
	endif
	execute '0read' l:file
	setlocal syntax=gitdraw
endfunction

function! gitdraw#compile(...) abort
	if a:0
		let l:file = g:gitdraw#template_dir .. '/' .. a:1
	else
		let l:file = expand('%:p')
	endif
	let l:content = readfile(l:file)[0:6]

	call gitdraw#clean(g:gitdraw#repo_path)
	call system(join(['git init', g:gitdraw#repo_path]))
	execute 'cd' g:gitdraw#repo_path
	for l:import_file in g:gitdraw#import_files
		call gitdraw#import(l:import_file)
	endfor
	call gitdraw#import(l:file)
	let l:file_name = fnamemodify(l:file, ':t')

	for l:weeknr in range(53)
		for l:weekday in range(7)
			let l:time = strftime('%Y-%m-%dT12:00:00', localtime() - (strftime('%w') + (52 - l:weeknr) * 7 - l:weekday) * 24 * 60 * 60)
			let l:nr = gitdraw#char2nr(gitdraw#getchar(l:content, l:weekday, l:weeknr))
			for l:commitnr in range(gitdraw#commit_number(l:nr, g:gitdraw#repeat_number))
				call writefile(gitdraw#content(l:content, l:weeknr, l:weekday, l:commitnr), l:file_name)
				call setenv('GIT_AUTHOR_DATE', l:time)
				call setenv('GIT_COMMITTER_DATE', l:time)
				call system(join(['git commit -a -m', shellescape(g:gitdraw#commit_message)]))
			endfor
		endfor
	endfor

	if g:gitdraw#isupload
		call gitdraw#upload()
	endif
endfunction

function! gitdraw#commit_number(nr, repeat_number) abort
	return max([0, (a:nr - 1) * a:repeat_number + 1])
endfunction

function! gitdraw#upload(...) abort
	if a:0
		execute 'cd' a:1
	else
		execute 'cd' g:gitdraw#repo_path
	endif

	call system(join(['git remote add', g:gitdraw#origin_name, g:gitdraw#website]))
	call system(join(['git push -uf', g:gitdraw#origin_name, 'master']))
endfunction

function! gitdraw#import(file_path) abort
	if empty(a:file_path)
		return
	endif
	let l:file_name = fnamemodify(a:file_path, ':t')
	call writefile(readfile(a:file_path), l:file_name)
	call system(join(['git add', l:file_name]))
endfunction

function! gitdraw#getchar(content, weekday, weeknr) abort
	return split(a:content[a:weekday], '\zs')[a:weeknr]
endfunction

function! gitdraw#content(content, weeknr, weekday, commitnr) abort
	return a:content + [join([a:weeknr, a:weekday, a:commitnr], ' ')]
endfunction

function! gitdraw#add(char) abort
	return gitdraw#nr2char(min([gitdraw#char2nr(a:char) + 1, s:nr_max]))
endfunction

function! gitdraw#delete(char) abort
	return gitdraw#nr2char(max([gitdraw#char2nr(a:char) - 1, 0]))
endfunction

function! gitdraw#char2nr(char) abort
	try
		return g:gitdraw#convert_rule[a:char].convert_number
	catch /^Vim\%((\a\+)\)\=:E716:/
		call s:warn('No number! Please check your g:gitdraw#convert_rule.')
	endtry
endfunction

function! gitdraw#nr2char(nr) abort
	for [l:char, l:val] in items(g:gitdraw#convert_rule)
		let l:nr = l:val.convert_number
		if l:nr == a:nr
			return l:char
		endif
	endfor
	call s:warn('No character! Please check your g:gitdraw#convert_rule.')
endfunction

function! gitdraw#dotfont() abort
	return str2nr(
				\ join(
				\ map(
				\ map(
				\ getline(1, '$'),
				\ {_, val -> map(split(val, '\zs'), {_, v -> gitdraw#char2nr(v)})}
				\ ),
				\ {_, v -> gitdraw#dotfont_map(v)}
				\ ),
				\ ''),
				\ 2)
endfunction

function! s:warn(msg) abort
	echohl WarningMsg
	echomsg 'gitdraw:' a:msg
	echohl NONE
endfunction

" vim:set noet sts=0 sw=8 ts=8 tw=77 fdm=syntax:
