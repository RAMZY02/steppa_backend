-- 1. create user superadmin
CREATE USER reki IDENTIFIED BY reki;
CREATE role superadmin IDENTIFIED BY superadmin;
GRANT CREATE TABLE TO superadmin;
GRANT CREATE INDEX TO superadmin;
GRANT CREATE TRIGGER TO superadmin;
GRANT CREATE VIEW TO superadmin;
GRANT CREATE PROCEDURE TO superadmin;
GRANT GRANT ANY OBJECT PRIVILEGE TO superadmin;
GRANT ALTER ANY TABLE TO superadmin;
GRANT CREATE SEQUENCE TO superadmin;
GRANT CREATE ROLE TO superadmin;
GRANT CREATE DATABASE LINK TO superadmin;
GRANT CREATE MATERIALIZED VIEW TO superadmin;
GRANT CREATE JOB TO superadmin;
GRANT MANAGE SCHEDULER TO superadmin;
ALTER USER reki QUOTA UNLIMITED ON USERS;
GRANT superadmin TO reki;
GRANT CONNECT TO reki;
GRANT CREATE SESSION TO reki;

-- Create roles
CREATE ROLE admin;
CREATE ROLE manager;
CREATE ROLE cashier;
CREATE ROLE inventory;

-- Grant privileges to admin
GRANT SELECT, INSERT, UPDATE, DELETE ON products TO admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON sales TO admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON sale_items TO admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON customers TO admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON carts TO admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON cart_items TO admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON revenue_reports TO admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON log_store TO admin;

CREATE USER vapo IDENTIFIED BY vapo;
GRANT admin TO vapo;

-- Grant privileges to manager
GRANT SELECT, INSERT, UPDATE, DELETE ON products TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON sales TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON sale_items TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON customers TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON carts TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON cart_items TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON revenue_reports TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON log_store TO manager;

create user baki identified by baki;
grant manager to baki;

-- Grant privileges to cashier
GRANT SELECT, INSERT, UPDATE ON sales TO cashier;
GRANT SELECT, INSERT, UPDATE ON sale_items TO cashier;
GRANT SELECT, INSERT, UPDATE ON customers TO cashier;
GRANT SELECT, INSERT, UPDATE ON carts TO cashier;
GRANT SELECT, INSERT, UPDATE ON cart_items TO cashier;

CREATE USER noko IDENTIFIED BY noko;
GRANT cashier TO noko;

-- Grant privileges to inventory
GRANT SELECT, INSERT, UPDATE, DELETE ON products TO inventory;
GRANT SELECT, INSERT, UPDATE, DELETE ON log_store TO inventory;

CREATE USER bawa IDENTIFIED BY bawa;
GRANT inventory TO bawa;

--login ke reki
conn reki@steppa_store/reki



--role superadmin
set role superadmin identified by superadmin;

drop table products cascade constraints;
drop table sales cascade constraints;
drop table sale_items cascade constraints;
drop table customers cascade constraints;
drop table carts cascade constraints;
drop table cart_items cascade constraints;
drop table revenue_reports cascade constraints;
drop table users cascade constraints;
drop table log_store cascade constraints;



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
    password VARCHAR2(60),
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

CREATE TABLE users (
    user_id VARCHAR2(10) PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    password VARCHAR2(255) NOT NULL,
    full_name VARCHAR2(100),
    email VARCHAR2(100),
    phone_number VARCHAR2(20),
    role VARCHAR2(20) CHECK (role IN ('admin', 'manager', 'cashier', 'inventory')),
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);




DROP SEQUENCE seq_products_id;
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


DROP SEQUENCE seq_sales_id;
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


DROP SEQUENCE seq_sale_items_id;
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


DROP SEQUENCE seq_customers_id;
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


DROP SEQUENCE seq_carts_id;
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

DROP SEQUENCE seq_cart_items_id;
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

DROP SEQUENCE seq_revenue_id;
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

DROP SEQUENCE seq_users_id;
CREATE SEQUENCE seq_users_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_users
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    :NEW.user_id := 'USR' || LPAD(seq_users_id.NEXTVAL, 4, '0');
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
        v_existing_price NUMBER;
    BEGIN
        SELECT quantity, price
        INTO v_existing_quantity, v_existing_price
        FROM cart_items
        WHERE cart_id = p_cart_id
          AND product_id = p_product_id
          AND status = 'active'
          AND deleted_at IS NULL;
        
        IF v_existing_quantity IS NOT NULL THEN
            UPDATE cart_items
            SET quantity = v_existing_quantity + p_quantity,
                price = v_existing_price + (p_quantity * p_price)
            WHERE cart_id = p_cart_id
              AND product_id = p_product_id
              AND status = 'active';
        ELSE
            INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
            VALUES (p_cart_id, p_product_id, p_quantity, p_quantity*p_price, 'active');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
            VALUES (p_cart_id, p_product_id, p_quantity, p_quantity*p_price, 'active');
    END;
