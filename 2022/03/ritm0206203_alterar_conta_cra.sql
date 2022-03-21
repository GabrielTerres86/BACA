BEGIN

      UPDATE crapprm 
         SET crapprm.dsvlrprm = '237;0099;3027651;INSTITUTO DE PROTESTOS DE TÍTULOS;03.656.766/0003-89;CC;2'
       WHERE crapprm.nmsistem = 'CRED'
         AND crapprm.cdcooper = 3
         AND crapprm.cdacesso = 'CONTA_IEPTB'
         AND crapprm.dsvlrprm = '237;0099;002836;INSTITUTO DE PROTESTOS DE TÍTULOS;03.656.766/0003-89;CC;2';

	commit;
END;
