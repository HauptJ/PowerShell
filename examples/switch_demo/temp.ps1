
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