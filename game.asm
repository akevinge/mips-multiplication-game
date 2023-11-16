.data
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
SELECTION_BOARD: .space 144 # 6x6 board of 1/0 where 1 = selected, 0 = not selected
.globl BOARD_WIDTH_CELLS
BOARD_WIDTH_CELLS: .word 6 # number of cells per row
.globl BOARD_HEIGHT_CELLS
BOARD_HEIGHT_CELLS: .word 6 # number of rows
    ########################################

    # Game ###############################
PREV_GAME_STATE: .word 0 # game state at previous tick
.globl GAME_STATE
GAME_STATE: .word 1 # 0 = player's turn, 1 = opponent's turn, 2 = game over
.globl SELECTED_POINTER
SELECTED_POINTER: .word 1 # pointer selected to be moved 1 = top pointer, -1 = bottom pointer
.globl TOP_POINTER_POSITION
TOP_POINTER_POSITION: .word -1 
.globl BOTTOM_POINTER_POSITION
BOTTOM_POINTER_POSITION: .word -1
TICK_STATE: .word 0 # state of tick which signals an update to the display
PREV_TICK_STATE: .word 0 # previous state of tick which signals an update to the display
TICK_PERIOD_MS: .word 400 # period of tick which signals an update to the display
    ########################################

.text
# FUN game_loop
.globl game_loop
game_loop:
    jal update_tick
    jal update_prev_game_state

    jal try_get_next_keypress
    # $v0 = keypress
    move $a0, $v0
    jal key_handler

    jal routine_update_display

    jal sleep
    j game_loop

# END FUN game_loop


# FUN sleep
# Sleeps for TICK_PERIOD_MS
sleep:
    lw $a0, TICK_PERIOD_MS
    li $v0, 32
    syscall

    jr $ra

# END FUN sleep


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

    xor $t0, $t0, 1 # toggle TICK_STATE
    sw $t0, 0($s0)

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN update_tick

# FUN update_prev_game_state
# Saves previous game state every tick before it changes via key handler.
# This is used by the routine display udate to determine if the game state text
# needs to be updated.
# ARGS:
# $a0: arg1
# $a1: arg2
# $a2: arg3
# RETURN $v0: 0
update_prev_game_state:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    la $t0, PREV_GAME_STATE
    lw $t1, GAME_STATE
    sw $t1, 0($t0) # PREV_GAME_STATE = GAME_STATE

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    move 		$v0, $zero			# $v0 = $zero
    jr			$ra					# jump to $ra

# END FUN update_prev_game_state


# FUN routine_update_display
# Updates trivial display details (e.g. blinking pointers)
routine_update_display:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    lw $t0, PREV_GAME_STATE
    lw $t1, GAME_STATE
    beq $t0, $t1, _blink_selected_pointer # if GAME_STATE == PREV_GAME_STATE, do nothing. skip to rest of subroutine.
    # else, update game state text
    beq $t1, $zero, _player_move_text # if GAME_STATE == 0, paint player move text

_paint_opponent_move_text:
    # Erase player move text
    lw $a0, BACKGROUND_COLOR
    jal paint_your_move

    lw $a0, RED
    jal paint_opponent_move
    j _blink_selected_pointer

_player_move_text:
    # Erase opponent move text
    lw $a0, BACKGROUND_COLOR
    jal paint_opponent_move

    lw $a0, GREEN
    jal paint_your_move

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


# ███████╗███████╗██╗     ███████╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗
# ██╔════╝██╔════╝██║     ██╔════╝██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║
# ███████╗█████╗  ██║     █████╗  ██║        ██║   ██║██║   ██║██╔██╗ ██║
# ╚════██║██╔══╝  ██║     ██╔══╝  ██║        ██║   ██║██║   ██║██║╚██╗██║
# ███████║███████╗███████╗███████╗╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║
# ╚══════╝╚══════╝╚══════╝╚══════╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝

