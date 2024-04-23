#!ps 
#timeout=1800000
#maxlength=500000

$clientID = "6b22f9e3-41f7-4ca3-8242-2080e3d8671b"
$tenantName = "guidepointglobal.onmicrosoft.com"  
$ClientSecret64 = 'Vm5COFF+WVYyTVR1Unp1RHVRNmM4UkNJMUc2VmxINkpJWHd0TmNnNg=='
$resource = "https://graph.microsoft.com/"

Function RequestToken{
    $ReqTokenBody = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        client_Id     = $clientID
        Client_Secret = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($ClientSecret64))
    }
    $TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
    Return $TokenResponse
}

Function GetUserLocation {
    Param([String]$UserPrincipalName)

    $Tokenresponse = RequestToken
    $apiUrl = "https://graph.microsoft.com/v1.0/users/$UserPrincipalName"
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get

    Return $Data.officeLocation
}


Function GrapAPI_sendMail {
    Param(
        [String]$Subject,
        [ValidateSet("Low", "Normal", "High")] [String]$Importance,
        [String]$HTMLBody,
        [String]$ToRecipients,
        [String]$FromMail
    )

    $body = @"
    {
      "Message": {
        "Subject": "$Subject",
        "importance":"$Importance",
        "Body": {
          "ContentType": "HTML",
          "Content": "$HTMLBody"
        },
        "ToRecipients": [
          {
            "EmailAddress": {
              "Address": "$ToRecipients"
            }
          }
        ]
      },
      "SaveToSentItems": "false",
      "isDraft": "false"
    }
"@

  
    $Tokenresponse = RequestToken
    $apiUrl = "https://graph.microsoft.com/v1.0/users/$FromMail/sendMail"
    $ResponseData = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Body $Body -Method POST -ContentType 'application/json'
    Return $ResponseData
}

## Ensure that Powershell is using TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

## Get the old / currnet name of the machine
$OldName=(Get-WmiObject Win32_COMPUTERSYSTEM).name

## Get the Dell ServiceTag of the machine and save it as a variable.
$ServiceTag=((Get-WmiObject Win32_BIOS).serialnumber)

##Get user's office location
$userName = ( Get-WmiObject -class Win32_ComputerSystem ).username -replace '^.*\\'
$domain = "@guidepoint.com"
$email = "$username$Domain"
Write-Output $email 

## Get Office Location
$OfficeLocation = GetUserLocation -UserPrincipalName $email

#Define city code
$Cities =
@(
[pscustomobject]@{City="New York";Code="NY"},
[pscustomobject]@{City="Sydney";Code="SY"},
[pscustomobject]@{City="Mumbai";Code="MU"},
[pscustomobject]@{City="Phoenix";Code="PH"},
[pscustomobject]@{City="San Francisco";Code="SF"},
[pscustomobject]@{City="Boston";Code="BO"},
[pscustomobject]@{City="London";Code="LO"},
[pscustomobject]@{City="Dusseldorf";Code="DU"},
[pscustomobject]@{City="Athens";Code="AT"},
[pscustomobject]@{City="Dubai";Code="DB"},
[pscustomobject]@{City="Singapore";Code="SG"},
[pscustomobject]@{City="Shanghai";Code="SH"},
[pscustomobject]@{City="Hong Kong";Code="HK"},
[pscustomobject]@{City="Seoul";Code="SE"},
[pscustomobject]@{City="Tokyo";Code="TK"})
$CurrentCity = $Cities | Where-Object { $_.City -eq $OfficeLocation}
$CityCode = $CurrentCity.Code


## Set New Computer Name
$ComputerName = "$CityCode-$ServiceTag"

## Rename Workgroup
$CurrentWorkgroup = (Get-WmiObject -Class Win32_ComputerSystem).Workgroup
$StandardWorkgroup = "AZ-GUIDEPOINT"
    If ($CurrentWorkgroup -notmatch "$StandardWorkgroup|MARWAN-TEST")
        {
        Add-Computer -WorkgroupName $StandardWorkgroup
        }
    Else
        {
        Write-Host "Computer workgroup is already set to $StandardWorkgroup ..."
        }

## Rename PC and send E-mail
If($OldName -ne $ComputerName)
{
    Write-Host "Renaming computer from $OldName to $ComputerName ..."
    Rename-Computer -NewName "$ComputerName"
    Write-Host "Computer Renamed ."
    shutdown -r -f -t 300 -c "Your computer will reboot in 5 minutes"
    exit $LASTEXITCODE
}
else 
{
    Write-Host "Computer name is already set to $ComputerName ..."
    exit $LASTEXITCODE
}