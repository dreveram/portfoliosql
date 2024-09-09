--Lista los pedidos que se han hecho en el 2005 y que ya han sido enviados
SELECT orderNumber
FROM orders
WHERE status = 'Shipped' AND strftime('%Y', orderDate) = '2005';

--Lista los pedidos que fueron cancelados o en proceso y tienen como fecha de pedido Mayo de 2005
SELECT orderNumber, status, strftime('%m-%Y', orderDate) AS fecha_pedido
FROM orders
WHERE (status = 'In Process' OR status = 'Cancelled') AND strftime('%m-%Y', orderDate) = '05-2005';

--Lista de proveedores con más de 35000 unidades en stock ordenados por nombre de proveedor
SELECT productVendor, SUM(quantityInStock)
FROM products
GROUP BY productVendor
HAVING SUM(quantityInStock)>35000
ORDER BY productVendor;

-- Listar el número de pedidos por año (de pedido) y status que NO han sido enviados
SELECT COUNT(orderNumber), strftime('%Y', orderDate), status
FROM orders
WHERE status <> 'Shipped'
GROUP BY strftime('%Y', orderDate);

--Número de clientes por país para países con más de 5 clientes, de más cantidad a menos
SELECT country, COUNT(customerNumber)
FROM customers
GROUP BY country
HAVING COUNT(customerNumber)>5
ORDER BY COUNT(customerNumber) DESC;

--Numero de pedidos registrados el año 2005 por mes y estado del pedido
SELECT strftime('%m', orderDate), status, COUNT(orderNumber)
FROM orders
WHERE strftime('%Y', orderDate) = '2005'
GROUP BY strftime('%m', orderDate), status;

--¿Cual es el tiempo maximo de espera entre el recibo de una orden y su envío por cliente (ten en cuenta solo pedidos enviados)?
SELECT MAX(JULIANDAY(shippedDate) - JULIANDAY(orderDate)), customerNumber
FROM orders
WHERE status = 'Shipped'
GROUP BY customerNumber;

--Promedio de límite de crédito por país del cliente para los clientes que tienen límite > 0
SELECT CAST(AVG(creditLimit) AS INTEGER), country, COUNT(customerNumber)
FROM customers
WHERE creditLimit>0
GROUP BY country
ORDER BY AVG(creditLimit);

--Lista cada empleado (nombre, apellido), con la ciudad y código postal de su oficina.
SELECT e.lastName||', '||e.firstName AS empleado, o.city, o.postalCode
FROM employees AS e
INNER JOIN offices AS o
ON e.officeCode = o.officeCode;

--Selecciona solo los que están en la oficina de San Francisco.
SELECT e.lastName||', '||e.firstName AS empleado, o.city, o.postalCode
FROM employees AS e
INNER JOIN offices AS o
ON e.officeCode = o.officeCode
WHERE o.city ='San Francisco';

--Lista los clientes y su país, que no han hecho ningún pedido, con JOIN
SELECT c.customerNumber, c.country
FROM customers AS c
LEFT JOIN orders AS o 
ON c.customerNumber = o.customerNumber
WHERE o.customerNumber IS NULL;

--Lista el nombre y la descripcion de la categoría del producto de aquellos productos que no hayan sido incluidos en ningun pedido.
SELECT pl.productLine, pl.textDescription, p.productName
FROM products AS p

JOIN productlines AS pl
ON pl.productLine = p.productLine

LEFT JOIN orderdetails AS od
ON p.productCode = od.productCode
WHERE od.productCode IS NULL; 

--Ranking de productos más vendidos por año y por país, incluyendo productLine y número de ventas por año y país
SELECT p.productName, p.productLine, SUM(od.quantityOrdered) AS total_pedidos, strftime('%Y', o.orderDate) AS año, c.country
FROM orderdetails AS od 

JOIN products AS p
ON p.productCode = od.productCode

JOIN orders AS o 
ON od.orderNumber = o.orderNumber

JOIN customers AS c 
ON o.customerNumber = c.customerNumber

