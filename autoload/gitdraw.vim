let s:nr_max = len(g:gitdraw#convert_rule) - 1
if !exists('g:gitdraw#template_dir')
	let g:gitdraw#template_dir = expand('<sfile>:p:h:h') . '/template'
endif
if !exists('gitdraw#repeat_number')
	let g:gitdraw#repeat_number = 1
endif
if !exists('gitdraw#repo_path')
	let g:gitdraw#repo_path = 'git-drawing'
endif

function! gitdraw#clean(...) abort
	if a:0 == 0
		let l:file = g:gitdraw#repo_path
	else
		let l:file = a:1
	endif
	call delete(g:gitdraw#repo_path, 'rf')
endfunction

function! gitdraw#complete(arglead, cmdline, cursorpos) abort
	let l:paths = split(glob(g:gitdraw#template_dir.'/*.gitdraw'))
	let l:files = []
	for l:path in l:paths
		let l:files += [split(split(l:path, '/')[-1], '\.gitdraw')[0]]
	endfor
	return l:files
endfunction

function! gitdraw#template(...) abort
	if a:0 == 0
		let l:file = g:gitdraw#template_dir . '/main.gitdraw'
	else
		let l:file = g:gitdraw#template_dir . '/' . a:1 . '.gitdraw'
	endif
	execute '0read ' . l:file
	setlocal syntax=gitdraw
endfunction

function! gitdraw#compile(...) abort
	if a:0 == 0
		let l:file = expand('%:p')
	else
		let l:file = g:gitdraw#template_dir . '/' . a:1
	endif
	let l:content = readfile(l:file)[0:6]
	let l:localtime = localtime()

	call gitdraw#clean(g:gitdraw#repo_path)
	call system('git init ' . g:gitdraw#repo_path)
	execute 'cd ' . g:gitdraw#repo_path
	for l:import_file in get(g:, 'gitdraw#import_files', [g:gitdraw#template_dir . '/README.md', g:gitdraw#template_dir . '/../LICENSE'])
		call gitdraw#import(l:import_file)
	endfor
	call gitdraw#import(l:file)
	let l:file_name = split(l:file, '/', 'gn')[-1]

	for l:weeknr in range(53)
		for l:weekday in range(7)
			let l:time = strftime('%Y-%m-%dT12:00:00', l:localtime - (strftime('%w') + (52 - l:weeknr) * 7 - l:weekday) * 24 * 60 * 60)
			let l:nr = gitdraw#char2nr(gitdraw#getchar(l:content, l:weekday, l:weeknr))
			for l:commitnr in range(gitdraw#commit_number(l:nr, g:gitdraw#repeat_number))
				call writefile(gitdraw#content(l:content, l:weeknr, l:weekday, l:commitnr), l:file_name)
				call system('GIT_AUTHOR_DATE=' . l:time . ' GIT_COMMITTER_DATE=' . l:time . ' git commit -a -m "' . get(g:, 'gitdraw#commit_message', 'gitdraw') . '"')
			endfor
		endfor
	endfor

	if get(g:, 'gitdraw#isupload', 1)
		call gitdraw#upload()
	endif
endfunction

function! gitdraw#commit_number(nr, repeat_number) abort
	return max([0, (a:nr - 1) * a:repeat_number + 1])
endfunction

function! gitdraw#upload(...) abort
	if a:0 == 0
		execute 'cd ' . g:gitdraw#repo_path
	else
		execute 'cd ' . a:1
	endif

	let l:origin = get(g:, 'gitdraw#origin_name', 'origin')
	call system('git remote add ' . l:origin . ' ' . get(g:, 'gitdraw#website', 'git@github.com:' . get(g:, 'gitdraw#author_name', executable('git') ? trim(system('git config --global user.name')) : expand('$USER')) . '/git-drawing.git'))
	call system('git push -uf ' . l:origin . ' master')
endfunction

function! gitdraw#import(file_path) abort
	if a:file_path ==# ''
		finish
	endif
	let l:file_name = split(a:file_path, '/', 'gn')[-1]
	call writefile(readfile(a:file_path), l:file_name)
	call system('git add ' . l:file_name)
endfunction

function! gitdraw#getchar(content, weekday, weeknr) abort
	return split(a:content[a:weekday], '\zs')[a:weeknr]
endfunction

function! gitdraw#content(content, weeknr, weekday, commitnr) abort
	return a:content + [join([a:weeknr, a:weekday, a:commitnr], ' ')]
endfunction

function! gitdraw#add(char) abort
	let l:nr = gitdraw#char2nr(a:char) + 1
	let l:nr = min([l:nr, s:nr_max])
	return gitdraw#nr2char(l:nr)
endfunction

function! gitdraw#delete(char) abort
	let l:nr = gitdraw#char2nr(a:char) - 1
	let l:nr = max([l:nr, 0])
	return gitdraw#nr2char(l:nr)
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

function! gitdraw#result() abort
	let l:nrss = []
	for l:i in range(1, line('$'))
		let l:chars = getline(l:i)
		let l:nrs = []
		for l:j in range(len(split(l:chars, '\zs')))
			let l:nrs += [gitdraw#char2nr(split(l:chars, '\zs')[l:j])]
		endfor
		let l:nrss += [l:nrs]
	endfor
	return l:nrss
endfunction

function! gitdraw#dotfont() abort
	let l:nrs = []
	for l:i in gitdraw#result()
		let l:nr = 0
		for l:j in l:i
			let l:nr = l:nr * 2 + l:j
		endfor
		let l:nrs += [l:nr]
	endfor
	return l:nrs
endfunction

function! s:warn(msg) abort
	echohl WarningMsg
	echomsg 'gitdraw: '. a:msg
	echohl NONE
endfunction

" vim:set noet sts=0 sw=8 ts=8 tw=77 fdm=syntax:
