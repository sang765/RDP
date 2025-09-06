$backupDir = "C:\backup"
$userDir = "C:\Users\${{ secrets.VNC_USER || 'vncrunner' }}"
$folders = @("AppData", "LocalAppData", "Downloads", "Documents")
foreach ($folder in $folders) {
    $zipFile = "$backupDir/$folder.zip"
    if (Test-Path $zipFile) {
        Expand-Archive -Path $zipFile -DestinationPath "$userDir\$folder" -Force
    }
}
