DECLARE

  vr_aux_ambiente INTEGER       := 1;            
  vr_aux_diretor  VARCHAR2(100) := 'INC349470'; 
  vr_aux_arquivo  VARCHAR2(100) := 'contas';    

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;

  vr_input_file UTL_FILE.FILE_TYPE; 
  vr_handle     UTL_FILE.FILE_TYPE; 
  vr_handle_log UTL_FILE.FILE_TYPE;
  vr_handle_log_lanc UTL_FILE.FILE_TYPE; 
  vr_nrcontad   PLS_INTEGER := 0;
  vr_idx_carga  PLS_INTEGER;                            
  vr_setlinha   VARCHAR2(5000);                
  vr_vet_campos gene0002.typ_split; 
  
  vr_nmarq_carga    VARCHAR2(200);
  vr_nmarq_log      VARCHAR2(200);
  vr_nmarq_log_lanc VARCHAR2(200);
  vr_nmarq_rollback VARCHAR2(200);
  
  rw_crapdat        BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_erro       VARCHAR2(10000);   
  vr_aux_cdcooper   NUMBER;
  vr_aux_nrdconta   NUMBER;
  vr_aux_inpessoa   VARCHAR2(10);
  vr_aux_adp7       crapsld.vlsmnmes%TYPE;
  vr_ttl_vlsmnmes   crapsld.vlsmnmes%TYPE;
  vr_aux_lim7       crapsld.vlsmnesp%TYPE;
  vr_ttl_vlsmnesp   crapsld.vlsmnesp%TYPE;
  vr_aux_vliofmes   NUMBER;
  vr_aux_ttliof     NUMBER;
  vr_aux_juros_ttl  crapsld.vljuresp%TYPE;
  vr_aux_limite_juros craplrt.txmensal%TYPE;
  vr_aux_adp_juros  craplrt.txmensal%TYPE;
  vr_dstextab       craptab.dstextab%TYPE;
  vr_seqdig         NUMBER(10);
  vr_cdbccxlt       CONSTANT PLS_INTEGER := 100; 
  vr_incrineg       INTEGER;
  vr_tab_retorno    LANC0001.typ_reg_retorno;
  vr_aux_iof_prop   NUMBER;
  vr_aux_pix_ttl    NUMBER;
  vr_vliofpri       NUMBER := 0; 
  vr_vliofadi       NUMBER := 0; 
  vr_vliofcpl       NUMBER := 0; 
  vr_flgimune       PLS_INTEGER;
  vr_vltaxa_iof_principal NUMBER := 0;
  vr_aux_ttl_utilizado NUMBER := 0;
  vr_aux_limite_util NUMBER := 0;
  vr_aux_pix_ttl_range NUMBER;
  vr_aux_limite_juros_range craplrt.txmensal%TYPE;
  vr_aux_iof_prop_range craplrt.txmensal%TYPE;
  
  TYPE typ_reg_carga IS RECORD(cdcooper  crapass.cdcooper%TYPE
                              ,nrdconta  crapass.nrdconta%TYPE);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;
  
  TYPE typ_reg_carga_sda IS RECORD(vllimcre  crapsda.vllimcre%TYPE
                                  ,vllimutl7 crapsda.vllimutl%TYPE
                                  ,vladdutl7 crapsda.vladdutl%TYPE);
  TYPE typ_tab_carga_sda IS TABLE OF typ_reg_carga_sda INDEX BY PLS_INTEGER;
  vr_tab_carga_sda typ_tab_carga_sda;
     
  CURSOR cr_crapsda(pr_cdcooper IN crapsda.cdcooper%TYPE     
                   ,pr_nrdconta IN crapsda.nrdconta%TYPE) IS     
       SELECT sda.cdcooper
             ,sda.nrdconta
             ,sda.dtmvtolt
             ,sda.vllimcre 
             ,sda.vllimutl 
             ,sda.vladdutl 
             ,sda.vlsddisp
         FROM crapsda sda
        WHERE sda.cdcooper = pr_cdcooper
          AND sda.nrdconta = pr_nrdconta
          AND sda.dtmvtolt = to_date('27/04/2022', 'dd/mm/RRRR')
        ORDER BY sda.dtmvtolt;
    rw_crapsda cr_crapsda%ROWTYPE;
       
   CURSOR cr_crapsld(pr_cdcooper IN crapsld.cdcooper%TYPE    
                    ,pr_nrdconta IN crapsld.nrdconta%TYPE) IS    
     SELECT sld.vlsmnmes
           ,sld.vlsmnesp
           ,sld.vlsdchsl
           ,sld.vliofmes
       FROM crapsld sld
      WHERE sld.cdcooper = pr_cdcooper
        AND sld.nrdconta = pr_nrdconta;
    rw_crapsld cr_crapsld%ROWTYPE;
       
   CURSOR cr_ioflanc(pr_cdcooper IN tbgen_iof_lancamento.cdcooper%TYPE    
                    ,pr_nrdconta IN tbgen_iof_lancamento.nrdconta%TYPE) IS 
     SELECT IDLANCTO
           ,CDCOOPER
           ,NRDCONTA
           ,DTMVTOLT
           ,TPPRODUTO
           ,TPIOF
           ,NRCONTRATO
           ,IDLAUTOM
           ,DTMVTOLT_LCM
           ,CDAGENCI_LCM
           ,CDBCCXLT_LCM
           ,NRDOLOTE_LCM
           ,NRSEQDIG_LCM
           ,INIMUNIDADE
           ,VLIOF
           ,NRPARCELA_EPR
           ,VLIOF_PRINCIPAL
           ,VLIOF_ADICIONAL
           ,VLIOF_COMPLEMENTAR
           ,VLTAXAIOF_PRINCIPAL
           ,VLTAXAIOF_ADICIONAL
           ,NRACORDO
           ,IDLANCTO_PREJUIZO
       FROM tbgen_iof_lancamento a
      WHERE a.cdcooper = pr_cdcooper
        AND a.nrdconta = pr_nrdconta
        AND a.tpproduto = 5
        AND a.tpiof IN (1, 2)
        AND a.dtmvtolt = to_date('27/04/2022', 'dd/mm/RRRR');
    rw_ioflanc cr_ioflanc%ROWTYPE;
    
    
    CURSOR cr_craplrt (pr_cdcooper IN craplrt.cdcooper%TYPE
                      ,pr_nrdconta IN craplim.nrdconta%TYPE) IS
     SELECT lrt.txmensal
        FROM craplim lim
            ,craplrt lrt
       WHERE lim.cdcooper = lrt.cdcooper
         AND lim.cddlinha = lrt.cddlinha
         AND lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.tpctrlim = 1 
         AND lim.insitlim = 2;
    rw_craplrt cr_craplrt%ROWTYPE;
   
   
    CURSOR cr_lanc_pix(pr_cdcooper IN tbgen_iof_lancamento.cdcooper%TYPE    
                      ,pr_nrdconta IN tbgen_iof_lancamento.nrdconta%TYPE) IS   
       SELECT NVL(SUM(lp.vllanmto), 0) total_pix
         FROM TBCC_LANCAMENTOS_PENDENTES LP
             ,TBPIX_TRANSACAO            T
             ,CRAPLCM                    L
        WHERE T.IDTRANSACAO = LP.IDTRANSACAO
          AND L.DTMVTOLT = LP.DTMVTOLT
          AND L.CDCOOPER = LP.CDCOOPER
          AND L.NRDCONTA = LP.NRDCONTA
          AND L.NRDOCMTO = LP.IDTRANSACAO
          AND LP.DTMVTOLT = to_date('27/04/2022', 'dd/mm/RRRR')
          AND LP.CDCOOPER = pr_cdcooper
          AND LP.NRDCONTA = pr_nrdconta
          AND LP.DHTRANSACAO BETWEEN TO_DATE('27/04/2022 09:50', 'dd/mm/RRRR HH24:MI') AND
              TO_DATE('27/04/2022 11:35', 'dd/mm/RRRR HH24:MI')
          AND LP.IDSITUACAO = 'P'
          AND T.IDTIPO_TRANSACAO = 'P'
          AND lp.cdhistor = l.cdhistor;   
    rw_lanc_pix cr_lanc_pix%ROWTYPE;
 

   CURSOR cr_cooperado(pr_cdcooper IN crapass.cdcooper%TYPE    
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS   
        SELECT ass.inpessoa
              ,(SELECT jur.natjurid
                  FROM crapjur jur
                 WHERE ass.cdcooper = jur.cdcooper
                   AND ass.nrdconta = jur.nrdconta) natjurid
              ,(SELECT jur.tpregtrb
                  FROM crapjur jur
                 WHERE ass.cdcooper = jur.cdcooper
                   AND ass.nrdconta = jur.nrdconta) tpregtrb
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
  rw_cooperado cr_cooperado%ROWTYPE;          
       
BEGIN 

  IF vr_aux_ambiente = 1 THEN   
    vr_nmarq_carga    := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';           
    vr_nmarq_log      := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
    vr_nmarq_log_lanc := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG_LANCAMENTOS.txt'; 
    vr_nmarq_rollback := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
  ELSIF vr_aux_ambiente = 2 THEN        
    vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';         
    vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';     
    vr_nmarq_log_lanc := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG_LANCAMENTOS.txt'; 
    vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
  ELSIF vr_aux_ambiente = 3 THEN 
    vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';        
    vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';     
    vr_nmarq_log_lanc := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG_LANCAMENTOS.txt';
    vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
  ELSE
    vr_dscritic := 'Erro ao apontar ambiente de execucao.';
    RAISE vr_exc_erro;
  END IF;

      GENE0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_carga
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_input_file
                              ,pr_des_erro => vr_dscritic);                                                                       
      IF vr_dscritic IS NOT NULL THEN 
         vr_dscritic := 'Erro ao abrir o arquivo para leitura: '||vr_nmarq_carga || ' - ' || vr_dscritic;
         RAISE vr_exc_erro;
      END IF;


      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log
                              ,pr_tipabert => 'W'              
                              ,pr_utlfileh => vr_handle_log   
                              ,pr_des_erro => vr_des_erro);
      if vr_des_erro is not null then
        vr_dscritic := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
        RAISE vr_exc_erro;
      end if;
             
      LOOP
        BEGIN
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file 
                                      ,pr_des_text => vr_setlinha); 
      
          vr_nrcontad := vr_nrcontad + 1;
          
          IF vr_nrcontad = 1 THEN 
            continue;
          END IF;

          vr_setlinha := REPLACE(REPLACE(vr_setlinha,chr(13),''),chr(10),''); 

          vr_vet_campos := gene0002.fn_quebra_string(TRIM(vr_setlinha),';'); 

          OPEN BTCH0001.cr_crapdat(pr_cdcooper =>  vr_vet_campos(1));
          FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
          CLOSE BTCH0001.cr_crapdat;


          BEGIN
            vr_aux_cdcooper := TO_NUMBER(vr_vet_campos(1));
            vr_aux_nrdconta := TO_NUMBER(vr_vet_campos(2));
  
          EXCEPTION
            WHEN OTHERS THEN
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                            ,pr_des_text => 'Erro na leitura da linha: ' || vr_nrcontad || ' -> ' || SQLERRM);
              
            CONTINUE;
          END;             

          vr_tab_carga(vr_nrcontad).cdcooper := vr_aux_cdcooper;
          vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrdconta;

          
        EXCEPTION
          WHEN no_data_found THEN
            EXIT;
          WHEN vr_exc_erro THEN
            RAISE vr_exc_erro;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro na leitura da linha '||vr_nrcontad||' -> '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      END LOOP; 

      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Coop;Conta;Critica - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));


      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log_lanc
                              ,pr_tipabert => 'W'              
                              ,pr_utlfileh => vr_handle_log_lanc   
                              ,pr_des_erro => vr_des_erro);
      if vr_des_erro is not null then
        vr_dscritic := 'Erro ao abrir arquivo de LOG de lancamentos: ' || vr_des_erro;
        RAISE vr_exc_erro;
      end if;
   
      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback
                              ,pr_tipabert => 'W'              
                              ,pr_utlfileh => vr_handle   
                              ,pr_des_erro => vr_des_erro);
      if vr_des_erro is not null then
        vr_dscritic := 'Erro ao abrir arquivo de ROLLBACK: ' || vr_des_erro;
        RAISE vr_exc_erro;
      end if;          

      
      FOR vr_idx1 IN vr_tab_carga.first .. vr_tab_carga.last LOOP
          IF vr_tab_carga.exists(vr_idx1) THEN
          
             vr_aux_adp7 := 0;          
             vr_aux_lim7 := 0; 
             vr_ttl_vlsmnmes := 0;
             vr_ttl_vlsmnesp := 0;
             vr_aux_vliofmes := 0;
             vr_aux_ttliof   := 0;
             vr_aux_iof_prop := 0;
             vr_aux_pix_ttl := 0;
             vr_aux_limite_juros := 0; 
             vr_aux_ttl_utilizado := 0; 
             vr_aux_limite_util := 0; 
             vr_aux_pix_ttl_range := 0;
             vr_aux_limite_juros_range := 0;
             vr_aux_iof_prop_range := 0;
             

             OPEN cr_cooperado(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper,
                               pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta);
             FETCH cr_cooperado INTO rw_cooperado;                
             CLOSE cr_cooperado;
             
          
             FOR rw_crapsda IN cr_crapsda(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                         ,pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta) LOOP
                vr_tab_carga_sda(vr_idx1).vllimcre  := rw_crapsda.vllimcre;
                vr_tab_carga_sda(vr_idx1).vllimutl7 := rw_crapsda.vllimutl;
                vr_tab_carga_sda(vr_idx1).vladdutl7 := rw_crapsda.vladdutl;                   
             END LOOP;   

             
             OPEN cr_lanc_pix(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper,
                              pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta);
             FETCH cr_lanc_pix INTO rw_lanc_pix; 
             
             vr_aux_pix_ttl := rw_lanc_pix.total_pix;              
             CLOSE cr_lanc_pix;


             IF vr_aux_pix_ttl > 0 AND vr_aux_pix_ttl <= vr_tab_carga_sda(vr_idx1).vladdutl7 THEN
               
                 TIOF0001.pc_calcula_valor_iof(pr_tpproduto  => 5 
                                              ,pr_tpoperacao => 1           
                                              ,pr_cdcooper   => vr_tab_carga(vr_idx1).cdcooper
                                              ,pr_nrdconta   => vr_tab_carga(vr_idx1).nrdconta
                                              ,pr_inpessoa   => rw_cooperado.inpessoa 
                                              ,pr_natjurid   => rw_cooperado.natjurid  
                                              ,pr_tpregtrb   => rw_cooperado.tpregtrb 
                                              ,pr_dtmvtolt   => to_date('27/04/2022', 'dd/mm/RRRR')
                                              ,pr_qtdiaiof   => 1
                                              ,pr_vloperacao => vr_aux_pix_ttl
                                              ,pr_vltotalope => vr_aux_pix_ttl
                                              ,pr_vliofpri   => vr_vliofpri
                                              ,pr_vliofadi   => vr_vliofadi
                                              ,pr_vliofcpl   => vr_vliofcpl
                                              ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal
                                              ,pr_flgimune   => vr_flgimune
                                              ,pr_dscritic   => vr_dscritic);                        
                 IF vr_dscritic IS NOT NULL THEN
                    vr_dscritic := 'Erro ao calcular IOF - ' || vr_dscritic || ' - ' || SQLERRM;
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                  ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                  vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                  vr_dscritic);
                 ELSE
                   vr_aux_iof_prop := vr_vliofpri + vr_vliofadi + vr_vliofcpl; 
                 END IF;
 
             ELSIF vr_aux_pix_ttl > 0 AND vr_aux_pix_ttl > vr_tab_carga_sda(vr_idx1).vladdutl7 THEN
               

                 TIOF0001.pc_calcula_valor_iof(pr_tpproduto  => 5 
                                              ,pr_tpoperacao => 1           
                                              ,pr_cdcooper   => vr_tab_carga(vr_idx1).cdcooper
                                              ,pr_nrdconta   => vr_tab_carga(vr_idx1).nrdconta
                                              ,pr_inpessoa   => rw_cooperado.inpessoa 
                                              ,pr_natjurid   => rw_cooperado.natjurid  
                                              ,pr_tpregtrb   => rw_cooperado.tpregtrb 
                                              ,pr_dtmvtolt   => to_date('27/04/2022', 'dd/mm/RRRR')
                                              ,pr_qtdiaiof   => 1
                                              ,pr_vloperacao => ROUND(NVL(vr_tab_carga_sda(vr_idx1).vladdutl7,0),2)
                                              ,pr_vltotalope => ROUND(NVL(vr_tab_carga_sda(vr_idx1).vladdutl7,0),2)
                                              ,pr_vliofpri   => vr_vliofpri
                                              ,pr_vliofadi   => vr_vliofadi
                                              ,pr_vliofcpl   => vr_vliofcpl
                                              ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal
                                              ,pr_flgimune   => vr_flgimune
                                              ,pr_dscritic   => vr_dscritic);                        
                 IF vr_dscritic IS NOT NULL THEN
                    vr_dscritic := 'Erro ao calcular IOF - ' || vr_dscritic || ' - ' || SQLERRM;
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                  ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                  vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                  vr_dscritic);

                 ELSE
                   vr_aux_iof_prop := vr_vliofpri + vr_vliofadi + vr_vliofcpl;
                 END IF;
                 
                 
                 vr_aux_ttl_utilizado :=  vr_aux_pix_ttl - vr_tab_carga_sda(vr_idx1).vladdutl7;
               
                 IF vr_aux_ttl_utilizado >= NVL(vr_tab_carga_sda(vr_idx1).vllimutl7,0) THEN
                    vr_aux_limite_util := NVL(vr_tab_carga_sda(vr_idx1).vllimutl7,0);
                 ELSE
                    vr_aux_limite_util := NVL(vr_aux_ttl_utilizado,0);
                 END IF;
             
                IF vr_aux_limite_util > 0  THEN 
                   vr_aux_lim7 := round(vr_aux_limite_util / rw_crapdat.qtdiaute,2);

                   OPEN cr_craplrt(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                  ,pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta);
                   FETCH cr_craplrt INTO rw_craplrt;
                   IF cr_craplrt%FOUND THEN
                      vr_aux_limite_juros := ROUND(((NVL(vr_aux_lim7,0) * (rw_craplrt.txmensal / 100))),2);
                   ELSE
                     vr_aux_limite_juros := 0;
                     vr_dscritic := 'Contrato de limite nao encontrado.(craplim-craplrt) - ' || ' - ' || SQLERRM;
                     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                   ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                   vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                   vr_dscritic);  
                   END IF;
                   CLOSE cr_craplrt;
                    
                ELSE
                   vr_aux_limite_juros := 0;   
                END IF;
                
             ELSE
                vr_dscritic := 'Lancamentos de PIX nao encontrados.';
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                              vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                              vr_dscritic); 
             END IF;           



            IF vr_aux_iof_prop > 0 THEN
              
                vr_seqdig:= FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                       ,pr_nmdcampo => 'NRSEQDIG'
                                       ,pr_dsdchave => to_char(vr_tab_carga(vr_idx1).cdcooper)||';'||
                                       to_char(rw_crapdat.dtmvtolt , 'DD/MM/RRRR')||';'||
                                       '0;'||
                                       to_char(vr_cdbccxlt)||';'||
                                       to_char(NULL));
                                   
                LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt 
                                                  ,pr_cdbccxlt => vr_cdbccxlt
                                                  ,pr_cdpesqbb => ''
                                                  ,pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta
                                                  ,pr_nrdctabb => vr_tab_carga(vr_idx1).nrdconta
                                                  ,pr_nrdctitg => to_char(vr_tab_carga(vr_idx1).nrdconta,'fm00000000')
                                                  ,pr_nrdocmto => vr_seqdig
                                                  ,pr_cdhistor => 2649
                                                  ,pr_nrseqdig => vr_seqdig
                                                  ,pr_vllanmto => vr_aux_iof_prop 
                                                  ,pr_cdoperad => '1'
                                                  ,pr_cdcritic => vr_cdcritic          
                                                  ,pr_dscritic => vr_dscritic         
                                                  ,pr_incrineg => vr_incrineg        
                                                  ,pr_tab_retorno => vr_tab_retorno );

                IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN              
                   vr_dscritic := 'Erro ao incluir o lancamento: (Estorno IOF 2649) - ' || vr_dscritic || ' - ' || SQLERRM;
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                 ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                 vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                 vr_dscritic);
                ELSE
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log_lanc
                                                 ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                 vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                'Estorno IOF - 2649;' ||
                                                                to_char(vr_aux_iof_prop,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));
                     
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'DELETE craplcm'
                                                                ||' WHERE cdcooper = '||vr_tab_carga(vr_idx1).cdcooper
                                                                ||' AND nrdconta = '||vr_tab_carga(vr_idx1).nrdconta
                                                                ||' AND dtmvtolt = "'||rw_crapdat.dtmvtolt||'"'
                                                                ||' AND cdhistor = 2649;');                         
                END IF;
            END IF;
            

            IF vr_aux_limite_juros > 0 THEN
              
                vr_seqdig:= FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                       ,pr_nmdcampo => 'NRSEQDIG'
                                       ,pr_dsdchave => to_char(vr_tab_carga(vr_idx1).cdcooper)||';'||
                                       to_char(rw_crapdat.dtmvtolt , 'DD/MM/RRRR')||';'||
                                       '0;'||
                                       to_char(vr_cdbccxlt)||';'||
                                       to_char(NULL));
                                   
                LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt 
                                                  ,pr_cdbccxlt => vr_cdbccxlt
                                                  ,pr_cdpesqbb => ''
                                                  ,pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta
                                                  ,pr_nrdctabb => vr_tab_carga(vr_idx1).nrdconta
                                                  ,pr_nrdctitg => to_char(vr_tab_carga(vr_idx1).nrdconta,'fm00000000')
                                                  ,pr_nrdocmto => vr_seqdig
                                                  ,pr_cdhistor => 320
                                                  ,pr_nrseqdig => vr_seqdig
                                                  ,pr_vllanmto => vr_aux_limite_juros 
                                                  ,pr_cdoperad => '1'
                                                  ,pr_cdcritic => vr_cdcritic          
                                                  ,pr_dscritic => vr_dscritic         
                                                  ,pr_incrineg => vr_incrineg        
                                                  ,pr_tab_retorno => vr_tab_retorno );

                IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN              
                   vr_dscritic := 'Erro ao incluir o lancamento: (Estorno Juros 320) - ' || vr_dscritic || ' - ' || SQLERRM;
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                 ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                 vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                 vr_dscritic);
                ELSE
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log_lanc
                                                 ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                 vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                'Estorno Juros - 320;' ||
                                                                 to_char(vr_aux_limite_juros,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));
                                                                 
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'DELETE craplcm'
                                                                ||' WHERE cdcooper = '||vr_tab_carga(vr_idx1).cdcooper
                                                                ||' AND nrdconta = '||vr_tab_carga(vr_idx1).nrdconta
                                                                ||' AND dtmvtolt = "'||rw_crapdat.dtmvtolt||'"'
                                                                ||' AND cdhistor = 320;');                        
                END IF;
            END IF;        
            
            COMMIT;

          END IF;
          
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                        ,pr_des_text => 'COMMIT;');
                                        
      END LOOP;

      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,pr_des_text => 'COMMIT;');
      
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Horario de fim da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
      
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log_lanc); 
          
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);              
     
EXCEPTION
    
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro arquivos: ' || vr_dscritic);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro arquivos: ' || vr_dscritic || ' SQLERRM: ' || SQLERRM);      

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;  
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro geral: ' || ' SQLERRM: ' || SQLERRM);

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
END;
