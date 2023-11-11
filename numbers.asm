.data
jTable: .word paint_zero, paint_one, paint_two, paint_three, paint_four, paint_five, paint_six, paint_seven, paint_eight, paint_nine

.text
# FUN paint_number
# ARGS:
# $a0: two digit number to paint
# $a1: buffer address
# $a2: color to paint
.globl paint_number
paint_number:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    move $s1, $a1 # copy buffer address to $s1
    move $s2, $a2 # copy color to $s2

    # $a0 = number to paint
    jal extract_digits
    bne $v0, $zero, paint_number_multi # if number is not zero, paint two digits

paint_number_single: # paint number with one digit
    move $a0, $v1 # copy number to $a0
    move $a1, $s1 # copy buffer address to $a1
    move $a2, $s2 # copy color to $a2
    jal paint_digit # paint number
    j paint_number_end

paint_number_multi: # paint number with two digits
    # paint first digit
    move $a0, $v0 # copy number to $a0
    addi $a1, $s1, -8 # copy buffer address to $a1, offset left by 2 pixels
    move $a2, $s2 # copy color to $a2
    jal paint_digit # paint first digit

    # paint second digit
    move $a0, $v1 # copy number to $a0
    addi $a1, $s1, 12 # copy buffer address to $a1, offset right by 3 pixels
    move $a2, $s2 # copy color to $a2
    jal paint_digit # paint second digit
    j paint_number_end

paint_number_end:
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20
    jr			$ra					# jump to $ra

# END FUN paint_number

.globl paint_digit
paint_digit:
    ############################################
    # paint_digit
    # paints a digit in a 4x7px grid
    # $a0 = digit to paint
    # $a1 = buffer address
    # $a2 = color
    ############################################

    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)


    move $s0, $a0 # copy number to $t1

    move $a0, $a1 # copy buffer address to $a0, this is later used by paint subroutines
    move $a1, $a2 # copy color to $a1, this is later used by paint subroutines


    sll $s0, $s0, 2 # $s1 = $s1 * 4
    la $t0, jTable # load address of jump table into $t0
    add $s0, $s0, $t0 # $s1 = $s1 + $t0, $s1 now points to the subroutine to call
    lw $s0 0($s0) # load subroutine address into $s1
    jr $s0 # jump to subroutine

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra



.globl paint_zero
paint_zero:
    ############################################
    # paint_zero
    # paints the number zero
    # $a0 = buffer address
    # $a1 = color
    # # # # #
    #   x x  
    # x     x
    # x     x
    # x     x 
    # x     x
    # x     x
    #   x x  
    # $t3 = row size in bytes
    # $t4 = -$t3
    ############################################
    addi    $sp,                            $sp,                -4      # decrement stack pointer
    sw      $ra,                            0($sp)                      # save return address

    move $a2, $a0
    move $a3, $a1

    # Draw 1 pixel right of  center. 
    li      $a0,                            1
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel right and 1 pixel up from center. 
    li      $a0,                            1
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 2 pixels up and 1 pixel right from center.
    li      $a0,                            1
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 3 pixels up from center.
    li      $a0,                            0
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 1 pixel left and 3 pixels up from center.
    li      $a0,                            -1
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 2 pixels left and 2 pixels up from center.
    li      $a0,                            -2
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 2 pixels left and 1 pixels up from center.
    li      $a0,                            -2
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 2 pixels left from center.
    li      $a0,                            -2
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel right and 1 pixel down from center.
    li      $a0,                            1
    li      $a1,                            -1
    jal     paint_pixel_relative

    # Draw 1 pixel right and 2 pixels down from center.
    li     $a0,                            1
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 3 pixels down from center.
    li      $a0,                            0
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 1 pixel left and 3 pixels down from center.
    li      $a0,                            -1
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 2 pixels left and 2 pixels down from center.
    li      $a0,                            -2
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 2 pixels left and 1 pixels down from center.
    li      $a0,                            -2
    li      $a1,                            -1
    jal     paint_pixel_relative

    lw      $ra,                            0($sp)
    addi  $sp,                            $sp,                4       # increment stack pointer
    jr      $ra



