# Obtenemos los tipos de registros disponibles en el sistema
$logs = Get-EventLog -List

# Inicializamos la opción
$opcion = " "
#Hacemos menu que sale si es = 0
do {

    Write-Host "MENÚ DE REGISTROS DE EVENTOS"
    Write-Host "0. Salir"

    # Mostrar los logs con un número asignado
    for ($i = 0; $i -lt $logs.Count; $i++) {
        Write-Host "$($i+1). $($logs[$i].LogDisplayName)"
    }
    $opcion = Read-Host "Selecciona una opción"

    # Convertir a entero
    $opcion = $opcion -as [int]

    # si opción es válida
    if ($opcion -ne $null -and $opcion -ge 1 -and $opcion -le $logs.Count) {
    #Restamos por se empieza desde 0 
        $opcionm = $opcion - 1
        $logSeleccionado = $logs[$opcionm].Log
        #Mostramos
        Write-Host "Mostrando eventos de: $logSeleccionado"
        Get-EventLog -LogName $logSeleccionado -Newest 12
    }
    elseif ($opcionInt -ne 0) {
        Write-Host "Opción no válida."
    }

} while ($opcion -ne 0)

Write-Host "Has salido del script"