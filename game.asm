.data
    # Game ###############################
GAME_STATE: .word 0 # 0 = waiting for input, 1 = waiting on opponent, 2 = game over
.globl SELECTED_POINTER
SELECTED_POINTER: .word 1 # pointer selected to be moved 1 = top pointer, -1 = bottom pointer
.globl TOP_POINTER_POSITION
TOP_POINTER_POSITION: .word -1 
.globl BOTTOM_POINTER_POSITION
BOTTOM_POINTER_POSITION: .word -1
TICK_STATE: .word 0 # state of tick which signals an update to the display
PREV_TICK_STATE: .word 0 # previous state of tick which signals an update to the display
TICKET_PERIOD_MS: .word 400 # period of tick which signals an update to the display
    ########################################

.text
# FUN game_loop
.globl game_loop
game_loop:
    jal update_tick

    jal try_get_next_keypress
    # $v0 = keypress
    move $a0, $v0
    jal key_handler

    jal routine_update_display

    jal sleep
    j game_loop

# END FUN game_loop


# FUN sleep
# Sleeps for TICKET_PERIOD_MS
sleep:
    lw $a0, TICKET_PERIOD_MS
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
