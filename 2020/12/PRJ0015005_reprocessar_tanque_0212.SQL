begin 

  update tbcc_lancamentos_pendentes l
     set l.idsituacao = 'M' /* Processado manualmente */
   where l.idseq_lancamento in(92645,164100);    
  
  update tbcc_lancamentos_pendentes l
     set l.idsituacao = 'A'
   where l.idsituacao = 'E'
     and l.idseq_lancamento not in(92645,164100)
     and not exists(select 1
                      from craplcm lc
                          ,tbpix_transacao tt
                     where lp.idtransacao = tt.IDTRANSACAO
                       and lc.cdcooper = tt.CDCOOPER
                       and lc.nrdconta = tt.NRDCONTA
                       and lc.cdhistor in(3396,3397,3409)
                       and lc.vllanmto = lp.vllanmto
                       and lc.dtmvtolt >= lp.dhtransacao);
	commit;   
end;   