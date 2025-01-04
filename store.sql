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
set role admin identified by admin




--create table
CREATE TABLE products (
    product_id VARCHAR2(10) PRIMARY KEY,
    product_name VARCHAR2(100) NOT NULL,
    product_description VARCHAR2(255),
    product_category VARCHAR2(50) NOT NULL,
    stok_qty NUMBER NOT NULL,
    price NUMBER NOT NULL,
    is_deleted CHAR(1) DEFAULT 'N'
);

CREATE TABLE sales (
    sale_id VARCHAR2(10) PRIMARY KEY,
    sale_channel VARCHAR2(50) NOT NULL,
    sale_date DATE NOT NULL,
    total NUMBER NOT NULL,
    is_deleted CHAR(1) DEFAULT 'N'
);

CREATE TABLE sale_items (
    sale_item_id VARCHAR2(10) PRIMARY KEY,
    sale_id VARCHAR2(10) NOT NULL REFERENCES sales(sale_id),
    product_id VARCHAR2(10) NOT NULL REFERENCES products(product_id),
    quantity NUMBER NOT NULL,
    price NUMBER NOT NULL,
    subtotal NUMBER NOT NULL,
    is_deleted CHAR(1) DEFAULT 'N'
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
    is_deleted CHAR(1) DEFAULT 'N'
);

CREATE TABLE carts (
    cart_id VARCHAR2(10) PRIMARY KEY,
    customer_id VARCHAR2(10) NOT NULL REFERENCES customers(customer_id),
    is_deleted CHAR(1) DEFAULT 'N'
);

CREATE TABLE cart_items (
    cart_item_id VARCHAR2(10) PRIMARY KEY,
    cart_id VARCHAR2(10) NOT NULL REFERENCES carts(cart_id),
    product_id VARCHAR2(10) NOT NULL REFERENCES products(product_id),
    quantity NUMBER NOT NULL CHECK (quantity > 0),
    price NUMBER NOT NULL,
    status VARCHAR2(20) DEFAULT 'active',
    added_at DATE DEFAULT SYSDATE,
    is_deleted CHAR(1) DEFAULT 'N'
);

CREATE TABLE revenue_reports (
    report_id VARCHAR2(10) PRIMARY KEY,
    report_period DATE NOT NULL,
    total_revenue NUMBER NOT NULL,
    total_expenses NUMBER NOT NULL,
    net_profit NUMBER NOT NULL,
    is_deleted CHAR(1) DEFAULT 'N'
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
    :NEW.cart_id := 'CIT' || LPAD(seq_cart_items_id.NEXTVAL, 4, '0');
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
