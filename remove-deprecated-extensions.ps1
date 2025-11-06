# PowerShell script to help identify and remove deprecated VS Code extensions
param(
    [switch]$Interactive,
    [switch]$AutoRemove,
    [switch]$BackupFirst,
    [string]$ExtensionId
)

function Write-ColorText {
    param($Text, $Color = 'White')
    Write-Host $Text -ForegroundColor $Color
}

function Get-ExtensionInfo {
    param($ExtensionId)
    try {
        $info = code --show-extension $ExtensionId 2>$null
        return $info
    } catch {
        return $null
    }
}

function Backup-Extensions {
    $backupFile = "vscode-extensions-backup-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"
    $extensions = code --list-extensions
    $extensions | Out-File -FilePath $backupFile -Encoding UTF8
    Write-ColorText "✅ Extensions backed up to: $backupFile" 'Green'
    return $backupFile
}

function Remove-Extension {
    param($ExtensionId, [switch]$Confirm = $true)
    
    if ($Confirm) {
        $response = Read-Host "Remove extension '$ExtensionId'? (y/n)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-ColorText "❌ Skipped: $ExtensionId" 'Yellow'
            return
        }
    }
    
    try {
        code --uninstall-extension $ExtensionId
        Write-ColorText "✅ Removed: $ExtensionId" 'Green'
    } catch {
        Write-ColorText "❌ Failed to remove: $ExtensionId" 'Red'
    }
}

# Main execution
Write-ColorText "=== VS Code Extension Cleanup Tool ===" 'Green'
Write-ColorText "Date: $(Get-Date)" 'Gray'
Write-Host ""

# Handle specific extension removal
if ($ExtensionId) {
    if ($BackupFirst) { Backup-Extensions }
    Remove-Extension -ExtensionId $ExtensionId -Confirm (-not $AutoRemove)
    exit
}

# Get list of installed extensions
Write-ColorText "� Currently installed extensions:" 'Yellow'
$extensions = code --list-extensions --show-versions
$extensionIds = code --list-extensions

if ($extensions.Count -eq 0) {
    Write-ColorText "No extensions found." 'Gray'
    exit
}

$extensions | ForEach-Object { Write-ColorText "  - $_" 'Gray' }

Write-Host ""

# Check for potentially deprecated extensions
Write-ColorText "🔍 Scanning for potentially deprecated extensions..." 'Yellow'

$commonDeprecated = @(
    "ms-vscode.vscode-typescript-next",
    "formulahendry.auto-rename-tag", 
    "hookyqr.beautify",
    "ms-vscode.atom-keybindings",
    "ms-vscode.sublime-keybindings",
    "robertohuertasm.vscode-icons",
    "ms-vscode.brackets-pack",
    "ms-vscode.notepadplusplus-keybindings"
)

$duplicateExtensions = @{
    "docker.docker" = "ms-azuretools.vscode-docker"
    "ms-vscode.azure-account" = "ms-azuretools.vscode-azureresourcegroups"
}

$foundDeprecated = @()
$foundDuplicates = @()

# Check for known deprecated extensions
foreach ($deprecated in $commonDeprecated) {
    if ($extensionIds -contains $deprecated) {
        $foundDeprecated += $deprecated
        Write-ColorText "  ❌ DEPRECATED: $deprecated" 'Red'
    }
}

# Check for duplicate/superseded extensions
foreach ($old in $duplicateExtensions.Keys) {
    $new = $duplicateExtensions[$old]
    if (($extensionIds -contains $old) -and ($extensionIds -contains $new)) {
        $foundDuplicates += $old
        Write-ColorText "  ⚠️  DUPLICATE: $old (superseded by $new)" 'Yellow'
    }
}

if ($foundDeprecated.Count -eq 0 -and $foundDuplicates.Count -eq 0) {
    Write-ColorText "✅ No known deprecated or duplicate extensions found!" 'Green'
}

Write-Host ""

# Interactive mode
if ($Interactive -and ($foundDeprecated.Count -gt 0 -or $foundDuplicates.Count -gt 0)) {
    Write-ColorText "🛠️  Interactive cleanup mode" 'Cyan'
    
    if ($BackupFirst -or (Read-Host "Create backup first? (y/n)") -eq 'y') {
        Backup-Extensions
        Write-Host ""
    }
    
    foreach ($ext in $foundDeprecated) {
        Remove-Extension -ExtensionId $ext
    }
    
    foreach ($ext in $foundDuplicates) {
        $replacement = $duplicateExtensions[$ext]
        Write-ColorText "Extension '$ext' is superseded by '$replacement'" 'Yellow'
        Remove-Extension -ExtensionId $ext
    }
}

# Auto-remove mode
if ($AutoRemove -and ($foundDeprecated.Count -gt 0 -or $foundDuplicates.Count -gt 0)) {
    Write-ColorText "🤖 Auto-remove mode enabled" 'Cyan'
    
    if ($BackupFirst) { Backup-Extensions }
    
    foreach ($ext in ($foundDeprecated + $foundDuplicates)) {
        Remove-Extension -ExtensionId $ext -Confirm:$false
    }
}

Write-Host ""
Write-ColorText "� Usage examples:" 'Cyan'
Write-ColorText "  .\remove-deprecated-extensions.ps1 -Interactive" 'Gray'
Write-ColorText "  .\remove-deprecated-extensions.ps1 -AutoRemove -BackupFirst" 'Gray'
Write-ColorText "  .\remove-deprecated-extensions.ps1 -ExtensionId 'extension.name'" 'Gray'

Write-Host ""
Write-ColorText "💡 Manual check steps:" 'Yellow'
Write-ColorText "  1. Open VS Code (Ctrl+Shift+X)" 'Gray'
Write-ColorText "  2. Search: '@deprecated'" 'Gray'
Write-ColorText "  3. Check extension pages for migration guides" 'Gray'