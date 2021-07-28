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