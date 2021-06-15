-- Created on 11/06/2021 - t0033182
  
begin
 
--Os insert na tabela menumobile foram feitos pelo vinicius, não será necessário eu criar.
 
--1009  Transações -> PIX
--1010  Transações -> PIX -> Cadastramento de chaves
--1011  Transações -> PIX -> Pagamento Pix
--1012  Transações -> PIX -> Recebimento Pix
--1013  Transações -> PIX -> Sobre o Pix
                        
--xxx4.10 > Realiza a Inclus�o de Mensagem 

  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM
    ,CDORIGEM_MENSAGEM
    ,DSTITULO_MENSAGEM
    ,DSTEXTO_MENSAGEM
    ,DSHTML_MENSAGEM
    ,CDICONE
    ,INEXIBIR_BANNER
    ,INEXIBE_BOTAO_ACAO_MOBILE  
    ,CDMENU_ACAO_MOBILE 
    ,INENVIAR_PUSH
    ,DSMENSAGEM_ACAO_MOBILE
    ,Dstexto_Botao_Acao_Mobile )
  VALUES
    (6528
    ,13
    ,'Confirmação de pagamento agendado Pix.'
    ,'Seu pagamento Pix agendado no valor de #valorpix foi realizado com sucesso.'
    ,'<br/>#nomeresumido,</br> Seu pagamento Pix que estava agendado para hoje foi realizado com sucesso.</br> Beneficiário: #beneficiario</br> Valor: #valorpix </br></br>Para consultar mais informações acesse a opção ver comprovante.</br></br>' 
    ,16
    ,0
    ,1
    ,1009 --gerenciamento de chaves
    ,1
    ,'Minhas chaves'
    ,'Minhas chaves');

  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM
    ,CDMOTIVO_MENSAGEM
    ,DSMOTIVO_MENSAGEM
    ,CDMENSAGEM
    ,DSVARIAVEIS_MENSAGEM
    ,INMENSAGEM_ATIVA
    ,INTIPO_REPETICAO)
  VALUES
    (13
    ,19
    ,'Confirmação de pagamento agendado Pix.'
    ,6528
    ,'<br/>#nomeresumido,</br> Seu pagamento Pix que estava agendado para hoje foi realizado com sucesso.</br> Beneficiário: #beneficiario</br> Valor: #valorpix </br></br>Para consultar mais informações acesse a opção ver comprovante.</br></br>' 
    ,1
    ,0);
                                            
--xxx4.12 > Realiza a Inclus�o de Mensagem 

  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM
    ,CDORIGEM_MENSAGEM
    ,DSTITULO_MENSAGEM
    ,DSTEXTO_MENSAGEM
    ,DSHTML_MENSAGEM
    ,CDICONE
    ,INEXIBIR_BANNER
    ,INEXIBE_BOTAO_ACAO_MOBILE  
    ,CDMENU_ACAO_MOBILE 
    ,INENVIAR_PUSH
    ,DSMENSAGEM_ACAO_MOBILE
    ,Dstexto_Botao_Acao_Mobile )
  VALUES
    (6529
    ,13
    ,'Pagamento agendado Pix não realizado.'
    ,'O pagamento de Pix no valor de #valorpix que estava agendado para hoje não foi realizado devido ao limite diário ou saldo insuficiente em sua conta corrente.'
    ,'</br>#nomeresumido,</br> Seu pagamento Pix que estava agendado para hoje não foi realizado devido ao limite diário ou saldo insuficiente em sua conta corrente.</br> Beneficiário: #beneficiario </br> Valor: #valorpix </br></br> Verifique seu limite diário Pix ou o saldo em conta corrente.</br></br>' 
    ,16
    ,0
    ,1
    ,1009 --gerenciamento de chaves
    ,1
    ,'Minhas chaves'
    ,'Minhas chaves');

  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM
    ,CDMOTIVO_MENSAGEM
    ,DSMOTIVO_MENSAGEM
    ,CDMENSAGEM
    ,DSVARIAVEIS_MENSAGEM
    ,INMENSAGEM_ATIVA
    ,INTIPO_REPETICAO)
  VALUES
    (13
    ,20
    ,'Pagamento agendado Pix não realizado.'
    ,6529
    ,'</br>#nomeresumido,</br> Seu pagamento Pix que estava agendado para hoje não foi realizado devido ao limite diário ou saldo insuficiente em sua conta corrente.</br> Beneficiário: #beneficiario </br> Valor: #valorpix </br></br> Verifique seu limite diário Pix ou o saldo em conta corrente.</br></br>' 
    ,1
    ,0);
	
