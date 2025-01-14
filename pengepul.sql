-- 1. create user superadmin
CREATE USER reti IDENTIFIED BY reti;
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
GRANT CREATE MATERIALIZED VIEW TO superadmin;
GRANT CREATE JOB TO superadmin;
ALTER USER reti QUOTA UNLIMITED ON USERS;
GRANT superadmin TO reti;
GRANT CONNECT TO reti;
GRANT CREATE DATABASE LINK to superadmin;
GRANT CREATE SESSION TO reti;


--login ke reki
conn reti@steppa_supplier/reti



--role superadmin
set role superadmin identified by superadmin;



drop table suppliers cascade constraints;
drop table raw_materials cascade constraints;
drop table transactions cascade constraints;
drop table transaction_detail cascade constraints;
drop table material_shipment cascade constraints;
drop table material_shipment_detail cascade constraints;
drop table users cascade constraints;
drop table log_supplier cascade constraints;

--create table
CREATE TABLE suppliers (
    supplier_id VARCHAR2(10)  PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    location VARCHAR2(100),
    contact_info VARCHAR2(50),
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE TABLE raw_materials (
    material_id VARCHAR2(10)  PRIMARY KEY,
    material_name VARCHAR2(100) NOT NULL,
    stock_quantity NUMBER NOT NULL CHECK (stock_quantity >= 0),
    supplier_id VARCHAR2(10) REFERENCES suppliers(supplier_id) ON DELETE SET NULL,
    last_update DATE DEFAULT SYSDATE,
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE TABLE transactions (
    transaction_id VARCHAR2(10) PRIMARY KEY,
    transaction_date DATE DEFAULT SYSDATE NOT NULL,
    transaction_status VARCHAR2(20) NOT NULL CHECK (transaction_status IN ('Pending', 'Completed')),
    supplier_id VARCHAR2(10) REFERENCES suppliers(supplier_id) ON DELETE SET NULL,
    remarks VARCHAR2(255),
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE TABLE transaction_detail (
    detail_id VARCHAR2(10) PRIMARY KEY,
    transaction_id VARCHAR2(10) REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    material_id VARCHAR2(10) REFERENCES raw_materials(material_id) ON DELETE CASCADE,
    quantity NUMBER NOT NULL CHECK (quantity > 0),
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE TABLE material_shipment (
    shipment_id VARCHAR2(10) PRIMARY KEY,
    shipment_date DATE DEFAULT SYSDATE NOT NULL,
    shipment_status VARCHAR2(20) NOT NULL CHECK (shipment_status IN ('Shipped', 'Canceled', 'Delivered', 'Failed')),
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE TABLE material_shipment_detail (
    shipment_detail_id VARCHAR2(10) PRIMARY KEY,
    shipment_id VARCHAR2(10) REFERENCES material_shipment(shipment_id) ON DELETE CASCADE,
    material_id VARCHAR2(10) REFERENCES raw_materials(material_id) ON DELETE CASCADE,
    quantity NUMBER NOT NULL CHECK (quantity > 0),
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
    role VARCHAR2(20) CHECK (role IN ('admin', 'manager', 'employee')),
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE TABLE log_supplier (
    log_id INT PRIMARY KEY,
    action_type CHAR(1),
    table_name VARCHAR2(50),
    action_details VARCHAR2(1000),
    action_time DATE DEFAULT SYSDATE,
    action_user VARCHAR2(50)
);

DROP SEQUENCE seq_suppliers_id;
CREATE SEQUENCE seq_suppliers_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
NOCACHE;

CREATE OR REPLACE TRIGGER trg_bef_suppliers
BEFORE INSERT ON suppliers
FOR EACH ROW
BEGIN
    :NEW.supplier_id := 'SUP' || LPAD(seq_suppliers_id.NEXTVAL, 4, '0');
END;
/

DROP SEQUENCE seq_materials_id;
CREATE SEQUENCE seq_materials_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
NOCACHE;

CREATE OR REPLACE TRIGGER trg_bef_materials
BEFORE INSERT ON raw_materials
FOR EACH ROW
BEGIN
    :NEW.material_id := 'MAT' || LPAD(seq_materials_id.NEXTVAL, 4, '0');
END;
/

DROP SEQUENCE seq_transactions_id;
CREATE SEQUENCE seq_transactions_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
NOCACHE;

CREATE OR REPLACE TRIGGER trg_bef_transactions
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    :NEW.transaction_id := 'TRS' || LPAD(seq_transactions_id.NEXTVAL, 4, '0');
END;
/

DROP SEQUENCE seq_tran_detail_id;
CREATE SEQUENCE seq_tran_detail_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
NOCACHE;

CREATE OR REPLACE TRIGGER trg_bef_tran_detail
BEFORE INSERT ON transaction_detail
FOR EACH ROW
BEGIN
    :NEW.detail_id := 'TRD' || LPAD(seq_tran_detail_id.NEXTVAL, 4, '0');
END;
/

DROP SEQUENCE seq_users_id;
CREATE SEQUENCE seq_users_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
NOCACHE;

CREATE OR REPLACE TRIGGER trg_bef_users
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    :NEW.user_id := 'USR' || LPAD(seq_users_id.NEXTVAL, 4, '0');
END;
/

DROP SEQUENCE seq_material_shipment_id;
CREATE SEQUENCE seq_material_shipment_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE
NOCACHE;

CREATE OR REPLACE TRIGGER trg_bef_material_shipment
BEFORE INSERT ON material_shipment
FOR EACH ROW
BEGIN
    :NEW.shipment_id := 'SHP' || LPAD(seq_material_shipment_id.NEXTVAL, 4, '0');
END;
/

DROP SEQUENCE seq_shipment_detail_id;
CREATE SEQUENCE seq_shipment_detail_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE
NOCACHE;

CREATE OR REPLACE TRIGGER trg_bef_shipment_detail
BEFORE INSERT ON material_shipment_detail
FOR EACH ROW
BEGIN
    :NEW.shipment_detail_id := 'SHD' || LPAD(seq_shipment_detail_id.NEXTVAL, 4, '0');
END;
/

CREATE SEQUENCE log_supplier_seq
START WITH 1
INCREMENT BY 1
MINVALUE 1 
MAXVALUE 9999
NOCYCLE
NOCACHE;


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

BEGIN
    update_transaction_status('TRS0005', 'Completed');
END;
/




CREATE OR REPLACE TRIGGER trg_log_suppliers
AFTER INSERT OR UPDATE OR DELETE ON suppliers
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'I', 'suppliers', 'Inserted supplier: ' || :NEW.name, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.supplier_id || ' ';

        IF :OLD.supplier_id != :NEW.supplier_id THEN
            v_action_details := v_action_details || 'Supplier ID changed from ' || :OLD.supplier_id || ' to ' || :NEW.supplier_id || ', ';
        END IF;
        IF :OLD.name != :NEW.name THEN
            v_action_details := v_action_details || 'Name changed from ' || :OLD.name || ' to ' || :NEW.name || ', ';
        END IF;
        IF :OLD.location != :NEW.location THEN
            v_action_details := v_action_details || 'Location changed from ' || :OLD.location || ' to ' || :NEW.location || ', ';
        END IF;
        IF :OLD.contact_info != :NEW.contact_info THEN
            v_action_details := v_action_details || 'Contact Info changed from ' || :OLD.contact_info || ' to ' || :NEW.contact_info || ', ';
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

        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'U', 'suppliers', v_action_details, v_user);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_log_raw_materials
AFTER INSERT OR UPDATE OR DELETE ON raw_materials
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'I', 'raw_materials', 'Inserted raw material: ' || :NEW.material_name, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.material_id || ' ';

        IF :OLD.material_id != :NEW.material_id THEN
            v_action_details := v_action_details || 'Material ID changed from ' || :OLD.material_id || ' to ' || :NEW.material_id || ', ';
        END IF;
        IF :OLD.material_name != :NEW.material_name THEN
            v_action_details := v_action_details || 'Material Name changed from ' || :OLD.material_name || ' to ' || :NEW.material_name || ', ';
        END IF;
        IF :OLD.stock_quantity != :NEW.stock_quantity THEN
            v_action_details := v_action_details || 'Stock quantity changed from ' || :OLD.stock_quantity || ' to ' || :NEW.stock_quantity || ', ';
        END IF;
        IF :OLD.supplier_id != :NEW.supplier_id THEN
            v_action_details := v_action_details || 'Supplier ID changed from ' || :OLD.supplier_id || ' to ' || :NEW.supplier_id || ', ';
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

        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'U', 'raw_materials', v_action_details, v_user);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_log_transactions
AFTER INSERT OR UPDATE OR DELETE ON transactions
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'I', 'transactions', 'Inserted transaction: ' || :NEW.transaction_id, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.transaction_id || ' ';

        IF :OLD.transaction_id != :NEW.transaction_id THEN
            v_action_details := v_action_details || 'Transaction ID changed from ' || :OLD.transaction_id || ' to ' || :NEW.transaction_id || ', ';
        END IF;
        IF :OLD.transaction_date != :NEW.transaction_date THEN
            v_action_details := v_action_details || 'Transaction Date changed from ' || :OLD.transaction_date || ' to ' || :NEW.transaction_date || ', ';
        END IF;
        IF :OLD.transaction_status != :NEW.transaction_status THEN
            v_action_details := v_action_details || 'Transaction Status changed from ' || :OLD.transaction_status || ' to ' || :NEW.transaction_status || ', ';
        END IF;
        IF :OLD.supplier_id != :NEW.supplier_id THEN
            v_action_details := v_action_details || 'Supplier ID changed from ' || :OLD.supplier_id || ' to ' || :NEW.supplier_id || ', ';
        END IF;
        IF :OLD.remarks != :NEW.remarks THEN
            v_action_details := v_action_details || 'Remarks changed from ' || :OLD.remarks || ' to ' || :NEW.remarks || ', ';
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

        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'U', 'transactions', v_action_details, v_user);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_log_transaction_detail
AFTER INSERT OR UPDATE OR DELETE ON transaction_detail
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'I', 'transaction_detail', 'Inserted transaction detail: Material ' || :NEW.material_id || ' with quantity ' || :NEW.quantity, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.detail_id || ' ';

        IF :OLD.detail_id != :NEW.detail_id THEN
            v_action_details := v_action_details || 'Detail ID changed from ' || :OLD.detail_id || ' to ' || :NEW.detail_id || ', ';
        END IF;
        IF :OLD.transaction_id != :NEW.transaction_id THEN
            v_action_details := v_action_details || 'Transaction ID changed from ' || :OLD.transaction_id || ' to ' || :NEW.transaction_id || ', ';
        END IF;
        IF :OLD.material_id != :NEW.material_id THEN
            v_action_details := v_action_details || 'Material ID changed from ' || :OLD.material_id || ' to ' || :NEW.material_id || ', ';
        END IF;
        IF :OLD.quantity != :NEW.quantity THEN
            v_action_details := v_action_details || 'Quantity changed from ' || TO_CHAR(:OLD.quantity) || ' to ' || TO_CHAR(:NEW.quantity) || ', ';
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

        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'U', 'transaction_detail', v_action_details, v_user);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_log_users
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'I', 'users', 'Inserted user: ' || :NEW.username, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.user_id || ' ';

        IF :OLD.user_id != :NEW.user_id THEN
            v_action_details := v_action_details || 'User ID changed from ' || :OLD.user_id || ' to ' || :NEW.user_id || ', ';
        END IF;
        IF :OLD.username != :NEW.username THEN
            v_action_details := v_action_details || 'Username changed from ' || :OLD.username || ' to ' || :NEW.username || ', ';
        END IF;
        IF :OLD.password != :NEW.password THEN
            v_action_details := v_action_details || 'Password changed from ' || :OLD.password || ' to ' || :NEW.password || ', ';
        END IF;
        IF :OLD.full_name != :NEW.full_name THEN
            v_action_details := v_action_details || 'Full Name changed from ' || :OLD.full_name || ' to ' || :NEW.full_name || ', ';
        END IF;
        IF :OLD.email != :NEW.email THEN
            v_action_details := v_action_details || 'Email changed from ' || :OLD.email || ' to ' || :NEW.email || ', ';
        END IF;
        IF :OLD.phone_number != :NEW.phone_number THEN
            v_action_details := v_action_details || 'Phone Number changed from ' || :OLD.phone_number || ' to ' || :NEW.phone_number || ', ';
        END IF;
        IF :OLD.role != :NEW.role THEN
            v_action_details := v_action_details || 'Role changed from ' || :OLD.role || ' to ' || :NEW.role || ', ';
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

        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'U', 'users', v_action_details, v_user);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_log_material_shipment
AFTER INSERT OR UPDATE OR DELETE ON material_shipment
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'I', 'material_shipment', 'Inserted shipment: ' || :NEW.shipment_id, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.shipment_id || ' ';

        IF :OLD.shipment_date != :NEW.shipment_date THEN
            v_action_details := v_action_details || 'Shipment date changed from ' || :OLD.shipment_date || ' to ' || :NEW.shipment_date || ', ';
        END IF;
        IF :OLD.shipment_status != :NEW.shipment_status THEN
            v_action_details := v_action_details || 'Shipment status changed from ' || :OLD.shipment_status || ' to ' || :NEW.shipment_status || ', ';
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

        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'U', 'material_shipment', v_action_details, v_user);
    ELSIF DELETING THEN
        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'D', 'material_shipment', 'Deleted shipment: ' || :OLD.shipment_id, v_user);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_log_shipment_detail
