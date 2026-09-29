# Starts a dedicated server without a window. Extra arguments go to the game, for example:
#   powershell -ExecutionPolicy Bypass -File tools\run_server.ps1 --port 7778
# Uses the Godot executable in $env:GODOT, or `godot` from your PATH.

$godot = if ($env:GODOT) { $env:GODOT } else { 'godot' }
$game = (Resolve-Path (Join-Path (Join-Path $PSScriptRoot '..') 'game')).Path

# A fresh clone has no import cache yet, and the game can't start without it.
if (-not (Test-Path (Join-Path $game '.godot'))) {
    & $godot --headless --path $game --import
}
# The quotes around -- keep Windows PowerShell from swallowing it.
& $godot --headless --path $game '--' --server @args
exit $LASTEXITCODE
