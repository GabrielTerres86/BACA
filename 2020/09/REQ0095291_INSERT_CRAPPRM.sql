BEGIN

	insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
	values ('CRED', 0, 'AUTBUR_SCRIPT_SFTP_PREST', 'Script para envio e recebimento dos arquivos prestamistas via SFTP', '/usr/local/bin/exec_comando_oracle.sh perl_remoto /usr/local/cecred/bin/sftp_envia_recebe_1224.pl');

	COMMIT;
END;