# This script will detect if Zoom version 5.13 is present on the device

# Get the list of installed applications
$installedApps = Get-AppXPackage

# Loop through the installed applications
foreach ($app in $installedApps) {

    # Get the name of the application
    $appName = $app.DisplayName

    # Get the version of the application
    $appVersion = $app.Version

    # If the application name is Zoom and the version is 5.13, then the script will output "Zoom version 5.13 is present on the device"
    if ($appName -eq "Zoom" -and $appVersion -ge "5.13") {
        echo "Zoom version 5.13 is present on the device"
    }
}