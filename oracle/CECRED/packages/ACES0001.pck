CREATE OR REPLACE PACKAGE CECRED.ACES0001 AS 

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa:  ACES0001                      
  --  Autor   : Gielow
  --  Data    : Fevereiro/2016                     Ultima Atualizacao: 28/03/2016
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo manutencao de operadores
  --              do sistema ayllos.
  --
  --  Alteracoes: 28/03/2016 - Criacao da procedure pc_exclui_permis_ope (Tiago SD414193)
  --
  ---------------------------------------------------------------------------------------------------------------

  /*Procedure que gera uma lista de operadores em determinada pasta*/
  PROCEDURE pc_lista_operadores(pr_dsdireto IN VARCHAR2);

  /* Procedures que gera uma lista com operadores e suas permissoes
     de acesso no sistema ayllos */
  PROCEDURE pc_lista_permissoes_operadores(pr_dsdireto IN VARCHAR2);


  /* Procedure que a permissao dos operadores baseados em um arquivo de entrada */
  PROCEDURE pc_exclui_permis_ope(pr_dsdireto IN VARCHAR2);  
  
  /* Procedure que a exclui todos os acessos informados para uma determinada tela */
  PROCEDURE pc_exc_permis_ope_tela(
    pr_dsdireto IN VARCHAR2, -- diretorio onde os arquivos serão gerados
    pr_nmdatela IN VARCHAR2, -- nome da tela que as permissões devem ser excluidas
    pr_cdopptel IN VARCHAR2 -- listsa de opcoes da tela a serem excluidas
  );

