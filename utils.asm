.data
NEWLINE: .asciiz "\n"

.text
.globl extract_digits
# FUN extract_digits
# ARGS:
# $a0: a two digit, 4B integer
# RETURN $v0: left digit, $v1: right digit
extract_digits:
    addi		$sp, $sp, -4			# $sp -= 4
    sw			$ra, 0($sp)

    li $t1, 10
    
    beq $t1, $a0, extract_digits_ten # equal to 10
    bgt $a0, $t1, extract_digits_mult # greater than 10
    move $v0, $zero
    move $v1, $a0
    j extract_digits_end

extract_digits_mult:
    div $a0, $t1
    mflo $v0
    mfhi $v1
    j extract_digits_end

extract_digits_ten:
    li $v0, 1
    move $v1, $zero

extract_digits_end:
    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN extract_digits


# FUN coord_to_index
# Calculates cell index given row and column
# ARGS:
# $a0: row (0-indexed)
# $a1: column (0-indexed)
# RETURN:
# $v0: cell index (0-35)
.globl coord_to_index
coord_to_index:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    lw $t0, BOARD_WIDTH_CELLS
    mul $t0, $t0, $a0 # row number * SIZE
    add $v0, $t0, $a1 # $v0 = cell index = row number * SIZE + column number
    
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END coord_to_index


# FUN index_to_coord
# Calculate row and column given cell index
# ARGS:
# $a0: cell index
# RETURN:
# $v0: row number (0-indexed)
# $v1: column number (0-indexed)
.globl index_to_coord
index_to_coord:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    lw $t0, BOARD_WIDTH_CELLS
    div $a0, $t0 # LAST_SELECTED_CELL_IDX / BOARD_WIDTH_CELLS = ROW r COLUMN
    mflo $v0
    mfhi $v1
    
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END index_to_coord


# FUN print_newline
.globl print_newline
print_newline:
    addi		$sp, $sp, -4			# $sp -= 4
    sw			$ra, 0($sp)

    li $v0, 4
    la $a0, NEWLINE
    syscall
    
    addi		$sp, $sp, 4			# $sp += 4
    jr			$ra					# jump to $ra

# END FUN print_newline
