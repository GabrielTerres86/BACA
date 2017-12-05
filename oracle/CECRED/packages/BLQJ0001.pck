CREATE OR REPLACE PACKAGE CECRED.BLQJ0001 AS

  /*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0155.p
    Autor   : Renato Darosci
    Data    : Outubro/2016                Ultima Atualizacao: 26/10/2016.
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela BLQJUD
                 
    Alteracoes: 26/10/2016 - Conversão PROGRESS para ORACLE (Renato Darosci).

  .............................................................................*/
  
  -- Registro de dados do cooperado
  TYPE typ_reg_cooperado IS RECORD (cdcooper    crapass.cdcooper%TYPE
                                   ,nrdconta    crapass.nrdconta%TYPE
                                   ,nrcpfcgc    crapass.nrcpfcgc%TYPE
                                   ,idseqttl    crapttl.idseqttl%TYPE
                                   ,vlsldcap    NUMBER
                                   ,vlsldapl    NUMBER
                                   ,vlstotal    NUMBER
                                   ,vlsldppr    NUMBER
                                   ,dtadmiss    crapass.dtadmiss%TYPE
                                   ,dtdemiss    crapass.dtdemiss%TYPE
                                   ,cdagenci    crapass.cdagenci%TYPE
                                   ,dsendere    crapenc.dsendere%TYPE
                                   ,nrendere    crapenc.nrendere%TYPE
                                   ,nmbairro    crapenc.nmbairro%TYPE
                                   ,nmcidade    crapenc.nmcidade%TYPE
                                   ,nrcepend    crapenc.nrcepend%TYPE
                                   ,cdufende    crapenc.cdufende%TYPE);
                                  
  -- Tabela de memória para gravar os dados do cooperado
  TYPE typ_tab_cooperado IS TABLE OF typ_reg_cooperado INDEX BY BINARY_INTEGER;
  
  
  -- Chamar a busca-contas-cooperado por mensageria
  PROCEDURE pc_busca_contas_cooperado_web(pr_cdcooper   IN crapcop.cdcooper%TYPE     
                                         ,pr_cdagenci   IN VARCHAR2                  
                                         ,pr_nrdcaixa   IN VARCHAR2                  
                                         ,pr_cdoperad   IN VARCHAR2                  
                                         ,pr_nmdatela   IN VARCHAR2                  
                                         ,pr_idorigem   IN NUMBER                    
                                         ,pr_inproces   IN NUMBER                    
                                         ,pr_cooperad   IN NUMBER         
                                         ,pr_tpcooperad IN NUMBER   DEFAULT 0
                                         ,pr_xmllog     IN VARCHAR2                --> XML com informações de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER             --> Código da crítica
                                         ,pr_dscritic  OUT VARCHAR2                --> Descrição da crítica
                                         ,pr_retxml     IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2                --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);              --> Erros do processo 
  
  -- Buscar contas cooperado
  PROCEDURE pc_busca_contas_cooperado(pr_cdcooper   IN crapcop.cdcooper%TYPE 
                                     ,pr_cdagenci   IN VARCHAR2
                                     ,pr_nrdcaixa   IN VARCHAR2               
                                     ,pr_cdoperad   IN VARCHAR2
                                     ,pr_nmdatela   IN VARCHAR2
                                     ,pr_idorigem   IN NUMBER    
                                     ,pr_inproces   IN NUMBER 
                                     ,pr_cooperad   IN NUMBER          
                                     ,pr_tpcooperad IN NUMBER  DEFAULT 0
                                     ,pr_nmprimtl      OUT VARCHAR2            
                                     ,pr_tab_cooperado OUT BLQJ0001.typ_tab_cooperado
                                     ,pr_tab_erro   IN OUT GENE0001.typ_tab_erro);
  
  -- Chamar a inclui-bloqueio-jud por mensageria
  PROCEDURE pc_inclui_bloqueio_jud_web(pr_cdcooper  IN NUMBER       
                                      ,pr_nrdconta  IN VARCHAR2  /*LISTAS*/
                                      ,pr_cdtipmov  IN VARCHAR2  /*LISTAS*/
                                      ,pr_cdmodali  IN VARCHAR2  /*LISTAS*/
                                      ,pr_vlbloque  IN VARCHAR2  /*LISTAS*/
                                      ,pr_nroficio  IN VARCHAR2  
                                      ,pr_nrproces  IN VARCHAR2  
                                      ,pr_dsjuizem  IN VARCHAR2  
                                      ,pr_dsresord  IN VARCHAR2  
                                      ,pr_flblcrft  IN NUMBER  -- 0 para FALSE / 1 para TRUE      
                                      ,pr_dtenvres  IN VARCHAR2      
                                      ,pr_vlrsaldo  IN VARCHAR2      
                                      ,pr_cdoperad  IN VARCHAR2      
                                      ,pr_dsinfadc  IN VARCHAR2                  
                                      ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER             --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2                --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);              --> Erros do processo 
  
  -- Incluir bloqueios judiciais
  PROCEDURE pc_inclui_bloqueio_jud(pr_cdcooper    IN NUMBER       
                                  ,pr_nrdconta    IN VARCHAR2  /*LISTAS*/
                                  ,pr_cdtipmov    IN VARCHAR2  /*LISTAS*/
                                  ,pr_cdmodali    IN VARCHAR2  /*LISTAS*/
                                  ,pr_vlbloque    IN VARCHAR2  /*LISTAS*/
                                  ,pr_nroficio    IN VARCHAR2  
                                  ,pr_nrproces    IN VARCHAR2  
                                  ,pr_dsjuizem    IN VARCHAR2  
                                  ,pr_dsresord    IN VARCHAR2  
                                  ,pr_flblcrft    IN BOOLEAN      
                                  ,pr_dtenvres    IN DATE      
                                  ,pr_vlrsaldo    IN NUMBER      
                                  ,pr_cdoperad    IN VARCHAR2      
                                  ,pr_dsinfadc    IN VARCHAR2         
                                  ,pr_tab_erro   IN OUT GENE0001.typ_tab_erro);  --> Retorno de erro                          
  
  -- Chamar a efetua-desbloqueio-jud por mensageria
  PROCEDURE pc_efetua_desbloqueio_jud_web(pr_cdcooper   IN NUMBER
                                         ,pr_dtmvtolt   IN VARCHAR2
                                         ,pr_cdoperad   IN VARCHAR2
                                         ,pr_nroficio   IN VARCHAR2
                                         ,pr_nrctacon   IN VARCHAR2
                                         ,pr_nrofides   IN VARCHAR2
                                         ,pr_dtenvdes   IN VARCHAR2
                                         ,pr_dsinfdes   IN VARCHAR2
                                         ,pr_fldestrf   IN NUMBER   
                                         ,pr_tpcooperad IN NUMBER   DEFAULT 0
                                         ,pr_vldesblo   IN NUMBER
                                         ,pr_cdmodali   IN NUMBER
                                         ,pr_xmllog     IN VARCHAR2             --> XML com informações de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml     IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);           --> Erros do processo 
  
  -- Efetuar os desbloqueios judiciais
  PROCEDURE pc_efetua_desbloqueio_jud(pr_cdcooper   IN NUMBER
                                     ,pr_dtmvtolt   IN DATE
                                     ,pr_cdoperad   IN VARCHAR2
                                     ,pr_nroficio   IN VARCHAR2
                                     ,pr_nrctacon   IN VARCHAR2
                                     ,pr_nrofides   IN VARCHAR2
                                     ,pr_dtenvdes   IN DATE
                                     ,pr_dsinfdes   IN VARCHAR2
                                     ,pr_fldestrf   IN BOOLEAN   
                                     ,pr_tpcooperad IN NUMBER     DEFAULT 0
                                     ,pr_vldesblo   IN NUMBER
                                     ,pr_cdmodali   IN NUMBER     DEFAULT 0
                                     ,pr_tab_erro   IN OUT GENE0001.typ_tab_erro);
  