AFTER INSERT OR UPDATE OR DELETE ON material_shipment_detail
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'I', 'material_shipment_detail', 'Inserted shipment detail: ' || :NEW.shipment_detail_id, v_user);
    ELSIF UPDATING THEN
        v_action_details := :NEW.shipment_detail_id || ' ';

        IF :OLD.shipment_id != :NEW.shipment_id THEN
            v_action_details := v_action_details || 'Shipment ID changed from ' || :OLD.shipment_id || ' to ' || :NEW.shipment_id || ', ';
        END IF;
        IF :OLD.material_id != :NEW.material_id THEN
            v_action_details := v_action_details || 'Material ID changed from ' || :OLD.material_id || ' to ' || :NEW.material_id || ', ';
        END IF;
        IF :OLD.quantity != :NEW.quantity THEN
            v_action_details := v_action_details || 'Quantity changed from ' || :OLD.quantity || ' to ' || :NEW.quantity || ', ';
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

        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'U', 'material_shipment_detail', v_action_details, v_user);
    ELSIF DELETING THEN
        INSERT INTO log_supplier (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_supplier_seq.NEXTVAL, 'D', 'material_shipment_detail', 'Deleted shipment detail: ' || :OLD.shipment_detail_id, v_user);
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE insert_material_shipment(
    p_materials IN SYS.ODCIVARCHAR2LIST,
    p_quantities IN SYS.ODCINUMBERLIST
) AS
    v_shipment_id VARCHAR2(10);
    v_stock_quantity NUMBER;
