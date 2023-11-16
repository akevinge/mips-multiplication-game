.text
# FUN paint_a
# ARGS:
# $a0 = buffer address
# $a1 = color
.globl paint_a
paint_a:
    addi		$sp, $sp, -4
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    li      $a0, 1
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -3
    jal     paint_pixel_relative
        
    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN paint_a


# FUN paint_e
# ARGS:
# $a0 = buffer address
# $a1 = color
.globl paint_e
paint_e:
    addi		$sp, $sp, -4
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    li      $a0, 1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -3
    jal     paint_pixel_relative
        
    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN paint_e


# FUN paint_o
# ARGS:
# $a0 = buffer address
# $a1 = color
.globl paint_o
paint_o:
    addi		$sp, $sp, -4
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    li      $a0, 1
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -2
    jal     paint_pixel_relative

        
    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN paint_o


# FUN paint_p
# ARGS:
# $a0 = buffer address
# $a1 = color
.globl paint_p
paint_p:
    addi		$sp, $sp, -4
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    li      $a0, 1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -3
    jal     paint_pixel_relative

    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN paint_p


# FUN paint_m
# ARGS:
# $a0 = buffer address
# $a1 = color
.globl paint_m
paint_m:
    addi		$sp, $sp, -4
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    li      $a0, 1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -3
    jal     paint_pixel_relative

    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN paint_m


# FUN paint_n
# ARGS:
# $a0 = buffer address
# $a1 = color
.globl paint_n
paint_n:
    addi		$sp, $sp, -4
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    li      $a0, 1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -3
    jal     paint_pixel_relative

    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN paint_n


# FUN paint_r
# ARGS:
# $a0 = buffer address
# $a1 = color
.globl paint_r
paint_r:
    addi		$sp, $sp, -4
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    li      $a0, 1
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -3
    jal     paint_pixel_relative

    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN paint_r


# FUN paint_s
# ARGS:
# $a0 = buffer address
# $a1 = color
.globl paint_s
paint_s:
    addi		$sp, $sp, -4
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    li      $a0, 1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -3
    jal     paint_pixel_relative

    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN paint_s


# FUN paint_t
# ARGS:
# $a0 = buffer address
# $a1 = color
.globl paint_t
paint_t:
    addi		$sp, $sp, -4
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    li      $a0, 1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 3
    jal     paint_pixel_relative

    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN paint_t


# FUN paint_u
# ARGS:
# $a0 = buffer address
# $a1 = color
.globl paint_u
paint_u:
    addi		$sp, $sp, -4
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    li      $a0, 1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -2
    jal     paint_pixel_relative

    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN paint_u


# FUN paint_v
# ARGS:
# $a0 = buffer address
# $a1 = color
.globl paint_v
paint_v:
    addi		$sp, $sp, -4
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    li      $a0, 1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, -2
    jal     paint_pixel_relative

    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN paint_v


# FUN paint_y
# ARGS:
# $a0 = buffer address
# $a1 = color
.globl paint_y
paint_y:
    addi		$sp, $sp, -4
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    li      $a0, 1
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, 1
    li      $a1, 1
    jal     paint_pixel_relative

    li      $a0, 0
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, 0
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, -1
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, -2
    jal     paint_pixel_relative

    li      $a0, -1
    li      $a1, -3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 3
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 2
    jal     paint_pixel_relative

    li      $a0, -2
    li      $a1, 1
    jal     paint_pixel_relative

    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4

    jr			$ra					# jump to $ra

# END FUN paint_y