begin 
  update tbcc_lancamentos_pendentes lp
     set lp.idsituacao = 'A'
   where lp.idsituacao = 'E'
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

