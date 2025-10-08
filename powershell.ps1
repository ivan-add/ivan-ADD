function pizza {
    do {  
        $pi = Read-host "¿Que pizza quieres vegetariana(1) o no vegetariana(2)? (0 para salir)"
        if ($pi -eq "1") {
            Write-Host "Has escogido la pizza vegetariana"
            do {
                Write-Host "1. Pizza con Pimiento"
                Write-Host "2. Pizza con tofu"
                Write-Host "0. Salir"
                   $op = Read-Host "¿Que pizza quieres?" 
                switch ($op) {
                    "1" {
                        Write-Host "Has escogido la pizza con pimiento"
                        Write-Host "Así que Has escogido una pizza vegetariana con pimiento, mozzarella y tomate"
                    }
                    "2" {
                        Write-Host "Has escogido la pizza con tofu"
                        Write-Host "Así que Has escogido una pizza vegetariana con tofu, mozzarella y tomate"
                    }
                    "0" {
                        $pi = 0
                        break
                    }
                }
            } while ($op -ne "0")
        }
        elseif ($pi -eq "2") {
            Write-Host "Has escogido la pizza no vegetariana"
            do {
                Write-Host "1. peperoni"
                Write-Host "2. Jamon"
                Write-Host "3. Salmon"
                Write-Host "0. Salir"
                $op = Read-Host "Que pizza quieres"
                switch ($op) {
                    "1" {
                        Write-Host "Has escogido la pizza con peperoni"
                        Write-Host "Así que Has escogido una pizza no vegetariana con peperoni, mozzarella y tomate"
                    }
                    "2" {
                        Write-Host "Has escogido la pizza con Jamon"
                        Write-Host "Así que Has escogido una pizza no vegetariana con Jamon, mozzarella y tomate"
                    }
                    "3" {
                        Write-Host "Has escogido la pizza con Salmon"
                        Write-Host "Así que Has escogido una pizza no vegetariana con Salmon, mozzarella y tomate"
                    }
                    "0" {
                        $pi = 0
                        break
                    }
            
                }
            } while ($op -ne "0")
        }
        elseif ($pi -ne "0") {
            Write-Host 'Escribe "1", "2" o "0" para seleccionar una pizza o salir del script'
            continue
        }
    } while ($pi -ne "0")
    Write-Host "Has salido de la selección de pizzas"
}

function dias {
    Write-Host "Los dias pares e impares del año en un año biesto son: "
    $dia31 = 31
    $dia30 = 30
    $dia29 = 29
    $pares = 0
    $impares = 0
    $pares31 = 0
    $impares31 = 0
    $pares30 = 0
    $impares30 = 0
    $pares29 = 0
    $impares29 = 0
    for ($i=0; $i -lt $dia31) {
        if (($dia31 % 2) -eq 0) {
            $dia31 --
            $pares31 = $pares31 + 1
        }
        else {
            $dia31 = $dia31 - 1
            $impares31 = $impares31 + 1
        }  
    }
 
    for ($i=0; $i -lt $dia30) {
        if (($dia30 % 2) -eq 0) {
            $dia30 --
            $pares30 = $pares30 + 1
        }
        else {
            $dia30 = $dia30 - 1
            $impares30 = $impares30 + 1
        }  
    }

    for ($i=0; $i -lt $dia29) {
        if (($dia29 % 2) -eq 0) {
            $dia29 --
            $pares29 = $pares29 + 1
        }
        else {
            $dia29 = $dia29 - 1
            $impares29 = $impares29 + 1
        }  
    }
    $pares = ($pares31 * 7) + ($pares30 * 4) + $pares29
    $impares = ($impares31 * 7) + ($impares30 * 4) + $impares29
    Write-Host = "Hay $pares dias pares y $impares dias impares"
}

