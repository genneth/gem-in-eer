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

# Determine the active pack (kirov, engineer, or mashup)
$Pack = $env:RA2_PACK
if (-not $Pack -or -not (Test-Path (Join-Path $AudioRootDir $Pack))) {
    $Pack = "mashup"
}

$AudioDir = Join-Path $AudioRootDir $Pack

$SoundMap = @{
    "SessionStart" = @("KirovReporting.mp3", "ToolsReady.mp3", "AirshipReady.mp3")
    "SessionEnd"   = @("ShesGoingToBlow.mp3", "WereLosingAltitude.mp3")
    "AfterAgent"   = @("TargetAcquired.mp3", "PowerUp.mp3", "Engineering.mp3")
    "BeforeTool"   = @("Acknowledged.mp3", "SettingNewCourse.mp3", "BearingSet.mp3", "YesCommander.mp3")
    "AfterTool"    = @("Engineering.mp3", "Acknowledged.mp3")
    "Error"        = @("MaydayMayday.mp3", "ShesGoingToBlow.mp3", "GetMeOuttaHere.mp3")
    "InputRequired" = @("Information.mp3", "ExaminingDiagrams.mp3", "CheckingDesigns.mp3")
}

$Category = $Event

# Check for errors in AfterTool or other events
if ($HookData -and $HookData.error) {
    $Category = "Error"
}

$Sounds = $SoundMap[$Category]
if (-not $Sounds) {
    exit 0
}

# Find a sound that exists in the current pack
$PossibleSounds = $Sounds | Get-Random -Count $Sounds.Count
$SoundFile = $null

foreach ($s in $PossibleSounds) {
    $Path1 = Join-Path $AudioDir $s
    $Path2 = Join-Path $AudioDir "sounds/$s"
    if (Test-Path $Path1) {
        $SoundFile = $s
        $FinalPath = $Path1
        break
    } elseif (Test-Path $Path2) {
        $SoundFile = $s
        $FinalPath = $Path2
        break
    }
}

# If no sound found in specific pack, try mashup
if (-not $SoundFile) {
    $AudioDir = Join-Path $AudioRootDir "mashup"
    foreach ($s in $PossibleSounds) {
        $Path1 = Join-Path $AudioDir $s
        if (Test-Path $Path1) {
            $SoundFile = $s
            $FinalPath = $Path1
            break
        }
    }
}

if (-not $SoundFile) {
    exit 0
}

$SoundPath = $FinalPath

# Play sound in background so we don't block the CLI
$PlayCommand = @"
Add-Type -AssemblyName PresentationCore
`$player = New-Object System.Windows.Media.MediaPlayer
`$player.Open([Uri]::new('$($SoundPath.Replace([char]92, '/'))'))
`$player.Volume = 0.5
`$player.Play()
Start-Sleep -Seconds 5
`$player.Close()
"@

Start-Process powershell.exe -ArgumentList "-NoProfile", "-NonInteractive", "-Command", $PlayCommand -WindowStyle Hidden