END;
/


CREATE OR REPLACE PROCEDURE update_cart_item_quantity(
    p_cart_item_id IN VARCHAR2,
    p_quantity IN NUMBER
) AS
BEGIN
    UPDATE cart_items
    SET quantity = p_quantity,
        price = p_quantity * (price / quantity)
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
        p_total := p_total + r.price;
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




CREATE OR REPLACE PROCEDURE offline_transaction_member(
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


CREATE OR REPLACE PROCEDURE offline_transaction_non_member(
    p_sale_channel IN VARCHAR2,
    p_products IN SYS.ODCIVARCHAR2LIST,
    p_quantities IN SYS.ODCINUMBERLIST,
    p_prices IN SYS.ODCINUMBERLIST,
    p_total OUT NUMBER
) AS
    v_sale_id VARCHAR2(10);
    v_total NUMBER := 0;
    v_stok_qty NUMBER;
BEGIN
    FOR i IN 1 .. p_products.COUNT LOOP
        SELECT stok_qty INTO v_stok_qty FROM products WHERE product_id = p_products(i);
        IF v_stok_qty < p_quantities(i) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Insufficient stock for product: ' || p_products(i));
        END IF;
    END LOOP;
    
    INSERT INTO sales (sale_channel, sale_date, total)
    VALUES (p_sale_channel, SYSDATE, 0)
    RETURNING sale_id INTO v_sale_id;

    FOR i IN 1 .. p_products.COUNT LOOP
        INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
        VALUES (v_sale_id, p_products(i), p_quantities(i), p_prices(i), p_quantities(i) * p_prices(i));

        UPDATE products
        SET stok_qty = stok_qty - p_quantities(i)
        WHERE product_id = p_products(i);

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
VALUES ('Nike Air Max', 'High-quality running shoes', 'Running Shoes', '40', 'male', 'https://drive.google.com/file/d/1yFhbQqkKLMc4Gbe3X2NxBsrn9nnmptwu/view?usp=sharing', 50, 150);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Nike Air Max', 'High-quality running shoes', 'Running Shoes', '41', 'male', 'https://drive.google.com/file/d/1yFhbQqkKLMc4Gbe3X2NxBsrn9nnmptwu/view?usp=sharing', 50, 150);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Nike Air Max', 'High-quality running shoes', 'Running Shoes', '42', 'male', 'https://drive.google.com/file/d/1yFhbQqkKLMc4Gbe3X2NxBsrn9nnmptwu/view?usp=sharing', 50, 150);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Nike Air Max', 'High-quality running shoes', 'Running Shoes', '43', 'male', 'https://drive.google.com/file/d/1yFhbQqkKLMc4Gbe3X2NxBsrn9nnmptwu/view?usp=sharing', 50, 150);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Nike Air Max', 'High-quality running shoes', 'Running Shoes', '44', 'male', 'https://drive.google.com/file/d/1yFhbQqkKLMc4Gbe3X2NxBsrn9nnmptwu/view?usp=sharing', 50, 150);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Adidas Ultraboost', 'Comfortable and stylish', 'Running Shoes', '40', 'female', 'https://drive.google.com/file/d/1j8LjNWCGye8-7YikgrXN5JKpjMtK3jGj/view?usp=sharing', 30, 180);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Adidas Ultraboost', 'Comfortable and stylish', 'Running Shoes', '41', 'female', 'https://drive.google.com/file/d/1j8LjNWCGye8-7YikgrXN5JKpjMtK3jGj/view?usp=sharing', 30, 180);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Adidas Ultraboost', 'Comfortable and stylish', 'Running Shoes', '42', 'female', 'https://drive.google.com/file/d/1j8LjNWCGye8-7YikgrXN5JKpjMtK3jGj/view?usp=sharing', 30, 180);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Adidas Ultraboost', 'Comfortable and stylish', 'Running Shoes', '43', 'female', 'https://drive.google.com/file/d/1j8LjNWCGye8-7YikgrXN5JKpjMtK3jGj/view?usp=sharing', 30, 180);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Adidas Ultraboost', 'Comfortable and stylish', 'Running Shoes', '44', 'female', 'https://drive.google.com/file/d/1j8LjNWCGye8-7YikgrXN5JKpjMtK3jGj/view?usp=sharing', 30, 180);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Puma Sneakers', 'Trendy streetwear shoes', 'Sneakers', '40', 'male', 'https://drive.google.com/file/d/179psE65OseXDL-OxcnJJgTnxlxImQp7l/view?usp=sharing', 20, 90);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Puma Sneakers', 'Trendy streetwear shoes', 'Sneakers', '41', 'male', 'https://drive.google.com/file/d/179psE65OseXDL-OxcnJJgTnxlxImQp7l/view?usp=sharing', 20, 90);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Puma Sneakers', 'Trendy streetwear shoes', 'Sneakers', '42', 'male', 'https://drive.google.com/file/d/179psE65OseXDL-OxcnJJgTnxlxImQp7l/view?usp=sharing', 20, 90);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Puma Sneakers', 'Trendy streetwear shoes', 'Sneakers', '43', 'male', 'https://drive.google.com/file/d/179psE65OseXDL-OxcnJJgTnxlxImQp7l/view?usp=sharing', 20, 90);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Puma Sneakers', 'Trendy streetwear shoes', 'Sneakers', '44', 'male', 'https://drive.google.com/file/d/179psE65OseXDL-OxcnJJgTnxlxImQp7l/view?usp=sharing', 20, 90);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Reebok Training', 'Durable and lightweight', 'Training Shoes', '40', 'female', 'https://drive.google.com/file/d/13qMsSURIJ28tspj89LbxK8aCW8Nd7dNp/view?usp=sharing', 25, 120);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Reebok Training', 'Durable and lightweight', 'Training Shoes', '41', 'female', 'https://drive.google.com/file/d/13qMsSURIJ28tspj89LbxK8aCW8Nd7dNp/view?usp=sharing', 25, 120);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Reebok Training', 'Durable and lightweight', 'Training Shoes', '42', 'female', 'https://drive.google.com/file/d/13qMsSURIJ28tspj89LbxK8aCW8Nd7dNp/view?usp=sharing', 25, 120);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Reebok Training', 'Durable and lightweight', 'Training Shoes', '43', 'female', 'https://drive.google.com/file/d/13qMsSURIJ28tspj89LbxK8aCW8Nd7dNp/view?usp=sharing', 25, 120);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Reebok Training', 'Durable and lightweight', 'Training Shoes', '44', 'female', 'https://drive.google.com/file/d/13qMsSURIJ28tspj89LbxK8aCW8Nd7dNp/view?usp=sharing', 25, 120);

-- Insert dummy data into sales
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Online', SYSDATE, 100);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Offline', SYSDATE, 200);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Online', SYSDATE, 300);

