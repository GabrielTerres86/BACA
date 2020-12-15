PL/SQL Developer Test script 3.0
1380
-- Created on 09/12/2020 by F0032386 
declare 

  vr_cdprogra   VARCHAR2(100) := 'RECP0003'; --PRB0041875
  vr_flgerlog   BOOLEAN       := FALSE;
  vr_flgemail   BOOLEAN       := FALSE;

  PROCEDURE pc_gera_log(pr_cdcooper      IN PLS_INTEGER           --> Cooperativa
                       ,pr_dstiplog      IN VARCHAR2              --> Tipo Log
                       ,pr_dscritic      IN VARCHAR2 DEFAULT NULL --> Descricao da critica
                       ,pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0
                       ,pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0
                       ,pr_ind_tipo_log  IN tbgen_prglog_ocorrencia.tpocorrencia%type DEFAULT 2
                       ,pr_nmarqlog      IN tbgen_prglog.nmarqlog%type DEFAULT NULL
                       ,pr_tpexecucao    IN tbgen_prglog.tpexecucao%type DEFAULT 1 -- cadeia - 12/02/2019 - REQ0035813
                       ) IS
  
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
    --
  BEGIN         
    --> Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E'), 
                           pr_cdcooper      => pr_cdcooper, 
                           pr_tpocorrencia  => pr_ind_tipo_log, 
                           pr_cdprograma    => vr_cdprogra, 
                           pr_tpexecucao    => pr_tpexecucao,
                           pr_cdcriticidade => pr_cdcriticidade,
                           pr_cdmensagem    => pr_cdmensagem,    
                           pr_dsmensagem    => pr_dscritic,               
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => pr_nmarqlog);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
  END pc_gera_log;
  
  -- Controla log proc_batch, para apensa exibir qnd realmente processar informacao
  PROCEDURE pc_controla_log_batch(pr_cdcooper IN PLS_INTEGER
                                 ,pr_dstiplog IN VARCHAR2
                                 ,pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_controla_log_batch');

    --> Controlar geração de log de execução dos jobs
    BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                             ,pr_cdprogra  => 'JOB_ACORDO_CYBER' --> Codigo do programa
                             ,pr_nomdojob  => 'JOB_ACORDO_CYBER' --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

    -- Limpa nome do modulo logado - 15/08/2019 - PRB0041875
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
  END pc_controla_log_batch;


  -- Importa arquivo referente a acordos quitados
  PROCEDURE pc_imp_arq_acordo_quitado(pr_flgemail OUT BOOLEAN
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    
                                  
      -- Variaveis de Erros
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic crapcri.dscritic%TYPE := '';
     
      -- Variaveis Locais
      vr_des_erro VARCHAR2(100);
      vr_nmarqtxt VARCHAR2(200)  := '';
      vr_nmtmpzip VARCHAR2(4000) := '';
      vr_endarqui VARCHAR2(4000) := '';
      vr_nmtmparq VARCHAR2(4000) := '';
      vr_nmarqzip VARCHAR2(4000) := '';
      vr_setlinha VARCHAR2(4000) := '';
      vr_nrindice INTEGER;
      vr_idx_txt  INTEGER;
      vr_nrlinha  INTEGER := 0;
      vr_inprejuz BOOLEAN;
      vr_cdcooper crapcop.cdcooper%TYPE := 3;

      -- Variavel de retorno
      vr_des_reto  VARCHAR2(100);

      --Variaveis Comando Unix
      vr_typ_saida VARCHAR2(10);
      vr_comando   VARCHAR2(4000);
      vr_listadir  VARCHAR2(4000);
      vr_endarqtxt VARCHAR2(4000);
      vr_input_file  utl_file.file_type;

      -- Tabela para armazenar arquivos lidos
      vr_tab_arqzip gene0002.typ_split;
      vr_tab_arqtxt gene0002.typ_split;

      vr_vlsddisp NUMBER(25,2) := 0; -- Saldo disponivel
      vr_vltotpag NUMBER(25,2) := 0; -- Valor Total de Pagamento
      vr_vllancam NUMBER(25,2) := 0; -- Saldo disponivel
      vr_vllanacc NUMBER(25,2) := 0; -- Valor do abatimento em conta corrente
      vr_vllanact NUMBER(25,2) := 0; -- Valor do abatimento em contratos (emprésitmo, desc. de título)
      vr_vlpagmto NUMBER;
      vr_idvlrmin NUMBER(25,2) := 0; -- Indicador de valor Minimo
      vr_cdoperad crapope.cdoperad%TYPE := '1';
      vr_nmdatela craptel.nmdatela%TYPE := 'JOB';
      vr_nracordo NUMBER;
      vr_dtquitac DATE;

      vr_cdhistor craplcm.cdhistor%type;
      
      vr_vlrabono      tbcc_prejuizo.vlrabono%TYPE;
      vr_valor_pagar   tbdsct_lancamento_bordero.vllanmto%TYPE;   
      vr_valor_pagmto  tbdsct_lancamento_bordero.vllanmto%TYPE;   
      vr_exc_proximo  EXCEPTION;
      
      -- Consulta contratos em acordo
      CURSOR cr_crapcyb(pr_nracordo tbrecup_acordo.nracordo%TYPE) IS
        WITH acordo_contrato AS (
             SELECT a.cdcooper
              , a.nracordo
              , a.nrdconta
              , c.nrctremp
              , c.cdorigem
              , c.indpagar
           FROM tbrecup_acordo a
              , tbrecup_acordo_contrato c
         WHERE a.nracordo = pr_nracordo
           AND c.nracordo = a.nracordo 
           AND c.indpagar = 'S'
        )
        SELECT acc.nracordo
              ,acc.cdcooper
              ,acc.nrdconta
              ,acc.cdorigem
              ,acc.nrctremp
          FROM acordo_contrato acc,
               crapcyb cyb
         WHERE cyb.cdcooper(+) = acc.cdcooper
           AND cyb.nrdconta(+) = acc.nrdconta
           AND cyb.nrctremp(+) = acc.nrctremp
           AND cyb.cdorigem(+) = acc.cdorigem          
      ORDER BY cyb.cdorigem;
      rw_crapcyb cr_crapcyb%ROWTYPE;

      -- Consulta PA e limites de credito do cooperado
      CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT ass.cdagenci
              ,ass.vllimcre
              ,ass.cdcooper
              ,ass.nrdconta
              ,ass.inprejuz
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
     
      -- Consulta cooperativas
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
          FROM crapcop cop
         WHERE cop.flgativo = 1;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Consulta valor bloqueado pelo acordo
      CURSOR cr_nracordo(pr_nracordo tbrecup_acordo.nracordo%TYPE)IS
        SELECT aco.vlbloqueado
              ,aco.cdcooper
              ,aco.nrdconta
              ,aco.nracordo
              ,aco.cdsituacao
         FROM tbrecup_acordo aco
        WHERE aco.nracordo = pr_nracordo;
      rw_nracordo cr_nracordo%ROWTYPE;  

      -- Consulta valor bloqueado pelo acordo
      CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crapepr.nrctremp%TYPE)IS
        SELECT epr.cdcooper
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.inliquid
              ,epr.inprejuz
              ,epr.flgpagto
              ,epr.tpemprst
              ,epr.vlsdprej
              ,epr.vlprejuz
              ,epr.vlsprjat
              ,epr.vlpreemp
              ,epr.vlttmupr
              ,epr.vlpgmupr
              ,epr.vlttjmpr
              ,epr.vlpgjmpr
              ,epr.cdlcremp
              ,epr.qtprepag
              ,epr.vlsdeved
              ,epr.vlsdevat
              ,epr.vljuracu
              ,epr.txjuremp
              ,epr.dtultpag
              ,epr.vliofcpl
              ,epr.dtmvtolt
              ,epr.vlemprst
              ,epr.txmensal
              ,epr.dtdpagto
              ,epr.vlsprojt
              ,epr.qttolatr
              ,wpr.dtdpagto wdtdpagto
              ,wpr.txmensal wtxmensal
         FROM crapepr epr
             ,crawepr wpr
        WHERE epr.cdcooper = wpr.cdcooper(+)
          AND epr.nrdconta = wpr.nrdconta(+)
          AND epr.nrctremp = wpr.nrctremp(+)
          AND epr.cdcooper = pr_cdcooper
          AND epr.nrdconta = pr_nrdconta
          AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;      

      --PRB0043380
      --Selecionar informacoes dos titulos do bordero
      CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%type
                        ,pr_nrdconta IN craptdb.nrdconta%type
                        ,pr_nrctrdsc IN tbdsct_titulo_cyber.nrctrdsc%type) IS
         SELECT bdt.inprejuz 
               ,tdb.nrborder
               ,tdb.cdbandoc
               ,tdb.nrdctabb
               ,tdb.nrcnvcob
               ,tdb.nrdocmto
                ,CASE
                   WHEN bdt.inprejuz = 0 THEN (vlsldtit + (vlmtatit - vlpagmta) + (vlmratit - vlpagmra)+ (vliofcpl - vlpagiof))
                   ELSE 0
                 END as vlsdeved    
                ,CASE
                   WHEN bdt.inprejuz = 1 THEN nvl(tdb.vlsdprej + (tdb.vlttjmpr - tdb.vlpgjmpr) + (tdb.vlttmupr - tdb.vlpgmupr) + (tdb.vljraprj - tdb.vlpgjrpr) + (tdb.vliofprj - tdb.vliofppr),0)
                   ELSE 0
                 END as vlsdprej
                ,CASE
                   WHEN bdt.inprejuz = 0 THEN (vlsldtit + (vlmtatit - vlpagmta) + (vlmratit - vlpagmra)+ (vliofcpl - vlpagiof))
                   ELSE 0
                 END as vlatraso
            FROM   craptdb tdb
                  ,tbdsct_titulo_cyber titcyb
                  ,crapbdt bdt
            WHERE  tdb.dtresgat    IS NULL
            AND    tdb.dtlibbdt    IS NOT NULL
            AND    tdb.dtdpagto    IS NULL
            AND    bdt.nrborder    = tdb.nrborder
            AND    bdt.nrdconta    = tdb.nrdconta
            AND    bdt.cdcooper    = tdb.cdcooper
            AND    tdb.nrtitulo    = titcyb.nrtitulo
            AND    tdb.nrborder    = titcyb.nrborder
            AND    tdb.nrdconta    = titcyb.nrdconta
            AND    tdb.cdcooper    = titcyb.cdcooper
            AND    titcyb.nrctrdsc = pr_nrctrdsc
            AND    titcyb.nrdconta = pr_nrdconta
            AND    titcyb.cdcooper = pr_cdcooper;
         
      rw_craptdb cr_craptdb%ROWTYPE;
      
      -- Cursor genérico de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      TYPE typ_tab_crapdat IS
      TABLE OF btch0001.cr_crapdat%ROWTYPE
      INDEX BY BINARY_INTEGER;
            
      -- Tabela de Saldos
      vr_tab_saldos EXTR0001.typ_tab_saldos;
      vr_tab_crapdat typ_tab_crapdat;
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_index_saldo INTEGER;

    BEGIN
      -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');

      FOR rw_crapcop IN cr_crapcop LOOP
        OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        
        vr_tab_crapdat(rw_crapcop.cdcooper) := rw_crapdat;

        CLOSE btch0001.cr_crapdat;

      END LOOP;
  
      pr_flgemail := FALSE; 

      BEGIN
      
      
            
                 vr_vllanacc := 0;
                 vr_vllanact := 0;
                 vr_nracordo := 187316;
                 vr_dtquitac := TRUNC(SYSDATE);

                 -- PRB0042525 --                 
                 OPEN cr_nracordo(pr_nracordo => vr_nracordo);
                 FETCH cr_nracordo INTO rw_nracordo;
                 CLOSE cr_nracordo;
                 
                 -- Acordos quitados e cancelados.
                 IF rw_nracordo.cdsituacao IN (2,3) THEN
                   RAISE vr_exc_proximo;
                 END IF;
                 -- PRB0042525 --        

                 FOR rw_crapcyb IN cr_crapcyb(pr_nracordo => vr_nracordo) LOOP
                   
                   OPEN cr_crapass(pr_cdcooper => rw_crapcyb.cdcooper
                                  ,pr_nrdconta => rw_crapcyb.nrdconta);

                   FETCH cr_crapass INTO rw_crapass;
                     
                   CLOSE cr_crapass;

                   -- Estouro de Conta
                   IF rw_crapcyb.cdorigem IN (1) THEN 
                     --Limpar tabela saldos
                     vr_tab_saldos.DELETE;
                    
                     -- Saldo  disponivel
                     vr_vlsddisp := 0;

                     --Obter Saldo do Dia
                     EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crapcyb.cdcooper
                                                ,pr_rw_crapdat => vr_tab_crapdat(rw_crapcyb.cdcooper)
                                                ,pr_cdagenci   => rw_crapass.cdagenci
                                                ,pr_nrdcaixa   => 100
                                                ,pr_cdoperad   => vr_cdoperad
                                                ,pr_nrdconta   => rw_crapcyb.nrdconta
                                                ,pr_vllimcre   => rw_crapass.vllimcre
                                                ,pr_dtrefere   => vr_tab_crapdat(rw_crapcyb.cdcooper).dtmvtolt
                                                ,pr_des_reto   => vr_des_erro
                                                ,pr_tab_sald   => vr_tab_saldos
                                                ,pr_tipo_busca => 'A'
                                                ,pr_tab_erro   => vr_tab_erro);

                     IF vr_des_erro <> 'OK' THEN
                       vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                       vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                       -- Log de erro de execucao
                       vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na extr0001.pc_obtem_saldo_dia - ' || 
                                      ' Cooper: ' || rw_crapcyb.cdcooper ||
                                      ' Conta: ' || rw_crapcyb.nrdconta ||
                                      ' Acordo: ' || rw_crapcyb.nracordo ||
                                      ' vllimcre: ' || rw_crapass.vllimcre || ' - ' || vr_dscritic;

                       RAISE vr_exc_proximo;
                       
                     END IF;
                     -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                     GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');

                     --Buscar Indice
                     vr_index_saldo := vr_tab_saldos.FIRST;
                     IF vr_index_saldo IS NOT NULL THEN
                       -- Saldo Disponivel na conta corrente
                       vr_vlsddisp := NVL(vr_tab_saldos(vr_index_saldo).vlsddisp, 0);
                     END IF;

                     -- Armazenar valor para ser lancado no final como ajuste contabil
                     -- Somente deverá conter o valor para zerar o estouro de conta.
                     IF vr_vlsddisp < 0 THEN        

                       -- RITM0081683
                       IF NVL(rw_crapass.vllimcre,0) > 0 THEN
                         vr_vlsddisp := vr_vlsddisp + NVL(rw_crapass.vllimcre,0);
                       END IF; 
                       
                       RECP0001.pc_pagar_contrato_conta(pr_cdcooper => rw_crapcyb.cdcooper
                                                       ,pr_nrdconta => rw_crapcyb.nrdconta
                                                       ,pr_cdagenci => rw_crapass.cdagenci
                                                       ,pr_crapdat  => vr_tab_crapdat(rw_crapcyb.cdcooper)
                                                       ,pr_cdoperad => vr_cdoperad
                                                       ,pr_nracordo => rw_crapcyb.nracordo
                                                       ,pr_vlsddisp => vr_vlsddisp
                                                       ,pr_vlparcel => ABS(vr_vlsddisp)
                                                       ,pr_vltotpag => vr_vltotpag
                                                       ,pr_cdcritic => vr_cdcritic
                                                       ,pr_dscritic => vr_dscritic);
                                                       
                       IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN

                         IF NVL(vr_cdcritic,0) > 0 THEN
                           vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                         END IF;

                         vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na RECP0001.pc_pagar_contrato_conta - ' || 
                                        ' Cooper: ' || rw_crapcyb.cdcooper ||
                                        ' Conta: ' || rw_crapcyb.nrdconta ||
                                        ' Acordo: ' || rw_crapcyb.nracordo ||
                                        ' vr_vlsddisp: ' || vr_vlsddisp || ' - ' || vr_dscritic;

                         RAISE vr_exc_proximo;

                       END IF;
                       -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                       GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');

                       vr_vllanacc := NVL(vr_vllanacc,0) + NVL(ABS(vr_vltotpag),0);  -- Valor para lancto de abatimento na C/C (Reginaldo/AMcom - P450)
                       
                     END IF;

                   ELSIF rw_crapcyb.cdorigem IN (2,3) THEN
                     
                     OPEN cr_crapepr(pr_cdcooper => rw_crapcyb.cdcooper
                                    ,pr_nrdconta => rw_crapcyb.nrdconta
                                    ,pr_nrctremp => rw_crapcyb.nrctremp);

                     FETCH cr_crapepr INTO rw_crapepr;

                     IF cr_crapepr%NOTFOUND THEN
                       CLOSE cr_crapepr;
                       
                       -- Erro
                       vr_dscritic := 'Origem 2,3 -> Contrato Num. ' || trim(GENE0002.fn_mask_contrato(rw_crapcyb.nrctremp)) ||
                                      ' nao encontrado. Conta: ' || trim(GENE0002.fn_mask_conta(rw_crapcyb.nrdconta)) ||
                                      ', Cooperativa: ' || TO_CHAR(rw_crapcyb.cdcooper) ||
                                      ', Origem: '||rw_crapcyb.cdorigem ||
                                      ', Acordo: '||rw_crapcyb.nracordo;

                       RAISE vr_exc_proximo;
                       
                     ELSE
                       CLOSE cr_crapepr;
                     END IF;

                     -- Verificar se o contrato já está LIQUIDADO   OU
                     -- Se o contrato de PREJUIZO já foi TOTALMENTE PAGO
                     IF (rw_crapepr.inliquid = 1 AND rw_crapepr.inprejuz = 0) OR 
                        (rw_crapepr.inprejuz = 1 AND rw_crapepr.vlsdprej <= 0) THEN
                       -- Proximo Contrato
                       CONTINUE;
                     END IF;

                     -- Condicao para verificar se o contrato de emprestimo é de prejuizo
                     IF rw_crapepr.inprejuz = 1 THEN
                        
                       -- Realizar a chamada da rotina para pagamento de prejuizo
                       EMPR9999.pc_pagar_emprestimo_prejuizo(pr_cdcooper => rw_crapepr.cdcooper
                                                            ,pr_nrdconta => rw_crapepr.nrdconta         
                                                            ,pr_cdagenci => rw_crapass.cdagenci         
                                                            ,pr_crapdat  => vr_tab_crapdat(rw_crapepr.cdcooper)
                                                            ,pr_nrctremp => rw_crapepr.nrctremp 
                                                            ,pr_tpemprst => rw_crapepr.tpemprst
                                                            ,pr_vlprejuz => rw_crapepr.vlprejuz 
                                                            ,pr_vlsdprej => rw_crapepr.vlsdprej
                                                            ,pr_vlsprjat => rw_crapepr.vlsprjat 
                                                            ,pr_vlpreemp => rw_crapepr.vlpreemp 
                                                            ,pr_vlttmupr => rw_crapepr.vlttmupr
                                                            ,pr_vlpgmupr => rw_crapepr.vlpgmupr 
                                                            ,pr_vlttjmpr => rw_crapepr.vlttjmpr 
                                                            ,pr_vlpgjmpr => rw_crapepr.vlpgjmpr
                                                            ,pr_nrparcel => 0
                                                            ,pr_cdoperad => vr_cdoperad
                                                            ,pr_vlparcel => 0
                                                            ,pr_nmtelant => vr_nmdatela
                                                            ,pr_inliqaco => 'S'           -- Indicador informando que é para liquidar o contrato de emprestimo
                                                            ,pr_vliofcpl => rw_crapepr.vliofcpl
                                                            ,pr_vltotpag => vr_vltotpag -- Retorno do total pago       
                                                            ,pr_cdcritic => vr_cdcritic
                                                            ,pr_dscritic => vr_dscritic);
                       
                       -- Se retornar erro da rotina
                       IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                         IF NVL(vr_cdcritic,0) > 0 THEN
                           vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                         END IF;

                         vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na EMPR9999.pc_pagar_emprestimo_prejuizo - ' || 
                                        ' Cooper: ' || rw_crapepr.cdcooper ||
                                        ' Conta: ' || rw_crapepr.nrdconta ||
                                        ' Contrato: ' || rw_crapepr.nrctremp || 
                                        ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;
                         
                         RAISE vr_exc_proximo;
                         
                       END IF;
                       -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                       GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                        
                       -- Não deve mais gerar lancamento 2181 para pagamento prejuizo.
                       -- vr_vllancam := NVL(vr_vllancam,0) + NVL(vr_vltotpag,0);   
                     -- Folha de Pagamento
                     ELSIF rw_crapepr.flgpagto = 1 THEN 
                       
                       -- Realizar a chamada da rotina para pagamento de prejuizo
                       EMPR9999.pc_pagar_emprestimo_folha(pr_cdcooper => rw_crapepr.cdcooper
                                                         ,pr_nrdconta => rw_crapepr.nrdconta
                                                         ,pr_cdagenci => rw_crapass.cdagenci
                                                         ,pr_crapdat  => vr_tab_crapdat(rw_crapepr.cdcooper)
                                                         ,pr_nrctremp => rw_crapepr.nrctremp
                                                         ,pr_nrparcel => 0
                                                         ,pr_cdlcremp => rw_crapepr.cdlcremp
                                                         ,pr_inliquid => rw_crapepr.inliquid
                                                         ,pr_qtprepag => rw_crapepr.qtprepag
                                                         ,pr_vlsdeved => rw_crapepr.vlsdeved
                                                         ,pr_vlsdevat => rw_crapepr.vlsdevat
                                                         ,pr_vljuracu => rw_crapepr.vljuracu
                                                         ,pr_txjuremp => rw_crapepr.txjuremp
                                                         ,pr_dtultpag => rw_crapepr.dtultpag
                                                         ,pr_vlparcel => 0
                                                         ,pr_nmtelant => vr_nmdatela
                                                         ,pr_cdoperad => vr_cdoperad
                                                         ,pr_inliqaco => 'S'           -- Indicador informando que é para liquidar o contrato de emprestimo
                                                         ,pr_vltotpag => vr_vltotpag
                                                         ,pr_cdcritic => vr_cdcritic
                                                         ,pr_dscritic => vr_dscritic);
                       
                       -- Se retornar erro da rotina
                       IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                         IF NVL(vr_cdcritic,0) > 0 THEN
                           vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                         END IF;

                         vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na EMPR9999.pc_pagar_emprestimo_folha - ' || 
                                        ' Cooper: ' || rw_crapepr.cdcooper ||
                                        ' Conta: ' || rw_crapepr.nrdconta ||
                                        ' Contrato: ' || rw_crapepr.nrctremp || 
                                        ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                         RAISE vr_exc_proximo;
                         
                       END IF;
                       -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                       GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                       
                       vr_vllanact := NVL(vr_vllanact,0) + NVL(vr_vltotpag,0); 
                      -- Emprestimo TR
                      ELSIF rw_crapepr.tpemprst = 0 THEN
                        
                        -- Pagar empréstimo TR
                        EMPR9999.pc_pagar_emprestimo_tr(pr_cdcooper => rw_crapepr.cdcooper
                                                       ,pr_nrdconta => rw_crapepr.nrdconta
                                                       ,pr_cdagenci => rw_crapass.cdagenci
                                                       ,pr_crapdat  => vr_tab_crapdat(rw_crapepr.cdcooper)
                                                       ,pr_nrctremp => rw_crapepr.nrctremp
                                                       ,pr_nrparcel => 0
                                                       ,pr_cdlcremp => rw_crapepr.cdlcremp
                                                       ,pr_inliquid => rw_crapepr.inliquid
                                                       ,pr_qtprepag => rw_crapepr.qtprepag
                                                       ,pr_vlsdeved => rw_crapepr.vlsdeved
                                                       ,pr_vlsdevat => rw_crapepr.vlsdevat
                                                       ,pr_vljuracu => rw_crapepr.vljuracu
                                                       ,pr_txjuremp => rw_crapepr.txjuremp
                                                       ,pr_dtultpag => rw_crapepr.dtultpag
                                                       ,pr_vlparcel => 0
                                                       ,pr_idorigem => 7
                                                       ,pr_nmtelant => vr_nmdatela
                                                       ,pr_cdoperad => vr_cdoperad
                                                       ,pr_inliqaco => 'S'
                                                       ,pr_vltotpag => vr_vltotpag
                                                       ,pr_cdcritic => vr_cdcritic
                                                       ,pr_dscritic => vr_dscritic);
                         
                        -- Se retornar erro da rotina
                        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                          IF NVL(vr_cdcritic,0) > 0 THEN
                            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          END IF;

                          vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na EMPR9999.pc_pagar_emprestimo_tr - ' || 
                                         ' Cooper: ' || rw_crapepr.cdcooper ||
                                         ' Conta: ' || rw_crapepr.nrdconta ||
                                         ' Contrato: ' || rw_crapepr.nrctremp || 
                                         ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                          RAISE vr_exc_proximo;
                         
                        END IF;
                        -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                       
                        vr_vllanact := NVL(vr_vllanact,0) + NVL(vr_vltotpag,0); 
                      -- Emprestimo PP
                      ELSIF rw_crapepr.tpemprst = 1 THEN
                        -- Pagar empréstimo PP
                        RECP0001.pc_pagar_emprestimo_pp(pr_cdcooper => rw_crapepr.cdcooper
                                                       ,pr_nrdconta => rw_crapepr.nrdconta         
                                                       ,pr_cdagenci => rw_crapass.cdagenci         
                                                       ,pr_crapdat  => vr_tab_crapdat(rw_crapepr.cdcooper)
                                                       ,pr_nrctremp => rw_crapcyb.nrctremp
                                                       ,pr_nracordo => rw_crapcyb.nracordo
                                                       ,pr_nrparcel => 0
                                                       ,pr_vlsdeved => rw_crapepr.vlsdeved
                                                       ,pr_vlsdevat => rw_crapepr.vlsdevat
                                                       ,pr_vlparcel => 0
                                                       ,pr_idorigem => 7 
                                                       ,pr_nmtelant => vr_nmdatela
                                                       ,pr_cdoperad => vr_cdoperad
                                                       ,pr_inliqaco => 'S'
                                                       ,pr_idvlrmin => vr_idvlrmin
                                                       ,pr_vltotpag => vr_vltotpag         
                                                       ,pr_cdcritic => vr_cdcritic         
                                                       ,pr_dscritic => vr_dscritic);       
                        
                        -- Se retornar erro da rotina
                        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                          IF NVL(vr_cdcritic,0) > 0 THEN
                            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          END IF;

                          vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na RECP0001.pc_pagar_emprestimo_pp - ' || 
                                         ' Cooper: ' || rw_crapepr.cdcooper ||
                                         ' Conta: ' || rw_crapepr.nrdconta ||
                                         ' Contrato: ' || rw_crapepr.nrctremp || 
                                         ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                          RAISE vr_exc_proximo;
                         
                        END IF;
                        -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                       
                        vr_vllanact := NVL(vr_vllanact,0) + NVL(vr_vltotpag,0);
                      -- Emprestimo Pos-Fixado
                      ELSIF rw_crapepr.tpemprst = 2 THEN
                        -- Pagar emprestimo Pos-Fixado
                        recp0001.pc_pagar_emprestimo_pos(pr_cdcooper => rw_crapepr.cdcooper
                                              ,pr_nrdconta => rw_crapepr.nrdconta
                              ,pr_cdagenci => rw_crapass.cdagenci
                              ,pr_crapdat  => vr_tab_crapdat(rw_crapepr.cdcooper)
                              ,pr_nrctremp => rw_crapcyb.nrctremp
                              ,pr_dtefetiv => rw_crapepr.dtmvtolt
                              ,pr_cdlcremp => rw_crapepr.cdlcremp
                              ,pr_vlemprst => rw_crapepr.vlemprst
                                              ,pr_txmensal => rw_crapepr.wtxmensal
                                              ,pr_dtdpagto => rw_crapepr.wdtdpagto
                              ,pr_vlsprojt => rw_crapepr.vlsprojt
                              ,pr_qttolatr => rw_crapepr.qttolatr
                              ,pr_nrparcel => 0
                              ,pr_vlparcel => 0
                              ,pr_inliqaco => 'S'
                              ,pr_idorigem => 7
                              ,pr_nmtelant => vr_nmdatela
                              ,pr_cdoperad => vr_cdoperad
                              --
                              ,pr_idvlrmin => vr_idvlrmin
                              ,pr_vltotpag => vr_vltotpag
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic
                              );      
                        
                        -- Se retornar erro da rotina
                        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                          IF NVL(vr_cdcritic,0) > 0 THEN
                            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          END IF;

                          vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na RECP0001.pc_pagar_emprestimo_pos - ' || 
                                         ' Cooper: ' || rw_crapepr.cdcooper ||
                                         ' Conta: ' || rw_crapepr.nrdconta ||
                                         ' Contrato: ' || rw_crapepr.nrctremp || 
                                         ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                          RAISE vr_exc_proximo;
                         
                        END IF;
                        -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                       
                        vr_vllanact := NVL(vr_vllanact,0) + NVL(vr_vltotpag,0);
                      END IF;

                      -- Se a conta está em prejuízo, debita da conta transitória o valor pago no contrato de empréstimo
                      IF NVL(vr_vltotpag,0) > 0 AND rw_crapass.inprejuz = 1 THEN
                        PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => rw_crapepr.cdcooper
                                                    , pr_nrdconta => rw_crapepr.nrdconta
                                                    , pr_vlrlanc  => vr_vltotpag
                                                    , pr_dtmvtolt => vr_tab_crapdat(rw_crapepr.cdcooper).dtmvtolt
                                                    , pr_cdcritic => vr_cdcritic
                                                    , pr_dscritic => vr_dscritic);
                                                    
                        -- Se retornar erro da rotina
                        IF TRIM(vr_dscritic) IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
                          IF NVL(vr_cdcritic,0) > 0 THEN
                            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          END IF;
                          -- Log de erro de execucao
                          vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na PREJ0003.pc_gera_debt_cta_prj - ' || 
                                         ' Cooper: ' || rw_crapepr.cdcooper ||
                                         ' Conta: ' || rw_crapepr.nrdconta ||
                                         ' Contrato: ' || rw_crapepr.nrctremp || 
                                         ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                          RAISE vr_exc_proximo;
                         
                        END IF;
                        -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                     END IF;

                   --Desconto de Títulos - PRB0043380
                   ELSIF rw_crapcyb.cdorigem = 4 THEN
                     
                     vr_vltotpag := 0;

                     --Busca Saldo Devedor do Contrato
                     OPEN cr_craptdb(pr_cdcooper => rw_crapcyb.cdcooper
                                    ,pr_nrdconta => rw_crapcyb.nrdconta
                                    ,pr_nrctrdsc => rw_crapcyb.nrctremp);

                     FETCH cr_craptdb INTO rw_craptdb;
                     IF cr_craptdb%NOTFOUND THEN
                       CLOSE cr_craptdb;
                       
                         -- Se o contrato não estiver com situação = 3 (esperada no cursor, desconsidera
                         -- Grava para conferência, se necessário
                         vr_dscritic := 'Origem 4 -> Contrato Num. ' || trim(GENE0002.fn_mask_contrato(rw_crapcyb.nrctremp)) ||
                                        ' nao encontrado. Conta: ' || trim(GENE0002.fn_mask_conta(rw_crapcyb.nrdconta)) ||
                                        ', Cooperativa: ' || TO_CHAR(rw_crapcyb.cdcooper) ||
                                        ', Origem: '||rw_crapcyb.cdorigem ||
                                        ', Acordo: '||rw_crapcyb.nracordo;



                         CONTINUE;
                       
                     ELSE
                       CLOSE cr_craptdb;
                     END IF;


                     --Verifica se é rejuízo ou não, para informar o valor a ser pago
                     IF rw_craptdb.inprejuz = 1 THEN
                        vr_valor_pagar  := nvl(rw_craptdb.vlsdprej,0);
                        vr_valor_pagmto := 0;

                      --Paga e abona o valor
                      PREJ0005.pc_pagar_titulo_prejuizo(pr_cdcooper => rw_crapcyb.cdcooper
                                                       ,pr_cdagenci => rw_crapass.cdagenci
                                                       ,pr_nrdcaixa => 100
                                                       ,pr_cdoperad => vr_cdoperad
                                                       ,pr_nrdconta => rw_crapcyb.nrdconta
                                                       ,pr_nrborder => rw_craptdb.nrborder
                                                       ,pr_cdbandoc => rw_craptdb.cdbandoc
                                                       ,pr_nrdctabb => rw_craptdb.nrdctabb
                                                       ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                                       ,pr_nrdocmto => rw_craptdb.nrdocmto
                                                       ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt
                                                       ,pr_vlpagmto => vr_valor_pagmto
                                                       ,pr_vlaboorj => vr_valor_pagar
                                                       ,pr_flgvalac => 1
                                                       ,pr_cdcritic => vr_cdcritic
                                                       ,pr_dscritic => vr_dscritic);

                        -- Se retornar erro da rotina
                        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                          IF NVL(vr_cdcritic,0) > 0 THEN
                            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          END IF;

                          vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na PREJ0005.pc_pagar_titulo_prejuizo - ' || 
                                         ' Cooper: ' || rw_crapcyb.cdcooper ||
                                         ' Conta: ' || rw_crapcyb.nrdconta ||
                                         ' Contrato: ' || rw_crapcyb.nrctremp || 
                                         ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                          RAISE vr_exc_proximo;

                        END IF;
                        
                     ELSE  --Se título ativo

                       vr_valor_pagar := nvl(rw_craptdb.vlsdeved,0);

                       --Chama a rotina para pagamento de títulos
                       recp0001.pc_pagar_contrato_desc_tit( pr_cdcooper => rw_crapcyb.cdcooper
                                                   ,pr_nrdconta => rw_crapcyb.nrdconta
                                                   ,pr_nrctrdsc => rw_crapcyb.nrctremp
                                                   ,pr_crapdat  => vr_tab_crapdat(rw_crapass.cdcooper)
                                                   ,pr_cdagenci => rw_crapass.cdagenci
                                                   ,pr_nrdcaixa => 100 -- TO DO
                                                   ,pr_idorigem => rw_crapcyb.cdorigem
                                                   ,pr_cdoperad => vr_cdoperad
                                                   ,pr_vlparcel => vr_valor_pagar  -- Valor Total do Título
                                                   ,pr_idvlrmin => vr_idvlrmin
                                                   ,pr_vltotpag => vr_vltotpag
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

                        -- Se retornar erro da rotina
                        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                          IF NVL(vr_cdcritic,0) > 0 THEN
                            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          END IF;

                          vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na RECP0001.pc_pagar_contrato_desc_tit - ' || 
                                         ' Cooper: ' || rw_crapcyb.cdcooper ||
                                         ' Conta: ' || rw_crapcyb.nrdconta ||
                                         ' Contrato: ' || rw_crapcyb.nrctremp || 
                                         ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                          RAISE vr_exc_proximo;
                           
                        END IF;
                        
                        --Se a conta estiver em prejuízo...
                        vr_inprejuz := PREJ0003.fn_verifica_preju_conta(pr_cdcooper => rw_crapcyb.cdcooper
                                                                       ,pr_nrdconta => rw_crapcyb.nrdconta);

                        IF vr_inprejuz = TRUE THEN

                           --Efetua o lançamento de retorno do valor do abono (C) da conta transitória para a CC após o pagamento do acordo de descto de título.
                           PREJ0003.pc_gera_transf_cta_prj(pr_cdcooper => rw_crapcyb.cdcooper
                                                          ,pr_nrdconta => rw_crapcyb.nrdconta
                                                          ,pr_cdoperad => vr_cdoperad
                                                          ,pr_vllanmto => vr_vltotpag
                                                          ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt
                                                          ,pr_versaldo => 0  --Se deve validar o saldo disponível na conta transitória
                                                          ,pr_atsldlib => 0  --Se deve atualizar o saldo disponível para operações na conta corrente (VLSLDLIB)
                                                          ,pr_dsoperac => NULL
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);
                                                          

                          -- Se retornar erro da rotina
                          IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

                            IF NVL(vr_cdcritic,0) > 0 THEN
                              vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                            END IF;

                            vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na PREJ0003.pc_gera_transf_cta_prj - ' || 
                                           ' Cooper: ' || rw_crapcyb.cdcooper ||
                                           ' Conta: ' || rw_crapcyb.nrdconta ||
                                           ' Contrato: ' || rw_crapcyb.nrctremp || 
                                           ' Valor: '|| vr_vltotpag ||
                                           ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                            RAISE vr_exc_proximo;
                             
                          END IF;

                        END IF;

                     END IF;
                      
                      -- Inclui nome do modulo logado
                      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                       
                      vr_vllanact := NVL(vr_vllanact,0) + NVL(vr_vltotpag,0);

                   END IF;

                   BEGIN
                     UPDATE crapcyc 
                        SET flgehvip = decode(cdmotcin,2,flgehvip,7,flgehvip,flvipant),
                            cdmotcin = decode(cdmotcin,2,cdmotcin,7,cdmotcin,cdmotant),
                            dtaltera = vr_tab_crapdat(rw_crapcyb.cdcooper).dtmvtolt,
                            cdoperad = 'cyber'
                      WHERE cdcooper = rw_crapcyb.cdcooper
                        AND cdorigem = DECODE(rw_crapcyb.cdorigem,2,3,rw_crapcyb.cdorigem)
                        AND nrdconta = rw_crapcyb.nrdconta
                        AND nrctremp = rw_crapcyb.nrctremp;
                   EXCEPTION
                     WHEN OTHERS THEN
                       
                       vr_dscritic := TO_CHAR(SYSDATE,'hh24:mi:ss') || ' --> Arquivo: ' || vr_nmarqtxt || 
                                      ' Acordo: ' || vr_nracordo || ' - Erro ao atualizar CRAPCYC: '||SQLERRM;

                       RAISE vr_exc_proximo;
                       
                   END;

                 END LOOP;
                 
                 OPEN cr_nracordo(pr_nracordo => vr_nracordo);

                 FETCH cr_nracordo INTO rw_nracordo;

                 CLOSE cr_nracordo;

                 OPEN cr_crapass(pr_cdcooper => rw_nracordo.cdcooper
                                ,pr_nrdconta => rw_nracordo.nrdconta);   

                 FETCH cr_crapass INTO rw_crapass;               

                 CLOSE cr_crapass;

                 IF rw_nracordo.vlbloqueado > 0 THEN
                                      
                    IF rw_crapass.inprejuz = 0 THEN   
                    EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper                          --> Cooperativa conectada
                                                  ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt --> Movimento atual
                                                  ,pr_cdagenci => rw_crapass.cdagenci                          --> Código da agência
                                                  ,pr_cdbccxlt => 100                                          --> Número do caixa
                                                  ,pr_cdoperad => vr_cdoperad                                  --> Código do Operador
                                                  ,pr_cdpactra => rw_crapass.cdagenci                          --> P.A. da transação
                                                  ,pr_nrdolote => 650001                                       --> Numero do Lote
                                                  ,pr_nrdconta => rw_crapass.nrdconta                          --> Número da conta
                                                  ,pr_cdhistor => 2194                                         --> Codigo historico 2194 - CR.DESB.ACORD
                                                  ,pr_vllanmto => rw_nracordo.vlbloqueado                      --> Valor da parcela emprestimo
                                                  ,pr_nrparepr => 0                                            --> Número parcelas empréstimo
                                                  ,pr_nrctremp => rw_nracordo.nracordo                         --> Número do contrato de empréstimo
                                                  ,pr_des_reto => vr_des_reto                                  --> Retorno OK / NOK
                                                  ,pr_tab_erro => vr_tab_erro);                                --> Tabela com possíves erros
                    --Se Retornou erro
                    IF vr_des_reto <> 'OK' THEN
                      -- Se possui algum erro na tabela de erros
                      IF vr_tab_erro.count() > 0 THEN
                        -- Atribui críticas às variaveis
                        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                      ELSE
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao criar o lancamento de desbloqueio de acordo';
                      END IF;
                      
                      -- Log de erro de execucao
                      vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na EMPR0001.pc_cria_lancamento_cc - ' || 
                                     ' Cooper: ' || rw_crapepr.cdcooper ||
                                     ' Conta: ' || rw_crapepr.nrdconta ||
                                     ' Contrato: ' || rw_crapepr.nrctremp || 
                                     ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                      RAISE vr_exc_proximo;
                          
                    END IF;
                    -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                    ELSE
                      PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => rw_crapass.cdcooper
                                    , pr_nrdconta => rw_crapass.nrdconta
                                    , pr_vlrlanc  => rw_nracordo.vlbloqueado
                                    , pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt
                                    , pr_cdcritic => vr_cdcritic
                                    , pr_dscritic => vr_dscritic); 
                            
                      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                        
                        -- Log de erro de execucao
                        vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na PREJ0003.pc_gera_cred_cta_prj - ' || 
                                       ' Cooper: ' || rw_crapepr.cdcooper ||
                                       ' Conta: ' || rw_crapepr.nrdconta ||
                                       ' Contrato: ' || rw_crapepr.nrctremp || 
                                       ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                        RAISE vr_exc_proximo;
                      
                      END IF;
                      -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                    END IF;

                 END IF;

                 -- Verifica se deve lançar abatimento no acordo
                 IF vr_vllanacc + vr_vllanact - rw_nracordo.vlbloqueado > 0 THEN
                   IF rw_crapass.inprejuz = 0 THEN        
                     vr_vlrabono := vr_vllanacc + vr_vllanact - rw_nracordo.vlbloqueado;
                                  
                     -- Lança crédito do abono na conta corrente
                   EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper                          --> Cooperativa conectada
                                                 ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt --> Movimento atual
                                                 ,pr_cdagenci => rw_crapass.cdagenci                          --> Código da agência
                                                 ,pr_cdbccxlt => 100                                          --> Número do caixa
                                                 ,pr_cdoperad => vr_cdoperad                                  --> Código do Operador
                                                 ,pr_cdpactra => rw_crapass.cdagenci                          --> P.A. da transação
                                                 ,pr_nrdolote => 650001                                       --> Numero do Lote
                                                 ,pr_nrdconta => rw_crapass.nrdconta                          --> Número da conta
                                                 ,pr_cdhistor => 2181                                         --> Codigo historico
                                                   ,pr_vllanmto => vr_vlrabono                                  --> Valor do credito
                                                 ,pr_nrparepr => 0                                            --> Número do Acordo
                                                 ,pr_nrctremp => rw_nracordo.nracordo                         --> Número do contrato de empréstimo
                                                 ,pr_des_reto => vr_des_reto                                  --> Retorno OK / NOK
                                                 ,pr_tab_erro => vr_tab_erro);                                --> Tabela com possíves erros

                   -- Se ocorreu erro
                   IF vr_des_reto <> 'OK' THEN
                     -- Se possui algum erro na tabela de erros
                     IF vr_tab_erro.COUNT() > 0 THEN
                       vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                       vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                     ELSE
                       vr_cdcritic := 0;
                       vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
                     END IF;
                     -- Log de erro de execucao
                     vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na EMPR0001.pc_cria_lancamento_cc - ' || 
                                    ' Cooper: ' || rw_crapepr.cdcooper ||
                                    ' Conta: ' || rw_crapepr.nrdconta ||
                                    ' Contrato: ' || rw_crapepr.nrctremp || 
                                    ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;
 
                     RAISE vr_exc_proximo;
                        
                   END IF;
                   -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                   GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                   ELSE
                     IF vr_vllanacc > 0 THEN -- Abatimento em conta corrente
                       IF vr_vllanacc > rw_nracordo.vlbloqueado THEN
                         vr_vlrabono := vr_vllanacc - rw_nracordo.vlbloqueado;
                       
                         -- Lança crédito do abono na conta corrente
                         EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper                          --> Cooperativa conectada
                                                       ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt --> Movimento atual
                                                       ,pr_cdagenci => rw_crapass.cdagenci                          --> Código da agência
                                                       ,pr_cdbccxlt => 100                                          --> Número do caixa
                                                       ,pr_cdoperad => vr_cdoperad                                  --> Código do Operador
                                                       ,pr_cdpactra => rw_crapass.cdagenci                          --> P.A. da transação
                                                       ,pr_nrdolote => 650001                                       --> Numero do Lote
                                                       ,pr_nrdconta => rw_crapass.nrdconta                          --> Número da conta
                                                       ,pr_cdhistor => 2919                                         --> Codigo historico
                                                       ,pr_vllanmto => vr_vlrabono                                  --> Valor do credito
                                                       ,pr_nrparepr => 0                                            --> Número do Acordo
                                                       ,pr_nrctremp => rw_nracordo.nracordo                         --> Número do contrato de empréstimo
                                                       ,pr_des_reto => vr_des_reto                                  --> Retorno OK / NOK
                                                       ,pr_tab_erro => vr_tab_erro);                                --> Tabela com possíves erros

                         -- Se ocorreu erro
                         IF vr_des_reto <> 'OK' THEN
                           -- Se possui algum erro na tabela de erros
                           IF vr_tab_erro.COUNT() > 0 THEN
                             vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                             vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                           ELSE
                             vr_cdcritic := 0;
                             vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
                           END IF;
                           -- Log de erro de execucao
                           vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na EMPR0001.pc_cria_lancamento_cc - ' || 
                                          ' Cooper: ' || rw_crapepr.cdcooper ||
                                          ' Conta: ' || rw_crapepr.nrdconta ||
                                          ' Contrato: ' || rw_crapepr.nrctremp || 
                                          ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                           RAISE vr_exc_proximo;
                         END IF;
                         
                        
                         --01/10/2019 - PJ450.2 - Bug 25724 - Diferenças Contábeis - histórico 2919 - (Marcelo Elias Gonçalves/AMcom).                               
                         -- Efetua o pagamento do prejuízo de conta corrente
                         prej0003.pc_pagar_prejuizo_cc(pr_cdcooper => rw_crapass.cdcooper
                                                     , pr_nrdconta => rw_crapass.nrdconta
                                                     , pr_vlrpagto => vr_vlrabono 
                                                     , pr_indabono => 1 -- se for abono/abatimento (0 - Nao, 1 - Sim)                                          
                                                     , pr_cdcritic => vr_cdcritic
                                                     , pr_dscritic => vr_dscritic);                                                                                                                              
                         IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                           vr_dscritic := 'Erro ao Efetuar o Pagamento do Prejuízo de Conta Corrente (Abono). Cooperativa: '||rw_crapass.cdcooper||' | Conta: '||rw_crapass.nrdconta||'. Erro: '|| SubStr(SQLERRM,1,255);
                            -- Log de erro de execucao
                           vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na prej0003.pc_pagar_prejuizo_cc - ' || 
                                          ' Cooper: ' || rw_crapepr.cdcooper ||
                                          ' Conta: ' || rw_crapepr.nrdconta ||
                                          ' Contrato: ' || rw_crapepr.nrctremp || 
                                          ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;
 
                           RAISE vr_exc_proximo;
                         END IF; 
                         
                         
                         -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                         GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');

                 -- Atualiza valor do abono do saldo do prejuízo da conta corrente
                 BEGIN
                   -- Abate o valor do abono do saldo do prejuízo da conta corrente
                   UPDATE tbcc_prejuizo prj
                      SET vlsdprej = 0
                        , vljur60_ctneg = 0
                        , vljur60_lcred = 0
                        , vljuprej = 0
                        , vlrabono = vlrabono + vr_vlrabono
                    WHERE cdcooper = rw_crapass.cdcooper
                       AND nrdconta = rw_crapass.nrdconta
                        AND dtliquidacao IS NULL;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_dscritic := 'Erro ao atualizar registro na tabela TBCC_PREJUIZO: ' || SQLERRM;
                     -- Log de erro de execucao
                     vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || 
                                    ' Cooper: ' || rw_crapepr.cdcooper ||
                                    ' Conta: ' || rw_crapepr.nrdconta ||
                                    ' Contrato: ' || rw_crapepr.nrctremp || 
                                    ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;
       
                     RAISE vr_exc_proximo;
                 END;
                 END IF;
                     
                       IF vr_vllanacc >= rw_nracordo.vlbloqueado THEN
                         rw_nracordo.vlbloqueado := 0;
                       ELSE
                         rw_nracordo.vlbloqueado := rw_nracordo.vlbloqueado - 1;
                   END IF;
                     END IF;
                     
                     IF vr_vllanact > 0 THEN -- Abatimento em contratos (empréstimo, descto. de títulos, ...)
                       vr_vlrabono := vr_vllanact - rw_nracordo.vlbloqueado;
                       
                       -- Lança crédito do abono na conta corrente
                       EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper                          --> Cooperativa conectada
                                                     ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt --> Movimento atual
                                                     ,pr_cdagenci => rw_crapass.cdagenci                          --> Código da agência
                                                     ,pr_cdbccxlt => 100                                          --> Número do caixa
                                                     ,pr_cdoperad => vr_cdoperad                                  --> Código do Operador
                                                     ,pr_cdpactra => rw_crapass.cdagenci                          --> P.A. da transação
                                                     ,pr_nrdolote => 650001                                       --> Numero do Lote
                                                     ,pr_nrdconta => rw_crapass.nrdconta                          --> Número da conta
                                                     ,pr_cdhistor => 2181                                         --> Codigo historico
                                                     ,pr_vllanmto => vr_vlrabono                                  --> Valor do credito
                                                     ,pr_nrparepr => 0                                            --> Número do Acordo
                                                     ,pr_nrctremp => rw_nracordo.nracordo                         --> Número do contrato de empréstimo
                                                     ,pr_des_reto => vr_des_reto                                  --> Retorno OK / NOK
                                                     ,pr_tab_erro => vr_tab_erro);                                --> Tabela com possíves erros

                       -- Se ocorreu erro
                       IF vr_des_reto <> 'OK' THEN
                         -- Se possui algum erro na tabela de erros
                         IF vr_tab_erro.COUNT() > 0 THEN
                           vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                           vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                         ELSE
                           vr_cdcritic := 0;
                           vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
                         END IF;
                         -- Log de erro de execucao
                         vr_dscritic := 'Arquivo: ' || vr_nmarqtxt || ' - Erro na EMPR0001.pc_cria_lancamento_cc - ' || 
                                        ' Cooper: ' || rw_crapepr.cdcooper ||
                                        ' Conta: ' || rw_crapepr.nrdconta ||
                                        ' Contrato: ' || rw_crapepr.nrctremp || 
                                        ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                         RAISE vr_exc_proximo;
                       END IF;
                       -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
                       GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                       
                     END IF;
                   END IF;
                 END IF;

                 -- Atualiza a situação do acordo
                 BEGIN
                   UPDATE tbrecup_acordo
                      SET vlbloqueado = 0,
                          cdsituacao  = 2,
                          dtliquid    = vr_dtquitac
                    WHERE tbrecup_acordo.nracordo = vr_nracordo;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_dscritic := 'Erro ao atualizar registro na tabela TBRECUP_ACORDO: ' || SQLERRM;
                     -- Log de erro de execucao
                     vr_dscritic := 'Arquivo: ' || vr_nmarqtxt ||  
                                    ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

                     RAISE vr_exc_proximo;                                        
                 END;   

               
               EXCEPTION
                 WHEN vr_exc_proximo THEN
                   ROLLBACK;
                   pr_flgemail := TRUE;
                   
                   GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                   
                   -- Grava LOG
                   pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                        ,pr_dstiplog => 'E'
                                        ,pr_dscritic => vr_dscritic);
                 WHEN OTHERS THEN
                   ROLLBACK;
                   -- Grava LOG
                   pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                                        ,pr_dstiplog => 'E'
                                        ,pr_dscritic => 'Arquivo: ' || vr_nmarqtxt || ' ' || vr_dscritic || 
                                                        ' - Coop: ' || rw_crapepr.cdcooper || 
                                                        ' Conta: ' || rw_crapepr.nrdconta || 
                                                        ' Contrato: ' || rw_crapepr.nrctremp || 
                                                        ' Acordo: ' || vr_nracordo);
               END;
            
      -- Limpa nome do modulo logado - 15/08/2019 - PRB0041875
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na RECP0003.PC_IMP_ARQ_ACORDO_QUITADO: ' || SQLERRM;
      pr_flgemail := TRUE;
      -- Log de erro de execucao
      pc_controla_log_batch(pr_cdcooper => vr_cdcooper
                           ,pr_dstiplog => 'E'
                           ,pr_dscritic => pr_dscritic);

      ROLLBACK;

      --PRB0041875
      CECRED.pc_internal_exception (pr_cdcooper => 3);

      --Grava log
      pc_gera_log(pr_cdcooper      => 3,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);
      --
      
  END pc_imp_arq_acordo_quitado; 
  
  PROCEDURE pc_quita_conta_corrente( pr_cdcooper IN NUMBER,
                                     pr_nrdconta IN NUMBER,
                                     pr_nracordo IN NUMBER,
                                     pr_dscritic OUT VARCHAR2) IS
  
  
  -- Consulta PA e limites de credito do cooperado
  CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
          ,ass.vllimcre
          ,ass.cdcooper
          ,ass.nrdconta
          ,ass.inprejuz
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
      
  
  -- Tabela de Saldos
  vr_tab_saldos EXTR0001.typ_tab_saldos;  
  rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE; 
  vr_vlsddisp   NUMBER;
  vr_vlrabono   NUMBER;
  vr_index_saldo INTEGER;

  -- Variaveis de Erros  
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_erro EXCEPTION;
  vr_cdcritic crapcri.cdcritic%TYPE := 0;
  vr_dscritic crapcri.dscritic%TYPE := '';
  vr_des_reto  VARCHAR2(100);
  
  
      

