CREATE OR REPLACE PACKAGE CECRED.sspb0001 AS

/*
    Programa: sspb0001                        Antigo: b1wgen0046.p
    Autor   : David/Fernando/Guilherme
    Data    : Outubro/2009                    Ultima Atualizacao: 28/09/2016

    Dados referentes ao programa:

    Objetivo  : BO ref. a Mensageria do SPB.

    Alteracoes: 26/06/2010 - Alterada BO para tratar conta com digito verificador
                             X - Banco do Brasil (Fernando).

                24/09/2010 - Incluido TAG <CodIdentdTransf> para as mensagens
                             PAG0109, STR0009, PAG0108 e STR0008 (Guilherme)

                02/12/2010 - Incluida procedure proc_opera_str (Diego).

                15/02/2011 - Fazer a leitura da crapban atraves do 'nrispbif'
                             quando processada a STR0019 (Gabriel).

                20/06/2011 - Efetuar leitura pelo campo crapban.cdbccxlt quando
                             for mensagem STR0019 (Diego).

                19/09/2011 - Incluido novo parametro na procedure cria_gnmvspb
                             para alimentar o novo campo da tabela gnmvspb
                             (Henrique).

                02/12/2011 - Substituida critica 15 por "Banco nao operante no
                             SPB"  (Diego).

                27/02/2012 - Tratamento novo catalogo de mensagens V. 3.05,
                             eliminando mensagens STR0009/PAG0109 (Gabriel).

                04/04/2012 - Altera��o do campo cdfinmsg para dsfinmsg
                             (David Kruger).

                11/04/2012 - Chamada da procedure grava-log-ted na procedure
                             gera_xml.
                             Inclusao do parametro par_cdorigem na procedure
                             proc_envia_tec_ted. (Fabricio)

                14/05/2012 - Projeto TED Internet (David).

                20/06/2012 - Alterado procedure proc_opera_str para quando for
                             mensagem STR0019 e j� existir registro na crapban,
                             alterar nome e nome resumido do registro
                             (Guilherme Maba).

                30/07/2012 - Inclus�o de novos parametros na procedure gera_xml
                             campos: cdagenci, nrdcaixa, cdoperad.(Lucas R).

                22/11/2012 - Ajuste para utilizar campo crapdat.dtmvtocd no
                             lugar do crapdat.dtmvtolt. (Jorge)

                19/03/2013 - Projeto VR Boleto (Rafael).

                18/07/2013 - Conversao Progress para Oracle - Alisson (Amcom)

                20/01/2014 - Utilizar valor do pagto do VR Boleto ao gravar
                             registro na tabela gnmvcen. (Tiago Castro RKAM)
                             
                12/08/2015 - Inclusao da procedure pc_trfsal_opcao_x (Jean Michel).             

                28/09/2016 - Removida a validacao de horario cadastrado na TAB085
                             para a geracao de TED dos convenios. SD 519980.
                             (Carlos Rafael Tanholi)
..............................................................................*/

  --cria��o TempTable

  /* Type de registros para armazenar mensagens de log do SPB*/
  TYPE typ_reg_logspb IS
      RECORD (nrseqlog PLS_INTEGER,
              dslinlog VARCHAR2(4000));
   TYPE typ_tab_logspb IS
    TABLE OF typ_reg_logspb
    INDEX BY PLS_INTEGER;

  /* Type de registros para armazenar mensagens de log do SPB*/
  TYPE typ_reg_logspb_detalhe IS
      RECORD (nrseqlog craplmt.nrsequen%type,
              cdbandst craplmt.cdbanctl%type,
              cdagedst craplmt.cdagectl%type,
              nrctadst VARCHAR2(14),
              dsnomdst craplmt.nmcopcta%type,
              dscpfdst craplmt.nrcpfcop%type,
              cdbanrem craplmt.cdbanctl%type,
              cdagerem craplmt.cdagectl%type,
              nrctarem VARCHAR2(14),
              dsnomrem craplmt.nmcopcta%type,
              dscpfrem craplmt.nrcpfcop%type,
              hrtransa Varchar2(10),
              vltransa craplmt.vldocmto%type,
              dsmotivo craplmt.dsmotivo%type,
              dstransa Varchar2(30),
              dsorigem Varchar2(15),
              cdagenci craplmt.cdagenci%type,
              nrdcaixa craplmt.nrdcaixa%type,
              cdoperad craplmt.cdoperad%type,
              nmevento craplmt.nmevento%TYPE,
              nrctrlif craplmt.nrctrlif%TYPE);

  TYPE typ_tab_logspb_detalhe IS
    TABLE OF typ_reg_logspb_detalhe
    INDEX BY varchar2(20); --hrtransa(10)+ nrseqlog(10).

  /* Type de registros para armazenar os totais por situa��o de log do SPB*/
  TYPE typ_reg_logspb_totais IS
      RECORD (qtsitlog NUMBER,
              vlsitlog NUMBER);
  TYPE typ_tab_logspb_totais IS
    TABLE OF typ_reg_logspb_totais
    INDEX BY varchar2(1); --idsitmsg(1)

  -- variavel utilizada para contar registros rejeitados
  vr_qtrejeit INTEGER;

  /** Enviar mensagem STR0026 para a cabine SPB **/
  PROCEDURE pc_proc_envia_vr_boleto (pr_cdcooper IN INTEGER         /* Cooperativa*/
                                    ,pr_cdagenci IN INTEGER         /* Cod. Agencia  */
                                    ,pr_nrdcaixa IN INTEGER         /* Numero  Caixa */
                                    ,pr_cdoperad IN VARCHAR2        /* Operador */
                                    ,pr_cdorigem IN INTEGER         /* Cod. Origem */
                                    ,pr_nrctrlif IN VARCHAR2        /* NumCtrlIF */
                                    ,pr_dscodbar IN VARCHAR2        /* codigo de barras */
                                    ,pr_cdbanced IN INTEGER         /* Banco Cedente */
                                    ,pr_cdageced IN INTEGER         /* Agencia Cedente */
                                    ,pr_tppesced IN VARCHAR2        /* tp pessoa cedente */
                                    ,pr_nrinsced IN NUMBER          /* CPF/CNPJ Ced  */
                                    ,pr_tppessac IN VARCHAR2        /* tp pessoa sacado */
                                    ,pr_nrinssac IN NUMBER          /* CPF/CNPJ Sac  */
                                    ,pr_vldocmto IN NUMBER          /* Vlr. DOCMTO */
                                    ,pr_vldesabt IN NUMBER          /* Vlr Desc. Abat */
                                    ,pr_vlrjuros IN NUMBER          /* Vlr Juros */
                                    ,pr_vlrmulta IN NUMBER          /* Vlr Multa */
                                    ,pr_vlroutro IN NUMBER          /* Vlr Out Acresc */
                                    ,pr_vldpagto IN NUMBER          /* Vlr Pagamento */
                                    ,pr_cdcritic OUT INTEGER  /* Codigo Critica */
                                    ,pr_dscritic OUT VARCHAR2); /* Descricao Critica */

  /** Procedimento para obter log do SPB da Cecred*/
  PROCEDURE pc_obtem_log_cecred ( pr_cdcooper  IN INTEGER   -- Codigo Cooperativa
                                 ,pr_cdagenci  IN INTEGER   -- Cod. Agencia
                                 ,pr_nrdcaixa  IN INTEGER   -- Numero  Caixa
                                 ,pr_cdoperad  IN VARCHAR2  -- Operador
                                 ,pr_nmdatela  IN VARCHAR2  -- Nome da tela
                                 ,pr_cdorigem  IN INTEGER   -- Identificador Origem
                                 ,pr_dtmvtini  IN DATE      -- Data de movimento de log Inicial
                                 ,pr_dtmvtfim  IN DATE      -- Data de movimento de log Final
                                 ,pr_numedlog  IN varchar2  -- Indicador de log a carregar
                                 ,pr_cdsitlog  IN varchar2  -- Codigo de situa��o de log
                                 ,pr_nrdconta  IN VARCHAR2  -- Numero da Conta
                                 ,pr_nrsequen  IN NUMBER    -- Numero sequencial
                                 ,pr_nriniseq  IN INTEGER   -- numero inicial da sequencia
                                 ,pr_nrregist  IN VARCHAR2  -- numero de registros
                                 ,pr_inestcri  IN INTEGER DEFAULT 0 -- Estado Crise
                                 ,pr_cdifconv  IN INTEGER DEFAULT 3 -- IF Da TED
                                 ,pr_vlrdated  IN NUMBER            -- Valor da TED
                                 ,pr_dscritic           OUT varchar2
                                 ,pr_tab_logspb         OUT nocopy SSPB0001.typ_tab_logspb         --> TempTable para armazenar o valor
                                 ,pr_tab_logspb_detalhe OUT nocopy SSPB0001.typ_tab_logspb_detalhe --> TempTable para armazenar o valor
                                 ,pr_tab_logspb_totais  OUT nocopy SSPB0001.typ_tab_logspb_totais  --> Variavel para armazenar os totais por situa��o de log
                                 ,pr_tab_erro           OUT GENE0001.typ_tab_erro                  --> Tabela contendo os erros
                                );

  /** Procedimento para obter log do SPB da Cecred sendo chamada via Progress */
  PROCEDURE pc_obtem_log_cecred_car ( pr_cdcooper  IN INTEGER   -- Codigo Cooperativa
                                     ,pr_cdagenci  IN INTEGER   -- Cod. Agencia
                                     ,pr_nrdcaixa  IN INTEGER   -- Numero  Caixa
                                     ,pr_cdoperad  IN VARCHAR2  -- Operador
                                     ,pr_nmdatela  IN VARCHAR2  -- Nome da tela
                                     ,pr_cdorigem  IN INTEGER   -- Identificador Origem
                                     ,pr_dtmvtini  IN DATE      -- Data de movimento de log Inicial
                                     ,pr_dtmvtfim  IN DATE      -- Data de movimento de log Final
                                     ,pr_numedlog  IN varchar2  -- Indicador de log a carregar
                                     ,pr_cdsitlog  IN varchar2  -- Codigo de situa��o de log
                                     ,pr_nrdconta  IN VARCHAR2  -- Numero da Conta
                                     ,pr_nrsequen  IN NUMBER    -- Numero sequencial
                                     ,pr_nriniseq  IN INTEGER   -- numero inicial da sequencia
                                     ,pr_nrregist  IN VARCHAR2  -- numero de registros
                                     ,pr_inestcri  IN INTEGER DEFAULT 0 -- Estado Crise
                                     ,pr_cdifconv  IN INTEGER DEFAULT 3 -- IF Da TED
                                     ,pr_vlrdated  IN NUMBER            -- Valor da TED
                                     ,pr_clob_logspb         OUT CLOB
                                     ,pr_clob_logspb_detalhe OUT CLOB
                                     ,pr_clob_logspb_totais  OUT CLOB
                                     ,pr_cdcritic            OUT NUMBER
                                     ,pr_dscritic            OUT VARCHAR2
                                    );

  /******************************************************************************/
  /**                       Gera log de envio TED                              **/
  /******************************************************************************/
  PROCEDURE pc_grava_log_ted
                        (pr_cdcooper IN INTEGER  --> Codigo cooperativo
                        ,pr_dttransa IN DATE     --> Data transa��o
                        ,pr_hrtransa IN INTEGER  --> Hora Transa��o
                        ,pr_idorigem IN INTEGER  --> Id de origem
                        ,pr_cdprogra IN VARCHAR2 --> Codigo do programa
                        ,pr_idsitmsg IN INTEGER  --> Situa��o da mensagem.
                        ,pr_nmarqmsg IN VARCHAR2 --> Nome do arquivo da mensagem.
                        ,pr_nmevento IN VARCHAR2 --> Descricao do evento da mensagem.
                        ,pr_nrctrlif IN VARCHAR2 --> Numero de controle da mensagem.
                        ,pr_vldocmto IN NUMBER   --> Valor do documento.
                        ,pr_cdbanctl IN INTEGER  --> Codigo de banco da central.
                        ,pr_cdagectl IN INTEGER  --> Codigo de agencia na central.
                        ,pr_nrdconta IN VARCHAR2 --> Numero da conta cooperado
                        ,pr_nmcopcta IN VARCHAR2 --> Nome do cooperado.
                        ,pr_nrcpfcop IN NUMBER   --> Cpf/cnpj do cooperado.
                        ,pr_cdbandif IN INTEGER  --> Codigo do banco da if.
                        ,pr_cdagedif IN INTEGER  --> Codigo da agencia na if.
                        ,pr_nrctadif IN VARCHAR2 --> Numero da conta na if.
                        ,pr_nmtitdif IN VARCHAR2 --> Nome do titular da conta na if.
                        ,pr_nrcpfdif IN NUMBER   --> Cpf/cnpj do titular da conta na if.
                        ,pr_cdidenti IN VARCHAR2 --> Codigo identificador da transacao.
                        ,pr_dsmotivo IN VARCHAR2 --> Descricao do motivo de erro na mensagem.
                        ,pr_cdagenci IN INTEGER  --> Numero do pa.
                        ,pr_nrdcaixa IN INTEGER  --> Numero do caixa.
                        ,pr_cdoperad IN VARCHAR2 --> Codigo do operador.
                        ,pr_nrispbif IN INTEGER  --> Numero de inscri��o SPB
                        ,pr_inestcri IN INTEGER DEFAULT 0 --> Estado crise
                        ,pr_cdifconv IN INTEGER DEFAULT 0 -->IF convenio 0 - CECRED / 1 - SICREDI
                        
                        --------- SAIDA --------
                        ,pr_cdcritic  OUT INTEGER       --> Codigo do erro
                        ,pr_dscritic  OUT VARCHAR2);    --> Descricao do erro


  /******************************************************************************/
  /**                         Envia TED/TEC  - SPB                             **/
  /******************************************************************************/
  PROCEDURE pc_proc_envia_tec_ted 
                          (pr_cdcooper IN INTEGER   --> Cooperativa
                          ,pr_cdagenci IN INTEGER   --> Cod. Agencia  
                          ,pr_nrdcaixa IN INTEGER   --> Numero  Caixa  
                          ,pr_cdoperad IN VARCHAR2  --> Operador     
                          ,pr_titulari IN BOOLEAN   --> Mesmo Titular.
                          ,pr_vldocmto IN NUMBER    --> Vlr. DOCMTO    
                          ,pr_nrctrlif IN VARCHAR2  --> NumCtrlIF   
                          ,pr_nrdconta IN INTEGER   --> Nro Conta
                          ,pr_cdbccxlt IN INTEGER   --> Codigo Banco 
                          ,pr_cdagenbc IN INTEGER   --> Cod Agencia 
                          ,pr_nrcctrcb IN NUMBER    --> Nr.Ct.destino   
                          ,pr_cdfinrcb IN INTEGER   --> Finalidade     
                          ,pr_tpdctadb IN INTEGER   --> Tp. conta deb 
                          ,pr_tpdctacr IN INTEGER   --> Tp conta cred  
                          ,pr_nmpesemi IN VARCHAR2  --> Nome Do titular 
                          ,pr_nmpesde1 IN VARCHAR2  --> Nome De 2TTT 
                          ,pr_cpfcgemi IN NUMBER    --> CPF/CNPJ Do titular 
                          ,pr_cpfcgdel IN NUMBER    --> CPF sec TTL
                          ,pr_nmpesrcb IN VARCHAR2  --> Nome Para 
                          ,pr_nmstlrcb IN VARCHAR2  --> Nome Para 2TTL
                          ,pr_cpfcgrcb IN NUMBER    --> CPF/CNPJ Para
                          ,pr_cpstlrcb IN NUMBER    --> CPF Para 2TTL
                          ,pr_tppesemi IN INTEGER   --> Tp. pessoa De  
                          ,pr_tppesrec IN INTEGER   --> Tp. pessoa Para 
                          ,pr_flgctsal IN BOOLEAN   --> CC Sal
                          ,pr_cdidtran IN VARCHAR2  --> tipo de transferencia
                          ,pr_cdorigem IN INTEGER   --> Cod. Origem    
                          ,pr_dtagendt IN DATE      --> data egendamento
                          ,pr_nrseqarq IN INTEGER   --> nr. seq arq.
                          ,pr_cdconven IN INTEGER   --> Cod. Convenio
                          ,pr_dshistor IN VARCHAR2  --> Dsc do Hist.  
                          ,pr_hrtransa IN INTEGER   --> Hora transacao 
                          ,pr_cdispbif IN INTEGER   --> ISPB Banco
                          --------- SAIDA --------
                          ,pr_cdcritic OUT INTEGER   --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2);--> Descricao do erro 

PROCEDURE pc_trfsal_opcao_b(pr_cdcooper IN INTEGER    --> Cooperativa
                            ,pr_cdagenci IN INTEGER   --> Cod. Agencia  
                            ,pr_nrdcaixa IN INTEGER   --> Numero  Caixa  
                            ,pr_cdoperad IN VARCHAR2  --> Codigo Operador
                            ,pr_cdempres craplfp.cdempres%TYPE
                             --------- SAIDA --------
                            ,pr_cdcritic OUT INTEGER    --> Codigo do erro
                            ,pr_dscritic OUT VARCHAR2); --> Descricao do erro                             

PROCEDURE pc_trfsal_opcao_x(pr_cdcooper IN INTEGER    --> Cooperativa
                           ,pr_cdagenci IN INTEGER   --> Cod. Agencia  
                           ,pr_nrdcaixa IN INTEGER   --> Numero  Caixa  
                           ,pr_cdoperad IN VARCHAR2  --> Codigo Operador
                           ,pr_cdempres craplfp.cdempres%TYPE
                           --------- SAIDA --------
                           ,pr_cdcritic OUT INTEGER    --> Codigo do erro
                           ,pr_dscritic OUT VARCHAR2); --> Descricao do erro                             

PROCEDURE pc_estado_crise (pr_flproces  IN VARCHAR2 DEFAULT 'N' -- Indica para verificar o processo
                          ,pr_inestcri OUT INTEGER -- 0-Sem crise / 1-Com Crise
                          ,pr_clobxmlc OUT CLOB); -- XML com informa��es de LOG

