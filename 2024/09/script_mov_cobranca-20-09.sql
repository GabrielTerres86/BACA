BEGIN
    INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao (DTREFERENCIA, TPMARCO)
    VALUES (to_date('20-09-2024', 'dd-mm-yyyy'), 1);
    
    INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao (DTREFERENCIA, TPMARCO)
    VALUES (to_date('23-09-2024', 'dd-mm-yyyy'), 1);   

    COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END;
