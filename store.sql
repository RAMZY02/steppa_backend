-- 1. create user admin
CREATE USER reki IDENTIFIED BY reki;
CREATE role admin IDENTIFIED BY admin;
GRANT CREATE TABLE TO admin;
GRANT CREATE INDEX TO admin;
GRANT CREATE TRIGGER TO admin;
GRANT CREATE VIEW TO admin;
GRANT CREATE PROCEDURE TO admin;
GRANT GRANT ANY OBJECT PRIVILEGE TO admin;
GRANT ALTER ANY TABLE TO admin;
GRANT CREATE SEQUENCE TO admin;
GRANT CREATE ROLE TO admin;
ALTER USER reki QUOTA UNLIMITED ON USERS;
GRANT ADMIN TO reki;
GRANT CONNECT TO reki;
GRANT CREATE SESSION TO reki;

--login ke reki
conn reki@steppa_store/reki



--role admin
set role admin identified by admin;




--create table
CREATE TABLE products (
    product_id VARCHAR2(10) PRIMARY KEY,
    product_name VARCHAR2(100) NOT NULL,
    product_description VARCHAR2(255),
    product_category VARCHAR2(50) NOT NULL,
    product_size VARCHAR2(2) NOT NULL,
    product_gender VARCHAR2(6) NOT NULL,
    product_image VARCHAR2(255) NOT NULL,
    stok_qty NUMBER NOT NULL,
    price NUMBER NOT NULL,
    last_update DATE DEFAULT SYSDATE,
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE TABLE sales (
    sale_id VARCHAR2(10) PRIMARY KEY,
    sale_channel VARCHAR2(50) NOT NULL,
    sale_date DATE NOT NULL,
    total NUMBER NOT NULL,
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE TABLE sale_items (
    sale_item_id VARCHAR2(10) PRIMARY KEY,
    sale_id VARCHAR2(10) NOT NULL REFERENCES sales(sale_id),
    product_id VARCHAR2(10) NOT NULL REFERENCES products(product_id),
    quantity NUMBER NOT NULL,
    price NUMBER NOT NULL,
    subtotal NUMBER NOT NULL,
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE TABLE customers (
    customer_id VARCHAR2(10) PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100),
    phone_number VARCHAR2(15),
    password VARCHAR2(20),
    address VARCHAR2(200),
    city VARCHAR2(50),
    country VARCHAR2(50),
    zip_code VARCHAR2(10),
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE TABLE carts (
    cart_id VARCHAR2(10) PRIMARY KEY,
    customer_id VARCHAR2(10) NOT NULL REFERENCES customers(customer_id),
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE TABLE cart_items (
    cart_item_id VARCHAR2(10) PRIMARY KEY,
    cart_id VARCHAR2(10) NOT NULL REFERENCES carts(cart_id),
    product_id VARCHAR2(10) NOT NULL REFERENCES products(product_id),
    quantity NUMBER NOT NULL CHECK (quantity > 0),
    price NUMBER NOT NULL,
    status VARCHAR2(20) DEFAULT 'active',
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE TABLE revenue_reports (
    report_id VARCHAR2(10) PRIMARY KEY,
    report_period DATE NOT NULL,
    total_revenue NUMBER NOT NULL,
    total_expenses NUMBER NOT NULL,
    net_profit NUMBER NOT NULL,
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);





CREATE SEQUENCE seq_products_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_products
BEFORE INSERT ON products
FOR EACH ROW
BEGIN
    :NEW.product_id := 'PRO' || LPAD(seq_products_id.NEXTVAL, 4, '0');
END;
/



CREATE SEQUENCE seq_sales_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_sales
BEFORE INSERT ON sales
FOR EACH ROW
BEGIN
    :NEW.sale_id := 'SLS' || LPAD(seq_sales_id.NEXTVAL, 4, '0');
END;
/



CREATE SEQUENCE seq_sale_items_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_sale_items
BEFORE INSERT ON sale_items
FOR EACH ROW
BEGIN
    :NEW.sale_item_id := 'SLI' || LPAD(seq_sale_items_id.NEXTVAL, 4, '0');
END;
/



CREATE SEQUENCE seq_customers_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_customers
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    :NEW.customer_id := 'CUS' || LPAD(seq_customers_id.NEXTVAL, 4, '0');
END;
/



CREATE SEQUENCE seq_carts_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_carts
BEFORE INSERT ON carts
FOR EACH ROW
BEGIN
    :NEW.cart_id := 'CRT' || LPAD(seq_carts_id.NEXTVAL, 4, '0');
END;
/


CREATE SEQUENCE seq_cart_items_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_cart_items
BEFORE INSERT ON cart_items
FOR EACH ROW
BEGIN
    :NEW.cart_item_id := 'CIT' || LPAD(seq_cart_items_id.NEXTVAL, 4, '0');
END;
/


CREATE SEQUENCE seq_revenue_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_revenue
BEFORE INSERT ON revenue_reports
FOR EACH ROW
BEGIN
    :NEW.report_id := 'REV' || LPAD(seq_revenue_id.NEXTVAL, 4, '0');
END;
/

CREATE OR REPLACE PROCEDURE add_to_cart(
    p_cart_id IN VARCHAR2,
    p_product_id IN VARCHAR2,
    p_quantity IN NUMBER,
    p_price IN NUMBER
) AS
BEGIN
    DECLARE
        v_existing_quantity NUMBER;
    BEGIN
        SELECT quantity
        INTO v_existing_quantity
        FROM cart_items
        WHERE cart_id = p_cart_id
          AND product_id = p_product_id
          AND status = 'active';
        
        IF v_existing_quantity IS NOT NULL THEN
            UPDATE cart_items
            SET quantity = v_existing_quantity + p_quantity
            WHERE cart_id = p_cart_id
              AND product_id = p_product_id
              AND status = 'active';
        ELSE
            INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
            VALUES (p_cart_id, p_product_id, p_quantity, p_price, 'active');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
            VALUES (p_cart_id, p_product_id, p_quantity, p_price, 'active');
    END;
END;
/


CREATE OR REPLACE PROCEDURE update_cart_item_quantity(
    p_cart_item_id IN VARCHAR2,
    p_quantity IN NUMBER
) AS
BEGIN
    UPDATE cart_items
    SET quantity = p_quantity
    WHERE cart_item_id = p_cart_item_id
      AND status = 'active';
    
    IF p_quantity <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Quantity must be greater than zero');
    END IF;
END;
/


CREATE OR REPLACE PROCEDURE remove_item_from_cart(
    p_cart_item_id IN VARCHAR2
) AS
BEGIN
    UPDATE cart_items
    SET deleted_at = SYSDATE 
    WHERE cart_item_id = p_cart_item_id
      AND status = 'active';
END;
/


CREATE OR REPLACE PROCEDURE checkout(
    p_cart_id IN VARCHAR2
) AS
    v_sale_id VARCHAR2(10);
    v_total NUMBER := 0;
BEGIN
    INSERT INTO sales (sale_id, sale_channel, sale_date, total)
    VALUES (v_sale_id, 'Online', SYSDATE, 0)
    RETURNING sale_id INTO v_sale_id;

    FOR r IN (SELECT ci.product_id, ci.quantity, ci.price
              FROM cart_items ci
              WHERE ci.cart_id = p_cart_id AND ci.status = 'active') LOOP
        v_total := v_total + (r.quantity * r.price);

        INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
        VALUES (v_sale_id, r.product_id, r.quantity, r.price, r.quantity * r.price);
    END LOOP;

    UPDATE sales
    SET total = v_total
    WHERE sale_id = v_sale_id;

    UPDATE cart_items
    SET status = 'purchased'
    WHERE cart_id = p_cart_id AND status = 'active';
END;
/


CREATE OR REPLACE PROCEDURE calculate_cart_subtotal(
    p_cart_id IN VARCHAR2,
    p_total OUT NUMBER
) AS
BEGIN
    p_total := 0;

    FOR r IN (SELECT ci.quantity, ci.price
              FROM cart_items ci
              WHERE ci.cart_id = p_cart_id AND ci.status = 'active') LOOP
        p_total := p_total + (r.quantity * r.price);
    END LOOP;
END;
/

CREATE OR REPLACE TRIGGER before_insert_sale_item
BEFORE INSERT ON sale_items
FOR EACH ROW
BEGIN
    :NEW.subtotal := :NEW.quantity * :NEW.price;
END;
/

CREATE OR REPLACE TRIGGER after_checkout_update_stock
AFTER INSERT ON sale_items
FOR EACH ROW
DECLARE
    v_stock NUMBER;
BEGIN
    SELECT stok_qty
    INTO v_stock
    FROM products
    WHERE product_id = :NEW.product_id;

    IF v_stock - :NEW.quantity < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Insufficient stock for product: ' || :NEW.product_id);
    END IF;

    UPDATE products
    SET stok_qty = stok_qty - :NEW.quantity
    WHERE product_id = :NEW.product_id;
END;
/


CREATE OR REPLACE PROCEDURE offline_transaction( 
    p_customer_id IN VARCHAR2,
    p_sale_channel IN VARCHAR2,
    p_products IN SYS.ODCIVARCHAR2LIST,
    p_quantities IN SYS.ODCINUMBERLIST,
    p_prices IN SYS.ODCINUMBERLIST,
    p_total OUT NUMBER
) AS
    v_sale_id VARCHAR2(10);
    v_cart_id VARCHAR2(10);
    v_total NUMBER := 0;
    v_stok_qty NUMBER;
BEGIN
    SELECT cart_id
    INTO v_cart_id
    FROM carts
    WHERE customer_id = p_customer_id;

    INSERT INTO sales (sale_channel, sale_date, total)
    VALUES (p_sale_channel, SYSDATE, 0)
    RETURNING sale_id INTO v_sale_id;

    FOR i IN 1 .. p_products.COUNT LOOP
        SELECT stok_qty INTO v_stok_qty FROM products WHERE product_id = p_products(i);
        IF v_stok_qty < p_quantities(i) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Insufficient stock for product: ' || p_products(i));
        END IF;

        INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
        VALUES (v_sale_id, p_products(i), p_quantities(i), p_prices(i), p_quantities(i) * p_prices(i));

        UPDATE products
        SET stok_qty = stok_qty - p_quantities(i)
        WHERE product_id = p_products(i);

        INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
        VALUES (v_cart_id, p_products(i), p_quantities(i), p_prices(i), 'purchased');

        v_total := v_total + (p_quantities(i) * p_prices(i));
    END LOOP;

    UPDATE sales
    SET total = v_total
    WHERE sale_id = v_sale_id;

    p_total := v_total;
END;
/

-- Insert dummy data into products
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 1', 'Description 1', 'Category 1', '40', 'Unisex', 'image1.jpg', 100, 50);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 1', 'Description 1', 'Category 1', '41', 'Unisex', 'image1.jpg', 100, 50);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 1', 'Description 1', 'Category 1', '42', 'Unisex', 'image1.jpg', 100, 50);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 1', 'Description 1', 'Category 1', '43', 'Unisex', 'image1.jpg', 100, 50);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 1', 'Description 1', 'Category 1', '44', 'Unisex', 'image1.jpg', 100, 50);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 2', 'Description 2', 'Category 2', '40', 'Male', 'image2.jpg', 200, 60);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 2', 'Description 2', 'Category 2', '41', 'Male', 'image2.jpg', 200, 60);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 2', 'Description 2', 'Category 2', '42', 'Male', 'image2.jpg', 200, 60);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 2', 'Description 2', 'Category 2', '43', 'Male', 'image2.jpg', 200, 60);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 2', 'Description 2', 'Category 2', '44', 'Male', 'image2.jpg', 200, 60);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 3', 'Description 3', 'Category 3', '40', 'Female', 'image3.jpg', 150, 70);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 3', 'Description 3', 'Category 3', '41', 'Female', 'image3.jpg', 150, 70);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 3', 'Description 3', 'Category 3', '42', 'Female', 'image3.jpg', 150, 70);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 3', 'Description 3', 'Category 3', '43', 'Female', 'image3.jpg', 150, 70);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 3', 'Description 3', 'Category 3', '44', 'Female', 'image3.jpg', 150, 70);

-- Insert dummy data into sales
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Online', SYSDATE, 100);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Offline', SYSDATE, 200);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Online', SYSDATE, 300);

-- Insert dummy data into sale_items
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0001', 'PRO0001', 2, 50, 100);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0001', 'PRO0002', 1, 60, 60);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0002', 'PRO0002', 3, 60, 180);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0002', 'PRO0003', 1, 70, 70);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0003', 'PRO0001', 1, 50, 50);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0003', 'PRO0003', 2, 70, 140);

-- Insert dummy data into customers
INSERT INTO customers (name, email, phone_number, password, address, city, country, zip_code)
VALUES ('Customer 1', 'customer1@example.com', '1234567890', 'password1', 'Address 1', 'City 1', 'Country 1', '12345');
INSERT INTO customers (name, email, phone_number, password, address, city, country, zip_code)
VALUES ('Customer 2', 'customer2@example.com', '0987654321', 'password2', 'Address 2', 'City 2', 'Country 2', '54321');
INSERT INTO customers (name, email, phone_number, password, address, city, country, zip_code)
VALUES ('Customer 3', 'customer3@example.com', '1122334455', 'password3', 'Address 3', 'City 3', 'Country 3', '67890');

-- Insert dummy data into carts
INSERT INTO carts (customer_id)
VALUES ('CUS0001');
INSERT INTO carts (customer_id)
VALUES ('CUS0002');
INSERT INTO carts (customer_id)
VALUES ('CUS0003');

-- Insert dummy data into cart_items
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0001', 'PRO0001', 2, 50, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0001', 'PRO0002', 1, 60, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0002', 'PRO0002', 3, 60, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0002', 'PRO0003', 1, 70, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0003', 'PRO0001', 1, 50, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0003', 'PRO0003', 2, 70, 'active');

-- Insert dummy data into revenue_reports
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 1000, 500, 500);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 2000, 1000, 1000);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 3000, 1500, 1500);

CREATE OR REPLACE TRIGGER trg_update_trans_status
AFTER UPDATE OF transaction_status ON transactions
FOR EACH ROW
WHEN (NEW.transaction_status = 'Completed')
DECLARE
    v_material_id VARCHAR2(10);
    v_quantity NUMBER;
    CURSOR transaction_details_cursor IS
        SELECT material_id, quantity
        FROM transaction_detail
        WHERE transaction_id = :NEW.transaction_id;
BEGIN
    FOR detail IN transaction_details_cursor LOOP
        v_material_id := detail.material_id;
        v_quantity := detail.quantity;

        UPDATE raw_materials
        SET stock_quantity = stock_quantity + v_quantity,
            last_update = SYSDATE
        WHERE material_id = v_material_id;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE update_transaction_status (
    p_transaction_id IN VARCHAR2,
    p_new_status IN VARCHAR2
) AS
    v_current_status VARCHAR2(20);
BEGIN
    IF p_new_status NOT IN ('Pending', 'Completed') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid transaction status.');
    END IF;

    SELECT transaction_status
    INTO v_current_status
    FROM transactions
    WHERE transaction_id = p_transaction_id;

    IF v_current_status = 'Completed' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Transaction already completed, cannot be updated further.');
    END IF;

    UPDATE transactions
    SET transaction_status = p_new_status,
        transaction_date = SYSDATE 
    WHERE transaction_id = p_transaction_id;

    COMMIT;
END;
/
