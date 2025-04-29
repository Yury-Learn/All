# Инструкция, как восстановить флешку, если не видно полный объем.
Запустить CMD с правами администратор
Diskpart.exe
List disk
Select disk N
Clean
Create partition primary
Format fs=fat32 quick (вместо fat32, ntfs, exFAT) если убрать quick будет просто форматирование (долго)
exit
Format fs=ntfs quick