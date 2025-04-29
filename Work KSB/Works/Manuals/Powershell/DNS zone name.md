#powershell #dns #windows

Записи комментариев экранированы ==/==

/# Define the DNS zone name
$zoneName = 'dns_zone.local'

/# Retrieve the DNS records and format the output
$dnsRecords = Get-DnsServerZone -Name $zoneName | Get-DnsServerResourceRecord | Select-Object -Property `
    HostName, `
    RecordType, `
    @{Label="RecordData"; Expression={
        $RR = $_.RecordData
        switch ($_.RecordType) {
            "A" { $RR.IPv4Address }
            "AAAA" { $RR.IPv6Address }
            "CNAME" { $RR.HostNameAlias }
            "SRV" {
                "$($RR.Priority) $($RR.Weight) $($RR.Port) $($RR.DomainName)"
            }
            "PTR" { $RR.PtrDomainName }
            "MX" {
                "$($RR.Preference) $($RR.MailExchange)"
            }
            "TXT" { $RR.DescriptiveText }
        }
    }}

/# Define the output file path
$outputFilePath = "C:\path\to\output\DnsRecords.txt"

/# Export the DNS records to a text file with tabular formatting
$dnsRecords | Format-Table -AutoSize | Out-File -FilePath $outputFilePath

Write-Output "DNS records have been exported to $outputFilePath"
