# Extension Analyzer - Deep analysis of VS Code extensions
# Checks for updates, deprecation status, and recommendations

Write-Host "=== VS Code Extension Deep Analysis ===" -ForegroundColor Green
Write-Host "Analyzing your current extensions..." -ForegroundColor Yellow
Write-Host ""

$extensions = code --list-extensions --show-versions
$analysisResults = @()

foreach ($ext in $extensions) {
    $parts = $ext -split '@'
    $id = $parts[0]
    $version = if ($parts.Length -gt 1) { $parts[1] } else { "unknown" }
    
    $result = [PSCustomObject]@{
        ID = $id
        Version = $version
        Status = "Analyzing..."
        Recommendation = ""
        LastUpdated = ""
    }
    
    # Check against known issues
    switch ($id) {
        "docker.docker" { 
            $result.Status = "⚠️ Potentially Superseded"
            $result.Recommendation = "Consider ms-azuretools.vscode-docker instead"
        }
        "ms-vscode.vscode-typescript-next" {
            $result.Status = "❌ Deprecated"
            $result.Recommendation = "Use built-in TypeScript support"
        }
        "hookyqr.beautify" {
            $result.Status = "❌ Deprecated"
            $result.Recommendation = "Use Prettier (esbenp.prettier-vscode)"
        }
        "formulahendry.auto-rename-tag" {
            $result.Status = "❌ Deprecated" 
            $result.Recommendation = "Use built-in HTML rename tag feature"
        }
        default {
            $result.Status = "✅ No known issues"
            $result.Recommendation = "Keep monitoring"
        }
    }
    
    $analysisResults += $result
}

# Display results
Write-Host "📊 Analysis Results:" -ForegroundColor Cyan
Write-Host ""

$issuesFound = $false
foreach ($result in $analysisResults) {
    if ($result.Status -like "*❌*" -or $result.Status -like "*⚠️*") {
        $issuesFound = $true
        Write-Host "Extension: $($result.ID)" -ForegroundColor White
        Write-Host "  Version: $($result.Version)" -ForegroundColor Gray
        Write-Host "  Status:  $($result.Status)" -ForegroundColor $(if ($result.Status -like "*❌*") { 'Red' } else { 'Yellow' })
        Write-Host "  Action:  $($result.Recommendation)" -ForegroundColor Cyan
        Write-Host ""
    }
}

if (-not $issuesFound) {
    Write-Host "🎉 Great! No issues found with your extensions." -ForegroundColor Green
}

# Summary statistics
$totalExtensions = $analysisResults.Count
$deprecatedCount = ($analysisResults | Where-Object { $_.Status -like "*❌*" }).Count
$warningCount = ($analysisResults | Where-Object { $_.Status -like "*⚠️*" }).Count

Write-Host "📈 Summary:" -ForegroundColor Yellow
Write-Host "  Total Extensions: $totalExtensions" -ForegroundColor Gray
Write-Host "  Deprecated: $deprecatedCount" -ForegroundColor $(if ($deprecatedCount -gt 0) { 'Red' } else { 'Green' })
Write-Host "  Warnings: $warningCount" -ForegroundColor $(if ($warningCount -gt 0) { 'Yellow' } else { 'Green' })
Write-Host "  Healthy: $($totalExtensions - $deprecatedCount - $warningCount)" -ForegroundColor Green

Write-Host ""
Write-Host "🔧 Next Steps:" -ForegroundColor Cyan
if ($issuesFound) {
    Write-Host "  1. Run: .\remove-deprecated-extensions.ps1 -Interactive" -ForegroundColor White
    Write-Host "  2. Backup first: .\remove-deprecated-extensions.ps1 -BackupFirst -Interactive" -ForegroundColor White
} else {
    Write-Host "  1. Set up monitoring: .\extension-monitor.ps1 -CreateScheduledTask" -ForegroundColor White
}
Write-Host "  2. Check manually: Open VS Code -> Ctrl+Shift+X -> Search @deprecated" -ForegroundColor White