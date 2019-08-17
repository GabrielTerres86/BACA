DECLARE 
  
  CURSOR cr_libera IS
    SELECT DISTINCT a.NMDATELA, a.CDOPERAD, c.CDCOOPER, a.NRMODULO, a.IDEVENTO, a.IDAMBACE
                      FROM CRAPCOP c
                         , CRAPACE a
                         , CRAPOPE o
                     WHERE c.cdcooper = a.cdcooper
                       AND c.flgativo = 1
                       AND o.cdcooper = a.cdcooper
                       AND o.cdoperad = a.cdoperad
                       AND o.cdsitope = 1
                       AND a.idambace = 2
                       AND a.nmdatela = 'ATENDA'
                       AND a.cddopcao = '@'
                       AND TRIM(a.nmrotina) IS NULL
             /*AND UPPER(o.cdoperad) NOT IN ('F0030992'
                                          ,'F0030382' 
                                          ,'F0030991' 
                                          ,'F0030631' 
                                          ,'F0030595' 
                                          ,'F0030892' 
                                          ,'F0031022' 
                                          ,'F0030597' 
                                          ,'F0030832'
                                          ,'F0031981'
                                          ,'F0030563'
                                          ,'F0032179') 
             AND c.cdcooper <> 11*/ ; 
  
  CURSOR cr_solpor IS
    SELECT DISTINCT a.CDOPERAD, c.CDCOOPER, a.NRMODULO, a.IDEVENTO, a.IDAMBACE
                        FROM CRAPCOP c
                           , CRAPACE a
                           , CRAPOPE o
                       WHERE c.cdcooper = a.cdcooper
                         AND c.flgativo = 1
                         AND o.cdcooper = a.cdcooper
                         AND o.cdoperad = a.cdoperad
                         AND o.cdsitope = 1
                         AND a.idambace = 2
                         AND a.nmdatela = 'ATENDA'
                         AND a.cddopcao = '@'
                         AND a.nmrotina = 'PORTABILIDADE'; 
  
  CURSOR cr_solpor_viacredi IS
    SELECT DISTINCT a.CDOPERAD, c.CDCOOPER, a.NRMODULO, a.IDEVENTO, a.IDAMBACE
                        FROM CRAPCOP c
                           , CRAPACE a
                           , CRAPOPE o
                       WHERE c.cdcooper = a.cdcooper
                         AND c.flgativo = 1
                         AND o.cdcooper = a.cdcooper
                         AND o.cdoperad = a.cdoperad
                         AND o.cdsitope = 1
                         AND a.idambace = 2
                         AND a.nmdatela = 'ATENDA'
                         AND a.cddopcao = '@'
                         AND a.nmrotina = 'PORTABILIDADE'
                         AND c.cdcooper <> 1 ; -- não incluir viacredi
  
  vr_cdopcao  VARCHAR2(1);

