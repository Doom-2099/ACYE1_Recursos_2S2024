

def main():
    try:
        patron = 'B%1'
        patron_guardado = ''

        while True:
            patron_guardado += input(">> Ingrese Un Caracter: ")

            if(patron_guardado == patron):
                print("Patron Correcto")
                break;
    
            if(len(patron_guardado) == len(patron)):
                print("Patron Incorrecto")
                patron_guardado = ''

    except KeyboardInterrupt:
        print("\n>> Programa Terminado")

if __name__ == '__main__':
    main()


    