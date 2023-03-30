DECLARE
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'/cpd/bacas/RITM0289165';
  vr_nmarqimp        VARCHAR2(100)  := 'RITM0289165.csv';
  vr_nmarqimpr       VARCHAR2(100)  := 'ROLLBACK_RITM0289165.csv';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquivr     utl_file.file_type;  
  vr_linha           varchar2(5000);
  vr_campo           GENE0002.typ_split;
  vr_texto_padrao    VARCHAR2(200);     
  vr_cdcooper        crapepr.cdcooper%type; 
  vr_nrdconta        crapepr.nrdconta%type; 
  vr_cont            NUMBER(6) := 0;
  vr_nrdrowid        ROWID;
  vr_tem_param       BOOLEAN;
  vr_dscritic        VARCHAR2(32767);
  vr_exc_saida       EXCEPTION;
  
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
  SELECT ass.inpessoa
        ,ass.nrcpfcnpj_base
    FROM cecred.crapass ass
   WHERE ass.cdcooper = pr_cdcooper
     AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  CURSOR cr_param_conta (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_nrdconta crapass.nrdconta%TYPE
                        ,pr_tppessoa crapass.indnivel%TYPE
                        ,pr_nrcpfcnpj_base crapass.nrcpfcnpj_base%TYPE) IS
  SELECT par.flglibera
        ,par.dtvigencia_paramet
    FROM tbcc_param_pessoa_produto par
   WHERE par.cdcooper       = pr_cdcooper
     AND par.nrdconta       = pr_nrdconta
     AND par.tppessoa       = pr_tppessoa
     AND par.nrcpfcnpj_base = pr_nrcpfcnpj_base
     AND par.cdproduto        = 25
     AND par.cdoperac_produto = 1;
  rw_param_conta cr_param_conta%ROWTYPE;  
  
BEGIN 
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        
                          ,pr_nmarquiv => vr_nmarqimp       
                          ,pr_tipabert => 'R'                
                          ,pr_utlfileh => vr_ind_arquiv     
                          ,pr_des_erro => vr_dscritic);     
  IF vr_dscritic IS NOT NULL THEN  
    dbms_output.put_line(vr_dscritic);    
    RAISE vr_exc_saida;
  END IF;   
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        
                          ,pr_nmarquiv => vr_nmarqimpr       
                          ,pr_tipabert => 'W'                
                          ,pr_utlfileh => vr_ind_arquivr     
                          ,pr_des_erro => vr_dscritic);     
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_exc_saida;
  END IF;
  gene0001.pc_escr_linha_arquivo(vr_ind_arquivr,'COOP;CONTA;RESULTADO;OBSERVACAO');
  
  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,
                               pr_des_text => vr_linha);
  LOOP
    BEGIN
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,pr_des_text => vr_linha);
    EXCEPTION
      WHEN no_data_found THEN 
      EXIT;
    END;
      
    vr_cont  := vr_cont+1;
    vr_campo := GENE0002.fn_quebra_string(pr_string => vr_linha, pr_delimit => ';');
      
    vr_cdcooper := GENE0002.fn_char_para_number(vr_campo(1));
    vr_nrdconta := GENE0002.fn_char_para_number(vr_campo(2)); 

    vr_texto_padrao := vr_cdcooper || ';' ||
                       vr_nrdconta || ';';
                       
    vr_dscritic := NULL;                                                                          
      
    OPEN cr_crapass (pr_cdcooper => vr_cdcooper
                    ,pr_nrdconta => vr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
        
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := gene0001.fn_busca_critica(9);
      gene0001.pc_escr_linha_arquivo(vr_ind_arquivr, vr_texto_padrao || 'NOK;' || vr_dscritic);
      CONTINUE;      
    ELSE
      CLOSE cr_crapass;
    END IF;
    
    OPEN cr_param_conta (vr_cdcooper,vr_nrdconta,rw_crapass.inpessoa,rw_crapass.nrcpfcnpj_base);
    FETCH cr_param_conta INTO rw_param_conta;
    vr_tem_param := cr_param_conta%FOUND;
    CLOSE cr_param_conta;                                 

    BEGIN                                    
      IF NOT vr_tem_param THEN
        BEGIN                               
          INSERT INTO cecred.TBCC_PARAM_PESSOA_PRODUTO(cdcooper
                                                      ,nrdconta
                                                      ,tppessoa
                                                      ,nrcpfcnpj_base
                                                      ,cdproduto
                                                      ,cdoperac_produto
                                                      ,flglibera
                                                      ,dtvigencia_paramet)
                                                VALUES(vr_cdcooper
                                                      ,vr_nrdconta
                                                      ,rw_crapass.inpessoa
                                                      ,rw_crapass.nrcpfcnpj_base
                                                      ,25
                                                      ,1
                                                      ,1
                                                      ,NULL);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar parametrização produto conta: '||SQLERRM;
        END;                                                      
      ELSE
        BEGIN
          UPDATE tbcc_param_pessoa_produto par
               SET par.flglibera  = 1
                  ,par.dtvigencia_paramet = NULL
             WHERE par.cdcooper         = vr_cdcooper
               AND par.nrdconta         = vr_nrdconta
               AND par.tppessoa         = rw_crapass.inpessoa
               AND par.nrcpfcnpj_base   = rw_crapass.nrcpfcnpj_base
               AND par.cdproduto        = 25
               AND par.cdoperac_produto = 1;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar parametrização produto conta: '||SQLERRM;
        END;             
      END IF;
                                                  
      INSERT INTO cecred.TBCC_HIST_PARAM_PESSOA_PROD(cdcooper
                                             ,nrdconta
                                             ,tppessoa
                                             ,nrcpfcnpj_base
                                             ,dtoperac
                                             ,dtvigencia_paramet
                                             ,cdproduto
                                             ,cdoperac_produto
                                             ,flglibera
                                             ,idmotivo
                                             ,cdoperad)
                                       VALUES(vr_cdcooper
                                             ,vr_nrdconta
                                             ,rw_crapass.inpessoa
                                             ,rw_crapass.nrcpfcnpj_base
                                             ,SYSDATE
                                             ,NULL
                                             ,25
                                             ,1
                                             ,1
                                             ,19
                                             ,1);                                                    

      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => 1
                          ,pr_dscritic => ''
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                          ,pr_dstransa => 'Desbloqueio manual de Pre Aprovado - RITM0289165'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 0
                          ,pr_nmdatela => 'TELA_ATENDA_PREAPV'
                          ,pr_nrdconta => vr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);                                                                              
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir parametrizacao produto conta RITM0289165: '||SQLERRM;
    END;
                                                                                                                                     
    IF vr_dscritic IS NOT NULL THEN
      gene0001.pc_escr_linha_arquivo(vr_ind_arquivr, vr_texto_padrao || 'NOK;' || vr_dscritic);
      CONTINUE;
    END IF;
      
    gene0001.pc_escr_linha_arquivo(vr_ind_arquivr, vr_texto_padrao || 'OK;');
      
    IF vr_cont = 50 THEN
       vr_cont := 0;
      COMMIT;   
    END IF;      
  END LOOP;
   
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivr); 
  COMMIT;
       
EXCEPTION 
  WHEN OTHERS THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivr); 
    dbms_output.put_line(sqlerrm);
    dbms_output.put_line(sqlcode);
    ROLLBACK;
END;
