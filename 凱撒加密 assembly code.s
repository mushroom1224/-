.globl __start

.rodata
    msg0: .string "This is HW1-2: \n"
    msg1: .string "Enter shift: "
    msg2: .string "Plaintext: "
    msg3: .string "Ciphertext: "
.text

################################################################################
  # print_char function
  # Usage: 
  #     1. Store the beginning address in x20
  #     2. Use "j print_char"
  #     The function will print the string stored from x20 
  #     When finish, the whole program with return value 0
print_char:
    addi a0, x0, 4
    la a1, msg3
    ecall
  
    add a1,x0,x20
    ecall

  # Ends the program with status code 0
    addi a0,x0,10
    ecall
    
################################################################################

__start:
  # Prints msg
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
    add a6, a0, x0
    
  # Prints msg2
    addi a0, x0, 4
    la a1, msg2
    ecall
    
    addi a0,x0,8
    li a1, 0x10150
    addi a2,x0,2047
    ecall
  # Load address of the input string into a0
    add a0,x0,a1


################################################################################ 
  # Write your main function here. 
  # a0 stores the begining Plaintext
  # x16 stores the shift
  # Do store 66048(0x10200) into x20 
  # ex. j print_char   
main: 
    addi sp,sp,-8 #sp清空2個位置
    sw x1,0(sp) #存ra
    addi x28,x0,0 #給定填入輸入與輸出array的byte數(位置)
    addi x29,x0,0 #若輸入為空格，要輸出的數字(initial為0)
    addi x19,x0,10 #給定常數方便後面計算
    addi x31,x0,26 #同上
    li x20,66048 #將66048存在x20(66048太大了不能用addi)
    
judge:
    add x5,x28,x10 #x5=addr of input
    add x18,x28,x20 #x18=addr of output
    lbu x6,0(x5) #叫出對應輸入字串特定位置的數字 
    beq x6,x19,end #如果輸入遇到\n就跳end準備收尾
    addi x30,x6,-32 #反之則將輸入的值-32
    beq x30,x0,space #如果x30為0表示x6為32(亦即輸入為空格，要跳去遇到空格的處理)
    addi x22,x6,-97 #如果x30不為0表示輸入既非空格也非\n，以字母來處理
    #先將輸入的值-97，使得輸入的值落在0~25的範圍方便取餘(a~z本來是97~122，同減97得到0~25)
    add x22,x22,x16 #將輸入的值+給定的shift
    bge x22,x0,positive #如果+shift後為正，跳positive，直接取餘
    add x22,x22,x31 #+shift後為負，先+26使其為正，也使取餘26的值不變
    rem x22,x22,x31 #取餘26得到輸入值移動後的輸出值(同樣落在0~25)
    addi x22,x22,97 #+97回去恢復成ASCII實際上對應的a~z(97~122)
    sb x22,0(x18) #把處理好的值存回輸出字串
    addi x28,x28,1 #填入輸入與輸出array的byte數(位置)+1，以進行下一輪
    jal x0,judge #跳回judge再判別下一個輸入值

positive:
    rem x22,x22,x31 #+shift後為正，直接取餘26
    addi x22,x22,97 #同上，恢復成ASCII實際上對應的a~z(97~122)
    sb x22,0(x18) #把處理好的值存回輸出字串
    addi x28,x28,1 #填入輸入與輸出array的byte數(位置)+1，以進行下一輪
    jal x0,judge #跳回judge再判別下一個輸入值 
      
space: 
    addi x7,x6,16 #如果輸入為空格，則此時x6=32，要印出代表0的48，所以把x6+16
    add x7,x7,x29 #加上要輸出的數字(initial為x6+16+0=48) 
    sb x7,0(x18) #把處理好的值存回輸出字串
    addi x28,x28,1 #填入輸入與輸出array的byte數(位置)+1，以進行下一輪
    addi x29,x29,1 #下次遇到空格要輸出1，因此調整x7的參數x29必須+1備用，後續以此類推
    jal x0,judge #跳回judge再判別下一個輸入值
  
end:
    j print_char #跳到print_char輸出字串
    jalr x0,0(x1) #return
################################################################################

