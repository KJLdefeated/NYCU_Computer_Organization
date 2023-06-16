.data
    msg1: .asciiz "Enter the number n = "
    msg2: .asciiz " is a prime"
    msg3: .asciiz " is not a prime, the nearest prime is"
    space:.asciiz " "
    newline:.asciiz "\n"

.text
main:
    li $v0, 4
    la $a0, msg1
    syscall

    li $v0, 5
    syscall
    move $s0, $v0   #n = s0

    add $t5, $zero, $s0
    jal prime
L1:
    move $t1, $v0
    beq $t1, $zero, L4

    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, msg2
    syscall

    jal end

L4:
    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, msg3
    syscall

    addi $t1, $zero, 1 #t1 = i
    addi $t7, $zero, 0 #t7 = flag
loop:    
    bne $t7, $zero, end

    sub $t2, $s0, $t1
    add $t5, $zero, $t2
    jal prime
    move $t3, $v0
    beq $t3, $zero, is_not_prime

    li $v0, 4
    la $a0, space
    syscall
    li $v0, 1
    move $a0, $t2
    syscall
    addi $t7, $zero, 1

is_not_prime:   
    add $t2, $s0, $t1
    add $t5, $zero, $t2
    jal prime
    move $t3, $v0
    beq $t3, $zero, is_not_prime2

    li $v0, 4
    la $a0, space
    syscall
    li $v0, 1
    move $a0, $t2
    syscall
    addi $t7, $zero, 1

is_not_prime2: 
    addi $t1, $t1, 1
    jal loop


end:
    li $v0, 10
    syscall

#-------------------------
prime:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    addi $v0, $zero, 0
    addi $t0, $zero, 1
    beq $t5, 1, L33

    addi $t0, $zero, 2
L2:
    mul $t4, $t0, $t0
    bgt $t4, $t5, L3
    div $t4, $t5, $t0 #n%i
    mfhi $t4
    beq $t4, $zero, L33
    addi $t0, $t0, 1
    jal L2
L3:
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
    addi $v0, $zero, 1
    jr $ra

L33:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

