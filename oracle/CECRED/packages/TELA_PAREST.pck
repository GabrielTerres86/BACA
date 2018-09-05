CREATE OR REPLACE PACKAGE CECRED.TELA_PAREST IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CONPRO
  --  Sistema  : Rotinas utilizadas pela Tela COMPRO
  --  Sigla    : EMPR
  --  Autor    : Daniel Zimmermann
  --  Data     : Mar�o - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela CONPRO
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  TYPE typ_reg_crapcop IS RECORD(
    cdcooper crapcop.cdcooper%TYPE,
    contigen VARCHAR2(10),
    incomite VARCHAR2(10),
    anlautom VARCHAR2(10),
		nmregmpf VARCHAR2(250),
    nmregmpj VARCHAR2(250),
		qtsstime NUMBER(3),
		qtmeschq NUMBER(2),
		qtmeschqal11 NUMBER(2),
		qtmeschqal12 NUMBER(2),
		qtmesest NUMBER(2),
		qtmesemp NUMBER(2),
    nmrescop VARCHAR2(30));

  -- Definicao de tabela que compreende os registros acima declarados
  TYPE typ_tab_crapcop IS TABLE OF typ_reg_crapcop INDEX BY BINARY_INTEGER;

  PROCEDURE pc_lista_cooperativas(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo         
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2); --> Descricao do Erro

  PROCEDURE pc_cons_parametos_web(pr_tlcooper IN crapcop.cdcooper%TYPE
                                 ,pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo  
                                 ,pr_tpprodut IN NUMBER --> Tipo de produto (0 - Empr�stimos e Financiamentos / 1 - Desconto de T�tulos / 4 - Cart�o de Cr�dito)  
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_cons_parametos(pr_cdcooper    IN crapcop.cdcooper%TYPE
                             ,pr_flgativo    IN crapcop.flgativo%TYPE --> Flag Ativo  
                             ,pr_tpprodut IN NUMBER --> Tipo de produto (0 - Empr�stimos e Financiamentos / 1 - Desconto de T�tulos / 4 - Cart�o de Cr�dito)  
                             ,pr_nmdcampo    OUT VARCHAR2
                             ,pr_cdcritic    OUT crapcri.cdcritic%TYPE --> C�d. da cr�tica
                             ,pr_dscritic    OUT crapcri.dscritic%TYPE --> Descri��o da cr�tica
                             ,pr_tab_crapcop OUT typ_tab_crapcop);

  PROCEDURE pc_altera_parametos(pr_tlcooper IN crapcop.cdcooper%TYPE
                               ,pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo  
                               ,pr_tpprodut IN NUMBER --> Tipo de produto (0 - Empr�stimos e Financiamentos / 1 - Desconto de T�tulos / 4 - Cart�o de Cr�dito)  
                               ,pr_incomite IN NUMBER
                               ,pr_contigen IN NUMBER
															 ,pr_anlautom IN NUMBER
                               ,pr_nmregmpf IN VARCHAR2
                               ,pr_nmregmpj IN VARCHAR2
															 ,pr_qtsstime IN NUMBER
															 ,pr_qtmeschq IN NUMBER
															 ,pr_qtmeschqal11 IN NUMBER
															 ,pr_qtmeschqal12 IN NUMBER
                               ,pr_qtmesest IN NUMBER
                               ,pr_qtmesemp IN NUMBER
                               ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                               ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2); --> Pl/Table com os dados de cobran�a de emprestimos

END TELA_PAREST;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PAREST IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_PAREST
  --  Sistema  : Rotinas utilizadas pela Tela PAREST
  --  Sigla    : EMPR
  --  Autor    : Daniel Zimmermann
  --  Data     : Mar�o - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela PAREST
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_lista_cooperativas(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo         
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_cooperativas
    --  Sistema  : Rotinas para listar as cooperativas do sistema
    --  Sigla    : GENE
    --  Autor    : Daniel Zimmermann
    --  Data     : Julho/2015.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de cooperativas no sistema.
    --
    --  Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
    
      -- Cursores
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper,
               INITCAP(cop.nmrescop) nmrescop,
               cop.flgativo
          FROM crapcop cop
         WHERE (cop.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
           AND cop.flgativo = pr_flgativo
         ORDER BY cop.nmrescop;
    
      rw_crapcop cr_crapcop%ROWTYPE;
    
      -- Variaveis locais
      vr_contador INTEGER := 0;
    
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
    BEGIN
    
      FOR rw_crapcop IN cr_crapcop LOOP
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inf',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdcooper',
                               pr_tag_cont => rw_crapcop.cdcooper,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nmrescop',
                               pr_tag_cont => rw_crapcop.nmrescop,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'flgativo',
                               pr_tag_cont => rw_crapcop.flgativo,
                               pr_des_erro => vr_dscritic);
      
        vr_contador := vr_contador + 1;
      
      END LOOP;
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em TELA_PAREST.PC_LISTA_COOPERATIVAS: ' || SQLERRM;
        pr_dscritic := 'Erro geral em TELA_PAREST.PC_LISTA_COOPERATIVAS: ' || SQLERRM;
    END;
  END pc_lista_cooperativas;

  PROCEDURE pc_cons_parametos_web(pr_tlcooper IN crapcop.cdcooper%TYPE
                                 ,pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo  
                                 ,pr_tpprodut IN NUMBER --> Tipo de produto (0 - Empr�stimos e Financiamentos / 1 - Desconto de T�tulos / 4 - Cart�o de Cr�dito)
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_cons_parametos_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel Zimmermann
        Data    : Mar�o/16.                    Ultima atualizacao: 12/04/2018
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para enviar consultar parametros esteira
    
        Observacao: -----
    
        Alteracoes: 12/04/2018 - Inclus�o do Tipo Produto 4 - Cart�o de Cr�dito (Paulo - Supero)
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
      vr_dscritic crapcri.dscritic%TYPE; --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      -- PL/Table
      vr_tab_crapcop TELA_PAREST.typ_tab_crapcop; -- PL/Table com os dados retornados da procedure
      vr_ind_crapcop INTEGER := 0; -- Indice para a PL/Table retornada da procedure
    
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
    
    BEGIN
    
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      -- Se retornou alguma cr�tica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exce��o
        RAISE vr_exc_saida;
      END IF;
    
      TELA_PAREST.pc_cons_parametos(pr_cdcooper    => pr_tlcooper,
                                    pr_flgativo    => pr_flgativo,
                                    pr_tpprodut    => pr_tpprodut,
                                    pr_nmdcampo    => pr_nmdcampo,
                                    pr_cdcritic    => vr_cdcritic,
                                    pr_dscritic    => vr_dscritic,
                                    pr_tab_crapcop => vr_tab_crapcop);
    
      -- Se retornou alguma cr�tica
      IF vr_cdcritic <> 0 OR
         vr_dscritic IS NOT NULL THEN
        -- Levantar exce��o
        RAISE vr_exc_saida;
      END IF;
    
      -- Se PL/Table possuir algum registro
      IF vr_tab_crapcop.count() > 0 THEN
        -- Atribui registro inicial como indice
        vr_ind_crapcop := vr_tab_crapcop.FIRST;
        -- Se existe registro com o indice inicial
        IF vr_tab_crapcop.exists(vr_ind_crapcop) THEN
          -- Criar cabe�alho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Root',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'Dados',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);
        
          LOOP
            
            -- Insere as tags
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'Dados',
                                   pr_posicao  => 0,
                                   pr_tag_nova => 'inf',
                                   pr_tag_cont => NULL,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'cdcooper',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).cdcooper,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nmrescop',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).nmrescop,
                                   pr_des_erro => vr_dscritic);

            IF pr_tpprodut in (0,1) THEN
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'incomite',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).incomite,
                                   pr_des_erro => vr_dscritic);
            END IF;            
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'contigen',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).contigen,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'anlautom',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).anlautom,
                                   pr_des_erro => vr_dscritic);                                   
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nmregmpf',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).nmregmpf,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nmregmpj',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).nmregmpj,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'qtsstime',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).qtsstime,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'qtmeschq',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).qtmeschq,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'qtmeschqal11',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).qtmeschqal11,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'qtmeschqal12',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).qtmeschqal12,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'qtmesest',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).qtmesest,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'qtmesemp',
                                   pr_tag_cont => vr_tab_crapcop(vr_ind_crapcop).qtmesemp,
                                   pr_des_erro => vr_dscritic);

            -- Sai do loop se for o �ltimo registro ou se chegar no n�mero de registros solicitados
            EXIT WHEN(vr_ind_crapcop = vr_tab_crapcop.LAST);
          
            -- Busca pr�ximo indice
            vr_ind_crapcop := vr_tab_crapcop.NEXT(vr_ind_crapcop);
            vr_auxconta    := vr_auxconta + 1;
          
          END LOOP;
          -- Quantidade total de registros
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Root',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'Qtdregis',
                                 pr_tag_cont => vr_tab_crapcop.count(),
                                 pr_des_erro => vr_dscritic);
        END IF;
      ELSE
        -- Atribui cr�tica
        vr_cdcritic := 0;
        vr_dscritic := 'Dados nao encontrados!';
        -- Levanta exce��o
        RAISE vr_exc_saida;
      END IF;
    
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
        pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_cons_parametos_web;

  PROCEDURE pc_cons_parametos(pr_cdcooper    IN crapcop.cdcooper%TYPE
                             ,pr_flgativo    IN crapcop.flgativo%TYPE --> Flag Ativo  
                             ,pr_tpprodut    IN NUMBER --> Tipo de produto (0 - Empr�stimos e Financiamentos / 1 - Desconto de T�tulos / 4 - Cart�o de Cr�dito)
                             ,pr_nmdcampo    OUT VARCHAR2
                             ,pr_cdcritic    OUT crapcri.cdcritic%TYPE --> C�d. da cr�tica
                             ,pr_dscritic    OUT crapcri.dscritic%TYPE --> Descri��o da cr�tica
                             ,pr_tab_crapcop OUT typ_tab_crapcop) IS --> Pl/Table com os dados de cobran�a de emprestimos
  BEGIN
    /* .............................................................................
    
      Programa: pc_cons_parametos
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Daniel Zimmermann
      Data    : Mar�o/16.                    Ultima atualizacao: 12/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina referente a busca parametros esteira
    
      Observacao: -----
    
      Alteracoes: 12/04/2018 - Inclus�o do Tipo de Produto 4 - Cart�o de Cr�dito (Paulo - Supero)
    ..............................................................................*/
    DECLARE
      ----------------------------- VARIAVEIS ---------------------------------
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      vr_ind_crapcop      INTEGER := 0;
      vr_ind_crapcop_desc INTEGER := 0;
      vr_ind_crapcop_crd  INTEGER := 0;
    
      ---------------------------- CURSORES -----------------------------------
      CURSOR cr_crapcop IS
        SELECT DECODE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdcooper => cop.cdcooper,
                                                pr_cdacesso => 'CONTIGENCIA_ESTEIRA_IBRA'),
                      1,
                      'SIM',
                      0,'NAO') contigencia,
               DECODE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdcooper => cop.cdcooper,
                                                pr_cdacesso => 'ENVIA_EMAIL_COMITE'),
                      1,
                      'SIM',
                      0,'NAO') comite,
               DECODE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdcooper => cop.cdcooper,
                                                pr_cdacesso => 'ANALISE_OBRIG_MOTOR_CRED'),
                      1,
                      'SIM',
                      0,'NAO') analise_autom,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
																				 pr_cdcooper => cop.cdcooper,
																				 pr_cdacesso => 'REGRA_ANL_MOTOR_IBRA_PF') nmregmpf,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
																				 pr_cdcooper => cop.cdcooper,
																				 pr_cdacesso => 'REGRA_ANL_MOTOR_IBRA_PJ') nmregmpj,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
																				 pr_cdcooper => cop.cdcooper,
																				 pr_cdacesso => 'TIME_RESP_MOTOR_IBRA') qtsstime,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
																				 pr_cdcooper => cop.cdcooper,
																				 pr_cdacesso => 'QTD_MES_HIST_DEV_CHEQUES') qtmeschq,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
																				 pr_cdcooper => cop.cdcooper,
																				 pr_cdacesso => 'QTD_MES_HIST_DEV_CH_AL11') qtmeschqal11,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
																				 pr_cdcooper => cop.cdcooper,
																				 pr_cdacesso => 'QTD_MES_HIST_DEV_CH_AL12') qtmeschqal12,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
																				 pr_cdcooper => cop.cdcooper,
																				 pr_cdacesso => 'QTD_MES_HIST_ESTOUROS') qtmesest,																				 
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
																				 pr_cdcooper => cop.cdcooper,
																				 pr_cdacesso => 'QTD_MES_HIST_EMPREST') qtmesemp,
               cdcooper,
               Initcap(nmrescop) nmrescop
        
          FROM crapcop cop
         WHERE (NVL(pr_cdcooper, 0) = 0 OR cop.cdcooper = pr_cdcooper)
           AND cop.flgativo = pr_flgativo
         ORDER BY cop.cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
    
      CURSOR cr_crapcop_desc IS
        SELECT DECODE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdcooper => cop.cdcooper,
                                                pr_cdacesso => 'CONTIGENCIA_ESTEIRA_DESC'),
                      1,
                      'SIM',
                      0,'NAO') contigencia,
               DECODE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdcooper => cop.cdcooper,
                                                pr_cdacesso => 'ENVIA_EMAIL_COMITE_DESC'),
                      1,
                      'SIM',
                      0,'NAO') comite,
               DECODE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdcooper => cop.cdcooper,
                                                pr_cdacesso => 'ANALISE_OBRIG_MOTOR_DESC'),
                      1,
                      'SIM',
                      0,'NAO') analise_autom,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'REGRA_ANL_MOTOR_PF_DESC') nmregmpf,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'REGRA_ANL_MOTOR_PJ_DESC') nmregmpj,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'TIME_RESP_MOTOR_DESC') qtsstime,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'QTD_MES_HIST_DEVCHQ_DESC') qtmeschq,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'QTD_MES_HIST_DC_A11_DESC') qtmeschqal11,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'QTD_MES_HIST_DC_A12_DESC') qtmeschqal12,                                                    
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'QTD_MES_HIST_EST_DESC') qtmesest,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'QTD_MES_HIST_EMPRES_DESC') qtmesemp,
               cdcooper,
               Initcap(nmrescop) nmrescop

          FROM crapcop cop
         WHERE (NVL(pr_cdcooper, 0) = 0 OR cop.cdcooper = pr_cdcooper)
           AND cop.flgativo = pr_flgativo
         ORDER BY cop.cdcooper;
      rw_crapcop_desc cr_crapcop_desc%ROWTYPE;
      
      CURSOR cr_crapcop_crd IS
        SELECT DECODE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdcooper => cop.cdcooper,
                                                pr_cdacesso => 'CONTIGENCIA_ESTEIRA_CRD'),
                      1,
                      'SIM',
                      0,'NAO') contigencia,
               DECODE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdcooper => cop.cdcooper,
                                                pr_cdacesso => 'ANALISE_OBRIG_MOTOR_CRD'),
                      1,
                      'SIM',
                      0,'NAO') analise_autom,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'REGRA_ANL_IBRA_CRD') nmregmpf,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'REGRA_ANL_IBRA_CRD_PJ') nmregmpj,                          
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'TIME_RESP_MOTOR_CRD') qtsstime,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'QTD_MES_HIST_DEVCHQ_CRD') qtmeschq,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'QTD_MES_HIST_DCH_A11_CRD') qtmeschqal11,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'QTD_MES_HIST_DCH_A12_CRD') qtmeschqal12,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'QTD_MES_HIST_EST_CRD') qtmesest,
               GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => cop.cdcooper,
                                         pr_cdacesso => 'QTD_MES_HIST_EMPRES_CRD') qtmesemp,
               cdcooper,
               Initcap(nmrescop) nmrescop

          FROM crapcop cop
         WHERE (NVL(pr_cdcooper, 0) = 0 OR cop.cdcooper = pr_cdcooper)
           AND cop.flgativo = pr_flgativo
         ORDER BY cop.cdcooper;
      rw_crapcop_crd cr_crapcop_crd%ROWTYPE;

    BEGIN
    
      ---------------------------------- VALIDACOES INICIAIS --------------------------
    
      -- Abre cursor para atribuir os registros encontrados na PL/Table
      IF pr_tpprodut = 0 THEN -- Se o tipo de produto for empr�stimos ou financioamentos
        FOR rw_crapcop IN cr_crapcop LOOP
            
        IF rw_crapcop.comite IS NULL THEN
          continue;
        END IF;
          
        -- Incrementa contador para utilizar como indice da PL/Table
        vr_ind_crapcop := vr_ind_crapcop + 1;
          
        pr_tab_crapcop(vr_ind_crapcop).cdcooper := rw_crapcop.cdcooper;
        pr_tab_crapcop(vr_ind_crapcop).nmrescop := rw_crapcop.nmrescop;
        pr_tab_crapcop(vr_ind_crapcop).incomite := rw_crapcop.comite;
        pr_tab_crapcop(vr_ind_crapcop).contigen := rw_crapcop.contigencia;
        pr_tab_crapcop(vr_ind_crapcop).anlautom := rw_crapcop.analise_autom;
        pr_tab_crapcop(vr_ind_crapcop).nmregmpf := rw_crapcop.nmregmpf;
        pr_tab_crapcop(vr_ind_crapcop).nmregmpj := rw_crapcop.nmregmpj;
        pr_tab_crapcop(vr_ind_crapcop).qtsstime := rw_crapcop.qtsstime;								
        pr_tab_crapcop(vr_ind_crapcop).qtmeschq := rw_crapcop.qtmeschq;								
        pr_tab_crapcop(vr_ind_crapcop).qtmeschqal11 := rw_crapcop.qtmeschqal11;
        pr_tab_crapcop(vr_ind_crapcop).qtmeschqal12 := rw_crapcop.qtmeschqal12;
        pr_tab_crapcop(vr_ind_crapcop).qtmesest := rw_crapcop.qtmesest;								
        pr_tab_crapcop(vr_ind_crapcop).qtmesemp := rw_crapcop.qtmesemp;																				
          
        END LOOP;
      ELSIF pr_tpprodut = 1 THEN -- Desconto de T�tulos
        FOR rw_crapcop_desc IN cr_crapcop_desc LOOP
          
          IF rw_crapcop_desc.comite IS NULL THEN
            continue;
          END IF;
        
          -- Incrementa contador para utilizar como indice da PL/Table
          vr_ind_crapcop_desc := vr_ind_crapcop_desc + 1;
        
          pr_tab_crapcop(vr_ind_crapcop_desc).cdcooper := rw_crapcop_desc.cdcooper;
          pr_tab_crapcop(vr_ind_crapcop_desc).nmrescop := rw_crapcop_desc.nmrescop;
          pr_tab_crapcop(vr_ind_crapcop_desc).incomite := rw_crapcop_desc.comite;
          pr_tab_crapcop(vr_ind_crapcop_desc).contigen := rw_crapcop_desc.contigencia;
          pr_tab_crapcop(vr_ind_crapcop_desc).anlautom := rw_crapcop_desc.analise_autom;
          pr_tab_crapcop(vr_ind_crapcop_desc).nmregmpf := rw_crapcop_desc.nmregmpf;
          pr_tab_crapcop(vr_ind_crapcop_desc).nmregmpj := rw_crapcop_desc.nmregmpj;
          pr_tab_crapcop(vr_ind_crapcop_desc).qtsstime := rw_crapcop_desc.qtsstime;               
          pr_tab_crapcop(vr_ind_crapcop_desc).qtmeschq := rw_crapcop_desc.qtmeschq;               
          pr_tab_crapcop(vr_ind_crapcop_desc).qtmeschqal11 := rw_crapcop_desc.qtmeschqal11;
          pr_tab_crapcop(vr_ind_crapcop_desc).qtmeschqal12 := rw_crapcop_desc.qtmeschqal12;
          pr_tab_crapcop(vr_ind_crapcop_desc).qtmesest := rw_crapcop_desc.qtmesest;               
          pr_tab_crapcop(vr_ind_crapcop_desc).qtmesemp := rw_crapcop_desc.qtmesemp;                                       
        
		END LOOP;
      ELSIF pr_tpprodut = 4 THEN --Cart�o de Cr�dito
        FOR rw_crapcop_crd IN cr_crapcop_crd LOOP

          -- Incrementa contador para utilizar como indice da PL/Table
          vr_ind_crapcop_crd := vr_ind_crapcop_crd + 1;

          pr_tab_crapcop(vr_ind_crapcop_crd).cdcooper := rw_crapcop_crd.cdcooper;
          pr_tab_crapcop(vr_ind_crapcop_crd).nmrescop := rw_crapcop_crd.nmrescop;
          pr_tab_crapcop(vr_ind_crapcop_crd).contigen := rw_crapcop_crd.contigencia;
          pr_tab_crapcop(vr_ind_crapcop_crd).anlautom := rw_crapcop_crd.analise_autom;
          pr_tab_crapcop(vr_ind_crapcop_crd).nmregmpf := rw_crapcop_crd.nmregmpf;
          pr_tab_crapcop(vr_ind_crapcop_crd).nmregmpj := rw_crapcop_crd.nmregmpj;
          pr_tab_crapcop(vr_ind_crapcop_crd).qtsstime := rw_crapcop_crd.qtsstime;
          pr_tab_crapcop(vr_ind_crapcop_crd).qtmeschq := rw_crapcop_crd.qtmeschq;
          pr_tab_crapcop(vr_ind_crapcop_crd).qtmeschqal11 := rw_crapcop_crd.qtmeschqal11;
          pr_tab_crapcop(vr_ind_crapcop_crd).qtmeschqal12 := rw_crapcop_crd.qtmeschqal12;
          pr_tab_crapcop(vr_ind_crapcop_crd).qtmesest := rw_crapcop_crd.qtmesest;
          pr_tab_crapcop(vr_ind_crapcop_crd).qtmesemp := rw_crapcop_crd.qtmesemp;

        END LOOP;

      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se possui c�digo de cr�tica e n�o foi informado a descri��o
        IF vr_cdcritic <> 0 AND
           TRIM(vr_dscritic) IS NULL THEN
          -- Busca descri��o da cr�tica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
      
        -- Atribui exce��o para os parametros de cr�tica
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        -- Atribui exce��o para os parametros de cr�tica
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na TELA_PAREST.pc_cons_parametos: ' || SQLERRM;
      
    END;
  END pc_cons_parametos;

  PROCEDURE pc_altera_parametos(pr_tlcooper IN crapcop.cdcooper%TYPE
                               ,pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo  
                               ,pr_tpprodut IN NUMBER --> Tipo de produto (0 - Empr�stimos e Financiamentos / 1 - Desconto de T�tulos / 4 - Cart�o de Cr�dito)  
                               ,pr_incomite IN NUMBER
                               ,pr_contigen IN NUMBER
															 ,pr_anlautom IN NUMBER
															 ,pr_nmregmpf IN VARCHAR2
                               ,pr_nmregmpj IN VARCHAR2
															 ,pr_qtsstime IN NUMBER
															 ,pr_qtmeschq IN NUMBER
															 ,pr_qtmeschqal11 IN NUMBER
															 ,pr_qtmeschqal12 IN NUMBER
                               ,pr_qtmesest IN NUMBER
                               ,pr_qtmesemp IN NUMBER
                               ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                               ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS --> Pl/Table com os dados de cobran�a de emprestimos
  BEGIN
    /* .............................................................................
    
      Programa: pc_altera_parametos
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Daniel Zimmermann
      Data    : Mar�o/16.                    Ultima atualizacao: 12/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina referente a altera��o de parametros esteira
    
      Observacao: -----
    
      Alteracoes: 12/04/2018 - Inclus�o do Tipo de Produto 4 - Cart�o de Cr�dito (Paulo - Supero)
    ..............................................................................*/
    DECLARE
      ----------------------------- VARIAVEIS ---------------------------------
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      vr_possui_reg BOOLEAN;
    
      vr_cd_incomite crapprm.cdacesso%TYPE;
      vr_cd_contigen crapprm.cdacesso%TYPE;
      vr_cd_anlautom crapprm.cdacesso%TYPE;
      vr_cd_nmregmpf crapprm.cdacesso%TYPE;
      vr_cd_nmregmpj crapprm.cdacesso%TYPE;
      vr_cd_qtsstime crapprm.cdacesso%TYPE;
      vr_cd_qtmeschq crapprm.cdacesso%TYPE;
      vr_cd_qtmeschqal11 crapprm.cdacesso%TYPE;
      vr_cd_qtmeschqal12 crapprm.cdacesso%TYPE;
      vr_cd_qtmesest crapprm.cdacesso%TYPE;
      vr_cd_qtmesemp crapprm.cdacesso%TYPE;

      ---------------------------- CURSORES -----------------------------------
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop cop
         WHERE (NVL(pr_tlcooper, 0) = 0 OR cop.cdcooper = pr_tlcooper)
           AND cop.flgativo = pr_flgativo
         ORDER BY cop.cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
    
    BEGIN
    
      ---------------------------------- VALIDACOES INICIAIS --------------------------
    
      vr_possui_reg := FALSE;
    
      IF pr_tpprodut = 0 THEN --  Se o tipo de produto for empr�stimos e financiamentos
        vr_cd_incomite := 'ENVIA_EMAIL_COMITE';
        vr_cd_contigen := 'CONTIGENCIA_ESTEIRA_IBRA';
        vr_cd_anlautom := 'ANALISE_OBRIG_MOTOR_CRED';
        vr_cd_nmregmpf := 'REGRA_ANL_MOTOR_IBRA_PF';
        vr_cd_nmregmpj := 'REGRA_ANL_MOTOR_IBRA_PJ';
        vr_cd_qtsstime := 'TIME_RESP_MOTOR_IBRA';
        vr_cd_qtmeschq := 'QTD_MES_HIST_DEV_CHEQUES';
        vr_cd_qtmeschqal11 := 'QTD_MES_HIST_DEV_CH_AL11';
        vr_cd_qtmeschqal12 := 'QTD_MES_HIST_DEV_CH_AL12'; 
        vr_cd_qtmesest := 'QTD_MES_HIST_ESTOUROS';
        vr_cd_qtmesemp := 'QTD_MES_HIST_EMPREST';
      ELSIF pr_tpprodut = 1 THEN -- desconto de t�tulos
        vr_cd_incomite := 'ENVIA_EMAIL_COMITE_DESC'; 
        vr_cd_contigen := 'CONTIGENCIA_ESTEIRA_DESC'; 
        vr_cd_anlautom := 'ANALISE_OBRIG_MOTOR_DESC';
        vr_cd_nmregmpf := 'REGRA_ANL_MOTOR_PF_DESC';
        vr_cd_nmregmpj := 'REGRA_ANL_MOTOR_PJ_DESC';
        vr_cd_qtsstime := 'TIME_RESP_MOTOR_DESC';
        vr_cd_qtmeschq := 'QTD_MES_HIST_DEVCHQ_DESC';
        vr_cd_qtmeschqal11 := 'QTD_MES_HIST_DC_A11_DESC';
        vr_cd_qtmeschqal12 := 'QTD_MES_HIST_DC_A12_DESC';
        vr_cd_qtmesest := 'QTD_MES_HIST_EST_DESC';
        vr_cd_qtmesemp := 'QTD_MES_HIST_EMPRES_DESC';
      ELSIF pr_tpprodut = 4 THEN -- Cart�o de Cr�dito
        vr_cd_contigen := 'CONTIGENCIA_ESTEIRA_CRD'; 
        vr_cd_anlautom := 'ANALISE_OBRIG_MOTOR_CRD';
        vr_cd_nmregmpf := 'REGRA_ANL_IBRA_CRD';
        vr_cd_nmregmpj := 'REGRA_ANL_IBRA_CRD_PJ';
        vr_cd_qtsstime := 'TIME_RESP_MOTOR_CRD';
        vr_cd_qtmeschq := 'QTD_MES_HIST_DEVCHQ_CRD';
        vr_cd_qtmeschqal11 := 'QTD_MES_HIST_DCH_A11_CRD';
        vr_cd_qtmeschqal12 := 'QTD_MES_HIST_DCH_A12_CRD';
        vr_cd_qtmesest := 'QTD_MES_HIST_EST_CRD';
        vr_cd_qtmesemp := 'QTD_MES_HIST_EMPRES_CRD';
      END IF;

      -- Abre cursor para atribuir os registros encontrados na PL/Table
      FOR rw_crapcop IN cr_crapcop LOOP
      
        vr_possui_reg := TRUE;
      
        IF pr_tpprodut IN (0,1) THEN
          BEGIN
            UPDATE crapprm prm
             SET prm.dsvlrprm = pr_incomite
             WHERE prm.nmsistem = 'CRED'
             AND prm.cdcooper = rw_crapcop.cdcooper
               AND prm.cdacesso = vr_cd_incomite;
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela crapprm (1). ' || SQLERRM;
            --Sair do programa
            RAISE vr_exc_saida;
          END;

        END IF;

		    BEGIN
          UPDATE crapprm prm
             SET prm.dsvlrprm = pr_contigen
           WHERE prm.nmsistem = 'CRED'
             AND prm.cdcooper = rw_crapcop.cdcooper
             AND prm.cdacesso = vr_cd_contigen;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela crapprm (2). ' || SQLERRM;
            --Sair do programa
            RAISE vr_exc_saida;
        END;
        
        IF (NVL(pr_tlcooper, 0) = 0) AND  --No caso de cart�es, para todas as cooperativas
           (pr_tpprodut = 4)         THEN --existira esse campo em interface.
          BEGIN
			UPDATE crapprm prm
              SET prm.dsvlrprm = pr_anlautom
            WHERE prm.nmsistem = 'CRED'
              AND prm.cdcooper = rw_crapcop.cdcooper
              AND prm.cdacesso = vr_cd_anlautom;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela crapprm (3). ' || SQLERRM;
              --Sair do programa
              RAISE vr_exc_saida;
          END;
        END IF;
        
	      IF NVL(pr_tlcooper, 0) <> 0 THEN
					BEGIN
						UPDATE crapprm prm
             SET prm.dsvlrprm = pr_anlautom
						 WHERE prm.nmsistem = 'CRED'
							 AND prm.cdcooper = rw_crapcop.cdcooper
             AND prm.cdacesso = vr_cd_anlautom;
					EXCEPTION
						WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela crapprm (3). ' || SQLERRM;
							--Sair do programa
							RAISE vr_exc_saida;
					END;
	        
					BEGIN
						UPDATE crapprm prm
               SET prm.dsvlrprm = pr_nmregmpf
						 WHERE prm.nmsistem = 'CRED'
							 AND prm.cdcooper = rw_crapcop.cdcooper
               AND prm.cdacesso = vr_cd_nmregmpf;
					EXCEPTION
						WHEN OTHERS THEN
                            vr_dscritic := 'Erro ao atualizar tabela crapprm (4). ' || SQLERRM;
							--Sair do programa
							RAISE vr_exc_saida;
					END;

					BEGIN
						UPDATE crapprm prm
							 SET prm.dsvlrprm = pr_nmregmpj
						 WHERE prm.nmsistem = 'CRED'
							 AND prm.cdcooper = rw_crapcop.cdcooper
							 AND prm.cdacesso = vr_cd_nmregmpj;
					EXCEPTION
						WHEN OTHERS THEN
							vr_dscritic := 'Erro ao atualizar tabela crapprm (5). ' || SQLERRM;
							--Sair do programa
							RAISE vr_exc_saida;
					END;
						      
					BEGIN
						UPDATE crapprm prm
							 SET prm.dsvlrprm = pr_qtsstime
						 WHERE prm.nmsistem = 'CRED'
							 AND prm.cdcooper = rw_crapcop.cdcooper
                             AND prm.cdacesso = vr_cd_qtsstime;
					EXCEPTION
						WHEN OTHERS THEN
							vr_dscritic := 'Erro ao atualizar tabela crapprm (6). ' || SQLERRM;
							--Sair do programa
							RAISE vr_exc_saida;
					END;

					BEGIN
						UPDATE crapprm prm
							 SET prm.dsvlrprm = pr_qtmeschq
						 WHERE prm.nmsistem = 'CRED'
							 AND prm.cdcooper = rw_crapcop.cdcooper
               AND prm.cdacesso = vr_cd_qtmeschq;
					EXCEPTION
						WHEN OTHERS THEN
							vr_dscritic := 'Erro ao atualizar tabela crapprm (7). ' || SQLERRM;
							--Sair do programa
							RAISE vr_exc_saida;
					END;

					BEGIN
						UPDATE crapprm prm
							 SET prm.dsvlrprm = pr_qtmeschqal11
						 WHERE prm.nmsistem = 'CRED'
							 AND prm.cdcooper = rw_crapcop.cdcooper
							 AND prm.cdacesso = vr_cd_qtmeschqal11;
					EXCEPTION
						WHEN OTHERS THEN
							vr_dscritic := 'Erro ao atualizar tabela crapprm (8). ' || SQLERRM;
							--Sair do programa
							RAISE vr_exc_saida;
					END;

					BEGIN
						UPDATE crapprm prm
							 SET prm.dsvlrprm = pr_qtmeschqal12
						 WHERE prm.nmsistem = 'CRED'
							 AND prm.cdcooper = rw_crapcop.cdcooper
							 AND prm.cdacesso = vr_cd_qtmeschqal12;
					EXCEPTION
						WHEN OTHERS THEN
							vr_dscritic := 'Erro ao atualizar tabela crapprm (9). ' || SQLERRM;
							--Sair do programa
							RAISE vr_exc_saida;
					END;

					BEGIN
						UPDATE crapprm prm
							 SET prm.dsvlrprm = pr_qtmesest
						 WHERE prm.nmsistem = 'CRED'
							 AND prm.cdcooper = rw_crapcop.cdcooper
               AND prm.cdacesso = vr_cd_qtmesest;
					EXCEPTION
						WHEN OTHERS THEN
							vr_dscritic := 'Erro ao atualizar tabela crapprm (8). ' || SQLERRM;
							--Sair do programa
							RAISE vr_exc_saida;
					END;

					BEGIN
						UPDATE crapprm prm
							 SET prm.dsvlrprm = pr_qtmesemp
						 WHERE prm.nmsistem = 'CRED'
							 AND prm.cdcooper = rw_crapcop.cdcooper
               AND prm.cdacesso = vr_cd_qtmesemp;
					EXCEPTION
						WHEN OTHERS THEN
							vr_dscritic := 'Erro ao atualizar tabela crapprm (9). ' || SQLERRM;
							--Sair do programa
							RAISE vr_exc_saida;
					END;
        END IF;				
      END LOOP;
    
      COMMIT;
    
      IF vr_possui_reg = FALSE THEN
      
        pr_des_erro := 'NOK';
      
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || 'Registro nao Encontrado' ||
                                       '</Erro></Root>');
      END IF;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se possui c�digo de cr�tica e n�o foi informado a descri��o
        IF vr_cdcritic <> 0 AND
           TRIM(vr_dscritic) IS NULL THEN
          -- Busca descri��o da cr�tica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
      
        -- Atribui exce��o para os parametros de cr�tica
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        pr_des_erro := 'NOK';
      
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
      
      WHEN OTHERS THEN
        -- Atribui exce��o para os parametros de cr�tica
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na TELA_PAREST.pc_altera_parametos: ' || SQLERRM;
      
        pr_des_erro := 'NOK';
      
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
      
    END;
  END pc_altera_parametos;

END TELA_PAREST;
/
