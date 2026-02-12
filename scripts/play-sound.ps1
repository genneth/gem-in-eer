param(
    [string]$Event
)

$ExtensionPath = $PSScriptRoot | Split-Path -Parent
$AudioRootDir = Join-Path $ExtensionPath "audio"

# Read JSON from stdin
$JsonInput = $Input | Out-String
if ($JsonInput) {
    try {
        $HookData = $JsonInput | ConvertFrom-Json
    } catch {
        $HookData = $null
    }
}

# Determine the active pack
$Pack = $env:GEMINEER_PACK
if (-not $Pack -or -not (Test-Path (Join-Path $AudioRootDir $Pack))) {
    exit 0
}

# Map Gemini CLI events to CESP (Coding Event Sound Pack) categories
$CategoryMap = @{
    "SessionStart"    = "session.start"
    "SessionEnd"      = "session.end"
    "AfterAgent"      = "task.complete"
    "BeforeTool"      = "task.acknowledge"
    "AfterTool"       = "task.acknowledge"
    "InputRequired"   = "input.required"
    "BeforeAgent"     = "task.acknowledge"
}

$CespCategory = $CategoryMap[$Event]
if ($HookData -and $HookData.error) {
    $CespCategory = "task.error"
}

if (-not $CespCategory) { exit 0 }

# Function to pick a sound from a pack's manifest
function Get-SoundFromPack($PackPath, $Category) {
    $ManifestPath = Join-Path $PackPath "openpeon.json"
    if (-not (Test-Path $ManifestPath)) { return $null }
    
    try {
        $Manifest = Get-Content $ManifestPath | ConvertFrom-Json
        $Sounds = $Manifest.categories.$Category.sounds
        if ($Sounds) {
            $Sound = $Sounds | Get-Random
            $File = $Sound.file
            # Try root, sounds/ subfolder, etc.
            $PathsToTry = @(
                (Join-Path $PackPath $File),
                (Join-Path $PackPath ([System.IO.Path]::GetFileName($File))),
                (Join-Path $PackPath (Join-Path "sounds" ([System.IO.Path]::GetFileName($File))))
            )
            foreach ($P in $PathsToTry) {
                if (Test-Path $P) { return $P }
            }
        }
    } catch {}
    return $null
}

$PackPath = Join-Path $AudioRootDir $Pack
$SoundPath = Get-SoundFromPack $PackPath $CespCategory

if (-not $SoundPath) { exit 0 }

# Determine Volume
$Volume = $env:GEMINEER_VOLUME
if (-not $Volume) { $Volume = 0.5 }

# Play sound in background
$PlayCommand = @"
Add-Type -AssemblyName PresentationCore
`$player = New-Object System.Windows.Media.MediaPlayer
`$player.Open([Uri]::new('$($SoundPath.Replace([char]92, '/'))'))
`$player.Volume = $Volume
`$player.Play()
Start-Sleep -Seconds 5
`$player.Close()
"@

Start-Process powershell.exe -ArgumentList "-NoProfile", "-NonInteractive", "-Command", $PlayCommand -WindowStyle Hidden
