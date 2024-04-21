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
        [bool] $deleteFiles,
        [string] $directoryPath,
        [string[]] $filesToManage
    )
}

function Word-Hash-Map {
    param (
        [bool] $sortDescending,
        [string[]] $wordArray
    )
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
        3 { Word-Hash-Map -sortDescending $configObj.SortDescending -wordArray $configObj.WordArray }
        default { default-fctn }
    }

} catch [System.IO.FileNotFoundException], [System.IO.IOException] {
    "File IO error regarding input json config file"
    Exit 1
} catch {
    "An unresolved error occured"
    Exit 2
}