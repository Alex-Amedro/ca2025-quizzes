# Functional code all made by me (no exceptions: no line completion and no generated code)
# Some comments may be hard to understand due to my English, to counter that comments could have been made by Copilot
.data
result1: .word 0
result2: .word 0
result3: .word 0

.text
.global main

main:
    # Test 1: encode 1000
    li x1, 1000
    jal x20, encode_uf8
    la x10, result1
    sw x2, 0(x10)
    
    # Test 2: encode 10000
    li x1, 10000
    jal x20, encode_uf8
    la x10, result2
    sw x2, 0(x10)
    
    # Test 3: encode 100000
    li x1, 100000
    jal x20, encode_uf8
    la x10, result3
    sw x2, 0(x10)
    
    j exit_program

encode_uf8:
    
    addi x21, x21, -4
    sw x20, 0(x21)
    
    jal x20, init_registers
    blt x1, x3, skip_encode
    li x3, 0

    # CLZ 
    # x3 = LZ
    # x4 = count
    # x5 = step size 
    # x6 = working value
    # x7 = temp register
    add x6, x1, x0
    loop:
        beq x5, x0, end_loop         # stop if step size is 0
        srl x7, x6, x5               # shift value right by step
        beq x7, x0, skip2            # if still zero, skip update
        sub x4, x4, x5               # reduce count by step
        addi x6, x7, 0               # update working value
    skip2:
        li x10, 1
        srl x5, x5, x10              # divide step by 2
        j loop
    end_loop:

    # msb
    sub x3, x4, x6
    li x4, 31
    sub x4, x4, x3

    # x3 = lz
    # x4 = msb
    # x5 = exponent
    # x6 = overflow
    # x7 = loop index
    li x5, 0
    li x6, 0
    li x7, 0
    li x11, 5
    li x12, 4
    li x13, 16
    li x14, 4                        # used for final shift
    li x15, 15                       # max exponent

    blt x4, x11, skip3               # if msb < 5, skip
        sub x5, x4, x12              # exponent = msb - 4
        blt x5, x13, skip4           # if exponent < 16, continue
            li x5, 15                # else clamp exponent to 15
    skip4:

    # Build overflow 
    loop3:
        bge x7, x5, loop3_end
        sll x6, x6, x10
        addi x6, x6, 16
        addi x7, x7, 1
        j loop3
    loop3_end:

    # Adjust overflow 
    loop4:
        blt x5, x10, loop4_end       # stop if exponent < 1
        blt x6, x1, loop4_end        # stop if overflow < value
        beq x6, x1, loop4_end        # stop if overflow == value
        addi x6, x6, -16             # decrease overflow
        srl x6, x6, x10              # divide by 2
        addi x5, x5, -1              # reduce exponent
        j loop4
    loop4_end:

    skip3:
    li x7, 0
    # overflow expansion loop
    loop5:
        bge x5, x15, loop5_end       # stop if exponent = 15
        sll x7, x6, x10
        addi x7, x7, 16
        bge x7, x1, loop5_end        # stop if new overflow >= value
        addi x6, x7, 0               # update overflow
        addi x5, x5, 1               # increase exponent
        j loop5
    loop5_end:

    # Mantissa part
    li x7, 0
    sub x7, x1, x6                   # value - overflow
    srl x7, x7, x5                   # scale by exponent
    sll x2, x5, x14                  # put exponent in high bits
    or x2, x2, x7                    # combine exponent + mantissa

    j encode_return

init_registers:
    li x2, 0                         # return value
    li x3, 16                        # comparison value
    li x4, 32                        # counter for CLZ
    li x5, 16                        # step size for CLZ
    jr x20

skip_encode:
    add x2, x0, x1                   # if value < 16, just return value
    
encode_return:
    lw x20, 0(x21)
    addi x21, x21, 4
    jr x20

exit_program:
    li a7, 10                        # exit
    ecall