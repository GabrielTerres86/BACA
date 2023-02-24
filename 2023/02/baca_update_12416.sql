DECLARE

BEGIN
  
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br/><br/>Foi devolvido #valor_devolucao_pix de um Pix recebido em #data_hora_transacao.<br/><br/>Destinat�rio: #nome_pagador<br/>Valor da transa��o original: #valor_pix<br/>Institui��o: #instituicao_pagador<br/>Identifica��o: #identificao_transacao<br/>#campo_completo_data_hora_bloqueioDescri��o:<br/><br/>Acesse o comprovante ou confira o extrato da sua conta corrente.',
  tnmc.dstexto_mensagem = 'Foi devolvido #valor_devolucao_pix de um Pix. A transa��o j� foi conclu�da.',
  tnmc.dstexto_botao_acao_mobile = 'Ver Comprovante'
  WHERE tnmc.cdmensagem = 12416
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br/>#valor_devolucao_pix - Valor de Devolu��o do Pix (Ex: 2.000,00)<br/>#data_hora_transacao - Data e hora da transa��o - ("26/01/2023 �s 17:54:32")<br/>#nome_pagador - Nome do Pagador (Ex: "Fabio da Silva")<br/>#valor_pix - Valor do Pix (Ex: 2.000,00)<br/>#instituicao_pagador - PSP do Pagador (Ex.:"Viacredi")<br/>#identificao_transacao - Identifica��o da Transa��o (896547896)<br/>#campo_completo_data_hora_bloqueio - descri��o e valores de data hora bloqueio (Ex.: Data Hora Bloqueio: 26/01/2023 �s 17:54:32)',
  tnap.dsmotivo_mensagem = 'PIX - Envio de devolu��o de Pix'
  WHERE tnap.cdmensagem = 12416
  AND tnap.cdorigem_mensagem = 13;
  
  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

END;
