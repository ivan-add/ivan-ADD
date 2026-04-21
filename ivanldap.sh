#!/bin/bash

DOMINIO="dc=ivan2025,dc=ldap"
ADMIN="cn=admin,$DOMINIO"

eliminar_correo() {
    read -p "Nombre del usuario: " NOMBRE
    read -p "Unidad Organizativa: " OU
    USUARIO="cn=$NOMBRE,ou=$OU,$DOMINIO"

    cat <<EOF > temp_del.ldif
dn: $USUARIO
changetype: modify
delete: mail
EOF

    ldapmodify -x -D "$ADMIN" -W -f temp_del.ldif
    rm -f temp_del.ldif
}

modificar_correo() {
    read -p "Nombre del usuario: " NOMBRE
    read -p "Unidad Organizativa: " OU
    USUARIO="cn=$NOMBRE,ou=$OU,$DOMINIO"
    read -p "Nuevo correo electronico: " CORREO

    cat <<EOF > temp_mod.ldif
dn: $USUARIO
changetype: modify
replace: mail
mail: $CORREO
EOF

    ldapmodify -x -D "$ADMIN" -W -f temp_mod.ldif
    rm -f temp_mod.ldif
}

busquedas() {
    echo ""
    echo "1. Consultar un usuario concreto"
    echo "2. Listar todos los usuarios"
    read -p "Elige opcion (1/2): " OPCION_BUSQ

    if [ "$OPCION_BUSQ" == "1" ]; then
        read -p "Nombre del usuario: " NOMBRE
        echo ""
        ldapsearch -x -LLL -b "$DOMINIO" "(cn=$NOMBRE)" cn mail
    elif [ "$OPCION_BUSQ" == "2" ]; then
        echo ""
        echo "... LISTADO DE USUARIOS (nombre y correo) ---"
        ldapsearch -x -LLL -b "$DOMINIO" "(objectClass=inetOrgPerson)" cn mail
    else
        echo "Opcion no valida. Intentalo de nuevo."
        busquedas
    fi
}

OPCION=1
while [ $OPCION -ne 4 ]; do
    echo ""
    echo "=========== GESTION LDAP ==========="
    echo "1) Eliminar correo de usuario"
    echo "2) Modificar correo de usuario"
    echo "3) Realizar busquedas"
    echo "4) Salir"
    echo "================================="
    read -p "Elige opcion: " OPCION

    case $OPCION in
    1) eliminar_correo ;;
    2) modificar_correo ;;
    3) busquedas ;;
    4) echo "Saliendo..." ;;
    *) echo "Opcion no valida";;
    esac
done
