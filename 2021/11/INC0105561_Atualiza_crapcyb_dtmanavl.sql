DECLARE
  vr_cdcooper    crapcyb.cdcooper%TYPE;
  vr_cdorigem    crapcyb.cdorigem%TYPE;
  vr_nrdconta    crapcyb.nrdconta%TYPE;
  vr_nrctremp    crapcyb.nrctremp%TYPE;
  vr_dtmvtolt    crapdat.dtmvtolt%TYPE;
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_dtmanavl    VARCHAR2(200);
  vr_diretorio   VARCHAR2(200);  
  vr_setlinha    VARCHAR2(4000);
  vr_rollback    VARCHAR2(4000);
  vr_log         VARCHAR2(4000);  
  vr_arqupdate   UTL_FILE.file_type;
  vr_arqrollback UTL_FILE.file_type;
  vr_arqlog      UTL_FILE.file_type;  
  vr_exec_erro   EXCEPTION;

  CURSOR cr_crapcyb(pr_cdcooper IN crapcyb.cdcooper%TYPE
                   ,pr_cdorigem IN crapcyb.cdorigem%TYPE
                   ,pr_nrdconta IN crapcyb.nrdconta%TYPE
                   ,pr_nrctremp IN crapcyb.nrctremp%TYPE) IS
    SELECT dtmanavl
      FROM crapcyb
     WHERE cdcooper = pr_cdcooper
       AND cdorigem = pr_cdorigem
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND dtdbaixa IS NULL;
  rw_crapcyb cr_crapcyb%ROWTYPE;
BEGIN
  vr_diretorio := obterParametroSistema(pr_nmsistem => 'CRED'
                                       ,pr_cdacesso => 'ROOT_MICROS') || 'cpd/bacas/INC0105561';

  abrirArquivo(pr_nmdireto => vr_diretorio,
               pr_nmarquiv => 'contas.txt',
               pr_tipabert => 'R',
               pr_utlfileh => vr_arqupdate,
               pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exec_erro;
  END IF;
  
  abrirArquivo(pr_nmdireto => vr_diretorio,
               pr_nmarquiv => 'rollback.sql',
               pr_tipabert => 'W',
               pr_utlfileh => vr_arqrollback,
               pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exec_erro;
  END IF;
  
  abrirArquivo(pr_nmdireto => vr_diretorio,
               pr_nmarquiv => 'log.txt',
               pr_tipabert => 'W',
               pr_utlfileh => vr_arqlog,
               pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exec_erro;
  END IF;      

  LOOP
    BEGIN
      vr_cdcooper := NULL;
      vr_cdorigem := NULL;
      vr_nrdconta := NULL;
      vr_nrctremp := NULL;      
    
      IF utl_file.IS_OPEN(vr_arqupdate) THEN
        BEGIN
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqupdate
                                      ,pr_des_text => vr_setlinha);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            EXIT;
        END;
      
        vr_cdcooper := to_number(substr(vr_setlinha, 1, 4));
        vr_cdorigem := to_number(substr(vr_setlinha, 5, 4));
        vr_nrdconta := to_number(substr(vr_setlinha, 9, 8));
        vr_nrctremp := to_number(substr(vr_setlinha, 17, 8));
      
        OPEN cr_crapcyb(pr_cdcooper => vr_cdcooper,
                        pr_cdorigem => vr_cdorigem,
                        pr_nrdconta => vr_nrdconta,
                        pr_nrctremp => vr_nrctremp);
        FETCH cr_crapcyb
          INTO rw_crapcyb;
      
        IF cr_crapcyb%FOUND THEN
          IF rw_crapcyb.dtmanavl IS NULL THEN
            vr_dtmanavl := 'NULL';
          ELSE
            vr_dtmanavl := 'to_date(''' || rw_crapcyb.dtmanavl || ''', ''DD/MM/RRRR'')';
          END IF;
        
          vr_rollback := 'UPDATE crapcyb cyb SET cyb.dtmanavl = ' || vr_dtmanavl ||
                         ' WHERE cyb.cdcooper = ' || vr_cdcooper || 
                           ' AND cyb.cdorigem = ' || vr_cdorigem || 
                           ' AND cyb.nrdconta = ' || vr_nrdconta ||
                           ' AND cyb.nrctremp = ' || vr_nrctremp || 
                           ' AND cyb.dtdbaixa IS NULL;';
        
          escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                             ,pr_des_text => vr_rollback);
                             
          OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
          FETCH btch0001.cr_crapdat
            INTO btch0001.rw_crapdat;
          CLOSE btch0001.cr_crapdat;
            
          vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
        
          UPDATE crapcyb cyb
             SET cyb.dtmanavl = vr_dtmvtolt
           WHERE cyb.cdcooper = vr_cdcooper
             AND cyb.cdorigem = vr_cdorigem
             AND cyb.nrdconta = vr_nrdconta
             AND cyb.nrctremp = vr_nrctremp
             AND cyb.dtdbaixa IS NULL;
          COMMIT;
        ELSE
          vr_log := 'cdcooper - ' || vr_cdcooper || 
                   ' cdorigem - ' || vr_cdorigem || 
                   ' nrdconta - ' || vr_nrdconta || 
                   ' nrctremp - ' || vr_nrctremp || 
                   ' Não encontrado';
                   
          escreveLinhaArquivo(pr_utlfileh => vr_arqlog
                             ,pr_des_text => vr_log);              
        END IF;
      
        CLOSE cr_crapcyb;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        
        vr_log := 'cdcooper - ' || vr_cdcooper || 
                 ' cdorigem - ' || vr_cdorigem || 
                 ' nrdconta - ' || vr_nrdconta || 
                 ' nrctremp - ' || vr_nrctremp || 
                 ' Erro: ' || SQLERRM;
                 
        escreveLinhaArquivo(pr_utlfileh => vr_arqlog
                           ,pr_des_text => vr_log);                 
    END;
  END LOOP;

  IF utl_file.IS_OPEN(vr_arqupdate) THEN
    fecharArquivo(pr_utlfileh => vr_arqupdate);
  END IF;

  IF utl_file.IS_OPEN(vr_arqrollback) THEN
    fecharArquivo(pr_utlfileh => vr_arqrollback);
  END IF;
  
  IF utl_file.IS_OPEN(vr_arqlog) THEN
    fecharArquivo(pr_utlfileh => vr_arqlog);
  END IF;  
EXCEPTION
  WHEN vr_exec_erro THEN
    raise_application_error(-20500, 'Erro ao abrir arquivo: ' || vr_dscritic);
END;
