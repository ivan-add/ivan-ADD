#!/bin/bash

# Verificamos si el archivo existe
if [ ! -f "programas.txt" ]; then
    echo "Error: No se encuentra programas.txt"
else
	# Desinstalamos todos los programas que se encuentren en programas.txt
	sudo apt remove --purge -y $(cat programas.txt)
	#Limpiamos paquetes huerfanos
	sudo apt autoremove -y
    	echo "Programas eliminados"
fi
