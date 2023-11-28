
DECLARE
  vr_exc_erro       EXCEPTION;
  vr_dsdireto       VARCHAR2(2000);
  vr_nmarquiv       VARCHAR2(100);
  vr_dscritic       VARCHAR2(4000);
  vr_ind_arquiv     utl_file.file_type;
  vr_ind_arqlog     utl_file.file_type;
  vr_dslinha        VARCHAR2(4000);
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  vr_dttransa       cecred.craplgm.dttransa%type;
  vr_hrtransa       cecred.craplgm.hrtransa%type;
  vr_nrdrowid       ROWID;
  vr_typ_saida      VARCHAR2(3);
  
  vr_vet_dados      cecred.gene0002.typ_split;

  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);

  CURSOR cr_crapris(pr_cdcooper IN cecred.crapris.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapris.nrdconta%TYPE
                   ,pr_nrctremp IN cecred.crapris.nrctremp%TYPE) IS
    SELECT o.inrisco_rating
      FROM cecred.crapris r, cecred.crapdat d, cecred.tbrisco_operacoes o
     WHERE d.cdcooper = r.cdcooper
       AND r.dtrefere = d.dtmvcentral
       AND o.cdcooper = r.cdcooper
       AND o.nrdconta = r.nrdconta
       AND o.nrctremp = r.nrctremp
       AND r.cdcooper = pr_cdcooper
       AND r.nrdconta = pr_nrdconta
       AND r.nrctremp = pr_nrctremp;
  rw_crapris cr_crapris%ROWTYPE;

  rw_crapdat cecred.btch0001.cr_crapdat%ROWTYPE;
BEGIN

  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'Rollback das informacoes'||chr(13), FALSE);

  vr_dsdireto := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto := vr_dsdireto||'cpd/bacas/RATING'; 
  vr_nmarqbkp := 'ROLLBACK_RATING_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  vr_nmarquiv := 'RISCO_RATING.csv';

  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarquiv  
                          ,pr_tipabert => 'R'          
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                      
  IF vr_dscritic IS NOT NULL THEN
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' Nao foi possivel ler o arquivo de entrada');  
    RAISE vr_exc_erro;
  END IF;
  
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;
  
  BEGIN     

    LOOP
        
      IF utl_file.IS_OPEN(vr_ind_arquiv) THEN

        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv
                                    ,pr_des_text => vr_dslinha);

        vr_vet_dados := gene0002.fn_quebra_string(pr_string => vr_dslinha, pr_delimit => ';');
        
        OPEN cr_crapris(pr_cdcooper => vr_vet_dados(1)
                       ,pr_nrdconta => vr_vet_dados(2)
                       ,pr_nrctremp => vr_vet_dados(3));
        FETCH cr_crapris INTO rw_crapris;
        IF cr_crapris%FOUND THEN
          UPDATE cecred.tbrisco_operacoes a 
             SET a.inrisco_rating = vr_vet_dados(4)
           WHERE a.cdcooper = vr_vet_dados(1)
             AND a.nrdconta = vr_vet_dados(2)
             AND a.nrctremp = vr_vet_dados(3);
          
          gene0002.pc_escreve_xml(vr_dados_rollback
                                 ,vr_texto_rollback
                                 ,'UPDATE cecred.tbrisco_operacoes o' || chr(13) || 
                                  '   SET o.inrisco_rating = ' || nvl(to_char(rw_crapris.inrisco_rating), 'null') || chr(13) || 
                                  ' WHERE o.cdcooper = ' || vr_vet_dados(1) || chr(13) || 
                                  '   AND o.nrdconta = ' || vr_vet_dados(2) || chr(13) || 
                                  '   AND o.nrctremp = ' || vr_vet_dados(3) || 
                                  ';' ||chr(13)||chr(13), FALSE); 
        
        ELSE
          gene0002.pc_escreve_xml(vr_dados_rollback
                                 ,vr_texto_rollback
                                 ,'Contrato nao encontrado - cdcooper = ' || vr_vet_dados(1) ||
                                  ' nrdconta = ' || vr_vet_dados(2) || 
                                  ' nrctremp = ' || vr_vet_dados(3) || 
                                  ';' ||chr(13)||chr(13), FALSE); 
        END IF;
        CLOSE cr_crapris;
          
      END IF;        
    END LOOP;

  EXCEPTION
    WHEN no_data_found THEN        
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  END;   

  gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '|| vr_nmdireto||'/' || vr_nmarquiv || ' '
                                                     || vr_nmdireto||'/' || 'PROC_' || to_char(sysdate,'ddmmyyyy_hh24miss') || vr_nmarquiv
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
  IF NVL(vr_typ_saida,' ') = 'ERR' THEN
    RAISE vr_exc_erro;
  END IF;
          
  
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE); 
             
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             
                                     ,pr_cdprogra  => 'ATENDA'                      
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                
                                     ,pr_dsxml     => vr_dados_rollback             
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp 
                                     ,pr_flg_impri => 'N'                           
                                     ,pr_flg_gerar => 'S'                           
                                     ,pr_flgremarq => 'N'                           
                                     ,pr_nrcopias  => 1                             
                                     ,pr_des_erro  => vr_dscritic);                 
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   
  
  COMMIT;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro: ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, SQLERRM);
END;
