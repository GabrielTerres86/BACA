DECLARE
  vr_cdcooper                craplac.cdcooper%TYPE := 3;
  vr_cdprograma              tbgen_prglog.cdprograma%TYPE := 'INC0291465';
  vr_vlrdtaxa                craptxi.vlrdtaxa%TYPE := 0.00680500;
  vr_nrseqdig                craplot.nrseqdig%TYPE;
  vr_vllanmto                craplac.vllanmto%TYPE;
  vr_dslog                   tbgen_prglog_ocorrencia.dsmensagem%TYPE;
  vr_vlbascal                NUMBER;
  vr_vlsldtot                NUMBER;
  vr_vlsldrgt                NUMBER;
  vr_vlultren                NUMBER;
  vr_vlrentot                NUMBER;
  vr_vlrevers                NUMBER;
  vr_vlrdirrf                NUMBER;
  vr_percirrf                NUMBER;
  vr_incrineg                INTEGER;
  vr_vlbasecalculo_corrigida craplac.vllanmto%TYPE;
    
  vr_cdcritic crapcri.cdcritic%TYPE := 0;
  vr_dscritic VARCHAR2(5000) := NULL;
  vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  vr_exc_saida EXCEPTION;
  vr_nraplicanova craprac.nraplica%TYPE := 0;

  rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;
  vr_tab_retorno LANC0001.typ_reg_retorno;

  CURSOR cr_craprac IS
    SELECT *
      FROM CECRED.craprac
     WHERE cdprodut = 1109
       AND dtatlsld >= to_date('11/09/2023','dd/mm/yyyy')
       AND dtaniver = to_date('09/10/2023','dd/mm/yyyy');
  rw_craprac cr_craprac%ROWTYPE;

  CURSOR cr_craplac(pr_cdcooper NUMBER
                   ,pr_nrdconta NUMBER
                   ,pr_nraplica NUMBER) IS
    SELECT SUM(decode(his.indebcre, 'D', -1, 1) * lac.vllanmto) vllanmto
      FROM CECRED.craplac lac
          ,CECRED.craphis his
     WHERE lac.cdcooper = his.cdcooper
       AND lac.CDHISTOR = his.CDHISTOR
       AND lac.cdcooper = pr_cdcooper
       AND lac.nrdconta = pr_nrdconta
       AND lac.nraplica = pr_nraplica
       AND lac.cdhistor in (3527,3532,3528)
       AND lac.dtmvtolt < to_date('09/09/2023','dd/mm/yyyy');
  rw_craplac cr_craplac%ROWTYPE;
  
  CURSOR cr_craplac_rentab(pr_cdcooper NUMBER
                          ,pr_nrdconta NUMBER
                          ,pr_nraplica NUMBER) IS
    SELECT lac.vllanmto vllanmto
      FROM CECRED.craplac lac
     WHERE lac.cdcooper = pr_cdcooper
       AND lac.nrdconta = pr_nrdconta
       AND lac.nraplica = pr_nraplica
       AND lac.cdhistor = 3532
       AND lac.dtmvtolt = to_date('11/09/2023','dd/mm/yyyy');
  rw_craplac_rentab cr_craplac_rentab%ROWTYPE;

