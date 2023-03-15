BEGIN

  UPDATE cecred.tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Não deixe a sua chave #chaveenderecamento ser cancelada.</br></br><b>Faça a validação que está pendente, acessando o Minhas Chaves no Menu Pix no seu App Ailos para concluir o processo.</b></br></br>'
  WHERE tnmc.cdmensagem = 5466
  AND tnmc.cdorigem_mensagem = 13;

  UPDATE cecred.tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = '#nomeresumido</br></br>Sua chave Pix #chaveenderecamento recebeu uma solicitação de reivindicação de posse por outro usuário.</br></br>Para aceitar ou cancelar a solicitação você deve acessar o menu Minhas Chaves dentro da opção Pix no seu App Ailos.</br></br><b>Se não houver a confirmação de posse, a chave será cancelada de sua conta na Cooperativa.</b></br></br>Em caso de dúvidas, entre em contato com o SAC ou sua Cooperativa.</br></br>'
  WHERE tnmc.cdmensagem = 5460
  AND tnmc.cdorigem_mensagem = 13;
  
  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      
END;
