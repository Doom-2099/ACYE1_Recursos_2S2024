.global atoi
.global itoa
.global _start

.data

salto:
    .asciz "\n"
    lenSalto = . - salto

clear_screen:
    .asciz "\x1B[2J\x1B[H"
    lenClear = . - clear_screen

encabezado:
    .asciz "Universidad De San Carlos De Guatemala\n"
    .asciz "Facultad De Ingenieria\n"
    .asciz "Escuela De Ciencias Y Sistemas\n"
    .asciz "Arquitectura De Computadores 1\n"
    .asciz "Jorge Castañeda\n"
    lenEncabezado = . - encabezado

menuPrincipal:
    .asciz ">> Menu Principal\n"
    .asciz "1. Suma\n"
    .asciz "2. Resta\n"
    .asciz "3. Multiplicacion\n"
    .asciz "4. Division\n"
    .asciz "5. Calculo Con Memoria\n"
    .asciz "6. Salir\n"
    .asciz ">> Ingrese Una Opcion: "
    lenMenu = . - menuPrincipal

inputOperacion:
    .asciz ">> Ingrese La Operacion: "
    lenInputOperacion = . - inputOperacion

errDivision:
    .asciz "Error: Division Por Cero\n"
    lenErrDivision = . - errDivision
    
.bss
opcion:
    .space 5

bufferOperandos:
    .zero 10
bufferResultado:
    .zero 10
bufferAux:
    .zero 10
operando1:
    .zero 8
operando2:
    .zero 8


.text
.macro print reg, len
    MOV x0, 1
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

.macro read reg, len
    MOV x0, 0
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm

atoi:  // ascii to int
    SUB x5, x5, 1
    a_contarDigitos:
        LDRB w1, [x0], 1 // post - index
        CBZ w1, a_convertir
        CMP w1, 10
        BEQ a_convertir
        B a_contarDigitos

    a_convertir:
        SUB x0, x0, 2 // Index de la cadena a recorrer
        MOV w4, 1   // Multiplicador
        MOV x7, 0  // Resultado
        
        a_convertirChars:
            LDRB w1, [x0], -1
            CMP w1, 45
            BEQ a_negativeNum

            SUB w1, w1, 48
            MUL w1, w1, w4
            ADD w7, w7, w1

            MOV w6, 10
            MUL w4, w4, w6
            
            CMP x0, x5
            BNE a_convertirChars
            B a_endConvertir

        a_negativeNum:
            NEG w7, w7
        
        a_endConvertir:
            STR w7, [x8] // usando 32 bits
    
    RET

itoa: // int to ascii
    MOV x10, 0
    MOV x12, 0
    MOV w2, 10000
    CMP w0, 0
    BGT i_convertirAscii

    CMP w0, 0
    BEQ i_zero

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
        UDIV w3, w0, w2
        CBZ w3, i_reduceBase

        CMP w2, 1
        BLE i_unidades

        MOV w5, w3
        ADD w5, w5, 48
        STRB w5, [x1], 1
        ADD x10, x10, 1

        MUL w3, w3, w2
        SUB w0, w0, w3

        i_reduceBase:
            MOV w6, 10
            UDIV w2, w2, w6

            CMP w2, 1
            BLE i_unidades

            CBNZ w10, i_addZero
            B i_convertirAscii

        i_addZero:
            CBNZ w3, i_convertirAscii
            ADD x10, x10, 1
            MOV w5, 48
            STRB w5, [x1], 1
            B i_convertirAscii

        i_unidades:
            CMP w2, 1
            BGT i_convertirAscii
            ADD x10, x10, 1
            MOV w5, w0
            ADD w5, w5, 48
            STRB w5, [x1], 1

    i_endConversion:
        ADD x10, x10, x12
        print bufferResultado, x10
        RET

_start:
    print clear_screen, lenClear
    print encabezado, lenEncabezado 
    read opcion, 1

    menu:
        print clear_screen, lenClear
        print menuPrincipal, lenMenu
        read opcion, 5

        LDR x3, =opcion
        LDRB w3, [x3]
        CMP w3, 54
        BEQ end

        print inputOperacion, lenInputOperacion
        read bufferOperandos, 10

        LDR x7, =bufferOperandos
        validarInput:
            LDRB w8, [x7], 1
            CBZ w8, tipo1

            CMP w8, 44 // ','
            BEQ tipo3
            
            B validarInput

        tipo1:
            LDR x0, =bufferOperandos
            LDR x5, =bufferOperandos
            LDR x8, =operando1
            BL atoi

            print inputOperacion, lenInputOperacion
            read bufferOperandos, 10
            
            LDR x0, =bufferOperandos
            LDR x5, =bufferOperandos
            LDR x8, =operando2
            BL atoi

            B hacerOperacion

        tipo3: // Ingresar numeros por comas
            MOV w8, 0
            STRB w8, [x7, -1]! // pre-index
            ADD x7, x7, 1

            LDR x9, =bufferAux
            MOV x10, 0
            copyValue:
                LDRB w8, [x7]
                CMP w8, 10
                BEQ endCopy

                STRB w8, [x9], 1
                STRB w10, [x7], 1
                B copyValue

            endCopy: 
                MOV w8, 0
                STRB w8, [x9], 1

                LDR x0, =bufferOperandos
                LDR x5, =bufferOperandos
                LDR x8, =operando1
                BL atoi
                
                LDR x0, =bufferAux
                LDR x5, =bufferAux
                LDR x8, =operando2
                BL atoi

        hacerOperacion:
            MOV x2, 0
            MOV x3, 0

            LDR x0, =operando1
            LDR x1, =operando2

            LDR w2, [x0]
            LDR w3, [x1]

            MOV x8, 0
            LDR x7, =opcion
            LDRB w8, [x7]

            CMP w8, 49
            BEQ suma    

            CMP w8, 50
            BEQ resta

            CMP w8, 51
            BEQ multiplicacion

            CMP w8, 52
            BEQ division

            suma:
                ADD w3, w2, w3
                B printResultado

            resta:
                SUB w3, w2, w3
                B printResultado
                
            multiplicacion:
                SMULL x3, w2, w3
                B printResultado

            division:
                CMP w3, 0
                BEQ printErrDivision
                SDIV w3, w2, w3
                B printResultado

            printErrDivision:
                print errDivision, lenErrDivision
                read opcion, 1
                B menu

            printResultado:
                MOV x0, 0
                MOV w0, w3
                LDR x1, =bufferResultado

                BL itoa
                print salto, lenSalto
                read opcion, 1
                B menu

        B menu

    end:
        MOV x0, 0
        MOV x8, 93
        SVC 0

