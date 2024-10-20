.global itoa
.global atoi
.global proc_import
.global import_data
.global readCSV
.global openFile
.global closeFile
.global _start

.data
salto:
    .asciz "\n"
    lenSalto = .- salto

espacio:
    .asciz "\t"
    lenEspacio = .- espacio

espacio2:
    .asciz " "
    lenEspacio2 = .- espacio2

dpuntos:
    .asciz ":"
    lenDpuntos = .- dpuntos

cols:
    .asciz " ABCDEF"

rows:
    .asciz "123456"

cmdimp:
    .asciz "IMPORTAR"

cmdsep:
    .asciz "SEPARADO POR COMA"

errorImport:
    .asciz "Error En El Comando De Importación"
    lenError = .- errorImport

errorOpenFile:
    .asciz "Error al abrir el archivo\n"
    lenErrOpenFile = .- errorOpenFile

getIndexMsg:
    .asciz "Ingrese la columna para el encabezado "
    lenGetIndexMsg = .- getIndexMsg

readSuccess:
    .asciz "El Archivo Se Ha Leido Correctamente\n"
    lenReadSuccess = .- readSuccess

.bss
arreglo:
    .rept 36
    .hword 0
    .endr

val:
    .space 2

bufferComando:
    .zero 50

filename:
    .space 100

buffer:
    .zero 1024

fileDescriptor:
    .space 8

listIndex:
    .zero 6

num:
    .space 8

col_imp:
    .space 1

character:
    .space 2

count:
    .zero 8
    

.text
.macro print stdout, reg, len
    MOV x0, \stdout
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

.macro read stdin, reg, len
    MOV x0, \stdin
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm

itoa:
    // params: x0 => number, x1 => buffer address
    MOV x10, 0  // contador de digitos a imprimir
    MOV x12, 0  // flag para indicar si hay signo menos

    CBZ x0, i_zero

    MOV x2, 1
    defineBase:
        CMP x2, x0
        MOV x5, 0
        BGT cont
        MOV x5, 10
        MUL x2, x2, x5
        B defineBase

    cont:
        CMP x0, 0  // Numero a convertir
        BGT i_convertirAscii
        B i_negative

    i_zero:
        ADD x10, x10, 1
        MOV w5, 48
        STRB w5, [x1], 1
        B i_endConversion

    i_negative:
        MOV  x12, 1
        MOV w5, 45
        STRB w5, [x1], 1
        NEG x0, x0

    i_convertirAscii:
        CBZ x2, i_endConversion
        UDIV x3, x0, x2
        CBZ x3, i_reduceBase

        MOV w5, w3
        ADD w5, w5, 48
        STRB w5, [x1], 1
        ADD x10, x10, 1

        MUL x3, x3, x2
        SUB x0, x0, x3

        CMP x2, 1
        BLE i_endConversion

        i_reduceBase:
            MOV x6, 10
            UDIV x2, x2, x6

            CBNZ x10, i_addZero
            B i_convertirAscii

        i_addZero:
            CBNZ x3, i_convertirAscii
            ADD x10, x10, 1
            MOV w5, 48
            STRB w5, [x1], 1
            B i_convertirAscii

    i_endConversion:
        ADD x10, x10, x12
        print 1, num, x10
        RET

atoi:
    // params: x5, x8 => buffer address
    SUB x5, x5, 1
    a_c_digits:
        LDRB w7, [x8], 1
        CBZ w7, a_c_convert
        CMP w7, 10
        BEQ a_c_convert
        B a_c_digits

    a_c_convert:
        SUB x8, x8, 2
        MOV x4, 1
        MOV x9, 0

        a_c_loop:
            LDRB w7, [x8], -1
            CMP w7, 45
            BEQ a_c_negative

            SUB w7, w7, 48
            MUL w7, w7, w4
            ADD w9, w9, w7

            MOV w6, 10
            MUL w4, w4, w6

            CMP x8, x5
            BNE a_c_loop
            B a_c_end

        a_c_negative:
            NEG w9, w9

        a_c_end:
            RET

proc_import:
    LDR x0, =cmdimp
    LDR x1, =bufferComando

    imp_loop:
        LDRB w2, [x0], 1
        LDRB w3, [x1], 1

        CBZ w2, imp_filename

        CMP w2, w3
        BNE imp_error

        B imp_loop

        imp_error:
            print 1, errorImport, lenError
            B end_proc_import

    imp_filename:
        LDR x0, =filename
        imp_file_loop:
            LDRB w2, [x1], 1

            CMP w2, 32
            BEQ cont_imp_file

            STRB w2, [x0], 1
            B imp_file_loop

        cont_imp_file:
            STRB wzr, [x0]
            LDR x0, =cmdsep
            cont_imp_loop:
                LDRB w2, [x0], 1
                LDRB w3, [x1], 1
                
                CBZ w2, end_proc_import
                B cont_imp_loop

                CMP w2, w3
                BNE imp_error
    end_proc_import:
        RET

