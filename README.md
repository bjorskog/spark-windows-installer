# Installer Script for Spark on Windows

This is a powershell script used to install Spark and everything else (so it will actually work).

It will install the following (if the command has not been found, don't worry, it will ask before continueing): 
* **chocolatey**: A package manager for windows, used to install dependencies
* **python2**: Installed through chocolatey
* **Java 1.8.0 (jdk8, jre8)**: Installed through chocolatey
* **Scala 2.11**: Installed through chocolatey
* **GnuWin**: GNU Coreutils for windows (used for the tar & gzip commands); installed through chocolatey
* **Spark 2.1.0** with Hadoop 2.7: binaries downloaded directly from the official website
* **winutils.exe**: Required by spark to work (it's added in the `SPARK_HOME/bin` dir)

This script also sets the necessary environment variables on the User-level.

## Hive
* Hive needs a temporary scratch dir (defualt is `/tmp/hive`) with write permissions
* Because of how the file system works on Windows this path is relative the current root you run the command (so if you're on C: drive, the folder will be available at `C:\tmp\hive`)

## Reporting errors & contributing
* If you happen to run into any issue at all, don't hesitate to file a issue, here on Github 😁
* There are quite a lot of improvements to be made, please check the issue tracker or file your own improvement issue