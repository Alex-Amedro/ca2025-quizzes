# Functional code all made by me 
# Some comments may be hard to understand due to my English level, to counter that comments could have been made by Copilot
#you can run the programme and look at the memory addresses to see the results  

# this code as been reviewed and corrected by ChatGPT due to a loop error that i wasn't able to fix myself

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
    jal x2, init_sqrt
    
    li x7, 0xFF
    bne x5, x7, skip1_sqrt
        bnez x6, return_a_sqrt
        bnez x4, return_nan_sqrt
        j return_a_sqrt
    skip1_sqrt:
    
    or x7, x5, x6
    bnez x7, skip2_sqrt
        li x1, 0
        j return_sqrt
    skip2_sqrt:
    
    bnez x4, return_nan_sqrt
    
    bnez x5, skip3_sqrt
        li x1, 0
        j return_sqrt
    skip3_sqrt:
    
    li x7, 127
    sub x8, x5, x7
    
    ori x11, x6, 0x80
    
    andi x7, x8, 1
    beqz x7, skip4_sqrt
        slli x11, x11, 1
        addi x8, x8, -1
        srai x9, x8, 1
        addi x9, x9, 127
        j skip5_sqrt
    skip4_sqrt:
        srai x9, x8, 1
        addi x9, x9, 127
    skip5_sqrt:
    
    li x12, 90
    li x13, 256
    li x14, 128
    
    while_loop_sqrt:
        bltu x13, x12, end_loop_sqrt
        add x15, x12, x13
        srli x15, x15, 1
        
        li x18, 0
        li x19, 0
        mv x20, x15
        mv x25, x15                  
        sqrt_mul_loop:
            li x21, 8
            beq x19, x21, sqrt_mul_end
            andi x21, x20, 1
            beqz x21, sqrt_mul_skip
                add x18, x18, x25     
            sqrt_mul_skip:
            slli x25, x25, 1          
            srli x20, x20, 1
            addi x19, x19, 1
            j sqrt_mul_loop
        sqrt_mul_end:
        
        bltu x11, x18, skip6_sqrt
            mv x14, x15
            addi x12, x15, 1
            j skip7_sqrt
        skip6_sqrt:
            addi x13, x15, -1
        skip7_sqrt:
        j while_loop_sqrt
    end_loop_sqrt:
    
    li x7, 256
    blt x14, x7, skip8_sqrt
        srli x14, x14, 1
        addi x9, x9, 1
        j skip9_sqrt
    skip8_sqrt:
        li x7, 128
        bge x14, x7, skip9_sqrt
        loop_2_sqrt:
            li x7, 128
            bge x14, x7, skip10_sqrt
                li x16, 1
                ble x9, x16, skip10_sqrt
                slli x14, x14, 1
                addi x9, x9, -1
                j loop_2_sqrt
        skip10_sqrt:
    skip9_sqrt:
    
    andi x14, x14, 0x7F
    
    li x7, 0xFF
    bge x9, x7, return_inf_sqrt
    
    blez x9, return_zero_sqrt
    
    andi x9, x9, 0xFF
    slli x9, x9, 7
    or x1, x9, x14
    j return_sqrt

init_sqrt:
    srli x4, x10, 15
    srli x5, x10, 7
    andi x5, x5, 0xFF
    andi x6, x10, 0x7F
    jr x2

    
return_a_sqrt:
    add x1, x10, x0
    j return
    
return_nan_sqrt:
    li x1, 0x7FC0
    j return
    
return_inf_sqrt:
    li x1, 0x7F80
    j return
    
return_zero_sqrt:
    li x1, 0
    j return
    
return:
    la x7, result
    sw x1, 0(x7)
    j end 
    
end: 
    li a7, 10
    ecall