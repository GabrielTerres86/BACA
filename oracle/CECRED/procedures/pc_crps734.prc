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
     Sistema : Cr�dito - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Lazari (GFT)
     Data    : Junho/2018                     Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Atualizar o saldo devedor de t�tulos vencidos descontados.

     Alteracoes: 
               06/08/2018 - Alterado para paralelismo - Luis Fernando (GFT)
  ............................................................................ */
  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS734';
    vr_qtdjobs             number;
    vr_dtultdia DATE;                  -- Variavel para armazenar o ultimo dia util do ano
    vr_idparale INTEGER;
    vr_jobname             varchar2(30); 
    vr_dsplsql             varchar2(4000); 
    
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

    --  Busca todos os t�tulos liberados que est�o vencidos
    CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                     ,pr_cdagenci IN crapbdt.cdagenci%TYPE) IS
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
             CASE 
               WHEN (SELECT 
                       COUNT(1)
                     FROM craptdb tdb
                     WHERE (tdb.dtvencto+60) < pr_dtmvtolt
                                  AND tdb.insittit = 4 
                                  AND tdb.cdcooper=pr_cdcooper 
                                  AND tdb.nrborder=craptdb.nrborder
                                  AND tdb.insittit = 4
                                ) > 0 THEN 1 
               ELSE 0 
             END AS possui60 -- verifica se o bordero desse titulo possui 1 titulo vencido ha mais de 60 dias
        FROM craptdb, crapbdt
       WHERE craptdb.cdcooper =  crapbdt.cdcooper
         AND craptdb.nrdconta =  crapbdt.nrdconta
         AND craptdb.nrborder =  crapbdt.nrborder
         AND craptdb.cdcooper =  pr_cdcooper
         AND craptdb.dtvencto <= pr_dtmvtolt
         AND craptdb.insittit =  4  -- liberado
         AND crapbdt.cdagenci = nvl(pr_cdagenci,crapbdt.cdagenci)
         AND crapbdt.flverbor =  1; -- bordero liberado na nova vers�o
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    TYPE typ_reg_craptdb IS RECORD
      (vlmtatit craptdb.vlmtatit%TYPE
      ,vlmratit craptdb.vlmratit%TYPE
      ,vljura60 craptdb.vljura60%TYPE
      ,vlioftit craptdb.vliofcpl%TYPE
      ,vr_rowid ROWID);
      
    TYPE typ_tab_craptdb IS TABLE OF typ_reg_craptdb INDEX BY PLS_INTEGER;
    vr_tab_craptdb  typ_tab_craptdb;
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_index            PLS_INTEGER;
    
    vr_vlmtatit NUMBER;
    vr_vlmratit NUMBER;
    vr_vlioftit NUMBER;
    vr_datacalc DATE;
  BEGIN
    -- ainda n�o comecou a rodar o paralelismo
    IF (nvl(pr_idparale,0)=0) THEN
      vr_idparale := gene0001.fn_gera_id_paralelo;
      -- Buscar quantidade parametrizada de Jobs
      vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper --> C�digo da coopertiva
                                                   ,vr_cdprogra --> C�digo do programa
                                                   );
      IF (vr_qtdjobs = 0) THEN
        vr_dscritic := 'Nao foi possivel encontrar o parametro de quantidade de Jobs';
        RAISE vr_exc_saida;
      END IF;
      FOR reg_crapage in cr_crapage LOOP
        vr_jobname := vr_cdprogra ||'_'|| reg_crapage.cdagenci || '$';
        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                    ,pr_idprogra => LPAD(reg_crapage.cdagenci,3,'0') --> Utiliza a ag�ncia como id programa
                                    ,pr_des_erro => vr_dscritic);
        -- Testar saida com erro
        if vr_dscritic is not null then
          -- Levantar exce�ao
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
          gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> C�digo da cooperativa
                                ,pr_cdprogra => vr_cdprogra  --> C�digo do programa
                                ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva  => NULL         --> Sem intervalo de execu��o da fila, ou seja, apenas 1 vez
                                ,pr_jobname  => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro => vr_dscritic);    

          -- Testar saida com erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levantar exce�ao
            RAISE vr_exc_saida;
          END IF;
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => vr_qtdjobs
                                   ,pr_des_erro => vr_dscritic);
      END LOOP;
      
      --Chama rotina de aguardo agora passando 0, para esperar
      --at� que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => 0
                                   ,pr_des_erro => vr_dscritic);
                                  
      -- Testar saida com erro
      IF  vr_dscritic IS NOT NULL THEN 
        -- Levantar exce�ao
        RAISE vr_exc_saida;
      END IF;
    ELSE 
    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do m�dulo logado
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
    
    -- Rotina para achar o ultimo dia �til do ano
    vr_dtultdia := add_months(TRUNC(rw_crapdat.dtmvtoan,'RRRR'),12)-1;    
    CASE to_char(vr_dtultdia,'d') 
      WHEN '1' THEN vr_dtultdia := vr_dtultdia - 2;
      WHEN '7' THEN vr_dtultdia := vr_dtultdia - 1;
      ELSE vr_dtultdia := add_months(TRUNC(rw_crapdat.dtmvtoan,'RRRR'),12)-1;
    END CASE;
    
    -- Loop principal dos t�tulos vencidos
    FOR rw_craptdb IN cr_craptdb(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_cdagenci => pr_cdagenci) LOOP
      
      -- #################################################################################################
      --   REGRA PARA N�O DEBITAR T�TULOS VENCIDOS NO PRIMEIRO DIA UTIL DO ANO E QUE VENCERAM NO
      --   DIA UTIL ANTERIOR.
      --   Ex: Boleto com vencto  = 29/12/2017  (ultimo dia �til do ano)
      --       Se o movimento for = 02/01/2018  (primeiro dia util do ano) -- nao debitar --
      --       Se o movimento for = 03/01/2018  (segundo dia util do ano)  -- debitar --
      -- #################################################################################################        
      -- se o titulo vencer no �ltimo dia �til do ano e tamb�m no dia �til anterior,
      -- entao "n�o" dever� debitar o t�tulo
      IF rw_craptdb.dtvencto = vr_dtultdia AND
         rw_craptdb.dtvencto = rw_crapdat.dtmvtoan THEN
         CONTINUE;
      END IF;
      -- #################################################################################################
      
        IF (rw_crapdat.inproces=1) THEN
          vr_datacalc := rw_crapdat.dtmvtolt;
        ELSE 
          vr_datacalc := rw_crapdat.dtmvtopr;
        END IF;
        
        
        
      -- Calcula os valores de atraso do t�tulo    
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
      
      vr_index := vr_tab_craptdb.COUNT + 1;
      
      -- Realiza o c�lculo dos juros + 60 de mora do t�tulo
      IF (rw_craptdb.possui60 = 1) THEN
        vr_tab_craptdb(vr_index).vljura60 := rw_craptdb.vljura60 + (vr_vlmratit - rw_craptdb.vlmratit);  
      ELSE
        vr_tab_craptdb(vr_index).vljura60 := 0;
      END IF;
      
      vr_tab_craptdb(vr_index).vlmtatit := vr_vlmtatit;
      vr_tab_craptdb(vr_index).vlmratit := vr_vlmratit;
      vr_tab_craptdb(vr_index).vlioftit := vr_vlioftit;
      vr_tab_craptdb(vr_index).vr_rowid := rw_craptdb.ROWID;   
    END LOOP;
    
    -- Atualiza os valores de multa, juros de mora, juros + 60 e iof do atraso do t�tulo
    BEGIN
      FORALL idx IN INDICES OF vr_tab_craptdb SAVE EXCEPTIONS
        UPDATE craptdb
           SET craptdb.vlmtatit = vr_tab_craptdb(idx).vlmtatit,    
               craptdb.vljura60 = vr_tab_craptdb(idx).vljura60,    
               craptdb.vlmratit = vr_tab_craptdb(idx).vlmratit,    
               craptdb.vliofcpl = vr_tab_craptdb(idx).vlioftit   
         WHERE ROWID = vr_tab_craptdb(idx).vr_rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar craptdb: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
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
