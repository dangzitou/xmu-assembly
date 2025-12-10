; -------------------------------------------------------------
; 程序名称: Screen Bounce (屏幕反弹球)
; 编译环境: MASM 5.0 / 6.11 (在 DOSBox 下运行)
; 功能: 在屏幕上显示一个字符 'O'，碰到边缘反弹，按 ESC 退出
; -------------------------------------------------------------

.MODEL SMALL
.STACK 100H

.DATA
    row      DB 12      ; 初始行 (0-24)
    col      DB 40      ; 初始列 (0-79)
    d_row    DB 1       ; 行移动方向 (1:下, -1:上) - 也就是补码的FF
    d_col    DB 1       ; 列移动方向 (1:右, -1:左)
    char     DB 'O'     ; 要显示的字符
    color    DB 0Ah     ; 字符属性 (0A = 亮绿色)
    
    old_row  DB ?       ; 用于清除上一次的位置
    old_col  DB ?

.CODE
MAIN PROC
    ; --- 初始化数据段 ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- 初始化显存段 (ES 指向 B800H) ---
    MOV AX, 0B800H
    MOV ES, AX

    ; --- 清屏 (可选，为了看清效果) ---
    CALL CLEAR_SCREEN

MAIN_LOOP:
    ; 1. 保存当前位置到 old_row/col，以便稍后清除
    MOV AL, row
    MOV old_row, AL
    MOV AL, col
    MOV old_col, AL

    ; 2. 更新坐标 (row = row + d_row)
    MOV AL, row
    ADD AL, d_row
    MOV row, AL

    ; 3. 更新坐标 (col = col + d_col)
    MOV AL, col
    ADD AL, d_col
    MOV col, AL

    ; 4. 边界检测与反弹处理
    ; --- 检查 Y 轴 (行) ---
    CMP row, 0          ; 是否撞到底部(上边缘)?
    JLE REVERSE_Y       ; 如果 <= 0，反转
    CMP row, 24         ; 是否撞到顶部(下边缘)?
    JGE REVERSE_Y       ; 如果 >= 24，反转
    JMP CHECK_X         ; 没撞墙，去检查X轴

REVERSE_Y:
    NEG d_row           ; 取反方向 (1变-1，-1变1)
    ; 修正位置防止卡在墙里
    MOV AL, row
    ADD AL, d_row       ; 立即弹回一步
    MOV row, AL

CHECK_X:
    ; --- 检查 X 轴 (列) ---
    CMP col, 0          ; 是否撞到左边?
    JLE REVERSE_X
    CMP col, 79         ; 是否撞到右边?
    JGE REVERSE_X
    JMP DRAW_STEP

REVERSE_X:
    NEG d_col           ; 取反方向
    ; 修正位置
    MOV AL, col
    ADD AL, d_col
    MOV col, AL

DRAW_STEP:
    ; 5. 清除旧字符 (在 old_row, old_col 处写空格)
    MOV DH, old_row
    MOV DL, old_col
    CALL CALC_OFFSET    ; 计算偏移量到 DI
    MOV BYTE PTR ES:[DI], ' '   ; 写入空格 ASCII
    MOV BYTE PTR ES:[DI+1], 07h ; 恢复默认黑底白字

    ; 6. 绘制新字符 (在 row, col 处写字符)
    MOV DH, row
    MOV DL, col
    CALL CALC_OFFSET    ; 计算偏移量到 DI
    MOV AL, char
    MOV ES:[DI], AL     ; 写入字符
    MOV AL, color
    MOV ES:[DI+1], AL   ; 写入颜色

    ; 7. 延时 (否则速度太快看不清)
    CALL DELAY

    ; 8. 检测键盘输入 (按 ESC 退出)
    MOV AH, 01H         ; 检查键盘缓冲区
    INT 16H
    
    ; === 修改开始 ===
    JNZ HAS_KEY         ; 如果标志位 Z=0 (有按键)，跳转到处理部分
    JMP MAIN_LOOP       ; 如果 Z=1 (没按键)，用 JMP 跳回开头 (JMP支持长距离跳转)

HAS_KEY:
    ; 如果有按键，读取它
    MOV AH, 00H
    INT 16H
    CMP AL, 27          ; 27 是 ESC 的 ASCII 码
    JE  EXIT_PROG       ; 如果是 ESC，退出
    JMP MAIN_LOOP       ; 如果是其他键，忽略并继续循环
    ; === 修改结束 ===

EXIT_PROG:
    MOV AH, 4CH         ; DOS 退出功能调用
    INT 21H
MAIN ENDP

; ------------------------------------------------
; 子程序: CALC_OFFSET
; 功能: 根据 DH(行) 和 DL(列) 计算显存偏移量 DI
; 公式: Offset = (Row * 80 + Col) * 2
; ------------------------------------------------
CALC_OFFSET PROC
    PUSH AX
    PUSH BX
    
    XOR AX, AX
    MOV AL, DH          ; AX = 行
    MOV BL, 80
    MUL BL              ; AX = 行 * 80
    
    XOR BX, BX
    MOV BL, DL          ; BX = 列
    ADD AX, BX          ; AX = 行*80 + 列
    
    SHL AX, 1           ; AX = AX * 2 (每个字符2字节)
    MOV DI, AX          ; 结果存入 DI
    
    POP BX
    POP AX
    RET
CALC_OFFSET ENDP

; ------------------------------------------------
; 子程序: DELAY
; 功能: 空循环延时
; 注意: 在现在的 DOSBox 中，循环次数需要设得很大
; ------------------------------------------------
DELAY PROC
    PUSH CX
    PUSH DX
    MOV CX, 0FFFFH      ; 外层循环
D1: 
    MOV DX, 0010H       ; 内层循环 (根据机器速度调整这里)
D2: 
    DEC DX
    JNZ D2
    LOOP D1
    POP DX
    POP CX
    RET
DELAY ENDP

; ------------------------------------------------
; 子程序: CLEAR_SCREEN
; 功能: 利用 BIOS 中断清屏
; ------------------------------------------------
CLEAR_SCREEN PROC
    MOV AX, 0600H       ; AH=06(滚动), AL=00(全屏)
    MOV BH, 07H         ; 属性: 黑底白字
    MOV CX, 0000H       ; 左上角 (0,0)
    MOV DX, 184FH       ; 右下角 (24,79) hex: 18=24, 4F=79
    INT 10H
    RET
CLEAR_SCREEN ENDP

END MAIN