.global openFile
.global closeFile
.global readCSV
.global atoi
.global itoa
.global bubbleSort
.global _start

.data
salto:
    .asciz "\n"
    lenSalto = .- salto

espacio:
    .asciz " "
    lenEspacio = .- espacio

clear_screen:
    .asciz "\x1B[2J\x1B[H"
    lenClear = .- clear_screen

encabezado:
    .asciz "Ejemplo Practica 4 - Jorge Castañeda\n"
    .asciz "Ordenamiento De Datos\n"
    .asciz "Lectura Y Escritura De Archivos\n"
    lenEncabezado = .- encabezado

msgFilename:
    .asciz "Ingrese el nombre del archivo: "
    lenMsgFilename = .- msgFilename

errorOpenFile:
    .asciz "Error al abrir el archivo\n"
    lenErrOpenFile = .- errorOpenFile

readSuccess:
    .asciz "El Archivo Se Ha Leido Correctamente\n"
    lenReadSuccess = .- readSuccess


.bss
opcion:
    .space 2

filename:
    .zero 50

array:
    .skip 1024

count:
    .zero 8

num:
    .space 4

character:
    .byte 0

fileDescriptor:
    .space 8

.text

// Macro para imprimir strings
.macro print reg, len
    MOV x0, 1
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

// Macro para leer datos del usuario
.macro read stdin, buffer, len
    MOV x0, \stdin
    LDR x1, =\buffer
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm

openFile:
    // param: x1 -> filename
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
        print errorOpenFile, lenErrOpenFile
        read 0, opcion, 1

    op_f_end:
        RET


closeFile:
    LDR x0, =fileDescriptor
    LDR x0, [x0]
    MOV x8, 57
    SVC 0
    RET

readCSV:
    // code para leer numero y convertir
    LDR x10, =num    // Buffer para almacenar el numero
    LDR x11, =fileDescriptor
    LDR x11, [x11]

    rd_num:
        read x11, character, 1
        LDR x4, =character
        LDRB w3, [x4]
        CMP w3, 44
        BEQ rd_cv_num

        MOV x20, x0
        CBZ x0, rd_cv_num

        STRB w3, [x10], 1
        B rd_num

    rd_cv_num:
        LDR x5, =num
        LDR x8, =num
        LDR x12, =array

        STP x29, x30, [SP, -16]!

        BL atoi

        LDP x29, x30, [SP], 16

        LDR x12, =num
        MOV w13, 0
        MOV x14, 0

        cls_num:
            STRB w13, [x12], 1
            ADD x14, x14, 1
            CMP x14, 3
            BNE cls_num
            LDR x10, =num
            CBNZ x20, rd_num

    rd_end:
        print salto, lenSalto
        print readSuccess, lenReadSuccess
        read 0, opcion, 2
        RET

atoi:
    // params: x5, x8 => buffer address, x12 => result address
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
            LDR x13, =count
            LDR x13, [x13] // saltos
            MOV x14, 2
            MUL x14, x13, x14

            STRH w9, [x12, x14] // usando 16 bits

            ADD x13, x13, 1
            LDR x12, =count
            STR x13, [x12]

            RET

itoa:
    // params: x0 => number, x1 => buffer address
    MOV x10, 0  // contador de digitos a imprimir
    MOV x12, 0  // flag para indicar si hay signo menos
    MOV w2, 10000  // Base 10
    CMP w0, 0  // Numero a convertir
    BGT i_convertirAscii
    CBZ w0, i_zero

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
        NEG w0, w0

    i_convertirAscii:
        CBZ w2, i_endConversion
        UDIV w3, w0, w2
        CBZ w3, i_reduceBase

        MOV w5, w3
        ADD w5, w5, 48
        STRB w5, [x1], 1
        ADD x10, x10, 1

        MUL w3, w3, w2
        SUB w0, w0, w3

        CMP w2, 1
        BLE i_endConversion

        i_reduceBase:
            MOV w6, 10
            UDIV w2, w2, w6

            CBNZ w10, i_addZero
            B i_convertirAscii

        i_addZero:
            CBNZ w3, i_convertirAscii
            ADD x10, x10, 1
            MOV w5, 48
            STRB w5, [x1], 1
            B i_convertirAscii

    i_endConversion:
        ADD x10, x10, x12
        print num, x10
        RET


bubbleSort:
    LDR x0, =count
    LDR x0, [x0] // length => cantidad de numeros leidos del csv

    MOV x1, 0 // index i - bubble sort algorithm
    SUB x0, x0, 1 // length - 1

    bs_loop1:
        MOV x9, 0 // index j - bubble sort algorithm
        SUB x2, x0, x1 // length - 1 - i

        bs_loop2:
            LDR x3, =array
            LDRH w4, [x3, x9, LSL 1] // array[i]
            ADD x9, x9, 1
            LDRH w5, [x3, x9, LSL 1] // array[i + 1]

            CMP w4, w5
            BLT bs_cont_loop2

            STRH w4, [x3, x9, LSL 1]
            SUB x9, x9, 1
            STRH w5, [x3, x9, LSL 1]
            ADD x9, x9, 1

            bs_cont_loop2:
                CMP x9, x2
                BNE bs_loop2

        ADD x1, x1, 1
        CMP x1, x0
        BNE bs_loop1

    RET

// Etiqueta de inicio del programa
_start:
    // Limpiar salida de la terminal
    print clear_screen, lenClear

    // Imprimir encabezado
    print encabezado, lenEncabezado
    read 0, opcion, 2

    // Imprimir mensaje para ingresar el nombre del archivo
    print msgFilename, lenMsgFilename
    read 0, filename, 50

    // Agregar caracter nulo al final del nombre del archivo
    LDR x0, =filename
    loop:
        LDRB w1, [x0], 1
        CMP w1, 10
        BEQ endLoop
        B loop

        endLoop:
            MOV w1, 0
            STRB w1, [x0, -1]!

    // funcion para abrir el archivo
    LDR x1, =filename
    BL openFile 
    
    // procedimiento para leer los numeros del archivo
    BL readCSV

    // funcion para cerrar el archivo
    BL closeFile 

    // Llamar Algoritmo de Ordenamiento Burbuja
    BL bubbleSort

    // recorrer array y convertir a ascii
    LDR x9, =count
    LDR x9, [x9] // length => cantidad de numeros leidos del csv
    MOV x7, 0
    LDR x15, =array

    loop_array:
        LDRH w0, [x15], 2
        LDR x1, =num
        BL itoa

        print espacio, lenEspacio

        ADD x7, x7, 1
        CMP x9, x7
        BNE loop_array

    print salto, lenSalto

    // Instruccion para terminar el programa
    end:
        MOV x0, 0
        MOV x8, 93
        SVC 0
