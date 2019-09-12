/*
12/06/2019 - Rotina para unificar 2 relatorios em 1 (crrl238 + crrl287) = crrl782 - Jackson Barcellos - AMcom
*/
BEGIN

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
  nls= ''BINARY''
  nls_territory = ''AMERICA''
  nls_time_format = ''HH.MI.SSXFF AM''
  nls_time_tz_format = ''HH.MI.SSXFF AM TZR''
  nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM''
  nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR'''; 
    
  sys.dbms_scheduler.create_job(
    job_name        => 'CECRED.JBCOMPE_UNIFICAR_REL_782',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 
'declare
   CURSOR cr_cooper IS
     SELECT cdcooper
      FROM crapcop
     WHERE CDCOOPER <> 3 
           and FLGATIVO = 1
       ORDER BY cdcooper;

   vr_stprogra                 BINARY_INTEGER;
   vr_infimsol                 BINARY_INTEGER;
   vr_cdcritic                 crapcri.cdcritic%TYPE;
   vr_dscritic                 crapcri.dscritic%TYPE;
   pr_dscritic                 varchar2(4000);
      
   rw_cooper   cr_cooper%ROWTYPE;
       
BEGIN
    FOR rw_cooper IN cr_cooper LOOP
      vr_dscritic := null;  
      COMP0001.pc_gera_rel782(pr_cdcooper => rw_cooper.cdcooper,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
      -- executa o JOB
      IF vr_dscritic IS NOT NULL THEN
         pr_dscritic := pr_dscritic||'cdcooper: '|| rw_cooper.cdcooper || '('||vr_dscritic||')'||CHR(13);
      END IF;
    END LOOP;
    IF pr_dscritic IS NOT NULL THEN
       raise_application_error(-20001, pr_dscritic);
    END IF;   
END;',
    start_date      => TO_TIMESTAMP_TZ(to_date('10/06/2019' ,'DD/MM/RRRR')||' 07:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR'),
    repeat_interval => 'Freq=DAILY;ByDay=Tue,Wed,Thu,Fri,Sat;BYHOUR=07;BYMINUTE=05;BYSECOND=0',
    end_date        => to_date(null),
    job_class       => 'DEFAULT_JOB_CLASS',
    enabled         => TRUE,
    auto_drop       => TRUE,
    comments        => 'Rotina para unificar 2 relatorios em 1 (crrl238 + crrl287) = crrl782');

END;
/
