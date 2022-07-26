BEGIN
	INSERT INTO crapprm 
	  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
	VALUES 
	  ('CRED', 0, 'ENVIAR_TRANSF_AILOS_MAIS', 'Chave Liga/Desliga da chamada do envio de transfência ao OFSAA para o Ailos+', '0');
	COMMIT;
END;	
/