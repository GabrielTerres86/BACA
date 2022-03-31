BEGIN
  	
  FOR st_cdcooper IN (SELECT c.cdcooper FROM crapcop c) LOOP
    INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES ('CRED',st_cdcooper.cdcooper,'TPCUSTEI_PADRAO','Valor padrão do tipo de custeio para cadastro de uma nova linha de crédito','1');
  END LOOP;
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 0, 'FIM_VIG_PRESTAMISTA', 'Quantidade de anos para fim de vigência contratação seguro prestamista', '5');
	
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/

