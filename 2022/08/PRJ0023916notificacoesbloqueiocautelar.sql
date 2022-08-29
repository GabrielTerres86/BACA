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
     'Valor do Pix bloqueado',
     'Você recebeu um crédito Pix de #valor_pix, porém esta transação está em análise.',
     'Cooperado,<br /><br />Você recebeu um crédito Pix de #valor_pix, porém esta transação está em análise. Este valor ficará com bloqueio cautelar por no máximo 72 horas. Após a conclusão da análise, dentro do prazo citado, você receberá uma nova notificação com o resultado da avaliação.<br /><br />Pagador: #nome_pagador<br />Valor: #valor_pix<br />Instituição: #instituicao_pagador<br />Identificação: #identificao_transacao<br />Descrição: <br /><br />Este é uma procedimento obrigatório de acordo com o Regulamento Pix, emitido pelo Banco Central do Brasil para garantir mais segurança às suas transações.',
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
     'PIX - Valor do Pix bloqueado',
     (V_CODIGO + 1),
     '<br />#valor_pix - Valor do Pix (Ex.: 2.000,00)<br />#nome_pagador - Nome do Pagador - ("João da Silva")<br />#instituicao_pagador - Instituição do Pagador ("Viacredi")<br />#identificao_transacao - Identificação da Transação (E18236120202011062016s0644601CBP)',
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
     'Valor do Pix liberado',
     'O crédito que você recebeu em #data_transacao foi analisado, liberado e já está em sua conta.',
     'Cooperado,<br /><br />O crédito que você recebeu em #data_transacao foi analisado e liberado. O valor já está disponível em sua conta.<br /><br />Pagador: #nome_pagador<br />Valor: #valor_pix<br />Instituição: #instituicao_pagador<br />Identificação: #identificao_transacao<br />Descrição:<br /><br />Acesse o comprovante no App Ailos ou confira o extrato da sua conta.',
     16,
     0,
     1,
     '400',
     1,
     '',
     'Ver Comprovante');
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
     'PIX - Valor do Pix liberado',
     (V_CODIGO + 1),
     '<br />#data_transacao - Data da Transação (Ex.: 17/02/2022)<br />#valor_pix - Valor do Pix (Ex.: 2.000,00)<br />#nome_pagador - Nome do Pagador - ("João da Silva")<br />#instituicao_pagador - Instituição do Pagador ("Viacredi")<br />#identificao_transacao - Identificação da Transação (E18236120202011062016s0644601CBP)',
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
     'Valor do Pix devolvido ao pagador',
     'O crédito que Você recebeu em #data_transacao foi analisado e devolvido para o pagador.',
     'Cooperado,<br /><br />O crédito que você recebeu em #data_transacao foi analisado e devolvido para o pagador.<br /><br />Pagador: #nome_pagador<br />Valor: #valor_pix<br />Instituição: #instituicao_pagador<br />Identificação: #identificao_transacao<br />Descrição:<br /><br />Em caso de dúvidas contatar o remetente do recurso.',
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
     'PIX - Valor do Pix devolvido ao pagador',
     (V_CODIGO + 1),
     '<br />#data_transacao - Data da Transação (Ex.: 17/02/2022)<br />#valor_pix - Valor do Pix (Ex.: 2.000,00)<br />#nome_pagador - Nome do Pagador - ("João da Silva")<br />#instituicao_pagador - Instituição do Pagador ("Viacredi")<br />#identificao_transacao - Identificação da Transação (E18236120202011062016s0644601CBP)',
     1,
     0);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro: ' || SQLERRM);
END;
