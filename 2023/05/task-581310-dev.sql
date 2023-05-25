DECLARE
  vr_cdcooper   craplac.cdcooper%TYPE := 1;
  vr_cdprograma tbgen_prglog.cdprograma%TYPE := 'INC581310-10';
  vr_nrseqdig   craplot.nrseqdig%TYPE;
  vr_vllanmto   craplac.vllanmto%TYPE;
  vr_dslog      tbgen_prglog_ocorrencia.dsmensagem%TYPE;
  vr_vlbascal   NUMBER;
  vr_vlsldtot   NUMBER;
  vr_vlsldrgt   NUMBER;
  vr_vlultren   NUMBER;
  vr_vlrentot   NUMBER;
  vr_vlrevers   NUMBER;
  vr_vlrdirrf   NUMBER;
  vr_percirrf   NUMBER;
  vr_incrineg   INTEGER;
    
  vr_cdcritic crapcri.cdcritic%TYPE := 0;
  vr_dscritic VARCHAR2(5000) := NULL;
  vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  vr_exc_saida EXCEPTION;

  rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;
  vr_tab_retorno LANC0001.typ_reg_retorno;

  CURSOR cr_crapsli(pr_cdcooper IN crapsli.cdcooper%TYPE
                   ,pr_nrdconta IN crapsli.nrdconta%TYPE
                   ,pr_dtrefere IN crapsli.dtrefere%TYPE) IS
    SELECT sli.cdcooper
          ,sli.nrdconta
          ,sli.dtrefere
          ,sli.vlsddisp
          ,sli.rowid
      FROM CECRED.crapsli sli
     WHERE sli.cdcooper = pr_cdcooper
       AND sli.nrdconta = pr_nrdconta
       AND sli.dtrefere = pr_dtrefere;

  rw_crapsli cr_crapsli%ROWTYPE;

  CURSOR cr_craprac IS
    SELECT rac.cdcooper
          ,rac.nrdconta
          ,rac.nraplica
          ,rac.dtmvtolt
          ,rac.idsaqtot
          ,rac.vlsldatl
      FROM CECRED.craprac rac
     WHERE rac.cdprodut = 1109
       AND EXTRACT(DAY FROM rac.dtmvtolt) = 28
       AND rac.dtmvtolt < TO_DATE('28/02/2023', 'dd/MM/yyyy')
       AND rac.dtatlsld >= TO_DATE('28/02/2023', 'dd/MM/yyyy');
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
       AND lac.cdhistor in (3527,3532,3528);
  rw_craplac cr_craplac%ROWTYPE;

  PROCEDURE lancamento_craplac(pr_cdcooper IN craplac.cdcooper%TYPE
                              ,pr_nrdconta IN craplac.nrdconta%TYPE
                              ,pr_nraplica IN craplac.nraplica%TYPE
                              ,pr_dtmvtolt IN craplac.dtmvtolt%TYPE
                              ,pr_vllanmto IN craplac.vllanmto%TYPE
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                              ,pr_dscritic OUT VARCHAR2) IS
    vr_exc_saida EXCEPTION;
  
    vr_incrineg INTEGER;
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := NULL;
    vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
    vr_nrseqrgt craprga.nrseqrgt%TYPE := 0;
    
    
  BEGIN
    
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
        (pr_cdcooper
        ,pr_dtmvtolt
        ,1
        ,100
        ,8502
        ,pr_nrdconta
        ,pr_nraplica
        ,99||pr_nraplica ||9
        ,99||pr_nraplica ||9
        ,pr_vllanmto
        ,3528
        ,vr_nrseqrgt
        ,0
        ,0
        ,5
        ,1);
    
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 999;
        vr_dscritic := 'Erro ao inserir registro de lancamento de aplicacao. Erro: Cooperativa: ' || pr_cdcooper || ' Conta: ' || pr_nrdconta || ' Aplicacao: ' || pr_nraplica || SQLERRM;
        RAISE vr_exc_saida;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 999;
      pr_dscritic := 'Erro na procedure lancamento_craplac. Detalhes: Cooperativa: ' || pr_cdcooper || ' Conta: ' || pr_nrdconta || ' Aplicacao: ' || pr_nraplica || SQLERRM;
  END lancamento_craplac;

