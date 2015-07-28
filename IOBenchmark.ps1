Set-StrictMode -version latest



<#

Based on: 

http://blogs.msdn.com/b/sqlmeditation/archive/2013/04/04/choosing-what-sqlio-tests-to-run-and-automating-sqlio-testing-somewhat.aspx

#>


$computerName =  $env:COMPUTERNAME
$numberofProcessors = $env:NUMBER_OF_PROCESSORS
$duration = 5 #300
$outputDirectory = "C:\IoTest\"

if(-not (Test-path $outputDirectory)) {

New-Item -ItemType directory $outputDirectory -Force

}

$testFile = "C:\TestFile.dat"

$VerbosePreference = "Continue"

"Running SQL I/O Benchmark on $computerName CPU Count: $numberOfProcessors"

Push-Location "C:\Program Files (x86)\SQLIO"

#region Read Tests Match O/S CPU Count


<#
Similar to single-page reads (8 KB) in SQL. 
#>

Write-Verbose "SQL Server: Single Page Reads"
./sqlio.exe -kR -t"$numberofProcessors" -s"$duration"  -o8 -frandom -b8 -BH -LS  "$testFile" > "$outputDirectory\Reads8KRandom8Outstanding.txt"

if($?){"Done..."} else {"Failed"}

#$foo = ./sqlio.exe -kR -t8 -s5 -o8 -frandom -b8 -BH -LS  F:\IoTest\TestFile.dat

<#
Similar to extent reads I/O 64KB
#>
Write-Verbose "SQL Server: Extent Reads"
.\sqlio.exe -kR -t"$numberofProcessors"2 -s"$duration"  -frandom -o8 -b64 -LS -BH "$testFile" > "$outputDirectory\Reads64KRandom8Outstanding.txt"

if($?){"Done..."} else {"Failed"}

<#
 Similar to Read-Ahead in SQL; 
#>
Write-Verbose "SQL Server: Read-Aheads(Standard Edition)"
.\sqlio.exe -kR -t"$numberofProcessors" -s"$duration" -frandom -o8 -b512 -LS -BH "$testFile"  > "$outputDirectory\Reads512KRandom8Outstanding.txt"

if($?){"Done..."} else {"Failed"}

<#
 Similar to Read-Ahead in SQL; 
#>
Write-Verbose "SQL Server: Read-Aheads(Enterprise Edition)"
.\sqlio.exe -kR -t"$numberofProcessors" -s"$duration" -frandom -o8 -b1024 -LS -BH "$testFile" > "$outputDirectory\Reads1024KRandom8Outstanding.txt"

if($?){"Done..."} else {"Failed"}

#endregion

#region Write Tests


<# 

    8 KB Writes 

    – single-page writes in SQL (rare)
    - Log Writes (though log write sizes vary) 
    - Eager Writes may be similar; 
#>
Write-Verbose "SQL Server: Single Page Writes"
 .\sqlio.exe -kW -t2 -s"$duration" -frandom -o8 -b8 -LS -BH "$testFile" > "$outputDirectory\Writes8KRandom8Outstanding.txt"

 if($?){"Done..."} else {"Failed"}

<#
  256 KB Writes

  Checkpoint in SQL Server (2 thread 100 outstanding)
#>
Write-Verbose "SQL Server: Checkpoint (2 thread 100 outstanding)"
.\sqlio.exe -kW -t2 -s"$duration"  -frandom -o100 -b256 -LS -BH "$testFile" > "$outputDirectory\Writes256KRandom100Outstanding.txt"

if($?){"Done..."} else {"Failed"}

<#
   256 KB Writes 
   - Checkpoint in SQL Server (1 thread 200 outstanding)

#>

Write-Verbose "SQL Server: Checkpoint (1 thread 200 outstanding)"
.\sqlio.exe -kW -t1 -s"$duration" -frandom -o200 -b256 -LS -BH "$testFile" > "$outputDirectory\Writes256KRandom200Outstanding.txt"

if($?){"Done..."} else {"Failed"}

Write-Verbose "Done.."

Pop-Location 


#endregion


#start-Process powershell -Verb runAs
<#
FSUTIL.EXE file createnew L:\testfile.dat (40GB) 
FSUTIL.EXE file setvaliddata L:\testfile.dat (40GB)

FSUTIL.EXE file createnew S:\testfile.dat (40GB) 
FSUTIL.EXE file setvaliddata S:\testfile.dat (40GB)

FSUTIL.EXE file createnew T:\testfile.dat (40GB) 
FSUTIL.EXE file setvaliddata T:\testfile.dat (40GB)
#>
