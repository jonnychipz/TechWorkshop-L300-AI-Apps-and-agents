# PowerShell script to help identify and remove deprecated VS Code extensions

Write-Host "=== VS Code Extension Cleanup Tool ===" -ForegroundColor Green
Write-Host ""

# Get list of installed extensions
Write-Host "📋 Currently installed extensions:" -ForegroundColor Yellow
$extensions = code --list-extensions
$extensions | ForEach-Object { Write-Host "  - $_" }

Write-Host ""
Write-Host "🔍 To check for deprecated extensions:" -ForegroundColor Yellow
Write-Host "  1. Open VS Code"
Write-Host "  2. Press Ctrl+Shift+X (Extensions view)"
Write-Host "  3. Type '@deprecated' in the search box"
Write-Host "  4. Look for any extensions marked as deprecated"

Write-Host ""
Write-Host "🗑️  To uninstall an extension:" -ForegroundColor Yellow
Write-Host "  Method 1 (UI): Click gear icon → Uninstall"
Write-Host "  Method 2 (CLI): code --uninstall-extension EXTENSION_ID"

Write-Host ""
Write-Host "⚠️  Common deprecated extensions to look out for:" -ForegroundColor Red
$commonDeprecated = @(
    "ms-vscode.vscode-typescript-next",
    "formulahendry.auto-rename-tag", 
    "hookyqr.beautify",
    "ms-vscode.atom-keybindings",
    "ms-vscode.sublime-keybindings"
)

$commonDeprecated | ForEach-Object { 
    if ($extensions -contains $_) {
        Write-Host "  ❌ FOUND: $_ (consider removing)" -ForegroundColor Red
    } else {
        Write-Host "  ✅ Not installed: $_" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "💡 Tip: Always check the extension's marketplace page for migration guidance!" -ForegroundColor Cyan