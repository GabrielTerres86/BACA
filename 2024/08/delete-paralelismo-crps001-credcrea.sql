BEGIN

   DELETE FROM tbgen_batch_paralelo WHERE cdcooper = 7 AND TRUNC(dtmvtolt) = '30/09/2024';

   COMMIT;

END;