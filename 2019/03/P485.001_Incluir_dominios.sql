BEGIN 
	
  -- Limpar os dominios para reinserção
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

  -- MOTIVOS DE REPROVAÇÃO DE PORTABILIDADE
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '1','CNPJ do Empregador não encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '2','CPF do Beneficiário não encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '3','CNPJ e CPF divergentes');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '5','Beneficiário não solicitou a portabilidade');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '6','Desistência do Cliente');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '7','Conta informada não permite transferência');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR', '9','Conta de pagamento benefício INSS');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR','10','Conta salário não aberta');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREPRVCPORTDDCTSALR','11','Falta de clareza na prestação da informação');

  -- MOTIVOS DE CONTESTAÇÃO
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVCONTTC', '1','Recurso enviado para conta divergente da informada na solicitação de portabilidade (TED Devolvida)');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVCONTTC', '2','Portabilidade aprovada, recurso não enviado');

  -- MOTIVOS DE REPOSTA DE CONTESTAÇÃO APROVADA
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCAPROVD', '1','Improcedente, resposta correta');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCAPROVD', '2','Improcedente, nova portabilidade registrada no Participante Folha de Pagamento');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCAPROVD', '3','Improcedente, não houve crédito de salário após portabilidade');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCAPROVD', '4','Procedente, correção de sistema interno');
  
  -- MOTIVOS DE REPOSTA DE CONTESTAÇÃO REPROVADA
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '1','CNPJ do Empregador não encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '2','CPF do Beneficiário não encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '3','CNPJ e CPF divergentes');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '5','Beneficiário não solicitou a portabilidade');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '6','Desistência do Cliente');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '7','Conta informada não permite transferência');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD',  '9','Conta pagamento benefício - INSS');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD', '10','Conta salário não aberta');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVRESPCONTTCREPVD', '11','Falta de clareza na prestação da informação');
  
  -- MOTIVO DE REGULARIZAÇÃO APROVADA
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCAPROVD', '1','Erro Operacional');
  
  -- MOTIVO DE REGULARIZAÇÃO REPROVADA
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '1','CNPJ do Empregador não encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '2','CPF do Beneficiário não encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '3','CNPJ e CPF divergentes');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '5','Beneficiário não solicitou a portabilidade');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '6','Desistência do Cliente');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '7','Conta informada não permite transferência');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD',  '9','Conta pagamento benefício - INSS');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD', '10','Conta salário não aberta');
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVREGLZCREPVD', '11','Falta de clareza na prestação da informação');

  -- MOTIVO DE ENCERRAMENTO DA CONTESTAÇÃO
  INSERT INTO tbcc_dominio_campo VALUES ('MOTVENCRMNTCONTTC', '1','Encerramento da Constestação por falta de resposta do Participante Folha');
  
  -- SITUAÇÃO DA CONTESTAÇÃO RECEBIDA
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_RECEBE', 1,'Pendente');
	
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_RECEBE', 2,'Aprovada');
	
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_RECEBE', 3,'Reprovada');
	
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_RECEBE', 4,'Fechada sem resposta');
  
  -- SITUAÇÃO DA CONTESTAÇÃO ENVIADA
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_ENVIA', 1,'Solicitada');
	
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_ENVIA', 2,'Contestada');
	
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_ENVIA', 3,'Contestação Aprovada');
	
	INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_ENVIA', 4,'Contestação Reprovada');
	
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_ENVIA', 5,'Fechada sem resposta');
  
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_CONTESTACAO_ENVIA', 6,'Contestação Rejeitada');
  
  -- SITUAÇÃO DAS REGULARIZAÇÕES
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_REGULARIZACAO', 1,'Solicitada');
  
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_REGULARIZACAO', 2,'Comunicada CIP');
  
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_REGULARIZACAO', 3,'Regularizado Aprovada');
  
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_REGULARIZACAO', 4,'Regularizado Reprovada');
  
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
	('SIT_PORTAB_REGULARIZACAO', 5,'Regularizado Rejeitada');
  
  -- INDICA A REGULARIZAÇÃO
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
  ('PORTAB_REGULARIZA_SIT' , 1, 'Aprovada');
  
  INSERT INTO tbcc_dominio_campo (nmdominio, cddominio, dscodigo) VALUES 
  ('PORTAB_REGULARIZA_SIT' , 2, 'Reprovada');
  
  ----------------------------------------------
    -- ERROS DE PROCESSAMENTOS
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0001','Portabilidade não encontrada');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0002','Portabilidade não permitida, solicitante é o Particpante Folha');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0003','Participante Principal não aderiu à funcionalidade APCS101');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0004','Participante Administrado não aderiu à funcionalidade APCS101');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0005','Participante Principal não aderiu à funcionalidade APCS102');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0006','Participante Administrado não aderiu a funcionalidade APCS102');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0007','Participante Principal não aderiu a funcionalidade APCS103');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0008','Participante Administrado não aderiu a funcionalidade APCS103');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0009','Participante Principal não aderiu a funcionalidade APCS104');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0010','Participante Administrado não aderiu a funcionalidade APCS104');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0011','Participante Administrado não aderiu a funcionalidade APCS105');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0012','Data Referência inválida');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0013','CPF inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0014','CNPJ inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0015','Arquivo fora de Grade Horária');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0016','Instituição não participante do PCS');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0017','Portabilidade em andamento');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0018','Número Único da Portabilidade no PCS inválido ou não encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0019','Data deve ser igual à data atual');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0020','Tipo de conta fora do domínio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0022','Participante Administrado não é administrado pelo Participante Principal');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0023','Não é possível solicitar portabilidade para o mesmo DNA (CPF/CNPJ Empregador/ISPB Folha)');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0024','Portabilidade não enviada para Instituição que está respondendo');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0025','Portabilidade já respondida');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0026','Portabilidade cancelada');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0027','Motivo de cancelamento inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0031','Nome do Arquivo Duplicado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0035','Campo Conta Pagamento Destino é obrigatório para Tipo Conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0036','Campo Conta Pagamento Destino não deve ser preenchido para o Tipo Conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0037','Campo Conta Destino é obrigatório para Tipo Conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0038','Campo Conta Destino nâo deve ser preenchido para o Tipo conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0039','ISPB informado diferente do solicitante do arquivo');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0040','Campo Agência Destino é obrigatório para Tipo Conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0041','Campo Agência Destino não deve ser preenchido para o Tipo conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0042','Portabilidade em decurso de prazo não pode ser respondida');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0043','CPF Cliente informado, divergente da proposta original');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0044','Nome Cliente divergente da solicitação');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0045','Telefone Cliente divergente da solicitação');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0046','Email Cliente divergente da solicitação');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0047','ISPB Folha de Pagamento divergente da solicitação');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0048','CNPJ do Empregador divergente da solicitação');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0049','ISPB Participante Destino divergente da Proposta');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0050','Tipo de Conta divergente da Proposta');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0051','Agência Destino divergente da Proposta');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0052','Conta Corrente Destino divergente da Proposta');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0053','Conta Pagamento Destino divergente da Proposta');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0054','Motivo de reprovação fora do domínio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0055','Participante não pode cancelar a portabilidade');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0056','Portabilidade não pode ser cancelada');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0057','Código Autenticação do Beneficiário divergente da solicitação');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0058','Campo Agência Cliente Relacionamento é obrigatório para Tipo Conta Relacionamento informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0059','Campo Agência Cliente Relacionamento não deve ser preenchido para o Tipo Conta Relacionamento inform');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0060','Campo Conta Corrente Relacionamento é obrigatório para Tipo Conta Relacionamento informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0061','Campo Conta Corrente Relacionamento não deve ser preenchido para o Tipo conta Relacionamento inform');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0062','Campo Conta Pagamento Relacionamento é obrigatório para Tipo Conta Relacionamento informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0063','Campo Conta Pagamento Relacionamento não deve ser preenchido para o Tipo Conta Relacionamento inform');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0064','Código de Autenticação do Beneficiário duplicado para o mesmo Participante Destino');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0065','Participante Relacionamento não aderiu a funcionalidade APCS104');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0066','Tipo de Conta Relacionamento não informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0067','Portabilidade em Aceite Compulsorio não pode ser respondida');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0068','Portabilidade Cancelada não pode ser respondida');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0069','Tamanho do dado inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0070','CNPJ Participante Folha Pagamento divergente do cadastro do Participante');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0071','CNPJ Participante Folha Pagamento divergente da solicitação');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0072','CNPJ Participante Destino divergente do cadastro do Participante');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0073','CNPJ Participante Destino divergente da solicitação');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0074','CNPJ Participante Relacionamento divergente do cadastro do Participante');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0075','Denominação Social do Empregador divergente da solicitação');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0076','Campo Agência e Conta Destino não devem ser preenchidos para o Tipo conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0077','Campo Agência e Conta Destino são obrigatórios para o Tipo conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0078','Campo Agência e Conta Relacionamento não devem ser preenchidos para o Tipo conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0079','Campo Agência e Conta Relacionamento são obrigatórios para o Tipo conta informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0080','ISPB Participante Relacionamento divergente das 8 primeiras posições do CNPJ Particpante Relacionam.');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0081','ISPB Participante Relacionamento não pode ser igual ao ISPB Folha Pagamento');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0082','ISPB Participante Relacionamento não pode ser igual ao ISPB Participante Destino');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0083','CNPJ Participante Relacionamento inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0084','Motivo de contestação fora do domínio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0085','Participante Administrado não aderiu à funcionalidade APCS201');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0086','Participante Administrado Folha não aderiu a funcionalidade APCS202');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0087','Participante Principal não aderiu à funcionalidade APCS201');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0088','Participante Principal Folha não aderiu à funcionalidade APCS202');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0089','Situação da Portabilidade não permite contestação');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0090','Data da contestação fora do prazo');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0091','Participante Principal Folha não aderiu à funcionalidade APCS203');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0092','Limite de Contestações atingido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0093','Não é possível solicitar portabilidade, este DNA possui contestação em andamento');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0094','Número Único da Contestação não existe no sistema');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0095','Motivo de Resposta de Contestação fora do domínio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0096','Data Resposta da contestação fora do prazo');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0097','Participante Administrado não aderiu à funcionalidade APCS301');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0098','Limite de Regularizações atingido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0099','Justificativa da Regularização fora do domínio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0100','Motivo de regularização fora do domínio');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0101','Participante Principal não aderiu à funcionalidade APCS301');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0102','Participante Administrado Destino não aderiu à funcionalidade APCS302');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0103','Participante Principal Destino não aderiu à funcionalidade APCS302');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0104','Participante Administrado Destino não aderiu à funcionalidade APCS204');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0105','Participante Principal Destino não aderiu à funcionalidade APCS204');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0106','Participante Administrado Folha não aderiu à funcionalidade APCS203');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0107','NU Portabilidade Contestada não é permitido Regularização');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0108','NU Portabilidade Regularizada não é permitida Contestação');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0109','NU Portabilidade Contestada não é a última vigente no PCPS');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0110','NU Portabilidade Regularizada não é a última registrada no PCPS');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0111','Número Único da Portabilidade no PCS não está registrado para o Participante Destino');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0112','Data da regularização fora do prazo');
 
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGENPCPS','REJEITADO CIP');
  
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0001','XML Mal Formado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0004','ISPB Emissor Não Informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0005','ISPB Emissor Inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0006','ISPB Emissor Não Autorizado ao CODMSG Solicitado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0007','ISPB Emissor Não Autorizado para a Fila Requerida');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0008','ISPB Destinatário Não Informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0009','ISPB Destinatário Não Confere com Destino');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0010','NuOP Não Informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0011','NuOP já Registrado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0012','NuOP Não Confere com ISPB');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0013','NuOP Inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0016','Erro na Conversão do Código');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0017','XML Inválido. Campo Obrigatório Ausente');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0018','XML Inválido. Campo Não Faz Parte da Mensagem');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0019','Tipo ID Emissor Ausente/Inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0020','Tipo ID Destinatário Ausente/Inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0021','ISPB Emissora em Contingência');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0022','Campo Obrigatório Não Informado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0023','Conteúdo Inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0026','NUOp Não Encontrado');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0027','Mensagem Não Encontrada');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0028','Tipo de Retorno Inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0029','Nome do Arquivo Não Tratado pelo Destinatário');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0030','Nome do Arquivo Inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0031','Identificador do Arquivo Inválido');
  INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0032','Recepção de Arquivo Fora do Horário');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0033','Tipo de Transmissão Inválido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0034','XML Inválido. Formato deve ser Unicode UTF-16 BE');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0035','"Namespace" Inválido.');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0036','Domínio de Sistema Inválido.');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0037','Formato inválido de arquivo ZIP');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0041','Participante Não Está em Contingência Integral');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0042','Existe Outro Arquivo Pendente de Confirmação/Cancelamento na Data Movimento');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0043','XML Inválido - Não Está de Acordo com a Definição do XSD');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0046','Existe Outro Arquivo em Validação na Data-Movimento');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0047','Indicador Continuidade Inválido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0049','Quantidade de Repetição Inválida');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0050','Erro de Processamento');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0051','ISPB Emissor Não Autorizado à Requisição do Arquivo');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0052','ISPB Emissor Não Autorizado ao Envio do Arquivo');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0058','Número de telefone inválido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0059','Endereço eletrônico inválido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0079','Formato do Dado Inválido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0080','Tamanho do Dado Inválido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0152','Participante em Contingência');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN0153','ISPB Emissor Incompatível com ISPB Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1001','ISPB Inválido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1002','ISPB Não Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1003','Código da Certificadora ou Número do Certificado a Inativar Não Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1004','Código do Certificado a Ativar Igual a Zeros');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1005','Código do Certificado a Ativar Não Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1006','Situação do Certificado Não Informada');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1007','Situação do Certificado Inválida');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1009','Data Movimento Inválida');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1010','Data Movimento Diferente da Data de Processamento');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1011','Certificado/Cartório Não Ativo');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1013','Código da Certificadora do Certificado a Inativar Não Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1014','Certificado a Inativar Não Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1015','Ativando um Certificado sem Desativar o que Está Ativo');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1016','Data de Validade do Certif. a Ativar Menor que a Data Corrente');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1017','Certificado inválido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1018','Não é permitido ativar o certificado antes da data estabelecida');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1055','Campos da Repetição Fora da Sequência ou Não Existe Tag de Grupo');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1101','Valor Não Informado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1102','Valor Inválido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1103','Chave de Segurança Não Informada');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1104','Chave de Segurança Inválida');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1105','Tabelas de Contingência Indisponíveis');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1106','Números Randômicos Esgotados');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN1107','Data Movimento Não Informada');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9901','Tamanho do Cabeçalho de Segurança Zerado ou Incompatível c/os Possíveis');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9902','Versão Inválida ou Incompatível com o Tamanho e/ou Conexão');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9903','Algoritmo da Chave do Destinatário Inválido ou Divergente do Certificado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9904','Algoritmo Simétrico Inválido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9905','Algoritmo da Chave de Assinatura Inválido ou Divergente do Certificado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9906','Algoritmo de "Hash" Não Corresponde aos Indicados');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9907','Código da AC do Certificado do Destinatário Inválido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9908','Número de Série do Certificado Destino Inválido (Não Foi Emitido pela AC)');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9909','Código da AC do Certificado de Assinatura Inválido');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9910','Número Série do Certificado de Assinatura Inválido (Não Foi Emitido p/AC)');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9911','Assinatura da Mensagem Inválida ou com Erro');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9912','Certificado Não é do Emissor da Mensagem (Titular da Fila no MQ)');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9913','Erro na Extração da Chave Simétrica');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9914','Erro Gerado pelo Algoritmo Simétrico');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9915','Tamanho da Mensagem Não Múltiplo de 8 Bytes');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9916','Certificado Usado Não Está Ativado');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9917','Certificado Usado Está Revogado, Vencido ou Excluído pela Instituição');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9918','Erro Genérico da Camada de Segurança');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9919','Indicação de Uso Específico Inválida ou Incompatível');
	INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EGEN9920','Certificado Inválido (usar certificado "a ativar" na GEN0006)');
  ----------------------------------------------
  
	COMMIT;
  
END;
