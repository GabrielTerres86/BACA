CREATE OR REPLACE PACKAGE CECRED."LIMI0001" AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : LIMI0001
  --  Sistema  : Rotinas referentes ao limite de credito
  --  Sigla    : LIMI
  --  Autor    : James Prust Junior
  --  Data     : Dezembro - 2014.                   Ultima atualizacao: 13/03/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente ao limite de credito

  -- Alteracoes:     11/08/2016 - Inclusão de parâmetros para limite de desconto de cheque.
  --                 (Linhares - Projeto 300)
  --
  --                 17/08/2016 - Inclusão de rotina para renovação de limite de cheque.
  --                 (Linhares - Projeto 300)
  --
  --                 08/08/2017 - Melhoria 438 - Majoracao automatica de limite de credito
  --                              Heitor (Mouts)
  --
  --                 05/02/2018 - Adicionados campos novos (qtcarpag e qtaltlim) - (Luis Fernando - GFT)
  --
  --                 13/03/2018 - Inclusão da Procedure pc_renovar_lim_desc_titulo (Leonardo Oliveira - GFT)
  --
  --                 16/03/2018 - Inclusão do parâmetro de input 'crapldc' na procedure pc_renovar_lim_desc_titulo (Leonardo Oliveira - GFT)
  --
  --                 13/03/2018 - Inclusão de novo campo (Quantidade de Meses do novo limite após o cancelamento)
  --                              Diego Simas (AMcom)
  --
  --                 27/04/2018 - Adicionados campos de indicador de cancelamento automatico por inadimplencia, e, campo de qtde de dias para cancelamento por inadimplencia
  --                            Marcel (AMcom)
  --
  --                 23/08/2018 - Alteraçao na pc_renovar_lim_desc_titulo: Registrar a renovação na tabela de histórico de alteraçao
  --                              de contrato de limite (Andrew Albuquerque - GFT)
  --
  --                 20/05/2019 - Inclusão de campos RATING na procedure pc_busca_limite_conta (AMcom - Mario)
  --
  ---------------------------------------------------------------------------------------------------------------
  --> Armazenar dados do contrato de limite (antigo b1wge0019tt.i - tt-dados-ctr)
  TYPE typ_rec_dados_ctr
       IS RECORD (nmextcop crapcop.nmextcop%TYPE,
                  nmrescop crapcop.nmrescop%TYPE,
                  nrdocnpj VARCHAR2(50),
                  dsendcop VARCHAR2(1000),
                  nrdconta crapass.nrdconta%TYPE,
                  nmprimtl crapass.nmprimtl%TYPE,
                  inpessoa crapass.inpessoa%TYPE,
                  dsendass VARCHAR2(1000),
                  cdagenci crapass.cdagenci%TYPE,
                  cdageori craplim.cdageori%TYPE,
                  nmcidpac crapage.nmcidade%TYPE,
                  nrctrlim craplim.nrctrlim%TYPE,
                  dsctrlim VARCHAR2(100),
                  vllimite craplim.vllimite%TYPE,
                  qtdiavig craplim.qtdiavig%TYPE,
                  dtinivig craplim.dtinivig%TYPE,
                  dtfimvig craplim.dtfimvig%TYPE,
                  dtrenova craplim.dtrenova%TYPE,
                  cddlinha craplim.cddlinha%TYPE,
                  dsencfin VARCHAR2(1000),
                  dsvllimi VARCHAR2(1000),
                  dsemsctr VARCHAR2(1000),
                  nmoperad VARCHAR2(1000),
                  ddmvtolt VARCHAR2(100),
                  aamvtolt VARCHAR2(100),
                  dsdtmvto VARCHAR2(1000),
                  dsvlnpr1 VARCHAR2(1000),
                  dsmesref VARCHAR2(1000),
                  dsdmoeda VARCHAR2(10),
                  txcetano NUMBER,
                  txcetmes NUMBER,
                  nrgarope craplim.nrgarope%TYPE,
                  nrinfcad craplim.nrinfcad%TYPE,
                  nrliquid craplim.nrliquid%TYPE,
                  nrpatlvr craplim.nrpatlvr%TYPE,
                  vltotsfn craplim.vltotsfn%TYPE,
                  perfatcl crapjfn.perfatcl%TYPE,
                  nrcpfcgc VARCHAR2(100),
                  nrdrgass VARCHAR2(100));

  TYPE typ_tab_dados_ctr IS TABLE OF typ_rec_dados_ctr
       INDEX BY PLS_INTEGER;

  -- Armazenar dados dos representantes/socios do cooperado antigo tt-repres-ctr
  TYPE typ_rec_repres_ctr
       IS RECORD (nmrepres crapavt.nmdavali%TYPE,
                  nrcpfrep VARCHAR2(100),
                  dsdocrep crapavt.nrdocava%TYPE,
                  cdoedrep tbgen_orgao_expedidor.cdorgao_expedidor%TYPE);

  TYPE typ_tab_repres_ctr IS TABLE OF typ_rec_repres_ctr
    INDEX BY PLS_INTEGER;

  --> Armqzenar dados do avalista antigo tt-avais-ctr
  TYPE typ_rec_avais_ctr
       IS RECORD (nmdavali crapavt.nmdavali%TYPE,
                  dsdocava VARCHAR2(100),
                  nmconjug crapavt.nmconjug%TYPE,
                  nrcpfcjg VARCHAR2(100),
                  dsdoccjg VARCHAR2(100),
                  cpfavali VARCHAR2(100),
                  dsendava VARCHAR2(1000),
          nrdconta crapass.nrdconta%TYPE
       );
  TYPE typ_tab_avais_ctr IS TABLE OF typ_rec_avais_ctr
       INDEX BY PLS_INTEGER;


  -- Rotina referente a consulta da tela CADLIM
  PROCEDURE pc_tela_cadlim_consultar(pr_inpessoa IN craprli.inpessoa%TYPE --> Codigo do tipo de pessoa
                                    ,pr_flgdepop IN INTEGER               --> Flag para verificar o departamento do operador
                                    ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                    ,pr_tplimite IN INTEGER               --> Tipo de limite (1 - Limite de credito / 2 - Limite de desconto de cheques / 3 - Lim. Desc. Titulo )
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina referente a alteracao da tela CADLIM
  PROCEDURE pc_tela_cadlim_alterar(pr_inpessoa IN craprli.inpessoa%TYPE --> Codigo do tipo de pessoa
                                  ,pr_vlmaxren IN craprli.vlmaxren%TYPE --> Valor Maximo para renovacao do limite
                                  ,pr_nrrevcad IN craprli.nrrevcad%TYPE --> Numero de meses da revisao cadastral
                                  ,pr_qtmincta IN craprli.qtmincta%TYPE --> Tempo Minimo de conta
                                  ,pr_qtdiaren IN craprli.qtdiaren%TYPE --> Periodo Maximo de dias para renovacao
                                  ,pr_qtmaxren IN craprli.qtmaxren%TYPE --> Quantidade maxima de renovacao
                                  ,pr_qtdiaatr IN craprli.qtdiaatr%TYPE --> Quantidade de dias de atraso de emprestimo
                                  ,pr_qtatracc IN craprli.qtatracc%TYPE --> Quantidade de dias de atraso em conta corrente
                                  ,pr_dssitdop IN craprli.dssitdop%TYPE --> Situacoes que englobam a operacao
                                  ,pr_dsrisdop IN craprli.dsrisdop%TYPE --> Riscos que englobam a operacao
                                  ,pr_tplimite IN craprli.tplimite%TYPE --> Tipo de limite de crédito
                                  ,pr_pcliqdez IN craprli.pcliqdez%TYPE --> Percentual mínimo de liquidez
                                  ,pr_qtdialiq IN craprli.qtdialiq%TYPE --> Quantidade de dias para calculo do percentual liquidez
                                  ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                  ,pr_qtcarpag IN craprli.qtcarpag%TYPE --> Contem o periodo de carencia de pagamento
                                  ,pr_qtaltlim IN craprli.qtaltlim%TYPE --> Contem o periodo de alteracao de limites rejeitados
                  ,pr_qtmeslic IN craprli.qtmeslic%TYPE --> Quantidade de Meses do novo limite após o cancelamento
                                  ,pr_cnauinad IN craprli.cnauinad%TYPE --> indicador de cancelamento automatico por inadimplencia
                                  ,pr_qtdiatin IN craprli.qtdiatin%TYPE --> Quantidade de dias de atraso para cancelamento por ina
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina referente a renovacao manual do limite de credito
  PROCEDURE pc_renovar_limite_cred_manual(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                         ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                         ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                         ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

  -- Rotina para geração do contrato de limite de credito
  PROCEDURE pc_impres_contrato_limite(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo Movimento
                                     ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo
                                     ,pr_idimpres IN INTEGER                --> Indicador de impresao
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_dsiduser IN VARCHAR2               --> id do usuario
                                     ,pr_flgimpnp IN INTEGER                --> indica se deve gerar nota promissoria(0-nao 1-sim)
                                     ,pr_flgemail IN INTEGER                --> Indicador de envia por email (0-nao, 1-sim)
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2             --> Retornar quantidad de registros
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

  --> Rotina para geração do contrato de limite de credito  - Ayllos Web
  PROCEDURE pc_impres_contrato_limite_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
                                         ,pr_idseqttl   IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                         ,pr_idimpres   IN INTEGER                --> Indicador de impresao
                                         ,pr_nrctrlim   IN craplim.nrctrlim%TYPE  --> Contrato
                                         ,pr_dsiduser   IN VARCHAR2               --> id do usuario
                                         ,pr_flgimpnp   IN INTEGER                --> indica se deve gerar nota promissoria(0-nao 1-sim)
                                         ,pr_flgemail   IN INTEGER                --> Indicador de envia por email (0-nao, 1-sim)
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo

  -- Rotina referente a renovacao manual do limite de desconto de cheque
  PROCEDURE pc_renovar_lim_desc_cheque(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite IN craplim.vllimite%TYPE --> Valor Limite de Desconto
                                      ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                      ,pr_idorigem IN INTEGER               --> Identificador de Origem
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Rotina referente ao desbloqueio para inclusao de novos borderos
  PROCEDURE pc_desblq_inclusao_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do Caixa
                                      ,pr_cdoperad IN craplgm.cdoperad%TYPE --> Código do operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Rotina referente a consulta de ultimas alteracoes da tela ATENDA
  PROCEDURE pc_ultimas_alteracoes(pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
  PROCEDURE pc_ultima_majoracao(pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina referente a renovacao manual do limite de desconto de titulo
  PROCEDURE pc_renovar_lim_desc_titulo(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite IN craplim.vllimite%TYPE --> Valor Limite de Desconto
                                      ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                      ,pr_cddlinha IN crapldc.cddlinha%TYPE --> Código da Linha
                                      ,pr_idorigem IN INTEGER               --> Identificador de Origem
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  PROCEDURE pc_busca_limite_conta(pr_nrdconta IN craplim.nrdconta%TYPE --> Numero da conta
                                  ,
                                   pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,
                                   pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,
                                   pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,
                                   pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,
                                   pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,
                                   pr_des_erro OUT VARCHAR2);

   PROCEDURE pc_busca_dados_lim_pf(pr_nrdconta IN craplim.nrdconta%TYPE --> Numero da conta
                                  ,
                                   pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,
                                   pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,
                                   pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,
                                   pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,
                                   pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,
                                   pr_des_erro OUT VARCHAR2);


   PROCEDURE pc_busca_dados_lim_pj(pr_nrdconta IN craplim.nrdconta%TYPE --> Numero da conta
                                  ,
                                   pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,
                                   pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,
                                   pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,
                                   pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,
                                   pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,
                                   pr_des_erro OUT VARCHAR2);

END LIMI0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED."LIMI0001" AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : LIMI0001
  --  Sistema  : Rotinas referentes ao limite de credito
  --  Sigla    : LIMI
  --  Autor    : James Prust Junior
  --  Data     : Dezembro - 2014.                   Ultima atualizacao: 28/05/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente ao limite de credito

  -- Alteracoes: 13/11/2015 - Incluido o comando upper para os cursores que fazem
  --                          comparacao com o campo cdoperad da tabela crapope
  --                          (Tiago SD339476)
  --
  --             11/08/2016 - Inclusão de parâmetros para limite de desconto de cheque.
  --                          (Linhares - Projeto 300)
  --
  --             17/08/2016 - Inclusão de rotina para renovação de limite de cheque.
  --                          (Linhares - Projeto 300)
  --
  --             03/10/2017 - Imprimir conta quando o avalista for cooperado
  --                          Junior (Mouts) - Chamado 767055
  --
  --             14/11/2017 - Incluido retorno do operador na proc pc_ultimas_alteracoes
  --                          para a nova coluna ultimas alterações do limite de credito
  --                          Chamado 791852 (Mateus Z - Mouts)
  --
  --             13/03/2018 - Inclusão de novo campo (Quantidade de Meses do novo limite após o cancelamento)
  --                          Diego Simas (AMcom)
  --
  --             23/08/2018 - Alteraçao na pc_renovar_lim_desc_titulo: Registrar a renovação na tabela de histórico de alteraçao
  --                          de contrato de limite (Andrew Albuquerque - GFT)
  --
  --             05/06/2019 - Inclusão de parametro RATING_RENOVACAO_ATIVO (Mario - AMcom)
  --
  --             13/05/2019 - Alterado pc_ultimas_alteracoes para nos casos de CANCELADOS buscar o operador baseado na cdopeexc
  --                          no casos em que o campo nao estiver vazio PRJ 438 (Mateus Z - Mouts)
  --
  --             28/05/2019 - Alterado pc_carrega_dados_avais para trazer s/n no numero de endereço do avalista terceiro quando 
  --                          não estiver preenchido e trazer dsendres##2 caso o nmbairro estiver vazio. PRJ 438 (Mateus Z - Mouts)
  --
  --             28/06/2019 - Alterado pc_ultimas_alteracoes para trazer o motivo 'Cancelado automaticamente por inadimplência'. 
  --                          PRJ 438 - (Mateus Z / Mouts)
  --
  --             16/08/2019 - P450 - Adicionado na pc_renovar_lim_desc_titulo a solicitação da busca do rating 
  --                          na IBRATAN via pela pc_solicitar_rating_motor
  --                          (Luiz Otavio Olinger Momm - AMCOM)
  --
  --             16/08/2019 - P450 - Adicionado na pc_renovar_lim_desc_cheque a solicitação da busca do rating 
  --                          na IBRATAN via pela pc_solicitar_rating_motor
  --                          (Luiz Otavio Olinger Momm - AMCOM)
  --
  --             16/08/2019 - P450 - Adicionado na pc_renovar_limite_cred_manual a solicitação da busca do rating 
  --                          na IBRATAN via pela pc_solicitar_rating_motor
  --                          (Luiz Otavio Olinger Momm - AMCOM)
  ---------------------------------------------------------------------------------------------------------------
  PROCEDURE pc_tela_cadlim_consultar(pr_inpessoa IN craprli.inpessoa%TYPE --> Codigo do tipo de pessoa
                                    ,pr_flgdepop IN INTEGER               --> Flag para verificar o departamento do operador
                                    ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                    ,pr_tplimite IN INTEGER               --> Tipo de limite (1 - Limite de credito / 2 - Limite de desconto de cheques / 3 - Lim. Desc. Titulo )
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_cadlim_consultar
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Dezembro/14.                    Ultima atualizacao: 13/03/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Consultar as regras do limite de credito.

     Observacao: -----
     Alteracoes:
                 25/11/2016 - Alteração para que o fonte realize a avaliação do departamento
                              pelo campo CDDEPART ao invés do DSDEPART. (Renato Darosci - Supero)

                 11/08/2016 - Inclusão do parâmetro pr_tplmite para filtro por tipo de limite
                            - Inclusão dos campos pcliqdez e qtdialiq na consulta
                              (Linhares - Projeto 300)

                 05/02/2018 - Adicionados campos novos (qtcarpag e qtaltlim) - (Luis Fernando - GFT)

         13/03/2018 - Inclusão de novo campo (Quantidade de Meses do novo limite após o cancelamento)
                              Diego Simas (AMcom)

                 27/04/2018 - Adicionados campos de indicador de cancelamento automatico por inadimplencia, e, campo de qtde de dias para cancelamento por inadimplencia
                              Marcel (AMcom)
     ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_craprli(pr_cdcooper IN craprli.cdcooper%TYPE
                       ,pr_inpessoa IN craprli.inpessoa%TYPE
                       ,pr_tplimite IN craprli.tplimite%TYPE) IS
        SELECT vlmaxren,
               nrrevcad,
               qtmincta,
               qtdiaren,
               qtmeslic,
               cnauinad,
               qtdiatin,
               qtmaxren,
               qtdiaatr,
               qtatracc,
               dssitdop,
               dsrisdop,
               pcliqdez,
               qtdialiq,
               qtcarpag,
               qtaltlim
          FROM craprli
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa
           AND tplimite = pr_tplimite;

      rw_craprli cr_craprli%ROWTYPE;

      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT cddepart
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND upper(crapope.cdoperad) = upper(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Condicao para verificar se olha o departamento do operador
      IF pr_flgdepop = 1 THEN

        -- Buscar Dados do Operador
        OPEN cr_crapope (pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad);
        FETCH cr_crapope INTO rw_crapope;
        -- Verifica se a retornou registro
        IF cr_crapope%NOTFOUND THEN
          CLOSE cr_crapope;
          vr_cdcritic := 67;
          vr_dscritic := NULL;
          RAISE vr_exc_saida;
        ELSE
          -- Apenas Fecha o Cursor
          CLOSE cr_crapope;
        END IF;

        -- Somente o departamento credito irá ter acesso para alterar as informacoes
        IF rw_crapope.cddepart NOT IN (14,20) THEN
          vr_cdcritic := 36;
          vr_dscritic := NULL;
          RAISE vr_exc_saida;
        END IF;

      END IF; /* END IF pr_flgdepop */

      -- Cursor com os dados da Regra
      OPEN cr_craprli(pr_cdcooper => vr_cdcooper
                     ,pr_inpessoa => pr_inpessoa
                     ,pr_tplimite => pr_tplimite);
      FETCH cr_craprli
       INTO rw_craprli;
      -- Se nao encontrar
      IF cr_craprli%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_craprli;
        vr_dscritic := 'Regra nao encontrada.';
        RAISE vr_exc_saida;
      ELSE
        -- Fecha o cursor
        CLOSE cr_craprli;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlmaxren', pr_tag_cont => rw_craprli.vlmaxren, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrrevcad', pr_tag_cont => rw_craprli.nrrevcad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtmincta', pr_tag_cont => rw_craprli.qtmincta, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiaren', pr_tag_cont => rw_craprli.qtdiaren, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtmeslic', pr_tag_cont => rw_craprli.qtmeslic, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cnauinad', pr_tag_cont => rw_craprli.cnauinad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiatin', pr_tag_cont => rw_craprli.qtdiatin, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtmaxren', pr_tag_cont => rw_craprli.qtmaxren, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiaatr', pr_tag_cont => rw_craprli.qtdiaatr, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtatracc', pr_tag_cont => rw_craprli.qtatracc, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dssitdop', pr_tag_cont => rw_craprli.dssitdop, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dsrisdop', pr_tag_cont => rw_craprli.dsrisdop, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'pcliqdez', pr_tag_cont => rw_craprli.pcliqdez, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdialiq', pr_tag_cont => rw_craprli.qtdialiq, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtcarpag', pr_tag_cont => rw_craprli.qtcarpag, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtaltlim', pr_tag_cont => rw_craprli.qtaltlim, pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em LIMI0001.pc_tela_cadlim_alterar: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_tela_cadlim_consultar;

  -- Rotina referente a alteracao da tela CADLIM
  PROCEDURE pc_tela_cadlim_alterar(pr_inpessoa IN craprli.inpessoa%TYPE --> Codigo do tipo de pessoa
                                  ,pr_vlmaxren IN craprli.vlmaxren%TYPE --> Valor Maximo para renovacao do limite
                                  ,pr_nrrevcad IN craprli.nrrevcad%TYPE --> Numero de meses da revisao cadastral
                                  ,pr_qtmincta IN craprli.qtmincta%TYPE --> Tempo Minimo de conta
                                  ,pr_qtdiaren IN craprli.qtdiaren%TYPE --> Periodo Maximo de dias para renovacao
                                  ,pr_qtmaxren IN craprli.qtmaxren%TYPE --> Quantidade maxima de renovacao
                                  ,pr_qtdiaatr IN craprli.qtdiaatr%TYPE --> Quantidade de dias de atraso de emprestimo
                                  ,pr_qtatracc IN craprli.qtatracc%TYPE --> Quantidade de dias de atraso em conta corrente
                                  ,pr_dssitdop IN craprli.dssitdop%TYPE --> Situacoes que englobam a operacao
                                  ,pr_dsrisdop IN craprli.dsrisdop%TYPE --> Riscos que englobam a operacao
                                  ,pr_tplimite IN craprli.tplimite%TYPE --> Tipo de limite de crédito
                                  ,pr_pcliqdez IN craprli.pcliqdez%TYPE --> Percentual mínimo de liquidez
                                  ,pr_qtdialiq IN craprli.qtdialiq%TYPE --> Quantidade de dias para calculo do percentual liquidez
                                  ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                  ,pr_qtcarpag IN craprli.qtcarpag%TYPE --> Contem o periodo de carencia de pagamento
                                  ,pr_qtaltlim IN craprli.qtaltlim%TYPE --> Contem o periodo de alteracao de limites rejeitados
                                  ,pr_qtmeslic IN craprli.qtmeslic%TYPE --> Quantidade de Meses do novo limite após o cancelamento
                                  ,pr_cnauinad IN craprli.cnauinad%TYPE --> indicador de cancelamento automatico por inadimplencia
                                  ,pr_qtdiatin IN craprli.qtdiatin%TYPE --> Quantidade de dias de atraso para cancelamento por inadimplencia
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_cadlim_alterar
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Dezembro/14.                    Ultima atualizacao: 13/03/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Alterar as regras do limite de credito.

     Observacao: -----
     Alteracoes:
                 25/11/2016 - Alteração para que o fonte realize a avaliação do departamento
                              pelo campo CDDEPART ao invés do DSDEPART. (Renato Darosci - Supero)

                 11/08/2016 - Inclusão do parâmetro pr_tplmite para filtro por tipo de limite
                            - Inclusão dos parâmetros pr_pcliqdez e pr_qtdialiq para busca e atualização
                 (Linhares - Projeto 300)

                 05/02/2018 - Adicionados campos novos (qtcarpag e qtaltlim) - (Luis Fernando - GFT)


                 13/03/2018 - Inclusão de novo campo (Quantidade de Meses do novo limite após o cancelamento)
                              Diego Simas (AMcom)

     ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_craprli(pr_cdcooper IN craprli.cdcooper%TYPE
                       ,pr_inpessoa IN craprli.inpessoa%TYPE) IS
        SELECT vlmaxren,
               nrrevcad,
               qtmincta,
               qtdiaren,
               qtmeslic,
               cnauinad,
               qtdiatin,
               qtmaxren,
               qtdiaatr,
               qtatracc,
               dssitdop,
               dsrisdop,
               pcliqdez,
               qtdialiq,
               qtcarpag,
               qtaltlim
          FROM craprli
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa
           AND tplimite = pr_tplimite;

      rw_craprli cr_craprli%ROWTYPE;

      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT cddepart
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND upper(crapope.cdoperad) = upper(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Variaveis de log
      vr_dtaltcad      VARCHAR2(20);          --> Data de alteracao do cadastro
      vr_tpaltcad      VARCHAR2(50);          --> Tipo do cadastro da alteracao
      vr_dsclinha      VARCHAR2(4000);        --> Linha a ser inserida no LOG
      vr_dsdireto      VARCHAR2(400);         --> Diretório do arquivo de LOG
      vr_utlfileh      utl_file.file_type;    --> Handle para arquivo de LOG

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Buscar Dados do Operador
      OPEN cr_crapope (pr_cdcooper => vr_cdcooper
                      ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      -- Verifica se a retornou registro
      IF cr_crapope%NOTFOUND THEN
        CLOSE cr_crapope;
        vr_cdcritic := 67;
        vr_dscritic := NULL;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_crapope;
      END IF;

      -- Somente o departamento credito irá ter acesso para alterar as informacoes
      IF rw_crapope.cddepart NOT IN (14,20) THEN
        vr_cdcritic := 36;
        vr_dscritic := NULL;
        RAISE vr_exc_saida;
      END IF;

      -- Cursor com os dados da Regra
      OPEN cr_craprli(pr_cdcooper => vr_cdcooper
                     ,pr_inpessoa => pr_inpessoa);
      FETCH cr_craprli
       INTO rw_craprli;
      -- Se nao encontrar
      IF cr_craprli%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_craprli;
        vr_dscritic := 'Regra nao encontrada.';
        RAISE vr_exc_saida;
      ELSE
        -- Fecha o cursor
        CLOSE cr_craprli;
      END IF;

      vr_dtaltcad := to_char(SYSDATE,'dd/mm/yyyy hh24:mi:ss');

      IF pr_tplimite = 2 THEN
        vr_tpaltcad := ' --> Limite Desconto de Cheque';
      ELSIF pr_tplimite = 3 THEN
        vr_tpaltcad := ' --> Limite Desconto de Titulo';
      ELSE
        vr_tpaltcad := ' --> Limite de Credito';
      END IF;

      IF pr_inpessoa = 1 THEN
        vr_tpaltcad := vr_tpaltcad || ' - PF';
      ELSE
        vr_tpaltcad := vr_tpaltcad || ' - PJ';
      END IF;

      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => '/log');

      -- Abrir arquivo em modo de adição
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto
                              ,pr_nmarquiv => 'cadlim.log'
                              ,pr_tipabert => 'A'
                              ,pr_utlfileh => vr_utlfileh
                              ,pr_des_erro => vr_dscritic);

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF rw_craprli.vlmaxren <> pr_vlmaxren THEN
        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Valor Maximo do Limite de '
                                   || rw_craprli.vlmaxren || ' para ' || pr_vlmaxren;
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;

      IF rw_craprli.nrrevcad <> pr_nrrevcad THEN
        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Revisao Cadastral de '
                                   || rw_craprli.nrrevcad || ' para ' || pr_nrrevcad;
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;

      IF rw_craprli.qtmincta <> pr_qtmincta THEN
        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Tempo de Conta de '
                                   || rw_craprli.qtmincta || ' para ' || pr_qtmincta;
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;

      IF rw_craprli.qtdiaren <> pr_qtdiaren THEN
        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Tentativas Diarias de Renovacao de '
                                   || rw_craprli.qtdiaren || ' para ' || pr_qtdiaren;
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;

      IF rw_craprli.qtmeslic <> pr_qtmeslic THEN
        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Inclusão de Novo Limite após o cancelamento de '
                                   || rw_craprli.qtmeslic || ' para ' || pr_qtmeslic;
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;

      IF rw_craprli.cnauinad <> pr_cnauinad THEN
        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o indicador de Cancelamento automático por inadimplência  '
                                   || rw_craprli.cnauinad || ' para ' || pr_cnauinad;
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;

      IF rw_craprli.qtdiatin <> pr_qtdiatin THEN
        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo qtde de dias para Cancelamento automático por inadimplência  '
                                   || rw_craprli.qtdiatin || ' para ' || pr_qtdiatin;
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;

      IF rw_craprli.dssitdop <> pr_dssitdop THEN
        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Situacao da Conta de '
                                   || rw_craprli.dssitdop || ' para ' || pr_dssitdop;

        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;

      IF rw_craprli.qtmaxren <> pr_qtmaxren THEN
        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Qtde. Maxima de Renovacoes de '
                                   || rw_craprli.qtmaxren || ' para ' || pr_qtmaxren;

        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;

      IF rw_craprli.qtdiaatr <> pr_qtdiaatr THEN
        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Emprestimo em Atraso de '
                                   || rw_craprli.qtdiaatr || ' para ' || pr_qtdiaatr;

        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;

      IF rw_craprli.qtatracc <> pr_qtatracc THEN
        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Conta Corrente em Atraso de '
                                   || rw_craprli.qtatracc || ' para ' || pr_qtatracc;

        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;

      IF rw_craprli.dsrisdop <> pr_dsrisdop THEN
        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Risco da Conta de '
                                   || rw_craprli.dsrisdop || ' para ' || pr_dsrisdop;

        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;


      IF rw_craprli.pcliqdez <> pr_pcliqdez THEN

        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Percentual Minimo de Liquidez de '
                                   || rw_craprli.pcliqdez || ' para ' || pr_pcliqdez;

        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);

      END IF;


      IF rw_craprli.qtdialiq <> pr_qtdialiq THEN

        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Quantidade de Dias para Calculo Percentual Liquidez de '
                                   || rw_craprli.qtdialiq || ' para ' || pr_qtdialiq;

        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);

      END IF;

      IF rw_craprli.qtcarpag <> pr_qtcarpag THEN

        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Periodo de carencia de pagamento '
                                   || rw_craprli.qtcarpag || ' para ' || pr_qtcarpag;

        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);

      END IF;

      IF rw_craprli.qtaltlim <> pr_qtaltlim THEN

        vr_dsclinha := vr_dtaltcad || vr_tpaltcad
                                   || ' -->  Operador ' || vr_cdoperad
                                   || ' alterou o campo Periodo de alteracao de limites rejeitados '
                                   || rw_craprli.qtaltlim || ' para ' || pr_qtaltlim;

        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);

      END IF;

      -- Fechar arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);

      BEGIN
        UPDATE craprli SET
               vlmaxren = pr_vlmaxren,
               nrrevcad = pr_nrrevcad,
               qtmincta = pr_qtmincta,
               qtdiaren = pr_qtdiaren,
               qtmeslic = pr_qtmeslic,
               cnauinad = pr_cnauinad,
               qtdiatin = pr_qtdiatin,
               qtmaxren = pr_qtmaxren,
               qtdiaatr = pr_qtdiaatr,
               qtatracc = pr_qtatracc,
               dssitdop = pr_dssitdop,
               dsrisdop = pr_dsrisdop,
               pcliqdez = pr_pcliqdez,
               qtdialiq = pr_qtdialiq,
               qtcarpag = pr_qtcarpag,
               qtaltlim = pr_qtaltlim
         WHERE cdcooper = vr_cdcooper
           AND inpessoa = pr_inpessoa
           AND tplimite = pr_tplimite;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar a regra: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em LIMI0001.pc_tela_cadlim_alterar: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_tela_cadlim_alterar;

  -- Rotina referente a renovacao manual do limite de credito
  PROCEDURE pc_renovar_limite_cred_manual(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                         ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                         ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                         ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
  BEGIN
    /* .............................................................................

     Programa: pc_renovar_manual
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Dezembro/14.                    Ultima atualizacao: 11/08/2016

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina referente a renovacao manual do limite de credito
     Alteracoes:  11/08/2016 - Incluído filtro tplimite para Limite de Crédito
                               (Linhares Projeto 300)

                  03/2019      Incluido rati0003.pc_grava_rating_operacao proj 450 rating 
                   
                  28/05/2019 - Proj 450 - Ajuste para gravar o rating como vencido (Heckmann - AMcom)

                  16/08/2019 - P450 - Adicionado na renovação a solicitação da busca do rating 
                               na IBRATAN via pela pc_solicitar_rating_motor
                               (Luiz Otavio Olinger Momm - AMCOM)
                               
                  21/08/2019 - P450 - Adicionado regra de endividamento e efetivação nas
                               renovações (Luiz Otavio Olinger Momm)

    ..............................................................................*/

  DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis de Log de Alteracao
    vr_flgctitg crapalt.flgctitg%TYPE;
    vr_dsaltera LONG;

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Parametro de Flag Rating Renovacao Ativo: 0-Não Ativo, 1-Ativo
    vr_flg_Rating_Renovacao_Ativo    NUMBER := 0;

    -- Cursor Limite de cheque especial
    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE     --> Código da Cooperativa
                     ,pr_nrdconta IN craplim.nrdconta%TYPE     --> Número da Conta
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS --> Número do Contrato

      SELECT craplim.cddlinha,
             craplim.insitlim,
             craplim.qtrenova,
             craplim.dtrenova,
             craplim.vllimite, -- P450
             nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) as dtfimvig
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrlim
         AND craplim.tpctrlim = 1;
    rw_craplim cr_craplim%ROWTYPE;

    -- Cursor Linhas de Credito Rotativo
    CURSOR cr_craplrt (pr_cdcooper IN craplrt.cdcooper%TYPE,
                       pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT craplrt.flgstlcr
        FROM craplrt
       WHERE craplrt.cdcooper = pr_cdcooper AND
             craplrt.cddlinha = pr_cddlinha;
    rw_craplrt cr_craplrt%ROWTYPE;

    -- Cursor Regras do limite de cheque especial
    CURSOR cr_craprli (pr_cdcooper IN craprli.cdcooper%TYPE,
                       pr_inpessoa IN craprli.inpessoa%TYPE) IS
      SELECT qtmaxren
        FROM craprli
       WHERE craprli.cdcooper = pr_cdcooper AND
             craprli.inpessoa = DECODE(pr_inpessoa,3,2,pr_inpessoa)
             AND craprli.tplimite = 1; -- Limite Credito
    rw_craprli cr_craprli%ROWTYPE;

    -- Cursor Associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa,
             nrdctitg,
             flgctitg,
             nrcpfcnpj_base,
             cdagenci
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper AND
             crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor alteracao de cadastro
    CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT crapalt.dsaltera,
             crapalt.rowid
        FROM crapalt
       WHERE crapalt.cdcooper = pr_cdcooper
         AND crapalt.nrdconta = pr_nrdconta
         AND crapalt.dtaltera = pr_dtmvtolt;
    rw_crapalt cr_crapalt%ROWTYPE;


    vr_in_risco_rat INTEGER;
    vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

    -- P450 Valida Endividamento
    vr_strating     NUMBER;
    vr_flgrating    NUMBER;
    vr_vlendivid    craplim.vllimite%TYPE; -- Valor do Endividamento do Cooperado
    vr_vllimrating  craplim.vllimite%TYPE; -- Valor do Parametro Rating (Limite) TAB056
    -- P450 Valida Endividamento

  BEGIN

    --> Buscar Parametro
    vr_flg_Rating_Renovacao_Ativo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                              ,pr_cdcooper => 0
                                                              ,pr_cdacesso => 'RATING_RENOVACAO_ATIVO');

    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');

    -- Consultar o limite de credito
    OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrlim => pr_nrctrlim);
    FETCH cr_craplim INTO rw_craplim;
    -- Verifica se o limite de credito existe
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_dscritic := 'Associado nao possui proposta de limite de credito. Conta: ' || pr_nrdconta || '.Contrato: ' || pr_nrctrlim;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplim;
    END IF;

    -- Verifica a situacao do limite do cheque especial
    IF nvl(rw_craplim.insitlim,0) <> 2 THEN
      vr_dscritic := 'O contrato de limite de credito deve estar ativo.';
      RAISE vr_exc_saida;
    END IF;

    -- Verificacao para saber se jah passou o vencimento do limite para a renovacao
    IF rw_craplim.dtfimvig > pr_dtmvtolt THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao do limite. Contrato nao esta vencido.';
      RAISE vr_exc_saida;
    END IF;

    -- Consulta o limite de credito
    OPEN cr_craplrt(pr_cdcooper => pr_cdcooper,
                    pr_cddlinha => rw_craplim.cddlinha);
    FETCH cr_craplrt INTO rw_craplrt;
    -- Verifica se o limite de credito existe
    IF cr_craplrt%NOTFOUND THEN
      CLOSE cr_craplrt;
      vr_dscritic := 'Linha de Credito nao cadastrada. Linha: ' || rw_craplim.cddlinha;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplrt;
    END IF;

    -- Verifica a situacao do limite do credito
    IF nvl(rw_craplrt.flgstlcr,0) = 0 THEN
      vr_dscritic := 'Linha de credito bloqueada. Nao e possivel efetuar a renovacao. E necessario incluir um novo limite.';
      RAISE vr_exc_saida;
    END IF;

    -- Consulta o Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- Verifica se o limite de credito existe
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado. Conta: ' || pr_nrdconta;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Consulta a regra do limite de cheque especial
    OPEN cr_craprli(pr_cdcooper => pr_cdcooper,
                    pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_craprli INTO rw_craprli;
    -- Verifica se o limite de credito existe
    IF cr_craprli%NOTFOUND THEN
      CLOSE cr_craprli;
      vr_dscritic := 'Regras do Linha de Credito nao cadastrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craprli;
    END IF;

    -- Verificar a quantidade maxima que pode renovar
    IF ((nvl(rw_craprli.qtmaxren,0) > 0) AND (nvl(rw_craplim.qtrenova,0) >= nvl(rw_craprli.qtmaxren,0))) THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao do limite. Incluir novo contrato';
      RAISE vr_exc_saida;
    END IF;

    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper <> 3 AND vr_habrat = 'S') THEN

      -- Verifica processamento do Rating Renovacao
      IF vr_flg_Rating_Renovacao_Ativo = 1 THEN

        /*
        Situacao da proposta na Esteira
        0-Nao enviada
        1-Enviada Analise Automatica
        2-Enviada Analise Manual
        3-Analise Finalizada
        4-Expirado
        
        Muda para Nao enviada para enviar para a Ibratan novamente
        */
        BEGIN
          UPDATE crawlim
             SET insitest = 0
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctrlim = pr_nrctrlim
             AND tpctrlim = 1; -- Limite Credito

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao renovar o limite de titulo de desconto de titulo: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        rati0003.pc_solicitar_rating_motor( pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => pr_nrdconta,
                                            pr_tpctrato => 1, -- Limite Credito
                                            pr_nrctrato => pr_nrctrlim,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_cdagenci => rw_crapass.cdagenci,
                                            pr_dtmvtolt => pr_dtmvtolt,
                                            pr_inpessoa => rw_crapass.inpessoa,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
                                            
        IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic,0) > 0 THEN
          RAISE vr_exc_saida;
        END IF;
        
        /* Validar Status rating */
        RATI0003.pc_busca_status_rating(pr_cdcooper  => pr_cdcooper
                                       ,pr_nrdconta  => pr_nrdconta
                                       ,pr_tpctrato  => 1 -- Limite Credito
                                       ,pr_nrctrato  => pr_nrctrlim
                                       ,pr_strating  => vr_strating
                                       ,pr_flgrating => vr_flgrating
                                       ,pr_cdcritic  => vr_cdcritic
                                       ,pr_dscritic  => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;

        -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
        RATI0003.pc_busca_endivid_param(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_vlendivi => vr_vlendivid
                                       ,pr_vlrating => vr_vllimrating
                                       ,pr_dscritic => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;

        -- Status do rating inválido
        IF vr_flgrating = 0 THEN
          vr_dscritic := 'Contrato não pode ser efetivado porque não há Rating válido.';
          RAISE vr_exc_saida;

        ELSE -- Status do rating válido

          -- Se Endividamento + Contrato atual > Parametro Rating (TAB056)
          IF ((vr_vlendivid) > vr_vllimrating) THEN

            -- Gravar o Rating da operação, efetivando-o
            rati0003.pc_grava_rating_operacao(pr_cdcooper          => pr_cdcooper
                                             ,pr_nrdconta          => pr_nrdconta
                                             ,pr_tpctrato          => 1 -- Limite Credito
                                             ,pr_nrctrato          => pr_nrctrlim
                                             ,pr_dtrating          => pr_dtmvtolt
                                             ,pr_strating          => 4
                                             ,pr_efetivacao_rating => 1 -- Identificar se deve considerar o parâmetro de contingência
                                             --Variáveis para gravar o histórico
                                             ,pr_cdoperad          => pr_cdoperad
                                             ,pr_dtmvtolt          => pr_dtmvtolt
                                             ,pr_valor             => rw_craplim.vllimite
                                             ,pr_rating_sugerido   => NULL
                                             ,pr_justificativa     => 'Renovação de Contrato - Efetivação do Rating'
                                             ,pr_tpoperacao_rating => 2
                                             ,pr_nrcpfcnpj_base    => rw_crapass.nrcpfcnpj_base
                                             --Variáveis de crítica
                                             ,pr_cdcritic          => vr_cdcritic
                                             ,pr_dscritic          => vr_dscritic);

            IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        END IF;
        
      END IF;
      -- Verifica processamento do Rating Renovacao
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

    -- Atualiza os dados do limite de cheque especial
    BEGIN
      UPDATE craplim SET
             dtrenova = pr_dtmvtolt,
             tprenova = 'M',
             dsnrenov = '',
             dtfimvig = pr_dtmvtolt + nvl(qtdiavig,0),
             qtrenova = nvl(qtrenova,0) + 1,
             cdoperad = pr_cdoperad,
             cdopelib = pr_cdoperad
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrctrlim
         AND tpctrlim = 1; -- Limite Credito
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao renovar o limite de credito: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;

    /* Por default fica como 3 */
    vr_flgctitg  := 3;
    vr_dsaltera  := 'Renov. Manual Limite Cred. Ctr: ' || pr_nrctrlim || ',';

    /* Se for conta integracao ativa, seta a flag para enviar ao BB */
    IF trim(rw_crapass.nrdctitg) IS NOT NULL AND rw_crapass.flgctitg = 2 THEN  /* Ativa */
      --Conta Integracao
      vr_flgctitg := 0;
    END IF;

    /* Verifica se jah possui alteracao */
    OPEN cr_crapalt (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_dtmvtolt => pr_dtmvtolt);
    FETCH cr_crapalt INTO rw_crapalt;
    --Verificar se encontrou
    IF cr_crapalt%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapalt;
      -- Altera o registro
      BEGIN
        UPDATE crapalt SET
               crapalt.dsaltera = rw_crapalt.dsaltera || vr_dsaltera,
               crapalt.cdoperad = pr_cdoperad,
               crapalt.flgctitg = vr_flgctitg
         WHERE crapalt.rowid = rw_crapalt.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
          --Sair
          RAISE vr_exc_saida;
      END;
    ELSE
      --Fechar Cursor
      CLOSE cr_crapalt;

      --Inserir Alteracao
      BEGIN
        INSERT INTO crapalt
          (crapalt.nrdconta
          ,crapalt.dtaltera
          ,crapalt.tpaltera
          ,crapalt.dsaltera
          ,crapalt.cdcooper
          ,crapalt.flgctitg
          ,crapalt.cdoperad)
        VALUES
          (pr_nrdconta
          ,pr_dtmvtolt
          ,2
          ,vr_dsaltera
          ,pr_cdcooper
          ,vr_flgctitg
          ,pr_cdoperad);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;

    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral LIMI0001.pc_renovar_limite_cred_manual: ' || SQLERRM;
      ROLLBACK;
    END;

  END pc_renovar_limite_cred_manual;


  PROCEDURE pc_carrega_dados_avais (pr_cdcooper          IN crapcop.cdcooper%TYPE, --> Cooperativa do avalista
                                    pr_nrdconta          IN crapass.nrdconta%TYPE, --> Numero da conta do avalista
                                    pr_nrctrlim          IN craplim.nrctrlim%TYPE, --> Numero do contrato de limite
                  pr_nrvrsctr          IN INTEGER,               --> Versão do relatório
                                    pr_tab_avais_ctr IN OUT typ_tab_avais_ctr,     --> Retorna dados dos avalistas
                                    pr_cdcritic         OUT PLS_INTEGER,           --> Código da crítica
                                    pr_dscritic         OUT VARCHAR2) IS           --> Descrição da crít
  /* .............................................................................

     Programa: pc_carrega_dados_avais
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/16.                    Ultima atualizacao: 27/01/2017

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para buscar dados doa avalistas do contrato de limite de credito
     Alteracoes: 27/01/2017 - Buscar o CPF do avalista e nao do conjuge. (Jaison/Daniel)
                 28/05/2019 - Alterado pc_carrega_dados_avais para trazer s/n no numero de endereço do avalista terceiro quando 
                              não estiver preenchido e trazer dsendres##2 caso o nmbairro estiver vazio.  PRJ 438 (Mateus Z - Mouts)
    ..............................................................................*/

    ---------->> CURSORES <<--------
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl,
             ass.cdagenci,
             ass.inpessoa,
             ass.nrdconta,
             ass.nrdocptl,
             ass.idorgexp,
             ass.tpdocptl,
             ass.cdufdptl

        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --> Buscar conjuge do cooperado
    CURSOR cr_crapcje ( pr_cdcooper crapcje.cdcooper%TYPE,
                        pr_nrdconta crapcje.nrdconta%TYPE )IS
      SELECT cje.nrdconta,
             cje.nrctacje,
             cje.cdcooper,
             cje.nmconjug,
             cje.nrcpfcjg,
             cje.tpdoccje,
             cje.nrdoccje
        FROM crapcje cje
       WHERE cje.cdcooper = pr_cdcooper
         AND cje.nrdconta = pr_nrdconta
         AND cje.idseqttl = 1;
    rw_crapcje cr_crapcje%ROWTYPE;

    --> Busca as informaçoes do titular da conta
    CURSOR cr_crapttl (pr_cdcooper crapcje.cdcooper%TYPE,
                       pr_nrdconta crapcje.nrdconta%TYPE )IS
      SELECT ttl.nrdconta,
             ttl.nmextttl,
             ttl.nrcpfcgc,
             ttl.tpdocttl,
             ttl.nrdocttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1;
    rw_crapttl cr_crapttl%ROWTYPE;

    --> Buscar endereço
    CURSOR cr_crapenc (pr_cdcooper crapcje.cdcooper%TYPE,
                       pr_nrdconta crapcje.nrdconta%TYPE ) IS
      SELECT enc.nrdconta,
             enc.dsendere,
             enc.nrcepend,
             enc.nmbairro,
             enc.nmcidade,
             enc.nrendere,
             enc.cdufende
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.idseqttl = 1
         AND enc.cdseqinc = 1;
    rw_crapenc cr_crapenc%ROWTYPE;

    --> Avalistas que possuem conta na cooperativa
    CURSOR cr_craplin_ava (pr_cdcooper crapavt.cdcooper%TYPE,
                           pr_nrdconta crapavt.nrdconta%TYPE,
                           pr_nrctrlim craplim.nrctrlim%TYPE) IS
    SELECT MAX nrdconta
      FROM craplim
       --> Converter as duas colunas em linha para o for
       UNPIVOT ( MAX FOR conta IN (nrctaav1, nrctaav2) )
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctrlim = pr_nrctrlim;

    --> Buscar avalistas terceiros
    CURSOR cr_crapavt (pr_cdcooper crapavt.cdcooper%TYPE,
                       pr_nrdconta crapavt.nrdconta%TYPE,
                       pr_nrctremp crapavt.nrctremp%TYPE  )IS
      SELECT avt.nrdconta
            ,avt.nmdavali
            ,avt.nrcpfcgc
            ,avt.nmconjug
            ,avt.nrcpfcjg
            ,avt.dsendres##1 dsendres
            ,avt.nrcepend
            ,avt.nrendere
            ,(case when length(avt.nmbairro) > 1 then avt.nmbairro else avt.dsendres##2 end) nmbairro
            ,avt.nmcidade
            ,avt.cdufresd
            ,avt.tpdocava
            ,avt.nrdocava
            ,avt.tpdoccjg
            ,avt.nrdoccjg
        FROM crapavt avt
       WHERE avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrctremp = pr_nrctremp
         AND avt.tpctrato = 3;

    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;

    vr_idxavais       PLS_INTEGER;
    vr_tab_avais_ctr  typ_tab_avais_ctr;

  vr_stsnrcal       BOOLEAN;
  vr_inpessoa       INTEGER;

  BEGIN


    --> Avalistas que possuem conta na cooperativa
    FOR rw_craplin_ava IN  cr_craplin_ava (pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_nrctrlim => pr_nrctrlim) LOOP
      -- Se estiver zerado, pode ir para o proximo
      IF nvl(rw_craplin_ava.nrdconta,0) = 0 THEN
        continue;
      END IF;
      vr_idxavais := vr_tab_avais_ctr.count() + 1;

      --> Buscar conta do cooperado avalista
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => rw_craplin_ava.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%FOUND THEN
        CLOSE cr_crapass;
    vr_tab_avais_ctr(vr_idxavais).nrdconta := rw_craplin_ava.nrdconta;
        vr_tab_avais_ctr(vr_idxavais).nmdavali := rw_crapass.nmprimtl;
        vr_tab_avais_ctr(vr_idxavais).dsdocava := rw_crapass.tpdocptl ||': '|| rw_crapass.nrdocptl;

        IF rw_crapass.inpessoa = 1 THEN

      IF pr_nrvrsctr = 1 THEN
          vr_tab_avais_ctr(vr_idxavais).cpfavali := 'CPF: '|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                                                                        pr_inpessoa => rw_crapass.inpessoa )
                                            ||' '||gene0002.fn_mask_conta(rw_crapass.nrdconta);
          ELSE
       vr_tab_avais_ctr(vr_idxavais).cpfavali := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                         pr_inpessoa => rw_crapass.inpessoa );
      END IF;

          --> Buscar conjuge do cooperado
          OPEN cr_crapcje ( pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => rw_crapass.nrdconta);
          FETCH cr_crapcje INTO rw_crapcje;
          IF cr_crapcje%FOUND THEN
            CLOSE cr_crapcje;
            --> Verificar se existe o numero da conta do conjuge
            IF rw_crapcje.nrctacje > 0 THEN
              --> Busca as informaçoes do titular da conta
              OPEN cr_crapttl ( pr_cdcooper => rw_crapcje.cdcooper,
                                pr_nrdconta => rw_crapcje.nrctacje);
              FETCH cr_crapttl INTO rw_crapttl;
              IF cr_crapttl%FOUND THEN
                CLOSE cr_crapttl;
                vr_tab_avais_ctr(vr_idxavais).nmconjug := rw_crapttl.nmextttl;
        IF pr_nrvrsctr = 1 THEN
                vr_tab_avais_ctr(vr_idxavais).nrcpfcjg := 'CPF: '|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapttl.nrcpfcgc,
                                                                                              pr_inpessoa => 1 );
        ELSE
                   vr_tab_avais_ctr(vr_idxavais).nrcpfcjg := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapttl.nrcpfcgc,
                                                                                       pr_inpessoa => 1 );
        END IF;
                vr_tab_avais_ctr(vr_idxavais).dsdoccjg := rw_crapttl.tpdocttl ||': '|| rw_crapttl.nrdocttl;


              ELSE
                CLOSE cr_crapttl;
              END IF;

            ELSE
              vr_tab_avais_ctr(vr_idxavais).nmconjug := rw_crapcje.nmconjug;
        IF pr_nrvrsctr = 1 THEN
              vr_tab_avais_ctr(vr_idxavais).nrcpfcjg := 'CPF: '|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcje.nrcpfcjg,
                                                                                            pr_inpessoa => 1 );
        ELSE
         vr_tab_avais_ctr(vr_idxavais).nrcpfcjg := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcje.nrcpfcjg,
                                             pr_inpessoa => 1 );
              END IF;
              vr_tab_avais_ctr(vr_idxavais).dsdoccjg := rw_crapcje.tpdoccje ||': '|| rw_crapcje.nrdoccje;
            END IF;

          ELSE
            CLOSE cr_crapcje;
            IF pr_nrvrsctr = 1 THEN
            vr_tab_avais_ctr(vr_idxavais).nmconjug := lpad('_',40,'_');
            vr_tab_avais_ctr(vr_idxavais).nrcpfcjg := 'CPF: ' || lpad('_',35,'_');
            vr_tab_avais_ctr(vr_idxavais).dsdoccjg := 'CI: '  || lpad('_',36,'_');

            END IF;
          END IF;

        ELSE
        IF pr_nrvrsctr = 1 THEN
          vr_tab_avais_ctr(vr_idxavais).cpfavali := 'CNPJ: '|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                                                                         pr_inpessoa => rw_crapass.inpessoa )||' '||gene0002.fn_mask_conta(rw_crapass.nrdconta);

          vr_tab_avais_ctr(vr_idxavais).nmconjug := lpad('_',40,'_');
          vr_tab_avais_ctr(vr_idxavais).nrcpfcjg := 'CPF: ' || lpad('_',35,'_');
          vr_tab_avais_ctr(vr_idxavais).dsdoccjg := 'CI: '  || lpad('_',36,'_');
          ELSE
       vr_tab_avais_ctr(vr_idxavais).cpfavali := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                                                                pr_inpessoa => rw_crapass.inpessoa );
      END IF;

        END IF; --> Fim IF rw_crapass.inpessoa = 1

        --> Buscar endereço do avalista
        OPEN cr_crapenc ( pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => rw_crapass.nrdconta);
        FETCH cr_crapenc INTO rw_crapenc;
        IF cr_crapenc%FOUND THEN
          CLOSE cr_crapenc;

          vr_tab_avais_ctr(vr_idxavais).dsendava := substr(rw_crapenc.dsendere,1,32) || ', ' || to_char(rw_crapenc.nrendere,'fm999G999G999')||', '||
                                                    rw_crapenc.nmbairro || ', ' || gene0002.fn_mask_cep(rw_crapenc.nrcepend) ||' - '||
                                                    rw_crapenc.nmcidade || '/'  || rw_crapenc.cdufende || '.';

        ELSE
          CLOSE cr_crapenc;
        END IF;

      ELSE
        CLOSE cr_crapass;
        IF pr_nrvrsctr = 1 THEN
        vr_tab_avais_ctr(vr_idxavais).nmdavali := '*** NAO CADASTRADO ***';
        vr_tab_avais_ctr(vr_idxavais).cpfavali := 'CPF: '|| lpad('_',35,'_');
        vr_tab_avais_ctr(vr_idxavais).dsdocava := 'CI: ' || lpad('_',36,'_');
        vr_tab_avais_ctr(vr_idxavais).nmconjug := lpad('_',40,'_');
        vr_tab_avais_ctr(vr_idxavais).nrcpfcjg := 'CPF: '|| lpad('_',35,'_');
        vr_tab_avais_ctr(vr_idxavais).dsdoccjg := 'CI: ' || lpad('_',36,'_');
        vr_tab_avais_ctr(vr_idxavais).dsendava := lpad('_',40,'_');
            END IF;

      END IF;
    END LOOP;

     --> Avalistas Terceiros do contrado
    FOR rw_crapavt IN  cr_crapavt (pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctrlim) LOOP

      vr_idxavais := vr_tab_avais_ctr.count() + 1;
    vr_tab_avais_ctr(vr_idxavais).nmdavali := rw_crapavt.nmdavali;

      IF pr_nrvrsctr = 1 THEN
        vr_tab_avais_ctr(vr_idxavais).cpfavali := 'CPF: '|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapavt.nrcpfcgc,
                                                                                      pr_inpessoa => 1 )||' '||gene0002.fn_mask_conta(rw_crapass.nrdconta);
      ELSE
        -- Buscar inpessoa
        gene0005.pc_valida_cpf_cnpj(rw_crapavt.nrcpfcgc
				   ,vr_stsnrcal
				   ,vr_inpessoa);				
        vr_tab_avais_ctr(vr_idxavais).cpfavali := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapavt.nrcpfcgc, 
                                                                            pr_inpessoa => vr_inpessoa );
      END IF;
			
      vr_tab_avais_ctr(vr_idxavais).dsdocava := rw_crapavt.tpdocava ||': '|| rw_crapavt.nrdocava;  
      
      vr_tab_avais_ctr(vr_idxavais).dsendava := substr(rw_crapavt.dsendres,1,32) || ', ' || 
                                                case when rw_crapavt.nrendere > 0 then to_char(rw_crapavt.nrendere,'fm999G999G999') else 's/n' end ||', '||
                                                  rw_crapavt.nmbairro || ', ' || gene0002.fn_mask_cep(rw_crapavt.nrcepend) ||' - '||
                                                  rw_crapavt.nmcidade || '/'  || rw_crapavt.cdufresd || '.';
      
      IF pr_nrvrsctr = 1 THEN								      
        vr_tab_avais_ctr(vr_idxavais).nmconjug := nvl(TRIM(rw_crapavt.nmconjug),lpad('_',40,'_'));
        vr_tab_avais_ctr(vr_idxavais).nrcpfcjg := 'CPF: '|| nvl(TRIM(gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapavt.nrcpfcjg,
                                                                                             pr_inpessoa => 1 )),lpad('_',35,'_'));
      ELSE
        vr_tab_avais_ctr(vr_idxavais).nmconjug := TRIM(rw_crapavt.nmconjug);
        vr_tab_avais_ctr(vr_idxavais).nrcpfcjg := TRIM(gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapavt.nrcpfcjg,
                                                                                 pr_inpessoa => 1 ));
      END IF;

      IF TRIM(rw_crapavt.tpdoccjg) IS NOT NULL AND
         TRIM(rw_crapavt.nrdoccjg) IS NOT NULL THEN
        vr_tab_avais_ctr(vr_idxavais).dsdoccjg := rw_crapavt.tpdoccjg ||': '|| rw_crapavt.nrdoccjg;
      ELSE
        vr_tab_avais_ctr(vr_idxavais).dsdoccjg := 'CI: '|| lpad('_',36,'_');
      END IF;

    END LOOP;

    pr_tab_avais_ctr := vr_tab_avais_ctr;

  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao buscar dados do avalista: ' || SQLERRM, chr(13)),chr(10));
  END pc_carrega_dados_avais;

  --> Rotina para buscar dados para impressao do contrato de limite de credito
  PROCEDURE pc_obtem_dados_contrato (  pr_cdcooper        IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                      ,pr_cdagenci        IN crapage.cdagenci%TYPE  --> Código da agencia
                                      ,pr_nrdcaixa        IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                      ,pr_cdoperad        IN crapope.cdoperad%TYPE  --> Código do Operador
                                      ,pr_idorigem        IN INTEGER                --> Identificador de Origem
                                      ,pr_nrdconta        IN crapass.nrdconta%TYPE  --> Número da Conta
                                      ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                      ,pr_nrctrlim        IN craplim.nrctrlim%TYPE  --> Contrato
                                      ,pr_tab_dados_ctr  OUT typ_tab_dados_ctr      --> Dados do contrato
                                      ,pr_tab_avais_ctr  OUT typ_tab_avais_ctr      --> Dados do avalista
                                      ,pr_tab_repres_ctr OUT typ_tab_repres_ctr     --> Dados do representantes/socios
                                      ,pr_cdcritic       OUT PLS_INTEGER            --> Código da crítica
                                      ,pr_dscritic       OUT VARCHAR2) IS           --> Descrição da crít

    /* .............................................................................

     Programa: pc_obtem_dados_contrato  (antiga: b1wgen0019.p/obtem-dados-contrato)
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/16.                    Ultima atualizacao: 24/07/2017

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para buscar dados para impressao do contrato de limite de credito

     Alteracoes: 24/07/2017 - Alterar cdoedptl para idorgexp.
                              PRJ339-CRM  (Odirlei-AMcom)
    ..............................................................................*/

    ---------->> CURSORES <<--------
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl,
             ass.cdagenci,
             ass.inpessoa,
             ass.nrdconta,
             ass.nrdocptl,
             ass.idorgexp,
             ass.tpdocptl,
             ass.cdufdptl

        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    rw_crabass cr_crapass%ROWTYPE;

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.nrdocnpj
            ,cop.dsendcop
            ,cop.nrendcop
            ,cop.nmbairro
            ,cop.nmcidade
            ,cop.cdufdcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    --> Buscar Contrato de limite
    CURSOR cr_craplim IS
      SELECT lim.nrdconta,
             lim.cdageori,
             lim.vllimite,
             lim.cddlinha,
             lim.nrctrlim,
             lim.dtrenova,
             lim.dtinivig,
       lim.dtpropos,
             lim.qtdiavig,
             lim.dtfimvig,
             lim.dsencfin##1,
             lim.dsencfin##2,
             lim.dsencfin##3,
             lim.nrgarope,
             lim.nrinfcad,
             lim.nrliquid,
             lim.nrpatlvr,
             lim.vltotsfn,
             lim.nrctaav1,
             lim.nrctaav2
        FROM craplim lim
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.nrctrlim = pr_nrctrlim
         AND lim.tpctrlim = 1;
    rw_craplim cr_craplim%ROWTYPE;

    --> Buscar enderecos do cooperado.
    CURSOR cr_crapenc IS
      SELECT enc.nrdconta,
             enc.dsendere,
             enc.nrcepend,
             enc.nmbairro,
             enc.nmcidade,
             enc.nrendere,
             enc.cdufende
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.idseqttl = 1
         AND enc.cdseqinc = 1;
    rw_crapenc cr_crapenc%ROWTYPE;

    --> buscar operador
    CURSOR cr_crapope IS
      SELECT ope.cdoperad
            ,ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;
    rw_crapope cr_crapope%ROWTYPE;

    --> Buscar Dados agencia
    CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE,
                      pr_cdagenci crapage.cdagenci%TYPE) IS
      SELECT age.nmcidade
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;

    --> Para pessoa juridica - faturamento unico cliente
    CURSOR cr_crapjfn (pr_cdcooper crapjfn.cdcooper%TYPE,
                       pr_nrdconta crapjfn.nrdconta%TYPE )IS
      SELECT jfn.cdcooper,
             jfn.perfatcl
        FROM crapjfn jfn
       WHERE jfn.cdcooper = pr_cdcooper
         AND jfn.nrdconta = pr_nrdconta;
    rw_crapjfn cr_crapjfn%ROWTYPE;

    --> Buscar Linhas de Credito Rotativo
    CURSOR cr_craplrt (pr_cdcooper craplrt.cdcooper%TYPE,
                       pr_cddlinha craplrt.cddlinha%TYPE) IS
      SELECT lrt.cdcooper,
             lrt.txmensal
        FROM craplrt lrt
       WHERE lrt.cdcooper = pr_cdcooper
         AND lrt.cddlinha = pr_cddlinha;
    rw_craplrt cr_craplrt%ROWTYPE;

    --> Buscar avalistas
    CURSOR cr_crapavt IS
      SELECT avt.cdcooper,
             avt.nrdctato,
             avt.nrcpfcgc,
             avt.nmdavali,
             avt.nrdocava,
             avt.idorgexp

        FROM crapavt avt
       WHERE avt.cdcooper = pr_cdcooper
         AND avt.tpctrato = 6
         AND avt.nrdconta = pr_nrdconta;

    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    vr_idxctr          PLS_INTEGER;
    vr_idxrepre        PLS_INTEGER;
    vr_tab_dados_ctr   typ_tab_dados_ctr;
    vr_tab_repres_ctr  typ_tab_repres_ctr;
    vr_tab_avais_ctr   typ_tab_avais_ctr;

    vr_vllimite_ext    VARCHAR2(200);
    vr_desdoano_ext    VARCHAR2(200);
    vr_dtmvtolt_ext    VARCHAR2(200);
    vr_dtmvtolt_ass    VARCHAR2(200);

    vr_txcetano        NUMBER;
    vr_txcetmes        NUMBER;

    vr_dsendcop        VARCHAR2(1000);
    vr_dsendass        VARCHAR2(1000);
    vr_cdorgexp        tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
    vr_nmorgexp        tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
  vr_nrvrsctr        NUMBER;

  BEGIN

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    --> Buscar cooperado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;

    --> Buscar Contrato de limite
    OPEN cr_craplim;
    FETCH cr_craplim INTO rw_craplim;
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_cdcritic := 105; -- 105 - Associado nao tem limite de credito.
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplim;
    END IF;

    --> Buscar endereço do cooperado
    OPEN cr_crapenc;
    FETCH cr_crapenc INTO rw_crapenc;
    IF cr_crapenc%NOTFOUND THEN
      CLOSE cr_crapenc;
      vr_dscritic := 'Endereco nao cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapenc;
    END IF;

    --> buscar dados do operador
    OPEN cr_crapope;
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_dscritic := 'Operador nao cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapope;
    END IF;

    --> Buscar Dados agencia
    OPEN cr_crapage(pr_cdcooper => pr_cdcooper ,
                    pr_cdagenci => rw_crapass.cdagenci);
    FETCH cr_crapage INTO rw_crapage;
    CLOSE cr_crapage;

    --> Para pessoa juridica - faturamento unico cliente
    OPEN cr_crapjfn (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta );
    FETCH cr_crapjfn INTO rw_crapjfn;
    CLOSE cr_crapjfn;

    --> Buscar Linhas de Credito Rotativo
    OPEN cr_craplrt (pr_cdcooper => pr_cdcooper,
                     pr_cddlinha => rw_craplim.cddlinha);
    FETCH cr_craplrt INTO rw_craplrt;
    IF cr_craplrt%NOTFOUND THEN
      CLOSE cr_craplrt;
      vr_dscritic := 'Linhas de Credito Rotativo nao encotrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplrt;
    END IF;

    --Gerar valor em extenso
    vr_vllimite_ext := gene0002.fn_valor_extenso(pr_idtipval => 'M',
                                                 pr_valor    => rw_craplim.vllimite);

    IF to_char(pr_dtmvtolt,'DD') > 1 THEN
      --Gerar valor em extenso
      -- DIA
      vr_dtmvtolt_ext := gene0002.fn_valor_extenso(pr_idtipval => 'I',
                                                   pr_valor    => to_char(pr_dtmvtolt,'DD'));
      vr_dtmvtolt_ext := vr_dtmvtolt_ext ||' DIAS ';

    ELSE
      vr_dtmvtolt_ext := 'PRIMEIRO DIA ';
    END IF;

    --> Ano
    vr_desdoano_ext := gene0002.fn_valor_extenso(pr_idtipval => 'I',
                                                 pr_valor    => to_char(pr_dtmvtolt,'RRRR'));

    vr_dtmvtolt_ext := vr_dtmvtolt_ext ||' DO MÊS DE '||
                       gene0001.vr_vet_nmmesano(to_char(pr_dtmvtolt,'MM')) ||
                       ' DE ' || vr_desdoano_ext;


    --> Calcular cet
    ccet0001.pc_calculo_cet_limites (pr_cdcooper  => pr_cdcooper -- Cooperativa
                                    ,pr_dtmvtolt  => pr_dtmvtolt -- Data Movimento
                                    ,pr_cdprogra  => 'atenda' -- Programa chamador
                                    ,pr_nrdconta  => pr_nrdconta -- Conta/dv
                                    ,pr_inpessoa  => rw_crapass.inpessoa -- Indicativo de pessoa
                                    ,pr_cdusolcr  => 1 -- Codigo de uso da linha de credito
                                    ,pr_cdlcremp  => rw_craplim.cddlinha -- Linha de credio
                                    ,pr_tpctrlim  => 1 -- Tipo da operacao -- 1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit
                                    ,pr_nrctrlim  => rw_craplim.nrctrlim -- Contrato
                                    ,pr_dtinivig  => coalesce(rw_craplim.dtrenova,rw_craplim.dtinivig,pr_dtmvtolt) -- Data liberacao
                                    ,pr_qtdiavig  => rw_craplim.qtdiavig -- Dias de vigencia
                                    ,pr_vlemprst  => rw_craplim.vllimite -- Valor emprestado
                                    ,pr_txmensal  => rw_craplrt.txmensal -- Taxa mensal
                                    ,pr_txcetano  => vr_txcetano  -- Taxa cet ano
                                    ,pr_txcetmes  => vr_txcetmes  -- Taxa cet mes
                                    ,pr_cdcritic  => vr_cdcritic  --> Código da crítica
                                    ,pr_dscritic  => vr_dscritic);--> Descrição da crítica


    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Montar string endereço cooper
    vr_dsendcop := rw_crapcop.dsendcop || ', ' || to_char(rw_crapcop.nrendcop,'fm999G999G999')||', '||
                   rw_crapcop.nmbairro || ', ' || rw_crapcop.nmcidade ||', '||
                   rw_crapcop.cdufdcop || '.';

    vr_dsendass := rw_crapenc.dsendere || ', ' || to_char(rw_crapenc.nrendere,'fm999G999G999')||', '||
                   rw_crapenc.nmbairro || ', ' || gene0002.fn_mask_cep(rw_crapenc.nrcepend) ||' - '||
                   rw_crapenc.nmcidade || '/'  || rw_crapenc.cdufende || '.';


    vr_dtmvtolt_ass := SUBSTR(rw_crapage.nmcidade,1,15) ||', ' || gene0005.fn_data_extenso(pr_dtmvtolt);

    --> Carregar temptable do contrato
    vr_idxctr := vr_tab_dados_ctr.count() + 1;
    vr_tab_dados_ctr(vr_idxctr).nmextcop := rw_crapcop.nmextcop;
    vr_tab_dados_ctr(vr_idxctr).nmrescop := rw_crapcop.nmrescop;
    vr_tab_dados_ctr(vr_idxctr).nrdocnpj := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcop.nrdocnpj, pr_inpessoa => 2);
    vr_tab_dados_ctr(vr_idxctr).dsendcop := vr_dsendcop;
    vr_tab_dados_ctr(vr_idxctr).nrdconta := rw_crapass.nrdconta;
    vr_tab_dados_ctr(vr_idxctr).nmprimtl := rw_crapass.nmprimtl;
    vr_tab_dados_ctr(vr_idxctr).inpessoa := rw_crapass.inpessoa;
    vr_tab_dados_ctr(vr_idxctr).dsendass := vr_dsendass;
    vr_tab_dados_ctr(vr_idxctr).cdagenci := rw_crapass.cdagenci;
    vr_tab_dados_ctr(vr_idxctr).cdageori := rw_craplim.cdageori;
    vr_tab_dados_ctr(vr_idxctr).nmcidpac := nvl(rw_crapage.nmcidade,'____________________');
    vr_tab_dados_ctr(vr_idxctr).nrctrlim := rw_craplim.nrctrlim;
    vr_tab_dados_ctr(vr_idxctr).dsctrlim := TRIM(gene0002.fn_mask_contrato(rw_craplim.nrctrlim)) || '/001';
    vr_tab_dados_ctr(vr_idxctr).vllimite := rw_craplim.vllimite;
    vr_tab_dados_ctr(vr_idxctr).qtdiavig := rw_craplim.qtdiavig;
    vr_tab_dados_ctr(vr_idxctr).dtinivig := rw_craplim.dtinivig;
    vr_tab_dados_ctr(vr_idxctr).dtfimvig := rw_craplim.dtfimvig;
    vr_tab_dados_ctr(vr_idxctr).dtrenova := rw_craplim.dtrenova;
    vr_tab_dados_ctr(vr_idxctr).cddlinha := rw_craplim.cddlinha;
    vr_tab_dados_ctr(vr_idxctr).dsencfin := rw_craplim.dsencfin##1 || rw_craplim.dsencfin##2 ||
                                            rw_craplim.dsencfin##3;
    vr_tab_dados_ctr(vr_idxctr).dsvllimi := vr_vllimite_ext;
    vr_tab_dados_ctr(vr_idxctr).dsemsctr := vr_dtmvtolt_ass;
    vr_tab_dados_ctr(vr_idxctr).nmoperad := 'Operador: '|| rw_crapope.nmoperad;
    vr_tab_dados_ctr(vr_idxctr).ddmvtolt := to_char(pr_dtmvtolt,'DD');
    vr_tab_dados_ctr(vr_idxctr).aamvtolt := to_char(pr_dtmvtolt,'RRRR');
    vr_tab_dados_ctr(vr_idxctr).dsdtmvto := vr_dtmvtolt_ext;
    vr_tab_dados_ctr(vr_idxctr).dsvlnpr1 := vr_vllimite_ext;
    vr_tab_dados_ctr(vr_idxctr).dsmesref := gene0001.vr_vet_nmmesano(to_char(pr_dtmvtolt,'MM'));
    vr_tab_dados_ctr(vr_idxctr).dsdmoeda := 'R$';
    vr_tab_dados_ctr(vr_idxctr).txcetano := vr_txcetano;
    vr_tab_dados_ctr(vr_idxctr).txcetmes := vr_txcetmes;

    --> Campos para o Rating
    vr_tab_dados_ctr(vr_idxctr).nrgarope := rw_craplim.nrgarope;
    vr_tab_dados_ctr(vr_idxctr).nrinfcad := rw_craplim.nrinfcad;
    vr_tab_dados_ctr(vr_idxctr).nrliquid := rw_craplim.nrliquid;
    vr_tab_dados_ctr(vr_idxctr).nrpatlvr := rw_craplim.nrpatlvr;
    vr_tab_dados_ctr(vr_idxctr).vltotsfn := rw_craplim.vltotsfn;
    vr_tab_dados_ctr(vr_idxctr).perfatcl := rw_crapjfn.perfatcl;

    IF rw_crapass.inpessoa = 1 THEN
      vr_tab_dados_ctr(vr_idxctr).nrcpfcgc := 'CPF ';
    ELSE
      vr_tab_dados_ctr(vr_idxctr).nrcpfcgc := 'CNPJ ';
    END IF;
    vr_tab_dados_ctr(vr_idxctr).nrcpfcgc := vr_tab_dados_ctr(vr_idxctr).nrcpfcgc ||
                                            gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                                                      pr_inpessoa => rw_crapass.inpessoa);
    -- Se ainda for contrato antigo
    IF nvl(rw_craplim.dtinivig, rw_craplim.dtpropos) < TO_DATE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                        ,pr_cdacesso => 'DT_VIG_IMP_CTR_V2'),'DD/MM/RRRR') THEN
           vr_nrvrsctr := 1; -- Atribui versão 1
    ELSE
       vr_nrvrsctr := 2; -- Atribui versão 2
    END IF;

    IF rw_crapass.inpessoa > 1 THEN
      --Listar representantes/socios
      FOR rw_crapavt IN cr_crapavt LOOP
        vr_idxrepre := vr_tab_repres_ctr.count() + 1;

        IF rw_crapavt.nrdctato <> 0  THEN
          --> Buscar conta do cooperado avalista
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => rw_crapavt.nrdctato);
          FETCH cr_crapass INTO rw_crabass;
          IF cr_crapass%FOUND THEN
            CLOSE cr_crapass;
            vr_tab_repres_ctr(vr_idxrepre).nmrepres := rw_crabass.nmprimtl;
            vr_tab_repres_ctr(vr_idxrepre).nrcpfrep := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crabass.nrcpfcgc,
                                                                                pr_inpessoa => rw_crabass.inpessoa );
            vr_tab_repres_ctr(vr_idxrepre).dsdocrep := rw_crabass.nrdocptl;


            --> Buscar orgão expedidor
            vr_tab_repres_ctr(vr_idxrepre).cdoedrep := NULL;
            cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crabass.idorgexp,
                                              pr_cdorgao_expedidor => vr_tab_repres_ctr(vr_idxrepre).cdoedrep,
                                              pr_nmorgao_expedidor => vr_nmorgexp,
                                              pr_cdcritic          => vr_cdcritic,
                                              pr_dscritic          => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              vr_tab_repres_ctr(vr_idxrepre).cdoedrep := 'NAO CADAST';
              vr_nmorgexp := NULL;
            END IF;

          ELSE
            CLOSE cr_crapass;
          END IF;

        ELSE
          vr_tab_repres_ctr(vr_idxrepre).nmrepres := rw_crapavt.nmdavali;
          vr_tab_repres_ctr(vr_idxrepre).nrcpfrep := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapavt.nrcpfcgc,
                                                                               pr_inpessoa => 1 );
          vr_tab_repres_ctr(vr_idxrepre).dsdocrep := rw_crapavt.nrdocava;

          --> Buscar orgão expedidor
          vr_tab_repres_ctr(vr_idxrepre).cdoedrep := NULL;
          cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapavt.idorgexp,
                                            pr_cdorgao_expedidor => vr_tab_repres_ctr(vr_idxrepre).cdoedrep,
                                            pr_nmorgao_expedidor => vr_nmorgexp,
                                            pr_cdcritic          => vr_cdcritic,
                                            pr_dscritic          => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
            vr_tab_repres_ctr(vr_idxrepre).cdoedrep := 'NAO CADAST';
            vr_nmorgexp := NULL;
          END IF;

        END IF;

      END LOOP;
    ELSE
      --> Buscar orgão expedidor
      vr_cdorgexp := NULL;
      cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapass.idorgexp,
                                        pr_cdorgao_expedidor => vr_cdorgexp,
                                        pr_nmorgao_expedidor => vr_nmorgexp,
                                        pr_cdcritic          => vr_cdcritic,
                                        pr_dscritic          => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        vr_cdorgexp := 'NAO CADAST';
        vr_nmorgexp := NULL;
      END IF;

      vr_tab_dados_ctr(vr_idxctr).nrdrgass := rw_crapass.tpdocptl || ' '  ||
                                              rw_crapass.nrdocptl || ' - '||
                                              vr_cdorgexp         || '/'  ||
                                              rw_crapass.cdufdptl ;
    END IF;

    vr_tab_avais_ctr.delete;

    --> Verificar se proposta possui conta avalista
    pc_carrega_dados_avais (pr_cdcooper      => pr_cdcooper,         --> Cooperativa do avalista
                            pr_nrdconta      => pr_nrdconta,         --> Numero da conta do avalista
                            pr_nrctrlim      => pr_nrctrlim,         --> Numero do contrato de limite de credito
              pr_nrvrsctr      => vr_nrvrsctr,         --> Versão do contrato
                            pr_tab_avais_ctr => vr_tab_avais_ctr,    --> Retorna dados dos avalistas
                            pr_cdcritic      => vr_cdcritic,         --> Código da crítica
                            pr_dscritic      => vr_dscritic);        --> Descrição da crítica
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Retornar dados encontrados
    pr_tab_dados_ctr  := vr_tab_dados_ctr;
    pr_tab_avais_ctr  := vr_tab_avais_ctr;
    pr_tab_repres_ctr := vr_tab_repres_ctr;


  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao buscar dados para impressao: ' || SQLERRM, chr(13)),chr(10));
  END pc_obtem_dados_contrato;

  -- Rotina para geração do contrato de limite de credito
  PROCEDURE pc_impres_contrato_limite_v1(pr_cdcooper IN crapcop.cdcooper%TYPE    --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo Movimento
                                     ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo
                                     ,pr_idimpres IN INTEGER                --> Indicador de impresao
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_dsiduser IN VARCHAR2               --> id do usuario
                                     ,pr_flgimpnp IN INTEGER                --> indica se deve gerar nota promissoria(0-nao 1-sim)
                                     ,pr_flgemail IN INTEGER                --> Indicador de envia por email (0-nao, 1-sim)
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_tab_dados_ctr  IN typ_tab_dados_ctr  --> Dados do contrato
                                     ,pr_tab_avais_ctr  IN typ_tab_avais_ctr  --> Dados do avalista
                                     ,pr_tab_repres_ctr IN typ_tab_repres_ctr --> Dados do representantes/socios
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .............................................................................

     Programa: pc_impres_contrato_limite_v1 (antiga:pc_impres_contrato_limite)   (antiga: b1wgen0019.p/gera-impressao-limite(parte contrato))
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/16.                    Ultima atualizacao: 25/01/2018

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do contrato de limite de credito
     Alteracoes: 20/03/2017 - Tratamento para que na impressão do contrato apenas imprima o
                      contrato, e não o CET e nem a nota promissora como no completo.
                      Chamado: 511304 (Andrey Formigari - Mouts)

                 07/02/2018 - Foi renomeada pc_impres_contrato_limite para pc_impres_contrato_limite_v1,
                              Prj. 404 (Jean Michel)

    ..............................................................................*/

    ---------->>> CURSORES  <<<---------
    CURSOR cr_craplrt (pr_cdcooper IN craplrt.cdcooper%TYPE,
                       pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT txmensal
        FROM craplrt
       WHERE craplrt.cdcooper = pr_cdcooper
         AND craplrt.cddlinha = pr_cddlinha;
    rw_craplrt cr_craplrt%ROWTYPE;

    --> Buscar os emails para envio
    CURSOR cr_craprel (pr_cdcooper craprel.cdcooper%TYPE,
                       pr_cdrelato craprel.cdrelato%TYPE)IS
      SELECT rel.dsdemail
        FROM craprel rel
       WHERE rel.cdcooper = pr_cdcooper
         AND rel.cdrelato = pr_cdrelato;
    rw_craprel cr_craprel%ROWTYPE;

    --> Buscar dados agencia
    CURSOR cr_crapage (pr_cdcooper crapage.cdcooper%TYPE,
                       pr_cdagenci crapage.cdagenci%TYPE)IS
      SELECT age.cdagenci,
             age.nmresage
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;

    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        GENE0001.typ_tab_erro;

    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;

    vr_dstextab        craptab.dstextab%TYPE;
    vr_tpdocged        INTEGER;
    vr_qrcode          VARCHAR2(100);
    vr_cdageqrc        INTEGER;

    vr_dsdireto        VARCHAR2(4000);
    vr_nmendter        VARCHAR2(4000);
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100);

    vr_idxctr          PLS_INTEGER;
    vr_dscetano        VARCHAR2(1000);
    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE;
    vr_nrdrowid        ROWID;

    vr_dsextmail       VARCHAR2(3);
    vr_dsmailcop       VARCHAR2(4000);
    vr_dsassmail       VARCHAR2(200);
    vr_dscormail       VARCHAR2(50);
    vr_nmarquivo       VARCHAR2(50) := 'crrl580_contrato_limite.jasper';

    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);

    --> CET
    vr_desxml_CET      CLOB;
    vr_nmarqimp_CET    varchar2(60);

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;

  BEGIN
    --> Definir transação
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);

      CASE pr_idimpres
        WHEN 1 THEN
          vr_dstransa := 'Gerar impressao da proposta e contrato do limite de credito';
        WHEN 2 THEN
          vr_dstransa := 'Gerar impressao do contrato do limite de credito';
        ELSE
          vr_dscritic := 'Tipo de impressao invalida.';
          RAISE vr_exc_erro;
      END CASE;
    END IF;

    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper
                                         pr_cdcooper => pr_cdcooper);

    vr_nmendter := vr_dsdireto ||'/rl/crrl580_'||pr_dsiduser;

    vr_dscomand := 'rm '||vr_nmendter||'* 2>/dev/null';

    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;

    --> Montar nome do arquivo
    pr_nmarqpdf := 'crrl580_'||pr_dsiduser || gene0002.fn_busca_time || '.pdf';

    vr_idxctr := pr_tab_dados_ctr.first;
    --> Verificar se retornou informacao
    IF vr_idxctr IS NULL THEN
      vr_dscritic := 'Nao foi possivel gerar a impressao.';
      RAISE vr_exc_erro;
    END IF;

    --> calculo do cet por extenso
    vr_dscetano := gene0002.fn_valor_extenso(pr_idtipval => 'M',
                                             pr_valor    => pr_tab_dados_ctr(vr_idxctr).txcetano);

    vr_dscetano := to_char(pr_tab_dados_ctr(vr_idxctr).txcetano,'fm990D00')||
                   '% ('|| vr_dscetano ||') ao ano; (' ||
                   to_char(pr_tab_dados_ctr(vr_idxctr).txcetmes,'fm90D00') ||
                   ' % ao mes), conforme planilha demonstrativa';

    vr_dstextab :=  TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                               pr_nmsistem => 'CRED'      ,
                                               pr_tptabela => 'GENERI'    ,
                                               pr_cdempres => 00          ,
                                               pr_cdacesso => 'DIGITALIZA' ,
                                               pr_tpregist => 19 ); --> Contrato limite de credito (GED)

    vr_tpdocged :=  gene0002.fn_busca_entrada(pr_postext => 3,
                                              pr_dstext  => vr_dstextab,
                                              pr_delimitador => ';');

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    vr_txtcompl := NULL;

    --Incluir no QRcode a agencia onde foi criado o contrato.
    IF nvl(pr_tab_dados_ctr(vr_idxctr).cdageori,0) = 0 THEN
      vr_cdageqrc := pr_tab_dados_ctr(vr_idxctr).cdagenci;
    ELSE
      vr_cdageqrc := pr_tab_dados_ctr(vr_idxctr).cdageori;
    END IF;

    vr_qrcode := pr_cdcooper ||'_'||
                 vr_cdageqrc ||'_'||
                 TRIM(gene0002.fn_mask_conta(pr_nrdconta))    ||'_'||
                 0           ||'_'||
                 TRIM(gene0002.fn_mask_contrato(pr_nrctrlim)) ||'_'||
                 0           ||'_'||
                 vr_tpdocged;

    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz><contrato>
                    <inpessoa>'|| pr_tab_dados_ctr(vr_idxctr).inpessoa ||'</inpessoa>
                    <nmprimtl>'|| pr_tab_dados_ctr(vr_idxctr).nmprimtl ||'</nmprimtl>
                    <nmextcop>'|| pr_tab_dados_ctr(vr_idxctr).nmextcop ||'</nmextcop>
                    <nmoperad>'|| pr_tab_dados_ctr(vr_idxctr).nmoperad ||'</nmoperad>
          <idimpres>'|| pr_idimpres ||'</idimpres>
                    <dsemsctr>'|| pr_tab_dados_ctr(vr_idxctr).dsemsctr ||'</dsemsctr>');

    pc_escreve_xml('<dados>'||
                     '<dsqrcode>'|| vr_qrcode                            ||'</dsqrcode>'||
                     '<nrctrlim>'|| pr_nrctrlim                          ||'</nrctrlim>'||
                     '<nmextcop>'|| pr_tab_dados_ctr(vr_idxctr).nmextcop ||'</nmextcop>'||
                     '<nmprimtl>'|| pr_tab_dados_ctr(vr_idxctr).nmprimtl ||'</nmprimtl>'||
                     '<nrdocnpj>'|| pr_tab_dados_ctr(vr_idxctr).nrdocnpj ||'</nrdocnpj>'||
                     '<cdagenci>'|| pr_tab_dados_ctr(vr_idxctr).cdagenci ||'</cdagenci>'||
                     '<dsendcop>'|| pr_tab_dados_ctr(vr_idxctr).dsendcop ||'</dsendcop>'||
                     '<nrcpfcgc>'|| pr_tab_dados_ctr(vr_idxctr).nrcpfcgc ||'</nrcpfcgc>'||
                     '<nrdconta>'|| pr_tab_dados_ctr(vr_idxctr).nrdconta ||'</nrdconta>'||
                     '<dsendass>'|| pr_tab_dados_ctr(vr_idxctr).dsendass ||'</dsendass>'||
                     '<vllimite>'|| to_char(pr_tab_dados_ctr(vr_idxctr).vllimite,'FM999G999G990D00') ||'</vllimite>'||
                     '<dsvlnprp>'|| pr_tab_dados_ctr(vr_idxctr).dsvlnpr1 ||'</dsvlnprp>'||
                     '<dsencfin>'|| pr_tab_dados_ctr(vr_idxctr).dsencfin ||'</dsencfin>'||
                     '<dscetano>'|| vr_dscetano                          ||'</dscetano>'||
                     '<qtdiavig>'|| pr_tab_dados_ctr(vr_idxctr).qtdiavig ||'</qtdiavig>'||
                     '<nrdrgass>'|| pr_tab_dados_ctr(vr_idxctr).nrdrgass ||'</nrdrgass>'

                     );

    --> Listar representantes/socios
    pc_escreve_xml('<representantes>');
    IF pr_tab_repres_ctr.count() > 0 THEN
      FOR idx IN pr_tab_repres_ctr.first..pr_tab_repres_ctr.last LOOP
        pc_escreve_xml('<repres>'||
                          '<nmrepres>' ||   pr_tab_repres_ctr(idx).nmrepres ||'</nmrepres>' ||
                          '<nrcpfrep>' ||   pr_tab_repres_ctr(idx).nrcpfrep ||'</nrcpfrep>' ||
                          '<dsdocrep>' ||   pr_tab_repres_ctr(idx).dsdocrep ||'</dsdocrep>' ||
                          '<cdoedrep>' ||   pr_tab_repres_ctr(idx).cdoedrep ||'</cdoedrep>' ||
                       '</repres>');
      END LOOP;
    END IF;
    pc_escreve_xml('</representantes></dados>');

    --> Listar avalistas
    pc_escreve_xml('<avalistas>');
    IF pr_tab_avais_ctr.count() > 0 THEN
      FOR idx IN pr_tab_avais_ctr.first..pr_tab_avais_ctr.last LOOP
        pc_escreve_xml('<avallim>'||
                           '<nrsequen>'|| idx                              ||'</nrsequen>'||
                           '<nmdavali>'|| pr_tab_avais_ctr(idx).nmdavali   ||'</nmdavali>'||
                           '<cpfavali>'|| pr_tab_avais_ctr(idx).cpfavali   ||'</cpfavali>'||
                           '<dsdocava>'|| pr_tab_avais_ctr(idx).dsdocava   ||'</dsdocava>'||
                           '<nmconjug>'|| pr_tab_avais_ctr(idx).nmconjug   ||'</nmconjug>'||
                           '<nrcpfcjg>'|| pr_tab_avais_ctr(idx).nrcpfcjg   ||'</nrcpfcjg>'||
                           '<dsdoccjg>'|| pr_tab_avais_ctr(idx).dsdoccjg   ||'</dsdoccjg>'||
                       '</avallim>');
      END LOOP;
    END IF;

    pc_escreve_xml('</avalistas>');

    IF pr_idimpres NOT IN (2, 6) THEN
      --> Tratamento da impressao da nota promissoria
      IF pr_flgimpnp = 1 THEN
        pc_escreve_xml('<Promissoria>'||
                         '<tpctrlim>'|| 1                                       ||'</tpctrlim>'||
                         '<nmrescop>'||  pr_tab_dados_ctr(vr_idxctr).nmrescop   ||'</nmrescop>'||
                         '<nmextcop>'||  pr_tab_dados_ctr(vr_idxctr).nmextcop   ||'</nmextcop>'||
                         '<nrdocnpj>'||  pr_tab_dados_ctr(vr_idxctr).nrdocnpj   ||'</nrdocnpj>'||
                         '<ddmvtolt>'||  pr_tab_dados_ctr(vr_idxctr).ddmvtolt   ||'</ddmvtolt>'||
                         '<dsmesref>'||  pr_tab_dados_ctr(vr_idxctr).dsmesref   ||'</dsmesref>'||
                         '<aamvtolt>'||  pr_tab_dados_ctr(vr_idxctr).aamvtolt   ||'</aamvtolt>'||
                         '<dsctremp>'||  pr_tab_dados_ctr(vr_idxctr).dsctrlim   ||'</dsctremp>'||
                         '<dsdmoeda>'||  pr_tab_dados_ctr(vr_idxctr).dsdmoeda   ||'</dsdmoeda>'||
                         '<vlpreemp>'||  to_char(pr_tab_dados_ctr(vr_idxctr).vllimite,'FM999G999G990D00')  ||'</vlpreemp>'||
                         '<dsmvtolt>'||  upper(pr_tab_dados_ctr(vr_idxctr).dsdtmvto)   ||'</dsmvtolt>'||
                         '<dspreemp>'||  pr_tab_dados_ctr(vr_idxctr).dsvlnpr1   ||'</dspreemp>'||
                         '<nmprimtl>'||  pr_tab_dados_ctr(vr_idxctr).nmprimtl   ||'</nmprimtl>'||
                         '<dscpfcgc>'||  pr_tab_dados_ctr(vr_idxctr).nrcpfcgc   ||'</dscpfcgc>'||
                         '<nrdconta>'||  pr_tab_dados_ctr(vr_idxctr).nrdconta   ||'</nrdconta>'||
                         '<nmcidpac>'||  'Págavel em '|| pr_tab_dados_ctr(vr_idxctr).nmcidpac   ||'</nmcidpac>'||
                         '<dsemsnot>'||  pr_tab_dados_ctr(vr_idxctr).dsemsctr    ||'</dsemsnot>'||
                         '<dsendass>'||  pr_tab_dados_ctr(vr_idxctr).dsendass   ||'</dsendass>');

        IF pr_tab_avais_ctr.COUNT > 0 THEN

          pc_escreve_xml('<avalistas>');

          FOR vr_idx IN pr_tab_avais_ctr.FIRST..pr_tab_avais_ctr.LAST LOOP
            pc_escreve_xml('<aval>'||
                             '<nmdavali>'|| pr_tab_avais_ctr(vr_idx).nmdavali ||'</nmdavali>'||
                             '<nmconjug>'|| pr_tab_avais_ctr(vr_idx).nmconjug ||'</nmconjug>'||
                             '<cpfavali>'|| pr_tab_avais_ctr(vr_idx).cpfavali ||'</cpfavali>'||
                             '<nrcpfcjg>'|| pr_tab_avais_ctr(vr_idx).nrcpfcjg ||'</nrcpfcjg>'||
                             '<dsendava><![CDATA['|| pr_tab_avais_ctr(vr_idx).dsendava ||']]></dsendava>'||
                           '</aval>');
          END LOOP;

          pc_escreve_xml('</avalistas>');

        END IF;
        pc_escreve_xml('</Promissoria>');
      END IF;
    END IF;


    IF pr_idimpres = 1  THEN --> Completa

      --> GERAR CONTRATO DO CET
      OPEN cr_craplrt (pr_cdcooper => pr_cdcooper,
                       pr_cddlinha => pr_tab_dados_ctr(vr_idxctr).cddlinha);
      FETCH cr_craplrt INTO rw_craplrt;
      IF cr_craplrt%NOTFOUND THEN
        CLOSE cr_craplrt;
        vr_dscritic := 'Linha de credito do contrato nao encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplrt;
      END IF;

      --> Gerar XML para dados do relatorio de CET
      CCET0001.pc_imprime_limites_cet( pr_cdcooper  => pr_cdcooper                 -- Cooperativa
                                      ,pr_dtmvtolt  => pr_dtmvtolt                 -- Data Movimento
                                      ,pr_cdprogra  => 'ATENDA'                    -- Programa chamador
                                      ,pr_nrdconta  => pr_nrdconta                 -- Conta/dv
                                      ,pr_inpessoa  => pr_tab_dados_ctr(vr_idxctr).inpessoa         -- Indicativo de pessoa
                                      ,pr_cdusolcr  => 1                           -- Codigo de uso da linha de credito
                                      ,pr_cdlcremp  =>pr_tab_dados_ctr(vr_idxctr).cddlinha         -- Linha de credio
                                      ,pr_tpctrlim  => 1                           --> Tipo da operacao (1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit)
                                      ,pr_nrctrlim  => pr_nrctrlim                 -- Contrato
                                      ,pr_dtinivig  => nvl(nvl(pr_tab_dados_ctr(vr_idxctr).dtrenova,
                                                               pr_tab_dados_ctr(vr_idxctr).dtinivig),
                                                           pr_dtmvtolt)         -- Data liberacao

                                      ,pr_qtdiavig  => pr_tab_dados_ctr(vr_idxctr).qtdiavig -- Dias de vigencia
                                      ,pr_vlemprst  => pr_tab_dados_ctr(vr_idxctr).vllimite -- Valor emprestado
                                      ,pr_txmensal  => rw_craplrt.txmensal         -- Taxa mensal
                                      ,pr_flretxml  => 1                           -- Indicador se deve apenas retornar o XML da impressao
                                      ,pr_des_xml   => vr_desxml_CET               -- XML
                                      ,pr_nmarqimp  => vr_nmarqimp_CET             -- Nome do arquivo
                                      ,pr_cdcritic  => vr_cdcritic                 --> Código da crítica
                                      ,pr_dscritic  => vr_dscritic);               --> Descrição da crítica

      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

    --> Descarregar buffer
    pc_escreve_xml(' ',TRUE);

    IF vr_desxml_CET IS NOT NULL THEN
      -- concatena xml retornado CCET com xml contratos
      dbms_lob.append(vr_des_xml, vr_desxml_CET);
      dbms_lob.freetemporary(vr_desxml_CET);
    END IF;

    --> Descarregar buffer
    pc_escreve_xml('</contrato></raiz>',TRUE);

    -- Se foi solicitado para enviar email
    IF pr_flgemail = 1 THEN

      --> Buscar os emails para envio
      OPEN cr_craprel(pr_cdcooper => pr_cdcooper,
                      pr_cdrelato => 517);
      FETCH cr_craprel INTO rw_craprel;
      IF cr_craprel%NOTFOUND THEN
        CLOSE cr_craprel;
        vr_cdcritic := 0;
        vr_dscritic := 'Relatorio nao cadastrado - 517.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craprel;
      END IF;
      -- Se nao possui email informado
      IF TRIM(rw_craprel.dsdemail) IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Necessario cadastro de e-mail. Tela PAMREL.';
        RAISE vr_exc_erro;
      END IF;

      --> Buscar dados agencia
      OPEN cr_crapage(pr_cdcooper => pr_cdcooper,
                      pr_cdagenci => pr_tab_dados_ctr(vr_idxctr).cdagenci);
      FETCH cr_crapage INTO rw_crapage;
      IF cr_crapage%NOTFOUND THEN
        CLOSE cr_crapage;
        vr_cdcritic := 962;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapage;
      END IF;

      vr_dsmailcop := REPLACE(rw_craprel.dsdemail, ',', ';');
      vr_dscormail := 'SEGUE ARQUIVO EM ANEXO.';
      vr_dsassmail := 'crrl580 - Conta/dv: ' ||
                      TRIM(GENE0002.fn_mask_conta(pr_nrdconta)) || ' - PA ' ||
                      rw_crapage.cdagenci || ' ' || rw_crapage.nmresage;
    ELSE

      vr_dsmailcop := NULL;
      vr_dscormail := NULL;
      vr_dsassmail := NULL;
    END IF;


    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => pr_cdprogra
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz/contrato'
                               , pr_dsjasper  => vr_nmarquivo
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 234
                               , pr_cdrelato  => 280
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_dsextmail => NULL
                               , pr_dsmailcop => vr_dsmailcop
                               , pr_dsassmail => vr_dsassmail
                               , pr_dscormail => vr_dscormail
                               , pr_des_erro  => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;

    IF pr_idorigem = 5 THEN
      -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => NULL
                                  ,pr_nrdcaixa => NULL
                                  ,pr_nmarqpdf => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);
      -- Se retornou erro
      IF NVL(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_dsdireto ||'/rl/'||pr_nmarqpdf
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;

    --> Gerar log de sucesso
    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdopecxa,
                           pr_dscritic => NULL,
                           pr_dsorigem => vr_dsorigem,
                           pr_dstransa => vr_dstransa,
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans =>  1, -- True
                           pr_hrtransa => gene0002.fn_busca_time,
                           pr_idseqttl => pr_idseqttl,
                           pr_nmdatela => pr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'nrctrlim',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_nrctrlim);
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := REPLACE(REPLACE(vr_dscritic,chr(13)),chr(10));
      END IF;

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao do contrato: ' || SQLERRM, chr(13)),chr(10));

  END pc_impres_contrato_limite_v1;

  -- Rotina para geração do contrato de limite de credito
  PROCEDURE pc_impres_contrato_limite_v2(pr_cdcooper IN crapcop.cdcooper%TYPE    --> Código da Cooperativa
                                        ,pr_cdagecxa IN crapage.cdagenci%TYPE    --> Código da agencia
                                        ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa do operador
                                        ,pr_cdopecxa IN crapope.cdoperad%TYPE    --> Código do Operador
                                        ,pr_nmdatela IN craptel.nmdatela%TYPE    --> Nome da Tela
                                        ,pr_idorigem IN INTEGER                  --> Identificador de Origem
                                        ,pr_cdprogra IN crapprg.cdprogra%TYPE    --> Codigo do programa
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE    --> Número da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE    --> Titular da Conta
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE    --> Data de Movimento
                                        ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE    --> Data do proximo Movimento
                                        ,pr_inproces IN crapdat.inproces%TYPE    --> Indicador do processo
                                        ,pr_idimpres IN INTEGER                  --> Indicador de impresao
                                        ,pr_nrctrlim IN craplim.nrctrlim%TYPE    --> Contrato
                                        ,pr_dsiduser IN VARCHAR2                 --> id do usuario
                                        ,pr_flgimpnp IN INTEGER                  --> indica se deve gerar nota promissoria(0-nao 1-sim)
                                        ,pr_flgemail IN INTEGER                  --> Indicador de envia por email (0-nao, 1-sim)
                                        ,pr_flgerlog IN INTEGER                  --> Indicador se deve gerar log(0-nao, 1-sim)
                                        ,pr_tab_dados_ctr  IN typ_tab_dados_ctr  --> Dados do contrato
                                        ,pr_tab_avais_ctr  IN typ_tab_avais_ctr  --> Dados do avalista
                                        ,pr_tab_repres_ctr IN typ_tab_repres_ctr --> Dados do representantes/socios
                                       --------> OUT <--------
                                       ,pr_nmarqpdf  OUT VARCHAR2                --> Retornar quantidad de registros
                                       ,pr_cdcritic OUT PLS_INTEGER              --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2) IS             --> Descrição da crítica
    /* .............................................................................

     Programa: pc_impres_contrato_limite_v2
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : Jean Michel
     Data    : Fevereiro/2018                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia:

     Objetivo  : Rotina para geração do contrato de limite de credito(Nova versão), Prj. 404

     Alteracoes:

    ..............................................................................*/

    ---------->>> CURSORES  <<<---------

    CURSOR cr_craplrt(pr_cdcooper IN craplrt.cdcooper%TYPE
                     ,pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT lrt.txmensal
        FROM craplrt lrt
       WHERE lrt.cdcooper = pr_cdcooper
         AND lrt.cddlinha = pr_cddlinha;

    rw_craplrt cr_craplrt%ROWTYPE;

    --> Buscar os emails para envio
    CURSOR cr_craprel(pr_cdcooper craprel.cdcooper%TYPE
                     ,pr_cdrelato craprel.cdrelato%TYPE)IS
      SELECT rel.dsdemail
        FROM craprel rel
       WHERE rel.cdcooper = pr_cdcooper
         AND rel.cdrelato = pr_cdrelato;

    rw_craprel cr_craprel%ROWTYPE;

    --> Buscar dados agencia
    CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE
                     ,pr_cdagenci crapage.cdagenci%TYPE)IS
      SELECT age.cdagenci,
             age.nmresage
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;

    rw_crapage cr_crapage%ROWTYPE;

    --> Informações da cooperativa
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.nmextcop
            ,cop.nmrescop
            ,cop.nrdocnpj
            ,cop.dsendcop
            ,cop.nrendcop
            ,cop.nmbairro
            ,cop.nrcepend
            ,cop.nmcidade
            ,cop.cdufdcop
        FROM crapcop cop
       WHERE cdcooper = pr_cdcooper;

    rw_crapcop cr_crapcop%ROWTYPE;

    --> Dados da conta
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.inpessoa
            ,ass.nmprimtl
            ,ass.nrcpfcgc
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%ROWTYPE;

      --> Endereço do cooperado
    CURSOR cr_crapenc(pr_cdcooper crapenc.cdcooper%TYPE
                     ,pr_nrdconta crapenc.nrdconta%TYPE
                     ,pr_inpessoa crapass.inpessoa%TYPE
                     ,pr_idseqttl crapenc.idseqttl%TYPE) IS
      SELECT enc.dsendere
            ,enc.nrendere
            ,enc.complend
            ,enc.nmbairro
            ,enc.nmcidade
            ,enc.cdufende
            ,enc.nrcepend
            ,enc.nrcxapst
            ,enc.incasprp
            ,enc.vlalugue
            ,enc.dtinires
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.tpendass = DECODE(pr_inpessoa, 1,10,9)
         AND enc.idseqttl = pr_idseqttl;

    rw_crapenc cr_crapenc%ROWTYPE;

    CURSOR cr_tbgar_cobertura_operacao(pr_cdcooper   tbgar_cobertura_operacao.cdcooper%TYPE
                                      ,pr_nrdconta   tbgar_cobertura_operacao.nrdconta%TYPE
                                      ,pr_nrcontrato tbgar_cobertura_operacao.nrcontrato%TYPE) IS
      SELECT cob.nrconta_terceiro
        FROM tbgar_cobertura_operacao cob
       WHERE cob.cdcooper   = pr_cdcooper
         AND cob.nrdconta   = pr_nrdconta
         AND cob.nrcontrato = pr_nrcontrato
         AND cob.inaplicacao_terceiro = 1;

    rw_tbgar_cobertura_operacao cr_tbgar_cobertura_operacao%ROWTYPE;

    --> Buscar informações do limite de crédito contratado
    CURSOR cr_craplim(pr_nrdconta craplim.nrdconta%TYPE
                     ,pr_cdcooper craplim.cdcooper%TYPE
                     ,pr_nrctrlim craplim.nrctrlim%TYPE) IS
    SELECT to_char(lim.dtpropos, 'DD/MM/RRRR') dtpropos -- Data da contratação
          ,lim.vllimite -- sobre xx
          ,lim.qtdiavig
          ,lim.dsencfin##1 -- Encargos financeiros
          ,nvl(lim.dsencfin##2,0) dsencfin##2 -- Juros na contratação – (Aplicável x%)
          ,lim.dsencfin##3 -- Periodicidade da capitalização (Mensal)
          ,(SELECT nmcidade || ' - ' || cdufdcop FROM crapcop cop WHERE cop.cdcooper = pr_cdcooper AND rownum = 1) nmcidade -- Lugar do Pagamento (cidade local do PA)
          ,cob.perminimo -- Valor(es) da aplicação(ões) financeira(s) bloqueada(a): x%  do limite de crédito concedido
          ,cob.qtdias_atraso_permitido -- Carência para resgate automático da(s) aplicação(ões) financeira(s) bloqueada(s): X dias, contados do excesso do uso do limite pelo COOPERADO*/
      ,cob.idcobertura
      ,cob.inresgate_automatico
      FROM craplim lim,
           tbgar_cobertura_operacao cob
     WHERE lim.nrdconta = cob.nrdconta(+)
       AND lim.cdcooper = cob.cdcooper(+)
       AND lim.nrctrlim = cob.nrcontrato(+)
       AND lim.nrdconta = pr_nrdconta  -- numero da conta
       AND lim.cdcooper = pr_cdcooper  -- codigo da cooperativa
       AND lim.nrctrlim = pr_nrctrlim; -- numero do contrato

    rw_craplim cr_craplim%ROWTYPE;

    --> Buscar avalistas terceiros/interveniente garantidor
    CURSOR cr_crapavt(pr_cdcooper crapavt.cdcooper%TYPE
                     ,pr_nrdconta crapavt.nrdconta%TYPE
                     ,pr_nrctremp crapavt.nrctremp%TYPE)IS

      SELECT avt.nrdconta
            ,avt.nmdavali
            ,avt.nrcpfcgc
            ,avt.nmconjug
            ,avt.nrcpfcjg
            ,avt.dsendres##1 dsendres
            ,avt.nrcepend
            ,avt.nrendere
            ,avt.nmbairro
            ,avt.nmcidade
            ,avt.cdufresd
            ,avt.tpdocava
            ,avt.nrdocava
            ,avt.tpdoccjg
            ,avt.nrdoccjg
        FROM crapavt avt
       WHERE avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrctremp = pr_nrctremp
         AND avt.tpctrato = 3;

    rw_crapavt cr_crapavt%ROWTYPE;

    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        GENE0001.typ_tab_erro;

    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;

    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE;
    vr_nrdrowid        ROWID;

    vr_dstextab        craptab.dstextab%TYPE;
    vr_tpdocged        INTEGER;
    vr_qrcode          VARCHAR2(100);
    vr_cdageqrc        INTEGER;

    vr_dsdireto        VARCHAR2(4000);
    vr_nmendter        VARCHAR2(4000);
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100);

    vr_idxctr          PLS_INTEGER;
    vr_dscetano        VARCHAR2(1000);

    vr_dsextmail       VARCHAR2(3);
    vr_dsmailcop       VARCHAR2(4000);
    vr_dsassmail       VARCHAR2(200);
    vr_dscormail       VARCHAR2(50);
    vr_nmarquivo       VARCHAR2(50) := 'crrl580_contrato_limite_v2.jasper';
    vr_nrcpfcgc        VARCHAR2(50) := '';

    vr_contaval        INTEGER := 0;

    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);

    --> CET
    vr_desxml_CET      CLOB;
    vr_nmarqimp_CET    varchar2(60);
  vr_ind_interv      INTEGER := 0;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;

  BEGIN
    --> Definir transação
      IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);

      CASE pr_idimpres
        WHEN 1 THEN
          vr_dstransa := 'Gerar impressao da proposta e contrato do limite de credito';
        WHEN 2 THEN
          vr_dstransa := 'Gerar impressao do contrato do limite de credito';
        ELSE
          vr_dscritic := 'Tipo de impressao invalida.';
          RAISE vr_exc_erro;
      END CASE;
      END IF;

    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper
                                         pr_cdcooper => pr_cdcooper);

    vr_nmendter := vr_dsdireto ||'/rl/crrl580_'||pr_dsiduser;

    vr_dscomand := 'rm '||vr_nmendter||'* 2>/dev/null';

    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;

    --> Montar nome do arquivo
    pr_nmarqpdf := 'crrl580_'||pr_dsiduser || gene0002.fn_busca_time || '.pdf';

    vr_idxctr := pr_tab_dados_ctr.first;
    --> Verificar se retornou informacao
    IF vr_idxctr IS NULL THEN
      vr_dscritic := 'Nao foi possivel gerar a impressao.';
      RAISE vr_exc_erro;
    END IF;

    --> calculo do cet por extenso
    vr_dscetano := gene0002.fn_valor_extenso(pr_idtipval => 'M',
                                             pr_valor    => pr_tab_dados_ctr(vr_idxctr).txcetano);

    vr_dscetano := to_char(pr_tab_dados_ctr(vr_idxctr).txcetano,'fm990D00')||
                   '% ao ano (' || to_char(pr_tab_dados_ctr(vr_idxctr).txcetmes,'fm90D00') ||
                   ' % ao mes), conforme planilha demonstrativa de cálculo.';

    vr_dstextab :=  TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                               pr_nmsistem => 'CRED'      ,
                                               pr_tptabela => 'GENERI'    ,
                                               pr_cdempres => 00          ,
                                               pr_cdacesso => 'DIGITALIZA' ,
                                               pr_tpregist => 19 ); --> Contrato limite de credito (GED)

    vr_tpdocged :=  gene0002.fn_busca_entrada(pr_postext => 3,
                                              pr_dstext  => vr_dstextab,
                                              pr_delimitador => ';');

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    vr_txtcompl := NULL;

    --Incluir no QRcode a agencia onde foi criado o contrato.
    IF nvl(pr_tab_dados_ctr(vr_idxctr).cdageori,0) = 0 THEN
      vr_cdageqrc := pr_tab_dados_ctr(vr_idxctr).cdagenci;
    ELSE
      vr_cdageqrc := pr_tab_dados_ctr(vr_idxctr).cdageori;
    END IF;

    vr_qrcode := pr_cdcooper ||'_'|| vr_cdageqrc ||'_'|| TRIM(gene0002.fn_mask_conta(pr_nrdconta)) ||'_'||
                 0           ||'_'|| TRIM(gene0002.fn_mask_contrato(pr_nrctrlim)) ||'_'||
                 0           ||'_'|| vr_tpdocged;

    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);

    FETCH cr_crapcop INTO rw_crapcop;

    IF cr_crapcop%NOTFOUND THEN
      vr_cdcritic := 1070;
      CLOSE cr_crapcop;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    --> Dados da Cooperativa
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><contrato>' ||
                    '<dsqrcode>'|| vr_qrcode || '</dsqrcode>' ||
                    '<cooperativa>' ||
                       '<nmextcop>' || rw_crapcop.nmextcop || '</nmextcop>' ||
                       '<nmrescop>' || rw_crapcop.nmrescop || '</nmrescop>' ||
                       '<nrdocnpj>' || GENE0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2) || '</nrdocnpj>' ||
                       '<dsendcop>' || rw_crapcop.dsendcop || '</dsendcop>' ||
                       '<nrendcop>' || rw_crapcop.nrendcop || '</nrendcop>' ||
                       '<nmbairro>' || rw_crapcop.nmbairro || '</nmbairro>' ||
                       '<nrcepend>' || GENE0002.fn_mask_cep(rw_crapcop.nrcepend) || '</nrcepend>' ||
                       '<nmcidade>' || rw_crapcop.nmcidade || '</nmcidade>' ||
                       '<cdufdcop>' || rw_crapcop.cdufdcop || '</cdufdcop>' ||
                    '</cooperativa>');

    --> Dados do Cooperado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);

    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      CLOSE cr_crapass;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;

      OPEN cr_crapenc(pr_cdcooper => rw_crapass.cdcooper
                     ,pr_nrdconta => rw_crapass.nrdconta
                     ,pr_inpessoa => rw_crapass.inpessoa
                     ,pr_idseqttl => 1);

      FETCH cr_crapenc INTO rw_crapenc;

      IF cr_crapenc%NOTFOUND THEN
        vr_cdcritic := 247;
        CLOSE cr_crapenc;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapenc;
      END IF;

    END IF;

    vr_nrcpfcgc := TRIM(REPLACE(pr_tab_dados_ctr(vr_idxctr).nrcpfcgc,'CNPJ',''));
    vr_nrcpfcgc := TRIM(REPLACE(vr_nrcpfcgc,'CPF',''));

    pc_escreve_xml('<cooperado>'||
                      '<nrdconta>'|| TRIM(GENE0002.fn_mask_conta(pr_tab_dados_ctr(vr_idxctr).nrdconta)) ||'</nrdconta>'||
                      '<cdagenci>'|| TRIM(pr_tab_dados_ctr(vr_idxctr).cdagenci) ||'</cdagenci>' ||
                      '<nmprimtl>'|| TRIM(pr_tab_dados_ctr(vr_idxctr).nmprimtl) ||'</nmprimtl>' ||
                      '<nrcpfcgc>'|| TRIM(vr_nrcpfcgc)                          ||'</nrcpfcgc>' ||
                      '<dsendere>'|| TRIM(rw_crapenc.dsendere)                  ||'</dsendere>' ||
                      '<nrendere>'|| TRIM(rw_crapenc.nrendere)                  ||'</nrendere>' ||
                      '<complend>'|| TRIM(rw_crapenc.complend)                  ||'</complend>' ||
                      '<nmcidade>'|| TRIM(rw_crapenc.nmcidade)                  ||'</nmcidade>' ||
                      '<nmbairro>'|| TRIM(rw_crapenc.nmbairro)                  ||'</nmbairro>' ||
                      '<cdufende>'|| TRIM(rw_crapenc.cdufende)                  ||'</cdufende>' ||
                      '<nrcepend>'|| GENE0002.fn_mask_cep(TRIM(rw_crapenc.nrcepend)) ||'</nrcepend>' ||
                   '</cooperado>');

    OPEN cr_craplim(pr_nrdconta => pr_nrdconta
                   ,pr_cdcooper => pr_cdcooper
                   ,pr_nrctrlim => pr_nrctrlim);

    FETCH cr_craplim INTO rw_craplim;

    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_cdcritic := 356;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplim;
    END IF;

    pc_escreve_xml('<contrato>'||
                      '<nrctrlim>'  || TRIM(pr_nrctrlim)                                     || '</nrctrlim>'  ||
                      '<dtinivig>'  || TRIM(rw_craplim.dtpropos)                             || '</dtinivig>'  ||
                      '<qtdiavig>'  || TRIM(rw_craplim.qtdiavig)                             || '</qtdiavig>'  ||
                      '<vllimite>'  || TRIM(TO_CHAR(rw_craplim.vllimite,'fm999G999G999D00')) || '</vllimite>'  ||
                      '<dsencfin1>' || TRIM(rw_craplim.dsencfin##1)                          || '</dsencfin1>' ||
                      '<dsencfin2>' || TRIM(rw_craplim.dsencfin##2)                          || '</dsencfin2>' ||
                      '<dsencfin3>' || TRIM(rw_craplim.dsencfin##3)                          || '</dsencfin3>' ||
                      '<nmcidade>'  || TRIM(rw_craplim.nmcidade)                             || '</nmcidade>'  ||
                      '<dscetano>'  || TRIM(vr_dscetano)                                     || '</dscetano>'  ||
                      '<perminimo>' || rw_craplim.perminimo                                  || '</perminimo>' ||
                      '<qtdias_atraso_permitido>' || rw_craplim.qtdias_atraso_permitido      || '</qtdias_atraso_permitido>' ||
                      '<inresauto>' || nvl(rw_craplim.inresgate_automatico,0)      || '</inresauto>' ||
            '<inaddcob>'  || (CASE WHEN nvl(rw_craplim.idcobertura,0) > 0 THEN '1' ELSE '0' END) ||'</inaddcob>' ||
                   '</contrato>');

    --> Listar avalistas
    pc_escreve_xml('<avalistas>');
    vr_contaval := 0;
    IF pr_tab_avais_ctr.count() > 0 THEN
      FOR idx IN pr_tab_avais_ctr.first..pr_tab_avais_ctr.last LOOP
        vr_contaval := vr_contaval + 1;
        pc_escreve_xml('<avalista'|| vr_contaval ||'>'||
                         '<nmdavali>'|| pr_tab_avais_ctr(idx).nmdavali ||'</nmdavali>'||
                         '<cpfavali>'|| pr_tab_avais_ctr(idx).cpfavali ||'</cpfavali>'||
                         '<dsendava>'|| pr_tab_avais_ctr(idx).dsendava ||'</dsendava>'||
                         '<nrctaava>'|| trim(gene0002.fn_mask_conta(nvl(pr_tab_avais_ctr(idx).nrdconta,0))) ||'</nrctaava>'||
             '<nrcpfcjg>'|| pr_tab_avais_ctr(idx).nrcpfcjg ||'</nrcpfcjg>'||
             '<nmconjug>'|| pr_tab_avais_ctr(idx).nmconjug ||'</nmconjug>'||
                       '</avalista'|| vr_contaval ||'>');
      END LOOP;
    END IF;
    pc_escreve_xml('</avalistas>');
    pc_escreve_xml('<qtd_avalistas>' || to_char(pr_tab_avais_ctr.count()) || '</qtd_avalistas>');

    --> Fim avalistas

    --> Listar Interveniente/Garantidor
    pc_escreve_xml('<interveniente>');
    OPEN cr_tbgar_cobertura_operacao(pr_cdcooper   => rw_crapass.cdcooper
                                    ,pr_nrdconta   => rw_crapass.nrdconta
                                    ,pr_nrcontrato => pr_nrctrlim);

    LOOP

      FETCH cr_tbgar_cobertura_operacao INTO rw_tbgar_cobertura_operacao;

      -- Sai quando chegar ao fim dos registros
      EXIT WHEN cr_tbgar_cobertura_operacao%NOTFOUND;

      OPEN cr_crapass(pr_cdcooper => rw_crapass.cdcooper
                     ,pr_nrdconta=>  rw_tbgar_cobertura_operacao.nrconta_terceiro);

      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic := 9;
        CLOSE cr_crapass;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;

        OPEN cr_crapenc(pr_cdcooper => rw_crapass.cdcooper
                       ,pr_nrdconta => rw_crapass.nrdconta
                       ,pr_inpessoa => rw_crapass.inpessoa
                       ,pr_idseqttl => 1);

        FETCH cr_crapenc INTO rw_crapenc;

        IF cr_crapenc%NOTFOUND THEN
          vr_cdcritic := 247;
          CLOSE cr_crapenc;
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapenc;
        END IF;

      END IF;
      -- Indicador de interveniente
      vr_ind_interv := 1;
      pc_escreve_xml('<nrdconta_interv>'|| trim(gene0002.fn_mask_conta(nvl(rw_crapass.nrdconta,0))) || '</nrdconta_interv>' ||
                     '<nminterv>'|| rw_crapass.nmprimtl || '</nminterv>' ||
                     '<nrcpfcgc>'|| gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc
                                                             ,rw_crapass.inpessoa) || '</nrcpfcgc>' ||
                     '<dsendere>'|| rw_crapenc.dsendere || '</dsendere>' ||
                     '<nrendere>'|| rw_crapenc.nrendere || '</nrendere>' ||
                     '<complend>'|| rw_crapenc.complend || '</complend>' ||
                     '<nmbairro>'|| rw_crapenc.nmbairro || '</nmbairro>' ||
                     '<nmcidade>'|| rw_crapenc.nmcidade || '</nmcidade>' ||
                     '<cdufende>'|| rw_crapenc.cdufende || '</cdufende>' ||
                     '<nrcepend>'|| gene0002.fn_mask_cep(rw_crapenc.nrcepend) || '</nrcepend>');
    END LOOP;
    pc_escreve_xml('</interveniente>'||
               '<ind_interv>' || vr_ind_interv ||'</ind_interv>');
    --> Fim interveniente/Garantidor

    -- Projeto 470 - SM 1 - 18/03/2019
    -- Marcelo Telles Coelho - Mouts
    DECLARE
      vr_dsfrase_cooperado   VARCHAR2(4000);
      vr_dsfrase_cooperativa VARCHAR2(4000);
    BEGIN
      cntr0001.pc_ver_protocolo (pr_cdcooper            => pr_cdcooper
                                ,pr_nrdconta            => pr_nrdconta
                                ,pr_nrcontrato          => pr_nrctrlim
                                ,pr_tpcontrato          => 29
                                ,pr_dsfrase_cooperado   => vr_dsfrase_cooperado
                                ,pr_dsfrase_cooperativa => vr_dsfrase_cooperativa);
      IF vr_dsfrase_cooperado IS NOT NULL THEN
        pc_escreve_xml('<autorizacao_por_senha>');
        pc_escreve_xml('<dsfrase_cooperado>'||vr_dsfrase_cooperado||'</dsfrase_cooperado>');
        pc_escreve_xml('<dsfrase_cooperativa>'||vr_dsfrase_cooperativa||'</dsfrase_cooperativa>');
        pc_escreve_xml('</autorizacao_por_senha>');
      END IF;
    END;
    -- Fim Projeto 470 - SM 1

    IF pr_idimpres = 1  THEN --> Completa

      --> GERAR CONTRATO DO CET
      OPEN cr_craplrt (pr_cdcooper => pr_cdcooper,
                       pr_cddlinha => pr_tab_dados_ctr(vr_idxctr).cddlinha);
      FETCH cr_craplrt INTO rw_craplrt;
      IF cr_craplrt%NOTFOUND THEN
        CLOSE cr_craplrt;
        vr_dscritic := 'Linha de credito do contrato nao encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplrt;
      END IF;

      --> Gerar XML para dados do relatorio de CET
      CCET0001.pc_imprime_limites_cet( pr_cdcooper  => pr_cdcooper                 -- Cooperativa
                                      ,pr_dtmvtolt  => pr_dtmvtolt                 -- Data Movimento
                                      ,pr_cdprogra  => 'ATENDA'                    -- Programa chamador
                                      ,pr_nrdconta  => pr_nrdconta                 -- Conta/dv
                                      ,pr_inpessoa  => pr_tab_dados_ctr(vr_idxctr).inpessoa         -- Indicativo de pessoa
                                      ,pr_cdusolcr  => 1                           -- Codigo de uso da linha de credito
                                      ,pr_cdlcremp  =>pr_tab_dados_ctr(vr_idxctr).cddlinha         -- Linha de credio
                                      ,pr_tpctrlim  => 1                           --> Tipo da operacao (1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit)
                                      ,pr_nrctrlim  => pr_nrctrlim                 -- Contrato
                                      ,pr_dtinivig  => nvl(nvl(pr_tab_dados_ctr(vr_idxctr).dtrenova,
                                                               pr_tab_dados_ctr(vr_idxctr).dtinivig),
                                                           pr_dtmvtolt)         -- Data liberacao

                                      ,pr_qtdiavig  => pr_tab_dados_ctr(vr_idxctr).qtdiavig -- Dias de vigencia
                                      ,pr_vlemprst  => pr_tab_dados_ctr(vr_idxctr).vllimite -- Valor emprestado
                                      ,pr_txmensal  => rw_craplrt.txmensal         -- Taxa mensal
                                      ,pr_flretxml  => 1                           -- Indicador se deve apenas retornar o XML da impressao
                                      ,pr_des_xml   => vr_desxml_CET               -- XML
                                      ,pr_nmarqimp  => vr_nmarqimp_CET             -- Nome do arquivo
                                      ,pr_cdcritic  => vr_cdcritic                 --> Código da crítica
                                      ,pr_dscritic  => vr_dscritic);               --> Descrição da crítica

      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

    --> Descarregar buffer
    pc_escreve_xml(' ',TRUE);

    IF vr_desxml_CET IS NOT NULL THEN
      -- concatena xml retornado CCET com xml contratos
      dbms_lob.append(vr_des_xml, vr_desxml_CET);
      dbms_lob.freetemporary(vr_desxml_CET);
    END IF;

    --> Descarregar buffer
    pc_escreve_xml('</contrato>',TRUE);

    -- Se foi solicitado para enviar email
    IF pr_flgemail = 1 THEN

      --> Buscar os emails para envio
      OPEN cr_craprel(pr_cdcooper => pr_cdcooper,
                      pr_cdrelato => 517);
      FETCH cr_craprel INTO rw_craprel;
      IF cr_craprel%NOTFOUND THEN
        CLOSE cr_craprel;
        vr_cdcritic := 0;
        vr_dscritic := 'Relatorio nao cadastrado - 517.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craprel;
      END IF;
      -- Se nao possui email informado
      IF TRIM(rw_craprel.dsdemail) IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Necessario cadastro de e-mail. Tela PAMREL.';
        RAISE vr_exc_erro;
      END IF;

      --> Buscar dados agencia
      OPEN cr_crapage(pr_cdcooper => pr_cdcooper,
                      pr_cdagenci => pr_tab_dados_ctr(vr_idxctr).cdagenci);
      FETCH cr_crapage INTO rw_crapage;
      IF cr_crapage%NOTFOUND THEN
        CLOSE cr_crapage;
        vr_cdcritic := 962;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapage;
      END IF;

      vr_dsmailcop := REPLACE(rw_craprel.dsdemail, ',', ';');
      vr_dscormail := 'SEGUE ARQUIVO EM ANEXO.';
      vr_dsassmail := 'crrl580 - Conta/dv: ' ||
                      TRIM(GENE0002.fn_mask_conta(pr_nrdconta)) || ' - PA ' ||
                      rw_crapage.cdagenci || ' ' || rw_crapage.nmresage;
    ELSE

      vr_dsmailcop := NULL;
      vr_dscormail := NULL;
      vr_dsassmail := NULL;
    END IF;

    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => pr_cdprogra
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/contrato'
                               , pr_dsjasper  => vr_nmarquivo
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 234
                               , pr_cdrelato  => 280
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_dsextmail => NULL
                               , pr_dsmailcop => vr_dsmailcop
                               , pr_dsassmail => vr_dsassmail
                               , pr_dscormail => vr_dscormail
                               , pr_des_erro  => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;

    IF pr_idorigem = 5 THEN
      -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => NULL
                                  ,pr_nrdcaixa => NULL
                                  ,pr_nmarqpdf => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);
      -- Se retornou erro
      IF NVL(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_dsdireto ||'/rl/'||pr_nmarqpdf
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;

    --> Gerar log de sucesso
    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdopecxa,
                           pr_dscritic => NULL,
                           pr_dsorigem => vr_dsorigem,
                           pr_dstransa => vr_dstransa,
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans =>  1, -- True
                           pr_hrtransa => gene0002.fn_busca_time,
                           pr_idseqttl => pr_idseqttl,
                           pr_nmdatela => pr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'nrctrlim',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_nrctrlim);
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;

      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa,
                             pr_dscritic => pr_dscritic,
                             pr_dsorigem => vr_dsorigem,
                             pr_dstransa => vr_dstransa,
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time,
                             pr_idseqttl => pr_idseqttl,
                             pr_nmdatela => pr_nmdatela,
                             pr_nrdconta => pr_nrdconta,
                             pr_nrdrowid => vr_nrdrowid);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'nrctrlim',
                                  pr_dsdadant => NULL,
                                  pr_dsdadatu => pr_nrctrlim);
      END IF;

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao do contrato: ' || SQLERRM, chr(13)),chr(10));

      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa,
                             pr_dscritic => pr_dscritic,
                             pr_dsorigem => vr_dsorigem,
                             pr_dstransa => vr_dstransa,
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time,
                             pr_idseqttl => pr_idseqttl,
                             pr_nmdatela => pr_nmdatela,
                             pr_nrdconta => pr_nrdconta,
                             pr_nrdrowid => vr_nrdrowid);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'nrctrlim',
                                  pr_dsdadant => NULL,
                                  pr_dsdadatu => pr_nrctrlim);
      END IF;

  END pc_impres_contrato_limite_v2;

  -- Rotina para geração do contrato de limite de credito
  PROCEDURE pc_impres_contrato_limite(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo Movimento
                                     ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo
                                     ,pr_idimpres IN INTEGER                --> Indicador de impresao
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_dsiduser IN VARCHAR2               --> id do usuario
                                     ,pr_flgimpnp IN INTEGER                --> indica se deve gerar nota promissoria(0-nao 1-sim)
                                     ,pr_flgemail IN INTEGER                --> Indicador de envia por email (0-nao, 1-sim)
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .............................................................................

     Programa: pc_impres_contrato_limite  (antiga: b1wgen0019.p/gera-impressao-limite(parte contrato))
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/16.                    Ultima atualizacao: 25/01/2018

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do contrato de limite de credito
     Alteracoes: 20/03/2017 - Tratamento para que na impressão do contrato apenas imprima o
                              contrato, e não o CET e nem a nota promissora como no completo.
                              Chamado: 511304 (Andrey Formigari - Mouts)

                 25/01/2018 - Inclusão de condição para geração de novos modelos de contratos,
                              Prj. 404, foram geradas procedures distintas para os novos contratos (Jean Michel).

    ..............................................................................*/

    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;

    vr_idxctr          PLS_INTEGER;
    vr_nmarqpdf        VARCHAR2(500);

    vr_tab_dados_ctr  typ_tab_dados_ctr;
    vr_tab_repres_ctr typ_tab_repres_ctr;
    vr_tab_avais_ctr  typ_tab_avais_ctr;

    vr_nrvrsctr        INTEGER;
  BEGIN

    --> Buscar dados para impressao do contrato de limite de credito
    pc_obtem_dados_contrato(pr_cdcooper       => pr_cdcooper       --> Código da Cooperativa
                           ,pr_cdagenci       => pr_cdagecxa       --> Código da agencia
                           ,pr_nrdcaixa       => pr_nrdcaixa       --> Numero do caixa do operador
                           ,pr_cdoperad       => pr_cdopecxa       --> Código do Operador
                           ,pr_idorigem       => pr_idorigem       --> Identificador de Origem
                           ,pr_nrdconta       => pr_nrdconta       --> Número da Conta
                           ,pr_dtmvtolt       => pr_dtmvtolt       --> Data de Movimento
                           ,pr_nrctrlim       => pr_nrctrlim       --> Contrato
                           ,pr_tab_dados_ctr  => vr_tab_dados_ctr  --> Dados do contrato
                           ,pr_tab_avais_ctr  => vr_tab_avais_ctr  --> Dados do avalista
                           ,pr_tab_repres_ctr => vr_tab_repres_ctr --> Dados do representantes/socios
                           ,pr_cdcritic       => vr_cdcritic       --> Código da crítica
                           ,pr_dscritic       => vr_dscritic);     --> Descrição da crít

    vr_idxctr := vr_tab_dados_ctr.first;

    --> Verificar se retornou informacao
    IF vr_idxctr IS NULL THEN
      vr_dscritic := 'Nao foi possivel gerar a impressao. cdcooper: ' || pr_cdcooper
                                                                      || 'cdagecxa: ' || pr_cdagecxa
                                                                      || 'nrdcaixa: ' || pr_nrdcaixa
                                                                      || 'cdopecxa: ' || pr_cdopecxa
                                                                      || 'idorigem: ' || pr_idorigem
                                                                      || 'nrdconta: ' || pr_nrdconta
                                                                      || 'dtmvtolt: ' || pr_dtmvtolt
                                                                      || 'nrctrlim: ' || pr_nrctrlim;
      RAISE vr_exc_erro;
    END IF;

    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  -- Se ainda for contrato antigo
    IF vr_tab_dados_ctr(vr_idxctr).dtinivig < TO_DATE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                               ,pr_cdacesso => 'DT_VIG_IMP_CTR_V2'),'DD/MM/RRRR') THEN
       vr_nrvrsctr := 1; -- Atribui versão 1
  ELSE
     vr_nrvrsctr := 2; -- Atribui versão 2
  END IF;

    IF vr_nrvrsctr = 1 THEN

      pc_impres_contrato_limite_v1(pr_cdcooper       => pr_cdcooper       --> Código da Cooperativa
                                  ,pr_cdagecxa       => pr_cdagecxa       --> Código da agencia
                                  ,pr_nrdcaixa       => pr_nrdcaixa       --> Numero do caixa do operador
                                  ,pr_cdopecxa       => pr_cdopecxa       --> Código do Operador
                                  ,pr_nmdatela       => pr_nmdatela       --> Nome da Tela
                                  ,pr_idorigem       => pr_idorigem       --> Identificador de Origem
                                  ,pr_cdprogra       => pr_cdprogra       --> Codigo do programa
                                  ,pr_nrdconta       => pr_nrdconta       --> Número da Conta
                                  ,pr_idseqttl       => pr_idseqttl       --> Titular da Conta
                                  ,pr_dtmvtolt       => pr_dtmvtolt       --> Data de Movimento
                                  ,pr_dtmvtopr       => pr_dtmvtopr       --> Data do proximo Movimento
                                  ,pr_inproces       => pr_inproces       --> Indicador do processo
                                  ,pr_idimpres       => pr_idimpres       --> Indicador de impresao
                                  ,pr_nrctrlim       => pr_nrctrlim       --> Contrato
                                  ,pr_dsiduser       => pr_dsiduser       --> id do usuario
                                  ,pr_flgimpnp       => pr_flgimpnp       --> indica se deve gerar nota promissoria(0-nao 1-sim)
                                  ,pr_flgemail       => pr_flgemail       --> Indicador de envia por email (0-nao, 1-sim)
                                  ,pr_flgerlog       => pr_flgerlog       --> Indicador se deve gerar log(0-nao, 1-sim)
                                  ,pr_tab_dados_ctr  => vr_tab_dados_ctr  --> Dados do contrato
                                  ,pr_tab_avais_ctr  => vr_tab_avais_ctr  --> Dados do avalista
                                  ,pr_tab_repres_ctr => vr_tab_repres_ctr --> Dados do representantes/socios
                                  ,pr_nmarqpdf       => vr_nmarqpdf       --> Retornar quantidad de registros
                                  ,pr_cdcritic       => vr_cdcritic       --> Código da crítica
                                  ,pr_dscritic       => vr_dscritic);     --> Descrição da crítica
    ELSE
      pc_impres_contrato_limite_v2(pr_cdcooper       => pr_cdcooper       --> Código da Cooperativa
                                  ,pr_cdagecxa       => pr_cdagecxa       --> Código da agencia
                                  ,pr_nrdcaixa       => pr_nrdcaixa       --> Numero do caixa do operador
                                  ,pr_cdopecxa       => pr_cdopecxa       --> Código do Operador
                                  ,pr_nmdatela       => pr_nmdatela       --> Nome da Tela
                                  ,pr_idorigem       => pr_idorigem       --> Identificador de Origem
                                  ,pr_cdprogra       => pr_cdprogra       --> Codigo do programa
                                  ,pr_nrdconta       => pr_nrdconta       --> Número da Conta
                                  ,pr_idseqttl       => pr_idseqttl       --> Titular da Conta
                                  ,pr_dtmvtolt       => pr_dtmvtolt       --> Data de Movimento
                                  ,pr_dtmvtopr       => pr_dtmvtopr       --> Data do proximo Movimento
                                  ,pr_inproces       => pr_inproces       --> Indicador do processo
                                  ,pr_idimpres       => pr_idimpres       --> Indicador de impresao
                                  ,pr_nrctrlim       => pr_nrctrlim       --> Contrato
                                  ,pr_dsiduser       => pr_dsiduser       --> id do usuario
                                  ,pr_flgimpnp       => pr_flgimpnp       --> indica se deve gerar nota promissoria(0-nao 1-sim)
                                  ,pr_flgemail       => pr_flgemail       --> Indicador de envia por email (0-nao, 1-sim)
                                  ,pr_flgerlog       => pr_flgerlog       --> Indicador se deve gerar log(0-nao, 1-sim)
                                  ,pr_tab_dados_ctr  => vr_tab_dados_ctr  --> Dados do contrato
                                  ,pr_tab_avais_ctr  => vr_tab_avais_ctr  --> Dados do avalista
                                  ,pr_tab_repres_ctr => vr_tab_repres_ctr --> Dados do representantes/socios
                                  ,pr_nmarqpdf       => vr_nmarqpdf       --> Retornar quantidad de registros
                                  ,pr_cdcritic       => vr_cdcritic       --> Código da crítica
                                  ,pr_dscritic       => vr_dscritic);     --> Descrição da crítica
    END IF;

    pr_nmarqpdf := vr_nmarqpdf;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao do contrato: ' || SQLERRM, chr(13)),chr(10));

  END pc_impres_contrato_limite;

  --> Rotina para geração do contrato de limite de credito  - Ayllos Web
  PROCEDURE pc_impres_contrato_limite_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
                                         ,pr_idseqttl   IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                         ,pr_idimpres   IN INTEGER                --> Indicador de impresao
                                         ,pr_nrctrlim   IN craplim.nrctrlim%TYPE  --> Contrato
                                         ,pr_dsiduser   IN VARCHAR2               --> id do usuario
                                         ,pr_flgimpnp   IN INTEGER                --> indica se deve gerar nota promissoria(0-nao 1-sim)
                                         ,pr_flgemail   IN INTEGER                --> Indicador de envia por email (0-nao, 1-sim)
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_impres_contrato_limite_web
    Sistema : Ayllos Web
    Autor   : Odirlei - AMcom
    Data    : Setembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para chamar as impressoes pelo Ayllos Web

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis gerais
      vr_nmarqpdf VARCHAR2(1000);

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_gera_impressao'
                                ,pr_action => NULL);

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      pc_impres_contrato_limite(pr_cdcooper => vr_cdcooper  --> Código da Cooperativa
                               ,pr_cdagecxa => vr_cdagenci  --> Código da agencia
                               ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa do operador
                               ,pr_cdopecxa => vr_cdoperad  --> Código do Operador
                               ,pr_nmdatela => vr_nmdatela  --> Nome da Tela
                               ,pr_idorigem => vr_idorigem  --> Identificador de Origem
                               ,pr_cdprogra => vr_nmdatela  --> Codigo do programa
                               ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                               ,pr_idseqttl => pr_idseqttl  --> Titular da Conta
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data de Movimento
                               ,pr_dtmvtopr => rw_crapdat.dtmvtopr  --> Data do proximo Movimento
                               ,pr_inproces => rw_crapdat.inproces  --> Indicador do processo
                               ,pr_idimpres => pr_idimpres  --> Indicador de impresao
                               ,pr_nrctrlim => pr_nrctrlim  --> Contrato
                               ,pr_dsiduser => pr_dsiduser  --> id do usuario
                               ,pr_flgimpnp => pr_flgimpnp  --> indica se deve gerar nota promissoria(0-nao 1-sim)
                               ,pr_flgemail => pr_flgemail
                               ,pr_flgerlog => 1            --> True
                               --------> OUT <--------
                               ,pr_nmarqpdf => vr_nmarqpdf       --> Retornar quantidad de registros
                               ,pr_cdcritic => vr_cdcritic       --> Código da crítica
                               ,pr_dscritic => vr_dscritic);     --> Descrição da crítica

      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_impres_contrato_limite_web: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_impres_contrato_limite_web;

 -- Rotina referente a renovacao manual do limite de desconto de cheque
  PROCEDURE pc_renovar_lim_desc_cheque(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite IN craplim.vllimite%TYPE --> Valor Limite de Desconto
                                      ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                      ,pr_idorigem IN INTEGER               --> Identificador de Origem
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

  BEGIN

    /* .............................................................................

     Programa: pc_renovar_lim_desc_cheque
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : Ricardo Linhares/
     Data    : Agosto/16.                    Ultima atualizacao: 08/09/2016

     Dados referentes ao programa:

     Frequencia: Sempre que chamada.
     Objetivo  : Rotina referente a renovacao manual do limite de desconto de cheque

     Alteracoes: 08/09/2016 - Alterada procedure para ser chamada sem mensageria.
                              Mensageria será tratada na package criada exclusivamente
                              para a tela. Projeto 300 (Lombardi)

                 03/06/2019 - Atribuir Rating da Central de Risco na renovação (Mario - AMcom).

                 16/08/2019 - P450 - Adicionado na renovação a solicitação da busca do rating 
                              na IBRATAN via pela pc_solicitar_rating_motor
                              (Luiz Otavio Olinger Momm - AMCOM)

                 21/08/2019 - P450 - Adicionado regra de endividamento e efetivação nas
                              renovações (Luiz Otavio Olinger Momm)

    ..............................................................................*/

  DECLARE

    -- Variável para consulta de limite
    vr_tab_lim_desconto dscc0001.typ_tab_lim_desconto;

    --Variaveis auxiliares
    vr_vllimite craplim.vllimite%TYPE;
    vr_nrdrowid ROWID;
    vr_in_risco_rat INTEGER;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis de Log de Alteracao
    vr_flgctitg crapalt.flgctitg%TYPE;
    vr_dsaltera LONG;

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Parametro de Flag Rating Renovacao Ativo: 0-Não Ativo, 1-Ativo
    vr_flg_Rating_Renovacao_Ativo    NUMBER := 0;

    -- Cursor Limite de cheque especial
    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE     --> Código da Cooperativa
                     ,pr_nrdconta IN craplim.nrdconta%TYPE     --> Número da Conta
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS --> Número do Contrato

      SELECT craplim.cddlinha,
             craplim.insitlim,
             craplim.qtrenova,
             craplim.dtrenova,
             craplim.vllimite,
             nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) as dtfimvig
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrlim
         AND craplim.tpctrlim = 2; -- Limite de crédito de desconto de cheque
    rw_craplim cr_craplim%ROWTYPE;

    -- Cursor Linhas de Credito de Desconto de Cheque
    CURSOR cr_crapldc (pr_cdcooper IN craplrt.cdcooper%TYPE,
                       pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT crapldc.flgstlcr
        FROM crapldc
       WHERE crapldc.cdcooper = pr_cdcooper
         AND crapldc.cddlinha = pr_cddlinha
         AND crapldc.tpdescto = 2; -- Cheque

    rw_crapldc cr_crapldc%ROWTYPE;

    -- Cursor Regras do limite de cheque especial
    CURSOR cr_craprli (pr_cdcooper IN craprli.cdcooper%TYPE,
                       pr_inpessoa IN craprli.inpessoa%TYPE) IS
      SELECT qtmaxren
        FROM craprli
       WHERE craprli.cdcooper = pr_cdcooper
         AND craprli.inpessoa = DECODE(pr_inpessoa,3,2,pr_inpessoa)
         AND craprli.tplimite = 2; -- Limite Credito Desconto Cheque

    rw_craprli cr_craprli%ROWTYPE;

    -- Cursor Associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa,
             nrdctitg,
             flgctitg,
             nrcpfcnpj_base,
             cdagenci
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor alteracao de cadastro
    CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT crapalt.dsaltera,
           crapalt.rowid
      FROM crapalt
     WHERE crapalt.cdcooper = pr_cdcooper
       AND crapalt.nrdconta = pr_nrdconta
       AND crapalt.dtaltera = pr_dtmvtolt;

     rw_crapalt cr_crapalt%ROWTYPE;

     vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

     -- P450 Valida Endividamento
     vr_strating     NUMBER;
     vr_flgrating    NUMBER;
     vr_vlendivid    craplim.vllimite%TYPE; -- Valor do Endividamento do Cooperado
     vr_vllimrating  craplim.vllimite%TYPE; -- Valor do Parametro Rating (Limite) TAB056
     -- P450 Valida Endividamento

  BEGIN

    --> Buscar Parametro
    vr_flg_Rating_Renovacao_Ativo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                              ,pr_cdcooper => 0
                                                              ,pr_cdacesso => 'RATING_RENOVACAO_ATIVO');

    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');

    IF(pr_vllimite <= 0) OR pr_vllimite IS NULL THEN
      vr_dscritic := 'Valor do limite inválido.';
      RAISE vr_exc_saida;
    END IF;

    -- Consultar o limite de credito
    OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrlim => pr_nrctrlim);
    FETCH cr_craplim INTO rw_craplim;

    -- Verifica se o limite de credito existe
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_dscritic := 'Associado não possui proposta de limite de desconto cheque.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplim;
    END IF;

    -- Verifica a situacao do limite do cheque especial
    IF nvl(rw_craplim.insitlim,0) <> 2 THEN
      vr_dscritic := 'O contrato de limite de desconto de cheque deve estar ativo.';
      RAISE vr_exc_saida;
    END IF;

    -- Verificacao para saber se jah passou o vencimento do limite para a renovacao
    IF rw_craplim.dtfimvig > pr_dtmvtolt THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao do limite de desconto de cheque. Limite nao esta vencido.';
      RAISE vr_exc_saida;
    END IF;

    --Guarda valor anterior do limite
    vr_vllimite := rw_craplim.vllimite;

    -- Consulta o limite de credito de desconto de cheque
    OPEN cr_crapldc(pr_cdcooper => pr_cdcooper,
                    pr_cddlinha => rw_craplim.cddlinha);
    FETCH cr_crapldc INTO rw_crapldc;

    -- Verifica se o limite de credito existe
    IF cr_crapldc%NOTFOUND THEN
      CLOSE cr_crapldc;
      vr_dscritic := 'Linha de desconto de cheque nao cadastrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapldc;
    END IF;

    -- Verifica se a linha de credito esta liberada
    IF nvl(rw_crapldc.flgstlcr,0) = 0 THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao de limite, linha de desconto bloqueada. Incluir novo limite.';
      RAISE vr_exc_saida;
    END IF;

    -- Consulta o Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    -- Verifica se o limite de credito existe
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Consulta a regra do limite de cheque especial
    OPEN cr_craprli(pr_cdcooper => pr_cdcooper,
                    pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_craprli INTO rw_craprli;
    -- Verifica se o limite de credito existe
    IF cr_craprli%NOTFOUND THEN
      CLOSE cr_craprli;
      vr_dscritic := 'Regras da linha de credito de desconto de cheque nao cadastrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craprli;
    END IF;

    -- Verificar a quantidade maxima que pode renovar
    IF ((nvl(rw_craprli.qtmaxren,0) > 0) AND (nvl(rw_craplim.qtrenova,0) >= nvl(rw_craprli.qtmaxren,0))) THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao do limite. Incluir novo contrato';
      RAISE vr_exc_saida;
    END IF;

    -- Consulta o limite de desconto por tipo de pessoa
    DSCC0001.pc_busca_tab_limdescont(pr_cdcooper => pr_cdcooper                  --> Codigo da cooperativa
                                    ,pr_inpessoa => rw_crapass.inpessoa          --> Tipo de pessoa ( 0 - todos 1-Fisica e 2-Juridica)
                                    ,pr_tab_lim_desconto => vr_tab_lim_desconto  --> Temptable com os dados do limite de desconto
                                    ,pr_cdcritic => vr_cdcritic                  --> Código da crítica
                                    ,pr_dscritic => vr_dscritic);                --> Descrição da crítica

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_saida;
    END IF;

    -- Verifica se o novo limite estipula o limite máximo pelo tipo de pessoa
    IF(pr_vllimite > vr_tab_lim_desconto(rw_crapass.inpessoa).vllimite) THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao de limite, valor excede o limite estipulado.';
      RAISE vr_exc_saida;
    END IF;

    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper <> 3 AND vr_habrat = 'S') THEN

      -- Verifica processamento do Rating Renovacao
      IF vr_flg_Rating_Renovacao_Ativo = 1 THEN

        /*
        Situacao da proposta na Esteira
        0-Nao enviada
        1-Enviada Analise Automatica
        2-Enviada Analise Manual
        3-Analise Finalizada
        4-Expirado
        
        Mura para Nao enviada para enviar para a Ibratan novamente
        */
        BEGIN
          UPDATE crawlim
             SET insitest = 0
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctrlim = pr_nrctrlim
             AND tpctrlim = 2; -- Limite Desconto Cheque

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao renovar o limite de titulo de desconto de titulo: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        rati0003.pc_solicitar_rating_motor( pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => pr_nrdconta,
                                            pr_tpctrato => 2, -- Limite Desconto Cheque
                                            pr_nrctrato => pr_nrctrlim,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_cdagenci => rw_crapass.cdagenci,
                                            pr_dtmvtolt => pr_dtmvtolt,
                                            pr_inpessoa => rw_crapass.inpessoa,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
                                            
        IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic,0) > 0 THEN
          RAISE vr_exc_saida;
        END IF;
        
        /* Validar Status rating */
        RATI0003.pc_busca_status_rating(pr_cdcooper  => pr_cdcooper
                                       ,pr_nrdconta  => pr_nrdconta
                                       ,pr_tpctrato  => 2 -- Limite Desconto Cheque
                                       ,pr_nrctrato  => pr_nrctrlim
                                       ,pr_strating  => vr_strating
                                       ,pr_flgrating => vr_flgrating
                                       ,pr_cdcritic  => vr_cdcritic
                                       ,pr_dscritic  => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;

        -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
        RATI0003.pc_busca_endivid_param(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_vlendivi => vr_vlendivid
                                       ,pr_vlrating => vr_vllimrating
                                       ,pr_dscritic => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;

        -- Status do rating inválido
        IF vr_flgrating = 0 THEN
          vr_dscritic := 'Contrato não pode ser efetivado porque não há Rating válido.';
          RAISE vr_exc_saida;

        ELSE -- Status do rating válido

          -- Se Endividamento + Contrato atual > Parametro Rating (TAB056)
          IF ((vr_vlendivid) > vr_vllimrating) THEN

            -- Gravar o Rating da operação, efetivando-o
            rati0003.pc_grava_rating_operacao(pr_cdcooper          => pr_cdcooper
                                             ,pr_nrdconta          => pr_nrdconta
                                             ,pr_tpctrato          => 2 -- Limite Desconto Cheque
                                             ,pr_nrctrato          => pr_nrctrlim
                                             ,pr_dtrating          => pr_dtmvtolt
                                             ,pr_strating          => 4
                                             ,pr_efetivacao_rating => 1 -- Identificar se deve considerar o parâmetro de contingência
                                             --Variáveis para gravar o histórico
                                             ,pr_cdoperad          => pr_cdoperad
                                             ,pr_dtmvtolt          => pr_dtmvtolt
                                             ,pr_valor             => pr_vllimite
                                             ,pr_rating_sugerido   => NULL
                                             ,pr_justificativa     => 'Renovação de Contrato - Efetivação do Rating'
                                             ,pr_tpoperacao_rating => 2
                                             ,pr_nrcpfcnpj_base    => rw_crapass.nrcpfcnpj_base
                                             --Variáveis de crítica
                                             ,pr_cdcritic          => vr_cdcritic
                                             ,pr_dscritic          => vr_dscritic);

            IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        END IF;

      END IF;
      -- Verifica processamento do Rating Renovacao
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

    -- Atualiza os dados do limite de cheque especial
    BEGIN
      UPDATE craplim
         SET dtinivig = pr_dtmvtolt,
             dtfimvig = pr_dtmvtolt + NVL(qtdiavig,0),
             vllimite = pr_vllimite,
             qtrenova = NVL(qtrenova,0) + 1,
             dtrenova = pr_dtmvtolt,
             tprenova = 'M' -- Manual
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrctrlim
         AND tpctrlim = 2; -- Limite Desconto Cheque

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao renovar o limite de credito de desconto de cheque: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;

    -- Por default fica como 3
    vr_flgctitg  := 3;
    vr_dsaltera  := 'Renov. Manual Limite Desc Cheque. Ctr: ' || pr_nrctrlim || ',';

    -- Se for conta integracao ativa, seta a flag para enviar ao BB
    IF trim(rw_crapass.nrdctitg) IS NOT NULL AND rw_crapass.flgctitg = 2 THEN  -- Ativa
      --Conta Integracao
      vr_flgctitg := 0;
    END IF;

    -- Verifica se jah possui alteracao
    OPEN cr_crapalt (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_dtmvtolt => pr_dtmvtolt);
    FETCH cr_crapalt INTO rw_crapalt;

    IF cr_crapalt%FOUND THEN
      CLOSE cr_crapalt;
      -- Altera o registro
      BEGIN
        UPDATE crapalt SET
               dsaltera = rw_crapalt.dsaltera || vr_dsaltera,
               cdoperad = pr_cdoperad,
               flgctitg = vr_flgctitg
         WHERE rowid = rw_crapalt.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSE
      CLOSE cr_crapalt;
      --Inserir Alteracao
      BEGIN
        INSERT INTO crapalt
          (nrdconta
          ,dtaltera
          ,tpaltera
          ,dsaltera
          ,cdcooper
          ,flgctitg
          ,cdoperad)
        VALUES
          (pr_nrdconta
          ,pr_dtmvtolt
          ,2 -- alterações diversas
          ,vr_dsaltera
          ,pr_cdcooper
          ,vr_flgctitg
          ,pr_cdoperad);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;

    END IF;

    IF vr_vllimite <> pr_vllimite THEN
      -- Inclusão de log com retorno do ROWID
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                          ,pr_dstransa => 'Alteração do valor limite de desconto de cheque.'
                          ,pr_dttransa => trunc(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 0
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Valor Limite'
                               ,pr_dsdadant => to_char(vr_vllimite,'FM999G999G999G999G999D00')
                               ,pr_dsdadatu => to_char(pr_vllimite,'FM999G999G999G999G999D00'));
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
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || pr_nmdatela || ': ' || SQLERRM;
      ROLLBACK;
    END;

  END pc_renovar_lim_desc_cheque;

  -- Rotina referente ao desbloqueio para inclusao de novos borderos
  PROCEDURE pc_desblq_inclusao_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do Caixa
                                      ,pr_cdoperad IN craplgm.cdoperad%TYPE --> Código do operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

    BEGIN

    /* .............................................................................

     Programa: pc_desblq_inclusao_bordero
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : Ricardo Linhares
     Data    : Agosto/16.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que chamada.
     Objetivo  : Rotina referente ao desbloqueio para inclusao de novos borderos
     Alteracoes:
    ..............................................................................*/


    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_tab_erro      gene0001.typ_tab_erro;

    -- Cursor Associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT dtelimin,
             dtdemiss,
             cdagenci,
             vllimcre
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --Tipo da tabela de saldos
    vr_tab_saldo EXTR0001.typ_tab_saldos;

    -- Cursor alteracao de cadastro
    CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT crapalt.dsaltera,
           crapalt.rowid
      FROM crapalt
     WHERE crapalt.cdcooper = pr_cdcooper
       AND crapalt.nrdconta = pr_nrdconta
       AND crapalt.dtaltera = pr_dtmvtolt;

    rw_crapalt cr_crapalt%ROWTYPE;

    -- Variaveis de Log de Alteracao
    vr_flgctitg crapalt.flgctitg%TYPE;
    vr_dsaltera LONG;

    -- saldo disponível
    vr_vlsddisp NUMBER;

   BEGIN

    -- Consulta o Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    -- Verifica a conta do associado
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Verifica se o cooperado está demitido
    IF rw_crapass.dtdemiss IS NOT NULL THEN
      vr_dscritic := 'Operacao nao efetuada. Cooperado Demitido';
      RAISE vr_exc_saida;
    END IF;

    -- Verifica se a conta não está eliminada
    IF rw_crapass.dtelimin IS NOT NULL THEN
      vr_dscritic := 'Operacao nao efetuada. Conta Eliminada.';
      RAISE vr_exc_saida;
    END IF;

   -- Leitura do calendario da cooperativa
     OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Verifica se o saldo está positivo
    extr0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper,
                                pr_rw_crapdat => rw_crapdat,
                                pr_cdagenci => rw_crapass.cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_cdoperad => pr_cdoperad,
                                pr_nrdconta => pr_nrdconta,
                                pr_vllimcre => rw_crapass.vllimcre,
                                pr_dtrefere => rw_crapdat.dtmvtolt,
                                pr_flgcrass => FALSE,
                                pr_tipo_busca => 'A', -- A = Usa dtrefere-1
                                pr_des_reto => vr_dscritic,
                                pr_tab_sald => vr_tab_saldo,
                                pr_tab_erro => vr_tab_erro);

    --Se ocorreu erro
    IF vr_dscritic = 'NOK' THEN
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Operacao nao Efetuada. Nao foi possivel consultar o saldo para a operacao.';
      END IF;
      RAISE vr_exc_saida;
    ELSE
      vr_dscritic:= NULL;
    END IF;
    --Verificar o saldo retornado
    IF vr_tab_saldo.Count = 0 THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Operacao nao Efetuada. Nao foi possivel consultar o saldo para a operacao.';
      RAISE vr_exc_saida;
    ELSE
      vr_vlsddisp := nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                     nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
    END IF;

    -- Verifica se o saldo é positivo
    IF vr_vlsddisp < 0 THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Operacao nao Efetuada. Conta com Saldo Negativo.';
      RAISE vr_exc_saida;
    END IF;

    -- Efetuar desbloqueio
    UPDATE craplim
       SET insitblq = 0
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctrlim = pr_nrctrlim
       AND tpctrlim = 2; -- Limite Desconto Cheque

    vr_flgctitg  := 3;
    vr_dsaltera  := 'Desbloq. Inclusao Bordero. Ctr: ' || pr_nrctrlim || ',';

    -- Atualizar CRAPLAT
    OPEN cr_crapalt (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
    FETCH cr_crapalt INTO rw_crapalt;

    IF cr_crapalt%FOUND THEN
      CLOSE cr_crapalt;
      BEGIN
        UPDATE crapalt SET
               dsaltera = rw_crapalt.dsaltera || vr_dsaltera,
               cdoperad = pr_cdoperad,
               flgctitg = vr_flgctitg
         WHERE rowid = rw_crapalt.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar crapalt. '|| SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSE
      CLOSE cr_crapalt;
      BEGIN
        INSERT INTO crapalt
          (nrdconta
          ,dtaltera
          ,tpaltera
          ,dsaltera
          ,cdcooper
          ,flgctitg
          ,cdoperad)
        VALUES
          (pr_nrdconta
          ,rw_crapdat.dtmvtolt
          ,2 --alterações diversas
          ,vr_dsaltera
          ,pr_cdcooper
          ,vr_flgctitg
          ,pr_cdoperad);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;

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
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || pr_nmdatela || ': ' || SQLERRM;
        ROLLBACK;
      END;

    END pc_desblq_inclusao_bordero;

    -- Rotina referente a consulta de ultimas alteracoes da tela ATENDA
    PROCEDURE pc_ultimas_alteracoes(pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
      cursor c_ultimas_alteracoes(pr_cdcooper in crapcop.cdcooper%TYPE
                                 ,pr_nrdconta in crapass.nrdconta%TYPE) is
        select x.*
             , COUNT(*) OVER (PARTITION BY cdcooper) qtdregis
          from (
        select c.cdcooper
             , c.nrctrlim
             , c.dtinivig
             , c.dtfimvig
             , c.vllimite
             , 'CANCELADO' dssitlli
             -- PRJ 438 - Sprint 13 - Ajustado para trazer o motivo 'Cancelado automaticamente por inadimplência' (Mateus Z / Mouts)
             , case when c.cdmotcan = 1 then 'ALT. DE LIMITE'
                    when c.cdmotcan = 2 then 'PELO ASSOCIADO'
                    when c.cdmotcan = 3 then 'PELA COOPERATIVA'
                    when c.cdmotcan = 4 then 'TRANSFERENCIA C/C'
                    when c.cdmotcan = 0 and c.ininadim = 1 then 'Cancelado automaticamente por inadimplência'
                    else 'DIFERENTE'
               end dsmotivo
             , null dhalteracao
             , o.nmoperad
          from craplim c
             , crapope o
         where c.cdcooper = pr_cdcooper
           and c.nrdconta = pr_nrdconta
           and c.tpctrlim = 1
           and c.insitlim = 3
           and c.nrctrlim <> 0
       and o.cdcooper = c.cdcooper
       and o.cdoperad = decode(c.cdopeexc, ' ', c.cdoperad, c.cdopeexc)
        union
        select t.cdcooper
             , t.nrctrlim
             , x.dtinivig
             , x.dtfimvig
             , x.vllimite
             , 'MAJORACAO' dssitlli
             , ('Limite - '||t.dsvalor_anterior||' --> '||t.dsvalor_novo) dsmotivo
             , t.dhalteracao
       , 'SUPER-USUARIO' nmoperad
          from craplim x
             , tblimcre_historico t
         where x.cdcooper = t.cdcooper
           and x.nrdconta = t.nrdconta
           and x.nrctrlim = t.nrctrlim
           and x.tpctrlim = t.tpctrlim
           and t.nmcampo  = 'vllimite'
           and t.cdcooper = pr_cdcooper
           and t.nrdconta = pr_nrdconta
           and t.tpctrlim = 1
           and t.nrctrlim <> 0
        union
        select t.cdcooper
             , t.nrctrlim
             , x.dtinivig
             , x.dtfimvig
             , x.vllimite
             , 'RENOVACAO' dssitlli
             , ('Renovacao '||' - '||to_char(t.dhalteracao,'DD/MM/RRRR')) dsmotivo
             , t.dhalteracao
       , 'SUPER-USUARIO' nmoperad
          from craplim x
             , tblimcre_historico t
         where x.cdcooper = t.cdcooper
           and x.nrdconta = t.nrdconta
           and x.nrctrlim = t.nrctrlim
           and x.tpctrlim = t.tpctrlim
           and t.nmcampo  = 'dtrenova'
           and t.cdcooper = pr_cdcooper
           and t.nrdconta = pr_nrdconta
           and t.tpctrlim = 1
           and t.nrctrlim <> 0
        union
        select x.cdcooper
             , x.nrctrlim
             , x.dtinivig
             , NULL dtfimvig
             , x.vllimite
             , 'LIMITE ATIVO' dssitlli
             , (' ') dsmotivo
             , null dhalteracao
       , o.nmoperad
          from craplim x
             , crapope o
         where x.cdcooper = pr_cdcooper
           and x.nrdconta = pr_nrdconta
           and x.tpctrlim = 1
           and x.nrctrlim <> 0
           and x.insitlim = 2
       and o.cdcooper = x.cdcooper
           and o.cdoperad = x.cdoperad) x
        order
           by dtfimvig desc, dhalteracao desc;
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(1000);
      vr_contador      NUMBER(5) := 0;
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
    begin
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      for r_ultimas_alteracoes in c_ultimas_alteracoes(vr_cdcooper, pr_nrdconta) loop
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctrlim', pr_tag_cont => r_ultimas_alteracoes.nrctrlim, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtinivig', pr_tag_cont => to_char(r_ultimas_alteracoes.dtinivig,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtfimvig', pr_tag_cont => to_char(r_ultimas_alteracoes.dtfimvig,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vllimite', pr_tag_cont => r_ultimas_alteracoes.vllimite, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dssitlli', pr_tag_cont => r_ultimas_alteracoes.dssitlli, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsmotivo', pr_tag_cont => r_ultimas_alteracoes.dsmotivo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => r_ultimas_alteracoes.nmoperad, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      end loop;
    exception
      when others then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina Ultimas Alteracoes: ' || SQLERRM;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    end pc_ultimas_alteracoes;
    -- Rotina referente a consulta de ultimas alteracoes da tela ATENDA
    PROCEDURE pc_ultima_majoracao(pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
      cursor c_ultima_majoracao(pr_cdcooper in crapcop.cdcooper%TYPE
                               ,pr_nrdconta in crapass.nrdconta%TYPE) is
        select trunc(t.dhalteracao) dtultmaj
          from craplim x
             , tblimcre_historico t
         where x.cdcooper = t.cdcooper
           and x.nrdconta = t.nrdconta
           and x.nrctrlim = t.nrctrlim
           and x.tpctrlim = t.tpctrlim
           and t.nmcampo  = 'vllimite'
           and t.cdcooper = pr_cdcooper
           and t.nrdconta = pr_nrdconta
           and t.tpctrlim = 1
           and t.nrctrlim <> 0
         order
            by t.dhalteracao desc;
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(1000);
      vr_contador      NUMBER(5) := 0;
      vr_dtultmaj      DATE;
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
    begin
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      open c_ultima_majoracao(vr_cdcooper, pr_nrdconta);
      fetch c_ultima_majoracao into vr_dtultmaj;
      if c_ultima_majoracao%notfound then
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtultmaj', pr_tag_cont => ' ', pr_des_erro => vr_dscritic);
      else
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtultmaj', pr_tag_cont => to_char(vr_dtultmaj,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
      end if;
      close c_ultima_majoracao;
    exception
      when others then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da Ultima Majoracao: ' || SQLERRM;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    end pc_ultima_majoracao;



  -- Rotina referente a renovacao manual do limite de desconto de titulo
  PROCEDURE pc_renovar_lim_desc_titulo(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite IN craplim.vllimite%TYPE --> Valor Limite de Desconto
                                      ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                      ,pr_cddlinha IN crapldc.cddlinha%TYPE --> Código da Linha
                                      ,pr_idorigem IN INTEGER               --> Identificador de Origem
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

  BEGIN

    /* .............................................................................

     Programa: pc_renovar_lim_desc_titulo
     Sistema : Rotinas referentes ao limite de titulo
     Autor   : Leonardo Oliveira
     Data    : 03/2018

     Dados referentes ao programa:

     Objetivo  : Rotina referente a renovacao manual do limite de desconto de titulo

     Alteração: 23/08/2018 - Alteraçao na pc_renovar_lim_desc_titulo: Registrar a renovação na tabela de histórico de alteraçao
                             de contrato de limite (Andrew Albuquerque - GFT)

                03/06/2019 - Atribuir Rating da Central de Risco na renovação (Mario - AMcom).

                16/08/2019 - P450 - Adicionado na renovação a solicitação da busca do rating 
                             na IBRATAN via pela pc_solicitar_rating_motor
                             (Luiz Otavio Olinger Momm - AMCOM)

                21/08/2019 - P450 - Adicionado regra de endividamento e efetivação nas
                             renovações (Luiz Otavio Olinger Momm)

    ..............................................................................*/

  DECLARE

    -- Variaveis para calculo da nova data fim da vigencia
    vr_dtfimvig craplim.dtfimvig%TYPE;
    vr_difdias  NUMBER;
    vr_cdlantar craplat.cdlantar%TYPE;

    -- Variável para consulta de limite
    vr_tab_lim_desconto_op dsct0002.typ_tab_dados_dsctit;
    vr_tab_lim_desconto_ai dsct0002.typ_tab_cecred_dsctit;

    --Variaveis auxiliares
    vr_vllimite craplim.vllimite%TYPE;
    vr_nrdrowid ROWID;
    vr_in_risco_rat INTEGER;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis de Log de Alteracao
    vr_flgctitg crapalt.flgctitg%TYPE;
    vr_dsaltera LONG;

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Parametro de Flag Rating Renovacao Ativo: 0-Não Ativo, 1-Ativo
    vr_flg_Rating_Renovacao_Ativo    NUMBER := 0;
    
    -- P450 Valida Endividamento
    vr_strating     NUMBER;
    vr_flgrating    NUMBER;
    vr_vlendivid    craplim.vllimite%TYPE; -- Valor do Endividamento do Cooperado
    vr_vllimrating  craplim.vllimite%TYPE; -- Valor do Parametro Rating (Limite) TAB056
    -- P450 Valida Endividamento


   --     Busca dos dados da cooperativa
   cursor cr_crapcop is
   select cop.nmrescop
         ,cop.nmextcop
         ,cop.nrdocnpj
   from   crapcop cop
   where  cop.cdcooper = pr_cdcooper;
   rw_crapcop cr_crapcop%rowtype;

    -- Cursor Limite de titulo especial
    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE     --> Código da Cooperativa
                     ,pr_nrdconta IN craplim.nrdconta%TYPE     --> Número da Conta
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS --> Número do Contrato

      SELECT craplim.cddlinha,
             craplim.insitlim,
             craplim.qtrenova,
             craplim.dtrenova,
             craplim.vllimite,
             nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) as dtfimvig,
             craplim.qtdiavig
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrlim
         AND craplim.tpctrlim = 3; -- Limite de crédito de desconto de titulo
    rw_craplim cr_craplim%ROWTYPE;

    -- Cursor Linhas de Credito de Desconto de Titulo
    CURSOR cr_crapldc (pr_cdcooper IN craplrt.cdcooper%TYPE,
                       pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT crapldc.flgstlcr
        FROM crapldc
       WHERE crapldc.cdcooper = pr_cdcooper
         AND crapldc.cddlinha = pr_cddlinha
         AND crapldc.tpdescto = 3; -- Titulo

    rw_crapldc cr_crapldc%ROWTYPE;

    -- Cursor Regras do limite de titulo especial
    CURSOR cr_craprli (pr_cdcooper IN craprli.cdcooper%TYPE,
                       pr_inpessoa IN craprli.inpessoa%TYPE) IS
      SELECT qtmaxren
        FROM craprli
       WHERE craprli.cdcooper = pr_cdcooper
         AND craprli.inpessoa = DECODE(pr_inpessoa,3,2,pr_inpessoa)
         AND craprli.tplimite = 3; -- Limite Credito Desconto Titulo

    rw_craprli cr_craprli%ROWTYPE;

    -- Cursor Associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa,
             nrdctitg,
             flgctitg,
             nrcpfcnpj_base,
             cdagenci
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor alteracao de cadastro
    CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT crapalt.dsaltera,
           crapalt.rowid
      FROM crapalt
     WHERE crapalt.cdcooper = pr_cdcooper
       AND crapalt.nrdconta = pr_nrdconta
       AND crapalt.dtaltera = pr_dtmvtolt;

     rw_crapalt cr_crapalt%ROWTYPE;

     -- Cursor genérico de calendário
     rw_crapdat btch0001.cr_crapdat%rowtype;

     vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

   --> Rotina para cobrança das tarifas de renovação de contrato
   PROCEDURE pc_gera_tarifa_renova(pr_cdcooper crapcop.cdcooper%type  --> Código da Cooperativa
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                    ,pr_vllimite IN craplim.vllimite%TYPE --> Valor Limite de Desconto
                                    ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Contrato
                                    ,pr_inpessoa IN craprli.inpessoa%TYPE
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2) IS --> Data de Movimento

        vr_idprglog tbgen_prglog.idprglog%type     := 0;


         -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.nmprimtl,
             crapass.inpessoa,
             crapass.nrcpfcgc,
             crapass.nrdctitg,
             crapass.cdagenci,
             crapass.vllimcre,
             crapass.cdcooper,
             crapass.nrcpfcnpj_base
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

        --> Critica
        vr_cdcritic pls_integer;
        vr_dscritic varchar2(4000);
        vr_tab_erro gene0001.typ_tab_erro;

        -- Variaveis de tarifa
        vr_cdhistor craphis.cdhistor%type;
        vr_cdhisest craphis.cdhistor%type;
        vr_dtdivulg date;
        vr_dtvigenc date;
        vr_cdfvlcop crapfco.cdfvlcop%type;
        vr_vltarifa crapfco.vltarifa%type;

        vr_cdbattar varchar2(10);
        vr_rowid         rowid;
        vr_email_tarif VARCHAR2(300); --> Email da area de taifa.


     BEGIN

        --> buscar os limites renovados hj para cobrança de Tarifa
        --for rw_craplim_tari in cr_craplim_tari loop
            --  1 - Pessoa Fisica
            if  pr_inpessoa = 1 then
                vr_cdbattar := 'DSTRENOVPF'; -- Renovacao contrato pessoa fisica
            else
                vr_cdbattar := 'DSTRENOVPJ'; -- Renovacao contrato pessoa juridica
            end if;

            -- Busca valor da tarifa
            tari0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                                 ,pr_cdbattar => vr_cdbattar
                                                 ,pr_vllanmto => pr_vllimite
                                                 ,pr_cdprogra => 'ATENDA'
                                                 ,pr_cdhistor => vr_cdhistor
                                                 ,pr_cdhisest => vr_cdhisest
                                                 ,pr_vltarifa => vr_vltarifa
                                                 ,pr_dtdivulg => vr_dtdivulg
                                                 ,pr_dtvigenc => vr_dtvigenc
                                                 ,pr_cdfvlcop => vr_cdfvlcop
                                                 ,pr_cdcritic => vr_cdcritic
                                                 ,pr_dscritic => vr_dscritic
                                                 ,pr_tab_erro => vr_tab_erro);

            -- Incluir nome do módulo logado - Chamado 660306 29/06/2017
            gene0001.pc_set_modulo(pr_module => pr_nmdatela
                                  ,pr_action => 'LIMI0001.pc_renovar_lim_desc_titulo');

            --  Se ocorreu erro
            if  vr_cdcritic is not null or trim(vr_dscritic) is not null then
                --  Se possui erro no vetor
                if  vr_tab_erro.count() > 0 then
                    pr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
                    pr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
                    RAISE vr_exc_saida;
                else
                    pr_cdcritic:= 0;
                    pr_dscritic:= 'Nao foi possivel carregar a tarifa.';
                end if;

                -- Se não Existe Tarifa
                RETURN;
            end if;

            --  Verifica se valor da tarifa esta zerado
            if  vr_vltarifa = 0 then
                RETURN;
            end if;

            ---
            -- Criar Lançamento automatico Tarifas de contrato de desconto de titulo
            tari0001.pc_lan_tarifa_online( pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                          ,pr_cdagenci => 1 --Codigo Agencia destino
                                          ,pr_nrdconta => pr_nrdconta--Numero da Conta Destino
                                          ,pr_cdbccxlt => 100--Codigo banco/caixa
                                          ,pr_nrdolote => 10300--Numero do Lote
                                          ,pr_tplotmov => 1--Tipo Lote
                                          ,pr_cdoperad => pr_cdoperad--Codigo Operador
                                          ,pr_dtmvtlat => rw_crapdat.dtmvtolt--Data Tarifa
                                          ,pr_dtmvtlcm => rw_crapdat.dtmvtocd--Data lancamento
                                          ,pr_nrdctabb => pr_nrdconta--Numero Conta BB
                                          ,pr_nrdctitg => gene0002.fn_mask(pr_nrdconta,'99999999')--Conta Integracao
                                          ,pr_cdhistor => vr_cdhistor--Codigo Historico
                                          ,pr_cdpesqbb => 'Fato gerador tarifa:' || to_char(pr_nrctrlim)--Codigo pesquisa
                                          ,pr_cdbanchq => 0--Codigo Banco Cheque
                                          ,pr_cdagechq => 0--Codigo Agencia Cheque
                                          ,pr_nrctachq => 0--Numero Conta Cheque
                                          ,pr_flgaviso => false--Flag Aviso
                                          ,pr_tpdaviso => 0--Tipo Aviso
                                          ,pr_vltarifa => vr_vltarifa--Valor tarifa
                                          ,pr_nrdocmto => 0--Numero Documento
                                          ,pr_cdcoptfn => rw_crapass.cdcooper--Codigo Cooperativa Terminal
                                          ,pr_cdagetfn => rw_crapass.cdagenci--Codigo Agencia Terminal
                                          ,pr_nrterfin => 0--Numero Terminal Financeiro
                                          ,pr_nrsequni => 0--Numero Sequencial Unico
                                          ,pr_nrautdoc => 0--Numero Autenticacao Documento
                                          ,pr_dsidenti => null--Descricao Identificacao
                                          ,pr_cdfvlcop => vr_cdfvlcop--Codigo Faixa Valor Cooperativa
                                          ,pr_inproces => rw_crapdat.inproces--Indicador Processo
                                          ,pr_cdlantar => vr_cdlantar--Codigo Lancamento tarifa
                                          ,pr_tab_erro => vr_tab_erro--Tabela de erro
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic
                                          );

            -- Incluir nome do módulo logado - Chamado 660306 29/06/2017
            GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                                  ,pr_action => 'LIMI0001.pc_renovar_lim_desc_titulo');

            --  Se ocorreu erro
            if  vr_cdcritic is not null or trim(vr_dscritic) is not null then
                --  Se possui erro no vetor
                if  vr_tab_erro.count > 0 then
                    pr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
                    pr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
                    RAISE vr_exc_saida;
                else
                    pr_cdcritic:= 0;
                    pr_dscritic:= 'Erro no lancamento Tarifa de contrato de limite de desconto de titulo';
                end if;
                -- Limpa valores das variaveis de critica
                pr_cdcritic:= 0;
                pr_dscritic:= null;
            end if;

     EXCEPTION
        when others then
             pr_dscritic:= 'Não foi possivel gerar tarifa de renovação: '||sqlerrm;
             -- Envio centralizado de log de erro
             -- Limpa valores das variaveis de critica
             --vr_cdcritic:= 0;
             --vr_dscritic:= null;
     END pc_gera_tarifa_renova;


  BEGIN

    --> Buscar Parametro
    vr_flg_Rating_Renovacao_Ativo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                              ,pr_cdcooper => 0
                                                              ,pr_cdacesso => 'RATING_RENOVACAO_ATIVO');

    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');

    IF(pr_vllimite <= 0) OR pr_vllimite IS NULL THEN
      vr_dscritic := 'Valor do limite inválido.';
      RAISE vr_exc_saida;
    END IF;

    -- Consultar o limite de credito
    OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrlim => pr_nrctrlim);
    FETCH cr_craplim INTO rw_craplim;

    -- Verifica se o limite de credito existe
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_dscritic := 'Associado não possui proposta de limite de desconto titulo.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplim;
    END IF;

    -- Verifica a situacao do limite do titulo especial
    IF nvl(rw_craplim.insitlim,0) <> 2 THEN
      vr_dscritic := 'O contrato de limite de desconto de titulo deve estar ativo.';
      RAISE vr_exc_saida;
    END IF;

    -- diferença entre a data do fim da vigencia e a data de movimentação para calcular vencimento
    vr_difdias := rw_craplim.dtfimvig - pr_dtmvtolt;

    --vencido
    IF (vr_difdias < 0 ) THEN

      IF (vr_difdias < -60 ) THEN
         -- Verificacao para saber se ja se passaram mais de 60 dias limite para a renovacao
         vr_dscritic := 'Nao e possivel realizar a renovacao do limite de desconto de titulo. Ja se passaram 60 dias do fim da vigencia';
         RAISE vr_exc_saida;
         END IF;
      -- calcula o novo fim da vigencia a partir  da data da movimentação
      vr_dtfimvig := pr_dtmvtolt + NVL(rw_craplim.qtdiavig,0);

    -- não vencido
    ELSE

       -- Verificacao para saber se faltam mais que 15 dias para o vencimento do limite para a renovacao
       IF (vr_difdias > 15 ) THEN
          vr_dscritic := 'Nao e possivel realizar a renovacao do limite de desconto de titulo. Faltam mais que 15 dias para o limite ';
          RAISE vr_exc_saida;
       END IF;

          -- calcula o novo fim da vigencia a partir do fim da vigencia atual
          vr_dtfimvig := rw_craplim.dtfimvig + NVL(rw_craplim.qtdiavig,0);
    END IF;-- fim verificacao vencimento

    --Guarda valor anterior do limite
    vr_vllimite := rw_craplim.vllimite;

    -- Consulta o limite de credito de desconto de titulo
    OPEN cr_crapldc(pr_cdcooper => pr_cdcooper,
                    pr_cddlinha => pr_cddlinha);--rw_craplim.cddlinha
    FETCH cr_crapldc INTO rw_crapldc;

    -- Verifica se o limite de credito existe
    IF cr_crapldc%NOTFOUND THEN
      CLOSE cr_crapldc;
      vr_dscritic := 'Linha de desconto de titulo nao cadastrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapldc;
    END IF;

    -- Verifica se a linha de credito esta liberada
    IF nvl(rw_crapldc.flgstlcr,0) = 0 THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao de limite, linha de desconto bloqueada. Incluir novo limite.';
      RAISE vr_exc_saida;
    END IF;

    -- Consulta o Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    -- Verifica se o limite de credito existe
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Consulta a regra do limite de titulo especial
    OPEN cr_craprli(pr_cdcooper => pr_cdcooper,
                    pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_craprli INTO rw_craprli;
    -- Verifica se o limite de credito existe
    IF cr_craprli%NOTFOUND THEN
      CLOSE cr_craprli;
      vr_dscritic := 'Regras da linha de credito de desconto de titulo nao cadastrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craprli;
    END IF;

    -- Verificar a quantidade maxima que pode renovar
    IF ((nvl(rw_craprli.qtmaxren,0) > 0) AND (nvl(rw_craplim.qtrenova,0) >= nvl(rw_craprli.qtmaxren,0))) THEN
      vr_dscritic := 'Não é possível realizar a renovação do limite. A quantidade de renovações do limite '||
                     ' excedeu a quantidade máxima permitida. Incluir novo contrato';
      RAISE vr_exc_saida;
    END IF;

    -- Consulta o limite de desconto por tipo de pessoa
    /*
    DSCC0001.pc_busca_tab_limdescont(pr_cdcooper => pr_cdcooper                  --> Codigo da cooperativa
                                    ,pr_inpessoa => rw_crapass.inpessoa          --> Tipo de pessoa ( 0 - todos 1-Fisica e 2-Juridica)
                                    ,pr_tab_lim_desconto => vr_tab_lim_desconto  --> Temptable com os dados do limite de desconto
                                    ,pr_cdcritic => vr_cdcritic                  --> Código da crítica
                                    ,pr_dscritic => vr_dscritic);                --> Descrição da crítica
    */

    -- Busca os Parâmetros para o Cooperado e Cobrança Com Registro
    dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                        NULL, --Agencia de operação
                                        NULL, --Número do caixa
                                        NULL, --Operador
                                        NULL, -- Data da Movimentação
                                        NULL, --Identificação de origem
                                        1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                        rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                        vr_tab_lim_desconto_op,
                                        vr_tab_lim_desconto_ai,
                                        vr_cdcritic,
                                        vr_dscritic);


    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_saida;
    END IF;

    -- Verifica se o novo limite estipula o limite máximo pelo tipo de pessoa
    IF(pr_vllimite > vr_tab_lim_desconto_op(1).vllimite) THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao de limite, valor excede o limite estipulado.';
      RAISE vr_exc_saida;
    END IF;

    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper <> 3 AND vr_habrat = 'S') THEN

      -- Verifica processamento do Rating Renovacao
      IF vr_flg_Rating_Renovacao_Ativo = 1 THEN

        /*
        Situacao da proposta na Esteira
        0-Nao enviada
        1-Enviada Analise Automatica
        2-Enviada Analise Manual
        3-Analise Finalizada
        4-Expirado
        
        Mura para Nao enviada para enviar para a Ibratan novamente
        */
        BEGIN
          UPDATE crawlim
             SET insitest = 0
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctrlim = pr_nrctrlim
             AND tpctrlim = 3; -- Limite Desconto Titulo

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao renovar o limite de titulo de desconto de titulo: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        rati0003.pc_solicitar_rating_motor( pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => pr_nrdconta,
                                            pr_tpctrato => 3, -- Limite Desconto Titulo
                                            pr_nrctrato => pr_nrctrlim,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_cdagenci => rw_crapass.cdagenci,
                                            pr_dtmvtolt => pr_dtmvtolt,
                                            pr_inpessoa => rw_crapass.inpessoa,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
                                            
        IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic,0) > 0 THEN
          RAISE vr_exc_saida;
        END IF;

        /* Validar Status rating */
        RATI0003.pc_busca_status_rating(pr_cdcooper  => pr_cdcooper
                                       ,pr_nrdconta  => pr_nrdconta
                                       ,pr_tpctrato  => 3 -- Limite Desconto Titulo
                                       ,pr_nrctrato  => pr_nrctrlim
                                       ,pr_strating  => vr_strating
                                       ,pr_flgrating => vr_flgrating
                                       ,pr_cdcritic  => vr_cdcritic
                                       ,pr_dscritic  => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;

        -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
        RATI0003.pc_busca_endivid_param(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_vlendivi => vr_vlendivid
                                       ,pr_vlrating => vr_vllimrating
                                       ,pr_dscritic => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;

        -- Status do rating inválido
        IF vr_flgrating = 0 THEN
          vr_dscritic := 'Contrato não pode ser efetivado porque não há Rating válido.';
          RAISE vr_exc_saida;

        ELSE -- Status do rating válido

          -- Se Endividamento + Contrato atual > Parametro Rating (TAB056)
          IF ((vr_vlendivid) > vr_vllimrating) THEN

            -- Gravar o Rating da operação, efetivando-o
            rati0003.pc_grava_rating_operacao(pr_cdcooper          => pr_cdcooper
                                             ,pr_nrdconta          => pr_nrdconta
                                             ,pr_tpctrato          => 3 -- Limite Desconto Titulo
                                             ,pr_nrctrato          => pr_nrctrlim
                                             ,pr_dtrating          => pr_dtmvtolt
                                             ,pr_strating          => 4
                                             ,pr_efetivacao_rating => 1 -- Identificar se deve considerar o parâmetro de contingência
                                             --Variáveis para gravar o histórico
                                             ,pr_cdoperad          => pr_cdoperad
                                             ,pr_dtmvtolt          => pr_dtmvtolt
                                             ,pr_valor             => pr_vllimite
                                             ,pr_rating_sugerido   => NULL
                                             ,pr_justificativa     => 'Renovação de Contrato - Efetivação do Rating'
                                             ,pr_tpoperacao_rating => 2
                                             ,pr_nrcpfcnpj_base    => rw_crapass.nrcpfcnpj_base
                                             --Variáveis de crítica
                                             ,pr_cdcritic          => vr_cdcritic
                                             ,pr_dscritic          => vr_dscritic);

            IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        END IF;

      END IF;
      -- Verifica processamento do Rating Renovacao
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo
    
    -- Atualiza os dados do limite de titulo especial
    BEGIN
      UPDATE craplim
         SET dtinivig = pr_dtmvtolt,
             dtfimvig = vr_dtfimvig,
             vllimite = pr_vllimite,
             qtrenova = NVL(qtrenova,0) + 1,
             dtrenova = pr_dtmvtolt,
             tprenova = 'M', -- Manual
             cddlinha = pr_cddlinha
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrctrlim
         AND tpctrlim = 3; -- Limite Desconto Titulo

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao renovar o limite de titulo de desconto de titulo: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;

    -- Por default fica como 3
    vr_flgctitg  := 3;
    vr_dsaltera  := 'Renov. Manual Limite Desc Titulo. Ctr: ' || pr_nrctrlim || ',';

    -- Se for conta integracao ativa, seta a flag para enviar ao BB
    IF trim(rw_crapass.nrdctitg) IS NOT NULL AND rw_crapass.flgctitg = 2 THEN  -- Ativa
      --Conta Integracao
      vr_flgctitg := 0;
    END IF;

    -- Verifica se jah possui alteracao
    OPEN cr_crapalt (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_dtmvtolt => pr_dtmvtolt);
    FETCH cr_crapalt INTO rw_crapalt;

    IF cr_crapalt%FOUND THEN
      CLOSE cr_crapalt;
      -- Altera o registro
      BEGIN
        UPDATE crapalt SET
               dsaltera = rw_crapalt.dsaltera || vr_dsaltera,
               cdoperad = pr_cdoperad,
               flgctitg = vr_flgctitg
         WHERE rowid = rw_crapalt.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSE
      CLOSE cr_crapalt;
      --Inserir Alteracao
      BEGIN
        INSERT INTO crapalt
          (nrdconta
          ,dtaltera
          ,tpaltera
          ,dsaltera
          ,cdcooper
          ,flgctitg
          ,cdoperad)
        VALUES
          (pr_nrdconta
          ,pr_dtmvtolt
          ,2 -- alterações diversas
          ,vr_dsaltera
          ,pr_cdcooper
          ,vr_flgctitg
          ,pr_cdoperad);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;

    END IF;

    IF vr_vllimite <> pr_vllimite THEN
      -- Inclusão de log com retorno do ROWID
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                          ,pr_dstransa => 'Alteração do valor limite de desconto de titulo.'
                          ,pr_dttransa => trunc(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 0
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Valor Limite'
                               ,pr_dsdadant => to_char(vr_vllimite,'FM999G999G999G999G999D00')
                               ,pr_dsdadatu => to_char(pr_vllimite,'FM999G999G999G999G999D00'));
    END IF;

   --    Leitura do calendário da cooperativa
   open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
   fetch btch0001.cr_crapdat into rw_crapdat;
   if    btch0001.cr_crapdat%notfound then
         close btch0001.cr_crapdat;
         vr_dscritic:= 'Não foi possivel recuperar Data do sistema. '||SQLERRM;
         raise vr_exc_saida;
   end   if;
   close btch0001.cr_crapdat;

    --> Rotina para cobrança das tarifas de renovação de contrato
   pc_gera_tarifa_renova(pr_cdcooper => pr_cdcooper                  --> Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt                 --> Data de Movimento
                         ,pr_nrdconta => pr_nrdconta                 --> Número da Conta
                         ,pr_vllimite => pr_vllimite                 --> Valor Limite de Desconto
                         ,pr_nrctrlim => pr_nrctrlim                 --> Contrato
                         ,pr_inpessoa => rw_crapass.inpessoa         --> Tipo de Pessoa
                         ,pr_cdcritic => vr_cdcritic                 --> Código da crítica
                         ,pr_dscritic => vr_dscritic);               --> Descrição da crítica

    -- awae: Gerar histórico de Majoração/manutenção de Proposta.
    cecred.tela_atenda_dscto_tit.pc_gravar_hist_alt_limite(pr_cdcooper => pr_cdcooper
                                                          ,pr_nrdconta => pr_nrdconta
                                                          ,pr_nrctrlim => pr_nrctrlim
                                                          ,pr_tpctrlim => 3 -- Limite Desconto Titulo
                                                          ,pr_dsmotivo => 'RENOVAÇÃO MANUAL'
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic
                                                          );

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic,0) > 0 THEN
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
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || pr_nmdatela || ': ' || SQLERRM;
      ROLLBACK;
    END;

  END pc_renovar_lim_desc_titulo;

   PROCEDURE pc_busca_limite_conta(pr_nrdconta IN craplim.nrdconta%TYPE --> Numero da conta
                                  ,
                                   pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,
                                   pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,
                                   pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,
                                   pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,
                                   pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,
                                   pr_des_erro OUT VARCHAR2) IS

     /* .............................................................................

        Programa: pc_busca_limite_conta
        Sistema : Cadastro - Cooperativa de Credito
        Sigla   : CRED
        Autor   : Leonardo Zippert - Mouts
        Data    : 27/11/2018                        Ultima atualizacao: 24/06/2019

        Dados referentes ao programa:

        Frequencia: Diaria - Sempre que for chamada
        Objetivo  : Rotina para retornar uma lista de limites do cooperado (Somente Ativos e Pendente de Analise).
     
        Alteracoes: 24/06/2019 - Remover o caracter especial '' da coluna observação. PRJ 438 (Mateus Z / Mouts)    
     ............................................................................. */

     -- Buscar os limites ativos e pendentes de aprovacao
     CURSOR cr_craplim(pr_cdcooper craplim.cdcooper%type) IS
       select CRAPLIM.DTPROPOS,
              CRAPLIM.DTINIVIG,
              CRAPLIM.NRCTRLIM,
              CRAPLIM.VLLIMITE,
              CRAPLRT.TXMENSAL,
              CRAPLIM.DTFIMVIG,
              CRAPLIM.DTRENOVA,
              DECODE(INSITLIM,
                     1,
                     'ESTUDO',
                     2,
                     'ATIVO',
                     3,
                     'CANCELADO',
                     'DIFERENTE') INSITLIM,
              INSITLIM LFGSITUA,
              crapass.inpessoa,
              craplrt.qtdiavig,
              CRAPLRT.cddlinha,
              CRAPLRT.dsdlinha,
              CRAPLRT.txjurfix,
              CRAPLIM.nrinfcad,
              CRAPLIM.nrgarope,
              CRAPLIM.nrliquid,
              CRAPLIM.nrpatlvr,
              CRAPLIM.nrperger,
              'A' nivrisco,
              CRAPLIM.idcobope,
              gene0007.fn_caract_acento(crapprp.dsobserv##1, 1, '') dsobserv
         from craplim,
              CRAPLRT,
              crapass,
              crapprp
        where craplim.cdcooper = pr_cdcooper
          and craplim.nrdconta = pr_nrdconta
          and craplim.tpctrlim = 1 -- Apenas limites de crédito
          and craplim.insitlim in (1, 2)
          and CRAPLRT.cdcooper = craplim.cdcooper
          and CRAPLRT.Cddlinha = craplim.cddlinha
          and crapass.cdcooper = craplim.cdcooper
          and crapass.nrdconta = craplim.nrdconta
          and crapprp.cdcooper = craplim.cdcooper
          and crapprp.nrdconta = craplim.nrdconta
          and crapprp.nrctrato = craplim.nrctrlim
        order by craplim.insitlim desc;

        cursor cr_tip_pessoa(pr_cdcooper craplim.cdcooper%type) is
        select crapass.inpessoa
        from crapass
        where crapass.cdcooper = pr_cdcooper
        and crapass.nrdconta = pr_nrdconta;

     CURSOR cr_operacoes(vr_cdcooper IN INTEGER,
                         vr_nrdconta IN INTEGER,
                         vr_tpctrato IN INTEGER,
                         vr_nrctremp IN INTEGER) IS
        SELECT oper.inrisco_rating_autom,
               UPPER(t1.dscodigo)   origem_rating,
               UPPER(t2.dscodigo)   desc_sit
          FROM tbrisco_operacoes    oper
              ,tbgen_dominio_campo  t1
              ,tbgen_dominio_campo  t2
         WHERE
               oper.tpctrato = vr_tpctrato
           AND oper.cdcooper = vr_cdcooper
           AND oper.nrdconta = vr_nrdconta
           AND oper.nrctremp = vr_nrctremp
           AND t1.nmdominio (+) = 'INORIGEM_RATING'
           AND t1.cddominio (+) = oper.inorigem_rating
           AND t2.nmdominio (+) = 'INSITUACAO_RATING'
           AND t2.cddominio (+) = oper.insituacao_rating;
    rw_operacoes cr_operacoes%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_saida exception;
    vr_origem_rating  VARCHAR2(100);
    vr_desc_sit       VARCHAR2(100);
    vr_desc_rating    VARCHAR2(2);
    vr_inrisco_rating INTEGER;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dsorigem VARCHAR2(1000);

    -- Variaveis gerais
    vr_contador PLS_INTEGER := 0;
    vr_tp_pessoa crapass.inpessoa%type;

    vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

   BEGIN

   gene0001.pc_informa_acesso(pr_module => 'LIMI0001');

    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => vr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');
 

    -- Gerar lista de saida com os limites encontrados.
    FOR rw_craplim in cr_craplim(vr_cdcooper) LOOP
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtpropos', pr_tag_cont => to_char(rw_craplim.dtpropos,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtinivig', pr_tag_cont => to_char(rw_craplim.dtinivig,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctrlim', pr_tag_cont => to_char(rw_craplim.nrctrlim), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vllimite', pr_tag_cont => to_char(rw_craplim.vllimite,'999G999D99MI'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'txmensal', pr_tag_cont => to_char(rw_craplim.txmensal), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtfimvig', pr_tag_cont => to_char(rw_craplim.dtfimvig,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtrenova', pr_tag_cont => to_char(rw_craplim.dtrenova,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'insitlim', pr_tag_cont => to_char(rw_craplim.insitlim), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'lfgsitua', pr_tag_cont => to_char(rw_craplim.lfgsitua), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'inpessoa', pr_tag_cont => to_char(rw_craplim.inpessoa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtdiavig', pr_tag_cont => to_char(rw_craplim.qtdiavig), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cddlinha', pr_tag_cont => to_char(rw_craplim.cddlinha), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsdlinha', pr_tag_cont => to_char(rw_craplim.dsdlinha), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'txjurfix', pr_tag_cont => to_char(rw_craplim.txjurfix), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nivrisco', pr_tag_cont => to_char(rw_craplim.nivrisco), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrgarope', pr_tag_cont => to_char(rw_craplim.nrgarope), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrinfcad', pr_tag_cont => to_char(rw_craplim.nrinfcad), pr_des_erro => vr_dscritic); -- bruno - prj 438 - sprint 7 - tela rating
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrliquid', pr_tag_cont => to_char(rw_craplim.nrliquid), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrpatlvr', pr_tag_cont => to_char(rw_craplim.nrpatlvr), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrperger', pr_tag_cont => to_char(rw_craplim.nrperger), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idcobope', pr_tag_cont => to_char(rw_craplim.idcobope), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsobserv', pr_tag_cont => to_char(rw_craplim.dsobserv), pr_des_erro => vr_dscritic);

      -- P450 SPT13 - alteracao para habilitar rating novo
      IF (vr_cdcooper <> 3 AND vr_habrat = 'S') THEN
        vr_inrisco_rating := NULL;
        vr_origem_rating := NULL;
        vr_desc_sit:= NULL;

        -- busco informações de operações
        OPEN cr_operacoes(vr_cdcooper => vr_cdcooper,
                          vr_nrdconta => pr_nrdconta,
                          vr_tpctrato => 1,
                          vr_nrctremp => rw_craplim.nrctrlim);
        FETCH cr_operacoes
         INTO vr_inrisco_rating, vr_origem_rating, vr_desc_sit ;
        CLOSE cr_operacoes;

        -- Nota do Rating
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'pr_dsrisco_rating',
                               pr_tag_cont =>  cecred.risc0004.fn_traduz_risco(vr_inrisco_rating),
                               pr_des_erro => vr_dscritic);
       -- Origem Rating
       gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'pr_origem_rating',
                           pr_tag_cont => to_char(vr_origem_rating),
                           pr_des_erro => vr_dscritic);
        -- descrição Situação
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'pr_desc_sit',
                               pr_tag_cont => to_char(vr_desc_sit),
                               pr_des_erro => vr_dscritic);
      END IF;
      -- P450 SPT13 - alteracao para habilitar rating novo

      vr_contador := vr_contador + 1;

    END LOOP;

    if vr_contador = 0 then

      open cr_tip_pessoa(vr_cdcooper);
      fetch cr_tip_pessoa into vr_tp_pessoa;
      close cr_tip_pessoa;

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'inpessoa', pr_tag_cont => to_char(vr_tp_pessoa), pr_des_erro => vr_dscritic);

    end if;


    pr_des_erro := 'OK';


   EXCEPTION WHEN vr_exc_saida THEN
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
                                   '<Root><Erro>' || pr_dscritic ||
                                   '</Erro></Root>');
  WHEN OTHERS THEN
    cecred.pc_internal_exception(3);
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := 'Erro geral em LIMI0001.pc_busca_limite_conta.';
    pr_des_erro := 'NOK';

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic ||
                                   '</Erro></Root>');
   END pc_busca_limite_conta;

   PROCEDURE pc_busca_dados_lim_pf(pr_nrdconta IN craplim.nrdconta%TYPE --> Numero da conta
                                  ,
                                   pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,
                                   pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,
                                   pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,
                                   pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,
                                   pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,
                                   pr_des_erro OUT VARCHAR2) IS

     /* .............................................................................

        Programa: pc_busca_dados_lim_pf
        Sistema : Cadastro - Cooperativa de Credito
        Sigla   : CRED
        Autor   : Leonardo Zippert - Mouts
        Data    : 29/11/2018                        Ultima atualizacao:

        Dados referentes ao programa:

        Frequencia: Diaria - Sempre que for chamada
        Objetivo  : Buscar -> salario titular / salario conjuge / outras rendas / indicador se paga aluguel;

        Alteracoes:
     ............................................................................. */


     -- Cursor que tras as informacoes do cooperado titular
     cursor c_conta_principal(pr_cdcooper in craplim.cdcooper%type) is
      select *
      from crapttl
      where cdcooper = pr_cdcooper
      and nrdconta = pr_nrdconta
      and idseqttl = 1;

      -- Buscar informacao do conjuge
      cursor c_dados_conjuge(pr_cdcooper in craplim.cdcooper%type) is
      select nrctacje, vlsalari
      from crapcje
      where cdcooper = pr_cdcooper
      and nrdconta = pr_nrdconta
      and idseqttl = 1;

      -- Se o conjuge tambem tiver conta
      cursor c_dados_ttl_cjg(pr_cdcooper in craplim.cdcooper%type,
                             pr_nrctacje in craplim.nrdconta%type) is
      select vlsalari
      from crapttl
      where cdcooper = pr_cdcooper
      and nrdconta = pr_nrctacje
      and idseqttl = 1;

      -- Verificar se o mesmo tem casa propria ou aluguel
      cursor c_paga_alguel(pr_cdcooper in craplim.cdcooper%type) is
      select decode(incasprp,3,'S','N') incasprp, vlalugue
      from crapenc
      where cdcooper = pr_cdcooper
      and nrdconta = pr_nrdconta
      and idseqttl = 1
      and tpendass = 10; -- 10 Residencial

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(4000);
      vr_exc_saida exception;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_dsorigem VARCHAR2(1000);

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;

      vr_cont_cjg crapcje.nrctacje%type;
      vr_sal_cjg  crapcje.vlsalari%type;
      vr_ren_tit  crapttl.vlsalari%type;
      vr_ind_alg  varchar2(1);
      vr_aluguel  crapenc.vlalugue%type;

      r_conta c_conta_principal%rowtype;


     begin


        gene0001.pc_informa_acesso(pr_module => 'LIMI0001');

        -- Extrai os dados vindos do XML
        GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
                                 pr_cdcooper => vr_cdcooper,
                                 pr_nmdatela => vr_nmdatela,
                                 pr_nmeacao  => vr_nmeacao,
                                 pr_cdagenci => vr_cdagenci,
                                 pr_nrdcaixa => vr_nrdcaixa,
                                 pr_idorigem => vr_idorigem,
                                 pr_cdoperad => vr_cdoperad,
                                 pr_dscritic => vr_dscritic);

        vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        -- Se o titular da conta nao tiver informação sai com erro.
        open c_conta_principal(vr_cdcooper);
        fetch c_conta_principal into r_conta;
        if c_conta_principal%notfound then
          close c_conta_principal;
          vr_dscritic := 'Não Encontrado dados da conta do titular.';
          raise vr_exc_saida;
        end if;
        close c_conta_principal;

        -- Soma todos os outros rendimentos do Titular (Outras Rendas)
        vr_ren_tit := r_conta.vldrendi##1+ r_conta.vldrendi##2+ r_conta.vldrendi##3+ r_conta.vldrendi##4+ r_conta.vldrendi##5+ r_conta.vldrendi##6;

        -- Busca dados do Conjuge
        open c_dados_conjuge(vr_cdcooper);
        fetch c_dados_conjuge into vr_cont_cjg, vr_sal_cjg;
        close c_dados_conjuge;

        -- Se o conjuge tiver uma conta entao busca informacao de renda na ttl
        if vr_cont_cjg is not null and vr_cont_cjg > 0 then
          open c_dados_ttl_cjg(vr_cdcooper,vr_cont_cjg);
          fetch c_dados_ttl_cjg into vr_sal_cjg;
          close c_dados_ttl_cjg;
        end if;

        -- Verifica se o titular paga aluguel
        open c_paga_alguel(vr_cdcooper);
        fetch c_paga_alguel into vr_ind_alg, vr_aluguel;
        close c_paga_alguel;

        -- Registro Unico.
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlsaltit', pr_tag_cont => to_char(r_conta.vlsalari,'999G999D99MI'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlrentit', pr_tag_cont => to_char(vr_ren_tit,'999G999D99MI'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlrencjg', pr_tag_cont => to_char(nvl(vr_sal_cjg,0),'999G999D99MI'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idpgtalg', pr_tag_cont => nvl(vr_ind_alg,'N'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlalugue', pr_tag_cont => to_char(nvl(vr_aluguel,'0'),'999G999D99MI'), pr_des_erro => vr_dscritic);

       pr_des_erro := 'OK';

   EXCEPTION WHEN vr_exc_saida THEN
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
                                   '<Root><Erro>' || pr_dscritic ||
                                   '</Erro></Root>');
  WHEN OTHERS THEN
    cecred.pc_internal_exception(3);
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := 'Erro geral em LIMI0001.pc_busca_dados_lim_pf.';
    pr_des_erro := 'NOK';

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic ||
                                   '</Erro></Root>');
  end pc_busca_dados_lim_pf;

  PROCEDURE pc_busca_dados_lim_pj(pr_nrdconta IN craplim.nrdconta%TYPE --> Numero da conta
                                  ,
                                   pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,
                                   pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,
                                   pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,
                                   pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,
                                   pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,
                                   pr_des_erro OUT VARCHAR2) IS

     /* .............................................................................

        Programa: pc_busca_dados_lim_pf
        Sistema : Cadastro - Cooperativa de Credito
        Sigla   : CRED
        Autor   : Leonardo Zippert - Mouts
        Data    : 30/11/2018                        Ultima atualizacao:

        Dados referentes ao programa:

        Frequencia: Diaria - Sempre que for chamada
        Objetivo  : Buscar -> Faturamento da Empresa;

        Alteracoes:
     ............................................................................. */


     -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(4000);
      vr_exc_saida exception;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_dsorigem VARCHAR2(1000);

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_exception gene0001.typ_tab_erro;
      vr_vlmedfat NUMBER(25,2);

     begin


        gene0001.pc_informa_acesso(pr_module => 'LIMI0001');

        -- Extrai os dados vindos do XML
        GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
                                 pr_cdcooper => vr_cdcooper,
                                 pr_nmdatela => vr_nmdatela,
                                 pr_nmeacao  => vr_nmeacao,
                                 pr_cdagenci => vr_cdagenci,
                                 pr_nrdcaixa => vr_nrdcaixa,
                                 pr_idorigem => vr_idorigem,
                                 pr_cdoperad => vr_cdoperad,
                                 pr_dscritic => vr_dscritic);

        vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

          cada0001.pc_calcula_faturamento(pr_cdcooper => vr_cdcooper  -- Codigo Cooperativa
                                  ,pr_cdagenci => vr_cdagenci  -- Codigo Agencia
                                  ,pr_nrdcaixa => vr_nrdcaixa  -- Numero Caixa
                                  ,pr_nrdconta => pr_nrdconta  -- Numero da Conta
                                  ,pr_vlmedfat => vr_vlmedfat  -- Valor medio faturamento
                                  ,pr_tab_erro => vr_exception -- Tabela Erro
                                  ,pr_des_reto => vr_dscritic);

         IF vr_dscritic <> 'OK' THEN
           vr_dscritic := 'Erro ao chamar cada0001.pc_calcula_faturamento';
           RAISE vr_exc_saida;
         END IF;

         -- Registro Unico.
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlmedfat', pr_tag_cont => to_char(nvl(vr_vlmedfat,0),'999G999G999D99MI'), pr_des_erro => vr_dscritic);

        pr_des_erro := 'OK';

     EXCEPTION WHEN vr_exc_saida THEN
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
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
     WHEN OTHERS THEN
        cecred.pc_internal_exception(3);
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em LIMI0001.pc_busca_dados_lim_pj.';
        pr_des_erro := 'NOK';

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
     end pc_busca_dados_lim_pj;



END LIMI0001;
/