import_data:
    LDR x1, =filename
    STP x29, x30, [SP, -16]!
    BL openFile
    LDP x29, x30, [SP], 16

    LDR x25, =buffer
    MOV x10, 0
    LDR x11, =fileDescriptor
    LDR x11, [x11]
    MOV x17, 0 //contador de columnas
    LDR x15, =listIndex

    read_head:
        read x11, character, 1
        LDR x4, =character
        LDRB w2, [x4]

        CMP w2, 44
        BEQ getIndex

        CMP w2, 10
        BEQ getIndex

        STRB w2, [x25], 1
        ADD x10, x10, 1
        B read_head

        getIndex:
            print 1, getIndexMsg, lenGetIndexMsg
            print 1, buffer, x10
            print 1, dpuntos, lenDpuntos
            print 1, espacio2, lenEspacio2

            LDR x4, =character
            LDRB w7, [x4]

            read 0, character, 2

            LDR x4, =character
            LDRB w2, [x4]
            SUB w2, w2, 65
            
            STRB w2, [x15], 1
            ADD x17, x17, 1

            CMP w7, 10
            BEQ end_header

            LDR x25, =buffer
            MOV x10, 0
            B read_head

        end_header:
            STP x29, x30, [SP, -16]!
            BL readCSV
            LDP x29, x30, [SP], 16

            RET
            

readCSV:
    LDR x10, =num
    LDR x11,  =fileDescriptor
    LDR x11, [x11]
    MOV x21, 0  // contador de filas
    LDR x15, =listIndex // contador de columnas

    rd_num:
        read x11, character, 1
        LDR x4, =character
        LDRB w3, [x4]
        CMP w3, 44
        BEQ rd_cv_num

        CMP w3, 10
        BEQ rd_cv_num

        MOV x25, x0
        CBZ x0, rd_cv_num

        STRB w3, [x10], 1
        B rd_num

    rd_cv_num:
        LDR x5, =num
        LDR x8, =num

        STP x29, x30, [SP, -16]!

        BL atoi

        LDP x29, x30, [SP], 16

        LDRB w16, [x15], 1 // obtener la columna

        LDR x20, =arreglo
        MOV x22, 6
        MUL x22, x21, x22
        ADD x22, x16, x22
        STRH w9, [x20, x22, LSL #1]

        LDR x12, =num
        MOV w13, 0
        MOV x14, 0
        
        LDR x20, =listIndex
        SUB x20, x15, x20
        CMP x20, x17
        BNE cls_num
        
        LDR x15, =listIndex
        ADD x21, x21, 1

        cls_num:
            STRB w13, [x12], 1
            ADD x14, x14, 1
            CMP x14, 7
            BNE cls_num
            LDR x10, =num
            CBNZ x25, rd_num

    rd_end:
        print 1, salto, lenSalto
        print 1, readSuccess, lenReadSuccess
        read 0, character, 2
        RET


openFile:
    // param: x1 => filename
    MOV x0, -100
    MOV x2, 0
    MOV x8, 56
    SVC 0

    CMP x0, 0
    BLE op_f_error
    LDR x9, =fileDescriptor
    STR x0, [x9]
    B op_f_end

    op_f_error:
        print 1, errorOpenFile, lenErrOpenFile
        read 0, character, 2
    
    op_f_end:
        RET

closeFile:
    LDR x0, =fileDescriptor
    LDR x0, [x0]
    MOV x8, 57
    SVC 0
    RET

print_matrix:
    LDR x4, =arreglo    // cargar dirección de la matriz
    MOV x9, 0  // index de slots
    MOV x7, 0 // Contador de filas
    LDR x18, =cols
    LDR x19, =val
    
    printCols:
        LDRB w20, [x18], 1
        STRB w20, [x19]

        print 1, val, 1
        print 1, espacio, lenEspacio
        ADD x7, x7, 1
        CMP x7, 7
        BNE printCols
        print 1, salto, lenSalto

    MOV x7, 0
    LDR x18, =rows
    LDR x19, =val

    loop1:
        LDRB w20, [x18, x7]
        STRB w20, [x19]
        print 1, val, 1
        print 1, espacio, lenEspacio

        MOV x13, 0 // Contador de columnas
        loop2:
            MOV x15, 0 
            LDRH w15, [x4, x9, LSL #1]   // cargar valor del slot de la matriz

            // Convertir dato del slot a ASCII
            MOV x0, x15
            LDR x1, =num

            STP x29, x30, [SP, -16]!
            BL itoa
            LDP x29, x30, [SP], 16

            print 1, espacio, lenEspacio

            ADD x9, x9, 1 // incrementar index de slots
            ADD x13, x13, 1   // incrementar contador de columnas
            CMP x13, 6
            BNE loop2

        print 1, salto, lenSalto

        ADD x7, x7, 1
        CMP x7, 6
        BNE loop1

        RET

_start:
        BL print_matrix

        read 0, bufferComando, 50

        BL proc_import

        BL import_data

        BL print_matrix

    exit: 
        MOV x0, 0
        MOV x8, 93
        SVC 0