BEGIN
  --
  UPDATE crapprm prm
     SET prm.DSVLRPRM = 1
   WHERE prm.NMSISTEM = 'CRED'
     AND prm.CDCOOPER = 0
     AND prm.CDACESSO = 'MLC_ATIVO';
  --
  COMMIT;
  --
END;
