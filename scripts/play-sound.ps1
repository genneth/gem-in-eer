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
    $Pack = "mashup"
}

# Auto-setup on first run
if ($Event -eq "SessionStart" -and -not (Test-Path (Join-Path $AudioRootDir "mashup"))) {
    Start-Process powershell.exe -ArgumentList "-NoProfile", "-NonInteractive", "-File", (Join-Path $ExtensionPath "scripts/setup-audio.ps1") -WindowStyle Hidden
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
            # Handle both "file.mp3" and "sounds/file.mp3"
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

# Fallback to mashup if sound not found in active pack
if (-not $SoundPath -and $Pack -ne "mashup") {
    $MashupPath = Join-Path $AudioRootDir "mashup"
    $SoundPath = Get-SoundFromPack $MashupPath $CespCategory
}

# Final fallback: Hardcoded RA2 names (backwards compatibility for manual installs)
if (-not $SoundPath) {
    $HardMap = @{
        "session.start"    = @("KirovReporting.mp3", "ToolsReady.mp3", "AirshipReady.mp3")
        "task.complete"    = @("TargetAcquired.mp3", "PowerUp.mp3", "Engineering.mp3")
        "task.acknowledge" = @("Acknowledged.mp3", "SettingNewCourse.mp3", "YesCommander.mp3")
        "task.error"       = @("MaydayMayday.mp3", "ShesGoingToBlow.mp3")
        "input.required"   = @("Information.mp3")
    }
    $PossibleFiles = $HardMap[$CespCategory]
    foreach ($f in ($PossibleFiles | Get-Random -Count $PossibleFiles.Count)) {
        $P1 = Join-Path $AudioRootDir "mashup/$f"
        if (Test-Path $P1) { $SoundPath = $P1; break }
    }
}

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
