BEGIN
  INSERT INTO cecred.crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 0, 'DIAS_MAX_REPIQUE_SEGPRE', 'Dias maximo para realização do repique do seguro contributario', '181');
  COMMIT;
END;
/
