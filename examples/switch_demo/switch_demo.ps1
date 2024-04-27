param (
    [Parameter(Position=0, mandatory=$true)] # Mandatory / required param: .\switch_demo.ps1 .\jsonConfigTask0.json
    [string] $jsonConfigFilePath,
    [parameter(mandatory=$false)] # Optional param; Enable PS-Debug: .\switch_demo.ps1 .\jsonConfigTask0.json -debugLvl 2
    [int] $debugLvl = 0 # Default value for optional paramater
)

# Functions https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/09-functions?view=powershell-7.4
# Advanced Functions with Parameters https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced?view=powershell-7.4
function generate-report-msg-if-else {

    Param(
        [Parameter(Mandatory=$true)]
        [int] $returnCode,
        [Parameter(Mandatory=$true)]
        [int] $task
    )

    # Everything you wanted to know about the if statement https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-if?view=powershell-7.4
    if( $res -eq 0 ) { # About Comparison Operators: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-7.4
        Write-Host "Task: $task completed successfully"
    } elseif ( $res -in 10..19 ){ 
        Write-Host "The tesk function had a file IO error. res: $returnCode" # Within range https://stackoverflow.com/questions/23399104/how-to-tell-if-a-number-is-within-a-range-in-powershell
    } elseif ( $res -in 20..29 ){
        Write-Host "The tesk function recieved invalid input params. res: $returnCode"
    } else {
        Write-Host "The task funtion did not coplete successfully. res: $returnCode"
    }
}

function generate-report-msg-switch {

    Param(
        [Parameter(Mandatory=$true)]
        [int] $returnCode,
        [Parameter(Mandatory=$true)]
        [int] $task
    )

    # Switch case with ScriptBlock https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-switch?view=powershell-7.4#scriptblock
    # Throw https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_throw?view=powershell-7.4
    try {
        switch ( $returnCode )
        {
            ({$PSItem -eq 0})
            {
                Write-Host "Task: $task completed successfully - no errors thrown"
                return 0
            }
            ({$PSItem -in 11..15})
            {
                throw "The directoryPath provided is invalid for task: $task returnCode: $returnCode"
            }
            ({$PSItem -in 16..19 })
            {
                throw "There was a file IO error in task: $task returnCode: $returnCode"
            }
            ({$PSItem -in 20..29})
            {
                throw "An invalid or missing param was passed in task: $task returnCode: $returnCode"
            }
            default
            {
                throw "An unhandled non-zero returnCode: $returnCode was returned from task: $task"
            }
        }
    } catch {
        throw "An exception was thrown in generate-report-msg"
    } 
}

function validate-directory-path($directoryPath){

    # Return https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_return?view=powershell-7.4
    try {
        if(-Not($directoryPath)){
            return 11
        } elseif(-Not(Test-Path -Path $directoryPath)){ # test-path: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path?view=powershell-7.4
            return 12
        } elseif(-Not((Get-Item $directoryPath) -is [System.IO.DirectoryInfo])){ # Determine if a path is to a file or a folder: https://devblogs.microsoft.com/scripting/powertip-using-powershell-to-determine-if-path-is-to-file-or-folder/
            return 13
        } else {
            return 0
        }
    } catch [System.IO.IOException]  {
        Write-Host "An IO exception occured in validate-directory-path: $directoryPath"
        return 14
    } catch {
        Write-Host "An unresolved exception occured in validate-directory-path: directoryPath: $directoryPath"
        return 15
    }
}


function Hello-World {
    # Try Catch Finally: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.4
    try {
        Write-Host "Hello World" # Write-Host: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-host?view=powershell-7.4
        return 0
    } catch {
        throw "An unresolved error was thrown in Hello-World"
    } finally {
        Write-Host "Hello World task completed"
    }
}


function Hello-Name($name) {
    if(-Not($name)){
        return 21
    } else {
        Write-Host "Hello $name"
    }

    return 0
}


