BEGIN
  
  INSERT INTO PAGAMENTO.tbpagto_resultado_antifraude (idanalise_fraude, flresultado_antifraude) VALUES (877618481, 1);

COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
