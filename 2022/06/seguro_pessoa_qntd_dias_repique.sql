BEGIN
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 0, 'DIAS_MAX_REPIQUE_SEGPRE', 'Dias maximo para realização do reppique do seguro contributario', '180');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
