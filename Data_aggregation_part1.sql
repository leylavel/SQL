--ЗАДАЧА 9
--Посчитайте количество заказов в таблице orders с девятью и более товарами. 
--Для этого воспользуйтесь функцией array_length, отфильтруйте данные по количеству товаров в заказе и проведите агрегацию. 
--Полученный столбец назовите orders. Поле в результирующей таблице: orders

SELECT count(order_id) as orders
FROM   orders
WHERE  array_length(product_ids, 1) >= 9
GROUP BY array_length(product_ids, 1)


--ЗАДАЧА 12
--Рассчитайте среднюю цену товаров в таблице products, в названиях которых присутствуют слова «чай» или «кофе». Любым известным способом исключите из --расчёта товары содержащие «иван-чай» или «чайный гриб». Среднюю цену округлите до двух знаков после запятой. Столбец с полученным значением назовите --avg_price. Поле в результирующей таблице: avg_price

SELECT round(avg(price), 2) as avg_price
FROM   products
WHERE  ((name like '%чай%'
    or name like '%кофе%')
   and name not like '%иван%'
   and name not like '%гриб%')


--ЗАДАЧА 14
--Рассчитайте среднее количество товаров в заказах из таблицы orders, которые пользователи оформляли по выходным дням (суббота и воскресенье) в течение --всего времени работы сервиса. Полученное значение округлите до двух знаков после запятой. Колонку с ним назовите avg_order_size.
--Поле в результирующей таблице: avg_order_size

SELECT round(avg(array_length(product_ids, 1)), 2) as avg_order_size
FROM   orders
WHERE  date_part('dow', creation_time) = 0
    or date_part('dow', creation_time) = 6



--ЗАДАЧА 15
--На основе данных в таблице user_actions посчитайте количество уникальных пользователей сервиса, количество уникальных заказов, поделите одно на другое и --выясните, сколько заказов приходится на одного пользователя. В результирующей таблице отразите все три значения — поля назовите соответственно --unique_users, unique_orders, orders_per_user. Показатель числа заказов на пользователя округлите до двух знаков после запятой.
--Поля в результирующей таблице: unique_users, unique_orders, orders_per_user

SELECT count(distinct(user_id)) as unique_users,
       count(distinct(order_id)) as unique_orders,
       round(count(distinct(order_id))::decimal/count(distinct(user_id))::decimal,
             2) as orders_per_user
FROM   user_actions



--ЗАДАЧА 17
--Посчитайте общее количество заказов в таблице orders, количество заказов с пятью и более товарами и найдите долю заказов с пятью и более товарами в общем --количестве заказов. В результирующей таблице отразите все три значения — поля назовите соответственно orders, large_orders, large_orders_share.
--Долю заказов с пятью и более товарами в общем количестве товаров округлите до двух знаков после запятой. Поля в результирующей --таблице:orders,large_orders, large_orders_share


SELECT count(order_id) as orders,
       count(order_id) filter (WHERE array_length(product_ids, 1) >= 5) as large_orders,
       round(count(order_id) filter (WHERE array_length(product_ids, 1) >= 5)/count(order_id)::decimal,
             2) as large_orders_share
FROM   orders










 