function Manage-Files {
    param (
        [bool] $deleteFiles = "false",
        [string] $directoryPath,
        [string[]] $filesToManage
    )

    try {

        $validDirPath = validate-directory-path($directoryPath)
        if($validDirPath -ne 0){
            return $validDirPath
        }

        if(-Not($filesToManage)){
            return 24
        }

        # About Foreach: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_foreach?view=powershell-7.4
        foreach($file in $filesToManage) {  
            $filePath = Join-Path $directoryPath $file
            if(!$deleteFiles) { # equivalent to -Not($deleteFiles)
                if(-Not (Test-Path -Path $filePath)){
                    New-Item -Path $filePath -type file -Force # Create file item; New-Item: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_foreach?view=powershell-7.4
                    Write-Host "Created file: $filePath"
                } else {
                    Write-Host "File $filePath already existed"
                }
            } elseif($deleteFiles) {
                if(Test-Path -Path $filePath){
                    # How to Delete a File with PowerShell Remove-Item: https://lazyadmin.nl/powershell/powershell-delete-file/
                    Remove-Item -Path $filePath # Delete file item; Remove-Item: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-item?view=powershell-7.4
                    Write-Host "Deleted file: $filePath"
                } else {
                    Write-Host "File $filePath does not exist"
                }
            } else {
                Write-Host "Invalid parameter passed in for deleteFiles: $deleteFiles"
                return 25
            }
        }
    } catch {
        Write-Host "An unresolved exception occured in Manage-Files"
        return 4
    }

    return 0
}


function Word-Hash-Map {
    param (
        [bool] $sortDescending = "false",
        [string[]] $wordArray,
        [string] $directoryPath,
        [string] $outFile = "sorted.txt",
        [string] $delimiter = ";",
        [string] $case = "lower"
    )

    try {

        $validDirPath = validate-directory-path($directoryPath)
        if($validDirPath -ne 0){
            return $validDirPath
        }

        # About Hash Tables: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7.4
        # Everything you wanted to know about hashtables: https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-hashtable?view=powershell-7.4
        $hashTable = @{}
        $sortedHashTable =[ordered]@{}
        # Join-Path: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/join-path?view=powershell-7.4
        # How to Combine Multiple Paths in PowerShell: https://www.byteinthesky.com/powershell/combine-multiple-paths/
        $outFilePath = Join-Path $directoryPath $outFile

        $wordCase = $case.ToLower() # Convert a String to Uppercase or Lowercase: https://www.powershellcookbook.com/recipe/EHBp/convert-a-string-to-uppercase-or-lowercase

        foreach($word in $wordArray){
            if($hashTable.ContainsKey($word)){
                $hashTable[$word]++
            } else {
                if ($wordCase -eq "upper") {
                    $hashTable.Add($word.ToUpper(), 1) # Convert a String to Uppercase or Lowercase: https://www.powershellcookbook.com/recipe/EHBp/convert-a-string-to-uppercase-or-lowercase
                } elseif ($wordCase -eq "lower") {
                    $hashTable.Add($word.ToLower(), 1)
                } else {
                    $hashTable.Add($word, 1)
                }
            }
        }

        Write-Host "Unsorted Table length:"
        Write-Host $hashTable.Count

        # Looping through a hash table in PowerShell https://stackoverflow.com/questions/9015138/looping-through-a-hash-or-using-an-array-in-powershell
        # Iterate Over A Hashtable in PowerShell: https://arcanecode.com/2020/12/14/iterate-over-a-hashtable-in-powershell/
        # Does not work with ordered hash tables
        foreach($key in $hashTable.keys){
            $msg = 'key: {0} value: {1}' -f $key, $hashTable[$key]
            Write-Host $msg
        }

        if($sortDescending) {
            Write-Host "Sort Descending"
            $sortedHashTable = $hashTable.GetEnumerator() | Sort-Object -Property key -Descending # Sort-Object: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/sort-object?view=powershell-7.4
        } else {
            Write-Host "Sort Asscending"
            $sortedHashTable = $hashTable.GetEnumerator() | Sort-Object -Property key
        } 
        
        Write-Host "sorted Table length:"
        Write-Host $sortedHashTable.Count

        # Looping through a hash table in PowerShell https://stackoverflow.com/questions/9015138/looping-through-a-hash-or-using-an-array-in-powershell
        # Works with ordered hash tables
        foreach($hash in $sortedHashTable.GetEnumerator()){
            $msg = 'key: {0} value: {1}' -f $hash.Name, $hash.Value
            Write-Host $msg
        }

        try {
            # Select-Object: https://learn.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Utility/Select-Object?view=powershell-7.4
            # How to use PowerShell Select-Object: https://lazyadmin.nl/powershell/select-object/
            # Export-Csv: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-csv?view=powershell-7.4
            # Export-Csv Essentials: https://adamtheautomator.com/export-csv/
            $sortedHashTable | Select-Object Key,Value | Export-Csv -Path $outFilePath -Delimiter $delimiter -NoTypeInformation
        } catch [System.IO.FileNotFoundException], [System.IO.IOException] {
            Write-Host "An IO error occurred writting to the output CSV file"
            return 16
        } catch {
            Write-Host "An unresolved exceoption occurred writting to the output CSV file"
            return 17
        }

    } catch {
        Write-Host "An unresolved exception occurred in Word-Hash-Map"
        return 5
    }

    return 0
}


