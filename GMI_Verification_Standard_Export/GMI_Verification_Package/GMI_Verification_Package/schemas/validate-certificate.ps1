Param(
  [Parameter(Mandatory=$true)][string]$CertificatePath,
  [Parameter(Mandatory=$false)][string]$SchemaPath = "$PSScriptRoot/certificate.schema.json"
)

function Write-ErrorAndExit([string]$Message) {
  Write-Host "[ERROR] $Message" -ForegroundColor Red
  exit 1
}

if (-not (Test-Path -Path $CertificatePath)) {
  Write-ErrorAndExit "Certificate file not found: $CertificatePath"
}
if (-not (Test-Path -Path $SchemaPath)) {
  Write-ErrorAndExit "Schema file not found: $SchemaPath"
}

# Use Python jsonschema validator if available for strict draft-07 validation
$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) {
  Write-ErrorAndExit "Python not found on PATH. Please install Python, then 'pip install jsonschema'."
}

$pythonScript = @"
import json, sys
try:
    import jsonschema
except ImportError:
    print('[ERROR] Python package jsonschema not installed. Run: pip install jsonschema')
    sys.exit(2)

schema_path = sys.argv[1]
cert_path = sys.argv[2]
with open(schema_path, 'r', encoding='utf-8-sig') as f:
    schema = json.load(f)
with open(cert_path, 'r', encoding='utf-8-sig') as f:
    data = json.load(f)

validator = jsonschema.Draft7Validator(schema)
errors = sorted(validator.iter_errors(data), key=lambda e: e.path)
if errors:
    print('[VALIDATION FAILED] The certificate does not conform to the schema.')
    for e in errors:
        path = '.'.join(str(p) for p in e.path)
        print(f' - {path}: {e.message}')
    sys.exit(3)
else:
    print('[VALIDATION OK] The certificate conforms to the schema.')
    sys.exit(0)
"@

$tempPy = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tempPy -Value $pythonScript -Encoding UTF8

try {
  $proc = & python $tempPy $SchemaPath $CertificatePath
  Write-Host $proc
} finally {
  Remove-Item -Path $tempPy -ErrorAction SilentlyContinue
}
