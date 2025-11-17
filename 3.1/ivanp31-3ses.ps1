# Hacemos Los varables que se van a utilizar en parametros
param(
    [datetime]$FechaInicio,
    [datetime]$FechaFin
)

Write-Host "Eventos de Inicio de Sesión"

# Creamos una variable para conseguir los inicio de sesión entra las fechas establecidas
$eventos = Get-EventLog -LogName Security -InstanceId 4624 -After $FechaInicio -Before $FechaFin

# Filtramos los eventos y los mostramos 
foreach ($evento in $eventos) {
    $usuario = $evento.ReplacementStrings[5]
    # Excluimos usuarios
    if ($usuario -ne "SYSTEM") {
        Write-Host "Fecha: $($evento.TimeGenerated) - Usuario: $usuario"
    }
}