DECLARE

  vr_sequence NUMBER;

  CURSOR cr_reneg IS
    SELECT w.cdcooper
          ,w.nrdconta
          ,w.nrctremp
          ,e.dtmvtolt
          ,CASE
             WHEN nvl(w.nrliquid, 0) = 0 THEN
              0
             ELSE
              2
           END TPCONTRATO_LIQUIDADO
          ,CASE
             WHEN nvl(w.nrliquid, 0) = 0 THEN
              0
             ELSE
              w.nrctremp
           END NRCTREMP_NOVO
      FROM cecred.crawepr w
      JOIN cecred.crapepr e
        ON e.cdcooper = w.cdcooper
       AND e.nrdconta = w.nrdconta
       AND e.nrctremp = w.nrctremp
     WHERE w.flgreneg = 1
       AND e.inliquid = 0
       AND NOT EXISTS (SELECT 1
              FROM cecred.tbepr_renegociacao_contrato trc
             WHERE trc.cdcooper = w.cdcooper
               AND trc.nrdconta = w.nrdconta
               AND ((trc.nrctrepr = w.nrctremp) OR
                   (trc.nrctremp_novo = w.nrctremp)))
       AND EXISTS (SELECT 1
              FROM cecred.tbepr_renegociacao_crapepr epr
             WHERE epr.cdcooper = w.cdcooper
               AND epr.nrdconta = w.nrdconta
               AND epr.nrctremp = w.nrctremp);


  CURSOR cr_versao_reneg(pr_cdcooper crapepr.cdcooper%TYPE
                        ,pr_nrdconta crapepr.nrdconta%TYPE
                        ,pr_nrctremp crapepr.nrctremp%TYPE) IS
    SELECT MAX(nrversao) nrversao
      FROM cecred.tbepr_renegociacao_crapepr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp;
  rw_versao_reneg cr_versao_reneg%ROWTYPE;

  CURSOR cr_crawepr_atual(pr_cdcooper crapepr.cdcooper%TYPE
                         ,pr_nrdconta crapepr.nrdconta%TYPE
                         ,pr_nrctremp crapepr.nrctremp%TYPE) IS
    SELECT *
      FROM cecred.crawepr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp;
  crawepr_atual cr_crawepr_atual%ROWTYPE;

  CURSOR cr_crapepr_atual(pr_cdcooper crapepr.cdcooper%TYPE
                         ,pr_nrdconta crapepr.nrdconta%TYPE
                         ,pr_nrctremp crapepr.nrctremp%TYPE) IS
    SELECT *
      FROM cecred.crapepr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp;
  crapepr_atual cr_crapepr_atual%ROWTYPE;

  CURSOR cr_crapepr_antes(pr_cdcooper crapepr.cdcooper%TYPE
                         ,pr_nrdconta crapepr.nrdconta%TYPE
                         ,pr_nrctremp crapepr.nrctremp%TYPE) IS
    SELECT *
      FROM cecred.tbepr_renegociacao_crapepr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp;
  crapepr_antes cr_crapepr_antes%ROWTYPE;


