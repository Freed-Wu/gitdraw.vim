scriptencoding utf-8

if !exists('g:gitdraw#convert_rule')
	let g:gitdraw#convert_rule = {
				\ '〇': {
				\ 'convert_number': 0,
				\ 'highlight_set': 'guibg=Grey guifg=Grey ctermbg=Grey ctermfg=Grey',
				\ },
				\ '一': {
				\ 'convert_number': 1,
				\ 'highlight_set': 'guibg=Yellow guifg=Yellow ctermbg=Yellow ctermfg=Yellow',
				\ },
				\ '二': {
				\ 'convert_number': 2,
				\ 'highlight_set': 'guibg=Green guifg=Green ctermbg=Green ctermfg=Green',
				\ },
				\ '三': {
				\ 'convert_number': 3,
				\ 'highlight_set': 'guibg=Cyan guifg=Cyan ctermbg=Cyan ctermfg=Cyan',
				\ },
				\ '四': {
				\ 'convert_number': 4,
				\ 'highlight_set': 'guibg=Brown guifg=Brown ctermbg=Brown ctermfg=Brown',
				\ },
				\ }
endif

for [s:key, s:val] in items(g:gitdraw#convert_rule)
	execute 'syntax match gitdraw' .. s:val.convert_number shellescape(s:key)
	execute 'highlight gitdraw' .. s:val.convert_number s:val.highlight_set
endfor

" vim:set noet sts=0 sw=8 ts=8 tw=77 fdm=syntax:
