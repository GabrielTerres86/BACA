BEGIN
  update tbblqj_ordem_online 
     set instatus = 1, dhresposta = null, dslog_erro = '' 
   where idordem in (2785801,2785802);
	 
  COMMIT;
END;