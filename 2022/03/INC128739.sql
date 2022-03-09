declare
  vr_cdcooper  crapcop.cdcooper%TYPE; 

  vr_cdprogra        CONSTANT crapprg.cdprogra%TYPE := 'CRPS720';

  vr_exc_saida       EXCEPTION;
  vr_cdcritic        PLS_INTEGER;
  vr_dscritic        VARCHAR2(4000);

  vr_idprglog        NUMBER := 0;
  vr_qtdias_carencia NUMBER := 0;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/inc0128739';
  vr_nmarqimp        VARCHAR2(100)  := 'inc0128739_rollback.txt';   
  vr_ind_arquiv      utl_file.file_type;
  
  vr_vltotal_juros      NUMBER(12,2);
  vr_vltotal_parcela    NUMBER(12,2);    
  vr_vltotal_pago       NUMBER(12,2);

  CURSOR cr_epr_pep IS
    SELECT crapepr.cdagenci,
           crapepr.nrdconta,
           crapepr.nrctremp,
           crapepr.dtmvtolt,
           crapepr.qtpreemp,
           crapepr.vlsprojt,
           crawepr.dtdpagto,
           crapepr.vlemprst,
           crapepr.cdlcremp,
           crawepr.txmensal,
           crawepr.idcarenc,
           crawepr.cddindex,
           ROW_NUMBER() OVER(PARTITION BY crapepr.nrdconta ORDER BY crapepr.cdcooper, crapepr.nrdconta) AS numconta,
           COUNT(1) OVER(PARTITION BY crapepr.nrdconta) qtdconta,
           crawepr.cdcooper,
           pep1.dtvencto dtaniversario,
           crapepr.vlpreemp,
           pep1.vlparepr, 
           pep1.vlsdvpar,
           pep1.nrparepr
      FROM crapepr
      JOIN crawepr
        ON crawepr.cdcooper = crapepr.cdcooper
       AND crawepr.nrdconta = crapepr.nrdconta
       AND crawepr.nrctremp = crapepr.nrctremp
      JOIN crappep pep1
        ON pep1.cdcooper = crapepr.cdcooper
       AND pep1.nrdconta = crapepr.nrdconta
       AND pep1.nrctremp = crapepr.nrctremp
       AND pep1.dtvencto BETWEEN to_date('26/02/2022', 'dd/mm/yyyy') AND to_date('27/02/2022', 'dd/mm/yyyy')
     WHERE crapepr.tpemprst = 2 
       AND crapepr.inliquid = 0;

  CURSOR cr_crappep(vr_cdcooper IN crappep.cdcooper%TYPE,
                    pr_nrdconta IN crappep.nrdconta%TYPE,
                    pr_nrctremp IN crappep.nrctremp%TYPE) IS
    SELECT crappep.nrparepr, crappep.dtvencto, crappep.vltaxatu
      FROM crappep
     WHERE crappep.cdcooper = vr_cdcooper
       and crappep.nrdconta = pr_nrdconta
       and crappep.nrctremp = pr_nrctremp
       and crappep.inliquid = 0
       and crappep.dtvencto > to_date('27/02/2022', 'dd/mm/yyyy')
       and EXISTS (select 1
              from crappep pep
             where pep.cdcooper = crappep.cdcooper
               and pep.nrdconta = crappep.nrdconta
               and pep.nrctremp = crappep.nrctremp
               AND pep.dtvencto >= to_date('26/03/2022', 'dd/mm/yyyy')
               AND pep.dtvencto <= to_date('27/03/2022', 'dd/mm/yyyy')) 
       and rownum = 1
     order by crappep.nrparepr asc;
  rw_crappep cr_crappep%ROWTYPE;

  CURSOR cr_carencia IS
    SELECT param.idcarencia, param.qtddias
      FROM tbepr_posfix_param_carencia param
     WHERE param.idparametro = 1;

  CURSOR cr_vltotal_pag_par(pr_cdcooper IN crappep.cdcooper%TYPE
                         ,pr_nrdconta IN crappep.nrdconta%TYPE
                         ,pr_nrctremp IN crappep.nrctremp%TYPE) IS  
  SELECT SUM(crappep.vlpagpar)
    FROM crappep
   WHERE crappep.cdcooper = pr_cdcooper
     AND crappep.nrdconta = pr_nrdconta
     AND crappep.nrctremp = pr_nrctremp;
         
