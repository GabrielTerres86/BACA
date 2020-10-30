declare 
  -- Local variables here
  V_CODIGO TBGEN_NOTIF_MSG_CADASTRO.cdmensagem%TYPE;
  
begin
  -- Test statements here  
  /* Os passos 1 e 2 já foram criados com a liberação da 1 onda (Outubro), cadastramento de chaves.
  
--1º -> Inserir novo icone
  INSERT INTO tbgen_notif_icone
    (CDICONE
    ,NMICONE
    ,NMIMAGEM_LIDA
    ,NMIMAGEM_NAOLIDA
    ,NMIMAGEM_IBANK)
  VALUES
    (16
    ,'Pix'
    ,'pix_72_w.png'  
    ,'pix_72.png'   
    ,'mdi-coin');   

--2º > Realiza a inclusão da origem:  Pix - Pagamento Instantâneo   
  INSERT INTO TBGEN_NOTIF_MSG_ORIGEM
    (CDORIGEM_MENSAGEM
    ,DSORIGEM_MENSAGEM
    ,CDTIPO_MENSAGEM
    ,HRINICIO_PUSH
    ,HRFIM_PUSH
    ,HRTEMPO_VALIDADE_PUSH)
  VALUES
    (13
    ,'Pix - Pagamento Instantâneo'
    ,1 --Serviços
    ,0 
    ,86399
    ,86400); 
    
    
--3º > Criar menu no mobile
--Os insert na tabela menumobile foram feitos pelo vinicius, não será necessário eu criar.
 
--1009  Transações -> PIX
--1010  Transações -> PIX -> Cadastramento de chaves
--1011  Transações -> PIX -> Pagamento Pix
--1012  Transações -> PIX -> Recebimento Pix
--1013  Transações -> PIX -> Sobre o Pix
*/



--4º 
--xxx4.1 > Realiza a Inclus�o de Mensagem  
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
    ,DSTEXTO_BOTAO_ACAO_MOBILE 
    ,DSMENSAGEM_ACAO_MOBILE)
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Portabilidade de chave Pix'
    ,'Você recebeu uma solicitação de portabilidade de instituição financeira.'
    ,'Cooperado,</br></br>Uma solicitação de portabilidade da sua chave de endereçamento Pix #chaveenderecamento para outra instituição financeira foi aberta.</br></br>' ||
     'Para aceitar ou cancelar a solicitação você deve acessar o menu Gerenciamento de Chaves dentro da opção Pix no seu App Ailos.' ||
     '</br></br><b>Se não houver resposta em 7 dias, o processo de portabilidade será cancelado.</b></br></br>Em caso de dúvidas, entre em contato com o SAC da sua Cooperativa.</br></br>'
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
    ,1
    ,'PIX - Recebimento de pedido de portabilidade'
    ,(V_CODIGO + 1)
    ,'</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)'
    ,1
    ,0);

--xxx4.2 > Realiza a Inclus�o de Mensagem  
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
    ,DSTEXTO_BOTAO_ACAO_MOBILE
    ,DSMENSAGEM_ACAO_MOBILE )
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Reivindicação de chave Pix'
    ,'Sua chave foi reivindicada por outro usuário. Saiba mais!'
    ,'#nomeresumido</br></br>Sua chave de endereçamento Pix #chaveenderecamento recebeu uma solicitação de reivindicação de posse por outro usuário.</br></br>' ||
     'Para aceitar ou cancelar a solicitação você deve acessar o menu Gerenciamento de Chaves dentro da opção Pix no seu App Ailos.</br></br>' ||
     '<b>Se não houver resposta em 7 dias, a chave de endereçamento será cancelada de sua conta na Cooperativa.</b></br></br>' || 
     'Em caso de dúvidas, entre em contato com o SAC da sua Cooperativa.</br></br>'
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
    ,2 
    ,'PIX - Recebimento de pedido de reivindicação'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido - Contas PF: Primeiro nome do titular, Contas PJ: nome fantasia (Ex.: JOÃO, ou GOOGLE)' || 
     '</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)'
    ,1
    ,0);
    