function menu_usuario {
    do {
        Write-Host " "
        Write-Host "1. Listar usuarios"
        Write-Host "2. Crear usuarios"
        Write-Host "3. Eliminar usuarios"
        Write-Host "4. Modificar usuarios"
        Write-Host "0. Salir"
        Write-Host " "
        $op = Read-Host "Cual opción quieres coger: "
        switch ($op) {
            "1" {
                $listar = Get-LocalUser
                Write-host "Usuario: $listar"
            }
            "2" {
                try {
                    $user = Read-Host "Nombre del nuevo usuario"
                    $pass = Read-Host "Escriba una contraseña segura para el usuario"
                    $password = ConvertTo-secureString $pass -AsPlainText -force
                    New-LocalUser -name $user -Password $password -ErrorAction Stop
                    Write-Host "Se ha creado el usuario "
                }
                catch {
                    Write-Host "Error al crear el usuario:"
                }
            }
            "3" {
                try {
                    $user = Read-host "Dime un usuario para eliminar"
                    Remove-LocalUser $user -ErrorAction Stop
                    Write-Host "Se a eliminado al usuario $user $delete"
                }
                catch {
                    Write-Host "Error al eliminar el usuario:"
                }
            }   
            "4" {
                try {
                    $user = Read-host "Dime un usuario para modificar el nombre "
                    $newname = Read-Host "Dime el nuevo nombre que le quieres poner "
                    Rename-LocalUser -Name $user -NewName $newname -ErrorAction Stop
                    Write-Host "Se a cambiado el nombre de usuario de $user a $newname "
                }
                catch {
                    Write-Host "Error al modicar el usuario:"
                }
            }   
            "0" {
                Write-Host "Has salido del script"
            }  
        }

    } while ($op -ne 0) 
}

function menu_grupos {
    do {
    Write-Host "Menu de grupos"
    Write-Host "1. Listar grupos y miembros"
    Write-Host "2. Crear grupo"
    Write-Host "3. Eliminar grupo"
    Write-Host "4. Crear miembro de un grupo"
    Write-Host "5. Eliminar miembro de un grupo"
    Write-Host "0. Salir"
    $op = Read-Host "Escoge una de las opciones"

    switch ($op) {
        "1" {
            $grupos = Get-ADGroup -Filter *
            Foreach ($g in $grupos) {
                Write-Host "Grupo: $($g.Name)"
                $miembros = Get-ADGroupMember -Identity $g.Name
                if ($miembros) {
                    foreach ($m in $miembros) {
                    Write-Host "   -> $($m.Name)"
                }
                } 
                else {
                    Write-Host "   (Sin miembros)"
                }
            }
        }
        "2" {
            $name = Read-Host "Dime el nombre que le quieres poner al nuevo grupo: "
            New-ADGroup -Name $name -SamAccountName $name -GroupScope Global
            Write-Host "Se a creado el grupo $name"
        }
        "3" {
            $gr = Read-Host "Introduce el nombre de un grupo para eliminar"
            # $saber_si_existe = if (Get-ADGroup -Filter "Name -eq '$nombre'" -ErrorAction SilentlyContinue)
            Remove-ADGroup -Identity $gr -Confirm:$false
            Write-Host "Se ha eliminado el grupo $gr"
        }
        "4" {
            $grupo = Read-Host "Introduce el nombre del grupo"
            $user = Read-Host "Introduce el miembro a crear"
            Add-ADGroupMember -Identity $grupo -Members $user
            Write-Host "Usuario $user añadido al grupo $grupo."
        }
        "5" {
            $grupo = Read-Host "Introduce el nombre del grupo"
            $user = Read-Host "Introduce el miembro a crear"
            Remove-ADGroupMember -Identity $grupo -Members $user -Confirm:$false
            Write-Host "Usuario $user eliminado del grupo $grupo."
        }
        "0" {
            Write-Host "Has salido del script"
        }
    }

    }while ($op -ne 0)
}

function diskp {
    #Mostramos los discos
    Write-Host "Mostar los discos disponibles:"
    Get-Disk | Select-Object Number, FriendlyName, Size | Format-Table -AutoSize
    # Pide el número de disco
    $numero = Read-Host "Introduce el número del disco a utilizar"

    # Obtiene el tamaño del disco en GB
    $tamano = (Get-Disk -Number $numero).Size / 1GB
    Write-Host "El tamaño del disco es de $([math]::Round($tamano)) GB"

    # Calcula cuántas particiones de 1GB caben
    $numParticiones = [math]::Floor($tamano)
    Write-Host "$numParticiones"
    # Crea script temporal para Diskpart
    $ruta = "$env:TEMP\diskp_script.txt"
    Set-Content $ruta "select disk $numero"
    Add-Content $ruta "clean"
    Add-Content $ruta "convert gpt"

    # Crea particiones de 1GB hasta llenar el disco
    for ($i = 1; $i -le $numParticiones; $i++) {
        Add-Content $ruta "create partition primary size=1024"
    }

    Add-Content $ruta "exit"

    # Ejecuta Diskpart
    diskpart /s $ruta
}

