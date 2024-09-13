BEGIN
    INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao (DTREFERENCIA, TPMARCO)
    VALUES (to_date('12-09-2024', 'dd-mm-yyyy'), 1);
    
    INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao (DTREFERENCIA, TPMARCO)
    VALUES (to_date('13-09-2024', 'dd-mm-yyyy'), 1);
    
    DELETE tbgen_batch_paralelo a 
     WHERE a.cdcooper = 7
       AND a.dtmvtolt >= to_date('09/09/2024', 'dd/mm/yyyy');

    COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END;