-- Insert dummy data into sale_items
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0001', 'PRO0001', 2, 150, 300);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0001', 'PRO0002', 1, 180, 180);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0002', 'PRO0002', 2, 180, 360);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0002', 'PRO0003', 1, 90, 90);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0003', 'PRO0001', 1, 150, 150);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0003', 'PRO0003', 2, 90, 180);

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
VALUES ('CRT0001', 'PRO0001', 2, 150, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0001', 'PRO0002', 1, 180, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0002', 'PRO0002', 3, 180, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0002', 'PRO0003', 1, 90, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0003', 'PRO0001', 1, 150, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0003', 'PRO0003', 2, 90, 'active');

-- Insert dummy data into revenue_reports
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 1000, 500, 500);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 2000, 1000, 1000);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 3000, 1500, 1500);


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


-- Sequence untuk log
CREATE SEQUENCE log_store_seq
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

-- Tabel log untuk menyimpan perubahan
CREATE TABLE log_store (
    log_id INT PRIMARY KEY,
    action_type CHAR(1), 
    table_name VARCHAR2(50),
    action_details VARCHAR2(255),
    action_time DATE DEFAULT SYSDATE,
    action_user VARCHAR2(50)
);

-- Trigger untuk produk
CREATE OR REPLACE TRIGGER trg_log_products
AFTER INSERT OR UPDATE OR DELETE ON products
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(1000);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'I', 'products', 'Inserted product: ' || :NEW.product_name, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.product_id || ' ';

        IF :OLD.product_name != :NEW.product_name THEN
            v_action_details := v_action_details || 'Product name changed from ' || :OLD.product_name || ' to ' || :NEW.product_name || ', ';
        END IF;
        IF :OLD.product_description != :NEW.product_description THEN
            v_action_details := v_action_details || 'Product description changed from ' || :OLD.product_description || ' to ' || :NEW.product_description || ', ';
        END IF;
        IF :OLD.product_category != :NEW.product_category THEN
            v_action_details := v_action_details || 'Product category changed from ' || :OLD.product_category || ' to ' || :NEW.product_category || ', ';
        END IF;
        IF :OLD.product_size != :NEW.product_size THEN
            v_action_details := v_action_details || 'Product size changed from ' || :OLD.product_size || ' to ' || :NEW.product_size || ', ';
        END IF;
        IF :OLD.product_gender != :NEW.product_gender THEN
            v_action_details := v_action_details || 'Product gender changed from ' || :OLD.product_gender || ' to ' || :NEW.product_gender || ', ';
        END IF;
        IF :OLD.product_image != :NEW.product_image THEN
            v_action_details := v_action_details || 'Product image changed from ' || :OLD.product_image || ' to ' || :NEW.product_image || ', ';
        END IF;
        IF :OLD.stok_qty != :NEW.stok_qty THEN
            v_action_details := v_action_details || 'Stock quantity changed from ' || :OLD.stok_qty || ' to ' || :NEW.stok_qty || ', ';
        END IF;
        IF :OLD.price != :NEW.price THEN
            v_action_details := v_action_details || 'Price changed from ' || :OLD.price || ' to ' || :NEW.price || ', ';
        END IF;
        IF :OLD.last_update != :NEW.last_update THEN
            v_action_details := v_action_details || 'Last update changed from ' || :OLD.last_update || ' to ' || :NEW.last_update || ', ';
        END IF;
        IF :OLD.created_at != :NEW.created_at THEN
            v_action_details := v_action_details || 'Created At changed from ' || :OLD.created_at || ' to ' || :NEW.created_at || ', ';
        END IF;
        IF :OLD.deleted_at != :NEW.deleted_at THEN
            v_action_details := v_action_details || 'Deleted At changed from ' || :OLD.deleted_at || ' to ' || :NEW.deleted_at || ', ';
        END IF;

        IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, LENGTH(v_action_details) - 1, 2) = ', ' THEN
            v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
        END IF;

        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'U', 'products', v_action_details, v_user);
    ELSIF DELETING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'D', 'products', 'Deleted product: ' || :OLD.product_name, v_user);
    END IF;
