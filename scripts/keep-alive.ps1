# Script keep-alive để duy trì kết nối
$duration = 6 * 60 * 60  # 6 giờ
$startTime = Get-Date
$checkInterval = 300  # 5 phút

Write-Output "Starting keep-alive script for $duration seconds"

while (((Get-Date) - $startTime).TotalSeconds -lt $duration) {
    $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds)
    $remaining = $duration - $elapsed
    $hours = [math]::Floor($remaining / 3600)
    $minutes = [math]::Floor(($remaining % 3600) / 60)
    $seconds = $remaining % 60
    
    Write-Output "Keeping alive... Time remaining: ${hours}h ${minutes}m ${seconds}s"
    
    # Kiểm tra và khởi động lại VNC nếu cần
    $vncService = Get-Service -Name "tigervnc" -ErrorAction SilentlyContinue
    if ($vncService.Status -ne "Running") {
        try {
            Start-Service -Name "tigervnc"
            Write-Output "Restarted TigerVNC service"
        } catch {
            Write-Output "Failed to restart TigerVNC service: $($_.Exception.Message)"
        }
    }
    
    # Kiểm tra và khởi động lại Ngrok nếu cần
    $ngrokProcess = Get-Process -Name "ngrok" -ErrorAction SilentlyContinue
    if (-not $ngrokProcess) {
        try {
            Start-Process -FilePath "ngrok" -ArgumentList "tcp 5900 --log stdout" -WindowStyle Hidden
            Write-Output "Restarted Ngrok process"
        } catch {
            Write-Output "Failed to restart Ngrok process: $($_.Exception.Message)"
        }
    }
    
    Start-Sleep -Seconds $checkInterval
}

Write-Output "Keep-alive period completed"
