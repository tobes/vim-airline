let s:sections = ['a', 'b', 'c', 'gutter', 'x', 'y', 'z', 'warning']

function! s:clear()
  for key in s:sections
    unlet! g:airline_section_{key}
  endfor
endfunction

call airline#init#bootstrap()

describe 'init sections'
  before
    call s:clear()
    call airline#init#sections()
  end

  after
    call s:clear()
  end

  it 'section a should have mode, paste, iminsert'
    let a = airline#extensions#default#make_section('a')
    Expect a =~ 'mode'
    Expect a =~ 'paste'
    Expect a =~ 'iminsert'
  end

  it 'section b should be blank because no extensions are installed'
    let b = airline#extensions#default#make_section('b')
    Expect b == ''
  end

  it 'section c should be file'
    let c = airline#extensions#default#make_section('c')
    Expect c == '%<%f%m %#__accent_red#%{airline#util#wrap(airline#parts#readonly(),0)}%#__restore__#'
  end

  it 'section x should be filetype'
    let x = airline#extensions#default#make_section('x')
    Expect x == '%{airline#util#wrap(airline#parts#filetype(),0)}'
  end

  it 'section y should be fenc and ff'
    let y = airline#extensions#default#make_section('y')
    Expect y =~ 'ff'
    Expect y =~ 'fenc'
  end

  it 'section z should be line numbers'
    let z = airline#extensions#default#make_section('z')
    Expect z =~ '%3p%%'
    Expect z =~ '%4l'
    Expect z =~ '%3v'
  end

  it 'should not redefine sections already defined'
    for s in s:sections
      let g:airline_section_{s} = [s]
    endfor
    call airline#init#bootstrap()
    for s in s:sections
      Expect g:airline_section_{s} == [s]
    endfor
  end

  it 'all default statusline extensions should be blank'
    Expect airline#parts#get('hunks').raw == ''
    Expect airline#parts#get('branch').raw == ''
    Expect airline#parts#get('tagbar').raw == ''
    Expect airline#parts#get('syntastic').raw == ''
    Expect airline#parts#get('eclim').raw == ''
    Expect airline#parts#get('whitespace').raw == ''
  end
end

describe 'init parts'
  it 'should not redefine parts already defined'
    call airline#parts#define_raw('linenr', 'bar')
    call airline#init#sections()
    let z = airline#extensions#default#make_section('z')
    Expect z =~ 'bar'
  end
end