function default-fctn {
    Write-Host "Default Case"
}


try {

    # Set-PSDebug: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-psdebug?view=powershell-7.4
    if ($debugLvl -gt 0) {
        Set-PSDebug -Trace $debugLvl
    } elseif ($debugLvl -eq 0) {
        Set-PSDebug -Off
    }

    try {
        if(-Not(Test-Path($jsonConfigFilePath))){
            # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_throw?view=powershell-7.4
            throw New-Object System.IO.FileNotFoundException
        }

        # Get-Content: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-content?view=powershell-7.4
        # Get-Content: https://lazyadmin.nl/powershell/get-content/
        $jsonConfig = Get-Content -Path $jsonConfigFilePath -Raw
        # ConvertFrom-Json: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json?view=powershell-7.4
        # PowerShell and JSON: A Comprehensive Guide https://adamtheautomator.com/powershell-json/
        $configObj = ConvertFrom-Json -InputObject $jsonConfig
    
        $task = $configObj.Task
        Write-Host "Task: $task"
        Write-Host $configObj

    # Terminating a script in PowerShell; Exit vs Return vs Break: https://stackoverflow.com/questions/2022326/terminating-a-script-in-powershell
    # Language Key Word "exit": https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_language_keywords?view=powershell-7.4#exit
    } catch [System.IO.FileNotFoundException] {
        Write-Host "File IO error: Json input file not found. jsonConfigFilePath: $jsonConfigFilePath"
        Exit 3
    } catch  [System.IO.IOException] {
        Write-Host "File IO error: Unable to read the input json config file. jsonConfigFilePath: $jsonConfigFilePath"
        Exit 3
    } catch {
        Write-Host "An unresolved error occured reading input json config file"
        Exit 4
    }

    $res = 0

    # About Switch: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_switch?view=powershell-7.4
    # Everything About Switch: https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-switch?view=powershell-7.4
    switch ( $task ) 
    {
        0 { $res = Hello-World }
        1 { $res = Hello-Name($configObj.Name) }
        2 { $res = Manage-Files -deleteFiles $configObj.DeleteFiles -directoryPath $configObj.DirectoryPath -filesToManage $configObj.FilesToManage }
        3 { $res = Word-Hash-Map -sortDescending $configObj.SortDescending -wordArray $configObj.WordArray -directoryPath $configObj.DirectoryPath -outFile $configObj.OutFile -delimiter $configObj.Delimiter -case $configObj.Case }
        default { default-fctn }
    }

    # if elif else example
    generate-report-msg-if-else -returnCode $res -task $task
    # complex switch case implementation with throw
    generate-report-msg-switch -returnCode $res -task $task

} catch {
    # $Error Automatic Variable: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.4#error
    Write-Host "An error occured"
    if($Error.Count -gt 0){

        Write-Host "Errors thrown: " $Error.Count # Everything you wanted to know about arrays: https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-arrays?view=powershell-7.4
        foreach($err in $Error){
            Write-Host "Error: $err"
        }
    }
    Exit 1
}