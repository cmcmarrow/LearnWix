# Set-ExecutionPolicy RemoteSigned
$msbuild = "C:\Program Files (x86)\MSBuild\14.0\"    # Build tools 2015
$wixpath = "$($ENV:WIX)bin"

Write-Host -ForegroundColor Yellow "Compiling cs into dll..."
# https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/filealign-compiler-option
Push-Location MinionConfigurationExtension
$releasedir = "obj\x86\Release"
cmd /r del /q $releasedir\*.dll
if (!(Test-Path -Path $releasedir)){New-Item -ItemType directory -Path $releasedir}
& "$($msbuild)bin\csc.exe" `
 /nologo /noconfig /nowarn:1701,1702 /nostdlib+ /errorreport:prompt /warn:4 /define:TRACE /highentropyva- `
 /reference:"$($ENV:WIX)SDK\Microsoft.Deployment.WindowsInstaller.dll" `
 /reference:"$($ENV:WIX)bin\wix.dll" `
 /reference:"C:\Windows\Microsoft.NET\Framework\v2.0.50727\mscorlib.dll" `
 /reference:"C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.dll" `
 /reference:"C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.Xml.dll" `
 /debug:pdbonly /filealign:512 /optimize+ `
 /out:$releasedir\MinionConfigurationExtension.dll `
 /target:library /utf8output `
 MinionConfiguration.cs `
  Properties\AssemblyInfo.cs 
if ($LastExitCode -eq 0) {
  Write-Host -ForegroundColor Yellow "Compiling cs... done"
} else {
  Write-Host -ForegroundColor Red "Compiling cs... failed $LastExitCode"
  exit(1)
}
Pop-Location


# Usage: MakeSfxCA <outputca.dll> SfxCA.dll <inputca.dll> [support files ...]
# Makes a self-extracting managed MSI CA or UI DLL package.

Write-Host -ForegroundColor Yellow "Packing dll's into CA.dll..."
& "$($ENV:WIX)sdk\MakeSfxCA.exe" `
 "c:\git\LearnWix\custom_actions_csharp\MinionConfigurationExtension\obj\x86\Release\MinionConfigurationExtension.CA.dll" `
 "$($ENV:WIX)sdk\x86\SfxCA.dll" `
 "c:\git\LearnWix\custom_actions_csharp\MinionConfigurationExtension\obj\x86\Release\MinionConfigurationExtension.dll" `
 "$($ENV:WIX)SDK\Microsoft.Deployment.WindowsInstaller.dll" `
 "$($ENV:WIX)bin\wix.dll" `
 "$($ENV:WIX)bin\Microsoft.Deployment.Resources.dll" `
 "c:\git\LearnWix\custom_actions_csharp\MinionConfigurationExtension\CustomAction.config"
Write-Host -ForegroundColor Yellow "Packing dll's into CA.dll...done"


Write-Host -ForegroundColor Yellow "Collecting files... TODO"



Write-Host -ForegroundColor Yellow "Compiling wxs... TODO"
