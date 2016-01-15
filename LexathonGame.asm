# Project: Lexathon
# Course: CS 3340
# Contributors: Jaswin S. Kohli, Aahan Sawhney,Aishwarya Tirumani, Paarth Kapadia
	
	.data
input: .space 10
start_message: .asciiz "\tLet's Play LEXATHON!!!  To score, please create words out of the letter matrix presented below.\nThe words must be lowercase, between 4-9 characters, and contain the middle character.\nYou've got 120 seconds and will get 30 seconds upon each right answer.  Good luck!\n"
correct_ans: .asciiz "\nThat's a write answer. You get TEN points!\n\n"
wrong_ans: .asciiz "\nThat's a wrong answer. You get NO points. Give it another try!\n\n"
outtimemsg: .asciiz "\nYou're out of time!\n\n"
timemsg: .asciiz "\nTime remaining (in seconds): "
alphabet:.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 # space for integer array of size 26 representing count of each letter
flag:	.space 4 		# space for result of checking letters
endl: .asciiz "\n"			#new line character
letters: .space 10			#allocating memory for 9 random letters
random_int: .space 4			#space for a random integer
file: 	.asciiz "dictionary2.txt"	#storing file name
buffer: .space 745770			#space for reading from file
usedwords: .space 5000			#space for storing used words
uwcounter: .word 0
array: .space 1
points: .word 0
valid_string: .word 0
tab: .asciiz "\t"
input_text: .asciiz "Enter the word (press 0 to exit game): "
size: .word 3
points_text: .asciiz	"Total Points: "
beep: .byte 72
duration: .byte 100
volume: .byte 127
has_0: .word 0
has_1: .word 0
has_2: .word 0
has_3: .word 0
has_mid: .word 0
has_5: .word 0
has_6: .word 0
has_7: .word 0
has_8: .word 0
inpterr:	.asciiz "\nPlease make sure your input consists of a 4-9 letter word comprised of the lowercase letters provided above and includes the middle letter.\nTry again.\n"
starttime: .word 0
totaltime: .word 120
vowels: .asciiz "aeiou"
consonants: .asciiz "ttttsssrrrnnnmlhhgfdthrssrht"

	.text
main: 	jal read_file
	la $a0, start_message
	li $v0, 4
	syscall
	
	li  $v0, 30
	syscall
	sw $a0, starttime  		########################	
	
	add $s0, $zero, 0		#initializing register 16
	jal random			#call to loop procedure to generate random letters
	j start
	
start:					#This method calls all other methods in order of the game
	jal print_points		#Prints out the score
	jal printMatrix			#Prints out the character matrix
	jal get_input			#Gets the input from user
	jal exit_condition		#Checks the exit condition
	jal validate 			#Validates user entered string
	jal update_points		#Updates points
	
	j start				#Restarts loop so user can enter another word
	
read_file:
	li $v0, 13			#syscode for opening file
	la $a0, file			#passing file name as argument
	li $a1, 0			#code for opening file in read only mode
	li $a2, 0			#unused
	syscall
	move $s0, $v0			#storing file descriptor
	
	li $v0, 14			#syscode for file input
	move $a0, $s0 			#loading file descriptor into $a0
	la $a1, buffer			#address of space where read strings will be stored
	li $a2, 745770			#number of bytes/characters to read
	syscall
	
	li $v0, 16			#syscode for closing file
	move $a0, $s0			#loading file descriptor
	syscall
	jr $ra
	
random:	
	li $v0, 42			#syscode for generating a random number within a range
	li $a1, 26			#range for random integer
	syscall				#generates a random number between 0 and 25 inclusive
	
	addiu $t0, $a0, 97		#converting to lowercase ASCII letters 
	
	la $s1, letters			#loading address for assigned space
	add $s1, $s1, $s0 		#adding counter to $s1
	sb $t0, ($s1)			#storing random character
	
	add $s0, $s0, 1			#updating counter
	bne $s0, 3, random		#########
	j random_vowel
	
