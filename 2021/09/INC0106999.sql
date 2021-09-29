UPDATE 
	TBBLQJ_ORDEM_ONLINE
SET 
	INSTATUS = 4, 
	DSLOG_ERRO = 'Ajuste Manual,Envio da TED nao concluido, critica 1171; (erro craplot)'
WHERE 
	IDORDEM = 2305456;

COMMIT;
