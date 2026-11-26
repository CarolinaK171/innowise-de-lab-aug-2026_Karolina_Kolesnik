# Часть 1. ПОДГОТОВКА скрипта: ETL для группы csv файлов в заданной директории

import pandas as pd
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.exc import ArgumentError, OperationalError
from pathlib import Path

'''Функция db_ecomarket_etl
Задача: реализация базового ETL-процесса обработки raw-данных Ecomarket в формате CSV файлов
Этапы: подготовка подключения к БД, загрузки CSV-файла в датафрейм и его загрузка в виде таблицы в схему bronze БД
Результат: подключение к БД устанвлено, схема bronze в БД создана, CSV-файл загружен в виде таблицы в схему bronze БД
Обработка ошибок: функция предусматривает обработку основных типов ошибок на этапах подключения к БД, извлечения CSV-файлов и их загрузки в БД
'''

def db_ecomarket_etl (csv_filepath: str, schema_name: str):

    #Этап 1. Подключение к базе данных и создание схемы
    try:
        load_dotenv()
        db_url = os.environ['DATABASE_URL']
        engine = create_engine(db_url, echo=False)
        print('--- Соединение с базой данных установлено! ---')
        
        with engine.begin() as conn:
            conn.execute(text(f'CREATE SCHEMA IF NOT EXISTS {schema_name}'))
        print(f'--- Схема {schema_name} в базе данных создана! ---')

    except KeyError:
        print('Ошибка: Переменная окружения DATABASE_URL не найдена.')
    except ArgumentError:
        print('Ошибка: Некорректный формат DATABASE_URL.')
    except OperationalError:
        print('Ошибка: Ошибка подключения к базе данных')
    except Exception as e:
        print(f'Произошла непредвиденная ошибка: {e}')

    # Этап 2. Чтение csv-файла и подсчет количества строк в датафрейме
    try:
        file_name = Path(csv_filepath).stem
        print(f'1. Чтение данных из файла CSV {file_name}...')

        df = pd.read_csv(csv_filepath, sep=';', header='infer', names=None)
        print(f'2. Чтение файла CSV {file_name} успешно завершено. Количество строк: {len(df)}')

    # Этап 3. Загрузка данных в схему базы данных
        print(f'3. Загрузка файла CSV {file_name} в базу данных...')
        db_table_name = schema_name + '_' + file_name
        df.to_sql(
            name=db_table_name,
            con=engine,
            schema=schema_name,
            if_exists='append',
            index=False,
            chunksize=10000
        )
        print(f'--- Загрузка файла CSV {file_name} в базу данных успешна завершена! ---')

    except FileNotFoundError:
         print(f'Ошибка: файл CSV {file_name} не найден.')
    except FileNotFoundError:
        print(f'Ошибка: структура файла CSV {file_name} не соответстствует структуре таблицы базы данных.')
    except Exception as e:
        print(f'Произошла непредвиденная ошибка: {e}')


# ЧАСТЬ 2. ВЫПОЛНЕНИЕ скрипта: ETL для группы csv файлов в заданной директории

# 1.Формируем список имен csv-файлов, за исключением файла sales.csv, для последующей пакетной загрузки в БД. Файл sales.csv, как наиболее объемный, будет загружен отдельно

path = Path('.') # Формирование пути к директории, в данном случае - той же папке, где лежит скрипт python
file_list = [f for f in path.glob('*.csv') if f.name != 'sales.csv']

# 2. Запускаем цикл для пакетного ETL группы csv файлов, за исключением файла sales.csv
p = 0 # Задаем начальное значение счетчика для подсчета итогового количества загруженных в БД файлов
for i in file_list:
    db_ecomarket_etl(i, 'bronze')
    p = p + 1
print(f'--- ETL-процесс в БД завершен!.\nИТОГО загружено файлов: {p}. ---')


# 3. Отдельно выполняем ETL для файла sales.csv
db_ecomarket_etl('sales.csv', 'bronze')
print(f'ETL-процесс файла sales.csv завершен!.')