" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_CommentAnyWay') && g:loaded_CommentAnyWay
    finish
endif
let g:loaded_CommentAnyWay = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


if !exists('g:caw_no_default_keymappings')
    let g:caw_no_default_keymappings = 0
endif

if !exists('g:caw_sp_i')
    let g:caw_sp_i = ' '
endif
if !exists('g:caw_i_startinsert_at_blank_line')
    let g:caw_i_startinsert_at_blank_line = 1
endif
if !exists('g:caw_i_align')
    let g:caw_i_align = 1
endif

if !exists('g:caw_I_startinsert_at_blank_line')
    let g:caw_I_startinsert_at_blank_line = 1
endif
if !exists('g:caw_sp_I')
    let g:caw_sp_I = ' '
endif

if !exists('g:caw_sp_a_left')
    let g:caw_sp_a_left = repeat(' ', 4)
endif
if !exists('g:caw_sp_a_right')
    let g:caw_sp_a_right = ' '
endif
if !exists('g:caw_a_startinsert')
    let g:caw_a_startinsert = 1
endif

if !exists('g:caw_sp_wrap_left')
    let g:caw_sp_wrap_left = ' '
endif
if !exists('g:caw_sp_wrap_right')
    let g:caw_sp_wrap_right = ' '
endif

if !exists('g:caw_sp_jump')
    let g:caw_sp_jump = ' '
endif

if !exists('g:caw_find_another_action')
    let g:caw_find_another_action = 1
endif



function! s:map_user(lhs, rhs) "{{{
    if a:lhs == '' || a:rhs == ''
        echoerr 'internal error'
        return
    endif
    let lhs = '<Plug>(caw:prefix)' . a:lhs
    let rhs = printf('<Plug>(caw:%s)', a:rhs)
    for mode in ['n', 'v']
        if !hasmapto(rhs, mode)
            silent! execute
            \   mode.'map <unique>' lhs rhs
        endif
    endfor
endfunction "}}}
function! s:map_plug(lhs, fn, ...) "{{{
    if a:lhs == '' || a:fn == ''
        echoerr 'internal error'
        return
    endif
    let lhs = printf('<Plug>(caw:%s)', a:lhs)
    for mode in a:0 ? a:1 : ['n', 'v']
        execute
        \   mode . 'noremap'
        \   '<silent>'
        \   lhs
        \   ':<C-u>call '
        \   . substitute(a:fn, '<mode>', string(mode), 'g')
        \   . '<CR>'
    endfor
endfunction "}}}


" prefix
function! s:define_prefix(lhs) "{{{
    let rhs = '<Plug>(caw:prefix)'
    if !hasmapto(rhs)
        execute 'silent! nmap <unique>' a:lhs rhs
        execute 'silent! vmap <unique>' a:lhs rhs
    endif
endfunction "}}}
call s:define_prefix('gc')


" i/I/a
function! s:map_generic(type, action) "{{{
    let lhs = printf('%s:%s', a:type, a:action)
    let rhs = printf('caw#do_%s_%s(<mode>)', a:type, a:action)
    call s:map_plug(lhs, rhs)
endfunction "}}}
function! s:define_generic() "{{{
    for type in ['i', 'I', 'a', 'wrap']
        for action in ['comment', 'uncomment', 'toggle']
            call s:map_generic(type, action)
        endfor
    endfor
endfunction "}}}
call s:define_generic()



if !g:caw_no_default_keymappings
    call s:map_user('i', 'i:comment')
    call s:map_user('I', 'I:comment')
    call s:map_user('a', 'a:comment')
    call s:map_user('ui', 'i:uncomment')
    call s:map_user('ua', 'a:uncomment')
    call s:map_user('c', 'i:toggle')
endif


" wrap
if !g:caw_no_default_keymappings
    call s:map_user('w', 'wrap:comment')
    call s:map_user('uw', 'wrap:uncomment')
endif



" jump
call s:map_plug('jump:comment-next', 'caw#do_jump_comment_next()', ['n'])
call s:map_plug('jump:comment-prev', 'caw#do_jump_comment_prev()', ['n'])

if !g:caw_no_default_keymappings
    call s:map_user('o', 'jump:comment-next')
    call s:map_user('O', 'jump:comment-prev')
endif



" input
call s:map_plug('input:comment', 'caw#do_input_comment(<mode>)')
call s:map_plug('input:uncomment', 'caw#do_input_uncomment(<mode>)')

if !g:caw_no_default_keymappings
    call s:map_user('v', 'input:comment')
    call s:map_user('uv', 'input:uncomment')
endif



delfunc s:map_prefix
delfunc s:map_user
delfunc s:map_plug


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
