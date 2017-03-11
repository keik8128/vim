" Test for 'extrasyntaxes'

function! SetUp()
  let s:topdir = expand('%:h') . '/Xdir'
  let syntaxdir = s:topdir . '/syntax'
  call mkdir(syntaxdir, 'p')
  let s:rtp_save = &rtp
  let &rtp .= ',' . s:topdir

  execute 'split' syntaxdir . '/bbbbb.vim'
  call setline(1, 'let g:esyn_syntax_bbbbb_works = 1')
  wq

  execute 'split' syntaxdir . '/ccccc.vim'
  call setline(1, 'let g:esyn_syntax_ccccc_works = 1')
  wq
endfunction

function! TearDown()
  call delete(s:topdir, 'rf')
  let &rtp = s:rtp_save
endfunction

function! Test_esyn()
  if !has('syntax') | return | endif

  syntax on

  if has('autocmd')
    augroup test_extrasyntaxes
      autocmd Syntax aaaaa call assert_false(v:syn_isextra)
      autocmd Syntax bbbbb let g:esyn_autocmd_bbbbb_works = 5
                         \|call assert_true(v:syn_isextra)
      autocmd Syntax ccccc let g:esyn_autocmd_ccccc_works = 8
                         \|call assert_true(v:syn_isextra)
    augroup END
  endif

  set syn=aaaaa

  set esyn=bbbbb,ccccc
  call assert_equal(1, g:esyn_syntax_bbbbb_works)
  call assert_equal(1, g:esyn_syntax_ccccc_works)
  if has('autocmd')
    call assert_equal(5, g:esyn_autocmd_bbbbb_works)
    call assert_equal(8, g:esyn_autocmd_ccccc_works)
  endif

  if has('autocmd')
    set ft=ddddd
    set eft=eeeee,fffff

    call assert_equal("ddddd", &syntax)
    call assert_equal("eeeee,fffff", &extrasyntaxes)
  endif
endfunction
