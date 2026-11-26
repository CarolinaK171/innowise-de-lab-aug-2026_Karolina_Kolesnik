#Задание 1
def calculate_purchase(product_name, weight, price):
    """ 
    Выводит итоговую стоимость партии товара, фиксирует и выводит сообщение об ошибках ввода данных классов ValueError, TypeError и ZeroDivisionError
    :param weight: Вес партии
    :param price: Цена за единицу веса
    :return: Стоимость партии товара
    """ 
    try:
        numeric_weight = float(weight)
        total_cost = numeric_weight * price
        technical_index = 100 / numeric_weight
        print(f'Товар: {product_name}. Итоговая стоимость: {total_cost}$')

    except TypeError as e:
        print(f'Тип ошибки: {type(e)}\nСообщение: {e}')

    except ValueError as e:
            print(f'Тип ошибки: {type(e)}\nСообщение: {e}')

    except ZeroDivisionError as e:
            print(f'Тип ошибки: {type(e)}\nСообщение: {e}')

    finally:
          print('--- Проверка партии завершена ---')

#Входные данные: Томаты: 100 кг., 2,5$ за кг. — корректный случай.
tomatoes_total_cost = calculate_purchase('Томаты', 100, 2.5)

#Входные данные: Огурцы: "пятьдесят" кг., 1,8$ за кг. — ошибка значения веса.
cucumbers_total_cost = calculate_purchase('Огурцы', 'пятьдесят', 1.8)

#Входные данные: Перец: 0 кг., 4$ за кг. — ошибка деления на 0.
pepper_total_cost = calculate_purchase('Перец', 0, 4)

#Входные данные: Зелень: [10] (список), 5$ за кг. — ошибка типа данных.
greenery_total_cost = calculate_purchase('Зелень', [10], 5)

 
#Задание 2
from typing import Union, Optional

def calculate_total_delivery_cost (product_name: str, weights: Union[list[float],tuple[float]], prices: list[float] | tuple[float], discount: Optional[float] = None, currency_rate: int | float = 1, *extra_costs: float) -> dict[str, float]:
    """ 
    Выводит итоговую стоимость партии товара с учетом базовых цен, скидки и дополнительных расходов
    :param product_name: название товара
    :param weights: коллекция с весами партий (может быть как список, так и кортеж)
    :param prices: коллекция с ценами за кг. (может быть как список, так и кортеж)
    :param discount: скидка, которой по умолчанию нет, но может быть передана в функцию
    :param currency_rate: коэффициент пересчета валюты, который может быть как целым числом, так и дробным. По умолчанию всегда равен 1
    :param *extra_costs: дополнительные расходы (например, доставка, упаковка, хранение).
    """ 
    if len(weights) != len(prices):
        return print(f'ОШИБКА!: Количество значений веса не равно количеству цен')
    
    total_sum: int = 0
    for i in range(len(weights)):
        total_sum += weights[i] * prices[i]
    if discount is not None:
        discount_sum: float = total_sum * (1 - discount)
    else:
        discount_sum = total_sum
    extra_sum: float = discount_sum + sum(extra_costs)
    final_sum: float = extra_sum * currency_rate
    return {product_name: final_sum}

#Входные данные:
#1. Для овощей:
#Название: "Овощная партия"
#Веса: [100, 50]
#Цены: [4, 6]
#Скидка: 0.1
#Курс: 1
#Дополнительные расходы: 20, 15

vegetables_total_delivery_cost = calculate_total_delivery_cost('Овощная партия', [100, 50], [4, 6], 0.1, 1, 20, 15)

for key, value in vegetables_total_delivery_cost.items():
    print(f'Товар: {key}, итоговая стоимость: {value}')

#2. Для фруктов:
#Название: "Фруктовая партия"
# Веса: (30, 20, 10)
# Цены: (15, 12, 18)
# Скидка: None
# Курс: 1.2
# Дополнительные расходы: 25

fruits_total_delivery_cost = calculate_total_delivery_cost('Фруктовая партия', (30, 20, 10), (15, 12, 18), None, 1.2, 25)

for key, value in fruits_total_delivery_cost.items():
    print(f'Товар: {key}, итоговая стоимость: {value}')
