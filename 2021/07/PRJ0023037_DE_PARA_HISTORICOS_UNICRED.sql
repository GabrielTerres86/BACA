BEGIN
	
	INSERT INTO crapprd (cdprodut, dsprodut, cdarnego) VALUES (29, 'CARTAO VISA UNICRED', 4);
	
	INSERT INTO cartao.tbcrd_his_vinculo_unicred VALUES (3469, 3577);
	INSERT INTO cartao.tbcrd_his_vinculo_unicred VALUES (5812, 3578);
	INSERT INTO cartao.tbcrd_his_vinculo_unicred VALUES (3465, 3579);
	INSERT INTO cartao.tbcrd_his_vinculo_unicred VALUES (5810, 3580);
	INSERT INTO cartao.tbcrd_his_vinculo_unicred VALUES (3467, 3581);
	INSERT INTO cartao.tbcrd_his_vinculo_unicred VALUES (5811, 3582);
	
	COMMIT;
	
END;