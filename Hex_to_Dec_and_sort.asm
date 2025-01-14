# Author: Salome Dadouche	ID: 328603477       Date: 06.08.24
# Input: The program gets a string of characters with a maximum length of 37 characters (actually 36).
#	 The characters are pairs of digits in base 16 (byte size) separated by the '$' character.
#	 After the last pair will be ENTER.
# Output: The program will check if the input is correct (if not, it will print an error message).
#	After that, the program will convert the exa pairs received in the input to numerical values,
#	and print these numbers in a decimal base according to the unsigned representation method
#	and according to the 2's complement representation method, from largest to smallest

################# Data segment #####################
.data
stringhex: .space 37
NUM: .space 12
unsign: .space 12
sign: .space 12
msg1: .asciiz  "\n Please enter a string according to the rules in the assignment\n"
msg2: .asciiz  "\n wrong input\n"
msg3: .asciiz  "\n The numbers of 'unsign' in decimal base are:\n"
msg4: .asciiz  "\n The numbers of 'sign' in decimal base are:\n"


################# Code segment #####################
.text
.globl main

#------main------#
main:		la $a0,msg1	# Please enter a string according to the rules in the assignment
		li $v0,4	# system call to print
		syscall	        # out a string 		
	 
		li $v0,8        	#get string
		la $a0, stringhex	# &a0 = Pointer to the beginning of the string stringhex (the first character)
		li $a1, 37 		#How much space to keep in memory
		syscall
	
		li $t2,0	# $t2 = counter of the current letter sequence before the '$'
		li $v0,0	# Counter of received hexadecimal pairs
		jal is_valid
		
		addi $v1,$v0,0		#$v1=$v0 - the num of hexadecimal pairs
		la $a0, stringhex	# &a0 = Pointer to the beginning of the string stringhex (the first character)
		la $a1, NUM		# &a1 = Pointer to the beginning of the string NUM (the first character)
		li $t1, 1		# $t1 is a flag:
					# if $t1=0 - the current char is '$' ,
					# if $t1=1 - The current char is the first digit in the pair, 
					# if $t1=2 - The current char is the second digit in the pair		
		jal convert
		
		addi $v1,$v0,0		#$v1=$v0 - the num of hexadecimal pairs
		la $a1, NUM		# &a1 = Pointer to the beginning of the string NUM (the first character)
		la $a2, unsign		# &a2 = Pointer to the beginning of the string unsign (the first character)
		jal sortunsign
		
		addi $v1,$v0,0		#$v1=$v0 - the num of hexadecimal pairs
		la $a1, NUM		# &a1 = Pointer to the beginning of the string NUM (the first character)
		la $a2, sign		# &a2 = Pointer to the beginning of the string sign (the first character)
		jal sortsign

		addi $v1,$v0,0		#$v1=$v0 - the num of hexadecimal pairs
		la $a1,unsign		# &a0 = Pointer to the beginning of the string unsign (the first character)
		jal printunsign
		
		la $a1,sign		# &a1 = Pointer to the beginning of the string sign (the first character)
		jal printsign		
		
		j finish
		
		
#------is_valid------#
# $t2 = counter of the current letter sequence before the '$'
# $v0 = counter of received hexadecimal pairs
# $t0 = the current character
# &a0 = pointer to the beginning of the string stringhex (the first character)

is_valid:	lbu $t0, ($a0)			#Copy the current character to $t0
		#We will check if the character is in the range of digits in base 16
		beq $t0, '\n', end_string
		blt $t0, '0', out_of_range	# if the current char < '0' , it's out of range
		bgt $t0, 'F' , out_of_range	# if the current char > 'F' , it's out of range
		bge $t0, 'A' , in_range		# if the current char >= 'A' , it's in the range
		ble $t0, '9' , in_range		# if the current char <= '9' , it's in the range
		
in_range:	addi $t2,$t2,1		# $t2++
		bgt $t2, 2 , error	# if $t2>2 it's mean that there are more than 2 consecutive digits
		addi $a0,$a0,1		# $a0++ to the next char
		j is_valid
				
out_of_range:	bne $t0, '$', error	# $t0 != '$'
		bne $t2, 2 , error	# $t2 != 2
		li $t2,0		# $t2 = 0
		addi $v0,$v0,1		# $v0++ 
		addi $a0,$a0,1		# $a0++ to the next char
		j is_valid

end_string:	addi $a0,$a0,-1		# points to a character before the '\n'
		lbu $t0, ($a0)
		bne $t0, '$', error	#Checking that the last character was '$'
		jr $ra			# The string is valid and we will continue the main program

