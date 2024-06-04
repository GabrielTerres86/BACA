BEGIN
  UPDATE cobranca.tbcobran_ailosmais_conta_corrente a
     SET a.nrconta_corrente = 99149931
   WHERE a.cdcooperativa = 14
     AND a.idailosmais_conta_corrente = '115E99116DE207AEE0630A29357CFFEB';
  COMMIT;
END;
