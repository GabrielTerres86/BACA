BEGIN
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = 'Cooperado,<br><br>Você recebeu um crédito Pix.<br><br>Pagador: #nomepagador <br>Valor: #valorpix <br>Instituição: #psppagador <br>Identificação: #identificacao <br>Data/Hora Transacão : #datahoratransacao <br>Descrição: #descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 5469;
  
  UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '</br>#valorpix - Valor do Pix (Ex.: 45,00)</br>#nomepagador - Nome do pagador</br>#psppagador - PSP do pagador </br>#identificacao - Identificação</br>#datahoratransacao - Data/Hora Transacão</br>#descricao - Descrição'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 13 AND CDMENSAGEM = 5469;
  
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = 'Cooperado,<br><br>Você recebeu um crédito Pix.<br><br>Pagador: #nomepagador <br>CPF/CNPJ : #documentopagador<br>Valor: #valorpix <br>Instituição: #psppagador <br>Identificação: #identificacao <br>Data/Hora Transacão : #datahoratransacao <br>Descrição: #descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 15251;
  
  UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '</br>#valorpix - Valor do Pix (Ex.: 45,00)</br>#nomepagador - Nome do pagador</br>#documentopagador - CPF/CNPJ</br>#psppagador - PSP do pagador </br>#identificacao - Identificação</br>#datahoratransacao - Data/Hora Transacão</br>#descricao - Descrição'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 61 AND CDMENSAGEM = 15251;  
 
COMMIT;
END;