error:		la $a0,msg2	# wrong input
		li $v0,4	# system call to print
		syscall	        # out a string
		li $v0,0
		j main

				
#------convert------#
# $v1=  the num of hexadecimal pairs
# &a0 = Pointer to the beginning of the string stringhex (the first character)
# &a1 = Pointer to the beginning of the string NUM (the first character)
# $t0 = the current character
# $t1 = flag as described in 'main' program
# $t2 = temporary variable
# $t3 = temporary variable
# $t4 = the numerical value of an exa pair

convert:	beq $v1, 0 , end_convert	#We read all the pairs
		lbu $t0, ($a0)			#Copy the current character to $t0 
		bge $t0, 'A' , A_F_range	# if the current char >= 'A' , it's in the range of A-F
		bge $t0, '0' , zero_nine_range	# if the current char >= '0' , it's in the range of 0-9
continue:	beq $t1, 1, first_digit		# $t1=1 - The current char is the first digit in the pair
		beq $t1, 2, second_digit	# $t1=2 - The current char is the second digit in the pair
		beq $t1, 0, dollar		# $t1=0 - The current char is '$'

A_F_range:	addi $t0,$t0, -55		#If we subtract 55 from the chars A-F we will arrive at the corresponding num in the range a-f
		j continue 
		
zero_nine_range:addi $t0,$t0, -48		#If we subtract 55 from the chars 0-9 we will arrive at the corresponding num in the range 0-9			
		j continue

first_digit: 	sll $t2,$t0,4		# $t2 = $t0<<4 - Put in the left 4 bits
		li, $t1, 2		# $t1=2 because the next char is the second digit
		addi $a0,$a0,1		# $a0++ to the next char 
		j convert
		
second_digit:	or $t3, $t0, 0		# $t3 = $t0||$zero - Put in the right 4 bits
		li, $t1, 0		# $t1=0 because the next char is '$'
		addi $a0,$a0,1		# $a0++ to the next char 
		j convert
		
dollar:		or $t4, $t2, $t3	#$t4 = $t2||$t3 - "Merges" the 2 digits
		sb $t4, ($a1)		# MEM[$a1] = $t4 
		addi $a1,$a1,1		#We will advance the pointer to the next byte in NUM
		addi $v1,$v1,-1		#$v1-- : We subtract the number of pairs left to read by one
		li, $t1, 1		# $t1=1 because the next char is the first digit
		addi $a0,$a0,1		# $a0++ to the next char
		j convert
		
end_convert:	li $a1, 0
		jr $ra
	
			
#------sortunsign------#		
# $v1= the num of hexadecimal pairs in NUM
# &a1 = Pointer to the beginning of the string NUM (the first character)
# &a2 = Pointer to the beginning of the string unsign (the first character)
# $t0 = i - External index
# $t1 = j - Internal index 
# $t2 = temp_first_num 
# $t3 = Pointer to the beginning of the string unsign (the first character)
# $t4 = temp_second_num							
																					
sortunsign:	li $t0, 0          # $t0 = current index in NUM	

copy_NUM:	bge $t0,$v1,bubble_sort	#if &t0>=$v1 - we finished to copy and now we will sort
		lbu $t1,($a1)		#Copy the current num to $t1
		sb $t1, ($a2)		# MEM[$a2] = $t1
		addi $a2,$a2,1		#We will advance the pointer to the next byte in unsign
		addi $a1,$a1,1		#We will advance the pointer to the next byte in NUM
		addi $t0,$t0,1		# index++
		j copy_NUM
		
		#Now we will sort according to the well-known 'bubble sort'
bubble_sort:	li $t0, 0		# $t0 = i - External index
    		li $t1, 0		# $t1 = j - Internal index
    		li $t2, 0		# $t2 = temp_first_num 
    		li $t4, 0		# $t4 = temp_second_num
    		la $a2, unsign		# $a2 = Pointer to the beginning of the string unsign (the first character)
    		
outer_loop:	bge $t0, $v1, end_sort   #if $t0>=$v1 - we finished to sort
		move $t3,$a2 		 #Pointer to the beginning of the string unsign (the first character)
		li $t1, 1		 # j=0

inner_loop:	bge $t1, $v1, next_outer 	#if $t1>=$v1 - go to the next outer 
    		lbu $t2, ($t3)			# $t2 = the first num
    		addi $t3, $t3, 1		# the adress of the second num
    		lbu $t4, ($t3)			# $t4 = the second num
    		bgeu $t2, $t4, next_inner	#if first>=second - go to the next inner
    		#first<second - then swap the numbers: 
    		sb $t4, -1($t3)       		#save the second num in the first
   		sb $t2, ($t3)         		#save the first num in the second
    		
