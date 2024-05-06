BEGIN
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',0, 'TIME_OUT_BORDEROS', 'Tempo Sleep - Consultas automatizadas Ibratan', 1);
 
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;