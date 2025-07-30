---
tags: powershell, windows
---
Для удаленного управления компьютером с помощью PowerShell можно использовать несколько методов, включая PowerShell Remoting и Remote Desktop Protocol (RDP). Мы сосредоточимся на PowerShell Remoting, так как это более гибкий и мощный способ управления удаленными системами.

### Включение PowerShell Remoting на удаленном компьютере

Перед тем как приступить к удаленному управлению, необходимо включить PowerShell Remoting на удаленном компьютере. На удаленном компьютере (IP: 192.53.244.128) выполните следующие шаги:

1. **Откройте PowerShell с правами администратора**.
2. Выполните команду:

   ```powershell
   Enable-PSRemoting -Force
   ```

Эта команда включит PowerShell Remoting и настроит необходимые правила брандмауэра.

### Настройка доверенных хостов

Если компьютер, с которого вы подключаетесь (IP: 10.38.40.75), и удаленный компьютер (IP: 192.53.244.128) не находятся в одном домене, вам может понадобиться добавить удаленный компьютер в список доверенных хостов:

```powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.53.244.128"
```

### Использование PowerShell для удаленного управления

1. **Запустите PowerShell на компьютере, с которого будет выполняться подключение (IP: 10.38.40.75)**.
2. Создайте объект учетных данных:

   ```powershell
   $password = ConvertTo-SecureString "Password_123" -AsPlainText -Force
   $credential = New-Object System.Management.Automation.PSCredential ("ksb1", $password)
   ```

3. Установите удаленную сессию:

   ```powershell
   Enter-PSSession -ComputerName 192.53.244.128 -Credential $credential
   ```

После выполнения этой команды вы войдете в интерактивную сессию с удаленным компьютером и сможете выполнять команды на нем, как если бы вы работали локально.

### Выполнение одиночной команды на удаленном компьютере

Если вам нужно выполнить одну команду и не оставаться в интерактивной сессии, используйте `Invoke-Command`:

```powershell
Invoke-Command -ComputerName 192.53.244.128 -Credential $credential -ScriptBlock { <ваша команда> }
```

Например, чтобы получить список процессов на удаленном компьютере:

```powershell
Invoke-Command -ComputerName 192.53.244.128 -Credential $credential -ScriptBlock { Get-Process }
```

### Подключение с помощью RDP

Если вам необходимо использовать RDP для подключения к удаленному компьютеру, вы можете сделать это с помощью mstsc (Microsoft Terminal Services Client):

1. Откройте командную строку или PowerShell.
2. Введите команду:

   ```powershell
   mstsc /v:192.53.244.128
   ```

Эта команда откроет окно RDP, где вы сможете ввести учетные данные (пользователь: `ksb1`, пароль: `Password_123`).

Скрипт в одно действие

	# Проверка, запущен ли скрипт с правами администратора
	if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
	    # Перезапуск скрипта с правами администратора
	    Start-Process powershell -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`"") -Verb RunAs
	    exit
	}
	
	# Установка политики выполнения для текущего процесса
	Set-ExecutionPolicy RemoteSigned -Scope Process -Force
	
	# Создание объекта учетных данных
	$password = ConvertTo-SecureString "Password_123" -AsPlainText -Force
	$credential = New-Object System.Management.Automation.PSCredential ("ksb1", $password)
	
	# Установка удаленной сессии
	Enter-PSSession -ComputerName 192.53.244.128 -Credential $credential
