PASOS PARA LA EJECUCION DEL CODIGO ENSAMBLADOR ARM
    1. Crear su archivo sh
    2. Crear el codigo fuente
    3. Ensamblar, Enlazar y Ejecutar el codigo con el comando "./compilar" o "sh compilar.sh"

Contenido ARM
    DIRECTIVAS
- .global: directiva para indicar el punto de inicio de nuestro programa
- .data: directiva que indica al ensamblador que inicia la seccion de datos que se encuentran en la memoria
- .asciz: directiva indica que se trata de una cadena de caracteres ASCII con el caracter nulo '\0' al final.
- .text: directiva que indica al ensamblador el inicio del segmento de codigo
- .(punto): devuelve el valor actual de la memoria en donde se encuentra este caracter.
- .space: directiva que inicializa con cualquier valor la cantidad de BYTES especificada
- .bss: directiva que indica el inicio del segmento de variables sin inicializar

    ETIQUETAS:
las etiquetas con palabras que hacen referencia a una direccion de memoria en el programa. 
Debe iniciar con un caracter o _ y esta puede estar formada por letras minusculas, mayusculas, numeros y guines bajos.
En el caso de referenciar una etiqueta esta debe tener el mismo nombre con el que se ha declarado. estas etiquetas son sensibles a
los caracteres en mayusculas.

    INSTRUCCIONES:
- MOV: Esta instruccion mueve un valor entre registros. permite los siguientes formatos
    MOV reg, reg
    MOV reg, inmediato

- LDR: Cargar un valor de 64 bits desde la memoria hacia el registro.

- LDRB: Cargar un byte desde la memoria hacia el registro

- CMP: Instruccion que realiza una resta entre los dos valores especificados pero no almacena el resultado, unicamente sirbe para alterar el registro de las banderas

- SVC 0: Instruccion que invoca la llamada al sistema, con los parametros configurados en los registros correspondientes.

    MACROS
Son similares a los metodos en los lenguajes de alto nivel. Recibe unos parametros y realiza una accion sin devolver ningun valor en especifico.
La estructura de los macros es la siguiente:
    .macro NombreMacro [Lista De Argumentos]
        // Instrucciones
        // Instrucciones
    .endm

        Ejemplo:
            .macro print text, cantidadChars
                MOV x0, 1
                LDR x1, =\text
                LDR x2, =\cantidadChars
                MOV x8, 64
                SVC 0 
            .endm

Estos macros deben definirse antes de la etiqueta inicial del programa. Es decir antes de la etiqueta _start

    SALTOS
Existen saltos condicionales y saltos no condicionales. Los saltos no condicionales, no tienen restriccion alguna y no 
dependen del registro de las banderas. Unicamente cambia la direccion de memoria de la ejecucion del programa a otra.
Los saltos condicionales, dependen del registro de banderas para realizar el salto, es decir que toma una decision basada
en el registro de banderas para saber como actuar.

        - salto incondicional: B nombre_etiqueta
        - salto condicional: BCondicion nombre_etiqueta
            - BEQ: saltar si es igual
            - BNE: saltar si NO es igual
            - BHS: saltar si op1 es mayor o igual que op2
            - BGT: saltar si es mayor
            - BLT: salta si es menor
            - BGE: saltar si es mayor o igual(operadores con signo)
            - BLE: saltar si es menor o igual(operadores con signo)
            - BMI: si el operador es negativo o menor a 0
            - BPL: si el operador es mayor o igual a 0
        