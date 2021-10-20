BEGIN
  UPDATE tbrecup_acordo 
     SET cdsituacao = 1
   WHERE nracordo IN (215674, 245425);
   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, 'Erro: ' || SQLERRM);
END;