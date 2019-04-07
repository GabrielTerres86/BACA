UPDATE crapscb scb
   SET scb.dsdirarq = '/usr/connect/bancoob'
 WHERE scb.tparquiv = 6;
--
COMMIT;
