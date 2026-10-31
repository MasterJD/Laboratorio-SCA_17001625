# Entrega - Laboratorio SCA

## 1. Identificación del proyecto

- Repositorio: [MasterJD/Laboratorio-SCA_17001625](https://github.com/MasterJD/Laboratorio-SCA_17001625)
- Rama principal: `main`
- Rama de remediación: `fix/sca-remediation`
- Pull Request de remediación: [PR #1](https://github.com/MasterJD/Laboratorio-SCA_17001625/pull/1)
- Estado del PR: fusionado en `main`
- Commit de remediación: `c94cb003a855d42f1dafdf30da179302dde8affd`

## 2. Resultado final

- Compilación Maven: exitosa (`BUILD SUCCESS`).
- Dependency-Check local: 0 dependencias vulnerables y 0 vulnerabilidades.
- Workflow de GitHub Actions: exitoso.
- SBOM CycloneDX: generado correctamente.
- SARIF: publicado en GitHub Code Scanning.
- Reportes del pipeline: publicados como artefacto `dependency-check-reports`.
- SBOM del pipeline: publicado como artefacto `cyclonedx-sbom`.
- Secretos: la clave NVD se mantiene fuera del repositorio, mediante `.env.local` y el secreto `NVD_API_KEY` de GitHub.

## 3. Enlaces externos

- [Workflow del PR](https://github.com/MasterJD/Laboratorio-SCA_17001625/actions/runs/41157102979)
- [Job OWASP Dependency-Check](https://github.com/MasterJD/Laboratorio-SCA_17001625/actions/runs/41157102979/job/124406200491)
- [Job SBOM CycloneDX](https://github.com/MasterJD/Laboratorio-SCA_17001625/actions/runs/41157102979/job/124406200325)
- [Code Scanning del repositorio](https://github.com/MasterJD/Laboratorio-SCA_17001625/security/code-scanning)
- [Actions del repositorio](https://github.com/MasterJD/Laboratorio-SCA_17001625/actions)

## 4. Evidencias visuales

### Dependency-Check local

- [Ejecución local - captura 1](evidence/local_dependency_check_01.png)
- [Ejecución local - captura 2](evidence/local_dependency_check_02.png)
- [Ejecución local - captura 3](evidence/local_dependency_check_03.png)
- [Resultado sin vulnerabilidades](evidence/dependency-check-pass.png)

### GitHub Actions y Pull Request

- [Ejecución del pipeline](evidence/pipeline_execution_01.png)
- [PR fusionado](evidence/successful_pr.png)

### Dependency-Track

- [Importación del SBOM](evidence/dependency_track_sbom_02.png)
- [Proyecto en Dependency-Track](evidence/dependency_track_webapp_01.png)
- [Vista general](evidence/dependency-track-overview.png)
- [Auditoría](evidence/dependency-track-audit.png)
- [Componentes](evidence/dependency-track-components.png)
- [Grafo de dependencias](evidence/dependency-track-graph.png)
- [Grafo adicional](evidence/dependency_graph.png)

### DefectDojo

- [Importación del reporte en DefectDojo](evidence/defectdojo-import.png)

## 5. Reportes y artefactos

### SBOM

- [SBOM remediado CycloneDX](evidence/remediated-bom.json)
- El SBOM contiene 27 componentes y corresponde a la versión remediada del proyecto.

### Reportes remotos del pipeline

- [Reporte HTML](evidence/remote-pipeline-dependency-check-reports/dependency-check-report.html)
- [Reporte JSON](evidence/remote-pipeline-dependency-check-reports/dependency-check-report.json)
- [Reporte XML](evidence/remote-pipeline-dependency-check-reports/dependency-check-report.xml)
- [Reporte SARIF](evidence/remote-pipeline-dependency-check-reports/dependency-check-report.sarif)

Estos archivos corresponden al artefacto `dependency-check-reports` descargado desde GitHub Actions.

## 6. Archivos principales de implementación

- [Workflow SCA](.github/workflows/sca-dependency-check.yml)
- [Dependencias Maven](pom.xml)
- [Reglas de exclusión](.gitignore)
- [Script de Dependency-Check](scripts/run-dependency-check.ps1)
- [Script de generación del SBOM](scripts/generate-sbom.ps1)
- [Variables de ejemplo](.env.example)
- [Documentación general](README.md)

## 7. Remediaciones aplicadas

- MySQL Connector/J actualizado a `8.4.0`.
- `protobuf-java` actualizado a `3.25.5`.
- JSON actualizado a `20231013`.
- Hibernate actualizado a `5.6.15.Final`.
- dom4j actualizado a `2.1.4`.
- Log4j actualizado a `2.26.1`.
- Commons Collections actualizado a `3.2.2`.
- Commons FileUpload actualizado a `1.6.0`.
- Commons IO actualizado a `2.16.1`.
- jQuery actualizado a `3.7.1`.
- Secretos simulados retirados del código fuente.

## 8. Archivos que no deben publicarse

Los siguientes archivos se mantienen fuera del control de versiones por contener datos locales, secretos o resultados temporales:

- `.env.local`
- `target/`
- `reports/`
- `infra/**/data/`
- `Tarea_SCA_DependencyCheck.pdf`
- La copia local `javavulnerablelab-sca/`

## 9. Pendiente para la entrega académica

La implementación técnica, el PR, el pipeline, el SBOM y las evidencias están completos. Si la sección 5 exige un documento final independiente en PDF, todavía debe elaborarse y entregarse ese PDF usando este archivo como índice y las capturas enlazadas arriba.
