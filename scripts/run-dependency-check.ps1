#requires -Version 5.1
<#
.SYNOPSIS
    Ejecuta OWASP Dependency-Check con Maven dentro de Docker.
.DESCRIPTION
    Lee la clave del NVD desde .env.local (recomendado) o desde la variable de
    entorno NVD_API_KEY. Genera HTML, XML, JSON y SARIF en target/ y copia los
    reportes a reports/ para que sean fáciles de entregar.
#>
[CmdletBinding()]
param(
    [string]$NvdApiKey = $env:NVD_API_KEY,
    [double]$FailOnCVSS = 11
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$envFile = Join-Path $projectRoot '.env.local'

if (-not $NvdApiKey -and (Test-Path $envFile)) {
    foreach ($line in Get-Content $envFile) {
        if ($line -match '^\s*NVD_API_KEY\s*=\s*(.+?)\s*$') {
            $NvdApiKey = $Matches[1].Trim('"').Trim("'")
        }
    }
}

if (-not $NvdApiKey) {
    throw "Falta la clave del NVD. Escribe NVD_API_KEY=tu_clave en $envFile o define `$env:NVD_API_KEY."
}

$env:NVD_API_KEY = $NvdApiKey
Write-Host "==> Proyecto: $projectRoot"
Write-Host '==> Ejecutando Dependency-Check 13.0.0 en Docker (la primera vez descarga el NVD)...'

Push-Location $projectRoot
try {
    docker run --rm `
        -v "${projectRoot}:/src" `
        -v "jvl-m2:/root/.m2" `
        -e NVD_API_KEY `
        -w /src `
        maven:3.9-eclipse-temurin-17 `
        mvn -B org.owasp:dependency-check-maven:13.0.0:check `
            '-Dformat=ALL' `
            '-DossindexAnalyzerEnabled=false' `
            "-Ddependency-check.failBuildOnCVSS=$FailOnCVSS"

    $scanExitCode = $LASTEXITCODE

    $reportsDir = Join-Path $projectRoot 'reports'
    New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null
    foreach ($name in 'html', 'xml', 'json', 'sarif') {
        $source = Join-Path $projectRoot "target\dependency-check-report.$name"
        if (Test-Path $source) {
            Copy-Item $source (Join-Path $reportsDir "dependency-check-report.$name") -Force
        }
    }

    if ($scanExitCode -ne 0) {
        throw "Dependency-Check terminó con código $scanExitCode (posible CVSS >= $FailOnCVSS). Los reportes quedaron en target\ y reports\."
    }

    Write-Host ''
    Write-Host '==> Listo. Reportes:'
    Write-Host '    target\dependency-check-report.html'
    Write-Host '    target\dependency-check-report.xml'
    Write-Host '    target\dependency-check-report.json'
    Write-Host '    target\dependency-check-report.sarif'
    Write-Host '    reports\ (copia para entregar)'
}
finally {
    Pop-Location
}
