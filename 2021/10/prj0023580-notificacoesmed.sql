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
     'Solicitação de devolução de Pix',
     'Você recebeu um Pix, mas o pagador contestou e solicitou devolução do valor.',
     'Olá,<br> Você recebeu um Pix no valor de #valorpix de #nomepagador, mas ele foi contestado. <br> Isto significa que esta operação está sendo analisada e em até 10 dias você receberá um retorno. Por enquanto, o valor foi bloqueado, ou seja, ele está indisponível na sua conta. <br> Se a análise indicar que está tudo certo, o valor será liberado, caso contrário, o valor será devolvido para a pessoa que lhe enviou. <br> Esta é uma medida de segurança do Pix. Agradecemos a sua compreensão.',
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
     'PIX - Solicitação de devolução de Pix',
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
     'Analisamos o Pix que você recebeu e ele será devolvido para o pagador.',
     'Olá, <br><br> Você recebeu um Pix no valor de #valorpix de #nomepagador, mas ele foi contestado. O caso foi analisado e identificamos que a contestação é procedente, então o valor foi devolvido para o pagador. Esta é uma medida de segurança do Pix. <br><br>Agradecemos a sua compreensão.',
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
     'Solicitação de devolução de Pix negada',
     'Você recebeu uma solicitação de devolução de Pix, mas analisamos que a contestação é improcedente e o valor foi liberado em sua conta.',
     'Olá, <br><br> Você recebeu um Pix no valor de #valorpix de #nomepagador e ele foi contestado. O caso foi analisado e identificamos que a contestação é improcedente, então o valor foi liberado em sua conta. Esta é uma medida de segurança do Pix. <br><br>Agradecemos a sua compreensão.',
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
     'PIX - Solicitação de devolução de Pix negada',
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
     'Contestação de Pix em análise',
     'O Pix que você contestou está sendo analisado.',
     'Olá, <br><br>O Pix que você contestou no valor de #valorpix para #nomerecebedor está sendo analisado pela área responsável. Caso o retorno da contestação seja positivo, faremos a solicitação de devolução mediante aprovação da instituição financeira do recebedor. Assim que a análise for concluída, você receberá um retorno. Esta é uma medida de segurança do Pix. <br><br> Agradecemos a sua compreensão.',
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
     'PIX - Contestação de Pix em análise',
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
     'Contestação de Pix aceita',
     'A devolução do Pix que você contestou foi recebida.',
     'Olá, <br><br>O Pix que você contestou foi analisado e a instituição financeira do recebedor aprovou a devolução de #valordevolucaorecebida. <br><br>Creditamos o valor na sua conta e ele já está disponível.',
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
     'PIX - Contestação de Pix aceita',
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
     'Contestação de Pix não atendida',
     'A sua contestação de Pix não foi respondida pela instituição do recebedor e o valor não foi devolvido.',
     'Olá,<br><br> Não obtivemos resposta da instituição financeira do recebedor sobre a solicitação de devolução do Pix de #valorpix para #nomeRecebedor que você contestou. <br>Para maiores informações você pode acessar o Serviço de Atendimento Pix, na opção Atendimento do Banco Central do Brasil.',
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
     'PIX - Contestação de Pix não atendida',
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
     'Contestação de Pix rejeitada pela contraparte',
     'A sua contestação de Pix foi rejeitada e o valor não pode ser devolvido.',
     'Olá, <br><br> O Pix de #valorpix para #nomerecebedor que você contestou foi analisado, mas a operação não pode ser devolvida pela conta recebedora. <br><br>Infelizmente não será possível creditar o valor à sua conta.',
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
     'PIX - Contestação de Pix rejeitada pela contraparte',
     (V_CODIGO + 1),
     '<br/>#valorpix - Valor do Pix (Ex: 2.000,00)<br>#nomerecebedor - Nome do Recebedor - ("Fabio Silva")',
     1,
     0);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro: ' || SQLERRM);
END;
