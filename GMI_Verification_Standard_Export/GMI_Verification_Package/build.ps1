# Build script for packaging NovaFuse GMI docs to HTML/PDF and building verification assets

param(
    [string]$DocsDir = "GMI_Verification_Package/docs",
    [string]$OutDir = "GMI_Verification_Package/docs/dist",
    [switch]$Clean,
    [switch]$Test,
    [switch]$Doc
)

Write-Host "Packaging docs from '$DocsDir' to '$OutDir'" -ForegroundColor Cyan

if (-Not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$mdFiles = Get-ChildItem -Path $DocsDir -Filter *.md -File
if ($mdFiles.Count -eq 0) {
    Write-Host "No markdown files found in '$DocsDir'" -ForegroundColor Yellow
}

function Html-Escape {
    param([string]$Text)
    if ($null -eq $Text) { return "" }
    $escaped = $Text -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;' -replace "'","&#39;"
    return $escaped
}

function Convert-ToHtml {
    param([string]$InputPath, [string]$OutputPath)
    $content = Get-Content -Path $InputPath -Raw
    $escaped = Html-Escape -Text $content
    $html = "<html><head><meta charset='utf-8'><title>$(Split-Path $InputPath -Leaf)</title></head><body><pre>" + $escaped + "</pre></body></html>"
    Set-Content -Path $OutputPath -Value $html -Encoding UTF8
}

$pandoc = Get-Command pandoc -ErrorAction SilentlyContinue
foreach ($md in $mdFiles) {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($md.FullName)
    $htmlOut = Join-Path $OutDir ($base + ".html")
    $pdfOut = Join-Path $OutDir ($base + ".pdf")
    # Always produce HTML
    Convert-ToHtml -InputPath $md.FullName -OutputPath $htmlOut
    # Produce PDF if pandoc is available
    if ($pandoc) {
        & $pandoc $md.FullName -o $pdfOut
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Pandoc failed for '$($md.Name)'; HTML produced" -ForegroundColor Yellow
        } else {
            Write-Host "Generated PDF: $pdfOut" -ForegroundColor Green
        }
    } else {
        Write-Host "Pandoc not found; skipping PDF for '$($md.Name)'" -ForegroundColor Yellow
    }
    Write-Host "Generated HTML: $htmlOut" -ForegroundColor Green
}

Write-Host "Done." -ForegroundColor Cyan
# GMI Genesis Verification Package Build Script

# Configuration
$config = @{
    CoqPath  = "D:\Coq-Platform~8.20~2025.01\bin"
    SourceDir = "proofs\v3.0.0\coq"
    OutputDir = "artifacts"
    DocDir = "docs"
}

$ErrorActionPreference = "Stop"

# Ensure base directories exist
$base = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $base
New-Item -ItemType Directory -Path $config.SourceDir -Force | Out-Null
New-Item -ItemType Directory -Path $config.OutputDir -Force | Out-Null
New-Item -ItemType Directory -Path $config.DocDir -Force | Out-Null
New-Item -ItemType Directory -Path "scripts" -Force | Out-Null
New-Item -ItemType Directory -Path "tests" -Force | Out-Null

# Add Coq to PATH for this session
if (-not (Test-Path $config.CoqPath)) { throw "Coq bin not found at $($config.CoqPath)" }
$env:Path = "$($config.CoqPath);$env:Path"

function Invoke-Clean {
    Write-Host "Cleaning build artifacts..." -ForegroundColor Yellow
    if (Test-Path $config.OutputDir) {
        Get-ChildItem -Path $config.OutputDir -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }
    Get-ChildItem -Path $config.SourceDir -Include "*.vo","*.glob","*.vok","*.vos" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
}

function Invoke-Build {
    Write-Host "Building GMI Genesis Verification Package..." -ForegroundColor Cyan
    Push-Location $config.SourceDir
    try {
        # Create _CoqProject
        Set-Content -Path "_CoqProject" -Value "-R . NovaFuse" -Encoding Ascii

        # Show tool versions
        & "$($config.CoqPath)\coqc.exe" --version
        if (Test-Path "$($config.CoqPath)\coqdoc.exe") { & "$($config.CoqPath)\coqdoc.exe" --version }

        # Compile Coq files
        & "$($config.CoqPath)\coqc.exe" -Q . NovaFuse GMI_Genesis_Lyapunov_v3.v

        # Copy artifacts to output directory
        Pop-Location
        Copy-Item -Path "$($config.SourceDir)\GMI_Genesis_Lyapunov_v3.*" -Destination "$($config.OutputDir)\" -Force

        Write-Host "Build completed successfully!" -ForegroundColor Green
    }
    catch {
        Pop-Location
        Write-Error "Build failed: $_"
        exit 1
    }
}

function Invoke-Test {
    Write-Host "Running verification tests..." -ForegroundColor Cyan
    
    # Run adversarial test suite
    # Look in repo root first, then in local scripts directory
    $rootDir = Split-Path -Parent $base
    $adversarialScript = Join-Path $rootDir "scripts\test\adversarial_suite.js"
    
    if (-not (Test-Path $adversarialScript)) {
        $adversarialScript = Join-Path $base "scripts\test\adversarial_suite.js"
    }
    
    if (Test-Path $adversarialScript) {
        Write-Host "Running GMI Genesis Adversarial Test Suite..." -ForegroundColor Cyan
        
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $outputPath = Join-Path $base $config.OutputDir
        $outBase = Join-Path $outputPath "adversarial_test_$timestamp"
        
        Write-Host "Test script: $adversarialScript" -ForegroundColor Gray
        Write-Host "Output base: $outBase" -ForegroundColor Gray
        
        & node $adversarialScript --all --out $outBase --formats "json,html,csv"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Adversarial tests passed! ✅" -ForegroundColor Green
            Write-Host "Results saved to: $outBase.*" -ForegroundColor Green
        } else {
            Write-Host "Adversarial tests had failures. ❌" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Adversarial test suite not found at $adversarialScript" -ForegroundColor Red
        Write-Host "Searched locations:" -ForegroundColor Yellow
        Write-Host "  - $rootDir\scripts\test\adversarial_suite.js" -ForegroundColor Yellow
        Write-Host "  - $base\scripts\test\adversarial_suite.js" -ForegroundColor Yellow
    }
}

function Invoke-GenerateDoc {
    Write-Host "Generating documentation..." -ForegroundColor Cyan
    Push-Location $config.SourceDir
    try {
        if (Test-Path "$($config.CoqPath)\coqdoc.exe") {
            & "$($config.CoqPath)\coqdoc.exe" --latex -o "GMI_Genesis_Lyapunov_v3.tex" GMI_Genesis_Lyapunov_v3.v
            Pop-Location
            Copy-Item -Path "$($config.SourceDir)\GMI_Genesis_Lyapunov_v3.tex" -Destination "$($config.DocDir)\" -Force
            Write-Host "Documentation generated: $($config.DocDir)\GMI_Genesis_Lyapunov_v3.tex" -ForegroundColor Green
        } else {
            Pop-Location
            Write-Warning "coqdoc.exe not found at $($config.CoqPath). Skipping documentation generation."
        }
    } catch {
        Pop-Location
        Write-Error "Documentation generation failed: $_"
        exit 1
    }
}

if ($Clean) { Invoke-Clean }
Invoke-Build
if ($Test) { Invoke-Test }
if ($Doc) { Invoke-GenerateDoc }
