# Display Multiplexor Code by....Alex Neiman and Schuyler Fenton
# CPE 233 Lab 8. Counts button presses and outputs that number to the sseg disp

.data
sseg:	.byte	0x03,0x9F,0x25,0x0D,0x99,0x49,0x41,0x1F,0x01,0x09,0xFC # LUT for 7-segs
ans:	.byte	0x07,0x0B

.text
mplxer:	la	x10,isr 	# Get interrupt service routine ready
	csrrw	x0,mtvec,x10
	li	x10,1		# Make sure interrupts are enabled
	csrrw	x0,mie,x10
	
	li	x20,0x1100C008	# address of anode
	li	x21,0x1100C004	# address of segs
	li	x13,0		# number of button presses
	li	x14,0		# Current anode output AND ssegs out
	li	x15,10		# Number 10 (for comparison)
	li	x23,50		# Number 50 (for comparison)
	li	x11,0		# x11 = what character of the display we are on [1,0]
	
cloop:	# char loop- one iteration for every character

	la	x16,sseg	# load address of LUT into temp reg x16
	bnez	x11,tens	# if current anode not zero, branch to tens section
	call	parse		# every two clock cycles, parse the counter x13 into x17,x18
ones:	add	x16,x16,x17	# ones stuff: x16 <- x16 + x17 (addr_LUT + ones)- offset address
	li	x14,0x07	# Anode output value for ones place
	sw	x14,0(x20)	# write x14 anode value to anode (io)
	j	iorw		# skip tens stuff
tens:	beqz	x18,admin	# tens stuff: skip loop if tens=0 (lead zero blanking)
	li	x14,0x0B	# Anode output value for tens place
	sw	x14,0(x20)	# write to IO
	add	x16,x16,x18	# x16 <- x16 + x18
iorw:	# We now have the addresses of the LUT. Load the value from mem and write to display
	lbu	x14,0(x16)	# lb from LUT: x16 now addr of the number we wish to display
	sw	x14,0(x21)	# write ssegs. x19 is our temp value
	# Timing loop- we want to stall the MPU so that it can display the number correctly.
	li	x12,100000	# Number of clock cycles for each loop (also loop counter)
sloop:	addi	x12,x12,-1	# Timimg loop- subtract loop counter
	bnez	x12,sloop	# Create a delay by looping
	
admin:	xori	x11,x11,0x1	# switch characters 00 -> 01, 01 -> 00
	j	cloop		# go to next character



parse:	mv	x17,x13		# copy input value x13 into ones (x17)
	mv	x18,x0		# intialize tens(x18) to zero
ploop: 	bltu	x17,x15,pdone	# branch pdone loop if ONES <= TEN(x15)
	addi	x17,x17,-10	# substract 10 from ONES
	addi	x18,x18,1	# add 1 to tens
	j ploop			# restart loop
pdone:	ret
	
 
isr:	addi	x13,x13,1	# Increment number of button presses by 1
	blt	x13,x23,isr_d 	# If num of button press is less than 50, skip zeroing
	mv	x13,x0		# zero the count
isr_d:	csrrw	x0,mie,x10		# re enable interrupts
	mret			# ISR is done. return		
