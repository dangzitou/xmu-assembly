; 十进制转十六进制板子
; 包含: 读取十进制数并输出为十六进制

    ; ==========================================
    ; 函数: DEC_TO_HEX
    ; 功能: 从键盘读取十进制数，并直接打印其十六进制表示
    ; 输入: 无 (从键盘读取)
    ; 输出: 打印十六进制数
    ; ==========================================
DEC_TO_HEX PROC NEAR
                   PUSH   AX
                   PUSH   BX
                   PUSH   CX
                   PUSH   DX

    ; 1. 读取十进制数到 BX
                   MOV    BX, 0
    READ_DEC_LOOP: 
                   MOV    AH, 1
                   INT    21H

                   CMP    AL, 0DH           ; 回车结束
                   JE     READ_DONE
                   SUB    AL, 30H
                   JL     READ_DONE         ; 非数字结束
                   CMP    AL, 9
                   JG     READ_DONE         ; 非数字结束

                   CBW
                   XCHG   AX, BX
                   MOV    CX, 10
                   MUL    CX
                   ADD    BX, AX
                   JMP    READ_DEC_LOOP

    READ_DONE:     
    ; 换行 (可选，这里为了清晰加一个换行)
                   MOV    AH, 2
                   MOV    DL, 0DH
                   INT    21H
                   MOV    DL, 0AH
                   INT    21H

    ; 2. 打印 BX 为十六进制
                   MOV    CH, 4             ; 4个十六进制位
    PRINT_HEX_LOOP:
                   MOV    CL, 4
                   ROL    BX, CL            ; 循环左移4位
                   MOV    AL, BL
                   AND    AL, 0FH           ; 取低4位
                   ADD    AL, 30H
                   CMP    AL, 39H
                   JLE    IS_DIGIT_HEX
                   ADD    AL, 7             ; 'A'-'F'
    IS_DIGIT_HEX:  
                   MOV    DL, AL
                   MOV    AH, 2
                   INT    21H
                   DEC    CH
                   JNZ    PRINT_HEX_LOOP

                   POP    DX
                   POP    CX
                   POP    BX
                   POP    AX
                   RET
DEC_TO_HEX ENDP