BEGIN
    INSERT INTO material_shipment (shipment_date, shipment_status)
    VALUES (SYSDATE, 'Shipped')
    RETURNING shipment_id INTO v_shipment_id;

    FOR i IN 1 .. p_materials.COUNT LOOP
        -- Check if there is enough stock
        SELECT stock_quantity INTO v_stock_quantity
        FROM raw_materials
        WHERE material_id = p_materials(i);

        IF v_stock_quantity < p_quantities(i) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Not enough stock for material ' || p_materials(i));
        END IF;
    END LOOP;
    
    FOR i IN 1 .. p_materials.COUNT LOOP
        INSERT INTO material_shipment_detail (shipment_id, material_id, quantity)
        VALUES (v_shipment_id, p_materials(i), p_quantities(i));

        -- Decrease the stock quantity of the material
        UPDATE raw_materials
        SET stock_quantity = stock_quantity - p_quantities(i),
            last_update = SYSDATE
        WHERE material_id = p_materials(i);
    END LOOP;

    COMMIT;
END;
/

-- Data dummy untuk tabel suppliers
INSERT INTO suppliers (name, location, contact_info) VALUES
('ABC Supply Co.', 'Jakarta', '081234567890');
INSERT INTO suppliers (name, location, contact_info) VALUES
('Global Raw Materials', 'Bandung', '081987654321');
INSERT INTO suppliers (name, location, contact_info) VALUES
('PT. Indo Resources', 'Surabaya', '081567890123');

