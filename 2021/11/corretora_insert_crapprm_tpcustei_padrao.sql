BEGIN
  FOR st_cdcooper IN (SELECT c.cdcooper FROM crapcop c) LOOP
    INSERT INTO crapprm
      (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
      ('CRED',
       st_cdcooper.cdcooper,
       'TPCUSTEI_PADRAO',
       'Valor padr�o do tipo de custeio para cadastro de uma nova linha de cr�dito',
       '0');
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
