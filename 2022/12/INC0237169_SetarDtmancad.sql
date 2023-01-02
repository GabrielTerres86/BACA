DECLARE
  vr_cdcooper    cecred.crapcyb.cdcooper%TYPE := 3;
  vr_dtmvtolt    cecred.crapdat.dtmvtolt%TYPE;
  vr_cdcritic    cecred.crapcri.cdcritic%TYPE;
  vr_dscritic    cecred.crapcri.dscritic%TYPE;
  vr_dtmancad    VARCHAR2(200);
  vr_cdcoopcent  VARCHAR2(200) := '6,7,9,11,13,16';
  vr_cdcooprest  VARCHAR2(200) := '1,2,3,5,8,10,12,14';
  vr_cooperativa VARCHAR2(200);
  vr_diretorio   VARCHAR2(200);
  vr_rollback    VARCHAR2(4000);
  vr_log         VARCHAR2(4000);
  vr_arqrollback UTL_FILE.file_type;
  vr_arqlog      UTL_FILE.file_type;
  vr_indice      PLS_INTEGER;
  vr_limite      PLS_INTEGER;
  vr_exec_erro EXCEPTION;

  CURSOR cr_crapcyb(pr_cdcooper IN VARCHAR2) IS
    SELECT c.cdcooper
          ,c.nrdconta
          ,c.cdorigem
          ,c.nrctremp
          ,c.dtmancad
      FROM cecred.crapcyb c
          ,(SELECT DISTINCT a.cdcooper
                           ,a.nrdconta
              FROM cecred.craptfc a
             WHERE (a.cdopetfn IS NULL 
                 OR a.nrdddtfc IS NULL 
                 OR a.nrtelefo IS NULL 
                 OR a.nrdramal IS NULL 
                 OR a.tptelefo IS NULL 
                 OR a.nmpescto IS NULL)) d
     WHERE c.cdcooper = d.cdcooper
       AND c.nrdconta = d.nrdconta
       AND c.dtdbaixa IS NULL
       AND instr(',' || pr_cdcooper || ',', ',' || c.cdcooper || ',') > 0
     ORDER BY c.cdcooper
             ,c.nrdconta
             ,c.cdorigem
             ,c.nrctremp;

  TYPE typ_crapcyb IS TABLE OF cr_crapcyb%ROWTYPE INDEX BY PLS_INTEGER;

  vr_crapcyb typ_crapcyb;

  PROCEDURE obterProximaData(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                            ,pr_dtmvtolt IN cecred.crapdat.dtmvtolt%TYPE
                            ,pr_dtmvtopr OUT cecred.crapdat.dtmvtopr%TYPE
                            ,pr_cdcritic OUT cecred.crapcri.cdcritic%TYPE
                            ,pr_dscritic OUT cecred.crapcri.dscritic%TYPE) IS
    vr_cdcooper PLS_INTEGER := pr_cdcooper;
    vr_dtmvtolt DATE := pr_dtmvtolt;
    vr_dtmvtoan DATE;
    vr_dtmvtopr DATE;
    vr_dtultdia DATE := LAST_DAY(vr_dtmvtolt);
    vr_dtultdma DATE := LAST_DAY(ADD_MONTHS(vr_dtmvtolt, -1));
    vr_blnachou BOOLEAN;
  
    CURSOR cr_crapfer(pr_cdcooper IN cecred.crapfer.cdcooper%TYPE
                     ,pr_dtferiad IN cecred.crapfer.dtferiad%TYPE) IS
      SELECT dtferiad
            ,dsferiad
        FROM cecred.crapfer
       WHERE cdcooper = pr_cdcooper
         AND dtferiad = pr_dtferiad;
    rw_crapfer cr_crapfer%ROWTYPE;
  BEGIN
    OPEN cr_crapfer(pr_cdcooper => vr_cdcooper, pr_dtferiad => vr_dtmvtolt);
    FETCH cr_crapfer
      INTO rw_crapfer;
    vr_blnachou := cr_crapfer%FOUND;
    CLOSE cr_crapfer;
    IF vr_blnachou AND
       NOT (to_char(vr_dtmvtolt, 'mm') = '12' AND to_char(vr_dtmvtolt, 'dd') = '31') THEN
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
      OPEN cr_crapfer(pr_cdcooper => vr_cdcooper, pr_dtferiad => vr_dtmvtoan);
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
      OPEN cr_crapfer(pr_cdcooper => vr_cdcooper, pr_dtferiad => vr_dtmvtopr);
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
      sistema.fecharArquivo(pr_utlfileh => vr_arqrollback);
    END IF;
  
    IF utl_file.IS_OPEN(vr_arqlog) THEN
      sistema.fecharArquivo(pr_utlfileh => vr_arqlog);
    END IF;
  END;
BEGIN
  vr_diretorio := sistema.obterParametroSistema(pr_nmsistem => 'CRED'
                                               ,pr_cdacesso => 'ROOT_MICROS') || 'cpd/bacas/INC0237169';

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

  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH cecred.btch0001.cr_crapdat
    INTO cecred.btch0001.rw_crapdat;
  CLOSE cecred.btch0001.cr_crapdat;

  vr_dtmvtolt := cecred.btch0001.rw_crapdat.dtmvtoan;

  FOR vr_indice IN 1 .. 2 LOOP
    IF vr_indice = 1 THEN
      vr_cooperativa := vr_cdcoopcent;
      vr_limite      := 50000;
    ELSE
      vr_cooperativa := vr_cdcooprest;
      vr_limite      := 15000;
    END IF;
  
    OPEN cr_crapcyb(pr_cdcooper => vr_cooperativa);
    LOOP
      FETCH cr_crapcyb BULK COLLECT
        INTO vr_crapcyb LIMIT vr_limite;
      EXIT WHEN vr_crapcyb.count = 0;
    
      obterProximaData(pr_cdcooper => vr_cdcooper,
                       pr_dtmvtolt => vr_dtmvtolt,
                       pr_dtmvtopr => vr_dtmvtolt,
                       pr_cdcritic => vr_cdcritic,
                       pr_dscritic => vr_dscritic);
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
        sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                                   ,pr_des_text => vr_rollback);
      END LOOP;
    
      BEGIN
        FORALL idx IN INDICES OF vr_crapcyb SAVE EXCEPTIONS
          UPDATE cecred.crapcyb cyb
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
            sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqlog
                                       ,pr_des_text => vr_log);
          END LOOP;
      END;
    
      COMMIT;
    END LOOP;
    CLOSE cr_crapcyb;
  END LOOP;

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
