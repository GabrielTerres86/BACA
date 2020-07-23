
BEGIN
  DECLARE
    CURSOR cr_crapcop IS
      SELECT cdcooper
           , LPAD(nrdocnpj,14,'0') nrdocnpj_str
        FROM crapcop
       WHERE flgativo = 1;
  
  BEGIN
  
    FOR rw_crapcop IN cr_crapcop LOOP
      INSERT INTO crapprm
        (NMSISTEM,
         CDCOOPER,
         CDACESSO,
         DSTEXPRM,
         DSVLRPRM)
      VALUES
        ('CRED',
         rw_crapcop.cdcooper,
         'USUARIO_AUTH_REG_CTR',
         'Usuario SOA para registros de contratos pc_busca_autenticacao_reg_ctr',
         rw_crapcop.nrdocnpj_str);
    
    
      INSERT INTO crapprm
        (NMSISTEM,
         CDCOOPER,
         CDACESSO,
         DSTEXPRM,
         DSVLRPRM)
      VALUES
        ('CRED',
         rw_crapcop.cdcooper,
         'SENHA_AUTH_REG_CTR',
         'Senha SOA para registros de contratos pc_busca_autenticacao_reg_ctr',
         'Ailos2020');
    
    END LOOP;
  COMMIT;
  END;
END;
