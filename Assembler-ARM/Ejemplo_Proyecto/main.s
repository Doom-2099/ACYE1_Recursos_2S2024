.global itoa
.global _start

.data
salto:
    .asciz "\n"
    lenSalto = .- salto

espacio:
    .asciz "\t"
    lenEspacio = .- espacio

cols:
    .asciz "ABCDEF"

rows:
    .asciz "123456"

.bss
arreglo:
    .rept 36
    .hword 0
    .endr

num:
    .space 4

val:
    .space 1
    

.text
.macro print stdout, reg, len
    MOV x0, \stdout
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
        CMP x7, 6
        BNE printCols
        print 1, salto, lenSalto

    MOV x7, 0

    loop1:
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

        ADD x9, x9, 1
        ADD x7, x7, 1
        CMP x7, 6
        BNE loop1

        // REVISAR VALORES QUE SE IMPRIMEN EXTRA EN LA MATRIZ
        // DEBUGGEAR LA IMPRESION DE LA MATRIZ

    exit:
        MOV x0, 0
        MOV x8, 93
        SVC 0
