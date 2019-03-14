BEGIN
	
  -- Limpar os dominios para reinser��o
  DELETE tbcc_dominio_campo
   WHERE tbcc_dominio_campo.nmdominio IN ('MOTVREPRVCPORTDDCTSALR'
                                         ,'MOTVCONTTC'
                                         ,'MOTVRESPCONTTCAPROVD'
                                         ,'MOTVRESPCONTTCREPVD'
                                         ,'MOTVREGLZCAPROVD'
                                         ,'MOTVENCRMNTCONTTC'
                                         ,'MOTVREGLZCREPVD'
                                         ,'SIT_PORTAB_CONTESTACAO_ENVIA'
                                         ,'SIT_PORTAB_CONTESTACAO_RECEBE'
                                         ,'SIT_PORTAB_REGULARIZACAO'
                                         ,'PORTAB_REGULARIZA_SIT'
                                         ,'ERRO_PCPS_CIP');

  -- MOTIVOS DE REPROVA��O DE PORTABILIDADE
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '1','CNPJ do Empregador n�o encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '2','CPF do Benefici�rio n�o encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '3','CNPJ e CPF divergentes');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '5','Benefici�rio n�o solicitou a portabilidade');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '6','Desist�ncia do Cliente');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '7','Conta informada n�o permite transfer�ncia');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '9','Conta de pagamento benef�cio INSS');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR','10','Conta sal�rio n�o aberta');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR','11','Falta de clareza na presta��o da informa��o');

  -- MOTIVOS DE CONTESTA��O
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVCONTTC', '1','Recurso enviado para conta divergente da informada na solicita��o de portabilidade (TED Devolvida)');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVCONTTC', '2','Portabilidade aprovada, recurso n�o enviado');

  -- MOTIVOS DE REPOSTA DE CONTESTA��O APROVADA
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCAPROVD', '1','Improcedente, resposta correta');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCAPROVD', '2','Improcedente, nova portabilidade registrada no Participante Folha de Pagamento');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCAPROVD', '3','Improcedente, n�o houve cr�dito de sal�rio ap�s portabilidade');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCAPROVD', '4','Procedente, corre��o de sistema interno');
  
  -- MOTIVOS DE REPOSTA DE CONTESTA��O REPROVADA
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '1','CNPJ do Empregador n�o encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '2','CPF do Benefici�rio n�o encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '3','CNPJ e CPF divergentes');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '5','Benefici�rio n�o solicitou a portabilidade');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '6','Desist�ncia do Cliente');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '7','Conta informada n�o permite transfer�ncia');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '9','Conta pagamento benef�cio � INSS');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD', '10','Conta sal�rio n�o aberta');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD', '11','Falta de clareza na presta��o da informa��o');
  
  -- MOTIVO DE REGULARIZA��O APROVADA
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCAPROVD', '1','Erro Operacional');
  
  -- MOTIVO DE REGULARIZA��O REPROVADA
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '1','CNPJ do Empregador n�o encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '2','CPF do Benefici�rio n�o encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '3','CNPJ e CPF divergentes');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '5','Benefici�rio n�o solicitou a portabilidade');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '6','Desist�ncia do Cliente');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '7','Conta informada n�o permite transfer�ncia');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '9','Conta pagamento benef�cio � INSS');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD', '10','Conta sal�rio n�o aberta');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD', '11','Falta de clareza na presta��o da informa��o');

  -- MOTIVO DE ENCERRAMENTO DA CONTESTA��O
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVENCRMNTCONTTC', '1','Encerramento da Constesta��o por falta de resposta do Participante Folha');
  
  -- SITUA��O DA CONTESTA��O RECEBIDA
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_RECEBE', 1,'Pendente');
	
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_RECEBE', 2,'Aprovada');
	
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_RECEBE', 3,'Reprovada');
	
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_RECEBE', 4,'Fechada sem resposta');
    
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_RECEBE', 5,'Resposta Rejeitada');

  -- SITUA��O DA CONTESTA��O ENVIADA
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_ENVIA', 1,'Solicitada');
	
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_ENVIA', 2,'Contestada');
	
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_ENVIA', 3,'Contesta��o Aprovada');
	
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_ENVIA', 4,'Contesta��o Reprovada');
	
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_ENVIA', 5,'Fechada sem resposta');
  
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_ENVIA', 6,'Contesta��o Rejeitada');
  
  -- SITUA��O DAS REGULARIZA��ES
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_REGULARIZACAO', 1,'Solicitada');
  
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_REGULARIZACAO', 2,'Comunicada CIP');
  
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_REGULARIZACAO', 3,'Regularizado Aprovada');
  
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_REGULARIZACAO', 4,'Regularizado Reprovada');
  
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_REGULARIZACAO', 5,'Regulariza��o Rejeitada');
  
  -- INDICA A REGULARIZA��O
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
  ('PORTAB_REGULARIZA_SIT' , 1, 'Aprovada');
  
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
  ('PORTAB_REGULARIZA_SIT' , 2, 'Reprovada');
  
  ----------------------------------------------
    -- ERROS DE PROCESSAMENTOS
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0001','Portabilidade n�o encontrada');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0002','Portabilidade n�o permitida, solicitante � o Particpante Folha');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0003','Participante Principal n�o aderiu � funcionalidade APCS101');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0004','Participante Administrado n�o aderiu � funcionalidade APCS101');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0005','Participante Principal n�o aderiu � funcionalidade APCS102');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0006','Participante Administrado n�o aderiu a funcionalidade APCS102');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0007','Participante Principal n�o aderiu a funcionalidade APCS103');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0008','Participante Administrado n�o aderiu a funcionalidade APCS103');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0009','Participante Principal n�o aderiu a funcionalidade APCS104');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0010','Participante Administrado n�o aderiu a funcionalidade APCS104');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0011','Participante Administrado n�o aderiu a funcionalidade APCS105');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0012','Data Refer�ncia inv�lida');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0013','CPF inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0014','CNPJ inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0015','Arquivo fora de Grade Hor�ria');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0016','Institui��o n�o participante do PCS');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0017','Portabilidade em andamento');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0018','N�mero �nico da Portabilidade no PCS inv�lido ou n�o encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0019','Data deve ser igual � data atual');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0020','Tipo de conta fora do dom�nio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0022','Participante Administrado n�o � administrado pelo Participante Principal');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0023','N�o � poss�vel solicitar portabilidade para o mesmo DNA (CPF/CNPJ Empregador/ISPB Folha)');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0024','Portabilidade n�o enviada para Institui��o que est� respondendo');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0025','Portabilidade j� respondida');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0026','Portabilidade cancelada');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0027','Motivo de cancelamento inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0031','Nome do Arquivo Duplicado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0035','Campo Conta Pagamento Destino � obrigat�rio para Tipo Conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0036','Campo Conta Pagamento Destino n�o deve ser preenchido para o Tipo Conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0037','Campo Conta Destino � obrigat�rio para Tipo Conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0038','Campo Conta Destino n�o deve ser preenchido para o Tipo conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0039','ISPB informado diferente do solicitante do arquivo');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0040','Campo Ag�ncia Destino � obrigat�rio para Tipo Conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0041','Campo Ag�ncia Destino n�o deve ser preenchido para o Tipo conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0042','Portabilidade em decurso de prazo n�o pode ser respondida');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0043','CPF Cliente informado, divergente da proposta original');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0044','Nome Cliente divergente da solicita��o');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0045','Telefone Cliente divergente da solicita��o');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0046','Email Cliente divergente da solicita��o');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0047','ISPB Folha de Pagamento divergente da solicita��o');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0048','CNPJ do Empregador divergente da solicita��o');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0049','ISPB Participante Destino divergente da Proposta');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0050','Tipo de Conta divergente da Proposta');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0051','Ag�ncia Destino divergente da Proposta');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0052','Conta Corrente Destino divergente da Proposta');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0053','Conta Pagamento Destino divergente da Proposta');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0054','Motivo de reprova��o fora do dom�nio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0055','Participante n�o pode cancelar a portabilidade');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0056','Portabilidade n�o pode ser cancelada');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0057','C�digo Autentica��o do Benefici�rio divergente da solicita��o');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0058','Campo Ag�ncia Cliente Relacionamento � obrigat�rio para Tipo Conta Relacionamento informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0059','Campo Ag�ncia Cliente Relacionamento n�o deve ser preenchido para o Tipo Conta Relacionamento inform');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0060','Campo Conta Corrente Relacionamento � obrigat�rio para Tipo Conta Relacionamento informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0061','Campo Conta Corrente Relacionamento n�o deve ser preenchido para o Tipo conta Relacionamento inform');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0062','Campo Conta Pagamento Relacionamento � obrigat�rio para Tipo Conta Relacionamento informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0063','Campo Conta Pagamento Relacionamento n�o deve ser preenchido para o Tipo Conta Relacionamento inform');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0064','C�digo de Autentica��o do Benefici�rio duplicado para o mesmo Participante Destino');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0065','Participante Relacionamento n�o aderiu a funcionalidade APCS104');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0066','Tipo de Conta Relacionamento n�o informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0067','Portabilidade em Aceite Compulsorio n�o pode ser respondida');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0068','Portabilidade Cancelada n�o pode ser respondida');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0069','Tamanho do dado inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0070','CNPJ Participante Folha Pagamento divergente do cadastro do Participante');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0071','CNPJ Participante Folha Pagamento divergente da solicita��o');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0072','CNPJ Participante Destino divergente do cadastro do Participante');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0073','CNPJ Participante Destino divergente da solicita��o');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0074','CNPJ Participante Relacionamento divergente do cadastro do Participante');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0075','Denomina��o Social do Empregador divergente da solicita��o');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0076','Campo Ag�ncia e Conta Destino n�o devem ser preenchidos para o Tipo conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0077','Campo Ag�ncia e Conta Destino s�o obrigat�rios para o Tipo conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0078','Campo Ag�ncia e Conta Relacionamento n�o devem ser preenchidos para o Tipo conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0079','Campo Ag�ncia e Conta Relacionamento s�o obrigat�rios para o Tipo conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0080','ISPB Participante Relacionamento divergente das 8 primeiras posi��es do CNPJ Particpante Relacionam.');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0081','ISPB Participante Relacionamento n�o pode ser igual ao ISPB Folha Pagamento');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0082','ISPB Participante Relacionamento n�o pode ser igual ao ISPB Participante Destino');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0083','CNPJ Participante Relacionamento inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0084','Motivo de contesta��o fora do dom�nio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0085','Participante Administrado n�o aderiu � funcionalidade APCS201');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0086','Participante Administrado Folha n�o aderiu a funcionalidade APCS202');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0087','Participante Principal n�o aderiu � funcionalidade APCS201');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0088','Participante Principal Folha n�o aderiu � funcionalidade APCS202');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0089','Situa��o da Portabilidade n�o permite contesta��o');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0090','Data da contesta��o fora do prazo');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0091','Participante Principal Folha n�o aderiu � funcionalidade APCS203');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0092','Limite de Contesta��es atingido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0093','N�o � poss�vel solicitar portabilidade, este DNA possui contesta��o em andamento');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0094','N�mero �nico da Contesta��o n�o existe no sistema');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0095','Motivo de Resposta de Contesta��o fora do dom�nio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0096','Data Resposta da contesta��o fora do prazo');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0097','Participante Administrado n�o aderiu � funcionalidade APCS301');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0098','Limite de Regulariza��es atingido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0099','Justificativa da Regulariza��o fora do dom�nio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0100','Motivo de regulariza��o fora do dom�nio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0101','Participante Principal n�o aderiu � funcionalidade APCS301');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0102','Participante Administrado Destino n�o aderiu � funcionalidade APCS302');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0103','Participante Principal Destino n�o aderiu � funcionalidade APCS302');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0104','Participante Administrado Destino n�o aderiu � funcionalidade APCS204');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0105','Participante Principal Destino n�o aderiu � funcionalidade APCS204');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0106','Participante Administrado Folha n�o aderiu � funcionalidade APCS203');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0107','NU Portabilidade Contestada n�o � permitido Regulariza��o');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0108','NU Portabilidade Regularizada n�o � permitida Contesta��o');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0109','NU Portabilidade Contestada n�o � a �ltima vigente no PCPS');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0110','NU Portabilidade Regularizada n�o � a �ltima registrada no PCPS');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0111','N�mero �nico da Portabilidade no PCS n�o est� registrado para o Participante Destino');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0112','Data da regulariza��o fora do prazo');
 
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGENPCPS','REJEITADO CIP');
  
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0001','XML Mal Formado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0004','ISPB Emissor N�o Informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0005','ISPB Emissor Inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0006','ISPB Emissor N�o Autorizado ao CODMSG Solicitado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0007','ISPB Emissor N�o Autorizado para a Fila Requerida');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0008','ISPB Destinat�rio N�o Informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0009','ISPB Destinat�rio N�o Confere com Destino');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0010','NuOP N�o Informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0011','NuOP j� Registrado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0012','NuOP N�o Confere com ISPB');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0013','NuOP Inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0016','Erro na Convers�o do C�digo');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0017','XML Inv�lido. Campo Obrigat�rio Ausente');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0018','XML Inv�lido. Campo N�o Faz Parte da Mensagem');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0019','Tipo ID Emissor Ausente/Inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0020','Tipo ID Destinat�rio Ausente/Inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0021','ISPB Emissora em Conting�ncia');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0022','Campo Obrigat�rio N�o Informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0023','Conte�do Inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0026','NUOp N�o Encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0027','Mensagem N�o Encontrada');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0028','Tipo de Retorno Inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0029','Nome do Arquivo N�o Tratado pelo Destinat�rio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0030','Nome do Arquivo Inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0031','Identificador do Arquivo Inv�lido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0032','Recep��o de Arquivo Fora do Hor�rio');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0033','Tipo de Transmiss�o Inv�lido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0034','XML Inv�lido. Formato deve ser Unicode UTF-16 BE');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0035','"Namespace" Inv�lido.');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0036','Dom�nio de Sistema Inv�lido.');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0037','Formato inv�lido de arquivo ZIP');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0041','Participante N�o Est� em Conting�ncia Integral');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0042','Existe Outro Arquivo Pendente de Confirma��o/Cancelamento na Data Movimento');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0043','XML Inv�lido - N�o Est� de Acordo com a Defini��o do XSD');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0046','Existe Outro Arquivo em Valida��o na Data-Movimento');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0047','Indicador Continuidade Inv�lido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0049','Quantidade de Repeti��o Inv�lida');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0050','Erro de Processamento');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0051','ISPB Emissor N�o Autorizado � Requisi��o do Arquivo');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0052','ISPB Emissor N�o Autorizado ao Envio do Arquivo');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0058','N�mero de telefone inv�lido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0059','Endere�o eletr�nico inv�lido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0079','Formato do Dado Inv�lido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0080','Tamanho do Dado Inv�lido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0152','Participante em Conting�ncia');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0153','ISPB Emissor Incompat�vel com ISPB Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1001','ISPB Inv�lido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1002','ISPB N�o Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1003','C�digo da Certificadora ou N�mero do Certificado a Inativar N�o Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1004','C�digo do Certificado a Ativar Igual a Zeros');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1005','C�digo do Certificado a Ativar N�o Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1006','Situa��o do Certificado N�o Informada');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1007','Situa��o do Certificado Inv�lida');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1009','Data Movimento Inv�lida');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1010','Data Movimento Diferente da Data de Processamento');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1011','Certificado/Cart�rio N�o Ativo');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1013','C�digo da Certificadora do Certificado a Inativar N�o Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1014','Certificado a Inativar N�o Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1015','Ativando um Certificado sem Desativar o que Est� Ativo');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1016','Data de Validade do Certif. a Ativar Menor que a Data Corrente');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1017','Certificado inv�lido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1018','N�o � permitido ativar o certificado antes da data estabelecida');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1055','Campos da Repeti��o Fora da Sequ�ncia ou N�o Existe Tag de Grupo');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1101','Valor N�o Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1102','Valor Inv�lido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1103','Chave de Seguran�a N�o Informada');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1104','Chave de Seguran�a Inv�lida');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1105','Tabelas de Conting�ncia Indispon�veis');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1106','N�meros Rand�micos Esgotados');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1107','Data Movimento N�o Informada');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9901','Tamanho do Cabe�alho de Seguran�a Zerado ou Incompat�vel c/os Poss�veis');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9902','Vers�o Inv�lida ou Incompat�vel com o Tamanho e/ou Conex�o');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9903','Algoritmo da Chave do Destinat�rio Inv�lido ou Divergente do Certificado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9904','Algoritmo Sim�trico Inv�lido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9905','Algoritmo da Chave de Assinatura Inv�lido ou Divergente do Certificado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9906','Algoritmo de "Hash" N�o Corresponde aos Indicados');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9907','C�digo da AC do Certificado do Destinat�rio Inv�lido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9908','N�mero de S�rie do Certificado Destino Inv�lido (N�o Foi Emitido pela AC)');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9909','C�digo da AC do Certificado de Assinatura Inv�lido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9910','N�mero S�rie do Certificado de Assinatura Inv�lido (N�o Foi Emitido p/AC)');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9911','Assinatura da Mensagem Inv�lida ou com Erro');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9912','Certificado N�o � do Emissor da Mensagem (Titular da Fila no MQ)');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9913','Erro na Extra��o da Chave Sim�trica');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9914','Erro Gerado pelo Algoritmo Sim�trico');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9915','Tamanho da Mensagem N�o M�ltiplo de 8 Bytes');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9916','Certificado Usado N�o Est� Ativado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9917','Certificado Usado Est� Revogado, Vencido ou Exclu�do pela Institui��o');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9918','Erro Gen�rico da Camada de Seguran�a');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9919','Indica��o de Uso Espec�fico Inv�lida ou Incompat�vel');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9920','Certificado Inv�lido (usar certificado "a ativar" na GEN0006)');
  ----------------------------------------------
  
	COMMIT;
  
END;
