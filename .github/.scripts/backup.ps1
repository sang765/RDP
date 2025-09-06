$backupDir = "C:\backup"
New-Item -Path $backupDir -ItemType Directory -Force
$folders = @("AppData", "LocalAppData", "Downloads", "Documents")
foreach ($folder in $folders) {
    $source = "C:\Users\${{ secrets.VNC_USER || 'vncrunner' }}\$folder"
    if (Test-Path $source) {
        Compress-Archive -Path $source -DestinationPath "$backupDir/$folder.zip" -Update
    }
}
