param (
    [Parameter(Position=0, mandatory=$true)]
    [string] $jsonConfigFilePath,
    [parameter(mandatory=$false)]
    [int] $debugLvl = 2,
    [parameter(mandatory=$false)]
    [string] $reportFilePath
)



Set-PSDebug -Trace 2

function Hello-World {
    Write-Host "Hello World"
}


function Hello-Name($name="Bob") {
    Write-Host "Hello $name"
}

function Manage-Files {
    param (
        [bool] $deleteFiles = "false",
        [string] $directoryPath,
        [string[]] $filesToManage
    )
    
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
}

function Word-Hash-Map {
    param (
        [bool] $sortDescending = "false",
        [string[]] $wordArray,
        [string] $directoryPath,
        [string] $outFile = "sorted.txt",
        [string] $delimiter = ";",
        [bool] $upperCase = "false"
    )

    try {
        $hashTable = @{}
        $sortedHastTable =[ordered]@{}
        $outFilePath = Join-Path $directoryPath $outFile

        foreach($word in $wordArray){
            if($hashTable.ContainsKey($word)){
                $hashTable[$word]++
            } else {
                if ($upperCase) {
                    $hashTable.Add($word.ToUpper(), 1)
                } else {
                    $hashTable.Add($word.ToLower(), 1)
                }
            }
        }

        Write-Output $hashTable

        if($sortDescending) {
            $sortedHastTable = $hashTable.GetEnumerator() | Sort-Object -Property key -Descending
        } else {
            $sortedHastTable = $hashTable.GetEnumerator() | Sort-Object -Property key
        } 
        
        Write-Output $sortedHastTable

        $sortedHastTable | Select-Object Key,Value | Export-Csv -Path $outFilePath -Delimiter $delimiter -NoTypeInformation

    } catch {
        Write-Host "An unresolved exception occurred"
    }

}

function default-fctn {
    Write-Host "Default Case"
}

try {

    if ($debugLvl > 0) {
        Set-PSDebug -Trace $debugLvl
    } elseif ($debugLvl -eq 0) {
        Set-PSDebug -Off
    }

    $jsonConfig = Get-Content -Path $jsonConfigFilePath -Raw
    $configObj = ConvertFrom-Json -InputObject $jsonConfig

    $task = $configObj.Task
    Write-Host "Task: $task"
    Write-Host $configObj

    switch ( $task ) 
    {
        0 { Hello-World }
        1 { Hello-Name($configObj.Name) }
        2 { Manage-Files -deleteFiles $configObj.DeleteFiles -directoryPath $configObj.DirectoryPath -filesToManage $configObj.FilesToManage }
        3 { Word-Hash-Map -sortDescending $configObj.SortDescending -wordArray $configObj.WordArray -directoryPath $configObj.DirectoryPath -outFile $configObj.OutFile -delimiter $configObj.Delimiter -upperCase $configObj.UpperCase }
        default { default-fctn }
    }

} catch [System.IO.FileNotFoundException], [System.IO.IOException] {
    "File IO error regarding input json config file"
    Exit 1
} catch {
    "An unresolved error occured"
    Exit 2
}