### Set-ExecutionPolicy RemoteSigned
###
###  Downloads software to setup_env_cache
###
Set-PSDebug -Strict
Set-strictmode -version latest

Import-Module $PSScriptRoot\setupUtil.psm1

#### cache dir
####
$CACHEDIR = "_cache.dir"
if (-Not (Test-Path -Path $CACHEDIR -PathType Container)) {
    New-Item -ItemType directory -Path $CACHEDIR | Out-null
}


## WiX toolset 
##
## From https://wixtoolset.org/releases
##   Wix 3.11.1  released Dec 31, 2017
##   Wix 3.11.2  released Sep 19, 2019 (Unneeded protection against maliciously crafted cabinet or zip files) 

##
## If you have a csproj you must edit the hard reference to the WiX version in file
##          wix.d/MinionConfigurationExtension/MinionConfigurationExtension.csproj
##    <Reference Include="wix">
##      <HintPath>c:\Program Files (x86)\WiX Toolset v3.11\bin\wix.dll</HintPath>
##    </Reference>
##
##
if (ProductcodeExists "{AA06E868-267F-47FB-86BC-D3D62305D7F4}") {
    Write-Host -ForegroundColor Green "Wix 3.11.1 is installed"
} else {
    $dotnet3state = (Get-WindowsOptionalFeature -Online -FeatureName "NetFx3").State
    $dotnet3enabled = $dotnet3state -Eq "Enabled"
    if (-Not ($dotnet3enabled)) {
        Write-Host -ForegroundColor Yellow "    ***  Please enable .Net Framework 3.5 (For WiX 3.11)***"
        Start-Process optionalfeatures -Wait -NoNewWindow
    }
    
    $wixInstaller = "$CACHEDIR/wix311.exe"
    VerifyOrDownload $wixInstaller `
        "https://github.com/wixtoolset/wix3/releases/download/wix3111rtm/wix311.exe" `
        "7CAECC9FFDCDECA09E211AA20C8DD2153DA12A1647F8B077836B858C7B4CA265"
    Write-Host -ForegroundColor Yellow "    *** Please install the Wix toolset ***"
    Start-Process $wixInstaller -Wait -NoNewWindow
}
if ($ENV:WIX -eq $null) {
    Write-Host -ForegroundColor Yellow "    *** Please open a new Shell for the Wix enviornment variable ***"
}



## Build tools 2015  
#  There is a bugfix upgrade 
#  14.0.23107    from link     {8C918E5B-E238-401F-9F6E-4FB84B024CA2}   Appears in appwiz.cpl
#  14.0.25420    from where?   {79750C81-714E-45F2-B5DE-42DEF00687B8}   Doesn't appear in appwiz.cpl
#
if ((ProductcodeExists "{8C918E5B-E238-401F-9F6E-4FB84B024CA2}") -or  
    (ProductcodeExists "{79750C81-714E-45F2-B5DE-42DEF00687B8}")) {
    Write-Host -ForegroundColor Green "Build Tools 2015 are installed"
} else {
    $BuildToolsInstaller = "$CACHEDIR/BuildTools_Full.exe"
    VerifyOrDownload $BuildToolsInstaller `
        "https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe" `
        "92CFB3DE1721066FF5A93F14A224CC26F839969706248B8B52371A8C40A9445B"

    Write-Host -ForegroundColor Yellow "    *** Please install Microsoft Build Tools 2015 (and wait 40 seconds) ***"
    #Start-Process $BuildToolsInstaller -Wait -NoNewWindow   // waits forever (for the "process group"?)
    $p = start-process -passthru $BuildToolsInstaller
    $p.WaitForExit()
}
$msbuild = "C:\Program Files (x86)\MSBuild\14.0\"    # Build tools 2015