next_inner:	addi $t1, $t1, 1      #j++
    		j inner_loop  


next_outer:	addi $t0, $t0, 1      #i++
    		j outer_loop  
    		
end_sort:	jr $ra 


#------sortsign------#
# $v1= the num of hexadecimal pairs in NUM
# &a1 = Pointer to the beginning of the string NUM (the first character)
# &a2 = Pointer to the beginning of the string sign (the first character)
# $t0 = i - External index
# $t1 = j - Internal index
# $t2 = temp_first_num 
# $t3 = pointer to the beginning of the string sign (the first character)
# $t4 = temp_second_num

sortsign:	li $t0, 0          # $t0 = current index in NUM
		
copy_NUM_sign:	bge $t0,$v1,bubble_sort_sign	#if &t0>=$v1 - we finished to copy and now we will sort
		lb $t1,($a1)		#Copy the current num (with sign) to $t1
		sb $t1, ($a2)		# MEM[$a2] = $t1
		addi $a2,$a2,1		#We will advance the pointer to the next byte in sign
		addi $a1,$a1,1		#We will advance the pointer to the next byte in NUM
		addi $t0,$t0,1		# index++
		j copy_NUM_sign
		
		#Now we will sort according to the well-known bubble sort
bubble_sort_sign:	li $t0, 0		# $t0 = i - External index
    			li $t1, 0		# $t1 = j - Internal index
    			li $t2, 0		# $t2 = temp_first_num 
    			li $t4, 0		# $t4 = temp_second_num
    			la $a2, sign		# $a2 = Pointer to the beginning of the string sign (the first character)
				
outer_loop_sign:	bge $t0, $v1, end_sort_sign   #if $t0>=$v1 - we finished to sort
			move $t3,$a2 		 #Pointer to the beginning of the string sign (the first character)
			li $t1, 1		 # j=1

inner_loop_sign:	bge $t1, $v1, next_outer_sign 	#if $t1>=$v1 - go to the next outer 
    			lb $t2, ($t3)			# $t2 = the first num
    			addi $t3, $t3, 1		# the adress of the second num
    			lb $t4, ($t3)			# $t4 = the second num
    			bge $t2, $t4, next_inner_sign	#if first>=second - go to the next inner
    			#first<second - then swap the numbers: 
    			sb $t4, -1($t3)       		#save the second num in the first
   			sb $t2, ($t3)         		#save the first num in the second
    		
next_inner_sign:	addi $t1, $t1, 1      #j++
    			j inner_loop_sign  


next_outer_sign:	addi $t0, $t0, 1      #i++
    			j outer_loop_sign  
    		
end_sort_sign:		jr $ra 			


#------printunsign------#
# $v1 = the num of hexadecimal pairs
# &a1 = Pointer to the beginning of the string unsign (the first character)
# $t0 = current index
# $t1 = current number
# $t2 = temporary variable
# $t3 = the hundreds/tens digit 
# $t4 = temporary variable
# $t5 = temp hundreds digit (to check later if it's 0)

printunsign:		la $a0,msg3	# The numbers of 'unsign' in decimal base are:
			li $v0,4	# system call to print
			syscall	        # out a string 		
			li $t0, 0	# $t0 = current index

print_unsign_loop:	bge $t0, $v1, end_printunsign	#If $t0>=$v1, we have finished to print all the numbers
    			lbu $t1, ($a1)             	#$t1 = current number

   			# Calculates and prints the hundreds digit:
    			li $t2, 100		# $t2 = 100
    			divu $t3, $t1, $t2	# Divide the current number by 100
    			mflo $t3		# $t3 = the hundreds digit
    			move $t5,$t3		# $t5 = temp hundreds digit (to check later if it's 0) 
    			beq $t3,0,tens_digit	# the hundreds digit = 0
    			addi $t3, $t3, 48	# Convert the digit to ASCII
    			li $v0, 11		# print char
    			move $a0, $t3
    			syscall
  			# Subtract the hundreds part from the number:
    			addi $t3, $t3, -48	# $t3 = the hundreds digit	
    			mul $t4, $t3, $t2	# $t4 = hundreds
    			subu $t1, $t1, $t4	#Subtract the hundreds

   			# Calculates and prints the tens digit:
tens_digit:    		li $t2, 10		# $t2 = 10
    			divu $t3, $t1, $t2	# Divide the current number by 100
    			mflo $t3		# $t3 = the tens digit
    			bne $t5,0,hundreds_isnot_zero # the hundreds digit != 0
    			beq $t3,0,unit_digit	# the hundreds digit and the tens digit are 0
