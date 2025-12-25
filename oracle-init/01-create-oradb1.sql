-- 1) Create PDB (only if not exists)
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM dba_pdbs WHERE pdb_name = 'ORADB1';

  IF v_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE PLUGGABLE DATABASE oradb1
        ADMIN USER mlusr IDENTIFIED BY 123
        FILE_NAME_CONVERT = ('pdbseed', 'oradb1')
    ]';
  END IF;
END;
/

-- 2) Open PDB + persist
ALTER PLUGGABLE DATABASE oradb1 OPEN;
ALTER PLUGGABLE DATABASE oradb1 SAVE STATE;

-- 3) Ensure service exists + start it
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM dba_services WHERE name = 'oradb1';

  IF v_count = 0 THEN
    DBMS_SERVICE.CREATE_SERVICE(service_name => 'oradb1', network_name => 'oradb1');
  END IF;

  DBMS_SERVICE.START_SERVICE('oradb1');
END;
/

-- 4) Switch to the PDB for tablespace/user grants
ALTER SESSION SET CONTAINER = oradb1;

-- 5) Create tablespace in the PDB (only if not exists)
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM dba_tablespaces WHERE tablespace_name = 'DATA';

  IF v_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLESPACE DATA DATAFILE
        '/opt/oracle/oradata/ORCLCDB/oradb1/DATA.dbf'
      SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED
      LOGGING
      ONLINE
      EXTENT MANAGEMENT LOCAL AUTOALLOCATE
      SEGMENT SPACE MANAGEMENT AUTO
    ]';
  END IF;
END;
/

-- 6) Grants for mlusr (in the PDB)
-- create session is fine; DBA is very powerful (OK for dev)
GRANT CREATE SESSION TO mlusr;
GRANT DBA TO mlusr;

-- 7) Assign tablespace to mlusr + give quota
ALTER USER mlusr DEFAULT TABLESPACE DATA;
ALTER USER mlusr TEMPORARY TABLESPACE TEMP;

-- Give unlimited quota on DATA tablespace
ALTER USER mlusr QUOTA UNLIMITED ON DATA;
