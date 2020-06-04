## Adobe Reader DC version check and Slack Notification ##
## Usage of this script requires that you have an active Slack App for the channel you want notifications for ##
## For information on configuring this, visit: https://api.slack.com/messaging/webhooks ##


## Variables - Set before Run ##

## Path to collect previous version, or create new file to hold data for comparison, end with trailing slash
$filePath = 
## File Name for Version holding
$fileName = 
## URL to icon to include with Slack Block Message
$icon = 
## URL to Webhook configured for Slack App
$uri = 

## Running code - Editing will affect performance

$fullFile = $filepath + $fileName
if (!(Test-Path -Path $fullFile))
{
    New-Item -Path $filePath -Type File -Name $fileName
}

$adobe = Invoke-WebRequest "https://helpx.adobe.com/acrobat/release-note/release-notes-acrobat-reader.html#AcrobatDCandAcrobatReaderDCContinuousTrackreleasenotes"
$adobeVer =  $adobe.Links | select-object innerText | select-string -Pattern '(DC\s)(.*?)(\d\d\d\d\s\W)' | ForEach-Object {$_ -replace "@{innerText=","" -replace "\s\W",";" -replace "\W}",""}
$adobeSplt = $adobeVer[0] | ForEach-Object {$_ -split ";"} 
$newDate = $adobeSplt[0]
$newVer = $adobeSplt[1]
$current = Get-Content -Path $versionFile | ForEach-Object {$_ -split ";"}
If($null -ne $current)
{
    $curVer = $current[1]
}

$block = @("[
    {
        `"type`": `"section`",
        `"text`": {
            `"type`": `"mrkdwn`",
            `"text`": `"Adobe Reader DC for Windows has updated on *$newDate* to version *$newVer*.\n\n`"
        },
        `"accessory`": {
            `"type`": `"image`",
            `"image_url`": `"$icon`",
            `"alt_text`": `"Update`"
        }
    },
    {
        `"type`": `"divider`"
    }
]")




If ([version]$newVer -gt [version]$curVer -or $null -eq $current)
{
    Invoke-WebRequest -Method POST -Uri  $uri -Body "{`"blocks`":$block}" -ContentType 'application/json'
    $adobeVer[0] | Out-File $fullFile -Force
}
