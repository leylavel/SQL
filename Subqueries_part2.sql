----������ 19
--���������� ������� ������� ������������ � ������� users.
--������� �������� ������ ������ ���, ��� �� ������ � ������� ������. ������� �������� ������������ ��������� ���� � ������� user_actions.
--��� ��� �������������, � ������� � ������� users �� ������� ���� ��������, ������� ������� �������� �������� ���� ��������� �������������, ���������� �� ������ �����.
--������� � ��������� �������� age. � ��������� �������� ������� � id ������������ � ���������. ������������ ���������� ��������� �� ����������� id ������������.

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

--������ 24
--�� ������� orders �������� id � ���������� �������, ������� �������� ���� �� ���� �� ���� ����� ������� �������, ��������� � ����� �������.
--��������� ������������ �� ����������� id ������.

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
