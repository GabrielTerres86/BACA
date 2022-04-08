BEGIN
      DELETE crapprm 
       WHERE crapprm.nmsistem = 'CRED'
         AND crapprm.cdcooper = 3
         AND crapprm.cdacesso = 'CONTA_IEPTB';
		 
	  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
	  VALUES ('CRED', 3, 'CONTA_IEPTB_CUSTAS', 'Dados da conta do IEPTB para fazer a TED', '237;0099;002836;INSTITUTO DE PROTESTOS DE TÍTULOS;03.656.766/0003-89;CC;2');

      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
	  VALUES ('CRED', 3, 'CONTA_IEPTB_TARIFAS', 'Dados da conta do IEPTB para fazer a TED', '237;0099;3027651;INSTITUTO DE PROTESTOS DE TÍTULOS;03.656.766/0003-89;CC;2');

    COMMIT;

EXCEPTION  WHEN OTHERS THEN    SISTEMA.excecaoInterna(pr_compleme => 'RITM0206203');
    ROLLBACK;

END;