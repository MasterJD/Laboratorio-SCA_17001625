Java Vulnerable Lab
===================

A deliberately vulnerable Java web application from the [Cyber Security and Privacy Foundation](https://www.cysecurity.org). It is built for Java developers and anyone else who wants to find real web application vulnerabilities, exploit them, and then read the source to understand why they were possible and how to fix them.

Every challenge is mapped to a category from the [OWASP Top 10:2025](https://owasp.org/Top10/2025/), and each vulnerable page carries a comment explaining the flaw and the fix.

**Warning:** this application is intentionally insecure. Several challenges give remote code execution inside the container. Running it locally with Docker on your own machine is fine. Do not expose it to the internet and never deploy it on a public facing or production server.

One thing to be aware of: Docker publishes port 9080 on all interfaces, so anyone on the same network can reach the lab. If you are on shared or untrusted wifi, change the port mapping in `docker-compose.yml` to `127.0.0.1:9080:8080` to keep it on your machine only.

Software Composition Analysis (fork del laboratorio)
----------------------------------------------------

Este repositorio es un fork de JavaVulnerableLab preparado para el laboratorio de
**Software Composition Analysis**. Sobre la aplicacion original se anadieron las
herramientas y la infraestructura necesarias para analizar sus dependencias:

| Elemento | Ruta | Para que sirve |
| -------- | ---- | -------------- |
| OWASP Dependency-Check | `pom.xml` (plugin `dependency-check-maven`) | Analisis SCA local y en CI; genera HTML, XML, JSON y SARIF |
| CycloneDX | `pom.xml` (plugin `cyclonedx-maven-plugin`) | Genera el SBOM `target/bom.json` que consume Dependency-Track |
| Pipeline CI/CD | `.github/workflows/sca-dependency-check.yml` | Ejecuta el analisis en cada push/PR y publica SARIF y artefactos |
| Script de escaneo local | `scripts/run-dependency-check.ps1` | Repite el analisis en Docker sin instalar Maven ni JDK |
| Script de SBOM | `scripts/generate-sbom.ps1` | Genera `target/bom.json` y lo copia a `reports/` |
| Dependency-Track | `infra/dependency-track/docker-compose.yml` | Gestion continua de vulnerabilidades a partir del SBOM |
| Plantilla de variables | `.env.example` | Documenta las variables necesarias (sin valores reales) |

### Requisitos

* Docker Desktop (o Docker Engine con Compose v2).
* Una clave de la API del NVD: <https://nvd.nist.gov/developers/request-an-api-key>.
  Sin clave, la descarga inicial de la base del NVD es mucho mas lenta.

### Configurar la clave del NVD

La clave **nunca se escribe en el repositorio**. Hay dos formas de pasarla:

1. **Local (Docker/Maven):** copiar `.env.example` a `.env.local` y rellenar
   `NVD_API_KEY=...`. El archivo `.env.local` esta en `.gitignore`.
2. **GitHub Actions:** guardar la clave como secreto del repositorio en
   *Settings > Secrets and variables > Actions > New repository secret* con el
   nombre `NVD_API_KEY`.

### Analisis local

```powershell
# Dependency-Check: HTML, XML, JSON y SARIF en target/ y copia en reports/
./scripts/run-dependency-check.ps1

# SBOM CycloneDX (target/bom.json + reports/bom.json)
./scripts/generate-sbom.ps1
```

La primera ejecucion descarga la base completa del NVD (varios cientos de MB) y
tarda bastante; las siguientes reutilizan el volumen `jvl-m2`.

### Dependency-Track

```powershell
docker compose -f infra/dependency-track/docker-compose.yml up -d
```

* UI: <http://localhost:8082>
* API: <http://localhost:8081>

Crear un proyecto (`JavaVulnerableLab` / `1.0`), generar una API key en
*Administration > Access Management > Teams*, subir `reports/bom.json` desde la
pestana *Components* del proyecto y esperar al analisis.

### Pipeline

El workflow `SCA con OWASP Dependency-Check` se dispara en `push` a `main`, en
cada `pull_request` hacia `main` y manualmente con `workflow_dispatch`. Usa
permisos minimos (`contents: read`, `security-events: write`), JDK 17, cache de
la base del NVD, sube el SARIF a *Security > Code scanning* y publica los
reportes y el SBOM como artefactos. Falla el build si encuentra una
vulnerabilidad con `CVSS >= 7` (`-Ddependency-check.failBuildOnCVSS=7`).

Quick start (Docker)
--------------------

This is the supported setup and the one that matches the current code.

    1. Install Docker and Docker Compose: https://docs.docker.com/engine/install/
    2. From this directory, run: docker compose up --build
    3. Wait for Tomcat to finish starting.
    4. Open http://localhost:9080/JavaVulnerableLab/install.jsp
    5. Click Install. The defaults are already correct for the Compose setup.
    6. Open http://localhost:9080/JavaVulnerableLab/ and start with the Vulnerability menu.

The app is published on port **9080** so it does not collide with anything else you may already have on 8080. Inside the container Tomcat still listens on 8080, which matters for a couple of the challenges.

MySQL data persists in `./mysql-data`. To start over from a clean database, stop the stack, delete that directory, and re-run the install step.

Default logins
--------------

Created by `install.jsp`. All passwords are stored in plaintext, which is one of the lessons.

| Username  | Password | Role  |
| --------- | -------- | ----- |
| admin     | admin    | admin |
| victim    | victim   | user  |
| attacker  | attacker | user  |
| NEO       | trinity  | user  |
| trinity   | NEO      | user  |
| Anderson  | java     | user  |
| mule      | mule     | user  |

The admin username and password are whatever you typed on the install page, and default to `admin` / `admin`.

What is inside
--------------

Challenges are reachable from the **Vulnerability** menu in the top navigation, grouped by OWASP Top 10:2025 category.

**A01 Broken Access Control**
Insecure direct object references (viewing and modifying another user's profile), path traversal in the document download, missing function level access control on the admin pages, privilege escalation by tampering with an unverified JWT claim, privilege escalation via a trusted cookie, CSRF over both GET and POST, server-side request forgery, and open redirect and forward.

**A02 Security Misconfiguration**
The setup page left deployed, unchanged default admin credentials, directory listing enabled on `/backup/`, debug mode left on in production, and XML external entity processing.

**A03 Software Supply Chain Failures**
Log4Shell (CVE-2021-44228) through a bundled Log4j 2.12.1, plus a companion Spring application in [VulnerableSpring](https://github.com/CSPF-Founder/VulnerableSpring).

**A04 Cryptographic Failures**
Card data sent in cleartext, passwords stored in plaintext, credentials written to a cookie, and MD5 password hashing.

**A05 Injection**
SQL injection (error based, blind, union, and authentication bypass), OS command injection, XPath injection, XSLT injection, ORM injection, and reflected, stored and Flash-based cross-site scripting.

**A06 Insecure Design**
Account recovery through a guessable security question, unrestricted file upload leading to a web shell, and an OTP step-up flow whose result is decided by the client.

**A07 Authentication Failures**
Login with no rate limiting or lockout, username enumeration, password change without reauthentication, session fixation via URL rewriting, and backend API keys hard-coded into front-end JavaScript.

**A08 Software or Data Integrity Failures**
Insecure Java deserialization of a client-supplied view state, reachable with a ysoserial CommonsCollections gadget, and a third-party script loaded with no Subresource Integrity.

**A09 Security Logging and Alerting Failures**
Log injection that forges audit trail entries and attributes an action to another user.

**A10 Mishandling of Exceptional Conditions**
An unhandled exception leaking a stack trace, an access check that fails open when its input is missing, and a wallet transfer with no rollback that corrupts balances.

Other installation methods
--------------------------

**These are not maintained and predate the OWASP Top 10:2025 rewrite.** The prebuilt VM image, the standalone JAR and the released WAR on SourceForge are all older than the current code and will not contain the newer challenges. Use Docker unless you have a specific reason not to. They are kept here for reference.

<details>
<summary>VirtualBox VM (outdated)</summary>

    1. Install VirtualBox: https://www.virtualbox.org/wiki/Downloads
    2. Download the VM image: http://sourceforge.net/projects/javavulnerablelab/files/v0.1/JavaVulnerableLab.ova/download
    3. Import JavaVulnerableLab.ova into VirtualBox.
    4. Set the network to Host-Only.
    5. Start the machine and log in (username: root, password: cspf).
    6. Run "service tomcat start" and "service mysql start".
    7. Find the IP address of the machine.
    8. Open http://[VM_IP]:8080/JavaVulnerableLab/install.jsp and click Install.

</details>

<details>
<summary>Standalone JAR with embedded Tomcat (outdated)</summary>

    1. Install a JDK.
    2. Download: http://sourceforge.net/projects/javavulnerablelab/files/v0.2/JavaVulnerableLab.jar/download
    3. Run: java -jar JavaVulnerableLab.jar
    4. Open http://localhost:8080/JavaVulnerableLab/install.jsp and click Install.

</details>

<details>
<summary>WAR file on your own Tomcat (outdated)</summary>

    1. Install Apache Tomcat.
    2. Go to http://[TOMCAT_IP]:8080/manager/ (edit tomcat-users.xml to allow manager access first).
    3. Download: https://sourceforge.net/projects/javavulnerablelab/files/latest/JavaVulnerableLab.war/download
    4. Deploy the WAR through the manager.
    5. Open http://[TOMCAT_IP]:8080/JavaVulnerableLab/install.jsp and click Install.

</details>

To build a current WAR from source instead, run `mvn clean package` and deploy `target/JavaVulnerableLab.war`. It needs a MySQL database and a JDK 8 build environment.

Learning material
-----------------

The full course content is on GitHub for free: https://github.com/CSPF-Founder/JavaSecurityCourse

The full course on hacking and securing Java web programs: https://learn.cysecurity.org/course/view.php?id=3

License
-------

GNU General Public License v2. See [LICENSE](LICENSE).
