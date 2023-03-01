DECLARE

V_CODIGO_MENSAGEM TBGEN_NOTIF_MSG_CADASTRO.cdmensagem%TYPE;
V_CODIGO_MOTIVO TBGEN_NOTIF_AUTOMATICA_PRM.cdmotivo_mensagem%TYPE;

BEGIN
  
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
         dbms_output.put_line('Erro: ' || SQLERRM);

END;
