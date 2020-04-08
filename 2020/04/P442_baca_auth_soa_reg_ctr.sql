
BEGIN
  DECLARE
    CURSOR cr_crapcop IS
      SELECT cdcooper
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
         '07057169965');
    
      INSERT INTO crapprm
        (NMSISTEM,
         CDCOOPER,
         CDACESSO,
         DSTEXPRM,
         DSVLRPRM)
      VALUES
        ('CRED',
         rw_crapcop.cdcooper,
         'SENHA_AUTH_REG_CTR_SC',
         'Senha SOA para registros de contratos pc_busca_autenticacao_reg_ctr',
         'ailos2019sc');
    
      INSERT INTO crapprm
        (NMSISTEM,
         CDCOOPER,
         CDACESSO,
         DSTEXPRM,
         DSVLRPRM)
      VALUES
        ('CRED',
         rw_crapcop.cdcooper,
         'SENHA_AUTH_REG_CTR_PR',
         'Senha SOA para registros de contratos pc_busca_autenticacao_reg_ctr',
         'ailos2019');
    
    END LOOP;
    INSERT INTO crapprm
      (NMSISTEM,
       CDCOOPER,
       CDACESSO,
       DSTEXPRM,
       DSVLRPRM)
    VALUES
      ('CRED',
       0,
       'USUARIO_AUTH_REG_CTR',
       'Usuario SOA para registros de contratos pc_busca_autenticacao_reg_ctr',
       '07057169965');
  
    INSERT INTO crapprm
      (NMSISTEM,
       CDCOOPER,
       CDACESSO,
       DSTEXPRM,
       DSVLRPRM)
    VALUES
      ('CRED',
       0,
       'SENHA_AUTH_REG_CTR_SC',
       'Senha SOA para registros de contratos pc_busca_autenticacao_reg_ctr',
       'ailos2019sc');
  
    INSERT INTO crapprm
      (NMSISTEM,
       CDCOOPER,
       CDACESSO,
       DSTEXPRM,
       DSVLRPRM)
    VALUES
      ('CRED',
       0,
       'SENHA_AUTH_REG_CTR_PR',
       'Senha SOA para registros de contratos pc_busca_autenticacao_reg_ctr',
       'ailos2019');
  END;
END;
