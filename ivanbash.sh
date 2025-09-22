#!/bin/bash
menu() {
echo "1. bisiesto"
echo "2. configurared"
echo "3. adivina"
echo "4. buscar"
echo "5. contar"
echo "6. permisosoctal"
echo "7. romano"
echo "0. salida"
read -p "Elige una opción " op
echo ""
}
menu
case $op in
	0)
	echo "Has salido del script"
	;;
	4)
	read -p "Escriba el nombre de un fichero " f
	busqueda=$(find / -type f -name "$f" 2>/dev/null)
	if [ -f "$busqueda" ]; then
 	    vocales=$(grep -o -i "[aeiouáéíóú]" $f | wc -l)
   	    echo "El archivo se encuentra en $busqueda y el archivo tiene un total de $vocales vocales"
	else
	    echo "No Existe el fichero $f"
	fi
	;;
	5)
	read -p "Contar cuantos ficheros hay en un directorio " d
	if [ -d "$d" ]; then
	   contar=$(find $d -type f | wc -l 2>/dev/null)
	   echo "Hay un total de $contar ficheros en el directorio $d"
	else
	   echo "El directorio $d no exite"
	fi
	;;
esac
