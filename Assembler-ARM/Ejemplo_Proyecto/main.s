.global itoa
.global atoi
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

enterCommand:
    .asciz ">> "
    lenEnterCommand = .- enterCommand

cols:
    .asciz " ABCDEF"

rows:
    .asciz "123456"


.bss
arreglo:
    .rept 36
    .hword 0
    .endr

num:
    .space 8

val:
    .space 1

bufferComando:
    .zero 50

bufferArchivo:
    .zero 100

descriptor:
    .space 8

count:
    .space 8
    
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
    MOV x8, 64
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


/* openFile:
    // param: x1 -> filename
    MOV x0, -100
    MOV x2, 0
    MOV x8, 56
    SVC 0

    CMP x0, 0
    //BLE op_f_error
    LDR x9, =descriptor
    STR x0, [x9]
    B op_f_end

    op_f_error:
        print 1, errorOpenFile, lenErrOpenFile
        read 0, opcion, 1
 
    op_f_end:
        RET */

/* closeFile:
    LDR x0, =descriptor
    LDR x0, [x0]
    MOV x8, 57
    SVC 0
    RET */

_start:
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
            BL itoa

            print 1, espacio, lenEspacio

            ADD x9, x9, 1 // incrementar index de slots
            ADD x13, x13, 1   // incrementar contador de columnas
            CMP x13, 6
            BNE loop2

        print 1, salto, lenSalto

        ADD x7, x7, 1
        CMP x7, 6
        BNE loop1

    print 1, enterCommand, lenEnterCommand

    // obtener nombre del archivo a leer
    /* read 0, bufferComando, 50

    LDR x0, =filename
    f_filename:
        LDRB w1, [x0], 1
        CMP w1, 10
        BEQ f_endfilename
        B f_filename

        f_endfilename:
            MOV w1, 0
            STRB w1, [x0, -1]! */

    //LDR x1, =bufferComando
    //BL openFile

    // comenzar a leer el archivo y almacenar valores en el arreglo
    

    //BL closeFile

    exit: 
        MOV x0, 0
        MOV x8, 93
        SVC 0
