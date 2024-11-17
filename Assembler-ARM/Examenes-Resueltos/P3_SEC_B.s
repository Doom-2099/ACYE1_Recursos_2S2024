// -------------- TERCER PARCIAL ARQUI 1 SECCION B -------------------------
// >> TEMA 1
// Asuma que x0 = 0x10 y que x2 = #6. Indique a la par de cada 
// comando que valores en base decimal tendran x0 y x1

    ADD x0, x0, x1              // x0 + x1 => 16 + 6 = 22 | x0 = 22, x1 = 6

    EOR x1, x0, x1              // x0 a binario => 0001 0110
                                // x1 a binario => 0000 0110
                                // x0 xor x1    => 0001 0000 => 16
                                // x0 = 22, x1 = 16

    MVN x1, x1                  // NOT (x1) => 0000 0000 0000 0000 (HEX)
                                //      ~x1 => FFFF FFFF FFFF FFEF (HEX)
                                // Para obtener valor en decimal, se usa complemento a 2 solo para obtener la magnitud
                                // C2(~x1) => 16 + 1 = 17 => valor de x1, conservando el signo = -17
                                // x0 = 22, x1 = -17

    MVN x0, x0                  // NOT (x0) => 0000 0000 0000 0000 (HEX)
                                //      ~x0 => FFFF FFFF FFFF FFE9 (HEX)
                                // Para obtener valor en decimal, se usa complemento a 2 solo para obtener la magnitud
                                // C2(~x0) => 22 + 1 = 23 => valor de x0, conservando el signo = -23
                                // x0 = -23, x1 = -17

    CMP x1, x0                  // se realiza la resta entre x1 y x0 | x1 - x0 | x0 = -23, x1 = -17

    CSNEG x1, x0, x1, GT        // El funcionamiento de esta instruccion es el siguiente:
                                // si x1 > x0:
                                    // x1 = x0
                                // si no:
                                    // x1 = NEG x1 => NEG -17 = 17
                                
                                // Segun la comparacion realizada en la linea anterior
                                // para modificar el registro de banderas -> -17 > -23 => verdadero
                                // entonces x1 = x0
                                // x0 = -23, x1 = -23
    
// -------------------------------------------------------------------------------------------------------------------
// >> TEMA 2
// Asuma que el registro x0 tiene asignado los 64 bits menos significativos de un numero de 128 bits
// titulado "a" y el registro x1 tiene asignado los 64 bits mas significativos de "a", por otro lado x2
// tiene asignado los 64 bits menos significativos de un numero de 128 bits titulado "b" y el registro
// x3 tiene asignado los 64 bits mas significativos de "b".
// Escriba la secuencia necesaria MAS CORTA de instrucciones para comparar "a" y "b" y afectar las respectivas banderas
// en el registro PSTATE

// Imaginemos que los numeros "a" y "b" se ven de la siguiente forma
// "a" |--- x1 ---|--- x0 ---| => longitud: 128 bits
//       Mas Sig.  Menos Sig.

// "b" |--- x3 ---|--- x2 ---| => longitud: 128 bits
//       Mas Sig.  Menos Sig.

// la operacion a realizar es una comparacion, que modifique los registros de las banderas.
// vamos a partir del concepto de como se hace una comparacion en ensamblador, que basicamente es una resta.

// Teniendo esto en mente, como se opera una resta normalmente? iniciando desde los numeros mas pequeños.
// Es decir que primero realizaremos la resta de las partes menos significativas, teniendo el cuidado de manejar
// correctamente el acarreo o prestamo. La pregunta es ahora, como hacemos esto, una resta que modifique las banderas?
// Pues sencillamente utilizando la instruccion SUBS

    SUBS x4, x0, x2

// En el caso de que ocurra un acarreo o prestamo, este bit quedara seteado para que lo podamos usar en las banderas
// Ahora el siguiente paso es como utilizar este prestamo con los bits mas significativos? pues utilizando la instruccion
// SBC que realiza una resta con acarreo, funcionando de la siguiente manera
    // SBC x4, x1, x3 ==> x1 - x3 - (bit Carry)
// En el caso de que haya quedado un prestamo de la resta anterior, entonces en esta nueva operacion se restara una unidad (1),
// caso contrario permanecera como un 0 y no ocurrira ningun prestamo. Asi pues la instruccion SBC modifica los registros de 
// banderas con lo cual se cumpliria con lo solcitado en el enunciado, quedando la solucion asi:

    SUBS x4, x0, x2
    SBC x4, x1, x3

// los resultados se almacenan en x4, recordando que una operacion de comparacion no modifica los valores originales, entonces
// al almacenar los resultados en x4 estamos manteniendo los numeros originales.

