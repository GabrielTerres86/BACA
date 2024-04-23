BEGIN 
  UPDATE server.tb_transaction_input 
     SET logical_evaluation = 'https://integra.ailos.coop.br/eapi-ailosmais-teller'
   WHERE id_if = 0
     AND id_channel = 0 
     AND id_transaction = 0  
	 AND seq_flow = 0 
	 AND env_name = 'BASE_SERVICE_URL' 
	 AND version = '1.0.0';
  COMMIT;
END;