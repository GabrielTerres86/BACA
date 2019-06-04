CREATE OR REPLACE PACKAGE CECRED.cada_f8n IS

  -- Rotina para retorno de ID pessoa passando como parametro o CPF / CNPJ
  PROCEDURE pc_retorna_IdPessoa_f8n(pr_nrcpfcgc IN  NUMBER -- Numero do CPF / CNPJ
                               ,pr_idpessoa OUT NUMBER -- Registro de pessoa
													   	 ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para retorno de email
  PROCEDURE pc_retorna_pessoa_email_f8n(pr_idpessoa IN NUMBER -- Registro de bens
                                   ,pr_retorno  OUT xmltype -- XML de retorno
                                   ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para retorno de endereço
  PROCEDURE pc_retorna_pessoa_endereco_f8n(pr_idpessoa IN NUMBER -- Registro de bens
                                      ,pr_retorno  OUT xmltype -- XML de retorno
                                      ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro

END cada_f8n;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cada_f8n IS
  -- Rotina para retorno de ID pessoa passando como parametro o CPF / CNPJ
  PROCEDURE pc_retorna_IdPessoa_f8n(pr_nrcpfcgc IN  NUMBER -- Numero do CPF / CNPJ
                               ,pr_idpessoa OUT NUMBER -- Registro de pessoa
													   	 ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro

  BEGIN
    CECRED.cada0012.pc_retorna_IdPessoa(pr_nrcpfcgc, pr_idpessoa, pr_dscritic);
  END pc_retorna_IdPessoa_f8n;


  -- Rotina para retorno de email
  PROCEDURE pc_retorna_pessoa_email_f8n(pr_idpessoa IN NUMBER -- Registro de e-mail
                                   ,pr_retorno  OUT xmltype -- XML de retorno
                                   ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro

  BEGIN
	CECRED.cada0012.pc_retorna_pessoa_email(pr_idpessoa, pr_retorno, pr_dscritic);
  END pc_retorna_pessoa_email_f8n;

  -- Rotina para retorno de endereço
  PROCEDURE pc_retorna_pessoa_endereco_f8n(pr_idpessoa IN NUMBER -- Registro de endereço
                                      ,pr_retorno  OUT xmltype -- XML de retorno
                                      ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
  BEGIN
    CECRED.cada0012.pc_retorna_pessoa_endereco(pr_idpessoa, pr_retorno, pr_dscritic);
  END pc_retorna_pessoa_endereco_f8n;

END cada_f8n;
/
