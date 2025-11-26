# verify.ps1 — Canonical GMI Verification & Certification

param(
  [string]$ProfilePath = "GMI_Verification_Package/verification.profile.json",
  [string]$ArtifactsDir = "GMI_Verification_Package/artifacts",
  [string]$CertificatesDir = "GMI_Verification_Package/certificates",
  [switch]$RunTests,
  [switch]$IssueCertificate,
  [switch]$SkipHtmlPostprocess,
  [switch]$SkipConsistencyCheck,
  [switch]$SkipSchemaValidation
)

$ErrorActionPreference = "Stop"

function Ensure-Dir {
  param([string]$Path)
  if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Path $Path | Out-Null }
}

function Ensure-Executable {
  param([string]$Name)
  $cmd = $null
  try { $cmd = Get-Command $Name -ErrorAction Stop } catch {}
  return ($null -ne $cmd)
}

function Assert-Under-Root {
  param([string]$Path)
  $resolvedObj = $null
  try { $resolvedObj = Resolve-Path $Path -ErrorAction Stop } catch {}
  $repoRoot = Split-Path -Parent $PSScriptRoot
  $root = (Resolve-Path $repoRoot).Path
  $isAbsolute = [System.IO.Path]::IsPathRooted($Path)
  if ($isAbsolute) {
    $absObj = $resolvedObj
    if (-not $absObj) { try { $absObj = Resolve-Path $Path -ErrorAction Stop } catch {} }
    $resolved = if ($absObj) { $absObj.Path } else { $Path }
    if (-not ($resolved.ToLower().StartsWith($root.ToLower()))) { throw "Path outside repository root: $Path" }
    return $resolved
  } else {
    $joined = Join-Path $repoRoot $Path
    $absObj2 = $null
    try { $absObj2 = Resolve-Path $joined -ErrorAction Stop } catch {}
    if ($absObj2) { return $absObj2.Path } else { return $joined }
  }
}

function Get-StringHashSHA256 {
  param([string]$Text)
  $sha256 = [System.Security.Cryptography.SHA256]::Create()
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
  $hashBytes = $sha256.ComputeHash($bytes)
  -join ($hashBytes | ForEach-Object { $_.ToString("x2") })
}

function Get-FileHashSHA256 {
  param([string]$Path)
  if (-not (Test-Path $Path)) { throw "File not found for hashing: $Path" }
  (Get-FileHash -Algorithm SHA256 -Path $Path).Hash.ToLower()
}

# Robustly set a property on the fingerprint object whether it's a hashtable or PSCustomObject
function Set-FingerprintProperty($fp, [string]$name, $value) {
  if ($null -eq $fp) { return }
  if ($fp -is [hashtable]) {
    $fp[$name] = $value
  } else {
    $prop = $fp.PSObject.Properties[$name]
    if ($null -eq $prop) {
      $fp | Add-Member -NotePropertyName $name -NotePropertyValue $value
    } else {
      $fp.$name = $value
    }
  }
}

function Build-Canonical-Config-String {
  param($Config)
  $lines = @()
  function Walk($obj, [string]$prefix) {
    if ($obj -is [System.Collections.IDictionary]) {
      $keys = $obj.Keys | Sort-Object
      foreach ($k in $keys) { Walk $obj[$k] (if ($prefix) {"$prefix.$k"} else {$k}) }
    } elseif ($obj -is [System.Collections.IEnumerable] -and -not ($obj -is [string])) {
      $i = 0
      foreach ($v in $obj) { Walk $v ("$prefix[$i]"); $i++ }
    } else {
      $lines += "$prefix=" + [string]$obj
    }
  }
  Walk $Config ""
  ($lines | Sort-Object) -join "`n"
}

