#by Marius Anghel

####################################################
#             Bitmap Display Settings		   #
#Unit Width in Pixels		1		   #	 
#Unit Height in Pixels		1		   #
#Display Width in Pixels	512		   #
#Display Height in Pixels	256		   #
#Base address for display	0x10040000 (heap)  #
####################################################


.data
menu:
	.asciiz "\nChoose an option:\n1-cls\n2-stave\n3-note\n4-exit\n"
	
choose_colour: 
	.asciiz"Choose a colour:\n1-green\n2-red\n3-blue\n4-yellow\n"
	
choose_row:
	.asciiz"Enter the row number on which you wish the first stave to be: \n"
	
choose_note:
	.asciiz"\nPlay a note by typing a single character A-G or X to return to the menu: \n"
	
end_of_stave_message:
	.asciiz"\nYou have reached the end of the stave, reset the display by choosing the cls (1) option\n"

new_line:
	.asciiz"\n"
	
stave_error_message:
	.asciiz"\nYou have introduced a row number that is out of range.\nPlease introduce a number that is in the range 1-210"
	
	
.text

jal main

#MAIN#MENU
main:
	li $v0, 4
	la $a0, menu
	syscall

	# Get user's input
	li $v0, 5
	syscall

	# Store result in $t0
	move $t0, $v0
	
	beq $t0, 1, cls
	beq $t0, 2, stave
	beq $t0, 3, note
	beq $t0, 4, exit

	jal main

	
#CLS PROCEDURE	
cls:	
	# Leave an emtpy line so program looks better when it's running
	li $v0, 4
	la $a0, new_line
	syscall
	
	li $t5, 0
			
	li $v0, 4
	la $a0, choose_colour
	syscall

	# Get user's color
	li $v0, 5
	syscall

	# Store result in $t0
	move $t0, $v0
	
	
	# Leave an emtpy line so program looks better when it's running
	li $v0, 4
	la $a0, new_line
	syscall
	
	#based on input jumps to part of program that colours the thing in
	beq $t0, 1, green
	beq $t0, 2, red
	beq $t0, 3, blue
	beq $t0, 4, yellow
	
	jal main
	
	green:
		lui $s0,0x1004 		#bitmap display base address in $s0 (heap)
		addi $t8,$zero,0x77DD77	#set colour to green in $t8
		addi $t0,$s0,0 		#initialise $t0 to base address, will count
		lui $s1,0x100C	 	#end of screen area in $s1
		jal drawPixel		#go to label that colour everthing in
	
	red:
		lui $s0,0x1004 		#bitmap display base address in $s0 (heap)
		addi $t8,$zero,0xff6961	#set colour to red in $t8
		addi $t0,$s0,0 		#initialise $t0 to base address, will count
		lui $s1,0x100C	 	#end of screen area in $s1
		jal drawPixel		#go to label that colour everthing in
		
	blue:
		lui $s0,0x1004 		#bitmap display base address in $s0 (heap)
		addi $t8,$zero,0xA7C7E7	#set colour to pink in $t8
		addi $t0,$s0,0 		#initialise $t0 to base address, will count
		lui $s1,0x100C	 	#end of screen area in $s1
		jal drawPixel		#go to label that colour everthing in
		
	yellow:
		lui $s0,0x1004 		#bitmap display base address in $s0 (heap)
		addi $t8,$zero,0xFDFD96	#set colour to pink in $t8
		addi $t0,$s0,0 		#initialise $t0 to base address, will count
		lui $s1,0x100C	 	#end of screen area in $s1
		jal drawPixel		#go to label that colour everthing in
	
	drawPixel: 			#label
		sw $t8,0($t0) 		#store colour $t8 in current target address
		addi $t0,$t0,4 		#increment $t0 by one word
		bne $t0,$s1,drawPixel 	#if haven’t reached the target yet, repeat
		
	jal main
	

#STAVE PROCEDURE
staveOutOfRange:
		li $v0, 4
		la $a0, stave_error_message
		syscall
				
		# Leave an emtpy line so program looks better when it's running
		li $v0, 4
		la $a0, new_line
		syscall
				
		jal stave	

