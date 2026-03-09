param(
    [string]$MySqlExe = "mysql",
    [string]$RootUser = "root",
    [string]$RootPassword = "",
    [string]$DbHost = "127.0.0.1",
    [int]$Port = 3306
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$sqlFile = Join-Path $repoRoot "database\init.sql"

if (-not (Test-Path $sqlFile)) {
    throw "No se encuentra el archivo SQL: $sqlFile"
}

$mysqlCmd = Get-Command $MySqlExe -ErrorAction SilentlyContinue
if (-not $mysqlCmd) {
    throw "No se encontro el comando '$MySqlExe'. Instala MySQL Server/Client y anade mysql.exe al PATH."
}

Write-Host "Ejecutando inicializacion SQL en $DbHost`:$Port ..."

if ([string]::IsNullOrWhiteSpace($RootPassword)) {
    Get-Content -Raw $sqlFile | & $MySqlExe -h $DbHost -P $Port -u $RootUser --protocol=TCP
} else {
    Get-Content -Raw $sqlFile | & $MySqlExe -h $DbHost -P $Port -u $RootUser -p$RootPassword --protocol=TCP
}

if ($LASTEXITCODE -ne 0) {
    throw "Fallo la ejecucion del SQL de inicializacion."
}

Write-Host "Base de datos inicializada correctamente."
