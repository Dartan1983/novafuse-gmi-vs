# Enhanced integrity verification with PDF support and final package hash validation
param(
    [switch]$SkipSelfCheck = $false,
    [string]$ExpectedPackageHash = "C8B3F81374CECF3EB97379BC7581654B49DA77E0A85DACB3EE68CDA9B1897EBC"
)

Write-Host "=== GMI Verification Package Integrity Check ===" -ForegroundColor Cyan

# Expected hashes for all core artifacts including PDFs
$expectedHashes = @{
    "README.md" = "76D7B35752772CA437FFC493949783F02F4F8558A4ACF89852B7369E9D18F6FE"
    "BUILD_INSTRUCTIONS.md" = "F1B3680D0D68D33F973DF6E1B59709AD313920FFB9AF62F4311F7C43FFBFABE4"
    "EVIDENCE_SUMMARY.md" = "7B1DABDC44AF59D04D006F2252463F07DC9E074F62CD3129CBFBCBFE5557B855"
    "INTEGRITY_MANIFEST.md" = "DBB7C6376E5A1A651619EEB3483D873258C276146EF6C493040DEBD601ED2408"
    "README.pdf" = "C5F05C1D40BBBEB2C24344F7901FE9B943FE065E76D1B699DBC6DEE8D4DAD503"
    "BUILD_INSTRUCTIONS.pdf" = "8D6F49475C39C3CCA2B9D5D9156A4C7441011BB1F7F96F32622196539DE1388A"
    "EVIDENCE_SUMMARY.pdf" = "45EA39220EC35F77E4EBDE78715AECC20722257DB51CC28F232E4E38A662C06E"
    "INTEGRITY_MANIFEST.pdf" = "2EE84E322BF2FB1C33BC355AA5971A76F5EFD482833852B75C3BFAFDEE80727A"
    "proofs\v3.0.0\empirical_validation\run_full_validation_suite.py" = "A2CE43D99C1F62F8F5187CF7C6E718316BFD604DCE037E2C4836F73C524EFA74"
    "proofs\v3.0.0\coq\GMI_Genesis_Lyapunov_v3.v" = "367A13A884DD69715ACAF900C7EF427093D23B99965C0CCB839D7DE3D2239BE6"
    "proofs\v3.0.0\coq\_CoqProject" = "EB092A918E5A69C3CEFE7A315CCB5FBF32AB28AD422DCF9F8DFB21B0F148211B"
    "proofs\v3.0.0\empirical_validation\run_quick_test.py" = "16D211342E03384272C8A1FEBBB6FB9BDDD44DDDDDF4B3151FD32120A960601B"
    "proofs\v3.0.0\empirical_validation\configs\gmi_validation_20251110.yaml" = "D5C67C7BE3CF9A7F3017ABB4FEB35C08F3A64FAB8A7062F0D2B5CD3B3E37ADFF"
    "proofs\v3.0.0\empirical_validation\results\validation_report_20251110_220933.json" = "F46DD49C0D833C18F64A25E31DE7A49C33DA1A525D1097AD6D0460D6002BC5E0"
}

$allPassed = $true

# Self-check skip logic with zero false warnings
if ($SkipSelfCheck) {
    Write-Host "[SKIP] Self-check mode enabled - zero false warnings" -ForegroundColor Yellow
} else {
    Write-Host "[INFO] Full integrity verification in progress..." -ForegroundColor Green
}

# Verify each artifact
foreach ($file in $expectedHashes.Keys) {
    if (Test-Path $file) {
        $actualHash = (Get-FileHash $file -Algorithm SHA256).Hash
        if ($actualHash -eq $expectedHashes[$file]) {
            Write-Host "[OK] $file - OK" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] $file - HASH MISMATCH" -ForegroundColor Red
            Write-Host "  Expected: $($expectedHashes[$file])" -ForegroundColor Red
            Write-Host "  Actual: $actualHash" -ForegroundColor Red
            $allPassed = $false
        }
    } else {
        Write-Host "[FAIL] $file - FILE NOT FOUND" -ForegroundColor Red
        $allPassed = $false
    }
}

# Final package hash validation
$packageFile = "..\GMI_Verification_Package_20251116_024000_Final_With_PDFs.zip"
if (Test-Path $packageFile) {
    $packageHash = (Get-FileHash $packageFile -Algorithm SHA256).Hash
    if ($packageHash -eq $ExpectedPackageHash) {
        Write-Host "[OK] Final package hash matches letter: $ExpectedPackageHash" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Final package hash mismatch!" -ForegroundColor Red
        Write-Host "  Expected: $ExpectedPackageHash" -ForegroundColor Red
        Write-Host "  Actual: $packageHash" -ForegroundColor Red
        $allPassed = $false
    }
} else {
    Write-Host "[WARN] Final package file not found at: $packageFile" -ForegroundColor Yellow
}

# Final result
if ($allPassed) {
    Write-Host "=== Integrity Check Complete ===" -ForegroundColor Green
    Write-Host "All artifacts verified successfully" -ForegroundColor Green
    exit 0
} else {
    Write-Host "=== Integrity Check FAILED ===" -ForegroundColor Red
    Write-Host "Please resolve mismatches before transmission" -ForegroundColor Red
    exit 1
}
