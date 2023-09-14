# Sagi Menahem, Maman 11, EX 4
# This MIPS assembly code processes pairs of base 8 digits separated by '$',
# converts them to decimal, sorts them, and prints the results.
# ------------------------------------#
.text
# Start the program
start:
	# Prompt the user to enter pairs of base 8 digits separated by '$':
	li $v0, 4			# Load syscall code for printing string
	la $a0, prompt1			# Load address of prompt1 string
	syscall				# Execute the syscall to print the prompt
	
	# Read input string from the user:
	li $v0, 8			# Load syscall code for reading input
	la, $a0, stringocta		# Load address of input buffer
	lw $a1, max_len($0)		# Load maximum length of input
	syscall				# Execute the syscall to read input

	# Check if the input string is valid:
	la   $a0, stringocta		# Load address of input string
	jal  is_valid			# Jump to the is_valid function
	beq  $v0, $zero, print_invalid_input	# If return value is 0, print invalid input message

	# Convert the valid input to decimal:
	move $a2, $v0			# Move return value to $a2 (valid pair count)
	la   $a0, stringocta		# Load address of input string
	la   $a1, NUM			# Load address of destination array (decimal values)
	jal  convert			# Jump to the convert function

	# Print the converted decimal values:
	la   $a0, prompt3		# Load address of prompt3 string
	li   $v0, 4			# Load syscall code for printing string
	syscall				# Execute the syscall to print the message
    
	la   $a0, NUM			# Load address of decimal values array
	move $a1, $a2			# Move valid pair count to $a1
	jal  print_pairs		# Jump to the print_pairs function

	# Print a new line:
	li $v0, 4			# Load syscall code for printing string
	la $a0, new_line		# Load address of new_line string
	syscall				# Execute the syscall to print a new line
	
	# Print a message before sorting:
	la   $a0, prompt4		# Load address of prompt4 string
	li   $v0, 4			# Load syscall code for printing string
	syscall				# Execute the syscall to print the message
    
    	# Sort the array and print the sorted values:
	la   $a0, sort_array		# Load address of decimal values array
	la   $a1, NUM			# Load address of base array
	move $a2, $t2			# Move valid pair count to $a1
	jal  sort			# Jump to the sort function

	# Print a message after sorting:
	la   $a0, prompt5		# Load address of prompt5 string
	li   $v0, 4			# Load syscall code for printing string
	syscall				# Execute the syscall to print the message
    
    	# Print the sorted decimal values:
	la   $a0, sort_array		# Load address of decimal values array
	move $a1, $t2			# Move valid pair count to $a1
	jal  print_pairs		# Jump to the print_pairs function

	# Exit the program:
	li   $v0, 10			# Load syscall code for program exit
	syscall				# Execute the syscall to exit

# Print a message for invalid input and restart the program:
print_invalid_input:
	la   $a0, prompt2		# Load address of prompt2 string
	li   $v0, 4			# Load syscall code for printing string
	syscall				# Execute the syscall to print the message
	j    start

# Check if the input string is valid:
is_valid:
	# Initialize counters
	li $t2, 0			# Initialize valid pair count
	li $t3, 0			# Initialize digit count
	li $t4, 0			# Initialize consecutive pair flag

loop1:
	lb $t0, ($a0)			# Load byte at current address
	beq $t0, $zero, end		# If byte is null, exit loop
	beq $t0, 10, end		# If byte is newline, exit loop

	# Check if the byte is a valid base 8 digit:
	blt $t0, '0', not_valid		# Check if it's less than '0'
	bgt $t0, '7', check_dollar	# Check if it's greater than '7'

	# Count the valid digits and check for pairs separated by '$':
	addi $t3, $t3, 1
	beq $t3, 2, expect_dollar	# If two digits, expect a dollar sign
	j loop2

# Expecting a dollar sign after a valid pair
expect_dollar:
	lb $t0, 1($a0)			# Load next character (expected '$')
	beq $t0, '$', valid_pair	# If dollar sign, validate the pair
	j not_valid			# Otherwise, input is invalid

# Valid pair found
valid_pair:
	addi $t2, $t2, 1		# Increment valid pair count
	addi $a0, $a0, 1		# Move to the next character
	li $t3, 0			# Reset digit count
	li $t4, 1			# Set flag for pair
	j loop2

