DECLARE
  vr_aux_nrseqdig NUMBER;
  vr_idlancto     tbfin_recursos_movimento.idlancto%TYPE;
  vr_cdcooper     INTEGER := 3;
  vr_aux_nrctacre INTEGER := 10000003;
  vr_aux_dtmvtolt DATE:= TO_DATE('17012022','DDMMYYYY');  

BEGIN

  vr_aux_nrseqdig := fn_sequence('tbfin_recursos_movimento'
                                ,'nrseqdig'
                                ,'' || vr_cdcooper || ';' || vr_aux_nrctacre || ';' ||
                                 to_char(vr_aux_dtmvtolt, 'dd/mm/yyyy') || '');

  vr_idlancto := fn_sequence(pr_nmtabela => 'TBFIN_RECURSOS_MOVIMENTO'
                            ,pr_nmdcampo => 'IDLANCTO'
                            ,pr_dsdchave => 'IDLANCTO');

  INSERT INTO tbfin_recursos_movimento
    (CDCOOPER
    ,NRDCONTA
    ,DTMVTOLT
    ,NRDOCMTO
    ,NRSEQDIG
    ,CDHISTOR
    ,DSDEBCRE
    ,VLLANMTO
    ,NMIF_DEBITADA
    ,NRCNPJ_DEBITADA
    ,NMTITULAR_DEBITADA
    ,TPCONTA_DEBITADA
    ,CDAGENCI_DEBITADA
    ,DSCONTA_DEBITADA
    ,NRISPBIF
    ,NRCNPJ_CREDITADA
    ,NMTITULAR_CREDITADA
    ,TPCONTA_CREDITADA
    ,CDAGENCI_CREDITADA
    ,DSCONTA_CREDITADA
    ,HRTRANSA
    ,CDOPERAD
    ,DSINFORM
    ,IDLANCTO
    ,DTCONCILIACAO
    ,INPESSOA_DEBITADA
    ,INPESSOA_CREDITADA
    ,DTDEVOLUCAO_TED
    ,IDTEDDEVOLVIDA
    ,DSDEVTED_DESCRICAO
    ,INDEVTED_MOTIVO
    ,IDCONCILIACAO)
  VALUES
    (3
    ,vr_aux_nrctacre
    ,vr_aux_dtmvtolt
    ,34262612
    ,vr_aux_nrseqdig
    ,2622
    ,'C'
    ,199532.53
    ,'315557'
    ,12079319000133
    ,'INSTITUTO DE EST DE PROT DE TIT DO BR SEC SC IEPTB SC'
    ,'CC'
    ,4372
    ,'648388'
    ,315557
    ,0
    ,'MATHEUS SILVA'
    ,'CC'
    ,1
    ,'10000003'
    ,38154
    ,'1'
    ,' '
    ,vr_idlancto
    ,NULL
    ,2
    ,2
    ,NULL
    ,NULL
    ,NULL
    ,0
    ,0);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