END BLQJ0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.BLQJ0001 AS

  /*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0155.p
    Autor   : Renato Darosci
    Data    : Outubro/2016                Ultima Atualizacao: 26/10/2016.
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela BLQJUD
                 
    Alteracoes: 26/10/2016 - Conversão PROGRESS para ORACLE (Renato Darosci).
    
                11/11/2016 - Inclusão do parametro PR_TPCOOPERAD, que será utilizado 
                             para indicar o tipo de identificação passada no parametro
                             PR_COOPERAD, onde:
                             [0] - Campo PR_COOPERAD virá com CPF/CNPJ ou conta
                             [1] - Campo PR_COOPERAD virá uma conta especifica
                             [2] - Campo PR_COOPERAD virá com um CPF/CNPJ
                             [3] - Campo PR_COOPERAD virá com a raiz de um CNPJ

                30/05/2017 - Remocao de caracteres especiais e espacos em branco ao gravar
                             o numero do oficio.
                             Rafael (Mouts) - Chamado 662865

				30/11/2017 - M460 bancenJud - Demetrius\Thiago Rodrigues

  .............................................................................*/
  
  -- Buscar o lote para lançamentos
  CURSOR cr_craplot(pr_cdcooper  craplot.cdcooper%TYPE
                   ,pr_dtmvtolt  craplot.dtmvtolt%TYPE
                   ,pr_nrdolote  craplot.nrdolote%TYPE) IS
    SELECT lot.rowid dsdrowid
         , lot.cdcooper 
         , lot.dtmvtolt
         , lot.cdagenci
         , lot.cdbccxlt
         , lot.nrdolote
         , lot.tplotmov
         , lot.nrseqdig
      FROM craplot lot
     WHERE lot.cdcooper = pr_cdcooper   
       AND lot.dtmvtolt = pr_dtmvtolt   
       AND lot.cdagenci = 1
       AND lot.cdbccxlt = 100
       AND lot.nrdolote = pr_nrdolote FOR UPDATE; -- Realizar o lock do registro de lote
  rw_craplot  cr_craplot%ROWTYPE;
  
    
  -- Buscar os dados de documentos do cooperado por documento e conta
  PROCEDURE pc_busca_nrcpfcgc_cooperado(pr_cdcooper   IN crapass.cdcooper%TYPE
                                       ,pr_nrctadoc   IN NUMBER
                                       ,pr_tpcooperad IN NUMBER
                                       ,pr_nrcpfcgc  OUT crapass.nrcpfcgc%TYPE
                                       ,pr_nmprimtl  OUT crapass.nmprimtl%TYPE
                                       ,pr_dscritic  OUT VARCHAR2) IS
  
    -- CURSORES 
    -- Buscar o cooperado pelo número de documento
    CURSOR cr_nrcpfcgc IS
      SELECT ass.nrcpfcgc
           , ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrcpfcgc = pr_nrctadoc;
         
    -- Buscar o cooperado pelo número da conta
    CURSOR cr_nrdconta IS
      SELECT ass.nrcpfcgc
           , ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrctadoc;
    
    -- Buscar o cooperado pela base do CNPJ
    CURSOR cr_cnpjbase IS
      SELECT ass.nrcpfcgc
           , ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrcpfcgc BETWEEN to_number(pr_nrctadoc||'000000') AND to_number(pr_nrctadoc||'999999');
        
    -- VARIÁVEIS
    vr_nrcpfcgc    crapass.nrcpfcgc%TYPE;
    vr_nmprimtl    crapass.nmprimtl%TYPE;
    
  BEGIN
    
    -- se o tipo do cooperado for para pesquisa padrão ou indicando o CPF/CNPJ
    IF pr_tpcooperad IN (0,2) THEN
      -- FAZ A BUSCA POR CPF/CNPJ
      OPEN  cr_nrcpfcgc;
      FETCH cr_nrcpfcgc INTO vr_nrcpfcgc
                           , vr_nmprimtl;
                           
      -- Se não encontrar o registro e o tipo de pesquisa for padrão
      IF cr_nrcpfcgc%NOTFOUND AND 
         pr_tpcooperad = 0    THEN
        
        -- FAZ A BUSCA POR CONTA
        OPEN  cr_nrdconta;
        FETCH cr_nrdconta INTO vr_nrcpfcgc
                             , vr_nmprimtl;
                             
        -- Se não encontrar registro
        IF cr_nrdconta%NOTFOUND THEN
          -- Retorna a informação de cooperado não encontrado
          vr_nmprimtl :=  'COOPERADO NAO ENCONTRADO';
        END IF;
        
        -- Fechar o cursor
        CLOSE cr_nrdconta;
      
      ELSIF cr_nrcpfcgc%NOTFOUND THEN
        -- Retorna a informação de cooperado não encontrado
        vr_nmprimtl := 'COOPERADO NAO ENCONTRADO';
        vr_nrcpfcgc := NULL;
      END IF;
                 
      -- Fechar o cursor
      CLOSE cr_nrcpfcgc;
    
    -- Se a busca for por conta
    ELSIF pr_tpcooperad = 1 THEN
      -- FAZ A BUSCA POR CONTA
      OPEN  cr_nrdconta;
      FETCH cr_nrdconta INTO vr_nrcpfcgc
                           , vr_nmprimtl;
                             
      -- Se não encontrar registro
      IF cr_nrdconta%NOTFOUND THEN
        -- Retorna a informação de cooperado não encontrado
        vr_nmprimtl :=  'COOPERADO NAO ENCONTRADO';
      END IF;
        
      -- Fechar o cursor
      CLOSE cr_nrdconta;
    
    -- Se a busca for pelo  => CNPJ BASE <=
    ELSIF pr_tpcooperad = 3 THEN 
      
      -- FAZ A BUSCA PELO CNPJ BASE
      OPEN  cr_cnpjbase;
      FETCH cr_cnpjbase INTO vr_nrcpfcgc
                           , vr_nmprimtl;
                             
      -- Se não encontrar registro
      IF cr_cnpjbase%NOTFOUND THEN
        -- Retorna a informação de cooperado não encontrado
        vr_nmprimtl :=  'COOPERADO NAO ENCONTRADO';
      END IF;
        
      -- Fechar o cursor
      CLOSE cr_cnpjbase;
    
    END IF;
    
    -- Retornar os valores encontrados
    pr_nrcpfcgc := vr_nrcpfcgc;
    pr_nmprimtl := vr_nmprimtl;
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar a mensagem de erro para retorno
      pr_dscritic := 'Erro na PC_BUSCA_NRCPFCGC_COOPERADO: '||SQLERRM;
      
      -- Verifica se algum cursor ficou aberto
      IF cr_nrcpfcgc%ISOPEN THEN
        CLOSE cr_nrcpfcgc;
      END IF;
      
      IF cr_nrdconta%ISOPEN THEN
        CLOSE cr_nrdconta;
      END IF;
  END pc_busca_nrcpfcgc_cooperado;
  
  -- Chamar a busca-contas-cooperado por mensageria
  PROCEDURE pc_busca_contas_cooperado_web(pr_cdcooper   IN crapcop.cdcooper%TYPE   
                                         ,pr_cdagenci   IN VARCHAR2                
                                         ,pr_nrdcaixa   IN VARCHAR2                
                                         ,pr_cdoperad   IN VARCHAR2                  
                                         ,pr_nmdatela   IN VARCHAR2                
                                         ,pr_idorigem   IN NUMBER                  
                                         ,pr_inproces   IN NUMBER                  
                                         ,pr_cooperad   IN NUMBER       
                                         ,pr_tpcooperad IN NUMBER     DEFAULT 0        
                                         ,pr_xmllog     IN VARCHAR2                --> XML com informações de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER             --> Código da crítica
                                         ,pr_dscritic  OUT VARCHAR2                --> Descrição da crítica
                                         ,pr_retxml     IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2                --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2) IS            --> Erros do processo 
                                   
    -- VARIÁVEIS
    vr_tab_cooperado BLQJ0001.typ_tab_cooperado;
    vr_tab_erro      GENE0001.typ_tab_erro;
    vr_nmprimtl      VARCHAR2(200);
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(2000);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    
    -- EXCEPTIONS
    vr_exc_saida     EXCEPTION;
    
    -- Escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN 
    
    pr_des_erro := 'OK';
    
    gene0001.pc_informa_acesso(pr_module => 'BLQJ0001');
    
    -- Chamar a procedure
    BLQJ0001.pc_busca_contas_cooperado(pr_cdcooper   => pr_cdcooper
                                      ,pr_cdagenci   => pr_cdagenci
                                      ,pr_nrdcaixa   => pr_nrdcaixa
                                      ,pr_cdoperad   => pr_cdoperad
                                      ,pr_nmdatela   => pr_nmdatela
                                      ,pr_idorigem   => pr_idorigem
                                      ,pr_inproces   => pr_inproces
                                      ,pr_cooperad   => pr_cooperad
                                      ,pr_tpcooperad => NVL(pr_tpcooperad,0)
                                      ,pr_nmprimtl   => vr_nmprimtl
                                      ,pr_tab_cooperado => vr_tab_cooperado
                                      ,pr_tab_erro   => vr_tab_erro);
   
    -- Se houve o retorno de erro
    IF vr_tab_erro.count() > 0 THEN
      vr_dscritic := 'Nao foi possivel consultar os registros.';
      RAISE vr_exc_saida;
    END IF;
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    vr_texto_completo := NULL;
      
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><root><dados nmprimtl="'||vr_nmprimtl||'">');
    
    -- Se retornou algum registro
    IF vr_tab_cooperado.count() > 0 THEN
      
      -- Percorrer todos os registros retornados
      FOR vr_idx IN vr_tab_cooperado.FIRST()..vr_tab_cooperado.LAST() LOOP
        
        -- Escrever os dados no XML      
        pc_escreve_xml('<cooperado>'||
                          '<cdcooper>' || vr_tab_cooperado(vr_idx).cdcooper ||'</cdcooper>' ||
                          '<nrdconta>' || vr_tab_cooperado(vr_idx).nrdconta ||'</nrdconta>' ||
                          '<nrcpfcgc>' || vr_tab_cooperado(vr_idx).nrcpfcgc ||'</nrcpfcgc>' ||
                          '<vlsldapl>' || vr_tab_cooperado(vr_idx).vlsldapl ||'</vlsldapl>' ||
                          '<vlsldcap>' || vr_tab_cooperado(vr_idx).vlsldcap ||'</vlsldcap>' ||
                          '<vlstotal>' || vr_tab_cooperado(vr_idx).vlstotal ||'</vlstotal>' ||
                          '<vlsldppr>' || vr_tab_cooperado(vr_idx).vlsldppr ||'</vlsldppr>' ||
                          '<dtadmiss>' || to_char(vr_tab_cooperado(vr_idx).dtadmiss, 'dd/mm/yyyy') ||'</dtadmiss>' ||
                          '<dtdemiss>' || to_char(vr_tab_cooperado(vr_idx).dtdemiss, 'dd/mm/yyyy') ||'</dtdemiss>' ||
                          '<dsendere>' || vr_tab_cooperado(vr_idx).dsendere ||'</dsendere>' ||
                          '<nrendere>' || vr_tab_cooperado(vr_idx).nrendere ||'</nrendere>' ||
                          '<nmbairro>' || vr_tab_cooperado(vr_idx).nmbairro ||'</nmbairro>' ||
                          '<nmcidade>' || vr_tab_cooperado(vr_idx).nmcidade ||'</nmcidade>' ||
                          '<nrcepend>' || vr_tab_cooperado(vr_idx).nrcepend ||'</nrcepend>' ||
                          '<cdufende>' || vr_tab_cooperado(vr_idx).cdufende ||'</cdufende>' ||
                       '</cooperado>'); 
          
      END LOOP;
     
    END IF;
    
    -- Finaliza o XML     
    pc_escreve_xml('</dados></root>',TRUE);        
    pr_retxml := XMLType.createXML(vr_des_xml);
      
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral PC_BUSCA_CONTAS_COOPERADO_WEB: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_contas_cooperado_web;        
  
  
  -- Buscar contas cooperado
  PROCEDURE pc_busca_contas_cooperado(pr_cdcooper    IN crapcop.cdcooper%TYPE 
                                     ,pr_cdagenci    IN VARCHAR2
                                     ,pr_nrdcaixa    IN VARCHAR2               
                                     ,pr_cdoperad    IN VARCHAR2
                                     ,pr_nmdatela    IN VARCHAR2
                                     ,pr_idorigem    IN NUMBER    
                                     ,pr_inproces    IN NUMBER    
                                     ,pr_cooperad    IN NUMBER
                                     ,pr_tpcooperad  IN NUMBER   DEFAULT 0
                                     ,pr_nmprimtl      OUT VARCHAR2            
                                     ,pr_tab_cooperado OUT BLQJ0001.typ_tab_cooperado
                                     ,pr_tab_erro   IN OUT GENE0001.typ_tab_erro) IS  --> Retorno de erro   
    
    -- CURSORES
    
    -- Buscar as contas do cooperado
    CURSOR cr_crapass_ttl(pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
      SELECT ass.cdcooper
           , ass.nrdconta
           , ass.nrcpfcgc
           , 1   idseqttl
           , ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper 
         -- quando o tipo do registro for 1, pesquisa diretamente pela conta
         AND ((ass.nrcpfcgc = pr_nrcpfcgc AND NVL(pr_tpcooperad,0) NOT IN (1,3)) OR
              (ass.nrcpfcgc BETWEEN to_number(pr_cooperad||'000000') AND to_number(pr_cooperad||'999999') AND NVL(pr_tpcooperad,0) = 3) OR
              (ass.nrdconta = pr_cooperad AND NVL(pr_tpcooperad,0) = 1))
      UNION    -- Cláusula UNION é excludente de repetições
      SELECT ttl.cdcooper
           , ttl.nrdconta
           , ttl.nrcpfcgc
           , ttl.idseqttl
           , ttl.inpessoa
        FROM crapttl  ttl
       WHERE ttl.cdcooper = pr_cdcooper 
         AND ttl.nrcpfcgc = pr_nrcpfcgc 
         AND NVL(pr_tpcooperad,0) <> 1;
    
    -- Buscar dados específicos da conta
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.cdcooper
           , ass.nrdconta
           , ass.inpessoa
           , ass.nrdctitg
           , ass.dtadmiss
           , ass.dtdemiss
           , ass.cdagenci
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass  cr_crapass%ROWTYPE;
    
    -- Buscar dados dos titulares de conta
    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                     ,pr_nrdconta IN crapttl.nrdconta%TYPE) IS
      SELECT ttl.idseqttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper 
         AND ttl.nrdconta = pr_nrdconta 
         AND ttl.idseqttl = 1; -- fixo
    rw_crapttl  cr_crapttl%ROWTYPE;
    
    -- Buscar dados do cadastro de bloqueio judicial
    CURSOR cr_crapblj(pr_cdcooper  crapblj.cdcooper%TYPE
                     ,pr_nrdconta  crapblj.nrdconta%TYPE) IS
      SELECT blj.cdmodali
           , blj.vlbloque
        FROM crapblj blj
       WHERE blj.cdcooper = pr_cdcooper 
         AND blj.nrdconta = pr_nrdconta
         AND blj.cdtipmov <> 2            
         AND blj.dtblqfim IS NULL;
    
    /* Buscar valor do saldo devedor dos empréstimos ativos, contratados a partir de Outubro/2014 e
    modalidades de linha de credito (emprestimo/financiamento) */
    CURSOR cr_creprlcr(pr_cdcooper  crapepr.cdcooper%TYPE
                      ,pr_nrdconta  crapepr.nrdconta%TYPE) IS
      SELECT epr.nrctremp
        FROM craplcr lcr
           , crapepr epr
       WHERE epr.cdcooper = pr_cdcooper      
         AND epr.nrdconta = pr_nrdconta  
         AND epr.inliquid = 0
         AND epr.vlsdeved > 0
         AND epr.dtmvtolt >= to_date('01/10/2014','dd/mm/yyyy') 
         AND lcr.cdlcremp = epr.cdlcremp  
         AND lcr.cdcooper = epr.cdcooper
         AND lcr.dsoperac IN ('EMPRESTIMO','FINANCIAMENTO');
    
    -- Buscar os dados de endereço do cooperado
    CURSOR cr_crapenc(pr_cdcooper  IN crapenc.cdcooper%TYPE
                     ,pr_nrdconta  IN crapenc.nrdconta%TYPE
                     ,pr_inpessoa  IN crapass.inpessoa%TYPE
                     ,pr_idseqttl  IN crapttl.idseqttl%TYPE) IS 
      SELECT TRIM(dsendere) dsendere
           , nrendere
           , TRIM(nmbairro) nmbairro
           , TRIM(nmcidade) nmcidade
           , nrcepend
           , TRIM(cdufende) cdufende
        FROM crapenc t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND ((t.tpendass = 10 AND pr_inpessoa = 1) OR
              (t.tpendass IN (10,9) AND pr_inpessoa = 2))
         AND t.idseqttl = pr_idseqttl
       ORDER BY t.tpendass DESC;
    rw_crapenc  cr_crapenc%ROWTYPE;
    
    -- VARIÁVEIS
    vr_cdcritic       NUMBER;
    vr_dscritic       VARCHAR2(2000);
    vr_nrindice       NUMBER;
    vr_vlsldapl       NUMBER;
    vr_vlsldpou       NUMBER;
    
    vr_nrcpfcgc       crapass.nrcpfcgc%TYPE;
        
    vr_flconven       INTEGER;
    vr_tab_cabec      CADA0004.typ_tab_cabec;
    vr_tb_comp_cabec  CADA0004.typ_tab_comp_cabec;
    vr_tb_vlr_conta   CADA0004.typ_tab_valores_conta;
    vr_tb_msgs_atenda CADA0004.typ_tab_mensagens_atenda;
    vr_tb_crapobs     CADA0004.typ_tab_crapobs;
    vr_tab_craptab    APLI0001.typ_tab_ctablq;
    vr_tab_craplpp    APLI0001.typ_tab_craplpp;
    vr_tab_craplrg    APLI0001.typ_tab_craplpp;
    vr_tab_resgate    APLI0001.typ_tab_resgate;
    
    vr_des_reto       VARCHAR2(100);
    vr_vlsdeved       NUMBER;
    vr_vlsldrpp       NUMBER;
    vr_vltotemp       NUMBER;
    vr_vltotpre       NUMBER;
    vr_qtprecal       crapepr.qtprecal%TYPE;
    vr_dstextab       craptab.dstextab%TYPE;
    vr_inusatab       BOOLEAN;
    
    vr_tbsaldo_rdca   APLI0001.typ_tab_saldo_rdca;
    vr_tbdados_rpp    APLI0001.typ_tab_dados_rpp;
    
    -- EXCEPTIONS
    vr_exp_erro       EXCEPTION;
  
  BEGIN
    
    -- Buscar dados do cooperado por documento ou conta
    pc_busca_nrcpfcgc_cooperado(pr_cdcooper   => pr_cdcooper
                               ,pr_nrctadoc   => pr_cooperad
                               ,pr_tpcooperad => pr_tpcooperad
                               ,pr_nrcpfcgc   => vr_nrcpfcgc
                               ,pr_nmprimtl   => pr_nmprimtl
                               ,pr_dscritic   => vr_dscritic);
                              
    -- Se houver retorno de erro
    IF vr_dscritic IS NOT NULL THEN
      -- Critica
      vr_cdcritic := 9;
      vr_dscritic := NULL;
      
       -- Gerar registro de erro      
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 1
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    
      RAISE vr_exp_erro;
    END IF;
    
    -- Buscar a CRAPDAT para a cooperativa
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO BTCH0001.rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
    
    --Verificar se usa tabela juros
    vr_dstextab := TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TAXATABELA'
                                              ,pr_tpregist => 0);
    -- Se a primeira posição do campo dstextab for diferente de zero
    vr_inusatab := SUBSTR(vr_dstextab,1,1) != '0';
    
    -- Buscar todas as contas relacionadas ao CPF/CNPJ - Tabelas CRAPASS e CRAPTTL
    FOR rw_crapass_ttl IN cr_crapass_ttl(pr_cdcooper
                                        ,vr_nrcpfcgc) LOOP
      -- Define o indice para tabela de memória dos cooperados  
      vr_nrindice := pr_tab_cooperado.COUNT() + 1;
      
      -- Adicionar o registro na tabela de memória
      pr_tab_cooperado(vr_nrindice).cdcooper := rw_crapass_ttl.cdcooper;
      pr_tab_cooperado(vr_nrindice).nrdconta := rw_crapass_ttl.nrdconta;
      pr_tab_cooperado(vr_nrindice).nrcpfcgc := rw_crapass_ttl.nrcpfcgc;
      
      -- Buscar endereço do cooperado
      OPEN  cr_crapenc(rw_crapass_ttl.cdcooper    -- pr_cdcooper
                      ,rw_crapass_ttl.nrdconta    -- pr_nrdconta
                      ,rw_crapass_ttl.inpessoa    -- pr_inpessoa
                      ,rw_crapass_ttl.idseqttl ); -- pr_idseqttl
      
      FETCH cr_crapenc INTO rw_crapenc;
      
      -- Se encontrar registro e o endereço não estiver nulo
      IF cr_crapenc%FOUND AND rw_crapenc.dsendere IS NOT NULL  THEN
        -- Popular os dados do endereço
        pr_tab_cooperado(vr_nrindice).dsendere := rw_crapenc.dsendere;
        pr_tab_cooperado(vr_nrindice).nrendere := rw_crapenc.nrendere;
        pr_tab_cooperado(vr_nrindice).nmbairro := rw_crapenc.nmbairro;
        pr_tab_cooperado(vr_nrindice).nmcidade := rw_crapenc.nmcidade;
        pr_tab_cooperado(vr_nrindice).nrcepend := rw_crapenc.nrcepend;
        pr_tab_cooperado(vr_nrindice).cdufende := rw_crapenc.cdufende;
      ELSE
        -- Fechar o cursor que está aberto, para realizar nova consulta
        CLOSE cr_crapenc;
        
        -- Buscar endereço do cooperado pelo titular 1
        OPEN  cr_crapenc(rw_crapass_ttl.cdcooper    -- pr_cdcooper
                        ,rw_crapass_ttl.nrdconta    -- pr_nrdconta
                        ,rw_crapass_ttl.inpessoa    -- pr_inpessoa
                        ,1 );                       -- pr_idseqttl -- INFORMAÇÕES DO PRIMEIRO TITULAR
      
        FETCH cr_crapenc INTO rw_crapenc;
        
        -- Se encontrar registro e o endereço não estiver nulo
        IF cr_crapenc%FOUND AND TRIM(rw_crapenc.dsendere) IS NOT NULL  THEN
          -- Popular os dados do endereço
          pr_tab_cooperado(vr_nrindice).dsendere := rw_crapenc.dsendere;
          pr_tab_cooperado(vr_nrindice).nrendere := rw_crapenc.nrendere;
          pr_tab_cooperado(vr_nrindice).nmbairro := rw_crapenc.nmbairro;
          pr_tab_cooperado(vr_nrindice).nmcidade := rw_crapenc.nmcidade;
          pr_tab_cooperado(vr_nrindice).nrcepend := rw_crapenc.nrcepend;
          pr_tab_cooperado(vr_nrindice).cdufende := rw_crapenc.cdufende;
        END IF;
        
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_crapenc;
            
    END LOOP;
      
    -- Se inseriu dados na tabela de memória de cooperados
    IF pr_tab_cooperado.COUNT() > 0 THEN
      
      -- Percorrer todos os dados inseridos na tabela de memória
      FOR vr_ind_cooperado IN pr_tab_cooperado.FIRST..pr_tab_cooperado.LAST LOOP
        
        -- Inicializa as variáveis
        vr_vlsldapl := 0;
        vr_vlsldpou := 0;
      
        -- Deve buscar os dados da conta especifica na CRAPASS
        OPEN  cr_crapass(pr_tab_cooperado(vr_ind_cooperado).cdcooper
                        ,pr_tab_cooperado(vr_ind_cooperado).nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        
        -- Verifica se encontrou a conta apenas por garantia
        IF cr_crapass%NOTFOUND THEN
          -- Fechar o cursor 
          CLOSE cr_crapass;
          
          -- Critica
          vr_cdcritic := 9;
          
           -- Gerar registro de erro      
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => 1
                               ,pr_nrdcaixa => 1
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        
          RAISE vr_exp_erro;
        END IF;
      
        -- Fechar o cursor 
        CLOSE cr_crapass;
      
        -- Atualiza a data de admissao
        pr_tab_cooperado(vr_ind_cooperado).dtadmiss := rw_crapass.dtadmiss;
     
        -- Atualiza a data de demissao
        pr_tab_cooperado(vr_ind_cooperado).dtdemiss := rw_crapass.dtdemiss;

        -- Atualiza a agencia
        pr_tab_cooperado(vr_ind_cooperado).cdagenci := rw_crapass.cdagenci;

        -- Se for pessoa física
        IF rw_crapass.inpessoa = 1 THEN
          -- Deve buscar os dados da CRAPTTL
          OPEN cr_crapttl(pr_tab_cooperado(vr_ind_cooperado).cdcooper
                         ,pr_tab_cooperado(vr_ind_cooperado).nrdconta);
          FETCH cr_crapttl INTO rw_crapttl;
          
          -- Verifica se foi encontrado registro do titular
          IF cr_crapttl%NOTFOUND THEN
            -- Fechar o Cursor  
            CLOSE cr_crapttl;
          
            -- Critica
            vr_cdcritic := 821;
            vr_dscritic := NULL;
            
             -- Gerar registro de erro      
            GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => 1
                                 ,pr_nrdcaixa => 1
                                 ,pr_nrsequen => 1
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
            
            -- Retorna o nome do associado que apresentou erro
            pr_nmprimtl := vr_dscritic;
            
            RAISE vr_exp_erro;
          END IF; -- cr_crapttl%NOTFOUND

          -- Fechar o Cursor  
          CLOSE cr_crapttl;
          
        END IF; -- rw_crapass.inpessoa = 1
        
        -- Limpar tabela de valores da conta
        vr_tb_vlr_conta.delete;
        
        -- Buscar dados 
        CADA0004.pc_carrega_dados_atenda(pr_cdcooper => pr_cdcooper                     --> Codigo da cooperativa
                                        ,pr_cdagenci => pr_cdagenci                     --> Codigo de agencia
                                        ,pr_nrdcaixa => pr_nrdcaixa                     --> Numero do caixa
                                        ,pr_cdoperad => pr_cdoperad                     --> Codigo do operador
                                        ,pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt    --> Data do movimento
                                        ,pr_dtmvtopr => BTCH0001.rw_crapdat.dtmvtopr    --> Proxima data do movimento
                                        ,pr_dtmvtoan => BTCH0001.rw_crapdat.dtmvtoan    --> Data anterior do movimento
                                        ,pr_dtiniper => TRUNC(SYSDATE)                  --> Data inicial do periodo
                                        ,pr_dtfimper => TRUNC(SYSDATE)                  --> data final do periodo
                                        ,pr_nmdatela => pr_nmdatela                     --> Nome da tela
                                        ,pr_idorigem => pr_idorigem                     --> Identificado de oriem
                                        ,pr_nrdconta => rw_crapass.nrdconta             --> Numero da conta
                                        ,pr_idseqttl => 1                               --> Sequencial do titular
                                        ,pr_nrdctitg => rw_crapass.nrdctitg             --> Numero da conta itg
                                        ,pr_inproces => pr_inproces                     --> Indicador do processo
                                        ,pr_flgerlog => 'N'                             --> identificador se deve gerar log S-Sim e N-Nao                                    
                                        ---------- OUT --------
                                        ,pr_flconven             => vr_flconven         --> Retorna se aceita convenio
                                        ,pr_tab_cabec            => vr_tab_cabec        --> Retorna dados do cabecalho da tela ATENDA
                                        ,pr_tab_comp_cabec       => vr_tb_comp_cabec    --> observacoes dos associados
                                        ,pr_tab_valores_conta    => vr_tb_vlr_conta     --> Retorna os valores para a tela ATENDA
                                        ,pr_tab_mensagens_atenda => vr_tb_msgs_atenda   --> Retorna as mensagens para tela atenda
                                        ,pr_tab_crapobs          => vr_tb_crapobs       --> observacoes dos associados
                                        ,pr_dscritic             => vr_dscritic         --> Retornar critica que nao aborta processamento            
                                        ,pr_des_reto             => vr_des_reto         --> OK ou NOK
                                        ,pr_tab_erro             => pr_tab_erro);
                                    
        -- Verifica se ocorreu o retorno de erros                        
        IF vr_des_reto = 'NOK' THEN
          IF pr_tab_erro.exists(pr_tab_erro.first) THEN
            vr_dscritic := pr_tab_erro(pr_tab_erro.first).dscritic;
          ELSE
            vr_dscritic := 'Erro na execução da PC_CARREGA_DADOS_ATENDA';
          END IF;
          RAISE vr_exp_erro;      
        END IF;
        
        -- Limpar toda a tabela de memória
        vr_tbsaldo_rdca.DELETE();
        
        -- Busca a listagem de aplicacoes 
        APLI0005.pc_lista_aplicacoes(pr_cdcooper   => pr_cdcooper         -- Código da Cooperativa 
                                    ,pr_cdoperad   => pr_cdoperad         -- Código do Operador
                                    ,pr_nmdatela   => pr_nmdatela         -- Nome da Tela
                                    ,pr_idorigem   => 1                   -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA )
                                    ,pr_nrdcaixa   => 1                   -- Numero do Caixa
                                    ,pr_nrdconta   => rw_crapass.nrdconta -- Número da Conta
                                    ,pr_idseqttl   => 1                   -- Titular da Conta 
                                    ,pr_cdagenci   => 1                   -- Codigo da Agencia
                                    ,pr_cdprogra   => pr_nmdatela         -- Codigo do Programa
                                    ,pr_nraplica   => 0                   -- Número da Aplicaçao 
                                    ,pr_cdprodut   => 0                   -- Código do Produto
                                    ,pr_dtmvtolt   => BTCH0001.rw_crapdat.dtmvtolt -- Data de Movimento
                                    ,pr_idconsul   => 6                   -- Identificador de Consulta
                                    ,pr_idgerlog   => 1                   -- Identificador de Log (0 – Nao / 1 – Sim)
                                    ,pr_cdcritic   => vr_cdcritic         -- Código da crítica 
                                    ,pr_dscritic   => vr_dscritic         -- Descriçao da crítica 
                                    ,pr_saldo_rdca => vr_tbsaldo_rdca );
        
      -- Verifica se ocorreram erros
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Gerar registro de erro      
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => 1
                               ,pr_nrdcaixa => 1
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          
          RAISE vr_exp_erro;    
          
        END IF;
        
        -- Percorrer cada um dos registro encontrados e retornados
        IF vr_tbsaldo_rdca.COUNT() > 0 THEN
          FOR vr_ind_saldo IN vr_tbsaldo_rdca.FIRST()..vr_tbsaldo_rdca.LAST() LOOP
            -- Se a descrição for diferente de bloqueada
            IF vr_tbsaldo_rdca(vr_ind_saldo).dssitapl <> 'BLOQUEADA' THEN
              -- Sumariza o saldo da aplicação
              vr_vlsldapl := NVL(vr_vlsldapl,0) + NVL(vr_tbsaldo_rdca(vr_ind_saldo).sldresga,0);
            END IF;
          END LOOP;
        END IF;
        
        -- Limpar toda a tabela de memória
        vr_tbdados_rpp.DELETE();
        
        -- Consultar dados da Poupança
        APLI0001.pc_consulta_poupanca(pr_cdcooper      => pr_cdcooper
                                     ,pr_cdagenci      => pr_cdagenci
                                     ,pr_nrdcaixa      => pr_nrdcaixa
                                     ,pr_cdoperad      => pr_cdoperad
                                     ,pr_idorigem      => 1 -- pr_nmdatela
                                     ,pr_nrdconta      => rw_crapass.nrdconta
                                     ,pr_idseqttl      => 1
                                     ,pr_nrctrrpp      => 0
                                     ,pr_dtmvtolt      => BTCH0001.rw_crapdat.dtmvtolt
                                     ,pr_dtmvtopr      => BTCH0001.rw_crapdat.dtmvtopr
                                     ,pr_inproces      => 1
                                     ,pr_cdprogra      => pr_nmdatela
                                     ,pr_flgerlog      => FALSE
                                     ,pr_percenir      => 0
                                     ,pr_tab_craptab   => vr_tab_craptab
                                     ,pr_tab_craplpp   => vr_tab_craplpp
                                     ,pr_tab_craplrg   => vr_tab_craplrg
                                     ,pr_tab_resgate   => vr_tab_resgate
                                     ,pr_vlsldrpp      => vr_vlsldrpp
                                     ,pr_retorno       => vr_des_reto
                                     ,pr_tab_dados_rpp => vr_tbdados_rpp
                                     ,pr_tab_erro      => pr_tab_erro);
                                    
        -- Verifica se ocorreu o retorno de erros                        
        IF vr_des_reto = 'NOK' THEN
          IF pr_tab_erro.exists(pr_tab_erro.first) THEN
            vr_dscritic := pr_tab_erro(pr_tab_erro.first).dscritic;
          ELSE
            vr_dscritic := 'Erro na execução da PC_CARREGA_DADOS_ATENDA';
          END IF;
          RAISE vr_exp_erro;      
        END IF;
        
        -- Percorrer cada um dos registro encontrados e retornados
        IF vr_tbdados_rpp.COUNT() > 0 THEN
          FOR vr_ind_rpp IN vr_tbdados_rpp.FIRST()..vr_tbdados_rpp.LAST() LOOP
            -- Se O indicador de bloqueio for diferente de SIM
            IF UPPER(vr_tbdados_rpp(vr_ind_rpp).dsblqrpp) <> 'SIM' THEN
              -- Sumariza o saldo da aplicação
              vr_vlsldpou := NVL(vr_vlsldpou,0) + NVL(vr_tbdados_rpp(vr_ind_rpp).vlrgtrpp,0);
            END IF;
          END LOOP;
        END IF;
        
        -- Buscar dados do cadastro de bloqueio judicial
        FOR rw_crapblj IN cr_crapblj(rw_crapass.cdcooper
                                    ,rw_crapass.nrdconta) LOOP
          /* APLICACAO */
          IF rw_crapblj.cdmodali = 2 THEN  
            vr_vlsldapl := NVL(vr_vlsldapl,0) - NVL(rw_crapblj.vlbloque,0);
          /* POUP. PROGRAMADA */
          ELSIF rw_crapblj.cdmodali = 3 THEN  
            vr_vlsldpou := NVL(vr_vlsldpou,0) - NVL(rw_crapblj.vlbloque,0);
          /* POUP. PROGRAMADA */
          ELSIF rw_crapblj.cdmodali = 4 THEN  /* CAPITAL */
            vr_tb_vlr_conta(vr_tb_vlr_conta.FIRST).vlsldcap := NVL(vr_tb_vlr_conta(vr_tb_vlr_conta.FIRST).vlsldcap ,0)
                                                               - rw_crapblj.vlbloque;
          END IF;        
        END LOOP; -- cr_crapblj
        
        
        /* Buscar valor do saldo devedor dos empréstimos ativos, contratados a partir de Outubro/2014 e
           modalidades de linha de credito (emprestimo/financiamento) */
        FOR rw_creprlcr IN cr_creprlcr(rw_crapass.cdcooper
                                      ,rw_crapass.nrdconta) LOOP
          -- Inicializa a variável          
          vr_vltotemp := 0;
          
          -- Buscar o saldo devedor do empréstimo
          EMPR0001.pc_saldo_devedor_epr(pr_cdcooper => rw_crapass.cdcooper
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => 'B1WGEN0155'
                                       ,pr_idorigem => 1
                                       ,pr_nrdconta => rw_crapass.nrdconta
                                       ,pr_idseqttl => 1
                                       ,pr_rw_crapdat => btch0001.rw_crapdat
                                       ,pr_nrctremp => rw_creprlcr.nrctremp
                                       ,pr_cdprogra => 'B1WGEN0155'
                                       ,pr_inusatab => vr_inusatab
                                       ,pr_flgerlog => 'N'
                                       ,pr_vlsdeved => vr_vltotemp
                                       ,pr_vltotpre => vr_vltotpre
                                       ,pr_qtprecal => vr_qtprecal
                                       ,pr_des_reto => vr_des_reto
                                       ,pr_tab_erro => pr_tab_erro);
                                    
          -- Verifica se ocorreu o retorno de erros                        
          IF vr_des_reto = 'NOK' THEN
            IF pr_tab_erro.exists(pr_tab_erro.first) THEN
              vr_dscritic := pr_tab_erro(pr_tab_erro.first).dscritic;
            ELSE
              vr_dscritic := 'Erro na execução da PC_CARREGA_DADOS_ATENDA';
            END IF;
            
            -- Gerar registro de erro      
            GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
            
            -- Retornar a mensagem de erro
            pr_nmprimtl := pr_tab_erro(pr_tab_erro.first).dscritic;
            
            RAISE vr_exp_erro;    
          END IF;
         
          -- acumula saldo de todos emprestimos ativos
          vr_vlsdeved := NVL(vr_vlsdeved,0) + NVL(vr_vltotemp,0);
            
        END LOOP; -- cr_creprlcr
        
        -- Se tem valores da conta
        IF vr_tb_vlr_conta.count() > 0 THEN
          -- Subtrai o total de saldo devedor dos emprestimos 
          vr_tb_vlr_conta(vr_tb_vlr_conta.FIRST).vlsldcap := 
                         NVL(vr_tb_vlr_conta(vr_tb_vlr_conta.FIRST).vlsldcap,0) - nvl(vr_vlsdeved,0);
                
          -- Verificar valores negativo
          IF  NVL(vr_tb_vlr_conta(vr_tb_vlr_conta.FIRST).vlsldcap,0) < 0 THEN 
            pr_tab_cooperado(vr_ind_cooperado).vlsldcap := 0;
          ELSE 
            pr_tab_cooperado(vr_ind_cooperado).vlsldcap := NVL(vr_tb_vlr_conta(vr_tb_vlr_conta.FIRST).vlsldcap,0);
          END IF;
          
          -- Verificar valores negativo
          IF  NVL(vr_vlsldapl,0) < 0 THEN 
            pr_tab_cooperado(vr_ind_cooperado).vlsldapl := 0;
          ELSE
            pr_tab_cooperado(vr_ind_cooperado).vlsldapl := NVL(vr_vlsldapl,0);
          END IF;
          
          -- Verificar valores negativo
          IF  NVL(vr_tb_vlr_conta(vr_tb_vlr_conta.FIRST).vlstotal,0) < 0 THEN 
            pr_tab_cooperado(vr_ind_cooperado).vlstotal := 0;
          ELSE
            pr_tab_cooperado(vr_ind_cooperado).vlstotal := NVL(vr_tb_vlr_conta(vr_tb_vlr_conta.FIRST).vlstotal,0);
          END IF;
                             
          -- Verificar valores negativo
          IF  NVL(vr_vlsldpou,0) < 0 THEN 
            pr_tab_cooperado(vr_ind_cooperado).vlsldppr := 0;
          ELSE
            pr_tab_cooperado(vr_ind_cooperado).vlsldppr := NVL(vr_vlsldpou,0);
          END IF;
        END IF; -- vr_tb_vlr_conta.count() > 0 
      END LOOP;
    END IF;
    
  EXCEPTION 
    WHEN vr_exp_erro THEN
      -- Retornar a critica de erro
      pr_tab_erro(1).dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Retornar a critica de erro
      pr_tab_erro(1).dscritic := 'Erro na PC_BUSCA_CONTAS_COOPERADO: '||SQLERRM;
  END pc_busca_contas_cooperado;
  
  
  -- Chamar a inclui-bloqueio-jud por mensageria
  PROCEDURE pc_inclui_bloqueio_jud_web(pr_cdcooper  IN NUMBER       
                                      ,pr_nrdconta  IN VARCHAR2  /*LISTAS*/
                                      ,pr_cdtipmov  IN VARCHAR2  /*LISTAS*/
                                      ,pr_cdmodali  IN VARCHAR2  /*LISTAS*/
                                      ,pr_vlbloque  IN VARCHAR2  /*LISTAS*/
                                      ,pr_nroficio  IN VARCHAR2  
                                      ,pr_nrproces  IN VARCHAR2  
                                      ,pr_dsjuizem  IN VARCHAR2  
                                      ,pr_dsresord  IN VARCHAR2  
                                      ,pr_flblcrft  IN NUMBER  -- 0 para FALSE / 1 para TRUE      
                                      ,pr_dtenvres  IN VARCHAR2      
                                      ,pr_vlrsaldo  IN VARCHAR2      
                                      ,pr_cdoperad  IN VARCHAR2      
                                      ,pr_dsinfadc  IN VARCHAR2                  
                                      ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER             --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2                --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS            --> Erros do processo 
                                   
    -- VARIÁVEIS
    vr_tab_erro      GENE0001.typ_tab_erro;
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(2000);
    vr_flblcrft      BOOLEAN;
    vr_dtenvres      DATE := to_date(pr_dtenvres,'DD/MM/YYYY');
    vr_vlrsaldo      NUMBER := GENE0002.fn_char_para_number(pr_vlrsaldo);
    
    -- EXCEPTIONS
    vr_exc_saida     EXCEPTION;
    
  BEGIN 
    
    pr_des_erro := 'OK';
    
    gene0001.pc_informa_acesso(pr_module => 'BLQJ0001');
    
    -- Verifica se foi passado true ou false
    IF NVL(pr_flblcrft,0) = 0 THEN
      vr_flblcrft := FALSE;
    ELSE
      vr_flblcrft := TRUE;
    END IF;
    
    -- Chamar a procedure
    BLQJ0001.pc_inclui_bloqueio_jud(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_cdtipmov => pr_cdtipmov
                                   ,pr_cdmodali => pr_cdmodali
                                   ,pr_vlbloque => pr_vlbloque
                                   ,pr_nroficio => pr_nroficio
                                   ,pr_nrproces => pr_nrproces 
                                   ,pr_dsjuizem => pr_dsjuizem 
                                   ,pr_dsresord => pr_dsresord 
                                   ,pr_flblcrft => vr_flblcrft    
                                   ,pr_dtenvres => vr_dtenvres 
                                   ,pr_vlrsaldo => vr_vlrsaldo   
                                   ,pr_cdoperad => pr_cdoperad    
                                   ,pr_dsinfadc => pr_dsinfadc 
                                   ,pr_tab_erro => vr_tab_erro);
   
    -- Se houve o retorno de erro
    IF vr_tab_erro.count() > 0 THEN
      --vr_dscritic := 'Nao foi possivel consultar os registros.';
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic; -- Retornar o erro ocorrido na rotina
      RAISE vr_exc_saida;
    END IF;
    
    -- Retornar XML em branco
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral PC_INCLUI_BLOQUEIO_JUD_WEB: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_inclui_bloqueio_jud_web; 
  
  
  -- Incluir bloqueios judiciais
  PROCEDURE pc_inclui_bloqueio_jud(pr_cdcooper    IN NUMBER       
                                  ,pr_nrdconta    IN VARCHAR2  /*LISTAS*/
                                  ,pr_cdtipmov    IN VARCHAR2  /*LISTAS*/
                                  ,pr_cdmodali    IN VARCHAR2  /*LISTAS*/
                                  ,pr_vlbloque    IN VARCHAR2  /*LISTAS*/
                                  ,pr_nroficio    IN VARCHAR2  
                                  ,pr_nrproces    IN VARCHAR2  
                                  ,pr_dsjuizem    IN VARCHAR2  
                                  ,pr_dsresord    IN VARCHAR2  
                                  ,pr_flblcrft    IN BOOLEAN      
                                  ,pr_dtenvres    IN DATE      
                                  ,pr_vlrsaldo    IN NUMBER      
                                  ,pr_cdoperad    IN VARCHAR2      
                                  ,pr_dsinfadc    IN VARCHAR2         
                                  ,pr_tab_erro   IN OUT GENE0001.typ_tab_erro) IS  --> Retorno de erro   
    
    -- CURSORES
    -- Buscar dados do cadastro de bloqueio
    CURSOR cr_crapblj(pr_cdcooper  crapblj.cdcooper%TYPE
                     ,pr_nrdconta  crapblj.nrdconta%TYPE
                     ,pr_nroficio  crapblj.nroficio%TYPE
                     ,pr_cdmodali  crapblj.cdmodali%TYPE) IS
      SELECT 1
        FROM crapblj blj
       WHERE blj.cdcooper = pr_cdcooper
         AND blj.nrdconta = pr_nrdconta
         AND blj.nroficio = pr_nroficio
         AND blj.cdmodali = pr_cdmodali;
    rw_crapblj   cr_crapblj%ROWTYPE;
    
    -- Buscar dados da conta do cooperado
    CURSOR cr_crapass(pr_cdcooper  crapass.cdcooper%TYPE
                     ,pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
           , ass.nrcpfcgc
           , ass.nrdctitg
           , ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper 
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass   cr_crapass%ROWTYPE;
    
    -- Buscar as contas do cooperado pelo documento
    CURSOR cr_contcpf(pr_cdcooper  crapass.cdcooper%TYPE
                     ,pr_nrcpfcgc  crapass.nrcpfcgc%TYPE) IS
      SELECT ass.nrdconta
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper 
         AND ass.nrcpfcgc = pr_nrcpfcgc;
    
    -- Buscar pelo lançamento
    CURSOR cr_craplcm(pr_nrdconta  craplcm.nrdconta%TYPE
                     ,pr_nrdocmto  craplcm.nrdocmto%TYPE
                     ,pr_dtmvtolt  craplcm.dtmvtolt%TYPE) IS
      SELECT 1
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdagenci = 1
         AND lcm.cdbccxlt = 100
         AND lcm.nrdolote = 6880
         AND lcm.nrdctabb = pr_nrdconta
         AND lcm.nrdocmto = pr_nrdocmto;
    
    -- Buscar lançamento automático
    CURSOR cr_craplau(pr_nrdconta  craplau.nrdconta%TYPE
                     ,pr_nrdocmto  craplau.nrdocmto%TYPE
                     ,pr_dtmvtolt  craplau.dtmvtolt%TYPE) IS
      SELECT 1
        FROM craplau lau
       WHERE lau.cdcooper = pr_cdcooper     
         AND lau.dtmvtolt = pr_dtmvtolt     
         AND lau.cdagenci = 1
         AND lau.cdbccxlt = 100
         AND lau.nrdolote = 6870
         AND lau.nrdctabb = pr_nrdconta
         AND lau.nrdocmto = pr_nrdocmto;
    
    -- VARIÁVEIS
    vr_tbcontas      GENE0002.typ_split;
    vr_tbtipmov      GENE0002.typ_split;
    vr_tbmodali      GENE0002.typ_split;
    vr_tbbloque      GENE0002.typ_split;
    vr_fldepvis      BOOLEAN;
    vr_flgbloqu      BOOLEAN;
    vr_flgtrans      BOOLEAN;
    vr_flblcrft      NUMBER;
    vr_nrdregis      NUMBER;
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(1000);
    vr_nrcpfcgc      NUMBER;
    vr_nmprimtl      VARCHAR2(100);
    
    vr_dtblqfim      crapblj.dtblqfim%TYPE;
    vr_vlresblq      crapblj.vlresblq%TYPE;
    vr_nrdocmto      craplcm.nrdocmto%TYPE;
    
    -- EXCEPTIONS
    vr_exp_erro       EXCEPTION;
    
  BEGIN
    
    -- Faz o split das contas 
    vr_tbcontas := GENE0002.fn_quebra_string(pr_string => pr_nrdconta
                                            ,pr_delimit => ';');
    vr_tbtipmov := GENE0002.fn_quebra_string(pr_string => pr_cdtipmov
                                            ,pr_delimit => ';');
    vr_tbmodali := GENE0002.fn_quebra_string(pr_string => pr_cdmodali
                                            ,pr_delimit => ';');
    vr_tbbloque := GENE0002.fn_quebra_string(pr_string => pr_vlbloque
                                            ,pr_delimit => ';');
    
    -- Inicializa as variáveis                                        
    vr_fldepvis := FALSE;
    vr_flgbloqu := TRUE;    
    vr_flgtrans := FALSE;
    
    -- Se a primeira entrada do cdtipmov for igual a 2
    IF vr_tbtipmov.EXISTS(1) THEN
      IF TO_NUMBER(vr_tbtipmov(1)) = 2 THEN
        vr_flgbloqu := FALSE;
      END IF;
    END IF;
    
    -- Buscar a CRAPDAT para a cooperativa
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO BTCH0001.rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
    
    -- Se encontrar registros
    IF vr_tbcontas.COUNT() > 0 THEN
      
      -- Se o flag estiver como True
      IF pr_flblcrft THEN
        vr_flblcrft := 1;
      ELSE 
        vr_flblcrft := 0;
      END IF;
      

        
      FOR vr_indice IN vr_tbcontas.FIRST()..vr_tbcontas.LAST() LOOP
        
        -- Buscar dados da conta
        OPEN  cr_crapass(pr_cdcooper
                        ,vr_tbcontas(vr_indice));
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;

        BEGIN 
          
          -- Se a flag estiver true
          IF vr_flgbloqu THEN
            vr_dtblqfim := NULL;
          ELSE 
            vr_dtblqfim := BTCH0001.rw_crapdat.dtmvtolt;
          END IF;
          
          -- Se a modalidade for 1
          IF TO_NUMBER(vr_tbmodali(vr_indice)) = 1  THEN
            vr_vlresblq := pr_vlrsaldo;
            vr_fldepvis := TRUE;
          ELSE
            vr_vlresblq := 0;
          END IF;
        
          -- Inserir o registro do bloqueio
          INSERT INTO crapblj(cdcooper
                             ,nrdconta
                             ,nrcpfcgc
                             ,cdmodali
                             ,cdtipmov
                             ,flblcrft
                             ,dtblqini
                             ,dtblqfim
                             ,vlbloque
                             ,cdopdblq
                             ,cdopddes
                             ,dsjuizem
                             ,dsresord
                             ,dtenvres
                             ,nroficio
                             ,nrproces
                             ,dsinfadc
                             ,vlresblq
                             ,hrblqini)
                       VALUES(pr_cdcooper                       -- cdcooper
                             ,rw_crapass.nrdconta               -- nrdconta
                             ,rw_crapass.nrcpfcgc               -- nrcpfcgc
                             ,TO_NUMBER(vr_tbmodali(vr_indice)) -- cdmodali
                             ,TO_NUMBER(vr_tbtipmov(vr_indice)) -- cdtipmov
                             ,vr_flblcrft                       -- flblcrft
                             ,BTCH0001.rw_crapdat.dtmvtolt      -- dtblqini
                             ,vr_dtblqfim                       -- dtblqfim
                             ,TO_NUMBER(vr_tbbloque(vr_indice)) -- vlbloque
                             ,pr_cdoperad                       -- cdopdblq /* Operador Bloqueio    */
                             ,NULL                              -- cdopddes /* Operador Desbloqueio */
                             ,pr_dsjuizem                       -- dsjuizem
                             ,pr_dsresord                       -- dsresord
                             ,pr_dtenvres                       -- dtenvres
                             ,trim(replace(gene0007.fn_caract_acento(pr_nroficio,1,
                                                             '@#$&%¹²³ªº°*!?<>/\|.,:-_"{}[]',
                                                             '                             '),' ')) -- nroficio
                             ,pr_nrproces                       -- nrproces
                             ,pr_dsinfadc                       -- dsinfadc
                             ,vr_vlresblq                       -- vlresblq
                             ,GENE0002.fn_busca_time);
        EXCEPTION               
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir CRAPBLJ: '||SQLERRM;
            RAISE vr_exp_erro;
        END;
        
        -- Setar a variavel de transação
        vr_flgtrans := TRUE;
        
        -- Se modalidade 1 e houver valor bloqueado deve criar o lançamento
        IF TO_NUMBER(vr_tbmodali(vr_indice)) = 1 AND TO_NUMBER(vr_tbbloque(vr_indice)) > 0 THEN
          -- Buscar o lote para o lançamento
          OPEN  cr_craplot(pr_cdcooper
                          ,BTCH0001.rw_crapdat.dtmvtolt
                          ,6880);
          FETCH cr_craplot INTO rw_craplot;
          
          -- Se não encontrar o registro do lote
          IF cr_craplot%NOTFOUND THEN
            -- Cria o lote
            BEGIN
              INSERT INTO craplot(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,nrseqdig)
                           VALUES(pr_cdcooper
                                 ,BTCH0001.rw_crapdat.dtmvtolt
                                 ,1           
                                 ,100          
                                 ,6880
                                 ,1
                                 ,0) 
                        RETURNING ROWID INTO rw_craplot.dsdrowid;
                         
               -- Atualizar o registro do lote        
               rw_craplot.cdcooper := pr_cdcooper;
               rw_craplot.dtmvtolt := BTCH0001.rw_crapdat.dtmvtolt;
               rw_craplot.cdagenci := 1;
               rw_craplot.cdbccxlt := 100;        
               rw_craplot.nrdolote := 6880;
               rw_craplot.tplotmov := 1;               
               rw_craplot.nrseqdig := 0;
               
            EXCEPTION 
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir Lote: '||SQLERRM;
                RAISE vr_exp_erro;
            END;
          END IF;
          
          -- Fechar o cursor
          CLOSE cr_craplot;

          -- Montar o número do documento com base no NRSEQDIG
          vr_nrdocmto := rw_craplot.nrseqdig + 1;
          -------------             
          LOOP
            -- Buscar por lançamento pelo número do documento
            OPEN  cr_craplcm(rw_crapass.nrdconta
                            ,vr_nrdocmto
                            ,BTCH0001.rw_crapdat.dtmvtolt);
            FETCH cr_craplcm INTO vr_nrdregis;
            
            -- Se encontrou registro
            IF cr_craplcm%NOTFOUND THEN 
              -- Fechar o cursor
              CLOSE cr_craplcm;
              -- Encerra o LOOP
              EXIT;              
            END IF;
            
            -- Fechar o cursor
            CLOSE cr_craplcm;
            
            -- Ajusta o número do documento para reconsultar
            vr_nrdocmto := vr_nrdocmto + 100000;
          END LOOP;
          -------------
          
          -- Inserir registro na CRAPLCM 
          BEGIN
            INSERT INTO craplcm(cdcooper
                               ,dtmvtolt
                               ,dtrefere
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,nrdconta
                               ,nrdctabb
                               ,nrdctitg
                               ,nrdocmto
                               ,cdhistor
                               ,vllanmto
                               ,nrseqdig
                               ,cdpesqbb)
                         VALUES(pr_cdcooper                       -- cdcooper
                               ,BTCH0001.rw_crapdat.dtmvtolt      -- dtmvtolt
                               ,BTCH0001.rw_crapdat.dtmvtolt      -- dtrefere
                               ,rw_craplot.cdagenci               -- cdagenci
                               ,rw_craplot.cdbccxlt               -- cdbccxlt
                               ,rw_craplot.nrdolote               -- nrdolote
                               ,rw_crapass.nrdconta               -- nrdconta
                               ,rw_crapass.nrdconta               -- nrdctabb
                               ,rw_crapass.nrdctitg               -- nrdctitg
                               ,vr_nrdocmto                       -- nrdocmto
                               ,DECODE(rw_crapass.inpessoa, 1, 1402, 1403) -- cdhistor => 1402 - PF / 1403 - PJ
                               ,TO_NUMBER(vr_tbbloque(vr_indice)) -- vllanmto
                               ,rw_craplot.nrseqdig + 1           -- nrseqdig
                               ,'BLOQJUD');                       -- cdpesqbb
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir Lancamento: '||SQLERRM;
              RAISE vr_exp_erro;
          END;
          
          -- Atualizar o registro da CRAPLOT
          BEGIN
            UPDATE craplot 
               SET qtcompln = NVL(qtcompln,0) + 1
                 , qtinfoln = NVL(qtinfoln,0) + 1
                 , nrseqdig = NVL(nrseqdig,0) + 1   
                 , vlinfodb = NVL(vlinfodb,0) + TO_NUMBER(vr_tbbloque(vr_indice))
                 , vlcompdb = NVL(vlcompdb,0) + TO_NUMBER(vr_tbbloque(vr_indice))
             WHERE ROWID = rw_craplot.dsdrowid;
          EXCEPTION           
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar Lote: '||SQLERRM;
              RAISE vr_exp_erro;
          END;
          
          -- Atualizar o registro de saldo
          BEGIN
            UPDATE crapsld 
               SET vlblqjud = NVL(vlblqjud,0) + TO_NUMBER(vr_tbbloque(vr_indice))
             WHERE cdcooper = pr_cdcooper     
               AND nrdconta = rw_crapass.nrdconta;

            -- Se nenhuma linha foi atualizada
            IF SQL%ROWCOUNT = 0 THEN
              vr_cdcritic := 10;
              vr_dscritic := NULL;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar saldo cooperado: '||SQLERRM;
          END;
          
          -- Se ocorreu algum erro no update do saldo
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exp_erro;
          END IF;
        
        END IF;
        
        -- Tratamento para o ultimo registro
        IF vr_indice = vr_tbcontas.LAST() AND 
           NOT vr_fldepvis  AND
           pr_vlrsaldo > 0  AND
           pr_flblcrft      AND
           vr_flgbloqu      THEN

          BEGIN 
            
            -- Inserir o registro do bloqueio
            INSERT INTO crapblj(cdcooper
                               ,nrdconta
                               ,nrcpfcgc
                               ,cdmodali
                               ,cdtipmov
                               ,flblcrft
                               ,dtblqini
                               ,dtblqfim
                               ,vlbloque
                               ,cdopdblq
                               ,cdopddes
                               ,dsjuizem
                               ,dsresord
                               ,dtenvres
                               ,nroficio
                               ,nrproces
                               ,dsinfadc
                               ,vlresblq
                               ,hrblqini)
                         VALUES(pr_cdcooper                       -- cdcooper
                               ,rw_crapass.nrdconta               -- nrdconta
                               ,rw_crapass.nrcpfcgc               -- nrcpfcgc
                               ,1  /* Dep. a Vista */             -- cdmodali
                               ,TO_NUMBER(vr_tbtipmov(vr_indice)) -- cdtipmov
                               ,vr_flblcrft                       -- flblcrft
                               ,BTCH0001.rw_crapdat.dtmvtolt      -- dtblqini
                               ,NULL                              -- dtblqfim
                               ,0                                 -- vlbloque
                               ,pr_cdoperad                       -- cdopdblq /* Operador Bloqueio    */
                               ,NULL                              -- cdopddes /* Operador Desbloqueio */
                               ,pr_dsjuizem                       -- dsjuizem
                               ,pr_dsresord                       -- dsresord
                               ,pr_dtenvres                       -- dtenvres
                               ,trim(replace(gene0007.fn_caract_acento(pr_nroficio,1,
                                                             '@#$&%¹²³ªº°*!?<>/\|.,:-_"{}[]',
                                                             '                             '),' ')) -- nroficio
                               ,pr_nrproces                       -- nrproces
                               ,pr_dsinfadc                       -- dsinfadc
                               ,pr_vlrsaldo                       -- vlresblq
                               ,GENE0002.fn_busca_time);
          EXCEPTION               
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir CRAPBLJ: '||SQLERRM;
              RAISE vr_exp_erro;
          END;
        END IF;
        
      END LOOP;
      
      -- 
      IF pr_flblcrft           AND
         pr_vlrsaldo > 0       AND
         vr_flgbloqu           THEN
      
        -- Busca CPF/CNPJ do cooperado 
        pc_busca_nrcpfcgc_cooperado(pr_cdcooper   => pr_cdcooper
                                   ,pr_nrctadoc   => vr_tbcontas(1)
                                   ,pr_nrcpfcgc   => vr_nrcpfcgc
                                   ,pr_tpcooperad => 0
                                   ,pr_nmprimtl   => vr_nmprimtl
                                   ,pr_dscritic   => vr_dscritic);
        
        -- Se houve alguma critica na execução da rotina
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exp_erro;
        END IF;
        
        -- Buscar contas pelo CPF
        FOR rw_contcpf IN cr_contcpf(pr_cdcooper
                                    ,vr_nrcpfcgc) LOOP
                                            
          -- Buscar o lote para o lançamento
          OPEN  cr_craplot(pr_cdcooper
                          ,BTCH0001.rw_crapdat.dtmvtolt
                          ,6870);
          FETCH cr_craplot INTO rw_craplot;
          
          -- Se não encontrar o registro do lote
          IF cr_craplot%NOTFOUND THEN
            -- Cria o lote
            BEGIN
              INSERT INTO craplot(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,nrseqdig)
                           VALUES(pr_cdcooper
                                 ,BTCH0001.rw_crapdat.dtmvtolt
                                 ,1           
                                 ,100          
                                 ,6870
                                 ,1
                                 ,0) 
                        RETURNING ROWID INTO rw_craplot.dsdrowid;
                         
               -- Atualizar o registro do lote        
               rw_craplot.cdcooper := pr_cdcooper;
               rw_craplot.dtmvtolt := BTCH0001.rw_crapdat.dtmvtolt;
               rw_craplot.cdagenci := 1;
               rw_craplot.cdbccxlt := 100;        
               rw_craplot.nrdolote := 6870;
               rw_craplot.tplotmov := 1;               
               rw_craplot.nrseqdig := 0;
               
            EXCEPTION 
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir Lote: '||SQLERRM;
                RAISE vr_exp_erro;
            END;
          END IF;
          
          -- Fechar o cursor
          CLOSE cr_craplot;
          
          -- Montar o número do documento com base no NRSEQDIG
          vr_nrdocmto := rw_craplot.nrseqdig + 1;
          -------------             
          LOOP
            -- Buscar por lançamento pelo número do documento
            OPEN  cr_craplau(rw_contcpf.nrdconta
                            ,vr_nrdocmto
                            ,BTCH0001.rw_crapdat.dtmvtolt);
            FETCH cr_craplau INTO vr_nrdregis;
            
            -- Se encontrou registro
            IF cr_craplau%NOTFOUND THEN 
              -- Fechar o cursor
              CLOSE cr_craplau;
              -- Encerra o LOOP
              EXIT;              
            END IF;
            
            -- Fechar o cursor
            CLOSE cr_craplau;
            
            -- Ajusta o número do documento para reconsultar
            vr_nrdocmto := vr_nrdocmto + 100000;
          END LOOP;
          -------------
          
          -- Inserir registro na CRAPLAU
          BEGIN
            INSERT INTO craplau(cdcooper
                               ,dtmvtolt
                               ,dtmvtopg
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,nrdconta
                               ,nrdctabb
                               ,nrdctitg
                               ,nrdocmto
                               ,cdhistor    
                               ,vllanaut
                               ,nrseqdig
                               ,insitlau
                               ,dtdebito
                               ,dsorigem
                               ,cdseqtel)
                         VALUES(pr_cdcooper                       -- cdcooper
                               ,BTCH0001.rw_crapdat.dtmvtolt      -- dtmvtolt
                               ,BTCH0001.rw_crapdat.dtmvtolt      -- dtmvtopg
                               ,rw_craplot.cdagenci               -- cdagenci
                               ,rw_craplot.cdbccxlt               -- cdbccxlt
                               ,rw_craplot.nrdolote               -- nrdolote
                               ,rw_crapass.nrdconta               -- nrdconta
                               ,rw_crapass.nrdconta               -- nrdctabb
                               ,rw_crapass.nrdctitg               -- nrdctitg
                               ,vr_nrdocmto                       -- nrdocmto
                               ,DECODE(rw_crapass.inpessoa, 1, 1402, 1403) -- cdhistor => 1402 - PF / 1403 - PJ
                               ,pr_vlrsaldo                       -- vllanaut
                               ,rw_craplot.nrseqdig + 1           -- nrseqdig
                               ,1                                 -- insitlau
                               , NULL                             -- dtdebito
                               ,'BLOQJUD'                         -- dsorigem
                               ,pr_nroficio);                     -- cdseqtel
                               
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir CRAPLAU: '||SQLERRM;
              RAISE vr_exp_erro;
          END;
          
          -- Atualizar o registro da CRAPLOT
          BEGIN
            UPDATE craplot 
               SET qtcompln = NVL(qtcompln,0) + 1
                 , qtinfoln = NVL(qtinfoln,0) + 1
                 , nrseqdig = NVL(nrseqdig,0) + 1   
                 , vlinfodb = NVL(vlinfodb,0) + pr_vlrsaldo
                 , vlcompdb = NVL(vlcompdb,0) + pr_vlrsaldo
             WHERE ROWID = rw_craplot.dsdrowid;
          EXCEPTION           
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar Lote: '||SQLERRM;
              RAISE vr_exp_erro;
          END;
          
          -- Setar a flag de transação
          vr_flgtrans := TRUE;      
        END LOOP;
      END IF;
    END IF;
        
    -- Se não efetuou transação
    IF NOT vr_flgtrans THEN
      -- Gerar a crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro na gravacao da LAUTOM!';
        
      -- Gera o erro e encerra a execução
      RAISE vr_exp_erro;

    END IF;
        
    
  EXCEPTION
    WHEN vr_exp_erro THEN
      -- Gerar registro de erro      
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 0
                           ,pr_nrdcaixa => 1
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      pr_tab_erro(1).cdcritic := 0;
      pr_tab_erro(1).dscritic := 'Erro na PC_INCLUI_BLOQUEIO_JUD: '||SQLERRM;
  END pc_inclui_bloqueio_jud;
  
  -- Chamar a efetua-desbloqueio-jud por mensageria
  PROCEDURE pc_efetua_desbloqueio_jud_web(pr_cdcooper   IN NUMBER
                                         ,pr_dtmvtolt   IN VARCHAR2
                                         ,pr_cdoperad   IN VARCHAR2
                                         ,pr_nroficio   IN VARCHAR2
                                         ,pr_nrctacon   IN VARCHAR2
                                         ,pr_nrofides   IN VARCHAR2
                                         ,pr_dtenvdes   IN VARCHAR2
                                         ,pr_dsinfdes   IN VARCHAR2
                                         ,pr_fldestrf   IN NUMBER  
                                         ,pr_tpcooperad IN NUMBER   DEFAULT 0
                                         ,pr_vldesblo   IN NUMBER
                                         ,pr_cdmodali   IN NUMBER
                                         ,pr_xmllog     IN VARCHAR2             --> XML com informações de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml     IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo 
  
    -- VARIÁVEIS
    vr_tab_erro      GENE0001.typ_tab_erro;
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(2000);
    vr_fldestrf      BOOLEAN;
    vr_dtmvtolt      DATE := to_date(pr_dtmvtolt,'DD/MM/YYYY');
    vr_dtenvdes      DATE := to_date(pr_dtenvdes,'DD/MM/YYYY');
    
    -- EXCEPTIONS
    vr_exc_saida     EXCEPTION;
    
  BEGIN 
    
    pr_des_erro := 'OK';
    
    gene0001.pc_informa_acesso(pr_module => 'BLQJ0001');
        
    -- Verifica se foi passado true ou false
    IF NVL(pr_fldestrf,0) = 0 THEN
      vr_fldestrf := FALSE;
    ELSE
      vr_fldestrf := TRUE;
    END IF;
    
    -- Chamar a procedure
    BLQJ0001.pc_efetua_desbloqueio_jud(pr_cdcooper   => pr_cdcooper
                                      ,pr_dtmvtolt   => vr_dtmvtolt
                                      ,pr_cdoperad   => pr_cdoperad
                                      ,pr_nroficio   => pr_nroficio
                                      ,pr_nrctacon   => pr_nrctacon
                                      ,pr_nrofides   => pr_nrofides
                                      ,pr_dtenvdes   => vr_dtenvdes
                                      ,pr_dsinfdes   => pr_dsinfdes
                                      ,pr_fldestrf   => vr_fldestrf       
                                      ,pr_tpcooperad => NVL(pr_tpcooperad,0)
                                      ,pr_vldesblo   => pr_vldesblo
                                      ,pr_cdmodali   => pr_cdmodali  ---- 0 -- Processar todas as modalidades
                                      ,pr_tab_erro   => vr_tab_erro);
   
    -- Se houve o retorno de erro
    IF vr_tab_erro.count() > 0 THEN
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic; -- Retornar o erro ocorrido na rotina
      RAISE vr_exc_saida;
    END IF;
    
    -- Retornar XML em branco
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral PC_EFETUA_DESBLOQUEIO_JUD_WEB: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;  
  END pc_efetua_desbloqueio_jud_web;
  
  
  -- Efetuar os desbloqueios judiciais
  PROCEDURE pc_efetua_desbloqueio_jud(pr_cdcooper   IN NUMBER
                                     ,pr_dtmvtolt   IN DATE
                                     ,pr_cdoperad   IN VARCHAR2
                                     ,pr_nroficio   IN VARCHAR2
                                     ,pr_nrctacon   IN VARCHAR2
                                     ,pr_nrofides   IN VARCHAR2
                                     ,pr_dtenvdes   IN DATE
                                     ,pr_dsinfdes   IN VARCHAR2
                                     ,pr_fldestrf   IN BOOLEAN 
                                     ,pr_tpcooperad IN NUMBER     DEFAULT 0
                                     ,pr_vldesblo   IN NUMBER
                                     ,pr_cdmodali   IN NUMBER     DEFAULT 0
                                     ,pr_tab_erro   IN OUT GENE0001.typ_tab_erro) IS  --> Retorno de erro   
    
    -- CURSORES
    
    -- Buscar as modalidades e demais dados da crapblj
    CURSOR cr_crapblj(pr_nrcpfcgc crapblj.nrcpfcgc%TYPE) IS
      SELECT blj.rowid    dsdrowid
           , blj.cdmodali
           , blj.vlbloque
           , blj.flblcrft
           , blj.dtblqini
           , ass.nrdconta
           , ass.nrdctitg
           , ass.inpessoa
           , COUNT(1) OVER (PARTITION BY blj.cdcooper
                                       , blj.nroficio
                                       , blj.nrcpfcgc
                                       , blj.cdmodali) qtdreg_ag
           , ROW_NUMBER() OVER (PARTITION BY blj.cdcooper
                                           , blj.nroficio
                                           , blj.nrcpfcgc
                                           , blj.cdmodali
                                    ORDER BY blj.cdcooper
                                           , blj.nroficio
                                           , blj.nrcpfcgc
                                           , blj.cdmodali) nrseqreg_ag
        FROM crapblj blj
           , crapass ass
       WHERE ass.cdcooper = blj.cdcooper 
         AND ass.nrdconta = blj.nrdconta
         AND blj.cdcooper = pr_cdcooper
         AND blj.nroficio = pr_nroficio  
         AND blj.nrdconta = pr_nrctacon 
         AND ((blj.nrcpfcgc = pr_nrcpfcgc AND pr_tpcooperad = 0) 
           OR (blj.nrdconta = pr_nrctacon AND pr_tpcooperad = 1) )
         AND blj.dtblqfim IS NULL
         AND (blj.cdmodali = pr_cdmodali OR NVL(pr_cdmodali,0) = 0)
      ORDER BY blj.cdmodali
             , blj.dtblqini
             , blj.hrblqini
             , blj.dtblqfim
             , blj.hrblqfim;

    -- Total bloqueado
    CURSOR cr_crapbljtot(pr_nrcpfcgc crapblj.nrcpfcgc%TYPE) IS
      SELECT NVL(SUM(blj.vlbloque),0)
        FROM crapblj blj
       WHERE blj.cdcooper = pr_cdcooper
         AND blj.nroficio = pr_nroficio
         AND blj.nrdconta = pr_nrctacon
         AND ((blj.nrcpfcgc = pr_nrcpfcgc AND pr_tpcooperad = 0) 
           OR (blj.nrdconta = pr_nrctacon AND pr_tpcooperad = 1) )
         AND blj.dtblqfim IS NULL
         AND (blj.cdmodali = pr_cdmodali OR NVL(pr_cdmodali,0) = 0);
    
    -- Buscar pelo lançamento
    CURSOR cr_craplcm(pr_nrdconta  craplcm.nrdconta%TYPE
                     ,pr_nrdocmto  craplcm.nrdocmto%TYPE) IS
      SELECT 1
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdagenci = 1
         AND lcm.cdbccxlt = 100
         AND lcm.nrdolote = 6880
         AND lcm.nrdctabb = pr_nrdconta
         AND lcm.nrdocmto = pr_nrdocmto;
        
    -- VARIÁVEIS
    vr_nrdocmto      craplot.nrseqdig%TYPE;
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(1000);
    vr_nrcpfcgc      NUMBER;
    vr_nrdregis      NUMBER;
    vr_nmprimtl      VARCHAR2(100);
    vr_fldestrf      NUMBER;
    vr_vldesblo      NUMBER := pr_vldesblo;
    ww_vldesblo      NUMBER;
    vr_vltotblq      NUMBER;
    vr_inserlcm      BOOLEAN;
    
    -- EXCEPTIONS
    vr_exp_erro       EXCEPTION;
    
  BEGIN
    
    -- Busca CPF/CNPJ do cooperado 
    pc_busca_nrcpfcgc_cooperado(pr_cdcooper   => pr_cdcooper
                               ,pr_nrctadoc   => pr_nrctacon
                               ,pr_tpcooperad => pr_tpcooperad 
                               ,pr_nrcpfcgc   => vr_nrcpfcgc
                               ,pr_nmprimtl   => vr_nmprimtl
                               ,pr_dscritic   => vr_dscritic);
        
    -- Se houve alguma critica na execução da rotina
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exp_erro;
    END IF;
    
    -- Ajustar o flag 
    IF pr_fldestrf THEN
      vr_fldestrf := 1; -- TRUE
    ELSE 
      vr_fldestrf := 0; -- FALSE
    END IF;
    
    -- verificar se valor informado na tela maior que bloqueado
    OPEN  cr_crapbljtot(vr_nrcpfcgc);
    FETCH cr_crapbljtot INTO vr_vltotblq;
    CLOSE cr_crapbljtot;
    IF vr_vldesblo > vr_vltotblq THEN
      vr_dscritic := 'Valor de desbloqueio R$ '||vr_vldesblo||' maior que o valor bloqueado R$ '||vr_vltotblq;
      RAISE vr_exp_erro;
    END IF;
    
	vr_inserlcm := FALSE; --inicializando a vr_insere para creditar apenas 1 vez

    -- Percorrer todos os bloqueios da conta
    FOR rw_crapblj IN cr_crapblj(vr_nrcpfcgc) LOOP
      ww_vldesblo := 0;
      IF vr_vldesblo >= NVL(rw_crapblj.vlbloque,0) THEN
        ww_vldesblo := rw_crapblj.vlbloque;
      ELSIF vr_vldesblo > 0
      AND NVL(rw_crapblj.vlbloque,0) > vr_vldesblo THEN
        -- para fazer demais atualizações com valor de desbloqueio menor
        ww_vldesblo := vr_vldesblo;
      
        -- inserir novo registro com valor de desbloqueio
        BEGIN
          INSERT INTO crapblj(cdcooper
                             ,nrdconta
                             ,nrcpfcgc
                             ,cdmodali
                             ,cdtipmov
                             ,flblcrft
                             ,dtblqini
                             ,dtblqfim
                             ,vlbloque
                             ,cdopdblq
                             ,cdopddes
                             ,dsjuizem
                             ,dsresord
                             ,dtenvres
                             ,nroficio
                             ,nrproces
                             ,dsinfadc
                             ,vlresblq
                             ,hrblqini)
                       SELECT cdcooper
                             ,nrdconta
                             ,nrcpfcgc
                             ,cdmodali
                             ,cdtipmov
                             ,flblcrft
                             ,dtblqini
                             ,dtblqfim
                             ,NVL(rw_crapblj.vlbloque,0) - vr_vldesblo -- ww_vldesblo --  vlbloque
                             ,cdopdblq
                             ,cdopddes
                             ,dsjuizem
                             ,dsresord
                             ,dtenvres
                             ,nroficio
                             ,nrproces
                             ,dsinfadc
                             ,vlresblq
                             ,GENE0002.fn_busca_time hrblqini
                         FROM crapblj
                        WHERE rowid = rw_crapblj.dsdrowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir CRAPBLJ: '||SQLERRM;
            RAISE vr_exp_erro;
        END;

      END IF;

      IF ww_vldesblo > 0 THEN
      -- Atualizar o registro de bloqueio
      BEGIN
        UPDATE crapblj blj
           SET blj.cdopddes = pr_cdoperad  /* operador desbloqueio    */
             , blj.dtblqfim = pr_dtmvtolt  /* data desbloqueio        */
             , blj.nrofides = pr_nrofides  /* nro oficio desbloqueio  */
             , blj.dtenvdes = pr_dtenvdes  /*dt envio resp desbloqueio*/
             , blj.dsinfdes = pr_dsinfdes  /*inf adicional desbloqueio*/
             , blj.fldestrf = vr_fldestrf  /*desbloqueio para transf. */
         WHERE rowid = rw_crapblj.dsdrowid;
      
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atulizar CRAPBLJ: '||SQLERRM;
          RAISE vr_exp_erro;
      END;
      
      -- Verificar se deve cria o lançamento
      IF rw_crapblj.cdmodali = 1 AND rw_crapblj.vlbloque > 0 THEN
        
        -- Buscar o lote para o lançamento
        OPEN  cr_craplot(pr_cdcooper
                        ,pr_dtmvtolt
                        ,6880);
        FETCH cr_craplot INTO rw_craplot;
          
        -- Se não encontrar o registro do lote
        IF cr_craplot%NOTFOUND THEN
          -- Cria o lote
          BEGIN
            INSERT INTO craplot(cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,tplotmov
                               ,nrseqdig)
                         VALUES(pr_cdcooper
                               ,pr_dtmvtolt
                               ,1           
                               ,100          
                               ,6880
                               ,1
                               ,0) 
                       RETURNING ROWID INTO rw_craplot.dsdrowid;
                         
            -- Atualizar o registro do lote        
            rw_craplot.cdcooper := pr_cdcooper;
            rw_craplot.dtmvtolt := pr_dtmvtolt;
            rw_craplot.cdagenci := 1;
            rw_craplot.cdbccxlt := 100;        
            rw_craplot.nrdolote := 6880;
            rw_craplot.tplotmov := 1;               
            rw_craplot.nrseqdig := 0;
               
          EXCEPTION 
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir Lote: '||SQLERRM;
              RAISE vr_exp_erro;
          END;
        END IF;
          
        -- Fechar o cursor
        CLOSE cr_craplot;

        -- Montar o número do documento com base no NRSEQDIG
        vr_nrdocmto := rw_craplot.nrseqdig + 1;
        -------------             
        LOOP
          -- Buscar por lançamento pelo número do documento
          OPEN  cr_craplcm(rw_crapblj.nrdconta
                          ,vr_nrdocmto);
          FETCH cr_craplcm INTO vr_nrdregis;
            
          -- Se encontrou registro
          IF cr_craplcm%NOTFOUND THEN 
            -- Fechar o cursor
            CLOSE cr_craplcm;
            -- Encerra o LOOP
            EXIT;              
          END IF;
            
          -- Fechar o cursor
          CLOSE cr_craplcm;
            
          -- Ajusta o número do documento para reconsultar
          vr_nrdocmto := vr_nrdocmto + 100000;
        END LOOP;
        -------------
        -- Inserir registro na CRAPLCM 
        BEGIN
            -- Demetrius
--            UPDATE craplcm lcm
--               SET lcm.vllanmto = lcm.vllanmto + ww_vldesblo
--             WHERE lcm.cdcooper = pr_cdcooper
--               AND lcm.dtmvtolt = pr_dtmvtolt
--               AND lcm.cdagenci = rw_craplot.cdagenci
--               AND lcm.cdbccxlt = rw_craplot.cdbccxlt
--               AND lcm.nrdolote = rw_craplot.nrdolote
--               AND lcm.nrdctabb = rw_crapblj.nrdconta
--               AND lcm.nrdocmto = rw_craplot.nrseqdig; --vr_nrdocmto;
--
--            IF sql%rowcount = 0  THEN
           IF NOT vr_inserlcm THEN
              vr_inserlcm := TRUE;
          INSERT INTO craplcm(cdcooper
                             ,dtmvtolt
                             ,dtrefere
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,nrdconta
                             ,nrdctabb
                             ,nrdctitg
                             ,nrdocmto
                             ,cdhistor
                             ,vllanmto
                             ,nrseqdig
                             ,cdpesqbb)
                       VALUES(pr_cdcooper                       -- cdcooper
                             ,pr_dtmvtolt                       -- dtmvtolt
                             ,pr_dtmvtolt                       -- dtrefere
                             ,rw_craplot.cdagenci               -- cdagenci
                             ,rw_craplot.cdbccxlt               -- cdbccxlt
                             ,rw_craplot.nrdolote               -- nrdolote
                             ,rw_crapblj.nrdconta               -- nrdconta
                             ,rw_crapblj.nrdconta               -- nrdctabb
                             ,rw_crapblj.nrdctitg               -- nrdctitg
                             ,vr_nrdocmto                       -- nrdocmto
                             ,DECODE(rw_crapblj.inpessoa, 1, 1404, 1405) -- cdhistor => 1404 - PF / 1405 - PJ
                                 ,pr_vldesblo  --ww_vldesblo -- NVL(rw_crapblj.vlbloque,0)        -- vllanmto
                             ,rw_craplot.nrseqdig + 1           -- nrseqdig
                             ,'BLOQJUD');                       -- cdpesqbb
--            END IF;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir Lancamento: '||SQLERRM;
            RAISE vr_exp_erro;
        END;
          
        -- Atualizar o registro da CRAPLOT
        BEGIN
          UPDATE craplot 
             SET qtcompln = NVL(qtcompln,0) + 1
               , qtinfoln = NVL(qtinfoln,0) + 1
               , nrseqdig = NVL(nrseqdig,0) + 1   
                 , vlinfodb = NVL(vlinfodb,0) + ww_vldesblo --NVL(rw_crapblj.vlbloque,0)
                 , vlcompdb = NVL(vlcompdb,0) + ww_vldesblo --NVL(rw_crapblj.vlbloque,0)
           WHERE ROWID = rw_craplot.dsdrowid;
        EXCEPTION           
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar Lote: '||SQLERRM;
            RAISE vr_exp_erro;
        END;
          
        -- Atualizar o registro de saldo
        BEGIN
          UPDATE crapsld 
               SET vlblqjud = NVL(vlblqjud,0) - ww_vldesblo --NVL(rw_crapblj.vlbloque,0)
           WHERE cdcooper = pr_cdcooper     
             AND nrdconta = rw_crapblj.nrdconta;

          -- Se nenhuma linha foi atualizada
          IF SQL%ROWCOUNT = 0 THEN
            vr_cdcritic := 10;
            vr_dscritic := NULL;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar saldo cooperado: '||SQLERRM;
        END;
          
        -- Se ocorreu algum erro no update do saldo
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exp_erro;
        END IF;
        
      END IF; -- rw_crapblj.cdmodali = 1 AND rw_crapblj.vlbloque > 0
      
      -- Verifica os Lancamentos Futuros - quando for o último registros da modalidade
      IF rw_crapblj.qtdreg_ag = rw_crapblj.nrseqreg_ag THEN     
        -- Se contem a situacao do bloqueio para creditos futuros (SIM/NAO).
        IF rw_crapblj.flblcrft = 1 THEN
          BEGIN
            UPDATE craplau  lau
               SET lau.insitlau = 3
                 , lau.dtdebito = pr_dtmvtolt
             WHERE lau.cdcooper = pr_cdcooper
               AND lau.dtmvtolt = rw_crapblj.dtblqini 
               AND lau.cdagenci = 1
               AND lau.cdbccxlt = 100
               AND lau.nrdolote = 6870
               AND lau.dsorigem = 'BLOQJUD'
               AND lau.cdseqtel = pr_nroficio;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar CRAPLAU: '||SQLERRM;
              RAISE vr_exp_erro;
          END;
          
        END IF; -- rw_crapblj.flblcrft = 1
      END IF; -- rw_crapblj.qtdreg_ag = rw_crapblj.nrseqreg_ag
        vr_vldesblo := vr_vldesblo - ww_vldesblo; --rw_crapblj.vlbloque;
        IF vr_vldesblo <= 0 THEN
          EXIT;
        END IF;
      END IF; -- vr_vldesblo 
    END LOOP; -- cr_crapblj
    
  EXCEPTION
    WHEN vr_exp_erro THEN
      -- Gerar registro de erro      
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 0
                           ,pr_nrdcaixa => 1
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      pr_tab_erro(1).cdcritic := 0;
      pr_tab_erro(1).dscritic := 'Erro na PC_EFETUA_DESBLOQUEIO_JUD: '||SQLERRM;
  END pc_efetua_desbloqueio_jud;
  
  
END BLQJ0001;
/