CURSOR cr_vltotal_pago_princ(pr_cdcooper IN crappep.cdcooper%TYPE
                            ,pr_nrdconta IN crappep.nrdconta%TYPE
                            ,pr_nrctremp IN crappep.nrctremp%TYPE
                            ,pr_dtvencto IN crappep.dtvencto%TYPE) IS   
  SELECT SUM(crappep.vlpagpar)
    FROM crappep
   WHERE crappep.cdcooper = pr_cdcooper
     AND crappep.nrdconta = pr_nrdconta
     AND crappep.nrctremp = pr_nrctremp
     AND crappep.inliquid = 1;
         
CURSOR cr_vltotal_parcela(pr_cdcooper IN crappep.cdcooper%TYPE
                         ,pr_nrdconta IN crappep.nrdconta%TYPE
                         ,pr_nrctremp IN crappep.nrctremp%TYPE
                         ,pr_dtvencto IN crappep.dtvencto%TYPE) IS
  SELECT SUM(crappep.vlparepr)
    FROM crappep
   WHERE crappep.cdcooper = pr_cdcooper
     AND crappep.nrdconta = pr_nrdconta
     AND crappep.nrctremp = pr_nrctremp
     AND crappep.dtvencto <= pr_dtvencto
     AND crappep.inliquid = 0;
    
