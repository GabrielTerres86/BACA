DECLARE
BEGIN
  INSERT INTO CRAPPRM
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES
    ('CRED',
      0,
     'DATA_TARI_DOCMTO_BORDERO',
     'Data de in�cio de tarifacao titulo liberado no bordero',
     SYSDATE);
  COMMIT;
END;
