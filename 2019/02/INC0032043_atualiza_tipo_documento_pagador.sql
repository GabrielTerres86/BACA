-- INC0032043 - Atualizar cadatro do pagador, cpf cadastrado como cnpj. Mudar para 1 - CPF.
update crapsab b
   set b.cdtpinsc = 1 -- 1 - CPF / 2 - CNPJ
 where b.cdcooper = 1
   and nrdconta = 7737106
   and b.nrinssac in (27712737649);

-- INC0032043 - Atualizar cadatro do pagador, cnpj cadastrado como cpf. Mudar para 2 - CNPJ
update crapsab b
   set b.cdtpinsc = 2 -- 1 - CPF / 2 - CNPJ
 where b.cdcooper = 1
   and nrdconta = 7737106
   and b.nrinssac in (692880000104, 4757051000113, 4757051000202, 5090575000166, 5889213000130, 5889213000210, 5889213000300, 7087199000186, 7266606000112, 7420674000194, 11443293000106,
                      11974416000127, 12454335000169, 12816469000182, 13227197000148, 13765529000148, 14374012000190, 17428029000171, 17864502000244, 19724730000163, 36117109000150,
                      62246277000156, 64437890000267, 72380330000160);

commit;
