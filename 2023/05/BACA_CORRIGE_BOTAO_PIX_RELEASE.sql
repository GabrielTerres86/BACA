UPDATE cecred.tbgen_notif_msg_cadastro tnmc
SET tnmc.dshtml_mensagem = '#nomeresumido</br></br>Sua chave Pix #chaveenderecamento recebeu uma solicitação de reivindicação de posse por outro usuário.</br></br>Para aceitar ou cancelar a solicitação você deve acessar o menu Minhas Chaves dentro da opção Pix no seu App Ailos.</br></br><b>Se não houver a confirmação de posse, a chave será cancelada de sua conta na Cooperativa.</b></br></br>Em caso de dúvidas, entre em contato com o SAC.</br></br>',
tnmc.dstexto_botao_acao_mobile = 'Pix',
tnmc.dsmensagem_acao_mobile = 'Pix'
WHERE tnmc.cdmensagem = 5460
AND tnmc.cdorigem_mensagem = 13;
