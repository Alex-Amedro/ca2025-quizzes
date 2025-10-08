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
    # Save return address
    addi x21, x21, -4
    sw x20, 0(x21)
    
    jal x20, init_registers
    blt x1, x3, skip_encode
    li x3, 0
    
    # Count Leading Zeros (CLZ)
    add x6, x1, x0              # x6 = value
    loop:
        beq x5, x0, end_loop    # if step == 0, exit
        srl x7, x6, x5          # x7 = value >> step
        beq x7, x0, skip2       # if zero, skip
        sub x4, x4, x5          # counter -= step
        addi x6, x7, 0          # value = x7
    skip2:
        li x10, 1
        srl x5, x5, x10         # step >>= 1
        j loop
    end_loop:
    
    # Calculate MSB
    sub x3, x4, x6              # x3 = lz
    li x4, 31
    sub x4, x4, x3              # x4 = msb
    
    # Calculate exponent and overflow
    li x5, 0                    # x5 = exponent
    li x6, 0                    # x6 = overflow
    li x7, 0                    # x7 = loop index
    li x11, 5
    li x12, 4
    li x13, 16
    li x14, 4
    li x15, 15
    
    blt x4, x11, skip3          # if msb < 5, skip
        sub x5, x4, x12         # exponent = msb - 4
        blt x5, x13, skip4
            li x5, 15           # clamp to 15
    skip4:
    
    # Build overflow
    loop3:
        bge x7, x5, loop3_end
        sll x6, x6, x10         # overflow <<= 1
        addi x6, x6, 16         # overflow += 16
        addi x7, x7, 1
        j loop3
    loop3_end:
    
    # Adjust overflow
    loop4:
        blt x5, x10, loop4_end
        blt x6, x1, loop4_end
        beq x6, x1, loop4_end
        addi x6, x6, -16        # overflow -= 16
        srl x6, x6, x10         # overflow >>= 1
        addi x5, x5, -1         # exponent--
        j loop4
    loop4_end:
    skip3:
    
    # Find exact exponent
    li x7, 0
    loop5:
        bge x5, x15, loop5_end
        sll x7, x6, x10         # next_overflow = overflow << 1
        addi x7, x7, 16         # next_overflow += 16
        bge x7, x1, loop5_end   # if value < next_overflow, break
        addi x6, x7, 0          # overflow = next_overflow
        addi x5, x5, 1          # exponent++
        j loop5
    loop5_end:
    
    # Calculate mantissa and combine
    li x7, 0
    sub x7, x1, x6              # x7 = value - overflow
    srl x7, x7, x5              # mantissa = x7 >> exponent
    sll x2, x5, x14             # x2 = exponent << 4
    or x2, x2, x7               # x2 = (exponent << 4) | mantissa
    j encode_return

init_registers:
    li x2, 0                    # return value
    li x3, 16                   # comparison value
    li x4, 32                   # counter
    li x5, 16                   # step size
    jr x20

skip_encode:
    add x2, x0, x1              # return value as-is
    jr x20
    
encode_return:
    lw x20, 0(x21)
    addi x21, x21, 4
    jr x20

exit_program:
    li a7, 10
    ecall