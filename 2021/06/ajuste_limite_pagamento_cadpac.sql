BEGIN

  UPDATE crapage age
     SET age.vllimpag = 80
   WHERE age.cdcooper = 2
     AND age.vllimpag > 0;

  COMMIT;

END;
