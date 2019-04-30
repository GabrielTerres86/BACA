BEGIN
  /************/
  /* ENDEREÇO */
  /************/
  ALTER TABLE CECRED.TBCADAST_PESSOA_ENDERECO ADD statusrevisão NUMBER(1) DEFAULT(0);
  COMMENT ON COLUMN CECRED.TBCADAST_PESSOA_ENDERECO.statusrevisão IS 'Status Revisão: 1 - Confirmado, 2 - Não Confirmado';
  
  /**********************/
	/*  RENDA E EMPRESA   */
	/**********************/
	ALTER TABLE CECRED.TBCADAST_PESSOA_RENDA ADD statusrevisao_renda NUMBER(1) DEFAULT(0);
  ALTER TABLE CECRED.TBCADAST_PESSOA_RENDA ADD statusrevisao_empresa NUMBER(1) DEFAULT(0);
  COMMENT ON COLUMN CECRED.TBCADAST_PESSOA_ENDERECO.statusrevisao_renda IS 'Status Revisão Renda: 1 - Confirmado, 2 - Não Confirmado';
  COMMENT ON COLUMN CECRED.TBCADAST_PESSOA_ENDERECO.statusrevisao_empresa IS 'Status Revisão Empresa: 1 - Confirmado, 2 - Não Confirmado';
  
  COMMIT;
END;