--xxx4.13 > Realiza a Inclus�o de Mensagem 

  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM
    ,CDORIGEM_MENSAGEM
    ,DSTITULO_MENSAGEM
    ,DSTEXTO_MENSAGEM
    ,DSHTML_MENSAGEM
    ,CDICONE
    ,INEXIBIR_BANNER
    ,INEXIBE_BOTAO_ACAO_MOBILE  
    ,CDMENU_ACAO_MOBILE 
    ,INENVIAR_PUSH
    ,DSMENSAGEM_ACAO_MOBILE
    ,Dstexto_Botao_Acao_Mobile )
  VALUES
    (6530
    ,13
    ,'Pagamento agendado Pix não realizado.'
    ,'O pagamento no valor de #valorpix que estava agendado para hoje não foi realizado devido a uma falha no processamento. Por favor, refaça o pagamento ou agendamento.'
    ,'</br>#nomeresumido, </br> Seu pagamento Pix que estava agendado para hoje não foi realizado devido a uma falha no processamento. </br> Beneficiário: #beneficiario </br> Valor: #valorpix </br></br>  Por favor, refaça o pagamento ou agendamento.</br></br>'
    ,16
    ,0
    ,1
    ,1009 --gerenciamento de chaves
    ,1
    ,'Minhas chaves'
    ,'Minhas chaves');

  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM
    ,CDMOTIVO_MENSAGEM
    ,DSMOTIVO_MENSAGEM
    ,CDMENSAGEM
    ,DSVARIAVEIS_MENSAGEM
    ,INMENSAGEM_ATIVA
    ,INTIPO_REPETICAO)
  VALUES
    (13
    ,21
    ,'Pagamento agendado Pix não realizado.'
    ,6530
    ,'</br>#nomeresumido, </br> Seu pagamento Pix que estava agendado para hoje não foi realizado devido a uma falha no processamento. </br> Beneficiário: #beneficiario </br> Valor: #valorpix </br></br>  Por favor, refaça o pagamento ou agendamento.</br></br>'
    ,1
    ,0);
	
--xxx4.14 > Realiza a Inclus�o de Mensagem 

  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM
    ,CDORIGEM_MENSAGEM
    ,DSTITULO_MENSAGEM
    ,DSTEXTO_MENSAGEM
    ,DSHTML_MENSAGEM
    ,CDICONE
    ,INEXIBIR_BANNER
    ,INEXIBE_BOTAO_ACAO_MOBILE  
    ,CDMENU_ACAO_MOBILE 
    ,INENVIAR_PUSH
    ,DSMENSAGEM_ACAO_MOBILE
    ,Dstexto_Botao_Acao_Mobile )
  VALUES
    (6531
    ,13
    ,'Pagamento agendado Pix não realizado.'
    ,'O pagamento no valor de #valorpix que estava agendado para hoje foi reprovado por medidas de segurança. Em caso de dúvidas, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).'
    ,'</br>#nomeresumido, </br> Infelizmente, seu pagamento Pix que estava agendado para hoje foi reprovado. </br> Valor: #valorpix </br> Beneficiário: #beneficiario </br></br> Para mais informações, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).</br></br>'
    ,16
    ,0
    ,1
    ,1009 --gerenciamento de chaves
    ,1
    ,'Minhas chaves'
    ,'Minhas chaves');

  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM
    ,CDMOTIVO_MENSAGEM
    ,DSMOTIVO_MENSAGEM
    ,CDMENSAGEM
    ,DSVARIAVEIS_MENSAGEM
    ,INMENSAGEM_ATIVA
    ,INTIPO_REPETICAO)
  VALUES
    (13
    ,22
    ,'Pagamento agendado Pix não realizado.'
    ,6531
    ,'</br>#nomeresumido, </br> Infelizmente, seu pagamento Pix que estava agendado para hoje foi reprovado. </br> Valor: #valorpix </br> Beneficiário: #beneficiario </br></br> Para mais informações, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).</br></br>'
    ,1
    ,0);
	
--xxx4.15 > Realiza a Inclus�o de Mensagem 

  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM
    ,CDORIGEM_MENSAGEM
    ,DSTITULO_MENSAGEM
    ,DSTEXTO_MENSAGEM
    ,DSHTML_MENSAGEM
    ,CDICONE
    ,INEXIBIR_BANNER
    ,INEXIBE_BOTAO_ACAO_MOBILE  
    ,CDMENU_ACAO_MOBILE 
    ,INENVIAR_PUSH
    ,DSMENSAGEM_ACAO_MOBILE
    ,Dstexto_Botao_Acao_Mobile )
  VALUES
    (6532
    ,13
    ,'Agendamento Pix cancelado.'
    ,'Realizado o cancelamento de #quantidade transações agendadas Pix. Em caso de dúvidas, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).'
    ,'</br>#nomeresumido, </br> Realizado o cancelamento de #quantidade transações agendadas Pix, para verificar seus agendamentos clique em Ver agendamentos Pix. </br></br> Em caso de dúvidas, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).</br></br>' 
    ,16
    ,0
    ,1
    ,1009 --gerenciamento de chaves
    ,1
    ,'Minhas chaves'
    ,'Minhas chaves');

  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM
    ,CDMOTIVO_MENSAGEM
    ,DSMOTIVO_MENSAGEM
    ,CDMENSAGEM
    ,DSVARIAVEIS_MENSAGEM
    ,INMENSAGEM_ATIVA
    ,INTIPO_REPETICAO)
  VALUES
    (13
    ,23
    ,'Agendamento Pix cancelado.'
    ,6532
    ,'</br>#nomeresumido, </br> Realizado o cancelamento de #quantidade transações agendadas Pix, para verificar seus agendamentos clique em Ver agendamentos Pix. </br></br> Em caso de dúvidas, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).</br></br>' 
    ,1
    ,0);
	
               
COMMIT;

  
EXCEPTION
  WHEN OTHERS THEN 
       dbms_output.put_line('Erro: ' || SQLERRM);
       
end;