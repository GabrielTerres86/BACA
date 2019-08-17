DECLARE 

  vr_cdopcao  VARCHAR2(2);

BEGIN
  
  /*********************************************** ACESSOS TELA CADDES ***********************************************/

  -- Deletar todos os acessos da tela CADDES na CENTRAL e na VIACREDI
  DELETE crapace t
   WHERE UPPER(t.nmdatela) = 'CADDES'
     AND t.cdcooper IN (1,3);
    
  -- Para cada uma das opções da tela CADDES
  FOR vr_index IN 1..6 LOOP
    
    -- selecionar a opção
    CASE vr_index 
      WHEN 1 THEN vr_cdopcao := '@';  
      WHEN 2 THEN vr_cdopcao := 'A';
      WHEN 3 THEN vr_cdopcao := 'I';
      WHEN 4 THEN vr_cdopcao := 'C';
      WHEN 5 THEN vr_cdopcao := 'E';
      WHEN 6 THEN vr_cdopcao := 'U';
    END CASE;
      
    -- Liberar acesso a opção para os usuários da CENTRAL
    INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
               SELECT t.nmdatela, vr_cdopcao, o.cdoperad, t.nmrotina, o.cdcooper, t.nrmodulo, t.idevento, t.idambtel
                 FROM craptel t 
                    , crapope o
                WHERE t.nmdatela = 'CADDES'
                  AND t.cdcooper = o.cdcooper
                  AND o.cdcooper = 3   -- APENAS CENTRAL
                  AND upper(o.cdoperad) IN ('F0030215', 'F0030497', 'F0030598', 'F0030636', 'F0031411', 'F0030868')
                  AND o.cdsitope = 1;
    
    -- Liberar acesso a opção para os usuários da VIACREDI
		INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
               SELECT t.nmdatela, vr_cdopcao, o.cdoperad, t.nmrotina, o.cdcooper, t.nrmodulo, t.idevento, t.idambtel
                 FROM craptel t
                    , crapope o
                WHERE o.cdcooper = 1 -- APENAS VIACREDI
                  AND UPPER(t.nmdatela) = 'CADDES'
                  AND o.cdcooper = t.cdcooper
                  AND o.cdsitope = 1
                  AND EXISTS (SELECT 1 
                                FROM crapace  ace
                               WHERE o.cdcooper = ace.cdcooper
                                 AND upper(ace.nmdatela) = 'ATENDA'  
                                 AND UPPER(ace.nmrotina) = 'COBRANCA'
                                 AND upper(o.cdoperad) = upper(ace.cdoperad)
                                 AND ace.idambace = 2 );
    
  END LOOP;
  
  COMMIT;
  
  
  /*********************************************** ACESSOS TELA CADAPI ***********************************************/
  
  -- Deletar todos os acessos da tela CADAPI na CENTRAL
  DELETE crapace t
   WHERE UPPER(t.nmdatela) = 'CADAPI'
     AND t.cdcooper = 3;
  
  -- Para cada uma das opções da tela CADAPI
  FOR vr_index IN 1..4 LOOP
    
    -- selecionar a opção
    CASE vr_index 
      WHEN 1 THEN vr_cdopcao := '@';  
      WHEN 2 THEN vr_cdopcao := 'C';
      WHEN 3 THEN vr_cdopcao := 'F';
      WHEN 4 THEN vr_cdopcao := 'E';
    END CASE;
      
    -- Liberar acesso a opção para os usuários da CENTRAL
    INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
               SELECT t.nmdatela, vr_cdopcao, o.cdoperad, t.nmrotina, o.cdcooper, t.nrmodulo, t.idevento, t.idambtel
                 FROM craptel t 
                    , crapope o
                WHERE t.nmdatela = 'CADAPI'
                  AND t.cdcooper = o.cdcooper
                  AND o.cdcooper = 3   -- APENAS CENTRAL
                  AND upper(o.cdoperad) IN ('F0030215', 'F0030497', 'F0030598', 'F0030636', 'F0031411', 'F0030868')
                  AND o.cdsitope = 1;
    
  END LOOP;
  
  COMMIT;
  
  
  /************************************** ACESSOS TELA ATENDA > PLATAFORMA API ***************************************/
  
  -- Deletar todos os acessos da tela PLATAFORMA API na VIACREDI
  DELETE crapace t
   WHERE UPPER(t.nmdatela) = 'ATENDA'
     AND UPPER(t.nmrotina) = 'PLATAFORMA_API'
     AND t.cdcooper = 1;
    
  -- Para cada uma das opções da tela ATENDA > PLATAFORMA API
  FOR vr_index IN 1..5 LOOP
    
    -- selecionar a opção
    CASE vr_index 
      WHEN 1 THEN vr_cdopcao := '@';  
      WHEN 2 THEN vr_cdopcao := 'C';
      WHEN 3 THEN vr_cdopcao := 'CA';
      WHEN 4 THEN vr_cdopcao := 'A';
      WHEN 5 THEN vr_cdopcao := 'I';
    END CASE;
      
    -- Liberar acesso a opção para os usuários da VIACREDI
		INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
               SELECT t.nmdatela, vr_cdopcao, o.cdoperad, t.nmrotina, o.cdcooper, t.nrmodulo, t.idevento, t.idambtel
                 FROM craptel t
                    , crapope o
                WHERE o.cdcooper = 1 -- APENAS VIACREDI
                  AND UPPER(t.nmdatela) = 'ATENDA'
                  AND UPPER(t.nmrotina) = 'PLATAFORMA_API'
                  AND o.cdcooper = t.cdcooper
                  AND o.cdsitope = 1
                  AND EXISTS (SELECT 1 
                                FROM crapace  ace
                               WHERE o.cdcooper = ace.cdcooper
                                 AND upper(ace.nmdatela) = 'ATENDA'  
                                 AND UPPER(ace.nmrotina) = 'COBRANCA'
                                 AND upper(o.cdoperad) = upper(ace.cdoperad)
                                 AND ace.idambace = 2 );
    
  END LOOP;
  
  COMMIT;
  
  
END;
