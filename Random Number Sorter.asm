; Author: Joshua McKerracher
; Description: This takes a user entered number, creates a list of randomly generated numbers whose size is determined by the user number, prints it, sorts the numbers, finds the list median, prints the median, and prints the sorted list.

INCLUDE Irvine32.inc

.386
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
introOne		BYTE		"Welcome to the Random Number Sorter!",0
introTwo		BYTE		"Programmed by Joshua McKerracher",0
divider			BYTE		"--------------------------------------------",0
instructions1		BYTE		"This program makes a list of random numbers in the range [100 ... 999]. ",0
instructions2		BYTE		"It then prints the list, sorts it, finds the median value, displays the median, ",0
instructions3		BYTE		"and prints the sorted list. ",0
instructions4		BYTE		"Please enter how many numbers you would like to see [15 ... 200]: ",0
userNum			DWORD		?															; value the user enters
MIN			EQU		15															; the lowest value that can be entered.
MAX			EQU		200															; the highest value that can be entered.
LO			EQU		100
HI			EQU		999
outOfBoundsMsg		BYTE		"Out of range! Please enter a number in the range [15 ... 200]: ",0
goodByeMsg		BYTE		"Thanks for using the Random Number Sorter! Goodbye!",0
MAX_SIZE		EQU		300
list			DWORD		MAX_SIZE DUP(?)
randomRangeVal		DWORD		?
fiveSpaces		BYTE		"     ",0
unsorted		DWORD		0
sorted			DWORD		1
printUnsortedMsg	BYTE		"The unsorted random numbers: ",0
printSortedMsg		BYTE		"The sorted random numbers: ",0
innerLoopCount		DWORD		?
testNum			DWORD		0
medianMsg		BYTE		"The median is: ",0










.code
main PROC

	; Displays the introduction message.
	push		OFFSET instructions3
	push		OFFSET instructions2
	push		OFFSET instructions1
	push		OFFSET divider	
	push		OFFSET introTwo
	push		OFFSET introOne
	call		intro

	; Gets the user entered number.
	push		OFFSET outOfBoundsMsg
	push		MAX
	push		MIN
	push		OFFSET instructions4
	call		getUserData

	; Fills an array of user determined size with random numbers.
	call		Randomize
	push		OFFSET list										; Address of list as parameter for fillArray PROC.
	push		LO
	push		userNum											; UserNum as a parameter for fillArray PROC for loop control.
	call		fillArray

	; Displays the list of unsorted random numbers.
	push		OFFSET printSortedMsg
	push		OFFSET printUnsortedMsg
	push		unsorted										; used to print a message for the unsorted list.
	push		OFFSET list										; Address of list as parameter for fillArray PROC.
	push		userNum											; UserNum as a parameter for displayList PROC for loop control.
	call		displayList

	; Sorts the list of numbers.
	push		userNum
	push		innerLoopCount
	push		OFFSET list
	call		sortList

	; Displays the median value in the list.
	push		OFFSET list
	push		OFFSET medianMsg
	push		userNum
	call		displayMedian

	; Displays the sorted list.
	push		OFFSET printSortedMsg
	push		OFFSET printUnsortedMsg
	push		sorted											; used to print a message for the unsorted list.
	push		OFFSET list										; Address of list as parameter for fillArray PROC.
	push		userNum											; UserNum as a parameter for displayList PROC for loop control.
	call		displayList

	; Displays a goodbye message.
	push		OFFSET goodByeMsg
	call		goodBye

	exit
main ENDP









;#########################################################################################
;# Procedure name: intro
;# Description: Prints an introductory message to the user.
;# Receives: introOne, introTwo, divider, instructions1, instructions2, instructions3.
;# Returns: Text. An introductory message.
;# Preconditions: Push introOne, introTwo, divider, instructions1, instructions2, and instructions3 in that order.
;# Registers changed: EDX
;#########################################################################################

intro PROC
; INTRODUCTION SECTION: 
	push		ebp
	mov		ebp, esp

	; displays my name and program title. ---------
	mov		edx, [ebp + 8]
	call		WriteString
	call		CrLf

	mov		edx, [ebp + 12]
	call		WriteString
	call		CrLf

	mov		edx, [ebp + 16]
	call		WriteString
	call		CrLf

	; Provides instructions to the user ---------------
	mov		edx, [ebp + 20]
	call		WriteString
	call		CrLf
	mov		edx, [ebp + 24]
	call		WriteString
	call		CrLf
	mov		edx, [ebp + 28]
	call		WriteString
	call		CrLf

	pop		ebp
	ret		24
intro ENDP









;#########################################################################################
;# Procedure name: getUserData
;# Description: Requests that the user enter a number in range [15,200].
;# Receives: outOfBoundsMsg, MAX, MIN, instructions 4.
;# Returns: Text and the user entered number.
;# Preconditions: Push outOfBoundsMsg, MAX, MIN, and instructions 4 in that order.
;# Registers changed: EDX, EAX
;#########################################################################################

