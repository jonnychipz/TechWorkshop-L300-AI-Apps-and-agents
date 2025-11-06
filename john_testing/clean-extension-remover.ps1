# Clean Extension Remover - Simple tool to remove deprecated VS Code extensions

param(
    [switch]$Interactive,
    [string]$ExtensionId
)

Write-Host "=== VS Code Extension Remover ===" -ForegroundColor Green
Write-Host ""

# Function to remove an extension
function Remove-Extension {
    param($Id, [switch]$Confirm = $true)
    
    if ($Confirm) {
        $response = Read-Host "Remove extension '$Id'? (y/n)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "Skipped: $Id" -ForegroundColor Yellow
            return $false
        }
    }
    
    try {
        code --uninstall-extension $Id
        Write-Host "Successfully removed: $Id" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Failed to remove: $Id" -ForegroundColor Red
        return $false
    }
}

# Function to backup extensions
function Backup-Extensions {
    $backupFile = "vscode-extensions-backup-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"
    $extensions = code --list-extensions
    $extensions | Out-File -FilePath $backupFile -Encoding UTF8
    Write-Host "Extensions backed up to: $backupFile" -ForegroundColor Green
    return $backupFile
}

# Handle specific extension removal
if ($ExtensionId) {
    Write-Host "Removing specific extension: $ExtensionId"
    Remove-Extension -Id $ExtensionId -Confirm:$false
    exit
}

# Get current extensions
$extensions = code --list-extensions
Write-Host "Found $($extensions.Count) installed extensions" -ForegroundColor Yellow

# Check for issues
$issuesFound = @()

# Check for duplicate Docker extensions
if (($extensions -contains "docker.docker") -and ($extensions -contains "ms-azuretools.vscode-docker")) {
    $issuesFound += @{
        Extension = "docker.docker"
        Issue = "Duplicate/Superseded"
        Recommendation = "Use ms-azuretools.vscode-docker instead"
    }
}

# Check for other common deprecated extensions
$deprecated = @(
    "ms-vscode.vscode-typescript-next",
    "formulahendry.auto-rename-tag", 
    "hookyqr.beautify",
    "ms-vscode.atom-keybindings",
    "ms-vscode.sublime-keybindings"
)

foreach ($dep in $deprecated) {
    if ($extensions -contains $dep) {
        $issuesFound += @{
            Extension = $dep
            Issue = "Deprecated" 
            Recommendation = "Should be removed"
        }
    }
}

# Display findings
if ($issuesFound.Count -gt 0) {
    Write-Host ""
    Write-Host "Issues found:" -ForegroundColor Red
    foreach ($issue in $issuesFound) {
        Write-Host "  Extension: $($issue.Extension)" -ForegroundColor White
        Write-Host "  Issue: $($issue.Issue)" -ForegroundColor Yellow
        Write-Host "  Action: $($issue.Recommendation)" -ForegroundColor Cyan
        Write-Host ""
    }
    
    if ($Interactive) {
        Write-Host "Interactive cleanup mode" -ForegroundColor Cyan
        
        # Ask about backup
        $backup = Read-Host "Create backup first? (y/n)"
        if ($backup -eq 'y' -or $backup -eq 'Y') {
            Backup-Extensions
        }
        
        # Remove each problematic extension
        foreach ($issue in $issuesFound) {
            Write-Host "Processing: $($issue.Extension)"
            Write-Host "Issue: $($issue.Issue)"
            Write-Host "Recommendation: $($issue.Recommendation)"
            Remove-Extension -Id $issue.Extension
        }
    } else {
        Write-Host "To remove these extensions interactively, run:"
        Write-Host "  .\clean-extension-remover.ps1 -Interactive" -ForegroundColor Yellow
    }
} else {
    Write-Host "No deprecated or duplicate extensions found!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Manual check: Open VS Code -> Extensions -> Search @deprecated" -ForegroundColor Cyan