.globl paint_one
paint_one:
    ############################################
    # paint_one
    # paints the number one
    # $a0 = buffer address
    # $a1 = color
    # # # # #
    #     x
    #   x x
    # x   x
    #     x <- ($a0, $a1)
    #     x
    #     x
    # 	  x
    ############################################
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    move $a2, $a0
    move $a3, $a1

    # Draw pixel at center.
    li      $a0,                            0
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixels up from center.
    li      $a0,                            0
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 2 pixels up from center.
    li      $a0,                            0
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 3 pixels up from center.
    li      $a0,                            0
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 1 pixels down from center.
    li      $a0,                            0
    li      $a1,                            -1
    jal     paint_pixel_relative

    # Draw 2 pixels down from center.
    li      $a0,                            0
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 3 pixels down from center.
    li      $a0,                            0
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 1 pixel left and 2 pixels up from center.
    li      $a0,                            -1
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 2 pixels left and 1 pixel up from center.
    li      $a0,                            -2
    li      $a1,                            1
    jal     paint_pixel_relative

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    move 		$v0, $zero			# $v0 = $zero
    jr			$ra					# jump to $ra


.globl paint_two
paint_two:
    ############################################
    # paint_two
    # paints the number two
    # $a0 = buffer address
    # $a1 = color
    # # # # #
    #   x x
    # x     x
    #       x
    #     x <- ($a0, $a1)
    #   x
    # x
    # x x x x
    # $t3 = row size in bytes
    # $t4 = -$t3
    ############################################
    addi    $sp,                            $sp,                -4      # decrement stack pointer
    sw      $ra,                            0($sp)                      # save return address

    move $a2, $a0
    move $a3, $a1

    # Draw 1 pixel at center
    li      $a0,                            0
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel right and 3 pixel down from center
    li      $a0,                            1
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 3 pixels from down from center
    li      $a0,                            0
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 1 pixels left and 3 pixels down from center
    li      $a0,                            -1
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 2 pixels left and 3 pixels down from center
    li      $a0,                            -2
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 2 pixels left and 2 pixels down from center
    li      $a0,                            -2
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 1 pixels left and 1 pixels down from center
    li      $a0,                            -1
    li      $a1,                            -1
    jal     paint_pixel_relative

    # Draw 1 pixels right and 1 pixels up from center
    li      $a0,                            1
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 1 pixels right and 2 pixels up from center
    li      $a0,                            1
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 3 pixels up from center
    li      $a0,                            0
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 1 pixel left and 3 pixels up from center
    li      $a0,                            -1
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 2 pixel left and 2 pixels up from center
    li      $a0,                            -2
    li      $a1,                            2
    jal     paint_pixel_relative

    lw      $ra,                            0($sp)
    addi  $sp,                            $sp,                4       # increment stack pointer
    jr      $ra


.globl paint_three
paint_three:
    ############################################
    # paint_three
    # paints the number three
    # $a0 = buffer address
    # $a1 = color
    # # # # #
    #   x x
    # x     x
    #       x
    #   x x <- ($a0, $a1)
    #       x
    # x     x
    #   x x  
    # $t3 = row size in bytes
    # $t4 = -$t3
    ############################################
    addi    $sp,                            $sp,                -4      # decrement stack pointer
    sw      $ra,                            0($sp)                      # save return address

    move $a2, $a0
    move $a3, $a1

    # Draw 1 pixels up and 1 pixel right from center
    li      $a0,                            1
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 2 pixels up and 1 pixel right from center
    li      $a0,                            1
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 3 pixels down
    li      $a0,                            0
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 3 pixels down and 1 pixel left
    li      $a0,                            -1
    li      $a1,                             3
    jal     paint_pixel_relative

    # Draw 2 pixels up and 2 pixel left
    li      $a0,                            -2
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw pixel at center
    li      $a0,                            0
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel left from center
    li      $a0,                            -1
    li      $a1,                             0 
    jal     paint_pixel_relative

    # Draw 1 pixels down and 1 pixel right from center
    li      $a0,                            1
    li      $a1,                            -1
    jal     paint_pixel_relative

    # Draw 2 pixels down and 1 pixel right from center
    li      $a0,                            1
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 3 pixels down
    li      $a0,                            0
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 3 pixels down and 1 pixel left
    li      $a0,                            -1
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 2 pixels down and 2 pixel left
    li      $a0,                            -2
    li      $a1,                            -2
    jal     paint_pixel_relative

    lw      $ra,                            0($sp)
    addi  $sp,                            $sp,                4       # increment stack pointer
    jr      $ra


