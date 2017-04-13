# Installer Script for Spark on Windows

## Introduction
First time I wanted to install and learn spark I just said to myself I'll use windows locally, and skip using an Ubuntu VM for this. Turns out installing Spark on windows ain't that easy, hence why I made this script.

This is a powershell script used to install Spark and everything else (so it will actually work). This script also sets the necessary environment variables on the User-level.

This was made for development purposes, so I don't recommend using it for production

## What does it do ?

It will install the following (if the command has not been found, don't worry, it will ask before continueing): 
* **chocolatey**: A package manager for windows, used to install dependencies
* **python2**: Installed through chocolatey
* **Java 1.8.0 (jdk8, jre8)**: Installed through chocolatey
* **Scala 2.12.1**: Installed through chocolatey
* **GnuWin**: GNU Coreutils for windows (used for the tar & gzip commands); installed through chocolatey
* **Spark 2.1.0** with Hadoop 2.7: binaries downloaded directly from the official website
* **winutils.exe**: Required by spark to work (it's added in the `SPARK_HOME/bin` dir)

## How do I even ?

Actually, it's easy as pie 🍪. Turn on a powershell console with Administrator privileges and navigate to your script file, then:
```
PS> ./installer.ps1
```

At the moment there is one command argument for this script:
* `-Where "C:\"` the path were spark will be installed. In this example you will find spark in the dir `C:\spark`

## Hive
* Hive needs a temporary scratch dir (defualt is `/tmp/hive`) with write permissions
* Because of how the file system works on Windows this path is relative the current root you run the command (so if you're on C: drive, the folder will be available at `C:\tmp\hive`)

## Current problems
* Even though I'm using chmod to change the dir permissions spark may still fail to boot up complaining with the error `The root scratch dir: /tmp/hive on HDFS should be writable. Current permissions are: rw-rw-rw-`. Your Spark installation will not work until this is solved

## Reporting errors & contributing
* If you happen to run into any issue at all, don't hesitate to file a issue, here on Github 😁
* There are quite a lot of improvements to be made, please check the issue tracker or file your own improvement issue