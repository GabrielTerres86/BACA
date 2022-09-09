DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0213389_cpfs_rendas.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'INC0213389_ROLLBACK_natjur.sql';
  vr_nmarqlog           VARCHAR2(50) := 'INC0213389_log_execucao.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_ind_arquiv         UTL_FILE.FILE_TYPE;
  vr_ind_arqlog         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_nrdrowid    ROWID;
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
  CURSOR cr_natjur IS
    SELECT A.NRDCONTA
      , A.CDCOOPER
      , J.NATJURID               natjur_aimaro
      , JC.CDNATUREZA_JURIDICA   natjur_centralizado
    FROM CECRED.CRAPJUR J
    JOIN CECRED.CRAPASS A ON J.NRDCONTA = A.NRDCONTA
                      AND J.CDCOOPER = A.CDCOOPER
    JOIN CECRED.TBCADAST_PESSOA P ON A.NRCPFCGC = P.NRCPFCGC
    JOIN CECRED.TBCADAST_PESSOA_JURIDICA JC ON P.IDPESSOA = JC.IDPESSOA
    WHERE j.natjurid = 0
      and j.natjurid <> NVL(jc.cdnatureza_juridica, 0)
    ;
  
  rw_natjur  cr_natjur%ROWTYPE;
  
  CURSOR cr_crapdat IS
    SELECT d.dtmvtolt
    FROM CECRED.crapdat d
    WHERE d.cdcooper = 1;
    
  vr_dtmvtolt CECRED.crapdat.DTMVTOLT%TYPE;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0213389';
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqlog
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arqlog
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');

  OPEN cr_crapdat();
  FETCH cr_crapdat INTO vr_dtmvtolt;
  CLOSE cr_crapdat;
  
  vr_count := 0;
  
  OPEN cr_natjur;
  LOOP
    FETCH cr_natjur INTO rw_natjur;
    EXIT WHEN cr_natjur%NOTFOUND;
    
    vr_count := vr_count + 1;
    
    BEGIN
      
      UPDATE CECRED.CRAPJUR
        SET natjurid = rw_natjur.natjur_centralizado
      WHERE NRDCONTA = rw_natjur.nrdconta
        AND CDCOOPER = rw_natjur.cdcooper;
      
    EXCEPTION 
      WHEN OTHERS THEN
        
        vr_dscritic := 'Erro ao atualizar CRAPJUR para Cooper/Conta ' || rw_natjur.cdcooper || '/' || rw_natjur.nrdconta || ' - ' || SQLERRM;
        RAISE vr_exception;
        
    END;
    
    IF SQL%ROWCOUNT > 1 THEN
      vr_dscritic := SQL%ROWCOUNT || ' registros atualizado na CRAPJUR para Cooper/Conta ' || rw_natjur.cdcooper || '/' || rw_natjur.nrdconta;
      RAISE vr_exception;
    END IF;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, '    UPDATE CECRED.CRAPJUR '
                                    || '   SET natjurid = ' || rw_natjur.natjur_aimaro
                                    || ' WHERE nrdconta = ' || rw_natjur.nrdconta
                                    || '   AND cdcooper = ' || rw_natjur.cdcooper || '; ' );
    
    CECRED.GENE0001.pc_gera_log( pr_cdcooper => rw_natjur.cdcooper,
                                 pr_cdoperad => 1,
                                 pr_dscritic => null,
                                 pr_dsorigem => 'Script',
                                 pr_dstransa => 'INC0213389 - Ajuste de natureza jurídica conforme dados do centralizado',
                                 pr_dttransa => vr_dtmvtolt,
                                 pr_flgtrans => 1,
                                 pr_hrtransa => gene0002.fn_busca_time,
                                 pr_idseqttl => 1,
                                 pr_nmdatela => 'JOB', 
                                 pr_nrdconta => rw_natjur.nrdconta,
                                 pr_nrdrowid => vr_nrdrowid
                                );
    
    CECRED.GENE0001.pc_gera_log_item( pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Natureza Jurídica'
                                     ,pr_dsdadant => to_char( rw_natjur.natjur_aimaro )
                                     ,pr_dsdadatu => to_char( rw_natjur.natjur_centralizado ) 
                                    );
    
    IF vr_count >= 500 THEN
      
      COMMIT;
      vr_count := 0;
      
    END IF;
    
  END LOOP;
  
  CLOSE cr_natjur;
  
  COMMIT;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
EXCEPTION
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);

    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    
END;
