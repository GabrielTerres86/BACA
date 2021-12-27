DECLARE
  vr_cdcooper    crapcyb.cdcooper%TYPE := 1;
  vr_nrdconta    crapcyb.nrdconta%TYPE;
  vr_dtmvtolt    crapdat.dtmvtolt%TYPE;
  vr_cdcritic    crapcri.cdcritic%TYPE;
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_dtmancad    VARCHAR2(200);
  vr_diretorio   VARCHAR2(200);
  vr_rollback    VARCHAR2(4000);
  vr_log         VARCHAR2(4000);
  vr_listarq     VARCHAR2(200);
  vr_dsarquivo   CLOB;
  vr_arqrollback UTL_FILE.file_type;
  vr_arqlog      UTL_FILE.file_type;
  vr_exec_erro   EXCEPTION;

  CURSOR cr_crapcyb(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_dsxmlarq CLOB) IS
    SELECT cyb.cdcooper
          ,cyb.cdorigem
          ,cyb.nrdconta
          ,cyb.nrctremp
          ,cyb.dtmancad
      FROM crapcyb cyb
          ,XMLTABLE('registros/contas' 
             PASSING XMLTYPE(pr_dsxmlarq) 
             COLUMNS 
               nrdconta NUMBER(10) PATH 'conta') cta
     WHERE cyb.nrdconta = cta.nrdconta
       AND cyb.cdcooper = pr_cdcooper
       AND cyb.dtdbaixa IS NULL;

  TYPE typ_crapcyb IS TABLE OF cr_crapcyb%ROWTYPE INDEX BY PLS_INTEGER;

  vr_crapcyb typ_crapcyb;

  PROCEDURE obterProximaData(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                            ,pr_dtmvtopr OUT crapdat.dtmvtopr%TYPE
                            ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                            ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    vr_cdcooper PLS_INTEGER := pr_cdcooper;
    vr_dtmvtolt DATE := pr_dtmvtolt;
    vr_dtmvtoan DATE;
    vr_dtmvtopr DATE;
    vr_dtultdia DATE := LAST_DAY(vr_dtmvtolt);
    vr_dtultdma DATE := LAST_DAY(ADD_MONTHS(vr_dtmvtolt, -1));
    vr_blnachou BOOLEAN;
  
    CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE
                     ,pr_dtferiad IN crapfer.dtferiad%TYPE) IS
      SELECT dtferiad
            ,dsferiad
        FROM crapfer
       WHERE cdcooper = pr_cdcooper
         AND dtferiad = pr_dtferiad;
    rw_crapfer cr_crapfer%ROWTYPE;
  BEGIN
    OPEN cr_crapfer(pr_cdcooper => vr_cdcooper
                   ,pr_dtferiad => vr_dtmvtolt);
    FETCH cr_crapfer
      INTO rw_crapfer;
    vr_blnachou := cr_crapfer%FOUND;
    CLOSE cr_crapfer;
    IF vr_blnachou AND NOT (to_char(vr_dtmvtolt, 'mm') = '12' AND to_char(vr_dtmvtolt, 'dd') = '31') THEN
      obterProximaData(pr_cdcooper => pr_cdcooper,
                       pr_dtmvtolt => vr_dtmvtolt + 1,
                       pr_dtmvtopr => pr_dtmvtopr,
                       pr_cdcritic => pr_cdcritic,
                       pr_dscritic => pr_dscritic);
      RETURN;
    ELSIF TO_CHAR(vr_dtmvtolt, 'D') = 7 THEN
      obterProximaData(pr_cdcooper => pr_cdcooper,
                       pr_dtmvtolt => vr_dtmvtolt + 1,
                       pr_dtmvtopr => pr_dtmvtopr,
                       pr_cdcritic => pr_cdcritic,
                       pr_dscritic => pr_dscritic);
      RETURN;
    ELSIF TO_CHAR(vr_dtmvtolt, 'D') = 1 THEN
      obterProximaData(pr_cdcooper => pr_cdcooper,
                       pr_dtmvtolt => vr_dtmvtolt + 1,
                       pr_dtmvtopr => pr_dtmvtopr,
                       pr_cdcritic => pr_cdcritic,
                       pr_dscritic => pr_dscritic);
      RETURN;
    END IF;
  
    vr_dtmvtoan := vr_dtmvtolt - 1;
    LOOP
      OPEN cr_crapfer(pr_cdcooper => vr_cdcooper
                     ,pr_dtferiad => vr_dtmvtoan);
      FETCH cr_crapfer
        INTO rw_crapfer;
      vr_blnachou := cr_crapfer%FOUND;
      CLOSE cr_crapfer;
      IF NOT vr_blnachou AND TO_CHAR(vr_dtmvtoan, 'D') NOT IN (1, 7) THEN
        EXIT;
      END IF;
      vr_dtmvtoan := vr_dtmvtoan - 1;
    END LOOP;
  
    vr_dtmvtopr := vr_dtmvtolt + 1;
    LOOP
      OPEN cr_crapfer(pr_cdcooper => vr_cdcooper
                     ,pr_dtferiad => vr_dtmvtopr);
      FETCH cr_crapfer
        INTO rw_crapfer;
      vr_blnachou := cr_crapfer%FOUND;
      CLOSE cr_crapfer;
      IF NOT vr_blnachou AND TO_CHAR(vr_dtmvtopr, 'D') NOT IN (1, 7) THEN
        EXIT;
      END IF;
      vr_dtmvtopr := vr_dtmvtopr + 1;
    END LOOP;
  
    pr_dtmvtopr := vr_dtmvtopr;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := SQLERRM;
  END obterProximaData;

  PROCEDURE fecharArquivos IS
  BEGIN
    IF utl_file.IS_OPEN(vr_arqrollback) THEN
      fecharArquivo(pr_utlfileh => vr_arqrollback);
    END IF;
  
    IF utl_file.IS_OPEN(vr_arqlog) THEN
      fecharArquivo(pr_utlfileh => vr_arqlog);
    END IF;
  END;
