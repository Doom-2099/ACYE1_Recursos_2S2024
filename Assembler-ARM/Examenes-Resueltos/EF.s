.data
PALABRA:    .ascii "ARQUI1"

.text
.type buscar, %function
.global buscar
.global _start

// Parametros: x0 => bytes a analizar
buscar:
    STP x29, x30, [SP, #-16]!       // Almacenamos el valor de FP y LR en la pila
    
    ADR x7, PALABRA     // direccion de memoria de la palabra a buscar
    MOV x12, 0          // bandera que indicara si se encontro o no la palabra
    
    loop1:
        LDRB w8, [x7], 1    // Cargar letra de la palabra al registro w8
        MOV x10, #0         // contador para el desplazamiento en el registro

        loop2:
            MOV x11, #255
            LSR x9, x0, x10
            AND x9, x11, x0             // realizar un desplazamiento y aplicar una mascara para recuperar solo un byte
                                        // los desplazamientos seran multiplos de 8, ya que cada byte tiene 8 bits
                                        // La mascara funciona de la siguiente manera:
                                        // x0       => XXXX XXXX XXXX XXXX
                                        // x10      => 0000 0000 0000 00FF
                                        // x0 & x10 => 0000 0000 0000 00XX
                                        // Es decir solo vamos a recuperar el byte menos significativo del registro
                                        // para obtener ese caracter y poderlo comparar con la palabra

            CMP w9, w8      // Comparamos si la letra se encuentra en el registro
            BEQ loop1       // Si se encuentra la letra, pasaremos a la siguiente letra de la palabra para buscar dentro del registro

            ADR x13, PALABRA    // cargamos direccion de memoria de la palabra
            SUB x13, x7, x13   // hacemos una resta para saber si se encontraron las 6 letras
            CMP x13, #7         // al tener un desfase por el post index aqui LDRB w8, [x7], 1
                                // entonces debemos comparar con 7
            
            BEQ encontrado      // si llegamos al final quiere decir que si lo encontro

            ADD x10, x10, #8    // Aumentamos los bits para el desplazamiento en 8 unidades
            CMP x10, #64        // Si llegamos a los 64 bits de desplazamiento quiere decir que no encontro la letra
            BNE loop2
            B salir_funcion

    encontrado:
        MOV x12, 1 

    salir_funcion:
        LDP x29, x30, [SP], 16          // Recuperamos el valor de FP y LR de la pila
        RET                             // retornamos al flujo principal del programa
        .size buscar, (. - buscar)

_start:
    BL buscar
    CMP x12, #1
    BNE reg1
    MOV x0, 0b0011
    B end

    reg1:
        MOV x0, x1
        BL buscar
        CMP x12, #1
        BNE reg2
        MOV x0, 0b0100
        B end

    reg2:
        MOV x0, x2
        BL buscar
        CMP x12, #1
        BNE reg3
        MOV x0, 0b0101
        B end

    reg3:
        MOV x0, x3
        BL buscar
        CMP x12, #1
        BNE reg4
        MOV x0, 0b0110
        B end

    reg4:
        MOV x0, x4
        BL buscar
        CMP x12, #1
        BNE reg5
        MOV x0, 0b0111
        B end

    reg5:
        MOV x0, x5
        BL buscar
        CMP x12, #1
        BNE reg6
        MOV x0, 0b1000
        B end

    reg6:
        MOV x0, x6
        BL buscar
        MOV x0, 0b1001

    end:
        MOV x0, 0
        MOV x8, 93
        SVC 0
