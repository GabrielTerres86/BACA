BEGIN
  --
  UPDATE cecred.crapass
    SET flgctitg = 3
  WHERE nrdconta = 827703
    and cdcooper = 1;
  --
  COMMIT;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao aplicar o script: ' || SQLERRM);
    --
END;
