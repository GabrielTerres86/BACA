BEGIN
  UPDATE cobranca.tbcobran_ailosmais_conta_corrente a
     SET a.nrconta_corrente = 18712665
   WHERE a.idailosmais_conta_corrente = '115E99116DE207AEE0630A29357CFFEB';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO ' || SQLERRM);
    ROLLBACK;
END;
