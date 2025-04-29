
# Чтобы удалить старые неактивные компьютеры из домена, вы можете использовать следующий скрипт PowerShell: 
powershell
*
Import-Module ActiveDirectory

$daysInactive = 90
$inactiveDate = (Get-Date).AddDays(-$daysInactive)

$computers = Get-ADComputer -Filter {Enabled -eq $true} -Properties LastLogonDate |
    Where-Object {$_.LastLogonDate -lt $inactiveDate}
foreach ($computer in $computers) {
    Remove-ADComputer -Identity $computer -Confirm:$false
}
*
В этом скрипте мы сначала импортируем модуль Active Directory. Затем мы указываем количество дней бездействия (`$daysInactive`), прежде чем считать компьютер старым и неактивным. Мы вычисляем дату, которая равна `$ daysInactive` несколько дней назад, и сохраняем ее в `$ inactiveDate`.
Далее мы используем командлет `Get-ADComputer` для получения списка включенных компьютеров с их свойством `LastLogonDate`. Мы фильтруем список, чтобы включать только компьютеры с `LastLogonDate`, более старым, чем `$ inactiveDate`.
Наконец, мы перебираем список неактивных компьютеров и используем командлет `Remove-ADComputer` для удаления каждого компьютера из домена с параметром `-Confirm:$false` для подавления запроса на подтверждение.
Пожалуйста, обратите внимание, что удаление компьютеров из домена является конфиденциальной операцией, поэтому обязательно тщательно протестируйте скрипт в непроизводственной среде, прежде чем запускать его в рабочей среде.
*

# Import-Module ActiveDirectory

$daysInactive = 45
$inactiveDate = (Get-Date).AddDays(-$daysInactive)

$computers = Get-ADComputer -Filter {Enabled -eq $true} -Properties LastLogonDate |
    Where-Object {$_.LastLogonDate -lt $inactiveDate}
foreach ($computer in $computers) {
    Remove-ADComputer -Identity $computer -Confirm:$false
}
*

Нижний вариант рабочий


> Посмотреть список 
dsquery computer -inactive 10 (10 недель)