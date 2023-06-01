DECLARE
  codigoMensagem tbgen_notif_msg_cadastro.cdmensagem%TYPE := 0;
BEGIN

  SELECT (max(cdmensagem) + 1)
    into codigoMensagem
    FROM CECRED.tbgen_notif_msg_cadastro;

  INSERT INTO CECRED.tbgen_notif_msg_cadastro
    (cdmensagem,
     cdorigem_mensagem,
     dstitulo_mensagem,
     dstexto_mensagem,
     dshtml_mensagem,
     cdicone,
     inexibir_banner,
     inexibe_botao_acao_mobile,
     dstexto_botao_acao_mobile,
     cdmenu_acao_mobile,
     dsmensagem_acao_mobile,
     inenviar_push)
  VALUES
    (codigoMensagem,
     13,
     'Você enviou um Pix',
     'Você enviou um Pix de R$ #ValorPix. A transação já foi concluída.',
     'Cooperado, <br><br>Você enviou um Pix.<br><br>Recebedor: #NomeRecebedor <br>CPF/CNPJ: #DocumentoRecebedor<br>Valor do pagamento: #ValorPix <br>Instituição: #Instituicao <br> Identificação: #Identificacao <br>Descrição: #Descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente.',
     16,
     0,
     1,
     'Ver comprovante',
     400,
     'Ver comprovante',
     1);

  INSERT INTO CECRED.tbgen_notif_automatica_prm
    (cdorigem_mensagem,
     cdmotivo_mensagem,
     dsmotivo_mensagem,
     cdmensagem,
     inmensagem_ativa,
     intipo_repeticao,
     dsvariaveis_mensagem)
  VALUES
    (13,
     59,
     'PIX - Você enviou um Pix',
     codigoMensagem,
     1,
     0,
     '<br>#NomeRecebedor - Nome do Recebedor<br>#DocumentoRecebedor - CPF/CNPJ<br>#ValorPix - Valor do pagamento (Ex.: 5000,00)<br>#Instituicao - Nome da Instituição<br>#Identificacao - Identificação do Pix<br>#Descricao - Descrição do Pagamento');

  SELECT (max(cdmensagem) + 1)
    into codigoMensagem
    FROM CECRED.tbgen_notif_msg_cadastro;

  INSERT INTO CECRED.tbgen_notif_msg_cadastro
    (cdmensagem,
     cdorigem_mensagem,
     dstitulo_mensagem,
     dstexto_mensagem,
     dshtml_mensagem,
     cdicone,
     inexibir_banner,
     inexibe_botao_acao_mobile,
     dstexto_botao_acao_mobile,
     cdmenu_acao_mobile,
     dsmensagem_acao_mobile,
     inenviar_push)
  VALUES
    (codigoMensagem,
     13,
     'Você enviou um Pix',
     'Você enviou um Pix de R$ #ValorPix. A transação já foi concluída.',
     'Cooperado, <br><br>Você enviou um Pix.<br><br>Recebedor: #NomeRecebedor <br>CPF/CNPJ: #DocumentoRecebedor<br>Valor do pagamento: #ValorPix <br>Valor da tarifa: #ValorTarifaPix <br>Instituição: #Instituicao <br> Identificação: #Identificacao <br>Descrição: #Descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente.',
     16,
     0,
     1,
     'Ver comprovante',
     400,
     'Ver comprovante',
     1);

  INSERT INTO CECRED.tbgen_notif_automatica_prm
    (cdorigem_mensagem,
     cdmotivo_mensagem,
     dsmotivo_mensagem,
     cdmensagem,
     inmensagem_ativa,
     intipo_repeticao,
     dsvariaveis_mensagem)
  VALUES
    (13,
     60,
     'PIX - Você enviou um Pix',
     codigoMensagem,
     1,
     0,
     '<br>#NomeRecebedor - Nome do Recebedor<br>#DocumentoRecebedor - CPF/CNPJ<br>#ValorPix - Valor do pagamento (Ex.: 5000,00)<br>#ValorTarifaPix# - Valor da tarifa (Ex.: 5,00)<br>Instituicao - Nome da Instituição<br>#Identificacao - Identificação do Pix<br>#Descricao - Descrição do Pagamento');

  SELECT (max(cdmensagem) + 1)
    into codigoMensagem
    FROM CECRED.tbgen_notif_msg_cadastro;

  INSERT INTO CECRED.tbgen_notif_msg_cadastro
    (cdmensagem,
     cdorigem_mensagem,
     dstitulo_mensagem,
     dstexto_mensagem,
     dshtml_mensagem,
     cdicone,
     inexibir_banner,
     inexibe_botao_acao_mobile,
     dstexto_botao_acao_mobile,
     cdmenu_acao_mobile,
     dsmensagem_acao_mobile,
     inenviar_push)
  VALUES
    (codigoMensagem,
     13,
     'Você recebeu um Pix',
     'Você recebeu um crédito Pix de #valorpix. O valor já está em sua conta.',
     'Cooperado,</br></br>Você recebeu um crédito Pix.</br></br>Pagador: #nomepagador </br>CPF/CNPJ : #documentopagador</br>Valor: #valorpix </br>Instituição: #psppagador </br>Identificação: #identificacao </br>Descrição: #descricao </br></br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente</br></br>',
     16,
     0,
     1,
     'Ver comprovante',
     400,
     'Ver comprovante',
     1);

  INSERT INTO CECRED.tbgen_notif_automatica_prm
    (cdorigem_mensagem,
     cdmotivo_mensagem,
     dsmotivo_mensagem,
     cdmensagem,
     inmensagem_ativa,
     intipo_repeticao,
     dsvariaveis_mensagem)
  VALUES
    (13,
     61,
     'PIX - Recebimento de crédito Pix',
     codigoMensagem,
     1,
     0,
     '</br>#valorpix - Valor do Pix (Ex.: 45,00)</br>#nomepagador - Nome do pagador</br>#documentopagador - CPF/CNPJ</br>#psppagador - PSP do pagador </br>#identificacao - Identificação</br>#descricao - Descrição');

  COMMIT;
END;