BEGIN  
 
  
  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 1);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;

  IF btch0001.cr_crapdat%NOTFOUND
  THEN
    CLOSE btch0001.cr_crapdat;
    vr_dscritic := 'Erro no carregamento do cursor btch0001.cr_crapdat. Dados nao encontrados.';
    RAISE vr_exc_saida;
  ELSE
    CLOSE btch0001.cr_crapdat;
  END IF;
  
  FOR rw_craprac IN cr_craprac
  LOOP
    vr_vllanmto := 0;
  
    OPEN cr_craplac(rw_craprac.cdcooper, rw_craprac.nrdconta, rw_craprac.nraplica);
    FETCH cr_craplac
      INTO rw_craplac;
  
    IF cr_craplac%NOTFOUND
    THEN
      CLOSE cr_craplac;
      vr_dscritic := 'Erro no carregamento do cursor cr_craplac. Dados nao encontrados.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplac;
    END IF;
  
    IF rw_craprac.idsaqtot = 1
       AND rw_craplac.vllanmto > 0
    THEN
      vr_dslog := 'Saque total realizado, valor de lancamento maior que zero. ' 
                  || 'Cooperativa: ' || rw_craprac.cdcooper || '; '
                  || 'Conta: ' || rw_craprac.nrdconta || '; ' 
                  || 'Aplicacao: ' || rw_craprac.nraplica || '; ' 
                  || 'Valor a lancar: ' || TO_CHAR(rw_craplac.vllanmto) || '; ';
    
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dslog,
                             pr_cdmensagem => 111,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => vr_cdcooper,
                             pr_idprglog   => vr_idprglog);
    
      lancamento_craplac(pr_cdcooper => rw_craprac.cdcooper,
                         pr_nrdconta => rw_craprac.nrdconta,
                         pr_nraplica => rw_craprac.nraplica,
                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                         pr_vllanmto => rw_craplac.vllanmto,
                         pr_cdcritic => vr_cdcritic,
                         pr_dscritic => vr_dscritic);
    
      IF nvl(vr_cdcritic, 0) > 0
         OR vr_dscritic IS NOT NULL
      THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_nrseqdig := fn_sequence('CRAPLOT',
                                 'NRSEQDIG',
                                 '' || rw_craprac.cdcooper || ';' 
                                 || to_char(rw_crapdat.dtmvtolt, 'dd/MM/yyyy') || ';' || 1 || ';' || 100 || ';' || 8599);
      
      cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => rw_craprac.cdcooper,
                                                pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                pr_cdagenci    => 1,
                                                pr_cdbccxlt    => 100,
                                                pr_nrdolote    => 8599,
                                                pr_nrdconta    => rw_craprac.nrdconta,
                                                pr_nrdctabb    => rw_craprac.nrdconta,
                                                pr_nrdocmto    => rw_craprac.nraplica,
                                                pr_nrseqdig    => vr_nrseqdig,
                                                pr_dtrefere    => rw_crapdat.dtmvtolt,
                                                pr_vllanmto    => rw_craplac.vllanmto,
                                                pr_cdhistor    => 3529,
                                                pr_nraplica    => rw_craprac.nraplica,
                                                pr_tab_retorno => vr_tab_retorno,
                                                pr_incrineg    => vr_incrineg,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
      
      IF nvl(vr_cdcritic, 0) > 0
         OR vr_dscritic IS NOT NULL
      THEN
        vr_dscritic := 'Erro ao inserir registro de lancamento de credito. Erro: Cooperativa: ' || rw_craprac.cdcooper || ' Conta: ' || rw_craprac.nrdconta || ' Aplicacao: ' || rw_craprac.nraplica  || SQLERRM;
        RAISE vr_exc_saida;
      END IF;
    ELSIF rw_craprac.idsaqtot = 0
          AND rw_craplac.vllanmto <> rw_craprac.vlsldatl
    THEN
      vr_dslog := 'Resgate total ' 
                  || 'Cooperativa: ' || rw_craprac.cdcooper || ';' 
                  || 'Conta: ' || rw_craprac.nrdconta || '; ' 
                  || 'Aplicacao: ' || rw_craprac.nraplica || '; ' 
                  || 'Valor original do extrato: ' || TO_CHAR(rw_craplac.vllanmto) || '; ' 
                  || 'Valor total da aplicacao: ' || TO_CHAR(rw_craprac.vlsldatl) || '; ';
    
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dslog,
                             pr_cdmensagem => 222,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => vr_cdcooper,
                             pr_idprglog   => vr_idprglog);
    
      lancamento_craplac(pr_cdcooper => rw_craprac.cdcooper,
                         pr_nrdconta => rw_craprac.nrdconta,
                         pr_nraplica => rw_craprac.nraplica,
                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                         pr_vllanmto => rw_craplac.vllanmto,
                         pr_cdcritic => vr_cdcritic,
                         pr_dscritic => vr_dscritic);
    
      IF nvl(vr_cdcritic, 0) > 0
         OR vr_dscritic IS NOT NULL
      THEN
        RAISE vr_exc_saida;
      END IF;
      
      BEGIN
          UPDATE CECRED.craprac
             SET craprac.vlbasapl = 0,
                 craprac.vlsldatl = 0,
                 craprac.idsaqtot = 1
           WHERE craprac.cdcooper = rw_craprac.cdcooper
             AND craprac.nrdconta = rw_craprac.nrdconta
             AND craprac.nraplica = rw_craprac.nraplica;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crarac script. Erro: Cooperativa: ' || rw_craprac.cdcooper || ' Conta: ' || rw_craprac.nrdconta || ' Aplicacao: ' || rw_craprac.nraplica  || SQLERRM;
            RAISE vr_exc_saida;
        END;
      
    
      BEGIN
        vr_nrseqdig := CECRED.SEQCAPT_CRAPLCI_NRSEQDIG.NEXTVAL();
        
        INSERT INTO CECRED.craplci
          (cdcooper
          ,dtmvtolt
          ,cdagenci
          ,cdbccxlt
          ,nrdolote
          ,nrdconta
          ,nrdocmto
          ,nrseqdig
          ,vllanmto
          ,cdhistor
          ,nraplica)
        VALUES
          (rw_craprac.cdcooper
          ,rw_crapdat.dtmvtolt
          ,1
          ,100
          ,9900010106
          ,rw_craprac.nrdconta
          ,9 || rw_craprac.nraplica || vr_nrseqdig
          ,vr_nrseqdig
          ,rw_craplac.vllanmto
          ,490
          ,rw_craprac.nraplica);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro na CRAPLCI. Erro: Cooperativa: ' || rw_craprac.cdcooper || ' Conta: ' || rw_craprac.nrdconta || ' Aplicacao: ' || rw_craprac.nraplica  || SQLERRM;
          RAISE vr_exc_saida;
      END;
    
      OPEN cr_crapsli(pr_cdcooper => rw_craprac.cdcooper,
                      pr_nrdconta => rw_craprac.nrdconta,
                      pr_dtrefere => rw_crapdat.dtultdia);
    
      FETCH cr_crapsli
        INTO rw_crapsli;
    
      IF cr_crapsli%NOTFOUND
      THEN
        CLOSE cr_crapsli;
      
        BEGIN
          INSERT INTO CECRED.crapsli
            (cdcooper
            ,nrdconta
            ,dtrefere
            ,vlsddisp)
          VALUES
            (rw_craprac.cdcooper
            ,rw_craprac.nrdconta
            ,rw_crapdat.dtultdia
            ,rw_craplac.vllanmto);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro na CRAPSLI. Erro: Cooperativa: ' || rw_craprac.cdcooper || ' Conta: ' || rw_craprac.nrdconta || ' Aplicacao: ' || rw_craprac.nraplica  || SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE
        CLOSE cr_crapsli;
        
        BEGIN
          UPDATE CECRED.crapsli
             SET crapsli.vlsddisp = crapsli.vlsddisp + rw_craplac.vllanmto
           WHERE crapsli.cdcooper = rw_craprac.cdcooper
             AND crapsli.nrdconta = rw_craprac.nrdconta
             AND crapsli.dtrefere = LAST_DAY(rw_crapdat.dtmvtolt);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar saldo de conta investimento. Erro: Cooperativa: ' || rw_craprac.cdcooper || ' Conta: ' || rw_craprac.nrdconta || ' Aplicacao: ' || rw_craprac.nraplica  || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        IF rw_craplac.vllanmto >= 5
        THEN

          CECRED.APLI0005.pc_cadastra_aplic(pr_cdcooper => rw_craprac.cdcooper,
                                            pr_cdoperad => 1,
                                            pr_nmdatela => 'CRPS145-SCRIPT',
                                            pr_idorigem => 5,
                                            pr_nrdconta => rw_craprac.nrdconta,
                                            pr_idseqttl => 1,
                                            pr_nrdcaixa => 100,
                                            pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                            pr_cdprodut => 1109,
                                            pr_qtdiaapl => 9999,
                                            pr_dtvencto => rw_crapdat.dtmvtolt + 9999,
                                            pr_qtdiacar => 30,
                                            pr_qtdiaprz => 9999,
                                            pr_vlaplica => rw_craplac.vllanmto,
                                            pr_iddebcti => 1,
                                            pr_idorirec => 0,
                                            pr_idgerlog => 0,
                                            pr_nraplica => rw_craprac.nraplica,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
        
          IF vr_dscritic IS NOT NULL
          THEN
            vr_dscritic := vr_dscritic ||' Cooperativa: ' || rw_craprac.cdcooper || ' Conta: ' || rw_craprac.nrdconta || ' Aplicacao: ' || rw_craprac.nraplica ;
            RAISE vr_exc_saida;
          END IF;
         ELSIF rw_craplac.vllanmto < 5 THEN
                vr_dslog := 'Aplicacao menos que 5 ' 
                  || 'Cooperativa: ' || rw_craprac.cdcooper || ';' 
                  || 'Conta: ' || rw_craprac.nrdconta || '; ' 
                  || 'Aplicacao: ' || rw_craprac.nraplica || '; ' 
                  || 'Valor original do extrato: ' || TO_CHAR(rw_craplac.vllanmto) || '; ' 
                  || 'Valor total da aplicacao: ' || TO_CHAR(rw_craprac.vlsldatl) || '; ';
    
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dslog,
                             pr_cdmensagem => 333,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => vr_cdcooper,
                             pr_idprglog   => vr_idprglog);
        END IF;
      END IF;
    END IF;
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    IF vr_cdcritic <> 0
    THEN
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
