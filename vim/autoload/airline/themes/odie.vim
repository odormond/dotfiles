let g:airline#themes#odie#palette = {}

" Normal mode
let s:N1 = [ '#005f00' , '#afd700' , 22  , 148 ]
let s:N2 = [ '#b2b2b2' , '#4e4e4e' , 249 , 239 ]
let s:N3 = [ '#ffffff' , '#303030' , 231 , 236 ]

let g:airline#themes#odie#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

" Insert mode
let s:I1 = [ '#00005f' , '#ffffff' , 17  , 231 ]
let s:I2 = [ '#afffff' , '#0000d7' , 159 , 20  ]
let s:I3 = [ '#ffffff' , '#00005f' , 231 , 17  ]

let g:airline#themes#odie#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)

" Replace mode
let s:R1 = [ '#5f005f' , '#ffffff' , 53  , 231 ]
let s:R2 = [ '#ffffaf' , '#d70000' , 229 , 160 ]
let s:R3 = [ '#ffffff' , '#5f0000' , 231 , 52  ]

let g:airline#themes#odie#palette.replace = airline#themes#generate_color_map(s:R1, s:R2, s:R3)

" Visual mode
let s:V1 = [ '#080808' , '#ffaf00' , 232 , 214 ]

let g:airline#themes#odie#palette.visual = {
      \ 'airline_a': [ s:V1[0]   , s:V1[1]   , s:V1[2]   , s:V1[3]   , ''     ],
      \ 'airline_z': [ s:V1[0]   , s:V1[1]   , s:V1[2]   , s:V1[3]   , ''     ] }

" Inactive mode
let s:IA = [ '#8a8a8a' , '#303030' , 245 , 236 , '' ]

let g:airline#themes#odie#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)

