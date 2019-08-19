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
                               ,'f0030260'
                               ,'f0031839'
                               ,'f0030947'
                               ,'f0030641');

  -- Vari�vel de cr�ticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(10000);
  vr_exc_saida     EXCEPTION;
  vr_qtdsuces      INTEGER := 0;
  vr_qtderror      INTEGER := 0;
  
BEGIN
  
  --Limpa registros
  DELETE FROM crapace ace WHERE ace.nmdatela = 'APRCAR';
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
    -- Op��o '@'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030519', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030260', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0031839', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030947', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030641', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    
    -- Op��o 'C'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030519', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030260', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0031839', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030947', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030641', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    
    -- Op��o 'A'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030519', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030260', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0031839', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030947', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030641', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);    
  END LOOP;
  
  /*FOR row_ope IN cr_crapope LOOP
  BEGIN
    
    -- Op��o '@P'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES ('ATENDA', 'J', row_ope.cdoperad, 'CARTAO CRED', row_ope.cdcooper, 1, 1, 2);
    
    -- Op��o 'PC'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES ('ATENDA', 'K', row_ope.cdoperad, 'CARTAO CRED', row_ope.cdcooper, 1, 1, 2);
    
    vr_qtdsuces := vr_qtdsuces + 1;
    
    EXCEPTION  -- exception handlers begin
      WHEN OTHERS THEN  -- handles all other errors
      vr_dscritic := 'Erro ao criar a permiss�o para o Operador: ' || row_ope.cdoperad || ', Error: (' || SQLERRM || ');';
      vr_qtderror := vr_qtderror + 1;
    END;
    
  END LOOP; */
  
  COMMIT;
  
  dbms_output.put_line('Qtd de Sucesso: ' || vr_qtdsuces);
  dbms_output.put_line('Qtd de Erros: ' || vr_qtderror);
END;



