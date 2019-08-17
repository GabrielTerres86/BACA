DECLARE
  vr_cdcritic_pr     crapcri.cdcritic%TYPE;
  vr_dscritic_pr     crapcri.dscritic%TYPE;

    -- Selecionar borderôs com problemas nas rendas juros remuneratórios
    -- Problema nos titulos resgatados após a virada de chave, pois tinha um erro no fonte quando era necessário restituir valores dos meses após a data do resgate
    CURSOR cr_tdb(pr_cdcooper craptdb.cdcooper%TYPE
                 ,pr_dtlibbdt craptdb.dtlibbdt%TYPE) IS
      SELECT tmp.*
            ,(tmp.renda - tmp.vldjuros) difere 
        FROM (
              SELECT tdb.cdcooper, tdb.nrdconta, tdb.nrborder, tdb.nrdocmto, bdt.flverbor, tdb.dtlibbdt, tdb.dtresgat, tdb.vltitulo, tdb.vlliquid, tdb.vlliqres
                    ,tdb.dtvencto, tdb.cdbandoc, tdb.nrdctabb, tdb.nrcnvcob, bdt.txmensal
                    ,(tdb.vltitulo - tdb.vlliquid) renda
                    ,ljt.vldjuros
                    ,(tdb.vltitulo - tdb.vlliqres) difliqres
                FROM crapbdt bdt
                    ,craptdb tdb
                    ,( SELECT ljt.cdcooper
                             ,ljt.nrdconta
                             ,ljt.nrborder
                             ,ljt.nrdocmto
                             ,ljt.cdbandoc
                             ,ljt.nrdctabb
                             ,ljt.nrcnvcob
                             ,SUM(ljt.vldjuros + ljt.vlrestit) vldjuros
                         FROM crapljt ljt
                        WHERE ljt.cdcooper = pr_cdcooper
                        GROUP BY ljt.cdcooper
                                ,ljt.nrdconta
                                ,ljt.nrborder
                                ,ljt.nrdocmto
                                ,ljt.cdbandoc
                                ,ljt.nrdctabb
                                ,ljt.nrcnvcob  
                     ) ljt
               WHERE bdt.flverbor = 0
                 AND bdt.cdcooper = tdb.cdcooper
                 AND bdt.nrborder = tdb.nrborder
                 AND tdb.cdcooper = ljt.cdcooper
                 AND tdb.nrdconta = ljt.nrdconta
                 AND tdb.nrborder = ljt.nrborder
                 AND tdb.nrdocmto = ljt.nrdocmto
                 AND tdb.cdbandoc = ljt.cdbandoc
                 AND tdb.nrdctabb = ljt.nrdctabb
                 AND tdb.nrcnvcob = ljt.nrcnvcob
                 AND tdb.cdcooper = pr_cdcooper
                 AND tdb.dtlibbdt IS NOT NULL   
                 AND tdb.dtresgat >= pr_dtlibbdt
             ) tmp 
         WHERE tmp.renda <> tmp.vldjuros ;
    rw_tdb cr_tdb%ROWTYPE;

  -- Procedure para efetuar resgate de titulos de um determinado bordero
  PROCEDURE pc_reprocessa_resgate(rw_craptdb     IN cr_tdb%ROWTYPE
                                 ,pr_cdcooper    IN craptdb.cdcooper%TYPE --> Codigo Cooperativa
                                 ,pr_dtresgat    IN crapdat.dtmvtolt%TYPE --> Data do resgate
                                 ,pr_operacao    IN VARCHAR2
                                 ,pr_cdcritic    OUT INTEGER              --> Codigo Critica
                                 ,pr_dscritic    OUT VARCHAR2             --> Descricao Critica
                                 ) IS 

  --Tipo de Tabela de lancamentos de juros dos titulos
  TYPE typ_crawljt IS RECORD (
    nrdconta crapljt.nrdconta%TYPE,
    nrborder crapljt.nrborder%TYPE,
    nrctrlim crapljt.nrctrlim%TYPE,
    dtrefere crapljt.dtrefere%TYPE,
    dtmvtolt crapljt.dtmvtolt%TYPE,
    vldjuros NUMBER,
    vlrestit crapljt.vlrestit%TYPE,
    cdcooper crapljt.cdcooper%TYPE,
    cdbandoc crapljt.cdbandoc%TYPE,
    nrdctabb crapljt.nrdctabb%TYPE,
    nrcnvcob crapljt.nrcnvcob%TYPE,
    nrdocmto crapljt.nrdocmto%TYPE );

  TYPE typ_tab_crawljt IS TABLE OF typ_crawljt INDEX BY PLS_INTEGER;

  --Tabela de lancamentos de juros dos titulos
  vr_tab_crawljt typ_tab_crawljt;
  
      vr_qtdprazo    NUMBER;
      vr_vltitulo    craptdb.vltitulo%TYPE;
      vr_vlliqnov    craptdb.vltitulo%TYPE;
      vr_dtperiod    crapbdt.dtlibbdt%TYPE;
      vr_dtrefjur    crapbdt.dtlibbdt%TYPE;
      vr_vldjuros    NUMBER(38,8) := 0;
      vr_vljurper    NUMBER(38,8) := 0;
      vr_vlliqori    craptdb.vlliquid%TYPE;
      vr_txdiaria     NUMBER;
      vr_flgachou     BOOLEAN := FALSE;
      vr_incrawljt    PLS_INTEGER;
      idx             PLS_INTEGER;
      vr_fcrapljt     BOOLEAN := FALSE;
      vr_exc_erro     EXCEPTION;
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     crapcri.dscritic%TYPE;
      vr_dtultdat    DATE;
      vr_vllanmto    craplcm.vllanmto%TYPE;
      vr_dsparame    VARCHAR2(4000);
    
    --Buscar lancamento juros desconto titulo
    CURSOR cr_crapljt (pr_cdcooper IN crapljt.cdcooper%type
                      ,pr_nrdconta IN crapljt.nrdconta%type
                      ,pr_nrborder IN crapljt.nrborder%type
                      ,pr_dtrefere IN crapljt.dtrefere%type
                      ,pr_cdbandoc IN crapljt.cdbandoc%type
                      ,pr_nrdctabb IN crapljt.nrdctabb%type
                      ,pr_nrcnvcob IN crapljt.nrcnvcob%type
                      ,pr_nrdocmto IN crapljt.nrdocmto%TYPE) IS
      SELECT crapljt.ROWID
            ,crapljt.vldjuros
            ,crapljt.vlrestit
            ,crapljt.dtrefere
        FROM crapljt
       WHERE crapljt.cdcooper = pr_cdcooper
         AND crapljt.nrdconta = pr_nrdconta
         AND crapljt.nrborder = pr_nrborder
         AND crapljt.dtrefere = pr_dtrefere -------
         AND crapljt.cdbandoc = pr_cdbandoc
         AND crapljt.nrdctabb = pr_nrdctabb
         AND crapljt.nrcnvcob = pr_nrcnvcob
         AND crapljt.nrdocmto = pr_nrdocmto;    
    rw_crapljt cr_crapljt%ROWTYPE;
      
    --Buscar lancamento juros desconto titulo com data de referencia maior que o parametro
    CURSOR cr_crapljt2 (pr_cdcooper IN crapljt.cdcooper%type
                      ,pr_nrdconta IN crapljt.nrdconta%type
                      ,pr_nrborder IN crapljt.nrborder%type
                      ,pr_dtrefere IN crapljt.dtrefere%type
                      ,pr_cdbandoc IN crapljt.cdbandoc%type
                      ,pr_nrdctabb IN crapljt.nrdctabb%type
                      ,pr_nrcnvcob IN crapljt.nrcnvcob%type
                      ,pr_nrdocmto IN crapljt.nrdocmto%TYPE) IS
      SELECT crapljt.ROWID
            ,crapljt.vldjuros
            ,crapljt.vlrestit
            ,crapljt.dtrefere
        FROM crapljt
       WHERE crapljt.cdcooper = pr_cdcooper
         AND crapljt.nrdconta = pr_nrdconta
         AND crapljt.nrborder = pr_nrborder
         AND crapljt.dtrefere > pr_dtrefere -------
         AND crapljt.cdbandoc = pr_cdbandoc
         AND crapljt.nrdctabb = pr_nrdctabb
         AND crapljt.nrcnvcob = pr_nrcnvcob
         AND crapljt.nrdocmto = pr_nrdocmto;   


  BEGIN
      vr_dsparame :=' cdcooper = '||rw_craptdb.cdcooper ||
                    ' nrdconta = '||rw_craptdb.nrdconta ||
                    ' nrborder = '||rw_craptdb.nrborder ||
                    ' nrdocmto = '||rw_craptdb.nrdocmto ||
                    ' dtresgat = '||pr_dtresgat;
  
      /*IF rw_craptdb.dtvencto > pr_dtmvtoan AND
         rw_craptdb.dtvencto < pr_dtresgat THEN 
        vr_qtdprazo := rw_craptdb.dtvencto - rw_craptdb.dtlibbdt;
      ELSE 
        vr_qtdprazo := pr_dtresgat - rw_craptdb.dtlibbdt;
      END IF;*/
      
      vr_qtdprazo := pr_dtresgat - rw_craptdb.dtlibbdt;

      --> Calcular taxa diaria
      vr_txdiaria := apli0001.fn_round((power(1 + (rw_craptdb.txmensal / 100),1 / 30) - 1),7);
        
      vr_vltitulo := rw_craptdb.vltitulo;
      vr_dtperiod := rw_craptdb.dtlibbdt;
      vr_vldjuros := 0;
      vr_vljurper := 0;
      vr_vlliqori := rw_craptdb.vlliquid;
      vr_tab_crawljt.delete; 
      
      -- Restituicao nao no mesmo dia da Liberacao
      IF vr_qtdprazo > 0 THEN    
        FOR vr_contador IN 1..vr_qtdprazo LOOP
          vr_vldjuros := apli0001.fn_round(vr_vltitulo * vr_txdiaria,2);
          vr_vltitulo := vr_vltitulo + vr_vldjuros;
          vr_dtperiod := vr_dtperiod + 1;
          vr_dtrefjur := last_day(vr_dtperiod);
          
          --Marcar que nao encontrou
          vr_flgachou:= FALSE;
          --Selecionar Lancamento Juros Desconto Titulo
          FOR idx IN 1..vr_tab_crawljt.Count LOOP
            IF vr_tab_crawljt(idx).cdcooper = rw_craptdb.cdcooper AND
               vr_tab_crawljt(idx).nrdconta = rw_craptdb.nrdconta AND
               vr_tab_crawljt(idx).nrborder = rw_craptdb.nrborder AND
               vr_tab_crawljt(idx).dtrefere = vr_dtrefjur         AND
               vr_tab_crawljt(idx).cdbandoc = rw_craptdb.cdbandoc AND
               vr_tab_crawljt(idx).nrdctabb = rw_craptdb.nrdctabb AND
               vr_tab_crawljt(idx).nrcnvcob = rw_craptdb.nrcnvcob AND
               vr_tab_crawljt(idx).nrdocmto = rw_craptdb.nrdocmto THEN
              --Marcar que encontrou
              vr_flgachou:= TRUE;
              --Acumular valor juros
              vr_tab_crawljt(idx).vldjuros:= vr_tab_crawljt(idx).vldjuros + vr_vldjuros;
            END IF;
          END LOOP;
          
          -- Se nao encontrou cria
          IF NOT vr_flgachou THEN
            --Selecionar indice
            vr_incrawljt:= vr_tab_crawljt.Count+1;
            --Gravar dados tabela memoria
            vr_tab_crawljt(vr_incrawljt).cdcooper:= rw_craptdb.cdcooper;
            vr_tab_crawljt(vr_incrawljt).nrdconta:= rw_craptdb.nrdconta;
            vr_tab_crawljt(vr_incrawljt).nrborder:= rw_craptdb.nrborder;
            vr_tab_crawljt(vr_incrawljt).dtrefere:= vr_dtrefjur;
            vr_tab_crawljt(vr_incrawljt).cdbandoc:= rw_craptdb.cdbandoc;
            vr_tab_crawljt(vr_incrawljt).nrdctabb:= rw_craptdb.nrdctabb;
            vr_tab_crawljt(vr_incrawljt).nrcnvcob:= rw_craptdb.nrcnvcob;
            vr_tab_crawljt(vr_incrawljt).nrdocmto:= rw_craptdb.nrdocmto;
            vr_tab_crawljt(vr_incrawljt).vldjuros:= vr_vldjuros;
          END IF;
        END LOOP;  --vr_contador IN 1..vr_qtdprazo

        vr_vlliqnov := rw_craptdb.vltitulo - (vr_vltitulo - rw_craptdb.vltitulo); 
                             
        --> Atualiza registro de provisao de juros ..........  
        FOR idx IN 1..vr_tab_crawljt.Count LOOP
          --Se for a mesma cooperativa
          IF vr_tab_crawljt(idx).cdcooper = pr_cdcooper THEN
            BEGIN
              --Selecionar lancamento juros desconto titulo
              OPEN cr_crapljt (pr_cdcooper => vr_tab_crawljt(idx).cdcooper
                              ,pr_nrdconta => vr_tab_crawljt(idx).nrdconta
                              ,pr_nrborder => vr_tab_crawljt(idx).nrborder
                              ,pr_dtrefere => vr_tab_crawljt(idx).dtrefere
                              ,pr_cdbandoc => vr_tab_crawljt(idx).cdbandoc
                              ,pr_nrdctabb => vr_tab_crawljt(idx).nrdctabb
                              ,pr_nrcnvcob => vr_tab_crawljt(idx).nrcnvcob
                              ,pr_nrdocmto => vr_tab_crawljt(idx).nrdocmto);
              
              FETCH cr_crapljt INTO rw_crapljt;
              vr_fcrapljt := cr_crapljt%FOUND;
              CLOSE cr_crapljt;
            EXCEPTION  
              WHEN OTHERS THEN
                vr_fcrapljt := FALSE;
            END;
            
            -- Verificar se encontrou o registro
            IF vr_fcrapljt = FALSE THEN
              -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
              vr_cdcritic := 1170; --Registro crapljt nao encontrado.
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              RAISE vr_exc_erro;
            END IF;
            
            IF pr_operacao = 'L' THEN
              --Atualizar tabela juros
              BEGIN

                UPDATE crapljt 
                   SET crapljt.vlrestit = 0
                      ,crapljt.vldjuros = nvl(vr_tab_crawljt(idx).vldjuros,0)
                WHERE crapljt.ROWID = rw_crapljt.ROWID
                RETURNING crapljt.vlrestit INTO rw_crapljt.vlrestit;
              EXCEPTION
                WHEN OTHERS THEN
                  -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                  --CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
                  -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                  vr_cdcritic := 1035;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                                 'crapljt(5):'||
                                 ' vlrestit:'  || 'NVL(crapljt.vldjuros,0) - ' || NVL(vr_tab_crawljt(idx).vldjuros,0) ||
                                 ', vldjuros:' || nvl(vr_tab_crawljt(idx).vldjuros,0) ||
                                 ', ROWID:'    || rw_crapljt.ROWID || 
                                 '. ' ||sqlerrm; 
                  --Levantar Excecao
                  RAISE vr_exc_erro;
              END;
            ELSE  
            
              --Se o valor dos juros mudou
              IF rw_crapljt.vldjuros <> vr_tab_crawljt(idx).vldjuros THEN
                --Se valor juros tabela eh maior encontrado
                IF  rw_crapljt.vldjuros > vr_tab_crawljt(idx).vldjuros THEN
                  --Atualizar tabela juros
                  BEGIN

                    UPDATE crapljt SET crapljt.vlrestit = NVL(crapljt.vldjuros,0) - NVL(vr_tab_crawljt(idx).vldjuros,0)
                                      ,crapljt.vldjuros = nvl(vr_tab_crawljt(idx).vldjuros,0)
                    WHERE crapljt.ROWID = rw_crapljt.ROWID
                    RETURNING crapljt.vlrestit INTO rw_crapljt.vlrestit;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                      --CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
                      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                      vr_cdcritic := 1035;
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                                     'crapljt(4):'||
                                     ' vlrestit:'  || 'NVL(crapljt.vldjuros,0) - ' || NVL(vr_tab_crawljt(idx).vldjuros,0) ||
                                     ', vldjuros:' || nvl(vr_tab_crawljt(idx).vldjuros,0) ||
                                     ', ROWID:'    || rw_crapljt.ROWID || 
                                     '. ' ||sqlerrm; 
                      --Levantar Excecao
                      RAISE vr_exc_erro;
                  END;
                ELSE
                  -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                  vr_cdcritic := 367; --Erro - Juros negativo:
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||rw_crapljt.vldjuros;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END IF;

            --Data de Referencia
            vr_dtultdat:= vr_tab_crawljt(idx).dtrefere;
            --Excluir registro da tabela memoria
            vr_tab_crawljt.DELETE(idx);
          END IF;
        END LOOP;
        
      ELSE
        vr_dtultdat := pr_dtresgat;
        vr_vlliqori := rw_craptdb.vlliquid;
        vr_vlliqnov := rw_craptdb.vltitulo;  
      END IF;-- Fim IF vr_qtdprazo > 0 THEN     

      vr_vllanmto := rw_craptdb.vltitulo - (vr_vlliqnov - vr_vlliqori);  
      
      --Selecionar lancamento juros desconto titulo
      FOR rw_craplj IN cr_crapljt2 ( pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => rw_craptdb.nrdconta
                                    ,pr_nrborder => rw_craptdb.nrborder
                                    ,pr_dtrefere => vr_dtultdat
                                    ,pr_cdbandoc => rw_craptdb.cdbandoc
                                    ,pr_nrdctabb => rw_craptdb.nrdctabb
                                    ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                    ,pr_nrdocmto => rw_craptdb.nrdocmto) LOOP
        --Atualizar tabela juros
        BEGIN

          UPDATE crapljt 
             SET crapljt.vlrestit = crapljt.vldjuros
                ,crapljt.vldjuros = 0
          WHERE crapljt.ROWID = rw_craplj.ROWID
          RETURNING crapljt.vlrestit INTO rw_craplj.vlrestit;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                           'crapljt(5):'||
                           ' vlrestit:'  || 'crapljt.vldjuros' ||
                           ', vldjuros:' || '0' ||
                           ', ROWID:'    || rw_craplj.ROWID || 
                           '. ' ||sqlerrm; 
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END LOOP; -- Fim loop rw_craplj
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic ||'. '|| vr_dsparame;

    WHEN OTHERS THEN
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||' DSCT0001.pc_efetua_resgate_tit_bord. '||sqlerrm||'. '||vr_dsparame;
  END;