stave:
		#reset all variables used in this part of the procedure
		sub $s0, $s0, $s0
		sub $t8, $t8, $t8
		sub $t0, $t0, $t0
		sub $t2, $t2, $t2
		sub $t1, $t1, $t1
		
		# Leave an emtpy line so program looks better when it's running
		li $v0, 4
		la $a0, new_line
		syscall
		
		#print message that asks user to input the row number
		li $v0, 4
		la $a0, choose_row
		syscall
		
		#gets user input and stores it in $t3 
		li $v0, 5
		syscall
		move $t3, $v0
		
		#error message if invalid input
		ble $t3, 0, staveOutOfRange
		bge $t3, 211, staveOutOfRange
		
		#times the user input by 2048 to calculate the address of the first pixel
		li $t4, 2048
		mul $t3, $t3, $t4
		
		lui $s0,0x1004 		#bitmap display base address in $s0 (heap)
		addi $t8,$zero,0x000000	#set colour to green in $t8
		addi $t0,$s0,0 		#initialise $t0 to base address, will count
		add $t0, $t0, $t3	#stores the address of the first pixel in $t0
		
		addi $t2, $zero, 0	#counts the number of lines 
		jal drawLine 
		
	
		drawLine:	
			sw $t8, ($t0)
			addi $t0, $t0, 4
			addi $t1, $t1, 1
			bne $t1, 512, drawLine
			addi $t2, $t2, 1	#adds 1 to line counter
			sub $t1, $t1, $t1
			jal drawAnotherLine
			
		drawAnotherLine:
			addi $t0, $t0, 20480	#skip 10 lines (=20480 pixels)
			bne $t2, 5, drawLine	#if number of lines aint 5 draw another line
			jal main			#return to main
		
				
