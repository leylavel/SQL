--ЗАДАЧА 16

--Разбейте пользователей из таблицы users на 4 возрастные группы:

--от 19 до 24 лет;
--от 25 до 29 лет;
--от 30 до 35 лет;
--от 36 до 41 года.
--Посчитайте число пользователей, попавших в каждую возрастную группу. Группы назовите соответственно «19-24», «25-29», «30-35», «36-41» (без кавычек).
--Выведите наименования групп и число пользователей в них. Колонку с наименованием групп назовите group_age, а колонку с числом пользователей — users_count.
--Отсортируйте полученную таблицу по колонке с наименованием групп по возрастанию. Поля в результирующей таблице: group_age, users_count

SELECT case when date_part('year',
                           age(current_date, birth_date))::integer between 19 and
                 24 then '19-24'
            when date_part('year', age(current_date, birth_date))::integer between 25 and
                 29 then '25-29'
            when date_part('year', age(current_date, birth_date))::integer between 30 and
                 35 then '30-35'
            when date_part('year', age(current_date, birth_date))::integer between 36 and
                 41 then '36-41' end as group_age,
       count(user_id) as users_count
FROM   users
GROUP BY group_age
ORDER BY group_age limit 4

--ЗАДАЧА 17
--Для каждого пользователя в таблице user_actions посчитайте общее количество оформленных заказов и долю отменённых заказов.
--Новые колонки назовите соответственно orders_count и cancel_rate. Колонку с долей отменённых заказов округлите до двух знаков после запятой.
--В результат включите только тех пользователей, которые оформили больше трёх заказов и у которых показатель cancel_rate составляет не менее 0.5.
--Результат отсортируйте по возрастанию id пользователя.

SELECT user_id,
       count(order_id) filter (WHERE action = 'create_order') as orders_count,
       round(count(order_id) filter (WHERE action = 'cancel_order')::decimal/count(order_id) filter (WHERE action = 'create_order')::decimal,
             2) as cancel_rate
FROM   user_actions
GROUP BY user_id having count(order_id) filter (
WHERE  action = 'create_order') > 3
   and round(count(order_id) filter (
WHERE  action = 'cancel_order')::decimal/count(order_id) filter (
WHERE  action = 'create_order')::decimal, 2) >= 0.5
ORDER BY user_id

--ЗАДАЧА 18
--Для каждого дня недели в таблице user_actions посчитайте:
--Общее количество оформленных заказов.
--Общее количество отменённых заказов.
--Общее количество неотменённых заказов (т.е. доставленных).
--Долю неотменённых заказов в общем числе заказов (success rate).Новые колонки назовите соответственно created_orders, canceled_orders, actual_orders и success_rate. Колонку с долей неотменённых заказов округлите до трёх знаков после запятой.
--Все расчёты проводите за период с 24 августа по 6 сентября 2022 года включительно, чтобы во временной интервал попало равное количество разных дней недели.
--Группы сформируйте следующим образом: выделите день недели из даты с помощью функции to_char с параметром 'Dy', также выделите порядковый номер дня недели с помощью функции DATE_PART с параметром 'isodow'. Далее сгруппируйте данные по двум полям и проведите все необходимые расчёты. В результате должна получиться группировка по двум колонкам: с порядковым номером дней недели и их сокращёнными наименованиями.Результат отсортируйте по возрастанию порядкового номера дня недели.

SELECT count(order_id) filter (WHERE action = 'create_order') as created_orders,
       count(order_id) filter (WHERE action = 'cancel_order') as canceled_orders,
       count(order_id) filter (WHERE action = 'create_order') - count(order_id) filter (WHERE action = 'cancel_order') as actual_orders,
       round((count(order_id) filter (WHERE action = 'create_order') - count(order_id) filter (WHERE action = 'cancel_order'))::decimal/count(order_id) filter (WHERE action = 'create_order')::decimal,
             3) as success_rate,
       to_char(time, 'Dy') as weekday,
       date_part('isodow', time)::integer as weekday_number
FROM   user_actions
WHERE  time >= '2022-08-24'
   and time < '2022-09-07'
   --WHERE  time between '2022/08/24' and '2022/09/06'
GROUP BY date_part('isodow', time)::integer, to_char(time, 'Dy')
--с 24 августа по 6 сентября 2022 года включительно