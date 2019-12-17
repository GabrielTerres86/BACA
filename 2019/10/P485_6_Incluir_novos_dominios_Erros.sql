BEGIN
	
  -- ERRO: EPCS0113  Situação da Portabilidade não permite regularização
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0113','Situação da Portabilidade não permite regularização');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
  END;
  
	-- ERRO: EPCS0114  Situação da Portabilidade informada não permite resposta da contestação
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0114','Situação da Portabilidade informada não permite resposta da contestação');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
  END;
  
	-- ERRO: EPCS0115  Número Único da Portabilidade PCS não está registrado para o Participante Folha
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0115','Número Único da Portabilidade PCS não está registrado para o Participante Folha');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
  END;
  
	-- ERRO: EPCS0116  CNPJ/CPF do Empregador inválido
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0116','CNPJ/CPF do Empregador inválido');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
  END;
  
	-- ERRO: EPCS0117  Tipo de Pessoa Empregador fora de domínio
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0117','Tipo de Pessoa Empregador fora de domínio');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
  END;
  
	-- ERRO: EPCS0118  Tipo de Pessoa Empregador divergente da solicitação
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0118','Tipo de Pessoa Empregador divergente da solicitação');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
  END;
  
	-- ERRO: EPCS0119  CNPJ/CPF do Empregador com tamanho incorreto
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0119','CNPJ/CPF do Empregador com tamanho incorreto');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
  END;
  
	COMMIT;
  
END;
