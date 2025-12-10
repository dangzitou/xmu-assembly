; 排序板子
; 包含: 冒泡排序

    ; ==========================================
    ; 函数: BUBBLE_SORT
    ; 功能: 对字节数组进行冒泡排序 (升序)
    ; 输入: DS:SI = 数组首地址, CX = 数组长度
    ; 输出: 数组被原地排序
    ; ==========================================
BUBBLE_SORT PROC NEAR
                PUSH   AX
                PUSH   BX
                PUSH   CX
                PUSH   DX
                PUSH   SI

                CMP    CX, 1         ; 如果长度 <= 1，不需要排序
                JLE    SORT_DONE

                DEC    CX            ; 外层循环次数 = 长度 - 1

    OUTER_LOOP: 
                PUSH   CX            ; 保存外层循环计数
                PUSH   SI            ; 保存数组起始地址
    
    ; 内层循环
    ; CX 是剩余需要比较的次数
    ; SI 是当前指针
    
    INNER_LOOP: 
                MOV    AL, [SI]
                MOV    AH, [SI+1]
                CMP    AL, AH
                JLE    NO_SWAP       ; 如果 AL <= AH，不需要交换 (升序)
    
    ; 交换
                MOV    [SI], AH
                MOV    [SI+1], AL

    NO_SWAP:    
                INC    SI
                LOOP   INNER_LOOP    ; 继续内层循环

                POP    SI            ; 恢复数组起始地址
                POP    CX            ; 恢复外层循环计数
                LOOP   OUTER_LOOP    ; 继续外层循环

    SORT_DONE:  
                POP    SI
                POP    DX
                POP    CX
                POP    BX
                POP    AX
                RET
BUBBLE_SORT ENDP
