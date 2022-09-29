//Robert Brandl
//I pledge my honor that I have abided by the Stevens Honor System.
.text
.global _start
.extern printf

SWAP: //function (procedure) to swap two values in the array
    SUB   SP, SP, #32 //allocates stack space to create local variables
    STUR  X9, [SP, #24]
    STUR  X10, [SP, #16]
    STUR  X11, [SP, #8]
    STUR  X12, [SP, #0]
    
    LSL   X11, X7, #3 //determines offset to add to address of array to find value at index stored in X7
    ADD   X11, X11, X6 //adds offset to base address of array
    LDUR  X9, [X11, #0] //loads in array value at that address
    LSL   X12, X3, #3 //determines offset to add to address of array to find value at index stored in X3
    ADD   X12, X12, X6 //adds offset to base address of array
    LDUR  X10, [X12, #0] //loads in array value at that address
    STUR  X10, [X11, #0] //stores the values into the opposite addresses --> swaps the values
    STUR  X9,  [X12, #0]
    
    LDUR  X9, [SP, #24]
    LDUR  X10, [SP, #16]
    LDUR  X11, [SP, #8]
    LDUR  X12, [SP, #0]
    ADD   SP, SP, #32 //reallocates stack space
    BR    X30 //branches back
    
_start:
    LDR   X0, =msg //loads in original message (with no %d)
    ADR   X6, array //oads in the array from data
    LDR   X15, =arraysize //loads in the array size from data
    LDR   X2, [x15] //puts the array size in a usable register
    CMP   X2, #0 //checks if the array size is 0 --> empty array
    B.EQ  EXIT //skips over the selection sort
    CMP   X2, #0 //checks if negative array size --> invalid input
    B.LE DONE //skips over the rest of the code
    SUB   X9, X2, #1 //creates a variable to hold how many times the outer loop, of the double for-loop below, must execute
    MOV   X7, #0 //creates a variable that can be used for calculating offset
LOOP1: CMP X7, X9 //start of outer loop, checks if X7 equals X9, then exits
    B.GE  EXIT
    ADD   X3, X7, #0 //creates two new variables to use for the inner loop
    ADD   X5, X7, #1
    LOOP2: CMP X5, X2 //checks whether the loop should terminate
    	   B.GE  EX2 // exits inner loop
    	   LSL   X19, X5, #3//performs shift to access value at X5
    	   ADD   X20, X6, X19 //adds offset to base address
    	   LDUR  X10, [X20, #0] //accesses that value
    	   LSL   X21, X3, #3 //inds the values ot compare
    	   ADD   X22, X6, X21
    	   LDUR  X11, [X22, #0]
    	   CMP   X10, X11 //compares the values
    	   B.GE  EX3 //checks if they are in order
    	   MOV   X3, X5
    	   EX3: ADD   X5, X5, #1 //updates counter
    	   B     LOOP2
    EX2: SUB   X4, X3, X7
    CBZ   X4, EX1
    BL SWAP //Calls the swap procedure
    EX1: ADD X7, X7, #1
    B LOOP1
    
EXIT: MOV X25, X2 //creates 2 new counters to use in the printing loop
    MOV   X26, XZR
    BL    printf //prints out the initial message
    
PrintLoop: ADR   X23, array //puts the array into a saved address, starts the loop
    CBZ    X25, DONE //Checks if all elements have been printed
    LSL   X18, X26, #3
    ADD   X17, X18, X23
    LDR   X0, =value //Loads in message for printing values
    LDUR  X1, [x17, #0]
    BL    printf //prints out the current value
    ADD   X26, X26, #1 //updates the counters
    SUB   X25, X25, #1
    B PrintLoop
    DONE: MOV   X0, #0 //ends the program
    MOV   W8, #93
    SVC   #0

.data
msg: .ascii "sorted array: \n\0"
value: .ascii "%ld\n\0"
array: .dword 90, 1000, -1, 20, 45, 32, 56, 78, 91, 0, -60, 432, 10000, 3, 9, 12, 99, 82, 33, -21, -90, -100, -4, 10000
arraysize: .dword 25
.end
