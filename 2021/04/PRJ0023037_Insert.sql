BEGIN
	begin

		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
		values ('TPENDERECOENTREGAUNICRED', '10', 'Residêncial', 1);

		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
		values ('TPENDERECOENTREGAUNICRED', '13', 'Correspondência', 1);

		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
		values ('TPENDERECOENTREGAUNICRED', '14', 'Complementar', 1);

		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
		values ('TPENDERECOENTREGAUNICRED', '9', 'Comercial', 1);

		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
		values ('TPENDERECOENTREGAUNICRED', '90', 'PA', 1);

		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
		values ('TPENDERECOENTREGAUNICRED', '91', 'Outro PA', 1);

		insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
		values ('TPFUNCIONALIDADEENTREGA', '2', 'Envio de cartão de crédito VISA - Unicred para o endereço do cooperado', 1);

		Commit;
		
	end;

	BEGIN
	  insert INTO crapprm p
		(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
	  VALUES
		('CRED',
		 3,
		 'QTD_REG_FILA_CARTAO_VISA',
		 'Quantidade de registros para processar fila de integracao do cartao visa',
		 20);
	  COMMIT;
	END;
	
	BEGIN
    -- Compra debito
		INSERT INTO tbcrd_his_vinculo_unicred VALUES (3469, 3577);
	  -- Estorno
		INSERT INTO tbcrd_his_vinculo_unicred VALUES (5812, 3578);
	  -- Saque ATM   
		INSERT INTO tbcrd_his_vinculo_unicred VALUES (3465, 3579);
	  -- Estorno Saque ATM   
		INSERT INTO tbcrd_his_vinculo_unicred VALUES (5810, 3580);
	  -- Tarifa Saque ATM
		INSERT INTO tbcrd_his_vinculo_unicred VALUES (3467, 3581);
		-- Estorno Tarifa Saque ATM        
		INSERT INTO tbcrd_his_vinculo_unicred VALUES (5811, 3582);   
	   
		COMMIT;
	END;
	
	BEGIN
		INSERT INTO tbcrd_subst_cartaovisa (nmtabela, nmcoluna, vlorigem, vlsubst) VALUES ('TBCRD_CARTAO', 'IDSTATUS', '1', '3');
		INSERT INTO tbcrd_subst_cartaovisa (nmtabela, nmcoluna, vlorigem, vlsubst) VALUES ('TBCRD_CARTAO', 'IDSTATUS', '2', '5');
		INSERT INTO tbcrd_subst_cartaovisa (nmtabela, nmcoluna, vlorigem, vlsubst) VALUES ('TBCRD_CARTAO', 'IDSTATUS', '4', '6');
	END;
END;