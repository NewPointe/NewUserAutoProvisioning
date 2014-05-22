
Import-Module ActiveDirectory
Write-Host "First name: " -ForegroundColor White -NoNewline
$NewFirstName = Read-Host
Write-Host "Last name: " -ForegroundColor White -NoNewline
$NewLastName = Read-Host
Write-Host "`n"
$NewDisplayName = $NewFirstName + ' ' + $NewLastName
$NewUserName = $NewFirstName.Substring(0,1) + $NewLastName
$NewUserName = $NewUserName.ToLower()
$TestUserName = Get-ADUser -LDAPFilter "(sAMAccountName=$NewUserName)"
If ($TestUserName -eq $null) {
    Write-Host "User name $NewUserName isn't being used, so we're good to go there." -ForegroundColor Green
    Write-Host "`n"
    CreationStep2
}
Else {
    UsernameAttempt2
}
function UsernameAttempt2 {
    Write-Host "Username $NewUserName already exists, so let's add the user's middle initial to the username to make it unique." -ForegroundColor Red
    Write-Host "What is their middle initial? " -NoNewline
    $NewMI = Read-Host
    $NewUserName = $NewFirstName.Substring(0,1) + $NewMI + $NewLastName
    $NewUserName = $NewUserName.ToLower()
    Write-Host "`n"
    Write-Host "OK, let's try $NewUserName and see if it's taken..."
    Write-Host "`n"
    $TestUserName = Get-ADUser -LDAPFilter "(sAMAccountName=$NewUserName)"
    If ($TestUserName -eq $null) {
        Write-Host "User name $NewUserName isn't being used, so we're good to go." -FiregroundColor Green
        Write-Host "`n"
        CreationStep2
    }
    Else {
        UsernameAttempt3
    }
}
function UsernameAttempt3 {
    Write-Host "Username $NewUserName also exists, so we'll need you to just enter a custom user name here." -ForegroundColor Red
    Write-Host "Enter a custom user name: " -NoNewline
    $CustomUserName = Read-Host
    $NewUserName = $CustomUserName
    Write-Host "`n"
    Write-Host "OK, let's try $NewUserName and see if it's taken..."
    $TestUserName = Get-ADUser -LDAPFilter "(sAMAccountName=$NewUserName)"
    If ($TestUserName -eq $null) {
        Write-Host "User name $NewUserName isn't being used, so we're good to go." -ForegroundColor Green
        Write-Host "`n"
        CreationStep2
    }
    Else {
        UsernameAttempt3
    }
}
function CreationStep2 {
    Write-Host "Work phone number for $NewFirstName (or leave blank for none): " -ForegroundColor White -NoNewline
    $InputWorkPhone = Read-Host
    If ($InputWorkPhone -eq $null){
        CreationStep3
    }
    Else {
        WorkPhoneFormatAndVerify
    }
}
function WorkPhoneFormatAndVerify {
    $NewWorkPhoneAreaCode = $InputWorkPhone.Substring(0,3)
    $NewWorkPhoneExchange = $InputWorkPhone.Substring(4,3)
    $NewWorkPhoneExt = $InputWorkPhone.Substring(8,4)
    Write-Host $NewWorkPhoneAreaCode" "$NewWorkPhoneExchange" "$NewWorkPhoneExt
    $NewWorkPhone = "+1 (" + $NewWorkPhoneAreaCode + ") " + $NewWorkPhoneExchange + "-" + $NewWorkPhoneExt
    Write-Host "Complete phone number is "$NewWorkPhone
    $TestWorkPhone = Get-ADUser -LDAPFilter "(telephoneNumber=$NewWorkPhone)"
    If ($TestWorkPhone -eq $null) {
        CreationStep3
    }
    Else {
        Write-Host "The phone number you specified is already present in AD. Please use a different number" -ForegroundColor Red
        Write-Host "`n"
        CreationStep2
    }
}
function CreationStep3 {
    Write-Host "We're at Step 3 now!"
}
