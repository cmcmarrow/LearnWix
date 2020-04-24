###
###  Downloads software to setup_env_cache
###
Set-PSDebug -Strict
Set-strictmode -version latest

function Verify ($local_file, $SHA256) {
    if (-Not (Test-Path $local_file)) {
        Write-Host  -ForegroundColor Red "$local_file   MISSING"
        exit -2
    }
    if ((Get-FileHash $local_file).Hash -eq $SHA256) {
        Write-Host -ForegroundColor Green "Found $local_file"
        } else {
        Write-Host  -ForegroundColor Red "$local_file   UNEXPECTED HASH   $((Get-FileHash $local_file).Hash)"
        exit -2
    }
}


function OptionallyDownloadAndVerify ($local_file, $URL, $SHA256) {
    if (-Not (Test-Path $local_file)) {
        Write-Host -ForegroundColor Green "Downloading...  $URL"
        Write-Host -ForegroundColor Green "To...           $local_file"
        [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
        (New-Object System.Net.WebClient).DownloadFile($URL, $local_file)
    }
    Verify $local_file $SHA256
}


#### Ensure path exists
####
$setup_env_cache = "setup_env_cache"
# mkdir must be guarded, and I don't want to send the result of is-dir to console
if (-Not (Test-Path -Path $setup_env_cache -PathType Container)) {
    New-Item -ItemType directory -Path $setup_env_cache
}

#### Ensure resources are installed or get them
####


## You get WiX from https://wixtoolset.org/releases
##
## Wix 3.11.1  released Dec 31, 2017
## Wix 3.11.2  released Sep 19, 2019 (Unneeded protection against maliciously crafted cabinet or zip files) 

##
## You must edit the hard reference to the WiX version in file
##          wix.d/MinionConfigurationExtension/MinionConfigurationExtension.csproj
##    <Reference Include="wix">
##      <HintPath>c:\Program Files (x86)\WiX Toolset v3.11\bin\wix.dll</HintPath>
##    </Reference>
##
if (Test-Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"{AA06E868-267F-47FB-86BC-D3D62305D7F4}") {
    Write-Host -ForegroundColor Green "Wix 3.11.1 is installed"
} else {
    $dotnet3state = (Get-WindowsOptionalFeature -Online -FeatureName "NetFx3").State
    $dotnet3enabled = $dotnet3state -Eq "Enabled"
    if (-Not ($dotnet3enabled)) {
        Write-Host -ForegroundColor Red "To use WiX 3.11 on Windows 10, you need to enable .Net Framework 3.5"
        Start-Process optionalfeatures -Wait -NoNewWindow
    }
    
    $wixInstaller = "./setup_env_cache/wix311.exe"
    $u = "https://github.com/wixtoolset/wix3/releases/download/wix3111rtm/wix311.exe"
    $h = "7CAECC9FFDCDECA09E211AA20C8DD2153DA12A1647F8B077836B858C7B4CA265"
    OptionallyDownloadAndVerify $WixInstaller $u $h
    
    Start-Process $wixInstaller -Wait -NoNewWindow
}


## Build tools 2015  
#  Account for Build tools 2015 bugfix upgrade 
#  14.0.23107    from link     {8C918E5B-E238-401F-9F6E-4FB84B024CA2}   Appears in appwiz.cpl
#  14.0.25420    from where?   {79750C81-714E-45F2-B5DE-42DEF00687B8}   Doesn't appear in appwiz.cpl
if ((Test-Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"{8C918E5B-E238-401F-9F6E-4FB84B024CA2}") -or  
    (Test-Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"{79750C81-714E-45F2-B5DE-42DEF00687B8}")) {
    Write-Host -ForegroundColor Green "Build Tools are installed"
} else {
    $BuildToolsInstaller = "./setup_env_cache/BuildTools_Full.exe"
    $u = "https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe"
    $h = "92CFB3DE1721066FF5A93F14A224CC26F839969706248B8B52371A8C40A9445B"
    OptionallyDownloadAndVerify $BuildToolsInstaller $u $h
    Write-Host -ForegroundColor Yellow "------------------------------------"
    Write-Host -ForegroundColor Yellow "-- Please install the Build Tools --"
    Write-Host -ForegroundColor Yellow "------------------------------------"
    Start-Process $BuildToolsInstaller -Wait -NoNewWindow
}
