DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RITM0275853_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0275853_script_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'RITM0275853_relatorio_exec.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arquiv2        utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  CURSOR cr_colaborador IS
    SELECT c.cdusured
      , t.cdcooper
      , t.nrdconta
      , t.nrcpfcgc
      , t.idseqttl
      , t.rowid       idregttl
      , t.vlsalari
      , a.flgrestr
    FROM CECRED.tbcadast_colaborador c
    JOIN CECRED.crapttl t ON c.nrcpfcgc = t.nrcpfcgc
                             AND c.cdcooper = t.cdcooper
    JOIN CECRED.crapass a ON t.cdcooper = a.cdcooper
                             and t.nrdconta = a.nrdconta
                             and c.nrcpfcgc = a.nrcpfcgc
    WHERE a.dtdemiss is null
      AND c.flgativo = 'A';
  
  rg_colab          cr_colaborador%ROWTYPE;
  
  vr_nrdrowid       ROWID;
  vr_dscritic_out   VARCHAR2(2000);
  vr_mesref         VARCHAR2(10);
  vr_vlref          CECRED.tbfolha_lanaut.VLRENDA%TYPE;
  vr_dtmvtolt       DATE := SISTEMA.datascooperativa(3).dtmvtolt;
  vr_exception      EXCEPTION;
  
  PROCEDURE pc_busca_rendas_aut_sub(pr_nrdconta   IN crapass.nrdconta%TYPE 
                                   ,pr_cdcooper IN NUMBER
                                   ,pr_dscritic OUT VARCHAR2
                                   ,pr_mesref   OUT VARCHAR2
                                   ,pr_vlrefe   OUT CECRED.tbfolha_lanaut.VLRENDA%TYPE
                                   ) IS
                                
    CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS                              
      SELECT ass.nrdconta
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
         
    CURSOR cr_tbfolha_lanaut(pr_cdcooper crapcop.cdcooper%TYPE
                            ,pr_nrdconta craplcm.nrdconta%TYPE
                            ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT lan.vlrenda, lan.dtmvtolt, his.dshistor, his.cdhistor
        FROM tbfolha_lanaut lan, craphis his
       WHERE lan.cdcooper = pr_cdcooper
         AND lan.nrdconta = pr_nrdconta
         AND lan.dtmvtolt >= pr_dtmvtolt
         AND lan.cdcooper = his.cdcooper
         AND lan.cdhistor = his.cdhistor
       ORDER BY lan.dtmvtolt;
       
    vr_contlan  PLS_INTEGER;   
    vr_mesatual PLS_INTEGER;
    vr_mesante  PLS_INTEGER;
    vr_vltotmes DECIMAL(10,2);
                     
    vr_dsconteu VARCHAR2(4000);          
    vr_hsparfol VARCHAR2(4000);
    vr_qtdfolha PLS_INTEGER;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_des_erro VARCHAR2(10);
    vr_tab_erro gene0001.typ_tab_erro;
    
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    vr_exc_erro EXCEPTION;
    
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_cdoperad VARCHAR2(100);
    vr_referenc VARCHAR2(7);

    vr_codfolha   crapprm.dsvlrprm%TYPE;    
    
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    
    FUNCTION fn_busca_data_ret(pr_dtmvtolt crapdat.dtmvtolt%TYPE) RETURN DATE IS
    BEGIN
      --
      RETURN ADD_MONTHS(  TO_DATE('01'||TO_CHAR(pr_dtmvtolt,'MM/RRRR'),'DD/MM/RRRR')   ,-3);                 
    END fn_busca_data_ret;
    
  BEGIN 
    
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      vr_dscritic := 'Data da DTMVTOLT cooperativa Não encontrada. Coop: ' || pr_cdcooper;
      RAISE vr_exc_erro;
    END IF;
    
    CLOSE btch0001.cr_crapdat;
    
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
                   
    FETCH cr_crapass INTO rw_crapass;
    
    IF cr_crapass%NOTFOUND THEN
       CLOSE cr_crapass;
       vr_dscritic := 'Conta do cooperado Não encontrada: ' || pr_nrdconta || '(' || pr_cdcooper || ')';
       RAISE vr_exc_erro;
    END IF;    

    vr_contlan := 0;
    vr_mesante := 0;
    vr_vltotmes:= 0;

    vr_codfolha := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 0
                                            ,pr_cdacesso => 'COD_FOLHA_RENDA');                           
     
    FOR rw_tbfolha_lanaut IN cr_tbfolha_lanaut(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_dtmvtolt => fn_busca_data_ret(rw_crapdat.dtmvtolt) ) LOOP
      
      vr_mesatual := TO_NUMBER(TO_CHAR(rw_tbfolha_lanaut.dtmvtolt,'MM'));
      
      If gene0002.fn_existe_valor(  vr_codfolha, rw_tbfolha_lanaut.cdhistor, ',' ) = 'S' Then
         continue;
      End if;        
      
      IF vr_mesante <> vr_mesatual THEN
        
        IF vr_vltotmes > 0 THEN  
           vr_vltotmes := 0;             
         END IF;
        
        vr_referenc :=  LPAD(TO_CHAR(vr_mesatual),2,'0')||'/'||TO_CHAR(rw_tbfolha_lanaut.dtmvtolt,'RRRR');
        vr_contlan  := vr_contlan + 1;
        vr_mesante  := vr_mesatual;
        
      END IF;
      
      vr_vltotmes := vr_vltotmes + rw_tbfolha_lanaut.vlrenda;
      
    END LOOP;
    
    pr_mesref := vr_referenc;
    pr_vlrefe := vr_vltotmes;

  EXCEPTION 
    WHEN vr_exc_erro THEN
      
      RAISE_APPLICATION_ERROR(-20000, 'Erro: ' || vr_dscritic);
      
    WHEN OTHERS THEN
      
      RAISE_APPLICATION_ERROR(-20001, 'Erro não tratado: ' || SQLERRM);
                                  
  END pc_busca_rendas_aut_sub;
  

BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0275853';
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic_out);
                          
  IF vr_dscritic_out IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqlog
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arqlog
                          ,pr_des_erro => vr_dscritic_out);
                          
  IF vr_dscritic_out IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  
  vr_count := 0;
  
  OPEN cr_colaborador;
  LOOP
    FETCH cr_colaborador INTO rg_colab;
    EXIT WHEN cr_colaborador%NOTFOUND;
    
    vr_vlref  := 0;
    vr_mesref := '';
  
    pc_busca_rendas_aut_sub(pr_nrdconta  => rg_colab.nrdconta
                           ,pr_cdcooper  => rg_colab.cdcooper
                           ,pr_dscritic  => vr_dscritic_out
                           ,pr_mesref    => vr_mesref
                           ,pr_vlrefe    => vr_vlref );
                           
    IF TRIM(vr_dscritic_out) IS NOT NULL THEN
      RAISE vr_exception;
    END IF;
    
    IF NVL(vr_vlref, 0) > 0 AND NVL(vr_vlref, 0) > NVL(rg_colab.vlsalari, 0) THEN
      
      BEGIN
        
        UPDATE CECRED.crapttl 
          SET vlsalari = vr_vlref
        WHERE ROWID = rg_colab.idregttl;
        
      EXCEPTION
        WHEN OTHERS THEN
          
          vr_dscritic_out := 'Erro ao atualizar a renda na TTL: ' || SQLERRM;
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
            rg_colab.cdcooper || ';' || 
            rg_colab.nrdconta || ';' || 
            rg_colab.nrcpfcgc || ';' ||
            rg_colab.idseqttl || ';' ||
            to_char(rg_colab.vlsalari, 'FM999G999G999D99') || ';' ||
            vr_mesref                                      || ';' ||
            to_char(vr_vlref, 'FM999G999G999D99')          || ';' ||
            'ERRO: ' || vr_dscritic_out
          );
          
          CLOSE cr_colaborador;
          RAISE vr_exception;
          
      END;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'UPDATE CECRED.crapttl SET vlsalari = ' || REPLACE(rg_colab.vlsalari, ',', '.') || ' WHERE ROWID = ''' || rg_colab.idregttl || '''; ');
      
      CECRED.GENE0001.pc_gera_log( pr_cdcooper => rg_colab.cdcooper,
                                   pr_cdoperad => 1,
                                   pr_dscritic => null,
                                   pr_dsorigem => 'Script',
                                   pr_dstransa => 'RITM0275853 - Atualização do valor da renda conforme rendas automáticas.',
                                   pr_dttransa => vr_dtmvtolt,
                                   pr_flgtrans => 1,
                                   pr_hrtransa => gene0002.fn_busca_time,
                                   pr_idseqttl => 1,
                                   pr_nmdatela => 'JOB', 
                                   pr_nrdconta => rg_colab.nrdconta,
                                   pr_nrdrowid => vr_nrdrowid
                                 );
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                      ,pr_nmdcampo  => 'vlsalari'
                                      ,pr_dsdadant  => to_char(rg_colab.vlsalari, 'FM999G999G999D99')
                                      ,pr_dsdadatu  => to_char(vr_vlref, 'FM999G999G999D99')
                                      );
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
        rg_colab.cdcooper || ';' || 
        rg_colab.nrdconta || ';' || 
        rg_colab.nrcpfcgc || ';' ||
        rg_colab.idseqttl || ';' ||
        to_char(rg_colab.vlsalari, 'FM999G999G999D99') || ';' ||
        vr_mesref                                      || ';' ||
        to_char(vr_vlref, 'FM999G999G999D99')          || ';' ||
        'Rendimento atualizado'
      );
      
    ELSE
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
        rg_colab.cdcooper || ';' || 
        rg_colab.nrdconta || ';' || 
        rg_colab.nrcpfcgc || ';' ||
        rg_colab.idseqttl || ';' ||
        to_char(rg_colab.vlsalari, 'FM999G999G999D99') || ';' ||
        vr_mesref                                      || ';' ||
        to_char(vr_vlref, 'FM999G999G999D99')          || ';' ||
        'Não elegível'
      );
      
    END IF;
    
    vr_count := vr_count + 1;
    IF vr_count >= 500 THEN
      COMMIT;
    END IF;
    
  END LOOP;
  
  CLOSE cr_colaborador;
  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic_out );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic_out);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20003, 'Erro: ' || vr_dscritic_out);
    
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20004, 'ERRO NÃO TRATADO: ' || SQLERRM);
    
END;
