BEGIN
  
  UPDATE cecred.tbblqj_ordem_online
     SET instatus = 2, 
         dhresposta = SYSDATE
   WHERE idordem = 5298247;
           
  UPDATE INVESTIMENTO.TBINVEST_RESGATE_JUDICIAL_LCI lci 
     SET lci.insituacao = 4
   WHERE lci.cdcooper = 1
     and lci.nrdconta = 10688536
     and lci.idresgatejudicial = '0FA02A3D461E0490E0630A29357C9B73';
  
  COMMIT;


END;