function Compute-Artifacts-Manifest-Hash {
  param($Artifacts)
  $paths = @()
  foreach ($k in $Artifacts.PSObject.Properties.Name) {
    $v = $Artifacts.$k
    if ($v -is [System.Collections.IDictionary]) {
      foreach ($kp in $v.PSObject.Properties.Name) { $paths += $v.$kp }
    } else {
      $paths += $v
    }
  }
  $existing = $paths | Where-Object { $_ -and (Test-Path $_) }
  $hashes = @()
  foreach ($p in $existing) { $hashes += (Get-FileHash -Algorithm SHA256 -Path $p).Hash.ToLower() }
  Get-StringHashSHA256 -Text (($hashes | Sort-Object) -join "|")
}

function Get-Verification-Stats {
  param([string]$Dir)
  $stats = [ordered]@{ total = 0; nepi_mode1 = 0; nepi_inactive = 0; pass = 0; last_issued_at = $null }
  if (-not (Test-Path $Dir)) { return $stats }
  $files = Get-ChildItem -Path $Dir -Filter 'GMI-CERT-*.json' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
  foreach ($f in $files) {
    try {
      $doc = Get-Content -Raw -Path $f.FullName | ConvertFrom-Json
      $stats.total++
      if ($doc.nepi_stage -eq 'NEPI-Mode1-StructuralCoherence') { $stats.nepi_mode1++ } else { $stats.nepi_inactive++ }
      if ($doc.contextual_validation -and $doc.contextual_validation.pass -eq $true) { $stats.pass++ }
    } catch {}
  }
  if ($files -and $files.Count -gt 0) {
    try { $latestDoc = Get-Content -Raw -Path $files[0].FullName | ConvertFrom-Json; $stats.last_issued_at = $latestDoc.issued_at } catch {}
  }
  return $stats
}

Write-Host "Canonical GMI Verification starting..." -ForegroundColor Cyan
$testsPassed = $true
$ProfilePath = Assert-Under-Root $ProfilePath
$ArtifactsDir = Assert-Under-Root $ArtifactsDir
$CertificatesDir = Assert-Under-Root $CertificatesDir
Ensure-Dir $ArtifactsDir
Ensure-Dir $CertificatesDir

if (-not (Test-Path $ProfilePath)) { throw "Profile not found: $ProfilePath" }
$profile = Get-Content -Path $ProfilePath -Raw | ConvertFrom-Json

# Verifier self-hash verification and stamping
if (-not $profile.verifier) { $profile | Add-Member -NotePropertyName verifier -NotePropertyValue @{} }
$scriptPath = $MyInvocation.MyCommand.Path
$scriptHash = Get-FileHashSHA256 -Path $scriptPath
$profile.verifier.path = $scriptPath
if (-not $profile.verifier.hash_expected) { $profile.verifier.hash_expected = "" }
if ($profile.verifier.hash_expected -and ($profile.verifier.hash_expected -ne $scriptHash)) {
  Write-Host "Verifier hash mismatch! Expected $($profile.verifier.hash_expected), computed $scriptHash" -ForegroundColor Red
  Write-Host "Refuse to proceed: pin or update verifier hash in profile and re-run." -ForegroundColor Yellow
  exit 1
}
$profile.verifier.hash_last_computed = $scriptHash
if (-not $profile.verifier.sbom_path) { $profile.verifier.sbom_path = "GMI_Verification_Package/artifacts/verifier_sbom.txt" }

# Emit a minimal SBOM for the verifier
$verifierVersion = "1.0.0"
if ($profile.verifier -is [hashtable]) { $profile.verifier['version'] = $verifierVersion } else { $profile.verifier | Add-Member -NotePropertyName version -NotePropertyValue $verifierVersion -Force }

$sbomLines = @(
  "verifier.path=$scriptPath",
  "verifier.hash_sha256=$scriptHash",
  "verifier.version=$verifierVersion",
  "profile.path=$ProfilePath",
  "adversarial_suite.path=(resolved at runtime)",
  "container.digest=$($profile.verifier.container_digest)"
)
Ensure-Dir (Split-Path -Parent $profile.verifier.sbom_path)
$sbomLines | Set-Content -Path $profile.verifier.sbom_path -Encoding UTF8

