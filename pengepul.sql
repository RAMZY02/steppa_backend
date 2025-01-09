-- 1. create user admin
CREATE USER reti IDENTIFIED BY reti;
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
ALTER USER reti QUOTA UNLIMITED ON USERS;
GRANT ADMIN TO reti;
GRANT CONNECT TO reti;
grant create database link to admin;
GRANT CREATE SESSION TO reti;


--login ke reki
conn reti@steppa_supplier/reti



--role admin
set role admin identified by admin;




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
    role VARCHAR2(20) CHECK (role IN ('admin', 'employee')),
    created_at DATE DEFAULT SYSDATE,
    deleted_at DATE
);

CREATE SEQUENCE seq_suppliers_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_suppliers
BEFORE INSERT ON suppliers
FOR EACH ROW
BEGIN
    :NEW.supplier_id := 'SUP' || LPAD(seq_suppliers_id.NEXTVAL, 4, '0');
END;
/

CREATE SEQUENCE seq_materials_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_materials
BEFORE INSERT ON raw_materials
FOR EACH ROW
BEGIN
    :NEW.material_id := 'MAT' || LPAD(seq_materials_id.NEXTVAL, 4, '0');
END;
/

CREATE SEQUENCE seq_transactions_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_transactions
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    :NEW.transaction_id := 'TRS' || LPAD(seq_transactions_id.NEXTVAL, 4, '0');
END;
/

CREATE SEQUENCE seq_tran_detail_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_tran_detail
BEFORE INSERT ON transaction_detail
FOR EACH ROW
BEGIN
    :NEW.detail_id := 'TRD' || LPAD(seq_tran_detail_id.NEXTVAL, 4, '0');
END;
/

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

CREATE SEQUENCE seq_material_shipment_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_material_shipment
BEFORE INSERT ON material_shipment
FOR EACH ROW
BEGIN
    :NEW.shipment_id := 'SHP' || LPAD(seq_material_shipment_id.NEXTVAL, 4, '0');
END;
/

CREATE SEQUENCE seq_shipment_detail_id
START WITH 1 
INCREMENT BY 1 
MINVALUE 1 
MAXVALUE 9999 
NOCYCLE 
CACHE 10;

CREATE OR REPLACE TRIGGER trg_bef_shipment_detail
BEFORE INSERT ON material_shipment_detail
FOR EACH ROW
BEGIN
    :NEW.shipment_detail_id := 'SHD' || LPAD(seq_shipment_detail_id.NEXTVAL, 4, '0');
END;
/

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



CREATE SEQUENCE log_pengepul_seq
START WITH 1
INCREMENT BY 1
CACHE 10;

CREATE TABLE log_pengepul (
    log_id INT PRIMARY KEY,
    action_type CHAR(1),
    table_name VARCHAR2(50),
    action_details VARCHAR2(255),
    action_time DATE DEFAULT SYSDATE,
    action_user VARCHAR2(50)
);

CREATE OR REPLACE TRIGGER trg_log_suppliers
AFTER INSERT OR UPDATE OR DELETE ON suppliers
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_action_details VARCHAR2(255);
BEGIN
    SELECT USER INTO v_user FROM DUAL;

    IF INSERTING THEN
        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'I', 'suppliers', 'Inserted supplier: ' || :NEW.name, v_user);
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

        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'U', 'suppliers', v_action_details, v_user);
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
        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'I', 'raw_materials', 'Inserted raw material: ' || :NEW.material_name, v_user);
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

        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'U', 'raw_materials', v_action_details, v_user);
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
        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'I', 'transactions', 'Inserted transaction: ' || :NEW.transaction_id, v_user);
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

        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'U', 'transactions', v_action_details, v_user);
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
        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'I', 'transaction_detail', 'Inserted transaction detail: Material ' || :NEW.material_id || ' with quantity ' || :NEW.quantity, v_user);
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

        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'U', 'transaction_detail', v_action_details, v_user);
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
        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'I', 'users', 'Inserted user: ' || :NEW.username, v_user);
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

        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'U', 'users', v_action_details, v_user);
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
        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'I', 'material_shipment', 'Inserted shipment: ' || :NEW.shipment_id, v_user);
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

        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'U', 'material_shipment', v_action_details, v_user);
    ELSIF DELETING THEN
        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'D', 'material_shipment', 'Deleted shipment: ' || :OLD.shipment_id, v_user);
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
        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'I', 'material_shipment_detail', 'Inserted shipment detail: ' || :NEW.shipment_detail_id, v_user);
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

        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'U', 'material_shipment_detail', v_action_details, v_user);
    ELSIF DELETING THEN
        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'D', 'material_shipment_detail', 'Deleted shipment detail: ' || :OLD.shipment_detail_id, v_user);
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE insert_material_shipment(
    p_materials IN SYS.ODCIVARCHAR2LIST,
    p_quantities IN SYS.ODCINUMBERLIST
) AS
    v_shipment_id VARCHAR2(10);
