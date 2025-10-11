.data
test_a: .word 0x3F80    # 1.0
test_b: .word 0x4000    # 2.0
test_c: .word 0x4040    # 3.0
test_d: .word 0x4080    # 4.0
test_e: .word 0x4100    # 9.0
inf_pos: .word 0x7F80   # +Inf
inf_neg: .word 0xFF80   # -Inf
nan_val: .word 0x7FC0   # NaN
zero_val: .word 0x0000  # 0.0

result_add1: .word 0
result_add2: .word 0
result_sub1: .word 0
result_mul1: .word 0
result_div1: .word 0
result_sqrt1: .word 0
result_sqrt2: .word 0

msg_test1: .string "Test Add 1.0+2.0: "
msg_test2: .string "Test Add Inf+1.0: "
msg_test3: .string "Test Sub 2.0-1.0: "
msg_test4: .string "Test Mul 3.0*4.0: "
msg_test5: .string "Test Div 9.0/3.0: "
msg_test6: .string "Test Sqrt 4.0: "
msg_test7: .string "Test Sqrt 9.0: "
msg_pass: .string "PASS\n"
msg_fail: .string "FAIL\n"


.text
.global main

main: 
    la a0, msg_test1
    li a7, 4
    ecall
    la x14, test_a
    lw x14, 0(x14)
    la x15, test_b
    lw x15, 0(x15)
    jal x2, add
    la x7, result_add1
    sw x1, 0(x7)
    li x16, 0x4040
    beq x1, x16, test1_pass
    la a0, msg_fail
    li a7, 4
    ecall
    j test2
test1_pass:
    la a0, msg_pass
    li a7, 4
    ecall

test2:
    la a0, msg_test2
    li a7, 4
    ecall
    la x14, inf_pos
    lw x14, 0(x14)
    la x15, test_a
    lw x15, 0(x15)
    jal x2, add
    la x7, result_add2
    sw x1, 0(x7)
    li x16, 0x7F80
    beq x1, x16, test2_pass
    la a0, msg_fail
    li a7, 4
    ecall
    j test3
test2_pass:
    la a0, msg_pass
    li a7, 4
    ecall

test3:
    la a0, msg_test3
    li a7, 4
    ecall
    la x14, test_b
    lw x14, 0(x14)
    la x15, test_a
    lw x15, 0(x15)
    jal x2, sub
    la x7, result_sub1
    sw x1, 0(x7)
    li x16, 0x3F80
    beq x1, x16, test3_pass
    la a0, msg_fail
    li a7, 4
    ecall
    j test4
test3_pass:
    la a0, msg_pass
    li a7, 4
    ecall
test4:
    la a0, msg_test4
    li a7, 4
    ecall
    la x10, test_c
    lw x10, 0(x10)
    la x11, test_d
    lw x11, 0(x11)
    jal x2, mul
    la x7, result_mul1
    sw x1, 0(x7)
    li x16, 0x4140
    beq x1, x16, test4_pass
    la a0, msg_fail
    li a7, 4
    ecall
    j test5
test4_pass:
    la a0, msg_pass
    li a7, 4
    ecall


    j end

#---add-sub--------------------------------------------------------------------
init_add_sub:
    srli x4, x14, 15          # sign_a
    srli x5, x15, 15          # sign_b
    srli x6, x14, 7           # exp_a
    andi x6, x6, 0xFF         # isolate exponent
    srli x7, x15, 7           # exp_b
    andi x7, x7, 0xFF         # isolate exponent
    andi x8, x14, 0x7F        # mant_a
    andi x9, x15, 0x7F        # mant_b
    jr x2

sub:
    li x16, 0x8000          
    xor x15, x15, x16    
    j add
    
   
add:
    srli x4, x14, 15
    srli x5, x15, 15
    srli x6, x14, 7
    andi x6, x6, 0xFF
    srli x7, x15, 7
    andi x7, x7, 0xFF
    andi x8, x14, 0x7F
    andi x9, x15, 0x7F

    li x16, 0xFF
    bne x6, x16, add_skip1
        bne x8, x0, add_return_a
            bne x7, x16, add_skip2
                bne x9, x0, add_return_b
                beq x4, x5, add_return_b
                li x1, 0xFFC0
                j add_exit
            add_skip2:
                j add_return_a
    add_skip1:

    li x16, 0xFF
    beq x7, x16, add_return_b
    
    or x16, x6, x8
    beq x16, x0, add_return_b
    
    or x16, x7, x9
    beq x16, x0, add_return_a
    
    beq x6, x0, add_skip3
        ori x8, x8, 0x80
    add_skip3:

    beq x7, x0, add_skip4
        ori x9, x9, 0x80
    add_skip4:

    sub x10, x6, x7

    blez x10, add_skip5
        add x12, x6, x0
        li x16, 8
        bge x10, x16, add_return_a
        srl x9, x9, x10
        j add_skip7
    add_skip5:
    bgez x10, add_skip6
        add x12, x7, x0
        li x16, -8
        blt x10, x16, add_return_b
        sub x16, x0, x10
        srl x8, x8, x16
        j add_skip7
    add_skip6:
        add x12, x6, x0
    add_skip7:

    bne x4, x5, add_subtraction_path
    
