# Dừng VNC service
$vncDir = "C:\tigervnc"
.$vncDir\vncserver.exe -service -stop

# Xóa thư mục tạm
Remove-Item -Path "C:\backup" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\tigervnc" -Recurse -Force -ErrorAction SilentlyContinue
