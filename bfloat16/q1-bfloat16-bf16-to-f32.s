# Functional code all made by me (no exceptions: no line completion and no generated code) (if you find something that seems AI generated i'm may be just to inteligent or more stupid than a probabilist model, we'll never know)
# Some comments may be hard to understand due to my English, to counter that comments could have been made by Copilot

#you can run the programme and look at the memory addresses to see the results  

.data
bfloat16: .word 0
float32:  .word 0

# List of registers used:
# x1: input value / input addresses
# x2: ra 
# x3: sp


.text
.global main

main: 

f32_to_bf16:
    la x1, bfloat16
    lh x1, 0(x1)            # load the bfloat16 value
    slli x4, x1, 16         # shift left to position as float32

return_f32:
    la x7, float32
    sw x4, 0(x7)            # store the float32 value
    j end 

end: 
    li a7, 10               # exit syscall
    ecall    