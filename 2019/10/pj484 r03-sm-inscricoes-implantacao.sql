DECLARE

BEGIN

  BEGIN
    INSERT INTO CRAPPRM
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES
      ('CRED',
       0,
       'DIR_INTEGRA_INTELIX',
       'Diret�rio padr�o para integra��o dos arquivos intelix',
       'intelix');
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
  END;

  BEGIN
    INSERT INTO CRAPPRM
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES
      ('CRED', 
       0, 
       'COLUNAS_INTEGRA_INTELIX', 
       'Posi��o das colunas no arquivo exportado pela Intelix', 
       'CPF_CNPJ:6;Status_1:3;Status_2:29;ID_Evento:4;Nome:1;Telefone:23;Atendente:28');
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
  END;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    CECRED.PC_INTERNAL_EXCEPTION;
    ROLLBACK;
	
END;
