#requires -Version 5.1
<#
.SYNOPSIS
    Genera el SBOM CycloneDX JSON del proyecto con Maven dentro de Docker.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Write-Host "==> Generando SBOM CycloneDX para $projectRoot"

Push-Location $projectRoot
try {
    docker run --rm `
        -v "${projectRoot}:/src" `
        -v "jvl-m2:/root/.m2" `
        -w /src `
        maven:3.9-eclipse-temurin-17 `
        mvn -B org.cyclonedx:cyclonedx-maven-plugin:2.9.3:makeAggregateBom

    if ($LASTEXITCODE -ne 0) {
        throw "El plugin CycloneDX terminó con código $LASTEXITCODE."
    }

    $bom = Join-Path $projectRoot 'target\bom.json'
    if (-not (Test-Path $bom)) {
        throw "No se generó $bom"
    }

    $reportsDir = Join-Path $projectRoot 'reports'
    New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null
    Copy-Item $bom (Join-Path $reportsDir 'bom.json') -Force

    $json = Get-Content $bom -Raw | ConvertFrom-Json
    $count = @($json.components).Count
    Write-Host ''
    Write-Host "==> SBOM generado: target\bom.json"
    Write-Host "==> Componentes en el SBOM: $count"
    Write-Host '==> Copia para entregar: reports\bom.json'
}
finally {
    Pop-Location
}