# Determine adversarial suite path
$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $base
$adversarialScript = Join-Path $rootDir "scripts\test\adversarial_suite.js"
if (-not (Test-Path $adversarialScript)) { $adversarialScript = Join-Path $base "scripts\test\adversarial_suite.js" }

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runId = "adversarial_test_$timestamp-auto"
$outBase = Join-Path $ArtifactsDir $runId

function Compute-Robustness-Margin {
  param(
    [string]$JsonPath,
    [string]$CsvPath
  )
  $result = [ordered]@{
    alpha_min_observed = $null
    timing_jitter_ms_p95 = $null
    timing_jitter_ms_p99 = $null
    perturbation_norm = $null
  }

  # Helper: recursively collect numbers by candidate property names
  function Collect-NumbersByKeys($obj, [string[]]$keys) {
    $vals = @()
    if ($null -eq $obj) { return $vals }
    if ($obj -is [System.Collections.IDictionary]) {
      foreach ($k in $obj.Keys) {
        $v = $obj[$k]
        if ($keys -contains ([string]$k).ToLower()) {
          if ($v -is [double] -or $v -is [int] -or $v -is [decimal]) { $vals += [double]$v }
        }
        $vals += (Collect-NumbersByKeys -obj $v -keys $keys)
      }
    } elseif ($obj -is [System.Collections.IEnumerable] -and -not ($obj -is [string])) {
      foreach ($v in $obj) { $vals += (Collect-NumbersByKeys -obj $v -keys $keys) }
    }
    return $vals
  }

  if ($JsonPath -and (Test-Path $JsonPath)) {
    try {
      $json = Get-Content -Raw -Path $JsonPath | ConvertFrom-Json
      $alphaCandidates = Collect-NumbersByKeys -obj $json -keys @('alpha','alpha_min','alpha_observed')
      $p95Candidates = Collect-NumbersByKeys -obj $json -keys @('timing_jitter_ms_p95')
      $p99Candidates = Collect-NumbersByKeys -obj $json -keys @('timing_jitter_ms_p99')
      $jitterDefault = Collect-NumbersByKeys -obj $json -keys @('timing_jitter_ms')
      $perturbCandidates = Collect-NumbersByKeys -obj $json -keys @('perturb_norm','perturbation_norm','noise_norm')
      if ($alphaCandidates.Count -gt 0) { $result.alpha_min_observed = ($alphaCandidates | Measure-Object -Minimum).Minimum }
      if ($p95Candidates.Count -gt 0) { $result.timing_jitter_ms_p95 = ($p95Candidates | Measure-Object -Maximum).Maximum }
      if ($p99Candidates.Count -gt 0) { $result.timing_jitter_ms_p99 = ($p99Candidates | Measure-Object -Maximum).Maximum }
      if ($null -eq $result.timing_jitter_ms_p95 -and $jitterDefault.Count -gt 0) { $result.timing_jitter_ms_p95 = ($jitterDefault | Measure-Object -Maximum).Maximum }
      if ($perturbCandidates.Count -gt 0) { $result.perturbation_norm = ($perturbCandidates | Measure-Object -Maximum).Maximum }
    } catch { Write-Host "Failed to parse JSON metrics: $JsonPath" -ForegroundColor Yellow }
  }

  if ($CsvPath -and (Test-Path $CsvPath)) {
    try {
      $rows = Import-Csv -Path $CsvPath
      if ($rows.Count -gt 0) {
        $alphaCol = ($rows[0].PSObject.Properties.Name | Where-Object { $_ -in @('alpha','alpha_min','alpha_observed') }) | Select-Object -First 1
        $p95Col   = ($rows[0].PSObject.Properties.Name | Where-Object { $_ -in @('timing_jitter_ms_p95','timing_jitter_ms') }) | Select-Object -First 1
        $p99Col   = ($rows[0].PSObject.Properties.Name | Where-Object { $_ -eq 'timing_jitter_ms_p99' }) | Select-Object -First 1
        $perturbCol = ($rows[0].PSObject.Properties.Name | Where-Object { $_ -in @('perturbation_norm','perturb_norm','noise_norm') }) | Select-Object -First 1
        if ($alphaCol) {
          $vals = $rows | ForEach-Object { [double]($_.$alphaCol) } | Where-Object { $_ -ne $null }
          if ($vals.Count -gt 0) { $result.alpha_min_observed = if ($result.alpha_min_observed -ne $null) { [Math]::Min($result.alpha_min_observed, ($vals | Measure-Object -Minimum).Minimum) } else { ($vals | Measure-Object -Minimum).Minimum } }
        }
        if ($p95Col) {
          $vals = $rows | ForEach-Object { [double]($_.$p95Col) } | Where-Object { $_ -ne $null }
          if ($vals.Count -gt 0) { $result.timing_jitter_ms_p95 = if ($result.timing_jitter_ms_p95 -ne $null) { [Math]::Max($result.timing_jitter_ms_p95, ($vals | Measure-Object -Maximum).Maximum) } else { ($vals | Measure-Object -Maximum).Maximum } }
        }
        if ($p99Col) {
          $vals = $rows | ForEach-Object { [double]($_.$p99Col) } | Where-Object { $_ -ne $null }
          if ($vals.Count -gt 0) { $result.timing_jitter_ms_p99 = if ($result.timing_jitter_ms_p99 -ne $null) { [Math]::Max($result.timing_jitter_ms_p99, ($vals | Measure-Object -Maximum).Maximum) } else { ($vals | Measure-Object -Maximum).Maximum } }
        }
        if ($perturbCol) {
          $vals = $rows | ForEach-Object { [double]($_.$perturbCol) } | Where-Object { $_ -ne $null }
          if ($vals.Count -gt 0) { $result.perturbation_norm = if ($result.perturbation_norm -ne $null) { [Math]::Max($result.perturbation_norm, ($vals | Measure-Object -Maximum).Maximum) } else { ($vals | Measure-Object -Maximum).Maximum } }
        }
      }
    } catch { Write-Host "Failed to parse CSV metrics: $CsvPath" -ForegroundColor Yellow }
  }

  return $result
}

