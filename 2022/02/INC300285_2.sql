BEGIN

declare

  vr_nrctrcrd crawcrd.nrctrcrd%TYPE;
  vr_nrseqcrd crawcrd.nrseqcrd%TYPE;

begin

/* conta cartao 7563239671220 */

begin

  vr_nrctrcrd := fn_sequence('CRAPMAT','NRCTRCRD', 2);
  vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(2);

   insert into tbcrd_conta_cartao (
         cdcooper,
         nrdconta,
         nrconta_cartao,
         vllimite_global,
         cdadmcrd ) values (
          1,
          11250399,
          7563239671220,
          '',
          15
         );
   
  commit;     
  
  insert into crawcrd
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
  values  (11250399,        -- nrdconta
    '5474080218637963',     -- nrcrcard
    7563239671220,        -- nrcctitg
    7861047911,        -- nrcpftit
    3200,         -- vllimcrd (obtido no Sipagnet)
    3,          -- flgctitg
    trunc(sysdate),       -- dtmvtolt
    'GEICE NAIARA SOARES',     -- nmextttl
    0,          -- flgprcrd (primeiro cartão da adm para a conta)
    1,          -- tpdpagto (forma de pagamento da fatura)
    1,          -- flgdebcc (débito em conta corrente)
    0,          -- tpenvcrd (forma de envio do cartão)
    0,          -- vlsalari (valor salário)
    22,         -- dddebito (dia do débito)
    0,         -- cdlimcrd (feito select na tabela craptlc)
    2,          -- tpcartao (tipo de cartão)
    to_date('09/03/2020','dd/mm/yyyy'), -- dtnasccr (obtido no Sipagnet)
    '04638311837',      -- nrdoccrd (arquivo posição 230, tamanho 15)
    'GEICE NAIARA SOARES',     -- nmtitcrd
    vr_nrctrcrd,        -- nrctrcrd
    15,         -- cdadmcrd (obtido da tbcrd_conta_cartao porque registro já existe, mas pode ser obtido grupo afinidade no arquivo posição 42, tamanho 7, dados da conta cartão e feito select na function cartao.crd_grupo_afinidade_bin.consultarADMGrpAfin(cooperativa, grupo afinidade) */
    1,          -- cdcooper
    vr_nrseqcrd,        -- nrseqcrd
    to_date('14/07/2021','dd/mm/rrrr'), -- dtpropos
    to_date('14/07/2021','dd/mm/rrrr'), -- dtsolici
    0,          -- flgdebit (habilita função débito)
    5,          -- cdgraupr (grau de parentesco entre os titulares)
    4,          -- insitcrd
    trunc(sysdate),       -- dtlibera
    2         -- insiw3tdec (indicar de decisão sobre a análise do crédito do cartão)
    );

  insert into crapcrd
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
    11250399,         -- nrdconta
    5474080218637963,     -- nrcrcard
    7861047911,        -- nrcpftit
    'GEICE NAIARA SOARES',     -- nmtitcrd
    22,         -- dddebito
    0,         -- cdlimcrd
    NULL,         -- dtvalida (data de validade -- valor padrão null)
    vr_nrctrcrd,        -- nrctrcrd
    0,          -- cdmotivo (valor padrão 0)
    0,          -- nrprotoc (valor padrão 0)
    15,         -- cdadmcrd
    2,          -- tpcartao
    NULL,         -- dtcancel
    1,          -- flgdebit
    0         -- flgprovi (só será 1 quando o nome no cartã é "CARTAO PROVISORIO")
    );

   update CRAWCRD set
         nrcctitg = 7563239671220,
         insitcrd = 6
   where cdcooper = 1
   and nrdconta = 11250399
   and nrctrcrd = 1967666;
  
   commit;  
  
   delete from crawcrd a
   where a.cdcooper = 1
   and a.nrdconta = 11250399
   and a.nrctrcrd = 1967669;
  
  commit;

  /* 7564438062146 */
  
    insert into tbcrd_conta_cartao (
         cdcooper,
         nrdconta,
         nrconta_cartao,
         vllimite_global,
         cdadmcrd ) values (
          11,
          773964,
          7564438062146,
          '',
          16
         );
   
  commit;    
  
   UPDATE CRAWCRD
       SET NRCRCARD = 6393500103927878
          ,INSITCRD = 4
          ,NRCCTITG = 7564438062146
          ,CDLIMCRD = 0
    ,dtrejeit = null
    ,dtlibera = trunc(SYSDATE)
    ,dtentreg = null
     WHERE CDCOOPER = 11
       AND NRDCONTA = 773964
       AND NRCTRCRD = 147227;
       
     INSERT INTO crapcrd
           (cdcooper
           ,nrdconta
           ,nrcrcard
           ,nrcpftit
           ,nmtitcrd
           ,dddebito
           ,cdlimcrd
           ,dtvalida
           ,nrctrcrd
           ,cdmotivo
           ,nrprotoc
           ,cdadmcrd
           ,tpcartao
           ,dtcancel
           ,flgdebit
           ,flgprovi)
        VALUES
           (11
           ,773964
           ,6393500103927878
           ,10616378912
           ,'TALITA C C DIAS'
           ,0
           ,0
           ,NULL
           ,147227
           ,0
           ,0
           ,16
           ,2
           ,NULL
           ,1
           ,0);
  COMMIT;
  
  /* Conta 7563232018039 */
  
  insert into tbcrd_conta_cartao (
         cdcooper,
         nrdconta,
         nrconta_cartao,
         vllimite_global,
         cdadmcrd ) values (
          6,
          201901,
          7563232018039,
          '',
          15
         );
   
  commit;     
end;

commit;

end;

END;
