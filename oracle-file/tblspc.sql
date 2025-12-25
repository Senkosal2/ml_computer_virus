set linesize 300;
set pagesize 300;
SELECT      df.tablespace_name "Tablespace",
            ROUND(100*((df.totalspace-fs.freespace)/df.totalspace)) "Usage%",
            ROUND(df.totalspace/1024,3) "Size GB",
            ROUND(fs.freespace/1024,3) "Free GB",
            ROUND((df.totalspace-fs.freespace)/1024,3) "Used GB",
            ROUND(100*(fs.freespace/df.totalspace)) "Free%",
            Round(((df.totalspace-fs.freespace)/(fs.freedatafilein+df.totalspace))*100,3) "Used % of Max" ,
            ROUND(fs.freedatafilein/1024,3) "Free DBF GB",
            ROUND(fs.freedatafile/1024,3) "Total Avail GB"
FROM
  (SELECT tablespace_name,ROUND((SUM(bytes) / (1024*1024)),3) TotalSpace FROM dba_data_files GROUP BY tablespace_name
   Union
   SELECT tablespace_name,ROUND((SUM(bytes) / (1024*1024)),3) TotalSpace FROM dba_temp_files GROUP BY tablespace_name) df,
                    (Select ft.Tablespace_name,sum(ft.freespace) freespace,sum(ft.freedatafilein) freedatafilein,sum(ft.freedatafile) freedatafile from (select a.Tablespace_name,0 freespace,sum(ROUND(A.MAXBYTES/1024/1024)- ROUND(A.Bytes/1024/1024))  freedatafilein,sum(ROUND(A.MAXBYTES/1024/1024)- ROUND(A.Bytes/1024/1024))  freedatafile  from dba_data_files A  where  A.AUTOEXTENSIBLE='YES' Group By a.Tablespace_name
Union
select B.Tablespace_name,round(sum(B.bytes/1024/1024)) freespace,0 freedatafilein,round(sum(B.bytes/1024/1024)) freedatafile from dba_free_space B group by B.TABLESPACE_NAME) ft
Group By ft.TableSpace_name
Union
  SELECT tablespace_name, ROUND((SUM(bytes) / (1024*1024)),3) freespace,0 freedatafilein,1 freedatafile FROM v$temp_extent_map GROUP BY tablespace_name) fs
  WHERE df.tablespace_name = fs.tablespace_name(+) order by 1;
