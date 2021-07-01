--795
declare 
PROCEDURE PC_CRPS795_poupanca (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  BEGIN
    /*..............................................................................

     Programa: PC_CRPS795
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Anderson Fossa
     Data    : Setembro/2020                        Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Mensal.

     Objetivo  : Gera relatorio mensal de produtos de captacao PCAPTA
                 para contabilizacao.
                 
     Alterações: Roda atraves de JOB - JBCAPT_CONTAB_APLPROG.
    ...............................................................................*/

    DECLARE
    
      TYPE typ_reg_crrl795 IS
      RECORD (id INTEGER(4)
             ,vlrvalor NUMERIC(18,2)
             ,quantida INTEGER);

      TYPE typ_tab_crrl795 IS
      TABLE OF typ_reg_crrl795
      INDEX BY PLS_INTEGER;
      
      vr_tab_crrl795 typ_tab_crrl795;

      ------------------------------- VARIAVEIS -------------------------------
      -- Código do programa
      vr_cdprogra  VARCHAR2(40) := 'CRPS795';
      -- Tratamento de erros
      vr_exc_erro exception;
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);     
      -- descricao do arquivo
      vr_dsarquiv VARCHAR2(200) := '/rl/crrl823.lst';
      -- xml de dados
      vr_clobxml CLOB;    
      vr_intipmsg INTEGER := 1;
      vr_idx INTEGER(4);
      vr_acumulado NUMERIC(18,2);
      
      vr_qtdtitat_pf INTEGER := 0;
      vr_qtdtitap_pf INTEGER := 0;
      vr_sldtitat_pf NUMERIC(18,2);
      vr_vlrtotap_pf NUMERIC(18,2);
      vr_rencreme_pf NUMERIC(18,2);
      vr_rendebme_pf NUMERIC(18,2);
      vr_vlrtotpr_pf NUMERIC(18,2);
      vr_ajtprome_pf NUMERIC(18,2);
      vr_restitve_pf NUMERIC(18,2);
      vr_saqsemre_pf NUMERIC(18,2);
      vr_saqcomre_pf NUMERIC(18,2);
      vr_imprenrf_pf NUMERIC(18,2);

      vr_qtdtitat_pj INTEGER := 0;
      vr_qtdtitap_pj INTEGER := 0;
      vr_sldtitat_pj NUMERIC(18,2);
      vr_vlrtotap_pj NUMERIC(18,2);
      vr_rencreme_pj NUMERIC(18,2);
      vr_rendebme_pj NUMERIC(18,2);
      vr_vlrtotpr_pj NUMERIC(18,2);
      vr_ajtprome_pj NUMERIC(18,2);
      vr_restitve_pj NUMERIC(18,2);
      vr_saqsemre_pj NUMERIC(18,2);
      vr_saqcomre_pj NUMERIC(18,2);
      vr_imprenrf_pj NUMERIC(18,2);

      vr_qtdtitat_pl INTEGER := 0;
      vr_qtdtitap_pl INTEGER := 0;
      vr_sldtitat_pl NUMERIC(18,2);
      vr_vlrtotap_pl NUMERIC(18,2);
      vr_rencreme_pl NUMERIC(18,2);
      vr_rendebme_pl NUMERIC(18,2);
      vr_vlrtotpr_pl NUMERIC(18,2);
      vr_ajtprome_pl NUMERIC(18,2);
      vr_restitve_pl NUMERIC(18,2);
      vr_saqsemre_pl NUMERIC(18,2);
      vr_saqcomre_pl NUMERIC(18,2);
      vr_imprenrf_pl NUMERIC(18,2);

      vr_dtultdma_util DATE;

      ------------------------------- CURSORES ---------------------------------
      
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca aplicacoes ativas
      CURSOR cr_craprac(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
        SELECT rac.cdcooper
              ,rac.cdprodut
              ,rac.nrdconta
              ,rac.nraplica
              ,rac.dtmvtolt
              ,rac.dtatlsld
              ,rac.dtaniver
              ,rac.idsaqtot
              ,rac.vlaplica
              ,ass.inpessoa
              ,APLI0012.fn_pessoa_ligada(rac.cdcooper, rac.nrdconta) AS inpeslig -- Indicador Pessoa Ligada
              ,(rac.dtvencto - vr_dtultdma_util) qtddiasvcto
              ,nvl((select SUM(decode(his.indebcre,'D',-1,1) * lac.vllanmto) AS "Valor"
                      from craplac lac, craphis his
                     where lac.cdcooper  = rac.cdcooper
                       and lac.nrdconta  = rac.nrdconta
                       and lac.nraplica  = rac.nraplica
                       and lac.dtmvtolt <= rw_crapdat.dtultdma -- Lancamentos ate ultimo dia do mes anterior.                   
                       and his.cdcooper  = lac.cdcooper
                       and his.cdhistor  = lac.cdhistor),0) valor -- saldo ate dtultdma
          FROM craprac rac,
               crapass ass
         WHERE rac.cdcooper = pr_cdcooper
           AND rac.cdprodut = pr_cdprodut
           AND rac.dtmvtolt <= rw_crapdat.dtultdma
           AND ass.cdcooper = rac.cdcooper
           AND ass.nrdconta = rac.nrdconta;
      rw_craprac cr_craprac%ROWTYPE;

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
       WHERE cpc.indplano = 0 /* Produtos nao aplicacao programada */
         AND cpc.idsitpro = 1
         AND cpc.cddindex = 6;--AUT. POUP
       rw_crapcpc cr_crapcpc%ROWTYPE;
       
       CURSOR cr_craplac (pr_cdcooper craprac.cdcooper%TYPE,
                          pr_nrdconta craprac.nrdconta%TYPE,
                          pr_nraplica craprac.nraplica%TYPE) IS
         SELECT lac.cdhistor, 
                lac.vllanmto,
                ass.inpessoa
           FROM craplac lac,
                crapass ass
          WHERE lac.cdcooper = pr_cdcooper
            AND lac.nrdconta = pr_nrdconta
            AND lac.nraplica = pr_nraplica
            AND lac.dtmvtolt BETWEEN TRUNC(rw_crapdat.dtultdma, 'MM') AND rw_crapdat.dtultdma
            AND ass.cdcooper = lac.cdcooper
            AND ass.nrdconta = lac.nrdconta;
       rw_craplac cr_craplac%ROWTYPE;

       -- SUBROTINA PARA ESCREVER TEXTO NA VARIÁVEL CLOB DO XML
       PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       BEGIN
         -- ESCREVE DADOS NA VARIAVEL vr_clobxml QUE IRA CONTER OS DADOS DO XML
         dbms_lob.writeappend(vr_clobxml, length(pr_des_dados), pr_des_dados);
       END;

       PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                                      ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                      ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                      ,pr_tpexecuc IN NUMBER   DEFAULT 2   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                                      ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                      ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                                      ,pr_cdcooper IN VARCHAR2
                                      ,pr_flgsuces IN NUMBER   DEFAULT 1    -- Indicador de sucesso da execução  
                                      ,pr_flabrchd IN INTEGER  DEFAULT 0    -- Abre chamado 1 Sim/ 0 Não
                                      ,pr_textochd IN VARCHAR2 DEFAULT NULL -- Texto do chamado
                                      ,pr_desemail IN VARCHAR2 DEFAULT NULL -- Destinatario do email
                                      ,pr_flreinci IN INTEGER  DEFAULT 0)IS -- Erro pode reincidir no prog em dias diferentes, devendo abrir chamado
        
          vr_idprglog tbgen_prglog.idprglog%TYPE := 0;        
        BEGIN
          -- Controlar geração de log de execução dos jobs                                
          CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                                ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                                ,pr_dsmensagem    => pr_dscritic
                                ,pr_cdmensagem    => pr_cdcritic
                                ,pr_cdcooper      => NVL(pr_cdcooper,0)
                                ,pr_flgsucesso    => pr_flgsuces
                                ,pr_flabrechamado => pr_flabrchd -- Abre chamado 1 Sim/ 0 Não
                                ,pr_texto_chamado => pr_textochd
                                ,pr_destinatario_email => pr_desemail
                                ,pr_flreincidente => pr_flreinci
                                ,pr_cdprograma    => vr_cdprogra
                                ,pr_idprglog      => vr_idprglog);   
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      END pc_controla_log_batch;

       PROCEDURE pc_envia_email IS
         vr_dsdestino VARCHAR2(100);
         vr_dsassunto VARCHAR2(100)  := 'Erro no processamento do relatorio mensal de aplicacoes PCAPTA';
         vr_dsconteud VARCHAR2(1000) := 'Ocorreu um erro durante o processamento do relatório crrl823 das aplicações PCAPTA!';
       BEGIN
         vr_dsdestino := gene0001.fn_param_sistema('CRED',0,'ENVIA_EMAIL_INTEGRA_IPCA');
         gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                   ,pr_cdprogra        => 'PC_JOB_PCAPTA_RENDIMENTO'
                                   ,pr_des_destino     => vr_dsdestino
                                   ,pr_des_assunto     => vr_dsassunto
                                   ,pr_des_corpo       => vr_dsconteud
                                   ,pr_des_anexo       => ''
                                   ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                   ,pr_flg_remete_coop => 'S' --> Se o envio sera do e-mail da Cooperativa
                                   ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                   ,pr_des_erro        => vr_dscritic);
       EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
       END pc_envia_email;

    BEGIN
      
      
      
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'Cooper: ' || pr_cdcooper);

    pc_controla_log_batch(pr_dstiplog => 'I'
               ,pr_cdcooper => pr_cdcooper);

      -- busca a ultima data de movimento
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      --Carrega ultimo dia util do mes passado
      vr_dtultdma_util := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                      pr_dtmvtolt  => rw_crapdat.dtultdma,
                                                      pr_tipo      => 'A',
                                                      pr_feriado   => true,
                                                      pr_excultdia => true);
      vr_tab_crrl795.delete;
      
      -- ARQUIVO P/ GERACAO DO RELATORIO
      vr_dsarquiv := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => pr_cdcooper) || vr_dsarquiv;
      
      -- inicializar o clob (XML)
      dbms_lob.createtemporary(vr_clobxml, TRUE);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      -- inicio do arquivo XML
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');   
      pc_escreve_xml('<cooperativa id="'||pr_cdcooper||'">');

      /* Loop pelos produtos PCAPTA que nao sejam de aplicacao programada,
         pois a apl. prog. tem seu proprio programa de contabilizacao (crps737) */
      FOR rw_crapcpc IN cr_crapcpc LOOP
        
        vr_qtdtitat_pf := 0; vr_qtdtitat_pj := 0; vr_qtdtitat_pl := 0;
        vr_qtdtitap_pf := 0; vr_qtdtitap_pj := 0; vr_qtdtitap_pl := 0;
        vr_sldtitat_pf := 0; vr_sldtitat_pj := 0; vr_sldtitat_pl := 0;
        vr_vlrtotap_pf := 0; vr_vlrtotap_pj := 0; vr_vlrtotap_pl := 0;
        vr_rencreme_pf := 0; vr_rencreme_pj := 0; vr_rencreme_pl := 0;
        vr_rendebme_pf := 0; vr_rendebme_pj := 0; vr_rendebme_pl := 0;
        vr_vlrtotpr_pf := 0; vr_vlrtotpr_pj := 0; vr_vlrtotpr_pl := 0;
        vr_ajtprome_pf := 0; vr_ajtprome_pj := 0; vr_ajtprome_pl := 0;
        vr_restitve_pf := 0; vr_restitve_pj := 0; vr_restitve_pl := 0;
        vr_saqsemre_pf := 0; vr_saqsemre_pj := 0; vr_saqsemre_pl := 0;
        vr_saqcomre_pf := 0; vr_saqcomre_pj := 0; vr_saqcomre_pl := 0;
        vr_imprenrf_pf := 0; vr_imprenrf_pj := 0; vr_imprenrf_pl := 0;

        pc_escreve_xml('<produto id="'|| rw_crapcpc.cdprodut ||'" dsprodut="'||rw_crapcpc.nmprodut||'">');
        
        FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper
                                    ,pr_cdprodut => rw_crapcpc.cdprodut) LOOP
             
          /* Se a aplicacao esta sacada total e a ult. atualizacao de saldo nao foi no ultimo mes */
          IF rw_craprac.idsaqtot = 1 and 
             rw_craprac.dtatlsld < trunc(rw_crapdat.dtultdma,'MM') THEN
             CONTINUE;
          END IF;
          
          -- QUANTIDADE TITULOS ATIVOS
          IF rw_craprac.valor > 0 THEN
            IF rw_craprac.cdprodut = 1109 AND rw_craprac.inpeslig = 1 THEN -- Pessoa ligada
              vr_qtdtitat_pl := vr_qtdtitat_pl + 1;
            ELSE 
              IF rw_craprac.inpessoa = 1 THEN
                 vr_qtdtitat_pf := vr_qtdtitat_pf + 1;
              ELSE
                vr_qtdtitat_pj := vr_qtdtitat_pj + 1;
              END IF;
            END IF;
          END IF;
          
          -- SALDO TOTAL TITULOS ATIVOS
            IF rw_craprac.cdprodut = 1109 AND rw_craprac.inpeslig = 1 THEN -- Pessoa ligada
                vr_sldtitat_pl := rw_craprac.valor + vr_sldtitat_pl;
            ELSE
              IF rw_craprac.inpessoa = 1 THEN
                vr_sldtitat_pf := rw_craprac.valor + vr_sldtitat_pf;
              ELSE
                vr_sldtitat_pj := rw_craprac.valor + vr_sldtitat_pj;
              END IF;
            END IF;
          
          -- DENTRO DO MES
          IF TO_CHAR(rw_craprac.dtmvtolt, 'MM/YYYY') = TO_CHAR(rw_crapdat.dtultdma, 'MM/YYYY') THEN
            -- QTD TITULOS APLICADOS
            IF rw_craprac.cdprodut = 1109 AND rw_craprac.inpeslig = 1 THEN -- Pessoa ligada
              vr_qtdtitap_pl := vr_qtdtitap_pl + 1;
            ELSE
              IF rw_craprac.inpessoa = 1 THEN
                vr_qtdtitap_pf := vr_qtdtitap_pf + 1;
              ELSE
                vr_qtdtitap_pj := vr_qtdtitap_pj + 1;
              END IF;
            END IF;
            
            -- VALOR TOTAL APLICADO
            IF rw_craprac.cdprodut = 1109 AND rw_craprac.inpeslig = 1 THEN -- Pessoa ligada
                vr_vlrtotap_pl := vr_vlrtotap_pl + rw_craprac.vlaplica;
            ELSE
              IF rw_craprac.inpessoa = 1 THEN
                vr_vlrtotap_pf := vr_vlrtotap_pf + rw_craprac.vlaplica;
              ELSE
                vr_vlrtotap_pj := vr_vlrtotap_pj + rw_craprac.vlaplica;
              END IF;
            END IF;
          END IF;

          FOR rw_craplac IN cr_craplac(rw_craprac.cdcooper,
                                       rw_craprac.nrdconta,
                                       rw_craprac.nraplica) LOOP
             
             -- RENDIMENTO CREDITADO
             IF rw_craplac.cdhistor = rw_crapcpc.cdhsrdap THEN
               IF rw_craprac.cdprodut = 1109 AND rw_craprac.inpeslig = 1 THEN -- Pessoa ligada
                  vr_rencreme_pl := vr_rencreme_pl + rw_craplac.vllanmto;
               ELSE
                 IF rw_craplac.inpessoa = 1 THEN
                   vr_rencreme_pf := vr_rencreme_pf + rw_craplac.vllanmto;
                 ELSE
                   vr_rencreme_pj := vr_rencreme_pj + rw_craplac.vllanmto;
                 END IF;
               END IF;
               
             -- RENDIMENTO DEBITADO
             ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsrnap THEN
               IF rw_craprac.cdprodut = 1109 AND rw_craprac.inpeslig = 1 THEN -- Pessoa ligada
                   vr_rendebme_pl := vr_rendebme_pl + rw_craplac.vllanmto;
               ELSE
                 IF rw_craplac.inpessoa = 1 THEN
                   vr_rendebme_pf := vr_rendebme_pf + rw_craplac.vllanmto;
                 ELSE 
                   vr_rendebme_pj := vr_rendebme_pj + rw_craplac.vllanmto;
                 END IF;
               END IF;
               
             -- VALOR PROVISAO TOTAL
             ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsprap THEN
               IF rw_craprac.cdprodut = 1109 AND rw_craprac.inpeslig = 1 THEN -- Pessoa ligada
                   vr_ajtprome_pl := vr_ajtprome_pl + rw_craplac.vllanmto;
               ELSE
                 IF rw_craplac.inpessoa = 1 THEN
                   vr_ajtprome_pf := vr_ajtprome_pf + rw_craplac.vllanmto;
                 ELSE
                   vr_ajtprome_pj := vr_ajtprome_pj + rw_craplac.vllanmto;
                 END IF;
              END IF;
               
             -- VALOR REVERSAO TOTAL
             ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsrvap THEN
               IF rw_craprac.cdprodut = 1109 AND rw_craprac.inpeslig = 1 THEN -- Pessoa ligada
                   vr_restitve_pl := vr_restitve_pl + rw_craplac.vllanmto;
               ELSE
                 IF rw_craplac.inpessoa = 1 THEN
                   vr_restitve_pf := vr_restitve_pf + rw_craplac.vllanmto;
                 ELSE 
                   vr_restitve_pj := vr_restitve_pj + rw_craplac.vllanmto;
                 END IF;
               END IF;
               
             -- VALOR TOTAL RESGATE NO MES
             ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsrgap OR 
                   rw_craplac.cdhistor = rw_crapcpc.cdhsvtap THEN
               IF rw_craprac.cdprodut = 1109 AND rw_craprac.inpeslig = 1 THEN -- Pessoa ligada
                   vr_saqsemre_pl := vr_saqsemre_pl + rw_craplac.vllanmto;
               ELSE
                 IF rw_craplac.inpessoa = 1 THEN
                   vr_saqsemre_pf := vr_saqsemre_pf + rw_craplac.vllanmto;
                 ELSE 
                   vr_saqsemre_pj := vr_saqsemre_pj + rw_craplac.vllanmto;
                 END IF;
               END IF;
               
             -- VALOR TOTAL IR RETIDO NO MES
             ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsirap THEN
               IF rw_craprac.cdprodut = 1109 AND rw_craprac.inpeslig = 1 THEN -- Pessoa ligada
                   vr_imprenrf_pl := vr_imprenrf_pl + rw_craplac.vllanmto;
               ELSE
                 IF rw_craplac.inpessoa = 1 THEN
                   vr_imprenrf_pf := vr_imprenrf_pf + rw_craplac.vllanmto;
                 ELSE
                   vr_imprenrf_pj := vr_imprenrf_pj + rw_craplac.vllanmto;
                 END IF;
               END IF;
             END IF;
             
          END LOOP;
          
          IF rw_craprac.qtddiasvcto <= 90 THEN
            vr_idx := 90;
          ELSIF rw_craprac.qtddiasvcto <= 180 THEN
            vr_idx := 180;
          ELSIF rw_craprac.qtddiasvcto <= 270 THEN
            vr_idx := 270;
          ELSIF rw_craprac.qtddiasvcto <= 360 THEN
            vr_idx := 360;
          ELSIF rw_craprac.qtddiasvcto <= 720 THEN
            vr_idx := 720;
          ELSIF rw_craprac.qtddiasvcto <= 1080 THEN
            vr_idx := 1080;
          ELSIF rw_craprac.qtddiasvcto <= 1440 THEN
            vr_idx := 1440;
          ELSIF rw_craprac.qtddiasvcto <= 1800 THEN
            vr_idx := 1800;
          ELSIF rw_craprac.qtddiasvcto <= 2160 THEN
            vr_idx := 2160;
          ELSIF rw_craprac.qtddiasvcto <= 2520 THEN
            vr_idx := 2520;
          ELSIF rw_craprac.qtddiasvcto <= 2880 THEN
            vr_idx := 2880;
          ELSIF rw_craprac.qtddiasvcto <= 3240 THEN
            vr_idx := 3240;
          ELSIF rw_craprac.qtddiasvcto <= 3600 THEN
            vr_idx := 3600;
          ELSIF rw_craprac.qtddiasvcto <= 3960 THEN
            vr_idx := 3960;
          ELSIF rw_craprac.qtddiasvcto <= 4320 THEN
            vr_idx := 4320;
          ELSIF rw_craprac.qtddiasvcto <= 4680 THEN
            vr_idx := 4680;
          ELSIF rw_craprac.qtddiasvcto <= 5040 THEN
            vr_idx := 5040;
          ELSIF rw_craprac.qtddiasvcto <= 5400 THEN
            vr_idx := 5400;
          ELSIF rw_craprac.qtddiasvcto >= 5401 THEN
            vr_idx := 5401;
          END IF;
          
          vr_tab_crrl795(vr_idx).id := vr_idx;
          vr_tab_crrl795(vr_idx).quantida := NVL(vr_tab_crrl795(vr_idx).quantida, 0) + 1;
          vr_tab_crrl795(vr_idx).vlrvalor := NVL(rw_craprac.valor, 0) + NVL(vr_tab_crrl795(vr_idx).vlrvalor, 0);

        END LOOP;
        
        pc_escreve_xml('<resumo>'||
                       '<qtdtitat_pf>' || vr_qtdtitat_pf || '</qtdtitat_pf>' ||
                       '<qtdtitat_pj>' || vr_qtdtitat_pj || '</qtdtitat_pj>' ||
                       '<qtdtitat_pl>' || vr_qtdtitat_pl || '</qtdtitat_pl>' ||
                       '<qtdtitat_to>' || to_char(vr_qtdtitat_pf + vr_qtdtitat_pj+ vr_qtdtitat_pl) || '</qtdtitat_to>' ||
                       '<qtdtitap_pf>' || vr_qtdtitap_pf || '</qtdtitap_pf>' ||
                       '<qtdtitap_pj>' || vr_qtdtitap_pj || '</qtdtitap_pj>' ||
                       '<qtdtitap_pl>' || vr_qtdtitap_pl || '</qtdtitap_pl>' ||
                       '<qtdtitap_to>' || to_char(vr_qtdtitap_pf + vr_qtdtitap_pj+ vr_qtdtitap_pl) || '</qtdtitap_to>' ||
                       '<sldtitat_pf>' || to_char(vr_sldtitat_pf, 'FM99G999G999G999G999G999G999G990D00') || '</sldtitat_pf>' ||
                       '<sldtitat_pj>' || to_char(vr_sldtitat_pj, 'FM99G999G999G999G999G999G999G990D00') || '</sldtitat_pj>' ||
                       '<sldtitat_pl>' || to_char(vr_sldtitat_pl, 'FM99G999G999G999G999G999G999G990D00') || '</sldtitat_pl>' ||
                       '<sldtitat_to>' || to_char(vr_sldtitat_pf + vr_sldtitat_pj + vr_sldtitat_pl, 'FM99G999G999G999G999G999G999G990D00') || '</sldtitat_to>' ||
                       '<vlrtotap_pf>' || to_char(vr_vlrtotap_pf, 'FM99G999G999G999G999G999G999G990D00') || '</vlrtotap_pf>' ||
                       '<vlrtotap_pj>' || to_char(vr_vlrtotap_pj, 'FM99G999G999G999G999G999G999G990D00') || '</vlrtotap_pj>' ||
                       '<vlrtotap_pl>' || to_char(vr_vlrtotap_pl, 'FM99G999G999G999G999G999G999G990D00') || '</vlrtotap_pl>' ||
                       '<vlrtotap_to>' || to_char(vr_vlrtotap_pf + vr_vlrtotap_pj + vr_vlrtotap_pl, 'FM99G999G999G999G999G999G999G990D00') || '</vlrtotap_to>' ||
                       '<rencreme_pf>' || to_char(vr_rencreme_pf, 'FM99G999G999G999G999G999G999G990D00') || '</rencreme_pf>' ||
                       '<rencreme_pj>' || to_char(vr_rencreme_pj, 'FM99G999G999G999G999G999G999G990D00') || '</rencreme_pj>' ||
                       '<rencreme_pl>' || to_char(vr_rencreme_pl, 'FM99G999G999G999G999G999G999G990D00') || '</rencreme_pl>' ||
                       '<rencreme_to>' || to_char(vr_rencreme_pf + vr_rencreme_pj + vr_rencreme_pl, 'FM99G999G999G999G999G999G999G990D00') || '</rencreme_to>' ||
                       '<rendebme_pf>' || to_char(vr_rendebme_pf, 'FM99G999G999G999G999G999G999G990D00') || '</rendebme_pf>' ||
                       '<rendebme_pj>' || to_char(vr_rendebme_pj, 'FM99G999G999G999G999G999G999G990D00') || '</rendebme_pj>' ||
                       '<rendebme_pl>' || to_char(vr_rendebme_pl, 'FM99G999G999G999G999G999G999G990D00') || '</rendebme_pl>' ||
                       '<rendebme_to>' || to_char(vr_rendebme_pf + vr_rendebme_pj + vr_rendebme_pl, 'FM99G999G999G999G999G999G999G990D00') || '</rendebme_to>' ||
                       '<vlrtotpr_pf>' || to_char(vr_vlrtotpr_pf, 'FM99G999G999G999G999G999G999G990D00') || '</vlrtotpr_pf>' ||
                       '<vlrtotpr_pj>' || to_char(vr_vlrtotpr_pj, 'FM99G999G999G999G999G999G999G990D00') || '</vlrtotpr_pj>' ||
                       '<vlrtotpr_pl>' || to_char(vr_vlrtotpr_pl, 'FM99G999G999G999G999G999G999G990D00') || '</vlrtotpr_pl>' ||
                       '<vlrtotpr_to>' || to_char(vr_vlrtotpr_pf + vr_vlrtotpr_pj + vr_vlrtotpr_pl, 'FM99G999G999G999G999G999G999G990D00') || '</vlrtotpr_to>' ||
                       '<ajtprome_pf>' || to_char(vr_ajtprome_pf, 'FM99G999G999G999G999G999G999G990D00') || '</ajtprome_pf>' ||
                       '<ajtprome_pj>' || to_char(vr_ajtprome_pj, 'FM99G999G999G999G999G999G999G990D00') || '</ajtprome_pj>' ||
                       '<ajtprome_pl>' || to_char(vr_ajtprome_pl, 'FM99G999G999G999G999G999G999G990D00') || '</ajtprome_pl>' ||
                       '<ajtprome_to>' || to_char(vr_ajtprome_pf + vr_ajtprome_pj + vr_ajtprome_pl, 'FM99G999G999G999G999G999G999G990D00') || '</ajtprome_to>' ||
                       '<restitve_pf>' || to_char(vr_restitve_pf, 'FM99G999G999G999G999G999G999G990D00') || '</restitve_pf>' ||
                       '<restitve_pj>' || to_char(vr_restitve_pj, 'FM99G999G999G999G999G999G999G990D00') || '</restitve_pj>' ||
                       '<restitve_pl>' || to_char(vr_restitve_pl, 'FM99G999G999G999G999G999G999G990D00') || '</restitve_pl>' ||
                       '<restitve_to>' || to_char(vr_restitve_pf + vr_restitve_pj + vr_restitve_pl, 'FM99G999G999G999G999G999G999G990D00') || '</restitve_to>' ||
                       '<saqsemre_pf>' || to_char(vr_saqsemre_pf, 'FM99G999G999G999G999G999G999G990D00') || '</saqsemre_pf>' ||
                       '<saqsemre_pj>' || to_char(vr_saqsemre_pj, 'FM99G999G999G999G999G999G999G990D00') || '</saqsemre_pj>' ||
                       '<saqsemre_pl>' || to_char(vr_saqsemre_pl, 'FM99G999G999G999G999G999G999G990D00') || '</saqsemre_pl>' ||
                       '<saqsemre_to>' || to_char(vr_saqsemre_pf + vr_saqsemre_pj + vr_saqsemre_pl, 'FM99G999G999G999G999G999G999G990D00') || '</saqsemre_to>' ||
                       '<saqcomre_pf>' || to_char(vr_saqcomre_pf, 'FM99G999G999G999G999G999G999G990D00') || '</saqcomre_pf>' ||
                       '<saqcomre_pj>' || to_char(vr_saqcomre_pj, 'FM99G999G999G999G999G999G999G990D00') || '</saqcomre_pj>' ||
                       '<saqcomre_pl>' || to_char(vr_saqcomre_pl, 'FM99G999G999G999G999G999G999G990D00') || '</saqcomre_pl>' ||
                       '<saqcomre_to>' || to_char(vr_saqcomre_pf + vr_saqcomre_pj + vr_saqcomre_pl, 'FM99G999G999G999G999G999G999G990D00') || '</saqcomre_to>' ||
                       '<imprenrf_pf>' || to_char(vr_imprenrf_pf, 'FM99G999G999G999G999G999G999G990D00') || '</imprenrf_pf>' ||
                       '<imprenrf_pj>' || to_char(vr_imprenrf_pj, 'FM99G999G999G999G999G999G999G990D00') || '</imprenrf_pj>' ||
                       '<imprenrf_pl>' || to_char(vr_imprenrf_pl, 'FM99G999G999G999G999G999G999G990D00') || '</imprenrf_pl>' ||
                       '<imprenrf_to>' || to_char(vr_imprenrf_pf + vr_imprenrf_pj + vr_imprenrf_pl, 'FM99G999G999G999G999G999G999G990D00') || '</imprenrf_to>' ||
                       '</resumo>');
        
        pc_escreve_xml('<prazos>');
        
        vr_idx := vr_tab_crrl795.FIRST;
        vr_acumulado := 0;
        WHILE vr_idx IS NOT NULL LOOP
          vr_acumulado := vr_acumulado + NVL(vr_tab_crrl795(vr_idx).vlrvalor, 0);
          pc_escreve_xml('<prazo>' ||
                            '<id>'|| vr_tab_crrl795(vr_idx).id ||'</id> ' ||
                            '<vlrvalor>' || to_char(vr_tab_crrl795(vr_idx).vlrvalor, 'FM99G999G999G999G999G999G999G990D00') ||'</vlrvalor>' ||
                            '<vlrvalac>' || to_char(vr_acumulado, 'FM99G999G999G999G999G999G999G990D00') || '</vlrvalac>'||
                            '<quantida>' || vr_tab_crrl795(vr_idx).quantida || '</quantida>' ||
                         '</prazo>');
          vr_idx := vr_tab_crrl795.NEXT(vr_idx);
        END LOOP;
      
        vr_tab_crrl795.delete;
      
        pc_escreve_xml('</prazos>');
        pc_escreve_xml('</produto>');
        
      END LOOP;
      
      pc_escreve_xml('</cooperativa>');
      pc_escreve_xml('</raiz>');

      -- SOLICITACAO DO RELATORIO
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa
                                  pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                                  pr_dsxml     => vr_clobxml,          --> Arquivo XML de dados
                                  pr_dsxmlnode => '/raiz/cooperativa/produto', --> Nó do XML para iteração
                                  pr_dsjasper  => 'crrl823_principal.jasper', --'crrl678.jasper',    --> Arquivo de layout do iReport
                                  pr_dsparams  => 'PR_DTMVTOLT##' || to_char(rw_crapdat.dtultdma, 'DD/MM/YYYY'), --> Array de parametros diversos
                                  pr_dsarqsaid => vr_dsarquiv,         --> Path/Nome do arquivo PDF gerado
                                  pr_flg_gerar => 'S',                 --> Gerar o arquivo na hora*
                                  pr_qtcoluna  => 132,                 --> Qtd colunas do relatório (80,132,234)
                                  pr_sqcabrel  => 1,                   --> Indicado de seq do cabrel
                                  pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)*
                                  pr_nmformul  => '',                  --> Nome do formulário para impressão
                                  pr_nrcopias  => 1,                   --> Qtd de cópias
                                  pr_flappend  => 'N',                 --> Indica que a solicitação irá incrementar o arquivo
                                  pr_nrvergrl  => 1,
                                  pr_des_erro  => vr_dscritic);        --> Saída com erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
 
      COMMIT;
      
      -- LIBERA A MEMORIA ALOCADA P/ VARIAVE CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);      
      
      -- Log de fim de execucao
    pc_controla_log_batch(pr_dstiplog => 'F'
               ,pr_flgsuces => 1
               ,pr_cdcooper => pr_cdcooper);

    EXCEPTION
      WHEN vr_exc_erro THEN

    ROLLBACK;

    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
        
        -- Log de erro de execucao
        pc_controla_log_batch(pr_dstiplog => 'O'
                             ,pr_tpocorre => 4
                             ,pr_cdcricid => 0
                             ,pr_cdcritic => NVL(vr_cdcritic,0)
                             ,pr_dscritic => vr_dscritic
                             ,pr_cdcooper => pr_cdcooper);
                             
    pc_controla_log_batch(pr_dstiplog => 'F'
               ,pr_flgsuces => 0
               ,pr_cdcooper => pr_cdcooper);
                                                                    
    -- Nao precisa mandar email se tiver reagendado o JOB
        IF NVL(vr_intipmsg,1) <> 3 THEN -- IF upper(vr_dscritic) NOT LIKE '%JOB REAGENDADO PARA%' THEN          
          pc_envia_email;
        END IF;
    
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);     

    ROLLBACK;

    pr_cdcritic := 9999;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                   vr_cdprogra || '. ' || SQLERRM;

        -- Log de erro de execucao
        pc_controla_log_batch(pr_dstiplog => 'E'
                             ,pr_tpocorre => 3
                             ,pr_cdcricid => 0
                         ,pr_cdcritic => NVL(pr_cdcritic,0)
                             ,pr_dscritic => pr_dscritic
                             ,pr_cdcooper => pr_cdcooper);

        pc_controla_log_batch(pr_dstiplog => 'F'
                 ,pr_flgsuces => 0
                 ,pr_cdcooper => pr_cdcooper);
                             
        pc_envia_email;
    END;
END PC_CRPS795_poupanca;

begin
  declare
    vr_cdcritic     crapcri.cdcritic%TYPE;
    vr_dscritic     crapcri.dscritic%TYPE;
  begin
   pc_crps795_poupanca (pr_cdcooper => 1
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
    --
    dbms_output.put_line('vr_cdcritic:'||vr_cdcritic);
    dbms_output.put_line('vr_dscritic:'||vr_dscritic);
    --
    pc_crps795_poupanca (pr_cdcooper => 16
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
    --
    dbms_output.put_line('vr_cdcritic:'||vr_cdcritic);
    dbms_output.put_line('vr_dscritic:'||vr_dscritic);
    
  end;  
end;  
