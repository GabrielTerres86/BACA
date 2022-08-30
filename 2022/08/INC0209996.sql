BEGIN

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
  values  (13163426,        -- nrdconta
    '5161620001760205',     -- nrcrcard
    7563239788757,        -- nrcctitg
    9199720981,        -- nrcpftit
    310000,         -- vllimcrd (obtido no Sipagnet)
    3,          -- flgctitg
    trunc(sysdate),       -- dtmvtolt
    'DAMARIS CRISTINA RODRIGUES DA SILVA FELIX ARAUJO',     -- nmextttl
    1,          -- flgprcrd (primeiro cartão da adm para a conta)
    1,          -- tpdpagto (forma de pagamento da fatura)
    1,          -- flgdebcc (débito em conta corrente)
    0,          -- tpenvcrd (forma de envio do cartão)
    0,          -- vlsalari (valor salário)
    11,         -- dddebito (dia do débito)
    0,         -- cdlimcrd (feito select na tabela craptlc)
    2,          -- tpcartao (tipo de cartão)
    to_date('26/05/1992','dd/mm/yyyy'), -- dtnasccr (obtido no Sipagnet)
    '0',      -- nrdoccrd (arquivo posição 230, tamanho 15)
    'DAMARIS DE A SILVA',     -- nmtitcrd
    vr_nrctrcrd,        -- nrctrcrd
    18,         -- cdadmcrd (obtido da tbcrd_conta_cartao porque registro já existe, mas pode ser obtido grupo afinidade no arquivo posição 42, tamanho 7, dados da conta cartão e feito select na function cartao.crd_grupo_afinidade_bin.consultarADMGrpAfin(cooperativa, grupo afinidade) */
    1,          -- cdcooper
    vr_nrseqcrd,        -- nrseqcrd
    to_date('23/08/2022','dd/mm/rrrr'), -- dtpropos
    to_date('23/08/2022','dd/mm/rrrr'), -- dtsolici
    1,          -- flgdebit (habilita função débito)
    5,          -- cdgraupr (grau de parentesco entre os titulares)
    3,          -- insitcrd
    trunc(sysdate),       -- dtlibera
    2         -- insiw3tdec (indicar de decisão sobre a análise do crédito do cartão)
    );

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
  values  (1,         -- cdcooper
    13163426,         -- nrdconta
    5161620001760205,     -- nrcrcard
    9199720981,        -- nrcpftit
    'DAMARIS DE A SILVA',     -- nmtitcrd
    11,         -- dddebito
    0,         -- cdlimcrd
    NULL,         -- dtvalida (data de validade -- valor padrão null)
    vr_nrctrcrd,        -- nrctrcrd
    0,          -- cdmotivo (valor padrão 0)
    0,          -- nrprotoc (valor padrão 0)
    18,         -- cdadmcrd
    2,          -- tpcartao
    NULL,         -- dtcancel
    1,          -- flgdebit
    0         -- flgprovi (só será 1 quando o nome no cartã é "CARTAO PROVISORIO")
    );


    commit;     
  end;


END;
