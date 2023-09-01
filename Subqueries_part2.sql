----ЗАДАЧА 19
--Посчитайте возраст каждого пользователя в таблице users.
--Возраст измерьте числом полных лет, как мы делали в прошлых уроках. Возраст считайте относительно последней даты в таблице user_actions.
--Для тех пользователей, у которых в таблице users не указана дата рождения, укажите среднее значение возраста всех остальных пользователей, округлённое до целого числа.
--Колонку с возрастом назовите age. В результат включите колонки с id пользователя и возрастом. Отсортируйте полученный результат по возрастанию id пользователя.

with t1 as (SELECT user_id,
                   date_part('year', age((SELECT max(time)
                                   FROM   user_actions), birth_date))::integer as date_part
            FROM   users
            WHERE  birth_date is not null)
SELECT user_id,
       case when date_part('year', age((SELECT max(time)
                                 FROM   user_actions), birth_date))::integer is null then (SELECT round(avg(date_part))
                                                          FROM   t1) else date_part('year', age((SELECT max(time)
                                       FROM   user_actions), birth_date))::integer end as age
FROM   users
ORDER BY user_id

--ЗАДАЧА 24
--Из таблицы orders выведите id и содержимое заказов, которые включают хотя бы один из пяти самых дорогих товаров, доступных в нашем сервисе.
--Результат отсортируйте по возрастанию id заказа.

with t1 as (SELECT *,
                   unnest(product_ids) as prod_id
            FROM   orders)
SELECT DISTINCT order_id,
                product_ids
FROM   t1
WHERE  prod_id in (SELECT product_id
                   FROM   products
                   ORDER BY price desc limit 5)
ORDER BY order_id
