BEGIN
  UPDATE CONTABILIDADE.TBCONTAB_DIR_SALDO
     SET VLCIM_AMORTIZACAOFGTS = 36774.92,
         VLCIM_AMORTIZACAO = 59690.75,
         VLCIM_DEVEDOR = 153201.79
   WHERE CDCOOPER = 1
     AND NRDCONTA = 14847493
     AND NRCONTRATO = 5622630
     AND DTMVTOLT = TO_DATE('30/12/2022','dd/mm/yyyy');

  COMMIT;
END;