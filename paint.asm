# FUN paint_pixel
# paints a pixel at specific position in frame buffer address
# ARGS:
# $a0: address to paint pixel
# $a1: color of pixel
.globl paint_pixel
paint_pixel:
    addi		$sp, $sp, -4			# $sp -= 4
    sw			$ra, 0($sp)

    sw			$a1, 0($a0)				# store color in frame buffer

    lw			$ra, 0($sp)
    addi		$sp, $sp, 4			# $sp += 4
    jr			$ra					# jump to $ra

# END FUN paint_pixel


# FUN paint_background
# paints the entire background with BACKGROUND_COLOR
.globl paint_background
paint_background:   
    addi		$sp, $sp, -4			# $sp -= 4
    sw			$ra, 0($sp)

    lw      $t0,                    FRAME_BUFFER                # load frame buffer address
    lw      $t1,                    FRAME_BUFFER_SIZE           # load frame size
    lw      $t2,                    BACKGROUND_COLOR            # load background color

paint_background_loop:
    move $a0, $t0                                               # move frame buffer address to $a0
    move $a1, $t2                                               # move background color to $a1
    jal paint_pixel

    addi    $t0,                    $t0,                    4   # advance to next pixel position in display
    addi    $t1,                    $t1,                    -1  # decrement number of pixels
    bnez    $t1,                    paint_background_loop       # repeat while number of pixels is not zero

    lw      $ra,                    0($sp)                      # restore $ra
    addi    $sp,                    $sp,                    4   # $sp += 4
    jr      $ra                                                 # return

# END FUN paint_background

.globl paint_board
paint_board:
    ############################################
    # paint_board
    # paints the board
    ############################################

    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    lw $s0, BOARD_WIDTH_CELLS # number of cells per row
    lw $s1, BOARD_HEIGHT_CELLS # number of rows

    mult $s0, $s1 # multiply number of cells per row by number of rows
    mflo $s2 # store total number of cells in $s2

    li $s3, 0 # initialize cell iterator to 0
    lw $s4, WHITE
    # TODO: load number from board into $a2

paint_board_l1:
    move $a0, $s3 # move cell iterator to $a0
    move $a1, $s4 # move cell color to $a1
    jal paint_board_cell # paint cell

    addi $s3, $s3, 1 # increment cell iterator
    bne $s3, $s2, paint_board_l1 # if cell iterator is not equal to total number of cells, jump to paint_board_l1

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

.globl paint_board_cell
paint_board_cell:
    ############################################
    # paint_board_cell
    # paints a cell of the board
    # Each cell is 15px x 13px (including border).
    # $a0 = cell number (0-35)
    # $a1 = cell color
    # $a2 = cell value
    ############################################
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    lw $s0, FRAME_BUFFER # load frame buffer address
    lw $s1, CELL_WIDTH # load cell width
    lw $s2, CELL_HEIGHT # load cell height
    lw $s3, ROW_SIZE_BYTES # load row size in bytes
    lw $s6, NEG_ROW_SIZE_BYTES # load negative row size in bytes


    # $a0 = cell number (0-35)
    jal calculate_cell_position
    # $v0 = byte position in frame buffer for top left cell position
    add $s0, $s0, $v0 # add top left cell position in bytes to frame buffer address

    li $s4, 0 # initialize pixel index iterator to 0
    move $s5, $s0 # copy frame buffer address to $s4
top_border_l1:
    move $a0, $s5 # move frame buffer address to $a0
    lw $a1, WHITE # load border color
    jal paint_pixel

    addi $s5, $s5, 4 # increment frame buffer address by 4 bytes
    addi $s4, $s4, 1 # increment pixel index iterator
    bne $s4, $s1, top_border_l1 # if pixel index iterator is not equal to cell width, jump to top_border_l2

    li $s4, 0 # initialize pixel index iterator to 0
    # $s5 = frame buffer address of top right corner of cell
