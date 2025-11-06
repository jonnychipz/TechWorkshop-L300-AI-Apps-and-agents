# Simple Extension Checker - Quick analysis of VS Code extensions

Write-Host "=== VS Code Extension Analysis ===" -ForegroundColor Green
Write-Host ""

# Get extensions
$extensions = code --list-extensions --show-versions
Write-Host "Found $($extensions.Count) extensions installed" -ForegroundColor Yellow
Write-Host ""

# Check your specific extensions for potential issues
$potentialIssues = @()

foreach ($ext in $extensions) {
    $id = ($ext -split '@')[0]
    
    # Check against known deprecated/superseded extensions
    switch ($id) {
        "docker.docker" { 
            $potentialIssues += "DUPLICATE: $id (consider ms-azuretools.vscode-docker instead)"
        }
        "ms-vscode.vscode-typescript-next" {
            $potentialIssues += "DEPRECATED: $id (use built-in TypeScript support)"
        }
        "hookyqr.beautify" {
            $potentialIssues += "DEPRECATED: $id (use Prettier extension)"
        }
        "formulahendry.auto-rename-tag" {
            $potentialIssues += "DEPRECATED: $id (built into VS Code now)"
        }
        "ms-vscode.atom-keybindings" {
            $potentialIssues += "DEPRECATED: $id (Atom discontinued)"
        }
        "ms-vscode.sublime-keybindings" {
            $potentialIssues += "OLD: $id (consider if still needed)"
        }
    }
}

# Display results
if ($potentialIssues.Count -gt 0) {
    Write-Host "Issues Found:" -ForegroundColor Red
    foreach ($issue in $potentialIssues) {
        Write-Host "  $issue" -ForegroundColor Yellow
    }
} else {
    Write-Host "No known issues found with your extensions!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Your installed extensions:" -ForegroundColor Cyan
$extensions | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Open VS Code Extensions (Ctrl+Shift+X)" -ForegroundColor White
Write-Host "2. Search for: @deprecated" -ForegroundColor White  
Write-Host "3. Look for yellow warning badges on extensions" -ForegroundColor White
Write-Host "4. To remove: .\remove-deprecated-extensions.ps1 -Interactive" -ForegroundColor White