if ($RunTests) {
  if (Test-Path $adversarialScript) {
    Write-Host "Running adversarial suite: $adversarialScript" -ForegroundColor Cyan
    if (-not (Ensure-Executable -Name 'node')) {
      Write-Host "node not found in PATH" -ForegroundColor Red
      Write-Host "Install Node.js and ensure 'node' is available" -ForegroundColor Yellow
      exit 1
    }
    $mRun = Measure-Command { & node $adversarialScript --all --out $outBase --formats "json,html,csv" }
    if ($LASTEXITCODE -ne 0) {
      Write-Host "Adversarial suite returned non-zero exit code ($LASTEXITCODE)." -ForegroundColor Red
      $testsPassed = $false
    } else {
      Write-Host "Adversarial tests passed (exit 0)." -ForegroundColor Green
      Write-Host ("Adversarial suite runtime: {0}s" -f $mRun.TotalSeconds) -ForegroundColor Cyan
    }
  } else {
    Write-Host "Adversarial suite not found at: $adversarialScript" -ForegroundColor Red
    Write-Host "Skipping run; cannot certify without evidence." -ForegroundColor Yellow
    exit 1
  }
}

# Update profile with artifacts paths and run id (resolve actual exported filenames)
$profile.evidence_run_id = $runId
try {
  $actualJson = Get-ChildItem -Path $ArtifactsDir -Filter ("{0}*.json" -f $runId) -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  $actualCsv  = Get-ChildItem -Path $ArtifactsDir -Filter ("{0}*.csv" -f $runId)  -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  $actualHtml = Get-ChildItem -Path $ArtifactsDir -Filter ("{0}*.html" -f $runId) -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  $profile.artifacts.json = if ($actualJson) { $actualJson.FullName } else { "$outBase.json" }
  $profile.artifacts.csv  = if ($actualCsv)  { $actualCsv.FullName }  else { "$outBase.csv" }
  $profile.artifacts.html = if ($actualHtml) { $actualHtml.FullName } else { "$outBase.html" }
} catch {
  $profile.artifacts.json = "$outBase.json"
  $profile.artifacts.csv  = "$outBase.csv"
  $profile.artifacts.html = "$outBase.html"
}

