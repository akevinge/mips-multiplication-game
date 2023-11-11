############################################
# Unit Width in Pixels: 4
# Unit Height in Pixels: 4
# Display Width in Pixels: 1024
# Display Height in Pixels: 1024
# Display Unit Size: 256x256
# Frame Buffer Address: 0x10040000 (heap)
# Frame Buffer Size: 65536 (256x256)
############################################

.data
    ###
    # Display ###########################
FRAME_BUFFER:       .word   0x10040000                          # frame buffer address
FRAME_BUFFER_SIZE:  .word   65536                               # 256x256 units
ROW_SIZE_BYTES:    .word   1024                                 # 256units x 4B
NEG_ROW_SIZE_BYTES: .word   -1024                                # -256units x 4B
CELL_WIDTH: .word 16 # cell width in pixels
CELL_HEIGHT: .word 16 # cell height in pixels
BOARD_NUMBERLINE_ROW_GAP: .word 16 # number of rows between board and number line
BOARD_NUMBERLINE_CELL_SIZE: .word 16 # size of each cell in number line in pixels
    ####################################

.text

# ██████╗ ██╗███████╗██████╗ ██╗      █████╗ ██╗   ██╗    ██╗   ██╗████████╗██╗██╗     ███████╗
# ██╔══██╗██║██╔════╝██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝    ██║   ██║╚══██╔══╝██║██║     ██╔════╝
# ██║  ██║██║███████╗██████╔╝██║     ███████║ ╚████╔╝     ██║   ██║   ██║   ██║██║     ███████╗
# ██║  ██║██║╚════██║██╔═══╝ ██║     ██╔══██║  ╚██╔╝      ██║   ██║   ██║   ██║██║     ╚════██║
# ██████╔╝██║███████║██║     ███████╗██║  ██║   ██║       ╚██████╔╝   ██║   ██║███████╗███████║
# ╚═════╝ ╚═╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝        ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝
                                                                                             
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

# FUN paint_pixel_relative
# paints a pixel relative to a center point
# ARGS:
# $a0: x position of center
# $a1: y position of center
# $a2: buffer address
# $a3: color
.globl paint_pixel_relative
paint_pixel_relative:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    li      $t0,                            4                           # load 4 into $t0
    mult    $a0,                            $t0                         # multiply x position by 4 bytes
    mflo    $t1                                                         # move result to $t1, this is our x offset

    lw      $t0,                            NEG_ROW_SIZE_BYTES          # load row size in bytes
    mult    $a1,                            $t0                         # multiply y position by row size
    mflo    $t2                                                         # move result to $t2, this is our y offset

    add     $t3,                            $t1,                $t2     # add x and y offsets to get pixel offset
    add     $t3,                            $t3,                $a2     # add pixel offset to buffer address

    move $a0, $t3
    move $a1, $a3
    jal paint_pixel # paint pixel

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    move 		$v0, $zero			# $v0 = $zero
    jr			$ra					# jump to $ra

# END FUN paint_pixel_relative

# FUN paint_cell_number
# paints the number of a cell given the cell number and frame buffer address of cell center
# ARGS:
# $a0: cell number
# $a1: frame buffer address of cell center
paint_cell_number:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    # calculate center of cell
    # $t1 = cell width in bytes / 2
    lw $t0, CELL_WIDTH
    srl $t1, $t0, 1 # divide cell width by 2
    sll $t1, $t1, 2 # multiply by 4 because each pixel is 4 bytes

    # t2 = (cell height / 2) * row size in bytes
    lw $t0, CELL_HEIGHT
    srl $t2, $t0, 1
    lw $t0, ROW_SIZE_BYTES
    mult $t2, $t0
    mflo $t2

    add $s0, $a1, $t1
    add $s0, $s0, $t2 # $s0 = frame buffer address of cell center

    # $a0 = cell number
    move $a1, $s0 # move frame buffer address of cell center to $a1
    lw $a2, WHITE # load cell color
    jal paint_number  # paint cell number

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    move 		$v0, $zero			# $v0 = $zero
    jr			$ra					# jump to $ra

# END FUN paint_cell_number


# FUN paint_cell_borders
# ARGS:
# $a0: frame buffer address of top left corner of cell position
paint_cell_borders:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    move $s0, $a0 # copy frame buffer address to $s0

    li $s1, 0 # initialize pixel index iterator to 0
top_border_l1:
    move $a0, $s0 # move frame buffer address to $a0
    lw $a1, WHITE # load border color
    jal paint_pixel

    addi $s0, $s0, 4 # increment frame buffer address by 4 bytes
    addi $s1, $s1, 1 # increment pixel index iterator
    lw $t0, CELL_WIDTH
    bne $s1, $t0, top_border_l1 # if pixel index iterator is not equal to cell width, jump to top_border_l2

    li $s1, 0 # initialize pixel index iterator to 0
    # $s5 = frame buffer address of top right corner of cell
right_border_l1:
    move $a0, $s0 # move frame buffer address to $a0
    lw $a1, WHITE # load border color
    jal paint_pixel

    lw $t0, ROW_SIZE_BYTES
    add $s0, $s0, $t0 # increment frame buffer address by row size in bytes
    addi $s1, $s1, 1 # increment pixel index iterator
    lw $t0, CELL_HEIGHT
    bne $s1, $t0, right_border_l1 # if pixel index iterator is not equal to cell height, jump to right_border_l1
    
    li $s1, 0 # initialize pixel index iterator to 0
    # $s5 = frame buffer address of bottom right corner of cell
