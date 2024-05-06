DECLARE

  aux_cdacesso  crapprm.cdacesso%TYPE;
  vr_existeprm	NUMBER;
 
BEGIN
	
  aux_cdacesso := 'TIMEOUT_NEUROTECH_CONSIG';
  SELECT count(1) INTO	vr_existeprm
    FROM CECRED.crapprm
   WHERE cdacesso = aux_cdacesso
     AND nmsistem = 'CRED';
  
  IF (vr_existeprm > 0) THEN  
     DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso AND nmsistem = 'CRED';	 
  END IF;
 
  aux_cdacesso := 'TIMEOUT_NEUROTECH_RENEG';
  SELECT count(1) INTO	vr_existeprm
    FROM CECRED.crapprm
   WHERE cdacesso = aux_cdacesso
     AND nmsistem = 'CRED';
  
  IF (vr_existeprm > 0) THEN  
     DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso AND nmsistem = 'CRED';	 
  END IF;
 
  aux_cdacesso := 'TIMEOUT_NEUROTECH_IMOB';
  SELECT count(1) INTO	vr_existeprm
    FROM CECRED.crapprm
   WHERE cdacesso = 'aux_cdacesso'
     AND nmsistem = 'CRED';
  
  IF (vr_existeprm > 0) THEN  
     DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso AND nmsistem = 'CRED';	 
  END IF; 
 
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED', 0, 'TIMEOUT_NEUROTECH_CONSIG', 'Quantidade Máxima de Segundos para Aguardo no momento da Requisição para a Neurotech Consignado'  , '30');
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED', 0, 'TIMEOUT_NEUROTECH_RENEG' , 'Quantidade Máxima de Segundos para Aguardo no momento da Requisição para a Neurotech Renegociação', '30');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED', 0, 'TIMEOUT_NEUROTECH_IMOB'  , 'Quantidade Máxima de Segundos para Aguardo no momento da Requisição para a Neurotech Imobiliário' , '30');

  COMMIT;
 
  EXCEPTION WHEN OTHERS THEN ROLLBACK;            

END; 


 