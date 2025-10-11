.data
test_a: .word 0x3F80    # 1.0
test_b: .word 0x4000    # 2.0
test_c: .word 0x4040    # 3.0
test_d: .word 0x4080    # 4.0
test_e: .word 0x4100    # 8.0
inf_pos: .word 0x7F80   # +Inf
inf_neg: .word 0xFF80   # -Inf
nan_val: .word 0x7FC0   # NaN
zero_val: .word 0x0000  # 0.0

result_add1: .word 0
result_add2: .word 0
result_sub1: .word 0
result_mul1: .word 0
result_mul2: .word 0
result_div1: .word 0
result_div2: .word 0

msg_test1: .string "Test Add 1.0+2.0: "
msg_test2: .string "Test Add Inf+1.0: "
msg_test3: .string "Test Sub 2.0-1.0: "
msg_test4: .string "Test Mul 3.0*4.0: "
msg_test5: .string "Test Div 8.0/2.0: "
msg_test6: .string "Test Mul Inf*Inf: "
msg_test7: .string "Test Div 0.0/0.0: "
msg_pass: .string "PASS\n"
msg_fail: .string "FAIL\n"

.text
.global main

main:
    # Test 1: Add 1.0 + 2.0 = 3.0
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
    # Test 2: Add Inf + 1.0 = Inf
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
    # Test 3: Sub 2.0 - 1.0 = 1.0
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
    # Test 4: Mul 3.0 * 4.0 = 12.0
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

test5:
    # Test 5: Div 8.0 / 2.0 = 4.0
    la a0, msg_test5
    li a7, 4
    ecall
    la x10, test_e
    lw x10, 0(x10)
    la x11, test_b
    lw x11, 0(x11)
    jal x2, div
    la x7, result_div1
    sw x1, 0(x7)
    li x16, 0x4080
    beq x1, x16, test5_pass
    la a0, msg_fail
    li a7, 4
    ecall
    j test6
test5_pass:
    la a0, msg_pass
    li a7, 4
    ecall

test6:
    # Test 6: Mul Inf * Inf = Inf
    la a0, msg_test6
    li a7, 4
    ecall
    la x10, inf_pos
    lw x10, 0(x10)
    la x11, inf_pos
    lw x11, 0(x11)
    jal x2, mul
    la x7, result_mul2
    sw x1, 0(x7)
    li x16, 0x7F80
    beq x1, x16, test6_pass
    la a0, msg_fail
    li a7, 4
    ecall
    j test7
test6_pass:
    la a0, msg_pass
    li a7, 4
    ecall

test7:
    # Test 7: Div 0.0 / 0.0 = NaN
    la a0, msg_test7
    li a7, 4
    ecall
    la x10, zero_val
    lw x10, 0(x10)
    la x11, zero_val
    lw x11, 0(x11)
    jal x2, div
    la x7, result_div2
    sw x1, 0(x7)
    li x16, 0x7FC0
    beq x1, x16, test7_pass
    la a0, msg_fail
    li a7, 4
    ecall
    j program_end
test7_pass:
    la a0, msg_pass
    li a7, 4
    ecall


program_end:
    li a7, 10
    ecall

# ============================================
# ADDITION FUNCTION
# ============================================
add:
    # init_add a été intégré ici
    srli x4, x14, 15
    srli x5, x15, 15
    srli x6, x14, 7
    andi x6, x6, 0xFF
    srli x7, x15, 7
    andi x7, x7, 0xFF
    andi x8, x14, 0x7F
    andi x9, x15, 0x7F

    li x16, 0xFF
    bne x6, x16, skip1
        bne x8, x0, return_a
            bne x7, x16, skip2
                bne x9, x0, return_b
                beq x4, x5, return_b
                li x1, 0xFFC0
                j return_add
            skip2:
        return_a:
            add x1, x14, x0
            j return_add
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
            j return_add
    skip9:
    j combine_result_add
    
skip8:
    blt x8, x9, skip10
        add x11, x4, x0
        sub x13, x8, x9
        j skip11
    skip10:
        add x11, x5, x0
        sub x13, x9, x8
    
