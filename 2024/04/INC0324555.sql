DECLARE 

  PROCEDURE pc_gera_extrato_cnab(pr_cdcooper   IN NUMBER
                                ,pr_nrdconta   IN NUMBER
                                ,pr_dtrefere   IN DATE) IS

    TYPE rec_cnab IS RECORD (vlsldini cecred.crapsld.vlsddisp%TYPE
                            ,vlsldfin cecred.crapsld.vlsddisp%TYPE
                            ,vlmais24 cecred.crapsld.vlsddisp%TYPE
                            ,vlmeno24 cecred.crapsld.vlsddisp%TYPE
                            ,cdbccxlt cecred.crapban.cdbccxlt%TYPE
                            ,nrdolote cecred.craplot.nrdolote%TYPE
                            ,tpregist NUMBER
                            ,inpessoa cecred.crapass.inpessoa%TYPE
                            ,nrcpfcgc cecred.crapass.nrcpfcgc%TYPE
                            ,cdconven VARCHAR2(20)
                            ,cdagenci cecred.crapass.cdagenci%TYPE
                            ,nrdconta cecred.crapass.nrdconta%TYPE
                            ,nrdigcta NUMBER
                            ,nmresemp cecred.crapemp.nmresemp%TYPE
                            ,nmprimtl cecred.crapass.nmprimtl%TYPE
                            ,nmrescop cecred.crapcop.nmrescop%TYPE
                            ,cdremess NUMBER
                            ,dtmvtolt cecred.craplcm.dtmvtolt%TYPE
                            ,hrtransa NUMBER
                            ,nrseqarq NUMBER
                            ,tpservco NUMBER
                            ,cdsegmto VARCHAR2(10)
                            ,tpmovmto NUMBER
                            ,dtsldini cecred.craplcm.dtmvtolt%TYPE
                            ,insldini cecred.craphis.indebcre%TYPE
                            ,iniscpmf VARCHAR2(1)
                            ,dtliblan cecred.crapdpb.dtliblan%TYPE
                            ,dtlanmto cecred.craplcm.dtmvtolt%TYPE
                            ,vllanmto cecred.craplcm.vllanmto%TYPE
                            ,indebcre cecred.craphis.indebcre%TYPE
                            ,cdcatego NUMBER
                            ,cdhistor cecred.craphis.cdhistor%TYPE
                            ,dsextrat cecred.craphis.dsextrat%TYPE
                            ,nrdocmto VARCHAR2(50)
                            ,vllimite cecred.craplim.vllimite%TYPE
                            ,dtsldfin cecred.craplcm.dtmvtolt%TYPE
                            ,insldfin cecred.craphis.indebcre%TYPE
                            ,dtmesref NUMBER
                            ,dtanoref NUMBER
                            ,cdempres NUMBER
                            ,nrcadast cecred.crapass.nrcadast%TYPE
                            ,tpoperac NUMBER
                            ,dtdiavec NUMBER
                            ,dtmesvec NUMBER
                            ,dtanovec NUMBER
                            ,qtprepag cecred.crapepr.qtprepag%TYPE
                            ,qtpreemp cecred.crapepr.qtpreemp%TYPE
                            ,dtdpagto cecred.crawepr.dtdpagto%TYPE
                            ,dtultpag cecred.crapepr.dtultpag%TYPE
                            ,vlemprst cecred.crapepr.vlemprst%TYPE
                            ,vlpreemp cecred.crapepr.vlpreemp%TYPE
                            ,vlsdeved cecred.crapepr.vlsdeved%TYPE
                            ,nrctremp cecred.crapepr.nrctremp%TYPE
                            ,qtdcrato NUMBER);
    TYPE tab_cnab IS TABLE OF rec_cnab INDEX BY BINARY_INTEGER;

    vr_tbcratarq  tab_cnab;

    CURSOR cr_crapcop IS
      SELECT *
        FROM cecred.crapcop t
       WHERE t.cdcooper = pr_cdcooper;
    rg_crapcop   cr_crapcop%ROWTYPE;

    CURSOR cr_crapass(pr_nrdconta NUMBER) IS
      SELECT *
        FROM cecred.crapass t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta;
    rg_crapass    cr_crapass%ROWTYPE;

    CURSOR cr_cheques IS
      SELECT t.dstextab
        FROM cecred.craptab t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nmsistem = 'CRED'
         AND t.tptabela = 'GENERI'
         AND t.cdempres = 0
         AND t.cdacesso = 'HSTCHEQUES'
         AND t.tpregist = 0;

    CURSOR cr_crapcex IS
      SELECT *
        FROM cecred.crapcex t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.tpextrat = 3
         AND t.cdperiod = 1;

    CURSOR cr_crapsda(pr_nrdconta  NUMBER) IS
      SELECT t.vlsddisp
        FROM cecred.crapsda t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.dtmvtolt = gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                     ,pr_dtmvtolt => pr_dtrefere - 1
                                                     ,pr_tipo     => 'A');

    CURSOR cr_craplcm(pr_nrdconta  NUMBER) IS
      SELECT lcm.cdhistor
           , his.dsextrat
           , lcm.cdpesqbb
           , lcm.nrparepr
           , his.inhistor
           , lcm.vllanmto
           , lcm.nrdocmto
           , lcm.cdagenci
           , lcm.cdbccxlt
           , lcm.nrdolote
           , lcm.nrdconta
           , lcm.progress_recid
           , lcm.dtmvtolt
           , his.cdcatego
        FROM cecred.craplcm lcm
       INNER JOIN cecred.craphis his
          ON his.cdcooper = lcm.cdcooper
         AND his.cdhistor = lcm.cdhistor
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.dtmvtolt = pr_dtrefere
         AND lcm.cdhistor <> 289
       ORDER BY lcm.nrdconta
              , lcm.dtmvtolt
              , lcm.cdhistor
              , lcm.nrdocmto;

    CURSOR cr_crapepr(pr_nrdconta  NUMBER
                     ,pr_cdpesqbb  NUMBER) IS
      SELECT t.qtpreemp
        FROM cecred.crapepr t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.nrctremp = to_number(pr_cdpesqbb);
    rg_crapepr   cr_crapepr%ROWTYPE;

    CURSOR cr_crapdpb(pr_cdagenci   cecred.crapdpb.cdagenci%TYPE
                     ,pr_cdbccxlt   cecred.crapdpb.cdbccxlt%TYPE
                     ,pr_nrdolote   cecred.crapdpb.nrdolote%TYPE
                     ,pr_nrdconta   cecred.crapdpb.nrdconta%TYPE
                     ,pr_nrdocmto   cecred.crapdpb.nrdocmto%TYPE) IS
      SELECT *
        FROM cecred.crapdpb t
       WHERE t.cdcooper = pr_cdcooper
         AND t.dtmvtolt = pr_dtrefere
         AND t.cdagenci = pr_cdagenci
         AND t.cdbccxlt = pr_cdbccxlt
         AND t.nrdolote = pr_nrdolote
         AND t.nrdconta = pr_nrdconta
         AND t.nrdocmto = pr_nrdocmto;
    rg_crapdpb   cr_crapdpb%ROWTYPE;
    
    CURSOR cr_crapdcb(pr_nrdconta  cecred.crapdcb.nrdconta%TYPE
                     ,pr_cdpesqbb  cecred.crapdcb.nrcrcard%TYPE
                     ,pr_vllanmto  cecred.crapdcb.vldtrans%TYPE
                     ,pr_cdhistor  cecred.crapdcb.cdhistor%TYPE
                     ,pr_nrdocmto  VARCHAR2) IS
      SELECT *
        FROM crapdcb t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.nrcrcard = pr_cdpesqbb
         AND t.dtdtrans = pr_dtrefere
         AND t.vldtrans = pr_vllanmto
         AND t.cdhistor = pr_cdhistor
         AND t.tpmensag = SUBSTR(gene0002.fn_mask(pr_nrdocmto, '99999999999999999999'), 1, 4)
         AND t.nrnsucap = to_number(SUBSTR(gene0002.fn_mask(pr_nrdocmto, '99999999999999999999'), 5, 6));
    rg_crapdcb    cr_crapdcb%ROWTYPE;

    CURSOR cr_crapdcb_2(pr_nrdconta  cecred.crapdcb.nrdconta%TYPE
                       ,pr_cdpesqbb  cecred.crapdcb.nrcrcard%TYPE
                       ,pr_vllanmto  cecred.crapdcb.vldtrans%TYPE
                       ,pr_cdhistor  cecred.crapdcb.cdhistor%TYPE
                       ,pr_nrdocmto  NUMBER
                       ,pr_nrnsuori  cecred.crapdcb.nrnsuori%TYPE) IS
      SELECT *
        FROM crapdcb  t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.nrcrcard = pr_cdpesqbb
         AND t.dtdtrans = pr_dtrefere
         AND t.vldtrans = pr_vllanmto
         AND t.cdhistor <> pr_cdhistor
         AND t.tpmensag <> SUBSTR(gene0002.fn_mask(pr_nrdocmto, '99999999999999999999'), 1, 4)
         AND t.nrnsuori = pr_nrnsuori;
    rg_crapdcb_2   cr_crapdcb_2%ROWTYPE;
    
    vr_lshistor   cecred.craptab.dstextab%TYPE;
    vr_vlmais24   NUMBER := 0;
    vr_vlmeno24   NUMBER := 0;
    vr_nrseqarq   NUMBER := 0;
    vr_qtreglot   NUMBER := 0;
    vr_tbindice   NUMBER;
    vr_vlstotal   NUMBER;
    vr_dshisdeb   cecred.crapprm.dsvlrprm%TYPE;
    vr_dshisest   cecred.crapprm.dsvlrprm%TYPE;
    vr_nrdocmto   VARCHAR2(50);
    vr_dsextrat   cecred.craphis.dsextrat%TYPE;
    vr_dtmvtopr   DATE := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                     ,pr_dtmvtolt => pr_dtrefere+1);
    vr_nrnsucap   cecred.crapdcb.nrnsucap%TYPE;
    vr_nrnsuori   cecred.crapdcb.nrnsuori%TYPE;
    vr_dtliblan   cecred.crapdpb.dtliblan%TYPE;
    vr_nmarqimp   VARCHAR2(50);
    vr_dsarquiv   CLOB;
    vr_txarquiv   VARCHAR2(32600);
    vr_nrcalcul   NUMBER;
    vr_flcalcul   BOOLEAN;
    vr_dscomple   VARCHAR2(100);
    vr_des_erro   VARCHAR2(2000);
    vr_dsdlinha   VARCHAR2(500);
    vr_qtregtot   NUMBER;
    vr_nrseqlan   NUMBER;
    vr_vltotcre   NUMBER;
    vr_vltotdeb   NUMBER;

  BEGIN

    OPEN  cr_crapcop;
    FETCH cr_crapcop INTO rg_crapcop;

    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      raise_application_error(-20001,'Cooperativa nao encontrada.');
    END IF;

    CLOSE cr_crapcop;

    OPEN  cr_cheques;
    FETCH cr_cheques INTO vr_lshistor;

    IF cr_cheques%NOTFOUND THEN
      vr_lshistor := '999';
    END IF;

    CLOSE cr_cheques;

    FOR cex IN cr_crapcex LOOP

      vr_vlmais24 := 0;
      vr_vlmeno24 := 0;
      vr_nrseqarq := 0;
      vr_vlstotal := 0;

      vr_tbcratarq.DELETE;

      OPEN  cr_crapass(cex.nrdconta);
      FETCH cr_crapass INTO rg_crapass;

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapcop;
        raise_application_error(-20002,'Conta nao encontrada.');
      END IF;

      CLOSE cr_crapass;

      vr_tbindice := NVL(vr_tbcratarq.COUNT(),0) + 1;
      vr_tbcratarq(vr_tbindice).nrseqarq := vr_nrseqarq;
      vr_tbcratarq(vr_tbindice).cdbccxlt := 085;
      vr_tbcratarq(vr_tbindice).nrdolote := 0;
      vr_tbcratarq(vr_tbindice).tpregist := 0;
      vr_tbcratarq(vr_tbindice).inpessoa := CASE rg_crapass.inpessoa WHEN 1 THEN 1 ELSE 2 END;
      vr_tbcratarq(vr_tbindice).nrcpfcgc := rg_crapass.nrcpfcgc;
      vr_tbcratarq(vr_tbindice).cdagenci := rg_crapcop.cdagectl;
      vr_tbcratarq(vr_tbindice).nrdconta := TO_NUMBER(SUBSTR(LPAD(rg_crapass.nrdconta,8,'0'),1,7));
      vr_tbcratarq(vr_tbindice).nrdigcta := TO_NUMBER(SUBSTR(LPAD(rg_crapass.nrdconta,8,'0'),8,1));
      vr_tbcratarq(vr_tbindice).nmprimtl := rg_crapass.nmprimtl;
      vr_tbcratarq(vr_tbindice).nmrescop := rg_crapcop.nmrescop;
      vr_tbcratarq(vr_tbindice).cdremess := 2;
      vr_tbcratarq(vr_tbindice).dtmvtolt := pr_dtrefere;
      vr_tbcratarq(vr_tbindice).hrtransa := to_char(SYSDATE,'hh24miss');

      OPEN  cr_crapsda(rg_crapass.nrdconta);
      FETCH cr_crapsda INTO vr_vlstotal;

      IF cr_crapsda%NOTFOUND THEN
        CLOSE cr_crapsda;
        raise_application_error(-20003,'Saldo nao encontrado.');
      END IF;

      CLOSE cr_crapsda;

      vr_tbindice := NVL(vr_tbcratarq.COUNT(),0) + 1;
      vr_tbcratarq(vr_tbindice).cdbccxlt := 085;
      vr_tbcratarq(vr_tbindice).nrdolote := 1;
      vr_tbcratarq(vr_tbindice).tpregist := 1;
      vr_tbcratarq(vr_tbindice).inpessoa := CASE rg_crapass.inpessoa WHEN 1 THEN 1 ELSE 2 END;
      vr_tbcratarq(vr_tbindice).nrcpfcgc := rg_crapass.nrcpfcgc;
      vr_tbcratarq(vr_tbindice).cdagenci := rg_crapcop.cdagectl;
      vr_tbcratarq(vr_tbindice).nrdconta := TO_NUMBER(SUBSTR(LPAD(rg_crapass.nrdconta,8,'0'),1,7));
      vr_tbcratarq(vr_tbindice).nrdigcta := TO_NUMBER(SUBSTR(LPAD(rg_crapass.nrdconta,8,'0'),8,1));
      vr_tbcratarq(vr_tbindice).nmprimtl := rg_crapass.nmprimtl;
      vr_tbcratarq(vr_tbindice).dtsldini := pr_dtrefere;

      IF vr_vlstotal < 0 THEN
        vr_tbcratarq(vr_tbindice).vlsldini := vr_vlstotal * -1;
        vr_tbcratarq(vr_tbindice).insldini := 'D';
      ELSE
        vr_tbcratarq(vr_tbindice).vlsldini := vr_vlstotal;
        vr_tbcratarq(vr_tbindice).insldini := 'C';
      END IF;

      vr_dshisdeb := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'HIST_CARTAO_DEBITO');

      vr_dshisest := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'HIST_EST_CARTAO_DEBITO');

      FOR lcm IN cr_craplcm(rg_crapass.nrdconta) LOOP

        vr_dtliblan := NULL;

        IF lcm.cdhistor IN (375,376,377,537,538,539,771,772) THEN
          vr_nrdocmto := gene0002.fn_mask(SUBSTR(lcm.cdpesqbb,45,8),'zzzzz.zzz.9');
        ELSIF lcm.cdhistor IN (104,302,303) THEN
          BEGIN
            IF to_number(lcm.cdpesqbb) > 0   THEN
              vr_nrdocmto := gene0002.fn_mask(lcm.cdpesqbb,'zzzzz.zzz.9');
            ELSE
              vr_nrdocmto := gene0002.fn_mask(lcm.nrdocmto,'zzz.zzz.zz9');
            END IF;
          EXCEPTION
            WHEN INVALID_NUMBER THEN
              vr_nrdocmto := gene0002.fn_mask(lcm.nrdocmto,'zzz.zzz.zz9');
          END;
        ELSIF lcm.cdhistor = 418 THEN
          vr_nrdocmto := '    ' || SUBSTR(lcm.cdpesqbb,60,7);
        ELSIF lcm.cdhistor = 100 THEN
          IF TRIM(lcm.cdpesqbb) IS NOT NULL THEN
            vr_nrdocmto := lcm.cdpesqbb;
          ELSE
            vr_nrdocmto := gene0002.fn_mask(lcm.nrdocmto,'zzz.zzz.zz9');
          END IF;
        ELSE
          IF ','||vr_lshistor||',' LIKE '%,'||lcm.cdhistor||',%' THEN
            vr_nrdocmto := gene0002.fn_mask(lcm.nrdocmto,'z.zzz.zz9.9');
          ELSIF LENGTH(lcm.nrdocmto) < 10 THEN
            vr_nrdocmto := gene0002.fn_mask(lcm.nrdocmto,'zzzzzzz.zz9');
          ELSE
            vr_nrdocmto := SUBSTR(gene0002.fn_mask(lcm.nrdocmto,'9999999999999999999999999'),4,11);
          END IF;
        END IF;

        IF lcm.cdhistor IN (24,27,47,78,156,191,338,351,399,573,3221) THEN
          vr_dsextrat := lcm.dsextrat||lcm.cdpesqbb;
        ELSE
          vr_dsextrat := lcm.dsextrat;
        END IF;

        IF lcm.nrparepr > 0 THEN

          OPEN  cr_crapepr(pr_nrdconta, TRIM(lcm.cdpesqbb));
          FETCH cr_crapepr INTO rg_crapepr;

          IF cr_crapepr%FOUND THEN
            vr_dsextrat := SUBSTR(vr_dsextrat,1,13) || ' '
                         ||gene0002.fn_mask(lcm.nrparepr,'999') ||'/'
                         ||gene0002.fn_mask(rg_crapepr.qtpreemp,'999');
          END IF;

          CLOSE cr_crapepr;
        END IF;

        IF lcm.inhistor BETWEEN 1 AND 5 THEN
          vr_vlstotal := vr_vlstotal + lcm.vllanmto;

          IF lcm.inhistor NOT IN (1,2) THEN
            OPEN  cr_crapdpb(lcm.cdagenci
                            ,lcm.cdbccxlt
                            ,lcm.nrdolote
                            ,lcm.nrdconta
                            ,lcm.nrdocmto);
            FETCH cr_crapdpb INTO rg_crapdpb;

            IF cr_crapdpb%NOTFOUND THEN
              CLOSE cr_crapdpb;
              raise_application_error(-20004,'Registro CRAPDPB nao encontrado.');
            END IF;

            CLOSE cr_crapdpb;

            IF rg_crapdpb.dtliblan = vr_dtmvtopr THEN
              vr_vlmeno24 := vr_vlmeno24 + lcm.vllanmto;
            ELSE
              vr_vlmais24 := vr_vlmais24 + lcm.vllanmto;
            END IF;

            vr_dtliblan := rg_crapdpb.dtliblan;
          END IF;

        ELSIF lcm.inhistor BETWEEN 11 AND 15 THEN
          vr_vlstotal := vr_vlstotal - lcm.vllanmto;
        ELSE
          raise_application_error(-20005,'Erro na definição de saldo. LCM: '||lcm.progress_recid);
        END IF;

        IF vr_dshisdeb LIKE '%;'||lcm.cdhistor||';%' OR
           vr_dshisest LIKE '%;'||lcm.cdhistor||';%' THEN

          OPEN  cr_crapdcb(lcm.nrdconta
                          ,lcm.cdpesqbb
                          ,lcm.vllanmto
                          ,lcm.cdhistor
                          ,lcm.nrdocmto);
          FETCH cr_crapdcb INTO rg_crapdcb;

          IF cr_crapdcb%FOUND THEN
            vr_nrnsucap := rg_crapdcb.nrnsucap;
            vr_nrnsuori := rg_crapdcb.nrnsuori;

            IF TRIM(rg_crapdcb.dsdtrans) IS NULL THEN
              OPEN  cr_crapdcb_2(lcm.nrdconta
                                ,lcm.cdpesqbb
                                ,lcm.vllanmto
                                ,lcm.cdhistor
                                ,lcm.nrdocmto
                                ,vr_nrnsuori);
              FETCH  cr_crapdcb_2 INTO rg_crapdcb_2;

              IF cr_crapdcb_2%FOUND THEN
                vr_dscomple := rg_crapdcb_2.dsdtrans;
              ELSE
                vr_dscomple := '';
              END IF;
            ELSE
              vr_dscomple := rg_crapdcb.dsdtrans;
            END IF;
          ELSE
            vr_dscomple := '';
          END IF;

          IF TRIM(vr_dscomple) IS NOT NULL THEN
            vr_dsextrat := vr_dsextrat||' - '||vr_dscomple;
          END IF;

        END IF;

        vr_tbindice := NVL(vr_tbcratarq.COUNT(),0) + 1;
        vr_tbcratarq(vr_tbindice).cdbccxlt := 085;
        vr_tbcratarq(vr_tbindice).nrdolote := 1;
        vr_tbcratarq(vr_tbindice).tpregist := 3;
        vr_tbcratarq(vr_tbindice).inpessoa := CASE rg_crapass.inpessoa WHEN 1 THEN 1 ELSE 2 END;
        vr_tbcratarq(vr_tbindice).nrcpfcgc := rg_crapass.nrcpfcgc;
        vr_tbcratarq(vr_tbindice).cdagenci := rg_crapcop.cdagectl;
        vr_tbcratarq(vr_tbindice).nrdconta := TO_NUMBER(SUBSTR(LPAD(rg_crapass.nrdconta,8,'0'),1,7));
        vr_tbcratarq(vr_tbindice).nrdigcta := TO_NUMBER(SUBSTR(LPAD(rg_crapass.nrdconta,8,'0'),8,1));
        vr_tbcratarq(vr_tbindice).nmprimtl := rg_crapass.nmprimtl;
        vr_tbcratarq(vr_tbindice).iniscpmf := CASE rg_crapass.iniscpmf WHEN 0 THEN 'N' ELSE 'S' END;
        vr_tbcratarq(vr_tbindice).dtlanmto := lcm.dtmvtolt;
        vr_tbcratarq(vr_tbindice).dtliblan := NVL(vr_dtliblan,lcm.dtmvtolt);
        vr_tbcratarq(vr_tbindice).vllanmto := ABS(lcm.vllanmto);
        vr_tbcratarq(vr_tbindice).cdhistor := lcm.cdhistor;
        vr_tbcratarq(vr_tbindice).dsextrat := vr_dsextrat;
        vr_tbcratarq(vr_tbindice).nrdocmto := vr_nrdocmto;
        vr_tbcratarq(vr_tbindice).cdcatego := lcm.cdcatego;

        IF lcm.inhistor BETWEEN 1 AND 5 THEN
          vr_tbcratarq(vr_tbindice).indebcre := 'C';
        ELSE
          IF lcm.inhistor BETWEEN 11 AND 15 THEN
            vr_tbcratarq(vr_tbindice).indebcre := 'D';
          END IF;
        END IF;

      END LOOP;

      vr_tbindice := NVL(vr_tbcratarq.COUNT(),0) + 1;
      vr_tbcratarq(vr_tbindice).cdbccxlt := 085;
      vr_tbcratarq(vr_tbindice).nrdolote := 1;
      vr_tbcratarq(vr_tbindice).tpregist := 5;
      vr_tbcratarq(vr_tbindice).inpessoa := CASE rg_crapass.inpessoa WHEN 1 THEN 1 ELSE 2 END;
      vr_tbcratarq(vr_tbindice).nrcpfcgc := rg_crapass.nrcpfcgc;
      vr_tbcratarq(vr_tbindice).cdagenci := rg_crapcop.cdagectl;
      vr_tbcratarq(vr_tbindice).nrdconta := TO_NUMBER(SUBSTR(LPAD(rg_crapass.nrdconta,8,'0'),1,7));
      vr_tbcratarq(vr_tbindice).nrdigcta := TO_NUMBER(SUBSTR(LPAD(rg_crapass.nrdconta,8,'0'),8,1));
      vr_tbcratarq(vr_tbindice).nmprimtl := rg_crapass.nmprimtl;
      vr_tbcratarq(vr_tbindice).vlmais24 := vr_vlmais24;
      vr_tbcratarq(vr_tbindice).vlmeno24 := vr_vlmeno24;
      vr_tbcratarq(vr_tbindice).vllimite := rg_crapass.vllimcre;
      vr_tbcratarq(vr_tbindice).dtsldfin := pr_dtrefere;
      vr_tbcratarq(vr_tbindice).vlsldfin := ABS(vr_vlstotal);

      IF vr_vlstotal < 0 THEN
        vr_tbcratarq(vr_tbindice).insldfin := 'D';
      ELSE
        vr_tbcratarq(vr_tbindice).insldfin := 'C';
      END IF;

      vr_tbindice := NVL(vr_tbcratarq.COUNT(),0) + 1;
      vr_tbcratarq(vr_tbindice).cdbccxlt := 085;
      vr_tbcratarq(vr_tbindice).nrdolote := 9999;
      vr_tbcratarq(vr_tbindice).tpregist := 9;

      vr_nmarqimp := 'extcc_'||rg_crapass.nrdconta||'_'||to_char(pr_dtrefere, 'ddmm')||'_240.txt';

      dbms_lob.createtemporary(vr_dsarquiv, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_dsarquiv, dbms_lob.lob_readwrite);

      vr_nrcalcul := to_number(vr_tbcratarq(1).cdagenci||'0');

      vr_flcalcul := gene0005.fn_calc_digito(pr_nrcalcul => vr_nrcalcul);

      vr_nrcalcul := to_number(SUBSTR(to_char(vr_nrcalcul), LENGTH(to_char(vr_nrcalcul)), 1));

      FOR ind IN vr_tbcratarq.FIRST..vr_tbcratarq.LAST LOOP
        vr_dsdlinha := NULL;
        vr_qtregtot := NVL(vr_qtregtot,0) + 1;

        IF vr_tbcratarq(ind).tpregist = 0 THEN

          vr_dsdlinha := gene0002.fn_mask(vr_tbcratarq(ind).cdbccxlt,'999')  ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdolote,'9999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).tpregist,'9') || '         ' ||
                         gene0002.fn_mask(vr_tbcratarq(ind).inpessoa,'9') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrcpfcgc,'99999999999999') ||
                         '                    ' ||
                         gene0002.fn_mask(vr_tbcratarq(ind).cdagenci,'99999') ||
                         gene0002.fn_mask(vr_nrcalcul,'9') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdconta,'999999999999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdigcta,'9') ||
                         gene0002.fn_mask(vr_nrcalcul,'9') ||
                         RPAD(vr_tbcratarq(ind).nmprimtl,30,' ') ||
                         RPAD(vr_tbcratarq(ind).nmrescop,30,' ') || '          ' ||
                         gene0002.fn_mask(vr_tbcratarq(ind).cdremess,'9') ||
                         to_char(vr_tbcratarq(ind).dtmvtolt,'ddmmyyyy') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).hrtransa,'999999');

          IF vr_tbcratarq(ind).nrseqarq > 0 THEN
            vr_dsdlinha := vr_dsdlinha || gene0002.fn_mask(vr_tbcratarq(ind).nrseqarq, '999999');
          ELSE
            vr_dsdlinha := vr_dsdlinha || '000001';
          END IF;

          vr_dsdlinha := vr_dsdlinha || '06000000                                        ';

        ELSIF vr_tbcratarq(ind).tpregist = 1 THEN
          vr_qtreglot := NVL(vr_qtreglot,0) + 1;

          vr_dsdlinha := gene0002.fn_mask(vr_tbcratarq(ind).cdbccxlt,'999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdolote,'9999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).tpregist,'9') || 'E0440032 '||
                         gene0002.fn_mask(vr_tbcratarq(ind).inpessoa,'9') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrcpfcgc,'99999999999999') || '                    ' ||
                         gene0002.fn_mask(vr_tbcratarq(ind).cdagenci,'99999') ||
                         gene0002.fn_mask(vr_nrcalcul,'9') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdconta,'999999999999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdigcta,'9') ||
                         gene0002.fn_mask(vr_nrcalcul,'9') ||
                         RPAD(vr_tbcratarq(ind).nmprimtl,30,' ') || '                                        ' ||
                         to_char(vr_tbcratarq(ind).dtsldini,'ddmmyyyy') ||
                         REPLACE(to_char(vr_tbcratarq(ind).vlsldini,'FM0000000000000000d00'),',','') ||
                         RPAD(vr_tbcratarq(ind).insldini,1,' ') || 'FBRL00001';

        ELSIF vr_tbcratarq(ind).tpregist = 3 THEN
          vr_nrseqlan := NVL(vr_nrseqlan,0) + 1;

          IF vr_tbcratarq(ind).indebcre = 'C' THEN
            vr_vltotcre := NVL(vr_vltotcre,0) + vr_tbcratarq(ind).vllanmto;
          ELSE
            vr_vltotdeb := NVL(vr_vltotdeb,0) + vr_tbcratarq(ind).vllanmto;
          END IF;

          vr_dsdlinha := gene0002.fn_mask(vr_tbcratarq(ind).cdbccxlt,'999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdolote,'9999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).tpregist,'9') ||
                         gene0002.fn_mask(vr_nrseqlan,'99999') || 'E   ' ||
                         gene0002.fn_mask(vr_tbcratarq(ind).inpessoa,'9') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrcpfcgc,'99999999999999') || '                    ' ||
                         gene0002.fn_mask(vr_tbcratarq(ind).cdagenci,'99999') ||
                         gene0002.fn_mask(vr_nrcalcul,'9') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdconta,'999999999999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdigcta,'9') ||
                         gene0002.fn_mask(vr_nrcalcul,'9') ||
                         RPAD(vr_tbcratarq(ind).nmprimtl,30,' ') || '         00                    ' ||
                         RPAD(vr_tbcratarq(ind).iniscpmf,1, ' ') ||
                         to_char(vr_tbcratarq(ind).dtliblan,'ddmmyyyy') ||
                         to_char(vr_tbcratarq(ind).dtlanmto,'ddmmyyyy') ||
                         REPLACE(to_char(vr_tbcratarq(ind).vllanmto,'FM0000000000000000d00'),',','') ||
                         RPAD(vr_tbcratarq(ind).indebcre,1,' ') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).cdcatego,'999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).cdhistor,'9999') ||
                         RPAD(vr_tbcratarq(ind).dsextrat,25,' ') ||
                         vr_tbcratarq(ind).nrdocmto;

        ELSIF vr_tbcratarq(ind).tpregist = 5 THEN
          vr_qtreglot := NVL(vr_qtreglot,0) + 1;
          vr_qtreglot := vr_qtreglot + vr_nrseqlan;

          vr_dsdlinha := gene0002.fn_mask(vr_tbcratarq(ind).cdbccxlt,'999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdolote,'9999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).tpregist,'9') || '         ' ||
                         gene0002.fn_mask(vr_tbcratarq(ind).inpessoa,'9') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrcpfcgc,'99999999999999') || '                    ' ||
                         gene0002.fn_mask(vr_tbcratarq(ind).cdagenci,'99999') ||
                         gene0002.fn_mask(vr_nrcalcul,'9') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdconta,'999999999999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdigcta,'9') ||
                         gene0002.fn_mask(vr_nrcalcul,'9') || '                ' ||
                         REPLACE(to_char(vr_tbcratarq(ind).vlmais24,'FM0000000000000000d00'),',','') ||
                         REPLACE(to_char(vr_tbcratarq(ind).vllimite,'FM0000000000000000d00'),',','') ||
                         REPLACE(to_char(vr_tbcratarq(ind).vlmeno24,'FM0000000000000000d00'),',','') ||
                         to_char(vr_tbcratarq(ind).dtsldfin,'ddmmyyyy') ||
                         REPLACE(to_char(vr_tbcratarq(ind).vlsldfin,'FM0000000000000000d00'),',','') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).insldfin,'9') || 'F' ||
                         gene0002.fn_mask(vr_qtreglot,'999999') ||
                         REPLACE(to_char(vr_vltotdeb,'FM0000000000000000d00'),',','') ||
                         REPLACE(to_char(vr_vltotcre,'FM0000000000000000d00'),',','') ||
                         '                            ';

        ELSIF vr_tbcratarq(ind).tpregist = 9 THEN
          vr_dsdlinha := gene0002.fn_mask(vr_tbcratarq(ind).cdbccxlt,'999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).nrdolote,'9999') ||
                         gene0002.fn_mask(vr_tbcratarq(ind).tpregist,'9') || '         ' ||
                         '000001' || gene0002.fn_mask(vr_qtregtot,'999999') ||
                         '000001';
        END IF;

        IF vr_tbcratarq(ind).tpregist <> 9  THEN
          gene0002.pc_escreve_xml(vr_dsarquiv, vr_txarquiv,RPAD(vr_dsdlinha,240,' ')||CHR(10));
        ELSE
          gene0002.pc_escreve_xml(vr_dsarquiv, vr_txarquiv,RPAD(vr_dsdlinha,240,' '),TRUE);
        END IF;

      END LOOP;

      gene0002.pc_clob_para_arquivo(pr_clob     => vr_dsarquiv
                                   ,pr_caminho  => gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                                        ,pr_cdcooper => pr_cdcooper
                                                                        ,pr_nmsubdir => 'salvar')
                                   ,pr_arquivo  => vr_nmarqimp
                                   ,pr_des_erro => vr_des_erro);

      IF vr_des_erro IS NOT NULL THEN
        raise_application_error(-20006,'Erro ao gravar arquivo no diretorio salvar: '||vr_des_erro);
      END IF;

    END LOOP;

  END;
  