--xxxxx4.3 > Realiza a Inclus�o de Mensagem 
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
    ,INENVIAR_PUSH)
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Exclusão de chave Pix'
    ,'Sua chave foi excluída por inatividade de mais de 12 meses.'
    ,'#nomeresumido,</br></br>Sua chave de endereçamento do Pix #chaveenderecamento foi excluída por falta de uso ao longo de 12 meses.' || 
     'Caso ainda deseje utilizar essa chave, deve fazer um novo cadastro acessando Pix > Gerenciamento de Chaves > Cadastrar nova Chave, no App Ailos.</br></br>' 
    ,16
    ,0
    ,0    
    ,1);

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
    ,3 
    ,'PIX - Exclusão da chave por inatividade'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido - Contas PF: Primeiro nome do titular, Contas PJ: nome fantasia (Ex.: JOÃO, ou GOOGLE)' || 
     '</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)'
    ,1
    ,0);
    
--xxxx4.4 > Realiza a Inclus�o de Mensagem 
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
    ,INENVIAR_PUSH)
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Cancelamento da portabilidade'
    ,'A solicitação de portabilidade da sua chave Pix foi cancelada.'
    ,'O seu processo de portabilidade de chave Pix #chaveenderecamento foi cancelado pela instituição em que a chave está atualmente cadastrada.</br></br>' || 
     'Entre em contato com a instituição para verificar a situação.</br></br>' 
    ,16
    ,0
    ,0    
    ,1);

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
    ,4
    ,'PIX - Cancelamento do pedido de portabilidade'
    ,(V_CODIGO + 1)
    ,'</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)'
    ,1
    ,0);
    
--xxx4.5 > Realiza a Inclus�o de Mensagem 
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
    ,'Confirmação de portabilidade'
    ,'A chave Pix solicitada foi cadastrada na Cooperativa'
    ,'#nomeresumido,</br></br>O seu processo de portabilidade da chave #chaveenderecamento foi concluído com sucesso.' || 
     'Você pode verificar o cadastramento acessando a opção Pix > Gerenciamento de Chaves, no App Ailos.</br></br>' 
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
    ,5
    ,'PIX - Confirmação do pedido de portabilidade'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido - Contas PF: Primeiro nome do titular, Contas PJ: nome fantasia (Ex.: JOÃO, ou GOOGLE)' || 
     '</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)'
    ,1
    ,0);
    
--xxx4.6 > Realiza a Inclus�o de Mensagem 
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
    ,INENVIAR_PUSH)
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Cancelamento de reivindicação'
    ,'A solicitação de reivindicação da sua chave Pix foi cancelada.'
    ,'O seu processo de reivindicação de chave Pix #chaveenderecamento foi cancelado pela instituição em que a chave está atualmente cadastrada.</br></br>' ||
     'Entre em contato com a instituição para verificar a situação.</br></br>' 
    ,16
    ,0
    ,0    
    ,1);

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
    ,6
    ,'PIX - Cancelamento do pedido de reivindicação'
    ,(V_CODIGO + 1)
    ,'</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)'
    ,1
    ,0);
    
    
--xxx4.7 > Realiza a Inclus�o de Mensagem 
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
    ,'Confirmação de reivindicação'
    ,'A solicitação de posse da chave Pix foi aceita. Finalize o cadastro!'
    ,'#nomeresumido,</br></br>O seu processo de reivindicação da chave #chaveenderecamento foi aprovado com sucesso.</br></br>' || 
     '<b>Agora você precisa finalizar o cadastro da chave em sua conta, acessando o Gerenciamento de Chave no App Ailos e validando novamente a posse da chave de endereçamento Pix.</b></br></br>' ||
     'Em caso de dúvidas, entre em contato com o SAC.</br></br>' 
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
    ,7
    ,'PIX - Confirmação do pedido de reivindicação'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido - Contas PF: Primeiro nome do titular, Contas PJ: nome fantasia (Ex.: JOÃO, ou GOOGLE)' || 
     '</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)'
    ,1
    ,0);
    
--xxx4.8 > Realiza a Inclus�o de Mensagem 
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
    ,'Faltam 24h para sua chave do Pix ser cancelada'
    ,'A resolução do processo de reivindicação está pendente. Saiba mais!'
    ,'Não deixe a sua chave de endereçamento #chaveenderecamento ser cancelada.</br></br>' ||  
     '<b>Faça a validação que está pendente, acessando o Gerenciamento de Chave do Pix no seu App Ailos para concluir o processo.</b></br></br>' 
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
    ,8
    ,'PIX - Alerta para pedido de reivindicação - 24h para encerramento do prazo'
    ,(V_CODIGO + 1)
    ,'</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)'
    ,1
    ,0);
    