# Check if the byte is a dollar sign
check_dollar:
	beq $t0, '$', check_consecutive	# Check if it's a dollar sign
	j not_valid			# Otherwise, input is invalid

# Check for consecutive pairs
check_consecutive:
	beq $t4, 1, not_valid		# Check if no consecutive pairs
	li $t4, 1			# Set flag for consecutive pair
	j loop2

loop2:
	addi $a0, $a0, 1		# Move to the next character
	j loop1

# End of processing input
end:
	move $v0, $t2			# Set return value to valid pair count
	jr $ra				# Return to caller

# Invalid input case
not_valid:
	li $v0, 0			# Set return value to 0 (invalid)
	jr $ra				# Return to caller

# Function to convert base 8 pairs to decimal:
convert:
	la   $t0, stringocta		# Load address of input string
	la   $t1, NUM			# Load address of destination array
	li   $t2, 0			# Initialize loop counter

loop3:
	lb   $s1, ($t0)			# Load first ASCII digit
	addi $t0, $t0, 1		# Move to the next character
	lb   $s2, ($t0)			# Load second ASCII digit
	addi $t0, $t0, 1		# Move to the next character
	
	# Convert ASCII digits to integers and calculate decimal value:
	sub  $s1, $s1, '0'		# Convert first digit to integer
	sub  $s2, $s2, '0'		# Convert second digit to integer
	sll  $s1, $s1, 3		# Multiply the first digit by 8
	add  $s1, $s1, $s2		# Add the second digit
	sb   $s1, ($t1)			# Store the decimal value in the array

	addi $t1, $t1, 1		# Move to the next element in the array
	addi $t0, $t0, 1		# Move to the next pair in the input
	addi $t2, $t2, 1		# Increment loop counter
	bne  $t2, $a2, loop3		# Repeat the loop until all pairs are converted

	jr   $ra

# Printing decimal pairs
print_pairs:
	li   $t0, 0			# Initialize loop counter
	la   $t3, NUM			# Load address of the array

loop4:
	bge  $t0, $a1, print_pairs_end	# Exit the loop if all elements are printed

	lb   $s0, ($t3)			# Load the current decimal value
	move $a0, $s0			# Move the value to argument register
	li   $v0, 1			# Load syscall code for printing integer
	syscall				# Execute the syscall to print the value

	li   $v0, 4			# Load syscall code for printing string
	la   $a0, two_spaces		# Load address of two_spaces string
	syscall				# Execute the syscall to print spaces

	addi $t0, $t0, 1		# Increment loop counter
	addi $t3, $t3, 1		# Move to the next element in the array
	j    loop4

print_pairs_end:
	jr   $ra
	
# Sorting the array
sort:
	li   $t2, 0			# Initialize loop counter

loop5:
	bge  $t2, $a2, loop5_end	# Exit the loop if all elements are sorted

	move $t0, $a1			# Load base address of the array
	move $t3, $a2
	subi $t3, $t3, 1		# Calculate the last index

loop6:
	beq  $t3, $zero, loop6_end	# Exit the inner loop if at the beginning of the array

	lb   $t4, ($t0)			# Load current element
	lb   $t5, 1($t0)		# Load next element

	ble  $t4, $t5, no_swap		# Compare and swap elements if necessary

	# Swap elements
	sb   $t5, ($t0)
	sb   $t4, 1($t0)

no_swap:
	addi $t0, $t0, 1		# Move to the next element
	subi $t3, $t3, 1		# Decrement loop counter
	j    loop6

loop6_end:
	addi $t2, $t2, 1		# Increment loop counter
	j    loop5

loop5_end:
	move $a0, $t0			# Return sorted array address
	jr   $ra

#------------------------------------#
.data
prompt1: .asciiz "Please enter pairs of base 8 digits separated by $ (max 30 chars): "
prompt2: .asciiz "Invalid input, Please try again!\n"
prompt3: .asciiz "Converted values in decimal is: "
prompt4: .asciiz "Start sorting the values...\n"
prompt5: .asciiz "The values after sorting: "
two_spaces: .asciiz "  "
new_line: .asciiz "\n"
stringocta: .space 31
max_len: .word 31
NUM: .space 10
sort_array: .space 10
