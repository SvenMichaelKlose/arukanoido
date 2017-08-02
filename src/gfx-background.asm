bg_start = @(+ framechars foreground)

gfx_background:

bg_brick_orange = @(+ bg_start 0)
%01010100
%10101000
%01010100
%10101000
%01010100
%10101000
%01010100
%00000000

bg_brick = @(+ bg_start 1)
%11111110
%11111110
%11111110
%11111110
%11111110
%11111110
%11111110
%00000000

bg_brick_special1 = @(+ bg_start 2)
%10101010
%11111110
%10101010
%11111110
%10101010
%11111110
%10101010
%00000000

bg_side = @(+ bg_start 3)
%00111100
%10111100
%10111111
%10111100
%10111111
%10111100
%10111111
%10111100

%10111111
%00110000
%10111111
%00110000
%10111111
%00110000
%10111111
%00110000

%10111100
%10111111
%10111100
%10111111
%10111100
%10111111
%10111100
%00111100

%00000000
%00101100
%00101100
%00101100
%00101100
%00101100
%00101100
%00101100

%00101100
%00101100
%00101100
%00101100
%00101100
%00101100
%00101100
%00000000

bg_corner_left = @(+ bg_start 8)
%00000000
%00001010
%00101111
%00101111
%00101111
%00101111
%00101111
%00000011

bg_top_1 = @(+ bg_start 9)
%00000000
%10101010
%11111111
%11111111
%11111111
%11111111
%00000000
%00000000

bg_top_2 = @(+ bg_start 10)
%00101010
%10111100
%11111111
%11111100
%11111111
%11111100
%00111111
%00000000

bg_top_3 = @(+ bg_start 11)
%10101000
%00111110
%11111111
%00111111
%11111111
%00111111
%11111100
%00000000

bg_corner_right = @(+ bg_start 12)
%00000000
%10100000
%11111000
%11111100
%11111000
%11111100
%11111100
%11000000

bg_break = @(+ bg_start 13)
%00100000
%00010000
%00001000
%00000100
%00001000
%00010000
%00100000
%01000000

%00001000
%00010000
%00100000
%01000000
%00100000
%00010000
%00001000
%00000100

bg_minivaus = @(+ bg_start 15)
%01110100
%10101000
%01110100
%01110100
%00000000
%00000000
%00000000
%00000000

gfx_background_end:
