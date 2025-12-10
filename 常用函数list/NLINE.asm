    ; ==========================================
    ; 函数: NLINE
    ; 功能: 输出换行符 (CR + LF)
    ; 输入: 无
    ; 输出: 无 (打印换行)
    ; ==========================================
NLINE PROC
             PUSH   BP
             MOV    BP,SP
             PUSH   DX

             MOV    DX,0DH
             PUSH   DX
             CALL   PUTC
             ADD    SP,2

             MOV    DX,0AH
             PUSH   DX
             CALL   PUTC
             ADD    SP,2

             POP    DX
             POP    BP
             RET
NLINE ENDP