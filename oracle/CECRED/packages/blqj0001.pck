CREATE OR REPLACE PACKAGE CECRED.BLQJ0001 AS

  /*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0155.p
    Autor   : Renato Darosci
    Data    : Outubro/2016                Ultima Atualizacao: 26/10/2016.
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela BLQJUD
                 
    Alteracoes: 26/10/2016 - Convers�o PROGRESS para ORACLE (Renato Darosci).

  .............................................................................*/
  
  -- Registro de dados do cooperado
  TYPE typ_reg_cooperado IS RECORD (cdcooper    crapass.cdcooper%TYPE
                                   ,nrdconta    crapass.nrdconta%TYPE
                                   ,nrcpfcgc    crapass.nrcpfcgc%TYPE
                                   ,vlsldcap    NUMBER
                                   ,vlsldapl    NUMBER
                                   ,vlstotal    NUMBER
                                   ,vlsldppr    NUMBER);
                                  
  -- Tabela de mem�ria para gravar os dados do cooperado
  TYPE typ_tab_cooperado IS TABLE OF typ_reg_cooperado INDEX BY BINARY_INTEGER;
  
  
  -- Chamar a busca-contas-cooperado por mensageria
  PROCEDURE pc_busca_contas_cooperado_web(pr_cdcooper  IN crapcop.cdcooper%TYPE     
                                         ,pr_cdagenci  IN VARCHAR2                  
                                         ,pr_nrdcaixa  IN VARCHAR2                  
                                         ,pr_cdoperad  IN VARCHAR2                  
                                         ,pr_dtmvtolt  IN VARCHAR2                  
                                         ,pr_dtmvtopr  IN VARCHAR2                  
                                         ,pr_dtmvtoan  IN VARCHAR2                  
                                         ,pr_dtiniper  IN VARCHAR2                  
                                         ,pr_dtfimper  IN VARCHAR2                  
                                         ,pr_nmdatela  IN VARCHAR2                  
                                         ,pr_idorigem  IN NUMBER                    
                                         ,pr_idseqttl  IN NUMBER                    
                                         ,pr_inproces  IN NUMBER                    
                                         ,pr_cooperad  IN NUMBER                    
                                         ,pr_xmllog    IN VARCHAR2                --> XML com informa��es de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER             --> C�digo da cr�tica
                                         ,pr_dscritic OUT VARCHAR2                --> Descri��o da cr�tica
                                         ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);              --> Erros do processo 
  
  -- Buscar contas cooperado
  PROCEDURE pc_busca_contas_cooperado(pr_cdcooper IN crapcop.cdcooper%TYPE 
                                     ,pr_cdagenci IN VARCHAR2
                                     ,pr_nrdcaixa IN VARCHAR2               
                                     ,pr_cdoperad IN VARCHAR2
                                     ,pr_dtmvtolt IN DATE
                                     ,pr_dtmvtopr IN DATE
                                     ,pr_dtmvtoan IN DATE
                                     ,pr_dtiniper IN DATE
                                     ,pr_dtfimper IN DATE
                                     ,pr_nmdatela IN VARCHAR2
                                     ,pr_idorigem IN NUMBER    
                                     ,pr_idseqttl IN NUMBER    
                                     ,pr_inproces IN NUMBER    
                                     ,pr_cooperad IN NUMBER
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
                                      ,pr_dtmvtolt  IN VARCHAR2      
                                      ,pr_cdoperad  IN VARCHAR2      
                                      ,pr_dsinfadc  IN VARCHAR2                  
                                      ,pr_xmllog    IN VARCHAR2                --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER             --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2                --> Descri��o da cr�tica
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
                                  ,pr_dtmvtolt    IN DATE      
                                  ,pr_cdoperad    IN VARCHAR2      
                                  ,pr_dsinfadc    IN VARCHAR2         
                                  ,pr_tab_erro   IN OUT GENE0001.typ_tab_erro);  --> Retorno de erro                          
  
  -- Chamar a efetua-desbloqueio-jud por mensageria
  PROCEDURE pc_efetua_desbloqueio_jud_web(pr_cdcooper  IN NUMBER
                                         ,pr_dtmvtolt  IN VARCHAR2
                                         ,pr_cdoperad  IN VARCHAR2
                                         ,pr_nroficio  IN VARCHAR2
                                         ,pr_nrctacon  IN VARCHAR2
                                         ,pr_nrofides  IN VARCHAR2
                                         ,pr_dtenvdes  IN VARCHAR2
                                         ,pr_dsinfdes  IN VARCHAR2
                                         ,pr_fldestrf  IN NUMBER  
                                         ,pr_xmllog    IN VARCHAR2             --> XML com informa��es de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                         ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                         ,pr_retxml    IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);           --> Erros do processo 
  
  -- Efetuar os desbloqueios judiciais
  PROCEDURE pc_efetua_desbloqueio_jud(pr_cdcooper IN NUMBER
                                     ,pr_dtmvtolt IN DATE
                                     ,pr_cdoperad IN VARCHAR2
                                     ,pr_nroficio IN VARCHAR2
                                     ,pr_nrctacon IN VARCHAR2
                                     ,pr_nrofides IN VARCHAR2
                                     ,pr_dtenvdes IN DATE
                                     ,pr_dsinfdes IN VARCHAR2
                                     ,pr_fldestrf IN BOOLEAN          
                                     ,pr_tab_erro IN OUT GENE0001.typ_tab_erro);
  