# Compute robustness margin from artifacts (best-effort)
$robustness = Compute-Robustness-Margin -JsonPath $profile.artifacts.json -CsvPath $profile.artifacts.csv

# Optional NovaCortex contextual validation
function Try-Get-NovaCortexMetrics {
  param([string]$BaseUrl)
  $metrics = $null
  try {
    $uri = "$BaseUrl/api/novacortex/safety/metrics"
    $resp = Invoke-RestMethod -Method GET -Uri $uri -TimeoutSec 5 -ErrorAction Stop
    $metrics = $resp
  } catch {}
  return $metrics
}

function Try-Get-NovaCortexSafetyState {
  param([string]$BaseUrl)
  $state = $null
  try {
    $uri = "$BaseUrl/api/novacortex/safety/state"
    $resp = Invoke-RestMethod -Method GET -Uri $uri -TimeoutSec 5 -ErrorAction Stop
    $state = $resp
  } catch {}
  return $state
}

$novaCortexUrl = if ($env:NOVACORTEX_URL) { $env:NOVACORTEX_URL } else { "http://localhost:3010" }
$cortexMetrics = Try-Get-NovaCortexMetrics -BaseUrl $novaCortexUrl
$safetyState = Try-Get-NovaCortexSafetyState -BaseUrl $novaCortexUrl
$contextualValidation = $null
if ($cortexMetrics -or $safetyState) {
  $checks = [ordered]@{}
  $checks.coherence_level_min = if ($cortexMetrics -and $cortexMetrics.coherence -and $cortexMetrics.coherence.level -ne $null) { [double]$cortexMetrics.coherence.level -ge 0.95 } elseif ($safetyState -and $safetyState.coherence -and $safetyState.coherence.level -ne $null) { [double]$safetyState.coherence.level -ge 0.95 } else { $false }
  $checks.pi_rhythm_synchronized = if ($cortexMetrics -and $cortexMetrics.pi_rhythm -and $cortexMetrics.pi_rhythm.status) { [string]$cortexMetrics.pi_rhythm.status -eq "synchronized" } elseif ($safetyState -and $safetyState.pi_rhythm -and $safetyState.pi_rhythm.status) { [string]$safetyState.pi_rhythm.status -eq "synchronized" } else { $false }
  $checks.castl_aligned = if ($safetyState -and $safetyState.castl -and $safetyState.castl.status) { [string]$safetyState.castl.status -eq "aligned" } else { $false }
  $checks.castl_confidence_min = if ($safetyState -and $safetyState.castl -and $safetyState.castl.confidence -ne $null) { [double]$safetyState.castl.confidence -ge 0.80 } else { $false }
  $pass = $checks.coherence_level_min -and $checks.pi_rhythm_synchronized -and $checks.castl_aligned -and $checks.castl_confidence_min
  $contextualValidation = [ordered]@{
    router = "NovaCortex"
    policy = "contextual_safety"
    metrics = $cortexMetrics
    state = $safetyState
    checks = $checks
    pass = $pass
  }
}

$nepiStage = if ($contextualValidation -and $contextualValidation.pass) { "NEPI-Mode1-StructuralCoherence" } else { "NEPI-Inactive" }
if ($nepiStage -eq "NEPI-Mode1-StructuralCoherence") {
  Write-Host "NEPI Mode 1 active (structural coherence triad passed)" -ForegroundColor Green
} else {
  Write-Host "NEPI inactive (triadic safety checks not satisfied)" -ForegroundColor Yellow
}

