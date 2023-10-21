If (Get-Volume | where {$_.FileSystemLabel -eq "Citrix Boot"})
{
$CitrixBootDisk = Get-Volume | where {$_.FileSystemLabel -eq "Citrix Boot"}
$BootDiskDriveLtr = $CitrixBootDisk.Driveletter+":"
$CitrixBootDisk | Get-Partition | Remove-PartitionAccessPath -AccessPath $BootDiskDriveLtr
}