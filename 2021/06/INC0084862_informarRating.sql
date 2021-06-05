UPDATE crawepr e
   SET e.dsnivris = 'A',
       e.dsnivori = 'A'
 WHERE e.cdcooper = 1
   AND e.nrdconta = 7600518
   AND e.nrctremp IN (3555624,3573233);

UPDATE tbrisco_operacoes o
   SET o.inrisco_inclusao     = 2,
       o.inrisco_rating       = 2,
       o.inrisco_rating_autom = 1,
       o.dtrisco_rating_autom = TO_DATE('01/06/2021'),
       o.dtrisco_rating       = TO_DATE('01/06/2021'),
       o.inorigem_rating      = 1,
       o.cdoperad_rating      = '1',
       o.innivel_rating       = 1,
       o.inpontos_rating      = 0,
       o.insegmento_rating    = ' ',
       o.flintegrar_sas       = 1,
       o.dtvencto_rating      = TO_DATE('01/06/2021'),
       o.qtdiasvencto_rating  = 180,
       o.insituacao_rating    = 4
 WHERE o.cdcooper = 1
   AND o.nrdconta = 7600518
   AND o.nrctremp IN (3555624,3573233)
   AND o.tpctrato = 90;

COMMIT;
