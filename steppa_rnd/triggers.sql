--------------------------------------------------------
--  File created - Sunday-January-05-2025   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger TRG_DESIGN_ID
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "RAMA"."TRG_DESIGN_ID" 
  BEFORE INSERT ON "RAMA"."DESIGN"
  FOR EACH ROW
BEGIN
  -- Assigning a new value to ID before inserting a row
  IF :NEW."ID" IS NULL THEN
    SELECT SEQ_DESIGN.NEXTVAL
    INTO :NEW."ID"
    FROM DUAL;
  END IF;

END;
ALTER TRIGGER "RAMA"."TRG_DESIGN_ID" ENABLE
--------------------------------------------------------
--  DDL for Trigger TRG_DESIGN_MATERIALS_ID
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "RAMA"."TRG_DESIGN_MATERIALS_ID" 
  BEFORE INSERT ON "RAMA"."DESIGN_MATERIALS"
  FOR EACH ROW
BEGIN
  -- Assigning a new value to ID before inserting a row
  IF :NEW."ID" IS NULL THEN
    SELECT SEQ_DESIGN_MATERIALS.NEXTVAL
    INTO :NEW."ID"
    FROM DUAL;
  END IF;
END;
ALTER TRIGGER "RAMA"."TRG_DESIGN_MATERIALS_ID" ENABLE
--------------------------------------------------------
--  DDL for Trigger TRG_LOG_DESIGN
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "RAMA"."TRG_LOG_DESIGN" 
AFTER INSERT OR UPDATE OR DELETE ON "RAMA"."DESIGN"
FOR EACH ROW
DECLARE
  v_user VARCHAR2(50);
  v_action_details VARCHAR2(255);
  v_action CHAR(1);
BEGIN
  SELECT USER INTO v_user FROM DUAL;

  IF INSERTING THEN
    v_action_details := 'Inserted design: Name - ' || :NEW.NAME;
    v_action := 'I';
  ELSIF UPDATING THEN
    v_action_details := 'Updated design: ';
    v_action := 'U';
    IF :OLD.NAME != :NEW.NAME THEN
      v_action_details := v_action_details || 'Name changed from ' || :OLD.NAME || ' to ' || :NEW.NAME || ', ';
    END IF;
    IF :OLD.IMAGE != :NEW.IMAGE THEN
      v_action_details := v_action_details || 'Image changed (details not shown for security reasons), ';
    END IF;
    IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, LENGTH(v_action_details) - 1, 2) = ', ' THEN
      v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
    END IF;
  ELSIF DELETING THEN
    v_action := 'U';
    v_action_details := 'Deleted design: Name - ' || :OLD.NAME;
  END IF;

  IF LENGTH(v_action_details) > 0 THEN
    INSERT INTO log_rnd (log_id, action_type, table_name, action_details, action_user)
    VALUES (seq_log_rnd.NEXTVAL, v_action, 'DESIGN', v_action_details, v_user);
  END IF;
END;
ALTER TRIGGER "RAMA"."TRG_LOG_DESIGN" ENABLE
--------------------------------------------------------
--  DDL for Trigger TRG_LOG_DESIGN_MATERIALS
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "RAMA"."TRG_LOG_DESIGN_MATERIALS" 
AFTER INSERT OR UPDATE OR DELETE ON "RAMA"."DESIGN_MATERIALS"
FOR EACH ROW
DECLARE
  v_user VARCHAR2(50);
  v_action_details VARCHAR2(255);
  v_action CHAR(1);
BEGIN
  SELECT USER INTO v_user FROM DUAL;

  IF INSERTING THEN
    v_action := 'I';
    v_action_details := 'Inserted design material association: Design ID - ' || :NEW.DESIGN_ID || ', Material ID - ' || :NEW.MATERIAL_ID || ', Quantity - ' || :NEW.QTY;
  ELSIF UPDATING THEN
    v_action := 'U';
    v_action_details := 'Updated design material association: ';
    IF :OLD.DESIGN_ID != :NEW.DESIGN_ID THEN
      v_action_details := v_action_details || 'Design ID changed from ' || :OLD.DESIGN_ID || ' to ' || :NEW.DESIGN_ID || ', ';
    END IF;
    IF :OLD.MATERIAL_ID != :NEW.MATERIAL_ID THEN
      v_action_details := v_action_details || 'Material ID changed from ' || :OLD.MATERIAL_ID || ' to ' || :NEW.MATERIAL_ID || ', ';
    END IF;
    IF :OLD.QTY != :NEW.QTY THEN
      v_action_details := v_action_details || 'Quantity changed from ' || :OLD.QTY || ' to ' || :NEW.QTY || ', ';
    END IF;
    IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, LENGTH(v_action_details) - 1, 2) = ', ' THEN
      v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
    END IF;
  ELSIF DELETING THEN
    v_action := 'D';
    v_action_details := 'Deleted design material association: Design ID - ' || :OLD.DESIGN_ID || ', Material ID - ' || :OLD.MATERIAL_ID || ', Quantity - ' || :OLD.QTY;
  END IF;

  IF LENGTH(v_action_details) > 0 THEN
    INSERT INTO log_rnd (log_id, action_type, table_name, action_details, action_user)
    VALUES (seq_log_rnd.NEXTVAL, v_action, 'DESIGN_MATERIALS', v_action_details, v_user);
  END IF;
