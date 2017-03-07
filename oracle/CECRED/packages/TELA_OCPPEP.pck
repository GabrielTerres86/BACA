CREATE OR REPLACE PACKAGE CECRED.TELA_OCPPEP AS

   /*
   Programa: TELA_OCPPEP                          
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Adriano 
   Data    : Fevereiro/2017                       Ultima atualizacao:
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela OCPPEP, manutenção de natureza de ocupação e ocupações.

   Alteracoes: 
    
   */               
   
  /* Tabela para guardar as naturezas de ocupação */
  TYPE typ_natureza_ocupacao IS RECORD 
    (cdnatocp gncdnto.cdnatocp%TYPE
    ,dsnatocp gncdnto.dsnatocp%TYPE
    ,rsnatocp gncdnto.rsnatocp%TYPE);
       
  /* Tabela para guardar as naturezas de ocupação */
  TYPE typ_tab_natureza_ocupacao IS TABLE OF typ_natureza_ocupacao INDEX BY PLS_INTEGER;

  /* Tabela para guardar as ocupações */
  TYPE typ_ocupacoes IS RECORD 
    (cdocupa  gncdocp.cdocupa%TYPE
    ,dsdocupa gncdocp.dsdocupa%TYPE
    ,cdnatocp gncdocp.cdnatocp%TYPE
    ,rsdocupa gncdocp.rsdocupa%TYPE);
    
  /* Tabela para guardar as ocupações */
  TYPE typ_tab_ocupacoes IS TABLE OF typ_ocupacoes INDEX BY PLS_INTEGER;  
  
  PROCEDURE pc_consulta_nat_ocp(pr_cdnatocp  IN gncdnto.cdnatocp%TYPE -- Código da natureza
                               ,pr_cdsubrot  IN VARCHAR2              -- Subrotina
                               ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro  OUT VARCHAR2);           --Saida OK/NOK
   
  PROCEDURE pc_consulta_ocupacoes(pr_cdnatocp  IN gncdnto.cdnatocp%TYPE -- Código da natureza
                                 ,pr_cdocupa   IN gncdocp.cdocupa%TYPE  -- Código de ocupação
                                 ,pr_cdsubrot  IN VARCHAR2              -- Subrotina
                                 ,pr_xmllog    IN VARCHAR2              -- XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER          -- Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2             -- Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2             -- Nome do Campo
                                 ,pr_des_erro  OUT VARCHAR2);          -- Saida OK/NOK
                                 
  PROCEDURE pc_manter_ocupacoes(pr_cdnatocp  IN gncdnto.cdnatocp%TYPE -- Código da natureza
                               ,pr_cdocupa   IN gncdocp.cdocupa%TYPE  -- Código da ocupação
                               ,pr_dsdocupa  IN gncdocp.dsdocupa%TYPE -- Descrição da ocupação
                               ,pr_rsdocupa  IN gncdocp.rsdocupa%TYPE -- Resumo da ocupação                             
                               ,pr_cdsubrot  IN VARCHAR2              -- Subrotina
                               ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro  OUT VARCHAR2);          --Saida OK/NOK                             
                
  PROCEDURE pc_busca_ocupacoes(pr_cdnatocp  IN gncdocp.cdnatocp%TYPE -- Código da natureza
                              ,pr_cdocupa   IN gncdocp.cdocupa%TYPE  -- Código da ocupação
                              ,pr_rsdocupa  IN gncdocp.rsdocupa%TYPE -- Descrição da ocupação
                              ,pr_nrregist  IN INTEGER               -- Quantidade de registros                            
                              ,pr_nriniseq  IN INTEGER               -- Qunatidade inicial
                              ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                              ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                              ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                              ,pr_des_erro  OUT VARCHAR2);          --Saida OK/NOK
                                                                                                                           
