UPDATE cecred.tbgen_notif_msg_cadastro tnmc
SET tnmc.dshtml_mensagem = '#nomeresumido</br></br>Sua chave Pix #chaveenderecamento recebeu uma solicita��o de reivindica��o de posse por outro usu�rio.</br></br>Para aceitar ou cancelar a solicita��o voc� deve acessar o menu Minhas Chaves dentro da op��o Pix no seu App Ailos.</br></br><b>Se n�o houver a confirma��o de posse, a chave ser� cancelada de sua conta na Cooperativa.</b></br></br>Em caso de d�vidas, entre em contato com o SAC.</br></br>',
tnmc.dstexto_botao_acao_mobile = 'Pix',
tnmc.dsmensagem_acao_mobile = 'Pix'
WHERE tnmc.cdmensagem = 5460
AND tnmc.cdorigem_mensagem = 13;