add_addition_path:
    add x11, x4, x0
    add x13, x8, x9
    
    andi x16, x13, 0x100
    beq x16, x0, add_skip9
        srli x13, x13, 1
        addi x12, x12, 1
        li x16, 0xFF
        blt x12, x16, add_skip9
            slli x1, x11, 15
            li x16, 0x7F80
            or x1, x1, x16
            j add_exit
    add_skip9:
    j add_build_result
    
add_subtraction_path:
    blt x8, x9, add_swap
        add x11, x4, x0
        sub x13, x8, x9
        j add_normalize
    add_swap:
        add x11, x5, x0
        sub x13, x9, x8
    
add_normalize:
    beq x13, x0, add_return_zero
    
add_normalize_loop:
    andi x16, x13, 0x80
    bne x16, x0, add_build_result
        slli x13, x13, 1
        addi x12, x12, -1
        blez x12, add_return_zero
        j add_normalize_loop

add_build_result:
    slli x1, x11, 15
    andi x16, x12, 0xFF
    slli x16, x16, 7
    or x1, x1, x16
    andi x16, x13, 0x7F
    or x1, x1, x16
    j add_exit



#------------------------------------------------------------------------
mul:
    jal x2, init_mul
    
    li x16, 0xFF
    bne x6, x16, mul_skip1
        bnez x8, mul_return_a
        or x17, x7, x9
        beqz x17, mul_return_NAN
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j mul_exit
    mul_skip1:
    
    li x16, 0xFF
    bne x7, x16, mul_skip2
        bnez x9, mul_return_b
        or x17, x6, x8
        beqz x17, mul_return_NAN
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j mul_exit
    mul_skip2:
    
    or x17, x6, x8
    or x16, x7, x9
    bnez x17, mul_skip3
        slli x1, x12, 15
        j mul_exit
    mul_skip3:
    bnez x16, mul_skip4
        slli x1, x12, 15
        j mul_exit
    mul_skip4:

    li x13, 0
    
    bnez x6, mul_skip5
        mul_normalize_a:
            andi x16, x8, 0x80
            bnez x16, mul_skip6
                slli x8, x8, 1
                addi x13, x13, -1
                j mul_normalize_a
        mul_skip6:
        li x6, 1
        j mul_skip7
    mul_skip5:
        ori x8, x8, 0x80
    mul_skip7:

    bnez x7, mul_skip8
        mul_normalize_b:
            andi x16, x9, 0x80
            bnez x16, mul_skip9   
                slli x9, x9, 1
                addi x13, x13, -1
                j mul_normalize_b
        mul_skip9:
        li x7, 1
        j mul_skip10
    mul_skip8:
        ori x9, x9, 0x80
    mul_skip10:
    
    mul x14, x8, x9
    
    add x15, x6, x7
    li x16, 127
    sub x15, x15, x16
    add x15, x15, x13
    
    li x16, 0x8000
    and x17, x14, x16
    beqz x17, mul_skip11
        srli x14, x14, 8
        andi x14, x14, 0x7F
        addi x15, x15, 1
        j mul_skip12
    mul_skip11:
        srli x14, x14, 7
        andi x14, x14, 0x7F
    mul_skip12:

    li x16, 0xFF
    blt x15, x16, mul_skip13
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j mul_exit
    mul_skip13:
    
    bgtz x15, mul_skip14
        li x17, -6
        blt x15, x17, mul_skip15
            li x16, 1
            sub x16, x16, x15
            srl x14, x14, x16
            li x15, 0
            j mul_skip14
        mul_skip15:
            slli x1, x12, 15
            j mul_exit
    mul_skip14:

    slli x1, x12, 15
    andi x16, x15, 0xFF
    slli x16, x16, 7
    or x1, x1, x16
    andi x16, x14, 0x7F
    or x1, x1, x16
    j mul_exit
    
init_mul:
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

#------------------------------------------------------------------------

mul_return_NAN:
    li x1, 0xFFC0
    j mul_exit

mul_return_a:
    add x1, x10, x0
    j mul_exit
    
mul_return_b:
    add x1, x11, x0
    j mul_exit

mul_exit:
    jr x2

add_return_a:
    add x1, x14, x0
    j add_exit
    
add_return_b:
    add x1, x15, x0
    j add_exit
    
add_return_zero:
    li x1, 0
    j add_exit

add_exit:
    jr x2

end: 
    li a7, 10
    ecall