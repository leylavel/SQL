--������ 16

--�������� ������������� �� ������� users �� 4 ���������� ������:

--�� 19 �� 24 ���;
--�� 25 �� 29 ���;
--�� 30 �� 35 ���;
--�� 36 �� 41 ����.
--���������� ����� �������������, �������� � ������ ���������� ������. ������ �������� �������������� �19-24�, �25-29�, �30-35�, �36-41� (��� �������).
--�������� ������������ ����� � ����� ������������� � ���. ������� � ������������� ����� �������� group_age, � ������� � ������ ������������� � users_count.
--������������ ���������� ������� �� ������� � ������������� ����� �� �����������. ���� � �������������� �������: group_age, users_count

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

--������ 17
--��� ������� ������������ � ������� user_actions ���������� ����� ���������� ����������� ������� � ���� ��������� �������.
--����� ������� �������� �������������� orders_count � cancel_rate. ������� � ����� ��������� ������� ��������� �� ���� ������ ����� �������.
--� ��������� �������� ������ ��� �������������, ������� �������� ������ ��� ������� � � ������� ���������� cancel_rate ���������� �� ����� 0.5.
--��������� ������������ �� ����������� id ������������.

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

--������ 18
--��� ������� ��� ������ � ������� user_actions ����������:
--����� ���������� ����������� �������.
--����� ���������� ��������� �������.
--����� ���������� ����������� ������� (�.�. ������������).
--���� ����������� ������� � ����� ����� ������� (success rate).����� ������� �������� �������������� created_orders, canceled_orders, actual_orders � success_rate. ������� � ����� ����������� ������� ��������� �� ��� ������ ����� �������.
--��� ������� ��������� �� ������ � 24 ������� �� 6 �������� 2022 ���� ������������, ����� �� ��������� �������� ������ ������ ���������� ������ ���� ������.
--������ ����������� ��������� �������: �������� ���� ������ �� ���� � ������� ������� to_char � ���������� 'Dy', ����� �������� ���������� ����� ��� ������ � ������� ������� DATE_PART � ���������� 'isodow'. ����� ������������ ������ �� ���� ����� � ��������� ��� ����������� �������. � ���������� ������ ���������� ����������� �� ���� ��������: � ���������� ������� ���� ������ � �� ������������ ��������������.��������� ������������ �� ����������� ����������� ������ ��� ������.

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
--� 24 ������� �� 6 �������� 2022 ���� ������������