BEGIN

  FOR reg IN cr_libera LOOP 
    -- Para cada uma das opções -- @,S,C
    FOR vr_index IN 1..3 LOOP
      
      -- selecionar a opção
      CASE vr_index 
        WHEN 1 THEN vr_cdopcao := '@';
        WHEN 2 THEN vr_cdopcao := 'S';
        WHEN 3 THEN vr_cdopcao := 'C';
      END CASE;
        
      BEGIN
        -- Replicar todos os acessos da tela ATENDA.... para o item Portabilidade
        INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                     VALUES (reg.NMDATELA
                            ,vr_cdopcao      -- CDDOPCAO
                            ,reg.CDOPERAD
                            ,'PORTABILIDADE' -- NMROTINA
                            ,reg.CDCOOPER
                            ,reg.NRMODULO
                            ,reg.IDEVENTO
                            ,reg.IDAMBACE); 
      EXCEPTION
        WHEN dup_val_on_index THEN
          NULL;
        WHEN OTHERS THEN
          raise_application_error(-20000,'Erro ao inserir permissões: '||SQLERRM); 
      END;
                   
    END LOOP;
  END LOOP;
  
  COMMIT;
  
  
  /********** INCLUIR OS ACESSOS DA SOLPOR - OPÇÕES E e R **********/
  
  FOR reg IN cr_solpor LOOP
    -- Para cada uma das opções -- @,E,R,M
    FOR vr_index IN 1..3 LOOP
      
      -- selecionar a opção
      CASE vr_index 
        WHEN 1 THEN vr_cdopcao := '@';
        WHEN 2 THEN vr_cdopcao := 'E';
        WHEN 3 THEN vr_cdopcao := 'R';  
        --WHEN 4 THEN vr_cdopcao := 'M';
      END CASE;
      
      BEGIN 
        -- Replicar todos os acessos da tela ATENDA.... para a tela SOLPOR
        INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                      VALUES('SOLPOR'   -- NMDATELA
                            ,vr_cdopcao -- CDDOPCAO
                            ,reg.CDOPERAD
                            ,reg.CDCOOPER
                            ,reg.NRMODULO
                            ,reg.IDEVENTO
                            ,reg.IDAMBACE);

      EXCEPTION
        WHEN dup_val_on_index THEN
          NULL;
        WHEN OTHERS THEN
          raise_application_error(-20000, 'Erro ao inserir acesso às opções E e R: '||SQLERRM);
      END; 
      
    END LOOP;
  END LOOP;
  
  COMMIT;
  
  
  /********** INCLUIR OS ACESSOS DA SOLPOR - OPÇÃO M - COOPERATIVAS MENOS VIACREDI **********/
  
  FOR reg IN cr_solpor_viacredi LOOP          
    BEGIN 
      -- Replicar todos os acessos da tela ATENDA.... para a tela SOLPOR
      INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                    VALUES('SOLPOR'   -- NMDATELA
                          ,'M' -- CDDOPCAO
                          ,reg.CDOPERAD
                          ,reg.CDCOOPER
                          ,reg.NRMODULO
                          ,reg.IDEVENTO
                          ,reg.IDAMBACE);

    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
      WHEN OTHERS THEN
        raise_application_error(-20000, 'Erro ao inserir acesso à opção M: '||SQLERRM);
    END;     
  END LOOP;
  
  COMMIT;
  
  
  /********** INCLUIR OS ACESSOS DA SOLPOR - OPÇÃO M - VIACREDI **********/
  --------------------------------------------------------------------------------------------------------------
  BEGIN 
    -- Replicar todos os acessos da tela ATENDA.... para a tela SOLPOR
    INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                  VALUES('SOLPOR','M'      ,'f0014249',1       , 1       , 1       , 2);

  EXCEPTION
    WHEN dup_val_on_index THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20000, 'Erro ao inserir acesso aos usuários VIACREDI (f0014249): '||SQLERRM);
  END;     
  --------------------------------------------------------------------------------------------------------------
  BEGIN 
    -- Replicar todos os acessos da tela ATENDA.... para a tela SOLPOR
    INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                  VALUES('SOLPOR','M'      ,'f0012108',1       , 1       , 1       , 2);

  EXCEPTION
    WHEN dup_val_on_index THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20000, 'Erro ao inserir acesso aos usuários VIACREDI (f0012108): '||SQLERRM);
  END;     
  --------------------------------------------------------------------------------------------------------------
  BEGIN 
    -- Replicar todos os acessos da tela ATENDA.... para a tela SOLPOR
    INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                  VALUES('SOLPOR','M'      ,'f0014230',1       , 1       , 1       , 2);

  EXCEPTION
    WHEN dup_val_on_index THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20000, 'Erro ao inserir acesso aos usuários VIACREDI (f0014230): '||SQLERRM);
  END;     
  --------------------------------------------------------------------------------------------------------------
  BEGIN 
    -- Replicar todos os acessos da tela ATENDA.... para a tela SOLPOR
    INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                  VALUES('SOLPOR','M'      ,'f0010484',1       , 1       , 1       , 2);

  EXCEPTION
    WHEN dup_val_on_index THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20000, 'Erro ao inserir acesso aos usuários VIACREDI (f0010484): '||SQLERRM);
  END;     
  --------------------------------------------------------------------------------------------------------------
  BEGIN 
    -- Replicar todos os acessos da tela ATENDA.... para a tela SOLPOR
    INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                  VALUES('SOLPOR','M'      ,'f0014239',1       , 1       , 1       , 2);

  EXCEPTION
    WHEN dup_val_on_index THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20000, 'Erro ao inserir acesso aos usuários VIACREDI (f0014239): '||SQLERRM);
  END;     
  --------------------------------------------------------------------------------------------------------------
  BEGIN 
    -- Replicar todos os acessos da tela ATENDA.... para a tela SOLPOR
    INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                  VALUES('SOLPOR','M'      ,'f0011233',1       , 1       , 1       , 2);

  EXCEPTION
    WHEN dup_val_on_index THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20000, 'Erro ao inserir acesso aos usuários VIACREDI (f0011233): '||SQLERRM);
  END;     
  --------------------------------------------------------------------------------------------------------------
  
  COMMIT;
  
END;
