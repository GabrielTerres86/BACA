declare

  vr_nrctrcrd crawcrd.nrctrcrd%TYPE;
  vr_nrseqcrd crawcrd.nrseqcrd%TYPE;

begin

  vr_nrctrcrd := fn_sequence('CRAPMAT','NRCTRCRD', 2);
  vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(2);

  insert into cecred.crawcrd
    (nrdconta,
    nrcrcard,
    nrcctitg,
    nrcpftit,
    vllimcrd,
    flgctitg,
    dtmvtolt,
    nmextttl,
    flgprcrd,
    tpdpagto,
    flgdebcc,
    tpenvcrd,
    vlsalari,
    dddebito,
    cdlimcrd,
    tpcartao,
    dtnasccr,
    nrdoccrd,
    nmtitcrd,
    nrctrcrd,
    cdadmcrd,
    cdcooper,
    nrseqcrd,
    dtpropos,
    dtsolici,
    flgdebit,
    cdgraupr,
    insitcrd,
    dtlibera,
    insitdec)
  values  (950521,
           5474080364028579,
           7564438085820,
           10265625971,
           1000,
           3,
           trunc(sysdate),
           'SINAL SAT COMERCIO E SERVICOS ELETRICOS LTDA',
           1,
           1,
           1,
           0,
           0,
           19,
           0,
           2,
           to_date('11/04/1997','DD/MM/YYYY'),
           06411980483,
           'JORDAN CALASANS',
           vr_nrctrcrd,
           15,
           11,
           vr_nrseqcrd,
           to_date('16/05/2022','DD/MM/YYYY'),
           to_date('16/05/2022','DD/MM/YYYY'),
           1,
           5,
           3,
           null,
           3);

  insert into cecred.crapcrd
    (cdcooper,
    nrdconta,
    nrcrcard,
    nrcpftit,
    nmtitcrd,
    dddebito,
    cdlimcrd,
    dtvalida,
    nrctrcrd,
    cdmotivo,
    nrprotoc,
    cdadmcrd,
    tpcartao,
    dtcancel,
    flgdebit,
    flgprovi)
  values  (11,
           950521,
           5474080364028579,
           10265625971,
           'JORDAN CALASANS',
           19,
           0,
           to_date('31/07/2029','DD/MM/YYYY'),
           vr_nrctrcrd,
           0,
           0,
           16,
           2,
           null,
           1,
           0);



insert into TBCRD_CONTA_CARTAO (CDCOOPER, NRDCONTA, NRCONTA_CARTAO, VLLIMITE_GLOBAL, CDADMCRD)
values (11, 950521, 7564438085820, null, 16);

commit;


end;