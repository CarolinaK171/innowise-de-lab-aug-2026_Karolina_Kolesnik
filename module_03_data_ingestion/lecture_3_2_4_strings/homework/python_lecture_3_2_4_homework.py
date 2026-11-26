#Задание 1
#1.1. Инициализировать данные
rows_range = range(1,6)
rows = list(rows_range)

#1.2. Выполнить изменение по индексу
rows[2] = 'Ремонт'

#1.3. Проверить наличие значения
if 5 in rows:
    print('Ряд 5 доступен')

#1.4 Выполнить срез
priority_rows = rows[0:3]

#1.5. Вывести в консоль
print(f'Список рядов: {rows}\nПриоритетные ряды: {priority_rows}')


#Задание 2

#2.1. Инициализировать список prices со следующими значениями в коде:
prices = [100, -50, 300, 40, 800]

#2.2. Очистить данные
prices.remove(-50)

#2.3. Изменить список
prices.append(150)

#2.4 Отсортировать список
prices.sort()

#2.5 Создать новый список через List Comprehension
tax_prices = [price*1.2 for price in prices if price*1.2 > 100.0]

#2.6. Вывести в консоль   

print(f'Базовый прайс (очищенный): {prices}\nЦены с НДС (>100): {tax_prices}\nОбщая выручка: {sum(tax_prices)}\nМинимум: {min(tax_prices)}\nМаксимум: {max(tax_prices)}')