END;
ALTER TRIGGER "RAMA"."TRG_LOG_DESIGN_MATERIALS" ENABLE
--------------------------------------------------------
--  DDL for Trigger TRG_LOG_PRODUCTION
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "RAMA"."TRG_LOG_PRODUCTION" 
AFTER INSERT OR UPDATE OR DELETE ON "RAMA"."PRODUCTION"
FOR EACH ROW
DECLARE
  v_user VARCHAR2(50);
  v_action_details VARCHAR2(255);
  v_action CHAR(1);
BEGIN
  SELECT USER INTO v_user FROM DUAL;

  IF INSERTING THEN
    v_action := 'I';
    v_action_details := 'Inserted new production: design id - ' || :new.design_id;
  ELSIF UPDATING THEN
    v_action := 'U';
    v_action_details := 'Updated production ' || :NEW.ID || ': ' || 'design id - ' || :new.design_id;
    IF :OLD.design_id != :new.design_id THEN
      v_action_details := v_action_details || 'design id changed from ' || :OLD.design_id || 'to ' || :new.design_id;
    END IF;
    IF :OLD.EXPECTED_QTY != :NEW.EXPECTED_QTY THEN
      v_action_details := v_action_details || 'Expected Quantity changed from ' || :OLD.EXPECTED_QTY || ' to ' || :NEW.EXPECTED_QTY || ', ';
    END IF;
    IF :OLD.ACTUAL_QTY != :NEW.ACTUAL_QTY THEN
      v_action_details := v_action_details || ' Actual Quantity changed from ' || :OLD.ACTUAL_QTY || ' to ' || :NEW.ACTUAL_QTY || ', ';
    END IF;
    IF :OLD.STATUS != :NEW.STATUS THEN
      v_action_details := v_action_details || 'Status changed from ' || :OLD.STATUS || ' to ' || :NEW.STATUS;
    END IF;
    -- Hapus koma terakhir jika ada
    IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, -2) = ', ' THEN
      v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
    END IF;
  ELSIF DELETING THEN
    v_action := 'D';
    v_action_details := 'Deleted production: ID - ' || :OLD.ID || ', design id  - ' || :OLD.design_id;
  END IF;

  IF LENGTH(v_action_details) > 0 THEN
    INSERT INTO log_rnd (log_id, action_type, table_name, action_details, action_user)
    VALUES (seq_log_rnd.NEXTVAL, v_action, 'PRODUCTION', v_action_details, v_user);
  END IF;
END;
ALTER TRIGGER "RAMA"."TRG_LOG_PRODUCTION" ENABLE
--------------------------------------------------------
--  DDL for Trigger TRG_LOG_PRODUCTS
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "RAMA"."TRG_LOG_PRODUCTS" 
AFTER INSERT OR UPDATE OR DELETE ON "RAMA"."PRODUCTS"
FOR EACH ROW
DECLARE
  v_user VARCHAR2(50);
  v_action_details VARCHAR2(255);
  v_action CHAR(1);
BEGIN
  SELECT USER INTO v_user FROM DUAL;

  IF INSERTING THEN
    v_action := 'I';
    v_action_details := 'Inserted new product: Name - ' || :NEW.PRODUCT_NAME || 
                        ', Category - ' || :NEW.PRODUCT_CATEGORY || 
                        ', Price - ' || :NEW.PRICE;
  ELSIF UPDATING THEN
    v_action := 'U';
    v_action_details := 'Updated product: ID - ' || :NEW.PRODUCT_ID || ': Deleted_At ' || :new.deleted_at;

    IF :OLD.PRODUCT_NAME != :NEW.PRODUCT_NAME THEN
      v_action_details := v_action_details || 'Name changed from ' || :OLD.PRODUCT_NAME || 
                          ' to ' || :NEW.PRODUCT_NAME || ', ';
    END IF;
    IF :OLD.PRODUCT_CATEGORY != :NEW.PRODUCT_CATEGORY THEN
      v_action_details := v_action_details || 'Category changed from ' || :OLD.PRODUCT_CATEGORY || 
                          ' to ' || :NEW.PRODUCT_CATEGORY || ', ';
    END IF;
    IF :OLD.PRICE != :NEW.PRICE THEN
      v_action_details := v_action_details || 'Price changed from ' || :OLD.PRICE || 
                          ' to ' || :NEW.PRICE || ', ';
    END IF;
    IF :OLD.STOK_QTY != :NEW.STOK_QTY THEN
      v_action_details := v_action_details || 'Stock Quantity changed from ' || :OLD.STOK_QTY || 
                          ' to ' || :NEW.STOK_QTY || ', ';
    END IF;

    -- Menghapus koma terakhir jika ada
    IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, -2) = ', ' THEN
      v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
    END IF;

  ELSIF DELETING THEN
    v_action := 'D';
    v_action_details := 'Deleted product: ID - ' || :OLD.PRODUCT_ID || 
                        ', Name - ' || :OLD.PRODUCT_NAME;
  END IF;

  IF LENGTH(v_action_details) > 0 THEN
    INSERT INTO log_rnd (log_id, action_type, table_name, action_details, action_user)
    VALUES (seq_log_rnd.NEXTVAL, v_action, 'PRODUCTS', v_action_details, v_user);
  END IF;
