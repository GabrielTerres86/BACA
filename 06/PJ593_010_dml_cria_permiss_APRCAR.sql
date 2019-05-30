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
  DELETE FROM crapace ace WHERE ace.nmdatela = 'CARCRD';
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
    -- Opção '@'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('APRCAR', '@', 'f0030260', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        
    -- Opção 'C'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('APRCAR', 'C', 'f0030260', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    
    -- Opção 'A'
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('APRCAR', 'A', 'f0030260', ' ', rw_crapcop.cdcooper, 1, 1, 2);
    
  END LOOP;
  
  COMMIT;
  
  dbms_output.put_line('Qtd de Sucesso: ' || vr_qtdsuces);
  dbms_output.put_line('Qtd de Erros: ' || vr_qtderror);
END;


