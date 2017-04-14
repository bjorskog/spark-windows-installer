#Requires -RunAsAdministrator

param(
    [string]$Where = "C:\"
)

$WhatToInstall = @()
$TemptFiles = @()
$InstallScala = $false
$ErrorActionPreference = "Stop"

function InstallScala() {
	Write-Host 'Downloading Scala 2.12.1...'
	Invoke-WebRequest https://downloads.lightbend.com/scala/2.12.1/scala-2.12.1.msi -OutFile "$env:TEMP/scala-2.12.1.msi"
	$TemptFiles += "$env:TEMP/scala-2.12.1.msi"
	Write-Host 'Installing Scala 2.12.1...'
	Start-Process msiexec.exe -Wait -ArgumentList "/I `"$env:TEMP\scala-2.12.1.msi`" /quiet"

	refreshenv

	if (-Not (Get-Command scala -ErrorAction SilentlyContinue)) {
		throw [System.ApplicationException] 'We were unable to install Scala :('
	}

	Write-Host 'Successfully installed Scala 2.12.1.'
}

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
		$answer = (Read-Host "Do you want [us] to automatically install python 2.7.13?").ToLower();
	}

	if ($answer -eq 'y') {
		$WhatToInstall += 'python2'
	}
} else {
	Write-Host "Python 2 already installed" -ForegroundColor Green
}

if (-Not (Get-Command java -ErrorAction SilentlyContinue)) {
	Write-Host "Java not detected in PATH" -ForegroundColor Yellow
	$answer = $null;

	while(@('y', 'n') -notcontains $answer) {
		$answer = (Read-Host "Do you want [us] to automatically install JRE/JDK 1.8.0?").ToLower();
	}

	if ($answer -eq 'y') {
		$WhatToInstall += @('jdk8', 'jre8')
	}
} else {
	Write-Host "Java already installed" -ForegroundColor Green
}

if (-Not (Get-Command scala -ErrorAction SilentlyContinue)) {
	Write-Host "Scala not detected in PATH" -ForegroundColor Yellow
	$answer = $null;

	while(@('y', 'n') -notcontains $answer) {
		$answer = (Read-Host "Do you want [us] to automatically install Scala 2.12.1?").ToLower();
	}

	if ($answer -eq 'y') {
		$InstallScala = $true
	}	
} elseif ([bool]((scala -version) -notmatch '2.12')) {
	Write-Host "We want to install Scala version 2.12.1 but you seem to have another version" -ForegroundColor Yellow
	$answer = $null;

	while(@('y', 'n') -notcontains $answer) {
		$answer = (Read-Host "Do you want [us] to automatically install Scala 2.12.1?").ToLower();
	}

	if ($answer -eq 'y') {
		$InstallScala = $true
	}
}

if (-not ([bool]($(choco search GnuWin --local-only -r)))) {
	Write-Host "GNU coreutils for windows not detected" -ForegroundColor Yellow
	Write-Host "This will take some time to install. Please be patient" -ForegroundColor Yellow

	$WhatToInstall += 'GnuWin'
} else {
	Write-Host "GNU coreutils on windows already installed" -ForegroundColor Green
}

if ($WhatToInstall.Length -ne 0) {
	choco install @WhatToInstall

	refreshenv
}

if ($InstallScala) {
	InstallScala
}

$tempArchive = "$env:TEMP\spark-2.1.0-bin-hadoop2.7"

Write-Host "Downloading Spark 2.1.0..."
Invoke-WebRequest -Uri http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz -OutFile "$($tempArchive).tgz"
$TemptFiles += "$($tempArchive).tar"

Write-Host "Decompressing archive..."
gzip -d "$($tempArchive).tgz"
Write-Host "Extracting archive to $($Where)"
bsdtar xvf "$($tempArchive).tar" -C $Where
Move-Item "$($where)spark-2.1.0-bin-hadoop2.7" "$($where)spark"

Write-Host "Downloading winutils required for spark on windows..."
Invoke-WebRequest https://github.com/steveloughran/winutils/raw/master/hadoop-2.7.1/bin/winutils.exe -OutFile "$($Where)\spark\bin\winutils.exe"

Write-Host "Setting environment variables..."
[System.Environment]::SetEnvironmentVariable('HADOOP_HOME', "$($Where)spark", 'User')
[System.Environment]::SetEnvironmentVariable('SPARK_HOME', "$($Where)spark", 'User')
[System.Environment]::SetEnvironmentVariable('SPARK_JARS', "$($Where)spark\jars", 'User')

if (-Not [bool]$env:SCALA_HOME) {
	[System.Environment]::SetEnvironmentVariable('SCALA_HOME', "C:\Program Files (x86)\scala\bin", 'User')
}

$hasEnvPath = ([System.Environment]::GetEnvironmentVariable('PATH', 'User') -split ';') -contains "$($Where)spark\bin"

if (-not $hasEnvPath) {
	[System.Environment]::SetEnvironmentVariable('PATH', "$([System.Environment]::GetEnvironmentVariable('PATH', 'User'))$($Where)spark\bin", 'User')	
}

Write-Host "Creating hive scratch dirs and setting permissions..."
mkdir.exe -p /tmp/hive
winutils chmod 777 /tmp/hive
winutils chmod 777 $env:TEMP
Remove-Item @TemptFiles

Write-Host "Done."