getUserData PROC
	; Prints instructions for the user and requests a number 1 - 300.
	push		ebp
	mov		ebp, esp

	mov		edx, [ebp + 8]
	call		WriteString

	call		ReadInt
	
	; Compares the user input to the min and max.
	CMP		eax, [ebp + 12]
	jl		outOfBounds
	CMP		eax, [ebp + 16]
	jg		outOfBounds

	mov		userNum, eax										; Moves the user input into variable for later use.

	jmp		quit

outOfBounds:

	mov		edx, [ebp + 20]
	call		WriteString
	
	call		ReadInt

	CMP		eax, [ebp + 12]
	jl		outOfBounds
	CMP		eax, [ebp + 16]
	jg		outOfBounds

	mov		userNum, eax										; Moves the user input into variable for later use.

	jmp		quit

quit:
	call		CrLf
	pop		ebp
	ret		16
getUserData ENDP









;#########################################################################################
;# Procedure name: fillArray
;# Description: Fills an array (max size 300 initlialized to all DWORDS) with random integers. The number of integers determined by userNum.
;# Receives: list, userNum
;# Returns: An array filled with integeres. The number of integers in the array is determined by userNum.
;# Preconditions: Call randomize first. Push LO, list, userNum.
;# Registers changed: ECX, EDI, EAX, 
;#########################################################################################

fillArray PROC
	push		ebp
	mov		ebp, esp

	mov		ecx, [ebp + 8]										; moves userNum to ECX for loop control.
	mov		edi, [ebp + 16]										; move addrress of list to the destination index register for use in loop.

	; Fills the first element of the array.
	mov		eax, 900
	call		RandomRange
	add		eax, [ebp + 12]
	mov		[edi], eax

	; Fills the rest of the array with random numbers.
fillyFillLoop:
	add		edi, 4
	mov		eax, 900
	call		RandomRange
	add		eax, [ebp + 12]
	mov		[edi], eax
	loop		fillyFillLoop

	pop		ebp
	ret		12
fillArray ENDP









;#########################################################################################
;# Procedure name: sortList
;# Description: Sorts an array of numbers into highest to lowest order.
;# Receives: userNum, innerLoopCount, and the offset for list.
;# Returns: A sorted array of numbers.
;# Preconditions: Push userNum, innerLoopCount, and list.
;# Registers changed: ESI, ECX, EBX, EDI, EDX
;#########################################################################################

sortList PROC
	push		ebp
	mov		ebp, esp

	mov		esi, [ebp + 8]										; moves the offset of list (the array) to ESI
	mov		ecx, [ebp + 16]										; moves userNum to ECX
	inc		ecx
	
	sub		esi, 4

	; Starts at first element.
sortySortOne:

	; Gets the value in the array and assigns it to ebx
	add		esi, 4
	mov		ebx, [esi]

	; Assigns memory address of ESI + 4 to EDI for use in the second loop.
	mov		edi, esi
	add		edi, 4
	
	; Sets inner loop counter.
	mov		edx, ecx
	sub		edx, 1

	JMP		sortySortTwo

	; This section loops using the loop with ECX method for sortySortOne.
loopyLoopSortySortOne:
	loop		sortySortOne
	JMP		quit

	; Using EDI, starts at EDI = [ESI + 4].
sortySortTwo:
	CMP		ebx, [edi]
	jl		swappySwap
	add		edi, 4
	CMP		edx, 0
	JE		loopyLoopSortySortOne
	dec		edx										; Loop counter for the inner loop.
	CMP		edx, 0								
	JE		loopyLoopSortySortOne								; if all numbers have been checked, loop back to increment ESI.
	JG		sortySortTwo

swappySwap:
	call		exchangeElements
	JMP		sortySortTwo

quit:
	pop		ebp
	ret		12
sortList ENDP









;#########################################################################################
;# Procedure name: exchangeElements
;# Description: This is used as a sub-procedure for sortList. Swaps elements in the list when needed.
;# Returns: Positions in the list swapped.
;# Preconditions: Must call from sortList.
;# Registers changed: EAX, EBX, EDI, ESI, EDX, 
;#########################################################################################

exchangeElements PROC

; Puts high number into the lower slot
	mov		eax, [edi]									; saves low number into EAX
	mov		[esi], eax									; high number moved into lower slot.								

	; Puts low number in the higher slot
	mov		[edi], ebx

	; Assigns memory address of ESI + 4 to EDI for use in the second loop.
	mov		edi, esi
	add		edi, 4

	mov		edx, ecx
	sub		edx, 1

	mov		ebx, [esi]

	ret
exchangeElements ENDP









;#########################################################################################
;# Procedure name: displayMedian
;# Description: Finds the median value in the list and displays it.
;# Receives: A sorted list, medianMsg, and userNum.
;# Returns: The median of the sorted list.
;# Preconditions: The list must be sorted. Then push list, medianMsg, and userNum.
;# Registers changed: EAX, EBX, ECX, EDX, 
;#########################################################################################

