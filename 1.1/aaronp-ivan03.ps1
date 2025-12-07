# Creamos los funcion para almacenar parametros
param(
    [string]$FicheroBajas,
    [switch]$DryRun
)

# Declaramos las variables necesarias
#Donde se guardaran los logs
$logDir = "C:\Windows\Logs"
# Ruta del log de errores
$logErrores = Join-Path $logDir "bajaserror.log"
# Ruta del log de bajas correctas
$logBajas = Join-Path $logDir "bajas.log"
# Carpeta donde se guardarán los archivos movidos de los usuarios
$carpetaProyecto = "C:\Users\proyecto"

# Creamos una función para escribir en el archivo de los logs de errores
function Escribir-LogError {
    # Definimos parametros
    param(
        [string]$login,
        [string]$nombre,
        [string]$apellido1,
        [string]$apellido2,
        [string]$motivo
    )
    # Variable para definir la fecha
    $fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    # apellidos del usuario
    $apellidos = "$apellido1 $apellido2"
    # Linea completa que se meterá en log
    $linea = "$fecha-$login-$nombre-$apellidos-$motivo"
    # Si se activa DryRun
    if ($DryRun) {
        # mostramos que se haría
        Write-Host "[DRY-RUN] Se escribiria en log de errores: $linea" -ForegroundColor Yellow
    } 
    # Si no se escribirá la línea en el fichero de errores
    else {
        Add-Content -Path $logErrores -Value $linea
    }
}

# Función para escribir en log de bajas
function Escribir-LogBaja {
    # Definimos parametros que se introducirán
    param(
        [string]$login,
        [string]$carpetaDestino,
        [array]$ficheros
    )
    # Obtenemos la fecha
    $fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
    # Definimos el log de baja para la cabecera
    $linea = "`n========================================`n"
    $linea += "Fecha y hora: $fecha `n"
    $linea += "Login: $login`n"
    $linea += "Carpeta destino: $carpetaDestino`n"
    $linea += "Ficheros movidos:`n"
    #Enumeramos cada fichero movido
    $contador = 1
    # Recorremos cada fichero en la lista de ficheros 
    foreach ($fichero in $ficheros) {
        # Añadimos al log una línea con el número de fichero y su nombre
        $linea += "  $contador. $($fichero.Name)`n"
        # Incrementamos el contador para enumerar el siguiente fichero
        $contador++
    }
    # Añadimos al log el total de ficheros movidos
    $linea += "Total de ficheros: $($ficheros.Count)`n"
    # Añadimos una línea de separación para el cada log
    $linea += "========================================`n"
    # Comprobamos si estamos en modo DryRun
    if ($DryRun) {
        # mostramos que se haría
        Write-Host "[DRY-RUN] Se escribiria en log de bajas:" -ForegroundColor Yellow
        Write-Host $linea -ForegroundColor Cyan
    } 
    else {
        #En caso de no ser DryRun Escribimos la información en el log de bajas real
        Add-Content -Path $logBajas -Value $linea
    }
}

