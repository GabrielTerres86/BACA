DECLARE
  vr_nrseqdig     craplot.nrseqdig%type;
  taxa_fixa       NUMBER;
  datainicial     DATE;
  saldo_final     NUMBER (12,2);
  pr_txprodia     NUMBER (9,8);
  contratado      NUMBER (11,10);
  rendimento      NUMBER (12,2);
  pr_vllanmto     NUMBER (12,2);
  vr_qtdiaute     NUMBER;
  vr_dtfimper     DATE;
  vr_cdcritic     NUMBER;
  vr_dscritic     VARCHAR(4000);
  datafimper      DATE;
  valorir         NUMBER (12,2);
  valorirpag      NUMBER (12,2);
  rendimentopag   NUMBER (12,2);
  rendimentomes   NUMBER (12,2);
  vr_flagresgatcc NUMBER;
  vr_datafimcalc  DATE;
  vr_cdprograma   VARCHAR2(50) := 'SCRIPT-RDC';
  vr_idprglog     NUMBER;
  rw_crapdat      btch0001.cr_crapdat%rowtype;
  diamvtolt       number;
  pr_feriado      BOOLEAN DEFAULT TRUE;
  pr_excultdia    BOOLEAN ;
  vr_exc_erro     EXCEPTION;
  vr_nrdocmto     NUMBER;
  vr_tab_retorno  LANC0001.typ_reg_retorno;
  vr_incrineg     INTEGER; 
  vr_dslog     tbgen_prglog_ocorrencia.dsmensagem%TYPE;

  CURSOR cr_craprda IS
    SELECT a.cdcooper,
           a.nrdconta,
           a.nraplica,
           a.dtcalcul,
           a.vlsdrdca,
           a.dtfimper,
           a.dtrefatu,
           a.dtmvtolt,
           a.rowid,
           (CASE WHEN a.nrdconta = 97933740 THEN 98 ELSE 93 END) taxafixa
      FROM cecred.craprda a
     WHERE a.cdcooper = 1
       AND ((a.nrdconta = 97933740 AND nraplica =  167087) OR
            (a.nrdconta = 97976750 AND nraplica in (244856, 188035)));
    rw_craprda cr_craprda%ROWTYPE;    

  CURSOR cr_craplap(pr_cdcooper IN craplap.cdcooper%TYPE
                   ,pr_nrdconta IN craplap.nrdconta%TYPE
                   ,pr_nraplica IN craplap.nraplica%TYPE) IS 
    SELECT SUM(decode(his.indebcre, 'D', -1, 1) * lac.vllanmto) vllanmto
             FROM cecred.craphis his
                 ,cecred.craplap lac
             WHERE his.cdhistor = lac.cdhistor
               AND his.cdcooper = lac.cdcooper
               AND lac.dtmvtolt <= to_date(SYSDATE)
               AND lac.nraplica = pr_nraplica
               AND lac.nrdconta = pr_nrdconta
               AND lac.cdcooper = pr_cdcooper
               AND lac.cdhistor NOT IN (180,866,182);
     rw_craplap cr_craplap%ROWTYPE; 

