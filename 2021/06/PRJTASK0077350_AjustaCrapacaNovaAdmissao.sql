DECLARE

  vr_exception EXCEPTION;
  vr_msg       VARCHAR2(100);

BEGIN
  UPDATE CECRED.crapaca
    SET nmproced = 'admitirCooperadoWeb'
  WHERE upper(nmproced) = 'ADMITIRCOOPERADO'
    AND nrseqrdr = 211
    ;
  --
  IF SQL%ROWCOUNT <> 1 THEN
    vr_msg := 'Quantidade de registros alterados incorreto: ' || SQL%ROWCOUNT;
    RAISE vr_exception;
  ELSE 
    dbms_output.put_line(SQL%ROWCOUNT || ' Regisros alterados.');
  END IF;
  --
  COMMIT;
  --
EXCEPTION
  WHEN vr_exception THEN 
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar o script: ' || vr_msg);
    --
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar o script: ' || SQLERRM);
    --
END;
