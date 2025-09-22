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
read -p "Elige una opción" op
echo ""
}
menu
case $op == 0 in
	0)
	echo "Has salido del script"
	;;
	3)
	num=$(( (RANDOM % 100) + 1))
	tries=0
	while [[ $tries -le 5  || $n -ne num ]]; do
     	   read -p "Di un numero aletorio del 1 al 100" n
	   intentos++
	   if [ $n -gt $num ]; then
	      echo "El numero Aleatoriamente puesto es menor a $n"
	      echo "Este es tu intento numero $intentos"
	   fi

	;;
esac
