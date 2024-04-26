param (
    [Parameter(Position=0, mandatory=$true)]
    [string] $jsonConfigFilePath,
    [parameter(mandatory=$false)]
    [int] $debugLvl = 2
)


function Hello-World {
    Write-Host "Hello World"
    return 0
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

    if(-Not($directoryPath)){
        return 23
    }

    if(-Not($filesToManage)){
        return 24
    }

    # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path?view=powershell-7.4
    if(-Not(Test-Path -Path $directoryPath)){
        return 14
    }

    # https://devblogs.microsoft.com/scripting/powertip-using-powershell-to-determine-if-path-is-to-file-or-folder/
    if(-Not((Get-Item $directoryPath) -is [System.IO.DirectoryInfo])){
        return 14
    }

    try {
        foreach($file in $filesToManage) {
            $filePath = Join-Path $directoryPath $file
            if(!$deleteFiles) {
                if(-Not (Test-Path -Path $filePath)){
                    New-Item -Path $filePath -type file -Force
                    Write-Host "Created file: $filePath"
                } else {
                    Write-Host "File $filePath already existed"
                }
            } elseif($deleteFiles) {
                if(Test-Path -Path $filePath){
                    Remove-Item -Path $filePath
                    Write-Host "Deleted file: $filePath"
                } else {
                    Write-Host "File $filePath does not exist"
                }
            } else {
                Write-Host "Invalid parameter passed in for deleteFiles: $deleteFiles"
            }
        }
    } catch {
        Write-Host "An unresolved exception occured"
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
        $hashTable = @{}
        $sortedHashTable =[ordered]@{}
        $outFilePath = Join-Path $directoryPath $outFile

        $wordCase = $case.ToLower()

        foreach($word in $wordArray){
            if($hashTable.ContainsKey($word)){
                $hashTable[$word]++
            } else {
                if ($wordCase -eq "upper") {
                    $hashTable.Add($word.ToUpper(), 1)
                } elseif ($wordCase -eq "lower") {
                    $hashTable.Add($word.ToLower(), 1)
                } else {
                    $hashTable.Add($word, 1)
                }
            }
        }

        Write-Host "Unsorted Table length:"
        Write-Host $hashTable.Count

        # Does not work with ordered hash tables
        foreach($key in $hashTable.keys){
            $msg = 'key: {0} value: {1}' -f $key, $hashTable[$key]
            Write-Host $msg
        }

        if($sortDescending) {
            Write-Host "Sort Descending"
            $sortedHashTable = $hashTable.GetEnumerator() | Sort-Object -Property key -Descending
        } else {
            Write-Host "Sort Asscending"
            $sortedHashTable = $hashTable.GetEnumerator() | Sort-Object -Property key
        } 
        
        Write-Host "sorted Table length:"
        Write-Host $sortedHashTable.Count

        # Works with ordered hash tables
        foreach($hash in $sortedHashTable.GetEnumerator()){
            $msg = 'key: {0} value: {1}' -f $hash.Name, $hash.Value
            Write-Host $msg
        }

        try {
            $sortedHashTable | Select-Object Key,Value | Export-Csv -Path $outFilePath -Delimiter $delimiter -NoTypeInformation
        } catch [System.IO.FileNotFoundException], [System.IO.IOException] {
            Write-Host "An IO error occurred writting to the output CSV file"
            return 10
        } catch {
            Write-Host "An unresolved exceoption occurred writting to the output CSV file"
            return 11
        }

    } catch {
        Write-Host "An unresolved exception occurred in Word-Hash-Map"
        return 3
    }

    return 0
}

function default-fctn {
    Write-Host "Default Case"
}

try {

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

        # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-content?view=powershell-7.4
        # https://lazyadmin.nl/powershell/get-content/
        $jsonConfig = Get-Content -Path $jsonConfigFilePath -Raw
        # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json?view=powershell-7.4
        # https://adamtheautomator.com/powershell-json/
        $configObj = ConvertFrom-Json -InputObject $jsonConfig
    
        $task = $configObj.Task
        Write-Host "Task: $task"
        Write-Host $configObj

    # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.4
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

    # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_switch?view=powershell-7.4
    # https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-switch?view=powershell-7.4
    switch ( $task ) 
    {
        0 { $res = Hello-World }
        1 { $res = Hello-Name($configObj.Name) }
        2 { $res = Manage-Files -deleteFiles $configObj.DeleteFiles -directoryPath $configObj.DirectoryPath -filesToManage $configObj.FilesToManage }
        3 { $res = Word-Hash-Map -sortDescending $configObj.SortDescending -wordArray $configObj.WordArray -directoryPath $configObj.DirectoryPath -outFile $configObj.OutFile -delimiter $configObj.Delimiter -case $configObj.Case }
        default { default-fctn }
    }

    if( $res -eq 0 ) {
        Write-Host "Task: $task completed successfully"
    } elseif ( $res -in 10..19 ){ 
        Write-Host "The tesk function had a file IO error. res: $res"
    } elseif ( $res -in 20..29 ){
        Write-Host "The tesk function recieved invalid input params. res: $res"
    } else {
        Write-Host "The task funtion did not coplete successfully. res: $res"
    }

} catch {
    "An unresolved error occured"
    Exit 1
}