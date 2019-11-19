BEGIN
	
  -- ERRO: EPCS0113  Situa��o da Portabilidade n�o permite regulariza��o
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0113','Situa��o da Portabilidade n�o permite regulariza��o');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
  END;
  
	-- ERRO: EPCS0114  Situa��o da Portabilidade informada n�o permite resposta da contesta��o
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0114','Situa��o da Portabilidade informada n�o permite resposta da contesta��o');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
  END;
  
	-- ERRO: EPCS0115  N�mero �nico da Portabilidade PCS n�o est� registrado para o Participante Folha
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0115','N�mero �nico da Portabilidade PCS n�o est� registrado para o Participante Folha');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
  END;
  
	-- ERRO: EPCS0116  CNPJ/CPF do Empregador inv�lido
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0116','CNPJ/CPF do Empregador inv�lido');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
  END;
  
	-- ERRO: EPCS0117  Tipo de Pessoa Empregador fora de dom�nio
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0117','Tipo de Pessoa Empregador fora de dom�nio');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
  END;
  
	-- ERRO: EPCS0118  Tipo de Pessoa Empregador divergente da solicita��o
	BEGIN
    INSERT INTO tbcc_dominio_campo VALUES ('ERRO_PCPS_CIP', 'EPCS0118','Tipo de Pessoa Empregador divergente da solicita��o');
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
