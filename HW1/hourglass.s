.data
    prompt: .asciiz "Enter the number n = "
    star:   .asciiz "*"
    space:  .asciiz " "
    newline:.asciiz "\n"

.text
main:
    # prompt user to enter the value of n
    li $v0, 4
    la $a0, prompt
    syscall

    # read integer n from user
    li $v0, 5
    syscall
    move $s0, $v0

    li $v0, 4
    la $a0, newline
    syscall

    # compute the value of temp
    addi $t0, $s0, 1
    div $t0, $t0, 2
    mflo $t1
    addi $t0, $zero, 2
    div $s0, $t0
    mfhi $t2
    bne $t2, 1, L1      # if n is odd, decrement temp
    addi $t1, $t1, -1

L1:
    addi $t2, $zero, 0  # initialize i to 0

L2: 
    beq $t2, $t1, L7_t   # exit loop when i == temp

    # print spaces
    addi $t3, $zero, 0  # initialize j to 0
L3: bgt $t3, $t2, L4
    li $v0, 4
    la $a0, space
    syscall
    addi $t3, $t3, 1
    jal L3

    # print stars
L4: addi $t4, $zero, 0  # initialize j to 0
    mul $t5, $t2, 2
    sub $t6, $s0, $t5

L5: bge $t4, $t6, L6   # exit loop when j >= n - i*2
    li $v0, 4
    la $a0, star
    syscall
    addi $t4, $t4, 1
    jal L5

L6: 
    li $v0, 4
    la $a0, newline
    syscall

    addi $t2, $t2, 1
    jal L2
 
L7_t:
    addi $t0, $zero, 2
    div $s0, $t0
    mfhi $t3
    beq $t3, 1, L7
    addi $t2, $t2, -1
L7:    
    addi $t3, $t2, 1
    beq $t3, $zero, L12   # exit loop when i == temp

    # print spaces
    addi $t3, $zero, 0  # initialize j to 0
L8: 
    bgt $t3, $t2, L9
    li $v0, 4
    la $a0, space
    syscall
    addi $t3, $t3, 1
    jal L8

L9: 
    addi $t4, $zero, 0  # initialize j to 0
    mul $t5, $t2, 2
    sub $t6, $s0, $t5

L10: 
    bge $t4, $t6, L11   # exit loop when j >= n - i*2
    li $v0, 4
    la $a0, star
    syscall
    addi $t4, $t4, 1
    jal L10

L11: 
    li $v0, 4
    la $a0, newline
    syscall

    addi $t2, $t2, -1
    jal L7

L12:
    li $v0, 10
    syscall