END;
/

-- Trigger untuk sales
DROP SEQUENCE seq_sales_id;
CREATE OR REPLACE TRIGGER trg_log_sales
AFTER INSERT OR UPDATE OR DELETE ON sales
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'I', 'sales', 'Inserted sale: ' || :NEW.sale_id, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.sale_id || ' ';

        IF :OLD.sale_channel != :NEW.sale_channel THEN
            v_action_details := v_action_details || 'Sale channel changed from ' || :OLD.sale_channel || ' to ' || :NEW.sale_channel || ', ';
        END IF;
        IF :OLD.sale_date != :NEW.sale_date THEN
            v_action_details := v_action_details || 'Sale date changed from ' || :OLD.sale_date || ' to ' || :NEW.sale_date || ', ';
        END IF;
        IF :OLD.total != :NEW.total THEN
            v_action_details := v_action_details || 'Total sale changed from ' || :OLD.total || ' to ' || :NEW.total || ', ';
        END IF;
        IF :OLD.created_at != :NEW.created_at THEN
            v_action_details := v_action_details || 'Created At changed from ' || :OLD.created_at || ' to ' || :NEW.created_at || ', ';
        END IF;
        IF :OLD.deleted_at != :NEW.deleted_at THEN
            v_action_details := v_action_details || 'Deleted At changed from ' || :OLD.deleted_at || ' to ' || :NEW.deleted_at || ', ';
        END IF;

        IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, LENGTH(v_action_details) - 1, 2) = ', ' THEN
            v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
        END IF;

        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'U', 'sales', v_action_details, v_user);
    ELSIF DELETING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'D', 'sales', 'Deleted sale: ' || :OLD.sale_id, v_user);
    END IF;
END;
/