displayMedian PROC

	push		ebp
	mov		ebp, esp

	;Checks userNum to see if it's even. (userNum = number of array elements).
	mov		eax, [ebp + 8]										; userNum
	mov		edx, 0
	mov		ebx, 2
	div		ebx
	CMP		edx, 0
	JNE		medianForOddNum
	JE		medianforEvenNum
	
	; get the value of [(userNum / 2 and (userNum/2 + 1)) / 2]
medianForEvenNum:
	
	; Gets the first middle number.
	dec		eax
	mov		edx, 4											; data size of each element in the array to edx
	mul		edx											; multiply EDX*EAX (EAX has the quotient at this point)
	mov		ebx, [ebp + 16]										; ebx gets the list address
	mov		ecx, eax										; moves the value of quotient * data size to ecx 
	mov		eax, [ebx + ecx]									; adds the offset of the first array position + the value of (quotient * data) and gets the value at that position and moves to eax.
	mov		edx, eax										; Stores the first middle number in edx

	; Adds the second middle number to the first.
	add		ecx, 4											; increment ecx by 4 to get the 2nd middle number
	mov		eax, [ebx + ecx]									; move the value of the 2nd middle number to eax.
	add		edx, eax										; add the two middle values.

	; Divide the sum of the two middle numbers by 2
	mov		eax, edx										; moves the sum of the two middle values to be divided by 2.
	mov		ebx, 2											; divisor
	mov		edx, 0		
	div		ebx											; quotient (average) is now in eax.

	; Print the message and number.
	mov		edx, [ebp + 12]
	call		WriteString
	call		WriteDec
	call		CrLf
	call		CrLf
	JMP		quit
	

	; Get the quotient and add 1 for the index of the median. The median of 7 ordered elements is the fourth position. (e.g., 7 / 2 = 3 -> 3 + 1 = 4)
medianForOddNum:
	
	mov		edx, 4											; data size of each element in the array to edx
	mul		edx											; multiply EDX*EAX (EAX has the quotient at this point)
	mov		ebx, [ebp + 16]										; ebx gets the list address
	mov		ecx, eax										; moves the value of quotient * data size to ecx 
	mov		eax, [ebx + ecx]									; adds the offset of the first array position + the value of (quotient * data) and gets the value at that position and moves to eax.

	mov		edx, [ebp + 12]
	call		WriteString
	call		WriteDec
	call		CrLf
	call		CrLf
	JMP		quit

quit:
	pop		ebp
	ret		12
displayMedian ENDP








	
;#########################################################################################
;# Procedure name: displayList
;# Description: Prints/displays the list of numbers. 
;# Receives: Push userNum, list, (EITHER sorted OR unsorted), printUnsortedMsg, printSortedMsg
;# Returns: The list printed out.
;# Preconditions: Push userNum, list, (EITHER sorted OR unsorted), printUnsortedMsg, printSortedMsg.
;# Registers changed: ECX, ESI, EDX, EBX, EAX
;#########################################################################################

displayList PROC
	push		ebp
	mov		ebp, esp

	mov		ecx, [ebp + 8]										; moves userNum to ECX for loop control.
	mov		esi, [ebp + 12]										; move addrress of list to the destination index register for use in loop.
	mov		edx, [ebp + 16]										; used to check if the sorted or unsorted list msg should be printed.
	mov		ebx, 0											; user for counting printed numbers.

	; This checks if the sorted or unsorted message needs to be printed.
	CMP		edx, 0
	JE		unsortedMsg
	JG		sortedMsg

unsortedMsg:
	mov		edx, [ebp + 20]
	call		WriteString
	call		CrLf
	JMP		printyPrintLoop

sortedMsg:
	mov		edx, [ebp + 24]
	call		WriteString
	call		CrLf

printyPrintLoop:
	mov		eax, [esi]
	call		WriteDec
	mov		edx, OFFSET fiveSpaces
	call		WriteString
	inc		ebx											; tracks printed numbers.
	add		esi, 4

	CMP		ebx, 10
	JE		newLine

afterCompare:
	loop		printyPrintLoop
	JMP		quit

newLine:
	call		CrLf
	mov		ebx, 0
	JMP		afterCompare

quit:
	call		CrLf
	call		CrLf
	pop		ebp
	ret		20
displayList ENDP









;#########################################################################################
;# Procedure name: goodBye
;# Description: Displays a goodbye message.
;# Receives: Push goodByeMsg
;# Returns: A goodbye message.
;# Preconditions: Push goodByeMsg.
;# Registers changed: EDX
;#########################################################################################

goodBye PROC
	push		ebp
	mov		ebp, esp

	; Prints a goodbye message.
	mov		edx, [ebp + 8]
	call		WriteString
	call		CrLf
	call		CrLf

	pop		ebp
	ret		4
goodBye ENDP


end main
