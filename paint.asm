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
LEFT_BOARD_OFFSET: .word 364 # offset of board from left edge of screen in bytes (4B = 1unit)
LEFT_NUMBERLINE_OFFSET: .word 264 # offset of number line from left edge of screen in bytes (4B = 1unit)
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


# ██████╗  █████╗  ██████╗██╗  ██╗ ██████╗ ██████╗  ██████╗ ██╗   ██╗███╗   ██╗██████╗ 
# ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝ ██╔══██╗██╔═══██╗██║   ██║████╗  ██║██╔══██╗
# ██████╔╝███████║██║     █████╔╝ ██║  ███╗██████╔╝██║   ██║██║   ██║██╔██╗ ██║██║  ██║
# ██╔══██╗██╔══██║██║     ██╔═██╗ ██║   ██║██╔══██╗██║   ██║██║   ██║██║╚██╗██║██║  ██║
# ██████╔╝██║  ██║╚██████╗██║  ██╗╚██████╔╝██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
# ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ 
                                                        
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

# ██████╗  ██████╗  █████╗ ██████╗ ██████╗ 
# ██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔══██╗
# ██████╔╝██║   ██║███████║██████╔╝██║  ██║
# ██╔══██╗██║   ██║██╔══██║██╔══██╗██║  ██║
# ██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝
# ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ 

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
    lw $a1, BACKGROUND_COLOR # load cell color
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


# FUN paint_board_cell_background
# Paints the background of a cell (excluding borders).
# ARGS:
# $a0: frame buffer address of top left corner to start painting from
# $a1: cell background color
paint_board_cell_background:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    move $s0, $a0 # copy frame buffer address to $s0
    move $s3, $a1 # copy cell background color to $s3

    li $s1, 0 # initialize row index iterator to 0
_paint_board_cell_background_l1: # iterate over each row
    lw $t0, CELL_WIDTH
    addi $t0, $t0, -1 # subtract 2 from cell width to skip border
    beq $s1, $t0, _paint_board_cell_background_end # if row index iterator is equal to cell width - 2, jump to _paint_board_cell_background_l2

    addi $s1, $s1, 1 # increment row index iterator

    li $s2, 0 # initialize column index iterator to 0
_paint_board_cell_background_l2:
    lw $t0, CELL_HEIGHT
    addi $t0, $t0, -1 # subtract 2 from cell height to skip border
    beq $s2, $t0, _paint_board_cell_background_l1 # if column index iterator is equal to cell height - 2, jump to _paint_board_cell_background_l1

    move $t0, $s2
    sll $t0, $t0, 2 # column index * 4 = x offset in bytes

    move $t1, $s1
    lw $t2, ROW_SIZE_BYTES
    mul $t1, $t2, $t1 # row index * row size in bytes = y offset in bytes

    add $t3, $t0, $t1 # x offset + y offset = offset in bytes
    add $t3, $t3, $s0 # frame buffer + offset

    move $a0, $t3 # move frame buffer address to $a0
    move $a1, $s3
    jal paint_pixel

    addi $s2, $s2, 1 # increment column index iterator
    j _paint_board_cell_background_l2

_paint_board_cell_background_end:
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN paint_board_cell_background

.globl paint_board_cell
paint_board_cell:
    ############################################
    # paint_board_cell
    # paints a cell of the board
    # Each cell is 15px x 13px (including border).
    # $a0 = cell number (0-35)
    # $a1 = cell background color
    # $a2 = cell value
    ############################################
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    move $s1, $a2 # copy cell value to $s1
    move $s2, $a1 # copy cell background color to $s2

    # $a0 = cell number (0-35)
    jal calculate_board_cell_position
    # $v0 = byte position in frame buffer for top left cell position
    lw $t0, FRAME_BUFFER
    add $s0, $t0, $v0 # add top left cell position in bytes to frame buffer address

    move $a0, $s0
    jal paint_cell_borders

    add $a0, $s0, 4 # move right one pixel to skip left border column
    move $a1, $s2 # move cell background color to $a1
    jal paint_board_cell_background

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
    lw $t0, LEFT_BOARD_OFFSET
    add $v0, $v0, $t0 # $v0 = top left cell position in bytes + left display offset

    # restore registers
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20
    jr $ra


