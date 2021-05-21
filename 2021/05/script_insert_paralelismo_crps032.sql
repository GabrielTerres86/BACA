INSERT INTO tbgen_batch_param(idparametro, qtparalelo,qtreg_transacao,cdcooper,cdprograma) 
  VALUES((SELECT max(IDPARAMETRO) + 1 FROM tbgen_batch_param), 30,0,1,'CRPS032');
  
COMMIT;
