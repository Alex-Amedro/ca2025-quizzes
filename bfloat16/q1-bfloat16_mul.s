# Functional code all made by me (no exceptions: no line completion and no generated code) (if you find something that seems AI generated i'm may be just to inteligent or more stupid than a probabilist model, we'll never know)
# Some comments may be hard to understand due to my English, to counter that comments could have been made by Copilot
#you can run the programme and look at the memory addresses to see the results  
.data
bf16_a: .word 0x3F80
bf16_b: .word 0x4000
result: .word 0
# List of registers used:
# x1: result value 
# x2: ra 
# x3: sp
# x4: sign_a
# x5: sign_b
# x6: exp_a
# x7: exp_b
# x8: mant_a
# x9: mant_b
# x10: bf16_a
# x11: bf16_b
# x12: result_sign
# x13: exp_adjust
# x14: result_mant
# x15: result_exp
# x16: temporary
# x17: temporary
.text
.global main
main: 
    la x10, bf16_a
    lw x10, 0(x10)
    la x11, bf16_b
    lw x11, 0(x11)
    
mul:
    jal x2, init
    
    li x16, 0xFF
    bne x6, x16, skip1
        bnez x8, return_a
        or x17, x7, x9
        beqz x17, return_NAN
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j return
    skip1:
    
    li x16, 0xFF
    bne x7, x16, skip2
        bnez x9, return_b
        or x17, x6, x8
        beqz x17, return_NAN
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j return
    skip2:
    
    or x17, x6, x8
    or x16, x7, x9
    bnez x17, skip3
        slli x1, x12, 15
        j return
    skip3:
    bnez x16, skip4
        slli x1, x12, 15
        j return
    skip4:
    
    li x13, 0
    
    bnez x6, skip5
        normalize_a:
            andi x16, x8, 0x80
            bnez x16, skip6
                slli x8, x8, 1
                addi x13, x13, -1
                j normalize_a
        skip6:
        li x6, 1
        j skip7
    skip5:
        ori x8, x8, 0x80
    skip7:
    
    bnez x7, skip8
        normalize_b:
            andi x16, x9, 0x80
            bnez x16, skip9
                slli x9, x9, 1
                addi x13, x13, -1
                j normalize_b
        skip9:
        li x7, 1
        j skip10
    skip8:
        ori x9, x9, 0x80
    skip10:
    
    mul x14, x8, x9
    
    add x15, x6, x7
    li x16, 127
    sub x15, x15, x16
    add x15, x15, x13
    
    li x16, 0x8000
    and x17, x14, x16
    beqz x17, skip11
        srli x14, x14, 8
        andi x14, x14, 0x7F
        addi x15, x15, 1
        j skip12
    skip11:
        srli x14, x14, 7
        andi x14, x14, 0x7F
    skip12:
    
    li x16, 0xFF
    blt x15, x16, skip13
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j return
    skip13:
    
    bgtz x15, skip14
        li x17, -6
        blt x15, x17, skip15
            li x16, 1
            sub x16, x16, x15
            srl x14, x14, x16
            li x15, 0
            j skip14
        skip15:
            slli x1, x12, 15
            j return
    skip14:
    
    slli x1, x12, 15
    andi x16, x15, 0xFF
    slli x16, x16, 7
    or x1, x1, x16
    andi x16, x14, 0x7F
    or x1, x1, x16
    j return
    
init:
    srli x4, x10, 15
    srli x5, x11, 15
    srli x6, x10, 7
    andi x6, x6, 0xFF
    srli x7, x11, 7
    andi x7, x7, 0xFF
    andi x8, x10, 0x7F
    andi x9, x11, 0x7F
    xor x12, x4, x5
    jr x2
    
return_a:
    add x1, x10, x0
    j return 
    
return_b:
    add x1, x11, x0
    j return
    
return_NAN:
    li x1, 0xFFC0
    j return
    
return:
    la x7, result
    sw x1, 0(x7)
    j end 
    
end: 
    li a7, 10
    ecall