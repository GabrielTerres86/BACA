BEGIN
  /************/
  /* ENDEREÇO */
  /************/
  ALTER TABLE CECRED.TBCADAST_PESSOA_ENDERECO ADD statusrevisao NUMBER(1) DEFAULT(0);
  COMMENT ON COLUMN CECRED.TBCADAST_PESSOA_ENDERECO.statusrevisao IS 'Status Revisão (Dominio:TBCADAST_DOMINIO_CAMPO)';
  
  /**********************/
  /*  RENDA E EMPRESA   */
  /**********************/
  ALTER TABLE CECRED.TBCADAST_PESSOA_RENDA ADD statusrevisao_renda NUMBER(1) DEFAULT(0);
  ALTER TABLE CECRED.TBCADAST_PESSOA_RENDA ADD statusrevisao_empresa NUMBER(1) DEFAULT(0);
  COMMENT ON COLUMN CECRED.TBCADAST_PESSOA_ENDERECO.statusrevisao_renda IS 'Status Revisão Renda (Dominio:TBCADAST_DOMINIO_CAMPO)';
  COMMENT ON COLUMN CECRED.TBCADAST_PESSOA_ENDERECO.statusrevisao_empresa IS 'Status Revisão Empresa (Dominio:TBCADAST_DOMINIO_CAMPO)';
  
  /************************************/
  /*  INSERT DOMINIO STATUS REVISÃO   */
  /************************************/
  INSERT INTO TBCADAST_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO) VALUES ('TBCADAST_STATUSREVISAO', 1, 'Confirmado');
  INSERT INTO TBCADAST_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO) VALUES ('TBCADAST_STATUSREVISAO', 2, 'Não confirmado'); 
  
  COMMIT;
END;
