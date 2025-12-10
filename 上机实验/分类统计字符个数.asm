DATASG SEGMENT
    letter  DB 0
    digit   DB 0
    other   DB 0

    prompt  DB 'Enter a string: $'
    crlf    DB 0DH, 0AH, '$'

    in_buf  DB 81
            DB ?
    str_dat DB 81 DUP(?)
DATASG ENDS

CODESG SEGMENT
    ASSUME CS:CODESG, DS:DATASG

START:
    MOV AX, DATASG
    MOV DS, AX

    LEA DX, prompt
    MOV AH, 09H
    INT 21H

    LEA DX, in_buf
    MOV AH, 0AH
    INT 21H

    LEA DX, crlf
    MOV AH, 09H
    INT 21H

    MOV CL, [in_buf + 1]
    MOV CH, 0
    
    JCXZ EXIT

    LEA SI, str_dat

PROCESS_LOOP:
    MOV AL, [SI]

    CMP AL, 'A'
    JL  CHECK_DIGIT
    CMP AL, 'Z'
    JLE IS_LETTER

    CMP AL, 'a'
    JL  IS_OTHER
    CMP AL, 'z'
    JLE IS_LETTER
    JMP IS_OTHER

CHECK_DIGIT:
    CMP AL, '0'
    JL  IS_OTHER
    CMP AL, '9'
    JLE IS_DIGIT
    JMP IS_OTHER

IS_LETTER:
    INC letter
    JMP NEXT_CHAR

IS_DIGIT:
    INC digit
    JMP NEXT_CHAR

IS_OTHER:
    INC other

NEXT_CHAR:
    INC SI
    LOOP PROCESS_LOOP

EXIT:
    MOV AH, 4CH
    INT 21H

CODESG ENDS
    END START