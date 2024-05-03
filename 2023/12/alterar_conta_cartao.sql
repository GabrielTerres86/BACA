DECLARE
  vr_cooperativa INTEGER := 9;
  vr_conta       INTEGER := 99999595;
  vr_cartao      NUMBER(25) := 6393500000038738;
  vr_nrctrcrd    INTEGER := 9099999;
  vr_cpf_titular NUMBER(20);
  
BEGIN

insert into crapcrd (NRDCONTA, NRCRCARD, NRCPFTIT, NMTITCRD, DDDEBITO, CDLIMCRD, DTVALIDA, NRCTRCRD, DTCANCEL, CDMOTIVO, NRPROTOC, DTANUCRD, VLANUCRD, INANUCRD, CDADMCRD, TPCARTAO, DTULTVAL, VLLIMDLR, CDCOOPER, DTALTVAL, DTALTLIM, DTALTLDL, DTALTDDB, INACETAA, QTSENERR, CDOPETAA, DTACETAA, DSSENTAA, FLGDEBIT, DSSENPIN, CDOPEORI, CDAGEORI, DTINSORI, DTREFATU, FLGPROVI, DTASSELE, DTASSSUP) values (84398060, 6393500000038738.00, 1809698030.00, 'LAIS CARDOSO ', 32, 0, to_date('30-04-2025', 'dd-mm-yyyy'), 9999971, null, 0, 0.00, null, 0.00, 0, 16, 2, null, 0.00, 8, null, null, null, null, 1, 0, '1', to_date('15-02-2024', 'dd-mm-yyyy'), 'QchybOzfpbVbccmk', 1, '74E21A4ACFD6D521', ' ', 0, null, to_date('26-03-2024', 'dd-mm-yyyy'), 0, null, null);
insert into crawcrd (NRCRCARD, NRDCONTA, NMTITCRD, NRCPFTIT, CDGRAUPR, VLSALARI, VLSALCON, VLOUTRAS, VLALUGUE, DDDEBITO, CDLIMCRD, DTPROPOS, CDOPERAD, INSITCRD, NRCTRCRD, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRSEQDIG, DTSOLICI, DTENTREG, DTVALIDA, DTANUIDA, VLANUIDA, INANUIDA, QTANUIDA, QTPARCAN, DTLIBERA, DTCANCEL, CDMOTIVO, NRPROTOC, DTENTR2V, TPCARTAO, CDADMCRD, DTNASCCR, NRDOCCRD, DTULTVAL, NRCTAAV1, FLGIMPNP, NMDAVAL1, DSCPFAV1, DSENDAV1##1, DSENDAV1##2, NRCTAAV2, NMDAVAL2, DSCPFAV2, DSENDAV2##1, DSENDAV2##2, DSCFCAV1, DSCFCAV2, NMCJGAV1, NMCJGAV2, DTSOL2VI, VLLIMDLR, CDCOOPER, FLGCTITG, DTECTITG, FLGDEBCC, FLGRMCOR, FLGPROTE, FLGMALAD, NRCCTITG, DT2VIASN, NRREPINC, NRREPENT, NRREPLIM, NRREPVEN, NRREPSEN, NRREPCAR, NRREPCAN, DDDEBANT, NMEXTTTL, TPENVCRD, TPDPAGTO, VLLIMCRD, NMEMPCRD, FLGPRCRD, NRSEQCRD, CDORIGEM, FLGDEBIT, DTREJEIT, CDOPEEXC, CDAGEEXC, DTINSEXC, CDOPEORI, CDAGEORI, DTINSORI, DTREFATU, INSITDEC, DTAPROVA, DSPROTOC, DSJUSTIF, CDOPEENT, INUPGRAD, CDOPESUP, DSOBSCMT, DTENVEST, DTENEFES, DSENDENV, IDLIMITE, IDCOMPON) values (6393500000038738.00, 84398060, 'LAIS CARDOSO ', 1809698030.00, 5, 1471.04, 0.00, 0.00, 0.00, 32, 0, to_date('12-02-2020', 'dd-mm-yyyy'), 'f0080095', 4, 9999971, to_date('12-02-2020 11:50:14', 'dd-mm-yyyy hh24:mi:ss'), 0, 0, 0, 0, to_date('12-02-2020', 'dd-mm-yyyy'), to_date('28-02-2020', 'dd-mm-yyyy'), to_date('30-04-2025', 'dd-mm-yyyy'), null, 0.00, 0, 0, 0, to_date('13-02-2020', 'dd-mm-yyyy'), to_date('27-06-2022', 'dd-mm-yyyy'), 4, 0.00, null, 2, 16, to_date('16-10-1990', 'dd-mm-yyyy'), '92538354548', null, 0, 1, ' ', ' ', ' 0', ' -  - 00000.000 - ', 0, ' ', ' ', ' 0', ' -  - 00000.000 - ', ' ', ' ', ' ', ' ', null, 0.00, 8, 3, null, 1, 0, 0, 0, 7564435003533, null, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 32, 'GUSTAVO DA COSTA', 1, 1, 0.00, 'VALORES LTDA ', 1, 4919, 0, 1, null, ' ', 0, null, 'f0080052', 3, to_date('12-02-2020', 'dd-mm-yyyy'), to_date('03-01-2024', 'dd-mm-yyyy'), 2, null, null, null, null, 0, null, null, null, null, 'AVENIDA ENRICO DIAS, 1112', 0, null);

  FOR cartao IN (SELECT DISTINCT a.nrcpftit
                   FROM crawcrd a
                  WHERE a.cdcooper = vr_cooperativa
                    AND a.nrdconta = vr_conta
                    AND a.insitcrd = 4) LOOP
    vr_cpf_titular := cartao.nrcpftit;
  END LOOP;
  IF vr_cpf_titular IS NULL THEN
    FOR titular IN (SELECT a.nrcpfcgc
                      FROM crapttl a
                     WHERE a.cdcooper = vr_cooperativa
                       AND a.nrdconta = vr_conta
                       AND a.idseqttl = 1) LOOP
      vr_cpf_titular := titular.nrcpfcgc;
    END LOOP;
  END IF;

  IF vr_cpf_titular IS NULL THEN
    RETURN;
  END IF;

  UPDATE crapcrd card
     SET card.cdcooper = vr_cooperativa
        ,card.nrdconta = vr_conta
        ,card.nrcpftit = vr_cpf_titular
        ,card.qtsenerr = 0
        ,card.inacetaa = 1
        ,card.cdadmcrd = 12
        ,card.NRCTRCRD = vr_nrctrcrd
   WHERE card.nrcrcard = vr_cartao;

  UPDATE crawcrd card
     SET card.cdcooper = vr_cooperativa
        ,card.nrdconta = vr_conta
        ,card.nrcpftit = vr_cpf_titular
        ,card.NRCTRCRD = vr_nrctrcrd
        ,card.cdadmcrd = 12
   WHERE card.nrcrcard = vr_cartao;

  COMMIT;
END;
