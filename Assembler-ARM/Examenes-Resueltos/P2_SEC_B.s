// -------------- SEGUNDO PARCIAL ARQUI 1 SECCION B -------------------------
// >> TEMA 1
// Asuma que en el area de datos existe una etiqueta titulada NUMS y bajo ella hay 8 diferentes numeros de tamaño 
// word todos ellos son considerados sin signo. Proceda a diseñar un programa en lenguaje ensamblador ARM64 por medio 
// del cual se detecte cual de estos numeros es mas pequeño en ponderacion y para finalizar almacenelo en el area de
// memoria con una etiqueta BLYS que lo evidencie. Diseñe este programa como una funcion (subrutina) con las consideraciones
// especiales de manejo de los registros x29 y x30. Ademas no olvide mostrar como quedara tambien el area de memoria de datos
// tanto en su declaracion de peticion como en la ubicacion de las etiquetas, tanto de la entrada NUMS como la del resultado
// BYLS.

.data
NUMS:   .space 32   // reservamos 32 bytes de memoria para los numeros previamente alojados
BYLS:   .word   0   // reservamos un espacio de 32 bits de memoria para el valor menos ponderado

.text
.type   min, %function
.global min

min:
    STP x29, x30, [SP, #-16]!       // Almacenamos el valor de FP y LR en la pila

    ADR x0, NUMS                    // Cargamos la direccion de memoria de NUMS
    ADR x3, BYLS                    // Cargamos la direccion de memoria de BYLS que nos servira como condicion de parada del ciclo

    MOV w2, 0xFFFFFFFF              // Movemos un valor muy alto a w2 que servira de referencia para las comparaciones e
                                    // ir almacenando el valor menos ponderado

    LOOP:
        LDR w1, [x0], #4            // Cargamos numero por numero, haciendo un desplazamiento de 4 bytes(32 bits)
        
        CMP w1, w2                  // Comparamos con el numero "menos ponderado" al momento de la iteracion
        CSEL w2, w1, w2, LO         // Si w1 < w2 entonces:
                                    //      w2 = w1
                                    // si no:
                                    //      w2 = w2

        CMP x0, x3                  // Comparamos si hemos llegado al final de NUMS, ya que las celdas de memoria
                                    // entre NUMS y BYLS estan contiguas, la direccion de BYLS funciona como condicion de parada
        BNE LOOP                    // Si los valores no son iguales se mantiene en el ciclo

    STR w2, [x3]                    // Almacenamos el valor "menos ponderado" en la direccion de x3 que corresponde a BYLS
                                    // declarada unas lineas mas arriba
        
    LDP x29, x30, [SP], 16          // Recuperamos el valor de FP y LR de la pila
    RET                             // retornamos al flujo principal del programa
    .size min, (. - min)
// -------------------------------------------------------------------------------------------------------------------
// >> TEMA 2
// El siguiente comando en lenguaje C es un arreglo de cuatro enteros, e inicializa sus ubicaciones
// con los numeros 7, 3, 21, 10, justo en ese orden, abajo se muestra lo mencionado:
//      int nums [] = {7, 3, 21, 10}
// Proceda a escribir el programa necesario en ARM64 para cargar los 4 numeros dentro de los
// registros w3, w4, w5 y w6 respectivamente, usando para ello 4 instrucciones "LDR"

.data
nums: .word 7, 3, 21, 10    // Mostramos el arreglo de numeros declarado en la seccion de datos

.text
main:
    ADR x0, nums            // Cargamos la direccion de memoria de la etiqueta nums, que es
                            // donde se encuentran los numeros del arreglo, al ser de tipo int
                            // cada numero ocupa un espacio de 4 bytes, 
                            // importante conocer esta informacion para el desplazamiento

    LDR w3, [x0], #4        // Cargamos el primer numero al registro w3, luego actualizamos
                            // el apuntador de la memoria sumandole 4 bytes de salto.

    LDR w4, [x0], #4        // Cargamos el siguiente numero al registro w4, luego actualizamos
                            // el apuntador de la memoria sumandole 4 bytes de salto.

    LDR w5, [x0], #4        // Cargamos el siguiente numero al registro w5, luego actualizamos
                            // el apuntador de la memoria sumandole 4 bytes de salto.

    LDR w6, [x0]            // Cargamos el ultimo numero al registro w6, sin actualizar 
                            // el apuntador de la memoria