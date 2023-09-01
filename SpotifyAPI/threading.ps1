<#
.SYNOPSIS
   Threading Test File: Testing Invoking APIs using PowerShell's Threading.

.DESCRIPTION
   Uses Spotify API: To Be Determined

.NOTES
   Author: Michael Parent
#>

#region Import Secrets (API)
<#
.DESCRIPTION
    Imports a JSON formated file to import secrets.

.NOTES
    - Assumes JSON file is valid.
    - Path/Filename is hardcoded

#>
try {
    
    $spotifyAPI = $(Get-Content -Path ".\apikey.sconfig" | ConvertTo-JSON -Depth 100)

} catch {

    throw "Failed to extract details from 'apikey.sconfig'."
    return 1

}
#endregion



#region Request Bearer Token
<#
.DESCRIPTION

.NOTES

#>
$spotifyAuthorizationBody = @{
    "client_id"     = $spotifyAPI.client_id
    "client_secret" = $spotifyAPI.client_secret
    "grant_type"    = "client_credentials"
}

$spotifyAuthURI = "https://accounts.spotify.com/api/token"

try {
    
    Write-Host ("[STATUS] - Attempting to Authenticate to Spotify API.")
    $spotifyAuth = Invoke-RestMethod -Method "POST" -URI $spotifyAuthURI -Body $spotifyAuthorizationBody -ContentType "application/x-www-form-urlencoded"
    Write-Host ("[STATUS] - Success!")

} catch {

    Write-Host "[ ERROR] - Failed!"
    Write-Host ($_)
    throw "Failed to Authenticate to Spotify's API."
}
#endregion



#region Prompt For Track Name
<#
.DESCRIPTION
    Prompts the user for a track name to search.

.NOTES
    - Does not handle if no results are found
#>
Write-Host ("--------------------------------------------------")
$name = Read-Host -Prompt "Enter Track Name"
Write-Host ("--------------------------------------------------")
#endregion



#region Search For a Track
$spotifyAuthenticationHeader = @{
    "Authorization" = "Bearer $($spotifyAuth.access_token)"
}

$spotifyAPIendpoint = "https://api.spotify.com/v1/search?q=$name&type=track"

try {
    
    $spotifyResponse = $(Invoke-RestMethod -Method "GET" -Uri $spotifyAPIendpoint -Headers $spotifyAuthenticationHeader -ContentType "application/json").tracks

} catch {

    Write-Host "[ ERROR] - Failed!"
    Write-Host ($_)
    throw "Failed to Request from Spotify's API."

    return 1

}
#endregion



#region Process Results (Search Track)
<#
.DESCRIPTION
    Process and Display Returned Track Values from Search.

.NOTES
    n/a
#>
$counter = 0
Write-Host ("$($spotifyResponse.items.count) Track(s) Found!:")
foreach ($item in $spotifyResponse.items) {

    $counter++
    Write-Host ("[{0:D1}] - {1}" -F $counter, $item.name)

}
#endregion

# -- EOF --