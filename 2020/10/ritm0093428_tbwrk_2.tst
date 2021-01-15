PL/SQL Developer Test script 3.0
92
/* ritm0093428 Criação de jobs para apagar os registros de 04/2018 a 05/2020 da tabela tbgen_batch_relatorio_wrk, utilizada para os relatórios de programas que rodam em paralelo. 
Total de registros a serem excluídos: 74.969.546 (Carlos) */
declare  
  intervalo number := 0;--tempo em minutos para o próximo job
  
  PROCEDURE pc_cria_job (pr_comando varchar2, pr_intervalo number) IS
  BEGIN
    sys.dbms_scheduler.create_job(job_name   => dbms_scheduler.generate_job_name('JBDEL_REL_WRK'),
                                  job_type   => 'PLSQL_BLOCK',
                                  job_action => 'DECLARE 
CURSOR cr_batch_relatorio_wrk IS
SELECT rowid FROM tbgen_batch_relatorio_wrk
WHERE dtmvtolt between ' || pr_comando || ';
limite NUMBER(10) := 500000;
TYPE tbrowid IS TABLE OF rowid
INDEX BY PLS_INTEGER;
r_wrk tbrowid;

BEGIN
  OPEN cr_batch_relatorio_wrk;  
  LOOP
    FETCH cr_batch_relatorio_wrk
    BULK COLLECT INTO r_wrk LIMIT limite;

    FORALL indx IN 1 .. r_wrk.COUNT
    DELETE FROM tbgen_batch_relatorio_wrk
    WHERE ROWID = r_wrk(indx);

    COMMIT;
    EXIT WHEN r_wrk.COUNT < limite;
  END LOOP;
  CLOSE cr_batch_relatorio_wrk;
END;',
                                  start_date => sysdate + (intervalo/24/60),
                                  job_class => 'DEFAULT_JOB_CLASS', enabled => true, auto_drop => true);
    intervalo := intervalo + pr_intervalo;
  END pc_cria_job;
  
