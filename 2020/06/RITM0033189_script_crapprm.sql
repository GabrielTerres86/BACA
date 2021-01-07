DECLARE
BEGIN
  INSERT INTO CRAPPRM
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES
    ('CRED',
      0,
     'DATA_TARI_DOCMTO_BORDERO',
     'Data de início de tarifacao titulo liberado no bordero',
     TO_CHAR(SYSDATE,'DD/MM/RRRR'));
  COMMIT;
END;
