// -------------- TERCER PARCIAL ARQUI 1 SECCION A -------------------------
// >> TEMA 1
// En el lenguaje ensamblador ARM64, escriba una funcion que sea equivalente a la siguiente funcion
// en lenguaje C, asumiendo que a y b son numeros sin signo
// int max (int a, int b)
// {
//      if (a < b)
//          return a
//      return -b
// }

max:
    STP x29, x30, [SP, #-16]!   // almacenamos el FP y LR en la pila

    CMP x0, x1                  // se hace la comparcion entre x0 y x1 => x0 - x1

    CSNEG x0, x0, x1, LO        // si x0 = a  < x1 = b entonces:
                                //      x0 = x0
                                // si no:
                                //      x0 = -x1

    LDP x29, x30, [SP], 16      // recuperamos FP y LR de la pila
    RET                         // regresamos al flujo principal del programa
    .size max, (. - max)
// -------------------------------------------------------------------------------------------------------------------
// >> TEMA 2
// Escriba una funcion con todas sus formalidades en ARM64 que sea equivalente a la siguiente funcion
// en lenguaje C
// int minsix ( int a, int b, int c, int d, int e, int f)
// {
//      if (b < a)
//          a = b 
//      if (d < c)
//          c = d
//      if (c < a)
//          a = c
//      if (f < e)
//          e = f
//      if (e < a)
//          a = e
//      return a
// }

// Los parametros a utilizar son los siguientes:
// x0 = a | x1 = b | x2 = c | x3 = d | x4 = e | x5 = f

// realizando las condiciones como comparaciones y 
// actualizando valores con la instruccion CSEL, el codigo queda de la siguiente manera
minsix:
    STP x29, x30, [SP, #-16]!   // Guardamos FP y LR en la pila

    CMP x1, x0              // Realizamos la comparacion x1 - x0 (b y a)
    CSEL x0, x1, x0, LO     // Si b < a es verdadero:
                            // x0 <- x1 (se hace el cambio como lo indica el enunciado)
                            // si no:
                            // x0 <- x0 (se mantiene el valor original)

    CMP x3, x2              // Realizamos la comparacion x3 - x2 (d y c)
    CSEL x2, x3, x2, LO     // Si d < c es verdadero:
                            // x2 <- x3 (se hace el cambio como lo indica el enunciado)
                            // si no:
                            // x2 <- x2 (se mantiene el valor original)

    CMP x3, x0              // Realizamos la comparacion x3 - x0 (c y a)
    CSEL x0, x3, x0, LO     // Si c < a es verdadero:
                            // x0 <- x3 (se hace el cambio como lo indica el enunciado)
                            // si no:
                            // x0 <- x0 (se mantiene el valor original)

    CMP x5, x4              // Realizamos la comparacion x5 - x4 (f y e)
    CSEL x4, x5, x4, LO     // Si f < e es verdadero:
                            // x5 <- x4 (se hace el cambio como lo indica el enunciado)
                            // si no:
                            // x5 <- x5 (se mantiene el valor original)

    CMP x4, x0              // Realizamos la comparacion x4 - x0 (e y a)
    CSEL x0, x4, x0, LO     // Si e < a es verdadero:
                            // x0 <- x4 (se hace el cambio como lo indica el enunciado)
                            // si no:
                            // x0 <- x0 (se mantiene el valor original)

    LDP x29, x30, [SP], #16     // Recuperamos FP y LR de la pila
    RET                        // regresamos al Flujo principal
    .size minsix, (. - minsix)