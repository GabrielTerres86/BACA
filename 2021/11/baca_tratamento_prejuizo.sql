DECLARE
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  vr_dstratar VARCHAR2(100) := '502049;10014825;04/08/2021|'; -- Adicionar tratamento para a conta  | separador 1 e ; separador 2
BEGIN

  -- PRM
  FOR rw_crapcop IN cr_crapcop LOOP
    
    INSERT INTO crapprm
      (nmsistem,
       cdcooper,
       cdacesso,
       dstexprm,
       dsvlrprm)
    VALUES
      ('CRED',
       rw_crapcop.cdcooper,
       'PREJUIZO_EXCECAO',
       'Contas com excecoes exclusivas a serem tratadas em fontes especificos EMPR0001 e EXTR0002',
       CASE rw_crapcop.cdcooper WHEN 9 THEN vr_dstratar ELSE '' END);
       
  END LOOP;
  
  COMMIT;
END;

