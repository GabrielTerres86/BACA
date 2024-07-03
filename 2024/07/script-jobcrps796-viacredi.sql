DECLARE
  ct_cdprogra constant VARCHAR2(40) := 'CRPS796';
  vr_exc_erro EXCEPTION;
  pr_cdcooper crapcop.cdcooper%TYPE := 1;
  pr_dsjobnam VARCHAR2(40) := 'SCRIPT796';
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  pr_cdcritic crapcri.cdcritic%TYPE;
  pr_dscritic crapcri.dscritic%TYPE;
  vr_intipmsg INTEGER := null;
  vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  vr_qtd_commit        INTEGER := 5000;
  vr_qtdregis INTEGER := 0;

  PROCEDURE pc_escreve_xml(pr_clobxml   IN OUT NOCOPY CLOB
                          ,pr_des_dados IN VARCHAR2) IS
  BEGIN

    dbms_lob.writeappend(pr_clobxml, length(pr_des_dados), pr_des_dados);
  END pc_escreve_xml;

  PROCEDURE pc_controla_log_batch(pr_idprglog IN OUT tbgen_prglog.idprglog%TYPE
                                 ,pr_dstiplog IN VARCHAR2 DEFAULT 'E' 
                                 ,pr_tpocorre IN NUMBER DEFAULT 2 
                                 ,pr_cdcricid IN NUMBER DEFAULT 2 
                                 ,pr_tpexecuc IN NUMBER DEFAULT 2 
                                 ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcooper IN VARCHAR2
                                 ,pr_flgsuces IN NUMBER DEFAULT 1 
                                 ,pr_flabrchd IN INTEGER DEFAULT 0
                                 ,pr_textochd IN VARCHAR2 DEFAULT NULL 
                                 ,pr_desemail IN VARCHAR2 DEFAULT NULL
                                 ,pr_flreinci IN INTEGER DEFAULT 0) IS

  BEGIN
                            
    CECRED.pc_log_programa(pr_dstiplog           => pr_dstiplog
                          ,pr_tpocorrencia       => pr_tpocorre 
                          ,pr_cdcriticidade      => pr_cdcricid 
                          ,pr_tpexecucao         => pr_tpexecuc
                          ,pr_dsmensagem         => pr_dscritic
                          ,pr_cdmensagem         => pr_cdcritic
                          ,pr_cdcooper           => NVL(pr_cdcooper, 0)
                          ,pr_flgsucesso         => pr_flgsuces
                          ,pr_flabrechamado      => pr_flabrchd 
                          ,pr_texto_chamado      => pr_textochd
                          ,pr_destinatario_email => pr_desemail
                          ,pr_flreincidente      => pr_flreinci
                          ,pr_cdprograma         => ct_cdprogra
                          ,pr_idprglog           => pr_idprglog);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
  END pc_controla_log_batch;

  PROCEDURE pc_envia_email IS
    vr_dscritic  VARCHAR2(32000) := null;
    vr_dsdestino VARCHAR2(100)   := null;
    vr_dsassunto VARCHAR2(100)   := 'Erro no processamento do relatorio diario da Poupanca (PC_CRPS796)';
    vr_dsconteud VARCHAR2(1000)  := 'Ocorreu um erro durante o processamento do relatório crrl824 da Poupanca!';
  BEGIN
    vr_dsdestino := gene0001.fn_param_sistema('CRED', 0, 'EMAIL_EQUIPE_POUPANCA');
    gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                              ,pr_cdprogra        => 'PC_JOB_RENTAB_POUP'
                              ,pr_des_destino     => vr_dsdestino
                              ,pr_des_assunto     => vr_dsassunto
                              ,pr_des_corpo       => vr_dsconteud
                              ,pr_des_anexo       => ''
                              ,pr_flg_remove_anex => 'N'
                              ,pr_flg_remete_coop => 'S'
                              ,pr_flg_enviar      => 'S'
                              ,pr_des_erro        => vr_dscritic);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
  END pc_envia_email;

  PROCEDURE pc_gera_saldo_consolidado_poup(pr_cdcooper IN tbcapt_saldo_consolidado.cdcooper%TYPE
                                          ,pr_cdprodut IN tbcapt_saldo_consolidado.cdprodut%TYPE
                                          ,pr_dtmvtolt IN tbcapt_saldo_consolidado.dtmvtolt%TYPE
                                          ,pr_vlsaldo  IN tbcapt_saldo_consolidado.vlsaldo%TYPE
                                          ,pr_cdcritic OUT PLS_INTEGER
                                          ,pr_dscritic OUT VARCHAR2) IS

  BEGIN
 
    pr_cdcritic := 0;
    pr_dscritic := NULL;
 
    BEGIN
    
      INSERT INTO cecred.tbcapt_saldo_consolidado
        (cdcooper
        ,cdprodut
        ,dtmvtolt
        ,vlsaldo
        ,dtatualizacao)
      VALUES
        (pr_cdcooper 
        ,pr_cdprodut
        ,trunc(pr_dtmvtolt)
        ,pr_vlsaldo
        ,SYSDATE 
         );
    
    EXCEPTION

      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
 
          UPDATE cecred.tbcapt_saldo_consolidado tsc
             SET tsc.vlsaldo       = pr_vlsaldo
                ,tsc.dtatualizacao = SYSDATE
           WHERE tsc.dtmvtolt = trunc(pr_dtmvtolt)
             AND tsc.cdprodut = pr_cdprodut
             AND tsc.cdcooper = pr_cdcooper;
      
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                        ,pr_compleme => 'UPDATE tbcapt_saldo_consolidado:(' ||
                                                        pr_cdcooper || ',' || pr_cdprodut || ',' ||
                                                        trunc(pr_dtmvtolt) || ',' || pr_vlsaldo || ')');
            raise_application_error(-20001, 'UPDATE tbcapt_saldo_consolidado');
        END;
      WHEN OTHERS THEN
        BEGIN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                      ,pr_compleme => 'INSERT tbcapt_saldo_consolidado:(' ||
                                                      pr_cdcooper || ',' || pr_cdprodut || ',' ||
                                                      trunc(pr_dtmvtolt) || ',' || pr_vlsaldo || ')');
          raise_application_error(-20001, 'INSERT tbcapt_saldo_consolidado');
        END;
     
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                    ,pr_compleme => 'pc_gera_saldo_consolidado_poup');
        pr_dscritic := 'Erro geral em pc_gera_saldo_consolidado_poup: ' || SQLERRM;
      END;
  END pc_gera_saldo_consolidado_poup;  
  
  
  PROCEDURE pc_poupanca_financeiro_rel(pr_cdcooper IN crapcop.cdcooper%TYPE
                                      ,pr_idprglog IN OUT tbgen_prglog.idprglog%TYPE
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT VARCHAR2) IS


    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    vr_dsarquiv VARCHAR2(200) := '/rl/crrl824.lst';
 
    vr_clobxml   CLOB;
   
    vr_pf_qttitulo_ativo          INTEGER;
    vr_pf_vltitulo_ativo          NUMERIC(18,2);
    vr_pf_qttitulo_dia            INTEGER;
    vr_pf_vltitulo_dia            NUMERIC(18,2);
    vr_pf_vlrendimento_cre_dia    NUMERIC(18,2);
    vr_pf_vlrendimento_deb_dia    NUMERIC(18,2);
    vr_pf_vlprovisao_dia          NUMERIC(18,2);
    vr_pf_vlreversao_provisao_dia NUMERIC(18,2);
    vr_pf_vlresgate_dia           NUMERIC(18,2);
    vr_pf_vlimposto_renda_dia     NUMERIC(18,2);

    vr_pj_qttitulo_ativo          INTEGER;
    vr_pj_vltitulo_ativo          NUMERIC(18,2);
    vr_pj_qttitulo_dia            INTEGER;
    vr_pj_vltitulo_dia            NUMERIC(18,2);
    vr_pj_vlrendimento_cre_dia    NUMERIC(18,2);
    vr_pj_vlrendimento_deb_dia    NUMERIC(18,2);
    vr_pj_vlprovisao_dia          NUMERIC(18,2);
    vr_pj_vlreversao_provisao_dia NUMERIC(18,2);
    vr_pj_vlresgate_dia           NUMERIC(18,2);
    vr_pj_vlimposto_renda_dia     NUMERIC(18,2);

    vr_dtreferencia DATE;
  

  
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    CURSOR cr_crapcpc IS
      SELECT cpc.cdprodut
            ,cpc.cddindex
            ,cpc.nmprodut
            ,cpc.idsitpro
            ,cpc.idtippro
            ,cpc.idtxfixa
            ,cpc.idacumul
            ,cpc.cdhscacc
            ,cpc.cdhsvrcc
            ,cpc.cdhsraap
            ,cpc.cdhsnrap
            ,cpc.cdhsprap
            ,cpc.cdhsrvap
            ,cpc.cdhsrdap
            ,cpc.cdhsirap
            ,cpc.cdhsrgap
            ,cpc.cdhsvtap
            ,cpc.cdhsrnap
        FROM crapcpc cpc
       WHERE cpc.cddindex = 6
         AND cpc.idsitpro = 1; 
    rw_crapcpc cr_crapcpc%ROWTYPE;

 
    CURSOR cr_craprac(pr_cdcooper     IN crapcop.cdcooper%TYPE
                     ,pr_cdprodut     IN crapcpc.cdprodut%TYPE
                     ,pr_dtreferencia IN DATE) IS
      SELECT rac.cdcooper
            ,rac.cdprodut
            ,rac.nrdconta
            ,rac.nraplica
            ,rac.dtmvtolt
            ,rac.dtaniver
            ,rac.vlaplica
            ,ass.inpessoa
            ,nvl((SELECT SUM(decode(his.indebcre, 'D', -1, 1) * lac.vllanmto) AS "Valor"
                    FROM craphis his
                        ,craplac lac
                  WHERE his.cdhistor = lac.cdhistor
                    AND his.cdcooper = lac.cdcooper
                    AND lac.dtmvtolt <= TRUNC(pr_dtreferencia) 
                    AND lac.nraplica = rac.nraplica
                    AND lac.nrdconta = rac.nrdconta
                    AND lac.cdcooper = rac.cdcooper)
                 ,0) valor 
        FROM crapass ass
            ,craprac rac
       WHERE ass.nrdconta = rac.nrdconta
         AND ass.cdcooper = rac.cdcooper

         AND NOT (rac.idsaqtot = 1 AND rac.dtatlsld < trunc(pr_dtreferencia))
         AND rac.dtmvtolt <= TRUNC(pr_dtreferencia)
         AND rac.cdprodut = pr_cdprodut
         AND rac.cdcooper = pr_cdcooper;
    rw_craprac cr_craprac%ROWTYPE;

    CURSOR cr_craplac(pr_cdcooper     IN craprac.cdcooper%TYPE
                     ,pr_nrdconta     IN craprac.nrdconta%TYPE
                     ,pr_nraplica     IN craprac.nraplica%TYPE
                     ,pr_dtreferencia IN DATE) IS
      SELECT lac.cdhistor
            ,lac.vllanmto
            ,ass.inpessoa
        FROM crapass ass
            ,craplac lac
       WHERE ass.nrdconta = lac.nrdconta
         AND ass.cdcooper = lac.cdcooper
         AND lac.dtmvtolt >= TRUNC(pr_dtreferencia)
         AND lac.dtmvtolt <  TRUNC(pr_dtreferencia)+1
         AND lac.nraplica = pr_nraplica
         AND lac.nrdconta = pr_nrdconta
         AND lac.cdcooper = pr_cdcooper;
    rw_craplac cr_craplac%ROWTYPE;
  
  BEGIN

    GENE0001.pc_set_modulo(pr_module => ct_cdprogra, pr_action => 'Cooper: ' || pr_cdcooper);
    pc_controla_log_batch(pr_idprglog => pr_idprglog, pr_dstiplog => 'I', pr_cdcooper => pr_cdcooper);

    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    IF btch0001.cr_crapdat%NOTFOUND THEN
 
      CLOSE btch0001.cr_crapdat;
 
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;

    vr_dtreferencia := rw_crapdat.dtmvtoan;

    vr_dsarquiv := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => pr_cdcooper)||vr_dsarquiv;
 
    dbms_lob.createtemporary(vr_clobxml, TRUE);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

    pc_escreve_xml(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');
    pc_escreve_xml(vr_clobxml,'<cooperativa id="' || pr_cdcooper || '">');

    FOR rw_crapcpc IN cr_crapcpc
    LOOP
      
      vr_pf_qttitulo_ativo          := 0;
      vr_pf_vltitulo_ativo          := 0;
      vr_pf_qttitulo_dia            := 0;
      vr_pf_vltitulo_dia            := 0;
      vr_pf_vlrendimento_cre_dia    := 0;
      vr_pf_vlrendimento_deb_dia    := 0;
      vr_pf_vlprovisao_dia          := 0;
      vr_pf_vlreversao_provisao_dia := 0;
      vr_pf_vlresgate_dia           := 0;
      vr_pf_vlimposto_renda_dia     := 0;
      
      vr_pj_qttitulo_ativo          := 0;
      vr_pj_vltitulo_ativo          := 0;
      vr_pj_qttitulo_dia            := 0;
      vr_pj_vltitulo_dia            := 0;
      vr_pj_vlrendimento_cre_dia    := 0;
      vr_pj_vlrendimento_deb_dia    := 0;
      vr_pj_vlprovisao_dia          := 0;
      vr_pj_vlreversao_provisao_dia := 0;
      vr_pj_vlresgate_dia           := 0;
      vr_pj_vlimposto_renda_dia     := 0;
      
      pc_escreve_xml(vr_clobxml,'<produto id="'||rw_crapcpc.cdprodut||'" dsprodut="'||rw_crapcpc.nmprodut||'">');
      
      FOR r_coop IN (
                     SELECT cop.cdcooper
                     FROM crapcop cop
                     WHERE cop.flgativo = 1
                       AND cop.cdcooper <> 3
                       AND (cop.cdcooper = pr_cdcooper OR pr_cdcooper = 3)
                     ORDER BY cop.cdcooper
                    )
      LOOP
        
        FOR rw_craprac IN cr_craprac(pr_cdcooper     => r_coop.cdcooper
                                    ,pr_cdprodut     => rw_crapcpc.cdprodut
                                    ,pr_dtreferencia => vr_dtreferencia)
        LOOP
        
          IF rw_craprac.valor > 0 THEN
            IF rw_craprac.inpessoa = 1 THEN
              vr_pf_qttitulo_ativo := vr_pf_qttitulo_ativo + 1;
            ELSE
              vr_pj_qttitulo_ativo := vr_pj_qttitulo_ativo + 1;
            END IF;
          END IF;
        
          IF rw_craprac.inpessoa = 1 THEN
            vr_pf_vltitulo_ativo := vr_pf_vltitulo_ativo + rw_craprac.valor;
          ELSE
            vr_pj_vltitulo_ativo := vr_pj_vltitulo_ativo + rw_craprac.valor;
          END IF;
         
          IF TO_CHAR(rw_craprac.dtmvtolt, 'DD/MM/YYYY') = TO_CHAR(vr_dtreferencia, 'DD/MM/YYYY') THEN
           
            IF rw_craprac.inpessoa = 1 THEN
              vr_pf_qttitulo_dia := vr_pf_qttitulo_dia + 1;
            ELSE
              vr_pj_qttitulo_dia := vr_pj_qttitulo_dia + 1;
            END IF;
            
            IF rw_craprac.inpessoa = 1 THEN
              vr_pf_vltitulo_dia := vr_pf_vltitulo_dia + rw_craprac.vlaplica;
            ELSE
              vr_pj_vltitulo_dia := vr_pj_vltitulo_dia + rw_craprac.vlaplica;
            END IF;
          END IF;
          
          FOR rw_craplac IN cr_craplac(pr_cdcooper     => rw_craprac.cdcooper
                                      ,pr_nrdconta     => rw_craprac.nrdconta
                                      ,pr_nraplica     => rw_craprac.nraplica
                                      ,pr_dtreferencia => vr_dtreferencia)
          LOOP
          
            IF rw_craplac.cdhistor = rw_crapcpc.cdhsrdap THEN
              IF rw_craplac.inpessoa = 1 THEN
                vr_pf_vlrendimento_cre_dia := vr_pf_vlrendimento_cre_dia + rw_craplac.vllanmto;
              ELSE
                vr_pj_vlrendimento_cre_dia := vr_pj_vlrendimento_cre_dia + rw_craplac.vllanmto;
              END IF;
             
            ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsrnap THEN
              IF rw_craplac.inpessoa = 1 THEN
                vr_pf_vlrendimento_deb_dia := vr_pf_vlrendimento_deb_dia + rw_craplac.vllanmto;
              ELSE
                vr_pj_vlrendimento_deb_dia := vr_pj_vlrendimento_deb_dia + rw_craplac.vllanmto;
              END IF;
             
            ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsprap THEN
              IF rw_craplac.inpessoa = 1 THEN
                vr_pf_vlprovisao_dia := vr_pf_vlprovisao_dia + rw_craplac.vllanmto;
              ELSE
                vr_pj_vlprovisao_dia := vr_pj_vlprovisao_dia + rw_craplac.vllanmto;
              END IF;
             
            ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsrvap THEN
              IF rw_craplac.inpessoa = 1 THEN
                vr_pf_vlreversao_provisao_dia := vr_pf_vlreversao_provisao_dia + rw_craplac.vllanmto;
              ELSE
                vr_pj_vlreversao_provisao_dia := vr_pj_vlreversao_provisao_dia + rw_craplac.vllanmto;
              END IF;
             
            ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsrgap OR
                  rw_craplac.cdhistor = rw_crapcpc.cdhsvtap THEN
              IF rw_craplac.inpessoa = 1 THEN
                vr_pf_vlresgate_dia := vr_pf_vlresgate_dia + rw_craplac.vllanmto;
              ELSE
                vr_pj_vlresgate_dia := vr_pj_vlresgate_dia + rw_craplac.vllanmto;
              END IF;
         
            ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsirap THEN
              IF rw_craplac.inpessoa = 1 THEN
                vr_pf_vlimposto_renda_dia := vr_pf_vlimposto_renda_dia + rw_craplac.vllanmto;
              ELSE
                vr_pj_vlimposto_renda_dia := vr_pj_vlimposto_renda_dia + rw_craplac.vllanmto;
              END IF;
            END IF;
            
          END LOOP;
         vr_qtdregis := vr_qtdregis + 1;
          IF MOD(vr_qtdregis, vr_qtd_commit) = 0 THEN
            CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                                  ,pr_dsmensagem    => 'Commit - ' || vr_qtdregis
                                  ,pr_cdprograma    => ct_cdprogra
                                  ,pr_cdcooper      => pr_cdcooper
                                  ,pr_idprglog      => pr_idprglog);           
          END IF;  
        END LOOP;
        
      END LOOP;
      
      pc_escreve_xml(vr_clobxml
                    ,'<resumo>'
                      ||'<qtdtitat_pf>'||vr_pf_qttitulo_ativo||'</qtdtitat_pf>'
                      ||'<qtdtitat_pj>'||vr_pj_qttitulo_ativo||'</qtdtitat_pj>'
                      ||'<qtdtitat_to>'||to_char(vr_pf_qttitulo_ativo+vr_pj_qttitulo_ativo)||'</qtdtitat_to>'
                      ||'<qtdtitap_pf>'||vr_pf_qttitulo_dia||'</qtdtitap_pf>'
                      ||'<qtdtitap_pj>'||vr_pj_qttitulo_dia||'</qtdtitap_pj>'
                      ||'<qtdtitap_to>' ||to_char(vr_pf_qttitulo_dia+vr_pj_qttitulo_dia)||'</qtdtitap_to>'
                      ||'<sldtitat_pf>'||to_char(vr_pf_vltitulo_ativo,'FM99G999G999G999G999G999G999G990D00')||'</sldtitat_pf>'
                      ||'<sldtitat_pj>'||to_char(vr_pj_vltitulo_ativo, 'FM99G999G999G999G999G999G999G990D00')||'</sldtitat_pj>'
                      ||'<sldtitat_to>'||to_char(vr_pf_vltitulo_ativo+vr_pj_vltitulo_ativo,'FM99G999G999G999G999G999G999G990D00')||'</sldtitat_to>'
                      ||'<vlrtotap_pf>'||to_char(vr_pf_vltitulo_dia,'FM99G999G999G999G999G999G999G990D00')||'</vlrtotap_pf>'
                      ||'<vlrtotap_pj>'||to_char(vr_pj_vltitulo_dia, 'FM99G999G999G999G999G999G999G990D00')||'</vlrtotap_pj>'
                      ||'<vlrtotap_to>' ||to_char(vr_pf_vltitulo_dia+vr_pj_vltitulo_dia,'FM99G999G999G999G999G999G999G990D00')||'</vlrtotap_to>'
                      ||'<vlcompul_pf>'||to_char(round((vr_pf_vltitulo_ativo*0.2),2),'FM99G999G999G999G999G999G999G990D00')||'</vlcompul_pf>'
                      ||'<vlcompul_pj>'||to_char(round((vr_pj_vltitulo_ativo*0.2),2), 'FM99G999G999G999G999G999G999G990D00')||'</vlcompul_pj>'
                      ||'<vlcompul_to>' ||to_char(round((vr_pf_vltitulo_ativo*0.2),2)+round((vr_pj_vltitulo_ativo*0.2),2),'FM99G999G999G999G999G999G999G990D00')||'</vlcompul_to>'
                      ||'<rencreme_pf>'||to_char(vr_pf_vlrendimento_cre_dia,'FM99G999G999G999G999G999G999G990D00')||'</rencreme_pf>'
                      ||'<rencreme_pj>'||to_char(vr_pj_vlrendimento_cre_dia,'FM99G999G999G999G999G999G999G990D00')||'</rencreme_pj>'
                      ||'<rencreme_to>'||to_char(vr_pf_vlrendimento_cre_dia+vr_pj_vlrendimento_cre_dia,'FM99G999G999G999G999G999G999G990D00')||'</rencreme_to>'
                      ||'<rendebme_pf>'||to_char(vr_pf_vlrendimento_deb_dia,'FM99G999G999G999G999G999G999G990D00')||'</rendebme_pf>'
                      ||'<rendebme_pj>'||to_char(vr_pj_vlrendimento_deb_dia,'FM99G999G999G999G999G999G999G990D00')||'</rendebme_pj>'
                      ||'<rendebme_to>'||to_char(vr_pf_vlrendimento_deb_dia+vr_pj_vlrendimento_deb_dia,'FM99G999G999G999G999G999G999G990D00')||'</rendebme_to>'
                      ||'<ajtprome_pf>'||to_char(vr_pf_vlprovisao_dia,'FM99G999G999G999G999G999G999G990D00')||'</ajtprome_pf>'
                      ||'<ajtprome_pj>'||to_char(vr_pj_vlprovisao_dia,'FM99G999G999G999G999G999G999G990D00')||'</ajtprome_pj>'
                      ||'<ajtprome_to>'||to_char(vr_pf_vlprovisao_dia+vr_pj_vlprovisao_dia,'FM99G999G999G999G999G999G999G990D00')||'</ajtprome_to>'
                      ||'<restitve_pf>'||to_char(vr_pf_vlreversao_provisao_dia,'FM99G999G999G999G999G999G999G990D00')||'</restitve_pf>'
                      ||'<restitve_pj>'||to_char(vr_pj_vlreversao_provisao_dia,'FM99G999G999G999G999G999G999G990D00')||'</restitve_pj>'
                      ||'<restitve_to>'||to_char(vr_pf_vlreversao_provisao_dia+vr_pj_vlreversao_provisao_dia,'FM99G999G999G999G999G999G999G990D00')||'</restitve_to>'
                      ||'<saqsemre_pf>'||to_char(vr_pf_vlresgate_dia,'FM99G999G999G999G999G999G999G990D00')||'</saqsemre_pf>'
                      ||'<saqsemre_pj>'||to_char(vr_pj_vlresgate_dia,'FM99G999G999G999G999G999G999G990D00')||'</saqsemre_pj>'
                      ||'<saqsemre_to>'||to_char(vr_pf_vlresgate_dia+vr_pj_vlresgate_dia,'FM99G999G999G999G999G999G999G990D00')||'</saqsemre_to>'
                      ||'<imprenrf_pf>'||to_char(vr_pf_vlimposto_renda_dia,'FM99G999G999G999G999G999G999G990D00')||'</imprenrf_pf>'
                      ||'<imprenrf_pj>'||to_char(vr_pj_vlimposto_renda_dia,'FM99G999G999G999G999G999G999G990D00')||'</imprenrf_pj>'
                      ||'<imprenrf_to>'||to_char(vr_pf_vlimposto_renda_dia+vr_pj_vlimposto_renda_dia,'FM99G999G999G999G999G999G999G990D00')||'</imprenrf_to>'
                   ||'</resumo>');
      
      pc_escreve_xml(vr_clobxml,'</produto>');
      
      pc_gera_saldo_consolidado_poup(pr_cdcooper  => pr_cdcooper
                                     ,pr_cdprodut => rw_crapcpc.cdprodut
                                     ,pr_dtmvtolt => vr_dtreferencia
                                     ,pr_vlsaldo  => (vr_pf_vltitulo_ativo + vr_pj_vltitulo_ativo)
                                     ,pr_cdcritic => pr_cdcritic
                                     ,pr_dscritic => pr_dscritic);
                                         
    END LOOP;
    
    pc_escreve_xml(vr_clobxml,'</cooperativa>');
    pc_escreve_xml(vr_clobxml,'</raiz>');

    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => ct_cdprogra 
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt 
                               ,pr_dsxml     => vr_clobxml 
                               ,pr_dsxmlnode => '/raiz/cooperativa/produto' 
                               ,pr_dsjasper  => 'crrl824_principal.jasper' 
                               ,pr_dsparams  => 'PR_DTMVTOLT##'||to_char(vr_dtreferencia, 'DD/MM/YYYY') 
                               ,pr_dsarqsaid => vr_dsarquiv
                               ,pr_flg_gerar => 'N' 
                               ,pr_qtcoluna  => 132
                               ,pr_sqcabrel  => 1 
                               ,pr_flg_impri => 'S' 
                               ,pr_nmformul  => '' 
                               ,pr_nrcopias  => 1 
                               ,pr_flappend  => 'N' 
                               ,pr_nrvergrl  => 1
                               ,pr_des_erro  => vr_dscritic); 
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    COMMIT;
 
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);
 
    pc_controla_log_batch(pr_idprglog => pr_idprglog, pr_dstiplog => 'F', pr_flgsuces => 1, pr_cdcooper => pr_cdcooper);
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_cdcritic := nvl(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
 
      pc_controla_log_batch(pr_idprglog => pr_idprglog
                           ,pr_dstiplog => 'O'
                           ,pr_tpocorre => 4
                           ,pr_cdcricid => 0
                           ,pr_cdcritic => NVL(vr_cdcritic, 0)
                           ,pr_dscritic => vr_dscritic
                           ,pr_cdcooper => pr_cdcooper);
      pc_controla_log_batch(pr_idprglog => pr_idprglog, pr_dstiplog => 'F', pr_flgsuces => 0, pr_cdcooper => pr_cdcooper);

      pc_envia_email;
      
    WHEN OTHERS THEN
   
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      ROLLBACK;
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) || ct_cdprogra || '. ' ||
                     SQLERRM;

      pc_controla_log_batch(pr_idprglog => pr_idprglog
                           ,pr_dstiplog => 'E'
                           ,pr_tpocorre => 3
                           ,pr_cdcricid => 0
                           ,pr_cdcritic => NVL(pr_cdcritic, 0)
                           ,pr_dscritic => pr_dscritic
                           ,pr_cdcooper => pr_cdcooper);
      pc_controla_log_batch(pr_idprglog => pr_idprglog, pr_dstiplog => 'F', pr_flgsuces => 0, pr_cdcooper => pr_cdcooper);
      pc_envia_email;
  END pc_poupanca_financeiro_rel;
  
    
  BEGIN
    
    pr_cdcritic := null;
    pr_dscritic := null;

    gene0004.pc_trata_exec_job(pr_cdcooper => pr_cdcooper 
                              ,pr_fldiautl => 1       
                              ,pr_flproces => 1             
                              ,pr_flrepjob => 1             
                              ,pr_flgerlog => 0          
                              ,pr_flultdia => true         
                              ,pr_nmprogra => pr_dsjobnam  
                              ,pr_intipmsg => vr_intipmsg
                              ,pr_cdcritic => pr_cdcritic
                              ,pr_dscritic => pr_dscritic);
    
    IF TRIM(pr_dscritic) IS NULL THEN
      
      pc_poupanca_financeiro_rel(pr_cdcooper => pr_cdcooper
                                ,pr_idprglog => vr_idprglog
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic);
      
    ELSE
      RAISE vr_exc_erro;
    END IF;
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
    BEGIN
      
      ROLLBACK;
  
      pc_controla_log_batch(pr_idprglog => vr_idprglog
                           ,pr_dstiplog => 'O'
                           ,pr_tpocorre => 4
                           ,pr_cdcricid => 0
                           ,pr_cdcritic => NVL(pr_cdcritic, 0)
                           ,pr_dscritic => pr_dscritic
                           ,pr_cdcooper => pr_cdcooper);

      IF NVL(vr_intipmsg,1) <> 3 THEN       
        pc_envia_email;
      END IF;
      
    END;
    WHEN OTHERS THEN
    BEGIN

      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      ROLLBACK;
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) || ct_cdprogra || '. ' ||
                     SQLERRM;

      pc_controla_log_batch(pr_idprglog => vr_idprglog
                           ,pr_dstiplog => 'E'
                           ,pr_tpocorre => 3
                           ,pr_cdcricid => 0
                           ,pr_cdcritic => NVL(pr_cdcritic, 0)
                           ,pr_dscritic => pr_dscritic
                           ,pr_cdcooper => pr_cdcooper);
      pc_controla_log_batch(pr_idprglog => vr_idprglog, pr_dstiplog => 'F', pr_flgsuces => 0, pr_cdcooper => pr_cdcooper);
      pc_envia_email;
      
    END;
    
END;
