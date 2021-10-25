DECLARE
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
BEGIN
  FOR rw_crapcop IN cr_crapcop LOOP
    INSERT INTO crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
    VALUES ('CRED',rw_crapcop.cdcooper,'RENEGOCIACAO_DIGITAL','Código para pendência de digitalização de renegociações digitais','294');
    --
    INSERT INTO crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
    VALUES ('CRED',rw_crapcop.cdcooper,'TRAN_CCB_ADI_DIR_FTP','Diretorio do servidor FTP do Smartshare para renegociações digitais','Agilidade_Aditivos');  
  END LOOP;
  COMMIT;
END;
