DELETE FROM crapcyb
 WHERE CDCOOPER = 14
   AND CDORIGEM = 5
   AND NRDCONTA = 53694
   AND NRCTREMP = 6187;

UPDATE tbgen_batch_controle c
   SET c.insituacao = 2
 where c.cdcooper = 3
   and c.cdprogra = 'CRPS652'
   and c.dtmvtolt = '12/07/2019'
   and c.nrexecucao = 1
   AND c.tpagrupador = 3
   and c.insituacao = 1;

DELETE FROM crappar p
 WHERE p.flcontro = 1
   and p.idprogra = 1400001;

COMMIT;
