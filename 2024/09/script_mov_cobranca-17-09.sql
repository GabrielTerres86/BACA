BEGIN
    INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao (DTREFERENCIA, TPMARCO)
    VALUES (to_date('17-09-2024', 'dd-mm-yyyy'), 1);

    COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END;

