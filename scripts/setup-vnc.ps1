# Script cài đặt và cấu hình VNC
param(
    [string]$VncPassword,
    [string]$UserName
)

# Kiểm tra và tạo user nếu chưa tồn tại
if (-not (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue)) {
    $password = ConvertTo-SecureString "TempPassword123!" -AsPlainText -Force
    New-LocalUser -Name $UserName -Password $password -FullName "GitHub Runner"
    Add-LocalGroupMember -Group "Administrators" -Member $UserName
    Write-Output "Created user: $UserName"
} else {
    Write-Output "User $UserName already exists"
}

# Tải và cài đặt TigerVNC
$vncInstallerPath = "$env:TEMP\tigervnc-installer.exe"
try {
    Invoke-WebRequest -Uri "https://sourceforge.net/projects/tigervnc/files/stable/1.13.1/tigervnc-64-1.13.1.exe/download" -OutFile $vncInstallerPath
    Start-Process -FilePath $vncInstallerPath -ArgumentList "/S" -Wait
    Write-Output "TigerVNC installed successfully"
} catch {
    Write-Error "Failed to install TigerVNC: $($_.Exception.Message)"
}

# Thiết lập VNC password
$vncPasswdPath = "C:\Program Files\TigerVNC\vncpasswd.exe"
if (Test-Path $vncPasswdPath) {
    $tempPassFile = "$env:TEMP\vncpass.txt"
    try {
        # Tạo file password
        $VncPassword | Out-File -FilePath $tempPassFile -Encoding ASCII
        $VncPassword | Out-File -FilePath $tempPassFile -Encoding ASCII -Append
        
        # Thiết lập password
        Get-Content $tempPassFile | & "$vncPasswdPath" -f
        Remove-Item $tempPassFile -Force
        Write-Output "VNC password set successfully"
    } catch {
        Write-Error "Failed to set VNC password: $($_.Exception.Message)"
    }
} else {
    Write-Error "VNC password utility not found"
}
