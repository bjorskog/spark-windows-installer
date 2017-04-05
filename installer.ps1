#Requires -RunAsAdministrator

param(
    [string]$Where = "C:\"
)

$WhatToInstall = @()
$ErrorActionPreference = "Stop"

if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
	Write-Host "Installing chocolatey package manager" -ForegroundColor Green
	Write-Host "Don't worry, we will remove it afterwards"
	Start-Sleep 2
	Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
} else {
	Write-Host "Chocolatey already installed" -ForegroundColor Green
}

if (-Not (Get-Command python -ErrorAction SilentlyContinue)) {
	Write-Host "Python 2 not detected in PATH" -ForegroundColor Yellow
	$answer = $null;

	while(@('y', 'n') -notcontains $answer) {
		$answer = (Read-Host "Do you want [us] to automatically install python 2?").ToLower();
	}

	$WhatToInstall += 'python2'
} else {
	Write-Host "Python 2 already installed" -ForegroundColor Green
}

if (-Not (Get-Command java -ErrorAction SilentlyContinue)) {
	Write-Host "Java not detected in PATH" -ForegroundColor Yellow
	$answer = $null;

	while(@('y', 'n') -notcontains $answer) {
		$answer = (Read-Host "Do you want [us] to automatically install Java 1.8.0?").ToLower();
	}

	$WhatToInstall += @('jdk8', 'jre8')
} else {
	Write-Host "Java already installed" -ForegroundColor Green
}

if (-not ([bool]($(choco search GnuWin --local-only -r)))) {
	Write-Host "GNU coreutils for windows not detected" -ForegroundColor Yellow
	Write-Host "This will take some time to install. Please be patient" -ForegroundColor Yellow

	$WhatToInstall += 'GnuWin'
} else {
	Write-Host "GNU coreutils on windows already installed" -ForegroundColor Green
}

if ($WhatToInstall.Length -ne 0) {
	choco install ($WhatToInstall -join ' ')

	refreshenv
}

$tempArchive = "C:\Windows\Temp\spark-2.1.0-bin-hadoop2.7"

Write-Host "Downloading Spark 2.1.0..."
Invoke-WebRequest -Uri http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz -OutFile "$($tempArchive).tgz"

Write-Host "Decompressing archive..."
gzip -d "$($tempArchive).tgz"
Write-Host "Extracting archive to $($Where)"
bsdtar xvf "$($tempArchive).tar" -C $Where
Write-Host "Removing temp archive file"
Remove-Item "$($tempArchive).tar"
Move-Item "$($where)spark-2.1.0-bin-hadoop2.7" "$($where)spark"

Write-Host "Downloading winutils required for spark on windows..."
Invoke-WebRequest http://public-repo-1.hortonworks.com/hdp-win-alpha/winutils.exe -OutFile "$($Where)\spark\bin\winutils.exe"

Write-Host "Setting environment variables..."
[System.Environment]::SetEnvironmentVariable('HADOOP_HOME', "$($Where)spark", 'User')
[System.Environment]::SetEnvironmentVariable('SPARK_HOME', "$($Where)spark", 'User')

$hasEnvPath = ([System.Environment]::GetEnvironmentVariable('PATH') -split ';') -contains "$($Where)spark\bin"

if (-not $hasEnvPath) {
	[System.Environment]::SetEnvironmentVariable('PATH', "$([System.Environment]::GetEnvironmentVariable('PATH'));$($Where)spark\bin")	
}

Write-Host "Done."