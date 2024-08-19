DECLARE

  vr_dscritic         VARCHAR2(4000);
  vr_exc_erro         EXCEPTION;

  vr_cdprogra VARCHAR2(50) := 'exp_tbcrd_score';
  vr_dsplsql  VARCHAR2(4000);
  vr_jobname  VARCHAR2(4000);

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     ORDER BY c.cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;

BEGIN

  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_format = ''DD/MM/RRRR''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_numeric_characters = '',.''';

  FOR rw_crapcop IN cr_crapcop LOOP
    vr_jobname := 'expurgoScore_' || TRIM(to_char(rw_crapcop.cdcooper,'09')) || '_';
    vr_dsplsql := 'DECLARE'                                                     || chr(13) ||
                  '  vr_dtlimite_expurgo DATE;'                                 || chr(13) ||
                  'BEGIN'                                                       || chr(13) ||
                  '  SELECT (MAX(DTBASE) - INTERVAL ''12'' MONTH) AS vr_dtlimite_expurgo' || chr(13) ||
                  '    INTO vr_dtlimite_expurgo'                                || chr(13) ||
                  '    FROM CECRED.TBCRD_SCORE'                                 || chr(13) ||
                  '   WHERE CDCOOPER =  '|| rw_crapcop.cdcooper                 || chr(13) ||
                  '     AND CDMODELO IN (3,4)'                                  || chr(13) ||
                  '     AND FLVIGENTE = 0;'                                     || chr(13) ||
                  ' '                                                           || chr(13) ||
                  '  DELETE FROM CECRED.TBCRD_SCORE'                            || chr(13) ||
                  '   WHERE CDCOOPER = '|| rw_crapcop.cdcooper                  || chr(13) ||
                  '     AND CDMODELO IN (3,4)'                                  || chr(13) ||
                  '     AND FLVIGENTE = 0'                                      || chr(13) ||
                  '     AND DTBASE < vr_dtlimite_expurgo;'                      || chr(13) ||
                  ' '                                                           || chr(13) ||
                  '  COMMIT;'                                                   || chr(13) ||
                  'END;';
    cecred.gene0001.pc_submit_job(pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_cdprogra => vr_cdprogra        
                                 ,pr_dsplsql  => vr_dsplsql         
                                 ,pr_dthrexe  => SYSTIMESTAMP       
                                 ,pr_interva  => NULL               
                                 ,pr_jobname  => vr_jobname         
                                 ,pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT null THEN
      vr_dscritic := vr_dscritic || ' - ' || vr_jobname;
      RAISE vr_exc_erro;
    END IF;

  END LOOP;

  vr_jobname := 'expurgoScore_0_';
  vr_dsplsql := 'DECLARE'                                                     || chr(13) ||
                '  vr_dtlimite_expurgo DATE;'                                 || chr(13) ||
                'BEGIN'                                                       || chr(13) ||
                '  SELECT (MAX(DTBASE) - INTERVAL ''12'' MONTH) AS vr_dtlimite_expurgo' || chr(13) ||
                '    INTO vr_dtlimite_expurgo'                                || chr(13) ||
                '    FROM CECRED.TBCRD_SCORE'                                 || chr(13) ||
                '   WHERE CDCOOPER =  0'                                      || chr(13) ||
                '     AND CDMODELO IN (3,4)'                                  || chr(13) ||
                '     AND FLVIGENTE = 0;'                                     || chr(13) ||
                ' '                                                           || chr(13) ||
                '  DELETE FROM CECRED.TBCRD_SCORE'                            || chr(13) ||
                '   WHERE CDCOOPER =  0'                                      || chr(13) ||
                '     AND CDMODELO IN (3,4)'                                  || chr(13) ||
                '     AND FLVIGENTE = 0'                                      || chr(13) ||
                '     AND DTBASE < vr_dtlimite_expurgo;'                      || chr(13) ||
                ' '                                                           || chr(13) ||
                '  COMMIT;'                                                   || chr(13) ||
                'END;';
  cecred.gene0001.pc_submit_job(pr_cdcooper => 3
                               ,pr_cdprogra => vr_cdprogra        
                               ,pr_dsplsql  => vr_dsplsql         
                               ,pr_dthrexe  => SYSTIMESTAMP       
                               ,pr_interva  => NULL               
                               ,pr_jobname  => vr_jobname         
                               ,pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT null THEN
    vr_dscritic := vr_dscritic || ' - ' || vr_jobname;
    RAISE vr_exc_erro;
  END IF;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