# Creamos una función para procesar la baja de un usuario
function Procesar-Baja {
    param(
        [string]$nombre,
        [string]$apellido1,
        [string]$apellido2,
        [string]$login
    )
    #Mostramos que se inicie el proceso
    Write-Host "`n Procesando baja de usuario: $login" -ForegroundColor Cyan
    
    # Verificamos que el usuario existe en el sistema
    try {
        $usuario = Get-LocalUser -Name $login -ErrorAction Stop
    } 
    catch {
        # Mostramos mensaje de error si el usuario no existe y Registramos el error en el log de errores
        Write-Host "Error: El usuario '$login' no existe en el sistema" -ForegroundColor Red
        Escribir-LogError -login $login -nombre $nombre -apellido1 $apellido1 -apellido2 $apellido2 -motivo "Usuario no existe en el sistema"
        #Salimos de pla funcion
        return
    }
    
    # Definimos las rutas de carpetas del usuario
    $directorioPersonal = "C:\Users\$login"
    $carpetaTrabajo = Join-Path $directorioPersonal "trabajo"
    $carpetaDestinoUsuario = Join-Path $carpetaProyecto $login
    
    # Verificamos que existe el directorio de trabajo
    if (-not (Test-Path $carpetaTrabajo)) {
        # Mostramos aviso si no existe el directorio de trabajo
        Write-Host "Aviso: No existe el directorio de trabajo para el usuario '$login'" -ForegroundColor Yellow
        # Registramos el error en el log de errores
        Escribir-LogError -login $login -nombre $nombre -apellido1 $apellido1 -apellido2 $apellido2 -motivo "No existe directorio trabajo"
        
        # Continuamos con la eliminación del usuario
        if ($DryRun) {
            #Mensaje si estamos en simulación
            Write-Host "[DRY-RUN] Se eliminaria el usuario '$login'" -ForegroundColor Yellow
        } 
        else {
             # Eliminamos el usuario real del sistema
            Remove-LocalUser -Name $login
            # Mostramos mensaje de confirmación
            Write-Host "Usuario '$login' eliminado correctamente" -ForegroundColor Green
        }
        # Salimos de la función
        return
    }
    
    # Comprobamos si estamos en modo DryRun
    if ($DryRun) {
        Write-Host "[DRY-RUN] Se crearia la carpeta: $carpetaDestinoUsuario" -ForegroundColor Yellow
    } 
    else {
        # Verificamos si la carpeta principal del proyecto existe
        if (-not (Test-Path $carpetaProyecto)) {
        # Creamos la carpeta principal del proyecto si no existe
            New-Item -Path $carpetaProyecto -ItemType Directory -Force | Out-Null
        }
        # Verificamos si la carpeta del usuario dentro del proyecto existe
        if (-not (Test-Path $carpetaDestinoUsuario)) {
            # Creamos la carpeta del usuario si no existe
            New-Item -Path $carpetaDestinoUsuario -ItemType Directory -Force | Out-Null
            Write-Host "Carpeta creada: $carpetaDestinoUsuario" -ForegroundColor Green
        }
    }
    
    # Obtenemos ficheros del directorio trabajo del usuario
    try {
        $ficheros = Get-ChildItem -Path $carpetaTrabajo -File -ErrorAction Stop
        # Comprobamos si no hay ficheros para mover
        if ($ficheros.Count -eq 0) {
            Write-Host "No hay ficheros que mover en el directorio trabajo" -ForegroundColor Yellow
        } 
        else {
            # Movemos los ficheros a la carpeta destino
            if ($DryRun) {
                # En modo DryRun, mostramos cuántos ficheros se moverían y sus nombres
                Write-Host "[DRY-RUN] Se moverian $($ficheros.Count) ficheros a $carpetaDestinoUsuario" -ForegroundColor Yellow
                # Mostramos cada fichero que se movería
                foreach ($fichero in $ficheros) {
                    Write-Host "  - $($fichero.Name)" -ForegroundColor Cyan
                }
            } 
            else {
                # Movemos cada fichero a la carpeta destino
                foreach ($fichero in $ficheros) {
                    $destino = Join-Path $carpetaDestinoUsuario $fichero.Name
                    Move-Item -Path $fichero.FullName -Destination $destino -Force
                }
                # Mostramos mensaje de confirmación del número de ficheros movidos
                Write-Host "Ficheros movidos: $($ficheros.Count)" -ForegroundColor Green
                    
                # Cambiamos el propietario de la carpeta y los ficheros a Administrador
                Write-Host "Cambiando propietario de los ficheros a Administrador..." -ForegroundColor Cyan
                $acl = Get-Acl $carpetaDestinoUsuario
                $adminUser = New-Object System.Security.Principal.NTAccount("Administrador")
                $acl.SetOwner($adminUser)
                Set-Acl -Path $carpetaDestinoUsuario -AclObject $acl
                
                 # Aplicamos el cambio de propietario a cada fichero dentro de la carpeta
                foreach ($fichero in (Get-ChildItem -Path $carpetaDestinoUsuario -File)) {
                    $aclFile = Get-Acl $fichero.FullName
                    $aclFile.SetOwner($adminUser)
                    Set-Acl -Path $fichero.FullName -AclObject $aclFile
                }
                # Mostramos mensaje de confirmación de cambio de propietario
                Write-Host "Propietario cambiado correctamente" -ForegroundColor Green
            }
            
            # Registramos la baja del usuario en el log de bajas
            Escribir-LogBaja -login $login -carpetaDestino $carpetaDestinoUsuario -ficheros $ficheros
        }
        
    } 
    # Cualquier error que ocurra al procesar los ficheros lo mostraremos
    catch {
        Write-Host "Error al procesar ficheros: $($_.Exception.Message)" -ForegroundColor Red
        # Registramos el error en el log de errores
        Escribir-LogError -login $login -nombre $nombre -apellido1 $apellido1 -apellido2 $apellido2 -motivo "Error al mover ficheros: $($_.Exception.Message)"
        return
    }
    
    # mostramos lo que se haría
    if ($DryRun) {
        Write-Host "[DRY-RUN] Se eliminaria el usuario '$login' y su directorio personal" -ForegroundColor Yellow
    } 
    else {
        try {
            # Eliminamos el usuario del sistema
            Remove-LocalUser -Name $login
            Write-Host "Usuario '$login' eliminado del sistema" -ForegroundColor Green
            
            # Comprobamos si el directorio personal existe
            if (Test-Path $directorioPersonal) {
                # Eliminamos el directorio personal del usuario
                Remove-Item -Path $directorioPersonal -Recurse -Force
                Write-Host "Directorio personal eliminado: $directorioPersonal" -ForegroundColor Green
            }
            
        } catch {
            # Mostramos mensaje de error si ocurre algún problema al eliminar
            Write-Host "Error al eliminar usuario o directorio: $($_.Exception.Message)" -ForegroundColor Red
            # Registramos el error en el log de errores
            Escribir-LogError -login $login -nombre $nombre -apellido1 $apellido1 -apellido2 $apellido2 -motivo "Error al eliminar: $($_.Exception.Message)"
        }
    }
}

