param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("list", "download")]
    [string]$Action,
    
    [string]$PackName
)

$ExtensionPath = $PSScriptRoot | Split-Path -Parent
$AudioRootDir = Join-Path $ExtensionPath "audio"
$RegistryUrl = "https://peonping.github.io/registry/index.json"

function Get-Registry {
    try {
        return Invoke-RestMethod -Uri $RegistryUrl
    } catch {
        Write-Host "Error: Could not reach PeonPing registry."
        return $null
    }
}

function Download-Pack($Name) {
    if (-not $Name) { Write-Host "Error: No pack name provided."; return }
    
    $Registry = Get-Registry
    if (-not $Registry) { return }
    
    $PackInfo = $Registry.packs | Where-Object { $_.name -eq $Name }
    if (-not $PackInfo) { Write-Host "Error: Pack '$Name' not found."; return }

    $Repo = if ($PackInfo.source_repo) { $PackInfo.source_repo } else { "PeonPing/og-packs" }
    $Ref = if ($PackInfo.source_ref) { $PackInfo.source_ref } else { "v1.0.0" }
    $Path = if ($PackInfo.source_path -ne $null) { $PackInfo.source_path } else { $Name }

    $BaseUrl = "https://raw.githubusercontent.com/$Repo/$Ref/$Path"
    if ($Path -eq "") { $BaseUrl = "https://raw.githubusercontent.com/$Repo/$Ref" }

    $PackDir = Join-Path $AudioRootDir $Name
    if (-not (Test-Path $PackDir)) { New-Item -ItemType Directory -Path $PackDir | Out-Null }
    $SoundsDir = Join-Path $PackDir "sounds"
    if (-not (Test-Path $SoundsDir)) { New-Item -ItemType Directory -Path $SoundsDir | Out-Null }

    Write-Host "Downloading $Name manifest..."
    try {
        $Manifest = Invoke-RestMethod -Uri "$BaseUrl/openpeon.json"
        $Manifest | ConvertTo-Json | Out-File (Join-Path $PackDir "openpeon.json")
        
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
        Write-Host "Pack '$Name' ready."
    } catch {
        Write-Host "Error: Failed to download pack $Name."
    }
}

switch ($Action) {
    "list" {
        $Registry = Get-Registry
        if ($Registry) {
            foreach ($P in $Registry.packs) {
                Write-Host "$($P.name): $($P.display_name) ($($P.language))"
            }
        }
    }
    
    "download" {
        Download-Pack $PackName
    }
}
