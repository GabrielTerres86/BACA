BEGIN
	INSERT INTO tbcrd_situacao (cdsitadm, dssitadm, cdsitcrd, cdmotivo)
	VALUES (5, 'Periodo Utilização Excedido', 6, 5);

	INSERT INTO tbcrd_situacao (cdsitadm, dssitadm, cdsitcrd, cdmotivo)
	VALUES (27, 'Período Utilização Excedido Temp', 6, 5);
	INSERT INTO tbcrd_situacao (cdsitadm, dssitadm, cdsitcrd, cdmotivo)

	VALUES (95, 'Bloqueio Parcial', 1, 0);
	INSERT INTO tbcrd_situacao (cdsitadm, dssitadm, cdsitcrd, cdmotivo)
	VALUES (96, 'Bloqueio Total', 6, 5);

	INSERT INTO tbcrd_situacao (cdsitadm, dssitadm, cdsitcrd, cdmotivo)
	VALUES (97, 'Cancelamento Definitivo', 6, 5);

	COMMIT;
  
END;	