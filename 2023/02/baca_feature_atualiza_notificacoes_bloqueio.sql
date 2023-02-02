DECLARE

BEGIN
  UPDATE tbgen_notif_msg_cadastro tnmc
  SET tnmc.dshtml_mensagem = 'Cooperado,<br /><br />Voc� recebeu um cr�dito Pix de #valor_pix, por�m esta transa��o est� em an�lise. Este valor ficar� com bloqueio cautelar por no m�ximo 72 horas. Ap�s a conclus�o da an�lise, dentro do prazo citado, voc� receber� uma nova notifica��o com o resultado da avalia��o.<br /><br />Valor bloqueado: #valor_bloqueado_pix<br />Pagador: #nome_pagador<br />Institui��o: #instituicao_pagador<br />Identifica��o: #identificao_transacao<br />Descri��o: <br />Data hora transa��o: #data_hora_transacao<br /><br />Este � uma procedimento obrigat�rio de acordo com o Regulamento Pix, emitido pelo Banco Central do Brasil para garantir mais seguran�a �s suas transa��es.'
  WHERE tnmc.cdmensagem = 10524
  AND tnmc.cdorigem_mensagem = 13;
  
  UPDATE tbgen_notif_automatica_prm tnap 
  SET tnap.dsvariaveis_mensagem = '<br />#valor_pix - Valor do Pix (Ex.: 2.000,00)<br />#nome_pagador - Nome do Pagador - ("Jo�o da Silva")<br />#instituicao_pagador - Institui��o do Pagador ("Viacredi")<br />#identificao_transacao - Identifica��o da Transa��o (E18236120202011062016s0644601CBP)<br />#data_hora_transacao - Data e hora da transa��o - ("26/01/2023 17:54:32")<br />#valor_bloqueado_pix - Valor do Pix bloqueado (Ex.: 2.000,00)'
  WHERE tnap.cdmensagem = 10524
  AND tnap.cdorigem_mensagem = 13;
  
  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

END;