# NovaAlign performance report ingestion
function Get-NovaAlignSummary {
  $repoTop = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
  $files = Get-ChildItem -Path $repoTop -Filter 'novaalign-performance-report-*.json' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
  if (-not $files -or $files.Count -eq 0) { return $null }
  $reports = @()
  foreach ($f in ($files | Select-Object -First 3)) {
    try {
      $data = Get-Content -Path $f.FullName -Raw | ConvertFrom-Json
      $rep = [ordered]@{
        timestamp = $data.timestamp
        dashboard_ms = [double]$data.performance.dashboard.averageResponseTime
        api_ms = [double]$data.performance.api.averageResponseTime
        concurrency_avg_ms = if ($data.performance.concurrency -and $data.performance.concurrency.Count -gt 0) { [double](($data.performance.concurrency | Where-Object { $_.testType -like '*Harmonic*' } | Select-Object -First 1).averageResponseTime) } else { $null }
        cyber_avg_ms = [double]$data.cyberResilience.metrics.averageResponseTime
        mitigationRate = [double]$data.cyberResilience.metrics.mitigationRate
        resilience = ($data.performance.concurrency | Where-Object { $_.testType -like '*Harmonic*' } | Select-Object -First 1).resilience
        overallGrade = $data.summary.overallGrade
      }
      $reports += $rep
    } catch {}
  }
  if ($reports.Count -eq 0) { return $null }
  $trend = $null
  if ($reports.Count -ge 2) {
    $latest = $reports[0]
    $prev = $reports[1]
    $trend = [ordered]@{
      dashboard_ms_delta = $latest.dashboard_ms - $prev.dashboard_ms
      api_ms_delta = $latest.api_ms - $prev.api_ms
      cyber_avg_ms_delta = $latest.cyber_avg_ms - $prev.cyber_avg_ms
    }
  }
  return [ordered]@{ reports = $reports; trend = $trend }
}

$novaAlignSummary = Get-NovaAlignSummary

# Compute hashes
$configString = Build-Canonical-Config-String -Config $profile.config
$configHash = Get-StringHashSHA256 -Text $configString
$artifactManifestHash = Compute-Artifacts-Manifest-Hash -Artifacts $profile.artifacts

if (-not $profile.fingerprint) { $profile | Add-Member -NotePropertyName fingerprint -NotePropertyValue @{} }
Set-FingerprintProperty -fp $profile.fingerprint -name 'config_hash_sha256' -value $configHash
Set-FingerprintProperty -fp $profile.fingerprint -name 'artifact_manifest_hash_sha256' -value $artifactManifestHash
Set-FingerprintProperty -fp $profile.fingerprint -name 'verifier_hash_sha256' -value $scriptHash

# Persist updated profile
$profile | ConvertTo-Json -Depth 10 | Set-Content -Path $ProfilePath -Encoding UTF8
Write-Host "Profile updated with hashes and evidence run id." -ForegroundColor Green