function contraseña {
    $password = Read-Host "Introduce la contraseña a comprobar si pasa los parámetros de seguridad" -AsSecureString
    $pass = [System.net.NetworkCredential]::new("",$password).Password
    $validar = $true

    if ($pass.Length -lt 8) {
        Write-Host "La contraseña debe tener al menos 8 caracteres."
        $validar = $false
    }

    if ($pass -cnotmatch "[A-Z]") {
        Write-Host "La contraseña debe contener al menos una letra mayúscula."
        $validar = $false
    }

    if ($pass -cnotmatch "[a-z]") {
        Write-Host "La contraseña debe contener al menos una letra minúscula."
        $validar = $false
    }

    if ($pass -notmatch "[0-9]") {
        Write-Host "La contraseña debe contener al menos un número."
        $validar = $false
    }

    if ($pass -notmatch "[^a-zA-Z0-9]") {
        Write-Host "La contraseña debe contener al menos un carácter especial."
        $validar = $false
    }

    if ($validar -eq $true) {
        Write-Host "Contraseña válida."
    } else {
        Write-Host "Contraseña no válida."
    }
}

function Fibonacci {
    $try = Read-Host "¿Cuántas veces quieres repetir el Fibonacci?"
    $times = $try -as [int]

    if ($times -isnot [int]) {
        Write-Host "Debes escribir un número entero."
    } else {
        $num1 = 0
        $num2 = 1

        Write-Host "Secuencia de Fibonacci:"
        for ($i = 1; $i -le $times; $i++) {
            Write-Host $num1
            $next = $num1 + $num2
            $num1 = $num2
            $num2 = $next
        }
    }
}

function Fibonacci_recursividad {
    function Get-Fibonacci {
        param([int]$n)
        if ($n -le 0) { return 0 }
        elseif ($n -eq 1) { return 1 }
        else { return (Get-Fibonacci ($n - 1)) + (Get-Fibonacci ($n - 2)) }
    }

    $try = Read-Host "¿Cuántos números quieres mostrar? (comienza en 0)"
    $times = $try -as [int]
    if ($times -isnot [int]) { Write-Host "Debes escribir un número entero." ; exit }

    for ($i = 0; $i -lt $times; $i++) {
        Write-Host (Get-Fibonacci $i)
    }
}

function monitoreo {
    $totalUso = 0
    $contador = 0
    Write-Host "Iniciando monitoreo de CPU durante 30 segundos..."
    for ($i = 1; $i -le 6; $i++) {
        # Obtiene el uso de CPU con WMI/CIM (método compatible)
        $usoCPU = (Get-CimInstance Win32_Processor).LoadPercentage
        $usoCPU = [math]::Round(($usoCPU | Measure-Object -Average).Average, 2)

        Write-Host "Medición $i : $usoCPU %"

        $totalUso += $usoCPU
        $contador++

        Start-Sleep -Seconds 5
    }
    # Calcula el promedio
    $promedio = [math]::Round(($totalUso / $contador), 2)

    Write-Host "-----------------------------------------------"
    Write-Host "Promedio de uso de CPU: $promedio %"
}

function alertaEspacio {
    # Definir la ruta y el nombre del archivo de log
    $logFile = Read-Host "Dame una ruta para guardar los log en archivo terminado en .log"

    # Verificar si el archivo de log ya existe, si no, crear uno
    if (-Not (Test-Path -Path $logFile)) {
        # Crear el archivo vacío si no existe
        New-Item -Path $logFile -ItemType File -Force
        Write-Host "El archivo de log no existía y ha sido creado en: $logFile"
    } else {
        Write-Host "El archivo de log ya existe en: $logFile"
    }

    # Función para verificar el espacio en disco
    
    $discos = Get-WmiObject Win32_LogicalDisk
    
    foreach ($disco in $discos) {
        $espacioLibre = [math]::round(($disco.FreeSpace / $disco.Size) * 100, 2)  # Porcentaje de espacio libre
        
        if ($espacioLibre -lt 10) {
            # Alerta en pantalla
            Write-Host "¡ALERTA! El disco $($disco.DeviceID) tiene solo $espacioLibre% de espacio libre."
            
            # Escribir el mensaje en el archivo de log
            $mensajeLog = "$(Get-Date) - ALARMA: El disco $($disco.DeviceID) tiene solo $espacioLibre% de espacio libre."
            Add-Content -Path $logFile -Value $mensajeLog
        }
    }
}

