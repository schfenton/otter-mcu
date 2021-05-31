# Display Multiplexor Code by....Alex Neiman and Schuyler Fenton
# CPE 233 Lab 8. Counts button presses and outputs that number to the sseg disp

.data
sseg:	.byte	0x03,0x9F,0x25,0x0D,0x99,0x49,0x41,0x1F,0x01,0x09 # LUT for 7-segs


.text
init:   li	x20,0x1100C008	# address of anode
	li	x21,0x1100C004	# address of segs
	li	x13,0		# number of button presses
	li	x14,0		# Current anode output AND ssegs out
	li	x15,10		# Number 10 (for comparison)
	li	x23,50		# Number 50 (for comparison)
	li	x11,0		# x11 = what character of the display we are on [1-tens,0-ones]
	
	la	x6,isr          
	csrrw	x0,mtvec,x6     # store isr as mtvec
	li	x6,1		
	csrrw	x0,mie,x6       # enable interrupts
	
dloop:	# digit loop- one iteration for every character

	la	x16,sseg	# load address of LUT into reg x16
	bnez	x11,tens	# if not evaluating ones place, skip ones section
ones:	call	parse		# recalculate each digit value (every other loop)
	add	x16,x16,x17	# offset address by ones place
	li	x14,0x07	# load anode value 0111 for last display
	j	iorw		# skip tens stuff
tens:	beqz	x18,admin	# tens stuff: skip loop if tens=0 (lead zero blanking)
	li	x14,0x0B	# load anode value 1011 for 3rd display
	add	x16,x16,x18	# x16 <- x16 + x18

iorw:	sw	x14,0(x20)	# write x14 anode value to anode (io)
        lbu	x14,0(x16)	# lb from LUT: x16 now addr of the number we wish to display
	sw	x14,0(x21)	# write ssegs. x19 is our temp value
	
	li	x12,100000	# Number of mcu cycles to delay
sloop:	addi	x12,x12,-1	# subtract loop counter
	bnez	x12,sloop	# Create a delay by looping
	
admin:	xori	x11,x11,0x1	# toggle digit to evaluate
	j	dloop		# start loop again



parse:	mv	x17,x13		# copy input value x13 into ones (x17)
	mv	x18,x0		# intialize tens(x18) to zero
ploop: 	bltu	x17,x15,pdone	# branch pdone loop if ONES <= TEN(x15)
	addi	x17,x17,-10	# substract 10 from ONES
	addi	x18,x18,1	# add 1 to tens
	j ploop			# restart loop
pdone:	ret
	
 
isr:	addi	x13,x13,1	# Increment total by 1
	blt	x13,x23,isr_d 	# If total is less than 50, skip reset
	mv	x13,x0		# reset total
isr_d:	csrrw	x0,mie,x6	# re enable interrupts
	mret			# ISR is done. return		