BEGIN 
  
  -- Buscar o CRAPDAT da cooperativa
  OPEN BTCH0001.cr_crapdat(pr_cdcooper); 
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  
  -- Se não encontrar registro na CRAPDAT
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor
    CLOSE BTCH0001.cr_crapdat;    
    RETURN;
  END IF;        
  -- Fechar o cursor
  CLOSE BTCH0001.cr_crapdat;
  
  OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                 ,pr_nrdconta => pr_nrdconta);
  FETCH cr_crapass INTO rw_crapass;                     
  CLOSE cr_crapass;

  --Limpar tabela saldos
  vr_tab_saldos.DELETE;
                        
  -- Saldo  disponivel
  vr_vlsddisp := 0;

  --Obter Saldo do Dia
  EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crapass.cdcooper
                            ,pr_rw_crapdat => rw_crapdat
                            ,pr_cdagenci   => rw_crapass.cdagenci
                            ,pr_nrdcaixa   => 100
                            ,pr_cdoperad   => 1
                            ,pr_nrdconta   => rw_crapass.nrdconta
                            ,pr_vllimcre   => rw_crapass.vllimcre
                            ,pr_dtrefere   => rw_crapdat.dtmvtolt
                            ,pr_des_reto   => vr_des_reto
                            ,pr_tab_sald   => vr_tab_saldos
                            ,pr_tipo_busca => 'A'
                            ,pr_tab_erro   => vr_tab_erro);

  IF vr_des_reto <> 'OK' THEN
    vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
    vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;    
   RAISE vr_erro;
                           
  END IF;
  
  --Buscar Indice
  vr_index_saldo := vr_tab_saldos.FIRST;
  IF vr_index_saldo IS NOT NULL THEN
   -- Saldo Disponivel na conta corrente
   vr_vlsddisp := NVL(vr_tab_saldos(vr_index_saldo).vlsddisp, 0);
  END IF;
  
  IF vr_vlsddisp < 0 THEN    
    
    vr_vlrabono := vr_vlsddisp * -1;
    
    -- Lança crédito do abono na conta corrente
    EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper                          --> Cooperativa conectada
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt                           --> Movimento atual
                                 ,pr_cdagenci => rw_crapass.cdagenci                          --> Código da agência
                                 ,pr_cdbccxlt => 100                                          --> Número do caixa
                                 ,pr_cdoperad => 1                                            --> Código do Operador
                                 ,pr_cdpactra => rw_crapass.cdagenci                          --> P.A. da transação
                                 ,pr_nrdolote => 650001                                       --> Numero do Lote
                                 ,pr_nrdconta => rw_crapass.nrdconta                          --> Número da conta
                                 ,pr_cdhistor => 2181                                         --> Codigo historico
                                 ,pr_vllanmto => vr_vlrabono                                  --> Valor do credito
                                 ,pr_nrparepr => 0                                            --> Número do Acordo
                                 ,pr_nrctremp => pr_nracordo                         --> Número do contrato de empréstimo
                                 ,pr_des_reto => vr_des_reto                                  --> Retorno OK / NOK
                                 ,pr_tab_erro => vr_tab_erro);                                --> Tabela com possíves erros

    -- Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
     -- Se possui algum erro na tabela de erros
     IF vr_tab_erro.COUNT() > 0 THEN
       vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
       vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
     ELSE
       vr_cdcritic := 0;
       vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
     END IF;
     
     RAISE vr_erro;
                            
    END IF;  
  
  END IF;  
EXCEPTION
  WHEN vr_erro THEN
    pr_dscritic := vr_dscritic;
    ROLLBACK;
  
  WHEN OTHERS THEN  
    pr_dscritic := 'Erro ao realizar quitação :'||SQLERRM;
    ROLLBACK;  
  
END pc_quita_conta_corrente;
  

begin
  
  
  pc_quita_conta_corrente( pr_cdcooper => 7,
                           pr_nrdconta => 180793,
                           pr_nracordo => 293090,
                           pr_dscritic => :pr_dscritic);

  IF :pr_dscritic IS NOT NULL THEN
    raise_application_error(-20501,:pr_dscritic); 
  END IF; 
  
  pc_imp_arq_acordo_quitado(pr_flgemail => vr_flgemail 
                           ,pr_cdcritic => :pr_cdcritic 
                           ,pr_dscritic => :pr_dscritic); 
                           
  IF nvl(:pr_cdcritic,0) > 0 OR 
     TRIM(:pr_dscritic) IS NOT NULL THEN
    ROLLBACK; 
  ELSE
    COMMIT;
  END IF;     


end;
3
pr_flgemail
0
-5
pr_cdcritic
0
5
pr_dscritic
0
5
0
