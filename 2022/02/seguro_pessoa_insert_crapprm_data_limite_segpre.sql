BEGIN
  FOR rw_cdcooper IN (SELECT c.cdcooper FROM crapcop c WHERE c.flgativo = 1) LOOP
    INSERT INTO crapprm
      (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
      ('CRED',
       rw_cdcooper.cdcooper,
       'DATA_LIMITE_SEGPRE',
       'Data limite de geração de rotinas de seguro prestamista não contributário',
       TO_DATE('31/12/2022', 'DD/MM/RRRR'));
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
    ROLLBACK;
END;
/