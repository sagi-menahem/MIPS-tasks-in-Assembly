#Sagi Menahem, Maman 11, EX 3
#------------------------------------#
.text
# Prompt the user with "Please enter a string: ":
	li $v0, 4		# Load syscall code for printing string
	la $a0, prompt1		# Load address of prompt1 string
	syscall			# Execute the syscall to print the prompt
# Read input string from the user:
	li $v0, 8		# Load syscall code for reading input
	la, $a0, string		# Load address of input buffer
	lw $a1, max_len($0)	# Load maximum length of input
	syscall			# Execute the syscall to read input
# Print a new line:
	li $v0, 4		# Load syscall code for printing string
	la $a0, new_line	# Load address of new_line string
	syscall			# Execute the syscall to print a new line
# Prompt the user with "The string in cascading form:"
	li $v0, 4		# Load syscall code for printing string
	la $a0, prompt2		# Load address of prompt2 string
	syscall			# Execute the syscall to print the prompt
	
#---- Loop to remove newline characters from the input string ----#
la   $t0, string		# Load address of input string
# Start removing '\n'
remove:
	lb   $t2, ($t0)		# Load byte at current address
	beq  $t2, $zero, end_remove	# If byte is null, exit loop
	li   $t3, 10		# Load ASCII code for newline character
	beq  $t2, $t3, replace	# If byte is newline, go to replace
	addi $t0, $t0, 1	# Move to the next byte
	j    remove		# Repeat the loop
# Replace '\n' with '\0'
replace:
	sb   $zero, ($t0)	# Store null byte to replace newline
# End removing '\n'
end_remove:

#---- Loop to find the length of the input string ----#
la   $t0, string		# Load address of input string
li   $t1, 0			# Initialize string length counter
# Find the length of the string
find_length:
	lb   $t2, ($t0)		# Load byte at current address
	beq  $t2, $zero, end_find_length	# If byte is null, exit loop
	addi $t1, $t1, 1	# Increment string length counter
	addi $t0, $t0, 1	# Move to the next byte
	j    find_length	# Repeat the loop
# End finding the length
end_find_length:

#---- Loop to print the input string in staggered form ----#
la   $t0, string		# Load address of input string
li   $t4, 1			# Initialize stagger value to 1
# A loop to print the string
loop:
	beq  $t1, $zero, end	# If string length is zero, exit loop

	beq  $t4, 1, skip_line	# If stagger value is 1, skip printing a new line
	la   $a0, new_line	# Load address of new_line string
	li   $v0, 4		# Load syscall code for printing string
	syscall			# Execute the syscall to print a new line
# Skip printing a new line
skip_line:
	li   $t4, 0		# Reset stagger value to 0

	move $a0, $t0		# Load address of current character
	li   $v0, 4		# Load syscall code for printing string
	syscall			# Execute the syscall to print a character

	add  $t3, $t0, $t1	# Calculate address of last character
	subi $t3, $t3, 1	# Decrement last character to null terminate
	sb   $zero, ($t3)	# Null terminate the string

	addi $t1, $t1, -1	# Decrement string length counter
	j    loop		# Repeat the loop

end:
	li   $v0, 10		# Load syscall code for program exit
	syscall			# Execute the syscall to exit
#------------------------------------#
.data
prompt1: .asciiz "Please enter a string: "
prompt2: .asciiz "The string in cascading form:\n"
new_line: .asciiz "\n"
string: .space 31
max_len: .word 31