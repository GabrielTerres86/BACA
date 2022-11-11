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
  vr_nrdconta        cecred.crapass.nrdconta%TYPE;

  vr_inrisco_atraso_original cecred.crapris.innivris%TYPE;
  vr_inrisco_atraso_novo     cecred.crapris.innivris%TYPE;
  vr_inrisco_atraso          cecred.crapris.innivris%TYPE;
  
  CURSOR cr_acordo(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                  ,pr_nracordo IN cecred.tbrecup_acordo.nracordo%TYPE
                  ,pr_nrctremp IN cecred.tbrecup_acordo_contrato.nrctremp%TYPE) IS
    SELECT a.nrdconta
          ,c.inrisco_acordo
      FROM tbrecup_acordo           a
          ,tbrecup_acordo_contrato  c
     WHERE c.nracordo   = a.nracordo
       AND a.cdsituacao = 1
       AND a.cdcooper   = pr_cdcooper
       AND a.nracordo   = pr_nracordo
       AND c.nrctremp   = pr_nrctremp;
  rw_acordo cr_acordo%ROWTYPE;
  
  CURSOR cr_crapris(pr_cdcooper IN cecred.crapris.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapris.nrdconta%TYPE
                   ,pr_nrctremp IN cecred.crapris.nrctremp%TYPE) IS
    SELECT r.qtdiaatr
          ,o.qtparcelas_controle_riscomelhora
          ,o.inrisco_melhora
          ,o.dtrisco_melhora  
          ,o.cdcritica_melhora
          ,o.tpctrato
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
  vr_nmdireto := vr_dsdireto||'cpd/bacas/MELHORA_ACORDO'; 
  vr_nmarqbkp := 'ROLLBACK_MELHORA_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  vr_nmarquiv := 'RISCO_MELHORA_ACORDO.csv';

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
        
        OPEN  btch0001.cr_crapdat(pr_cdcooper => vr_vet_dados(1));
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
        
        OPEN cr_acordo(pr_cdcooper => vr_vet_dados(1)
                      ,pr_nracordo => vr_vet_dados(5)
                      ,pr_nrctremp => vr_vet_dados(3));
        FETCH cr_acordo INTO rw_acordo;
        IF cr_acordo%NOTFOUND THEN
          CLOSE cr_acordo;
          CONTINUE;
        ELSE
          vr_nrdconta := rw_acordo.nrdconta;
          CLOSE cr_acordo;
        END IF;
          
        OPEN cr_crapris(pr_cdcooper => vr_vet_dados(1)
                       ,pr_nrdconta => vr_nrdconta
                       ,pr_nrctremp => vr_vet_dados(3));
        FETCH cr_crapris INTO rw_crapris;
        CLOSE cr_crapris;
          
        vr_inrisco_atraso_original := cecred.risc0004.fn_traduz_nivel_risco(cecred.RISC0004.fn_calcula_risco_atraso(rw_crapris.qtdiaatr));
        vr_inrisco_atraso_novo     := cecred.risc0004.fn_traduz_nivel_risco(vr_vet_dados(6));
        
        vr_inrisco_atraso := greatest(vr_inrisco_atraso_original, vr_inrisco_atraso_novo);
        
        cecred.RISC0004.pc_grava_risco_melhora(pr_cdcooper            => vr_vet_dados(1)
                                              ,pr_nrdconta            => vr_nrdconta
                                              ,pr_nrctremp            => vr_vet_dados(3)
                                              ,pr_tpctrato            => rw_crapris.tpctrato
                                              ,pr_qtcontrole_melhora  => rw_crapris.qtparcelas_controle_riscomelhora
                                              ,pr_inrisco_melhora     => vr_inrisco_atraso
                                              ,pr_dtrisco_melhora     => rw_crapdat.dtmvtolt
                                              ,pr_dscritic            => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        BEGIN 
          UPDATE cecred.tbrecup_acordo_contrato
             SET inrisco_acordo = vr_inrisco_atraso
           WHERE nracordo = vr_vet_dados(5)
             AND nrctremp = vr_vet_dados(3);
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('Erro ao atualizar atraso de acordo: ' || vr_vet_dados(5) || '  ' || SQLERRM);
        END;
        
        vr_nrdrowid := NULL;
        
        CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_vet_dados(1)
                                   ,pr_cdoperad => 1
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_dsorigem => 'AIMARO'
                                   ,pr_dstransa => 'Atualizacao de risco melhora em Acordo'
                                   ,pr_dttransa => vr_dttransa
                                   ,pr_flgtrans => 1
                                   ,pr_hrtransa => vr_hrtransa
                                   ,pr_idseqttl => 0
                                   ,pr_nmdatela => NULL
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
        
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Acordo/Contrato'
                                        ,pr_dsdadant => vr_vet_dados(5)
                                        ,pr_dsdadatu => vr_vet_dados(3));
                                        
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Risco Melhora'
                                        ,pr_dsdadant => rw_crapris.inrisco_melhora
                                        ,pr_dsdadatu => vr_inrisco_atraso);

        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Risco Atraso'
                                        ,pr_dsdadant => rw_acordo.inrisco_acordo
                                        ,pr_dsdadatu => vr_inrisco_atraso);
                                        
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'UPDATE cecred.tbrisco_operacoes o' || chr(13) || 
                                '   SET o.inrisco_melhora                  = ' || nvl(to_char(rw_crapris.inrisco_melhora), 'null') || chr(13) || 
                                '      ,o.dtrisco_melhora                  = to_date(''' || nvl(to_char(rw_crapris.dtrisco_melhora), '') || ''', ''DD/MM/RRRR'')' || chr(13) || 
                                '      ,o.qtparcelas_controle_riscomelhora = ' || nvl(to_char(rw_crapris.qtparcelas_controle_riscomelhora), 'null') || chr(13) || 
                                '      ,o.cdcritica_melhora                = ' || nvl(to_char(rw_crapris.cdcritica_melhora), 'null') || chr(13) || 
                                ' WHERE o.cdcooper = ' || vr_vet_dados(1) || chr(13) || 
                                '   AND o.nrdconta = ' || vr_nrdconta     || chr(13) || 
                                '   AND o.nrctremp = ' || vr_vet_dados(3) || 
                                ';' ||chr(13)||chr(13), FALSE); 
        
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'UPDATE cecred.crawepr w' || chr(13) || 
                                '   SET w.inrisco_melhora  = ' || nvl(to_char(cecred.RISC0004.fn_traduz_risco(innivris => rw_crapris.inrisco_melhora)), 'null') || chr(13) || 
                                ' WHERE w.cdcooper = ' || vr_vet_dados(1) || chr(13) || 
                                '   AND w.nrdconta = ' || vr_nrdconta     || chr(13) || 
                                '   AND w.nrctremp = ' || vr_vet_dados(3) || 
                                ';' ||chr(13)||chr(13), FALSE); 
        
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'UPDATE cecred.tbrecup_acordo_contrato o' || chr(13) || 
                                '   SET o.inrisco_acordo = '|| vr_inrisco_atraso_original || chr(13) || 
                                ' WHERE o.nracordo = ' || vr_vet_dados(5) || chr(13) || 
                                '   AND o.nrctremp = ' || vr_vet_dados(3) || 
                                ';' ||chr(13)||chr(13), FALSE); 
        
        dbms_output.put_line('Cooperativa: ' || vr_vet_dados(1) || ' ' ||
                             'Conta: '       || vr_vet_dados(2) || ' ' ||
                             'Conta HIG: '   || vr_nrdconta     || ' ' ||
                             'Contrato: '    || vr_vet_dados(3) || ' ' ||
                             'Documento: '   || vr_vet_dados(4) || ' ' ||
                             'Acordo: '      || vr_vet_dados(5) || ' ' ||
                             'Risco: '       || vr_vet_dados(6) || ' ' ||
                             'Original: '    || vr_inrisco_atraso_original || ' ' ||
                             'Novo: '        || vr_inrisco_atraso_novo
                             );
           

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
