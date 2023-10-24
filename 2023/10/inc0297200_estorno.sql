DECLARE

  rw_crapdat       btch0001.cr_crapdat%ROWTYPE;
  vr_tab_retorno   LANC0001.typ_reg_retorno;
  vr_incrineg      INTEGER;
  vr_nrseqdiglcm   CECRED.craplcm.nrseqdig%TYPE;
  vr_cdcooper      CECRED.crapcop.cdcooper%TYPE;
  vr_cdhistor      CECRED.craphis.cdhistor%TYPE;
  vr_nrdolote      CECRED.craplcm.nrdolote%TYPE;
  vr_qterros       PLS_INTEGER := 0;
  vr_qtprocessados PLS_INTEGER := 0;
  vr_qtfuturos     PLS_INTEGER := 0;
  vr_inlctfut      VARCHAR2(01);
  vr_coopdest      CECRED.crapcop.cdcooper%TYPE := 3;
  vr_nrdconta      NUMBER(25);
  vr_dtprocesso    CECRED.crapdat.dtmvtolt%TYPE;
  vr_exc_saida     EXCEPTION;
  vr_cdcritic      CECRED.crapcri.cdcritic%TYPE;
  vr_dscritic      CECRED.crapcri.dscritic%TYPE;

  CURSOR cr_lancamento IS
    select x.*
    from cecred.CRAPLCM x 
    where x.DTMVTOLT = trunc(sysdate - 1)
    and cdpesqbb in (
       select cdpesqbb from (
         select dtmvtolt, nrdconta, vllanmto, cdpesqbb, x.CDCOOPER, count(*) qtd
         from cecred.CRAPLCM x 
         where x.DTMVTOLT = trunc(sysdate - 1)
         and (cdpesqbb like '20231023%'
         or cdpesqbb like '20231020%')
      group by dtmvtolt, nrdconta, vllanmto, cdpesqbb, CDCOOPER)
      where qtd = 2)
   and x.dttrans > TO_DATE('2023/10/23 21:00:00', 'YYYY/MM/DD HH24:MI:SS');

  CURSOR cr_crapcop IS
    SELECT cdcooper
          ,cdagectl
          ,nmrescop
          ,flgativo
      FROM CECRED.crapcop;

  CURSOR cr_craptco(pr_cdcopant IN CECRED.crapcop.cdcooper%TYPE
                   ,pr_nrctaant IN craptco.nrctaant%TYPE) IS
    SELECT tco.nrdconta
          ,tco.cdcooper
      FROM CECRED.craptco tco
     WHERE tco.cdcopant = pr_cdcopant
       AND tco.nrctaant = pr_nrctaant;
  rw_craptco cr_craptco%ROWTYPE;

BEGIN

  FOR rw_lancamento IN cr_lancamento LOOP
  
    OPEN btch0001.cr_crapdat(vr_coopdest);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
  
    IF trunc(sysdate) IS NULL THEN
      IF rw_crapdat.inproces > 1 THEN
        vr_dtprocesso := rw_crapdat.dtmvtopr;
      ELSE
        vr_dtprocesso := rw_crapdat.dtmvtolt;
      END IF;
    ELSE
      vr_dtprocesso := trunc(sysdate);
    END IF;
  
    vr_nrdconta := rw_lancamento.nrdconta;
    vr_cdcooper := rw_lancamento.cdcooper;
    vr_nrdolote := 9666;
    vr_cdhistor := 2760;
    vr_dscritic := NULL;
  
    cecred.ccrd0006.pc_procura_ultseq_craplcm(pr_cdcooper    => vr_cdcooper,
                                       pr_dtmvtolt    => vr_dtprocesso,
                                       pr_cdagenci    => 1,
                                       pr_cdbccxlt    => 100,
                                       pr_nrdolote    => vr_nrdolote,
                                       pr_nrseqdiglcm => vr_nrseqdiglcm,
                                       pr_cdcritic    => vr_cdcritic,
                                       pr_dscritic    => vr_dscritic);
  
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    BEGIN
      cecred.LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => trunc(vr_dtprocesso),
                                         pr_cdagenci    => 1,
                                         pr_cdbccxlt    => 100,
                                         pr_nrdolote    => vr_nrdolote,
                                         pr_nrdconta    => vr_nrdconta,
                                         pr_nrdocmto    => vr_nrseqdiglcm,
                                         pr_cdhistor    => vr_cdhistor,
                                         pr_nrseqdig    => vr_nrseqdiglcm,
                                         pr_vllanmto    => rw_lancamento.vllanmto,
                                         pr_nrdctabb    => vr_nrdconta,
                                         pr_nrdctitg    => GENE0002.fn_mask(vr_nrdconta, '99999999'),
                                         pr_cdcooper    => vr_cdcooper,
                                         pr_dtrefere    => rw_lancamento.dtmvtolt,
                                         pr_cdoperad    => 1,
                                         pr_cdpesqbb    => rw_lancamento.cdpesqbb,
                                         pr_tab_retorno => vr_tab_retorno,
                                         pr_incrineg    => vr_incrineg,
                                         pr_cdcritic    => vr_cdcritic,
                                         pr_dscritic    => vr_dscritic);
    
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        RAISE vr_exc_saida;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir CRAPLCM: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
  
    vr_qtprocessados := vr_qtprocessados + 1;
  
    vr_dscritic := NULL;
  
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
  
    ROLLBACK;
    raise_application_error(-20001,
                            'Erro: ' || ' ' || vr_cdcritic || ' ' ||
                            SQLERRM);
  
  WHEN OTHERS THEN
    raise_application_error(-20002, 'Erro: ' || SQLERRM);
  
    ROLLBACK;
  
END;