GROUP BY od.productCode, strftime('%Y', o.orderDate), c.country
ORDER BY total_pedidos DESC;

--¿Qué clientes nos deben dinero y cuánto?

WITH facturas AS
    (SELECT o.customerNumber, SUM(od.quantityOrdered*od.priceEach) AS total_facturas
    FROM orderdetails AS od

    LEFT JOIN orders AS o
    ON od.orderNumber = o.orderNumber
    GROUP BY o.customerNumber
    ),

pagos AS
    (SELECT customerNumber, SUM(amount) AS pagado_cliente
    FROM payments
    GROUP BY customerNumber
    )

SELECT c.customerNumber, (facturas.total_facturas - pagos.pagado_cliente) AS DEBE
FROM customers AS C

LEFT JOIN facturas
ON c.customerNumber = facturas.customerNumber

LEFT JOIN pagos
ON c.customerNumber = pagos.customerNumber

WHERE DEBE >0.1;

--Clasifica el listado de clientes en funcion del pago que hayan hecho: haz 3 categorias, menos de 20.000, entre 20.000 y 50.000 y mas de 50.000
SELECT customerNumber, SUM(amount), 
CASE 
    WHEN SUM(amount)<20000 THEN 'Menos de 20k'
    WHEN SUM(amount)>=20000 AND SUM(amount)<=50000 THEN 'Entre 20k y 50k'
    WHEN SUM(amount)>50000 THEN 'Mas de 50k'
    ELSE '99' 
END AS Importe_Pagado
FROM payments
GROUP BY customerNumber;

--¿Cuántos clientes han realizado algun pedido y cuántos no?
SELECT COUNT(DISTINCT c.customerNumber),
CASE
    WHEN o.customerNumber IS NULL THEN '0'
    ELSE '1'
END AS Con_pedido
FROM customers AS c 

LEFT JOIN orders AS o 
ON c.customerNumber = o.customerNumber

GROUP BY CASE
    WHEN o.customerNumber IS NULL THEN '0'
    ELSE '1'
END;

--Crea un campo que clasifique la cantidad de unidades encargadas por pedido: menos de 100 ,entre 100 y 200 o mas de 200. Cuantos pedidos hay de cada tipo?
SELECT orderNumber,
CASE
    WHEN SUM(quantityOrdered)<100 THEN 'Menos de 100'
    WHEN SUM(quantityOrdered)>=100 AND SUM(quantityOrdered)<=200 THEN 'Entre 100 y 200'
    WHEN SUM(quantityOrdered)>200 THEN 'Mas de 200'
    ELSE '99'
END AS Unidades_por_pedido
FROM orderdetails

GROUP BY orderNumber;

WITH aux AS
    (SELECT orderNumber,
    CASE
        WHEN SUM(quantityOrdered)<100 THEN 'Menos de 100'
        WHEN SUM(quantityOrdered)>=100 AND SUM(quantityOrdered)<=200 THEN 'Entre 100 y 200'
        WHEN SUM(quantityOrdered)>200 THEN 'Mas de 200'
        ELSE '99'
    END AS Unidades_por_pedido
    FROM orderdetails

    GROUP BY orderNumber)

SELECT COUNT(orderNumber), Unidades_por_pedido
FROM aux
GROUP BY Unidades_por_pedido;

--Crea una lista de todos los codigos postales donde se puedan recibir o enviar paquetes. En caso de que sea una oficina, el campo "Accion" contendra "E" y en caso que sea la direccion de un cliente contendra "R". La lista no puede contener duplicados
SELECT postalCode, 'R' AS acción
FROM customers
UNION
SELECT postalCode, 'E' AS acción
FROM offices;

--Numero de pedidos hechos por ciudad en la tabla orders
SELECT o.*, COUNT() OVER (PARTITION BY c.city), c.city
FROM orders AS o

JOIN customers AS c 
ON o.customerNumber = c.customerNumber;

--Crea un ranking de clientes con más pedidos para cada país.
SELECT RANK() OVER(PARTITION BY (c.country) ORDER BY COUNT(o.orderNumber) DESC), 
    c.customerNumber, c.country, COUNT(o.orderNumber)
