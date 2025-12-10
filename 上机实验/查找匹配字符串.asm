DGROUP GROUP DATA

DATA SEGMENT
    ; --- 提示信息 ---
    MSG_KEY         DB 'Enter keyword: $'
    MSG_SNT         DB 13, 10, 'Enter sentence: $'
    MSG_MATCH_PRE   DB 13, 10, 'Match at location: $'
    MSG_MATCH_POST  DB ' H of the sentence.$'
    MSG_NOMATCH     DB 13, 10, 'No match!$'

    ; --- 输入缓冲区 ---
    KBD_BUF     DB 81        
                DB ?         
                DB 81 DUP(?) 

    SNT_BUF     DB 255       
                DB ?         
                DB 255 DUP(?)

DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DGROUP, ES:DGROUP

; -----------------------------------------------------------------
; 过程名：PRINT_HEX
; 功能  ：以十六进制打印 AX 寄存器中的无符号数
; -----------------------------------------------------------------
PRINT_HEX PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP AX, 0
    JNE NON_ZERO
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    JMP HEX_EXIT

NON_ZERO:
    MOV BL, 4           ; BL = 4 (循环计数器)
    MOV BH, 1           ; BH = 1 (前导零标志)

HEX_LOOP:
    MOV CL, 4           ; 设置 ROL 的循环位数
    ROL AX, CL          ; 将高 4 位转到低 4 位

    MOV DL, AL
    AND DL, 0FH         ; 仅保留这 4 位

    CMP BH, 1           ; 检查是否还在处理前导零?
    JE CHECK_LEADING_ZERO

PRINT_NIBBLE:
    CMP DL, 9
    JBE IS_DIGIT
    ADD DL, 'A' - 10    ; 转换为 'A'-'F'
    JMP DO_PRINT
IS_DIGIT:
    ADD DL, '0'         ; 转换为 '0'-'9'

; --- 修正点 ---
DO_PRINT:
    PUSH AX             ; <<< 关键修正 (1/2): 保存 AX (因为它即将被 INT 21H 破坏)
    MOV AH, 02H         ; DOS 打印功能
    INT 21H
    POP AX              ; <<< 关键修正 (2/2): 恢复 AX (以便下次 ROL 能正确工作)
    JMP NEXT_ITER

CHECK_LEADING_ZERO:
    CMP DL, 0
    JE NEXT_ITER        ; 仍然是 0, 跳过打印
    MOV BH, 0           ; 发现第一个非零数字, 清除标志
    JMP PRINT_NIBBLE    ; 去打印

NEXT_ITER:
    DEC BL              ; 使用 BL 递减计数器
    JNZ HEX_LOOP        ; 循环直到 BL = 0

HEX_EXIT:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX ENDP

; -----------------------------------------------------------------
; 主程序开始
; -----------------------------------------------------------------
START:
    MOV AX, DGROUP
    MOV DS, AX
    MOV ES, AX

    ; 1. 获取关键字
    LEA DX, MSG_KEY
    MOV AH, 09H
    INT 21H
    LEA DX, KBD_BUF
    MOV AH, 0AH
    INT 21H

    XOR CH, CH
    MOV CL, KBD_BUF[1]
    MOV BP, CX

; -----------------------------------------------------------------
; 句子处理主循环
; -----------------------------------------------------------------
SENTENCE_LOOP:
    ; 2. 获取句子
    LEA DX, MSG_SNT
    MOV AH, 09H
    INT 21H
    LEA DX, SNT_BUF
    MOV AH, 0AH
    INT 21H

    ; 3. 设置比较参数
    CLD
    XOR CH, CH
    MOV CL, SNT_BUF[1]
    LEA SI, KBD_BUF[2]
    LEA DI, SNT_BUF[2]

    ; 4. 检查是否可能匹配
    CMP CX, BP
    JL HANDLE_NO_MATCH

    ; 5. 计算外循环次数
    SUB CX, BP
    INC CX
    MOV BX, CX

; 6. 外循环
OUTER_LOOP:
    PUSH SI
    PUSH DI
    MOV CX, BP
    
    ; 7. 内循环
    REPZ CMPSB
    
    POP DI
    POP SI
    
    ; 8. 检查匹配结果
    JCXZ HANDLE_MATCH
    
    INC DI
    DEC BX
    JNZ OUTER_LOOP
    
    JMP HANDLE_NO_MATCH

; 9. 找到匹配
HANDLE_MATCH:
    LEA DX, MSG_MATCH_PRE
    MOV AH, 09H
    INT 21H
    
    LEA AX, SNT_BUF[2]
    SUB DI, AX
    INC DI
    
    MOV AX, DI
    CALL PRINT_HEX
    
    LEA DX, MSG_MATCH_POST
    MOV AH, 09H
    INT 21H
    
    JMP SENTENCE_LOOP

; 10. 未找到匹配
HANDLE_NO_MATCH:
    LEA DX, MSG_NOMATCH
    MOV AH, 09H
    INT 21H
    
    JMP SENTENCE_LOOP

CODE ENDS
    END START