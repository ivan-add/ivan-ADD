#!/bin/bash

# Archivo de salida
archivo="errores.txt"

# Limpiamos el archivo si existe
> "$archivo"

# Recorremos todo /var/log
for log_file in /var/log/*; do
    # Verificamos si es un archivo
    if [ -f "$log_file" ]; then
        # Creamos una variable para comprobar si el archivo contiene errores
        comprobacion=$(grep -i -e "error" -e "fail" "$log_file" 2>/dev/null)

        # Comprobamos que contenga algún error; si es así, lo metemos dentro de errores.txt
        if [ -n "$comprobacion" ]; then
            # Identificamos el archivo con error
            echo "El siguiente archivo: $log_file contiene un error " >> "$archivo"

            # Añadir errores del archivo
            echo "$comprobacion" >> "$archivo"
	    echo "" >> "$archivo"
        fi
    fi
done

echo "Resultados guardados en: $archivo"
