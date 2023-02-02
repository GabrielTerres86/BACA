DECLARE

BEGIN
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br /><br />Você recebeu um crédito Pix de #valor_pix, porém esta transação está em análise. Este valor ficará com bloqueio cautelar por no máximo 72 horas. Após a conclusão da análise, dentro do prazo citado, você receberá uma nova notificação com o resultado da avaliação.<br /><br />Valor bloqueado: #valor_bloqueado_pix<br />Pagador: #nome_pagador<br />Instituição: #instituicao_pagador<br />Identificação: #identificao_transacao<br />Descrição: <br />Data hora transação: #data_hora_transacao<br /><br />Este é uma procedimento obrigatório de acordo com o Regulamento Pix, emitido pelo Banco Central do Brasil para garantir mais segurança às suas transações.'
  WHERE tnmc.cdmensagem = 10524
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br />#valor_pix - Valor do Pix (Ex.: 2.000,00)<br />#nome_pagador - Nome do Pagador - ("João da Silva")<br />#instituicao_pagador - Instituição do Pagador ("Viacredi")<br />#identificao_transacao - Identificação da Transação (E18236120202011062016s0644601CBP)<br />#data_hora_transacao - Data e hora da transação - ("26/01/2023 17:54:32")<br />#valor_bloqueado_pix - Valor do Pix bloqueado (Ex.: 2.000,00)'
  WHERE tnap.cdmensagem = 10524
  AND tnap.cdorigem_mensagem = 13;
  
  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

END;
