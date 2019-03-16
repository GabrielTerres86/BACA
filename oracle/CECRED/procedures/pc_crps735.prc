CREATE OR REPLACE PROCEDURE CECRED.pc_crps735(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                             ,pr_cdagenci  IN crapbdt.cdagenci%TYPE DEFAULT NULL --> Agencia
                                             ,pr_idparale IN INTEGER DEFAULT 0          --> Id da transacao de paralelismo
                                             ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                             ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps735
     Sistema : Crédito - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Lazari (GFT)
     Data    : Junho/2018                     Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Realiza o pagamento de títulos vencidos através das regras de raspada de conta corrente.

     Alteracoes:
               07/08/2018 - Alterado para paralelismo - Luis Fernando (GFT)
               05/09/2018 - Alterado para nao incluir titulos em acordo na raspada - Cassia de Oliveira (GFT)
               17/09/2018 - Adicionada raspada para borderos em prejuizo - Luis Fernando (GFT)
               27/09/2018 - Alterado para incluir titulos em acordo cancelado na raspada - Cassia de Oliveira (GFT)
			   10/11/2018 - Correção no cdorigem - Cássia de Oliveira (GFT)
               26/11/2018 - Correção para fazer raspaga de titulos vencido em feriados e pagos parcialmente no proximo dia util - Cássia de Oliveira (GFT)
               30/11/2018 - Alterada regra para se a cobranca estiver paga (mesmo parcialmente) deverá fazer a raspada na conta do cooperado (Luis Fernando - GFT)
  ............................................................................ */
  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS735';
    vr_qtdjobs  NUMBER;
    vr_idparale INTEGER;
    vr_jobname  VARCHAR2(30); 
    vr_dsplsql  VARCHAR2(4000); 
    vr_des_erro VARCHAR2(32000);

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    ------------------------------- CURSORES ---------------------------------
    -- Cursor generico de calendario
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
    
    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0
                     ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE DEFAULT 0) IS
     SELECT crapass.cdcooper
           ,crapass.nrdconta
           ,crapass.inpessoa
           ,crapass.vllimcre
           ,crapass.nmprimtl
           ,crapass.nrcpfcgc
           ,crapass.dtdemiss
           ,crapass.inadimpl
       FROM crapass
      WHERE crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = DECODE(pr_nrdconta,0,crapass.nrdconta,pr_nrdconta)
        AND crapass.nrcpfcgc = DECODE(pr_nrcpfcgc,0,crapass.nrcpfcgc,pr_nrcpfcgc);
    rw_crapass cr_crapass%ROWTYPE;
    

    -- Cursor para trazer as agencias para o paralelismo
    CURSOR cr_crapage IS 
      SELECT  crapage.cdagenci
             ,crapage.nmresage
      FROM  crapage
       where crapage.cdcooper = pr_cdcooper
         AND crapage.cdagenci <> 999
    ;
    --  Busca todos os títulos liberados que estão vencidos e pendentes de pagamento
    CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                     ,pr_cdagenci IN crapbdt.cdagenci%TYPE) IS
      SELECT craptdb.ROWID,
             craptdb.cdcooper,
             craptdb.nrdconta,
             craptdb.nrborder,
             craptdb.cdbandoc,
             craptdb.dtvencto,
             craptdb.dtlibbdt,
             craptdb.nrcnvcob,
             craptdb.nrdctabb,
             craptdb.nrdocmto,
             craptdb.nrinssac,
             craptdb.vltitulo,
             craptdb.vlsldtit,
             craptdb.vliofcpl,
             craptdb.vlpagiof,
             craptdb.vlmtatit,
             craptdb.vlpagmta,
             craptdb.vlmratit,
             craptdb.vlpagmra,
             craptdb.vlliquid,
             crapbdt.inprejuz,
             cob.incobran
        FROM crapbdt, craptdb
  INNER JOIN crapcob cob
          ON cob.cdbandoc = craptdb.cdbandoc
         AND cob.nrdctabb = craptdb.nrdctabb
         AND cob.nrcnvcob = craptdb.nrcnvcob
         AND cob.nrdocmto = craptdb.nrdocmto   
         AND cob.cdcooper = craptdb.cdcooper
         AND cob.nrdconta = craptdb.nrdconta
   LEFT JOIN tbdsct_titulo_cyber -- busca codigo de desconto de titulos
          ON tbdsct_titulo_cyber.cdcooper = craptdb.cdcooper
         AND tbdsct_titulo_cyber.nrdconta = craptdb.nrdconta
         AND tbdsct_titulo_cyber.nrborder = craptdb.nrborder
         AND tbdsct_titulo_cyber.nrtitulo = craptdb.nrtitulo
       WHERE craptdb.cdcooper =  crapbdt.cdcooper
         AND craptdb.nrdconta =  crapbdt.nrdconta
         AND craptdb.nrborder =  crapbdt.nrborder
         AND craptdb.cdcooper =  pr_cdcooper
         AND craptdb.dtvencto <= pr_dtmvtolt
         AND craptdb.insittit =  4 -- liberado
         AND crapbdt.cdagenci = nvl(pr_cdagenci,crapbdt.cdagenci)
         AND crapbdt.flverbor =  1 -- bordero liberado na nova versão
         AND crapbdt.inprejuz = 0
         AND NOT EXISTS(SELECT 1 
                          FROM tbrecup_acordo_contrato -- busca titulos em acordo ativo ou quitado
                     LEFT JOIN tbrecup_acordo
                            ON tbrecup_acordo.nracordo = tbrecup_acordo_contrato.nracordo
                         WHERE tbdsct_titulo_cyber.nrctrdsc = tbrecup_acordo_contrato.nrctremp  
                           AND tbdsct_titulo_cyber.cdcooper = tbrecup_acordo.cdcooper 
                           AND tbdsct_titulo_cyber.nrdconta = tbrecup_acordo.nrdconta 
                           AND tbrecup_acordo_contrato.nrgrupo = 1 
                           AND tbrecup_acordo_contrato.cdorigem = 4
                           AND tbrecup_acordo.cdsituacao <> 3)
       ORDER BY dtvencto, vlsldtit desc; -- define a ordem de prioridade da raspada
    
    CURSOR cr_crapbdt_prejuz (pr_cdcooper crapbdt.cdcooper%TYPE,pr_cdagenci crapbdt.cdagenci%TYPE) IS 
      SELECT
        bdt.nrborder
        ,bdt.cdcooper
        ,bdt.nrdconta
        ,SUM(tdb.vlsdprej
          + (tdb.vlttjmpr - tdb.vlpgjmpr)
          + (tdb.vlttmupr - tdb.vlpgmupr)
          + (tdb.vljraprj - tdb.vlpgjrpr)
          + (tdb.vliofprj - tdb.vliofppr)
                                ) AS vlsldatu -- Saldo atualizado
      FROM crapbdt bdt
        INNER JOIN craptdb tdb ON bdt.cdcooper = tdb.cdcooper AND bdt.nrdconta = tdb.nrdconta AND bdt.nrborder = tdb.nrborder
        LEFT JOIN tbdsct_titulo_cyber -- busca codigo de desconto de titulos
               ON tdb.cdcooper = tbdsct_titulo_cyber.cdcooper 
              AND tdb.nrdconta = tbdsct_titulo_cyber.nrdconta
              AND tdb.nrborder = tbdsct_titulo_cyber.nrborder
              AND tdb.nrtitulo = tbdsct_titulo_cyber.nrtitulo
      WHERE bdt.cdcooper = pr_cdcooper
        AND bdt.inprejuz = 1
        AND bdt.dtliqprj IS NULL 
        AND bdt.cdagenci = nvl(pr_cdagenci,bdt.cdagenci)
        AND bdt.flverbor =  1 -- bordero liberado na nova versão
        AND bdt.insitbdt =  3
        AND tdb.insittit = 4
        AND NOT EXISTS(SELECT 1 
                          FROM tbrecup_acordo_contrato -- busca titulos em acordo ativo ou quitado
                     LEFT JOIN tbrecup_acordo
                            ON tbrecup_acordo.nracordo = tbrecup_acordo_contrato.nracordo
                         WHERE tbdsct_titulo_cyber.nrctrdsc = tbrecup_acordo_contrato.nrctremp  
                           AND tbdsct_titulo_cyber.cdcooper = tbrecup_acordo.cdcooper 
                           AND tbdsct_titulo_cyber.nrdconta = tbrecup_acordo.nrdconta 
                           AND tbrecup_acordo_contrato.nrgrupo = 1 
                           AND tbrecup_acordo_contrato.cdorigem = 4
                           AND tbrecup_acordo.cdsituacao <> 3)
      GROUP BY 
        bdt.nrborder,bdt.cdcooper,bdt.nrdconta,bdt.dtprejuz
      ORDER BY  bdt.dtprejuz;
    rw_crapbdt_prejuz cr_crapbdt_prejuz%ROWTYPE;
    
    -- Cursor para verificar se existe algum boleto em aberto (emitido pela tela COBTIT)
    CURSOR cr_cde (pr_cdcooper IN crapcob.cdcooper%TYPE
                  ,pr_nrdconta IN crapcob.nrdconta%TYPE
                  ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
         SELECT cob.nrdocmto
           FROM crapcob cob
          WHERE cob.cdcooper = pr_cdcooper
            AND cob.incobran = 0
            AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrdocmto) IN
                (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrboleto
                   FROM tbrecup_cobranca cde
                  WHERE cde.cdcooper  = pr_cdcooper
                    AND cde.nrdconta  = pr_nrdconta
                    AND cde.nrctremp  = pr_nrborder
                    AND cde.tpproduto = 3); -- desconto de titulo
    rw_cde cr_cde%ROWTYPE;

    -- Cursor para verificar se existe algum boleto pago pendente de processamento (emitido pela tela COBTIT)
    CURSOR cr_ret (pr_cdcooper IN crapcob.cdcooper%TYPE
                  ,pr_nrdconta IN crapcob.nrdconta%TYPE
                  ,pr_nrborder IN crapbdt.nrborder%TYPE
                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT cob.nrdocmto
          FROM crapcob cob, crapret ret
         WHERE cob.cdcooper = pr_cdcooper
           AND cob.incobran = 5
           AND cob.dtdpagto = pr_dtmvtolt
           AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrdocmto) IN
               (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrboleto
                  FROM tbrecup_cobranca cde
                 WHERE cde.cdcooper  = pr_cdcooper
                   AND cde.nrdconta  = pr_nrdconta
                   AND cde.nrctremp  = pr_nrborder
                   AND cde.tpproduto = 3) -- Desconto de título
           AND ret.cdcooper = cob.cdcooper
           AND ret.nrdconta = cob.nrdconta
           AND ret.nrcnvcob = cob.nrcnvcob
           AND ret.nrdocmto = cob.nrdocmto
           AND ret.dtocorre = cob.dtdpagto
           AND ret.cdocorre = 6
           AND ret.flcredit = 0;
    rw_ret cr_ret%ROWTYPE;
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

    

    ------------------------------- VARIAVEIS -------------------------------
    
    vr_dsctajud      crapprm.dsvlrprm%TYPE; -- Armazena as conta que possuem alguma ação judicial
    vr_dtultdia      DATE;                  -- Variavel para armazenar o ultimo dia util do ano
    vr_tab_saldos EXTR0001.typ_tab_saldos;

    -- Variavel dos Indices
    vr_index_saldo PLS_INTEGER;
    
    -- Variaveis tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_des_reto VARCHAR2(10);
    vr_tab_erro GENE0001.typ_tab_erro;
    vr_vlsldisp NUMBER;  
    
    -- Parametro de bloqueio de resgate de valores em c/c
    vr_blqresg_cc       VARCHAR2(1);
    
    
    -- Retorno da #TAB052
    vr_tab_dados_dsctit    cecred.dsct0002.typ_tab_dados_dsctit;
    vr_tab_cecred_dsctit   cecred.dsct0002.typ_tab_cecred_dsctit;
    
    vr_vlpagmto NUMBER; -- valor sendo pago de bordero em prejuizo 
    vr_liquidou INTEGER;
  BEGIN
    -- ainda não comecou a rodar o paralelismo
    IF (nvl(pr_idparale,0)=0) THEN
      vr_idparale := gene0001.fn_gera_id_paralelo;
      -- Buscar quantidade parametrizada de Jobs
      vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper --> Código da coopertiva
                                                   ,vr_cdprogra --> Código do programa
                                                   );
      IF (vr_qtdjobs = 0) THEN
        vr_dscritic := 'Nao foi possivel encontrar o parametro de quantidade de Jobs';
        RAISE vr_exc_erro;
      END IF;
      FOR reg_crapage in cr_crapage LOOP
        vr_jobname := vr_cdprogra ||'_'|| reg_crapage.cdagenci || '$';
        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                    ,pr_idprogra => LPAD(reg_crapage.cdagenci,3,'0') --> Utiliza a agência como id programa
                                    ,pr_des_erro => vr_des_erro);
        -- Testar saida com erro
        if vr_des_erro is not null then
          vr_dscritic := vr_des_erro;
          raise vr_exc_erro;
        END if;
        vr_dsplsql := 'declare'            ||chr(13)||
                      ' wpr_stprogra  binary_integer; '||chr(13)||
                      ' wpr_infimsol  binary_integer; '||chr(13)||
                      ' wpr_cdcritic  number(5); '     ||chr(13)||
                      ' wpr_dscritic  varchar2(4000); '||chr(13)||
                      ' begin '||chr(13)||
                      '   cecred.pc_crps735('||pr_cdcooper||','||chr(13)||
                                               reg_crapage.cdagenci||','||chr(13)||
                                               vr_idparale||','||chr(13)||
                                               'wpr_stprogra,' ||chr(13)||
                                               'wpr_infimsol,' ||chr(13)||
                                               'wpr_cdcritic,' ||chr(13)||
                                               'wpr_dscritic'  ||chr(13)||
                                               ');'||chr(13)||
                      'end;';
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                                ,pr_cdprogra => vr_cdprogra  --> Código do programa
                                ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                ,pr_jobname  => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro => vr_des_erro);    

          -- Testar saida com erro
          IF vr_des_erro IS NOT NULL THEN
            vr_dscritic := vr_des_erro;
            RAISE vr_exc_erro;
          END IF;
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => vr_qtdjobs
                                   ,pr_des_erro => vr_des_erro);
      END LOOP;
      --Chama rotina de aguardo agora passando 0, para esperar
      --até que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => 0
                                   ,pr_des_erro => vr_des_erro);
                                  
      -- Testar saida com erro
      IF  vr_des_erro IS NOT NULL THEN 
        vr_dscritic := vr_des_erro;
        RAISE vr_exc_erro;
      END IF;
    ELSE
      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                                ,pr_action => NULL);

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Leitura do calendario
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        vr_cdcritic := 1;
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_erro;
      END IF;
      CLOSE BTCH0001.cr_crapdat;

      -- Validacoes iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se possui erro
      IF vr_cdcritic <> 0 THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
      vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                               pr_cdcooper => pr_cdcooper,
                                               pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');  
        
      
      -- Rotina para achar o ultimo dia útil do ano
      vr_dtultdia := add_months(TRUNC(rw_crapdat.dtmvtoan,'RRRR'),12)-1;    
      CASE to_char(vr_dtultdia,'d') 
        WHEN '1' THEN vr_dtultdia := vr_dtultdia - 2;
        WHEN '7' THEN vr_dtultdia := vr_dtultdia - 1;
        ELSE vr_dtultdia := add_months(TRUNC(rw_crapdat.dtmvtoan,'RRRR'),12)-1;
      END CASE;
      
      -- Parametro de bloqueio de resgate de valores em c/c
      -- ref ao pagto de boletos emitidos pela COBTIT
      vr_blqresg_cc := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'COBTIT_BLQ_RESG_CC');         
                                                 
      -- Loop principal dos borderos em prejuizo
      FOR rw_crapbdt_prejuz IN cr_crapbdt_prejuz(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci) LOOP
        IF (rw_crapbdt_prejuz.vlsldatu > 0) THEN
          --Verifica se a conta existe
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_crapbdt_prejuz.nrdconta);
          FETCH cr_crapass INTO rw_crapass;
            
          IF cr_crapass%NOTFOUND THEN
            CLOSE cr_crapass;
            vr_cdcritic := 9; --Associado n cadastrado: --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            RAISE vr_exc_erro;
          END IF;            
          CLOSE cr_crapass;                                                                    
          
          -- Busca os parametros na TAB05                                     
          DSCT0002.pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
                                              ,pr_cdagenci          => null -- Não utiliza dentro da procedure
                                              ,pr_nrdcaixa          => null -- Não utiliza dentro da procedure
                                              ,pr_cdoperad          => null -- Não utiliza dentro da procedure
                                              ,pr_dtmvtolt          => null -- Não utiliza dentro da procedure
                                              ,pr_idorigem          => null -- Não utiliza dentro da procedure
                                              ,pr_tpcobran          => 1    -- Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                              ,pr_inpessoa          => rw_crapass.inpessoa
                                              ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> Tabela contendo os parametros da cooperativa
                                              ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                              ,pr_cdcritic          => vr_cdcritic
                                              ,pr_dscritic          => vr_dscritic);     
                                              
          
          -- Condicao para verificar se permite incluir as linhas parametrizadas
          IF INSTR(',' || vr_dsctajud || ',',',' || rw_crapbdt_prejuz.nrdconta || ',') > 0 THEN
            CONTINUE;
          END IF;
          
          /* verificar se existe boleto de contrato em aberto e se pode debitar do cooperado */
          /* 1º) verificar se o parametro está bloqueado para realizar busca de boleto em aberto */
          IF vr_blqresg_cc = 'S' THEN

            -- inicializar rows de cursores
            rw_cde := NULL;
            rw_ret := NULL;

            /* 2º se permitir, verificar se possui boletos em aberto */
            OPEN cr_cde( pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => rw_crapbdt_prejuz.nrdconta
                        ,pr_nrborder => rw_crapbdt_prejuz.nrborder);
            FETCH cr_cde INTO rw_cde;
            CLOSE cr_cde;

            /* 3º se existir boleto de contrato em aberto, nao debitar */
            IF nvl(rw_cde.nrdocmto,0) > 0 THEN
               --vr_dsobservacao := vr_dsobservacao||'Boleto de contrato em aberto, nao debitar; ';
               CONTINUE;
            ELSE
               /* 4º cursor para verificar se existe boleto pago pendente de processamento, nao debitar */
               OPEN cr_ret( pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapbdt_prejuz.nrdconta
                           ,pr_nrborder => rw_crapbdt_prejuz.nrborder
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
               FETCH cr_ret INTO rw_ret;
               CLOSE cr_ret;

               /* 6º se existir boleto de contrato pago pendente de processamento, nao debitar */
               IF nvl(rw_ret.nrdocmto,0) > 0 THEN
                  --vr_dsobservacao := vr_dsobservacao||'Boleto de contrato pago pendente de processamento, nao debitar; ';
                  CONTINUE;
               END IF;

            END IF;
          END IF;
          
          -- Limpar tabela saldos
          vr_tab_saldos.DELETE;

          -- Obter Saldo do Dia
          EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                     ,pr_rw_crapdat => rw_crapdat
                                     ,pr_cdagenci   => 1
                                     ,pr_nrdcaixa   => 100
                                     ,pr_cdoperad   => 1
                                     ,pr_nrdconta   => rw_crapbdt_prejuz.nrdconta
                                     ,pr_vllimcre   => rw_crapass.vllimcre
                                     ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                     ,pr_flgcrass   => TRUE
                                     ,pr_des_reto   => vr_des_reto
                                     ,pr_tab_sald   => vr_tab_saldos
                                     ,pr_tipo_busca => 'A'
                                     ,pr_tab_erro   => vr_tab_erro);
                                     
          -- Se retornou erro
          IF vr_des_reto <> 'OK' THEN
            IF vr_tab_erro.COUNT > 0 THEN
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_dscritic := 'Erro na procedure pc_crps735.';
            END IF;
            RAISE vr_exc_erro;
          END IF;

          -- Buscar Indice
          vr_index_saldo := vr_tab_saldos.FIRST;
          IF vr_index_saldo IS NOT NULL THEN
            -- Acumular Saldo
            vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index_saldo).vlsddisp, 0) + NVL(vr_tab_saldos(vr_index_saldo).vllimcre, 0),2);
          END IF;
          
          -- se não há saldo disponível na conta corrente, pula o título
          IF vr_vlsldisp <= 0 THEN
            CONTINUE;
          END IF;
          
          IF (vr_vlsldisp > rw_crapbdt_prejuz.vlsldatu) THEN 
            vr_vlpagmto := rw_crapbdt_prejuz.vlsldatu;
          ELSE
            vr_vlpagmto := vr_vlsldisp;
          END IF; 
  --        vr_vlpagmto
          PREJ0005.pc_pagar_bordero_prejuizo(pr_cdcooper => rw_crapbdt_prejuz.cdcooper
                                             ,pr_nrborder => rw_crapbdt_prejuz.nrborder
                                             ,pr_vlaboorj => 0
                                             ,pr_vlpagmto => vr_vlpagmto
                                             ,pr_cdoperad => 1
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_nrdcaixa => NULL
                                             ,pr_liquidou => vr_liquidou
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;  
      END LOOP;
      
      -- Loop principal dos títulos vencidos
      FOR rw_craptdb IN cr_craptdb(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_cdagenci => pr_cdagenci) LOOP
        
        --Verifica se a conta existe
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => rw_craptdb.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
          
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_cdcritic := 9; --Associado n cadastrado: --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_erro;
        END IF;            
        CLOSE cr_crapass;                                                                    
        
        -- Busca os parametros na TAB05                                     
        DSCT0002.pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
                                            ,pr_cdagenci          => null -- Não utiliza dentro da procedure
                                            ,pr_nrdcaixa          => null -- Não utiliza dentro da procedure
                                            ,pr_cdoperad          => null -- Não utiliza dentro da procedure
                                            ,pr_dtmvtolt          => null -- Não utiliza dentro da procedure
                                            ,pr_idorigem          => null -- Não utiliza dentro da procedure
                                            ,pr_tpcobran          => 1    -- Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                            ,pr_inpessoa          => rw_crapass.inpessoa
                                            ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> Tabela contendo os parametros da cooperativa
                                            ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                            ,pr_cdcritic          => vr_cdcritic
                                            ,pr_dscritic          => vr_dscritic);     
                                            
        -- cobranca em aberto, entao faz o teste da carencia
        -- Caso a data de vencimento + carência seja maior que a data de movimentação, pula
        IF (rw_craptdb.incobran = 0) THEN 
          IF ((rw_craptdb.dtvencto + vr_tab_dados_dsctit(1).cardbtit_c) >  rw_crapdat.dtmvtolt) THEN
            CONTINUE;
          END IF;
        END IF;
        
        -- Condicao para verificar se permite incluir as linhas parametrizadas
        IF INSTR(',' || vr_dsctajud || ',',',' || rw_craptdb.nrdconta || ',') > 0 THEN
          CONTINUE;
        END IF;
        
        -- Caso o titulo venca num feriado ou fim de semana e não foi pago parcialmente, pula pois sera pego no proximo dia util 
        IF rw_craptdb.dtvencto > rw_crapdat.dtmvtoan AND rw_craptdb.dtvencto < rw_crapdat.dtmvtolt AND rw_craptdb.incobran = 0 THEN
          CONTINUE;
        END IF;
        
        -- #################################################################################################
        --   REGRA PARA NÃO DEBITAR TÍTULOS VENCIDOS NO PRIMEIRO DIA UTIL DO ANO E QUE VENCERAM NO
        --   DIA UTIL ANTERIOR.
        --   Ex: Boleto com vencto  = 29/12/2017  (ultimo dia útil do ano)
        --       Se o movimento for = 02/01/2018  (primeiro dia util do ano) -- nao debitar --
        --       Se o movimento for = 03/01/2018  (segundo dia util do ano)  -- debitar --
        -- #################################################################################################        
        -- se o titulo vencer no último dia útil do ano e também no dia útil anterior,
        -- entao "não" deverá debitar o título
        IF rw_craptdb.dtvencto = vr_dtultdia AND
           rw_craptdb.dtvencto = rw_crapdat.dtmvtoan THEN
           CONTINUE;
        END IF;
        -- #################################################################################################
        
        /* verificar se existe boleto de contrato em aberto e se pode debitar do cooperado */
        /* 1º) verificar se o parametro está bloqueado para realizar busca de boleto em aberto */
        IF vr_blqresg_cc = 'S' THEN

          -- inicializar rows de cursores
          rw_cde := NULL;
          rw_ret := NULL;

          /* 2º se permitir, verificar se possui boletos em aberto */
          OPEN cr_cde( pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => rw_craptdb.nrdconta
                      ,pr_nrborder => rw_craptdb.nrborder);
          FETCH cr_cde INTO rw_cde;
          CLOSE cr_cde;

          /* 3º se existir boleto de contrato em aberto, nao debitar */
          IF nvl(rw_cde.nrdocmto,0) > 0 THEN
             --vr_dsobservacao := vr_dsobservacao||'Boleto de contrato em aberto, nao debitar; ';
             CONTINUE;
          ELSE
             /* 4º cursor para verificar se existe boleto pago pendente de processamento, nao debitar */
             OPEN cr_ret( pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_craptdb.nrdconta
                         ,pr_nrborder => rw_craptdb.nrborder
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
             FETCH cr_ret INTO rw_ret;
             CLOSE cr_ret;

             /* 6º se existir boleto de contrato pago pendente de processamento, nao debitar */
             IF nvl(rw_ret.nrdocmto,0) > 0 THEN
                --vr_dsobservacao := vr_dsobservacao||'Boleto de contrato pago pendente de processamento, nao debitar; ';
                CONTINUE;
             END IF;

          END IF;
        END IF;
        
        -- Limpar tabela saldos
        vr_tab_saldos.DELETE;

        -- Obter Saldo do Dia
        EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                   ,pr_rw_crapdat => rw_crapdat
                                   ,pr_cdagenci   => 1
                                   ,pr_nrdcaixa   => 100
                                   ,pr_cdoperad   => 1
                                   ,pr_nrdconta   => rw_craptdb.nrdconta
                                   ,pr_vllimcre   => rw_crapass.vllimcre
                                   ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                   ,pr_flgcrass   => TRUE
                                   ,pr_des_reto   => vr_des_reto
                                   ,pr_tab_sald   => vr_tab_saldos
                                   ,pr_tipo_busca => 'A'
                                   ,pr_tab_erro   => vr_tab_erro);
                                   
        -- Se retornou erro
        IF vr_des_reto <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic := 'Erro na procedure pc_crps735.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        -- Buscar Indice
        vr_index_saldo := vr_tab_saldos.FIRST;
        IF vr_index_saldo IS NOT NULL THEN
          -- Acumular Saldo
          vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index_saldo).vlsddisp, 0) + NVL(vr_tab_saldos(vr_index_saldo).vllimcre, 0),2);
        END IF;
        
        -- se não há saldo disponível na conta corrente, pula o título
        IF vr_vlsldisp <= 0 THEN
          CONTINUE;
        END IF;
        
        -- Realiza o pagamento do título
        DSCT0003.pc_pagar_titulo( pr_cdcooper => pr_cdcooper 
                                 ,pr_cdagenci => 1  
                                 ,pr_nrdcaixa => 100  
                                 ,pr_idorigem => 7  
                                 ,pr_cdoperad => 1  
                                 ,pr_nrdconta => rw_craptdb.nrdconta    
                                 ,pr_nrborder => rw_craptdb.nrborder    
                                 ,pr_cdbandoc => rw_craptdb.cdbandoc    
                                 ,pr_nrdctabb => rw_craptdb.nrdctabb    
                                 ,pr_nrcnvcob => rw_craptdb.nrcnvcob    
                                 ,pr_nrdocmto => rw_craptdb.nrdocmto    
                                 ,pr_cdorigpg => 0 -- Conta corrente
                                 ,pr_vlpagmto => vr_vlsldisp
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt    
                                 ,pr_inproces => rw_crapdat.inproces    
                                 ,pr_cdcritic => vr_cdcritic    
                                 ,pr_dscritic => vr_cdcritic);

        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END LOOP;

      -- Processo OK, devemos chamar a fimprg
      BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_des_erro);

      COMMIT;
    END IF;

  EXCEPTION

    WHEN vr_exc_erro THEN
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_des_erro);
      vr_cdcritic := NVL(vr_cdcritic, 0);
      IF vr_cdcritic > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;

    WHEN OTHERS THEN
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_des_erro);
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;

  END;

END pc_crps735;
/
