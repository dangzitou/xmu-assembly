STACK SEGMENT
          DB 255 DUP(?)
STACK ENDS

; 声明样例
DATA SEGMENT
                INPUT_STRING LABEL BYTE
    MAX_LENGTH  DB           100
    TRUE_LENGTH DB           ?
    STRING      DB           100 DUP(?)
    ARR         DB           26 DUP(0)
    ARR_LEN     DB           26
DATA ENDS

CODE SEGMENT
                     ASSUME CS:CODE, SS:STACK, DS:DATA
    ; 输出十进制AX(无符号)
PRINT_DEC PROC FAR
                     PUSH   BX
                     PUSH   CX
                     PUSH   DX
                     XOR    CX, CX
                     MOV    BL, 10
    WHILE_P:         
                     DIV    BL                            ; AL = AX / BL; AH = AX % BL
                     MOV    DL, AH
                     ADD    DL, '0'
                     PUSH   DX
                     INC    CX
                     XOR    AH, AH

                     CMP    AL, BYTE PTR 0
                     JNZ    WHILE_P

                     MOV    AH, 02H
    WHILE_O:         
                     POP    DX
                     INT    21H
                     LOOP   WHILE_O

                     POP    DX
                     POP    CX
                     POP    BX
                     RET
PRINT_DEC ENDP
    ; 输出二进制AX(无符号)
PRINT_BIN PROC FAR
                     PUSH   CX
                     PUSH   DX
                     MOV    CX, 16
    WHILE_PB:        
                     MOV    DX, AX
                     AND    DX, 1
                     ADD    DL, '0'
                     SHR    AX, 1
                     PUSH   DX
                     LOOP   WHILE_PB

                     MOV    CX, 16
                     MOV    AH, 02H
    WHILE_OB:        
                     POP    DX
                     INT    21H
                     LOOP   WHILE_OB

                     POP    DX
                     POP    CX
                     RET
PRINT_BIN ENDP
    ; 输出十六进制AX(无符号) 大写
PRINT_HEX PROC FAR
                     PUSH   CX
                     PUSH   DX
                     MOV    CX, 4
    WHILE_PH:        
                     MOV    DX, AX
                     AND    DX, 15
                     ADD    DL, '0'
                     CMP    DL, '9'
                     JLE    L_10
                     ADD    DL, 7
    L_10:            
                     PUSH   CX
                     MOV    CL, 4
                     SHR    AX, CL
                     POP    CX
                     PUSH   DX
                     LOOP   WHILE_PH

                     MOV    CX, 4
                     MOV    AH, 02H
    WHILE_OH:        
                     POP    DX
                     INT    21H
                     LOOP   WHILE_OH

                     POP    DX
                     POP    CX
                     RET
PRINT_HEX ENDP
    ; 输出换行
ENDL PROC FAR
                     PUSH   AX
                     PUSH   DX
                     MOV    AH, 02H
                     MOV    DL, 0AH
                     INT    21H
                     POP    DX
                     POP    AX
                     RET
ENDL ENDP
    ; 输出DL(字符)
PUTCHAR PROC FAR
                     PUSH   AX
                     MOV    AH, 02H
                     INT    21H
                     POP    AX
                     RET
PUTCHAR ENDP
    ; 输出DX(字符串) '$'=结束
PUTS PROC FAR
                     PUSH   AX
                     MOV    AH, 09H
                     INT    21H
                     POP    AX
                     RET
PUTS ENDP
    ; 输入AL(字符)
GETCHAR PROC FAR
                     MOV    AH, 01H
                     INT    21H
                     RET
GETCHAR ENDP
    ; 输入DX(字符串) DX[0]=最大容量 DX[1]=实际容量 DX[2]=字符串首
GETS PROC FAR
                     PUSH   AX
                     MOV    AH, 0AH
                     INT    21H
                     POP    AX
                     RET
GETS ENDP
    ; 排序数组(BYTE)(小->大) CX:排序的长度(容量) BX:数组首项地址 选择排序
SORTSB PROC FAR
                     PUSH   AX
                     PUSH   SI
                     PUSH   DI

                     XOR    SI, SI                        ; SI = 0
    _SORTS_FOR1:     
                     MOV    DI, SI
                     INC    DI                            ; DI = SI + 1
                     PUSH   SI                            ; SAVE SI (LET SI := MININDEX)
    _SORT_FOR2:      
                     MOV    AL, [BX+SI]
                     CMP    AL, [BX+DI]                   ; IF BX[MININDEX] > BX[DI]
                     JLE    _SORT_FOR2_END
                     MOV    SI, DI                        ; THEN MININDEX = DI

    _SORT_FOR2_END:  
                     INC    DI
                     CMP    DI, CX                        ; IF DI <= CX LOOP INNER
                     JL     _SORT_FOR2

                     MOV    DI, SI                        ; DI := MININDEX
                     POP    SI                            ; SI := CURRENT
                     CMP    DI, SI
                     JE     _SORTS_FOR1_END               ; IF DI != SI
                     MOV    AL, [BX+DI]                   ; THEN SWAP
                     XCHG   AL, [BX+SI]
                     MOV    [BX+DI], AL

    _SORTS_FOR1_END: 
                     INC    SI                            ; SI++
                     MOV    AX, CX
                     DEC    AX
                     CMP    SI, AX                        ; IF SI < CX - 1 LOOP OUTER
                     JL     _SORTS_FOR1
        
                     POP    DI
                     POP    SI
                     POP    AX
                     RET