-- Trigger untuk sale_items
CREATE OR REPLACE TRIGGER trg_log_sale_items
AFTER INSERT OR UPDATE OR DELETE ON sale_items
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'I', 'sale_items', 'Inserted sale item: ' || :NEW.sale_item_id, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.sale_item_id || ' ';

        IF :OLD.sale_id != :NEW.sale_id THEN
            v_action_details := v_action_details || 'Sale ID changed from ' || :OLD.sale_id || ' to ' || :NEW.sale_id || ', ';
        END IF;
        IF :OLD.product_id != :NEW.product_id THEN
            v_action_details := v_action_details || 'Product ID changed from ' || :OLD.product_id || ' to ' || :NEW.product_id || ', ';
        END IF;
        IF :OLD.quantity != :NEW.quantity THEN
            v_action_details := v_action_details || 'Quantity changed from ' || :OLD.quantity || ' to ' || :NEW.quantity || ', ';
        END IF;
        IF :OLD.price != :NEW.price THEN
            v_action_details := v_action_details || 'Price changed from ' || :OLD.price || ' to ' || :NEW.price || ', ';
        END IF;
        IF :OLD.subtotal != :NEW.subtotal THEN
            v_action_details := v_action_details || 'Subtotal changed from ' || :OLD.subtotal || ' to ' || :NEW.subtotal || ', ';
        END IF;
        IF :OLD.created_at != :NEW.created_at THEN
            v_action_details := v_action_details || 'Created At changed from ' || :OLD.created_at || ' to ' || :NEW.created_at || ', ';
        END IF;
        IF :OLD.deleted_at != :NEW.deleted_at THEN
            v_action_details := v_action_details || 'Deleted At changed from ' || :OLD.deleted_at || ' to ' || :NEW.deleted_at || ', ';
        END IF;

        IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, LENGTH(v_action_details) - 1, 2) = ', ' THEN
            v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
        END IF;

        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'U', 'sale_items', v_action_details, v_user);
    ELSIF DELETING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'D', 'sale_items', 'Deleted sale item: ' || :OLD.sale_item_id, v_user);
    END IF;
END;
/

-- Trigger untuk customers
CREATE OR REPLACE TRIGGER trg_log_customers
AFTER INSERT OR UPDATE OR DELETE ON customers
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'I', 'customers', 'Inserted customer: ' || :NEW.name, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.customer_id || ' ';

        IF :OLD.name != :NEW.name THEN
            v_action_details := v_action_details || 'Name changed from ' || :OLD.name || ' to ' || :NEW.name || ', ';
        END IF;
        IF :OLD.email != :NEW.email THEN
            v_action_details := v_action_details || 'Email changed from ' || :OLD.email || ' to ' || :NEW.email || ', ';
        END IF;
        IF :OLD.phone_number != :NEW.phone_number THEN
            v_action_details := v_action_details || 'Phone number changed from ' || :OLD.phone_number || ' to ' || :NEW.phone_number || ', ';
        END IF;
        IF :OLD.password != :NEW.password THEN
            v_action_details := v_action_details || 'Password changed from ' || :OLD.password || ' to ' || :NEW.password || ', ';
        END IF;
        IF :OLD.address != :NEW.address THEN
            v_action_details := v_action_details || 'Address changed from ' || :OLD.address || ' to ' || :NEW.address || ', ';
        END IF;
        IF :OLD.city != :NEW.city THEN
            v_action_details := v_action_details || 'City changed from ' || :OLD.city || ' to ' || :NEW.city || ', ';
        END IF;
        IF :OLD.country != :NEW.country THEN
            v_action_details := v_action_details || 'Country changed from ' || :OLD.country || ' to ' || :NEW.country || ', ';
        END IF;
        IF :OLD.zip_code != :NEW.zip_code THEN
            v_action_details := v_action_details || 'Zip code changed from ' || :OLD.zip_code || ' to ' || :NEW.zip_code || ', ';
        END IF;
        IF :OLD.created_at != :NEW.created_at THEN
            v_action_details := v_action_details || 'Created At changed from ' || :OLD.created_at || ' to ' || :NEW.created_at || ', ';
        END IF;
        IF :OLD.deleted_at != :NEW.deleted_at THEN
            v_action_details := v_action_details || 'Deleted At changed from ' || :OLD.deleted_at || ' to ' || :NEW.deleted_at || ', ';
        END IF;

        IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, LENGTH(v_action_details) - 1, 2) = ', ' THEN
            v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
        END IF;

        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'U', 'customers', v_action_details, v_user);
    ELSIF DELETING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'D', 'customers', 'Deleted customer: ' || :OLD.name, v_user);
    END IF;
END;
/

