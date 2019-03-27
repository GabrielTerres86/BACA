CREATE OR REPLACE PROCEDURE CECRED.pc_crps734(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                             ,pr_cdagenci  IN crapbdt.cdagenci%TYPE DEFAULT NULL --> Agencia
                                             ,pr_idparale IN INTEGER DEFAULT 0          --> Id da transacao de paralelismo
                                             ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                             ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps734
     Sistema : Crédito - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Lazari (GFT)
     Data    : Junho/2018                     Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Atualizar o saldo devedor de títulos vencidos descontados.

     Alteracoes: 
               06/08/2018 - Alterado para paralelismo - Luis Fernando (GFT)
               18/09/2018 - Adicionados calculos do prejuizo - Luis Fernando (GFT)
               02/10/2018 - Adicionado instrução para inserir lançamento de juros de atualização - Cássia de Oliveira (GFT)
  ............................................................................ */
  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS734';
    vr_qtdjobs  NUMBER;
    vr_dtultdia DATE;                  -- Variavel para armazenar o ultimo dia util do ano
    vr_idparale INTEGER;
    vr_jobname  VARCHAR2(30); 
    vr_dsplsql  VARCHAR2(4000); 
    vr_des_erro VARCHAR2(32000);
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------
    -- Cursor generico de calendario
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;

    -- Cursor para trazer as agencias para o paralelismo
    CURSOR cr_crapage IS 
      SELECT  crapage.cdagenci
             ,crapage.nmresage
      FROM  crapage
       where crapage.cdcooper = pr_cdcooper
         AND crapage.cdagenci <> 999
    ;

    --  Busca todos os títulos liberados que estão vencidos
    
    CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                     ,pr_cdagenci IN crapbdt.cdagenci%TYPE) IS
      SELECT 
        x.*
      FROM (
      SELECT craptdb.ROWID,
             craptdb.nrdconta,
             craptdb.dtvencto,
             craptdb.nrborder,
             craptdb.cdbandoc,
             craptdb.nrcnvcob,
             craptdb.nrdctabb,
             craptdb.vlmratit,
             craptdb.vljura60,
             craptdb.nrdocmto,
             craptdb.vlsldtit,
			 (SELECT 
					   MIN(dtvencto)
					 FROM craptdb tdb
					 WHERE tdb.insittit = 4 
					   AND tdb.cdcooper = pr_cdcooper 
					   AND tdb.nrborder = craptdb.nrborder
					   AND tdb.nrdconta = craptdb.nrdconta
					 GROUP BY tdb.nrborder 
								) AS  maisvencido, -- verifica se o bordero desse titulo possui 1 titulo vencido ha mais de 60 dias
			 (POWER((crapbdt.vltxmora / 100) + 1,(1 / 30)) - 1) AS txdiariamora
        FROM craptdb, crapbdt
       WHERE craptdb.cdcooper =  crapbdt.cdcooper
         AND craptdb.nrdconta =  crapbdt.nrdconta
         AND craptdb.nrborder =  crapbdt.nrborder
         AND craptdb.cdcooper =  pr_cdcooper
         AND craptdb.insittit =  4  -- liberado
                 AND crapbdt.flverbor =  1 -- bordero liberado na nova versão
                 AND crapbdt.inprejuz = 0 -- apenas titulos de borderos que nao estao em prejuizo
         AND crapbdt.cdagenci = nvl(pr_cdagenci,crapbdt.cdagenci)
                 ORDER BY craptdb.cdcooper,craptdb.nrdconta,craptdb.nrborder
        ) x
      WHERE 
        (dtvencto <= pr_dtmvtolt OR (maisvencido+60)<= pr_dtmvtolt);
    
    
    --  Busca todos os títulos liberados que estão em prejuízo
    CURSOR cr_craptdb_prejuz(pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                               ,pr_cdagenci IN crapbdt.cdagenci%TYPE) IS
      SELECT tdb.ROWID,
        tdb.nrdconta,
        tdb.dtvencto,
        tdb.nrborder,
        tdb.cdbandoc,
        tdb.nrcnvcob,
        tdb.nrdctabb,
        tdb.vlmratit,
        tdb.vljura60,
        tdb.nrdocmto,
        tdb.vlsldtit,
        tdb.nrtitulo,
        (bdt.txmensal/30) AS txdiariaatualizacao,
        bdt.dtprejuz
      FROM craptdb tdb
        INNER JOIN crapbdt bdt ON bdt.cdcooper = tdb.cdcooper AND bdt.nrborder = tdb.nrborder AND bdt.nrdconta = tdb.nrdconta
      WHERE tdb.cdcooper =  pr_cdcooper
         AND tdb.insittit =  4  -- liberado
         AND bdt.flverbor =  1 -- bordero liberado na nova versão
         AND bdt.inprejuz = 1 -- apenas titulos de borderos que estao em prejuizo
         AND bdt.dtliqprj IS NULL
         AND bdt.cdagenci = nvl(pr_cdagenci,bdt.cdagenci)
      ORDER BY tdb.cdcooper,tdb.nrdconta,tdb.nrborder;
    
    CURSOR cr_lancbor_jraprj(pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                            ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                            ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                            ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                            ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo do historico do lancamento
                            ,pr_cdbandoc IN craptdb.cdbandoc%TYPE --> Codigo do banco impresso no boleto
                            ,pr_nrdctabb IN craptdb.nrdctabb%TYPE --> Numero da conta base do titulo
                            ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE --> Numero do convenio de cobranca
                            ,pr_nrdocmto IN craptdb.nrdocmto%TYPE --> Numero do documento
                            ) IS
    SELECT SUM(lcb.vllanmto) vllanmto
      FROM tbdsct_lancamento_bordero lcb
     WHERE lcb.cdcooper = pr_cdcooper
       AND lcb.nrdconta = pr_nrdconta
       AND lcb.nrborder = pr_nrborder
       AND lcb.cdbandoc = pr_cdbandoc
       AND lcb.nrdctabb = pr_nrdctabb
       AND lcb.nrcnvcob = pr_nrcnvcob
       AND lcb.nrdocmto = pr_nrdocmto
       AND lcb.cdhistor = pr_cdhistor
       AND lcb.dtmvtolt <= pr_dtmvtolt;
    rw_lancbor_jraprj cr_lancbor_jraprj%ROWTYPE;
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    TYPE typ_reg_craptdb IS RECORD
      (vlmtatit craptdb.vlmtatit%TYPE
      ,vlmratit craptdb.vlmratit%TYPE
      ,vljura60 craptdb.vljura60%TYPE
      ,vlioftit craptdb.vliofcpl%TYPE
      ,vljraprj craptdb.vljraprj%TYPE
      ,vljrmprj craptdb.vljrmprj%TYPE
      ,vr_rowid ROWID);
      
    TYPE typ_tab_craptdb IS TABLE OF typ_reg_craptdb INDEX BY PLS_INTEGER;
    vr_tab_craptdb  typ_tab_craptdb;
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_index            PLS_INTEGER;
    
    vr_vlmtatit NUMBER;
    vr_vlmratit NUMBER;
    vr_vlioftit NUMBER;
    vr_vljraprj NUMBER;
    vr_vljrmprj NUMBER;
    vr_datacalc DATE;
    vr_vljura60 craptdb.vljura60%TYPE;
    vr_vljrre60 craptdb.vljura60%TYPE;
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
        RAISE vr_exc_saida;
      END IF;
      FOR reg_crapage in cr_crapage LOOP
        vr_jobname := vr_cdprogra ||'_'|| reg_crapage.cdagenci || '$';
        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                    ,pr_idprogra => LPAD(reg_crapage.cdagenci,3,'0') --> Utiliza a agência como id programa
                                    ,pr_des_erro => vr_dscritic);
        -- Testar saida com erro
        if vr_dscritic is not null then
          -- Levantar exceçao
          raise vr_exc_saida;
        END if;
        vr_dsplsql := 'declare'            ||chr(13)||
                      ' wpr_stprogra  binary_integer; '||chr(13)||
                      ' wpr_infimsol  binary_integer; '||chr(13)||
                      ' wpr_cdcritic  number(5); '     ||chr(13)||
                      ' wpr_dscritic  varchar2(4000); '||chr(13)||
                      ' begin '||chr(13)||
                      '   cecred.pc_crps734('||pr_cdcooper||','||chr(13)||
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
                                ,pr_des_erro => vr_dscritic);    

          -- Testar saida com erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_saida;
          END IF;
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => vr_qtdjobs
                                   ,pr_des_erro => vr_dscritic);
      END LOOP;
      
      --Chama rotina de aguardo agora passando 0, para esperar
      --até que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => 0
                                   ,pr_des_erro => vr_dscritic);
                                  
      -- Testar saida com erro
      IF  vr_dscritic IS NOT NULL THEN 
        -- Levantar exceçao
        RAISE vr_exc_saida;
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
        RAISE vr_exc_saida;
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
        RAISE vr_exc_saida;
      END IF;
      
      -- Rotina para achar o ultimo dia útil do ano
      vr_dtultdia := add_months(TRUNC(rw_crapdat.dtmvtoan,'RRRR'),12)-1;    
      CASE to_char(vr_dtultdia,'d') 
        WHEN '1' THEN vr_dtultdia := vr_dtultdia - 2;
        WHEN '7' THEN vr_dtultdia := vr_dtultdia - 1;
        ELSE vr_dtultdia := add_months(TRUNC(rw_crapdat.dtmvtoan,'RRRR'),12)-1;
      END CASE;
      
    IF (rw_crapdat.inproces=1) THEN
      vr_datacalc := rw_crapdat.dtmvtolt;
    ELSE 
      vr_datacalc := rw_crapdat.dtmvtopr;
    END IF;
    
    vr_tab_craptdb.delete;
    
    FOR rw_craptdb_prejuz IN cr_craptdb_prejuz(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => vr_datacalc
                                  ,pr_cdagenci => pr_cdagenci) LOOP
      vr_index := vr_tab_craptdb.COUNT + 1;
      
      IF (rw_craptdb_prejuz.dtprejuz<=vr_datacalc) THEN -- titulo em atraso
        PREJ0005.pc_calcula_atraso_prejuizo(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_craptdb_prejuz.nrdconta
                                            ,pr_nrborder => rw_craptdb_prejuz.nrborder
                                            ,pr_cdbandoc => rw_craptdb_prejuz.cdbandoc
                                            ,pr_nrdctabb => rw_craptdb_prejuz.nrdctabb
                                            ,pr_nrcnvcob => rw_craptdb_prejuz.nrcnvcob
                                            ,pr_nrdocmto => rw_craptdb_prejuz.nrdocmto
                                            ,pr_dtmvtolt => vr_datacalc
                                            ,pr_vljraprj => vr_vljraprj
                                            ,pr_vljrmprj => vr_vljrmprj
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                           );
        vr_tab_craptdb(vr_index).vljraprj := vr_vljraprj;
        vr_tab_craptdb(vr_index).vljrmprj := vr_vljrmprj;

        -- Buscar o valor dos juros de atualização do prejuizo já lançados em dias anteriores para desconsiderar da diária atual
        OPEN cr_lancbor_jraprj(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => rw_craptdb_prejuz.nrdconta
                              ,pr_nrborder => rw_craptdb_prejuz.nrborder
                              ,pr_dtmvtolt => vr_datacalc
                              ,pr_cdhistor => PREJ0005.vr_cdhistordsct_juros_atuali
                              ,pr_cdbandoc => rw_craptdb_prejuz.cdbandoc
                              ,pr_nrdctabb => rw_craptdb_prejuz.nrdctabb
                              ,pr_nrcnvcob => rw_craptdb_prejuz.nrcnvcob
                              ,pr_nrdocmto => rw_craptdb_prejuz.nrdocmto );
        FETCH cr_lancbor_jraprj INTO rw_lancbor_jraprj;
        CLOSE cr_lancbor_jraprj;
        
        -- Lançar valor de pagamento da multa nos lançamentos do borderô
        DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_craptdb_prejuz.nrdconta
                                     ,pr_nrborder => rw_craptdb_prejuz.nrborder
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdbandoc => rw_craptdb_prejuz.cdbandoc
                                     ,pr_nrdctabb => rw_craptdb_prejuz.nrdctabb
                                     ,pr_nrcnvcob => rw_craptdb_prejuz.nrcnvcob
                                     ,pr_nrdocmto => rw_craptdb_prejuz.nrdocmto
                                     ,pr_nrtitulo => rw_craptdb_prejuz.nrtitulo
                                     ,pr_cdorigem => 7
                                     ,pr_cdhistor => PREJ0005.vr_cdhistordsct_juros_atuali
                                     ,pr_vllanmto => vr_vljraprj - nvl(rw_lancbor_jraprj.vllanmto,0)
                                     ,pr_dscritic => vr_dscritic );
      END IF;
      
      vr_tab_craptdb(vr_index).vr_rowid := rw_craptdb_prejuz.ROWID;   
    END LOOP;
    -- Atualiza os valores de prejuizo
    BEGIN
      FORALL idx IN INDICES OF vr_tab_craptdb SAVE EXCEPTIONS
        UPDATE craptdb
           SET craptdb.vljraprj = nvl(vr_tab_craptdb(idx).vljraprj,craptdb.vljraprj),               
               craptdb.vljrmprj = nvl(vr_tab_craptdb(idx).vljrmprj,craptdb.vljrmprj)
         WHERE ROWID = vr_tab_craptdb(idx).vr_rowid;
   
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar craptdb em prejuizo: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;

    vr_tab_craptdb.delete;
      -- Loop principal dos títulos vencidos
      FOR rw_craptdb IN cr_craptdb(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => vr_datacalc
                                  ,pr_cdagenci => pr_cdagenci) LOOP
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
        
        
      vr_index := vr_tab_craptdb.COUNT + 1;   
      IF (rw_craptdb.dtvencto<=vr_datacalc) THEN -- titulo em atraso
        -- Calcula os valores de atraso do título    
        DSCT0003.pc_calcula_atraso_tit(pr_cdcooper => pr_cdcooper    
                                      ,pr_nrdconta => rw_craptdb.nrdconta    
                                      ,pr_nrborder => rw_craptdb.nrborder    
                                      ,pr_cdbandoc => rw_craptdb.cdbandoc    
                                      ,pr_nrdctabb => rw_craptdb.nrdctabb    
                                      ,pr_nrcnvcob => rw_craptdb.nrcnvcob    
                                      ,pr_nrdocmto => rw_craptdb.nrdocmto    
                                      ,pr_dtmvtolt => vr_datacalc    
                                      ,pr_vlmtatit => vr_vlmtatit    
                                      ,pr_vlmratit => vr_vlmratit    
                                      ,pr_vlioftit => vr_vlioftit    
                                      ,pr_cdcritic => vr_cdcritic    
                                      ,pr_dscritic => vr_dscritic);
        
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        vr_tab_craptdb(vr_index).vlmtatit := vr_vlmtatit;
        vr_tab_craptdb(vr_index).vlmratit := vr_vlmratit;
        vr_tab_craptdb(vr_index).vlioftit := vr_vlioftit;
      END IF;
        
        -- Realiza o cálculo dos juros + 60 de mora do título
      DSCT0003.pc_calcula_juros60_tit(pr_cdcooper =>pr_cdcooper    
                                     ,pr_nrdconta => rw_craptdb.nrdconta    
                                     ,pr_nrborder => rw_craptdb.nrborder    
                                     ,pr_cdbandoc => rw_craptdb.cdbandoc    
                                     ,pr_nrdctabb => rw_craptdb.nrdctabb    
                                     ,pr_nrcnvcob => rw_craptdb.nrcnvcob    
                                     ,pr_nrdocmto => rw_craptdb.nrdocmto    
                                     ,pr_dtmvtolt => vr_datacalc    
                                     ,pr_vljura60 => vr_vljura60
                                     ,pr_vljrre60 => vr_vljrre60
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic );

      IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
        END IF;
                                  
      vr_tab_craptdb(vr_index).vljura60 := vr_vljura60;

        vr_tab_craptdb(vr_index).vr_rowid := rw_craptdb.ROWID;   
      END LOOP;
      
      -- Atualiza os valores de multa, juros de mora, juros + 60 e iof do atraso do título
      BEGIN
        FORALL idx IN INDICES OF vr_tab_craptdb SAVE EXCEPTIONS
          UPDATE craptdb
           SET craptdb.vlmtatit = nvl(vr_tab_craptdb(idx).vlmtatit,craptdb.vlmtatit),
               craptdb.vljura60 = nvl(vr_tab_craptdb(idx).vljura60,craptdb.vljura60),
               craptdb.vlmratit = nvl(vr_tab_craptdb(idx).vlmratit,craptdb.vlmratit),
               craptdb.vliofcpl = nvl(vr_tab_craptdb(idx).vlioftit,craptdb.vliofcpl)
           WHERE ROWID = vr_tab_craptdb(idx).vr_rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar craptdb: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Processo OK, devemos chamar a fimprg
      BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
      
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);
      COMMIT;
            
  END IF;

  EXCEPTION

    WHEN vr_exc_saida THEN
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);
      vr_cdcritic := NVL(vr_cdcritic, 0);
      IF vr_cdcritic > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;

    WHEN OTHERS THEN
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;

  END;

END pc_crps734;
/
