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
    # Game ###############################
.globl GAME_STATE
GAME_STATE: .word 0 # 0 = waiting for input, 1 = waiting on opponent, 2 = game over
SELECTED_POINTER: .word 1 # pointer selected to be moved 1 = top pointer, -1 = bottom pointer
TOP_POINTER_POSITION: .word -1 
BOTTOM_POINTER_POSITION: .word -1
TICK_STATE: .word 0 # state of tick which signals an update to the display
PREV_TICK_STATE: .word 0 # previous state of tick which signals an update to the display
TICKET_PERIOD_MS: .word 500 # period of tick which signals an update to the display
    #       
    # Game #####################################

.globl NEWLINE
NEWLINE: .asciiz "\n"

.text
main:
    jal generate_board

    jal paint_background

    jal paint_board

    jal paint_numberline

    jal init_pointers

game_loop:
    jal update_tick

    jal try_get_next_keypress
    # $v0 = keypress
    move $a0, $v0
    jal key_handler

    jal routine_update_display

    jal sleep
    j game_loop

sleep:
    lw $a0, TICKET_PERIOD_MS
    li $v0, 32
    syscall

    jr $ra

# FUN update_tick
# Updates tick state and saves previous tick state.
# Tick alternates between 0 and 1.
update_tick:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    la $s0, TICK_STATE
    la $s1, PREV_TICK_STATE

    lw $t0, 0($s0)
    sw $t0, 0($s1) # PREV_TICK_STATE = TICK_STATE

    beq $t0, $zero, increment_tick # if TICK_STATE == 0, increment_tick
decrement_tick:
    addi $t0, $t0, -1
    sw $t0, 0($s0)
    j update_tick_end

increment_tick:
    addi $t0, $t0, 1
    sw $t0, 0($s0)
    j update_tick_end

update_tick_end:
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN update_tick

# FUN init_pointers
# Initializes the pointers to the top and bottom of the board.
init_pointers:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    lw $a0, TOP_POINTER_POSITION
    li $a1, 1
    lw $a2, WHITE
    jal paint_pointer

    lw $a0, BOTTOM_POINTER_POSITION
    li $a1, -1
    lw $a2, WHITE
    jal paint_pointer

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    move 		$v0, $zero			# $v0 = $zero
    jr			$ra					# jump to $ra

# END FUN init_pointers

# FUN routine_update_display
# Updates trivial display details (e.g. blinking pointers)
routine_update_display:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

_blink_selected_pointer: # blink selected pointer by changing color depending on tick state
    lw $t0, TICK_STATE
    beq $t0, $zero, _paint_selected_pointer_bg # if TICK_STATE == 0, paint pointer background color
_paint_selected_pointer_white:
    jal get_selected_pointer_position
    move $a0, $v0
    lw $a1, SELECTED_POINTER
    lw $a2, WHITE
    jal paint_pointer
    j _paint_selected_pointer_end
_paint_selected_pointer_bg:
    jal get_selected_pointer_position
    move $a0, $v0
    lw $a1, SELECTED_POINTER
    lw $a2, BACKGROUND_COLOR
    jal paint_pointer
    j _paint_selected_pointer_end

_paint_selected_pointer_end:
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN routine_update_display

# FUN get_selected_pointer_position
# Gets the position of the selected pointer.
# RETURN $v0: position of selected pointer
get_selected_pointer_position:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    lw $t0, SELECTED_POINTER
    beq $t0, 1, _get_top_pointer_position # if SELECTED_POINTER == 1, return TOP_POINTER_POSITION

_get_top_pointer_position:
    lw $v0, TOP_POINTER_POSITION
    j _get_selected_pointer_position_end

_get_bottom_pointer_position:
    lw $v0, BOTTOM_POINTER_POSITION
    j _get_selected_pointer_position_end

_get_selected_pointer_position_end:
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN get_selected_pointer_positi

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


.globl terminate
terminate:          
    jal paint_background # reset background
    li      $v0,                    10
    syscall 
