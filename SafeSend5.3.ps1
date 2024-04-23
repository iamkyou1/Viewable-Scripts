#!ps 
#timeout=1800000
#maxlength=500000
 
##################################
# Define Variables
##################################
#$SafeSendLicenceKey = ':2024-02-14:Full:guidepoint.com:guidepointglobal.com:BpPBEWr7Vkoy/xYS9N4yirq1FI4EetNN98wMTbKRnpmpoYdKBYER8bXGOw7xkTsH/9rKq3LY3g34dWNqi9z6WhjjWhx+nEReYvW+3eZVQ8Yg+gSkQeToMbdKUjV6ziNQwbQw8wchiesXUJusWxKK/DGfAIbp6uCuMXEKTJiZ7Mk='
$SafeSendLicenceKey = ':2025-02-14:Full:guidepoint.com:guidepointglobal.com:0MF6LaX2SyTm4fVh2oYNfvqXTiGwj56dLjQ0JIiaeIVPsJtM58LccXF3B8vArJg0H0CF1evFAdruUgfgnpjpA4wpDrTsTdMRac/nkLE3pCIpd9KJCFQrd+LHtJkgEI86An39VNZ+lgwPoraS2u4LN1GnITiwRk4e5YT22tugcHc='
$SafeSendLogo       = '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'
$SafeSendFooterText = ''
$URL = 'https://go.vipre.com/?linkid=1873'
$SafeSendZIPFilename = "SafeSendArchive.zip"

##################################
# Function to Check for SafeSend Installation and Version
##################################
Function Check-ForSafeSendUpdate {
    $installedVersion = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SafeSend' -Name 'DisplayVersion' -ErrorAction SilentlyContinue
    if ($installedVersion -ne $null -and [version]$installedVersion -ge [version]"5.3") {
        Write-Output "SafeSend version 5.3 or newer is already installed."
        return $false
    } else {
        Write-Output "Updating to SafeSend version 5.3..."
        return $true
    }
}

##################################
# Download and Install Latest SafeSend if Required
##################################
If (Check-ForSafeSendUpdate) {
$null = New-Item -Path c:\temp -ItemType Directory -ErrorAction SilentlyContinue
Invoke-WebRequest -Uri $URL -OutFile "C:\temp\$SafeSendZIPFilename"
Expand-Archive -Path "C:\temp\$SafeSendZIPFilename" -DestinationPath "C:\temp\SafeSend\" -Force
Expand-Archive -Path "C:\temp\SafeSend\SafeSendPC_5.3.2.33.zip" -DestinationPath "C:\temp\SafeSend" -Force
$Parameters= " /qn /norestart /l*v C:\temp\$SafeSendZIPFilename.log" 
Start-Process msiexec.exe -Wait -ArgumentList '/i ',"C:\temp\SafeSend\SafeSendSetup.msi",$Parameters
}

##################################
# Add SafeSend Licence Key + Logo
##################################
$SafeSendRegLocation1 = 'HKLM:\SOFTWARE\Policies'
If(Test-Path "$SafeSendRegLocation1\SafeSend"){
  Write-Verbose 'Key already exists' -Verbose
}else{
  New-Item -Path $SafeSendRegLocation1 -Name 'SafeSend' -Verbose
}
New-ItemProperty -Path "$SafeSendRegLocation1\SafeSend" -Name "SS_LicenseKey" -PropertyType "String" -Value $SafeSendLicenceKey -Force
New-ItemProperty -Path "$SafeSendRegLocation1\SafeSend" -Name "SS_Logo"       -PropertyType "String" -Value $SafeSendLogo -Force
New-ItemProperty -Path "$SafeSendRegLocation1\SafeSend" -Name "SS_FooterText" -PropertyType "String" -Value $SafeSendFooterText -Force


##################################
# Delete Temp install Files
##################################
Start-Sleep 5
Remove-Item "C:\temp\SafeSend\" -Force -Recurse -Verbose
Remove-Item "C:\temp\SafeSendArchive.zip" -Force -Verbose

