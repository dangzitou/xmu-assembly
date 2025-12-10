; 字符串处理板子
; 包含: 长度计算, 比较, 子串查找

    ; ==========================================
    ; 函数: STRLEN
    ; 功能: 计算以 '$' 结尾的字符串长度
    ; 输入: DS:SI 指向字符串
    ; 输出: CX = 长度
    ; ==========================================
STRLEN PROC NEAR
                     PUSH   SI
                     PUSH   AX
                     XOR    CX, CX
    STRLEN_LOOP:     
                     MOV    AL, [SI]
                     CMP    AL, '$'
                     JE     STRLEN_END
                     INC    CX
                     INC    SI
                     JMP    STRLEN_LOOP
    STRLEN_END:      
                     POP    AX
                     POP    SI
                     RET
STRLEN ENDP

    ; ==========================================
    ; 函数: STRCMP
    ; 功能: 比较两个字符串 (以 '$' 结尾)
    ; 输入: DS:SI = 字符串1, ES:DI = 字符串2
    ; 输出: ZF=1 (相等), ZF=0 (不等)
    ; ==========================================
STRCMP PROC NEAR
                     PUSH   AX
                     PUSH   SI
                     PUSH   DI
    STRCMP_LOOP:     
                     MOV    AL, [SI]
                     CMP    AL, ES:[DI]
                     JNE    STRCMP_DIFF
                     CMP    AL, '$'
                     JE     STRCMP_EQUAL
                     INC    SI
                     INC    DI
                     JMP    STRCMP_LOOP

    STRCMP_DIFF:     
    ; ZF IS ALREADY 0
                     JMP    STRCMP_EXIT

    STRCMP_EQUAL:    
                     CMP    BYTE PTR ES:[DI], '$'    ; CHECK IF BOTH ENDED
    ; IF EQUAL, ZF=1
    
    STRCMP_EXIT:     
                     POP    DI
                     POP    SI
                     POP    AX
                     RET
STRCMP ENDP

    ; ==========================================
    ; 函数: STRSTR (暴力匹配)
    ; 功能: 在主串中查找子串
    ; 输入: DS:SI = 主串 (以 '$' 结尾), DS:BX = 子串 (以 '$' 结尾)
    ; 输出: AX = 子串在主串中的偏移地址 (找到), FFFFH (未找到)
    ; ==========================================
STRSTR PROC NEAR
                     PUSH   CX
                     PUSH   SI
                     PUSH   BX
                     PUSH   DX
    
                     MOV    DX, SI                   ; 保存主串起始位置用于恢复

    STRSTR_OUTER:    
                     MOV    AL, [SI]
                     CMP    AL, '$'
                     JE     STRSTR_NOT_FOUND
    
    ; 开始尝试匹配
                     PUSH   SI                       ; 保存当前主串位置
                     PUSH   BX                       ; 保存子串起始位置
    
    STRSTR_INNER:    
                     MOV    AL, [SI]
                     MOV    AH, [BX]
                     CMP    AH, '$'                  ; 子串结束，匹配成功
                     JE     STRSTR_FOUND
                     CMP    AL, AH
                     JNE    STRSTR_NEXT              ; 字符不匹配，尝试主串下一个位置
                     CMP    AL, '$'                  ; 主串也结束了但子串没结束
                     JE     STRSTR_NEXT
    
                     INC    SI
                     INC    BX
                     JMP    STRSTR_INNER

    STRSTR_NEXT:     
                     POP    BX                       ; 恢复子串指针
                     POP    SI                       ; 恢复主串指针
                     INC    SI                       ; 主串指针后移一位
                     JMP    STRSTR_OUTER

    STRSTR_FOUND:    
                     POP    BX                       ; 清理堆栈
                     POP    AX                       ; 弹出的 SI 就是匹配的起始位置
    ; AX 已经在栈顶被弹出到 AX (其实是 POP AX 对应 PUSH SI)
    ; 等等，上面的 POP AX 是把 PUSH SI 的值弹给 AX，正是我们要的返回值
                     JMP    STRSTR_EXIT

    STRSTR_NOT_FOUND:
                     MOV    AX, 0FFFFH

    STRSTR_EXIT:     
                     POP    DX
                     POP    BX
                     POP    SI
                     POP    CX
                     RET
STRSTR ENDP