skip11:
    beq x13, x0, return_zero_add
    
skip12:
    andi x16, x13, 0x80
    bne x16, x0, skip13
        slli x13, x13, 1
        addi x12, x12, -1
        blez x12, return_zero_add
        j skip12
skip13:

combine_result_add:
    slli x1, x11, 15
    andi x16, x12, 0xFF
    slli x16, x16, 7
    or x1, x1, x16
    andi x16, x13, 0x7F
    or x1, x1, x16
    j return_add

return_b:
    add x1, x15, x0
    j return_add
    
return_zero_add:
    li x1, 0
    j return_add

return_add:
    jr x2

# ============================================
# SUBTRACTION FUNCTION
# ============================================
sub:
    li x16, 0x8000
    xor x15, x15, x16
    j add

# ============================================
# MULTIPLICATION FUNCTION
# ============================================
mul:
    # init_mul a été intégré ici
    srli x4, x10, 15
    srli x5, x11, 15
    srli x6, x10, 7
    andi x6, x6, 0xFF
    srli x7, x11, 7
    andi x7, x7, 0xFF
    andi x8, x10, 0x7F
    andi x9, x11, 0x7F
    xor x12, x4, x5
    
    li x16, 0xFF
    bne x6, x16, skip1_mul
        bnez x8, return_a_mul
        or x17, x7, x9
        beqz x17, return_NAN
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j return_mul
    skip1_mul:
    
    li x16, 0xFF
    bne x7, x16, skip2_mul
        bnez x9, return_b_mul
        or x17, x6, x8
        beqz x17, return_NAN
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j return_mul
    skip2_mul:
    
    or x17, x6, x8
    or x16, x7, x9
    bnez x17, skip3_mul
        slli x1, x12, 15
        j return_mul
    skip3_mul:
    bnez x16, skip4_mul
        slli x1, x12, 15
        j return_mul
    skip4_mul:
    
    li x13, 0
    
    bnez x6, skip5_mul
        normalize_a:
            andi x16, x8, 0x80
            bnez x16, skip6_mul
                slli x8, x8, 1
                addi x13, x13, -1
                j normalize_a
        skip6_mul:
        li x6, 1
        j skip7_mul
    skip5_mul:
        ori x8, x8, 0x80
    skip7_mul:
    
    bnez x7, skip8_mul
        normalize_b:
            andi x16, x9, 0x80
            bnez x16, skip9_mul
                slli x9, x9, 1
                addi x13, x13, -1
                j normalize_b
        skip9_mul:
        li x7, 1
        j skip10_mul
    skip8_mul:
        ori x9, x9, 0x80
    skip10_mul:
    
    li x14, 0
    li x17, 0
    mv x23, x8
    mv x24, x9
    mul_loop_manual:
        li x18, 8
        beq x17, x18, mul_loop_end
        andi x18, x24, 1
        beqz x18, mul_skip
            add x14, x14, x23
        mul_skip:
        slli x23, x23, 1
        srli x24, x24, 1
        addi x17, x17, 1
        j mul_loop_manual
    mul_loop_end:
    
    add x15, x6, x7
    li x16, 127
    sub x15, x15, x16
    add x15, x15, x13
    
    li x16, 0x8000
    and x17, x14, x16
    beqz x17, skip11_mul
        srli x14, x14, 8
        andi x14, x14, 0x7F
        addi x15, x15, 1
        j skip12_mul
    skip11_mul:
        srli x14, x14, 7
        andi x14, x14, 0x7F
    skip12_mul:
    
    li x16, 0xFF
    blt x15, x16, skip13_mul
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j return_mul
    skip13_mul:
    
    bgtz x15, skip14_mul
        li x17, -6
        blt x15, x17, skip15_mul
            li x16, 1
            sub x16, x16, x15
            srl x14, x14, x16
            li x15, 0
            j skip14_mul
        skip15_mul:
            slli x1, x12, 15
            j return_mul
    skip14_mul:
    
    slli x1, x12, 15
    andi x16, x15, 0xFF
    slli x16, x16, 7
    or x1, x1, x16
    andi x16, x14, 0x7F
    or x1, x1, x16
    j return_mul

