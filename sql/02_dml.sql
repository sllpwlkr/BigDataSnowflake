INSERT INTO dim_customer (
    customer_id, first_name, last_name, age, email, country, postal_code
)
SELECT 
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code
FROM (
    SELECT DISTINCT ON (sale_customer_id)
        sale_customer_id,
        customer_first_name,
        customer_last_name,
        customer_age,
        customer_email,
        customer_country,
        customer_postal_code
    FROM mock_data
    WHERE sale_customer_id IS NOT NULL
    ORDER BY sale_customer_id, sale_date DESC
) AS customers
ON CONFLICT (customer_id) DO NOTHING;



INSERT INTO dim_date (
    sale_date, year, quarter, month, day, weekday
)
SELECT DISTINCT
    sale_date,
    EXTRACT(YEAR FROM sale_date)::INT,
    EXTRACT(QUARTER FROM sale_date)::INT,
    EXTRACT(MONTH FROM sale_date)::INT,
    EXTRACT(DAY FROM sale_date)::INT,
    EXTRACT(DOW FROM sale_date)::INT
FROM mock_data
WHERE sale_date IS NOT NULL
ON CONFLICT (sale_date) DO NOTHING;


INSERT INTO dim_product (
    product_id, name, category, weight, color, size, brand, 
    material, description, rating, reviews, release_date, 
    expiry_date, unit_price
)
SELECT 
    sale_product_id,
    product_name,
    product_category,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date,
    product_price
FROM (
    SELECT DISTINCT ON (sale_product_id)
        sale_product_id,
        product_name,
        product_category,
        product_weight,
        product_color,
        product_size,
        product_brand,
        product_material,
        product_description,
        product_rating,
        product_reviews,
        product_release_date,
        product_expiry_date,
        product_price
    FROM mock_data
    WHERE sale_product_id IS NOT NULL
    ORDER BY sale_product_id, sale_date DESC
) AS products
ON CONFLICT (product_id) DO NOTHING;



INSERT INTO dim_seller (
    seller_id, first_name, last_name, email, country, postal_code
)
SELECT 
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM (
    SELECT DISTINCT ON (sale_seller_id)
        sale_seller_id,
        seller_first_name,
        seller_last_name,
        seller_email,
        seller_country,
        seller_postal_code
    FROM mock_data
    WHERE sale_seller_id IS NOT NULL
    ORDER BY sale_seller_id, sale_date DESC
) AS sellers
ON CONFLICT (seller_id) DO NOTHING;



INSERT INTO dim_store (
    name, location, city, state, country, phone, email
)
SELECT 
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM (
    SELECT DISTINCT ON (store_name)
        store_name,
        store_location,
        store_city,
        store_state,
        store_country,
        store_phone,
        store_email
    FROM mock_data
    WHERE store_name IS NOT NULL
    ORDER BY store_name, sale_date DESC
) AS stores
ON CONFLICT (name) DO NOTHING;



INSERT INTO dim_supplier (
    name, contact, email, phone, address, city, country
)
SELECT 
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM (
    SELECT DISTINCT ON (supplier_name)
        supplier_name,
        supplier_contact,
        supplier_email,
        supplier_phone,
        supplier_address,
        supplier_city,
        supplier_country
    FROM mock_data
    WHERE supplier_name IS NOT NULL
    ORDER BY supplier_name, sale_date DESC
) AS suppliers
ON CONFLICT (name) DO NOTHING;



INSERT INTO fact_sales (
    date_sk, customer_sk, seller_sk, product_sk, 
    store_sk, supplier_sk, sale_quantity, 
    sale_total_price, unit_price
)
SELECT 
    d.date_sk,
    c.customer_sk,
    s.seller_sk,
    p.product_sk,
    st.store_sk,
    sup.supplier_sk,
    md.sale_quantity,
    md.sale_total_price,
    md.product_price
FROM mock_data md
JOIN dim_date d ON md.sale_date = d.sale_date
JOIN dim_customer c ON md.sale_customer_id = c.customer_id
JOIN dim_seller s ON md.sale_seller_id = s.seller_id
JOIN dim_product p ON md.sale_product_id = p.product_id
JOIN dim_store st ON md.store_name = st.name
JOIN dim_supplier sup ON md.supplier_name = sup.name
WHERE md.sale_customer_id IS NOT NULL
  AND md.sale_seller_id IS NOT NULL
  AND md.sale_product_id IS NOT NULL;