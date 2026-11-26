# %%
# ЧАСТЬ 1. ПОДГОТОВКА скрипта: создаем функцию для подключения к БД и загрузки в датафреймы таблиц и бронзового слоя БД
import pandas as pd
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.exc import ArgumentError, OperationalError, ProgrammingError, DataError


def db_ecomarket_etl_for_silver_layer (table_name: str, schema_name: str):

    #Этап 1. Подключение к базе данных и обработка возможных ошибок подключения
    try:
        load_dotenv()
        db_url = os.environ['DATABASE_URL']
        engine = create_engine(db_url, echo=False)
        print('--- Соединение с базой данных установлено! ---')

    except KeyError:
            print('Ошибка: Переменная окружения DATABASE_URL не найдена.')
    except ArgumentError:
            print('Ошибка: Некорректный формат DATABASE_URL.')
    except OperationalError:
            print('Ошибка: Ошибка подключения к базе данных')
    except Exception as e:
            print(f'Произошла непредвиденная ошибка подключения к базе данных: {e}')

    #Этап 2. Поиск в БД таблицы по имени и схеме в БД, ее загрузка в датафмейм c обработкой возможных ошибок поиска и загрузки
    try:
        with engine.begin() as connection:
            df = pd.read_sql_table(table_name, con=connection, schema=schema_name)

    except ProgrammingError:
        print (f'Ошибка: Таблица {table_name} не найдена в БД или к ней нет доступа.')
        df = None
    except ValueError:
        print('Ошибка: Неверно указано имя таблицы или параметры подключения.')
        df = None        
    except MemoryError:
        print(f'Ошибка: Таблица {table_name} слишком велика для оперативной памяти.')
        df = None
    except Exception as e:
        print(f'Произошла непредвиденная ошибка поиска и/или загрузки таблицы {table_name} из базы данных: {e}')
        df = None
    else:
        print(f'--- Таблица {table_name} успешно загружена в DataFrame! ---')
        return df

# ЧАСТЬ 2. ЗАГРУЗКА таблиц из бронзового слоя БД в датафреймы
df_bronze_countries = db_ecomarket_etl_for_silver_layer('bronze_countries', 'bronze')
df_bronze_cities = db_ecomarket_etl_for_silver_layer('bronze_cities', 'bronze')
df_bronze_categories = db_ecomarket_etl_for_silver_layer('bronze_categories', 'bronze')
df_bronze_customers = db_ecomarket_etl_for_silver_layer('bronze_customers', 'bronze')
df_bronze_employees = db_ecomarket_etl_for_silver_layer('bronze_employees', 'bronze')
df_bronze_products = db_ecomarket_etl_for_silver_layer('bronze_products', 'bronze')
df_bronze_shops = db_ecomarket_etl_for_silver_layer('bronze_shops', 'bronze')
df_bronze_sales = db_ecomarket_etl_for_silver_layer('bronze_sales', 'bronze')

#%%
# ЧАСТЬ 3. Восстановление времени в таблице bronze_sales: 
# делаем проверку поля sales_timestamp - удаляем строки без даты продажи, в строках без времени продажи
# подставляем техническое время '00:00:00'.

print(df_bronze_sales['sales_timestamp'].isna().sum()) #Проверяем количество пустых строк в исходной таблице

#Этап 1. Удаляем строки, где не указана дата продажи
df_bronze_sales= df_bronze_sales.dropna(subset=['sales_timestamp'])
print(df_bronze_sales['sales_timestamp'].isna().sum()) #Проверяем, что пустые сроки были удалены 

#Этап 2. Приводим значения столбца с датой и временем продажи 'sales_timestamp' к типу datetime
#с помощью метода pd.to_datetime(). Метод автоматически подставляет время 00:00:00 в строках, где указана
#только дата продажи, если такие строки есть.
df_bronze_sales['sales_timestamp'] = pd.to_datetime(df_bronze_sales['sales_timestamp'], format='mixed', errors='coerce')
print(df_bronze_sales['sales_timestamp'].isna().sum()) #Проверяем, есть ли строки, которые не были распознаны как дата и время (метод to-datetime вернул значение NaT)

df_bronze_sales.info()

# %%
# ЧАСТЬ 4. Валидация дат в таблице bronze_employees:
# функция validate_and_fix_date - разбрирает некорректные форматы (слэши) и проверяет реальность даты,
# невозможные даты (например, 2023-99-99) заменяет на Technical Default -> 1900-01-01.