function copiasMasivas {
    # Ruta base de perfiles de usuario
    $usuariosPath = "C:\Users"

    # Ruta donde se guardarán las copias comprimidas
    $destino = "C:\CopiasSeguridad"

    # Crear el directorio de destino si no existe
    if (-not (Test-Path -Path $destino)) {
        New-Item -ItemType Directory -Path $destino
    }

    # Obtener carpetas de usuario 
    $carpetasUsuarios = Get-ChildItem -Path $usuariosPath -Directory 

    # Recorrer cada carpeta de usuario
    foreach ($usuario in $carpetasUsuarios) {
        $nombreUsuario = $usuario.Name
        $rutaOrigen = Join-Path $usuariosPath $nombreUsuario
        $rutaDestinoZip = Join-Path $destino "$nombreUsuario.zip"

        Write-Host "Comprimiendo perfil de usuario: $nombreUsuario"

        # Comprimir carpeta del perfil
        Compress-Archive -Path $rutaOrigen -DestinationPath $rutaDestinoZip -Force
    }

    Write-Host "Copias de seguridad completadas correctamente."
}

function automatizarps {
    # Script automatizarps.ps1
    $rutaUsuarios = "C:\Users"

    # Obtener archivos del directorio
    $archivos = Get-ChildItem $rutaUsuarios -File

    # Comprobar si está vacío
    if ($archivos.Count -eq 0) {
        Write-Host "Listado vacío - No hay archivos en $rutaUsuarios"
        exit
    }

    # Procesar cada archivo
    foreach ($archivo in $archivos) {
        $nombreUsuario = $archivo.BaseName
        $rutaArchivo = $archivo.FullName
    
        Write-Host "Procesando usuario: $nombreUsuario"
    
        # Crear usuario local
        New-LocalUser -Name $nombreUsuario -NoPassword
        Write-Host "Usuario $nombreUsuario creado correctamente"
        
        # Leer carpetas desde el archivo
        $carpetas = Get-Content $rutaArchivo
        
        # Crear cada carpeta en el directorio del usuario
        foreach ($carpeta in $carpetas) {
            if ($carpeta) {
                $rutaCarpeta = "C:\Users\$nombreUsuario\$carpeta"
                New-Item -Path $rutaCarpeta -ItemType Directory -Force
                Write-Host "Carpeta creada: $carpeta"
            }
        }
        
            # Borrar el archivo
            Remove-Item $rutaArchivo -Force
            Write-Host "Archivo $nombreUsuario eliminado"
        
    }

    Write-Host "Proceso completado"
}

function barrido {
    # Script barrido.ps1
    param(
        [string]$Red = "192.168.1.0/24"
    )

    # Validar formato de red
    if ($Red -notmatch "^(\d+\.\d+\.\d+\.\d+)/(\d+)$") {
        Write-Host "Error: Usa formato CIDR como 192.168.1.0/24"
        exit
    }

    $partes = $Red -split "/"
    $baseIP = $partes[0]
    $bits = [int]$partes[1]

    # Calcular rango de IPs
    $totalIPs = [math]::Pow(2, (32 - $bits))
    $ipsActivas = @()

    Write-Host "Escaneando $totalIPs IPs en la red $Red"

    # Probar cada IP
    for ($i = 1; $i -lt $totalIPs - 1; $i++) {
        $ip = "$baseIP.$i"
    
        # Mostrar progreso
        if ($i % 50 -eq 0) {
            Write-Host "Probando IP: $ip - Progreso: $i/$($totalIPs-2)"
        }
    
        # Hacer ping (versión compatible)
        $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet
    
        if ($ping) {
            Write-Host "$ip - ACTIVA"
            $ipsActivas += $ip
        }
    }

    # Guardar resultados
    $fecha = Get-Date -Format "yyyyMMdd-HHmmss"
    $archivo = "ips_activas_$fecha.txt"

    $ipsActivas | Out-File $archivo
    Write-Host "`nResultados guardados en: $archivo"
    Write-Host "IPs activas encontradas: $($ipsActivas.Count)"
    Write-Host "Archivo guardado en: $(Get-Location)\$archivo"
}

function evento {
    $cantidad = 200
    $logs = "System", "Application"
    $eventos = foreach ($log in $logs) {
        Get-EventLog -LogName $log -EntryType Error,Warning
    }
    $eventos = $eventos | Sort-Object TimeGenerated -Descending | Select-Object -First $cantidad
    $eventos | Export-Csv -Path "eventos_$(Get-Date -Format 'yyyyMMdd-HHmmss').csv" -NoTypeInformation
    Write-Host "Eventos exportados: $($eventos.Count)"
    $archivo = "$eventos_$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    Write-Host "Archivo guardado en: $(Get-Location)\$archivo"
}

