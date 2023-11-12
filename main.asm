.data
    # Colors ##########################
.globl BACKGROUND_COLOR
BACKGROUND_COLOR:   .word   0x00000000

.globl WHITE
WHITE:               .word   0xFFFFFFFF
    #       
    # Colors ###################################

    # Board ##############################
.globl BOARD
BOARD: .word  # 6x6 board of random numbers multiples of two numbers 1-9
1, 2, 3, 4, 5, 6,
7, 8, 9, 10, 12, 14,
15, 16, 18, 20, 21, 24,
25, 27, 28, 30, 32, 35,
36, 40, 42, 45, 48, 49,
54, 56, 63, 64, 72, 81
.globl SELECTION_BOARD
SELECTION_BOARD: .space 144 # 6x6x4B board of 1/0 where 1 = selected, 0 = not selected
.globl BOARD_WIDTH_CELLS
BOARD_WIDTH_CELLS: .word 6 # number of cells per row
.globl BOARD_HEIGHT_CELLS
BOARD_HEIGHT_CELLS: .word 6 # number of rows
    #       
    # Board ####################################

.globl NEWLINE
NEWLINE: .asciiz "\n"

.text
main:
    jal paint_background

    jal paint_board

    jal paint_numberline

    jal init_pointers

    jal game_loop

.globl terminate
terminate:          
    jal paint_background # reset background
    li      $v0,                    10
    syscall 
