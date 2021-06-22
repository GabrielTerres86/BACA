declare 
  -- Local variables here
  V_CODIGO TBGEN_NOTIF_MSG_CADASTRO.cdmensagem%TYPE;
  
begin

SELECT MAX(CDMENSAGEM)
    INTO V_CODIGO
    FROM TBGEN_NOTIF_MSG_CADASTRO;

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
    ((V_CODIGO + 1)
    ,13
    ,'Confirmação de pagamento agendado Pix'
    ,'Seu pagamento Pix agendado no valor de #valorpix foi realizado com sucesso.'
    ,'<br/>#nomeresumido,</br> Seu pagamento Pix que estava agendado para hoje foi realizado com sucesso.</br> Beneficiário: #beneficiario</br> Valor: #valorpix </br></br>Para consultar mais informações acesse a opção ver comprovante.</br></br>' 
    ,16
    ,0
    ,1
    ,400 --Comprovantes
    ,1
    ,'Ver comprovante'
    ,'Ver comprovante');

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
    ,'PIX - Confirmação de pagamento agendado Pix'
  ,(V_CODIGO + 1)
    ,'<br/>#nomeresumido,</br> Seu pagamento Pix que estava agendado para hoje foi realizado com sucesso.</br> Beneficiário: #beneficiario</br> Valor: #valorpix </br></br>Para consultar mais informações acesse a opção ver comprovante.</br></br>' 
    ,1
    ,0);
         

SELECT MAX(CDMENSAGEM)
    INTO V_CODIGO
    FROM TBGEN_NOTIF_MSG_CADASTRO;
     
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
    ((V_CODIGO + 1)
    ,13
    ,'Pagamento agendado Pix não realizado'
    ,'O pagamento de Pix no valor de #valorpix que estava agendado para hoje não foi realizado devido ao limite/saldo insuficiente em sua conta.'
    ,'</br>#nomeresumido,</br> Seu pagamento Pix que estava agendado para hoje não foi realizado devido ao limite diário ou saldo insuficiente em sua conta corrente.</br> Beneficiário: #beneficiario </br> Valor: #valorpix </br></br> Verifique seu limite diário Pix ou o saldo em conta corrente.</br></br>' 
    ,16
    ,0
    ,1
    ,1021 --limites pix
    ,1
    ,'Ver limite Pix'
    ,'Ver limite Pix');

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
    ,'PIX - Pagamento agendado Pix não realizado'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido,</br> Seu pagamento Pix que estava agendado para hoje não foi realizado devido ao limite diário ou saldo insuficiente em sua conta corrente.</br> Beneficiário: #beneficiario </br> Valor: #valorpix </br></br> Verifique seu limite diário Pix ou o saldo em conta corrente.</br></br>' 
    ,1
    ,0);
  
  SELECT MAX(CDMENSAGEM)
    INTO V_CODIGO
    FROM TBGEN_NOTIF_MSG_CADASTRO;
  
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
    ((V_CODIGO + 1)
    ,13
    ,'Pagamento agendado Pix não realizado'
    ,'O pagamento no valor de #valorpix que estava agendado para hoje não foi realizado devido a uma falha no processamento.'
    ,'</br>#nomeresumido, </br> Seu pagamento Pix que estava agendado para hoje não foi realizado devido a uma falha no processamento. </br> Beneficiário: #beneficiario </br> Valor: #valorpix </br></br>  Por favor, refaça o pagamento ou agendamento.</br></br>'
    ,16
    ,0
    ,1
    ,1011 --Pagar com pix
    ,1
    ,'Fazer um novo Pix'
    ,'Fazer um novo Pix');

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
    ,'PIX - Pagamento agendado Pix não realizado'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido, </br> Seu pagamento Pix que estava agendado para hoje não foi realizado devido a uma falha no processamento. </br> Beneficiário: #beneficiario </br> Valor: #valorpix </br></br>  Por favor, refaça o pagamento ou agendamento.</br></br>'
    ,1
    ,0);
  
  SELECT MAX(CDMENSAGEM)
    INTO V_CODIGO
    FROM TBGEN_NOTIF_MSG_CADASTRO;
  
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
    ((V_CODIGO + 1)
    ,13
    ,'Pagamento agendado Pix não realizado'
    ,'O pagamento no valor de #valorpix que estava agendado para hoje foi reprovado por medidas de segurança.'
    ,'</br>#nomeresumido, </br> Infelizmente, seu pagamento Pix que estava agendado para hoje foi reprovado. </br> Valor: #valorpix </br> Beneficiário: #beneficiario </br></br> Para mais informações, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).</br></br>'
    ,16
    ,0
    ,1
    ,1024 --agendamentos Pix
    ,1
    ,'Ver agendamentos Pix'
    ,'Ver agendamentos Pix');

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
    ,'PIX - Pagamento agendado Pix não realizado'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido, </br> Infelizmente, seu pagamento Pix que estava agendado para hoje foi reprovado. </br> Valor: #valorpix </br> Beneficiário: #beneficiario </br></br> Para mais informações, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).</br></br>'
    ,1
    ,0);
  
  SELECT MAX(CDMENSAGEM)
    INTO V_CODIGO
    FROM TBGEN_NOTIF_MSG_CADASTRO;
  
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
    ((V_CODIGO + 1)
    ,13
    ,'Agendamento Pix cancelado'
    ,'Realizado o cancelamento de #quantidade transações agendadas Pix.'
    ,'</br>#nomeresumido, </br> Realizado o cancelamento de #quantidade transações agendadas Pix, para verificar seus agendamentos clique em Ver agendamentos Pix. </br></br> Em caso de dúvidas, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).</br></br>' 
    ,16
    ,0
    ,1
    ,1024 --agendamentos Pix
    ,1
    ,'Ver agendamentos Pix'
    ,'Ver agendamentos Pix');

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
    ,'PIX - Agendamento Pix cancelado'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido, </br> Realizado o cancelamento de #quantidade transações agendadas Pix, para verificar seus agendamentos clique em Ver agendamentos Pix. </br></br> Em caso de dúvidas, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).</br></br>' 
    ,1
    ,0);
  
               
COMMIT;

  
EXCEPTION
  WHEN OTHERS THEN 
       dbms_output.put_line('Erro: ' || SQLERRM);
       
end;