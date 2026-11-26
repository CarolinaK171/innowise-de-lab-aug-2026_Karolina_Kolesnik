#Task 1
products = ["Яблоки", "Хлеб", "Молоко", "Печенье", "Сок", "Кефир"]

for i in range(0,len(products),2):
        if products[i] == 'Бананы':
            print(f'Индекс {i}: Найден товар {products[i]} (Длина названия: {len(products[i])}. Проверка завершена!')
            break
        print(f'Индекс {i}: Проверен товар {products[i]} (Длина названия: {len(products[i])} символов)')
else:
    print('--- Выборочная проверка успешно завершена ---\n\n')


#Task 2
daily_logs = [
    [500, 0, 1200],       # Касса 1 (Нормальная)
    [300, -999, 800],     # Касса 2 (Сломалась посередине, 800 не должно посчитаться)
    [1500, 200]           # Касса 3 (Нормальная)
]

total_revenue = 0
for i, item in enumerate(daily_logs, start=1):
    print(f'--- Обработка Кассы №{i} ---')
    for amount in item:
        if amount == -999:
            print('Аварийная остановка кассы!')
            break
        elif amount == 0:
            print('Пропуск сбоя (0)')
            continue
        total_revenue += amount
        print(f'Добавлено: {amount}')
print(f'=== ИТОГ ДНЯ ===\nОбщая выручка магазина: {total_revenue}')