def validate_and_fix_date (df_date_column_to_fix: pd.Series, start_timerange: int = 50, end_timerange: int = 0) -> pd.Series:

    """
    Функция validate_and_fix_date приводит в столбце датафрейма к общему формату дат 'YY-mm-dd',
    устанавлиает корректный тип данных datetime и проверяет соответствие дат на вхожение в заданный логический диапазон
    :param df_date_column_to_fix: Исходный столбец датафрейма с датами для валидации и корректировки
    :param start_timerange: Параметр задает начальную границу диапазона дат для валидации (по умолчанию 50 - минус 50 лет от текущей даты)
    :param end_timerange: Параметр задает конечную границу диапазона дат для валидации (по умолчанию 0 - текущая дата)
    """
    #Этап 1. Приведение значений в общему формату - ищем в строке символы точки, слеша, обратного слеша и заменяем их на символ дефиса
    df_string = df_date_column_to_fix.astype(str)
    df_form = df_string.str.replace(r'[/.\\]', '-', regex=True)

    #Этап 2. Приведение строк к корректному типу: datetime
    df_date_type = pd.to_datetime(df_form, errors='coerce', format='%Y-%m-%d').dt.floor('D')

    #Этап 3. Поиск и замена на Technical Default -> 1900-01-01 значений, которые выходят за пределы заданного логического диапазона дат
    today = pd.Timestamp.now().normalize()
    start_date = today - pd.DateOffset(years=start_timerange)
    end_date =  today - pd.DateOffset(years=end_timerange)
    technical_default = pd.to_datetime('1900-01-01')

    df_rangecheck = df_date_type.where(df_date_type.between(start_date, end_date), technical_default)
    return df_rangecheck

print(df_bronze_employees.describe())

#Проводим валидацию и корректировку столбца hire_date таблицы bronze_employees с датой найма 
df_bronze_employees['hire_date'] = validate_and_fix_date(df_bronze_employees['hire_date'])

#Проводим валидацию и корректировку столбца birth_date таблицы bronze_employees с датой рождения, меняем логический диапазон дат для валидации (возраст сотрудника на текущую дату не может быть более 70 лет и менее 18 лет)
df_bronze_employees['birth_date'] = validate_and_fix_date(df_bronze_employees['birth_date'], start_timerange=70, end_timerange=18)

print(df_bronze_employees.describe())


# %%
# ЧАСТЬ 5.  ПОДГОТОВКА скрипта: создаем функцию для подключения к БД и загрузки обработанных датафреймов в таблицы схемы silver базы данных

def db_ecomarket_to_silver_layer_upload (dataframe_to_upload: pd.DataFrame, db_table_name: str, db_schema_name: str):

    #Этап 1. Подключение к базе данных и создание схемы
    try:
        load_dotenv()
        db_url = os.environ['DATABASE_URL']
        engine = create_engine(db_url, echo=False)
        print('--- Соединение с базой данных установлено! ---')
        
    except KeyError:
        print('Ошибка: Переменная окружения DATABASE_URL не найдена.')
    except ArgumentError:
        print('Ошибка: Некорректный формат DATABASE_URL.')
    except OperationalError:
        print('Ошибка: Ошибка подключения к базе данных')
    except Exception as e:
        print(f'Произошла непредвиденная ошибка: {e}')

    # Этап 2. Загрузка датафрейма в созданную таблицу silver схемы базы данных
    try: 
        print(f'Загрузка датафрейма в таблицу {db_table_name} базы данных...')
        dataframe_to_upload.to_sql(
            name=db_table_name,
            con=engine,
            schema=db_schema_name,
            if_exists='append',
            index=False,
            chunksize=10000
        )
        print(f'--- Загрузка датафрейма в таблицу {db_table_name} успешна завершена! ---')

    except ProgrammingError:
         print(f'Ошибка: Неверное имя таблицы/схемы или в {dataframe_to_upload} есть лишние колонки, которых нет в БД.')
    except DataError:
        print(f'Ошибка: Значение в {dataframe_to_upload} не совпадает с типом колонки в БД.')
    except Exception as e:
        print(f'Произошла непредвиденная ошибка: {e}')

# ЧАСТЬ 6. ЗАГРУЗКА обработанных датафреймов в таблицы схемы silver базы данных

#db_ecomarket_to_silver_layer_upload(df_bronze_countries, 'silver_countries', 'silver')
#db_ecomarket_to_silver_layer_upload(df_bronze_cities, 'silver_cities', 'silver')
#db_ecomarket_to_silver_layer_upload(df_bronze_categories, 'silver_categories', 'silver')
#db_ecomarket_to_silver_layer_upload(df_bronze_customers, 'silver_customers', 'silver')
#db_ecomarket_to_silver_layer_upload(df_bronze_employees, 'silver_employees', 'silver')
#db_ecomarket_to_silver_layer_upload(df_bronze_products, 'silver_products', 'silver')
#db_ecomarket_to_silver_layer_upload(df_bronze_shops, 'silver_shops', 'silver')
db_ecomarket_to_silver_layer_upload(df_bronze_sales, 'silver_sales', 'silver')