# Primero definimos los parámetros que el script va a recibir

param(
    [string]$Accion,   # Este sería la accion a ejecutar (-G, -U, -M...)
    [string]$Param2,   # Segundo parámetro (Depende de la acción que se realize)
    [string]$Param3,   # Segundo tercero (Depende de la acción que se realize)
    [string]$Param4,   # Segundo cuarto (Depende de la acción que se realize)
    [switch]$DryRun    # Es opcional, solo sirve para simular las acciones sin que se llegue a ejecutar de verdad
)

# Creamos la función para mostrar la ayuda de cómo se usa el script (aparece si no se le pasa ningun parametro)

function Mostrar-Ayuda {

    Write-Host "`n=== MANUAL DEL SCRIPT DE IVAN Y AARÓN ===" -ForegroundColor Cyan
    Write-Host "Uso: .\aaronp-ivan02.ps1 -Accion <ACCION> [parametros]`n"
    Write-Host "Acciones disponibles:" -ForegroundColor Yellow

    Write-Host "  -G    : Crear grupo"
    Write-Host "          Parametros: -Param2 <Nombre> -Param3 <Ambito> -Param4 <Tipo>"
    Write-Host "          Ambito: Global, Universal, DomainLocal"
    Write-Host "          Tipo: Security, Distribution`n"
    
    Write-Host "  -U    : Crear usuario"
    Write-Host "          Parametros: -Param2 <Nombre> -Param3 <UO>"
    Write-Host "          Ejemplo: -Param2 'Juan' -Param3 'OU=Usuarios,DC=dominio,DC=com'`n"
    
    Write-Host "  -M    : Modificar usuario"
    Write-Host "          Parametros: -Param2 <Usuario> -Param3 <Contraseña> -Param4 <Habilitar/Deshabilitar>"
    Write-Host "          Ejemplo: -Param4 'Habilitar' o 'Deshabilitar'`n"
    
    Write-Host "  -AG   : Añadir usuario a grupo"
    Write-Host "          Parametros: -Param2 <Usuario> -Param3 <Grupo>`n"
    
    Write-Host "  -LIST : Listar objetos"
    Write-Host "          Parametros: -Param2 <Usuarios/Grupos/Ambos> -Param3 <UO opcional>`n"
    
    Write-Host "Opcion adicional:" -ForegroundColor Yellow
    Write-Host "  -DryRun : Simula las acciones sin ejecutarlas realmente`n"
}

# Función para generar la contraseña aleatoria del usuario
function Generar-Contraseña {

    $longitud = 12
    $caracteres = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%"
    $password = ""

    # Ponemos de rango máximo hasta 12 (valor de la variable longitud)
    for ($i = 0; $i -lt $longitud; $i++) {

    # Usamos un bucle for para que genere la contraseña seleccionando caracteres aleatorios de la variable caracteres y las añada a la variable contraseña
        $password += $caracteres[(Get-Random -Minimum 0 -Maximum $caracteres.Length)]
    }
    return $password   # Devolvemos la contraseña generada aleatoriamente
}

# Función para validar la complejidad de la contraseña
function Validar-Contraseña {

    param([string]$password)
    
    $valida = $true   # Definimos esta variable para definir si la contraseña es valida o no
    $errores = @()    # Creamos un array para guardar los errores encontrados
    
    if ($password.Length -lt 8) {   # Verificamos si cumple con la longitud mínima (8 caracteres)
        $valida = $false
        $errores += "Debe tener al menos 8 caracteres"
    }

    if ($password -notmatch "[A-Z]") {   # Verificamos si contiene al menos una mayuscula con -nomatch
        $valida = $false
        $errores += "Debe contener al menos una mayuscula"
    }

    if ($password -notmatch "[a-z]") {   # Verificamos si contiene al menos una minuscula con -nomatch
        $valida = $false
        $errores += "Debe contener al menos una minuscula"
    }

    if ($password -notmatch "[0-9]") {    # Verificamos si contiene al menos un numero con -nomatch
        $valida = $false
        $errores += "Debe contener al menos un numero"
    }
    
    return @{Valida = $valida; Errores = $errores}    # Devolvemos tanto el resultado de si es válida o no como los posibles errores encontrados
}