END TELA_OCPPEP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_OCPPEP AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_OCPPEP                          
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Adriano
   Data    : Fevereiro/2017                       Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela OCPPEP, manutenção de natureza de ocupação e ocupações.

   Alteracoes:              
                                                             
  ---------------------------------------------------------------------------------------------------------------*/
  
  PROCEDURE pc_gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE
                       ,pr_cdsubrot IN VARCHAR2
                       ,pr_cdnatocp IN gncdnto.cdnatocp%TYPE
                       ,pr_dsnatocp IN gncdnto.dsnatocp%TYPE
                       ,pr_dsnatocp_new IN gncdnto.dsnatocp%TYPE
                       ,pr_rsnatocp IN gncdnto.rsnatocp%TYPE
                       ,pr_rsnatocp_new IN gncdnto.rsnatocp%TYPE
                       ,pr_cdocupa  IN gncdocp.cdocupa%TYPE
                       ,pr_dsdocupa IN gncdocp.dsdocupa%TYPE
                       ,pr_dsdocupa_new IN gncdocp.dsdocupa%TYPE
                       ,pr_rsdocupa IN gncdocp.rsdocupa%TYPE                       
                       ,pr_rsdocupa_new IN gncdocp.rsdocupa%TYPE
                       ,pr_des_erro OUT VARCHAR2) IS  
                        
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gera_log                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano - RKAM
    Data     : Março/2017                            Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para gerar log
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                            
     
   BEGIN
      
     IF pr_cdsubrot = 'A' THEN
         
       -- Gera log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => 'ocppep.log'
                                 ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                     'Atualizou a ocupacao -> Codigo: ' || pr_cdocupa || 
                                                     ', Natureza de ocupacao: ' || pr_cdnatocp || ', Descricao de: ' || pr_dsdocupa || 
                                                    ' para: ' || pr_dsdocupa_new || ', Resumo de: ' || pr_rsdocupa || ' para : ' || pr_rsdocupa_new  ||'.');
       
     
     ELSIF pr_cdsubrot = 'I' THEN
         
       -- Gera log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => 'ocppep.log'
                                 ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                     'Incluiu a ocupacao -> Codigo: ' || pr_cdocupa || 
                                                     ', Natureza de ocupacao: ' || pr_cdnatocp || ', Descricao: ' || pr_dsdocupa_new || 
                                                    ', Resumo: ' || pr_rsdocupa_new || '.');
       
   
     ELSIF pr_cdsubrot = 'E' THEN
       
       -- Gera log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => 'ocppep.log'
                                 ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                     'Excluiu a ocupacao -> Codigo: ' || pr_cdocupa || 
                                                     ', Natureza de ocupacao: ' || pr_cdnatocp || ', Descricao: ' || pr_dsdocupa_new || 
                                                    ', Resumo: ' || pr_rsdocupa_new || '.');
         
     END IF;
    
     pr_des_erro := 'OK';                                          
   
   EXCEPTION
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';    
         
   END pc_gera_log;    
  
  PROCEDURE pc_consulta_nat_ocp(pr_cdnatocp  IN gncdnto.cdnatocp%TYPE -- Código da natureza
                               ,pr_cdsubrot  IN VARCHAR2              -- Subrotina
                               ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro  OUT VARCHAR2)IS          --Saida OK/NOK
                                    
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_consulta_nat_ocp                                antiga:
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano  
    Data     : Fevereiro/2017                          Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Consulta Natureza de ocupação
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
    CURSOR cr_gncdnto(pr_cdnatocp IN gncdnto.cdnatocp%TYPE) IS
    SELECT gncdnto.cdnatocp
          ,gncdnto.dsnatocp
          ,gncdnto.rsnatocp
     FROM gncdnto
    WHERE gncdnto.cdnatocp = pr_cdnatocp;
    rw_gncdnto cr_gncdnto%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Tabela de natureza de ocupação
    vr_tab_natureza_ocupacao typ_tab_natureza_ocupacao;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
      
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;    
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_natureza_ocupacao.DELETE;
      
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
      
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    OPEN cr_gncdnto(pr_cdnatocp => pr_cdnatocp);
    
    FETCH cr_gncdnto INTO rw_gncdnto;
    
    IF cr_gncdnto%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_gncdnto;
      
      IF pr_cdsubrot <> 'I' THEN
        
        vr_cdcritic := 0;
        vr_dscritic := 'Natureza de ocupação não encontrada.';
        
        RAISE vr_exc_erro;
    
      END IF;
      
    ELSE
      
      --Fecha o cursor
      CLOSE cr_gncdnto;
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
      
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root>' || 
                                                   '<naturezas>' ||
                                                   '  <cdnatocp>' || rw_gncdnto.cdnatocp||'</cdnatocp>'||
                                                   '  <dsnatocp>' || rw_gncdnto.dsnatocp||'</dsnatocp>'|| 
                                                   '  <rsnatocp>' || rw_gncdnto.rsnatocp||'</rsnatocp>'|| 
                                                   '</naturezas></Root>'
                             ,pr_fecha_xml      => TRUE);
        
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob); 
      
    END IF;
    
    --Retorno
    pr_des_erro:= 'OK'; 
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
        
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_nat_ocp --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_consulta_nat_ocp; 
  
  PROCEDURE pc_consulta_ocupacoes(pr_cdnatocp  IN gncdnto.cdnatocp%TYPE -- Código da natureza
                                 ,pr_cdocupa   IN gncdocp.cdocupa%TYPE  -- Código de ocupação
                                 ,pr_cdsubrot  IN VARCHAR2              -- Subrotina
                                 ,pr_xmllog    IN VARCHAR2              -- XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER          -- Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2             -- Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2             -- Nome do Campo
                                 ,pr_des_erro  OUT VARCHAR2)IS          -- Saida OK/NOK
                                    
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_consulta_ocupacao                                antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano  
    Data     : Fevereiro/2017                          Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Consulta Natureza de ocupação
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
    CURSOR cr_ocupacoes(pr_cdnatocp IN gncdnto.cdnatocp%TYPE
                       ,pr_cdocupa  IN gncdocp.cdocupa%TYPE) IS
    SELECT ocp.cdocupa
          ,ocp.dsdocupa
          ,ocp.rsdocupa
     FROM gncdnto nto
         ,gncdocp ocp
    WHERE nto.cdnatocp = pr_cdnatocp
      AND ocp.cdnatocp = nto.cdnatocp
      AND ocp.cdocupa  = pr_cdocupa;
    rw_ocupacoes cr_ocupacoes%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Tabela de ocupações
    vr_tab_ocupacoes typ_tab_ocupacoes;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
      
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;    
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_ocupacoes.DELETE;
      
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
      
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    OPEN cr_ocupacoes(pr_cdnatocp => pr_cdnatocp
                     ,pr_cdocupa  => pr_cdocupa);
    
    FETCH cr_ocupacoes INTO rw_ocupacoes;
    
    IF cr_ocupacoes%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_ocupacoes;
      
      IF pr_cdsubrot <> 'I' THEN
        
        vr_cdcritic := 0;
        vr_dscritic := 'Ocupação não encontrada.';
        
        RAISE vr_exc_erro;
    
      END IF;
      
    ELSE
      
      --Fecha o cursor
      CLOSE cr_ocupacoes;      
      
      IF pr_cdsubrot = 'I' THEN
        
        vr_cdcritic := 0;
        vr_dscritic := 'Ocupação já cadastrada.';
        
        RAISE vr_exc_erro;
    
      END IF;
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
      
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root>' || 
                                                   '<ocupacoes>' ||
                                                   '  <cdocupa>' || rw_ocupacoes.cdocupa||'</cdocupa>'||
                                                   '  <dsdocupa>' || rw_ocupacoes.dsdocupa||'</dsdocupa>'|| 
                                                   '  <rsdocupa>' || rw_ocupacoes.rsdocupa||'</rsdocupa>'|| 
                                                   '</ocupacoes></Root>'
                             ,pr_fecha_xml      => TRUE);
        
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob); 
      
    END IF;
    
    --Retorno
    pr_des_erro:= 'OK'; 
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
        
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_ocupacoes --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_consulta_ocupacoes;   
 
  PROCEDURE pc_manter_ocupacoes(pr_cdnatocp  IN gncdnto.cdnatocp%TYPE -- Código da natureza
                               ,pr_cdocupa   IN gncdocp.cdocupa%TYPE  -- Código da ocupação
                               ,pr_dsdocupa  IN gncdocp.dsdocupa%TYPE -- Descrição da ocupação
                               ,pr_rsdocupa  IN gncdocp.rsdocupa%TYPE -- Resumo da ocupação                             
                               ,pr_cdsubrot  IN VARCHAR2              -- Subrotina
                               ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro  OUT VARCHAR2)IS          --Saida OK/NOK
                                    
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_manter_ocupacao                                   antiga:
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano  
    Data     : Fevereiro/2017                          Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Rotina responsável pela inclusão/alteração/exclusão da ocupação
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
    CURSOR cr_gncdocp(pr_cdocupa IN gncdocp.cdocupa%TYPE) IS
    SELECT ocp.cdocupa
          ,ocp.dsdocupa
          ,ocp.rsdocupa
     FROM gncdocp ocp
    WHERE ocp.cdnatocp = pr_cdocupa;
    rw_gncdocp cr_gncdocp%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
      
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;    
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
      
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF pr_cdnatocp <> 99  THEN
      
      vr_cdcritic := 0;
      vr_dscritic := 'Somente é permitido o uso da natureza 99 - PEP.';
        
      RAISE vr_exc_erro;
        
    END IF;
        
    OPEN cr_gncdocp(pr_cdocupa  => pr_cdocupa);
    
    FETCH cr_gncdocp INTO rw_gncdocp;
    
    IF cr_gncdocp%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_gncdocp;
      
      IF pr_cdsubrot <> 'I' THEN
        
        vr_cdcritic := 0;
        vr_dscritic := 'Ocupação não encontrada.';
        
        RAISE vr_exc_erro;
    
      END IF;
      
      BEGIN
        
        INSERT INTO gncdocp
                   (cdocupa
                   ,cdnatocp
                   ,dsdocupa
                   ,rsdocupa)
            VALUES(pr_cdocupa
                  ,pr_cdnatocp
                  ,upper(pr_dsdocupa)
                  ,upper(pr_rsdocupa));
        
      EXCEPTION 
        WHEN OTHERS THEN
           vr_dscritic := 'Erro ao inserir gncdocp: '||SQLERRM;
           RAISE vr_exc_erro;
      END;
      
    ELSE
      
      --Fecha o cursor
      CLOSE cr_gncdocp;
            
      IF pr_cdsubrot = 'I' THEN
        
        vr_cdcritic := 0;
        vr_dscritic := 'Ocupação já cadastrada.';
        
        RAISE vr_exc_erro;
    
      ELSIF pr_cdsubrot = 'E' THEN
        
        BEGIN
        
          DELETE gncdocp ocp            
           WHERE ocp.cdnatocp = pr_cdnatocp
             AND ocp.cdocupa  = pr_cdocupa;
          
        EXCEPTION 
          WHEN OTHERS THEN
             vr_dscritic := 'Erro ao excluir gncdocp: '||SQLERRM;
             RAISE vr_exc_erro;
        END; 
      
      ELSE
        BEGIN
        
          UPDATE gncdocp ocp
             SET ocp.dsdocupa = upper(pr_dsdocupa)
                ,ocp.rsdocupa = upper(pr_rsdocupa)
           WHERE ocp.cdnatocp = pr_cdnatocp
             AND ocp.cdocupa  = pr_cdocupa;
          
        EXCEPTION 
          WHEN OTHERS THEN
             vr_dscritic := 'Erro ao atualizar gncdocp: '||SQLERRM;
             RAISE vr_exc_erro;
        END; 
        
      END IF;
      
    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper
               ,pr_cdoperad => vr_cdoperad
               ,pr_cdsubrot => pr_cdsubrot
               ,pr_cdnatocp => pr_cdnatocp
               ,pr_dsnatocp => ''
               ,pr_dsnatocp_new => ''
               ,pr_rsnatocp => ''
               ,pr_rsnatocp_new => ''
               ,pr_cdocupa => pr_cdocupa
               ,pr_dsdocupa => rw_gncdocp.dsdocupa
               ,pr_dsdocupa_new => upper(pr_dsdocupa)
               ,pr_rsdocupa => rw_gncdocp.rsdocupa
               ,pr_rsdocupa_new => upper(pr_rsdocupa)
               ,pr_des_erro => pr_des_erro);
               
    --Retorno
    pr_des_erro:= 'OK'; 
    
    --Efetua commit das alterações
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
        
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_manter_ocupacoes --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_manter_ocupacoes; 
  
  PROCEDURE pc_busca_ocupacoes(pr_cdnatocp  IN gncdocp.cdnatocp%TYPE -- Código da natureza
                              ,pr_cdocupa   IN gncdocp.cdocupa%TYPE  -- Código da ocupação
                              ,pr_rsdocupa  IN gncdocp.rsdocupa%TYPE -- Descrição da ocupação
                              ,pr_nrregist  IN INTEGER               -- Quantidade de registros                            
                              ,pr_nriniseq  IN INTEGER               -- Qunatidade inicial
                              ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                              ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                              ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                              ,pr_des_erro  OUT VARCHAR2)IS          --Saida OK/NOK
                                    
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_ocupacoes                            antiga: b1wgen0059\busca-gncdocp
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano  
    Data     : Fevereiro/2017                          Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de ocupação
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
    CURSOR cr_gncdocp(pr_cdnatocp IN gncdnto.cdnatocp%TYPE
                     ,pr_cdocupa  IN gncdocp.cdnatocp%TYPE
                     ,pr_rsdocupa IN gncdocp.rsdocupa%TYPE) IS
    SELECT ocp.cdocupa
          ,ocp.dsdocupa
          ,ocp.rsdocupa
          ,ocp.cdnatocp
     FROM gncdocp ocp
         ,gncdnto nto
    WHERE(pr_cdnatocp = 0
       OR nto.cdnatocp = pr_cdnatocp)
      AND ocp.cdnatocp = nto.cdnatocp
      AND(pr_cdocupa = 0
       OR ocp.cdocupa = pr_cdocupa)
      AND UPPER(ocp.rsdocupa) LIKE '%' || pr_rsdocupa || '%';
    rw_gncdocp cr_gncdocp%ROWTYPE;
    
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;    
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
      
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><gncdocp>');
    
    FOR rw_gncdocp IN cr_gncdocp(pr_cdnatocp => pr_cdnatocp
                                ,pr_cdocupa  => nvl(pr_cdocupa,0)
                                ,pr_rsdocupa => upper(pr_rsdocupa)) LOOP
      
      IF trim(rw_gncdocp.rsdocupa) IS NULL THEN
        
        CONTINUE;
        
      END IF;
      
      --Indice para a temp-table
      vr_qtregist := nvl(vr_qtregist,0) + 1;
      
      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proxima linha
          CONTINUE;
      END IF; 
      
      --Numero Registros
      IF vr_nrregist > 0 THEN 
        
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                         ,pr_texto_completo => vr_xml_temp
                         ,pr_texto_novo     => '<ocupacoes>'||
                                               '  <cdocupa>' ||  rw_gncdocp.cdocupa||'</cdocupa>'||
                                               '  <dsdocupa>' || substr(rw_gncdocp.dsdocupa,1,30)||'</dsdocupa>'|| 
                                               '  <rsdocupa>' || substr(rw_gncdocp.rsdocupa,1,20)||'</rsdocupa>'||                                                    
                                               '</ocupacoes>'); 
          
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</gncdocp></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'gncdocp'            --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                             
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
                                   
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
                                      
    --Retorno
    pr_des_erro:= 'OK'; 
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
        
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_ocupacoes --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_ocupacoes;                             
  
END TELA_OCPPEP;
/
