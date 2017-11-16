CREATE OR REPLACE PACKAGE CECRED.gene0010 AS

  /*---------------------------------------------------------------------------------------------------------------

      Programa : gene0010
      Sistema  : Rotinas genéricas
      Sigla    : GENE
      Autor    : Odirlei Busana - AMcom
      Data     : Agosto/2017.                   Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas genericas para busca de dominios

      Alterações:
  ------------------------------------------------------------------------------------------------------------------*/
  --------------> CURSORES <------------------
  
  ------------> TEMPTABLES <------------------
  --> Variavel para armazenar os dominios
  TYPE typ_rec_dominio 
       IS RECORD (cddominio tbcadast_dominio_campo.cddominio%TYPE,
                  dscodigo  tbcadast_dominio_campo.dscodigo%TYPE);
   
  TYPE typ_tab_dominio IS TABLE OF typ_rec_dominio    
       INDEX BY PLS_INTEGER;
  
  --------------> ROTINAS <-------------------
  /******************************************************************************/
  /**   Function para retornar descrição de campos da tabela                   **/
  /******************************************************************************/
  FUNCTION fn_desc_campo (pr_nmtabela IN  VARCHAR2, --> Nome da tabela
                          pr_nmcmpret IN  VARCHAR2, --> Nome do Campo a ser retornado
                          pr_nmcamppk IN  VARCHAR2, --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                          pr_dsvalpes IN  VARCHAR2, --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                          pr_dscritic OUT VARCHAR2) --> Retorna critica
             RETURN VARCHAR2;
  
  --> Função para retornar descrição do dominio.
  FUNCTION fn_desc_dominio ( pr_nmmodulo   IN VARCHAR2,       --> Nome do modulo(CADAST, COBRAN, etc.)
                             pr_nmdomini   IN VARCHAR2,       --> Nome do dominio
                             pr_cddomini   IN VARCHAR2        --> Codigo que deseja retornar descrição
                             -----> OUT <------                              
                             ) RETURN VARCHAR2;

  --> Procedure para retornar as opçoes do dominio.
  PROCEDURE pc_retorna_dominios (pr_nmmodulo   IN VARCHAR2,           --> Nome do modulo(CADAST, COBRAN, etc.)
                                 pr_nmdomini   IN VARCHAR2,           --> Nome do dominio                              
                                 -----> OUT <------    
                                 pr_tab_dominios OUT typ_tab_dominio, --> retorna os dados dos dominios                          
                                 pr_dscritic     OUT VARCHAR2         --> retorna descricao da critica
                                 );    
                                 
  --> Função para retornar descrição do dominio SIM_NAO.
  FUNCTION fn_desc_sim_nao ( pr_cddomini   IN VARCHAR2        --> Codigo que deseja retornar descrição
                           ) RETURN VARCHAR2;                                 
