# Extension Monitor - Automated checker for deprecated VS Code extensions
# Run this script weekly to monitor your extensions

param(
    [switch]$CreateScheduledTask,
    [switch]$RemoveScheduledTask
)

$TaskName = "VSCode-ExtensionMonitor"
$ScriptPath = $PSScriptRoot + "\remove-deprecated-extensions.ps1"

function Create-ScheduledTask {
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`""
    $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At "09:00AM"
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    $Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
    
    try {
        Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Description "Weekly VS Code extension deprecation check"
        Write-Host "✅ Scheduled task created: $TaskName" -ForegroundColor Green
        Write-Host "   Runs every Monday at 9:00 AM" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Failed to create scheduled task: $_" -ForegroundColor Red
    }
}

function Remove-ScheduledTask {
    try {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "✅ Scheduled task removed: $TaskName" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to remove scheduled task: $_" -ForegroundColor Red
    }
}

# Main execution
Write-Host "=== VS Code Extension Monitor Setup ===" -ForegroundColor Green
Write-Host ""

if ($CreateScheduledTask) {
    Create-ScheduledTask
    exit
}

if ($RemoveScheduledTask) {
    Remove-ScheduledTask
    exit
}

# Default: Run the check and show setup options
Write-Host "🔍 Running extension check..." -ForegroundColor Yellow
& $ScriptPath

Write-Host ""
Write-Host "🛠️  Setup Options:" -ForegroundColor Cyan
Write-Host "  Create weekly monitor: .\extension-monitor.ps1 -CreateScheduledTask" -ForegroundColor Gray
Write-Host "  Remove monitor:       .\extension-monitor.ps1 -RemoveScheduledTask" -ForegroundColor Gray
Write-Host ""
Write-Host "📅 The monitor will check extensions every Monday at 9:00 AM" -ForegroundColor Yellow