-- Trigger untuk carts
CREATE OR REPLACE TRIGGER trg_log_carts
AFTER INSERT OR UPDATE OR DELETE ON carts
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'I', 'carts', 'Inserted cart: ' || :NEW.cart_id, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.cart_id || ' ';

        IF :OLD.customer_id != :NEW.customer_id THEN
            v_action_details := v_action_details || 'Customer ID changed from ' || :OLD.customer_id || ' to ' || :NEW.customer_id || ', ';
        END IF;
        IF :OLD.created_at != :NEW.created_at THEN
            v_action_details := v_action_details || 'Created At changed from ' || :OLD.created_at || ' to ' || :NEW.created_at || ', ';
        END IF;
        IF :OLD.deleted_at != :NEW.deleted_at THEN
            v_action_details := v_action_details || 'Deleted At changed from ' || :OLD.deleted_at || ' to ' || :NEW.deleted_at || ', ';
        END IF;

        IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, LENGTH(v_action_details) - 1, 2) = ', ' THEN
            v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
        END IF;

        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'U', 'carts', v_action_details, v_user);
    ELSIF DELETING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'D', 'carts', 'Deleted cart: ' || :OLD.cart_id, v_user);
    END IF;
END;
/

-- Trigger untuk cart_items
CREATE OR REPLACE TRIGGER trg_log_cart_items
AFTER INSERT OR UPDATE OR DELETE ON cart_items
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'I', 'cart_items', 'Inserted cart item: ' || :NEW.cart_item_id, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.cart_item_id || ' ';

        IF :OLD.cart_id != :NEW.cart_id THEN
            v_action_details := v_action_details || 'Cart ID changed from ' || :OLD.cart_id || ' to ' || :NEW.cart_id || ', ';
        END IF;
        IF :OLD.product_id != :NEW.product_id THEN
            v_action_details := v_action_details || 'Product ID changed from ' || :OLD.product_id || ' to ' || :NEW.product_id || ', ';
        END IF;
        IF :OLD.quantity != :NEW.quantity THEN
            v_action_details := v_action_details || 'Quantity changed from ' || :OLD.quantity || ' to ' || :NEW.quantity || ', ';
        END IF;
        IF :OLD.price != :NEW.price THEN
            v_action_details := v_action_details || 'Price changed from ' || :OLD.price || ' to ' || :NEW.price || ', ';
        END IF;
        IF :OLD.status != :NEW.status THEN
            v_action_details := v_action_details || 'Status changed from ' || :OLD.status || ' to ' || :NEW.status || ', ';
        END IF;
        IF :OLD.created_at != :NEW.created_at THEN
            v_action_details := v_action_details || 'Created At changed from ' || :OLD.created_at || ' to ' || :NEW.created_at || ', ';
        END IF;
        IF :OLD.deleted_at != :NEW.deleted_at THEN
            v_action_details := v_action_details || 'Deleted At changed from ' || :OLD.deleted_at || ' to ' || :NEW.deleted_at || ', ';
        END IF;

        IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, LENGTH(v_action_details) - 1, 2) = ', ' THEN
            v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
        END IF;

        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'U', 'cart_items', v_action_details, v_user);
    ELSIF DELETING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'D', 'cart_items', 'Deleted cart item: ' || :OLD.cart_item_id, v_user);
    END IF;
END;
/

-- Trigger untuk revenue_reports
CREATE OR REPLACE TRIGGER trg_log_revenue_reports
AFTER INSERT OR UPDATE OR DELETE ON revenue_reports
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'I', 'revenue_reports', 'Inserted revenue report: ' || :NEW.report_id, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.report_id || ' ';

        IF :OLD.report_period != :NEW.report_period THEN
            v_action_details := v_action_details || 'Report period changed from ' || :OLD.report_period || ' to ' || :NEW.report_period || ', ';
        END IF;
        IF :OLD.total_revenue != :NEW.total_revenue THEN
            v_action_details := v_action_details || 'Total revenue changed from ' || :OLD.total_revenue || ' to ' || :NEW.total_revenue || ', ';
        END IF;
        IF :OLD.total_expenses != :NEW.total_expenses THEN
            v_action_details := v_action_details || 'Total expenses changed from ' || :OLD.total_expenses || ' to ' || :NEW.total_expenses || ', ';
        END IF;
        IF :OLD.net_profit != :NEW.net_profit THEN
            v_action_details := v_action_details || 'Net profit changed from ' || :OLD.net_profit || ' to ' || :NEW.net_profit || ', ';
        END IF;
        IF :OLD.created_at != :NEW.created_at THEN
            v_action_details := v_action_details || 'Created At changed from ' || :OLD.created_at || ' to ' || :NEW.created_at || ', ';
        END IF;
        IF :OLD.deleted_at != :NEW.deleted_at THEN
            v_action_details := v_action_details || 'Deleted At changed from ' || :OLD.deleted_at || ' to ' || :NEW.deleted_at || ', ';
        END IF;

        IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, LENGTH(v_action_details) - 1, 2) = ', ' THEN
            v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
        END IF;

        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'U', 'revenue_reports', v_action_details, v_user);
    ELSIF DELETING THEN
        INSERT INTO log_store (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_store_seq.NEXTVAL, 'D', 'revenue_reports', 'Deleted revenue report: ' || :OLD.report_id, v_user);
    END IF;
