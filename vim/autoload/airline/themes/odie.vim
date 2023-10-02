vim9script
g:airline#themes#odie#palette = {}

# Normal mode
var N1 = ['#005f00', '#afd700', 22,  148]
var N2 = ['#b2b2b2', '#4e4e4e', 249, 239]
var N3 = ['#ffffff', '#303030', 231, 236]

g:airline#themes#odie#palette.normal = airline#themes#generate_color_map(N1, N2, N3)

# Insert mode
var I1 = ['#00005f', '#ffffff', 17,  231]
var I2 = ['#afffff', '#0000d7', 159, 20 ]
var I3 = ['#ffffff', '#00005f', 231, 17 ]

g:airline#themes#odie#palette.insert = airline#themes#generate_color_map(I1, I2, I3)

# Replace mode
var R1 = ['#5f005f', '#ffffff', 53,  231]
var R2 = ['#ffffaf', '#d70000', 229, 160]
var R3 = ['#ffffff', '#5f0000', 231, 52 ]

g:airline#themes#odie#palette.replace = airline#themes#generate_color_map(R1, R2, R3)

# Visual mode
var V1 = ['#080808', '#ffaf00', 232, 214]

g:airline#themes#odie#palette.visual = {
    'airline_a': [V1[0], V1[1], V1[2], V1[3], ''],
    'airline_z': [V1[0], V1[1], V1[2], V1[3], ''],
}

# Inactive mode
var IA = ['#8a8a8a', '#303030', 245, 236, '']

g:airline#themes#odie#palette.inactive = airline#themes#generate_color_map(IA, IA, IA)

