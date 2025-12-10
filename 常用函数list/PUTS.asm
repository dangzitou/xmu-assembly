    ; ==========================================
    ; 函数: PUTS
    ; 功能: 打印栈内指向的以 '$' 结尾的字符串
    ; 输入: 栈参数 [BP+4] (字符串偏移地址 DX)
    ; 输出: 无 (打印字符串)
    ; ==========================================
PUTS PROC
             PUSH   BP
             MOV    BP,SP
             PUSH   DX
             PUSH   AX

             MOV    DX,[BP-2]
             MOV    AH,09H                     ;输出字符串
             INT    21H

             POP    AX
             POP    DX
             POP    BP
             RET
PUTS ENDP