right_border_l1:
    move $a0, $s5 # move frame buffer address to $a0
    lw $a1, WHITE # load border color
    jal paint_pixel

    add $s5, $s5, $s3 # increment frame buffer address by row size in bytes
    addi $s4, $s4, 1 # increment pixel index iterator
    bne $s4, $s2, right_border_l1 # if pixel index iterator is not equal to cell height, jump to right_border_l1

    
    li $s4, 0 # initialize pixel index iterator to 0
    # $s5 = frame buffer address of bottom right corner of cell
bottom_border_l1:
    move $a0, $s5 # move frame buffer address to $a0
    lw $a1, WHITE # load border color
    jal paint_pixel

    addi $s5, $s5, -4 # decrement frame buffer address by 4 bytes
    addi $s4, $s4, 1 # increment pixel index iterator
    bne $s4, $s1, bottom_border_l1 # if pixel index iterator is not equal to cell width, jump to bottom_border_l1

    li $s4, 0 # initialize pixel index iterator to 0
    # $s5 = frame buffer address of bottom left corner of cell

left_border_l1:
    move $a0, $s5 # move frame buffer address to $a0
    lw $a1, WHITE # load border color
    jal paint_pixel

    add $s5, $s5, $s6 # decrement frame buffer address by row size in bytes
    addi $s4, $s4, 1 # increment pixel index iterator
    bne $s4, $s2, left_border_l1 # if pixel index iterator is not equal to cell height, jump to left_border_l1


    # calculate center of cell
    # $t1 = cell width in bytes / 2
    li $t0, 2
    div $s1, $t0
    mflo $t1
    li $t2, 4
    mult $t1, $t2
    mflo $t1

    addi $t1, $t1, 4 # move over 4 bytes because number center is 4 bytes right, this just centers it properly

    # t2 = (cell height / 2) * row size in bytes
    div $s2, $t0
    mflo $t2
    mult $t2, $s3
    mflo $t2

    move $s5, $s0 # copy frame buffer address to $s5
    add $s5, $s5, $t1 # add cell width in bytes / 2 to frame buffer address
    add $s5, $s5, $t2 # add (cell height / 2) * row size in bytes to frame buffer address

    li $a0, 0 # load 0 into $a0
    move $a1, $s5 # move frame buffer address to $a0
    lw $a2, WHITE
    jal paint_number

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

.globl calculate_cell_position
calculate_cell_position:
    ############################################
    # calculate_cell_position
    # calculates the top left position of a cell 
    # $a0 = cell number (0-35)
    # return: 
    # $v0 = byte position in frame buffer for top left cell position
    ############################################

    # save registers
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    lw $t0, BOARD_WIDTH_CELLS # number of cells per row
    lw $t1, BOARD_HEIGHT_CELLS # number of rows
    lw $t2, CELL_WIDTH # load cell width
    lw $t3, CELL_HEIGHT # load cell height in bytes
    lw $t4, ROW_SIZE_BYTES # load negative row size in bytes

    # $t2 = cell width in bytes = CELL_WIDTH * 4
    li $t5, 4
    mult $t2, $t5
    mflo $t2

    # $s0 = row number (0-indexed)
    # $s1 = column number (0-indexed)
    # $s2 = top left cell y position in bytes
    # $s3 = top left cell x position in bytes

    # row number = floor(cell number / BOARD_WIDTH_CELLS) (0-indexed)
    div $a0, $t0 
    mflo $s0

    # column number = remainder (0-indexed)
    mfhi $s1

    # top left cell y position = ROW_SIZE_BYTES * row number * CELL_HEIGHT (number of rows to skip)
    mult $s0, $t3
    mflo $t5
    mult $t4, $t5
    mflo $s2

    # top left cell x position in bytes = y position in bytes + column number * CELL_WIDTH_BYTES
    mult $s1, $t2
    mflo $s3

    add $v0, $s2, $s3 # $v0 = top left cell position in bytes

    # restore registers
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20
    jr $ra

