# 3. Ограничения атрибутов таблиц `products` и `sales` датасета `source.zip`

| No | Table Name | Column | Constraint Type | Constraint Type Rationale&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
| :---: | :--- | :--- | :--- | :--- |
| 1 | `products` | `product_id` | `PRIMARY KEY` | Уникальный идентификатор товара. |
| | | `product_name` | `NOT NULL` | Наименование товара обязательно для отображения и учёта. |
| | | `price` | `NOT NULL`<br>`CHECK (price >= 0)` | Базовая цена обязательна и не может быть отрицательной. |
| | | `category_id` | `NOT NULL`<br>`FOREIGN KEY` | Внешний ключ к `categories (category_id)`; каждый товар должен принадлежать существующей категории. |
| | | `class` | `NOT NULL`<br>`CHECK (class IN ('A', 'B', 'C'))` | ABC-класс товара обязателен и принимает одно из трёх стандартных значений классификации. |
| | | `modify_timestamp` | `NOT NULL` | Дата и время последнего обновления записи обязательны для аудита изменений. |
| | | `resistant` | `NOT NULL`<br>`DEFAULT FALSE` | Флаг устойчивости обязателен и имеет логический тип (`BOOLEAN`), по умолчанию устанавливается в `FALSE` (неустойчив). |
| | | `is_allergic` | `NOT NULL`<br>`DEFAULT FALSE` | Признак наличия аллергенов обязателен и имеет логический тип (`BOOLEAN`), по умолчанию устанавливается в `FALSE` (аллергены отсутствуют). |
| | | `vitality_days` | `NOT NULL`<br>`CHECK (vitality_days >= 0)` | Срок годности в днях обязателен и не может быть отрицательным числом. |
| 2 | `sales` | `sales_id` | `PRIMARY KEY` | Уникальный идентификатор строки продажи (позиции в чеке). |
| | | `employee_id` | `NOT NULL`<br>`FOREIGN KEY` | Внешний ключ к `employees (employee_id)`; каждая продажа оформляется конкретным сотрудником. |
| | | `customer_id` | `NOT NULL`<br>`FOREIGN KEY` | Внешний ключ к `customers (customer_id)`; привязка покупки к существующему клиенту. |
| | | `product_id` | `NOT NULL`<br>`FOREIGN KEY` | Внешний ключ к `products (product_id)`; ссылка на проданный товар из каталога. |
| | | `quantity` | `NOT NULL`<br>`CHECK (quantity > 0)` | Количество единиц товара в продаже обязательно и должно быть строго больше нуля. |
| | | `discount` | `NOT NULL`<br>`CHECK (discount >= 0 AND discount <= 1)` | Доля скидки обязательна и находится в диапазоне от `0` (0%) до `1` (100%). |
| | | `total_price` | `NOT NULL`<br>`CHECK (total_price >= 0)` | Итоговая сумма продажи обязательна и не может быть отрицательной. |
| | | `sales_timestamp` | `NOT NULL` | Дата и время совершения продажи обязательны для хронологического анализа. |
| | | `transaction_number` | `NOT NULL`<br>`UNIQUE` | Номер транзакции обязателен; `UNIQUE` ставится, если одна строка `sales` = один чек.<br><sub>*(Если в одном чеке бывает несколько товаров, `UNIQUE` следует снять и использовать индекс).*</sub> |
