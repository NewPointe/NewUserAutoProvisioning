function main
{

    #Set variables that we'll need to pass between functions.
    New-Variable -Name NewFirstName
    New-Variable -Name NewLastName
    New-Variable -Name NewDisplayName
    New-Variable -Name NewUserName
    New-Variable -Name NewMI
    New-Variable -Name NewWorkPhone
    New-Variable -Name NewMobilePhone
    New-Variable -Name NewEmailAddress1
    New-Variable -Name NewEmailAddress2

    #First off, let's get some credentials stored so we can run this stuff.
    #   $scriptcred = Get-Credential

    #Import the Active Directory module and then start running functions.
    Import-Module ActiveDirectory
    GetUserName ([ref]$NewFirstName) ([ref]$NewLastName) ([ref]$NewMI) ([ref]$NewDisplayName) ([ref]$NewUserName)
    GetWorkPhone ([ref]$NewFirstName) ([ref]$NewWorkPhone)
    GetMobilePhone ([ref]$NewFirstName) ([ref]$NewMobilePhone)
    MakeEmailAddresses ([ref]$NewFirstName) ([ref]$NewLastName) ([ref]$NewUserName) ([ref]$NewEmailAddress1) ([ref]$NewEmailAddress2)

    Write-Host "`n"
    Write-Host "Here are the results!"
    Write-Host "------------------------"
    Write-Host "User Name: $NewUserName"
    Write-Host "First Name: $NewFirstName"
    Write-Host "Middle Initial: $NewMI"
    Write-Host "Last Name: $NewLastName"
    Write-Host "Display Name: $NewDisplayName"
    Write-Host "Work Phone: $NewWorkPhone"
    Write-Host "Mobile Phone: $NewMobilePhone"
    Write-Host "Primary Email Address: $NewEmailAddress1"
    Write-Host "Secondary Email Address: $NewEmailAddress2"

}

function GetUserName( [ref]$NewFirstName, [ref]$NewLastName, [ref]$NewMI, [ref]$NewDisplayName, [ref]$NewUserName )
{
    Write-Host "First name: " -ForegroundColor White -NoNewline
    $NewFirstName.Value = Read-Host
    Write-Host "Last name: " -ForegroundColor White -NoNewline
    $NewLastName.Value = Read-Host
    Write-Host "`n"
    $NewDisplayName.Value = $NewFirstName.Value + ' ' + $NewLastName.Value
    $FormedUserName = $NewFirstName.Value.Substring(0,1) + $NewLastName.Value
    $NewUserName.Value = $FormedUserName.ToLower()
    $UserNameCompare = $NewUserName.Value
    Write-Host "Checking to see if $UserNameCompare already exists..." -ForegroundColor Yellow
    $TestUserName = Get-ADUser -LDAPFilter "(sAMAccountName=$UserNameCompare)"
    Sleep -Seconds 1
    If ($TestUserName -eq $null) {
        Write-Host "User name $UserNameCompare is unique. Good to go!." -ForegroundColor Green
        Sleep -Seconds 1
        Write-Host "`n"
    }
    Else {
        Write-Host "Username $UserNameCompare already exists, so let's add the user's middle initial to the username to make it unique." -ForegroundColor Red
        Sleep -Seconds 1
        Write-Host "What is their middle initial? " -NoNewline
        $NewMI.Value = Read-Host
        $NewMI.Value = $NewMI.Value.ToUpper()
        $NewDisplayName.Value = $NewFirstName.Value + " " + $NewMI.Value + " " + $NewLastName.Value
        $NewUserName.Value = $NewFirstName.Value.Substring(0,1) + $NewMI.Value + $NewLastName.Value
        $NewUserName.Value = $NewUserName.Value.ToLower()
        $UserNameCompare = $NewUserName.Value
        Write-Host "`n"
        Write-Host "OK, let's try $UserNameCompare and see if it's taken..."
        Write-Host "`n"
        Sleep -Seconds 1
        $TestUserName = Get-ADUser -LDAPFilter "(sAMAccountName=$UserNameCompare)"
        If ($TestUserName -eq $null) {
            Write-Host "User name $UserNameCompare is unique. Good to go!" -ForegroundColor Green
            Sleep -Seconds 1
            Write-Host "`n"
        }
        Else {
            $UsernameVerified = $false
            Do {
                Write-Host "Username $UserNameCompare already exists, so you'll need to enter a custom user name here." -ForegroundColor Red
                Write-Host "Enter a custom user name: " -NoNewline
                $CustomUserName = Read-Host
                $NewUserName = $CustomUserName
                Write-Host "`n"
                Write-Host "OK, let's try $NewUserName and see if it's taken..."
                Sleep -Seconds 1
                $TestUserName = Get-ADUser -LDAPFilter "(sAMAccountName=$NewUserName)"
                If ($TestUserName -eq $null) {
                    Write-Host "User name $UserNameCompare is unique. Good to go!" -ForegroundColor Green
                    $UsernameVerified = $true
                    Sleep -Seconds 1
                    Write-Host "`n"
                }
                Else {
                }
            }
            While ($UsernameVerified -eq $false)
        }
    }
}

