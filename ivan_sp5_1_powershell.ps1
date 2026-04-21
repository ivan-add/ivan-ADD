# Creamos una funcion para mostrar la informacion del dominio
function Mostrar-InfoDominio {
    $dominio  = Get-ADDomain
    $ous      = (Get-ADOrganizationalUnit -Filter *).Count
    $grupos   = (Get-ADGroup -Filter *).Count
    $usuarios = (Get-ADUser  -Filter *).Count
 
    Write-Host "Nombre del equipo : $env:COMPUTERNAME"
    Write-Host "Nombre del dominio: $($dominio.DNSRoot)"
    Write-Host "Numero de OUs     : $ous"
    Write-Host "Numero de grupos  : $grupos"
    Write-Host "Numero de usuarios: $usuarios"
}
# Creamos una funcion para crear las OU  
function Crear-OU {
    $nombre = Read-Host "Nombre de la nueva OU"
    $path   = Read-Host "DN de la OU (ej: DC=ivan,DC=aws)"
    New-ADOrganizationalUnit -Name $nombre -Path $path
    Write-Host "OU '$nombre' creada correctamente."
}
# Creamos funcion para ver miembros de la OU
function Ver-MiembrosOU {
    $ouDN = Read-Host "DN de la OU (ej: OU=Prueba,DC=ivan,DC=aws)"
    Get-ADObject -Filter * -SearchBase $ouDN -SearchScope OneLevel -Properties Name, objectClass |
        Select-Object Name, objectClass | Format-Table -AutoSize
}
# Creamos una funcion para crear grupos 
function Crear-Grupo {
    $nombre = Read-Host "Nombre del grupo"
    $path   = Read-Host "DN de la OU donde crear el grupo (ej: OU=Prueba,DC=ivan,DC=aws)"
    New-ADGroup -Name $nombre -GroupScope Global -GroupCategory Security -Path $path
    Write-Host "Grupo '$nombre' creado correctamente."
}
# Creamos una funcion para crear los usuarios 
function Crear-Usuario {
    $nombre   = Read-Host "Nombre"
    $apellido = Read-Host "Apellidos"
    $sam      = Read-Host "Nombre de inicio de sesion (SAMAccountName)"
    $upn      = "$sam@$((Get-ADDomain).DNSRoot)"
    $pass     = Read-Host "Contrasena" -AsSecureString
    $path     = Read-Host "DN de la OU donde crear el usuario (ej: OU=Prueba,DC=ivan,DC=aws)"
    $grupo    = Read-Host "Nombre del grupo al que asignar el usuario"
 
    New-ADUser -GivenName $nombre `
               -Surname $apellido `
               -Name "$nombre $apellido" `
               -SamAccountName $sam `
               -UserPrincipalName $upn `
               -AccountPassword $pass `
               -Path $path `
               -Enabled $true `
               -ChangePasswordAtLogon $true
 
    Add-ADGroupMember -Identity $grupo -Members $sam
    Write-Host "Usuario '$sam' creado y anadido al grupo '$grupo'."
}
 
# Hacemos el Menu
do {
    Write-Host ""
    Write-Host "GESTION DE DOMINIO"
    Write-Host "1. Informacion del dominio"
    Write-Host "2. Crear Unidad Organizativa"
    Write-Host "3. Ver miembros de una OU"
    Write-Host "4. Crear grupo"
    Write-Host "5. Crear usuario"
    Write-Host "0. Salir"
    Write-Host ""
 
    $opcion = Read-Host "Selecciona una opcion"
 
    switch ($opcion) {
        "1" { Mostrar-InfoDominio }
        "2" { Crear-OU }
        "3" { Ver-MiembrosOU }
        "4" { Crear-Grupo }
        "5" { Crear-Usuario }
        "0" { Write-Host "Saliendo..." }
        default { Write-Host "Opcion no valida." }
    }
 
} while ($opcion -ne "0")
 