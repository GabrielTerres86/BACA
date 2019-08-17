DECLARE

  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1;
  
  CURSOR cr_crapope IS 
    SELECT ope.cdoperad, 
           ope.cdcooper 
      FROM crapope ope 
     WHERE UPPER(ope.cdoperad) LIKE UPPER('f%')
		   AND ope.cdsitope = 1
       AND ope.cdoperad NOT IN ('f0030519'
                               ,'f0031749'
                               ,'f0031849'
                               ,'f0031296'
                               ,'f0030947'
                               ,'f0032397'
                               ,'f0030641');

  -- Variável de críticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(10000);
  vr_exc_saida     EXCEPTION;
  vr_qtdsuces      INTEGER := 0;
  vr_qtderror      INTEGER := 0;
  
BEGIN
  
  --Limpa registros
  DELETE FROM crapace ace WHERE ace.nmdatela = 'PARECC';
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
    -- Opção '@'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', '@', 'f0030519', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', '@', 'f0031749', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', '@', 'f0031849', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', '@', 'f0031296', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', '@', 'f0030947', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', '@', 'f0032397', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', '@', 'f0030641', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    
    -- Opção 'A'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'A', 'f0030519', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'A', 'f0031749', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'A', 'f0031849', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'A', 'f0031296', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'A', 'f0030947', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'A', 'f0032397', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'A', 'f0030641', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    
    -- Opção 'C'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'C', 'f0030519', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'C', 'f0031749', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'C', 'f0031849', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'C', 'f0031296', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'C', 'f0030947', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'C', 'f0032397', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('PARECC', 'C', 'f0030641', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    
  END LOOP;
  
  FOR row_ope IN cr_crapope LOOP
  BEGIN
    
    -- Opção '@'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES ('PARECC', '@', row_ope.cdoperad, ' ', row_ope.cdcooper, 1, 1, 2);
    
    -- Opção 'C'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES ('PARECC', 'C', row_ope.cdoperad, ' ', row_ope.cdcooper, 1, 1, 2);
    
    vr_qtdsuces := vr_qtdsuces + 1;
    
    EXCEPTION  -- exception handlers begin
      WHEN OTHERS THEN  -- handles all other errors
      vr_dscritic := 'Erro ao criar a permissão para o Operador: ' || row_ope.cdoperad || ', Error: (' || SQLERRM || ');';
      vr_qtderror := vr_qtderror + 1;
    END;
    
  END LOOP;
  
  COMMIT;
  
  dbms_output.put_line('Qtd de Sucesso: ' || vr_qtdsuces);
  dbms_output.put_line('Qtd de Erros: ' || vr_qtderror);
END;
