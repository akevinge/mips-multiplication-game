.data
    # Keyboard ############################
KEYBOARD: .word 0xFFFF0004
A_KEY: .word 0x00000061
D_KEY: .word 0x00000064
Q_KEY: .word 0x00000071
    #######################################

.text
# FUN try_get_next_keypress
# Attempts to get the next keypress from the keyboard, if any.
# RETURN VALUE: $v0 = 0 if no keypress, otherwise ASCII value of keypress
.globl try_get_next_keypress
try_get_next_keypress:
    lw $a0, KEYBOARD
    lw $v0, 0($a0)
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

_a_key_case:
    lw $t0, A_KEY
    bne $a0, $t0, _d_key_case
    j _key_handler_end

_d_key_case:
    lw $t0, D_KEY
    bne $a0, $t0, _q_key_case
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

# FUN a_key_handler
a_key_handler:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN a_key_handler