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


-- Insert dummy data into products
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 1', 'Description 1', 'Category 1', '40', 'Male', 'image1.jpg', 100, 70);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 1', 'Description 1', 'Category 1', '41', 'Male', 'image1.jpg', 200, 70);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 1', 'Description 1', 'Category 1', '42', 'Male', 'image1.jpg', 150, 70);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 4', 'Description 4', 'Category 4', 'M', 'Female', 'image4.jpg', 120, 80);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 5', 'Description 5', 'Category 5', 'L', 'Male', 'image5.jpg', 130, 90);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 6', 'Description 6', 'Category 6', 'S', 'Female', 'image6.jpg', 140, 100);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 7', 'Description 7', 'Category 7', 'M', 'Male', 'image7.jpg', 110, 110);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 8', 'Description 8', 'Category 8', 'L', 'Female', 'image8.jpg', 160, 120);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 9', 'Description 9', 'Category 9', 'S', 'Male', 'image9.jpg', 170, 130);
INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
VALUES ('Product 10', 'Description 10', 'Category 10', 'M', 'Female', 'image10.jpg', 180, 140);

-- Insert dummy data into sales
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Online', SYSDATE, 500);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Offline', SYSDATE, 600);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Online', SYSDATE, 700);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Offline', SYSDATE, 800);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Online', SYSDATE, 900);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Offline', SYSDATE, 1000);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Online', SYSDATE, 1100);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Offline', SYSDATE, 1200);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Online', SYSDATE, 1300);
INSERT INTO sales (sale_channel, sale_date, total)
VALUES ('Offline', SYSDATE, 1400);

-- Insert dummy data into sale_items
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0001', 'PRO0001', 2, 50, 100);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0002', 'PRO0002', 3, 60, 180);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0003', 'PRO0003', 4, 70, 280);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0004', 'PRO0004', 5, 80, 400);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0005', 'PRO0005', 6, 90, 540);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0006', 'PRO0006', 7, 100, 700);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0007', 'PRO0007', 8, 110, 880);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0008', 'PRO0008', 9, 120, 1080);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0009', 'PRO0009', 10, 130, 1300);
INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
VALUES ('SLS0010', 'PRO0010', 11, 140, 1540);

-- Insert dummy data into customers
INSERT INTO customers (name, email, phone_number, address, city, country, zip_code)
VALUES ('Customer 1', 'customer1@example.com', '1234567890', 'Address 1', 'City 1', 'Country 1', '12345');
INSERT INTO customers (name, email, phone_number, address, city, country, zip_code)
VALUES ('Customer 2', 'customer2@example.com', '0987654321', 'Address 2', 'City 2', 'Country 2', '54321');
INSERT INTO customers (name, email, phone_number, address, city, country, zip_code)
VALUES ('Customer 3', 'customer3@example.com', '1122334455', 'Address 3', 'City 3', 'Country 3', '67890');
INSERT INTO customers (name, email, phone_number, address, city, country, zip_code)
VALUES ('Customer 4', 'customer4@example.com', '5566778899', 'Address 4', 'City 4', 'Country 4', '09876');
INSERT INTO customers (name, email, phone_number, address, city, country, zip_code)
VALUES ('Customer 5', 'customer5@example.com', '6677889900', 'Address 5', 'City 5', 'Country 5', '11223');
INSERT INTO customers (name, email, phone_number, address, city, country, zip_code)
VALUES ('Customer 6', 'customer6@example.com', '7788990011', 'Address 6', 'City 6', 'Country 6', '33445');
INSERT INTO customers (name, email, phone_number, address, city, country, zip_code)
VALUES ('Customer 7', 'customer7@example.com', '8899001122', 'Address 7', 'City 7', 'Country 7', '55667');
INSERT INTO customers (name, email, phone_number, address, city, country, zip_code)
VALUES ('Customer 8', 'customer8@example.com', '9900112233', 'Address 8', 'City 8', 'Country 8', '77889');
INSERT INTO customers (name, email, phone_number, address, city, country, zip_code)
VALUES ('Customer 9', 'customer9@example.com', '0011223344', 'Address 9', 'City 9', 'Country 9', '99001');
INSERT INTO customers (name, email, phone_number, address, city, country, zip_code)
VALUES ('Customer 10', 'customer10@example.com', '1122334455', 'Address 10', 'City 10', 'Country 10', '12345');

-- Insert dummy data into carts
INSERT INTO carts (customer_id)
VALUES ('CUS0001');
INSERT INTO carts (customer_id)
VALUES ('CUS0002');
INSERT INTO carts (customer_id)
VALUES ('CUS0003');
INSERT INTO carts (customer_id)
VALUES ('CUS0004');
INSERT INTO carts (customer_id)
VALUES ('CUS0005');
INSERT INTO carts (customer_id)
VALUES ('CUS0006');
INSERT INTO carts (customer_id)
VALUES ('CUS0007');
INSERT INTO carts (customer_id)
VALUES ('CUS0008');
INSERT INTO carts (customer_id)
VALUES ('CUS0009');
INSERT INTO carts (customer_id)
VALUES ('CUS0010');

-- Insert dummy data into cart_items
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0001', 'PRO0001', 2, 50, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0002', 'PRO0002', 3, 60, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0003', 'PRO0003', 4, 70, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0004', 'PRO0004', 5, 80, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0005', 'PRO0005', 6, 90, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0006', 'PRO0006', 7, 100, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0007', 'PRO0007', 8, 110, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0008', 'PRO0008', 9, 120, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0009', 'PRO0009', 10, 130, 'active');
INSERT INTO cart_items (cart_id, product_id, quantity, price, status)
VALUES ('CRT0010', 'PRO0010', 11, 140, 'active');

-- Insert dummy data into revenue_reports
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 1000, 500, 500);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 2000, 1000, 1000);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 3000, 1500, 1500);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 4000, 2000, 2000);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 5000, 2500, 2500);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 6000, 3000, 3000);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 7000, 3500, 3500);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 8000, 4000, 4000);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 9000, 4500, 4500);
INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
VALUES (SYSDATE, 10000, 5000, 5000);
