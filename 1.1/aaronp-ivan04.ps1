# Definimos los parámetros que el script puede recibir
param(

    # Ruta al script de bajas que queremos evaluar
    [string]$ScriptBajas = ".\script-bajas.ps1",
    
    # Si se usa, solo simula las acciones sin ejecutarlas
    [switch]$DryRun
)

# Variables que usaremos a lo largo de el script
$nota = 0                                    # El contador de la nota (0-10)
$errores = @()                               # Un array para almacenar los errores encontrados
$logDir = "C:\Windows\Logs"                  # El directorio donde se guardaran los logs
$carpetaProyecto = "C:\Users\proyecto"       # La carpeta donde se mueven los archivos
$ficheroTest = "C:\bajas_test.txt"           # El fichero de bajas para las pruebas

# Creamos la función para limpiar el entorno
function Limpiar-Entorno {

    Write-Host "`n--- LIMPIANDO ENTORNO DE PRUEBAS ---" -ForegroundColor Cyan
    
    # Si usa el DryRun, solo mostramos lo que haría
    if ($DryRun) {

        Write-Host "[DRY-RUN] Se limpiaria el entorno de pruebas" -ForegroundColor Yellow
        return  # Salimos sin hacer cambios de verdad
    }
    
    # Creamos la lista de usuarios que crearemos para las pruebas
    $usuariosPrueba = @("usuario1", "usuario2", "usuario3", "usuario4", "usuario5")
    
    # Los repetimos por cada usuario para eliminarlos
    foreach ($user in $usuariosPrueba) {

        try {
            # Intentamos obtener el usuario (si existe)
            $existe = Get-LocalUser -Name $user -ErrorAction SilentlyContinue
            
            # En caso de que sí, lo eliminamos
            if ($existe) {

                Remove-LocalUser -Name $user -ErrorAction SilentlyContinue
            }
            
            # Eliminamos también su directorio personal (si existe)
            $dirUser = "C:\Users\$user"

            if (Test-Path $dirUser) {

                Remove-Item -Path $dirUser -Recurse -Force -ErrorAction SilentlyContinue
            }

        } catch {
            # Si hay algún error en la limpieza, lo ignoramos ya que puede ser que el usuario ya no exista
        }
    }
    
    # Eliminar carpeta del proyecto completa (si existe)
    if (Test-Path $carpetaProyecto) {

        Remove-Item -Path $carpetaProyecto -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Eliminar los archivos de log de pruebas anteriores
    if (Test-Path "$logDir\bajas.log") {

        Remove-Item -Path "$logDir\bajas.log" -Force -ErrorAction SilentlyContinue
    }

    if (Test-Path "$logDir\bajaserror.log") {

        Remove-Item -Path "$logDir\bajaserror.log" -Force -ErrorAction SilentlyContinue
    }
    
    # Eliminamos el fichero de bajas de test
    if (Test-Path $ficheroTest) {

        Remove-Item -Path $ficheroTest -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "Entorno limpiado correctamente" -ForegroundColor Green
}

# Creamos la función para crear el entorno
function Preparar-Entorno {

    Write-Host "`n--- CREACIÓN DEL ENTORNO DE PRUEBAS ---" -ForegroundColor Cyan
    
    # Si usa DryRun, solo mostramos lo que haría
    if ($DryRun) {

        Write-Host "[DRY-RUN] Se prepararia el entorno de pruebas" -ForegroundColor Yellow
        Write-Host "[DRY-RUN] - Crear 5 usuarios con directorios y ficheros" -ForegroundColor Yellow
        Write-Host "[DRY-RUN] - Crear fichero bajas_test.txt" -ForegroundColor Yellow
        return $true  # Devolvemos que funcionó correctamente en modo simulación
    }
    
    try {
        # Definimos un array con los datos de cada usuario, cada línea contiene: Nombre, Apellido1, Apellido2 y Login
        $usuarios = @(
            @{Nombre="Juan"; Apellido1="Perez"; Apellido2="Garcia"; Login="usuario1"},
            @{Nombre="Maria"; Apellido1="Lopez"; Apellido2="Martinez"; Login="usuario2"},
            @{Nombre="Carlos"; Apellido1="Sanchez"; Apellido2="Ruiz"; Login="usuario3"},
            @{Nombre="Ana"; Apellido1="Gomez"; Apellido2="Fernandez"; Login="usuario4"},
            @{Nombre="Pedro"; Apellido1="Rodriguez"; Apellido2="Diaz"; Login="usuario5"}
        )
        
        # Repetimos por cada usuario para crearlo
        foreach ($user in $usuarios) {

            $login = $user.Login
            
            # Creamos el usuario local en el sistema
            # Usamos ConvertTo-SecureString para convertir la contraseña de texto plano a formato seguro
            $password = ConvertTo-SecureString "Password123!" -AsPlainText -Force
            
            # Creamos el usuario en el sistema local
            New-LocalUser -Name $login -Password $password -FullName "$($user.Nombre) $($user.Apellido1)" -ErrorAction Stop | Out-Null
            
            # Creamos el directorio personal del usuario
            $dirPersonal = "C:\Users\$login"
            New-Item -Path $dirPersonal -ItemType Directory -Force | Out-Null
            
            # Creamos la carpeta "trabajo" dentro del directorio personal
            $dirTrabajo = Join-Path $dirPersonal "trabajo"
            New-Item -Path $dirTrabajo -ItemType Directory -Force | Out-Null
            
            # Creamos 3 ficheros de prueba dentro de la carpeta de trabajo
            for ($i = 1; $i -le 3; $i++) {

                # Usamos Join-Path para unir las rutas de forma segura
                $fichero = Join-Path $dirTrabajo "archivo$i.txt"
                
                # Usamos Set-Content para crear el fichero y escribir contenido en él
                Set-Content -Path $fichero -Value "Contenido del archivo $i del usuario $login"
            }
            
            Write-Host "Usuario $login creado con 3 ficheros en directorio trabajo" -ForegroundColor Green
        }
        
        # Creamos el fichero de bajas que usará el script para comprobar. Este fichero tiene el formato: nombre:apellido1:apellido2:login
        # Incluimos un usuario que NO existe (usuarionoexiste) para verificar que el script maneja correctamente los errores
        $contenidoBajas = @"
Juan:Perez:Garcia:usuario1
Maria:Lopez:Martinez:usuario2
Carlos:Sanchez:Ruiz:usuario3
NoExiste:Usuario:Prueba:usuarionoexiste
Ana:Gomez:Fernandez:usuario4
"@
        # Guardamos el contenido en el fichero
        Set-Content -Path $ficheroTest -Value $contenidoBajas
        Write-Host "Fichero de bajas creado: $ficheroTest" -ForegroundColor Green
        
        # Si llega aquí, todo se creó correctamente
        return $true
        
    } catch {
        # Si ocurre algún error durante la ejecución, lo mostramos
        Write-Host "Error al preparar entorno: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Creamos una función para registrar el resultado de cada prueba
function Registrar-Prueba {

    # Definimos los parámetros de entrada
    param(
        [int]$numPrueba,           # Número de la prueba
        [string]$descripcion,      # El qué estamos probando
        [bool]$exito,              # Si superó o no la prueba
        [string]$errorDetalle = "" # Detalle del error, en caso de que exista
    )
    
    # Comprobamos si la prueba fue exitosa
    if ($exito) {

        # En caso de que si mostramos un tick (✓) en verde
        Write-Host "  [PRUEBA $numPrueba] ✓ $descripcion" -ForegroundColor Green
        
        # Y sumamos 1 punto a la nota
        # Usamos $script:nota para acceder a la variable global $nota
        $script:nota++
    } else {

        # Si la prueba falló, mostramos una X en rojo
        Write-Host "  [PRUEBA $numPrueba] ✗ $descripcion" -ForegroundColor Red
        
        # Añadimos el error al array de errores con el siguiente formato: "Prueba N - Descripción : Detalle del error"
        $script:errores += "Prueba $numPrueba - $descripcion : $errorDetalle"
    }
}

# Creamos una función que ejecute el script de bajas
function Ejecutar-ScriptBajas {

    # Si usa el modo DryRun, solo mostramos lo que haría
    if ($DryRun) {

        Write-Host "[DRY-RUN] Se ejecutaria el script: $ScriptBajas -FicheroBajas $ficheroTest" -ForegroundColor Yellow
        return $true
    }
    
    try {
        # Usamos & para llamar y ejecutar el script y le pasamos el parámetro -FicheroBajas con la ruta de nuestro fichero de test
        & $ScriptBajas -FicheroBajas $ficheroTest
        return $true
        
    } catch {
        # Si el script falla, mostramos el error
        Write-Host "Error al ejecutar script de bajas: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Creamos el programa principal
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SCRIPT DE CALIFICACION (aaronp-ivan04.ps1)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Si usa el DryRun, informamos al usuario
if ($DryRun) {
    Write-Host "*** MODO DRY-RUN ACTIVADO ***" -ForegroundColor Yellow
    Write-Host "No se realizaran cambios reales`n" -ForegroundColor Yellow
}

# 1º Paso: Verificar que existe el script a evaluar
if (-not (Test-Path $ScriptBajas)) {

    Write-Host "Error: No se encuentra el script '$ScriptBajas'" -ForegroundColor Red
    Write-Host "Uso: .\aaronp-ivan04.ps1 [-ScriptBajas <ruta>] [-DryRun]" -ForegroundColor Yellow
    exit 1  # Salimos con código de error 1
}

Write-Host "Script a evaluar: $ScriptBajas" -ForegroundColor Green

# 2º Paso: Limpiamos el entorno de pruebas
Limpiar-Entorno

# 3º Paso: Preparamos el entorno de pruebas creando usuarios, directorios, ficheros y el archivo de bajas
if (-not (Preparar-Entorno)) {

    # Si no se pudo preparar el entorno, señalamos el error ya que no podemos continuar
    Write-Host "`nError: No se pudo preparar el entorno de pruebas" -ForegroundColor Red
    exit 1
}

# Esperamos 2 segundos para que el sistema termine de crear todo
Start-Sleep -Seconds 2

# 4º Paso: Ejecutamos el script de bajas
Write-Host "`n--- EJECUTANDO SCRIPT DE BAJAS... ---" -ForegroundColor Cyan

# Ejecutamos el script que vamos a evaluar
if (-not (Ejecutar-ScriptBajas)) {

    Write-Host "`nError: No se pudo ejecutar el script de bajas" -ForegroundColor Red
    exit 1
}

# Esperamos 2 segundos para que el script termine completamente
Start-Sleep -Seconds 2

# 5º Paso: Realizar las 10 pruebas
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  EVALUACION CON 10 PRUEBAS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Si usa DryRun, simulamos que todas las pruebas pasaron
if ($DryRun) {

    Write-Host "[DRY-RUN] Se realizarian 10 pruebas de evaluacion" -ForegroundColor Yellow
    Write-Host "[DRY-RUN] Simulando todas las pruebas como exitosas..." -ForegroundColor Yellow
    $nota = 10  # Ponemos un 10 como nota en modo simulación

} else {
    
    # Prueba 1: Verificar que usuario1 fue eliminado del sistema
    Write-Host "`nPrueba 1: Verificar eliminacion de usuario1" -ForegroundColor Yellow

    try {
        # Intentamos obtener el usuario
        # Si no existe, no lanzará error
        $user = Get-LocalUser -Name "usuario1" -ErrorAction Stop
        
        # Si llegamos aquí, el usuario existe (mal, debería estar eliminado)
        Registrar-Prueba -numPrueba 1 -descripcion "Usuario1 eliminado del sistema" -exito $false -errorDetalle "El usuario aun existe"
    } catch {
        # Si Get-LocalUser lanza error, es porque el usuario no existe (bien)
        Registrar-Prueba -numPrueba 1 -descripcion "Usuario1 eliminado del sistema" -exito $true
    }
    
    # Prueba 2: Verificar que usuario2 fue eliminado del sistema
    Write-Host "`nPrueba 2: Verificar eliminacion de usuario2" -ForegroundColor Yellow
    try {

        $user = Get-LocalUser -Name "usuario2" -ErrorAction Stop
        # Si existe, es un error
        Registrar-Prueba -numPrueba 2 -descripcion "Usuario2 eliminado del sistema" -exito $false -errorDetalle "El usuario aun existe"
    } catch {
        # Si no existe, es correcto
        Registrar-Prueba -numPrueba 2 -descripcion "Usuario2 eliminado del sistema" -exito $true
    }
    
    # Prueba 3: Verificar que se creó la carpeta en C:\Users\proyecto\usuario1
    Write-Host "`nPrueba 3: Verificar creacion de carpeta proyecto usuario1" -ForegroundColor Yellow
    
    # Construimos la ruta de la carpeta que debería existir
    $carpetaUser1 = Join-Path $carpetaProyecto "usuario1"
    
    # Usamos Test-Path para que devuelva $true si la ruta existe, $false si no
    if (Test-Path $carpetaUser1) {
        # La carpeta existe, prueba exitosa
        Registrar-Prueba -numPrueba 3 -descripcion "Carpeta proyecto usuario1 creada" -exito $true
    } else {
        # La carpeta no existe, prueba fallida
        Registrar-Prueba -numPrueba 3 -descripcion "Carpeta proyecto usuario1 creada" -exito $false -errorDetalle "No existe la carpeta $carpetaUser1"
    }
    
    # Prueba 4: Verificar que se movieron los 3 ficheros de usuario1
    Write-Host "`nPrueba 4: Verificar ficheros movidos usuario1" -ForegroundColor Yellow
    
    # Obtenemos todos los ficheros (no directorios) de la carpeta
    $ficherosMovidos = Get-ChildItem -Path $carpetaUser1 -File -ErrorAction SilentlyContinue
    
    # Verificamos que existan ficheros Y que sean exactamente 3
    if ($ficherosMovidos -and $ficherosMovidos.Count -eq 3) {

        Registrar-Prueba -numPrueba 4 -descripcion "Ficheros de usuario1 movidos (3 ficheros)" -exito $true
    
    } else {

        # Calculamos cuántos ficheros se encontraron
        $cantidad = if ($ficherosMovidos) { $ficherosMovidos.Count } else { 0 }
        Registrar-Prueba -numPrueba 4 -descripcion "Ficheros de usuario1 movidos (3 ficheros)" -exito $false -errorDetalle "Se encontraron $cantidad ficheros, esperados 3"
    }
    
    # Prueba 5: Verificar que el directorio personal de usuario1 fue eliminado
    Write-Host "`nPrueba 5: Verificar eliminacion directorio personal usuario1" -ForegroundColor Yellow
    
    $dirUser1 = "C:\Users\usuario1"
    
    # Si NO existe el directorio, la prueba pasa
    if (-not (Test-Path $dirUser1)) {
        Registrar-Prueba -numPrueba 5 -descripcion "Directorio personal usuario1 eliminado" -exito $true
    } else {
        # Si aún existe, es un error
        Registrar-Prueba -numPrueba 5 -descripcion "Directorio personal usuario1 eliminado" -exito $false -errorDetalle "El directorio $dirUser1 aun existe"
    }

    # Prueba 6: Verificar que se creó el archivo de log bajas.log
    Write-Host "`nPrueba 6: Verificar creacion de log bajas.log" -ForegroundColor Yellow
    
    $logBajas = Join-Path $logDir "bajas.log"
    
    # Verificamos si existe el archivo
    if (Test-Path $logBajas) {

        Registrar-Prueba -numPrueba 6 -descripcion "Log bajas.log creado" -exito $true
    
    } else {

        Registrar-Prueba -numPrueba 6 -descripcion "Log bajas.log creado" -exito $false -errorDetalle "No se encontro el archivo $logBajas"
    }
    
    # Prueba 7: Verificar que el log de bajas contiene información de usuario1
    Write-Host "`nPrueba 7: Verificar contenido log bajas (usuario1)" -ForegroundColor Yellow
    
    # Verificamos que el log existe
    if (Test-Path $logBajas) {

        # Usamos Get-Content -Raw para que lea todo el contenido del archivo como una sola cadena
        $contenidoLog = Get-Content $logBajas -Raw
        
        if ($contenidoLog -match "usuario1") {

            Registrar-Prueba -numPrueba 7 -descripcion "Log contiene informacion de usuario1" -exito $true
       
        } else {

            Registrar-Prueba -numPrueba 7 -descripcion "Log contiene informacion de usuario1" -exito $false -errorDetalle "No se encontro 'usuario1' en el log"
        }

    } else {

        # Si el log no existe, esta prueba también falla
        Registrar-Prueba -numPrueba 7 -descripcion "Log contiene informacion de usuario1" -exito $false -errorDetalle "Log no existe"
    }
    
    # Prueba 8: Verificar que se creó el archivo de log bajaserror.log
    Write-Host "`nPrueba 8: Verificar creacion de log bajaserror.log" -ForegroundColor Yellow
    
    $logErrores = Join-Path $logDir "bajaserror.log"
    
    if (Test-Path $logErrores) {

        Registrar-Prueba -numPrueba 8 -descripcion "Log bajaserror.log creado" -exito $true

    } else {

        Registrar-Prueba -numPrueba 8 -descripcion "Log bajaserror.log creado" -exito $false -errorDetalle "No se encontro el archivo $logErrores"
    }
    
    # Prueba 9: Verificar que el log de errores registró el usuario inexistente
    Write-Host "`nPrueba 9: Verificar registro de usuario no existente en log errores" -ForegroundColor Yellow
    
    if (Test-Path $logErrores) {

        # Leemos el contenido del log de errores
        $contenidoErrorLog = Get-Content $logErrores -Raw
        
        # Buscamos si aparece "usuarionoexiste" en el log
        if ($contenidoErrorLog -match "usuarionoexiste") {

            Registrar-Prueba -numPrueba 9 -descripcion "Usuario no existente registrado en log errores" -exito $true
       
        } else {

            Registrar-Prueba -numPrueba 9 -descripcion "Usuario no existente registrado en log errores" -exito $false -errorDetalle "No se encontro 'usuarionoexiste' en log de errores"
        }

    } else {

        Registrar-Prueba -numPrueba 9 -descripcion "Usuario no existente registrado en log errores" -exito $false -errorDetalle "Log de errores no existe"
    }
    
    # Prueba 10: Verificar que usuario4 también fue procesado correctamente
    Write-Host "`nPrueba 10: Verificar procesamiento completo (usuario4)" -ForegroundColor Yellow
    
    try {
        # Intentamos obtener usuario4
        $user = Get-LocalUser -Name "usuario4" -ErrorAction Stop
        
        # Si existe, es un error (debería haber sido eliminado)
        Registrar-Prueba -numPrueba 10 -descripcion "Usuario4 eliminado correctamente" -exito $false -errorDetalle "El usuario4 aun existe, deberia haber sido eliminado"
    } catch {
        # Si no existe, el script procesó correctamente todas las líneas
        Registrar-Prueba -numPrueba 10 -descripcion "Usuario4 eliminado correctamente" -exito $true
    }
}

# 6º Paso: Mostramos los resultados finales
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  RESULTADOS FINALES" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Mostramos la nota final
# Usamos el color verde si aprobó (>=5) y rojo si suspendió (<5)
Write-Host "NOTA FINAL: $nota / 10" -ForegroundColor $(if ($nota -ge 5) { "Green" } else { "Red" })

# Si hay errores, los mostramos todos
if ($errores.Count -gt 0) {

    Write-Host "`nERRORES DETECTADOS ($($errores.Count)):" -ForegroundColor Red
    
    # Repetimos por cada error para mostrarlo
    foreach ($error in $errores) {

        Write-Host "  - $error" -ForegroundColor Yellow
    }

} else {

    # Si no hay errores, felicitamos al usuario
    Write-Host "`n¡Excelente! Todas las pruebas han pasado correctamente" -ForegroundColor Green
}

# Mostramos la calificación
Write-Host "`n========================================" -ForegroundColor Cyan

# Convertimos la nota numérica en calificación usando operadores de comparación
$calificacion = if ($nota -ge 9) { 'Sobresaliente' } 

                elseif ($nota -ge 7) { 'Notable' } 

                elseif ($nota -ge 5) { 'Aprobado' } 

                else { 'Suspenso' }

Write-Host "Calificacion: $calificacion" -ForegroundColor $(if ($nota -ge 5) { "Green" } else { "Red" })
Write-Host "========================================`n" -ForegroundColor Cyan