# FUN make_board_selection
# Makes a selection on the board at multiple of the numbers at the pointers.
# If either pointer is unmoved, do nothing.
# RETURN $v0: 
# -2 if either pointer is unmoved or selection is invalid,
# -1 if selection was already made,
# 0 if selection was made successfully
.globl make_board_selection
make_board_selection:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    jal get_board_selection_of_curr_pointers
    # $v0 = multiple of number at both pointers (pointer pos + 1), 0 if either pointer is unmoved
    beq $v0, $zero, _make_board_select_unmoved_or_invalid # if either pointer is unmoved, do nothing

    la $s0, BOARD
    li $s1, 0 # index of board
_make_board_selection_l1:
    lw $t0, BOARD_WIDTH_CELLS
    lw $t1, BOARD_HEIGHT_CELLS
    mul $t0, $t0, $t1 # $t0 = number of cells in board
    beq $s1, $t0, _make_board_select_unmoved_or_invalid # if reached end of board, selection is invalid

    lw $t0, 0($s0) # $t0 = number at current index
    beq $t0, $v0, _make_board_selection_idx_found # if number at current index == multiple of numbers at pointers, select number

    addi $s0, $s0, 4 # increment board pointer
    addi $s1, $s1, 1 # increment index
    j _make_board_selection_l1

_make_board_selection_idx_found:
    la $s2, SELECTION_BOARD
    sll $t0, $s1, 2 # $t0 = index * 4
    add $s2, $s2, $t0 # $s2 = addr of selection board at index
    lw $t0, 0($s2) # $t0 = value at selection board at index
    beq $t0, 1, _make_board_selection_already_selected # if value at selection board at index == 1, selection was already made

    li $t0, 1
    sw $t0, 0($s2) # set value at selection board at index to 1

    lw $t1, GAME_STATE
    beq $t1, $zero, _make_board_selection_player # if GAME_STATE == 0, player made selection
    
_make_board_selection_opponent:
    lw $a1, RED
    j _make_board_selection_paint

_make_board_selection_player:
    lw $a1, GREEN

_make_board_selection_paint:
    move $a0, $s1 # cell index
    lw $a2, 0($s0) # cell value at index
    jal paint_board_cell

    # Toggle game state
    la $t0, GAME_STATE
    lw $t1, 0($t0)
    xor $t1, $t1, 1
    sw $t1, 0($t0)

    # Return 0
    li $v0, 0
    j _make_board_selection_end

_make_board_selection_already_selected:
    li $v0, -1
    j _make_board_selection_end

_make_board_select_unmoved_or_invalid:
    li $v0, -2
    j _make_board_selection_end
    
_make_board_selection_end:
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN make_board_selection

# FUN get_board_selection_of_curr_pointers
# Selects a number on the board at the current pointer position.
# Returns 0 if either pointer is unmoved.
# RETURN $v0: multiple of number at both pointers (pointer pos + 1), 0 if either pointer is unmoved
get_board_selection_of_curr_pointers:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    lw $t0, BOTTOM_POINTER_POSITION
    addi $t0, $t0, 1 # add 1 to bottom pointer position
    beq $t0, $zero, _pointer_unmoved # if bottom pointer is unmoved, return 0

    lw $t1, TOP_POINTER_POSITION
    addi $t1, $t1, 1
    beq $t1, $zero, _pointer_unmoved # if top pointer is unmoved, return 0

    mul $v0, $t0, $t1 # $v0 = bottom pointer position * top pointer position
    j _get_board_selection_of_curr_pointers_end
    
_pointer_unmoved:
    li $v0, 0
    j _get_board_selection_of_curr_pointers_end

_get_board_selection_of_curr_pointers_end:
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN get_board_selection_of_curr_pointers


# ██████╗  ██████╗ ██╗███╗   ██╗████████╗███████╗██████╗ 
# ██╔══██╗██╔═══██╗██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
# ██████╔╝██║   ██║██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
# ██╔═══╝ ██║   ██║██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
# ██║     ╚██████╔╝██║██║ ╚████║   ██║   ███████╗██║  ██║
# ╚═╝      ╚═════╝ ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
#  █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
# ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
# ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
# ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
# ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
# ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

