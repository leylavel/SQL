--ЗАДАЧА 9
--Используя данные из таблицы user_actions, рассчитайте, сколько заказов сделал каждый пользователь и отразите это в столбце orders_count.В отдельном столбце orders_avg напротив каждого пользователя укажите среднее число заказов всех пользователей, округлив его до двух знаков после запятой.
--Также для каждого пользователя посчитайте отклонение числа заказов от среднего значения. Отклонение считайте так: число заказов «минус» округлённое среднее значение. Колонку с отклонением назовите orders_diff.
--Результат отсортируйте по возрастанию id пользователя. Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
with t1 as (SELECT user_id,
                   count(order_id) as orders_count
            FROM   user_actions
            WHERE  action = 'create_order'
            GROUP BY user_id), t2 as (SELECT round(avg(orders_count), 2) as orders_avg
                          FROM   t1)
SELECT user_id,
       orders_count,
       orders_avg,
       orders_count - orders_avg as orders_diff
FROM   t1, t2
ORDER BY user_id limit 1000


--ЗАДАЧА 10
--Назначьте скидку 15% на товары, цена которых превышает среднюю цену на все товары на 50 и более рублей, а также скидку 10% на товары, цена которых ниже средней на 50 и более рублей. Цену остальных товаров внутри диапазона (среднее - 50; среднее + 50) оставьте без изменений. При расчёте средней цены, округлите её до двух знаков после запятой.
--Выведите информацию о всех товарах с указанием старой и новой цены. Колонку с новой ценой назовите new_price.
--Результат отсортируйте сначала по убыванию прежней цены в колонке price, затем по возрастанию id товара.

SELECT product_id,
       name,
       price,
       case when price - (SELECT round(avg(price), 2)
                   FROM   products) >= 50 then price*0.85 when (SELECT round(avg(price), 2)
                                             FROM   products) - price >= 50 then price*0.9 else price end as new_price
FROM   products
ORDER BY price desc, product_id

--ЗАДАЧА 17
--Из таблицы couriers выведите всю информацию о курьерах, которые в сентябре 2022 года доставили 30 и более заказов. Результат отсортируйте по возрастанию id курьера.
--Поля в результирующей таблице: courier_id, birth_date, sex

with t1 as(SELECT courier_id,
                  count(order_id)
           FROM   courier_actions
           WHERE  date_part('year', time) = 2022
              and date_part('month', time) = 9
              and action = 'deliver_order'
           GROUP BY courier_id having count(order_id) >= 30)
SELECT *
FROM   couriers
WHERE  courier_id in (SELECT courier_id
                      FROM   t1)
ORDER BY courier_id