BEGIN
INSERT INTO cecred.tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES
('CALRIS_STATUS_TANQUE', 13, 'Aguardando envio de cadidato');
INSERT INTO cecred.tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES
('CALRIS_STATUS_TANQUE', 14, 'Envio de cadidato a Gupy com erro');
INSERT INTO cecred.tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES
('CALRIS_STATUS_TANQUE', 15, 'Aguardando lista reputacional');
INSERT INTO cecred.tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES
('CALRIS_STATUS_TANQUE', 16, 'Lista reputacional com erro');
COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
END;