" MIT License. Copyright (c) 2013-2015 Bailey Ling.
" vim: et ts=2 sts=2 sw=2

let s:section_truncate_width = get(g:, 'airline#extensions#default#section_truncate_width', {
      \ 'b': 79,
      \ 'x': 60,
      \ 'y': 88,
      \ 'z': 45,
      \ })
let s:layout = get(g:, 'airline#extensions#default#layout', [
      \ [ 'a', 'b', 'c' ],
      \ [ 'x', 'y', 'z', 'warning' ]
      \ ])

let s:layout_force = get(g:, 'airline#extensions#default#layout_force', {'normal' : ['z']})


let s:layout_info = {}

function! s:create_layout_info()
  " populate dictionary s:layout_info { section_key: append style,..}

  function! s:get_forced(key)
    for force in keys(s:layout_force)
      if index(get(s:layout_force, force, []), a:key) > -1
        return force
      endif
    endfor
    return 0
  endfunction

  for idx in range(2)
    let l:layout_parts = s:layout[idx]
    for idy in range(len(l:layout_parts))
      let l:layout_part = l:layout_parts[idy]
      let l:forced = s:get_forced(l:layout_part)
      if type(l:forced) == type('')
        let l:layout_type = l:forced
      elseif idx == 0 && idy == 0
        let l:layout_type = 'left'
      elseif idx == 1
        if idy == len(l:layout_parts) - 1
          let l:layout_type = 'norm'
        else
          let l:layout_type = 'right'
        endif
      else
        let l:layout_type = 'norm'
      endif
      let s:layout_info[l:layout_part] = l:layout_type
    endfor
  endfor
endfunction

call s:create_layout_info()


function! airline#extensions#default#make_section(key)
  let l:layout = get(s:layout_info, a:key, 'norm')
  let l:data = g:airline_section_{a:key}
  if l:layout ==# 'left'
    return airline#section#create_left(l:data)
  elseif l:layout ==# 'right'
    return airline#section#create_right(l:data)
  else
    return airline#section#create(l:data)
  endif
endfunction


function! s:get_section(winnr, key, ...)
  if has_key(s:section_truncate_width, a:key)
    if winwidth(a:winnr) < s:section_truncate_width[a:key]
      return ''
    endif
  endif
  let spc = g:airline_symbols.space
  if type(g:airline_section_{a:key}) == type([])
    let text = airline#extensions#default#make_section(a:key)
  else
    let text = airline#util#getwinvar(a:winnr, 'airline_section_'.a:key, g:airline_section_{a:key})
  endif
  let [prefix, suffix] = [get(a:000, 0, '%('.spc), get(a:000, 1, spc.'%)')]
  return empty(text) ? '' : prefix.text.suffix
endfunction

function! s:build_sections(builder, context, keys)
  for key in a:keys
    if key == 'warning' && !a:context.active
      continue
    endif
    call s:add_section(a:builder, a:context, key)
  endfor
endfunction

if v:version >= 704 || (v:version >= 703 && has('patch81'))
  function s:add_section(builder, context, key)
    " i have no idea why the warning section needs special treatment, but it's
    " needed to prevent separators from showing up
    if a:key == 'warning'
      call a:builder.add_raw('%(')
    endif
    call a:builder.add_section('airline_'.a:key, s:get_section(a:context.winnr, a:key))
    if a:key == 'warning'
      call a:builder.add_raw('%)')
    endif
  endfunction
else
  " older version don't like the use of %(%)
  function s:add_section(builder, context, key)
    if a:key == 'warning'
      call a:builder.add_raw('%#airline_warning#'.s:get_section(a:context.winnr, a:key))
    else
      call a:builder.add_section('airline_'.a:key, s:get_section(a:context.winnr, a:key))
    endif
  endfunction
endif

function! airline#extensions#default#apply(builder, context)
  let winnr = a:context.winnr
  let active = a:context.active

  if airline#util#getwinvar(winnr, 'airline_render_left', active || (!active && !g:airline_inactive_collapse))
    call s:build_sections(a:builder, a:context, s:layout[0])
  else
    let text = s:get_section(winnr, 'c')
    if empty(text)
      let text = ' %f%m '
    endif
    call a:builder.add_section('airline_c'.(a:context.bufnr), text)
  endif

  call a:builder.split(s:get_section(winnr, 'gutter', '', ''))

  if airline#util#getwinvar(winnr, 'airline_render_right', 1)
    call s:build_sections(a:builder, a:context, s:layout[1])
  endif

  return 1
endfunction

