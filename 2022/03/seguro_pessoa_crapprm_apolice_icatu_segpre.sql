BEGIN
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 0, 'APOLICE_ICATU_SEGPRE', 'Apólice do seguro contributário ICATU para teste', '77000799');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
