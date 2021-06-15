---atualizar cdageimp nos limites e borderos cheque e titulo
DECLARE

  -- Tratamento de erros
  vr_des_erro VARCHAR2(1000);
  vr_dscritic VARCHAR2(1000);
  vr_exc_erro EXCEPTION;

  --variaveis arquivos
  vr_nmarq_rollback VARCHAR2(100);

  vr_handle     utl_file.file_type;
  vr_handle_log utl_file.file_type;
  vr_registros  NUMBER(10) := 0;

  CURSOR c1 IS
    SELECT craplim.cdopelib
          ,crapope.cdpactra
          ,crawlim.cdagenci
          ,crawlim.cdageimp
          ,crawlim.cdcooper
          ,crawlim.nrdconta
          ,crawlim.tpctrlim
          ,crawlim.nrctrlim
      FROM craplim
          ,crapope
          ,crawlim
     WHERE craplim.cdcooper >= 1
       AND craplim.dtinivig >= '01/01/2020'
       AND craplim.insitlim = 2
       AND crapope.cdcooper = craplim.cdcooper
       AND crapope.cdoperad = craplim.cdopelib
       AND crawlim.cdcooper = craplim.cdcooper
       AND crawlim.nrdconta = craplim.nrdconta
       AND crawlim.nrctrlim = craplim.nrctrlim
       AND crawlim.tpctrlim = craplim.tpctrlim
       AND crawlim.insitlim = craplim.insitlim
       AND NVL(crawlim.cdageimp, 0) = 0;

  CURSOR c2 IS
    SELECT crapope.cdpactra
          ,a.cdopelib
          ,a.cdageimp
          ,a.cdagenci
          ,a.cdcooper
          ,a.nrborder
          ,a.nrdconta
      FROM crapbdc a
          ,crapope
     WHERE a.cdcooper >= 1
       AND a.dtlibbdc >= '01/01/2020'
       AND NVL(a.cdageimp, 0) = 0
       AND crapope.cdcooper = a.cdcooper
       AND crapope.cdoperad = a.cdopelib;

  CURSOR c3 IS
    SELECT crapope.cdpactra
          ,a.cdopelib
          ,a.cdageimp
          ,a.cdagenci
          ,a.cdcooper
          ,a.nrborder
          ,a.nrdconta
      FROM crapbdt a
          ,crapope
     WHERE a.cdcooper >= 1
       AND a.dtlibbdt >= '01/01/2020'
       AND NVL(a.cdageimp, 0) = 0
       AND crapope.cdcooper = a.cdcooper
       AND crapope.cdoperad = a.cdopelib;
     
     vr_dsdireto varchar2(100);

BEGIN

  -- Banco individual
 -- vr_nmarq_rollback := '/progress/t0031664/micros/cpd/bacas/RITM0146650_ROLLBACK.sql';

  -- Banco Test      
  -- \\pkgtest\micros---  /microstst/cecred/Elton/
  --  vr_nmarq_rollback := '/microstst/cecred/Elton/RITM0127089_ROLLBACK_RENOVA.sql';

  -- caminho para produção:
     vr_dsdireto       := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/';
     vr_nmarq_rollback := vr_dsdireto||'RITM0146650_ROLLBACK.sql';

  /* Abrir o arquivo de rollback */
  gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback,
                           pr_tipabert => 'W' --> Modo de abertura (R,W,A)
                          ,
                           pr_utlfileh => vr_handle --> Handle do arquivo aberto
                          ,
                           pr_des_erro => vr_des_erro);
  IF vr_des_erro IS NOT NULL THEN
    vr_dscritic := 'Erro ao abrir arquivo de rollback: ' || vr_des_erro;
    RAISE vr_exc_erro;
  END IF;

  -- todos os limites
  FOR r1 IN c1 LOOP
    BEGIN
      UPDATE cecred.crawlim a
         SET a.cdageimp = r1.cdpactra
       WHERE a.cdcooper = r1.cdcooper
         AND a.nrdconta = r1.nrdconta
         AND a.nrctrlim = r1.nrctrlim
         AND a.tpctrlim = r1.tpctrlim;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar crawlim. ' || SQLERRM;
        --Sair
        RAISE vr_exc_erro;
    END;
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                   pr_des_text => 'UPDATE crawlim SET ' || ' cdageimp = 0 ' ||
                                                  ' WHERE cdcooper = ' || r1.cdcooper ||
                                                  '   AND nrdconta = ' || r1.nrdconta ||
                                                  '  AND nrctrlim = ' || r1.nrctrlim ||
                                                  '  AND tpctrlim = ' || r1.tpctrlim || ';');
  
  END LOOP;

  -- bordero de cheque
  FOR r2 IN c2 LOOP
    BEGIN
      UPDATE cecred.crapbdc a
         SET a.cdageimp = r2.cdpactra
       WHERE a.cdcooper = r2.cdcooper
         AND a.nrdconta = r2.nrdconta
         AND a.nrborder = r2.nrborder;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar crapbdc. ' || SQLERRM;
        --Sair
        RAISE vr_exc_erro;
    END;
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                   pr_des_text => 'UPDATE crapbdc SET ' || ' cdageimp = 0 ' ||
                                                  ' WHERE cdcooper = ' || r2.cdcooper ||
                                                  '   AND nrdconta = ' || r2.nrdconta ||
                                                  '  AND nrborder = ' || r2.nrborder || ';');
  END LOOP;

  -- bordero de titulo
  FOR r3 IN c3 LOOP
    BEGIN
      UPDATE cecred.crapbdt a
         SET a.cdageimp = r3.cdpactra
       WHERE a.cdcooper = r3.cdcooper
         AND a.nrdconta = r3.nrdconta
         AND a.nrborder = r3.nrborder;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar crapbdt. ' || SQLERRM;
        --Sair
        RAISE vr_exc_erro;
    END;
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                   pr_des_text => 'UPDATE crapbdt SET ' || ' cdageimp = 0 ' ||
                                                  ' WHERE cdcooper = ' || r3.cdcooper ||
                                                  '   AND nrdconta = ' || r3.nrdconta ||
                                                  '  AND nrborder = ' || r3.nrborder || ';');
  END LOOP;

  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle, pr_des_text => 'COMMIT;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle, pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    ROLLBACK;
  
END;
/
