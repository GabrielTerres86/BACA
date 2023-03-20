DECLARE

V_CODIGO_MENSAGEM TBGEN_NOTIF_MSG_CADASTRO.cdmensagem%TYPE;
V_CODIGO_MOTIVO TBGEN_NOTIF_AUTOMATICA_PRM.cdmotivo_mensagem%TYPE;

BEGIN
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br /><br />Voc� recebeu um cr�dito Pix de #valor_pix, por�m esta transa��o est� em an�lise. Este valor ficar� com bloqueio cautelar por no m�ximo 72 horas. Ap�s a conclus�o da an�lise, dentro do prazo citado, voc� receber� uma nova notifica��o com o resultado da avalia��o.<br /><br />Valor bloqueado: #valor_bloqueado_pix<br />Pagador: #nome_pagador<br />Institui��o: #instituicao_pagador<br />Identifica��o: #identificao_transacao<br />Data hora transa��o: #data_hora_transacao<br />Descri��o:<br /><br />Este � uma procedimento obrigat�rio de acordo com o Regulamento Pix, emitido pelo Banco Central do Brasil para garantir mais seguran�a �s suas transa��es.'
  WHERE tnmc.cdmensagem = 10524
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br />#valor_pix - Valor do Pix (Ex.: 2.000,00)<br />#nome_pagador - Nome do Pagador - ("Jo�o da Silva")<br />#instituicao_pagador - Institui��o do Pagador ("Viacredi")<br />#identificao_transacao - Identifica��o da Transa��o (E18236120202011062016s0644601CBP)<br />#data_hora_transacao - Data e hora da transa��o - ("26/01/2023 �s 17:54:32")<br />#valor_bloqueado_pix - Valor do Pix bloqueado (Ex.: 2.000,00)'
  WHERE tnap.cdmensagem = 10524
  AND tnap.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br /><br />O cr�dito Pix de #valor_pix, que voc� recebeu em #data_hora_transacao foi analisado e liberado. O valor j� est� dispon�vel em sua conta.<br /><br />Valor desbloqueado: #valor_desbloqueado_pix<br />Pagador: #nome_pagador<br />Institui��o: #instituicao_pagador<br />Identifica��o: #identificao_transacao<br />Data hora bloqueio: #data_hora_bloqueio<br />Descri��o:<br /><br />Acesse o comprovante no App Ailos ou confira o extrato da sua conta.'
  WHERE tnmc.cdmensagem = 10525
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br />#data_transacao - Data da Transa��o (Ex.: 17/02/2022)<br />#data_hora_transacao - Data da Transa��o (Ex.: 17/02/2022 �s 11:06:32)<br />#valor_pix - Valor do Pix (Ex.: 2.000,00)<br />#nome_pagador - Nome do Pagador - ("Jo�o da Silva")<br />#instituicao_pagador - Institui��o do Pagador ("Viacredi")<br />#identificao_transacao - Identifica��o da Transa��o (E18236120202011062016s0644601CBP)<br />#valor_desbloqueado_pix - Valor desbloqueado (Ex.: 2.000,00)<br />#data_hora_bloqueio - Data e hora do bloqueio (Ex.: 18/02/2022 �s 13:12:54)'
  WHERE tnap.cdmensagem = 10525
  AND tnap.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br /><br />O cr�dito Pix de #valor_pix, que voc� recebeu em #data_hora_transacao foi analisado e devolvido para o pagador.<br /><br />Valor desbloqueado: #valor_desbloqueado_pix<br />Pagador: #nome_pagador<br />Institui��o: #instituicao_pagador<br />Identifica��o: #identificao_transacao<br />Data hora bloqueio: #data_hora_bloqueio<br />Descri��o:<br /><br />Em caso de d�vidas contatar o remetente do recurso.'
  WHERE tnmc.cdmensagem = 10526
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br />#data_transacao - Data da Transa��o (Ex.: 17/02/2022)<br />#data_hora_transacao - Data da Transa��o (Ex.: 17/02/2022 �s 11:06:32)<br />#valor_pix - Valor do Pix (Ex.: 2.000,00)<br />#nome_pagador - Nome do Pagador - ("Jo�o da Silva")<br />#instituicao_pagador - Institui��o do Pagador ("Viacredi")<br />#identificao_transacao - Identifica��o da Transa��o (E18236120202011062016s0644601CBP)<br />#valor_desbloqueado_pix - Valor desbloqueado (Ex.: 2.000,00)<br />#data_hora_bloqueio - Data e hora do bloqueio (Ex.: 18/02/2022 �s 13:12:54)'
  WHERE tnap.cdmensagem = 10526
  AND tnap.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br><br> O Pix de #valorpix para #nomerecebedor que voc� contestou foi analisado, mas a opera��o n�o pode ser devolvida pela conta recebedora. <br><br>Infelizmente n�o ser� poss�vel creditar o valor � sua conta.'
  WHERE tnmc.cdmensagem = 7397
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br/>#valorpix - Valor do Pix (Ex: 2.000,00)<br>#nomerecebedor - Nome do Recebedor - ("Fabio Silva")'
  WHERE tnap.cdmensagem = 7397
  AND tnap.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br><br> N�o obtivemos resposta da institui��o financeira do recebedor sobre a solicita��o de devolu��o do Pix de #valorpix para #nomeRecebedor que voc� contestou. <br>Para maiores informa��es voc� pode acessar o Servi�o de Atendimento Pix, na op��o Atendimento do Banco Central do Brasil.'
  WHERE tnmc.cdmensagem = 7396
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br/>#valorpix - Valor do Pix (Ex: 2.000,00)'
  WHERE tnap.cdmensagem = 7396
  AND tnap.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br><br>O Pix que voc� contestou foi analisado e a institui��o financeira do recebedor aprovou a devolu��o de #valordevolucaorecebida. <br><br>Creditamos o valor na sua conta e ele j� est� dispon�vel.'
  WHERE tnmc.cdmensagem = 7395
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br/>#valordevolucaorecebida - Valor de Devolucao do Pix (Ex: 2.000,00)'
  WHERE tnap.cdmensagem = 7395
  AND tnap.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado, <br><br>O Pix que voc� contestou no valor de #valorpix para #nomerecebedor est� sendo analisado pela �rea respons�vel. Caso o retorno da contesta��o seja positivo, faremos a solicita��o de devolu��o mediante aprova��o da institui��o financeira do recebedor. Assim que a an�lise for conclu�da, voc� receber� um retorno. Esta � uma medida de seguran�a do Pix. <br><br> Agradecemos a sua compreens�o.'
  WHERE tnmc.cdmensagem = 7394
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br/>#valorpix - Valor do Pix (Ex: 2.000,00) <br/> #nomerecebedor - Nome do Pagador (Ex: "Frank George")'
  WHERE tnap.cdmensagem = 7394
  AND tnap.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br><br> Em #data_hora_transacao voc� recebeu um Pix no valor de #valorpix de #nomepagador e ele foi contestado. O caso foi analisado e identificamos que a contesta��o � improcedente. Portanto, o valor de #valor_bloqueado_pix bloqueado em #data_hora_bloqueio foi liberado em sua conta. Esta � uma medida de seguran�a do Pix. <br><br>Agradecemos a sua compreens�o.',
  tnmc.inexibe_botao_acao_mobile = 1,
  tnmc.dstexto_botao_acao_mobile = 'Ver Comprovante',
  tnmc.cdmenu_acao_mobile = 400
  WHERE tnmc.cdmensagem = 7393
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br/>#valorpix - Valor do Pix (Ex: 2.000,00) <br/> #nomepagador - Nome do Pagador (Ex: "Fabio da Silva") <br />#data_hora_transacao - Data e hora da transa��o - ("26/01/2023 �s 17:54:32") <br/>#valor_bloqueado_pix - Valor bloqueado (Ex: 2.000,00) <br />#data_hora_bloqueio - Data e hora do bloqueio - ("28/01/2023 �s 15:34:52")'
  WHERE tnap.cdmensagem = 7393
  AND tnap.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br><br> Em #data_hora_transacao voc� recebeu um Pix no valor de #valorpix de #nomepagador e ele foi contestado. O caso foi analisado e identificamos que a contesta��o � procedente. Portanto, o valor de #valor_bloqueado_pix bloqueado em #data_hora_bloqueio foi devolvido para o pagador. Esta � uma medida de seguran�a do Pix. <br><br>Agradecemos a sua compreens�o.',
  tnmc.inexibe_botao_acao_mobile = 1,
  tnmc.dstexto_botao_acao_mobile = 'Ver Comprovante',
  tnmc.cdmenu_acao_mobile = 400
  WHERE tnmc.cdmensagem = 7392
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br/>#valorpix - Valor do Pix (Ex: 2.000,00) <br/> #nomepagador - Nome do Pagador (Ex: "Fabio da Silva") <br />#data_hora_transacao - Data e hora da transa��o - ("26/01/2023 �s 17:54:32") <br/>#valor_bloqueado_pix - Valor bloqueado (Ex: 2.000,00) <br />#data_hora_bloqueio - Data e hora do bloqueio - ("28/01/2023 �s 15:34:52")'
  WHERE tnap.cdmensagem = 7392
  AND tnap.cdorigem_mensagem = 13;

  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br><br>Em #data_hora_transacao voc� recebeu um Pix no valor de #valorpix, de #nomepagador, mas ele foi contestado. <br> Isto significa que esta opera��o est� sendo analisada e em at� 11 dias voc� receber� um retorno. Por enquanto, o valor de #valor_bloqueado foi bloqueado, ou seja, ele est� indispon�vel na sua conta. <br> Se a an�lise indicar que est� tudo certo, o valor ser� liberado, caso contr�rio, o valor ser� devolvido para a pessoa que lhe enviou. <br><br> Esta � uma medida de seguran�a do Pix. Agradecemos a sua compreens�o.'
  WHERE tnmc.cdmensagem = 7391
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br/>#valorpix  - Valor do Pix (Ex: 2.000,00) <br/> #nomepagador - Nome do Pagador (Ex: "Fabio da Silva")<br />#data_hora_transacao - Data e hora da transa��o - ("26/01/2023 �s 17:54:32")<br/>#valor_bloqueado - Valor bloqueado (Ex: 2.000,00)'
  WHERE tnap.cdmensagem = 7391
  AND tnap.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'O Pix que voc� realizou em #datahoratransacao, no valor de #valorpix para #beneficiario foi devolvido no valor #parcialtotalmente de #valordevolvido.</br></br><b>O valor est� novamente dispon�vel em sua conta corrente.</b></br></br>Acesse o comprovante para mais detalhes da devolu��o.'
  WHERE tnmc.cdmensagem = 5470
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '</br>#datatransacao - Data da transa��o (Ex.: 25/08/2099)</br>#valorpix - Valor do Pix (Ex.: 45,00)</br>#beneficiario - Nome do benefici�rio</br>#parcialtotalmente - Tipo da devolu��o (Parcial/Totalmente)</br>#datahoratransacao - Data e hora da transa��o (Ex.: 25/08/2099 �s 18:12:48)</br>#valordevolvido - Valor da devolu��o recebida (Ex.: 45,00)'
  WHERE tnap.cdmensagem = 5470
  AND tnap.cdorigem_mensagem = 13;
  
  SELECT MAX(CDMENSAGEM)
  INTO V_CODIGO_MENSAGEM
  FROM TBGEN_NOTIF_MSG_CADASTRO;
  
  SELECT MAX(CDMOTIVO_MENSAGEM)
  INTO V_CODIGO_MOTIVO
  FROM TBGEN_NOTIF_AUTOMATICA_PRM;
  
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
    ,DSTEXTO_BOTAO_ACAO_MOBILE
    ,INENVIAR_PUSH
    ,DSMENSAGEM_ACAO_MOBILE)
  VALUES
    ((V_CODIGO_MENSAGEM + 1)
    ,13
    ,'Foi devolvido um Pix'
    ,'Foi devolvido #valor_devolucao_pix de um Pix. A transa��o j� foi conclu�da.'
    ,'Cooperado,<br/><br/>Foi devolvido #valor_devolucao_pix de um Pix recebido em #data_hora_transacao.<br/><br/>Destinat�rio: #nome_pagador<br/>Valor da transa��o original: #valor_pix<br/>Institui��o: #instituicao_pagador<br/>Identifica��o: #identificao_transacao<br/>Descri��o:<br/><br/>Acesse o comprovante ou confira o extrato da sua conta corrente.'
    ,16
    ,0
    ,1
    ,'400'
    ,'Ver comprovante'
    ,1
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
    ,(V_CODIGO_MOTIVO + 1)
    ,'PIX - Envio de devolu��o de Pix'
    ,(V_CODIGO_MENSAGEM + 1)
    ,'<br/>#valor_devolucao_pix - Valor de Devolu��o do Pix (Ex: 2.000,00)<br/>#data_hora_transacao - Data e hora da transa��o - ("26/01/2023 �s 17:54:32")<br/>#nome_pagador - Nome do Pagador (Ex: "Fabio da Silva")<br/>#valor_pix - Valor do Pix (Ex: 2.000,00)<br/>#instituicao_pagador - PSP do Pagador (Ex.:"Viacredi")<br/>#identificao_transacao - Identifica��o da Transa��o (896547896)'
    ,1
    ,0);
  
  SELECT MAX(CDMENSAGEM)
  INTO V_CODIGO_MENSAGEM
  FROM TBGEN_NOTIF_MSG_CADASTRO;
  
  SELECT MAX(CDMOTIVO_MENSAGEM)
  INTO V_CODIGO_MOTIVO
  FROM TBGEN_NOTIF_AUTOMATICA_PRM;
  
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
    ,DSTEXTO_BOTAO_ACAO_MOBILE
    ,INENVIAR_PUSH
    ,DSMENSAGEM_ACAO_MOBILE)
  VALUES
    ((V_CODIGO_MENSAGEM + 1)
    ,13
    ,'Foi devolvido um Pix'
    ,'Foi devolvido #valor_devolucao_pix de um Pix. A transa��o j� foi conclu�da.'
    ,'Cooperado,<br/><br/>Foi devolvido #valor_devolucao_pix de um Pix recebido em #data_hora_transacao.<br/><br/>Destinat�rio: #nome_pagador<br/>Valor da transa��o original: #valor_pix<br/>Institui��o: #instituicao_pagador<br/>Identifica��o: #identificao_transacao<br/>Data hora �ltimo bloqueio: #data_hora_bloqueio<br/>Descri��o:<br/><br/>Acesse o comprovante ou confira o extrato da sua conta corrente.'
    ,16
    ,0
    ,1
    ,'400'
    ,'Ver comprovante'
    ,1
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
    ,(V_CODIGO_MOTIVO + 1)
    ,'PIX - Envio de devolu��o de Pix'
    ,(V_CODIGO_MENSAGEM + 1)
    ,'<br/>#valor_devolucao_pix - Valor de Devolu��o do Pix (Ex: 2.000,00)<br/>#data_hora_transacao - Data e hora da transa��o - ("26/01/2023 �s 17:54:32")<br/>#nome_pagador - Nome do Pagador (Ex: "Fabio da Silva")<br/>#valor_pix - Valor do Pix (Ex: 2.000,00)<br/>#instituicao_pagador - PSP do Pagador (Ex.:"Viacredi")<br/>#identificao_transacao - Identifica��o da Transa��o (896547896)<br/>#data_hora_bloqueio - data hora bloqueio (Ex.: 26/01/2023 �s 17:54:32)'
    ,1
    ,0);
    
  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

END;