#NOTE PROCEDURE
note:
	#reset all variables used in this part of the procedure
	sub $s0, $s0, $s0
	sub $t8, $t8, $t8
	sub $t0, $t0, $t0	
	sub $t2, $t2, $t2
	sub $t1, $t1, $t1
	li $t1, 0
	
	#print message that asks user to play a note or go back to menu
	li $v0, 4
	la $a0, choose_note
	syscall
	
	#get user input and store it in $t1
	li $v0, 12
	syscall
	move $t1, $v0
	
	move $t4, $t3
	
	#$t5 is a varible that stores the distance (in pixels) from left of the screen and is incremented every time a note is played
	addi $t5, $t5, 40	
	
	#when the end of the stave has been reached jump to procedure that gives user instruction on resetting the display
	bge $t5, 2016, endOfStave
	
	#branch to corresponding label depending on user's input
	beq $t1, 'A', noteA
	beq $t1, 'a', noteA
	beq $t1, 'B', noteB
	beq $t1, 'b', noteB
	beq $t1, 'C', noteC
	beq $t1, 'c', noteC
	beq $t1, 'D', noteD
	beq $t1, 'd', noteD
	beq $t1, 'E', noteE
	beq $t1, 'e', noteE
	beq $t1, 'F', noteF
	beq $t1, 'f', noteF
	beq $t1, 'G', noteG
	beq $t1, 'g', noteG
	beq $t1, 'X', main
	beq $t1, 'x', main
	
	#if none of the valid options are selected return to main menu
	jal main
	
	#print error message when the end of the stave has been reached
	endOfStave:
		li $v0, 4
		la $a0, end_of_stave_message
		syscall
		
		j main
		
	noteA:
		
		#draw the note
		li $t1, 0			#counter for width of rectangle
		li $t7, 0			#just some temporary variable used to add some registers
		li $s2, 0			#counts the heigth of the rectangle
		lui $s0,0x1004 			#bitmap display base address in $s0 (heap)
		
		addi $t8,$zero,0x000000		#set colour 
		lui $t0, 0x1004
		
		addi $t7, $t5, 51200		#so that note A is in between 3rd and 4th line 
		add $t9, $t7, $t3		
		add $t0, $t0, $t9		#stores the address of the first pixel in $t0
		
		jal widthA
		
		widthA:
			sw $t8, ($t0)
			addi $t0, $t0, 4
			addi $t1, $t1, 1
			bne $t1, 8, widthA 
			sub $t1, $t1, $t1
			addi $s2, $s2, 1
			
		heightA:
			addi $t0, $t0, 2016	#skip 504 pixels (1 row is 512 pixels, and width is 8 so some simple subtraction)
			bne $s2, 6, widthA	#if width aint 6 
			addi $t5, $t5, 16
			
		#play the sound
		li $v0, 33
		la $a0, 69
		la $a1, 500
		la $a2, 5
		la $a3, 127
		syscall
		
		jal note
		
	noteB:
		#draw the note
		li $t1, 0			#counter for width of rectangle
		li $t7, 0			#just some temporary variable used to add some registers
		li $s2, 0			#counts the heigth of the rectangle
		lui $s0,0x1004 			#bitmap display base address in $s0 (heap)
		
		addi $t8,$zero,0x000000		#set colour 
		lui $t0, 0x1004
		
		addi $t7, $t5, 38912		#offset so note is in right place 
		add $t9, $t7, $t3		
		add $t0, $t0, $t9		#stores the address of the first pixel in $t0
		
		jal widthB
		
		widthB:
			sw $t8, ($t0)
			addi $t0, $t0, 4
			addi $t1, $t1, 1
			bne $t1, 8, widthA 
			sub $t1, $t1, $t1
			addi $s2, $s2, 1
	
		heightB:
			addi $t0, $t0, 2016	#skip 504 pixels (1 row is 512 pixels, and width is 8 so some simple subtraction)
			bne $s2, 6, widthB	#if width aint 6 
			addi $t5, $t5, 16
		
		#play the note
		li $v0, 33
		la $a0, 71
		la $a1, 500
		la $a2, 5
		la $a3, 127
		syscall
		
		jal note
		
	noteC:
		#draw the note
		li $t1, 0			#counter for width of rectangle
		li $t7, 0			#just some temporary variable used to add some registers
		li $s2, 0			#counts the heigth of the rectangle
		lui $s0,0x1004 			#bitmap display base address in $s0 (heap)
		
		addi $t8,$zero,0x000000		#set colour 
		lui $t0, 0x1004
		
		addi $t7, $t5, 28672		#offset so note is in right place 
		add $t9, $t7, $t3		
		add $t0, $t0, $t9		#stores the address of the first pixel in $t0
		
		jal widthC
		
		widthC:
			sw $t8, ($t0)
			addi $t0, $t0, 4
			addi $t1, $t1, 1
			bne $t1, 8, widthC
			sub $t1, $t1, $t1
			addi $s2, $s2, 1
			
		heightC:
			addi $t0, $t0, 2016	#skip 504 pixels (1 row is 512 pixels, and width is 8 so some simple subtraction)
			bne $s2, 6, widthC	#if width aint 6 
			addi $t5, $t5, 16
		
		#play the note
		li $v0, 33
		la $a0, 72
		la $a1, 500
		la $a2, 5
		la $a3, 127
		syscall
		
		jal note
		
	noteD:		
		#draw the note
		li $t1, 0			#counter for width of rectangle
		li $t7, 0			#just some temporary variable used to add some registers
		li $s2, 0			#counts the heigth of the rectangle
		lui $s0,0x1004 			#bitmap display base address in $s0 (heap)
		
		addi $t8,$zero,0x000000		#set colour 
		lui $t0, 0x1004
		
		addi $t7, $t5, 16384		#offset so note is in right place 
		add $t9, $t7, $t3		
		add $t0, $t0, $t9		#stores the address of the first pixel in $t0
		
		jal widthD
		
		widthD:
			sw $t8, ($t0)
			addi $t0, $t0, 4
			addi $t1, $t1, 1
			bne $t1, 8, widthD
			sub $t1, $t1, $t1
			addi $s2, $s2, 1
			
		heightD:
			addi $t0, $t0, 2016	#skip 504 pixels (1 row is 512 pixels, and width is 8 so some simple subtraction)
			bne $s2, 6, widthD	#if width aint 6 
			addi $t5, $t5, 16
		
		#play the note
		li $v0, 33
		la $a0, 74
		la $a1, 500
		la $a2, 5
		la $a3, 127
		syscall
		
		jal note
		
	noteE:
		#draw the note
		li $t1, 0			#counter for width of rectangle
		li $t7, 0			#just some temporary variable used to add some registers
		li $s2, 0			#counts the heigth of the rectangle
		lui $s0,0x1004 			#bitmap display base address in $s0 (heap)
		
		addi $t8,$zero,0x000000		#set colour to black in $t8
		lui $t0, 0x1004
		
		addi $t7, $t5, 6144		#offset so note is in right place 
		add $t9, $t7, $t3		
		add $t0, $t0, $t9		#stores the address of the first pixel in $t0
		
		jal widthE
		
		widthE:
			sw $t8, ($t0)
			addi $t0, $t0, 4
			addi $t1, $t1, 1
			bne $t1, 8, widthE
			sub $t1, $t1, $t1
			addi $s2, $s2, 1
			
		heightE:
			addi $t0, $t0, 2016	#skip 504 pixels (1 row is 512 pixels, and width is 8 so some simple subtraction)
			bne $s2, 6, widthE	#if width aint 6 
			addi $t5, $t5, 16
		
		#play the note
		li $v0, 33
		la $a0, 76
		la $a1, 500
		la $a2, 5
		la $a3, 127
		syscall
		
		jal note

	noteF:
		#draw the note
		li $t1, 0			#counter for width of rectangle
		li $t7, 0			#just some temporary variable used to add some registers
		li $s2, 0			#counts the heigth of the rectangle
		lui $s0,0x1004 			#bitmap display base address in $s0 (heap)
		
		addi $t8,$zero,0x000000		#set colour
		lui $t0, 0x1004
		
		addi $t7, $t5, 73728		#offset so note is in right place 
		add $t9, $t7, $t3		
		add $t0, $t0, $t9		#stores the address of the first pixel in $t0
		
		jal widthF
		
		widthF:
			sw $t8, ($t0)
			addi $t0, $t0, 4
			addi $t1, $t1, 1
			bne $t1, 8, widthF
			sub $t1, $t1, $t1
			addi $s2, $s2, 1
			
		heightF:
			addi $t0, $t0, 2016	#skip 504 pixels (1 row is 512 pixels, and width is 8 so some simple subtraction)
			bne $s2, 6, widthF	#if width aint 6 
			addi $t5, $t5, 16
		
		#play the note
		li $v0, 33
		la $a0, 65
		la $a1, 500
		la $a2, 5
		la $a3, 127
		syscall
	
		jal note
		
	noteG:
		#draw the note
		li $t1, 0			#counter for width of rectangle
		li $t7, 0			#just some temporary variable used to add some registers
		li $s2, 0			#counts the heigth of the rectangle
		lui $s0,0x1004 			#bitmap display base address in $s0 (heap)
		
		addi $t8,$zero,0x000000		
		lui $t0, 0x1004
		
		addi $t7, $t5, 63488		#offset so note is in right place  
		add $t9, $t7, $t3		
		add $t0, $t0, $t9		#stores the address of the first pixel in $t0
		
		jal widthG
		
		widthG:
			sw $t8, ($t0)
			addi $t0, $t0, 4
			addi $t1, $t1, 1
			bne $t1, 8, widthG
			sub $t1, $t1, $t1
			addi $s2, $s2, 1
					
		heightG:
			addi $t0, $t0, 2016	#skip 504 pixels (1 row is 512 pixels, and width is 8 so some simple subtraction)
			bne $s2, 6, widthG	#if width aint 6 
			addi $t5, $t5, 16
		
		#play the note
		li $v0, 33
		la $a0, 67
		la $a1, 500
		la $a2, 5
		la $a3, 127
		syscall
	
		jal note
	
	jal main

#EXIT PROCEDURE
exit:
	li $v0, 10
	syscall
