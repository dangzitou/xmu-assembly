; -------------------------------------------------------------
; 程序名称: SCREEN BOUNCE (屏幕反弹球) - 完整段定义版
; 编译环境: MASM 5.0 / 6.11
; -------------------------------------------------------------

; --- 堆栈段定义 ---
STACK SEGMENT STACK
          DB 256 DUP(0)    ; 分配 256 字节的堆栈空间
STACK ENDS

; --- 数据段定义 ---
DATA SEGMENT
    ROW     DB 12     ; 初始行 (0-24)
    COL     DB 40     ; 初始列 (0-79)
    D_ROW   DB 1      ; 行移动方向 (1:下, -1:上)
    D_COL   DB 1      ; 列移动方向 (1:右, -1:左)
    CHAR    DB 'O'    ; 要显示的字符
    COLOR   DB 0AH    ; 字符属性 (0A = 亮绿色)
    
    OLD_ROW DB ?      ; 用于清除上一次的位置
    OLD_COL DB ?
DATA ENDS

; --- 代码段定义 ---
CODE SEGMENT
                 ASSUME CS:CODE, DS:DATA, SS:STACK, ES:NOTHING

MAIN PROC FAR
    ; --- 初始化数据段 ---
                 MOV    AX, DATA
                 MOV    DS, AX

    ; --- 初始化显存段 (ES 指向 B800H) ---
                 MOV    AX, 0B800H
                 MOV    ES, AX

    ; --- 清屏 ---
                 CALL   CLEAR_SCREEN

    MAIN_LOOP:   
    ; 1. 保存当前位置到 OLD_ROW/COL
                 MOV    AL, ROW
                 MOV    OLD_ROW, AL
                 MOV    AL, COL
                 MOV    OLD_COL, AL

    ; 2. 更新坐标 (ROW = ROW + D_ROW)
                 MOV    AL, ROW
                 ADD    AL, D_ROW
                 MOV    ROW, AL

    ; 3. 更新坐标 (COL = COL + D_COL)
                 MOV    AL, COL
                 ADD    AL, D_COL
                 MOV    COL, AL

    ; 4. 边界检测与反弹处理
    ; --- 检查 Y 轴 (行) ---
                 CMP    ROW, 0                                    ; 是否撞到底部?
                 JLE    REVERSE_Y
                 CMP    ROW, 24                                   ; 是否撞到顶部?
                 JGE    REVERSE_Y
                 JMP    CHECK_X

    REVERSE_Y:   
                 NEG    D_ROW                                     ; 取反方向
                 MOV    AL, ROW
                 ADD    AL, D_ROW                                 ; 修正位置
                 MOV    ROW, AL

    CHECK_X:     
    ; --- 检查 X 轴 (列) ---
                 CMP    COL, 0                                    ; 是否撞到左边?
                 JLE    REVERSE_X
                 CMP    COL, 79                                   ; 是否撞到右边?
                 JGE    REVERSE_X
                 JMP    DRAW_STEP

    REVERSE_X:   
                 NEG    D_COL                                     ; 取反方向
                 MOV    AL, COL
                 ADD    AL, D_COL                                 ; 修正位置
                 MOV    COL, AL

    DRAW_STEP:   
    ; 5. 清除旧字符
                 MOV    DH, OLD_ROW
                 MOV    DL, OLD_COL
                 CALL   CALC_OFFSET
                 MOV    BYTE PTR ES:[DI], ' '                     ; 写入空格
                 MOV    BYTE PTR ES:[DI+1], 07H                   ; 恢复属性

    ; 6. 绘制新字符
                 MOV    DH, ROW
                 MOV    DL, COL
                 CALL   CALC_OFFSET
                 MOV    AL, CHAR
                 MOV    ES:[DI], AL                               ; 写入字符
                 MOV    AL, COLOR
                 MOV    ES:[DI+1], AL                             ; 写入颜色

    ; 7. 延时
                 CALL   DELAY

    ; 8. 检测键盘输入
                 MOV    AH, 01H                                   ; 检查键盘缓冲区
                 INT    16H
                 JNZ    HAS_KEY                                   ; 有按键则跳转
                 JMP    MAIN_LOOP                                 ; 无按键继续循环

    HAS_KEY:     
                 MOV    AH, 00H                                   ; 读取按键
                 INT    16H
                 CMP    AL, 27                                    ; ESC 键?
                 JE     EXIT_PROG
                 JMP    MAIN_LOOP

    EXIT_PROG:   
                 MOV    AH, 4CH                                   ; 返回 DOS
                 INT    21H
MAIN ENDP

    ; ------------------------------------------------
    ; 子程序: CALC_OFFSET
    ; ------------------------------------------------
CALC_OFFSET PROC NEAR
                 PUSH   AX
                 PUSH   BX
    
                 XOR    AX, AX
                 MOV    AL, DH                                    ; AX = 行
                 MOV    BL, 80
                 MUL    BL                                        ; AX = 行 * 80
    
                 XOR    BX, BX
                 MOV    BL, DL                                    ; BX = 列
                 ADD    AX, BX                                    ; AX = 行*80 + 列
    
                 SHL    AX, 1                                     ; AX * 2
                 MOV    DI, AX
    
                 POP    BX
                 POP    AX
                 RET
CALC_OFFSET ENDP

    ; ------------------------------------------------
    ; 子程序: DELAY
    ; ------------------------------------------------
DELAY PROC NEAR
                 PUSH   CX
                 PUSH   DX
                 MOV    CX, 0FFFFH
    D1:          
                 MOV    DX, 0010H
    D2:          
                 DEC    DX
                 JNZ    D2
                 LOOP   D1
                 POP    DX
                 POP    CX
                 RET
DELAY ENDP

    ; ------------------------------------------------
    ; 子程序: CLEAR_SCREEN
    ; ------------------------------------------------
CLEAR_SCREEN PROC NEAR
                 MOV    AX, 0600H
                 MOV    BH, 07H
                 MOV    CX, 0000H
                 MOV    DX, 184FH
                 INT    10H
                 RET
CLEAR_SCREEN ENDP

CODE ENDS
    END MAIN