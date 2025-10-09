# Functional code all made by me (no exceptions: no line completion and no generated code) (if you find something that seems AI generated i'm may be just to inteligent or more stupid than a probabilist model, we'll never know)
# Some comments may be hard to understand due to my English, to counter that comments could have been made by Copilot

#you can run the programme and look at the memory addresses to see the results  

.data
initial_value1: .word 976
initial_value2: .word 15
initial_value3: .word 0

encode_value1: .word 0
encode_value2: .word 0
encode_value3: .word 0 

decode_value1: .word 0
decode_value2: .word 0
decode_value3: .word 0

# Messages for test output
msg_test1: .string "Test 1 (976): "
msg_test2: .string "Test 2 (15): "
msg_test3: .string "Test 3 (0): "
msg_pass: .string "PASS\n"
msg_fail: .string "FAIL\n"
msg_all_pass: .string "\nAll tests PASSED!\n"
msg_final_fail: .string "\nSome tests FAILED!\n"

# Test validation
test_results: .word 0, 0, 0      # 1 = pass, 0 = fail for each test

# List of registers used:
# x1: input value / input addresses
# x2: result 
# x3 - x19: working registers
# x20: ra (return value for jal)
# x21: sp (stack pointer)

# explanation will only be provide for the first test.
.text
.global main

main:
    li x21, 0x10000                         # init stack pointer
    
    # Test 1: encode 1000
    la a0, msg_test1
    li a7, 4
    ecall
    la x1, initial_value1                   # loading the address           
    lw x1, 0(x1)                            # loading the value
    mv x19, x1
    jal x20, encode_uf8                     # call encode function
    la x10, encode_value1                   # loading the address to store the result
    sw x2, 0(x10)                           # storing the result
    la x1, encode_value1                    # loading the address of the encoded value
    lw x1, 0(x1)                            # loading the encoded value
    jal x20, decode_uf8                     # call decode function
    la x10, decode_value1                   # loading the address to store the result
    sw x2, 0(x10)                           # storing the result
    beq x2, x19, test1_pass
    la a0, msg_fail
    li a7, 4
    ecall
    la x10, test_results
    sw x0, 0(x10)
    j test2_start

test1_pass:

    la a0, msg_pass
    li a7, 4
    ecall
    la x10, test_results
    li x11, 1
    sw x11, 0(x10)


test2_start:

    # Test 2: encode 10000
    la a0, msg_test2
    li a7, 4
    ecall
    la x1, initial_value2
    lw x1, 0(x1)
    mv x19, x1
    jal x20, encode_uf8
    la x10, encode_value2
    sw x2, 0(x10)
    la x1, encode_value2
    lw x1, 0(x1)
    jal x20, decode_uf8
    la x10, decode_value2
    sw x2, 0(x10)
    beq x2, x19, test2_pass
    la a0, msg_fail
    li a7, 4
    ecall
    la x10, test_results
    sw x0, 4(x10)
    j test3_start

test2_pass:
    la a0, msg_pass
    li a7, 4
    ecall
    la x10, test_results
    li x11, 1
    sw x11, 4(x10)

test3_start:
    
    # Test 3: encode 100000
    la a0, msg_test3
    li a7, 4
    ecall
    la x1, initial_value3
    lw x1, 0(x1)
    mv x19, x1
    jal x20, encode_uf8
    la x10, encode_value3
    sw x2, 0(x10)
    la x1, encode_value3
    lw x1, 0(x1)
    jal x20, decode_uf8
    la x10, decode_value3
    sw x2, 0(x10)
    beq x2, x19, test3_pass
    la a0, msg_fail
    li a7, 4
    ecall
    la x10, test_results
    sw x0, 8(x10)
    j final_summary

test3_pass:
    la a0, msg_pass
    li a7, 4
    ecall
    la x10, test_results
    li x11, 1
    sw x11, 8(x10)

final_summary:
    # Check if all tests passed
    la x10, test_results                #load all the test results  
    lw x11, 0(x10)                      
    lw x12, 4(x10)
    lw x13, 8(x10)
    and x14, x11, x12                   # use and to see if all are 1
    and x14, x14, x13
    beqz x14, failed                    # if not all 1, some test failed
    la a0, msg_all_pass                 # if yes ,all passed 
    li a7, 4
    ecall
    j exit_program