END  gene0010;
/
CREATE OR REPLACE PACKAGE BODY CECRED.gene0010 AS

  /*---------------------------------------------------------------------------------------------------------------

      Programa : gene0010
      Sistema  : Rotinas genéricas
      Sigla    : GENE
      Autor    : Odirlei Busana - AMcom
      Data     : Agosto/2017.                   Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas genericas para busca de dominios

      Alterações:
  ------------------------------------------------------------------------------------------------------------------*/
  
  /******************************************************************************/
  /**   Function para retornar descrição de campos da tabela                   **/
  /******************************************************************************/
  FUNCTION fn_desc_campo (pr_nmtabela IN  VARCHAR2, --> Nome da tabela
                          pr_nmcmpret IN  VARCHAR2, --> Nome do Campo a ser retornado
                          pr_nmcamppk IN  VARCHAR2, --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                          pr_dsvalpes IN  VARCHAR2, --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                          pr_dscritic OUT VARCHAR2) --> Retorna critica
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_campo      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição de campos da tabela       
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    
    -- Variáveis para criação de cursor dinâmico
    vr_nrcursor      NUMBER;
    vr_nrretorn      NUMBER;
    vr_qtdretor      NUMBER;
    vr_cursor        VARCHAR2(32000);
    vr_dsdcampo      VARCHAR2(4000);
    
    vr_tab_campos    gene0002.typ_split;
    vr_tab_valores   gene0002.typ_split;
                  
  BEGIN
  
    
    vr_cursor := 'SELECT ' || pr_nmcmpret ||
                 '  FROM ' || pr_nmtabela;
    
    IF instr(pr_nmcamppk,'|') = 0 THEN 
      vr_cursor := vr_cursor ||' WHERE ' || pr_nmcamppk ||' = '''|| pr_dsvalpes ||'''';
    ELSE
      vr_tab_campos := gene0002.fn_quebra_string (pr_string  => pr_nmcamppk, 
                                                  pr_delimit => '|');
      vr_tab_valores := gene0002.fn_quebra_string (pr_string  => pr_dsvalpes, 
                                                   pr_delimit => '|');
                                                   
      IF vr_tab_campos.count <> vr_tab_valores.count THEN 
        pr_dscritic := 'Parametros invalidos.';
        RETURN NULL;
      END IF;
      
      FOR i IN vr_tab_campos.first..vr_tab_campos.last LOOP
        IF i = vr_tab_campos.first THEN
          vr_cursor := vr_cursor ||' WHERE ';
        ELSE
          vr_cursor := vr_cursor ||' AND ';
        END IF;
       
        vr_cursor := vr_cursor || vr_tab_campos(i) ||' = '''|| vr_tab_valores(i) ||'''';
      END LOOP;
                                                   
    END IF;  
     
    -- Cria cursor dinâmico
    vr_nrcursor := dbms_sql.open_cursor;
    -- Comando Parse
    dbms_sql.parse(vr_nrcursor, vr_cursor, 1);
    
    -- Definindo Colunas de retorno
    dbms_sql.define_column(vr_nrcursor, 1, vr_dsdcampo,4000);
    -- Execução do select dinamico
    vr_nrretorn := dbms_sql.execute(vr_nrcursor);
    vr_qtdretor  := 0;
        
    LOOP 
      -- Verifica se há alguma linha de retorno do cursor
      vr_nrretorn := dbms_sql.fetch_rows(vr_nrcursor);
      if vr_nrretorn = 0 THEN
        -- Se o cursor dinamico está aberto
        IF dbms_sql.is_open(vr_nrcursor) THEN
          -- Fecha o mesmo
          dbms_sql.close_cursor(vr_nrcursor);
        END IF;
        EXIT;
      ELSE 
        vr_qtdretor := vr_qtdretor + 1;
        
        IF vr_qtdretor > 1 THEN
          pr_dscritic := 'Consulta na tabela '|| pr_nmtabela ||' retornou mais de um registro';
        END IF;
      
        -- Carrega variáveis com o retorno do cursor
        dbms_sql.column_value(vr_nrcursor, 1, vr_dsdcampo);
      END IF;   
    END LOOP;
    
    RETURN vr_dsdcampo;
  END fn_desc_campo;    
  
  --> Função para retornar descrição do dominio.
  FUNCTION fn_desc_dominio ( pr_nmmodulo   IN VARCHAR2,       --> Nome do modulo(CADAST, COBRAN, etc.)
                             pr_nmdomini   IN VARCHAR2,       --> Nome do dominio
                             pr_cddomini   IN VARCHAR2        --> Codigo que deseja retornar descrição
                             -----> OUT <------                              
                             ) RETURN VARCHAR2 IS  
  /* ..........................................................................
  --
  --  Programa : fn_desc_dominio
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana(AMcom)
  --  Data     : Agosto/2017.                   Ultima atualizacao: 
  --
  --  Dados referentes ao programa:
  --
  --   Frequencia: Sempre que for chamado
  --   Objetivo  : Função para retornar descrição do dominio.
  --
  --
  --  Alteração : 
  -- ..........................................................................*/
    
    ------------------> CURSORES <----------------
      
      
      
    -----------------> VARIAVEIS <-----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_nmtabela     VARCHAR2(200);
    vr_dsdomini     tbcadast_dominio_campo.dscodigo%TYPE;
    -----------------> SUBPROGRAMAS <--------------
      
      
  BEGIN
      
    --> Caso não foi informado modulo, retorna nulo
    IF pr_nmmodulo IS NULL THEN
      RETURN NULL;
    END IF;  
      
    vr_nmtabela := 'TB'||UPPER(pr_nmmodulo)||'_DOMINIO_CAMPO';
      
    vr_dsdomini := fn_desc_campo( pr_nmtabela => vr_nmtabela,          --> Nome da tabela
                                 pr_nmcmpret => 'DSCODIGO',            --> Nome do Campo a ser retornado
                                 pr_nmcamppk => 'NMDOMINIO|CDDOMINIO', --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                                 pr_dsvalpes => pr_nmdomini||'|'||pr_cddomini,  --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                                 pr_dscritic => vr_dscritic);          --> Retorna critica
      
    
    RETURN vr_dsdomini;
    
  EXCEPTION
    WHEN vr_exc_erro  THEN
       RETURN NULL;
    WHEN OTHERS THEN
       RETURN NULL;
  END fn_desc_dominio;
    
  --> Procedure para retornar as opçoes do dominio.
  PROCEDURE pc_retorna_dominios (pr_nmmodulo   IN VARCHAR2,           --> Nome do modulo(CADAST, COBRAN, etc.)
                                 pr_nmdomini   IN VARCHAR2,           --> Nome do dominio                              
                                 -----> OUT <------    
                                 pr_tab_dominios OUT typ_tab_dominio, --> retorna os dados dos dominios                          
                                 pr_dscritic     OUT VARCHAR2         --> retorna descricao da critica
                                 ) IS  
  /* ..........................................................................
  --
  --  Programa : pc_retorna_dominios
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana(AMcom)
  --  Data     : Agosto/2017.                   Ultima atualizacao: 
  --
  --  Dados referentes ao programa:
  --
  --   Frequencia: Sempre que for chamado
  --   Objetivo  : Procedure para retornar as opçoes do dominio.
  --
  --
  --   Alteração : 
  -- ..........................................................................*/
    
    ------------------> CURSORES <----------------
      
      
      
    -----------------> VARIAVEIS <-----------------
    vr_nrcursor      NUMBER;
    vr_nrretorn      NUMBER;
    vr_qtdretor      NUMBER;
    vr_cursor        VARCHAR2(32000);
    
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_nmtabela     VARCHAR2(200);
    
    -----------------> SUBPROGRAMAS <--------------
      
      
  BEGIN
      
    --> Caso não foi informado modulo, retorna nulo
    IF pr_nmmodulo IS NULL THEN
      vr_dscritic := 'Modulo deve ser informado';
    END IF;  
      
    vr_nmtabela := 'TB'||UPPER(pr_nmmodulo)||'_DOMINIO_CAMPO';
    
    vr_cursor := 'SELECT cddominio,dscodigo FROM ' || vr_nmtabela;
    vr_cursor := vr_cursor||' where nmdominio = '''|| pr_nmdomini || ''''; 
     
    -- Cria cursor dinâmico
    vr_nrcursor := dbms_sql.open_cursor;
    -- Comando Parse
    dbms_sql.parse(vr_nrcursor, vr_cursor, 1);
    
    -- Definindo Colunas de retorno
    dbms_sql.define_column(vr_nrcursor, 1, pr_tab_dominios(1).cddominio ,4000);
    dbms_sql.define_column(vr_nrcursor, 1, pr_tab_dominios(1).dscodigo  ,4000);
    
    -- Execução do select dinamico
    vr_nrretorn := dbms_sql.execute(vr_nrcursor);
    vr_qtdretor  := 0;
        
    LOOP 
      -- Verifica se há alguma linha de retorno do cursor
      vr_nrretorn := dbms_sql.fetch_rows(vr_nrcursor);
      if vr_nrretorn = 0 THEN
        -- Se o cursor dinamico está aberto
        IF dbms_sql.is_open(vr_nrcursor) THEN
          -- Fecha o mesmo
          dbms_sql.close_cursor(vr_nrcursor);
        END IF;
        EXIT;
      ELSE 
        vr_qtdretor := vr_qtdretor + 1;        
        -- Carrega variáveis com o retorno do cursor
        dbms_sql.column_value(vr_nrcursor, 1, pr_tab_dominios(vr_qtdretor).cddominio);
        dbms_sql.column_value(vr_nrcursor, 1, pr_tab_dominios(vr_qtdretor).dscodigo );
      END IF;   
    END LOOP;
    
    
  EXCEPTION
    WHEN vr_exc_erro  THEN
       pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
       pr_dscritic := 'Erro nao tratado ao carregar dominio:'||SQLERRM;
  END pc_retorna_dominios;
  
  --> Função para retornar descrição do dominio SIM_NAO.
  FUNCTION fn_desc_sim_nao ( pr_cddomini   IN VARCHAR2        --> Codigo que deseja retornar descrição
                           ) RETURN VARCHAR2 IS  
  /* ..........................................................................
  --
  --  Programa : fn_desc_sim_nao
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana(AMcom)
  --  Data     : Agosto/2017.                   Ultima atualizacao: 
  --
  --  Dados referentes ao programa:
  --
  --   Frequencia: Sempre que for chamado
  --   Objetivo  : Função para retornar descrição do dominio SIM_NAO..
  --
  --
  --  Alteração : 
  -- ..........................................................................*/
    
    ------------------> CURSORES <----------------
      
      
      
    -----------------> VARIAVEIS <-----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    -----------------> SUBPROGRAMAS <--------------
            
  BEGIN
      
    RETURN GENE0010.fn_desc_dominio( pr_nmmodulo   => 'CADAST',                  --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => ' SIM_NAO',   --> Nome do dominio
                                     pr_cddomini   => pr_cddomini); --> Codigo que deseja retornar descrição
    
  EXCEPTION
    WHEN vr_exc_erro  THEN
       RETURN NULL;
    WHEN OTHERS THEN
       RETURN NULL;
  END fn_desc_sim_nao;
    
END  gene0010;
/
