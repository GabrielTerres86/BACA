DECLARE

  aux_cdacesso  crapprm.cdacesso%TYPE;
  vr_existeprm	NUMBER;
BEGIN

  aux_cdacesso := 'REGRA_ANL_IBRA_IMOB_PF';

  SELECT count(1)
  INTO	vr_existeprm
  FROM crapprm
  WHERE cdacesso = aux_cdacesso
  AND nmsistem = 'CRED';
  
  IF (vr_existeprm > 0) THEN
  
    DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso AND nmsistem = 'CRED';
	COMMIT;
  
  END IF;
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',1, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',2, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',5, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',6, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',7, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',8, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',9, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',10, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',11, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',12, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',13, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');  
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',14, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',16, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario','PoliticaGeralFinancPF');

  COMMIT;  

    aux_cdacesso := 'REGRA_ANL_IBRA_IMOB_PJ';

  SELECT count(1)
  INTO	vr_existeprm
  FROM crapprm
  WHERE cdacesso = aux_cdacesso
  AND nmsistem = 'CRED';
  
  IF (vr_existeprm > 0) THEN
  
    DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso AND nmsistem = 'CRED';
	COMMIT;
  
  END IF;
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',1, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',2, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',5, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',6, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',7, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',8, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',9, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',10, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',11, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',12, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',13, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',14, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',16, aux_cdacesso, 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for Imobiliario PJ','PoliticaGeralFinancPJ');  
 
END;