--xxx4.9 > Realiza a Inclus�o de Mensagem 
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
    ,'A chave Pix foi cancelada'
    ,'Sua chave de endereçamento Pix foi cancelada por falta de resposta. Saiba mais!'
    ,'#nomeresumido,</br></br>Não recebemos retorno do processo de reivindicação da chave Pix #chaveenderecamento enviado a você em #datadareivindicacaorecebida.' || 
     'Conforme informado, após sete dias sem retorno sua chave é automaticamente cancelada.</br></br>' || 
     'Caso não tenha identificado a solicitação de reivindicação e ainda possua a chave de endereçamento reivindicada, acesse o Gerenciamento de Chave do Pix no seu ' || 
     'App Ailos e faça uma nova validação de posse para evitar a transferência da chave para outra instituição. Se não possui mais esta chave, conclua o processo de ' || 
     'solicitação autorizando a reivindicação.</br></br>' ||
     'Em caso de dúvidas, entre em contato com o SAC.</br></br>'
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
    ,9
    ,'PIX - Exclusão automática de reivindicação'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido - Contas PF: Primeiro nome do titular, Contas PJ: nome fantasia (Ex.: JOÃO, ou GOOGLE)' || 
     '</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)' ||
     '</br>#datadareivindicacaorecebida - Data do envio (Ex.: 25/08/2099)'
    ,1
    ,0);
             
--xxx4.12 > Realiza a Inclus�o de Mensagem 
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
    ,DSTEXTO_BOTAO_ACAO_MOBILE)
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Conclusão de reivindicação'
    ,'A chave Pix solicitada foi cadastrada na Cooperativa'
    ,'#nomeresumido>,</br></br>O seu processo de reivindicação da chave #chaveenderecamento foi concluído com sucesso. A chave está ativa na Cooperativa.</br></br>' || 
     'Você pode verificar o cadastramento acessando a opção Pix > Gerenciamento de Chaves, no App Ailos.</br></br>'
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
    ,12
    ,'PIX - Confirmação do pedido de reivindicação'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido - Contas PF: Primeiro nome do titular, Contas PJ: nome fantasia (Ex.: JOÃO, ou GOOGLE)' || 
     '</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)' 
    ,1
    ,0);
           
    
--4º 
--xxx4.1 > Realiza a Inclus�o de Mensagem  
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
    ,DSTEXTO_BOTAO_ACAO_MOBILE)
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Você recebeu um Pix'
    ,'Você recebeu um crédito Pix de #valorpix. O valor já está em sua conta.'
    ,'Cooperado,</br></br>Você recebeu um crédito Pix.</br></br>' || 
     'Pagador: #nomepagador </br>' || 
     'Valor: #valorpix </br>'   || 
     'Instituição: #psppagador </br>' || 
     'Identificação: #identificacao </br>' || 
     'Descrição: #descricao </br></br>' || 
     'Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente</br></br>'     
    ,16
    ,0
    ,1
    ,402 --comprovantes recebidos
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
    ,13
    ,'PIX - Recebimento de crédito Pix'
    ,(V_CODIGO + 1)
    ,'</br>#valorpix - Valor do Pix (Ex.: 45,00)' || 
     '</br>#nomepagador - Nome do pagador' ||
     '</br>#psppagador - PSP do pagador ' || 
     '</br>#identificacao - Identificação' ||
     '</br>#descricao - Descrição' 
    ,1
    ,0);
    
--xxx4.2 > Realiza a Inclus�o de Mensagem  
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
    ,DSTEXTO_BOTAO_ACAO_MOBILE)
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Devolução de Pix recebida'
    ,'Você recebeu a devolução de um Pix que realizou.'
    ,'O Pix que você realizou em #datatransacao no valor de #valorpix para #chave/#beneficiario foi devolvido #parcialtotalmente.</br></br>' || 
     '<b>O valor está novamente disponível em sua conta corrente.</b></br></br>' ||
     'Acesse o comprovante para mais detalhes da devolução.'
    ,16
    ,0
    ,1
    ,402 --comprovantes recebidos
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
    ,14
    ,'PIX - Recebimento de devolução Pix'
    ,(V_CODIGO + 1)
    ,'</br>#datatransacao - Data da transação (Ex.: 25/08/2099)' || 
     '</br>#valorpix - Valor do Pix (Ex.: 45,00)'  ||
     '</br>#chave - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)' ||
     '</br>#beneficiario - Nome do beneficiário' ||
     '</br>#parcialtotalmente - Tipo da devolução (Parcial/Totalmente)'
    ,1
    ,0);
    
