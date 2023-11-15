.data
    # Keyboard ############################
KEYBOARD: .word 0xFFFF0004
L_KEY: .word 0x0000006C # move selected pointer to the right
H_KEY: .word 0x00000068 # move selected pointer to the left
K_KEY: .word 0x0000006B # select top pointer
J_KEY: .word 0x0000006A # select bottom pointer
Q_KEY: .word 0x00000071 # quit
ENTER_KEY: .word 0x0000000A # enter
    #######################################

.text
# FUN try_get_next_keypress
# Attempts to get the next keypress from the keyboard, if any.
# RETURN VALUE: $v0 = 0 if no keypress, otherwise ASCII value of keypress
.globl try_get_next_keypress
try_get_next_keypress:
    lw $a0, KEYBOARD
    lw $v0, 0($a0)
    sw $zero, 0($a0) # clear keyboard
    jr			$ra					# jump to $ra

# END FUN try_get_next_keypress

# FUN key_handler
# ARGS:
# $a0: hex value of key pressed
.globl key_handler
key_handler:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

_enter_key_case:
    lw $t0, ENTER_KEY
    bne $a0, $t0, _l_key_case
    jal make_board_selection
    j _key_handler_end

_l_key_case:
    lw $t0, L_KEY
    bne $a0, $t0, _h_key_case
    jal increment_selected_pointer
    j _key_handler_end

_h_key_case:
    lw $t0, H_KEY
    bne $a0, $t0, _k_key_case
    jal decrement_selected_pointer
    j _key_handler_end

_k_key_case:
    lw $t0, K_KEY
    bne $a0, $t0, _j_key_case
    jal select_top_pointer
    j _key_handler_end

_j_key_case:
    lw $t0, J_KEY
    bne $a0, $t0, _q_key_case
    jal select_bottom_pointer
    j _key_handler_end

_q_key_case:
    lw $t0, Q_KEY
    bne $a0, $t0, _key_handler_end
    j terminate
    
_key_handler_end:
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    move 		$v0, $zero			# $v0 = $zero
    jr			$ra					# jump to $ra

# END FUN key_handler