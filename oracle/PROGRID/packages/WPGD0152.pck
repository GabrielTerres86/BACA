CREATE OR REPLACE PACKAGE PROGRID.WPGD0152 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0152                     
  --  Sistema  : Rotinas para tela de Cadastro de Curriculos Progrid(WPGD0152)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : 09/11/2017                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Curriculos do Progrid(WPGD0152)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral para listagem de titulares
  PROCEDURE pc_lista_titulares(pr_cdcooper IN crapttl.cdcooper%TYPE --> Código de Cooperativa
                              ,pr_nrdconta IN crapttl.nrdconta%TYPE --> Número da Conta
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
  
  -- Rotina geral para consulta de dados do titular informado
  PROCEDURE pc_carrega_titular(pr_cdcooper IN crapttl.cdcooper%TYPE --> Código de Cooperativa
                              ,pr_nrdconta IN crapttl.nrdconta%TYPE --> Número da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro

  -- Rotina geral da tela WPGD0152
  PROCEDURE pc_wpgd0152(pr_cdcooper     IN crapttl.cdcooper%TYPE --> Código de Cooperativa
                       ,pr_nmrescop     IN crapcop.nmrescop%TYPE --> Nome da Cooperativa
                       ,pr_nrdconta     IN crapttl.nrdconta%TYPE --> Número da Conta
                       ,pr_idseqttl     IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                       ,pr_nmextttl     IN crapttl.nmextttl%TYPE --> Nome do Titular
                       ,pr_nrcpfcgc     IN crapttl.nrcpfcgc%TYPE --> Número do CPF
                       ,pr_mandatos     IN VARCHAR2              --> Informações de Mandatos
                       ,pr_afastamentos IN VARCHAR2              --> Informações de Afastamentos
                       ,pr_capacitacoes IN VARCHAR2              --> Informações de Capacitacoes
                       ,pr_experiencias IN VARCHAR2              --> Informações de Experiencias
                       ,pr_nriniseq     IN INTEGER               --> Registro inicial para pesquisa
                       ,pr_qtregist     IN INTEGER               --> Quantidade de registros por pesquisa
                       ,pr_xmllog   IN VARCHAR2                  --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER              --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2                 --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2                 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);               --> Descricao do Erro

  -- Rotina geral para impressão da consulta de dados do titular informado
  PROCEDURE pc_imprime_titular(pr_cdcooper IN crapttl.cdcooper%TYPE --> Código de Cooperativa
                              ,pr_nrdconta IN crapttl.nrdconta%TYPE --> Número da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro



END WPGD0152;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0152 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0152
  --  Sistema  : Rotinas para tela de Cadastro de Currículos(WPGD0152)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : 09/11/2017                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Curriculos (WPGD0152)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral para listagem de titulares
  PROCEDURE pc_lista_titulares(pr_cdcooper IN crapttl.cdcooper%TYPE --> Código de Cooperativa
                              ,pr_nrdconta IN crapttl.nrdconta%TYPE --> Número da Conta
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro

      CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE) IS

        SELECT ttl.idseqttl
              ,ttl.nmextttl
              ,ass.inpessoa
              ,ass.dtdemiss
          FROM crapttl ttl 
              ,crapass ass
         WHERE ttl.cdcooper(+) = ass.cdcooper
           AND ttl.nrdconta(+) = ass.nrdconta
           AND ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta
           ORDER BY ttl.nmextttl;

      rw_crapttl cr_crapttl%ROWTYPE;
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis locais
      vr_contador INTEGER := 0;

    BEGIN
     
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'titulares', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      FOR rw_crapttl IN cr_crapttl(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta) LOOP
        
        IF rw_crapttl.inpessoa <> 1 THEN
          vr_dscritic := 'Somente contas de Pessoa Física deve ser informada!';
          RAISE vr_exc_saida;
        END IF;

        IF rw_crapttl.dtdemiss IS NOT NULL THEN
          vr_dscritic := 'Cooperado da conta informada não faz mais parte da cooperativa!';
          RAISE vr_exc_saida;
        END IF;

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'titulares', pr_posicao  => 0, pr_tag_nova => 'titular', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'titular', pr_posicao  => vr_contador, pr_tag_nova => 'idseqttl', pr_tag_cont => rw_crapttl.idseqttl, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'titular', pr_posicao  => vr_contador, pr_tag_nova => 'nmextttl', pr_tag_cont => rw_crapttl.nmextttl, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
        
      END LOOP;

    EXCEPTION
      
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;        

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PC_WPGD0152.pc_lista_titulares: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_lista_titulares;

  -- Rotina geral para consulta de dados do titular informado
  PROCEDURE pc_carrega_titular(pr_cdcooper IN crapttl.cdcooper%TYPE --> Código de Cooperativa
                              ,pr_nrdconta IN crapttl.nrdconta%TYPE --> Número da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS           --> Descricao do Erro

      CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE
                       ,pr_idseqttl crapttl.idseqttl%TYPE) IS

        SELECT ttl.idseqttl
              ,ttl.nmextttl
              ,ttl.nrcpfcgc
              ,ttl.cdsexotl
              ,ttl.dtnasttl
              ,ttl.cdestcvl
              ,ttl.grescola
              ,ttl.cdfrmttl
              ,enc.nrcepend
              ,TRIM(replace(UPPER(enc.dsendere),'RUA ','')) AS dsendere
              ,enc.nrendere
              ,enc.complend
              ,enc.nrdoapto
              ,enc.cddbloco
              ,enc.nmbairro
              ,enc.nmcidade
              ,enc.cdufende
          FROM crapttl ttl
              ,crapenc enc
         WHERE ttl.cdcooper = pr_cdcooper
           AND ttl.nrdconta = pr_nrdconta
           AND ttl.idseqttl = pr_idseqttl
           AND ttl.cdcooper = enc.cdcooper
           AND ttl.nrdconta = enc.nrdconta
           AND enc.tpendass = 10;

      rw_crapttl cr_crapttl%ROWTYPE;

      CURSOR cr_craptfc(pr_cdcooper crapttl.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE
                       ,pr_idseqttl crapttl.idseqttl%TYPE) IS
        SELECT tab.dstextab AS nmoperad
              ,tfc.nrdddtfc AS nrdddtfc
              ,TRIM(gene0002.fn_mask(tfc.nrtelefo,'z9999-9999')) AS nrtelefo
              ,tfc.nrdramal AS nrdramal
              ,DECODE(tfc.tptelefo,1,'Residencial',2,'Celular',3,'Comercial',4,'Contato') AS nmpescto
          FROM craptfc tfc
              ,craptab tab 
         WHERE tfc.cdcooper = pr_cdcooper
           AND tfc.nrdconta = pr_nrdconta
           AND tfc.idseqttl = pr_idseqttl
           AND tab.cdcooper(+) = 0            
           AND tab.nmsistem(+) = 'CRED'       
           AND tab.tptabela(+) = 'USUARI'     
           AND tab.cdempres(+) = 11           
           AND tab.cdacesso(+) = 'OPETELEFON'
           AND tab.tpregist(+) = tfc.cdopetfn;
      
      rw_craptfc cr_craptfc%ROWTYPE;
    
      CURSOR cr_crapcem(pr_cdcooper crapttl.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE
                       ,pr_idseqttl crapttl.idseqttl%TYPE) IS

        SELECT cem.dsdemail
              ,cem.secpscto
              ,cem.nmpescto 
          FROM crapcem cem 
         WHERE cem.cdcooper = pr_cdcooper
           AND cem.nrdconta = pr_nrdconta
           AND cem.idseqttl = pr_idseqttl;

      rw_crapcem cr_crapcem%ROWTYPE;
      
      CURSOR cr_crapidp(pr_cdcooper crapttl.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE
                       ,pr_idseqttl crapttl.idseqttl%TYPE) IS
        SELECT edp.nmevento
              ,adp.dtinieve
              ,adp.dtfineve
              ,DECODE(edp.tpevento,10,edp.dscarhor,TO_CHAR(REPLACE(TO_CHAR(pdp.qtcarhor,'FM00D00'),',',':'))) AS dscarhor
              ,ldp.dslocali
          FROM crapedp edp
              ,crapadp adp
              ,crapidp idp
              ,crapcdp cdp
              ,gnappdp pdp
              ,crapldp ldp
         WHERE adp.idstaeve = 4
           AND idp.idevento = 1
           AND idp.cdcooper = pr_cdcooper
           AND idp.nrdconta = pr_nrdconta
           AND idp.idseqttl = pr_idseqttl
           AND idp.tpinseve = 1
           AND idp.idstains = 2
           AND edp.cdevento = adp.cdevento                                                              
           AND edp.idevento = adp.idevento                                                              
           AND edp.cdcooper = adp.cdcooper                                                              
           AND edp.dtanoage = adp.dtanoage                                                              
           AND idp.idevento = edp.idevento                                                              
           AND idp.cdevento = edp.cdevento                                                              
           AND idp.idevento = adp.idevento                                                              
           AND idp.cdevento = adp.cdevento                                                              
           AND idp.nrseqeve = adp.nrseqdig                                                              
           AND cdp.idevento(+) = adp.idevento                                                             
           AND cdp.dtanoage(+) = adp.dtanoage                                                              
           AND cdp.cdcooper(+) = adp.cdcooper                                                              
           AND cdp.cdagenci(+) = adp.cdagenci                                                              
           AND cdp.cdevento(+) = adp.cdevento                                                              
           AND cdp.tpcuseve(+) = 1                                                                         
           AND cdp.cdcuseve(+) = 1                                                                         
           AND pdp.nrcpfcgc(+) = cdp.nrcpfcgc                                                              
           AND pdp.nrpropos(+) = cdp.nrpropos                                                              
           AND adp.cdlocali = ldp.nrseqdig
           AND (((idp.qtfaleve * 100) / DECODE(adp.qtdiaeve,0,1,adp.qtdiaeve)) >= (100 - edp.prfreque))
           AND ldp.cdcooper = DECODE(edp.tpevento,10,ldp.cdcooper,adp.cdcooper);

      rw_crapidp cr_crapidp%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis locais
      vr_contador INTEGER := 0;

    BEGIN

      OPEN cr_crapttl(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_idseqttl => pr_idseqttl);

      FETCH cr_crapttl INTO rw_crapttl ;
      
      IF cr_crapttl%NOTFOUND THEN
        CLOSE cr_crapttl;
        vr_dscritic := 'Registro de Titular não encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapttl;
      END IF;
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      -- DADOS PESSOAIS
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'idseqttl', pr_tag_cont => rw_crapttl.idseqttl, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nmextttl', pr_tag_cont => rw_crapttl.nmextttl, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_crapttl.nrcpfcgc,1), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'cdsexotl', pr_tag_cont => rw_crapttl.cdsexotl, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'dtnasttl', pr_tag_cont => rw_crapttl.dtnasttl, pr_des_erro => vr_dscritic);
      -- ESCOLARIDADE
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'cdestcvl', pr_tag_cont => rw_crapttl.cdestcvl, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'grescola', pr_tag_cont => rw_crapttl.grescola, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'cdfrmttl', pr_tag_cont => rw_crapttl.cdfrmttl, pr_des_erro => vr_dscritic);
      -- ENDERECO
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nrcepend', pr_tag_cont => rw_crapttl.nrcepend, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'dsendere', pr_tag_cont => rw_crapttl.dsendere, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nrendere', pr_tag_cont => rw_crapttl.nrendere, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'complend', pr_tag_cont => rw_crapttl.complend, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nrdoapto', pr_tag_cont => rw_crapttl.nrdoapto, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'cddbloco', pr_tag_cont => rw_crapttl.cddbloco, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nmbairro', pr_tag_cont => rw_crapttl.nmbairro, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_crapttl.nmcidade, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'cdufende', pr_tag_cont => rw_crapttl.cdufende, pr_des_erro => vr_dscritic);

      -- TELEFONES
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'telefones', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      vr_contador := 0;
      FOR rw_craptfc IN cr_craptfc(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_idseqttl => pr_idseqttl) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telefones', pr_posicao  => 0, pr_tag_nova => 'telefone', pr_tag_cont => '', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telefone',  pr_posicao  => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => rw_craptfc.nmoperad, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telefone',  pr_posicao  => vr_contador, pr_tag_nova => 'nrdddtfc', pr_tag_cont => rw_craptfc.nrdddtfc, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telefone',  pr_posicao  => vr_contador, pr_tag_nova => 'nrtelefo', pr_tag_cont => rw_craptfc.nrtelefo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telefone',  pr_posicao  => vr_contador, pr_tag_nova => 'nrdramal', pr_tag_cont => rw_craptfc.nrdramal, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telefone',  pr_posicao  => vr_contador, pr_tag_nova => 'nmpescto', pr_tag_cont => rw_craptfc.nmpescto, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      END LOOP;

      --EMAILS
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'emails', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      vr_contador := 0;
      FOR rw_crapcem IN cr_crapcem(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_idseqttl => pr_idseqttl) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'emails', pr_posicao  => 0, pr_tag_nova => 'email', pr_tag_cont => '', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'email',  pr_posicao  => vr_contador, pr_tag_nova => 'dsdemail', pr_tag_cont => rw_crapcem.dsdemail, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'email',  pr_posicao  => vr_contador, pr_tag_nova => 'secpscto', pr_tag_cont => rw_crapcem.secpscto, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'email',  pr_posicao  => vr_contador, pr_tag_nova => 'nmpescto', pr_tag_cont => rw_crapcem.nmpescto, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      END LOOP;

      --CURSOS DE CAPACITACAO
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'capacitacoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      vr_contador := 0;
      FOR rw_crapidp IN cr_crapidp(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_idseqttl => pr_idseqttl) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacoes', pr_posicao  => 0, pr_tag_nova => 'capacitacao', pr_tag_cont => '', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapidp.nmevento, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'dtinieve', pr_tag_cont => TO_CHAR(rw_crapidp.dtinieve,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'dtfineve', pr_tag_cont => TO_CHAR(rw_crapidp.dtfineve,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'dscarhor', pr_tag_cont => TO_CHAR(rw_crapidp.dscarhor), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'dslocali', pr_tag_cont => rw_crapidp.dslocali, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;                                                                                                                            
      END LOOP;


    EXCEPTION
     
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PC_WPGD0152.pc_carrega_titular: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_carrega_titular;

  -- Rotina geral da tela WPGD0152
  PROCEDURE pc_wpgd0152(pr_cdcooper     IN crapttl.cdcooper%TYPE --> Código de Cooperativa
                       ,pr_nmrescop     IN crapcop.nmrescop%TYPE --> Nome da Cooperativa
                       ,pr_nrdconta     IN crapttl.nrdconta%TYPE --> Número da Conta
                       ,pr_idseqttl     IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                       ,pr_nmextttl     IN crapttl.nmextttl%TYPE --> Nome do Titular
                       ,pr_nrcpfcgc     IN crapttl.nrcpfcgc%TYPE --> Número do CPF
                       ,pr_mandatos     IN VARCHAR2              --> Informações de Mandatos
                       ,pr_afastamentos IN VARCHAR2              --> Informações de Afastamentos
                       ,pr_capacitacoes IN VARCHAR2              --> Informações de Capacitacoes
                       ,pr_experiencias IN VARCHAR2              --> Informações de Experiencias
                       ,pr_nriniseq     IN INTEGER               --> Registro inicial para pesquisa
                       ,pr_qtregist     IN INTEGER               --> Quantidade de registros por pesquisa
                       ,pr_xmllog   IN VARCHAR2                  --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER              --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2                 --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2                 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS             --> Descricao do Erro

      CURSOR cr_crapcce(pr_nrdconta crapttl.nrdconta%TYPE
                       ,pr_nrcpfcgc crapttl.nrcpfcgc%TYPE
                       ,pr_nmextttl crapttl.nmextttl%TYPE
                       ,pr_nmrescop crapcop.nmrescop%TYPE) IS

        SELECT cce.cdcooper
              ,cop.nmrescop 
              ,cce.nrdconta
              ,ttl.nmextttl
              ,cce.idseqttl
              ,ttl.nrcpfcgc
              ,ROW_NUMBER() OVER(ORDER BY cop.nmrescop, cce.nrdconta, ttl.nmextttl) AS nrdseque
          FROM crapcce cce
              ,crapttl ttl
              ,crapcop cop
         WHERE (cce.nrdconta = pr_nrdconta OR pr_nrdconta IS NULL)
           AND cce.cdcooper = ttl.cdcooper
           AND cce.nrdconta = ttl.nrdconta
           AND cce.idseqttl = ttl.idseqttl
           AND (UPPER(TO_CHAR(ttl.nrcpfcgc)) LIKE UPPER('%' || TO_CHAR(pr_nrcpfcgc) || '%') OR pr_nrcpfcgc IS NULL)
           AND (UPPER(ttl.nmextttl) LIKE UPPER('%' || pr_nmextttl || '%') OR pr_nmextttl IS NULL)
           AND cop.cdcooper = cce.cdcooper
           AND (UPPER(cop.nmrescop) LIKE UPPER('%' || pr_nmrescop || '%') OR pr_nmrescop IS NULL)
        ORDER BY cop.nmrescop, cce.nrdconta, ttl.nmextttl;

      rw_crapcce cr_crapcce%ROWTYPE;
    
      -- Consulta Mandatos
      CURSOR cr_crapmcc(pr_cdcooper crapmcc.cdcooper%TYPE
                       ,pr_nrdconta crapmcc.nrdconta%TYPE
                       ,pr_idseqttl crapmcc.idseqttl%TYPE) IS

        SELECT mcc.dtanoage || ';' || mcc.dtiniman  || ';' || mcc.dtfimman  || ';' || mcc.idtipcad AS mandato
          FROM crapmcc mcc
         WHERE mcc.cdcooper = pr_cdcooper
           AND mcc.nrdconta = pr_nrdconta
           AND mcc.idseqttl = pr_idseqttl
        ORDER BY mcc.dtiniman, mcc.dtfimman;

      rw_crapmcc cr_crapmcc%ROWTYPE;

      -- Consulta Intervalos de Datas de mandatos
      CURSOR cr_crapmcc_dat(pr_cdcooper crapmcc.cdcooper%TYPE
                           ,pr_nrdconta crapmcc.nrdconta%TYPE
                           ,pr_idseqttl crapmcc.idseqttl%TYPE
                           ,pr_dtiniman crapmcc.dtiniman%TYPE
                           ,pr_dtfimman crapmcc.dtfimman%TYPE) IS

        SELECT mcc.*
          FROM crapmcc mcc
         WHERE mcc.cdcooper = pr_cdcooper
           AND mcc.nrdconta = pr_nrdconta
           AND mcc.idseqttl = pr_idseqttl
           AND (pr_dtiniman BETWEEN mcc.dtiniman AND mcc.dtfimman
            OR pr_dtfimman BETWEEN mcc.dtiniman AND mcc.dtfimman);

      rw_crapmcc_dat cr_crapmcc_dat%ROWTYPE;

      -- Consulta Afastamentos
      CURSOR cr_crapafc(pr_cdcooper crapafc.cdcooper%TYPE
                       ,pr_nrdconta crapafc.nrdconta%TYPE
                       ,pr_idseqttl crapafc.idseqttl%TYPE) IS

        SELECT afc.dtiniafa || ';' || afc.dtfimafa || ';' || afc.dsmotafa AS afastamento
          FROM crapafc afc
         WHERE afc.cdcooper = pr_cdcooper
           AND afc.nrdconta = pr_nrdconta
           AND afc.idseqttl = pr_idseqttl
      ORDER BY afc.dtiniafa, afc.dtfimafa;

      rw_crapafc cr_crapafc%ROWTYPE;

      -- Consulta intervalos  de datas de afastamentos
      CURSOR cr_crapafc_dat(pr_cdcooper crapafc.cdcooper%TYPE
                           ,pr_nrdconta crapafc.nrdconta%TYPE
                           ,pr_idseqttl crapafc.idseqttl%TYPE
                           ,pr_dtiniafa crapafc.dtiniafa%TYPE
                           ,pr_dtfimafa crapafc.dtfimafa%TYPE) IS

        SELECT afc.*
          FROM crapafc afc
         WHERE afc.cdcooper = pr_cdcooper
           AND afc.nrdconta = pr_nrdconta
           AND afc.idseqttl = pr_idseqttl
           AND (pr_dtiniafa BETWEEN afc.dtiniafa AND afc.dtfimafa
            OR pr_dtfimafa BETWEEN afc.dtiniafa AND afc.dtfimafa);

      rw_crapafc_dat cr_crapafc_dat%ROWTYPE;

      -- Consulta Capacitações
      CURSOR cr_crapccr(pr_cdcooper crapccr.cdcooper%TYPE
                       ,pr_nrdconta crapccr.nrdconta%TYPE
                       ,pr_idseqttl crapccr.idseqttl%TYPE) IS

        SELECT ccr.nmdcurso || ';' || ccr.dtinicur || ';' || ccr.dtfimcur || ';' || GENE0002.fn_mask(TRIM(ccr.qtcarhor),'99:99')  || ';' || ccr.dsloccur AS capacitacao
          FROM crapccr ccr
         WHERE ccr.cdcooper = pr_cdcooper
           AND ccr.nrdconta = pr_nrdconta
           AND ccr.idseqttl = pr_idseqttl
      ORDER BY ccr.dtinicur, ccr.dtfimcur;

      rw_crapccr cr_crapccr%ROWTYPE;

      -- Consulta intervalos de datas de Capacitações
      CURSOR cr_crapccr_dat(pr_cdcooper crapccr.cdcooper%TYPE
                           ,pr_nrdconta crapccr.nrdconta%TYPE
                           ,pr_idseqttl crapccr.idseqttl%TYPE
                           ,pr_dtinicur crapccr.dtinicur%TYPE
                           ,pr_dtfimcur crapccr.dtfimcur%TYPE) IS

        SELECT ccr.*
          FROM crapccr ccr
         WHERE ccr.cdcooper = pr_cdcooper
           AND ccr.nrdconta = pr_nrdconta
           AND ccr.idseqttl = pr_idseqttl
           AND (pr_dtinicur BETWEEN ccr.dtinicur AND ccr.dtfimcur
            OR pr_dtfimcur BETWEEN ccr.dtinicur AND ccr.dtfimcur);

      rw_crapccr_dat cr_crapccr_dat%ROWTYPE;

      -- Consulta Experiências Profissionais
      CURSOR cr_crapecc(pr_cdcooper crapecc.cdcooper%TYPE
                       ,pr_nrdconta crapecc.nrdconta%TYPE
                       ,pr_idseqttl crapecc.idseqttl%TYPE) IS

        SELECT ecc.dsexppro || ';' || ecc.dtiniexp || ';' || ecc.dtfimexp  || ';' || ecc.dslocexp AS experiencia
          FROM crapecc ecc
         WHERE ecc.cdcooper = pr_cdcooper
           AND ecc.nrdconta = pr_nrdconta
           AND ecc.idseqttl = pr_idseqttl
      ORDER BY ecc.dtiniexp, ecc.dtfimexp;

      rw_crapecc cr_crapecc%ROWTYPE;

      -- Consulta intervalos de datas de Experiências Profissionais
      CURSOR cr_crapecc_dat(pr_cdcooper crapecc.cdcooper%TYPE
                           ,pr_nrdconta crapecc.nrdconta%TYPE
                           ,pr_idseqttl crapecc.idseqttl%TYPE
                           ,pr_dtiniexp crapecc.dtiniexp%TYPE
                           ,pr_dtfimexp crapecc.dtfimexp%TYPE) IS

        SELECT ecc.*
          FROM crapecc ecc
         WHERE ecc.cdcooper = pr_cdcooper
           AND ecc.nrdconta = pr_nrdconta
           AND ecc.idseqttl = pr_idseqttl
           AND (pr_dtiniexp BETWEEN ecc.dtiniexp AND ecc.dtfimexp
            OR pr_dtfimexp BETWEEN ecc.dtiniexp AND ecc.dtfimexp);

      rw_crapecc_dat cr_crapecc_dat%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela VARCHAR2(100);
      vr_nmdeacao VARCHAR2(100);
      vr_cddopcao VARCHAR2(100);
      vr_idcokses VARCHAR2(100);
      vr_idsistem INTEGER;
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis locais
      vr_contador INTEGER := 0;
      vr_totregis INTEGER := 0;

      -- variáveis para o retorno de consulta      
      vr_mandato VARCHAR2(32000) := '';
      vr_afastamento VARCHAR2(32000) := '';
      vr_capacitacao VARCHAR2(32000) := '';
      vr_experiencia VARCHAR2(32000) := '';

      -- Arrays
      arr_mandato GENE0002.typ_split;     -- Array de Mandatos
      arr_afastamento GENE0002.typ_split; -- Array de Afastamentos
      arr_capacitacao GENE0002.typ_split; -- Array de Capacitacoes
      arr_experiencia GENE0002.typ_split; -- Array de Experiências

      -- Arrays de Registros
      arr_mandato_reg GENE0002.typ_split;     -- Array de registros de Mandatos
      arr_afastamento_reg GENE0002.typ_split; -- Array de registros de Afastamentos
      arr_capacitacao_reg GENE0002.typ_split; -- Array de registros de Capacitacoes
      arr_experiencia_reg GENE0002.typ_split; -- Array de registros de Experiências

    BEGIN
      prgd0001.pc_extrai_dados_prgd(pr_xml      => pr_retxml
                                   ,pr_cdcooper => vr_cdcooper
                                   ,pr_cdoperad => vr_cdoperad
                                   ,pr_nmdatela => vr_nmdatela
                                   ,pr_nmdeacao => vr_nmdeacao
                                   ,pr_idcokses => vr_idcokses
                                   ,pr_idsistem => vr_idsistem
                                   ,pr_cddopcao => vr_cddopcao
                                   ,pr_dscritic => vr_dscritic);

      -- Verifica se houve critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Validação de Dados obrigatório no Insert e Delete das informações      
      IF vr_cddopcao <> 'C' THEN

        -- Valida Cooperativa
        IF TRIM(pr_cdcooper) IS NULL OR pr_cdcooper = 0 THEN
          vr_dscritic := 'Informe uma Cooperativa.';
        END IF;

        -- Valida conta do cooperado
        IF TRIM(pr_nrdconta) IS NULL OR pr_nrdconta = 0 THEN
          vr_dscritic := 'Informe uma Conta.';
        END IF;

        -- Valida titular
        IF TRIM(pr_idseqttl) IS NULL OR pr_idseqttl = 0 THEN
          vr_dscritic := 'Informe um Titular.';
        END IF;
      END IF;

      IF vr_cddopcao = 'C' THEN -- Consulta de Dados
       
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');
        FOR rw_crapcce IN cr_crapcce(pr_nrdconta => pr_nrdconta, pr_nrcpfcgc => pr_nrcpfcgc, pr_nmextttl => pr_nmextttl, pr_nmrescop => pr_nmrescop) LOOP
          IF ((pr_nriniseq <= rw_crapcce.nrdseque) AND (rw_crapcce.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN

            -- Mandatos
            vr_mandato := '';
            FOR rw_crapmcc IN cr_crapmcc(pr_cdcooper => rw_crapcce.cdcooper,pr_nrdconta => rw_crapcce.nrdconta, pr_idseqttl => rw_crapcce.idseqttl) LOOP
              IF vr_mandato IS NULL THEN
                vr_mandato := rw_crapmcc.mandato;
              ELSE
                vr_mandato := vr_mandato || '+' || rw_crapmcc.mandato;
              END IF;
            END LOOP;

            -- Afastamentos
            vr_afastamento := '';
            FOR rw_crapafc IN cr_crapafc(pr_cdcooper => rw_crapcce.cdcooper,pr_nrdconta => rw_crapcce.nrdconta, pr_idseqttl => rw_crapcce.idseqttl) LOOP
              IF vr_afastamento IS NULL THEN
                vr_afastamento := rw_crapafc.afastamento;
              ELSE
                vr_afastamento := vr_afastamento || '+' || rw_crapafc.afastamento;
              END IF;
            END LOOP;
            
            -- Capacitações
            vr_capacitacao := '';
            FOR rw_crapccr IN cr_crapccr(pr_cdcooper => rw_crapcce.cdcooper,pr_nrdconta => rw_crapcce.nrdconta, pr_idseqttl => rw_crapcce.idseqttl) LOOP
              IF vr_capacitacao IS NULL THEN
                vr_capacitacao := rw_crapccr.capacitacao;
              ELSE
                vr_capacitacao := vr_capacitacao || '+' || rw_crapccr.capacitacao;
              END IF;
            END LOOP;
            
            -- Experiências Profissionais
            vr_experiencia := '';
            FOR rw_crapecc IN cr_crapecc(pr_cdcooper => rw_crapcce.cdcooper,pr_nrdconta => rw_crapcce.nrdconta, pr_idseqttl => rw_crapcce.idseqttl) LOOP
              IF vr_experiencia IS NULL THEN
                vr_experiencia := rw_crapecc.experiencia;
              ELSE
                vr_experiencia := vr_experiencia || '+' || rw_crapecc.experiencia;
              END IF;
            END LOOP;

            -- Informações principais
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'cdcooperPesquisa', pr_tag_cont => rw_crapcce.cdcooper, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapcce.nmrescop, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => GENE0002.fn_mask_conta(rw_crapcce.nrdconta), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'nmextttl', pr_tag_cont => rw_crapcce.nmextttl, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'hdnIdseqttl', pr_tag_cont => rw_crapcce.idseqttl, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => GENE0002.fn_mask_cpf_cnpj(rw_crapcce.nrcpfcgc,1), pr_des_erro => vr_dscritic);
            -- Informações complementares
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'mandato', pr_tag_cont => vr_mandato, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'afastamento', pr_tag_cont => vr_afastamento, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'capacitacao', pr_tag_cont => vr_capacitacao, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'experiencia', pr_tag_cont => vr_experiencia, pr_des_erro => vr_dscritic);

            vr_contador := vr_contador + 1;
          END IF;
          
          vr_totregis := vr_totregis +1;

        END LOOP;

        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

      ELSIF vr_cddopcao = 'E' THEN -- Exclusão de Dados
        
        -- MANDATO
        BEGIN
          DELETE FROM crapmcc WHERE crapmcc.cdcooper = pr_cdcooper
                                AND crapmcc.nrdconta = pr_nrdconta
                                AND crapmcc.idseqttl = pr_idseqttl;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPMCC). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- AFASTAMENTO
        BEGIN
          DELETE FROM crapafc WHERE crapafc.cdcooper = pr_cdcooper
                                AND crapafc.nrdconta = pr_nrdconta
                                AND crapafc.idseqttl = pr_idseqttl;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPAFC). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- CAPACITACAO
        BEGIN
          DELETE FROM crapccr WHERE crapccr.cdcooper = pr_cdcooper
                                AND crapccr.nrdconta = pr_nrdconta
                                AND crapccr.idseqttl = pr_idseqttl;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPCCR). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- EXPERIENCIA PROFISSIONAL
        BEGIN
          DELETE FROM crapecc WHERE crapecc.cdcooper = pr_cdcooper
                                AND crapecc.nrdconta = pr_nrdconta
                                AND crapecc.idseqttl = pr_idseqttl;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPECC). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- PRINCIPAL
        BEGIN
          DELETE FROM crapcce WHERE crapcce.cdcooper = pr_cdcooper
                                AND crapcce.nrdconta = pr_nrdconta
                                AND crapcce.idseqttl = pr_idseqttl;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPCCE). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
      ELSIF vr_cddopcao = 'I' THEN
        -- PRINCIPAL
        BEGIN
          INSERT INTO crapcce(cdcooper, nrdconta, idseqttl, cdoperad, cdprogra, dtatuali)
            VALUES(pr_cdcooper, pr_nrdconta, pr_idseqttl, vr_cdoperad, vr_nmdatela, SYSDATE);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            BEGIN
              UPDATE crapcce
                 SET crapcce.cdoperad = vr_cdoperad
                    ,crapcce.cdprogra = vr_nmdatela
                    ,crapcce.dtatuali = SYSDATE
               WHERE crapcce.cdcooper = pr_cdcooper
                 AND crapcce.nrdconta = pr_nrdconta
                 AND crapcce.idseqttl = pr_idseqttl;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar registro(CRAPCCE). Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;      
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro(CRAPCCE). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;    
        
        -- Antes de inlcuir registros, limpar a tabela com as informações atuais

        -- MANDATO
        BEGIN
          DELETE FROM crapmcc WHERE crapmcc.cdcooper = pr_cdcooper
                                AND crapmcc.nrdconta = pr_nrdconta
                                AND crapmcc.idseqttl = pr_idseqttl;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPMCC). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- AFASTAMENTO
        BEGIN
          DELETE FROM crapafc WHERE crapafc.cdcooper = pr_cdcooper
                                AND crapafc.nrdconta = pr_nrdconta
                                AND crapafc.idseqttl = pr_idseqttl;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPAFC). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- CAPACITACAO
        BEGIN
          DELETE FROM crapccr WHERE crapccr.cdcooper = pr_cdcooper
                                AND crapccr.nrdconta = pr_nrdconta
                                AND crapccr.idseqttl = pr_idseqttl;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPCCR). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- EXPERIENCIA PROFISSIONAL
        BEGIN
          DELETE FROM crapecc WHERE crapecc.cdcooper = pr_cdcooper
                                AND crapecc.nrdconta = pr_nrdconta
                                AND crapecc.idseqttl = pr_idseqttl;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPECC). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Fim Limpeza Tabelas
        
        -- Inserir Mandatos
        arr_mandato := gene0002.fn_quebra_string(pr_string => pr_mandatos,pr_delimit => '#');

        -- Dados de Mandatos
        IF NVL(arr_mandato.count(),0) > 0 THEN

          FOR ind_registro IN arr_mandato.FIRST..arr_mandato.LAST LOOP

            arr_mandato_reg := gene0002.fn_quebra_string(pr_string => arr_mandato(ind_registro),pr_delimit => '|');

            -- Validacoes de Informacoes do Mandatos
            -- Ano de Agenda do Mandato
            IF arr_mandato_reg(1) < 1000 OR arr_mandato_reg(1) IS NULL THEN
              vr_dscritic := 'Informe um ANO AGO válido para o mandato.';
              RAISE vr_exc_saida;
            END IF;

            -- Data de início do Mandato
            IF TO_DATE(arr_mandato_reg(2),'dd/mm/RRRR') > TO_DATE(arr_mandato_reg(3),'dd/mm/RRRR') THEN
              vr_dscritic := 'Data de início do mandato deve ser menor ou igual a data final.';
              RAISE vr_exc_saida;
            END IF;

            -- Tipo do Mandato
            IF arr_mandato_reg(4) = 0 OR arr_mandato_reg(4) > 2 THEN
              vr_dscritic := 'Informe um tipo de mandato válido.';
              RAISE vr_exc_saida;
            END IF;
            -- Fim Validacoes de Informacoes do Mandatos

            -- Verifica se existem datas intercaladas de mandatos
            OPEN cr_crapmcc_dat(pr_cdcooper => pr_cdcooper
                               ,pr_idseqttl => pr_idseqttl
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_dtiniman => TO_DATE(arr_mandato_reg(2),'dd/mm/RRRR')
                               ,pr_dtfimman => TO_DATE(arr_mandato_reg(3),'dd/mm/RRRR'));

            FETCH cr_crapmcc_dat INTO rw_crapmcc_dat;

            IF cr_crapmcc_dat%NOTFOUND THEN
              -- Insere informações de mandato na tabela física
              BEGIN
                INSERT INTO crapmcc(idtipcad, cdcooper, nrdconta, idseqttl, dtiniman, dtfimman, dtanoage, cdoperad, cdprogra, dtatuali)
                  VALUES(arr_mandato_reg(4),pr_cdcooper,pr_nrdconta,pr_idseqttl,TO_DATE(arr_mandato_reg(2),'dd/mm/RRRR'),TO_DATE(arr_mandato_reg(3),'dd/mm/RRRR'),arr_mandato_reg(1),vr_cdoperad,vr_nmdatela,SYSDATE);
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir registro de mandato(CRAPMCC). Erro: ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
              CLOSE cr_crapmcc_dat;
            ELSE
              CLOSE cr_crapmcc_dat;
              vr_dscritic := 'Data não pode coincidir com período de outro mandanto, favor verificar as datas informadas.';
              RAISE vr_exc_saida;              
            END IF;
            -- Fim Insert Mandato

          END LOOP;
        END IF;
        -- Fim Inserir Mandatos

        -- Inserir Afastamentos
        arr_afastamento := gene0002.fn_quebra_string(pr_string => pr_afastamentos,pr_delimit => '#');

        -- Dados de Afastamentos
        IF NVL(arr_afastamento.count(),0) > 0 THEN

          FOR ind_registro IN arr_afastamento.FIRST..arr_afastamento.LAST LOOP

            arr_afastamento_reg := gene0002.fn_quebra_string(pr_string => arr_afastamento(ind_registro),pr_delimit => '|');

            -- Validacoes de Informacoes de Afastamentos

            -- Data de início do afastamento
            IF TO_DATE(arr_afastamento_reg(1),'dd/mm/RRRR') > TO_DATE(arr_afastamento_reg(2),'dd/mm/RRRR') THEN
              vr_dscritic := 'Data de início de afastamento deve ser menor ou igual que data final.';
              RAISE vr_exc_saida;
            END IF;

            -- Motivo do afastamento
            IF TRIM(arr_afastamento_reg(3)) IS NULL THEN
              vr_dscritic := 'Informe o motivo de afastamento.';
              RAISE vr_exc_saida;
            END IF;
            -- Fim Validacoes de Informacoes de Afastamentos

            -- Verifica se existem datas intercaladas de afastamentos
            OPEN cr_crapafc_dat(pr_cdcooper => pr_cdcooper
                               ,pr_idseqttl => pr_idseqttl
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_dtiniafa => TO_DATE(arr_afastamento_reg(1),'dd/mm/RRRR')
                               ,pr_dtfimafa => TO_DATE(arr_afastamento_reg(2),'dd/mm/RRRR'));

            FETCH cr_crapafc_dat INTO rw_crapafc_dat;

            IF cr_crapafc_dat%NOTFOUND THEN
              CLOSE cr_crapafc_dat;
              -- Insere informações de Afastamento na tabela física
              BEGIN
                INSERT INTO crapafc(cdcooper, nrdconta, idseqttl, dtiniafa, dtfimafa, dsmotafa, cdoperad, cdprogra, dtatuali)
                  VALUES(pr_cdcooper,pr_nrdconta,pr_idseqttl,TO_DATE(arr_afastamento_reg(1),'dd/mm/RRRR'),TO_DATE(arr_afastamento_reg(2),'dd/mm/RRRR'),arr_afastamento_reg(3),vr_cdoperad,vr_nmdatela,SYSDATE);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir registro de afastamento(CRAPAFC). Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
              -- Fim insert de Afastamentos
            ELSE
              CLOSE cr_crapafc_dat;
              vr_dscritic := 'Data não pode coincidir com período de outro afastamento, favor verificar as datas informadas.';
              RAISE vr_exc_saida;  
            END IF;
            
          END LOOP;
        END IF;
        -- Fim Inserir Afastamentos

        -- Inserir Capacitações
        arr_capacitacao := gene0002.fn_quebra_string(pr_string => pr_capacitacoes,pr_delimit => '#');

        -- Dados de Afastamentos
        IF NVL(arr_capacitacao.count(),0) > 0 THEN

          FOR ind_registro IN arr_capacitacao.FIRST..arr_capacitacao.LAST LOOP

            arr_capacitacao_reg := gene0002.fn_quebra_string(pr_string => arr_capacitacao(ind_registro),pr_delimit => '|');

            -- Validacoes de Informacoes de Capacitações

            -- Nome do curso
            IF TRIM(arr_capacitacao_reg(1)) IS NULL THEN
              vr_dscritic := 'Informe o nome do curso de capacitação.';
              RAISE vr_exc_saida;
            END IF;

            -- Data de capacitação
            IF TO_DATE(arr_capacitacao_reg(2),'dd/mm/RRRR') > TO_DATE(arr_capacitacao_reg(3),'dd/mm/RRRR') THEN
              vr_dscritic := 'Data de início do curso de capacitação deve ser menor ou igual a data final.';
              RAISE vr_exc_saida;
            END IF;

            -- Carga Horária
            IF arr_capacitacao_reg(4) IS NULL THEN
              vr_dscritic := 'Informe a carga horária do curso de capacitação.';
              RAISE vr_exc_saida;
            END IF;

            -- Local do Curso
            IF arr_capacitacao_reg(5) IS NULL THEN
              vr_dscritic := 'Informe o local do curso de capacitação.';
              RAISE vr_exc_saida;
            END IF;

            -- Fim Validacoes de Informacoes de Capacitações

            -- Verifica se existem datas intercaladas de mandatos
            OPEN cr_crapccr_dat(pr_cdcooper => pr_cdcooper
                               ,pr_idseqttl => pr_idseqttl
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_dtinicur => TO_DATE(arr_capacitacao_reg(2),'dd/mm/RRRR')
                               ,pr_dtfimcur => TO_DATE(arr_capacitacao_reg(3),'dd/mm/RRRR'));

            FETCH cr_crapccr_dat INTO rw_crapccr_dat;

            IF cr_crapccr_dat%NOTFOUND THEN
              CLOSE cr_crapccr_dat;
              -- Insere informações de Capacitação na tabela física
              BEGIN
                INSERT INTO crapccr(cdcooper, nrdconta, idseqttl, nrseqcur, nmdcurso, dtinicur, dtfimcur, qtcarhor, dsloccur, cdoperad, cdprogra, dtatuali)
                  VALUES(pr_cdcooper,pr_nrdconta,pr_idseqttl,(SELECT NVL(MAX(nrseqcur),0) + 1 FROM crapccr), arr_capacitacao_reg(1), TO_DATE(arr_capacitacao_reg(2),'dd/mm/RRRR'), TO_DATE(arr_capacitacao_reg(3),'dd/mm/RRRR'), arr_capacitacao_reg(4), arr_capacitacao_reg(5), vr_cdoperad, vr_nmdatela, SYSDATE);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir registro de capacitação(CRAPCCR). Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
              -- Fim Insere informações de Capacitação na tabela física              
            ELSE
              CLOSE cr_crapccr_dat;
              vr_dscritic := 'Data não pode coincidir com período de outra capacitação, favor verificar as datas informadas.';
              RAISE vr_exc_saida;
            END IF;

          END LOOP;
        END IF;
        -- Fim Inserir Capacitações

        -- Inserir Experiências Profissionais
        arr_experiencia := gene0002.fn_quebra_string(pr_string => pr_experiencias,pr_delimit => '#');

        -- Dados de Experiências Profissionais
        IF NVL(arr_experiencia.count(),0) > 0 THEN

          FOR ind_registro IN arr_experiencia.FIRST..arr_experiencia.LAST LOOP

            arr_experiencia_reg := gene0002.fn_quebra_string(pr_string => arr_experiencia(ind_registro),pr_delimit => '|');

            -- Validacoes de Informacoes sobre Experiências Profissionais

            -- Experiência Profissional
            IF TRIM(arr_experiencia_reg(1)) IS NULL THEN
              vr_dscritic := 'Informe a descrição da experiência profissional.';
              RAISE vr_exc_saida;
            END IF;

            -- Data de Início da Experiência Profissional
            IF TO_DATE(arr_experiencia_reg(2),'dd/mm/RRRR') > TO_DATE(arr_experiencia_reg(3),'dd/mm/RRRR') THEN
              vr_dscritic := 'Data de início da experiência profissional dever ser menor ou igual que data final.';
              RAISE vr_exc_saida;
            END IF;

            -- Local da Experiência Profissional
            IF TRIM(arr_experiencia_reg(4)) IS NULL THEN
              vr_dscritic := 'Informe o local da experiência profissional.';
              RAISE vr_exc_saida;
            END IF;

            -- Fim Validacoes de Informacoes sobre Experiências Profissionais

            OPEN cr_crapecc_dat(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_idseqttl => pr_idseqttl
                               ,pr_dtiniexp => TO_DATE(arr_experiencia_reg(2),'dd/mm/RRRR')
                               ,pr_dtfimexp => TO_DATE(arr_experiencia_reg(3),'dd/mm/RRRR'));

            FETCH cr_crapecc_dat INTO rw_crapecc_dat;

            IF cr_crapecc_dat%NOTFOUND THEN
              CLOSE cr_crapecc_dat;
              -- Insert Experiências Profissionais Tabela Física
              BEGIN
                INSERT INTO crapecc(cdcooper, nrdconta, idseqttl, nrseqexp, dsexppro, dtiniexp, dtfimexp, dslocexp, cdoperad, cdprogra, dtatuali)
                  VALUES(pr_cdcooper,pr_nrdconta,pr_idseqttl,(SELECT NVL(MAX(nrseqexp) + 1,0) FROM crapecc),arr_experiencia_reg(1), TO_DATE(arr_experiencia_reg(2),'dd/mm/RRRR'), TO_DATE(arr_experiencia_reg(3),'dd/mm/RRRR'), arr_experiencia_reg(4),vr_cdoperad,vr_nmdatela, SYSDATE);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir registro de experiência profissional(CRAPECC). Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
              -- Fim Insert Experiências Profissionais Tabela Física
            ELSE
              CLOSE cr_crapecc_dat;
              vr_dscritic := 'Data não pode coincidir com período de outra experiência profissional, favor verificar as datas informadas.';
              RAISE vr_exc_saida;
            END IF;

          END LOOP;
        END IF;
        -- Fim Inserir Experiências Profissionais

      END IF; -- FIM SALVAR DADOS

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;        

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PC_WPGD0152.pc_lista_titulares: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;

  END pc_wpgd0152;

  -- Rotina geral para impressão da consulta de dados do titular informado
  PROCEDURE pc_imprime_titular(pr_cdcooper IN crapttl.cdcooper%TYPE --> Código de Cooperativa
                              ,pr_nrdconta IN crapttl.nrdconta%TYPE --> Número da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro

      CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE
                       ,pr_idseqttl crapttl.idseqttl%TYPE) IS

        SELECT cop.nmrescop
              ,ttl.nmextttl
              ,ttl.nrcpfcgc
              ,DECODE(ttl.cdsexotl,1,'MASCULINO',2,'FEMININO','NAO INFORMADO') AS dssexotl
              ,ttl.dtnasttl
              ,cvl.dsestcvl
              ,esc.dsescola
              ,frm.dsfrmttl
              ,GENE0002.fn_mask_cep(enc.nrcepend) AS nrcepend
              ,TRIM(replace(UPPER(enc.dsendere),'RUA ','')) AS dsendere
              ,enc.nrendere
              ,enc.complend
              ,enc.nrdoapto
              ,enc.cddbloco
              ,enc.nmbairro
              ,enc.nmcidade
              ,enc.cdufende
          FROM crapttl ttl
              ,crapenc enc
              ,crapcop cop
              ,gnetcvl cvl
              ,gngresc esc
              ,gncdfrm frm
         WHERE ttl.cdcooper = pr_cdcooper
           AND ttl.nrdconta = pr_nrdconta
           AND ttl.idseqttl = pr_idseqttl
           AND ttl.cdcooper = enc.cdcooper
           AND ttl.nrdconta = enc.nrdconta
           AND ttl.cdcooper = cop.cdcooper
           AND enc.tpendass = 10
           AND ttl.cdestcvl = cvl.cdestcvl
           AND ttl.grescola = esc.grescola
           AND ttl.cdfrmttl = frm.cdfrmttl;

      rw_crapttl cr_crapttl%ROWTYPE;

      CURSOR cr_craptfc(pr_cdcooper crapttl.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE
                       ,pr_idseqttl crapttl.idseqttl%TYPE) IS
        SELECT tab.dstextab AS nmoperad
              ,tfc.nrdddtfc AS nrdddtfc
              ,TRIM(gene0002.fn_mask(tfc.nrtelefo,'z9999-9999')) AS nrtelefo
              ,tfc.nrdramal AS nrdramal
              ,DECODE(tfc.tptelefo,1,'Residencial',2,'Celular',3,'Comercial',4,'Contato') AS nmpescto
          FROM craptfc tfc
              ,craptab tab 
         WHERE tfc.cdcooper = pr_cdcooper
           AND tfc.nrdconta = pr_nrdconta
           AND tfc.idseqttl = pr_idseqttl
           AND tab.cdcooper(+) = 0            
           AND tab.nmsistem(+) = 'CRED'       
           AND tab.tptabela(+) = 'USUARI'     
           AND tab.cdempres(+) = 11           
           AND tab.cdacesso(+) = 'OPETELEFON'
           AND tab.tpregist(+) = tfc.cdopetfn;
      
      rw_craptfc cr_craptfc%ROWTYPE;
    
      CURSOR cr_crapcem(pr_cdcooper crapttl.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE
                       ,pr_idseqttl crapttl.idseqttl%TYPE) IS

        SELECT cem.dsdemail
              ,cem.secpscto
              ,cem.nmpescto 
          FROM crapcem cem 
         WHERE cem.cdcooper = pr_cdcooper
           AND cem.nrdconta = pr_nrdconta
           AND cem.idseqttl = pr_idseqttl;

      rw_crapcem cr_crapcem%ROWTYPE;
      
      CURSOR cr_crapidp(pr_cdcooper crapttl.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE
                       ,pr_idseqttl crapttl.idseqttl%TYPE) IS
        SELECT edp.nmevento
              ,adp.dtinieve
              ,adp.dtfineve
              ,DECODE(edp.tpevento,10,edp.dscarhor,TO_CHAR(REPLACE(TO_CHAR(pdp.qtcarhor,'FM00D00'),',',':'))) AS dscarhor
              ,ldp.dslocali
          FROM crapedp edp
              ,crapadp adp
              ,crapidp idp
              ,crapcdp cdp
              ,gnappdp pdp
              ,crapldp ldp
         WHERE adp.idstaeve = 4
           AND idp.idevento = 1
           AND idp.cdcooper = pr_cdcooper
           AND idp.nrdconta = pr_nrdconta
           AND idp.idseqttl = pr_idseqttl
           AND idp.tpinseve = 1
           AND idp.idstains = 2
           AND edp.cdevento = adp.cdevento                                                              
           AND edp.idevento = adp.idevento                                                              
           AND edp.cdcooper = adp.cdcooper                                                              
           AND edp.dtanoage = adp.dtanoage                                                              
           AND idp.idevento = edp.idevento                                                              
           AND idp.cdevento = edp.cdevento                                                              
           AND idp.idevento = adp.idevento                                                              
           AND idp.cdevento = adp.cdevento                                                              
           AND idp.nrseqeve = adp.nrseqdig                                                              
           AND cdp.idevento(+) = adp.idevento                                                             
           AND cdp.dtanoage(+) = adp.dtanoage                                                              
           AND cdp.cdcooper(+) = adp.cdcooper                                                              
           AND cdp.cdagenci(+) = adp.cdagenci                                                              
           AND cdp.cdevento(+) = adp.cdevento                                                              
           AND cdp.tpcuseve(+) = 1                                                                         
           AND cdp.cdcuseve(+) = 1                                                                         
           AND pdp.nrcpfcgc(+) = cdp.nrcpfcgc                                                              
           AND pdp.nrpropos(+) = cdp.nrpropos                                                              
           AND adp.cdlocali = ldp.nrseqdig
           AND (((idp.qtfaleve * 100) / DECODE(adp.qtdiaeve,0,1,adp.qtdiaeve)) >= (100 - edp.prfreque))
           AND ldp.cdcooper = DECODE(edp.tpevento,10,ldp.cdcooper,adp.cdcooper);

      rw_crapidp cr_crapidp%ROWTYPE;

      -- Consulta Mandatos
      CURSOR cr_crapmcc(pr_cdcooper crapmcc.cdcooper%TYPE
                       ,pr_nrdconta crapmcc.nrdconta%TYPE
                       ,pr_idseqttl crapmcc.idseqttl%TYPE) IS

        SELECT mcc.dtanoage
              ,mcc.dtiniman
              ,mcc.dtfimman
              ,DECODE(mcc.idtipcad,1,'Conselheiro',2,'Comitê Educativo','Não Informado') AS idtipcad
          FROM crapmcc mcc
         WHERE mcc.cdcooper = pr_cdcooper
           AND mcc.nrdconta = pr_nrdconta
           AND mcc.idseqttl = pr_idseqttl
      ORDER BY mcc.dtiniman, mcc.dtfimman;

      rw_crapmcc cr_crapmcc%ROWTYPE;

       -- Consulta Afastamentos
      CURSOR cr_crapafc(pr_cdcooper crapafc.cdcooper%TYPE
                       ,pr_nrdconta crapafc.nrdconta%TYPE
                       ,pr_idseqttl crapafc.idseqttl%TYPE) IS

        SELECT afc.dtiniafa
              ,afc.dtfimafa
              ,afc.dsmotafa
          FROM crapafc afc
         WHERE afc.cdcooper = pr_cdcooper
           AND afc.nrdconta = pr_nrdconta
           AND afc.idseqttl = pr_idseqttl
      ORDER BY afc.dtiniafa, afc.dtfimafa;

      rw_crapafc cr_crapafc%ROWTYPE;

      -- Consulta Capacitações
      CURSOR cr_crapccr(pr_cdcooper crapccr.cdcooper%TYPE
                       ,pr_nrdconta crapccr.nrdconta%TYPE
                       ,pr_idseqttl crapccr.idseqttl%TYPE) IS

        SELECT ccr.nmdcurso AS nmevento
              ,ccr.dtinicur AS dtinieve
              ,ccr.dtinicur AS dtfineve
              ,GENE0002.fn_mask(TRIM(ccr.qtcarhor),'99:99') AS dscarhor
              ,ccr.dsloccur AS dslocali
          FROM crapccr ccr
         WHERE ccr.cdcooper = pr_cdcooper
           AND ccr.nrdconta = pr_nrdconta
           AND ccr.idseqttl = pr_idseqttl
      ORDER BY ccr.dtinicur, ccr.dtfimcur;

      rw_crapccr cr_crapccr%ROWTYPE;

      -- Consulta Experiências Profissionais
      CURSOR cr_crapecc(pr_cdcooper crapecc.cdcooper%TYPE
                       ,pr_nrdconta crapecc.nrdconta%TYPE
                       ,pr_idseqttl crapecc.idseqttl%TYPE) IS

        SELECT ecc.dsexppro
              ,ecc.dtiniexp
              ,ecc.dtfimexp
              ,ecc.dslocexp
          FROM crapecc ecc
         WHERE ecc.cdcooper = pr_cdcooper
           AND ecc.nrdconta = pr_nrdconta
           AND ecc.idseqttl = pr_idseqttl
      ORDER BY ecc.dtiniexp, ecc.dtfimexp;

      rw_crapecc cr_crapecc%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis locais
      vr_contador INTEGER := 0;

    BEGIN

      OPEN cr_crapttl(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_idseqttl => pr_idseqttl);

      FETCH cr_crapttl INTO rw_crapttl ;
      
      IF cr_crapttl%NOTFOUND THEN
        CLOSE cr_crapttl;
        vr_dscritic := 'Registro de Titular não encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapttl;
      END IF;
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      -- DADOS PESSOAIS
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapttl.nmrescop, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nmextttl', pr_tag_cont => rw_crapttl.nmextttl, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_crapttl.nrcpfcgc,1), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'dssexotl', pr_tag_cont => rw_crapttl.dssexotl, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'dtnasttl', pr_tag_cont => rw_crapttl.dtnasttl, pr_des_erro => vr_dscritic);
      -- ESCOLARIDADE
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'dsestcvl', pr_tag_cont => rw_crapttl.dsestcvl, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'dsescola', pr_tag_cont => rw_crapttl.dsescola, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'dsfrmttl', pr_tag_cont => rw_crapttl.dsfrmttl, pr_des_erro => vr_dscritic);
      -- ENDERECO
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nrcepend', pr_tag_cont => rw_crapttl.nrcepend, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'dsendere', pr_tag_cont => rw_crapttl.dsendere, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nrendere', pr_tag_cont => rw_crapttl.nrendere, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'complend', pr_tag_cont => rw_crapttl.complend, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nrdoapto', pr_tag_cont => rw_crapttl.nrdoapto, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'cddbloco', pr_tag_cont => rw_crapttl.cddbloco, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nmbairro', pr_tag_cont => rw_crapttl.nmbairro, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_crapttl.nmcidade, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'cdufende', pr_tag_cont => rw_crapttl.cdufende, pr_des_erro => vr_dscritic);

      -- TELEFONES
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'telefones', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      vr_contador := 0;
      FOR rw_craptfc IN cr_craptfc(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_idseqttl => pr_idseqttl) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telefones', pr_posicao  => 0, pr_tag_nova => 'telefone', pr_tag_cont => '', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telefone',  pr_posicao  => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => rw_craptfc.nmoperad, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telefone',  pr_posicao  => vr_contador, pr_tag_nova => 'nrdddtfc', pr_tag_cont => rw_craptfc.nrdddtfc, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telefone',  pr_posicao  => vr_contador, pr_tag_nova => 'nrtelefo', pr_tag_cont => rw_craptfc.nrtelefo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telefone',  pr_posicao  => vr_contador, pr_tag_nova => 'nrdramal', pr_tag_cont => rw_craptfc.nrdramal, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telefone',  pr_posicao  => vr_contador, pr_tag_nova => 'nmpescto', pr_tag_cont => rw_craptfc.nmpescto, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      END LOOP;

      --EMAILS
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'emails', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      vr_contador := 0;
      FOR rw_crapcem IN cr_crapcem(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_idseqttl => pr_idseqttl) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'emails', pr_posicao  => 0, pr_tag_nova => 'email', pr_tag_cont => '', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'email',  pr_posicao  => vr_contador, pr_tag_nova => 'dsdemail', pr_tag_cont => rw_crapcem.dsdemail, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'email',  pr_posicao  => vr_contador, pr_tag_nova => 'secpscto', pr_tag_cont => rw_crapcem.secpscto, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'email',  pr_posicao  => vr_contador, pr_tag_nova => 'nmpescto', pr_tag_cont => rw_crapcem.nmpescto, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      END LOOP;

      --MANDATOS
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'mandatos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      vr_contador := 0;
      FOR rw_crapmcc IN cr_crapmcc(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_idseqttl => pr_idseqttl) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mandatos', pr_posicao  => 0, pr_tag_nova => 'mandato', pr_tag_cont => '', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mandato',  pr_posicao  => vr_contador, pr_tag_nova => 'dtanoage', pr_tag_cont => rw_crapmcc.dtanoage, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mandato',  pr_posicao  => vr_contador, pr_tag_nova => 'dtiniman', pr_tag_cont => rw_crapmcc.dtiniman, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mandato',  pr_posicao  => vr_contador, pr_tag_nova => 'dtfimman', pr_tag_cont => rw_crapmcc.dtfimman, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mandato',  pr_posicao  => vr_contador, pr_tag_nova => 'idtipcad', pr_tag_cont => rw_crapmcc.idtipcad, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      END LOOP;

      --AFASTAMENTOS 
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'afastamentos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      vr_contador := 0;
      FOR rw_crapafc IN cr_crapafc(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_idseqttl => pr_idseqttl) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'afastamentos', pr_posicao  => 0, pr_tag_nova => 'afastamento', pr_tag_cont => '', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'afastamento',  pr_posicao  => vr_contador, pr_tag_nova => 'dtiniafa', pr_tag_cont => rw_crapafc.dtiniafa, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'afastamento',  pr_posicao  => vr_contador, pr_tag_nova => 'dtfimafa', pr_tag_cont => rw_crapafc.dtfimafa, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'afastamento',  pr_posicao  => vr_contador, pr_tag_nova => 'dsmotafa', pr_tag_cont => rw_crapafc.dsmotafa, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      END LOOP;

      --CURSOS DE CAPACITACAO (Progrid)
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'capacitacoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      vr_contador := 0;
      FOR rw_crapidp IN cr_crapidp(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_idseqttl => pr_idseqttl) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacoes', pr_posicao  => 0, pr_tag_nova => 'capacitacao', pr_tag_cont => '', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapidp.nmevento, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'dtinieve', pr_tag_cont => TO_CHAR(rw_crapidp.dtinieve,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'dtfineve', pr_tag_cont => TO_CHAR(rw_crapidp.dtfineve,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'dscarhor', pr_tag_cont => rw_crapidp.dscarhor, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'dslocali', pr_tag_cont => rw_crapidp.dslocali, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      END LOOP;

      --CURSOS DE CAPACITACAO (Tela Curriculo)
      FOR rw_crapccr IN cr_crapccr(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_idseqttl => pr_idseqttl) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacoes', pr_posicao  => 0, pr_tag_nova => 'capacitacao', pr_tag_cont => '', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapccr.nmevento, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'dtinieve', pr_tag_cont => TO_CHAR(rw_crapccr.dtinieve,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'dtfineve', pr_tag_cont => TO_CHAR(rw_crapccr.dtfineve,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'dscarhor', pr_tag_cont => rw_crapccr.dscarhor, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'capacitacao',  pr_posicao  => vr_contador, pr_tag_nova => 'dslocali', pr_tag_cont => rw_crapccr.dslocali, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      END LOOP;

      --EXPERIENCIAS PROFISSIONAIS
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'experiencias', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      vr_contador := 0;
      FOR rw_crapecc IN cr_crapecc(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_idseqttl => pr_idseqttl) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'experiencias', pr_posicao  => 0, pr_tag_nova => 'experiencia', pr_tag_cont => '', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'experiencia',  pr_posicao  => vr_contador, pr_tag_nova => 'dsexppro', pr_tag_cont => rw_crapecc.dsexppro, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'experiencia',  pr_posicao  => vr_contador, pr_tag_nova => 'dtiniexp', pr_tag_cont => TO_CHAR(rw_crapecc.dtiniexp,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'experiencia',  pr_posicao  => vr_contador, pr_tag_nova => 'dtfimexp', pr_tag_cont => TO_CHAR(rw_crapecc.dtfimexp,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'experiencia',  pr_posicao  => vr_contador, pr_tag_nova => 'dslocexp', pr_tag_cont => rw_crapecc.dslocexp, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      END LOOP;

    EXCEPTION
     
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PC_WPGD0152.pc_imprime_titular: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_imprime_titular;
  
END WPGD0152;
/