# ███╗   ██╗██╗   ██╗███╗   ███╗██████╗ ███████╗██████╗ ██╗     ██╗███╗   ██╗███████╗
# ████╗  ██║██║   ██║████╗ ████║██╔══██╗██╔════╝██╔══██╗██║     ██║████╗  ██║██╔════╝
# ██╔██╗ ██║██║   ██║██╔████╔██║██████╔╝█████╗  ██████╔╝██║     ██║██╔██╗ ██║█████╗  
# ██║╚██╗██║██║   ██║██║╚██╔╝██║██╔══██╗██╔══╝  ██╔══██╗██║     ██║██║╚██╗██║██╔══╝  
# ██║ ╚████║╚██████╔╝██║ ╚═╝ ██║██████╔╝███████╗██║  ██║███████╗██║██║ ╚████║███████╗
# ╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝
                                                                                   
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
    move $a0, $s3
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

    addi $a0, $s1, 1 # move cell value + 1 to $a0
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
    lw $t0, LEFT_NUMBERLINE_OFFSET
    add $v0, $v0, $t0 # $v0 = top left of number line in frame buffer + left number line offset

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN calculate_number_line_position

# ██████╗  ██████╗ ██╗███╗   ██╗████████╗███████╗██████╗ ███████╗
# ██╔══██╗██╔═══██╗██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗██╔════╝
# ██████╔╝██║   ██║██║██╔██╗ ██║   ██║   █████╗  ██████╔╝███████╗
# ██╔═══╝ ██║   ██║██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗╚════██║
# ██║     ╚██████╔╝██║██║ ╚████║   ██║   ███████╗██║  ██║███████║
# ╚═╝      ╚═════╝ ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝

# FUN init_pointers
# Initializes the pointers to the top and bottom of the board.
.globl init_pointers
init_pointers:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    lw $a0, TOP_POINTER_POSITION
    li $a1, 1
    lw $a2, WHITE
    jal paint_pointer

    lw $a0, BOTTOM_POINTER_POSITION
    li $a1, -1
    lw $a2, WHITE
    jal paint_pointer

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    move 		$v0, $zero			# $v0 = $zero
    jr			$ra					# jump to $ra

# END FUN init_pointers


# FUN paint_pointer
# ARGS:
# $a0: cell number that pointer is on (0-8)
# $a1: position of triangle (1 = top, -1 = bottom)
# $a2: color of triangle
.globl paint_pointer
paint_pointer:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    jal calculate_number_line_position 
    # $v0 = top left position of number line in frame buffer

    lw $t0, BOARD_NUMBERLINE_CELL_SIZE
    sll $t0, $t0, 2 # multiply cell size by 4 bytes
    mult $t0, $s0
    mflo $t0 # $t1 = cell size * cell number

    add $t0, $t0, $v0 # $t0 = top left position of cell in number line in frame buffer + (cell size * cell number)

    lw $t1, FRAME_BUFFER
    add $t3, $t0, $t1 # $s1 = top left position of cell in number line in frame buffer + (cell size * cell number) + frame buffer address
    
    lw $t0, BOARD_NUMBERLINE_CELL_SIZE
    sll $t0, $t0, 2 # multiply cell size by 4 bytes
    srl $t0, $t0, 1 # divide cell size by 2
    add $t3, $t3, $t0 # shift pointer over by half a cell

    beq $s1, 1, _top_pointer
    j _bottom_pointer

