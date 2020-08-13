-- Atualizar quantidade de linhas para quebra do arquivo para 25000
UPDATE tbgen_notif_params par
SET par.dsvalor = 25000
WHERE par.cdacesso = 'QTD_LINHAS_QBR_ARQ';

UPDATE crapprm prm
   SET prm.dsvlrprm = '25000'
 WHERE prm.cdcooper = 0
   AND prm.nmsistem = 'CRED'
   AND prm.cdacesso = 'PARBAN_QTD_LINH_QBR_ARQ';
	 
COMMIT;
