-- 1. create user admin
CREATE USER reki IDENTIFIED BY reki
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
ALTER USER admin QUOTA UNLIMITED ON USERS;
GRANT ADMIN TO reki;


--login ke reki
conn reki@steppa_store/reki



--role admin
set role admin identified by admin




--create table
CREATE TABLE suppliers (
    supplier_id VARCHAR2(10)  PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    location VARCHAR2(100),
    contact_info VARCHAR2(50),
    is_deleted CHAR(1) DEFAULT 'N'
);

CREATE TABLE raw_materials (
    material_id VARCHAR2(10)  PRIMARY KEY,
    material_name VARCHAR2(100) NOT NULL,
    stock_quantity NUMBER NOT NULL CHECK (stock_quantity >= 0),
    supplier_id VARCHAR2(10) REFERENCES suppliers(supplier_id) ON DELETE SET NULL,
    last_update DATE DEFAULT SYSDATE
    is_deleted CHAR(1) DEFAULT 'N'
);

CREATE TABLE transactions (
    transaction_id VARCHAR2(10) PRIMARY KEY,
    transaction_date DATE DEFAULT SYSDATE NOT NULL,
    transaction_status VARCHAR2(20) NOT NULL CHECK (transaction_type IN ('Pending', 'Completed')),
    supplier_id VARCHAR2(10) REFERENCES suppliers(supplier_id) ON DELETE SET NULL,
    remarks VARCHAR2(255)
    is_deleted CHAR(1) DEFAULT 'N'
);

CREATE TABLE transaction_detail (
    detail_id VARCHAR2(10) PRIMARY KEY,
    transaction_id VARCHAR2(10) REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    material_id VARCHAR2(10) REFERENCES raw_materials(material_id) ON DELETE CASCADE,
    quantity NUMBER NOT NULL CHECK (quantity > 0)
    is_deleted CHAR(1) DEFAULT 'N'
);


GRANT SELECT, INSERT ON transactions TO pengepul;
GRANT SELECT, INSERT ON transaction_detail TO pengepul;
GRANT SELECT ON suppliers TO pengepul;
GRANT SELECT ON raw_materials TO pengepul;



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

        IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, LENGTH(v_action_details) - 1, 2) = ', ' THEN
            v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
        END IF;

        INSERT INTO log_pengepul (log_id, action_type, table_name, action_details, action_user)
        VALUES (log_pengepul_seq.NEXTVAL, 'U', 'transaction_detail', v_action_details, v_user);
    END IF;
END;
/
