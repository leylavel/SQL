--������ 11
--���������� ���������� ������� � ������ ������, ��������� � ���� ��������� ����������� � ����������� ���������� ������� � ������ ������. ���������� ������ ������, ����������� �� ������. � ��������� �������� ������ �� ������� �������, ����� ����� ������� ��������� 2000. ��� �������� ����������� ������ �� ������� orders.
--�������� ��� �������: ������ ������ � ����� ������� ������ �������. ������� �������� �������������� order_size � orders_count.
--��������� ������������ �� ����������� ������� ������. ���� � �������������� �������: order_size, orders_count

SELECT array_length(product_ids, 1) as order_size,
       count(order_id) as orders_count
FROM   orders
WHERE  date_part('dow', creation_time) in (1, 2, 3, 4, 5)
GROUP BY order_size having count(order_id) >= 2000
ORDER BY order_size


--������ 12
--�� ������ �� ������� user_actions ���������� ���� �������������, ��������� � ������� 2022 ���� ���������� ���������� �������.
--�������� ��� ������� � id ������������� � ����� ����������� ��� �������. ������� � ������ ����������� ������� �������� created_orders. 
--��������� ������������ ������� �� �������� ����� �������, ��������� ����� ��������������, ����� �� ����������� id ���� �������������.
--���� � �������������� �������: user_id, created_orders

SELECT user_id,
       count(order_id) as created_orders
FROM   user_actions
WHERE  time > '2022/07/31'
   and time < '2022/09/01'
   and action = 'create_order'
GROUP BY user_id
ORDER BY created_orders desc, user_id limit 5


--������ 15
--�� ������ �� ������� orders ����������� ������� ������ ������ �� �������� � �� ������. ������ � ��������� ����� (������� � �����������) �������� �weekend�, � ������ � ������� ����� (� ������������ �� �������) � �weekdays� (��� �������).
--� ��������� �������� ��� �������: ������� � �������� �������� week_part, � ������� �� ������� �������� ������ � avg_order_size. 
--������� ������ ������ ��������� �� ���� ������ ����� �������.��������� ������������ �� ������� �� ������� �������� ������ � �� �����������.
--���� � �������������� �������: week_part, avg_order_size

SELECT case when date_part('dow',
                           creation_time) in (1, 2, 3, 4, 5) then 'weekdays'
            when date_part('dow', creation_time) in (0, 6) then 'weekend' end as week_part,
       round(avg(array_length(product_ids, 1)), 2) as avg_order_size
FROM   orders
GROUP BY week_part
ORDER BY avg_order_size