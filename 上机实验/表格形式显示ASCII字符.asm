; 实验 2.1: 用表格形式显示 ASCII 字符
; 功能: 以 15x16 的表格显示 10H 到 FFH 的所有 ASCII 字符

STACKSG SEGMENT STACK 'STACK'
    DB 200 DUP(?)       ; 定义一个 200 字节的堆栈段，防止链接时出现警告
STACKSG ENDS

CODESG  SEGMENT
    ASSUME CS:CODESG, SS:STACKSG

; 定义几个常量，让代码更易读
SPACE   EQU 20H         ; 定义空格的 ASCII 码 (实验要求中的 00H 是 NULL, 不会显示，20H 才是空格)
CR      EQU 0DH         ; 定义回车的 ASCII 码
LF      EQU 0AH         ; 定义换行的 ASCII 码

MAIN    PROC FAR        ; 主过程定义
START:
    ; 初始化要显示的第一个字符
    MOV DX, 10H         ; 将 DL 初始化为 10H，DL 用于存放当前要显示的字符 ASCII 码

    ; 外层循环控制行数，共 15 行
    MOV CH, 15          ; 使用 CH 作为外层循环计数器
ROW_LOOP:
    ; 内层循环控制列数，每行 16 个字符
    MOV CL, 16          ; 使用 CL 作为内层循环计数器
COL_LOOP:
    ; --- 核心显示逻辑 ---
    ; 1. 显示当前字符
    MOV AH, 02H         ; 使用 2 号功能调用，显示 DL 中的字符
    INT 21H             ; 执行 DOS 中断

    ; 2. 准备显示分隔符（空格）前，保护 DX 寄存器
    PUSH DX             ; 将 DX (包含当前字符) 压入堆栈

    ; 3. 显示空格
    MOV DL, SPACE       ; 将空格的 ASCII 码放入 DL
    MOV AH, 02H         ; 同样使用 2 号功能调用
    INT 21H

    ; 4. 恢复 DX 寄存器
    POP DX              ; 从堆栈中弹出之前保存的 DX，DL 恢复为原来的字符

    ; 5. 准备下一个字符
    INC DL              ; 将 DL 加 1，指向下一个 ASCII 码

    DEC CL              ; 内层循环计数器减 1
    JNZ COL_LOOP        ; 如果 CL 不为零，则继续循环打印本行的下一个字符

    ; --- 一行显示完毕，准备换行 ---
    ; 换行操作同样需要使用 DL, 所以依然要先保护再恢复 DX
    PUSH DX             ; 保护下一行要显示的第一个字符

    ; 显示回车 (CR)
    MOV DL, CR
    MOV AH, 02H
    INT 21H

    ; 显示换行 (LF)
    MOV DL, LF
    MOV AH, 02H
    INT 21H

    POP DX              ; 恢复下一行要显示的第一个字符

    DEC CH              ; 外层循环计数器减 1
    JNZ ROW_LOOP        ; 如果 CH 不为零，则继续循环打印下一行

EXIT:
    ; 程序结束，返回 DOS
    MOV AH, 4CH         ; 使用 4CH 功能调用
    INT 21H

MAIN    ENDP
CODESG  ENDS
    END START