END;
ALTER TRIGGER "RAMA"."TRG_LOG_PRODUCTS" ENABLE
--------------------------------------------------------
--  DDL for Trigger TRG_LOG_RAW_MATERIALS
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "RAMA"."TRG_LOG_RAW_MATERIALS" 
AFTER INSERT OR UPDATE OR DELETE ON "RAMA"."RAW_MATERIALS"
FOR EACH ROW
DECLARE
  v_user VARCHAR2(50);
  v_action_details VARCHAR2(255);
  v_action CHAR(1);
BEGIN
  SELECT USER INTO v_user FROM DUAL;

  IF INSERTING THEN
    v_action := 'I';
    v_action_details := 'Inserted new raw material: Name - ' || :NEW.NAME || ', Stock Quantity - ' || :NEW.STOK_QTY;
  ELSIF UPDATING THEN
    v_action := 'U';
    v_action_details := 'Updated raw material ' || :NEW.ID || ': ';
    IF :OLD.NAME != :NEW.NAME THEN
      v_action_details := v_action_details || 'Name changed from ' || :OLD.NAME || ' to ' || :NEW.NAME || ', ';
    END IF;
    IF :OLD.STOK_QTY != :NEW.STOK_QTY THEN
      v_action_details := v_action_details || 'Stock Quantity changed from ' || :OLD.STOK_QTY || ' to ' || :NEW.STOK_QTY || ', ';
    END IF;
    IF LENGTH(v_action_details) > 0 AND SUBSTR(v_action_details, -2) = ', ' THEN
      v_action_details := SUBSTR(v_action_details, 1, LENGTH(v_action_details) - 2);
    END IF;
  ELSIF DELETING THEN
    v_action := 'D';
    v_action_details := 'Deleted raw material: ID - ' || :OLD.ID || ', Name - ' || :OLD.NAME;
  END IF;

  IF LENGTH(v_action_details) > 0 THEN
    INSERT INTO log_rnd (log_id, action_type, table_name, action_details, action_user)
    VALUES (seq_log_rnd.NEXTVAL, v_action, 'RAW_MATERIALS', v_action_details, v_user);
  END IF;
END;
ALTER TRIGGER "RAMA"."TRG_LOG_RAW_MATERIALS" ENABLE
--------------------------------------------------------
--  DDL for Trigger TRG_PRODUCTION_ID
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "RAMA"."TRG_PRODUCTION_ID" 
BEFORE INSERT ON "RAMA"."PRODUCTION"
FOR EACH ROW
BEGIN
  IF :NEW."ID" IS NULL THEN
    SELECT seq_production.NEXTVAL INTO :NEW."ID" FROM DUAL;
  END IF;
END;
ALTER TRIGGER "RAMA"."TRG_PRODUCTION_ID" ENABLE
--------------------------------------------------------
--  DDL for Trigger TRG_PRODUCTS_ID
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "RAMA"."TRG_PRODUCTS_ID" 
BEFORE INSERT ON "RAMA"."PRODUCTS"
FOR EACH ROW
BEGIN
    :NEW.product_id := 'PRO' || LPAD(seq_products.NEXTVAL, 4, '0');
END;

ALTER TRIGGER "RAMA"."TRG_PRODUCTS_ID" ENABLE
--------------------------------------------------------
--  DDL for Trigger TRG_RAW_MATERIALS_ID
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "RAMA"."TRG_RAW_MATERIALS_ID" 
  BEFORE INSERT ON "RAMA"."RAW_MATERIALS"
  FOR EACH ROW
BEGIN
  -- Assigning a new value to ID before inserting a row
  IF :NEW."ID" IS NULL THEN
    SELECT SEQ_RAW_MATERIALS.NEXTVAL
    INTO :NEW."ID"
    FROM DUAL;
  END IF;
END;
ALTER TRIGGER "RAMA"."TRG_RAW_MATERIALS_ID" ENABLE
