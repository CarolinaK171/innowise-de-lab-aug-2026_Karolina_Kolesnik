#Задание 1
SMALL_BATCH_LIMIT = 500

def calculate_batch(weight, price, discount = 0.0):
    """ 
	Рассчитывает стоимость партии товара с учетом скидки (при ее наличии) и проверяе превышение установленного лимита стоимости (переменая SMALL_BATCH_LIMIT)
	:param weight: Вес партии
	:param price: Цена за единицу веса
    :param discount: Скидка, необязательный параметр (по умолчанию равен 0.0)
    :return: Кортеж (Соимость партии товара, Индикатор превышенич лимита стоимости)
	""" 
    final_sum = weight * price * (1 - discount)
    is_limit_exceeded = False
    if final_sum > SMALL_BATCH_LIMIT:
        is_limit_exceeded = True
    return final_sum, is_limit_exceeded

#Входящие данные: Продажа партии моркови (100 кг по 4$ за кг., без скидки)
carrots_total_sum, carrots_limit = calculate_batch(100, 4)

#Вызов функции calculate_batch для условий: Продажа партии яблок (50 кг по 20$ за кг., скидка 10%)
apples_total_sum, apples_limit = calculate_batch(50, 20, 0.1)

print(f'Партия 1 (Морковь): Сумма {carrots_total_sum}. Превышение лимита: {carrots_limit}')
print(f'Партия 1 (Яблоки): Сумма {apples_total_sum}. Превышение лимита: {apples_limit}')


#Задание 2
branches = [
    {"city": "Minsk", "revenue": 15000},
    {"city": "Warsaw", "revenue": 32000},
    {"city": "London", "revenue": 12000}
]

def audit_logger(func):
    def wrapper(*args, **kwargs):
        print('[AUDIT] Запуск анализа....')
        result = func(*args, **kwargs)
        print('[AUDIT] Анализ завершен.')
        return result
    return wrapper

@audit_logger
def get_sorted_report(branches_list):
    branches_list_sorted = sorted(branches_list, key = lambda item: item['revenue'], reverse = True)
    return branches_list_sorted

branches_sorted = get_sorted_report(branches)

for item in branches_sorted:
    if branches_sorted.index(item) == 0:
        print('Топ филиалов:')
    print(f'{branches_sorted.index(item) + 1}. {item['city']}: {item['revenue']}')