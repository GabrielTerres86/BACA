BEGIN 
  DELETE FROM tbspb_msg_recebida_fase WHERE nrseq_mensagem = 220528417013;
  DELETE FROM tbspb_msg_recebida WHERE nrseq_mensagem = 220528417013; 
  DELETE FROM tbspb_msg_enviada_fase WHERE nrseq_mensagem_fase = 220580168551;
  DELETE FROM recuperacao.tbrecup_err_transf_entre_if_env WHERE nr_controle_str = 'STR20220404033769292';
  COMMIT;
END;  