function GetWorkPhone( [ref]$NewFirstName, [ref]$NewWorkPhone )
{
    $UserName = $NewFirstName.Value
    $WorkPhoneVerified = $false
    Do {
        Write-Host "Work phone number for $UserName -- Format should be XXX-XXX-XXXX (or leave blank for none): " -ForegroundColor White -NoNewline
        $InputWorkPhone = Read-Host
        If ($InputWorkPhone -ne [string]::Empty){
            $NewWorkPhoneAreaCode = $InputWorkPhone.Substring(0,3)
            $NewWorkPhoneExchange = $InputWorkPhone.Substring(4,3)
            $NewWorkPhoneExt = $InputWorkPhone.Substring(8,4)
            $NewWorkPhone.Value = "+1 (" + $NewWorkPhoneAreaCode + ") " + $NewWorkPhoneExchange + "-" + $NewWorkPhoneExt
            $WorkPhoneCompare = $NewWorkPhone.Value
            Write-Host  "Checking to see if $WorkPhoneCompare already exists..."
            $TestWorkPhone = Get-ADUser -Filter {(OfficePhone -eq $WorkPhoneCompare)}
            Sleep -Seconds 1
            If ($TestWorkPhone -eq $null) {
                $WorkPhoneVerified = $true
                Write-Host "$WorkPhoneCompare is unique. Good to go!" -ForegroundColor Green
            }
            Else {
                Write-Host "The phone number $WorkPhoneCompare is already present in AD. Please use a different number." -ForegroundColor Red
            }
        }
        Else{
            $NewWorkPhone = $null
            $WorkPhoneVerified = $true    
        }
    }
    While ($WorkPhoneVerified -eq $false)
}

function GetMobilePhone( [ref]$NewFirstName, [ref]$NewMobilePhone )
{
    $UserName = $NewFirstName.Value
    $MobilePhoneVerified = $false
    Do {
        Write-Host "Mobile phone number for $UserName -- Format should be XXX-XXX-XXXX (or leave blank for none): " -ForegroundColor White -NoNewline
        $InputMobilePhone = Read-Host
        If ($InputMobilePhone -ne [string]::Empty){
            Sleep -Seconds 1
            $NewMobilePhoneAreaCode = $InputMobilePhone.Substring(0,3)
            $NewMobilePhoneExchange = $InputMobilePhone.Substring(4,3)
            $NewMobilePhoneExt = $InputMobilePhone.Substring(8,4)
            $NewMobilePhone.Value = "+1 (" + $NewMobilePhoneAreaCode + ") " + $NewMobilePhoneExchange + "-" + $NewMobilePhoneExt
            $MobilePhoneCompare = $NewMobilePhone.Value
            Write-Host  "Checking to see if $MobilePhoneCompare already exists..."
            $TestMobilePhone = Get-ADUser -Filter {(MobilePhone -eq $MobilePhoneCompare)}
            Sleep -Seconds 1
            If ($TestMobilePhone -eq $null) {
                $MobilePhoneVerified = $true
                Write-Host "$MobilePhoneCompare is unique. Good to go!" -ForegroundColor Green
            }
            Else {
                Write-Host "The phone number $MobilePhoneCompare is already present in AD. Please use a different number." -ForegroundColor Red
            }
        }
        Else{
            $NewMobilePhone = $null
            $MobilePhoneVerified = $true
        }
    }
    While ($MobilePhoneVerified -eq $false)
}

function MakeEmailAddresses( [ref]$NewFirstName, [ref]$NewLastName, [ref]$NewUserName, [ref]$NewEmailAddress1, [ref]$NewEmailAddress2 )
{
    $UserName = $NewFirstName.Value
    Do {
        Write-Host "
        --- Please select an email domain for $UserName ---
        1. newpointe.org
        2. None (no email for this user)
        "
        $choice1 = Read-Host -Prompt "Make a selection and press Enter"
    }
    Until ($choice1 -eq "1" -or $choice1 -eq "2")

    Switch ($choice1) {
        "1" {
            #Generate the user's "first-initial-last-name" address.
            $NewEmailDefault = $NewUserName.Value.ToLower()
            $NewEmailAddress1.Value = $NewEmailDefault + "@newpointe.org"
            #Generate the user's "firstname.lastname" address.
            $NewEmailFirst = $NewFirstName.Value.ToLower()
            $NewEmailLast = $NewLastName.Value.ToLower()
            $NewEmailAddress2.Value = $NewEmailFirst + "." + $NewEmailLast + "@newpointe.org"
            Write-Host "$UserName's email addresses will be as follows:"
            Write-Host "Email address 1: "$NewEmailAddress1.Value
            Write-Host "Email Address 2: "$NewEmailAddress2.Value
            Write-Host "`n"
        }
        "2" {$NewEmailAddress.Value = $null
            Write-Host "OK, no email address for $UserName then.`n"}
        }
        Sleep -Seconds 1   
    }

    main