END BLQJ0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.BLQJ0001 AS

  /*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0155.p
    Autor   : Renato Darosci
    Data    : Outubro/2016                Ultima Atualizacao: 26/10/2016.
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela BLQJUD
                 
    Alteracoes: 26/10/2016 - Convers�o PROGRESS para ORACLE (Renato Darosci).

  .............................................................................*/
  
  -- Buscar o lote para lan�amentos
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
  PROCEDURE pc_busca_nrcpfcgc_cooperado(pr_cdcooper  IN crapass.cdcooper%TYPE
                                       ,pr_nrctadoc  IN NUMBER
                                       ,pr_nrcpfcgc OUT crapass.nrcpfcgc%TYPE
                                       ,pr_nmprimtl OUT crapass.nmprimtl%TYPE
                                       ,pr_dscritic OUT VARCHAR2) IS
  
    -- CURSORES 
    -- Buscar o cooperado pelo n�mero de documento
    CURSOR cr_nrcpfcgc IS
      SELECT ass.nrcpfcgc
           , ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrcpfcgc = pr_nrctadoc;
         
    -- Buscar o cooperado pelo n�mero da conta
    CURSOR cr_nrdconta IS
      SELECT ass.nrcpfcgc
           , ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrctadoc;
        
    -- VARI�VEIS
    vr_nrcpfcgc    crapass.nrcpfcgc%TYPE;
    vr_nmprimtl    crapass.nmprimtl%TYPE;
    
  BEGIN
  
    -- FAZ A BUSCA POR CPF/CNPJ
    OPEN  cr_nrcpfcgc;
    FETCH cr_nrcpfcgc INTO vr_nrcpfcgc
                         , vr_nmprimtl;
                         
    -- Se n�o encontrar o registro
    IF cr_nrcpfcgc%NOTFOUND THEN
      
      -- FAZ A BUSCA POR CONTA
      OPEN  cr_nrdconta;
      FETCH cr_nrdconta INTO vr_nrcpfcgc
                           , vr_nmprimtl;
                           
      -- Se n�o encontrar registro
      IF cr_nrdconta%NOTFOUND THEN
        -- Retorna a informa��o de cooperado n�o encontrado
        vr_nmprimtl :=  'COOPERADO NAO ENCONTRADO';
      END IF;
      
      -- Fechar o cursor
      CLOSE cr_nrdconta;
      
    END IF;
               
    -- Fechar o cursor
    CLOSE cr_nrcpfcgc;
    
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
  PROCEDURE pc_busca_contas_cooperado_web(pr_cdcooper  IN crapcop.cdcooper%TYPE   
                                         ,pr_cdagenci  IN VARCHAR2                
                                         ,pr_nrdcaixa  IN VARCHAR2                
                                         ,pr_cdoperad  IN VARCHAR2                
                                         ,pr_dtmvtolt  IN VARCHAR2                
                                         ,pr_dtmvtopr  IN VARCHAR2                
                                         ,pr_dtmvtoan  IN VARCHAR2                
                                         ,pr_dtiniper  IN VARCHAR2                
                                         ,pr_dtfimper  IN VARCHAR2                
                                         ,pr_nmdatela  IN VARCHAR2                
                                         ,pr_idorigem  IN NUMBER                  
                                         ,pr_idseqttl  IN NUMBER                  
                                         ,pr_inproces  IN NUMBER                  
                                         ,pr_cooperad  IN NUMBER                  
                                         ,pr_xmllog    IN VARCHAR2                --> XML com informa��es de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER             --> C�digo da cr�tica
                                         ,pr_dscritic OUT VARCHAR2                --> Descri��o da cr�tica
                                         ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS            --> Erros do processo 
                                   
    -- VARI�VEIS
    vr_tab_cooperado BLQJ0001.typ_tab_cooperado;
    vr_tab_erro      GENE0001.typ_tab_erro;
    vr_nmprimtl      VARCHAR2(200);
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(2000);
    
    -- Converte a data passada por parametro para tipo correto
    vr_dtmvtolt      DATE := TO_DATE(pr_dtmvtolt,'dd/mm/yyyy');
    vr_dtmvtopr      DATE := TO_DATE(pr_dtmvtopr,'dd/mm/yyyy');
    vr_dtmvtoan      DATE := TO_DATE(pr_dtmvtoan,'dd/mm/yyyy');
    vr_dtiniper      DATE := TO_DATE(pr_dtiniper,'dd/mm/yyyy');
    vr_dtfimper      DATE := TO_DATE(pr_dtfimper,'dd/mm/yyyy');
        
    
    -- Vari�veis para armazenar as informa��es em XML
    vr_des_xml         CLOB;
    -- Vari�vel para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    
    -- EXCEPTIONS
    vr_exc_saida     EXCEPTION;
    
    -- Escrever texto na vari�vel CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN 
    
    pr_des_erro := 'OK';
    
    gene0001.pc_informa_acesso(pr_module => 'BLQJ0001');
    
    -- Chamar a procedure
    BLQJ0001.pc_busca_contas_cooperado(pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_nrdcaixa => pr_nrdcaixa
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_dtmvtolt => vr_dtmvtolt
                                      ,pr_dtmvtopr => vr_dtmvtopr
                                      ,pr_dtmvtoan => vr_dtmvtoan
                                      ,pr_dtiniper => vr_dtiniper
                                      ,pr_dtfimper => vr_dtfimper
                                      ,pr_nmdatela => pr_nmdatela
                                      ,pr_idorigem => pr_idorigem
                                      ,pr_idseqttl => pr_idseqttl
                                      ,pr_inproces => pr_inproces
                                      ,pr_cooperad => pr_cooperad
                                      ,pr_nmprimtl => vr_nmprimtl
                                      ,pr_tab_cooperado => vr_tab_cooperado
                                      ,pr_tab_erro => vr_tab_erro);
   
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
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral PC_BUSCA_CONTAS_COOPERADO_WEB: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_contas_cooperado_web;        
  
  
  -- Buscar contas cooperado
  PROCEDURE pc_busca_contas_cooperado(pr_cdcooper IN crapcop.cdcooper%TYPE 
                                     ,pr_cdagenci IN VARCHAR2
                                     ,pr_nrdcaixa IN VARCHAR2               
                                     ,pr_cdoperad IN VARCHAR2
                                     ,pr_dtmvtolt IN DATE
                                     ,pr_dtmvtopr IN DATE
                                     ,pr_dtmvtoan IN DATE
                                     ,pr_dtiniper IN DATE
                                     ,pr_dtfimper IN DATE
                                     ,pr_nmdatela IN VARCHAR2
                                     ,pr_idorigem IN NUMBER    
                                     ,pr_idseqttl IN NUMBER    
                                     ,pr_inproces IN NUMBER    
                                     ,pr_cooperad IN NUMBER
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
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper 
         AND ass.nrcpfcgc = pr_nrcpfcgc
      UNION    -- Cl�usula UNION � excludente de repeti��es
      SELECT ttl.cdcooper
           , ttl.nrdconta
           , ttl.nrcpfcgc
        FROM crapttl  ttl
       WHERE ttl.cdcooper = pr_cdcooper 
         AND ttl.nrcpfcgc = pr_nrcpfcgc;
    
    -- Buscar dados espec�ficos da conta
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.cdcooper
           , ass.nrdconta
           , ass.inpessoa
           , ass.nrdctitg
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass  cr_crapass%ROWTYPE;
    
    -- Buscar dados dos titulares de conta
    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                     ,pr_nrdconta IN crapttl.nrdconta%TYPE
                     ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS
      SELECT ttl.idseqttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper 
         AND ttl.nrdconta = pr_nrdconta 
         AND ttl.idseqttl = pr_idseqttl;
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
    
    /* Buscar valor do saldo devedor dos empr�stimos ativos, contratados a partir de Outubro/2014 e
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
    
    -- VARI�VEIS
    --vr_dsorigem       VARCHAR2(20);
    --vr_dstransa       VARCHAR2(200);
    vr_cdcritic       NUMBER;
    vr_dscritic       VARCHAR2(2000);
    vr_nrindice       NUMBER;
    vr_vlsldapl       NUMBER;
    vr_vlsldpou       NUMBER;
    vr_clobxmlc       CLOB;
    
    vr_nrcpfcgc       crapass.nrcpfcgc%TYPE;
    vr_nmprimtl       crapass.nmprimtl%TYPE;
        
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
    
    -- Inicializa��o de vari�veis
    --vr_dsorigem := 'AYLLOS'; 
    --vr_dstransa := 'Consultar dados para Bloqueio Judicial.';
    
    -- Buscar dados do cooperado por documento ou conta
    pc_busca_nrcpfcgc_cooperado(pr_cdcooper => pr_cdcooper
                               ,pr_nrctadoc => pr_cooperad
                               ,pr_nrcpfcgc => vr_nrcpfcgc
                               ,pr_nmprimtl => vr_nmprimtl
                               ,pr_dscritic => vr_dscritic);
                              
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
    -- Se a primeira posi��o do campo dstextab for diferente de zero
    vr_inusatab := SUBSTR(vr_dstextab,1,1) != '0';
    
    -- Buscar todas as contas relacionadas ao CPF/CNPJ - Tabelas CRAPASS e CRAPTTL
    FOR rw_crapass_ttl IN cr_crapass_ttl(pr_cdcooper
                                        ,vr_nrcpfcgc) LOOP
      -- Define o indice para tabela de mem�ria dos cooperados  
      vr_nrindice := pr_tab_cooperado.COUNT() + 1;
      
      -- Adicionar o registro na tabela de mem�ria
      pr_tab_cooperado(vr_nrindice).cdcooper := rw_crapass_ttl.cdcooper;
      pr_tab_cooperado(vr_nrindice).nrdconta := rw_crapass_ttl.nrdconta;
      pr_tab_cooperado(vr_nrindice).nrcpfcgc := rw_crapass_ttl.nrcpfcgc;
      
       -- Gerar registro de erro      
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 1
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      
    END LOOP;
      
    -- Se inseriu dados na tabela de mem�ria de cooperados
    IF pr_tab_cooperado.COUNT() > 0 THEN
      
      -- Percorrer todos os dados inseridos na tabela de mem�ria
      FOR vr_ind_cooperado IN pr_tab_cooperado.FIRST..pr_tab_cooperado.LAST LOOP
        
        -- Inicializa as vari�veis
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
      
        -- Se for pessoa f�sica
        IF rw_crapass.inpessoa = 1 THEN
          -- Deve buscar os dados da CRAPTTL
          OPEN cr_crapttl(pr_tab_cooperado(vr_ind_cooperado).cdcooper
                         ,pr_tab_cooperado(vr_ind_cooperado).nrdconta
                         ,pr_idseqttl);
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
                                        ,pr_dtmvtolt => pr_dtmvtolt                     --> Data do movimento
                                        ,pr_dtmvtopr => pr_dtmvtopr                     --> Proxima data do movimento
                                        ,pr_dtmvtoan => pr_dtmvtoan                     --> Data anterior do movimento
                                        ,pr_dtiniper => pr_dtiniper                     --> Data inicial do periodo
                                        ,pr_dtfimper => pr_dtfimper                     --> data final do periodo
                                        ,pr_nmdatela => pr_nmdatela                     --> Nome da tela
                                        ,pr_idorigem => pr_idorigem                     --> Identificado de oriem
                                        ,pr_nrdconta => rw_crapass.nrdconta             --> Numero da conta
                                        ,pr_idseqttl => pr_idseqttl                     --> Sequencial do titular
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
            vr_dscritic := 'Erro na execu��o da PC_CARREGA_DADOS_ATENDA';
          END IF;
          RAISE vr_exp_erro;      
        END IF;
      
        -- Busca a listagem de aplicacoes 
        APLI0005.pc_lista_aplicacoes_car(pr_cdcooper => pr_cdcooper         -- C�digo da Cooperativa 
                                        ,pr_cdoperad => pr_cdoperad         -- C�digo do Operador
                                        ,pr_nmdatela => pr_nmdatela         -- Nome da Tela
                                        ,pr_idorigem => 1                   -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA )
                                        ,pr_nrdcaixa => 1                   -- Numero do Caixa
                                        ,pr_nrdconta => rw_crapass.nrdconta -- N�mero da Conta
                                        ,pr_idseqttl => 1                   -- Titular da Conta 
                                        ,pr_cdagenci => 1                   -- Codigo da Agencia
                                        ,pr_cdprogra => pr_nmdatela         -- Codigo do Programa
                                        ,pr_nraplica => 0                   -- N�mero da Aplica�ao 
                                        ,pr_cdprodut => 0                   -- C�digo do Produto
                                        ,pr_dtmvtolt => pr_dtmvtolt         -- Data de Movimento
                                        ,pr_idconsul => 6                   -- Identificador de Consulta
                                        ,pr_idgerlog => 1                   -- Identificador de Log (0 � Nao / 1 � Sim)
                                        ,pr_clobxmlc => vr_clobxmlc         -- XML com informa�oes 
                                        ,pr_cdcritic => vr_cdcritic         -- C�digo da cr�tica 
                                        ,pr_dscritic => vr_dscritic);       -- Descri�ao da cr�tica 
     
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
        
        -- Limpar toda a tabela de mem�ria
        vr_tbsaldo_rdca.DELETE();
        
        -- Verifica se o Clob foi retornado com valor
        IF vr_clobxmlc = empty_clob() THEN        
          /*********** BLOCO PARA TRATAR O XML ***********/
          DECLARE
            -- Vari�veis para tratamento do XML
            vr_node_list       xmldom.DOMNodeList;
            vr_parser          xmlparser.Parser;
            vr_doc             xmldom.DOMDocument;
            vr_lenght          NUMBER;
            vr_node_name       VARCHAR2(100);
            vr_item_node       xmldom.DOMNode;
            
            vr_insdrdca        NUMBER;
            
          BEGIN
            -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
            vr_parser := xmlparser.newParser;
            xmlparser.parseClob(vr_parser, vr_clobxmlc);
            
            -- Limpar mem�ria alocado ao CLOB, j� que o mesmo j� foi enviado ao XMLType
            DBMS_LOB.close(vr_clobxmlc);
            DBMS_LOB.freetemporary(vr_clobxmlc);
            
            -- Capturar o parser XML
            vr_doc := xmlparser.getDocument(vr_parser);
            xmlparser.freeParser(vr_parser);

            -- Faz o get de toda a lista de elementos
            vr_node_list := xmldom.getElementsByTagName(vr_doc, '*');
            vr_lenght := xmldom.getLength(vr_node_list);
            
            -- Percorrer todos os Nodos do XML
            FOR i IN 0..vr_lenght-1 LOOP
              -- Pega o item
              vr_item_node := xmldom.item(vr_node_list, i);

              -- Captura o nome do nodo
              vr_node_name := xmldom.getNodeName(vr_item_node);

              -- Verifica qual nodo esta sendo lido
              IF LOWER(vr_node_name) = 'aplicacao' THEN
                -- Para nodo APLICACAO, deve atualizar o indice
                vr_insdrdca := vr_tbsaldo_rdca.COUNT() + 1;
              ELSIF LOWER(vr_node_name) = 'sldresga' THEN
                -- Atualizar o valor na tabela de mem�ria
                vr_tbsaldo_rdca(vr_insdrdca).sldresga := TO_NUMBER(xmldom.getNodeValue(vr_item_node));
              ELSIF LOWER(vr_node_name) = 'dssitapl' THEN
                -- Atualizar o valor na tabela de mem�ria
                vr_tbsaldo_rdca(vr_insdrdca).dssitapl := xmldom.getNodeValue(vr_item_node);
              END IF;

            END LOOP;
            
            -- Eliminar documento DOM
            xmldom.freeDocument(vr_doc);
            
          END;
          /******** FIM - BLOCO PARA TRATAR O XML ********/
        END IF;
        
        -- Percorrer cada um dos registro encontrados e retornados
        IF vr_tbsaldo_rdca.COUNT() > 0 THEN
          FOR vr_ind_saldo IN vr_tbsaldo_rdca.FIRST()..vr_tbsaldo_rdca.LAST() LOOP
            -- Se a descri��o for diferente de bloqueada
            IF vr_tbsaldo_rdca(vr_ind_saldo).dssitapl <> 'BLOQUEADA' THEN
              -- Sumariza o saldo da aplica��o
              vr_vlsldapl := NVL(vr_vlsldapl,0) + NVL(vr_tbsaldo_rdca(vr_ind_saldo).sldresga,0);
            END IF;
          END LOOP;
        END IF;
        
        -- Limpar toda a tabela de mem�ria
        vr_tbdados_rpp.DELETE();
        
        -- Consultar dados da Poupan�a
        APLI0001.pc_consulta_poupanca(pr_cdcooper      => pr_cdcooper
                                     ,pr_cdagenci      => pr_cdagenci
                                     ,pr_nrdcaixa      => pr_nrdcaixa
                                     ,pr_cdoperad      => pr_cdoperad
                                     ,pr_idorigem      => 1 -- pr_nmdatela
                                     ,pr_nrdconta      => rw_crapass.nrdconta
                                     ,pr_idseqttl      => pr_idseqttl
                                     ,pr_nrctrrpp      => 0
                                     ,pr_dtmvtolt      => pr_dtmvtolt
                                     ,pr_dtmvtopr      => pr_dtmvtopr
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
            vr_dscritic := 'Erro na execu��o da PC_CARREGA_DADOS_ATENDA';
          END IF;
          RAISE vr_exp_erro;      
        END IF;
        
        -- Percorrer cada um dos registro encontrados e retornados
        IF vr_tbdados_rpp.COUNT() > 0 THEN
          FOR vr_ind_rpp IN vr_tbdados_rpp.FIRST()..vr_tbdados_rpp.LAST() LOOP
            -- Se O indicador de bloqueio for diferente de SIM
            IF UPPER(vr_tbdados_rpp(vr_ind_rpp).dsblqrpp) <> 'SIM' THEN
              -- Sumariza o saldo da aplica��o
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
        
        
        /* Buscar valor do saldo devedor dos empr�stimos ativos, contratados a partir de Outubro/2014 e
           modalidades de linha de credito (emprestimo/financiamento) */
        FOR rw_creprlcr IN cr_creprlcr(rw_crapass.cdcooper
                                      ,rw_crapass.nrdconta) LOOP
          -- Inicializa a vari�vel          
          vr_vltotemp := 0;
          
          -- Buscar o saldo devedor do empr�stimo
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
              vr_dscritic := 'Erro na execu��o da PC_CARREGA_DADOS_ATENDA';
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
                         NVL(vr_tb_vlr_conta(vr_tb_vlr_conta.FIRST).vlsldcap,0) - vr_vlsdeved;
                
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
                                      ,pr_dtmvtolt  IN VARCHAR2      
                                      ,pr_cdoperad  IN VARCHAR2      
                                      ,pr_dsinfadc  IN VARCHAR2                  
                                      ,pr_xmllog    IN VARCHAR2                --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER             --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2                --> Descri��o da cr�tica
                                      ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS            --> Erros do processo 
                                   
    -- VARI�VEIS
    vr_tab_erro      GENE0001.typ_tab_erro;
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(2000);
    vr_flblcrft      BOOLEAN;
    vr_dtenvres      DATE := to_date(pr_dtenvres,'DD/MM/YYYY');
    vr_dtmvtolt      DATE := to_date(pr_dtmvtolt,'DD/MM/YYYY');
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
                                   --,pr_vlresblq => pr_vlresblq
                                   ,pr_nroficio => pr_nroficio
                                   ,pr_nrproces => pr_nrproces 
                                   ,pr_dsjuizem => pr_dsjuizem 
                                   ,pr_dsresord => pr_dsresord 
                                   ,pr_flblcrft => vr_flblcrft    
                                   ,pr_dtenvres => vr_dtenvres 
                                   ,pr_vlrsaldo => vr_vlrsaldo   
                                   ,pr_dtmvtolt => vr_dtmvtolt 
                                   ,pr_cdoperad => pr_cdoperad    
                                   ,pr_dsinfadc => pr_dsinfadc 
                                   ,pr_tab_erro => vr_tab_erro);
   
    -- Se houve o retorno de erro
    IF vr_tab_erro.count() > 0 THEN
      vr_dscritic := 'Nao foi possivel consultar os registros.';
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
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral PC_INCLUI_BLOQUEIO_JUD_WEB: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
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
                                  --,pr_vlresblq    IN VARCHAR2  /*LISTAS*/
                                  ,pr_nroficio    IN VARCHAR2  
                                  ,pr_nrproces    IN VARCHAR2  
                                  ,pr_dsjuizem    IN VARCHAR2  
                                  ,pr_dsresord    IN VARCHAR2  
                                  ,pr_flblcrft    IN BOOLEAN      
                                  ,pr_dtenvres    IN DATE      
                                  ,pr_vlrsaldo    IN NUMBER      
                                  ,pr_dtmvtolt    IN DATE      
                                  ,pr_cdoperad    IN VARCHAR2      
                                  ,pr_dsinfadc    IN VARCHAR2         
                                  ,pr_tab_erro   IN OUT GENE0001.typ_tab_erro) IS  --> Retorno de erro   
    
    -- CURSORES
    -- Buscar dados do cadastro de bloqueio
    CURSOR cr_crapblj(pr_cdcooper  crapblj.cdcooper%TYPE
                     ,pr_nrdconta  crapblj.nrdconta%TYPE
                     ,pr_nroficio  crapblj.nroficio%TYPE) IS
      SELECT 1
        FROM crapblj blj
       WHERE blj.cdcooper = pr_cdcooper
         AND blj.nrdconta = pr_nrdconta
         AND blj.nroficio = pr_nroficio;
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
    
    -- Buscar pelo lan�amento
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
    
    -- Buscar lan�amento autom�tico
    CURSOR cr_craplau(pr_nrdconta  craplau.nrdconta%TYPE
                     ,pr_nrdocmto  craplau.nrdocmto%TYPE) IS
      SELECT 1
        FROM craplau lau
       WHERE lau.cdcooper = pr_cdcooper     
         AND lau.dtmvtolt = pr_dtmvtolt     
         AND lau.cdagenci = 1
         AND lau.cdbccxlt = 100
         AND lau.nrdolote = 6870
         AND lau.nrdctabb = pr_nrdconta
         AND lau.nrdocmto = pr_nrdocmto;
    
    -- VARI�VEIS
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
    
    -- Inicializa as vari�veis                                        
    vr_fldepvis := FALSE;
    vr_flgbloqu := TRUE;    
    vr_flgtrans := FALSE;
    
    -- Se a primeira entrada do cdtipmov for igual a 2
    IF vr_tbtipmov.EXISTS(1) THEN
      IF TO_NUMBER(vr_tbtipmov(1)) = 2 THEN
        vr_flgbloqu := FALSE;
      END IF;
    END IF;

    -- Se encontrar registros
    IF vr_tbcontas.COUNT() > 0 THEN
      
      -- Se o flag estiver como True
      IF pr_flblcrft THEN
        vr_flblcrft := 1;
      ELSE 
        vr_flblcrft := 0;
      END IF;
      
      -- Percorrer os registros para validar se algum dos mesmos j� existe
      FOR vr_indice IN vr_tbcontas.FIRST..vr_tbcontas.LAST LOOP

        -- Buscar registro de cadastro de bloqueio
        OPEN  cr_crapblj(pr_cdcooper
                        ,vr_tbcontas(vr_indice)
                        ,pr_nroficio);
        FETCH cr_crapblj INTO rw_crapblj;
        
        -- Se encontrar registro
        IF cr_crapblj%FOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapblj;
          
          -- Definir a cr�tica
          vr_cdcritic := 0;
          vr_dscritic := 'Ja existe este Nr. Oficio para esta Conta.';
          
          -- Exception
          RAISE vr_exp_erro;
        END IF;
        
        -- Fechar o cursor
        CLOSE cr_crapblj;
        
      END LOOP;   
      
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
            vr_dtblqfim := pr_dtmvtolt;
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
                             ,vlresblq)
                       VALUES(pr_cdcooper                       -- cdcooper
                             ,rw_crapass.nrdconta               -- nrdconta
                             ,rw_crapass.nrcpfcgc               -- nrcpfcgc
                             ,TO_NUMBER(vr_tbmodali(vr_indice)) -- cdmodali
                             ,TO_NUMBER(vr_tbtipmov(vr_indice)) -- cdtipmov
                             ,vr_flblcrft                       -- flblcrft
                             ,pr_dtmvtolt                       -- dtblqini
                             ,vr_dtblqfim                       -- dtblqfim
                             ,TO_NUMBER(vr_tbbloque(vr_indice)) -- vlbloque
                             ,pr_cdoperad                       -- cdopdblq /* Operador Bloqueio    */
                             ,NULL                              -- cdopddes /* Operador Desbloqueio */
                             ,pr_dsjuizem                       -- dsjuizem
                             ,pr_dsresord                       -- dsresord
                             ,pr_dtenvres                       -- dtenvres
                             ,pr_nroficio                       -- nroficio
                             ,pr_nrproces                       -- nrproces
                             ,pr_dsinfadc                       -- dsinfadc
                             ,vr_vlresblq);                     -- vlresblq
                                
        EXCEPTION               
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir CRAPBLJ: '||SQLERRM;
            RAISE vr_exp_erro;
        END;
        
        -- Setar a variavel de transa��o
        vr_flgtrans := TRUE;
        
        -- Se modalidade 1 e houver valor bloqueado deve criar o lan�amento
        IF TO_NUMBER(vr_tbmodali(vr_indice)) = 1 AND TO_NUMBER(vr_tbbloque(vr_indice)) > 0 THEN
          -- Buscar o lote para o lan�amento
          OPEN  cr_craplot(pr_cdcooper
                          ,pr_dtmvtolt
                          ,6880);
          FETCH cr_craplot INTO rw_craplot;
          
          -- Se n�o encontrar o registro do lote
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

          -- Montar o n�mero do documento com base no NRSEQDIG
          vr_nrdocmto := rw_craplot.nrseqdig + 1;
          -------------             
          LOOP
            -- Buscar por lan�amento pelo n�mero do documento
            OPEN  cr_craplcm(rw_crapass.nrdconta
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
            
            -- Ajusta o n�mero do documento para reconsultar
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
                               ,pr_dtmvtolt                       -- dtmvtolt
                               ,pr_dtmvtolt                       -- dtrefere
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
                               ,vlresblq)
                         VALUES(pr_cdcooper                       -- cdcooper
                               ,rw_crapass.nrdconta               -- nrdconta
                               ,rw_crapass.nrcpfcgc               -- nrcpfcgc
                               ,1  /* Dep. a Vista */             -- cdmodali
                               ,TO_NUMBER(vr_tbtipmov(vr_indice)) -- cdtipmov
                               ,vr_flblcrft                       -- flblcrft
                               ,pr_dtmvtolt                       -- dtblqini
                               ,NULL                              -- dtblqfim
                               ,0                                 -- vlbloque
                               ,pr_cdoperad                       -- cdopdblq /* Operador Bloqueio    */
                               ,NULL                              -- cdopddes /* Operador Desbloqueio */
                               ,pr_dsjuizem                       -- dsjuizem
                               ,pr_dsresord                       -- dsresord
                               ,pr_dtenvres                       -- dtenvres
                               ,pr_nroficio                       -- nroficio
                               ,pr_nrproces                       -- nrproces
                               ,pr_dsinfadc                       -- dsinfadc
                               ,pr_vlrsaldo);                     -- vlresblq
                                  
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
        pc_busca_nrcpfcgc_cooperado(pr_cdcooper => pr_cdcooper
                                   ,pr_nrctadoc => vr_tbcontas(1)
                                   ,pr_nrcpfcgc => vr_nrcpfcgc
                                   ,pr_nmprimtl => vr_nmprimtl
                                   ,pr_dscritic => vr_dscritic);
        
        -- Se houve alguma critica na execu��o da rotina
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exp_erro;
        END IF;
        
        -- Buscar contas pelo CPF
        FOR rw_contcpf IN cr_contcpf(pr_cdcooper
                                    ,vr_nrcpfcgc) LOOP
                                            
          -- Buscar o lote para o lan�amento
          OPEN  cr_craplot(pr_cdcooper
                          ,pr_dtmvtolt
                          ,6870);
          FETCH cr_craplot INTO rw_craplot;
          
          -- Se n�o encontrar o registro do lote
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
                                 ,6870
                                 ,1
                                 ,0) 
                        RETURNING ROWID INTO rw_craplot.dsdrowid;
                         
               -- Atualizar o registro do lote        
               rw_craplot.cdcooper := pr_cdcooper;
               rw_craplot.dtmvtolt := pr_dtmvtolt;
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
          
          -- Montar o n�mero do documento com base no NRSEQDIG
          vr_nrdocmto := rw_craplot.nrseqdig + 1;
          -------------             
          LOOP
            -- Buscar por lan�amento pelo n�mero do documento
            OPEN  cr_craplau(rw_contcpf.nrdconta
                            ,vr_nrdocmto);
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
            
            -- Ajusta o n�mero do documento para reconsultar
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
                               ,pr_dtmvtolt                       -- dtmvtolt
                               ,pr_dtmvtolt                       -- dtmvtopg
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
          
          -- Setar a flag de transa��o
          vr_flgtrans := TRUE;      
        END LOOP;
      END IF;
    END IF;
        
    -- Se n�o efetuou transa��o
    IF NOT vr_flgtrans THEN
      -- Gerar a cr�tica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro na gravacao da LAUTOM!';
        
      -- Gera o erro e encerra a execu��o
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
  PROCEDURE pc_efetua_desbloqueio_jud_web(pr_cdcooper  IN NUMBER
                                         ,pr_dtmvtolt  IN VARCHAR2
                                         ,pr_cdoperad  IN VARCHAR2
                                         ,pr_nroficio  IN VARCHAR2
                                         ,pr_nrctacon  IN VARCHAR2
                                         ,pr_nrofides  IN VARCHAR2
                                         ,pr_dtenvdes  IN VARCHAR2
                                         ,pr_dsinfdes  IN VARCHAR2
                                         ,pr_fldestrf  IN NUMBER  
                                         ,pr_xmllog    IN VARCHAR2             --> XML com informa��es de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                         ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                         ,pr_retxml    IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo 
  
    -- VARI�VEIS
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
    BLQJ0001.pc_efetua_desbloqueio_jud(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => vr_dtmvtolt
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_nroficio => pr_nroficio
                                      ,pr_nrctacon => pr_nrctacon
                                      ,pr_nrofides => pr_nrofides
                                      ,pr_dtenvdes => vr_dtenvdes
                                      ,pr_dsinfdes => pr_dsinfdes
                                      ,pr_fldestrf => vr_fldestrf       
                                      ,pr_tab_erro => vr_tab_erro);
   
    -- Se houve o retorno de erro
    IF vr_tab_erro.count() > 0 THEN
      vr_dscritic := 'Nao foi possivel desbloquear os registros.';
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
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral PC_EFETUA_DESBLOQUEIO_JUD_WEB: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;  
  END pc_efetua_desbloqueio_jud_web;
  
  
  -- Efetuar os desbloqueios judiciais
  PROCEDURE pc_efetua_desbloqueio_jud(pr_cdcooper IN NUMBER
                                     ,pr_dtmvtolt IN DATE
                                     ,pr_cdoperad IN VARCHAR2
                                     ,pr_nroficio IN VARCHAR2
                                     ,pr_nrctacon IN VARCHAR2
                                     ,pr_nrofides IN VARCHAR2
                                     ,pr_dtenvdes IN DATE
                                     ,pr_dsinfdes IN VARCHAR2
                                     ,pr_fldestrf IN BOOLEAN          
                                     ,pr_tab_erro IN OUT GENE0001.typ_tab_erro) IS  --> Retorno de erro   
    
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
         AND blj.nrcpfcgc = pr_nrcpfcgc
      ORDER BY blj.cdcooper
             , blj.nroficio
             , blj.nrcpfcgc
             , blj.cdmodali;
    
    -- Buscar pelo lan�amento
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
        
    -- VARI�VEIS
    vr_nrdocmto      craplot.nrseqdig%TYPE;
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(1000);
    vr_nrcpfcgc      NUMBER;
    vr_nrdregis      NUMBER;
    vr_nmprimtl      VARCHAR2(100);
    vr_fldestrf      NUMBER;
    
    -- EXCEPTIONS
    vr_exp_erro       EXCEPTION;
    
  BEGIN
    
    -- Busca CPF/CNPJ do cooperado 
    pc_busca_nrcpfcgc_cooperado(pr_cdcooper => pr_cdcooper
                               ,pr_nrctadoc => pr_nrctacon
                               ,pr_nrcpfcgc => vr_nrcpfcgc
                               ,pr_nmprimtl => vr_nmprimtl
                               ,pr_dscritic => vr_dscritic);
        
    -- Se houve alguma critica na execu��o da rotina
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exp_erro;
    END IF;
    
    -- Ajustar o flag 
    IF pr_fldestrf THEN
      vr_fldestrf := 1; -- TRUE
    ELSE 
      vr_fldestrf := 0; -- FALSE
    END IF;
    
    -- Percorrer todos os bloqueios da conta
    FOR rw_crapblj IN cr_crapblj(vr_nrcpfcgc) LOOP
      
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
      
      -- Verificar se deve cria o lan�amento
      IF rw_crapblj.cdmodali = 1 AND rw_crapblj.vlbloque > 0 THEN
        
        -- Buscar o lote para o lan�amento
        OPEN  cr_craplot(pr_cdcooper
                        ,pr_dtmvtolt
                        ,6880);
        FETCH cr_craplot INTO rw_craplot;
          
        -- Se n�o encontrar o registro do lote
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

        -- Montar o n�mero do documento com base no NRSEQDIG
        vr_nrdocmto := rw_craplot.nrseqdig + 1;
        -------------             
        LOOP
          -- Buscar por lan�amento pelo n�mero do documento
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
            
          -- Ajusta o n�mero do documento para reconsultar
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
                             ,NVL(rw_crapblj.vlbloque,0)        -- vllanmto
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
               , vlinfodb = NVL(vlinfodb,0) + NVL(rw_crapblj.vlbloque,0)
               , vlcompdb = NVL(vlcompdb,0) + NVL(rw_crapblj.vlbloque,0)
           WHERE ROWID = rw_craplot.dsdrowid;
        EXCEPTION           
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar Lote: '||SQLERRM;
            RAISE vr_exp_erro;
        END;
          
        -- Atualizar o registro de saldo
        BEGIN
          UPDATE crapsld 
             SET vlblqjud = NVL(vlblqjud,0) - NVL(rw_crapblj.vlbloque,0)
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
      
      -- Verifica os Lancamentos Futuros - quando for o �ltimo registros da modalidade
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
