.data
result1: .word 0
result2: .word 0
result3: .word 0  

.text
.global main

main:
    # Test 1: decode 0x5f ~ 1000
    li x1, 0x5f
    jal x20, decode_uf8
    la x10, result1
    sw x2, 0(x10)
    
    # Test 2: decode 0x93 ~ 10000
    li x1, 0x93
    jal x20, decode_uf8
    la x10, result2
    sw x2, 0(x10)
    
    # Test 3: decode 0xc8 ~ 100000
    li x1, 0xc8
    jal x20, decode_uf8
    la x10, result3
    sw x2, 0(x10)
    
    j exit_program

decode_uf8:
    # Save return address
    addi x21, x21, -4
    sw x20, 0(x21)
    
    jal x20, init_decode
    
    # Decode formula: (mantissa << exponent) + offset
    and x3, x1, x6              # x3 = mantissa = fl & 0x0F
    srl x4, x1, x7              # x4 = exponent = fl >> 4
    sub x5, x8, x4              # x5 = 15 - exponent
    srl x5, x9, x5              # offset = 0x7FFF >> (15 - exponent)
    sll x5, x5, x7              # offset <<= 4
    sll x2, x3, x4              # x2 = mantissa << exponent
    add x2, x2, x5              # x2 += offset
    j return_decode

init_decode:                   
    li x2, 0                    # return value
    li x3, 0                    # mantissa
    li x4, 0                    # exponent
    li x5, 0                    # offset 
    li x6, 0x0F                 # mask for mantissa
    li x7, 4                    # shift amount
    li x8, 15                   # max exponent
    li x9, 0x7FFF               # offset base
    jr x20

return_decode:
    lw x20, 0(x21)
    addi x21, x21, 4
    jr x20

exit_program:
    li a7, 10
    ecall