 UPDATE crapprm p
    SET p.dsvlrprm = 'https://wsayllos.cecred.coop.br/taxa'
  WHERE p.cdacesso = 'URI_WEBSRV_RET_MOTOR_SIM'
    AND p.cdcooper = 0
    AND p.nmsistem = 'CRED';
	
COMMIT;