failed:
    la a0, msg_final_fail
    li a7, 4
    ecall

    j exit_program


encode_uf8:
    addi x21, x21, -4
    sw x20, 0(x21)
    
    jal x20, init_registers_encode
    blt x1, x3, skip_encode
    li x3, 0

    # CLZ 
    # x3 = LZ
    # x4 = count
    # x5 = step size 
    # x6 = working value
    # x7 = temp register
    add x6, x1, x0
    loop:
        beq x5, x0, end_loop         # stop if step size is 0
        srl x7, x6, x5               # shift value right by step
        beq x7, x0, skip2            # if still zero, skip update
        sub x4, x4, x5               # reduce count by step
        addi x6, x7, 0               # update working value
    skip2:
        li x10, 1
        srl x5, x5, x10              # divide step by 2
        j loop
    end_loop:

    # msb
    sub x3, x4, x6
    li x4, 31
    sub x4, x4, x3

    # x3 = lz
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
    li x14, 4                        # used for final shift
    li x15, 15                       # max exponent

    blt x4, x11, skip3               # if msb < 5, skip
        sub x5, x4, x12              # exponent = msb - 4
        blt x5, x13, skip4           # if exponent < 16, continue
            li x5, 15                # else clamp exponent to 15
    skip4:

    # Build overflow 
    loop3:
        bge x7, x5, loop3_end
        sll x6, x6, x10
        addi x6, x6, 16
        addi x7, x7, 1
        j loop3
    loop3_end:

    # Adjust overflow 
    loop4:
        blt x5, x10, loop4_end       # stop if exponent < 1
        blt x6, x1, loop4_end        # stop if overflow < value
        beq x6, x1, loop4_end        # stop if overflow == value
        addi x6, x6, -16             # decrease overflow
        srl x6, x6, x10              # divide by 2
        addi x5, x5, -1              # reduce exponent
        j loop4
    loop4_end:

    skip3:
    li x7, 0
    
    # overflow expansion loop
    loop5:
        bge x5, x15, loop5_end       # stop if exponent = 15
        sll x7, x6, x10
        addi x7, x7, 16
        bge x7, x1, loop5_end        # stop if new overflow >= value
        addi x6, x7, 0               # update overflow
        addi x5, x5, 1               # increase exponent
        j loop5
    loop5_end:

    # Mantissa part
    li x7, 0
    sub x7, x1, x6                   # value - overflow
    srl x7, x7, x5                   # scale by exponent
    sll x2, x5, x14                  # put exponent in high bits
    or x2, x2, x7                    # combine exponent + mantissa

    j encode_return
    
init_registers_encode:
    li x2, 0                         # return value
    li x3, 16                        # comparison value
    li x4, 32                        # counter for CLZ
    li x5, 16                        # step size for CLZ
    jr x20

skip_encode:
    add x2, x0, x1                   # if value < 16, just return value
    j encode_return

encode_return:
    lw x20, 0(x21)
    addi x21, x21, 4
    jr x20
 
decode_uf8:
    addi x21, x21, -4
    sw x20, 0(x21)
    
    jal x20, init_decode           # init
    and x3, x1, x6                 # mantissa calculation
    srl x4, x1, x7                 # exponent calculation 
    sub x5, x8, x4                 # offset calculation
    srl x5, x9, x5                 # offset
    sll x5, x5, x7 
    sll x2, x3, x4                 # decode uf8 result
    add x2, x2, x5
    j return_decode

init_decode:                   
    li x2, 0                       # return value
    li x3, 0                       # mantissa
    li x4, 0                       # exponent
    li x5, 0                       # offset 
    li x6, 0x0F                    # cst
    li x7, 4                       # cst
    li x8, 15                      # cst
    li x9, 0x7FFF                  # cst
    jr x20

return_decode:
    lw x20, 0(x21)
    addi x21, x21, 4
    jr x20

exit_program:
    li a7, 10                        # exit
    ecall