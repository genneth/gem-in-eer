# setup-audio.ps1
# This script downloads RA2 sound assets from the OpenPeon registry.
# Reuses the curated packs from the PeonPing project.

$ExtensionPath = $PSScriptRoot | Split-Path -Parent
$AudioRootDir = Join-Path $ExtensionPath "audio"

$Packs = @{
    "kirov"    = "https://raw.githubusercontent.com/PeonPing/og-packs/v1.0.0/ra2_kirov/sounds/"
    "engineer" = "https://raw.githubusercontent.com/PeonPing/og-packs/v1.0.0/ra2_soviet_engineer/sounds/"
}

$Files = @{
    "kirov" = @(
        "Acknowledged.mp3", "AirshipReady.mp3", "BearingSet.mp3", 
        "BombardiersToYourStations.mp3", "BombingBaysReady.mp3", 
        "ClosingOnTarget.mp3", "HeliumMixOptimal.mp3", "KirovReporting.mp3", 
        "ManeuverPropsEngaged.mp3", "MaydayMayday.mp3", "SettingNewCourse.mp3", 
        "ShesGoingToBlow.mp3", "TargetAcquired.mp3", "WereLosingAltitude.mp3"
    )
    "engineer" = @(
        "CheckingDesigns.mp3", "Engineering.mp3", "ExaminingDiagrams.mp3", 
        "GetMeOuttaHere.mp3", "Information.mp3", "PowerUp.mp3", 
        "ToolsReady.mp3", "YesCommander.mp3"
    )
}

if (-not (Test-Path $AudioRootDir)) { New-Item -ItemType Directory -Path $AudioRootDir | Out-Null }

foreach ($PackName in $Packs.Keys) {
    $PackDir = Join-Path $AudioRootDir $PackName
    if (-not (Test-Path $PackDir)) { New-Item -ItemType Directory -Path $PackDir | Out-Null }
    
    $BaseUrl = $Packs[$PackName]
    $FileList = $Files[$PackName]
    
    Write-Host "Downloading $PackName pack..." -ForegroundColor Cyan
    foreach ($FileName in $FileList) {
        $DestPath = Join-Path $PackDir $FileName
        if (-not (Test-Path $DestPath)) {
            Write-Host "  -> $FileName"
            curl.exe -fsSL "$BaseUrl$FileName" -o $DestPath
        }
    }
}

# Create Mashup
Write-Host "Creating mashup pack..." -ForegroundColor Cyan
$MashupDir = Join-Path $AudioRootDir "mashup"
if (-not (Test-Path $MashupDir)) { New-Item -ItemType Directory -Path $MashupDir | Out-Null }
Copy-Item (Join-Path $AudioRootDir "kirov\*") $MashupDir -Force
Copy-Item (Join-Path $AudioRootDir "engineer\*") $MashupDir -Force

Write-Host "Deployment Complete! Battlefield control established." -ForegroundColor Green
