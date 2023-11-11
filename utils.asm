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