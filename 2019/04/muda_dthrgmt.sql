 update tbgen_batch_relatorio_wrk a
   set a.dscritic = '7560005474080090750637   2M0002803201929032019280320190000000966200000009662383477SUNSHINE 305           MEDLEY         FL0000084000000009662                       004444000000201294               05021303262143460010000000000000013701201        12000000400                                          '
 where a.cdcooper = 3
   and a.cdagenci in (97)
   and a.cdprograma = 'CRPS670'
   and a.dsrelatorio = 'DADOS_ARQ'
   and a.dtmvtolt = '03/04/2019'
   AND a.nrdconta = 240666
   and a.dscritic like '%50213%'
   and SUBSTR(a.dscritic, 1, 5) not in ('CEXT0', 'CEXT9');
  commit;   
