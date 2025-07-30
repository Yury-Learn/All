#wsus #windows
Вы можете настроить целевую версию с через групповые политики или через реестр.

1. Откройте редактор [локальной групповой политики (gpedit.msc)](https://winitpro.ru/index.php/2015/10/02/redaktor-gruppovyx-politik-dlya-windows-10-home-edition/);
2. Перейдите в раздел **Computer Configuration -> Administrative Templates -> Windows Components -> Windows Update -> Windows Update for Business** (Конфигурация компьютера **->** Административные шаблоны **->** Компоненты Windows **->** Центр обновления Windows **->** Центр обновления Windows для бизнеса);
3. Включите параметр **Select the target Feature Update version** (этот параметр GPO доступен в Windows 10 2004 и выше). В дополнительных опциях параметра нужно указать версию Windows и номер билда, на котором вы хотите остаться;
4. Укажите `Windows 10` в поле **Which Windows product version would you like to receive feature updates for** (**Выбор версии для обновления целевого компонента**);
5. Укажите целевой билд Windows 10 на вашем компьютере в поле **Target Version for Feature Updates**. Например, `21H2` ;