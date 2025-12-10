    ; ==========================================
    ; 函数: GETS
    ; 功能: 从键盘读入一个字符串到指定缓冲区
    ; 输入: 栈参数 [BP+4] (缓冲区首地址 DX) 注意: 这里的BP-2是基于push bp后的偏移，实际调用时应push dx
    ; 输出: 缓冲区被填充
    ; ==========================================
GETS PROC
             PUSH   BP
             MOV    BP,SP
             PUSH   DX
             PUSH   AX

             MOV    DX,[BP-2]
             MOV    AH,0AH                     ;接受输入字符串
             INT    21H

             POP    AX
             POP    DX
             POP    BP
             RET
GETS ENDP