return_a_mul:
    add x1, x10, x0
    j return_mul

return_b_mul:
    add x1, x11, x0
    j return_mul

return_NAN:
    li x1, 0xFFC0
    j return_mul

return_mul:
    jr x2

# ============================================
# DIVISION FUNCTION
# ============================================
div:
    # init_div a été intégré ici
    srli x4, x10, 15
    srli x5, x11, 15
    srli x6, x10, 7
    andi x6, x6, 0xFF
    srli x7, x11, 7
    andi x7, x7, 0xFF
    andi x8, x10, 0x7F
    andi x9, x11, 0x7F
    xor x12, x4, x5
    
    li x16, 0xFF
    bne x7, x16, skip1_div
        bnez x9, return_b_div
        li x16, 0xFF
        bne x6, x16, skip1_1_div
            bnez x8, skip1_1_div
                li x1, 0x7FC0
                j return_div
        skip1_1_div:
        slli x1, x12, 15
        j return_div
    skip1_div:
    
    or x17, x7, x9
    bnez x17, skip2_div
        or x17, x6, x8
        bnez x17, skip2_1_div
            li x1, 0x7FC0
            j return_div
        skip2_1_div:
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j return_div
    skip2_div:
    
    li x16, 0xFF
    bne x6, x16, skip3_div
        bnez x8, return_a_div
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j return_div
    skip3_div:
    
    or x17, x6, x8
    bnez x17, skip4_div
        slli x1, x12, 15
        j return_div
    skip4_div:
    
    bnez x6, skip5_div
        ori x8, x8, 0x80
        j skip6_div
    skip5_div:
        ori x8, x8, 0x80
    skip6_div:
    
    bnez x7, skip7_div
        ori x9, x9, 0x80
        j skip8_div
    skip7_div:
        ori x9, x9, 0x80
    skip8_div:
    
    slli x13, x8, 15
    mv x14, x9
    li x15, 0
    li x18, 0
    
    loop_div:
        li x19, 16
        beq x18, x19, end_loop_div
        slli x15, x15, 1
        li x20, 15
        sub x20, x20, x18
        sll x21, x14, x20
        bltu x13, x21, skip9_div
            sub x13, x13, x21
            ori x15, x15, 1
        skip9_div:
        addi x18, x18, 1
        j loop_div
    end_loop_div:
    
    sub x22, x6, x7
    addi x22, x22, 127
    bnez x6, skip10_div
        addi x22, x22, -1
    skip10_div:
    bnez x7, skip11_div
        addi x22, x22, 1
    skip11_div:
    
    li x16, 0x8000
    and x17, x15, x16
    beqz x17, normalize_loop_start_div
        srli x15, x15, 8
        j skip12_div
    
    normalize_loop_start_div:
    loop_2_div:
        li x16, 0x8000
        and x17, x15, x16
        bnez x17, end_loop_2_div
            li x19, 1
            ble x22, x19, end_loop_2_div
            slli x15, x15, 1
            addi x22, x22, -1
            j loop_2_div
    end_loop_2_div:
        srli x15, x15, 8
    skip12_div:
    
    andi x15, x15, 0x7F
    
    li x16, 0xFF
    blt x22, x16, skip13_div
        slli x1, x12, 15
        li x16, 0x7F80
        or x1, x1, x16
        j return_div
    skip13_div:
    
    bgtz x22, skip14_div
        slli x1, x12, 15
        j return_div
    skip14_div:
    
    slli x1, x12, 15
    andi x22, x22, 0xFF
    slli x22, x22, 7
    or x1, x1, x22
    andi x15, x15, 0x7F
    or x1, x1, x15
    j return_div

return_a_div:
    add x1, x10, x0
    j return_div

return_b_div:
    add x1, x11, x0
    j return_div

return_div:
    jr x2

