#!/bin/bash
#Obtenemos el mes y el año y lo almacenamos en una variable
mes=$(date +"%B-%Y")
#Creamos una copia completa  de /home y se guardará con la fecha
tar -czf /bacivandestino/CopTot-$mes.tar.gz /home/
