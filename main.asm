    ############################################
    # Unit Width in Pixels: 4
    # Unit Height in Pixels: 4
    # Display Width in Pixels: 512
    # Display Height in Pixels: 512
    # Display Unit Size: 128x128
    # Frame Buffer Address: 0x10010000
    # Frame Buffer Size: 16384
    ############################################

.data
    ###
    # Colors ##########################
.globl BACKGROUND_COLOR
BACKGROUND_COLOR:   .word   0x00000000

.globl WHITE
WHITE:               .word   0xFFFFFFFF
    #       
    # Colors ###################################

    ###
    # Display ###########################
.globl FRAME_BUFFER
FRAME_BUFFER:       .word   0x10000000                          # frame buffer address
.globl FRAME_BUFFER_SIZE
FRAME_BUFFER_SIZE:  .word   16384                               # 128x128 units
.globl ROW_SIZE_BYTES
ROW_SIZE_BYTES:    .word   512                                 # 128units x 4B
.globl NEG_ROW_SIZE_BYTES
NEG_ROW_SIZE_BYTES: .word   -512                                # -128units x 4B
.globl CELL_WIDTH
CELL_WIDTH: .word 16
.globl CELL_HEIGHT
CELL_HEIGHT: .word 16
.globl BOARD_WIDTH_CELLS
BOARD_WIDTH_CELLS: .word 6 # number of cells per row
.globl BOARD_HEIGHT_CELLS
BOARD_HEIGHT_CELLS: .word 6 # number of rows
    #       
    # Display ####################################

    ###
    # Board ##############################
.globl BOARD
BOARD: .space 144 # 6x6x4B board
    #       
    # Board ####################################

.globl NEWLINE
NEWLINE: .asciiz "\n"

.text
main:
    jal generate_board

    jal paint_background

    jal paint_board
    
    jal terminate


generate_board:     
    ############################################
    # generate_board
    # generates a 6x6 board of random numbers multiples of two numbers 1 - 9
    ############################################

    addi		$sp, $sp, -20			# $sp -= 20
    sw			$ra, 0($sp)


    li      $t0, 0 # set $t0 to 0 (board index)
    li      $t1, 36 # 6x6 board
    la     $t2, BOARD # load board address

generate_board_l1:
    jal     generate_rand_multiple                              # generate random multiple of two numbers 1-9
    sw      $v0, 0($t2) # store random number in board
    addi    $t2, $t2, 4 # increment board address
    addi    $t0, $t0, 1 # increment board index
    bne     $t0, $t1, generate_board_l1

    jal     generate_rand_multiple
    move    $t0,                    $v0                         # move random number to $t0

    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20
    jr			$ra					# jump to $ra


generate_rand_multiple:
    ############################################
    # generate_rand_multiple
    # generate random multiple of two numbers 1 - 9
    # $v0 = random multiple
    ############################################

    move    $s0,                    $ra                         # save return address

    jal     generate_rand                                       # generate first random number
    move    $t0,                    $v0                         # move random number to $t0

    jal     generate_rand                                       # generate second random number
    move    $t1,                    $v0                         # move random number to $t1

    mult    $t0,                    $t1                         # multiply $t0 and $t1
    mflo    $v0                                                 # move result to $v0

    move    $ra,                    $s0                         # restore return address
    jr      $ra


generate_rand:      
    ############################################
    #       
    # generate_rand
    # generates a random number between 1 and 9 (inclusive)
    # $v0 = random number
    ############################################

    li      $a0,                    1                           # set $a0 to 1 (ID of random generator)
    li      $a1,                    9                           # set $a1 to 9 (max random number). 0 - 8 (inclusive)
    li      $v0,                    42                          # set $v0 to 42 (syscall for random number)
    syscall                                                     # call random number

    move    $v0,                    $a0                         # set $v0 to random number
    add     $v0,                    $v0,                    1   # add 1 to random number to make it 1 - 9 (inclusive)

    jr      $ra


terminate:          
    li      $v0,                    10
    syscall 
