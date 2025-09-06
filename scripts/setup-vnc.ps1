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
}

# Tải và cài đặt TigerVNC
$vncInstallerPath = "$env:TEMP\tigervnc-installer.exe"
Invoke-WebRequest -Uri "https://sourceforge.net/projects/tigervnc/files/latest/download" -OutFile $vncInstallerPath
Start-Process -FilePath $vncInstallerPath -ArgumentList "/S" -Wait

# Thiết lập VNC password
$passwordFile = "$env:PROGRAMFILES\TigerVNC\vncpasswd.txt"
echo $VncPassword | Out-File -FilePath $passwordFile -Encoding ASCII
