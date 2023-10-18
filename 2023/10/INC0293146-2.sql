BEGIN
	delete from  CECRED.tbcrd_limite_atualiza
	where cdcooper = 1
	and   nrdconta = 10505792
	and   nrproposta_est in (3193392,1598061);
   
    commit;
END;