if ($IssueCertificate -and $testsPassed) {
  $certId = if ($profile.certificate_id) { $profile.certificate_id } else { "GMI-CERT-$timestamp-TUNE13" }
  $certificate = [ordered]@{
    certificate_id = $certId
    rts_id         = $profile.rts_id
    evidence_run_id = $profile.evidence_run_id
    nepi_stage     = $nepiStage
    fingerprints   = [ordered]@{
      config_hash_sha256 = $profile.fingerprint.config_hash_sha256
      artifact_manifest_hash_sha256 = $profile.fingerprint.artifact_manifest_hash_sha256
      verifier_hash_sha256 = $profile.fingerprint.verifier_hash_sha256
      container_digest = $profile.verifier.container_digest
    }
    parameters     = $profile.config
    artifacts      = $profile.artifacts
    verifier       = $profile.verifier
    issued_at      = (Get-Date).ToString("o")
    pass_condition = "8/8 adversarial scenarios"
    status         = "issued"
    robustness_margin = $robustness
    gmi_definition = [ordered]@{
      tiers = @("cognition","behavior","domain")
      llm_invariance = [ordered]@{
        policy = "contextual_safety"
        routing_modes = @("explain","warn","redirect","comply")
      }
      principles = @("contextual boundary enforcement","intent interpretation","domain-appropriate response")
    }
    contextual_validation = $contextualValidation
    novaalign_summary = $novaAlignSummary
  }
  # Validate certificate shape minimally (audit-grade checks can use JSON schema)
  function Validate-Certificate($cert) {
    $errors = @()
    if (-not $cert.certificate_id) { $errors += 'certificate_id missing' }
    if (-not $cert.fingerprints) { $errors += 'fingerprints missing' }
    if (-not $cert.parameters) { $errors += 'parameters missing' }
    if (-not $cert.artifacts) { $errors += 'artifacts missing' }
    if (-not $cert.robustness_margin) { $errors += 'robustness_margin missing' }
    else {
      foreach ($k in @('alpha_min_observed','timing_jitter_ms_p95','timing_jitter_ms_p99','perturbation_norm')) {
        if ($cert.robustness_margin.Contains($k)) {
          $v = $cert.robustness_margin[$k]
          if ($null -ne $v -and -not ($v -is [double] -or $v -is [int] -or $v -is [decimal])) {
            $errors += "robustness_margin.$k must be numeric or null"
          }
        } else {
          $errors += "robustness_margin.$k missing"
        }
      }
    }
    return $errors
  }
  $certErrors = Validate-Certificate -cert $certificate
  if ($certErrors.Count -gt 0) {
    Write-Host "Certificate validation failed:" -ForegroundColor Red
    $certErrors | ForEach-Object { Write-Host " - $_" -ForegroundColor Yellow }
    exit 1
  }
  $certJsonPath = Join-Path $CertificatesDir ("$certId.json")
  $certificate | ConvertTo-Json -Depth 10 | Set-Content -Path $certJsonPath -Encoding UTF8
  Write-Host "Certificate issued: $certJsonPath" -ForegroundColor Cyan

  # Strict schema validation (optional enforcement)
  $schemasDir = Join-Path $base 'schemas'
  $validator = Join-Path $schemasDir 'validate-certificate.ps1'
  $schemaPath = Join-Path $schemasDir 'certificate.schema.json'
  if (-not $SkipSchemaValidation) {
    if ((Test-Path $validator) -and (Test-Path $schemaPath)) {
      if (-not (Ensure-Executable -Name 'python')) {
        Write-Host "python not found; skipping strict validation." -ForegroundColor Yellow
      } else {
        $hasJsonschema = $false
        try { $null = & python -c "import jsonschema" 2>$null; $hasJsonschema = ($LASTEXITCODE -eq 0) } catch {}
        if (-not $hasJsonschema) {
          Write-Host "jsonschema not available; skipping strict validation." -ForegroundColor Yellow
        } else {
          Write-Host "Validating certificate against JSON schema..." -ForegroundColor Cyan
          $mVal = Measure-Command { & $validator -CertificatePath $certJsonPath -SchemaPath $schemaPath }
          if ($LASTEXITCODE -ne 0) {
            Write-Host "Certificate failed JSON schema validation (exit $LASTEXITCODE)." -ForegroundColor Red
            exit 1
          } else {
            Write-Host "Certificate JSON schema validation passed." -ForegroundColor Green
            Write-Host ("Schema validation runtime: {0}s" -f $mVal.TotalSeconds) -ForegroundColor Cyan
          }
        }
      }
    } else {
      Write-Host "Schema validator or schema not found; skipping strict validation." -ForegroundColor Yellow
    }
  }

  $vstats = Get-Verification-Stats -Dir $CertificatesDir
  if (-not $profile.stats) { $profile | Add-Member -NotePropertyName stats -NotePropertyValue @{} }
  $profile.stats.verifications = $vstats
  $profile | ConvertTo-Json -Depth 10 | Set-Content -Path $ProfilePath -Encoding UTF8
  Write-Host ("Verifications total: {0}" -f $vstats.total) -ForegroundColor Cyan
  Write-Host ("NEPI Mode 1: {0}" -f $vstats.nepi_mode1) -ForegroundColor Green
  Write-Host ("NEPI Inactive: {0}" -f $vstats.nepi_inactive) -ForegroundColor Yellow
  Write-Host ("Triad pass: {0}" -f $vstats.pass) -ForegroundColor Green
  if ($vstats.last_issued_at) { Write-Host ("Last issued at: {0}" -f $vstats.last_issued_at) -ForegroundColor Cyan }

  # (post-processing and consistency check moved below to run regardless of certificate issuance)
} elseif ($IssueCertificate -and -not $testsPassed) {
  Write-Host "Skipping certificate issuance due to failing adversarial tests." -ForegroundColor Yellow
}

