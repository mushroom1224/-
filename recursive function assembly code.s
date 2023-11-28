.globl __start

.rodata
    msg0: .string "This is HW1-1: T(n) = 5T(n/2) + 6n + 4, T(1) = 2\n"
    msg1: .string "Enter a number: "
    msg2: .string "The result is: "

.text


__start:
  # Prints msg0
    addi a0, x0, 4
    la a1, msg0
    ecall

  # Prints msg1
    addi a0, x0, 4
    la a1, msg1
    ecall

  # Reads an int
    addi a0, x0, 5
    ecall

################################################################################ 
  # Write your main function here. 
  # Input n is in a0. You should store the result T(n) into t0
  # HW1-1 T(n) = 5T(n/2) + 6n + 4, T(1) = 2, round down the result of division
  # ex. addi t0, a0, 1
main:
    jal L1
    addi x5,x10,0
    jal result
    
L1:
    addi sp,sp,-16 #sp清空2個位置
    sw x1,8(sp) #return
    sw x10,0(sp) #把輸入的variable(n)先存起來(每在L2處理一次就存一次)
    addi x7,x10,-2 #x7=input-2 
    bge x7,x0,L2 #if x7>=0 L2  
    addi x10,x0,2 #x7<0後，令x10=2=T(1)
    addi sp,sp,16
    jalr x0,0(x1) #跳運算(第50行)
    #jalr要有jal先把ra的值存起來 #jalr跳回jal那一行
    #j是pseudo instruction無條件跳躍
L2:
    srli x10,x10,1 #要存在memory 所以recursive特定處理後的變數要放x10
    jal x1,L1
    addi x6,x10,0 #把送過來的x10(一開始是T(1))先另外存起來避免動到
    lw x10,0(sp) #輪流叫出第39行存好的那些n
    lw x1,8(sp)
    addi sp,sp,16
    addi x29,x0,5 #給定係數方便計算
    addi x30,x0,6 #同上
    mul x6,x6,x29 #把前一輪的運算結果(T[.])乘以5
    mul x10,x10,x30 #把存好的variable(n)乘以6
    add x10,x10,x6 #把上面兩個運算結果加起來
    addi x10,x10,4 #最後+4
    jalr x0,0(x1) #跳回第50行，把第59行的運算結果存起來
################################################################################

result:
  # Prints msg2
    addi a0, x0, 4
    la a1, msg2
    ecall

  # Prints the result in t0
    addi a0, x0, 1
    add a1, x0, t0
    ecall
    
  # Ends the program with status code 0
    addi a0, x0, 10
    ecall
