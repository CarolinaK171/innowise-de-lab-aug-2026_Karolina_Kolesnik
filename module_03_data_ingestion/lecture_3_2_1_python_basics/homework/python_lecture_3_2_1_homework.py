#Task 1
category_a = "Vegetables"
category_b = "Fruits"
price_per_unit_a = 150
quantity_a = 40
vat_rate = 0.2

category_a, category_b = category_b, category_a

total_value = (price_per_unit_a * quantity_a) + (price_per_unit_a * quantity_a * vat_rate)
print(f'Текущая категория A: {category_a}\nОбщая стоимость партии с НДС: {total_value}')

#Task2
'''
Модуль: Расчет длины стороны квадратной зоны хранения на основаннии вводимого идентификатора зоны
Автор: Karolina Kolesnik
Версия: 1.1 (Обновлено: Сентябрь 2026)
'''

# Импорт библиотеки math
import math

# Задаем значение переменной площади (area_total) для зоны хранения типа "Cold-Storage-01"
area_total = 225

# Запрашиваем у пользоваиеля ввод идентификатора зоны
area_type = input('Введите идентификатор зоны в формате "Zone-A1" ')

# Рассчитываем длину стороны
side_length = math.sqrt(area_total)

# Выводим на экран идентификатор зонуы и рассчитанную длину стороны
print(f'Идентификатор зоны: {area_type}\nДлина стороны зоны: {side_length}')
