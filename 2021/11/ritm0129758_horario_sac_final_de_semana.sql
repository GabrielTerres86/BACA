BEGIN

	INSERT INTO CRAPPRM(NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES('CRED', 0 , 'HORA_SAC_FDS_INI', 'Hora inicial de funcionamento do SAC nos finais de semanas e feriados.','08:00' );
	INSERT INTO CRAPPRM(NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) VALUES('CRED', 0 , 'HORA_SAC_FDS_FIM', 'Hora final de funcionamento do SAC nos finais de semanas e feriados.','20:00' );
	COMMIT;

END;