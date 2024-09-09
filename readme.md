Este proyecto contiene una serie de consultas SQL diseñadas para resolver diferentes tipos de problemas y casos de uso comunes en la gestión y manipulación de bases de datos. Las consultas están orientadas a explorar y extraer datos de manera eficiente, cubriendo aspectos como la agregación, clasificación, y análisis de datos.
A continuación se detallan las principales características y el tipo de consultas incluidas:

- Gestión y filtrado de datos: Consultas que permiten listar pedidos, clientes y productos basándose en condiciones específicas como el estado del pedido, la fecha o la cantidad de unidades.
- Consultas de agregación y clasificación: Uso de funciones como SUM(), COUNT(), AVG(), y RANK() para obtener resúmenes de datos, clasificaciones de productos y clientes, y análisis de ventas por país o año.
- Consultas con funciones de ventana: Ejemplos del uso de funciones de ventana como ROW_NUMBER(), RANK() y CASE para la creación de rankings, categorización de ventas y análisis de pedidos repetidos.
- Consultas de relaciones entre tablas: Implementación de JOINs (incluyendo INNER JOIN, LEFT JOIN, y UNION) para combinar datos de múltiples tablas, como productos, clientes, oficinas y detalles de pedidos.
- Análisis temporal: Consultas que analizan los datos a lo largo del tiempo, como el número de pedidos por mes o año, tiempos máximos de espera entre la orden y el envío, y el historial de pagos por cliente.
- Consultas de deuda y pagos: Listados de clientes que tienen facturas pendientes y análisis de pagos realizados por clientes en función de diferentes rangos de importes.
- Consultas sobre pedidos no enviados: Análisis de los pedidos que no han sido enviados, así como cálculos de ratios de envíos completados sobre el total de pedidos por cliente.
- Consultas de productos no vendidos: Identificación de productos que no han sido incluidos en ningún pedido, útil para el análisis de inventario no movilizado.
- Ranking de productos más vendidos: Consultas para determinar los productos más vendidos por año y por país, y ranking de clientes con más pedidos para cada país.
- Consultas de clientes sin actividad: Listado de clientes que no han realizado pedidos, así como clientes cuya primera transacción supera un determinado umbral económico.
