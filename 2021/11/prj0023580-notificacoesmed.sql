DECLARE
  V_CODIGO                 TBGEN_NOTIF_MSG_CADASTRO.cdmensagem%TYPE;
  V_CODIGO_MOTIVO_MENSAGEM TBGEN_NOTIF_AUTOMATICA_PRM.Cdmotivo_Mensagem%TYPE;
BEGIN
  SELECT MAX(CDMENSAGEM) INTO V_CODIGO FROM TBGEN_NOTIF_MSG_CADASTRO;
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM,
     CDORIGEM_MENSAGEM,
     DSTITULO_MENSAGEM,
     DSTEXTO_MENSAGEM,
     DSHTML_MENSAGEM,
     CDICONE,
     INEXIBIR_BANNER,
     INEXIBE_BOTAO_ACAO_MOBILE,
     CDMENU_ACAO_MOBILE,
     INENVIAR_PUSH,
     DSMENSAGEM_ACAO_MOBILE,
     Dstexto_Botao_Acao_Mobile)
  VALUES
    ((V_CODIGO + 1),
     13,
     'Solicita��o de devolu��o de Pix',
     'Voc� recebeu um Pix, mas o pagador contestou e solicitou devolu��o do valor.',
     'Ol�,<br> Voc� recebeu um Pix no valor de #valorpix de #nomepagador, mas ele foi contestado. <br> Isto significa que esta opera��o est� sendo analisada e em at� 10 dias voc� receber� um retorno. Por enquanto, o valor foi bloqueado, ou seja, ele est� indispon�vel na sua conta. <br> Se a an�lise indicar que est� tudo certo, o valor ser� liberado, caso contr�rio, o valor ser� devolvido para a pessoa que lhe enviou. <br> Esta � uma medida de seguran�a do Pix. Agradecemos a sua compreens�o.',
     16,
     0,
     0,
     '',
     1,
     '',
     '');
  SELECT MAX(CDMOTIVO_MENSAGEM)
    INTO V_CODIGO_MOTIVO_MENSAGEM
    FROM TBGEN_NOTIF_AUTOMATICA_PRM;
  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM,
     CDMOTIVO_MENSAGEM,
     DSMOTIVO_MENSAGEM,
     CDMENSAGEM,
     DSVARIAVEIS_MENSAGEM,
     INMENSAGEM_ATIVA,
     INTIPO_REPETICAO)
  VALUES
    (13,
     (V_CODIGO_MOTIVO_MENSAGEM + 1),
     'PIX - Solicita��o de devolu��o de Pix',
     (V_CODIGO + 1),
     '<br/>#valorpix  - Valor do Pix (Ex: 2.000,00) <br/> #nomepagador - Nome do Pagador (Ex: "Fabio da Silva")',
     1,
     0);

  SELECT MAX(CDMENSAGEM) INTO V_CODIGO FROM TBGEN_NOTIF_MSG_CADASTRO;
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM,
     CDORIGEM_MENSAGEM,
     DSTITULO_MENSAGEM,
     DSTEXTO_MENSAGEM,
     DSHTML_MENSAGEM,
     CDICONE,
     INEXIBIR_BANNER,
     INEXIBE_BOTAO_ACAO_MOBILE,
     CDMENU_ACAO_MOBILE,
     INENVIAR_PUSH,
     DSMENSAGEM_ACAO_MOBILE,
     Dstexto_Botao_Acao_Mobile)
  VALUES
    ((V_CODIGO + 1),
     13,
     'Pix Devolvido',
     'Analisamos o Pix que voc� recebeu e ele ser� devolvido para o pagador.',
     'Ol�, <br><br> Voc� recebeu um Pix no valor de #valorpix de #nomepagador, mas ele foi contestado. O caso foi analisado e identificamos que a contesta��o � procedente, ent�o o valor foi devolvido para o pagador. Esta � uma medida de seguran�a do Pix. <br><br>Agradecemos a sua compreens�o.',
     16,
     0,
     0,
     '',
     1,
     '',
     '');
  SELECT MAX(CDMOTIVO_MENSAGEM)
    INTO V_CODIGO_MOTIVO_MENSAGEM
    FROM TBGEN_NOTIF_AUTOMATICA_PRM;
  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM,
     CDMOTIVO_MENSAGEM,
     DSMOTIVO_MENSAGEM,
     CDMENSAGEM,
     DSVARIAVEIS_MENSAGEM,
     INMENSAGEM_ATIVA,
     INTIPO_REPETICAO)
  VALUES
    (13,
     (V_CODIGO_MOTIVO_MENSAGEM + 1),
     'PIX - Pix Devolvido',
     (V_CODIGO + 1),
     '<br/>#valorpix - Valor do Pix (Ex: 2.000,00) <br/> #nomepagador - Nome do Pagador (Ex: "Fabio da Silva")',
     1,
     0);

  SELECT MAX(CDMENSAGEM) INTO V_CODIGO FROM TBGEN_NOTIF_MSG_CADASTRO;
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM,
     CDORIGEM_MENSAGEM,
     DSTITULO_MENSAGEM,
     DSTEXTO_MENSAGEM,
     DSHTML_MENSAGEM,
     CDICONE,
     INEXIBIR_BANNER,
     INEXIBE_BOTAO_ACAO_MOBILE,
     CDMENU_ACAO_MOBILE,
     INENVIAR_PUSH,
     DSMENSAGEM_ACAO_MOBILE,
     Dstexto_Botao_Acao_Mobile)
  VALUES
    ((V_CODIGO + 1),
     13,
     'Solicita��o de devolu��o de Pix negada',
     'Voc� recebeu uma solicita��o de devolu��o de Pix, mas analisamos que a contesta��o � improcedente e o valor foi liberado em sua conta.',
     'Ol�, <br><br> Voc� recebeu um Pix no valor de #valorpix de #nomepagador e ele foi contestado. O caso foi analisado e identificamos que a contesta��o � improcedente, ent�o o valor foi liberado em sua conta. Esta � uma medida de seguran�a do Pix. <br><br>Agradecemos a sua compreens�o.',
     16,
     0,
     0,
     '',
     1,
     '',
     '');
  SELECT MAX(CDMOTIVO_MENSAGEM)
    INTO V_CODIGO_MOTIVO_MENSAGEM
    FROM TBGEN_NOTIF_AUTOMATICA_PRM;
  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM,
     CDMOTIVO_MENSAGEM,
     DSMOTIVO_MENSAGEM,
     CDMENSAGEM,
     DSVARIAVEIS_MENSAGEM,
     INMENSAGEM_ATIVA,
     INTIPO_REPETICAO)
  VALUES
    (13,
     (V_CODIGO_MOTIVO_MENSAGEM + 1),
     'PIX - Solicita��o de devolu��o de Pix negada',
     (V_CODIGO + 1),
     '<br/>#valorpix - Valor do Pix (Ex: 2.000,00) <br/> #nomepagador - Nome do Pagador (Ex: "Fabio da Silva")',
     1,
     0);

  SELECT MAX(CDMENSAGEM) INTO V_CODIGO FROM TBGEN_NOTIF_MSG_CADASTRO;
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM,
     CDORIGEM_MENSAGEM,
     DSTITULO_MENSAGEM,
     DSTEXTO_MENSAGEM,
     DSHTML_MENSAGEM,
     CDICONE,
     INEXIBIR_BANNER,
     INEXIBE_BOTAO_ACAO_MOBILE,
     CDMENU_ACAO_MOBILE,
     INENVIAR_PUSH,
     DSMENSAGEM_ACAO_MOBILE,
     Dstexto_Botao_Acao_Mobile)
  VALUES
    ((V_CODIGO + 1),
     13,
     'Contesta��o de Pix em an�lise',
     'O Pix que voc� contestou est� sendo analisado.',
     'Ol�, <br><br>O Pix que voc� contestou no valor de #valorpix para #nomerecebedor est� sendo analisado pela �rea respons�vel. Caso o retorno da contesta��o seja positivo, faremos a solicita��o de devolu��o mediante aprova��o da institui��o financeira do recebedor. Assim que a an�lise for conclu�da, voc� receber� um retorno. Esta � uma medida de seguran�a do Pix. <br><br> Agradecemos a sua compreens�o.',
     16,
     0,
     0,
     '',
     1,
     '',
     '');
  SELECT MAX(CDMOTIVO_MENSAGEM)
    INTO V_CODIGO_MOTIVO_MENSAGEM
    FROM TBGEN_NOTIF_AUTOMATICA_PRM;
  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM,
     CDMOTIVO_MENSAGEM,
     DSMOTIVO_MENSAGEM,
     CDMENSAGEM,
     DSVARIAVEIS_MENSAGEM,
     INMENSAGEM_ATIVA,
     INTIPO_REPETICAO)
  VALUES
    (13,
     (V_CODIGO_MOTIVO_MENSAGEM + 1),
     'PIX - Contesta��o de Pix em an�lise',
     (V_CODIGO + 1),
     '<br/>#valorpix - Valor do Pix (Ex: 2.000,00) <br/> #nomerecebedor - Nome do Pagador (Ex: "Frank George")',
     1,
     0);

  SELECT MAX(CDMENSAGEM) INTO V_CODIGO FROM TBGEN_NOTIF_MSG_CADASTRO;
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM,
     CDORIGEM_MENSAGEM,
     DSTITULO_MENSAGEM,
     DSTEXTO_MENSAGEM,
     DSHTML_MENSAGEM,
     CDICONE,
     INEXIBIR_BANNER,
     INEXIBE_BOTAO_ACAO_MOBILE,
     CDMENU_ACAO_MOBILE,
     INENVIAR_PUSH,
     DSMENSAGEM_ACAO_MOBILE,
     Dstexto_Botao_Acao_Mobile)
  VALUES
    ((V_CODIGO + 1),
     13,
     'Contesta��o de Pix aceita',
     'A devolu��o do Pix que voc� contestou foi recebida.',
     'Ol�, <br><br>O Pix que voc� contestou foi analisado e a institui��o financeira do recebedor aprovou a devolu��o de #valordevolucaorecebida. <br><br>Creditamos o valor na sua conta e ele j� est� dispon�vel.',
     16,
     0,
     0,
     '',
     1,
     '',
     '');
  SELECT MAX(CDMOTIVO_MENSAGEM)
    INTO V_CODIGO_MOTIVO_MENSAGEM
    FROM TBGEN_NOTIF_AUTOMATICA_PRM;
  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM,
     CDMOTIVO_MENSAGEM,
     DSMOTIVO_MENSAGEM,
     CDMENSAGEM,
     DSVARIAVEIS_MENSAGEM,
     INMENSAGEM_ATIVA,
     INTIPO_REPETICAO)
  VALUES
    (13,
     (V_CODIGO_MOTIVO_MENSAGEM + 1),
     'PIX - Contesta��o de Pix aceita',
     (V_CODIGO + 1),
     '<br/>#valordevolucaorecebida - Valor de Devolucao do Pix (Ex: 2.000,00)',
     1,
     0);

  SELECT MAX(CDMENSAGEM) INTO V_CODIGO FROM TBGEN_NOTIF_MSG_CADASTRO;
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM,
     CDORIGEM_MENSAGEM,
     DSTITULO_MENSAGEM,
     DSTEXTO_MENSAGEM,
     DSHTML_MENSAGEM,
     CDICONE,
     INEXIBIR_BANNER,
     INEXIBE_BOTAO_ACAO_MOBILE,
     CDMENU_ACAO_MOBILE,
     INENVIAR_PUSH,
     DSMENSAGEM_ACAO_MOBILE,
     Dstexto_Botao_Acao_Mobile)
  VALUES
    ((V_CODIGO + 1),
     13,
     'Contesta��o de Pix n�o atendida',
     'A sua contesta��o de Pix n�o foi respondida pela institui��o do recebedor e o valor n�o foi devolvido.',
     'Ol�,<br><br> N�o obtivemos resposta da institui��o financeira do recebedor sobre a solicita��o de devolu��o do Pix de #valorpix para #nomeRecebedor que voc� contestou. <br>Para maiores informa��es voc� pode acessar o Servi�o de Atendimento Pix, na op��o Atendimento do Banco Central do Brasil.',
     16,
     0,
     0,
     '',
     1,
     '',
     '');
  SELECT MAX(CDMOTIVO_MENSAGEM)
    INTO V_CODIGO_MOTIVO_MENSAGEM
    FROM TBGEN_NOTIF_AUTOMATICA_PRM;
  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM,
     CDMOTIVO_MENSAGEM,
     DSMOTIVO_MENSAGEM,
     CDMENSAGEM,
     DSVARIAVEIS_MENSAGEM,
     INMENSAGEM_ATIVA,
     INTIPO_REPETICAO)
  VALUES
    (13,
     (V_CODIGO_MOTIVO_MENSAGEM + 1),
     'PIX - Contesta��o de Pix n�o atendida',
     (V_CODIGO + 1),
     '<br/>#valorpix - Valor do Pix (Ex: 2.000,00)',
     1,
     0);

  SELECT MAX(CDMENSAGEM) INTO V_CODIGO FROM TBGEN_NOTIF_MSG_CADASTRO;
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM,
     CDORIGEM_MENSAGEM,
     DSTITULO_MENSAGEM,
     DSTEXTO_MENSAGEM,
     DSHTML_MENSAGEM,
     CDICONE,
     INEXIBIR_BANNER,
     INEXIBE_BOTAO_ACAO_MOBILE,
     CDMENU_ACAO_MOBILE,
     INENVIAR_PUSH,
     DSMENSAGEM_ACAO_MOBILE,
     Dstexto_Botao_Acao_Mobile)
  VALUES
    ((V_CODIGO + 1),
     13,
     'Contesta��o de Pix rejeitada pela contraparte',
     'A sua contesta��o de Pix foi rejeitada e o valor n�o pode ser devolvido.',
     'Ol�, <br><br> O Pix de #valorpix para #nomerecebedor que voc� contestou foi analisado, mas a opera��o n�o pode ser devolvida pela conta recebedora. <br><br>Infelizmente n�o ser� poss�vel creditar o valor � sua conta.',
     16,
     0,
     0,
     '',
     1,
     '',
     '');
  SELECT MAX(CDMOTIVO_MENSAGEM)
    INTO V_CODIGO_MOTIVO_MENSAGEM
    FROM TBGEN_NOTIF_AUTOMATICA_PRM;
  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM,
     CDMOTIVO_MENSAGEM,
     DSMOTIVO_MENSAGEM,
     CDMENSAGEM,
     DSVARIAVEIS_MENSAGEM,
     INMENSAGEM_ATIVA,
     INTIPO_REPETICAO)
  VALUES
    (13,
     (V_CODIGO_MOTIVO_MENSAGEM + 1),
     'PIX - Contesta��o de Pix rejeitada pela contraparte',
     (V_CODIGO + 1),
     '<br/>#valorpix - Valor do Pix (Ex: 2.000,00)<br>#nomerecebedor - Nome do Recebedor - ("Fabio Silva")',
     1,
     0);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro: ' || SQLERRM);
END;
