BEGIN 
 DELETE FROM tbspb_msg_recebida_fase WHERE nrseq_mensagem = '220428103877';
 DELETE FROM tbspb_msg_recebida WHERE nrcontrole_if_env = '2220404010175565482A'; 
 DELETE FROM tbspb_msg_enviada_fase WHERE nrseq_mensagem_fase = 220479528013;
  COMMIT;
END;  
  
  

  
