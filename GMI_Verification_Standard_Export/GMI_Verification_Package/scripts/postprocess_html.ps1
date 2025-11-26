Param(
  [Parameter(Mandatory=$true)][string]$HtmlPath,
  [string]$Version
)

if (-not (Test-Path -Path $HtmlPath)) {
  Write-Host "[ERROR] HTML file not found: $HtmlPath" -ForegroundColor Red
  exit 1
}

$content = Get-Content -Raw -Path $HtmlPath -Encoding UTF8

# Normalize human labels to canonical metric keys
$canonicalLabelMap = @{
  'Alpha (observed)'        = 'alpha_min_observed'
  'alpha_observed'          = 'alpha_min_observed'
  'timing_jitter_ms (P95)'  = 'timing_jitter_ms_p95'
  'timing_jitter_ms_p95 (P95)' = 'timing_jitter_ms_p95'
  'Jitter (P95 default)'    = 'timing_jitter_ms_p95'
  'Jitter P95'              = 'timing_jitter_ms_p95'
  'Jitter P99'              = 'timing_jitter_ms_p99'
  'timing_jitter_ms_p95_p99' = 'timing_jitter_ms_p99'
  'timing_jitter_ms'        = 'timing_jitter_ms_p95'
  'Perturbation Norm'       = 'perturbation_norm'
  'perturb_max_tolerated_norm' = 'perturbation_norm'
}

foreach ($human in $canonicalLabelMap.Keys) {
  $canon = $canonicalLabelMap[$human]
  $content = $content -replace [Regex]::Escape($human), $canon
}

# Fix duplicated suffixes from prior exports
$content = $content -replace 'timing_jitter_ms_p95_p95', 'timing_jitter_ms_p95'
$content = $content -replace 'timing_jitter_ms_p95_p99', 'timing_jitter_ms_p99'
$content = [Regex]::Replace($content, 'timing_jitter_ms_p95(_p95)+', 'timing_jitter_ms_p95')

# Normalize jitter labels inside metric-label divs by regex
$content = [Regex]::Replace($content, '(<div[^>]*class="metric-label"[^>]*>\s*)timing_jitter_ms[^<]*P95[^<]*(\s*</div>)', '$1timing_jitter_ms_p95$2')
$content = [Regex]::Replace($content, '(<div[^>]*class="metric-label"[^>]*>\s*)timing_jitter_ms[^<]*P99[^<]*(\s*</div>)', '$1timing_jitter_ms_p99$2')

# Map canonical keys to README ADV anchors (aligned to README anchors)
$advMap = @{
  'alpha_min_observed'      = '../../README.md#adv-04-lyapunov-destabilization'
  'timing_jitter_ms_p95'    = '../../README.md#adv-07-timing-attack-resistance'
  'timing_jitter_ms_p99'    = '../../README.md#adv-07-timing-attack-resistance'
  'perturbation_norm'       = '../../README.md#adv-05-perturbation-robustness'
  'timing_jitter_ms_p95_p95' = '../../README.md#adv-07-timing-attack-resistance'
}

foreach ($key in $advMap.Keys) {
  $href = $advMap[$key]
  # Replace plain label occurrences inside table cells or spans with anchor tags
  $patternTd = "(<td>\s*)" + [Regex]::Escape($key) + "(\s*</td>)"
  $patternSpan = "(<span[^>]*>\s*)" + [Regex]::Escape($key) + "(\s*</span>)"
  $patternDiv = '(<div[^>]*class="metric-label"[^>]*>\s*)' + [Regex]::Escape($key) + '(\s*</div>)'
  $anchor = "<a href='{0}'>{1}</a>" -f $href, $key
  $replacementTd = '$1' + $anchor + '$2'
  $replacementSpan = '$1' + $anchor + '$2'
  $replacementDiv = '$1' + $anchor + '$2'
  $content = [Regex]::Replace($content, $patternTd, $replacementTd)
  $content = [Regex]::Replace($content, $patternSpan, $replacementSpan)
  $content = [Regex]::Replace($content, $patternDiv, $replacementDiv)
}

# Add a small footer note referencing Metrics Definitions
if ($content -notmatch 'Metrics_Definitions.md') {
  $note = '<div style="margin-top:12px;font-size:12px;color:#555">See Metrics_Definitions.md for calculation details.</div>'
  $content = $content -replace '</body>', ($note + '</body>')
}

# Insert Compliance & Safety banner linking to COMPLIANCE.md (avoid duplicates)
if ($content -notmatch 'id="gmi-compliance-banner"') {
  $banner = '<div id="gmi-compliance-banner" style="background:#eef7ff;border:1px solid #bcdfff;padding:8px 12px;margin:12px 0;font-size:13px;color:#004c99">Compliance & Safety: See <a href="../../docs/COMPLIANCE.md">COMPLIANCE.md</a> for SLSA provenance, Runtime Barrier Guard, and validation workflow.</div>'
  $content = [Regex]::Replace($content, "(<body[^>]*>)", '$1' + $banner)
}

if ($Version -and ($content -notmatch 'id="gmi-version-banner"')) {
  $vb = '<div id="gmi-version-banner" style="background:#f8f9fa;border:1px solid #ddd;padding:6px 10px;margin:8px 0;font-size:12px;color:#333">Verifier version: ' + $Version + '</div>'
  $content = [Regex]::Replace($content, "(<body[^>]*>)", '$1' + $vb)
}

Set-Content -Path $HtmlPath -Value $content -Encoding UTF8
Write-Host "Post-processed HTML with ADV links: $HtmlPath" -ForegroundColor Green
