BEGIN 
  UPDATE tbgen_trans_pend 
     SET idsituacao_transacao = 3
   WHERE cdcooper = 7 
     AND nrdconta = 176036 
     AND idsituacao_transacao = 5;

  COMMIT; 
  
END;

