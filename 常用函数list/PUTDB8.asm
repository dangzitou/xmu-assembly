    ; ==========================================
    ; 函数: PUTDB8
    ; 功能: 将AL中的8位二进制数以16进制形式打印
    ; 输入: AL (8位数值)
    ; 输出: 无 (打印2位16进制字符)
    ; ==========================================
PUTDB8 PROC
             PUSH   BX
             PUSH   CX
             PUSH   DX
             PUSH   AX

             MOV    BL, AL                     ; 将AL移入BL
             MOV    BH, AL                     ; 备份到BH (其实只需要BL)
             MOV    CH, 02H                    ; 设置循环计数器
    ;转化为16进制的ASCII码
    SWITCH:  
             MOV    CL, 4H
             ROL    BL, CL                     ; 循环左移4位 (处理BL)
             MOV    AL, BL                     ; 取BL的低8位
             AND    AL, 0FH                    ; 清除AL的高4位
             ADD    AL, 30H                    ; 加上"0"的ASCII码
             CMP    AL, 39H                    ; 将AL的值与"9"的ASCII码比较
             JLE    PRINT
             ADD    AL, 07H                    ; 若大于9，则+7，转到A~F
      
    ;输出
    PRINT:   
             MOV    DX, 00H
             MOV    DL, AL
             PUSH   DX
             CALL   PUTC
             ADD    SP, 2

             DEC    CH
             JNZ    SWITCH                     ; 如果循环计数器不为0，则跳转到SWITCH
             
             POP    AX
             POP    DX
             POP    CX
             POP    BX
             RET

PUTDB8 ENDP