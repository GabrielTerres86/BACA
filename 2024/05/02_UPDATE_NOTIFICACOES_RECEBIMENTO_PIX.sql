BEGIN
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = 'Cooperado, <br><br>Você enviou um Pix.<br><br>Recebedor: #NomeRecebedor <br>Valor do pagamento: #ValorPix <br>Instituição: #Instituicao <br> Identificação: #Identificacao <br>Data/Hora Transação: #datahoratransacao <br>Descrição: #Descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente.'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 11399;
  
  UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '<br>#NomeRecebedor - Nome do Recebedor<br>#ValorPix - Valor do pagamento (Ex.: 5000,00)<br>#Instituicao - Nome da Instituição<br>#Identificacao - Identificação do Pix<br>#datahoratransacao - Data/Hora Transação<br>#Descricao - Descrição do Pagamento'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 53 AND CDMENSAGEM = 11399;
  
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = 'Cooperado, <br><br>Você enviou um Pix.<br><br>Recebedor: #NomeRecebedor <br>Valor do pagamento: #ValorPix <br>Valor da tarifa: #ValorTarifaPix <br>Instituição: #Instituicao <br> Identificação: #Identificacao <br>Data/Hora Transação: #datahoratransacao <br>Descrição: #Descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente.'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 11400;
  
  UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '<br>#NomeRecebedor - Nome do Recebedor<br>#ValorPix - Valor do pagamento (Ex.: 5000,00)<br>#ValorTarifaPix# - Valor da tarifa (Ex.: 5,00)<br>Instituicao - Nome da Instituição<br>#Identificacao - Identificação do Pix<br>#datahoratransacao - Data/Hora Transação<br>#Descricao - Descrição do Pagamento'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 54 AND CDMENSAGEM = 11400;
  
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = 'Cooperado, <br><br>Você enviou um Pix.<br><br>Recebedor: #NomeRecebedor <br>CPF/CNPJ: #DocumentoRecebedor<br>Valor do pagamento: #ValorPix <br>Instituição: #Instituicao <br> Identificação: #Identificacao <br>Data/Hora Transação: #datahoratransacao <br>Descrição: #Descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente.'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 16049;
  
  UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '<br>#NomeRecebedor - Nome do Recebedor<br>#DocumentoRecebedor - CPF/CNPJ<br>#ValorPix - Valor do pagamento (Ex.: 5000,00)<br>#Instituicao - Nome da Instituição<br>#Identificacao - Identificação do Pix<br>#datahoratransacao - Data/Hora Transação<br>#Descricao - Descrição do Pagamento'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 59 AND CDMENSAGEM = 16049;  
  
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = 'Cooperado, <br><br>Você enviou um Pix.<br><br>Recebedor: #NomeRecebedor <br>CPF/CNPJ: #DocumentoRecebedor<br>Valor do pagamento: #ValorPix <br>Valor da tarifa: #ValorTarifaPix <br>Instituição: #Instituicao <br> Identificação: #Identificacao <br>Data/Hora Transação: #datahoratransacao <br>Descrição: #Descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente.'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 16050;
  
  UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '<br>#NomeRecebedor - Nome do Recebedor<br>#DocumentoRecebedor - CPF/CNPJ<br>#ValorPix - Valor do pagamento (Ex.: 5000,00)<br>#ValorTarifaPix# - Valor da tarifa (Ex.: 5,00)<br>Instituicao - Nome da Instituição<br>#Identificacao - Identificação do Pix<br>#datahoratransacao - Data/Hora Transação<br>#Descricao - Descrição do Pagamento'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 60 AND CDMENSAGEM = 16050;
  
COMMIT;
END;
