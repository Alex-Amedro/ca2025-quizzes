# Functional code all made by me (no exceptions: no line completion and no generated code)
# Some comments may be hard to understand due to my English, to counter that comments could have been made by Copilot
.data
result1: .word 0
result2: .word 0
result3: .word 0  

.text
.global main

main:
    # Test 1: decode 0x5f ~ 1 000
    li x1, 0x5f
    jal x20, decode_uf8
    la x10, result1
    sw x2, 0(x10)
    
    # Test 2: decode 0x93 ~ 10 000
    li x1, 0x93
    jal x20, decode_uf8
    la x10, result2
    sw x2, 0(x10)
    
    # Test 3: decode 0xc8 ~ 100 000
    li x1, 0xc8
    jal x20, decode_uf8
    la x10, result3
    sw x2, 0(x10)
    
    j exit_program

decode_uf8:
    # sauvegarde x20
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
    li a7, 10                      # exit
    ecall