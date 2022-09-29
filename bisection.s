//Robert Brandl
//I pledge my honor that I have abided by the Stevens Honor System.
.text
.global _start
.extern printf

funcVal:
    MOV X7, #0//counter for the i-value
    FMOV D8, #1//holds the multiplication x^i
    MOVI D9, #0//holds the temp sum
    LOOP: CMP X20, X7//degree of polynomial minus counter
    B.LT  EXIT//if the last i-value, exit the loop
    LSL X15, X7, #3//shifts the counter to get the offset
    ADD X16, X15, X28//adds the offset to the address of the array
    LDUR  D13, [X16]//load in the pi value
    FMUL  D14, D13, D8//multiplies pi by x^i
    FADD  D9, D14, D9//adds the next value to the sum variable
    FMUL D8, D8, D24//multiplies D8 by D24 again
    ADD X7, X7, #1//increments the i counter
    B LOOP//repeats the loop
    EXIT: FMOV D25, D9//stores the f(c) value into D25
    BR X30
    
findRoot:
    ADD SP, SP, #8//allocates space to hold the return address
    STUR X30, [SP, #0]//stores the return address on the stack
    FADD  D24, D22, D23//a+b
    FMOV  D9, #2.0//gets the divisor
    FDIV  D24, D24, D9// D24 (c) = (a+b)/2
    BL    funcVal//branches to get the f(c) value, placed in D25
    //check if c itself is a root
    MOVI D9, #0//sets D9 to 0
    FCMP D25, D9//checks if D25, f(c) is negative
    B.LT CHECK// if so, does a separate check
    FCMP  D25, D21//if positive or 0, checks if within tolerance range
    B.LE LEAVE//if the root, exit function
    B CONT//otherwise, keeps going
    CHECK: FMOV D9, #-1//sets D9 to -1 to convert negative value positive
    FMUL D7, D25, D9//changes the negative number to be positive
    FCMP  D7, D21//checks if within tolerance range
    B.LE LEAVE// if the root, exit function
    
    CONT: FMOV D3, D25//f(c)
    FMOV D4, D24//c
    FMOV D24, D22//sets the a-value to be sent to funcVal
    BL funcVal//gets the f(a) value
    FMOV D5, D25//f(a)
    FMOV D6, D24//a
    FMOV D24, D23//sets the b-value to be sent to funcVal
    BL funcVal//gets the f(b) value
    //now D25 has f(b) and D24 has b
    MOVI D9, #0//sets D9 to 0
    FCMP D5, D9//checks if f(a) is positive
    B.LT ANEG//if its negative, skip to ANEG lable
    B APOS//otherwise go to APOS label
    ANEG: FCMP D3, D9//if f(a) is negative, check if f(c) is positive
    B.GT USEAC//if f(c) is positive, use the interval from a to c
    B USECB//otherwise use the interval from c to b
    APOS: FCMP D3, D9// if f(a) is positive, check if f(c) is negative
    B.LT USEAC//if f(c) is negative, use the interval from a to c, otherwise, keep going with interval from c to b
    USECB: FMOV D22, D4//sets the c to be the new a-value
    FMOV D23, D24//sets the b to be the new b-value
    BL findRoot//recursively runs on the new interval
    B LEAVE//once it returns, skip to the end to avoid the next recursive call
    USEAC: FMOV D22, D6//sets the a to be the new a-value
    FMOV D23, D4//sets the c to be the new b-value
    BL findRoot//recursively runs on the new interval
    LEAVE: LDUR X30, [SP, #0]//restores the return register
    SUB SP, SP, #8//reallocates the stack space
    BR  X30//returns from the procedure
   
_start:
    LDR   X15, =tolerance
    LDUR  D21, [X15] //holds the tolerance value
    
    LDR   X15, =a
    LDUR  D22, [X15]//holds the a value
    
    LDR   X15, =b
    LDUR  D23, [X15]//holds the b value
    
    ADR   X28, coeff//gets the array of coefficients
    LDR   X15, =N
    LDUR  X20, [X15]//stores the degree of the polynomial
    MOVI  D24, #0//holds the c value, which will be the root at the end
    MOVI  D25, #0//holds f(c), which will be f(root) at the end
    BL findRoot
    
    //prints the final output message
    LDR   X0, =output
    FMOV  D0, D24
    FMOV  D1, D25
    BL   printf
    
    MOV   X0, #0 //ends the program
    MOV   W8, #93
    SVC   #0

.data
coeff: .double 0.2, 3.1, -0.3, 1.9, 0.2//coefficients of the polynomial, with 0s as needed for missing values
N: .dword 4 //degree of the polynomial
tolerance: .double 0.01
a: .double -1.0
b: .double 1.0
output: .ascii "Root: %lf Value of Function at Root: %lf \n\0"
.end