BEGIN
  FOR rw_cop IN ( SELECT cop.cdcooper
                         ,min(bdt.dtlibbdt) dtvirachave
                    FROM crapbdt bdt
                        ,crapcop cop
                   WHERE bdt.flverbor = 1
                     AND bdt.cdcooper = cop.cdcooper
                     AND cop.flgativo = 1
                   GROUP BY cop.cdcooper ) 
  LOOP 
    OPEN cr_tdb(pr_cdcooper => rw_cop.cdcooper
               ,pr_dtlibbdt => rw_cop.dtvirachave);
    LOOP
      FETCH cr_tdb INTO rw_tdb;
      EXIT WHEN cr_tdb%NOTFOUND;
      
      -- recalcular os valores de juros da lcj simulando a liberação do borderô que considera o calculo dos juros até o vencimento do titulo
      pc_reprocessa_resgate(rw_craptdb  => rw_tdb
                           ,pr_cdcooper => rw_tdb.cdcooper
                           ,pr_dtresgat => rw_tdb.dtvencto
                           ,pr_operacao => 'L' -- liberação
                           ,pr_cdcritic => vr_cdcritic_pr
                           ,pr_dscritic => vr_dscritic_pr );

      IF NVL(vr_cdcritic_pr,0) > 0 OR trim(vr_dscritic_pr) IS NOT NULL THEN
        CLOSE cr_tdb;
        RAISE_application_error(-20001,vr_cdcritic_pr||' - '||vr_dscritic_pr);
      END IF; 
      
      -- recalcular os valores de juros da lcj simulando o resgate do borderô que considera o calculo dos juros até o resgate, podendo ter juros a restituir
      pc_reprocessa_resgate(rw_craptdb  => rw_tdb
                           ,pr_cdcooper => rw_tdb.cdcooper
                           ,pr_dtresgat => rw_tdb.dtresgat
                           ,pr_operacao => 'R' -- resgate
                           ,pr_cdcritic => vr_cdcritic_pr
                           ,pr_dscritic => vr_dscritic_pr );

      IF NVL(vr_cdcritic_pr,0) > 0 OR trim(vr_dscritic_pr) IS NOT NULL THEN
        CLOSE cr_tdb;
        RAISE_application_error(-20001,vr_cdcritic_pr||' - '||vr_dscritic_pr);
      END IF; 

    END LOOP;
    CLOSE cr_tdb;
  END LOOP;

  COMMIT;
END;