.globl paint_four
paint_four:
    ############################################
    # paint_four
    # paints the number four
    # $a0 = buffer address
    # $a1 = color
    # # # # #
    #       x
    #     x x
    #   x   x
    # x x x x 
    #       x
    #       x
    #       x
    # $t3 = row size in bytes
    # $t4 = -$t3
    ############################################
    addi    $sp,                            $sp,                -4      # decrement stack pointer
    sw      $ra,                            0($sp)                      # save return address

    move $a2, $a0
    move $a3, $a1

    # Draw pixel at center.
    li      $a0,                            0
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel right and 1 pixels up from center.
    li      $a0,                            1
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 1 pixel right 2 pixels up from center.
    li      $a0,                            1
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 1 pixel right and 3 pixels up from center.
    li      $a0,                            1
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 1 pixel right and 1 pixels down from center.
    li      $a0,                             1
    li      $a1,                            -1
    jal     paint_pixel_relative

    # Draw 1 pixel right and 2 pixels down from center.
    li      $a0,                             1
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 1 pixel right and 3 pixels down from center.
    li      $a0,                             1
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 1 pixel right from center.
    li      $a0,                            1
    li      $a1,                            0
    jal     paint_pixel_relative


    # Draw 1 pixel left from center.
    li      $a0,                            -1
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 2 pixels and 2 left from center.
    li      $a0,                            -2
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel up and 1 pixel left from center.
    li      $a0,                            -1
    li      $a1,                            1
    jal     paint_pixel_relative


    # Draw 2 pixels up from center.
    li      $a0,                            0
    li      $a1,                            2
    jal     paint_pixel_relative

    lw      $ra,                            0($sp)
    addi  $sp,                            $sp,                4       # increment stack pointer
    jr      $ra


.globl paint_five
paint_five:
    ############################################
    # paint_five
    # paints the number five
    # $a0 = buffer address
    # $a1 = color
    # # # # #
    # x x x x
    # x      
    # x x x  
    #       x 
    #       x
    # x     x
    #   x x  
    # $t3 = row size in bytes
    # $t4 = -$t3
    ############################################
    addi    $sp,                            $sp,                -4      # decrement stack pointer
    sw      $ra,                            0($sp)                      # save return address

    move $a2, $a0
    move $a3, $a1

    # Draw 1 pixel right of center.
    li      $a0,                            1
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel down and 1 right of center.
    li      $a0,                            1
    li      $a1,                            -1
    jal     paint_pixel_relative

    # Draw 2 pixels down and 1 right of center.
    li      $a0,                            1
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 3 pixels down from center.
    li      $a0,                            0
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 2 pixels down and 1 pixel left from center.
    li      $a0,                            -1
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 2 pixels down and 2 pixels left from center.
    li      $a0,                            -2
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 1 pixel up from center.
    li      $a0,                            0
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 1 pixel up and 1 pixel left from center.
    li      $a0,                            -1
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 1 pixel up and 2 pixel left from center.
    li      $a0,                            -2
    li      $a1,                            1
    jal     paint_pixel_relative


    # Draw 2 pixel up and 2 pixel left from center.
    li      $a0,                            -2
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 3 pixel up and 2 pixel left from center.
    li      $a0,                            -2
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 3 pixel up and 1 pixel left from center.
    li      $a0,                            -1
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 3 pixel up from center.
    li      $a0,                            0
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 3 pixel up and 1 right from center.
    li      $a0,                            1
    li      $a1,                            3
    jal     paint_pixel_relative

    lw      $ra,                            0($sp)
    addi  $sp,                            $sp,                4       # increment stack pointer
    jr      $ra


