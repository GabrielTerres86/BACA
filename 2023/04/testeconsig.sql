DECLARE  
  vr_indsobra   VARCHAR2(1000); 
  vr_inderro    VARCHAR2(1000) := 0; 
  
  vr_nrcursor   NUMBER;
  vr_nrretorn   NUMBER;
  vr_cursor     VARCHAR2(32000);

  vr_cdcooper   VARCHAR2(400);
  vr_nrdconta   VARCHAR2(400);
  vr_nrctremp   VARCHAR2(400);
  vr_nrparepr   VARCHAR2(400);
  vr_cdagenci   VARCHAR2(400);
  
  vr_cotas      NUMBER   := 0;
  vr_vlrsobra   NUMBER   := 0;
  vr_pago       NUMBER;
  vr_pago_total NUMBER;
  vr_seqerro    NUMBER   := 0;
  vr_seq        NUMBER   := 0;  
  vr_cdcritic   INTEGER  := 0;
  vr_dscritic   VARCHAR2(4000); 
  vr_exc_saida  EXCEPTION;  

  vr_rootmicros   VARCHAR2(4000) := gene0001.fn_param_sistema('CRED', 2, 'ROOT_MICROS');
  vr_nmdireto     VARCHAR2(4000) := vr_rootmicros||'/cpd/bacas/RITM0295362';
  vr_arq_leitura  VARCHAR2(100) := '/CONSIGNADO_ACENTRA_TEST.csv';  
  vr_ind_arquiv   utl_file.file_type;
  vr_ind_arquivr  utl_file.file_type;
  vr_linha        VARCHAR2(5000);
  vr_campo        GENE0002.typ_split;
  vr_texto_padrao VARCHAR2(200); 
  
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;   
  
  TYPE typ_reg_contrato IS RECORD(cdcooper  cecred.crapepr.cdcooper%TYPE,
                                  nrdconta  cecred.crapepr.nrdconta%TYPE,
                                  contratos VARCHAR2(4000),
                                  cotas     cecred.crapepr.vlemprst%TYPE);
  TYPE typ_tab_contrato IS TABLE OF typ_reg_contrato INDEX BY PLS_INTEGER;
    vr_tab_contrato typ_tab_contrato;
    
  TYPE typ_reg_contrato_erro IS RECORD(cdcooper  cecred.crapepr.cdcooper%TYPE,
                                       nrdconta  cecred.crapepr.nrdconta%TYPE,
                                       contrato  cecred.crapepr.nrctremp%TYPE);
  TYPE typ_tab_contrato_erro IS TABLE OF typ_reg_contrato_erro INDEX BY PLS_INTEGER;
    vr_tab_contrato_erro typ_tab_contrato_erro;              
                                         
  CURSOR cr_atraso_pp(pr_cdcooper  IN crappep.cdcooper%TYPE
                     ,pr_nrdconta  IN crappep.nrdconta%TYPE
                     ,pr_dtmvtolt  IN crappep.dtvencto%TYPE
                     ,pr_dtmvtoan  IN crappep.dtvencto%TYPE) IS
        SELECT nvl((select 1 from crapbpr
                 where  crapbpr.cdcooper = crappep.cdcooper
                 and    crapbpr.nrdconta = crappep.nrdconta
                 and    crapbpr.nrctrpro = crappep.nrctremp
                 and    grvm0001.fn_valida_categoria_alienavel(crapbpr.dscatbem) = 'S'
                 and    crapbpr.cdsitgrv not in (1,4,5)
                 and    rownum = 1),0) idgravame
           , nvl((select 1 from crapavl
                 where  crapavl.cdcooper = crappep.cdcooper
                 and    crapavl.nrdconta = crappep.nrdconta
                 and    rownum = 1),0) idavalista
           , crappep.cdcooper
           , crappep.nrdconta
           , crappep.nrctremp
           , crapass.cdagenci
           , crappep.dtvencto
           , crappep.vlsdvatu vlsdvpar
           , crappep.nrparepr
           , crappep.inliquid
           , crappep.rowid
        FROM crawepr
           , crapass
           , crappep
       WHERE crawepr.cdcooper (+) = crappep.cdcooper
         AND crawepr.nrdconta (+) = crappep.nrdconta
         AND crawepr.nrctremp (+) = crappep.nrctremp
         AND crapass.cdcooper = crappep.cdcooper
         AND crapass.nrdconta = crappep.nrdconta
         AND crapass.nrdconta = pr_nrdconta
         AND crappep.cdcooper = pr_cdcooper
         AND crappep.dtvencto < pr_dtmvtolt
         AND crappep.inprejuz = 0
         AND crawepr.flgpagto <> 2
         AND crappep.inliquid = 0
         AND EXISTS (SELECT 1 FROM crapepr where crapepr.cdcooper = crappep.cdcooper
                                             and crapepr.nrdconta = crappep.nrdconta
                                             and crapepr.nrctremp = crappep.nrctremp
                                             and crapepr.tpemprst = 1
                                             and crapepr.inliquid = 0
                                             and crapepr.inprejuz = 0)
       ORDER
          BY dtvencto
           , idgravame  desc
           , idavalista desc
           , vlsdvpar   desc
           , cdcooper
           , nrdconta
           , nrctremp
           , nrparepr;                                             
    rw_atraso_pp cr_atraso_pp%ROWTYPE;    
     
  CURSOR cr_sobra_antecipa_pp(pr_cdcooper crappep.cdcooper%TYPE
                             ,pr_nrdconta crappep.nrdconta%TYPE
                             ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT     crappep.cdcooper
               , crappep.nrdconta
               , crappep.nrctremp
               , crappep.nrparepr
               , crapass.cdagenci
               , crapepr.txmensal
               , NVL((SELECT COUNT(pep.nrparepr) FROM crappep pep
                                    WHERE pep.cdcooper = crappep.cdcooper
                                     AND pep.nrdconta = crappep.nrdconta
                                     AND pep.nrctremp = crappep.nrctremp
                                     AND pep.dtvencto >= pr_dtmvtolt
                                     AND pep.inprejuz = 0
                                     AND pep.inliquid = 0),0)qtd_parc_aberto 
    
        FROM crawepr
           , crapass
           , crappep
           , crapepr
       WHERE crawepr.cdcooper (+) = crappep.cdcooper
         AND crawepr.nrdconta (+) = crappep.nrdconta
         AND crawepr.nrctremp (+) = crappep.nrctremp
         AND crapass.cdcooper = crappep.cdcooper
         AND crapass.nrdconta = crappep.nrdconta
         AND crapass.nrdconta = pr_nrdconta         
         AND crappep.cdcooper = pr_cdcooper
         AND crappep.dtvencto >= pr_dtmvtolt
         AND crappep.inprejuz = 0
         AND crawepr.flgpagto <> 2
         AND crappep.inliquid = 0
         AND crapepr.cdcooper = crappep.cdcooper
         AND crapepr.nrdconta = crappep.nrdconta
         AND crapepr.nrctremp = crappep.nrctremp
         AND crapepr.tpemprst = 1
         AND crapepr.inliquid = 0
         AND crapepr.inprejuz = 0          
       ORDER BY crapepr.txmensal DESC
              , qtd_parc_aberto  DESC
              , crappep.cdcooper
              , crappep.nrdconta
              , crappep.nrctremp
              , crappep.nrparepr DESC;
                             
      rw_sobra_antecipa_pp cr_sobra_antecipa_pp%ROWTYPE;   
                
          
  PROCEDURE CRPS750_PAGAMENTO(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapepr.nrdconta%TYPE
                             ,pr_nrctremp IN crapepr.nrctremp%type
                             ,pr_nrparepr IN crappep.nrparepr%TYPE
                             ,pr_cdagenci IN crapass.cdagenci%type
                             ,pr_vlrcotas IN crapepr.vlsdeved%TYPE
                             ,pr_nmdatela IN VARCHAR2             
                             ,pr_vlsobras OUT crapepr.vlsdeved%TYPE
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                             ,pr_dscritic OUT VARCHAR2) IS  
                            
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdcooper
             , crapcop.nmrescop
             , crapcop.nrtelura
             , crapcop.cdbcoctl
             , crapcop.cdagectl
             , crapcop.dsdircop
             , crapcop.nrctactl
             , crapcop.cdagedbb
             , crapcop.cdageitg
             , crapcop.nrdocnpj
          FROM crapcop crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                        ,pr_nrdconta IN crapepr.nrdconta%TYPE
                        ,pr_nrctremp IN crapepr.nrctremp%TYPE
                        ,pr_inliquid IN crapepr.inliquid%TYPE) IS
        SELECT crapepr.dtdpagto
             , crapepr.cdlcremp
             , crapepr.cdempres
             , crapepr.tpemprst
             , crapepr.tpdescto
             , crapepr.rowid
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp
           AND crapepr.inliquid = pr_inliquid
           AND crapepr.flgpagto <> 2
           AND crapepr.inprejuz = 0;

      rw_crapepr cr_crapepr%ROWTYPE;

      CURSOR cr_crappep (pr_cdcooper  IN crappep.cdcooper%TYPE
                        ,pr_nrdconta  IN crappep.nrdconta%TYPE
                        ,pr_nrctremp  IN crappep.nrctremp%TYPE
                        ,pr_nrparepr  IN crappep.nrparepr%TYPE) IS
        SELECT crappep.cdcooper
             , crappep.nrdconta
             , crappep.nrctremp
             , crappep.dtvencto
             , crappep.vlsdvpar
             , crappep.nrparepr
             , crappep.inliquid
             , crappep.rowid
             , crawepr.dtlibera
             , crawepr.tpemprst
             , crawepr.idcobope
             , crapass.vllimcre
             , crappep.vlparepr
             , crappep.vlmtapar 
             , crappep.vlmrapar 
             , crappep.vliofcpl 
          FROM crawepr
             , crapass
             , crappep
         WHERE crawepr.cdcooper (+) = crappep.cdcooper
           AND crawepr.nrdconta (+) = crappep.nrdconta
           AND crawepr.nrctremp (+) = crappep.nrctremp
           AND crapass.cdcooper = crappep.cdcooper
           AND crapass.nrdconta = crappep.nrdconta
           AND crappep.cdcooper = pr_cdcooper
           and crappep.nrdconta = pr_nrdconta
           and crappep.nrctremp = pr_nrctremp
           and crappep.nrparepr = pr_nrparepr
           AND crawepr.flgpagto <> 2
           AND crappep.inprejuz = 0;

      rw_crappep cr_crappep%ROWTYPE;
      CURSOR cr_craplcmC(pr_cdcooper IN craplcm.cdcooper%TYPE
                        ,pr_nrdconta IN craplcm.nrdconta%TYPE
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
        SELECT a.vllanmto
          FROM craplcm a
             , craphis b
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta
           AND a.dtmvtolt = pr_dtmvtolt
           AND a.cdhistor = b.cdhistor
           and b.cdcooper = a.cdcooper
           AND b.indebcre = 'C';
      rw_craplcmC cr_craplcmC%ROWTYPE;

      CURSOR cr_cde (pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrctremp IN crapcob.nrctremp%TYPE) IS
        SELECT cob.nrdocmto
          FROM crapcob cob
         WHERE cob.cdcooper = pr_cdcooper
           AND cob.incobran = 0
           AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN
                       (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                          FROM tbrecup_cobranca cde
                         WHERE cde.cdcooper = pr_cdcooper
                           AND cde.nrdconta = pr_nrdconta
                           AND cde.nrctremp = pr_nrctremp
                           AND cde.tpproduto = 0);
      rw_cde cr_cde%ROWTYPE;

      CURSOR cr_ret (pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrctremp IN crapcob.nrctremp%TYPE
                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT cob.nrdocmto
          FROM crapcob cob, crapret ret
         WHERE cob.cdcooper = pr_cdcooper
           AND cob.incobran = 5
           AND cob.dtdpagto = pr_dtmvtolt
           AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN
                     (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                        FROM tbrecup_cobranca cde
                       WHERE cde.cdcooper = pr_cdcooper
                         AND cde.nrdconta = pr_nrdconta
                         AND cde.nrctremp = pr_nrctremp
                         AND cde.tpproduto = 0)
           AND ret.cdcooper = cob.cdcooper
           AND ret.nrdconta = cob.nrdconta
           AND ret.nrcnvcob = cob.nrcnvcob
           AND ret.nrdocmto = cob.nrdocmto
           AND ret.dtocorre = cob.dtdpagto
           AND ret.cdocorre = 6
           AND ret.flcredit = 0;
      rw_ret cr_ret%ROWTYPE;

      CURSOR cr_ctr_acordo(pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                          ,pr_nrdconta tbrecup_acordo.nrdconta%TYPE
                          ,pr_nrctremp tbrecup_acordo_contrato.nrctremp%TYPE) IS
        SELECT tbrecup_acordo_contrato.nracordo
             , tbrecup_acordo.cdcooper
             , tbrecup_acordo.nrdconta
             , tbrecup_acordo_contrato.nrctremp
          FROM tbrecup_acordo_contrato
          JOIN tbrecup_acordo
            ON tbrecup_acordo.nracordo   = tbrecup_acordo_contrato.nracordo
         WHERE tbrecup_acordo.cdsituacao = 1
           AND tbrecup_acordo_contrato.cdorigem IN (2,3)
           AND tbrecup_acordo.cdcooper = pr_cdcooper
           AND tbrecup_acordo.nrdconta = pr_nrdconta
           AND tbrecup_acordo_contrato.nrctremp = pr_nrctremp;
      rw_ctr_acordo cr_ctr_acordo%ROWTYPE;

    CURSOR cr_blqDebConsignado (pr_cdcooper in CRAPPCO.CDCOOPER%TYPE) IS
      SELECT DSCONTEU FROM CRAPPCO WHERE CDCOOPER = pr_cdcooper AND CDPARTAR = 162;
      rw_blqDebConsignado cr_blqDebConsignado%ROWTYPE;

    CURSOR cr_consig (pr_cdcooper IN tbcadast_empresa_consig.cdcooper%TYPE,
                      pr_cdempres IN tbcadast_empresa_consig.cdempres%TYPE) IS
      SELECT NVL(tec.nrdialimiterepasse,0) nrdialimiterepasse
             , NVL(tec.inddebitador,0) inddebitador
        FROM tbcadast_empresa_consig tec
       WHERE tec.cdcooper = pr_cdcooper
         AND tec.cdempres = pr_cdempres;
      vr_tab_crawepr      EMPR0001.typ_tab_crawepr;
      vr_tab_msg_confirma EMPR0001.typ_tab_msg_confirma;
      vr_tab_erro         GENE0001.typ_tab_erro;
      vr_tab_pgto_parcel  EMPR0001.typ_tab_pgto_parcel;
      vr_tab_calculado    EMPR0001.typ_tab_calculado;
      TYPE typ_tab_acordo IS TABLE OF NUMBER(10) INDEX BY VARCHAR2(30);
      vr_tab_acordo       typ_tab_acordo;
      rw_crapdat          BTCH0001.cr_crapdat%ROWTYPE;
      vr_cdprogra         VARCHAR2(50) := 'CRPS750_ANTECIP';
      vr_rowid            ROWID;
      vr_rowidlog         ROWID;
      vr_rowiderro        ROWID;
      vr_rowidgeral       ROWID;
      vr_vlsomato_tmp     NUMBER;
      vr_vlrcotas         NUMBER;
      vr_vlapagar         NUMBER;
      vr_vlsomato         NUMBER;
      vr_vlresgat         NUMBER;
      vr_vljurmes         NUMBER;
      vr_dtcalcul         DATE;
      vr_cdoperad         VARCHAR2(1);
      vr_flgpagpa         BOOLEAN;
      vr_flgemdia         BOOLEAN;
      vr_ehmensal         BOOLEAN;
      vr_diarefju         INTEGER;
      vr_mesrefju         INTEGER;
      vr_anorefju         INTEGER;
      vr_flgpripr         BOOLEAN;
      vr_idacaojd         BOOLEAN := FALSE;
      vr_blqconsig        BOOLEAN := FALSE;
      vr_vlsomvld         NUMBER;

      vr_cdindice         VARCHAR2(30) := '';
      vr_index_crawepr    VARCHAR2(30);
      vr_index_pgto_parcel PLS_INTEGER;

      vr_cdcritic         INTEGER:= 0;
      vr_dscritic         VARCHAR2(4000);
      vr_des_erro         VARCHAR2(3);

      vr_exc_final        EXCEPTION;
      vr_exc_saida        EXCEPTION;

      vr_blqresg_cc       VARCHAR2(1);

      vr_inBloqueioDebito number;

      vr_flultexe     NUMBER;

      vr_nrdialimiterepasse tbcadast_empresa_consig.nrdialimiterepasse%TYPE;
      vr_inddebitador       tbcadast_empresa_consig.inddebitador%TYPE;

      PROCEDURE pc_limpa_tabela IS
      BEGIN
        vr_tab_crawepr.DELETE;
        vr_tab_calculado.DELETE;
        vr_tab_msg_confirma.DELETE;
        vr_tab_pgto_parcel.DELETE;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao limpar tabelas de memoria. Rotina pc_CRPS750.pc_limpa_tabela. '||sqlerrm;
          RAISE vr_exc_saida;
      END pc_limpa_tabela;

      PROCEDURE pc_verifica_pagamento(pr_vlsomato IN NUMBER          
                                     ,pr_inliquid IN INTEGER         
                                     ,pr_flgpagpa OUT BOOLEAN        
                                     ,pr_des_reto OUT VARCHAR2) IS   
      BEGIN
        IF nvl(pr_vlsomato,0) <= 0 OR pr_inliquid = 1 THEN
          pr_flgpagpa := FALSE;
        ELSE
          pr_flgpagpa:= TRUE;
        END IF;

        pr_des_reto:= 'OK';

      EXCEPTION
        WHEN OTHERS THEN
          pr_des_reto:= 'NOK';
      END pc_verifica_pagamento;

  BEGIN
    
      pr_vlsobras:= pr_vlrcotas;
      vr_vlrcotas:= pr_vlrcotas;
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      OPEN  cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      vr_cdoperad:= '1';

      pc_limpa_tabela;
      
      FOR rw_ctr_acordo IN cr_ctr_acordo(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctremp => pr_nrctremp) LOOP
      
        vr_cdindice := LPAD(rw_ctr_acordo.cdcooper,10,'0') || LPAD(rw_ctr_acordo.nrdconta,10,'0') ||
                       LPAD(rw_ctr_acordo.nrctremp,10,'0');
      
        vr_tab_acordo(vr_cdindice) := rw_ctr_acordo.nracordo;   
      END LOOP;                            

      FOR rw_crappep IN cr_crappep (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctremp => pr_nrctremp
                                   ,pr_nrparepr => pr_nrparepr) LOOP
                                        
        vr_flgemdia := rw_crappep.dtvencto > rw_crapdat.dtmvtoan;

        vr_tab_crawepr.DELETE;

        vr_vlresgat := 0;

        IF rw_crappep.dtlibera IS NOT NULL THEN
          vr_index_crawepr := lpad(rw_crappep.cdcooper,10,'0')||
                              lpad(rw_crappep.nrdconta,10,'0')||
                              lpad(rw_crappep.nrctremp,10,'0');
          vr_tab_crawepr(vr_index_crawepr).dtlibera:= rw_crappep.dtlibera;
          vr_tab_crawepr(vr_index_crawepr).tpemprst:= rw_crappep.tpemprst;
          vr_tab_crawepr(vr_index_crawepr).idcobope:= rw_crappep.idcobope;
        END IF;

        OPEN cr_crapepr (pr_cdcooper => rw_crappep.cdcooper
                        ,pr_nrdconta => rw_crappep.nrdconta
                        ,pr_nrctremp => rw_crappep.nrctremp
                        ,pr_inliquid => 0);

        FETCH cr_crapepr INTO rw_crapepr;
        IF cr_crapepr%NOTFOUND THEN
          CLOSE cr_crapepr;
          vr_dscritic := 'Erro Informacoes Emprestimo';
          pr_dscritic := vr_dscritic;
          CONTINUE;
        END IF;
        CLOSE cr_crapepr;
        
        IF rw_crapepr.tpdescto = 2 AND rw_crapepr.cdempres = 9999 THEN
          vr_dscritic := 'Consignado com Empresa 9999 (Desligado)';
          pr_dscritic := vr_dscritic;
          CONTINUE;
        END IF;
        
        vr_inddebitador := 0;

        FOR rw_consig IN cr_consig (pr_cdcooper => rw_crappep.cdcooper,
                                    pr_cdempres => rw_crapepr.cdempres) LOOP
          vr_nrdialimiterepasse:= rw_consig.nrdialimiterepasse;
          vr_inddebitador := 1;
        END LOOP;

        IF rw_crapdat.inproces = 1 AND vr_flgpripr THEN
          OPEN  cr_craplcmC(pr_cdcooper => rw_crappep.cdcooper
                           ,pr_nrdconta => rw_crappep.nrdconta
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
          FETCH cr_craplcmC INTO rw_craplcmC;
          IF cr_craplcmC%NOTFOUND THEN
            CLOSE cr_craplcmC;
            vr_dscritic := 'Erro Lançamentos de credito da conta';
            pr_dscritic := vr_dscritic;
            CONTINUE;
          END IF;
          CLOSE cr_craplcmC;
        END IF;

        vr_vlapagar     := rw_crappep.vlsdvpar;
        vr_vlsomato     := 0;
        
        dbms_output.put_line('Saldo devedor da parcela: ' || vr_vlapagar);

        vr_idacaojd := FALSE;
        vr_inBloqueioDebito := 0;
        credito.verificarBloqueioDebito(pr_cdcooper => pr_cdcooper,
                                        pr_nrdconta => rw_crappep.nrdconta,
                                        pr_nrctremp => rw_crappep.nrctremp,
                                        pr_bloqueio => vr_inBloqueioDebito,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);
        IF vr_dscritic is not null or vr_cdcritic > 0 THEN
           pr_dscritic := vr_dscritic;
           CONTINUE;
        END IF;
        IF vr_inBloqueioDebito = 1 THEN
          vr_idacaojd := TRUE;
        END IF;

        IF vr_idacaojd THEN
          vr_dscritic := 'Bloqueio Judicial para Conta/Contrato.';
          pr_dscritic := vr_dscritic;
          IF vr_tab_crawepr.count() > 0 THEN
            vr_index_crawepr := vr_tab_crawepr.FIRST();
            LOOP
              vr_tab_crawepr(vr_index_crawepr).idcobope := 0;
              EXIT WHEN vr_index_crawepr = vr_tab_crawepr.LAST();
              vr_index_crawepr := vr_tab_crawepr.NEXT(vr_index_crawepr);
            END LOOP;
          END IF;
        END IF;

        OPEN  cr_blqDebConsignado(pr_cdcooper => 3);
        FETCH cr_blqDebConsignado INTO rw_blqDebConsignado;
        CLOSE cr_blqDebConsignado;

        vr_blqconsig := FALSE;
        IF rw_crapepr.tpdescto = 2 AND NVL(rw_blqDebConsignado.DSCONTEU,0) = 1 THEN
          vr_blqconsig := TRUE;
          vr_dscritic := 'Bloqueio Judicial para Conta/Contrato Consig';
          pr_dscritic := vr_dscritic;
        END IF;

        EMPR0001.pc_valida_pagamentos_geral(pr_cdcooper    => pr_cdcooper                
                                           ,pr_cdagenci    => pr_cdagenci                
                                           ,pr_nrdcaixa    => 0                          
                                           ,pr_cdoperad    => vr_cdoperad                
                                           ,pr_nmdatela    => vr_cdprogra                
                                           ,pr_idorigem    => 7                          
                                           ,pr_nrdconta    => rw_crappep.nrdconta        
                                           ,pr_nrctremp    => rw_crappep.nrctremp        
                                           ,pr_idseqttl    => 1                          
                                           ,pr_dtmvtolt    => rw_crapdat.dtmvtolt        
                                           ,pr_flgerlog    => TRUE                       
                                           ,pr_dtrefere    => rw_crapdat.dtmvtolt        
                                           ,pr_vlapagar    => vr_vlapagar                
                                           ,pr_tab_crawepr => vr_tab_crawepr             
                                           ,pr_efetresg    => 'S'                        
                                           ,pr_vlsomato    => vr_vlsomato                
                                           ,pr_vlresgat    => vr_vlresgat                
                                           ,pr_tab_erro    => vr_tab_erro                
                                           ,pr_des_reto    => vr_des_erro                
                                           ,pr_tab_msg_confirma => vr_tab_msg_confirma); 
        IF vr_des_erro <> 'OK' THEN
          IF vr_tab_erro.count > 0 THEN
            vr_cdcritic:= 0;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            pr_dscritic := vr_dscritic; 
            CONTINUE;
          END IF;
        END IF;
        
        vr_vlresgat := 0;

        vr_vlsomato_tmp := nvl(vr_vlrcotas,0);
        
        vr_vlresgat := nvl(vr_vlresgat,0);
        
        vr_vlsomato := nvl(vr_vlrcotas,0);
        
        vr_vlapagar := nvl(vr_vlapagar,0);
        vr_vlsomvld := 0;

        IF vr_idacaojd THEN
          vr_vlsomato_tmp := 0;
          vr_vlsomato     := 0;
        END IF;

        IF vr_blqconsig THEN
          vr_vlsomato_tmp := 0;
          vr_vlsomato     := 0;
        END IF;

        IF vr_flgemdia THEN 
            SAVEPOINT sav_trans_750;
            pc_verifica_pagamento (pr_vlsomato => vr_vlsomato           
                                  ,pr_inliquid => rw_crappep.inliquid   
                                  ,pr_flgpagpa => vr_flgpagpa           
                                  ,pr_des_reto => vr_des_erro);         

            IF vr_flultexe = 1 THEN
              BEGIN
                UPDATE crapepr
                  SET    crapepr.qtmesdec = nvl(crapepr.qtmesdec,0) + 1
                  WHERE  crapepr.rowid = rw_crapepr.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  cecred.pc_internal_exception;
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao atualizar crapepr. '||SQLERRM;
                  pr_dscritic := vr_dscritic;
                  RAISE vr_exc_saida;
              END;
            END IF;
            IF vr_des_erro <> 'OK' THEN
              vr_dscritic := 'Erro pc_verifica_pagamento';
              pr_dscritic := vr_dscritic;
              CONTINUE;
            END IF;

            IF vr_blqresg_cc = 'S' THEN
              rw_cde := NULL;
              rw_ret := NULL;

              OPEN  cr_cde(pr_cdcooper => rw_crappep.cdcooper
                          ,pr_nrdconta => rw_crappep.nrdconta
                          ,pr_nrctremp => rw_crappep.nrctremp);
              FETCH cr_cde INTO rw_cde;
              CLOSE cr_cde;

              IF nvl(rw_cde.nrdocmto,0) > 0 THEN
                IF vr_flgpagpa THEN
                  vr_flgpagpa := FALSE;
                END IF;
              ELSE

                OPEN  cr_ret(pr_cdcooper => rw_crappep.cdcooper
                            ,pr_nrdconta => rw_crappep.nrdconta
                            ,pr_nrctremp => rw_crappep.nrctremp
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
                FETCH cr_ret INTO rw_ret;
                CLOSE cr_ret;

                IF nvl(rw_ret.nrdocmto,0) > 0 THEN
                  IF vr_flgpagpa THEN
                    vr_flgpagpa := FALSE;
                  END IF;
                END IF;
              END IF;
            END IF;   

            vr_cdindice := LPAD(pr_cdcooper,10,'0') || LPAD(rw_crappep.nrdconta,10,'0') ||
                           LPAD(rw_crappep.nrctremp,10,'0');

            IF vr_tab_acordo.EXISTS(vr_cdindice) THEN
              vr_flgpagpa := FALSE;
            END IF;

            IF NOT vr_flgpagpa THEN
              vr_dtcalcul:= GENE0005.fn_valida_dia_util (pr_cdcooper => pr_cdcooper
                                                        ,pr_dtmvtolt => last_day(rw_crappep.dtvencto)
                                                        ,pr_tipo => 'A'
                                                        ,pr_excultdia => TRUE);
              vr_ehmensal:= rw_crappep.dtvencto > vr_dtcalcul;

              IF vr_flultexe = 1 THEN
          IF NOT ( rw_crapepr.tpdescto = 2 AND rw_crapepr.tpemprst = 1 ) THEN
            EMPR0001.pc_lanca_juro_contrato(pr_cdcooper    => pr_cdcooper
                           ,pr_cdagenci    => pr_cdagenci         
                           ,pr_nrdcaixa    => 0                   
                           ,pr_nrdconta    => rw_crappep.nrdconta 
                           ,pr_nrctremp    => rw_crappep.nrctremp 
                           ,pr_dtmvtolt    => rw_crapdat.dtmvtolt 
                           ,pr_cdoperad    => vr_cdoperad         
                           ,pr_cdpactra    => pr_cdagenci         
                           ,pr_flnormal    => TRUE                
                           ,pr_dtvencto    => rw_crappep.dtvencto 
                           ,pr_ehmensal    => vr_ehmensal         
                           ,pr_dtdpagto    => rw_crapepr.dtdpagto 
                           ,pr_tab_crawepr => vr_tab_crawepr      
                           ,pr_cdorigem    => 7                   
                           ,pr_vljurmes    => vr_vljurmes         
                           ,pr_diarefju    => vr_diarefju         
                           ,pr_mesrefju    => vr_mesrefju         
                           ,pr_anorefju    => vr_anorefju         
                           ,pr_des_reto    => vr_des_erro         
                           ,pr_tab_erro    => vr_tab_erro);       
            IF vr_des_erro <> 'OK' THEN
            IF vr_tab_erro.count > 0 THEN
              vr_cdcritic := 0;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              pr_dscritic := vr_dscritic;              
              ROLLBACK TO SAVEPOINT sav_trans_750;
              CONTINUE;
            END IF;
            END IF;
          END IF;
              END IF;
              IF nvl(vr_vljurmes,0) > 0 THEN
                BEGIN
                  UPDATE crapepr
                     SET crapepr.diarefju = nvl(vr_diarefju,0)
                       , crapepr.mesrefju = nvl(vr_mesrefju,0)
                       , crapepr.anorefju = nvl(vr_anorefju,0)
                       , crapepr.vlsdeved = nvl(crapepr.vlsdeved,0) + nvl(vr_vljurmes,0)
                       , crapepr.vljuratu = nvl(crapepr.vljuratu,0) + nvl(vr_vljurmes,0)
                       , crapepr.vljuracu = nvl(crapepr.vljuracu,0) + nvl(vr_vljurmes,0)
                   WHERE crapepr.rowid = rw_crapepr.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    cecred.pc_internal_exception;
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao atualizar crapepr. '||SQLERRM;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_saida;
                END;
              END IF;
              vr_dscritic := 'Sem valor suficiente para pagar parcela ou parcela ja liquidada';
              pr_dscritic := vr_dscritic;
              CONTINUE;

            END IF;
            IF rw_crapepr.tpdescto <> 2 THEN
            EMPR0001.pc_verifica_parcel_anteriores (pr_cdcooper => pr_cdcooper         
                                                   ,pr_nrdconta => rw_crappep.nrdconta 
                                                   ,pr_nrctremp => rw_crappep.nrctremp 
                                                   ,pr_nrparepr => rw_crappep.nrparepr 
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt 
                                                   ,pr_des_reto => vr_des_erro         
                                                   ,pr_dscritic => vr_dscritic);       
              IF vr_des_erro <> 'OK' THEN
                pr_dscritic := vr_dscritic;
                CONTINUE;
              END IF;
            END IF;
            
            IF nvl(vr_vlsomato,0) > nvl(vr_vlapagar,0) THEN
              vr_vlsomato:= vr_vlapagar;             
            END IF;

            IF rw_crapepr.tpdescto = 2 AND vr_inddebitador = 1 THEN
              EMPR0020.pc_gera_pagto_deb_uni_consig(pr_cdcooper => pr_cdcooper  
                                                   ,pr_cdagenci => pr_cdagenci  
                                                   ,pr_nrdcaixa => 0            
                                                   ,pr_cdoperad => vr_cdoperad  
                                                   ,pr_nmdatela => pr_nmdatela  
                                                   ,pr_idorigem => 7 
                                                   ,pr_cdpactra => pr_cdagenci  
                                                   ,pr_nrdconta => rw_crappep.nrdconta 
                                                   ,pr_idseqttl => 1 
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt 
                                                   ,pr_flgerlog => 'N'                 
                                                   ,pr_nrctremp => rw_crappep.nrctremp 
                                                   ,pr_nrparepr => rw_crappep.nrparepr 
                                                   ,pr_vlparpag => vr_vlsomato         
                                                   ,pr_vlsdvpar => rw_crappep.vlsdvpar 
                                                   ,pr_dtvencto => rw_crappep.dtvencto 
                                                   ,pr_cdlcremp => rw_crapepr.cdlcremp 
                                                   ,pr_tppagmto => 'D'                 
                                                   ,pr_vlrmulta => rw_crappep.vlmtapar 
                                                   ,pr_vlatraso => rw_crappep.vlmrapar 
                                                   ,pr_vliofcpl => rw_crappep.vliofcpl 
                                                   ,pr_des_reto => vr_des_erro   
                                                   ,pr_tab_erro => vr_tab_erro); 
           ELSE
             EMPR0001.pc_efetiva_pagto_parcela(pr_cdcooper => pr_cdcooper          
                                              ,pr_cdagenci => pr_cdagenci          
                                              ,pr_nrdcaixa => 0                    
                                              ,pr_cdoperad => vr_cdoperad          
                                              ,pr_nmdatela => pr_nmdatela          
                                              ,pr_idorigem => 7           
                                              ,pr_cdpactra => pr_cdagenci
                                              ,pr_nrdconta => rw_crappep.nrdconta  
                                              ,pr_idseqttl => 1       
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt  
                                              ,pr_flgerlog => 'S'                  
                                              ,pr_nrctremp => rw_crappep.nrctremp  
                                              ,pr_nrparepr => rw_crappep.nrparepr  
                                              ,pr_vlparepr => vr_vlsomato          
                                              ,pr_tab_crawepr => vr_tab_crawepr    
                                              ,pr_tab_erro => vr_tab_erro          
                                              ,pr_des_reto => vr_des_erro);        
           END IF;
            IF vr_des_erro <> 'OK' THEN
              IF vr_tab_erro.count > 0 THEN
                vr_cdcritic:= 0;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                pr_dscritic := vr_dscritic;
                ROLLBACK TO SAVEPOINT sav_trans_750;
                CONTINUE;
              END IF;
            END IF;

        ELSE
          IF rw_crapepr.tpdescto = 2 THEN
             IF vr_nrdialimiterepasse = 0 then
                 vr_vlsomato := 0;
                 vr_dscritic := 'Sem dia limite de Repasse consig.';
             ELSIF to_char(rw_crapdat.dtmvtolt,'DD') < (vr_nrdialimiterepasse) THEN
                 vr_vlsomato := 0;
                 vr_dscritic := 'Dia limite de Repasse consig Menor que hoje.';
             END IF;
             IF rw_crapdat.inproces > 1 then
                vr_dscritic := 'para operacao de consignado nao ira efetuar pagamentos na execucao noturna';
                pr_dscritic := vr_dscritic;
                CONTINUE;
             END IF;
          END IF;

          IF vr_blqresg_cc = 'S' THEN
            rw_cde := NULL;
            rw_ret := NULL;

            OPEN  cr_cde(pr_cdcooper => rw_crappep.cdcooper
                        ,pr_nrdconta => rw_crappep.nrdconta
                        ,pr_nrctremp => rw_crappep.nrctremp);
            FETCH cr_cde INTO rw_cde;
            CLOSE cr_cde;
            
            IF nvl(rw_cde.nrdocmto,0) > 0 THEN
              vr_vlsomato := 0;
              vr_dscritic := 'Boleto de contrato em aberto.';
            ELSE
              OPEN  cr_ret(pr_cdcooper => rw_crappep.cdcooper
                          ,pr_nrdconta => rw_crappep.nrdconta
                          ,pr_nrctremp => rw_crappep.nrctremp
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
              FETCH cr_ret INTO rw_ret;
              CLOSE cr_ret;

              IF nvl(rw_ret.nrdocmto,0) > 0 THEN
                vr_vlsomato := 0;
                vr_dscritic := 'Boleto de contrato pendente.';
              END IF;
            END IF; 
          END IF;

          vr_cdindice := LPAD(pr_cdcooper,10,'0')        ||
                         LPAD(rw_crappep.nrdconta,10,'0')||
                         LPAD(rw_crappep.nrctremp,10,'0');

          IF vr_tab_acordo.EXISTS(vr_cdindice) THEN
            vr_vlsomato := 0;
            vr_dscritic := 'Acordo encontrado.';
          END IF;

          IF (vr_vlsomato) <= 0 THEN
            vr_dscritic := vr_dscritic||' Pulou Parcela erro Se o saldo mais o valor de resgate são menores ou igual a zero';
            pr_dscritic := vr_dscritic;
            CONTINUE;
          END IF;

          IF rw_crapepr.tpdescto <> 2 THEN
         
          EMPR0001.pc_verifica_parcel_anteriores(pr_cdcooper => pr_cdcooper         
                                                ,pr_nrdconta => rw_crappep.nrdconta 
                                                ,pr_nrctremp => rw_crappep.nrctremp 
                                                ,pr_nrparepr => rw_crappep.nrparepr 
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt 
                                                ,pr_des_reto => vr_des_erro         
                                                ,pr_dscritic => vr_dscritic);       
          IF vr_des_erro <> 'OK' THEN
            pr_dscritic := vr_dscritic;
            CONTINUE;
            END IF;
          END IF;
          SAVEPOINT sav_trans_750;

          EMPR0001.pc_busca_pgto_parcelas(pr_cdcooper => pr_cdcooper                
                                         ,pr_cdagenci => pr_cdagenci                
                                         ,pr_nrdcaixa => 0                          
                                         ,pr_cdoperad => vr_cdoperad                
                                         ,pr_nmdatela => pr_nmdatela                
                                         ,pr_idorigem => 7              
                                         ,pr_nrdconta => rw_crappep.nrdconta        
                                         ,pr_idseqttl => 1                          
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt        
                                         ,pr_flgerlog => 'N'                        
                                         ,pr_nrctremp => rw_crappep.nrctremp        
                                         ,pr_dtmvtoan => rw_crapdat.dtmvtoan        
                                         ,pr_nrparepr => rw_crappep.nrparepr        
                                         ,pr_des_reto => vr_des_erro                
                                         ,pr_tab_erro => vr_tab_erro                
                                         ,pr_tab_pgto_parcel => vr_tab_pgto_parcel  
                                         ,pr_tab_calculado   => vr_tab_calculado);  
          IF vr_des_erro <> 'OK' THEN
            IF vr_tab_erro.count > 0 THEN
              vr_cdcritic := 0;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              pr_dscritic := vr_dscritic;
              ROLLBACK TO SAVEPOINT sav_trans_750;
              CONTINUE;
            END IF;
          END IF;

          vr_index_pgto_parcel := vr_tab_pgto_parcel.FIRST;

          IF vr_index_pgto_parcel IS NOT NULL THEN
            IF nvl(vr_vlsomato,0) > nvl(vr_tab_pgto_parcel(vr_index_pgto_parcel).vlatrpag,0) THEN
              vr_vlsomato:= nvl(vr_tab_pgto_parcel(vr_index_pgto_parcel).vlatrpag,0);
            END IF;
          END IF;
          
          IF rw_crapepr.tpdescto = 2 THEN
             EMPR0020.pc_gera_pagto_deb_uni_consig(pr_cdcooper => pr_cdcooper  
                                                  ,pr_cdagenci => pr_cdagenci  
                                                  ,pr_nrdcaixa => 0            
                                                  ,pr_cdoperad => vr_cdoperad  
                                                  ,pr_nmdatela => pr_nmdatela  
                                                  ,pr_idorigem => 7            
                                                  ,pr_cdpactra => pr_cdagenci  
                                                  ,pr_nrdconta => rw_crappep.nrdconta 
                                                  ,pr_idseqttl => 1  
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt 
                                                  ,pr_flgerlog => 'N'                 
                                                  ,pr_nrctremp => rw_crappep.nrctremp 
                                                  ,pr_nrparepr => rw_crappep.nrparepr 
                                                  ,pr_vlparpag => vr_vlsomato         
                                                  ,pr_vlsdvpar => nvl(vr_tab_pgto_parcel(vr_index_pgto_parcel).vlatrpag,0)
                                                  ,pr_dtvencto => rw_crappep.dtvencto 
                                                  ,pr_cdlcremp => rw_crapepr.cdlcremp 
                                                  ,pr_tppagmto => 'A'                 
                                                  ,pr_vlrmulta => rw_crappep.vlmtapar 
                                                  ,pr_vlatraso => rw_crappep.vlmrapar 
                                                  ,pr_vliofcpl => rw_crappep.vliofcpl 
                                                  ,pr_des_reto => vr_des_erro
                                                  ,pr_tab_erro => vr_tab_erro);
          ELSE
            EMPR0001.pc_efetiva_pagto_atr_parcel(pr_cdcooper => pr_cdcooper           
                                                ,pr_cdagenci => pr_cdagenci           
                                                ,pr_nrdcaixa => 0                     
                                                ,pr_cdoperad => vr_cdoperad           
                                                ,pr_nmdatela => pr_nmdatela           
                                                ,pr_idorigem => 7                     
                                                ,pr_cdpactra => pr_cdagenci           
                                                ,pr_nrdconta => rw_crappep.nrdconta   
                                                ,pr_idseqttl => 1                     
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt   
                                                ,pr_flgerlog => 'N'                   
                                                ,pr_nrctremp => rw_crappep.nrctremp   
                                                ,pr_nrparepr => rw_crappep.nrparepr   
                                                ,pr_vlpagpar => vr_vlsomato           
                                                ,pr_tab_crawepr => vr_tab_crawepr     
                                                ,pr_des_reto => vr_des_erro           
                                                ,pr_tab_erro => vr_tab_erro);         
          END IF;
          IF vr_des_erro <> 'OK' THEN
            ROLLBACK TO SAVEPOINT sav_trans_750;
                                  
            vr_dscritic := vr_dscritic||' '||vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            pr_dscritic := vr_dscritic;                     
            CONTINUE;
          END IF;

        END IF;
        
        pr_vlsobras := pr_vlsobras - vr_vlsomato;
        dbms_output.put_line('Valor Pago: ' || vr_vlsomato);

      END LOOP;

      pc_limpa_tabela;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        
        ROLLBACK;

      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

  END CRPS750_PAGAMENTO;
    
BEGIN
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto,
                           pr_nmarquiv => vr_arq_leitura,
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_ind_arquiv,
                           pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,
                               pr_des_text => vr_linha);
  LOOP
    BEGIN
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,
                                   pr_des_text => vr_linha);
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;
    END;
    
    vr_campo    := GENE0002.fn_quebra_string(pr_string  => vr_linha,
                                             pr_delimit => ';');
                                             
    vr_indsobra := GENE0002.fn_char_para_number(vr_campo(1))||GENE0002.fn_char_para_number(vr_campo(2));                                                 
  
    vr_tab_contrato(vr_indsobra).cdcooper  := GENE0002.fn_char_para_number(vr_campo(1));
    vr_tab_contrato(vr_indsobra).nrdconta  := GENE0002.fn_char_para_number(vr_campo(2));   
    IF TRIM(vr_tab_contrato(vr_indsobra).contratos) IS NOT NULL THEN
      vr_tab_contrato(vr_indsobra).contratos := vr_tab_contrato(vr_indsobra).contratos||' , '||vr_campo(3);
    ELSE 
      vr_tab_contrato(vr_indsobra).contratos := vr_campo(3);
    END IF;    
    vr_tab_contrato(vr_indsobra).cotas := NVL(vr_tab_contrato(vr_indsobra).cotas,0) + NVL(GENE0002.fn_char_para_number(vr_campo(4)),0);  
  END LOOP; 
  
  vr_indsobra := vr_tab_contrato.FIRST;
  
  WHILE vr_indsobra IS NOT NULL LOOP
              
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_tab_contrato(vr_indsobra).cdcooper);   
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      vr_cdcritic:= 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;
   
    vr_cotas := 0;   
    vr_pago := 0;
    vr_pago_total := 0;

    vr_seq   := 0;    
    vr_seqerro := vr_seqerro+1;
    vr_cotas := vr_tab_contrato(vr_indsobra).cotas;
    
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('Inicio Analise na COOP/CONTA: ' || vr_tab_contrato(vr_indsobra).cdcooper ||' / '||vr_tab_contrato(vr_indsobra).nrdconta); 
    
    
    
    IF vr_cotas > 0 THEN      
      FOR rw_atraso_pp IN cr_atraso_pp (pr_cdcooper => vr_tab_contrato(vr_indsobra).cdcooper
                                       ,pr_nrdconta => vr_tab_contrato(vr_indsobra).nrdconta
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_dtmvtoan => rw_crapdat.dtmvtoan) LOOP
        
        vr_inderro := vr_seqerro||rw_atraso_pp.nrctremp;
                                      
        IF vr_tab_contrato_erro.exists(vr_inderro) THEN 
          IF vr_tab_contrato_erro(vr_inderro).cdcooper = rw_atraso_pp.cdcooper AND
             vr_tab_contrato_erro(vr_inderro).nrdconta = rw_atraso_pp.nrdconta AND
             vr_tab_contrato_erro(vr_inderro).contrato = rw_atraso_pp.nrctremp THEN
            CONTINUE; 
          END IF;
        END IF; 
                                                                                                                                                    
        dbms_output.put_line('');
        dbms_output.put_line('ATRASO');
        dbms_output.put_line('Contrato: '|| rw_atraso_pp.nrctremp ||' Parcela: ' || rw_atraso_pp.nrparepr);                                
        dbms_output.put_line('Valor Cotas LANÇADA para pagar ATRASO: ' || vr_cotas);
          
        vr_seq := vr_seq+1;
        dbms_output.put_line('SEQUENCIA DE PAGAMENTOS: ' || vr_seq);  
                                                                                                                                                                                           
        CRPS750_PAGAMENTO(pr_cdcooper => rw_atraso_pp.cdcooper
                         ,pr_nrdconta => rw_atraso_pp.nrdconta
                         ,pr_nrctremp => rw_atraso_pp.nrctremp
                         ,pr_nrparepr => rw_atraso_pp.nrparepr
                         ,pr_cdagenci => rw_atraso_pp.cdagenci
                         ,pr_vlrcotas => vr_cotas
                         ,pr_nmdatela => 'CRPS750_BACEN'
                         ,pr_vlsobras => vr_vlrsobra
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
                                          
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          dbms_output.put_line('Erro principal CRPS750_PAGAMENTO (Atraso): ' || vr_dscritic); 
                             
          vr_tab_contrato_erro(vr_inderro).cdcooper := rw_atraso_pp.cdcooper;
          vr_tab_contrato_erro(vr_inderro).nrdconta := rw_atraso_pp.nrdconta;
          vr_tab_contrato_erro(vr_inderro).contrato := rw_atraso_pp.nrctremp;          
          CONTINUE;
        END IF;
        
        vr_pago := vr_cotas - vr_vlrsobra;
        vr_pago_total := vr_pago_total + vr_pago;
        
        vr_cotas := vr_vlrsobra;
                
        dbms_output.put_line('Sobrou de COTAS: ' || vr_cotas);
                
        IF vr_cotas <= 0 THEN
          dbms_output.put_line('');
          dbms_output.put_line('Sem saldo para continuar pagamentos de ATRASO CONTRATO: ' || vr_cotas);
          EXIT;
        END IF;                                                                       
      END LOOP;
    END IF;        
    
    
    
    IF vr_cotas > 0 THEN                             
      vr_cursor :=     'SELECT crappep.cdcooper
                             , crappep.nrdconta
                             , crappep.nrctremp
                             , crappep.nrparepr
                             , crapass.cdagenci
                             , crapepr.txmensal
                             , NVL((SELECT COUNT(pep.nrparepr) FROM crappep pep
                                                  WHERE pep.cdcooper = crappep.cdcooper
                                                   AND pep.nrdconta = crappep.nrdconta
                                                   AND pep.nrctremp = crappep.nrctremp
                                                   AND pep.dtvencto >= '''||TO_DATE(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||''' 
                                                   AND pep.inprejuz = 0
                                                   AND pep.inliquid = 0),0)qtd_parc_aberto 
                  
                              FROM crawepr
                                 , crapass
                                 , crappep
                                 , crapepr
                             WHERE crawepr.cdcooper (+) = crappep.cdcooper
                               AND crawepr.nrdconta (+) = crappep.nrdconta
                               AND crawepr.nrctremp (+) = crappep.nrctremp
                               AND crapass.cdcooper = crappep.cdcooper
                               AND crapass.nrdconta = crappep.nrdconta
                               AND crapass.nrdconta = '||vr_tab_contrato(vr_indsobra).nrdconta||'
                               AND crappep.nrctremp IN ('||vr_tab_contrato(vr_indsobra).contratos||')
                               AND crappep.cdcooper = '||vr_tab_contrato(vr_indsobra).cdcooper||'
                               AND crappep.dtvencto >= '''||TO_DATE(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||'''  
                               AND crappep.inprejuz = 0
                               AND crawepr.flgpagto <> 2
                               AND crappep.inliquid = 0
                               AND crapepr.cdcooper = crappep.cdcooper
                               AND crapepr.nrdconta = crappep.nrdconta
                               AND crapepr.nrctremp = crappep.nrctremp
                               AND crapepr.tpemprst = 1
                               AND crapepr.inliquid = 0
                               AND crapepr.inprejuz = 0          
                               ORDER BY crapepr.txmensal DESC
                                      , qtd_parc_aberto  DESC
                                      , crappep.cdcooper
                                      , crappep.nrdconta
                                      , crappep.nrctremp
                                      , crappep.nrparepr DESC'; 
                                       
                                       
      vr_nrcursor := dbms_sql.open_cursor;
      dbms_sql.parse(vr_nrcursor, vr_cursor, 1);

      dbms_sql.define_column(vr_nrcursor, 1, vr_cdcooper ,4000);
      dbms_sql.define_column(vr_nrcursor, 2, vr_nrdconta ,4000);
      dbms_sql.define_column(vr_nrcursor, 3, vr_nrctremp ,4000);
      dbms_sql.define_column(vr_nrcursor, 4, vr_nrparepr ,4000);
      dbms_sql.define_column(vr_nrcursor, 5, vr_cdagenci ,4000);      
        
      vr_nrretorn := dbms_sql.execute(vr_nrcursor);
            
      LOOP 
        vr_nrretorn := dbms_sql.fetch_rows(vr_nrcursor);
        IF vr_nrretorn = 0 THEN
          IF dbms_sql.is_open(vr_nrcursor) THEN
            dbms_sql.close_cursor(vr_nrcursor);
          END IF;
          EXIT;
        ELSE 

          dbms_sql.column_value(vr_nrcursor, 1, vr_cdcooper);
          dbms_sql.column_value(vr_nrcursor, 2, vr_nrdconta);
          dbms_sql.column_value(vr_nrcursor, 3, vr_nrctremp);
          dbms_sql.column_value(vr_nrcursor, 4, vr_nrparepr);
          dbms_sql.column_value(vr_nrcursor, 5, vr_cdagenci); 
          
          vr_cdcooper := GENE0002.fn_char_para_number(vr_cdcooper);    
          vr_nrdconta := GENE0002.fn_char_para_number(vr_nrdconta);
          vr_nrctremp := GENE0002.fn_char_para_number(vr_nrctremp);
          vr_nrparepr := GENE0002.fn_char_para_number(vr_nrparepr);
          vr_cdagenci := GENE0002.fn_char_para_number(vr_cdagenci);
           
          vr_inderro := vr_seqerro||vr_nrctremp;
          
          IF vr_tab_contrato_erro.exists(vr_inderro) THEN
            IF vr_tab_contrato_erro(vr_inderro).cdcooper = vr_cdcooper AND
               vr_tab_contrato_erro(vr_inderro).nrdconta = vr_nrdconta AND
               vr_tab_contrato_erro(vr_inderro).contrato = vr_nrctremp THEN
              CONTINUE; 
            END IF;                                                                                                                                                 
          END IF;
                           
          dbms_output.put_line('');   
          dbms_output.put_line('CONTRATO PLANILHA'); 
          dbms_output.put_line('Contrato: '|| vr_nrctremp ||' Parcela: ' || vr_nrparepr);                                
          dbms_output.put_line('Valor Cotas LANÇADA para pagar CONTRATO: ' || vr_cotas);  
          
          vr_seq := vr_seq+1;
          dbms_output.put_line('SEQUENCIA DE PAGAMENTOS: ' || vr_seq);
                                                                                                                                                                                                                                                                    
          CRPS750_PAGAMENTO(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => vr_nrdconta
                           ,pr_nrctremp => vr_nrctremp
                           ,pr_nrparepr => vr_nrparepr
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_vlrcotas => vr_cotas
                           ,pr_nmdatela => 'CRPS750_BACEN'
                           ,pr_vlsobras => vr_vlrsobra
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
                                                  
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            dbms_output.put_line('ERRO PRINCIPAL CRPS750_PAGAMENTO (ORIGINADOR): ' || vr_dscritic);
                        
            vr_tab_contrato_erro(vr_inderro).cdcooper := vr_cdcooper;
            vr_tab_contrato_erro(vr_inderro).nrdconta := vr_nrdconta;
            vr_tab_contrato_erro(vr_inderro).contrato := vr_nrctremp;                    
            CONTINUE;
          END IF;

          vr_pago := vr_cotas - vr_vlrsobra;
          vr_pago_total := vr_pago_total + vr_pago;
                                 
          vr_cotas := vr_vlrsobra;
                    
          dbms_output.put_line('Sobrou de COTAS: ' || vr_cotas);
                        
          IF vr_cotas <= 0 THEN
            dbms_output.put_line('');
            dbms_output.put_line('Sem saldo para continuar pagamentos de ANTECIPACAO CONTRATO PLANILHA: ' || vr_cotas);
            EXIT;
          END IF;                            
        END IF;                                                                         
      END LOOP;
    END IF;  
        
    
    
    IF vr_cotas > 0 THEN  
      FOR rw_sobra_antecipa_pp IN cr_sobra_antecipa_pp (pr_cdcooper => vr_tab_contrato(vr_indsobra).cdcooper
                                                       ,pr_nrdconta => vr_tab_contrato(vr_indsobra).nrdconta
                                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
                                                       
        vr_inderro := vr_seqerro||rw_sobra_antecipa_pp.nrctremp;        
        IF vr_tab_contrato_erro.exists(vr_inderro) THEN                                           
          IF vr_tab_contrato_erro(vr_inderro).cdcooper = rw_sobra_antecipa_pp.cdcooper AND
             vr_tab_contrato_erro(vr_inderro).nrdconta = rw_sobra_antecipa_pp.nrdconta AND
             vr_tab_contrato_erro(vr_inderro).contrato = rw_sobra_antecipa_pp.nrctremp THEN
            CONTINUE; 
          END IF;                                                                                                                                      
        END IF;
                                                                                                                                                                     
        dbms_output.put_line('');  
        dbms_output.put_line('CONTRATO ANTECIPADO GERAL');
        dbms_output.put_line('Contrato: '|| rw_sobra_antecipa_pp.nrctremp ||' Parcela: ' || rw_sobra_antecipa_pp.nrparepr);                                
        dbms_output.put_line('Valor Cotas LANÇADA para pagar ANTECIPADO GERAL: ' || vr_cotas);
          
        vr_seq := vr_seq+1;
        dbms_output.put_line('SEQUENCIA DE PAGAMENTOS: ' || vr_seq);
                                                                                                                                                                                                               
        CRPS750_PAGAMENTO(pr_cdcooper => rw_sobra_antecipa_pp.cdcooper
                        ,pr_nrdconta => rw_sobra_antecipa_pp.nrdconta
                        ,pr_nrctremp => rw_sobra_antecipa_pp.nrctremp
                        ,pr_nrparepr => rw_sobra_antecipa_pp.nrparepr
                        ,pr_cdagenci => rw_sobra_antecipa_pp.cdagenci
                        ,pr_vlrcotas => vr_cotas
                        ,pr_nmdatela => 'CRPS750_BACEN'
                        ,pr_vlsobras => vr_vlrsobra
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic);
                                        
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          dbms_output.put_line('ERRO PRINCIPAL CRPS750_PAGAMENTO (GERAL): ' || vr_dscritic);
          
          vr_tab_contrato_erro(vr_inderro).cdcooper := rw_sobra_antecipa_pp.cdcooper;
          vr_tab_contrato_erro(vr_inderro).nrdconta := rw_sobra_antecipa_pp.nrdconta;
          vr_tab_contrato_erro(vr_inderro).contrato := rw_sobra_antecipa_pp.nrctremp;              
          CONTINUE;
        END IF;
        
        vr_pago := vr_cotas - vr_vlrsobra; 
        vr_pago_total := vr_pago_total + vr_pago;
                   
        vr_cotas := vr_vlrsobra;
            
        dbms_output.put_line('Sobrou de COTAS: ' || vr_cotas); 
              
        IF vr_cotas <= 0 THEN
          dbms_output.put_line('');
          dbms_output.put_line('Sem saldo para continuar pagamentos de ANTECIPACAO GERAL: '|| vr_cotas);
          EXIT;
        END IF;                                                                                                             
      END LOOP;
    END IF;
      
  dbms_output.put_line('Pagou TOTAL: ' || nvl(vr_pago_total,0)); 
  dbms_output.put_line('Sobrou de COTAS geral: ' || vr_cotas);    
                                    
  vr_indsobra := vr_tab_contrato.NEXT(vr_indsobra);
  END LOOP;        
COMMIT;  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line('ERRO BACA: ' || SQLERRM ||vr_dscritic);                                                             
END;
