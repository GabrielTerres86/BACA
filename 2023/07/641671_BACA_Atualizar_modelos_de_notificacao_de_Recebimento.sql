BEGIN
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = 'Cooperado,<br><br>Voc� recebeu um cr�dito Pix.<br><br>Pagador: #nomepagador <br>Valor: #valorpix <br>Institui��o: #psppagador <br>Identifica��o: #identificacao <br>Data/Hora Transac�o : #datahoratransacao <br>Descri��o: #descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 5469;
  
  UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '</br>#valorpix - Valor do Pix (Ex.: 45,00)</br>#nomepagador - Nome do pagador</br>#psppagador - PSP do pagador </br>#identificacao - Identifica��o</br>#datahoratransacao - Data/Hora Transac�o</br>#descricao - Descri��o'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 13 AND CDMENSAGEM = 5469;
  
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = 'Cooperado,<br><br>Voc� recebeu um cr�dito Pix.<br><br>Pagador: #nomepagador <br>CPF/CNPJ : #documentopagador<br>Valor: #valorpix <br>Institui��o: #psppagador <br>Identifica��o: #identificacao <br>Data/Hora Transac�o : #datahoratransacao <br>Descri��o: #descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 15251;
  
  UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '</br>#valorpix - Valor do Pix (Ex.: 45,00)</br>#nomepagador - Nome do pagador</br>#documentopagador - CPF/CNPJ</br>#psppagador - PSP do pagador </br>#identificacao - Identifica��o</br>#datahoratransacao - Data/Hora Transac�o</br>#descricao - Descri��o'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 61 AND CDMENSAGEM = 15251;  
 
COMMIT;
END;
