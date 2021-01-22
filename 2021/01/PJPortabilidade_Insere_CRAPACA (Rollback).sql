/**************************************************************************************************************
Projeto Portabilidade (Script Rollback)
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
  DELETE crapaca
  WHERE  nmdeacao = 'PORTAB_CHQESP_APRV'; 
  
  COMMIT;
  
  DELETE crapaca
  WHERE  nmdeacao = 'PORTAB_CHQESP_EXTR';
   
  COMMIT;
   
  UPDATE crapaca
  SET    lstparam = 'pr_operacao, pr_nrcnpjbase_if_origem, pr_nmif_origem, pr_nrcontrato_if_origem, pr_cdmodali'
  WHERE  nmdeacao = 'VAL_PORTAB';
 
  COMMIT;
  
  DELETE crapaca
  WHERE  nmdeacao = 'PORTAB_CHQESP_TERMO';
   
  COMMIT;

  DELETE crapaca
  WHERE  nmdeacao = 'CAD_PORTAB_CHEQESP';

  COMMIT;
  
  DELETE crapaca
  WHERE  nmdeacao = 'VAL_PORTAB_CHEQESP';

  COMMIT;
  
  DELETE crapaca
  WHERE  nmdeacao = 'CON_PORTAB_CHEQESP';
   
  COMMIT;
  
  DELETE crapaca
  WHERE  nmdeacao = 'VER_PORTAB_CHEQESP';
  
  COMMIT;

END;
/
