$a = Get-Date
$stop_watch = [system.diagnostics.stopwatch]::startNew()
Invoke-Expression "$args"
$stop_watch.Stop()
Write-Host Elapsed: $stop_watch.Elapsed
$b = Get-Date
Write-Host $a.ToString() - $b.ToString() `, ($b-$a)