END;
/

-- Endpoint to get sale by channel
CREATE OR REPLACE PROCEDURE get_sale_by_channel(
    p_sale_channel IN VARCHAR2,
    p_sales OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_sales FOR
    SELECT * FROM sales
    WHERE sale_channel = p_sale_channel;
END;
/

-- Endpoint to get sale by date
CREATE OR REPLACE PROCEDURE get_sale_by_date(
    p_sale_date IN DATE,
    p_sales OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_sales FOR
    SELECT * FROM sales
    WHERE TRUNC(sale_date) = TO_DATE(p_sale_date, 'YYYY-MM-DD');
END;
/

-- Endpoint to get sale by date range
CREATE OR REPLACE PROCEDURE get_sale_by_date_range(
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_sales OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_sales FOR
    SELECT * FROM sales
    WHERE TRUNC(sale_date) BETWEEN TO_DATE(p_start_date, 'DD-MM-YYYY') AND TO_DATE(p_end_date, 'DD-MM-YYYY');
END;
/

-- Endpoint to get sale item by sale id
CREATE OR REPLACE PROCEDURE get_sale_item_by_sale_id(
    p_sale_id IN VARCHAR2,
    p_sale_items OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_sale_items FOR
    SELECT * FROM sale_items
    WHERE sale_id = p_sale_id;
END;
/

-- Endpoint to get sale item by product id
CREATE OR REPLACE PROCEDURE get_sale_item_by_product_id(
    p_product_id IN VARCHAR2,
    p_sale_items OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_sale_items FOR
    SELECT * FROM sale_items
    WHERE product_id = p_product_id;
END;
/

-- Endpoint to get cart by customer id
CREATE OR REPLACE PROCEDURE get_cart_by_customer_id(
    p_customer_id IN VARCHAR2,
    p_carts OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_carts FOR
    SELECT * FROM carts
    WHERE customer_id = p_customer_id;
END;
/

-- Endpoint to get cart items by cart id
CREATE OR REPLACE PROCEDURE get_cart_items_by_cart_id(
    p_cart_id IN VARCHAR2,
    p_cart_items OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cart_items FOR
    SELECT ci.cart_item_id, ci.cart_id, ci.product_id, ci.quantity, ci.price, ci.status,
           p.product_name, p.product_description, p.product_category, p.product_size, p.product_gender, p.product_image, p.stok_qty, p.price
    FROM cart_items ci
    JOIN products p ON ci.product_id = p.product_id
    WHERE ci.cart_id = p_cart_id AND ci.deleted_at IS NULL;
END;
/

-- Create a database link to connect to the pengepul database
CREATE DATABASE LINK pengepul_dblink
CONNECT TO reti IDENTIFIED BY reti
USING 'steppa_supplier';

-- Test the database link
SELECT * FROM products@pengepul_dblink;

-- Create a database link to connect to the pengepul database
CREATE DATABASE LINK rnd_dblink
CONNECT TO rama IDENTIFIED BY rama
USING 'conrnd';

-- Test the database link
SELECT * FROM products@rnd_dblink;

CREATE OR REPLACE PROCEDURE accept_product_shipment(
    p_shipment_id IN VARCHAR2
) AS
BEGIN
    UPDATE product_shipment@rnd_dblink
    SET shipment_status = 'Delivered'
    WHERE shipment_id = p_shipment_id
    AND shipment_status = 'Shipped';
END;
/


INSERT INTO product_shipment@rnd_dblink(shipment_date, shipment_status)
VALUES (SYSDATE, 'Shipped');
INSERT INTO product_shipment@rnd_dblink(shipment_date, shipment_status)
VALUES (SYSDATE, 'Delivered');
INSERT INTO product_shipment@rnd_dblink(shipment_date, shipment_status)
VALUES (SYSDATE, 'Failed');

  INSERT INTO product_shipment_detail@rnd_dblink (shipment_id, product_id, quantity)
  VALUES ('SHP0006', 'PRO0011', 10);
  INSERT INTO product_shipment_detail@rnd_dblink (shipment_id, product_id, quantity)
  VALUES ('SHP0006', 'PRO0012', 20);
  INSERT INTO product_shipment_detail@rnd_dblink (shipment_id, product_id, quantity)
  VALUES ('SHP0006', 'PRO0013', 30);

  INSERT INTO product_shipment_detail@rnd_dblink (shipment_id, product_id, quantity)
  VALUES ('SHP0002', 'PRO0014', 15);
  INSERT INTO product_shipment_detail@rnd_dblink (shipment_id, product_id, quantity)
  VALUES ('SHP0002', 'PRO0015', 25);
  INSERT INTO product_shipment_detail@rnd_dblink (shipment_id, product_id, quantity)
  VALUES ('SHP0002', 'PRO0016', 35);

  INSERT INTO product_shipment_detail@rnd_dblink (shipment_id, product_id, quantity)
  VALUES ('SHP0003', 'PRO0017', 5);
  INSERT INTO product_shipment_detail@rnd_dblink (shipment_id, product_id, quantity)
  VALUES ('SHP0003', 'PRO0018', 10);
  INSERT INTO product_shipment_detail@rnd_dblink (shipment_id, product_id, quantity)
  

CREATE MATERIALIZED VIEW MV_MATERIAL_DATA
BUILD IMMEDIATE
REFRESH FORCE
ON DEMAND
AS
SELECT material_id, material_name, stock_quantity
FROM raw_materials@db_link_supplier;

BEGIN
   DBMS_SCHEDULER.CREATE_JOB (
      job_name        => 'REFRESH_MV_MATERIAL_DATA',
      job_type        => 'PLSQL_BLOCK',
      job_action      => 'BEGIN DBMS_MVIEW.REFRESH(''MV_MATERIAL_DATA''); END;',
      start_date      => SYSDATE,
      repeat_interval => 'FREQ=DAILY; BYHOUR=12; BYMINUTE=0; BYSECOND=0',
      enabled         => TRUE
   );
END;
/

BEGIN
   DBMS_SCHEDULER.RUN_JOB('REFRESH_MV_MATERIAL_DATA');
END;
/

CREATE MATERIALIZED VIEW MV_MATERIAL_DATA
BUILD IMMEDIATE
REFRESH FORCE
ON DEMAND
AS
SELECT product_id, product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price, last_update
FROM products@rnd_dblink;

BEGIN
   DBMS_SCHEDULER.CREATE_JOB (
      job_name        => 'REFRESH_MV_RND_DATA',
      job_type        => 'PLSQL_BLOCK',
      job_action      => 'BEGIN DBMS_MVIEW.REFRESH(''MV_RND_DATA''); END;',
      start_date      => SYSDATE,
      repeat_interval => 'FREQ=DAILY; BYHOUR=12; BYMINUTE=0; BYSECOND=0',
      enabled         => TRUE
   );
END;
/

BEGIN
   DBMS_SCHEDULER.RUN_JOB('REFRESH_MV_MATERIAL_DATA');
END;
/

CREATE OR REPLACE PROCEDURE sync_products IS
BEGIN
    MERGE INTO products p
    USING (
        SELECT product_id, product_name, product_description, product_category, 
               product_size, product_gender, product_image, price, last_update
        FROM products@rnd_dblink
    ) ps
    ON (p.product_id = ps.product_id)
    WHEN MATCHED THEN
        UPDATE SET 
            p.product_name        = ps.product_name,
            p.product_description = ps.product_description,
            p.product_category    = ps.product_category,
            p.product_size        = ps.product_size,
            p.product_gender      = ps.product_gender,
            p.product_image       = ps.product_image,
            p.price               = ps.price,
            p.last_update         = SYSDATE
        WHERE p.deleted_at IS NULL  
    WHEN NOT MATCHED THEN
        INSERT (
            product_id, product_name, product_description, product_category, 
            product_size, product_gender, product_image, stok_qty, price, last_update, created_at
        )
        VALUES (
            ps.product_id, ps.product_name, ps.product_description, ps.product_category, 
            ps.product_size, ps.product_gender, ps.product_image, 0, ps.price, SYSDATE, SYSDATE
        );
END;
/

BEGIN
    DBMS_SCHEDULER.create_job (
        job_name        => 'sync_products_job',   -- Nama job
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN sync_products; END;',
        start_date      => TRUNC(SYSDATE) + 1 + (12/24), -- Dimulai pada pukul 12 malam esok hari
        repeat_interval => 'FREQ=DAILY; BYHOUR=0; BYMINUTE=0; BYSECOND=0', -- Setiap hari pukul 12:00 malam
        enabled         => TRUE, -- Job diaktifkan
        comments        => 'Job to sync products table every midnight'
    );
END;
/


BEGIN
   DBMS_SCHEDULER.RUN_JOB('sync_products_job');
END;
/