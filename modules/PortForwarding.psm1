function Start-PortForwarding {
    [CmdletBinding()]
    param(
        [int]$LocalPort,
        [string]$RemoteHost,
        [int]$RemotePort
    )
    try {
        Write-Host "Setting up port forwarding: localhost:$LocalPort -> ${RemoteHost}:$RemotePort"
        $tcpListener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $LocalPort)
        $tcpListener.Start(); $tcpListener.Stop()
        $jobScript = {
            param($LocalPort, $RemoteHost, $RemotePort)
            Add-Type -TypeDefinition @"
                using System; using System.Net; using System.Net.Sockets; using System.IO; using System.Threading;
                public class PortForwarder {
                    public static void Forward(int localPort, string remoteHost, int remotePort) {
                        TcpListener listener = new TcpListener(IPAddress.Loopback, localPort);
                        listener.Start();
                        while (true) {
                            try {
                                using (TcpClient client = listener.AcceptTcpClient())
                                using (TcpClient target = new TcpClient(remoteHost, remotePort))
                                using (NetworkStream clientStream = client.GetStream())
                                using (NetworkStream targetStream = target.GetStream()) {
                                    byte[] buffer = new byte[4096];
                                    int bytesRead;
                                    while (client.Connected && target.Connected) {
                                        if (clientStream.DataAvailable) {
                                            bytesRead = clientStream.Read(buffer,0,buffer.Length);
                                            targetStream.Write(buffer,0,bytesRead);
                                        }
                                        if (targetStream.DataAvailable) {
                                            bytesRead = targetStream.Read(buffer,0,buffer.Length);
                                            clientStream.Write(buffer,0,bytesRead);
                                        }
                                        Thread.Sleep(10);
                                    }
                                }
                            } catch (Exception ex) {
                                Console.Error.WriteLine($"Forwarding error: {ex.Message}");
                                Thread.Sleep(1000);
                            }
                        }
                    }
                }
"@
            [PortForwarder]::Forward($LocalPort,$RemoteHost,$RemotePort)
        }
        $global:PortForwardJob = Start-Job -ScriptBlock $jobScript -ArgumentList $LocalPort,$RemoteHost,$RemotePort
        $global:OpenAIEndpoint = "http://localhost:${LocalPort}"
        Write-Host "Port forwarding started successfully."
        return $true
    } catch {
        Write-Warning "Failed to start port forwarding: $_"
        return $false
    }
}

function Stop-PortForwarding {
    if ($global:PortForwardJob) {
        $global:PortForwardJob | Stop-Job -PassThru | Remove-Job -Force
        $global:PortForwardJob = $null
        Write-Host "Port forwarding stopped."
    }
}

function Check-PortForwarding {
    [CmdletBinding()]
    param(
        [int]$LocalPort = 8080,
        [int]$TimeoutMs = 2000
    )
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connect = $tcpClient.BeginConnect('localhost',$LocalPort,$null,$null)
        $success = $connect.AsyncWaitHandle.WaitOne($TimeoutMs,$false)
        if ($tcpClient.Connected) {
            $tcpClient.EndConnect($connect)|Out-Null
            $tcpClient.Close(); return $true
        }
        return $false
    } catch { return $false }
}

function Test-PortAvailable {
    param([Parameter(Mandatory=$true)][int]$Port)
    try {
        $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback,$Port)
        $listener.Start(); $listener.Stop(); return $true
    } catch { return $false }
}

Export-ModuleMember -Function Start-PortForwarding,Stop-PortForwarding,Check-PortForwarding,Test-PortAvailable
