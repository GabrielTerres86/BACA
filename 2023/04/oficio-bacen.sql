DECLARE  
  vr_indsobra   VARCHAR2(1000); 
  vr_inderro    VARCHAR2(1000) := 0; 
  
  vr_nrcursor   NUMBER;
  vr_nrretorn   NUMBER;
  vr_cursor     VARCHAR2(32000);

  vr_cdcooper   VARCHAR2(400);
  vr_nrdconta   VARCHAR2(400);
  vr_nrctremp   VARCHAR2(400);
  vr_nrparepr   VARCHAR2(400);
  vr_cdagenci   VARCHAR2(400);
  
  vr_cotas      NUMBER;
  vr_vlrsobra   NUMBER;
  vr_seqerro    NUMBER   := 0;
  vr_seq        NUMBER   := 0;  
  vr_cdcritic   INTEGER  := 0;
  vr_dscritic   VARCHAR2(4000); 
  vr_exc_saida  EXCEPTION;  

  vr_rootmicros   VARCHAR2(4000) := gene0001.fn_param_sistema('CRED', 1, 'ROOT_MICROS');
  vr_nmdireto     VARCHAR2(4000) := vr_rootmicros||'/cpd/bacas/RITM0295362';
  vr_arq_leitura  VARCHAR2(100) := '/RITM0295362.csv';  
  vr_ind_arquiv   utl_file.file_type;
  vr_ind_arquivr  utl_file.file_type;
  vr_linha        VARCHAR2(5000);
  vr_campo        GENE0002.typ_split;
  vr_texto_padrao VARCHAR2(200); 
  
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;   
  
  TYPE typ_reg_contrato IS RECORD(cdcooper  cecred.crapepr.cdcooper%TYPE,
                                  nrdconta  cecred.crapepr.nrdconta%TYPE,
                                  contratos VARCHAR2(4000),
                                  cotas     cecred.crapepr.vlemprst%TYPE);
  TYPE typ_tab_contrato IS TABLE OF typ_reg_contrato INDEX BY PLS_INTEGER;
    vr_tab_contrato typ_tab_contrato;
    
  TYPE typ_reg_contrato_erro IS RECORD(cdcooper  cecred.crapepr.cdcooper%TYPE,
                                       nrdconta  cecred.crapepr.nrdconta%TYPE,
                                       contrato  cecred.crapepr.nrctremp%TYPE);
  TYPE typ_tab_contrato_erro IS TABLE OF typ_reg_contrato_erro INDEX BY PLS_INTEGER;
    vr_tab_contrato_erro typ_tab_contrato_erro;              
                                         
  CURSOR cr_atraso_pp(pr_cdcooper  IN crappep.cdcooper%TYPE
                     ,pr_nrdconta  IN crappep.nrdconta%TYPE
                     ,pr_dtmvtolt  IN crappep.dtvencto%TYPE
                     ,pr_dtmvtoan  IN crappep.dtvencto%TYPE) IS
        SELECT nvl((select 1 from crapbpr
                 where  crapbpr.cdcooper = crappep.cdcooper
                 and    crapbpr.nrdconta = crappep.nrdconta
                 and    crapbpr.nrctrpro = crappep.nrctremp
                 and    grvm0001.fn_valida_categoria_alienavel(crapbpr.dscatbem) = 'S'
                 and    crapbpr.cdsitgrv not in (1,4,5)
                 and    rownum = 1),0) idgravame
           , nvl((select 1 from crapavl
                 where  crapavl.cdcooper = crappep.cdcooper
                 and    crapavl.nrdconta = crappep.nrdconta
                 and    rownum = 1),0) idavalista
           , crappep.cdcooper
           , crappep.nrdconta
           , crappep.nrctremp
           , crapass.cdagenci
           , crappep.dtvencto
           , crappep.vlsdvatu vlsdvpar
           , crappep.nrparepr
           , crappep.inliquid
           , crappep.rowid
        FROM crawepr
           , crapass
           , crappep
       WHERE crawepr.cdcooper (+) = crappep.cdcooper
         AND crawepr.nrdconta (+) = crappep.nrdconta
         AND crawepr.nrctremp (+) = crappep.nrctremp
         AND crapass.cdcooper = crappep.cdcooper
         AND crapass.nrdconta = crappep.nrdconta
         AND crapass.nrdconta = pr_nrdconta
         AND crappep.cdcooper = pr_cdcooper
         AND crappep.dtvencto < pr_dtmvtolt
         AND crappep.inprejuz = 0
         AND crawepr.flgpagto <> 2
         AND crappep.inliquid = 0
         AND EXISTS (SELECT 1 FROM crapepr where crapepr.cdcooper = crappep.cdcooper
                                             and crapepr.nrdconta = crappep.nrdconta
                                             and crapepr.nrctremp = crappep.nrctremp
                                             and crapepr.tpemprst = 1 --in (1,2)
                                             and crapepr.inliquid = 0
                                             and crapepr.inprejuz = 0)
       ORDER
          BY dtvencto
           , idgravame  desc
           , idavalista desc
           , vlsdvpar   desc
           , cdcooper
           , nrdconta
           , nrctremp
           , nrparepr;                                             
    rw_atraso_pp cr_atraso_pp%ROWTYPE;    
     
  CURSOR cr_sobra_antecipa_pp(pr_cdcooper crappep.cdcooper%TYPE
                             ,pr_nrdconta crappep.nrdconta%TYPE
                             ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT     crappep.cdcooper
               , crappep.nrdconta
               , crappep.nrctremp
               , crappep.nrparepr
               , crapass.cdagenci
               , crapepr.txmensal
               , NVL((SELECT COUNT(pep.nrparepr) FROM crappep pep
                                    WHERE pep.cdcooper = crappep.cdcooper
                                     AND pep.nrdconta = crappep.nrdconta
                                     AND pep.nrctremp = crappep.nrctremp
                                     AND pep.dtvencto >= pr_dtmvtolt
                                     AND pep.inprejuz = 0
                                     AND pep.inliquid = 0),0)qtd_parc_aberto 
    
        FROM crawepr
           , crapass
           , crappep
           , crapepr
       WHERE crawepr.cdcooper (+) = crappep.cdcooper
         AND crawepr.nrdconta (+) = crappep.nrdconta
         AND crawepr.nrctremp (+) = crappep.nrctremp
         AND crapass.cdcooper = crappep.cdcooper
         AND crapass.nrdconta = crappep.nrdconta
         AND crapass.nrdconta = pr_nrdconta         
         AND crappep.cdcooper = pr_cdcooper
         AND crappep.dtvencto >= pr_dtmvtolt
         AND crappep.inprejuz = 0
         AND crawepr.flgpagto <> 2
         AND crappep.inliquid = 0
         AND crapepr.cdcooper = crappep.cdcooper
         AND crapepr.nrdconta = crappep.nrdconta
         AND crapepr.nrctremp = crappep.nrctremp
         AND crapepr.tpemprst = 1 --in (1,2)
         AND crapepr.inliquid = 0
         AND crapepr.inprejuz = 0          
       ORDER BY crapepr.txmensal DESC
              , qtd_parc_aberto  DESC
              , crappep.cdcooper
              , crappep.nrdconta
              , crappep.nrctremp
              , crappep.nrparepr DESC;
                             
      rw_sobra_antecipa_pp cr_sobra_antecipa_pp%ROWTYPE;   
                
          
  PROCEDURE CRPS750_PAGAMENTO(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                             ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Número da conta
                             ,pr_nrctremp IN crapepr.nrctremp%type  --> contrato de emprestimo
                             ,pr_nrparepr IN crappep.nrparepr%TYPE --> numero da parcela
                             ,pr_cdagenci IN crapass.cdagenci%type --> código da agencia
                             ,pr_vlrcotas IN crapepr.vlsdeved%TYPE
                             ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                             ,pr_vlsobras OUT crapepr.vlsdeved%TYPE
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                             ,pr_dscritic OUT VARCHAR2) IS  
                            
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdcooper
             , crapcop.nmrescop
             , crapcop.nrtelura
             , crapcop.cdbcoctl
             , crapcop.cdagectl
             , crapcop.dsdircop
             , crapcop.nrctactl
             , crapcop.cdagedbb
             , crapcop.cdageitg
             , crapcop.nrdocnpj
          FROM crapcop crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                        ,pr_nrdconta IN crapepr.nrdconta%TYPE
                        ,pr_nrctremp IN crapepr.nrctremp%TYPE
                        ,pr_inliquid IN crapepr.inliquid%TYPE) IS
        SELECT crapepr.dtdpagto
             , crapepr.cdlcremp
             , crapepr.cdempres
             , crapepr.tpemprst
             , crapepr.tpdescto
             , crapepr.rowid
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp
           AND crapepr.inliquid = pr_inliquid
           AND crapepr.flgpagto <> 2 -- Boleto = 2
           AND crapepr.inprejuz = 0;

      rw_crapepr cr_crapepr%ROWTYPE;

      CURSOR cr_crappep (pr_cdcooper  IN crappep.cdcooper%TYPE
                        ,pr_nrdconta  IN crappep.nrdconta%TYPE
                        ,pr_nrctremp  IN crappep.nrctremp%TYPE
                        ,pr_nrparepr  IN crappep.nrparepr%TYPE) IS
        SELECT crappep.cdcooper
             , crappep.nrdconta
             , crappep.nrctremp
             , crappep.dtvencto
             , crappep.vlsdvpar
             , crappep.nrparepr
             , crappep.inliquid
             , crappep.rowid
             , crawepr.dtlibera
             , crawepr.tpemprst
             , crawepr.idcobope
             , crapass.vllimcre
             , crappep.vlparepr
             , crappep.vlmtapar 
             , crappep.vlmrapar 
             , crappep.vliofcpl 
          FROM crawepr
             , crapass
             , crappep
         WHERE crawepr.cdcooper (+) = crappep.cdcooper
           AND crawepr.nrdconta (+) = crappep.nrdconta
           AND crawepr.nrctremp (+) = crappep.nrctremp
           AND crapass.cdcooper = crappep.cdcooper
           AND crapass.nrdconta = crappep.nrdconta
           AND crappep.cdcooper = pr_cdcooper
           and crappep.nrdconta = pr_nrdconta
           and crappep.nrctremp = pr_nrctremp
           and crappep.nrparepr = pr_nrparepr
           AND crawepr.flgpagto <> 2 -- Boleto = 2
           AND crappep.inprejuz = 0;

      rw_crappep cr_crappep%ROWTYPE;
      CURSOR cr_craplcmC(pr_cdcooper IN craplcm.cdcooper%TYPE
                        ,pr_nrdconta IN craplcm.nrdconta%TYPE
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
        SELECT a.vllanmto
          FROM craplcm a
             , craphis b
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta
           AND a.dtmvtolt = pr_dtmvtolt
           AND a.cdhistor = b.cdhistor
           and b.cdcooper = a.cdcooper
           AND b.indebcre = 'C';
      rw_craplcmC cr_craplcmC%ROWTYPE;

      -- Cursor para verificar se existe algum boleto em aberto
      CURSOR cr_cde (pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrctremp IN crapcob.nrctremp%TYPE) IS
        SELECT cob.nrdocmto
          FROM crapcob cob
         WHERE cob.cdcooper = pr_cdcooper
           AND cob.incobran = 0
           AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN
                       (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                          FROM tbrecup_cobranca cde
                         WHERE cde.cdcooper = pr_cdcooper
                           AND cde.nrdconta = pr_nrdconta
                           AND cde.nrctremp = pr_nrctremp
                           AND cde.tpproduto = 0);
      rw_cde cr_cde%ROWTYPE;

      -- Cursor para verificar se existe algum boleto pago pendente de processamento
      CURSOR cr_ret (pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrctremp IN crapcob.nrctremp%TYPE
                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT cob.nrdocmto
          FROM crapcob cob, crapret ret
         WHERE cob.cdcooper = pr_cdcooper
           AND cob.incobran = 5
           AND cob.dtdpagto = pr_dtmvtolt
           AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN
                     (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                        FROM tbrecup_cobranca cde
                       WHERE cde.cdcooper = pr_cdcooper
                         AND cde.nrdconta = pr_nrdconta
                         AND cde.nrctremp = pr_nrctremp
                         AND cde.tpproduto = 0)
           AND ret.cdcooper = cob.cdcooper
           AND ret.nrdconta = cob.nrdconta
           AND ret.nrcnvcob = cob.nrcnvcob
           AND ret.nrdocmto = cob.nrdocmto
           AND ret.dtocorre = cob.dtdpagto
           AND ret.cdocorre = 6
           AND ret.flcredit = 0;
      rw_ret cr_ret%ROWTYPE;

      -- Consulta contratos ativos de acordos
      CURSOR cr_ctr_acordo(pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                          ,pr_nrdconta tbrecup_acordo.nrdconta%TYPE
                          ,pr_nrctremp tbrecup_acordo_contrato.nrctremp%TYPE) IS
        SELECT tbrecup_acordo_contrato.nracordo
             , tbrecup_acordo.cdcooper
             , tbrecup_acordo.nrdconta
             , tbrecup_acordo_contrato.nrctremp
          FROM tbrecup_acordo_contrato
          JOIN tbrecup_acordo
            ON tbrecup_acordo.nracordo   = tbrecup_acordo_contrato.nracordo
         WHERE tbrecup_acordo.cdsituacao = 1
           AND tbrecup_acordo_contrato.cdorigem IN (2,3)
           AND tbrecup_acordo.cdcooper = pr_cdcooper
           AND tbrecup_acordo.nrdconta = pr_nrdconta
           AND tbrecup_acordo_contrato.nrctremp = pr_nrctremp;
      rw_ctr_acordo cr_ctr_acordo%ROWTYPE;

    CURSOR cr_blqDebConsignado (pr_cdcooper in CRAPPCO.CDCOOPER%TYPE) IS
      SELECT DSCONTEU FROM CRAPPCO WHERE CDCOOPER = pr_cdcooper AND CDPARTAR = 162;
      rw_blqDebConsignado cr_blqDebConsignado%ROWTYPE;

    -- P437 - Consignado Busca o parametro "Dia Limite para Repasse"
    CURSOR cr_consig (pr_cdcooper IN tbcadast_empresa_consig.cdcooper%TYPE,
                      pr_cdempres IN tbcadast_empresa_consig.cdempres%TYPE) IS
      SELECT NVL(tec.nrdialimiterepasse,0) nrdialimiterepasse
             , NVL(tec.inddebitador,0) inddebitador
        FROM tbcadast_empresa_consig tec
       WHERE tec.cdcooper = pr_cdcooper
         AND tec.cdempres = pr_cdempres;
      -- Tabela de Memoria dos detalhes de emprestimo
      vr_tab_crawepr      EMPR0001.typ_tab_crawepr;
      --Tabela de Memoria de Mensagens Confirmadas
      vr_tab_msg_confirma EMPR0001.typ_tab_msg_confirma;
      --Tabela de Memoria de Erros
      vr_tab_erro         GENE0001.typ_tab_erro;
      -- Tabela de Memoria de Pagamentos de Parcela
      vr_tab_pgto_parcel  EMPR0001.typ_tab_pgto_parcel;
      -- Tabela de Memoria de Calculados
      vr_tab_calculado    EMPR0001.typ_tab_calculado;
      /* Contratos de acordo */
      TYPE typ_tab_acordo IS TABLE OF NUMBER(10) INDEX BY VARCHAR2(30);
      vr_tab_acordo       typ_tab_acordo;
      --Registro do tipo calendario
      rw_crapdat          BTCH0001.cr_crapdat%ROWTYPE;
      -- Constantes
      vr_cdprogra         VARCHAR2(50) := 'CRPS750_ANTECIP';
      -- Globais
      vr_rowid            ROWID;
      vr_rowidlog         ROWID;
      vr_rowiderro        ROWID;
      vr_rowidgeral       ROWID;
      vr_vlsomato_tmp     NUMBER;
      -- Variaveis Locais
      vr_vlrcotas         NUMBER;
      vr_vlapagar         NUMBER;
      vr_vlsomato         NUMBER;
      vr_vlresgat         NUMBER;
      vr_vljurmes         NUMBER;
      vr_dtcalcul         DATE;
      vr_cdoperad         VARCHAR2(1);
      vr_flgpagpa         BOOLEAN;
      vr_flgemdia         BOOLEAN;
      vr_ehmensal         BOOLEAN;
      vr_diarefju         INTEGER;
      vr_mesrefju         INTEGER;
      vr_anorefju         INTEGER;
      vr_flgpripr         BOOLEAN;
      vr_idacaojd         BOOLEAN := FALSE; -- Indicar Ação Judicial
      vr_blqconsig        BOOLEAN := FALSE; -- Bloqueio de debito emp. consignado
      vr_vlsomvld         NUMBER;


      -- Variaveis de Indices
      vr_cdindice         VARCHAR2(30) := ''; -- Indice da tabela de acordos
      vr_index_crawepr    VARCHAR2(30);
      vr_index_pgto_parcel PLS_INTEGER;

      -- Variaveis para retorno de erro
      vr_cdcritic         INTEGER:= 0;
      vr_dscritic         VARCHAR2(4000);
      vr_des_erro         VARCHAR2(3);

      -- Variaveis de Excecao
      vr_exc_final        EXCEPTION;
      vr_exc_saida        EXCEPTION;

      -- Parametro de bloqueio de resgate de valores em c/c
      vr_blqresg_cc       VARCHAR2(1);

      -- Parametro de contas que nao podem debitar os emprestimos
      vr_inBloqueioDebito number;

      -- Debitador Unico
      vr_flultexe     NUMBER;

      -- P437 - Consignado
      vr_nrdialimiterepasse tbcadast_empresa_consig.nrdialimiterepasse%TYPE;
      vr_inddebitador       tbcadast_empresa_consig.inddebitador%TYPE;

  ----------------------------------------------------------------------------------

      -- Procedure para limpar os dados das tabelas de memoria
      PROCEDURE pc_limpa_tabela IS
      BEGIN
        vr_tab_crawepr.DELETE;
        vr_tab_calculado.DELETE;
        vr_tab_msg_confirma.DELETE;
        vr_tab_pgto_parcel.DELETE;
      EXCEPTION
        WHEN OTHERS THEN
          -- Variavel de erro recebe erro ocorrido
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao limpar tabelas de memoria. Rotina pc_CRPS750.pc_limpa_tabela. '||sqlerrm;
          --Sair do programa
          RAISE vr_exc_saida;
      END pc_limpa_tabela;

      -- Verificar Pagamento
      PROCEDURE pc_verifica_pagamento(pr_vlsomato IN NUMBER          --Soma Total
                                     ,pr_inliquid IN INTEGER         --Indicador Liquidacao
                                     ,pr_flgpagpa OUT BOOLEAN        --Indicador Pago
                                     ,pr_des_reto OUT VARCHAR2) IS   -- Indicador Erro OK/NOK
      BEGIN

        /* Se parcela ja liquidada ou nao tem valor pra pagar, nao permitir pagamento */
        IF nvl(pr_vlsomato,0) <= 0 OR pr_inliquid = 1 THEN
          pr_flgpagpa := FALSE;
        ELSE
          pr_flgpagpa:= TRUE;
        END IF;

        -- RETORNAR OK
        pr_des_reto:= 'OK';

      EXCEPTION
        WHEN OTHERS THEN
          pr_des_reto:= 'NOK';
      END pc_verifica_pagamento;

  BEGIN
      --TOTAL COTAS PARA DEBITOS
      pr_vlsobras:= pr_vlrcotas;
      vr_vlrcotas:= pr_vlrcotas;
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      -- Verifica se a cooperativa esta cadastrada
      OPEN  cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Verifica se a data esta cadastrada
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Setar Operador
      vr_cdoperad:= '1';

      -- Limpar Tabela
      pc_limpa_tabela;
      
      -- Carregar Contratos de Acordos
      FOR rw_ctr_acordo IN cr_ctr_acordo(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctremp => pr_nrctremp) LOOP
      
        vr_cdindice := LPAD(rw_ctr_acordo.cdcooper,10,'0') || LPAD(rw_ctr_acordo.nrdconta,10,'0') ||
                       LPAD(rw_ctr_acordo.nrctremp,10,'0');
      
        vr_tab_acordo(vr_cdindice) := rw_ctr_acordo.nracordo;   
      END LOOP;                            

      /* Todas as parcelas nao liquidadas que estao para serem pagas em dia ou estao em atraso */
      FOR rw_crappep IN cr_crappep (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctremp => pr_nrctremp
                                   ,pr_nrparepr => pr_nrparepr) LOOP
                                        
        /* Atribuir se operacao esta em dia ou atraso */
        vr_flgemdia := rw_crappep.dtvencto > rw_crapdat.dtmvtoan;

        vr_tab_crawepr.DELETE;

        vr_vlresgat := 0;

        IF rw_crappep.dtlibera IS NOT NULL THEN
          vr_index_crawepr := lpad(rw_crappep.cdcooper,10,'0')||
                              lpad(rw_crappep.nrdconta,10,'0')||
                              lpad(rw_crappep.nrctremp,10,'0');
          vr_tab_crawepr(vr_index_crawepr).dtlibera:= rw_crappep.dtlibera;
          vr_tab_crawepr(vr_index_crawepr).tpemprst:= rw_crappep.tpemprst;
          vr_tab_crawepr(vr_index_crawepr).idcobope:= rw_crappep.idcobope;
        END IF;

        -- Selecionar Informacoes Emprestimo
        OPEN cr_crapepr (pr_cdcooper => rw_crappep.cdcooper
                        ,pr_nrdconta => rw_crappep.nrdconta
                        ,pr_nrctremp => rw_crappep.nrctremp
                        ,pr_inliquid => 0);

        FETCH cr_crapepr INTO rw_crapepr;
        IF cr_crapepr%NOTFOUND THEN
          CLOSE cr_crapepr;
          --Proxima Parcela
          vr_dscritic := 'Erro Informacoes Emprestimo';
          pr_dscritic := vr_dscritic;
          CONTINUE;
        END IF;
        CLOSE cr_crapepr;

        -- P437 - Consignado,
        -- busca o dia limite de repasse
        vr_inddebitador := 0;

        FOR rw_consig IN cr_consig (pr_cdcooper => rw_crappep.cdcooper,
                                    pr_cdempres => rw_crapepr.cdempres) LOOP
          vr_nrdialimiterepasse:= rw_consig.nrdialimiterepasse;
          vr_inddebitador := 1;--rw_consig.inddebitador; --##VALIDAR EM AMBIENTE TEST
        END LOOP;

        /* 229243 Verifica se possui movimento de credito no dia */
        IF rw_crapdat.inproces = 1 AND vr_flgpripr THEN
          -- Selecionar Lançamentos de credito da conta
          OPEN  cr_craplcmC(pr_cdcooper => rw_crappep.cdcooper
                           ,pr_nrdconta => rw_crappep.nrdconta
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
          FETCH cr_craplcmC INTO rw_craplcmC;
          IF cr_craplcmC%NOTFOUND THEN
            CLOSE cr_craplcmC;
            -- Proxima Parcela
            vr_dscritic := 'Erro Lançamentos de credito da conta';
            pr_dscritic := vr_dscritic;
            CONTINUE;
          END IF;
          CLOSE cr_craplcmC;
        END IF;

        /* Saldo devedor da parcela */
        vr_vlapagar     := rw_crappep.vlsdvpar;
        vr_vlsomato     := 0;
        
        dbms_output.put_line('Saldo devedor da parcela: ' || vr_vlapagar);

        -- Setar o flag para FALSE, negando existencia de acao judicial, antes da verificação
        vr_idacaojd := FALSE;
        vr_inBloqueioDebito := 0;
        credito.verificarBloqueioDebito(pr_cdcooper => pr_cdcooper,
                                        pr_nrdconta => rw_crappep.nrdconta,
                                        pr_nrctremp => rw_crappep.nrctremp,
                                        pr_bloqueio => vr_inBloqueioDebito,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);
        IF vr_dscritic is not null or vr_cdcritic > 0 THEN
           pr_dscritic := vr_dscritic;
           CONTINUE;
        END IF;
        -- Trava para nao cobrar as parcelas desta conta pelo motivo de uma acao judicial
        IF vr_inBloqueioDebito = 1 THEN
          -- Indica que existe uma acao judicial
          vr_idacaojd := TRUE;
        END IF;
        -- Se há ação judicial, deve indicar o flag de coberturação de operação como zero, para que não seja feito
        -- resgate, pois na sequencia o valor do saldo será zerado
        IF vr_idacaojd THEN
          vr_dscritic := 'Bloqueio Judicial para Conta/Contrato.';
          pr_dscritic := vr_dscritic;
          -- Verifica se há registros
          IF vr_tab_crawepr.count() > 0 THEN
            -- Ler o primeiro indice
            vr_index_crawepr := vr_tab_crawepr.FIRST();
            -- Percorrer todos os registros
            LOOP
              -- Indica com zero para não realizar resgate
              vr_tab_crawepr(vr_index_crawepr).idcobope := 0;
              -- Sair após ultimo registro
              EXIT WHEN vr_index_crawepr = vr_tab_crawepr.LAST();
              -- Buscar próximo indice
              vr_index_crawepr := vr_tab_crawepr.NEXT(vr_index_crawepr);
            END LOOP;
          END IF;
        END IF;

        OPEN  cr_blqDebConsignado(pr_cdcooper => 3);
        FETCH cr_blqDebConsignado INTO rw_blqDebConsignado;
        CLOSE cr_blqDebConsignado;

        vr_blqconsig := FALSE;
        IF rw_crapepr.tpdescto = 2 AND NVL(rw_blqDebConsignado.DSCONTEU,0) = 1 THEN  -- Consignado e o parametro estiver para bloquear;
          vr_blqconsig := TRUE;
          vr_dscritic := 'Bloqueio Judicial para Conta/Contrato Consig';
          pr_dscritic := vr_dscritic;
        END IF;

        -- Validar Pagamentos
        EMPR0001.pc_valida_pagamentos_geral(pr_cdcooper    => pr_cdcooper                --> Codigo Cooperativa
                                           ,pr_cdagenci    => pr_cdagenci                --> Codigo Agencia
                                           ,pr_nrdcaixa    => 0                          --> Codigo Caixa
                                           ,pr_cdoperad    => vr_cdoperad                --> Operador
                                           ,pr_nmdatela    => vr_cdprogra                --> Nome da Tela
                                           ,pr_idorigem    => 7 /*Batch*/                --> Identificador origem
                                           ,pr_nrdconta    => rw_crappep.nrdconta        --> Numero da Conta
                                           ,pr_nrctremp    => rw_crappep.nrctremp        --> Numero Contrato
                                           ,pr_idseqttl    => 1                          --> Sequencial Titular
                                           ,pr_dtmvtolt    => rw_crapdat.dtmvtolt        --> Data Emprestimo
                                           ,pr_flgerlog    => TRUE                       --> Erro no Log
                                           ,pr_dtrefere    => rw_crapdat.dtmvtolt        --> Data Referencia
                                           ,pr_vlapagar    => vr_vlapagar                --> Valor Pagar
                                           ,pr_tab_crawepr => vr_tab_crawepr             --> Tabela com Contas e Contratos
                                           ,pr_efetresg    => 'S'                        --> Efetuar o resgate de cobertura de aplicação
                                           ,pr_vlsomato    => vr_vlsomato                --> Soma Total
                                           ,pr_vlresgat    => vr_vlresgat                --> Soma
                                           ,pr_tab_erro    => vr_tab_erro                --> tabela Erros
                                           ,pr_des_reto    => vr_des_erro                --> Indicador OK/NOK
                                           ,pr_tab_msg_confirma => vr_tab_msg_confirma); --> Tabela Confirmacao
        IF vr_des_erro <> 'OK' THEN
          IF vr_tab_erro.count > 0 THEN
            vr_cdcritic:= 0;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            pr_dscritic := vr_dscritic; 
            CONTINUE;
          END IF;
        END IF;
        
        --Não vou utilizar valor resgate (revisitar assunto)
        vr_vlresgat := 0;

        --vr_vlsomato_tmp := nvl(vr_vlsomato,0); -- apenas para log
        vr_vlsomato_tmp := nvl(vr_vlrcotas,0);
        
        vr_vlresgat := nvl(vr_vlresgat,0);
        
        vr_vlsomato := nvl(vr_vlrcotas,0);
        --vr_vlsomato := nvl(vr_vlsomato,0);
        
        vr_vlapagar := nvl(vr_vlapagar,0);
        vr_vlsomvld := 0;

        -- Se há trava devido a existencia de bloqueio por ação judicial
        IF vr_idacaojd THEN
          vr_vlsomato_tmp := 0;
          vr_vlsomato     := 0;
        END IF;

        -- nao debitar consignado quando tiver bloqueado
        IF vr_blqconsig THEN
          vr_vlsomato_tmp := 0;
          vr_vlsomato     := 0;
        END IF;

        IF vr_flgemdia THEN /* PARCELA EM DIA */
          /* Parcela em dia */
            --Criar savepoint
            SAVEPOINT sav_trans_750;

            -- Verificar Pagamento
            pc_verifica_pagamento (pr_vlsomato => vr_vlsomato --> Soma Total + Soma Resgate
                                  ,pr_inliquid => rw_crappep.inliquid   --> Indicador Liquidacao
                                  ,pr_flgpagpa => vr_flgpagpa           --> Pagamento OK
                                  ,pr_des_reto => vr_des_erro);         --> Indicador Erro OK/NOK

            --15/08/2018 (Debitador Único)
            --Só atualiza Qtde de Meses Decorridos na última execução do dia
            IF vr_flultexe = 1 THEN
              --Atualizar quantidade meses decorridos
              BEGIN
                UPDATE crapepr
                  SET    crapepr.qtmesdec = nvl(crapepr.qtmesdec,0) + 1
                  WHERE  crapepr.rowid = rw_crapepr.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  cecred.pc_internal_exception;
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao atualizar crapepr. '||SQLERRM;
                  pr_dscritic := vr_dscritic;
                  -- Levantar Excecao
                  RAISE vr_exc_saida;
              END;
            END IF;

            -- Se ocorreu erro
            IF vr_des_erro <> 'OK' THEN
              --Proximo Registro
              vr_dscritic := 'Erro pc_verifica_pagamento';
              pr_dscritic := vr_dscritic;
              CONTINUE;
            END IF;

            -- P437 - Consignado - Para a operacao de consignado  não haverá pagamento em dia
                                                            -- TESTAR CONSIGNADO ATRASADO/ANTECIPADO E COM COOPERADO DESLIGADO
            /*IF rw_crapepr.tpdescto = 2 AND vr_inddebitador = 0 THEN
              vr_dscritic := 'Para a operacao de consignado  não haverá pagamento em dia';
              pr_dscritic := vr_dscritic;
              CONTINUE;
            END IF; -- crapepr.tpdescto = 2*/

            /* verificar se existe boleto de contrato em aberto e se pode lancar juros remuneratorios no contrato */
            /* 1º) verificar se o parametro está bloqueado para realizar busca de boleto em aberto */
            IF vr_blqresg_cc = 'S' THEN

              -- inicializar rows de cursores
              rw_cde := NULL;
              rw_ret := NULL;

              /* 2º se permitir, verificar se possui boletos em aberto */
              OPEN  cr_cde(pr_cdcooper => rw_crappep.cdcooper
                          ,pr_nrdconta => rw_crappep.nrdconta
                          ,pr_nrctremp => rw_crappep.nrctremp);
              FETCH cr_cde INTO rw_cde;
              -- Fechar o cursor
              CLOSE cr_cde;

              /* 3º se existir boleto de contrato em aberto, lancar juros */
              IF nvl(rw_cde.nrdocmto,0) > 0 THEN
                IF vr_flgpagpa THEN
                  vr_flgpagpa := FALSE;
                END IF;
              ELSE
                /* 4º cursor para verificar se existe boleto pago pendente de processamento */
                OPEN  cr_ret(pr_cdcooper => rw_crappep.cdcooper
                            ,pr_nrdconta => rw_crappep.nrdconta
                            ,pr_nrctremp => rw_crappep.nrctremp
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
                FETCH cr_ret INTO rw_ret;
                CLOSE cr_ret;

                /* 6º se existir boleto de contrato pago pendente de processamento, lancar juros */
                IF nvl(rw_ret.nrdocmto,0) > 0 THEN
                  IF vr_flgpagpa THEN
                    vr_flgpagpa := FALSE;
                  END IF;
                END IF;
              END IF;  -- IF nvl(rw_cde.nrdocmto,0) > 0
            END IF; -- IF vr_blqresg_cc = 'S'

            -- Verifica acordos
            vr_cdindice := LPAD(pr_cdcooper,10,'0') || LPAD(rw_crappep.nrdconta,10,'0') ||
                           LPAD(rw_crappep.nrctremp,10,'0');

            IF vr_tab_acordo.EXISTS(vr_cdindice) THEN
              vr_flgpagpa := FALSE;
            END IF;

            /* Sem valor suficiente para pagar parcela ou parcela ja liquidada */
            IF NOT vr_flgpagpa THEN
              -- buscar ultimo dia Util do mes
              vr_dtcalcul:= GENE0005.fn_valida_dia_util (pr_cdcooper => pr_cdcooper
                                                        ,pr_dtmvtolt => last_day(rw_crappep.dtvencto)
                                                        ,pr_tipo => 'A'
                                                        ,pr_excultdia => TRUE);
              -- Determinar se eh mensal
              vr_ehmensal:= rw_crappep.dtvencto > vr_dtcalcul;

              /* 229243 Juros não devem ser lançados no processamento on line */
              IF vr_flultexe = 1 THEN
                --Lancar Juro Contrato
          /* SE FOR CONSIGNADO NAO REALIZA O LANCAMENTO DE JUROS */
          IF NOT ( rw_crapepr.tpdescto = 2 AND rw_crapepr.tpemprst = 1 ) THEN
            EMPR0001.pc_lanca_juro_contrato(pr_cdcooper    => pr_cdcooper         --> Codigo Cooperativa
                           ,pr_cdagenci    => pr_cdagenci         --> Codigo Agencia
                           ,pr_nrdcaixa    => 0                   --> Codigo Caixa
                           ,pr_nrdconta    => rw_crappep.nrdconta --> Numero da Conta
                           ,pr_nrctremp    => rw_crappep.nrctremp --> Numero Contrato
                           ,pr_dtmvtolt    => rw_crapdat.dtmvtolt --> Data Emprestimo
                           ,pr_cdoperad    => vr_cdoperad         --> Operador
                           ,pr_cdpactra    => pr_cdagenci         --> Posto Atendimento
                           ,pr_flnormal    => TRUE                --> Lancamento Normal
                           ,pr_dtvencto    => rw_crappep.dtvencto --> Data vencimento
                           ,pr_ehmensal    => vr_ehmensal         --> Indicador Mensal
                           ,pr_dtdpagto    => rw_crapepr.dtdpagto --> Data pagamento
                           ,pr_tab_crawepr => vr_tab_crawepr      --> Tabela com Contas e Contratos
                           ,pr_cdorigem    => 7                   -- 7) Batch
                           ,pr_vljurmes    => vr_vljurmes         --> Valor Juros no Mes
                           ,pr_diarefju    => vr_diarefju         --> Dia Referencia Juros
                           ,pr_mesrefju    => vr_mesrefju         --> Mes Referencia Juros
                           ,pr_anorefju    => vr_anorefju         --> Ano Referencia Juros
                           ,pr_des_reto    => vr_des_erro         --> Retorno OK/NOK
                           ,pr_tab_erro    => vr_tab_erro);       --> tabela Erros

            -- Se ocorreu erro
            IF vr_des_erro <> 'OK' THEN
            -- Se tem erro
            IF vr_tab_erro.count > 0 THEN
              vr_cdcritic := 0;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              pr_dscritic := vr_dscritic;              
              -- Rollback até savepoint
              ROLLBACK TO SAVEPOINT sav_trans_750;
              -- Proximo registro
              CONTINUE;
            END IF;
            END IF;
          END IF;
              END IF; -- IF rw_crapdat.inproces <> 1

              -- Possui Juros
              IF nvl(vr_vljurmes,0) > 0 THEN
                /* Atualiza saldo devedor e juros */
                BEGIN
                  UPDATE crapepr
                     SET crapepr.diarefju = nvl(vr_diarefju,0)
                       , crapepr.mesrefju = nvl(vr_mesrefju,0)
                       , crapepr.anorefju = nvl(vr_anorefju,0)
                       , crapepr.vlsdeved = nvl(crapepr.vlsdeved,0) + nvl(vr_vljurmes,0)
                       , crapepr.vljuratu = nvl(crapepr.vljuratu,0) + nvl(vr_vljurmes,0)
                       , crapepr.vljuracu = nvl(crapepr.vljuracu,0) + nvl(vr_vljurmes,0)
                   WHERE crapepr.rowid = rw_crapepr.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    cecred.pc_internal_exception;
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao atualizar crapepr. '||SQLERRM;
                    pr_dscritic := vr_dscritic;
                    -- Levantar Excecao
                    RAISE vr_exc_saida;
                END;
              END IF; -- IF nvl(vr_vljurmes,0) > 0

              -- Proximo Registro
              vr_dscritic := 'Sem valor suficiente para pagar parcela ou parcela ja liquidada';
              pr_dscritic := vr_dscritic;
              CONTINUE;

            END IF; --NOT vr_flgpagpa

            /* Verifica se tem uma parcela anterior nao liquida e ja vencida */
            EMPR0001.pc_verifica_parcel_anteriores (pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                                   ,pr_nrdconta => rw_crappep.nrdconta --> Número da conta
                                                   ,pr_nrctremp => rw_crappep.nrctremp --> Número do contrato de empréstimo
                                                   ,pr_nrparepr => rw_crappep.nrparepr --> Número parcelas empréstimo
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                                   ,pr_des_reto => vr_des_erro         --> Retorno OK / NOK
                                                   ,pr_dscritic => vr_dscritic);       --> Descricao Erro
            -- Se ocorreu erro
            IF vr_des_erro <> 'OK' THEN
              -- Proximo Registro
              pr_dscritic := vr_dscritic;
              CONTINUE;
            END IF;

            

            /* Se saldo disp. maior que sald. devedor, entao pega saldo devedor */
            IF nvl(vr_vlsomato,0) > nvl(vr_vlapagar,0) THEN
              -- Soma total recebe valor a pagar
              vr_vlsomato:= vr_vlapagar;             
            END IF;

            IF rw_crapepr.tpdescto = 2 AND vr_inddebitador = 1 THEN
              EMPR0020.pc_gera_pagto_deb_uni_consig(pr_cdcooper => pr_cdcooper  --> Cooperativa conectada
                                                   ,pr_cdagenci => pr_cdagenci  --> Código da agência
                                                   ,pr_nrdcaixa => 0            --> Número do caixa
                                                   ,pr_cdoperad => vr_cdoperad  --> Código do Operador
                                                   ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                                                   ,pr_idorigem => 7 /*Batch*/  --> Id do módulo de sistema
                                                   ,pr_cdpactra => pr_cdagenci  --> P.A. da transação
                                                   ,pr_nrdconta => rw_crappep.nrdconta --> Número da conta
                                                   ,pr_idseqttl => 1 /* Titular */     --> Seq titula
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                                   ,pr_flgerlog => 'N'                 --> Indicador S/N para geração de log
                                                   ,pr_nrctremp => rw_crappep.nrctremp --> Número do contrato de empréstimo
                                                   ,pr_nrparepr => rw_crappep.nrparepr --> Número parcelas empréstimo
                                                   ,pr_vlparpag => vr_vlsomato         --> valor que esta sendo pago
                                                   ,pr_vlsdvpar => rw_crappep.vlsdvpar    --> Valor da parcela emprestimo à pagar
                                                   ,pr_dtvencto => rw_crappep.dtvencto --> Vencimento da parcela
                                                   ,pr_cdlcremp => rw_crapepr.cdlcremp --> Linha de crédito
                                                   ,pr_tppagmto => 'D'                 --> Tipo Pagamento - "D" -Em Dia, "A"- Em Atraso
                                                   ,pr_vlrmulta => rw_crappep.vlmtapar --> Valor da multa
                                                   ,pr_vlatraso => rw_crappep.vlmrapar --> Valor Juros de mora
                                                   ,pr_vliofcpl => rw_crappep.vliofcpl --> Valor do IOF complementar de atraso
                                                   ,pr_des_reto => vr_des_erro   --> Retorno OK / NOK
                                                   ,pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros
           ELSE
             -- Efetivar Pagamento Normal da Parcela
             EMPR0001.pc_efetiva_pagto_parcela(pr_cdcooper => pr_cdcooper          --> Codigo Cooperativa
                                              ,pr_cdagenci => pr_cdagenci          --> Codigo Agencia
                                              ,pr_nrdcaixa => 0                    --> Codigo Caixa
                                              ,pr_cdoperad => vr_cdoperad          --> Operador
                                              ,pr_nmdatela => pr_nmdatela          --> Nome da Tela
                                              ,pr_idorigem => 7 /*Batch*/          --> Identificador origem
                                              ,pr_cdpactra => pr_cdagenci /*cdpactra*/ --> Posto Atendimento
                                              ,pr_nrdconta => rw_crappep.nrdconta  --> Numero da Conta
                                              ,pr_idseqttl => 1 /* Tit. */         --> Sequencial Titular
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data Emprestimo
                                              ,pr_flgerlog => 'S'                  --> Erro no Log
                                              ,pr_nrctremp => rw_crappep.nrctremp  --> Numero Contrato
                                              ,pr_nrparepr => rw_crappep.nrparepr  --> Numero parcela
                                              ,pr_vlparepr => vr_vlsomato          --> Valor da parcela
                                              ,pr_tab_crawepr => vr_tab_crawepr    --> Tabela com Contas e Contratos
                                              ,pr_tab_erro => vr_tab_erro          --> tabela Erros
                                              ,pr_des_reto => vr_des_erro);        --> Indicador OK/NOK
           END IF;

            -- Se ocorreu erro
            IF vr_des_erro <> 'OK' THEN
              -- Se tem erro
              IF vr_tab_erro.count > 0 THEN
                vr_cdcritic:= 0;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                pr_dscritic := vr_dscritic;
                -- Desfazer transacao
                ROLLBACK TO SAVEPOINT sav_trans_750;

                -- Proximo registro
                CONTINUE;
              END IF;
            END IF;

        ELSE /* PARCELA VENCIDA */

          -- P437- Consignado
          -- Para parcela de consignado em atraso só debita
          -- se existir cadastrado o dia limite para repasse
          -- O débito deve acontecer no dia seguinte do parametro
          IF rw_crapepr.tpdescto = 2 THEN
             IF vr_nrdialimiterepasse = 0 then-- não possui cadastro
                --Proximo Registro
                 vr_vlsomato := 0;
             ELSIF to_char(rw_crapdat.dtmvtolt,'DD') < (vr_nrdialimiterepasse) THEN
                --Proximo Registro
                 vr_vlsomato := 0;
             END IF;

             -- P437 - Conignado - para operação de consignado não irá efetuar pagamentos na execução noturna
             IF rw_crapdat.inproces > 1 then -- Processo Noturno (batch)
                vr_dscritic := 'para operacao de consignado nao ira efetuar pagamentos na execucao noturna';
                pr_dscritic := vr_dscritic;
                CONTINUE;
             END IF;
          END IF;


          /* verificar se existe boleto de contrato em aberto e se pode debitar do cooperado */
          /* 1º) verificar se o parametro está bloqueado para realizar busca de boleto em aberto */
          IF vr_blqresg_cc = 'S' THEN

            -- inicializar rows de cursores
            rw_cde := NULL;
            rw_ret := NULL;

            /* 2º se permitir, verificar se possui boletos em aberto */
            OPEN  cr_cde(pr_cdcooper => rw_crappep.cdcooper
                        ,pr_nrdconta => rw_crappep.nrdconta
                        ,pr_nrctremp => rw_crappep.nrctremp);
            FETCH cr_cde INTO rw_cde;
            CLOSE cr_cde;

            /* 3º se existir boleto de contrato em aberto, nao debitar */
            IF nvl(rw_cde.nrdocmto,0) > 0 THEN
              vr_vlsomato := 0;
            ELSE
              /* 4º cursor para verificar se existe boleto pago pendente de processamento, nao debitar */
              OPEN  cr_ret(pr_cdcooper => rw_crappep.cdcooper
                          ,pr_nrdconta => rw_crappep.nrdconta
                          ,pr_nrctremp => rw_crappep.nrctremp
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
              FETCH cr_ret INTO rw_ret;
              CLOSE cr_ret;

              /* 6º se existir boleto de contrato pago pendente de processamento, nao debitar */
              IF nvl(rw_ret.nrdocmto,0) > 0 THEN
                vr_vlsomato := 0;
              END IF;
            END IF; -- IF nvl(rw_cde.nrdocmto,0) > 0
          END IF; -- IF vr_blqresg_cc = 'S'

          -- verifica acordos
          vr_cdindice := LPAD(pr_cdcooper,10,'0')        ||
                         LPAD(rw_crappep.nrdconta,10,'0')||
                         LPAD(rw_crappep.nrctremp,10,'0');

          IF vr_tab_acordo.EXISTS(vr_cdindice) THEN
            vr_vlsomato := 0;
          END IF;

          -- Se o saldo mais o valor de resgate são menores ou igual a zero
          IF (vr_vlsomato) <= 0 THEN
            vr_dscritic := 'Pulou Parcela erro Se o saldo mais o valor de resgate são menores ou igual a zero';
            pr_dscritic := vr_dscritic;
            -- Proximo registro
            CONTINUE;
          END IF;

          -- P437 - Consignado - Não verificar parcelas anteriores
          -- para o consignado
          IF rw_crapepr.tpdescto <> 2 THEN
          /* Verifica se tem uma parcela anterior nao liquida e ja vencida */
          EMPR0001.pc_verifica_parcel_anteriores(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                                ,pr_nrdconta => rw_crappep.nrdconta --> Número da conta
                                                ,pr_nrctremp => rw_crappep.nrctremp --> Número do contrato de empréstimo
                                                ,pr_nrparepr => rw_crappep.nrparepr --> Número parcelas empréstimo
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                                ,pr_des_reto => vr_des_erro         --> Retorno OK / NOK
                                                ,pr_dscritic => vr_dscritic);       --> Descricao Erro
          -- Se ocorreu erro
          IF vr_des_erro <> 'OK' THEN
            -- Proximo Registro
            pr_dscritic := vr_dscritic;
            CONTINUE;
            END IF;
          END IF;

          -- Criar savepoint
          SAVEPOINT sav_trans_750;

          -- Buscar pagamentos Parcela
          EMPR0001.pc_busca_pgto_parcelas(pr_cdcooper => pr_cdcooper                --> Cooperativa conectada
                                         ,pr_cdagenci => pr_cdagenci                --> Código da agência
                                         ,pr_nrdcaixa => 0                          --> Número do caixa
                                         ,pr_cdoperad => vr_cdoperad                --> Código do Operador
                                         ,pr_nmdatela => pr_nmdatela                --> Nome da tela
                                         ,pr_idorigem => 7 /*Batch*/                --> Id do módulo de sistema
                                         ,pr_nrdconta => rw_crappep.nrdconta        --> Número da conta
                                         ,pr_idseqttl => 1                          --> Seq titula
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt        --> Movimento atual
                                         ,pr_flgerlog => 'N'                        --> Indicador S/N para geração de log
                                         ,pr_nrctremp => rw_crappep.nrctremp        --> Número do contrato de empréstimo
                                         ,pr_dtmvtoan => rw_crapdat.dtmvtoan        --> Data anterior
                                         ,pr_nrparepr => rw_crappep.nrparepr        --> Número parcelas empréstimo
                                         ,pr_des_reto => vr_des_erro                --> Retorno OK / NOK
                                         ,pr_tab_erro => vr_tab_erro                --> Tabela com possíves erros
                                         ,pr_tab_pgto_parcel => vr_tab_pgto_parcel  --> Tabela com registros de pagamentos
                                         ,pr_tab_calculado   => vr_tab_calculado);  --> Tabela com totais calculados
          -- Se ocorreu erro
          IF vr_des_erro <> 'OK' THEN
            -- Se tem erro
            IF vr_tab_erro.count > 0 THEN
              vr_cdcritic := 0;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              pr_dscritic := vr_dscritic;
              -- Desfazer transacao
              ROLLBACK TO SAVEPOINT sav_trans_750;

              --Proximo registro
              CONTINUE;
            END IF;
          END IF;

          -- Se retornou dados Buscar primeiro registro
          vr_index_pgto_parcel := vr_tab_pgto_parcel.FIRST;

          IF vr_index_pgto_parcel IS NOT NULL THEN
            /* Se valor disponivel a pagar eh maior do que tem que pagar , entao liquida parcela */
            IF nvl(vr_vlsomato,0) > nvl(vr_tab_pgto_parcel(vr_index_pgto_parcel).vlatrpag,0) THEN
              vr_vlsomato:= nvl(vr_tab_pgto_parcel(vr_index_pgto_parcel).vlatrpag,0);
            END IF;
          END IF; -- IF vr_index_pgto_parcel IS NOT NULL

          -- P437 - Consignado
          -- Quando for consignado chama a rotina que irá criar o evento SOA
          -- e os lançamentos em c/c de multa, juros, IOF de atraso e da parcela em atraso
          IF rw_crapepr.tpdescto = 2 THEN
             EMPR0020.pc_gera_pagto_deb_uni_consig(pr_cdcooper => pr_cdcooper  --> Cooperativa conectada
                                                  ,pr_cdagenci => pr_cdagenci  --> Código da agência
                                                  ,pr_nrdcaixa => 0            --> Número do caixa
                                                  ,pr_cdoperad => vr_cdoperad  --> Código do Operador
                                                  ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                                                  ,pr_idorigem => 7 /*Batch*/  --> Id do módulo de sistema
                                                  ,pr_cdpactra => pr_cdagenci  --> P.A. da transação
                                                  ,pr_nrdconta => rw_crappep.nrdconta --> Número da conta
                                                  ,pr_idseqttl => 1 /* Titular */     --> Seq titula
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                                  ,pr_flgerlog => 'N'                 --> Indicador S/N para geração de log
                                                  ,pr_nrctremp => rw_crappep.nrctremp --> Número do contrato de empréstimo
                                                  ,pr_nrparepr => rw_crappep.nrparepr --> Número parcelas empréstimo
                                                  ,pr_vlparpag => vr_vlsomato         --> valor que esta sendo pago
                                                  ,pr_vlsdvpar => nvl(vr_tab_pgto_parcel(vr_index_pgto_parcel).vlatrpag,0)    --> Valor da parcela emprestimo à pagar
                                                  ,pr_dtvencto => rw_crappep.dtvencto --> Vencimento da parcela
                                                  ,pr_cdlcremp => rw_crapepr.cdlcremp --> Linha de crédito
                                                  ,pr_tppagmto => 'A'                 --> Tipo Pagamento - "D" -Em Dia, "A"- Em Atraso
                                                  ,pr_vlrmulta => rw_crappep.vlmtapar --> Valor da multa
                                                  ,pr_vlatraso => rw_crappep.vlmrapar --> Valor Juros de mora
                                                  ,pr_vliofcpl => rw_crappep.vliofcpl --> Valor do IOF complementar de atraso
                                                  ,pr_des_reto => vr_des_erro   --> Retorno OK / NOK
                                                  ,pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros
          ELSE
            -- Efetivar Pagamento da Parcela Atrasada
            EMPR0001.pc_efetiva_pagto_atr_parcel(pr_cdcooper => pr_cdcooper           --> Cooperativa conectada
                                                ,pr_cdagenci => pr_cdagenci           --> Código da agência
                                                ,pr_nrdcaixa => 0                     --> Número do caixa
                                                ,pr_cdoperad => vr_cdoperad           --> Código do Operador
                                                ,pr_nmdatela => pr_nmdatela           --> Nome da tela
                                                ,pr_idorigem => 7 /*Batch*/           --> Id do módulo de sistema
                                                ,pr_cdpactra => pr_cdagenci /*cdpactra*/ --> P.A. da transação
                                                ,pr_nrdconta => rw_crappep.nrdconta   --> Número da conta
                                                ,pr_idseqttl => 1 /* Titular */       --> Seq titula
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Movimento atual
                                                ,pr_flgerlog => 'N'                   --> Indicador S/N para geração de log
                                                ,pr_nrctremp => rw_crappep.nrctremp   --> Número do contrato de empréstimo
                                                ,pr_nrparepr => rw_crappep.nrparepr   --> Número parcelas empréstimo
                                                ,pr_vlpagpar => vr_vlsomato           --> Soma Total
                                                ,pr_tab_crawepr => vr_tab_crawepr     --> Tabela com Contas e Contratos
                                                ,pr_des_reto => vr_des_erro           --> Retorno OK / NOK
                                                ,pr_tab_erro => vr_tab_erro);         --> Tabela com possíves erros
          END IF;

          /* Se deu erro eh porque nao tinha dinheiro minimo suficiente */
          --Se ocorreu erro
          IF vr_des_erro <> 'OK' THEN
            -- Desfazer transacao
            ROLLBACK TO SAVEPOINT sav_trans_750;
                                  
            vr_dscritic := vr_dscritic||' '||vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            pr_dscritic := vr_dscritic;                     
            --Proximo registro
            CONTINUE;
          END IF;

        END IF; -- PARCELA EM DIA / PARCELA VENCIDA

        -- Salvar informacoes no banco de dados parcela a parcela
        --COMMIT; --##REMOVER POIS COMMIT VAI SER VIA BACA
        
        pr_vlsobras := pr_vlsobras - vr_vlsomato;
        dbms_output.put_line('Valor Pago: ' || vr_vlsomato);

      END LOOP; /*  Fim do FOR EACH e da transacao -- Leitura dos emprestimos  */

      -- Limpar as tabelas de memória
      pc_limpa_tabela;

    EXCEPTION
      /*WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas codigo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descricao da critica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          dbms_output.put_line('ERRO geral: '||vr_dscritic);   
        END IF;
        -- Limpar parametros
        pr_cdcritic:= 0;
        pr_dscritic:= NULL;
        -- Efetuar commit pois gravaremos o que foi processado ate entao
        --COMMIT;--##REMOVER COMMIT POIS PRECISA DO CREDITO.*/

      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas codigo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descricao
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Devolvemos codigo e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        -- Efetuar rollback
        --ROLLBACK;

      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        -- Efetuar rollback
        --ROLLBACK;
  END CRPS750_PAGAMENTO;
    
BEGIN
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto,
                           pr_nmarquiv => vr_arq_leitura,
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_ind_arquiv,
                           pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,
                               pr_des_text => vr_linha);
  LOOP
    BEGIN
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,
                                   pr_des_text => vr_linha);
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;
    END;
    
    vr_campo    := GENE0002.fn_quebra_string(pr_string  => vr_linha,
                                             pr_delimit => ';');
                                             
    vr_indsobra := GENE0002.fn_char_para_number(vr_campo(1))||GENE0002.fn_char_para_number(vr_campo(2));                                                 
  
    vr_tab_contrato(vr_indsobra).cdcooper  := GENE0002.fn_char_para_number(vr_campo(1));
    vr_tab_contrato(vr_indsobra).nrdconta  := GENE0002.fn_char_para_number(vr_campo(2));   
    IF TRIM(vr_tab_contrato(vr_indsobra).contratos) IS NOT NULL THEN
      vr_tab_contrato(vr_indsobra).contratos := vr_tab_contrato(vr_indsobra).contratos||' , '||vr_campo(3);
    ELSE 
      vr_tab_contrato(vr_indsobra).contratos := vr_campo(3);
    END IF;    
    vr_tab_contrato(vr_indsobra).cotas := NVL(vr_tab_contrato(vr_indsobra).cotas,0) + NVL(GENE0002.fn_char_para_number(vr_campo(4)),0);  
  END LOOP; 
  
  vr_indsobra := vr_tab_contrato.FIRST;
  
  WHILE vr_indsobra IS NOT NULL LOOP
              
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_tab_contrato(vr_indsobra).cdcooper);   
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      vr_cdcritic:= 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;
   
    --Atribui o VALOR de COTAS
    vr_cotas := vr_tab_contrato(vr_indsobra).cotas;
    --Zera Sequencia
    vr_seq   := 0;    
    vr_seqerro := vr_seqerro+1;
    
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('Inicio Analise na COOP/CONTA: ' || vr_tab_contrato(vr_indsobra).cdcooper ||' / '||vr_tab_contrato(vr_indsobra).nrdconta); 
    
    
    
    IF vr_cotas > 0 THEN      
      FOR rw_atraso_pp IN cr_atraso_pp (pr_cdcooper => vr_tab_contrato(vr_indsobra).cdcooper
                                       ,pr_nrdconta => vr_tab_contrato(vr_indsobra).nrdconta
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_dtmvtoan => rw_crapdat.dtmvtoan) LOOP
        
        vr_inderro := vr_seqerro||rw_atraso_pp.nrctremp;
                                      
        IF vr_tab_contrato_erro.exists(vr_inderro) THEN 
          IF vr_tab_contrato_erro(vr_inderro).cdcooper = rw_atraso_pp.cdcooper AND
             vr_tab_contrato_erro(vr_inderro).nrdconta = rw_atraso_pp.nrdconta AND
             vr_tab_contrato_erro(vr_inderro).contrato = rw_atraso_pp.nrctremp THEN
            CONTINUE; 
          END IF;
        END IF; 
                                                                                                                                                    
        dbms_output.put_line('');
        dbms_output.put_line('ATRASO');
        dbms_output.put_line('Contrato: '|| rw_atraso_pp.nrctremp ||' Parcela: ' || rw_atraso_pp.nrparepr);                                
        dbms_output.put_line('Valor Cotas LANÇADA para pagar ATRASO: ' || vr_cotas);
          
        vr_seq := vr_seq+1;
        dbms_output.put_line('SEQUENCIA DE PAGAMENTOS: ' || vr_seq);  
                                                                                                                                                                                           
        CRPS750_PAGAMENTO(pr_cdcooper => rw_atraso_pp.cdcooper
                         ,pr_nrdconta => rw_atraso_pp.nrdconta
                         ,pr_nrctremp => rw_atraso_pp.nrctremp
                         ,pr_nrparepr => rw_atraso_pp.nrparepr
                         ,pr_cdagenci => rw_atraso_pp.cdagenci
                         ,pr_vlrcotas => vr_cotas
                         ,pr_nmdatela => 'CRPS750_BACEN'
                         ,pr_vlsobras => vr_vlrsobra
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
                                          
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          dbms_output.put_line('Erro principal CRPS750_PAGAMENTO (Atraso): ' || vr_dscritic); 
                             
          vr_tab_contrato_erro(vr_inderro).cdcooper := rw_atraso_pp.cdcooper;
          vr_tab_contrato_erro(vr_inderro).nrdconta := rw_atraso_pp.nrdconta;
          vr_tab_contrato_erro(vr_inderro).contrato := rw_atraso_pp.nrctremp;          
          CONTINUE;
        END IF;
                
        vr_cotas := vr_vlrsobra;
        dbms_output.put_line('Sobrou de COTAS: ' || vr_cotas);
                
        IF vr_cotas <= 0 THEN
          dbms_output.put_line('');
          dbms_output.put_line('Sem saldo para continuar pagamentos de ATRASO CONTRATO: ' || vr_cotas);
          EXIT;
        END IF;                                                                       
      END LOOP;
    END IF;        
    
    
    
    IF vr_cotas > 0 THEN                             
      vr_cursor :=     'SELECT crappep.cdcooper
                             , crappep.nrdconta
                             , crappep.nrctremp
                             , crappep.nrparepr
                             , crapass.cdagenci
                             , crapepr.txmensal
                             , NVL((SELECT COUNT(pep.nrparepr) FROM crappep pep
                                                  WHERE pep.cdcooper = crappep.cdcooper
                                                   AND pep.nrdconta = crappep.nrdconta
                                                   AND pep.nrctremp = crappep.nrctremp
                                                   AND pep.dtvencto >= '''||TO_DATE(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||''' 
                                                   AND pep.inprejuz = 0
                                                   AND pep.inliquid = 0),0)qtd_parc_aberto 
                  
                              FROM crawepr
                                 , crapass
                                 , crappep
                                 , crapepr
                             WHERE crawepr.cdcooper (+) = crappep.cdcooper
                               AND crawepr.nrdconta (+) = crappep.nrdconta
                               AND crawepr.nrctremp (+) = crappep.nrctremp
                               AND crapass.cdcooper = crappep.cdcooper
                               AND crapass.nrdconta = crappep.nrdconta
                               AND crapass.nrdconta = '||vr_tab_contrato(vr_indsobra).nrdconta||'
                               AND crappep.nrctremp IN ('||vr_tab_contrato(vr_indsobra).contratos||')
                               AND crappep.cdcooper = '||vr_tab_contrato(vr_indsobra).cdcooper||'
                               AND crappep.dtvencto >= '''||TO_DATE(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||'''  
                               AND crappep.inprejuz = 0
                               AND crawepr.flgpagto <> 2
                               AND crappep.inliquid = 0
                               AND crapepr.cdcooper = crappep.cdcooper
                               AND crapepr.nrdconta = crappep.nrdconta
                               AND crapepr.nrctremp = crappep.nrctremp
                               AND crapepr.tpemprst = 1 --in (1,2)
                               AND crapepr.inliquid = 0
                               AND crapepr.inprejuz = 0          
                               ORDER BY crapepr.txmensal DESC
                                      , qtd_parc_aberto  DESC
                                      , crappep.cdcooper
                                      , crappep.nrdconta
                                      , crappep.nrctremp
                                      , crappep.nrparepr DESC'; 
                                       
                                       
      vr_nrcursor := dbms_sql.open_cursor;
      dbms_sql.parse(vr_nrcursor, vr_cursor, 1);

      dbms_sql.define_column(vr_nrcursor, 1, vr_cdcooper ,4000);
      dbms_sql.define_column(vr_nrcursor, 2, vr_nrdconta ,4000);
      dbms_sql.define_column(vr_nrcursor, 3, vr_nrctremp ,4000);
      dbms_sql.define_column(vr_nrcursor, 4, vr_nrparepr ,4000);
      dbms_sql.define_column(vr_nrcursor, 5, vr_cdagenci ,4000);      
        
      vr_nrretorn := dbms_sql.execute(vr_nrcursor);
            
      LOOP 
        vr_nrretorn := dbms_sql.fetch_rows(vr_nrcursor);
        IF vr_nrretorn = 0 THEN
          IF dbms_sql.is_open(vr_nrcursor) THEN
            dbms_sql.close_cursor(vr_nrcursor);
          END IF;
          EXIT;
        ELSE 

          dbms_sql.column_value(vr_nrcursor, 1, vr_cdcooper);
          dbms_sql.column_value(vr_nrcursor, 2, vr_nrdconta);
          dbms_sql.column_value(vr_nrcursor, 3, vr_nrctremp);
          dbms_sql.column_value(vr_nrcursor, 4, vr_nrparepr);
          dbms_sql.column_value(vr_nrcursor, 5, vr_cdagenci); 
          
          vr_cdcooper := GENE0002.fn_char_para_number(vr_cdcooper);    
          vr_nrdconta := GENE0002.fn_char_para_number(vr_nrdconta);
          vr_nrctremp := GENE0002.fn_char_para_number(vr_nrctremp);
          vr_nrparepr := GENE0002.fn_char_para_number(vr_nrparepr);
          vr_cdagenci := GENE0002.fn_char_para_number(vr_cdagenci);
           
          vr_inderro := vr_seqerro||vr_nrctremp;
          
          IF vr_tab_contrato_erro.exists(vr_inderro) THEN
            IF vr_tab_contrato_erro(vr_inderro).cdcooper = vr_cdcooper AND
               vr_tab_contrato_erro(vr_inderro).nrdconta = vr_nrdconta AND
               vr_tab_contrato_erro(vr_inderro).contrato = vr_nrctremp THEN
              CONTINUE; 
            END IF;                                                                                                                                                 
          END IF;
                           
          dbms_output.put_line('');   
          dbms_output.put_line('CONTRATO PLANILHA'); 
          dbms_output.put_line('Contrato: '|| vr_nrctremp ||' Parcela: ' || vr_nrparepr);                                
          dbms_output.put_line('Valor Cotas LANÇADA para pagar CONTRATO: ' || vr_cotas);  
          
          vr_seq := vr_seq+1;
          dbms_output.put_line('SEQUENCIA DE PAGAMENTOS: ' || vr_seq);
                                                                                                                                                                                                                                                                    
          CRPS750_PAGAMENTO(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => vr_nrdconta
                           ,pr_nrctremp => vr_nrctremp
                           ,pr_nrparepr => vr_nrparepr
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_vlrcotas => vr_cotas
                           ,pr_nmdatela => 'CRPS750_BACEN'
                           ,pr_vlsobras => vr_vlrsobra
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
                                                  
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            dbms_output.put_line('ERRO PRINCIPAL CRPS750_PAGAMENTO (ORIGINADOR): ' || vr_dscritic);
                        
            vr_tab_contrato_erro(vr_inderro).cdcooper := vr_cdcooper;
            vr_tab_contrato_erro(vr_inderro).nrdconta := vr_nrdconta;
            vr_tab_contrato_erro(vr_inderro).contrato := vr_nrctremp;                    
            CONTINUE;
          END IF;
                       
          vr_cotas := vr_vlrsobra;
          dbms_output.put_line('Sobrou de COTAS: ' || vr_cotas);
                        
          IF vr_cotas <= 0 THEN
            dbms_output.put_line('');
            dbms_output.put_line('Sem saldo para continuar pagamentos de ANTECIPACAO CONTRATO PLANILHA: ' || vr_cotas);
            EXIT;
          END IF;                            
        END IF;                                                                         
      END LOOP;
    END IF;  
        
    
    
    IF vr_cotas > 0 THEN  
      FOR rw_sobra_antecipa_pp IN cr_sobra_antecipa_pp (pr_cdcooper => vr_tab_contrato(vr_indsobra).cdcooper
                                                       ,pr_nrdconta => vr_tab_contrato(vr_indsobra).nrdconta
                                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
                                                       
        vr_inderro := vr_seqerro||rw_sobra_antecipa_pp.nrctremp;        
        IF vr_tab_contrato_erro.exists(vr_inderro) THEN                                           
          IF vr_tab_contrato_erro(vr_inderro).cdcooper = rw_sobra_antecipa_pp.cdcooper AND
             vr_tab_contrato_erro(vr_inderro).nrdconta = rw_sobra_antecipa_pp.nrdconta AND
             vr_tab_contrato_erro(vr_inderro).contrato = rw_sobra_antecipa_pp.nrctremp THEN
            CONTINUE; 
          END IF;                                                                                                                                      
        END IF;
                                                                                                                                                                     
        dbms_output.put_line('');  
        dbms_output.put_line('CONTRATO ANTECIPADO GERAL');
        dbms_output.put_line('Contrato: '|| rw_sobra_antecipa_pp.nrctremp ||' Parcela: ' || rw_sobra_antecipa_pp.nrparepr);                                
        dbms_output.put_line('Valor Cotas LANÇADA para pagar ANTECIPADO GERAL: ' || vr_cotas);
          
        vr_seq := vr_seq+1;
        dbms_output.put_line('SEQUENCIA DE PAGAMENTOS: ' || vr_seq);
                                                                                                                                                                                                               
        CRPS750_PAGAMENTO(pr_cdcooper => rw_sobra_antecipa_pp.cdcooper
                        ,pr_nrdconta => rw_sobra_antecipa_pp.nrdconta
                        ,pr_nrctremp => rw_sobra_antecipa_pp.nrctremp
                        ,pr_nrparepr => rw_sobra_antecipa_pp.nrparepr
                        ,pr_cdagenci => rw_sobra_antecipa_pp.cdagenci
                        ,pr_vlrcotas => vr_cotas
                        ,pr_nmdatela => 'CRPS750_BACEN'
                        ,pr_vlsobras => vr_vlrsobra
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic);
                                        
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          dbms_output.put_line('ERRO PRINCIPAL CRPS750_PAGAMENTO (GERAL): ' || vr_dscritic);
          
          vr_tab_contrato_erro(vr_inderro).cdcooper := rw_sobra_antecipa_pp.cdcooper;
          vr_tab_contrato_erro(vr_inderro).nrdconta := rw_sobra_antecipa_pp.nrdconta;
          vr_tab_contrato_erro(vr_inderro).contrato := rw_sobra_antecipa_pp.nrctremp;              
          CONTINUE;
        END IF;
            
        vr_cotas := vr_vlrsobra;
            
        dbms_output.put_line('Sobrou de COTAS: ' || vr_cotas); 
              
        IF vr_cotas <= 0 THEN
          dbms_output.put_line('');
          dbms_output.put_line('Sem saldo para continuar pagamentos de ANTECIPACAO GERAL: '|| vr_cotas);
          EXIT;
        END IF;                                                                                                             
      END LOOP;
    END IF;
      
  dbms_output.put_line('Sobrou de COTAS geral: ' || vr_cotas);  
  vr_indsobra := vr_tab_contrato.NEXT(vr_indsobra);  
  END LOOP;        
--COMMIT;  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line('ERRO BACA: ' || SQLERRM ||vr_dscritic);                                                             
END;
