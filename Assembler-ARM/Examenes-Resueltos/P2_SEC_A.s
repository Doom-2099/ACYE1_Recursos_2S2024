// -------------- SEGUNDO PARCIAL ARQUI 1 SECCION A -------------------------
// >> TEMA 1
// Que valores tendran x0 y x1 despues de cada una de las siguientes instrucciones
// De su respuesta en base 10, con excepcion de la instruccion ubicada en la sexta linea
// de arriba-abajo en la cual se debera de indicar el valor de x0 y x1 en base hexadecimal
// y de las primeras 2 que NO APLICA

    MOV x2, #4                  // Movemos a x2 el valor de 4
    MOV x3, #8                  // Movemos a x3 el valor de 8

    MOV x0, #3                  // Movemos a x0 el valor de 3 | x0 = 3, x1 = 0
    MOV x1, 0x7                 // Movemos a x1 el valor de 7 | x0 = 3, x1 = 7

    CMP x1, x0                  // Se realiza la comparacion x1 - x0 | x0 = 3, x1 = 7
                                // como 7 - 3 = 4, el bit de carry no se activa

    CSINV x1, x2, x3, CS        // El funcionamiento de la instruccion es el siguiente:
                                // Si Carry == 1 entonces:
                                //      x1 = x2
                                // si no:
                                //      x1 = NOT(x3)
                                // Como el carry es igual a 0 entonces se ejecuta lo siguiente:
                                // x3 en binario       => 0000 0000 0000 0008 (HEX)
                                // NOT (x3) en binario => FFFF FFFF FFFF FFF7 (HEX)
                                // Para obtener valor en decimal, se usa complemento a 2 solo para obtener la magnitud
                                // C2(~x3) => 8 + 1 = 9 => valor de x3, conservando el signo = -9
                                // Posteriormente este valor se asigna a x1 <- -9
                                // x0 = 3, x1 = -9
                                
    
    MVN x1, x1                  // x1 en binario       => FFFF FFFF FFFF FFF7 (HEX)
                                // NOT (x1) en binario => 0000 0000 0000 0008 (HEX)
                                // x0 = 3, x1 = 8

    EOR x0, x1, 0x17            // x1 en binario   => 0000 1000
                                // 0x17 en binario => 0001 0111
                                // x1 xor 0x17     => 0001 1111
                                // 1F en decimal = 31
                                // x0 = 31, x1 = 8
    
    LSL x0, x1, #2              // Se hace el desplazamiento de dos bits a la izquierda del registro x1
                                // Es decir si se hace un desplazamiento de dos bits es como multiplicar *4
                                // x0 = x1 * 4 => 8 * 4 = 32
                                // x0 = 32, x1 = 8
// -------------------------------------------------------------------------------------------------------------------
// >> TEMA 2
// Diseñe un programa en lenguaje ensamblador ARM64 que sea capaz de desarrollar la siguiente funcion:
// - Desarrollar la suma aritmetica de dos numeros de 64 bits que han sido previamente alojados en los registros x0 y x1
//      asuma que ellos pueden, al sumarse, proveer un resultado que supere los 64 bits, entonces, previniendo esto usted,
//      debera de asegurar el resultado. El resultado se debera de guardar en memoria de dato (.data) para ello proceda dentro
//      del mismo programa pedido a solicitar el area de memoria de dato y ahorrando celdas de memoria proceda a guardar el
//      resultado generado sobre 64 bits con una variable del mismo tamaño asociado a una etiqueta titulada "curres" y para
//      el resultado que supere los 64 bits la variable adecuada respaldada en memoria de datos con una etiqueta titulada
//      "resresu"
// - Trabajar el cuerpo principal del programa pedido como una subrutina (funcion) tomando los cuidados pertinentes, 
//      incluya al final de la funcion la directriz "size"

.data
curres:     .quad 0             // Reservamos memoria para los 64 bits menos significativos
resresu:    .byte 0             // Reservamos un byte para manejar el desbordamiento de 64 bits
                                // Luego de realizar una suma entre dos numeros de 64 bits, se puede dar un desbordamiento
                                // de un bit, por lo que con reservar un byte de memoria es suficiente para manejar
                                // este desbordamiento tomando en consideracion el ahorro de celdas de memoria

.text
.type   main, %function
.global main

main:
    STP x29, x30, [SP, #-16]!       // Almacenamos el valor de FP y LR en la pila

    MOV x3, #0                      // Movemos 0 al registro x3 para poder capturar el acarreo

    // x0 y x1 ya tienen los valores almacenados
    ADDS x0, x0, x1                 // Realizamos la suma, alterando el registro de banderas

    ADC x1, x3, xzr                 // Capturamos el acarreo, en el caso de que existiera
                                    // x1 = x3 + 0 + Carry

    // Procedemos a almacenar los valores en la memorias
    ADR x2, curres                  // Cargamos la direccion de la variable curres en x2
    STR X0, [x2]                    // Almacenamos el resultado de 64 bits que se encuentra en x0

    ADR x2, resresu                 // Cargamos la direccion de la variable resresu en x2
    STRB x1, [x2]                   // Almacenamos el resultado de 8 bits que se encuentra en x1
                                    // Es decir, almacenamos el acarreo independientemente de si es un 1 o 0

    LDP x29, x30, [SP], 16          // Recuperamos el valor de FP y LR de la pila
    RET                             // retornamos al flujo principal del programa
    .size main, (. - main)