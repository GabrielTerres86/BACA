-- RITM0079334 - Alterar e-mail para enviar o resultado do processamento do arquivo de conciliação da Saque e Pague
-- Douglas Quisinski - 10/06/2020

BEGIN
	UPDATE crapprm prm
	   SET prm.dsvlrprm = 'leonardo@ailos.coop.br'
	 WHERE prm.nmsistem = 'CRED'
	   and prm.cdcooper = 0
	   and prm.cdacesso = 'SAQUE_PAGUE_E-MAIL';
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;