random_vowel:
	li $v0, 42			#syscode for generating a random number within a range
	li $a1, 5			#range for random integer
	syscall				#generates a random number between 0 and 25 inclusive
	
	la $s3, vowels
	add $t0, $zero, $a0
	add $s3, $s3, $t0
	lb $t0, ($s3)
	
	la $s1, letters			#loading address for assigned space
	add $s1, $s1, $s0 		#adding counter to $s1
	sb $t0, ($s1)			#storing random character
	
	add $s0, $s0, 1
	bne $s0, 6, random_vowel	#exit loop if counter = 9					
	j random_consonant
	
random_consonant:
	li $v0, 42			#syscode for generating a random number within a range
	li $a1, 5			#range for random integer
	syscall				#generates a random number between 0 and 25 inclusive
	
	la $s3, consonants
	add $t0, $zero, $a0
	add $s3, $s3, $t0
	lb $t0, ($s3)
	
	la $s1, letters			#loading address for assigned space
	add $s1, $s1, $s0 		#adding counter to $s1
	sb $t0, ($s1)			#storing random character
	
	add $s0, $s0, 1
	bne $s0, 9, random_consonant	#exit loop if counter = 9					
	jr $ra
	
printMatrix:
	la $a1, letters		# Contains the base address
	lw $a2, size		# Contains the size
	subi $sp, $sp, 4
	sw $ra, ($sp)
	jal initialize
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
		
initialize:
	add $t1, $a1, $zero
	li $t2, 0		#i = 0
	
while_1:
	li $v1, 0
	slt $t3, $t2, $a2		# if i > size
	beq $t3, $zero, end_matrix
	li $t4, 0			# j = 0
	
while_2: 
	slt $t3, $t4, $a2
	beq $t3, $zero, next_line
	add $t5, $t2, $t2		# Keeps the track of address as 3*i + j
	add $t5, $t5, $t2
	add $t5, $t5, $t4
	add $t6, $t5, $a1		#Gets the address of letter
	lb $a0, 0($t6)
	beq $t5, 4, mid_letter
	ret_1:
	li $v0, 11
	syscall
	
	li $v0, 4
	la $a0, tab
	syscall
	
	addi $t4, $t4, 1
	j while_2
	
mid_letter:
	subi $a0, $a0, 32
	j ret_1
	
next_line:
	li $v0, 4
	la $a0, endl
	syscall
	
	addi $t2, $t2, 1	# i++
	j while_1
	
end_matrix:
	jr $ra
	
cap_letter: 
	addi $t6, $t6, -32
	jr $ra
	
print_points:
	la $a0, endl			#for printing newline character
	li $v0, 4
	syscall
	
	la $a0, points_text      	#prints "Points:" on output screen
	li $v0, 4
	syscall
	
	la $s0, points			#prints actual points on output screen
	lw $t0, ($s0)
	add $a0, $t0, $zero
	li $v0, 1
	syscall
	
	la $a0, endl			#for printing newline character
	li $v0, 4
	syscall
	
	jr $ra
	
get_input:
	subi $sp, $sp, 4
	sw $ra, ($sp)
	
	la $a0, input_text      	#prompts user for the input
	li $v0, 4
	syscall
	
	la $a0, input			#Calls read method
	li $a1, 9
	la $a2, letters			
	jal Read
	
#	addi $s0, $s0, 1
	
#	li $v0,31
#li $a0, 71
#li $a1, 2000
#li $a2, 25
#li $a3, 127 

#syscall
	
	lw $ra, ($sp)
	jr $ra
Read:	
	subi $sp, $sp, 12		
	sw $a0, ($sp)
	sw $a1, 4($sp)
	sw $ra, 8($sp)

ReadLoop:		
	li  $v0, 12			#Reads in the entered character
    	syscall
    	
    	addi $t0, $0, 0x0000000a	
    	beq $v0, $t0, DoneReading	#If the entered character is an "Enter", then exits loop