# Mostramos el script
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Script de Bajas de Usuarios" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Verificamos que se pasó el parámetro del fichero de bajas
if (-not $FicheroBajas) {
    # Mostramos mensaje de error si no se especificó fichero
    Write-Host "Error: Debe especificar un fichero de bajas" -ForegroundColor Red
    Write-Host "Uso: .\nombre03.ps1 -FicheroBajas <ruta_fichero> [-DryRun]" -ForegroundColor Yellow
    Write-Host "Ejemplo: .\nombre03.ps1 -FicheroBajas C:\bajas.txt" -ForegroundColor Yellow
    # Salimos del script
    exit 1
}

# Verificamos que el fichero de bajas existe
if (-not (Test-Path $FicheroBajas)) {
    # Mostramos mensaje de error si el fichero no existe
    Write-Host "Error: El fichero '$FicheroBajas' no existe" -ForegroundColor Red
    exit 1
}

# Verificamos que la ruta corresponde a un fichero y no a un directorio
if (-not (Test-Path $FicheroBajas -PathType Leaf)) {
    # Mostramos mensaje de error si no es un fichero válido
    Write-Host "Error: '$FicheroBajas' no es un fichero valido" -ForegroundColor Red
    exit 1
}

# Mostramos la ruta del fichero de bajas que se va a procesar
Write-Host "Fichero de bajas: $FicheroBajas" -ForegroundColor Green

# Si es DryRun, mostramos información de simulación
if ($DryRun) {
    Write-Host "`n*** MODO DRY-RUN ACTIVADO ***" -ForegroundColor Yellow
    Write-Host "No se realizaran cambios reales en el sistema`n" -ForegroundColor Yellow
}

# Creamos el directorio de logs si no existe
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Leemos el fichero de bajas
try {
    $lineas = Get-Content -Path $FicheroBajas
    # Mostramos cuántos usuarios se van a procesar
    Write-Host "Total de usuarios a procesar: $($lineas.Count)`n" -ForegroundColor Cyan
    
    # iniciamos contador de usuarios procesados
    $contador = 0
    # Recorremos cada línea del fichero
    foreach ($linea in $lineas) {
        # Ignoramos líneas vacías
        if ([string]::IsNullOrWhiteSpace($linea)) {
            continue
        }
        
        # Dividimos la línea por ':' para obtener nombre, apellidos y login
        $datos = $linea.Split(':')
        
        # Comprobamos que la línea tiene el formato correcto
        if ($datos.Count -ne 4) {
            Write-Host "Error: Formato incorrecto en linea: $linea" -ForegroundColor Red
            continue
        }
        
        # Asignamos variables a los datos del usuario
        $nombre = $datos[0].Trim()
        $apellido1 = $datos[1].Trim()
        $apellido2 = $datos[2].Trim()
        $login = $datos[3].Trim()
        
        # Incrementamos contador de usuarios procesados
        $contador++
        # Mostramos información de usuario que se está procesando
        Write-Host "[$contador/$($lineas.Count)] Procesando: $nombre $apellido1 $apellido2 ($login)" -ForegroundColor White
        
        # LLamamos a la función que procesa la baja del usuario
        Procesar-Baja -nombre $nombre -apellido1 $apellido1 -apellido2 $apellido2 -login $login
    }
    
    # Mensajes finales al terminar el procesamiento
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Proceso completado" -ForegroundColor Green
    Write-Host "Total usuarios procesados: $contador" -ForegroundColor Cyan
    Write-Host "Log de bajas: $logBajas" -ForegroundColor Cyan
    Write-Host "Log de errores: $logErrores" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    

} 
# Si hay cualquier error al leer el fichero
catch {
    # Mostramos mensaje de error si no se puede leer el fichero
    Write-Host "Error al leer el fichero: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}