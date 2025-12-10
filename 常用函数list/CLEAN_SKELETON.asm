STACK SEGMENT
            DB 256 DUP(0)
STACK ENDS

DATA SEGMENT
      ; 在这里定义数据
      ; MSG DB 'HELLO, WORLD!$'
DATA ENDS

CODE SEGMENT
            ASSUME  CS:CODE, DS:DATA, SS:STACK
      START:
            MOV     AX, DATA
            MOV     DS, AX

      ; 在这里编写代码
    
      ; 退出程序
            MOV     AX, 4C00H
            INT     21H

      ; 引入所有常用函数
            INCLUDE 常用函数list\LIB.ASM

CODE ENDS
END START
