param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ComposeArgs
)

$vcxsrvPath = "C:\Program Files\VcXsrv\vcxsrv.exe"

# Start VcXsrv if it's not already running
if (-not (Get-Process | Where-Object { $_.Name -like "vcxsrv" })) {
    Start-Process -FilePath "$vcxsrvPath" `
        -ArgumentList ":0 -multiwindow -clipboard -wgl -ac" `
        -WindowStyle Minimized
    Start-Sleep -Seconds 2
    Write-Host "VcXsrv started"
} else {
    Write-Host "VcXsrv is already running"
}

# Set DISPLAY variable for Docker to send GUI to Windows
$env:DISPLAY = "host.docker.internal:0"
Write-Host "DISPLAY set to $env:DISPLAY"

Set-Location -Path "$PSScriptRoot"

# Build final command
$cmd = @("compose", "up", "-d") + $ComposeArgs

Write-Host "Running: docker $($cmd -join ' ')"
docker @cmd