_top_pointer:
    lw $t0, NEG_ROW_SIZE_BYTES
    sll $t0, $t0, 2 # multiply row size by 4 bytes
    add $t3, $t3, $t0 # $t3 = top left position of cell in number line in frame buffer + (cell size * cell number) + frame buffer address + (row size * 4)

    move $a0, $t3 # move frame buffer address of top left corner of cell position to $a0
    move $a1, $s2 # move triangle color to $a1
    li $a2, -1 # load direction of triangle (1 = up, -1 = down)
    jal paint_triangle # paint triangle
    j paint_pointer_end

_bottom_pointer:
    # move pointer below cell
    lw $t0, BOARD_NUMBERLINE_CELL_SIZE
    addi $t0, $t0, 4 # go 4 rows below the underside of the cell
    lw $t1, ROW_SIZE_BYTES
    mult $t0, $t1 # multiply cell size by row size in bytes
    mflo $t0
    add $t3, $t3, $t0 # $t3 = top left position of cell in number line in frame buffer + (cell size * cell number) + frame buffer address + (row size * 4) + (cell size * row size in bytes)

    move $a0, $t3 # move frame buffer address of top left corner of cell position to $a0
    move $a1, $s2 # move triangle color to $a1
    li $a2, 1 # load direction of triangle (1 = up, -1 = down)
    jal paint_triangle # paint triangle
    j paint_pointer_end

paint_pointer_end:
    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    move 		$v0, $zero			# $v0 = $zero
    jr			$ra					# jump to $ra

# END FUN paint_pointer

# FUN paint_triangle
# paints a triangle by row
# ex:
#         xxxxx
#          xxx
#           x
# ARGS:
# $a0: frame buffer address of top vertex of triangle
# $a1: color of triangle
# $a2: direction of triangle (1 = up, -1 = down)
paint_triangle:
    addi		$sp, $sp, -32			# $sp -= 32
    sw			$s0, 28($sp)
    sw			$s1, 24($sp)
    sw			$s2, 20($sp)
    sw			$s3, 16($sp)
    sw			$s4, 12($sp)
    sw			$s5, 8($sp)
    sw			$s6, 4($sp)
    sw			$ra, 0($sp)

    move $s5, $a0
    move $s6, $a2

    li $s0, 0 # triangle row iterator
    li $s1, 0 # left pointer of triangle
    li $s2, 0 # right pointer of triangle
paint_triangle_l1:
    li $t0, 5 # height of the triangle
    mult $s6, $t0 # multiply direction of triangle by height of triangle
    mflo $t0
    beq $s0, $t0, paint_triangle_end # end if triangle row iterator is equal to -5

    move $s3, $s1 # copy left pointer of triangle to $s3
    move $s4, $s2 # copy right pointer of triangle to $s4, need to restore later

paint_triangle_row_l2:
    bgt $s3, $s4, paint_triangle_row_l2_end # end row if left pointer of triangle is equal to right pointer of triangle
    
    sll $t0, $s3, 2 # multiply left pointer of triangle by 4 bytes
    add $t1, $s5, $t0 # add left pointer of triangle to current frame buffer addressk
    move $a0, $t1 # move frame buffer address to $a0
    jal paint_pixel

    sll $t0, $s4, 2 # multiply right pointer of triangle by 4 bytes
    add $t1, $s5, $t0 # add right pointer of triangle to current frame buffer addressk
    move $a0, $t1 # move frame buffer address to $a0
    jal paint_pixel

    addi $s3, $s3, 1 # increment left pointer of triangle
    addi $s4, $s4, -1 # decrement right pointer of triangle
    j paint_triangle_row_l2

paint_triangle_row_l2_end:
    add $s0, $s0, $a2 # increment triangle row iterator by direction of triangle
    addi $s1, $s1, -1 # decrement left pointer of triangle
    addi $s2, $s2, 1 # increment right pointer of triangle
    lw $t0, ROW_SIZE_BYTES
    mult $s6, $t0 # row size in bytes * direction of triangle
    mflo $t0
    add $s5, $s5, $t0 # decrement frame buffer address by row size in bytes
    j paint_triangle_l1

