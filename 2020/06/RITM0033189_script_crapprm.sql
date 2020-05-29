DECLARE
BEGIN
  FOR rw_crapcop IN (SELECT c.cdcooper FROM crapcop c WHERE c.flgativo = 1) LOOP

    INSERT INTO CRAPPRM
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES
      ('CRED',
        rw_crapcop.cdcooper,
       'DATA_TARI_DOCMTO_BORDERO',
       'Data de início de tarifacao titulo liberado no bordero',
       SYSDATE);

  END LOOP;

  COMMIT;
END;
