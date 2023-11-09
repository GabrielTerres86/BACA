DECLARE

  aux_cdacesso  crapprm.cdacesso%TYPE;
  vr_existeprm	NUMBER;
BEGIN

  aux_cdacesso := 'REGRA_PF_MOTOR_7';

  SELECT count(1)
  INTO	vr_existeprm
  FROM crapprm
  WHERE cdacesso = aux_cdacesso;
  
  IF (vr_existeprm > 0) THEN
  
    DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso;
	COMMIT;
  
  END IF;
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',0, aux_cdacesso, 'Nome da politica PF de Renegociacao no Motor de Credito NEUROTECH ','LEGADO_RENEGOCIACAO_PF');

  COMMIT;  

  aux_cdacesso := 'REGRA_PJ_MOTOR_7';

  SELECT count(1)
  INTO	vr_existeprm
  FROM crapprm
  WHERE cdacesso = aux_cdacesso;
  
  IF (vr_existeprm > 0) THEN
  
    DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso;
	COMMIT;
  
  END IF;
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',0, aux_cdacesso, 'Nome da politica PJ de Renegociacao no Motor de Credito NEUROTECH ','LEGADO_RENEGOCIACAO_PJ');  

  COMMIT;
  
  aux_cdacesso := 'REGRA_PF_MOTOR_8';

  SELECT count(1)
  INTO	vr_existeprm
  FROM crapprm
  WHERE cdacesso = aux_cdacesso;
  
  IF (vr_existeprm > 0) THEN
  
    DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso;
	COMMIT;
  
  END IF;
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',0, aux_cdacesso, 'Nome da politica PF de Consignado no Motor de Credito NEUROTECH ','LEGADO_CONSIGNADO_PF');

  COMMIT;

  aux_cdacesso := 'REGRA_PF_MOTOR_9';

  SELECT count(1)
  INTO	vr_existeprm
  FROM crapprm
  WHERE cdacesso = aux_cdacesso;
  
  IF (vr_existeprm > 0) THEN
  
    DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso;
	COMMIT;
  
  END IF;
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',0, aux_cdacesso, 'Nome da politica PF de Imobiliario PF no Motor de Credito NEUROTECH ','LEGADO_IMOBILIARIO_PF');

  COMMIT;
  
  aux_cdacesso := 'REGRA_PJ_MOTOR_9';

  SELECT count(1)
  INTO	vr_existeprm
  FROM crapprm
  WHERE cdacesso = aux_cdacesso;
  
  IF (vr_existeprm > 0) THEN
  
    DELETE FROM CECRED.CRAPPRM WHERE CDACESSO = aux_cdacesso;
	COMMIT;
  
  END IF;
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',0, aux_cdacesso, 'Nome da politica PF de Imobiliario PJ no Motor de Credito NEUROTECH ','LEGADO_IMOBILIARIO_PJ');

  COMMIT;
 
END;
