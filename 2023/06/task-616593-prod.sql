DECLARE

  vr_cdcritic crapcri.cdcritic%TYPE;
  pr_dscritic VARCHAR2(4000);
  vr_dscritic VARCHAR2(4000);
  rw_crapdat    btch0001.cr_crapdat%ROWTYPE;
  pr_cdcritic crapcri.cdcritic%TYPE;
  vr_incrineg     INTEGER;
  vr_idprglog   tbgen_prglog.idprglog%TYPE := 0;
  pr_nrdolote     craplot.nrdolote%TYPE := 800039;
  pr_cdprograma VARCHAR2(100) := 'INC0276817-2';
  vr_exc_saida EXCEPTION;
   vr_dslog VARCHAR2(4000) := '';
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta
          ,ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

  CURSOR cr_crapsdc(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT sdc.dtdebito,
           sdc.vllanmto,
           sdc.indebito
      FROM cecred.crapsdc sdc
     WHERE sdc.cdcooper = pr_cdcooper
       AND sdc.nrdconta = pr_nrdconta;
    rw_crapsdc cr_crapsdc%ROWTYPE;

  CURSOR cr_crapcot_base IS
    select  14 cdcooper, 16809670 nrdconta from dual union all
    select   6 cdcooper, 16836782 nrdconta from dual union all
    select  10 cdcooper, 16906578 nrdconta from dual;
    rw_crapcot_base cr_crapcot_base%ROWTYPE;

 PROCEDURE lancamento_craplct (pr_cdcooper IN  craplct.cdcooper%TYPE
                              ,pr_nrdconta IN  craplct.nrdconta%TYPE
                              ,pr_vllanmto IN  craplct.vllanmto%TYPE
                              ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE
                              ,pr_cdagenci IN  crapass.cdagenci%TYPE
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                              ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    BEGIN
      DECLARE
        vr_exc_erro     EXCEPTION;
        vr_nrseqdig_lot craplot.nrseqdig%TYPE;
        vr_busca        VARCHAR2(100);
        vr_nrdocmto     craplct.nrdocmto%TYPE;
        vr_tab_retorno  LANC0001.typ_reg_retorno;

        BEGIN

  vr_busca := TRIM(to_char(pr_cdcooper)) || ';' ||
              TRIM(to_char(pr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
              TRIM(to_char(pr_cdagenci)) || ';' ||
                   '100;' ||
                    pr_nrdolote || ';' ||
              TRIM(to_char(pr_nrdconta));

  vr_nrdocmto := fn_sequence('CRAPLCT','NRDOCMTO', vr_busca);

  vr_nrseqdig_lot := fn_sequence('CRAPLOT','NRSEQDIG',''||pr_cdcooper||';'||
                                 to_char(pr_dtmvtolt,'DD/MM/RRRR')||';'||
                                 pr_cdagenci||
                                 ';100;'||
                                  pr_nrdolote);

   INSERT INTO cecred.craplct(cdcooper
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,dtmvtolt
                             ,cdhistor
                             ,nrctrpla
                             ,nrdconta
                             ,nrdocmto
                             ,nrseqdig
                             ,vllanmto)
                      VALUES (pr_cdcooper
                             ,pr_cdagenci
                             ,100
                             ,pr_nrdolote
                             ,pr_dtmvtolt
                             ,2136
                             ,pr_nrdconta
                             ,pr_nrdconta
                             ,vr_nrdocmto
                             ,vr_nrseqdig_lot
                             ,pr_vllanmto);

   cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper =>pr_cdcooper
                                            ,pr_dtmvtolt =>pr_dtmvtolt
                                            ,pr_dtrefere =>pr_dtmvtolt
                                            ,pr_cdagenci =>pr_cdagenci
                                            ,pr_cdbccxlt =>100
                                            ,pr_nrdolote =>pr_nrdolote
                                            ,pr_nrdconta =>pr_nrdconta
                                            ,pr_nrdctabb => pr_nrdconta
                                            ,pr_nrdctitg => TO_CHAR(cecred.gene0002.fn_mask(pr_nrdconta,'99999999'))
                                            ,pr_nrdocmto => vr_nrdocmto
                                            ,pr_cdhistor => 2137
                                            ,pr_vllanmto =>pr_vllanmto
                                            ,pr_nrseqdig =>vr_nrseqdig_lot
                                            ,pr_tab_retorno => vr_tab_retorno
                                            ,pr_incrineg => vr_incrineg
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    UPDATE cecred.crapcot
       SET vldcotas = vldcotas - pr_vllanmto
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
  EXCEPTION
  WHEN vr_exc_erro THEN
    pr_cdcritic := 999;
    pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
    pr_cdcritic := 999;
    pr_dscritic := 'Erro no lancamento craplct --> '|| SQLERRM;
  END;
END lancamento_craplct;

BEGIN

  CECRED.pc_log_programa(pr_dstiplog   => 'O'
                        ,pr_dsmensagem => 'Inicio da execucao'
                        ,pr_cdmensagem => 111
                        ,pr_cdprograma => pr_cdprograma
                        ,pr_cdcooper   => 3
                        ,pr_idprglog   => vr_idprglog);

  OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  FOR rw_crapcot_base IN cr_crapcot_base LOOP    
    
    OPEN cr_crapass(pr_cdcooper => rw_crapcot_base.cdcooper,
                    pr_nrdconta => rw_crapcot_base.nrdconta);

    FETCH cr_crapass
    INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      pr_dscritic := 'Associado nao encontrado na crapcot- ' || rw_crapcot_base.cdcooper || ' Conta: ' || rw_crapcot_base.nrdconta;
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapass;

    OPEN cr_crapsdc(pr_cdcooper => rw_crapcot_base.cdcooper,
                    pr_nrdconta => rw_crapcot_base.nrdconta);

    FETCH cr_crapsdc
    INTO rw_crapsdc;

    IF cr_crapsdc%NOTFOUND THEN
      CLOSE cr_crapsdc;
      pr_dscritic := 'Associado nao encontrado na crapsdc- ' || rw_crapcot_base.cdcooper || ' Conta: ' || rw_crapcot_base.nrdconta;
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapsdc;
    
    vr_dslog := 'update crapsdc set dtdebito = ' || rw_crapsdc.dtdebito || ' vllanmto = ' || rw_crapsdc.vllanmto || ' indebito = ' || rw_crapsdc.indebito || ' where cdcooper = '|| rw_crapcot_base.cdcooper || ' nrdconta = ' || rw_crapcot_base.nrdconta ;
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => vr_dslog
                          ,pr_cdmensagem    => 222
                          ,pr_cdprograma    => pr_cdprograma
                          ,pr_cdcooper      => 3
                          ,pr_idprglog      => vr_idprglog);
                          
    IF rw_crapsdc.dtdebito IS NOT NULL AND rw_crapsdc.indebito = 1 THEN
      lancamento_craplct (pr_cdcooper => rw_crapcot_base.cdcooper
                         ,pr_nrdconta => rw_crapcot_base.nrdconta
                         ,pr_vllanmto => rw_crapsdc.vllanmto
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdagenci => rw_crapass.cdagenci
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        pr_dscritic := vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
    ELSIF rw_crapsdc.dtdebito IS NULL AND rw_crapsdc.indebito = 0 THEN
      BEGIN
        UPDATE cecred.crapsdc
           SET indebito = 2
         WHERE cdcooper = rw_crapcot_base.cdcooper
           AND nrdconta = rw_crapcot_base.nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 9999;
          vr_dscritic := 'Erro ao cancelar lançamento futuro de capital inicial. '||sqlerrm;
      END;
    ELSE
    vr_dslog := 'Nao entrou em nenhuma condicao - cooperativa = '|| rw_crapcot_base.cdcooper || ' conta = ' || rw_crapcot_base.nrdconta;
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => vr_dslog
                          ,pr_cdmensagem    => 333
                          ,pr_cdprograma    => pr_cdprograma
                          ,pr_cdcooper      => 3
                          ,pr_idprglog      => vr_idprglog);
    END IF;
               
  END LOOP;

  COMMIT;
  EXCEPTION
  WHEN vr_exc_saida THEN
    IF vr_cdcritic <> 0 THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    ELSE
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := pr_dscritic;
    END IF;
    ROLLBACK;
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => 444
                          ,pr_cdprograma    => pr_cdprograma
                          ,pr_cdcooper      => 3
                          ,pr_idprglog      => vr_idprglog);

  WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => 555
                          ,pr_cdprograma    => pr_cdprograma
                          ,pr_cdcooper      => 3
                          ,pr_idprglog      => vr_idprglog);    
END;
