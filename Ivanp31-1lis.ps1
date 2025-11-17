#Creamos la ka funcion para crear eventos y ponemos limite de 50 porque son demasiados
function Mostrar-EventosSistema {
    Write-Host "EVENTOS DEL SISTEMA"
    Get-EventLog -LogName System -Newest 50
}
#Creamos la funcion para mostra error de este utlimo mes
function Mostrar-ErroresUltimoMes {
    Write-Host "ERRORES DEL SISTEMA DEL ÚLTIMO MES"
    $fecha = (Get-Date).AddMonths(-1)
    Get-EventLog -LogName System -EntryType Error | Where-Object { $_.TimeGenerated -ge $fecha }
}
#Creamos la funcion para mostra warnings
function Mostrar-WarningsAplicacionesSemana {
    Write-Host "WARNING DE APLICACIONES ESTA SEMANA"
    $fecha = (Get-Date).AddDays(-7)
    Get-EventLog -LogName Application -EntryType Warning | Where-Object { $_.TimeGenerated -ge $fecha }
}
#HAcemos un menu
do {
    Write-Host "MENU"
    Write-Host "1. Listado de eventos del sistema"
    Write-Host "2. Errores del sistema del último mes"
    Write-Host "3. Warnings de aplicaciones de esta semana"
    Write-Host "0. Salir"
    $opcion = Read-Host "Elige una opción"
#Le decimos que pasará en cada caso
    switch ($opcion) {
        "1" { Mostrar-EventosSistema }
        "2" { Mostrar-ErroresUltimoMes }
        "3" { Mostrar-WarningsAplicacionesSemana }
        "0" { Write-Host "Has Salido del Programa" }
        default { Write-Host "Opción no válida" }
    }

} while ($opcion -ne "0")
#Solo saldrá si opcion ees = 0