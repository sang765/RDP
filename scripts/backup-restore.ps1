# Script backup và restore dữ liệu
param(
    [string]$Mode,
    [string]$BackupPath = "C:\backup.zip"
)

$foldersToBackup = @(
    "$env:USERPROFILE\AppData",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\LocalAppData"
)

if ($Mode -eq "backup") {
    try {
        if (Test-Path $BackupPath) {
            Remove-Item $BackupPath -Force
        }
        Compress-Archive -Path $foldersToBackup -DestinationPath $BackupPath -CompressionLevel Optimal
        Write-Output "Backup created successfully at $BackupPath"
    } catch {
        Write-Error "Failed to create backup: $($_.Exception.Message)"
    }
} elseif ($Mode -eq "restore") {
    if (Test-Path $BackupPath) {
        try {
            Expand-Archive -Path $BackupPath -DestinationPath "C:\" -Force
            Write-Output "Backup restored successfully from $BackupPath"
        } catch {
            Write-Error "Failed to restore backup: $($_.Exception.Message)"
        }
    } else {
        Write-Output "No backup found at $BackupPath"
    }
}