CheckMiddle:				
    	lb $t0, 4($a2)			#Checks if entered characters are in the randomly generated character list.
    	bne $v0, $t0, Check0		#Each time, if the character isn't the first time matched to a character in the matrix, then throws an invalid input message
    	jal HasMid
Check0:
    	lb $t0, ($a2)
    	bne $v0, $t0, Check1
    	jal Has0	
Check1:    	
    	lb $t0, 1($a2)
    	bne $v0, $t0, Check2
    	jal Has1
Check2:    	
    	lb $t0, 2($a2)
    	bne $v0, $t0, Check3
    	jal Has2
Check3:    	
    	lb $t0, 3($a2)
    	bne $v0, $t0, Check5
    	jal Has3
Check5:    	
    	lb $t0, 5($a2)
    	bne $v0, $t0, Check6
    	jal Has5
Check6:    	
    	lb $t0, 6($a2)
    	bne $v0, $t0, Check7
    	jal Has6
Check7:    	
    	lb $t0, 7($a2)
    	bne $v0, $t0, Check8
    	jal Has7
Check8:    	
    	lb $t0, 8($a2)
    	bne $v0, $t0, EndChecking
    	jal Has8
EndChecking:
    	li $t0, 0x00000030		#If a 0 was entered, quits program
    	beq $v0, $t0, exit
    	j InvalidInput
    	
HasLetters:    				
    	sb $v0, ($a0)			#Saves the character to the memory space for the string
    	addi $a0, $a0, 1
    	subi $a1, $a1, 1
    	
    	beq $a1, $0, DoneReading	
    	
    	j ReadLoop

DoneReading:
	la $t0, has_mid			#Makes sure middle character is present before progressing
	lw $t1, ($t0)
	beq $t1, 0, InvalidInput
	li $t0, 5
	bgt $a1, $t0, InvalidInput
	addi $a1, $a1, 1
	
AddNulls:
	sb $0, ($a0)			#Adds nulls to the end of the entered string
	addi $a0, $a0, 1
    	subi $a1, $a1, 1
    	
    	beq $a1, $0, FinishedAddingNulls
    	j AddNulls
	
FinishedAddingNulls:			#Resets all the words that keep track of how many times each letter has been entered
	la $t0, has_mid
	sw $0, ($t0)
	la $t0, has_0
	sw $0, ($t0)
	la $t0, has_1
	sw $0, ($t0)
	la $t0, has_2
	sw $0, ($t0)
	la $t0, has_3
	sw $0, ($t0)
	la $t0, has_5
	sw $0, ($t0)
	la $t0, has_6
	sw $0, ($t0)
	la $t0, has_7
	sw $0, ($t0)
    	la $t0, has_8
	sw $0, ($t0)
	
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra

Has0:					#Checks if the character at index 0 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	li $t0, 0x00000001
	la $t1, has_0
	lw $t2, ($t1)
	beq $t2, $t0, Already0
	sw $t0, ($t1)
	j HasLetters
Already0:
	jr $ra

Has1:					#Checks if the character at index 1 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	li $t0, 0x00000001
	la $t1, has_1
	lw $t2, ($t1)
	beq $t2, $t0, Already1
	sw $t0, ($t1)
	j HasLetters
Already1:
	jr $ra

Has2:					#Checks if the character at index 2 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	li $t0, 0x00000001
	la $t1, has_2
	lw $t2, ($t1)
	beq $t2, $t0, Already2
	sw $t0, ($t1)
	j HasLetters
Already2:
	jr $ra

Has3:					#Checks if the character at index 3 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	li $t0, 0x00000001
	la $t1, has_3
	lw $t2, ($t1)
	beq $t2, $t0, Already3
	sw $t0, ($t1)
	j HasLetters
Already3:
	jr $ra

HasMid:					#Checks if the character at index 4 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	li $t0, 0x00000001
	la $t1, has_mid
	lw $t2, ($t1)
	beq $t2, $t0, AlreadyMid
	sw $t0, ($t1)
	j HasLetters
