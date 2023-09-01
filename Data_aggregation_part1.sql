--������ 9
--���������� ���������� ������� � ������� orders � ������� � ����� ��������. 
--��� ����� �������������� �������� array_length, ������������ ������ �� ���������� ������� � ������ � ��������� ���������. 
--���������� ������� �������� orders. ���� � �������������� �������: orders

SELECT count(order_id) as orders
FROM   orders
WHERE  array_length(product_ids, 1) >= 9
GROUP BY array_length(product_ids, 1)


--������ 12
--����������� ������� ���� ������� � ������� products, � ��������� ������� ������������ ����� ���� ��� �����. ����� ��������� �������� ��������� �� --������� ������ ���������� �����-��� ��� ������� ����. ������� ���� ��������� �� ���� ������ ����� �������. ������� � ���������� ��������� �������� --avg_price. ���� � �������������� �������: avg_price

SELECT round(avg(price), 2) as avg_price
FROM   products
WHERE  ((name like '%���%'
    or name like '%����%')
   and name not like '%����%'
   and name not like '%����%')


--������ 14
--����������� ������� ���������� ������� � ������� �� ������� orders, ������� ������������ ��������� �� �������� ���� (������� � �����������) � ������� --����� ������� ������ �������. ���������� �������� ��������� �� ���� ������ ����� �������. ������� � ��� �������� avg_order_size.
--���� � �������������� �������: avg_order_size

SELECT round(avg(array_length(product_ids, 1)), 2) as avg_order_size
FROM   orders
WHERE  date_part('dow', creation_time) = 0
    or date_part('dow', creation_time) = 6



--������ 15
--�� ������ ������ � ������� user_actions ���������� ���������� ���������� ������������� �������, ���������� ���������� �������, �������� ���� �� ������ � --��������, ������� ������� ���������� �� ������ ������������. � �������������� ������� �������� ��� ��� �������� � ���� �������� �������������� --unique_users, unique_orders, orders_per_user. ���������� ����� ������� �� ������������ ��������� �� ���� ������ ����� �������.
--���� � �������������� �������: unique_users, unique_orders, orders_per_user

SELECT count(distinct(user_id)) as unique_users,
       count(distinct(order_id)) as unique_orders,
       round(count(distinct(order_id))::decimal/count(distinct(user_id))::decimal,
             2) as orders_per_user
FROM   user_actions



--������ 17
--���������� ����� ���������� ������� � ������� orders, ���������� ������� � ����� � ����� �������� � ������� ���� ������� � ����� � ����� �������� � ����� --���������� �������. � �������������� ������� �������� ��� ��� �������� � ���� �������� �������������� orders, large_orders, large_orders_share.
--���� ������� � ����� � ����� �������� � ����� ���������� ������� ��������� �� ���� ������ ����� �������. ���� � �������������� --�������:orders,large_orders, large_orders_share


SELECT count(order_id) as orders,
       count(order_id) filter (WHERE array_length(product_ids, 1) >= 5) as large_orders,
       round(count(order_id) filter (WHERE array_length(product_ids, 1) >= 5)/count(order_id)::decimal,
             2) as large_orders_share
FROM   orders










 