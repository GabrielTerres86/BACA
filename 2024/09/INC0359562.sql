PL/SQL Developer Test script 3.0
120
-- INC0359562
declare 
  vr_dscritic    cecred.crapcri.dscritic%TYPE;
  vr_diretorio   VARCHAR2(200);
  vr_rollback    VARCHAR2(4000);
  vr_log         VARCHAR2(4000);
  vr_arqrollback UTL_FILE.file_type;
  vr_arqlog      UTL_FILE.file_type;
  vr_exec_erro EXCEPTION;

  CURSOR cr_ris IS
   SELECT t.DTREFERE, t.cdcooper, t.nrdconta, t.nrctremp
         ,t.dtinictr
         ,c.dtdpagto,c.cdorigem
     FROM cecred.crapris t, cecred.crapcyb c
    WHERE t.cdcooper >= 1
      AND t.cdmodali = 101
      AND t.innivris < 10
      AND t.dtrefere = '29/08/2024' --'26/09/2024'
      AND c.cdcooper = t.cdcooper
      AND c.nrdconta = t.nrdconta
      AND c.nrctremp = t.NRCTREMP
      AND c.dtdbaixa IS NULL
      AND c.cdorigem = 1;

  TYPE typ_ris IS TABLE OF cr_ris%ROWTYPE INDEX BY PLS_INTEGER;

  vr_ris typ_ris;

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
                                               ,pr_cdacesso => 'ROOT_MICROS') || 'cpd/bacas/INC0359562';

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

  OPEN cr_ris;
  LOOP
    FETCH cr_ris BULK COLLECT
      INTO vr_ris LIMIT 5000;
    EXIT WHEN vr_ris.count = 0;
  
    FOR idx IN vr_ris.first .. vr_ris.last LOOP
      vr_rollback := 'UPDATE cecred.crapcyb cyb' || 
                       ' SET cyb.dtdpagto = ''' || vr_ris(idx).dtdpagto ||
                     ''' WHERE cyb.cdcooper = ' || vr_ris(idx).cdcooper || 
                       ' AND cyb.nrdconta = ' || vr_ris(idx).nrdconta || 
                       ' AND cyb.nrctremp = ' || vr_ris(idx).nrctremp ||
                       ' AND cyb.cdorigem = ' || vr_ris(idx).cdorigem || ';';
      sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                                 ,pr_des_text => vr_rollback);
    END LOOP;
  
    BEGIN
      FORALL idx IN INDICES OF vr_ris SAVE EXCEPTIONS
        UPDATE cecred.crapcyb cyb
           SET cyb.dtdpagto = vr_ris(idx).dtdpagto
         WHERE cyb.cdcooper = vr_ris(idx).cdcooper
           AND cyb.nrdconta = vr_ris(idx).nrdconta
           AND cyb.nrctremp = vr_ris(idx).nrctremp
           AND cyb.cdorigem = vr_ris(idx).cdorigem
           AND dtdbaixa IS NULL ;
    EXCEPTION
      WHEN OTHERS THEN
        FOR idx IN 1 .. SQL%bulk_exceptions.count LOOP
          vr_log := 'cdcooper: ' || vr_ris(SQL%BULK_EXCEPTIONS(idx).error_index).cdcooper ||
                    ' cdorigem: ' || vr_ris(SQL%BULK_EXCEPTIONS(idx).error_index).cdorigem ||
                    ' nrdconta: ' || vr_ris(SQL%BULK_EXCEPTIONS(idx).error_index).nrdconta ||
                    ' nrctremp: ' || vr_ris(SQL%BULK_EXCEPTIONS(idx).error_index).nrctremp ||
                    ' Erro: ' || SQLERRM;
          sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqlog
                                     ,pr_des_text => vr_log);
        END LOOP;
    END;
  
    COMMIT;
  END LOOP;
  CLOSE cr_ris;

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
0
1
vr_rollback
