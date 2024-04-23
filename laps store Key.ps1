[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$localAdmin = "gpadmin"
$logdir = 'C:\temp\gp-laps-logs'
$dinoDom = 'www.dinopass.com'
$kvDom = 'prod-gplaps-use-vault.vault.azure.net'

$tenantId = "MQAxAGUANQA1ADAANwA5AC0AMQA1AGUAZgAtADQAYwBkADQALQBiADgAMgBjAC0AZQA4ADcAMwA5AGQAZgA1ADMANgAxADYA"
$client_id = "MQBiADYANgA2ADUAZAAyAC0AOQAyAGEANQAtADQAMQA5AGYALQBhADMAYwBmAC0AZgA3AGQAZQA1ADgANAA4ADMAZQBmADkA"
$client_secret = "VQBIAHIAOABRAH4AdgBmAG4ANgA2AGgAWgBNADAAZABwAFUAdABjADkAcgBFAG8AWQBPAFUALQBSAHUAWQBVAGYAbwBoAFgAeABiAG4ATwA="
$IntModules = 'aAB0AHQAcABzADoALwAvAHAAcgBvAGQAZwBwAGwAYQBwAHMAdQBzAGUAcwB0AC4AYgBsAG8AYgAuAGMAbwByAGUALgB3AGkAbgBkAG8AdwBzAC4AbgBlAHQALwBnAHAAbABhAHAAcwAvAGwAYQBwAHMALQBtAG8AZAB1AGwAZQBzAC4AcABzADEAPwBzAHAAPQByACYAcwB0AD0AMgAwADIAMgAtADAANgAtADIAMABUADEANQA6ADIAMwA6ADUAOQBaACYAcwBlAD0AMgAwADIANAAtADAANgAtADIAMABUADIAMwA6ADIAMwA6ADUAOQBaACYAcwBwAHIAPQBoAHQAdABwAHMAJgBzAHYAPQAyADAAMgAxAC0AMAA2AC0AMAA4ACYAcwByAD0AYgAmAHMAaQBnAD0AeAAzAFEARwBiADgAegBNAEIAYwBpAEkAawBCAE4AYgBiAFIAdABuAE0AYQBNAEIAWABmAFoAMAAyAEwASABlAEIAMgBTAEsASAA3AHIAVgBOAEYAOAAlADMARAA='

$ErrorActionPreference = "Stop"

Invoke-Expression ([System.Net.WebClient]::new().DownloadString([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($IntModules))))

try {
    New-Item -Path $logdir -ItemType Directory -Force
} catch {
    Write-Host $_.Exception
    Write-Host "Unable to log results... Terminating"
    exit 1
}

Start-Transcript -Path "${logdir}\$(Get-Date -Format 'yyyymmddhhmmss').log" -Force

Write-Host "Testing connection to ${dinoDom}" -ForegroundColor Yellow
$dinoTest = Test-NetConnection -ComputerName $dinoDom -Port 443 
Write-Host "Testing connection to ${kvDom}" -ForegroundColor Yellow
$kvTest = Test-NetConnection -ComputerName $kvDom -Port 443 

If (-not ($dinoTest.TcpTestSucceeded) -and ($kvTest.TcpTestSucceeded)) {
    Write-Host "Connection unavailable... Exiting after failure" -ForegroundColor Red
    Stop-Transcript
    exit 1
}


Function Get-BitLockerRecoveryPassword() {
    $recovery_key = (Get-BitLockerVolume -MountPoint "C").KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" }
    $recovery_password = $recovery_key.RecoveryPassword
    if ($recovery_password.Length -gt 5) {
        return [string]$recovery_password
    } else {
        $recovery_password = "null"
        return [string]$recovery_password
    }
}


Function GetPass() {
    Do {
        [string]$dinoPass = Invoke-WebRequest -Uri "https://${dinoDom}/password/strong" -Method GET -UseBasicParsing
        Start-Sleep 1 #throttle so we don't get banned 
    } Until ($dinoPass.Contains('!'))
    Return $dinoPass
}

Function SetLocalAdmin([string]$accName, [string]$accPass) {
    $newSecure = ConvertTo-SecureString -String $accPass -AsPlainText -Force
    $get = (Get-LocalUser -Name $accName -ErrorAction SilentlyContinue)
    If (-not $get) {
        New-LocalUser $accName -Password $newSecure -AccountNeverExpires -PasswordNeverExpires:$true -Description "GP Local Admin" -Verbose
    } else {
        Set-LocalUser $accName -Password $newSecure -AccountNeverExpires -PasswordNeverExpires:$true -Description "GP Local Admin" -Verbose
    }
    Add-LocalGroupMember -Group "Administrators" -Member $accName -Verbose -ErrorAction SilentlyContinue
}

try {

    $newGpadminPass = GetPass
    Write-Host "Obtained new password from ${dinoDom}" -ForegroundColor Green

    SetLocalAdmin -accName $localAdmin -accPass $newGpadminPass
    Write-Host "Updated local admin '${localAdmin}' password with new value" -ForegroundColor Green

    $serNo = (Get-CimInstance -ClassName "win32_BIOS").SerialNumber
    Write-Host "Retrieved serial number for host: ${serNo}" -ForegroundColor Green

    $scope = "https://vault.azure.net/.default"
    $grant_type = "client_credentials"

    $bearer = Invoke-RestMethod `
        -Uri "https://login.microsoftonline.com/$([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($tenantId)))/oauth2/v2.0/token" `
        -ContentType "application/x-www-form-urlencoded" `
        -Method Post `
        -Body "client_id=$([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($client_id)))&scope=${scope}&client_secret=$([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($client_secret)))&grant_type=${grant_type}"
    Write-Host "Obtained authorization and access_token" -ForegroundColor Green

    $body = @{
        value       = $newGpadminPass
        attributes  = @{
            enabled = $true
        }
        contentType = "password"
        tags        = @{
            SerialNumber = $serNo
            BitlockerRecoveryKey = (Get-BitLockerRecoveryPassword)
        }
    } | ConvertTo-Json 

    $headers = @{
        Authorization  = "Bearer " + $bearer.access_token
        "Content-Type" = "application/json"
        Host           = "${kvDom}"
    }

    Write-Host "Invoking PUT request against ${kvDom}" -ForegroundColor Yellow
    $response = Invoke-RestMethod `
        -Uri "https://${kvDom}/secrets/$($env:COMPUTERNAME)?api-version=7.2" `
        -Method PUT `
        -Body $body `
        -Headers $headers
    Write-Host $response.contentType -ForegroundColor Green
    Write-Host $response.id -ForegroundColor Green
    Write-Host $response.attributes -ForegroundColor Green

} catch {
    Write-Host "Unable to update ${localadmin} password!" -ForegroundColor Red
    Write-Host "Exception:`t`t$($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Line:`t`t`t$($_.Exception.Line)" -ForegroundColor Red
}

Stop-Transcript