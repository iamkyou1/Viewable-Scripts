#!ps 
#timeout=1800000
#maxlength=500000

$Path = "HKLM:\SOFTWARE\Policies\SafeSend\"
 
$Key = "SS_LicenseKey"
 
$KeyFormat = "String"
 
$Value=':2025-02-14:Full:guidepoint.com:guidepointglobal.com:0MF6LaX2SyTm4fVh2oYNfvqXTiGwj56dLjQ0JIiaeIVPsJtM58LccXF3B8vArJg0H0CF1evFAdruUgfgnpjpA4wpDrTsTdMRac/nkLE3pCIpd9KJCFQrd+LHtJkgEI86An39VNZ+lgwPoraS2u4LN1GnITiwRk4e5YT22tugcHc='

try{
 
    if(!(Test-Path $Path)){New-Item -Path $Path -Force}
 
    if(!$Key){Set-Item -Path $Path -Value $Value}
 
    else{Set-ItemProperty -Path $Path -Name $Key -Value $Value -Type $KeyFormat}
 
    Write-Output "Key set: $Key = $Value"
 
}catch{
 
    Write-Error $_
 
}