param(
  [string]$Version = "1.0.0",
  [string]$OutDir = "GMI_Verification_Package/archives",
  [switch]$IncludeRuntimeGuard,
  [string]$Name = "GMI-VS"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$repoTop = Split-Path -Parent $repoRoot
function Ensure-Dir { param([string]$Path) if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Path $Path | Out-Null } }
function Assert-Under-Root { param([string]$Path) $joined = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $repoRoot $Path }; $joined }

$verify = Join-Path $PSScriptRoot 'verify.ps1'
& $verify -RunTests:$true -IssueCertificate:$true

$artDir = Assert-Under-Root 'GMI_Verification_Package/artifacts'
$certDir = Assert-Under-Root 'GMI_Verification_Package/certificates'
$schemasDir = Assert-Under-Root 'GMI_Verification_Package/schemas'

$latestJson = Get-ChildItem -Path $artDir -Filter 'adversarial_test_*auto*.json' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$latestCsv  = Get-ChildItem -Path $artDir -Filter 'adversarial_test_*auto*.csv'  | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$latestHtml = Get-ChildItem -Path $artDir -Filter 'adversarial_test_*auto*.html' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$certFile   = Get-ChildItem -Path $certDir -Filter '*.json' | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $latestJson -or -not $latestCsv -or -not $latestHtml -or -not $certFile) { throw "Artifacts incomplete for release." }

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$relBase = "$Name" + "_v$Version" + "_ThanksgivingLaunch_$timestamp"
$outAbs = Assert-Under-Root $OutDir
Ensure-Dir $outAbs
$staging = Join-Path $outAbs $relBase
Ensure-Dir $staging

Copy-Item -Path $latestJson.FullName -Destination (Join-Path $staging $latestJson.Name)
Copy-Item -Path $latestCsv.FullName  -Destination (Join-Path $staging $latestCsv.Name)
Copy-Item -Path $latestHtml.FullName -Destination (Join-Path $staging $latestHtml.Name)
Copy-Item -Path $certFile.FullName   -Destination (Join-Path $staging $certFile.Name)

Copy-Item -Path (Join-Path $schemasDir 'certificate.schema.json') -Destination (Join-Path $staging 'certificate.schema.json')
Copy-Item -Path (Join-Path $PSScriptRoot 'scripts\consistency_check.py') -Destination (Join-Path $staging 'consistency_check.py')
Copy-Item -Path (Join-Path $PSScriptRoot 'scripts\postprocess_html.ps1') -Destination (Join-Path $staging 'postprocess_html.ps1')
Copy-Item -Path (Join-Path $PSScriptRoot 'verify.ps1') -Destination (Join-Path $staging 'verify.ps1')
Copy-Item -Path (Join-Path $artDir 'verifier_sbom.txt') -Destination (Join-Path $staging 'verifier_sbom.txt') -ErrorAction SilentlyContinue
Copy-Item -Path (Join-Path $repoTop 'LICENSE') -Destination (Join-Path $staging 'LICENSE') -ErrorAction SilentlyContinue

if ($IncludeRuntimeGuard) {
  Copy-Item -Path (Join-Path $repoTop 'runtime\barrier_guard.ps1') -Destination (Join-Path $staging 'barrier_guard.ps1')
  Copy-Item -Path (Join-Path $repoTop 'runtime\telemetry_publisher.ps1') -Destination (Join-Path $staging 'telemetry_publisher.ps1')
  Copy-Item -Path (Join-Path $repoTop 'runtime\install_services.ps1') -Destination (Join-Path $staging 'install_services.ps1')
  Copy-Item -Path (Join-Path $repoTop 'demo\assurance_demo.ps1') -Destination (Join-Path $staging 'assurance_demo.ps1') -ErrorAction SilentlyContinue
}

$manifest = @(
  "release.version=$Version",
  "release.staging=$staging",
  "artifact.json=$($latestJson.Name)",
  "artifact.csv=$($latestCsv.Name)",
  "artifact.html=$($latestHtml.Name)",
  "certificate.json=$($certFile.Name)"
)
$manifest | Set-Content -Path (Join-Path $staging 'RELEASE_MANIFEST.txt') -Encoding UTF8

$zipPath = Join-Path $outAbs ($relBase + '.zip')
if (Test-Path $zipPath) { Remove-Item -Path $zipPath -Force }
Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $zipPath
Write-Host "Release package: $zipPath" -ForegroundColor Cyan
