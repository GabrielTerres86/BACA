CREATE OR REPLACE PACKAGE CECRED.DSCC0002 AS

  /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa: DSCC0002                        
  --  Autor   : Lombardi
  --  Data    : Agosto/2016                     Ultima Atualizacao: 
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo desconto de cheques para o IB.
  --
  --  Alteracoes: 
  --  
  --------------------------------------------------------------------------------------------------------------*/
	
	-- Buscar lista de borderos de cheques
  PROCEDURE pc_lista_borderos_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                ,pr_dtmvtini  IN crapdat.dtmvtolt%TYPE --> Data inicial do periodo
                                ,pr_dtmvtfin  IN crapdat.dtmvtolt%TYPE --> Data final do periodo
                                ,pr_insitbdc  IN crapbdc.insitbdc%TYPE --> Indicador de situacao (1=Aguardando analise , 2=Em analise, 3=Liberado).
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
  -- Buscar lista de cheques do bordero
  PROCEDURE pc_lista_detalhe_bord_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrborder  IN crapcdb.nrborder%TYPE --> Nr do convenio
                                    ,pr_nriniseq  IN INTEGER               --> Paginação - Inicio de sequencia
                                    ,pr_nrregist  IN INTEGER               --> Paginação - Número de registros
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
  -- Buscar lista de cheques em custodia
  PROCEDURE pc_lista_cheques_cust_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nriniseq  IN INTEGER               --> Paginação - Inicio de sequencia
                                    ,pr_nrregist  IN INTEGER               --> Paginação - Número de registros
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
  -- Excluir bordero de descontos.
  PROCEDURE pc_excluir_bordero_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                 ,pr_nrborder  IN crapbdc.nrborder%TYPE --> Nr do convenio
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
  -- Imprimir bordero
  PROCEDURE pc_imprime_bordero_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                 ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                 ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                 ,pr_nrborder  IN crapbdc.nrborder%TYPE --> Numero do bordero
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
  -- Verifica emitentes para cadastrar
  PROCEDURE pc_verifica_emitentes_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_dsdocmc7  IN VARCHAR2              --> Lista CMC7
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
  -- Cadastrar custodia e emitentes
  PROCEDURE pc_desconto_cheque_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                                 ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Número do Titular
                                 ,pr_tab_cheques IN dscc0001.typ_tab_cheques --> Cheques para desconto
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
  -- Cadastrar desconto nas tabelas de transação pendente
  PROCEDURE pc_descto_chq_pend_ib(pr_cdcooper    IN crapcop.cdcooper%TYPE    --> Cooperativa
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE    --> Codigo do Indexador
                                 ,pr_idseqttl    IN crapttl.idseqttl%TYPE    --> Número do Titular
                                 ,pr_nrcpfope    IN crapopi.nrcpfope%TYPE    --> Cpf do Operador
                                 ,pr_nrcpfrep    IN crapopi.nrcpfope%TYPE    --> Cpf do Responsavel Legal
                                 ,pr_tab_cheques IN dscc0001.typ_tab_cheques --> Cheques para desconto
                                 ,pr_dscritic   OUT VARCHAR2                 --> Descrição da crítica
                                 ,pr_retxml     OUT CLOB);                   --> Arquivo de retorno do XML
  
  --Verifica se a conta exige assinatura multipla
  PROCEDURE pc_verifica_ass_multi_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Número do Titular
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE --> Cpf do Operador
                                    ,pr_dtlibera  IN VARCHAR2              --> Lista Data Boa
                                    ,pr_dtdcaptu  IN VARCHAR2              --> Lista Data Emissao
                                    ,pr_vlcheque  IN VARCHAR2              --> Lista Valor Cheque
                                    ,pr_dtcustod  IN VARCHAR2              --> Lista Data Custodia
                                    ,pr_intipchq  IN VARCHAR2              --> Lista Tipo Cheque
                                    ,pr_dsdocmc7  IN VARCHAR2              --> Lista CMC7
                                    ,pr_nrremret  IN VARCHAR2              --> Lista Remessa
                                    ,pr_aprvpend  IN INTEGER               --> Aprova Bordero Pendente (1 - Sim/0 - Não)
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
END DSCC0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.DSCC0002 AS

  /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa: DSCC0002                        
  --  Autor   : Lombardi
  --  Data    : Agosto/2016                     Ultima Atualizacao: 19/09/2017
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo desconto de cheques para o IB.
  --
  --  Alteracoes: 
  
      19/09/2017 - #753579 Alterado de vazio para nrdconta o parametro pr_dsiduser da rotina
                   DSCC0001.pc_gera_impressao_bordero em pc_imprime_bordero_ib pois a rotina
                   está removendo os relatórios "crrl519_bordero_*" da cooperativa (Carlos)
  
  --------------------------------------------------------------------------------------------------------------*/
	
  -- Buscar lista de borderos de cheques
  PROCEDURE pc_lista_borderos_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                ,pr_dtmvtini  IN crapdat.dtmvtolt%TYPE --> Data inicial do periodo
                                ,pr_dtmvtfin  IN crapdat.dtmvtolt%TYPE --> Data final do periodo
                                ,pr_insitbdc  IN crapbdc.insitbdc%TYPE --> Indicador de situacao (1=Aguardando analise , 2=Em analise, 3=Liberado).
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML


  BEGIN
    /* .............................................................................
    Programa: pc_lista_borderos_ib
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 07/11/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar lista de borderos de cheques.

    Alteracoes: 
    ............................................................................. */
    DECLARE
      --------- CURSOR ---------
      -- Busca Remessas de custódias
      CURSOR cr_crapbdc (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_dtmvtini IN crapdat.dtmvtolt%TYPE
                        ,pr_dtmvtfin IN crapdat.dtmvtolt%TYPE
                        ,pr_insitbdc IN crapbdc.insitbdc%TYPE) IS
        SELECT to_char(bdc.dtmvtolt,'DD/MM/RRRR') dtmvtolt
              ,bdc.nrborder
              ,(SELECT COUNT(1)
                  FROM crapcdb cdb
                 WHERE cdb.cdcooper = bdc.cdcooper
                   AND cdb.nrdconta = bdc.nrdconta
                   AND cdb.nrborder = bdc.nrborder) qtcheque
              ,(SELECT SUM(cdb.vlcheque)
                  FROM crapcdb cdb
                 WHERE cdb.cdcooper = bdc.cdcooper
                   AND cdb.nrdconta = bdc.nrdconta
                   AND cdb.nrborder = bdc.nrborder) vlcheque
              ,bdc.insitbdc
              ,to_char(bdc.dtlibbdc,'DD/MM/RRRR') dtlibbdc
              ,bdc.nrctrlim
              ,(CASE WHEN bdc.dtrejeit IS NOT NULL THEN 1 ELSE 0 END) rejeitad
          from crapbdc bdc
         where bdc.cdcooper = pr_cdcooper
           AND bdc.nrdconta = pr_nrdconta
           AND bdc.dtmvtolt between pr_dtmvtini AND pr_dtmvtfin
           AND (pr_insitbdc = 0
           OR  (pr_insitbdc = 3
           AND bdc.insitbdc IN (3,4))
           OR  bdc.insitbdc = pr_insitbdc);
      
      CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT inpessoa
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Busca parametros da TAB019
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE) IS
        SELECT to_char(substr(tab.dstextab,209,12),'999g999g990d00') vlmxassi
          FROM craptab tab
         WHERE tab.cdcooper = pr_cdcooper
           AND upper(tab.nmsistem) = 'CRED'
           AND upper(tab.tptabela) = 'USUARI'
           AND tab.cdempres = 11
           AND upper(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist = 0;
      rw_craptab cr_craptab%ROWTYPE;
      
      -- Busca contrato de limite de desconto
      CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                       ,pr_nrdconta IN craplim.nrdconta%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT lim.insitblq
          FROM craplim lim
         WHERE lim.cdcooper =  pr_cdcooper
           AND lim.nrdconta =  pr_nrdconta
           AND lim.dtfimvig >= pr_dtmvtolt
           AND lim.tpctrlim =  2
           AND lim.insitlim =  2;
      rw_craplim cr_craplim%ROWTYPE;
      
      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      
      --------- Variaveis ---------
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  crapcri.dscritic%TYPE;
      
      -- Variaveis auxiliares
      vr_xml_pgto_temp VARCHAR2(32726) := '';
      vr_retxml        XMLType;
      vr_cdacesso      VARCHAR2(12);
      vr_flglimit      INTEGER;
      vr_insitblq      INTEGER;
      
    BEGIN
      
      -- Monta documento XML
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
      
      -- Verifica se a conta esta cadastrada
      OPEN cr_crapass( pr_cdcooper => pr_cdcooper
                     , pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;
      
      -- Verifica Tipo de Pessoa
      IF rw_crapass.inpessoa = 1 THEN
        vr_cdacesso := 'LIMDESCONTPF';
      ELSE
        vr_cdacesso := 'LIMDESCONTPJ';
      END IF;
        -- Buscar dados de limites de descontos 
      -- conforma a tipo de pessoa
      OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                      ,pr_cdacesso => vr_cdacesso);
      FETCH cr_craptab INTO rw_craptab;    
      -- Se nao encontrar
      IF cr_craptab%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craptab;
        
        -- Montar mensagem de critica
        vr_cdcritic := 55;
        vr_dscritic := '';
        -- volta para o programa chamador
        RAISE vr_exc_erro;
        
      END IF;
      -- Fechar o cursor
      CLOSE cr_craptab;
      
      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      
      OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
      FETCH cr_craplim INTO rw_craplim;
      
      IF cr_craplim%FOUND THEN
        vr_flglimit := 1;
        vr_insitblq := rw_craplim.insitblq;
      ELSE
        vr_flglimit := 1;
      END IF;
      
      CLOSE cr_craplim;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<vlmxassi>' || rw_craptab.vlmxassi || '</vlmxassi>' || -- Valor máximo dispensa assinatura
                                                   '<flglimit>' ||     vr_flglimit     || '</flglimit>' || -- Flag Possui contrato de limite
                                                   '<insitblq>' ||     vr_insitblq     || '</insitblq>' || -- Bloqueio inclusao de novos borderos
                                                   '<inproces>' || rw_crapdat.inproces || '</inproces>');  -- Flag Processo Noturno
      
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<borderos>');
      
      -- Percorre remessas
      FOR rw_crapbdc IN cr_crapbdc (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dtmvtini => pr_dtmvtini
                                   ,pr_dtmvtfin => pr_dtmvtfin
                                   ,pr_insitbdc => pr_insitbdc) LOOP
        
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_pgto_temp
                               ,pr_texto_novo     => '<bordero>'
                                                  || '<dtmvtolt>'||rw_crapbdc.dtmvtolt||'</dtmvtolt>'
                                                  || '<nrborder>'||rw_crapbdc.nrborder||'</nrborder>'
                                                  || '<qtcheque>'||rw_crapbdc.qtcheque||'</qtcheque>'
                                                  || '<vlcheque>'||to_char(rw_crapbdc.vlcheque,'fm999g999g990d00')||'</vlcheque>'
                                                  || '<insitbdc>'||rw_crapbdc.insitbdc||'</insitbdc>'
                                                  || '<dtlibbdc>'||rw_crapbdc.dtlibbdc||'</dtlibbdc>'
                                                  || '<nrctrlim>'||rw_crapbdc.nrctrlim||'</nrctrlim>'
                                                  || '<rejeitad>'||rw_crapbdc.rejeitad||'</rejeitad>'
                                                  || '</bordero>');
        
      END LOOP;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '</borderos>'
                             ,pr_fecha_xml      => TRUE);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        IF vr_cdcritic > 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_lista_borderos_ib: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
  END pc_lista_borderos_ib;
  
  -- Buscar lista de cheques do bordero
  PROCEDURE pc_lista_detalhe_bord_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrborder  IN crapcdb.nrborder%TYPE --> Nr do convenio
                                    ,pr_nriniseq  IN INTEGER               --> Paginação - Inicio de sequencia
                                    ,pr_nrregist  IN INTEGER               --> Paginação - Número de registros
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML
  
  
  BEGIN
    /* .............................................................................
    Programa: pc_lista_detalhe_bord_ib
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 07/11/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar lista de cheques do bordero

    Alteracoes: 
    ............................................................................. */
    DECLARE
      --------- CURSOR ---------
      -- Busca Remessas de custódias
      CURSOR cr_crapcdb (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_nrborder IN crapcdb.nrborder%TYPE) IS
        SELECT x.* 
          FROM (SELECT to_char(cdb.dtlibera,'DD/MM/RRRR') dtlibera
                ,to_char(cdb.dtemissa,'DD/MM/RRRR') dtemissa
                ,cdb.cdbanchq
                ,cdb.cdagechq
                ,cdb.nrctachq
                ,cdb.nrcheque
                ,to_char(cdb.vlcheque,'fm999g999g999g990D00') vlcheque
                ,cdb.insitana
                ,NVL((SELECT 0
                    FROM crapdcc dcc
                       ,craphcc hcc
                   WHERE dcc.cdcooper = cdb.cdcooper
                     AND dcc.nrdconta = cdb.nrdconta
                     AND dcc.cdbanchq = cdb.cdbanchq
                     AND dcc.cdagechq = cdb.cdagechq
                     AND dcc.nrctachq = cdb.nrctachq
                     AND dcc.nrcheque = cdb.nrcheque
                    AND dcc.nrremret = cdb.nrremret
                    AND dcc.intipmvt IN (1,3)
                    AND dcc.cdtipmvt = 1
                    AND hcc.cdcooper = dcc.cdcooper
                    AND hcc.nrdconta = dcc.nrdconta
                    AND hcc.nrremret = dcc.nrremret
                    AND hcc.intipmvt = dcc.intipmvt
                    AND (dcc.inconcil = 0
                     OR  hcc.dtcustod IS NULL)),1) inconcil 
                ,translate(cdb.dsdocmc7
                          ,'[0-9]<>:'
                          ,'[0-9]') dsdocmc7
                ,rownum rnum
                ,COUNT(*) over() qtregist
            FROM crapcdb cdb
           WHERE cdb.cdcooper = pr_cdcooper
             AND cdb.nrdconta = pr_nrdconta
             AND cdb.nrborder = pr_nrborder) x
         WHERE rnum >= pr_nriniseq
           AND rnum < (pr_nriniseq + pr_nrregist);
      
      -- Busca Bordero
      CURSOR cr_crapbdc (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
        SELECT bdc.insitbdc
          from crapbdc bdc
         where bdc.cdcooper = pr_cdcooper
           AND bdc.nrdconta = pr_nrdconta
           AND bdc.nrborder = pr_nrborder;
      rw_crapbdc cr_crapbdc%ROWTYPE;
      
      --------- Variaveis ---------
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_dscritic  crapcri.dscritic%TYPE;
      vr_qtregist  INTEGER;
      
      -- Variaveis auxiliares
      vr_xml_pgto_temp VARCHAR2(32726) := '';
      vr_retxml        XMLType;
      
    BEGIN
      
      -- Monta documento XML
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<cheques>');

      vr_qtregist := 0;
      
      -- Percorre remessas
      FOR rw_crapcdb IN cr_crapcdb (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder) LOOP
        
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_pgto_temp
                               ,pr_texto_novo     => '<cheque>'
                                                  || '<dtlibera>'||rw_crapcdb.dtlibera||'</dtlibera>'
                                                  || '<dtemissa>'||rw_crapcdb.dtemissa||'</dtemissa>'
                                                  || '<cdbanchq>'||rw_crapcdb.cdbanchq||'</cdbanchq>'
                                                  || '<cdagechq>'||rw_crapcdb.cdagechq||'</cdagechq>'
                                                  || '<nrctachq>'||rw_crapcdb.nrctachq||'</nrctachq>'
                                                  || '<nrcheque>'||rw_crapcdb.nrcheque||'</nrcheque>'
                                                  || '<vlcheque>'||rw_crapcdb.vlcheque||'</vlcheque>'
                                                  || '<inconcil>'||rw_crapcdb.inconcil||'</inconcil>'
                                                  || '<insitana>'||rw_crapcdb.insitana||'</insitana>'
                                                  || '<dsdocmc7>'||rw_crapcdb.dsdocmc7||'</dsdocmc7>'
                                                  || '</cheque>');
        IF vr_qtregist = 0 THEN
          vr_qtregist := rw_crapcdb.qtregist;
        END IF;
      END LOOP;
      
      -- Encerrar a tag cheques
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '</cheques>');
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     =>  '<qtregist>' || vr_qtregist || '</qtregist>');
      
      OPEN cr_crapbdc (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrborder => pr_nrborder);
      FETCH  cr_crapbdc INTO  rw_crapbdc;
      IF cr_crapbdc%NOTFOUND THEN
        CLOSE cr_crapbdc;
        vr_dscritic := 'Borderô não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapbdc;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     =>  '<insitbdc>' || rw_crapbdc.insitbdc || '</insitbdc>'
                             ,pr_fecha_xml      => TRUE);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_lista_detalhe_bord_ib: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
  END pc_lista_detalhe_bord_ib;
  
  -- Buscar lista de cheques em custodia
  PROCEDURE pc_lista_cheques_cust_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nriniseq  IN INTEGER               --> Paginação - Inicio de sequencia
                                    ,pr_nrregist  IN INTEGER               --> Paginação - Número de registros
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML


  BEGIN
    /* .............................................................................
    Programa: pc_lista_cheques_cust_ib
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 07/11/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar lista de borderos de cheques.

    Alteracoes: 
    ............................................................................. */
    DECLARE
      --------- CURSOR ---------
      
      CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT inpessoa
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      --------- Variaveis ---------
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  crapcri.dscritic%TYPE;
      
      -- Variaveis auxiliares
      vr_xml_pgto_temp VARCHAR2(32726) := '';
      vr_retxml        XMLType;
      vr_tab_cstdsc    dscc0001.typ_tab_cstdsc;
      vr_qtregist      NUMBER;
      vr_stsnrcal      BOOLEAN;
      vr_inpessoa      NUMBER;
    
    BEGIN
      
      -- Monta documento XML
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
      
      -- Verifica se a conta esta cadastrada
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;
      
      DSCC0001.pc_busca_cheques_dsc_cst(pr_cdcooper   => pr_cdcooper
                                       ,pr_nrdconta   => pr_nrdconta
                                       ,pr_cdagenci   => 0
                                       ,pr_nrdcaixa   => 0
                                       ,pr_cdoperad   => 0
                                       ,pr_dtmvtolt   => trunc(SYSDATE)
                                       ,pr_idorigem   => 3
                                       ,pr_nriniseq   => pr_nriniseq
                                       ,pr_nrregist   => pr_nrregist
                                       ,pr_qtregist   => vr_qtregist
                                       ,pr_tab_cstdsc => vr_tab_cstdsc
                                       ,pr_cdcritic   => vr_cdcritic
                                       ,pr_dscritic   => vr_dscritic);
      -- Se ocorreu algum erro 							 
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;
      
      -- Se não houver nenhum cheque na PlTable
      IF vr_tab_cstdsc.count = 0 THEN
        -- Gerar crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Cheques não encontrados';
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;
  		
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     =>  '<qtregist>' || vr_qtregist || '</qtregist>');
                             
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<cheques>');
      
      
      FOR idx IN vr_tab_cstdsc.first..vr_tab_cstdsc.last LOOP
  		
        gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_tab_cstdsc(idx).nrcpfcgc
                                   ,pr_stsnrcal => vr_stsnrcal
                                   ,pr_inpessoa => vr_inpessoa);
  		
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_pgto_temp
                               ,pr_texto_novo     => '<cheque>'
                                                  || '<dtlibera>' || to_char(vr_tab_cstdsc(idx).dtlibera,'DD/MM/RRRR')           || '</dtlibera>'
                                                  || '<dtdcaptu>' || to_char(vr_tab_cstdsc(idx).dtdcaptu,'DD/MM/RRRR')           || '</dtdcaptu>'
                                                  || '<cdbanchq>' || vr_tab_cstdsc(idx).cdbanchq                                 || '</cdbanchq>'
                                                  || '<cdagechq>' || vr_tab_cstdsc(idx).cdagechq                                 || '</cdagechq>'
                                                  || '<nrctachq>' || vr_tab_cstdsc(idx).nrctachq                                 || '</nrctachq>'
                                                  || '<nrcheque>' || vr_tab_cstdsc(idx).nrcheque                                 || '</nrcheque>'
                                                  || '<vlcheque>' || to_char(vr_tab_cstdsc(idx).vlcheque,'fm999g999g999g990d00') || '</vlcheque>'
                                                  || '<inconcil>' || vr_tab_cstdsc(idx).inconcil                                 || '</inconcil>'
                                                  || '<nrdocmc7>' || regexp_replace(vr_tab_cstdsc(idx).dsdocmc7,'[<>:]','')      || '</nrdocmc7>'
                                                  || '<cdcmpchq>' || vr_tab_cstdsc(idx).cdcmpchq                                 || '</cdcmpchq>'
                                                  || '<dtcustod>' || to_char(vr_tab_cstdsc(idx).dtcustod,'DD/MM/RRRR')           || '</dtcustod>'
                                                  || '<nrremret>' || vr_tab_cstdsc(idx).nrremret                                 || '</nrremret>'																 
                                                  || '</cheque>');

      END LOOP;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '</cheques>'
                             ,pr_fecha_xml      => TRUE);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        IF vr_cdcritic > 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_lista_cheques_cust_ib: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
  END pc_lista_cheques_cust_ib;
  
  -- Excluir bordero de descontos.
  PROCEDURE pc_excluir_bordero_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                 ,pr_nrborder  IN crapbdc.nrborder%TYPE --> Nr do convenio
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML


  BEGIN
    /* .............................................................................
    Programa: pc_excluir_bordero_ib
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 05/12/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para excluir bordero de descontos.

    Alteracoes: 
    ............................................................................. */
    DECLARE
      
      --------- CURSOR ---------
      
      -- Busca Bordero de Desconto
      CURSOR cr_crapbdc (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
        SELECT bdc.dtmvtolt
              ,bdc.nrdolote
              ,bdc.cdagenci
              ,bdc.cdbccxlt
              ,bdc.insitbdc
							,bdc.cdoperad
          FROM crapbdc bdc
         WHERE bdc.cdcooper = pr_cdcooper
           AND bdc.nrdconta = pr_nrdconta
           OR  bdc.nrborder = pr_nrborder;
      rw_crapbdc cr_crapbdc%ROWTYPE;
      
      -- Busca e-mail da empresa
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT age.dsmailbd
              ,age.cdagenci
          FROM crapass ass
              ,crapage age
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta
           AND age.cdcooper = ass.cdcooper
           AND age.cdagenci = ass.cdagenci
           AND TRIM(age.dsmailbd) IS NOT NULL;
      rw_crapage cr_crapage%ROWTYPE;
      
      --------- Variaveis ---------
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Variaveis auxiliares
      vr_flgfound      BOOLEAN;
      vr_dstransa      VARCHAR2(100);
      vr_rowid_log     ROWID;
      vr_retxml        XMLType;
      vr_xml_pgto_temp VARCHAR2(32726) := '';
      
      vr_desassun          VARCHAR2(1000);
      vr_descorpo          VARCHAR2(1000);
      
    BEGIN
      
      -- Monta documento XML
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

      -- Verifica se existe o registro
      OPEN cr_crapbdc (pr_cdcooper => pr_cdcooper 
                      ,pr_nrdconta => pr_nrdconta 
                      ,pr_nrborder => pr_nrborder);
      FETCH cr_crapbdc INTO rw_crapbdc;
      vr_flgfound := cr_crapbdc%FOUND;
      CLOSE cr_crapbdc;
      -- Se encontrar registro
      IF vr_flgfound THEN
        
        IF rw_crapbdc.insitbdc <> 1 THEN
          vr_dscritic := '';
          RAISE vr_exc_erro;
        END IF;
        
				-- Exclusão permitida somente para operações no IB
				IF rw_crapbdc.cdoperad <> '996' THEN
					vr_dscritic := 'Bordero incluso no PA. Não permitido exclusão.';
					RAISE vr_exc_erro;
				END IF;
        
        -- Exclui o resgitro
        BEGIN
          
          UPDATE crapdcc dcc SET nrborder = 0 -- zero
           WHERE dcc.cdcooper = pr_cdcooper
             AND dcc.nrdconta = pr_nrdconta
             AND dcc.nrborder = pr_nrborder;
      			
          -- se o cheque estiver em custódia (crapcst), atualizar o numero do borderô para zero;	
          UPDATE crapcst cst SET nrborder = 0 -- zero
           WHERE cst.cdcooper = pr_cdcooper
             AND cst.nrdconta = pr_nrdconta
             AND cst.nrborder = pr_nrborder;	  
          
          -- apagar registro do cálculo de juros do cheque no borderô;		   
          DELETE FROM crapljd ljd
           WHERE ljd.cdcooper = pr_cdcooper
             AND ljd.nrdconta = pr_nrdconta
             AND ljd.nrborder = pr_nrborder;
          
          -- apagar registro de análise dos cheques do borderô;
          DELETE FROM crapabc abc
           WHERE abc.cdcooper = pr_cdcooper
             AND abc.nrdconta = pr_nrdconta
             AND abc.nrborder = pr_nrborder;
          
          -- apagar registro do cheque no borderô;
          DELETE FROM crapcdb cdb
           WHERE cdb.cdcooper = pr_cdcooper
             AND cdb.nrdconta = pr_nrdconta
             AND cdb.nrborder = pr_nrborder;
          
          -- apagar registro do borderô;
          DELETE FROM crapbdc bdc
           WHERE bdc.cdcooper = pr_cdcooper
             AND bdc.nrdconta = pr_nrdconta
             AND bdc.nrborder = pr_nrborder;
          
          --apaga registro do lote;
          DELETE FROM craplot lot
           WHERE lot.cdcooper = pr_cdcooper
             AND lot.dtmvtolt = rw_crapbdc.dtmvtolt
             AND lot.nrdolote = rw_crapbdc.nrdolote
             AND lot.cdagenci = rw_crapbdc.cdagenci
             AND lot.cdbccxlt = rw_crapbdc.cdbccxlt;
             
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro na exclusão da remessa. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        vr_dstransa := 'Exclusao do bordero ' || 'Nro.: ' || pr_nrborder;
          
          -- Efetua os inserts para apresentacao na tela VERLOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => 996
                              ,pr_dscritic => ' '
                              ,pr_dsorigem => 'INTERNET'
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => trunc(SYSDATE)
                              ,pr_flgtrans => 1
                              ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => 'INTERNETBANK'
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_rowid_log);
        
      ELSE
        vr_dscritic := 'Bordero não localizado.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Busca e-mail da empresa
      OPEN cr_crapage (pr_cdcooper
                      ,pr_nrdconta);
      FETCH cr_crapage INTO rw_crapage;
      vr_flgfound := cr_crapage%FOUND;
      -- Fecha cursor
      CLOSE cr_crapage;
      
      -- Se e-mail do PA
      IF vr_flgfound THEN
        
        -- Assunto do E-mail
        vr_desassun := ' Exclusão de borderô de cheques: ' || rw_crapage.cdagenci ||
                                                  ' - ' || pr_nrdconta || 
                                                  ' - ' || pr_nrborder;
        
        -- Corpo do E-mail
        vr_descorpo := 'PA:'                      || rw_crapage.cdagenci || '<br>' ||
                       'Conta/DV:	'               || pr_nrdconta || '<br>' ||
                       'Número do borderô: '      || pr_nrborder || '<br>' ||
                       'Data/Hora: '              || to_char(SYSDATE, 'DD/MM/RRRR hh:mi:ss');
        
        -- Envia E-mail
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_flg_remete_coop => 'N'  --> Envio pelo e-mail da Cooperativa
                                  ,pr_cdprogra        => 'DSCC0002'
                                  ,pr_des_destino     => TRIM(rw_crapage.dsmailbd)
                                  ,pr_des_assunto     => vr_desassun
                                  ,pr_des_corpo       => vr_descorpo
                                  ,pr_des_anexo       => NULL --> nao envia anexo
                                  ,pr_flg_remove_anex => 'N'  --> Remover os anexos passados
                                  ,pr_flg_enviar      => 'S'  --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);
        -- Se houver erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        
      END IF;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<raiz>OK</raiz>'
                             ,pr_fecha_xml      => TRUE);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_excluir_bordero_ib: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
  END pc_excluir_bordero_ib;
  
  -- Imprimir bordero
  PROCEDURE pc_imprime_bordero_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                 ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                 ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                 ,pr_nrborder  IN crapbdc.nrborder%TYPE --> Numero do bordero
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML

  BEGIN
    /* .............................................................................
    Programa: pc_lista_borderos
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 07/11/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar lista de borderos de cheques.

    Alteracoes: 
    ............................................................................. */
    DECLARE
      --------- CURSOR ---------
      
       -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      
      --------- Variaveis ---------
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  crapcri.dscritic%TYPE;
      
      -- Variaveis auxiliares
      vr_xml_pgto_temp VARCHAR2(32726) := '';
      vr_retxml        XMLType;
      vr_nmarqpdf      VARCHAR2(1000);
    
    BEGIN
      
      -- Monta documento XML
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
      
      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      
      DSCC0001.pc_gera_impressao_bordero(pr_cdcooper => pr_cdcooper
                                        ,pr_cdagecxa => 0
                                        ,pr_nrdcaixa => 0
                                        ,pr_cdopecxa => 996
                                        ,pr_nmdatela => ''
                                        ,pr_idorigem => 3
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                        ,pr_inproces => rw_crapdat.inproces
                                        ,pr_idimpres => 7
                                        ,pr_nrctrlim => pr_nrctrlim
                                        ,pr_nrborder => pr_nrborder
                                        ,pr_dsiduser => to_char(pr_nrdconta)
                                        ,pr_flgemail => 0
                                        ,pr_flgerlog => 0
                                        ,pr_nmarqpdf => vr_nmarqpdf
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<nmarqpdf>' || vr_nmarqpdf || '</nmarqpdf>'
                             ,pr_fecha_xml      => TRUE);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        IF vr_cdcritic > 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_imprime_bordero_ib: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
  END pc_imprime_bordero_ib;
  
  -- Verifica emitentes para cadastrar
  PROCEDURE pc_verifica_emitentes_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_dsdocmc7  IN VARCHAR2              --> Lista CMC7
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML
  
  BEGIN
    /* .............................................................................
    Programa: pc_cadastra_custodia
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 20/10/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para cadastrar a custodia dos cheques

    Alteracoes: 
    
    ............................................................................. */
    DECLARE
      -- Variaveis de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_erro   EXCEPTION;
      vr_exc_emiten EXCEPTION;
  		vr_exc_custod EXCEPTION;
      
      -- Variaveis auxiliares
      vr_retxml            XMLType;
      vr_index_cheque      NUMBER := 0;
      vr_contas_existentes VARCHAR2(32726) := '';
      vr_conta_atual       VARCHAR2(200);
      
      -- Vetor para armazenar as informac?es de erro
      vr_xml_emitentes VARCHAR2(32726);
			
      -- Vetor para armazenar as informacoes dos cheques que estao sendo custodiados
      vr_tab_cheques DSCC0001.typ_tab_cheques;
      
    BEGIN
      
      -- Verificar se possui algum emitente não cadastrado
      dscc0001.pc_verifica_emitentes (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => 0
                                     ,pr_dscheque => replace(pr_dsdocmc7,'_','|')
                                     ,pr_tab_cheques => vr_tab_cheques
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
      
      -- Se retornou erro												 
		  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			  --Levantar Excecao
			  RAISE vr_exc_erro;
		  END IF;
															 															 			
			-- Verificar se possui algum emitente não cadastrado
			IF vr_tab_cheques.count > 0 THEN
				vr_xml_emitentes := '';
				FOR vr_index_cheque IN 1..vr_tab_cheques.count LOOP
					
           -- Monta chave do emitente
          vr_conta_atual := vr_tab_cheques(vr_index_cheque).cdbanchq ||
                            vr_tab_cheques(vr_index_cheque).cdagechq ||
                            vr_tab_cheques(vr_index_cheque).nrctachq;
          -- Verifica se emitente ta conta ja foi pedido
          IF INSTR(vr_contas_existentes, vr_conta_atual) = 0  OR 
             vr_contas_existentes IS NULL                     THEN
             vr_contas_existentes := vr_contas_existentes || ';' || vr_conta_atual;
          
            -- Se exister algum cheque sem emitente
            IF vr_tab_cheques(vr_index_cheque).inemiten = 0 AND
               vr_tab_cheques(vr_index_cheque).cdbanchq <> 85 THEN
              -- Passar flag de falta de cadastro de emitente
              vr_xml_emitentes := vr_xml_emitentes ||
                                  '<emitente'|| vr_index_cheque || '>' ||
                                  '   <cdbanchq>' || vr_tab_cheques(vr_index_cheque).cdbanchq || '</cdbanchq>' ||
                                  '   <cdagechq>' || vr_tab_cheques(vr_index_cheque).cdagechq || '</cdagechq>' ||
                                  '   <nrctachq>' || vr_tab_cheques(vr_index_cheque).nrctachq || '</nrctachq>' ||
                                  '   <cdcmpchq>' || vr_tab_cheques(vr_index_cheque).cdcmpchq || '</cdcmpchq>' ||
                                  '</emitente'|| vr_index_cheque || '>';
            END IF;
          END IF;
				END LOOP;
				IF trim(vr_xml_emitentes) IS NOT NULL THEN
					RAISE vr_exc_emiten;
				END IF;
			END IF;
      
    EXCEPTION
      WHEN vr_exc_emiten THEN
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<Root><Emitentes>' || vr_xml_emitentes || '</Emitentes></Root>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN vr_exc_erro THEN
        IF vr_cdcritic > 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_verifica_emitentes_ib: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
    
  END pc_verifica_emitentes_ib;
  
  -- Cadastrar desconto
  PROCEDURE pc_desconto_cheque_ib(pr_cdcooper    IN crapcop.cdcooper%TYPE    --> Cooperativa
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE    --> Codigo do Indexador
                                 ,pr_idseqttl    IN crapttl.idseqttl%TYPE    --> Número do Titular
                                 ,pr_tab_cheques IN dscc0001.typ_tab_cheques --> Cheques para desconto
                                 ,pr_dscritic   OUT VARCHAR2                 --> Descrição da crítica
                                 ,pr_retxml     OUT CLOB) IS                 --> Arquivo de retorno do XML
  
  BEGIN
    /* .............................................................................
    Programa: pc_cadastra_custodia
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 20/10/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para cadastrar a custodia dos cheques

    Alteracoes: 
    
    ............................................................................. */
    DECLARE
      
      -- Busca e-mail da empresa
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT age.dsmailbd
              ,age.cdagenci
          FROM crapass ass
              ,crapage age
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta
           AND age.cdcooper = ass.cdcooper
           AND age.cdagenci = ass.cdagenci
           AND TRIM(age.dsmailbd) IS NOT NULL;
      rw_crapage cr_crapage%ROWTYPE;
      
      -- Variaveis de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_erro   EXCEPTION;
      vr_exc_emiten EXCEPTION;
  		vr_exc_custod EXCEPTION;
      
      -- Variaveis auxiliares
      vr_xml_erro_emitente VARCHAR2(32726);
      vr_xml_erro_custodia VARCHAR2(32726);
      vr_retxml            XMLType;
      vr_nrdrowid          ROWID;
      vr_nrborder          NUMBER;
      vr_nrdolote          NUMBER;
      vr_qtcheque          NUMBER := 0;
      vr_vlcheque          NUMBER := 0;
      vr_desassun          VARCHAR2(1000);
      vr_descorpo          VARCHAR2(1000);
      vr_flgfound          BOOLEAN;
      
    BEGIN
      
      dscc0001.pc_criar_bordero_cheques(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_cdagenci => 0
                                       ,pr_idorigem => 3   -- INTERNET
                                       ,pr_cdoperad => 996 -- INTERNET
                                       ,pr_nrdolote => vr_nrdolote
                                       ,pr_nrborder => vr_nrborder
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
      
      -- Se houve críticas													 
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;
      
      -- Adicionar cheques ao bordero
      DSCC0001.pc_adicionar_cheques_bordero(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_cdagenci => 0
                                           ,pr_idorigem => 3   -- INTERNET
                                           ,pr_cdoperad => 996 -- INTERNET
                                           ,pr_nrborder => vr_nrborder
                                           ,pr_nrdolote => vr_nrdolote
                                           ,pr_tab_cheques => pr_tab_cheques
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
      -- Se houve críticas													 
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;	 
  		
      FOR idx IN pr_tab_cheques.first..pr_tab_cheques.last LOOP
        vr_qtcheque := vr_qtcheque + 1;
        vr_vlcheque := vr_vlcheque + pr_tab_cheques(idx).vlcheque;
      END LOOP;
      
      -- Gerar log
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 996
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => 'INTERNET'
                          ,pr_dstransa => 'Inclusão de borderô de desconto.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Borderô'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => vr_nrborder);
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Valor Total de Cheques'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => to_char(vr_vlcheque,'fm999g999g990d00'));
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Quantidade de Cheques'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => vr_qtcheque);
      
      FOR idx IN pr_tab_cheques.first..pr_tab_cheques.last LOOP
        
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Cheque ' || idx
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => gene0002.fn_mask(pr_tab_cheques(idx).dsdocmc7,'<99999999<9999999999>999999999999:'));
      END LOOP;
      
      -- Busca e-mail da empresa
      OPEN cr_crapage (pr_cdcooper
                      ,pr_nrdconta);
      FETCH cr_crapage INTO rw_crapage;
      vr_flgfound := cr_crapage%FOUND;
      -- Fecha cursor
      CLOSE cr_crapage;
      
      -- Se e-mail do PA
      IF vr_flgfound THEN
        
        -- Assunto do E-mail
        vr_desassun := ' Aviso de borderô de cheques: ' || rw_crapage.cdagenci ||
                                                  ' - ' || pr_nrdconta || 
                                                  ' - ' || vr_nrborder || 
                                                  ' - ' || to_char(vr_vlcheque,'fm999g999g990d00');
        
        -- Corpo do E-mail
        vr_descorpo := 'PA:'                      || rw_crapage.cdagenci || '<br>' ||
                       'Conta/DV:	'               || pr_nrdconta || '<br>' ||
                       'Número do borderô: '      || vr_nrborder || '<br>' ||
                       'Data/Hora: '              || to_char(SYSDATE, 'DD/MM/RRRR hh:mi:ss') || '<br>' ||
                       'Quantidade de cheques:  ' || vr_qtcheque || '<br>' ||
                       'Valor total do borderô: ' || to_char(vr_vlcheque,'fm999g999g990d00');
        
        -- Envia E-mail
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_flg_remete_coop => 'N'  --> Envio pelo e-mail da Cooperativa
                                  ,pr_cdprogra        => 'DSCC0002'
                                  ,pr_des_destino     => TRIM(rw_crapage.dsmailbd)
                                  ,pr_des_assunto     => vr_desassun
                                  ,pr_des_corpo       => vr_descorpo
                                  ,pr_des_anexo       => NULL --> nao envia anexo
                                  ,pr_flg_remove_anex => 'N'  --> Remover os anexos passados
                                  ,pr_flg_enviar      => 'S'  --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);
        -- Se houver erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        
      END IF;
            
      pr_retxml := '<Root>Operação realizada com sucesso!</Root>';
			
      -- Commita as alterações;
      COMMIT;
  
    EXCEPTION
      WHEN vr_exc_emiten THEN
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<Root><Validar_Emiten>' || vr_xml_erro_emitente || '</Validar_Emiten></Root>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN vr_exc_custod THEN
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<Root><Validar_CMC7>' || vr_xml_erro_custodia || '</Validar_CMC7></Root>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN vr_exc_erro THEN
        IF vr_cdcritic > 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_desconto_cheque_ib: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
    
  END pc_desconto_cheque_ib;
  
  -- Cadastrar desconto nas tabelas de transação pendente
  PROCEDURE pc_descto_chq_pend_ib(pr_cdcooper    IN crapcop.cdcooper%TYPE    --> Cooperativa
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE    --> Codigo do Indexador
                                 ,pr_idseqttl    IN crapttl.idseqttl%TYPE    --> Número do Titular
                                 ,pr_nrcpfope    IN crapopi.nrcpfope%TYPE    --> Cpf do Operador
                                 ,pr_nrcpfrep    IN crapopi.nrcpfope%TYPE    --> Cpf do Responsavel Legal
                                 ,pr_tab_cheques IN dscc0001.typ_tab_cheques --> Cheques para desconto
                                 ,pr_dscritic   OUT VARCHAR2                 --> Descrição da crítica
                                 ,pr_retxml     OUT CLOB) IS                 --> Arquivo de retorno do XML
  
  BEGIN
    /* .............................................................................
    Programa: pc_descto_chq_pend_ib
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 30/11/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  :  Cadastrar desconto nas tabelas de transação pendente

    Alteracoes: 
    
    ............................................................................. */
    DECLARE
      -- Variaveis de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_erro   EXCEPTION;
      vr_exc_emiten EXCEPTION;
  		vr_exc_custod EXCEPTION;
      
      -- Variaveis auxiliares
      vr_xml_erro_emitente VARCHAR2(32726);
      vr_xml_erro_custodia VARCHAR2(32726);
      vr_retxml            XMLType;
      vr_nrdrowid          ROWID;
      vr_qtcheque          NUMBER := 0;
      vr_vlcheque          NUMBER := 0;
      
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCONTO'
                                ,pr_action => NULL);	
  	  
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      inet0002.pc_cria_trans_pend_descto(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_nrcpfrep => pr_nrcpfrep
                                        ,pr_cdagenci => 90
                                        ,pr_nrdcaixa => 900
                                        ,pr_cdoperad => 996
                                        ,pr_nmdatela => 'INTERNETBANK'
                                        ,pr_idorigem => 3
                                        ,pr_nrcpfope => pr_nrcpfope
                                        ,pr_cdcoptfn => 0
                                        ,pr_cdagetfn => 0
                                        ,pr_nrterfin => 0
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_idastcjt => 1
                                        ,pr_tab_cheques => pr_tab_cheques
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
      
      -- Se ocorrer algum erro
      IF nvl(vr_cdcritic,0) <> 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro; 
      END IF;
      
      FOR idx IN pr_tab_cheques.first..pr_tab_cheques.last LOOP
        vr_qtcheque := vr_qtcheque + 1;
        vr_vlcheque := vr_vlcheque + pr_tab_cheques(idx).vlcheque;
      END LOOP;
      
      -- Gerar log
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 996
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => 'INTERNET'
                          ,pr_dstransa => 'Transação pendente de borderô de desconto.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => ' '
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Valor Total de Cheques'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => to_char(vr_vlcheque,'fm999g999g990d00'));
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Quantidade de Cheques'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => vr_qtcheque);
      
      pr_retxml := '<Root>Borderô de desconto de cheques registrado com sucesso. Aguardando aprovação do registro pelos demais responsáveis.</Root>';
			
      -- Commita as alterações;
      COMMIT;
  
    EXCEPTION
      WHEN vr_exc_emiten THEN
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<Root><Validar_Emiten>' || vr_xml_erro_emitente || '</Validar_Emiten></Root>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN vr_exc_custod THEN
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<Root><Validar_CMC7>' || vr_xml_erro_custodia || '</Validar_CMC7></Root>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN vr_exc_erro THEN
        IF vr_cdcritic > 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_descto_chq_pend_ib: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
    
  END pc_descto_chq_pend_ib;
  
  -- Verifica se a conta exige assinatura multipla
  PROCEDURE pc_verifica_ass_multi_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Número do Titular
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE --> Cpf do Operador
                                    ,pr_dtlibera  IN VARCHAR2              --> Lista Data Boa
                                    ,pr_dtdcaptu  IN VARCHAR2              --> Lista Data Emissao
                                    ,pr_vlcheque  IN VARCHAR2              --> Lista Valor Cheque
                                    ,pr_dtcustod  IN VARCHAR2              --> Lista Data Custodia
                                    ,pr_intipchq  IN VARCHAR2              --> Lista Tipo Cheque
                                    ,pr_dsdocmc7  IN VARCHAR2              --> Lista CMC7
                                    ,pr_nrremret  IN VARCHAR2              --> Lista Remessa
                                    ,pr_aprvpend  IN INTEGER               --> Aprova Bordero Pendente (1 - Sim/0 - Não/3 - Validar)
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML
  
  BEGIN
    /* .............................................................................
    Programa: pc_verifica_ass_multi_ib
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 30/11/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Verifica se a conta exige assinatura multipla

    Alteracoes: 24/08/2017 - Ajuste na busca de emitentes. (Lombardi)
    
    ............................................................................. */
    DECLARE
      -- Variaveis de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_erro   EXCEPTION;
      vr_exc_emiten EXCEPTION;
  		vr_exc_custod EXCEPTION;
      
      -- Variaveis auxiliares
      vr_qtmaxchq            NUMBER;
      vr_index_cheque        NUMBER := 0;
      vr_retxml              CLOB;
      vr_idastcjt            crapass.idastcjt%TYPE;
      vr_nrcpfcgc            crapass.nrcpfcgc%TYPE;
      vr_nmprimtl            crapass.nmprimtl%TYPE;
      vr_flcartma            INTEGER;
      vr_nrdconta_ver_cheque crapass.nrdconta%TYPE;
      vr_dsdaviso            VARCHAR2(1000);
      vr_dscheque            VARCHAR2(32726);
      
      -- Informações do cheque
      vr_dsdocmc7 VARCHAR2(45);
      vr_cdbanchq NUMBER; 
      vr_cdagechq NUMBER;
      vr_cdcmpchq NUMBER;
      vr_nrctachq NUMBER;
      vr_nrcheque NUMBER;
      vr_vlcheque NUMBER;
      vr_intipchq NUMBER;
      vr_nrremret NUMBER;
      vr_dtlibera DATE;
      vr_dtcustod DATE;
      vr_dtdcaptu DATE;		
      
      vr_ret_all_dtlibera gene0002.typ_split;
      vr_ret_all_dtdcaptu gene0002.typ_split;
      vr_ret_all_vlcheque gene0002.typ_split;
      vr_ret_all_dtcustod gene0002.typ_split;
      vr_ret_all_intipchq gene0002.typ_split;
      vr_ret_all_dsdocmc7 gene0002.typ_split;
      vr_ret_all_nrremret gene0002.typ_split;
      
      vr_tab_cheques         dscc0001.typ_tab_cheques;
      vr_tab_custodia_erro   cust0001.typ_erro_custodia;
      vr_tab_cheque_custodia cust0001.typ_cheque_custodia;
      
      --> Buscar cadastro do cooperado emitente
      CURSOR cr_crapass (pr_cdagectl IN crapcop.cdagectl%TYPE,
                         pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT ass.inpessoa
              ,ass.nrcpfcgc
          FROM crapass ass
              ,crapcop cop
         WHERE cop.cdagectl = pr_cdagectl
           AND ass.cdcooper = cop.cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass  cr_crapass%ROWTYPE;
      
      --> Buscar primeiro titular da conta
      CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ttl.nrcpfcgc
          FROM crapttl ttl
         WHERE ttl.cdcooper = pr_cdcooper
           AND ttl.nrdconta = pr_nrdconta
           AND ttl.idseqttl = 1;
      rw_crapttl  cr_crapttl%ROWTYPE;
      
      -- Busca informações do emitente
      CURSOR cr_crapcec (pr_cdcooper IN crapcec.cdcooper%TYPE
                        ,pr_cdcmpchq IN crapcec.cdcmpchq%TYPE
                        ,pr_cdbanchq IN crapcec.cdbanchq%TYPE
                        ,pr_cdagechq IN crapcec.cdagechq%TYPE
                        ,pr_nrctachq IN crapcec.nrctachq%TYPE) IS
        SELECT cec.nrcpfcgc
              ,cec.nmcheque
          FROM crapcec cec
         WHERE cec.cdcooper = pr_cdcooper
           AND cec.cdcmpchq = pr_cdcmpchq
           AND cec.cdbanchq = pr_cdbanchq
           AND cec.cdagechq = pr_cdagechq
           AND cec.nrctachq = pr_nrctachq
           AND cec.nrdconta = 0;
      rw_crapcec cr_crapcec%ROWTYPE;
      
      -- Busca cheque custodiado
      CURSOR cr_crapdcc(pr_cdcooper IN crapdcc.cdcooper%TYPE
                       ,pr_nrdconta IN crapdcc.nrdconta%TYPE
                       ,pr_dtlibera IN crapdcc.dtlibera%TYPE
                       ,pr_dtdcaptu IN crapdcc.dtdcaptu%TYPE
                       ,pr_vlcheque IN crapdcc.vlcheque%TYPE
                       ,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE) IS
        SELECT 1
          FROM crapdcc dcc
         WHERE dcc.cdcooper = pr_cdcooper 
           AND dcc.nrdconta = pr_nrdconta
           AND trunc(dcc.dtlibera) = trunc(pr_dtlibera)
           AND trunc(dcc.dtdcaptu) = trunc(pr_dtdcaptu)
           AND dcc.vlcheque = pr_vlcheque
           AND dcc.dsdocmc7 = pr_dsdocmc7
           AND dcc.intipmvt in (1,3); -- 1 - Remessa / 3 - Retorno
      rw_crapdcc cr_crapdcc%ROWTYPE;

      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCONTO'
                                ,pr_action => NULL);	
  	  
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      -- Não é pode cadastrar no processo noturno
      IF rw_crapdat.inproces <> 1 THEN
        vr_dscritic := 'Desconto de cheques indisponível no momento. Tente mais tarde.';
        RAISE vr_exc_erro;
      END IF;
      
      vr_qtmaxchq := to_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                         pr_cdcooper => 0, /* cecred */
                                                         pr_cdacesso => 'QTD_CHQ_REM_IB'));
      
      -- Criando um Array com todos os cheques que vieram como parametro
      vr_ret_all_dtlibera := gene0002.fn_quebra_string(pr_dtlibera, '_');
      vr_ret_all_dtdcaptu := gene0002.fn_quebra_string(pr_dtdcaptu, '_');
      vr_ret_all_vlcheque := gene0002.fn_quebra_string(pr_vlcheque, '_');
      vr_ret_all_dtcustod := gene0002.fn_quebra_string(pr_dtcustod, '_');
      IF pr_aprvpend = 0 THEN
        vr_ret_all_intipchq := gene0002.fn_quebra_string(pr_intipchq, '_');
      END IF;
      vr_ret_all_dsdocmc7 := gene0002.fn_quebra_string(pr_dsdocmc7, '_');
      vr_ret_all_nrremret := gene0002.fn_quebra_string(pr_nrremret, '_');
      
      IF vr_ret_all_dsdocmc7.count > vr_qtmaxchq THEN
        vr_dscritic := 'A quantidade máxima de cheques foi ultrapassada.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Percorre todos os cheques para processá-los
      FOR vr_auxcont IN 1..vr_ret_all_dsdocmc7.count LOOP
        -- Data de liberação
        vr_dtlibera := to_date(vr_ret_all_dtlibera(vr_auxcont),'dd/mm/RRRR');
        -- Data de emissão
        vr_dtdcaptu := to_date(vr_ret_all_dtdcaptu(vr_auxcont),'dd/mm/RRRR');
        IF TRIM(pr_dtcustod) IS NOT NULL THEN
          -- Data da custódia
          vr_dtcustod := to_date(vr_ret_all_dtcustod(vr_auxcont),'dd/mm/RRRR');
        ELSE
          vr_dtcustod := NULL;
        END IF;
        
        -- Valor do cheque
        vr_vlcheque := to_number(vr_ret_all_vlcheque(vr_auxcont));
        -- Buscar o cmc7			
        vr_dsdocmc7 := vr_ret_all_dsdocmc7(vr_auxcont);
  			-- Remessa
        vr_nrremret := to_number(vr_ret_all_nrremret(vr_auxcont));
  						
        -- Desmontar as informações do CMC-7
        -- Banco
        vr_cdbanchq := to_number(SUBSTR(vr_dsdocmc7,01,03)); 
        -- Agencia
        vr_cdagechq := to_number(SUBSTR(vr_dsdocmc7,04,04)); 
        -- Compe
        vr_cdcmpchq := to_number(SUBSTR(vr_dsdocmc7,09,03));
        -- Numero do Cheque
        vr_nrcheque := to_number(SUBSTR(vr_dsdocmc7,12,06));
        -- Conta do Cheque
        IF vr_cdbanchq = 1 THEN
          vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,22,08));   
        ELSE 
          vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,20,10)); 
        END IF;
  			
        -- Se for aprovacao
        IF pr_aprvpend <> 0 THEN
          OPEN cr_crapdcc (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_dtlibera => vr_dtlibera
                          ,pr_dtdcaptu => vr_dtdcaptu
                          ,pr_vlcheque => vr_vlcheque
                          ,pr_dsdocmc7 => gene0002.fn_mask(vr_dsdocmc7,'<99999999<9999999999>999999999999:'));
          FETCH cr_crapdcc INTO rw_crapdcc;
          IF cr_crapdcc%FOUND THEN --Tipo de cheque (1 - Novo, 2 - Selecionado)
            vr_intipchq := 2;
          ELSE
            vr_intipchq := 1;
          END IF;
          CLOSE cr_crapdcc;
        ELSE
          vr_intipchq := to_number(vr_ret_all_intipchq(vr_auxcont));
        END IF;
        
        -- Carrega as informações do cheque para custodiar
        vr_index_cheque := vr_tab_cheques.count + 1;  
        vr_tab_cheques(vr_index_cheque).cdcooper := pr_cdcooper;
        vr_tab_cheques(vr_index_cheque).nrdconta := pr_nrdconta;
        vr_tab_cheques(vr_index_cheque).cdagenci := 0;
        vr_tab_cheques(vr_index_cheque).dtmvtolt := rw_crapdat.dtmvtolt;			
        vr_tab_cheques(vr_index_cheque).dtcustod := vr_dtcustod;
        vr_tab_cheques(vr_index_cheque).dtlibera := vr_dtlibera;
        vr_tab_cheques(vr_index_cheque).dtdcaptu := vr_dtdcaptu;
        vr_tab_cheques(vr_index_cheque).intipchq := vr_intipchq;
        vr_tab_cheques(vr_index_cheque).vlcheque := vr_vlcheque;
        vr_tab_cheques(vr_index_cheque).dsdocmc7 := vr_dsdocmc7;
        vr_tab_cheques(vr_index_cheque).cdcmpchq := vr_cdcmpchq;
        vr_tab_cheques(vr_index_cheque).cdbanchq := vr_cdbanchq;
        vr_tab_cheques(vr_index_cheque).cdagechq := vr_cdagechq;
        vr_tab_cheques(vr_index_cheque).nrctachq := vr_nrctachq;
        vr_tab_cheques(vr_index_cheque).nrcheque := vr_nrcheque;
        vr_tab_cheques(vr_index_cheque).nrremret := vr_nrremret;
        
        -- Se for do sistema CECRED
        IF vr_cdbanchq = 85 THEN
          -- Buscar cadastro do cooperado emitente
          OPEN cr_crapass (pr_cdagectl => vr_cdagechq
                          ,pr_nrdconta => vr_nrctachq);
          FETCH cr_crapass INTO rw_crapass;
          
          -- Se encontrar
          IF cr_crapass%FOUND THEN
            CLOSE cr_crapass;
            -- Pessoa Física
            IF rw_crapass.inpessoa = 1 THEN
              OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => vr_nrctachq);
              FETCH cr_crapttl INTO rw_crapttl;
              -- Se encontrar
              IF cr_crapttl%FOUND THEN
                CLOSE cr_crapttl;
                vr_tab_cheques(vr_index_cheque).nrcpfcgc := rw_crapttl.nrcpfcgc;
              ELSE
                CLOSE cr_crapttl;
                vr_dscritic := 'Emitente não cadastrado.';
                RAISE vr_exc_erro;
              END IF;
            ELSE -- Pessoa Juridica
              vr_tab_cheques(vr_index_cheque).nrcpfcgc := rw_crapass.nrcpfcgc;
            END IF;
          ELSE
            CLOSE cr_crapass;
            vr_dscritic := 'Emitente não cadastrado.';
            RAISE vr_exc_erro;
          END IF;
        ELSE
          -- Buscar cadastro de emitentes de cheques
        OPEN cr_crapcec (pr_cdcooper => pr_cdcooper
                        ,pr_cdcmpchq => vr_cdcmpchq
                        ,pr_cdbanchq => vr_cdbanchq
                        ,pr_cdagechq => vr_cdagechq
                        ,pr_nrctachq => vr_nrctachq);
        FETCH cr_crapcec INTO rw_crapcec;
          -- Se encontrar
          IF cr_crapcec%FOUND THEN
          CLOSE cr_crapcec;
          vr_tab_cheques(vr_index_cheque).nrcpfcgc := rw_crapcec.nrcpfcgc;
          ELSE
        CLOSE cr_crapcec;
            vr_dscritic := 'Emitente não cadastrado.';
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
      END LOOP;
  		
      -- Validar Bordero
      IF pr_aprvpend = 3 THEN
        -- Validar os cheques
        FOR idx IN vr_tab_cheques.first..vr_tab_cheques.last LOOP
          -- Verificar Cheque
          CUST0001.pc_ver_cheque(pr_cdcooper => vr_tab_cheques(idx).cdcooper
                                ,pr_nrcustod => vr_tab_cheques(idx).nrdconta
                                ,pr_cdbanchq => vr_tab_cheques(idx).cdbanchq
                                ,pr_cdagechq => vr_tab_cheques(idx).cdagechq
                                ,pr_nrctachq => vr_tab_cheques(idx).nrctachq
                                ,pr_nrcheque => vr_tab_cheques(idx).nrcheque
                                ,pr_nrddigc3 => 1
                                ,pr_vlcheque => vr_tab_cheques(idx).vlcheque
                                ,pr_nrdconta => vr_nrdconta_ver_cheque
                                ,pr_dsdaviso => vr_dsdaviso
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
    			-- Se teve críticas
          IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Se for novo cheque				
          IF vr_tab_cheques(idx).intipchq = 1 THEN
            -- Montar dscheque	
            vr_dscheque := to_char(vr_tab_cheques(idx).dtlibera, 'dd/mm/rrrr') || ';' ||
                           to_char(vr_tab_cheques(idx).dtdcaptu, 'dd/mm/rrrr') || ';' ||
                           to_char(vr_tab_cheques(idx).vlcheque)               || ';' ||
                           vr_tab_cheques(idx).dsdocmc7;
            
            -- Valida custódia
            cust0001.pc_valida_custodia_manual(pr_cdcooper => pr_cdcooper                  --> Cooperativa
                                              ,pr_nrdconta => pr_nrdconta                  --> Número da conta
                                              ,pr_dscheque => vr_dscheque                  --> Codigo do Indexador 
                                              ,pr_tab_cust_cheq => vr_tab_cheque_custodia  --> Tabela com cheques para custódia
                                              ,pr_tab_erro_cust => vr_tab_custodia_erro    --> Tabela de cheques com erros
                                              ,pr_cdcritic => vr_cdcritic                  --> Código da crítica
                                              ,pr_dscritic => vr_dscritic);                --> Descrição da crítica      
			
            -- Se teve críticas
            IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL OR vr_tab_custodia_erro.count > 0 THEN
              IF vr_tab_custodia_erro.count > 0 THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Cheque ' ||
                               vr_tab_custodia_erro(vr_tab_custodia_erro.first).dsdocmc7 || 
                               ' apresentou erro. Erro: ' ||
                               vr_tab_custodia_erro(vr_tab_custodia_erro.first).dscritic;
              END IF;
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END LOOP;
      ELSE 
        -- Verifica se a conta exige assinatura multipla
        INET0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper--Codigo Cooperativa   
                                           ,pr_nrdconta => pr_nrdconta--Conta do Associado
                                           ,pr_idseqttl => pr_idseqttl --Titularidade do Associado
                                           ,pr_cdorigem => 3           --Codigo Origem
                                           ,pr_idastcjt => vr_idastcjt --Codigo 1 exige Ass. Conj.
                                           ,pr_nrcpfcgc => vr_nrcpfcgc --CPF do Rep. Legal
                                           ,pr_nmprimtl => vr_nmprimtl --Nome do Rep. Legal          
                                           ,pr_flcartma => vr_flcartma --Cartao Magnetico conjunta, 0 nao, 1 sim
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Se ocorrer algum erro
        IF nvl(vr_cdcritic,0) <> 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro; 
        END IF;
        	
        -- Se precisar de multiplas assinaturas
        IF vr_idastcjt = 1 AND pr_aprvpend = 0 THEN
          -- Cadastra transacao pendente
          pc_descto_chq_pend_ib(pr_cdcooper    => pr_cdcooper
                               ,pr_nrdconta    => pr_nrdconta
                               ,pr_idseqttl    => pr_idseqttl
                               ,pr_nrcpfope    => pr_nrcpfope
                               ,pr_nrcpfrep    => vr_nrcpfcgc
                               ,pr_tab_cheques => vr_tab_cheques
                               ,pr_dscritic    => vr_dscritic
                               ,pr_retxml      => vr_retxml);
          -- Se ocorrer algum erro
          IF nvl(vr_cdcritic,0) <> 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro; 
          END IF;
        ELSE 
          -- Se não, cadastra bordero normalmente
          pc_desconto_cheque_ib(pr_cdcooper    => pr_cdcooper
                               ,pr_nrdconta    => pr_nrdconta
                               ,pr_idseqttl    => pr_idseqttl
                               ,pr_tab_cheques => vr_tab_cheques
                               ,pr_dscritic    => vr_dscritic
                               ,pr_retxml      => vr_retxml);
          -- Se ocorrer algum erro
          IF nvl(vr_cdcritic,0) <> 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro; 
          END IF;
        END IF;
        
        pr_retxml := vr_retxml;
  		END IF;	
      -- Commita as alterações;
      COMMIT;
  
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic > 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := '<DSMSGERR>' || pr_dscritic || '</DSMSGERR>';
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_verifica_ass_multi_ib: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := '<DSMSGERR>' || pr_dscritic || '</DSMSGERR>';
        ROLLBACK;
    END;
    
  END pc_verifica_ass_multi_ib;
  
END DSCC0002;
/
