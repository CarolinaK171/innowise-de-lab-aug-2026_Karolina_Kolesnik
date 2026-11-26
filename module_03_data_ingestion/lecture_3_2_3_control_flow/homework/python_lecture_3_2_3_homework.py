#Задание 1
raw_log = "ORDER-2025-01-15|FRT-APPLE-PL|+111 (23) 456-78-90| мИНсК "

#1.1 Разделение строки
log_list = raw_log.split("|")
order_id, product_code, raw_phone, raw_city = log_list

#1.2 Разбор кода товара
category = product_code[:3]
region = product_code[-2:]
print(f'Позиция первого дефиса в коде товара: {product_code.find('-')}')

if product_code.startswith('FRT'):
    print("Код товара начинается с 'FRT'")
else:
    print("Код товара не начинается с 'FRT'")

#1.3 Приведение номера телефона к необходимому формату
clean_phone = str()
for char in raw_phone:
    if char.isdigit():
        clean_phone += char
print(f'Отформатированный номер телефона: {clean_phone}\nДлина номера телефона  : {len(clean_phone)} символов')

#1.4 Приведение названия города к верному формату
clean_city = raw_city.strip().lower().title()

#1.5 Итоговый отчет
report = f'Заказ: {order_id}\nКатегория: {category} | Регион: {region}\nТелефон: {clean_phone}\nГород: {clean_city}'
print(report)


#Задание 2
product = " фермерский ТВОРОГ " 
price = 4.567 
qty = 3 
csv_row = "milk,bread,cheese" 
review = "Это лучший ТВОРОГ в городе!" 
file_path = r"C:\EcoMarket\data\2025\january\sales.csv"

#2.1 Нормализация названия товара
clean_product = product.strip().lower().title()
print(clean_product)

#2.2 Формирование чека для клиента
total = price * qty
cheque = f'Чек "EcoMarket"\nТовар:\t{clean_product}\nКол-во:\t{qty}\nИтого:\t{total:.2f} руб.'
print(cheque)

#2.3 Подготовка строки из CSV
csv_row_split = csv_row.split(",")
csv_row_joined = " | ".join(csv_row_split)
print(csv_row_joined)

#2.4 Проверка отзыва клиента
if "творог" in review.lower():
    print('Отзыв относится к категории: Dairy')

#2.5 Работа с путём к файлу
print(r"C:\EcoMarket\data\2025\january\sales.csv") #r-строка позволяет использовать специальные символы (обратный слеш в данном случае) как часть текста, т.е. специальные символы в r-строках не интерпретируются