BEGIN

      OPEN BTCH0001.cr_crapdat(pr_cdcooper => 1);
      
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;          

      CLOSE BTCH0001.cr_crapdat;
        
  FOR rw_craprda IN cr_craprda LOOP
    datafimper    := sistema.validarDiaUtil(pr_cdcooper  => 1,
                                            pr_dtmvtolt  => rw_craprda.dtfimper,
                                            pr_tipo      => 'P',
                                            pr_feriado   => pr_feriado,
                                            pr_excultdia => pr_excultdia);

    vr_dslog := 'update craprda set  dtcalcul = ' || rw_craprda.dtcalcul 
                                                  || ' ,vlsdrdca = ' || rw_craprda.vlsdrdca 
                                                  || ' ,dtfimper = ' || rw_craprda.dtfimper
                                                  || ' where rowid = '|| rw_craprda.rowid;
                   
                    
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => vr_dslog,
                           pr_cdmensagem => 111,
                           pr_cdprograma => vr_cdprograma,
                           pr_cdcooper   => 3,
                           pr_idprglog   => vr_idprglog);                                            
                           
    datainicial   := rw_craprda.dtcalcul + 1;
    saldo_final   := rw_craprda.vlsdrdca;
    taxa_fixa     := rw_craprda.taxafixa;
    valorirpag    := 0;
    rendimentopag := 0;
    diamvtolt     := EXTRACT( day from rw_craprda.dtfimper);
    
    OPEN cr_craplap (pr_cdcooper => rw_craprda.cdcooper
                    ,pr_nrdconta => rw_craprda.nrdconta
                    ,pr_nraplica => rw_craprda.nraplica);
    
    FETCH cr_craplap INTO rw_craplap;
    IF rw_craplap.vllanmto > 0 THEN
      vr_flagresgatcc := 0;
      vr_datafimcalc  := rw_crapdat.dtmvtolt;
    ELSE 
      vr_flagresgatcc := 1;
      vr_datafimcalc  := rw_craprda.dtrefatu;
    END IF;
    CLOSE cr_craplap;
    
    WHILE datafimper <= vr_datafimcalc LOOP
      rendimentomes := 0;

      WHILE datainicial <= datafimper LOOP
                         
        IF to_char(datainicial, 'D') NOT IN (1, 7) AND
          NOT flxf0001.fn_verifica_feriado(rw_craprda.cdcooper, datainicial) THEN
        
          apli0004.pc_calcula_qt_dias_uteis(rw_craprda.cdcooper, datainicial, vr_qtdiaute, vr_dtfimper, vr_cdcritic, vr_dscritic);
        
          SELECT txofidia INTO pr_txprodia
            FROM cecred.craptrd   
           WHERE dtiniper = datainicial
             AND cdcooper = 1
             AND vlfaixas = 50000
             AND dtfimper = vr_dtfimper
             AND tptaxrda = 2;
   
          contratado := (taxa_fixa/100) * (pr_txprodia/100);
          rendimento := contratado * saldo_final;
          saldo_final := saldo_final + rendimento;
          rendimentomes := rendimentomes + rendimento;
          
        END IF;
     
        DataInicial := DataInicial + 1;
     
      END LOOP;
   
      valorir       := rendimentomes * 0.15;
      rendimentopag := rendimentopag + rendimentomes;
      valorirpag    := valorirpag + valorir;
      saldo_final := saldo_final - valorir;
      datafimper := to_date(diamvtolt || '/' || to_char(ADD_MONTHS(datainicial,1),'MM/YYYY'),'DD/MM/YYYY');
      datafimper := sistema.validarDiaUtil(pr_cdcooper  => 1,
                                           pr_dtmvtolt  => datafimper,
                                           pr_tipo      => 'P',
                                           pr_feriado   => pr_feriado,
                                           pr_excultdia => pr_excultdia);
      
      SELECT nvl(SUM(vllanmto),0) INTO pr_vllanmto
        FROM cecred.craplap 
       WHERE cdcooper = 1
         AND nrdconta = rw_craprda.nrdconta
         AND nraplica = rw_craprda.nraplica
         AND cdhistor = 494
         AND dtmvtolt between (to_date(datainicial) -1) and (to_date(datafimper) - 1);
            
      saldo_final := saldo_final - pr_vllanmto;
      
    END LOOP;
    IF vr_flagresgatcc = 0 THEN 
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_craprda.cdcooper||';'
                                 ||to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'
                                 ||1||';'
                                 ||100||';'
                                 ||10106);
      
      BEGIN
        INSERT INTO cecred.craplap(cdcooper
                           ,dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,nrdconta
                           ,nraplica
                           ,nrdocmto
                           ,txaplica
                           ,txaplmes
                           ,cdhistor
                           ,nrseqdig
                           ,vllanmto
                           ,dtrefere
                           ,vlrenacu
                           ,vlslajir)
                     VALUES(rw_craprda.cdcooper
                           ,rw_crapdat.dtmvtolt
                           ,1
                           ,100
                           ,10106
                           ,rw_craprda.nrdconta
                           ,rw_craprda.nraplica
                           ,vr_nrseqdig
                           ,valorirpag
                           ,valorirpag
                           ,862
                           ,vr_nrseqdig
                           ,valorirpag
                           ,rw_crapdat.dtmvtolt
                           ,0
                           ,0);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao criar lancamento de debito de IR na aplicacao (CRAPLAP) '
                         || '- Conta:'||rw_craprda.nrdconta || ' Aplicacao:'||rw_craprda.nraplica
                         || '. Detalhes: '||sqlerrm;
          RAISE vr_exc_erro;
      END;
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_craprda.cdcooper||';'
                                 ||to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'
                                 ||1||';'
                                 ||100||';'
                                 ||10106);
      
      BEGIN
        INSERT INTO cecred.craplap(cdcooper
                           ,dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,nrdconta
                           ,nraplica
                           ,nrdocmto
                           ,txaplica
                           ,txaplmes
                           ,cdhistor
                           ,nrseqdig
                           ,vllanmto
                           ,dtrefere
                           ,vlsdlsap
                           ,vlrenacu
                           ,vlslajir)
                     VALUES(rw_craprda.cdcooper
                           ,rw_crapdat.dtmvtolt
                           ,1
                           ,100
                           ,10106
                           ,rw_craprda.nrdconta
                           ,rw_craprda.nraplica
                           ,vr_nrseqdig
                           ,rw_craprda.taxafixa
                           ,rw_craprda.taxafixa
                           ,179
                           ,vr_nrseqdig
                           ,rendimentopag
                           ,rw_crapdat.dtmvtolt
                           ,saldo_final
                           ,saldo_final
                           ,valorirpag);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao criar lancamento da capitalizacao na aplicacao (CRAPLAP) '
                      || '- Conta:'||rw_craprda.nrdconta || ' Aplicacao:'||rw_craprda.nraplica
                      || '. Detalhes: '||sqlerrm;
          RAISE vr_exc_erro;
      END;
      
      BEGIN
        UPDATE cecred.craprda
           SET dtsdrdan = rw_craprda.dtcalcul
              ,vlsdrdan = rw_craprda.vlsdrdca
              ,dtiniext = to_date(datainicial) -1
              ,dtfimext = datafimper
              ,dtiniper = to_date(datainicial) -1
              ,dtfimper = datafimper
              ,vlsdrdca = saldo_final
              ,dtcalcul = to_date(datainicial) -1
              ,cdagenci = 202
              ,incalmes = 0
         WHERE rowid = rw_craprda.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar aplicacao (craprda) - Conta:'||rw_craprda.nrdconta || ' Aplicacao:'||rw_craprda.nraplica
                         || '. Detalhes: '||sqlerrm;
        RAISE vr_exc_erro;
      END;
    ELSE
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_craprda.cdcooper||';'
                                 ||to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'
                                 ||1||';'
                                 ||100||';'
                                 ||10106);
      vr_nrdocmto := 10106 || rw_craprda.nraplica;
      
      cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => rw_craprda.cdcooper
                                               ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                               ,pr_dtrefere    => rw_crapdat.dtmvtolt
                                               ,pr_cdagenci    => 1
                                               ,pr_cdbccxlt    => 100
                                               ,pr_nrdolote    => 10106
                                               ,pr_nrdconta    => rw_craprda.nrdconta
                                               ,pr_nrdctabb    => rw_craprda.nrdconta
                                               ,pr_nrdctitg    => TO_CHAR(cecred.gene0002.fn_mask(rw_craprda.nrdconta,'99999999'))
                                               ,pr_nrdocmto    => vr_nrdocmto
                                               ,pr_cdhistor    => 362
                                               ,pr_vllanmto    => saldo_final
                                               ,pr_nrseqdig    => vr_nrseqdig
                                               ,pr_tab_retorno => vr_tab_retorno
                                               ,pr_incrineg    => vr_incrineg
                                               ,pr_cdcritic    => vr_cdcritic
                                               ,pr_dscritic    => vr_dscritic);
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      UPDATE cecred.craprda
         SET vlsdrdca = 0
            ,insaqtot = 1
            ,dtsaqtot = rw_craprda.dtrefatu
       WHERE rowid = rw_craprda.rowid;                                        
    END IF;
  END LOOP;
  COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dscritic,
                             pr_cdmensagem => 222,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog); 
      ROLLBACK;
    WHEN OTHERS THEN
      vr_dscritic := 'Erro nao especificado! ' || SQLERRM;
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dscritic,
                             pr_cdmensagem => 333,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog); 
      ROLLBACK;  

END;
