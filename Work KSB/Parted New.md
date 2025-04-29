### parted: Warning: The resulting partition is not properly aligned for best performance.

Эта ошибка, уверен, достает каждого! Даже в самом простом случае, когда нужен 1 раздел на весь диск - почти невозможно подобрать значения под конкретный диск, которые бы устроили parted.  
  
Идеальный вариант такой.  
  
Сначала создаем таблицу gpt на диске (все данные будут уничтожены):  

> parted /dev/sda  
> mklabel gpt

  
После этого создаем один раздел на весь диск:  

> parted /dev/sda  
> unit s  
> mkpart main ext4 0% 100%

```sh
mkfs.ext4 /dev/sdXY
```

Проверяем, что parted правда удовлетворен выравниванием вновь созданного раздела:  

> parted /dev/sda align-check optimal 1

Ответ должен быть "aligned".