FROM customers AS c 

LEFT JOIN orders AS o 
ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber;

--Lista los checkNumber y la cantidad pagada de esos pagos en que la cantidad pagada sea inferior a la cantidad pagada promedia de la tabla de payments. Ordena los pagos de mas a menos y muestra solo las primeras 10 líneas.
SELECT checkNumber, amount
FROM payments
WHERE amount<
    (SELECT AVG(amount)
    FROM payments)
ORDER BY amount DESC
LIMIT 10;

--Lista el Nombre y apellido de cada manager seguido del nombre y apellido de cada empleado el cual supervisa. Ordena los resultados por el Apellido de cada manager. Muestra solo los 10 primeros registros.

WITH managers AS (
    SELECT lastName, firstName, employeeNumber
    FROM employees
    WHERE jobTitle LIKE '%Manager%')

SELECT managers.lastName, managers.firstName, e.lastName, e.firstName
FROM employees AS e

JOIN managers
ON managers.employeeNumber = e.reportsTo

ORDER BY managers.lastName
LIMIT 10;

--¿Cuántos clientes han hecho mas de un pedido el mismo dia?
SELECT COUNT(DISTINCT o1.customerNumber)
FROM orders AS o1
INNER JOIN orders as o2
ON o1.customerNumber = o2.customerNumber AND o1.orderDate = o2.orderDate AND o1.orderNumber <> o2.orderNumber;

--Calcula el ratio de pedidos enviados/total de pedidos para cada cliente 2003.
SELECT customerNumber, 
COUNT (CASE WHEN status = 'Shipped' THEN 1 END) *1.0 / COUNT (orderNumber) AS porcentaje_enviados
FROM orders
WHERE strftime('%Y', orderDate) = '2003'
GROUP BY customerNumber;

--Lista los 3 países con más unidades de pedido vendidas
SELECT SUM(od.quantityOrdered), c.country
FROM customers as c

LEFT JOIN orders as o 
ON c.customerNumber = o.customerNumber

LEFT JOIN orderdetails as od
ON o.orderNumber = od.orderNumber

GROUP BY c.country
ORDER BY SUM(od.quantityOrdered) DESC
LIMIT 3;

--Lista el nombre de los 10 clientes que más pedidos tengan, solo teniendo en cuenta aquellos que se hayan gastado más de 5.000€ en el total de sus pedidos.
SELECT customerName, COUNT(o.orderNumber), SUM(od.quantityOrdered*od.priceEach)
FROM customers AS c 

JOIN orders as o 
ON c.customerNumber = o.customerNumber

JOIN orderdetails as od  
ON o.orderNumber = od.orderNumber

GROUP BY o.customerNumber
HAVING SUM(od.quantityOrdered*od.priceEach) >5000
ORDER BY COUNT(o.orderNumber) DESC;

--Haz un histograma de los pedidos hechos por cliente en 2005
WITH aux AS (
    SELECT customerNumber, COUNT(orderNumber) as n_pedidos
    FROM orders
    WHERE strftime('%Y', orderDate) = '2005'
    GROUP BY customerNumber
    )
SELECT n_pedidos, COUNT(customerNumber)
FROM aux
GROUP BY n_pedidos;

--Lista los clientes que han comprado al menos una o más veces el mismo producto en días distintos
SELECT DISTINCT customerNumber
FROM (
  select customerNumber, RANK() OVER(PARTITION BY customerNumber,productCode ORDER BY orderDate) AS num_days
  FROM orders o
  LEFT JOIN orderdetails od 
  ON od.OrderNumber=o.OrderNumber
) 
WHERE num_days=2;

--Lista aquellos clientes los cuales su primera transaccion fue superior a 30.000€
WITH aux AS (
    SELECT ROW_NUMBER() OVER (PARTITION BY customerNumber ORDER BY paymentDate) as n_consulta, customerNumber, amount 
    FROM payments
    )
SELECT *
FROM aux
WHERE n_consulta= 1 AND amount >30000;
