# Functional code all made by me (no exceptions: no line completion and no generated code) (if you find something that seems AI generated i'm may be just to inteligent or more stupid than a probabilist model, we'll never know)
# Some comments may be hard to understand due to my English, to counter that comments could have been made by Copilot

#you can run the programme and look at the memory addresses to see the results  

.data
bfloat32: .word 0
bfloat16: .word 0

# List of registers used:
# x1: input value / input addresses
# x2: ra 
# x3: sp

.text
.global main

main: 


f32_to_bf16:
    la x1, bfloat32
    lw x1, 0(x1)            # load the bfloat32 value
    srli x4, x1, 23         # shift right to get exponent
    andi x4, x4, 0x7FF      # isolate exponent
    li x5, 0xFF
    bne x4, x5, normal_case
        srli x6, x1, 16         # shift right to get bfloat16
        andi x6, x6, 0xFFFF      # mask to get lower 16 bits
        j return_bf16
    
    normal_case:
        srli x6, x1, 16          # shift right to get bfloat16
        andi x6, x6, 1      # mask to get lower 16 bits
        addi x6, x6, 0x7FFF          # round up if necessary
        add x6, x1, x6
        srli x6, x6, 16         # shift right to get bfloat16


return_bf16:
    la x7, bfloat16
    sh x6, 0(x7)            # store the bfloat16 value
    j end 

end: 
    li a0, 10               # exit syscall
    ecall    