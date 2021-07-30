BEGIN

	/*
	 Cooperativa....: 13
     Conta..........: 385140
     Data...........: 23/07/2021
     Valor..........: 10
	 */
	 
	delete from tbcc_prejuizo_lancamento
	where cdcooper = 13
	and nrdconta = 385140
	and cdhistor = 2739
	and vllanmto = 10
	and dtmvtolt = to_date('23/07/2021', 'dd/mm/rrrr');
   
   
    /*
     Cooperativa....: 11
	 Conta..........: 433578
	 Data...........: 23/07/2021
	 Valor..........: 15,58
    */
	   
    delete from tbcc_prejuizo_lancamento
    where cdcooper = 11
    and nrdconta = 433578
    and cdhistor = 2739
    and vllanmto = 15.58
    and nrdocmto = 2
    and dtmvtolt = to_date('19/07/2021', 'dd/mm/rrrr');
	  
	  
	  
   /*
    Cooperativa....: 11
    Conta..........: 203262
    Data...........: 23/07/2021
    Valor..........: 12,52
   */
	  
	 delete from tbcc_prejuizo_lancamento
	 where cdcooper = 11
	 and nrdconta = 203262
	 and cdhistor = 2739
	 and vllanmto = 12.52
	 and nrdocmto = 2
	 and dtmvtolt = to_date('19/07/2021', 'dd/mm/rrrr');
	
	COMMIT;
	
END;