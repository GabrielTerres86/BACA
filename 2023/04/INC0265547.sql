BEGIN
  UPDATE cecred.tbcrd_fatura
  SET insituacao = 4
  WHERE cdcooper = 1
  and nrdconta = 3750744
  and insituacao = 1;
  COMMIT;
END;