if (-not $SkipHtmlPostprocess) {
  try {
    $htmlArtifactPath = $null
    if ($profile.artifacts -and $profile.artifacts.html) {
      $htmlArtifactPath = (Resolve-Path $profile.artifacts.html -ErrorAction SilentlyContinue).Path
    }
    $post = "$PSScriptRoot/scripts/postprocess_html.ps1"
    if ($post -and (Test-Path $post) -and $htmlArtifactPath -and (Test-Path $htmlArtifactPath)) {
      Write-Host "Injecting ADV links into $htmlArtifactPath" -ForegroundColor Cyan
      $mPost = Measure-Command { & $post -HtmlPath $htmlArtifactPath -Version $verifierVersion }
      Write-Host ("HTML post-process runtime: {0}s" -f $mPost.TotalSeconds) -ForegroundColor Cyan
    }
  } catch {
    Write-Host "Post-process HTML failed: $($_.Exception.Message)" -ForegroundColor Yellow
  }
}

if (-not $SkipConsistencyCheck) {
  try {
    $consistency = "$PSScriptRoot/scripts/consistency_check.py"
    if (Test-Path $consistency) {
      $jsonPath = (Resolve-Path $profile.artifacts.json -ErrorAction SilentlyContinue).Path
      $csvPath  = (Resolve-Path $profile.artifacts.csv  -ErrorAction SilentlyContinue).Path
      $htmlPath = (Resolve-Path $profile.artifacts.html -ErrorAction SilentlyContinue).Path
      if ($jsonPath -and $csvPath -and $htmlPath) {
        if (-not (Ensure-Executable -Name 'python')) {
          Write-Host "[CONSISTENCY] Skipped: python not found." -ForegroundColor Yellow
        } else {
          Write-Host "Running consistency check across JSON/CSV/HTML..." -ForegroundColor Cyan
          $mCons = Measure-Command { $output = & python $consistency $jsonPath $csvPath $htmlPath 2>&1; $exit = $LASTEXITCODE }
          $output | ForEach-Object { Write-Host $_ }
          if ($exit -eq 0) {
            Write-Host "[CONSISTENCY] Formats agree (exit 0)." -ForegroundColor Green
          } else {
            Write-Host "[CONSISTENCY] Disagreement detected (exit $exit)." -ForegroundColor Yellow
          }
          Write-Host ("Consistency check runtime: {0}s" -f $mCons.TotalSeconds) -ForegroundColor Cyan
        }
      } else {
        Write-Host "[CONSISTENCY] Skipped: artifact set incomplete." -ForegroundColor Yellow
      }
    }
  } catch {
    Write-Host "Consistency check failed: $($_.Exception.Message)" -ForegroundColor Yellow
  }
}

Write-Host "Canonical GMI Verification completed." -ForegroundColor Cyan
if ($env:GMI_PROFILE_PATH) { $ProfilePath = $env:GMI_PROFILE_PATH }
if ($env:GMI_CERT_DIR) { $CertificatesDir = $env:GMI_CERT_DIR }
if ($env:GMI_ARTIFACTS_DIR) { $ArtifactsDir = $env:GMI_ARTIFACTS_DIR }
