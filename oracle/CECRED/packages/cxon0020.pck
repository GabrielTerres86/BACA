CREATE OR REPLACE PACKAGE CECRED.cxon0020 AS

/*..............................................................................

   Programa: cxon0020                        Antigo: dbo/b1crap20.p
   Sistema : Caixa On-line
   Sigla   : CRED
   Autor   : Elton
   Data    : Outubro/2011                      Ultima atualizacao: 25/04/2016

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Transferencia e deposito entre cooperativas.

   Alteracoes: 23/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                17/04/2007 - Critica quando nao encontra cidade para
                             determinada agencia bancaria (Elton).

                23/04/2007 - Alterado para nao deixar fixo as informacoes do
                             Banco e Agencia do remetente (Elton).

                10/05/2007 - Criticar situacao da agencia destino  (Mirtes)

                29/01/2008 - Mostra o PAC do cooperado na autenticacao (Elton).

                19/02/2008 - Retirada critica que nao permite utilizacao de
                             TED's (Elton/Evandro).

                17/04/2008 - Tratamento horario TED (Diego)
                             Validacao de operador para TED (Evandro).

                22/12/2008 - Ajustes para unificacao dos bancos de dados
                             (Evandro).

                25/03/2009 - Retirado comentario dos campos craptvl.cdoperad e
                             craptvl.cdopeaut;
                           - Incluida critica no campo CPF/CNPJ do destinatario
                             do TED (Elton).

                25/05/2009 - Alteracao CDOPERAD (Kbase).

                26/08/2009 - Substituicao do campo banco/agencia da COMPE,
                             para o banco/agencia COMPE de DOC (cdagedoc e
                             cdbandoc) - (Sidnei - Precise).

                23/10/2009 - Alterada a procedure atualiza-doc-ted para enviar
                             TED�s por mensageria - SPB (Fernando).

                04/05/2010 - Criar lote 11000 + caixa sempre que uma transa��o
                             for efetuada (Fernando).

                31/05/2010 - Criada procedure valida-saldo para alertar quando
                             o saldo + limite de credito do remetente for menor
                             que o valor a ser enviado no DOC/TED (Fernando).

                24/06/2010 - Criticar o envio de TEDs entre cooperativas do
                             Sistema CECRED (Fernando).

                26/06/2010 - Ajustar chamada da b1wgen0046 para os TEDs via
                             SPB.
                             Criticar envio de TED C debito em conta com mesma
                             titularidade. Solicitar envio do TED D (Fernando).

                11/08/2010 - Retirar criticas da procedure atualiza-doc-ted
                             e colocar na procedure valida-valores (Fernando).

                24/09/2010 - Incluido parametro p-cod-id-transf (Guilherme).

                29/03/2011 - Incluido validacao de valores na verifica-operador
                             (Guilherme).

                17/05/2011 - Ajuste no comprovante de TED/DOC (Gabriel).

                25/08/2011 - Inclusao do parametro 'cod.rotina' na procedure
                             valida-saldo-conta (Diego).

                14/12/2011 - Incluido os parametro p-cod-rotina e p-coopdest na
                             procedure valida-saldo e na chamada da procedure
                             valida-saldo-conta (Elton).

                12/04/2012 - Inclusao do parametro "origem", na chamada da
                             procedure proc_envia_tec_ted. (Fabricio)

                11/05/2012 - Projeto TED Internet (David).

                22/11/2012 - Ajuste para utilizar campo crapdat.dtmvtocd no
                             lugar do crapdat.dtmvtolt. (Jorge)

                04/12/2012 - Incluir origem da mensagem no numero de controle
                            (Diego).

                15/03/2013 - Novo tratamento para Bancos que nao possuem
                             agencia (David Kruger).

                16/05/2013 - Incluso nova estrutura para buscar valor tarifa
                             utilizando b1wgen0153 (Daniel).

                20/05/2013 - Novo param. procedure 'grava-autenticacao-internet'
                            (Lucas).

                04/06/2013 - Incluso bloco de repeticao nas procedures enviar-ted
                             e atualiza-doc-tec ao efetuar lancamento na craplcm
                             (Daniel).

                23/07/2013 - Alterado lancamento tarifa nas procedures enviar-ted
                             e atualiza-doc-ted para utilizar procedure
                             lan-tarifa-online da b1wgen0153.p (Daniel).

               26/08/2013 - Convers�o Progress para Oracle (Alisson - AMcom)

			   25/04/2016 - Remocao de caracteres invalidos no nome da agencia 
							conforme solicitado no chamado 429584 (Kelvin)

..............................................................................*/
  --  antigo tt-protocolo-ted 
  TYPE typ_reg_protocolo_ted 
        IS RECORD ( cdtippro crappro.cdtippro%TYPE
                   ,dtmvtolt crappro.dtmvtolt%TYPE
                   ,dttransa crappro.dttransa%TYPE
                   ,hrautent crappro.hrautent%TYPE
                   ,vldocmto crappro.vldocmto%TYPE
                   ,nrdocmto crappro.nrdocmto%TYPE
                   ,nrseqaut crappro.nrseqaut%TYPE
                   ,dsinform##1 crappro.dsinform##1%TYPE
                   ,dsinform##2 crappro.dsinform##2%TYPE
                   ,dsinform##3 crappro.dsinform##3%TYPE
                   ,dsprotoc crappro.dsprotoc%TYPE
                   ,nmprepos crappro.nmprepos%TYPE
                   ,nrcpfpre crappro.nrcpfpre%TYPE
                   ,nmoperad crapopi.nmoperad%TYPE
                   ,nrcpfope crappro.nrcpfope%TYPE
                   ,cdbcoctl crapcop.cdbcoctl%TYPE
                   ,cdagectl crapcop.cdagectl%TYPE);
  TYPE typ_tab_protocolo_ted IS TABLE OF typ_reg_protocolo_ted
       INDEX BY PLS_INTEGER;


  /* Procedure para buscar tarifa ted */
  PROCEDURE pc_busca_tarifa_ted (pr_cdcooper IN INTEGER --Codigo Cooperativa
                                ,pr_cdagenci IN INTEGER --Codigo Agencia
                                ,pr_nrdconta IN INTEGER --Numero da Conta
                                ,pr_vllanmto IN OUT NUMBER  --Valor Lancamento
                                ,pr_vltarifa OUT NUMBER --Valor Tarifa
                                ,pr_cdhistor OUT INTEGER --Historico da tarifa
                                ,pr_cdhisest OUT INTEGER --Historico estorno
                                ,pr_cdfvlcop OUT INTEGER --Codigo faixa valor cooperativa
                                ,pr_cdcritic OUT INTEGER       --C�digo do erro
                                ,pr_dscritic OUT VARCHAR2);     --Descricao do erro

  -- Procedure para verificar os dados da TED
  PROCEDURE pc_verifica_dados_ted (pr_cdcooper IN INTEGER                --> Codigo Cooperativa
                                  ,pr_cdagenci IN INTEGER                --> Codigo Agencia
                                  ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                  ,pr_idorigem IN INTEGER                --> Identificador de origem
                                  ,pr_nrdconta IN INTEGER                --> Numero da Conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                  ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Codigo do banco
                                  ,pr_cdageban IN crapcti.cdageban%TYPE  --> Codigo da agencia bancaria
                                  ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> numero da conta transferencia destino
                                  ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> Nome do titular
                                  ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> Numero do cpf/cnpj do titular destino
                                  ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Identificador de tipo de pessoa
                                  ,pr_intipcta IN crapcti.intipcta%TYPE  --> identificador de tipo de conta
                                  ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lan�amento
                                  ,pr_cdfinali IN INTEGER                --> Codigo de finalidade
                                  ,pr_dshistor IN VARCHAR2               --> Descri�ao de historico
                                  ,pr_cdispbif IN crapcti.nrispbif%TYPE  --> Oito primeiras posicoes do cnpj. 
                                  ,pr_idagenda IN INTEGER                --> Indicador de agendamento
                                  /* parametros de saida */                               
                                  ,pr_dstransa OUT VARCHAR2              --> Descri��o de transa��o
                                  ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                                  ,pr_dscritic OUT VARCHAR2);            --> Descricao do erro
                                  
  
  --> Procedure para executar o envio da TED
  PROCEDURE pc_executa_envio_ted 
                          (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa    
                          ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Agencia
                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Caixa Operador    
                          ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador Autorizacao
                          ,pr_idorigem IN INTEGER                --> Origem                 
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                          ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta Remetente        
                          ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular                
                          ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --> CPF operador juridico
                          ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Banco destino
                          ,pr_cdageban IN crapcti.cdageban%TYPE  --> Agencia destino
                          ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Conta transferencia
                          ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> nome do titular destino
                          ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> CPF do titular destino
                          ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Tipo de pessoa
                          ,pr_intipcta IN crapcti.intipcta%TYPE  --> Tipo de conta
                          ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lan�amento
                          ,pr_dstransf IN VARCHAR2               --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER                --> Finalidade TED
                          ,pr_dshistor IN VARCHAR2               --> Descri�ao do Hist�rico
                          ,pr_cdispbif IN INTEGER                --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0      --> Indicador se origem � do Mobile
                          ,pr_idagenda IN INTEGER                --> Tipo de agendamento
                          -- saida
                          ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Retorna protocolo    
                          ,pr_tab_protocolo_ted OUT cxon0020.typ_tab_protocolo_ted --> dados do protocolo
                          ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2);            --> Descricao do erro 
                          
  --> Procedure para executar o envio da TED chamada pelo Progress
  PROCEDURE pc_executa_envio_ted_prog 
                          (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa    
                          ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Agencia
                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Caixa Operador    
                          ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador Autorizacao
                          ,pr_idorigem IN INTEGER                --> Origem                 
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                          ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta Remetente        
                          ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular                
                          ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --> CPF operador juridico
                          ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Banco destino
                          ,pr_cdageban IN crapcti.cdageban%TYPE  --> Agencia destino
                          ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Conta transferencia
                          ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> nome do titular destino
                          ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> CPF do titular destino
                          ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Tipo de pessoa
                          ,pr_intipcta IN crapcti.intipcta%TYPE  --> Tipo de conta
                          ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lan�amento
                          ,pr_dstransf IN VARCHAR2               --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER                --> Finalidade TED
                          ,pr_dshistor IN VARCHAR2               --> Descri�ao do Hist�rico
                          ,pr_cdispbif IN INTEGER                --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0      --> Indicador se origem � do Mobile
                          ,pr_idagenda IN INTEGER                --> Tipo de agendamento
                          -- saida
                          ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Retorna protocolo    
                          ,pr_tab_protocolo_ted OUT CLOB --> dados do protocolo
                          ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_enviar_ted (pr_cdcooper IN INTEGER  --> Cooperativa            
                          ,pr_idorigem IN INTEGER  --> Origem                 
                          ,pr_cdageope IN INTEGER  --> PAC Operador           
                          ,pr_nrcxaope IN INTEGER  --> Caixa Operador    
                          ,pr_cdoperad IN VARCHAR2 --> Operador Autorizacao
                          ,pr_cdopeaut IN VARCHAR2 --> Operador Autorizacao
                          ,pr_vldocmto IN NUMBER   --> Valor TED             
                          ,pr_nrdconta IN INTEGER  --> Conta Remetente        
                          ,pr_idseqttl IN INTEGER  --> Titular                
                          ,pr_nmprimtl IN VARCHAR2 --> Nome Remetente         
                          ,pr_nrcpfcgc IN NUMBER   --> CPF/CNPJ Remetente     
                          ,pr_inpessoa IN INTEGER  --> Tipo Pessoa Remetente  
                          ,pr_cdbanfav IN INTEGER  --> Banco Favorecido       
                          ,pr_cdagefav IN INTEGER  --> Agencia Favorecido     
                          ,pr_nrctafav IN NUMBER   --> Conta Favorecido       
                          ,pr_nmfavore IN VARCHAR2 --> Nome Favorecido        
                          ,pr_nrcpffav IN NUMBER   --> CPF/CNPJ Favorecido    
                          ,pr_inpesfav IN INTEGER  --> Tipo Pessoa Favorecido 
                          ,pr_tpctafav IN INTEGER  --> Tipo Conta Favorecido  
                          ,pr_dshistor IN VARCHAR2 --> Descri�ao do Hist�rico 
                          ,pr_dstransf IN VARCHAR2 --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER  --> Finalidade TED                              
                          ,pr_cdispbif IN INTEGER  --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0 --> Indicador se origem � do Mobile
                          ,pr_idagenda IN INTEGER  --> Tipo de agendamento                          
                          -- saida
                          ,pr_nrdocmto OUT INTEGER --> Documento TED        
                          ,pr_nrrectvl OUT ROWID   --> Autenticacao TVL      
                          ,pr_nrreclcm OUT ROWID   --> Autenticacao LCM      
                          ,pr_des_erro OUT VARCHAR2 );

  /******************************************************************************/
  /**                  Procedure para validar TED                              **/
  /******************************************************************************/
  PROCEDURE pc_validar_ted ( pr_cdcooper IN INTEGER  --> Cooperativa            
                            ,pr_idorigem IN INTEGER  --> Origem                 
                            ,pr_cdageope IN INTEGER  --> PAC Operador           
                            ,pr_nrcxaope IN INTEGER  --> Caixa Operador         
                            ,pr_vldocmto IN NUMBER   --> Valor TED             
                            ,pr_nrdconta IN INTEGER  --> Conta Remetente        
                            ,pr_idseqttl IN INTEGER  --> Titular                
                            ,pr_nmprimtl IN VARCHAR2 --> Nome Remetente         
                            ,pr_nrcpfcgc IN NUMBER   --> CPF/CNPJ Remetente     
                            ,pr_inpessoa IN INTEGER  --> Tipo Pessoa Remetente  
                            ,pr_cdbanfav IN INTEGER  --> Banco Favorecido       
                            ,pr_cdagefav IN INTEGER  --> Agencia Favorecido     
                            ,pr_nrctafav IN NUMBER   --> Conta Favorecido       
                            ,pr_nmfavore IN VARCHAR2 --> Nome Favorecido        
                            ,pr_nrcpffav IN NUMBER   --> CPF/CNPJ Favorecido    
                            ,pr_inpesfav IN INTEGER  --> Tipo Pessoa Favorecido 
                            ,pr_tpctafav IN INTEGER  --> Tipo Conta Favorecido  
                            ,pr_cdfinali IN INTEGER  --> Finalidade TED         
                            ,pr_dshistor IN VARCHAR2 --> Descri�ao do Hist�rico 
                            ,pr_cdispbif IN INTEGER  --> ISPB Banco Favorecido  
                            ,pr_idagenda IN INTEGER  --> Indicador de agendamento
                            ,pr_des_erro OUT VARCHAR2);

  FUNCTION fn_verifica_lote_uso(pr_rowid rowid) RETURN NUMBER;
                                                             
END CXON0020;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cxon0020 AS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : CXON0020
    Sistema  : Procedimentos e funcoes das transacoes do caixa online
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Junho/2013.                   Ultima atualizacao: 14/06/2016
  
    Dados referentes ao programa:
  
    Frequencia: -----
    Objetivo  : Procedimentos e funcoes das transacoes do caixa online
    
    Altera��o : 14/03/2016 - Removido save point da procedure e alterado por rollback em
                             toda a transa��o caso ocorra problemas. SD 417330 (Kelvin).

                27/04/2016 - Adicionado tratamento para verificar isencao ou nao                             
                             de tarifa no envio de TED Eletr�nica. PRJ 218/2 (Reinert).
    
                14/06/2016 - Ajuste para incluir o UPPER em campos de indice ao ler a tabela craptvl
                             (Adriano - SD 469449).
    
  ---------------------------------------------------------------------------------------------------------------*/

  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
          ,crapcop.nmextcop
          ,crapcop.nrtelura
          ,crapcop.dsdircop
          ,crapcop.cdbcoctl
          ,crapcop.cdagectl
          ,crapcop.flgoppag
          ,crapcop.flgopstr
          ,crapcop.inioppag
          ,crapcop.fimoppag
          ,crapcop.iniopstr
          ,crapcop.fimopstr
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Buscar dados das agencias */
  CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%type
                    ,pr_cdagenci IN crapage.cdagenci%type) IS
    SELECT crapage.nmresage
          ,crapage.qtddaglf
    FROM crapage
    WHERE crapage.cdcooper = pr_cdcooper
    AND   crapage.cdagenci = pr_cdagenci;
  rw_crapage cr_crapage%ROWTYPE;

  /* Busca dos dados do associado */
  CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.nmsegntl
          ,crapass.inpessoa
          ,crapass.cdagenci
          ,crapass.vllimcre
          ,crapass.nrcpfcgc
          ,crapass.nrcpfstl
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
     AND   crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  --Selecionar informacoes dos terminais
  CURSOR cr_craptfn (pr_cdcoptfn IN craptfn.cdcooper%type
                    ,pr_nrterfin IN craptfn.nrterfin%type) IS
    SELECT craptfn.nrultaut
          ,craptfn.cdcooper
          ,craptfn.cdagenci
          ,craptfn.nrterfin
          ,craptfn.cdoperad
          ,craptfn.ROWID
    FROM craptfn
    WHERE craptfn.cdcooper = pr_cdcoptfn
    AND   craptfn.nrterfin = pr_nrterfin;
  rw_craptfn cr_craptfn%ROWTYPE;

  --Selecionar informacoes dos lotes
  CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                    ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                    ,pr_cdagenci IN craplot.cdagenci%TYPE
                    ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                    ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT craplot.dtmvtolt
          ,craplot.cdagenci
          ,craplot.cdbccxlt
          ,craplot.nrdolote
          ,craplot.nrseqdig
          ,craplot.rowid
    FROM   craplot craplot
    WHERE  craplot.cdcooper = pr_cdcooper
    AND    craplot.dtmvtolt = pr_dtmvtolt
    AND    craplot.cdagenci = pr_cdagenci
    AND    craplot.cdbccxlt = pr_cdbccxlt
    AND    craplot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;
  
  /* Procedure para buscar tarifa ted */
  PROCEDURE pc_busca_tarifa_ted (pr_cdcooper IN INTEGER --Codigo Cooperativa
                                ,pr_cdagenci IN INTEGER --Codigo Agencia
                                ,pr_nrdconta IN INTEGER --Numero da Conta
                                ,pr_vllanmto IN OUT NUMBER  --Valor Lancamento
                                ,pr_vltarifa OUT NUMBER --Valor Tarifa
                                ,pr_cdhistor OUT INTEGER --Historico da tarifa
                                ,pr_cdhisest OUT INTEGER --Historico estorno
                                ,pr_cdfvlcop OUT INTEGER --Codigo faixa valor cooperativa
                                ,pr_cdcritic OUT INTEGER       --C�digo do erro
                                ,pr_dscritic OUT VARCHAR2) IS   --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_busca_tarifa_ted             Antigo: dbo/b1crap20.p/busca-tarifa-ted
  --  Sistema  : Procedure para buscar tarifa ted
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar tarifa ted
  --
  -- Alteracoes: 01/10/2015 - Retirado soma do parametro pr_vllanmto conforme era no progress (Odirlei-Amcom) 
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_dssigtar VARCHAR2(20);
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;

      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_tab_erro GENE0001.typ_tab_erro;

      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      --Tipo de Dados para cursor cooperativa
      rw_crabcop  cr_crapcop%ROWTYPE;
      --Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Inicializar variaveis retorno
      pr_vltarifa:= 0;
      pr_cdhistor:= 0;
      pr_cdfvlcop:= 0;
      pr_cdhisest:= 0;

      --Selecionar associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      --Posicionar no proximo registro
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        vr_dscritic:= 'Associado nao cadastrado.';
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;

      /** Conta administrativa nao sofre tarifacao **/
      IF rw_crapass.inpessoa = 3 THEN
        RETURN;
      END IF;

      --Se for TAA
      IF pr_cdagenci = 91 THEN
        RETURN;
      ELSIF pr_cdagenci = 90 THEN  /** Internet **/
        --Pessoa Fisica
        IF rw_crapass.inpessoa = 1 THEN
          --Sigla tarifa
          vr_dssigtar:= 'TEDELETRPF';
        ELSE
          --Sigla tarifa
          vr_dssigtar:= 'TEDELETRPJ';
        END IF;
      ELSE  /** Caixa On-Line **/
        --Pessoa Fisica
        IF rw_crapass.inpessoa = 1 THEN
          --Sigla tarifa
          vr_dssigtar:= 'TEDCAIXAPF';
        ELSE
          --Sigla tarifa
          vr_dssigtar:= 'TEDCAIXAPJ';
        END IF;
      END IF;

      /*  Busca valor da tarifa sem registro*/
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                            ,pr_cdbattar  => vr_dssigtar  --Codigo Tarifa
                                            ,pr_vllanmto  => pr_vllanmto  --Valor Lancamento
                                            ,pr_cdprogra  => NULL         --Codigo Programa
                                            ,pr_cdhistor  => pr_cdhistor  --Codigo Historico
                                            ,pr_cdhisest  => pr_cdhisest  --Historico Estorno
                                            ,pr_vltarifa  => pr_vltarifa  --Valor tarifa
                                            ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                            ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                            ,pr_cdfvlcop  => pr_cdfvlcop  --Codigo faixa valor cooperativa
                                            ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                            ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                            ,pr_tab_erro  => vr_tab_erro); --Tabela erros
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
          vr_cdcritic:= vr_tab_erro(1).cdcritic;
          vr_dscritic:= vr_tab_erro(1).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
        END IF;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0020.pc_busca_tarifa_ted. '||SQLERRM;
    END;
  END pc_busca_tarifa_ted;
  
  /******************************************************************************/
  /**                  Procedure para validar TED                              **/
  /******************************************************************************/
  PROCEDURE pc_validar_ted ( pr_cdcooper IN INTEGER  --> Cooperativa            
                            ,pr_idorigem IN INTEGER  --> Origem                 
                            ,pr_cdageope IN INTEGER  --> PAC Operador           
                            ,pr_nrcxaope IN INTEGER  --> Caixa Operador         
                            ,pr_vldocmto IN NUMBER   --> Valor TED             
                            ,pr_nrdconta IN INTEGER  --> Conta Remetente        
                            ,pr_idseqttl IN INTEGER  --> Titular                
                            ,pr_nmprimtl IN VARCHAR2 --> Nome Remetente         
                            ,pr_nrcpfcgc IN NUMBER   --> CPF/CNPJ Remetente     
                            ,pr_inpessoa IN INTEGER  --> Tipo Pessoa Remetente  
                            ,pr_cdbanfav IN INTEGER  --> Banco Favorecido       
                            ,pr_cdagefav IN INTEGER  --> Agencia Favorecido     
                            ,pr_nrctafav IN NUMBER   --> Conta Favorecido       
                            ,pr_nmfavore IN VARCHAR2 --> Nome Favorecido        
                            ,pr_nrcpffav IN NUMBER   --> CPF/CNPJ Favorecido    
                            ,pr_inpesfav IN INTEGER  --> Tipo Pessoa Favorecido 
                            ,pr_tpctafav IN INTEGER  --> Tipo Conta Favorecido  
                            ,pr_cdfinali IN INTEGER  --> Finalidade TED         
                            ,pr_dshistor IN VARCHAR2 --> Descri�ao do Hist�rico 
                            ,pr_cdispbif IN INTEGER  --> ISPB Banco Favorecido  
                            ,pr_idagenda IN INTEGER  --> Indicador de agendamento
                            ,pr_des_erro OUT VARCHAR2)IS --> Indicador se retornou com erro (OK ou NOK)

  /*---------------------------------------------------------------------------------------------------------------
  
      Programa : pc_validar_ted             Antigo: b1crap20/validar-ted
      Sistema  : Rotinas acessadas pelas telas de cadastros Web
      Sigla    : CRED
      Autor    : Odirlei Busana - Amcom
      Data     : Junho/2015.                   Ultima atualizacao: 08/06/2015
  
      Dados referentes ao programa:
  
      Frequencia: Sempre que for chamado
      Objetivo  : Procedure para validar TED
    
      Altera��o : 08/06/2015 - Convers�o Progress -> Oracle (Odirlei-Amcom)
    
  ---------------------------------------------------------------------------------------------------------------*/
    ---------------> CURSORES <-----------------        
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.nmprimtl,
             crapass.inpessoa,
             crapass.nrcpfcgc
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;       
    
    -- Validar banco
    CURSOR cr_crapban (pr_cdispbif crapban.nrispbif%TYPE,
                       pr_cdbccxlt crapban.cdbccxlt%TYPE) IS
      SELECT flgdispb
        FROM crapban 
       WHERE (crapban.nrispbif = pr_cdispbif AND pr_cdbccxlt = 0) 
         OR  (crapban.cdbccxlt = pr_cdbccxlt AND pr_cdbccxlt > 0);
    rw_crapban cr_crapban%ROWTYPE;
       
    ------------> ESTRUTURAS DE REGISTRO <-----------
    
    --Tabela de mem�ria de limites de horario
    vr_tab_limite INET0001.typ_tab_limite;
    vr_index      PLS_INTEGER;
                                       
    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
      
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    
    vr_nrcxaope NUMBER;     
    vr_flgretor BOOLEAN;
    vr_tppessoa INTEGER;
    vr_dstextab craptab.dstextab%TYPE;
    
  BEGIN
      
    IF pr_idorigem IN (3,4) THEN  /** 3-Internet  4-CASH/TAA **/
      vr_nrcxaope := pr_nrdconta || pr_idseqttl;
    ELSE
      vr_nrcxaope := pr_nrcxaope;
    END IF;
    
    --Eliminar erro
    CXON0000.pc_elimina_erro(pr_cooper      => pr_cdcooper
                            ,pr_cod_agencia => pr_cdageope
                            ,pr_nro_caixa   => vr_nrcxaope
                            ,pr_cdcritic    => vr_cdcritic
                            ,pr_dscritic    => vr_dscritic);
    
    vr_cdcritic := 0;
    vr_dscritic := NULL;
    
    --> Buscar dados cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
      
    --> verificar se encontra registro
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;     
    
    /*SD 244456 - VANESSA*/
    IF pr_cdfinali IN (99,99999,999) AND TRIM(pr_dshistor) IS NULL THEN 
      vr_cdcritic := 0;
      vr_dscritic := 'Informe a descri�ao do hist�rico';
      RAISE vr_exc_erro;
    END IF;
    /* FIM SD 244456*/
    
    --Buscar Horario Operacao
    INET0001.pc_horario_operacao (pr_cdcooper   => pr_cdcooper  -- C�digo Cooperativa
                                 ,pr_cdagenci   => pr_cdageope  -- Agencia do Associado
                                 ,pr_tpoperac   => 4 /* TED */  -- Tipo de Operacao (0=todos)
                                 ,pr_inpessoa   => pr_inpessoa  -- Tipo de Pessoa
                                 ,pr_tab_limite => vr_tab_limite --Tabelas de retorno de horarios limite
                                 ,pr_cdcritic   => vr_cdcritic    --C�digo do erro
                                 ,pr_dscritic   => vr_dscritic);  --Descricao do erro
    --Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --levantar Excecao
      RAISE vr_exc_erro;
    END IF;           
    
    vr_index := vr_tab_limite.first;
    /* Agendamento de TED deve ser poss�vel realizar em qualquer hor�rio e dia,
       mesmo n�o sendo �til */
    IF vr_tab_limite.exists(vr_index) = FALSE  OR   -- N�o encontrou
       ((vr_tab_limite(vr_index).idesthor = 1  OR   -- Estourou o horario
       vr_tab_limite(vr_index).iddiauti = 2)   AND 
       NOT pr_idagenda IN(2,3))                THEN -- N�o � dia util
    
      vr_cdcritic := 676; --> 676 - Horario esgotado para digitacao.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;   
    
    -- Validar data cooper
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se n�o encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
       CLOSE btch0001.cr_crapdat;

       vr_cdcritic := 0;
       vr_dscritic := 'Sistema sem data de movimento.';
       RAISE vr_exc_erro;
    ELSE
       CLOSE btch0001.cr_crapdat;
    END IF;
    
    -- Validar cooperado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- verificar se localizou
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crapass;
    END IF;
    
    -- Verificar nome
    IF TRIM(pr_nmprimtl) IS NULL  THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Nome do remetente incorreto';
      RAISE vr_exc_erro;
    END IF;
    
    -- Validar cpf ou cnpj
    GENE0005.pc_valida_cpf_cnpj (pr_nrcalcul => pr_nrcpfcgc --> Numero a ser verificado
                                ,pr_stsnrcal => vr_flgretor  --> Situacao
                                ,pr_inpessoa => vr_tppessoa);--> Tipo Inscricao Cedente
    
    IF vr_flgretor = FALSE THEN 
      vr_cdcritic := 27; --> 027 - CPF/CNPJ com erro.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;            
    END IF;            
    
    -- Validar tipo de pessoa
    IF pr_inpessoa <> vr_tppessoa THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Tipo de pessoa do remetente incorreto.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Validar codigo do banco favorecido
    IF pr_cdbanfav = rw_crapcop.cdbcoctl THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Nao e posssivel efetuar transferencia entre IFs do Sistema CECRED.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Validar banco
    OPEN cr_crapban (pr_cdispbif => pr_cdispbif,
                     pr_cdbccxlt => pr_cdbanfav);
    FETCH cr_crapban INTO rw_crapban;
      
    IF cr_crapban%NOTFOUND THEN
      vr_cdcritic := 57; --> BANCO NAO CADASTRADO.
      vr_dscritic := NULL;
      CLOSE cr_crapban;
      RAISE vr_exc_erro;  
    END IF;
    CLOSE cr_crapban;
    
    -- Verificar se banco esta em opera��o no SPB
    IF rw_crapban.flgdispb = 0 /*FALSE*/ THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Banco do favorecido nao opera no SPB.';
      RAISE vr_exc_erro;
    END IF;
    -- Validar agencia
    IF TRIM(pr_cdagefav) IS NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Agencia invalida.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Verificar conta favorecida
    IF nvl(pr_nrctafav,0) = 0 THEN 
      vr_cdcritic := 0;
      vr_dscritic := 'Conta do favorecido deve ser informada.';
      RAISE vr_exc_erro;
    END IF;
    IF TRIM(pr_nmfavore) IS NULL THEN 
      vr_cdcritic := 0;
      vr_dscritic := 'Nome favorecido deve ser informado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Validar cpf ou cnpj
    GENE0005.pc_valida_cpf_cnpj (pr_nrcalcul => pr_nrcpffav  --> Numero a ser verificado
                                ,pr_stsnrcal => vr_flgretor  --> Situacao
                                ,pr_inpessoa => vr_tppessoa);--> Tipo Inscricao Cedente
    
    IF vr_flgretor = FALSE THEN 
      vr_cdcritic := 27; --> 027 - CPF/CNPJ com erro.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;            
    END IF;    
    
    -- Validar tipo de pessoa
    IF pr_inpesfav <> vr_tppessoa THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Tipo de pessoa do favorecido e incorreto.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Ler tabela generica -  Tipo de conta
    vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => rw_crapcop.cdcooper 
                                              ,pr_nmsistem => 'CRED'           
                                              ,pr_tptabela => 'GENERI'         
                                              ,pr_cdempres => 00               
                                              ,pr_cdacesso => 'TPCTACRTED'     
                                              ,pr_tpregist => pr_tpctafav   );
    
    IF vr_dstextab IS NULL THEN
      vr_cdcritic := 17; --> Tipo de conta errado
      vr_dscritic := NULL;
      RAISE vr_exc_erro; 
    END IF;
    
    -- Ler tabela generica
    vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => rw_crapcop.cdcooper 
                                              ,pr_nmsistem => 'CRED'           
                                              ,pr_tptabela => 'GENERI'         
                                              ,pr_cdempres => 00               
                                              ,pr_cdacesso => 'FINTRFTEDS'     
                                              ,pr_tpregist => pr_cdfinali   );
    
    IF vr_dstextab IS NULL THEN
      vr_cdcritic := 362; --> Finalidade nao cadastrada.
      vr_dscritic := NULL;
      RAISE vr_exc_erro; 
    END IF;
    
    -- Validar valor
    IF pr_vldocmto = 0 THEN 
      vr_cdcritic := 0;
      vr_dscritic := 'Valor da TED deve ser informado.';
      RAISE vr_exc_erro;
    END IF;
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      --Criar Erro
      CXON0000.pc_cria_erro( pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => pr_cdageope
                            ,pr_nrdcaixa => vr_nrcxaope
                            ,pr_cod_erro => vr_cdcritic
                            ,pr_dsc_erro => vr_dscritic
                            ,pr_flg_erro => TRUE
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
      pr_des_erro := 'NOK'; 
    WHEN OTHERS THEN
      vr_dscritic := 'Nao foi possivel validar TED:'||SQLERRM;
      CXON0000.pc_cria_erro( pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => pr_cdageope
                            ,pr_nrdcaixa => vr_nrcxaope
                            ,pr_cod_erro => 0
                            ,pr_dsc_erro => vr_dscritic
                            ,pr_flg_erro => TRUE
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
      pr_des_erro := 'NOK'; 
  END pc_validar_ted;
  
  /******************************************************************************/
  /**                  Procedure para verificar os dados da TED                **/
  /******************************************************************************/
  PROCEDURE pc_verifica_dados_ted (pr_cdcooper IN INTEGER                --> Codigo Cooperativa
                                  ,pr_cdagenci IN INTEGER                --> Codigo Agencia
                                  ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                  ,pr_idorigem IN INTEGER                --> Identificador de origem
                                  ,pr_nrdconta IN INTEGER                --> Numero da Conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                  ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Codigo do banco
                                  ,pr_cdageban IN crapcti.cdageban%TYPE  --> Codigo da agencia bancaria
                                  ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> numero da conta transferencia destino
                                  ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> Nome do titular
                                  ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> Numero do cpf/cnpj do titular destino
                                  ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Identificador de tipo de pessoa
                                  ,pr_intipcta IN crapcti.intipcta%TYPE  --> identificador de tipo de conta
                                  ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lan�amento
                                  ,pr_cdfinali IN INTEGER                --> Codigo de finalidade
                                  ,pr_dshistor IN VARCHAR2               --> Descri�ao de historico
                                  ,pr_cdispbif IN crapcti.nrispbif%TYPE  --> Oito primeiras posicoes do cnpj. 
                                  ,pr_idagenda IN INTEGER                --> Indicador de agendamento
                                  /* parametros de saida */                               
                                  ,pr_dstransa OUT VARCHAR2              --> Descri��o de transa��o
                                  ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do erro
  /*---------------------------------------------------------------------------------------------------------------
  
      Programa : pc_verifica_dados_ted             Antigo: b1wgen0015/verifica-dados-ted
      Sistema  : Rotinas acessadas pelas telas de cadastros Web
      Sigla    : CRED
      Autor    : Odirlei Busana - Amcom
      Data     : Junho/2015.                   Ultima atualizacao: 08/06/2015
  
      Dados referentes ao programa:
  
      Frequencia: Sempre que for chamado
      Objetivo  : Procedure para verificar os dados da TED
    
      Altera��o : 08/06/2015 - Convers�o Progress -> Oracle (Odirlei-Amcom)
    
  ---------------------------------------------------------------------------------------------------------------*/
    ---------------> CURSORES <-----------------        
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.nmprimtl,
             crapass.inpessoa,
             crapass.nrcpfcgc
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;     
  
    -- Buscar titulares
    CURSOR cr_crapttl ( pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE,
                        pr_idseqttl crapttl.idseqttl%TYPE)  IS
      SELECT ttl.nmextttl
            ,ttl.inpessoa
            ,ttl.idseqttl
            ,ttl.nrcpfcgc
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl ;
    rw_crapttl cr_crapttl%ROWTYPE;     
    
    -- buscar erro
    CURSOR cr_craperr(pr_cdcooper craperr.cdcooper%TYPE,
                      pr_cdagenci craperr.cdagenci%TYPE,
                      pr_nrdcaixa craperr.nrdcaixa%TYPE) IS
      SELECT craperr.dscritic
        FROM craperr
       WHERE craperr.cdcooper = pr_cdcooper
         AND craperr.cdagenci = pr_cdagenci
         AND craperr.nrdcaixa = pr_nrdcaixa;
    
    
    ------------> ESTRUTURAS DE REGISTRO <-----------
                                       
    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
      
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
        
    vr_nmextttl crapttl.nmextttl%TYPE;
    vr_nrcpfcgc crapttl.nrcpfcgc%TYPE;
    vr_des_erro  VARCHAR2(200);
    
    
  BEGIN
    pr_dstransa := 'Transferencia de TED';
    
    --> Buscar dados cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
      
    --> verificar se encontra registro
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'Registro de cooperativa nao encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;
    
    -- Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- verificar se localizou
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado.';      
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crapass;
    END IF;
    
    -- se for pessoa fisica
    IF rw_crapass.inpessoa = 1 THEN
      -- buscar dados titular
      OPEN cr_crapttl (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_idseqttl => pr_idseqttl);
      FETCH cr_crapttl INTO rw_crapttl;
      
      IF cr_crapttl%NOTFOUND THEN
        CLOSE cr_crapttl;
        vr_dscritic := 'Titular nao cadastrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapttl;
      
      vr_nmextttl := rw_crapttl.nmextttl;
      vr_nrcpfcgc := rw_crapttl.nrcpfcgc;
      
    ELSE
      -- se for pessoa juridica, usar informa��es da crapass
      vr_nmextttl := rw_crapass.nmprimtl;
      vr_nrcpfcgc := rw_crapass.nrcpfcgc;
    END IF;
        
    cxon0020.pc_validar_ted( pr_cdcooper => pr_cdcooper    --> Cooperativa            
                            ,pr_idorigem => pr_idorigem   --> Origem                 
                            ,pr_cdageope => pr_cdagenci   --> PAC Operador           
                            ,pr_nrcxaope => pr_nrdcaixa   --> Caixa Operador         
                            ,pr_vldocmto => pr_vllanmto   --> Valor TED             
                            ,pr_nrdconta => pr_nrdconta   --> Conta Remetente        
                            ,pr_idseqttl => pr_idseqttl   --> Titular                
                            ,pr_nmprimtl => vr_nmextttl   --> Nome Remetente         
                            ,pr_nrcpfcgc => vr_nrcpfcgc   --> CPF/CNPJ Remetente     
                            ,pr_inpessoa => (CASE rw_crapass.inpessoa    --> Tipo Pessoa Remetente  
                                               WHEN 1 THEN rw_crapass.inpessoa
                                               ELSE 2
                                             END)  
                            ,pr_cdbanfav => pr_cddbanco   --> Banco Favorecido       
                            ,pr_cdagefav => pr_cdageban   --> Agencia Favorecido     
                            ,pr_nrctafav => pr_nrctatrf   --> Conta Favorecido       
                            ,pr_nmfavore => pr_nmtitula   --> Nome Favorecido        
                            ,pr_nrcpffav => pr_nrcpfcgc   --> CPF/CNPJ Favorecido    
                            ,pr_inpesfav => pr_inpessoa   --> Tipo Pessoa Favorecido 
                            ,pr_tpctafav => pr_intipcta   --> Tipo Conta Favorecido  
                            ,pr_cdfinali => pr_cdfinali   --> Finalidade TED         
                            ,pr_dshistor => pr_dshistor   --> Descri�ao do Hist�rico 
                            ,pr_cdispbif => pr_cdispbif   --> ISPB Banco Favorecido  
                            ,pr_idagenda => pr_idagenda   --> Indicador de agendamento
                            ,pr_des_erro => vr_des_erro); --> Indicador se retornou com erro (OK ou NOK)
    
    IF vr_des_erro <> 'OK' THEN
      -- buscar erro
      vr_dscritic := NULL;
      OPEN cr_craperr(pr_cdcooper => pr_cdcooper,
                      pr_cdagenci => pr_cdagenci,
                      pr_nrdcaixa => pr_nrdconta||pr_idseqttl);
      FETCH cr_craperr INTO vr_dscritic;
      CLOSE cr_craperr;
      
      -- se nao encontrou a critica ou esta em branco, define mensagem
      vr_dscritic := nvl(vr_dscritic,'TED invalida.');
      RAISE vr_exc_erro;
      
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN      
      IF vr_cdcritic = 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := 'N�o foi possivel verificar dados TED';
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel verificar dados TED: '||SQLERRM; 
  END pc_verifica_dados_ted;
  
  /******************************************************************************/
  /**                  Procedure para envio do TED                             **/
  /******************************************************************************/
  PROCEDURE pc_enviar_ted (pr_cdcooper IN INTEGER  --> Cooperativa            
                          ,pr_idorigem IN INTEGER  --> Origem                 
                          ,pr_cdageope IN INTEGER  --> PAC Operador           
                          ,pr_nrcxaope IN INTEGER  --> Caixa Operador    
                          ,pr_cdoperad IN VARCHAR2 --> Operador Autorizacao
                          ,pr_cdopeaut IN VARCHAR2 --> Operador Autorizacao
                          ,pr_vldocmto IN NUMBER   --> Valor TED             
                          ,pr_nrdconta IN INTEGER  --> Conta Remetente        
                          ,pr_idseqttl IN INTEGER  --> Titular                
                          ,pr_nmprimtl IN VARCHAR2 --> Nome Remetente         
                          ,pr_nrcpfcgc IN NUMBER   --> CPF/CNPJ Remetente     
                          ,pr_inpessoa IN INTEGER  --> Tipo Pessoa Remetente  
                          ,pr_cdbanfav IN INTEGER  --> Banco Favorecido       
                          ,pr_cdagefav IN INTEGER  --> Agencia Favorecido     
                          ,pr_nrctafav IN NUMBER   --> Conta Favorecido       
                          ,pr_nmfavore IN VARCHAR2 --> Nome Favorecido        
                          ,pr_nrcpffav IN NUMBER   --> CPF/CNPJ Favorecido    
                          ,pr_inpesfav IN INTEGER  --> Tipo Pessoa Favorecido 
                          ,pr_tpctafav IN INTEGER  --> Tipo Conta Favorecido  
                          ,pr_dshistor IN VARCHAR2 --> Descri�ao do Hist�rico 
                          ,pr_dstransf IN VARCHAR2 --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER  --> Finalidade TED                              
                          ,pr_cdispbif IN INTEGER  --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0 --> Indicador se origem � do Mobile
                          ,pr_idagenda IN INTEGER  --> Tipo de agendamento                          
                          -- saida
                          ,pr_nrdocmto OUT INTEGER --> Documento TED        
                          ,pr_nrrectvl OUT ROWID   --> Autenticacao TVL      
                          ,pr_nrreclcm OUT ROWID   --> Autenticacao LCM      
                          ,pr_des_erro OUT VARCHAR2 )IS  --> Indicador se retornou com erro (OK ou NOK)

  /*---------------------------------------------------------------------------------------------------------------
  
      Programa : pc_enviar_ted             Antigo: b1crap20/enviar-ted
      Sistema  : Rotinas acessadas pelas telas de cadastros Web
      Sigla    : CRED
      Autor    : Odirlei Busana - Amcom
      Data     : Junho/2015.                   Ultima atualizacao: 14/06/2016
  
      Dados referentes ao programa:
  
      Frequencia: Sempre que for chamado
      Objetivo  : Procedure para envio do TED
    
      Altera��o : 08/06/2015 - Convers�o Progress -> Oracle (Odirlei-Amcom)
      
                  04/02/2016 - Aumento no tempo de verificacao de TED duplicada. De 30 seg. para 
                               10 min. (Jorge/David) - SD 397867
                               
                  26/02/2016 - Inclus�o de log de lote em uso - TARI0001.pc_gera_log_lote_uso (Odirlei-AMcom)             
                  
                  01/03/2016 - Removido tratamento de TED duplicada contendo select na craptvl sem nrdconta
                               e ajustado a critica (Odirlei-AMcom)

				08/03/2016 - Adicionados par�metros para gera�ao de LOG
                               (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)

                  14/03/2016 - Removido save point da procedure e alterado por rollback em
                               toda a transa��o caso ocorra problemas. SD 417330 (Kelvin).
    
                  14/06/2016 - Ajuste para incluir o UPPER em campos de indice ao ler a tabela craptvl
                              (Adriano - SD 469449).
                               
  
  ---------------------------------------------------------------------------------------------------------------*/
    ---------------> CURSORES <-----------------        
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.nmprimtl,
             crapass.inpessoa,
             crapass.nrcpfcgc,
             crapass.nrdctitg,
             crapass.cdagenci,
             crapass.vllimcre
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;       
    
    -- Validar banco
    CURSOR cr_crapban (pr_cdispbif crapban.nrispbif%TYPE) IS
      SELECT flgdispb
        FROM crapban 
       WHERE crapban.nrispbif = pr_cdispbif;
    rw_crapban cr_crapban%ROWTYPE;
    
    -- Verificar tranferencia de valores (DOC C, DOC D E TEDS)
    CURSOR cr_craptvl (pr_cdcooper craptvl.cdcooper%TYPE,
                       pr_nrctrlif craptvl.idopetrf%TYPE)IS
      SELECT flgtitul,
             tpdctadb
        FROM craptvl
       WHERE craptvl.cdcooper = pr_cdcooper
         AND craptvl.tpdoctrf = 3 /* TED SPB */
       AND UPPER(craptvl.idopetrf) = UPPER(pr_nrctrlif);
    rw_craptvl cr_craptvl%ROWTYPE;
         
    /* Validar transferencia duplicadas */
    CURSOR cr_craptvl_max( pr_cdcooper craptvl.cdcooper%TYPE,
                           pr_dtmvtocd craptvl.dtmvtolt%TYPE,
                           pr_cdageope craptvl.cdagenci%TYPE,
                           pr_nrdolote craptvl.nrdolote%TYPE,
                           pr_nrdconta craptvl.nrdconta%TYPE,
                           pr_cdbanfav craptvl.cdbccrcb%TYPE,
                           pr_cdagefav craptvl.cdagercb%TYPE,
                           pr_nrctafav craptvl.nrcctrcb%TYPE,
                           pr_vldocmto craptvl.vldocrcb%TYPE) IS
      SELECT MAX(hrtransa) hrtransa
        FROM craptvl
       WHERE craptvl.cdcooper = pr_cdcooper
         AND craptvl.dtmvtolt = pr_dtmvtocd
         AND craptvl.cdagenci = pr_cdageope
         AND craptvl.cdbccxlt = 11
         AND craptvl.nrdolote = pr_nrdolote
         AND craptvl.tpdoctrf = 3
         AND craptvl.nrdconta = pr_nrdconta
         AND craptvl.cdbccrcb = pr_cdbanfav
         AND craptvl.cdagercb = pr_cdagefav
         AND craptvl.nrcctrcb = pr_nrctafav
         AND craptvl.vldocrcb = pr_vldocmto;
    rw_craptvl_max cr_craptvl_max%ROWTYPE;
         
         
    -- Buscar dados historico
    CURSOR cr_craphis (pr_cdcooper craphis.cdcooper%TYPE,
                       pr_cdhistor craphis.cdhistor%TYPE)IS
      SELECT craphis.cdhistor
        FROM craphis
       WHERE craphis.cdcooper = pr_cdcooper
         AND craphis.cdhistor = pr_cdhistor;
    rw_craphis cr_craphis%ROWTYPE;     
    
    -- Verificar se ja existe lcm
    CURSOR cr_craplcm (pr_cdcooper craplcm.cdcooper%TYPE,
                       pr_nrdconta craplcm.nrdctabb%TYPE,
                       pr_dtmvtolt craplcm.dtmvtolt%TYPE,
                       pr_cdagenci craplcm.cdagenci%TYPE,
                       pr_nrdolote craplcm.nrdolote%TYPE,
                       pr_nrdocmto craplcm.nrdocmto%TYPE)IS
      SELECT craplcm.hrtransa
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdbccxlt = 11
         AND craplcm.nrdolote = pr_nrdolote
         AND craplcm.nrdctabb = pr_nrdconta
         AND craplcm.nrdocmto = pr_nrdocmto;
    rw_craplcm cr_craplcm%ROWTYPE;     
    
    -- Verificar lote
    CURSOR cr_craplot (pr_cdcooper  craplot.cdcooper%TYPE,
                       pr_dtmvtolt  craplot.dtmvtolt%TYPE,
                       pr_cdageope  craplot.cdagenci%TYPE,
                       pr_cdbccxlt  craplot.cdbccxlt%TYPE,
                       pr_nrdolote  craplot.nrdolote%TYPE)IS
      SELECT craplot.rowid,
             craplot.dtmvtolt,
             craplot.cdagenci,
             craplot.cdbccxlt,
             craplot.nrdolote,
             craplot.nrseqdig,
             craplot.cdhistor
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdagenci = pr_cdageope
         AND craplot.cdbccxlt = pr_cdbccxlt
         AND craplot.nrdolote = pr_nrdolote
       FOR UPDATE NOWAIT;
    rw_craplot_tvl cr_craplot%ROWTYPE;
    rw_craplot_lcm cr_craplot%ROWTYPE;
    
    ------------> ESTRUTURAS DE REGISTRO <-----------
    
    --Tabela de mem�ria de limites de horario
    vr_tab_limite INET0001.typ_tab_limite;
    vr_index      PLS_INTEGER;
                                       
    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_tab_erro GENE0001.typ_tab_erro;
    vr_tab_saldo EXTR0001.typ_tab_saldos;
    
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
      
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_exc_log  EXCEPTION;
    
    vr_nrcxaope NUMBER;     
    vr_flgretor BOOLEAN;
    vr_tppessoa INTEGER;
		vr_idorigem INTEGER;
    vr_dstextab craptab.dstextab%TYPE;
    vr_nrdolote craplot.nrdolote%TYPE;
    vr_tpdolote craplot.tplotmov%TYPE;
    vr_cdhistor craplot.cdhistor%TYPE;
    vr_nrlotlcm craplot.nrdolote%TYPE;
    vr_tplotlcm craplot.tplotmov%TYPE;
    vr_nrseqted NUMBER;
    vr_nrctrlif VARCHAR2(200);
    vr_dslitera crapaut.dslitera%TYPE;
    vr_nrultseq crapaut.nrsequen%TYPE;
    vr_ultsqlcm crapaut.nrsequen%TYPE;
    vr_vllantar NUMBER;
    vr_vllanto_aux NUMBER;
    vr_cdhistar craphis.cdhistor%TYPE;
    vr_cdhisest craphis.cdhistor%TYPE;
    vr_cdhisted craphis.cdhistor%TYPE;
    vr_cdfvlcop INTEGER;
    vr_cdlantar craplat.cdlantar%TYPE;
    vr_hrtransa craplcm.hrtransa%TYPE;
    vr_email_dest VARCHAR2(500);
    vr_conteudo   VARCHAR2(4000);
    vr_nmarqlog   VARCHAR2(500);
    vr_flgerlog   VARCHAR2(50);
    vr_vlsldisp   NUMBER;
    vr_vltarifa   NUMBER;
    vr_debtarifa  BOOLEAN := FALSE;

    --Rowid lancamento tarifa
    vr_rowid_craplat ROWID;

	vr_qtacobra   INTEGER;
	vr_fliseope   INTEGER;		
    
    ---------------- SUB-ROTINAS ------------------
    -- Procedimento para inserir o lote e n�o deixar tabela lockada
    PROCEDURE pc_insere_lote (pr_cdcooper IN craplot.cdcooper%TYPE,
                              pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                              pr_cdagenci IN craplot.cdagenci%TYPE,
                              pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                              pr_nrdolote IN craplot.nrdolote%TYPE,
                              pr_tplotmov IN craplot.tplotmov%TYPE,
                              pr_cdhistor IN craplot.cdhistor%TYPE DEFAULT 0,
                              pr_cdoperad IN craplot.cdoperad%TYPE,
                              pr_nrdcaixa IN craplot.nrdcaixa%TYPE,
                              pr_cdopecxa IN craplot.cdopecxa%TYPE,
                              pr_craplot  OUT cr_craplot%ROWTYPE,
                              pr_dscritic OUT VARCHAR2)IS

      -- Pragma - abre nova sessao para tratar a atualizacao
      PRAGMA AUTONOMOUS_TRANSACTION;
        
      rw_craplot cr_craplot%ROWTYPE;
      vr_nrdolote craplot.nrdolote%TYPE;
        
    BEGIN
      vr_nrdolote := pr_nrdolote;
      
      TARI0001.pc_gera_log_lote_uso(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_nrdolote => vr_nrdolote,
                                    pr_flgerlog => vr_flgerlog,
                                    pr_des_log  =>'Alocando lote -> '||
                                                   'cdcooper: '|| pr_cdcooper ||' '||           
                                                   'dtmvtolt: '|| to_char(pr_dtmvtolt,'DD/MM/RRRR')||' '||           
                                                   'cdagenci: '|| pr_cdageope||' '||           
                                                   'cdbccxlt: '|| pr_cdbccxlt||' '||           
                                                   'nrdolote: '|| vr_nrdolote||' '|| 
                                                   'nrdconta: '|| pr_nrdconta||' '|| 
                                                   'cdhistor: '|| pr_cdhistor||' '|| 
                                                   'rotina: CXON0020.pc_enviar_ted ');
      
      FOR vr_contador IN 1..100 LOOP
        BEGIN         
          -- verificar lote
          OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                           pr_dtmvtolt  => pr_dtmvtolt,
                           pr_cdageope  => pr_cdageope,
                           pr_cdbccxlt  => pr_cdbccxlt,
                           pr_nrdolote  => vr_nrdolote);
          FETCH cr_craplot INTO rw_craplot;
          -- se n�o deu erro no fecth � pq o registro n�o esta em lock
          EXIT;           
            
        EXCEPTION
          WHEN OTHERS THEN
            IF cr_craplot%ISOPEN THEN
              CLOSE cr_craplot;
            END IF;
            
            TARI0001.pc_gera_log_lote_uso (pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_nrdolote => vr_nrdolote,
                                           pr_flgerlog => vr_flgerlog,
                                           pr_des_log  => 'Lote ja alocado('||vr_contador||') -> '||
                                                           'cdcooper: '||pr_cdcooper ||' '||           
                                                           'dtmvtolt: '|| to_char(pr_dtmvtolt,'DD/MM/RRRR') ||' '||           
                                                           'cdagenci: '|| pr_cdageope||' '||           
                                                           'cdbccxlt: '|| pr_cdbccxlt||' '||           
                                                           'nrdolote: '|| vr_nrdolote||' '|| 
                                                           'nrdconta: '|| pr_nrdconta||' '|| 
                                                           'cdhistor: '|| pr_cdhistor||' '|| 
                                                           'rotina: CXON0020.pc_enviar_ted');
            
            -- se for a ultima tentativa, guardar a critica
            IF vr_contador = 100 THEN
              pr_dscritic := 'Tabela CRAPLOT em uso(lote: '||vr_nrdolote||').';
            END IF;
            sys.dbms_lock.sleep(0.1);  
        END;
      END LOOP;
      
      -- se encontrou erro ao buscar lote, abortar programa
      IF pr_dscritic IS NOT NULL THEN
        ROLLBACK;
        RETURN;
      END IF;
        
      IF cr_craplot%NOTFOUND THEN
        -- criar registros de lote na tabela
        INSERT INTO craplot
            (dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             tplotmov,
             cdcooper,
             cdoperad,
             nrdcaixa,
             cdopecxa,
             nrseqdig,
             cdhistor)
          VALUES
            (pr_dtmvtolt,
             pr_cdagenci,
             pr_cdbccxlt,
             vr_nrdolote,
             pr_tplotmov,  -- tplotmov
             pr_cdcooper,
             pr_cdoperad,
             pr_nrdcaixa,
             pr_cdopecxa,
             1,            -- nrseqdig
             pr_cdhistor)
           RETURNING ROWID,
                     craplot.dtmvtolt,
                     craplot.cdagenci,
                     craplot.cdbccxlt,
                     craplot.nrdolote,
                     craplot.nrseqdig
                INTO rw_craplot.rowid,
                     rw_craplot.dtmvtolt,
                     rw_craplot.cdagenci,
                     rw_craplot.cdbccxlt,
                     rw_craplot.nrdolote,
                     rw_craplot.nrseqdig;
          
      ELSE
        -- Atualizar lote para reservar nrseqdig
        UPDATE craplot
           SET craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
         WHERE craplot.rowid = rw_craplot.rowid
        RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig; 
        
      END IF;
      CLOSE cr_craplot;
      pr_craplot := rw_craplot;
        
      COMMIT;
      
    EXCEPTION
      WHEN OTHERS THEN
        IF cr_craplot%ISOPEN THEN
          CLOSE cr_craplot;
        END IF;
        
        ROLLBACK;        
        -- se ocorreu algum erro durante a criac?o
        pr_dscritic := 'Erro ao inserir/atualizar lote '||rw_craplot.nrdolote||': '||SQLERRM;
    END pc_insere_lote;
    
    -------------------- Programa Principal -----------------
  BEGIN
    IF pr_idorigem IN (3,4) THEN  /** 3-Internet  4-CASH/TAA **/
      vr_nrcxaope := pr_nrdconta || pr_idseqttl;
    ELSE
      vr_nrcxaope := pr_nrcxaope;
    END IF;
    
    --Eliminar erro
    CXON0000.pc_elimina_erro(pr_cooper      => pr_cdcooper
                            ,pr_cod_agencia => pr_cdageope
                            ,pr_nro_caixa   => vr_nrcxaope
                            ,pr_cdcritic    => vr_cdcritic
                            ,pr_dscritic    => vr_dscritic);
    
    vr_cdcritic := 0;
    vr_dscritic := NULL;
    
    --> Buscar dados cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
      
    --> verificar se encontra registro
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;     
    
    -- Validar data cooper
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se n�o encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
       CLOSE btch0001.cr_crapdat;

      vr_cdcritic := 0;
      vr_dscritic := 'Sistema sem data de movimento.';
      RAISE vr_exc_erro;
    ELSE
       CLOSE btch0001.cr_crapdat;
    END IF;
    
    IF rw_crapcop.flgoppag = 0 /*FALSE*/ AND  -- N�o operando com o pag. (camara de compensacao) 
       rw_crapcop.flgopstr = 0 /*FALSE*/ THEN -- N�o opera com o str. 
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperativa nao esta operando no SPB.';
      RAISE vr_exc_erro;
    END IF;
    
    -- verificar caixa
    IF nvl(pr_cdageope,0) = 0   OR
       nvl(pr_nrcxaope,0) = 0   OR
       pr_cdoperad IS NULL  THEN
      vr_cdcritic := 0;
      vr_dscritic := 'ERRO!!! PA ZERADO. FECHE O CAIXA E AVISE O CPD.';
      RAISE vr_exc_erro;   
    END IF;   
    
    -- Validar cooperado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- verificar se localizou
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crapass;
    END IF;
    
    vr_nrdolote := 23000 + pr_nrcxaope;
    vr_tpdolote := 25;
    vr_cdhistor := 523;
    /* Lote para debito em CC*/
    vr_nrlotlcm := 11000 + pr_nrcxaope;
    vr_tplotlcm := 1;
    rw_craplot_tvl := NULL;
    
    -- Procedimento para inserir o lote e n�o deixar tabela lockada
    pc_insere_lote (pr_cdcooper => rw_crapcop.cdcooper,
                    pr_dtmvtolt => rw_crapdat.dtmvtocd,
                    pr_cdagenci => pr_cdageope,
                    pr_cdbccxlt => 11,
                    pr_nrdolote => vr_nrdolote,
                    pr_tplotmov => vr_tpdolote,
                    pr_cdhistor => vr_cdhistor,
                    pr_cdoperad => pr_cdoperad,
                    pr_nrdcaixa => pr_nrcxaope,
                    pr_cdopecxa => pr_cdoperad,
                    pr_dscritic => vr_dscritic,
                    pr_craplot  => rw_craplot_tvl);
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    /* Busca a proxima sequencia do campo CRAPMAT.NRSEQTED */
    vr_nrseqted := fn_sequence( 'CRAPMAT'
                               ,'NRSEQTED'
                               ,rw_crapcop.cdcooper
                               ,'N');
    -- retornar numero do documento
    pr_nrdocmto := vr_nrseqted;
    
    /* Se alterar numero de controle, ajustar procedure atualiza-doc-ted */
    vr_nrctrlif := '1'||to_char(rw_crapdat.dtmvtocd,'RRMMDD')
                      ||to_char(rw_crapcop.cdagectl,'fm0000')
                      ||to_char(pr_nrdocmto,'fm00000000');
    
    IF pr_flmobile = 1 THEN /* Canal Mobile */
      vr_nrctrlif := vr_nrctrlif ||'M';
    ELSE /* Canal InternetBank */
      vr_nrctrlif := vr_nrctrlif ||'I';
    END IF;
                      
    -- Verificar tranferencia de valores (DOC C, DOC D E TEDS)
    OPEN cr_craptvl (pr_cdcooper => rw_crapcop.cdcooper,
                     pr_nrctrlif => vr_nrctrlif);
    FETCH cr_craptvl INTO rw_craptvl;
    -- se localizou
    IF cr_craptvl%FOUND THEN
      CLOSE cr_craptvl;
      vr_cdcritic := 0;
      vr_dscritic := 'ERRO!!! NR. DOCUMENTO DUPLICADO, TENTE NOVAMENTE.';
      RAISE vr_exc_erro;    
    END IF; 
    
    IF pr_idagenda = 1 THEN

    /* Controle para envio de 2 TEDs iguais pelo ambiente Mobile */
    OPEN cr_craptvl_max( pr_cdcooper => rw_crapcop.cdcooper,
                         pr_dtmvtocd => rw_crapdat.dtmvtocd,
                         pr_cdageope => pr_cdageope,
                         pr_nrdolote => vr_nrdolote,
                         pr_nrdconta => pr_nrdconta,
                         pr_cdbanfav => pr_cdbanfav,
                         pr_cdagefav => pr_cdagefav,
                         pr_nrctafav => pr_nrctafav,
                         pr_vldocmto => pr_vldocmto);
    FETCH cr_craptvl_max INTO rw_craptvl_max;
    
    -- se ja existe um lan�amento com os mesmos dados em menos de 10 minutos (600 seg) apresentar alerta
    IF cr_craptvl_max%FOUND AND 
      (to_char(SYSDATE,'SSSSS') - nvl(rw_craptvl_max.hrtransa,0)) <= 600 THEN
      vr_cdcritic := 0;
        vr_dscritic := 'Ja existe TED de mesmo valor e favorecido. ' ||
                       'Consulte extrato ou tente novamente em 10 min.';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_craptvl_max;
                         
    END IF;
    
    /* Grava uma autenticacao */
    CXON0000.pc_grava_autenticacao_internet 
                          (pr_cooper       => pr_cdcooper     --> Codigo Cooperativa
                          ,pr_nrdconta     => pr_nrdconta     --> Numero da Conta
                          ,pr_idseqttl     => pr_idseqttl     --> Sequencial do titular
                          ,pr_cod_agencia  => pr_cdageope     --> Codigo Agencia
                          ,pr_nro_caixa    => pr_nrcxaope     --> Numero do caixa
                          ,pr_cod_operador => pr_cdoperad     --> Codigo Operador
                          ,pr_valor        => pr_vldocmto     --> Valor da transacao
                          ,pr_docto        => pr_nrdocmto     --> Numero documento
                          ,pr_operacao     => FALSE           --> Indicador Operacao Debito
                          ,pr_status       => '1'             --> Status da Operacao - Online
                          ,pr_estorno      => FALSE           --> Indicador Estorno
                          ,pr_histor       => vr_cdhistor     --> Historico Debito
                          ,pr_data_off     => NULL            --> Data Transacao
                          ,pr_sequen_off   => 0               --> Sequencia
                          ,pr_hora_off     => 0               --> Hora transacao
                          ,pr_seq_aut_off  => 0               --> Sequencia automatica
                          ,pr_cdempres     => NULL            --> Descricao Observacao
                          ,pr_literal      => vr_dslitera     --> Descricao literal lcm
                          ,pr_sequencia    => vr_nrultseq     --> Sequencia Autenticacao
                          ,pr_registro     => pr_nrrectvl     --> ROWID do registro debito
                          ,pr_cdcritic     => vr_cdcritic     --> Codigo do erro
                          ,pr_dscritic     => vr_dscritic);   --> Descricao do erro
    --Se ocorreu erro
    IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
     
    BEGIN
      INSERT INTO craptvl
                (craptvl.cdcooper
                ,craptvl.tpdoctrf
                ,craptvl.idopetrf
                ,craptvl.nrdconta
                ,craptvl.cpfcgemi
                ,craptvl.nmpesemi
                ,craptvl.nrdctitg
                ,craptvl.cdbccrcb
                ,craptvl.cdagercb
                ,craptvl.cpfcgrcb
                ,craptvl.nmpesrcb
                ,craptvl.cdbcoenv
                ,craptvl.vldocrcb
                ,craptvl.dtmvtolt
                ,craptvl.hrtransa
                ,craptvl.nrdolote
                ,craptvl.cdagenci
                ,craptvl.cdbccxlt
                ,craptvl.nrdocmto
                ,craptvl.nrseqdig
                ,craptvl.nrcctrcb
                ,craptvl.cdfinrcb
                ,craptvl.tpdctacr
                ,craptvl.tpdctadb
                ,craptvl.dshistor
                ,craptvl.cdoperad
                ,craptvl.cdopeaut
                ,craptvl.flgespec
                ,craptvl.flgtitul
                ,craptvl.flgenvio
                ,craptvl.nrispbif
                ,craptvl.flgpesdb
                ,craptvl.flgpescr
                ,craptvl.nrautdoc)
         VALUES (rw_crapcop.cdcooper     --> craptvl.cdcooper
                ,3                       --> craptvl.tpdoctrf
                ,vr_nrctrlif             --> craptvl.idopetrf     
                ,pr_nrdconta             --> craptvl.nrdconta
                ,pr_nrcpfcgc             --> craptvl.cpfcgemi
                ,upper(pr_nmprimtl)      --> craptvl.nmpesemi
                ,rw_crapass.nrdctitg     --> craptvl.nrdctitg
                ,pr_cdbanfav             --> craptvl.cdbccrcb
                ,pr_cdagefav             --> craptvl.cdagercb
                ,pr_nrcpffav             --> craptvl.cpfcgrcb
                ,upper(pr_nmfavore)      --> craptvl.nmpesrcb
                ,rw_crapcop.cdbcoctl     --> craptvl.cdbcoenv
                ,pr_vldocmto             --> craptvl.vldocrcb
                ,rw_crapdat.dtmvtocd     --> craptvl.dtmvtolt
                ,gene0002.fn_busca_time  --> craptvl.hrtransa
                ,vr_nrdolote             --> craptvl.nrdolote
                ,pr_cdageope             --> craptvl.cdagenci
                ,11                      --> craptvl.cdbccxlt
                ,pr_nrdocmto             --> craptvl.nrdocmto
                ,rw_craplot_tvl.nrseqdig     --> craptvl.nrseqdig 
                ,pr_nrctafav             --> craptvl.nrcctrcb
                ,pr_cdfinali             --> craptvl.cdfinrcb
                ,pr_tpctafav             --> craptvl.tpdctacr
                ,1  /** Conta Corrente craptvl.tpdctadb**/
                ,pr_dshistor             --> craptvl.dshistor
                ,pr_cdoperad             --> craptvl.cdoperad
                ,pr_cdopeaut             --> craptvl.cdopeaut
                ,0 /*FALSE*/             --> craptvl.flgespec
                ,0 /*FALSE*/             --> craptvl.flgtitul
                ,1 /*true*/              --> craptvl.flgenvio
                ,pr_cdispbif             --> craptvl.nrispbif
                ,vr_nrultseq             --> craptvl.nrautdoc
                ,(CASE pr_inpessoa       --> craptvl.flgpesdb
                    WHEN 1 THEN 1 /*TRUE*/
                    ELSE 0        /*FALSE*/
                  END)
                ,(CASE pr_inpesfav       --> craptvl.flgpescr
                    WHEN 1 THEN 1 /*TRUE*/
                    ELSE 0        /*FALSE*/
                  END))
        RETURNING craptvl.tpdctadb, craptvl.flgtitul
             INTO rw_craptvl.tpdctadb, rw_craptvl.flgtitul;
    EXCEPTION 
      WHEN OTHERS THEN
        vr_dscritic := 'N�o foi possivel inserir transferencia: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    ----------- LAN�AMENTO -----------
    rw_craplot_lcm := NULL;
    -- Cria��o do lote para lan�amento
    pc_insere_lote (pr_cdcooper => rw_crapcop.cdcooper,
                    pr_dtmvtolt => rw_crapdat.dtmvtocd,
                    pr_cdagenci => pr_cdageope,
                    pr_cdbccxlt => 11,
                    pr_nrdolote => vr_nrlotlcm,
                    pr_tplotmov => vr_tplotlcm,
                    pr_cdoperad => pr_cdoperad,
                    pr_nrdcaixa => pr_nrcxaope,
                    pr_cdopecxa => pr_cdoperad,
                    pr_craplot  => rw_craplot_lcm,
                    pr_dscritic => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    -- inicializar valor
    vr_vllanto_aux := 1;
    
    -- Rotina para buscar valor tarifa TED/DOC
    CXON0020.pc_busca_tarifa_ted (pr_cdcooper => rw_crapcop.cdcooper --> Codigo Cooperativa
                                 ,pr_cdagenci => pr_cdageope         --> Codigo Agencia
                                 ,pr_nrdconta => pr_nrdconta         --> Numero da Conta
                                 ,pr_vllanmto => vr_vllanto_aux      --> Valor Lancamento
                                 ,pr_vltarifa => vr_vllantar         --> Valor Tarifa
                                 ,pr_cdhistor => vr_cdhistar         --> Historico da tarifa
                                 ,pr_cdhisest => vr_cdhisest         --> Historico estorno
                                 ,pr_cdfvlcop => vr_cdfvlcop         --> Codigo Filial Cooperativa
                                 ,pr_cdcritic => vr_cdcritic         --> Codigo do erro
                                 ,pr_dscritic => vr_dscritic);       --> Descricao do erro
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    -- definir historico de ted
    vr_cdhisted := 555;
    
    /* Grava uma autenticacao */
    CXON0000.pc_grava_autenticacao_internet 
                          (pr_cooper       => pr_cdcooper     --> Codigo Cooperativa
                          ,pr_nrdconta     => pr_nrdconta     --> Numero da Conta
                          ,pr_idseqttl     => pr_idseqttl     --> Sequencial do titular
                          ,pr_cod_agencia  => pr_cdageope     --> Codigo Agencia
                          ,pr_nro_caixa    => pr_nrcxaope     --> Numero do caixa
                          ,pr_cod_operador => pr_cdoperad     --> Codigo Operador
                          ,pr_valor        => pr_vldocmto     --> Valor da transacao
                          ,pr_docto        => pr_nrdocmto     --> Numero documento
                          ,pr_operacao     => TRUE            --> Indicador Operacao Debito
                          ,pr_status       => '1'             --> Status da Operacao - Online
                          ,pr_estorno      => FALSE           --> Indicador Estorno
                          ,pr_histor       => vr_cdhisted     --> Historico Debito
                          ,pr_data_off     => NULL            --> Data Transacao
                          ,pr_sequen_off   => 0               --> Sequencia
                          ,pr_hora_off     => 0               --> Hora transacao
                          ,pr_seq_aut_off  => 0               --> Sequencia automatica
                          ,pr_cdempres     => NULL            --> Descricao Observacao
                          ,pr_literal      => vr_dslitera     --> Descricao literal lcm
                          ,pr_sequencia    => vr_ultsqlcm     --> Sequencia Autenticacao
                          ,pr_registro     => pr_nrreclcm     --> ROWID do registro debito
                          ,pr_cdcritic     => vr_cdcritic     --> Codigo do erro
                          ,pr_dscritic     => vr_dscritic);   --> Descricao do erro
    --Se ocorreu erro
    IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar dados historico
    OPEN cr_craphis (pr_cdcooper => rw_crapcop.cdcooper,
                     pr_cdhistor => vr_cdhisted);
    FETCH cr_craphis INTO rw_craphis;
    -- se n�o encontrar dados do historico
    IF cr_craphis%NOTFOUND THEN
      vr_cdcritic := 526; -- 526 - Historico nao encontrado.
      vr_dscritic := NULL;
      CLOSE cr_craphis;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_craphis;
    
    -- Verifico se ja existe registro com mesmo nrdocmto, se existir
    -- buscar ultimo sequencial de TED na crapmat                   
    OPEN cr_craplcm ( pr_cdcooper => rw_crapcop.cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_dtmvtolt => rw_crapdat.dtmvtocd,
                      pr_cdagenci => pr_cdageope,
                      pr_nrdolote => vr_nrlotlcm,
                      pr_nrdocmto => pr_nrdocmto);
          
    FETCH cr_craplcm INTO rw_craplcm;
    -- se localizar
    IF cr_craplcm%FOUND THEN
      /* Busca a proxima sequencia do campo CRAPMAT.NRSEQTED */
      vr_nrseqted := fn_sequence( 'CRAPMAT'
                                 ,'NRSEQTED'
                                 ,rw_crapcop.cdcooper
                                 ,'N');
      -- retornar numero do documento
      pr_nrdocmto := vr_nrseqted;
    
    END IF; 
    CLOSE cr_craplcm;
    
    vr_hrtransa := gene0002.fn_busca_time;
    BEGIN
      INSERT INTO craplcm
                  (craplcm.cdcooper
                  ,craplcm.dtmvtolt
                  ,craplcm.hrtransa
                  ,craplcm.cdagenci
                  ,craplcm.cdbccxlt
                  ,craplcm.nrdolote
                  ,craplcm.nrdconta
                  ,craplcm.nrdctabb
                  ,craplcm.nrdctitg
                  ,craplcm.nrdocmto
                  ,craplcm.cdhistor
                  ,craplcm.nrseqdig
                  ,craplcm.vllanmto
                  ,craplcm.vldoipmf
                  ,craplcm.nrautdoc
                  ,craplcm.cdpesqbb)
           VALUES (rw_crapcop.cdcooper               --> craplcm.cdcooper
                  ,rw_crapdat.dtmvtocd               --> craplcm.dtmvtolt
                  ,vr_hrtransa                       --> craplcm.hrtransa
                  ,pr_cdageope                       --> craplcm.cdagenci
                  ,11                                --> craplcm.cdbccxlt
                  ,rw_craplot_lcm.nrdolote               --> craplcm.nrdolote
                  ,pr_nrdconta                       --> craplcm.nrdconta
                  ,pr_nrdconta                       --> craplcm.nrdctabb
                  ,to_char(pr_nrdconta,'fm00000000')   --> craplcm.nrdctitg
                  ,pr_nrdocmto                       --> craplcm.nrdocmto
                  ,rw_craphis.cdhistor               --> craplcm.cdhistor
                  ,rw_craplot_lcm.nrseqdig               --> craplcm.nrseqdig
                  ,pr_vldocmto                       --> craplcm.vllanmto
                  ,0                                 --> craplcm.vldoipmf
                  ,vr_ultsqlcm                       --> craplcm.nrautdoc
                  ,'CRAP020');                       --> craplcm.cdpesqbb
       
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- se deu problema de chave duplicada, solicitar que usuario tente novamente para buscar novo sequencial
        vr_dscritic := 'N�o foi possivel enviar TED, tente novamente ou comunique seu PA.';
        RAISE vr_exc_erro;
      WHEN OTHERS THEN
        vr_dscritic := 'N�o foi possivel gerar lcm:'||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    IF vr_vllantar <> 0 THEN
			
		  /* Verificar isen��o ou n�o de tarifa */
		  TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => rw_crapcop.cdcooper -- Cooperativa
																					,pr_cdoperad => '888'               -- Operador
																					,pr_cdagenci => 1                   -- PA
																					,pr_cdbccxlt => 100                 -- Banco
																					,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data de movimento
																					,pr_cdprogra => 'CXON0020'          -- C�d. do programa
																					,pr_idorigem => 2                   -- Id. de origem
																					,pr_nrdconta => pr_nrdconta         -- N�mero da conta
																					,pr_tipotari => 12                  -- Tipo de tarifa 12 - TED Eletr�nico
																					,pr_tipostaa => 0                   -- Tipo TAA
																					,pr_qtoperac => 1                   -- Quantidade de opera��es
																					,pr_qtacobra => vr_qtacobra         -- Quantidade de opera��es a serem tarifadas
																					,pr_fliseope => vr_fliseope         -- Identificador de isen��o de tarifa (0 - nao isenta/1 - isenta)
																					,pr_cdcritic => vr_cdcritic         -- C�d. da cr�tica
																					,pr_dscritic => vr_dscritic);       -- Desc. da cr�tica

      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Exececao
        RAISE vr_exc_erro;
      END IF;
		
      -- Buscar dados historico
      OPEN cr_craphis (pr_cdcooper => rw_crapcop.cdcooper,
                       pr_cdhistor => vr_cdhistar);
      FETCH cr_craphis INTO rw_craphis;
      -- se n�o encontrar dados do historico
      IF cr_craphis%NOTFOUND THEN
        vr_cdcritic := 526; -- 526 - Historico nao encontrado.
        vr_dscritic := NULL;
        CLOSE cr_craphis;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_craphis; 
      
            
      --Limpar tabela saldo e erro
      vr_tab_saldo.DELETE;
      vr_tab_erro.DELETE;
      
      /** Verifica se possui saldo para fazer a operacao **/

      EXTR0001.pc_obtem_saldo_dia (pr_cdcooper   => rw_crapcop.cdcooper
                                  ,pr_rw_crapdat => rw_crapdat
                                  ,pr_cdagenci   => pr_cdageope
                                  ,pr_nrdcaixa   => pr_nrcxaope
                                  ,pr_cdoperad   => pr_cdoperad
                                  ,pr_nrdconta   => pr_nrdconta
                                  ,pr_vllimcre   => rw_crapass.vllimcre
                                  ,pr_tipo_busca => 'A' --> tipo de busca(A-dtmvtoan)
                                  ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                  ,pr_flgcrass   => FALSE                                                        
                                  ,pr_des_reto   => vr_dscritic
                                  ,pr_tab_sald   => vr_tab_saldo
                                  ,pr_tab_erro   => vr_tab_erro);
                                  
      --Se ocorreu erro
      IF vr_dscritic = 'NOK' THEN
        -- Tenta buscar o erro no vetor de erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrdconta;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informacao na pr_tab_erro, Conta: '||pr_nrdconta;

        END IF;

        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      
      --Verificar o saldo retornado
      IF vr_tab_saldo.Count = 0 THEN
        
        --Montar mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      ELSE
        --Total disponivel recebe valor disponivel + limite credito
        vr_vlsldisp:= nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) + nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
        
        --Se o saldo nao for suficiente
        IF vr_vlsldisp >= vr_vllantar THEN

          vr_debtarifa := TRUE;

        END IF;

      END IF;

	    -- Se n�o isenta cobran�a da tarifa
      IF vr_fliseope <> 1 THEN

        IF pr_idagenda = 1 OR
           vr_debtarifa    THEN 
          --Realizar lancamento tarifa
          TARI0001.pc_lan_tarifa_online (pr_cdcooper => rw_crapcop.cdcooper  --Codigo Cooperativa
                                        ,pr_cdagenci => 1                    --Codigo Agencia destino
                                        ,pr_nrdconta => pr_nrdconta          --Numero da Conta Destino
                                        ,pr_cdbccxlt => 100                  --Codigo banco/caixa
                                        ,pr_nrdolote => 7999                 --Numero do Lote
                                        ,pr_tplotmov => 1                    --Tipo Lote
                                        ,pr_cdoperad => 888                  --Codigo Operador
                                        ,pr_dtmvtlat => rw_crapdat.dtmvtolt  --Data Tarifa
                                        ,pr_dtmvtlcm => rw_crapdat.dtmvtocd  --Data lancamento
                                        ,pr_nrdctabb => pr_nrdconta         --Numero Conta BB
                                        ,pr_nrdctitg => to_char(pr_nrdconta,'fm00000000')         --Conta Integracao
                                        ,pr_cdhistor => vr_cdhistar          --Codigo Historico
                                        ,pr_cdpesqbb => 'CRAP020'            --Codigo pesquisa
                                        ,pr_cdbanchq => 0                    --Codigo Banco Cheque
                                        ,pr_cdagechq => 0                    --Codigo Agencia Cheque
                                        ,pr_nrctachq => 0                    --Numero Conta Cheque
                                        ,pr_flgaviso => FALSE                --Flag Aviso
                                        ,pr_tpdaviso => 0                    --Tipo Aviso
                                        ,pr_vltarifa => vr_vllantar          --Valor tarifa
                                        ,pr_nrdocmto => pr_nrdocmto          --Numero Documento
                                        ,pr_cdcoptfn => rw_crapcop.cdcooper  --Codigo Cooperativa Terminal
                                        ,pr_cdagetfn => rw_crapass.cdagenci  --Codigo Agencia Terminal
                                        ,pr_nrterfin => 0                    --Numero Terminal Financeiro
                                        ,pr_nrsequni => 0                    --Numero Sequencial Unico
                                        ,pr_nrautdoc => rw_craplot_lcm.nrseqdig + 1 --Numero Autenticacao Documento
                                        ,pr_dsidenti => NULL                 --Descricao Identificacao
                                        ,pr_cdfvlcop => vr_cdfvlcop          --Codigo Faixa Valor Cooperativa
                                        ,pr_inproces => rw_crapdat.inproces  --Indicador Processo
                                        ,pr_cdlantar => vr_cdlantar          --Codigo Lancamento tarifa
                                        ,pr_tab_erro => vr_tab_erro          --Tabela de erro
                                        ,pr_cdcritic => vr_cdcritic          --Codigo do erro
                                        ,pr_dscritic => vr_dscritic);        --Descricao do erro

          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Se tem informacoes no vetor erro
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic:= 0;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel lancar a tarifa.';
            END IF;
            --Levantar Exececao
            RAISE vr_exc_erro;
          END IF;

        ELSE
          
          --Inicializar variavel retorno erro
          TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                           ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --Data Lancamento
                                           ,pr_cdhistor => vr_cdhistar   --Codigo Historico
                                           ,pr_vllanaut => vr_vllantar   --Valor lancamento automatico
                                           ,pr_cdoperad => 888   --Codigo Operador
                                           ,pr_cdagenci => 1   --Codigo Agencia
                                           ,pr_cdbccxlt => 100   --Codigo banco caixa
                                           ,pr_nrdolote => 7999   --Numero do lote
                                           ,pr_tpdolote => 1   --Tipo do lote
                                           ,pr_nrdocmto => pr_nrdocmto   --Numero do documento
                                           ,pr_nrdctabb => pr_nrdconta   --Numero da conta
                                           ,pr_nrdctitg => to_char(pr_nrdconta,'fm00000000')   --Numero da conta integracao
                                           ,pr_cdpesqbb => 'CRAP020'   --Codigo pesquisa
                                           ,pr_cdbanchq => 0   --Codigo Banco Cheque
                                           ,pr_cdagechq => 0   --Codigo Agencia Cheque
                                           ,pr_nrctachq => 0   --Numero Conta Cheque
                                           ,pr_flgaviso => FALSE   --Flag aviso
                                           ,pr_tpdaviso => 0   --Tipo aviso
                                           ,pr_cdfvlcop => vr_cdfvlcop   --Codigo cooperativa
                                           ,pr_inproces => rw_crapdat.inproces   --Indicador processo
                                           ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                           ,pr_tab_erro => vr_tab_erro   --Tabela retorno erro
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica
                                           
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Se tem informacoes no vetor erro
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic:= 0;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel lancar a tarifa.';
            END IF;
            --Levantar Exececao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF;
    END IF;
    
    -- Procedimento para envio do TED para o SPB
    SSPB0001.pc_proc_envia_tec_ted 
                          (pr_cdcooper =>  rw_crapcop.cdcooper  --> Cooperativa
                          ,pr_cdagenci =>  pr_cdageope          --> Cod. Agencia  
                          ,pr_nrdcaixa =>  pr_nrcxaope          --> Numero  Caixa  
                          ,pr_cdoperad =>  pr_cdoperad          --> Operador     
                          ,pr_titulari =>  (rw_craptvl.flgtitul = 1) --> Mesmo Titular.
                          ,pr_vldocmto =>  pr_vldocmto          --> Vlr. DOCMTO    
                          ,pr_nrctrlif =>  vr_nrctrlif          --> NumCtrlIF   
                          ,pr_nrdconta =>  pr_nrdconta          --> Nro Conta
                          ,pr_cdbccxlt =>  pr_cdbanfav          --> Codigo Banco 
                          ,pr_cdagenbc =>  pr_cdagefav          --> Cod Agencia 
                          ,pr_nrcctrcb =>  pr_nrctafav          --> Nr.Ct.destino   
                          ,pr_cdfinrcb =>  pr_cdfinali          --> Finalidade     
                          ,pr_tpdctadb =>  rw_craptvl.tpdctadb  --> Tp. conta deb 
                          ,pr_tpdctacr =>  pr_tpctafav          --> Tp conta cred  
                          ,pr_nmpesemi =>  pr_nmprimtl          --> Nome Do titular 
                          ,pr_nmpesde1 =>  NULL                 --> Nome De 2TTT 
                          ,pr_cpfcgemi =>  pr_nrcpfcgc          --> CPF/CNPJ Do titular 
                          ,pr_cpfcgdel =>  0                    --> CPF sec TTL
                          ,pr_nmpesrcb =>  pr_nmfavore          --> Nome Para 
                          ,pr_nmstlrcb =>  NULL                 --> Nome Para 2TTL
                          ,pr_cpfcgrcb =>  pr_nrcpffav          --> CPF/CNPJ Para
                          ,pr_cpstlrcb =>  0                    --> CPF Para 2TTL
                          ,pr_tppesemi =>  pr_inpessoa          --> Tp. pessoa De  
                          ,pr_tppesrec =>  pr_inpesfav          --> Tp. pessoa Para 
                          ,pr_flgctsal =>  FALSE                --> CC Sal
                          ,pr_cdidtran =>  pr_dstransf          --> tipo de transferencia
                          ,pr_cdorigem =>  pr_idorigem          --> Cod. Origem    
                          ,pr_dtagendt =>  NULL                 --> data egendamento
                          ,pr_nrseqarq =>  0                    --> nr. seq arq.
                          ,pr_cdconven =>  0                    --> Cod. Convenio
                          ,pr_dshistor =>  pr_dshistor          --> Dsc do Hist.  
                          ,pr_hrtransa =>  vr_hrtransa          --> Hora transacao 
                          ,pr_cdispbif =>  pr_cdispbif          --> ISPB Banco
                          --------- SAIDA  --------
                          ,pr_cdcritic =>  vr_cdcritic          --> Codigo do erro
                          ,pr_dscritic =>  vr_dscritic );	    --> Descricao do erro
                          
    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    tari0001.pc_gera_log_lote_uso( pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrdolote => vr_nrdolote,
                                   pr_flgerlog => vr_flgerlog,
                                   pr_des_log  => 'Alocando lote -> '||
                                                   'cdcooper: '|| pr_cdcooper ||' '||           
                                                   'dtmvtolt: '|| to_char(rw_craplot_tvl.dtmvtolt,'DD/MM/RRRR')||' '||           
                                                   'cdagenci: '|| rw_craplot_tvl.cdagenci||' '||           
                                                   'cdbccxlt: '|| rw_craplot_tvl.cdbccxlt||' '||           
                                                   'nrdolote: '|| rw_craplot_tvl.nrdolote||' '|| 
                                                   'nrdconta: '|| pr_nrdconta||' '|| 
                                                   'cdhistor: '|| rw_craplot_tvl.cdhistor||' '|| 
                                                   'rotina: CXON0020.pc_enviar_ted');
    
    -- verificar se lote esta lockado
    IF fn_verifica_lote_uso(pr_rowid => rw_craplot_tvl.rowid ) = 1 THEN
      vr_dscritic:= 'Registro de lote '||rw_craplot_tvl.nrdolote||' em uso. Tente novamente.';  
      tari0001.pc_gera_log_lote_uso( pr_cdcooper => pr_cdcooper,
                                     pr_nrdconta => pr_nrdconta,
                                     pr_nrdolote => vr_nrdolote,
                                     pr_flgerlog => vr_flgerlog,
                                     pr_des_log  => 'ERRO: Lote j� alocado -> '||
                                                     'cdcooper: '|| pr_cdcooper ||' '||           
                                                     'dtmvtolt: '|| to_char(rw_craplot_tvl.dtmvtolt,'DD/MM/RRRR')||' '||           
                                                     'cdagenci: '|| rw_craplot_tvl.cdagenci||' '||           
                                                     'cdbccxlt: '|| rw_craplot_tvl.cdbccxlt||' '||           
                                                     'nrdolote: '|| rw_craplot_tvl.nrdolote||' '|| 
                                                     'nrdconta: '|| pr_nrdconta||' '|| 
                                                     'cdhistor: '|| rw_craplot_tvl.cdhistor||' '|| 
                                                     'rotina: CXON0020.pc_enviar_ted');
      -- apensa jogar critica em log
      RAISE vr_exc_log;
    END IF;
    
    -- Atualizar lote para craptvl
    BEGIN
      UPDATE craplot
         SET craplot.qtcompln = nvl(craplot.qtcompln,0) + 1,
             craplot.vlcompcr = nvl(craplot.vlcompcr,0) + pr_vldocmto,
             craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1,
             craplot.vlinfocr = nvl(craplot.vlinfocr,0) + pr_vldocmto
       WHERE craplot.rowid = rw_craplot_tvl.rowid; 
    EXCEPTION 
      WHEN OTHERS THEN
        vr_dscritic := 'N�o foi possivel atualizar lote '||rw_craplot_tvl.nrdolote||' :'||SQLERRM;
        -- apensa jogar critica em log
        RAISE vr_exc_log;
    END;
    
    tari0001.pc_gera_log_lote_uso( pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrdolote => vr_nrdolote,
                                   pr_flgerlog => vr_flgerlog,
                                   pr_des_log  => 'Alocando lote -> '||
                                                   'cdcooper: '|| pr_cdcooper ||' '||           
                                                   'dtmvtolt: '|| to_char(rw_craplot_lcm.dtmvtolt,'DD/MM/RRRR')||' '||           
                                                   'cdagenci: '|| rw_craplot_lcm.cdagenci||' '||           
                                                   'cdbccxlt: '|| rw_craplot_lcm.cdbccxlt||' '||           
                                                   'nrdolote: '|| rw_craplot_lcm.nrdolote||' '|| 
                                                   'nrdconta: '|| pr_nrdconta||' '|| 
                                                   'cdhistor: '|| rw_craplot_lcm.cdhistor||' '|| 
                                                   'rotina: CXON0020.pc_enviar_ted');
                                                 
    -- verificar se lote esta lockado
    IF fn_verifica_lote_uso(pr_rowid => rw_craplot_lcm.rowid ) = 1 THEN
      vr_dscritic:= 'Registro de lote '||rw_craplot_lcm.nrdolote||' em uso. Tente novamente.';  
      tari0001.pc_gera_log_lote_uso( pr_cdcooper => pr_cdcooper,
                                     pr_nrdconta => pr_nrdconta,
                                     pr_nrdolote => vr_nrdolote,
                                     pr_flgerlog => vr_flgerlog,
                                     pr_des_log  => 'ERRO: Lote ja alocado -> '||
                                                     'cdcooper: '|| pr_cdcooper ||' '||           
                                                     'dtmvtolt: '|| to_char(rw_craplot_lcm.dtmvtolt,'DD/MM/RRRR')||' '||           
                                                     'cdagenci: '|| rw_craplot_lcm.cdagenci||' '||           
                                                     'cdbccxlt: '|| rw_craplot_lcm.cdbccxlt||' '||           
                                                     'nrdolote: '|| rw_craplot_lcm.nrdolote||' '|| 
                                                     'nrdconta: '|| pr_nrdconta||' '|| 
                                                     'cdhistor: '|| rw_craplot_lcm.cdhistor||' '|| 
                                                     'rotina: CXON0020.pc_enviar_ted');
      -- apensa jogar critica em log
      RAISE vr_exc_log;
    END IF;
    
    -- Atualizar lote para craplcm
    BEGIN
      UPDATE craplot
         SET craplot.qtcompln = nvl(craplot.qtcompln,0) + 1,
             craplot.vlcompdb = nvl(craplot.vlcompdb,0) + pr_vldocmto,
             craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1,
             craplot.vlinfodb = nvl(craplot.vlinfodb,0) + pr_vldocmto
       WHERE craplot.rowid = rw_craplot_lcm.rowid; 
    EXCEPTION 
      WHEN OTHERS THEN
        vr_dscritic := 'N�o foi possivel atualizar lote '||rw_craplot_lcm.nrdolote||' :'||SQLERRM;
        -- apensa jogar critica em log
        RAISE vr_exc_log;
    END;   
                          
		IF pr_flmobile = 1 THEN
			vr_idorigem := 9;
		ELSE
			IF pr_idorigem = 0 THEN
				vr_idorigem := 7;
			ELSE 
				vr_idorigem := pr_idorigem;
			END IF;
    END IF;
		
   /* GRAVA LOG OPERADOR CARTAO */
    CADA0004.pc_gera_log_ope_cartao 
                          (pr_cdcooper        => pr_cdcooper     --> Codigo Cooperativa
                          ,pr_nrdconta        => pr_nrdconta     --> Numero da Conta
                          ,pr_indoperacao     => 3               --> TED
                          ,pr_cdorigem        => vr_idorigem
                          ,pr_indtipo_cartao  => 0
                          ,pr_nrdocmto        => pr_nrdocmto
                          ,pr_cdhistor        => vr_cdhisted
                          ,pr_nrcartao        => 0
                          ,pr_vllanmto        => pr_vldocmto
                          ,pr_cdoperad        => pr_cdoperad     
                          ,pr_cdbccrcb        => pr_cdbanfav     
                          ,pr_cdfinrcb        => pr_cdfinali
													,pr_cdpatrab        => pr_cdageope     
													,pr_nrseqems        => 0 
													,pr_nmreceptor      => ''
													,pr_nrcpf_receptor  => 0
                          ,pr_dscritic        => vr_dscritic);   --> Descricao do erro
    --Se ocorreu erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;		  
                          
    COMMIT;
    pr_des_erro := 'OK';
  EXCEPTION
    --> exception para apenas gerar log e n�o abortar envio de TED, pois 
     -- script j� foi executado 
    WHEN vr_exc_log THEN
      /* Se aconteceu erro, gera o log e envia o erro por e-mail */
      vr_nmarqlog := 'proc_message.log';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||' - '||
                                                    'CXON0020 - enviar-ted'               ||
                                                    ' - ERRO APOS ENVIAR TED  --> '              ||
                                                    'Cooperativa: '     || to_char(pr_cdcooper, '990')           ||
                                                    ', Conta: '         || gene0002.fn_mask_conta(pr_nrdconta)   ||
                                                    ', Documento: '     || to_char(pr_nrdocmto,'999G999G999G990')||
                                                    ', Valor: '         || to_char(pr_vldocmto,'999G999G999G990D00') ||
                                                    ', Banco Fav.: '    || pr_cdbanfav ||
                                                    ', Agencia Fav.: '  || pr_cdagefav ||
                                                    ', Conta Fav.: '    || pr_nrctafav ||
                                                    ', Critica: '       || vr_dscritic,
                                 pr_nmarqlog     => vr_nmarqlog);

      -- buscar destinatarios do email                           
      vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_ENVIO_TED');
      
      -- Gravar conteudo do email, controle com substr para n�o estourar campo texto
      vr_conteudo := substr('ERRO APOS ENVIAR TED '|| 
                     '<br>Cooperativa: '    || to_char(pr_cdcooper, '990')           ||
                      '<br>Conta: '         || gene0002.fn_mask_conta(pr_nrdconta)   ||
                      '<br>Documento: '     || to_char(pr_nrdocmto,'999G999G999G990')||
                      '<br>Valor: '         || to_char(pr_vldocmto,'999G999G999G990D00') ||
                      '<br>Banco Fav.: '    || pr_cdbanfav ||
                      '<br>Agencia Fav.: '  || pr_cdagefav ||
                      '<br>Conta Fav.: '    || pr_nrctafav ||
                      '<br>Critica: '       || vr_dscritic,1,4000);
                      
      vr_dscritic := NULL;
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'CXON0020'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'Erro apos envio TED - CXON0020'
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser� do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      vr_dscritic := NULL;  
      COMMIT;
      pr_des_erro := 'OK';
      
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) = 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := 'Erro ao efetuar o envio da TED. Tente Novamente.';
      END IF;
      
      -- rollback do ted
      ROLLBACK;
      
      --Criar Erro
      CXON0000.pc_cria_erro( pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => pr_cdageope
                            ,pr_nrdcaixa => vr_nrcxaope
                            ,pr_cod_erro => vr_cdcritic
                            ,pr_dsc_erro => vr_dscritic
                            ,pr_flg_erro => TRUE
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
      pr_des_erro := 'NOK'; 
    WHEN OTHERS THEN

      -- rollback do ted
      ROLLBACK;
      
      vr_dscritic := 'Erro ao efetuar o envio da TED. Tente Novamente.:'||SQLERRM;
      CXON0000.pc_cria_erro( pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => pr_cdageope
                            ,pr_nrdcaixa => vr_nrcxaope
                            ,pr_cod_erro => 0
                            ,pr_dsc_erro => vr_dscritic
                            ,pr_flg_erro => TRUE
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
      pr_des_erro := 'NOK'; 
  END pc_enviar_ted;


  /******************************************************************************/
  /**             Procedure para executar o envio da TED                       **/
  /******************************************************************************/
  PROCEDURE pc_executa_envio_ted 
                          (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa    
                          ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Agencia
                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Caixa Operador    
                          ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador Autorizacao
                          ,pr_idorigem IN INTEGER                --> Origem                 
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                          ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta Remetente        
                          ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular                
                          ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --> CPF operador juridico
                          ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Banco destino
                          ,pr_cdageban IN crapcti.cdageban%TYPE  --> Agencia destino
                          ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Conta transferencia
                          ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> nome do titular destino
                          ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> CPF do titular destino
                          ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Tipo de pessoa
                          ,pr_intipcta IN crapcti.intipcta%TYPE  --> Tipo de conta
                          ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lan�amento
                          ,pr_dstransf IN VARCHAR2               --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER                --> Finalidade TED
                          ,pr_dshistor IN VARCHAR2               --> Descri�ao do Hist�rico
                          ,pr_cdispbif IN INTEGER                --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0      --> Indicador se origem � do Mobile
                          ,pr_idagenda IN INTEGER                --> Tipo de agendamento
                          -- saida
                          ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Retorna protocolo    
                          ,pr_tab_protocolo_ted OUT cxon0020.typ_tab_protocolo_ted --> dados do protocolo
                          ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do erro

  /*---------------------------------------------------------------------------------------------------------------
  
      Programa : pc_executa_envio_ted             Antigo: b1wgen0015/executa-envio-ted
      Sistema  : Rotinas acessadas pelas telas de cadastros Web
      Sigla    : CRED
      Autor    : Odirlei Busana - Amcom
      Data     : Junho/2015.                   Ultima atualizacao: 09/06/2015
  
      Dados referentes ao programa:
  
      Frequencia: Sempre que for chamado
      Objetivo  : Procedure para executar o envio da TED
    
      Altera��o : 09/06/2015 - Convers�o Progress -> Oracle (Odirlei-Amcom)
    
                  08/10/2015 - Ajustado para gerar o numero da conta no protocolo com "."
                               conforme progress SD341797 (Odirlei-Amcom)
  ---------------------------------------------------------------------------------------------------------------*/
    ---------------> CURSORES <-----------------        
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.nmprimtl,
             crapass.inpessoa,
             crapass.nrcpfcgc,
             crapass.nrdctitg,
             crapass.cdagenci,
             crapass.idastcjt
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;  
    rw_crabass cr_crapass%ROWTYPE;  
    
    -- Verificar cadasto de senhas
    CURSOR cr_crapsnh (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_idseqttl crapttl.idseqttl%TYPE,
                       pr_nrcpfcgc crapttl.nrcpfcgc%TYPE) IS
      SELECT crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.nrcpfcgc
            ,crapsnh.vllimweb
            ,crapsnh.vllimtrf
            ,crapsnh.vllimted
            ,crapsnh.idseqttl
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND (crapsnh.idseqttl = pr_idseqttl OR pr_idseqttl = 0)
         AND crapsnh.tpdsenha = 1
         AND (crapsnh.nrcpfcgc = pr_nrcpfcgc OR pr_nrcpfcgc = 0);
    rw_crapsnh cr_crapsnh%ROWTYPE;
    
    -- Verificar cadasto de senhas
    CURSOR cr_crapavt (pr_cdcooper crapavt.cdcooper%TYPE,
                       pr_nrdconta crapavt.nrdconta%TYPE,
                       pr_nrcpfcgc crapavt.nrcpfcgc%TYPE) IS
      SELECT crapavt.cdcooper
            ,crapavt.nrdconta
            ,crapavt.nrdctato
            ,crapavt.nmdavali
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.tpctrato = 6
         AND crapavt.nrcpfcgc = pr_nrcpfcgc;
    rw_crapavt cr_crapavt%ROWTYPE; 
    
    -- Buscar titulares
    CURSOR cr_crapttl ( pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE,
                        pr_idseqttl crapttl.idseqttl%TYPE)  IS
      SELECT ttl.nmextttl
            ,ttl.inpessoa
            ,ttl.idseqttl
            ,ttl.nrcpfcgc
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl ;
    rw_crapttl cr_crapttl%ROWTYPE;
    
    -- buscar erro
    CURSOR cr_craperr(pr_cdcooper craperr.cdcooper%TYPE,
                      pr_cdagenci craperr.cdagenci%TYPE,
                      pr_nrdcaixa craperr.nrdcaixa%TYPE) IS
      SELECT craperr.dscritic
        FROM craperr
       WHERE craperr.cdcooper = pr_cdcooper
         AND craperr.cdagenci = pr_cdagenci
         AND craperr.nrdcaixa = pr_nrdcaixa;   
    
    -- localizar crapaut
    CURSOR cr_crapaut (pr_rowid ROWID) IS
      SELECT crapaut.dtmvtolt,
             crapaut.hrautent,
             crapaut.nrsequen,
             crapaut.nrdcaixa
        FROM crapaut
       WHERE crapaut.rowid = pr_rowid
       FOR UPDATE NOWAIT;
    rw_crapaut cr_crapaut%ROWTYPE;  
    
    -- Validar banco
    CURSOR cr_crapban (pr_cdispbif crapban.nrispbif%TYPE) IS
      SELECT flgdispb,
             nmextbcc
        FROM crapban 
       WHERE crapban.nrispbif = pr_cdispbif;
       
    CURSOR cr_crapban2 (pr_cdbccxlt crapban.cdbccxlt%TYPE) IS
      SELECT flgdispb,
             nmextbcc
        FROM crapban 
       WHERE crapban.cdbccxlt = pr_cdbccxlt;
          
    rw_crapban cr_crapban%ROWTYPE;

    CURSOR cr_crappod(pr_cdcooper crappod.cdcooper%TYPE
                     ,pr_nrdconta crappod.nrdconta%TYPE) IS
      SELECT pod.cdcooper,
             pod.nrdconta,
             pod.nrcpfpro
        FROM crappod pod
       WHERE pod.cdcooper = pr_cdcooper
         AND pod.nrdconta = pr_nrdconta
         AND pod.cddpoder = 10
         AND pod.flgconju = 1;
          
    rw_crappod cr_crappod%ROWTYPE;
    
    -- Buscar dados agencia favorecido
    CURSOR cr_crapagb (pr_cddbanco crapagb.cddbanco%TYPE,
                       pr_cdageban crapagb.cdageban%TYPE) IS
      SELECT gene0007.fn_caract_acento(crapagb.nmageban,1) nmageban 
        FROM crapagb
       WHERE crapagb.cddbanco = pr_cddbanco
         AND crapagb.cdageban = pr_cdageban;
    rw_crapagb cr_crapagb%ROWTYPE;
    
    -- Buscar dados protocolo
    CURSOR cr_crappro (pr_cdcooper crappro.cdcooper%TYPE,
                       pr_dsprotoc crappro.dsprotoc%TYPE) IS
      SELECT crappro.cdtippro,
             crappro.dtmvtolt,
             crappro.dttransa,
             crappro.hrautent,
             crappro.vldocmto,
             crappro.nrdocmto,
             crappro.nrseqaut,
             crappro.dsinform##1,
             crappro.dsinform##2,
             crappro.dsinform##3,
             crappro.dsprotoc,
             crappro.nmprepos,
             crappro.nrcpfpre,
             crappro.nrcpfope
        FROM crappro
       WHERE crappro.cdcooper = pr_cdcooper
         AND upper(crappro.dsprotoc) = upper(pr_dsprotoc);
    rw_crappro cr_crappro%ROWTYPE;
         
    -- Buscar dados operador juridico
    CURSOR cr_crapopi (pr_cdcooper crapopi.cdcooper%TYPE,
                       pr_nrdconta crapopi.nrdconta%TYPE,
                       pr_nrcpfope crapopi.nrcpfope%TYPE) IS
      SELECT crapopi.nmoperad
        FROM crapopi
       WHERE crapopi.cdcooper = pr_cdcooper
         AND crapopi.nrdconta = pr_nrdconta
         AND crapopi.nrcpfope = pr_nrcpfope;
    rw_crapopi cr_crapopi%rowtype;     
         
    ------------> ESTRUTURAS DE REGISTRO <-----------
    
    --Tabela de mem�ria de limites de horario
    vr_tab_limite INET0001.typ_tab_limite;
    vr_index      PLS_INTEGER;
                                       
    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_tab_erro GENE0001.typ_tab_erro;
    vr_des_erro VARCHAR2(50);
    
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
      
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_exc_log  EXCEPTION;
    
    vr_nmextttl crapttl.nmextttl%TYPE;
    vr_nmprepos crapass.nmprimtl%TYPE;
    vr_nrcpfcgc crapttl.nrcpfcgc%TYPE;
    vr_nrdocmto craplcm.nrdocmto%TYPE;
    vr_nrrectvl ROWID;
    vr_nrreclcm ROWID;
    vr_dstextab craptab.dstextab%TYPE;
    vr_dsinfor1 crappro.dsinform##1%TYPE;
    vr_dsinfor2 crappro.dsinform##1%TYPE;
    vr_dsinfor3 crappro.dsinform##3%TYPE;
    vr_dscpfcgc VARCHAR2(100);
    vr_idxpro   PLS_INTEGER;
    vr_cddbanco VARCHAR2(100);
    vr_nmarqlog VARCHAR2(100);
    vr_email_dest VARCHAR2(500);
    vr_conteudo   VARCHAR2(4000);
    
  BEGIN
    
    --> Buscar dados cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
      
    --> verificar se encontra registro
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'Registro de cooperativa nao encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;
  
    -- Buscar dados associados
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
      
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;
      
    -- Verificar cadastro de senha
    OPEN cr_crapsnh (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_idseqttl => pr_idseqttl,
                     pr_nrcpfcgc => 0); 
    IF cr_crapsnh%NOTFOUND THEN
      CLOSE cr_crapsnh;
      vr_dscritic := 'Senha para conta on-line nao cadastrada';
      RAISE vr_exc_erro;
    END IF;    
    CLOSE cr_crapsnh;
      
    -- se for pessoa juridica
    IF rw_crapass.inpessoa = 1 THEN
      -- buscar dados titular
      OPEN cr_crapttl (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_idseqttl => pr_idseqttl);
      FETCH cr_crapttl INTO rw_crapttl;
      
      IF cr_crapttl%NOTFOUND THEN
        CLOSE cr_crapttl;
        vr_dscritic := 'Titular nao cadastrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapttl;
      
      vr_nmextttl := rw_crapttl.nmextttl;
      vr_nrcpfcgc := rw_crapttl.nrcpfcgc;
    
    ELSE
      
      vr_nmextttl := rw_crapass.nmprimtl;
      vr_nrcpfcgc := rw_crapass.nrcpfcgc;
      
      -- Buscar dados do preposto apenas quando nao possuir 
      -- assinatura multipla
      IF rw_crapass.idastcjt = 0 THEN
      
        -- Buscar dados de avalista
        OPEN cr_crapavt (pr_cdcooper => rw_crapsnh.cdcooper,
                         pr_nrdconta => rw_crapsnh.nrdconta,
                         pr_nrcpfcgc => rw_crapsnh.nrcpfcgc);
        FETCH cr_crapavt INTO rw_crapavt;               
        IF cr_crapavt%FOUND THEN
          CLOSE cr_crapavt;
            
          -- Buscar dados associados preposto
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => rw_crapavt.nrdctato);
          FETCH cr_crapass INTO rw_crabass;
          IF cr_crapass%FOUND THEN
            vr_nmprepos := rw_crabass.nmprimtl;
          ELSE
            vr_nmprepos := rw_crapavt.nmdavali;
          END IF;
          CLOSE cr_crapass;
            
        END IF;
        CLOSE cr_crapavt;
        
      END IF;
      
    END IF;
    
    --Atualizar registro movimento da internet
    IF rw_crapass.idastcjt = 0 THEN
      BEGIN
        UPDATE crapmvi 
           SET crapmvi.vlmovted = crapmvi.vlmovted + pr_vllanmto
        WHERE crapmvi.cdcooper = pr_cdcooper
        AND   crapmvi.nrdconta = pr_nrdconta
        AND   crapmvi.idseqttl = pr_idseqttl
        AND   crapmvi.dtmvtolt = pr_dtmvtolt;
        --Nao atualizou nenhum registro
        IF SQL%ROWCOUNT = 0 THEN
          -- Cria o registro do movimento da internet
          BEGIN
            INSERT INTO crapmvi
                   (crapmvi.cdcooper
                   ,crapmvi.cdoperad
                   ,crapmvi.dtmvtolt
                   ,crapmvi.dttransa
                   ,crapmvi.hrtransa
                   ,crapmvi.idseqttl
                   ,crapmvi.nrdconta
                   ,crapmvi.vlmovted)
            VALUES (pr_cdcooper
                   ,pr_cdoperad
                   ,pr_dtmvtolt
                   ,trunc(SYSDATE)
                   ,GENE0002.fn_busca_time
                   ,pr_idseqttl
                   ,pr_nrdconta
                   ,pr_vllanmto);
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao inserir movimento na internet. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar movimento na internet. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
    ELSE
      FOR rw_crappod IN cr_crappod(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta) LOOP
        OPEN cr_crapsnh(pr_cdcooper => rw_crappod.cdcooper
                       ,pr_nrdconta => rw_crappod.nrdconta
                       ,pr_idseqttl => 0
                       ,pr_nrcpfcgc => rw_crappod.nrcpfpro);
                                
        FETCH cr_crapsnh INTO rw_crapsnh;

        IF cr_crapsnh%NOTFOUND THEN
          CLOSE cr_crapsnh;
          CONTINUE;
        ELSE
          CLOSE cr_crapsnh;

          BEGIN
            UPDATE crapmvi 
               SET crapmvi.vlmovted = crapmvi.vlmovted + pr_vllanmto
            WHERE crapmvi.cdcooper = pr_cdcooper
            AND   crapmvi.nrdconta = pr_nrdconta
            AND   crapmvi.idseqttl = rw_crapsnh.idseqttl
            AND   crapmvi.dtmvtolt = pr_dtmvtolt;
            --Nao atualizou nenhum registro
            IF SQL%ROWCOUNT = 0 THEN
              -- Cria o registro do movimento da internet
              BEGIN
                INSERT INTO crapmvi
                       (crapmvi.cdcooper
                       ,crapmvi.cdoperad
                       ,crapmvi.dtmvtolt
                       ,crapmvi.dttransa
                       ,crapmvi.hrtransa
                       ,crapmvi.idseqttl
                       ,crapmvi.nrdconta
                       ,crapmvi.vlmovted)
                VALUES (pr_cdcooper
                       ,pr_cdoperad
                       ,pr_dtmvtolt
                       ,trunc(SYSDATE)
                       ,GENE0002.fn_busca_time
                       ,rw_crapsnh.idseqttl
                       ,pr_nrdconta
                       ,pr_vllanmto);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao inserir movimento na internet. '||sqlerrm;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
              END;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar movimento na internet. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;

        END IF;

      END LOOP;
    END IF;
 
    -- Enviar TED
    pc_enviar_ted (pr_cdcooper => pr_cdcooper --> Cooperativa            
                  ,pr_idorigem => pr_idorigem --> Origem                 
                  ,pr_cdageope => pr_cdagenci --> PAC Operador           
                  ,pr_nrcxaope => pr_nrdcaixa --> Caixa Operador    
                  ,pr_cdoperad => pr_cdoperad --> Operador Autorizacao
                  ,pr_cdopeaut => pr_cdoperad --> Operador Autorizacao
                  ,pr_vldocmto => pr_vllanmto --> Valor TED             
                  ,pr_nrdconta => pr_nrdconta --> Conta Remetente        
                  ,pr_idseqttl => pr_idseqttl --> Titular                
                  ,pr_nmprimtl => vr_nmextttl --> Nome Remetente         
                  ,pr_nrcpfcgc => vr_nrcpfcgc --> CPF/CNPJ Remetente     
                  ,pr_inpessoa => rw_crapass.inpessoa --> Tipo Pessoa Remetente  
                  ,pr_cdbanfav => pr_cddbanco --> Banco Favorecido       
                  ,pr_cdagefav => pr_cdageban --> Agencia Favorecido     
                  ,pr_nrctafav => pr_nrctatrf --> Conta Favorecido       
                  ,pr_nmfavore => pr_nmtitula --> Nome Favorecido        
                  ,pr_nrcpffav => pr_nrcpfcgc --> CPF/CNPJ Favorecido    
                  ,pr_inpesfav => pr_inpessoa --> Tipo Pessoa Favorecido 
                  ,pr_tpctafav => pr_intipcta --> Tipo Conta Favorecido  
                  ,pr_dshistor => pr_dshistor --> Descri�ao do Hist�rico 
                  ,pr_dstransf => pr_dstransf --> Identificacao Transf.
                  ,pr_cdfinali => pr_cdfinali --> Finalidade TED                              
                  ,pr_cdispbif => pr_cdispbif --> ISPB Banco Favorecido
                  ,pr_flmobile => pr_flmobile --> Indicador se origem � do Mobile
                  ,pr_idagenda => pr_idagenda --> Tipo de agendamento                          
                  -- saida
                  ,pr_nrdocmto => vr_nrdocmto --> Documento TED        
                  ,pr_nrrectvl => vr_nrrectvl --> Autenticacao TVL      
                  ,pr_nrreclcm => vr_nrreclcm --> Autenticacao LCM      
                  ,pr_des_erro => vr_des_erro);
                  
    IF vr_des_erro <> 'OK' THEN
      -- buscar erro
      vr_dscritic := NULL;
      OPEN cr_craperr(pr_cdcooper => pr_cdcooper,
                      pr_cdagenci => pr_cdagenci,
                      pr_nrdcaixa => pr_nrdconta||pr_idseqttl);
      FETCH cr_craperr INTO vr_dscritic;
      CLOSE cr_craperr;
      
      -- se nao encontrou a critica ou esta em branco, define mensagem
      vr_dscritic := nvl(vr_dscritic,'TED invalida.');
      RAISE vr_exc_erro;  
    END IF;              
    
    /** PROTOCOLO PARA REGISTRO NA TABELA CRAPTVL **/
             
    -- localizar autentica��o     
    FOR vr_contador IN 1..10 LOOP
      BEGIN
        OPEN cr_crapaut (pr_rowid => vr_nrrectvl);
        FETCH cr_crapaut INTO rw_crapaut;
        -- verificar se encontrou
        IF cr_crapaut%NOTFOUND THEN
          vr_dscritic := 'Registro de autenticacao nao encontrado.';
          CLOSE cr_crapaut;
          RAISE vr_exc_log;  
        END IF;
        
        CLOSE cr_crapaut;
        EXIT; -- sair do loop
      EXCEPTION  
        WHEN OTHERS THEN
          -- se cursor estiver aberto, deve fechar
          IF cr_crapaut%ISOPEN THEN
            CLOSE cr_crapaut;
          END IF;
          -- se for o ultima tentativa, abortar o programa
          IF vr_contador = 10 THEN
            vr_dscritic := 'Registro de autenticacao esta sendo alterado.';
            RAISE vr_exc_log; 
          END IF;
          continue;
      END;
    END LOOP;               
    
    IF pr_cddbanco = 0 THEN
      vr_cddbanco := '   ';
    ELSE
      vr_cddbanco := to_char(pr_cddbanco,'fm000');
    END IF; 
    
    vr_dsinfor1 := 'TED';
    vr_dsinfor2 := vr_nmextttl||'#'||to_char(vr_cddbanco,'fm000');
    
    -- Obtem dados do banco do favorecido para Protocolo
    IF pr_cdispbif = 0 THEN
      OPEN cr_crapban2 (pr_cdbccxlt => pr_cddbanco);
      FETCH cr_crapban2 INTO rw_crapban;
      
      IF cr_crapban2%FOUND THEN
        vr_dsinfor2 := vr_dsinfor2 ||' - '||REPLACE(upper(TRIM(rw_crapban.nmextbcc)),'&','e'); 
      END IF;
      CLOSE cr_crapban2;
    ELSE
      
      OPEN cr_crapban (pr_cdispbif => pr_cdispbif);
      FETCH cr_crapban INTO rw_crapban;
      
      IF cr_crapban%FOUND THEN
        vr_dsinfor2 := vr_dsinfor2 ||' - '||REPLACE(upper(TRIM(rw_crapban.nmextbcc)),'&','e'); 
      END IF;
      CLOSE cr_crapban;
    END IF;
     
    
    vr_dsinfor2 := vr_dsinfor2 ||'#'||to_char(pr_cdageban,'fm0000');
    
    --> Obtem dados da agencia do favorecido para Protocolo
    OPEN cr_crapagb (pr_cddbanco => pr_cddbanco,
                     pr_cdageban => pr_cdageban);
    FETCH cr_crapagb INTO rw_crapagb;
    
    IF cr_crapagb%FOUND THEN
      vr_dsinfor2 := vr_dsinfor2 ||' - '||TRIM(rw_crapagb.nmageban); 
    END IF;
    CLOSE cr_crapagb;
    
    vr_dsinfor2 := vr_dsinfor2 ||'#';
    
    --> Formata dados do favorecido para Protocolo
    vr_dsinfor2 := vr_dsinfor2||
                  TRIM(gene0002.fn_mask(pr_nrctatrf,'zzzzzzzzzzzzzz.9'))||
                  '#'||gene0002.fn_mask(pr_cdispbif,'zzzzzzzzz9');
    vr_dscpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc,pr_inpessoa);
    vr_dsinfor3 := TRIM(pr_nmtitula) ||'#'|| vr_dscpfcgc ||'#';
    
    --> Formata dados da TED para Protocolo
     
    -- Ler tabela generica
    vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => rw_crapcop.cdcooper 
                                              ,pr_nmsistem => 'CRED'           
                                              ,pr_tptabela => 'GENERI'         
                                              ,pr_cdempres => 00               
                                              ,pr_cdacesso => 'FINTRFTEDS'     
                                              ,pr_tpregist => pr_cdfinali   );
    
    vr_dsinfor3 := vr_dsinfor3 || TRIM(upper(vr_dstextab)) ||'#'|| pr_dstransf;
    
    --Gerar protocolo
    GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper             --> C�digo da cooperativa
                              ,pr_dtmvtolt => rw_crapaut.dtmvtolt     --> Data movimento
                              ,pr_hrtransa => rw_crapaut.hrautent     --> Hora da transa��o NOK
                              ,pr_nrdconta => pr_nrdconta             --> N�mero da conta
                              ,pr_nrdocmto => vr_nrdocmto             --> N�mero do documento
                              ,pr_nrseqaut => rw_crapaut.nrsequen     --> N�mero da sequencia
                              ,pr_vllanmto => pr_vllanmto             --> Valor lan�amento
                              ,pr_nrdcaixa => rw_crapaut.nrdcaixa     --> N�mero do caixa NOK
                              ,pr_gravapro => TRUE                    --> Controle de grava��o
                              ,pr_cdtippro => 9                       --> C�digo de opera��o
                              ,pr_dsinfor1 => vr_dsinfor1             --> Descri��o 1
                              ,pr_dsinfor2 => vr_dsinfor2             --> Descri��o 2
                              ,pr_dsinfor3 => vr_dsinfor3             --> Descri��o 3
                              ,pr_dscedent => NULL                    --> Descritivo
                              ,pr_flgagend => FALSE                   --> Controle de agenda
                              ,pr_nrcpfope => pr_nrcpfope             --> N�mero de opera��o
                              ,pr_nrcpfpre => rw_crapsnh.nrcpfcgc     --> N�mero pr� opera��o
                              ,pr_nmprepos => vr_nmprepos             --> Nome
                              ,pr_dsprotoc => pr_dsprotoc             --> Descri��o do protocolo
                              ,pr_dscritic => vr_dscritic             --> Descri��o cr�tica
                              ,pr_des_erro => vr_des_erro);           --> Descri��o dos erros de processo
                                      
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      RAISE vr_exc_log;                           
    ELSE    
    /* Se n�o aconteceu erro o processo gera as informa��es do protocolo */
      -- Buscar dados protocolo
      OPEN cr_crappro (pr_cdcooper => pr_cdcooper,
                       pr_dsprotoc => pr_dsprotoc);
      FETCH cr_crappro INTO rw_crappro;
      IF cr_crappro%FOUND THEN
        CLOSE cr_crappro;  
        
        rw_crapopi := NULL;
        -- Buscar dados operador juridico
        OPEN cr_crapopi (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrcpfope => rw_crappro.nrcpfope);
        FETCH cr_crapopi INTO rw_crapopi;     
        CLOSE cr_crapopi;           
        
        /** Se incluir novo campo para o protocolo, verificar a 
            procedure lista_protocolos da BO bo_algoritmo_seguranca,
            onde ocorre consulta de protocolos para o InternetBank **/                
        vr_idxpro := pr_tab_protocolo_ted.count;
        
        pr_tab_protocolo_ted(vr_idxpro).cdtippro    := rw_crappro.cdtippro;
        pr_tab_protocolo_ted(vr_idxpro).dtmvtolt    := rw_crappro.dtmvtolt;
        pr_tab_protocolo_ted(vr_idxpro).dttransa    := rw_crappro.dttransa;
        pr_tab_protocolo_ted(vr_idxpro).hrautent    := rw_crappro.hrautent;
        pr_tab_protocolo_ted(vr_idxpro).vldocmto    := rw_crappro.vldocmto;
        pr_tab_protocolo_ted(vr_idxpro).nrdocmto    := rw_crappro.nrdocmto;
        pr_tab_protocolo_ted(vr_idxpro).nrseqaut    := rw_crappro.nrseqaut;
        pr_tab_protocolo_ted(vr_idxpro).dsinform##1 := rw_crappro.dsinform##1;
        pr_tab_protocolo_ted(vr_idxpro).dsinform##2 := rw_crappro.dsinform##2;
        pr_tab_protocolo_ted(vr_idxpro).dsinform##3 := rw_crappro.dsinform##3;
        pr_tab_protocolo_ted(vr_idxpro).dsprotoc    := rw_crappro.dsprotoc;
        pr_tab_protocolo_ted(vr_idxpro).nmprepos    := rw_crappro.nmprepos;
        pr_tab_protocolo_ted(vr_idxpro).nrcpfpre    := rw_crappro.nrcpfpre;
        pr_tab_protocolo_ted(vr_idxpro).nmoperad    := rw_crapopi.nmoperad;
        pr_tab_protocolo_ted(vr_idxpro).nrcpfope    := rw_crappro.nrcpfope;
        pr_tab_protocolo_ted(vr_idxpro).cdbcoctl    := rw_crapcop.cdbcoctl;
        pr_tab_protocolo_ted(vr_idxpro).cdagectl    := rw_crapcop.cdagectl;
        
      END IF;
      
      /** Armazena protocolo na autenticacao da craptvl **/
      BEGIN
        UPDATE crapaut 
           SET crapaut.dsprotoc = pr_dsprotoc
         WHERE crapaut.rowid = vr_nrrectvl;  
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 'N�o foi possivel atualizar protocolo na autentica��o: '||SQLERRM;
          RAISE vr_exc_log;
      END;
      
      /** PROTOCOLO PARA REGISTRO NA TABELA CRAPLCM **/
      -- localizar autentica��o     
      FOR vr_contador IN 1..10 LOOP
        BEGIN
          OPEN cr_crapaut (pr_rowid => vr_nrreclcm);
          FETCH cr_crapaut INTO rw_crapaut;
          -- verificar se encontrou
          IF cr_crapaut%NOTFOUND THEN
            vr_dscritic := 'Registro de autenticacao nao encontrado.';
            CLOSE cr_crapaut;
            RAISE vr_exc_log;  
          ELSE
            /** Armazena protocolo na autenticacao da craplcm **/
            BEGIN
              UPDATE crapaut 
                 SET crapaut.dsprotoc = pr_dsprotoc
               WHERE crapaut.rowid = vr_nrreclcm;  
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 'N�o foi possivel atualizar protocolo na autentica��o: '||SQLERRM;
                RAISE vr_exc_log;
            END;  
          END IF;
          
          CLOSE cr_crapaut;
          EXIT; -- sair do loop
        EXCEPTION  
          WHEN OTHERS THEN
            -- se cursor estiver aberto, deve fechar
            IF cr_crapaut%ISOPEN THEN
              CLOSE cr_crapaut;
            END IF;
            -- se for o ultima tentativa, abortar o programa
            IF vr_contador = 10 THEN
              vr_dscritic := 'Registro de autenticacao esta sendo alterado.';
              RAISE vr_exc_log; 
            END IF;
            continue;
        END;
      END LOOP;
    END IF;
    
  EXCEPTION
    --> exception para apenas gerar log e n�o abortar envio de TED, pois 
     -- script j� foi executado 
    WHEN vr_exc_log  THEN
      /* Se aconteceu erro, gera o log e envia o erro por e-mail */
      vr_nmarqlog := 'proc_message.log';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||' - '||
                                                    'b1wgen0015 - executa-envio-ted'               ||
                                                    ' - ERRO GERACAO PROTOCOLO  --> '              ||
                                                    'Cooperativa: '     || to_char(pr_cdcooper, '990')           ||
                                                    ', Conta: '         || gene0002.fn_mask_conta(pr_nrdconta)   ||
                                                    ', Documento: '     || to_char(vr_nrdocmto,'999G999G999G990')||
                                                    ', Valor: '         || to_char(pr_vllanmto,'999G999G999G990D00') ||
                                                    ', Informacao 1: '  || vr_dsinfor1 ||
                                                    ', Informacao 2: '  || vr_dsinfor2 ||
                                                    ', Informacao 3: '  || vr_dsinfor3 || 
                                                    ', CPF Operador: '  || to_char(pr_nrcpfope,'99999999999990')         ||
                                                    ', CPF crapsnh: '   || to_char(rw_crapsnh.nrcpfcgc,'99999999999990') ||
                                                    ', Nome Preposto: ' || vr_nmprepos ||
                                                    '. Data Autenticacao: '     || to_char(rw_crapaut.dtmvtolt, 'DD/MM/RRRR')||
                                                    ', Hora Autenticacao: '     || to_char(to_date(rw_crapaut.hrautent,'SSSSS'),'HH24:MM:SS')||
                                                    ', Sequencia Autenticacao: '|| to_char(rw_crapaut.nrsequen,'99G990')||
                                                    ', Caixa Autenticacao: '    || to_char(rw_crapaut.nrdcaixa,'990')||
                                                    ', Critica: '||vr_dscritic,
                                 pr_nmarqlog     => vr_nmarqlog);

      -- buscar destinatarios do email                           
      vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_ENVIO_TED');
      
      -- Gravar conteudo do email, controle com substr para n�o estourar campo texto
      vr_conteudo := substr('ERRO GERACAO PROTOCOLO - PROCEDURE executa-envio-ted'|| 
                     '<br>Cooperativa: '     || to_char(pr_cdcooper, '990')           ||
                      '<br>Conta: '         || gene0002.fn_mask_conta(pr_nrdconta)   ||
                      '<br>Documento: '     || to_char(vr_nrdocmto,'999G999G999G990')||
                      '<br>Valor: '         || to_char(pr_vllanmto,'999G999G999G990D00') ||
                      '<br>Informacao 1: '  || vr_dsinfor1 ||
                      '<br>Informacao 2: '  || vr_dsinfor2 ||
                      '<br>Informacao 3: '  || vr_dsinfor3 || 
                      '<br>CPF Operador: '  || to_char(pr_nrcpfope,'99999999999990')         ||
                      '<br>CPF crapsnh: '   || to_char(rw_crapsnh.nrcpfcgc,'99999999999990') ||
                      '<br>Nome Preposto: ' || vr_nmprepos ||
                      '<br>Data Autenticacao: '     || to_char(rw_crapaut.dtmvtolt, 'DD/MM/RRRR')||
                      '<br>Hora Autenticacao: '     || to_char(to_date(rw_crapaut.hrautent,'SSSSS'),'HH24:MM:SS')||
                      '<br>Sequencia Autenticacao: '|| to_char(rw_crapaut.nrsequen,'99G990')||
                      '<br>Caixa Autenticacao: '    || to_char(rw_crapaut.nrdcaixa,'990')||
                      '<br>Critica: '               || vr_dscritic,1,4000);
                      
      vr_dscritic := NULL;
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'B1WGEN0015'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'Erro geracao protocolo TED - b1wgen0015'
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser� do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
       
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) = 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := 'N�o foi possivel executar o envio da TED. Tente Novamente.';
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- rollback do ted
      ROLLBACK;
    WHEN OTHERS THEN
      -- rollback do ted
      ROLLBACK;
      pr_dscritic := 'N�o foi possivel executar o envio da TED. Tente Novamente.:'||SQLERRM;
  
  END pc_executa_envio_ted;  
  
  
  /******************************************************************************/
  /**             Procedure para executar o envio da TED                       **/
  /******************************************************************************/
  PROCEDURE pc_executa_envio_ted_prog 
                          (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa    
                          ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Agencia
                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Caixa Operador    
                          ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador Autorizacao
                          ,pr_idorigem IN INTEGER                --> Origem                 
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                          ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta Remetente        
                          ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular                
                          ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --> CPF operador juridico
                          ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Banco destino
                          ,pr_cdageban IN crapcti.cdageban%TYPE  --> Agencia destino
                          ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Conta transferencia
                          ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> nome do titular destino
                          ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> CPF do titular destino
                          ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Tipo de pessoa
                          ,pr_intipcta IN crapcti.intipcta%TYPE  --> Tipo de conta
                          ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lan�amento
                          ,pr_dstransf IN VARCHAR2               --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER                --> Finalidade TED
                          ,pr_dshistor IN VARCHAR2               --> Descri�ao do Hist�rico
                          ,pr_cdispbif IN INTEGER                --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0      --> Indicador se origem � do Mobile
                          ,pr_idagenda IN INTEGER                --> Tipo de agendamento
                          -- saida
                          ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Retorna protocolo    
                          ,pr_tab_protocolo_ted OUT CLOB --> dados do protocolo
                          ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do erro
  BEGIN
    DECLARE
    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    
    vr_tab_protocolo_ted CXON0020.typ_tab_protocolo_ted;
    
    vr_dscritic VARCHAR2(4000);
    BEGIN
      pc_executa_envio_ted(
                pr_cdcooper => pr_cdcooper,
                pr_cdagenci => pr_cdagenci, 
                pr_nrdcaixa => pr_nrdcaixa, 
                pr_cdoperad => pr_cdoperad, 
                pr_idorigem => pr_idorigem, 
                pr_dtmvtolt => pr_dtmvtolt, 
                pr_nrdconta => pr_nrdconta, 
                pr_idseqttl => pr_idseqttl, 
                pr_nrcpfope => pr_nrcpfope, 
                pr_cddbanco => pr_cddbanco, 
                pr_cdageban => pr_cdageban, 
                pr_nrctatrf => pr_nrctatrf, 
                pr_nmtitula => pr_nmtitula, 
                pr_nrcpfcgc => pr_nrcpfcgc, 
                pr_inpessoa => pr_inpessoa, 
                pr_intipcta => pr_intipcta, 
                pr_vllanmto => pr_vllanmto, 
                pr_dstransf => pr_dstransf, 
                pr_cdfinali => pr_cdfinali, 
                pr_dshistor => pr_dshistor, 
                pr_cdispbif => pr_cdispbif, 
                pr_flmobile => pr_flmobile, 
                pr_idagenda => pr_idagenda, 
                pr_dsprotoc => pr_dsprotoc, 
                pr_tab_protocolo_ted => vr_tab_protocolo_ted, 
                pr_cdcritic => pr_cdcritic, 
                pr_dscritic => pr_dscritic);
    -- se possui codigo, por�m n�o possui descri��o                     
    IF nvl(pr_cdcritic,0) > 0 AND 
       TRIM(pr_dscritic) IS NULL THEN
      -- buscar descri��o
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);        
    END IF;   
    
    --> DESCARREGAR TEMPTABLE DE LIMITES PARA O CLOB <---
    -- Criar documento XML
    dbms_lob.createtemporary(pr_tab_protocolo_ted, TRUE); 
    dbms_lob.open(pr_tab_protocolo_ted, dbms_lob.lob_readwrite);       

    -- Insere o cabe�alho do XML 
    gene0002.pc_escreve_xml(pr_xml            => pr_tab_protocolo_ted 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>'); 

    FOR vr_contador IN nvl(vr_tab_protocolo_ted.FIRST,0)..nvl(vr_tab_protocolo_ted.LAST,-1) LOOP
      -- Montar XML com registros de carencia
      gene0002.pc_escreve_xml(pr_xml            => pr_tab_protocolo_ted 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<protocolo>' 
                                                ||   '<cdtippro>'||vr_tab_protocolo_ted(vr_contador).cdtippro    ||'</cdtippro>'
                                                ||   '<dtmvtolt>'||vr_tab_protocolo_ted(vr_contador).dtmvtolt    ||'</dtmvtolt>'
                                                ||   '<dttransa>'||vr_tab_protocolo_ted(vr_contador).dttransa    ||'</dttransa>'
                                                ||   '<hrautent>'||vr_tab_protocolo_ted(vr_contador).hrautent    ||'</hrautent>'
                                                ||   '<vldocmto>'||vr_tab_protocolo_ted(vr_contador).vldocmto    ||'</vldocmto>'
                                                ||   '<nrdocmto>'||vr_tab_protocolo_ted(vr_contador).nrdocmto    ||'</nrdocmto>'
                                                ||   '<nrseqaut>'||vr_tab_protocolo_ted(vr_contador).nrseqaut    ||'</nrseqaut>'
                                                ||   '<dsinform##1>'||vr_tab_protocolo_ted(vr_contador).dsinform##1 ||'</dsinform##1>'
                                                ||   '<dsinform##2>'||vr_tab_protocolo_ted(vr_contador).dsinform##2 ||'</dsinform##2>'
                                                ||   '<dsinform##3>'||vr_tab_protocolo_ted(vr_contador).dsinform##3 ||'</dsinform##3>'
                                                ||   '<dsprotoc>'||vr_tab_protocolo_ted(vr_contador).dsprotoc ||'</dsprotoc>'
                                                ||   '<nmprepos>'||vr_tab_protocolo_ted(vr_contador).nmprepos ||'</nmprepos>'
                                                ||   '<nrcpfpre>'||vr_tab_protocolo_ted(vr_contador).nrcpfpre ||'</nrcpfpre>'
                                                ||   '<nmoperad>'||vr_tab_protocolo_ted(vr_contador).nmoperad ||'</nmoperad>'
                                                ||   '<nrcpfope>'||vr_tab_protocolo_ted(vr_contador).nrcpfope ||'</nrcpfope>'
                                                ||   '<cdbcoctl>'||vr_tab_protocolo_ted(vr_contador).cdbcoctl ||'</cdbcoctl>'
                                                ||   '<cdagectl>'||vr_tab_protocolo_ted(vr_contador).cdagectl ||'</cdagectl>'
                                                || '</protocolo>');
    END LOOP;
       
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => pr_tab_protocolo_ted 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '</raiz>' 
                           ,pr_fecha_xml      => TRUE);

    --> DESCARREGAR TEMPTABLE DE TAB_INTERNET PARA O CLOB <---
    -- Criar documento XML
    dbms_lob.createtemporary(pr_tab_protocolo_ted, TRUE); 
    dbms_lob.open(pr_tab_protocolo_ted, dbms_lob.lob_readwrite);  
    vr_xml_temp := NULL;     

  

    EXCEPTION 
      WHEN OTHERS THEN
        pr_dscritic := 'N�o foi possivel verificar operacao:'|| SQLERRM;
    END;                          
  END pc_executa_envio_ted_prog;
  
  FUNCTION fn_verifica_lote_uso(pr_rowid rowid) RETURN NUMBER IS 
    -- Verificar lote
    CURSOR cr_craplot IS
      SELECT craplot.rowid
        FROM craplot
       WHERE craplot.rowid = pr_rowid
       FOR UPDATE NOWAIT;
    rw_craplot cr_craplot%ROWTYPE;
  BEGIN
    /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */ 
    FOR i IN 1..100 LOOP
      BEGIN
        -- Leitura do lote
        OPEN cr_craplot;
        FETCH cr_craplot INTO rw_craplot;
        CLOSE cr_craplot;
        
        EXIT;
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_craplot%ISOPEN THEN
            CLOSE cr_craplot;
          END IF;

          -- setar critica caso for o ultimo
          IF i = 100 THEN
            RETURN 1; --> em uso
          END IF;
          -- aguardar 0,5 seg. antes de tentar novamente
          sys.dbms_lock.sleep(0.1);
      END;
    END LOOP;
    
    RETURN 0; --> liberado   
  END;
  
END CXON0020;
/
