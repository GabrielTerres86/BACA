BEGIN
  /************/
  /* ENDERE�O */
  /************/
  ALTER TABLE CECRED.TBCADAST_PESSOA_ENDERECO ADD statusrevis�o NUMBER(1) DEFAULT(0);
  COMMENT ON COLUMN CECRED.TBCADAST_PESSOA_ENDERECO.statusrevis�o IS 'Status Revis�o: 1 - Confirmado, 2 - N�o Confirmado';
  
  /**********************/
	/*  RENDA E EMPRESA   */
	/**********************/
	ALTER TABLE CECRED.TBCADAST_PESSOA_RENDA ADD statusrevisao_renda NUMBER(1) DEFAULT(0);
  ALTER TABLE CECRED.TBCADAST_PESSOA_RENDA ADD statusrevisao_empresa NUMBER(1) DEFAULT(0);
  COMMENT ON COLUMN CECRED.TBCADAST_PESSOA_ENDERECO.statusrevisao_renda IS 'Status Revis�o Renda: 1 - Confirmado, 2 - N�o Confirmado';
  COMMENT ON COLUMN CECRED.TBCADAST_PESSOA_ENDERECO.statusrevisao_empresa IS 'Status Revis�o Empresa: 1 - Confirmado, 2 - N�o Confirmado';
  
  COMMIT;
END;