begin

  EXECUTE IMMEDIATE 'ALTER SESSION SET 
      nls_calendar = ''GREGORIAN''
      nls_comp = ''BINARY''
      nls_date_format = ''DD-MON-RR''
      nls_date_language = ''AMERICAN''
      nls_iso_currency = ''AMERICA''
      nls_language = ''AMERICAN''
      nls_length_semantics = ''BYTE''
      nls_nchar_conv_excp = ''FALSE''
      nls_numeric_characters = ''.,''
      nls_sort = ''BINARY''
      nls_territory = ''AMERICA''
      nls_time_format = ''HH.MI.SSXFF AM''
      nls_time_tz_format = ''HH.MI.SSXFF AM TZR''
      nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM''
      nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR''';

  --viacredi 2018 157.610.317
  pc_cria_job('to_date(''01/04/2018'',''dd/mm/rrrr'') and to_date(''30/04/2018'',''dd/mm/rrrr'') AND cdcooper = 1', 9);-- 8856154
  pc_cria_job('to_date(''01/05/2018'',''dd/mm/rrrr'') and to_date(''31/05/2018'',''dd/mm/rrrr'') AND cdcooper = 1',18);--17831644
  pc_cria_job('to_date(''01/06/2018'',''dd/mm/rrrr'') and to_date(''30/06/2018'',''dd/mm/rrrr'') AND cdcooper = 1',19);--18219191 
  pc_cria_job('to_date(''01/07/2018'',''dd/mm/rrrr'') and to_date(''31/07/2018'',''dd/mm/rrrr'') AND cdcooper = 1',20);--19397710
  pc_cria_job('to_date(''01/08/2018'',''dd/mm/rrrr'') and to_date(''31/08/2018'',''dd/mm/rrrr'') AND cdcooper = 1',21);--20504135
  pc_cria_job('to_date(''01/09/2018'',''dd/mm/rrrr'') and to_date(''30/09/2018'',''dd/mm/rrrr'') AND cdcooper = 1',17);--16912327
  pc_cria_job('to_date(''01/10/2018'',''dd/mm/rrrr'') and to_date(''31/10/2018'',''dd/mm/rrrr'') AND cdcooper = 1',20);--19590737
  pc_cria_job('to_date(''01/11/2018'',''dd/mm/rrrr'') and to_date(''30/11/2018'',''dd/mm/rrrr'') AND cdcooper = 1',19);--18255890
  pc_cria_job('to_date(''01/12/2018'',''dd/mm/rrrr'') and to_date(''31/12/2018'',''dd/mm/rrrr'') AND cdcooper = 1',19);--18042529

  --viacredi 2019 256.130.732
  pc_cria_job('to_date(''01/01/2019'',''dd/mm/rrrr'') and to_date(''31/01/2019'',''dd/mm/rrrr'') AND cdcooper = 1',22);--21199096
  pc_cria_job('to_date(''01/02/2019'',''dd/mm/rrrr'') and to_date(''29/02/2019'',''dd/mm/rrrr'') AND cdcooper = 1',19);--18811959
  pc_cria_job('to_date(''01/03/2019'',''dd/mm/rrrr'') and to_date(''31/03/2019'',''dd/mm/rrrr'') AND cdcooper = 1',19);--18160922 
  pc_cria_job('to_date(''01/04/2019'',''dd/mm/rrrr'') and to_date(''30/04/2019'',''dd/mm/rrrr'') AND cdcooper = 1',21);--20468888
  pc_cria_job('to_date(''01/05/2019'',''dd/mm/rrrr'') and to_date(''31/05/2019'',''dd/mm/rrrr'') AND cdcooper = 1',22);--21849621
  pc_cria_job('to_date(''01/06/2019'',''dd/mm/rrrr'') and to_date(''30/06/2019'',''dd/mm/rrrr'') AND cdcooper = 1',19);--19152963 
  pc_cria_job('to_date(''01/07/2019'',''dd/mm/rrrr'') and to_date(''31/07/2019'',''dd/mm/rrrr'') AND cdcooper = 1',24);--23688719
  pc_cria_job('to_date(''01/08/2019'',''dd/mm/rrrr'') and to_date(''31/08/2019'',''dd/mm/rrrr'') AND cdcooper = 1',23);--22769923
  pc_cria_job('to_date(''01/09/2019'',''dd/mm/rrrr'') and to_date(''30/09/2019'',''dd/mm/rrrr'') AND cdcooper = 1',22);--21869353
  pc_cria_job('to_date(''01/10/2019'',''dd/mm/rrrr'') and to_date(''31/10/2019'',''dd/mm/rrrr'') AND cdcooper = 1',25);--24376047
  pc_cria_job('to_date(''01/11/2019'',''dd/mm/rrrr'') and to_date(''30/11/2019'',''dd/mm/rrrr'') AND cdcooper = 1',21);--21429718
  pc_cria_job('to_date(''01/12/2019'',''dd/mm/rrrr'') and to_date(''31/12/2019'',''dd/mm/rrrr'') AND cdcooper = 1',23);--22353523

  --viacredi 2020 123.551.074
  pc_cria_job('to_date(''01/01/2020'',''dd/mm/rrrr'') and to_date(''31/01/2020'',''dd/mm/rrrr'') AND cdcooper = 1',24);--23897345
  pc_cria_job('to_date(''01/02/2020'',''dd/mm/rrrr'') and to_date(''28/02/2020'',''dd/mm/rrrr'') AND cdcooper = 1',20);--19871903
  pc_cria_job('to_date(''01/03/2020'',''dd/mm/rrrr'') and to_date(''31/03/2020'',''dd/mm/rrrr'') AND cdcooper = 1',26);--25030479 
  pc_cria_job('to_date(''01/04/2020'',''dd/mm/rrrr'') and to_date(''30/04/2020'',''dd/mm/rrrr'') AND cdcooper = 1',27);--26333064
  pc_cria_job('to_date(''01/05/2020'',''dd/mm/rrrr'') and to_date(''31/05/2020'',''dd/mm/rrrr'') AND cdcooper = 1',29);--28418283

  --Total: 537.292.123 registros

end;
0
0