-- Data dummy untuk tabel raw_materials
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id) VALUES
('Tali Sepatu', 500, 'SUP0001');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id) VALUES
('Lem 200 gr', 300, 'SUP0002');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id) VALUES
('Kulit Durian', 700, 'SUP0003');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id) VALUES
('Kulit Ikan Pari', 200, 'SUP0001');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id) VALUES
('Kulit Singkong', 200, 'SUP0001');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id) VALUES
('Sabut Kelapa', 400, 'SUP0002');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id) VALUES
('Sayur Bayam', 500, 'SUP0002');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id) VALUES
('Kulit Kacang', 100, 'SUP0003');

-- Data dummy untuk tabel transactions
INSERT INTO transactions (transaction_status, supplier_id, remarks) VALUES
('Completed', 'SUP0001', 'Bulk order for project A');
INSERT INTO transactions (transaction_status, supplier_id, remarks) VALUES
('Pending', 'SUP0002', 'Urgent material delivery');
INSERT INTO transactions (transaction_status, supplier_id, remarks) VALUES
('Completed', 'SUP0003', 'Monthly stock replenishment');

-- Data dummy untuk tabel transaction_detail
INSERT INTO transaction_detail (transaction_id, material_id, quantity) VALUES
('TRS0001', 'MAT0001', 100);
INSERT INTO transaction_detail (transaction_id, material_id, quantity) VALUES
('TRS0001', 'MAT0004', 50);
INSERT INTO transaction_detail (transaction_id, material_id, quantity) VALUES
('TRS0002', 'MAT0002', 75);
INSERT INTO transaction_detail (transaction_id, material_id, quantity) VALUES
('TRS0003', 'MAT0003', 200);
INSERT INTO transaction_detail (transaction_id, material_id, quantity) VALUES
('TRS0003', 'MAT0001', 150);

