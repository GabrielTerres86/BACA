begin
   DECLARE  
   pr_cdcooper crapcop.cdcooper%TYPE := 2;
   pr_cdcritic crapcri.cdcritic%TYPE; 
   pr_dscritic VARCHAR2(4000);
   
    TYPE typ_reg_record IS RECORD (cdcooper tbseg_prestamista.cdcooper%TYPE
                                  ,nrdconta tbseg_prestamista.nrdconta%TYPE
                                  ,cdagenci crapass.cdagenci%TYPE
                                  ,dtmvtolt crapdat.dtmvtolt%TYPE
                                  ,dtinivig crapdat.dtmvtolt%TYPE
                                  ,dtrefcob crapdat.dtmvtolt%TYPE
                                  ,nmrescop crapcop.nmrescop%TYPE
                                  ,vlenviad NUMBER(25,2)
                                  ,dsregist VARCHAR2(20)
                                  ,inpessoa PLS_INTEGER
                                  ,tpregist tbseg_prestamista.tpregist%TYPE
                                  ,nmprimtl tbseg_prestamista.nmprimtl%TYPE
                                  ,nrcpfcgc tbseg_prestamista.nrcpfcgc%TYPE
                                  ,nrctrseg VARCHAR2(15)
                                  ,nrctremp tbseg_prestamista.nrctremp%TYPE
                                  ,vlprodut tbseg_prestamista.vlprodut%TYPE
                                  ,vlsdeved tbseg_prestamista.vlsdeved%TYPE
                                  ,insitlau VARCHAR2(20)
                                  ,dspessoa VARCHAR(20)
                                  ,vlpreemp crapepr.vlpreemp%TYPE
                                  ,nmsegura crapcsg.nmsegura%TYPE);

    TYPE typ_tab IS TABLE OF typ_reg_record INDEX BY VARCHAR2(30);
    vr_crrl819     typ_tab;
    vr_tab_crrl819 typ_tab;

    TYPE pl_tipo_registros IS RECORD (tpregist VARCHAR2(20));

    TYPE typ_registros IS TABLE OF pl_tipo_registros INDEX BY PLS_INTEGER;

    vr_tipo_registro typ_registros;
    
    TYPE typ_reg_totais IS RECORD (vlpremio NUMBER(25,2)
                                  ,slddeved NUMBER(25,2)
                                  ,qtdadesao PLS_INTEGER
                                  ,dsadesao VARCHAR(20));

    TYPE typ_tab_totais IS TABLE OF typ_reg_totais INDEX BY VARCHAR2(100);

    vr_totais typ_tab_totais;
        
    TYPE typ_reg_totDAT IS RECORD (vlpremio NUMBER(25,2)
                                  ,slddeved NUMBER(25,2));
    
    TYPE typ_tab_sldevpac IS TABLE OF typ_reg_totDAT INDEX BY PLS_INTEGER; 
    vr_tab_sldevpac typ_tab_sldevpac;
    
    vr_vltotarq     NUMBER(30,10); 
    vr_flgachou     BOOLEAN := FALSE;
    
    vr_vltotdiv819  NUMBER(30,10):= 0;
    vr_vlenviad     NUMBER;
    vr_vltotpro     NUMBER(30,10):= 0;
    vr_vlprodut     NUMBER;
    vr_dstextab     craptab.dstextab%TYPE;
    vr_ultimodiaMes DATE;
    vr_diames       VARCHAR(2);
    vr_diasem       NUMBER(1);
    vr_dados_rollback CLOB; 
    vr_texto_rollback VARCHAR2(32600);
    vr_nmarqbkp       VARCHAR2(100);
    vr_nmdireto       VARCHAR2(4000);
    
    TYPE typ_tab_lancarq IS TABLE OF NUMBER(30,10) INDEX BY PLS_INTEGER;          
    vr_tab_lancarq_819 typ_tab_lancarq;
    
    vr_cdcritic     PLS_INTEGER;
    vr_dscritic     VARCHAR2(4000);
    vr_exc_erro     EXCEPTION;
    
    vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'JB_ARQPRST';

    vr_dtmvtolt  crapdat.dtmvtolt%type;
    vr_cdcooper  crapcop.cdcooper%TYPE;
    
    vr_idprglog            tbgen_prglog.idprglog%TYPE := 0;
    vr_destinatario_email  VARCHAR2(500);
    vr_destinatario_email2 VARCHAR2(500);    
      
    vr_nmdircop   VARCHAR2(4000); 
    vr_nmarquiv   VARCHAR2(100);
    vr_ind_arquivo   utl_file.file_type;
    vr_index         VARCHAR2(50);
    vr_saldo_devedor NUMBER;
    
    vr_nrdeanos     PLS_INTEGER;
    vr_tab_nrdeanos PLS_INTEGER;
    vr_nrdmeses     PLS_INTEGER;
    vr_dsdidade     VARCHAR2(50);
    
    vr_dsdemail          VARCHAR2(100);
    vr_index_819         PLS_INTEGER := 0;
    vr_des_xml           CLOB;
    vr_dsadesao          VARCHAR2(100);
    vr_dir_relatorio_819 VARCHAR2(100);
    vr_arqhandle utl_file.file_type;
    vr_regras_segpre     VARCHAR2(1);
    vr_vlminimo number;
    vr_vlmaximo number;
    vr_interacao  NUMBER;

    vr_arquivo_txt         utl_file.file_type;
    vr_nmarqnov            VARCHAR2(50);
    vr_nom_diretorio       VARCHAR2(200);    
    vr_dsdircop            VARCHAR2(200);      
    vr_nmarqdat            VARCHAR2(50);
    vr_dtmvtolt_yymmdd     VARCHAR2(8);
    vr_idx_lancarq         PLS_INTEGER;
    vr_linhadet            VARCHAR(4000);
    vr_typ_said            VARCHAR2(4);
    vr_vlsdeved            NUMBER(24,10); 
    vr_nmsegura            VARCHAR2(200);

    TYPE typ_reg_prestamista IS RECORD(
      cdcooper crapcop.cdcooper%TYPE,
      nrdconta crapass.nrdconta%TYPE,
      cdagenci crapass.cdagenci%TYPE,
      nrcpfcgc crapass.nrcpfcgc%TYPE,
      nmprimtl crapass.nmprimtl%TYPE,
      nrctremp crapepr.nrctremp%TYPE,
      vlemprst crapepr.vlemprst%TYPE,
      vlsdeved crapepr.vlsdeved%TYPE,
      vldevatu tbseg_prestamista.vldevatu%TYPE,
      dtmvtolt crapdat.dtmvtolt%TYPE,
      dtempres crapdat.dtmvtolt%TYPE);
      
    TYPE typ_tab_prestamista IS TABLE OF typ_reg_prestamista INDEX BY varchar2(50);

    vr_tab_prst typ_tab_prestamista;   
    rw_tbseg_parametros_prst tbseg_parametros_prst%ROWTYPE;
     
    CURSOR cr_crapcop(pr_cdcooper in crapcop.cdcooper%type) IS
      SELECT c.cdcooper
            ,c.dsdircop
            ,c.nmrescop
            ,(SELECT dat.dtmvtolt
                FROM cecred.crapdat dat 
                WHERE dat.cdcooper = c.cdcooper) dtmvtolt         
        FROM cecred.crapcop c
       WHERE c.flgativo = 1 
         AND c.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    CURSOR cr_tbseg_prestamista(pr_cdcooper IN tbseg_prestamista.cdcooper%TYPE
                               ,pr_nrdconta IN tbseg_prestamista.nrdconta%TYPE
                               ,pr_nrctrato IN tbseg_prestamista.nrctremp%TYPE) IS
      SELECT seg.idseqtra,
             seg.nrctrseg,
             seg.nrproposta
        FROM cecred.tbseg_prestamista seg
       WHERE seg.cdcooper = pr_cdcooper
         AND seg.nrdconta = pr_nrdconta
         AND seg.nrctremp = pr_nrctrato;
      rw_tbseg_prestamista cr_tbseg_prestamista%ROWTYPE;    
   
    FUNCTION fn_verifica_arq_disponivel_ftp(pr_caminho   IN VARCHAR2
                                           ,pr_interacao IN OUT NUMBER) RETURN BOOLEAN IS
    BEGIN
      pr_interacao := pr_interacao + 1;
      
      IF pr_interacao != 1 THEN
        DBMS_LOCK.SLEEP(10);
      END IF;
      
      IF pr_interacao < 7 THEN
        IF GENE0001.fn_exis_arquivo(pr_caminho => pr_caminho) THEN 
          RETURN TRUE;
        ELSE
          RETURN fn_verifica_arq_disponivel_ftp(pr_caminho   => pr_caminho
                                              ,pr_interacao => pr_interacao);
        END IF;
      ELSE
        RETURN FALSE;  
      END IF;
    END fn_verifica_arq_disponivel_ftp;
   
    PROCEDURE pc_gera_proposta(pr_cdcooper   IN tbseg_prestamista.cdcooper%TYPE
                              ,pr_nrdconta   IN tbseg_prestamista.nrdconta%TYPE
                              ,pr_nrctrseg   IN tbseg_prestamista.nrctrseg%TYPE
                              ,pr_cdapolic   IN tbseg_prestamista.cdapolic%TYPE
                              ,pr_nrproposta IN OUT VARCHAR2) IS     
      vr_exc_saida           EXCEPTION;
    BEGIN
      pr_nrproposta := SEGU0003.FN_NRPROPOSTA(1); 
         
      BEGIN            
        UPDATE cecred.tbseg_prestamista g 
           SET g.nrproposta = pr_nrproposta
         WHERE g.cdapolic = pr_cdapolic;    
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao gravar numero de proposta pc_gera_proposta 1: ' || pr_nrproposta || ' - '|| SQLERRM;
          RAISE vr_exc_saida;               
      END; 
      
         
      BEGIN             
        UPDATE cecred.crawseg g  
           SET g.nrproposta = pr_nrproposta 
         WHERE g.cdcooper = pr_cdcooper 
           AND g.nrdconta = pr_nrdconta 
           AND g.nrctrseg = pr_nrctrseg;     
                               
      EXCEPTION 
        WHEN OTHERS THEN 
          vr_dscritic:= 'Erro ao gravar numero de proposta pc_gera_proposta 2: ' || pr_nrproposta ||' - '|| SQLERRM;
          RAISE vr_exc_saida;                
      END;
           
      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         
         pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
           
         ROLLBACK;
      WHEN OTHERS THEN
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         
         pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
           
         ROLLBACK;
    END pc_gera_proposta;   
   
    PROCEDURE pc_verifica_proposta(pr_cdcooper IN  crapcop.cdcooper%TYPE
                                  ,pr_dscritic OUT VARCHAR2) IS    
      CURSOR cr_proposta IS
      SELECT a.nrproposta, COUNT(a.nrproposta) qtd
        FROM cecred.tbseg_prestamista a 
       WHERE a.cdcooper = pr_cdcooper
         AND a.tpregist IN (1,2,3)
       GROUP by a.nrproposta
       HAVING COUNT(1) > 1;
       
       CURSOR cr_tbseg_prestamista (pr_nrproposta VARCHAR2) IS
       SELECT a.cdcooper
             ,a.nrctremp
             ,a.cdapolic
             ,a.nrdconta
             ,a.nrctrseg
             ,a.nrproposta
         FROM cecred.tbseg_prestamista a
        WHERE a.nrproposta = pr_nrproposta;
        
      CURSOR cr_proposta_zerada IS
      SELECT a.cdcooper
            ,a.nrctremp
            ,a.cdapolic
            ,a.nrdconta
            ,a.nrctrseg
        FROM cecred.tbseg_prestamista a 
       WHERE a.cdcooper = pr_cdcooper
         AND a.tpregist IN (1, 2, 3)           
         AND nvl(a.nrproposta,'0') = '0';
          
      CURSOR cr_registros IS
      SELECT a.*
        FROM cecred.tbseg_prestamista a,
             (SELECT MAX(IDSEQTRA) AS IDSEQTRA,
                     cdcooper,
                     nrdconta,
                     nrctremp,
                     COUNT(nrctremp)
                FROM cecred.tbseg_prestamista c
               WHERE c.cdcooper = pr_cdcooper
                 AND c.tpregist in (1, 3)
               GROUP BY cdcooper, nrdconta, nrctremp
              HAVING COUNT(1) > 1) b
       WHERE a.cdcooper = b.cdcooper
         AND a.nrdconta = b.nrdconta
         AND a.nrctremp = b.nrctremp
         AND a.IDSEQTRA <> b.IDSEQTRA;
      rw_registro cr_registros%ROWTYPE;     
         
      vr_nrproposta VARCHAR2(15);        
      vr_exc_saida  EXCEPTION;      
    BEGIN     
      FOR rw_proposta IN cr_proposta LOOP          
        FOR rw_tbseg_prestamista IN cr_tbseg_prestamista(pr_nrproposta => rw_proposta.nrproposta) LOOP
          vr_nrproposta := SEGU0003.FN_NRPROPOSTA(1);

          BEGIN            
                                          
            UPDATE cecred.tbseg_prestamista g 
               SET g.nrproposta = vr_nrproposta
             WHERE g.cdapolic = rw_tbseg_prestamista.cdapolic;  
                                     
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro ao gravar numero de proposta 1: ' || vr_nrproposta || ' - ' || SQLERRM;
              RAISE vr_exc_saida;              
          END;
           
          BEGIN                     
            UPDATE cecred.crawseg g 
               SET g.nrproposta = vr_nrproposta
             WHERE g.cdcooper = rw_tbseg_prestamista.cdcooper
               AND g.nrdconta = rw_tbseg_prestamista.nrdconta
               AND g.nrctrseg = rw_tbseg_prestamista.nrctrseg
               AND g.nrctrato = rw_tbseg_prestamista.nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro ao gravar numero de proposta 2: ' || vr_nrproposta || ' - ' || SQLERRM;
              RAISE vr_exc_saida;                
          END;
          
          COMMIT;
        END LOOP;
      END LOOP; 
      
      FOR rw_proposta_zerada IN cr_proposta_zerada LOOP
        vr_nrproposta := SEGU0003.FN_NRPROPOSTA(1); 
          
        BEGIN            
          UPDATE cecred.tbseg_prestamista g 
             SET g.nrproposta = vr_nrproposta
           WHERE g.cdapolic = rw_proposta_zerada.cdapolic;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao gravar numero de proposta 3: ' || vr_nrproposta || ' - ' || SQLERRM;
            RAISE vr_exc_saida;              
        END;
         
        BEGIN            
          UPDATE cecred.crawseg g 
             SET g.nrproposta = vr_nrproposta
           WHERE g.cdcooper = rw_proposta_zerada.cdcooper
             AND g.nrdconta = rw_proposta_zerada.nrdconta
             AND g.nrctrseg = rw_proposta_zerada.nrctrseg               
             AND g.nrctrato = rw_proposta_zerada.nrctremp;      
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao gravar numero de proposta 4: ' || vr_nrproposta || ' - ' || SQLERRM;
            RAISE vr_exc_saida;                
        END;
           
        COMMIT;
      END LOOP;
      
      FOR rw_registro in cr_registros LOOP            
        BEGIN            
            DELETE FROM TBSEG_PRESTAMISTA WHERE IDSEQTRA = rw_registro.IDSEQTRA;    
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao excluir rw_registro' || ' - ' || SQLERRM;
            RAISE vr_exc_saida;              
        END;          
      END LOOP;
      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          
        ROLLBACK;
      WHEN OTHERS THEN
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          
        ROLLBACK;
    END pc_verifica_proposta;

    PROCEDURE pc_confere_base_emprest(pr_cdcooper IN  crapcop.cdcooper%TYPE
                                     ,pr_dscritic OUT VARCHAR2) IS
      vr_exc_saida EXCEPTION;
        
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE) IS
        SELECT EPR.*              
          FROM (
                SELECT epr.nrctremp
                      ,epr.nrdconta
                      ,epr.vlsdeved
                      ,SUM(epr.vlsdeved) OVER(PARTITION BY epr.cdcooper, epr.nrdconta)  Saldo_Devedor
                      ,ass.nrcpfcgc
                      ,ass.nmprimtl
                      ,ass.cdagenci
                      ,ass.cdcooper
                      ,epr.dtmvtolt
                      ,ass.dtnasctl                              
                  FROM cecred.crapepr epr
                      ,cecred.crapass ass
                      ,cecred.craplcr lcr
                 WHERE ass.cdcooper = pr_cdcooper
                   AND ass.cdcooper = epr.cdcooper
                   AND ass.nrdconta = epr.nrdconta
                   AND lcr.cdcooper = epr.cdcooper
                   AND lcr.cdlcremp = epr.cdlcremp
                   AND ass.inpessoa = 1 
                   AND epr.inliquid = 0 
                   AND epr.inprejuz = 0 
                   AND epr.dtmvtolt >= to_date('31/01/2000', 'DD/MM/RRRR')
                   AND lcr.flgsegpr = 1
                   AND lcr.tpcuspr = 1
               ) EPR 
         WHERE NOT EXISTS(SELECT seg.idseqtra
                            FROM cecred.tbseg_prestamista seg,
                                 cecred.crapseg s
                           WHERE seg.cdcooper = epr.cdcooper
                             AND seg.nrdconta = epr.nrdconta
                             AND seg.nrctremp = epr.nrctremp
                             AND seg.cdcooper = s.cdcooper
                             AND seg.nrdconta = s.nrdconta
                             AND seg.nrctrseg = s.nrctrseg
                             AND s.cdsitseg <> 2
                             AND s.tpseguro = 4);
                                                     
      CURSOR cr_param_prst IS
        SELECT p.*
          FROM cecred.tbseg_parametros_prst p
         WHERE p.cdcooper = pr_cdcooper
           AND p.tpcustei = 1
           AND p.tppessoa = 1 
           AND p.cdsegura = segu0001.busca_seguradora;
      
      rw_crapepr cr_crapepr%ROWTYPE;                                
      rw_tbseg_parametros_prst tbseg_parametros_prst%ROWTYPE; 
      vr_vlminimo NUMBER := 0;          
    BEGIN
      vr_tab_prst.delete;
        
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => pr_cdcooper) LOOP        
        IF NVL(gene0001.fn_param_sistema('CRED', 0, 'UTILIZA_REGRAS_SEGPRE'),'N') = 'S' THEN
           OPEN cr_param_prst;
             FETCH cr_param_prst INTO rw_tbseg_parametros_prst;
           CLOSE cr_param_prst; 
        
           vr_vlminimo := segu0003.fn_capital_seguravel_min(pr_cdcooper => pr_cdcooper,
                                                            pr_tppessoa => rw_tbseg_parametros_prst.tppessoa,
                                                            pr_cdsegura => rw_tbseg_parametros_prst.cdsegura,
                                                            pr_tpcustei => rw_tbseg_parametros_prst.tpcustei,
                                                            pr_dtnasc   => rw_crapepr.dtnasctl,
                                                            pr_cdcritic => vr_cdcritic,
                                                            pr_dscritic => vr_dscritic);
        
           IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
           END IF;
        ELSE
            vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'USUARI'
                                                     ,pr_cdempres => 11
                                                     ,pr_cdacesso => 'SEGPRESTAM'
                                                     ,pr_tpregist => 0);
          IF vr_dstextab IS NULL THEN
            vr_vlminimo := 0;
          ELSE
            vr_vlminimo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 27, 12));
          END IF;
        END IF;
        
        IF rw_crapepr.saldo_devedor < vr_vlminimo THEN
          CONTINUE;
        END IF;

        SEGU0003.pc_efetiva_proposta_sp(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => rw_crapepr.nrdconta
                                       ,pr_nrctrato => rw_crapepr.nrctremp
                                       ,pr_cdagenci => rw_crapepr.cdagenci
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => 1
                                       ,pr_nmdatela => 'ENV_PRST'
                                       ,pr_idorigem => 7
                                       ,pr_versaldo => 'S'
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        vr_saldo_devedor := rw_crapepr.Saldo_Devedor ;        
        vr_index:= rw_crapepr.nrdconta ||rw_crapepr.nrctremp;
        vr_tab_prst(vr_index).cdcooper:= rw_crapepr.cdcooper;
        vr_tab_prst(vr_index).nrdconta:= rw_crapepr.nrdconta;
        vr_tab_prst(vr_index).cdagenci:= rw_crapepr.cdagenci;        
        vr_tab_prst(vr_index).nmprimtl:= rw_crapepr.nmprimtl;
        vr_tab_prst(vr_index).nrcpfcgc:= rw_crapepr.nrcpfcgc;
        vr_tab_prst(vr_index).nrctremp:= rw_crapepr.nrctremp;
        vr_tab_prst(vr_index).vlemprst:= rw_crapepr.vlsdeved;
        vr_tab_prst(vr_index).vlsdeved:= rw_crapepr.Saldo_Devedor;
        vr_tab_prst(vr_index).dtmvtolt:= vr_dtmvtolt ; 
        vr_tab_prst(vr_index).dtempres:= rw_crapepr.dtmvtolt;
        
        COMMIT;
      END LOOP;
    EXCEPTION
        WHEN vr_exc_saida THEN
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
        
          pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          ROLLBACK;               
                                                                
          cecred.pc_log_programa(pr_dstiplog           => 'E',  
                                 pr_cdprograma         => vr_cdprogra,
                                 pr_cdcooper           => pr_cdcooper,
                                 pr_tpexecucao         => 2,          
                                 pr_tpocorrencia       => 0,          
                                 pr_cdcriticidade      => 2,          
                                 pr_dsmensagem         => vr_dscritic,
                                 pr_flgsucesso         => 0,          
                                 pr_nmarqlog           => NULL,
                                 pr_idprglog           => vr_idprglog);

        WHEN OTHERS THEN
          vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          pr_dscritic := vr_dscritic;
          
          ROLLBACK;    
                                                                
          cecred.pc_log_programa(pr_dstiplog           => 'E',  
                                 pr_cdprograma         => vr_cdprogra, 
                                 pr_cdcooper           => pr_cdcooper, 
                                 pr_tpexecucao         => 2,           
                                 pr_tpocorrencia       => 0,           
                                 pr_cdcriticidade      => 2,           
                                 pr_dsmensagem         => vr_dscritic, 
                                 pr_flgsucesso         => 0,           
                                 pr_nmarqlog           => NULL,
                                 pr_destinatario_email => vr_destinatario_email,
                                 pr_idprglog           => vr_idprglog);
    END pc_confere_base_emprest;
    
    PROCEDURE pc_atualiza_tabela(pr_cdcooper IN  crapcop.cdcooper%TYPE
                                ,pr_dscritic OUT VARCHAR2) IS
                                
      CURSOR cr_prestamista(pr_cdcooper IN tbseg_prestamista.cdcooper%TYPE) IS
        SELECT a.* 
          FROM 
               (SELECT p.cdcooper, p.nrdconta
                      ,p.nrctremp, p.nrctrseg
                      ,t.idseqttl, p.tpregist
                      ,nvl(p.dtnasctl,(SELECT a.dtnasctl 
                                         FROM crapass a 
                                        WHERE a.cdcooper = p.cdcooper  
                                          AND a.nrdconta = p.nrdconta)) dtnasctl                            
                     ,e.inliquid
                     ,CASE WHEN e.inliquid = 1 THEN 0 ELSE e.vlsdeved END SaldoAtualizado    
                     ,p.vldevatu
                     ,p.dtnasctl dtnasctl1
                     ,CASE WHEN((CASE WHEN e.inliquid = 1 THEN 0 ELSE e.vlsdeved END) = 0 AND p.tpregist = 1 ) THEN 0 ELSE p.tpregist END Tiporeg
                     ,DECODE(t.cdsexotl, 2, '2', 1, '1', '1') cdsexotl_ttl 
                     ,p.cdsexotl cdsexotl_tbseg
                     ,p.cdapolic
                FROM cecred.tbseg_prestamista p
                    ,cecred.crapepr e
                    ,cecred.crapttl t
               WHERE p.cdcooper = pr_cdcooper
                 AND e.cdcooper = p.cdcooper
                 AND e.nrdconta = p.nrdconta
                 AND e.nrctremp = p.nrctremp
                 AND t.cdcooper = p.cdcooper
                 AND t.nrdconta = p.nrdconta
                 AND t.idseqttl = 1
                 AND p.vldevatu <> 0 
               ) a
         WHERE NOT (ROUND(vldevatu,2) = ROUND(SaldoAtualizado,2)
           AND dtnasctl1 = dtnasctl
           AND tpregist = Tiporeg
           AND cdsexotl_ttl = cdsexotl_tbseg);             
               
      rw_prestamista cr_prestamista%ROWTYPE; 
      vr_exc_saida           EXCEPTION;        
      BEGIN        
        FOR rw_prestamista IN cr_prestamista(pr_cdcooper => pr_cdcooper) LOOP
          BEGIN 
          gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'UPDATE cecred.tbseg_prestamista      ' || chr(13) ||
                              '   SET vldevatu =   ' ||   rw_prestamista.vldevatu   ||chr(13) ||                                                           
                              '   , tpregist =   ' ||   rw_prestamista.tpregist   ||chr(13) ||                                                           
                              ' WHERE CDCOOPER = ' || rw_prestamista.CDCOOPER || chr(13) ||
                              '   AND nrdconta = ' || rw_prestamista.nrdconta || chr(13) ||
                              '   AND nrctrseg = ' || rw_prestamista.nrctrseg || chr(13) || 
                              '   AND nrctremp = ' || rw_prestamista.nrctremp || chr(13) ||';' || chr(13),
                              FALSE);
                        
            UPDATE cecred.tbseg_prestamista p
               SET p.vldevatu = rw_prestamista.SaldoAtualizado
                 , p.dtnasctl = rw_prestamista.dtnasctl
                 , p.tpregist  = rw_prestamista.Tiporeg
                 , p.cdsexotl = rw_prestamista.cdsexotl_ttl
             WHERE p.cdcooper = pr_cdcooper
               AND p.nrdconta = rw_prestamista.nrdconta
               AND p.nrctrseg = rw_prestamista.nrctrseg
               AND p.nrctremp = rw_prestamista.nrctremp
               and p.cdapolic = rw_prestamista.cdapolic;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
                     
          COMMIT; 
        END LOOP;
      EXCEPTION 
        WHEN vr_exc_saida THEN
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
        
          pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          
          ROLLBACK;                
                                                      
          cecred.pc_log_programa(pr_dstiplog           => 'E',        
                                 pr_cdprograma         => vr_cdprogra,
                                 pr_cdcooper           => pr_cdcooper,
                                 pr_tpexecucao         => 2,          
                                 pr_tpocorrencia       => 0,          
                                 pr_cdcriticidade      => 2,          
                                 pr_dsmensagem         => vr_dscritic,
                                 pr_flgsucesso         => 0,          
                                 pr_nmarqlog           => NULL,
                                 pr_idprglog           => vr_idprglog);

        WHEN OTHERS THEN
          vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          pr_dscritic := vr_dscritic;
          
          ROLLBACK;                   
                                      
          cecred.pc_log_programa(pr_dstiplog           => 'E',     
                                 pr_cdprograma         => vr_cdprogra,
                                 pr_cdcooper           => pr_cdcooper,
                                 pr_tpexecucao         => 2,          
                                 pr_tpocorrencia       => 0,          
                                 pr_cdcriticidade      => 2,          
                                 pr_dsmensagem         => vr_dscritic,
                                 pr_flgsucesso         => 0,          
                                 pr_nmarqlog           => NULL,
                                 pr_destinatario_email => vr_destinatario_email,
                                 pr_idprglog           => vr_idprglog);
    END pc_atualiza_tabela;
    
    PROCEDURE pc_replica_cancelado(pr_cdcooper   IN  tbseg_prestamista.cdcooper%TYPE
                                  ,pr_nrdconta   IN  tbseg_prestamista.nrdconta%TYPE
                                  ,pr_nrctremp   IN  tbseg_prestamista.nrctremp%TYPE
                                  ,pr_dtemprst   IN  tbseg_prestamista.dtdevend%TYPE
                                  ,pr_nrctrseg   IN  tbseg_prestamista.nrctrseg%TYPE                                  
                                  ,pr_cdapolic   OUT tbseg_prestamista.cdapolic%TYPE
                                  ,pr_nrproposta OUT tbseg_prestamista.nrproposta%TYPE
                                  ,pr_cdcritic   OUT crapcri.cdcritic%TYPE 
                                  ,pr_dscritic   OUT VARCHAR2) IS          
      
      CURSOR cr_prest(pr_cdcooper  IN tbseg_prestamista.cdcooper%TYPE
                     ,pr_nrdconta  IN tbseg_prestamista.nrdconta%TYPE
                     ,pr_nrctremp  IN tbseg_prestamista.nrctremp%TYPE
                     ,pr_nrctrseg  IN tbseg_prestamista.nrctrseg%TYPE) IS
        SELECT t.* 
          FROM cecred.tbseg_prestamista t,
               cecred.crapseg s 
         WHERE t.cdcooper = s.cdcooper
           AND t.nrdconta = s.nrdconta
           AND t.nrctrseg = s.nrctrseg
           AND t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.nrctremp = pr_nrctremp
           AND t.nrctrseg = pr_nrctrseg
           AND t.tpregist = 2
           AND s.cdsitseg IN (1,2)
           AND s.tpseguro = 4;
      rw_prest cr_prest%ROWTYPE;
            
      vr_dsdemail   VARCHAR2(100);
      VR_NRPROPOSTA VARCHAR2(15);
      vr_dsmensagem tbgen_prglog_ocorrencia.dsmensagem%TYPE;
    BEGIN
    
        VR_NRPROPOSTA :=  SEGU0003.FN_NRPROPOSTA(1); 
      
        OPEN cr_prest(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_nrctrseg => pr_nrctrseg);
          FETCH cr_prest INTO rw_prest;
          IF cr_prest%FOUND THEN
            BEGIN 
              UPDATE cecred.tbseg_prestamista
                 SET tpregist = 1,
                     dtinivig = trunc(SYSDATE,'MONTH')-1,
                     nrproposta = VR_NRPROPOSTA 
               WHERE cdcooper = rw_prest.cdcooper
                 AND nrdconta = rw_prest.nrdconta
                 AND nrctremp = rw_prest.nrctremp
                 AND nrctrseg = rw_prest.nrctrseg;  
            
             UPDATE cecred.crawseg w
                SET w.nrproposta = VR_NRPROPOSTA
              WHERE w.cdcooper = rw_prest.cdcooper
                AND w.nrdconta = rw_prest.nrdconta
                AND decode(nvl(w.nrctrato,0),0,nvl(rw_prest.nrctremp,0),w.nrctrato) = nvl(rw_prest.nrctremp,0) 
                AND w.nrctrseg = rw_prest.nrctrseg;
            
              vr_dsmensagem := 'UPDATE 1 ' ||
                               ' cdcooper: ' || pr_cdcooper ||
                               ' nrdconta: ' || pr_nrdconta || 
                               ' nrctremp: ' || pr_nrctremp ||
                               ' nrctrseg: ' || pr_nrctrseg ||
                               ' nrproposta: ' || VR_NRPROPOSTA;
                
              CECRED.pc_log_programa(pr_dstiplog      => 'O'                    
                                    ,pr_tpocorrencia  => '4'                    
                                    ,pr_cdcriticidade => 0                      
                                    ,pr_cdcooper      => pr_cdcooper               
                                    ,pr_dsmensagem    => vr_dsmensagem             
                                    ,pr_cdmensagem    => 1201                   
                                    ,pr_cdprograma    => 'PC_REPLICA_CANCELADO' 
                                    ,pr_tpexecucao    => 0                      
                                    ,pr_idprglog      => vr_idprglog);
            
            COMMIT;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic:= 'Erro ao atualizar tbseg_prestamista (replica_cancelado) ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
            pr_cdapolic := rw_prest.cdapolic;
            pr_nrproposta := VR_NRPROPOSTA; 
          END IF;
        CLOSE cr_prest;

        vr_dsdemail := rw_prest.dsdemail;
        SEGU0003.pc_limpa_email(vr_dsdemail);     
  
    EXCEPTION
        WHEN vr_exc_erro THEN
          pr_cdcritic:= nvl(vr_cdcritic,0);
          pr_dscritic:= vr_dscritic;          
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao criar certificado para reenvio de cancelado - Cooper:' || pr_cdcooper || ' - Conta: ' || pr_nrdconta || ' - pc_replica_cancelado';
    END pc_replica_cancelado;
    
    PROCEDURE pc_gera_arquivo_coop_contributario(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    BEGIN
      DECLARE
        vr_exc_saida  EXCEPTION;
        vr_tipo_saida VARCHAR2(100);
        
        vr_nrsequen  NUMBER(5);
        vr_endereco  VARCHAR2(100);    
        vr_login     VARCHAR2(100);
        vr_senha     VARCHAR2(100);
        vr_seqtran   INTEGER;
        vr_vlsdatua  NUMBER;
        vr_vlsdeved  NUMBER := 0;
        vr_tpregist  INTEGER;
        vr_tiporeg   VARCHAR2(1);
        vr_nrproposta tbseg_prestamista.nrproposta%TYPE;
        vr_cdapolic  tbseg_prestamista.cdapolic%TYPE;
        vr_dtdevend  tbseg_prestamista.dtdevend%TYPE;
        vr_dtinivig  tbseg_prestamista.dtinivig%TYPE;
        vr_pielimit  tbseg_prestamista.vlpielimit%TYPE;
        vr_ifttlimi  tbseg_prestamista.vlpielimit%TYPE;
        
        vr_nmrescop crapcop.nmrescop%TYPE;
        vr_apolice  VARCHAR2(20);
        vr_nmdircop  VARCHAR2(100);
        vr_nmarquiv  VARCHAR2(100);
        vr_nmarquivFinal VARCHAR2(100);
        vr_linha_txt VARCHAR2(32600);
        vr_ultimoDia DATE;
        vr_vlprodvl  NUMBER;
        vr_dtfimvig  DATE;
        vr_nr_meses  NUMBER;
        vr_cdmotcan  NUMBER;
        vr_endosso   VARCHAR2(1) := 'N';
        
        vr_dtcancelamento DATE;
        vr_dtprotocolo    DATE;        
        vr_vlcaptpie      NUMERIC (15,2);
        vr_vlcaptiftt     NUMERIC (15,2);
        vr_capitalvg      NUMERIC (15,2);
        vr_modulo         VARCHAR2(50);
        vr_sub            VARCHAR2(50);
        vr_pac            VARCHAR2(10);
        vr_complemento    VARCHAR2(50);        
        vr_motivo_cancel  VARCHAR2(100);
        vr_banco          VARCHAR2(100);
        vr_agencia        VARCHAR2(100);
        vr_conta_corrente VARCHAR2(100);
        vr_vlparcela      crawepr.vlpreemp%TYPE;       
        
        TYPE typ_reg_ctrl_prst IS RECORD(nrcpfcgc tbseg_prestamista.nrcpfcgc%TYPE,
                                         nrctremp tbseg_prestamista.nrctremp%TYPE);  

        TYPE typ_tab_ctrl_prst IS TABLE OF typ_reg_ctrl_prst INDEX BY VARCHAR2(40);
        vr_tab_ctrl_prst typ_tab_ctrl_prst ;
        
        vr_ind_arquivo utl_file.file_type;
    
        CURSOR cr_prestamista(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
          SELECT p.idseqtra
                ,p.cdcooper
                ,p.nrdconta
                ,decode(s.cdagenci,90,decode(w.cdagenci,90,a.cdagenci,w.cdagenci),s.cdagenci) cdagenci
                ,p.nrctrseg
                ,p.tpregist
                ,p.cdapolic
                ,p.nrcpfcgc
                ,p.nmprimtl
                ,p.dtnasctl
                ,p.cdsexotl
                ,p.dsendres
                ,p.dsdemail
                ,p.nmbairro
                ,p.nmcidade
                ,p.cdufresd
                ,p.nrcepend
                ,p.nrtelefo
                ,p.dtdevend
                ,p.dtinivig
                ,p.nrctremp
                ,p.cdcobran
                ,p.cdadmcob
                ,p.tpfrecob
                ,p.tpsegura
                ,p.cdplapro
                ,p.vlprodut
                ,p.tpcobran
                ,p.vlsdeved
                ,p.vldevatu
                ,p.dtfimvig
                ,c.inliquid
                ,c.dtmvtolt data_emp
                ,w.qtpreemp
                ,w.vlpreemp
                ,p.nrproposta
                ,lpad(decode(p.cdcooper , 5,1, 7,2, 10,3,  11,4, 14,5, 9,6, 16,7, 2,8, 8,9, 6,10, 12,11, 13,12, 1,13  )   ,6,'0') cdcooperativa
                ,LPAD(DECODE(p.cdcooper,1,'0101',2,'0102',5,'0104',6,'0105',7,'0106',8,'0107',9,'0108',10,'0110',11,'0109',12,'0111',13,'0112',14,'0113',16,'0115'),4,0) nr_agencia
                ,SUM(p.vldevatu) over(partition by  p.cdcooper, p.nrcpfcgc ) saldo_cpf
                ,ADD_MONTHS(c.dtmvtolt, c.qtpreemp)  dtfimctr
                ,p.nrapolice
                ,p.vlpielimit
                ,p.vlifttlimi
                ,p.qtifttdias
                ,p.flcancelado_mobile 
                ,s.cdmotcan
                ,s.dtcancel
                ,w.nrctrliq##1
                ,w.nrctrliq##2
                ,w.nrctrliq##3
                ,w.nrctrliq##4
                ,w.nrctrliq##5
                ,w.nrctrliq##6
                ,w.nrctrliq##7
                ,w.nrctrliq##8
                ,w.nrctrliq##9
                ,w.nrctrliq##10
                , s.cdsitseg
            FROM cecred.tbseg_prestamista p
                ,cecred.crapepr c
                ,cecred.crapseg s
                ,cecred.crawepr w
                ,cecred.crapass a
           WHERE p.cdcooper = pr_cdcooper
             AND c.cdcooper = p.cdcooper
             AND c.nrdconta = p.nrdconta
             AND c.nrctremp = p.nrctremp   
             AND p.cdcooper = s.cdcooper
             AND p.nrdconta = s.nrdconta
             AND p.nrctrseg = s.nrctrseg       
             AND c.cdcooper = w.cdcooper
             AND c.nrdconta = w.nrdconta
             AND c.nrctremp = w.nrctremp
             AND p.cdcooper = a.cdcooper
             AND p.nrdconta = a.nrdconta    
             AND TRUNC(p.dtinivig) < trunc(SYSDATE,'MONTH')
             AND p.tpregist NOT IN (0,2)
             AND p.tpcustei = 0 
             ORDER BY p.nrcpfcgc ASC , p.cdapolic;
        rw_prestamista cr_prestamista%ROWTYPE;
        
        CURSOR cr_seg_parametro_prst(pr_cdcooper IN tbseg_prestamista.cdcooper%TYPE
                                    ,pr_tpcustei IN tbseg_parametros_prst.tpcustei%TYPE) IS
          SELECT pp.idseqpar,
                 pp.seqarqu,
                 pp.enderftp,
                 pp.loginftp,
                 pp.senhaftp,
                 pp.nrapolic,
                 pp.pielimit,
                 pp.ifttlimi
            FROM cecred.tbseg_parametros_prst pp
           WHERE pp.cdcooper = pr_cdcooper
             AND pp.tppessoa = 1 
             AND pp.cdsegura = segu0001.busca_seguradora
             AND pp.tpcustei = pr_tpcustei;
        rw_seg_parametro_prst cr_seg_parametro_prst%ROWTYPE;
        
        CURSOR cr_crawseg(pr_cdcooper crawseg.cdcooper%TYPE,
                          pr_nrdconta crawseg.nrdconta%TYPE,
                          pr_nrctrseg crawseg.nrctrseg%TYPE,
                          pr_nrctrato crawseg.nrctrato%TYPE) IS
          SELECT c.flggarad, c.nrendres, c.flfinanciasegprestamista
            FROM cecred.crawseg c
           WHERE c.cdcooper = pr_cdcooper
             AND c.nrdconta = pr_nrdconta
             AND c.nrctrseg = pr_nrctrseg
             AND c.nrctrato = pr_nrctrato;
        rw_crawseg cr_crawseg%ROWTYPE;
        
        CURSOR cr_refinancimento(pr_cdcooper  crawepr.cdcooper%TYPE,
                                 pr_nrdconta  crawepr.nrdconta%TYPE,
                                 pr_nrctremp  crawepr.nrctremp%TYPE) IS
          SELECT w.nrctremp
            FROM cecred.crapepr e,
                 cecred.crawepr w
           WHERE w.cdcooper = pr_cdcooper
             AND w.nrdconta = pr_nrdconta
             AND w.cdcooper = e.cdcooper
             AND w.nrdconta = e.nrdconta
             AND w.nrctremp = e.nrctremp
             AND (w.nrctrliq##1 = pr_nrctremp OR
                  w.nrctrliq##2 = pr_nrctremp OR
                  w.nrctrliq##3 = pr_nrctremp OR
                  w.nrctrliq##4 = pr_nrctremp OR
                  w.nrctrliq##5 = pr_nrctremp OR
                  w.nrctrliq##6 = pr_nrctremp OR
                  w.nrctrliq##7 = pr_nrctremp OR
                  w.nrctrliq##8 = pr_nrctremp OR
                  w.nrctrliq##9 = pr_nrctremp OR
                  w.nrctrliq##10 = pr_nrctremp);
        rw_refinancimento cr_refinancimento%ROWTYPE;

      BEGIN
        cecred.pc_log_programa(pr_dstiplog   => 'I',
                               pr_cdprograma => vr_cdprogra,
                               pr_cdcooper   => pr_cdcooper,
                               pr_tpexecucao => 2, 
                               pr_idprglog   => vr_idprglog);
        vr_seqtran := 1;
        
        SELECT nmrescop
          INTO vr_nmrescop
          FROM cecred.crapcop
         WHERE cdcooper = pr_cdcooper;
        

        OPEN cr_seg_parametro_prst(pr_cdcooper => pr_cdcooper,
                                   pr_tpcustei => 0); 
          FETCH cr_seg_parametro_prst INTO rw_seg_parametro_prst;        
          IF cr_seg_parametro_prst%NOTFOUND THEN
            CLOSE cr_seg_parametro_prst;
            vr_dscritic := 'Nao foi possivel localizar taxa de pagamento da seguradora. PC_PARAMETROS_PRST';          
            RAISE vr_exc_saida;
          END IF;           
        CLOSE cr_seg_parametro_prst;
          
        vr_nrsequen := rw_seg_parametro_prst.seqarqu + 1;
        vr_endereco := rw_seg_parametro_prst.enderftp;
        vr_login    := rw_seg_parametro_prst.loginftp;
        vr_senha    := rw_seg_parametro_prst.senhaftp;
          
        BEGIN
          UPDATE cecred.tbseg_parametros_prst p
             SET p.seqarqu = vr_nrsequen
           WHERE p.idseqpar = rw_seg_parametro_prst.idseqpar;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar sequencia da cooperativa: ' || pr_cdcooper || ' - ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        vr_ultimoDia := trunc(SYSDATE,'MONTH')-1;    
        
        vr_nmdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                             pr_cdcooper => pr_cdcooper);
                                             
        IF NOT gene0001.fn_database_name = gene0001.fn_param_sistema('CRED',0,'DB_NAME_PRODUC') THEN 
          vr_apolice := NVL(gene0001.fn_param_sistema('CRED', 0, 'APOLICE_ICATU_SEGPRE'),'77000799');
        ELSE
          vr_apolice  := nvl(rw_prestamista.nrapolice,rw_seg_parametro_prst.nrapolic);
        END IF;
                                             
        vr_nmarquiv := 'TMP_AILOS_'||vr_apolice||'_'||replace(vr_nmrescop,' ','_')||'_'  
                     ||REPLACE(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '') || '_' ||
                       gene0002.fn_mask(vr_nrsequen, '99999') || '.csv';
                       
        vr_nmarquivFinal := 'AILOS_'||vr_apolice||'_'||replace(vr_nmrescop,' ','_')||'_'  
                     ||REPLACE(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '') || '_' ||
                       gene0002.fn_mask(vr_nrsequen, '99999') || '.csv';                                              
      
        GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop || '/arq/'   
                                ,pr_nmarquiv => vr_nmarquiv              
                                ,pr_tipabert => 'W'                      
                                ,pr_utlfileh => vr_ind_arquivo           
                                ,pr_des_erro => vr_dscritic);            
        
        IF vr_dscritic IS NOT NULL THEN         
          RAISE vr_exc_erro;       
        END IF;
        
        vr_linha_txt :=  'CPF,Nome,Sexo,Data de Nascimento,Modulo,Subestipulante,Capital VG Basica,Matricula Funcional,Valor Premio VG,Data de Inicio de Vigencia do Contrato/Certificado,Data de Fim de Vigencia do Contrato/Certificado,'
        ||'Tipo de movimento,Endereco,Complemento,Bairro,Cidade,UF,CEP,'
        ||'Numero Endereco,Numero Proposta,Data da solicitacao do cancelamento,Numero da apolice coletiva,Data do Protocolo,CAPITAL PIE,CAPITAL IFTT,Meses de Financiamento,Data da Assinatura da Proposta,Valor da Parcela do financiamento,'
        ||'Competencia do movimento,Motivo do cancelamento do risco,Cooperativa,Banco,Agencia,Numero Conta Corrente,PAC';                      
        GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);                
        vr_linha_txt := '';

        FOR rw_prestamista IN cr_prestamista(pr_cdcooper => pr_cdcooper) LOOP
          vr_vlsdeved   := rw_prestamista.saldo_cpf;
          vr_vlsdatua   := rw_prestamista.vldevatu;
          vr_tpregist   := rw_prestamista.tpregist;  
          vr_cdapolic   := rw_prestamista.cdapolic;
          vr_nrproposta := nvl(rw_prestamista.nrproposta,'0');
          vr_dtdevend   := rw_prestamista.dtdevend;
          vr_dtinivig   := rw_prestamista.dtinivig;
          vr_dtfimvig   := rw_prestamista.dtfimvig;
          vr_endosso    := 'S';
          vr_cdmotcan   := NULL;
          vr_motivo_cancel := NULL;
          
          IF rw_prestamista.dtfimvig IS NULL THEN
            vr_dtfimvig := rw_prestamista.dtfimctr;
          END IF;
          
          IF TRUNC(vr_dtinivig) >= trunc(SYSDATE,'MONTH')-1 AND vr_tpregist = 1 THEN                          
            CONTINUE;            
          ELSIF vr_tpregist = 3 THEN
            IF rw_prestamista.flcancelado_mobile = 1 THEN              
              IF TRUNC(rw_prestamista.dtcancel - rw_prestamista.dtinivig) < 8 THEN
                vr_motivo_cancel := 33;
              ELSE
                vr_motivo_cancel := 2; 
              END IF;
              vr_endosso := 'N';
              vr_tpregist := 2;
              vr_cdmotcan := rw_prestamista.cdmotcan; 
            END IF;
            OPEN cr_refinancimento(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => rw_prestamista.nrdconta,
                                   pr_nrctremp => rw_prestamista.nrctremp);
              FETCH cr_refinancimento INTO rw_refinancimento;
                IF cr_refinancimento%FOUND THEN
                  vr_endosso := 'N';
                  vr_tpregist := 2;
                  vr_cdmotcan := 19; 
                  vr_motivo_cancel := 34;
                END IF;
            CLOSE cr_refinancimento;
            
            IF vr_endosso = 'S' THEN
              IF rw_prestamista.dtfimvig < vr_dtmvtolt THEN
                vr_endosso := 'N';
                vr_tpregist := 2;
                vr_cdmotcan := 21;
                vr_motivo_cancel := 16;
              END IF;
            END IF;
            
            IF vr_endosso = 'S' THEN
              IF rw_prestamista.inliquid = 1 AND vr_endosso = 'S' THEN
                vr_endosso := 'N';
                vr_tpregist := 2;
                vr_cdmotcan := 18;
                vr_motivo_cancel := 34;
              END IF;
            END IF;
          
            IF vr_endosso = 'S' THEN
              IF rw_prestamista.cdmotcan = 20 THEN
                vr_endosso := 'N';
                vr_tpregist := 2;
                vr_cdmotcan := 20; 
                vr_motivo_cancel := 2;
              END IF;
            END IF;
            IF vr_endosso = 'S' THEN
              CONTINUE;              
            END IF;
          END IF;
          
          IF vr_nrproposta = '0' THEN
            pc_gera_proposta (pr_cdcooper
                             ,rw_prestamista.nrdconta
                             ,rw_prestamista.nrctrseg
                             ,vr_cdapolic
                             ,vr_nrproposta);
          END IF;
          
          vr_tiporeg := CASE WHEN vr_tpregist = 1
                           THEN 'I'
                        WHEN vr_tpregist = 2
                           THEN 'C'
                        WHEN vr_tpregist = 3
                           THEN 'A'
                        END;
          
          vr_dtcancelamento := NULL;
          
          IF vr_tpregist = 2 THEN             
             vr_dtcancelamento := vr_ultimoDia;
             vr_dtinivig := vr_ultimoDia;
          END IF;
         
          vr_modulo := '0';  
          vr_sub    := rw_prestamista.cdcooperativa; 
          vr_dtprotocolo := rw_prestamista.data_emp;
          
          OPEN cr_crawseg(pr_cdcooper => rw_prestamista.cdcooper,
                          pr_nrdconta => rw_prestamista.nrdconta,
                          pr_nrctrseg => rw_prestamista.nrctrseg,
                          pr_nrctrato => rw_prestamista.nrctremp);
            FETCH cr_crawseg INTO rw_crawseg;
            IF cr_crawseg%NOTFOUND THEN
              vr_dscritic := 'Proposta de seguro prestamista não localizado!: 
                                       Conta: ' || rw_prestamista.nrdconta ||
                                      ' Apólice: ' || rw_prestamista.nrctrseg ||
                                      ' Contrato Empréstimo: ' ||rw_prestamista.nrctremp ;
              RAISE vr_exc_erro;     
            END IF;
          CLOSE cr_crawseg;
          
          vr_vlparcela := rw_prestamista.vlpreemp;
          
          IF rw_crawseg.flggarad = 1 THEN     
            IF rw_crawseg.flfinanciasegprestamista = 1 THEN
              
              CECRED.SEGU0003.pc_ret_parc_sem_seg(pr_cdcooper                 => rw_prestamista.cdcooper,
                                                  pr_nrdconta                 => rw_prestamista.nrdconta,
                                                  pr_nrctremp                 => rw_prestamista.nrctremp,
                                                  pr_flggarad                 => rw_crawseg.flggarad,
                                                  pr_flfinanciasegprestamista => rw_crawseg.flfinanciasegprestamista,
                                                  pr_vlseguro                 => rw_prestamista.vlprodut,
                                                  pr_nmdatela                 => 'PC_ENVIA_ARQ_SEG_PRST',
                                                  pr_vlparcel                 => vr_vlparcela);
            END IF;
            
            vr_vlcaptiftt := vr_vlparcela;            
            vr_vlcaptpie  := vr_vlparcela;
            
            vr_modulo     := 2;
            vr_pielimit := nvl(rw_prestamista.vlpielimit, rw_seg_parametro_prst.pielimit);
            IF vr_vlcaptpie > vr_pielimit THEN
               vr_vlcaptpie := vr_pielimit;
            END IF;
            
            vr_vlcaptpie := vr_vlcaptpie * rw_prestamista.qtifttdias;
            
            vr_ifttlimi := nvl(rw_prestamista.vlifttlimi, rw_seg_parametro_prst.ifttlimi);
            IF vr_vlcaptiftt > vr_ifttlimi THEN
               vr_vlcaptiftt := vr_ifttlimi;
            END IF;
            
            vr_vlcaptiftt := vr_vlcaptiftt * rw_prestamista.qtifttdias;
          ELSE
            vr_vlcaptiftt := 0;
            vr_vlcaptpie  := 0;
            vr_modulo     := 1;
          END IF;
          
          vr_capitalvg := rw_prestamista.vlsdeved;
          vr_vlenviad := rw_prestamista.vlsdeved;
          
          vr_vlprodvl := rw_prestamista.vlprodut;
          
          IF vr_vlprodvl < 0.01 THEN
            vr_vlprodvl:= 0.01;
          END IF;  
          
          IF vr_vlenviad < 0.01 THEN
            vr_vlenviad:= 0.01;
          END IF;                      
          
          vr_banco           := '85';
          vr_agencia         := rw_prestamista.nr_agencia;
          vr_conta_corrente  := rw_prestamista.nrdconta;
          vr_pac             := rw_prestamista.cdcooper || LPAD(rw_prestamista.cdagenci,4,0);
          
          vr_linha_txt :='';                                
          vr_linha_txt := vr_linha_txt || TRIM(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'))||','; 
          vr_linha_txt := vr_linha_txt ||
                          TRIM(UPPER(gene0007.fn_caract_especial(rw_prestamista.nmprimtl)))||','; 
          IF rw_prestamista.cdsexotl = 1 THEN 
            vr_linha_txt := vr_linha_txt || 'M,';
          ELSE
            vr_linha_txt := vr_linha_txt || 'F,';            
          END IF;
          vr_linha_txt := vr_linha_txt ||to_char(rw_prestamista.dtnasctl, 'DD/MM/YYYY')||',';
          vr_linha_txt := vr_linha_txt ||vr_modulo||','; 
          vr_linha_txt := vr_linha_txt ||vr_sub||','; 
          vr_linha_txt := vr_linha_txt || REPLACE(to_char(vr_capitalvg,'fm999999999990d00'),',','.') ||','; 
          vr_linha_txt := vr_linha_txt ||TRIM(to_char(rw_prestamista.nrcpfcgc,'fm00000000000')) 
                                       ||rw_prestamista.nrctremp ||',' ; 
          vr_linha_txt := vr_linha_txt || REPLACE(to_char(vr_vlprodvl,'fm999999999990d00'),',','.') ||',';
          vr_linha_txt := vr_linha_txt || TO_CHAR(vr_dtinivig, 'DD/MM/YYYY')||','; 
          vr_linha_txt := vr_linha_txt || TO_CHAR(vr_dtfimvig, 'DD/MM/YYYY')||',';         
          vr_linha_txt := vr_linha_txt ||vr_tiporeg||',';
          vr_linha_txt := vr_linha_txt ||TRIM(REPLACE(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.dsendres,' '))),',',' '))||','; 
          vr_linha_txt := vr_linha_txt ||TRIM(vr_complemento)||',';
          vr_linha_txt := vr_linha_txt ||TRIM(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.nmbairro,' '))))||','; 
          vr_linha_txt := vr_linha_txt ||TRIM(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.nmcidade,' '))))||','; 
          vr_linha_txt := vr_linha_txt || TRIM(nvl(to_char(rw_prestamista.cdufresd), ' '))||','; 
          vr_linha_txt := vr_linha_txt || TRIM(rw_prestamista.nrcepend)||',';
          vr_linha_txt := vr_linha_txt || rw_crawseg.nrendres || ',';
          vr_linha_txt := vr_linha_txt || vr_nrproposta||',';
          vr_linha_txt := vr_linha_txt || TO_CHAR(vr_dtcancelamento, 'DD/MM/YYYY')||',';
          vr_linha_txt := vr_linha_txt || vr_apolice||',' ; 
          vr_linha_txt := vr_linha_txt || TO_CHAR(vr_dtprotocolo, 'DD/MM/YYYY')||',';
          vr_linha_txt := vr_linha_txt || REPLACE(to_char(vr_vlcaptpie,'fm999999999990d00'),',','.') ||',';
          vr_linha_txt := vr_linha_txt || REPLACE(to_char(vr_vlcaptiftt,'fm999999999990d00'),',','.') ||',';
          vr_nr_meses := TRUNC((vr_dtfimvig - vr_dtinivig)/30);
          vr_linha_txt := vr_linha_txt || vr_nr_meses ||',';
          vr_linha_txt := vr_linha_txt || TO_CHAR(rw_prestamista.dtdevend, 'DD/MM/YYYY')||' ,';
          vr_linha_txt := vr_linha_txt || REPLACE(to_char(vr_vlparcela,'fm999999999990d00'),',','.')||',' ;
          vr_linha_txt := vr_linha_txt || TO_CHAR(vr_ultimoDia, 'MMYYYY')||',' ;
          vr_linha_txt := vr_linha_txt || vr_motivo_cancel||' ,';
          vr_linha_txt := vr_linha_txt || TRIM(rw_prestamista.cdcooper)|| ',';
          vr_linha_txt := vr_linha_txt || TRIM(vr_banco)|| ','; 
          vr_linha_txt := vr_linha_txt || LPAD(TRIM(vr_agencia),4,0)|| ',';
          vr_linha_txt := vr_linha_txt || TRIM(vr_conta_corrente)|| ','; 
          vr_linha_txt := vr_linha_txt || TRIM(vr_pac); 
          GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);
          IF vr_tpregist = 2 THEN
            vr_vlprodvl := 0.01; 
          END IF;
          
          vr_index_819 := vr_index_819 + 1;
          vr_tab_crrl819(vr_index_819) := NULL;
          vr_tab_crrl819(vr_index_819).dtmvtolt := vr_dtmvtolt ; 
          vr_tab_crrl819(vr_index_819).nmrescop := vr_nmrescop;
          vr_tab_crrl819(vr_index_819).nmprimtl := rw_prestamista.nmprimtl;
          vr_tab_crrl819(vr_index_819).nrdconta := rw_prestamista.nrdconta;
          vr_tab_crrl819(vr_index_819).cdagenci := rw_prestamista.cdagenci;          
          vr_tab_crrl819(vr_index_819).nrctrseg := vr_nrproposta;
          vr_tab_crrl819(vr_index_819).nrctremp := rw_prestamista.nrctremp;
          vr_tab_crrl819(vr_index_819).nrcpfcgc := rw_prestamista.nrcpfcgc;
          vr_tab_crrl819(vr_index_819).vlprodut := vr_vlprodvl;
          vr_tab_crrl819(vr_index_819).vlenviad := vr_vlenviad;
          vr_tab_crrl819(vr_index_819).vlsdeved := vr_vlsdeved;
          vr_tab_crrl819(vr_index_819).dtinivig := vr_dtinivig;
          vr_tab_crrl819(vr_index_819).dtrefcob := vr_ultimoDia;
          vr_tab_crrl819(vr_index_819).tpregist := vr_tpregist;
          vr_tab_crrl819(vr_index_819).dsregist := vr_tipo_registro(vr_tpregist).tpregist;
          
          IF vr_tpregist = 1 THEN 
            vr_tpregist := 3;
          END IF;
          
          BEGIN 
          gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'UPDATE cecred.tbseg_prestamista      ' || chr(13) ||
                              '   SET tpregist =   ' ||   rw_prestamista.tpregist   ||chr(13) ||                                                           
                              ' WHERE CDCOOPER = ' || rw_prestamista.CDCOOPER || chr(13) ||
                              '   AND nrdconta = ' || rw_prestamista.nrdconta || chr(13) ||
                              '   AND nrctrseg = ' || rw_prestamista.nrctrseg || chr(13) || 
                              '   AND nrctremp = ' || rw_prestamista.nrctremp || chr(13) ||';' || chr(13),
                              FALSE);
            
            UPDATE cecred.tbseg_prestamista
               SET tpregist = vr_tpregist
                  ,dtdenvio = vr_dtmvtolt
                  ,dtrefcob = vr_ultimoDia
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = rw_prestamista.nrdconta
               AND nrctrseg = rw_prestamista.nrctrseg
               AND nrctremp = rw_prestamista.nrctremp
               AND cdapolic = vr_cdapolic;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
          
          IF vr_tpregist = 2 AND rw_prestamista.cdmotcan = 0 THEN
            BEGIN
          gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'UPDATE cecred.crapseg      ' || chr(13) ||
                              '   SET cdsitseg =   ' ||   rw_prestamista.cdsitseg   ||chr(13) ||                                                           
                              '   , dtcancel =   ' ||   rw_prestamista.dtcancel   ||chr(13) ||                                                           
                              '   , cdmotcan =   ' ||   rw_prestamista.cdmotcan   ||chr(13) ||                                                                                                                       
                              ' WHERE CDCOOPER = ' || rw_prestamista.CDCOOPER || chr(13) ||
                              '   AND nrdconta = ' || rw_prestamista.nrdconta || chr(13) ||
                              '   AND nrctrseg = ' || rw_prestamista.nrctrseg || chr(13) || 
                              '   AND tpseguro = ' || '4' || chr(13) ||';' || chr(13),
                              FALSE);              
              UPDATE cecred.crapseg c
                 SET c.cdsitseg = vr_tpregist,
                     c.dtcancel = vr_dtmvtolt,
                     c.cdmotcan = vr_cdmotcan
               WHERE c.cdcooper = rw_prestamista.cdcooper
                 AND c.nrdconta = rw_prestamista.nrdconta
                 AND c.nrctrseg = rw_prestamista.nrctrseg
                 AND c.tpseguro = 4;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao cancelar seguro prestamista: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                RAISE vr_exc_saida;
            END;  
          END IF;        
        
          vr_seqtran := vr_seqtran + 1;         
        END LOOP;
        vr_tab_ctrl_prst.delete;
        vr_crrl819 := vr_tab_crrl819;

        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

        GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper 
                                    ,pr_nmarquiv => vr_nmdircop || '/arq/'||vr_nmarquiv
                                    ,pr_nmarqenv => vr_nmarquiv         
                                    ,pr_des_erro => vr_dscritic);       

        IF vr_dscritic IS NOT NULL THEN    
          RAISE vr_exc_erro;               
        END IF;
        gene0001.pc_OScommand_Shell(pr_des_comando => 'iconv -f ISO8859-1 -t utf-8 '||vr_nmdircop || '/converte/' || vr_nmarquiv||
                                                      ' > '||vr_nmdircop||'/arq/'||vr_nmarquivFinal);    
        
        IF TRIM(vr_nmarquiv) IS NOT NULL THEN
           gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdircop||'/arq/'||vr_nmarquivFinal||' '||vr_nmdircop||'/salvar',
                                       pr_typ_saida   => vr_tipo_saida,
                                       pr_des_saida   => vr_dscritic);
        END IF;
                                  
        IF vr_tipo_saida = 'ERR' THEN
          vr_dscritic := 'Erro ao mover o arquivo - Cooperativa: ' || pr_cdcooper || ' - ' ||vr_dscritic;
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 
                                    ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Movimentacao de diretorio retornou erro: '||vr_dscritic);
        END IF;
        
        vr_interacao := 0;
        IF fn_verifica_arq_disponivel_ftp(pr_caminho   => vr_nmdircop || '/salvar/' || vr_nmarquivFinal
                                         ,pr_interacao => vr_interacao) THEN
        
          SEGU0003.pc_processa_arq_ftp_prest(pr_nmarquiv => vr_nmarquivFinal,  
                                             pr_idoperac => 'E',                        
                                             pr_nmdireto => vr_nmdircop || '/salvar/',  
                                             pr_idenvseg => 'S',                        
                                             pr_ftp_site => vr_endereco,                
                                             pr_ftp_user => vr_login,                   
                                             pr_ftp_pass => vr_senha,                   
                                             pr_ftp_path => 'Envio',                    
                                             pr_dscritic => vr_dscritic);               

          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Erro ao processar arquivo via FTP - Cooperativa: ' || pr_cdcooper || ' - ' || vr_dscritic;
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' --> '
                                                          || 'Processamento de ftp retornou erro: '||vr_dscritic);
          END IF;
        ELSE
           vr_dscritic := 'Erro, arquivo não localizado para processar arquivo via FTP - Cooperativa: ' || pr_cdcooper 
                                        || ' Caminho: ' ||  vr_nmdircop || '/salvar/' || vr_nmarquivFinal || ' - ' || vr_dscritic;
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' --> '
                                                          || 'Localizar o arquivo de ftp retornou erro: '||vr_dscritic);
        END IF;
        
        cecred.pc_log_programa(pr_dstiplog   => 'F',
                               pr_cdprograma => vr_cdprogra,
                               pr_cdcooper   => pr_cdcooper,
                               pr_tpexecucao => 2,
                               pr_idprglog   => vr_idprglog);

        COMMIT;   
       
      EXCEPTION
        WHEN vr_exc_saida THEN
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
        
          pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          ROLLBACK;
          cecred.pc_log_programa(pr_dstiplog           => 'E',         
                                 pr_cdprograma         => vr_cdprogra, 
                                 pr_cdcooper           => pr_cdcooper, 
                                 pr_tpexecucao         => 2,           
                                 pr_tpocorrencia       => 0,           
                                 pr_cdcriticidade      => 2,           
                                 pr_dsmensagem         => vr_dscritic, 
                                 pr_flgsucesso         => 0,           
                                 pr_nmarqlog           => NULL,
                                 pr_idprglog           => vr_idprglog);

          gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                     pr_des_destino => vr_destinatario_email,
                                     pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                     pr_des_corpo   => pr_dscritic,
                                     pr_des_anexo   => NULL,
                                     pr_flg_enviar  => 'S',
                                     pr_des_erro    => vr_dscritic); 
        WHEN OTHERS THEN
          vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          pr_dscritic := vr_dscritic;
          ROLLBACK;
          cecred.pc_log_programa(pr_dstiplog           => 'E',         
                                 pr_cdprograma         => vr_cdprogra, 
                                 pr_cdcooper           => pr_cdcooper, 
                                 pr_tpexecucao         => 2,           
                                 pr_tpocorrencia       => 0,           
                                 pr_cdcriticidade      => 2,           
                                 pr_dsmensagem         => vr_dscritic, 
                                 pr_flgsucesso         => 0,           
                                 pr_nmarqlog           => NULL,
                                 pr_destinatario_email => vr_destinatario_email,
                                 pr_idprglog           => vr_idprglog);
          gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                     pr_des_destino => vr_destinatario_email,
                                     pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                     pr_des_corpo   => pr_dscritic,
                                     pr_des_anexo   => NULL,
                                     pr_flg_enviar  => 'S',
                                     pr_des_erro    => vr_dscritic); 
      END;
    END pc_gera_arquivo_coop_contributario;
    
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
    END pc_escreve_xml;


    PROCEDURE pc_gera_arq_previa_contributario(pr_cdcooper IN tbseg_prestamista.cdcooper%TYPE) IS 
      vr_nmarqcsv   VARCHAR2(100);
      vr_linha_csv  VARCHAR2(32600);
      vr_dscorpem   VARCHAR2(2000);
      vr_endereco   VARCHAR2(100);    
      vr_login      VARCHAR2(100);
      vr_senha      VARCHAR2(100);         
      vr_tipo_saida VARCHAR2(100);
      vr_geroucsv   NUMERIC(1);
      vr_nmrescop   crapcop.nmrescop%TYPE;
      vr_ultimoDia  DATE;
      vr_ind_arqcsv utl_file.file_type;
      vr_tiporeg    VARCHAR2(20);
      
      vr_des_xml     CLOB;                              
      vr_des_xml_999 CLOB;                              
      vr_nom_dir     VARCHAR2(400);                     
       
      CURSOR cr_prestamista(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
       SELECT p.nrdconta
             ,p.nrctrseg
             ,p.tpregist
             ,p.nrcpfcgc
             ,p.nmprimtl
             ,p.dtinivig
             ,p.nrctremp
             ,p.vlprodut
             ,p.vldevatu
             ,p.nrproposta
             ,decode(s.cdagenci,90,decode(w.cdagenci,90,a.cdagenci,w.cdagenci),s.cdagenci) cdagenci
         FROM cecred.crapass a
             ,cecred.crapseg s
             ,cecred.crawepr w
             ,cecred.crapepr c
             ,cecred.tbseg_prestamista p
        WHERE p.cdcooper = pr_cdcooper    
          AND p.cdcooper = c.cdcooper
          AND p.nrdconta = c.nrdconta
          AND p.nrctremp = c.nrctremp
          AND p.cdcooper = w.cdcooper
          AND p.nrdconta = w.nrdconta
          AND p.nrctremp = w.nrctremp
          AND p.cdcooper = s.cdcooper
          AND p.nrdconta = s.nrdconta
          AND p.nrctrseg = s.nrctrseg
          AND p.cdcooper = a.cdcooper
          AND p.nrdconta = a.nrdconta
          AND s.tpseguro = 4
          AND p.tpregist = 1 
          AND p.tpcustei = 0 
          AND p.dtdevend >= (trunc(SYSDATE,'MONTH')) - 7
          AND p.tpregist <> 0
        ORDER BY p.nrcpfcgc ASC, p.cdapolic;
      rw_prestamista cr_prestamista%ROWTYPE;
      
      PROCEDURE pc_xml_tag(pr_des_dados IN VARCHAR2
                          ,pr_flggeral  IN NUMBER) IS
      BEGIN
        IF pr_flggeral = 0 THEN
          dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
        ELSE
          dbms_lob.writeappend(vr_des_xml_999, length(pr_des_dados), pr_des_dados);
        END IF;
      END pc_xml_tag;
      
      BEGIN        
        SELECT nmrescop INTO vr_nmrescop FROM cecred.crapcop  WHERE cdcooper = pr_cdcooper;       
         
        vr_nmdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => pr_cdcooper);
        vr_ultimoDia :=  trunc(SYSDATE,'MONTH'); 
        vr_nmarqcsv := 'Previa_Contributario_'||REPLACE(to_char(vr_ultimoDia , 'DD/MM/YY'), '/', '')
                                 ||'_'||vr_nmrescop ||'.csv';                          
                                   
        vr_nmarqcsv := REPLACE(vr_nmarqcsv,' ','_');
        
        GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop || '/arq/' 
                              ,pr_nmarquiv => vr_nmarqcsv              
                              ,pr_tipabert => 'W'                      
                              ,pr_utlfileh => vr_ind_arqcsv            
                              ,pr_des_erro => vr_dscritic);            
                                                         
        IF vr_dscritic IS NOT NULL THEN         
          RAISE vr_exc_erro;    
        END IF;
        
        dbms_lob.createtemporary(vr_des_xml, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        pc_xml_tag('<?xml version="1.0" encoding="utf-8"?><root>',0);
        
        
        vr_geroucsv := 0;                        
        vr_linha_csv := 'Tip.Reg;Data.Env;Coop.;PA;Nome;CPF/CNPJ;CONTA/DV;Ctr.Seguro;Ctr.Emp;Premio;Sld.Devedor;Dat.Inicio; '|| chr(13);
        GENE0001.pc_escr_linha_arquivo(vr_ind_arqcsv,vr_linha_csv);               
        FOR rw_prestamista IN cr_prestamista(pr_cdcooper => pr_cdcooper) LOOP
          vr_tiporeg := CASE WHEN rw_prestamista.tpregist = 1
                           THEN 'ADESAO'
                        WHEN rw_prestamista.tpregist = 2
                           THEN 'CANCELAMENTO'
                        WHEN rw_prestamista.tpregist = 3
                           THEN 'ENDOSSO'
                        END;           
          
          vr_linha_csv := vr_tiporeg || ';'||                                                      
                          to_char(( trunc(SYSDATE,'MONTH')-1),'DD/MM/YYYY')|| ';'||                                    
                          vr_nmrescop|| ';'||                                                      
                          rw_prestamista.cdagenci|| ';' ||                                         
                          UPPER(gene0007.fn_caract_especial(rw_prestamista.nmprimtl))|| ';'||      
                          RPAD(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'), 14, ' ') || ';'|| 
                          rw_prestamista.nrdconta             || ';'||                             
                          rw_prestamista.nrproposta           || ';'||                             
                          rw_prestamista.nrctremp             || ';'||                             
                          rw_prestamista.vlprodut             || ';'||                             
                          rw_prestamista.vldevatu             || ';'||                             
                          rw_prestamista.dtinivig             || ';'||                             
                          chr(13);
                                        
          GENE0001.pc_escr_linha_arquivo(vr_ind_arqcsv,vr_linha_csv);               
          vr_geroucsv := 1;
          
          pc_xml_tag('<seguro>' 
                   || '<tpregist>'   || vr_tiporeg                                                     || '</tpregist>'      
                   || '<dataenv>'    || to_char(( trunc(SYSDATE,'MONTH')-1),'DD/MM/YYYY')                                  || '</dataenv>' 
                   || '<nmrescop>'   || vr_nmrescop                                                    || '</nmrescop>'
                   || '<cdagenci>'   || rw_prestamista.cdagenci                                        || '</cdagenci>'
                   || '<nmprimtl>'   || UPPER(gene0007.fn_caract_especial(rw_prestamista.nmprimtl))    || '</nmprimtl>'
                   || '<nrcpfcgc>'   || RPAD(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'), 14, ' ')|| '</nrcpfcgc>'
                   || '<nrdconta>'   || rw_prestamista.nrdconta                                        || '</nrdconta>'
                   || '<nrproposta>' || rw_prestamista.nrproposta                                      || '</nrproposta>'
                   || '<nrctremp>'   || rw_prestamista.nrctremp                                        || '</nrctremp>'
                   || '<vlprodut>'   || rw_prestamista.vlprodut                                        || '</vlprodut>'
                   || '<vldevatu>'   || rw_prestamista.vldevatu                                        || '</vldevatu>'
                   || '<dtinivig>'   || rw_prestamista.dtinivig                                        || '</dtinivig>'
                || '</seguro>',0);
        END LOOP;
        
        pc_xml_tag('</root>',0);
        
        vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nmsubdir => '/rl'); 
        
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                   ,pr_cdprogra  => vr_cdprogra
                                   ,pr_dtmvtolt  => vr_dtmvtolt
                                   ,pr_dsxml     => vr_des_xml
                                   ,pr_dsxmlnode => '/root'
                                   ,pr_dsjasper  => 'crrl813.jasper'
                                   ,pr_dsparams  => ''
                                   ,pr_dsarqsaid => vr_nom_dir || '/crrl813.lst'
                                   ,pr_flg_gerar => 'S'
                                   ,pr_qtcoluna  => 234
                                   ,pr_nmformul  => '234col'
                                   ,pr_sqcabrel  => 1
                                   ,pr_cdrelato  => 813
                                   ,pr_flg_impri => 'S'
                                   ,pr_nrcopias  => 1
                                   ,pr_nrvergrl  => 1
                                   ,pr_des_erro  => vr_dscritic);
        
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqcsv ); 
               
        vr_dscorpem := 'Arquivo CSV de Prévia Contributário com <br /><br /> '||
                             ' Cooperativa: ' || vr_nmrescop || '<br />';
                      
        IF vr_geroucsv = 1 THEN
            gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,         
                                       pr_des_destino => vr_destinatario_email2,
                                       pr_des_assunto => 'Seguros prestamistas contributarios gerados durante o mes ',
                                       pr_des_corpo   => vr_dscorpem,
                                       pr_des_anexo   => vr_nmdircop || '/arq/' || vr_nmarqcsv,
                                       pr_flg_remove_anex => 'N',
                                       pr_flg_enviar  => 'S',
                                       pr_des_erro    => vr_dscritic);
                                       
            IF vr_dscritic IS NOT NULL THEN   
              RAISE vr_exc_erro;              
            END IF;          
        END IF;
        
        IF TRIM(vr_nmarqcsv) IS NOT NULL THEN
           gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdircop||'/arq/'||vr_nmarqcsv||' '||vr_nmdircop||'/salvar',
                                       pr_typ_saida   => vr_tipo_saida,
                                       pr_des_saida   => vr_dscritic);
        END IF;
        
        IF vr_tipo_saida = 'ERR' THEN
          vr_dscritic := 'Erro ao mover o arquivo contributario - Cooperativa: ' || pr_cdcooper || ' - ' ||vr_dscritic;
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Movimentacao de diretorio retornou erro: '||vr_dscritic);
        END IF; 
        
        vr_interacao := 0;
        IF fn_verifica_arq_disponivel_ftp(pr_caminho   => vr_nmdircop || '/salvar/' || vr_nmarqcsv
                                         ,pr_interacao => vr_interacao) THEN
        
          vr_endereco := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                   pr_cdcooper => pr_cdcooper,
                                                   pr_cdacesso => 'PRST_FTP_ENDERECO');
          vr_login    := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                   pr_cdcooper => pr_cdcooper,
                                                   pr_cdacesso => 'PRST_FTP_LOGIN');
          vr_senha    := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                   pr_cdcooper => pr_cdcooper,
                                                   pr_cdacesso => 'PRST_FTP_SENHA');

          SEGU0003.pc_processa_arq_ftp_prest(pr_nmarquiv => vr_nmarqcsv,              
                                             pr_idoperac => 'E',                      
                                             pr_nmdireto => vr_nmdircop || '/salvar/',
                                             pr_idenvseg => 'S',                      
                                             pr_ftp_site => vr_endereco,              
                                             pr_ftp_user => vr_login,                 
                                             pr_ftp_pass => vr_senha,                 
                                             pr_ftp_path => 'Envio',                  
                                             pr_dscritic => vr_dscritic);             

          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Erro ao processar arquivo contributario via FTP - Cooperativa: ' || pr_cdcooper || ' - ' || vr_dscritic;
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' --> '
                                                          || 'Processamento de ftp retornou erro: '||vr_dscritic);
          END IF;
        ELSE
           vr_dscritic := 'Erro, arquivo não localizado para processar arquivo via FTP - Cooperativa: ' || pr_cdcooper 
                                        || ' Caminho: ' ||  vr_nmdircop || '/salvar/' || vr_nmarqcsv || ' - ' || vr_dscritic;
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' --> '
                                                          || 'Localizar o arquivo de ftp retornou erro: '||vr_dscritic);
        END IF;

    END pc_gera_arq_previa_contributario; 
    
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2,
                             pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic  crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);
    BEGIN
      IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                      pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                      pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;
  END;       

  BEGIN
    vr_regras_segpre := gene0001.fn_param_sistema('CRED', 0, 'UTILIZA_REGRAS_SEGPRE');
    vr_destinatario_email := gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_EMAIL'); 
    vr_destinatario_email2 := gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_MAIL_CSV');
    
      vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 3);
    pc_valida_direto(pr_nmdireto => vr_nmdireto || '/INC0275491',
                   pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  vr_nmdireto := vr_nmdireto || '/INC0275491';
    vr_dados_rollback := NULL;
    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);

    gene0002.pc_escreve_xml(vr_dados_rollback,
                            vr_texto_rollback,
                            '-- Programa para rollback das informacoes' ||
                            chr(13),
                            FALSE);
    gene0002.pc_escreve_xml(vr_dados_rollback,
                            vr_texto_rollback,
                            'BEGIN' || chr(13),
                            FALSE);

    vr_nmarqbkp := 'ROLLBACK_INCINC0275491' || to_char(sysdate, 'hh24miss') ||'.sql';
   
    IF cr_crapcop%ISOPEN THEN
      CLOSE cr_crapcop;
    END IF;
 
    SELECT nmsegura INTO vr_nmsegura FROM cecred.crapcsg WHERE cdcooper = pr_cdcooper AND cdsegura = 514; 
  
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
        IF cr_crapcop%FOUND THEN
   
          vr_tipo_registro.delete;
          vr_totais.delete;
          vr_tab_sldevpac.delete;
      
          vr_tipo_registro(0).tpregist := 'NOT FOUND';
          vr_tipo_registro(1).tpregist := 'ADESAO';
          vr_tipo_registro(2).tpregist := 'CANCELAMENTO';
          vr_tipo_registro(3).tpregist := 'ENDOSSO';    
    
          vr_diasem := 7;
          IF TO_CHAR(SYSDATE,'D') = vr_diasem AND TO_DATE(gene0001.fn_param_sistema('CRED', pr_cdcooper, 'DATA_LIMITE_SEGPRE'),'DD/MM/RRRR') >= TRUNC(SYSDATE) THEN 
      
            vr_dtmvtolt := rw_crapcop.dtmvtolt;
            vr_cdcooper := rw_crapcop.cdcooper; 
        
            pc_confere_base_emprest(pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_dscritic => vr_dscritic);
            
            IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
             
            dbms_lob.createtemporary(vr_des_xml, TRUE);
            dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
            pc_gera_arq_previa_contributario(rw_crapcop.cdcooper);
            
          ELSIF TO_CHAR(SYSDATE,'D') <> vr_diasem AND 
                TO_CHAR(SYSDATE,'DD') = TO_CHAR(TRUNC(LAST_DAY(SYSDATE)),'DD') THEN

            vr_dtmvtolt := rw_crapcop.dtmvtolt;
            vr_cdcooper := rw_crapcop.cdcooper; 
            
            pc_confere_base_emprest(pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_dscritic => vr_dscritic);
          END IF;  
           
          vr_diames := '01';

          IF TO_CHAR(trunc(SYSDATE,'MONTH'),'DD') <> vr_diames THEN 
            RETURN;
          END IF; 
          
          
          pc_atualiza_tabela(pr_cdcooper => rw_crapcop.cdcooper
                            ,pr_dscritic => vr_dscritic);
                            
          IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          vr_dtmvtolt := rw_crapcop.dtmvtolt;
          vr_cdcooper := rw_crapcop.cdcooper;
          
          IF NVL(vr_regras_segpre,'N') = 'S' THEN
            pc_gera_arquivo_coop_contributario(pr_cdcooper => rw_crapcop.cdcooper);

          END IF;        
                   
          vr_index_819 := '';
          vr_dtmvtolt := rw_crapcop.dtmvtolt;       
          vr_totais.delete;
      
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          vr_vltotarq := 0;
          vr_vltotpro := 0;
          vr_tab_sldevpac.delete;

          pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl819><dados>');  
          vr_index_819 :=  vr_crrl819.first;          
          WHILE vr_index_819 IS NOT NULL LOOP
            IF NOT vr_crrl819(vr_index_819).vlenviad IS NULL THEN
              vr_vlenviad := vr_crrl819(vr_index_819).vlenviad;
            ELSE 
              vr_vlenviad := 0;
            END IF;
            
            IF NOT vr_crrl819(vr_index_819).vlprodut IS NULL THEN
              vr_vlprodut := vr_crrl819(vr_index_819).vlprodut;
            ELSE 
              vr_vlprodut := 0;
            END IF;
            
            pc_escreve_xml(
                  '<registro>'||
                           '<dtmvtolt>' || TO_CHAR(vr_crrl819(vr_index_819).dtmvtolt , 'DD/MM/RRRR') || '</dtmvtolt>' ||
                           '<nmrescop>' || vr_crrl819(vr_index_819).nmrescop || '</nmrescop>' ||
                           '<nmprimtl>' || vr_crrl819(vr_index_819).nmprimtl || '</nmprimtl>' ||
                           '<nrdconta>' || TRIM(gene0002.fn_mask_conta(vr_crrl819(vr_index_819).nrdconta)) || '</nrdconta>' ||
                           '<cdagenci>' ||                     TO_CHAR(vr_crrl819(vr_index_819).cdagenci)  || '</cdagenci>' ||                           
                           '<nrctrseg>' || TRIM(                       vr_crrl819(vr_index_819).nrctrseg) || '</nrctrseg>' ||
                           '<nrctremp>' || TRIM(gene0002.fn_mask_contrato(vr_crrl819(vr_index_819).nrctremp)) || '</nrctremp>' ||
                           '<nrcpfcgc>' || TRIM(gene0002.fn_mask_cpf_cnpj(vr_crrl819(vr_index_819).nrcpfcgc, 1)) || '</nrcpfcgc>' ||
                           '<vlprodut>' || to_char(vr_crrl819(vr_index_819).vlprodut, 'FM99G999G999G999G999G999G999G990D00') || '</vlprodut>' ||
                           '<vlenviad>' || to_char(vr_vlenviad, 'FM99G999G999G999G999G999G999G990D00') || '</vlenviad>' ||
                           '<vlsdeved>' || to_char(vr_crrl819(vr_index_819).vlsdeved, 'FM99G999G999G999G999G999G999G990D00') || '</vlsdeved>' ||
                           '<dtrefcob>' || NVL(TO_CHAR( vr_crrl819(vr_index_819).dtrefcob, 'DD/MM/RRRR') , '') || '</dtrefcob>' ||
                           '<dsregist>' ||              vr_crrl819(vr_index_819).dsregist || '</dsregist>' ||
                           '<dtinivig>' || NVL(TO_CHAR( vr_crrl819(vr_index_819).dtinivig , 'DD/MM/RRRR') , '') || '</dtinivig>'
                   ||'</registro>');
           
            vr_dsadesao := vr_crrl819(vr_index_819).dsregist;
    
            IF NOT vr_tab_sldevpac.EXISTS(vr_crrl819(vr_index_819).cdagenci) THEN
               vr_tab_sldevpac(vr_crrl819(vr_index_819).cdagenci).slddeved := 0;
               vr_tab_sldevpac(vr_crrl819(vr_index_819).cdagenci).vlpremio := 0;
            END IF;
            vr_tab_sldevpac(vr_crrl819(vr_index_819).cdagenci).slddeved := vr_tab_sldevpac(vr_crrl819(vr_index_819).cdagenci).slddeved 
                                                                      + vr_vlenviad;
                                                                      
            vr_tab_sldevpac(vr_crrl819(vr_index_819).cdagenci).vlpremio := vr_tab_sldevpac(vr_crrl819(vr_index_819).cdagenci).vlpremio 
                                                                      + vr_vlprodut;
            vr_vltotarq := vr_vltotarq + vr_vlenviad;
            vr_vltotpro := vr_vltotpro + vr_vlprodut;
    
            IF vr_totais.EXISTS(vr_dsadesao) = FALSE THEN
              vr_totais(vr_dsadesao).qtdadesao := 1;
              vr_totais(vr_dsadesao).slddeved := vr_vlenviad;
              vr_totais(vr_dsadesao).vlpremio := vr_crrl819(vr_index_819).vlprodut;
              vr_totais(vr_dsadesao).dsadesao := vr_dsadesao;
            ELSE
              vr_totais(vr_dsadesao).slddeved := vr_totais(vr_dsadesao).slddeved +
                                                         vr_vlenviad;
              vr_totais(vr_dsadesao).vlpremio := vr_totais(vr_dsadesao).vlpremio +
                                                         vr_crrl819(vr_index_819).vlprodut;
              vr_totais(vr_dsadesao).qtdadesao := vr_totais(vr_dsadesao).qtdadesao + 1;
            END IF;
            
            vr_vltotdiv819 := vr_vltotdiv819 + vr_crrl819(vr_index_819).vlprodut;
                      
            vr_index_819 := vr_crrl819.next(vr_index_819);
            vr_flgachou := TRUE;
          END LOOP;
          pc_escreve_xml('</dados>');

          pc_escreve_xml('<totais>');        
          vr_index := vr_totais.first;
          WHILE vr_index IS NOT NULL LOOP
            IF vr_totais.EXISTS(vr_index) = TRUE THEN                  
              pc_escreve_xml('<registro>'||
                               '<dsadesao>' ||         NVL(vr_totais(vr_index).dsadesao, ' ') || '</dsadesao>' ||
                               '<vlpremio>' || to_char(NVL(vr_totais(vr_index).vlpremio, '0'), 'FM99G999G999G999G999G999G999G990D00') || '</vlpremio>' ||
                               '<slddeved>' || to_char(NVL(vr_totais(vr_index).slddeved, '0'), 'FM99G999G999G999G999G999G999G990D00') || '</slddeved>' ||
                               '<qtdadesao>' ||        NVL(vr_totais(vr_index).qtdadesao, 0) || '</qtdadesao>'||
                             '</registro>');
   
            END IF;
            vr_index := vr_totais.next(vr_index);
          END LOOP;
   
          pc_escreve_xml(  '</totais>');

          IF vr_flgachou THEN          
            vr_tab_lancarq_819.delete;
            
            pc_escreve_xml(  '<totpac vltotdiv="'||to_char(vr_vltotarq,'fm999g999g999g990d00')|| '" ' ||
                                     'vltotpre="'||to_char(vr_vltotpro,'fm999g999g999g990d00')||  '">');
            
            IF vr_tab_sldevpac.COUNT > 0 THEN
              FOR vr_cdagenci IN vr_tab_sldevpac.FIRST..vr_tab_sldevpac.LAST LOOP
                IF vr_tab_sldevpac.EXISTS(vr_cdagenci) THEN
                     pc_escreve_xml('<registro>'
                                   ||  '<cdagenci>'||LPAD(vr_cdagenci,3,' ')||'</cdagenci>'
                                   ||  '<sldevpac>'||to_char(vr_tab_sldevpac(vr_cdagenci).slddeved,'fm999g999g999g990d00')||'</sldevpac>'
                                   ||  '<slprepac>'||to_char(vr_tab_sldevpac(vr_cdagenci).vlpremio,'fm999g999g999g990d00')||'</slprepac>'
                                 ||'</registro>');  
                  vr_tab_lancarq_819(vr_cdagenci) := vr_tab_sldevpac(vr_cdagenci).vlpremio;
   
                END IF;
              END LOOP;
              pc_escreve_xml(  '</totpac>');          
            END IF;          
          END IF;        
          pc_escreve_xml('</crrl819>');
        
          vr_dir_relatorio_819 := gene0001.fn_diretorio('C', rw_crapcop.cdcooper, 'rl') || '/crrl819.lst';
          IF vr_crrl819.EXISTS(1) = TRUE THEN
            gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper         
                                       ,pr_cdprogra  => vr_cdprogra                 
                                       ,pr_dtmvtolt  => rw_crapcop.dtmvtolt         
                                       ,pr_dsxml     => vr_des_xml                  
                                       ,pr_dsxmlnode => '/crrl819'                  
                                       ,pr_dsjasper  => 'crrl819.jasper'            
                                       ,pr_dsparams  => NULL                        
                                       ,pr_dsarqsaid => vr_dir_relatorio_819        
                                       ,pr_cdrelato  => 819
                                       ,pr_flg_gerar => 'S'
                                       ,pr_qtcoluna  => 234
                                       ,pr_sqcabrel  => 1
                                       ,pr_nmformul  => '234col'
                                       ,pr_flg_impri => 'S'
                                       ,pr_nrcopias  => 1
                                       ,pr_nrvergrl  => 1
                                       ,pr_des_erro  => pr_dscritic);
   
            IF pr_dscritic IS NOT NULL THEN            
              RAISE vr_exc_erro; 
            END IF;
          END IF;
 
          dbms_lob.close(vr_des_xml);
          dbms_lob.freetemporary(vr_des_xml);

          vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                                    pr_cdcooper => pr_cdcooper,
                                                    pr_nmsubdir => 'contab');
                                                    
          vr_dsdircop := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => 0
                                                  ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
          
       
          vr_ultimodiaMes := trunc(SYSDATE,'MONTH') -1 ;
          
          vr_dtmvtolt_yymmdd := to_char(vr_ultimodiaMes, 'yyyymmdd'); 
          vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_'||lpad(pr_cdcooper,2,0)||'_PRESTAMISTACOMPL.txt';
          vr_linhadet        := '';
          
          gene0001.pc_abre_arquivo(
                                   pr_nmdireto => vr_nom_diretorio, 
                                   pr_nmarquiv => vr_nmarqdat,      
                                   pr_tipabert => 'W',              
                                   pr_utlfileh => vr_arquivo_txt,   
                                   pr_des_erro => vr_dscritic);     
       
          IF vr_dscritic IS NOT NULL THEN
             vr_cdcritic := 0;
             RAISE vr_exc_erro;
          END IF;        
     
          IF vr_tab_lancarq_819.count > 0 THEN
             vr_idx_lancarq := vr_tab_lancarq_819.first;
             vr_linhadet := TRIM(vr_dtmvtolt_yymmdd)||','||
                                 TRIM(to_char(vr_ultimodiaMes,'ddmmyy'))||
                                 ',8304,4963,'||
                                 TRIM(to_char(vr_vltotdiv819,'FM99999999999999990D90', 'NLS_NUMERIC_CHARACTERS = ''.,'''))|| 
                                 ',5210,'||
                                 '"VLR. REF. PROVISAO P/ PAGAMENTO DE SEGURO PRESTAMISTA MODALIDADE CONTRIBUTARIO - '|| vr_nmsegura ||' - REF. ' 
                                 || to_CHAR(vr_ultimodiaMes,'MM/YYYY') ||'"';
     
             gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
             
             WHILE vr_idx_lancarq IS NOT NULL LOOP                      
                vr_linhadet := lpad(vr_idx_lancarq,3,0) || ',' || 
                    TRIM(to_char(round(vr_tab_lancarq_819(vr_idx_lancarq),2),'FM99999999999999990D90', 'NLS_NUMERIC_CHARACTERS = ''.,''')); 
                    
                gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);                        
                vr_idx_lancarq := vr_tab_lancarq_819.next(vr_idx_lancarq);             
             END LOOP;           
          END IF;    
          
          
          
          gene0001.pc_fecha_arquivo(vr_arquivo_txt);      
          vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_PRESTAMISTA.txt';

          IF TRIM(vr_nmarqdat) IS NOT NULL THEN              
            gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||  
                         vr_nom_diretorio||'/'||vr_nmarqdat||' > '||
                         vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                          pr_typ_saida   => vr_typ_said,
                                          pr_des_saida   => vr_dscritic);
          END IF;
                    
          IF vr_typ_said = 'ERR' THEN
             vr_cdcritic := 1040;
             gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
          END IF;
        END IF;  
      CLOSE cr_crapcop;
    COMMIT;                                     
                              
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'COMMIT;' || chr(13),
                          FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'END;' || chr(13),
                          FALSE);
         
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          chr(13),
                          TRUE);

  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3
                                     ,
                                      pr_cdprogra  => 'ATENDA'
                                     ,
                                      pr_dtmvtolt  => trunc(SYSDATE)
                                     ,
                                      pr_dsxml     => vr_dados_rollback 
                                     ,
                                      pr_dsarqsaid => vr_nmdireto || '/' ||
                                                      vr_nmarqbkp
                                     ,
                                      pr_flg_impri => 'N'
                                     ,
                                      pr_flg_gerar => 'S'
                                     ,
                                      pr_flgremarq => 'N'
                                     ,
                                      pr_nrcopias  => 1
                                     ,
                                      pr_des_erro  => vr_dscritic);

  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);
      COMMIT;    
  EXCEPTION
    WHEN vr_exc_erro THEN
      vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      pr_dscritic := vr_dscritic;
      ROLLBACK;

      cecred.pc_log_programa(pr_dstiplog           => 'E',      
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => vr_cdcooper,
                             pr_tpexecucao         => 2,          
                             pr_tpocorrencia       => 0,          
                             pr_cdcriticidade      => 2,          
                             pr_dsmensagem         => vr_dscritic,
                             pr_flgsucesso         => 0,          
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => vr_destinatario_email,
                             pr_idprglog           => vr_idprglog);
      gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                 pr_des_destino => vr_destinatario_email,
                                 pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                 pr_des_corpo   => pr_dscritic,
                                 pr_des_anexo   => NULL,
                                 pr_flg_enviar  => 'S',
                                 pr_des_erro    => vr_dscritic); 
    WHEN OTHERS THEN
      vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      pr_dscritic := vr_dscritic;
      ROLLBACK;

      cecred.pc_log_programa(pr_dstiplog           => 'E', 
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => vr_cdcooper,
                             pr_tpexecucao         => 2,          
                             pr_tpocorrencia       => 0,          
                             pr_cdcriticidade      => 2,          
                             pr_dsmensagem         => vr_dscritic,
                             pr_flgsucesso         => 0,          
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => vr_destinatario_email,
                             pr_idprglog           => vr_idprglog);
      gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                 pr_des_destino => vr_destinatario_email,
                                 pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                 pr_des_corpo   => pr_dscritic,
                                 pr_des_anexo   => NULL,
                                 pr_flg_enviar  => 'S',
                                 pr_des_erro    => vr_dscritic);

  END;
  commit;
end;
