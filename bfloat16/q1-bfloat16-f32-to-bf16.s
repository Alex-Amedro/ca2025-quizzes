.# Functional code all made by me (no exceptions: no line completion and no generated code)
.# Some comments may be hard to understand due to my English level, to counter that comments could have been made by Copilot
.#you can run the programme and look at the memory addresses to see the results  

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
# x10: exp_diff
# x11: result_sign
# x12: result_exp
# x13: result_mant
# x14: bf16_a 
# x15: bf16_b

.text
.global main

main: 
    la x14, bf16_a
    lw x14, 0(x14)            # load the bf16_a value
    la x15, bf16_b
    lw x15, 0(x15)            # load the bf16_b value

    srli x4, x14, 15          # sign_a
    srli x5, x15, 15          # sign_b
    srli x6, x14, 7           # exp_a
    andi x6, x6, 0xFF         # isolate exponent
    srli x7, x15, 7           # exp_b
    andi x7, x7, 0xFF         # isolate exponent
    andi x8, x14, 0x7F        # mant_a
    andi x9, x15, 0x7F        # mant_b

    
add:
    li x16, 0xFF
    bne x6, x16, skip1
        bne x8, x0, return_a
            bne x7, x16, skip2
                bne x9, x0, return_b    
                beq x4, x5, return_b    
                li x1, 0xFFC0           
                j return
            skip2:
        return_a:
            add x1, x14, x0
            j return
    skip1:

    li x16, 0xFF
    beq x7, x16, return_b
    
    or x16, x6, x8
    beq x16, x0, return_b
    
    or x16, x7, x9
    beq x16, x0, return_a
    
    
    beq x6, x0, skip3
        ori x8, x8, 0x80
    skip3:

    beq x7, x0, skip4
        ori x9, x9, 0x80
    skip4:

    sub x10, x6, x7         

    blez x10, skip5
        add x12, x6, x0
        li x16, 8
        bge x10, x16, return_a
        srl x9, x9, x10
        j skip7

    skip5:
    bgez x10, skip6
        add x12, x7, x0
        li x16, -8
        blt x10, x16, return_b
        sub x16, x0, x10      
        srl x8, x8, x16
        j skip7
    skip6:
        add x12, x6, x0
    skip7:

    bne x4, x5, skip8
    
    add x11, x4, x0           
    add x13, x8, x9          
    
    andi x16, x13, 0x100
    beq x16, x0, skip9
        srli x13, x13, 1
        addi x12, x12, 1
        li x16, 0xFF
        blt x12, x16, skip9
            slli x1, x11, 15
            li x16, 0x7F80
            or x1, x1, x16
            j return
    skip9:
    j combine_result
    
skip8:
    blt x8, x9, skip10
        add x11, x4, x0
        sub x13, x8, x9
        j skip11
    skip10:
        add x11, x5, x0
        sub x13, x9, x8
    
skip11:
    beq x13, x0, return_zero
    
skip12:
    andi x16, x13, 0x80
    bne x16, x0, skip13
        slli x13, x13, 1
        addi x12, x12, -1
        blez x12, return_zero
        j skip12
skip13:

combine_result:
    slli x1, x11, 15
    andi x16, x12, 0xFF
    slli x16, x16, 7
    or x1, x1, x16
    andi x16, x13, 0x7F
    or x1, x1, x16
    j return

return_b:
    add x1, x15, x0
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