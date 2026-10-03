# Starts a dedicated server without a window. Extra arguments go to the game, for example:
#   powershell -ExecutionPolicy Bypass -File tools\run_server.ps1 --port 7778
# Uses the Godot executable in $env:GODOT, or `godot` from your PATH.

$godot = if ($env:GODOT) { $env:GODOT } else { 'godot' }
$game = (Resolve-Path (Join-Path (Join-Path $PSScriptRoot '..') 'game')).Path

# Import every time, not only on a fresh clone. After a branch switch, the old
# import makes scripts that use new classes fail to load, and the game still
# starts. With nothing to update it takes a few seconds. Only errors and
# warnings from the import are shown.
$importLog = & $godot --headless --path $game --import 2>&1
$importLog | Select-String -CaseSensitive -Pattern 'SCRIPT ERROR', '^ERROR:', '^WARNING:' |
    ForEach-Object { Write-Host $_.Line }
# The quotes around -- keep Windows PowerShell from swallowing it.
& $godot --headless --path $game '--' --server @args
exit $LASTEXITCODE
