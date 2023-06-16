**Total orders and total orders value by month**
SELECT		DATE_PART('year', order_purchase_timestamp) as purchased_year,
			DATE_PART('month', order_purchase_timestamp) as purchased_month,
			sum(price) as total_value, 
			sum(freight_value) as total_freight_value	
FROM		ecommerce.orders
RIGHT JOIN	ecommerce.items ON orders.order_id = items.order_id
GROUP BY	purchased_year,purchased_month
ORDER BY	purchased_year,sum(price) desc;

**Top 5 Product Category has highest orders**
SELECT		product_category_name,COUNT (items.order_id) as total
FROM		ecommerce.orders
RIGHT JOIN	ecommerce.items ON orders.order_id = items.order_id
LEFT JOIN	ecommerce.products ON items.product_id = products.product_id

GROUP BY	product_category_name
ORDER BY	total desc
LIMIT		5;

**Orders distribution in Brazil**
SELECT		count(order_id) as total_orders, geolocation_city, geolocation_lat, geolocation_lng
FROM		ecommerce.orders
LEFT JOIN	ecommerce.customers ON orders.customer_id = customers.customer_id
LEFT JOIN	ecommerce.geolocation ON customers.customer_zip_code_prefix = geolocation.geolocation_zip_code_prefix

GROUP BY	geolocation_city,geolocation_lat, geolocation_lng
ORDER BY	total_orders desc;


**Number of transactions and total values by payment type**
SELECT  count(order_id) as num_of_transactions, payment_type
FROM ecommerce.payments
GROUP BY payment_type;

SELECT  payment_type, sum(payment_value) as total_value 
FROM ecommerce.payments
GROUP BY payment_type
ORDER BY total_value desc;

**Define the good and bad sellers**
SELECT sellers.seller_id, round(avg(review_score),1) as average_score, count(review_score) as total_review
FROM ecommerce.reviews 
LEFT JOIN ecommerce.items
ON reviews."order_id " = items.order_id
LEFT JOIN ecommerce.sellers
ON items.seller_id = sellers.seller_id
GROUP BY sellers.seller_id
HAVING count(review_score) >10
ORDER BY average_score asc;

**Delivery operation**

SELECT		order_id,
			DATE_PART('day',order_delivered_carrier_date-order_purchase_timestamp) as processing_time,
			DATE_PART('day', order_delivered_customer_date - order_delivered_carrier_date) as delivered_time,
CASE
	WHEN	order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
	WHEN	order_delivered_customer_date < order_estimated_delivery_date THEN 'Early'
	ELSE	'On time'
END AS	delivery_quality
FROM		ecommerce.orders

**Define the product category that usually be delivered late**
SELECT product_category_name,count(order_id) as total_late_order
FROM
	(SELECT order_id, items.product_id, product_category_name
	FROM ecommerce.items  
	LEFT JOIN ecommerce.products ON items.product_id = products.product_id
	WHERE order_id in (SELECT order_id from
		(SELECT *
		 FROM
			(SELECT		order_id,
						DATE_PART('day',order_delivered_carrier_date-order_purchase_timestamp) as processing_time,
						DATE_PART('day', order_delivered_customer_date - order_delivered_carrier_date) as delivered_time,
			 CASE
				WHEN	order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
				WHEN	order_delivered_customer_date < order_estimated_delivery_date THEN 'Early'
				ELSE	'On time'
			END AS	delivery_quality
			FROM		ecommerce.orders) as innerq1
		WHERE delivery_quality = 'Late') as innerq2)) as inner3
GROUP BY product_category_name
ORDER BY total_late_order desc
LIMIT 10;

**Number of new customers by month**
SELECT	
		DATE_PART('year',first_time) as first_purchased_year,
		DATE_PART('month', first_time) as first_purchased_month,
		count(customer_unique_id) as new_member
FROM 
    (SELECT distinct customer_unique_id, min(order_purchase_timestamp) as first_time
     FROM ecommerce.orders
     LEFT JOIN ecommerce.customers on customers.customer_id = orders.customer_id
     GROUP BY customer_unique_id) as innerq
GROUP BY first_purchased_year, first_purchased_month
ORDER BY first_purchased_year, first_purchased_month;