# FUN select_top_pointer
# Switches selected pointer to top pointer.
.globl select_top_pointer
select_top_pointer:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    # Ensure that bottom pointer is painted. Could be in the middle
    # of blinking.
    lw $a0, BOTTOM_POINTER_POSITION
    li $a1, -1
    lw $a2, WHITE
    jal paint_pointer

    la $t0, SELECTED_POINTER
    li $t2, 1
    sw $t2, 0($t0) # set selected pointer to top pointer

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    move 		$v0, $zero			# $v0 = $zero
    jr			$ra					# jump to $ra

# END FUN select_top_pointer


# FUN select_bottom_pointer
# Switches selected pointer to bottom pointer.
.globl select_bottom_pointer
select_bottom_pointer:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    # Ensure that top pointer is painted. Could be in the middle
    # of blinking.
    lw $a0, TOP_POINTER_POSITION
    li $a1, 1
    lw $a2, WHITE
    jal paint_pointer

    la $t0, SELECTED_POINTER
    li $t2, -1
    sw $t2, 0($t0) # set selected pointer to bottom pointer

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    move 		$v0, $zero			# $v0 = $zero
    jr			$ra					# jump to $ra

# END FUN select_bottom_pointer


# FUN increment_selected_pointer
# Moves selected pointer to the right if possible.
# If selected pointer is at the rightmost position, do nothing.
.globl increment_selected_pointer
increment_selected_pointer:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    jal get_selected_pointer_position
    li $t0, 8
    beq $v0, $t0, _increment_selected_pointer_end # if selected pointer is at rightmost position, do nothing

    jal get_selected_pointer_position
    move $s0, $v0 # save selected pointer position

    # Erase previous selected pointer position.
    move $a0, $s0
    lw $a1, SELECTED_POINTER
    lw $a2, BACKGROUND_COLOR
    jal paint_pointer

    # Increment selected pointer position
    jal get_selected_pointer_addr
    addi $s0, $s0, 1 # increment selected pointer position
    sw $s0, 0($v0) # save incremented selected pointer position

    move $a0, $s0
    lw $a1, SELECTED_POINTER
    lw $a2, WHITE
    jal paint_pointer

_increment_selected_pointer_end:
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN increment_selected_pointer


# FUN decrement_selected_pointer
# Moves selected pointer to the left if possible.
# If selected pointer is at the leftmost position, do nothing.
.globl decrement_selected_pointer
decrement_selected_pointer:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    jal get_selected_pointer_position
    ble $v0, $zero, _decrement_selected_pointer_end # if selected pointer is at leftmost position, do nothing

    jal get_selected_pointer_position
    move $s0, $v0 # save selected pointer position

    # Erase previous selected pointer position.
    move $a0, $s0
    lw $a1, SELECTED_POINTER
    lw $a2, BACKGROUND_COLOR
    jal paint_pointer

    # Increment selected pointer position
    jal get_selected_pointer_addr
    addi $s0, $s0, -1 # increment selected pointer position
    sw $s0, 0($v0) # save incremented selected pointer position

    move $a0, $s0
    lw $a1, SELECTED_POINTER
    lw $a2, WHITE
    jal paint_pointer

_decrement_selected_pointer_end:
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN increment_selected_pointer


# FUN get_selected_pointer_addr
# Gets the address of the selected pointer.
# RETURN $v0: address of selected pointer
get_selected_pointer_addr:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    lw $t0, SELECTED_POINTER
    beq $t0, -1, _get_bottom_pointer_addr # if SELECTED_POINTER == -1, return address of BOTTOM_POINTER_POSITION

_get_top_pointer_addr:
    la $v0, TOP_POINTER_POSITION
    j _get_selected_pointer_position_end

_get_bottom_pointer_addr:
    la $v0, BOTTOM_POINTER_POSITION
    j _get_selected_pointer_position_end

_get_selected_pointer_position_end:
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN get_selected_pointer_addr


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

    jal get_selected_pointer_addr # $v0 = addr of selected pointer
    lw $v0, 0($v0) # $v0 = value at addr of selected pointer

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN get_selected_pointer_position
