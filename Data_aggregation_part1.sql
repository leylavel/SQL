--���������� ���������� ������� � ������� orders � ������� � ����� ��������. 
--��� ����� �������������� �������� array_length, ������������ ������ �� ���������� ������� � ������ � ��������� ���������. 
--���������� ������� �������� orders. ���� � �������������� �������: orders

SELECT count(order_id) as orders
FROM   orders
WHERE  array_length(product_ids, 1) >= 9
GROUP BY array_length(product_ids, 1)