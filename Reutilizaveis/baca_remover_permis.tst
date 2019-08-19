PL/SQL Developer Test script 3.0
348
-- Created on 22/06/2016 by F0030344 Tiago Machado Flor
DECLARE

  TYPE typ_reg_opcao_nome IS
      RECORD (cdopptel crapace.cddopcao%TYPE
             ,lsopptel craptel.lsopptel%TYPE
             ,nmrotina crapace.nmrotina%TYPE
             ,nmdatela craptel.nmdatela%TYPE);
             
  TYPE typ_tab_opcao_nome IS
    TABLE OF typ_reg_opcao_nome
    INDEX BY VARCHAR2(400);
    
  vr_tab_opcao_nome typ_tab_opcao_nome;
  
  vr_tab_split gene0002.typ_split;
  vr_tab_split2 gene0002.typ_split;

  TYPE typ_tab_ace IS TABLE OF crapace%ROWTYPE INDEX BY PLS_INTEGER;    
     
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper   
      FROM crapcop cop
     WHERE cop.cdcooper = 1;
     
  CURSOR cr_craptel IS
    SELECT * 
      FROM craptel
     WHERE craptel.cdcooper = 1
       AND UPPER(craptel.nmdatela) IN ('CONSCR');


  CURSOR cr_craptel2(pr_cdcooper crapcop.cdcooper%TYPE
                    ,pr_nmdatela craptel.nmdatela%TYPE
                    ,pr_nmrotina craptel.nmrotina%TYPE) IS
    SELECT * 
      FROM craptel
     WHERE craptel.cdcooper = pr_cdcooper
       AND UPPER(craptel.nmdatela) = UPPER(pr_nmdatela)
       AND UPPER(craptel.nmrotina) = UPPER(pr_nmrotina);
--SELECT * FROM craptel t WHERE t.nmdatela = 'ATENDA' AND nmrotina = 'DSC CHQS - LIMITE' AND cdcooper = 1 AND lsopptel LIKE '%RENOVACAO%'


  --CDCOOPER, UPPER(NMDATELA), UPPER(NMROTINA), UPPER(CDDOPCAO), UPPER(CDOPERAD), IDAMBACE
  CURSOR cr_crapace(pr_cdcooper crapace.cdcooper%TYPE
                   ,pr_nmdatela crapace.nmdatela%TYPE
                   ,pr_nmrotina crapace.nmrotina%TYPE
                   ,pr_cddopcao crapace.cddopcao%TYPE
                   ,pr_cdoperad crapace.cdoperad%TYPE) IS
    SELECT * 
      FROM crapace
     WHERE crapace.cdcooper = pr_cdcooper
       AND UPPER(crapace.nmdatela) = UPPER(pr_nmdatela)
       AND UPPER(crapace.nmrotina) = UPPER(pr_nmrotina)
       AND UPPER(crapace.cddopcao) = UPPER(pr_cddopcao)
       AND UPPER(crapace.cdoperad) = UPPER(pr_cdoperad);
                   

  rw_craptel cr_craptel%ROWTYPE;                                      
     
  vr_arq_path  VARCHAR2(1000);        --> Diretorio que sera criado o relatorio
  vr_rowid     ROWID;

  vr_tab_op gene0002.typ_split;
  vr_idx    INTEGER;
  vr_idx_op INTEGER;
  
  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);
  
  vr_tab_ace   typ_tab_ace;
  vr_chave     PLS_INTEGER := 0;
  vr_exc_erro  EXCEPTION;

  vr_hutlfile utl_file.file_type;
  vr_dstxtlid VARCHAR2(1000);
  vr_txtauxil VARCHAR2(200); -- Texto auxiliar
  vr_achou PLS_INTEGER;  
  vr_dscritic crapcri.dscritic%TYPE;

  vr_cdcooper craptel.cdcooper%TYPE;
  vr_nmdatela craptel.nmdatela%TYPE;
  vr_nmrotina craptel.nmrotina%TYPE;
  vr_lsopptel craptel.lsopptel%TYPE;
  vr_cdopptel craptel.cdopptel%TYPE;

  
  
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                           pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  END;

