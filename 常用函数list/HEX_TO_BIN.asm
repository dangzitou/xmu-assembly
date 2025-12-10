; 进制转换补充板子
; 包含: 16进制字符串转数值

    ; ==========================================
    ; 函数: HEX_STR_TO_WORD
    ; 功能: 将4位16进制字符串转为数值
    ; 输入: DS:SI 指向字符串 (例如 "1A2B")
    ; 输出: AX = 数值 (例如 1A2BH), CF=1 表示出错
    ; ==========================================
HEX_STR_TO_WORD PROC NEAR
                    PUSH   BX
                    PUSH   CX
                    PUSH   DX
                    PUSH   SI

                    XOR    BX, BX          ; BX 用于累加结果
                    MOV    CX, 4           ; 处理4个字符

    HEX_LOOP:       
                    MOV    AL, [SI]
    
    ; 转换字符 '0'-'9', 'A'-'F', 'A'-'F' 到数值
                    CMP    AL, '0'
                    JB     HEX_ERROR
                    CMP    AL, '9'
                    JBE    IS_DIGIT
    
                    CMP    AL, 'A'
                    JB     HEX_ERROR
                    CMP    AL, 'F'
                    JBE    IS_UPPER
    
                    CMP    AL, 'A'
                    JB     HEX_ERROR
                    CMP    AL, 'F'
                    JBE    IS_LOWER
    
                    JMP    HEX_ERROR

    IS_DIGIT:       
                    SUB    AL, '0'
                    JMP    ADD_VAL
    IS_UPPER:       
                    SUB    AL, 'A' - 10
                    JMP    ADD_VAL
    IS_LOWER:       
                    SUB    AL, 'A' - 10
                    JMP    ADD_VAL

    ADD_VAL:        
    ; BX = BX * 16 + AL
                    SHL    BX, 1
                    SHL    BX, 1
                    SHL    BX, 1
                    SHL    BX, 1
                    XOR    AH, AH
                    ADD    BX, AX
    
                    INC    SI
                    LOOP   HEX_LOOP

                    MOV    AX, BX          ; 结果存入 AX
                    CLC                    ; 清除进位标志，表示成功
                    JMP    HEX_EXIT

    HEX_ERROR:      
                    STC                    ; 设置进位标志，表示错误

    HEX_EXIT:       
                    POP    SI
                    POP    DX
                    POP    CX
                    POP    BX
                    RET
HEX_STR_TO_WORD ENDP
