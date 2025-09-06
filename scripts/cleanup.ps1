# Script cleanup
Write-Output "Starting cleanup process..."

# Dừng các dịch vụ VNC và Ngrok
try {
    Stop-Service -Name "tigervnc" -ErrorAction SilentlyContinue
    Write-Output "Stopped TigerVNC service"
} catch {
    Write-Output "Failed to stop TigerVNC service: $($_.Exception.Message)"
}

try {
    Get-Process -Name "ngrok" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Output "Stopped Ngrok process"
} catch {
    Write-Output "Failed to stop Ngrok process: $($_.Exception.Message)"
}

# Xóa file tạm
$filesToRemove = @(
    "C:\tigervnc.exe",
    "C:\ngrok.zip",
    "C:\backup.zip",
    "C:\keep-alive.ps1"
)

foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        try {
            Remove-Item -Path $file -Force
            Write-Output "Removed $file"
        } catch {
            Write-Output "Failed to remove $file: $($_.Exception.Message)"
        }
    }
}

# Xóa thư mục ngrok
if (Test-Path "C:\ngrok") {
    try {
        Remove-Item -Path "C:\ngrok" -Recurse -Force
        Write-Output "Removed Ngrok directory"
    } catch {
        Write-Output "Failed to remove Ngrok directory: $($_.Exception.Message)"
    }
}

Write-Output "Cleanup completed"