BEGIN
  vr_diretorio := obterParametroSistema(pr_nmsistem => 'CRED'
                                       ,pr_cdacesso => 'ROOT_MICROS') || 'cpd/bacas/PRB0046538'; 
                                       
  listarArquivo(pr_path     => vr_diretorio
               ,pr_pesq     => 'contas.xml'
               ,pr_listarq  => vr_listarq
               ,pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exec_erro;
  END IF;     
  
  IF TRIM(vr_listarq) IS NULL THEN
    vr_dscritic := 'Arquivo contas.xml não encontrado.';
    RAISE vr_exec_erro;
  END IF;              
                                       
  vr_dsarquivo := gene0002.fn_arq_para_clob(pr_caminho => vr_diretorio
                                           ,pr_arquivo => vr_listarq);                                                                                

  abrirArquivo(pr_nmdireto => vr_diretorio
              ,pr_nmarquiv => 'rollback.sql'
              ,pr_tipabert => 'W'
              ,pr_utlfileh => vr_arqrollback
              ,pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exec_erro;
  END IF;

  abrirArquivo(pr_nmdireto => vr_diretorio
              ,pr_nmarquiv => 'log.txt'
              ,pr_tipabert => 'W'
              ,pr_utlfileh => vr_arqlog
              ,pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exec_erro;
  END IF;                 

  escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                     ,pr_des_text => 'BEGIN');

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO btch0001.rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  vr_dtmvtolt := btch0001.rw_crapdat.dtmvtoan;

  OPEN cr_crapcyb(pr_cdcooper => vr_cdcooper
                 ,pr_dsxmlarq => vr_dsarquivo);
  LOOP
    FETCH cr_crapcyb BULK COLLECT
      INTO vr_crapcyb LIMIT 15000;
    EXIT WHEN vr_crapcyb.count = 0;
  
    obterProximaData(pr_cdcooper => vr_cdcooper
                    ,pr_dtmvtolt => vr_dtmvtolt
                    ,pr_dtmvtopr => vr_dtmvtolt
                    ,pr_cdcritic => vr_cdcritic
                    ,pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_erro;
    END IF;
  
    FOR idx IN vr_crapcyb.first .. vr_crapcyb.last LOOP
      IF vr_crapcyb(idx).dtmancad IS NULL THEN
        vr_dtmancad := 'NULL';
      ELSE
        vr_dtmancad := 'to_date(''' || to_char(vr_crapcyb(idx).dtmancad, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'')';
      END IF;
    
      vr_rollback := 'UPDATE crapcyb cyb' || 
                       ' SET cyb.dtmancad = ' || vr_dtmancad ||
                     ' WHERE cyb.cdcooper = ' || vr_crapcyb(idx).cdcooper || 
                       ' AND cyb.cdorigem = ' || vr_crapcyb(idx).cdorigem ||
                       ' AND cyb.nrdconta = ' || vr_crapcyb(idx).nrdconta || 
                       ' AND cyb.nrctremp = ' || vr_crapcyb(idx).nrctremp ||
                       ' AND cyb.dtdbaixa IS NULL;';    
      escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                         ,pr_des_text => vr_rollback);
    END LOOP;
  
    BEGIN
      FORALL idx IN INDICES OF vr_crapcyb SAVE EXCEPTIONS
        UPDATE crapcyb cyb
           SET cyb.dtmancad = vr_dtmvtolt
         WHERE cyb.cdcooper = vr_crapcyb(idx).cdcooper
           AND cyb.cdorigem = vr_crapcyb(idx).cdorigem
           AND cyb.nrdconta = vr_crapcyb(idx).nrdconta
           AND cyb.nrctremp = vr_crapcyb(idx).nrctremp
           AND cyb.dtdbaixa IS NULL;
    EXCEPTION
      WHEN OTHERS THEN
        FOR idx IN 1 .. SQL%bulk_exceptions.count LOOP
          vr_log := 'cdcooper: ' || vr_crapcyb(SQL%BULK_EXCEPTIONS(idx).error_index).cdcooper ||
                    ' cdorigem: ' || vr_crapcyb(SQL%BULK_EXCEPTIONS(idx).error_index).cdorigem ||
                    ' nrdconta: ' || vr_crapcyb(SQL%BULK_EXCEPTIONS(idx).error_index).nrdconta ||
                    ' nrctremp: ' || vr_crapcyb(SQL%BULK_EXCEPTIONS(idx).error_index).nrctremp ||
                    ' Erro: ' || SQLERRM;
          escreveLinhaArquivo(pr_utlfileh => vr_arqlog
                             ,pr_des_text => vr_log);
        END LOOP;
    END;
  
    COMMIT;
  END LOOP;
  CLOSE cr_crapcyb;

  escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                     ,pr_des_text => 'COMMIT;');
  escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
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
