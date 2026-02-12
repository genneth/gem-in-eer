param(
    [string]$PackName
)

if (-not $PackName) {
    Write-Host "Error: No pack name provided."
    exit 1
}

$ExtensionPath = $PSScriptRoot | Split-Path -Parent
$AudioRootDir = Join-Path $ExtensionPath "audio"
$RegistryUrl = "https://peonping.github.io/registry/index.json"

Write-Host "Fetching registry for pack info..."
try {
    $Registry = Invoke-RestMethod -Uri $RegistryUrl
    $PackInfo = $Registry.packs | Where-Object { $_.name -eq $PackName }
} catch {
    Write-Host "Error: Could not reach registry."
    exit 1
}

if (-not $PackInfo) {
    Write-Host "Error: Pack '$PackName' not found in registry."
    exit 1
}

$Repo = $PackInfo.source_repo -ifnot $PackInfo.source_repo -then "PeonPing/og-packs"
$Ref = $PackInfo.source_ref -ifnot $PackInfo.source_ref -then "v1.0.0"
$Path = $PackInfo.source_path -ifnot $PackInfo.source_path -then $PackName

$BaseUrl = "https://raw.githubusercontent.com/$Repo/$Ref/$Path"
if ($Path -eq "") { $BaseUrl = "https://raw.githubusercontent.com/$Repo/$Ref" }

$PackDir = Join-Path $AudioRootDir $PackName
if (-not (Test-Path $PackDir)) { New-Item -ItemType Directory -Path $PackDir | Out-Null }
$SoundsDir = Join-Path $PackDir "sounds"
if (-not (Test-Path $SoundsDir)) { New-Item -ItemType Directory -Path $SoundsDir | Out-Null }

Write-Host "Downloading manifest for $PackName..."
$ManifestUrl = "$BaseUrl/openpeon.json"
try {
    $Manifest = Invoke-RestMethod -Uri $ManifestUrl
    $Manifest | ConvertTo-Json | Out-File (Join-Path $PackDir "openpeon.json")
} catch {
    Write-Host "Error: Could not download manifest from $ManifestUrl"
    exit 1
}

Write-Host "Downloading sounds..."
foreach ($Cat in $Manifest.categories.PSObject.Properties) {
    foreach ($Sound in $Cat.Value.sounds) {
        $FileName = [System.IO.Path]::GetFileName($Sound.file)
        $DestPath = Join-Path $SoundsDir $FileName
        if (-not (Test-Path $DestPath)) {
            Write-Host "  -> $FileName"
            curl.exe -fsSL "$BaseUrl/sounds/$FileName" -o $DestPath
        }
    }
}

Write-Host "Pack '$PackName' downloaded successfully!"
