.data
result: .word 0                

.text
.global main

main:
    jal x20, init
    blt x1, x3, skip_encode
    li x3, 0

    # CLZ (count leading zeros) imitation
    # x3 = result of CLZ
    # x4 = counter for CLZ
    # x5 = step size for CLZ
    # x6 = working value
    # x7 = temp register
    add x6, x1, x0
    loop:
        beq x5, x0, end_loop       # stop if step size is 0
        srl x7, x6, x5             # shift value right by step
        beq x7, x0, skip2          # if still zero, skip update
        sub x4, x4, x5             # reduce count by step
        addi x6, x7, 0             # update working value
    skip2:
        li x10, 1
        srl x5, x5, x10            # divide step by 2
        j loop
    end_loop:

    # Now we have leading zeros in x3
    # Compute msb (position of most significant bit)
    sub x3, x4, x6
    li x4, 31
    sub x4, x4, x3

    # x3 = leading zeros
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
    li x14, 4                      # used for final shift
    li x15, 15                     # max exponent
    
    blt x4, x11, skip3             # if msb < 5, skip
        sub x5, x4, x12            # exponent = msb - 4
        blt x5, x13, skip4         # if exponent < 16, continue
            li x5, 15              # else clamp exponent to 15
    skip4:

    # Build overflow value by shifting and adding 16
    loop3:
        bge x7, x5, loop3_end
        sll x6, x6, x10
        addi x6, x6, 16
        addi x7, x7, 1
        j loop3
    loop3_end:

    # Adjust overflow until it fits the value
    loop4:
        blt x5, x10, loop4_end     # stop if exponent < 1
        blt x6, x1, loop4_end      # stop if overflow < value
        beq x6, x1, loop4_end      # stop if overflow == value
        addi x6, x6, -16           # decrease overflow
        srl x6, x6, x10            # divide by 2
        addi x5, x5, -1            # reduce exponent
        j loop4
    loop4_end:
    
    skip3:
    li x7, 0
    # overflow expansion loop
    loop5:
        bge x5, x15, loop5_end     # stop if exponent = 15
        sll x7, x6, x10
        addi x7, x7, 16
        bge x7, x1, loop5_end      # stop if new overflow >= value
        addi x6, x7, 0             # update overflow
        addi x5, x5, 1             # increase exponent
        j loop5
    loop5_end:

    # Mantissa part
    li x7, 0
    sub x7, x1, x6                 # value - overflow
    srl x7, x7, x5                 # scale by exponent
    sll x2, x5, x14                # put exponent in high bits
    or x2, x2, x7                  # combine exponent + mantissa

    j return

init:
    li x1, 9458                      # value to encode
    li x2, 0                       # return value
    li x3, 16                      # comparison value
    li x4, 32                      # counter for CLZ
    li x5, 16                      # step size for CLZ
    jr x20

skip_encode:
    add x2, x0, x1                 # if value < 16, just return value
    j return

return:
    la x10, result                 # load address of result
    sw x2, 0(x10)                  # store encoded value
    li a7, 10                      # exit
    ecall