CURSOR cr_vltotal_juros(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
  SELECT SUM(vllanmto)
    FROM craplem 
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta
     AND nrctremp = pr_nrctremp
     AND cdhistor in (2343,2342,2345,2344);

  TYPE typ_parc_atu IS RECORD(
    cdcooper crappep.cdcooper%TYPE,
    nrdconta crappep.nrdconta%TYPE,
    nrctremp crappep.nrctremp%TYPE,
    nrparepr crappep.nrparepr%TYPE,
    vlparepr crappep.vlparepr%TYPE,
    vltaxatu crappep.vltaxatu%TYPE,
    vlsprojt crapepr.vlsprojt%TYPE);

  TYPE typ_tab_parc_atu IS TABLE OF typ_parc_atu INDEX BY PLS_INTEGER;

  vr_tab_parc_epr typ_tab_parc_atu;
  vr_tab_parc_pep typ_tab_parc_atu;
  vr_tab_parcelas EMPR0011.typ_tab_parcelas;
  vr_tab_carencia CADA0001.typ_tab_number;
  vr_tab_craplcr  CADA0001.typ_tab_number;
  vr_tab_craptxi  CADA0001.typ_tab_number;


  vr_idx_parc_epr    PLS_INTEGER;
  vr_idx_parc_pep    PLS_INTEGER;
  vr_idx_parcelas    INTEGER;
  vr_qtdconta        INTEGER;

  PROCEDURE pc_grava_dados(pr_tab_parc_pep IN typ_tab_parc_atu,
                           pr_tab_parc_epr IN typ_tab_parc_atu) IS
    vr_nrdconta crapass.nrdconta%TYPE;
  BEGIN

    BEGIN
      FORALL idx IN 1 .. pr_tab_parc_pep.COUNT SAVE EXCEPTIONS
        UPDATE crappep
           SET vlparepr = pr_tab_parc_pep(idx).vlparepr,
               vlsdvpar = pr_tab_parc_pep(idx)
                          .vlparepr - (nvl(crappep.vlpagpar, 0) +
                                       nvl(crappep.vldespar, 0)),
               vltaxatu = pr_tab_parc_pep(idx).vltaxatu
         WHERE cdcooper = pr_tab_parc_pep(idx).cdcooper
           AND nrdconta = pr_tab_parc_pep(idx).nrdconta
           AND nrctremp = pr_tab_parc_pep(idx).nrctremp
           AND nrparepr = pr_tab_parc_pep(idx).nrparepr
           AND inliquid = 0;
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
      
        FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
          cecred.pc_log_programa(PR_DSTIPLOG   => 'E',
                                 PR_CDPROGRAMA => vr_cdprogra,
                                 pr_cdcooper   => vr_cdcooper,
                                 pr_dsmensagem => 'crappep -' ||
                                                  ' cdcooper: ' || pr_tab_parc_pep(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).cdcooper ||
                                                  ' nrdconta: ' || pr_tab_parc_pep(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrdconta ||
                                                  ' nrctremp: ' || pr_tab_parc_pep(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrctremp ||
                                                  ' nrparepr: ' || pr_tab_parc_pep(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrparepr ||
                                                  ' vlparepr: ' || pr_tab_parc_pep(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vlparepr ||
                                                  ' vltaxatu: ' || pr_tab_parc_pep(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vltaxatu ||
                                                  ' Oracle error: ' ||
                                                  SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE),
                                 PR_IDPRGLOG   => vr_idprglog);
        END LOOP;
      
        vr_dscritic := 'Erro ao atualizar crappep: ' ||
                       SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_saida;
    END;

    BEGIN
      FORALL idx IN 1 .. pr_tab_parc_epr.COUNT SAVE EXCEPTIONS
        UPDATE crapepr
           SET vlpreemp = pr_tab_parc_epr(idx).vlparepr
              ,vlsprojt = pr_tab_parc_epr(idx).vlsprojt
         WHERE cdcooper = pr_tab_parc_epr(idx).cdcooper
           AND nrdconta = pr_tab_parc_epr(idx).nrdconta
           AND nrctremp = pr_tab_parc_epr(idx).nrctremp;
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
      
        FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
          cecred.pc_log_programa(PR_DSTIPLOG   => 'E',
                                 PR_CDPROGRAMA => vr_cdprogra,
                                 pr_cdcooper   => vr_cdcooper,
                                 pr_dsmensagem => 'crapepr -' ||
                                                  ' cdcooper: ' || pr_tab_parc_epr(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).cdcooper ||
                                                  ' nrdconta: ' || pr_tab_parc_epr(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrdconta ||
                                                  ' nrctremp: ' || pr_tab_parc_epr(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrctremp ||
                                                  ' vlpreemp: ' || pr_tab_parc_epr(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vlparepr ||
                                                  ' Oracle error: ' ||
                                                  SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE),
                                 PR_IDPRGLOG   => vr_idprglog);
        END LOOP;
      
        vr_dscritic := 'Erro ao atualizar crapepr: ' ||
                       SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_saida;
    END;
  
    vr_nrdconta := 0;
    IF pr_tab_parc_epr.COUNT > 0 THEN
      vr_nrdconta := pr_tab_parc_epr(pr_tab_parc_epr.LAST).nrdconta;
    END IF;
  
    COMMIT;
  END pc_grava_dados;
  
  FUNCTION f_busca_valores (pr_cdcooper crappep.cdcooper%type,
                            pr_nrdconta crappep.nrdconta%type,
                            pr_nrctremp crappep.nrctremp%type,
                            pr_nrparepr crappep.nrparepr%type) return varchar2 is
      vr_texto varchar2(100);                      
    BEGIN
      select  'set   vlparepr = ' || replace(vlparepr, ',','.') || ',vlsdvpar = ' || replace(vlsdvpar, ',','.')
        into vr_texto
        from crappep
       where cdcooper = pr_cdcooper
       and   nrdconta = pr_nrdconta
       and   nrctremp = pr_nrctremp
       and   nrparepr = pr_nrparepr;
       
       RETURN vr_texto;
  EXCEPTION
       WHEN OTHERS THEN
         null;
    
  end f_busca_valores;

BEGIN

  GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                             pr_action => 'PC_' || vr_cdprogra || '_1');

  vr_qtdconta := 0;

  vr_tab_parc_epr.DELETE;
  vr_tab_parc_pep.DELETE;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto 
                          ,pr_nmarquiv => vr_nmarqimp 
                          ,pr_tipabert => 'W'    
                          ,pr_utlfileh => vr_ind_arquiv 
                          ,pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_exc_saida;
  END IF;    
  

  FOR rw_carencia IN cr_carencia LOOP
    vr_tab_carencia(rw_carencia.idcarencia) := rw_carencia.qtddias;
  END LOOP;

  FOR rw_epr_pep IN cr_epr_pep LOOP

    OPEN cr_crappep(vr_cdcooper => rw_epr_pep.cdcooper,
                    pr_nrdconta => rw_epr_pep.nrdconta,
                    pr_nrctremp => rw_epr_pep.nrctremp);
    FETCH cr_crappep
    INTO rw_crappep;


    IF cr_crappep%NOTFOUND THEN
      CLOSE cr_crappep;
      CONTINUE;
    END IF;
    CLOSE cr_crappep;
  
    vr_tab_parcelas.DELETE;
  
    vr_qtdias_carencia := 0; 
  
    IF vr_tab_carencia.EXISTS(rw_epr_pep.idcarenc) THEN
      vr_qtdias_carencia := vr_tab_carencia(rw_epr_pep.idcarenc);
    END IF;
    
    vr_vltotal_pago := 0;
    OPEN cr_vltotal_pago_princ(pr_cdcooper => rw_epr_pep.cdcooper
                              ,pr_nrdconta => rw_epr_pep.nrdconta
                              ,pr_nrctremp => rw_epr_pep.nrctremp
                              ,pr_dtvencto => rw_epr_pep.dtdpagto);
    FETCH cr_vltotal_pago_princ INTO vr_vltotal_pago;
    CLOSE cr_vltotal_pago_princ;
      
    vr_vltotal_juros := 0;
    OPEN cr_vltotal_juros(pr_cdcooper => rw_epr_pep.cdcooper
                         ,pr_nrdconta => rw_epr_pep.nrdconta
                         ,pr_nrctremp => rw_epr_pep.nrctremp);
    FETCH cr_vltotal_juros INTO vr_vltotal_juros;
    CLOSE cr_vltotal_juros;
        
    vr_vltotal_parcela := 0;
    OPEN cr_vltotal_parcela(pr_cdcooper => rw_epr_pep.cdcooper
                           ,pr_nrdconta => rw_epr_pep.nrdconta
                           ,pr_nrctremp => rw_epr_pep.nrctremp
                           ,pr_dtvencto => to_date('26/02/2022','dd/mm/yyyy'));
    FETCH cr_vltotal_parcela INTO vr_vltotal_parcela;
    CLOSE cr_vltotal_parcela;
        
    vr_idx_parc_epr := vr_tab_parc_epr.COUNT + 1;
    vr_tab_parc_epr(vr_idx_parc_epr).vlsprojt := NVL(rw_epr_pep.vlemprst,0) + 
                                                 NVL(vr_vltotal_juros,0) - 
                                                 NVL(vr_vltotal_parcela,0) - 
                                                 NVL(vr_vltotal_pago,0);
                       

    EMPR0011.pc_calcula_prox_parcela_pos(pr_cdcooper        => rw_epr_pep.cdcooper,
                                         pr_flgbatch        => TRUE,
                                         pr_dtcalcul        => rw_epr_pep.dtaniversario,
                                         pr_nrdconta        => rw_epr_pep.nrdconta,
                                         pr_nrctremp        => rw_epr_pep.nrctremp,
                                         pr_dtefetiv        => rw_epr_pep.dtmvtolt,
                                         pr_dtdpagto        => rw_epr_pep.dtdpagto,
                                         pr_txmensal        => rw_epr_pep.txmensal,
                                         pr_vlrdtaxa        => rw_crappep.vltaxatu,
                                         pr_qtpreemp        => rw_epr_pep.qtpreemp,
                                         pr_vlsprojt        => vr_tab_parc_epr(vr_idx_parc_epr).vlsprojt, 
                                         pr_vlemprst        => rw_epr_pep.vlemprst,
                                         pr_nrparepr        => rw_crappep.nrparepr,
                                         pr_dtvencto        => rw_crappep.dtvencto,
                                         pr_qtdias_carencia => vr_qtdias_carencia,
                                         pr_tab_parcelas    => vr_tab_parcelas,
                                         pr_cdcritic        => vr_cdcritic,
                                         pr_dscritic        => vr_dscritic);

    IF NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    vr_idx_parcelas := vr_tab_parcelas.FIRST;
    WHILE vr_idx_parcelas IS NOT NULL LOOP
      vr_idx_parc_pep := vr_tab_parc_pep.COUNT + 1;
      vr_tab_parc_pep(vr_idx_parc_pep).cdcooper := rw_epr_pep.cdcooper;
      vr_tab_parc_pep(vr_idx_parc_pep).nrdconta := rw_epr_pep.nrdconta;
      vr_tab_parc_pep(vr_idx_parc_pep).nrctremp := rw_epr_pep.nrctremp;
      vr_tab_parc_pep(vr_idx_parc_pep).nrparepr := vr_tab_parcelas(vr_idx_parcelas).nrparepr;
      vr_tab_parc_pep(vr_idx_parc_pep).vlparepr := vr_tab_parcelas(vr_idx_parcelas).vlparepr;
      vr_tab_parc_pep(vr_idx_parc_pep).vltaxatu := vr_tab_parcelas(vr_idx_parcelas).vlrdtaxa;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crappep ' 
                                                || f_busca_valores(rw_epr_pep.cdcooper , rw_epr_pep.nrdconta, rw_epr_pep.nrctremp, vr_tab_parcelas(vr_idx_parcelas).nrparepr)  
                                                ||' where cdcooper = ' || rw_epr_pep.cdcooper 
                                                ||' and   nrdconta = ' || rw_epr_pep.nrdconta 
                                                ||' and   nrctremp = ' || rw_epr_pep.nrctremp 
                                                ||' and   nrparepr = ' || vr_tab_parcelas(vr_idx_parcelas).nrparepr || '; ' ); 
      
      vr_idx_parcelas := vr_tab_parcelas.NEXT(vr_idx_parcelas);
    END LOOP;
  
    vr_tab_parc_epr(vr_idx_parc_epr).cdcooper := rw_epr_pep.cdcooper;
    vr_tab_parc_epr(vr_idx_parc_epr).nrdconta := rw_epr_pep.nrdconta;
    vr_tab_parc_epr(vr_idx_parc_epr).nrctremp := rw_epr_pep.nrctremp;
    vr_tab_parc_epr(vr_idx_parc_epr).vlparepr := vr_tab_parcelas(vr_tab_parcelas.FIRST).vlparepr;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crapepr ' 
                                                || 'set   vlpreemp = ' || replace(rw_epr_pep.vlpreemp , ',','.')
                                                || '     ,vlsprojt = ' || replace(rw_epr_pep.vlsprojt , ',','.')
                                                || ' where cdcooper = ' || rw_epr_pep.cdcooper 
                                                || ' and   nrdconta = ' || rw_epr_pep.nrdconta 
                                                || ' and   nrctremp = ' || rw_epr_pep.nrctremp || ';');
  

    vr_qtdconta := vr_qtdconta + 1;
    IF MOD(vr_qtdconta, 1000) = 0 THEN
      pc_grava_dados(pr_tab_parc_pep => vr_tab_parc_pep,
                     pr_tab_parc_epr => vr_tab_parc_epr);
      vr_tab_parc_epr.DELETE;
      vr_tab_parc_pep.DELETE;
    END IF;
  
  END LOOP;
  pc_grava_dados(pr_tab_parc_pep => vr_tab_parc_pep,
                 pr_tab_parc_epr => vr_tab_parc_epr);
                 
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); 

  COMMIT;

EXCEPTION

  WHEN vr_exc_saida THEN
    vr_cdcritic := NVL(vr_cdcritic, 0);
    IF vr_cdcritic > 0 THEN
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    ROLLBACK;

  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    vr_dscritic := SQLERRM;
    ROLLBACK;
  
END;

