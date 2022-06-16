﻿#######################################################
## GPN - 4.6.22
#######################################################

#Pre-reqs = Install-Module MSGraph, IntuneWin32App, AzureAD, and PSIntuneAuth


#Connect to Graph API - Commented out if running from master file. if running individually, uncomment below line.
$TenantID = Read-Host "Enter your TenantID (i.e. - domain.com or domain.onmicrosoft.com)"
Connect-MSIntuneGraph -TenantID $TenantID


#Create working direcotry for the Application, set download location, and download installer
$appfolder = new-item -Path ".\" -Name "Teams" -ItemType Directory -Force
$downloadsource = 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true'
$filename = "teams.msi"
$downloaddestination = $appfolder
Start-BitsTransfer -Source $downloadsource -Destination $appfolder\$filename | Out-Null


#logo download - image file must be PNG or JPG
$logoURL = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Microsoft_Office_Teams_%282018%E2%80%93present%29.svg/1024px-Microsoft_Office_Teams_%282018%E2%80%93present%29.svg.png"
$LogoFileName = "teams.png"
Invoke-WebRequest -Uri $logoURL -D -OutFile $downloaddestination\$LogoFileName


#Create the intunewin file from source and destination variables and assign IntuneWin file location variable
$Source = $appfolder
$SetupFile = $filename
$Destination = $appfolder
$CreateAppPackage = New-IntuneWin32AppPackage -SourceFolder $Source -SetupFile $SetupFile -OutputFolder $Destination -Verbose
$IntuneWinFile = $CreateAppPackage.Path

#Get intunewin file MSI MetaData <- Did not work for Chrome. May need to retrieve Product Code manually 
$IntuneWinMetaData = Get-IntuneWin32AppMetaData -FilePath $IntuneWinFile


#Names Application, description and publisher info as it appears in MEM - Examples below
$Displayname = "Microsoft Teams Machine-Wide installer x64"
$Description = "Teams Machine Wide Installer x64"
$Publisher = $IntuneWinMetaData.ApplicationInfo.MsiInfo.MsiPublisher


##Create MSI product code detection rule - Retrieve MSI code if you don't have it. Alternate method commented below to use File existence. MSIs are recommended to use Product Code. 
#DetectionRule = New-IntuneWin32AppDetectionRuleMSI -ProductCode "{C0A46265-716E-345D-BB59-72B42D15135B}"
#$DetectionRule = New-IntuneWin32AppDetectionRuleFile -Existence -FileOrFolder Firefox.exe -Path "C:\Program Files\Mozilla Firefox\" -Check32BitOn64System $false -DetectionType "exists"
$DetectionRule = New-IntuneWin32AppDetectionRuleMSI -ProductCode $IntuneWinMetaData.ApplicationInfo.MsiInfo.MsiProductCode

#Create Requirement Rule (32/64 bit and minimum Windows Version)
$ArchitectureRequired = "x64"
$MinimumOSBuild = "1909"
$RequirementRule = New-IntuneWin32AppRequirementRule -Architecture $ArchitectureRequired -MinimumSupportedOperatingSystem $MinimumOSBuild
 

#Create a cool Icon from the downloaded image file (if you want) - comment out lines if you don't want or can't find an image file
$ImageFile = "$appfolder\$LogoFileName"
$Icon = New-IntuneWin32AppIcon -FilePath $ImageFile
 

#****Install and Uninstall Commands - not needed for MSI installs****
#$InstallCommandLine = "7zipX64.exe /S"
#$UninstallCommandLine = "%systemdrive%\Program Files\7-Zip\Uninstall.exe"


#Builds the App and Uploads to Intune
Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $DisplayName -Description $Description -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -Icon $Icon -Verbose