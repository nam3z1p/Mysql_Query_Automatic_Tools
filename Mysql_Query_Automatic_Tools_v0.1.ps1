
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted
$m_Time = Get-Date -Format "yyyyMM"

$dllpath = "Current_Path\MySql.Data.dll"

function Main-Title(){
    Write-Host "################################################"
    Write-Host "##        Mysql_Query_Automatic_Tools         ##"
    Write-Host "##                                            ##"
    Write-Host "##                      Developed by nam3z1p  ##"
    Write-Host "##                                   2020.03  ##"
    Write-Host "################################################"
}

# Password Encrytion
# "mypwd" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString"

function Connect-MySQL_DB() {
    [void][System.Reflection.Assembly]::LoadFrom($dllpath)

    $sqlUser = 'Input ID'
    #$sqlPwd = 'mypwd'
    $sqlPwd = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000767f8dafb843d44581fc00257604230600000000020000000000106600000001000020000000d2885384dba57d404ef3e331b6e0ca24ce002a2165abf6e58568711791601e3f000000000e80000000020000200000000c9bd2cd409615970c49041cd692fe09dbd73dcb424ab42d03069e2e5138216d1000000009c0aaafbc0ce4f93f7073fbbd3a98ae400000006c281b30f691fcafd62b26efa852bcf90f69f564a71f70fab8c94cdeef5d260fdd34ba0e5bc06e52d8fe52837b7b01abfb2f4d83265996c286bbabc5e7800103"
    $database = 'Input DB'
    $mySQLHost = 'Input IP'
    $sql_Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sqlUser, ($sqlPwd | ConvertTo-SecureString)

    $MySQL_connStr = "server=" + $mySQLHost + ";port=5306;uid=" + $sqlUser + ";pwd=" + $sql_Cred.GetNetworkCredential().Password + ";database="+$database+";Pooling=FALSE;"
    $MySQL_conn = New-Object MySql.Data.MySqlClient.MySqlConnection($MySQL_connStr)
    $Error.Clear()
    try{
        $MySQL_conn.Open()
    }catch{
        Write-Warning("Unable to connect to MySQL server..")
    }
    return $MySQL_conn
}

function Execute-MySQLQuery([string]$query, $conn) {
    $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $conn)
    $dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($cmd)
    $dataSet = New-Object System.Data.DataSet
    $dataAdapter.Fill($dataSet, "data") | Out-Null
    $cmd.Dispose()
    return $dataSet
}

function Disconnect-MySQL($conn) {
    $conn.Close()
}

function Send-Email([string]$Subject,[string]$Body) {
    $EmailFrom = "Input Email_From"
    $EmailTo = "Input Email_To"
    #$EmailPwd = "mypwd"
    $EmailPwd = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000767f8dafb843d44581fc00257604230600000000020000000000106600000001000020000000d2885384dba57d404ef3e331b6e0ca24ce002a2165abf6e58568711791601e3f000000000e80000000020000200000000c9bd2cd409615970c49041cd692fe09dbd73dcb424ab42d03069e2e5138216d1000000009c0aaafbc0ce4f93f7073fbbd3a98ae400000006c281b30f691fcafd62b26efa852bcf90f69f564a71f70fab8c94cdeef5d260fdd34ba0e5bc06e52d8fe52837b7b01abfb2f4d83265996c286bbabc5e7800103"
    $Email_Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $EmailFrom, ($EmailPwd | ConvertTo-SecureString)

    $SMTPServer = "smtp.gmail.com"
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo, $Subject, $Body)
    $SMTPClient = New-Object System.Net.Mail.SmtpClient($SMTPServer, 587)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Email_Cred.UserName, $Email_Cred.Password);
    $SMTPClient.Send($SMTPMessage)
}

function Main(){

    Main-Title

    $mysql_Conn = Connect-MySQL_DB

    $query = "SELECT COUNT(*) FROM Input_DB.Table a WHERE date > $m_Time;"
    $results = Execute-MySQLQuery $query $mysql_Conn

    Disconnect-MySQL $mysql_Conn

    if($results.Tables["data"].Rows[0][0] -lt 0){
        Write-Host "[!] It's not exists data $m_Time"
        exit
    }

    $email_Subject = "Input Subject"
    $email_Body = "[+] Counts : $($results.Tables["data"].Rows[0][0])"

    Send-Email $email_Subject $email_Body

    Write-Host "[+] Done"

}

Main
