# Functional code all made by me (no exceptions: no line completion and no generated code) (if you find something that seems AI generated i'm may be just to inteligent or more stupid than a probabilist model, we'll never know)
# Some comments may be hard to understand due to my English, to counter that comments could have been made by Copilot
#you can run the programme and look at the memory addresses to see the results  
.data
bf16_a: .word 0x4000
result: .word 0
# List of registers used:
# x1: result value 
# x2: ra 
# x3: sp
# x4: sign
# x5: exp
# x6: mant
# x8: e
# x9: new_exp
# x10: bf16_a
# x11: m 
# x12: low
# x13: high
# x14: result_sqrt
# x15: mid
# x18: sq
.text
.global main

main: 
    la x10, bf16_a
    lw x10, 0(x10)
    
sqrt:
    jal x2, init
    
    li x7, 0xFF
    bne x5, x7, skip1
        bnez x6, return_a
        bnez x4, return_nan
        j return_a
    skip1:
    
    or x7, x5, x6
    bnez x7, skip2
        li x1, 0
        j return
    skip2:
    
    bnez x4, return_nan
    
    bnez x5, skip3
        li x1, 0
        j return
    skip3:
    
    li x7, 127
    sub x8, x5, x7
    
    ori x11, x6, 0x80
    
    andi x7, x8, 1
    beqz x7, skip4
        slli x11, x11, 1
        addi x8, x8, -1
        srai x9, x8, 1
        addi x9, x9, 127
        j skip5
    skip4:
        srai x9, x8, 1
        addi x9, x9, 127
    skip5:
    
    li x12, 90
    li x13, 256
    li x14, 128
    
    while_loop: 
        bltu x13, x12, end_loop
        add x15, x12, x13
        srli x15, x15, 1
        mul x18, x15, x15
        li x7, 128
        divu x18, x18, x7
        bltu x11, x18, skip6
            mv x14, x15
            addi x12, x15, 1
            j skip7
        skip6:
            addi x13, x15, -1
        skip7:
        j while_loop
    end_loop:
    
    li x7, 256
    blt x14, x7, skip8
        srli x14, x14, 1
        addi x9, x9, 1
        j skip9
    skip8:
        li x7, 128
        bge x14, x7, skip9
        loop_2:
            li x7, 128
            bge x14, x7, skip10
                li x16, 1
                ble x9, x16, skip10
                slli x14, x14, 1
                addi x9, x9, -1
                j loop_2
        skip10:
    skip9:
    
    andi x14, x14, 0x7F
    
    li x7, 0xFF
    bge x9, x7, return_inf
    
    blez x9, return_zero
    
    andi x9, x9, 0xFF
    slli x9, x9, 7
    or x1, x9, x14
    j return
    
init:
    srli x4, x10, 15
    srli x5, x10, 7
    andi x5, x5, 0xFF
    andi x6, x10, 0x7F
    jr x2
    
return_a:
    add x1, x10, x0
    j return
    
return_nan:
    li x1, 0x7FC0
    j return
    
return_inf:
    li x1, 0x7F80
    j return
    
return_zero:
    li x1, 0
    j return
    
return:
    la x7, result
    sw x1, 0(x7)
    j end 
    
end: 
    li a7, 10
    ecall