-- Data dummy untuk tabel material_shipment
INSERT INTO material_shipment (shipment_status) VALUES
('Delivered');
INSERT INTO material_shipment (shipment_status) VALUES
('Shipped');
INSERT INTO material_shipment (shipment_status) VALUES
('Failed');

-- Data dummy untuk tabel material_shipment_detail
INSERT INTO material_shipment_detail (shipment_id, material_id, quantity) VALUES
('SHP0001', 'MAT0001', 100);
INSERT INTO material_shipment_detail (shipment_id, material_id, quantity) VALUES
('SHP0001', 'MAT0002', 50);
INSERT INTO material_shipment_detail (shipment_id, material_id, quantity) VALUES
('SHP0002', 'MAT0003', 150);
INSERT INTO material_shipment_detail (shipment_id, material_id, quantity) VALUES
('SHP0002', 'MAT0004', 25);
INSERT INTO material_shipment_detail (shipment_id, material_id, quantity) VALUES
('SHP0003', 'MAT0001', 50);

-- Data dummy untuk tabel users
INSERT INTO users (username, password, full_name, email, phone_number, role) VALUES
('admin01', 'password123', 'Admin User', 'admin@company.com', '08111222333', 'admin');
INSERT INTO users (username, password, full_name, email, phone_number, role) VALUES
('manager01', 'password123', 'Manager User', 'manager@company.com', '08112223344', 'manager');
INSERT INTO users (username, password, full_name, email, phone_number, role) VALUES
('employee01', 'password123', 'Employee User', 'employee@company.com', '08113334455', 'employee');


-- Create a database link to connect to the supplier database
CREATE DATABASE LINK rnd_dblink
CONNECT TO rama IDENTIFIED BY rama
USING 'conrnd';

-- Test the database link
SELECT * FROM products@rnd_dblink;