hundreds_isnot_zero:	addi $t3, $t3, 48	# Convert the digit to ASCII
    			li $v0, 11		# print char
    			move $a0, $t3
    			syscall
			# Subtract the tens part from the number:
    			addi $t3, $t3, -48	# $t3 = the tens digit
   			mul $t4, $t3, $t2       # $t4 = tens
    			subu $t1, $t1, $t4      #Subtract the tens

			# Print the unit digit:
unit_digit:    		addi $t1, $t1, 48	# Convert the digit to ASCII
   	 		li $v0, 11		# print char
    			move $a0, $t1
    			syscall

			# Print two spaces
    			li $a0, 32		# ASCII for space
    			li $v0, 11		# print char
    			syscall
    			syscall			# Print another space

    			addi $a1, $a1, 1	#We will advance the pointer to the next byte in unsign
    			addi $t0, $t0, 1	# index++
    			j print_unsign_loop

end_printunsign:	jr $ra                   
    	
    			
#------printsign------#  
# $v1 = the num of hexadecimal pairs
# &a1 = Pointer to the beginning of the string sign (the first character)
# $t0 = current index
# $t1 = the positive value of $t2
# $t2 = current number (with sign)
# $t3 = the hundreds/tens digit 
# $t4 = temporary variable
# $t5 = temp hundreds digit (to check later if it's 0)
 
printsign:		la $a0,msg4	# The numbers of 'sign' in decimal base are:
			li $v0,4	# system call to print
			syscall	        # out a string 	
			li $t0, 0	# $t0 = index

print_sign_loop:	bge $t0, $v1, end_printsign	#If $t0>=$v1, we have finished to print all the numbers
    			lb $t2, ($a1)           	#$t2 = current number (with sign)
    			
    			blt $t2,0, print_minus		#if $t2 is negative print minus and turn it to positive  	
    			move $t1, $t2           	# $t1 = the positive value of $t2
    			j print_number          
		
print_minus:		negu $t1, $t2           # $t1 = -$t2 (turn the number from negative to positive)
    			li $a0, '-'             # ASCII code of minus
    			li $v0, 11              # print char
    			syscall
    			
print_number:		# Calculates and prints the hundreds digit:
    			li $t2, 100		# $t2 = 100
    			divu $t3, $t1, $t2	# Divide the current number by 100
    			mflo $t3		# $t3 = the hundreds digit
    			move $t5,$t3		# $t5 = temp hundreds digit (to check later if it's 0) 
    			beq $t3,0,tens_digit_2	# the hundreds digit = 0
    			addi $t3, $t3, 48	# Convert the digit to ASCII
    			li $v0, 11		# print char
    			move $a0, $t3
    			syscall
  			# Subtract the hundreds part from the number:
    			addi $t3, $t3, -48	# $t3 = the hundreds digit	
    			mul $t4, $t3, $t2	# $t4 = hundreds
    			subu $t1, $t1, $t4	#Subtract the hundreds

   			# Calculates and prints the tens digit:
tens_digit_2:    	li $t2, 10		# $t2 = 10
    			divu $t3, $t1, $t2	# Divide the current number by 100
    			mflo $t3		# $t3 = the tens digit
    			bne $t5,0,hundreds_isnot_zero_2 # the hundreds digit != 0
    			beq $t3,0,unit_digit_2	# the hundreds digit and the tens digit are 0
hundreds_isnot_zero_2:	addi $t3, $t3, 48	# Convert the digit to ASCII
    			li $v0, 11		# print char
    			move $a0, $t3
    			syscall
			# Subtract the tens part from the number:
    			addi $t3, $t3, -48	# $t3 = the tens digit
   			mul $t4, $t3, $t2       # $t4 = tens
    			subu $t1, $t1, $t4      #Subtract the tens

			# Print the unit digit:
unit_digit_2:    	addi $t1, $t1, 48	# Convert the digit to ASCII
   	 		li $v0, 11		# print char
    			move $a0, $t1
    			syscall

			# Print two spaces
    			li $a0, 32		# ASCII for space
    			li $v0, 11		# print char
    			syscall
    			syscall			# Print another space

    			addi $a1, $a1, 1	#We will advance the pointer to the next byte in unsign
    			addi $t0, $t0, 1	# index++
    			j print_sign_loop

end_printsign:	jr $ra  		
		
						
#------finish------#																		
finish:		li $v0, 10	# Exit program
		syscall
