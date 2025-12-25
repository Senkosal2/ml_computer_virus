-- Create PDB
CREATE PLUGGABLE DATABASE oradb1
  ADMIN USER mlusr IDENTIFIED BY 123
  FILE_NAME_CONVERT = ('pdbseed', 'oradb1');

-- Open it
ALTER PLUGGABLE DATABASE oradb1 OPEN;

-- Persist open state
ALTER PLUGGABLE DATABASE oradb1 SAVE STATE;

-- Explicit service registration (recommended)
BEGIN
  DBMS_SERVICE.CREATE_SERVICE(
    service_name => 'oradb1',
    network_name => 'oradb1'
  );
END;
/

BEGIN
  DBMS_SERVICE.START_SERVICE('oradb1');
END;
/