--xxx4.3 > Realiza a Inclus�o de Mensagem  
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
    ,DSTEXTO_BOTAO_ACAO_MOBILE)
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Transação concluída'
    ,'A análise foi finalizada e o Pix efetivado.'
    ,'Concluímos o processo de análise da sua operação realizada via Pix e confirmamos o sucesso da transação.</br></br>' ||
     'Valor: #valorpix </br>' || 
     'Beneficiário: #beneficiario </br>' || 
     'Instituição: #instituicao </br></br>' || 
     'Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente</br></br>' 
    ,16
    ,0
    ,1
    ,401 --comprovante realizados
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
    ,15
    ,'PIX - Pagamento Pix: retorno OFSAA (sucesso)'
    ,(V_CODIGO + 1)
    ,'</br>#valorpix - Valor do Pix (Ex.: 45,00)' ||
     '</br>#instituicao - PSP do beneficiário'  ||
     '</br>#beneficiario - Nome do beneficiário'
    ,1
    ,0);
   
--xxx4.4 > Realiza a Inclus�o de Mensagem  
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
    ,INENVIAR_PUSH)
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Pix - Transação não concluída'
    ,'O valor foi estornado para a sua conta. Saiba Mais.'
    ,'Concluímos o processo de análise da sua operação realizada via Pix.</br></br>' ||
     'A sua transação foi cancelada por medidas se segurança.</br></br>' ||
     'Valor: #valorpix </br>' || 
     'Beneficiário: #beneficiario </br>' || 
     'Instituição: #instituicao </br></br>' || 
     '<b>O valor foi estornado e está disponível em sua conta corrente.</b></br></br>' || 
     'Em caso de dúvidas, entre em contato com a Cooperativa.</br></br>'
    ,16
    ,0
    ,0
    ,1);

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
    ,16
    ,'PIX - Pagamento Pix: Retorno OFSAA (reprovada + estorno)'
    ,(V_CODIGO + 1)
    ,'</br>#valorpix - Valor do Pix (Ex.: 45,00)'  ||
     '</br>#instituicao - PSP do beneficiário'  ||
     '</br>#beneficiario - Nome do beneficiário'
    ,1
    ,0);
     
--xxx4.5 > Realiza a Inclus�o de Mensagem  
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
    ,DSTEXTO_BOTAO_ACAO_MOBILE)
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Transação concluída'
    ,'O Pix que estava em análise foi efetivado'
    ,'Concluímos o processo de análise da sua operação realizada via Pix e confirmamos o sucesso da transação.</br></br>' ||
     'Valor: #valorpix </br>' || 
     'Beneficiário: #beneficiario </br>' || 
     'Instituição: #instituicao </br></br>' || 
     'Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente.</br></br>'
    ,16
    ,0
    ,1
    ,401 --Comprovantes realizados
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
    ,17
    ,'PIX - Pagamento Pix: demora no recebimento da resposta JD e SPI (sucesso)'
    ,(V_CODIGO + 1)
    ,'</br>#valorpix - Valor do Pix (Ex.: 45,00)' ||
     '</br>#instituicao - PSP do beneficiário'  ||
     '</br>#beneficiario - Nome do beneficiário'
    ,1
    ,0);
    
--xxx4.6 > Realiza a Inclus�o de Mensagem  
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
    ,DSTEXTO_BOTAO_ACAO_MOBILE)
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Pix - Transação cancelada'
    ,'O valor foi estornado para sua conta. Saiba mais.'
    ,'Concluímos o processo de análise da sua operação realizada via Pix.</br></br>' ||
     'A sua transação foi cancelada por medidas de segurança.</br></br>' ||
     'Valor: #valorpix </br>' || 
     'Beneficiário: #beneficiario </br>' || 
     'Instituição: #instituicao </br></br>' || 
     'Tente novamente mais tarde ou entre em contato com a sua Cooperativa.'
    ,16
    ,0
    ,1
    ,1011 --pagamento pix
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
    ,18
    ,'PIX - Pagamento Pix: demora no recebimento da resposta JD e SPI (erro)'
    ,(V_CODIGO + 1)
    ,'</br>#valorpix - Valor do Pix (Ex.: 45,00)' ||
     '</br>#instituicao - PSP do beneficiário' ||
     '</br>#beneficiario - Nome do beneficiário'
    ,1
    ,0);
    
    
  COMMIT;

  
EXCEPTION
  WHEN OTHERS THEN 
       dbms_output.put_line('Erro: ' || SQLERRM);
       
end;