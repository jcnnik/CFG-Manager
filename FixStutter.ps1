<#
.SYNOPSIS
    CFG Manager - View and toggle Control Flow Guard settings for games.
.NOTES
    Must be run as Administrator.
#>

# Check for Administrator privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# --- GAME LIST LOADED FROM GameList.txt ---
$GameListPath = Join-Path $PSScriptRoot "GameList.txt"
$GameList = @()
if (Test-Path $GameListPath) {
    $GameList = @(Get-Content $GameListPath | Where-Object {$_.Trim() -ne ""} | ForEach-Object {($_.Trim().Trim('"').Trim(',') -split '#')[0].Trim()})
}
# ------------------------------------------

function Get-CFGStatus {
    param([string]$ProcessName)
    try {
        $mitigation = Get-ProcessMitigation -Name $ProcessName -ErrorAction Stop
        
        # When CFG is disabled, Enable property is "OFF"
        # When CFG is enabled (default), Enable property is "NOTSET" or "ON"
        return $mitigation.CFG.Enable -eq "OFF"
    }
    catch {
        return $false
    }
}

function Show-Manager {
    Clear-Host
    Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║         CFG MANAGER - Game Manager        ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    $programs = @()
    
    # Get all programs from GameList
    foreach ($game in $GameList) {
        $status = Get-CFGStatus -ProcessName $game
        $programs += @{
            Name = $game
            CFGDisabled = $status
            Index = $programs.Count + 1
        }
    }
    
    if ($programs.Count -eq 0) {
        Write-Host "No games found in GameList.txt" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Add game process names to GameList.txt (one per line)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Exit
    }
    
    Write-Host "Programs:" -ForegroundColor White
    Write-Host ""
    
    foreach ($prog in $programs) {
        $status = if ($prog.CFGDisabled) { "✓ DISABLED" } else { "✗ ENABLED" }
        $color = if ($prog.CFGDisabled) { "Green" } else { "Yellow" }
        $indexStr = "[$($prog.Index)]"
        Write-Host "  $($indexStr.PadRight(5)) $($prog.Name.PadRight(45)) $status" -ForegroundColor $color
    }
    
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  [1-$($programs.Count)] - Toggle CFG for program"
    Write-Host "  [A] - Enable CFG for All" -ForegroundColor Gray
    Write-Host "  [D] - Disable CFG for All" -ForegroundColor Gray
    Write-Host "  [R] - Refresh" -ForegroundColor Gray
    Write-Host "  [Q] - Exit" -ForegroundColor Gray
    Write-Host ""
    
    return $programs
}

# Main loop
while ($true) {
    $programs = Show-Manager
    
    Write-Host -NoNewline "Select option: "
    $choice = Read-Host
    
    switch ($choice.ToUpper()) {
        "Q" {
            Write-Host "Exiting..." -ForegroundColor Cyan
            Exit
        }
        "R" {
            continue
        }
        "A" {
            Write-Host "Enabling CFG for all programs..." -ForegroundColor Yellow
            foreach ($prog in $programs) {
                try {
                    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$($prog.Name)"
                    if (Test-Path $regPath) {
                        Remove-Item -Path $regPath -Recurse -ErrorAction Stop
                        Write-Host "✓ CFG Enabled for: $($prog.Name)" -ForegroundColor Green
                    }
                    else {
                        Write-Host "✓ CFG Enabled for: $($prog.Name) (already enabled)" -ForegroundColor Green
                    }
                }
                catch {
                    Write-Host "✗ Failed for $($prog.Name): $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            Write-Host ""
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "D" {
            Write-Host "Disabling CFG for all programs..." -ForegroundColor Yellow
            foreach ($prog in $programs) {
                try {
                    Set-ProcessMitigation -Name $prog.Name -Disable CFG -ErrorAction Stop
                    Write-Host "✓ CFG Disabled for: $($prog.Name)" -ForegroundColor Green
                }
                catch {
                    Write-Host "✗ Failed for $($prog.Name): $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            Write-Host ""
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        default {
            if ($choice -match '^\d+$') {
                $index = [int]$choice - 1
                if ($index -ge 0 -and $index -lt $programs.Count) {
                    $prog = $programs[$index]
                    $newStatus = -not $prog.CFGDisabled
                    $action = if ($newStatus) { "Disabling" } else { "Enabling" }
                    $actionColor = if ($newStatus) { "Green" } else { "Yellow" }
                    
                    Write-Host "$action CFG for $($prog.Name)..." -ForegroundColor $actionColor
                    try {
                        if ($newStatus) {
                            Set-ProcessMitigation -Name $prog.Name -Disable CFG -ErrorAction Stop
                            Write-Host "✓ CFG Disabled for: $($prog.Name)" -ForegroundColor Green
                        }
                        else {
                            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$($prog.Name)"
                            if (Test-Path $regPath) {
                                Remove-Item -Path $regPath -Recurse -ErrorAction Stop
                                Write-Host "✓ CFG Enabled for: $($prog.Name)" -ForegroundColor Green
                            }
                            else {
                                Write-Host "✓ CFG Enabled for: $($prog.Name) (already enabled)" -ForegroundColor Green
                            }
                        }
                    }
                    catch {
                        Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
                    }
                    Write-Host ""
                    Write-Host "Press any key to continue..."
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                }
                else {
                    Write-Host "Invalid selection!" -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            }
            else {
                Write-Host "Invalid option!" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}