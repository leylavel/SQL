--������ 9
--��������� ������ �� ������� user_actions, �����������, ������� ������� ������ ������ ������������ � �������� ��� � ������� orders_count.� ��������� ������� orders_avg �������� ������� ������������ ������� ������� ����� ������� ���� �������������, �������� ��� �� ���� ������ ����� �������.
--����� ��� ������� ������������ ���������� ���������� ����� ������� �� �������� ��������. ���������� �������� ���: ����� ������� ������ ���������� ������� ��������. ������� � ����������� �������� orders_diff.
--��������� ������������ �� ����������� id ������������. �������� � ������ �������� LIMIT � �������� ������ ������ 1000 ����� �������������� �������.
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


--������ 10
--��������� ������ 15% �� ������, ���� ������� ��������� ������� ���� �� ��� ������ �� 50 � ����� ������, � ����� ������ 10% �� ������, ���� ������� ���� ������� �� 50 � ����� ������. ���� ��������� ������� ������ ��������� (������� - 50; ������� + 50) �������� ��� ���������. ��� ������� ������� ����, ��������� � �� ���� ������ ����� �������.
--�������� ���������� � ���� ������� � ��������� ������ � ����� ����. ������� � ����� ����� �������� new_price.
--��������� ������������ ������� �� �������� ������� ���� � ������� price, ����� �� ����������� id ������.

SELECT product_id,
       name,
       price,
       case when price - (SELECT round(avg(price), 2)
                   FROM   products) >= 50 then price*0.85 when (SELECT round(avg(price), 2)
                                             FROM   products) - price >= 50 then price*0.9 else price end as new_price
FROM   products
ORDER BY price desc, product_id

--������ 17
--�� ������� couriers �������� ��� ���������� � ��������, ������� � �������� 2022 ���� ��������� 30 � ����� �������. ��������� ������������ �� ����������� id �������.
--���� � �������������� �������: courier_id, birth_date, sex

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