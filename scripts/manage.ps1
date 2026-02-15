param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("list", "download", "configure-hooks")]
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
    if ($Path -eq "" -or $Path -eq ".") { $BaseUrl = "https://raw.githubusercontent.com/$Repo/$Ref" }
    $BaseUrl = $BaseUrl.TrimEnd("/")

    $PackDir = Join-Path $AudioRootDir $Name
    if (-not (Test-Path $PackDir)) { New-Item -ItemType Directory -Path $PackDir | Out-Null }
    $SoundsDir = Join-Path $PackDir "sounds"
    if (-not (Test-Path $SoundsDir)) { New-Item -ItemType Directory -Path $SoundsDir | Out-Null }

    Write-Host "Downloading $Name manifest..."
    try {
        $Manifest = Invoke-RestMethod -Uri "$BaseUrl/openpeon.json"
        $Manifest | ConvertTo-Json -Depth 10 | Out-File (Join-Path $PackDir "openpeon.json") -Encoding UTF8
        
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

    "configure-hooks" {
        $AllHooks = @("SessionStart", "SessionEnd", "BeforeAgent", "AfterAgent", "BeforeTool", "AfterTool", "Notification")
        
        # Load current hooks
        $HooksFile = Join-Path $ExtensionPath "hooks" "hooks.json"
        $CurrentHooksObj = if (Test-Path $HooksFile) { Get-Content $HooksFile | ConvertFrom-Json } else { @{ hooks = @{} } }
        
        $ActiveHooks = New-Object System.Collections.Generic.List[string]
        if ($CurrentHooksObj.hooks) {
            foreach ($prop in $CurrentHooksObj.hooks.PSObject.Properties) {
                $ActiveHooks.Add($prop.Name) | Out-Null
            }
        }
        
        $Modified = $false
        
        while ($true) {
            Clear-Host
            Write-Host "--- Gem-in-eer Hook Configuration ---"
            Write-Host "Select hooks to toggle. Press 'S' to save, 'Q' to quit."
            Write-Host "NOTE: You may need to press Ctrl+F to focus this shell."
            Write-Host ""
            
            for ($i = 0; $i -lt $AllHooks.Count; $i++) {
                $H = $AllHooks[$i]
                $Status = if ($ActiveHooks.Contains($H)) { "[ON] " } else { "[OFF]" }
                Write-Host "$($i + 1). $Status $H"
            }
            Write-Host ""
            Write-Host "S. [Save and Exit]"
            Write-Host "Q. [Quit without saving]"
            Write-Host ""
            
            $Selection = Read-Host "Toggle (1-$($AllHooks.Count)) or S/Q"
            $Selection = $Selection.ToUpper()

            if ($Selection -eq "S") {
                if ($Modified) {
                    $NewHooks = @{}
                    foreach ($H in $AllHooks) {
                        if ($ActiveHooks.Contains($H)) {
                            $NewHooks[$H] = @(
                                @{
                                    "hooks" = @(
                                        @{
                                            "type" = "command"
                                            "command" = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `${extensionPath}/scripts/play-sound.ps1 -Event $H"
                                        }
                                    )
                                }
                            )
                        }
                    }
                    $FinalObj = @{ "hooks" = $NewHooks }
                    $FinalObj | ConvertTo-Json -Depth 10 | Out-File $HooksFile -Encoding UTF8
                    Write-Host "`nSettings saved! Please restart the Gemini CLI for changes to take effect."
                    Start-Sleep -Seconds 2
                }
                break
            }
            elseif ($Selection -eq "Q") {
                break
            }
            elseif ($Selection -match "^\d+$") {
                $Idx = [int]$Selection - 1
                if ($Idx -ge 0 -and $Idx -lt $AllHooks.Count) {
                    $SelectedHook = $AllHooks[$Idx]
                    if ($ActiveHooks.Contains($SelectedHook)) {
                        $ActiveHooks.Remove($SelectedHook) | Out-Null
                    } else {
                        $ActiveHooks.Add($SelectedHook) | Out-Null
                    }
                    $Modified = $true
                }
            }
        }
    }
}
