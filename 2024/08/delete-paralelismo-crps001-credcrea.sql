BEGIN

   DELETE FROM tbgen_batch_paralelo WHERE cdcooper = 7 AND TRUNC(dtmvtolt) = to_date('30/09/2024','dd/mm/yyyy');

   COMMIT;

END;