# Función para crear el grupo
function Crear-Grupo {

    # Definimos los parámetros de entrada de la función
    param([string]$nombre, [string]$ambito, [string]$tipo)
    
    Write-Host "`n--- CREACIÓN DE GRUPO ---" -ForegroundColor Green
    
    # En caso de usar DryRun mostramos solamente lo que pasaría
    if ($DryRun) {
        Write-Host "[DRY-RUN] Se crearia el grupo '$nombre' con ambito '$ambito' y tipo '$tipo'" -ForegroundColor Yellow
        return   #Al ser DryRun, no devolvemos nada para que no haga cambios reales
    }
    
    # Usamos try-catch para manejar los errores mejor
    try {
        
        # Buscamos si el grupo existe, en caso de que no ponemos -ErrorAction SilentlyContinue para que no devuelva el error
        $grupoExiste = Get-ADGroup -Filter "Name -eq '$nombre'" -ErrorAction SilentlyContinue
        
        # Verificamos si existe
        if ($grupoExiste) {
            Write-Host "El grupo '$nombre' ya existe en el sistema" -ForegroundColor Yellow
        
        # En caso de que no, lo creamos
        } else {
            New-ADGroup -Name $nombre -GroupScope $ambito -GroupCategory $tipo
            Write-Host "Grupo '$nombre' creado correctamente" -ForegroundColor Green
        }
        
        # En caso de que ocurra un error lo devolvemos.
    } catch {
        Write-Host "Error al crear el grupo: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Función para crear el usuario
function Crear-Usuario {
    
    # Definimos los parámetros de entrada de la función
    param([string]$nombre, [string]$uo)
    
    Write-Host "`n--- CREACIÓN DEL USUARIO ---" -ForegroundColor Green
    
    # Le ponemos de valor a la variable de contraseña el resultado de la función que creamos antes
    $password = Generar-Contraseña
    
    # En caso de que use dryrun mostramos lo que haría
    if ($DryRun) {
        Write-Host "[DRY-RUN] Se crearia el usuario '$nombre' en la UO '$uo'" -ForegroundColor Yellow
        Write-Host "[DRY-RUN] Contraseña generada: $password" -ForegroundColor Yellow
        return
    }
    
    try {

        # Verificamos si el usuario ya existe.
        $usuarioExiste = Get-ADUser -Filter "Name -eq '$nombre'" -ErrorAction SilentlyContinue
        
        # En caso de que existe, lo mostramos por pantalla para indicárselo al usuario
        if ($usuarioExiste) {
            Write-Host "El usuario '$nombre' ya existe en el sistema" -ForegroundColor Yellow

        } else {

            # En caso de que no exista, convertimos la contraseña de texto plano a SecureString
            $securePassword = ConvertTo-SecureString $password -AsPlainText -Force

            # Luego creamos al usuario
            New-ADUser -Name $nombre -Path $uo -AccountPassword $securePassword -Enabled $true
            Write-Host "Usuario '$nombre' creado correctamente" -ForegroundColor Green
            Write-Host "Contraseña generada: $password" -ForegroundColor Cyan
        }

    } catch {
        Write-Host "Error al crear el usuario: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Función para modificar a un usuario
function Modificar-Usuario {

    # Definimos los parámetros de entrada de la función
    param([string]$usuario, [string]$nuevaPassword, [string]$estado)
    
    Write-Host "`n--- MODIFICAR A UN USUARIO ---" -ForegroundColor Green
    
    # Validamos la contraseña usando la función que creamos anteriormente
    $validacion = Validar-Contraseña -password $nuevaPassword
    
    # En caso de que no sea válida mostramos el por que y salimos
    if (-not $validacion.Valida) {
        Write-Host "La contraseña no cumple los requisitos de complejidad:" -ForegroundColor Red

        foreach ($error in $validacion.Errores) {
            Write-Host "  - $error" -ForegroundColor Red
        }

        return   # No devolvemos nada.
    }
    
    # En caso de que use dryrun mostramos solamente lo que haría
    if ($DryRun) {

        Write-Host "[DRY-RUN] Se modificaria la contraseña del usuario '$usuario'" -ForegroundColor Yellow
        Write-Host "[DRY-RUN] Se $estado la cuenta" -ForegroundColor Yellow
        return
    }
    
    try {
        
        # Comprobamos que el usuario exista
        $usuarioAD = Get-ADUser -Filter "Name -eq '$usuario'" -ErrorAction SilentlyContinue
        

        # En caso de que no informamos al usuario y salimos
        if (-not $usuarioAD) {

            Write-Host "El usuario '$usuario' no existe" -ForegroundColor Red
            return
        }
        
        # Cambiamos la contraseña, pero primero la convertimos a securestring
        $securePassword = ConvertTo-SecureString $nuevaPassword -AsPlainText -Force
        Set-ADAccountPassword -Identity $usuarioAD -NewPassword $securePassword -Reset
        Write-Host "Contraseña modificada correctamente" -ForegroundColor Green
        
        # Habilitamos o deshabilitamos la cuenta segun lo que quiera el usuario
        if ($estado -eq "Habilitar") {
            Enable-ADAccount -Identity $usuarioAD
            Write-Host "Cuenta habilitada" -ForegroundColor Green

        } elseif ($estado -eq "Deshabilitar") {
            Disable-ADAccount -Identity $usuarioAD
            Write-Host "Cuenta deshabilitada" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "Error al modificar el usuario: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Función para añadir un usuario a un grupo
function Añadir-UsuarioGrupo {

    # Definimos los parametros de entrada
    param([string]$usuario, [string]$grupo)
    
    Write-Host "`n--- AÑADIR UN USUARIO A UN GRUPO ---" -ForegroundColor Green
    
    # Mostramos el futuro resultado en caso de que use dryrun
    if ($DryRun) {

        Write-Host "[DRY-RUN] Se añadiria el usuario '$usuario' al grupo '$grupo'" -ForegroundColor Yellow
        return
    }
    
    try {
        
        # Verificamos si el usuario existe
        $usuarioAD = Get-ADUser -Filter "Name -eq '$usuario'" -ErrorAction SilentlyContinue

        # Verificamos que si grupo existe
        $grupoAD = Get-ADGroup -Filter "Name -eq '$grupo'" -ErrorAction SilentlyContinue
        
        # Si el usuario no existe, mostramos error y salimos
        if (-not $usuarioAD) {
            Write-Host "Error: El usuario '$usuario' no existe" -ForegroundColor Red
            return
        }
        
        # Hacemos la misma comprobación del usuario pero con el grupo
        if (-not $grupoAD) {
            Write-Host "Error: El grupo '$grupo' no existe" -ForegroundColor Red
            return
        }
        
        # Si ambos existen, añadimos el usuario al grupo
        Add-ADGroupMember -Identity $grupoAD -Members $usuarioAD
        Write-Host "Usuario '$usuario' añadido al grupo '$grupo' correctamente" -ForegroundColor Green
        
    } catch {
        Write-Host "Error al añadir usuario al grupo: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Función para listar los objetos
function Listar-Objetos {

    # Definimos los parametros de entrada
    param([string]$tipo, [string]$filtroUO)
    
    Write-Host "`n--- LISTAR OBJETOS ---" -ForegroundColor Green
    
    # En caso de usar dryrun mostramos el qué haría
    if ($DryRun) {

        Write-Host "[DRY-RUN] Se listarian objetos de tipo '$tipo'" -ForegroundColor Yellow

        if ($filtroUO) {
            Write-Host "[DRY-RUN] Filtrado por UO: $filtroUO" -ForegroundColor Yellow
        }
        return
    }
    
    try {

        # Comprobamos si quiere listar a los usuarios o ambos
        if ($tipo -eq "Usuarios" -or $tipo -eq "Ambos") {

            Write-Host "`n=== USUARIOS ===" -ForegroundColor Cyan
            
            # Si el usuario filtró por UO, buscamos solo en esa UO
            if ($filtroUO) {

                # Usamos -SearchBase para limitar la búsqueda a una UO específica
                $usuarios = Get-ADUser -Filter * -SearchBase $filtroUO | Sort-Object Name

            } else {

                # Si no hay filtro, buscamos en todo el dominio
                $usuarios = Get-ADUser -Filter * | Sort-Object Name
            }
            
            # Mostramos a cada usuario encontrado
            foreach ($user in $usuarios) {
                Write-Host "  - $($user.Name) ($($user.DistinguishedName))"
            }
        }
        
        # Comprobamos si quiere listar los grupos o ambos
        if ($tipo -eq "Grupos" -or $tipo -eq "Ambos") {

            Write-Host "`n=== GRUPOS ===" -ForegroundColor Cyan
            
            if ($filtroUO) {

                # Verificamos si filtró por UO, al igual que hicimos con los usuarios
                $grupos = Get-ADGroup -Filter * -SearchBase $filtroUO | Sort-Object Name

            } else {
                $grupos = Get-ADGroup -Filter * | Sort-Object Name
            }
            
            # Mostramos cada grupo con su ámbito y categoría
            foreach ($group in $grupos) {
                Write-Host "  - $($group.Name) [$($group.GroupScope) - $($group.GroupCategory)]"
            }
        }
        
    } catch {

        Write-Host "Error al listar objetos: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Creamos el programa principal
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SCRIPT DE ADMINISTRACION (aaronp-ivan02.ps1)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Si no se pasa ninguna acción, mostramos la ayuda y salimos
if (-not $Accion) {

    Mostrar-Ayuda
    exit
}

# Ejecutamos la acción que haya elegido el usuario, para ello usamos un switch
switch ($Accion) {

    # 1º Caso: Crear un grupo
    "-G" {
        
        # Verificamos si se pasaron los 3 parámetros necesarios
        if (-not $Param2 -or -not $Param3 -or -not $Param4) {

            Write-Host "Error: Faltan parametros. Use -Param2 <Nombre> -Param3 <Ambito> -Param4 <Tipo>" -ForegroundColor Red
            exit
        }

        # Llamamos a la función Crear-Grupo
        Crear-Grupo -nombre $Param2 -ambito $Param3 -tipo $Param4
    }

    # 2º Caso: Crear un usuario
    "-U" {

         # Verificamos si se pasaron los 2 parámetros necesarios
        if (-not $Param2 -or -not $Param3) {

            Write-Host "Error: Faltan parametros. Use -Param2 <Nombre> -Param3 <UO>" -ForegroundColor Red
            exit
        }

        # Llamamos a la función Crear-Usuario
        Crear-Usuario -nombre $Param2 -uo $Param3
    }
    
    # 3º Caso: Modificar un usuario
    "-M" {

         # Verificamos si se pasaron los 3 parámetros necesarios
        if (-not $Param2 -or -not $Param3 -or -not $Param4) {

            Write-Host "Error: Faltan parametros. Use -Param2 <Usuario> -Param3 <Contraseña> -Param4 <Habilitar/Deshabilitar>" -ForegroundColor Red
            exit
        }

        # Llamamos a la función Modificar-Usuario
        Modificar-Usuario -usuario $Param2 -nuevaPassword $Param3 -estado $Param4
    }

    # 4º Caso: Añadir un usuario a un grupo
    "-AG" {
        
         # Verificamos si se pasaron los 2 parámetros necesarios
        if (-not $Param2 -or -not $Param3) {

            Write-Host "Error: Faltan parametros. Use -Param2 <Usuario> -Param3 <Grupo>" -ForegroundColor Red
            exit
        }

        # Llamamos a la función Añadir-UsuarioGrupo
        Añadir-UsuarioGrupo -usuario $Param2 -grupo $Param3
    }
    
    # 5º Caso: Listar objetos
    "-LIST" {

        # Veririficamos si se pasó el parametro2, ya que el 3 es opcional
        if (-not $Param2) {

            Write-Host "Error: Falta parametro. Use -Param2 <Usuarios/Grupos/Ambos> [-Param3 <UO>]" -ForegroundColor Red
            exit
        }

        # Llamamos a la función Listar-Objetos
        Listar-Objetos -tipo $Param2 -filtroUO $Param3
    }
    
    # Caso por defecto, en caso de que el usuario se haya equivocado de acción
    default {

        Write-Host "Accion no reconocida: $Accion" -ForegroundColor Red
        Mostrar-Ayuda   # Mostramos la ayuda para que vea en qué se ha equivocado.
    }
}