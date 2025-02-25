# speed up Invoke-WebRequest
# https://stackoverflow.com/questions/28682642/powershell-why-is-using-invoke-webrequest-much-slower-than-a-browser-download
$ProgressPreference = 'SilentlyContinue'

Write-Host ('Creating folder structure')
    New-Item -Type Directory -Path /installation -ErrorAction SilentlyContinue

    New-Item -Type Directory -Path /opt/fluent-bit
    New-Item -Type Directory -Path /opt/scripts/ruby
    New-Item -Type Directory -Path /opt/telegraf
    New-Item -Type Directory -Path /opt/windowsazuremonitoragent
    New-Item -Type Directory -Path /opt/windowsazuremonitoragent/datadirectory

    New-Item -Type Directory -Path /etc/fluent-bit
    New-Item -Type Directory -Path /etc/fluent
    New-Item -Type Directory -Path /etc/amalogswindows
    New-Item -Type Directory -Path /etc/telegraf
    New-Item -Type Directory -Path /etc/windowsazuremonitoragent

    New-Item -Type Directory -Path /etc/config/settings/
    New-Item -Type Directory -Path /etc/config/adx/

Write-Host ('Installing Fluent Bit');

    try {
        $fluentBitUri='https://fluentbit.io/releases/2.0/fluent-bit-2.0.14-win64.zip'
        Invoke-WebRequest -Uri $fluentBitUri -OutFile /installation/fluent-bit.zip
        Expand-Archive -Path /installation/fluent-bit.zip -Destination /installation/fluent-bit
        Move-Item -Path /installation/fluent-bit/*/* -Destination /opt/fluent-bit/ -ErrorAction SilentlyContinue
    }
    catch {
        $e = $_.Exception
        Write-Host "exception when Installing fluent bit"
        Write-Host $e
        exit 1
    }
Write-Host ('Finished Installing Fluentbit')

Write-Host ('Installing Telegraf');
try {
    $telegrafUri='https://dl.influxdata.com/telegraf/releases/telegraf-1.24.2_windows_amd64.zip'
    Invoke-WebRequest -Uri $telegrafUri -OutFile /installation/telegraf.zip
    Expand-Archive -Path /installation/telegraf.zip -Destination /installation/telegraf
    Move-Item -Path /installation/telegraf/*/* -Destination /opt/telegraf/ -ErrorAction SilentlyContinue
}
catch {
    $ex = $_.Exception
    Write-Host "exception while downloading telegraf for windows"
    Write-Host $ex
    exit 1
}
Write-Host ('Finished downloading Telegraf')

Write-Host ('Installing Visual C++ Redistributable Package')
    $vcRedistLocation = 'https://aka.ms/vs/16/release/vc_redist.x64.exe'
    $vcInstallerLocation = "\installation\vc_redist.x64.exe"
    $vcArgs = "/install /quiet /norestart"
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $vcRedistLocation -OutFile $vcInstallerLocation
    Start-Process $vcInstallerLocation -ArgumentList $vcArgs -NoNewWindow -Wait
    Copy-Item -Path /Windows/System32/msvcp140.dll -Destination /opt/fluent-bit/bin
    Copy-Item -Path /Windows/System32/vccorlib140.dll -Destination /opt/fluent-bit/bin
    Copy-Item -Path /Windows/System32/vcruntime140.dll -Destination /opt/fluent-bit/bin
Write-Host ('Finished Installing Visual C++ Redistributable Package')

Write-Host ('Extracting Certificate Generator Package')
    Expand-Archive -Path /opt/amalogswindows/certificategenerator.zip -Destination /opt/amalogswindows/certgenerator/ -Force
Write-Host ('Finished Extracting Certificate Generator Package')

Write-Host ('Installing Windows Azure Monitor Agent');
try {
    $windowsazuremonitoragent='https://github.com/microsoft/Docker-Provider/releases/download/windows-ama-bits/genevamonitoringagent.46.3.2.zip'
    Invoke-WebRequest -Uri $windowsazuremonitoragent -OutFile /installation/windowsazuremonitoragent.zip
    Expand-Archive -Path /installation/windowsazuremonitoragent.zip -Destination /installation/windowsazuremonitoragent
    Move-Item -Path /installation/windowsazuremonitoragent -Destination /opt/windowsazuremonitoragent/ -ErrorAction SilentlyContinue
}
catch {
    $ex = $_.Exception
    Write-Host "exception while downloading windowsazuremonitoragent"
    Write-Host $ex
    exit 1
}
Write-Host ('Finished downloading Windows Azure Monitor Agent')
Write-Host ("Removing Install folder")
Remove-Item /installation -Recurse
#Remove gemfile.lock for http_parser gem 0.6.0
#see  - https://github.com/fluent/fluentd/issues/3374 https://github.com/tmm1/http_parser.rb/issues/70