BEGIN
    INSERT INTO material_shipment (shipment_date, shipment_status)
    VALUES (SYSDATE, 'Shipped')
    RETURNING shipment_id INTO v_shipment_id;

    FOR i IN 1 .. p_materials.COUNT LOOP
        INSERT INTO material_shipment_detail (shipment_id, material_id, quantity)
        VALUES (v_shipment_id, p_materials(i), p_quantities(i));
    END LOOP;

    COMMIT;
END;
/
-- Insert dummy data into suppliers
INSERT INTO suppliers (name, location, contact_info)
VALUES ('Supplier 1', 'Location 1', 'Contact 1');
INSERT INTO suppliers (name, location, contact_info)
VALUES ('Supplier 2', 'Location 2', 'Contact 2');
INSERT INTO suppliers (name, location, contact_info)
VALUES ('Supplier 3', 'Location 3', 'Contact 3');
INSERT INTO suppliers (name, location, contact_info)
VALUES ('Supplier 4', 'Location 4', 'Contact 4');
INSERT INTO suppliers (name, location, contact_info)
VALUES ('Supplier 5', 'Location 5', 'Contact 5');
INSERT INTO suppliers (name, location, contact_info)
VALUES ('Supplier 6', 'Location 6', 'Contact 6');
INSERT INTO suppliers (name, location, contact_info)
VALUES ('Supplier 7', 'Location 7', 'Contact 7');
INSERT INTO suppliers (name, location, contact_info)
VALUES ('Supplier 8', 'Location 8', 'Contact 8');
INSERT INTO suppliers (name, location, contact_info)
VALUES ('Supplier 9', 'Location 9', 'Contact 9');
INSERT INTO suppliers (name, location, contact_info)
VALUES ('Supplier 10', 'Location 10', 'Contact 10');

-- Insert dummy data into raw_materials
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id)
VALUES ('Material 1', 100, 'SUP0001');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id)
VALUES ('Material 2', 200, 'SUP0002');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id)
VALUES ('Material 3', 300, 'SUP0003');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id)
VALUES ('Material 4', 400, 'SUP0004');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id)
VALUES ('Material 5', 500, 'SUP0005');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id)
VALUES ('Material 6', 600, 'SUP0006');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id)
VALUES ('Material 7', 700, 'SUP0007');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id)
VALUES ('Material 8', 800, 'SUP0008');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id)
VALUES ('Material 9', 900, 'SUP0009');
INSERT INTO raw_materials (material_name, stock_quantity, supplier_id)
VALUES ('Material 10', 1000, 'SUP0010');

-- Insert dummy data into transactions
INSERT INTO transactions (transaction_date, transaction_status, supplier_id, remarks)
VALUES (SYSDATE, 'Pending', 'SUP0001', 'Remarks 1');
INSERT INTO transactions (transaction_date, transaction_status, supplier_id, remarks)
VALUES (SYSDATE, 'Pending', 'SUP0002', 'Remarks 2');
INSERT INTO transactions (transaction_date, transaction_status, supplier_id, remarks)
VALUES (SYSDATE, 'Pending', 'SUP0003', 'Remarks 3');
INSERT INTO transactions (transaction_date, transaction_status, supplier_id, remarks)
VALUES (SYSDATE, 'Pending', 'SUP0004', 'Remarks 4');
INSERT INTO transactions (transaction_date, transaction_status, supplier_id, remarks)
VALUES (SYSDATE, 'Pending', 'SUP0005', 'Remarks 5');
INSERT INTO transactions (transaction_date, transaction_status, supplier_id, remarks)
VALUES (SYSDATE, 'Pending', 'SUP0006', 'Remarks 6');
INSERT INTO transactions (transaction_date, transaction_status, supplier_id, remarks)
VALUES (SYSDATE, 'Pending', 'SUP0007', 'Remarks 7');
INSERT INTO transactions (transaction_date, transaction_status, supplier_id, remarks)
VALUES (SYSDATE, 'Pending', 'SUP0008', 'Remarks 8');
INSERT INTO transactions (transaction_date, transaction_status, supplier_id, remarks)
VALUES (SYSDATE, 'Pending', 'SUP0009', 'Remarks 9');
INSERT INTO transactions (transaction_date, transaction_status, supplier_id, remarks)
VALUES (SYSDATE, 'Pending', 'SUP0010', 'Remarks 10');