AlreadyMid:
	jr $ra

Has5:					#Checks if the character at index 5 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	li $t0, 0x00000001
	la $t1, has_5
	lw $t2, ($t1)
	beq $t2, $t0, Already5
	sw $t0, ($t1)
	j HasLetters
Already5:
	jr $ra	
Has6:					#Checks if the character at index 6 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	li $t0, 0x00000001
	la $t1, has_6
	lw $t2, ($t1)
	beq $t2, $t0, Already6
	sw $t0, ($t1)
	j HasLetters
Already6:
	jr $ra
	
Has7:					#Checks if the character at index 7 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	li $t0, 0x00000001
	la $t1, has_7
	lw $t2, ($t1)
	beq $t2, $t0, Already7
	sw $t0, ($t1)
	j HasLetters
Already7:
	jr $ra
Has8:					#Checks if the character at index 8 has already been entered.  If not, sets its flag off.  Else, returns an error message.
	li $t0, 0x00000001
	la $t1, has_8
	lw $t2, ($t1)
	beq $t2, $t0, Already8
	sw $t0, ($t1)
	j HasLetters
Already8:
	jr $ra	
	
InvalidInput:				#In the case of invalid input, resets everything and returns error message.
	li $v0, 55
    	la $a0, inpterr
    	li $a1, 1		
    	syscall
    	
	li $v0, 4
    	la $a0, endl		
    	syscall
    	
    	lw $a0, ($sp)
    	lw $a1, 4($sp)
    	sb $0, ($a0)
    	sb $0, 1($a0)
    	sb $0, 2($a0)
    	sb $0, 3($a0)
    	sb $0, 4($a0)
    	sb $0, 5($a0)
    	sb $0, 6($a0)
    	sb $0, 7($a0)
    	sb $0, 8($a0)
    	sb $0, 9($a0)
    	
    	la $t0, has_mid
	sw $0, ($t0)
	la $t0, has_0
	sw $0, ($t0)
	la $t0, has_1
	sw $0, ($t0)
	la $t0, has_2
	sw $0, ($t0)
	la $t0, has_3
	sw $0, ($t0)
	la $t0, has_5
	sw $0, ($t0)
	la $t0, has_6
	sw $0, ($t0)
	la $t0, has_7
	sw $0, ($t0)
    	la $t0, has_8
	sw $0, ($t0)
	
    	j ReadLoop
    	
exit_condition:
	la $s0, input
	lb $t0, ($s0)
	bne $t0, 48, else
	j exit
	
validate:
	subi $sp, $sp, 4
	sw $ra, ($sp)
	
#	jal checkMiddleLetter
#	add $t9, $zero, $v0
	
#	add $a0, $v0, $zero
#	li $v0, 1
#	syscall
	
#	jal check		# calling check subprocedure
#	and $t9, $t9, $v0
	
#	move $a0, $v0		# puts the returned value into $a0 
#	li $v0, 1		# syscode for printing integer
#	syscall
#######################
#	jal check_length
#	and $t9, $t9, $v0
	
#	move $a0, $v0		# puts the returned value into $a0 
#	li $v0, 1		# syscode for printing integer
#	syscall
#######################
#	la $s0, valid_string
#	sw $t9, ($s0)
#	beq $t9, $0, EndValidation
	
#	move $a0, $t9		# puts the returned value into $a0 
#	li $v0, 1		# syscode for printing integer
#	syscall

	la $a0, input
	la $a1, buffer
	li $a2, 0
	li $a3, 74577
	jal Search
	
	sw $v0, valid_string
	beq $v0, $0, EndValidation
	la $t0, usedwords
	add $t1, $0, $0
	lw $t2, uwcounter
	
UsedWordsLoop:					#Checks if the entered word has been used so far; if not adds it
	bge $t1, $t2, EndUsedWordsLoop
	
	la $t3, input
	add $t4, $0, $t0
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	lb $t5, ($t3)
	lb $t6, ($t4)
	bne $t5, $t6, NotUsed
	
	sw $0, valid_string
	j EndValidation
	