BEGIN

  FOR rw_reneg IN cr_reneg LOOP
  
  
    vr_sequence := 0;
  
    OPEN cr_versao_reneg(pr_cdcooper => rw_reneg.cdcooper
                        ,pr_nrdconta => rw_reneg.nrdconta
                        ,pr_nrctremp => rw_reneg.nrctremp);
    FETCH cr_versao_reneg
      INTO rw_versao_reneg;
    CLOSE cr_versao_reneg;
  
    OPEN cr_crawepr_atual(rw_reneg.cdcooper
                         ,rw_reneg.nrdconta
                         ,rw_reneg.nrctremp);
    FETCH cr_crawepr_atual
      INTO crawepr_atual;
    CLOSE cr_crawepr_atual;
  
    OPEN cr_crapepr_atual(rw_reneg.cdcooper
                         ,rw_reneg.nrdconta
                         ,rw_reneg.nrctremp);
    FETCH cr_crapepr_atual
      INTO crapepr_atual;
    CLOSE cr_crapepr_atual;
  
    OPEN cr_crapepr_antes(rw_reneg.cdcooper
                         ,rw_reneg.nrdconta
                         ,rw_reneg.nrctremp);
    FETCH cr_crapepr_antes
      INTO crapepr_antes;
    CLOSE cr_crapepr_antes;
  
    vr_sequence := fn_sequence(pr_nmtabela => 'CRAPMAT'
                              ,pr_nmdcampo => 'NRCTREMP'
                              ,pr_dsdchave => rw_reneg.cdcooper
                              ,pr_flgdecre => 'N');
  
    INSERT INTO CECRED.tbepr_renegociacao
      (CDCOOPER
      ,NRDCONTA
      ,NRCTREMP
      ,FLGDOCJE
      ,IDFINIOF
      ,DTDPAGTO
      ,QTPREEMP
      ,VLEMPRST
      ,VLPREEMP
      ,DTLIBERA
      ,IDFINTAR)
    VALUES
      (rw_reneg.cdcooper
      ,rw_reneg.nrdconta
      ,vr_sequence
      ,0
      ,crawepr_atual.idfiniof
      ,crawepr_atual.dtdpagto
      ,crawepr_atual.qtpreemp
      ,crawepr_atual.vlemprst
      ,crawepr_atual.vlpreemp
      ,crawepr_atual.dtmvtolt
      ,0);
  
    INSERT INTO CECRED.tbepr_renegociacao_contrato
      (CDCOOPER
      ,NRDCONTA
      ,NRCTREMP
      ,NRCTREPR
      ,NRVERSAO
      ,VLSDEVED
      ,VLNVSDDE
      ,VLNVPRES
      ,TPEMPRST
      ,NRCTROTR
      ,CDFINEMP
      ,CDLCREMP
      ,DTDPAGTO
      ,IDCARENC
      ,DTCARENC
      ,VLPRECAR
      ,VLIOFEPR
      ,VLTAREPR
      ,IDQUALOP
      ,NRDIAATR
      ,CDLCREMP_ORIGEM
      ,CDFINEMP_ORIGEM
      ,VLEMPRST
      ,VLFINANC
      ,VLIOFADC
      ,VLIOFPRI
      ,PERCETOP
      ,FLGIMUNE
      ,TPCONTRATO_LIQUIDADO
      ,INCANCELAR_PRODUTO
      ,NRCTREMP_NOVO)
    VALUES
      (rw_reneg.cdcooper
      ,rw_reneg.nrdconta
      ,vr_sequence
      ,rw_reneg.nrctremp
      ,NVL(rw_versao_reneg.nrversao, 1)
      ,crapepr_atual.vlsdeved
      ,NVL(crapepr_antes.vlsdeved, crapepr_atual.vlsdeved)
      ,crapepr_atual.vlpreemp
      ,crapepr_atual.tpemprst
      ,0
      ,crapepr_atual.cdfinemp
      ,crapepr_atual.cdlcremp
      ,crawepr_atual.dtdpagto
      ,0
      ,NULL
      ,0
      ,crapepr_atual.vliofepr
      ,crapepr_atual.vltarifa
      ,crapepr_atual.idquaprc
      ,1
      ,CASE WHEN rw_reneg.tpcontrato_liquidado = 2 THEN
       crapepr_atual.cdlcremp ELSE crapepr_antes.cdlcremp END
      ,CASE WHEN rw_reneg.tpcontrato_liquidado = 2 THEN
       crapepr_atual.cdfinemp ELSE crapepr_antes.cdfinemp END
      ,crawepr_atual.vlemprst
      ,crawepr_atual.vlemprst
      ,crapepr_atual.vliofadc
      ,crapepr_atual.vliofpri
      ,crawepr_atual.percetop
      ,0
      ,rw_reneg.tpcontrato_liquidado
      ,0
      ,rw_reneg.nrctremp_novo);
  
  
  
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
