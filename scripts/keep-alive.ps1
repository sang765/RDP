
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
    $vncService = Get-Service -Name "tvnserver" -ErrorAction SilentlyContinue
    if ($vncService.Status -ne "Running") {
        try {
            Start-Service -Name "tvnserver"
            Write-Output "Restarted TightVNC service"
        } catch {
            Write-Output "Failed to restart TightVNC service: $($_.Exception.Message)"
        }
    }
    
    # Kiểm tra và khởi động lại Ngrok nếu cần
    try {
        $ngrokProcess = Get-Process -Name "ngrok" -ErrorAction Stop
        # Check if tunnel exists
        $tunnelExists = $true
        try {
            $ngrokInfo = (Invoke-WebRequest -Uri "http://localhost:4040/api/tunnels" -UseBasicParsing -TimeoutSec 5).Content | ConvertFrom-Json
            $vncTunnel = $ngrokInfo.tunnels | Where-Object { $_.name -eq "vnc-tunnel" }
            if (-not $vncTunnel) {
                $tunnelExists = $false
            }
        } catch {
            $tunnelExists = $false
        }

        if (-not $tunnelExists) {
            Write-Output "VNC tunnel not found, recreating..."
            $tunnelConfig = @{
                name = "vnc-tunnel"
                proto = "tcp"
                addr = "5900"
            } | ConvertTo-Json

            Invoke-WebRequest -Uri "http://localhost:4040/api/tunnels" -Method POST -Body $tunnelConfig -ContentType "application/json" -UseBasicParsing -TimeoutSec 10 | Out-Null
            Write-Output "Recreated Ngrok tunnel"
        }
    } catch {
        Write-Output "Ngrok process not found, restarting..."
        try {
            Start-Process -FilePath "ngrok" -ArgumentList "start --none --log=stdout" -WindowStyle Hidden
            Start-Sleep -Seconds 5
            # Create tunnel
            $tunnelConfig = @{
                name = "vnc-tunnel"
                proto = "tcp"
                addr = "5900"
            } | ConvertTo-Json

            Invoke-WebRequest -Uri "http://localhost:4040/api/tunnels" -Method POST -Body $tunnelConfig -ContentType "application/json" -UseBasicParsing -TimeoutSec 10 | Out-Null
            Write-Output "Started Ngrok and created tunnel"
        } catch {
            Write-Output "Failed to restart Ngrok: $($_.Exception.Message)"
        }
    }
    
    Start-Sleep -Seconds $checkInterval
}

Write-Output "Keep-alive period completed"