NotUsed:				#Adds word if not used
	addi $t0, $t0, 10
	addi $t1, $t1, 1
	j UsedWordsLoop

EndUsedWordsLoop:			#If used, clears memory used for input and sets the valid_string word to false
	la $t2, input
	lb $t1, ($t2)
	sb $t1, ($t0)
	addi $t1, $t1, 1
	lb $t1, 1($t2)
	sb $t1, 1($t0)
	addi $t1, $t1, 1
	lb $t1, 2($t2)
	sb $t1, 2($t0)
	addi $t1, $t1, 1
	lb $t1, 3($t2)
	sb $t1, 3($t0)
	addi $t1, $t1, 1
	lb $t1, 4($t2)
	sb $t1, 4($t0)
	addi $t1, $t1, 1
	lb $t1, 5($t2)
	sb $t1, 5($t0)
	addi $t1, $t1, 1
	lb $t1, 6($t2)
	sb $t1, 6($t0)
	addi $t1, $t1, 1
	lb $t1, 7($t2)
	sb $t1, 7($t0)
	addi $t1, $t1, 1
	lb $t1, 8($t2)
	sb $t1, 8($t0)
	addi $t1, $t1, 1
	lb $t1, 9($t2)
	sb $t1, 9($t0)
	lw $t0, uwcounter
	addi $t0, $t0, 1
	sw $t0, uwcounter
	
EndValidation:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

check_length:
	la $s0, input
	li $t0, 0		#Length counter
	
	subi $sp, $sp, 4
	sw $ra, ($sp)
	jal calculate_length
	addi $v0, $v0, -1
		
	slti $t0, $v0, 10
	sgt $t1, $v0, 3
	and $v0, $t0, $t1
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
calculate_length:
	add $s1, $s0, $t0
	lb $t1, ($s1)
	beq $t1, $zero, exit_loop
	addi $t0, $t0, 1
	j calculate_length
	
exit_loop:
	add $v0, $t0, $zero
	jr $ra

# Function to check if the middle letter is included
checkMiddleLetter:
	la $s0, letters
	lb $a0, 4($s0) 			# $t7 contains the central letter
	la $a1, input
	li $t0, 0
	j loop_1
	
loop_1:
      	add $s0, $a1, $t0
      	lb $t1, ($s0)
      	beq $t1, $zero, notFound
        beq $a0, $t1, found 		# go to NoMiddleLetter subroutine. # $t1 = middle letter #t5 = the current letter
        addi $t0, $t0, 1 		#increment regardless of the outcome
	j loop_1

notFound:
	li $v0, 0
	jr $ra

found:
	li $v0, 1 			#returns 1
        jr $ra


check:	move $s6, $ra		# storing the return address into a seperate register
	li $t0, 0		# i = 0
	jal loop1		# begin loop
	li $t0, 0		
	jal loop2
	li $t0, 0
	li $v0, 1
	jal loop3
	la $s0, flag
	sw $v0, ($s0)
	move $ra, $s6
	jr $ra
	
loop1:	slti $t1, $t0, 10	# stores 1 in $t1 if i < 10
	la $s0, letters		# storing address of letters in $s0
	add $s0, $s0, $t0	# adding offset to address of letters
	lb $t3, ($s0)		# loading byte at the given address
	sne $t2, $t3, $zero	# assigns 1 to $t2 if the charcter read is not NULL
	and $t1, $t1, $t2	# checks if both the conditions are true
	beq $t1, $zero, else 	# if they are false then exit loop
	subi $t3, $t3, 97	# subtracts 'a' from character read
	la $s1, alphabet	# loading address of array storing count of each alphabet
	sll $t3, $t3, 2		# multiplying the offset by 4
	add $s1, $s1, $t3	# adding offset to base address
	lw $t3, ($s1)		# loading count of the alphabet read
	addi $t3, $t3, 1	# incrementing the count by 1
	sw $t3, ($s1)		# storing the incremented value back
	add $t0, $t0, 1		# incrementing the counter
	j loop1
	
