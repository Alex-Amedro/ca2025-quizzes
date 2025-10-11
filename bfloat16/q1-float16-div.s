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
# x13: dividend
# x14: divisor
# x15: quotient
# x16: temporary
# x17: temporary
# x18: loop counter
# x19: temporary
# x20: temporary
# x21: temporary
# x22: result_exp
.text
.global main

main: 
    la x10, bf16_a
    lw x10, 0(x10)
    la x11, bf16_b
    lw x11, 0(x11)
    
div:
    jal x2, init
    
    li x16, 0xFF
    bne x7, x16, skip1
        bnez x9, return_b
        li x16, 0xFF
        bne x6, x16, skip1_1
            bnez x8, skip1_1
                li x1, 0x7FC0
                j return
        skip1_1:
        slli x1, x12, 15
        j return
    skip1:
    
    or x17, x7, x9
    bnez x17, skip2
        or x17, x6, x8
        bnez x17, skip2_1
            li x1, 0x7FC0
            j return
        skip2_1:
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j return
    skip2:
    
    li x16, 0xFF
    bne x6, x16, skip3
        bnez x8, return_a
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j return
    skip3:
    
    or x17, x6, x8
    bnez x17, skip4
        slli x1, x12, 15
        j return
    skip4:
    
    bnez x6, skip5
        ori x8, x8, 0x80
        j skip6
    skip5:
        ori x8, x8, 0x80
    skip6:
    
    bnez x7, skip7
        ori x9, x9, 0x80
        j skip8
    skip7:
        ori x9, x9, 0x80
    skip8:
    
    slli x13, x8, 15
    mv x14, x9
    li x15, 0
    li x18, 0
    
    loop:
        li x19, 16
        beq x18, x19, end_loop
        slli x15, x15, 1
        li x20, 15
        sub x20, x20, x18
        sll x21, x14, x20
        bltu x13, x21, skip9
            sub x13, x13, x21
            ori x15, x15, 1
        skip9:
        addi x18, x18, 1
        j loop
    end_loop:
    
    sub x22, x6, x7
    addi x22, x22, 127
    bnez x6, skip10
        addi x22, x22, -1
    skip10:
    bnez x7, skip11
        addi x22, x22, 1
    skip11:
    
    li x16, 0x8000
    and x17, x15, x16
    beqz x17, loop_2
        srli x15, x15, 8
        j skip12
    
    loop_2:
        li x16, 0x8000
        and x17, x15, x16
        bnez x17, end_loop_2
            li x19, 1
            ble x22, x19, end_loop_2
            slli x15, x15, 1
            addi x22, x22, -1
            j loop_2
    end_loop_2:
        srli x15, x15, 8
    skip12:
    
    andi x15, x15, 0x7F
    
    li x16, 0xFF
    blt x22, x16, skip13
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j return
    skip13:
    
    bgtz x22, skip14
        slli x1, x12, 15
        j return
    skip14:
    
    slli x1, x12, 15
    andi x22, x22, 0xFF
    slli x22, x22, 7
    or x1, x1, x22
    andi x15, x15, 0x7F
    or x1, x1, x15
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
    
return:
    la x7, result
    sw x1, 0(x7)
    j end 
    
end: 
    li a7, 10
    ecall