.globl paint_six
paint_six:
    ############################################
    # paint_six
    # paints the number six
    # $a0 = buffer address
    # $a1 = color
    # # # # #
    #   x x  
    # x     x
    # x      
    # x x x   
    # x     x
    # x     x
    #   x x  
    # $t3 = row size in bytes
    # $t4 = -$t3
    ############################################
    addi    $sp,                            $sp,                -4      # decrement stack pointer
    sw      $ra,                            0($sp)                      # save return address

    move $a2, $a0
    move $a3, $a1

    # Draw 1 pixel at center. 
    li      $a0,                            0
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel left of center. 
    li      $a0,                            -1
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 2 pixels left of center. 
    li      $a0,                            -2
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixels right and 1 pixel down from center. 
    li      $a0,                             1
    li      $a1,                            -1
    jal     paint_pixel_relative

    # Draw 1 pixels right and 2 pixels down from center. 
    li      $a0,                             1
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 3 pixels down from center. 
    li      $a0,                            0
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 3 pixels down and 1 pixel left from center. 
    li      $a0,                            -1
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 2 pixels down and 2 pixel left from center. 
    li      $a0,                            -2
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 2 pixels down and 2 pixel left from center. 
    li      $a0,                            -2
    li      $a1,                            -1
    jal     paint_pixel_relative

    # Draw 1 pixel up and 2 pixel left from center. 
    li      $a0,                            -2
    li      $a1,                             1
    jal     paint_pixel_relative

    # Draw 2 pixel up and 2 pixel left from center. 
    li      $a0,                            -2
    li      $a1,                             2
    jal     paint_pixel_relative

    # Draw 3 pixel up and 1 pixel left from center. 
    li      $a0,                            -1
    li      $a1,                             3
    jal     paint_pixel_relative

    # Draw 3 pixels up from center. 
    li      $a0,                             0
    li      $a1,                             3
    jal     paint_pixel_relative

    # Draw 1 pixels up and 2 pixels right from center. 
    li      $a0,                             1
    li      $a1,                             2
    jal     paint_pixel_relative

    lw      $ra,                            0($sp)
    addi  $sp,                            $sp,                4       # increment stack pointer
    jr      $ra


.globl paint_seven
paint_seven:
    ############################################
    # paint_seven
    # paints the number seven
    # $a0 = buffer address
    # $a1 = color
    # # # # #
    # x x x x
    #       x
    #       x
    #     x   
    #   x    
    #   x    
    #   x    
    # $t3 = row size in bytes
    # $t4 = -$t3
    ############################################
    addi    $sp,                            $sp,                -4      # decrement stack pointer
    sw      $ra,                            0($sp)                      # save return address

    move $a2, $a0
    move $a3, $a1

    # Draw pixel at center. 
    li      $a0,                            0
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel right and 1 pixel up from center. 
    li      $a0,                            1
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 2 pixels up and 1 pixel right from center.
    li      $a0,                            1
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 3 pixels up and 1 pixel right from center.
    li      $a0,                            1
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 1 pixels left and 1 pixels down from center.
    li      $a0,                            -1
    li      $a1,                            -1
    jal     paint_pixel_relative

    # Draw 2 pixels left and 2 pixels down from center.
    li      $a0,                            -1
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 2 pixels left and 3 pixels down from center.
    li      $a0,                            -1
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 3 pixels up from center.
    li      $a0,                            0
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 1 pixel left and 3 pixels up from center.
    li      $a0,                            -1
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 2 pixel left and 3 pixels up from center.
    li      $a0,                            -2
    li      $a1,                            3
    jal     paint_pixel_relative

    lw      $ra,                            0($sp)
    addi  $sp,                            $sp,                4       # increment stack pointer
    jr      $ra