bottom_border_l1:
    move $a0, $s0 # move frame buffer address to $a0
    lw $a1, WHITE # load border color
    jal paint_pixel

    addi $s0, $s0, -4 # decrement frame buffer address by 4 bytes
    addi $s1, $s1, 1 # increment pixel index iterator
    lw $t0, CELL_WIDTH
    bne $s1, $t0, bottom_border_l1 # if pixel index iterator is not equal to cell width, jump to bottom_border_l1

    li $s1, 0 # initialize pixel index iterator to 0
    # $s5 = frame buffer address of bottom left corner of cell
left_border_l1:
    move $a0, $s0 # move frame buffer address to $a0
    lw $a1, WHITE # load border color
    jal paint_pixel

    lw $t0, NEG_ROW_SIZE_BYTES
    add $s0, $s0, $t0 # decrement frame buffer address by row size in bytes
    addi $s1, $s1, 1 # increment pixel index iterator
    lw $t0, CELL_HEIGHT
    bne $s1, $t0, left_border_l1 # if pixel index iterator is not equal to cell height, jump to left_border_l1

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN paint_cell_borders


# ██████╗ ██╗███████╗██████╗ ██╗      █████╗ ██╗   ██╗    
# ██╔══██╗██║██╔════╝██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝    
# ██║  ██║██║███████╗██████╔╝██║     ███████║ ╚████╔╝     
# ██║  ██║██║╚════██║██╔═══╝ ██║     ██╔══██║  ╚██╔╝      
# ██████╔╝██║███████║██║     ███████╗██║  ██║   ██║       
# ╚═════╝ ╚═╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝       
                                                        
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
    la $s5, BOARD # load board address

paint_board_l1:
    move $a0, $s3 # move cell iterator to $a0
    lw $s1, WHITE # load cell color
    lw $a2, 0($s5) # load number from board into $a5
    jal paint_board_cell # paint cell

    addi $s3, $s3, 1 # increment cell iterator
    addi $s5, $s5, 4 # increment board address by 4 bytes
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

    move $s1, $a2 # copy cell value to $s1

    # $a0 = cell number (0-35)
    jal calculate_board_cell_position
    # $v0 = byte position in frame buffer for top left cell position
    lw $t0, FRAME_BUFFER
    add $s0, $t0, $v0 # add top left cell position in bytes to frame buffer address

    move $a0, $s0
    jal paint_cell_borders

    move $a0, $s1 # move cell value to $a0
    move $a1, $s0 # move frame buffer address of top left corner of cell position to $a1
    jal paint_cell_number

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra


.globl calculate_board_cell_position
calculate_board_cell_position:
    ############################################
    # calculate_board_cell_position
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

# FUN paint_numberline
.globl paint_numberline
paint_numberline:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    li $s3, 0 # initialize cell iterator to 0
paint_numberline_l1:
    move $a0, $s3 # move cell iterator to $a0
    lw $a1, WHITE
    jal paint_numberline_cell_number
    
    addi $s3, $s3, 1 # increment cell iterator
    bne $s3, 9, paint_numberline_l1 # if cell iterator is not equal to 8, jump to paint_numberline_l1

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN paint_numberline

paint_numberline_cell_number:
    ############################################
    # paint_numberline_cell_number
    # paints a cell of the board
    # Each cell is 15px x 13px (including border).
    # $a0 = cell number (0-8)
    # $a1 = cell color
    ############################################
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    move $s1, $a0 # copy cell value to $s1

    # $a0 = cell number (0-35)
    jal calculate_numberline_cell_position
    # $v0 = byte position in frame buffer for top left cell position
    lw $t0, FRAME_BUFFER
    add $s0, $t0, $v0 # add top left cell position in bytes to frame buffer address

    move $a0, $s0
    jal paint_cell_borders

    move $a0, $s1 # move cell value to $a0
    move $a1, $s0 # move frame buffer address of top left corner of cell position to $a1
    jal paint_cell_number

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra


# FUN calculate_numberline_cell_position
# calculates the top left position of a cell in the number line in the frame buffer
# ARGS:
# $a0: number (0-8)
# RETURN $v0: top left position of number line (bytes) in frame buffer
calculate_numberline_cell_position:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    jal calculate_number_line_position # calculate top left position of number line in frame buffer
    move $s0, $v0 # copy top left position of number line in frame buffer to $s0

    lw $t0, BOARD_NUMBERLINE_CELL_SIZE
    li $t1, 4
    mult $t0, $t1
    mflo $t2 # $t2 = cell width in bytes

    mult $a0, $t2 # multiply cell number by cell width in bytes
    mflo $t3 # $t3 = cell number * cell width in bytes

    add $v0, $s0, $t3 # $v0 = top left position of cell in number line in frame buffer

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN calculate_numberline_cell_position


# FUN calculate_number_line_position
# calculates the top left position of the number line in the frame buffer
# RETURN $v0: top left position of number line in frame buffer
.globl calculate_number_line_position
calculate_number_line_position:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    # number of rows * cell height in pixels * ROW_SIZE_BYTES
    lw $t0, BOARD_HEIGHT_CELLS
    lw $t1, CELL_HEIGHT
    mult $t0, $t1
    mflo $t3

    lw $t2, ROW_SIZE_BYTES
    mult $t3, $t2
    mflo $s0 # $s0 = number of rows * cell height in bytes (number of rows to skip) * ROW_SIZE_BYTES
    
    # gap between board and number line * ROW_SIZE_BYTES
    lw $t0, BOARD_NUMBERLINE_ROW_GAP
    mult $t0, $t2
    mflo $s2 # $s2 = gap between board and number line in bytes

    add $v0, $s0, $s2 # $v1 = top right of number line in frame buffer

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN calculate_number_line_position