SORTSB ENDP
    ; 排序数组(WORD)
SORTSW PROC FAR
                     PUSH   AX
                     PUSH   SI
                     PUSH   DI

                     XOR    SI, SI                        ; SI = 0
    _SORTSW_FOR1:    
                     MOV    DI, SI
                     ADD    DI, 2                         ; DI = SI + 1
                     PUSH   SI                            ; SAVE SI (LET SI := MININDEX)
    _SORTSW_FOR2:    
                     MOV    AX, [BX+SI]
                     CMP    AX, [BX+DI]                   ; IF BX[MININDEX] > BX[DI]
                     JLE    _SORTSW_FOR2_END
                     MOV    SI, DI                        ; THEN MININDEX = DI

    _SORTSW_FOR2_END:
                     ADD    DI, 2
                     MOV    AX, CX
                     SHL    AX, 1
                     CMP    DI, AX                        ; IF DI <= CX LOOP INNER
                     JL     _SORTSW_FOR2

                     MOV    DI, SI                        ; DI := MININDEX
                     POP    SI                            ; SI := CURRENT
                     CMP    DI, SI
                     JE     _SORTSW_FOR1_END              ; IF DI != SI
                     MOV    AX, [BX+DI]                   ; THEN SWAP
                     XCHG   AX, [BX+SI]
                     MOV    [BX+DI], AX

    _SORTSW_FOR1_END:
                     ADD    SI, 2                         ; SI++
                     MOV    AX, CX
                     DEC    AX
                     SHL    AX, 1
                     CMP    SI, AX                        ; IF SI < CX - 1 LOOP OUTER
                     JL     _SORTSW_FOR1
        
                     POP    DI
                     POP    SI
                     POP    AX
                     RET
SORTSW ENDP

    ; BX
PROCESS PROC FAR
                     XOR    AX, AX
                     MOV    AL, [BX]
                     SUB    AL, '0'
                     PUSH   BX
                     MOV    BL, 10
                     MUL    BL
                     POP    BX
                     PUSH   CX
                     MOV    CL, [BX+1]
                     SUB    CL, '0'
                     ADD    AL, CL
                     POP    CX
                     RET
PROCESS ENDP

    START:           
                     MOV    AX, STACK
                     MOV    SS, AX
                     MOV    AX, DATA
                     MOV    DS, AX

    ; CODE EXAMPLE
    ; TODO:

                     LEA    DX, INPUT_STRING
                     CALL   GETS

                     LEA    BX, STRING
                     CALL   PROCESS
                     MOV    CX, AX
                     ADD    BX, 3
                     CALL   PROCESS
                     XCHG   AX, CX

                     MOV    DL, [BX-1]
                     CMP    DL, '+'
                     JE     ADD_L
                     SUB    AX, CX
                     JMP    PNT
    ADD_L:           
                     ADD    AX, CX
    PNT:             
                     PUSH   AX

                     MOV    CX, 5
                     LEA    BX, STRING
    FORWARD:         
                     MOV    DL, [BX]
                     CALL   PUTCHAR
                     INC    BX
                     LOOP   FORWARD

                     MOV    DL, '='
                     CALL   PUTCHAR
                     POP    AX

                     CMP    AX, 0
                     JG     PNT_N
                     PUSH   AX
                     MOV    DL, '-'
                     CALL   PUTCHAR
                     POP    AX
                     NEG    AX
    PNT_N:           
                     CALL   PRINT_DEC
    ; CODE END

                     MOV    AX, 4C00H
                     INT    21H
CODE ENDS
END START

; 108E
; masm xxx.asm
; link xxx.obj
; debug xxx.exe
; ****************************************
; debug
; t (段:偏移) (条数) 执行几条指令
; p 同 t 但是MASM5以上版本
; r 显示所有寄存器和下一条指令
; r [寄存器名] 修改指定寄存器内容
; u [地址] (终止地址) machine -> assembly
; g (地址) (断点地址) 执行
; d (地址) (终止地址) 查看内存内容
; q quit
