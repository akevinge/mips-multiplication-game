.data
    # Colors ##########################
.globl BACKGROUND_COLOR
BACKGROUND_COLOR:   .word   0x00000000

.globl WHITE
WHITE:               .word   0xFFFFFFFF

.globl GREEN
GREEN:              .word   0x0000FF00

.globl RED
RED:                .word   0xFFFF0000
    #       
    # Colors ###################################

.globl NEWLINE
NEWLINE: .asciiz "\n"

.text
main:
    jal paint_background

    jal paint_board

    jal paint_numberline

    jal init_pointers

    lw $a0, RED
    jal paint_opponent_move

    jal game_loop

.globl terminate
terminate:          
    jal paint_background # reset background
    li      $v0,                    10
    syscall 
