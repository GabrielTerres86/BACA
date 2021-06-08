-- INC0084862
UPDATE crawepr e
   SET e.dsnivris = 'B',
       e.dsnivori = 'B'
 WHERE e.cdcooper = 1
   AND e.nrdconta = 7600518
   AND e.nrctremp IN (3555624,3573233);

UPDATE tbrisco_operacoes o
   SET o.inrisco_inclusao     = 3,
       o.inrisco_rating       = 3,
       o.inrisco_rating_autom = 3,
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
-- INC0084862

-- INC0080292
UPDATE tbrisco_operacoes o
   SET o.flintegrar_sas = 1
     , o.flencerrado    = 0
 WHERE o.cdcooper = 6
   AND o.nrdconta = 163562
   AND o.nrctremp = 163562
   AND o.tpctrato = 11;

UPDATE tbrisco_operacoes o
   SET o.inrisco_rating = 2
 WHERE o.cdcooper = 6
   AND o.nrdconta = 163570
   AND o.nrctremp = 163570
   AND o.tpctrato = 11;
-- INC0080292

COMMIT;
