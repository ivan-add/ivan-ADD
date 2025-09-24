#!/bin/bash
menu() {
        echo "1. bisiesto"
        echo "2. configurarred"
        echo "3. adivina"
        echo "4. buscar"
        echo "5. contar"
        echo "6. permisosoctal"
        echo "7. romano"
        echo "0. salir"
read -p "Escoge una opción " op
}
menu
case $op in
        0)
        echo "HAS SALIDO DEL SCRIPT"
        ;;
        1)
        read -p "Escribe un año " anio
        let anio--
        if [ $((anio % 4)) == 0 ]; then
           echo "El año pasado si era bisiesto  $anio "
        else
           echo "El año pasado no era bisiento  $anio "
        fi
        ;;
        2)
        read -p "Escribe una ip " ip
        read -p "Escribe una mascara " mask
        read -p "Escribe una puerta de enlace " gateway
        read -p "Escribe un dns " dns
        conf="/etc/netplan/50-cloud-init.yaml"
        cat > $conf <<net
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - $ip/$mask
      routes:
        - to: default
          via: $gateway
      nameservers:
        addresses:
          - $dns
net
        cat $conf > /etc/netplan/01-network-manager-all.yaml
        sleep 2
        netplan apply > /dev/null
        sleep 5
        ip addr
        ;;
        3)
        num=$(((RANDOM % 100) + 1))
        tries=0
        while [[ $tries -lt 5 && $n -ne $num ]]; do
            read -p "Di un numero aleatorio del 1 al 100: " n
            tries=$((tries + 1))
           echo " "
            if [ $n -gt $num ]; then
                echo "El numero Aleatoriamente puesto es menor a $n"
                echo "Este es tu intento numero $tries"
            elif [ $n -lt $num ]; then
                echo "El numero Aleatoriamente puesto es mayor a $n"
                echo "Este es tu intento numero $tries"
            elif [ $n -eq $num ]; then
                echo "Has Acertado era el numero $n"
                echo "Lo has conseguido en el intento numero $tries"
            fi
        done
        if [ $tries -eq 5 ] && [ $n -ne $num ]; then
           echo "Has Fallado era el numero $num"
        fi
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
	6)
	read -p
esac
