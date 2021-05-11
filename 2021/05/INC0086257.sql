--INC0086257 Diferença de Depósito à Vista Consignado- Civia 12/04 - Falta (Operação de Crédito)
DECLARE
  vr_cdhistor         craplem.cdhistor%type;
  vr_nrdolote         craplem.nrdolote%type;
  vr_cdcritic         number;
  vr_dscritic         varchar2(2000);
  vr_dtmvtolt         crapdat.dtmvtolt%type;

    CURSOR cr_craplem is

      SELECT * 
      FROM   CRAPLEM
      WHERE  cdcooper = 13
        AND trunc(dtmvtolt) = trunc(to_date('12/04/2021', 'DD/MM/YYYY' ))
        AND cdhistor = 1077 -- JUROS DE MORA -/- JURO MORA EMPRESTIMO PRE-FIXADO
        AND nrdconta in (41599,44164,59382,100161,102229,105015,124982,127582,130362,131415,135828,140660,141054,141496,143782,145742,
                          147753,148318,149632,149896,153397,155578,158313,158402,159859,161110,167894,168491,178888,179922,181617,
                          181722,182958,183334,186198,187747,187801,187895,192228,192694,200123,207144,212849,215902,216771,224162,
                          226327,226424,240982,241164,247057,248355,258598,265691,266744,274496,277193,277231,287296,295159,305839,
                          337471,340464,342599,343358,350605,373567,376639,391549,418978,427420,433063,443948,447510,472611,480991,
                          486230,487090,495310,506508,506893,524808,526118,545805,601063,709859);


  CURSOR cr_crapdat ( pr_cdcooper in craplcm.cdcooper%type ) is
      SELECT  dat.dtmvtolt
      FROM    crapdat   dat
      WHERE dat.cdcooper = pr_cdcooper;

BEGIN
  dbms_output.enable(1000000);    

    OPEN cr_crapdat ( pr_cdcooper => 13 ); --CIVIA
    FETCH  cr_crapdat
    INTO  vr_dtmvtolt;
    CLOSE cr_crapdat;    

    FOR rw_craplem IN cr_craplem  LOOP     
      
      dbms_output.put_line( 'Cooperativa:'      || rw_craplem.cdcooper    || ' ' ||
                           ' Conta:'            || rw_craplem.nrdconta    || ' ' ||
                           ' Contrato:'         || rw_craplem.nrctremp    || ' ' ||
                           ' Parcela:'          || rw_craplem.nrparepr    || ' ' ||
                           ' Valor duplicado:'  || rw_craplem.vllanmto    || ' ' ||
                           ' Valor lancado:'    || rw_craplem.vllanmto    || ' ' ||
                           ' Historico:'        || '1711 - EST.JUROS EMP -/- ESTORNO JUROS TAXA PRE-FIXADA'
                           );
  
        vr_cdhistor := 1711;                -- EST.JUROS EMP -/- ESTORNO JUROS TAXA PRE-FIXADA
        vr_nrdolote := 600031;        

        cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => rw_craplem.cdcooper,
                                               pr_dtmvtolt => vr_dtmvtolt, 
                                               pr_cdagenci => rw_craplem.cdagenci,
                                               pr_cdbccxlt => 100,
                                               pr_cdoperad => 1,
                                               pr_cdpactra => rw_craplem.cdagenci,
                                               pr_tplotmov => 5,
                                               pr_nrdolote => vr_nrdolote,
                                               pr_nrdconta => rw_craplem.nrdconta,
                                               pr_cdhistor => vr_cdhistor,
                                               pr_nrctremp => rw_craplem.nrctremp,
                                               pr_vllanmto => rw_craplem.vllanmto,
                                               pr_dtpagemp => vr_dtmvtolt,
                                               pr_txjurepr => 0,
                                               pr_vlpreemp => 0,
                                               pr_nrsequni => 0,
                                               pr_nrparepr => 0,
                                               pr_flgincre => true,
                                               pr_flgcredi => true,
                                               pr_nrseqava => 0,
                                               pr_cdorigem => 5,
                                               pr_cdcritic => vr_cdcritic,
                                               pr_dscritic => vr_dscritic);           
    END LOOP;
  COMMIT;
EXCEPTION
  WHEN others THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20501, SQLERRM);
END;
/
