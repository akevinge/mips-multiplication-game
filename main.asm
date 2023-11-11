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
    # Colors ##########################
.globl BACKGROUND_COLOR
BACKGROUND_COLOR:   .word   0x00000000

.globl WHITE
WHITE:               .word   0xFFFFFFFF
    #       
    # Colors ###################################

    # Board ##############################
.globl BOARD
BOARD: .space 144 # 6x6x4B board
.globl BOARD_WIDTH_CELLS
BOARD_WIDTH_CELLS: .word 6 # number of cells per row
.globl BOARD_HEIGHT_CELLS
BOARD_HEIGHT_CELLS: .word 6 # number of rows
    #       
    # Board ####################################

    ###
    # Keyboard ############################
.globl KEYBOARD
KEYBOARD: .word 0xFFFF0004
A_KEY: .word 0x00000061
D_KEY: .word 0x00000064
    #
    # Keyboard ##################################

    ###
    # Game ###############################
.globl GAME_STATE
GAME_STATE: .word 0 # 0 = waiting for input, 1 = waiting on opponent, 2 = game over
    #       
    # Game #####################################

.globl NEWLINE
NEWLINE: .asciiz "\n"

.text
main:
    jal generate_board

    jal paint_background

    jal paint_board
    
    jal terminate

# FUN keyboard_listener
keyboard_listener:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

keyboard_listener_l1:
    lw $a0, KEYBOARD
    lw $t0, 0($a0)
    beq $t0, $zero, keyboard_listener_l1 # wait for keypress to continue, otherwise loop
    move $a0, $t0
    li $v0, 34
    syscall

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    move 		$v0, $zero			# $v0 = $zero
    jr			$ra					# jump to $ra

# END FUN keyboard_listener


# FUN generate_board
# generates a 6x6 board of random numbers multiples of two numbers 1 - 9
generate_board:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    li      $s0, 0 # set $t0 to 0 (board index)
    li      $s1, 36 # 6x6 board
    la     $s2, BOARD # load board address

generate_board_l1:
    jal     generate_rand_multiple                              # generate random multiple of two numbers 1-9
    sw      $v0, 0($s2) # store random number in board
    addi    $s2, $s2, 4 # increment board address
    addi    $s0, $s0, 1 # increment board index
    bne     $s0, $s1, generate_board_l1

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN generate_board

generate_rand_multiple:
    ############################################
    # generate_rand_multiple
    # generate random multiple of two numbers 1 - 9
    # $v0 = random multiple
    ############################################
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    jal     generate_rand                                       # generate first random number
    move    $t0,                    $v0                         # move random number to $t0

    jal     generate_rand                                       # generate second random number
    move    $t1,                    $v0                         # move random number to $t1

    mult    $t0,                    $t1                         # multiply $t0 and $t1
    mflo    $v0                                                 # move result to $v0

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra



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
