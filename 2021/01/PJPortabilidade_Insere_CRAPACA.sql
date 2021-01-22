/**************************************************************************************************************
Projeto Portabilidade
05/10/2020 - Inserir Mensageria (CRAPACA) para Aprovação da Portabilidade do Cheque Especial.
13/10/2020 - Inserir Mensageria (CRAPACA) para Impressão do Extrado da Portabilidade do Cheque Especial.
30/10/2020 - Alterar Mensageria (CRAPACA) para Validação Natureza Jurídica da Portabilidade de Capital de Giro.
03/11/2020 - Inserir Mensageria (CRAPACA) para Impressão do Termo da Portabilidade do Cheque Especial.
11/11/2020 - Inserir Mensageria (CRAPACA) para Cadastro da Portabilidade do Cheque Especial.
12/11/2020 - Inserir Mensageria (CRAPACA) para Validação da Portabilidade do Cheque Especial.
19/11/2020 - Inserir Mensageria (CRAPACA) para Consulta da Portabilidade do Cheque Especial.
20/11/2020 - Inserir Mensageria (CRAPACA) para Verificar Existencia de Portabilidade do Cheque Especial.
**************************************************************************************************************/
BEGIN
  --Insere CRAPACA
  INSERT INTO crapaca
     (nrseqaca 
     ,nmdeacao 
     ,nmpackag 
     ,nmproced 
     ,lstparam 
     ,nrseqrdr)
  VALUES
     (NULL
     ,'PORTAB_CHQESP_APRV'
     ,NULL
     ,'CREDITO.aprovarPortabCheqEsp'
     ,'pr_nrdconta,pr_nrctrlim,pr_nrunico_portabilidade'
     ,203);
  --Salva 
  COMMIT;
  
  
  --Insere CRAPACA
  INSERT INTO crapaca
     (nrseqaca 
     ,nmdeacao 
     ,nmpackag 
     ,nmproced 
     ,lstparam 
     ,nrseqrdr)
  VALUES
     (NULL
     ,'PORTAB_CHQESP_EXTR'
     ,NULL
     ,'CREDITO.imprimirExtrPortabCheqEsp'
     ,'pr_cdcooper,pr_nrdconta,pr_nrctrlim'
     ,203);
  --Salva 
  COMMIT;
  
  
  --Altera CRAPACA
  UPDATE crapaca
  SET    lstparam = 'pr_operacao, pr_nrcnpjbase_if_origem, pr_nmif_origem, pr_nrcontrato_if_origem, pr_cdmodali, pr_nrdconta, pr_inpessoa'
  WHERE  nmdeacao = 'VAL_PORTAB';
  --Salva 
  COMMIT;
  
  
  --Insere CRAPACA
  INSERT INTO crapaca
     (nrseqaca 
     ,nmdeacao 
     ,nmpackag 
     ,nmproced 
     ,lstparam 
     ,nrseqrdr)
  VALUES
     (NULL
     ,'PORTAB_CHQESP_TERMO'
     ,NULL
     ,'CREDITO.imprimirTermoPortabCheqEsp'
     ,'pr_nrdconta,pr_nrctrlim'
     ,203);
  --Salva 
  COMMIT;
  
  
  --Insere CRAPACA
  INSERT INTO crapaca
     (nrseqaca 
     ,nmdeacao 
     ,nmpackag 
     ,nmproced 
     ,lstparam 
     ,nrseqrdr)
  VALUES
     (NULL
     ,'CAD_PORTAB_CHEQESP'
     ,NULL
     ,'CREDITO.cadastrarPortabCheqEsp'
     ,'pr_cdcooper, pr_nrdconta, pr_nrctrlim, pr_tpoperacao, pr_nrcnpjbase_if_origem, pr_nmif_origem, pr_nrcontrato_if_origem, pr_tpctacli, pr_nragenci, pr_nrctacor, pr_nrctapag, pr_inctacjs'
     ,203);
  --Salva 
  COMMIT;
  
  
  --Insere CRAPACA
  INSERT INTO crapaca
     (nrseqaca 
     ,nmdeacao 
     ,nmpackag 
     ,nmproced 
     ,lstparam 
     ,nrseqrdr)
  VALUES
     (NULL
     ,'VAL_PORTAB_CHEQESP'
     ,NULL
     ,'CREDITO.validarPortabCheqEsp'
     ,'pr_operacao, pr_nrcnpjbase_if_origem, pr_nmif_origem, pr_nrcontrato_if_origem, pr_cdmodali, pr_tpctacli, pr_nragenci, pr_nrctacor, pr_nrctapag, pr_inctacjs'    
     ,203);
  --Salva 
  COMMIT;
  
  --Insere CRAPACA
  INSERT INTO crapaca
     (nrseqaca 
     ,nmdeacao 
     ,nmpackag 
     ,nmproced 
     ,lstparam 
     ,nrseqrdr)
  VALUES
     (NULL
     ,'CON_PORTAB_CHEQESP'
     ,NULL
     ,'CREDITO.consultarPortabCheqEsp'
     ,'pr_cdcooper, pr_nrdconta, pr_nrctrlim, pr_tipo_consulta'
     ,203);
  --Salva 
  COMMIT;
  
  --Insere CRAPACA
  INSERT INTO crapaca
     (nrseqaca 
     ,nmdeacao 
     ,nmpackag 
     ,nmproced 
     ,lstparam 
     ,nrseqrdr)
  VALUES
     (NULL
     ,'VER_PORTAB_CHEQESP'
     ,NULL
     ,'CREDITO.verificarPortabCheqEsp'
     ,'pr_cdcooper, pr_nrdconta, pr_nrctrlim'
     ,203);
  --Salva 
  COMMIT;

END;
/
