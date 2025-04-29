### PortDift block

def SendTelegram(text):
    token = '6010899305:AAEyXQg19ZGlicmI-p5VaqTBIweMg8ovIuc'
    chat_id = '-1002006350032' 
    message_thread_id = '2054'
    url = f"https://api.telegram.org/bot{token}/sendMessage?&chat_id={chat_id}&message_thread_id={message_thread_id}&text={text}&parse_mode=Markdown"
    #url = f"https://api.telegram.org/bot{token}/sendMessage?&chat_id={chat_id}&text={text}&parse_mode=Markdown"
    requests.get(url)



    chat_id = параметр группы
    message_thread_id = параметр подгруппы


  ПКМ на сообщение в группе >>> копировать ссылку
  Получаем: https://t.me/c/2006350032/2054/2060

  Добавляем (-100)
  -1002006350032 - chat_ID
  2054           - message_thread_id