paint_triangle_end:
    lw			$s0, 28($sp)
    lw			$s1, 24($sp)
    lw			$s2, 20($sp)
    lw			$s3, 16($sp)
    lw			$s4, 12($sp)
    lw			$s5, 8($sp)
    lw			$s6, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 32			# $sp += 32

    move 		$v0, $zero			# $v0 = $zero
    jr			$ra					# jump to $ra

# END FUN paint_triangle


# ████████╗███████╗██╗  ██╗████████╗
# ╚══██╔══╝██╔════╝╚██╗██╔╝╚══██╔══╝
#    ██║   █████╗   ╚███╔╝    ██║   
#    ██║   ██╔══╝   ██╔██╗    ██║   
#    ██║   ███████╗██╔╝ ██╗   ██║   
#    ╚═╝   ╚══════╝╚═╝  ╚═╝   ╚═╝   
# FUN paint_opponent_move
# Paints the text "OPPONENTS MOVE" on the screen.
# ARGS: $a0: color
.globl paint_opponent_move
paint_opponent_move:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    lw $s0, FRAME_BUFFER # $s0 = buffer address
    # Move buffer down 16 rows
    lw $t0, ROW_SIZE_BYTES
    li $t1, 16
    mul $t0, $t0, $t1
    add $s0, $s0, $t0
    addi $s0, $s0, 64 # move right 16 pixels

    move $s2, $s0 # $s2 = leftmost pixel of text
    move $s1, $a0 # $s1 = color
    
    move $a0, $s0
    move $a1, $s1
    jal paint_o

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_p

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_p

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_o

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_n

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_e

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_n

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_t

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_s

    # Reset frame buffer to top left corner
    move $s0, $s2
    # Move buffer down 9 rows for next line
    lw $t0, ROW_SIZE_BYTES
    li $t1, 9
    mul $t0, $t0, $t1
    add $s0, $s0, $t0

    move $a0, $s0
    move $a1, $s1
    jal paint_m

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_o

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_v

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_e

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN paint_opponent_move

# FUN paint_your_move
# Paints the text "YOUR MOVE" on the screen.
# ARGS:
# $a0: color
.globl paint_your_move
paint_your_move:
    addi		$sp, $sp, -20			# $sp -= 20
    sw			$s0, 16($sp)
    sw			$s1, 12($sp)
    sw			$s2, 8($sp)
    sw			$s3, 4($sp)
    sw			$ra, 0($sp)

    
    lw $s0, FRAME_BUFFER # $s0 = buffer address
    # Move buffer down 16 rows
    lw $t0, ROW_SIZE_BYTES
    li $t1, 16
    mul $t0, $t0, $t1
    add $s0, $s0, $t0
    addi $s0, $s0, 64 # move right 16 pixels

    move $s2, $s0 # $s2 = leftmost pixel of text
    move $s1, $a0 # $s1 = color
    
    move $a0, $s0
    move $a1, $s1
    jal paint_y

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_o

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_u

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_r

    # Reset frame buffer to top left corner
    move $s0, $s2
    # Move buffer down 9 rows for next line
    lw $t0, ROW_SIZE_BYTES
    li $t1, 9
    mul $t0, $t0, $t1
    add $s0, $s0, $t0

    move $a0, $s0
    move $a1, $s1
    jal paint_m

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_o

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_v

    addi $s0, $s0, 20 # move right size of letter (4 pixels) + 1 pixel for space
    move $a0, $s0
    move $a1, $s1
    jal paint_e

    lw			$s0, 16($sp)
    lw			$s1, 12($sp)
    lw			$s2, 8($sp)
    lw			$s3, 4($sp)
    lw			$ra, 0($sp)
    addi		$sp, $sp, 20			# $sp += 20

    jr			$ra					# jump to $ra

# END FUN paint_your_move