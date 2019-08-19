-- INC0031454 - Atualizar cadatro do pagador, cpf cadastrado como cnpj. Mudar para 1 - CPF.
update crapsab b
   set b.cdtpinsc = 1 -- 1 - CPF / 2 - CNPJ
 where b.cdcooper = 1
   and nrdconta = 2668874
   and b.nrinssac in (2149039907, 2292451964, 3424351911, 3973219613, 4606621982, 5549873923, 9393457905, 11233938770, 31989451861, 38369737900, 89624122920);

commit;
