# get-registry.ps1
# Fetches the PeonPing registry and returns a list of pack names and descriptions.

$RegistryUrl = "https://peonping.github.io/registry/index.json"
try {
    $Registry = Invoke-RestMethod -Uri $RegistryUrl
    foreach ($Pack in $Registry.packs) {
        Write-Host "$($Pack.name): $($Pack.display_name) ($($Pack.language))"
    }
} catch {
    Write-Host "Error: Could not fetch pack registry."
}
