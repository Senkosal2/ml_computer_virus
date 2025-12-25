SET LINESIZE 300
SET PAGESIZE 100
COLUMN username FORMAT a30
COLUMN granted_roles FORMAT a50 WORD_WRAPPED
COLUMN system_privileges FORMAT a50 WORD_WRAPPED

WITH UserRoles AS (
    -- Aggregate all granted roles per user
    SELECT
        grantee,
        LISTAGG(granted_role, CHR(10)) WITHIN GROUP (ORDER BY granted_role) AS granted_roles
    FROM
        dba_role_privs
    GROUP BY
        grantee
),
UserPrivs AS (
    -- Aggregate all system privileges per user
    SELECT
        grantee,
        LISTAGG(privilege, CHR(10)) WITHIN GROUP (ORDER BY privilege) AS system_privileges
    FROM
        dba_sys_privs
    GROUP BY
        grantee
)
SELECT
    a.username,
    a.created,
    b.granted_roles,
    c.system_privileges
FROM
    dba_users a
LEFT JOIN
    UserRoles b
    ON a.username = b.grantee
LEFT JOIN
    UserPrivs c
    ON a.username = c.grantee
WHERE
    a.username NOT IN ('ANONYMOUS', 'APEX_PUBLIC_USER', 'APEX_050000', 'CTXSYS', 'DBSNMP', 'ORDSYS', 'OUTLN', 'WMSYS', 'XDB')
    AND a.username NOT LIKE '%SYS%'
    AND a.username NOT LIKE 'APEX_%'
    AND a.created >= (SELECT created FROM v$database)
ORDER BY
    a.username;