function agenda {
    # Crear diccionario vacío
    $agenda = @{}

    do {
        Write-Host "1. Añadir / Modificar contacto"
        Write-Host "2. Buscar contacto"
        Write-Host "3. Borrar contacto"
        Write-Host "4. Listar contactos"
        Write-Host "0. Salir"
        $opcion = Read-Host "Selecciona una opción (0-4)"

        switch ($opcion) {

            #AÑADIR / MODIFICAR
            "1" {
                $nombre = Read-Host "Introduce el nombre"
                if ($agenda.ContainsKey($nombre)) {
                    Write-Host "Teléfono actual: $($agenda[$nombre])"
                    $respuesta = Read-Host "¿Quieres modificarlo? (s/n)"
                    if ($respuesta -eq "s") {
                        $telefono = Read-Host "Introduce el nuevo teléfono"
                        $agenda[$nombre] = $telefono
                        Write-Host "Contacto actualizado."
                    } else {
                        Write-Host "No se ha modificado el contacto."
                    }
                } else {
                    $telefono = Read-Host "Introduce el teléfono"
                    $agenda[$nombre] = $telefono
                    Write-Host "Contacto añadido."
                }
            }

            #BUSCAR
            "2" {
                $cadena = Read-Host "Introduce el texto a buscar (inicio del nombre)"
                $resultados = $agenda.Keys | Where-Object { $_ -like "$cadena*" }

                if ($resultados.Count -gt 0) {
                    Write-Host "`n--- RESULTADOS DE BÚSQUEDA ---"
                    foreach ($nombre in $resultados) {
                        Write-Host "$nombre : $($agenda[$nombre])"
                    }
                } else {
                    Write-Host "No se encontraron contactos que comiencen por '$cadena'."
                }
            }

            #BORRAR
            "3" {
                $nombre = Read-Host "Introduce el nombre a borrar"
                if ($agenda.ContainsKey($nombre)) {
                    $confirmar = Read-Host "¿Seguro que quieres borrarlo? (s/n)"
                    if ($confirmar -eq "s") {
                        $agenda.Remove($nombre)
                        Write-Host "Contacto eliminado."
                    } else {
                        Write-Host "No se ha eliminado el contacto."
                    }
                } else {
                    Write-Host "El contacto no existe."
                }
            }

            #LISTAR
            "4" {
                if ($agenda.Count -eq 0) {
                    Write-Host "La agenda está vacía."
                } else {
                    Write-Host "`n--- LISTA DE CONTACTOS ---"
                    foreach ($nombre in $agenda.Keys) {
                        Write-Host "$nombre : $($agenda[$nombre])"
                    }
                }
            }

            #SALIR
            "0" {
                Write-Host "Has salido del programa."
            }
        }

    } while ($opcion -ne "0")
}

function menu {
    do {
        Write-Host "--- MENU ---"
        Write-Host "1. pizza "
        Write-Host "2. dias"
        Write-Host "3. menu_usuario"
        Write-Host "4. menu_grupos"
        Write-Host "5. diskp"
        Write-Host "6. contraseña"
        Write-Host "7. Fibonacci"
        Write-Host "8. Fibonacci_recursividad"
        Write-Host "9. monitoreo"
        Write-Host "10. alertaEspacio"
        Write-Host "11. copiasMasivas"
        Write-Host "12. automatizarps"
        Write-Host "13. barrido"
        Write-Host "14. evento"
        Write-Host "15. agenda"
        Write-Host "0. Salir"
        Write-Host "------------"
        $op = Read-Host "Elige una opcion"
        switch ($op) {
            "1"  { pizza; pause }
            "2"  { dias; pause }
            "3"  { menu_usuario; pause }
            "4"  { menu_grupos; pause }
            "5"  { diskp; pause }
            "6"  { contraseña; pause }
            "7"  { Fibonacci; pause }
            "8"  { Fibonacci_recursividad; pause }
            "9"  { monitoreo; pause }
            "10" { alertaEspacio; pause }
            "11" { copiasMasivas; pause }
            "12" { automatizarps; pause }
            "13" { barrido; pause }
            "14" { evento; pause }
            "15" { agenda; pause }
            "0"  { Write-Host "Has salido del Menu"}       
        }
    } while ($op -ne 0)
}
menu
