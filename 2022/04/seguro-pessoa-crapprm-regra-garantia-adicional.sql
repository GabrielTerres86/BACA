BEGIN
  	
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 0, 'IDADE_COOP_SEM_GARADI', 'Idade do cooperado que não deve contratar garantia adicional no seguro prestamista contributário', '66');	
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/

