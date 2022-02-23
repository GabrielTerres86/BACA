BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'DATA_LIMITE_SEGPRE',
     'Data limite de geração de rotinas de seguro prestamista não contributário',
     TO_DATE('31/12/2022', 'DD/MM/RRRR'));
     COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
END;
/