BEGIN


  
  pc_gera_extrato_cnab(pr_cdcooper => 2
                      ,pr_nrdconta => 61689,   
                      ,pr_dtrefere => to_date('22/01/2024','dd/mm/yyyy'));
					  
 pc_gera_extrato_cnab(pr_cdcooper => 2
                     ,pr_nrdconta => 61689,   
                     ,pr_dtrefere => to_date('24/01/2024','dd/mm/yyyy'));
					  
 pc_gera_extrato_cnab(pr_cdcooper => 2
                     ,pr_nrdconta => 61689,   
                     ,pr_dtrefere => to_date('01/02/2024','dd/mm/yyyy'));
					 
  pc_gera_extrato_cnab(pr_cdcooper => 2
                      ,pr_nrdconta => 238449
                      ,pr_dtrefere => to_date('22/01/2024','dd/mm/yyyy'));
					  
  pc_gera_extrato_cnab(pr_cdcooper => 2
                      ,pr_nrdconta => 238449
                      ,pr_dtrefere => to_date('25/01/2024','dd/mm/yyyy'));
  
  pc_gera_extrato_cnab(pr_cdcooper => 2
                      ,pr_nrdconta => 238449
                      ,pr_dtrefere => to_date('16/02/2024','dd/mm/yyyy'));
  
                      
  pc_gera_extrato_cnab(pr_cdcooper => 2
                      ,pr_nrdconta => 238457
                      ,pr_dtrefere => to_date('26/01/2024','dd/mm/yyyy'));
	
 pc_gera_extrato_cnab(pr_cdcooper => 2
                      ,pr_nrdconta => 238457
                      ,pr_dtrefere => to_date('29/01/2024','dd/mm/yyyy'));
                      
  
  COMMIT;
END;