END sspb0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.sspb0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : sspb0001
  --  Sistema  : Procedimentos e funcoes da BO b1wgen0046.p
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 22/09/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funcoes da BO b1wgen0046.p
  --
  -- Alteracoes: 12/08/2015 - Inclusao da procedure pc_trfsal_opcao_x (Jean Michel).
  --
  --             09/11/2015 - Ajustar a atualiza��o do lote para gravar vr_qtinfoln
  --                          na qtinfoln nas procedures pc_trfsal_opcao_b e 
  --                          pc_trfsal_opcao_x (Douglas - Chamado 356338)
  --
  --             22/09/2016 - Arrumar validacao para horario limite de envio de ted na 
  --                          procedure pc_trfsal_opcao_b (Lucas Ranghetti #500917)
  ---------------------------------------------------------------------------------------------------------------

  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
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
          ,crapcop.cdagebcb
          ,crapcop.dssigaut
          ,crapcop.cdagesic
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Busca dos dados do associado */
  CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.inpessoa
          ,crapass.cdagenci
          ,crapass.vllimcre
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
     AND   crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  --Selecionar informacoes dos bancos
  CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%TYPE
                    ,pr_flgdispb IN crapban.flgdispb%TYPE) IS
    SELECT crapban.nmresbcc
          ,crapban.nmextbcc
          ,crapban.cdbccxlt
          ,crapban.nrispbif
    FROM crapban
    WHERE crapban.cdbccxlt = pr_cdbccxlt
    AND  (pr_flgdispb = 9 OR crapban.flgdispb = pr_flgdispb);
  rw_crapban cr_crapban%ROWTYPE;

  /* Procedure para gravar log da TED */
  PROCEDURE pc_grava_log_ted (pr_cdcooper IN INTEGER  --Codigo cooperativa
                             ,pr_dttransa IN DATE     --Data transacao
                             ,pr_hrtransa IN INTEGER  --Hora transacao
                             ,pr_idorigem IN INTEGER  --Identificador origem
                             ,pr_cdprogra IN VARCHAR2 --Nome programa
                             ,pr_idsitmsg IN INTEGER  --Situacao mensagem
                             ,pr_nmarqmsg IN VARCHAR2 --Nome arquivo mensagem
                             ,pr_nmevento IN VARCHAR2 --Nome evento
                             ,pr_nrctrlif IN VARCHAR2 --Numero Contrato
                             ,pr_vldocmto IN NUMBER   --Valor Documento
                             ,pr_cdbanctl IN INTEGER  --Codigo banco centralizador
                             ,pr_cdagectl IN INTEGER  --Codigo Agencia Centralizadora
                             ,pr_nrdconta IN VARCHAR2 --Numero da Conta
                             ,pr_nmcopcta IN VARCHAR2 --Nome Cooperativa Conta
                             ,pr_nrcpfcop IN NUMBER   --Numero CPF Cooperativa
                             ,pr_cdbandif IN INTEGER  --Banco IF
                             ,pr_cdagedif IN INTEGER  --Agencia IF
                             ,pr_nrctadif IN VARCHAR2 --Numero Conta IF
                             ,pr_nmtitdif IN VARCHAR2 --Nome titular IF
                             ,pr_nrcpfdif IN NUMBER   --Numero CPF IF
                             ,pr_cdidenti IN VARCHAR2 --Codigo Identificador
                             ,pr_dsmotivo IN VARCHAR2 --Descricao Motivo
                             ,pr_cdagenci IN INTEGER  --Codigo Agencia
                             ,pr_nrdcaixa IN INTEGER  --Numero do Caixa
                             ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                             ,pr_cdcritic OUT INTEGER --Codigo erro
                             ,pr_dscritic OUT VARCHAR2) IS --Descricao erro
    -- .........................................................................
    --
    --  Programa : pc_grava_log_ted           Antigo: b1wgen0050.p/grava-log-ted
    --  Sistema  : Cred
    --  Sigla    : SSPB0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para gravar log da TED
  BEGIN
    DECLARE
      --Variaveis de erro
      vr_des_erro     VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Tabela de memoria de erros
      vr_tab_erro GENE0001.typ_tab_erro;
      --Registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      NULL;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina SSPB0001.pc_grava_log_ted. '||sqlerrm;
    END;
  END pc_grava_log_ted;


  /* Procedure para gerar xml boleto */
  PROCEDURE pc_gera_xml_vr_boleto (pr_cdcooper   IN INTEGER   --Codigo Cooperativa
                                  ,pr_cdorigem   IN INTEGER   --Identificador Origem
                                  ,pr_cdagenci   IN INTEGER   --Cod. Agencia
                                  ,pr_nrdcaixa   IN INTEGER   --Numero  Caixa
                                  ,pr_cdoperad   IN VARCHAR2  --Operador
                                  ,pr_nmmsgenv   IN VARCHAR2  --Mensagem envio
                                  ,pr_cdlegado   IN VARCHAR2  --Codigo Legado
                                  ,pr_tpmanut    IN VARCHAR2  --Tipo Manutencao
                                  ,pr_cdstatus   IN VARCHAR2  --Status Operacao
                                  ,pr_nroperacao IN VARCHAR2  --Numero Operacao
                                  ,pr_fldebcred  IN VARCHAR2  --Debito ou Credito
                                  ,pr_nrctrlif   IN VARCHAR2  --Numero Contrato
                                  ,pr_ispbdebt   IN VARCHAR2  --ISPB Debito
                                  ,pr_cdagectl   IN VARCHAR2  --Agencia centralizadora
                                  ,pr_cdbanced   IN INTEGER   --Banco cedente
                                  ,pr_cdageced   IN VARCHAR2  --Agencia cedente
                                  ,pr_vldpagto   IN VARCHAR2  --Valor Pagamento
                                  ,pr_dspessac   IN VARCHAR2  --Descricao Pessoa sacado
                                  ,pr_nrinssac   IN VARCHAR2  --Numero Inscricao sacado
                                  ,pr_dspesced   IN VARCHAR2  --Descricao pessoa cedente
                                  ,pr_nrinsced   IN VARCHAR2  --Numero inscricao cedente
                                  ,pr_dscodbar   IN VARCHAR2  --Codigo Barras
                                  ,pr_vldocmto   IN VARCHAR2  --Valor do Documento
                                  ,pr_vldesabt   IN VARCHAR2  --Valor Abatimento
                                  ,pr_vlrjuros   IN VARCHAR2  --Valor juros
                                  ,pr_vlrmulta   IN VARCHAR2  --Valor Multa
                                  ,pr_vlroutro   IN VARCHAR2  --Valor Outros
                                  ,pr_dtmvtolt   IN VARCHAR2  --Data Movimento
                                  ,pr_cdcritic   OUT INTEGER --Codigo erro
                                  ,pr_dscritic   OUT VARCHAR2) IS --Descricao erro
    -- .........................................................................
    --
    --  Programa : pc_gera_xml_vr_boleto           Antigo: b1wgen0046.p/gera_xml_vr_boleto
    --  Sistema  : Cred
    --  Sigla    : SSPB0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 17/11/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para gerar xml boleto
    --
    --   13/11/2014 - Realizado ajustes na chamado do script mqcecred_envia conforme
    --                solicitado pelo Tiago Wagner/Infra TI. (Rafael)
    --
    --   17/11/2014 - Ajustado tag XML <CanPagto> igual a vers�o Progress. (Rafael)
    --
  BEGIN
    DECLARE
      --Variaveis para o arquivo XML
      vr_XMLType     XMLType;
      vr_des_xml     CLOB;

      --Variaveis Locais
      vr_contador  INTEGER;
      vr_contctnr  INTEGER;
      vr_textoxml  VARCHAR2(100);
      vr_nmtagbod  VARCHAR2(100);
      vr_nmarquiv  VARCHAR2(100);
      vr_nmarqlog  VARCHAR2(100);
      vr_nmarqxml  VARCHAR2(100);
      vr_nmarqenv  VARCHAR2(100);
      vr_dsarqenv  VARCHAR2(100);
      vr_ispbcred  VARCHAR2(100);
      vr_comando   VARCHAR2(4000);
      vr_dsparam   VARCHAR2(1000);
      vr_typ_saida VARCHAR2(3);
      vr_canpgto   INTEGER;
      --Variaveis dos diretorios
      vr_nom_direto VARCHAR2(100);
      vr_nom_direto_log VARCHAR2(100);
      --Variaveis de erro
      vr_des_erro     VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Tabela de memoria de erros
      vr_tab_erro GENE0001.typ_tab_erro;
      --Registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      vr_xml_str VARCHAR2(4000);

      --Escrever no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo XML
        vr_xml_str := vr_xml_str || pr_des_dados;
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

    BEGIN
      --Inicializar parametros erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;

      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := NULL;
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      --Buscar diretorio destino arquivo
      vr_nom_direto:= gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nmsubdir => '/salvar'); --> Utilizaremos o salvar

      /* Arquivo gerado para o envio */
      vr_nmarqxml:= 'msgenv_cecred_' ||To_Char(SYSTIMESTAMP,'YYYYMMDDMISSFF')||'.xml';
      /* Arquivo de log - tela LOGSPB*/
      vr_nom_direto_log:= gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/log'); --> Utilizaremos o log
      --Nome arquivo log
      vr_nmarqlog:= 'mqcecred_envio_vrboleto'||To_Char(rw_crapdat.dtmvtocd,'DDMMYY')||'.log';
      --Nome arquivo
      vr_nmarquiv:= vr_nmarqxml;
      --Selecionar Banco
      OPEN cr_crapban (pr_cdbccxlt => pr_cdbanced
                      ,pr_flgdispb => 1);
      --Posicionar no proximo registro
      FETCH cr_crapban INTO rw_crapban;
      --Se nao encontrar
      IF cr_crapban%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapban;
        --Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Banco nao operante no SPB.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapban;
      --ISPB Credito
      vr_ispbcred:= TO_CHAR(rw_crapban.nrispbif,'fm00000000');

      IF pr_cdorigem = 2 THEN
         vr_canpgto := 1 ;
      ELSE
         vr_canpgto := 3;
      END IF;

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informa��es do XML
--      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>');
      pc_escreve_xml('<SISMSG>');
      pc_escreve_xml('<SEGCAB>');
      pc_escreve_xml('<CD_LEGADO>'||pr_cdlegado||'</CD_LEGADO>');
      pc_escreve_xml('<TP_MANUT>'|| pr_tpmanut ||'</TP_MANUT>');
      pc_escreve_xml('<CD_STATUS>'|| pr_cdstatus || '</CD_STATUS>');
      pc_escreve_xml('<NR_OPERACAO>' || pr_nroperacao || '</NR_OPERACAO>');
      pc_escreve_xml('<FL_DEB_CRED>'|| pr_fldebcred ||'</FL_DEB_CRED>');
      pc_escreve_xml('</SEGCAB>');

      /* BODY  - mensagem STR STR0026 Descri��o: destinado ao pagamento de VR Boletos */
      pc_escreve_xml('<'|| pr_nmmsgenv || '>');
      pc_escreve_xml('<CodMsg>'|| pr_nmmsgenv || '</CodMsg>');
      pc_escreve_xml('<NumCtrlIF>' || pr_nrctrlif || '</NumCtrlIF>');
      pc_escreve_xml('<ISPBIFDebtd>'|| pr_ispbdebt ||'</ISPBIFDebtd>');
      pc_escreve_xml('<AgDebtd>'|| pr_cdagectl||'</AgDebtd>');
      pc_escreve_xml('<ISPBIFCredtd>'|| vr_ispbcred||'</ISPBIFCredtd>');
      pc_escreve_xml('<AgCredtd>'|| pr_cdageced ||'</AgCredtd>');
      pc_escreve_xml('<VlrLanc>'|| pr_vldpagto||'</VlrLanc>');
      pc_escreve_xml('<TpPessoaSacd>'|| pr_dspessac||'</TpPessoaSacd>');
      pc_escreve_xml('<CNPJ_CPFSacd>'|| pr_nrinssac||'</CNPJ_CPFSacd>');
      pc_escreve_xml('<TpPessoaCed>'|| pr_dspesced ||'</TpPessoaCed>');
      pc_escreve_xml('<CNPJ_CPFCed>'|| pr_nrinsced||'</CNPJ_CPFCed>');
      pc_escreve_xml('<TpDocBarras>1</TpDocBarras>');
      pc_escreve_xml('<NumCodBarras>'|| pr_dscodbar||'</NumCodBarras>');
      pc_escreve_xml('<CanPgto>' || to_char(vr_canpgto) || '</CanPgto>');
      pc_escreve_xml('<VlrDoc>'|| pr_vldocmto||'</VlrDoc>');
      pc_escreve_xml('<VlrDesct_Abatt>'|| pr_vldesabt||'</VlrDesct_Abatt>');
      pc_escreve_xml('<VlrJuros>'|| pr_vlrjuros ||'</VlrJuros>');
      pc_escreve_xml('<VlrMulta>'|| pr_vlrmulta ||'</VlrMulta>');
      pc_escreve_xml('<VlrOtrAcresc>'|| pr_vlroutro||'</VlrOtrAcresc>');
      pc_escreve_xml('<DtMovto>'|| pr_dtmvtolt||'</DtMovto>');
      pc_escreve_xml('</'|| pr_nmmsgenv || '>');
      pc_escreve_xml('</SISMSG>');

      --Gera arquivo XML no diretorio salvar
      DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml,vr_nom_direto,vr_nmarqxml, 0);

      /* Com o comando SUDO pois para conecta no MQ atrav�s do script o usu�rio precisa ser ROOT
      '/usr/bin/sudo /usr/local/cecred/bin/mqcecred_envia.pl' */

      vr_dsparam:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'MQ_SUDO_ENVIA');
      --Se nao encontrou sai com erro
      IF vr_dsparam IS NULL THEN
        --Montar mensagem de erro
        vr_des_erro:= 'N�o foi encontrado diret�rio para execu��o MQ.';
        --Levantar Exce��o
        RAISE vr_exc_erro;
      END IF;

      --Montar comando
      -- /usr/local/bin/exec_comando_oracle.sh mqcecred_envia (conforme solicitacao Tiago Wagner)
      vr_comando:= '/usr/local/bin/exec_comando_oracle.sh mqcecred_envia ' || Chr(39) || vr_xml_str || Chr(39) || ' '
                                                                           || Chr(39) || to_char(pr_cdcooper) || Chr(39) || ' '
                                                                           || Chr(39) || vr_nmarqxml || Chr(39);

      --Executar Comando Unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel executar comando unix. Erro '|| vr_dscritic||': '||vr_comando;--odirlei
        RAISE vr_exc_erro;
      END IF;

      -- Liberando a mem�ria alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      /* Cria registro de Debito */
      BEGIN
        INSERT INTO gnmvcen
          (gnmvcen.cdagectl
          ,gnmvcen.dtmvtolt
          ,gnmvcen.dsmensag
          ,gnmvcen.dsdebcre
          ,gnmvcen.vllanmto)
        VALUES
          (nvl(rw_crapcop.cdagectl,0)
          ,rw_crapdat.dtmvtocd
          ,nvl(pr_nmmsgenv,'STR0026')
          ,'D' /*Debito em Conta*/
          ,TO_NUMBER(nvl(replace(trim(pr_vldpagto),'.',','),0)));
      EXCEPTION

        WHEN Others THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao inserir na tabela gnmvcen. '||SQLERRM;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
      /* Logar envio
      *****************************************************************
      * Cuidar ao alterar o log pois os espacamentos e formats estao  *
      * ajustados para que a tela LogSPB pegue os dados com SUBSTRING *
      *****************************************************************/
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      pc_escreve_xml(
       Chr(34) || To_Char(SYSDATE,'DD/MM/YYYY')|| ' - '||
       to_char(SYSDATE,'HH24:MI:SS')|| ' - '|| 'b1wgen0046'||
       ' - ENVIADA OK         --> '||
       'Arquivo '|| SUBSTR(vr_nmarquiv,1,40)||
       '. Evento: '|| SUBSTR(pr_nmmsgenv,1,9)||
       ', Numero Controle: '|| SUBSTR(pr_nrctrlif,1,20)||
       ', Hora: '|| TO_CHAR(SYSDATE,'HH24:MI:SS')||
       ', Valor: '|| To_Char(TO_NUMBER(REPLACE(pr_vldpagto,'.',',')),'fm999g999g990d00')||
       ', Banco Sacado.: '|| TO_CHAR(rw_crapcop.cdbcoctl,'fm990')||
       ', Agencia Sacado: '|| TO_CHAR(pr_cdagectl,'fm9990')||
       ', CPF/CNPJ Sacado: '|| pr_nrinssac||
       ', Banco Cedente.: '|| TO_CHAR(pr_cdbanced,'fm990')||
       ', Agencia Cedente: '|| TO_CHAR(pr_cdageced,'fm9990')||
       ', Cod.Barras.: '|| pr_dscodbar);

      --Gera arquivo XML no diretorio salvar
      DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml,vr_nom_direto_log,vr_nmarqlog, 0);

      -- Liberando a mem�ria alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina SSPB0001.pc_gera_xml_vr_boleto. '||sqlerrm;
    END;
  END pc_gera_xml_vr_boleto;


  /** Enviar mensagem STR0026 para a cabine SPB **/
  PROCEDURE pc_proc_envia_vr_boleto (pr_cdcooper IN INTEGER         /* Cooperativa*/
                                    ,pr_cdagenci IN INTEGER         /* Cod. Agencia  */
                                    ,pr_nrdcaixa IN INTEGER         /* Numero  Caixa */
                                    ,pr_cdoperad IN VARCHAR2        /* Operador */
                                    ,pr_cdorigem IN INTEGER         /* Cod. Origem */
                                    ,pr_nrctrlif IN VARCHAR2        /* NumCtrlIF */
                                    ,pr_dscodbar IN VARCHAR2        /* codigo de barras */
                                    ,pr_cdbanced IN INTEGER         /* Banco Cedente */
                                    ,pr_cdageced IN INTEGER         /* Agencia Cedente */
                                    ,pr_tppesced IN VARCHAR2        /* tp pessoa cedente */
                                    ,pr_nrinsced IN NUMBER          /* CPF/CNPJ Ced  */
                                    ,pr_tppessac IN VARCHAR2        /* tp pessoa sacado */
                                    ,pr_nrinssac IN NUMBER          /* CPF/CNPJ Sac  */
                                    ,pr_vldocmto IN NUMBER          /* Vlr. DOCMTO */
                                    ,pr_vldesabt IN NUMBER          /* Vlr Desc. Abat */
                                    ,pr_vlrjuros IN NUMBER          /* Vlr Juros */
                                    ,pr_vlrmulta IN NUMBER          /* Vlr Multa */
                                    ,pr_vlroutro IN NUMBER          /* Vlr Out Acresc */
                                    ,pr_vldpagto IN NUMBER          /* Vlr Pagamento */
                                    ,pr_cdcritic OUT INTEGER  /* Codigo Critica */
                                    ,pr_dscritic OUT VARCHAR2) IS /* Descricao Critica */
    -- .........................................................................
    --
    --  Programa : pc_proc_envia_vr_boleto           Antigo: b1wgen0046.p/proc_envia_vr_boleto
    --  Sistema  : Cred
    --  Sigla    : SSPB0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 19/09/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar mensagem STR0026 para a cabine SPB
    --
    --   Alteracoes: 	19/09/2016 - Removida a validacao de horario cadastrado na TAB085
		--					                   para a geracao de TED dos convenios. SD 519980.
		--					                   (Carlos Rafael Tanholi)
    --
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_flgutstr BOOLEAN;
      vr_nmmsgenv VARCHAR2(1000);
      --Variaveis para geracao XML
      vr_cdlegado   VARCHAR2(1000);
      vr_tpmanut    VARCHAR2(1000);
      vr_cdstatus   VARCHAR2(1000);
      vr_nroperacao VARCHAR2(1000);
      vr_fldebcred  VARCHAR2(1000);
      vr_dspesced   VARCHAR2(1000);
      vr_dspessac   VARCHAR2(1000);
      vr_dtmvtolt   VARCHAR2(1000);
      vr_vldocmto   VARCHAR2(1000);
      vr_vldesabt   VARCHAR2(1000);
      vr_vlrjuros   VARCHAR2(1000);
      vr_vlrmulta   VARCHAR2(1000);
      vr_vlroutro   VARCHAR2(1000);
      vr_vldpagto   VARCHAR2(1000);
      vr_ispbdebt   NUMBER;
      vr_nrinsced   VARCHAR2(1000);
      vr_nrinssac   VARCHAR2(1000);
      vr_dstextab   craptab.dstextab%TYPE;
      --Variaveis de erro
      vr_des_erro     VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Tabela de memoria de erros
      vr_tab_erro GENE0001.typ_tab_erro;
      --Registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar parametros erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Controle envio TEDs
      vr_flgutstr:= FALSE;
      /* Busca dados da cooperativa */
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= 'Tipo de categoria nao cadastrada!';
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;
      /* Busca data do sistema */
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := NULL;
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      /* ISPB Debt. eh os 8 primeiros digitos do CNPJ da Coop */
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 0
                                              ,pr_cdacesso => 'CNPJCENTRL'
                                              ,pr_tpregist => 0);
      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
        -- Montar mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= 'CNPJ da Central nao encontrado.';
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Cnpj da central
        vr_ispbdebt:= TO_NUMBER(vr_dstextab);
      END IF;
      /* ISPB Credt eh os 8 primeiros digitos do CNPJ do Banco de Destino */
      OPEN cr_crapban (pr_cdbccxlt => pr_cdbanced
                      ,pr_flgdispb => 1);
      --Posicionar no proximo registro
      FETCH cr_crapban INTO rw_crapban;
      --Se nao encontrar
      IF cr_crapban%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapban;
        --Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Banco nao operante no SPB.';
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapban;
      
      /*-- Operando com mensagens STR --*/
      /*IF rw_crapcop.flgopstr = 1 THEN
        --Verificar horario inicio e fim operacao
        IF rw_crapcop.iniopstr <= GENE0002.fn_busca_time AND
           rw_crapcop.fimopstr >= GENE0002.fn_busca_time THEN
          --Horario ted ultrapassado
          vr_flgutstr:= TRUE;
        END IF;
      END IF;
      IF vr_flgutstr = FALSE THEN
        --Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Hor�rio de envio dos TEDs encerrado.';
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;*/
      
      /* Alimenta variaveis default */

      --Se for pessoa fisica
      IF pr_tppesced = 'F' THEN
        --Numero Inscricao Cedente
        vr_nrinsced:= TO_CHAR(pr_nrinsced,'fm00000000000');
        --Numero Inscricao Sacado
        vr_nrinssac:= TO_CHAR(pr_nrinssac,'fm00000000000');
      ELSE
        --Numero Inscricao Cedente
        vr_nrinsced:= TO_CHAR(pr_nrinsced,'fm00000000000000');
        --Numero Inscricao Sacado
        vr_nrinssac:= TO_CHAR(pr_nrinssac,'fm00000000000000');
      END IF;
       /* Format da data deve ser AAAA-MM-DD */
      vr_dtmvtolt:= To_Char(SYSDATE,'YYYY-MM-DD');
      /* Separador decimal de centavos deve ser "." */
      vr_vldocmto:= REPLACE(pr_vldocmto,',','.');
      vr_vldesabt:= REPLACE(pr_vldesabt,',','.');
      vr_vlrjuros:= REPLACE(pr_vlrjuros,',','.');
      vr_vlrmulta:= REPLACE(pr_vlrmulta,',','.');
      vr_vlroutro:= REPLACE(pr_vlroutro,',','.');
      vr_vldpagto:= REPLACE(pr_vldpagto,',','.');
      /* Alimenta as variaveis do HEADER */
      vr_cdlegado:= rw_crapcop.cdagectl;
      vr_tpmanut:= 'I'; /* Inclusao */
      vr_cdstatus:= 'D'; /* Mensagem do tipo definitiva - real */
      vr_fldebcred:= 'D'; /* Debito */
      /*    crapcop.dssigaut   */
      vr_nroperacao:= pr_nrctrlif;
      /*-- Monta o BODY --*/
      SSPB0001.pc_gera_xml_vr_boleto (pr_cdcooper   => pr_cdcooper  --Codigo Cooperativa
                                     ,pr_cdorigem   => pr_cdorigem  --Identificador Origem
                                     ,pr_cdagenci   => pr_cdagenci  --Cod. Agencia
                                     ,pr_nrdcaixa   => pr_nrdcaixa  --Numero  Caixa
                                     ,pr_cdoperad   => pr_cdoperad  --Operador
                                     ,pr_nmmsgenv   => 'STR0026'    --Mensagem envio
                                     ,pr_cdlegado   => vr_cdlegado  --Codigo Legado
                                     ,pr_tpmanut    => vr_tpmanut   --Tipo Manutencao
                                     ,pr_cdstatus   => vr_cdstatus  --Status Operacao
                                     ,pr_nroperacao => vr_nroperacao --Numero Operacao
                                     ,pr_fldebcred  => vr_fldebcred  --Debito ou Credito
                                     ,pr_nrctrlif   => pr_nrctrlif   --Numero Contrato
                                     ,pr_ispbdebt   => SUBSTR(TO_CHAR(vr_ispbdebt,'FM00000000000000'),1,8) --ISPB Debito
                                     ,pr_cdagectl   => rw_crapcop.cdagectl --Agencia centralizadora
                                     ,pr_cdbanced   => pr_cdbanced   --Banco cedente
                                     ,pr_cdageced   => pr_cdageced   --Agencia cedente
                                     ,pr_vldpagto   => vr_vldpagto   --Valor Pagamento
                                     ,pr_dspessac   => pr_tppessac   --Descricao Pessoa sacado
                                     ,pr_nrinssac   => vr_nrinssac   --Numero Inscricao sacado
                                     ,pr_dspesced   => pr_tppesced   --Descricao pessoa cedente
                                     ,pr_nrinsced   => vr_nrinsced   --Numero inscricao cedente
                                     ,pr_dscodbar   => pr_dscodbar   --Codigo Barras
                                     ,pr_vldocmto   => vr_vldocmto   --Valor do Documento
                                     ,pr_vldesabt   => vr_vldesabt   --Valor Abatimento
                                     ,pr_vlrjuros   => vr_vlrjuros   --Valor juros
                                     ,pr_vlrmulta   => vr_vlrmulta   --Valor Multa
                                     ,pr_vlroutro   => vr_vlroutro   --Valor Outros
                                     ,pr_dtmvtolt   => vr_dtmvtolt   --Data Movimento
                                     ,pr_cdcritic   => vr_cdcritic   --Codigo erro
                                     ,pr_dscritic   => vr_dscritic); --Descricao erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina SSPB0001.pc_proc_envia_vr_boleto. '||sqlerrm;
    END;
  END pc_proc_envia_vr_boleto;

  /** Procedimento para gravar a mensagem de log SPB na TempTbale **/
  PROCEDURE pc_grava_msg_log (pr_tab_logspb IN OUT nocopy SSPB0001.typ_tab_logspb, --> TempTable para armazenar o valor
                              pr_dslinlog   IN VARCHAR2,                            --> Mensagem a ser armazenada
                              pr_tab_logspb_totais  IN OUT nocopy SSPB0001.typ_tab_logspb_totais  --> Variavel para armazenar os totais por situa��o de log
                              ) IS
    /*.........................................................................
    --
    --  Programa : pc_grava_msg_log           Antigo: b1wgen0050.p/grava-msg-log
    --  Sistema  : Cred
    --  Sigla    : SSPB0001
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : novembro/2013.                   Ultima atualizacao: 27/09/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Grava a mensagem de log SPB na TempTbale
    --
    --   Alteracoes 
    --               27/09/2016 - M211 - Ajustes em problemas encontrados na homologa��o (JOnata-RKAM)
      ..............................................................................*/

    vr_nrseqlog PLS_INTEGER;

  BEGIN

    -- Contar os registros rejeitados
    IF NOT pr_tab_logspb_totais.exists('R') THEN
      pr_tab_logspb_totais('R').qtsitlog := 0;
    END IF;
    
    pr_tab_logspb_totais('R').qtsitlog := NVL(pr_tab_logspb_totais('R').qtsitlog,0) + 1;

    vr_nrseqlog := nvl(pr_tab_logspb.last,0) + 1;

    --Gravar mensagem de log rejeitada
    pr_tab_logspb(vr_nrseqlog).nrseqlog := vr_nrseqlog;
    pr_tab_logspb(vr_nrseqlog).dslinlog := pr_dslinlog;

  END pc_grava_msg_log;

  /** Procedimento para ler mensagem de log SPB e gerar TempTable **/
  PROCEDURE pc_busca_log_SPB (pr_cdcooper  IN INTEGER  -- Codigo cooperativa
                             ,pr_nrdconta  IN VARCHAR2 -- Numero da Conta
                             ,pr_nrsequen  IN NUMBER   -- Numero da sequencia
                             ,pr_cdorigem  IN INTEGER  -- Codigo de origem
                             ,pr_dtmvtini  IN DATE     -- Data de movimento do log inicial
                             ,pr_dtmvtfim  IN DATE     -- Data de movimento do log final
                             ,pr_nriniseq  IN INTEGER  -- numero inicial da sequencia
                             ,pr_nrregist  IN INTEGER  -- Numero de registros
                             ,pr_idsitmsg  IN INTEGER  -- Indicador de tipo de mensagem (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                             ,pr_inestcri  IN INTEGER DEFAULT 0 -- Estado Crise
                             ,pr_cdifconv  IN INTEGER DEFAULT 3 -- IF da TED
                             ,pr_vlrdated  IN NUMBER            -- Valor da TED
                             ,pr_dscritic OUT VARCHAR2 -- Descricao do erro
                             ,pr_tab_logspb_detalhe IN OUT nocopy SSPB0001.typ_tab_logspb_detalhe --> TempTable para armazenar o valor
                             ,pr_tab_logspb_totais  IN OUT nocopy SSPB0001.typ_tab_logspb_totais  --> TempTable para armazenar os totais
                              ) IS
    /*.........................................................................
    --
    --  Programa : pc_busca_log_SPB           Antigo: b1wgen0050.p/busca-enviada-ok
    --                                                             busca-enviada-nok
    --                                                             busca-recebida-ok
    --                                                             busca-recebida-nok
    --                                                             busca-rejeitada-ok
    --
    --  Sistema  : Cred
    --  Sigla    : SSPB0001
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : novembro/2013.                   Ultima atualizacao: 26/09/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : ler mensagem de log SPB e gerar TempTable
    --   Alteracoes:
    --               10/11/2015 - Adicionado parametro de entrada pr_inestcri.
    --                            (Jorge/Andrino)
    --
    --               26/09/2016 - M211 - Adicionado busca das TEDs Sicredi e correcao
    --                            de parametros faltantes (Jonata-RKAM)
      ..............................................................................*/

    vr_nrseqlog PLS_INTEGER;
    vr_nrregist INTEGER;
    vr_qtregist NUMBER := 0;
    vr_qtsitlog NUMBER := 0;
    vr_vlsitlog NUMBER := 0;
    vr_idx      VARCHAR2(20);

    --Ler Log de mensagens para transa��es ao SPB
    CURSOR cr_craplmt IS
      SELECT vldocmto,
             nrsequen,
             cdbandif,
             cdagedif,
             nrctadif,
             nmtitdif,
             nrcpfdif,
             cdbanctl,
             cdagectl,
             nrdconta,
             nmcopcta,
             nrcpfcop,
             hrtransa,
             dsmotivo,
             cdagenci,
             nrdcaixa,
             cdoperad,
             idorigem,
             nrctrlif,
             nmevento
        FROM craplmt
       WHERE craplmt.cdcooper = pr_cdcooper
         AND ((craplmt.nrdconta = pr_nrdconta AND pr_nrdconta <> 0) OR
               pr_nrdconta = 0)
         AND ((craplmt.nrsequen = pr_nrsequen AND pr_nrsequen <> 0) OR
               pr_nrsequen = 0)   
         AND ((craplmt.idorigem = pr_cdorigem AND pr_cdorigem <> 0) OR
               pr_cdorigem = 0)
         AND craplmt.dttransa BETWEEN pr_dtmvtini AND pr_dtmvtfim
         AND ((craplmt.vldocmto = pr_vlrdated AND pr_vlrdated <> 0) OR
               pr_vlrdated = 0)
         AND ((pr_inestcri = 1           AND
               craplmt.inestcri IN (1,2) AND
               craplmt.nmevento IN ('STR0005R2','STR0007R2','STR0008R2', -- TED
                                    'PAG0107R2','PAG0108R2','PAG0143R2', -- TED
                                    'STR0037R2','PAG0137R2')) -- TEC
              OR
              pr_inestcri = 0)
         AND (pr_cdifconv = 3 OR (pr_cdifconv IN(0,1) AND cdifconv = pr_cdifconv))     
         AND craplmt.idsitmsg = pr_idsitmsg -- (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
       ORDER BY craplmt.hrtransa, craplmt.nrsequen;

  BEGIN

    vr_nrregist := pr_nrregist;
    vr_qtregist := 0;
    vr_qtsitlog := 0;
    vr_vlsitlog := 0;

    --Ler Log de mensagens para transa��es ao SPB
    FOR rw_craplmt IN cr_craplmt LOOP

      vr_qtregist := vr_qtregist + 1;
      -- Acumular totais
      IF pr_tab_logspb_totais.EXISTS(pr_idsitmsg) THEN
        pr_tab_logspb_totais(pr_idsitmsg).qtsitlog := nvl(pr_tab_logspb_totais(pr_idsitmsg).qtsitlog,0)
                                                        + 1;
        pr_tab_logspb_totais(pr_idsitmsg).vlsitlog := nvl(pr_tab_logspb_totais(pr_idsitmsg).vlsitlog,0)
                                                        + rw_craplmt.vldocmto;
      ELSE --Se n�o existe, somente inicializar
        pr_tab_logspb_totais(pr_idsitmsg).qtsitlog := 1;
        pr_tab_logspb_totais(pr_idsitmsg).vlsitlog := rw_craplmt.vldocmto;
      END IF;

      IF  vr_nrregist > 0 THEN
        vr_idx := lpad(rw_craplmt.hrtransa,10,'0')||lpad(rw_craplmt.nrsequen,10,'0');

         pr_tab_logspb_detalhe(vr_idx).nrseqlog := rw_craplmt.nrsequen;

         IF pr_idsitmsg IN (1,2,5) THEN -- ENVIADA-OK OU ENVIADA-NOK OU REJEITADA-OK
           pr_tab_logspb_detalhe(vr_idx).cdbanrem := rw_craplmt.cdbanctl;
           pr_tab_logspb_detalhe(vr_idx).cdagerem := rw_craplmt.cdagectl;
           pr_tab_logspb_detalhe(vr_idx).nrctarem := rw_craplmt.nrdconta;
           pr_tab_logspb_detalhe(vr_idx).dsnomrem := rw_craplmt.nmcopcta;
           pr_tab_logspb_detalhe(vr_idx).dscpfrem := rw_craplmt.nrcpfcop;
           pr_tab_logspb_detalhe(vr_idx).cdbandst := rw_craplmt.cdbandif;
           pr_tab_logspb_detalhe(vr_idx).cdagedst := rw_craplmt.cdagedif;
           pr_tab_logspb_detalhe(vr_idx).nrctadst := rw_craplmt.nrctadif;
           pr_tab_logspb_detalhe(vr_idx).dsnomdst := rw_craplmt.nmtitdif;
           pr_tab_logspb_detalhe(vr_idx).dscpfdst := rw_craplmt.nrcpfdif;

         ELSIF pr_idsitmsg IN (3,4) THEN -- RECEBIDA-OK OU RECEBIDA-NOK
           pr_tab_logspb_detalhe(vr_idx).cdbanrem := rw_craplmt.cdbandif;
           pr_tab_logspb_detalhe(vr_idx).cdagerem := rw_craplmt.cdagedif;
           pr_tab_logspb_detalhe(vr_idx).nrctarem := rw_craplmt.nrctadif;
           pr_tab_logspb_detalhe(vr_idx).dsnomrem := rw_craplmt.nmtitdif;
           pr_tab_logspb_detalhe(vr_idx).dscpfrem := rw_craplmt.nrcpfdif;
           pr_tab_logspb_detalhe(vr_idx).cdbandst := rw_craplmt.cdbanctl;
           pr_tab_logspb_detalhe(vr_idx).cdagedst := rw_craplmt.cdagectl;
           pr_tab_logspb_detalhe(vr_idx).nrctadst := rw_craplmt.nrdconta;
           pr_tab_logspb_detalhe(vr_idx).dsnomdst := rw_craplmt.nmcopcta;
           pr_tab_logspb_detalhe(vr_idx).dscpfdst := rw_craplmt.nrcpfcop;

         END IF;         
         
         pr_tab_logspb_detalhe(vr_idx).nmevento := rw_craplmt.nmevento;
         pr_tab_logspb_detalhe(vr_idx).nrctrlif := rw_craplmt.nrctrlif;
         pr_tab_logspb_detalhe(vr_idx).hrtransa := rw_craplmt.hrtransa;
         pr_tab_logspb_detalhe(vr_idx).vltransa := rw_craplmt.vldocmto;
         pr_tab_logspb_detalhe(vr_idx).dsmotivo := rw_craplmt.dsmotivo;
         pr_tab_logspb_detalhe(vr_idx).dstransa := (CASE pr_idsitmsg
                                                     WHEN 1 THEN 'ENVIADA OK'
                                                     WHEN 2 THEN 'ENVIADA NAO OK'
                                                     WHEN 3 THEN 'RECEBIDA OK'
                                                     WHEN 4 THEN 'RECEBIDA NAO OK'
                                                     WHEN 5 THEN 'REJEITADA OK'
                                                    END);
         pr_tab_logspb_detalhe(vr_idx).cdagenci := rw_craplmt.cdagenci ;
         pr_tab_logspb_detalhe(vr_idx).nrdcaixa := rw_craplmt.nrdcaixa ;
         pr_tab_logspb_detalhe(vr_idx).cdoperad := rw_craplmt.cdoperad ;
         pr_tab_logspb_detalhe(vr_idx).dsorigem := (CASE rw_craplmt.idorigem
                                                     WHEN 1 THEN 'AYLLOS'
                                                     WHEN 2 THEN 'CAIXA ONLINE'
                                                     WHEN 3 THEN 'INTERNET'
                                                     WHEN 4 THEN 'TAA'
                                                     ELSE NULL
                                                   END);

      END IF;

      vr_nrregist := vr_nrregist - 1;

      /* Variaveis CHAR
       Como pode haver digito X nas contas - adicionar 0 a frente
       PS: mesmo a conta do remetente pode ter, pois pode ser o
       remetente de outra instituicao financeira. */
      pr_tab_logspb_detalhe(vr_idx).nrctarem := lpad(pr_tab_logspb_detalhe(vr_idx).nrctarem,14,'0');
      pr_tab_logspb_detalhe(vr_idx).nrctadst := lpad(pr_tab_logspb_detalhe(vr_idx).nrctadst,14,'0');

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao buscar log SPB (pc_busca_log_SPB): '||SQLerrm;

  END pc_busca_log_SPB;

  /** Procedimento para gravar as informa��es da mensagem de log SPB na TempTable **/
  PROCEDURE pc_grava_detalhe (pr_idsitmsg IN INTEGER  -- Indicador de tipo de mensagem (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                             ,pr_dslinlog IN varchar2 -- descri��o da linha do log
                             ,pr_tab_logspb_detalhe IN OUT nocopy SSPB0001.typ_tab_logspb_detalhe --> TempTable para armazenar o valor
                             ,pr_tab_logspb_totais  IN OUT nocopy SSPB0001.typ_tab_logspb_totais  --> Variavel para armazenar os totais por situa��o de log
                             ,pr_dscritic OUT VARCHAR2 -- DEscri��o da critica
                              ) IS
    /*.........................................................................
    --
    --  Programa : pc_grava_detalhe           Antigo: b1wgen0050.p/grava-enviada-ok
    --                                                             grava-enviada-nok
    --                                                             grava-recebida-ok
    --                                                             grava-recebida-nok
    --                                                             grava-rejeitada-ok
    --
    --  Sistema  : Cred
    --  Sigla    : SSPB0001
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : novembro/2013.                   Ultima atualizacao: 22/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gravar as informa��es da mensagem de log SPB na TempTable
      ..............................................................................*/

    vr_dslinlog VARCHAR2(4000);
    vr_nrseqlog INTEGER;
    vr_idx      VARCHAR2(20);

  BEGIN

    vr_dslinlog := SUBSTR(vr_dslinlog,instr(vr_dslinlog,'-->') + 4);
    vr_nrseqlog := pr_tab_logspb_detalhe.count + 1;

    IF pr_idsitmsg IN (1) THEN --Enviada OK
      vr_idx := lpad(SUBSTR(vr_dslinlog,115,8),10,'0')||lpad(vr_nrseqlog,10,'0');

      pr_tab_logspb_detalhe(vr_idx).nrseqlog := vr_nrseqlog;
      pr_tab_logspb_detalhe(vr_idx).cdbanrem := to_number(SUBSTR(vr_dslinlog,162,3));
      pr_tab_logspb_detalhe(vr_idx).cdagerem := to_number(SUBSTR(vr_dslinlog,183,4));
      pr_tab_logspb_detalhe(vr_idx).nrctarem := TRIM(SUBSTR(vr_dslinlog,203,9));
      pr_tab_logspb_detalhe(vr_idx).dsnomrem := UPPER(SUBSTR(vr_dslinlog,227,40));
      pr_tab_logspb_detalhe(vr_idx).dscpfrem := to_number(SUBSTR(vr_dslinlog,286,14));
      pr_tab_logspb_detalhe(vr_idx).cdbandst := to_number(SUBSTR(vr_dslinlog,315,3));
      pr_tab_logspb_detalhe(vr_idx).cdagedst := to_number(SUBSTR(vr_dslinlog,335,4));
      pr_tab_logspb_detalhe(vr_idx).nrctadst := TRIM(SUBSTR(vr_dslinlog,354,14));
      pr_tab_logspb_detalhe(vr_idx).dsnomdst := UPPER(SUBSTR(vr_dslinlog,382,40));
      pr_tab_logspb_detalhe(vr_idx).dscpfdst := to_number(SUBSTR(vr_dslinlog,440,14));
      pr_tab_logspb_detalhe(vr_idx).hrtransa := SUBSTR(vr_dslinlog,115,8);
      pr_tab_logspb_detalhe(vr_idx).vltransa := to_number(SUBSTR(vr_dslinlog,132,14));
      pr_tab_logspb_detalhe(vr_idx).dsmotivo := ( CASE
                                                   WHEN SUBSTR(vr_dslinlog,59,7) = 'STR0004'  THEN
                                                        'STR0004 - '||SUBSTR(vr_dslinlog,454)
                                                  END);

      pr_tab_logspb_detalhe(vr_idx).hrtransa := SUBSTR(vr_dslinlog,115,8);
      pr_tab_logspb_detalhe(vr_idx).vltransa := to_number(SUBSTR(vr_dslinlog,132,14));

   ELSIF pr_idsitmsg IN (3) THEN  --Recebida OK

      vr_idx := lpad(SUBSTR(vr_dslinlog,115,8),10,'0')||lpad(vr_nrseqlog,10,'0');

      pr_tab_logspb_detalhe(vr_idx).nrseqlog := vr_nrseqlog;
      pr_tab_logspb_detalhe(vr_idx).cdbanrem := to_number(SUBSTR(vr_dslinlog,162,3));
      pr_tab_logspb_detalhe(vr_idx).cdagerem := to_number(SUBSTR(vr_dslinlog,183,4));
      pr_tab_logspb_detalhe(vr_idx).nrctarem := TRIM(SUBSTR(vr_dslinlog,203,14));
      pr_tab_logspb_detalhe(vr_idx).dsnomrem := UPPER(SUBSTR(vr_dslinlog,232,40));
      pr_tab_logspb_detalhe(vr_idx).dscpfrem := to_number(SUBSTR(vr_dslinlog,291,14));
      pr_tab_logspb_detalhe(vr_idx).cdbandst := to_number(SUBSTR(vr_dslinlog,320,3));
      pr_tab_logspb_detalhe(vr_idx).cdagedst := to_number(SUBSTR(vr_dslinlog,340,4));
      pr_tab_logspb_detalhe(vr_idx).nrctadst := TRIM(SUBSTR(vr_dslinlog,359,14));
      pr_tab_logspb_detalhe(vr_idx).dsnomdst := UPPER(SUBSTR(vr_dslinlog,387,40));
      pr_tab_logspb_detalhe(vr_idx).dscpfdst := to_number(SUBSTR(vr_dslinlog,445,14));
      pr_tab_logspb_detalhe(vr_idx).dsmotivo := null;
      pr_tab_logspb_detalhe(vr_idx).hrtransa := SUBSTR(vr_dslinlog,115,8);
      pr_tab_logspb_detalhe(vr_idx).vltransa := to_number(SUBSTR(vr_dslinlog,132,14));

    ELSIF pr_idsitmsg IN (2,5) THEN   -- Enviada NOK, Rejeitada OK
      vr_idx := lpad(SUBSTR(vr_dslinlog,220,8),10,'0')||lpad(vr_nrseqlog,10,'0');

      pr_tab_logspb_detalhe(vr_idx).nrseqlog := vr_nrseqlog;
      pr_tab_logspb_detalhe(vr_idx).cdbanrem := to_number(SUBSTR(vr_dslinlog,267,3));
      pr_tab_logspb_detalhe(vr_idx).cdagerem := to_number(SUBSTR(vr_dslinlog,288,4));
      pr_tab_logspb_detalhe(vr_idx).nrctarem := TRIM(SUBSTR(vr_dslinlog,308,9));
      pr_tab_logspb_detalhe(vr_idx).dsnomrem := UPPER(SUBSTR(vr_dslinlog,332,40));
      pr_tab_logspb_detalhe(vr_idx).dscpfrem := to_number(SUBSTR(vr_dslinlog,391,14));
      pr_tab_logspb_detalhe(vr_idx).cdbandst := to_number(SUBSTR(vr_dslinlog,420,3));
      pr_tab_logspb_detalhe(vr_idx).cdagedst := to_number(SUBSTR(vr_dslinlog,440,4));
      pr_tab_logspb_detalhe(vr_idx).nrctadst := TRIM(SUBSTR(vr_dslinlog,459,14));
      pr_tab_logspb_detalhe(vr_idx).dsnomdst := UPPER(SUBSTR(vr_dslinlog,487,40));
      pr_tab_logspb_detalhe(vr_idx).dscpfdst := to_number(SUBSTR(vr_dslinlog,545,14));
      pr_tab_logspb_detalhe(vr_idx).dsmotivo := UPPER(SUBSTR(vr_dslinlog,83,90));
      pr_tab_logspb_detalhe(vr_idx).hrtransa := SUBSTR(vr_dslinlog,220,8);
      pr_tab_logspb_detalhe(vr_idx).vltransa := to_number(SUBSTR(vr_dslinlog,237,14));

    ELSIF pr_idsitmsg IN (4) THEN   -- Recebida NOK
      vr_idx := lpad(SUBSTR(vr_dslinlog,220,8),10,'0')||lpad(vr_nrseqlog,10,'0');

      pr_tab_logspb_detalhe(vr_idx).nrseqlog := vr_nrseqlog;
      pr_tab_logspb_detalhe(vr_idx).cdbanrem := to_number(SUBSTR(vr_dslinlog,267,3));
      pr_tab_logspb_detalhe(vr_idx).cdagerem := to_number(SUBSTR(vr_dslinlog,288,4));
      pr_tab_logspb_detalhe(vr_idx).nrctarem := TRIM(SUBSTR(vr_dslinlog,308,14));
      pr_tab_logspb_detalhe(vr_idx).dsnomrem := UPPER(SUBSTR(vr_dslinlog,337,40));
      pr_tab_logspb_detalhe(vr_idx).dscpfrem := to_number(SUBSTR(vr_dslinlog,396,14));
      pr_tab_logspb_detalhe(vr_idx).cdbandst := to_number(SUBSTR(vr_dslinlog,425,3));
      pr_tab_logspb_detalhe(vr_idx).cdagedst := to_number(SUBSTR(vr_dslinlog,445,4));
      pr_tab_logspb_detalhe(vr_idx).nrctadst := TRIM(SUBSTR(vr_dslinlog,464,14));
      pr_tab_logspb_detalhe(vr_idx).dsnomdst := UPPER(SUBSTR(vr_dslinlog,492,40));
      pr_tab_logspb_detalhe(vr_idx).dscpfdst := to_number(SUBSTR(vr_dslinlog,550,14));
      pr_tab_logspb_detalhe(vr_idx).hrtransa := SUBSTR(vr_dslinlog,220,8);
      pr_tab_logspb_detalhe(vr_idx).vltransa := to_number(SUBSTR(vr_dslinlog,237,14));
      pr_tab_logspb_detalhe(vr_idx).dsmotivo := UPPER(SUBSTR(vr_dslinlog,83,90));

    END IF;

    pr_tab_logspb_detalhe(vr_idx).dstransa := (CASE pr_idsitmsg
                                                 WHEN 1 THEN 'ENVIADA OK'
                                                 WHEN 2 THEN 'ENVIADA NAO OK'
                                                 WHEN 3 THEN 'RECEBIDA OK'
                                                 WHEN 4 THEN 'RECEBIDA NAO OK'
                                                 WHEN 5 THEN 'REJEITADA OK'
                                                END);


    -- Acumular totais
    pr_tab_logspb_totais(pr_idsitmsg).qtsitlog := nvl(pr_tab_logspb_totais(pr_idsitmsg).qtsitlog,0)
                                                    + 1;
    pr_tab_logspb_totais(pr_idsitmsg).vlsitlog := nvl(pr_tab_logspb_totais(pr_idsitmsg).vlsitlog,0)
                                                    + pr_tab_logspb_detalhe(vr_idx).vltransa;


    /* Variaveis CHAR
       Como pode haver digito X nas contas - adicionar 0 a frente
       PS: mesmo a conta do remetente pode ter, pois pode ser o
       remetente de outra instituicao financeira. */
    pr_tab_logspb_detalhe(vr_idx).nrctarem := lpad(pr_tab_logspb_detalhe(vr_idx).nrctarem,14,'0');
    pr_tab_logspb_detalhe(vr_idx).nrctadst := lpad(pr_tab_logspb_detalhe(vr_idx).nrctadst,14,'0');

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao grava detalhe (pc_grava_detalhe): '||SQLerrm;
  END pc_grava_detalhe;


  /** Procedimento para ler o arquivo de log do SPB*/
  PROCEDURE pc_le_arquivo_log (pr_nmarqlog IN VARCHAR2  -- Nomer do arquivo de log
                              ,pr_numedlog IN varchar2 -- Indicador de log a carregar
                              ,pr_cdsitlog IN varchar2 -- Codigo de situa��o de log
                              ,pr_dscritic OUT varchar2
                              ,pr_tab_logspb_detalhe IN OUT nocopy SSPB0001.typ_tab_logspb_detalhe --> TempTable para armazenar o valor
                              ,pr_tab_logspb_totais  IN OUT nocopy SSPB0001.typ_tab_logspb_totais  --> Variavel para armazenar os totais por situa��o de log
                              ,pr_tab_logspb         IN OUT nocopy SSPB0001.typ_tab_logspb         --> TempTable para armazenar o valor
                              ) IS
    /*.........................................................................
    --
    --  Programa : pc_le_arquivo_log           Antigo: b1wgen0050.p/le-arquivo-log
    --
    --
    --  Sistema  : Cred
    --  Sigla    : SSPB0001
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : novembro/2013.                   Ultima atualizacao: 27/09/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Ler o arquivo de log do SPB
    --   Alteracoes
    --               27/09/2016 - Ajuste na rotina devido problemas nos testes do M211
    --                            Jonata - RKAM
      ..............................................................................*/

    vr_exc_erro EXCEPTION;

    --variavei leitura do arquivo
    vr_nmdireto    varchar2(100);
    vr_nmarquiv    varchar2(100);
    vr_input_file  UTL_FILE.file_type;
    vr_dslinlog    varchar2(750);

  BEGIN

     --Separar o nome do arquivo do caminho
     GENE0001.pc_separa_arquivo_path(pr_caminho => pr_nmarqlog
                                    ,pr_direto  => vr_nmdireto
                                    ,pr_arquivo => vr_nmarquiv);

     --Abre o arquivo de log
     gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto     --> Diretorio do arquivo
                             ,pr_nmarquiv => vr_nmarquiv     --> Nome do arquivo
                             ,pr_tipabert => 'R'             --> Modo de abertura (R,W,A)
                             ,pr_utlfileh => vr_input_file   --> Handle do arquivo aberto
                             ,pr_des_erro => pr_dscritic);   --> Erro
     IF pr_dscritic IS NOT NULL THEN
       --Levantar Excecao
       RAISE vr_exc_erro;
     END IF;

     -- ler linhas do arquivo
     LOOP
       BEGIN
         gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                     ,pr_des_text => vr_dslinlog); --> Texto lido
       EXCEPTION
         -- Sair se n�o achar mais linhas
         WHEN NO_DATA_FOUND THEN
           gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
           EXIT;
       END;

       IF  pr_numedlog = 0  THEN -- Todos
         IF vr_dslinlog like '%ENVIADA OK%' THEN
           --grava-enviada-ok.
           SSPB0001.pc_grava_detalhe
                      (pr_idsitmsg => 1  -- Tipo de msg (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                      ,pr_dslinlog => vr_dslinlog -- descri��o da linha do log
                      ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe--> TempTable para armazenar o valor
                      ,pr_tab_logspb_totais  => pr_tab_logspb_totais --> Variavel para armazenar os totais por situa��o de log
                      ,pr_dscritic => pr_dscritic
                        );
         ELSIF vr_dslinlog like '%ENVIADA NAO OK%'  THEN
           --grava-enviada-nok.
           SSPB0001.pc_grava_detalhe
                      (pr_idsitmsg => 2  -- Tipo de msg (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                      ,pr_dslinlog => vr_dslinlog -- descri��o da linha do log
                      ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe--> TempTable para armazenar o valor
                      ,pr_tab_logspb_totais  => pr_tab_logspb_totais --> Variavel para armazenar os totais por situa��o de log
                      ,pr_dscritic => pr_dscritic
                       );
         ELSIF  vr_dslinlog like '%RECEBIDA OK%'  THEN
           --grava-recebida-ok.
           SSPB0001.pc_grava_detalhe
                      (pr_idsitmsg => 3  -- Tipo de msg (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                      ,pr_dslinlog => vr_dslinlog -- descri��o da linha do log
                      ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe--> TempTable para armazenar o valor
                      ,pr_tab_logspb_totais  => pr_tab_logspb_totais --> Variavel para armazenar os totais por situa��o de log
                      ,pr_dscritic => pr_dscritic
                       );
         ELSIF  vr_dslinlog like '%RECEBIDA NAO OK%'  THEN
           -- grava-recebida-nok.
           SSPB0001.pc_grava_detalhe
                      (pr_idsitmsg => 4  -- Tipo de msg (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                      ,pr_dslinlog => vr_dslinlog -- descri��o da linha do log
                      ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe--> TempTable para armazenar o valor
                      ,pr_tab_logspb_totais  => pr_tab_logspb_totais --> Variavel para armazenar os totais por situa��o de log
                      ,pr_dscritic => pr_dscritic
                       );
         ELSIF vr_dslinlog like '%REJEITADA OK%' THEN
           -- grava-rejeitada-ok.
           SSPB0001.pc_grava_detalhe
                      (pr_idsitmsg => 5  -- Tipo de msg (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                      ,pr_dslinlog => vr_dslinlog -- descri��o da linha do log
                      ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe--> TempTable para armazenar o valor
                      ,pr_tab_logspb_totais  => pr_tab_logspb_totais --> Variavel para armazenar os totais por situa��o de log
                      ,pr_dscritic => pr_dscritic
                       );
         ELSIF vr_dslinlog like '%RETORNO JD OK%'    OR
               vr_dslinlog like '%RETORNO SPB%'      OR
               vr_dslinlog like '%REJEITADA NAO OK%' OR
               vr_dslinlog like '%PAG0101%'          OR
               vr_dslinlog like '%STR0018%'          OR
               vr_dslinlog like '%STR0019%'        THEN
           --RUN grava-msg-log.
           SSPB0001.pc_grava_msg_log (pr_tab_logspb => pr_tab_logspb, --> TempTable para armazenar o valor
                                      pr_dslinlog   => vr_dslinlog,   --> Mensagem a ser armazenada
                                      pr_tab_logspb_totais  => pr_tab_logspb_totais); --> Variavel para armazenar os totais por situa��o de log
         END IF;

      ELSIF pr_numedlog = 1  THEN  -- Enviado
        IF pr_cdsitlog = 'P'  THEN -- Processadas
          -- grava-enviada-ok.
          SSPB0001.pc_grava_detalhe
                      (pr_idsitmsg => 1  -- Tipo de msg (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                      ,pr_dslinlog => vr_dslinlog -- descri��o da linha do log
                      ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe--> TempTable para armazenar o valor
                      ,pr_tab_logspb_totais  => pr_tab_logspb_totais --> Variavel para armazenar os totais por situa��o de log
                      ,pr_dscritic => pr_dscritic
                        );
        ELSIF pr_cdsitlog = 'D'                  AND -- Devolvidas
              vr_dslinlog like '%ENVIADA NAO OK%' THEN
          -- grava-enviada-nok.
          SSPB0001.pc_grava_detalhe
                      (pr_idsitmsg => 2  -- Tipo de msg (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                      ,pr_dslinlog => vr_dslinlog -- descri��o da linha do log
                      ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe--> TempTable para armazenar o valor
                      ,pr_tab_logspb_totais  => pr_tab_logspb_totais --> Variavel para armazenar os totais por situa��o de log
                      ,pr_dscritic => pr_dscritic
                        );
        ELSIF pr_cdsitlog = 'R'                  AND  -- rejeitadas
              vr_dslinlog like '%REJEITADA OK%' THEN
          --  grava-rejeitada-ok.
          SSPB0001.pc_grava_detalhe
                      (pr_idsitmsg => 5  -- Tipo de msg (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                      ,pr_dslinlog => vr_dslinlog -- descri��o da linha do log
                      ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe--> TempTable para armazenar o valor
                      ,pr_tab_logspb_totais  => pr_tab_logspb_totais --> Variavel para armazenar os totais por situa��o de log
                      ,pr_dscritic => pr_dscritic
                        );
        END IF;
      ELSIF pr_numedlog = 2  THEN -- recebidas
        IF pr_cdsitlog = 'P'                AND  -- Processadas
           vr_dslinlog like '%RECEBIDA OK%' THEN
          -- grava-recebida-ok.
          --  grava-rejeitada-ok.
          SSPB0001.pc_grava_detalhe
                      (pr_idsitmsg => 3  -- Tipo de msg (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                      ,pr_dslinlog => vr_dslinlog -- descri��o da linha do log
                      ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe--> TempTable para armazenar o valor
                      ,pr_tab_logspb_totais  => pr_tab_logspb_totais --> Variavel para armazenar os totais por situa��o de log
                      ,pr_dscritic => pr_dscritic
                        );
        ELSIF pr_cdsitlog = 'D'                    AND -- Devolvidas
              vr_dslinlog like '%RECEBIDA NAO OK%' THEN
          -- grava-recebida-nok.
          SSPB0001.pc_grava_detalhe
                      (pr_idsitmsg => 4  -- Tipo de msg (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                      ,pr_dslinlog => vr_dslinlog -- descri��o da linha do log
                      ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe--> TempTable para armazenar o valor
                      ,pr_tab_logspb_totais  => pr_tab_logspb_totais --> Variavel para armazenar os totais por situa��o de log
                      ,pr_dscritic => pr_dscritic
                        );
        END IF;

      ELSIF pr_numedlog = 3                       AND -- Demais opera��es
           (vr_dslinlog like '%RETORNO JD OK%'    OR
            vr_dslinlog like '%RETORNO SPB%'      OR
            vr_dslinlog like '%REJEITADA NAO OK%' OR
            vr_dslinlog like '%PAG0101%'          OR
            vr_dslinlog like '%STR0018%'          OR
            vr_dslinlog like '%STR0019%')         THEN

        -- grava-msg-log.
        SSPB0001.pc_grava_msg_log (pr_tab_logspb => pr_tab_logspb, --> TempTable para armazenar o valor
                                   pr_dslinlog   => vr_dslinlog,   --> Mensagem a ser armazenada
                                   pr_tab_logspb_totais  => pr_tab_logspb_totais); --> Variavel para armazenar os totais por situa��o de log
      END IF;


    END LOOP; -- Fim loop linhas arquivo

  EXCEPTION
    WHEN vr_exc_erro THEN
      NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao ler arquivo de log (pc_le_arquivo_log): '||SQLerrm;
  END pc_le_arquivo_log;

  /** Procedimento para obter log do SPB da Cecred*/
  PROCEDURE pc_obtem_log_cecred ( pr_cdcooper  IN INTEGER   -- Codigo Cooperativa
                                 ,pr_cdagenci  IN INTEGER   -- Cod. Agencia
                                 ,pr_nrdcaixa  IN INTEGER   -- Numero  Caixa
                                 ,pr_cdoperad  IN VARCHAR2  -- Operador
                                 ,pr_nmdatela  IN VARCHAR2  -- Nome da tela
                                 ,pr_cdorigem  IN INTEGER   -- Identificador Origem
                                 ,pr_dtmvtini  IN DATE      -- Data de movimento de log Inicial
                                 ,pr_dtmvtfim  IN DATE      -- Data de movimento de log Final
                                 ,pr_numedlog  IN varchar2  -- Indicador de log a carregar
                                 ,pr_cdsitlog  IN varchar2  -- Codigo de situa��o de log
                                 ,pr_nrdconta  IN VARCHAR2  -- Numero da Conta
                                 ,pr_nrsequen  IN NUMBER    -- Numero sequencial
                                 ,pr_nriniseq  IN INTEGER   -- numero inicial da sequencia
                                 ,pr_nrregist  IN VARCHAR2  -- numero de registros
                                 ,pr_inestcri  IN INTEGER DEFAULT 0 -- Estado Crise
                                 ,pr_cdifconv  IN INTEGER DEFAULT 3 -- IF Da TED
                                 ,pr_vlrdated  IN NUMBER            -- Valor da TED
                                 ,pr_dscritic           OUT varchar2
                                 ,pr_tab_logspb         OUT nocopy SSPB0001.typ_tab_logspb         --> TempTable para armazenar o valor
                                 ,pr_tab_logspb_detalhe OUT nocopy SSPB0001.typ_tab_logspb_detalhe --> TempTable para armazenar o valor
                                 ,pr_tab_logspb_totais  OUT nocopy SSPB0001.typ_tab_logspb_totais  --> Variavel para armazenar os totais por situa��o de log
                                 ,pr_tab_erro           OUT GENE0001.typ_tab_erro                  --> Tabela contendo os erros
                                ) IS
    /*.........................................................................
    --
    --  Programa : pc_obtem_log_cecred           Antigo: b1wgen0050.p/obtem-log-cecred
    --
    --
    --  Sistema  : Cred
    --  Sigla    : SSPB0001
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : novembro/2013.                   Ultima atualizacao: 26/09/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Obter log do SPB da Cecred
    --   Alteracoes:
    --               10/11/2015 - Adicionado parametro de entrada pr_inestcri. 
    --                            (Jorge/Andrino)
    --
    --               26/09/2016 - M211 - Adicionado busca das TEDs Sicredi (Jonata-RKAM)              
      ..............................................................................*/

    vr_exc_erro EXCEPTION;

    vr_nmdireto    varchar2(100);
    vr_nmarqlog    varchar2(100);
    vr_input_file  UTL_FILE.file_type;
    vr_comando     VARCHAR2(500);
    vr_typ_saida   VARCHAR2(10);
    vr_dslinlog    varchar2(500);
    vr_nrregist    INTEGER;
    vr_nriniseq    INTEGER;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

  BEGIN
    /*********************************************************************
     * pr_numedlog => 1 - ENVIADAS / 2 - RECEBIDAS / 3 - DEMAIS MSG'S   *
     * pr_cdsitlog => "P" - MSG'S PROCESSADAS / "D" - MSG'S DEVOLVIDAS  *
     *                "R" - MSG'S REJEITADAS                            *
    /*********************************************************************/

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;

      vr_cdcritic := 651;
      vr_dscritic := null;
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => 1,
                            pr_cdcritic => vr_cdcritic,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);

      pr_dscritic := 'NOK';
      return;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Limpar temptable de total
    pr_tab_logspb_totais.delete;

    -- Inicializar variaveis
    IF NVL(pr_nriniseq,0) = 0  THEN
      vr_nriniseq := 1;
    ELSE
      vr_nriniseq := pr_nriniseq;
    END IF;

    IF NVL(pr_nrregist,0) = 0  THEN
      vr_nrregist := 999999;
    ELSE
      vr_nrregist := pr_nrregist;
    END IF;

    -- BUSCAR LOGS
    IF pr_numedlog = 0    OR
      (pr_numedlog = 1    AND   /** ENVIADAS    **/
       pr_cdsitlog = 'P') THEN  /** PROCESSADAS **/

      SSPB0001.pc_busca_log_SPB (pr_cdcooper  => pr_cdcooper -- Codigo cooperativa
                                ,pr_nrdconta  => pr_nrdconta -- Numero da Conta
                                ,pr_nrsequen  => pr_nrsequen -- Numero da sequencia
                                ,pr_cdorigem  => pr_cdorigem -- Codigo de origem
                                ,pr_dtmvtini  => pr_dtmvtini -- Data de movimento do log
                                ,pr_dtmvtfim  => pr_dtmvtfim -- Data de movimento do log
                                ,pr_idsitmsg  => 1           -- Indicador de tipo de mensagem (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                                ,pr_nriniseq  => vr_nriniseq -- numero inicial da sequencia
                                ,pr_nrregist  => vr_nrregist -- Numero de registros
                                ,pr_inestcri  => pr_inestcri -- Indicador Estado Crise
                                ,pr_cdifconv  => pr_cdifconv -- IF da TED
                                ,pr_vlrdated  => pr_vlrdated -- Valor da TED
                                ,pr_dscritic  => pr_dscritic-- Descricao do erro
                                ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe --> TempTable para armazenar o valor
                                ,pr_tab_logspb_totais  => pr_tab_logspb_totais
                                );
    END IF;

    IF pr_numedlog = 0    OR
       (pr_numedlog = 1    AND  /** ENVIADAS   **/
        pr_cdsitlog = 'D') THEN /** DEVOLVIDAS **/

      SSPB0001.pc_busca_log_SPB (pr_cdcooper  => pr_cdcooper -- Codigo cooperativa
                                ,pr_nrdconta  => pr_nrdconta -- Numero da Conta
                                ,pr_nrsequen  => pr_nrsequen -- Numero da sequencia
                                ,pr_cdorigem  => pr_cdorigem -- Codigo de origem
                                ,pr_dtmvtini  => pr_dtmvtini -- Data de movimento do log
                                ,pr_dtmvtfim  => pr_dtmvtfim -- Data de movimento do log
                                ,pr_idsitmsg  => 2           -- Indicador de tipo de mensagem (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                                ,pr_nriniseq  => vr_nriniseq -- numero inicial da sequencia
                                ,pr_nrregist  => vr_nrregist -- Numero de registros
                                ,pr_inestcri  => pr_inestcri -- Indicador Estado Crise
                                ,pr_cdifconv  => pr_cdifconv -- IF da TED
                                ,pr_vlrdated  => pr_vlrdated -- Valor da TED
                                ,pr_dscritic  => pr_dscritic -- Descricao do erro
                                ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe --> TempTable para armazenar o valor
                                ,pr_tab_logspb_totais  => pr_tab_logspb_totais
                                );

    END IF;

    IF pr_numedlog = 0     OR
       (pr_numedlog = 1     AND  /** ENVIADAS   **/
        pr_cdsitlog = 'R')  THEN /** ENVIADAS REJEITADAS **/
      SSPB0001.pc_busca_log_SPB (pr_cdcooper  => pr_cdcooper -- Codigo cooperativa
                                ,pr_nrdconta  => pr_nrdconta -- Numero da Conta
                                ,pr_nrsequen  => pr_nrsequen -- Numero da sequencia
                                ,pr_cdorigem  => pr_cdorigem -- Codigo de origem
                                ,pr_dtmvtini  => pr_dtmvtini -- Data de movimento do log
                                ,pr_dtmvtfim  => pr_dtmvtfim -- Data de movimento do log
                                ,pr_idsitmsg  => 5           -- Indicador de tipo de mensagem (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                                ,pr_nriniseq  => vr_nriniseq -- numero inicial da sequencia
                                ,pr_nrregist  => vr_nrregist -- Numero de registros
                                ,pr_inestcri  => pr_inestcri -- Indicador Estado Crise
                                ,pr_cdifconv  => pr_cdifconv -- IF da TED
                                ,pr_vlrdated  => pr_vlrdated -- Valor da TED
                                ,pr_dscritic  => pr_dscritic -- Descricao do erro
                                ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe --> TempTable para armazenar o valor
                                ,pr_tab_logspb_totais  => pr_tab_logspb_totais
                                );

    END IF;

    IF  pr_numedlog = 0     OR
        (pr_numedlog  = 2   AND  /** RECEBIDAS   **/
         pr_cdsitlog = 'P') THEN /** PROCESSADAS **/

      SSPB0001.pc_busca_log_SPB (pr_cdcooper  => pr_cdcooper -- Codigo cooperativa
                                ,pr_nrdconta  => pr_nrdconta -- Numero da Conta
                                ,pr_nrsequen  => pr_nrsequen -- Numero da sequencia
                                ,pr_cdorigem  => pr_cdorigem -- Codigo de origem
                                ,pr_dtmvtini  => pr_dtmvtini -- Data de movimento do log
                                ,pr_dtmvtfim  => pr_dtmvtfim -- Data de movimento do log
                                ,pr_idsitmsg  => 3           -- Indicador de tipo de mensagem (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                                ,pr_nriniseq  => vr_nriniseq -- numero inicial da sequencia
                                ,pr_nrregist  => vr_nrregist -- Numero de registros
                                ,pr_inestcri  => pr_inestcri -- Indicador Estado Crise
                                ,pr_cdifconv  => pr_cdifconv -- IF da TED
                                ,pr_vlrdated  => pr_vlrdated -- Valor da TED
                                ,pr_dscritic  => pr_dscritic -- Descricao do erro
                                ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe --> TempTable para armazenar o valor
                                ,pr_tab_logspb_totais  => pr_tab_logspb_totais
                                );
    END IF;

    IF pr_numedlog = 0      OR
       (pr_numedlog = 2     AND    /** RECEBIDAS   **/
        pr_cdsitlog = 'D')  THEN  /** RECEBIDAS DEVOLVIDAS  **/

      SSPB0001.pc_busca_log_SPB (pr_cdcooper  => pr_cdcooper -- Codigo cooperativa
                                ,pr_nrdconta  => pr_nrdconta -- Numero da Conta
                                ,pr_nrsequen  => pr_nrsequen -- Numero da sequencia
                                ,pr_cdorigem  => pr_cdorigem -- Codigo de origem
                                ,pr_dtmvtini  => pr_dtmvtini -- Data de movimento do log
                                ,pr_dtmvtfim  => pr_dtmvtfim -- Data de movimento do log
                                ,pr_idsitmsg  => 4           -- Indicador de tipo de mensagem (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
                                ,pr_nriniseq  => vr_nriniseq -- numero inicial da sequencia
                                ,pr_nrregist  => vr_nrregist -- Numero de registros
                                ,pr_inestcri  => pr_inestcri -- Indicador Estado Crise
                                ,pr_cdifconv  => pr_cdifconv -- IF da TED
                                ,pr_vlrdated  => pr_vlrdated -- Valor da TED
                                ,pr_dscritic  => pr_dscritic -- Descricao do erro
                                ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe --> TempTable para armazenar o valor
                                ,pr_tab_logspb_totais  => pr_tab_logspb_totais
                                );

    END IF;

    IF pr_numedlog = 0  OR /** Todos **/
       pr_numedlog = 3  THEN /** DEMAIS MSG'S **/

      -- Busca do diretorio base da cooperativa
      vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nmsubdir => '/log');

      vr_nmarqlog := vr_nmdireto||'/mqcecred_processa_'||
                     to_char(pr_dtmvtini,'DDMMRR')||'.log';


      -- Verificar se o arquivo existe
      vr_comando:= 'ls ' || vr_nmarqlog|| ' | wc -l';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
      ELSE
        --Se retornou zero , n�o existe o arquivo
        IF pr_numedlog = 3 AND
           SUBSTR(vr_dscritic,1,1) = '0' AND
           vr_dscritic IS NULL THEN
          --Gerar Critica e sair do programa
          vr_cdcritic:= 0;
          vr_dscritic := 'Nao existe log das transacoes para este dia.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => 1,
                                pr_cdcritic => vr_cdcritic,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);

          pr_dscritic := 'NOK';
          return;

        ELSE
          vr_dscritic := NULL;

          SSPB0001.pc_le_arquivo_log ( pr_nmarqlog => vr_nmarqlog -- Nomer do arquivo de log
                                      ,pr_numedlog => 3-- Indicador de log a carregar
                                      ,pr_cdsitlog => null-- Codigo de situa��o de log
                                      ,pr_dscritic => vr_dscritic
                                      ,pr_tab_logspb_detalhe => pr_tab_logspb_detalhe --> TempTable para armazenar o valor
                                      ,pr_tab_logspb_totais  => pr_tab_logspb_totais  --> Variavel para armazenar os totais por situa��o de log
                                      ,pr_tab_logspb         => pr_tab_logspb         --> TempTable para armazenar o valor
                                      );

          IF pr_dscritic IS NOT NULL THEN
            GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                  pr_cdagenci => pr_cdagenci,
                                  pr_nrdcaixa => pr_nrdcaixa,
                                  pr_nrsequen => 1,
                                  pr_cdcritic => 0,
                                  pr_dscritic => vr_dscritic,
                                  pr_tab_erro => pr_tab_erro);

            pr_dscritic := 'NOK';
            return;
          END IF;

        END IF;

      END IF;

      -- Se n�o localizou nenhuma mensagem, gerar critica
      IF pr_numedlog = 3 AND /** DEMAIS MSG'S **/
         NVL(pr_tab_logspb.COUNT,0) = 0 THEN
        --Gerar Critica e sair do programa
        vr_cdcritic:= 0;
        vr_dscritic := 'Nao existem mensagens de log para este dia.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => 1,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);

        pr_dscritic := 'NOK';
        return;

      END IF;
    END IF;

    IF pr_numedlog = 1  OR   /** ENVIADAS **/
       pr_numedlog = 2  THEN /** RECEBIDAS **/

      -- Se n�o localizou nenhuma mensagem, gerar critica
      IF NVL(pr_tab_logspb_detalhe.COUNT,0) = 0 THEN
        --Gerar Critica e sair do programa
        vr_cdcritic:= 0;
        vr_dscritic := 'Nao existem mensagens '||
                       (CASE  pr_numedlog
                          WHEN 1  THEN 'enviadas'
                          ELSE 'recebidas'
                        END)||
                        ' para este dia.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => 1,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);

        pr_dscritic := 'NOK';
        return;
      END IF;

    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      vr_cdcritic:= 0;
      vr_dscritic := 'Erro ao obter log (pc_obtem_log_cecred): '||SQLerrm;

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => 1,
                            pr_cdcritic => vr_cdcritic,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
      pr_dscritic := 'NOK';

  END pc_obtem_log_cecred;

  /** Procedimento para obter log do SPB da Cecred sendo chamada via Progress */
  PROCEDURE pc_obtem_log_cecred_car ( pr_cdcooper  IN INTEGER   -- Codigo Cooperativa
                                     ,pr_cdagenci  IN INTEGER   -- Cod. Agencia
                                     ,pr_nrdcaixa  IN INTEGER   -- Numero  Caixa
                                     ,pr_cdoperad  IN VARCHAR2  -- Operador
                                     ,pr_nmdatela  IN VARCHAR2  -- Nome da tela
                                     ,pr_cdorigem  IN INTEGER   -- Identificador Origem
                                     ,pr_dtmvtini  IN DATE      -- Data de movimento de log Inicial
                                     ,pr_dtmvtfim  IN DATE      -- Data de movimento de log Final
                                     ,pr_numedlog  IN varchar2  -- Indicador de log a carregar
                                     ,pr_cdsitlog  IN varchar2  -- Codigo de situa��o de log
                                     ,pr_nrdconta  IN VARCHAR2  -- Numero da Conta
                                     ,pr_nrsequen  IN NUMBER    -- Numero sequencial
                                     ,pr_nriniseq  IN INTEGER   -- numero inicial da sequencia
                                     ,pr_nrregist  IN VARCHAR2  -- numero de registros
                                     ,pr_inestcri  IN INTEGER DEFAULT 0 -- Estado Crise
                                     ,pr_cdifconv  IN INTEGER DEFAULT 3 -- IF Da TED
                                     ,pr_vlrdated  IN NUMBER            -- Valor da TED
                                     ,pr_clob_logspb         OUT CLOB
                                     ,pr_clob_logspb_detalhe OUT CLOB
                                     ,pr_clob_logspb_totais  OUT CLOB
                                     ,pr_cdcritic            OUT NUMBER
                                     ,pr_dscritic            OUT VARCHAR2
                                    ) IS
    /*.........................................................................
    --
    --  Programa : pc_obtem_log_cecred_car           Antigo: N�o h�
    --
    --
    --  Sistema  : Cred
    --  Sigla    : SSPB0001
    --  Autor    : Evandro - RKAM
    --  Data     : Setembro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Obter log do SPB da Cecred chamada via PRogress
    --   Alteracoes:
    --               
      ..............................................................................*/
    -- Retornos da procedure em pltable
    vr_tab_logspb         SSPB0001.typ_tab_logspb;   
    vr_idx_logspb         INTEGER;       
    vr_tab_logspb_detalhe SSPB0001.typ_tab_logspb_detalhe;
    vr_idx_logspb_detalhe varchar2(20);
    vr_tab_logspb_totais  SSPB0001.typ_tab_logspb_totais;  
    vr_idx_logspb_totais  VARCHAR2(1);
    vr_tab_erro           GENE0001.typ_tab_erro;
    -- Auxiliar texto para gravacao no CLOB
    vr_dstextaux VARCHAR2(32767);
    vr_dsregistr VARCHAR2(32767);
  BEGIN
    pc_obtem_log_cecred ( pr_cdcooper  => pr_cdcooper   -- Codigo Cooperativa
                         ,pr_cdagenci  => pr_cdagenci   -- Cod. Agencia
                         ,pr_nrdcaixa  => pr_nrdcaixa   -- Numero  Caixa
                         ,pr_cdoperad  => pr_cdoperad   -- Operador
                         ,pr_nmdatela  => pr_nmdatela   -- Nome da tela
                         ,pr_cdorigem  => pr_cdorigem   -- Identificador Origem
                         ,pr_dtmvtini  => pr_dtmvtini   -- Data de movimento de log inicial
                         ,pr_dtmvtfim  => pr_dtmvtfim   -- Data de movimento de log final
                         ,pr_numedlog  => pr_numedlog   -- Indicador de log a carregar
                         ,pr_cdsitlog  => pr_cdsitlog   -- Codigo de situa��o de log
                         ,pr_nrdconta  => pr_nrdconta   -- Numero da Conta
                         ,pr_nrsequen  => pr_nrsequen   -- Numero sequencial
                         ,pr_nriniseq  => pr_nriniseq   -- numero inicial da sequencia
                         ,pr_nrregist  => pr_nrregist   -- numero de registros
                         ,pr_inestcri  => pr_inestcri   -- Estado Crise
                         ,pr_cdifconv  => pr_cdifconv   -- IF Da TED
                         ,pr_vlrdated  => pr_vlrdated   -- Valor da TED
                         ,pr_dscritic           => pr_dscritic
                         ,pr_tab_logspb         => vr_tab_logspb         --> TempTable para armazenar o valor
                         ,pr_tab_logspb_detalhe => vr_tab_logspb_detalhe --> TempTable para armazenar o valor
                         ,pr_tab_logspb_totais  => vr_tab_logspb_totais  --> Variavel para armazenar os totais por situa��o de log
                         ,pr_tab_erro           => vr_tab_erro           --> Tabela contendo os erros
                        );
    -- Se houve erro na chamada
    IF pr_dscritic = 'NOK' THEN                    
      -- Se houver erro na tab erro
      IF vr_tab_erro.count > 0 THEN
        pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;        
      END IF;    
    ELSE
      -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_logspb, TRUE);
        dbms_lob.open(pr_clob_logspb, dbms_lob.lob_readwrite);
        
        -- Insere o cabe�alho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_logspb
                               ,pr_texto_completo => vr_dstextaux
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><root>');
                               
        
        
      -- Efetuaremos leitura das pltables e converteremos as mesmas para XML
      IF vr_tab_logspb.count > 0 THEN
        

        -- Insere o cabe�alho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_logspb
                               ,pr_texto_completo => vr_dstextaux
                               ,pr_texto_novo     => '<linhas_logspb>');

        --Buscar Primeiro registro
        vr_idx_logspb := vr_tab_logspb.FIRST;

        --Percorrer todos as regionais
        WHILE vr_idx_logspb IS NOT NULL LOOP
          vr_dsregistr:= '<linhas>'||
                         '  <nrseqlog>' || nvl(vr_tab_logspb(vr_idx_logspb).nrseqlog,0)||'</nrseqlog>'||
                         '  <dslinlog>' || nvl(vr_tab_logspb(vr_idx_logspb).dslinlog,' ')||'</dslinlog>'||
                         '</linhas>';

           -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_logspb
                                 ,pr_texto_completo => vr_dstextaux
                                 ,pr_texto_novo     => vr_dsregistr
                                 ,pr_fecha_xml      => FALSE);

          --Proximo Registro
          vr_idx_logspb := vr_tab_logspb.NEXT(vr_idx_logspb);

        END LOOP;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_logspb
                               ,pr_texto_completo => vr_dstextaux
                               ,pr_texto_novo     => '</linhas_logspb>');
      END IF;
      
      IF vr_tab_logspb_detalhe.count > 0 THEN
         

        -- Insere o cabe�alho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_logspb
                               ,pr_texto_completo => vr_dstextaux
                               ,pr_texto_novo     => '<linhas_logspb_detalhe>');

        --Buscar Primeiro registro
        vr_idx_logspb_detalhe := vr_tab_logspb_detalhe.FIRST;

        --Percorrer todos as regionais
        WHILE vr_idx_logspb_detalhe IS NOT NULL LOOP
          vr_dsregistr:= '<linhas>'||
                         '  <nrseqlog>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).nrseqlog,0)||'</nrseqlog>'||
                         '  <cdbandst>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).cdbandst,0)||'</cdbandst>'||
                         '  <cdagedst>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).cdagedst,0)||'</cdagedst>'||
                         '  <nrctadst>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).nrctadst,' ')||'</nrctadst>'||
                         '  <dsnomdst>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).dsnomdst,' ')||'</dsnomdst>'||
                         '  <dscpfdst>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).dscpfdst,0)||'</dscpfdst>'||
                         '  <cdbanrem>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).cdbanrem,0)||'</cdbanrem>'||
                         '  <cdagerem>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).cdagerem,0)||'</cdagerem>'||
                         '  <nrctarem>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).nrctarem,' ')||'</nrctarem>'||
                         '  <dsnomrem>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).dsnomrem,' ')||'</dsnomrem>'||
                         '  <dscpfrem>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).dscpfrem,0)||'</dscpfrem>'||                                                                                                                                                                                                                                 
                         '  <hrtransa>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).hrtransa,' ')||'</hrtransa>'||  
                         '  <vltransa>' || nvl(to_char(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).vltransa,'fm999g999g9990d00'),'0')||'</vltransa>'||  
                         '  <dsmotivo>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).dsmotivo,' ')||'</dsmotivo>'||  
                         '  <dstransa>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).dstransa,' ')||'</dstransa>'||  
                         '  <dsorigem>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).dsorigem,' ')||'</dsorigem>'||  
                         '  <cdagenci>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).cdagenci,0)||'</cdagenci>'||  
                         '  <nrdcaixa>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).nrdcaixa,0)||'</nrdcaixa>'||  
                         '  <cdoperad>' || nvl(vr_tab_logspb_detalhe(vr_idx_logspb_detalhe).cdoperad,' ')||'</cdoperad>'||                                                                                                                                                                                                          
                         '</linhas>';
           -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_logspb
                                 ,pr_texto_completo => vr_dstextaux
                                 ,pr_texto_novo     => vr_dsregistr
                                 ,pr_fecha_xml      => FALSE);

          --Proximo Registro
          vr_idx_logspb_detalhe := vr_tab_logspb_detalhe.NEXT(vr_idx_logspb_detalhe);

        END LOOP;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_logspb
                               ,pr_texto_completo => vr_dstextaux
                               ,pr_texto_novo     => '</linhas_logspb_detalhe>');
      END IF;
      
      IF vr_tab_logspb_totais.count > 0 THEN
        

        -- Insere o cabe�alho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_logspb
                               ,pr_texto_completo => vr_dstextaux
                               ,pr_texto_novo     => '<linhas_logspb_totais>');

        --Buscar Primeiro registro
        vr_idx_logspb_totais := vr_tab_logspb_totais.FIRST;

        --Percorrer todos as regionais
        WHILE vr_idx_logspb_totais IS NOT NULL LOOP
          vr_dsregistr:= '<linhas>'||
                         '  <qtsitlog>' || nvl(to_char(vr_tab_logspb_totais(vr_idx_logspb_totais).qtsitlog,'fm999g999g9990'),'0')||'</qtsitlog>'||
                         '  <vlsitlog>' || nvl(to_char(vr_tab_logspb_totais(vr_idx_logspb_totais).vlsitlog,'fm999g999g9990d00'),'0')||'</vlsitlog>'||
                         '</linhas>';
           -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_logspb
                                 ,pr_texto_completo => vr_dstextaux
                                 ,pr_texto_novo     => vr_dsregistr
                                 ,pr_fecha_xml      => FALSE);

          --Proximo Registro
          vr_idx_logspb_totais := vr_tab_logspb_totais.NEXT(vr_idx_logspb_totais);

        END LOOP;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_logspb
                               ,pr_texto_completo => vr_dstextaux
                               ,pr_texto_novo     => '</linhas_logspb_totais></root>'
                               ,pr_fecha_xml      => TRUE);
      END IF;
      
    END IF;                    
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao obter log (pc_obtem_log_cecred): '||SQLerrm;
  END pc_obtem_log_cecred_car;


  /******************************************************************************/
  /**                       Gera log de envio TED                              **/
  /******************************************************************************/
  PROCEDURE pc_grava_log_ted
                        (pr_cdcooper IN INTEGER  --> Codigo cooperativo
                        ,pr_dttransa IN DATE     --> Data transa��o
                        ,pr_hrtransa IN INTEGER  --> Hora Transa��o
                        ,pr_idorigem IN INTEGER  --> Id de origem
                        ,pr_cdprogra IN VARCHAR2 --> Codigo do programa
                        ,pr_idsitmsg IN INTEGER  --> Situa��o da mensagem.
                        ,pr_nmarqmsg IN VARCHAR2 --> Nome do arquivo da mensagem.
                        ,pr_nmevento IN VARCHAR2 --> Descricao do evento da mensagem.
                        ,pr_nrctrlif IN VARCHAR2 --> Numero de controle da mensagem.
                        ,pr_vldocmto IN NUMBER   --> Valor do documento.
                        ,pr_cdbanctl IN INTEGER  --> Codigo de banco da central.
                        ,pr_cdagectl IN INTEGER  --> Codigo de agencia na central.
                        ,pr_nrdconta IN VARCHAR2 --> Numero da conta cooperado
                        ,pr_nmcopcta IN VARCHAR2 --> Nome do cooperado.
                        ,pr_nrcpfcop IN NUMBER   --> Cpf/cnpj do cooperado.
                        ,pr_cdbandif IN INTEGER  --> Codigo do banco da if.
                        ,pr_cdagedif IN INTEGER  --> Codigo da agencia na if.
                        ,pr_nrctadif IN VARCHAR2 --> Numero da conta na if.
                        ,pr_nmtitdif IN VARCHAR2 --> Nome do titular da conta na if.
                        ,pr_nrcpfdif IN NUMBER   --> Cpf/cnpj do titular da conta na if.
                        ,pr_cdidenti IN VARCHAR2 --> Codigo identificador da transacao.
                        ,pr_dsmotivo IN VARCHAR2 --> Descricao do motivo de erro na mensagem.
                        ,pr_cdagenci IN INTEGER  --> Numero do pa.
                        ,pr_nrdcaixa IN INTEGER  --> Numero do caixa.
                        ,pr_cdoperad IN VARCHAR2 --> Codigo do operador.
                        ,pr_nrispbif IN INTEGER  --> Numero de inscri��o SPB
                        ,pr_inestcri IN INTEGER DEFAULT 0 --> Estado crise
                        ,pr_cdifconv IN INTEGER DEFAULT 0 -->IF convenio 0 - CECRED / 1 - SICREDI
                        
                        --------- SAIDA --------
                        ,pr_cdcritic  OUT INTEGER       --> Codigo do erro
                        ,pr_dscritic  OUT VARCHAR2) IS  --> Descricao do erro

  /*---------------------------------------------------------------------------------------------------------------

      Programa : pc_grava_log_ted             Antigo: b1wgen0050/grava-log-ted
      Sistema  : Comunica��o com SPB
      Sigla    : CRED
      Autor    : Odirlei Busana - Amcom
      Data     : Junho/2015.                   Ultima atualizacao: 29/10/2015

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedimento para gera log de envio TED

      Altera��o : 10/06/2015 - Convers�o Progress -> Oracle (Odirlei-Amcom)

                  29/10/2015 - Inclusao do indicador estado de crise. (Jaison/Andrino)

  ---------------------------------------------------------------------------------------------------------------*/
    -----------------> CURSORES <--------------------
    ------------> ESTRUTURAS DE REGISTRO <-----------

    -----------------> VARIAVEIS <-------------------
    vr_nrdconta   NUMBER;
    vr_nrctadif   NUMBER;
    vr_nrsequen   NUMBER;

  BEGIN
    -- verificar se � somente numerico
    BEGIN
      vr_nrdconta := to_number(pr_nrdconta);
    EXCEPTION
      -- se apresentou erro, retirar os caracteris n�o numericos
      WHEN OTHERS THEN
        -- remover os caracteres n�o numericos e substituir por zero
        vr_nrdconta := REGEXP_REPLACE(pr_nrdconta,'([^1234567890])','0');
    END;

    BEGIN
      vr_nrctadif := to_number(pr_nrctadif);
    EXCEPTION
      -- se apresentou erro, retirar os caracteris n�o numericos
      WHEN OTHERS THEN
        -- remover os caracteres n�o numericos e substituir por zero
        vr_nrctadif := REGEXP_REPLACE(pr_nrctadif,'([^1234567890])','0');
    END;

    /* Busca a proxima sequencia do campo CRAPLMT.NRSEQUEN */
    vr_nrsequen := fn_sequence( 'CRAPLMT'
                               ,'NRSEQUEN'
                               , pr_cdcooper ||';'||
                                 to_char(pr_dttransa,'DD/MM/RRRR') ||';'||
                                 vr_nrdconta
                               ,'N');

    BEGIN
      INSERT INTO craplmt
               ( craplmt.cdcooper
                ,craplmt.dttransa
                ,craplmt.hrtransa
                ,craplmt.idorigem
                ,craplmt.cdprogra
                ,craplmt.idsitmsg
                ,craplmt.nmarqmsg
                ,craplmt.nmevento
                ,craplmt.nrctrlif
                ,craplmt.vldocmto
                ,craplmt.cdbanctl
                ,craplmt.cdagectl
                ,craplmt.nrdconta
                ,craplmt.nmcopcta
                ,craplmt.nrcpfcop
                ,craplmt.cdbandif
                ,craplmt.cdagedif
                ,craplmt.nrctadif
                ,craplmt.nmtitdif
                ,craplmt.nrcpfdif
                ,craplmt.cdidenti
                ,craplmt.dsmotivo
                ,craplmt.nrsequen
                ,craplmt.cdagenci
                ,craplmt.nrdcaixa
                ,craplmt.cdoperad
                ,craplmt.nrispbif
                ,craplmt.inestcri
                ,craplmt.cdifconv)
        VALUES ( nvl(pr_cdcooper,0)     --> craplmt.cdcooper
                ,pr_dttransa            --> craplmt.dttransa
                ,nvl(pr_hrtransa,0)     --> craplmt.hrtransa
                ,nvl(pr_idorigem,0)     --> craplmt.idorigem
                ,nvl(pr_cdprogra,' ')   --> craplmt.cdprogra
                ,nvl(pr_idsitmsg,0)     --> craplmt.idsitmsg
                ,nvl(pr_nmarqmsg,' ')   --> craplmt.nmarqmsg
                ,nvl(pr_nmevento,' ')   --> craplmt.nmevento
                ,nvl(pr_nrctrlif,' ')   --> craplmt.nrctrlif
                ,nvl(pr_vldocmto,0)     --> craplmt.vldocmto
                ,nvl(pr_cdbanctl,0)     --> craplmt.cdbanctl
                ,nvl(pr_cdagectl,0)     --> craplmt.cdagectl
                ,nvl(vr_nrdconta,0)     --> craplmt.nrdconta
                ,nvl(pr_nmcopcta,' ')   --> craplmt.nmcopcta
                ,nvl(pr_nrcpfcop,0)     --> craplmt.nrcpfcop
                ,nvl(pr_cdbandif,0)     --> craplmt.cdbandif
                ,nvl(pr_cdagedif,0)     --> craplmt.cdagedif
                ,nvl(vr_nrctadif,0)     --> craplmt.nrctadif
                ,nvl(pr_nmtitdif,' ')   --> craplmt.nmtitdif
                ,nvl(pr_nrcpfdif,0)     --> craplmt.nrcpfdif
                ,nvl(pr_cdidenti,' ')   --> craplmt.cdidenti
                ,nvl(pr_dsmotivo,' ')   --> craplmt.dsmotivo
                ,nvl(vr_nrsequen,0)     --> craplmt.nrsequen
                ,nvl(pr_cdagenci,0)     --> craplmt.cdagenci
                ,nvl(pr_nrdcaixa,0)     --> craplmt.nrdcaixa
                ,nvl(pr_cdoperad,' ')   --> craplmt.cdoperad
                ,nvl(pr_nrispbif,0)     --> craplmt.nrispbif
                ,nvl(pr_inestcri,0)     --> craplmt.inestcri
                ,nvl(pr_cdifconv,0));   --> craplmt.cdifconv

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'N�o foi possivel gravar crplmt: '||SQLERRM;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel gerar log TED: '||SQLERRM;
  END pc_grava_log_ted;

  /******************************************************************************/
  /**                     Gera arquivo XML para SPB                            **/
  /******************************************************************************/
  PROCEDURE pc_gera_xml (pr_cdcooper   IN INTEGER         --> Codigo da cooperativa
                        ,pr_cdorigem   IN INTEGER         --> Id de origem
                        ,pr_crapdat    IN BTCH0001.cr_crapdat%ROWTYPE --> rowtype da crapdat
                         /* HEADER */
                        ,pr_nmmsgenv   IN VARCHAR2        --> Cod. da Mensagem
                        ,pr_cdlegago   IN VARCHAR2        --> Cod. Legado
                        ,pr_tpmanut    IN VARCHAR2        --> Inclusao
                        ,pr_cdstatus   IN VARCHAR2        --> Mensagem do tipo definitiva
                        ,pr_nroperacao IN VARCHAR2        --> Numero de operacao
                        ,pr_fldebcred  IN VARCHAR2        --> Debito
                         /* BODY */
                        ,pr_nrctrlif   IN VARCHAR2        --> Nr. controle da IF
                        ,pr_ispbdebt   IN VARCHAR2        --> Inscricao SPB
                        ,pr_cdbcoctl   IN VARCHAR2        --> Banco da Coop.
                        ,pr_cdagectl   IN VARCHAR2        --> Agencia da Coop.
                        ,pr_dsdctadb   IN VARCHAR2        --> Tp. Conta de Debito
                        ,pr_nrdconta   IN VARCHAR2        --> Nr.da Conta remeternte
                        ,pr_dspesemi   IN VARCHAR2        --> Tp. Pessoa Remetente
                        ,pr_cpfcgemi   IN VARCHAR2        --> CPF Remet
                        ,pr_cpfcgdel   IN VARCHAR2        --> CPF Remetente - Segundo ttl
                        ,pr_nmpesemi   IN VARCHAR2        --> Nome Remetente - Primeiro ttl
                        ,pr_nmpesde1   IN VARCHAR2        --> Nome Remetente - Segundo ttl
                        ,pr_ispbcred   IN VARCHAR2        --> IF de Credito
                        ,pr_cdbccxlt   IN VARCHAR2        --> Cd. Banco Destino
                        ,pr_cdagenbc   IN VARCHAR2        --> Agencia IF de credito
                        ,pr_nrcctrcb   IN VARCHAR2        --> Conta de credito
                        ,pr_dsdctacr   IN VARCHAR2        --> Tp. Conta de Debito
                        ,pr_dspesrec   IN VARCHAR2        --> Tp. Pessoa Destino
                        ,pr_cpfcgrcb   IN VARCHAR2        --> CPF Pessoa Destino
                        ,pr_nmpesrcb   IN VARCHAR2        --> Nome Pessoa Destino
                        ,pr_vldocmto   IN VARCHAR2        --> Valor do Docmto
                        ,pr_cdfinrcb   IN VARCHAR2        --> Finalidade
                        ,pr_dtmvtolt   IN VARCHAR2        --> Data atual
                        ,pr_dtmvtopr   IN VARCHAR2        --> Data proximo dia
                        ,pr_cdidtran   IN VARCHAR2        --> Id transa��o
                        ,pr_dshistor   IN VARCHAR2        --> Historico

                        ,pr_cdagenci   IN INTEGER         --> agencia/pac
                        ,pr_nrdcaixa   IN INTEGER         --> nr. do caixa
                        ,pr_cdoperad   IN VARCHAR2        --> operador
                        ,pr_dtagendt   IN VARCHAR2        --> Data de agendamento
                        ,pr_nrseqarq   IN VARCHAR2        --> Sequencial arq
                        ,pr_cdconven   IN INTEGER         --> convenio
                        ,pr_hrtransa   IN INTEGER         --> Hora transacao

                        --------- SAIDA --------
                        ,pr_cdcritic  OUT INTEGER       --> Codigo do erro
                        ,pr_dscritic  OUT VARCHAR2) IS  --> Descricao do erro

  /*---------------------------------------------------------------------------------------------------------------

      Programa : pc_gera_xml             Antigo: b1wgen0046/gera_xml
      Sistema  : Comunica��o com SPB
      Sigla    : CRED
      Autor    : Odirlei Busana - Amcom
      Data     : Junho/2015.                   Ultima atualizacao: 09/06/2015

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedimento para Gerar arquivo XML para SPB

      Altera��o : 09/06/2015 - Convers�o Progress -> Oracle (Odirlei-Amcom)

                  06/07/2015 - Alterado a procedure gera_xml, movendo a chamada do script
                             mqcecred_envia.pl e do log do arquivo aux_nmarqlog para o
                             final da procedure. Adicionado valida��o de erro na procedure
                             grava-log-ted e tratamento de erro na chamada do gera_xml
                             quando aux_nmmsgenv = "STR0008" (Douglas - Chamado 294944).

  ---------------------------------------------------------------------------------------------------------------*/
    -----------------> CURSORES <--------------------
    ------------> ESTRUTURAS DE REGISTRO <-----------

    -----------------> VARIAVEIS <-------------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

    -- Vari�veis para armazenar as informa��es em XML
    vr_des_xml         CLOB;
    -- Vari�vel para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_dsdircop        VARCHAR2(500);
    vr_nmarquiv        VARCHAR2(500);
    vr_nmarqxml        VARCHAR2(500);
    vr_nmarqlog        VARCHAR2(500);
    vr_nmmsgenv        VARCHAR2(50);
    vr_dsarqenv        VARCHAR2(5000);
    vr_comando         VARCHAR2(4000);
    vr_des_log         VARCHAR2(4000);
    vr_typ_saida       VARCHAR2(3);

    -----------------> SubRotinas <------------------
    -- Subrotina para escrever texto na vari�vel CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      --> String que recebe a mensagem enviada por buffer
      vr_dsarqenv := vr_dsarqenv||pr_des_dados;
    END;
  BEGIN

    /* Arquivo gerado para o envio */
    vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                         pr_cdcooper => pr_cdcooper);
    vr_nmarquiv := 'msgenv_cecred_' || to_char(SYSDATE,'RRRRMMDD')||
                   -- segundos passados da meia noite, e cada segundo fracionados
                   to_char(SYSTIMESTAMP,'SSSSSFF5')|| -- para tentar Simular ETIME
                   '.xml';
    vr_nmarqxml := vr_dsdircop ||'/salvar/'||vr_nmarquiv;
    /* Arquivo de log - tela LOGSPB*/
    vr_nmarqlog := 'mqcecred_envio'||to_char(pr_crapdat.dtmvtocd,'DDMMRR')||'.log';
    vr_nmmsgenv := pr_nmmsgenv;


    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informa��es do XML
    vr_texto_completo := NULL;


    /* HEADER - mensagens STR e PAG */
    pc_escreve_xml('<SISMSG>'||
                      '<SEGCAB>'||
                        '<CD_LEGADO>'   || pr_cdlegago  ||'</CD_LEGADO>'||
                        '<TP_MANUT>'    || pr_tpmanut   ||'</TP_MANUT>'||
                        '<CD_STATUS>'   || pr_cdstatus  ||'</CD_STATUS>'||
                        '<NR_OPERACAO>' || pr_nroperacao||'</NR_OPERACAO>'||
                        '<FL_DEB_CRED>' || pr_fldebcred ||'</FL_DEB_CRED>'||
                      '</SEGCAB>');

    /* BODY  - mensagens STR e PAG
       STR0005 e PAG0107
       Descri�ao: destinado a IF requisitar transferencia de recursos por
                  conta de nao correntistas. */
    IF vr_nmmsgenv IN ('STR0005','PAG0107') THEN
       pc_escreve_xml('<'|| vr_nmmsgenv ||'>
                        <CodMsg>'||        vr_nmmsgenv ||'</CodMsg>
                        <NumCtrlIF>'||     pr_nrctrlif ||'</NumCtrlIF>
                        <ISPBIFDebtd>'||   pr_ispbdebt ||'</ISPBIFDebtd>
                        <AgDebtd>'||       pr_cdagectl ||'</AgDebtd>
                        <TpPessoaRemet>'|| pr_dspesemi ||'</TpPessoaRemet>
                        <CNPJ_CPFRemet>'|| pr_cpfcgemi ||'</CNPJ_CPFRemet>
                        <NomRemet>'||      pr_nmpesemi ||'</NomRemet>
                        <ISPBIFCredtd>'||  pr_ispbcred ||'</ISPBIFCredtd>
                        <AgCredtd>'||      pr_cdagenbc ||'</AgCredtd>
                        <CtCredtd>'||      pr_nrcctrcb ||'</CtCredtd>
                        <TpCtCredtd>'||    pr_dsdctacr ||'</TpCtCredtd>
                        <TpPessoaDestinatario>'|| pr_dspesrec ||'</TpPessoaDestinatario>
                        <CNPJ_CPFDestinatario>'|| pr_cpfcgrcb ||'</CNPJ_CPFDestinatario>
                        <NomDestinatario>'||      pr_nmpesrcb ||'</NomDestinatario>
                        <VlrLanc>'||              pr_vldocmto ||'</VlrLanc>
                        <FinlddCli>'||            pr_cdfinrcb ||'</FinlddCli>
                        <Hist>'||                 pr_dshistor ||'</Hist>
                        <DtMovto>'||              pr_dtmvtolt ||'</DtMovto>
                      </'|| vr_nmmsgenv ||'>
                      </SISMSG>');

    /* Descricao: IF requisita Transferencia de IF para conta de cliente */
    ELSIF vr_nmmsgenv = 'STR0007' THEN
      pc_escreve_xml('<'|| vr_nmmsgenv ||'>
                        <CodMsg>'||      vr_nmmsgenv ||'</CodMsg>
                        <NumCtrlIF>'||   pr_nrctrlif ||'</NumCtrlIF>
                        <ISPBIFDebtd>'|| pr_ispbdebt ||'</ISPBIFDebtd>
                        <ISPBIFCredtd>'||pr_ispbcred ||'</ISPBIFCredtd>
                        <AgCredtd>'||    pr_cdagenbc ||'</AgCredtd>
                        <TpCtCredtd>'||  pr_dsdctacr ||'</TpCtCredtd>
                        <CtCredtd>'||    pr_nrcctrcb ||'</CtCredtd>
                        <TpPessoaCredtd>'||           pr_dspesrec||'</TpPessoaCredtd>
                        <CNPJ_CPFCliCredtdTitlar1>'|| pr_cpfcgrcb ||'</CNPJ_CPFCliCredtdTitlar1>
                        <NomCliCredtdTitlar1>'||      pr_nmpesrcb ||'</NomCliCredtdTitlar1>
                        <CNPJ_CPFCliCredtdTitlar2></CNPJ_CPFCliCredtdTitlar2>
                        <NomCliCredtdTitlar2></NomCliCredtdTitlar2>
                        <NumContrtoOpCred></NumContrtoOpCred>
                        <VlrLanc>'||         pr_vldocmto ||'</VlrLanc>
                        <FinlddIF>'||        pr_cdfinrcb ||'</FinlddIF>
                        <CodIdentdTransf>'|| pr_cdidtran ||'</CodIdentdTransf>
                        <Hist></Hist>
                        <DtAgendt>'||        pr_dtagendt ||'</DtAgendt>
                        <HrAgendt></HrAgendt>
                        <NivelPref></NivelPref>
                        <DtMovto>'||         pr_dtmvtopr ||'</DtMovto>
                      </'|| vr_nmmsgenv ||'>
                      </SISMSG>');

    /* STR0008 ,  PAG0108 , STR 0009 e PAG 0109
       - Descri�ao: destinado a IF requisitar transferencia de recursos
                    entre pessoas f�sicas ou jur�dicas em IFs distintas. */
    ELSIF  vr_nmmsgenv IN ('STR0008','PAG0108','STR0009','PAG0109')  THEN
      /* Enquanto nao for alterada tela da rotina 20 Cx.Online */
      IF pr_nmmsgenv = 'STR0009' THEN
        vr_nmmsgenv := 'STR0008';
      ELSIF pr_nmmsgenv = 'PAG0109' THEN
        vr_nmmsgenv := 'PAG0108';
      END IF;

      pc_escreve_xml(' <'|| vr_nmmsgenv ||'>'||
                       '<CodMsg>'||             vr_nmmsgenv ||'</CodMsg>'||
                         '<NumCtrlIF>'||        pr_nrctrlif ||'</NumCtrlIF>'||
                         '<ISPBIFDebtd>'||      pr_ispbdebt||'</ISPBIFDebtd>'||
                         '<AgDebtd>'||          pr_cdagectl ||'</AgDebtd>'||
                         '<TpCtDebtd>'||        pr_dsdctadb ||'</TpCtDebtd>'||
                         '<CtDebtd>'||          pr_nrdconta ||'</CtDebtd>'||
                         '<TpPessoaDebtd>'||    pr_dspesemi ||'</TpPessoaDebtd>'||
                         '<CNPJ_CPFCliDebtd>'|| pr_cpfcgemi ||'</CNPJ_CPFCliDebtd>'||
                         '<NomCliDebtd>'||      pr_nmpesemi ||'</NomCliDebtd>'||
                         '<ISPBIFCredtd>'||     pr_ispbcred ||'</ISPBIFCredtd>'||
                         '<AgCredtd>'||         pr_cdagenbc ||'</AgCredtd>'||
                         '<TpCtCredtd>'||       pr_dsdctacr ||'</TpCtCredtd>'||
                         '<CtCredtd>'||         pr_nrcctrcb ||'</CtCredtd>'||
                         '<TpPessoaCredtd>'||   pr_dspesrec ||'</TpPessoaCredtd>'||
                         '<CNPJ_CPFCliCredtd>'||pr_cpfcgrcb ||'</CNPJ_CPFCliCredtd>'||
                         '<NomCliCredtd>'||     pr_nmpesrcb ||'</NomCliCredtd>'||
                         '<VlrLanc>'||          pr_vldocmto ||'</VlrLanc>'||
                         '<FinlddCli>'||        pr_cdfinrcb ||'</FinlddCli>'||
                         '<CodIdentdTransf>'||  pr_cdidtran ||'</CodIdentdTransf>'||
                         '<Hist>'||             pr_dshistor ||'</Hist>'||
                         '<DtMovto>'||          pr_dtmvtolt ||'</DtMovto>'||
                       '</'|| vr_nmmsgenv ||'>'||
                     '</SISMSG>');

    /* Descricao: IF requisita Transferencia para repasse de tributos estaduais*/
    ELSIF vr_nmmsgenv = 'STR0020' THEN
      pc_escreve_xml('<'|| vr_nmmsgenv ||'>
                        <CodMsg>'||      vr_nmmsgenv ||'</CodMsg>
                        <NumCtrlIF>'||   pr_nrctrlif ||'</NumCtrlIF>
                        <ISPBIFDebtd>'|| pr_ispbdebt ||'</ISPBIFDebtd>
                        <ISPBIFCredtd>'||pr_ispbcred ||'</ISPBIFCredtd>
                        <AgCredtd>'||    pr_cdagenbc ||'</AgCredtd>
                        <CtCredtd>'||    pr_nrcctrcb||'</CtCredtd>
                        <CodSEFAZ>24</CodSEFAZ>
                        <TpReceita>9</TpReceita>
                        <TpRecolht>N</TpRecolht>
                        <DtArrec>'||     pr_dtmvtolt ||'</DtArrec>
                        <VlrLanc>'||     pr_vldocmto ||'</VlrLanc>
                        <NivelPref></NivelPref>
                        <Grupo_STR0020_VlrInf>
                          <TpVlrInf>25</TpVlrInf>
                          <VlrInf>'|| pr_vldocmto ||'</VlrInf>
                        </Grupo_STR0020_VlrInf>
                        <Hist>'||     pr_nrseqarq ||'</Hist>
                        <DtAgendt>'|| pr_dtagendt ||'</DtAgendt>
                        <HrAgendt></HrAgendt>
                        <DtMovto>'||  pr_dtmvtopr ||'</DtMovto>
                        </'||vr_nmmsgenv ||'>
                        </SISMSG>');

    /* STR0037 e PAG0137
    Descri�ao: destinado a IF requisitar transferencia de recursos
               com d�bito em conta-sal�rio. (TEC) */
    ELSIF vr_nmmsgenv IN ('STR0037', 'PAG0137') THEN
      pc_escreve_xml('<'|| vr_nmmsgenv ||'>
                        <CodMsg>'||      vr_nmmsgenv ||'</CodMsg>
                        <NumCtrlIF>'||   pr_nrctrlif ||'</NumCtrlIF>
                        <ISPBIFDebtd>'|| pr_ispbdebt ||'</ISPBIFDebtd>
                        <AgDebtd>'||     pr_cdagectl ||'</AgDebtd>
                        <CtDebtd>'||     pr_nrdconta ||'</CtDebtd>
                        <CPFCliDebtd>'|| pr_cpfcgemi ||'</CPFCliDebtd>
                        <NomCliDebtd>'|| pr_nmpesemi ||'</NomCliDebtd>
                        <ISPBIFCredtd>'||pr_ispbcred ||'</ISPBIFCredtd>
                        <AgCredtd>'||    pr_cdagenbc ||'</AgCredtd>
                        <TpCtCredtd>'||  pr_dsdctacr ||'</TpCtCredtd>
                        <CtCredtd>'||    pr_nrcctrcb ||'</CtCredtd>
                        <VlrLanc>'||     pr_vldocmto ||'</VlrLanc>
                        <DtMovto>'||     pr_dtmvtolt ||'</DtMovto>
                      </'||vr_nmmsgenv ||'>
                      </SISMSG>');
    END IF;

    -- descarregar buffer
    pc_escreve_xml(' ',TRUE);
    gene0002.pc_XML_para_arquivo(pr_XML     => vr_des_xml,
                                 pr_caminho => vr_dsdircop||'/salvar/',
                                 pr_arquivo => vr_nmarquiv,
                                 pr_des_erro=> vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    /* Cria registro de Debito */
    BEGIN
      INSERT INTO gnmvcen
        (gnmvcen.cdagectl
        ,gnmvcen.dtmvtolt
        ,gnmvcen.dsmensag
        ,gnmvcen.dsdebcre
        ,gnmvcen.vllanmto)
      VALUES
        (nvl(rw_crapcop.cdagectl,0)
        ,pr_crapdat.dtmvtocd
        ,vr_nmmsgenv
        ,'D' /*Debito em Conta*/
        ,TO_NUMBER(nvl(replace(trim(pr_vldocmto),'.',','),0)));
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao inserir na tabela gnmvcen. '||SQLERRM;
        --Levantar Excecao
        RAISE vr_exc_erro;
    END;

    -- gravar log craplmt
    pc_grava_log_ted ( pr_cdcooper => pr_cdcooper    --> Codigo cooperativo
                      ,pr_dttransa => trunc(SYSDATE) --> Data transa��o
                      ,pr_hrtransa => pr_hrtransa    --> Hora Transa��o
                      ,pr_idorigem => pr_cdorigem    --> Id de origem
                      ,pr_cdprogra => 'B1WGEN0046'   --> Codigo do programa
                      ,pr_idsitmsg => 1              --> Situa��o da mensagem.
                      ,pr_nmarqmsg => vr_nmarquiv   --> Nome do arquivo da mensagem.
                      ,pr_nmevento => pr_nmmsgenv   --> Descricao do evento da mensagem.
                      ,pr_nrctrlif => pr_nrctrlif   --> Numero de controle da mensagem.
                      ,pr_vldocmto => to_number(REPLACE(pr_vldocmto,'.',','))   --> Valor do documento.
                      ,pr_cdbanctl => pr_cdbcoctl   --> Codigo de banco da central.
                      ,pr_cdagectl => pr_cdagectl   --> Codigo de agencia na central.
                      ,pr_nrdconta => pr_nrdconta   --> Numero da conta cooperado
                      ,pr_nmcopcta => pr_nmpesemi   --> Nome do cooperado.
                      ,pr_nrcpfcop => pr_cpfcgemi   --> Cpf/cnpj do cooperado.
                      ,pr_cdbandif => pr_cdbccxlt   --> Codigo do banco da if.
                      ,pr_cdagedif => pr_cdagenbc   --> Codigo da agencia na if.
                      ,pr_nrctadif => pr_nrcctrcb   --> Numero da conta na if.
                      ,pr_nmtitdif => pr_nmpesrcb   --> Nome do titular da conta na if.
                      ,pr_nrcpfdif => pr_cpfcgrcb   --> Cpf/cnpj do titular da conta na if.
                      ,pr_cdidenti => pr_cdidtran   --> Codigo identificador da transacao.
                      ,pr_dsmotivo => NULL          --> Descricao do motivo de erro na mensagem.
                      ,pr_cdagenci => pr_cdagenci   --> Numero do pa.
                      ,pr_nrdcaixa => pr_nrdcaixa   --> Numero do caixa.
                      ,pr_cdoperad => pr_cdoperad   --> Codigo do operador.
                      ,pr_nrispbif => pr_ispbcred   --> Numero de inscri��o SPB

                      --------- SAIDA --------
                      ,pr_cdcritic => vr_cdcritic   --> Codigo do erro
                      ,pr_dscritic => vr_dscritic); --> Descricao do erro
    /* vers�o progress nao trata saida de erro
    IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL
      raise vr_exc_erro;
    END IF;*/

    -- Montar comando
    -- /usr/local/bin/exec_comando_oracle.sh mqcecred_envia (conforme solicitacao Tiago Wagner)
    vr_comando:= '/usr/local/bin/exec_comando_oracle.sh mqcecred_envia ' || Chr(39) || vr_dsarqenv || Chr(39) || ' '
                                                                         || Chr(39) || pr_cdcooper || Chr(39) || ' '
                                                                         || Chr(39) || vr_nmarqxml || Chr(39);
    --Executar Comando Unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Nao foi possivel executar comando unix. Erro '|| vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    -- Uma vez executado o script n�o pode mais abortar o envio
    -- por isso realizado o commit;
    COMMIT;

    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

    /* Logar envio
    *****************************************************************
    * Cuidar ao alterar o log pois os espacamentos e formats estao  *
    * ajustados para que a tela LogSPB pegue os dados com SUBSTRING *
    *****************************************************************/
    vr_des_log :=  Chr(34) || To_Char(SYSDATE,'DD/MM/YYYY')|| ' - '||
                   to_char(SYSDATE,'HH24:MI:SS')|| ' - '|| 'b1wgen0046'||
                   ' - ENVIADA OK         --> '||
                   'Arquivo '          || SUBSTR(vr_nmarquiv,1,40)||
                   '. Evento: '        || SUBSTR(vr_nmmsgenv,1,9)||
                   ', Numero Controle: '||SUBSTR(pr_nrctrlif,1,20)||
                   ', Hora: '          || TO_CHAR(SYSDATE,'HH24:MI:SS')||
                   ', Valor: '         || To_Char(TO_NUMBER(REPLACE(pr_vldocmto,'.',',')),'fm999g999g990d00')||
                   ', Banco Remet.: '  || gene0002.fn_mask(pr_cdbcoctl, 'zz9') ||
                   ', Agencia Remet.: '|| gene0002.fn_mask(pr_cdagectl,'zzzz9')||
                   ', Conta Remet.: '  || gene0002.fn_mask(pr_nrdconta, 'zzzzzzzz9')||
                   ', Nome Remet.: '   || RPAD(pr_nmpesemi,40,' ') ||
                   ', CPF/CNPJ Remet.: '||gene0002.fn_mask(pr_cpfcgemi,'zzzzzzzzzzzzz9') ||
                   ', Banco Dest.: '   || gene0002.fn_mask(pr_cdbccxlt,'zz9') ||
                   ', Agencia Dest.: ' || gene0002.fn_mask(pr_cdagenbc,'zzzz9') ||
                   ', Conta Dest.: '   || RPAD(pr_nrcctrcb,14,' ') ||
                   ', Nome Dest.: '    || RPAD(pr_nmpesrcb,40,' ') ||
                   ', CPF/CNPJ Dest.: '|| gene0002.fn_mask(pr_cpfcgrcb,'zzzzzzzzzzzzz9') ||
                   ', Cod. Ident. Tansf.: '|| RPAD(pr_cdidtran,25,' ');

    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 1, -- Normal
                               pr_des_log      => vr_des_log,
                               pr_nmarqlog     => vr_nmarqlog);

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel gerar xml para o SPB: '||SQLERRM;
  END pc_gera_xml;


  /******************************************************************************/
  /**                         Envia TED/TEC  - SPB                             **/
  /******************************************************************************/
  PROCEDURE pc_proc_envia_tec_ted
                          (pr_cdcooper IN INTEGER   --> Cooperativa
                          ,pr_cdagenci IN INTEGER   --> Cod. Agencia
                          ,pr_nrdcaixa IN INTEGER   --> Numero  Caixa
                          ,pr_cdoperad IN VARCHAR2  --> Operador
                          ,pr_titulari IN BOOLEAN   --> Mesmo Titular.
                          ,pr_vldocmto IN NUMBER    --> Vlr. DOCMTO
                          ,pr_nrctrlif IN VARCHAR2  --> NumCtrlIF
                          ,pr_nrdconta IN INTEGER   --> Nro Conta
                          ,pr_cdbccxlt IN INTEGER   --> Codigo Banco
                          ,pr_cdagenbc IN INTEGER   --> Cod Agencia
                          ,pr_nrcctrcb IN NUMBER    --> Nr.Ct.destino
                          ,pr_cdfinrcb IN INTEGER   --> Finalidade
                          ,pr_tpdctadb IN INTEGER   --> Tp. conta deb
                          ,pr_tpdctacr IN INTEGER   --> Tp conta cred
                          ,pr_nmpesemi IN VARCHAR2  --> Nome Do titular
                          ,pr_nmpesde1 IN VARCHAR2  --> Nome De 2TTT
                          ,pr_cpfcgemi IN NUMBER    --> CPF/CNPJ Do titular
                          ,pr_cpfcgdel IN NUMBER    --> CPF sec TTL
                          ,pr_nmpesrcb IN VARCHAR2  --> Nome Para
                          ,pr_nmstlrcb IN VARCHAR2  --> Nome Para 2TTL
                          ,pr_cpfcgrcb IN NUMBER    --> CPF/CNPJ Para
                          ,pr_cpstlrcb IN NUMBER    --> CPF Para 2TTL
                          ,pr_tppesemi IN INTEGER   --> Tp. pessoa De
                          ,pr_tppesrec IN INTEGER   --> Tp. pessoa Para
                          ,pr_flgctsal IN BOOLEAN   --> CC Sal
                          ,pr_cdidtran IN VARCHAR2  --> tipo de transferencia
                          ,pr_cdorigem IN INTEGER   --> Cod. Origem
                          ,pr_dtagendt IN DATE      --> data egendamento
                          ,pr_nrseqarq IN INTEGER   --> nr. seq arq.
                          ,pr_cdconven IN INTEGER   --> Cod. Convenio
                          ,pr_dshistor IN VARCHAR2  --> Dsc do Hist.
                          ,pr_hrtransa IN INTEGER   --> Hora transacao
                          ,pr_cdispbif IN INTEGER   --> ISPB Banco
                          --------- SAIDA --------
                          ,pr_cdcritic OUT INTEGER      --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2) IS --> Descricao do erro

  /*---------------------------------------------------------------------------------------------------------------

      Programa : proc_envia_tec_ted             Antigo: b1wgen0046/proc_envia_tec_ted
      Sistema  : Comunica��o com SPB
      Sigla    : CRED
      Autor    : Odirlei Busana - Amcom
      Data     : Junho/2015.                   Ultima atualizacao: 19/09/2016

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure para enviar TED/TEC  - SPB

      Altera��o : 09/06/2015 - Convers�o Progress -> Oracle (Odirlei-Amcom)
      
                  19/09/2016 - Removida a validacao de horario cadastrado na TAB085
                               para a geracao de TED dos convenios. SD 519980.
                               (Carlos Rafael Tanholi)      
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
             crapass.cdagenci
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    rw_crabass cr_crapass%ROWTYPE;

    --Selecionar informacoes dos bancos
    CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
      SELECT crapban.nmresbcc
            ,crapban.nmextbcc
            ,crapban.cdbccxlt
            ,crapban.nrispbif
            ,crapban.flgdispb
            ,crapban.flgoppag
        FROM crapban
       WHERE crapban.cdbccxlt = pr_cdbccxlt;

    --Selecionar informacoes dos bancos
    CURSOR cr_crapban_spb (pr_cdispbif IN crapban.nrispbif%TYPE) IS
      SELECT crapban.nmresbcc
            ,crapban.nmextbcc
            ,crapban.cdbccxlt
            ,crapban.nrispbif
            ,crapban.flgdispb
            ,crapban.flgoppag
        FROM crapban
       WHERE crapban.nrispbif = pr_cdispbif;

    rw_crapban cr_crapban%ROWTYPE;

    -- Verificar cadasto de senhas
    CURSOR cr_crapsnh (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_idseqttl crapttl.idseqttl%TYPE) IS
      SELECT crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.nrcpfcgc
            ,crapsnh.vllimweb
            ,crapsnh.vllimtrf
            ,crapsnh.vllimted
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.idseqttl = pr_idseqttl
         AND crapsnh.tpdsenha = 1;
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

    -- Buscar dados agencia favorecido
    CURSOR cr_crapagb (pr_cddbanco crapagb.cddbanco%TYPE,
                       pr_cdageban crapagb.cdageban%TYPE) IS
      SELECT crapagb.nmageban
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
         AND crappro.dsprotoc = pr_dsprotoc;
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
    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_tab_erro GENE0001.typ_tab_erro;
    vr_des_erro VARCHAR2(50);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    vr_dstextab craptab.dstextab%TYPE;
    vr_ispbdebt NUMBER;
    vr_fcrapban BOOLEAN := FALSE;
    vr_ispbcred VARCHAR2(50);
    vr_flgbcpag crapban.flgoppag%TYPE;
    vr_flgutstr BOOLEAN;
    vr_flgutpag BOOLEAN;
    vr_dspesemi VARCHAR2(100);
    vr_dspesrec VARCHAR2(100);
    vr_dsdctadb VARCHAR2(100);
    vr_dsdctacr VARCHAR2(100);
    vr_dtmvtolt VARCHAR2(100);
    vr_vldocmto VARCHAR2(100);
    vr_nrcpfemi VARCHAR2(100);
    vr_cpfcgrcb VARCHAR2(100);
    vr_cpfcgde1 VARCHAR2(100);
    vr_dtagendt VARCHAR2(100);
    vr_dtmvtopr VARCHAR2(100);
    vr_nrseqarq VARCHAR2(100);
    vr_cdlegado VARCHAR2(100);
    vr_tpmanut  VARCHAR2(100);
    vr_cdstatus VARCHAR2(100);
    vr_nroperacao  VARCHAR2(100);
    vr_fldebcred    VARCHAR2(10);
    vr_nmpesde1   VARCHAR2(100);
    vr_nmmsgenv   VARCHAR2(100);


  BEGIN

    /* Busca dados da cooperativa */
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 651;
      vr_dscritic:= NULL;
      --Gerar erro
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    /* Busca data do sistema */
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se n�o encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_dscritic := NULL;
      --Gerar erro
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    /* ISPB Debt. eh os 8 primeiros digitos do CNPJ da Coop */
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'GENERI'
                                            ,pr_cdempres => 0
                                            ,pr_cdacesso => 'CNPJCENTRL'
                                            ,pr_tpregist => 0);
    --Se nao encontrou
    IF vr_dstextab IS NULL THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 0;
      vr_dscritic:= 'CNPJ da Central nao encontrado.';
      --Gerar erro
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      -- Cnpj da central
      vr_ispbdebt:= TO_NUMBER(vr_dstextab);
    END IF;

    /* ISPB Credt eh os 8 primeiros digitos do CNPJ do Banco de Destino */
    IF nvl(pr_cdbccxlt,0) > 0 THEN
      OPEN cr_crapban (pr_cdbccxlt => pr_cdbccxlt);
      FETCH cr_crapban INTO rw_crapban;
      vr_fcrapban := cr_crapban%FOUND;
    ELSE
      -- buscar pelo cod spb
      OPEN cr_crapban_spb (pr_cdispbif => pr_cdispbif);
      FETCH cr_crapban_spb INTO rw_crapban;
      vr_fcrapban := cr_crapban_spb%FOUND;
    END IF;

    --Se nao encontrar
    IF vr_fcrapban = FALSE THEN

      --Mensagem erro
      vr_cdcritic:= 57;
      vr_dscritic:= NULL;
      --Gerar erro
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      vr_ispbcred := to_char(rw_crapban.nrispbif,'fm00000000');
      vr_flgbcpag := rw_crapban.flgoppag;
    END IF;

    -- Verificar se banco esta operando pelo SPB
    IF rw_crapban.flgdispb <> 1 THEN
      --Mensagem erro
      vr_cdcritic:= 0;
      vr_dscritic:= 'Banco nao operante no SPB.';
      --Gerar erro
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    -- Operando com mensagens STR
    /*IF rw_crapcop.flgopstr = 1  THEN
      IF rw_crapcop.iniopstr <= gene0002.fn_busca_time AND
         rw_crapcop.fimopstr >= gene0002.fn_busca_time THEN
        vr_flgutstr := TRUE;
      END IF;
    END IF;*/

    -- Operando com mensagens PAG
    IF rw_crapcop.flgoppag = 1  THEN
      IF rw_crapcop.inioppag <= gene0002.fn_busca_time AND
         rw_crapcop.fimoppag >= gene0002.fn_busca_time THEN
        vr_flgutpag := TRUE;
      END IF;
    END IF;

    IF vr_flgutpag = FALSE THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Hor�rio de envio dos TEDs encerrado.';
      --Gerar erro
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    --> Alimenta variaveis default

    -- Tp. pessoa - Remetente
    IF pr_tppesemi = 1   THEN
      vr_dspesemi := 'F';
      -- CPF Remetente - Primeiro titular
      vr_nrcpfemi := to_char(pr_cpfcgemi,'fm00000000000');
      -- CPF Remetente - Segundo titular
      vr_cpfcgde1 := to_char(pr_cpfcgdel,'fm00000000000');
    ELSE
      vr_dspesemi := 'J';
      -- CNPJ Remetente - Primeiro titular
      vr_nrcpfemi := to_char(pr_cpfcgemi,'fm00000000000000');
      -- CNPJ Remetente - Segundo titular
      vr_cpfcgde1 := to_char(pr_cpfcgdel,'fm00000000000000');
    END IF;

    -- Tp. pessoa - Destinatario
    IF pr_tppesrec = 1 THEN
      vr_dspesrec := 'F';
      -- CPF Destinatario
      vr_cpfcgrcb := to_char(pr_cpfcgrcb,'fm00000000000');
    ELSE
      vr_dspesrec := 'J';
      -- CNPJ Destinatario
      vr_cpfcgrcb := to_char(pr_cpfcgrcb,'fm00000000000000');
    END IF;

    -- Tp. conta - Remetente
    IF pr_tpdctadb = 2   THEN
      vr_dsdctadb := 'PP';
    ELSE
      vr_dsdctadb := 'CC';
    END IF;

    -- Tp. conta - Destinatario
    IF pr_tpdctacr = 2   THEN
      vr_dsdctacr := 'PP';
    ELSE
      vr_dsdctacr := 'CC';
    END IF;

    -- Format da data deve ser AAAA-MM-DD
    vr_dtmvtolt := to_char(rw_crapdat.dtmvtocd,'RRRR-MM-DD');

    -- Format da data deve ser AAAA-MM-DD
    vr_dtmvtopr := to_char(rw_crapdat.dtmvtopr,'RRRR-MM-DD');

    -- Separador decimal de centavos deve ser "."
    vr_vldocmto := REPLACE(to_char(pr_vldocmto),',','.');

    -- Alimenta as variaveis do HEADER
    vr_cdlegado := to_char(rw_crapcop.cdagectl);
    vr_tpmanut  := 'I';   -- Inclusao
    vr_cdstatus := 'D';   -- Mensagem do tipo definitiva - real
    vr_nroperacao := pr_nrctrlif;
    vr_fldebcred  := 'D'; -- Debito
    vr_nmpesde1   := pr_nmpesde1;

    IF nvl(pr_nrdconta,0) <> 0 THEN
      IF upper(vr_nmpesde1) LIKE 'E/OU%' THEN
        vr_nmpesde1 := SUBSTR(vr_nmpesde1,6);
      END IF;
    END IF;

    /*** MONTA O BODY ***/
    IF pr_flgctsal THEN
      -- Enviar com STR0037 ou PAG0137

      -- Se PAG Disponivel e se o Banco de destino estiver operando  com PAG
      IF vr_flgutpag AND vr_flgbcpag = 1 THEN
        vr_nmmsgenv := 'PAG0137';
      ELSE
        /* Se STR Disponivel */
        vr_nmmsgenv := 'STR0037';
      END IF;

      pc_gera_xml (pr_cdcooper => pr_cdcooper          --> Codigo da cooperativa
                  ,pr_cdorigem => pr_cdorigem          --> Id de origem
                  ,pr_crapdat  => rw_crapdat           --> rowtype da crapdat
                   /* HEADER */
                  ,pr_nmmsgenv   => vr_nmmsgenv        --> Cod. da Mensagem
                  ,pr_cdlegago   => vr_cdlegado        --> Cod. Legado
                  ,pr_tpmanut    => vr_tpmanut         --> Inclusao
                  ,pr_cdstatus   => vr_cdstatus        --> Mensagem do tipo definitiva
                  ,pr_nroperacao => vr_nroperacao      --> Numero de operacao
                  ,pr_fldebcred  => vr_fldebcred       --> Debito
                   /* BODY */
                  ,pr_nrctrlif => pr_nrctrlif          --> Nr. controle da IF
                  ,pr_ispbdebt => SUBSTR(to_char(vr_ispbdebt,'fm00000000000000'),1,8) --> Inscricao SPB
                  ,pr_cdbcoctl => rw_crapcop.cdbcoctl  --> Banco da Coop.
                  ,pr_cdagectl => rw_crapcop.cdagectl  --> Agencia da Coop.
                  ,pr_dsdctadb => NULL                 --> Tp. Conta de Debito
                  ,pr_nrdconta => pr_nrdconta          --> Nr.da Conta remeternte
                  ,pr_dspesemi => NULL                 --> Tp. Pessoa Remetente
                  ,pr_cpfcgemi => to_char(pr_cpfcgemi,'fm00000000000')--> CPF Remet
                  ,pr_cpfcgdel => NULL                 --> CPF Remetente - Segundo ttl
                  ,pr_nmpesemi => pr_nmpesemi          --> Nome Remetente - Primeiro ttl
                  ,pr_nmpesde1 => NULL                 --> Nome Remetente - Segundo ttl
                  ,pr_ispbcred => vr_ispbcred          --> IF de Credito
                  ,pr_cdbccxlt => pr_cdbccxlt          --> Cd. Banco Destino
                  ,pr_cdagenbc => pr_cdagenbc          --> Agencia IF de credito
                  ,pr_nrcctrcb => pr_nrcctrcb          --> Conta de credito
                  ,pr_dsdctacr => vr_dsdctacr          --> Tp. Conta de Debito
                  ,pr_dspesrec => NULL                 --> Tp. Pessoa Destino
                  ,pr_cpfcgrcb => NULL                 --> CPF Pessoa Destino
                  ,pr_nmpesrcb => NULL                 --> Nome Pessoa Destino
                  ,pr_vldocmto => vr_vldocmto          --> Valor do Docmto
                  ,pr_cdfinrcb => NULL                 --> Finalidade
                  ,pr_dtmvtolt => vr_dtmvtolt          --> Data atual
                  ,pr_dtmvtopr => vr_dtmvtopr          --> Data proximo dia
                  ,pr_cdidtran => pr_cdidtran          --> Id transa��o
                  ,pr_dshistor => NULL                 --> Historico

                  ,pr_cdagenci => pr_cdagenci          --> agencia/pac
                  ,pr_nrdcaixa => pr_nrdcaixa          --> nr. do caixa
                  ,pr_cdoperad => pr_cdoperad          --> operador
                  ,pr_dtagendt => NULL                 --> Data de agendamento
                  ,pr_nrseqarq => 0                    --> Sequencial arq
                  ,pr_cdconven => 0                    --> convenio
                  ,pr_hrtransa => pr_hrtransa          --> Hora transacao
                  --------- SAIDA ---------
                  ,pr_cdcritic => vr_cdcritic
                  ,pr_dscritic => vr_dscritic );


    ELSIF nvl(pr_nrdconta,0) = 0 THEN
      /* Enviar com STR0005 ou PAG0107 */

      /* Se PAG Disponivel e se o Banco de destino estiver operando
         com PAG */
      IF vr_flgutpag AND vr_flgbcpag = 1 THEN
        vr_nmmsgenv := 'PAG0107';
      ELSE /* Se STR Disponivel */
        vr_nmmsgenv := 'STR0005';
      END IF;

      pc_gera_xml (pr_cdcooper   => pr_cdcooper        --> Codigo da cooperativa
                  ,pr_cdorigem   => pr_cdorigem        --> Id de origem
                  ,pr_crapdat    => rw_crapdat         --> rowtype da crapdat
                   /* HEADER */
                  ,pr_nmmsgenv   => vr_nmmsgenv        --> Cod. da Mensagem
                  ,pr_cdlegago   => vr_cdlegado        --> Cod. Legado
                  ,pr_tpmanut    => vr_tpmanut         --> Inclusao
                  ,pr_cdstatus   => vr_cdstatus        --> Mensagem do tipo definitiva
                  ,pr_nroperacao => vr_nroperacao      --> Numero de operacao
                  ,pr_fldebcred  => vr_fldebcred       --> Debito
                   /* BODY */
                  ,pr_nrctrlif   => pr_nrctrlif        --> Nr. controle da IF
                  ,pr_ispbdebt   => SUBSTR(to_char(vr_ispbdebt,'fm00000000000000'),1,8) --> Inscricao SPB
                  ,pr_cdbcoctl   => rw_crapcop.cdbcoctl--> Banco da Coop.
                  ,pr_cdagectl   => rw_crapcop.cdagectl--> Agencia da Coop.
                  ,pr_dsdctadb   => vr_dsdctadb        --> Tp. Conta de Debito
                  ,pr_nrdconta   => NULL               --> Nr.da Conta remeternte
                  ,pr_dspesemi   => vr_dspesemi        --> Tp. Pessoa Remetente
                  ,pr_cpfcgemi   => vr_nrcpfemi        --> CPF Remet
                  ,pr_cpfcgdel   => NULL               --> CPF Remetente - Segundo ttl
                  ,pr_nmpesemi   => pr_nmpesemi        --> Nome Remetente - Primeiro ttl
                  ,pr_nmpesde1   => NULL               --> Nome Remetente - Segundo ttl
                  ,pr_ispbcred   => vr_ispbcred        --> IF de Credito
                  ,pr_cdbccxlt   => pr_cdbccxlt        --> Cd. Banco Destino
                  ,pr_cdagenbc   => pr_cdagenbc        --> Agencia IF de credito
                  ,pr_nrcctrcb   => pr_nrcctrcb        --> Conta de credito
                  ,pr_dsdctacr   => vr_dsdctacr        --> Tp. Conta de Debito
                  ,pr_dspesrec   => vr_dspesrec        --> Tp. Pessoa Destino
                  ,pr_cpfcgrcb   => vr_cpfcgrcb        --> CPF Pessoa Destino
                  ,pr_nmpesrcb   => pr_nmpesrcb        --> Nome Pessoa Destino
                  ,pr_vldocmto   => vr_vldocmto        --> Valor do Docmto
                  ,pr_cdfinrcb   => pr_cdfinrcb        --> Finalidade
                  ,pr_dtmvtolt   => vr_dtmvtolt        --> Data atual
                  ,pr_dtmvtopr   => vr_dtmvtopr        --> Data proximo dia
                  ,pr_cdidtran   => pr_cdidtran        --> Id transa��o
                  ,pr_dshistor   => pr_dshistor        --> Historico

                  ,pr_cdagenci   => pr_cdagenci        --> agencia/pac
                  ,pr_nrdcaixa   => pr_nrdcaixa        --> nr. do caixa
                  ,pr_cdoperad   => pr_cdoperad        --> operador
                  ,pr_dtagendt   => NULL               --> Data de agendamento
                  ,pr_nrseqarq   => 0                  --> Sequencial arq
                  ,pr_cdconven   => 0                  --> convenio
                  ,pr_hrtransa   => pr_hrtransa        --> Hora transacao
                  --------- SAIDA ---------
                  ,pr_cdcritic => vr_cdcritic
                  ,pr_dscritic => vr_dscritic );


    ELSIF pr_cdconven <> 0 THEN
      IF pr_cdconven IN (59,60) THEN /* DARE ou GNRE */
        vr_nmmsgenv := 'STR0020';
        vr_nrseqarq := to_char(pr_nrseqarq,'fm000000')||
                       to_char(pr_cdconven,'fm99');
      ELSE
        vr_nmmsgenv := 'STR0007';
        vr_nrseqarq := pr_nrseqarq;
      END IF;

      /* Format da data deve ser AAAA-MM-DD */
      vr_dtmvtolt := to_char(rw_crapdat.dtmvtolt,'RRRR-MM-DD');
      vr_dtagendt := to_char(pr_dtagendt,'RRRR-MM-DD');

      pc_gera_xml (pr_cdcooper   => pr_cdcooper        --> Codigo da cooperativa
                  ,pr_cdorigem   => pr_cdorigem        --> Id de origem
                  ,pr_crapdat    => rw_crapdat         --> rowtype da crapdat
                   /* HEADER */
                  ,pr_nmmsgenv   => vr_nmmsgenv        --> Cod. da Mensagem
                  ,pr_cdlegago   => vr_cdlegado        --> Cod. Legado
                  ,pr_tpmanut    => vr_tpmanut         --> Inclusao
                  ,pr_cdstatus   => vr_cdstatus        --> Mensagem do tipo definitiva
                  ,pr_nroperacao => vr_nroperacao      --> Numero de operacao
                  ,pr_fldebcred  => vr_fldebcred       --> Debito
                   /* BODY */
                  ,pr_nrctrlif   => pr_nrctrlif        --> Nr. controle da IF
                  ,pr_ispbdebt   => SUBSTR(to_char(vr_ispbdebt,'fm00000000000000'),1,8) --> Inscricao SPB
                  ,pr_cdbcoctl   => rw_crapcop.cdbcoctl--> Banco da Coop.
                  ,pr_cdagectl   => rw_crapcop.cdagectl--> Agencia da Coop.
                  ,pr_dsdctadb   => vr_dsdctadb        --> Tp. Conta de Debito
                  ,pr_nrdconta   => pr_nrdconta        --> Nr.da Conta remeternte
                  ,pr_dspesemi   => vr_dspesemi        --> Tp. Pessoa Remetente
                  ,pr_cpfcgemi   => vr_nrcpfemi        --> CPF Remet
                  ,pr_cpfcgdel   => NULL               --> CPF Remetente - Segundo ttl
                  ,pr_nmpesemi   => pr_nmpesemi        --> Nome Remetente - Primeiro ttl
                  ,pr_nmpesde1   => NULL               --> Nome Remetente - Segundo ttl
                  ,pr_ispbcred   => vr_ispbcred        --> IF de Credito
                  ,pr_cdbccxlt   => pr_cdbccxlt        --> Cd. Banco Destino
                  ,pr_cdagenbc   => pr_cdagenbc        --> Agencia IF de credito
                  ,pr_nrcctrcb   => pr_nrcctrcb        --> Conta de credito
                  ,pr_dsdctacr   => vr_dsdctacr        --> Tp. Conta de Debito
                  ,pr_dspesrec   => vr_dspesrec        --> Tp. Pessoa Destino
                  ,pr_cpfcgrcb   => vr_cpfcgrcb        --> CPF Pessoa Destino
                  ,pr_nmpesrcb   => pr_nmpesrcb        --> Nome Pessoa Destino
                  ,pr_vldocmto   => vr_vldocmto        --> Valor do Docmto
                  ,pr_cdfinrcb   => pr_cdfinrcb        --> Finalidade
                  ,pr_dtmvtolt   => vr_dtmvtolt        --> Data atual
                  ,pr_dtmvtopr   => vr_dtmvtopr        --> Data proximo dia
                  ,pr_cdidtran   => pr_cdidtran        --> Id transa��o
                  ,pr_dshistor   => pr_dshistor        --> Historico

                  ,pr_cdagenci   => pr_cdagenci        --> agencia/pac
                  ,pr_nrdcaixa   => pr_nrdcaixa        --> nr. do caixa
                  ,pr_cdoperad   => pr_cdoperad        --> operador
                  ,pr_dtagendt   => vr_dtagendt        --> Data de agendamento
                  ,pr_nrseqarq   => vr_nrseqarq        --> Sequencial arq
                  ,pr_cdconven   => pr_cdconven        --> convenio
                  ,pr_hrtransa   => pr_hrtransa        --> Hora transacao
                   --------- SAIDA ----------
                  ,pr_cdcritic => vr_cdcritic
                  ,pr_dscritic => vr_dscritic );

    ELSE
      /* Enviar com STR0008 ou PAG0108 */

      /* Se PAG Disponivel e se o Banco de destino estiver operando
         com PAG */
      IF vr_flgutpag AND vr_flgbcpag = 1 THEN
        vr_nmmsgenv := 'PAG0108';
      ELSE /* Se STR Disponivel */
        vr_nmmsgenv := 'STR0008';
      END IF;

      pc_gera_xml (pr_cdcooper   => pr_cdcooper        --> Codigo da cooperativa
                  ,pr_cdorigem   => pr_cdorigem        --> Id de origem
                  ,pr_crapdat    => rw_crapdat         --> rowtype da crapdat
                   /* HEADER */
                  ,pr_nmmsgenv   => vr_nmmsgenv        --> Cod. da Mensagem
                  ,pr_cdlegago   => vr_cdlegado        --> Cod. Legado
                  ,pr_tpmanut    => vr_tpmanut         --> Inclusao
                  ,pr_cdstatus   => vr_cdstatus        --> Mensagem do tipo definitiva
                  ,pr_nroperacao => vr_nroperacao      --> Numero de operacao
                  ,pr_fldebcred  => vr_fldebcred       --> Debito
                   /* BODY */
                  ,pr_nrctrlif   => pr_nrctrlif        --> Nr. controle da IF
                  ,pr_ispbdebt   => SUBSTR(to_char(vr_ispbdebt,'fm00000000000000'),1,8) --> Inscricao SPB
                  ,pr_cdbcoctl   => rw_crapcop.cdbcoctl--> Banco da Coop.
                  ,pr_cdagectl   => rw_crapcop.cdagectl--> Agencia da Coop.
                  ,pr_dsdctadb   => vr_dsdctadb        --> Tp. Conta de Debito
                  ,pr_nrdconta   => pr_nrdconta        --> Nr.da Conta remeternte
                  ,pr_dspesemi   => vr_dspesemi        --> Tp. Pessoa Remetente
                  ,pr_cpfcgemi   => vr_nrcpfemi        --> CPF Remet
                  ,pr_cpfcgdel   => NULL               --> CPF Remetente - Segundo ttl
                  ,pr_nmpesemi   => pr_nmpesemi        --> Nome Remetente - Primeiro ttl
                  ,pr_nmpesde1   => NULL               --> Nome Remetente - Segundo ttl
                  ,pr_ispbcred   => vr_ispbcred        --> IF de Credito
                  ,pr_cdbccxlt   => pr_cdbccxlt        --> Cd. Banco Destino
                  ,pr_cdagenbc   => pr_cdagenbc        --> Agencia IF de credito
                  ,pr_nrcctrcb   => pr_nrcctrcb        --> Conta de credito
                  ,pr_dsdctacr   => vr_dsdctacr        --> Tp. Conta de Debito
                  ,pr_dspesrec   => vr_dspesrec        --> Tp. Pessoa Destino
                  ,pr_cpfcgrcb   => vr_cpfcgrcb        --> CPF Pessoa Destino
                  ,pr_nmpesrcb   => pr_nmpesrcb        --> Nome Pessoa Destino
                  ,pr_vldocmto   => vr_vldocmto        --> Valor do Docmto
                  ,pr_cdfinrcb   => pr_cdfinrcb        --> Finalidade
                  ,pr_dtmvtolt   => vr_dtmvtolt        --> Data atual
                  ,pr_dtmvtopr   => vr_dtmvtopr        --> Data proximo dia
                  ,pr_cdidtran   => pr_cdidtran        --> Id transa��o
                  ,pr_dshistor   => pr_dshistor        --> Historico

                  ,pr_cdagenci   => pr_cdagenci        --> agencia/pac
                  ,pr_nrdcaixa   => pr_nrdcaixa        --> nr. do caixa
                  ,pr_cdoperad   => pr_cdoperad        --> operador
                  ,pr_dtagendt   => NULL               --> Data de agendamento
                  ,pr_nrseqarq   => 0                  --> Sequencial arq
                  ,pr_cdconven   => 0                  --> convenio
                  ,pr_hrtransa   => pr_hrtransa        --> Hora transacao
                   --------- SAIDA ----------
                  ,pr_cdcritic => vr_cdcritic
                  ,pr_dscritic => vr_dscritic );

    END IF;

    -- se retornou critica, abortar programa
    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'N�o foi possivel enviar TEC/TED para o SPB. '|| sqlerrm;
  END pc_proc_envia_tec_ted;

  /******************************************************************************/
  /**                         Tela TRFSAL Op��o B                              **/
  /******************************************************************************/
  PROCEDURE pc_trfsal_opcao_b(pr_cdcooper IN INTEGER              --> Cooperativa
                             ,pr_cdagenci IN INTEGER             --> Cod. Agencia
                             ,pr_nrdcaixa IN INTEGER             --> Numero  Caixa
                             ,pr_cdoperad IN VARCHAR2            --> Codigo Operador
                             ,pr_cdempres craplfp.cdempres%TYPE  --> Codigo da empresa
                             --------- SAIDA --------
                             ,pr_cdcritic OUT INTEGER            --> Codigo do erro
                             ,pr_dscritic OUT VARCHAR2) IS       --> Descricao do erro
 /*---------------------------------------------------------------------------------------------------------------

      Programa : pc_trfsal_opcao_b             Antigo: trfsal.p/opcao_b
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Evandro
      Data     : Dezembro/2006.                   Ultima atualizacao: 22/09/2016


      Dados referentes ao programa:

      Frequencia: Diario (on-line)
      Objetivo  : Gerar Arquivo TED para transmissao ao Banco Brasil referente as
                  contas salario.

      Altera��o : 22/07/2015 - Convers�o Progress -> Oracle (Vanessa)

                  26/10/2015 - Inclusao de verificacao indicador estado de crise. (Jaison/Andrino)

                  09/11/2015 - Ajustar a atualiza��o do lote para gravar vr_qtinfoln
                               na qtinfoln (Douglas - Chamado 356338)
                               
                  22/09/2016 - Arrumar validacao para horario limite de envio de ted (Lucas Ranghetti #500917)
  ---------------------------------------------------------------------------------------------------------------*/
  ---------------> CURSORES <-----------------

    --Verifica se j� existe o lote criado
    CURSOR cr_craplot(pr_cdcooper crapemp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_nrdolote craplot.nrdolote%TYPE) IS
       SELECT nrseqdig,
              qtinfoln,
              qtcompln,
              vlinfodb,
              vlcompdb,
              ROWID
         FROM craplot
        WHERE craplot.cdcooper = pr_cdcooper
          AND craplot.dtmvtolt = pr_dtmvtolt
          AND craplot.cdagenci = 1
          AND craplot.cdbccxlt = 100
          AND craplot.nrdolote = pr_nrdolote;
    rw_craplot cr_craplot%ROWTYPE;
    
    /* Seleciona os registros para enviar o arquivo */
    CURSOR cr_crapccs(pr_cdcooper crapemp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_cdempres craplfp.cdempres%TYPE) IS

       SELECT lcs.progress_recid rowidlcs
             ,ccs.cdagenci
             ,ccs.nrdconta
             ,ccs.cdbantrf
             ,ccs.cdagetrf
             ,ccs.nrctatrf
             ,ccs.nrdigtrf
             ,ccs.nmfuncio
             ,ccs.nrcpfcgc
             ,lcs.nrdocmto
             ,lcs.vllanmto
             ,lcs.dtmvtolt
             ,lcs.dttransf
             ,lcs.nrridlfp
        FROM craplcs lcs
            ,crapccs ccs
       WHERE ccs.cdcooper = lcs.cdcooper 
         AND ccs.nrdconta = lcs.nrdconta 
         AND lcs.cdcooper = pr_cdcooper  
         AND lcs.dtmvtolt = pr_dtmvtolt  
             -- FOLHA EMAIL   --> 560
             -- CAIXA ON-LINE --> 561
             -- FOLHA IBANK   --> gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIS_CRE_TECSAL')
         AND lcs.cdhistor IN(560,561,gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIS_CRE_TECSAL')) 
             --Nao enviado
         AND lcs.flgenvio = 0  
         AND (   pr_cdempres = 0 
              OR EXISTS (SELECT 1
                           FROM craplfp lfp
                          WHERE lfp.cdempres = pr_cdempres
                            AND lcs.cdcooper = lfp.cdcooper
                            AND lcs.nrdconta = lfp.nrdconta
                            AND lcs.nrridlfp = lfp.progress_recid
                            AND lfp.idsitlct = 'L' -- Lan�ado
                        )
             );
    rw_crapccs cr_crapccs%ROWTYPE;
    
    /* Verificar exist�ncia dos registros de debito */
    CURSOR cr_craplcs(pr_cdcooper crapemp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_nrdconta craplcs.nrdconta%TYPE,
                      pr_nrdocmto craplcs.nrdocmto%TYPE) IS

       SELECT lcs.nrdocmto
              ,lcs.vllanmto
              ,lcs.dtmvtolt
              ,lcs.idopetrf
          FROM craplcs lcs
         WHERE lcs.cdcooper = pr_cdcooper
           AND lcs.dtmvtolt = pr_dtmvtolt
           AND lcs.nrdconta = pr_nrdconta
           AND lcs.nrdocmto = pr_nrdocmto
           -- FOLHA EMAIL ou CAIXA ON-LINE --> 827
           -- FOLHA IBANK   --> gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIS_DEB_TECSAL')
           AND lcs.cdhistor IN(827,gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIS_DEB_TECSAL'));
    rw_craplcs cr_craplcs%ROWTYPE;

  ------------> ESTRUTURAS DE REGISTRO <-----------
  -- Definicao de temptable para registros da craplcs
  TYPE typ_tab_reg_crattem IS RECORD
     ( cdseqarq INTEGER,
       nrdolote INTEGER,
       cddbanco INTEGER,
       nmarquiv VARCHAR2(20),
       nrrectit INTEGER,
       nrdconta crapccs.nrdconta%TYPE,
       cdagenci INTEGER,
       cdbantrf crapccs.cdbantrf%TYPE,
       cdagetrf crapccs.cdagetrf%TYPE,
       nrctatrf NUMBER,
       nrdigtrf crapccs.nrdigtrf%TYPE,
       nmfuncio crapccs.nmfuncio%TYPE,
       nrcpfcgc crapccs.nrcpfcgc%TYPE,
       nrdocmto craplcs.nrdocmto%TYPE,
       vllanmto craplcs.vllanmto%TYPE,
       dtmvtolt craplcs.dtmvtolt%TYPE,
       tppessoa INTEGER);

  TYPE typ_tab_crattem IS
    TABLE OF typ_tab_reg_crattem
    INDEX BY PLS_INTEGER;

  vr_tab_crattem typ_tab_crattem;

  ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    vr_flgutstr BOOLEAN := FALSE;
    vr_flgutpag BOOLEAN := FALSE;
    vr_horalimb VARCHAR2(50);
    vr_nmarquiv VARCHAR2(100);
    vr_nrseqdig   craplot.nrseqdig%TYPE;
    vr_qtcompln   craplot.qtcompln%TYPE;
    vr_qtinfoln   craplot.qtinfoln%TYPE;
    vr_vlcompdb   craplot.vlcompdb%TYPE;
    vr_vlinfodb   craplot.vlinfodb%TYPE;
    vr_nrdolote   craplot.nrdolote%TYPE;
    flg_doctobb   BOOLEAN := FALSE;
    vr_contador   PLS_INTEGER := 0;
    vr_idxtbtem   PLS_INTEGER := 0;
    vr_nrctrlif   craplcs.idopetrf%TYPE  := '';
    vr_nrctrlat   craplcs.idopetrf%TYPE  := '';
    vr_nrdcomto craplcs.nrdocmto%TYPE := 0;
    vr_inestcri INTEGER;
    vr_clobxmlc CLOB;
    vr_hrlimted NUMBER;

  BEGIN

    /* Busca dados da cooperativa */
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 651;
      vr_dscritic:= gene0001.fn_busca_critica(651);
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    /* Busca data do sistema */
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_dscritic := gene0001.fn_busca_critica(1);
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Busca o indicador estado de crise
    pc_estado_crise (pr_inestcri => vr_inestcri
                    ,pr_clobxmlc => vr_clobxmlc);

    -- Se estiver setado como estado de crise
    IF  vr_inestcri > 0  THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Sistema indisponivel no momento. Tente mais tarde!';
        RAISE vr_exc_erro;
    END IF;

    /*-- Operando com mensagens STR --*/
    IF  rw_crapcop.flgopstr = 1 THEN
        IF rw_crapcop.iniopstr <= TO_CHAR(SYSDATE,'SSSSS')  AND rw_crapcop.fimopstr >= TO_CHAR(SYSDATE,'SSSSS')  THEN
           vr_flgutstr := TRUE;
        END IF;
    END IF;
    /*-- Operando com mensagens PAG --*/
    IF  rw_crapcop.flgoppag = 1  THEN
        IF  rw_crapcop.inioppag <= TO_CHAR(SYSDATE,'SSSSS') AND rw_crapcop.fimoppag >= TO_CHAR(SYSDATE,'SSSSS') THEN
            vr_flgutpag := TRUE;
       END IF;
    END IF;

    IF  vr_flgutstr = FALSE AND vr_flgutpag = FALSE  THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Hor�rio de envio de TED/DOC encerrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
    END IF;

    vr_horalimb := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HOR_LIM_PORTAB');

    vr_hrlimted := to_char(to_date(vr_horalimb,'hh24:mi'),'sssss');
    
    IF vr_hrlimted < to_char(SYSDATE, 'sssss') THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Horario limite para envio de ted --> ' || vr_horalimb;
       --Levantar Excecao
       RAISE vr_exc_erro;
    END IF;

    vr_nmarquiv := 'dc_ccs'||TO_CHAR(rw_crapdat.dtmvtolt, 'ddmm') || TO_CHAR(SYSDATE, 'sssss') ||'.rem';


    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_nrdolote => 10200);
    FETCH cr_craplot INTO rw_craplot;

    --Se n�o achou o lote cria o mesmo
    IF cr_craplot%NOTFOUND THEN
       BEGIN
           INSERT INTO craplot
                   (cdcooper
                   ,dtmvtolt
                   ,cdagenci
                   ,cdbccxlt
                   ,nrdolote
                   ,tplotmov)
             VALUES(pr_cdcooper
                   ,rw_crapdat.dtmvtolt
                   ,1   -- cdagenci
                   ,100 -- cdbccxlt
                   ,10200
                   ,1)
           RETURNING craplot.ROWID,
                     craplot.nrseqdig,
                     craplot.qtcompln,
                     craplot.qtinfoln,
                     craplot.vlcompdb,
                     craplot.vlinfodb
                INTO rw_craplot.rowid,
                     rw_craplot.nrseqdig,
                     rw_craplot.qtcompln,
                     rw_craplot.qtinfoln,
                     rw_craplot.vlcompdb,
                     rw_craplot.vlinfodb;

        EXCEPTION
          WHEN OTHERS THEN
             vr_cdcritic := 9999;
             vr_dscritic := 'Erro ao inserir craplot: '||SQLERRM;
             -- fecha cursor de lote e da tab
             CLOSE cr_craplot;
            -- Executa a exce��o
            RAISE vr_exc_erro;
       END;

    END IF;

    vr_nrseqdig := rw_craplot.nrseqdig;
    vr_qtcompln := rw_craplot.qtcompln;
    vr_qtinfoln := rw_craplot.qtinfoln;
    vr_vlcompdb := rw_craplot.vlcompdb;
    vr_vlinfodb := rw_craplot.vlinfodb;

    -- fecha cursor de lote
    CLOSE cr_craplot;

    /* Buscar todas as mensagens pendentes de envio */
    FOR rw_crapccs IN cr_crapccs(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                 pr_cdempres => pr_cdempres) LOOP


     /* Atualiza o registro de credito do salario como enviado */
        BEGIN
           UPDATE craplcs
              SET craplcs.flgenvio = 1, /* Enviada */
                  craplcs.cdopetrf = pr_cdoperad,
                  craplcs.dttransf = rw_crapdat.dtmvtolt,
                  craplcs.hrtransf = to_char(SYSDATE,'SSSSS'),
                  craplcs.nmarqenv = vr_nmarquiv
            WHERE craplcs.progress_recid = rw_crapccs.rowidlcs;

         EXCEPTION
           WHEN OTHERS THEN
              vr_cdcritic := 9999;
              vr_dscritic := 'Erro ao atualizar o registro na CRAPLCS: '||SQLERRM;
              -- Executa a exce��o
              RAISE vr_exc_erro;
        END;

        vr_contador := vr_contador + 1;

         -- CECRED
        IF rw_crapccs.cdbantrf = 85 THEN
           PAGA0002.pc_tranf_sal_intercooperativa(pr_cdcooper => pr_cdcooper   --> Codigo da cooperativa
                                        ,pr_cdagenci => 0                      --> Codigo da agencia
                                        ,pr_nrdcaixa => 0                      --> Numero do caixa
                                        ,pr_cdoperad => pr_cdoperad            --> Codigo do operador
                                        ,pr_nmdatela => 'TRFSAL'               --> Nome da tela
                                        ,pr_idorigem => 1                      --> Descri��o de origem do registro
                                        ,pr_nrdconta => rw_crapccs.nrdconta    --> Numero da conta do cooperado
                                        ,pr_rowidlcs => rw_crapccs.rowidlcs
                                        ,pr_cdagetrf => rw_crapccs.cdagetrf    --> Numero do PA.
                                        ,pr_idseqttl => 1                      --> Sequencial do titular
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt    --> Data do movimento
                                        ,pr_flgerlog => FALSE
                                        /* parametros de saida */
                                        ,pr_cdcritic => vr_cdcritic            --> Codigo da critica
                                        ,pr_dscritic => vr_dscritic);

           IF rw_crapccs.nrridlfp > 0 THEN
              IF vr_cdcritic IS NULL THEN
                  BEGIN
                    UPDATE craplfp
                       SET idsitlct = 'C'  --Creditado
                          ,dsobslct = NULL --Limpar qualquer erro anterior
                     WHERE progress_recid = rw_crapccs.nrridlfp;


                   EXCEPTION
                        WHEN OTHERS THEN
                          vr_cdcritic := 9999;
                          vr_dscritic := 'Erro ao atualizar o registro na CRAPLFP: '||SQLERRM;
                          -- Executa a exce��o
                          RAISE vr_exc_erro;
                  END;

              ELSE
                  BEGIN
                    UPDATE craplfp
                       SET idsitlct = 'E'  --Erro
                          ,dsobslct = 'Erro encontrado ' || vr_dscritic
                     WHERE progress_recid = rw_crapccs.nrridlfp;

                   EXCEPTION
                        WHEN OTHERS THEN
                          vr_cdcritic := 9999;
                          vr_dscritic := 'Erro ao atualizar o registro na CRAPLFP: '||SQLERRM;
                          -- Executa a exce��o
                          RAISE vr_exc_erro;
                   END;

              END IF;

           ELSE
               IF vr_cdcritic IS NOT NULL THEN
                  -- Executa a exce��o
                  RAISE vr_exc_erro;
               END IF;
           END IF;

        ELSE /* Outras IFs */


          LOOP
           -- Utiliza o contador porque estava gerando mensagem no mesmo
           --  ETIME - confrontando o numero de controle
             vr_nrctrlif := '2' ||
             TO_CHAR(rw_crapdat.dtmvtolt,'YY') ||
             TO_CHAR(rw_crapdat.dtmvtolt,'MM') ||
             TO_CHAR(rw_crapdat.dtmvtolt,'DD') ||
             LPAD(rw_crapcop.cdagectl,4,0) ||
             TO_CHAR(SYSTIMESTAMP,'SSSSSFF3') || --  ETIME - confrontando o numero de controle
             'A' ;
             EXIT WHEN vr_nrctrlif <> nvl(vr_nrctrlat,' ');

          END LOOP;


          vr_nrctrlat := vr_nrctrlif;

          OPEN cr_craplcs(pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_nrdconta => rw_crapccs.nrdconta
                         ,pr_nrdocmto => rw_crapccs.nrdocmto);

          FETCH cr_craplcs INTO rw_craplcs;

          IF cr_craplcs%NOTFOUND THEN
            vr_nrdcomto := rw_crapccs.nrdocmto;
          ELSE
            vr_nrdcomto := rw_crapccs.nrdocmto + 1000000;
          END IF;

          CLOSE cr_craplcs;

          BEGIN
               INSERT INTO craplcs
                          (cdcooper,
                           dtmvtolt,
                           nrdconta,
                           vllanmto,
                           dttransf,
                           cdopetrf,
                           hrtransf,
                           cdopecrd,
                           nrdocmto,
                           cdsitlcs,
                           nmarqenv,
                           cdhistor,
                           nrdolote,
                           nrautdoc,
                           cdagenci,
                           cdbccxlt,
                           flgenvio,
                           idopetrf,
                           flgopfin,
                           nrridlfp)
                    SELECT cdcooper,
                           dtmvtolt,
                           nrdconta,
                           vllanmto,
                           dttransf,
                           cdopetrf,
                           hrtransf,
                           cdopecrd,
                           vr_nrdcomto,
                           cdsitlcs,
                           nmarqenv,
                           gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIS_DEB_TECSAL'),
                           nrdolote,
                           nrautdoc,
                           cdagenci,
                           cdbccxlt,
                           flgenvio,
                           vr_nrctrlif,
                           flgopfin,
                           nrridlfp
                      FROM craplcs lcs
                     WHERE lcs.progress_recid = rw_crapccs.rowidlcs;

           EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic := 9999;
                  vr_dscritic := 'Erro ao inserir craplcs: ' || rw_crapccs.rowidlcs || SQLERRM;
                  -- Executa a exce��o
                  RAISE vr_exc_erro;
           END;
           IF rw_crapccs.cdbantrf = 1 THEN
               vr_nrdolote := 1;
               flg_doctobb := TRUE;
           ELSE
               IF flg_doctobb = TRUE THEN
                  vr_nrdolote := 2;
               ELSE
                  vr_nrdolote := 1;
               END IF;
           END IF;

           vr_tab_crattem(vr_contador).cdseqarq := 1;
           vr_tab_crattem(vr_contador).nrdolote := vr_nrdolote;
           vr_tab_crattem(vr_contador).cddbanco := rw_crapcop.cdbcoctl;
           vr_tab_crattem(vr_contador).nmarquiv := vr_nmarquiv;
           vr_tab_crattem(vr_contador).nrdconta := rw_crapccs.nrdconta;
           vr_tab_crattem(vr_contador).cdagenci := rw_crapccs.cdagenci;
           vr_tab_crattem(vr_contador).cdbantrf := rw_crapccs.cdbantrf;
           vr_tab_crattem(vr_contador).cdagetrf := rw_crapccs.cdagetrf;
           vr_tab_crattem(vr_contador).nrctatrf := rw_crapccs.nrctatrf;
           vr_tab_crattem(vr_contador).nrdigtrf := rw_crapccs.nrdigtrf;
           vr_tab_crattem(vr_contador).nmfuncio := rw_crapccs.nmfuncio;
           vr_tab_crattem(vr_contador).nrcpfcgc := rw_crapccs.nrcpfcgc;
           vr_tab_crattem(vr_contador).nrdocmto := rw_crapccs.nrdocmto;
           vr_tab_crattem(vr_contador).vllanmto := rw_crapccs.vllanmto;
           vr_tab_crattem(vr_contador).dtmvtolt := rw_crapccs.dtmvtolt;
           vr_tab_crattem(vr_contador).tppessoa := 1;

        END IF;

        -- Atualiza a capa do lote
        vr_nrseqdig := vr_nrseqdig + 1;
        vr_qtcompln := vr_qtcompln + 1;
        vr_qtinfoln := vr_qtinfoln + 1;
        vr_vlcompdb := vr_vlcompdb + rw_crapccs.vllanmto;
        vr_vlinfodb := vr_vlinfodb + rw_crapccs.vllanmto;

        BEGIN
           UPDATE craplot
              -- se o numero for maior que o ja existente atualiza
              SET nrseqdig = vr_nrseqdig,
                  qtcompln = vr_qtcompln,
                  qtinfoln = vr_qtinfoln,
                  vlcompdb = vr_vlcompdb,
                  vlinfodb = vr_vlinfodb
            WHERE ROWID = rw_craplot.rowid;
        EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic := 9999;
             vr_dscritic := 'Erro ao atualizar craplot: '||SQLERRM;
             -- Executa a exce��o
             RAISE vr_exc_erro;
        END;
    END LOOP; /* Fim do loop rw_craplcs */

    vr_idxtbtem := vr_tab_crattem.first;

    WHILE vr_idxtbtem IS NOT NULL LOOP

          OPEN cr_craplcs(pr_cdcooper => rw_crapcop.cdcooper,
                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                          pr_nrdconta => vr_tab_crattem(vr_idxtbtem).nrdconta,
                          pr_nrdocmto => vr_tab_crattem(vr_idxtbtem).nrdocmto);
          FETCH cr_craplcs INTO rw_craplcs;

          IF cr_craplcs%NOTFOUND  THEN
             vr_dscritic := 'Erro ao identificar numero de controle';
             CLOSE cr_craplcs;
              --levantar excecao
             RAISE vr_exc_erro;
          END IF;
          CLOSE cr_craplcs;

          vr_nrctrlif := rw_craplcs.idopetrf;

          BEGIN
              vr_tab_crattem(vr_idxtbtem).nrctatrf := to_number(vr_tab_crattem(vr_idxtbtem).nrctatrf || vr_tab_crattem(vr_idxtbtem).nrdigtrf);
          EXCEPTION
            WHEN OTHERS THEN
              vr_tab_crattem(vr_idxtbtem).nrctatrf := to_number(vr_tab_crattem(vr_idxtbtem).nrctatrf || '0');
          END;

          pc_proc_envia_tec_ted (pr_cdcooper => rw_crapcop.cdcooper                     --> Cooperativa
                                ,pr_cdagenci => vr_tab_crattem(vr_idxtbtem).cdagenci   --> Cod. Agencia
                                ,pr_nrdcaixa => 1                                      --> Numero  Caixa
                                ,pr_cdoperad => pr_cdoperad                            --> Operador
                                ,pr_titulari => TRUE                                      --> Mesmo Titular.
                                ,pr_vldocmto => vr_tab_crattem(vr_idxtbtem).vllanmto   --> Vlr. DOCMTO
                                ,pr_nrctrlif => vr_nrctrlif                            --> NumCtrlIF
                                ,pr_nrdconta => vr_tab_crattem(vr_idxtbtem).nrdconta   --> Nro Conta
                                ,pr_cdbccxlt => vr_tab_crattem(vr_idxtbtem).cdbantrf   --> Codigo Banco
                                ,pr_cdagenbc => vr_tab_crattem(vr_idxtbtem).cdagetrf   --> Cod Agencia
                                ,pr_nrcctrcb => vr_tab_crattem(vr_idxtbtem).nrctatrf   --> Nr.Ct.destino
                                ,pr_cdfinrcb => 10                                     --> Finalidade
                                ,pr_tpdctadb => 1                                      --> Tp. conta deb
                                ,pr_tpdctacr => 1                                      --> Tp conta cred
                                ,pr_nmpesemi => vr_tab_crattem(vr_idxtbtem).nmfuncio   --> Nome Do titular
                                ,pr_nmpesde1 => ''                                     --> Nome De 2TTT
                                ,pr_cpfcgemi => to_number(vr_tab_crattem(vr_idxtbtem).nrcpfcgc)   --> CPF/CNPJ Do titular
                                ,pr_cpfcgdel => 0                                      --> CPF sec TTL
                                ,pr_nmpesrcb => ''                                     --> Nome Para
                                ,pr_nmstlrcb => ''                                     --> Nome Para 2TTL
                                ,pr_cpfcgrcb => 0                                      --> CPF/CNPJ Para
                                ,pr_cpstlrcb => 0                                      --> CPF Para 2TTL
                                ,pr_tppesemi => 1                                      --> Tp. pessoa De
                                ,pr_tppesrec => 1                                      --> Tp. pessoa Para
                                ,pr_flgctsal => TRUE                                      --> CC Sal
                                ,pr_cdidtran => ''                                     --> tipo de transferencia
                                ,pr_cdorigem => 1                                      --> Cod. Origem
                                ,pr_dtagendt => NULL                                   --> data egendamento
                                ,pr_nrseqarq => 0                                      --> nr. seq arq.
                                ,pr_cdconven => 0                                      --> Cod. Convenio
                                ,pr_dshistor => ''                                     --> Dsc do Hist.
                                ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')               --> Hora transacao
                                ,pr_cdispbif => 0                                      --> ISPB Banco
                                --------- SAIDA --------
                                ,pr_cdcritic => vr_cdcritic                            --> Codigo do erro
                                ,pr_dscritic => vr_dscritic) ;

          IF vr_cdcritic IS NOT NULL THEN
              vr_dscritic := 'Nao foi possivel enviar o TEC ao SPB';
              RAISE vr_exc_erro;
          END IF;
          -- buscar proximo
          vr_idxtbtem := vr_tab_crattem.next(vr_idxtbtem);

     END LOOP;
     btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper,
                                 pr_nmarqlog     => 'TRFSAL',
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||': ' ||
                                                    'Operador '|| pr_cdoperad ||' --> TECs SALARIO processadas com sucesso.' );
  COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_nmarqlog     => 'TRFSAL',
                                 pr_ind_tipo_log => 1, -- Normal
                                 pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||':' ||
                                                    'Operador '|| pr_cdoperad ||' --> Critica: '|| vr_dscritic );

      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro n�o tratado. '|| SQLERRM;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_nmarqlog     => 'TRFSAL',
                                 pr_ind_tipo_log => 1, -- Normal
                                 pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||':' ||
                                                    'Operador '|| pr_cdoperad ||' --> Critica: '|| pr_dscritic );

      ROLLBACK;
  END pc_trfsal_opcao_b;

  /******************************************************************************/
  /**                         Tela TRFSAL Op��o X                              **/
  /******************************************************************************/
  PROCEDURE pc_trfsal_opcao_x(pr_cdcooper IN INTEGER              --> Cooperativa
                             ,pr_cdagenci IN INTEGER             --> Cod. Agencia
                             ,pr_nrdcaixa IN INTEGER             --> Numero  Caixa
                             ,pr_cdoperad IN VARCHAR2            --> Codigo Operador
                             ,pr_cdempres craplfp.cdempres%TYPE  --> Codigo da empresa
                             --------- SAIDA --------
                             ,pr_cdcritic OUT INTEGER            --> Codigo do erro
                             ,pr_dscritic OUT VARCHAR2) IS       --> Descricao do erro
 /*---------------------------------------------------------------------------------------------------------------

      Programa : pc_trfsal_opcao_x             Antigo: trfsal.p/opcao_b
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Jean Michel
      Data     : agosto/2015.                   Ultima atualizacao: 09/11/2015


      Dados referentes ao programa:

      Frequencia: Diario (on-line)
      Objetivo  : Gerar Arquivo TED para transmissao ao Banco Brasil referente as
                  contas salario.

      Altera��o : 09/11/2015 - Ajustar a atualiza��o do lote para gravar vr_qtinfoln
                               na qtinfoln (Douglas - Chamado 356338)

                  26/10/2015 - Inclusao de verificacao indicador estado de crise. (Jaison/Andrino)

  ---------------------------------------------------------------------------------------------------------------*/
  ---------------> CURSORES <-----------------

    --Verifica se j� existe o lote criado
    CURSOR cr_craplot(pr_cdcooper crapemp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_nrdolote craplot.nrdolote%TYPE) IS
       SELECT nrseqdig,
              qtinfoln,
              qtcompln,
              vlinfodb,
              vlcompdb,
              ROWID
         FROM craplot
        WHERE craplot.cdcooper = pr_cdcooper
          AND craplot.dtmvtolt = pr_dtmvtolt
          AND craplot.cdagenci = 1
          AND craplot.cdbccxlt = 100
          AND craplot.nrdolote = pr_nrdolote;
    rw_craplot cr_craplot%ROWTYPE;

    CURSOR cr_craplcs(pr_cdcooper crapemp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_nrdconta craplcs.nrdconta%TYPE,
                      pr_cdhistor craphis.cdhistor%TYPE,
                      pr_nrdocmto craplcs.nrdocmto%TYPE) IS

       SELECT lcs.cdcooper
              ,lcs.nrdocmto
              ,lcs.vllanmto
              ,lcs.dtmvtolt
              ,lcs.idopetrf
              ,lcs.nrridlfp
          FROM craplcs lcs
         WHERE lcs.cdcooper  = pr_cdcooper  AND
               lcs.dtmvtolt  <= pr_dtmvtolt  AND
               lcs.nrdconta  = pr_nrdconta  AND
               lcs.cdhistor  = pr_cdhistor  AND
               lcs.nrdocmto  = pr_nrdocmto;


    rw_craplcs cr_craplcs%ROWTYPE;

    /* Seleciona os registros para enviar o arquivo */
    CURSOR cr_crapccs(pr_cdcooper crapemp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_cdhistor craphis.cdhistor%TYPE,
                      pr_cdempres craplfp.cdempres%TYPE) IS

       SELECT lcs.progress_recid rowidlcs
             ,ccs.cdagenci
             ,ccs.nrdconta
             ,ccs.cdbantrf
             ,ccs.cdagetrf
             ,ccs.nrctatrf
             ,ccs.nrdigtrf
             ,ccs.nmfuncio
             ,ccs.nrcpfcgc
             ,lcs.nrdocmto
             ,lcs.vllanmto
             ,lcs.dtmvtolt
             ,lcs.dttransf
             ,lcs.nrridlfp
        FROM craplcs lcs
            ,crapccs ccs
       WHERE ccs.cdcooper = lcs.cdcooper AND
             ccs.nrdconta = lcs.nrdconta AND
             lcs.cdcooper = pr_cdcooper  AND
             lcs.dtmvtolt >= pr_dtmvtolt  AND
             lcs.cdhistor = pr_cdhistor  AND
             lcs.flgenvio = 0            AND --Nao enviado
             lcs.flgopfin = 0            AND
             (pr_cdempres = 0 OR EXISTS
               (SELECT 1
                  FROM craplfp lfp
                 WHERE lfp.cdempres = pr_cdempres
                   AND lcs.cdcooper = lfp.cdcooper
                   AND lcs.nrdconta = lfp.nrdconta
                   AND lcs.nrridlfp = lfp.progress_recid
                   AND lfp.idsitlct = 'L' -- Lan�ado
               )
             );
    rw_crapccs cr_crapccs%ROWTYPE;

  ------------> ESTRUTURAS DE REGISTRO <-----------
  -- Definicao de temptable para registros da craplcs
  TYPE typ_tab_reg_crattem IS RECORD
     ( cdseqarq INTEGER,
       nrdolote INTEGER,
       cddbanco INTEGER,
       nmarquiv VARCHAR2(20),
       nrrectit INTEGER,
       nrdconta crapccs.nrdconta%TYPE,
       cdagenci INTEGER,
       cdbantrf crapccs.cdbantrf%TYPE,
       cdagetrf crapccs.cdagetrf%TYPE,
       nrctatrf NUMBER,
       nrdigtrf crapccs.nrdigtrf%TYPE,
       nmfuncio crapccs.nmfuncio%TYPE,
       nrcpfcgc crapccs.nrcpfcgc%TYPE,
       nrdocmto craplcs.nrdocmto%TYPE,
       vllanmto craplcs.vllanmto%TYPE,
       dtmvtolt craplcs.dtmvtolt%TYPE,
       tppessoa INTEGER);

  TYPE typ_tab_crattem IS
    TABLE OF typ_tab_reg_crattem
    INDEX BY PLS_INTEGER;

  vr_tab_crattem typ_tab_crattem;

  ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    vr_nmarquiv VARCHAR2(100);
    vr_nrseqdig   craplot.nrseqdig%TYPE;
    vr_qtcompln   craplot.qtcompln%TYPE;
    vr_qtinfoln   craplot.qtinfoln%TYPE;
    vr_vlcompdb   craplot.vlcompdb%TYPE;
    vr_vlinfodb   craplot.vlinfodb%TYPE;
    vr_cdhistor   craplcs.cdhistor%TYPE;
    vr_nrdolote   craplot.nrdolote%TYPE;
    flg_doctobb   BOOLEAN := FALSE;
    vr_contador   PLS_INTEGER := 0;
    vr_idxtbtem   PLS_INTEGER := 0;
    vr_nrctrlif   craplcs.idopetrf%TYPE  := '';
    vr_nrctrlat   craplcs.idopetrf%TYPE  := '';
    vr_nrdcomto craplcs.nrdocmto%TYPE := 0;
    vr_inestcri INTEGER;
    vr_clobxmlc CLOB;
  BEGIN

    /* Busca dados da cooperativa */
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 651;
      vr_dscritic:= gene0001.fn_busca_critica(651);
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    /* Busca data do sistema */
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_dscritic := gene0001.fn_busca_critica(1);
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Busca o indicador estado de crise
    pc_estado_crise (pr_inestcri => vr_inestcri
                    ,pr_clobxmlc => vr_clobxmlc);

    -- Se estiver setado como estado de crise
    IF  vr_inestcri > 0  THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Sistema indisponivel no momento. Tente mais tarde!';
        RAISE vr_exc_erro;
    END IF;

    vr_nmarquiv := 'dc_ccs'||TO_CHAR(rw_crapdat.dtmvtolt, 'ddmm') || TO_CHAR(SYSDATE, 'sssss') ||'.rem';

    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_nrdolote => 10200);
    FETCH cr_craplot INTO rw_craplot;

    --Se n�o achou o lote cria o mesmo
    IF cr_craplot%NOTFOUND THEN
       BEGIN
           INSERT INTO craplot
                   (cdcooper
                   ,dtmvtolt
                   ,cdagenci
                   ,cdbccxlt
                   ,nrdolote
                   ,tplotmov)
             VALUES(pr_cdcooper
                   ,rw_crapdat.dtmvtolt
                   ,1   -- cdagenci
                   ,100 -- cdbccxlt
                   ,10200
                   ,1)
           RETURNING craplot.ROWID,
                     craplot.nrseqdig,
                     craplot.qtcompln,
                     craplot.qtinfoln,
                     craplot.vlcompdb,
                     craplot.vlinfodb
                INTO rw_craplot.rowid,
                     rw_craplot.nrseqdig,
                     rw_craplot.qtcompln,
                     rw_craplot.qtinfoln,
                     rw_craplot.vlcompdb,
                     rw_craplot.vlinfodb;

        EXCEPTION
          WHEN OTHERS THEN
             vr_cdcritic := 9999;
             vr_dscritic := 'Erro ao inserir craplot: '||SQLERRM;
             -- fecha cursor de lote e da tab
             CLOSE cr_craplot;
            -- Executa a exce��o
            RAISE vr_exc_erro;
       END;

    END IF;

    vr_nrseqdig := rw_craplot.nrseqdig;
    vr_qtcompln := rw_craplot.qtcompln;
    vr_qtinfoln := rw_craplot.qtinfoln;
    vr_vlcompdb := rw_craplot.vlcompdb;
    vr_vlinfodb := rw_craplot.vlinfodb;

    -- fecha cursor de lote
    CLOSE cr_craplot;

    vr_cdhistor := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIST_REC_TECSAL');

    FOR rw_crapccs IN cr_crapccs(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => rw_crapdat.dtmvtoan,
                                 pr_cdhistor => vr_cdhistor,
                                 pr_cdempres => pr_cdempres) LOOP

        /* Atualiza o registro de credito do salario como enviado */
        BEGIN
           UPDATE craplcs
              SET craplcs.flgenvio = 1, /* Enviada */
                  craplcs.cdopetrf = pr_cdoperad,
                  craplcs.dttransf = rw_crapdat.dtmvtolt,
                  craplcs.hrtransf = to_char(SYSDATE,'SSSSS'),
                  craplcs.nmarqenv = vr_nmarquiv
            WHERE craplcs.progress_recid = rw_crapccs.rowidlcs;

         EXCEPTION
           WHEN OTHERS THEN
              vr_cdcritic := 9999;
              vr_dscritic := 'Erro ao atualizar o registro na CRAPLCS: '||SQLERRM;
              -- Executa a exce��o
              RAISE vr_exc_erro;
        END;

        vr_contador := vr_contador + 1;

        LOOP
           -- Utiliza o contador porque estava gerando mensagem no mesmo
           --  ETIME - confrontando o numero de controle
             vr_nrctrlif := '2' ||
             TO_CHAR(rw_crapdat.dtmvtolt,'YY') ||
             TO_CHAR(rw_crapdat.dtmvtolt,'MM') ||
             TO_CHAR(rw_crapdat.dtmvtolt,'DD') ||
             LPAD(rw_crapcop.cdagectl,4,0) ||
             TO_CHAR(SYSTIMESTAMP,'SSSSSFF3') || --  ETIME - confrontando o numero de controle
             'A' ;
             EXIT WHEN vr_nrctrlif <> nvl(vr_nrctrlat,' ');

          END LOOP;

        vr_nrctrlat := vr_nrctrlif;

       OPEN cr_craplcs(pr_cdcooper => pr_cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                      ,pr_nrdconta => rw_crapccs.nrdconta
                      ,pr_cdhistor => gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIS_DEB_TECSAL')
                      ,pr_nrdocmto => rw_crapccs.nrdocmto);

       FETCH cr_craplcs INTO rw_craplcs;

       IF cr_craplcs%NOTFOUND THEN
         vr_nrdcomto := rw_crapccs.nrdocmto;
       ELSE
         vr_nrdcomto := rw_crapccs.nrdocmto + 1000000;
       END IF;

       CLOSE cr_craplcs;

       BEGIN
           INSERT INTO craplcs
                      (cdcooper,
                       dtmvtolt,
                       nrdconta,
                       vllanmto,
                       dttransf,
                       cdopetrf,
                       hrtransf,
                       cdopecrd,
                       nrdocmto,
                       cdsitlcs,
                       nmarqenv,
                       cdhistor,
                       nrdolote,
                       nrautdoc,
                       cdagenci,
                       cdbccxlt,
                       flgenvio,
                       idopetrf,
                       flgopfin,
                       nrridlfp)
                SELECT cdcooper,
                       dtmvtolt,
                       nrdconta,
                       vllanmto,
                       dttransf,
                       cdopetrf,
                       hrtransf,
                       cdopecrd,
                       vr_nrdcomto,
                       cdsitlcs,
                       nmarqenv,
                       gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIS_DEB_TECSAL'),
                       nrdolote,
                       nrautdoc,
                       cdagenci,
                       cdbccxlt,
                       flgenvio,
                       vr_nrctrlif,
                       flgopfin,
                       nrridlfp
                  FROM craplcs lcs
                 WHERE lcs.progress_recid = rw_crapccs.rowidlcs;

       EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 9999;
              vr_dscritic := 'Erro ao inserir craplcs: ' || rw_crapccs.rowidlcs || SQLERRM;
              -- Executa a exce��o
              RAISE vr_exc_erro;
       END;
       IF rw_crapccs.cdbantrf = 1 THEN
           vr_nrdolote := 1;
           flg_doctobb := TRUE;
       ELSE
           IF flg_doctobb = TRUE THEN
              vr_nrdolote := 2;
           ELSE
              vr_nrdolote := 1;
           END IF;
       END IF;

       vr_tab_crattem(vr_contador).cdseqarq := 1;
       vr_tab_crattem(vr_contador).nrdolote := vr_nrdolote;
       vr_tab_crattem(vr_contador).cddbanco := rw_crapcop.cdbcoctl;
       vr_tab_crattem(vr_contador).nmarquiv := vr_nmarquiv;
       vr_tab_crattem(vr_contador).nrdconta := rw_crapccs.nrdconta;
       vr_tab_crattem(vr_contador).cdagenci := rw_crapccs.cdagenci;
       vr_tab_crattem(vr_contador).cdbantrf := rw_crapccs.cdbantrf;
       vr_tab_crattem(vr_contador).cdagetrf := rw_crapccs.cdagetrf;
       vr_tab_crattem(vr_contador).nrctatrf := rw_crapccs.nrctatrf;
       vr_tab_crattem(vr_contador).nrdigtrf := rw_crapccs.nrdigtrf;
       vr_tab_crattem(vr_contador).nmfuncio := rw_crapccs.nmfuncio;
       vr_tab_crattem(vr_contador).nrcpfcgc := rw_crapccs.nrcpfcgc;
       vr_tab_crattem(vr_contador).nrdocmto := rw_crapccs.nrdocmto;
       vr_tab_crattem(vr_contador).vllanmto := rw_crapccs.vllanmto;
       vr_tab_crattem(vr_contador).dtmvtolt := rw_crapccs.dtmvtolt;
       vr_tab_crattem(vr_contador).tppessoa := 1;

         -- Atualiza a capa do lote
         vr_nrseqdig := vr_nrseqdig + 1;
         vr_qtcompln := vr_qtcompln + 1;
         vr_qtinfoln := vr_qtinfoln + 1;
         vr_vlcompdb := vr_vlcompdb + rw_craplcs.vllanmto;
         vr_vlinfodb := vr_vlinfodb + rw_craplcs.vllanmto;

         BEGIN
            UPDATE craplot
               -- se o numero for maior que o ja existente atualiza
               SET nrseqdig = vr_nrseqdig,
                   qtcompln = vr_qtcompln,
                   qtinfoln = vr_qtinfoln,
                   vlcompdb = vr_vlcompdb,
                   vlinfodb = vr_vlinfodb
             WHERE ROWID = rw_craplot.rowid;
         EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 9999;
              vr_dscritic := 'Erro ao atualizar craplot: '||SQLERRM;
              -- Executa a exce��o
              RAISE vr_exc_erro;
         END;

         /* Atualizar o registro do lan�amento do pagamento eliminado poss�veis erros
            anteriores e retornando a situa��o do registro para a situa��o inicial */
         UPDATE craplfp lfp
            SET lfp.idsitlct = 'L'
               ,lfp.dsobslct = NULL
          WHERE lfp.cdcooper = rw_craplcs.cdcooper
            AND lfp.progress_recid = rw_craplcs.nrridlfp;

    END LOOP; /* Fim do loop rw_craplcs */

    vr_idxtbtem := vr_tab_crattem.first;

    WHILE vr_idxtbtem IS NOT NULL LOOP

          OPEN cr_craplcs(pr_cdcooper => rw_crapcop.cdcooper,
                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                          pr_nrdconta => vr_tab_crattem(vr_idxtbtem).nrdconta,
                          pr_cdhistor => gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIS_DEB_TECSAL'),
                          pr_nrdocmto => vr_tab_crattem(vr_idxtbtem).nrdocmto);
          FETCH cr_craplcs INTO rw_craplcs;

          IF cr_craplcs%NOTFOUND  THEN
             vr_dscritic := 'Erro ao identificar numero de controle';
             CLOSE cr_craplcs;
              --levantar excecao
             RAISE vr_exc_erro;
          END IF;
          CLOSE cr_craplcs;

          vr_nrctrlif := rw_craplcs.idopetrf;

          BEGIN
              vr_tab_crattem(vr_idxtbtem).nrctatrf := to_number(vr_tab_crattem(vr_idxtbtem).nrctatrf || vr_tab_crattem(vr_idxtbtem).nrdigtrf);
          EXCEPTION
            WHEN OTHERS THEN
              vr_tab_crattem(vr_idxtbtem).nrctatrf := to_number(vr_tab_crattem(vr_idxtbtem).nrctatrf || '0');
          END;

          pc_proc_envia_tec_ted (pr_cdcooper => rw_crapcop.cdcooper                     --> Cooperativa
                                ,pr_cdagenci => vr_tab_crattem(vr_idxtbtem).cdagenci   --> Cod. Agencia
                                ,pr_nrdcaixa => 1                                      --> Numero  Caixa
                                ,pr_cdoperad => pr_cdoperad                            --> Operador
                                ,pr_titulari => TRUE                                      --> Mesmo Titular.
                                ,pr_vldocmto => vr_tab_crattem(vr_idxtbtem).vllanmto   --> Vlr. DOCMTO
                                ,pr_nrctrlif => vr_nrctrlif                            --> NumCtrlIF
                                ,pr_nrdconta => vr_tab_crattem(vr_idxtbtem).nrdconta   --> Nro Conta
                                ,pr_cdbccxlt => vr_tab_crattem(vr_idxtbtem).cdbantrf   --> Codigo Banco
                                ,pr_cdagenbc => vr_tab_crattem(vr_idxtbtem).cdagetrf   --> Cod Agencia
                                ,pr_nrcctrcb => vr_tab_crattem(vr_idxtbtem).nrctatrf   --> Nr.Ct.destino
                                ,pr_cdfinrcb => 10                                     --> Finalidade
                                ,pr_tpdctadb => 1                                      --> Tp. conta deb
                                ,pr_tpdctacr => 1                                      --> Tp conta cred
                                ,pr_nmpesemi => vr_tab_crattem(vr_idxtbtem).nmfuncio   --> Nome Do titular
                                ,pr_nmpesde1 => ''                                     --> Nome De 2TTT
                                ,pr_cpfcgemi => to_number(vr_tab_crattem(vr_idxtbtem).nrcpfcgc)   --> CPF/CNPJ Do titular
                                ,pr_cpfcgdel => 0                                      --> CPF sec TTL
                                ,pr_nmpesrcb => ''                                     --> Nome Para
                                ,pr_nmstlrcb => ''                                     --> Nome Para 2TTL
                                ,pr_cpfcgrcb => 0                                      --> CPF/CNPJ Para
                                ,pr_cpstlrcb => 0                                      --> CPF Para 2TTL
                                ,pr_tppesemi => 1                                      --> Tp. pessoa De
                                ,pr_tppesrec => 1                                      --> Tp. pessoa Para
                                ,pr_flgctsal => TRUE                                      --> CC Sal
                                ,pr_cdidtran => ''                                     --> tipo de transferencia
                                ,pr_cdorigem => 1                                      --> Cod. Origem
                                ,pr_dtagendt => NULL                                   --> data egendamento
                                ,pr_nrseqarq => 0                                      --> nr. seq arq.
                                ,pr_cdconven => 0                                      --> Cod. Convenio
                                ,pr_dshistor => ''                                     --> Dsc do Hist.
                                ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')               --> Hora transacao
                                ,pr_cdispbif => 0                                      --> ISPB Banco
                                --------- SAIDA --------
                                ,pr_cdcritic => vr_cdcritic                            --> Codigo do erro
                                ,pr_dscritic => vr_dscritic) ;

          IF vr_cdcritic IS NOT NULL THEN
              vr_dscritic := 'Nao foi possivel enviar o TEC ao SPB';
              RAISE vr_exc_erro;
          END IF;
          -- buscar proximo
          vr_idxtbtem := vr_tab_crattem.next(vr_idxtbtem);

     END LOOP;
     btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper,
                                 pr_nmarqlog     => 'TRFSAL',
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||': ' ||
                                                    'Operador '|| pr_cdoperad ||' --> TECs SALARIO processadas com sucesso.' );
   COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_nmarqlog     => 'TRFSAL',
                                 pr_ind_tipo_log => 1, -- Normal
                                 pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||':' ||
                                                    'Operador '|| pr_cdoperad ||' --> Critica: '|| vr_dscritic );

      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro n�o tratado. '|| SQLERRM;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_nmarqlog     => 'TRFSAL',
                                 pr_ind_tipo_log => 1, -- Normal
                                 pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||':' ||
                                                    'Operador '|| pr_cdoperad ||' --> Critica: '|| pr_dscritic );

      ROLLBACK;
  END pc_trfsal_opcao_x;

  /* Procedure para retornar o estado de crise */
  PROCEDURE pc_estado_crise (pr_flproces  IN VARCHAR2 DEFAULT 'N' -- Indica para verificar o processo
                            ,pr_inestcri OUT INTEGER -- 0-Sem crise / 1-Com Crise
                            ,pr_clobxmlc OUT CLOB) IS -- XML com informa��es de LOG
    -- .........................................................................
    --
    --  Programa  : pc_estado_crise
    --  Sistema   : CRED
    --  Sigla     : SSPB0001
    --  Autor     : Jaison
    --  Data      : Outubro/2015.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Procedure para retornar o estado de crise
  BEGIN
    DECLARE
      --Variaveis
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_flestcri VARCHAR2(1);
      vr_inestcri INTEGER;
      vr_dtintegr DATE;
      --Registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
      vr_clobxmlc CLOB;

      -- Busca as cooperativas
      CURSOR cr_crapcop IS
      SELECT crapcop.cdcooper
        FROM crapcop;

      -- Busca dados do cadastro dos programas
      CURSOR cr_crapprg(pr_cdcooper IN crapprg.cdcooper%TYPE      --> Codigo da cooperativa
                       ,pr_nmdatela IN crapprg.cdprogra%TYPE) IS  --> Nome da tela
      SELECT crapprg.inctrprg
        FROM crapprg
       WHERE crapprg.cdcooper = pr_cdcooper
         AND crapprg.cdprogra = pr_nmdatela
         AND crapprg.nmsistem = 'CRED';
      rw_crapprg cr_crapprg%ROWTYPE;

      -- Verifica se esta em execucao
      CURSOR cr_session(pr_cdcooper IN crapcop.cdcooper%TYPE) IS  --> Codigo da cooperativa
      SELECT 1
        FROM v$session 
       WHERE module IN ('PC_CRPS001','PC_CRPS008')
         AND action = pr_cdcooper;

    BEGIN
      -- Busca o indicador estado de crise
      vr_flestcri := TABE0001.fn_busca_dstextab(pr_cdcooper => 0
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'ESTCRISE'
                                               ,pr_tpregist => 0);
      -- Se estiver setado como estado de crise
      IF vr_flestcri = 'S' THEN
        pr_inestcri := 1; -- Estado de crise
      ELSE
        pr_inestcri := 0; -- Nao esta em estado de crise
      END IF;

      -- Se for para verificar no processo os programas CRPS0001 e CRPS0008
      IF pr_flproces = 'S' THEN

        -- Criar documento XML
        dbms_lob.createtemporary(vr_clobxmlc, TRUE);
        dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);

        -- Insere o cabe�alho do XML 
        GENE0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');

        -- Listagem das cooperativas
        FOR rw_crapcop IN cr_crapcop LOOP
          -- Seta a cooperativa
          vr_cdcooper := rw_crapcop.cdcooper;

          OPEN  BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
          FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
          CLOSE BTCH0001.cr_crapdat;

          -- Seta como sem estado de crise
          vr_inestcri := 0;
          vr_dtintegr := rw_crapdat.dtmvtolt;

          -- Se estiver setado como estado de crise
          IF vr_flestcri = 'S' THEN
            -- Seta como crise
            vr_inestcri := 1;

            -- Se estiver rodando o processo
            IF rw_crapdat.inproces > 1 THEN
              -- Seta a proxima data              
              vr_dtintegr := rw_crapdat.dtmvtopr;

              -- Busca o programa que calcula o saldo diario
              OPEN  cr_crapprg(vr_cdcooper, 'CRPS001');
              FETCH cr_crapprg INTO rw_crapprg;
              CLOSE cr_crapprg;
              -- Verifica se o programa rodou
              IF rw_crapprg.inctrprg = 2 THEN

                -- Busca o programa que Atualiza mensalmente os saldos
                OPEN  cr_crapprg(vr_cdcooper, 'CRPS008');
                FETCH cr_crapprg INTO rw_crapprg;
                CLOSE cr_crapprg;
                -- Verifica se o programa rodou
                IF rw_crapprg.inctrprg = 2 THEN

                  -- Verifica se esta em execucao
                  OPEN cr_session(vr_cdcooper);
                  -- Se nao encontrou
                  IF cr_session%NOTFOUND THEN
                    vr_inestcri := 2; -- Estado de crise
                  END IF;
                  CLOSE cr_session;

                END IF;

              END IF;

            END IF;

          END IF;

          -- Montar XML com registros
          GENE0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                                 ,pr_texto_completo => vr_xml_temp 
                                 ,pr_texto_novo     => '<coop>'
                                                    || '  <cdcooper>' || vr_cdcooper || '</cdcooper>'
                                                    || '  <dtintegr>' || TO_CHAR(vr_dtintegr, 'dd/mm/rrrr') || '</dtintegr>'
                                                    || '  <inestcri>' || vr_inestcri || '</inestcri>'
                                                    || '</coop>');

        END LOOP;

        -- Encerrar a tag raiz 
        GENE0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</raiz>' 
                               ,pr_fecha_xml      => TRUE);

        -- Seta o CLOB
        pr_clobxmlc := vr_clobxmlc;

        -- Liberando a memoria alocada para o CLOB
        dbms_lob.close(vr_clobxmlc);
        dbms_lob.freetemporary(vr_clobxmlc);

      END IF;

    END;
  END pc_estado_crise;
  
END sspb0001;
/