END ACES0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.ACES0001 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : ACES0001
  --  Sistema  : Package para rotinas envolvendo manutencao de operadores
  --             do sistema ayllos.
  --  Sigla    : CRED
  --  Autor    : Gielow
  --  Data     : Fevereiro/2016.                   Ultima atualizacao: 28/03/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Package para rotinas envolvendo manutencao de operadores
  --             do sistema ayllos.
  --
  -- Alteracoes: 28/03/2016 - Criacao da procedure pc_exclui_permis_ope (Tiago SD414193)
  --             
  --             28/11/2016 - P341 - Automatização BACENJUD - Alterado para buscar o nome do departamento
  --                          na tabela CRAPDPO, e não mais diretamente da CRAPOPE (Renato Darosci - Supero)
  --             04/12/2018 - SCTASK0038255 - Yuri Mouts
  --                          substituido o uso do dbms_xlsprocessor pela chamada da gene0002.pc_clob_para_arquivo
  ---------------------------------------------------------------------------------------------------------------

  /* Procedure que gera uma lista de operadores em determinada pasta */
  PROCEDURE pc_lista_operadores(pr_dsdireto IN VARCHAR2) IS
    -- .........................................................................
    --
    --  Programa : pc_lista_operadores           
    --  Sistema  : Cred
    --  Sigla    : ACES0001
    --  Autor    : Tiago
    --  Data     : Fevereiro/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure que gera uma lista de operadores em determinada pasta
    ---------------------------------------------------------------------------------
    
    CURSOR cr_crapcop IS
      SELECT * FROM crapcop;
  
    CURSOR cr_crapope(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT crapope.cdoperad
           , crapope.nmoperad
           , crapope.nvoperad
           , crapope.flgperac
           , crapope.tpoperad
           , crapope.cdagenci
           , crapope.cdpactra
           , crapope.flgdonet
           , crapope.flgdopgd
           , crapope.flgacres
           , crapope.cdsitope
           , crapope.vlpagchq
           , crapope.vllimted
           , crapope.cdcomite
           , crapope.vlapvcre
           , crapope.vlapvcap
           , crapdpo.dsdepart
        FROM crapdpo
           , crapope 
       WHERE crapdpo.cddepart(+) = crapope.cddepart
         AND crapdpo.cdcooper(+) = crapope.cdcooper
         AND crapope.cdcooper = pr_cdcooper;
  
    vr_linha    VARCHAR2(4000);
    vr_arq_path VARCHAR2(1000); --> Diretorio que sera criado o relatorio
    vr_dscritic VARCHAR2(4000);           --> Retorna critica Caso ocorra    
  
    vr_des_xml        CLOB;
    vr_texto_completo VARCHAR2(32600);
  
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml,
                              vr_texto_completo,
                              pr_des_dados,
                              pr_fecha_xml);
    END;
  BEGIN
    -- Iniciar Variáveis     
    vr_arq_path := pr_dsdireto;
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    vr_texto_completo := NULL;
    pc_escreve_xml('CODIGO;COOPERATIVA;CODIGO OPERAD;NOME OPERAD;NIVEL;PERMISSAO DE ACESSO;TIPO;PA OPERADOR;PA TRABALHO;ACESSAR SISTEMA AIMARO WEB;ACESSAR SISTEMA RELACIONAMENTO;ACESSO RESTRITO AO PA;SITUACAO DO OPERADOR;DEPARTAMENTO;VALOR LIMITE;VALOR LIMITE TED;PARTICIPA DO COMITE;VALOR ALCADA CREDITO;VALOR ALCADA CAPTACAO;' ||
                   chr(10));
  
    FOR rw_crapcop IN cr_crapcop LOOP
      FOR rw_crapope IN cr_crapope(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      
        vr_linha := rw_crapcop.cdcooper || ';';
        vr_linha := vr_linha || rw_crapcop.nmrescop || ';';
        vr_linha := vr_linha || rw_crapope.cdoperad || ';';
        vr_linha := vr_linha || rw_crapope.nmoperad || ';';
      
        --nivel do operador
        CASE rw_crapope.nvoperad
          WHEN 1 THEN
            vr_linha := vr_linha || 'OPERADOR' || ';';
          WHEN 2 THEN
            vr_linha := vr_linha || 'SUPERVISOR' || ';';
          WHEN 3 THEN
            vr_linha := vr_linha || 'GERENTE' || ';';
          ELSE
            vr_linha := vr_linha || 'NAO IDENTIFICADO' || ';';
        END CASE;
      
        --Permissao de acesso
        IF rw_crapope.flgperac = 1 THEN
          vr_linha := vr_linha || 'SIM' || ';';
        ELSE
          vr_linha := vr_linha || 'NAO' || ';';
        END IF;
      
        --Tipo de operador 
        CASE rw_crapope.tpoperad
          WHEN 1 THEN
            vr_linha := vr_linha || 'TERMINAL' || ';';
          WHEN 2 THEN
            vr_linha := vr_linha || 'CAIXA' || ';';
          WHEN 3 THEN
            vr_linha := vr_linha || 'TERMINAL + CAIXA' || ';';
          WHEN 4 THEN
            vr_linha := vr_linha || 'RETAGUARDA' || ';';
          WHEN 5 THEN
            vr_linha := vr_linha || 'CASH + RETAGUARDA' || ';';
          WHEN 6 THEN
            vr_linha := vr_linha || 'PROGRID' || ';';
          ELSE
            vr_linha := vr_linha || 'NAO IDENTIFICADO' || ';';
        END CASE;
      
        vr_linha := vr_linha || rw_crapope.cdagenci || ';'; --PA operador
        vr_linha := vr_linha || rw_crapope.cdpactra || ';'; --PA trabalho
      
        --Acessar sistema Ayllos Web
        IF rw_crapope.flgdonet = 1 THEN
          vr_linha := vr_linha || 'SIM' || ';';
        ELSE
          vr_linha := vr_linha || 'NAO' || ';';
        END IF;
      
        --Acessar sistema Relacionamento
        IF rw_crapope.flgdopgd = 1 THEN
          vr_linha := vr_linha || 'SIM' || ';';
        ELSE
          vr_linha := vr_linha || 'NAO' || ';';
        END IF;
      
        --Acesso restrito ao PA
        IF rw_crapope.flgacres = 1 THEN
          vr_linha := vr_linha || 'SIM' || ';';
        ELSE
          vr_linha := vr_linha || 'NAO' || ';';
        END IF;
      
        --Situacao do operador ATIVO,BLOQUEADO
        CASE rw_crapope.cdsitope
          WHEN 1 THEN
            vr_linha := vr_linha || 'ATIVO' || ';';
          WHEN 2 THEN
            vr_linha := vr_linha || 'BLOQUEADO' || ';';
          ELSE
            vr_linha := vr_linha || 'NAO IDENTIFICADO' || ';';
        END CASE;
      
        vr_linha := vr_linha || rw_crapope.dsdepart || ';'; --Departamento
        vr_linha := vr_linha ||
                    TO_CHAR(rw_crapope.vlpagchq,
                            'FM99G999G999G999G999G999G999G990D00') || ';'; --Valor limite
        vr_linha := vr_linha ||
                    TO_CHAR(rw_crapope.vllimted,
                            'FM99G999G999G999G999G999G999G990D00') || ';'; --Valor limite TED
      
        --Participa do comite
        CASE rw_crapope.cdcomite
          WHEN 0 THEN
            vr_linha := vr_linha || '0-Nao Participa' || ';';
          WHEN 1 THEN
            vr_linha := vr_linha || '1-Local' || ';';
          WHEN 2 THEN
            vr_linha := vr_linha || '2-Sede' || ';';
          ELSE
            vr_linha := vr_linha || 'NAO IDENTIFICADO' || ';';
        END CASE;
      
        vr_linha := vr_linha ||
                    TO_CHAR(rw_crapope.vlapvcre,
                            'FM99G999G999G999G999G999G999G990D00') || ';'; --Valor alcada credito
        vr_linha := vr_linha ||
                    TO_CHAR(rw_crapope.vlapvcap,
                            'FM99G999G999G999G999G999G999G990D00') || ';'; --Valor alcada captacao
      
        --dbms_output.put_line(vr_linha);
        pc_escreve_xml(vr_linha || chr(10));
      END LOOP;
    END LOOP;
  
    pc_escreve_xml(' ', TRUE);
    -- SCTASK0035225 (Yuri - Mouts)
/*    DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml,
                                vr_arq_path,
                                'LISTA_OPERADORES_OPERAD'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.txt',
                                NLS_CHARSET_ID('UTF8'));*/
    --Criar o arquivo no diretorio especificado 
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                 ,pr_caminho  => vr_arq_path
                                 ,pr_arquivo  => 'LISTA_OPERADORES_OPERAD'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.txt'
                                 ,pr_des_erro => vr_dscritic);
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN
    -- RAISE vr_exc_erro;
    -- Como todas procedures desta PCK não possuem tratamento de erros, esta também será mantida desta forma
       NULL;
    END IF;
	  -- Fim SCTASK0038225
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
  
  END pc_lista_operadores;
  
  
  /* Procedures que gera uma lista com operadores e suas permissoes
     de acesso no sistema ayllos */
  PROCEDURE pc_lista_permissoes_operadores(pr_dsdireto IN VARCHAR2) IS
    -- .........................................................................
    --
    --  Programa : pc_lista_permissoes_operadores
    --  Sistema  : Cred
    --  Sigla    : ACES0001
    --  Autor    : Tiago
    --  Data     : Fevereiro/2016.                   Ultima atualizacao: 19/07/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedures que gera uma lista com operadores e suas permissoes
    --               de acesso no sistema ayllos
    --
    --   Alteracoes: 19/07/2016 - Adicionado LOWER na comparação para ajustar o problema
    --                            do chamado 478321. (Kelvin)
    --
    -------------------------------------------------------------------------------
  
    CURSOR cr_crapcop IS
    SELECT * FROM crapcop;

    CURSOR cr_craptel(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT *
        FROM craptel
       WHERE craptel.cdcooper = pr_cdcooper;
    
    CURSOR cr_crapace IS 
      SELECT *
        FROM crapace;    

    CURSOR cr_crapope(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT *
        FROM crapope
       WHERE crapope.cdcooper        = pr_cdcooper
         AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
         
    rw_crapope cr_crapope%ROWTYPE;     

    TYPE typ_rec_tela_opc IS RECORD
         (cdcooper crapcop.cdcooper%TYPE,
          nmrescop crapcop.nmrescop%TYPE,
          nmdatela craptel.nmdatela%TYPE,
          cddopcao crapace.cddopcao%TYPE,
          dsdopcao craptel.lsopptel%TYPE,
          nmrotina craptel.nmrotina%TYPE,
          cdoperad crapace.cdoperad%TYPE,
          nmoperad crapope.nmoperad%TYPE);
          
    TYPE typ_tab_tela_opc IS TABLE OF typ_rec_tela_opc
      INDEX BY VARCHAR2(45); --cdcooper(3)/nmdatela(10)/nmrotina(25)/cddopcao(7)

    vr_tab_tela  typ_tab_tela_opc;
    vr_indice    VARCHAR2(45);
    vr_cddopcao  VARCHAR2(7);
    vr_linha     VARCHAR2(4000);
    vr_count     INTEGER;
    vr_tab_split gene0002.typ_split;
    
    vr_arq_path  VARCHAR2(1000);        --> Diretorio que sera criado o relatorio
    
    vr_count      NUMBER := 0;
     
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    vr_dscritic VARCHAR2(4000);           --> Retorna critica Caso ocorra    
    
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
    --
  BEGIN  
    vr_tab_tela.delete;

    FOR rw_crapcop IN cr_crapcop LOOP
      
      FOR rw_craptel IN cr_craptel(pr_cdcooper => rw_crapcop.cdcooper) LOOP   
          
          vr_tab_split := gene0002.fn_quebra_string(rw_craptel.cdopptel,',');
          
          vr_cddopcao  := vr_tab_split.FIRST;
          
          WHILE vr_cddopcao IS NOT NULL LOOP
            vr_indice := LPAD(rw_crapcop.cdcooper, 3, '0')||LPAD(rw_craptel.nmdatela, 10, ' ')||LPAD(rw_craptel.nmrotina, 25, ' ')||LPAD(vr_tab_split(vr_cddopcao), 7, ' ');   
            
            vr_tab_tela(vr_indice).cdcooper := rw_crapcop.cdcooper;
            vr_tab_tela(vr_indice).nmrescop := rw_crapcop.nmrescop;
            vr_tab_tela(vr_indice).nmdatela := rw_craptel.nmdatela;
            vr_tab_tela(vr_indice).cddopcao := vr_tab_split(vr_cddopcao);
            vr_tab_tela(vr_indice).dsdopcao := gene0002.fn_busca_entrada(pr_postext => vr_cddopcao, pr_dstext => rw_craptel.lsopptel, pr_delimitador => ',');
            vr_tab_tela(vr_indice).nmrotina := rw_craptel.nmrotina;
            
            
            vr_cddopcao := vr_tab_split.NEXT(vr_cddopcao);    
          END LOOP;
      
      END LOOP;
      
    END LOOP;  
    
    
    
    -- Iniciar Variáveis     
    vr_arq_path := pr_dsdireto;  
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    vr_texto_completo := NULL;
    pc_escreve_xml( 'CODIGO;COOPERATIVA;IDSISTEMA;SISTEMA;TELA;ROTINA;COD OPCAO;DESC OPCAO;OPERADOR;NOME OPERADOR;'||chr(10));
    
    FOR rw_crapace IN cr_crapace LOOP
      
        vr_indice := LPAD(rw_crapace.cdcooper, 3, '0')||LPAD(LOWER(rw_crapace.nmdatela), 10, ' ')||LPAD(rw_crapace.nmrotina, 25, ' ')||LPAD(rw_crapace.cddopcao, 7, ' ');
    
        IF vr_tab_tela.EXISTS(vr_indice) THEN
        
           OPEN cr_crapope(pr_cdcooper => rw_crapace.cdcooper
                          ,pr_cdoperad => rw_crapace.cdoperad);
           FETCH cr_crapope INTO rw_crapope;
           
           IF cr_crapope%FOUND THEN
              CLOSE cr_crapope;
              
              vr_linha := LPAD(rw_crapace.cdcooper, 2, '0')||';';
              vr_linha := vr_linha || UPPER(vr_tab_tela(vr_indice).nmrescop)||';';
              vr_linha := vr_linha || LPAD(rw_crapace.idambace, 2, '0')||';';
              
              IF rw_crapace.idambace = 1 THEN
                 vr_linha := vr_linha || 'AIMARO CARACTER' ||';';
              ELSE
                 IF rw_crapace.idambace = 2 THEN
                    vr_linha := vr_linha || 'AIMARO WEB' ||';';
                 ELSE
                    vr_linha := vr_linha || 'PROGRID' ||';';  
                 END IF;
              END IF;   
              
              vr_linha := vr_linha || UPPER(rw_crapace.nmdatela)||';';
              vr_linha := vr_linha || UPPER(rw_crapace.nmrotina)||';';
              
              vr_linha := vr_linha || UPPER(vr_tab_tela(vr_indice).cddopcao)||';';
              vr_linha := vr_linha || UPPER(vr_tab_tela(vr_indice).dsdopcao)||';';
              
              vr_linha := vr_linha || UPPER(rw_crapope.cdoperad)||';';
              vr_linha := vr_linha || UPPER(rw_crapope.nmoperad)||';';
              
              
              pc_escreve_xml( vr_linha || chr(10));
              --dbms_output.put_line( vr_linha );
              
              CONTINUE;
           END IF;
           
           CLOSE cr_crapope;
          
        END IF;  
        
    END LOOP;
    
    pc_escreve_xml(' ',TRUE);
    -- SCTASK0038225
/*  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_arq_path, 'LISTA_ACESSO_OPERADORES'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.txt', NLS_CHARSET_ID('UTF8'));*/
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                 ,pr_caminho  => vr_arq_path
                                 ,pr_arquivo  => 'LISTA_ACESSO_OPERADORES'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.txt'
                                 ,pr_des_erro => vr_dscritic);
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN
--     RAISE vr_exc_erro;
--     Como todas procedures desta PCK não possuem tratamento de erros, esta também será mantida desta forma
       NULL;
    END IF;
	  -- Fim SCTASK0038225
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    --
  END pc_lista_permissoes_operadores;
    


  /* Procedure que a permissao dos operadores baseados em um arquivo de entrada */
  PROCEDURE pc_exclui_permis_ope(pr_dsdireto IN VARCHAR2) IS
    -- .........................................................................
    --
    --  Programa : pc_lista_operadores           
    --  Sistema  : Cred
    --  Sigla    : ACES0001
    --  Autor    : Tiago
    --  Data     : Marco/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure que a permissao dos operadores baseados em um arquivo de entrada
    ---------------------------------------------------------------------------------

    -->> CURSORES <<--
    CURSOR cr_crapace(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nmdatela crapace.nmdatela%TYPE
                     ,pr_nmrotina crapace.nmrotina%TYPE
                     ,pr_cddopcao crapace.cddopcao%TYPE
                     ,pr_cdoperad crapace.cdoperad%TYPE
                     ,pr_idambace crapace.idambace%TYPE) IS
      SELECT ROWID, crapace.*
        FROM crapace
       WHERE crapace.cdcooper = pr_cdcooper 
         AND UPPER(crapace.nmdatela) = pr_nmdatela
         AND NVL(TRIM(UPPER(crapace.nmrotina)),' ') = NVL(TRIM(pr_nmrotina),' ')
         AND UPPER(crapace.cddopcao) = pr_cddopcao
         AND UPPER(crapace.cdoperad) = pr_cdoperad 
         AND idambace = pr_idambace;
    rw_crapace cr_crapace%ROWTYPE;

    -->> VARIAVEIS <<--    
    vr_dsdireto   VARCHAR2(4000);            --> Descrição do diretorio onde o arquivo se enconta
    vr_nmarquiv   VARCHAR2(100);            --> Nome do arquivo a ser importado
    vr_dscritic   VARCHAR2(4000);           --> Retorna critica Caso ocorra    
    vr_ind_arquiv utl_file.file_type;
    vr_ind_arqlog utl_file.file_type;
    vr_dslinha    VARCHAR2(4000);              
    
    vr_exc_erro   EXCEPTION;
    
    -- Array para guardar o split dos dados contidos na dstexttb
    vr_vet_dados gene0002.typ_split;

    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);

    vr_dscomando VARCHAR2(4000); --> Comando completo
    -- Saida da OS Command
    vr_des_erro  VARCHAR2(4000);
    vr_typ_saida VARCHAR2(4000);

    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;

  BEGIN
  
    vr_dsdireto := pr_dsdireto;
    vr_nmarquiv := 'LOG_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.txt';
    
    --Criar arquivo de log
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto        --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarquiv        --> Nome do arquivo
                            ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arqlog      --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);      --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN        
       RAISE vr_exc_erro;
    END IF;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Inicio Processo');  
    
    vr_nmarquiv := 'EXCLUI_ACESSO_OPERADORES.csv';
    
    --Abrir arquivo
    gene0001.pc_abre_arquivo ( pr_nmdireto => vr_dsdireto    --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                              ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arquiv  --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);  --> Erro
                      
    IF vr_dscritic IS NOT NULL THEN
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Nao foi possivel ler o arquivo de entrada');  
        --Levantar Excecao
        RAISE vr_exc_erro;
    END IF;
  
    BEGIN     

      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      vr_texto_completo := NULL;
    
      LOOP
        
        -- Verifica se o arquivo está aberto
        IF utl_file.IS_OPEN(vr_ind_arquiv) THEN

           gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                       ,pr_des_text => vr_dslinha);  --> Texto lido
                                       
           --1CODIGO;2COOPERATIVA;3IDSISTEMA;4SISTEMA;5TELA;6ROTINA;7COD OPCAO;8DESC OPCAO;9OPERADOR;10NOME OPERADOR
           vr_vet_dados := gene0002.fn_quebra_string(pr_string => vr_dslinha, pr_delimit => ';');
           
           --Verifica se o registro existe realmente na crapace
           OPEN cr_crapace(pr_cdcooper => vr_vet_dados(1)
                          ,pr_nmdatela => vr_vet_dados(5)
                          ,pr_nmrotina => vr_vet_dados(6)
                          ,pr_cddopcao => vr_vet_dados(7)
                          ,pr_cdoperad => vr_vet_dados(9)
                          ,pr_idambace => vr_vet_dados(3) );
           FETCH cr_crapace INTO rw_crapace;
           
           IF cr_crapace%NOTFOUND THEN
              gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Nao encontrado('||vr_dslinha||')');  
              CLOSE cr_crapace;
              CONTINUE;
           END IF;
           
           CLOSE cr_crapace;     
           
           pc_escreve_xml('INSERT '||
                            'INTO crapace(nmdatela, cddopcao,'||
                                         'cdoperad, nmrotina,'||
                                         'cdcooper, nrmodulo,'||
                                         'idevento, idambace)'||
                           'VALUES('''||rw_crapace.nmdatela||''','''||rw_crapace.cddopcao||''','''||
                                        rw_crapace.cdoperad||''','''||rw_crapace.nmrotina||''','''||
                                        rw_crapace.cdcooper||''','''||rw_crapace.nrmodulo||''','''||
                                        rw_crapace.idevento||''','''||rw_crapace.idambace||''');'||chr(10));
           
           BEGIN
             DELETE 
               FROM crapace 
              WHERE crapace.rowid = rw_crapace.rowid;              
           EXCEPTION
             WHEN OTHERS THEN
               gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Problema ao excluir acesso('||vr_dslinha||')');  
               RAISE vr_exc_erro;   
           END;

        END IF;        
      END LOOP;

    EXCEPTION
      WHEN no_data_found THEN        
        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
        
        pc_escreve_xml('COMMIT;');
        pc_escreve_xml(' ',TRUE);
        -- SCTASK0038225
/*      DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_dsdireto, 'ACESSO_OPERADORES_DELETADOS_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.txt', NLS_CHARSET_ID('UTF8'));*/
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                     ,pr_caminho  => vr_dsdireto
                                     ,pr_arquivo  => 'ACESSO_OPERADORES_DELETADOS_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.txt'
                                     ,pr_des_erro => vr_dscritic);
        -- em caso de crítica
        IF vr_dscritic IS NOT NULL THEN
    --     RAISE vr_exc_erro;
    --     Como todas procedures desta PCK não possuem tratamento de erros, esta também será mantida desta forma
           NULL;
        END IF;
        -- Fim SCTASK0038225

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        
    END;   
    
    -- Executa comando UNIX
    vr_dscomando := 'ux2dos < ' || vr_dsdireto ||'/'|| vr_nmarquiv || ' | tr -d "\032" ' ||
                    ' > ' || vr_dsdireto ||'/'|| vr_nmarquiv || '.' || to_char(sysdate,'ddmmyyyy_hh24miss') || ' 2>/dev/null';
    -- Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_des_erro);
                         
    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;    

    -- Executa comando UNIX
    vr_dscomando := 'rm ' || vr_dsdireto || '/' || vr_nmarquiv || ' 2>/dev/null';
    -- Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_des_erro);
                         
    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;    

    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Final Processo');  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  
    
    COMMIT;   
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Final Processo com erros');  
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  
      ROLLBACK;
    WHEN OTHERS THEN
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Erro Inesperado');  
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  
      ROLLBACK;  
  END pc_exclui_permis_ope;


PROCEDURE pc_exc_permis_ope_tela(
    pr_dsdireto IN VARCHAR2, -- diretorio onde os arquivos serão gerados
    pr_nmdatela IN VARCHAR2, -- nome da tela que as permissões devem ser excluidas
    pr_cdopptel IN VARCHAR2 -- listsa de opcoes da tela a serem excluidas
) IS
    -- .........................................................................
    --
    --  Programa : pc_lista_permissoes_operadores
    --  Sistema  : Cred
    --  Sigla    : ACES0001
    --  Autor    : Tiago
    --  Data     : Fevereiro/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedures que gera uma lista com operadores e suas permissoes
    --               de acesso no sistema ayllos
    -------------------------------------------------------------------------------
  
    CURSOR cr_crapcop IS
    SELECT * FROM crapcop;

    CURSOR cr_craptel(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT *
        FROM craptel
       WHERE craptel.cdcooper = pr_cdcooper and nmdatela = pr_nmdatela;
    
    CURSOR cr_crapace IS 
      SELECT ROWID, crapace.*
        FROM crapace
      WHERE nmdatela = pr_nmdatela;

    CURSOR cr_crapope(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT *
        FROM crapope
       WHERE crapope.cdcooper        = pr_cdcooper
         AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
         
    rw_crapope cr_crapope%ROWTYPE;     

    TYPE typ_rec_tela_opc IS RECORD
         (cdcooper crapcop.cdcooper%TYPE,
          nmrescop crapcop.nmrescop%TYPE,
          nmdatela craptel.nmdatela%TYPE,
          cddopcao crapace.cddopcao%TYPE,
          dsdopcao craptel.lsopptel%TYPE,
          nmrotina craptel.nmrotina%TYPE,
          cdoperad crapace.cdoperad%TYPE,
          nmoperad crapope.nmoperad%TYPE);
          
    TYPE typ_tab_tela_opc IS TABLE OF typ_rec_tela_opc
      INDEX BY VARCHAR2(45); --cdcooper(3)/nmdatela(10)/nmrotina(25)/cddopcao(7)

    vr_tab_tela  typ_tab_tela_opc;
    vr_indice    VARCHAR2(45);
    vr_cddopcao  VARCHAR2(7);
    vr_linha     VARCHAR2(4000);
    vr_count     INTEGER;
    vr_tab_split gene0002.typ_split;
    
    vr_arq_path  VARCHAR2(1000);        --> Diretorio que sera criado o relatorio
    
    vr_count      NUMBER := 0;
     
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    vr_dscritic VARCHAR2(4000);           --> Retorna critica Caso ocorra    
    
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
  
  BEGIN  
    vr_tab_tela.delete;

    FOR rw_crapcop IN cr_crapcop LOOP
      
      FOR rw_craptel IN cr_craptel(pr_cdcooper => rw_crapcop.cdcooper) LOOP   
          
          vr_tab_split := gene0002.fn_quebra_string(rw_craptel.cdopptel,',');
          
          vr_cddopcao  := vr_tab_split.FIRST;
          
          WHILE (vr_cddopcao IS NOT NULL) LOOP
            IF ( INSTR(pr_cdopptel, vr_tab_split(vr_cddopcao)) > 0 ) THEN
              vr_indice := LPAD(rw_crapcop.cdcooper, 3, '0')||LPAD(rw_craptel.nmdatela, 10, ' ')||LPAD(rw_craptel.nmrotina, 25, ' ')||LPAD(vr_tab_split(vr_cddopcao), 7, ' ');   
              
              vr_tab_tela(vr_indice).cdcooper := rw_crapcop.cdcooper;
              vr_tab_tela(vr_indice).nmrescop := rw_crapcop.nmrescop;
              vr_tab_tela(vr_indice).nmdatela := rw_craptel.nmdatela;
              vr_tab_tela(vr_indice).cddopcao := vr_tab_split(vr_cddopcao);
              vr_tab_tela(vr_indice).dsdopcao := gene0002.fn_busca_entrada(pr_postext => vr_cddopcao, pr_dstext => rw_craptel.lsopptel, pr_delimitador => ',');
              -- vr_tab_tela(vr_indice).nmrotina := rw_craptel.nmrotina;
              vr_tab_tela(vr_indice).nmrotina := '"' || vr_tab_split(vr_cddopcao) || '", "' || pr_cdopptel || '","' || INSTR(pr_cdopptel, vr_tab_split(vr_cddopcao)) || '"';
            END IF;
            
            vr_cddopcao := vr_tab_split.NEXT(vr_cddopcao);    
          END LOOP;
      
      END LOOP;
      
    END LOOP;  
    
    -- Iniciar Variáveis     
    vr_arq_path := pr_dsdireto;  
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    vr_texto_completo := NULL;
    -- pc_escreve_xml( 'CODIGO;COOPERATIVA;IDSISTEMA;SISTEMA;TELA;ROTINA;COD OPCAO;DESC OPCAO;OPERADOR;NOME OPERADOR;'||chr(10));
    
    FOR rw_crapace IN cr_crapace LOOP
      
        vr_indice := LPAD(rw_crapace.cdcooper, 3, '0')||LPAD(rw_crapace.nmdatela, 10, ' ')||LPAD(rw_crapace.nmrotina, 25, ' ')||LPAD(rw_crapace.cddopcao, 7, ' ');
    
        IF vr_tab_tela.EXISTS(vr_indice) THEN
        
           OPEN cr_crapope(pr_cdcooper => rw_crapace.cdcooper
                          ,pr_cdoperad => rw_crapace.cdoperad);
           FETCH cr_crapope INTO rw_crapope;
           
           IF cr_crapope%FOUND THEN
              vr_linha := 'INSERT '||
                            'INTO crapace(nmdatela, cddopcao,'||
                                         'cdoperad, nmrotina,'||
                                         'cdcooper, nrmodulo,'||
                                         'idevento, idambace)'||
                           'VALUES('''||rw_crapace.nmdatela||''','''||rw_crapace.cddopcao||''','''||
                                        rw_crapace.cdoperad||''','''||rw_crapace.nmrotina||''','''||
                                        rw_crapace.cdcooper||''','''||rw_crapace.nrmodulo||''','''||
                                        rw_crapace.idevento||''','''||rw_crapace.idambace||''');';
              
              
              pc_escreve_xml( vr_linha || chr(10));
              --dbms_output.put_line( vr_linha );

              --- EXCLUSÃO
              BEGIN
               DELETE 
                 FROM crapace 
                WHERE crapace.rowid = rw_crapace.rowid;              

              EXCEPTION
               WHEN OTHERS THEN
                 pc_escreve_xml(to_char(sysdate,'ddmmyyyy_hh24miss')||' - Problema ao excluir acesso('||vr_linha||')');
              END;
              
              CLOSE cr_crapope;

              CONTINUE;
           END IF;
           
           CLOSE cr_crapope;
           
        END IF;  
        
    END LOOP;
    
    pc_escreve_xml(' ',TRUE);
    -- SCTASK0038225
/*  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_arq_path, 'LISTA_ACESSO_OPERADORES'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.txt', NLS_CHARSET_ID('UTF8'));*/
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                 ,pr_caminho  => vr_arq_path
                                 ,pr_arquivo  => 'LISTA_ACESSO_OPERADORES'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.txt'
                                 ,pr_des_erro => vr_dscritic);
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN
--     RAISE vr_exc_erro;
--     Como todas procedures desta PCK não possuem tratamento de erros, esta também será mantida desta forma
       NULL;
    END IF;
	  -- Fim SCTASK0038225

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

  END pc_exc_permis_ope_tela;
END ACES0001;
/
