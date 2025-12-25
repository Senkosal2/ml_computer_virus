set linesize 300;
set pagesize 100;
COL datafile_name FORMAT a80
COL tablespace_name FORMAT a20
SELECT
    d.file#,
    d.NAME AS datafile_name,
    t.NAME AS tablespace_name,
    d.BYTES / (1024 * 1024) AS size_mb
FROM
    V$DATAFILE d
JOIN
    V$TABLESPACE t ON d.TS# = t.TS#;
