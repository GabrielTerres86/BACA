BEGIN  
UPDATE COBRANCA.tbcobran_ailosmais_conta_corrente a
SET a.nrconta_corrente =99204720
WHERE a.cdcooperativa = 16;
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO ' || SQLERRM);
    ROLLBACK;
END;
