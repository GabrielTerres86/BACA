CREATE OR REPLACE PACKAGE CECRED.INET_F8N AS

  /* Procedure para verificar horario permitido para transacoes */
  PROCEDURE pc_horario_operacao_f8n (pr_cdcooper IN crapcop.cdcooper%TYPE        --C¿digo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%type        --Agencia do Associado
                                     ,pr_tpoperac IN INTEGER                      --Tipo de Operacao (0=todos)
                                     ,pr_inpessoa IN crapass.inpessoa%type        --Tipo de Pessoa
                                     ,pr_tab_limite OUT CLOB        --XML de retorno de horarios limite
                                     ,pr_cdcritic   OUT INTEGER     --Código do erro
                                     ,pr_dscritic   OUT VARCHAR2);



END INET_F8N;
/
CREATE OR REPLACE PACKAGE BODY CECRED.INET_F8N AS

  PROCEDURE pc_horario_operacao_f8n (pr_cdcooper IN crapcop.cdcooper%TYPE        --C¿digo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%type        --Agencia do Associado
                                     ,pr_tpoperac IN INTEGER                      --Tipo de Operacao (0=todos)
                                     ,pr_inpessoa IN crapass.inpessoa%type        --Tipo de Pessoa
                                     ,pr_tab_limite OUT CLOB        --XML de retorno de horarios limite
                                     ,pr_cdcritic   OUT INTEGER     --Código do erro
                                     ,pr_dscritic   OUT VARCHAR2) IS

  BEGIN
	CECRED.inet0001.pc_horario_operacao_prog(pr_cdcooper, pr_cdagenci, pr_tpoperac, pr_inpessoa, pr_tab_limite, pr_cdcritic, pr_dscritic);
  END pc_horario_operacao_f8n;


END INET_F8N;
/
