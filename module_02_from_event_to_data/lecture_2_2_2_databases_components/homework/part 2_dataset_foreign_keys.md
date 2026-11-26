# 2\. Foreign Keys датасета `source.zip`: описание и связи с другими таблицами датасета

|No|Table Name|Foreign Keys|Related Table Name                                                            |
|:-:|-|-|-|
|1|`countries`|—|—|
|2|`cities`|`country_id`|`countries`|
|3|`categories`|—|—|
|4|`products`|`category_id`|`categories`|
|5|`shops`|`city_id`|`cities`|
|6|`employees`|`city_id`<br>`shop_id`|`cities`<br>`shops`|
|7|`customers`|`city_id`|`cities`|
|8|`sales`|`employee_id`<br>`customer_id`<br>`product_id`|`employees`<br>`customers`<br>`products`|



