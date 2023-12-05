DECLARE
  vr_dscritic    cecred.crapcri.dscritic%TYPE;
  vr_diretorio   VARCHAR2(200);
  vr_rollback    VARCHAR2(4000);
  vr_log         VARCHAR2(4000);
  vr_arqrollback UTL_FILE.file_type;
  vr_arqlog      UTL_FILE.file_type;
  vr_exec_erro EXCEPTION;

  CURSOR cr_crapcyb IS
    SELECT a.cdcooper
          ,a.nrdconta
          ,a.cdorigem
          ,a.nrctremp
          ,a.vlsdprej
      FROM cecred.crapcyb a
     WHERE a.cdorigem = 3
       AND a.dtdbaixa IS NULL
       AND a.flgpreju = 1
       AND a.vlsdprej > 0
       AND EXISTS (SELECT 1
              FROM cecred.crapcyb b
             WHERE b.cdcooper = a.cdcooper
               AND b.cdorigem = 2
               AND b.nrdconta = a.nrdconta
               AND b.nrctremp = a.nrctremp
               AND b.dtdbaixa IS NULL)
     ORDER BY a.cdcooper
             ,a.nrdconta
             ,a.cdorigem
             ,a.nrctremp;

  TYPE typ_crapcyb IS TABLE OF cr_crapcyb%ROWTYPE INDEX BY PLS_INTEGER;

  vr_crapcyb typ_crapcyb;

  PROCEDURE fecharArquivos IS
  BEGIN
    IF utl_file.IS_OPEN(vr_arqrollback) THEN
      sistema.fecharArquivo(pr_utlfileh => vr_arqrollback);
    END IF;
  
    IF utl_file.IS_OPEN(vr_arqlog) THEN
      sistema.fecharArquivo(pr_utlfileh => vr_arqlog);
    END IF;
  END;
BEGIN
  vr_diretorio := sistema.obterParametroSistema(pr_nmsistem => 'CRED'
                                               ,pr_cdacesso => 'ROOT_MICROS') || 'cpd/bacas/INC0294274';

  sistema.abrirArquivo(pr_nmdireto => vr_diretorio,
                       pr_nmarquiv => 'rollback.sql',
                       pr_tipabert => 'W',
                       pr_utlfileh => vr_arqrollback,
                       pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exec_erro;
  END IF;

  sistema.abrirArquivo(pr_nmdireto => vr_diretorio,
                       pr_nmarquiv => 'log.txt',
                       pr_tipabert => 'W',
                       pr_utlfileh => vr_arqlog,
                       pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exec_erro;
  END IF;

  sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                             ,pr_des_text => 'BEGIN');

  OPEN cr_crapcyb;
  LOOP
    FETCH cr_crapcyb BULK COLLECT
      INTO vr_crapcyb LIMIT 5000;
    EXIT WHEN vr_crapcyb.count = 0;
  
    FOR idx IN vr_crapcyb.first .. vr_crapcyb.last LOOP
      vr_rollback := 'UPDATE cecred.crapcyb cyb' || 
                       ' SET cyb.vlsdprej = ' || vr_crapcyb(idx).vlsdprej ||
                     ' WHERE cyb.cdcooper = ' || vr_crapcyb(idx).cdcooper || 
                       ' AND cyb.cdorigem = ' || vr_crapcyb(idx).cdorigem ||
                       ' AND cyb.nrdconta = ' || vr_crapcyb(idx).nrdconta || 
                       ' AND cyb.nrctremp = ' || vr_crapcyb(idx).nrctremp || ';';
      sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                                 ,pr_des_text => vr_rollback);
    END LOOP;
  
    BEGIN
      FORALL idx IN INDICES OF vr_crapcyb SAVE EXCEPTIONS
        UPDATE cecred.crapcyb cyb
           SET cyb.vlsdprej = 0
         WHERE cyb.cdcooper = vr_crapcyb(idx).cdcooper
           AND cyb.cdorigem = vr_crapcyb(idx).cdorigem
           AND cyb.nrdconta = vr_crapcyb(idx).nrdconta
           AND cyb.nrctremp = vr_crapcyb(idx).nrctremp;
    EXCEPTION
      WHEN OTHERS THEN
        FOR idx IN 1 .. SQL%bulk_exceptions.count LOOP
          vr_log := 'cdcooper: ' || vr_crapcyb(SQL%BULK_EXCEPTIONS(idx).error_index).cdcooper ||
                    ' cdorigem: ' || vr_crapcyb(SQL%BULK_EXCEPTIONS(idx).error_index).cdorigem ||
                    ' nrdconta: ' || vr_crapcyb(SQL%BULK_EXCEPTIONS(idx).error_index).nrdconta ||
                    ' nrctremp: ' || vr_crapcyb(SQL%BULK_EXCEPTIONS(idx).error_index).nrctremp ||
                    ' Erro: ' || SQLERRM;
          sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqlog
                                     ,pr_des_text => vr_log);
        END LOOP;
    END;
  
    COMMIT;
  END LOOP;
  CLOSE cr_crapcyb;

  sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                             ,pr_des_text => 'COMMIT;');
  sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                             ,pr_des_text => 'END;');
  fecharArquivos;
EXCEPTION
  WHEN vr_exec_erro THEN
    fecharArquivos;
    raise_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    fecharArquivos;
    raise_application_error(-20500, SQLERRM);
END;
