DECLARE

BEGIN
  
  -- Cautelar
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br /><br />Voc� recebeu um cr�dito Pix de #valor_pix, por�m esta transa��o est� em an�lise. Este valor ficar� com bloqueio cautelar por no m�ximo 72 horas. Ap�s a conclus�o da an�lise, dentro do prazo citado, voc� receber� uma nova notifica��o com o resultado da avalia��o.<br /><br />Valor bloqueado: #valor_bloqueado_pix<br />Pagador: #nome_pagador<br />Institui��o: #instituicao_pagador<br />Identifica��o: #identificao_transacao<br />Descri��o: <br />Data hora transa��o: #data_hora_transacao<br /><br />Este � uma procedimento obrigat�rio de acordo com o Regulamento Pix, emitido pelo Banco Central do Brasil para garantir mais seguran�a �s suas transa��es.'
  WHERE tnmc.cdmensagem = 10524
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br />#valor_pix - Valor do Pix (Ex.: 2.000,00)<br />#nome_pagador - Nome do Pagador - ("Jo�o da Silva")<br />#instituicao_pagador - Institui��o do Pagador ("Viacredi")<br />#identificao_transacao - Identifica��o da Transa��o (E18236120202011062016s0644601CBP)<br />#data_hora_transacao - Data e hora da transa��o - ("26/01/2023 17:54:32")<br />#valor_bloqueado_pix - Valor do Pix bloqueado (Ex.: 2.000,00)'
  WHERE tnap.cdmensagem = 10524
  AND tnap.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br /><br />O cr�dito Pix de #valor_pix, que voc� recebeu em #data_hora_transacao foi analisado e liberado. O valor j� est� dispon�vel em sua conta.<br /><br />Valor desbloqueado: #valor_desbloqueado_pix<br />Pagador: #nome_pagador<br />Institui��o: #instituicao_pagador<br />Identifica��o: #identificao_transacao<br />Descri��o:<br />Data hora bloqueio: #data_hora_bloqueio<br /><br />Acesse o comprovante no App Ailos ou confira o extrato da sua conta.'
  WHERE tnmc.cdmensagem = 10525
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br />#data_hora_transacao - Data da Transa��o (Ex.: 17/02/2022 11:06:32)<br />#valor_pix - Valor do Pix (Ex.: 2.000,00)<br />#nome_pagador - Nome do Pagador - ("Jo�o da Silva")<br />#instituicao_pagador - Institui��o do Pagador ("Viacredi")<br />#identificao_transacao - Identifica��o da Transa��o (E18236120202011062016s0644601CBP)<br />#valor_desbloqueado_pix - Valor desbloqueado (Ex.: 2.000,00)<br />#data_hora_bloqueio - Data e hora do bloqueio (Ex.: 18/02/2022 13:12:54)'
  WHERE tnap.cdmensagem = 10525
  AND tnap.cdorigem_mensagem = 13;
  
  -- MED
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado, <br><br> Em #data_hora_transacao voc� recebeu um Pix no valor de #valorpix de #nomepagador e ele foi contestado. O caso foi analisado e identificamos que a contesta��o � improcedente, ent�o o valor de #valor_bloqueado_pix em #data_hora_bloqueio foi liberado em sua conta. Esta � uma medida de seguran�a do Pix. <br><br>Agradecemos a sua compreens�o.',
  tnmc.inexibe_botao_acao_mobile = 1,
  tnmc.dstexto_botao_acao_mobile = 'Ver Comprovante',
  tnmc.cdmenu_acao_mobile = 400
  WHERE tnmc.cdmensagem = 7393
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br/>#valorpix - Valor do Pix (Ex: 2.000,00) <br/> #nomepagador - Nome do Pagador (Ex: "Fabio da Silva") <br />#data_hora_transacao - Data e hora da transa��o - ("26/01/2023 17:54:32") <br/>#valor_bloqueado_pix - Valor bloqueado (Ex: 2.000,00) <br />#data_hora_bloqueio - Data e hora do bloqueio - ("28/01/2023 15:34:52")'
  WHERE tnap.cdmensagem = 7393
  AND tnap.cdorigem_mensagem = 13;
  
  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

END;