BEGIN 

  -- Iniciar Variáveis     
  vr_arq_path := '/micros/cpd/bacas/PRB0040063/';

  
  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;
  
  
  --Carregar PLtable com as telas e as opcoes de tela correlacionadas
  
  -- Efetuar abertura do arquivo para processamento
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   --> Diretorio do arquivo
                          ,pr_nmarquiv => 'OPCOES_TELAS.csv'  --> Nome do arquivo
                          ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_hutlfile   --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic); --> Erro
                          
  IF vr_dscritic IS NOT NULL THEN
    --Levantar Excecao
    vr_dscritic := 'Erro na leitura do arquivo --> '||vr_dscritic;
    dbms_output.put_line(vr_dscritic);
    RAISE vr_exc_erro;
  END IF;  
  
  --Verifica se o arquivo esta aberto
  IF utl_file.IS_OPEN(vr_hutlfile) THEN
    BEGIN   
      
      vr_tab_opcao_nome.DELETE;
      vr_chave := 0;
      
      -- Laço para efetuar leitura de todas as linhas do arquivo 
      LOOP  
        -- Leitura da linha x
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile --> Handle do arquivo aberto
                                    ,pr_des_text => vr_dstxtlid); --> Texto lido
        
        vr_chave := vr_chave + 1;
        
        -- Ignorar primeira linha do arquivo
        IF vr_chave = 1 THEN
           CONTINUE;
        END IF;
            
        -- Ignorar linhas vazias
        IF length(vr_dstxtlid) <= 3 THEN 
          CONTINUE;
        END IF;
            
        -- Descobrir se a opcao e tela da planilha existem
        BEGIN
            
          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 1
                        ,pr_dstext      => vr_dstxtlid
                        ,pr_delimitador => ';');                                                  
            
          vr_lsopptel := UPPER(TRIM(vr_txtauxil));

          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 2
                        ,pr_dstext      => vr_dstxtlid
                        ,pr_delimitador => ';');                                                  
            
          vr_cdopptel := UPPER(TRIM(vr_txtauxil));

          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 3
                                                  ,pr_dstext      => vr_dstxtlid
                                                  ,pr_delimitador => ';');                                                  
            
          vr_nmdatela := UPPER(TRIM(vr_txtauxil));

          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 4
                                                  ,pr_dstext      => vr_dstxtlid
                                                  ,pr_delimitador => ';');                                                  
            
          vr_nmrotina := TRIM(vr_txtauxil);
          
          
          vr_tab_opcao_nome(vr_nmdatela||vr_lsopptel||vr_nmrotina).nmdatela := vr_nmdatela;
          vr_tab_opcao_nome(vr_nmdatela||vr_lsopptel||vr_nmrotina).cdopptel := vr_cdopptel;
          vr_tab_opcao_nome(vr_nmdatela||vr_lsopptel||vr_nmrotina).lsopptel := vr_lsopptel;
          vr_tab_opcao_nome(vr_nmdatela||vr_lsopptel||vr_nmrotina).nmrotina := vr_nmrotina;
  
        EXCEPTION
          WHEN OTHERS THEN 
            vr_dscritic := 'Erro na leitura do arquivo2 --> '||vr_txtauxil;  
            dbms_output.put_line(vr_dscritic);
            RAISE vr_exc_erro;
        END;
          
      END LOOP;
    EXCEPTION 
      WHEN no_data_found THEN 
        -- fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
    END;
  END IF;
  dbms_output.put_line('Carregou a tab1');
  --FIM Carregar PLtable com as telas e as opcoes de tela correlacionadas
  
  --carrega tab
  /***********************************************************/
  -- Efetuar abertura do arquivo para processamento
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   --> Diretorio do arquivo
                          ,pr_nmarquiv => 'USER_PERMIS.csv'  --> Nome do arquivo
                          ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_hutlfile   --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic); --> Erro
                          
  IF vr_dscritic IS NOT NULL THEN
    --Levantar Excecao
    vr_dscritic := 'Erro na leitura do arquivo --> '||vr_dscritic;
    dbms_output.put_line(vr_dscritic);
    RAISE vr_exc_erro;
  END IF;  
  
      --Verifica se o arquivo esta aberto
      IF utl_file.IS_OPEN(vr_hutlfile) THEN
        BEGIN   
          -- Laço para efetuar leitura de todas as linhas do arquivo 
          LOOP  
            -- Leitura da linha x
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile --> Handle do arquivo aberto
                                        ,pr_des_text => vr_dstxtlid); --> Texto lido
            
            -- Ignorar linhas vazias
            IF length(vr_dstxtlid) <= 3 THEN 
              continue;
            END IF;
            
            -- Efetuar leitura do operador
            BEGIN
              vr_chave := vr_chave + 1;                             
              
              
