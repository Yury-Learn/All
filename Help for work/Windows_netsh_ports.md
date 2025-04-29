# Пробросы порталов через компьютер.
  # показать список в 
    netsh interface portproxy show all



# cредствами винды

  # добавить
    netsh interface portproxy add v4tov4 listenaddress=мойадрес listenport=мойпорт connectaddress=доступныймнеадрес connectport=доступныймнепорт

  # удалить
    netsh interface portproxy delete v4tov4 listenaddress=мойадрес listenport=мойпорт

  # посмотреть
    netsh interface portproxy show all


  # средствами ssh
    plink.exe -ssh -A -L мойип:мойпорт:доступныйсерверуип:доступныйсерверупорт ипсервера -P портсервера -l логиннасервер
    klink.exe аналогично
  # или профилем
    plink.exe -v -ssh -A -L 127.0.0.1:8025:127.0.0.1:8025 kamchatka_mincr


  # Проверка портов
    netstat -anob   *показывает текущие порты*
    netstat -anob | find "80"   *отбор по 80 порту*