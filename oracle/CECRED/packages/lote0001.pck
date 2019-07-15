CREATE OR REPLACE PACKAGE cecred.lote0001 IS

 /*..............................................................................
   Programa: LOTE0001
   Autor   : Odirlei
   Data    : 28/07/2015                        Ultima atualizacao: 03/07/2019
  
   Dados referentes ao programa: 
  
   Objetivo  : Package com as procedures necessárias para pagamento de guias DARF e DAS
  
   Alteracoes: 07/12/2017 - Incluido novos campos no cursor da craplot (Tiago/Adriano #745339)
   
               26/02/2018 - Inclusao do campo cdcooper no returning do cursor
                            da craplot. (Chamado 856240) - (Fabricio)
			   
			   16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)

  03/07/2019 - PRB0041947 Na rotina lote0001.pc_insere_lote_rvt, ignorada a exception DUP_VAL_ON_INDEX, pois os 
               programas paralelos, ao concorrerem na inserção do lote, não devem abortar a execução (Carlos)
  ..............................................................................*/

  --Testar se o lote esta em lock
  CURSOR cr_craplot_rowid (pr_rowid IN ROWID) IS
  SELECT  1
    FROM craplot craplot
   WHERE craplot.rowid = pr_rowid
     FOR UPDATE NOWAIT;
  rw_craplot_rowid cr_craplot_rowid%ROWTYPE;

  --Buscar informacoes de lote
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                   ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                   ,pr_cdagenci IN craplot.cdagenci%TYPE
                   ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                   ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT craplot.cdcooper
          ,craplot.dtmvtolt
          ,craplot.nrdolote
          ,craplot.cdagenci
          ,craplot.nrseqdig
          ,craplot.cdbccxlt
          ,craplot.qtcompln
          ,craplot.tplotmov
          ,craplot.cdhistor
          ,craplot.cdoperad
          ,craplot.qtinfoln
          ,craplot.vlcompcr
          ,craplot.vlinfocr
          ,craplot.vlcompdb
          ,craplot.vlinfodb
          ,craplot.rowid
      FROM craplot craplot
     WHERE craplot.cdcooper = pr_cdcooper
       AND craplot.dtmvtolt = pr_dtmvtolt
       AND craplot.cdagenci = pr_cdagenci
       AND craplot.cdbccxlt = pr_cdbccxlt
       AND craplot.nrdolote = pr_nrdolote
       FOR UPDATE NOWAIT;

  CURSOR cr_craplot_sem_lock(pr_cdcooper IN craplot.cdcooper%TYPE
                            ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                            ,pr_cdagenci IN craplot.cdagenci%TYPE
                            ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                            ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
             SELECT craplot.cdcooper
                   ,craplot.dtmvtolt
                   ,craplot.nrdolote
                   ,craplot.cdagenci
                   ,craplot.nrseqdig
                   ,craplot.cdbccxlt
                   ,craplot.qtcompln
                   ,craplot.tplotmov
                   ,craplot.cdhistor
                   ,craplot.cdoperad
                   ,craplot.qtinfoln
                   ,craplot.vlcompcr
                   ,craplot.vlinfocr
                   ,craplot.vlcompdb
                   ,craplot.vlinfodb
                   ,craplot.rowid
               FROM craplot craplot
              WHERE craplot.cdcooper = pr_cdcooper
                AND craplot.dtmvtolt = pr_dtmvtolt
                AND craplot.cdagenci = pr_cdagenci
                AND craplot.cdbccxlt = pr_cdbccxlt
                AND craplot.nrdolote = pr_nrdolote;

  PROCEDURE pc_insere_lote(pr_cdcooper IN craplot.cdcooper%TYPE
                          ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                          ,pr_cdagenci IN craplot.cdagenci%TYPE
                          ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                          ,pr_nrdolote IN craplot.nrdolote%TYPE
                          ,pr_cdoperad IN craplot.cdoperad%TYPE
                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE
                          ,pr_tplotmov IN craplot.tplotmov%TYPE
                          ,pr_cdhistor IN craplot.cdhistor%TYPE
                          ,pr_craplot  OUT cr_craplot%ROWTYPE
                          ,pr_dscritic OUT VARCHAR2);

  /* Insere o lote mas nao atualiza, caso o mesmo exista - Projeto Revitalizacao*/
  PROCEDURE pc_insere_lote_rvt(pr_cdcooper IN craplot.cdcooper%TYPE
                              ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                              ,pr_cdagenci IN craplot.cdagenci%TYPE
                              ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                              ,pr_nrdolote IN craplot.nrdolote%TYPE
                              ,pr_cdoperad IN craplot.cdoperad%TYPE
                              ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE
                              ,pr_tplotmov IN craplot.tplotmov%TYPE
                              ,pr_cdhistor IN craplot.cdhistor%TYPE
                              ,pr_craplot  OUT cr_craplot_sem_lock%ROWTYPE
                              ,pr_dscritic OUT VARCHAR2);

END lote0001;
/
CREATE OR REPLACE PACKAGE BODY cecred.lote0001 IS

  -- Procedimento para inserir o lote e não deixar tabela lockada
  PROCEDURE pc_insere_lote(pr_cdcooper IN craplot.cdcooper%TYPE
                          ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                          ,pr_cdagenci IN craplot.cdagenci%TYPE
                          ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                          ,pr_nrdolote IN craplot.nrdolote%TYPE
                          ,pr_cdoperad IN craplot.cdoperad%TYPE
                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE
                          ,pr_tplotmov IN craplot.tplotmov%TYPE
                          ,pr_cdhistor IN craplot.cdhistor%TYPE
                          ,pr_craplot  OUT cr_craplot%ROWTYPE
                          ,pr_dscritic OUT VARCHAR2) IS
  /*..............................................................................
  
   Programa: LOTE0001
   Autor   : Odirlei
   Data    : 28/07/2015                        Ultima atualizacao: 
  
   Dados referentes ao programa: 
  
   Objetivo  : Package com as procedures necessárias para pagamento de guias DARF e DAS
  
   Alteracoes: 03/08/2016 - Procedure extraída da PAGA0001 para esta package. (Dionathan)
  ..............................................................................*/
  
    -- Pragma - abre nova sessao para tratar a atualizacao
    PRAGMA AUTONOMOUS_TRANSACTION;
    -- criar rowtype controle
    rw_craplot_ctl cr_craplot%ROWTYPE;
  
  BEGIN
  
    /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
    FOR i IN 1 .. 100 LOOP
      BEGIN
        -- Leitura do lote
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => pr_cdagenci
                       ,pr_cdbccxlt => pr_cdbccxlt
                       ,pr_nrdolote => pr_nrdolote);
        FETCH cr_craplot
        INTO rw_craplot_ctl;
        pr_dscritic := NULL;
        EXIT;
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_craplot%ISOPEN THEN
            CLOSE cr_craplot;
          END IF;
        
          -- setar critica caso for o ultimo
          IF i = 100 THEN
            pr_dscritic := pr_dscritic || 'Registro de lote ' ||
                           pr_nrdolote || ' em uso. Tente novamente.';
          END IF;
        
          -- aguardar 0,5 seg. antes de tentar novamente
          sys.dbms_lock.sleep(0.1);
      END;
    
    END LOOP;
  
    -- se encontrou erro ao buscar lote, abortar programa
    IF pr_dscritic IS NOT NULL THEN
      ROLLBACK;
      RETURN;
    END IF;
  
    IF cr_craplot%NOTFOUND THEN
      
      BEGIN
        -- criar registros de lote na tabela
        INSERT INTO craplot
          (craplot.cdcooper
          ,craplot.dtmvtolt
          ,craplot.cdagenci
          ,craplot.cdbccxlt
          ,craplot.nrdolote
          ,craplot.nrseqdig
          ,craplot.tplotmov
          ,craplot.cdoperad
          ,craplot.cdhistor
          ,craplot.nrdcaixa
          ,craplot.cdopecxa)
        VALUES
          (pr_cdcooper
          ,pr_dtmvtolt
          ,pr_cdagenci
          ,pr_cdbccxlt
          ,pr_nrdolote
          ,1 -- craplot.nrseqdig
          ,pr_tplotmov
          ,pr_cdoperad
          ,pr_cdhistor
          ,pr_nrdcaixa
          ,pr_cdoperad)
        RETURNING craplot.rowid
                 ,craplot.nrdolote
                 ,craplot.nrseqdig
                 ,craplot.cdbccxlt
                 ,craplot.tplotmov
                 ,craplot.dtmvtolt
                 ,craplot.cdagenci
                 ,craplot.cdhistor
                 ,craplot.cdoperad
                 ,craplot.qtcompln
                 ,craplot.qtinfoln
                 ,craplot.vlcompcr
                 ,craplot.vlinfocr
                 ,craplot.cdcooper
             INTO rw_craplot_ctl.rowid
                 ,rw_craplot_ctl.nrdolote
                 ,rw_craplot_ctl.nrseqdig
                 ,rw_craplot_ctl.cdbccxlt
                 ,rw_craplot_ctl.tplotmov
                 ,rw_craplot_ctl.dtmvtolt
                 ,rw_craplot_ctl.cdagenci
                 ,rw_craplot_ctl.cdhistor
                 ,rw_craplot_ctl.cdoperad
                 ,rw_craplot_ctl.qtcompln
                 ,rw_craplot_ctl.qtinfoln
                 ,rw_craplot_ctl.vlcompcr
                 ,rw_craplot_ctl.vlinfocr
                 ,rw_craplot_ctl.cdcooper;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception;
      END;
    
    ELSE
      -- ou atualizar o nrseqdig para reservar posição
      UPDATE craplot
         SET craplot.nrseqdig = NVL(craplot.nrseqdig, 0) + 1
       WHERE craplot.rowid = rw_craplot_ctl.rowid
      RETURNING craplot.nrseqdig
           INTO rw_craplot_ctl.nrseqdig;
    
    END IF;
  
    CLOSE cr_craplot;
  
    -- retornar informações para o programa chamador
    pr_craplot := rw_craplot_ctl;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF cr_craplot%ISOPEN THEN
        CLOSE cr_craplot;
      END IF;
    
      ROLLBACK;
      -- se ocorreu algum erro durante a criac?o
      pr_dscritic := 'Erro ao gravar craplot(' || pr_nrdolote || '): ' ||
                     SQLERRM;
  
  END pc_insere_lote;
  
  /* Insere o lote mas nao atualiza, caso o mesmo exista - Projeto Revitalizacao*/
  PROCEDURE pc_insere_lote_rvt(pr_cdcooper IN craplot.cdcooper%TYPE
                              ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                              ,pr_cdagenci IN craplot.cdagenci%TYPE
                              ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                              ,pr_nrdolote IN craplot.nrdolote%TYPE
                              ,pr_cdoperad IN craplot.cdoperad%TYPE
                              ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE
                              ,pr_tplotmov IN craplot.tplotmov%TYPE
                              ,pr_cdhistor IN craplot.cdhistor%TYPE
                              ,pr_craplot  OUT cr_craplot_sem_lock%ROWTYPE
                              ,pr_dscritic OUT VARCHAR2) IS
    /*..............................................................................
  
   Programa: LOTE0001
   Autor   : Heitor
   Data    : 20/09/2018                        Ultima atualizacao: 
  
   Dados referentes ao programa: 
  
   Objetivo  : Efetuar criacao de lote, caso o mesmo nao exista. Em caso de existencia, nao atualizar o mesmo.
  
   Alteracoes: 
  ..............................................................................*/
  
    -- Pragma - abre nova sessao para tratar a atualizacao
    PRAGMA AUTONOMOUS_TRANSACTION;
    -- criar rowtype controle
    rw_craplot_ctl cr_craplot_sem_lock%ROWTYPE;
  
  BEGIN
    -- Leitura do lote
    OPEN cr_craplot_sem_lock(pr_cdcooper => pr_cdcooper
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdagenci => pr_cdagenci
                            ,pr_cdbccxlt => pr_cdbccxlt
                            ,pr_nrdolote => pr_nrdolote);
    FETCH cr_craplot_sem_lock
    INTO rw_craplot_ctl;
    
    IF cr_craplot_sem_lock%NOTFOUND THEN
      
      BEGIN
      -- criar registros de lote na tabela
      INSERT INTO craplot
        (craplot.cdcooper
        ,craplot.dtmvtolt
        ,craplot.cdagenci
        ,craplot.cdbccxlt
        ,craplot.nrdolote
        ,craplot.nrseqdig
        ,craplot.tplotmov
        ,craplot.cdoperad
        ,craplot.cdhistor
        ,craplot.nrdcaixa
        ,craplot.cdopecxa)
      VALUES
        (pr_cdcooper
        ,pr_dtmvtolt
        ,pr_cdagenci
        ,pr_cdbccxlt
        ,pr_nrdolote
        ,0 -- craplot.nrseqdig
        ,pr_tplotmov
        ,pr_cdoperad
        ,pr_cdhistor
        ,pr_nrdcaixa
        ,pr_cdoperad)
      RETURNING craplot.rowid
               ,craplot.nrdolote
               ,craplot.nrseqdig
               ,craplot.cdbccxlt
               ,craplot.tplotmov
               ,craplot.dtmvtolt
               ,craplot.cdagenci
               ,craplot.cdhistor
               ,craplot.cdoperad
               ,craplot.qtcompln
               ,craplot.qtinfoln
               ,craplot.vlcompcr
               ,craplot.vlinfocr
               ,craplot.cdcooper
           INTO rw_craplot_ctl.rowid
               ,rw_craplot_ctl.nrdolote
               ,rw_craplot_ctl.nrseqdig
               ,rw_craplot_ctl.cdbccxlt
               ,rw_craplot_ctl.tplotmov
               ,rw_craplot_ctl.dtmvtolt
               ,rw_craplot_ctl.cdagenci
               ,rw_craplot_ctl.cdhistor
               ,rw_craplot_ctl.cdoperad
               ,rw_craplot_ctl.qtcompln
               ,rw_craplot_ctl.qtinfoln
               ,rw_craplot_ctl.vlcompcr
               ,rw_craplot_ctl.vlinfocr
               ,rw_craplot_ctl.cdcooper;
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
      END;
    END IF;
  
    CLOSE cr_craplot_sem_lock;
  
    -- retornar informações para o programa chamador
    pr_craplot := rw_craplot_ctl;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF cr_craplot_sem_lock%ISOPEN THEN
        CLOSE cr_craplot_sem_lock;
      END IF;
    
      ROLLBACK;
      -- se ocorreu algum erro durante a criac?o
      pr_dscritic := 'Erro ao gravar craplot(' || pr_nrdolote || '): ' ||
                     SQLERRM;
  END pc_insere_lote_rvt;

END lote0001;
/
