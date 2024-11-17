
MOV x1, =num    // numero a calcular el factorial

factorial:

    CMP x1, 1 
    BEQ endFact    // Si x1 es 0, salto a endFact

    STR x1, [SP, -8]!    // Guardo el valor de x1

    SUB x1, x1, 1

    STP x29, x30, [sp, -16]!

    BL factorial

    LDP x29, x30, [sp], 16

    LDR x2, [SP, 8]   // restauro el valor anterior

    MUL x1, x1, x2

    endFact:
        RET

-----------------------------------------------------------------------------------------


MOV x0, =num
MOV x1, x0
LDR x10, =buffer

    loop:
        CBZ x1, endLoop

        SDIV x0, x0, 2  // dividir por 2

        MOV x3, 2   
        MUL x2, x0, x3  // multiplicar cociente por 2

        SUB X3, x1, x2  // restar original - (cociente * 2) = residuo
        ADD x3, 48  // convertir a ascii el 1 o 0
        STRB w3, [X10], 1   // almacenarlo en el buffer y aumentar en 1 el index

        MOV x1, x0  // recuperar el cociente para el ciclo

        B loop

        endLoop:
            LDR x11, =buffer    // variable auxiliar para invertir la cadena

            invertirCadena: 
                LDRB w5, [x10]  // cargar el valor de la derecha
                LDRB w6, [x11]  // cargar el valor de la izquierda

                STRB w6, [x10], -1  // invertir valores y restar 1 al index de la derecha
                STRB w5, [x11], 1   // invertir valores y sumar 1 al index de la izquierda

                CMP x10, x11    // si el index x10 es menor al x11, quiere decir que ya invirtio la cadena
                BGT inveritirCadena