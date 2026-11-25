# 2\. Foreign Keys датасета `source.zip`: описание и связи с другими таблицами датасета

|No|Table Name|Foreign Keys|Related Table Name                                                            |
|:-:|-|-|-|
|1|`countries`|—|—|
|2|`cities`|`country\\\_id`|`countries`|
|3|`categories`|—|—|
|4|`products`|`category\\\_id`|`categories`|
|5|`shops`|`city\\\_id`|`cities`|
|6|`employees`|`city\\\_id`<br>`shop\\\_id`|`cities`<br>`shops`|
|7|`customers`|`city\\\_id`|`cities`|
|8|`sales`|`employee\\\_id`<br>`customer\\\_id`<br>`product\\\_id`|`employees`<br>`customers`<br>`products`|