BEGIN  
  BEGIN 
    UPDATE cecred.craptxi txi
       SET txi.vlrdtaxa = 0.68050000
     WHERE txi.dtiniper = to_date('09/08/2023','dd/mm/yyyy')
       AND txi.dtfimper = to_date('09/08/2023','dd/mm/yyyy')
       AND txi.cddindex = 6;
    COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'ERRO ao atualizar a taxa: ' || SQLERRM;
        RAISE vr_exc_saida;
  END;

  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;

  IF btch0001.cr_crapdat%NOTFOUND THEN
    CLOSE btch0001.cr_crapdat;
    vr_dscritic := 'Erro no carregamento do cursor btch0001.cr_crapdat. Dados nao encontrados.';
    RAISE vr_exc_saida;
  ELSE
    CLOSE btch0001.cr_crapdat;
  END IF;
  
  FOR rw_craprac IN cr_craprac LOOP
    vr_vllanmto := 0;

    OPEN cr_craplac(rw_craprac.cdcooper, rw_craprac.nrdconta, rw_craprac.nraplica);
    FETCH cr_craplac
      INTO rw_craplac;
  
    IF cr_craplac%NOTFOUND THEN
      CLOSE cr_craplac;
      vr_dscritic := 'Erro no carregamento do cursor cr_craplac. Dados nao encontrados.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplac;
    END IF;
    
    OPEN cr_craplac_rentab(rw_craprac.cdcooper, rw_craprac.nrdconta, rw_craprac.nraplica);
    FETCH cr_craplac_rentab
      INTO rw_craplac_rentab;
      
    IF cr_craplac_rentab%NOTFOUND THEN
      CLOSE cr_craplac_rentab;
      vr_dscritic := 'Erro no carregamento do cursor cr_craplac_rentab. Dados nao encontrados.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplac_rentab;
    END IF;
    
    vr_vlbasecalculo_corrigida := round(nvl(rw_craplac.vllanmto,0) * nvl(vr_vlrdtaxa,0),2);
    vr_vllanmto := nvl(vr_vlbasecalculo_corrigida,0) - nvl(rw_craplac_rentab.vllanmto,0);
      
    IF vr_vllanmto <= 0 THEN
       vr_dslog := 'Lançamento menor que zero ;' 
                  || 'Cooperativa; ' || rw_craprac.cdcooper || '; '
                  || 'Conta; ' || rw_craprac.nrdconta || '; ' 
                  || 'Aplicacao; ' || rw_craprac.nraplica || '; ' 
                  || 'Valor a lancar; ' || TO_CHAR(vr_vllanmto) || '; ';
    
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dslog,
                             pr_cdmensagem => 111,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => vr_cdcooper,
                             pr_idprglog   => vr_idprglog);
      CONTINUE;
    END IF;
    IF rw_craprac.idsaqtot = 1 THEN
      vr_dslog := 'Saque total realizado ;' 
                  || 'Cooperativa; ' || rw_craprac.cdcooper || '; '
                  || 'Conta; ' || rw_craprac.nrdconta || '; ' 
                  || 'Aplicacao; ' || rw_craprac.nraplica || '; ' 
                  || 'Valor a lancar; ' || TO_CHAR(vr_vllanmto) || '; ';
    
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dslog,
                             pr_cdmensagem => 222,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => vr_cdcooper,
                             pr_idprglog   => vr_idprglog);
      
      vr_nrseqdig := CECRED.SEQCAPT_CRAPLCI_NRSEQDIG.NEXTVAL();
      
      cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => rw_craprac.cdcooper,
                                                pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                pr_cdagenci    => 1,
                                                pr_cdbccxlt    => 100,
                                                pr_nrdolote    => 8599,
                                                pr_nrdconta    => rw_craprac.nrdconta,
                                                pr_nrdctabb    => rw_craprac.nrdconta,
                                                pr_nrdocmto    => 8599 || rw_craprac.nraplica || 9,
                                                pr_nrseqdig    => vr_nrseqdig,
                                                pr_dtrefere    => rw_crapdat.dtmvtolt,
                                                pr_vllanmto    => vr_vllanmto,
                                                pr_cdhistor    => 362,
                                                pr_nraplica    => rw_craprac.nraplica,
                                                pr_tab_retorno => vr_tab_retorno,
                                                pr_incrineg    => vr_incrineg,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
      
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Erro ao inserir registro de lancamento de credito. Erro: Cooperativa: ' || rw_craprac.cdcooper || ' Conta: ' || rw_craprac.nrdconta || ' Aplicacao: ' || rw_craprac.nraplica  || SQLERRM;
        RAISE vr_exc_saida;
      END IF;
    ELSIF rw_craprac.idsaqtot = 0 THEN
      vr_dslog := 'Aplicacao ativa ;' 
                  || 'Cooperativa; ' || rw_craprac.cdcooper || ';' 
                  || 'Conta; ' || rw_craprac.nrdconta || '; ' 
                  || 'Aplicacao; ' || rw_craprac.nraplica || '; ' 
                  || 'Valor lancamento; ' || TO_CHAR(vr_vllanmto) || '; ' ;
    
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dslog,
                             pr_cdmensagem => 333,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => vr_cdcooper,
                             pr_idprglog   => vr_idprglog);
    
       vr_nrseqdig := CECRED.SEQCAPT_CRAPLAC_NRSEQDIG.NEXTVAL(); 
    BEGIN
      INSERT INTO cecred.craplac
        (cdcooper
        ,dtmvtolt
        ,cdagenci
        ,cdbccxlt
        ,nrdolote
        ,nrdconta
        ,nraplica
        ,nrdocmto
        ,nrseqdig
        ,vllanmto
        ,cdhistor
        ,nrseqrgt
        ,vlrendim
        ,vlbasren
        ,cdcanal
        ,cdoperad)
      VALUES
        (rw_craprac.cdcooper
        ,rw_crapdat.dtmvtolt
        ,1
        ,100
        ,8502
        ,rw_craprac.nrdconta
        ,rw_craprac.nraplica
        ,99||rw_craprac.nraplica ||9
        ,99||rw_craprac.nraplica ||9
        ,vr_vllanmto
        ,3532
        ,0
        ,0
        ,0
        ,5
        ,1);
      
        UPDATE CECRED.craprac
           SET craprac.vlsldatl = vlsldatl + vr_vllanmto
         WHERE craprac.cdcooper = rw_craprac.cdcooper
           AND craprac.nrdconta = rw_craprac.nrdconta
           AND craprac.nraplica = rw_craprac.nraplica;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar inserir craprac script. Erro: Cooperativa: ' || rw_craprac.cdcooper || ' Conta: ' || rw_craprac.nrdconta || ' Aplicacao: ' || rw_craprac.nraplica  || SQLERRM;
          RAISE vr_exc_saida;
      END;
     
    END IF;
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    IF vr_cdcritic <> 0 THEN
      vr_dscritic := 'Erro ao rodar script : ' 
                     || gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) 
                     || '. Detalhes: ' || vr_dscritic;
    END IF;
  
    ROLLBACK;        
    
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => vr_dscritic,
                           pr_cdmensagem => 777,
                           pr_cdprograma => vr_cdprograma,
                           pr_cdcooper   => vr_cdcooper,
                           pr_idprglog   => vr_idprglog);  
  WHEN OTHERS THEN
    vr_dscritic := 'Erro nao tratado ao rodar script : Cooperativa: ' || rw_craprac.cdcooper || ' Conta: ' || rw_craprac.nrdconta || ' Aplicacao: ' || rw_craprac.nraplica  || SQLERRM;
  
    ROLLBACK;    
    
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => vr_dscritic,
                           pr_cdmensagem => 888,
                           pr_cdprograma => vr_cdprograma,
                           pr_cdcooper   => vr_cdcooper,
                           pr_idprglog   => vr_idprglog);
END;
