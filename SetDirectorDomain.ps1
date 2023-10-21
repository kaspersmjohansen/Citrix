$text = 'TextBox ID="Domain"'
$replacetext1 = 'TextBox ID="Domain" Text="'
$replacetext2 = $env:userdnsdomain
$replacetext3 = '" readonly="true"'
$replacetext = $replacetext1 + $replacetext2 + $replacetext3

$pathToFile = "C:\inetpub\wwwroot\Director"

Rename-Item $pathToFile\logon.aspx $pathToFile\logon.aspx.org

get-content $pathToFile\logon.aspx.org | % {$_ -replace $text, $replacetext} | set-content $pathToFile\logon.aspx