.globl paint_eight
paint_eight:
    ############################################
    # paint_eight
    # paints the number eight
    # $a0 = buffer address
    # $a1 = color
    # # # # #
    #   x x  
    # x     x
    # x     x
    #   x x   
    # x     x
    # x     x
    #   x x  
    # $t3 = row size in bytes
    # $t4 = -$t3
    ############################################
    addi    $sp,                            $sp,                -4      # decrement stack pointer
    sw      $ra,                            0($sp)                      # save return address

    move $a2, $a0
    move $a3, $a1

    # Draw pixel at center. 
    li      $a0,                            0
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel right and 1 pixel up from center. 
    li      $a0,                            1
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 2 pixels up and 1 pixel right from center.
    li      $a0,                            1
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 3 pixels up from center.
    li      $a0,                            0
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 1 pixel left and 3 pixels up from center.
    li      $a0,                            -1
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 2 pixels left and 2 pixels up from center.
    li      $a0,                            -2
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 2 pixels left and 1 pixels up from center.
    li      $a0,                            -2
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 1 pixel left from center.
    li      $a0,                            -1
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel right and 1 pixel down from center.
    li      $a0,                            1
    li      $a1,                            -1
    jal     paint_pixel_relative

    # Draw 1 pixel right and 2 pixels down from center.
    li     $a0,                            1
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 3 pixels down from center.
    li      $a0,                            0
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 1 pixel left and 3 pixels down from center.
    li      $a0,                            -1
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 2 pixels left and 2 pixels down from center.
    li      $a0,                            -2
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 2 pixels left and 1 pixels down from center.
    li      $a0,                            -2
    li      $a1,                            -1
    jal     paint_pixel_relative

    lw      $ra,                            0($sp)
    addi  $sp,                            $sp,                4       # increment stack pointer
    jr      $ra


.globl paint_nine
paint_nine:
    ############################################
    # paint_nine
    # paints the number nine
    # $a0 = buffer address
    # $a1 = color
    # # # # #
    #   x x  
    # x     x
    # x     x
    #   x x x 
    #       x
    # x     x
    #   x x  
    # $t3 = row size in bytes
    # $t4 = -$t3
    ############################################
    addi    $sp,                            $sp,                -4      # decrement stack pointer
    sw      $ra,                            0($sp)                      # save return address

    move $a2, $a0
    move $a3, $a1

    # Draw pixel at center. 
    li      $a0,                            0
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel right of center.
    li      $a0,                            1
    li      $a1,                            0
    jal     paint_pixel_relative

    # Draw 1 pixel left of center.
    li      $a0,                            -1
    li      $a1,                            0
    jal    paint_pixel_relative

    # Draw 2 pixels left and 1 pixel up from center.
    li      $a0,                            -2
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 2 pixels left and 2 pixels up from center.
    li      $a0,                            -2
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 1 pixel left and 3 pixels up from center.
    li      $a0,                            -1
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 3 pixels up from center.
    li      $a0,                            0
    li      $a1,                            3
    jal     paint_pixel_relative

    # Draw 2 pixels up and 1 pixel right from center.
    li      $a0,                            1
    li      $a1,                            2
    jal     paint_pixel_relative

    # Draw 1 pixel right and 1 pixel up from center.
    li      $a0,                            1
    li      $a1,                            1
    jal     paint_pixel_relative

    # Draw 1 pixel down and 1 pixel right from center.
    li      $a0,                            1
    li      $a1,                            -1
    jal     paint_pixel_relative

    # Draw 2 pixels down and 1 pixel right from center.
    li      $a0,                            1
    li      $a1,                            -2
    jal     paint_pixel_relative

    # Draw 3 pixels down from center.
    li      $a0,                            0
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 3 pixels down and 1 pixel left from center.
    li      $a0,                            -1
    li      $a1,                            -3
    jal     paint_pixel_relative

    # Draw 2 pixels down and 2 pixel left from center.
    li      $a0,                            -2
    li      $a1,                            -2
    jal     paint_pixel_relative

    lw      $ra,                            0($sp)
    addi  $sp,                            $sp,                4       # increment stack pointer
    jr      $ra

