--Which products should we order more or less of?
--Low Stock: Calculates the top 10 products that are almost out of stock or completely out of stock.

SELECT o.productcode, 
	ROUND(SUM(o.quantityordered)*1.0/
					(SELECT p.quantityinstock
					 FROM products p
					 WHERE o.productcode = p.productcode),2) as low_stock
FROM orderdetails o
GROUP BY o.productcode
ORDER BY low_stock DESC
LIMIT 10;


--Product Performance: Calulates the top 10 products with the highest sum of sales.

SELECT productcode, 
	SUM(quantityordered*priceeach) as performance
FROM orderdetails
GROUP BY productcode
ORDER BY performance DESC
LIMIT 10;


--Priority Products for Restocking: Calculates the high performing products that are almost out of stock or completely out of stock.

With low_stock_table AS(
	SELECT o.productcode, 
		ROUND(SUM(o.quantityordered)*1.0/
						(SELECT p.quantityinstock
						 FROM products p
						 WHERE o.productcode = p.productcode),2) as low_stock
	FROM orderdetails o
	GROUP BY o.productcode
	ORDER BY low_stock DESC
	LIMIT 10
),

products_to_restock AS(
	SELECT productcode, 
		SUM(quantityordered*priceeach) as performance	
	FROM orderdetails
	GROUP BY productcode
	ORDER BY performance DESC
	LIMIT 10
)

SELECT productname, 
	productline
FROM products
WHERE productcode 
	IN (SELECT productcode
		FROM products_to_restock);
		
		
		
--How should we match marketing and communication strategies to customer behaviors?		
--Customer Profit: Calculates the total profit for each customer. 

SELECT o.customernumber, 
	SUM(od.quantityordered * (od.priceeach - p.buyprice)) as profit

FROM orders o
LEFT JOIN orderdetails od
	ON o.ordernumber =od.ordernumber
LEFT JOIN products p
	ON p.productcode = od.productcode

GROUP BY o.customernumber
ORDER BY profit DESC;


--Top 5 Customers with the Highest Profit: Calculates top 5 customers with the highest total profit and provides a customer profile.

WITH customer_profit AS(
	SELECT o.customernumber as customer_number, 
		SUM(od.quantityordered * (od.priceeach - p.buyprice)) as profit
			
	FROM orders o
	LEFT JOIN orderdetails od
		ON o.ordernumber =od.ordernumber
	LEFT JOIN products p
		ON p.productcode = od.productcode
			
	GROUP BY o.customernumber
)

SELECT c.contactlastname, 
		c.contactfirstname, 
		c.city, 
		c.country, 
		cp.profit

FROM customers c
LEFT JOIN customer_profit cp
	ON c.customernumber = cp.customer_number

WHERE cp.profit IS NOT NULL 
ORDER BY cp.profit DESC
LIMIT 5;


--Top 5 Customers with the Lowest Profit: Calculates top 5 customers with the lowest total profit and provides a customer profile.

With customer_profit AS(
	SELECT o.customernumber as customer_number, 
		SUM(od.quantityordered * (od.priceeach - p.buyprice)) as profit
			
	FROM orders o
	LEFT JOIN orderdetails od
		ON o.ordernumber =od.ordernumber
	LEFT JOIN products p
		ON p.productcode = od.productcode
			
	GROUP BY o.customernumber
)

SELECT c.contactlastname, 
	c.contactfirstname, 
	c.city, 
	c.country, 
	cp.profit

FROM customers c
LEFT JOIN customer_profit cp
	ON c.customernumber = cp.customer_number

WHERE cp.profit IS NOT NULL 
ORDER BY cp.profit ASC
LIMIT 5;



--How Much Can We Spend on Acquiring New Customers?
--Average Customer Profit: Calculates the average total profit among all customers. 

WITH customer_profits AS(
	SELECT o.customernumber, 
		SUM(od.quantityordered * (od.priceeach - p.buyprice)) as profit
			
	FROM orders o
	LEFT JOIN orderdetails od
		ON o.ordernumber =od.ordernumber
	LEFT JOIN products p
		ON p.productcode = od.productcode
			
	GROUP BY o.customernumber
	ORDER BY profit DESC
)

SELECT AVG(profit)
FROM customer_profits;