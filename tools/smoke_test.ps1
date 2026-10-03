# Smoke test: starts a dedicated server and two bot clients, all without windows.
# It passes when each bot has seen the other one move, and nobody logged an error
# or a warning.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools\smoke_test.ps1
# Uses the Godot executable in $env:GODOT, or `godot` from your PATH. On Windows,
# point GODOT at the console build (Godot_v4.7.2-stable_win64_console.exe) so the
# logs get written.

$ErrorActionPreference = 'Stop'
$godot = if ($env:GODOT) { $env:GODOT } else { 'godot' }
$game = (Resolve-Path (Join-Path (Join-Path $PSScriptRoot '..') 'game')).Path
$port = if ($env:SMOKE_TEST_PORT) { $env:SMOKE_TEST_PORT } else { '7787' }
$logs = Join-Path ([System.IO.Path]::GetTempPath()) ('bursa-smoke-' + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $logs | Out-Null

function Start-Godot([string]$name, [string[]]$arguments) {
    # Start-Process joins the arguments with spaces, so quote the path ourselves.
    $allArguments = @('--headless', '--path', "`"$game`"") + $arguments
    $process = Start-Process -FilePath $godot -ArgumentList $allArguments -NoNewWindow -PassThru `
        -RedirectStandardOutput (Join-Path $logs "$name.log") `
        -RedirectStandardError (Join-Path $logs "$name.err.log")
    # Reading the handle now keeps ExitCode available after the process ends.
    $null = $process.Handle
    return $process
}

function Show-Logs([string[]]$names = @('server', 'bot_a', 'bot_b')) {
    foreach ($name in $names) {
        foreach ($suffix in '.log', '.err.log') {
            $path = Join-Path $logs "$name$suffix"
            if (Test-Path $path) {
                Write-Host "--- $name$suffix"
                Get-Content $path
            }
        }
    }
}

# Without Git LFS, binary assets arrive as small text "pointer" files that
# Godot can't load, and the import then fails with errors that don't say why.
$pointers = @(Get-ChildItem -Path (Join-Path $game 'assets') -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -lt 1024 -and (Get-Content -Path $_.FullName -TotalCount 1) -eq 'version https://git-lfs.github.com/spec/v1' })
if ($pointers.Count -gt 0) {
    Write-Host 'These files are Git LFS pointers, not the real files:'
    $pointers | ForEach-Object { Write-Host "  $($_.FullName)" }
    Write-Host 'Run git lfs install and git lfs pull, then try again.'
    exit 1
}

Write-Host 'Importing the project...'
$import = Start-Godot 'import' @('--import')
$import.WaitForExit()
if ($import.ExitCode -ne 0) {
    Show-Logs @('import')
    Write-Host 'Import failed.'
    exit 1
}

Write-Host "Starting a dedicated server on UDP port $port..."
$server = Start-Godot 'server' @('--', '--server', '--port', $port)
$bots = @()
$passed = $false
try {
    $serverLog = Join-Path $logs 'server.log'
    $ready = $false
    for ($i = 0; $i -lt 50 -and -not $ready; $i++) {
        Start-Sleep -Milliseconds 200
        $ready = (Test-Path $serverLog) -and (Select-String -Path $serverLog -Pattern 'Server listening' -Quiet)
    }
    if (-not $ready) {
        Show-Logs
        Write-Host "The server didn't start."
        exit 1
    }

    Write-Host 'Starting two bot clients...'
    foreach ($bot in @(@('bot_a', 'BotA'), @('bot_b', 'BotB'))) {
        $bots += Start-Godot $bot[0] @('--', '--connect', '127.0.0.1', '--port', $port, '--name', $bot[1], '--bot')
    }
    $passed = $true
    foreach ($process in $bots) {
        if (-not $process.WaitForExit(60000) -or $process.ExitCode -ne 0) {
            $passed = $false
        }
    }

    $logFiles = Get-ChildItem -Path $logs -Filter '*.log'
    $errors = $logFiles | Select-String -CaseSensitive -Pattern 'SCRIPT ERROR', '^ERROR:', '^WARNING:'
    if ($errors) {
        $errors | ForEach-Object { Write-Host $_ }
        Write-Host 'Errors or warnings were logged (listed above).'
        $passed = $false
    }
}
finally {
    foreach ($process in @($server) + $bots) {
        if ($process -and -not $process.HasExited) {
            Stop-Process -Id $process.Id -Force
        }
    }
}

if ($passed) {
    Write-Host 'Smoke test passed: both bots saw each other move.'
    exit 0
}
Show-Logs
Write-Host "Smoke test FAILED. The logs are in $logs"
exit 1