else: jr $ra			# jumps back to the return address/exits loop

loop2:	slti $t1, $t0, 10	# stores 1 in $t1 if i < 10
	la $s0, input		# storing address of input in $s0
	add $s0, $s0, $t0	# adding offset to address of input
	lb $t3, ($s0)		# loading byte at the given address
	sne $t2, $t3, $zero	# assigns 1 to $t2 if the charcter read is not NULL
	and $t1, $t1, $t2	# checks if both the conditions are true
	beq $t1, $zero, else 	# if they are false then exit loop
	subi $t3, $t3, 97	# subtracts 'a' from character read
	la $s1, alphabet		# loading address of array storing count of each alphabet
	sll $t3, $t3, 2		# multiplying the offset by 4
	add $s1, $s1, $t3	# adding offset to base address
	lw $t3, ($s1)		# loading count of the alphabet read
	subi $t3, $t3, 1	# decrementing the count by 1
	sw $t3, ($s1)		# storing the updated value back
	add $t0, $t0, 1		# incrementing the counter
	j loop2

loop3:	slti $t1, $t0, 26	# $t1 = 0 if  i < 26
	beq $t1, 0, else	# branch if $t1 = 0
	la $s1, alphabet		# loads the address of alphabet to $s1
	sll $t2, $t0, 2		# multiplying the counter by 4
	add $s1, $s1, $t2	# adding the offset to the base address
	lw $t3, ($s1)		# loading the value at the given address
	blt $t3, $zero, else2	# exit loop the value is negative
	add $t0, $t0, 1		# incrementging counter
	j loop3
	
else2: 	li $v0, 0		# assigns 0 to return value
	jr $ra			# going back to statement after function call

