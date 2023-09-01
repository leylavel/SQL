--ЗАДАЧА 11
--Посчитайте количество товаров в каждом заказе, примените к этим значениям группировку и рассчитайте количество заказов в каждой группе. Учитывайте только заказы, оформленные по будням. В результат включите только те размеры заказов, общее число которых превышает 2000. Для расчётов используйте данные из таблицы orders.
--Выведите две колонки: размер заказа и число заказов такого размера. Колонки назовите соответственно order_size и orders_count.
--Результат отсортируйте по возрастанию размера заказа. Поля в результирующей таблице: order_size, orders_count

SELECT array_length(product_ids, 1) as order_size,
       count(order_id) as orders_count
FROM   orders
WHERE  date_part('dow', creation_time) in (1, 2, 3, 4, 5)
GROUP BY order_size having count(order_id) >= 2000
ORDER BY order_size


--ЗАДАЧА 12
--По данным из таблицы user_actions определите пять пользователей, сделавших в августе 2022 года наибольшее количество заказов.
--Выведите две колонки — id пользователей и число оформленных ими заказов. Колонку с числом оформленных заказов назовите created_orders. 
--Результат отсортируйте сначала по убыванию числа заказов, сделанных пятью пользователями, затем по возрастанию id этих пользователей.
--Поля в результирующей таблице: user_id, created_orders

SELECT user_id,
       count(order_id) as created_orders
FROM   user_actions
WHERE  time > '2022/07/31'
   and time < '2022/09/01'
   and action = 'create_order'
GROUP BY user_id
ORDER BY created_orders desc, user_id limit 5


--ЗАДАЧА 15
--По данным из таблицы orders рассчитайте средний размер заказа по выходным и по будням. Группу с выходными днями (суббота и воскресенье) назовите «weekend», а группу с будними днями (с понедельника по пятницу) — «weekdays» (без кавычек).
--В результат включите две колонки: колонку с группами назовите week_part, а колонку со средним размером заказа — avg_order_size. 
--Средний размер заказа округлите до двух знаков после запятой.Результат отсортируйте по колонке со средним размером заказа — по возрастанию.
--Поля в результирующей таблице: week_part, avg_order_size

SELECT case when date_part('dow',
                           creation_time) in (1, 2, 3, 4, 5) then 'weekdays'
            when date_part('dow', creation_time) in (0, 6) then 'weekend' end as week_part,
       round(avg(array_length(product_ids, 1)), 2) as avg_order_size
FROM   orders
GROUP BY week_part
ORDER BY avg_order_size