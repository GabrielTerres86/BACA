BEGIN
    INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao (DTREFERENCIA, TPMARCO)
    VALUES (to_date('30-09-2024', 'dd-mm-yyyy'), 1);
    
    INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao (DTREFERENCIA, TPMARCO)
    VALUES (to_date('01-10-2024', 'dd-mm-yyyy'), 1);   

    INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao (DTREFERENCIA, TPMARCO)
    VALUES (to_date('02-10-2024', 'dd-mm-yyyy'), 1);
    
    INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao (DTREFERENCIA, TPMARCO)
    VALUES (to_date('03-10-2024', 'dd-mm-yyyy'), 1);
    
    INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao (DTREFERENCIA, TPMARCO)
    VALUES (to_date('04-10-2024', 'dd-mm-yyyy'), 1);
     
    COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END;