#This is the main search method.  It takes in 4 parameters.  $a0 is the memory address of the search value.
#$a2 is the memory address of the array.  $a3 is the lowest index (0) and $a4 is the highest index (74577, 
#or whatever the # of words is).  It returns a 1 if the value is found in the array and a 0 if it is not.
Search:
	subi $sp, $sp, 24		#Clear space on stack to store variables
	sw $a0, ($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $a3, 12($sp)
	sw $ra, 16($sp)
Search2:
	lw $t0, 8($sp)			#Load lowest and highest indexes from stack
	lw $t1, 12($sp)		
	bgt $t0, $t1, SearchNotFound		#If lowest index higher than highest, end subroutine and go to NotFound
	add $t4, $t1, $t0		#Calculate middle index
	div $t4, $t4, 2
	sw $t4, 20($sp)			#Store middle index
	li $t0, 10
	lw $a0, ($sp)			#Load search value address and array address
	lw $a1, 4($sp)
	mul $t4, $t4, 10		#Multiple middle index by 10 since each string has 10 characters (this gives displacement from lowest index value)
	add $a1, $a1, $t4		#Add middle index value to lowest index value
	jal CompareBytes		#Compare string at middle index and search value string
	li $t8, 1	
	beq $v0, $t8, LessT		#If search value less than, go to LessT
	li $t9, 2			
	beq $v0, $t9, GreaterT		#If search value greater than, go to GreaterT
	j SearchFound				#Else if equal, go end subroutine and go to Found
LessT:
	lw $t0, 20($sp)			#Load middle index
	subi $t1, $t0, 1		#Subtract 1 from middle index
	sw $t1, 12($sp)			#Store that as new highest index
	j Search2			#Run binary search again with new params
GreaterT:
	lw $t0, 20($sp)			#Load middle index
	addi $t1, $t0, 1		#Add 1 to middle index
	sw $t1, 8($sp)			#Store that as new lowest index
	j Search2
SearchNotFound:	
	li $v0, 0x00000000		#Load 0 into $v0, indicates search value not found
	lw $ra, 16($sp)			#Load return address from stack
	addi $sp, $sp, 24		#Reset stack pointer
	jr $ra				#Return to return address
SearchFound:	
	li $v0, 0x00000001		#Load 1 into $v0, indicates search value found
	lw $ra, 16($sp)			#Load return address from stack
	addi $sp, $sp, 24		#Reset stack pointer
	jr $ra				#Return to return address
	
CompareBytes:				
	li $t9, 0x00000000		#Null termintaing character stored in $t9's last byte###########################################################
CompareBytesLoop:	
	lb $t0, ($a0)			#Load bytes from string paramters
	lb $t1, ($a1)
	blt $t0, $t1, NotMatchLess	#If search value byte is lesser, go to NotMatchLess
	bgt $t0, $t1, NotMatchMore	#If search value byte is greater, go to NotMatchMore
	beq $t0, $t9, Match		#If search value byte is equal and equals Nul, go to Match
	addi $a0, $a0, 1		#Jumps to next byte on each string
	addi $a1, $a1, 1
	j CompareBytesLoop		#Restarts loop until final match or nonmatch reached
Match:	
	add $v0, $0, $0			#Load 0 into $v0, signifies match
	jr $ra				#Return to return address
NotMatchLess:	
	addi $v0, $0, 1			#Load 1 into $v0, signifies non-match where srch value is less
	jr $ra				#Return to return address
NotMatchMore:	
	addi $v0, $0, 2			#Load 2 into $v0, signifies non-match where srch value is more
	jr $ra				#Return to return address

update_points:
	lw $t0, points
	lw $t1, valid_string
	beq $t1, $zero, else_points
	addi $t0, $t0, 10
	sw $t0, points
	
	la $a0, correct_ans
	li $v0, 4
	syscall
	
	li $v0,31		# Correct answer sound
	li $a0, 68
	li $a1, 1000
	li $a2, 9
	li $a3, 127 
	syscall
	li $v0,31
	li $a0, 68
	li $a1, 1000
	li $a2, 9
	li $a3, 127 
	syscall
	
	lw $t0, starttime	#Gets start time and current time, and compares them to make sure user isn't over time.  If so, goes to out of time method.
	li $v0, 30
	syscall
	sub $t0, $a0, $t0
	div $t0, $t0, 1000
	lw $t1, totaltime
	addi $t1, $t1, 30	#Adds 30 more seconds to total time user has to play.
	sw $t1, totaltime
	bge $t0, $t1, OutOfTime
	
	sub $t1, $t1, $t0
	
	la $a0, timemsg		#Displays how much time left
	li $v0, 4
	syscall
	
	add $a0, $0, $t1
	li $v0, 1
	syscall
	
	jr $ra

else_points:
	la $a0, wrong_ans
	li $v0, 4
	syscall
	
	li $v0,31		# Wrong answer sound
	li $a0, 64
	li $a1, 1000
	li $a2, 9
	li $a3, 127 
	syscall
	
	lw $t0, starttime	#Gets start time and current time, and compares them to make sure user isn't over time.  If so, goes to out of time method.
	li $v0, 30
	syscall
	sub $t0, $a0, $t0
	div $t0, $t0, 1000
	lw $t1, totaltime
	bge $t0, $t1, OutOfTime
	
	sub $t1, $t1, $t0
	
	la $a0, timemsg		#Displays how much time left
	li $v0, 4
	syscall
	
	add $a0, $0, $t1
	li $v0, 1
	syscall
	
	jr $ra

OutOfTime:
	la $a0, outtimemsg	#Dispays out of time message
	li $v0, 4
	syscall

exit:	
	la $a0, endl			#for printing newline character
	li $v0, 4
	syscall
	
	la $a0, points_text      	#prints "Points:" on output screen
	li $v0, 4
	syscall
	
	la $s0, points			#prints actual points on output screen
	lw $t0, ($s0)
	add $a0, $t0, $zero
	li $v0, 1
	syscall
	
	la $a0, endl			#for printing newline character
	li $v0, 4
	syscall

	li $v0, 10			#syscode for ending program
	syscall
