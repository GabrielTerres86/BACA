-- Created on 05/08/2019 by F0030248 
DECLARE 

  vr_cdopcao  VARCHAR2(2);
  vr_dslobdev      CLOB;
  vr_dsbufdev      VARCHAR2(32700);  
  vr_dscritic      VARCHAR2(1000);  
  
  procedure pc_print(pr_msg VARCHAR2, vr_close BOOLEAN DEFAULT FALSE) is
  begin
    -- Inicilizar as informacoes do XML
    gene0002.pc_escreve_xml(vr_dslobdev,vr_dsbufdev,pr_msg || CHR(13) || CHR(10), vr_close);    
  end pc_print;
  

BEGIN
      
  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_dslobdev, TRUE);
  dbms_lob.open(vr_dslobdev, dbms_lob.lob_readwrite);
  vr_dsbufdev := NULL;
  
  pc_print('*** LOG - Copiar permissoes ATENDA > PLATAFORMA_API p/ OPERADORES ***');  

    -- Test statements here
    FOR rw IN (SELECT cdcooper 
                 FROM crapcop cop
                WHERE cop.cdcooper > 1
                  AND cop.flgativo = 1
                  AND cop.cdcooper <> 3) LOOP                
                  
      BEGIN                  
  
        -- Deletar todos os acessos da tela PLATAFORMA API na VIACREDI
        DELETE crapace t
         WHERE UPPER(t.nmdatela) = 'ATENDA'
           AND UPPER(t.nmrotina) = 'PLATAFORMA_API'
           AND t.cdcooper = rw.cdcooper;
          
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
                      WHERE o.cdcooper = rw.cdcooper
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
                                       AND ace.idambace = 2 )
                        AND NOT EXISTS (SELECT 1 
                                      FROM crapace  ace
                                     WHERE o.cdcooper = ace.cdcooper
                                       AND upper(ace.nmdatela) = 'ATENDA'  
                                       AND UPPER(ace.nmrotina) = 'PLATAFORMA_API'
                                       AND upper(o.cdoperad) = upper(ace.cdoperad)
                                       AND upper(ace.cddopcao) = vr_cdopcao
                                       AND ace.idambace = 2 );
                                       
          pc_print('Cooper: ' || rw.cdcooper || ' Tela ATENDA > PLATAFORMA_API - opcao = ' || vr_cdopcao || ' - Qtd = ' || SQL%ROWCOUNT);
          
        END LOOP;
        
      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            pc_print('Erro ao gerar permissão tela ATENDA > PLATAFORMA API: ' || SQLERRM);     
            ROLLBACK;      
          END;            
      END; 
      
      BEGIN
        
        -- Deletar todos os acessos da tela CADDES na CENTRAL e na VIACREDI
        DELETE crapace t
         WHERE UPPER(t.nmdatela) = 'CADDES'
           AND t.cdcooper = rw.cdcooper;
          
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
                      
          -- Liberar acesso a opção para os usuários da VIACREDI
          INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                     SELECT t.nmdatela, vr_cdopcao, o.cdoperad, t.nmrotina, o.cdcooper, t.nrmodulo, t.idevento, t.idambtel
                       FROM craptel t
                          , crapope o
                      WHERE o.cdcooper = rw.cdcooper
                        AND UPPER(t.nmdatela) = 'CADDES'
                        AND o.cdcooper = t.cdcooper
                        AND o.cdsitope = 1
                        AND EXISTS (SELECT 1 
                                      FROM crapace  ace
                                     WHERE o.cdcooper = ace.cdcooper
                                       AND upper(ace.nmdatela) = 'ATENDA'  
                                       AND UPPER(ace.nmrotina) = 'COBRANCA'
                                       AND upper(o.cdoperad) = upper(ace.cdoperad)
                                       AND ace.idambace = 2 )
                        AND NOT EXISTS (SELECT 1 
                                      FROM crapace  ace
                                     WHERE o.cdcooper = ace.cdcooper
                                       AND upper(ace.nmdatela) = 'CADDES'  
                                       AND upper(o.cdoperad) = upper(ace.cdoperad)
                                       AND upper(ace.cddopcao) = vr_cdopcao
                                       AND ace.idambace = 2 );
                                       
          pc_print('Cooper: ' || rw.cdcooper || ' Tela CADDES - opcao = ' || vr_cdopcao || ' - Qtd = ' || SQL%ROWCOUNT);
                    
        END LOOP;      
       
      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            pc_print('Erro ao gerar permissão tela CADDES: ' || SQLERRM);     
            ROLLBACK;      
          END;                    
      END;       
            
        
    END LOOP;                  
    
  pc_print('*** FIM ***', TRUE);
  
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_dslobdev, '/micros/cecred/rafael/', 'log_baca_plataforma_api.txt', NLS_CHARSET_ID('UTF8'));    
  
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_dslobdev);
  dbms_lob.freetemporary(vr_dslobdev);    
  
  COMMIT;
  
end;