--CDCOOPER	CDAGENCI	CDOPERAD	NMTELA	NMROTINA	NMOPCAO	NMOPERAD	DSCARGORH	NOMECENTROCUSTO	TIPO	OP_NIVEL	TELA_NIVEL
              
              vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 1
                                        ,pr_dstext      => vr_dstxtlid
                                        ,pr_delimitador => ';');                                                  
              vr_tab_ace(vr_chave).cdcooper := TRIM(vr_txtauxil);

              vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 3
                                                      ,pr_dstext      => vr_dstxtlid
                                                      ,pr_delimitador => ';');              
              vr_tab_ace(vr_chave).cdoperad := TRIM(vr_txtauxil);

              vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 4
                                                      ,pr_dstext      => vr_dstxtlid
                                                      ,pr_delimitador => ';');
              vr_tab_ace(vr_chave).nmdatela := UPPER(TRIM(vr_txtauxil));

              vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 5
                                                      ,pr_dstext      => vr_dstxtlid
                                                      ,pr_delimitador => ';');
              vr_tab_ace(vr_chave).nmrotina := UPPER(TRIM(vr_txtauxil));
                            
              vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 6
                                                      ,pr_dstext      => vr_dstxtlid
                                                      ,pr_delimitador => ';');              
                                                      
              IF vr_tab_opcao_nome.EXISTS(vr_tab_ace(vr_chave).nmdatela||UPPER(TRIM(vr_txtauxil))||vr_tab_ace(vr_chave).nmrotina)THEN
                 vr_tab_ace(vr_chave).cddopcao := vr_tab_opcao_nome(vr_tab_ace(vr_chave).nmdatela||UPPER(TRIM(vr_txtauxil))||vr_tab_ace(vr_chave).nmrotina).cdopptel;
              ELSE
                 vr_tab_ace.DELETE(vr_chave);
                 CONTINUE;
              END IF; 
              
--REPLACE(TRIM(vr_txtauxil),chr(13),'');
              
              vr_tab_ace(vr_chave).nrmodulo := '1';
              vr_tab_ace(vr_chave).idevento := '1';
              vr_tab_ace(vr_chave).idambace := '2';
              
            EXCEPTION
              WHEN OTHERS THEN 
                vr_dscritic := 'Erro na leitura do arquivo2 --> '||vr_txtauxil;  
                dbms_output.put_line(vr_dscritic);
                RAISE vr_exc_erro;
            END;
          
          END LOOP;
        EXCEPTION 
          WHEN no_data_found THEN 
            -- fechar arquivo
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
        END;
      END IF;
  dbms_output.put_line('Carregou a tab2');
    
  /************************************************************/
--CRAPACE CDCOOPER, UPPER(NMDATELA), UPPER(NMROTINA), UPPER(CDDOPCAO), UPPER(CDOPERAD), IDAMBACE
  vr_chave := vr_tab_ace.FIRST;
  
  WHILE vr_chave IS NOT NULL LOOP
--###############INSERINDO PERMISSOES##################-------------------    
    
    BEGIN
     
      FOR rw_crapace IN cr_crapace(pr_cdcooper => vr_tab_ace(vr_chave).cdcooper
                                  ,pr_nmdatela => vr_tab_ace(vr_chave).nmdatela
                                  ,pr_nmrotina => vr_tab_ace(vr_chave).nmrotina
                                  ,pr_cddopcao => vr_tab_ace(vr_chave).cddopcao
                                  ,pr_cdoperad => vr_tab_ace(vr_chave).cdoperad ) LOOP 
        BEGIN
          --criar insert
          pc_escreve_xml( 'INSERT INTO CRAPACE(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES('||
                          ''''|| rw_crapace.nmdatela || ''',''' || rw_crapace.cddopcao || ''',''' || rw_crapace.cdoperad || ''',''' ||
                          rw_crapace.nmrotina || ''',' || rw_crapace.cdcooper || ',' || rw_crapace.nrmodulo
                          || ',' || rw_crapace.idevento || ',' || rw_crapace.idambace || ');' || chr(10) );
        
          DELETE 
            FROM crapace
           WHERE crapace.cdcooper = rw_crapace.cdcooper
             AND UPPER(crapace.nmdatela) = UPPER(rw_crapace.nmdatela)
             AND UPPER(crapace.nmrotina) = UPPER(rw_crapace.nmrotina)
             AND UPPER(crapace.cddopcao) = UPPER(rw_crapace.cddopcao)
             AND UPPER(crapace.cdoperad) = UPPER(rw_crapace.cdoperad)
             AND crapace.idambace = rw_crapace.idambace;           
           
        EXCEPTION                          
          WHEN OTHERS THEN
            RAISE vr_exc_erro;
        END;
      END LOOP;
                                
    EXCEPTION
      WHEN OTHERS THEN
        RAISE vr_exc_erro;
    END;
    
    vr_chave := vr_tab_ace.NEXT(vr_chave);
  END LOOP;
  
  pc_escreve_xml(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_arq_path, 'BKP_USER_PERMIS.txt', NLS_CHARSET_ID('UTF8'));
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);  
  
  --descomentar para prod
  COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Excecao '||Sqlerrm);
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line('Excecao others '||Sqlerrm);
    ROLLBACK;    
END;
0
1
vr_chave
