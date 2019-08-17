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
                               ,'f0030641'
                               ,'f0030260'
                               ,'f0031839'
                               ,'f0030947');

  -- Variável de críticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(10000);
  vr_exc_saida     EXCEPTION;
  vr_qtdsuces      INTEGER := 0;
  vr_qtderror      INTEGER := 0;
  
BEGIN
  
  --Limpa registros
  DELETE FROM crapace ace WHERE ace.nmdatela = 'CARCRD';
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
    -- Opção '@'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030519', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        
    -- Opção 'C'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030519', ' ', rw_crapcop.cdcooper, 1, 1, 2);

    -- Opção '@'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030641', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        
    -- Opção 'C'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030641', ' ', rw_crapcop.cdcooper, 1, 1, 2);

    -- Opção '@'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030260', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        
    -- Opção 'C'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030260', ' ', rw_crapcop.cdcooper, 1, 1, 2);

    -- Opção '@'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0031839', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        
    -- Opção 'C'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0031839', ' ', rw_crapcop.cdcooper, 1, 1, 2);
       
    -- Opção '@'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030947', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        
    -- Opção 'C'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030947', ' ', rw_crapcop.cdcooper, 1, 1, 2);
       	   
  END LOOP;
  
  /*FOR row_ope IN cr_crapope LOOP
  BEGIN
    
    -- Opção '@'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES ('CARCRD', '@', row_ope.cdoperad, ' ', row_ope.cdcooper, 1, 1, 2);
    
    -- Opção 'C'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES ('CARCRD', 'C', row_ope.cdoperad, ' ', row_ope.cdcooper, 1, 1, 2);
    
    vr_qtdsuces := vr_qtdsuces + 1;
    
    EXCEPTION  -- exception handlers begin
      WHEN OTHERS THEN  -- handles all other errors
      vr_dscritic := 'Erro ao criar a permissão para o Operador: ' || row_ope.cdoperad || ', Error: (' || SQLERRM || ');';
      vr_qtderror := vr_qtderror + 1;
    END;
    
  END LOOP;*/
  
  COMMIT;
  
  dbms_output.put_line('Qtd de Sucesso: ' || vr_qtdsuces);
  dbms_output.put_line('Qtd de Erros: ' || vr_qtderror);
END;
