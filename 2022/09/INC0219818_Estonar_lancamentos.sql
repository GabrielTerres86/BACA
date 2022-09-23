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
    SELECT *
      FROM craplcm
     WHERE PROGRESS_RECID IN (1607180593
							,1607180594
							,1607180595
							,1607180596
							,1607180597
							,1607180598
							,1607180599
							,1607180600
							,1607180601
							,1607180602
							,1607180603
							,1607180604
							,1607180605
							,1607180606
							,1607180607
							,1607180608
							,1607180609
							,1607180610
							,1607180611
							,1607180612
							,1607180613
							,1607180614
							,1607180615
							,1607180616
							,1607180617
							,1607180618
							,1607180619
							,1607180620
							,1607180621
							,1607180622
							,1607180623
							,1607180624
							,1607180625
							,1607180626
							,1607180627
							,1607180628
							,1607180629
							,1607182694
							,1607180630
							,1607180631
							,1607180632
							,1607180633
							,1607180634
							,1607180635
							,1607180644
							,1607180645
							,1607180646
							,1607180647
							,1607180648
							,1607180649
							,1607180650
							,1607180651
							,1607180652
							,1607180653
							,1607180654
							,1607180655
							,1607180656
							,1607180657
							,1607180658
							,1607180659
							,1607180660
							,1607180661
							,1607182662
							,1607182663
							,1607182664
							,1607182665
							,1607182666
							,1607182667
							,1607182668
							,1607182669
							,1607182670
							,1607182671
							,1607182672
							,1607182673
							,1607182674
							,1607182675
							,1607182676
							,1607182677
							,1607182678
							,1607182679
							,1607182680
							,1607182681
							,1607182682
							,1607182683
							,1607182684
							,1607182685
							,1607182686
							,1607180636
							,1607182687
							,1607180637
							,1607180638
							,1607182688
							,1607182689
							,1607180639
							,1607180640
							,1607180641
							,1607180642
							,1607180643
							,1607182690
							,1607182691
							,1607182692
							,1607182693);

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
    vr_cdhistor := 360;
    vr_dscritic := NULL;
  
    ccrd0006.pc_procura_ultseq_craplcm(pr_cdcooper    => vr_cdcooper,
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
      LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => trunc(vr_dtprocesso),
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
