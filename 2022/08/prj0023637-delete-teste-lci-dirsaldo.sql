BEGIN
  DELETE contabilidade.tbcontab_dir_saldo
   WHERE cdcooper = 13
     AND iddirsaldo >= 1683572;
     
  COMMIT;
END;       
