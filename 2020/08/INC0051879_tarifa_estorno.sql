DECLARE 

  vr_nrincrem INTEGER;
  vr_cdcritic INTEGER;
  pr_nrdolote INTEGER;
  pr_cdbccxlt INTEGER;  
  pr_cdhistor INTEGER;
  pr_nrseqdig INTEGER;
  pr_vllanmto craplat.vltarifa%TYPE; 
  vr_exc_erro EXCEPTION;
  vr_dscritic   VARCHAR2(5000) := ' ';
  vr_craplcm_rowid ROWID;
  vr_tbcotas_devolucao_rowid ROWID;
  vr_tab_retorno   lanc0001.typ_reg_retorno;
  vr_incrineg      NUMBER;
  vr_nmarqimp1       VARCHAR2(100)  := 'erro.txt';
  vr_ind_arquiv1     utl_file.file_type;
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0051879_estorno_tarifa'; 
  
  CURSOR cr_crapdat (pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt,
           dat.dtmvtopr,
           dat.dtmvtoan,
           dat.inproces,
           dat.qtdiaute,
           dat.cdprgant,
           dat.dtmvtocd,
           trunc(dat.dtmvtolt,'mm')               dtinimes, 
           trunc(Add_Months(dat.dtmvtolt,1),'mm') dtpridms, 
           last_day(add_months(dat.dtmvtolt,-1))  dtultdma, 
           last_day(dat.dtmvtolt)                 dtultdia, 
           rowid
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%ROWTYPE;
    
  CURSOR cr_tbcotas_devolucao (pr_cdcooper IN tbcotas_devolucao.cdcooper%TYPE
                              ,pr_nrdconta IN tbcotas_devolucao.nrdconta%TYPE) IS
    SELECT     tb.nrdconta
              ,tb.vlcapital
              ,tb.cdcooper
              ,tb.tpdevolucao
         FROM tbcotas_devolucao tb
        WHERE tb.cdcooper = pr_cdcooper
          AND tb.nrdconta = pr_nrdconta
          AND tb.tpdevolucao = 4;  
       rw_tbcotas_devolucao cr_tbcotas_devolucao%ROWTYPE;        

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
          ,craplot.qtinfoln
          ,craplot.vlcompcr
          ,craplot.vlinfocr
          ,craplot.vlcompdb
          ,craplot.vlinfodb
          ,craplot.tplotmov
          ,craplot.rowid
          ,craplot.progress_recid
      FROM craplot craplot
     WHERE craplot.cdcooper = pr_cdcooper
       AND craplot.dtmvtolt = pr_dtmvtolt
       AND craplot.cdagenci = pr_cdagenci
       AND craplot.cdbccxlt = pr_cdbccxlt
       AND craplot.nrdolote = pr_nrdolote;
    rw_craplot cr_craplot%ROWTYPE; 


  CURSOR cr_lanc_tarifas IS
    SELECT ass.inpessoa
          ,ass.cdagenci
          ,lat.nrdocmto
          ,lat.nrdconta
          ,lat.vltarifa
          ,lat.cdcooper 
          ,lat.dtefetiv
          ,lat.cdlantar 
     FROM craplat lat, crapass ass
    WHERE lat.cdcooper = ass.cdcooper
      AND lat.nrdconta = ass.nrdconta
      AND lat.cdlantar in (56033321, 56018232, 56018233
                          ,56018235, 56018228, 56018234
                          ,56018230, 56018229, 56273900
                          ,56018231)
      order by lat.cdlantar;   
    rw_lanc_tarifas cr_lanc_tarifas%ROWTYPE;  
      
  PROCEDURE erro (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
  END; 
  
  PROCEDURE fecha_arquivos IS
  BEGIN
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
  END;
  
  --INICIO
BEGIN   
   --Criar arquivo
   gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                           ,pr_nmarquiv => vr_nmarqimp1       --> Nome do arquivo
                           ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                           ,pr_utlfileh => vr_ind_arquiv1     --> handle do arquivo aberto
                           ,pr_des_erro => vr_dscritic);      --> erro
   -- em caso de crítica
   IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exc_erro;
   END IF;         
   
   FOR rw_lanc_tarifas IN cr_lanc_tarifas LOOP
           
     OPEN cr_crapdat (pr_cdcooper => rw_lanc_tarifas.cdcooper);
      FETCH cr_crapdat INTO rw_crapdat;
     CLOSE cr_crapdat;
        --Se nao foi efetivado somente dar baixa
     IF rw_lanc_tarifas.dtefetiv IS NULL THEN
       BEGIN    
         UPDATE craplat lat
            SET lat.DTREFATU = rw_crapdat.dtmvtolt,
                lat.CDMOTEST = 1,
                lat.DTDESTOR = rw_crapdat.dtmvtolt,
                lat.CDOPEEST = '1',
                lat.INSITLAT = 3 
          WHERE lat.cdlantar = rw_lanc_tarifas.cdlantar;
         EXCEPTION
         WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar craplat.';
          erro('craplat - Conta ' || rw_lanc_tarifas.nrdconta || ' - Lancamento: ' || rw_lanc_tarifas.cdlantar );
         RAISE vr_exc_erro;
       END;       
     ELSE
       --Se foi efetivado estornar o valor
       BEGIN
         UPDATE craplat lat
           SET  lat.DTREFATU = rw_crapdat.dtmvtolt,
                lat.CDMOTEST = 1,
                lat.DTDESTOR = rw_crapdat.dtmvtolt,
                lat.CDOPEEST = '1',
                lat.INSITLAT = 4 
          WHERE lat.cdlantar = rw_lanc_tarifas.cdlantar;
         EXCEPTION
         WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar craplat.';
          erro('craplat - Conta ' || rw_lanc_tarifas.nrdconta || ' - Lancamento: ' || rw_lanc_tarifas.cdlantar );
         RAISE vr_exc_erro;
       END;
       --lancamento credito
       pr_nrdolote := 10514;
       vr_nrincrem := 1;
       pr_cdbccxlt := 100;
       pr_cdhistor := 1214;
       pr_vllanmto := rw_lanc_tarifas.vltarifa;
     
       OPEN cr_craplot(pr_cdcooper => rw_lanc_tarifas.cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                      ,pr_cdagenci => rw_lanc_tarifas.cdagenci
                      ,pr_cdbccxlt => pr_cdbccxlt
                      ,pr_nrdolote => pr_nrdolote);

       FETCH cr_craplot
       INTO rw_craplot;
       --Se não encontrou registro
       IF cr_craplot%NOTFOUND THEN
          --Fechar Cursor
         CLOSE cr_craplot;

         /*Total de valores computados a credito no lote*/
         rw_craplot.vlcompcr := (pr_vllanmto );
         /*Total de valores a credito do lote.*/
         rw_craplot.vlinfocr := (pr_vllanmto);
         /*Total de valores computados a debito no lote.*/
         rw_craplot.vlcompdb := 0;
         /*Total de valores a debito do lote.*/
         rw_craplot.vlinfodb := 0;
         
         --Criar lote
         BEGIN
           INSERT INTO craplot
              (craplot.cdcooper
              ,craplot.dtmvtolt
              ,craplot.cdagenci
              ,craplot.cdbccxlt
              ,craplot.nrdolote
              ,craplot.tplotmov
              ,craplot.cdoperad
              ,craplot.cdhistor
              ,craplot.dtmvtopg
              ,craplot.nrseqdig
              ,craplot.qtcompln
              ,craplot.qtinfoln
              ,craplot.vlcompcr
              ,craplot.vlinfocr
              ,craplot.vlcompdb
              ,craplot.vlinfodb)
           VALUES
              (rw_lanc_tarifas.cdcooper
              ,rw_crapdat.dtmvtolt
              ,rw_lanc_tarifas.cdagenci
              ,pr_cdbccxlt
              ,pr_nrdolote
              ,1
              ,1
              ,0
              ,rw_crapdat.dtmvtolt
              ,1
              ,vr_nrincrem
              ,vr_nrincrem
              ,rw_craplot.vlcompcr
              ,rw_craplot.vlinfocr
              ,rw_craplot.vlcompdb
              ,rw_craplot.vlinfodb)
           RETURNING craplot.nrseqdig, ROWID INTO pr_nrseqdig, rw_craplot.rowid;
           EXCEPTION
            WHEN Dup_Val_On_Index THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Lote ja cadastrado.';
              erro('craplot - lOTE ' || pr_nrdolote || ' - Lancamento: ' || rw_craplot.vlinfocr || ' - ' ||rw_craplot.vlcompcr || vr_dscritic);
              RAISE vr_exc_erro;
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir na tabela de lotes. ' || sqlerrm;
              erro('craplot - lOTE ' || pr_nrdolote || ' - Lancamento: ' || rw_craplot.vlinfocr || ' - '|| rw_craplot.vlcompcr || vr_dscritic);                                    
            RAISE vr_exc_erro;
         END;
      
       ELSE
          --Fechar Cursor
          CLOSE cr_craplot;
          --Incrementar Sequencial
          rw_craplot.nrseqdig := nvl(rw_craplot.nrseqdig, 0) + 1;
          /*Quantidade computada de lancamentos.*/
          rw_craplot.qtcompln := nvl(rw_craplot.qtcompln, 0) + 1;
          /*Quantidade de lancamentos do lote.*/
          rw_craplot.qtinfoln := nvl(rw_craplot.qtinfoln, 0) + 1;

          /*Total de valores computados a credito no lote*/
          rw_craplot.vlcompcr := nvl(rw_craplot.vlcompcr, 0) + (pr_vllanmto );
          /*Total de valores a credito do lote.*/
          rw_craplot.vlinfocr := nvl(rw_craplot.vlinfocr, 0) + (pr_vllanmto );
        

          --Atualizar Lote
          BEGIN
            UPDATE craplot
               SET craplot.nrseqdig = rw_craplot.nrseqdig
                  ,craplot.qtcompln = rw_craplot.qtcompln
                  ,craplot.qtinfoln = rw_craplot.qtinfoln
                  ,craplot.vlcompcr = rw_craplot.vlcompcr
                  ,craplot.vlinfocr = rw_craplot.vlinfocr
                  ,craplot.vlcompdb = rw_craplot.vlcompdb
                  ,craplot.vlinfodb = rw_craplot.vlinfodb
             WHERE craplot.rowid = rw_craplot.rowid
            RETURNING rw_craplot.nrseqdig INTO pr_nrseqdig;
           
            EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar lote. ' || SQLERRM;
              erro('craplot - lOTE ' || pr_nrdolote || ' - Lancamento: ' || rw_craplot.vlinfocr || ' - ' ||rw_craplot.vlcompcr || vr_dscritic);
            RAISE vr_exc_erro;
          END;
       END IF;

       --Fechar Cursor
       IF cr_craplot%ISOPEN THEN
         CLOSE cr_craplot;
       END IF;
       
       BEGIN
            lanc0001.pc_gerar_lancamento_conta (pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                , pr_cdagenci => rw_lanc_tarifas.cdagenci
                                                , pr_cdbccxlt => pr_cdbccxlt
                                                , pr_nrdolote => pr_nrdolote
                                                , pr_nrdconta => rw_lanc_tarifas.nrdconta
                                                , pr_nrdocmto => rw_lanc_tarifas.nrdocmto
                                                , pr_cdhistor => pr_cdhistor --decode(rw_crapass.inpessoa,1,2061,2062)
                                                , pr_nrseqdig => pr_nrseqdig
                                                , pr_vllanmto => pr_vllanmto --vr_vldescto
                                                , pr_nrdctabb => rw_lanc_tarifas.nrdconta
                                                , pr_cdpesqbb => 'MANCCF'
                                                , pr_cdcooper => rw_lanc_tarifas.cdcooper
                                                , pr_nrdctitg => gene0002.fn_mask(rw_lanc_tarifas.nrdconta,'99999999')
                                                , pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                                , pr_incrineg  => vr_incrineg      -- OUT Indicador de crítica de negócio
                                                , pr_cdcritic  => vr_cdcritic      -- OUT
                                                , pr_dscritic  => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)
              
      IF nvl(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
                 -- Se vr_incrineg = 0, se trata de um erro de Banco de Dados e deve abortar a sua execução            
                    vr_dscritic := 'Problemas ao criar lancamento:'||vr_dscritic;
                    erro('tbcotas_devolucao - Conta ' || rw_lanc_tarifas.nrdconta || ' - Documento: ' || rw_lanc_tarifas.nrdocmto || ' - ' || vr_dscritic);
                --Sair do programa
                RAISE vr_exc_erro;
              END IF; 
       
       END;            
    ----------------------------------------------------------------------------------
       --LANCAMENTO DE DEBITO - CRPS093
       pr_nrdolote := 7200;
       vr_nrincrem := 1;
       pr_cdbccxlt := 100;
       pr_cdhistor := CASE WHEN rw_lanc_tarifas.inpessoa = 1 THEN 2061 ELSE 2062 END;

                      
       OPEN cr_craplot(pr_cdcooper => rw_lanc_tarifas.cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                      ,pr_cdagenci => 1
                      ,pr_cdbccxlt => pr_cdbccxlt
                      ,pr_nrdolote => pr_nrdolote);

       FETCH cr_craplot
       INTO rw_craplot;
        --Se não encontrou registro
       IF cr_craplot%NOTFOUND THEN
          --Fechar Cursor
         CLOSE cr_craplot;
 
         /*Total de valores computados a credito no lote*/
         rw_craplot.vlcompcr := (pr_vllanmto);
         /*Total de valores a credito do lote.*/
         rw_craplot.vlinfocr := (pr_vllanmto);
         /*Total de valores computados a debito no lote.*/ 
         rw_craplot.vlcompdb := 0;
         /*Total de valores a debito do lote.*/
         rw_craplot.vlinfodb := 0;
         
         --Criar lote
         BEGIN 
           INSERT INTO craplot
              (craplot.cdcooper
              ,craplot.dtmvtolt
              ,craplot.cdagenci
              ,craplot.cdbccxlt
              ,craplot.nrdolote
              ,craplot.tplotmov
              ,craplot.cdoperad
              ,craplot.cdhistor
              ,craplot.dtmvtopg
              ,craplot.nrseqdig
              ,craplot.qtcompln
              ,craplot.qtinfoln
              ,craplot.vlcompcr
              ,craplot.vlinfocr
              ,craplot.vlcompdb
              ,craplot.vlinfodb)
           VALUES
              (rw_lanc_tarifas.cdcooper
              ,rw_crapdat.dtmvtolt
              ,1
              ,pr_cdbccxlt
              ,pr_nrdolote
              ,1
              ,1
              ,0
              ,rw_crapdat.dtmvtolt
              ,1
              ,vr_nrincrem
              ,vr_nrincrem
              ,rw_craplot.vlcompcr
              ,rw_craplot.vlinfocr
              ,rw_craplot.vlcompdb
              ,rw_craplot.vlinfodb)
           RETURNING craplot.nrseqdig, ROWID INTO pr_nrseqdig, rw_craplot.rowid;
           EXCEPTION
             WHEN Dup_Val_On_Index THEN
               vr_cdcritic := 0;
               vr_dscritic := 'Lote ja cadastrado.';
               erro('craplot - lOTE ' || pr_nrdolote || ' - Lancamento: ' || rw_craplot.vlinfocr || ' - ' ||rw_craplot.vlcompcr || vr_dscritic);
               RAISE vr_exc_erro;
             WHEN OTHERS THEN
               vr_cdcritic := 0;
               vr_dscritic := 'Erro ao inserir na tabela de lotes. ' ||sqlerrm;
               erro('craplot - lOTE ' || pr_nrdolote || ' - Lancamento: ' || rw_craplot.vlinfocr || ' - ' ||rw_craplot.vlcompcr || vr_dscritic);
               RAISE vr_exc_erro;
         END;
       ELSE
         --Fechar Cursor
         CLOSE cr_craplot;
         --Incrementar Sequencial
         rw_craplot.nrseqdig := nvl(rw_craplot.nrseqdig, 0) + 1;
         /*Quantidade computada de lancamentos.*/
         rw_craplot.qtcompln := nvl(rw_craplot.qtcompln, 0) + 1;
         /*Quantidade de lancamentos do lote.*/
         rw_craplot.qtinfoln := nvl(rw_craplot.qtinfoln, 0) + 1;
         /*Total de valores computados a credito no lote*/
         rw_craplot.vlcompcr := nvl(rw_craplot.vlcompcr, 0) + (pr_vllanmto);
         /*Total de valores a credito do lote.*/
         rw_craplot.vlinfocr := nvl(rw_craplot.vlinfocr, 0) + (pr_vllanmto);
         

         --Atualizar Lote
         BEGIN          
           UPDATE craplot
             SET craplot.nrseqdig = rw_craplot.nrseqdig
                ,craplot.qtcompln = rw_craplot.qtcompln
                ,craplot.qtinfoln = rw_craplot.qtinfoln
                ,craplot.vlcompcr = rw_craplot.vlcompcr
                ,craplot.vlinfocr = rw_craplot.vlinfocr
                ,craplot.vlcompdb = rw_craplot.vlcompdb
                ,craplot.vlinfodb = rw_craplot.vlinfodb
           WHERE craplot.rowid = rw_craplot.rowid
           RETURNING rw_craplot.nrseqdig INTO pr_nrseqdig;
           
           EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar lote. ' || SQLERRM;
              erro('craplot - lOTE ' || pr_nrdolote || ' - Lancamento: ' || rw_craplot.vlinfocr || ' - ' ||rw_craplot.vlcompcr || vr_dscritic);
              RAISE vr_exc_erro;
         END;
       END IF;

       --Fechar Cursor
       IF cr_craplot%ISOPEN THEN
         CLOSE cr_craplot;
       END IF;
               
            BEGIN
              lanc0001.pc_gerar_lancamento_conta (pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                , pr_cdagenci => 1
                                                , pr_cdbccxlt => pr_cdbccxlt
                                                , pr_nrdolote => pr_nrdolote
                                                , pr_nrdconta => rw_lanc_tarifas.nrdconta
                                                , pr_nrdocmto => pr_nrdolote ||rw_craplot.nrseqdig
                                                , pr_cdhistor => pr_cdhistor --decode(rw_crapass.inpessoa,1,2061,2062)
                                                , pr_nrseqdig => pr_nrseqdig
                                                , pr_vllanmto => pr_vllanmto --vr_vldescto
                                                , pr_nrdctabb => rw_lanc_tarifas.nrdconta
                                                , pr_cdpesqbb => ' '
                                                , pr_cdcooper => rw_lanc_tarifas.cdcooper
                                                , pr_nrdctitg => gene0002.fn_mask(rw_lanc_tarifas.nrdconta,'99999999')
                                                , pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                                , pr_incrineg  => vr_incrineg      -- OUT Indicador de crítica de negócio
                                                , pr_cdcritic  => vr_cdcritic      -- OUT
                                                , pr_dscritic  => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)
              
              IF nvl(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
                 -- Se vr_incrineg = 0, se trata de um erro de Banco de Dados e deve abortar a sua execução            
                    vr_dscritic := 'Problemas ao criar lancamento:'||vr_dscritic;
                    erro('tbcotas_devolucao - Conta ' || rw_lanc_tarifas.nrdconta || ' - Documento: ' || rw_lanc_tarifas.nrdocmto || ' - ' || vr_dscritic);
                --Sair do programa
                RAISE vr_exc_erro;
              END IF; 
            END;       
           
               
               ------------------------------------------------------------------------ 
     
      
       OPEN cr_tbcotas_devolucao (pr_cdcooper => rw_lanc_tarifas.cdcooper
                                 ,pr_nrdconta => rw_lanc_tarifas.nrdconta);
       FETCH cr_tbcotas_devolucao INTO rw_tbcotas_devolucao;

       --Se não encontrou registro
       IF cr_tbcotas_devolucao%NOTFOUND THEN
         --Fechar Cursor
         CLOSE cr_tbcotas_devolucao;
           BEGIN 
             INSERT INTO tbcotas_devolucao (cdcooper,
                                            nrdconta,
                                            tpdevolucao,
                                            vlcapital)
                                    VALUES (rw_lanc_tarifas.cdcooper
                                           ,rw_lanc_tarifas.nrdconta
                                           ,4 
                                           ,nvl(pr_vllanmto,0))
             RETURNING
             tbcotas_devolucao.rowid
             INTO vr_tbcotas_devolucao_rowid;
             EXCEPTION
               WHEN OTHERS THEN
               vr_dscritic := 'Erro na insercao tbcotas_devolucao: '||rw_lanc_tarifas.cdcooper||' '||rw_lanc_tarifas.nrdconta||' '|| rw_lanc_tarifas.nrdocmto || ' ' ||sqlerrm;
               erro('tbcotas_devolucao - Conta ' || rw_lanc_tarifas.nrdconta || ' - Documento: ' || rw_lanc_tarifas.nrdocmto || ' - ' || vr_dscritic);
               RAISE vr_exc_erro;  
           END;                               
       ELSE
         BEGIN
           UPDATE tbcotas_devolucao
              SET vlcapital   = vlcapital + nvl(pr_vllanmto,0)
            WHERE cdcooper    = rw_lanc_tarifas.cdcooper
              AND nrdconta    = rw_lanc_tarifas.nrdconta
              AND tpdevolucao = 4;
           EXCEPTION
             WHEN OTHERS THEN
             vr_dscritic := 'Erro ao atualizar tbcotas_devolucao.';
             erro('tbcotas_devolucao - Conta ' || rw_lanc_tarifas.nrdconta || ' - Documento: ' ||rw_lanc_tarifas.nrdocmto || ' - ' || vr_dscritic);
             RAISE vr_exc_erro;
         END;
         CLOSE cr_tbcotas_devolucao;
                  
       END IF;
     END IF; 
   END LOOP;    
   COMMIT; 
   fecha_arquivos;
  
   EXCEPTION
    WHEN vr_exc_erro THEN    
      vr_cdcritic := vr_cdcritic;
      vr_dscritic := vr_dscritic;
      fecha_arquivos;
    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro na conta' || rw_lanc_tarifas.nrdconta|| sqlerrm;
      fecha_arquivos;
     ROLLBACK;
END;
