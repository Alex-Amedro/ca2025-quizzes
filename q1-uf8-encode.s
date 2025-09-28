.data
result: .word 0 #zone for result
.text
.global main


main : 
    jal ra, init

    blt x1, x3, skip_encode
    li x3, 0 

    #x3 = CLZ result , x4 = n , x5 = c , x6 = x , x7 = y
    add x6, x1, x0 
    loop : beq x5, x0, end_loop
        srl x7, x6, x5
        beq x7, x0, skip2
        sub x4, x4, x5
        addi x6, x7, 0 

        skip2:
            srl x5, x5, 1

        j loop 

    end_loop:

    sub x3, x4, x6
    li x4, 31
    sub x4, x4, x3

    # x3 = lz , x4 = msb , x5 = exponent , x6 = overflow , x7 = loop index
    li x5, 0
    li x6, 0
    li x7, 0
    blt x4, 5 ,skip3
        sub x5, x4, 4 
        blt x5, 16, skip4
            li x5, 15 

        skip4:

        loop3 : 
        bge x7, x5,loop3_end
            sll x6, x6, 1
            addi x6, x6, 16
            addi x7, x7, 1
            j loop3
        loop3_end

        loop4 :
        blt x5, 1, loop4_end
            blt x6, x1, loop4_end
                beq x6, x1, loop4_end
                    addi x6, x6, -16
                    srl x6, x6, 1 
                    addi x5, x5, -1
                    j loop4 
        loop4_end
        skip3:
        li x7, 0
        # x5 = exponent , x6 = overflow , x7 = next_overflow

        loop5 : 
        bge x5, 15, loop5_end 
            sll x7, x6, 1 
            addi x7, x7, 16
            bge x7, x1, loop5_end
            addi x6, x7, 0 
            addi x5, x5, 1 
        loop5_end

        li x7, 0 
        # x5 = exponent , x6 = overflow , x7 = mantissa 
        sub x7, x1, x6 
        srl x7, x7, x5
        sll x2, x5,4
        or x2, x2, x7

    j return 

init : 
    li x1, 50 #value to encode
    li x2, 0 #return value
    li x3, 16 # comparaison value
    li x4, 32 # n for clz
    li x5, 16 # c for clz
    jr ra

skip_encode : 
    add x2, x0, x1
    j return

return :
    la x10, result #load address of result
    sw x2, 0(x10) #store result
    li a7, 10 # ecall for exit
    ecall 