-- Insert dummy data into transaction_detail
INSERT INTO transaction_detail (transaction_id, material_id, quantity)
VALUES ('TRS0001', 'MAT0001', 10);
INSERT INTO transaction_detail (transaction_id, material_id, quantity)
VALUES ('TRS0002', 'MAT0002', 20);
INSERT INTO transaction_detail (transaction_id, material_id, quantity)
VALUES ('TRS0003', 'MAT0003', 30);
INSERT INTO transaction_detail (transaction_id, material_id, quantity)
VALUES ('TRS0004', 'MAT0004', 40);
INSERT INTO transaction_detail (transaction_id, material_id, quantity)
VALUES ('TRS0005', 'MAT0005', 50);
INSERT INTO transaction_detail (transaction_id, material_id, quantity)
VALUES ('TRS0006', 'MAT0006', 60);
INSERT INTO transaction_detail (transaction_id, material_id, quantity)
VALUES ('TRS0007', 'MAT0007', 70);
INSERT INTO transaction_detail (transaction_id, material_id, quantity)
VALUES ('TRS0008', 'MAT0008', 80);
INSERT INTO transaction_detail (transaction_id, material_id, quantity)
VALUES ('TRS0009', 'MAT0009', 90);
INSERT INTO transaction_detail (transaction_id, material_id, quantity)
VALUES ('TRS0010', 'MAT0010', 100);

-- Insert dummy data into users
INSERT INTO users (username, password, full_name, email, phone_number, role)
VALUES ('admin', 'adminpassword', 'Admin User', 'admin@example.com', '1234567890', 'admin');
INSERT INTO users (username, password, full_name, email, phone_number, role)
VALUES ('employee1', 'employeepassword1', 'Employee One', 'employee1@example.com', '0987654321', 'employee');
INSERT INTO users (username, password, full_name, email, phone_number, role)
VALUES ('employee2', 'employeepassword2', 'Employee Two', 'employee2@example.com', '1122334455', 'employee');

-- Insert dummy data into material_shipment
INSERT INTO material_shipment (shipment_date, shipment_status)
VALUES (SYSDATE, 'Shipped');
INSERT INTO material_shipment (shipment_date, shipment_status)
VALUES (SYSDATE, 'Delivered');
INSERT INTO material_shipment (shipment_date, shipment_status)
VALUES (SYSDATE, 'Failed');

-- Insert dummy data into material_shipment_detail
INSERT INTO material_shipment_detail (shipment_id, material_id, quantity)
VALUES ('SHP0001', 'MAT0001', 10);
INSERT INTO material_shipment_detail (shipment_id, material_id, quantity)
VALUES ('SHP0001', 'MAT0002', 20);
INSERT INTO material_shipment_detail (shipment_id, material_id, quantity)
VALUES ('SHP0001', 'MAT0003', 30);

INSERT INTO material_shipment_detail (shipment_id, material_id, quantity)
VALUES ('SHP0002', 'MAT0004', 15);
INSERT INTO material_shipment_detail (shipment_id, material_id, quantity)
VALUES ('SHP0002', 'MAT0005', 25);
INSERT INTO material_shipment_detail (shipment_id, material_id, quantity)
VALUES ('SHP0002', 'MAT0006', 35);

INSERT INTO material_shipment_detail (shipment_id, material_id, quantity)
VALUES ('SHP0003', 'MAT0007', 5);
INSERT INTO material_shipment_detail (shipment_id, material_id, quantity)
VALUES ('SHP0003', 'MAT0008', 10);
INSERT INTO material_shipment_detail (shipment_id, material_id, quantity)
VALUES ('SHP0003', 'MAT0009', 20);

-- Create a database link to connect to the pengepul database
CREATE DATABASE LINK rnd_dblink
CONNECT TO rama IDENTIFIED BY rama
USING 'conrnd';

-- Test the database link
SELECT * FROM products@rnd_dblink;
