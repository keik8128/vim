" Test for 'extrafiletypes'

function! SetUp()
  let s:topdir = expand('%:h') . '/Xdir'
  let ftplugindir = s:topdir . '/ftplugin'
  let indentdir = s:topdir . '/indent'
  let s:testfiledir = s:topdir . '/testfile'
  call mkdir(ftplugindir, 'p')
  call mkdir(indentdir, 'p')
  call mkdir(s:testfiledir, 'p')
  let s:rtp_save = &rtp
  let &rtp .= ',' . s:topdir

  execute 'split' ftplugindir . '/bbbbb.vim'
  call setline(1, 'let g:eft_ftplugin_bbbbb_works = 1')
  wq

  execute 'split' ftplugindir . '/ccccc.vim'
  call setline(1, 'let g:eft_ftplugin_ccccc_works = 1')
  wq

  execute 'split' indentdir . '/bbbbb.vim'
  call setline(1, 'let g:eft_indent_bbbbb_works = 2')
  wq

  execute 'split' indentdir . '/ccccc.vim'
  call setline(1, 'let g:eft_indent_ccccc_works = 3')
  wq

  execute 'split' s:testfiledir . '/no_filetype_test1'
  call setline(1, 'Vim cannot detect this filetype.')
  wq
  execute 'split' s:testfiledir . '/no_filetype_test2'
  call setline(1, 'Vim cannot detect this filetype.')
  wq
endfunction

function! TearDown()
  call delete(s:topdir, 'rf')
  let &rtp = s:rtp_save
endfunction

function! Test_eft()
  if !has('autocmd') | return | endif

  filetype plugin indent on

  augroup test_extrafiletypes
    autocmd FileType aaaaa call assert_false(v:ft_isextra)
    autocmd FileType bbbbb let g:eft_autocmd_bbbbb_works = 5
                         \|call assert_true(v:ft_isextra)
    autocmd FileType ccccc let g:eft_autocmd_ccccc_works = 8
                         \|call assert_true(v:ft_isextra)
    autocmd FileType ddddd let g:eft_autocmd_ddddd_works = 13
    autocmd FileType eeeee let g:eft_autocmd_eeeee_works = 21
  augroup END

  " call assert_false(did_filetype()) cannot test due to did_filetype()'s bug
  set ft=aaaaa
  " call assert_true(did_filetype()) cannot test due to did_filetype()'s bug

  set eft=bbbbb,ccccc
  call assert_equal(1, g:eft_ftplugin_bbbbb_works)
  call assert_equal(1, g:eft_ftplugin_ccccc_works)
  call assert_equal(2, g:eft_indent_bbbbb_works)
  call assert_equal(3, g:eft_indent_ccccc_works)
  call assert_equal(5, g:eft_autocmd_bbbbb_works)
  call assert_equal(8, g:eft_autocmd_ccccc_works)
  " call assert_true(did_filetype()) cannot test due to did_filetype()'s bug

  " https://github.com/vim/vim/issues/747
  execute 'split' s:testfiledir . '/no_filetype_test1'
  execute 'edit' s:testfiledir . '/no_filetype_test2'
  call assert_true(empty(&filetype))
  call assert_true(empty(&extrafiletypes))
  set ft=ddddd eft=eeeee
  call assert_equal('ddddd', &filetype)
  call assert_equal('eeeee', &extrafiletypes)
  call assert_equal(13, g:eft_autocmd_ddddd_works)
  call assert_equal(21, g:eft_autocmd_eeeee_works)
  unlet g:eft_autocmd_ddddd_works g:eft_autocmd_eeeee_works
  bp | bn
  call assert_equal('ddddd', &filetype)
  call assert_equal('eeeee', &extrafiletypes)
  call assert_equal(13, g:eft_autocmd_ddddd_works)
  call assert_equal(21, g:eft_autocmd_eeeee_works)
endfunction
