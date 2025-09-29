.data
result: .word 0     

.text
.global main

main:
    jal x20, init                  # init
    and x3, x1, x6                 # mantissa calculation
    srl x4, x1, x7                 # exponent calculation 
    li x6, 15            
    sub x5, x6, x4                 # offset calculation
    li x6, 0x7FFF                   
    srl x5, x6, x5                 
    sll x5, x5, x7 
    sll x2, x3, x4                 # decode uf8 result
    add x2, x2, x5
    j return


init:
    li x1, 0x96                   # value to decode
    li x2, 0                       # return value
    li x3, 0                       # mantissa
    li x4, 0                       # exponent
    li x5, 0                       # offset 
    li x6, 0x0F                    # temp value 1
    li x7, 4                       # temp value 2
    jr x20



return:
    la x10, result                 # load address of result
    sw x2, 0(x10)                  # store encoded value
    li a7, 10                      # exit
    ecall
