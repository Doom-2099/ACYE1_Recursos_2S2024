.global _start

.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear

    encabezado:
        .asciz "Universidad De San Carlos De Guatemala\n"
        .asciz "Facultad De Ingenieria\n"
        .asciz "Arquitectura De Computadores\n"
        .asciz "Ejemplo Practico\n"
        lenEncabezado = . - encabezado

    menuPrincipal:
        .asciz ">> Menu Principal\n"
        .asciz "1. Suma\n"
        .asciz "2. Resta\n"
        .asciz "3. Multiplicacion\n"
        .asciz "4. Division\n"
        .asciz "5. Calculo Con Memoria\n"
        .asciz "6. Salir\n"
        lenMenuPrincipal = .- menuPrincipal

    msgOpcion:
        .asciz "Ingrese Una Opcion: "
        lenOpcion = .- msgOpcion

    sumaText:
        .asciz "Ingresando Suma\n"
        lenSumaText = . - sumaText

    restaText:
        .asciz "Ingresando Resta\n1"
        lenRestaText = . - restaText

    multiplicacionText:
        .asciz "Ingresando Multiplicacion\n"
        lenMultiplicacionText = . - multiplicacionText

    divisionText:
        .asciz "Ingresando Division\n"
        lenDivisionText = . - divisionText

    operacionesText:
        .asciz "Ingresando Operaciones\n"
        lenOperacionesText = . - operacionesText

.bss
    opcion:
        .space 5   // => El 1 indica cuantos BYTES se reservaran para la variable opcion

.macro print texto, cantidad
    MOV x0, 1
    LDR x1, =\texto
    LDR x2, =\cantidad
    MOV x8, 64
    SVC 0 
.endm

.macro input
    MOV x0, 0
    LDR x1, =opcion
    LDR x2, =5
    MOV x8, 63
    SVC 0
.endm


.text
_start:
    // Colocar el codigo ARM
    print clear, lenClear
    print encabezado, lenEncabezado
    input

    menu:
        print clear, lenClear
        print menuPrincipal, lenMenuPrincipal
        print msgOpcion, lenOpcion
        input

        LDR x10, =opcion
        LDRB w10, [x10]

        CMP w10, 49
        BEQ suma

        CMP w10, 50
        BEQ resta

        CMP w10, 51
        BEQ multiplicacion

        CMP w10, 52
        BEQ division

        CMP w10, 53
        BEQ operacion_memoria

        CMP w10, 54
        BEQ end

        suma:
            print sumaText, lenSumaText
            // Pedir numeros de entrada
            // replicar el funcionamiendo de atoi(ASCII TO INTEGER)[Funcion de C]
            // realizar operacion
            // replicar el funcionamiento de itoa(INTEGER TO ASCII)[Funcion de C]
            B cont

        resta:
            print restaText, lenRestaText
            B cont

        multiplicacion:
            print multiplicacionText, lenMultiplicacionText
            B cont

        division:
            print divisionText, lenDivisionText
            B cont
        
        operacion_memoria:
            print operacionesText, lenOperacionesText
            B cont

        cont:
            input
            B menu

    end:
        MOV x0, 0   // Codigo de error de la aplicacion -> 0: no hay error
        MOV x8, 93  // Codigo de la llamada al sistema
        SVC 0       // Ejecutar la llamada al sistema
