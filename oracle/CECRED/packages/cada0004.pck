CREATE OR REPLACE PACKAGE CECRED."CADA0004" is
 /* ---------------------------------------------------------------------------------------------------------------

    Programa : CADA0004
    Sistema  : Rotinas para detalhes de cadastros
    Sigla    : CADA
    Autor    : Odirlei Busana - AMcom
    Data     : Agosto/2015.                   Ultima atualizacao: 15/05/2019

   Dados referentes ao programa:

   Frequencia: -----
   Objetivo  : Rotinas para buscar detalhes de cadastros

   Alteracoes:   10/11/2015 - Incluido verificacao para impressao de termo de
                              responsabilidade na procedure pc_obtem_mensagens_alerta.
                              (Jean Michel).

                 01/12/2015 - Ajustes para projeto de assinatura multipla PJ.
                              Baseado na condicao da atenda.p em funcao
                              fn_situacao_senha. (Jorge/David)

                 12/04/2016 - Incluido rotina PC_GERA_LOG_OPE_CARTAO (Andrino - Projeto 290
                              Caixa OnLine)

                 29/09/2019 - Inclusao de verificacao de contratos de acordos de
                              empréstimos na procedure pc_obtem_mensagens_alerta,
                              Prj. 302 (Jean Michel).

                 14/11/2016 - M172 - Atualização Telefone no Auto Atendimento (Guilherme/SUPERO)

                 25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
                              crapass, crapttl, crapjur
                              (Adriano - P339).

                 23/06/2017 - Ajuste para inclusao do novo tipo de situacao da conta
                              "Desligamento por determinação do BACEN"
                              ( Jonata - RKAM P364).

                 12/12/2017 - Alterar para varchar2 o campo nrcartao na procedure
                              pc_gera_log_ope_cartao (Lucas Ranghetti #810576)

                 03/04/2018 - Adicionado NOTI0001.pc_cria_notificacao

                 27/04/2018 - Removido vetor para armazenar a descrição das situacoes
                              da conta. PRJ366 (Lombardi).

                 23/05/2018 - Mensagem quando ocorre prejuízo em conta corrente e empréstimo
                              Diego Simas - AMcom

                 30/05/2018 - Adição da procedure convertida de progress para Oracle pc_bloquear_cartao_magnetico
                              Rangel Decker

                 05/06/2018 - Inclusão do campo vr_insituacprvd no retorno da
                              pc_carrega_dados_atenda (Claudio CIS Corporate)

                 23/06/2018 - Rename da tabela tbepr_cobranca para tbrecup_cobranca e filtro tpproduto = 0 (Paulo Penteado GFT)

                 04/09/2018 - Atualizar DTINICIO_CREDITO ao atualizar TBCOTAS_DEVOLUCAO.
                              (Alcemir - Mout's : SM 364)

                 11/10/2018 - Incluido opção 6-Pagamento na tabela de log tbcrd_log_operacao.
                              (Reinert)

                 15/11/2018 - Inclusão do campo reciproc no retorno da
                              pc_carrega_dados_atenda (Andre Clemer - Supero)

                 23/11/2018 - P442 - Retorno do Score Behaviour do Cooperado (Marcos-Envolti)

                 12/12/2018 - Criado Procedure para salvar a data da assinatura eletronica TA Online. (Anderson-Alan Supero P432)

                 13/02/2019 - XSLProcessor

                 15/05/2019 - Merge branch P433 - API de Cobrança (Cechet)
  ---------------------------------------------------------------------------------------------------------------*/

  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  --TempTable para retornar valores para tela Atenda (Antigo b1wgen0001tt.i/tt-valores_conta)
  TYPE typ_rec_valores_conta
    IS RECORD ( vlsldcap NUMBER(32,8),
                vlsldepr NUMBER(32,8),
                vlsldapl NUMBER(32,8),
                vlsldinv NUMBER(32,8),
                vlsldppr NUMBER(32,8),
                vlstotal NUMBER(32,8),
                vllimite NUMBER(32,8),
                qtfolhas NUMBER(32,8),
                qtconven NUMBER(32,8),
                flgocorr INTEGER,
                dssitura VARCHAR2(100),
                vllautom NUMBER(32,8),
                dssitnet VARCHAR2(100),
                vltotpre NUMBER(32,8),
                vltotccr NUMBER(32,8),
                qtcarmag INTEGER,
                qttotseg NUMBER(18),
                vltotseg NUMBER(32,8),
                vltotdsc NUMBER(32,8),
                flgbloqt INTEGER,
                vllimite_saque tbtaa_limite_saque.vllimite_saque%TYPE,
                pacote_tarifa BOOLEAN,
                vldevolver NUMBER(32,8),
                insituacprvd tbprevidencia_conta.insituac%TYPE,
                idportab NUMBER,
                insitapi NUMBER,
                vlpreapr NUMBER(32,8)
        );
  TYPE typ_tab_valores_conta IS TABLE OF typ_rec_valores_conta
    INDEX BY PLS_INTEGER;

  -- temptable para armazenar dados do cartao magnetico, antiga tt-cartoes-magneticos
  TYPE typ_rec_cartoes_magneticos
       IS RECORD (nmtitcrd crapcrm.nmtitcrd%TYPE,
                  nrcartao VARCHAR2(100),
                  dssitcar VARCHAR2(100),
                  tpusucar crapcrm.tpusucar%TYPE);
  TYPE typ_tab_cartoes_magneticos IS TABLE OF typ_rec_cartoes_magneticos
    INDEX BY PLS_INTEGER;

  -- Temptable para armazenar dados dos convenios autotizados para debito, antiga b1wgen0026.p\tt-conven
  TYPE typ_rec_conven
       IS RECORD (cdcooper crapcop.cdcooper%TYPE,
                  nrdconta crapass.nrdconta%TYPE,
                  cdhistor craphis.cdhistor%TYPE,
                  dsexthst craphis.dsexthst%TYPE,
                  dtiniatr DATE,
                  dtultdeb DATE,
                  cdrefere NUMBER);
  TYPE typ_tab_conven IS TABLE OF typ_rec_conven
    INDEX BY PLS_INTEGER;

  -- Temptable para armazenar dados dos cartõesdo cooperado, antiga b1wgen0028.p\tt-cartoes
  TYPE typ_rec_cartoes
       IS RECORD(nrdconta crapass.nrdconta%TYPE,
                 nmtitcrd crawcrd.nmtitcrd%TYPE,
                 nmresadm crapadc.nmresadm%TYPE,
                 nrcrcard VARCHAR2(100),
                 dscrcard VARCHAR2(100),
                 dssitcrd VARCHAR2(100),
                 insitcrd crawcrd.insitcrd%TYPE,
                 nrctrcrd crawcrd.nrctrcrd%TYPE,
                 cdadmcrd crawcrd.cdadmcrd%TYPE,
                 flgcchip crapadc.flgcchip%TYPE);

  TYPE typ_tab_cartoes IS TABLE OF typ_rec_cartoes
    INDEX BY PLS_INTEGER;

  -- Temptable para armazenar ocorrencias do cooperado, antiga b1wgen0027.p\tt-ocorren
  TYPE typ_rec_ocorren
       IS RECORD(qtctrord INTEGER,
                 qtdevolu INTEGER,
                 dtcnsspc crapass.dtcnsspc%TYPE,
                 dtdsdsps crapass.dtdsdspc%TYPE,
                 qtddsdev crapsld.qtddsdev%TYPE,
                 dtdsdclq crapsld.dtdsdclq%TYPE,
                 qtddtdev crapsld.qtddtdev%TYPE,
                 flginadi INTEGER,
                 flglbace INTEGER,
                 flgeprat INTEGER,
                 indrisco crapnrc.indrisco%TYPE,
                 nivrisco VARCHAR2(100),
                 flgpreju INTEGER,
                 flgjucta INTEGER,
                 flgocorr INTEGER,
                 dtdrisco DATE,
                 qtdiaris INTEGER,
                 inrisctl crapass.inrisctl%TYPE,
                 dtrisctl crapass.dtrisctl%TYPE,
                 dsdrisgp VARCHAR2(200),
                 innivris crapris.innivris%TYPE);
  TYPE typ_tab_ocorren IS TABLE OF typ_rec_ocorren
    INDEX BY PLS_INTEGER;

  -- Temptable para armazenar Observacoes gerais sobre o associado
  -- antiga b1wgen0085.p\tt-crapobs
  TYPE typ_rec_crapobs
       IS RECORD (nrdconta crapobs.nrdconta%TYPE,
                  dtmvtolt crapobs.dtmvtolt%TYPE,
                  nrseqdig crapobs.nrseqdig%TYPE,
                  cdoperad crapobs.cdoperad%TYPE,
                  hrtransa crapobs.hrtransa%TYPE,
                  flgprior crapobs.flgprior%TYPE,
                  dsobserv crapobs.dsobserv%TYPE,
                  dslogobs crapobs.dslogobs%TYPE,
                  cdcooper crapobs.cdcooper%TYPE,
                  recidobs crapobs.progress_recid%TYPE,
                  nmoperad crapope.nmoperad%TYPE,
                  hrtransc VARCHAR2(10));
  TYPE typ_tab_crapobs IS TABLE OF typ_rec_crapobs
    INDEX BY PLS_INTEGER;

  -- Temptable para armazenar informacoes gerais  do associado
  -- antiga b1wgen0085.p\tt-infoass
  TYPE typ_rec_infoass
       IS RECORD (cdcooper crapass.cdcooper%TYPE,
                  nrdconta crapass.nrdconta%TYPE,
                  nmprimtl crapass.nmprimtl%TYPE);
  TYPE typ_tab_infoass IS TABLE OF typ_rec_infoass
    INDEX BY PLS_INTEGER;

  -- Temptable para armazenar complementos do cabecalho atenda
  -- antiga b1wgen0085.p\tt-comp_cabec
  TYPE typ_rec_comp_cabec
       IS RECORD (qtdevolu INTEGER,
                  qtddsdev INTEGER,
                  qtddtdev INTEGER,
                  dtsisfin DATE,
                  ftsalari VARCHAR2(100),
                  vlprepla NUMBER,
                  qttalret INTEGER,
                  flgdigit VARCHAR2(1));
  TYPE typ_tab_comp_cabec IS TABLE OF typ_rec_comp_cabec
    INDEX BY PLS_INTEGER;


  -- Temptable para armazenar mensagens de alerta conf. a conta
  -- antiga b1wgen0052.p\tt-alertas
  TYPE typ_rec_alertas
       IS RECORD (cdalerta INTEGER,
                  dsalerta VARCHAR2(200),
                  qtdpausa INTEGER,
                  tpalerta VARCHAR2(1) DEFAULT 'I');
  TYPE typ_tab_alertas IS TABLE OF typ_rec_alertas
    INDEX BY VARCHAR2(200);

  --> TempTable para retornar as mensagens para tela atenda (antiga b1wgen0031tt.i/tt-mensagens-atenda)
  TYPE typ_rec_mensagens_atenda
    IS RECORD(nrsequen INTEGER,
              dsmensag VARCHAR2(4000));
  TYPE typ_tab_mensagens_atenda IS TABLE OF typ_rec_mensagens_atenda
    INDEX BY PLS_INTEGER;

  --> Temptable para armazenar dados do cabecalho para tela atenda (antita b1wgen0001tt.i/tt-cabec)
  TYPE typ_rec_cabec
    IS RECORD (nrmatric  crapass.nrmatric%TYPE,
               cdagenci  crapass.cdagenci%TYPE,
               dtadmiss  crapass.dtadmiss%TYPE,
               nrdctitg  crapass.nrdctitg%TYPE,
               nrctainv  crapass.nrctainv%TYPE,
               dtadmemp  crapass.dtadmemp%TYPE,
               nmprimtl  crapass.nmprimtl%TYPE,
               nmsegntl  crapttl.nmextttl%TYPE,
               dtaltera  crapalt.dtaltera%TYPE,
               dsnatopc  VARCHAR2(30),
               nrramfon  VARCHAR2(100),
               dtdemiss  crapass.dtdemiss%TYPE,
               dsnatura  crapttl.dsnatura%TYPE,
               nrcpfcgc  VARCHAR2(30),
               cdsecext  crapass.cdsecext%TYPE,
               indnivel  crapass.indnivel%TYPE,
               dstipcta  VARCHAR2(100),
               dssitdct  VARCHAR2(100),
               cdempres  crapttl.cdempres%TYPE,
               cdturnos  crapttl.cdturnos%TYPE,
               cdtipsfx  crapass.cdtipsfx%TYPE,
               nrdconta  crapass.nrdconta%TYPE,
               vllimcre  crapass.vllimcre%TYPE,
               inpessoa  crapass.inpessoa%TYPE,
               dssititg  VARCHAR2(100),
               qttitula  integer,
               cdclcnae  crapass.cdclcnae%TYPE,
               cdsitdct  crapass.cdsitdct%TYPE,
               nmsocial  crapttl.nmsocial%TYPE,
               cdscobeh  VARCHAR2(100),
               reciproc  INTEGER,
               nrdgrupo  tbevento_grupos.nmdgrupo%TYPE);
  TYPE typ_tab_cabec IS TABLE OF typ_rec_cabec
    INDEX BY PLS_INTEGER;

  TYPE typ_reg_cadrest IS
        RECORD(nrdconta crapass.nrdconta%TYPE
              ,nrcpfcgc crapass.nrcpfcgc%TYPE
              ,nmextttl crapass.nmprimtl%TYPE
              ,idseqttl crapttl.idseqttl%TYPE);

  TYPE typ_tab_cadrest IS TABLE OF typ_reg_cadrest
    INDEX BY PLS_INTEGER;

  -->  Procedure verficar vigencia do procurador
  PROCEDURE pc_verif_vig_procurador ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                    ,pr_dtmvtolt IN DATE                   --> Data do movimento
                                    ,pr_dsvigpro OUT VARCHAR2);            --> retorna critica da vigencia
  
  /******************************************************************************/
  /**   Function para verificar se as letras de seguranca estao cadastradas   **/
  /******************************************************************************/
  FUNCTION fn_verif_letras_seguranca( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                     ) RETURN INTEGER;

  /*****************************************************************************/
  /** Procedure para validar se o percentual de todos os socios atingiu 100%  **/
  /*****************************************************************************/
  PROCEDURE pc_valida_socios(  pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                              ,pr_nmdatela  IN craptel.nmdatela%TYPE  --> Nome da tela
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE  --> Numero da conta
                              ,pr_dscritic OUT VARCHAR2);             --> retorna critica da vigencia


  /******************************************************************************/
  /**   Function para obter situacao da senha                                  **/
  /******************************************************************************/
  FUNCTION fn_situacao_senha ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                              ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                              ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                              ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                              ,pr_idorigem IN INTEGER                --> Identificado de oriem
                              ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                              ,pr_tpdsenha IN crapsnh.tpdsenha%TYPE  --> tipo de senha(1-Internet 2-URA)
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                              ) RETURN VARCHAR2; --> returnar descricao da situacao(dssitura)


  /******************************************************************************/
  /**        Funcao para verificar qual a administradora do cartao (WEB)       **/
  /******************************************************************************/
  PROCEDURE pc_verifica_adm_web(pr_cdadmcrd IN INTEGER --> Codigo da administradora
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);

  /******************************************************************************/
  /**            Procedure para listar cartoes do cooperado                    **/
  /******************************************************************************/
  PROCEDURE pc_lista_cartoes(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                            ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                            ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                            ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                            ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                            ,pr_idorigem IN INTEGER                --> Identificado de oriem
                            ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                            ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                            ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da cooperativa
                            ,pr_flgzerar IN VARCHAR2 DEFAULT 'S'  --> Flag para Zerar limite
                            ,pr_flgprcrd IN crawcrd.flgprcrd%TYPE DEFAULT 0 --> Considerar apenas titular (0-Nao,1-Sim)
                            ------ OUT ------
                            ,pr_flgativo     OUT INTEGER           --> Retorna situação 1-ativo 2-inativo
                            ,pr_nrctrhcj     OUT NUMBER            --> Retorna numero do contrato
                            ,pr_flgliber     OUT INTEGER           --> Retorna se esta liberado 1-sim 2-nao
                            ,pr_vltotccr     OUT NUMBER            --> retorna total de limite do cartao
                            ,pr_tab_cartoes  OUT typ_tab_cartoes   --> retorna temptable com os dados dos convenios
                            ,pr_des_reto     OUT VARCHAR2                    --> OK ou NOK
                            ,pr_tab_erro     OUT gene0001.typ_tab_erro);

  /******************************************************************************/
  /**            Procedure para listar ocorrencias do cooperado                **/
  /******************************************************************************/
  PROCEDURE pc_lista_ocorren(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                            ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                            ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                            ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                            ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                            ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE --> Data da cooperativa
                            ,pr_idorigem IN INTEGER                --> Identificado de oriem
                            ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                            ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                            ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                            ------ OUT ------
                            ,pr_tab_ocorren  OUT typ_tab_ocorren   --> retorna temptable com os dados dos convenios
                            ,pr_des_reto     OUT VARCHAR2          --> OK ou NOK
                            ,pr_tab_erro     OUT gene0001.typ_tab_erro);

   /******************************************************************************/
  /**    Procedure para listar ocorrencias do cooperado - Chamada PROGRESS     **/
  /******************************************************************************/
  PROCEDURE pc_lista_ocorren_prog( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                  ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                  ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                  ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                  ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                                  ------ OUT ------
                                  ,pr_xml_ocorren  OUT CLOB              --> retorna xml com os dados dos convenios
                                  ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                                  ,pr_cdcritic     OUT INTEGER) ;       --> Codigo da critica

  /******************************************************************************/
  /**             Funcao para obter saldo da conta investimento                **/
  /******************************************************************************/
  FUNCTION fn_saldo_invetimento( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da cooperativa

                                )RETURN NUMBER;   --> Retorna saldo de investimento

  /******************************************************************************/
  /**             Funcao para obter valor do limite de credito                 **/
  /******************************************************************************/
  FUNCTION fn_valor_limite_credito(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                  ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                  ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                  ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                  ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da cooperativa
                                  ,pr_des_reto OUT VARCHAR2             --> OK ou NOK
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro
                                  )RETURN NUMBER; --> Retorna saldo de investimento

  /******************************************************************************/
  /**        Funcao para validar retrição de acesso do operador                **/
  /******************************************************************************/
  FUNCTION fn_valida_restricao_ope( pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                   ,pr_nrdctitg IN crapass.nrdctitg%TYPE  --> Numero da conta
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                  )RETURN VARCHAR2;                       --> Retorna critica

  --> Buscar codigo da empresa da pessoa fisica ou juridica
  PROCEDURE pc_busca_cdempres_ass (pr_cdcooper IN crapcop.cdcooper%type,
                                   pr_inpessoa IN crapass.inpessoa%type,
                                   pr_nrdconta IN crapass.nrdconta%type,
                                   pr_cdempres IN OUT crapttl.cdempres%type,
                                   pr_cdturnos IN OUT crapttl.cdturnos%type,
                                   pr_dsnatura IN OUT crapttl.dsnatura%TYPE);


  /******************************************************************************/
  /**             Efetua a busca dos dados do associado                        **/
  /******************************************************************************/
  PROCEDURE pc_busca_dados_associado ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                      ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                      ,pr_nrseqdig IN INTEGER                --> sequencial do titular
                                      ,pr_cddopcao IN VARCHAR2               --> opcao de busca
                                      ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data da cooperativa
                                      ---------- OUT --------
                                      ,pr_tab_infoass OUT typ_tab_infoass    --> Temptable com dados associados
                                      ,pr_tab_crapobs OUT typ_tab_crapobs    --> observacoes dos associados
                                      ,pr_des_reto    OUT VARCHAR2           --> OK ou NOK
                                      ,pr_tab_erro    OUT gene0001.typ_tab_erro);


  /******************************************************************************/
  /**           Procedure para carregar dos dados para a tela ATENDA           **/
  /******************************************************************************/
  PROCEDURE pc_carrega_dados_atenda( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                    ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                    ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Proxima data do movimento
                                    ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE  --> Data anterior do movimento
                                    ,pr_dtiniper IN DATE                   --> Data inicial do periodo
                                    ,pr_dtfimper IN DATE                   --> data final do periodo
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                    ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                    ,pr_nrdctitg IN crapass.nrdctitg%TYPE  --> Numero da conta itg
                                    ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo
                                    ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao

                                    ---------- OUT --------
                                    ,pr_flconven          OUT INTEGER                --> Retorna se aceita convenio
                                    ,pr_tab_cabec         OUT typ_tab_cabec          --> Retorna dados do cabecalho da tela ATENDA
                                    ,pr_tab_comp_cabec    OUT typ_tab_comp_cabec     --> observacoes dos associados
                                    ,pr_tab_valores_conta OUT typ_tab_valores_conta  --> Retorna os valores para a tela ATENDA
                                    ,pr_tab_crapobs       OUT typ_tab_crapobs        --> Observacoes dos associados
                                    ,pr_tab_mensagens_atenda  OUT typ_tab_mensagens_atenda   --> Retorna as mensagens para tela atenda
                                    ,pr_dscritic          OUT VARCHAR2               --> Retornar critica que nao aborta processamento
                                    ,pr_des_reto          OUT VARCHAR2               --> OK ou NOK
                                    ,pr_tab_erro          OUT gene0001.typ_tab_erro);

  PROCEDURE pc_carrega_dados_atenda_web ( pr_nrdconta  IN crapass.nrdconta%TYPE   --> Conta do associado
                                         ,pr_idseqttl  IN crapttl.idseqttl%TYPE   --> Sequencia de titularidade da conta
                                         ,pr_nrdctitg  IN crapass.nrdctitg%TYPE   --> Numero da conta itg
                                         ,pr_dtmvtolt  IN VARCHAR2                --> Data do movimento
                                         ,pr_dtmvtopr  IN VARCHAR2                --> Proxima data do movimento
                                         ,pr_dtmvtoan  IN VARCHAR2                --> Data anterior do movimento
                                         ,pr_dtiniper  IN VARCHAR2                --> Data inicial do periodo
                                         ,pr_dtfimper  VARCHAR2                   --> data final do periodo
                                         ,pr_inproces  IN crapdat.inproces%TYPE   --> Indicador do processo
                                         ,pr_flgerlog  IN VARCHAR2                --> Gerar log S/N
                                         ,pr_xmllog         IN VARCHAR2           --> XML com informações de LOG
                                          -- OUT
                                         ,pr_cdcritic OUT PLS_INTEGER             --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2                --> Descric?o da critica
                                         ,pr_retxml   IN OUT NOCOPY XMLType       --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);              --> Erros do processo

  PROCEDURE pc_alerta_fraude (pr_cdcooper IN NUMBER                   --> Cooperativa
                             ,pr_cdagenci IN NUMBER                   --> PA
                             ,pr_nrdcaixa IN NUMBER                   --> Nr. do caixa
                             ,pr_cdoperad IN VARCHAR2                 --> Cód. operador
                             ,pr_nmdatela IN VARCHAR2                 --> Nome da tela
                             ,pr_dtmvtolt IN DATE                     --> Data de movimento
                             ,pr_idorigem IN NUMBER                   --> ID de origem
                             ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE    --> Nr. do CPF/CNPJ
                             ,pr_nrdconta IN crapass.nrdconta%TYPE    --> Nr. da conta
                             ,pr_idseqttl IN NUMBER                   --> Id de sequencia do titular
                             ,pr_bloqueia IN NUMBER                   --> Flag Bloqueia operação
                             ,pr_cdoperac IN NUMBER                   --> Cód da operação
                             ,pr_dsoperac IN VARCHAR2                 --> Desc. da operação
                             ,pr_cdcritic OUT NUMBER                  --> Cód. da crítica
                             ,pr_dscritic OUT VARCHAR2                --> Desc. da crítica
                             ,pr_des_erro OUT VARCHAR2);              --> Retorno de erro  OK/NOK

  FUNCTION fn_get_existe_risco_cpfcnpj (pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                                       ,pr_nmpessoa OUT VARCHAR2) RETURN BOOLEAN;

  PROCEDURE pc_liberar_cad_restritivo (pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                      ,pr_cdagenci IN NUMBER                --> PA
                                      ,pr_nrdcaixa IN NUMBER                --> Caixa
                                      ,pr_idorigem IN NUMBER                --> Origem
                                      ,pr_dtmvtolt IN DATE                  --> Data de movimento
                                      ,pr_cdoperad IN VARCHAR2              --> Operador
                                      ,pr_cdcoplib IN NUMBER                --> Cooperativa liberação
                                      ,pr_cdagelib IN NUMBER                --> PA liberação
                                      ,pr_cdopelib IN NUMBER                --> Operador liberação
                                      ,pr_nrdconta IN NUMBER                --> Nr. da conta
                                      ,pr_nrcpfcgc IN NUMBER                --> Nr do CPF
                                      ,pr_dsjuslib IN VARCHAR2              --> Descrição da justificativa
                                      ,pr_cdoperac IN NUMBER                --> Cód. operação
                                      ,pr_flgsiste IN NUMBER                --> Gerado pelo sistema
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo
                                      ,pr_cdcritic OUT NUMBER               --> Cód. da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_des_erro OUT VARCHAR2);           --> Retorno de erro OK/NOK

  PROCEDURE pc_envia_email_alerta (pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE --> PA
                                  ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE --> Nr. do caixa
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE --> Cód. operador
                                  ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da tela
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de movimento
                                  ,pr_idorigem IN INTEGER               --> ID de origem
                                  ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE --> Nr. do CPF/CNPJ
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Id de sequencia do titular
                                  ,pr_nmprimtl IN crapttl.nmextttl%TYPE --> Nome do primeiro titular
                                  ,pr_nmpessoa IN crapcrt.nmpessoa%TYPE --> Nome da pessoa
                                  ,pr_cdoperac IN INTEGER               --> Cód. da operação
                                  ,pr_dsoperac IN VARCHAR2              --> Desc. da operação
                                  ,pr_cdcritic OUT INTEGER              --> Cód. da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Desc. da crítica
                                  ,pr_des_erro OUT VARCHAR2);           --> Retorno de erro OK/NOK


  -- Geracao de log para operacoes que podem utilizar o cartao
  PROCEDURE pc_gera_log_ope_cartao(pr_cdcooper    tbcrd_log_operacao.cdcooper%TYPE, -- Codigo da cooperativa
                                   pr_nrdconta    tbcrd_log_operacao.nrdconta%TYPE, -- Numero da conta
                                   pr_indoperacao tbcrd_log_operacao.indoperacao%TYPE,  -- Operacao realizada no log (1-Saque/2-Doc/3-Ted/4-Transferencia/5-Talao de cheque)
                                   pr_cdorigem    tbcrd_log_operacao.cdorigem%TYPE, -- Origem do lancamento (1-Ayllos/2-Caixa/3-Internet/4-Cash/5-Ayllos WEB/6-URA/7-Batch/8-Mensageria)
                                   pr_indtipo_cartao tbcrd_log_operacao.tpcartao%TYPE,  -- Tipo de cartao utilizado. (0-Sem cartao/1-Magnetico/2-Cartao Cecred)
                                   pr_nrdocmto    tbcrd_log_operacao.nrdocmto%TYPE, -- Numero do documento utilizado no lancamento
                                   pr_cdhistor    tbcrd_log_operacao.cdhistor%TYPE, -- Codigo do historico utilizado no lancamento
                                   pr_nrcartao    VARCHAR2, -- Numero do cartao utilizado. Zeros quando nao existe cartao
                                   pr_vllanmto    tbcrd_log_operacao.vloperacao%TYPE, -- Valor do lancamento
                                   pr_cdoperad    tbcrd_log_operacao.cdoperad%TYPE, -- Codigo do operador
                                   pr_cdbccrcb    tbcrd_log_operacao.cdbanco_receb%TYPE, -- Codigo do banco de destino para os casos de TED e DOC
                                   pr_cdfinrcb    tbcrd_log_operacao.cdfinalid_operacao%TYPE, -- Codigo da finalidade para operacoes de TED e DOC
                                   pr_cdpatrab    crapope.cdpactra%TYPE, -- Codigo do PA de trabalho do operador
                                   pr_nrseqems    crapfdc.nrseqems%TYPE, -- Numero da sequencia da emissao do cheque
                                   pr_nmreceptor  crapass.nmprimtl%TYPE, -- Nome do terceiro que recebeu o o talonario do cheque
                                   pr_nrcpf_receptor crapass.nrcpfcgc%TYPE, -- Numero do CPF do terceiro que recebeu o o talonario do cheque
                                   pr_dscritic OUT varchar2); -- Descricao do erro quando houver

  -->   Busca quantidades de talões entregues por requisição e por cartão
  PROCEDURE pc_busca_qtd_entrega_talao
                        ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                         ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                         ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de movimento
                         ---------- OUT --------
                         ,pr_qtentreq OUT INTEGER               --> Quantidade de entragas de talao por requisição
                         ,pr_qtentcar OUT INTEGER               --> Quantidade de entragas de talao por cartão
                         ,pr_cdcritic OUT INTEGER
                         ,pr_dscritic OUT VARCHAR2);

  -- Busca o tipo de cartao nas operacoes de TED, DOC e transferencia
  PROCEDURE pc_busca_tipo_cartao_mvt(pr_cdcooper  IN tbcrd_log_operacao.cdcooper%TYPE, -- Codigo da cooperativa
                                     pr_nrdconta  IN tbcrd_log_operacao.nrdconta%TYPE, -- Numero da conta
                                     pr_nrdocmto  IN tbcrd_log_operacao.nrdocmto%TYPE, -- Numero do documento utilizado no lancamento
                                     pr_cdhistor  IN tbcrd_log_operacao.cdhistor%TYPE, -- Codigo do historico utilizado no lancamento
                                     pr_dtmvtolt  IN tbcrd_log_operacao.dtmvtolt%TYPE, -- Data do movimento
                                     pr_tpcartao OUT tbcrd_log_operacao.tpcartao%TYPE, -- Tipo de cartao
                                     pr_dscritic OUT varchar2); -- Descricao do erro quando houver

  -- Inserir registro de CNAE bloqueado
  PROCEDURE pc_inserir_cnae_bloqueado(pr_cdcnae     IN tbcc_cnae_bloqueado.cdcnae%TYPE         --> Codigo do CNAE
                                     ,pr_dsmotivo   IN tbcc_cnae_bloqueado.dsmotivo%TYPE       --> Motivo da inclusao
                                     ,pr_dtarquivo  IN tbcc_cnae_bloqueado.dtarquivo%TYPE      --> Data do arquivo
                                     ,pr_tpbloqueio IN tbcc_cnae_bloqueado.tpbloqueio%TYPE     --> Tipo de bloqueio do CNAE (0-Restrito, 1-Proibido)
                                     ,pr_tpinclusao IN tbcc_cnae_bloqueado.tpinclusao%TYPE     --> Tipo de inclusão (0-Manual, 1-Arquivo)
                                     ,pr_dtmvtolt   IN tbcc_cnae_bloqueado.dtmvtolt%TYPE       --> Data atual
                                     ,pr_dslicenca  IN tbcc_cnae_bloqueado.dslicenca%TYPE      --> licencas necessarias
                                     ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                  --> Codigo de critica
                                     ,pr_dscritic   OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_excluir_cnae_bloqueado(pr_cdcnae     IN tbcc_cnae_bloqueado.cdcnae%TYPE         --> Codigo do CNAE
                                     ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                  --> Codigo de critica
                                     ,pr_dscritic   OUT crapcri.dscritic%TYPE);                --> Descricao da critica

  PROCEDURE pc_buscar_cnae_bloqueado(pr_cdcnae   IN tbgen_cnae.cdcnae%TYPE --> Codigo do CNAE
                                    ,pr_dscnae   IN tbgen_cnae.dscnae%TYPE --> Descricao do CNAE
                                    ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                                    ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_cria_cnae_proibido_web(pr_cdcnae     IN  tbcc_cnae_bloqueado.cdcnae%TYPE
                                     ,pr_dsmotivo   IN  tbcc_cnae_bloqueado.dsmotivo%TYPE
                                     ,pr_tpbloqueio IN  tbcc_cnae_bloqueado.tpbloqueio%TYPE
                                     ,pr_tpinclusao IN  tbcc_cnae_bloqueado.tpinclusao%TYPE
                                     ,pr_dtarquivo  IN  VARCHAR2
                                     ,pr_dtmvtolt   IN  VARCHAR2
                                     ,pr_dslicenca  IN  VARCHAR2
                                     ,pr_xmllog     IN  VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml     IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                     ,pr_des_erro   OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_exclui_cnae_proibido_web(pr_cdcnae     IN  tbcc_cnae_bloqueado.cdcnae%TYPE
                                       ,pr_xmllog     IN  VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml     IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_importa_arq_cnae(pr_cdcooper  IN crapcop.cdcooper%TYPE
                               ,pr_dsarquiv  IN VARCHAR2
                               ,pr_dsdireto  IN VARCHAR2
                               ,pr_flglimpa  IN INTEGER
                               ,pr_dscritic  OUT VARCHAR2
                               ,pr_retxml    OUT CLOB);

  PROCEDURE pc_importa_arq_cnae_web(pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                   ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo
                                   ,pr_flglimpa   IN INTEGER             --> 1 - Limpa tabela ou 2 - só atualiza as informaçoes
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);

  PROCEDURE pc_exporta_arq_cnae(pr_cdcooper  IN crapcop.cdcooper%TYPE
                               ,pr_dsarquiv  OUT VARCHAR2
                               ,pr_cdcritic  IN INTEGER
                               ,pr_dscritic  OUT VARCHAR2);

  PROCEDURE pc_exporta_arq_cnae_web(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                   ,pr_xmllog     IN  VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml     IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro   OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_verifica_cnae_blq(pr_cdcnae   IN tbcc_cnae_bloqueado.cdcnae%TYPE
                                ,pr_nrcpfcgc IN tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE --> Codigo do CNPJ
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_valida_cnae_restrito(pr_cdcnae       IN  tbcc_cnae_bloqueado.cdcnae%TYPE --> Cod CNAE
                                   ,pr_flgrestrito  OUT INTEGER); --> 0 - OK, 1 = Restrito

  PROCEDURE pc_inserir_cnpj_bloqueado(pr_inpessoa   IN tbcc_cnpjcpf_bloqueado.inpessoa%TYPE    --> PF/PJ
                                     ,pr_nrcpfcgc   IN tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE    --> Codigo do CNAE
                                     ,pr_dsnome     IN tbcc_cnpjcpf_bloqueado.dsnome%TYPE      --> Nome
                                     ,pr_dsmotivo   IN tbcc_cnpjcpf_bloqueado.dsmotivo%TYPE    --> Motivo da inclusao
                                     ,pr_dtarquivo  IN tbcc_cnpjcpf_bloqueado.dtarquivo%TYPE   --> Data do arquivo
                                     ,pr_tpinclusao IN tbcc_cnpjcpf_bloqueado.tpinclusao%TYPE  --> Tipo de inclusão (0-Manual, 1-Arquivo)
                                     ,pr_dtmvtolt   IN tbcc_cnpjcpf_bloqueado.dtmvtolt%TYPE    --> Data atual
                                     ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                  --> Codigo de critica
                                     ,pr_dscritic   OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_excluir_cnpj_bloqueado(pr_nrcpfcgc   IN tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE    --> Codigo do CNPJ
                                     ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                  --> Codigo de critica
                                     ,pr_dscritic   OUT crapcri.dscritic%TYPE);                --> Descricao da critica

  PROCEDURE pc_buscar_cnpj_bloqueado(pr_inpessoa IN tbcc_cnpjcpf_bloqueado.inpessoa%TYPE --> 1 PF/ 2 PJ
                                    ,pr_nrcpfcgc IN tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE --> Codigo do CNPJ
                                    ,pr_dsnome   IN tbcc_cnpjcpf_bloqueado.dsnome%TYPE --> Nome do CNPJ
                                    ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                                    ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_cria_cnpj_proibido_web(pr_inpessoa   IN tbcc_cnpjcpf_bloqueado.inpessoa%TYPE
                                     ,pr_nrcpfcgc   IN  tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE
                                     ,pr_dsnome     IN  tbcc_cnpjcpf_bloqueado.dsnome%TYPE
                                     ,pr_dsmotivo   IN  tbcc_cnpjcpf_bloqueado.dsmotivo%TYPE
                                     ,pr_tpinclusao IN  tbcc_cnpjcpf_bloqueado.tpinclusao%TYPE
                                     ,pr_dtarquivo  IN  VARCHAR2
                                     ,pr_dtmvtolt   IN  VARCHAR2
                                     ,pr_xmllog     IN  VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml     IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                     ,pr_des_erro   OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_exclui_cnpj_proibido_web(pr_nrcpfcgc   IN  tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE --> CNPJ ou CPF
                                       ,pr_xmllog     IN  VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml     IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_importa_arq_cnpj(pr_cdcooper  IN crapcop.cdcooper%TYPE
                               ,pr_dsarquiv  IN VARCHAR2
                               ,pr_dsdireto  IN VARCHAR2
                               ,pr_flglimpa  IN INTEGER
                               ,pr_dscritic  OUT VARCHAR2
                               ,pr_retxml    OUT CLOB);

  PROCEDURE pc_importa_arq_cnpj_web(pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                   ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo
                                   ,pr_flglimpa   IN INTEGER             --> Limpar base de dados
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo

  PROCEDURE pc_exporta_arq_cnpj(pr_cdcooper  IN crapcop.cdcooper%TYPE
                               ,pr_dsarquiv  OUT VARCHAR2
                               ,pr_cdcritic  IN INTEGER
                               ,pr_dscritic  OUT VARCHAR2);

  PROCEDURE pc_exporta_arq_cnpj_web(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                   ,pr_xmllog     IN  VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml     IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro   OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_verifica_cnpj_blq(pr_inpessoa IN crapass.inpessoa%TYPE  --> Pessoa Fisica/ Pessoa Juridica
                                ,pr_nrcpfcgc IN tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE --> Codigo do CNPJ
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_atualiz_data_manut_fone(pr_cdcooper IN crapttl.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da Conta
                                      ,pr_cdcritic OUT INTEGER
                                      ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_verifica_atualiz_fone(pr_cdcooper IN crapttl.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da Conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencia do Titular
                                    ,pr_cdcritic OUT INTEGER
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_atualiza OUT VARCHAR2              --> OK ou NOK
                                    ,pr_dsnrfone OUT VARCHAR2              --> Nr Telefone Atual
                                    ,pr_qtmeatel OUT INTEGER               --> Qtde Meses Atualizacao Telefone
                                    );

  PROCEDURE pc_ib_verif_atualiz_fone(pr_cdcooper IN crapttl.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da Conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencia do Titular
                                    ,pr_inpessoa IN crapttl.inpessoa%TYPE  --> Indicador PF/PJ
                                    ,pr_cdcritic OUT INTEGER
                                    ,pr_dscritic OUT VARCHAR2
                                    );

  PROCEDURE pc_pode_impr_dec_pj_coop(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                    ,pr_nrdconta IN crapcop.nrdconta%TYPE --> Numero da Conta
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informac?es de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2); --> Erros do processo
  PROCEDURE pc_impr_dec_pj_coop_xml(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                   ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da conta
                                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE --> Numero do CPF
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);
  PROCEDURE pc_buscar_tbcota_devol (pr_cdcooper         IN  tbcotas_devolucao.cdcooper%TYPE --> Codigo da Cooperativa
                                   ,pr_nrdconta         IN  tbcotas_devolucao.nrdconta%TYPE --> Numero da conta
                                   ,pr_tpdevolucao      IN  tbcotas_devolucao.tpdevolucao%TYPE --> Indicador de forma de devolucao (1-Total / 2-Parcelado / 3-Sobras Cotas Demitido / 4-Sobras Deposito Demitido)
                                   ,pr_vlcapital        OUT tbcotas_devolucao.vlcapital%TYPE --> Valor Cotas ou Deposito
                                   ,pr_dtinicio_credito OUT tbcotas_devolucao.dtinicio_credito%TYPE --> Valor Cotas ou Deposito
                                   ,pr_vlpago           OUT tbcotas_devolucao.vlpago%TYPE --> Valor Cotas ou Deposito
                                   ,pr_cdcritic         OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                   ,pr_dscritic         OUT VARCHAR2); --> Descricao da critica

  PROCEDURE pc_atualizar_tbcota_devol(pr_cdcooper       IN  tbcotas_devolucao.cdcooper%TYPE --> Codigo da Cooperativa
                                     ,pr_nrdconta       IN  tbcotas_devolucao.nrdconta%TYPE --> Numero da conta
                                     ,pr_tpdevolucao    IN  tbcotas_devolucao.tpdevolucao%TYPE --> Indicador de forma de devolucao (1-Total / 2-Parcelado / 3-Sobras Cotas Demitido / 4-Sobras Deposito Demitido)
                                     ,pr_vlpago         IN tbcotas_devolucao.vlpago%TYPE --> Valor Cotas ou Deposito
                                     ,pr_cdcritic       OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                     ,pr_dscritic       OUT VARCHAR2); --> Descricao da critica

  /* Rotina para buscar valores para devolver  */
  PROCEDURE pc_buscar_tbcota_devol_web(pr_nrdconta   IN  tbcotas_devolucao.nrdconta%TYPE --> Numero da conta
                                      ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                      ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2);        --> Erros do processo
  PROCEDURE pc_retorna_cartao_valido(pr_nrdconta IN crapcrm.nrdconta%TYPE  --> Código da opção
                                    ,pr_idtipcar IN INTEGER                --> Indica qual o cartao
                                    ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Indica o tipo de pessoa
                                                                             -- 1 = PF
                                                                             -- 2 = PJ
                                                                             -- 4 = PF, retornar somente os cartões do titular da conta
                                    ,pr_xmllog   IN VARCHAR2                --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);             --> Descricao do Erro

PROCEDURE pc_obtem_cabecalho_atenda( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                      ,pr_nrdctitg IN crapass.nrdctitg%TYPE  --> Numero da conta itg
                                      ,pr_dtinicio IN DATE                   --> Data de incio
                                      ,pr_dtdfinal IN DATE                   --> data final
                                      ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                      ---------- OUT --------
                                      ,pr_tab_cabec OUT typ_tab_cabec                 --> Retorna dados do cabecalho da tela ATENDA
                                      ,pr_des_reto       OUT VARCHAR2                 --> OK ou NOK
                                      ,pr_tab_erro       OUT gene0001.typ_tab_erro);

PROCEDURE pc_busca_credito_config_categ(pr_cdcooper    IN TBCRD_CONFIG_CATEGORIA.CDCOOPER%TYPE
                                         ,pr_cdadmcrd    IN TBCRD_CONFIG_CATEGORIA.CDADMCRD%TYPE
                                         ,pr_tplimcrd    IN tbcrd_config_categoria.tplimcrd%TYPE DEFAULT 0
                                         ,pr_vllimite_minimo  OUT TBCRD_CONFIG_CATEGORIA.VLLIMITE_MINIMO%TYPE
                                         ,pr_vllimite_maximo  OUT TBCRD_CONFIG_CATEGORIA.VLLIMITE_MAXIMO%TYPE
                                         ,pr_diasdebito       OUT TBCRD_CONFIG_CATEGORIA.DSDIAS_DEBITO%TYPE
                                         ,pr_possui_registro  OUT NUMBER);

  PROCEDURE pc_obter_cartao_URA(pr_cdcooper IN crapcrm.cdcooper%TYPE  --> Código da cooperativa
                               ,pr_nrdconta IN crapcrm.nrdconta%TYPE  --> Código da opção
                               ,pr_nrcartao IN VARCHAR2 --crapcrm.nrcartao%TYPE  --> Número do cartão
                               ,pr_cdagenci OUT crapass.cdagenci%TYPE --> Agencia cooperado
                               ,pr_dtnascto OUT crapass.dtnasctl%TYPE --> Data nascimento cooperado
                               ,pr_idtipcar OUT NUMBER               --> Indica qual o cartao
                               ,pr_inpessoa OUT crapass.inpessoa%TYPE --> Indica o tipo de pessoa
                               ,pr_idsenlet OUT NUMBER -- Indica se existe senha de letras 1 = SIM 0 = NAO
                               ,pr_tpusucar OUT NUMBER  --> Usuário do cartão (Conta de pessoa física devolve o número do titular, conta pessoa jurídica devolve sempre "1" e cartão de operador devolve sempre "9")
                               ,pr_nrcpfcgc OUT crapass.nrcpfcgc%TYPE -->  Em caso de pessoa física é o CPF do titular que está utilizando o cartão, em caso se pessoa jurídica é o CNPJ
                               ,pr_nometitu OUT crapcrm.nmtitcrd%TYPE -->  Nome impresso no cartão
                               ,pr_dtexpira OUT crapcrm.dtvalcar%TYPE --> Data expiração cartão
                               ,pr_dtcancel OUT crapcrm.dtcancel%TYPE
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                               ,pr_dscritic OUT VARCHAR2);


  PROCEDURE pc_bloquear_cartao_magnetico( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                         ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                         ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                         ,pr_nmdatela IN VARCHAR2  --> Nome da tela
                                         ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                         ,pr_dtmvtolt IN DATE                   --> Data do movimento
                                         ,pr_nrcartao IN VARCHAR2               --crapcrm.nrcartao%TYPE  --> Numero do cartão
                                         ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao

                                        ------ OUT ------
                                         ,pr_cdcritic  OUT PLS_INTEGER
                                         ,pr_dscritic  OUT VARCHAR2
                                         ,pr_des_reto  OUT VARCHAR2 );

  -- Procedure para gravar data e hora no campo, visto que pelo progress estava gravando apenas a data.
  PROCEDURE pc_salva_dtassele(pr_cdcooper IN crapcrd.cdcooper%TYPE
                             ,pr_nrdconta IN crapcrd.nrdconta%TYPE
                             ,pr_nrcrcard IN VARCHAR2
                             ,pr_dscritic OUT VARCHAR2);


  PROCEDURE pc_retorna_dados_entrg_crt_web(pr_cdcooper IN crapcrm.cdcooper%TYPE  --> Código da cooperativa
                                           ,pr_nrdconta IN crapcrm.nrdconta%TYPE  --> Código CONTA
                                           ,pr_nrctrcrd IN VARCHAR2 --crapcrm.nrcartao%TYPE  --> Número do cartão
                                           ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  FUNCTION fn_dstipcta(pr_inpessoa IN tbcc_tipo_conta.inpessoa%TYPE,  --> Tipo de pessoa
                       pr_cdtipcta IN tbcc_tipo_conta.cdtipo_conta%TYPE)   --> Tipo de conta
                       RETURN VARCHAR2;

  FUNCTION fn_dssitdct(pr_cdsitdct IN crapass.cdsitdct%TYPE)  --> Codigo da situacao da conta
                       RETURN VARCHAR2;
                                           
END CADA0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED."CADA0004" IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0004
  --  Sistema  : Rotinas para detalhes de cadastros
  --  Sigla    : CADA
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Agosto/2015.                   Ultima atualizacao: 11/01/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para buscar detalhes de cadastros
  --
  -- Alteracoes:   10/11/2015 - Incluido verificacao para impressao de termo de
  --                            responsabilidade na procedure pc_obtem_mensagens_alerta.
  --                            (Jean Michel).
  --
  --               01/12/2015 - Ajustes para projeto de assinatura multipla PJ.
  --                            Baseado na condicao da atenda.p em funcao
  --                            fn_situacao_senha. (Jorge/David)
  --
  --               26/01/2016 - #383024 Acrescentado ELSE na verificação da situação do CPF (Carlos)
  --
  --               23/03/2015 - Adicionar novos parametros na chamada da
  --                            EXTR0002.pc_consulta_lancamento - Melhoria 157 (Lucas Ranghetti)
  --
  --               29/04/2016 - Passar como null dtiniper e dtfimper na chamada da procedure
  --                            EXTR0002.pc_consulta_lancamento (Lucas Ranghetti/Fabricio)
  --
  --               03/05/2016 - Alterada busca na tabela crapprm, estava utilizando o acesso
  --                            FINTRFDOCS para TEDS tambem, quando o correto seria FINTRFTEDS
  --                            (Heitor - RKAM)
  --
  --               21/06/2016 - Correcao para o uso correto do indice da CRAPTAB em procedures
  --                            desta package.(Carlos Rafael Tanholi).
  --
  --              29/09/2019 - Inclusao de verificacao de contratos de acordos de
  --                           empréstimos na procedure pc_obtem_mensagens_alerta,
  --                           Prj. 302 (Jean Michel).
  --
  --               14/07/2016 - Correcao na procedure pc_envia_email_alerta sobre o cursor da
  --                            craptab que estava com a logica errada. (Carlos Rafael Tanholi).
  --
  --               14/11/2016 - M172 - Atualização Telefone no Auto Atendimento (Guilherme/SUPERO)
  --
  --               19/06/2017 - Ajuste para inclusao do novo tipo de situacao da conta
  --                            "Desligamento por determinação do BACEN"
  --                            ( Jonata - RKAM P364).
  --
  --               25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
  --                            crapass, crapttl, crapjur
  --                            (Adriano - P339).
  --
  --               14/11/2017 - Ajuste para considerar lancamentos de devolucao de capital (Jonata - RKAM P364).
  --
  --               16/11/2017 - Criado duas novas rotinas (Jonata - RKAM P364).
  --
  --               01/12/2017 - Incluido procedure para buscar informacoes da rotina
  --                            "Valores a devolver" da tela ATENDA  (Jonata - RKAM P364).
  --
  --               03/12/2017 - Alterado cursor para ler da tbcotas e eliminado cursor da craplcm (Jonata - RKAM P364).
  --
  --               12/12/2017 - Alterar para varchar2 o campo nrcartao na procedure
  --                            pc_gera_log_ope_cartao (Lucas Ranghetti #810576)
  --
  --               03/04/2018 - Adicionado NOTI0001.pc_cria_notificacao
  --
  --               23/05/2018 - Mensagem quando ocorre prejuízo em conta corrente e empréstimo
  --                            Diego Simas - AMcom
  --
  --               05/06/2018 - Inclusão do campo vr_insituacprvd no retorno da
  --                            pc_carrega_dados_atenda (Claudio CIS Corporate)
  --
  --               05/12/2018 - SCTASK0038225 (Yuri - Mouts)
  --                            substituição do método XSLProcessor pela chamada da GENE0002
  --
  --               11/01/2019 - Adicionada tratativa para ANOTA para alertar cadastro de cooperado vencido (Luis Fernando - GFT)


---------------------------------------------------------------------------------------------------------------



  /*****************************************************************************/
  /**            Procedure verficar vigencia do procurador                    **/
  /*****************************************************************************/
  PROCEDURE pc_verif_vig_procurador( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                    ,pr_dtmvtolt IN DATE                   --> Data do movimento
                                    ,pr_dsvigpro OUT VARCHAR2) IS          --> retorna critica da vigencia

  /* ..........................................................................
    --
    --  Programa : pc_verif_vig_procurador        Antiga: b1wgen0031.p/verifica-vigencia-procurador
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Agosto/2015.                   Ultima atualizacao: 31/08/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure verficar vigencia do procurador
    --
    --  Alteração : 03/08/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar associado
    CURSOR cr_crapass IS
      SELECT 1
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta
         AND crapass.inpessoa = 1;
    rw_crapass cr_crapass%ROWTYPE;

    -- busacar dados avalista terceito
    CURSOR cr_crapavt (pr_cdcooper crapavt.cdcooper%TYPE,
                       pr_nrdconta crapavt.nrdconta%TYPE,
                       pr_nrctremp crapavt.nrctremp%TYPE) IS
    SELECT dtvalida
      FROM crapavt
     WHERE crapavt.cdcooper = pr_cdcooper
       AND crapavt.tpctrato = 6
       AND crapavt.nrdconta = pr_nrdconta
       AND crapavt.nrctremp = pr_nrctremp;


    vr_nrctremp NUMBER;

  BEGIN
    -- verificar associado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%FOUND THEN
      vr_nrctremp := pr_idseqttl;
    ELSE
      vr_nrctremp := 0;
    END IF;
    CLOSE cr_crapass;

    -- Verificar vigencia do procurador
    FOR rw_crapavt IN cr_crapavt ( pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => vr_nrctremp) LOOP

      IF rw_crapavt.dtvalida <> to_date('12/31/9999','MM/DD/RRRR')   AND
         rw_crapavt.dtvalida <  pr_dtmvtolt THEN
        pr_dsvigpro := 'Representante/Procurador com Procuracao/Ata vencida.';

        IF  pr_nmdatela = 'ATENDA' THEN
          pr_dsvigpro := pr_dsvigpro||' Verifique tela Contas';
        END IF;

        EXIT;
      END IF;

    END LOOP;
  END pc_verif_vig_procurador;

  /*****************************************************************************/
  /** Procedure para validar se o percentual de todos os socios atingiu 100%  **/
  /*****************************************************************************/
  PROCEDURE pc_valida_socios(  pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                              ,pr_nmdatela  IN craptel.nmdatela%TYPE  --> Nome da tela
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE  --> Numero da conta
                              ,pr_dscritic OUT VARCHAR2) IS           --> retorna critica da vigencia

  /* ..........................................................................
    --
    --  Programa : pc_valida_socios        Antiga: b1wgen0031.p/valida_socios
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Outubro/2015.                   Ultima atualizacao: 21/10/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para validar se o percentual de todos os socios atingiu 100%
    --
    --  Alteração : 21/10/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --> Buscar avalistas procurados
    CURSOR cr_crapavt IS
      SELECT SUM(crapavt.persocio) persocio
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.tpctrato = 6 /*procurad*/
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.nrctremp = 0;

    --> Buscar percentual por empresa
    CURSOR cr_crapepa IS
      SELECT SUM(crapepa.persocio) persocio
        FROM crapepa
       WHERE crapepa.cdcooper = pr_cdcooper
         AND crapepa.nrdconta = pr_nrdconta;

    --> Dados pessoa juridica
    CURSOR cr_crapjur IS
      SELECT crapjur.natjurid
        FROM crapjur
       WHERE crapjur.cdcooper = pr_cdcooper
         AND crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;

    --> Cadastro dos tipos de natureza juridica.
    CURSOR cr_gncdntj (pr_cdnatjur gncdntj.cdnatjur%TYPE)IS
      SELECT gncdntj.flgprsoc
        FROM gncdntj
       WHERE gncdntj.cdnatjur = pr_cdnatjur;
    rw_gncdntj cr_gncdntj%ROWTYPE;

    --------------> VARIAVEIS <-----------------
    vr_tot_persocio     NUMBER := 0;
    vr_tot_persocio_epa NUMBER := 0;


  BEGIN
    -- Procuradores da conta
    OPEN cr_crapavt;
      FETCH cr_crapavt INTO vr_tot_persocio;
    CLOSE cr_crapavt;

    -- Empresas quem tem participacao na empresa
    OPEN cr_crapepa;
      FETCH cr_crapepa INTO vr_tot_persocio_epa;
    CLOSE cr_crapepa;

    vr_tot_persocio := nvl(vr_tot_persocio,0) + nvl(vr_tot_persocio_epa,0);

    -- Pessoa juridica
    OPEN cr_crapjur;
    FETCH cr_crapjur INTO rw_crapjur;
    IF cr_crapjur%FOUND THEN
      CLOSE cr_crapjur;

      --> Cadastro dos tipos de natureza juridica.
      OPEN cr_gncdntj(pr_cdnatjur => rw_crapjur.natjurid);
      FETCH cr_gncdntj INTO rw_gncdntj;
      IF cr_gncdntj%FOUND THEN
        CLOSE cr_gncdntj;

        --> se deve contar percentual societario
        IF rw_gncdntj.flgprsoc = 1 /*TRUE*/ THEN
          IF nvl(vr_tot_persocio,0) = 0      THEN
            pr_dscritic := 'GE: % societario nao informado na tela CONTAS. Verificar cadastro.';
          ELSIF nvl(vr_tot_persocio,0) < 100 THEN
            pr_dscritic := 'GE: % societario na tela CONTAS inferior a 100%. Verificar cadastro.';
          END IF;
        END IF;

      ELSE
        CLOSE cr_gncdntj;
      END IF;

    ELSE
      CLOSE cr_crapjur;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possível validar socios (CADA0004.pc_valida_socios): '||SQLERRM;
  END pc_valida_socios;

  /******************************************************************************/
  /**   Function para verificar se as letras de seguranca estao cadastradas   **/
  /******************************************************************************/
  FUNCTION fn_verif_letras_seguranca( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                     ) RETURN INTEGER IS

  /* ..........................................................................
    --
    --  Programa : fn_verif_letras_seguranca        Antiga: b1wgen0032.p/verifica-letras-seguranca
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Agosto/2015.                   Ultima atualizacao: 31/08/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para verificar se as letras de seguranca estao cadastradas
    --
    --  Alteração : 03/08/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- verificar senhas
    CURSOR cr_crapsnh IS
      SELECT crapsnh.cddsenha
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.idseqttl = pr_idseqttl
         AND crapsnh.tpdsenha = 3; -- letras
    rw_crapsnh cr_crapsnh%ROWTYPE;

  BEGIN
    -- buscar senha
    OPEN cr_crapsnh;
    FETCH cr_crapsnh INTO rw_crapsnh;

    --> verificar se encontrou senha e possui valor
    IF cr_crapsnh%FOUND AND
       TRIM(rw_crapsnh.cddsenha) IS NOT NULL THEN
      CLOSE cr_crapsnh;
      -- retornar verdadeiro
      RETURN 1; --TRUE
    END IF;

    -- retorna falso
    CLOSE cr_crapsnh;
    RETURN 0; --FALSE

  END fn_verif_letras_seguranca;

  /******************************************************************************/
  /**                Funcao para retornar situacao do cartao                **/
  /******************************************************************************/
  FUNCTION fn_situacao_cartao_mag( pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE  --> Data do movimenti
                                  ,pr_dtvalcar  IN crapcrm.dtvalcar%TYPE  --> Data de validade
                                  ,pr_cdsitcar  IN crapcrm.cdsitcar%TYPE  --> Codigo de Situação
                                  ,pr_dtemscar  IN crapcrm.dtemscar%TYPE  --> Data emissao
                                  )RETURN VARCHAR IS --> Retorna descriçao da situacao

  /* ..........................................................................
    --
    --  Programa : pc_situacao_cartao_mag        Antiga: b1wgen0032.p/verifica-situacao-cartao
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembto/2015.                   Ultima atualizacao: 11/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Funcao para retornar situacao do cartao
    --
    --  Alteração : 11/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/

    ---------------> Variaveis <-----------------
    vr_dssitcar VARCHAR2(80) := NULL;
    vr_dstextab craptab.dstextab%TYPE;

  BEGIN
    IF pr_cdsitcar = 1 THEN
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'AUTOMA'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'CM'||to_char(pr_dtemscar,'DDMMRRRR')
                                                 ,pr_tpregist => 0);
      IF TRIM(vr_dstextab) = 1 THEN
        vr_dssitcar := 'DISPONIVEL';
      ELSE
        vr_dssitcar := 'SOLICITADO';
      END IF;

    ELSE

      CASE pr_cdsitcar
        WHEN 2 THEN
          IF pr_dtvalcar < pr_dtmvtolt THEN
            vr_dssitcar := 'VENCIDO';
          ELSE
            vr_dssitcar := 'ENTREGUE';
          END IF;
        WHEN 3 THEN
          vr_dssitcar := 'CANCELADO';
        WHEN 4 THEN
          vr_dssitcar := 'BLOQUEADO';
        ELSE
          vr_dssitcar := 'INDETERMINADO';
      END CASE;

    END IF;

    RETURN vr_dssitcar;

  END fn_situacao_cartao_mag;

  /******************************************************************************/
  /**           Procedure para obter cartoes magneticos do associado           **/
  /******************************************************************************/
  PROCEDURE pc_obtem_cartoes_magneticos( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                        ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                        ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                        ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                        ,pr_dtmvtolt IN DATE                   --> Data do movimento
                                        ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                                        ------ OUT ------
                                        ,pr_qtcarmag               OUT INTEGER                     --> retorna quantidade de cartoes
                                        ,pr_tab_cartoes_magneticos OUT typ_tab_cartoes_magneticos  --> retorna temptable com os dados dos cartoes
                                        ,pr_des_reto               OUT VARCHAR2                    --> OK ou NOK
                                        ,pr_tab_erro               OUT gene0001.typ_tab_erro) IS

  /* ..........................................................................
    --
    --  Programa : pc_obtem_cartoes_magneticos        Antiga: b1wgen0032.p/obtem-cartoes-magneticos
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembro/2015.                   Ultima atualizacao: 11/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para obter cartoes magneticos do associado
    --
    --  Alteração : 11/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --              08/12/2016 - P341-Automatização BACENJUD - Realizar a validação
    --                           do departamento pelo código do mesmo (Renato Darosci)
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --> buscar cartoes magneticos
    CURSOR cr_crapcrm ( pr_cdcooper  crapcrm.cdcooper%TYPE,
                        pr_nrdconta  crapcrm.nrdconta%TYPE,
                        pr_tpcarcta  crapcrm.tpcarcta%TYPE) IS
      SELECT crapcrm.cdsitcar
            ,crapcrm.dtvalcar
            ,crapcrm.dtcancel
            ,crapcrm.nmtitcrd
            ,crapcrm.nrcartao
            ,crapcrm.tpusucar
            ,crapcrm.dtemscar
        FROM crapcrm
       WHERE crapcrm.cdcooper = pr_cdcooper
         AND crapcrm.nrdconta = pr_nrdconta
         AND crapcrm.tpcarcta = pr_tpcarcta;

    -- buscar operador
    CURSOR cr_crapope IS
      SELECT cddepart
        FROM crapope
       WHERE crapope.cdcooper = pr_cdcooper
         AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;

    --------------> VARIAVEIS <-----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(200);
    vr_tpcarcta INTEGER;
    vr_dssitcar VARCHAR2(200);
    vr_idx      INTEGER;
    vr_nrdrowid ROWID;


  BEGIN
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Obter cartoes magneticos do associado';
    pr_qtcarmag := 0;

    IF pr_nmdatela = 'ATENDA' THEN
      vr_tpcarcta := 1;
    ELSE
      vr_tpcarcta := 9;
    END IF;

    --> buscar cartoes magneticos
    FOR rw_crapcrm IN cr_crapcrm ( pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_tpcarcta => vr_tpcarcta) LOOP

      -- se estiver ativo e valido
      IF rw_crapcrm.cdsitcar = 2            AND
         rw_crapcrm.dtvalcar >= pr_dtmvtolt THEN
        pr_qtcarmag := nvl(pr_qtcarmag,0) + 1;
      END IF;

      -- Buscar operador
      OPEN cr_crapope;
      FETCH cr_crapope INTO rw_crapope;

      IF cr_crapope%NOTFOUND THEN
        CLOSE cr_crapope;
        -- senao encontrou operador, abortar programa
        vr_cdcritic := 67; --> 067 - Operador nao cadastrado.
        vr_dscritic := NULL;
        RAISE vr_exc_erro;

      ELSE
        CLOSE cr_crapope;
      END IF;

      /** Mostra todos os cartoes somente para SUPER-USUARIO **/
      /** Despreza cancelados e vencidos ha mais de 180 dias **/
      IF rw_crapope.cddepart <> 20  AND  -- TI
         ((rw_crapcrm.cdsitcar = 3 AND
          rw_crapcrm.dtcancel < (pr_dtmvtolt - 180))   OR
          (rw_crapcrm.cdsitcar = 2  AND
          rw_crapcrm.dtvalcar < (pr_dtmvtolt - 180)))  THEN
        continue;
      END IF;

      vr_dssitcar := fn_situacao_cartao_mag( pr_cdcooper => pr_cdcooper           --> Codigo da cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt           --> Data do movimenti
                                            ,pr_dtvalcar => rw_crapcrm.dtvalcar   --> Data de validade
                                            ,pr_cdsitcar => rw_crapcrm.cdsitcar   --> Codigo de Situação
                                            ,pr_dtemscar => rw_crapcrm.dtemscar );--> Data emissao

      -- Incluir na temptable
      vr_idx := pr_tab_cartoes_magneticos.count + 1;
      pr_tab_cartoes_magneticos(vr_idx).nmtitcrd := rw_crapcrm.nmtitcrd;
      pr_tab_cartoes_magneticos(vr_idx).nrcartao := to_char(rw_crapcrm.nrcartao,'fm0000G0000G0000G0000');
      pr_tab_cartoes_magneticos(vr_idx).dssitcar := vr_dssitcar;
      pr_tab_cartoes_magneticos(vr_idx).tpusucar := rw_crapcrm.tpusucar;

    END LOOP; --> Fim Loop crpcrm

    -- Se foi solicitado log
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => vr_dsorigem --> Origem enviada
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => pr_dtmvtolt
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                           ,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;

    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Gerar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                             ,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro pc_obtem_cartoes_magneticos:'||SQLERRM;
      -- Gerar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                             ,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';
  END pc_obtem_cartoes_magneticos;

  /******************************************************************************/
  /**   Function para obter situacao da senha                                  **/
  /******************************************************************************/
  FUNCTION fn_situacao_senha ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                              ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                              ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                              ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                              ,pr_idorigem IN INTEGER                --> Identificado de oriem
                              ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                              ,pr_tpdsenha IN crapsnh.tpdsenha%TYPE  --> tipo de senha(1-Internet 2-URA)
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                              ) RETURN VARCHAR2 IS --> returnar descricao da situacao(dssitura)

  /* ..........................................................................
    --
    --  Programa : fn_situacao_senha        Antiga: b1wgen0015.p/obtem_situacao_ura
    --                                                           obtem_situacao_internet
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembro/2015.                   Ultima atualizacao: 16/05/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para obter situacao da senha do Tele-Atendimento
    --
    --  Alteração : 11/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --              30/11/2015 - Ajustes para projeto de assinatura multipla PJ.
    --                           Baseado na condicao da atenda.p (Jorge/David)
    --
    --              16/05/2016 - Ajustes para filtrar o registro com o
    --                           pr_idseqttl. (Jaison/Aline - SD: 446318)
    --
    -- ..........................................................................*/

    ---------------> VARIAVEIS <----------------

    aux_idastcjt NUMBER := 0;
    aux_cdsitsnh NUMBER := 0;

    ---------------> CURSORES <-----------------

    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT idastcjt FROM crapass
      WHERE crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = pr_nrdconta;

    -- verificar senha da ura
    CURSOR cr_crapsnh (pr_cdcooper crapsnh.cdcooper%TYPE,
                       pr_nrdconta crapsnh.nrdconta%TYPE,
                       pr_tpdsenha crapsnh.tpdsenha%TYPE,
                       pr_idseqttl crapsnh.idseqttl%TYPE) IS
      SELECT (CASE crapsnh.cdsitsnh
                WHEN 0 THEN 'INATIVA'
                WHEN 1 THEN 'ATIVA'
                WHEN 2 THEN 'BLOQUEADA'
                WHEN 3 THEN 'CANCELADA'
                ELSE NULL
              END)  AS dssitsnh
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.tpdsenha = pr_tpdsenha
         AND ((pr_tpdsenha = 2 AND crapsnh.idseqttl = 0) OR -- URA
              (pr_tpdsenha = 1 AND crapsnh.idseqttl = DECODE(NVL(pr_idseqttl, 0), 0, 1, pr_idseqttl)) -- Internet
             );
    rw_crapsnh cr_crapsnh%ROWTYPE;

    CURSOR cr_crapsnh2 (pr_cdcooper crapsnh.cdcooper%TYPE,
                        pr_nrdconta crapsnh.nrdconta%TYPE,
                        pr_nrcpfcgc crapsnh.nrcpfcgc%TYPE) IS
      SELECT cdsitsnh
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.tpdsenha = 1
         AND crapsnh.nrcpfcgc = pr_nrcpfcgc;

    CURSOR cr_crappod (pr_cdcooper crappod.cdcooper%TYPE,
                       pr_nrdconta crappod.nrdconta%TYPE) IS
      SELECT crappod.nrcpfpro
        FROM crappod
       WHERE crappod.cdcooper = pr_cdcooper AND
             crappod.nrdconta = pr_nrdconta AND
             crappod.cddpoder = 10           AND
             crappod.flgconju = 1;
    rw_crappod cr_crappod%ROWTYPE;

  BEGIN
    --------------> Internet <-------------
    IF pr_tpdsenha = 1 THEN
      rw_crapsnh.dssitsnh := 'INATIVA';

      -- buscar indice se conta exige assinatura multipla
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO aux_idastcjt;
      CLOSE cr_crapass;

      /* se nao nescessita assinatura multipla */
      IF aux_idastcjt = 0 THEN
         -- buscar situacao da senha para Internet
         OPEN cr_crapsnh (pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_tpdsenha => pr_tpdsenha,
                          pr_idseqttl => pr_idseqttl);
         FETCH cr_crapsnh INTO rw_crapsnh;
         CLOSE cr_crapsnh;
      ELSE
         -- verifica na tabela de poderes
         FOR rw_crappod IN cr_crappod (pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => pr_nrdconta) LOOP
             rw_crapsnh.dssitsnh := 'ATIVA';

             OPEN cr_crapsnh2 (pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => pr_nrdconta,
                               pr_nrcpfcgc => rw_crappod.nrcpfpro);
             FETCH cr_crapsnh2 INTO aux_cdsitsnh;

             IF cr_crapsnh2%NOTFOUND OR aux_cdsitsnh = 0 THEN
                rw_crapsnh.dssitsnh := 'INATIVA';
                CLOSE cr_crapsnh2;
                EXIT;
             END IF;

             IF aux_cdsitsnh = 2 THEN
                rw_crapsnh.dssitsnh := 'BLOQUEADA';
                CLOSE cr_crapsnh2;
                EXIT;
             END IF;

             IF aux_cdsitsnh = 3 THEN
                rw_crapsnh.dssitsnh := 'CANCELADA';
                CLOSE cr_crapsnh2;
                EXIT;
             END IF;

             CLOSE cr_crapsnh2;

         END LOOP;

      END IF;

    ELSE ---------> URA <------------

      -- buscar situacao da senha para URA
      OPEN cr_crapsnh (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_tpdsenha => pr_tpdsenha,
                       pr_idseqttl => pr_idseqttl);
      FETCH cr_crapsnh INTO rw_crapsnh;
      CLOSE cr_crapsnh;

    END IF;

    -- retornar descricao da situacao
    RETURN rw_crapsnh.dssitsnh;

  END fn_situacao_senha;

  /******************************************************************************/
  /**          Procedure para lista convenios autorizados para debito          **/
  /******************************************************************************/
  PROCEDURE pc_lista_conven( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                            ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                            ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                            ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                            ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                            ,pr_idorigem IN INTEGER                --> Identificado de oriem
                            ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                            ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                            ,pr_dtmvtolt IN DATE                   --> Data do movimento
                            ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                            ------ OUT ------
                            ,pr_qtconven     OUT INTEGER           --> retorna quantidade de convenios
                            ,pr_tab_conven   OUT typ_tab_conven    --> retorna temptable com os dados dos convenios
                            ,pr_cdcritic     OUT NUMBER
                            ,pr_dscritic     OUT VARCHAR2) IS

  /* ..........................................................................
    --
    --  Programa : pc_lista_conven        Antiga: b1wgen0026.p/lista_conven
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembro/2015.                   Ultima atualizacao: 11/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para lista convenios autorizados para debito
    --
    --  Alteração : 11/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -->  Buscar autorizacoes de debito em conta
    CURSOR cr_crapatr IS
      SELECT crapatr.cdcooper,
             crapatr.nrdconta,
             crapatr.cdhistor,
             craphis.dsexthst,
             crapatr.dtiniatr,
             crapatr.dtultdeb,
             crapatr.cdrefere
        FROM crapatr
            ,craphis
       WHERE craphis.cdcooper = pr_cdcooper
         AND craphis.cdcooper = crapatr.cdcooper
         AND craphis.cdhistor = crapatr.cdhistor
         AND crapatr.cdcooper = pr_cdcooper
         AND crapatr.nrdconta = pr_nrdconta
         AND crapatr.dtfimatr IS NULL
       ORDER BY crapatr.dtiniatr
               ,crapatr.cdhistor;

    --------------> VARIAVEIS <-----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(200);
    vr_idx      INTEGER;
    vr_nrdrowid ROWID;

  BEGIN
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Listar convenios ativos.';
    pr_qtconven := 0;

     -->  Buscar autorizacoes de debito em conta
    FOR rw_crapatr IN cr_crapatr  LOOP
      -- incluir na temptable
      vr_idx := pr_tab_conven.count + 1;
      pr_tab_conven(vr_idx).cdcooper := rw_crapatr.cdcooper;
      pr_tab_conven(vr_idx).nrdconta := rw_crapatr.nrdconta;
      pr_tab_conven(vr_idx).cdhistor := rw_crapatr.cdhistor;
      pr_tab_conven(vr_idx).dsexthst := SUBSTR(rw_crapatr.dsexthst,1,28);
      pr_tab_conven(vr_idx).dtiniatr := rw_crapatr.dtiniatr;
      pr_tab_conven(vr_idx).dtultdeb := rw_crapatr.dtultdeb;
      pr_tab_conven(vr_idx).cdrefere := SUBSTR(to_char(rw_crapatr.cdrefere,'fm0000000000000000000000000'),9,17);

      pr_qtconven := pr_qtconven + 1;
    END LOOP;

    -- Se foi solicitado log
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => vr_dsorigem --> Origem enviada
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => pr_dtmvtolt
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na CADA0004.pc_lista_conven: '||SQLERRM;
  END pc_lista_conven;

  /******************************************************************************/
  /**        Funcao para verificar qual a administradora do cartao             **/
  /******************************************************************************/
  FUNCTION fn_verifica_adm (pr_cdadmcrd IN INTEGER) RETURN INTEGER IS
  /* ..........................................................................
    --
    --  Programa : fn_verifica_adm        Antiga: b1wgen0028.p/f_verifica_adm
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembro/2015.                   Ultima atualizacao: 11/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Funcao para verificar qual a administradora do cartao
    --
    --  Alteração : 11/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/
  BEGIN
    IF pr_cdadmcrd >= 83 AND pr_cdadmcrd <= 88 THEN /*Banco do Brasil*/
      RETURN 1;
    ELSIF pr_cdadmcrd >= 10 AND pr_cdadmcrd <= 80 THEN /*Bancoob*/
      RETURN 2;
    ELSE /*Bradesco*/
      RETURN 3;
    END IF;

  END fn_verifica_adm;

  /******************************************************************************/
  /**        Funcao para verificar qual a administradora do cartao (WEB)       **/
  /******************************************************************************/
  PROCEDURE pc_verifica_adm_web(pr_cdadmcrd IN INTEGER --> Codigo da administradora
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS
      --> Erros do processo
      /* .............................................................................

          Programa: pc_verifica_adm_web
          Sistema : CECRED
          Sigla   : CRD
          Autor   : Augusto (Supero)
          Data    : Setembro/2018                 Ultima atualizacao: 15/09/2018

          Dados referentes ao programa:

          Frequencia: Sempre que for chamado

          Objetivo  : Retorna a administradora

          Observacao: -----

          Alteracoes:
      ..............................................................................*/

      -- Tratamento de erros
      vr_cdcritic NUMBER := 0;
      vr_dscritic VARCHAR2(4000);
  BEGIN

      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados><Administradora>' || fn_verifica_adm(pr_cdadmcrd) ||
                                     '</Administradora></Dados></Root>');

  EXCEPTION
      WHEN OTHERS THEN

          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral na rotina na procedure CADA0004.pc_verifica_adm_web. Erro: ' || SQLERRM;
          pr_des_erro := 'NOK';
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                         pr_dscritic || '</Erro></Root>');
  END pc_verifica_adm_web;

  /******************************************************************************/
  /**        Funcao para retotnar a descricao da situacao do cartao            **/
  /******************************************************************************/
  FUNCTION fn_retorna_situacao_cartao ( pr_insitcrd IN INTEGER
                                       ,pr_dtsol2vi IN DATE
                                       ,pr_cdadmcrd IN INTEGER)
                                        RETURN VARCHAR2 IS

   /* ..........................................................................
    --
    --  Programa : fn_retorna_situacao_cartao        Antiga: b1wgen0028.p/retorna-situacao
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembro/2015.                   Ultima atualizacao: 11/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Funcao para retotnar a descricao da situacao do cartao
    --
    --  Alteração : 11/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/

    vr_dssitcrd VARCHAR2(50) := NULL;
  BEGIN

    -- Verificar descrições de cada situacao
    CASE pr_insitcrd
      WHEN 0 THEN
        vr_dssitcrd := 'Estudo';
      WHEN 1 THEN
        vr_dssitcrd := 'Aprov.';
      WHEN 2 THEN
        vr_dssitcrd := 'Solic.';
      WHEN 3 THEN
        vr_dssitcrd := 'Liber.';
      WHEN 4 THEN
        IF pr_dtsol2vi IS NOT NULL THEN
          vr_dssitcrd := 'Sol.2v';
        ELSIF fn_verifica_adm(pr_cdadmcrd) = 1 THEN
          vr_dssitcrd := 'Prc.BB';
        ELSE
          vr_dssitcrd := 'Em uso';
        END IF;
      WHEN 5 THEN
        IF fn_verifica_adm(pr_cdadmcrd) IN (1,2) THEN
          vr_dssitcrd := 'Bloque';
        ELSE
          vr_dssitcrd := 'Cancel';
        END IF;
      WHEN 6 THEN
        IF fn_verifica_adm(pr_cdadmcrd) = 2 THEN
          vr_dssitcrd := 'Cancel';
        ELSE
          vr_dssitcrd := 'Encer.';
        END IF;
      WHEN 7 THEN
        vr_dssitcrd := 'Sol.2v';
      ELSE
        vr_dssitcrd := '??????';
      END CASE;

    RETURN vr_dssitcrd;

  END fn_retorna_situacao_cartao;


  /******************************************************************************/
  /**            Procedure para listar cartoes do cooperado                    **/
  /******************************************************************************/
  PROCEDURE pc_lista_cartoes(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                            ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                            ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                            ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                            ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                            ,pr_idorigem IN INTEGER                --> Identificado de oriem
                            ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                            ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                            ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da cooperativa
                            ,pr_flgzerar IN VARCHAR2 DEFAULT 'S'  --> Flag para Zerar limite
                            ,pr_flgprcrd IN crawcrd.flgprcrd%TYPE DEFAULT 0 --> Considerar apenas titular (0-Nao,1-Sim)
                            ------ OUT ------
                            ,pr_flgativo     OUT INTEGER           --> Retorna situação 1-ativo 2-inativo
                            ,pr_nrctrhcj     OUT NUMBER            --> Retorna numero do contrato
                            ,pr_flgliber     OUT INTEGER           --> Retorna se esta liberado 1-sim 2-nao
                            ,pr_vltotccr     OUT NUMBER            --> retorna total de limite do cartao
                            ,pr_tab_cartoes  OUT typ_tab_cartoes   --> retorna temptable com os dados dos convenios
                            ,pr_des_reto     OUT VARCHAR2                    --> OK ou NOK
                            ,pr_tab_erro     OUT gene0001.typ_tab_erro) IS

  /* ..........................................................................
    --
    --  Programa : pc_lista_cartoes        Antiga: b1wgen0028.p/lista_cartoes
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembro/2015.                   Ultima atualizacao: 11/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para listar cartoes do cooperado
    --
    --  Alteração : 11/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --> Buscar dados associado
    CURSOR cr_crapass IS
      SELECT crapass.cdagenci,
             crapass.inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -->  Buscar cartoes de credito do cooperado
    CURSOR cr_crawcrd IS
      SELECT crawcrd.cdadmcrd
            ,crawcrd.insitcrd
            ,crawcrd.tpcartao
            ,crawcrd.cdlimcrd
            ,crawcrd.dtsol2vi
            ,crawcrd.nmtitcrd
            ,crawcrd.nrcrcard
            ,crawcrd.nrctrcrd
            ,crawcrd.nrcpftit
            ,crawcrd.vllimcrd
            ,crapadc.nmresadm
            ,crapadc.flgcchip
            ,crawcrd.nrdconta
            ,crawcrd.flgprcrd
        FROM crawcrd
            ,crapadc
       WHERE crapadc.cdcooper = crawcrd.cdcooper
         AND crapadc.cdadmcrd = crawcrd.cdadmcrd
         AND crawcrd.cdcooper = pr_cdcooper
         AND crawcrd.nrdconta = pr_nrdconta;

    --> Buscar limites de cartao de credito e dias de debito.
    CURSOR cr_craptlc (pr_cdcooper  craptlc.cdcooper%TYPE,
                       pr_cdadmcrd  craptlc.cdadmcrd%TYPE,
                       pr_tpcartao  craptlc.tpcartao%TYPE,
                       pr_cdlimcrd  craptlc.cdlimcrd%TYPE) IS
      SELECT craptlc.vllimcrd
        FROM craptlc
       WHERE craptlc.cdcooper = pr_cdcooper
         AND craptlc.cdadmcrd = pr_cdadmcrd
         AND craptlc.tpcartao = pr_tpcartao
         AND craptlc.cdlimcrd = pr_cdlimcrd
         AND craptlc.dddebito = 0;
    rw_craptlc cr_craptlc%ROWTYPE;

    --> Buscar conta
    CURSOR cr_crapass_cpf ( pr_cdcooper crapass.cdcooper%TYPE,
                            pr_nrcpftit crapass.nrcpfcgc%TYPE) IS
      SELECT nrdconta
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrcpfcgc = pr_nrcpftit;
    rw_crapass_cpf cr_crapass_cpf%ROWTYPE;

    --> Buscar contas juridicas para utilizacao de cartao de credit
    CURSOR cr_craphcj (pr_cdcooper craphcj.cdcooper%TYPE,
                       pr_nrdconta craphcj.nrdconta%TYPE) IS
      SELECT craphcj.flgativo
            ,craphcj.nrctrhcj
        FROM craphcj
       WHERE craphcj.cdcooper = pr_cdcooper
         AND craphcj.nrdconta = pr_nrdconta;
    rw_craphcj cr_craphcj%ROWTYPE;

    --------------> VARIAVEIS <-----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_cdagenci crapass.cdagenci%TYPE;

    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(200);
    vr_idx      INTEGER;
    vr_nrdrowid ROWID;
    vr_dssitcrd VARCHAR2(50);

  BEGIN

    -- Buscar dados do cooperado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%FOUND THEN
      vr_cdagenci := rw_crapass.cdagenci;
    ELSE
      vr_cdagenci := 0;
    END IF;
    CLOSE cr_crapass;

    IF (pr_cdcooper = 2 AND vr_cdagenci = 5)     OR
       (pr_cdcooper = 1 AND pr_dtmvtolt >= to_date('11/12/2012','DD/MM/RRRR') AND
        vr_cdagenci IN (7,33,38,60,62))  OR
       (pr_cdcooper = 2 AND pr_dtmvtolt >= to_date('16/12/2013','DD/MM/RRRR') AND
        vr_cdagenci IN (2,4,6,7,11)) THEN
      pr_flgliber := 0; -- FALSE
    ELSE
      pr_flgliber := 1; --TRUE
    END IF;

    /* Apos o perido definido as conta da Concredi ou Credimilsul
       nao poderam mais realizar operacoes dos cartoes, devido a migraçao.
    */
    IF (pr_cdcooper =  4 AND pr_dtmvtolt >= to_date('12/11/2014','DD/MM/RRRR'))  OR
       (pr_cdcooper = 15 AND pr_dtmvtolt >= to_date('07/11/2012','DD/MM/RRRR'))  THEN
      pr_flgliber := 0; --FALSE
    END IF;

    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Listar cartoes de credito.';
    pr_vltotccr := 0;

    FOR rw_crawcrd IN cr_crawcrd LOOP

      -- Buscar situação
      vr_dssitcrd := fn_retorna_situacao_cartao( pr_insitcrd => rw_crawcrd.insitcrd
                                                ,pr_dtsol2vi => rw_crawcrd.dtsol2vi
                                                ,pr_cdadmcrd => rw_crawcrd.cdadmcrd);
      -- diferente de bancoob
      IF fn_verifica_adm(rw_crawcrd.cdadmcrd) <> 2 THEN

        /* Se estiver em uso soma o valor total de limite de todos os cartoes */
        IF rw_crawcrd.insitcrd IN (4,7) THEN

          --> Buscar limites de cartao de credito e dias de debito.
          OPEN cr_craptlc (pr_cdcooper => pr_cdcooper,
                           pr_cdadmcrd => rw_crawcrd.cdadmcrd,
                           pr_tpcartao => rw_crawcrd.tpcartao,
                           pr_cdlimcrd => rw_crawcrd.cdlimcrd);
          FETCH cr_craptlc INTO rw_craptlc;

          -- senao encontrou apresentar critica
          IF cr_craptlc%NOTFOUND THEN
            CLOSE cr_craptlc;
            vr_cdcritic := 532; --> 532 - Falta tabela de limite de cartao de credito.
            vr_dscritic := NULL;
            RAISE vr_exc_erro;
          ELSE
            CLOSE cr_craptlc;
          END IF;

          pr_vltotccr := pr_vltotccr + rw_craptlc.vllimcrd;

        END IF; --> Fim IF insitcrd IN (4,7)
      ELSE

        -- se for para considerar apenas o titular ele pula o registro
        IF pr_flgprcrd = 1 and rw_crawcrd.flgprcrd = 0 THEN
          continue;
        END IF;

        -- P337 - SOmente zerar se passado via parametro [ZERAR LIMITE CONFORME SD 181559]
        IF pr_flgzerar = 'N' THEN
          -- Somente acumular limite conforme situação cartão
          IF vr_dssitcrd IN ('Solic.','Liber.','Sol.2v','Prc.BB','Em uso','Sol.2v') THEN
            pr_vltotccr := pr_vltotccr + rw_crawcrd.vllimcrd;
      END IF;
        END IF;
      END IF;


      vr_idx := pr_tab_cartoes.count;

      pr_tab_cartoes(vr_idx).nmtitcrd := Rpad(rw_crawcrd.nmtitcrd,27,' ');
      pr_tab_cartoes(vr_idx).nmresadm := Rpad(rw_crawcrd.nmresadm,30,' ');
      pr_tab_cartoes(vr_idx).nrcrcard := to_char(rw_crawcrd.nrcrcard,'0000G0000G0000G0000');
      pr_tab_cartoes(vr_idx).dssitcrd := vr_dssitcrd;
      pr_tab_cartoes(vr_idx).nrctrcrd := rw_crawcrd.nrctrcrd;
      pr_tab_cartoes(vr_idx).cdadmcrd := rw_crawcrd.cdadmcrd;
      pr_tab_cartoes(vr_idx).flgcchip := rw_crawcrd.flgcchip;

      --> Mascara número de cartao de for Bancoob
      IF fn_verifica_adm(rw_crawcrd.cdadmcrd) = 2 THEN
        pr_tab_cartoes(vr_idx).dscrcard := SUBSTR(pr_tab_cartoes(vr_idx).nrcrcard ,1,4) ||'.'||
                                           SUBSTR(pr_tab_cartoes(vr_idx).nrcrcard ,6,2) ||'**.****.'||
                                           SUBSTR(pr_tab_cartoes(vr_idx).nrcrcard ,16,4);
      ELSE
        pr_tab_cartoes(vr_idx).dscrcard := pr_tab_cartoes(vr_idx).nrcrcard;
      END IF;

      --> Buscar associado
      rw_crapass_cpf := NULL;
      OPEN cr_crapass_cpf ( pr_cdcooper => pr_cdcooper,
                            pr_nrcpftit => rw_crawcrd.nrcpftit);
      FETCH cr_crapass_cpf INTO rw_crapass_cpf;
      IF cr_crapass_cpf%FOUND THEN
        pr_tab_cartoes(vr_idx).nrdconta := rw_crapass_cpf.nrdconta;
      ELSE
        pr_tab_cartoes(vr_idx).nrdconta := rw_crawcrd.nrdconta;
      END IF;
      CLOSE cr_crapass_cpf;


    END LOOP; -- FIM LOOP cr_crawcrd

    IF rw_crapass.inpessoa = 1 THEN
      pr_flgativo := 0;
      pr_nrctrhcj := 0;
    ELSE
      --> Buscar contas juridicas para utilizacao de cartao de credit
      OPEN cr_craphcj (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_craphcj INTO rw_craphcj;
      -- verificar se encontrou
      IF cr_craphcj%FOUND THEN
        pr_flgativo := rw_craphcj.flgativo;
        pr_nrctrhcj := rw_craphcj.nrctrhcj;
      ELSE
        pr_flgativo := 0;
        pr_nrctrhcj := 0;
      END IF;
      CLOSE cr_craphcj;
    END IF;

    -- Se foi solicitado log
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => vr_dsorigem --> Origem enviada
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => pr_dtmvtolt
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;

    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro CADA0004.pc_lista_cartoes:'||SQLERRM;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';
  END pc_lista_cartoes;

  /******************************************************************************/
  /**            Procedure para listar ocorrencias do cooperado                **/
  /******************************************************************************/
  PROCEDURE pc_lista_ocorren(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                            ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                            ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                            ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                            ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                            ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE --> Data da cooperativa
                            ,pr_idorigem IN INTEGER                --> Identificado de oriem
                            ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                            ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                            ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                            ------ OUT ------
                            ,pr_tab_ocorren  OUT typ_tab_ocorren   --> retorna temptable com os dados dos convenios
                            ,pr_des_reto     OUT VARCHAR2          --> OK ou NOK
                            ,pr_tab_erro     OUT gene0001.typ_tab_erro) IS

  /* ..........................................................................
    --
    --  Programa : pc_lista_ocorren        Antiga: b1wgen0027.p/lista_ocorren
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembro/2015.                   Ultima atualizacao: 30/01/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para listar ocorrencias do cooperado
    --
    --  Alteração : 14/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --              30/01/2017 - Exibir mensagem de atrasado quando for produto Pos-Fixado.
    --                           (Jaison/James - PRJ298)
    --              03/04/2019 - substituir a tabela crapnrc pela tbrisco_operacoes
    --                           P450 - (Mario - AMcom)
    --
    --              23/04/2018 - Ajuste na tratativa Cooper Central (cdcooper=3)nas 2 tabelas
    --                           crapnrc e tbrisco_operacoes (Mário-AMcom)
    --
    --              25/07/2019 - Parametro para habilitar o novo rating e usar novas rotinas
    --                           (Luiz Otávio Olinger Momm - AMcom)
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
     --> Buscar dados associado
    CURSOR cr_crapass IS
      SELECT crapass.cdagenci,
             crapass.inpessoa,
             crapass.inadimpl,
             crapass.inlbacen,
             crapass.cdsitdtl,
             crapass.nrdconta,
             crapass.nmprimtl,
             crapass.dtdsdspc,
             crapass.dtcnsspc,
             crapass.inrisctl,
             crapass.dtrisctl

        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --> buscar saldo do cooperado
    CURSOR cr_crapsld (pr_cdcooper crapsld.cdcooper%TYPE,
                       pr_nrdconta crapsld.nrdconta%TYPE) IS
      SELECT crapsld.nrdconta,
             crapsld.qtddsdev,
             crapsld.qtddtdev,
             crapsld.dtdsdclq

        FROM crapsld
       WHERE crapsld.cdcooper = pr_cdcooper
         AND crapsld.nrdconta = pr_nrdconta;
    rw_crapsld cr_crapsld%ROWTYPE;

    --> buscar qtd de Contra-Ordens
    CURSOR cr_crapcor_qtd (pr_cdcooper crapsld.cdcooper%TYPE,
                           pr_nrdconta crapsld.nrdconta%TYPE) IS
      SELECT COUNT(*)
        FROM crapcor
       WHERE crapcor.cdcooper = pr_cdcooper
         AND crapcor.nrdconta = pr_nrdconta
         AND crapcor.flgativo = 1; --TRUE

    --> buscar qtd de controle dos saldos negativos e devolucoes de cheques.
    CURSOR cr_crapneg_qtd (pr_cdcooper crapsld.cdcooper%TYPE,
                           pr_nrdconta crapsld.nrdconta%TYPE) IS
      SELECT /*+index (crapneg CRAPNEG##CRAPNEG2)*/
             COUNT(*)
        FROM crapneg
       WHERE crapneg.cdcooper = pr_cdcooper
         AND crapneg.nrdconta = pr_nrdconta
         AND crapneg.cdhisest = 1
         AND crapneg.cdobserv IN (11,12,13);

    -- Selecionar os dados da tabela Generica
    CURSOR cr_craptab (pr_cdcooper   craptab.cdcooper%TYPE
                      ,pr_nmsistem   craptab.nmsistem%TYPE
                      ,pr_tptabela   craptab.tptabela%TYPE
                      ,pr_cdempres   craptab.cdempres%TYPE
                      ,pr_cdacesso   craptab.cdacesso%TYPE) IS
      SELECT  GENE0002.fn_char_para_number(SubStr(craptab.dstextab,12,2)) contador
             ,TRIM(SUBSTR(craptab.dstextab,8,3)) dsdrisco
      FROM craptab  craptab
      WHERE craptab.cdcooper        = pr_cdcooper
      AND   UPPER(craptab.nmsistem) = pr_nmsistem
      AND   UPPER(craptab.tptabela) = pr_tptabela
      AND   craptab.cdempres        = pr_cdempres
      AND   UPPER(craptab.cdacesso) = pr_cdacesso;

    --> Buscar risco
    CURSOR cr_crapris (pr_cdcooper  crapris.cdcooper%TYPE,
                       pr_nrdconta  crapris.nrdconta%TYPE,
                       pr_dtrefere  crapris.dtrefere%TYPE,
                       pr_vlarrasto crapris.vldivida%TYPE)IS
    SELECT /*+index_desc (crapris CRAPRIS##CRAPRIS1)*/
           crapris.innivris,
           crapris.dtdrisco
      FROM crapris
     WHERE crapris.cdcooper = pr_cdcooper
       AND crapris.nrdconta = pr_nrdconta
       AND crapris.dtrefere = pr_dtrefere
       AND crapris.inddocto = 1
       AND (crapris.vldivida > pr_vlarrasto OR
            pr_vlarrasto = 0);
    rw_crapris cr_crapris%ROWTYPE;

    -- verificar se existe algum emprestimo em prejuizo
    CURSOR cr_crapepr (pr_cdcooper crapsld.cdcooper%TYPE,
                       pr_nrdconta crapsld.nrdconta%TYPE) IS
    SELECT 1
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.inprejuz = 1;

    --> Buscar Rating efetivo
    CURSOR cr_crapnrc (pr_cdcooper crapsld.cdcooper%TYPE,
                       pr_nrdconta crapsld.nrdconta%TYPE) IS
      SELECT indrisco
        FROM crapnrc
       WHERE crapnrc.cdcooper = pr_cdcooper
         AND crapnrc.nrdconta = pr_nrdconta
         AND crapnrc.insitrat = 2;
    rw_crapnrc cr_crapnrc%ROWTYPE;

    --> Buscar Rating P450 efetivo
    CURSOR cr_tbrisco_operacoes (pr_cdcooper crapsld.cdcooper%TYPE,
                       pr_nrdconta crapsld.nrdconta%TYPE) IS
      SELECT risc0004.fn_traduz_risco(tbrisco_operacoes.inrisco_rating )  indrisco
        FROM tbrisco_operacoes
       WHERE tbrisco_operacoes.cdcooper = pr_cdcooper
         AND tbrisco_operacoes.cdcooper <> 3
         AND tbrisco_operacoes.nrdconta = pr_nrdconta
         AND tbrisco_operacoes.insituacao_rating = 4
      UNION
      SELECT indrisco
        FROM crapnrc
       WHERE crapnrc.cdcooper = pr_cdcooper
         AND crapnrc.cdcooper = 3
         AND crapnrc.nrdconta = pr_nrdconta
         AND crapnrc.insitrat = 2;
    rw_tbrisco_operacoes cr_tbrisco_operacoes%ROWTYPE;

    --------------> VARIAVEIS <-----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_des_reto VARCHAR2(10);
    vr_exc_erro EXCEPTION;
    vr_tab_erro gene0001.typ_tab_erro;
    vr_idx      PLS_INTEGER;

    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(200);
    vr_nrdrowid ROWID;
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;
    vr_idxempr  VARCHAR2(200);
    vr_dstextab_digitaliza craptab.dstextab%TYPE;
    vr_dstextab_parempctl  craptab.dstextab%TYPE;
    vr_dstextab            craptab.dstextab%TYPE;

    vr_inusatab BOOLEAN;
    vr_fcrapris BOOLEAN;
    vr_fcrapnrc BOOLEAN; -- P450 - Rating Efetivo
    vr_ftbrisco_operacoes BOOLEAN;
    vr_flginadi INTEGER := 0;
    vr_flglbace INTEGER := 0;
    vr_flgjucta INTEGER := 0;
    vr_flgeprat INTEGER := 0;
    vr_flgpreju INTEGER := 0;
    vr_flgocorr INTEGER := 0;
    vr_flggrupo INTEGER := 0;

    vr_nrdgrupo crapgrp.nrdgrupo%TYPE;
    vr_gergrupo VARCHAR2(200);
    vr_dsdrisgp crapgrp.dsdrisgp%TYPE;

    vr_qtctrord INTEGER := 0;
    vr_qtdevolu INTEGER := 0;
    vr_qtregist INTEGER := 0;

    vr_nivrisco VARCHAR2(20);
    vr_dtdrisco DATE;
    vr_qtdiaris INTEGER := 0;

    vr_dtrefere DATE;
    vr_innivris  NUMBER;
    vr_vlarrasto NUMBER;

    vr_habrat VARCHAR2(1) := 'N'; -- P450 SPT13 - Paramentro para Habilitar Novo Ratin (S/N)

    TYPE typ_tab_dsdrisco  IS TABLE OF VARCHAR2(2) INDEX BY PLS_INTEGER;
    vr_tab_dsdrisco     typ_tab_dsdrisco;

  BEGIN
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Listar ocorrencias.';

    -- P450 SPT13 - verifica parametro
    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');
    -- P450 SPT13 - verifica parametro

    -- Buscar dados do cooperado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;


    IF rw_crapass.inadimpl = 0 THEN
      vr_flginadi := 0; --FALSE
    ELSE
      vr_flginadi := 1; --TRUE
    END IF;

    IF rw_crapass.inlbacen = 0  THEN
      vr_flglbace := 0; --FALSE
    ELSE
      vr_flglbace := 1; --TRUE
    END IF;

    IF rw_crapass.cdsitdtl IN (5,6,7,8) THEN
      vr_flgjucta := 1; --TRUE
    ELSE
      vr_flgjucta := 0;--FALSE
    END IF;

    vr_qtctrord := 0;
    vr_qtdevolu := 0;

    -- Buscar saldo
    OPEN cr_crapsld (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => rw_crapass.nrdconta);
    FETCH cr_crapsld INTO rw_crapsld;
    -- caso não localizar
    IF cr_crapsld%NOTFOUND THEN
      vr_cdcritic := 10; --> Associado sem registro de saldo
      vr_dscritic := NULL;
      CLOSE cr_crapsld;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapsld;

    -- Buscar qtd de contra-ordem
    OPEN cr_crapcor_qtd (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => rw_crapass.nrdconta);
    FETCH cr_crapcor_qtd INTO vr_qtctrord;
    CLOSE cr_crapcor_qtd;

    --> buscar qtd de controle dos saldos negativos e devolucoes de cheques.
    OPEN cr_crapneg_qtd (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => rw_crapass.nrdconta);
    FETCH cr_crapneg_qtd INTO vr_qtdevolu;
    CLOSE cr_crapneg_qtd;

    IF rw_crapass.inlbacen = 0 THEN
      vr_flglbace := 0; --False
    ELSE
      vr_flglbace := 1; --TRUE
    END IF;

    vr_flgeprat := 0; --FALSE

    -- busca o tipo de documento GED
    vr_dstextab_digitaliza := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                        ,pr_nmsistem => 'CRED'
                                                        ,pr_tptabela => 'GENERI'
                                                        ,pr_cdempres => 00
                                                        ,pr_cdacesso => 'DIGITALIZA'
                                                        ,pr_tpregist => 5);

    -- Leitura do indicador de uso da tabela de taxa de juros
    vr_dstextab_parempctl := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'USUARI'
                                                       ,pr_cdempres => 11
                                                       ,pr_cdacesso => 'PAREMPCTL'
                                                       ,pr_tpregist => 01);


    --Buscar Indicador Uso tabela
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'TAXATABELA'
                                            ,pr_tpregist => 0);
    --Se nao encontrou
    IF vr_dstextab IS NULL THEN
      --Nao usa tabela
      vr_inusatab:= FALSE;
    ELSE
      IF  SUBSTR(vr_dstextab,1,1) = '0' THEN
        --Nao usa tabela
        vr_inusatab:= FALSE;
      ELSE
        --Nao usa tabela
        vr_inusatab:= TRUE;
      END IF;
    END IF;

    /* Procedure para obter dados de emprestimos do associado */
    empr0001.pc_obtem_dados_empresti
                           (pr_cdcooper       => pr_cdcooper           --> Cooperativa conectada
                           ,pr_cdagenci       => pr_cdagenci           --> Código da agência
                           ,pr_nrdcaixa       => pr_nrdcaixa           --> Número do caixa
                           ,pr_cdoperad       => pr_cdoperad           --> Código do operador
                           ,pr_nmdatela       => pr_nmdatela           --> Nome datela conectada
                           ,pr_idorigem       => pr_idorigem           --> Indicador da origem da chamada
                           ,pr_nrdconta       => pr_nrdconta           --> Conta do associado
                           ,pr_idseqttl       => pr_idseqttl           --> Sequencia de titularidade da conta
                           ,pr_rw_crapdat     => pr_rw_crapdat         --> Vetor com dados de parâmetro (CRAPDAT)
                           ,pr_dtcalcul       => NULL                  --> Data solicitada do calculo
                           ,pr_nrctremp       => 0                     --> Número contrato empréstimo
                           ,pr_cdprogra       => 'b1wgen0027'          --> Programa conectado
                           ,pr_inusatab       => vr_inusatab           --> Indicador de utilização da tabela
                           ,pr_flgerlog       => 'N'                   --> Gerar log S/N
                           ,pr_flgcondc       => FALSE                 --> Mostrar emprestimos liquidados sem prejuizo
                           ,pr_nmprimtl       => rw_crapass.nmprimtl   --> Nome Primeiro Titular
                           ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                           ,pr_tab_digitaliza => vr_dstextab_digitaliza--> Dados tabela parametro
                           ,pr_nriniseq       => 0                     --> Numero inicial da paginacao
                           ,pr_nrregist       => 0                     --> Numero de registros por pagina
                           ,pr_qtregist       => vr_qtregist           --> Qtde total de registros
                           ,pr_tab_dados_epr  => vr_tab_dados_epr      --> Saida com os dados do empréstimo
                           ,pr_des_reto       => vr_des_reto           --> Retorno OK / NOK
                           ,pr_tab_erro       => vr_tab_erro);         --> Tabela com possíves erros

    IF vr_des_reto = 'NOK' THEN
      IF vr_tab_erro.exists(vr_tab_erro.first) THEN

        vr_dscritic := 'Conta: '||pr_nrdconta||' nao possui emprestimo.: '||
                        -- concatenado a critica na versao oracle para tbm saber a causa de abortar o programa
                        vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        vr_dscritic := 'Conta: '||pr_nrdconta||' nao possui emprestimo.';
      END IF;
      RAISE vr_exc_erro;
    END IF;

    -- varrer temptable de emprestimos
    vr_idxempr := vr_tab_dados_epr.first;
    WHILE vr_idxempr IS NOT NULL LOOP
      IF(vr_tab_dados_epr(vr_idxempr).tpemprst = 0   AND
         vr_tab_dados_epr(vr_idxempr).vlpreapg > 0)  OR

        (vr_tab_dados_epr(vr_idxempr).tpemprst IN (1,2)  AND
         vr_tab_dados_epr(vr_idxempr).flgatras = 1)      AND

         vr_tab_dados_epr(vr_idxempr).inprejuz = 0 THEN
        -- se encontrou ao menos um, marca como atrasado e sai do loop
        vr_flgeprat := 1;--TRUE
        EXIT;
      END IF;

      vr_idxempr := vr_tab_dados_epr.next(vr_idxempr);
    END LOOP;

    --Carregar tabela de memoria de nivel de risco
    FOR rw_craptab IN cr_craptab (pr_cdcooper => pr_cdcooper
                                 ,pr_nmsistem => 'CRED'
                                 ,pr_tptabela => 'GENERI'
                                 ,pr_cdempres => 00
                                 ,pr_cdacesso => 'PROVISAOCL') LOOP
      --Atribuir descricao do risco para a tabela de memoria
      vr_tab_dsdrisco(rw_craptab.contador):= rw_craptab.dsdrisco;
    END LOOP;

    --> Alimentar variavel para nao ser preciso criar registro na PROVISAOCL
    vr_tab_dsdrisco(10) := 'H';

    vr_nivrisco := NULL;
    vr_dtdrisco := NULL;
    vr_qtdiaris := 0;

    --Buscar Indicador Uso tabela
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'RISCOBACEN'
                                            ,pr_tpregist => 000);
    --Se nao encontrou
    IF vr_dstextab IS NULL THEN
      vr_dscritic := 'NOT AVAIL craptab;CRED;USUARI;11;RISCOBACEN';
      RAISE vr_exc_erro;
    END IF;

    vr_dtrefere    := pr_rw_crapdat.dtultdma;
    vr_innivris    := 2;
    vr_vlarrasto := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,3,9));

    -- buscar risco
    OPEN cr_crapris (pr_cdcooper  => pr_cdcooper,
                     pr_nrdconta  => pr_nrdconta,
                     pr_dtrefere  => vr_dtrefere,
                     pr_vlarrasto => vr_vlarrasto);
    FETCH cr_crapris INTO rw_crapris;
    vr_fcrapris := cr_crapris%FOUND;
    CLOSE cr_crapris;

    IF vr_fcrapris THEN
      vr_innivris := rw_crapris.innivris;
    ELSE -- caso nao localizar

      -- buscar risco sem valor
      OPEN cr_crapris (pr_cdcooper  => pr_cdcooper,
                       pr_nrdconta  => pr_nrdconta,
                       pr_dtrefere  => vr_dtrefere,
                       pr_vlarrasto => 0);
      FETCH cr_crapris INTO rw_crapris;
      vr_fcrapris := cr_crapris%FOUND;
      CLOSE cr_crapris;

      /* Quando possuir operacao em Prejuizo, o risco da central sera H */
      IF vr_fcrapris AND
         rw_crapris.innivris = 10 THEN
        vr_innivris := rw_crapris.innivris;
      END IF;

    END IF;

    -- se localizou risco
    IF vr_fcrapris THEN
      vr_nivrisco := vr_tab_dsdrisco(vr_innivris);
      vr_dtdrisco := rw_crapris.dtdrisco;
      vr_qtdiaris := pr_rw_crapdat.dtmvtolt - rw_crapris.dtdrisco;

      IF vr_nivrisco = 'AA' THEN
        vr_nivrisco := NULL; /* Contratos Antigos */
      END IF;
    ELSE
      vr_nivrisco := vr_tab_dsdrisco(vr_innivris);
    END IF;

    vr_flgpreju := 0; --FALSE

    -- verificar se existe algum emprestimo em prejuizo
    OPEN cr_crapepr (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapepr INTO vr_flgpreju; -- true
    CLOSE cr_crapepr;

    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper = 3 OR vr_habrat = 'N') THEN
      --> Buscar Rating efetivo
      OPEN cr_crapnrc (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapnrc INTO rw_crapnrc;
      vr_fcrapnrc := cr_crapnrc%FOUND;
      CLOSE cr_crapnrc;

      IF vr_qtctrord      > 0   OR
         vr_qtdevolu      > 0   OR
         rw_crapass.dtdsdspc IS NOT NULL   OR
         rw_crapsld.qtddsdev  > 0   OR
         rw_crapsld.qtddtdev  > 0   OR
         vr_flginadi = 1            OR
         vr_flglbace = 1            OR
         vr_flgeprat = 1            OR
         vr_flgpreju = 1            OR

         (vr_fcrapnrc          AND
          rw_crapnrc.indrisco IS NOT NULL AND
          rw_crapnrc.indrisco <> 'A')  OR

         (trim(vr_nivrisco)     IS NOT NULL    AND
          vr_nivrisco     <> 'A')  THEN
        vr_flgocorr := 1; --TRUE
      ELSE
        vr_flgocorr := 0; --FALSE
      END IF;
    ELSE
      --> Buscar Rating efetivo
      OPEN cr_tbrisco_operacoes (pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta);
      FETCH cr_tbrisco_operacoes INTO rw_tbrisco_operacoes;
      vr_ftbrisco_operacoes := cr_tbrisco_operacoes%FOUND;
      CLOSE cr_tbrisco_operacoes;

      IF vr_qtctrord      > 0   OR
         vr_qtdevolu      > 0   OR
         rw_crapass.dtdsdspc IS NOT NULL   OR
         rw_crapsld.qtddsdev  > 0   OR
         rw_crapsld.qtddtdev  > 0   OR
         vr_flginadi = 1            OR
         vr_flglbace = 1            OR
         vr_flgeprat = 1            OR
         vr_flgpreju = 1            OR

         (vr_ftbrisco_operacoes AND
          rw_tbrisco_operacoes.indrisco IS NOT NULL AND
          rw_tbrisco_operacoes.indrisco <> 'A')  OR

         (trim(vr_nivrisco)     IS NOT NULL    AND
          vr_nivrisco     <> 'A')  THEN
        vr_flgocorr := 1; --TRUE
      ELSE
        vr_flgocorr := 0; --FALSE
      END IF;
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

    -- buscar grupo economico do cooperado
    GECO0001.pc_busca_grupo_associado
                        (pr_cdcooper => pr_cdcooper   --> Codigo da cooperativa
                        ,pr_nrdconta => pr_nrdconta   --> Numero da conta
                        ------ OUT ------
                        ,pr_flggrupo  => vr_flggrupo   --> Retorna se conta pertence a um grupo
                        ,pr_nrdgrupo  => vr_nrdgrupo   --> retorna numero do grupo
                        ,pr_gergrupo  => vr_gergrupo   --> Retorna grupo economico
                        ,pr_dsdrisgp  => vr_dsdrisgp); --> retona descrição do grupo

    vr_idx := pr_tab_ocorren.count + 1;
    pr_tab_ocorren(vr_idx).qtctrord := vr_qtctrord;
    pr_tab_ocorren(vr_idx).qtdevolu := vr_qtdevolu;
    pr_tab_ocorren(vr_idx).dtcnsspc := rw_crapass.dtcnsspc;
    pr_tab_ocorren(vr_idx).dtdsdsps := rw_crapass.dtdsdspc;
    pr_tab_ocorren(vr_idx).qtddsdev := rw_crapsld.qtddsdev;
    pr_tab_ocorren(vr_idx).dtdsdclq := rw_crapsld.dtdsdclq;
    pr_tab_ocorren(vr_idx).qtddtdev := rw_crapsld.qtddtdev;
    pr_tab_ocorren(vr_idx).flginadi := vr_flginadi;
    pr_tab_ocorren(vr_idx).flglbace := vr_flglbace;
    pr_tab_ocorren(vr_idx).flgeprat := vr_flgeprat;
    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper = 3 OR vr_habrat = 'N') THEN
      IF vr_fcrapnrc THEN
        pr_tab_ocorren(vr_idx).indrisco := rw_crapnrc.indrisco;
      END IF;
    ELSE
      IF vr_ftbrisco_operacoes THEN
        pr_tab_ocorren(vr_idx).indrisco := rw_tbrisco_operacoes.indrisco;
      END IF;
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo
    pr_tab_ocorren(vr_idx).nivrisco := vr_nivrisco;
    pr_tab_ocorren(vr_idx).flgpreju := vr_flgpreju;
    pr_tab_ocorren(vr_idx).flgjucta := vr_flgjucta;
    pr_tab_ocorren(vr_idx).flgocorr := vr_flgocorr;
    pr_tab_ocorren(vr_idx).dtdrisco := vr_dtdrisco;
    pr_tab_ocorren(vr_idx).qtdiaris := vr_qtdiaris;
    IF rw_crapass.inrisctl = 'AA' THEN
      pr_tab_ocorren(vr_idx).inrisctl := 'A';
    ELSE
      pr_tab_ocorren(vr_idx).inrisctl := rw_crapass.inrisctl;
    END IF;
    pr_tab_ocorren(vr_idx).dtrisctl := rw_crapass.dtrisctl;
    pr_tab_ocorren(vr_idx).dsdrisgp := vr_dsdrisgp;
    pr_tab_ocorren(vr_idx).innivris := vr_innivris;

    -- Se foi solicitado log
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => vr_dsorigem --> Origem enviada
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;

    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro CADA0004.pc_lista_ocorren:'||SQLERRM;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';
  END pc_lista_ocorren;

  /******************************************************************************/
  /**    Procedure para listar ocorrencias do cooperado - Chamada PROGRESS     **/
  /******************************************************************************/
  PROCEDURE pc_lista_ocorren_prog( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                  ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                  ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                  ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                  ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                                  ------ OUT ------
                                  ,pr_xml_ocorren  OUT CLOB              --> retorna temptable com os dados dos convenios
                                  ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                                  ,pr_cdcritic     OUT INTEGER) IS       --> Codigo da critica

  /* ..........................................................................
    --
    --  Programa : pc_lista_ocorren_prog        Antiga: b1wgen0027.p/lista_ocorren
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Abril/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para listar ocorrencias do cooperado - Chamada progress
    --
    --  Alteração :
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    --------------> VARIAVEIS <-----------------
    vr_cdcritic     INTEGER;
    vr_dscritic     VARCHAR2(1000);
    vr_des_reto     VARCHAR2(10);
    vr_exc_erro     EXCEPTION;
    vr_tab_erro     gene0001.typ_tab_erro;

    vr_tab_ocorren  typ_tab_ocorren;
    vr_dstexto      VARCHAR2(32767);
    vr_string       VARCHAR2(32767);
    vr_index        PLS_INTEGER;

  BEGIN

    -- DATA DA COOPERATIVA
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    IF btch0001.cr_crapdat%NOTFOUND THEN

      -- FECHAR CR_CRAPDAT CURSOR POIS HAVERÁ RAISE
      CLOSE btch0001.cr_crapdat;

      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      RAISE vr_exc_erro;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE btch0001.cr_crapdat;
    END IF;

    pc_lista_ocorren(  pr_cdcooper   => pr_cdcooper  --> Codigo da cooperativa
                      ,pr_cdagenci   => pr_cdagenci  --> Codigo de agencia
                      ,pr_nrdcaixa   => pr_nrdcaixa  --> Numero do caixa
                      ,pr_cdoperad   => pr_cdoperad  --> Codigo do operador
                      ,pr_nrdconta   => pr_nrdconta  --> Numero da conta
                      ,pr_rw_crapdat => rw_crapdat   --> Data da cooperativa
                      ,pr_idorigem   => pr_idorigem  --> Identificado de oriem
                      ,pr_idseqttl   => pr_idseqttl  --> sequencial do titular
                      ,pr_nmdatela   => pr_nmdatela  --> Nome da tela
                      ,pr_flgerlog   => pr_flgerlog  --> identificador se deve gerar log S-Sim e N-Nao
                      ------ OUT ------
                      ,pr_tab_ocorren  => vr_tab_ocorren  --> retorna temptable com os dados dos convenios
                      ,pr_des_reto     => vr_des_reto     --> OK ou NOK
                      ,pr_tab_erro     => vr_tab_erro);

    IF vr_des_reto = 'NOK' THEN
      IF vr_tab_erro.exists(vr_tab_erro.first)  THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        vr_dscritic := 'Não foi possivel listar ocorrencias';
      END IF;
      RAISE vr_exc_erro;
    END IF;

    --Montar CLOB
    IF vr_tab_ocorren.COUNT > 0 THEN

      -- Criar documento XML
      dbms_lob.createtemporary(pr_xml_ocorren, TRUE);
      dbms_lob.open(pr_xml_ocorren, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_xml_ocorren
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '<root>');

      --Buscar Primeiro beneficiario
      vr_index := vr_tab_ocorren.FIRST;

      --Percorrer todos os beneficiarios
      WHILE vr_index IS NOT NULL LOOP
        vr_string := '<ocorren>'||
                         '<qtctrord>'|| vr_tab_ocorren(vr_index).qtctrord  ||'</qtctrord>'||
                         '<qtdevolu>'|| vr_tab_ocorren(vr_index).qtdevolu  ||'</qtdevolu>'||
                         '<dtcnsspc>'|| to_char(vr_tab_ocorren(vr_index).dtcnsspc,'DD/MM/RRRR')  ||'</dtcnsspc>'||
                         '<dtdsdsps>'|| to_char(vr_tab_ocorren(vr_index).dtdsdsps,'DD/MM/RRRR')  ||'</dtdsdsps>'||
                         '<qtddsdev>'|| vr_tab_ocorren(vr_index).qtddsdev  ||'</qtddsdev>'||
                         '<dtdsdclq>'|| to_char(vr_tab_ocorren(vr_index).dtdsdclq,'DD/MM/RRRR')  ||'</dtdsdclq>'||
                         '<qtddtdev>'|| vr_tab_ocorren(vr_index).qtddtdev  ||'</qtddtdev>'||
                         '<flginadi>'|| vr_tab_ocorren(vr_index).flginadi  ||'</flginadi>'||
                         '<flglbace>'|| vr_tab_ocorren(vr_index).flglbace  ||'</flglbace>'||
                         '<flgeprat>'|| vr_tab_ocorren(vr_index).flgeprat  ||'</flgeprat>'||
                         '<indrisco>'|| vr_tab_ocorren(vr_index).indrisco  ||'</indrisco>'||
                         '<nivrisco>'|| vr_tab_ocorren(vr_index).nivrisco  ||'</nivrisco>'||
                         '<flgpreju>'|| vr_tab_ocorren(vr_index).flgpreju  ||'</flgpreju>'||
                         '<flgjucta>'|| vr_tab_ocorren(vr_index).flgjucta  ||'</flgjucta>'||
                         '<flgocorr>'|| vr_tab_ocorren(vr_index).flgocorr  ||'</flgocorr>'||
                         '<dtdrisco>'|| to_char(vr_tab_ocorren(vr_index).dtdrisco,'DD/MM/RRRR')  ||'</dtdrisco>'||
                         '<qtdiaris>'|| vr_tab_ocorren(vr_index).qtdiaris  ||'</qtdiaris>'||
                         '<inrisctl>'|| vr_tab_ocorren(vr_index).inrisctl  ||'</inrisctl>'||
                         '<dtrisctl>'|| to_char(vr_tab_ocorren(vr_index).dtrisctl,'DD/MM/RRRR')  ||'</dtrisctl>'||
                         '<dsdrisgp>'|| vr_tab_ocorren(vr_index).dsdrisgp  ||'</dsdrisgp>'||
                         '<innivris>'|| vr_tab_ocorren(vr_index).innivris  ||'</innivris>'||
                     '</ocorren>';

        -- Escrever no XML
        gene0002.pc_escreve_xml(pr_xml            => pr_xml_ocorren
                               ,pr_texto_completo => vr_dstexto
                               ,pr_texto_novo     => vr_string
                               ,pr_fecha_xml      => FALSE);

        vr_index := vr_tab_ocorren.next(vr_index);
      END LOOP;

      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_xml_ocorren
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '</root>'
                             ,pr_fecha_xml      => TRUE);

    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro CADA0004.pc_lista_ocorren:'||SQLERRM;

  END pc_lista_ocorren_prog;

  /******************************************************************************/
  /**             Funcao para obter saldo da conta investimento                **/
  /******************************************************************************/
  FUNCTION fn_saldo_invetimento( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da cooperativa

                                )RETURN NUMBER IS --> Retorna saldo de investimento

  /* ..........................................................................
    --
    --  Programa : fn_saldo_invetimento        Antiga: b1wgen0020.p/obtem-saldo-investimento
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembto/2015.                   Ultima atualizacao: 16/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Funcao para obter saldo da conta investimento
    --
    --  Alteração : 16/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/

    ---------------  > cursores <----------------
    --> Buscar Saldos da conta investimento
    CURSOR cr_crapsli IS
      SELECT crapsli.vlsddisp
        FROM crapsli
       WHERE crapsli.cdcooper = pr_cdcooper
         AND crapsli.nrdconta = pr_nrdconta
         AND to_char(crapsli.dtrefere,'MM/RRRR') = to_char(pr_dtmvtolt,'MM/RRRR');
    rw_crapsli cr_crapsli%ROWTYPE;

    ---------------> Variaveis <-----------------
  BEGIN

    --> Buscar Saldos da conta investimento
    OPEN cr_crapsli;
    FETCH cr_crapsli INTO rw_crapsli;
    CLOSE cr_crapsli;

    -- caso não encontrar valor retorna 0
    RETURN nvl(rw_crapsli.vlsddisp,0);

  END fn_saldo_invetimento;

  /******************************************************************************/
  /**             Funcao para obter valor do limite de credito                 **/
  /******************************************************************************/
  FUNCTION fn_valor_limite_credito(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                  ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                  ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                  ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                  ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da cooperativa
                                  ,pr_des_reto OUT VARCHAR2             --> OK ou NOK
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro
                                  )RETURN NUMBER IS --> Retorna saldo de investimento

  /* ..........................................................................

      Programa : fn_valor_limite_credito        Antiga: b1wgen0019.p/obtem-valor-limite
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Setembto/2015.                   Ultima atualizacao: 14/03/2016

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Funcao para obter valor do limite de credito

      Alteração : 16/09/2015 - Conversão Progress -> Oracle (Odirlei)

                  14/03/2016 - Adicionado return na função ao ocorrer erro. SD 417330 (Kelvin).

     ..........................................................................*/

    ---------------> cursores <----------------
    --> Buscar dados associado
    CURSOR cr_crapass IS
      SELECT crapass.cdagenci,
             crapass.inpessoa,
             crapass.vllimcre
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --------------> Variaveis <----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(200);
    vr_nrdrowid ROWID;


  BEGIN
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Obter valor do limite de credito';

    -- Buscar dados do cooperado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;

    -- Se foi solicitado log
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => vr_dsorigem --> Origem enviada
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => pr_dtmvtolt
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;
    pr_des_reto := 'OK';

    RETURN rw_crapass.vllimcre;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';

      --Retorna 0 caso ocorra algum erro
      RETURN 0;

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro CADA0004.fn_valor_limite_credito:'||SQLERRM;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';

     --Retorna 0 caso ocorra erro
      RETURN 0;
  END fn_valor_limite_credito;

  /******************************************************************************/
  /**             Efetua a busca dos dados do associado                        **/
  /******************************************************************************/
  PROCEDURE pc_busca_dados_associado ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                      ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                      ,pr_nrseqdig IN INTEGER                --> sequencial do titular
                                      ,pr_cddopcao IN VARCHAR2               --> opcao de busca
                                      ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data da cooperativa
                                      ---------- OUT --------
                                      ,pr_tab_infoass OUT typ_tab_infoass    --> Temptable com dados associados
                                      ,pr_tab_crapobs OUT typ_tab_crapobs    --> observacoes dos associados
                                      ,pr_des_reto    OUT VARCHAR2           --> OK ou NOK
                                      ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS

  /* ..........................................................................
    --
    --  Programa : pc_busca_dados_associado        Antiga: b1wgen0085.p/Busca_Dados
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembto/2015.                   Ultima atualizacao: 03/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Efetua a busca dos dados do associado
    --
    --  Alteração : 16/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --              14/11/2017 - Auste para considerar lancamentos de devolucao de capital (Jonata - RKAM P364).
    --
    --              03/12/2017 - Alterado cursor para ler da tbcotas (Jonata - RKAM P364).
    -- ..........................................................................*/

    ---------------> cursores <----------------
    --> Buscar dados associado
    CURSOR cr_crapass IS
      SELECT crapass.cdagenci,
             crapass.inpessoa,
             crapass.vllimcre,
             crapass.cdcooper,
             crapass.nrdconta,
             crapass.nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_tbcotas_devolucao(pr_tpdevolucao tbcotas_devolucao.tpdevolucao%TYPE) IS
    select tbcotas.dtinicio_credito
          ,(tbcotas.vlcapital - tbcotas.vlpago) vldisponivel
    from TBCOTAS_DEVOLUCAO tbcotas
    where tbcotas.cdcooper = pr_cdcooper
      and tbcotas.nrdconta = pr_nrdconta
      and tbcotas.tpdevolucao = pr_tpdevolucao
      and tbcotas.dtinicio_credito is null
      and tbcotas.vlpago = 0;
    rw_tbcotas_devolucao cr_tbcotas_devolucao%ROWTYPE;

    --> buscar observacoes geraris do cooperado
    CURSOR cr_crapobs IS
      SELECT /*+index_asc (crapobs CRAPOBS##CRAPOBS1) */
             crapope.nmoperad,
             crapobs.nrdconta,
             crapobs.dtmvtolt,
             crapobs.nrseqdig,
             crapobs.cdoperad,
             crapobs.hrtransa,
             crapobs.flgprior,
             crapobs.dsobserv,
             crapobs.dslogobs,
             crapobs.cdcooper,
             crapobs.progress_recid
        FROM crapobs
            ,crapope
       WHERE crapobs.cdcooper = pr_cdcooper
         AND crapobs.nrdconta = pr_nrdconta
         AND ( pr_nrseqdig = 0 OR crapobs.nrseqdig = pr_nrseqdig)
         AND crapope.cdcooper = pr_cdcooper
         AND crapope.cdcooper = crapobs.cdcooper
         AND upper(crapope.cdoperad) = upper(crapobs.cdoperad);

    --------------> Variaveis <----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(200);
    vr_nrdrowid ROWID;

    vr_idxass   PLS_INTEGER;
    vr_idxobs   PLS_INTEGER;
  BEGIN
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Obter valor do limite de credito';

    --> Validar o digito da conta
    IF NOT gene0005.fn_valida_digito_verificador(pr_nrdconta) THEN
      vr_cdcritic := 8;
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;


    -- Buscar dados do cooperado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      vr_dscritic := NULL;
      CLOSE cr_crapass;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;

    vr_idxass := pr_tab_infoass.count + 1;
    pr_tab_infoass(vr_idxass).cdcooper := rw_crapass.cdcooper;
    pr_tab_infoass(vr_idxass).nrdconta := rw_crapass.nrdconta;
    pr_tab_infoass(vr_idxass).nmprimtl := rw_crapass.nmprimtl;

    --> buscar observacoes
    FOR rw_crapobs IN cr_crapobs LOOP
      vr_idxobs := pr_tab_crapobs.count;

      pr_tab_crapobs(vr_idxobs).nrdconta := rw_crapobs.nrdconta;
      pr_tab_crapobs(vr_idxobs).dtmvtolt := rw_crapobs.dtmvtolt;
      pr_tab_crapobs(vr_idxobs).nrseqdig := rw_crapobs.nrseqdig;
      pr_tab_crapobs(vr_idxobs).cdoperad := rw_crapobs.cdoperad;
      pr_tab_crapobs(vr_idxobs).hrtransa := rw_crapobs.hrtransa;
      pr_tab_crapobs(vr_idxobs).flgprior := rw_crapobs.flgprior;
      pr_tab_crapobs(vr_idxobs).dsobserv := rw_crapobs.dsobserv;
      pr_tab_crapobs(vr_idxobs).dslogobs := rw_crapobs.dslogobs;
      pr_tab_crapobs(vr_idxobs).cdcooper := rw_crapobs.cdcooper;

      pr_tab_crapobs(vr_idxobs).recidobs := rw_crapobs.progress_recid;
      pr_tab_crapobs(vr_idxobs).hrtransc := to_char(to_date(rw_crapobs.hrtransa,'SSSSS'),'HH24:MI:SS');
      pr_tab_crapobs(vr_idxobs).nmoperad := rw_crapobs.nmoperad;

    END LOOP;

    --Selecionar Devolução de cotas capital
    OPEN cr_tbcotas_devolucao(pr_tpdevolucao => 3);

    FETCH cr_tbcotas_devolucao INTO rw_tbcotas_devolucao;

    --Se cooperado ainda não sacou valor de cotas decorrente a demissão
    IF cr_tbcotas_devolucao%FOUND THEN

      vr_idxobs := pr_tab_crapobs.count;

      pr_tab_crapobs(vr_idxobs).nrdconta := pr_nrdconta;
      pr_tab_crapobs(vr_idxobs).dtmvtolt := rw_tbcotas_devolucao.dtinicio_credito;
      pr_tab_crapobs(vr_idxobs).dsobserv := 'Pendente devolucao de capital: R$ ' || to_char(rw_tbcotas_devolucao.vldisponivel,'fm999g999g990d00');

    END IF;

    --Fechar Cursor
    CLOSE cr_tbcotas_devolucao;

    --Selecionar Devolução de saldo
    OPEN cr_tbcotas_devolucao(pr_tpdevolucao => 4);

    FETCH cr_tbcotas_devolucao INTO rw_tbcotas_devolucao;

    --Se cooperado ainda não sacou valor de cotas decorrente a demissão
    IF cr_tbcotas_devolucao%FOUND THEN

      vr_idxobs := pr_tab_crapobs.count;

      pr_tab_crapobs(vr_idxobs).nrdconta := pr_nrdconta;
      pr_tab_crapobs(vr_idxobs).dtmvtolt := rw_tbcotas_devolucao.dtinicio_credito;
      pr_tab_crapobs(vr_idxobs).dsobserv := 'Pendente devolucao de depósito: R$ ' || to_char(rw_tbcotas_devolucao.vldisponivel,'fm999g999g990d00');

    END IF;

    --Fechar Cursor
    CLOSE cr_tbcotas_devolucao;

    -- Se foi solicitado log
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => vr_dsorigem --> Origem enviada
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => pr_dtmvtolt
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro CADA0004.pc_busca_dados_associado:'||SQLERRM;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';
  END pc_busca_dados_associado;

  /******************************************************************************/
  /**        Funcao para validar retrição de acesso do operador                **/
  /******************************************************************************/
  FUNCTION fn_valida_restricao_ope( pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                   ,pr_nrdctitg IN crapass.nrdctitg%TYPE  --> Numero da conta
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                  )RETURN VARCHAR2 IS --> Retorna critica

  /* ..........................................................................
    --
    --  Programa : fn_valida_restricao_ope        Antiga: b1wgen9998.p/valida_restricao_operador
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembto/2015.                   Ultima atualizacao: 16/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Funcao para validar retrição de acesso do operador
    --
    --  Alteração : 16/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/

    ---------------> cursores <----------------
    --> Buscar dados associado
    CURSOR cr_crapass IS
      SELECT crapass.cdagenci,
             crapass.inpessoa,
             crapass.vllimcre,
             crapass.cdcooper,
             crapass.nrdconta,
             crapass.nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.flgrestr = 1 --TRUE
         AND ((pr_nrdconta <> 0 AND crapass.nrdconta = pr_nrdconta) OR
              (TRIM(pr_nrdctitg) IS NOT NULL AND upper(crapass.nrdctitg)= upper(pr_nrdctitg))
              );
    rw_crapass cr_crapass%ROWTYPE;

    --> buscar dados operador
    CURSOR cr_crapope IS
      SELECT 1
        FROM crapope
       WHERE crapope.cdcooper = pr_cdcooper
         AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad)
         AND crapope.flgperac = 1; --TRUE
    rw_crapope cr_crapope%ROWTYPE;

    vr_fcrapass BOOLEAN;

  BEGIN
    --> Buscar dados associado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    vr_fcrapass := cr_crapass%FOUND;
    CLOSE cr_crapass;

    IF vr_fcrapass THEN
      -- verificar operador
      OPEN cr_crapope;
      FETCH cr_crapope INTO rw_crapope;

      IF cr_crapope%NOTFOUND THEN
        CLOSE cr_crapope;
        RETURN 'Acesso Restrito: Consulte seu Gerente/Coordenador.';
      ELSE
        CLOSE cr_crapope;
      END IF;
    END IF;

    RETURN NULL;

  END fn_valida_restricao_ope;

  /******************************************************************************/
  /**             Buscar informacoes complementares para tela Atenda           **/
  /******************************************************************************/
  PROCEDURE pc_completa_cab_atenda ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                    ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                    ,pr_nrdctitg IN crapass.nrdctitg%TYPE  --> Conta itg
                                    ,pr_dtinicio IN DATE                   --> Data inicio periodo
                                    ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                    ---------- OUT --------
                                    ,pr_tab_comp_cabec OUT typ_tab_comp_cabec    --> observacoes dos associados
                                    ,pr_des_reto       OUT VARCHAR2              --> OK ou NOK
                                    ,pr_tab_erro       OUT gene0001.typ_tab_erro) IS

  /* ..........................................................................
    --
    --  Programa : pc_completa_cab_atenda        Antiga: b1wgen0001.p/completa-cabecalho
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembto/2015.                   Ultima atualizacao: 16/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar informacoes complementares para tela Atenda
    --
    --  Alteração : 16/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/

    ---------------> cursores <----------------
    --> Buscar dados associado
    CURSOR cr_crapass IS
      SELECT crapass.cdagenci,
             crapass.inpessoa,
             crapass.vllimcre,
             crapass.cdcooper,
             crapass.nrdconta,
             crapass.nmprimtl,
             crapass.vledvmto,
             crapass.dtedvmto,
             crapass.nrcpfcgc
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND ((pr_nrdconta <> 0 AND crapass.nrdconta = pr_nrdconta) OR
              (TRIM(pr_nrdctitg) IS NOT NULL AND upper(crapass.nrdctitg) = upper(pr_nrdctitg))
              );
    rw_crapass cr_crapass%ROWTYPE;

    -- busca qtd de negativado
    CURSOR cr_crapneg IS
      SELECT /*+index (crapneg crapneg##crapneg2)*/
       COUNT(*)
        FROM crapneg
       WHERE crapneg.cdcooper = pr_cdcooper
         AND crapneg.nrdconta = pr_nrdconta
         AND crapneg.cdhisest = 1
         AND crapneg.cdobserv IN (11, 12, 13);

    -- Busca saldo
    CURSOR cr_crapsld IS
      SELECT crapsld.qtddtdev,
             crapsld.qtddsdev
        FROM crapsld
       WHERE crapsld.cdcooper = pr_cdcooper
         AND crapsld.nrdconta = pr_nrdconta;
    rw_crapsld cr_crapsld%ROWTYPE;

    CURSOR cr_crappla IS
      SELECT /*+index_asc crappla crappla##crappla3*/
             crappla.vlprepla
        FROM crappla
       WHERE crappla.cdcooper = pr_cdcooper
         AND crappla.nrdconta = pr_nrdconta
         AND crappla.tpdplano = 1
         AND crappla.cdsitpla = 1;

    -- Buscar qtd de folhas de cheque
    CURSOR cr_crapfdc IS
    SELECT COUNT(*)
      FROM crapfdc
     WHERE crapfdc.cdcooper = pr_cdcooper
       AND crapfdc.nrdconta = pr_nrdconta
       AND crapfdc.dtemschq IS NOT NULL
       AND crapfdc.dtretchq >= trunc(pr_dtinicio,'MONTH')
       AND crapfdc.tpcheque = 1;

    -- Buscar Data de abertura da conta mais antiga
    CURSOR cr_crapsfn IS
      SELECT crapsfn.dtabtcct
        FROM crapsfn
       WHERE crapsfn.cdcooper = pr_cdcooper
         AND crapsfn.nrcpfcgc = rw_crapass.nrcpfcgc
         AND crapsfn.tpregist = 1
       ORDER BY crapsfn.dtabtcct;

    ---------------------------------------------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_fcrapass BOOLEAN;

    vr_qtdevolu INTEGER := 0;
    vr_qtddtdev crapsld.qtddtdev%TYPE;
    vr_qtddsdev crapsld.qtddsdev%TYPE;
    vr_vlprepla crappla.vlprepla%TYPE;
    vr_dtabtcct DATE;
    vr_idx      PLS_INTEGER;
    vr_qtfolret INTEGER;
    vr_ftsalari VARCHAR2(100);


  BEGIN

    --> Buscar dados associado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    vr_fcrapass := cr_crapass%FOUND;
    CLOSE cr_crapass;

    IF vr_fcrapass = FALSE THEN
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;

    /* Devolucoes */
    vr_qtdevolu := 0;
    OPEN cr_crapneg;
    FETCH cr_crapneg INTO vr_qtdevolu;
    CLOSE cr_crapneg;
    vr_qtdevolu := nvl(vr_qtdevolu,0) ;

    /* CL/Estouro */
    OPEN cr_crapsld;
    FETCH cr_crapsld INTO rw_crapsld;
    CLOSE cr_crapsld;

    vr_qtddtdev := nvl(rw_crapsld.qtddtdev,0);
    vr_qtddsdev := nvl(rw_crapsld.qtddsdev,0);

    /* Data SFN */
    IF  nvl(rw_crapass.vledvmto,0) <> 0 THEN
      vr_ftsalari := to_char(rw_crapass.vledvmto,'fm99990')||' '||
                     to_char(rw_crapass.dtedvmto,'MM/RR');
    ELSE
      vr_ftsalari := NULL;
    END IF;

    /* Plano */
    OPEN cr_crappla;
    FETCH cr_crappla INTO vr_vlprepla;
    CLOSE cr_crappla;
    vr_vlprepla := nvl(vr_vlprepla,0);

    /* Fls.Ret */
    OPEN cr_crapfdc;
    FETCH cr_crapfdc INTO vr_qtfolret;
    CLOSE cr_crapfdc;

    /* Data de abertura da conta mais antiga */
    OPEN cr_crapsfn;
    FETCH cr_crapsfn INTO vr_dtabtcct;
    CLOSE cr_crapsfn;

    vr_idx := pr_tab_comp_cabec.count + 1;

    pr_tab_comp_cabec(vr_idx).qtdevolu := vr_qtdevolu;
    pr_tab_comp_cabec(vr_idx).qtddsdev := vr_qtddsdev;
    pr_tab_comp_cabec(vr_idx).qtddtdev := vr_qtddtdev;
    pr_tab_comp_cabec(vr_idx).dtsisfin := vr_dtabtcct;
    pr_tab_comp_cabec(vr_idx).ftsalari := vr_ftsalari;
    pr_tab_comp_cabec(vr_idx).vlprepla := vr_vlprepla;
    pr_tab_comp_cabec(vr_idx).qttalret := vr_qtfolret;
    pr_tab_comp_cabec(vr_idx).flgdigit := 'S';

    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      pr_des_reto := 'NOK';

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro CADA0004.pc_completa_cab_atenda:'||SQLERRM;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);


      pr_des_reto := 'NOK';
  END pc_completa_cab_atenda;

  /*****************************************************************************/
  /**         Procedure para criar registro de uma mensagem de alerta         **/
  /*****************************************************************************/
  PROCEDURE pc_cria_registro_msg(pr_dsmensag IN VARCHAR2,
                                 pr_tab_mensagens_atenda IN OUT typ_tab_mensagens_atenda) IS

    vr_nrsequen PLS_INTEGER;
  BEGIN

      vr_nrsequen := pr_tab_mensagens_atenda.count + 1;
      pr_tab_mensagens_atenda(vr_nrsequen).nrsequen := vr_nrsequen;
      pr_tab_mensagens_atenda(vr_nrsequen).dsmensag := pr_dsmensag;

  END pc_cria_registro_msg;

  /******************************************************************************/
  /**            Realiza a validacao das contas na viacredi altovale           **/
  /******************************************************************************/
  PROCEDURE pc_ret_criticas_altovale(pr_cdcooper IN     crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_nrcpfcgc IN     crapass.nrcpfcgc%TYPE  --> CPF/CNPJ do cooperado
                                    ,pr_dtmvtolt IN     crapdat.dtmvtolt%TYPE  --> Data do movimento
                                    ,pr_sqalerta IN OUT INTEGER                --> sequencial do alerta
                                    ,pr_tab_alertas OUT typ_tab_alertas        --> Temptable de Altertas
                                    ) IS

  /* ..........................................................................
    --
    --  Programa : pc_ret_criticas_altovale        Antiga: b1wgen0031.p/Criticas_AltoVale
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembto/2015.                   Ultima atualizacao: 18/09/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Realiza a validacao das contas na viacredi altovale
    --
    --  Alteração : 18/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/

    ---------------> cursores <----------------
    /* Verifica se existe alguma conta deste CPF/CNPJ na Viacredi*/
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrcpfcgc  crapass.nrcpfcgc%TYPE)IS
      SELECT crapass.cdcooper,
             crapass.nrdconta,
             crapass.dtdemiss
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrcpfcgc = pr_nrcpfcgc;

    --> buscar emprestimos em prejuizo
    CURSOR cr_crapepr (pr_cdcooper crapepr.cdcooper%TYPE,
                       pr_nrdconta crapepr.nrdconta%TYPE) IS
      SELECT DISTINCT
             (CASE WHEN crapepr.vlsdprej > 0 THEN 1 --> em prejuizo
                   ELSE 2
              END     ) idprejuz--> Já causou prejuizo
        FROM crapepr
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.nrdconta = pr_nrdconta
         AND crapepr.inprejuz = 1;

    --> Verificar se é uma conta migrada
    CURSOR cr_craptco (pr_cdcooper crapepr.cdcooper%TYPE,
                       pr_nrdconta crapepr.nrdconta%TYPE)  IS
      SELECT craptco.nrdconta
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcooper
         AND craptco.nrctaant = pr_nrdconta
         AND craptco.tpctatrf <> 3;
    rw_craptco cr_craptco%ROWTYPE;


    -----------------> VARIAVEIS <--------------------
    vr_cdcoptmp     INTEGER        := 0;
    vr_nmcoptmp     VARCHAR2(4000) := NULL;
    vr_dtdemiss     DATE;
    vr_dscripre     VARCHAR2(4000) := NULL;
    vr_dscriliq     VARCHAR2(4000) := NULL;
    vr_dsalerta     VARCHAR2(4000) := NULL;

  BEGIN


    IF pr_cdcooper = 1 THEN
      vr_cdcoptmp := 2;
      vr_nmcoptmp := 'Acredicoop';
    ELSE
      vr_cdcoptmp := 1;
      vr_nmcoptmp := 'Viacredi';
    END IF;

    /* Obter a data atual menos 02 anos */
    vr_dtdemiss := add_months(pr_dtmvtolt,-24);

    vr_dscripre := 'Cooperado com prejuizo na '|| vr_nmcoptmp ||'.';
    vr_dscriliq := 'Cooperado ja causou prejuizo na '|| vr_nmcoptmp ||' - Liquidado.';

    --> Verifica se existe alguma conta deste CPF/CNPJ na Viacredi
    FOR rw_crapass IN cr_crapass (pr_cdcooper => vr_cdcoptmp,
                                  pr_nrcpfcgc => pr_nrcpfcgc) LOOP

      --> buscar emprestimos em prejuizo
      FOR rw_crapepr IN  cr_crapepr (pr_cdcooper => rw_crapass.cdcooper,
                                     pr_nrdconta => rw_crapass.nrdconta) LOOP

        -- Verificar tipo
        IF rw_crapepr.idprejuz = 1 THEN
          vr_dsalerta := vr_dscripre;
        ELSE
          vr_dsalerta := vr_dscriliq;
        END IF;

        -- se ja esta na tabela, busca proximo
        IF pr_tab_alertas.exists(vr_dsalerta) THEN
          continue;
        ELSE
          pr_tab_alertas(vr_dsalerta).cdalerta := pr_sqalerta;
          pr_tab_alertas(vr_dsalerta).dsalerta := vr_dsalerta;
          pr_sqalerta                          := pr_sqalerta + 1;
        END IF;

        -- sair do loop
        EXIT;
      END LOOP;

      -- se foi demitido/encerrado cta em menos de 2 anos
      IF rw_crapass.dtdemiss IS NOT NULL   AND
         rw_crapass.dtdemiss > vr_dtdemiss THEN

         -- verificar se é uma conta migrada
         OPEN cr_craptco(pr_cdcooper => rw_crapass.cdcooper,
                         pr_nrdconta => rw_crapass.nrdconta);
         FETCH cr_craptco INTO rw_craptco;
         -- e nao for uma conta migrada
         IF cr_craptco%NOTFOUND THEN
           vr_dsalerta := 'Cooperado com conta demitida na '|| vr_nmcoptmp ||'.';

           -- se ja esta na tabela, busca proximo
          IF pr_tab_alertas.exists(vr_dsalerta) THEN
            continue;
          ELSE
            pr_tab_alertas(vr_dsalerta).cdalerta := pr_sqalerta;
            pr_tab_alertas(vr_dsalerta).dsalerta := vr_dsalerta;
            pr_sqalerta                          := pr_sqalerta + 1;
          END IF;
         END IF;
         CLOSE cr_craptco;

      END IF;
    END LOOP;

    --> Se existe ja as duas criticas de prejuizo,
    -- deixar somente a de nao liquidado
    IF pr_tab_alertas.exists(vr_dscripre) THEN
      pr_tab_alertas.delete(vr_dscriliq);
    END IF;

  END pc_ret_criticas_altovale;

  /******************************************************************************/
  /**     Funcao para buscar a ultima data de alteracao de cadastro      **/
  /******************************************************************************/
  FUNCTION fn_ult_dtaltera(pr_cdcooper IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                           pr_nrdconta IN crapass.nrdconta%TYPE,  --> Numero da conta
                           pr_tpaltera IN crapalt.tpaltera%TYPE ) --> Tipo de alteracao, nulo para todos
                           RETURN DATE IS

    --> Buscar alterações
    CURSOR cr_crapalt IS
      SELECT /*+index_desc (crapalt CRAPALT##CRAPALT1)*/
             crapalt.dtaltera
        FROM crapalt
       WHERE crapalt.cdcooper = pr_cdcooper
         AND crapalt.nrdconta = pr_nrdconta
         AND crapalt.tpaltera = nvl(pr_tpaltera,crapalt.tpaltera);
    rw_crapalt cr_crapalt%ROWTYPE;

  BEGIN
    --> Procura data de alteracao
    rw_crapalt := NULL;
    OPEN cr_crapalt;
    FETCH cr_crapalt INTO rw_crapalt;
    CLOSE cr_crapalt;

    RETURN rw_crapalt.dtaltera;


  END fn_ult_dtaltera;

  /******************************************************************************/
  /**         Funcao para buscar a natureza de operacao do cooperado           **/
  /******************************************************************************/
  FUNCTION fn_dsnatopc(pr_cdcooper IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                       pr_nrdconta IN crapass.nrdconta%TYPE,  --> Numero da conta
                       pr_inpessoa IN crapass.inpessoa%TYPE ) --> Tipo de pessoa 1- fisico 2-juridico
                       RETURN VARCHAR2 IS
    /* ..........................................................................
    --
    --  Programa : fn_dsnatopc        Antiga: b1wgen0001a.p
    --                                        b1wgen0001b.p
    --                                        b1wgen0001.p\fgetnatopc
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Outubro/2015.                   Ultima atualizacao: 22/10/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Funcao para buscar a natureza de operacao do cooperado
    --
    --  Alteração : 22/10/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/
    ---------------> CURSOR <-----------------
    -- Para pessoa fisica
    CURSOR cr_gncdnto(pr_cdnatopc gncdnto.cdnatocp%TYPE) IS
      SELECT gncdnto.rsnatocp
        FROM gncdnto
       WHERE gncdnto.cdnatocp = pr_cdnatopc;

    -- Para pessoa juridica
    CURSOR cr_gncdntj(pr_cdnatjur gncdntj.cdnatjur%TYPE) IS
      SELECT gncdntj.rsnatjur
        FROM gncdntj
       WHERE gncdntj.cdnatjur = pr_cdnatjur;

    --Buscar dados do titular
    CURSOR cr_crapttl (pr_cdcooper IN crapjur.cdcooper%type
                      ,pr_nrdconta IN crapjur.nrdconta%type) IS
      SELECT crapttl.cdnatopc
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = 1;
    rw_crapttl cr_crapttl%ROWTYPE;

    --Selecionar dados pessoa juridica
    CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%type
                      ,pr_nrdconta IN crapjur.nrdconta%type) IS
      SELECT crapjur.natjurid
      FROM crapjur
      WHERE crapjur.cdcooper = pr_cdcooper
      AND   crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;


    vr_dsnatopc VARCHAR2(100) := NULL;

  BEGIN

    IF pr_inpessoa = 1 THEN
      --Selecionar Dados Pessoa fisica
      OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapttl INTO rw_crapttl;
      --Se nao Encontrou
      IF cr_crapttl%FOUND THEN
        OPEN cr_gncdnto(pr_cdnatopc => rw_crapttl.cdnatopc);
        FETCH cr_gncdnto INTO vr_dsnatopc;
        IF cr_gncdnto%NOTFOUND THEN
           vr_dsnatopc := 'NAO CADASTRADO';
        END IF;
        CLOSE cr_gncdnto;
      END IF;
      CLOSE cr_crapttl;

    ELSE

      --Selecionar Dados Pessoa Juridica
      OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapjur INTO rw_crapjur;
      --Se nao Encontrou
      IF cr_crapjur%FOUND THEN
        --Selecionar Cadastro Tipos de natureja juridica
        OPEN cr_gncdntj (pr_cdnatjur => rw_crapjur.natjurid);
        FETCH cr_gncdntj INTO vr_dsnatopc;
        IF cr_gncdntj%NOTFOUND THEN
           vr_dsnatopc := 'NAO CADASTRADO';
        END IF;
        CLOSE cr_gncdntj;
      END IF;
      CLOSE cr_crapjur;

    END IF;

    RETURN vr_dsnatopc;

  END fn_dsnatopc;

  /******************************************************************************/
  /**              Funcao para buscar telefone cooperado                       **/
  /******************************************************************************/
  FUNCTION fn_nrramfon(pr_cdcooper IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                       pr_nrdconta IN crapass.nrdconta%TYPE,  --> Numero da conta
                       pr_inpessoa IN crapass.inpessoa%TYPE ) --> Tipo de pessoa 1- fisico 2-juridico
                       RETURN VARCHAR2 IS

    /* ..........................................................................
    --
    --  Programa : fn_nrramfon        Antiga: b1wgen0001.p\fgetnrramfon
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Outubro/2015.                   Ultima atualizacao: 22/10/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Funcao para buscar a natureza de operacao do cooperado
    --
    --  Alteração : 22/10/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --
    -- ..........................................................................*/

    --------------> CURSOR <---------------
    CURSOR cr_craptfc IS
      SELECT craptfc.nrtelefo,craptfc.nrdddtfc
        FROM craptfc
       WHERE craptfc.cdcooper = pr_cdcooper
         AND craptfc.nrdconta = pr_nrdconta
         ORDER BY craptfc.idseqttl,
                  -- Alternar ordenacao conforme tipo de pessoa
                  -- Se pessoa fisica :  Residencial/Celular/Comercial/Contato(1,2,3,4)
                  -- Se pessoa juridica: Comercial/Celular/Residencial/Contato(3,2,1,4)
                  decode(pr_inpessoa,2,decode(craptfc.tptelefo,3,-1,2,0,craptfc.tptelefo)
                                      ,craptfc.tptelefo),
                  craptfc.cdseqtfc ;
    rw_craptfc cr_craptfc%ROWTYPE;
    vr_nrtelefo VARCHAR2(100) := NULL;
  BEGIN
    --> Buscar numero de telefone
    OPEN cr_craptfc;
    FETCH cr_craptfc INTO rw_craptfc;

    IF cr_craptfc%FOUND THEN
      IF nvl(rw_craptfc.nrdddtfc,0) <> 0  THEN
        vr_nrtelefo := '('||rw_craptfc.nrdddtfc ||')';
      END IF;

      vr_nrtelefo := vr_nrtelefo || rw_craptfc.nrtelefo;
    END IF;
    CLOSE cr_craptfc;

    RETURN vr_nrtelefo;

  END fn_nrramfon;

  /******************************************************************************/
  /**       Funcao para buscar descrição do tipo de conta do cooperado         **/
  /******************************************************************************/
  FUNCTION fn_dstipcta(pr_inpessoa IN tbcc_tipo_conta.inpessoa%TYPE,  --> Tipo de pessoa
                       pr_cdtipcta IN tbcc_tipo_conta.cdtipo_conta%TYPE)  --> Tipo de conta
                       RETURN VARCHAR2 IS

    /* ..........................................................................
    --
    --  Programa : fn_dstipcta        Antiga: b1wgen0001.p\fgetdstipcta
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Outubro/2015.                   Ultima atualizacao: 22/10/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Funcao para buscar a natureza de operacao do cooperado
    --
    --  Alteração : 22/10/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --              20/02/2018 - Busca a descrição do tipo de conta da tabela
    --                           TBCC_TIPO_CONTA. PRJ366 (Lombardi).
    -- ..........................................................................*/

    --------------> CURSOR <---------------
    CURSOR cr_tipo_conta IS
      SELECT tpcta.dstipo_conta
        FROM tbcc_tipo_conta tpcta
       WHERE tpcta.inpessoa = pr_inpessoa
         AND tpcta.cdtipo_conta = pr_cdtipcta;
    rw_tipo_conta cr_tipo_conta%ROWTYPE;

     vr_dstipcta VARCHAR2(100) := NULL;
  BEGIN
    -- Buscar descrição do tipo de conta
    OPEN cr_tipo_conta;
    FETCH cr_tipo_conta INTO rw_tipo_conta;

    IF cr_tipo_conta%FOUND THEN
      CLOSE cr_tipo_conta;
      vr_dstipcta := pr_cdtipcta || ' - ' || rw_tipo_conta.dstipo_conta;
        RETURN vr_dstipcta;
    ELSE
      CLOSE cr_tipo_conta;
      RETURN pr_cdtipcta;
    END IF;

  END fn_dstipcta;

  /******************************************************************************/
  /**       Funcao para buscar descrição da situacao da conta do cooperado     **/
  /******************************************************************************/
  FUNCTION fn_dssitdct(pr_cdsitdct IN crapass.cdsitdct%TYPE)  --> Codigo da situacao da conta
                       RETURN VARCHAR2 IS

    /* ..........................................................................
    --
    --  Programa : fn_dssitdct        Antiga: b1wgen0001.p\fgetdssitdct
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Outubro/2015.                   Ultima atualizacao: 22/10/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Funcao para buscar descrição da situacao da conta do cooperado
    --
    --  Alteração : 22/10/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --              27/04/2018 - Buscar descricao da tabela de situacoes. PRJ366 (Lombardi)
    --
    -- ..........................................................................*/
  BEGIN
    DECLARE

      vr_dssituacao tbcc_situacao_conta.dssituacao%TYPE;
      vr_des_erro   VARCHAR2(10);
      vr_dscritic   crapcri.dscritic%TYPE;

    BEGIN
      CADA0006.pc_descricao_situacao_conta(pr_cdsituacao => pr_cdsitdct
                                          ,pr_dssituacao => vr_dssituacao
                                          ,pr_des_erro => vr_des_erro
                                          ,pr_dscritic => vr_dscritic);

    IF pr_cdsitdct > 0 AND
         vr_des_erro <> 'NOK' THEN
        RETURN pr_cdsitdct||' '|| vr_dssituacao;
    ELSE
      RETURN pr_cdsitdct||' ';
    END IF;

    END;
  END fn_dssitdct;

  --Buscar codigo da empresa da pessoa fisica ou juridica
  PROCEDURE pc_busca_cdempres_ass (pr_cdcooper IN crapcop.cdcooper%type,
                                   pr_inpessoa IN crapass.inpessoa%type,
                                   pr_nrdconta IN crapass.nrdconta%type,
                                   pr_cdempres IN OUT crapttl.cdempres%type,
                                   pr_cdturnos IN OUT crapttl.cdturnos%type,
                                   pr_dsnatura IN OUT crapttl.dsnatura%TYPE) IS

    /* ..........................................................................
    --
    --  Programa : pc_busca_cdempres_ass
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Outubro/2015.                   Ultima atualizacao: 19/10/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para buscar empresa e turno do cooperadp
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    -- Ler Cadastro de pessoas juridicas.
    CURSOR cr_crapjur is
      SELECT cdempres
        FROM crapjur
       WHERE crapjur.cdcooper = pr_cdcooper
         AND crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;

    -- Ler Cadastro de titulares da conta
    CURSOR cr_crapttl is
      SELECT cdempres,
             nrdconta,
             cdturnos,
             dsnatura
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = 1;
    rw_crapttl cr_crapttl%ROWTYPE;

  BEGIN

    -- Se for pessoa fisica
    IF pr_inpessoa = 1 THEN

      OPEN cr_crapttl;
      FETCH cr_crapttl INTO rw_crapttl;
      IF cr_crapttl%NOTFOUND THEN
        CLOSE cr_crapttl;
      ELSE
        CLOSE cr_crapttl;
        pr_cdempres := rw_crapttl.cdempres;
        pr_cdturnos := rw_crapttl.cdturnos;
        pr_dsnatura := rw_crapttl.dsnatura;
      END IF;

    ELSE
      -- Ler Cadastro de pessoas juridicas.
      OPEN cr_crapjur;
      FETCH cr_crapjur
        INTO rw_crapjur;
      IF cr_crapjur%NOTFOUND THEN
        CLOSE cr_crapjur;
      ELSE
        CLOSE cr_crapjur;
        pr_cdempres := rw_crapjur.cdempres;
      END IF;
    END IF;

  END pc_busca_cdempres_ass;


  /******************************************************************************/
  /**          Procedure obter mensagens de alerta para uma conta              **/
  /******************************************************************************/
  PROCEDURE pc_obtem_mensagens_alerta( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                      ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE    --> Data da cooperativa
                                      ---------- OUT --------
                                      ,pr_tab_mensagens_atenda OUT typ_tab_mensagens_atenda  --> Retorna as mensagens para tela atenda
                                      ,pr_des_reto       OUT VARCHAR2                  --> OK ou NOK
                                      ,pr_tab_erro       OUT gene0001.typ_tab_erro) IS

  /* ..........................................................................
    --
    --  Programa : pc_obtem_mensagens_alerta        Antiga: b1wgen0031.p/obtem-mensagens-alerta
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Outubro/2015.                   Ultima atualizacao: 09/04/2019
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure obter mensagens de alerta para uma conta
    --
    --  Alteração : 19/10/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --              09/11/2015 - Incluir mensagem de cartao rejeitado
    --                           Projeto 126 - DV4 (Odirlei-AMcom)
    --
    --              09/11/2015 - Merge versao progress, incluido alerta
    --                           de Boleto do contrato pagos sem processamento.
    --                           (Odirlei-AMcom)
    --
    --              10/11/2015 - Incluido verificacao para impressao de termo de
    --                           responsabilidade. (Jean Michel).
    --
    --              01/12/2015 - Alterar validacao de contratos em cobrança no
    --                           CYBER para verificar na cracyc ao inves da crapcyb
    --                           (Douglas)
    --
    --              01/08/2016 - Incluido mensagem do pre aprovado para cargas manuais.
    --                           Projeto 299/3 - Pre-Aprovado (Lombardi)
    --
    --              04/10/2016 - Validação de emprestimo em atraso da própria conta e como fiador.
    --                           Incluído uma cláusula "and" no lugar de utilizar 2 if's.
    --                           Dessa forma permite que as demais condições (else e elsif) sejam validadas
    --                           #487823 (AJFink)
    --
    --              22/09/2016 - Alterado para buscar a qtd de dias da renovacao do limite de cheque
    --                           da tabela craprli e nao mais da craptab.
    --                           PRJ-300 - Desconto de Cheque (Odirlei-AMcom)
    --
    --              29/09/2019 - Inclusao de verificacao de contratos de acordos de
    --                           empréstimos, Prj. 302 (Jean Michel).
    --
    --              30/01/2017 - Exibir mensagem quando Cooperado/Fiador atrasar emprestimo Pos-Fixado.
    --                           (Jaison/James - PRJ298)
    --
    --              03/03/2017 - Ajustado geração da mensagem de limite de desconto vencido.
    --                           PRJ-300 Desconto de Cheque (Daniel)
    --
    --              12/04/2017 - Exibir mensagem de fatura de cartão atrasado.
    --                           PRJ343 - Cessao de credito(Odirlei-AMcom)
    --
    --              23/06/2017 - Ajuste para inclusao do novo tipo de situacao da conta
    --                           "Desligamento por determinação do BACEN"
    --                           (Jonata - RKAM P364).
    --
    --              27/08/2017 - Inclusao de mensagens na tela Atenda. Melhoria 364 - Grupo Economico (Mauro)
    --
    --              09/10/2017 - Inclusao de mensagens na tela Atenda. Projeto 410 - RF 52  62
    --
    --              29/11/2017 - Chamado 784845 - Prova de vida não aparecendo na AV (Andrei-Mouts)
    --
    --              18/12/2017 - Inclusao da leitura do parametro para apresentar a mensagem de fatura
    --                           de cartao de credito em atraso (Anderson).
    --
    --              20/02/2018 - Alteracao da verificação de tipos de conta individuais, pela
    --                           verificação da categoria da conta. PRJ366 (Lombardi).
    --
    --              27/04/2018 - Buscar descricao da tabela de situacoes. PRJ366 (Lombardi)
    --
    --              23/05/2018 - Mensagem quando ocorre prejuízo em conta corrente e empréstimo
    --                           Diego Simas - AMcom
    --
    --              26/07/2018 - Melhoria na apresentacao de mensagem de atraso de pagamento de emprestimo.
    --                           Inserido regra para verificar se o acordo esta ativo. Caso esteja, pula
    --                           para proximo registro.
    --                           Chamado INC0016984 (Gabriel - Mouts).
    --
    --              27/08/2018 - Adicionado alerta para bordero em prejuizo. - Luis Fernando (GFT)
    --
    --              25/10/2018 - Adicionado alerta para títulos descontados em atraso. - Lucas (GFT)
    --
    --              25/12/2018 - PJ298.2 Adicionado mensagem para contratos migrados (Rafael Faria- Supero)
    --
    --              24/01/2019 - PJ298.2.2 - Ajustado mensagem de prejuizo de emprestimo (Rafael Faria - Supero)
    --
    --
    --              07/03/2019 - Correcao na mensagem de cadastro vencido (Cassia de Oliveira - GFT)
    --
    --              25/02/2019 - P442 - Envio da Taxa na mensagem do PreAprovado (Marcos-Envolti)
    --
    --              22/07/2019 - Alteração de mensagens de bloqueio judicial para contas monitoradas (RITM0022588 - Joao Mannes (Mouts))
    --              
    --              09/09/2019 - Ajuste na formatação de mensagens de bloqueio judicial para contas monitoradas (INC0024009 - Andre Bohn (Mouts))
    -- ..........................................................................*/

    ---------------> CURSORES <----------------
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT crapass.cdagenci,
             crapass.inpessoa,
             crapass.vllimcre,
             crapass.cdcooper,
             crapass.nrdconta,
             crapass.nmprimtl,
             crapass.cdsitdtl,
             crapass.nrcpfcgc,
             crapass.inlbacen,
             crapass.cdsitcpf,
             crapass.cdtipcta,
             crapass.dtdemiss,
             crapass.nrdctitg,
             crapass.flgctitg,
             crapass.idimprtr,
             crapass.idastcjt,
             crapass.cdsitdct,
             crapass.cdcatego,
             crapass.inprejuz,
             crapass.dtultalt
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    rw_bcrapass cr_crapass%ROWTYPE;

    --> Verificar conta transferida
    CURSOR cr_craptrf IS
      SELECT craptrf.nrsconta
        FROM craptrf
       WHERE craptrf.cdcooper = pr_cdcooper
         AND craptrf.nrdconta = pr_nrdconta
         AND craptrf.tptransa = 1
         AND craptrf.insittrs = 2;
    rw_craptrf cr_craptrf%ROWTYPE;

    --> Busca cadastro de avalistas terceiros
    CURSOR cr_crapavt IS
      SELECT crapavt.nrdctato,
             crapavt.nmdavali
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.tpctrato = 6
         AND crapavt.flgimpri = 1; --TRUE

    --> Busca cadastro de avalistas terceiros
    CURSOR cr_crapavt_2 IS
      SELECT crapavt.nrdctato,
             crapavt.nmdavali,
             crapavt.cdcooper
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.nrdctato <> 0
         AND crapavt.tpctrato = 5; -- contato

    --> Buscar titulares da conta
    CURSOR cr_crapttl IS
      SELECT crapttl.nmextttl
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.flgimpri = 1 --TRUE
         AND crapttl.idseqttl IN (1,2,3,4);

   --> Buscar cadastro do representante legal
    CURSOR cr_crapcrl IS
      SELECT crapcrl.nmrespon,
             crapcrl.nrdconta
        FROM crapcrl
       WHERE crapcrl.cdcooper = pr_cdcooper
         AND crapcrl.nrctamen = pr_nrdconta
         AND crapcrl.flgimpri = 1; --TRUE

    --> Contar titulares da conta
    CURSOR cr_crapttl_count IS
      SELECT COUNT(*)
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta;

    --> titulares da conta
    CURSOR cr_crapttl2 (pr_cdcooper crapttl.cdcooper%TYPE,
                        pr_nrdconta crapttl.nrdconta%TYPE,
                        pr_idseqttl crapttl.idseqttl%TYPE) IS
      SELECT crapttl.nmextttl
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = pr_idseqttl;
    rw_crapttl2 cr_crapttl2%ROWTYPE;

    --> Buscar entrega de cartao
    CURSOR cr_crapcrm IS
      SELECT /*--> + index_desc (crapcrm CRAPCRM##CRAPCRM3) alterado forma de busca*/
             MAX(crapcrm.dtemscar) dtemscar
        FROM crapcrm crapcrm
       WHERE crapcrm.cdcooper = pr_cdcooper
         AND crapcrm.nrdconta = pr_nrdconta
         AND crapcrm.tptitcar <> 9 --> Tipo Titular Cartao <> 9 (Operador)
         AND crapcrm.dtcancel IS NULL
         AND crapcrm.dtemscar IS NOT NULL
         AND crapcrm.dtentcrm IS NULL;
    rw_crapcrm cr_crapcrm%ROWTYPE;

    --> Buscar cartão do titular ativo
    CURSOR cr_crapcrm_2 (pr_cdcooper crapsnh.cdcooper%TYPE,
                       pr_nrdconta crapsnh.nrdconta%TYPE,
                       pr_idseqttl crapsnh.idseqttl%TYPE,
                       pr_dtmvtolt DATE)IS
      SELECT 1
        FROM crapcrm crapcrm
       WHERE crapcrm.cdcooper = pr_cdcooper
         AND crapcrm.nrdconta = pr_nrdconta
         AND crapcrm.tpusucar = pr_idseqttl
         AND crapcrm.cdsitcar = 2
         AND crapcrm.dtvalcar > pr_dtmvtolt
         AND rownum < 2;
    rw_crapcrm_2 cr_crapcrm_2%ROWTYPE;

    --> Verificar se cooperado possui cartao bancoob
    CURSOR cr_crapcrd_1 (pr_cdcooper crapcrd.cdcooper%TYPE,
                         pr_nrdconta crapcrd.nrdconta%TYPE,
                         pr_idseqttl crapttl.idseqttl%TYPE) IS
      SELECT 1
        FROM crapcrd
            ,crawcrd
            ,crapttl
       WHERE crapcrd.cdcooper = pr_cdcooper
         AND crapcrd.nrdconta = pr_nrdconta
         AND crapcrd.cdcooper = crapttl.cdcooper
         AND crapcrd.nrdconta = crapttl.nrdconta
         AND crapttl.idseqttl = pr_idseqttl
         AND crapcrd.nrcpftit = crapttl.nrcpfcgc
         AND crapcrd.cdadmcrd >= 10
         AND crapcrd.cdadmcrd <= 80
         AND crapcrd.inacetaa = 1
         AND crawcrd.cdcooper = crapcrd.cdcooper
         AND crawcrd.nrdconta = crapcrd.nrdconta
         AND crawcrd.nrctrcrd = crapcrd.nrctrcrd
         AND crawcrd.insitcrd IN(4,6);
    rw_crapcrd_1 cr_crapcrd_1%ROWTYPE;

    --> Verificar se cooperado possui cartao bancoob
    CURSOR cr_crapcrd_2 (pr_cdcooper crapcrd.cdcooper%TYPE,
                         pr_nrdconta crapcrd.nrdconta%TYPE) IS
      SELECT 1
        FROM crapcrd
            ,crawcrd
       WHERE crapcrd.cdcooper = pr_cdcooper
         AND crapcrd.nrdconta = pr_nrdconta
         AND crapcrd.cdadmcrd >= 10
         AND crapcrd.cdadmcrd <= 80
         AND crapcrd.inacetaa = 1
         AND crawcrd.cdcooper = crapcrd.cdcooper
         AND crawcrd.nrdconta = crapcrd.nrdconta
         AND crawcrd.nrctrcrd = crapcrd.nrctrcrd
         AND crawcrd.insitcrd IN(4,6);
    rw_crapcrd_2 cr_crapcrd_2%ROWTYPE;

    --> Buscar senhas dos cooperados
    CURSOR cr_crapsnh (pr_cdcooper crapsnh.cdcooper%TYPE,
                       pr_nrdconta crapsnh.nrdconta%TYPE,
                       pr_idseqttl crapsnh.idseqttl%TYPE)IS
      SELECT crapsnh.nrdconta
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.idseqttl = pr_idseqttl
         AND crapsnh.tpdsenha = 1
         AND crapsnh.cdsitsnh = 1;
    rw_crapsnh cr_crapsnh%ROWTYPE;

    --> Buscar Contratos de Limite de credito
    CURSOR cr_craplim (pr_cdcooper craplim.cdcooper%TYPE,
                       pr_nrdconta craplim.nrdconta%TYPE,
                       pr_tpctrlim craplim.tpctrlim%TYPE,
                       pr_insitlim craplim.insitlim%TYPE)IS
      SELECT /*+index_asc (craplim CRAPLIM##CRAPLIM1)*/
             craplim.dtfimvig
            ,craplim.dtinivig
            ,craplim.qtdiavig
        FROM craplim craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.tpctrlim = pr_tpctrlim
         AND craplim.insitlim = pr_insitlim;
    rw_craplim cr_craplim%ROWTYPE;

    --> Buscar Contratos de Limite de Desconto de Cheque e regras
    CURSOR cr_craprli (pr_cdcooper craplim.cdcooper%TYPE,
                       pr_nrdconta craplim.nrdconta%TYPE,
                       pr_tpctrlim craplim.tpctrlim%TYPE,
                       pr_insitlim craplim.insitlim%TYPE,
                       pr_inpessoa craprli.inpessoa%TYPE)IS
      SELECT /*+index_asc (craplim CRAPLIM##CRAPLIM1)*/
             lim.dtfimvig
            ,lim.dtinivig
            ,lim.qtdiavig
            ,rli.qtmaxren
        FROM craplim lim,
             craprli rli
       WHERE lim.cdcooper = rli.cdcooper
         AND lim.tpctrlim = rli.tplimite
         AND rli.inpessoa = pr_inpessoa
         AND lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.tpctrlim = pr_tpctrlim
         AND lim.insitlim = pr_insitlim;
    rw_craprli cr_craprli%ROWTYPE;

    --> Buscar emprestimos do cooperado prejuizo
    CURSOR cr_crapepr IS
      SELECT crapepr.vlsdprej
        FROM crapepr
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.nrdconta = pr_nrdconta
         AND crapepr.inprejuz = 1;
    rw_crapepr cr_crapepr%ROWTYPE;

    --> Buscar emprestimos do cooperado
    CURSOR cr_crapepr_2(pr_cdcooper crapepr.cdcooper%TYPE,
                        pr_nrdconta crapepr.nrdconta%TYPE,
                        pr_nrctremp crapepr.nrctremp%TYPE)IS
      SELECT crapepr.tpdescto,
             crapepr.dtdpagto
        FROM crapepr
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.nrdconta = pr_nrdconta
         AND crapepr.nrctremp = pr_nrctremp;
    rw_crapepr_2 cr_crapepr_2%ROWTYPE;

    /* PORTABILIDADE - verifica se o contrato liquidado foi portado para outra instituicao */
    CURSOR cr_portabilidade(pr_cdcooper crapepr.cdcooper%TYPE,
                            pr_nrdconta crapepr.nrdconta%TYPE,
                            pr_nrctremp crapepr.nrctremp%TYPE)IS
      SELECT portabilidade.nrctremp
        FROM tbepr_portabilidade portabilidade
            ,crapepr
       WHERE portabilidade.cdcooper = pr_cdcooper
         AND portabilidade.nrdconta = pr_nrdconta
         AND portabilidade.nrctremp = pr_nrctremp
         AND portabilidade.cdcooper = crapepr.cdcooper
         AND portabilidade.nrdconta = crapepr.nrdconta
         AND portabilidade.nrctremp = crapepr.nrctremp
         /*deve existir o contrato na crapepr e deve estar liquidado*/
         AND crapepr.inliquid = 1
         /*deve ser um contrato de portabilidade do tipo 2 (Venda)*/
         AND portabilidade.tpoperacao = 2;
    rw_portabilidade cr_portabilidade%ROWTYPE;

    --> Buscar emprestimos onde a conta é avalista
    CURSOR cr_crapavl (pr_cdcooper crapavl.cdcooper%TYPE,
                       pr_nrdconta crapavl.nrdconta%TYPE )IS
      SELECT crapepr.inprejuz,
             crapepr.vlsdprej,
             crapepr.inliquid,
             crapepr.tpdescto,
             crapepr.dtdpagto,
             crapavl.nrctaavd,
             crapavl.nrctravd
        FROM crapavl
            ,crapepr
       WHERE crapavl.cdcooper = pr_cdcooper
         AND crapavl.nrdconta = pr_nrdconta
         AND crapavl.tpctrato = 1
         AND crapepr.cdcooper = crapavl.cdcooper
         AND crapepr.nrdconta = crapavl.nrctaavd
         AND crapepr.nrctremp = crapavl.nrctravd
         ORDER BY crapavl.nrctaavd DESC,
                  crapavl.nrctravd;

    --> Valida Emprestimo BNDES
    CURSOR cr_crapprp IS
      SELECT /*+index_asc (crapprp CRAPPRP##CRAPPRP1)*/
             crapprp.cdcooper,
             crapprp.nrdconta,
             crapprp.nrctrato,
             crapprp.tpctrato
        FROM crapprp
       WHERE crapprp.cdcooper = pr_cdcooper
         AND crapprp.nrdconta = pr_nrdconta
         AND crapprp.tpctrato = 90
         AND crapprp.vlctrbnd > 0;

    --> Buscar Notas do rating por contrato
    CURSOR cr_crapnrc(pr_cdcooper crapnrc.cdcooper%TYPE,
                      pr_nrdconta crapnrc.nrdconta%TYPE,
                      pr_nrctrato crapnrc.nrctrrat%TYPE,
                      pr_tpctrato crapnrc.tpctrrat%TYPE)IS
      SELECT 1
        FROM crapnrc
       WHERE crapnrc.cdcooper = pr_cdcooper
         AND crapnrc.nrdconta = pr_nrdconta
         AND crapnrc.nrctrrat = pr_nrctrato
         AND crapnrc.tpctrrat = pr_tpctrato;
    rw_crapnrc cr_crapnrc%ROWTYPE;

    --> Buscar Cadastro de emprestimo BNDES -- Ativa, EM ATRASO ou Normal
    CURSOR cr_crapebn(pr_cdcooper crapnrc.cdcooper%TYPE,
                      pr_nrdconta crapnrc.nrdconta%TYPE,
                      pr_nrctrato crapnrc.nrctrrat%TYPE)IS
      SELECT crapebn.nrdconta,
             crapebn.insitctr
        FROM crapebn
       WHERE crapebn.cdcooper = pr_cdcooper
         AND crapebn.nrdconta = pr_nrdconta
         AND crapebn.nrctremp = pr_nrctrato
         AND crapebn.insitctr IN ('A', 'P', 'N');
    rw_crapebn cr_crapebn%ROWTYPE;

    --> Verifica se o endereco foi alterado pelo associado na internet
    CURSOR cr_crapenc IS
      SELECT crapenc.idseqttl
        FROM crapenc
       WHERE crapenc.cdcooper = pr_cdcooper
         AND crapenc.nrdconta = pr_nrdconta
         AND crapenc.tpendass = 12;

    --> Contas de transferencia do salario
    CURSOR cr_crapccs IS
      SELECT crapccs.nrcpfcgc
        FROM crapccs
       WHERE crapccs.cdcooper = pr_cdcooper
         AND crapccs.nrdconta = pr_nrdconta
         AND crapccs.cdsitcta = 1;
    rw_crapccs cr_crapccs%ROWTYPE;

    --> Buscar contas migradas
    CURSOR cr_craptco(pr_cdcooper craptco.cdcooper%TYPE,
                      pr_nrdconta craptco.nrdconta%TYPE ) IS
      SELECT craptco.cdcopant
        FROM craptco
       WHERE craptco.cdcooper = pr_cdcooper
         AND craptco.nrdconta = pr_nrdconta;
    rw_craptco cr_craptco%ROWTYPE;

    --> Buscar alterações
    CURSOR cr_crapalt IS
      SELECT /*+index_desc (crapalt CRAPALT##CRAPALT1)*/
             MAX(crapalt.dtaltera) AS dtaltera
        FROM crapalt
       WHERE crapalt.cdcooper = pr_cdcooper
         AND crapalt.nrdconta = pr_nrdconta
         AND crapalt.tpaltera = 1;
    rw_crapalt cr_crapalt%ROWTYPE;

    --> Buscar registro no cyber
    CURSOR cr_crapcyc IS
      SELECT /*+index_as (crapcyc CRAPCYC##CRAPCYC1)*/
             crapcyc.cdcooper
        FROM crapcyc crapcyc
       WHERE crapcyc.cdcooper = pr_cdcooper
         AND crapcyc.nrdconta = pr_nrdconta
         AND (crapcyc.flgjudic = 1 OR /*TRUE*/
              crapcyc.flextjud = 1 ); /*TRUE*/
    rw_crapcyc cr_crapcyc%ROWTYPE;

    --> Buscar log de alteracoes
    CURSOR cr_crapalt_1 IS
      SELECT crapalt.dsaltera
        FROM crapalt
       WHERE crapalt.cdcooper = pr_cdcooper
         AND crapalt.nrdconta = pr_nrdconta;

    --> Buscar cobrancas em aberto ou pago
    CURSOR cr_tbrecup_cobranca IS
      SELECT tbrecup_cobranca.cdcooper
            ,tbrecup_cobranca.nrdconta_cob
            ,tbrecup_cobranca.nrcnvcob
            ,tbrecup_cobranca.nrboleto
            ,tbrecup_cobranca.nrctremp
            ,tbrecup_cobranca.tpproduto
            ,crapcob.dtvencto
            ,crapcob.vltitulo
            ,crapcob.incobran
            ,crapcob.nrdconta
            ,crapcob.nrdocmto
            ,crapcob.dtdpagto
        FROM tbrecup_cobranca
            ,crapcob
       WHERE
         tbrecup_cobranca.cdcooper = pr_cdcooper
         AND tbrecup_cobranca.nrdconta = pr_nrdconta
         AND crapcob.cdcooper = tbrecup_cobranca.cdcooper
         AND crapcob.nrdconta = tbrecup_cobranca.nrdconta_cob
         AND crapcob.nrcnvcob = tbrecup_cobranca.nrcnvcob
         AND crapcob.nrdocmto = tbrecup_cobranca.nrboleto
         AND crapcob.incobran IN(0,5);

    -- Verificar se ret ainda nao foi processado
    CURSOR cr_crapret (pr_cdcooper  crapret.cdcooper%TYPE,
                       pr_nrdconta  crapret.nrdconta%TYPE,
                       pr_nrcnvcob  crapret.nrcnvcob%TYPE,
                       pr_nrdocmto  crapret.nrdocmto%TYPE,
                       pr_dtdpagto  crapret.dtocorre%TYPE)IS
      SELECT 1
        FROM crapret
       WHERE crapret.cdcooper = pr_cdcooper
         AND crapret.nrdconta = pr_nrdconta
         AND crapret.nrcnvcob = pr_nrcnvcob
         AND crapret.nrdocmto = pr_nrdocmto
         AND crapret.cdocorre = 6
         AND crapret.dtocorre = pr_dtdpagto
         AND crapret.flcredit = 0;
    rw_crapret cr_crapret%ROWTYPE;

    --> Buscar propostas de cartao rejeitadas
    CURSOR cr_crawcrd IS
      SELECT crawcrd.nrcrcard
        FROM crawcrd
       WHERE crawcrd.cdcooper = pr_cdcooper
         AND crawcrd.nrdconta = pr_nrdconta
         AND crawcrd.dtrejeit IS NOT NULL
         AND rownum = 1;
    rw_crawcrd cr_crawcrd%ROWTYPE;

    --> Busca registros de senhas
    CURSOR cr_crapsnh_2(pr_cdcooper crapsnh.cdcooper%TYPE,
                        pr_nrdconta crapsnh.nrdconta%TYPE,
                        pr_tpdsenha crapsnh.tpdsenha%TYPE,
                        pr_nrcpfcgc crapsnh.nrcpfcgc%TYPE) IS

      SELECT snh.cdcooper
            ,snh.nrdconta
        FROM crapsnh snh
       WHERE snh.cdcooper = pr_cdcooper
         AND snh.nrdconta = pr_nrdconta
         AND snh.tpdsenha = pr_tpdsenha
         AND snh.nrcpfcgc = pr_nrcpfcgc;

    rw_crapsnh_2 cr_crapsnh_2%ROWTYPE;

    -- Cursor para buscar os bloqueios judiciais
    CURSOR cr_crapblj IS
      SELECT DISTINCT a.nrproces,
             a.dsjuizem
        FROM crapblj a
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtblqfim IS NULL
       ORDER BY 1,2;

    --> Buscar alerta de atraso do cartao
    CURSOR cr_crdatraso (pr_cdcooper crapsnh.cdcooper%TYPE,
                         pr_nrdconta crapsnh.nrdconta%TYPE )IS
      SELECT *
        FROM (SELECT atr.qtdias_atraso,
                     atr.vlsaldo_devedor
                FROM tbcrd_alerta_atraso atr
               WHERE atr.cdcooper = pr_cdcooper
                 AND atr.nrdconta = pr_nrdconta
                 ORDER BY atr.qtdias_atraso DESC, atr.vlsaldo_devedor DESC)
       WHERE rownum <= 1;

    --> Buscar alerta para impressão da declaração de optante do simples nacional
    CURSOR cr_impdecsn(pr_cdcooper crapsnh.cdcooper%TYPE
                      ,pr_nrdconta crapsnh.nrdconta%TYPE) IS
        SELECT idimpdsn, tpregtrb
        FROM crapjur
        WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta;
    rw_cr_impdecsn cr_impdecsn%ROWTYPE;

    --> Busca contratos de bordero em prejuizo
    CURSOR cr_crapbdt_preju(pr_cdcooper crapbdt.cdcooper%TYPE
                            ,pr_nrdconta crapbdt.nrdconta%TYPE) IS
      SELECT
        bdt.inprejuz, -- possui prejuizo
        bdt.dtliqprj  -- prejuizo liquidado
      FROM
        crapbdt bdt
      WHERE
        bdt.nrdconta = pr_nrdconta
        AND bdt.cdcooper = pr_cdcooper
        AND bdt.inprejuz = 1
      ;
    rw_crapbdt_preju cr_crapbdt_preju%ROWTYPE;

    CURSOR cr_tbepr_migracao_empr (pr_cdcooper IN tbepr_migracao_empr.cdcooper%TYPE
                                  ,pr_nrdconta IN tbepr_migracao_empr.nrdconta%TYPE
                                  ,pr_nrctremp IN tbepr_migracao_empr.nrctremp%TYPE) IS
      SELECT e.nrctrnov
        FROM tbepr_migracao_empr e
       WHERE e.cdcooper = pr_cdcooper
         AND e.nrdconta = pr_nrdconta
         AND e.nrctremp = pr_nrctremp;
    rw_tbepr_migracao_empr cr_tbepr_migracao_empr%rowtype;

 --> Consultar se já houve prejuizo nessa conta
    CURSOR cr_prejuizo(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                       pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
      SELECT t.nrdconta
        FROM tbcc_prejuizo t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta;
    rw_prejuizo cr_prejuizo%ROWTYPE;


  -- Busca existência de títulos em atraso
    CURSOR cr_craptdb_atrasados(pr_cdcooper crapbdt.cdcooper%TYPE
                               ,pr_nrdconta crapbdt.nrdconta%TYPE
                               ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                               ,pr_dtmvtoan crapdat.dtmvtoan%TYPE) IS
          SELECT 1
            FROM crapbdt bdt
      INNER JOIN craptdb tdb ON tdb.cdcooper = bdt.cdcooper AND tdb.nrdconta = bdt.nrdconta AND tdb.nrborder = bdt.nrborder
           WHERE bdt.cdcooper = pr_cdcooper
             AND bdt.nrdconta = pr_nrdconta
             AND bdt.flverbor = 1             -- borderôs do novo produto
             AND tdb.dtlibbdt IS NOT NULL     -- borderôs que foram liberados em algum momento
             AND tdb.insittit = 4             -- borderôs em aberto
             AND tdb.dtvencto <  pr_dtmvtolt  -- borderôs vencidos
             AND tdb.dtvencto <= pr_dtmvtoan; -- desconsidera borderôs com títulos que venceram em dias não úteis e que podem ser pagos na data atual
      rw_craptdb_atrasados cr_craptdb_atrasados%ROWTYPE;
    
    
    --Busca os processos de contas monitoradas 
    CURSOR cr_processos_monitorados(pr_cdcooper crapbdt.cdcooper%TYPE
											     	   	   ,pr_nrdconta crapbdt.nrdconta%TYPE) IS
      SELECT DISTINCT b.dsprocesso, b.nmjuiz, a.vlsaldo
        FROM TBBLQJ_MONITORA_ORDEM_BLOQ a
       INNER JOIN TBBLQJ_ORDEM_BLOQ_DESBLOQ b on (b.idordem = a.idordem)
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta;
    rw_processos_monitorados cr_processos_monitorados%rowtype;

    --------------> VARIAVEIS <----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;
    vr_exc_next EXCEPTION;
    vr_des_reto VARCHAR2(100);
    vr_tab_erro gene0001.typ_tab_erro;


    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(200);
    vr_nrdrowid ROWID;

    vr_dstextab     craptab.dstextab%TYPE;
    vr_flg_digitlib VARCHAR2(10);
    vr_qttitula     INTEGER;
    vr_flgcadas     INTEGER;
    vr_dsmensag     VARCHAR2(4000);
    vr_flgpreju     BOOLEAN;
    vr_flgpreju_ativo BOOLEAN;
    vr_flgpreju_bdt BOOLEAN;
    vr_flgpreju_bdt_liq BOOLEAN;
    vr_dsprejuz     VARCHAR2(1000);
    vr_sralerta     INTEGER;
    vr_tab_alertas  typ_tab_alertas;
    vr_idxalert     VARCHAR(200);
    vr_idxepr       VARCHAR(100);
    vr_idxcpa       PLS_INTEGER;
    vr_dstextab_digitaliza craptab.dstextab%TYPE;
    vr_dstextab_parempctl  craptab.dstextab%TYPE;
    vr_epr_portabilidade   VARCHAR2(1000);
    vr_tbepr_migracao_empr VARCHAR2(1000);
    vr_tab_dados_epr       empr0001.typ_tab_dados_epr;
    vr_tab_dados_cpa       empr0002.typ_tab_dados_cpa;
    vr_tab_mensagens       TELA_CONTAS_GRUPO_ECONOMICO.typ_tab_mensagens;
    vr_inusatab     BOOLEAN;
    vr_flgexist     BOOLEAN;
    vr_qtregist     INTEGER;
    vr_vltotprv     NUMBER;
    vr_qtempatr     INTEGER;
    vr_tpbloque     INTEGER;

    vr_flbndand     BOOLEAN;
    vr_flbndatr     BOOLEAN;
    vr_flbndprj     BOOLEAN;
    vr_flbndnor     BOOLEAN;
    vr_fcraptco     BOOLEAN;
    vr_dsvigpro     VARCHAR2(2000);
    vr_vlblqjud     NUMBER := 0;
    vr_vlresblq     NUMBER := 0;
    vr_flgpvida     INTEGER;
    vr_exibe_migrado BOOLEAN := FALSE;

    vr_nrdconta_grp tbcc_grupo_economico.nrdconta%TYPE;
    vr_dsvinculo    VARCHAR(2000);

    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
    vr_tab_bens CADA0001.typ_tab_bens;          --Tabela bens

    vr_flgativo INTEGER := 0;
    vr_qtdiaatr INTEGER := 0;

    vr_dssituacao tbcc_situacao_conta.dssituacao%TYPE;

    vr_id_conta_monitorada    NUMBER(1);

    vr_processos_monitorados varchar(2000);

  BEGIN

    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Obter mensagens de alerta para tela ATENDA.';

    -- Buscar dados do cooperado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      vr_dscritic := NULL;
      CLOSE cr_crapass;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;

    -- Gerar aviso para impressão do termo de responsabilidade
    IF rw_crapass.idimprtr = 1 THEN
      pc_cria_registro_msg(pr_dsmensag => 'Imprimir Termo de Responsabilidade para acesso ao Autoatendimento e SAC.'
                          ,pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;

    CADA0006.pc_descricao_situacao_conta(pr_cdsituacao => 7
                                        ,pr_dssituacao => vr_dssituacao
                                        ,pr_des_erro => vr_des_reto
                                        ,pr_dscritic => vr_dscritic);

    IF vr_des_reto = 'NOK' THEN
      RAISE vr_exc_erro;
    END IF;

    --Em processo de Demissão
    IF rw_crapass.cdsitdct = 7 THEN
      pc_cria_registro_msg(pr_dsmensag             => vr_dssituacao,
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

    END IF;

    CADA0006.pc_descricao_situacao_conta(pr_cdsituacao => 8
                                        ,pr_dssituacao => vr_dssituacao
                                        ,pr_des_erro => vr_des_reto
                                        ,pr_dscritic => vr_dscritic);

    IF vr_des_reto = 'NOK' THEN
      RAISE vr_exc_erro;
    END IF;

    -- Demissão BACEN
    IF rw_crapass.cdsitdct = 8 THEN
      pc_cria_registro_msg(pr_dsmensag             => vr_dssituacao,
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

    END IF;

    --> Transferencia e Duplicacao de Matricula
    OPEN cr_craptrf;
    FETCH cr_craptrf INTO rw_craptrf;

    IF cr_craptrf%FOUND THEN
      pc_cria_registro_msg(pr_dsmensag             => 'Conta transferida para '||
                                                       TRIM(gene0002.fn_mask_conta(rw_craptrf.nrsconta))||'.' ,
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;
    CLOSE cr_craptrf;

    --> Tabela com a taxa do CPMF
    vr_dstextab := tabe0001.fn_busca_dstextab ( pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 00
                                               ,pr_cdacesso => 'DIGITALIBE'
                                               ,pr_tpregist => 1 );

    IF TRIM(vr_dstextab) IS NOT NULL THEN
      vr_flg_digitlib := gene0002.fn_busca_entrada(1,vr_dstextab,';');
    END IF;

    --> Mensagem impressao de cartao de assinatura
    IF vr_flg_digitlib = 'S' THEN
      --> Buscar avalistas terceiros
      FOR rw_crapavt IN cr_crapavt LOOP
        IF rw_crapavt.nrdctato <> 0 THEN

          -- Buscar dados do cooperado
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => rw_crapavt.nrdctato);
          FETCH cr_crapass INTO rw_bcrapass;
          CLOSE cr_crapass;
          pc_cria_registro_msg(pr_dsmensag             => 'Imprimir Cartao de Assinatura - Procurador: '|| rw_bcrapass.nmprimtl ,
                               pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

        ELSE
          pc_cria_registro_msg(pr_dsmensag             => 'Imprimir Cartao de Assinatura - Procurador: '|| rw_crapavt.nmdavali ,
                               pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

        END IF;

      END LOOP;

      --> Buscar titulares da conta
      FOR rw_crapttl IN cr_crapttl LOOP
        pc_cria_registro_msg(pr_dsmensag             => 'Imprimir Cartao de Assinatura - Titular: '|| rw_crapttl.nmextttl,
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

      END LOOP;

      --> Buscar cadastro do representante legal
      FOR rw_crapcrl IN cr_crapcrl LOOP
        IF TRIM(rw_crapcrl.nmrespon) IS NOT NULL THEN
          pc_cria_registro_msg(pr_dsmensag             => 'Imprimir Cartao de Assinatura - Responsavel Legal: '|| rw_crapcrl.nmrespon,
                               pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
        ELSE
          OPEN cr_crapttl2 (pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => rw_crapcrl.nrdconta,
                            pr_idseqttl => 1);
          FETCH cr_crapttl2 INTO rw_crapttl2;
          CLOSE cr_crapttl2;

          pc_cria_registro_msg(pr_dsmensag             => 'Imprimir Cartao de Assinatura - Responsavel Legal: '|| rw_crapttl2.nmextttl,
                               pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

        END IF;
      END LOOP;

    END IF;


    --> Mensagem entrega de cartao
    OPEN cr_crapcrm;
    FETCH cr_crapcrm INTO rw_crapcrm;

    IF cr_crapcrm%FOUND THEN
      CLOSE cr_crapcrm;

      --> Verificar se data já esta na tabela generica
      vr_dstextab := tabe0001.fn_busca_dstextab ( pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'AUTOMA'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'CM'||to_char(rw_crapcrm.dtemscar,'DDMMRRRR')
                                                 ,pr_tpregist => 0 );

      IF TRIM(vr_dstextab) = '1' THEN
        pc_cria_registro_msg(pr_dsmensag             => 'Cartao magnetico disponivel para entrega.',
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;
    ELSE
      CLOSE cr_crapcrm;
    END IF;

    vr_qttitula := 0;

    IF rw_crapass.inpessoa = 1 THEN
      --> COntar quantidade de titulares da conta
      OPEN cr_crapttl_count;
      FETCH cr_crapttl_count INTO vr_qttitula;
      CLOSE cr_crapttl_count;
    ELSE
      vr_qttitula := 1;
    END IF;

    -- Loop com a quantidade de titulares
    FOR vr_contador IN 1..vr_qttitula LOOP
      --> Buscar cadastro de senha do titular
      OPEN cr_crapsnh (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_idseqttl => vr_contador);
      FETCH cr_crapsnh INTO rw_crapsnh;

      --> Buscar cartao ativo do cooperado
      OPEN cr_crapcrm_2 (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_idseqttl => vr_contador,
                         pr_dtmvtolt => pr_rw_crapdat.dtmvtolt);
      FETCH cr_crapcrm_2 INTO rw_crapcrm_2;

      vr_flgexist := FALSE;

      IF rw_crapass.inpessoa = 1 THEN
        --> Verificar se cooperado possui cartao bancoob
        OPEN cr_crapcrd_1 (pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta,
                           pr_idseqttl => vr_contador);
        FETCH cr_crapcrd_1 INTO rw_crapcrd_1;
        vr_flgexist := cr_crapcrd_1%FOUND;
        CLOSE cr_crapcrd_1;

      ELSE
        --> Verificar se cooperado possui cartao bancoob
        OPEN cr_crapcrd_2 (pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta);
        FETCH cr_crapcrd_2 INTO rw_crapcrd_2;
        vr_flgexist := cr_crapcrd_2%FOUND;
        CLOSE cr_crapcrd_2;

      END IF;
      -- Senao encontrar senha e cartão, pode pular para o proximo
      IF cr_crapsnh%NOTFOUND AND cr_crapcrm_2%NOTFOUND AND
         vr_flgexist = FALSE THEN
        CLOSE cr_crapsnh;
        CLOSE cr_crapcrm_2;
        continue;
      END IF;

      -- fechar cursores
      CLOSE cr_crapsnh;
      CLOSE cr_crapcrm_2;

      vr_flgcadas := fn_verif_letras_seguranca( pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                                               ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                                               ,pr_idseqttl => vr_contador);--> sequencial do titular

      IF vr_flgcadas = 0 /* False */ THEN
        IF rw_crapass.inpessoa = 1  THEN
          vr_dsmensag := 'Falta cadastro das letras de seguranca - '|| vr_contador|| 'o titular.';
        ELSE
          IF rw_crapass.idastcjt = 0 THEN
            vr_dsmensag := 'Falta cadastro das letras de seguranca.';
          ELSE
            vr_dsmensag := 'Falta cadastro das letras de seguranca para TAA.';
          END IF;
        END if;
        -- Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;

    END LOOP;

    --> Buscar limite de credito do cooperado
    OPEN cr_craplim( pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_tpctrlim => 1,
                     pr_insitlim => 2);
    FETCH cr_craplim INTO rw_craplim;
    IF cr_craplim%FOUND THEN

      IF rw_craplim.dtfimvig IS NOT NULL THEN
        IF rw_craplim.dtfimvig <= pr_rw_crapdat.dtmvtolt THEN
          -- Incluir na temptable
          pc_cria_registro_msg(pr_dsmensag             => 'Contrato de limite de credito vencido.',
                               pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
        END IF;
      ELSIF (rw_craplim.dtinivig + rw_craplim.qtdiavig) <= pr_rw_crapdat.dtmvtolt  THEN
        -- Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => 'Contrato de limite de credito vencido.',
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;
    END IF;
    CLOSE cr_craplim;

    --> Tabela de limite de desconto de cheques
    vr_dstextab := tabe0001.fn_busca_dstextab ( pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'LIMDESCONT'
                                               ,pr_tpregist => 0 );

    IF TRIM(vr_dstextab) IS NULL THEN
      -- Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Tabela LIMDESCONT nao cadastrada.',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    ELSE
      vr_dstextab := trim(SUBSTR(vr_dstextab,19,02));
    END IF;

    --> Verifica se ja excedeu a vigencia do limite de desconto de cheques
    OPEN cr_craprli( pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_tpctrlim => 2,
                     pr_insitlim => 2,
                     pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_craprli INTO rw_craprli;
    IF cr_craprli%FOUND THEN

      IF rw_craprli.dtfimvig IS NOT NULL THEN
          IF rw_craprli.dtfimvig < pr_rw_crapdat.dtmvtolt THEN
        -- Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => 'Contrato de Desconto de Cheques Vencido.',
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;
      ELSIF (rw_craprli.dtinivig + rw_craprli.qtdiavig) < pr_rw_crapdat.dtmvtolt  THEN
        -- Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => 'Contrato de Desconto de Cheques Vencido.',
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;

    END IF;
    CLOSE cr_craprli;

    -- MENSAGENS PREJUÍZO --
    IF rw_crapass.inprejuz = 1 THEN
      -- Conta corrente em prejuizo
      -- Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Conta Corrente em Prejuizo',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    ELSE
      OPEN cr_prejuizo(pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_prejuizo INTO rw_prejuizo;
      IF cr_prejuizo%FOUND THEN
        CLOSE cr_prejuizo;
        -- Houve prejuizo de Conta Corrente
        -- Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => 'Houve Prejuizo de Conta Corrente',
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      ELSE
        CLOSE cr_prejuizo;
    END IF;
    END IF;

    vr_flgpreju := FALSE;
    vr_flgpreju_ativo := FALSE;
    --> Verificar se possui emprestimo em prejuizo
    FOR rw_crapepr IN cr_crapepr LOOP
      vr_flgpreju := TRUE;
      IF rw_crapepr.vlsdprej > 0  THEN
        vr_flgpreju_ativo := TRUE;
        EXIT;
    END IF;
    END LOOP;

    IF vr_flgpreju THEN
      IF vr_flgpreju_ativo THEN
      pc_cria_registro_msg(pr_dsmensag             => 'Conta Corrente com Emprestimo em Prejuizo',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    ELSE
      pc_cria_registro_msg(pr_dsmensag             => 'Houve Prejuizo de Emprestimo',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;
    END IF;

  vr_flgpreju_bdt := FALSE;
    vr_flgpreju_bdt_liq := FALSE;
    --> Verifica se possui bordero em prejuizo
    OPEN cr_crapbdt_preju (pr_cdcooper=>pr_cdcooper, pr_nrdconta=>pr_nrdconta);
    LOOP FETCH cr_crapbdt_preju INTO rw_crapbdt_preju;
      EXIT WHEN cr_crapbdt_preju%NOTFOUND;
      vr_flgpreju_bdt_liq := TRUE;
      IF (rw_crapbdt_preju.inprejuz=1) THEN
        --Conta possui desconto de título em prejuízo
        IF (rw_crapbdt_preju.dtliqprj IS NULL) THEN
          vr_flgpreju_bdt := TRUE;
          vr_flgpreju_bdt_liq := FALSE;
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF (vr_flgpreju_bdt_liq) THEN
      -- Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Houve prejuizo de desconto de titulos nesta conta - liquidado',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;

    IF (vr_flgpreju_bdt) THEN
      -- Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Conta possui desconto de titulo em prejuizo',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;

    -- Verifica se possui títulos em atraso
    OPEN cr_craptdb_atrasados (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                              ,pr_dtmvtoan => pr_rw_crapdat.dtmvtoan);
    FETCH cr_craptdb_atrasados INTO rw_craptdb_atrasados;

    IF cr_craptdb_atrasados%FOUND THEN
      -- Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Associado com borderô de desconto de títulos em atraso',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;
    CLOSE cr_craptdb_atrasados;

    -- FIM MENSAGENS PREJUÍZO --

    IF pr_cdcooper IN (16,1) THEN /* Se Viacredi AltoVale ou Viacredi*/
      pc_ret_criticas_altovale(pr_cdcooper => pr_cdcooper            --> Codigo da cooperativa
                              ,pr_nrcpfcgc => rw_crapass.nrcpfcgc    --> CPF/CNPJ do cooperado
                              ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data do movimento
                              ,pr_sqalerta => vr_sralerta            --> sequencial do alerta
                              ,pr_tab_alertas => vr_tab_alertas);    --> Temptable de Altertas

      -- Ler temptable de retorno
      vr_idxalert := vr_tab_alertas.first;
      WHILE vr_idxalert IS NOT NULL LOOP

        -- Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => vr_tab_alertas(vr_idxalert).dsalerta,
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
        -- buscar proximo
        vr_idxalert := vr_tab_alertas.next(vr_idxalert);
      END LOOP;
    END IF;

    IF rw_crapass.cdsitdtl IN (2,4,6,8) THEN
      -- Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Titular da conta bloqueado.',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;

    -- busca o tipo de documento GED
    vr_dstextab_digitaliza := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                        ,pr_nmsistem => 'CRED'
                                                        ,pr_tptabela => 'GENERI'
                                                        ,pr_cdempres => 00
                                                        ,pr_cdacesso => 'DIGITALIZA'
                                                        ,pr_tpregist => 5);

    -- Leitura do indicador de uso da tabela de taxa de juros
    vr_dstextab_parempctl := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'USUARI'
                                                       ,pr_cdempres => 11
                                                       ,pr_cdacesso => 'PAREMPCTL'
                                                       ,pr_tpregist => 01);


    --Buscar Indicador Uso tabela
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'TAXATABELA'
                                            ,pr_tpregist => 0);
    --Se nao encontrou
    IF vr_dstextab IS NULL THEN
      --Nao usa tabela
      vr_inusatab:= FALSE;
    ELSE
      IF  SUBSTR(vr_dstextab,1,1) = '0' THEN
        --Nao usa tabela
        vr_inusatab:= FALSE;
      ELSE
        --Nao usa tabela
        vr_inusatab:= TRUE;
      END IF;
    END IF;

    --> Procedure para obter dados de emprestimos do associado
    empr0001.pc_obtem_dados_empresti
                           (pr_cdcooper       => pr_cdcooper           --> Cooperativa conectada
                           ,pr_cdagenci       => pr_cdagenci           --> Código da agência
                           ,pr_nrdcaixa       => pr_nrdcaixa           --> Número do caixa
                           ,pr_cdoperad       => pr_cdoperad           --> Código do operador
                           ,pr_nmdatela       => pr_nmdatela           --> Nome datela conectada
                           ,pr_idorigem       => pr_idorigem           --> Indicador da origem da chamada
                           ,pr_nrdconta       => pr_nrdconta           --> Conta do associado
                           ,pr_idseqttl       => pr_idseqttl           --> Sequencia de titularidade da conta
                           ,pr_rw_crapdat     => pr_rw_crapdat         --> Vetor com dados de parâmetro (CRAPDAT)
                           ,pr_dtcalcul       => pr_rw_crapdat.dtmvtolt--> Data solicitada do calculo
                           ,pr_nrctremp       => 0                     --> Número contrato empréstimo
                           ,pr_cdprogra       => 'B1WGEN0030'          --> Programa conectado
                           ,pr_inusatab       => vr_inusatab           --> Indicador de utilização da tabela
                           ,pr_flgerlog       => 'N'                   --> Gerar log S/N
                           ,pr_flgcondc       => FALSE                 --> Mostrar emprestimos liquidados sem prejuizo
                           ,pr_nmprimtl       => rw_crapass.nmprimtl   --> Nome Primeiro Titular
                           ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                           ,pr_tab_digitaliza => vr_dstextab_digitaliza--> Dados tabela parametro
                           ,pr_nriniseq       => 0                     --> Numero inicial da paginacao
                           ,pr_nrregist       => 0                     --> Numero de registros por pagina
                           ,pr_qtregist       => vr_qtregist           --> Qtde total de registros
                           ,pr_tab_dados_epr  => vr_tab_dados_epr      --> Saida com os dados do empréstimo
                           ,pr_des_reto       => vr_des_reto           --> Retorno OK / NOK
                           ,pr_tab_erro       => vr_tab_erro);         --> Tabela com possíves erros

    IF vr_des_reto = 'NOK' THEN
      IF vr_tab_erro.exists(vr_tab_erro.first) THEN

        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      ELSE
        vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
      END IF;
      RAISE vr_exc_erro;

    END IF;

    --Ler emprestimos
    vr_idxepr := vr_tab_dados_epr.first;
    WHILE vr_idxepr IS NOT NULL LOOP
      BEGIN
        vr_vltotprv := nvl(vr_vltotprv,0) + vr_tab_dados_epr(vr_idxepr).vlprovis;

        -- se nao possuir saldo devedor, deve pular para o proximo
        IF vr_tab_dados_epr(vr_idxepr).vlsdeved <= 0 THEN
          RAISE vr_exc_next;
        END IF;

        --> Buscar emprestimos do cooperado
        OPEN cr_crapepr_2(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nrctremp => vr_tab_dados_epr(vr_idxepr).nrctremp);
        FETCH cr_crapepr_2 INTO rw_crapepr_2;

        IF cr_crapepr_2%FOUND AND
           rw_crapepr_2.tpdescto = 2             AND
           pr_rw_crapdat.dtmvtolt < rw_crapepr_2.dtdpagto THEN
          CLOSE cr_crapepr_2;
          RAISE vr_exc_next;
        ELSE
          CLOSE cr_crapepr_2;
        END IF;

        vr_dsmensag := NULL;
        vr_flgativo := NULL;

        -- Verifica contratos de acordos
        RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => 0
                                         ,pr_cdorigem => 0
                                         ,pr_flgativo => vr_flgativo
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Caso contrato esteja ativo pula para proximo registro
        IF vr_flgativo = 1  THEN
          RAISE vr_exc_next;
        END IF;

        IF vr_tab_dados_epr(vr_idxepr).tpemprst IN (1,2) and vr_tab_dados_epr(vr_idxepr).flgatras = 1 THEN  /*04/10/2016 #487823*/
            vr_dsmensag := 'Associado com emprestimo em atraso.';
        ELSIF (vr_tab_dados_epr(vr_idxepr).qtmesdec - vr_tab_dados_epr(vr_idxepr).qtprecal) >= 0.01  AND
               vr_tab_dados_epr(vr_idxepr).dtdpagto < pr_rw_crapdat.dtmvtolt                    THEN
          --> Verificar se a data de pagamento é um dia util
          IF vr_tab_dados_epr(vr_idxepr).dtdpagto <> gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                                                 pr_dtmvtolt => vr_tab_dados_epr(vr_idxepr).dtdpagto,
                                                                                 pr_tipo     => 'P' ) THEN
            -- > Verificar se menor que a data de movimento anterior
            IF vr_tab_dados_epr(vr_idxepr).dtdpagto < pr_rw_crapdat.dtmvtoan  THEN
              vr_dsmensag := 'Associado com emprestimo em atraso.';
            END IF;
          ELSE
            vr_dsmensag := 'Associado com emprestimo em atraso.';
          END IF;

        ELSIF vr_tab_dados_epr(vr_idxepr).vlpreapg <> 0                        AND
              vr_tab_dados_epr(vr_idxepr).dtdpagto <> pr_rw_crapdat.dtmvtolt   AND
             (vr_tab_dados_epr(vr_idxepr).qtmesdec -
              vr_tab_dados_epr(vr_idxepr).qtprecal) >= 0.01  THEN

          --> Verificar se a data de pagamento é um dia util
          IF vr_tab_dados_epr(vr_idxepr).dtdpagto = gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                                                 pr_dtmvtolt => vr_tab_dados_epr(vr_idxepr).dtdpagto,
                                                                                 pr_tipo     => 'P' ) THEN
            vr_dsmensag := 'Associado com emprestimo em atraso.';
          END IF;
        END IF;

        /* PORTABILIDADE - verifica se o contrato liquidado foi portado para outra instituicao */
        OPEN cr_portabilidade(pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrctremp => vr_tab_dados_epr(vr_idxepr).nrctremp);
        FETCH cr_portabilidade INTO rw_portabilidade;
        CLOSE cr_portabilidade;

        IF vr_epr_portabilidade IS NULL THEN
          vr_epr_portabilidade := rw_portabilidade.nrctremp;
        ELSE
          vr_epr_portabilidade := vr_epr_portabilidade ||','||rw_portabilidade.nrctremp;
        END IF;

        -- Se gerou uma mensagem, deve gravar na temptable de retorno e sair do loop de emprestimos
        IF vr_dsmensag IS NOT NULL  THEN
          -- Incluir na temptable
          pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                               pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

           EXIT;
        END IF;

      EXCEPTION
        WHEN vr_exc_next THEN
          NULL;
      END;
      vr_idxepr := vr_tab_dados_epr.next(vr_idxepr);
    END LOOP;

    --> cria o registro para informar os contratos liquidados pela portabilidade
    IF vr_epr_portabilidade IS NOT NULL THEN
      vr_epr_portabilidade := 'Contrato(s) liquidado(s) por Portabilidade '|| vr_epr_portabilidade;

      -- Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => vr_epr_portabilidade,
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;

    IF vr_tab_dados_epr.count > 0 THEN
      -- Gerar mensagens de emprestimos migrados
      FOR vr_contador IN vr_tab_dados_epr.first..vr_tab_dados_epr.LAST LOOP

        OPEN cr_tbepr_migracao_empr(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctremp => vr_tab_dados_epr(vr_contador).nrctremp);
        FETCH cr_tbepr_migracao_empr INTO rw_tbepr_migracao_empr;

        IF cr_tbepr_migracao_empr%FOUND THEN
          vr_tbepr_migracao_empr := 'Contrato '|| vr_tab_dados_epr(vr_contador).nrctremp || ' foi migrado para o contrato ' || rw_tbepr_migracao_empr.nrctrnov;

          pc_cria_registro_msg(pr_dsmensag             => vr_tbepr_migracao_empr,
                               pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;
        CLOSE cr_tbepr_migracao_empr;

      END LOOP;
    END IF;

    --> Buscar emprestimos onde a conta é avalista
    FOR rw_crapavl IN cr_crapavl (pr_cdcooper => pr_cdcooper,
                                  pr_nrdconta => pr_nrdconta) LOOP

      IF NOT ((rw_crapavl.inprejuz = 1  AND
               rw_crapavl.vlsdprej > 0) OR
               rw_crapavl.inliquid = 0) THEN
        continue;
      END IF;

      /** Ate 100 emprestimos em atraso **/
      vr_qtempatr := nvl(vr_qtempatr,0) + 1;
      IF vr_qtempatr > 99 THEN
        EXIT;
      END IF;

      vr_tab_dados_epr.delete;
      --> buscar dados do emprestimo onde a conta é avalista
      empr0001.pc_obtem_dados_empresti
                             (pr_cdcooper       => pr_cdcooper           --> Cooperativa conectada
                             ,pr_cdagenci       => pr_cdagenci           --> Código da agência
                             ,pr_nrdcaixa       => pr_nrdcaixa           --> Número do caixa
                             ,pr_cdoperad       => pr_cdoperad           --> Código do operador
                             ,pr_nmdatela       => pr_nmdatela           --> Nome datela conectada
                             ,pr_idorigem       => pr_idorigem           --> Indicador da origem da chamada
                             ,pr_nrdconta       => rw_crapavl.nrctaavd   --> Conta do associado
                             ,pr_idseqttl       => pr_idseqttl           --> Sequencia de titularidade da conta
                             ,pr_rw_crapdat     => pr_rw_crapdat         --> Vetor com dados de parâmetro (CRAPDAT)
                             ,pr_dtcalcul       => pr_rw_crapdat.dtmvtolt--> Data solicitada do calculo
                             ,pr_nrctremp       => rw_crapavl.nrctravd   --> Número contrato empréstimo
                             ,pr_cdprogra       => 'B1WGEN0030'          --> Programa conectado
                             ,pr_inusatab       => vr_inusatab           --> Indicador de utilização da tabela
                             ,pr_flgerlog       => 'N'                   --> Gerar log S/N
                             ,pr_flgcondc       => FALSE                 --> Mostrar emprestimos liquidados sem prejuizo
                             ,pr_nmprimtl       => rw_crapass.nmprimtl   --> Nome Primeiro Titular
                             ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                             ,pr_tab_digitaliza => vr_dstextab_digitaliza--> Dados tabela parametro
                             ,pr_nriniseq       => 0                     --> Numero inicial da paginacao
                             ,pr_nrregist       => 0                     --> Numero de registros por pagina
                             ,pr_qtregist       => vr_qtregist           --> Qtde total de registros
                             ,pr_tab_dados_epr  => vr_tab_dados_epr      --> Saida com os dados do empréstimo
                             ,pr_des_reto       => vr_des_reto           --> Retorno OK / NOK
                             ,pr_tab_erro       => vr_tab_erro);         --> Tabela com possíves erros

      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN

          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        ELSE
          vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
        END IF;
        RAISE vr_exc_erro;

      END IF;

      --Ler emprestimos
      vr_idxepr := vr_tab_dados_epr.first;
      IF vr_idxepr IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Registro de emprestimo temporario nao encontrado.';
        RAISE vr_exc_erro;
      END IF;

      vr_dsmensag := NULL;
      vr_flgativo := NULL;

      -- Verifica contratos de acordos
      RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => rw_crapavl.nrctaavd
                                       ,pr_nrctremp => 0
                                       ,pr_cdorigem => 0
                                       ,pr_flgativo => vr_flgativo
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Caso contrato esteja ativo pula para proximo registro
      IF vr_flgativo = 1 THEN
        continue;
      END IF;

      IF vr_tab_dados_epr(vr_idxepr).tpemprst IN (1,2) and vr_tab_dados_epr(vr_idxepr).flgatras = 1 THEN /*04/10/2016 #487823*/
          vr_dsmensag := 'Fiador de emprestimo em atraso: ';
      ELSIF rw_crapavl.inprejuz = 1 AND rw_crapavl.vlsdprej > 0  THEN
        vr_dsmensag := 'Fiador de emprestimo em atraso: ';
      ELSE
        -- se nao possuir saldo devedor, ir para o proximo emprestimo
        IF vr_tab_dados_epr(vr_idxepr).vlsdeved <= 0  THEN
          continue;
        END IF;

        -- em conta corrente e ainda não esta na data de pagamento
        IF rw_crapavl.tpdescto = 2             AND
           pr_rw_crapdat.dtmvtolt < rw_crapavl.dtdpagto  THEN
          continue;
        END IF;

        IF (vr_tab_dados_epr(vr_idxepr).qtmesdec - vr_tab_dados_epr(vr_idxepr).qtprecal) >= 0.01  AND
            vr_tab_dados_epr(vr_idxepr).dtdpagto < pr_rw_crapdat.dtmvtolt                    THEN
          --> Verificar se a data de pagamento é um dia util
          IF vr_tab_dados_epr(vr_idxepr).dtdpagto <> gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                                                 pr_dtmvtolt => vr_tab_dados_epr(vr_idxepr).dtdpagto,
                                                                                 pr_tipo     => 'P' ) THEN
            -- > Verificar se menor que a data de movimento anterior
            IF vr_tab_dados_epr(vr_idxepr).dtdpagto < pr_rw_crapdat.dtmvtoan  THEN
              vr_dsmensag := 'Fiador de emprestimo em atraso:';
            END IF;
          ELSE
            vr_dsmensag := 'Fiador de emprestimo em atraso:';
          END IF;

        ELSIF vr_tab_dados_epr(vr_idxepr).vlpreapg <> 0                        AND
              vr_tab_dados_epr(vr_idxepr).dtdpagto <> pr_rw_crapdat.dtmvtolt   THEN

          --> Verificar se a data de pagamento é um dia util
          IF vr_tab_dados_epr(vr_idxepr).dtdpagto = gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                                                 pr_dtmvtolt => vr_tab_dados_epr(vr_idxepr).dtdpagto,
                                                                                 pr_tipo     => 'P' ) THEN
            vr_dsmensag := 'Fiador de emprestimo em atraso: ';
          END IF;
        END IF;
      END IF;

      -- se encontrou critica, gerar registro na temptable
      IF vr_dsmensag IS NOT NULL THEN

        -- Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag||
                                                        'Conta: '||TRIM(gene0002.fn_mask_conta(rw_crapavl.nrctaavd))||
                                                        ' Contrato: '||TRIM(gene0002.fn_mask_contrato(rw_crapavl.nrctravd))|| '.',
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;
    END LOOP;  -- Fim loop avalista

    vr_flbndand := FALSE;  /* em andamento*/
    vr_flbndatr := FALSE;  /* em atraso */
    vr_flbndprj := FALSE;  /* em prejuizo */
    vr_flbndnor := FALSE; /* normal */

    --> Valida Emprestimo BNDES
    FOR rw_crapprp IN cr_crapprp LOOP
      --> Buscar Notas do rating por contrato
      OPEN cr_crapnrc(pr_cdcooper => rw_crapprp.cdcooper,
                      pr_nrdconta => rw_crapprp.nrdconta,
                      pr_nrctrato => rw_crapprp.nrctrato,
                      pr_tpctrato => rw_crapprp.tpctrato);
      FETCH cr_crapnrc INTO rw_crapnrc;
      IF  cr_crapnrc%NOTFOUND AND vr_flbndand = FALSE THEN
        vr_dsmensag := 'Atencao! Cooperado possui proposta de BNDES em andamento. Verifique.';
        -- Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

        vr_flbndand := TRUE;
        vr_dsmensag := NULL;
        CLOSE cr_crapnrc;
        continue;
      ELSE
        CLOSE cr_crapnrc;
      END IF;

      --> Buscar Cadastro de emprestimo BNDES -- Ativa, EM ATRASO ou Normal
      OPEN cr_crapebn(pr_cdcooper => rw_crapprp.cdcooper,
                      pr_nrdconta => rw_crapprp.nrdconta,
                      pr_nrctrato => rw_crapprp.nrctrato);
      FETCH cr_crapebn INTO rw_crapebn;

      -- Se localizou
      IF cr_crapebn%FOUND THEN
        CLOSE cr_crapebn;
        IF  rw_crapebn.insitctr = 'P' AND vr_flbndprj = FALSE THEN
          vr_dsmensag := 'Cooperado com emprestimo BNDES em prejuizo!';
          vr_flbndprj := TRUE;
        ELSIF rw_crapebn.insitctr = 'A' AND vr_flbndatr = FALSE THEN
          vr_dsmensag := 'Cooperado com emprestimo BNDES em atraso!';
          vr_flbndatr := TRUE;
        ELSIF rw_crapebn.insitctr = 'N' AND vr_flbndnor = FALSE THEN
          vr_dsmensag := 'Atencao! Cooperado possui operacao de BNDES.';
          vr_flbndnor := TRUE;
        END IF;

        --> Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
        vr_dsmensag := NULL;
        continue; --> cr_crapprp

      ELSE
        CLOSE cr_crapebn;
      END IF;
    END LOOP; -- FIM Valida Emprestimo BNDES

    --> Verificar total de provisão
    IF vr_vltotprv > 0  THEN
      --> Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Valor total provisionado no cheque salario: '||
                                                       to_char(vr_vltotprv,'fm999G999G990D00'),
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;


    --> Verifica se esta no CCF
    IF rw_crapass.inlbacen <> 0  THEN
      --> Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Associado esta no CCF.',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;

    --> Verifica se o CPF não está regularizado
    IF rw_crapass.cdsitcpf > 1 THEN
      vr_dsmensag := 'Associado com CPF' ||
                      CASE rw_crapass.cdsitcpf
                        WHEN 2 THEN ' pendente.'
                        WHEN 3 THEN ' cancelado.'
                        WHEN 4 THEN ' irregular.'
                        WHEN 5 THEN ' suspenso.'
                        ELSE        ' inválido.'
                      END;

      --> Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;

    --> Procura registro de impressao do TERMO DE ADESAO
    /*IF rw_crapass.cdtipcta IN (8,9,10,11) OR
       ((TRIM(rw_crapass.nrdctitg) IS NOT NULL AND rw_crapass.flgctitg = 2)  OR
        (TRIM(rw_crapass.nrdctitg) IS NULL AND rw_crapass.flgctitg = 0)) THEN
      vr_flgachou := FALSE;

      FOR rw_crapalt IN cr_crapalt_1 LOOP
        IF instr(upper(rw_crapalt.dsaltera),'*IMPRESSAO TERMO ADESAO*') > 0  THEN
          vr_flgachou := TRUE;
          EXIT;
        END IF;
      END LOOP;
      -- se nao localizou
      IF NOT vr_flgachou THEN
        --> Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => 'Falta a impressao do Termo de Adesao.',
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;
    END IF; */

    --> Verifica se o endereco foi alterado pelo associado na internet
    FOR rw_crapenc  IN cr_crapenc LOOP
      --> Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Verifique atualizacao de endereco pela '||
                                                      'internet ('|| rw_crapenc.idseqttl ||'o titular).',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

    END LOOP;

    --> Verifica se conta salario está ativa (cdsitcta = 1)
    OPEN cr_crapccs;
    FETCH cr_crapccs INTO rw_crapccs;

    IF cr_crapccs%FOUND THEN
      --> Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Cooperado CPF ('||rw_crapccs.nrcpfcgc||') possui conta salário ativa',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

    END IF;
    CLOSE cr_crapccs;

    -- Verificar necessidade de Prova de Vida
    vr_flgpvida := INSS0001.fn_verifica_renovacao_vida(pr_cdcooper => pr_cdcooper               --> Codigo da cooperativa
                                                              ,pr_nrdconta => pr_nrdconta               --> Numero da conta
                                                              ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt);  --> Data do movimento

    IF vr_flgpvida = 1 THEN
      --> Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Beneficiario com Prova de Vida Pendente. '||
                                                      'Efetue Comprovacao atraves da Tela INSS. ',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

    END IF;

    vr_tpbloque := INSS0001.fn_verifica_bloqueio_inss
                                              (pr_cdcooper => pr_cdcooper              --> Codigo da cooperativa
                                              ,pr_nrdcaixa => pr_nrdcaixa              --> Numero do caixa
                                              ,pr_cdagenci => pr_cdagenci              --> Codigo de agencia
                                              ,pr_cdoperad => pr_cdoperad              --> Codigo do operador
                                              ,pr_nmdatela => pr_nmdatela              --> Nome da tela
                                              ,pr_idorigem => pr_idorigem              --> Identificado de oriem
                                              ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt   --> Data do movimento
                                              ,pr_nrcpfcgc => rw_crapass.nrcpfcgc      --> CPF/CNPJ do cooperado
                                              ,pr_nrprocur => 0                        --> Numero do beneficio a ser procurado
                                              ,pr_tpdconsu => 1);--Verifica Qlqer bene.--> Tipo de consulta

    --> Bloqueio por falta de comprovacao de vida ou comprovacao ainda nao efetuada
    IF vr_tpbloque IN (1,2) THEN
      --> Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Beneficiario com Prova de Vida Pendente. '||
                                                      'Efetue Comprovacao atraves da COMPVI. ',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

    --> Menos de 60 dias para expirar o perido de um ano da comprovacao*/
    ELSIF vr_tpbloque = 3 THEN
      pc_cria_registro_msg(pr_dsmensag             => 'Este beneficiario devera efetuar a comprovacao de vida. A falta de '||
                                 'renovacao  implicara no bloqueio do beneficio pelo INSS.',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;


    --> Verifica Se Tipo de Conta Individual e possui mais de um Titular
    IF rw_crapass.inpessoa = 1  THEN
      IF vr_qttitula > 1 AND rw_crapass.cdcatego = 1 THEN
        --> Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => 'Tipo de conta nao permite MAIS DE UM TITULAR.',
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;
    END IF;

    pc_verif_vig_procurador( pr_cdcooper => pr_cdcooper   --> Codigo da cooperativa
                            ,pr_nmdatela => pr_nmdatela   --> Nome da tela
                            ,pr_nrdconta => pr_nrdconta   --> Numero da conta
                            ,pr_idseqttl => pr_idseqttl   --> sequencial do titular
                            ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt  --> Data do movimento
                            ,pr_dsvigpro => vr_dsvigpro);           --> retorna critica da vigencia
    -- se retornou critica
    IF TRIM(vr_dsvigpro) IS NOT NULL THEN
      --> Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => vr_dsvigpro,
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;

    IF rw_crapass.inpessoa = 2 THEN
      pc_valida_socios(  pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                        ,pr_nmdatela => pr_nmdatela --> Nome da tela
                        ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                        ,pr_dscritic => vr_dsmensag);
      IF vr_dsmensag IS NOT NULL THEN
        --> Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;
    END IF;

    --> Procura registro de recadastramento - JORGE, 27/07/2011
    OPEN cr_crapalt;
    FETCH cr_crapalt INTO rw_crapalt;
    IF cr_crapalt%NOTFOUND THEN
      CLOSE cr_crapalt;

      IF rw_crapass.dtdemiss IS NULL THEN
        vr_dsmensag := gene0001.fn_busca_critica(400); --> Associado nao recadastrado!!
        --> Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
        vr_dsmensag := NULL;
      END IF;
    ELSE
      CLOSE cr_crapalt;

      -- Verifica a data da ultima alteração do cooperado
      IF months_between(pr_rw_crapdat.dtmvtolt,rw_crapalt.dtaltera) > 12 THEN
        pc_cria_registro_msg(pr_dsmensag => 'Cooperado com cadastro vencido.'
                            ,pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;

      /* Somente para pessoa fisica */
      IF rw_crapass.inpessoa = 1 THEN
        -- ler avalistas
        FOR rw_crapavt_2 IN cr_crapavt_2 LOOP
          --> Se o contato eh associado, verifica se esta demitido
          rw_bcrapass := NULL;
          OPEN cr_crapass (pr_cdcooper => rw_crapavt_2.cdcooper,
                           pr_nrdconta => rw_crapavt_2.nrdctato);
          FETCH cr_crapass INTO rw_bcrapass;
          IF cr_crapass%NOTFOUND THEN
            vr_cdcritic := 491; --> Pessoa de contato nao cadastrada.
          ELSIF rw_bcrapass.dtdemiss IS NOT NULL THEN
            vr_cdcritic := 492; --> Pessoa de contato demitida.
          END IF;
          CLOSE cr_crapass;

          IF vr_cdcritic > 0 THEN
            vr_dsmensag := gene0001.fn_busca_critica(vr_cdcritic);
            --> Incluir na temptable
            pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                                 pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
            vr_dsmensag := NULL;
            vr_cdcritic := 0;
            EXIT;
          END IF;

        END LOOP;
      END IF;
    END IF;

  /*
    --> Busca Saldo Bloqueado Judicial
    GENE0005.pc_retorna_valor_blqjud (pr_cdcooper => pr_cdcooper      --> Cooperativa
                                     ,pr_nrdconta => pr_nrdconta      --> Conta
                                     ,pr_nrcpfcgc => 0                --> CPF/CGC
                                     ,pr_cdtipmov => 0                --> Tipo do movimento
                                     ,pr_cdmodali => 0                --> Modalidade
                                     ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data atual
                                     ,pr_vlbloque => vr_vlblqjud      --> Valor bloqueado
                                     ,pr_vlresblq => vr_vlresblq      --> Valor que falta bloquear
                                     ,pr_dscritic => vr_dscritic);    --> Erros encontrados no processo)

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF vr_vlblqjud > 0 THEN
      --> Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Conta Possui Valor Bloqueado Judicialmente.',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;
    */

    -- Busca os processos judiciais
    FOR rw_crapblj IN cr_crapblj LOOP
      pc_cria_registro_msg(pr_dsmensag             => 'Realizado bloqueio judicial. Processo '||rw_crapblj.nrproces||'. '||rw_crapblj.dsjuizem||'.',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);    
    END LOOP;

    --> Procedimento para buscar dados do credito pré-aprovado (crapcpa)
    EMPR0002.pc_busca_dados_cpa (pr_cdcooper  => pr_cdcooper   --> Codigo da cooperativa
                                ,pr_cdagenci  => pr_cdagenci   --> Código da agencia
                                ,pr_nrdcaixa  => pr_nrdcaixa   --> Numero do caixa
                                ,pr_cdoperad  => pr_cdoperad   --> Codigo do operador
                                ,pr_nmdatela  => pr_nmdatela   --> Nome da tela
                                ,pr_idorigem  => pr_idorigem   --> Id origem
                                ,pr_nrdconta  => pr_nrdconta   --> Numero da conta do cooperado
                                ,pr_idseqttl  => pr_idseqttl   --> Sequencial do titular
                                ,pr_nrcpfope  => 0             --> CPF do operador juridico
                                ------ OUT --------
                                ,pr_tab_dados_cpa => vr_tab_dados_cpa  --> Retorna dados do credito pre aprovado
                                ,pr_des_reto      => vr_des_reto       --> Retorno OK/NOK
                                ,pr_tab_erro      => vr_tab_erro);     --> Retorna os erros

    vr_idxcpa := vr_tab_dados_cpa.first;

    IF vr_tab_dados_cpa.exists(vr_idxcpa) AND
       vr_tab_dados_cpa(vr_idxcpa).vldiscrd > 0 THEN
        --> Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => vr_tab_dados_cpa(vr_idxcpa).msgmanua
                            ,pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;

    -- Verificar Cyber
    OPEN cr_crapcyc;
    FETCH cr_crapcyc INTO rw_crapcyc;
    IF cr_crapcyc%FOUND THEN

      --> Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => 'Existem contratos em cobrança – Consultar CADCYB ou CYBER',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;
    CLOSE cr_crapcyc;

    --> buscar boletos de contratos em aberto
    FOR rw_tbrecup_cobranca IN cr_tbrecup_cobranca LOOP
      --COBEMP
      IF (rw_tbrecup_cobranca.tpproduto=0) THEN
      -- Em aberto
      IF rw_tbrecup_cobranca.incobran = 0 THEN
        vr_dsmensag := 'Boleto do contrato '|| rw_tbrecup_cobranca.nrctremp|| ' em aberto.'||
                       ' Vencto '|| to_char(rw_tbrecup_cobranca.dtvencto,'DD/MM/RRRR')||
                       ' R$ '|| to_char(rw_tbrecup_cobranca.vltitulo, 'fm999G999G990D00mi') ||'.';

        --> Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      -- Pago
      ELSIF rw_tbrecup_cobranca.incobran = 5 THEN
        -- Verificar se ret ainda nao foi processado
        OPEN cr_crapret (pr_cdcooper => rw_tbrecup_cobranca.cdcooper,
                         pr_nrdconta => rw_tbrecup_cobranca.nrdconta,
                         pr_nrcnvcob => rw_tbrecup_cobranca.nrcnvcob,
                         pr_nrdocmto => rw_tbrecup_cobranca.nrdocmto,
                         pr_dtdpagto => rw_tbrecup_cobranca.dtdpagto);
        FETCH cr_crapret INTO rw_crapret;

        -- Se encontrar apresentar critica
        IF cr_crapret%FOUND THEN
          vr_dsmensag := 'Boleto do contrato '|| rw_tbrecup_cobranca.nrctremp||
                         ' esta pago pendente de processamento.'||
                         ' Vencto '|| to_char(rw_tbrecup_cobranca.dtvencto,'DD/MM/RRRR')||
                         ' R$ '|| to_char(rw_tbrecup_cobranca.vltitulo, 'fm999G999G990D00mi') ||'.';

          --> Incluir na temptable
          pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                               pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

        END IF;
        CLOSE cr_crapret;


      END IF;
      ELSE
        --COBTIT
        IF (rw_tbrecup_cobranca.tpproduto=3) THEN
          -- Em aberto
          IF rw_tbrecup_cobranca.incobran = 0 THEN
            vr_dsmensag := 'Boleto do borderô '|| rw_tbrecup_cobranca.nrctremp|| ' em aberto.'||
                           ' Vencto '|| to_char(rw_tbrecup_cobranca.dtvencto,'DD/MM/RRRR')||
                           ' R$ '|| to_char(rw_tbrecup_cobranca.vltitulo, 'fm999G999G990D00mi') ||'.';

            --> Incluir na temptable
            pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                                 pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
          -- Pago
          ELSIF rw_tbrecup_cobranca.incobran = 5 THEN
            -- Verificar se ret ainda nao foi processado
            OPEN cr_crapret (pr_cdcooper => rw_tbrecup_cobranca.cdcooper,
                             pr_nrdconta => rw_tbrecup_cobranca.nrdconta,
                             pr_nrcnvcob => rw_tbrecup_cobranca.nrcnvcob,
                             pr_nrdocmto => rw_tbrecup_cobranca.nrdocmto,
                             pr_dtdpagto => rw_tbrecup_cobranca.dtdpagto);
            FETCH cr_crapret INTO rw_crapret;

            -- Se encontrar apresentar critica
            IF cr_crapret%FOUND THEN
              vr_dsmensag := 'Boleto do borderô '|| rw_tbrecup_cobranca.nrctremp||
                             ' esta pago pendente de processamento.'||
                             ' Vencto '|| to_char(rw_tbrecup_cobranca.dtvencto,'DD/MM/RRRR')||
                             ' R$ '|| to_char(rw_tbrecup_cobranca.vltitulo, 'fm999G999G990D00mi') ||'.';

              --> Incluir na temptable
              pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                                   pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

            END IF;
            CLOSE cr_crapret;


          END IF;
        END IF;
      END IF;
    END LOOP;

    --> Apresentar alerta caso o cooperado possuir proposta de cartao rejeitada
    OPEN cr_crawcrd;
    FETCH cr_crawcrd INTO rw_crawcrd;
    IF cr_crawcrd%FOUND THEN

      vr_dsmensag := 'Cooperado possui cartao rejeitado, '||
                     'verificar relatorio de criticas numero (676).';
      --> Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;
    CLOSE cr_crawcrd;

    IF rw_crapass.idastcjt = 1 THEN
      cada0001.pc_busca_dados_58(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => pr_nrdcaixa
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_idorigem => pr_idorigem
                                ,pr_nrdconta => rw_crapass.nrdconta
                                ,pr_idseqttl => 0
                                ,pr_flgerlog => FALSE
                                ,pr_cddopcao => 'C'
                                ,pr_nrdctato => 0
                                ,pr_nrcpfcto => ''
                                ,pr_nrdrowid => NULL
                                ,pr_tab_crapavt => vr_tab_crapavt
                                ,pr_tab_bens => vr_tab_bens
                                ,pr_tab_erro => vr_tab_erro
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR
        vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      FOR vr_contador IN vr_tab_crapavt.FIRST..vr_tab_crapavt.LAST LOOP

        IF vr_tab_crapavt(vr_contador).idrspleg = 1 THEN
          OPEN cr_crapsnh_2(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_tpdsenha => 3
                           ,pr_nrcpfcgc => vr_tab_crapavt(vr_contador).nrcpfcgc);

          FETCH cr_crapsnh_2 INTO rw_crapsnh_2;

          IF cr_crapsnh_2%NOTFOUND THEN

            vr_dsmensag := 'Falta cadastro das letras de seguranca – CPF Responsavel: '
                          || gene0002.fn_mask_cpf_cnpj(vr_tab_crapavt(vr_contador).nrcpfcgc,1);

            --> Incluir na temptable
            pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                                 pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);

            CLOSE cr_crapsnh_2;

          ELSE
            CLOSE cr_crapsnh_2;
          END IF;

        END IF;

      END LOOP;

    END IF;

    -- Verifica contratos de acordos
    RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctremp => 0
                                     ,pr_cdorigem => 0
                                     ,pr_flgativo => vr_flgativo
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF vr_flgativo = 1 THEN
      pc_cria_registro_msg(pr_dsmensag             => 'Atencao! Cooperado possui contrato em acordo.',
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
    END IF;

    --> Busca parametro de qtd dias em atraso de fatura de cartao em atraso para apresentacao da mensagem.
    BEGIN
      vr_qtdiaatr := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                               pr_cdcooper => 0,
                                               pr_cdacesso => 'QTD_DIAS_FAT_CRD_ATRASO');
    EXCEPTION
     WHEN OTHERS THEN
        vr_qtdiaatr := 0;
    END;

    --> Buscar alerta de atraso do cartao
    FOR rw_crdatraso IN cr_crdatraso( pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta) LOOP

      IF (rw_crdatraso.qtdias_atraso > 0) AND (rw_crdatraso.qtdias_atraso > vr_qtdiaatr) THEN
        vr_dsmensag := 'Cooperado com fatura de cartão de crédito em atraso há '||
                       rw_crdatraso.qtdias_atraso ||
                       ' dias no valor de R$ '|| to_char(rw_crdatraso.vlsaldo_devedor,'FM999G999G999G990D00');

        --> Incluir na temptable
        pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;
    END LOOP;

    BEGIN
      blqj0002.pc_verifica_conta_bloqueio(pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_id_conta_monitorada => vr_id_conta_monitorada,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      FOR rw_processos_monitorados IN cr_processos_monitorados(pr_cdcooper => pr_cdcooper,
                                                               pr_nrdconta => pr_nrdconta) LOOP
        vr_processos_monitorados := vr_processos_monitorados || ' Processo: '||rw_processos_monitorados.dsprocesso||'. '||rw_processos_monitorados.nmjuiz||'. Saldo a bloquear: R$ ' || to_char(rw_processos_monitorados.vlsaldo,'fm999g999g990d00') ||'. ';
      END LOOP;
      IF vr_id_conta_monitorada = 1 THEN
        pc_cria_registro_msg(pr_dsmensag             => 'Cooperado possui bloqueio judicial. '|| vr_processos_monitorados||'Conforme normativa do BACEN, débitos não serão autorizados.',
                             pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END IF;
    END;

  -- Verifica se a conta possui algum grupo economico novo
    vr_tab_mensagens.DELETE;
    TELA_CONTAS_GRUPO_ECONOMICO.pc_obtem_mensagem_grp_econ(pr_cdcooper      => pr_cdcooper
                                                          ,pr_nrdconta      => pr_nrdconta
                                                          ,pr_tab_mensagens => vr_tab_mensagens
                                                          ,pr_cdcritic      => vr_cdcritic
                                                          ,pr_dscritic      => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Condicao para verificar se possui mensagem para exibir do grupo economico
    IF vr_tab_mensagens.COUNT > 0 THEN
      FOR i IN vr_tab_mensagens.first..vr_tab_mensagens.last LOOP
        pc_cria_registro_msg(pr_dsmensag             => vr_tab_mensagens(i).dsmensag,
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
      END LOOP;
    END IF;
  -- Verifica se foi impressa a declaração de optante do simples nacional
  OPEN cr_impdecsn(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
  FETCH cr_impdecsn
      INTO rw_cr_impdecsn;
  IF cr_impdecsn%FOUND AND (rw_cr_impdecsn.idimpdsn <> 2) AND
     (rw_cr_impdecsn.tpregtrb = 1) THEN
      vr_dsmensag := 'Imprimir a Declaração de Optante do Simples Nacional';
      --> Incluir na temptable
      pc_cria_registro_msg(pr_dsmensag             => vr_dsmensag,
                           pr_tab_mensagens_atenda => pr_tab_mensagens_atenda);
  END IF;
  CLOSE cr_impdecsn;
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      pr_des_reto := 'NOK';

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro CADA0004.pc_obtem_mensagens_alerta:'||SQLERRM;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      pr_des_reto := 'NOK';
  END pc_obtem_mensagens_alerta;

  /******************************************************************************/
  /**          Procedure obter dados para o cabeçalho da tela ATENDA           **/
  /******************************************************************************/
  PROCEDURE pc_obtem_cabecalho_atenda( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                      ,pr_nrdctitg IN crapass.nrdctitg%TYPE  --> Numero da conta itg
                                      ,pr_dtinicio IN DATE                   --> Data de incio
                                      ,pr_dtdfinal IN DATE                   --> data final
                                      ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                      ---------- OUT --------
                                      ,pr_tab_cabec OUT typ_tab_cabec                 --> Retorna dados do cabecalho da tela ATENDA
                                      ,pr_des_reto       OUT VARCHAR2                 --> OK ou NOK
                                      ,pr_tab_erro       OUT gene0001.typ_tab_erro) IS

  /* ..........................................................................
    --
    --  Programa : pc_obtem_cabecalho_atenda        Antiga: b1wgen0001.p/obtem-cabecalho
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Outubro/2015.                   Ultima atualizacao: 26/10/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure obter dados para o cabeçalho da tela ATENDA
    --
    --  Alteração : 22/10/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --              01/12/2015 - Carregar o campo cdclcnae da crapass (Jaison/Andrino)
    --
    --              25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
    --                           crapass, crapttl, crapjur
    --                         (Adriano - P339).
    --
    --              23/06/2017 - Ajuste para inclusao do novo tipo de situacao da conta
    --                           "Desligamento por determinação do BACEN"
    --                           ( Jonata - RKAM P364).
    --
    --              20/09/2017 - Ajuste nome do segundo titular para concatenar e/ou.
    --                           PRJ339 - CRM(Odirlei-AMcom)
    --
    --              20/09/2017 - Ajuste nos parametros da procedure fn_dstipcta
    --                           PRJ366 (Lombardi)
    --
    --              16/07/2018 - Novo campo Nome Social (#SCTASK0017525 - Andrey Formigari)
    --
    --              26/10/2018 - P442 - Retorno do Score Behaviour do Cooperado (Marcos-Envolti)
    --
    --              08/11/2018 - Alteração do campo indnivel da tela atenda para nrdgrupo - P484.
    --                           Gabriel Marcos (Mouts).
    --
    -- ..........................................................................*/

    ---------------> CURSORES <----------------
    --> Buscar associado
    CURSOR cr_crapass IS
      SELECT crapass.nrdconta,
             crapass.inpessoa,
             crapass.nrmatric,
             crapass.cdagenci,
             crapass.dtadmiss,
             crapass.nrdctitg,
             crapass.nrctainv,
             crapass.dtadmemp,
             crapass.nmprimtl,
             crapass.dtdemiss,
             crapass.cdsecext,
             crapass.indnivel,
             crapass.cdtipsfx,
             crapass.vllimcre,
             crapass.nrcpfcgc,
             crapass.cdtipcta,
             crapass.cdbcochq,
             crapass.cdsitdct,
             crapass.cdclcnae,
             CASE crapass.flgctitg
               WHEN 2 THEN 'Ativa'
               WHEN 3 THEN 'Inativa'
               ELSE decode(TRIM(crapass.nrdctitg),NULL,NULL,'Em Proc')
             END  dsdctitg,
       (SELECT ttl.nmsocial
                FROM crapttl ttl
               WHERE ttl.cdcooper = pr_cdcooper
                 AND ttl.nrdconta = pr_nrdconta
                 AND ttl.idseqttl = 1) AS nmsocial
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND ((nvl(pr_nrdconta,0) <> 0     AND crapass.nrdconta = pr_nrdconta) OR
              (nvl(pr_nrdctitg,' ') <> ' ' AND upper(crapass.nrdctitg) = upper(pr_nrdctitg)));
    rw_crapass cr_crapass%ROWTYPE;

    --> Contar titulares da conta
    CURSOR cr_crapttl_count IS
      SELECT COUNT(*)
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta;

  -->Busca informações do segundo titular
    CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE
                   ,pr_nrdconta crapttl.nrdconta%TYPE)IS
  SELECT crapttl.nmextttl
    FROM crapttl
   WHERE crapttl.cdcooper = pr_cdcooper
     AND crapttl.nrdconta = pr_nrdconta
     AND crapttl.idseqttl = 2;
    rw_crapttl cr_crapttl%ROWTYPE;

    /* Projeto 484 - Delegados */
    -- Cursor para buscar numero do grupo
    cursor cr_nrgrupo (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                      ,pr_nrcpfcgc in tbevento_pessoa_grupos.nrcpfcgc%type) is
    select substr(dsc.nmdgrupo,3) nrdgrupo
      from tbevento_pessoa_grupos grp
         , tbevento_grupos        dsc
     where grp.cdcooper = pr_cdcooper
       and grp.nrcpfcgc = pr_nrcpfcgc
       and dsc.cdcooper = grp.cdcooper
       and dsc.cdagenci = grp.cdagenci
       and dsc.nrdgrupo = grp.nrdgrupo;
    rw_nrgrupo cr_nrgrupo%rowtype;

    --------------> VARIAVEIS <----------------
    vr_cdcritic   INTEGER;
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;
    vr_des_reto   VARCHAR2(100);

    vr_cdempres   crapttl.cdempres%TYPE;
    vr_cdturnos   crapttl.cdturnos%TYPE;
    vr_dsnatura   crapttl.dsnatura%TYPE;
    vr_idxcab     PLS_INTEGER;
    vr_qttitula   INTEGER;
    vr_nmsegntl   crapttl.nmextttl%TYPE;

  BEGIN
    -- Buscar dados do cooperado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;

    pc_busca_cdempres_ass (pr_cdcooper => pr_cdcooper,
                           pr_inpessoa => rw_crapass.inpessoa,
                           pr_nrdconta => rw_crapass.nrdconta,
                           pr_cdempres => vr_cdempres,
                           pr_cdturnos => vr_cdturnos,
                           pr_dsnatura => vr_dsnatura);

    --> Contar quantidade de titulares da conta
    vr_qttitula := 0;
    IF rw_crapass.inpessoa = 1 THEN

      OPEN cr_crapttl_count;
      FETCH cr_crapttl_count INTO vr_qttitula;
      CLOSE cr_crapttl_count;

      OPEN cr_crapttl(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => rw_crapass.nrdconta);

      FETCH cr_crapttl INTO rw_crapttl;

      IF cr_crapttl%FOUND THEN

        vr_nmsegntl:= 'E/OU '||rw_crapttl.nmextttl;

      END IF;

      CLOSE cr_crapttl;

    ELSE
      vr_qttitula := 1;
    END IF;

    /* Projeto 484 - Delegados */
    -- Buscar grupo do cooperado
    open cr_nrgrupo (pr_cdcooper
                    ,rw_crapass.nrcpfcgc);
    fetch cr_nrgrupo into rw_nrgrupo;
    close cr_nrgrupo;

    --> Carregar temptable de retorno
    vr_idxcab := pr_tab_cabec.count + 1;
    pr_tab_cabec(vr_idxcab).nrmatric := rw_crapass.nrmatric;
    pr_tab_cabec(vr_idxcab).cdagenci := rw_crapass.cdagenci;
    pr_tab_cabec(vr_idxcab).dtadmiss := rw_crapass.dtadmiss;
    pr_tab_cabec(vr_idxcab).nrdctitg := nvl(trim(rw_crapass.nrdctitg),'00000000');
    pr_tab_cabec(vr_idxcab).nrctainv := rw_crapass.nrctainv;
    pr_tab_cabec(vr_idxcab).dtadmemp := rw_crapass.dtadmemp;
    pr_tab_cabec(vr_idxcab).nmprimtl := rw_crapass.nmprimtl;
    pr_tab_cabec(vr_idxcab).nmsegntl := vr_nmsegntl;
    pr_tab_cabec(vr_idxcab).cdclcnae := rw_crapass.cdclcnae;

    pr_tab_cabec(vr_idxcab).dtaltera := fn_ult_dtaltera (pr_cdcooper => pr_cdcooper,  --> Codigo da cooperativa
                                                         pr_nrdconta => pr_nrdconta,  --> Numero da conta
                                                         pr_tpaltera => 1 );          --> Tipo de alteracao, nulo para todos

    pr_tab_cabec(vr_idxcab).dsnatopc := fn_dsnatopc (pr_cdcooper => pr_cdcooper,          --> Codigo da cooperativa
                                                     pr_nrdconta => pr_nrdconta,          --> Numero da conta
                                                     pr_inpessoa => rw_crapass.inpessoa); --> Tipo de pessoa 1- fisico 2-juridico

    pr_tab_cabec(vr_idxcab).nrramfon := fn_nrramfon(pr_cdcooper => pr_cdcooper,          --> Codigo da cooperativa
                                                    pr_nrdconta => pr_nrdconta,          --> Numero da conta
                                                    pr_inpessoa => rw_crapass.inpessoa); --> Tipo de pessoa 1- fisico 2-juridico
    pr_tab_cabec(vr_idxcab).nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc
                                                                 ,pr_inpessoa => rw_crapass.inpessoa);

    pr_tab_cabec(vr_idxcab).dtdemiss := rw_crapass.dtdemiss;
    pr_tab_cabec(vr_idxcab).dsnatura := vr_dsnatura;
    pr_tab_cabec(vr_idxcab).cdsecext := rw_crapass.cdsecext;
    pr_tab_cabec(vr_idxcab).indnivel := rw_crapass.indnivel;

    pr_tab_cabec(vr_idxcab).dstipcta := fn_dstipcta (pr_inpessoa => rw_crapass.inpessoa,  --> Codigo da cooperativa
                                                     pr_cdtipcta => rw_crapass.cdtipcta); --> Tipo de conta

    pr_tab_cabec(vr_idxcab).dssitdct := fn_dssitdct(pr_cdsitdct => rw_crapass.cdsitdct);  --> Codigo da situacao da conta;
    pr_tab_cabec(vr_idxcab).cdsitdct := rw_crapass.cdsitdct;
    pr_tab_cabec(vr_idxcab).cdempres := vr_cdempres;
    pr_tab_cabec(vr_idxcab).cdturnos := nvl(vr_cdturnos,0);
    pr_tab_cabec(vr_idxcab).cdtipsfx := rw_crapass.cdtipsfx;
    pr_tab_cabec(vr_idxcab).nrdconta := rw_crapass.nrdconta;
    pr_tab_cabec(vr_idxcab).vllimcre := rw_crapass.vllimcre;
    pr_tab_cabec(vr_idxcab).inpessoa := rw_crapass.inpessoa;
    pr_tab_cabec(vr_idxcab).qttitula := vr_qttitula;
    pr_tab_cabec(vr_idxcab).dssititg := rw_crapass.dsdctitg;
    pr_tab_cabec(vr_idxcab).nmsocial := rw_crapass.nmsocial;
    -- P442 - Score Behaviour Cooperado
    pr_tab_cabec(vr_idxcab).cdscobeh := risc0005.fn_score_behaviour(pr_cdcooper,pr_nrdconta);

    -- Reciprocidade como piloto para cooperativa
    pr_tab_cabec(vr_idxcab).reciproc := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                  pr_cdcooper => pr_cdcooper,
                                                                  pr_cdacesso => 'RECIPROCIDADE_PILOTO');

    -- P484 - Numero do grupo do cooperado
    pr_tab_cabec(vr_idxcab).nrdgrupo := rw_nrgrupo.nrdgrupo;

    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      pr_des_reto := 'NOK';

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro CADA0004.pc_obtem_cabecalho_atenda:'||SQLERRM;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      pr_des_reto := 'NOK';
  END pc_obtem_cabecalho_atenda;

  /******************************************************************************/
  /**           Procedure para carregar dos dados para a tela ATENDA           **/
  /******************************************************************************/
  PROCEDURE pc_carrega_dados_atenda( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                    ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                    ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Proxima data do movimento
                                    ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE  --> Data anterior do movimento
                                    ,pr_dtiniper IN DATE                   --> Data inicial do periodo
                                    ,pr_dtfimper IN DATE                   --> data final do periodo
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                    ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                    ,pr_nrdctitg IN crapass.nrdctitg%TYPE  --> Numero da conta itg
                                    ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo
                                    ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao

                                    ---------- OUT --------
                                    ,pr_flconven          OUT INTEGER                --> Retorna se aceita convenio
                                    ,pr_tab_cabec         OUT typ_tab_cabec          --> Retorna dados do cabecalho da tela ATENDA
                                    ,pr_tab_comp_cabec    OUT typ_tab_comp_cabec     --> observacoes dos associados
                                    ,pr_tab_valores_conta OUT typ_tab_valores_conta  --> Retorna os valores para a tela ATENDA
                                    ,pr_tab_crapobs       OUT typ_tab_crapobs        --> Observacoes dos associados
                                    ,pr_tab_mensagens_atenda  OUT typ_tab_mensagens_atenda   --> Retorna as mensagens para tela atenda
                                    ,pr_dscritic          OUT VARCHAR2               --> Retornar critica que nao aborta processamento
                                    ,pr_des_reto          OUT VARCHAR2               --> OK ou NOK
                                    ,pr_tab_erro          OUT gene0001.typ_tab_erro) IS

  /* ..........................................................................
    --
    --  Programa : pc_carrega_dados_atenda        Antiga: b1wgen0001.p/carrega_dados_atenda
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Outubro/2015.                   Ultima atualizacao: 15/05/2019
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para carregar dos dados para a tela ATENDA
    --
    --  Alteração : 23/10/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --              23/03/2015 - Adicionar novos parametros na chamada da
    --                           EXTR0002.pc_consulta_lancamento - Melhoria 157 (Lucas Ranghetti)

    --              22/04/2016 - Ajustado problema em que enviava nrdconta nula para as
    --                           funções. Ajuste feito para correção do chamado 430838. (Kelvin)
    --
    --              29/04/2016 - Passar como null dtiniper e dtfimper na chamada da procedure
    --                           EXTR0002.pc_consulta_lancamento (Lucas Ranghetti/Fabricio)
    --
    --              08/06/2016 - Removido subrotina pc_carrega_temps_poupanca, pois as PL TABLES
    --                           carregadas nela nao influenciavam no retorno para a tela ATENDA
    --                           (Douglas - Chamado 454248)
    --
    --              23/06/2016 - P333.1 - Alteração no retorno de valor do seguro por quantidade
    --                           (Marcos-Supero)
    --
    --              09/08/2017 - P364 - Alteração na regra de busca do valor de saldo deposito a vista,
    --                                  irá buscar da LCM pelo LOTE, caso seja maior que 0 irá exibir
    --                                  o valor retornado (Mateus Zimmermann-MoutS)
    --
    --              14/11/2017 - Ajuste para considerar lancamentos de devolucao de capital (Jonata - RKAM P364).
    --
    --              03/12/2017 - Eliminado cursor da craplcm, não será usado (Jonata - RKAM P364).
    --
    --              05/06/2017 - Recuperar informacoes de previdencia (Claudio - CIS Corporate).
    --
    --             15/05/2019 - Merge branch P433 - API de Cobrança (Cechet)
    --
    --             30/05/2019 - Alterado para considerar também a situação 9 quando exibir existencia 
    --                          de portabilidade.  (Renato Darosci - Supero - P485)
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --> Quantidade de folhas de cheque disponiveis para o associado
    CURSOR cr_crapfdc (pr_cdcooper crapfdc.cdcooper%TYPE,
                       pr_nrdconta crapfdc.nrdconta%TYPE) IS
      SELECT COUNT(1)
        FROM crapfdc
       WHERE crapfdc.cdcooper = pr_cdcooper
         AND crapfdc.nrdconta = pr_nrdconta
         AND crapfdc.dtemschq IS NOT NULL
         AND crapfdc.dtretchq IS NOT NULL
         AND crapfdc.tpcheque = 1
         AND crapfdc.incheque IN (0,1,2);

    --> Buscar limite taa
    CURSOR cr_limite_saque IS
      SELECT vllimite_saque
        FROM tbtaa_limite_saque
       WHERE tbtaa_limite_saque.cdcooper = pr_cdcooper
         AND tbtaa_limite_saque.nrdconta = pr_nrdconta;

    --> Buscar pacotes tarifas
    CURSOR cr_pacotes_tarifas IS
      SELECT nrdconta
        FROM tbtarif_contas_pacote
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND flgsituacao = 1
         AND dtcancelamento IS NULL;
    rw_pacotes_tarifas cr_pacotes_tarifas%ROWTYPE;

    --> Buscar informacao previdencia
    CURSOR cr_tbprevidencia_conta IS
      SELECT tbprevidencia_conta.insituac
        FROM tbprevidencia_conta
       WHERE tbprevidencia_conta.cdcooper = pr_cdcooper
         AND tbprevidencia_conta.nrdconta = pr_nrdconta;
    rw_tbprevidencia_conta cr_tbprevidencia_conta%ROWTYPE;

    --> Busca informação Portabilidade de salario
    CURSOR cr_tbcc_portabilidade_envia IS
      SELECT 1
      FROM tbcc_portabilidade_envia
      WHERE tbcc_portabilidade_envia.cdcooper = pr_cdcooper
        AND tbcc_portabilidade_envia.nrdconta = pr_nrdconta
        AND tbcc_portabilidade_envia.idsituacao IN (1,2,3,5,9);

  --> Busca informção da Plataforma de API
  CURSOR cr_checkapi IS
      SELECT 1
        FROM tbapi_cooperado_servico
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND idsituacao_adesao = 1;
     rw_checkapi cr_checkapi%ROWTYPE;

    --------------> TempTable <-----------------
    vr_tab_saldos             EXTR0001.typ_tab_saldos;
    vr_tab_libera_epr         EXTR0001.typ_tab_libera_epr;
    vr_tab_totais_futuros     EXTR0002.typ_tab_totais_futuros;
    vr_tab_lancamento_futuro  EXTR0002.typ_tab_lancamento_futuro;
    vr_tab_saldo_cotas        APLI0002.typ_tab_saldo_cotas;
    vr_tab_conven             typ_tab_conven;
    vr_tab_cartoes            typ_tab_cartoes;
    vr_tab_ocorren            typ_tab_ocorren;
    vr_tab_saldo_rdca         APLI0001.typ_tab_saldo_rdca;
    vr_tab_infoass            typ_tab_infoass;
    vr_tab_cartoes_magneticos typ_tab_cartoes_magneticos;
    vr_tab_seguros            SEGU0001.typ_tab_seguros;
    vr_tab_tot_descontos      DSCT0001.typ_tab_tot_descontos;


    -- TempTables para APLI0001.pc_consulta_poupanca
    vr_tab_conta_bloq APLI0001.typ_tab_ctablq;
    vr_tab_craplpp    APLI0001.typ_tab_craplpp;
    vr_tab_craplrg    APLI0001.typ_tab_craplpp;
    vr_tab_resgate    APLI0001.typ_tab_resgate;
    vr_tab_dados_rpp  APLI0001.typ_tab_dados_rpp;
    
    --------------> VARIAVEIS <-----------------
    vr_cdcritic     INTEGER;
    vr_dscritic     VARCHAR2(1000);
    vr_exc_erro     EXCEPTION;
    vr_tab_erro     gene0001.typ_tab_erro;
    vr_des_reto     VARCHAR2(100);

    vr_dsorigem     VARCHAR2(50);
    vr_dstransa     VARCHAR2(200);
    vr_nrdrowid     ROWID;

    vr_nrdconta     crapass.nrdconta%TYPE;
    vr_vlstotal     NUMBER   := 0;
    vr_vllautom     NUMBER   := 0;
    vr_vlsldcap     NUMBER   := 0;
    vr_qtconven     NUMBER   := 0;
    vr_flgativo     INTEGER  := 0;
    vr_flgocorr     INTEGER  := 0;
    vr_nrctrhcj     NUMBER   := 0;
    vr_flgliber     INTEGER  := 0;
    vr_vltotccr     NUMBER   := 0;
    vr_dstextab     craptab.dstextab%TYPE;
    vr_inusatab     BOOLEAN;
    vr_vlsldepr     NUMBER   := 0;
    vr_vltotpre     NUMBER   := 0;
    vr_qtprecal     INTEGER  := 0;
    vr_vlsldtot     NUMBER   := 0;
    vr_ind          BINARY_INTEGER;
    vr_vlsldapl     NUMBER   := 0;
    vr_vlsldrgt     NUMBER   := 0;
    vr_vlsldinv     NUMBER   := 0;
    vr_percenir     NUMBER   := 0;
    vr_vlsldppr     NUMBER   := 0;
    vr_vllimite     NUMBER   := 0;
    vr_qtfolhas     INTEGER  := 0;
    vr_insituacprvd NUMBER := NULL;
    vr_vllimite_saque NUMBER := 0;
    vr_dssitura     VARCHAR2(100) := NULL;
    vr_dssitnet     VARCHAR2(100) := NULL;
    vr_qtcarmag     INTEGER  := 0;
    vr_cdempres     crapttl.cdempres%type;
    vr_qtsegass     INTEGER  := 0;
    vr_vltotseg     NUMBER   := 0;
    vr_vltotdsc     NUMBER   := 0;
    vr_flgbloqt     INTEGER  := 0;
    vr_vldevolver   NUMBER   := 0;
    vr_vlcapital    NUMBER   := 0;
    vr_vlpago       NUMBER   := 0;
    vr_dtinicio_credito DATE;
    vr_tab_cpt      CLOB;
    vr_idxval       PLS_INTEGER;
    vr_valor_deposito_vista NUMBER := 0;
    vr_permportab   NUMBER  := 0;


    BEGIN
    -- Atribuir numero de conta
    vr_nrdconta := pr_nrdconta;

    pr_tab_cabec.delete;
    pr_tab_comp_cabec.delete;
    pr_tab_valores_conta.delete;
    pr_tab_crapobs.delete;
    pr_tab_erro.delete;

    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Obter dados para tela ATENDA.';

    -- Leitura do calendário da cooperativa, para alguns procedimentos que precisam
    -- receber como parametro
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;


    -- Validacao de operador e conta migrada
    CADA0001.pc_valida_operador_migrado(pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_cdagenci => pr_cdagenci
                                       ,pr_nrdconta => vr_nrdconta
                                       ,pr_tab_erro => vr_tab_erro);

    -- Verifica se houve o retorno de erros
    IF vr_tab_erro.count > 0 THEN
      -- Retornar a mensagem de erro nos parametros
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    --> Validar restrição do operador
    vr_dscritic := fn_valida_restricao_ope( pr_cdoperad => pr_cdoperad --> Codigo do operador
                                           ,pr_nrdconta => vr_nrdconta --> Numero da conta
                                           ,pr_nrdctitg => pr_nrdctitg --> Numero da conta
                                           ,pr_cdcooper => pr_cdcooper); --> Codigo da cooperativa
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;


    --> Dados da conta para compor cabecalho da tela
    pc_obtem_cabecalho_atenda( pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                              ,pr_cdagenci => pr_cdagenci --> Codigo de agencia
                              ,pr_nrdcaixa => pr_nrdcaixa --> Numero do caixa
                              ,pr_cdoperad => pr_cdoperad --> Codigo do operador
                              ,pr_nrdconta => vr_nrdconta --> Numero da conta
                              ,pr_nrdctitg => pr_nrdctitg --> Numero da conta itg
                              ,pr_dtinicio => pr_dtiniper --> Data de incio
                              ,pr_dtdfinal => pr_dtfimper --> data final
                              ,pr_idorigem => pr_idorigem --> Identificado de oriem
                              ---------- OUT --------
                              ,pr_tab_cabec=> pr_tab_cabec --> Retorna dados do cabecalho da tela ATENDA
                              ,pr_des_reto => vr_des_reto  --> OK ou NOK
                              ,pr_tab_erro => vr_tab_erro);--> Temptable de erros

    IF vr_des_reto = 'NOK' THEN
      -- Retornar a mensagem de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    --> caso esteja zerada, alterar pela retornada da funcao
    IF nvl(pr_nrdconta,0) = 0 THEN
      IF pr_tab_cabec.exists(pr_tab_cabec.first)THEN
        vr_nrdconta := pr_tab_cabec(pr_tab_cabec.first).nrdconta;
      END IF;
    END IF;

    --> Completa dados do cabecalho da tela atenda
    pc_completa_cab_atenda ( pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                            ,pr_cdagenci => pr_cdagenci --> Codigo de agencia
                            ,pr_nrdcaixa => pr_nrdcaixa --> Numero do caixa
                            ,pr_cdoperad => pr_cdoperad --> Codigo do operador
                            ,pr_nrdconta => vr_nrdconta --> Numero da conta
                            ,pr_nrdctitg => pr_nrdctitg --> Conta itg
                            ,pr_dtinicio => pr_dtiniper --> Data inicio periodo
                            ,pr_idorigem => pr_idorigem --> Identificado de oriem
                            ---------- OUT --------
                            ,pr_tab_comp_cabec => pr_tab_comp_cabec --> observacoes dos associados
                            ,pr_des_reto       => vr_des_reto       --> OK ou NOK
                            ,pr_tab_erro       => vr_tab_erro);

    IF vr_des_reto = 'NOK' THEN
      -- Retornar a mensagem de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    --> Procedimento para buscar informaçoes de depositos avista
    EXTR0001.pc_carrega_dep_vista(pr_cdcooper  => pr_cdcooper   --> Codigo da cooperativa
                                 ,pr_cdagenci  => pr_cdagenci   --> Código da agencia
                                 ,pr_nrdcaixa  => pr_nrdcaixa   --> Numero do caixa
                                 ,pr_cdoperad  => pr_cdoperad   --> Codigo do operador
                                 ,pr_nrdconta  => vr_nrdconta   --> Numero da conta do cooperado
                                 ,pr_dtmvtolt  => pr_dtmvtolt   --> Data do movimento
                                 ,pr_idorigem  => pr_idorigem   --> Id origem
                                 ,pr_idseqttl  => pr_idseqttl   --> Sequencial do titular
                                 ,pr_nmdatela  => pr_nmdatela   --> Nome da tela
                                 ,pr_flgerlog  => 'N'           --> Identificador se deve gerar log S-Sim e N-Nao
                                 -------> OUT <------
                                 ,pr_tab_saldos     => vr_tab_saldos     --> Retornar saldos
                                 ,pr_tab_libera_epr => vr_tab_libera_epr --> Retornar dados de liberacao de epr
                                 ,pr_des_reto       => vr_des_reto       --> Retorno OK/NOK
                                 ,pr_tab_erro       => vr_tab_erro );    --> Retorna os erros

    IF vr_des_reto = 'NOK' THEN
      -- Retornar a mensagem de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    --> Extrair valor
    IF vr_tab_saldos.exists(vr_tab_saldos.first) THEN
      vr_vlstotal := vr_tab_saldos(vr_tab_saldos.first).vlstotal;
    END IF;

    --Consultar os lancamentos futuros
    EXTR0002.pc_consulta_lancamento(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                   ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                   ,pr_nrdcaixa => pr_nrdcaixa   --Numero do Caixa
                                   ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                   ,pr_nrdconta => vr_nrdconta   --Numero da Conta
                                   ,pr_idorigem => pr_idorigem   --Origem dos Dados
                                   ,pr_idseqttl => pr_idseqttl   --Sequencial do Titular
                                   ,pr_nmdatela => pr_nmdatela   --Nome da Tela
                                   ,pr_flgerlog => FALSE         --Sem log
                                   ,pr_dtiniper => NULL          -- Data inicio filtro
                                   ,pr_dtfimper => NULL          -- Data Final Filtro
                                   ,pr_indebcre => ''            -- Deb/Cre
                                   ,pr_des_reto => vr_des_reto   --OK ou NOK
                                   ,pr_tab_erro => pr_tab_erro   --Tabela de Erros
                                   ,pr_tab_totais_futuros    => vr_tab_totais_futuros  --> Vetor para o retorno das informações
                                   ,pr_tab_lancamento_futuro => vr_tab_lancamento_futuro);  --> Vetor para o retorno das informações
    -- Se houve retorno não Ok
    IF vr_des_reto = 'NOK' THEN
      -- Retornar a mensagem de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    --> Extrair valor
    IF vr_tab_totais_futuros.exists(vr_tab_totais_futuros.first) THEN
      vr_vllautom := vr_tab_totais_futuros(vr_tab_totais_futuros.first).vllautom;
    END IF;

    -- Obter Saldo Das Cotas do Associado
    APLI0002.pc_obtem_saldo_cotas (pr_cdcooper => pr_cdcooper       --Codigo Cooperativa
                                  ,pr_cdagenci => pr_cdagenci       --Codigo Agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa       --Numero do Caixa
                                  ,pr_cdoperad => pr_cdoperad       --Codigo operador
                                  ,pr_nmdatela => pr_nmdatela       --Nome da Tela
                                  ,pr_idorigem => pr_idorigem       --Origem da Execucao
                                  ,pr_nrdconta => vr_nrdconta       --Numero da Conta
                                  ,pr_idseqttl => pr_idseqttl       --Sequencial do Titular
                                  ,pr_dtmvtolt => pr_dtmvtolt       --Data do Movimento
                                  ,pr_tab_saldo_cotas => vr_tab_saldo_cotas --Tabela de Cotas
                                  ,pr_tab_erro => vr_tab_erro               --Tabela Erros
                                  ,pr_dscritic => vr_dscritic);             --Descricao Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Extrair valor
    IF vr_tab_saldo_cotas.exists(vr_tab_saldo_cotas.first) THEN
      vr_vlsldcap := vr_tab_saldo_cotas(vr_tab_saldo_cotas.first).vlsldcap;
    END IF;

    -->Procedure para lista convenios autorizados para debito
    pc_lista_conven( pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                    ,pr_cdagenci => pr_cdagenci  --> Codigo de agencia
                    ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa
                    ,pr_cdoperad => pr_cdoperad  --> Codigo do operador
                    ,pr_nrdconta => vr_nrdconta  --> Numero da conta
                    ,pr_idorigem => pr_idorigem  --> Identificado de oriem
                    ,pr_idseqttl => pr_idseqttl  --> sequencial do titular
                    ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                    ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                    ,pr_flgerlog => 'N'          --> identificador se deve gerar log S-Sim e N-Nao
                    ------ OUT ------
                    ,pr_qtconven   =>  vr_qtconven   --> retorna quantidade de convenios
                    ,pr_tab_conven =>  vr_tab_conven --> retorna temptable com os dados dos convenios
                    ,pr_cdcritic   =>  vr_cdcritic
                    ,pr_dscritic   =>  vr_dscritic);


    --> Procedure para listar cartoes do cooperado
    pc_lista_cartoes(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                    ,pr_cdagenci => pr_cdagenci --> Codigo de agencia
                    ,pr_nrdcaixa => pr_nrdcaixa --> Numero do caixa
                    ,pr_cdoperad => pr_cdoperad --> Codigo do operador
                    ,pr_nrdconta => vr_nrdconta --> Numero da conta
                    ,pr_idorigem => pr_idorigem --> Identificado de oriem
                    ,pr_idseqttl => pr_idseqttl --> sequencial do titular
                    ,pr_nmdatela => pr_nmdatela --> Nome da tela
                    ,pr_flgerlog => 'N'  --> identificador se deve gerar log S-Sim e N-Nao
                    ,pr_dtmvtolt => pr_dtmvtolt --> Data da cooperativa
                    ------ OUT ------
                    ,pr_flgativo     => vr_flgativo          --> Retorna situação 1-ativo 2-inativo
                    ,pr_nrctrhcj     => vr_nrctrhcj          --> Retorna numero do contrato
                    ,pr_flgliber     => vr_flgliber          --> Retorna se esta liberado 1-sim 2-nao
                    ,pr_vltotccr     => vr_vltotccr          --> retorna total de limite do cartao
                    ,pr_tab_cartoes  => vr_tab_cartoes   --> retorna temptable com os dados dos convenios
                    ,pr_des_reto     => vr_des_reto                    --> OK ou NOK
                    ,pr_tab_erro     => vr_tab_erro);

    -- Se houve retorno não Ok
    IF vr_des_reto = 'NOK' THEN
      -- Retornar a mensagem de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    --> Procedure para listar ocorrencias do cooperado
    pc_lista_ocorren(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                    ,pr_cdagenci => pr_cdagenci --> Codigo de agencia
                    ,pr_nrdcaixa => pr_nrdcaixa --> Numero do caixa
                    ,pr_cdoperad => pr_cdoperad --> Codigo do operador
                    ,pr_nrdconta => vr_nrdconta --> Numero da conta
                    ,pr_rw_crapdat => rw_crapdat--> Data da cooperativa
                    ,pr_idorigem => pr_idorigem --> Identificado de oriem
                    ,pr_idseqttl => pr_idseqttl --> sequencial do titular
                    ,pr_nmdatela => pr_nmdatela --> Nome da tela
                    ,pr_flgerlog => 'N'         --> identificador se deve gerar log S-Sim e N-Nao
                    ------ OUT ------
                    ,pr_tab_ocorren  => vr_tab_ocorren   --> retorna temptable com os dados dos convenios
                    ,pr_des_reto     => vr_des_reto          --> OK ou NOK
                    ,pr_tab_erro     => vr_tab_erro );

    -- Se houve retorno não Ok
    IF vr_des_reto = 'NOK' THEN
      -- Retornar a mensagem de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    --> Extrair valor
    IF vr_tab_ocorren.exists(vr_tab_ocorren.first) THEN
      vr_flgocorr := vr_tab_ocorren(vr_tab_ocorren.first).flgocorr;
    END IF;

    --Verificar se usa tabela juros
    vr_dstextab := TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TAXATABELA'
                                              ,pr_tpregist => 0);
    -- Se a primeira posição do campo dstextab for diferente de zero
    vr_inusatab := SUBSTR(vr_dstextab,1,1) != '0';

    -- Buscar saldo devedor
    EMPR0001.pc_saldo_devedor_epr (pr_cdcooper   => pr_cdcooper     --> Cooperativa conectada
                                  ,pr_cdagenci   => pr_cdagenci     --> Codigo da agencia
                                  ,pr_nrdcaixa   => pr_nrdcaixa     --> Numero do caixa
                                  ,pr_cdoperad   => pr_cdoperad     --> Codigo do operador
                                  ,pr_nmdatela   => pr_nmdatela     --> Nome datela conectada
                                  ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                                  ,pr_nrdconta   => vr_nrdconta     --> Conta do associado
                                  ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                                  ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parametro (CRAPDAT)
                                  ,pr_nrctremp   => 0               --> Numero contrato emprestimo
                                  ,pr_cdprogra   => 'B1WGEN0001'    --> Programa conectado
                                  ,pr_inusatab   => vr_inusatab     --> Indicador de utilizacão da tabela
                                  ,pr_flgerlog   => 'N'             --> Gerar log S/N
                                  ,pr_vlsdeved   => vr_vlsldepr     --> Saldo devedor calculado
                                  ,pr_vltotpre   => vr_vltotpre     --> Valor total das prestacães
                                  ,pr_qtprecal   => vr_qtprecal     --> Parcelas calculadas
                                  ,pr_des_reto   => vr_des_reto     --> Retorno OK / NOK
                                  ,pr_tab_erro   => vr_tab_erro);   --> Tabela com possives erros

    -- Se houve retorno de erro
    IF vr_des_reto = 'NOK' THEN
      -- Extrair o codigo e critica de erro da tabela de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    --Obtem Dados Aplicacoes
    APLI0002.pc_obtem_dados_aplicacoes (pr_cdcooper    => pr_cdcooper          --Codigo Cooperativa
                                       ,pr_cdagenci    => pr_cdagenci          --Codigo Agencia
                                       ,pr_nrdcaixa    => pr_nrdcaixa          --Numero do Caixa
                                       ,pr_cdoperad    => pr_cdoperad          --Codigo Operador
                                       ,pr_nmdatela    => pr_nmdatela          --Nome da Tela
                                       ,pr_idorigem    => pr_idorigem          --Origem dos Dados
                                       ,pr_nrdconta    => vr_nrdconta          --Numero da Conta do Associado
                                       ,pr_idseqttl    => pr_idseqttl          --Sequencial do Titular
                                       ,pr_nraplica    => 0                    --Numero da Aplicacao
                                       ,pr_cdprogra    => pr_nmdatela          --Nome da Tela
                                       ,pr_flgerlog    => 0 /*FALSE*/          --Imprimir log
                                       ,pr_dtiniper    => NULL                 --Data Inicio periodo
                                       ,pr_dtfimper    => NULL                 --Data Final periodo
                                       ,pr_vlsldapl    => vr_vlsldtot          --Saldo da Aplicacao
                                       ,pr_tab_saldo_rdca  => vr_tab_saldo_rdca    --Tipo de tabela com o saldo RDCA
                                       ,pr_des_reto    => vr_des_reto          --Retorno OK ou NOK
                                       ,pr_tab_erro    => vr_tab_erro);        --Tabela de Erros
    --Se retornou erro
    IF vr_des_reto = 'NOK' THEN
      --Se possuir erro na temp-table
      IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
          vr_dscritic := 'Nao foi possivel carregar o aplicacoes.';
      END IF;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    -- loop sobre a tabela de saldo
    vr_ind := vr_tab_saldo_rdca.first;
    WHILE vr_ind IS NOT NULL LOOP
      -- Somar o valor de resgate
      vr_vlsldapl := vr_vlsldapl + vr_tab_saldo_rdca(vr_ind).sldresga;

      vr_ind := vr_tab_saldo_rdca.next(vr_ind);
    END LOOP;

    --> Buscar saldo das aplicacoes
    APLI0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                      ,pr_cdoperad => pr_cdoperad   --> Código do Operador
                                      ,pr_nmdatela => pr_nmdatela   --> Nome da Tela
                                      ,pr_idorigem => pr_idorigem   --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                      ,pr_nrdconta => vr_nrdconta   --> Número da Conta
                                      ,pr_idseqttl => pr_idseqttl   --> Titular da Conta
                                      ,pr_nraplica => 0             --> Número da Aplicação / Parâmetro Opcional
                                      ,pr_dtmvtolt => pr_dtmvtolt   --> Data de Movimento
                                      ,pr_cdprodut => 0             --> Código do Produto -–> Parâmetro Opcional
                                      ,pr_idblqrgt => 1             --> Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas)
                                      ,pr_idgerlog => 0             --> Identificador de Log (0 – Não / 1 – Sim)
                                      ,pr_vlsldtot => vr_vlsldtot   --> Saldo Total da Aplicação
                                      ,pr_vlsldrgt => vr_vlsldrgt   --> Saldo Total para Resgate
                                      ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                      ,pr_dscritic => vr_dscritic); --> Descrição da crítica

    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    vr_vlsldapl := vr_vlsldapl + vr_vlsldrgt;

    --Funcao para obter saldo da conta investimento
    vr_vlsldinv := fn_saldo_invetimento
                             ( pr_cdcooper => pr_cdcooper   --> Codigo da cooperativa
                              ,pr_cdagenci => pr_cdagenci  --> Codigo de agencia
                              ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa
                              ,pr_cdoperad => pr_cdoperad  --> Codigo do operador
                              ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                              ,pr_idorigem => pr_idorigem  --> Identificado de oriem
                              ,pr_nrdconta => vr_nrdconta  --> Numero da conta
                              ,pr_idseqttl => pr_idseqttl  --> sequencial do titular
                              ,pr_dtmvtolt => pr_dtmvtolt); --> Data da cooperativa



    -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
    vr_percenir:= GENE0002.fn_char_para_number
                        (TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'CONFIG'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'PERCIRAPLI'
                                                   ,pr_tpregist => 0));

    -- Foi identificado que as PL TABLES vr_tab_conta_bloq, vr_tab_craplpp, vr_tab_craplrg, vr_tab_resgate
    -- nao sao utilizadas para calcular o valor do saldo de poupanca programada (vr_vlsldppr) que eh o unico
    -- campo carregado na Atenda
    -- As informacoes da PL TABLE vr_tab_dados_rpp nao sao enviados para a ATENDA
    -- por esse motivo as PL TABLES vr_tab_conta_bloq, vr_tab_craplpp, vr_tab_craplrg, vr_tab_resgate
    -- e por questao de performace elas nao serao carregadas

    -- Previdencia
    OPEN cr_tbprevidencia_conta;
    FETCH cr_tbprevidencia_conta INTO rw_tbprevidencia_conta;

    IF cr_tbprevidencia_conta%FOUND THEN
      vr_insituacprvd := rw_tbprevidencia_conta.insituac;
    END IF;
    CLOSE cr_tbprevidencia_conta;

    -- Portabilidade de salario
    OPEN cr_tbcc_portabilidade_envia;
    FETCH cr_tbcc_portabilidade_envia INTO vr_permportab;
    CLOSE cr_tbcc_portabilidade_envia;

    --Executar rotina consulta poupanca
    apli0001.pc_consulta_poupanca (pr_cdcooper => pr_cdcooper            --> Cooperativa
                                  ,pr_cdagenci => pr_cdagenci            --> Codigo da Agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa            --> Numero do caixa
                                  ,pr_cdoperad => pr_cdoperad            --> Codigo do Operador
                                  ,pr_idorigem => pr_idorigem            --> Identificador da Origem
                                  ,pr_nrdconta => vr_nrdconta            --> Nro da conta associado
                                  ,pr_idseqttl => pr_idseqttl            --> Identificador Sequencial
                                  ,pr_nrctrrpp => 0                      --> Contrato Poupanca Programada
                                  ,pr_dtmvtolt => pr_dtmvtolt            --> Data do movimento atual
                                  ,pr_dtmvtopr => pr_dtmvtopr            --> Data do proximo movimento
                                  ,pr_inproces => pr_inproces            --> Indicador de processo
                                  ,pr_cdprogra => pr_nmdatela            --> Nome do programa chamador
                                  ,pr_flgerlog => FALSE                  --> Flag erro log
                                  ,pr_percenir => vr_percenir            --> % IR para Calculo Poupanca
                                  ,pr_tab_craptab => vr_tab_conta_bloq   --> Tipo de tabela de Conta Bloqueada
                                  ,pr_tab_craplpp => vr_tab_craplpp      --> Tipo de tabela com lancamento poupanca
                                  ,pr_tab_craplrg => vr_tab_craplrg      --> Tipo de tabela com resgates
                                  ,pr_tab_resgate => vr_tab_resgate      --> Tabela com valores dos resgates das contas por aplicacao
                                  ,pr_vlsldrpp    => vr_vlsldppr         --> Valor saldo poupanca programada
                                  ,pr_retorno     => vr_des_reto         --> Descricao de erro ou sucesso OK/NOK
                                  ,pr_tab_dados_rpp => vr_tab_dados_rpp  --> Poupancas Programadas
                                  ,pr_tab_erro      => vr_tab_erro);     --> Saida com erros;
    --Se retornou erro
    IF vr_des_reto = 'NOK' THEN
      -- Extrair o codigo e critica de erro da tabela de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    --> Funcao para obter valor do limite de credito
    vr_vllimite := fn_valor_limite_credito ( pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                                            ,pr_cdagenci => pr_cdagenci --> Codigo de agencia
                                            ,pr_nrdcaixa => pr_nrdcaixa --> Numero do caixa
                                            ,pr_cdoperad => pr_cdoperad --> Codigo do operador
                                            ,pr_nmdatela => pr_nmdatela --> Nome da tela
                                            ,pr_idorigem => pr_idorigem --> Identificado de oriem
                                            ,pr_nrdconta => vr_nrdconta --> Numero da conta
                                            ,pr_idseqttl => pr_idseqttl --> sequencial do titular
                                            ,pr_flgerlog => 'N'         --> identificador se deve gerar log S-Sim e N-Nao
                                            ,pr_dtmvtolt => pr_dtmvtolt --> Data da cooperativa
                                            ,pr_des_reto => vr_des_reto --> OK ou NOK
                                            ,pr_tab_erro => vr_tab_erro);

    --Se retornou erro
    IF vr_des_reto = 'NOK' THEN
      -- Extrair o codigo e critica de erro da tabela de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    --> Quantidade de folhas de cheque disponiveis para o associado
    OPEN cr_crapfdc (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => vr_nrdconta);
    FETCH cr_crapfdc INTO vr_qtfolhas;
    CLOSE cr_crapfdc;

    --> Situacao da senha do Tele-Atendimento e InterneBank
    vr_dssitura := fn_situacao_senha(pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                                    ,pr_cdagenci => pr_cdagenci  --> Codigo de agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa
                                    ,pr_cdoperad => pr_cdoperad  --> Codigo do operador
                                    ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                                    ,pr_idorigem => pr_idorigem  --> Identificado de oriem
                                    ,pr_nrdconta => vr_nrdconta  --> Numero da conta
                                    ,pr_tpdsenha => 2 -- URA     --> tipo de senha
                                    ,pr_idseqttl => pr_idseqttl);--> sequencial do titular

    vr_dssitnet := fn_situacao_senha(pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                                    ,pr_cdagenci => pr_cdagenci  --> Codigo de agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa
                                    ,pr_cdoperad => pr_cdoperad  --> Codigo do operador
                                    ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                                    ,pr_idorigem => pr_idorigem  --> Identificado de oriem
                                    ,pr_nrdconta => vr_nrdconta  --> Numero da conta
                                    ,pr_tpdsenha => 1 -- Internet--> tipo de senha
                                    ,pr_idseqttl => pr_idseqttl);--> sequencial do titular

    --> Saldo Lancamentos futuros
    vr_vllautom := vr_vllautom + vr_vlstotal;

    --> obter mensagens de alerta para uma conta
    pc_obtem_mensagens_alerta( pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                              ,pr_cdagenci => pr_cdagenci  --> Codigo de agencia
                              ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa
                              ,pr_cdoperad => pr_cdoperad  --> Codigo do operador
                              ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                              ,pr_idorigem => pr_idorigem  --> Identificado de oriem
                              ,pr_nrdconta => vr_nrdconta  --> Numero da conta
                              ,pr_idseqttl => pr_idseqttl  --> Sequencial do titular
                              ,pr_rw_crapdat => rw_crapdat --> Data da cooperativa
                              ---------- OUT --------
                              ,pr_tab_mensagens_atenda => pr_tab_mensagens_atenda  --> Retorna as mensagens para tela atenda
                              ,pr_des_reto             => vr_des_reto              --> OK ou NOK
                              ,pr_tab_erro             => vr_tab_erro);

    --Se retornou erro
    IF vr_des_reto = 'NOK' THEN
      -- Extrair o codigo e critica de erro da tabela de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    --> Busca dos dados do associado
    pc_busca_dados_associado ( pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                              ,pr_cdagenci => pr_cdagenci  --> Codigo de agencia
                              ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa
                              ,pr_cdoperad => pr_cdoperad  --> Codigo do operador
                              ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                              ,pr_idorigem => pr_idorigem  --> Identificado de oriem
                              ,pr_nrdconta => vr_nrdconta  --> Numero da conta
                              ,pr_nrseqdig => 0            --> sequencial do titular
                              ,pr_cddopcao => 'C'          --> opcao de busca
                              ,pr_flgerlog => 'N'  --> identificador se deve gerar log S-Sim e N-Nao
                              ,pr_dtmvtolt => pr_dtmvtolt  --> Data da cooperativa
                              ---------- OUT --------
                              ,pr_tab_infoass => vr_tab_infoass --> Temptable com dados associados
                              ,pr_tab_crapobs => pr_tab_crapobs --> observacoes dos associados
                              ,pr_des_reto    => vr_des_reto    --> OK ou NOK
                              ,pr_tab_erro    => vr_tab_erro);

    --Se retornou erro
    IF vr_des_reto = 'NOK' THEN
      -- Extrair o codigo e critica de erro da tabela de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    --> Qtdade de Cartoes Magneticos
    pc_obtem_cartoes_magneticos( pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                                ,pr_cdagenci => pr_cdagenci  --> Codigo de agencia
                                ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa
                                ,pr_cdoperad => pr_cdoperad  --> Codigo do operador
                                ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                                ,pr_idorigem => pr_idorigem  --> Identificado de oriem
                                ,pr_nrdconta => vr_nrdconta  --> Numero da conta
                                ,pr_idseqttl => pr_idseqttl  --> sequencial do titular
                                ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                                ,pr_flgerlog => 'N'          --> identificador se deve gerar log S-Sim e N-Nao
                                ------ OUT ------
                                ,pr_qtcarmag               => vr_qtcarmag                     --> retorna quantidade de cartoes
                                ,pr_tab_cartoes_magneticos => vr_tab_cartoes_magneticos  --> retorna temptable com os dados dos cartoes
                                ,pr_des_reto               => vr_des_reto       --> OK ou NOK
                                ,pr_tab_erro               => vr_tab_erro);


    --> Buscar Dados do Seguro
    SEGU0001.pc_buscar_seguros ( pr_cdcooper  => pr_cdcooper        -- Cooperativa
                                ,pr_cdagenci  => pr_cdagenci        -- Agencia
                                ,pr_nrdcaixa  => pr_nrdcaixa        -- Numero Caixa
                                ,pr_cdoperad  => pr_cdoperad        -- Operador
                                ,pr_dtmvtolt  => pr_dtmvtolt        -- Data Movimento
                                ,pr_nrdconta  => vr_nrdconta        -- Numero Conta
                                ,pr_idseqttl  => pr_idseqttl        -- Sequencial Titular
                                ,pr_idorigem  => pr_idorigem        -- Origem Informacao
                                ,pr_nmdatela  => pr_nmdatela        -- Programa Chamador
                                ,pr_flgerlog  => FALSE              -- Escrever Erro Log
                                ,pr_cdempres  => vr_cdempres        -- Codigo Empresa
                                ,pr_tab_seguros => vr_tab_seguros   -- Tabela de Seguros
                                ,pr_qtsegass => vr_qtsegass         -- Qdade Seguros Associado
                                ,pr_vltotseg => vr_vltotseg         -- Valor Total Segurado
                                ,pr_des_erro => vr_des_reto         -- Descricao Erro
                                ,pr_tab_erro => vr_tab_erro);       -- Tabela Erros

    --> Buscar seguros novos incrementando na quantidade total
    vr_qtsegass := vr_qtsegass + tela_atenda_seguro.fn_qtd_seguros_novos(pr_cdcooper,pr_nrdconta);

    --> Buscar a soma total de descontos (titulos + cheques)  */
    DSCT0001.pc_busca_total_descontos(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                     ,pr_cdagenci => pr_cdagenci  --> Codigo da agencia
                                     ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa
                                     ,pr_cdoperad => pr_cdoperad  --> codigo do operador
                                     ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                                     ,pr_nrdconta => vr_nrdconta  --> Numero da conta
                                     ,pr_idseqttl => pr_idseqttl  --> idseqttl
                                     ,pr_idorigem => pr_idorigem  --> Codigo da origem
                                     ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                                     ,pr_flgerlog => 'N'          --> identificador se deve gerar log S-Sim e N-Nao
                                     ,pr_cdcritic => vr_cdcritic  --> Código da crítica
                                     ,pr_dscritic => vr_dscritic  --> Descrição da crítica
                                     ,pr_tab_tot_descontos => vr_tab_tot_descontos); --Totais de desconto

    --> Buscar valor total de Descontos
    IF vr_tab_tot_descontos.exists(vr_tab_tot_descontos.first) THEN
      vr_vltotdsc := nvl(vr_tab_tot_descontos(vr_tab_tot_descontos.first).vltotdsc,0);
    END IF;

    --> Retorna se o Cooperado possui cadastro de emissao bloqueto ativo
    vr_flgbloqt := COBR0001.fn_verif_ceb_ativo (pr_cdcooper => pr_cdcooper   -- Codigo da cooperativa
                                               ,pr_nrdconta => vr_nrdconta); -- Numero da conta do cooperado


    vr_vllimite_saque := 0;

    /* Busca o valor de limite de saque */
    OPEN cr_limite_saque;
    FETCH cr_limite_saque INTO vr_vllimite_saque;
    CLOSE cr_limite_saque;

    -- Realiza a chamada da rotina
    pc_buscar_tbcota_devol (pr_cdcooper         => pr_cdcooper
                           ,pr_nrdconta         => pr_nrdconta
                           ,pr_tpdevolucao      => 3
                           ,pr_vlcapital        => vr_vlcapital
                           ,pr_dtinicio_credito => vr_dtinicio_credito
                           ,pr_vlpago           => vr_vlpago
                           ,pr_cdcritic         => vr_cdcritic
                           ,pr_dscritic         => vr_dscritic);



    vr_vldevolver := nvl(vr_vlcapital,0) - nvl(vr_vlpago,0);

    vr_vlcapital:= 0;
    vr_vlpago:=0;

    -- Realiza a chamada da rotina
    pc_buscar_tbcota_devol (pr_cdcooper         => pr_cdcooper
                           ,pr_nrdconta         => pr_nrdconta
                           ,pr_tpdevolucao      => 4
                           ,pr_vlcapital        => vr_vlcapital
                           ,pr_dtinicio_credito => vr_dtinicio_credito
                           ,pr_vlpago           => vr_vlpago
                           ,pr_cdcritic         => vr_cdcritic
                           ,pr_dscritic         => vr_dscritic);

    vr_vldevolver := nvl(vr_vldevolver,0) + (nvl(vr_vlcapital,0) - nvl(vr_vlpago,0));

    --> Cria TEMP-TABLE com valores referente a conta
    vr_idxval := pr_tab_valores_conta.count + 1;

    pr_tab_valores_conta(vr_idxval).vlsldcap := vr_vlsldcap;
    pr_tab_valores_conta(vr_idxval).vlsldepr := nvl(vr_vlsldepr,0);
    pr_tab_valores_conta(vr_idxval).vlsldapl := vr_vlsldapl;
    pr_tab_valores_conta(vr_idxval).vlsldinv := vr_vlsldinv;
    pr_tab_valores_conta(vr_idxval).vlsldppr := nvl(vr_vlsldppr,0);
    pr_tab_valores_conta(vr_idxval).vllimite := vr_vllimite;
    pr_tab_valores_conta(vr_idxval).qtfolhas := vr_qtfolhas;
    pr_tab_valores_conta(vr_idxval).qtconven := vr_qtconven;
    pr_tab_valores_conta(vr_idxval).flgocorr := vr_flgocorr;
    pr_tab_valores_conta(vr_idxval).dssitura := vr_dssitura;
    pr_tab_valores_conta(vr_idxval).vllautom := vr_vllautom;
    pr_tab_valores_conta(vr_idxval).dssitnet := vr_dssitnet;
    pr_tab_valores_conta(vr_idxval).vlstotal := vr_vlstotal;
    pr_tab_valores_conta(vr_idxval).vltotpre := nvl(vr_vltotpre,0);
    pr_tab_valores_conta(vr_idxval).vltotccr := vr_vltotccr;
    pr_tab_valores_conta(vr_idxval).qtcarmag := vr_qtcarmag;
    pr_tab_valores_conta(vr_idxval).qttotseg := vr_qtsegass;
    pr_tab_valores_conta(vr_idxval).vltotseg := vr_vltotseg;
    pr_tab_valores_conta(vr_idxval).vltotdsc := vr_vltotdsc;
    pr_tab_valores_conta(vr_idxval).flgbloqt := vr_flgbloqt;
    pr_tab_valores_conta(vr_idxval).vllimite_saque := nvl(vr_vllimite_saque,0);
    pr_tab_valores_conta(vr_idxval).vldevolver := nvl(vr_vldevolver,0);
    pr_tab_valores_conta(vr_idxval).insituacprvd := vr_insituacprvd;
    pr_tab_valores_conta(vr_idxval).idportab := vr_permportab;

    pr_tab_valores_conta(vr_idxval).insitapi := 0;

    BEGIN
      OPEN cr_checkapi;
      FETCH cr_checkapi INTO rw_checkapi;

      IF cr_checkapi%FOUND THEN
        pr_tab_valores_conta(vr_idxval).insitapi := 1;
      END IF;
      CLOSE cr_tbprevidencia_conta;
    EXCEPTION
       WHEN OTHERS THEN
         null;
       END;

    /* Busca o pacote tarifas */
    OPEN cr_pacotes_tarifas;
    FETCH cr_pacotes_tarifas INTO rw_pacotes_tarifas;

    pr_tab_valores_conta(vr_idxval).pacote_tarifa := cr_pacotes_tarifas%FOUND;

    CLOSE cr_pacotes_tarifas;


    --> Verificar o Aceite do Cooperado ao Convenio
    PGTA0001.pc_verif_aceite_conven ( pr_cdcooper  => pr_cdcooper  -- Código da cooperativa
                                     ,pr_nrdconta  => vr_nrdconta  -- Numero Conta do cooperado
                                     ,pr_nrconven  => 1            -- Numero do Convenio
                                     ,pr_tab_cpt   => vr_tab_cpt   -- Retorna Tabela CRACPT
                                     ,pr_vretorno  => vr_des_reto  --> Retorna OK/NOK
                                     ,pr_cdcritic  => vr_cdcritic  -- Código do erro
                                     ,pr_dscritic  => pr_dscritic);-- Descricao do erro

    IF TRIM(pr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) <> 0 THEN
      pr_flconven := 0; /* FALSE */
    ELSE
      pr_flconven := 1; /* TRUE  */
    END IF;


    -- Se foi solicitado log
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => vr_dsorigem --> Origem enviada
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => pr_dtmvtolt
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;

    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Gerar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                             ,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro na rotina CADA0004.pc_carrega_dados_atenda: '||SQLERRM;
      -- Gerar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                             ,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';
  END pc_carrega_dados_atenda;

  /******************************************************************************/
  /** Procedure para carregar dos dados para a tela ATENDA - Chamada AyllosWeb **/
  /******************************************************************************/
  PROCEDURE pc_carrega_dados_atenda_web ( pr_nrdconta  IN crapass.nrdconta%TYPE   --> Conta do associado
                                         ,pr_idseqttl  IN crapttl.idseqttl%TYPE   --> Sequencia de titularidade da conta
                                         ,pr_nrdctitg  IN crapass.nrdctitg%TYPE   --> Numero da conta itg
                                         ,pr_dtmvtolt  IN VARCHAR2                --> Data do movimento
                                         ,pr_dtmvtopr  IN VARCHAR2                --> Proxima data do movimento
                                         ,pr_dtmvtoan  IN VARCHAR2                --> Data anterior do movimento
                                         ,pr_dtiniper  IN VARCHAR2                --> Data inicial do periodo
                                         ,pr_dtfimper  VARCHAR2                   --> data final do periodo
                                         ,pr_inproces  IN crapdat.inproces%TYPE   --> Indicador do processo
                                         ,pr_flgerlog  IN VARCHAR2                --> Gerar log S/N
                                         ,pr_xmllog         IN VARCHAR2           --> XML com informações de LOG
                                          -- OUT
                                         ,pr_cdcritic OUT PLS_INTEGER             --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2                --> Descric?o da critica
                                         ,pr_retxml   IN OUT NOCOPY XMLType       --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS            --> Erros do processo

  /* .............................................................................

       Programa: pc_carrega_dados_atenda_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana (AMcom)
       Data    : Outubro/2015.                         Ultima atualizacao: 15/11/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Chamada para ayllosWeb(mensageria)
                   Procedure para carregar dos dados para a tela ATENDA

       Alteracoes: 25/11/2015 - Incluido tratamento CDATA nas Tags de anotações
                                pois em alguns casos retorna carcateres especias(ex. "<>")
                                deixando o xml invalido. SD364357 (Odirlei-AMcom)

                   01/12/2015 - Adicionar o campo cdclcnae no retorno do xml (Jaison/Andrino)

                   23/06/2016 - P333.1 - Alteração no retorno de valor do seguro por quantidade
                                (Marcos-Supero)

                   29/08/2016 - Ajustado para adicionar os atributos flconven e dscritic
                                na tag Anotacoes quando a conta nao possui observações
                                (Douglas - Chamado 513666)

                   23/06/2017 - Ajuste para inclusao do novo tipo de situacao da conta
                                "Desligamento por determinação do BACEN"
                                (Jonata - RKAM P364).

                   16/07/2018 - Novo campo Nome Social (#SCTASK0017525 - Andrey Formigari)

                   26/10/2018 - P442 - Retorno do Score Behaviour do Cooperado (Marcos-Envolti)


                   15/11/2018 - Incluido no retorno da procedure o campo reciproc
                                (Andre Clemer - Supero)
    ............................................................................. */
    -------------------> VARIAVEIS <----------------------
    vr_cdcritic          INTEGER;
    vr_dscritic          VARCHAR2(1000);
    vr_exc_erro          EXCEPTION;

    vr_flconven          INTEGER;
    vr_tab_cabec         typ_tab_cabec;
    vr_tab_comp_cabec    typ_tab_comp_cabec;
    vr_tab_valores_conta typ_tab_valores_conta;
    vr_tab_mensagens_atenda typ_tab_mensagens_atenda;
    vr_tab_crapobs       typ_tab_crapobs;
    vr_des_reto          VARCHAR2(100);
    vr_tab_erro          gene0001.typ_tab_erro;

    -- Variaveis de entrada vindas no xml
    vr_cdcooper          INTEGER;
    vr_cdoperad          VARCHAR2(100);
    vr_nmdatela          VARCHAR2(100);
    vr_nmeacao           VARCHAR2(100);
    vr_cdagenci          VARCHAR2(100);
    vr_nrdcaixa          VARCHAR2(100);
    vr_idorigem          VARCHAR2(100);
    vr_dtmvtolt          DATE;
    vr_dtmvtopr          DATE;
    vr_dtmvtoan          DATE;
    vr_dtiniper          DATE;
    vr_dtfimper          DATE;


    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    ---------------------------> SUBROTINAS <--------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;

  BEGIN

    -- Converte data passada por parametro para tipo correto
    vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'dd/mm/yyyy');
    vr_dtmvtopr := TO_DATE(pr_dtmvtopr,'dd/mm/yyyy');
    vr_dtmvtoan := TO_DATE(pr_dtmvtoan,'dd/mm/yyyy');
    vr_dtiniper := TO_DATE(pr_dtiniper,'dd/mm/yyyy');
    vr_dtfimper := TO_DATE(pr_dtfimper,'dd/mm/yyyy');

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    --> Carregar dos dados para a tela ATENDA
    CADA0004.pc_carrega_dados_atenda ( pr_cdcooper => vr_cdcooper  --> Codigo da cooperativa
                                      ,pr_cdagenci => vr_cdagenci  --> Codigo de agencia
                                      ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa
                                      ,pr_cdoperad => vr_cdoperad  --> Codigo do operador
                                      ,pr_dtmvtolt => vr_dtmvtolt  --> Data do movimento
                                      ,pr_dtmvtopr => vr_dtmvtopr  --> Proxima data do movimento
                                      ,pr_dtmvtoan => vr_dtmvtoan  --> Data anterior do movimento
                                      ,pr_dtiniper => vr_dtiniper  --> Data inicial do periodo
                                      ,pr_dtfimper => vr_dtfimper  --> data final do periodo
                                      ,pr_nmdatela => vr_nmdatela  --> Nome da tela
                                      ,pr_idorigem => vr_idorigem  --> Identificado de oriem
                                      ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                                      ,pr_idseqttl => pr_idseqttl  --> Sequencial do titular
                                      ,pr_nrdctitg => pr_nrdctitg  --> Numero da conta itg
                                      ,pr_inproces => pr_inproces  --> Indicador do processo
                                      ,pr_flgerlog => pr_flgerlog  --> identificador se deve gerar log S-Sim e N-Nao
                                      ---------- OUT --------
                                      ,pr_flconven          => vr_flconven           --> Retorna se aceita convenio
                                      ,pr_tab_cabec         => vr_tab_cabec          --> Retorna dados do cabecalho da tela ATENDA
                                      ,pr_tab_comp_cabec    => vr_tab_comp_cabec     --> observacoes dos associados
                                      ,pr_tab_valores_conta => vr_tab_valores_conta  --> Retorna os valores para a tela ATENDA
                                      ,pr_tab_mensagens_atenda  => vr_tab_mensagens_atenda   --> Retorna as mensagens para tela atenda
                                      ,pr_tab_crapobs       => vr_tab_crapobs        --> observacoes dos associados
                                      ,pr_dscritic          => vr_dscritic            --> Retornar critica que nao aborta processamento
                                      ,pr_des_reto          => vr_des_reto           --> OK ou NOK
                                      ,pr_tab_erro          => vr_tab_erro);


    IF vr_des_reto = 'NOK' THEN
      IF vr_tab_erro.exists(vr_tab_erro.first) THEN

        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      ELSE
        vr_dscritic := 'Não foi possivel obter dados para tela ATENDA.';
      END IF;
      RAISE vr_exc_erro;
    END IF;

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;

    pc_escreve_xml ('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>');

    --> Ler temptable e gerar noh Cabecalho
    IF vr_tab_cabec.count > 0 THEN
      pc_escreve_xml ('<Cabecalho>');
      FOR i IN vr_tab_cabec.first..vr_tab_cabec.last LOOP
        pc_escreve_xml ('<Registro>'||
                        '<nrmatric>'|| vr_tab_cabec(i).nrmatric      ||'</nrmatric>'||
                        '<cdagenci>'|| vr_tab_cabec(i).cdagenci      ||'</cdagenci>'||
                        '<dtadmiss>'|| to_char(vr_tab_cabec(i).dtadmiss,'DD/MM/RRRR') ||'</dtadmiss>'||
                        '<nrdctitg>'|| vr_tab_cabec(i).nrdctitg      ||'</nrdctitg>'||
                        '<nrctainv>'|| vr_tab_cabec(i).nrctainv      ||'</nrctainv>'||
                        '<dtadmemp>'|| to_char(vr_tab_cabec(i).dtadmemp,'DD/MM/RRRR') ||'</dtadmemp>'||
                        '<nmprimtl>'|| vr_tab_cabec(i).nmprimtl      ||'</nmprimtl>'||
                        '<nmsegntl>'|| vr_tab_cabec(i).nmsegntl      ||'</nmsegntl>'||
                        '<dtaltera>'|| to_char(vr_tab_cabec(i).dtaltera,'DD/MM/RRRR') ||'</dtaltera>'||
                        '<dsnatopc>'|| vr_tab_cabec(i).dsnatopc      ||'</dsnatopc>'||
                        '<nrramfon>'|| vr_tab_cabec(i).nrramfon      ||'</nrramfon>'||
                        '<dtdemiss>'|| to_char(vr_tab_cabec(i).dtdemiss,'DD/MM/RRRR') ||'</dtdemiss>'||
                        '<dsnatura>'|| vr_tab_cabec(i).dsnatura      ||'</dsnatura>'||
                        '<nrcpfcgc>'|| vr_tab_cabec(i).nrcpfcgc      ||'</nrcpfcgc>'||
                        '<cdsecext>'|| vr_tab_cabec(i).cdsecext      ||'</cdsecext>'||
                        '<indnivel>'|| vr_tab_cabec(i).indnivel      ||'</indnivel>'||
                        '<dstipcta>'|| vr_tab_cabec(i).dstipcta      ||'</dstipcta>'||
                        '<dssitdct>'|| vr_tab_cabec(i).dssitdct      ||'</dssitdct>'||
                        '<cdempres>'|| vr_tab_cabec(i).cdempres      ||'</cdempres>'||
                        '<cdturnos>'|| vr_tab_cabec(i).cdturnos      ||'</cdturnos>'||
                        '<cdtipsfx>'|| vr_tab_cabec(i).cdtipsfx      ||'</cdtipsfx>'||
                        '<nrdconta>'|| vr_tab_cabec(i).nrdconta      ||'</nrdconta>'||
                        '<vllimcre>'|| vr_tab_cabec(i).vllimcre      ||'</vllimcre>'||
                        '<inpessoa>'|| vr_tab_cabec(i).inpessoa      ||'</inpessoa>'||
                        '<dssititg>'|| vr_tab_cabec(i).dssititg      ||'</dssititg>'||
                        '<qttitula>'|| vr_tab_cabec(i).qttitula      ||'</qttitula>'||
                        '<cdclcnae>'|| vr_tab_cabec(i).cdclcnae      ||'</cdclcnae>'||
                        '<cdsitdct>'|| vr_tab_cabec(i).cdsitdct      ||'</cdsitdct>'||
                        '<nmsocial>'|| vr_tab_cabec(i).nmsocial      ||'</nmsocial>'||
                        '<cdscobeh>'|| vr_tab_cabec(i).cdscobeh      ||'</cdscobeh>'||
                        '<reciproc>'|| vr_tab_cabec(i).reciproc      ||'</reciproc>'||
                        '<nrdgrupo>'|| vr_tab_cabec(i).nrdgrupo      ||'</nrdgrupo>'||
                        '</Registro>');

      END LOOP;
      pc_escreve_xml ('</Cabecalho>');
    END IF;

    --> Ler temptable e gerar noh Comp.Cabecalho
    IF vr_tab_comp_cabec.count > 0 THEN
      pc_escreve_xml ('<Comp.Cabecalho>');
      FOR i IN vr_tab_comp_cabec.first..vr_tab_comp_cabec.last LOOP
        pc_escreve_xml ('<Registro>'||
                        '<qtdevolu>'|| vr_tab_comp_cabec(i).qtdevolu ||'</qtdevolu>'||
                        '<qtddsdev>'|| vr_tab_comp_cabec(i).qtddsdev ||'</qtddsdev>'||
                        '<qtddtdev>'|| vr_tab_comp_cabec(i).qtddtdev ||'</qtddtdev>'||
                        '<dtsisfin>'|| TO_CHAR(vr_tab_comp_cabec(i).dtsisfin,'DD/MM/RRRR') ||'</dtsisfin>'||
                        '<ftsalari>'|| vr_tab_comp_cabec(i).ftsalari ||'</ftsalari>'||
                        '<vlprepla>'|| vr_tab_comp_cabec(i).vlprepla ||'</vlprepla>'||
                        '<qttalret>'|| vr_tab_comp_cabec(i).qttalret ||'</qttalret>'||
                        '<flgdigit>'|| (CASE upper(vr_tab_comp_cabec(i).flgdigit)
                                         WHEN 'S' THEN 'yes'
                                         ELSE 'no'
                                       END) ||'</flgdigit>'||
                        '</Registro>');
      END LOOP;
      pc_escreve_xml ('</Comp.Cabecalho>');
    END IF;

    --> Ler temptable e gerar noh Valores
    IF vr_tab_valores_conta.count > 0 THEN
      pc_escreve_xml ('<Valores>');
      FOR i IN vr_tab_valores_conta.first..vr_tab_valores_conta.last LOOP
        pc_escreve_xml ('<Registro>'||
                        '<vlsldcap>'|| vr_tab_valores_conta(i).vlsldcap ||'</vlsldcap>'||
                        '<vlsldepr>'|| vr_tab_valores_conta(i).vlsldepr ||'</vlsldepr>'||
                        '<vlsldapl>'|| vr_tab_valores_conta(i).vlsldapl ||'</vlsldapl>'||
                        '<vlsldinv>'|| vr_tab_valores_conta(i).vlsldinv ||'</vlsldinv>'||
                        '<vlsldppr>'|| vr_tab_valores_conta(i).vlsldppr ||'</vlsldppr>'||
                        '<vlstotal>'|| vr_tab_valores_conta(i).vlstotal ||'</vlstotal>'||
                        '<vllimite>'|| vr_tab_valores_conta(i).vllimite ||'</vllimite>'||
                        '<qtfolhas>'|| vr_tab_valores_conta(i).qtfolhas ||'</qtfolhas>'||
                        '<qtconven>'|| vr_tab_valores_conta(i).qtconven ||'</qtconven>'||
                        '<flgocorr>'|| (CASE vr_tab_valores_conta(i).flgocorr
                                         WHEN 1 THEN 'yes'
                                         ELSE 'no'
                                       END)                             ||'</flgocorr>'||
                        '<dssitura>'|| vr_tab_valores_conta(i).dssitura ||'</dssitura>'||
                        '<vllautom>'|| vr_tab_valores_conta(i).vllautom ||'</vllautom>'||
                        '<dssitnet>'|| vr_tab_valores_conta(i).dssitnet ||'</dssitnet>'||
                        '<vltotpre>'|| vr_tab_valores_conta(i).vltotpre ||'</vltotpre>'||
                        '<vltotccr>'|| vr_tab_valores_conta(i).vltotccr ||'</vltotccr>'||
                        '<qtcarmag>'|| vr_tab_valores_conta(i).qtcarmag ||'</qtcarmag>'||
                        '<flgsegur>'|| (CASE vr_tab_valores_conta(i).qttotseg
                                         WHEN 0 THEN 'no'
                                         ELSE 'yes'
                                       END)                             ||'</flgsegur>'||
                        '<vltotdsc>'|| vr_tab_valores_conta(i).vltotdsc ||'</vltotdsc>'||
                        '<flgbloqt>'|| (CASE vr_tab_valores_conta(i).flgbloqt
                                         WHEN 1 THEN 'yes'
                                         ELSE 'no'
                                       END)                             ||'</flgbloqt>'||
                        '<vllimite_saque>'|| vr_tab_valores_conta(i).vllimite_saque ||'</vllimite_saque>'||
                        '<pacote_tarifa>'|| (CASE vr_tab_valores_conta(i).pacote_tarifa
                                         WHEN TRUE THEN 'yes'
                                         ELSE 'no'
                                       END)   ||'</pacote_tarifa>'||
                        '<vldevolver>'|| vr_tab_valores_conta(i).vldevolver ||'</vldevolver>'||
                        '<insituacprvd>'|| vr_tab_valores_conta(i).insituacprvd ||'</insituacprvd>'||
                        '<idportab>'||  vr_tab_valores_conta(i).idportab ||'</idportab>'||
                        '<insitapi>'||  vr_tab_valores_conta(i).insitapi ||'</insitapi>'||
                        '</Registro>');


      END LOOP;
      pc_escreve_xml ('</Valores>');
    ELSE
      pc_escreve_xml ('<Valores/>');
    END IF;

    --> Ler temptable e gerar noh Mensagens
    IF vr_tab_mensagens_atenda.count > 0 THEN
      pc_escreve_xml ('<Mensagens>');
      FOR i IN vr_tab_mensagens_atenda.first..vr_tab_mensagens_atenda.last LOOP
        pc_escreve_xml ('<Registro>'||
                        '<nrsequen>'|| vr_tab_mensagens_atenda(i).nrsequen ||'</nrsequen>'||
                        '<dsmensag><![CDATA['|| vr_tab_mensagens_atenda(i).dsmensag ||']]></dsmensag>'||
                        '</Registro>');
      END LOOP;
      pc_escreve_xml ('</Mensagens>');
    ELSE
      pc_escreve_xml ('<Mensagens/>');
    END IF;

    --> Ler temptable e gerar noh Anotacoes
    IF vr_tab_crapobs.count > 0 THEN
      pc_escreve_xml ('<Anotacoes flconven="'|| vr_flconven||'"
                                  dscritic="'|| vr_dscritic||'">');
      FOR i IN vr_tab_crapobs.first..vr_tab_crapobs.last LOOP
        pc_escreve_xml ('<Registro>'||
                        '<nrdconta>'|| vr_tab_crapobs(i).nrdconta ||'</nrdconta>'||
                        '<dtmvtolt>'|| vr_tab_crapobs(i).dtmvtolt ||'</dtmvtolt>'||
                        '<nrseqdig>'|| vr_tab_crapobs(i).nrseqdig ||'</nrseqdig>'||
                        '<cdoperad>'|| vr_tab_crapobs(i).cdoperad ||'</cdoperad>'||
                        '<hrtransa>'|| vr_tab_crapobs(i).hrtransa ||'</hrtransa>'||
                        '<flgprior>'|| (CASE vr_tab_crapobs(i).flgprior
                                         WHEN 1 THEN 'yes'
                                         ELSE 'no'
                                       END)                       ||'</flgprior>'||
                        '<dsobserv><![CDATA['|| vr_tab_crapobs(i).dsobserv ||']]></dsobserv>'||
                        '<dslogobs><![CDATA['|| vr_tab_crapobs(i).dslogobs ||']]></dslogobs>'||
                        '<cdcooper>'|| vr_tab_crapobs(i).cdcooper ||'</cdcooper>'||
                        '<recidobs>'|| vr_tab_crapobs(i).recidobs ||'</recidobs>'||
                        '<hrtransc>'|| vr_tab_crapobs(i).hrtransc ||'</hrtransc>'||
                        '<nmoperad>'|| vr_tab_crapobs(i).nmoperad ||'</nmoperad>'||
                        '</Registro>');

      END LOOP;
      pc_escreve_xml ('</Anotacoes>');
    ELSE
      pc_escreve_xml ('<Anotacoes flconven="'|| vr_flconven||'"
                                  dscritic="'|| vr_dscritic||'" />');
    END IF;

    --> Descarregar buffer
    pc_escreve_xml ('</Root>',TRUE);

    pr_retxml := XMLType.createXML(vr_des_xml);

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);


  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN

      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_carrega_dados_atenda_web ' ||
                     SQLERRM;
  END pc_carrega_dados_atenda_web;

  PROCEDURE pc_alerta_fraude (pr_cdcooper IN NUMBER                   --> Cooperativa
                             ,pr_cdagenci IN NUMBER                   --> PA
                             ,pr_nrdcaixa IN NUMBER                   --> Nr. do caixa
                             ,pr_cdoperad IN VARCHAR2                 --> Cód. operador
                             ,pr_nmdatela IN VARCHAR2                 --> Nome da tela
                             ,pr_dtmvtolt IN DATE                     --> Data de movimento
                             ,pr_idorigem IN NUMBER                   --> ID de origem
                             ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE    --> Nr. do CPF/CNPJ
                             ,pr_nrdconta IN crapass.nrdconta%TYPE    --> Nr. da conta
                             ,pr_idseqttl IN NUMBER                   --> Id de sequencia do titular
                             ,pr_bloqueia IN NUMBER                   --> Flag Bloqueia operação
                             ,pr_cdoperac IN NUMBER                   --> Cód da operação
                             ,pr_dsoperac IN VARCHAR2                 --> Desc. da operação
                             ,pr_cdcritic OUT NUMBER                  --> Cód. da crítica
                             ,pr_dscritic OUT VARCHAR2                --> Desc. da crítica
                             ,pr_des_erro OUT VARCHAR2) IS            --> Retorno de erro  OK/NOK
  BEGIN
  /* .............................................................................

     Programa: pc_alerta_fraude           (Antigo b1wgen0110.p/alerta_fraude)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Reinert
     Data    : Fevereiro/2016.                         Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado.
     Objetivo  : Verificar se a conta está no cadastro restritivo.

     Alteracoes:
  ............................................................................. */

  DECLARE

    -- Variáveis de tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(3000);
    vr_des_erro VARCHAR2(3);
    vr_exc_erro EXCEPTION;

    -- Variáveis auxiliares
    vr_nmpessoa crapcrt.nmpessoa%TYPE;
    vr_nrdrowid ROWID;
    vr_cdpactra NUMBER;
    vr_blqopera NUMBER;
    vr_temjusti BOOLEAN;
    vr_inpessoa NUMBER;
    vr_stsnrcal BOOLEAN;
    vr_nmdcampo VARCHAR2(30);
    vr_flgrisco BOOLEAN;

    -- PL Table com dados do cadstro restritivo
    vr_tab_cadrest CADA0004.typ_tab_cadrest;
    vr_ind_cadrest NUMBER;

    -- Buscar PA do operador
    CURSOR cr_crapope_age IS
      SELECT age.cdagenci
        FROM crapope ope,
             crapage age
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad
         AND age.cdcooper = ope.cdcooper
         AND age.cdagenci = ope.cdpactra;
    rw_crapope_age cr_crapope_age%ROWTYPE;

    -- Buscar quantidade de titulares da conta com o mesmo cpf
    CURSOR cr_crapttl_count IS
      SELECT COUNT(1) qtdregist
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.nrcpfcgc = pr_nrcpfcgc;
    rw_crapttl_count cr_crapttl_count%ROWTYPE;

    -- Buscar dados dos titulares da conta
    CURSOR cr_crapttl IS
      SELECT ttl.nrdconta
            ,ttl.nrcpfcgc
            ,ttl.idseqttl
            ,ttl.nmextttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta;

    -- Busca representantes legais
    CURSOR cr_crapcrl IS
      SELECT crl.cdcooper
            ,crl.nrdconta
            ,crl.nrcpfcgc
            ,crl.nmrespon
        FROM crapcrl crl
       WHERE crl.cdcooper = pr_cdcooper
         AND crl.nrctamen = pr_nrdconta
         AND crl.idseqmen = pr_idseqttl;

    -- Dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.nrcpfcgc
            ,ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Buscar todos os representantes/procuradores
    CURSOR cr_crapavt IS
      SELECT avt.cdcooper
            ,avt.nrdctato
            ,avt.nrcpfcgc
            ,avt.nmdavali
        FROM crapavt avt
       WHERE avt.cdcooper = pr_cdcooper
         AND avt.tpctrato = 6
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrctremp = pr_idseqttl;

    -- Buscar todos os representantes/procuradores
    CURSOR cr_crapavt_pj IS
      SELECT avt.cdcooper
            ,avt.nrdctato
            ,avt.nrcpfcgc
            ,avt.nmdavali
        FROM crapavt avt
       WHERE avt.cdcooper = pr_cdcooper
         AND avt.tpctrato = 6
         AND avt.nrdconta = pr_nrdconta;

    -- Buscar todas as empresas participantes
    CURSOR cr_crapepa IS
      SELECT epa.nrctasoc
            ,epa.cdcooper
            ,epa.nrdocsoc
            ,epa.nmprimtl
        FROM crapepa epa
       WHERE epa.cdcooper = pr_cdcooper
         AND epa.nrdconta = pr_nrdconta;

    -- Verifica se existe justificativa
    CURSOR cr_craplju (pr_nrcpfcgcc IN craplju.nrcpfcgc%TYPE
                      ,pr_cdcooperc IN craplju.cdcooper%TYPE
                      ,pr_cdpactrac IN craplju.cdagenci%TYPE
                      ,pr_cdopelibc IN craplju.cdopelib%TYPE
                      ,pr_nrdcontac IN craplju.nrdconta%TYPE
                      ,pr_dtmvtoltc IN craplju.dtmvtolt%TYPE
                      ,pr_cdoperacc IN craplju.cdoperac%TYPE) IS
      SELECT 1
        FROM craplju lju
       WHERE lju.nrcpfcgc = pr_nrcpfcgcc
         AND lju.cdcooper = pr_cdcooperc
         AND lju.cdagenci = pr_cdpactrac
         AND lju.cdopelib = pr_cdopelibc
         AND lju.nrdconta = pr_nrdcontac
         AND lju.dtmvtolt = pr_dtmvtoltc
         AND (lju.cdoperac = pr_cdoperacc
           OR lju.cdoperac = 0);
    rw_craplju cr_craplju%ROWTYPE;

  BEGIN
    -- Buscar PA do operador
    OPEN cr_crapope_age;
    FETCH cr_crapope_age INTO rw_crapope_age;

    -- Se não encontrou
    IF cr_crapope_age%NOTFOUND THEN
      -- Gera crítica
      vr_cdcritic := 15;
      -- Fecha cursor
      CLOSE cr_crapope_age;
      -- Levanta exceção
      RAISE vr_exc_erro;
    ELSE
      vr_cdpactra := rw_crapope_age.cdagenci;
    END IF;
    -- Fecha cursor
    CLOSE cr_crapope_age;

    -- Se conta e cpf vieram zeradas
    IF pr_nrdconta = 0 AND
       pr_nrcpfcgc = 0 THEN
       -- Gera crítica
       vr_cdcritic := 9;
       -- Levanta exceção
       RAISE vr_exc_erro;
    END IF;

    -- Valida cpf ou cnpj
    gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_nrcpfcgc
                               ,pr_stsnrcal => vr_stsnrcal
                               ,pr_inpessoa => vr_inpessoa);
    -- Situação inválida
    IF NOT vr_stsnrcal THEN
       -- Gera crítica
       vr_cdcritic := 27;
       -- Levanta exceção
       RAISE vr_exc_erro;
    END IF;

    -- Se numero da conta for diferente de 0
    IF pr_nrdconta <> 0 THEN
      -- PF
      IF vr_inpessoa = 1 THEN
        -- Abre cursor de titulares da conta
        OPEN cr_crapttl_count;
        FETCH cr_crapttl_count INTO rw_crapttl_count;

        -- Se conta possuir 2 titulares para o mesmo cpf
        IF rw_crapttl_count.qtdregist > 1 THEN
          -- Gera crítica
          vr_cdcritic := 958;
          -- Fecha cursor
          CLOSE cr_crapttl_count;
          -- Levanta exceção
          RAISE vr_exc_erro;
        -- Se não encontrou nenhum titular
        ELSIF rw_crapttl_count.qtdregist = 0 THEN
          -- Gera crítica
          vr_cdcritic := 9;
          -- Fecha cursor
          CLOSE cr_crapttl_count;
          -- Levanta exceção
          RAISE vr_exc_erro;
        END IF;

        -- Fecha cursor
        CLOSE cr_crapttl_count;

        -- Para cada titular da conta
        FOR rw_crapttl IN cr_crapttl LOOP
          -- Pega novo indice
          vr_ind_cadrest := vr_tab_cadrest.COUNT + 1;
          -- Atribui a PLTable
          vr_tab_cadrest(vr_ind_cadrest).nrdconta := rw_crapttl.nrdconta;
          vr_tab_cadrest(vr_ind_cadrest).nrcpfcgc := rw_crapttl.nrcpfcgc;
          vr_tab_cadrest(vr_ind_cadrest).idseqttl := rw_crapttl.idseqttl;
          vr_tab_cadrest(vr_ind_cadrest).nmextttl := rw_crapttl.nmextttl;

        END LOOP;
        -- Para cada representante legal
        FOR rw_crapcrl IN cr_crapcrl LOOP
          -- Se numero da conta for diferente de 0
          IF rw_crapcrl.nrdconta <> 0 THEN
            -- Busca associado
            OPEN cr_crapass(pr_cdcooper => rw_crapcrl.cdcooper
                           ,pr_nrdconta => rw_crapcrl.nrdconta);
            FETCH cr_crapass INTO rw_crapass;

            IF cr_crapass%NOTFOUND THEN
              -- Gera crítica
              vr_cdcritic := 9;
              -- Fecha cursor
              CLOSE cr_crapass;
              -- Levanta exceção
              RAISE vr_exc_erro;
            END IF;
            -- Fecha cursor
            CLOSE cr_crapass;

            -- Pega novo indice
            vr_ind_cadrest := vr_tab_cadrest.COUNT + 1;
            -- Atribui a PL Table
            vr_tab_cadrest(vr_ind_cadrest).nrdconta := rw_crapass.nrdconta;
            vr_tab_cadrest(vr_ind_cadrest).nrcpfcgc := rw_crapass.nrcpfcgc;
            vr_tab_cadrest(vr_ind_cadrest).idseqttl := 1;
            vr_tab_cadrest(vr_ind_cadrest).nmextttl := rw_crapass.nmprimtl;
          ELSE
            -- Pega novo indice
            vr_ind_cadrest := vr_tab_cadrest.COUNT + 1;
            -- Atribui a PL Table
            vr_tab_cadrest(vr_ind_cadrest).nrdconta := rw_crapcrl.nrdconta;
            vr_tab_cadrest(vr_ind_cadrest).nrcpfcgc := rw_crapcrl.nrcpfcgc;
            vr_tab_cadrest(vr_ind_cadrest).nmextttl := rw_crapcrl.nmrespon;
          END IF;
        END LOOP;

        -- Buscar todos rep/procuradores
        FOR rw_crapavt IN cr_crapavt LOOP
          -- Se numero da conta for diferente de 0
          IF rw_crapavt.nrdctato <> 0 THEN
            -- Devemos procurar na crapass
            OPEN cr_crapass(pr_cdcooper => rw_crapavt.cdcooper
                           ,pr_nrdconta => rw_crapavt.nrdctato);
            FETCH cr_crapass INTO rw_crapass;

            -- Se não encontrou associado
            IF cr_crapass%NOTFOUND THEN
              -- Gera crítica
              vr_cdcritic := 9;
              -- Fecha cursor
              CLOSE cr_crapass;
              -- Levanta exceção
              RAISE vr_exc_erro;
            END IF;
            -- Fecha cursor
            CLOSE cr_crapass;

            -- Pega novo indice
            vr_ind_cadrest := vr_tab_cadrest.COUNT + 1;
            -- Atribui a PL Table
            vr_tab_cadrest(vr_ind_cadrest).nrdconta := rw_crapass.nrdconta;
            vr_tab_cadrest(vr_ind_cadrest).nrcpfcgc := rw_crapass.nrcpfcgc;
            vr_tab_cadrest(vr_ind_cadrest).idseqttl := 1;
            vr_tab_cadrest(vr_ind_cadrest).nmextttl := rw_crapass.nmprimtl;
          ELSE
            -- Pega novo indice
            vr_ind_cadrest := vr_tab_cadrest.COUNT + 1;
            -- Atribui a PL Table
            vr_tab_cadrest(vr_ind_cadrest).nrdconta := rw_crapavt.nrdctato;
            vr_tab_cadrest(vr_ind_cadrest).nrcpfcgc := rw_crapavt.nrcpfcgc;
            vr_tab_cadrest(vr_ind_cadrest).nmextttl := rw_crapavt.nmdavali;
          END IF;
        END LOOP;
      ELSE
        -- Procura associado
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;

        IF cr_crapass%NOTFOUND THEN
          -- Gera crítica
          vr_cdcritic := 9;
          -- Fecha cursor
          CLOSE cr_crapass;
          -- Levanta exceção
          RAISE vr_exc_erro;
        END IF;
        -- Fecha cursor
        CLOSE cr_crapass;

        -- Pega novo indice
        vr_ind_cadrest := vr_tab_cadrest.COUNT + 1;
        -- Atribui a PL Table
        vr_tab_cadrest(vr_ind_cadrest).nrdconta := rw_crapass.nrdconta;
        vr_tab_cadrest(vr_ind_cadrest).nrcpfcgc := rw_crapass.nrcpfcgc;
        vr_tab_cadrest(vr_ind_cadrest).idseqttl := 1;
        vr_tab_cadrest(vr_ind_cadrest).nmextttl := rw_crapass.nmprimtl;

        -- Busca todos rep/procuradores
        FOR rw_crapavt_pj IN cr_crapavt_pj LOOP
          IF rw_crapavt_pj.nrdctato <> 0 THEN
            -- Procura associado
            OPEN cr_crapass(pr_cdcooper => rw_crapavt_pj.cdcooper
                           ,pr_nrdconta => rw_crapavt_pj.nrdctato);

            IF cr_crapass%NOTFOUND THEN
              -- Gera crítica
              vr_cdcritic := 9;
              -- Fecha cursor
              CLOSE cr_crapass;
              -- Levanta exceção
              RAISE vr_exc_erro;
            END IF;
            -- Fecha cursor
            CLOSE cr_crapass;

            -- Pega novo indice
            vr_ind_cadrest := vr_tab_cadrest.COUNT + 1;
            -- Atribui a PL Table
            vr_tab_cadrest(vr_ind_cadrest).nrdconta := rw_crapass.nrdconta;
            vr_tab_cadrest(vr_ind_cadrest).nrcpfcgc := rw_crapass.nrcpfcgc;
            vr_tab_cadrest(vr_ind_cadrest).idseqttl := 1;
            vr_tab_cadrest(vr_ind_cadrest).nmextttl := rw_crapass.nmprimtl;

          ELSE
            -- Pega novo indice
            vr_ind_cadrest := vr_tab_cadrest.COUNT + 1;
            -- Atribui a PL Table
            vr_tab_cadrest(vr_ind_cadrest).nrdconta := rw_crapavt_pj.nrdctato;
            vr_tab_cadrest(vr_ind_cadrest).nrcpfcgc := rw_crapavt_pj.nrcpfcgc;
            vr_tab_cadrest(vr_ind_cadrest).nmextttl := rw_crapavt_pj.nmdavali;

          END IF;
        END LOOP;

        -- Busca todas as empresas participantes
        FOR rw_crapepa IN cr_crapepa LOOP

          -- Se numero da conta for diferente de 0
          IF rw_crapepa.nrctasoc <> 0 THEN
            -- Busca associado
            OPEN cr_crapass (pr_cdcooper => rw_crapepa.cdcooper
                            ,pr_nrdconta => rw_crapepa.nrctasoc);
            FETCH cr_crapass INTO rw_crapass;

            IF cr_crapass%NOTFOUND THEN
              -- Gera crítica
              vr_cdcritic := 9;
              -- Fecha cursor
              CLOSE cr_crapass;
              -- Levanta exceção
              RAISE vr_exc_erro;
            END IF;
            -- Fecha cursor
            CLOSE cr_crapass;

            -- Pega novo indice
            vr_ind_cadrest := vr_tab_cadrest.COUNT + 1;
            -- Atribui a PL Table
            vr_tab_cadrest(vr_ind_cadrest).nrdconta := rw_crapass.nrdconta;
            vr_tab_cadrest(vr_ind_cadrest).nrcpfcgc := rw_crapass.nrcpfcgc;
            vr_tab_cadrest(vr_ind_cadrest).idseqttl := 1;
            vr_tab_cadrest(vr_ind_cadrest).nmextttl := rw_crapass.nmprimtl;

          ELSE
            -- Pega novo indice
            vr_ind_cadrest := vr_tab_cadrest.COUNT + 1;
            -- Atribui a PL Table
            vr_tab_cadrest(vr_ind_cadrest).nrdconta := rw_crapepa.nrctasoc;
            vr_tab_cadrest(vr_ind_cadrest).nrcpfcgc := rw_crapepa.nrdocsoc;
            vr_tab_cadrest(vr_ind_cadrest).nmextttl := rw_crapepa.nmprimtl;

          END IF;

        END LOOP;

      END IF;
    ELSE
      -- Pega novo indice
      vr_ind_cadrest := vr_tab_cadrest.COUNT + 1;
      -- Atribui a PL Table
      vr_tab_cadrest(vr_ind_cadrest).nrdconta := pr_nrdconta;
      vr_tab_cadrest(vr_ind_cadrest).nrcpfcgc := pr_nrcpfcgc;
      vr_tab_cadrest(vr_ind_cadrest).nmextttl := pr_idseqttl;

    END IF;

    FOR vr_contador IN vr_tab_cadrest.first..vr_tab_cadrest.last LOOP

        vr_nmpessoa := '';
        vr_flgrisco := fn_get_existe_risco_cpfcnpj(vr_tab_cadrest(vr_contador).nrcpfcgc
                                                  ,vr_nmpessoa);
        -- Se o cpf em questão estiver no cadastro restritivo
        IF vr_flgrisco THEN
          IF pr_bloqueia = 0 THEN
            pc_liberar_cad_restritivo(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_idorigem => pr_idorigem
                                     ,pr_dtmvtolt => pr_dtmvtolt
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_cdcoplib => pr_cdcooper
                                     ,pr_cdagelib => vr_cdpactra
                                     ,pr_cdopelib => pr_cdoperad
                                     ,pr_nrdconta => vr_tab_cadrest(vr_contador).nrdconta
                                     ,pr_nrcpfcgc => vr_tab_cadrest(vr_contador).nrcpfcgc
                                     ,pr_dsjuslib => pr_dsoperac
                                     ,pr_cdoperac => pr_cdoperac
                                     ,pr_flgsiste => 1
                                     ,pr_nmdcampo => vr_nmdcampo
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_des_erro => vr_des_erro);

            -- Se retorno for diferente de OK
            IF vr_des_erro <> 'OK' THEN
              -- Se possui crítica
              IF vr_dscritic IS NOT NULL THEN
                -- Levanta exceção
                RAISE vr_exc_erro;
              ELSE
                IF vr_cdcritic <> 0 THEN
                  -- Busca crítica
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                ELSE
                  vr_dscritic := 'Nao foi possivel gerar justificativa';
                END IF;
                -- Levanta exceção
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END IF;

          -- Procura se possui justificativa
          OPEN cr_craplju(vr_tab_cadrest(vr_contador).nrcpfcgc
                         ,pr_cdcooper
                         ,vr_cdpactra
                         ,pr_cdoperad
                         ,vr_tab_cadrest(vr_contador).nrdconta
                         ,pr_dtmvtolt
                         ,pr_cdoperac);
          FETCH cr_craplju INTO rw_craplju;

          -- Coloca resultado da busca na variável
          vr_temjusti := cr_craplju%FOUND;
          -- Fecha cursor
          CLOSE cr_craplju;

          -- Envia email
          pc_envia_email_alerta(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_nmdatela => pr_nmdatela
                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_idorigem => pr_idorigem
                               ,pr_nrcpfcgc => vr_tab_cadrest(vr_contador).nrcpfcgc
                               ,pr_nrdconta => vr_tab_cadrest(vr_contador).nrdconta
                               ,pr_idseqttl => vr_tab_cadrest(vr_contador).idseqttl
                               ,pr_nmprimtl => vr_tab_cadrest(vr_contador).nmextttl
                               ,pr_nmpessoa => vr_nmpessoa
                               ,pr_cdoperac => pr_cdoperac
                               ,pr_dsoperac => pr_dsoperac
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_des_erro => vr_des_erro);

          -- Se retornou algum erro
          IF vr_des_erro <> 'OK' THEN
            -- Gera log
            btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log =>
                                      to_char(pr_dtmvtolt) || ' ' ||
                                      to_char(SYSDATE, 'HH:MI:SS') || ' --> ' ||
                                      'Operador ' || pr_cdoperad || ', operacao: ' ||
                                      pr_dsoperac ||
                                      '. Nao foi possivel enviar o(s) email(s)'
                                      ,pr_nmarqlog => 'alerta.log');
            vr_dscritic := 'Nao foi possivel enviar o(s) email(s)';
            RAISE vr_exc_erro;

          END IF;
          -- Se não houver justificativa bloqueia operação
          IF NOT vr_temjusti THEN
            vr_blqopera := 1;
          END IF;

        END IF;

    END LOOP;

    IF vr_blqopera = 1 THEN
      -- Gera crítica
      vr_dscritic := 'Operacao indisponivel, consulte o Gerente/Coordenador';
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;

    pr_des_erro := 'OK';
    -- Efetua commit
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN

      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_alerta_fraude ' ||
                     SQLERRM;
      pr_des_erro := 'NOK';
    END;
  END pc_alerta_fraude;

  FUNCTION fn_get_existe_risco_cpfcnpj (pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                                       ,pr_nmpessoa OUT VARCHAR2) RETURN BOOLEAN IS
  /* ..........................................................................
    --
    --  Programa : fn_get_existe_risco_cpfcnpj        Antiga: b1wgen0110.p/fget_existe_risco_cpfcnpj
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Lucas Reinert
    --  Data     : Fevereiro/2016.                 Ultima atualizacao: 25/02/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para verificar se o cpf em questão esta no cadastro
    --               restritivo
    --
    --  Alteração :
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    CURSOR cr_crapcrt IS
      SELECT crt.nmpessoa
        FROM crapcrt crt
       WHERE crt.cdsitreg = 1
         AND crt.nrcpfcgc = pr_nrcpfcgc;
    rw_crapcrt cr_crapcrt%ROWTYPE;
  BEGIN
    -- Procura cpf no cadastro restritivo
    OPEN cr_crapcrt;
    FETCH cr_crapcrt INTO rw_crapcrt;

    -- Se encontrou retorna o nome da pessoa
    IF cr_crapcrt%FOUND THEN
      pr_nmpessoa := rw_crapcrt.nmpessoa;
      CLOSE cr_crapcrt;
      RETURN TRUE;
    ELSE
      CLOSE cr_crapcrt;
      RETURN FALSE;
    END IF;

  END fn_get_existe_risco_cpfcnpj;

  PROCEDURE pc_liberar_cad_restritivo (pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                      ,pr_cdagenci IN NUMBER                --> PA
                                      ,pr_nrdcaixa IN NUMBER                --> Caixa
                                      ,pr_idorigem IN NUMBER                --> Origem
                                      ,pr_dtmvtolt IN DATE                  --> Data de movimento
                                      ,pr_cdoperad IN VARCHAR2              --> Operador
                                      ,pr_cdcoplib IN NUMBER                --> Cooperativa liberação
                                      ,pr_cdagelib IN NUMBER                --> PA liberação
                                      ,pr_cdopelib IN NUMBER                --> Operador liberação
                                      ,pr_nrdconta IN NUMBER                --> Nr. da conta
                                      ,pr_nrcpfcgc IN NUMBER                --> Nr do CPF
                                      ,pr_dsjuslib IN VARCHAR2              --> Descrição da justificativa
                                      ,pr_cdoperac IN NUMBER                --> Cód. operação
                                      ,pr_flgsiste IN NUMBER                --> Gerado pelo sistema
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo
                                      ,pr_cdcritic OUT NUMBER               --> Cód. da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Retorno de erro OK/NOK
  BEGIN
  /* .............................................................................

     Programa: pc_liberar_cad_restritivo (Antigo b1wgen0117.p/liberar_cad_restritivo)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Reinert
     Data    : Fevereiro/2016.                         Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado.
     Objetivo  : Liberar conta do cadastro restritivo.

     Alteracoes:
  ............................................................................. */
  DECLARE
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(3000);
    vr_sittrans VARCHAR2(3) := 'NOK';
    vr_exc_erro EXCEPTION;

    -- Variáveis auxiliares
    vr_nrjuslib NUMBER := 0;
    vr_nrcpfcgc NUMBER := 0;
    vr_nrdconta NUMBER := 0;
    vr_inpessoa NUMBER;
    vr_stsnrcal BOOLEAN;

    -------------> CURSORES <---------------
    -- Busca cooperativa
    CURSOR cr_crapcop(pr_cdcooperc IN crapcop.cdcooper%TYPE)IS
      SELECT 1
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooperc;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Busca operador
    CURSOR cr_crapope(pr_cdcooperc IN crapcop.cdcooper%TYPE
                     ,pr_cdoperadc IN crapope.cdoperad%TYPE) IS
      SELECT 1
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooperc
         AND ope.cdoperad = pr_cdoperadc;
    rw_crapope cr_crapope%ROWTYPE;

    -- Buscar PA
    CURSOR cr_crapage(pr_cdcooperc IN crapage.cdcooper%TYPE
                     ,pr_cdagencic IN crapage.cdagenci%TYPE) IS
      SELECT 1
        FROM crapage age
       WHERE age.cdcooper = pr_cdcoplib
         AND age.cdagenci = pr_cdagelib;
    rw_crapage cr_crapage%ROWTYPE;

    -- Busca operações/rotinas do sistema
    CURSOR cr_craprot IS
      SELECT 1
        FROM craprot rot
       WHERE rot.cdoperac = pr_cdoperac;
    rw_craprot cr_craprot%ROWTYPE;

    -- Buscar ultimo numero de liberação de justificativa
    CURSOR cr_craplju IS
      SELECT max(lju.nrjuslib) nrjuslib
        FROM craplju lju
       WHERE lju.nrcpfcgc = pr_nrcpfcgc;
    rw_craplju cr_craplju%ROWTYPE;

    -- Busca associado
    CURSOR cr_crapass (pr_cdcooperc IN crapass.cdcooper%TYPE
                      ,pr_nrdcontac IN crapass.nrdconta%TYPE) IS
      SELECT 1
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooperc
         AND ass.nrdconta = pr_nrdcontac;
    rw_crapass cr_crapass%ROWTYPE;


  BEGIN
    -- Verifica cooperativa
    OPEN cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    IF cr_crapcop%NOTFOUND THEN
      -- Gera crítica
      vr_cdcritic := 794;
      -- Fecha cursor
      CLOSE cr_crapcop;
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    -- Fecha cursor
    CLOSE cr_crapcop;

    -- Procura operador
    OPEN cr_crapope(pr_cdcooper, pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;

    -- Se não encontrar operador
    IF cr_crapope%NOTFOUND THEN
      -- Gera crítica
      vr_cdcritic := 67;
      -- Fecha cursor
      CLOSE cr_crapope;
    END IF;

    -- Procura cooperativa
    OPEN cr_crapcop(pr_cdcoplib);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se não encontrou
    IF cr_crapcop%NOTFOUND THEN
      -- Gera crítica
      vr_cdcritic := 794;
      pr_nmdcampo := 'cdcopsol';
      -- Fecha cursor
      CLOSE cr_crapcop;
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;

    -- Busca PA
    OPEN cr_crapage(pr_cdcoplib, pr_cdagelib);
    FETCH cr_crapage INTO rw_crapage;

    -- Se não encontrou
    IF cr_crapage%NOTFOUND THEN
      -- Gera crítica
      vr_cdcritic := 962;
      pr_nmdcampo := 'cdagepac';
      -- Fecha cursor
      CLOSE cr_crapage;
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    -- Fecha cursor
    CLOSE cr_crapage;

    -- Procura operador
    OPEN cr_crapope(pr_cdcoplib, pr_cdopelib);
    FETCH cr_crapope INTO rw_crapope;

    -- Se não encontrar operador
    IF cr_crapope%NOTFOUND THEN
      -- Gera crítica
      vr_cdcritic := 67;
      -- Fecha cursor
      CLOSE cr_crapope;
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    -- Fecha cursor
    CLOSE cr_crapope;

    IF pr_nrcpfcgc = 0 THEN
      -- Código da crítica
      vr_cdcritic := 27;
      pr_nmdcampo := 'nrcpfcgc';
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;

    -- Valida cpf ou cnpj
    gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_nrcpfcgc
                               ,pr_stsnrcal => vr_stsnrcal
                               ,pr_inpessoa => vr_inpessoa);

    IF NOT vr_stsnrcal THEN
      -- Código da crítica
      vr_cdcritic := 27;
      pr_nmdcampo := 'nrcpfcgc';
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;

    IF pr_nrdconta <> 0 THEN
      -- Procura conta do associado
      OPEN cr_crapass(pr_cdcoplib, pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        -- Código da crítica
        vr_cdcritic := 9;
        pr_nmdcampo := 'nrdconta';
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;

    END IF;

    -- Busca operações
    OPEN cr_craprot;
    FETCH cr_craprot INTO rw_craprot;

    IF cr_craprot%NOTFOUND THEN
      -- Gera crítica
      vr_dscritic := 'Operacao nao cadastrada';
      pr_nmdcampo := 'cdoperac';
      -- Fecha cursor
      CLOSE cr_craprot;
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    -- Fecha cursor
    CLOSE cr_craprot;


    IF pr_dsjuslib = '' THEN
      -- Gera crítica
      vr_cdcritic := 375;
      pr_nmdcampo := 'dsjuslib';
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;

    -- Buscar ultimo numero de liberação de justificativa
    OPEN cr_craplju;
    FETCH cr_craplju INTO rw_craplju;

    -- Se não encontrou iniciamos com 1
    IF rw_craplju.nrjuslib IS NULL THEN
      vr_nrjuslib := 1;
    ELSE -- Se encontrou incrementamos pelo último registro
      vr_nrjuslib := rw_craplju.nrjuslib + 1;
    END IF;
    -- Fecha cursor
    CLOSE cr_craplju;

    INSERT INTO craplju
           (nrcpfcgc
           ,nrjuslib
           ,cdcoplib
           ,cdagenci
           ,cdopelib
           ,nrdconta
           ,dtmvtolt
           ,hrtransa
           ,dsjuslib
           ,cdcooper
           ,cdoperad
           ,cdoperac
           ,flgsiste)
   VALUES (pr_nrcpfcgc
          ,vr_nrjuslib
          ,pr_cdcoplib
          ,pr_cdagelib
          ,pr_cdopelib
          ,pr_nrdconta
          ,pr_dtmvtolt
          ,to_char(SYSDATE, 'HH:MI:SS')
          ,pr_dsjuslib
          ,pr_cdcooper
          ,pr_cdoperad
          ,pr_cdoperac
          ,pr_flgsiste);

    pr_des_erro := 'OK';
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN

      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_liberar_cad_restritivo ' ||
                     SQLERRM;
      pr_des_erro := 'NOK';

    END;
  END pc_liberar_cad_restritivo;

  PROCEDURE pc_envia_email_alerta (pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE --> PA
                                  ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE --> Nr. do caixa
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE --> Cód. operador
                                  ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da tela
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de movimento
                                  ,pr_idorigem IN INTEGER               --> ID de origem
                                  ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE --> Nr. do CPF/CNPJ
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Id de sequencia do titular
                                  ,pr_nmprimtl IN crapttl.nmextttl%TYPE --> Nome do primeiro titular
                                  ,pr_nmpessoa IN crapcrt.nmpessoa%TYPE --> Nome da pessoa
                                  ,pr_cdoperac IN INTEGER               --> Cód. da operação
                                  ,pr_dsoperac IN VARCHAR2              --> Desc. da operação
                                  ,pr_cdcritic OUT INTEGER              --> Cód. da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Desc. da crítica
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Retorno de erro OK/NOK
  BEGIN
  /* .............................................................................

     Programa: pc_envia_email_alerta (Antigo b1wgen0110.p/pc_envia_email_alerta)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Reinert
     Data    : Fevereiro/2016.                         Ultima atualizacao: 05/08/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado.
     Objetivo  : Enviar email de alerta

     Alteracoes: Ajustado problema de conversão para resolver o problema
                 do chamado 496948. (Kelvin)
  ............................................................................. */
    DECLARE

      -- Variáveis locais
      vr_cdagenci crapage.cdagenci%TYPE;
      vr_nmextage crapage.nmextage%TYPE;
      vr_lsemails VARCHAR2(1000);
      vr_conteudo VARCHAR2(3000);
      vr_dsorigem VARCHAR2(40);
      vr_nrdrowid ROWID;
      vr_nmoperad VARCHAR2(100);
      vr_inpessoa INTEGER;
      vr_stsnrcal BOOLEAN;
      vr_nrcpfcgc VARCHAR2(40);
      vr_contador INTEGER;
      vr_emailenv VARCHAR2(1000);
      -- Tratamento de erros
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(3000);
      vr_exc_erro EXCEPTION;

      ---------------------> CURSORES <----------------------
      -- Valida cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Valida operador
      CURSOR cr_crapope IS
        SELECT ope.nmoperad
              ,ope.cdpactra
          FROM crapope ope
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;

    -- Buscar PA do operador
    CURSOR cr_crapope_age IS
      SELECT age.cdagenci
            ,age.nmextage
        FROM crapope ope,
             crapage age
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad
         AND age.cdcooper = ope.cdcooper
         AND age.cdagenci = ope.cdpactra;
    rw_crapope_age cr_crapope_age%ROWTYPE;

    -- Busca lista de emails
    CURSOR cr_craptab IS
      SELECT tab.dstextab
        FROM craptab tab
       WHERE tab.cdcooper = pr_cdcooper
         AND tab.nmsistem = 'CRED'
         AND tab.tptabela = 'GENERI'
         AND tab.cdempres = 0
         AND tab.tpregist = 1
         AND tab.cdacesso = 'EMAILCADRESTRITIVO';
    rw_craptab cr_craptab%ROWTYPE;

    -- Busca operação/rotina
    CURSOR cr_craprot IS
      SELECT rot.cdoperac
            ,rot.dsoperac
        FROM craprot rot
       WHERE rot.cdoperac = pr_cdoperac;
    rw_craprot cr_craprot%ROWTYPE;

    BEGIN
      -- Verifica cooperativa
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Gera crítica
        vr_cdcritic := 794;
        -- Fecha cursor
        CLOSE cr_crapcop;
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
      CLOSE cr_crapcop;

      -- Busca PA do operador
      OPEN cr_crapope_age;
      FETCH cr_crapope_age INTO rw_crapope_age;

      -- Se encontrar PA
      IF cr_crapope_age%FOUND THEN
        -- Se encontrou alimenta variáveis
        vr_cdagenci := rw_crapope_age.cdagenci;
        vr_nmextage := rw_crapope_age.nmextage;
      ELSE
        -- Gera crítica
        vr_cdcritic := 15;
        -- Fecha cursor
        CLOSE cr_crapope_age;
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
      CLOSE cr_crapope_age;

      -- Busca emails
      OPEN cr_craptab;
      FETCH cr_craptab INTO rw_craptab;

      IF cr_craptab%NOTFOUND THEN
        -- Gera crítica
        vr_cdcritic := 812;
        -- Fecha cursor
        CLOSE cr_craptab;
        -- Levanta exceção
        RAISE vr_exc_erro;
      ELSE
        -- Armazena lista de emails
        vr_lsemails := rw_craptab.dstextab;
      END IF;
      -- Fecha cursor
      CLOSE cr_craptab;

      -- Busca rotinas/operações
      OPEN cr_craprot;
      FETCH cr_craprot INTO rw_craprot;

      -- Se não encontrou rotina/operação
      IF cr_craprot%NOTFOUND THEN
        -- Gera crítica
        vr_cdcritic := 'Rotina nao cadastrada';
        -- Fecha cursor
        CLOSE cr_craprot;
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
      CLOSE cr_craprot;

      -- Valida cpf ou cnpj
      gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_nrcpfcgc
                                 ,pr_stsnrcal => vr_stsnrcal
                                 ,pr_inpessoa => vr_inpessoa);

      IF NOT vr_stsnrcal THEN
        -- Gera crítica
        vr_cdcritic := 27;
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;

      -- Busca CPF ou CNPJ
      vr_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => pr_nrcpfcgc
                                              ,pr_inpessoa => vr_inpessoa);

      -- Busca origem
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_conteudo := ' - Cooperativa.............: ' || rw_crapcop.nmrescop ||
                     '.\n' || ' - PA........................: ' ||
                     to_char(vr_cdagenci) || ' - ' || vr_nmextage || '.\n' ||
                     ' - Operador.................: ' || pr_cdoperad ||
                     ' - ' || vr_nmoperad || '.\n';
      IF pr_nrdconta = 0 THEN
        vr_conteudo := vr_conteudo ||
                       ' - O CPF/CNPJ ' || vr_nrcpfcgc ||
                       ' esta no cadastro restritivo. \n';
      ELSE
        IF vr_inpessoa = 1 THEN
          vr_conteudo := vr_conteudo ||
                         ' - O CPF/CNPJ ' || vr_nrcpfcgc ||
                         ' esta no cadastro restritivo. \n';
        ELSE
          vr_conteudo := vr_conteudo ||
                         ' - A conta ' || gene0002.fn_mask_conta(pr_nrdconta) ||
                         ' - CPF/CNPJ ' || vr_nrcpfcgc || ' esta no ' ||
                         'cadastro restritivo.\n';
        END IF;
      END IF;
      vr_conteudo := vr_conteudo ||
                     ' - Operacao realizada..: ' || pr_dsoperac || '.\n' ||
                     ' - Rotina......................: ' ||
                     to_char(rw_craprot.cdoperac) || ' - ' ||
                     rw_craprot.dsoperac || '.\n' ||
                     ' - Nome/Cooperado....: ' || pr_nmprimtl || '.\n' ||
                     ' - Nome/Cad. Restritivo: ' || pr_nmpessoa || '.';

      gene0003.pc_solicita_email(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => pr_nmdatela
                                ,pr_des_destino => vr_lsemails
                                ,pr_des_assunto => rw_crapcop.nmrescop || ' - ' ||
                                                   'CADASTRO RESTRITIVO!'
                                ,pr_des_corpo => vr_conteudo
                                ,pr_des_anexo => NULL
                                ,pr_des_erro => vr_dscritic);

      -- Coloca um espacaço após a virgula
      vr_emailenv := REPLACE(SRCSTR => vr_lsemails
                            ,OLDSUB => ','
                            ,NEWSUB => ', ');

      IF vr_emailenv IS NULL THEN
        vr_emailenv := 'nenhum destinatario';
      END IF;

      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log =>
                                to_char(pr_dtmvtolt) || ' ' ||
                                to_char(SYSDATE, 'HH:MI:SS') || ' --> ' ||
                                'Operador ' || pr_cdoperad || ', operacao: ' ||
                                pr_dsoperac || ' rotina: ' || rw_craprot.dsoperac ||
                                '. Enviado e-mail para ' || vr_emailenv
                                ,pr_nmarqlog => 'alerta.log');

      pr_des_erro := 'OK';
      -- Efetua commit
      COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN

      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_envia_email_alerta ' ||
                     SQLERRM;
      pr_des_erro := 'NOK';
    END;
  END pc_envia_email_alerta;


  -- Geracao de log para operacoes que podem utilizar o cartao
  PROCEDURE pc_gera_log_ope_cartao(pr_cdcooper    tbcrd_log_operacao.cdcooper%TYPE, -- Codigo da cooperativa
                                   pr_nrdconta    tbcrd_log_operacao.nrdconta%TYPE, -- Numero da conta
                                   pr_indoperacao tbcrd_log_operacao.indoperacao%TYPE,  -- Operacao realizada no log (1-Saque/2-Doc/3-Ted/4-Transferencia/5-Talao de cheque)
                                   pr_cdorigem    tbcrd_log_operacao.cdorigem%TYPE, -- Origem do lancamento (1-Ayllos/2-Caixa/3-Internet/4-Cash/5-Ayllos WEB/6-URA/7-Batch/8-Mensageria)
                                   pr_indtipo_cartao tbcrd_log_operacao.tpcartao%TYPE,  -- Tipo de cartao utilizado. (0-Sem cartao/1-Magnetico/2-Cartao Cecred)
                                   pr_nrdocmto    tbcrd_log_operacao.nrdocmto%TYPE, -- Numero do documento utilizado no lancamento
                                   pr_cdhistor    tbcrd_log_operacao.cdhistor%TYPE, -- Codigo do historico utilizado no lancamento
                                   pr_nrcartao    VARCHAR2, -- Numero do cartao utilizado. Zeros quando nao existe cartao
                                   pr_vllanmto    tbcrd_log_operacao.vloperacao%TYPE, -- Valor do lancamento
                                   pr_cdoperad    tbcrd_log_operacao.cdoperad%TYPE, -- Codigo do operador
                                   pr_cdbccrcb    tbcrd_log_operacao.cdbanco_receb%TYPE, -- Codigo do banco de destino para os casos de TED e DOC
                                   pr_cdfinrcb    tbcrd_log_operacao.cdfinalid_operacao%TYPE, -- Codigo da finalidade para operacoes de TED e DOC
                                   pr_cdpatrab    crapope.cdpactra%TYPE, -- Codigo do PA de trabalho do operador
                                   pr_nrseqems    crapfdc.nrseqems%TYPE, -- Numero da sequencia da emissao do cheque
                                   pr_nmreceptor  crapass.nmprimtl%TYPE, -- Nome do terceiro que recebeu o o talonario do cheque
                                   pr_nrcpf_receptor crapass.nrcpfcgc%TYPE, -- Numero do CPF do terceiro que recebeu o o talonario do cheque
                                   pr_dscritic OUT varchar2) IS -- Descricao do erro quando houver
    /* ..........................................................................
    --
    --  Programa : pc_gera_log_ope_cartao
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Andrino Carlos de Souza Junior (RKAM)
    --  Data     : Abril/2016.                   Ultima atualizacao: 12/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar log para os processos que utilizam o cartao no caixa online
    --
    --  Alteração : 07/06/2016 - Austes para recebimento de transferencia (Andrino - Projeto 290 -
    --                           Caixa OnLine)
    --
    --  Alteração : 08/06/2016 - Ajustado a leitura da craptab das informacoes de 'FINTRFDOCS'
    --                           e 'FINTRFTEDS' para utilizar a rotina padrao da TABE0001
    --                           (Douglas - Chamado 454248)
    --
    --  Alteração : 14/11/2016 - Ajustado para ler o cdorigem da gene0001 e não utilizar
    --                           ifs no programa(Odirlei-AMcom)
    --
    --  Alteração : 12/12/2017 - Alterar para para varchar2 o campo nrcartao
    --                           (Lucas Ranghetti #810576)
    --
    --  Alteração : 03/04/2018 - Alterar para o "Tipo de aprovacao" para "Saque com cartao CECRED"
    --                           (Andrey Formigari - Mouts #845782)
    --							 
    --  Alteração : 19/06/2019 - Ajuste para logar entrega de talonario.
    --                           (Lucas Lombardi)
     ............................................................................*/

    -- Cursor para retornar o nome do banco
    CURSOR cr_crapban IS
      SELECT nmextbcc
        FROM crapban
       WHERE cdbccxlt = pr_cdbccrcb;
    rw_crapban cr_crapban%ROWTYPE;

    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    vr_rowid_log ROWID; -- Rowid do log gerado
    vr_dstransa  craplgm.dstransa%TYPE; -- Data que ocorreu a transacao
    vr_dsorigem  craplgm.dsorigem%TYPE; -- Origem do lancamento
    vr_indgrlog  BOOLEAN := TRUE; -- Indicador de gravcao de log

    vr_dstextab  craptab.dstextab%TYPE; -- Dados da craptab
  BEGIN
    -- Busca a data da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Atualiza a descricao da transacao
    IF pr_indoperacao = 1 THEN -- Se for operacao de saque
      IF pr_indtipo_cartao = 0 THEN -- Se foi feito com recibo
        vr_dstransa := 'Saque com recibo';
      ELSIF pr_indtipo_cartao = 1 THEN -- Se foi feito com cartao magnetico
        vr_dstransa := 'Saque com cartao magnetico';
      ELSE -- Se foi feito com cartao Cecred
        vr_dstransa := 'Saque com cartao AILOS';
      END IF;
    ELSIF pr_indoperacao = 2 THEN -- Se for DOC
      vr_dstransa := 'DOC';
    ELSIF pr_indoperacao = 3 THEN -- Se for TED
      vr_dstransa := 'TED';
      -- Se for diferente do caixa online nao deve gerar log, pois o mesmo ja gera
      IF pr_cdorigem <> 2 THEN
        vr_indgrlog := FALSE;
      END IF;
    ELSIF pr_indoperacao = 4 THEN -- Se for transfernecia
      vr_dstransa := 'Transferência';
    ELSIF pr_indoperacao = 5 THEN -- Se for solicitacao de taloes
      vr_dstransa := 'Solicitação de Talões';
    ELSIF pr_indoperacao = 6 THEN -- Se for solicitacao de taloes
      vr_dstransa := 'Pagamento';
    ELSIF pr_indoperacao = 7 THEN -- Se for entrega de taloes
      vr_dstransa := 'Entrega de Talões';
    END IF;

    -- Preenche a descricao da origem
    IF vr_dsorigem > gene0001.vr_vet_des_origens.count() THEN
      vr_dsorigem := 'OUTROS';
    ELSE
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_cdorigem);
    END IF;

    -- Se deve gerar log na VERLOG
    IF vr_indgrlog THEN
      -- Efetua os inserts para apresentacao na tela VERLOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => trunc(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => ' '
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_rowid_log);

      -- Se a entrega foi para um terceiro, nao tem cartao
      IF nvl(pr_nrcpf_receptor,0) > 0 THEN
        -- Gera o log para o CPF do terceiro
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                 ,pr_nmdcampo => 'CPF Terceiro'
                                 ,pr_dsdadant => ' '
                                 ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(pr_nrcpf_receptor,1));
        -- Gera o log para o nome do terceiro
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                 ,pr_nmdcampo => 'Nome Terceiro'
                                 ,pr_dsdadant => ' '
                                 ,pr_dsdadatu => pr_nmreceptor);
      ELSIF pr_indtipo_cartao = 0 THEN -- Se for via recibo
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                 ,pr_nmdcampo => 'Tipo de aprovacao'
                                 ,pr_dsdadant => ' '
                                 ,pr_dsdadatu => 'Recibo');
      ELSIF pr_indtipo_cartao = 1 THEN -- Se for via cartao magnetico
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                 ,pr_nmdcampo => 'Tipo de aprovacao'
                                 ,pr_dsdadant => ' '
                                 ,pr_dsdadatu => 'Magnetico');
      ELSIF pr_indtipo_cartao = 2 THEN -- Se for por senha
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                 ,pr_nmdcampo => 'Tipo de aprovacao'
                                 ,pr_dsdadant => ' '
                                 ,pr_dsdadatu => 'Aprovado por senha');
      END IF;

      -- Gera o log dos itens para numero do cartao
      IF pr_indtipo_cartao <> 0 THEN -- Se foi utilizado cartao
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                 ,pr_nmdcampo => 'Numero do cartao'
                                 ,pr_dsdadant => ' '
                                 ,pr_dsdadatu => pr_nrcartao);
      END IF;

      -- Gera o log dos itens para numero do documento
      IF pr_nrdocmto > 0 AND -- Se possuir codigo do documento
         pr_indoperacao <> 5 AND
         pr_indoperacao <> 7 THEN -- Se for diferente de solicitacao de taloes

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                 ,pr_nmdcampo => 'Numero do documento'
                                 ,pr_dsdadant => ' '
                                 ,pr_dsdadatu => pr_nrdocmto);
      END IF;

      -- Gera o log dos itens para valor do saque
      IF pr_vllanmto > 0 THEN -- Se possuir valor de saque
        IF pr_indoperacao = 5 OR
           pr_indoperacao = 7 THEN -- Se for solicitacao de taloes
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                   ,pr_nmdcampo => 'Qtde taloes solicitados'
                                   ,pr_dsdadant => ' '
                                   ,pr_dsdadatu => pr_vllanmto);
        ELSE
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                 ,pr_nmdcampo => 'Valor do lancamento'
                                 ,pr_dsdadant => ' '
                                 ,pr_dsdadatu => to_char(pr_vllanmto,'fm999g999g990d00'));
        END IF;
      END IF;

      -- Se possuir banco de destino
      IF nvl(pr_cdbccrcb,0) > 0 THEN
        -- Busca o banco de destino
        OPEN cr_crapban;
        FETCH cr_crapban INTO rw_crapban;
        CLOSE cr_crapban;

        -- Gera o log com o banco de destino
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                 ,pr_nmdcampo => 'Banco de destino'
                                 ,pr_dsdadant => ' '
                                 ,pr_dsdadatu => pr_cdbccrcb||'-'||rw_crapban.nmextbcc);

      END IF;

      -- Se possuir finalidade
      IF nvl(pr_cdfinrcb,0) > 0 THEN
        -- Busca a descricao da finalidade
        IF pr_indoperacao = 2 THEN -- Se for DOC
          vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 00
                                                   ,pr_cdacesso => 'FINTRFDOCS'
                                                   ,pr_tpregist => pr_cdfinrcb);
        ELSE --- Se for TED
          vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 00
                                                   ,pr_cdacesso => 'FINTRFTEDS'
                                                   ,pr_tpregist => pr_cdfinrcb);
        END IF;

        -- Gera o log da finalidade
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                 ,pr_nmdcampo => 'Finalidade'
                                 ,pr_dsdadant => ' '
                                 ,pr_dsdadatu => pr_cdfinrcb||'-'||vr_dstextab);


      END IF;
    END IF;

    -- Se possuir numero do talao
    IF nvl(pr_nrseqems,0) > 0 THEN
      -- Gera o log da finalidade
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                               ,pr_nmdcampo => 'Talao'
                               ,pr_dsdadant => ' '
                               ,pr_dsdadatu => pr_nrseqems);
    END IF;

    -- Insere na tabela de log de operacoes, para ser utilizado no BI
    LOOP
      BEGIN
        INSERT INTO tbcrd_log_operacao
          (cdcooper,
           nrdconta,
           dttransacao,
           hrtransacao,
           indoperacao,
           cdorigem,
           tpcartao,
           dtmvtolt,
           nrdocmto,
           cdhistor,
           nrcartao,
           cdbanco_receb,
           vloperacao,
           cdfinalid_operacao,
           cdoperad,
           cdpac_solicitacao,
           nrseq_emissao_chq,
           nmreceptor,
           nrcpf_receptor)
        VALUES
          (pr_cdcooper,
           pr_nrdconta,
           trunc(SYSDATE),
           to_char(SYSDATE,'SSSSS'),
           pr_indoperacao,
           pr_cdorigem,
           pr_indtipo_cartao,
           rw_crapdat.dtmvtolt,
           pr_nrdocmto,
           pr_cdhistor,
           pr_nrcartao,
           decode(pr_indoperacao,4,85,pr_cdbccrcb),-- Se for transferencia, considerar como banco CECRED,
                                                   -- conforme solicitacao da Monique (31/05/2016)
           pr_vllanmto,
           pr_cdfinrcb,
           pr_cdoperad,
           pr_cdpatrab,
           pr_nrseqems,
           pr_nmreceptor,
           pr_nrcpf_receptor);
      EXCEPTION
        WHEN dup_val_on_index THEN
          continue; -- Volta para o inicio do loop, para pegar o proximo segundo na hrtransacao
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao inserir na tbcrd_log_operacao: '||SQLERRM;
          ROLLBACK;
          RETURN;
      END;

      EXIT; -- sai do loop
    END LOOP;


  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral rotina PC_GERA_LOG_OPE_CARTAO: '||SQLERRM;
      ROLLBACK;
  END;

  -- Busca o tipo de cartao nas operacoes de TED, DOC e transferencia
  PROCEDURE pc_busca_tipo_cartao_mvt(pr_cdcooper  IN tbcrd_log_operacao.cdcooper%TYPE, -- Codigo da cooperativa
                                     pr_nrdconta  IN tbcrd_log_operacao.nrdconta%TYPE, -- Numero da conta
                                     pr_nrdocmto  IN tbcrd_log_operacao.nrdocmto%TYPE, -- Numero do documento utilizado no lancamento
                                     pr_cdhistor  IN tbcrd_log_operacao.cdhistor%TYPE, -- Codigo do historico utilizado no lancamento
                                     pr_dtmvtolt  IN tbcrd_log_operacao.dtmvtolt%TYPE, -- Data do movimento
                                     pr_tpcartao OUT tbcrd_log_operacao.tpcartao%TYPE, -- Tipo de cartao
                                     pr_dscritic OUT varchar2) IS -- Descricao do erro quando houver
    /* ..........................................................................
    --
    --  Programa : pc_busca_tipo_cartao_mvt
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Andrino Carlos de Souza Junior (RKAM)
    --  Data     : Julho/2016.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar o tipo de cartao utilizado
    --
    -- ..........................................................................*/
  CURSOR cr_log IS
    SELECT tpcartao
      FROM tbcrd_log_operacao a
     WHERE cdcooper = pr_cdcooper
       AND dtmvtolt = pr_dtmvtolt
       AND nrdconta = pr_nrdconta
       AND cdhistor = pr_cdhistor
       AND nrdocmto = pr_nrdocmto
       AND indoperacao IN (2,3,4,6);
  BEGIN
    OPEN cr_log;
    FETCH cr_log INTO pr_tpcartao;
    IF cr_log%NOTFOUND THEN
      pr_tpcartao := 9;
    END IF;
    CLOSE cr_log;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro rotina pc_busca_tipo_cartao_mvt: '||SQLERRM;
  END;

  /******************************************************************************/
  /**   Busca quantidades de talões entregues por requisição e por cartão      **/
  /******************************************************************************/
  PROCEDURE pc_busca_qtd_entrega_talao
                        ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                         ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                         ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de movimento
                         ---------- OUT --------
                         ,pr_qtentreq OUT INTEGER               --> Quantidade de entragas de talao por requisição
                         ,pr_qtentcar OUT INTEGER               --> Quantidade de entragas de talao por cartão
                         ,pr_cdcritic OUT INTEGER
                         ,pr_dscritic OUT VARCHAR2) IS

  /* ..........................................................................
    --
    --  Programa : pc_busca_qtd_entrega_talao
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : julho/2016.                   Ultima atualizacao: 11/07/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Busca quantidades de talões entregues por requisição e por cartão
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <----------------
    --> Buscar quantidades de cartões entregues
    CURSOR cr_log_operacao IS
      SELECT COUNT(DECODE(a.tpcartao,0,1,NULL)) qt_requisicao,
             COUNT(DECODE(a.tpcartao,0,NULL,1)) qt_cartao
        FROM tbcrd_log_operacao a
       WHERE a.cdcooper    = pr_cdcooper
         AND a.indoperacao = 5
         AND a.nrdocmto    = pr_nrdcaixa
         AND a.dtmvtolt    = pr_dtmvtolt
         AND a.cdpac_solicitacao = pr_cdagenci
         AND a.nrseq_emissao_chq > 0;
    rw_log_operacao cr_log_operacao%ROWTYPE;

    --------------> Variaveis <----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(200);
    vr_nrdrowid ROWID;

    vr_idxass   PLS_INTEGER;
    vr_idxobs   PLS_INTEGER;
  BEGIN

    --> Buscar quantidades de cartões entregues
    OPEN cr_log_operacao;
    FETCH cr_log_operacao INTO rw_log_operacao;
    IF cr_log_operacao%NOTFOUND THEN
      pr_qtentreq := 0;
      pr_qtentcar := 0;
    ELSE
      pr_qtentreq  := rw_log_operacao.qt_requisicao;
      pr_qtentcar  := rw_log_operacao.qt_cartao;
    END IF;
    CLOSE cr_log_operacao;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel buscar dados pc_busca_qtd_entrega_talao: '||SQLERRM;
  END pc_busca_qtd_entrega_talao;

  PROCEDURE pc_inserir_cnae_bloqueado(pr_cdcnae     IN tbcc_cnae_bloqueado.cdcnae%TYPE         --> Codigo do CNAE
                                     ,pr_dsmotivo   IN tbcc_cnae_bloqueado.dsmotivo%TYPE       --> Motivo da inclusao
                                     ,pr_dtarquivo  IN tbcc_cnae_bloqueado.dtarquivo%TYPE      --> Data do arquivo
                                     ,pr_tpbloqueio IN tbcc_cnae_bloqueado.tpbloqueio%TYPE     --> Tipo de bloqueio do CNAE (0-Restrito, 1-Proibido)
                                     ,pr_tpinclusao IN tbcc_cnae_bloqueado.tpinclusao%TYPE     --> Tipo de inclusão (0-Manual, 1-Arquivo)
                                     ,pr_dtmvtolt   IN tbcc_cnae_bloqueado.dtmvtolt%TYPE       --> Data atual
                                     ,pr_dslicenca  IN tbcc_cnae_bloqueado.dslicenca%TYPE      --> Licencas necessarias
                                     ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                  --> Codigo de critica
                                     ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS              --> Descricao da critica
  BEGIN
    DECLARE
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    BEGIN

      -- Inserir
      BEGIN
        INSERT
          INTO tbcc_cnae_bloqueado(cdcnae,        dsmotivo
                                  ,dtarquivo,     tpbloqueio
                                  ,tpinclusao,    dtmvtolt
                                  ,dslicenca)
                            VALUES(pr_cdcnae,     pr_dsmotivo
                                  ,pr_dtarquivo,  pr_tpbloqueio
                                  ,pr_tpinclusao, pr_dtmvtolt
                                  ,pr_dslicenca);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          vr_cdcritic := 0;
          vr_dscritic := 'CNAE já cadastrado.';
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro geral em CADA0004.pc_inserir_cnae_bloqueado: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0004.pc_inserir_cnae_bloqueado: ' || SQLERRM;

    END;
  END pc_inserir_cnae_bloqueado;

  PROCEDURE pc_atualizar_cnae_bloqueado(pr_cdcnae     IN tbcc_cnae_bloqueado.cdcnae%TYPE         --> Codigo do CNAE
                                       ,pr_dsmotivo   IN tbcc_cnae_bloqueado.dsmotivo%TYPE       --> Motivo da inclusao
                                       ,pr_dtarquivo  IN tbcc_cnae_bloqueado.dtarquivo%TYPE      --> Data do arquivo
                                       ,pr_tpbloqueio IN tbcc_cnae_bloqueado.tpbloqueio%TYPE     --> Tipo de bloqueio do CNAE (0-Restrito, 1-Proibido)
                                       ,pr_tpinclusao IN tbcc_cnae_bloqueado.tpinclusao%TYPE     --> Tipo de inclusão (0-Manual, 1-Arquivo)
                                       ,pr_dtmvtolt   IN tbcc_cnae_bloqueado.dtmvtolt%TYPE       --> Data atual
                                       ,pr_dslicenca  IN tbcc_cnae_bloqueado.dslicenca%TYPE      --> Licencas necessarias
                                       ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                  --> Codigo de critica
                                       ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS              --> Descricao da critica
  BEGIN
    DECLARE

      CURSOR cr_cnae_blq(pr_cdcnae tbcc_cnae_bloqueado.cdcnae%TYPE) IS
        SELECT tbcc_cnae_bloqueado.cdcnae
          FROM tbcc_cnae_bloqueado
         WHERE tbcc_cnae_bloqueado.cdcnae = pr_cdcnae;
      rw_cnae_blq cr_cnae_blq%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    BEGIN

      OPEN cr_cnae_blq(pr_cdcnae => pr_cdcnae);
      FETCH cr_cnae_blq INTO rw_cnae_blq;

      IF cr_cnae_blq%NOTFOUND THEN -->Nao disparar critica apenas nao atualiza
         CLOSE cr_cnae_blq;
         vr_cdcritic := 0;
         vr_dscritic := '';
         RAISE vr_exc_saida;
      END IF;

      CLOSE cr_cnae_blq;

      -- Update
      BEGIN
        UPDATE tbcc_cnae_bloqueado
           SET tbcc_cnae_bloqueado.dsmotivo   = pr_dsmotivo
              ,tbcc_cnae_bloqueado.dtarquivo  = pr_dtarquivo
              ,tbcc_cnae_bloqueado.tpbloqueio = pr_tpbloqueio
              ,tbcc_cnae_bloqueado.tpinclusao = pr_tpinclusao
              ,tbcc_cnae_bloqueado.dtmvtolt   = pr_dtmvtolt
              ,tbcc_cnae_bloqueado.dslicenca  = pr_dslicenca
         WHERE tbcc_cnae_bloqueado.cdcnae     = pr_cdcnae;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro geral em CADA0004.pc_atualizar_cnae_bloqueado: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0004.pc_atualizar_cnae_bloqueado: ' || SQLERRM;

    END;
  END pc_atualizar_cnae_bloqueado;

  PROCEDURE pc_excluir_cnae_bloqueado(pr_cdcnae     IN tbcc_cnae_bloqueado.cdcnae%TYPE         --> Codigo do CNAE
                                     ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                  --> Codigo de critica
                                     ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS              --> Descricao da critica
  BEGIN
    DECLARE
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    BEGIN

      -- Excluir
      BEGIN
        DELETE FROM tbcc_cnae_bloqueado WHERE tbcc_cnae_bloqueado.cdcnae = pr_cdcnae;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro geral em CADA0004.pc_excluir_cnae_bloqueado: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0004.pc_excluir_cnae_bloqueado: ' || SQLERRM;

    END;
  END pc_excluir_cnae_bloqueado;

  PROCEDURE pc_buscar_cnae_bloqueado(pr_cdcnae   IN tbgen_cnae.cdcnae%TYPE --> Codigo do CNAE
                                    ,pr_dscnae   IN tbgen_cnae.dscnae%TYPE --> Descricao do CNAE
                                    ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                                    ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

      -- Cursor sobre a tabela do CNAE
      CURSOR cr_cnae_bloqueado(pr_cdcnae tbcc_cnae_bloqueado.cdcnae%TYPE
                              ,pr_dscnae tbgen_cnae.dscnae%TYPE) IS
        SELECT a.cdcnae,
               gene0007.fn_caract_acento(b.dscnae) dscnae,
               gene0007.fn_caract_acento(a.dsmotivo) dsmotivo,
               a.tpbloqueio,
               a.dslicenca,
               a.dtmvtolt,
               a.dtarquivo,
               count(1) over() retorno
          FROM tbcc_cnae_bloqueado a, tbgen_cnae b
         WHERE a.cdcnae = b.cdcnae
           AND a.cdcnae = decode(nvl(pr_cdcnae,0),0,a.cdcnae, pr_cdcnae)
           AND (trim(pr_dscnae) IS NULL
            OR  b.dscnae LIKE '%'||pr_dscnae||'%')
         ORDER BY a.cdcnae;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_posreg   PLS_INTEGER := 0;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

        -- Loop sobre a tabela de CNAE
        FOR rw_cnae_bloqueado IN cr_cnae_bloqueado(pr_cdcnae => pr_cdcnae
                                                  ,pr_dscnae => pr_dscnae)  LOOP

          -- Incrementa o contador de registros
          vr_posreg := vr_posreg + 1;

          -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
          IF vr_posreg = 1 THEN
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<CNAE qtregist="' || rw_cnae_bloqueado.retorno || '">');
          END IF;

          -- Enviar somente se a linha for superior a linha inicial
          IF nvl(pr_nriniseq,0) <= vr_posreg THEN

            -- Carrega os dados
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<inf>'||
                                                            '<cdcnae>' || rw_cnae_bloqueado.cdcnae ||'</cdcnae>'||
                                                            '<dscnae>' || rw_cnae_bloqueado.dscnae ||'</dscnae>'||
                                                            '<dsmotivo>' || rw_cnae_bloqueado.dsmotivo ||'</dsmotivo>'||
                                                            '<tpbloqueio>' || rw_cnae_bloqueado.tpbloqueio ||'</tpbloqueio>'||
                                                            '<dslicenca>' || rw_cnae_bloqueado.dslicenca ||'</dslicenca>'||
                                                            '<dtmvtolt>' || TO_CHAR(rw_cnae_bloqueado.dtmvtolt,'DD/MM/RRRR') ||'</dtmvtolt>'||
                                                            '<dtarquivo>' || TO_CHAR(rw_cnae_bloqueado.dtarquivo,'DD/MM/RRRR') ||'</dtarquivo>'||
                                                         '</inf>');
            vr_contador := vr_contador + 1;
          END IF;

          -- Deve-se sair se o total de registros superar o total solicitado
          EXIT WHEN vr_contador > nvl(pr_nrregist,99999);

        END LOOP;

        -- Se nao possuir nenhum registro, envia a quantidade de registros zerada
        IF vr_posreg = 0 THEN
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<CNAE qtregist="0">');
        END IF;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</CNAE></Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na busca do CNAE: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_buscar_cnae_bloqueado;

  PROCEDURE pc_cria_cnae_proibido_web(pr_cdcnae     IN  tbcc_cnae_bloqueado.cdcnae%TYPE
                                     ,pr_dsmotivo   IN  tbcc_cnae_bloqueado.dsmotivo%TYPE
                                     ,pr_tpbloqueio IN  tbcc_cnae_bloqueado.tpbloqueio%TYPE
                                     ,pr_tpinclusao IN  tbcc_cnae_bloqueado.tpinclusao%TYPE
                                     ,pr_dtarquivo  IN  VARCHAR2
                                     ,pr_dtmvtolt   IN  VARCHAR2
                                     ,pr_dslicenca  IN  VARCHAR2
                                     ,pr_xmllog     IN  VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml     IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                     ,pr_des_erro   OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_auxconta PLS_INTEGER := 0;
      vr_nmarqpdf VARCHAR2(500);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

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
        RAISE vr_exc_saida;
      END IF;

      -- Inserir
      pc_inserir_cnae_bloqueado(pr_cdcnae     => pr_cdcnae
                               ,pr_dsmotivo   => pr_dsmotivo
                               ,pr_dtarquivo  => TO_DATE(pr_dtmvtolt,'DD/MM/RRRR')
                               ,pr_dtmvtolt   => TO_DATE(pr_dtmvtolt,'DD/MM/RRRR')
                               ,pr_tpbloqueio => pr_tpbloqueio
                               ,pr_tpinclusao => pr_tpinclusao
                               ,pr_dslicenca  => pr_dslicenca
                               ,pr_cdcritic   => vr_cdcritic
                               ,pr_dscritic   => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      --gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      --gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0004.pc_cria_cnae_proibido_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_cria_cnae_proibido_web;

  PROCEDURE pc_exclui_cnae_proibido_web(pr_cdcnae     IN  tbcc_cnae_bloqueado.cdcnae%TYPE
                                       ,pr_xmllog     IN  VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml     IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

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
        RAISE vr_exc_saida;
      END IF;

      -- Inserir
      pc_excluir_cnae_bloqueado(pr_cdcnae     => pr_cdcnae
                               ,pr_cdcritic   => vr_cdcritic
                               ,pr_dscritic   => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0004.pc_exclui_cnae_proibido_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_exclui_cnae_proibido_web;

  PROCEDURE pc_limpa_cnae_bloqueado(pr_cdcritic   OUT PLS_INTEGER    --> Código da crítica
                                   ,pr_dscritic   OUT VARCHAR2) IS   --> Descrição da crítica

  BEGIN
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

    BEGIN

      BEGIN
        DELETE FROM tbcc_cnae_bloqueado;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE vr_exc_saida;
      END;

    EXCEPTION
      WHEN vr_exc_saida THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel limpar a tabela de CNAEs bloqueados.';

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em CADA0004.pc_limpa_cnae_bloqueado: ' || SQLERRM;

        ROLLBACK;

    END;
  END pc_limpa_cnae_bloqueado;

  /* Rotina para a validação do arquivo de folha - Através do IB */
  PROCEDURE pc_importa_arq_cnae(pr_cdcooper  IN crapcop.cdcooper%TYPE
                               ,pr_dsarquiv  IN VARCHAR2
                               ,pr_dsdireto  IN VARCHAR2
                               ,pr_flglimpa  IN INTEGER
                               ,pr_dscritic  OUT VARCHAR2
                               ,pr_retxml    OUT CLOB) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_importa_arq_cnae                  Antigo: Não há
  --  Sistema  : IB
  --  Sigla    : CRED
  --  Autor    : Tiago Machado flor - CECRED
  --  Data     : SET/2015.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina para a validação e importacao do arquivo de cnae
  --
  -- Alterações:
  ---------------------------------------------------------------------------------------------------------------

    -- CURSORES
    -- Buscar os dados de Origens para Pagamentos de Folha
    CURSOR cr_crapofp(pr_cdcooper  crapofp.cdcooper%TYPE
                     ,pr_cdorigem  crapofp.cdorigem%TYPE) IS
      SELECT ofp.cdhisdeb
           , ofp.cdhiscre
           , ofp.cdhsdbcp
           , ofp.cdhscrcp
           , ofp.cdorigem
           , ofp.dsorigem
           , ofp.idvarmes
        FROM crapofp ofp
       WHERE ofp.cdcooper = pr_cdcooper
         AND ofp.cdorigem = pr_cdorigem;
    rw_crapofp     cr_crapofp%ROWTYPE;

    -- Busca dados da empresa/conta logada
    CURSOR cr_crapemp(pr_cdcooper  crapemp.cdcooper%TYPE
                     ,pr_nrdconta  crapemp.nrdconta%TYPE) IS
      SELECT emp.idtpempr
           , SUBSTR(LPAD(emp.nrdocnpj,14,0),1,8) nrdocnpj
           , emp.cdempres
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.nrdconta = pr_nrdconta;

    -- Buscar dados para validar registro repetidos
    CURSOR cr_verifica(pr_cdcooper    crappfp.cdcooper%TYPE
                      ,pr_cdempres    crappfp.cdempres%TYPE
                      ,pr_dtcredit    crappfp.dtcredit%TYPE
                      ,pr_nrdconta    craplfp.nrdconta%TYPE
                      ,pr_cdorigem    craplfp.cdorigem%TYPE) IS
      SELECT COUNT(1)
        FROM craplfp lfp
           , crappfp pfp
       WHERE pfp.cdcooper = lfp.cdcooper
         AND pfp.cdempres = lfp.cdempres
         AND pfp.nrseqpag = lfp.nrseqpag
         AND pfp.cdcooper             = pr_cdcooper
         AND pfp.cdempres             = pr_cdempres
         AND TRUNC(pfp.dtcredit,'MM') = TRUNC(pr_dtcredit,'MM')
         AND lfp.nrdconta             = pr_nrdconta
         AND lfp.cdorigem             = pr_cdorigem;

    -- Registros
    TYPE typ_reccritc IS RECORD (nrdlinha NUMBER
                                ,dscritic VARCHAR2(1000));
    TYPE typ_tbcritic IS TABLE OF typ_reccritc INDEX BY BINARY_INTEGER;
    vr_tbcritic    typ_tbcritic; -- Tabela de criticas encontradas na validação do arquivo

    -- Variaveis
    vr_excerror    EXCEPTION;

    vr_dsdireto    VARCHAR2(100);
    vr_dsdlinha    VARCHAR2(500);
    vr_dscrilot    VARCHAR2(500); -- Critica a ser replicada no arquivo
    vr_dscriarq    VARCHAR2(500); -- Critica a ser replicada no arquivo
    vr_cdcritic    INTEGER;
    vr_dscritic    VARCHAR2(500); -- Critica
    vr_typ_said    VARCHAR2(50); -- Critica
    vr_des_erro    VARCHAR2(500); -- Critica
    vr_dsalert     VARCHAR2(500); -- Critica
    vr_tpregist    NUMBER;
    vr_qtlinhas    NUMBER;
    vr_indice      INTEGER;

    vr_nrdconta    NUMBER;
    vr_nmarquiv    VARCHAR2(100); -- Nome do arquivo gerado para gravação dos dados

    vr_clitmxml    CLOB;
    vr_dsitmxml    VARCHAR2(32767);

    vr_retxml      XMLType;
    vr_dsauxml     varchar2(32767);

    vr_tab_linhas  gene0009.typ_tab_linhas;
    vr_cdprogra    VARCHAR2(50) := 'CADA0004.pc_importa_arq_cnae';

    -- Procedure auxiliar para adicionar as criticas do arquivo
    PROCEDURE pc_add_critica(pr_dscritic IN VARCHAR2
                            ,pr_nrdlinha IN NUMBER) IS

      nrindice    NUMBER;

    BEGIN
      -- Indice para inclusão da crítica
      nrindice := vr_tbcritic.count() + 1;

      -- Inserir a critica no registro de memória
      vr_tbcritic(nrindice).nrdlinha := pr_nrdlinha;
      vr_tbcritic(nrindice).dscritic := pr_dscritic;

    END pc_add_critica;

  BEGIN

    -- Busca o diretório do upload do arquivo
    vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'upload');

    -- Realizar a cópia do arquivo
    GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||' '||pr_dsdireto||pr_dsarquiv||' S'
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => vr_des_erro);

      -- Testar erro
    IF vr_typ_said = 'ERR' THEN
      -- O comando shell executou com erro, gerar log e sair do processo
      vr_dscritic := 'Erro realizar o upload do arquivo: ' || vr_des_erro;
      RAISE vr_excerror;
    END IF;

    -- Verifica se o arquivo existe
    IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||pr_dsarquiv) THEN
      -- Retorno de erro
      vr_dscritic := 'Erro no upload do arquivo: '||REPLACE(vr_dsdireto,'/','-')||'-'||pr_dsarquiv;
      RAISE vr_excerror;
    END IF;

    -- Criar cabecalho do XML
    vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    --limpa temptable
    vr_tab_linhas.DELETE;
    -- Importar o arquivo utilizando o Layout, separado por Virgula
    gene0009.pc_importa_arq_layout(pr_nmlayout   => 'CNAEBLQ'
                                  ,pr_dsdireto   => vr_dsdireto
                                  ,pr_nmarquiv   => pr_dsarquiv
                                  ,pr_dscritic   => vr_dscritic
                                  ,pr_tab_linhas => vr_tab_linhas);

    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_excerror;
    END IF;

    -- Se não possuir linhas - Gera log erros
    IF vr_tab_linhas.count = 0 THEN
       vr_dscritic := 'Arquivo ' || pr_dsarquiv || ' não possui conteúdo!';
       RAISE vr_excerror;
    END IF;

    -- Se flglimpa = 1 entao devo limpar a tabela
    IF pr_flglimpa = 1 THEN
       pc_limpa_cnae_bloqueado(pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

       IF vr_cdcritic > 0 OR
          vr_dscritic IS NOT NULL THEN
          RAISE vr_excerror;
       END IF;
    END IF;


    -- Excluir o arquivo, pois desse ponto em diante irá trabalhar com o registro
    -- de memória. Em caso de erros o programa abortará e o usuário irá realizar
    -- novamente o envio do arquivo
    GENE0001.pc_OScommand_Shell('rm ' || vr_dsdireto || '/' || pr_dsarquiv);

    FOR vr_indice IN vr_tab_linhas.FIRST..vr_tab_linhas.LAST LOOP --LINHAS ARQUIVO

      IF vr_tab_linhas(vr_indice).exists('$ERRO$') THEN
         pc_add_critica(pr_dscritic => vr_tab_linhas(vr_indice)('$ERRO$').texto
                       ,pr_nrdlinha => vr_indice);
      ELSE
        pc_inserir_cnae_bloqueado(pr_cdcnae     => vr_tab_linhas(vr_indice)('CDCNAE').numero
                                 ,pr_dsmotivo   => vr_tab_linhas(vr_indice)('DSMOTIVO').texto
                                 ,pr_dtarquivo  => vr_tab_linhas(vr_indice)('DTARQUIVO').data
                                 ,pr_tpbloqueio => vr_tab_linhas(vr_indice)('TPBLOQUEIO').numero
                                 ,pr_tpinclusao => 1 --Inclusao via arquivo
                                 ,pr_dtmvtolt   => SYSDATE
                                 ,pr_dslicenca  => vr_tab_linhas(vr_indice)('DSLICENCA').texto
                                 ,pr_cdcritic   => vr_cdcritic
                                 ,pr_dscritic   => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN

           -- se nao conseguir inserir tenta atualizar
           pc_atualizar_cnae_bloqueado(pr_cdcnae     => vr_tab_linhas(vr_indice)('CDCNAE').numero
                                      ,pr_dsmotivo   => vr_tab_linhas(vr_indice)('DSMOTIVO').texto
                                      ,pr_dtarquivo  => vr_tab_linhas(vr_indice)('DTARQUIVO').data
                                      ,pr_tpbloqueio => vr_tab_linhas(vr_indice)('TPBLOQUEIO').numero
                                      ,pr_tpinclusao => 1 -- Via arquivo
                                      ,pr_dtmvtolt   => SYSDATE
                                      ,pr_dslicenca  => vr_tab_linhas(vr_indice)('DSLICENCA').texto
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_dscritic   => vr_dscritic);

           IF vr_cdcritic > 0 OR
              vr_dscritic IS NOT NULL THEN

           pc_add_critica(pr_dscritic => vr_dscritic
                         ,pr_nrdlinha => vr_indice);

           CONTINUE;

        END IF;

        END IF;

      END IF;

    END LOOP;

    -- Se possui críticas a serem retornadas
    IF vr_tbcritic.COUNT() > 0 THEN
       vr_indice := 0;

       -- Recriar cabecalho do XML
       vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><criticas></criticas><arqcnaes></arqcnaes></Root>');
       -- Percorre todas as mensagens de alerta
       FOR vr_indice IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP

         -- Criar nodo filho
         vr_retxml := XMLTYPE.appendChildXML(vr_retxml
                                             ,'/Root/criticas'
                                             ,XMLTYPE('<critica>'
                                                    ||'    <nrdlinha>'||vr_tbcritic(vr_indice).nrdlinha||'</nrdlinha>'
                                                    ||'    <dscritic>'||vr_tbcritic(vr_indice).dscritic||'</dscritic>'
                                                    ||'</critica>'));

       END LOOP; -- Loop das críticas

    END IF;

    -- Converter o XML em CLOB e retornar
    pr_retxml := vr_retxml.getClobVal();

  EXCEPTION
    WHEN vr_excerror THEN
      pr_dscritic := vr_dscritic;

      vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
       -- Converter o XML
      pr_retxml := vr_retxml.getClobVal();
    WHEN OTHERS THEN
      GENE0001.pc_OScommand_Shell('rm ' || vr_dsdireto || '/' || pr_dsarquiv);

      pr_dscritic := 'Erro geral na rotina pc_importa_arq_cnae: '||SQLERRM;

      vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');

       -- Converter o XML
      pr_retxml := vr_retxml.getClobVal();

  END pc_importa_arq_cnae;

  /* Rotina para importacao do arquivo de cnae para tela COCNAE Através do AyllosWeb */
  PROCEDURE pc_importa_arq_cnae_web(pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                   ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo
                                   ,pr_flglimpa   IN INTEGER             --> 1 - Limpa tabela ou 2 - só atualiza as informaçoes
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_importa_arq_cnae_web                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Tiago Machado Flor
  --  Data     : Set/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina importacao arquivo cnae bloqueado
  --
  ---------------------------------------------------------------------------------------------------------------

    -- Variáveis
    vr_cdcooper    NUMBER;
    vr_nmdatela    VARCHAR2(25);
    vr_nmeacao     VARCHAR2(25);
    vr_cdagenci    VARCHAR2(25);
    vr_nrdcaixa    VARCHAR2(25);
    vr_idorigem    VARCHAR2(25);
    vr_cdoperad    VARCHAR2(25);
    vr_retxml      CLOB;

    vr_excerror    EXCEPTION;

    CURSOR cr_cnae_blq(pr_cdcnae tbcc_cnae_bloqueado.cdcnae%TYPE) IS
      SELECT ROWID
        FROM tbcc_cnae_bloqueado
       WHERE tbcc_cnae_bloqueado.cdcnae = pr_cdcnae;

  BEGIN

    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excerror;
    END IF;

    -- Realiza a chamada da rotina
    pc_importa_arq_cnae(pr_cdcooper => vr_cdcooper
                       ,pr_dsarquiv => pr_dsarquiv
                       ,pr_dsdireto => pr_dsdireto
                       ,pr_flglimpa => pr_flglimpa
                       ,pr_dscritic => pr_dscritic
                       ,pr_retxml   => vr_retxml);

    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excerror;
    END IF;

    -- Cria o XML de retorno
    pr_retxml := XMLType.createXML(vr_retxml);

  EXCEPTION
    WHEN vr_excerror THEN
      pr_des_erro := pr_dscritic;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral na rotina pc_importa_arq_cnae_web: '||SQLERRM;
      pr_des_erro := pr_dscritic;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
  END pc_importa_arq_cnae_web;

  PROCEDURE pc_exporta_arq_cnae(pr_cdcooper  IN crapcop.cdcooper%TYPE
                               ,pr_dsarquiv  OUT VARCHAR2
                               ,pr_cdcritic  IN INTEGER
                               ,pr_dscritic  OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_exporta_arq_cnae                  Antigo: Não há
  --  Sistema  : IB
  --  Sigla    : CRED
  --  Autor    : Tiago Machado flor - SUPERO
  --  Data     : SET/2015.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina para a exportacao do arquivo de cnae
  --
  -- Alterações:
  ---------------------------------------------------------------------------------------------------------------

    CURSOR cr_cnae_blq IS
      SELECT *
        FROM tbcc_cnae_bloqueado;

    TYPE typ_tab_cnae_blq IS TABLE OF VARCHAR2(1000)
      INDEX BY PLS_INTEGER;

    vr_tab_cnae_blq typ_tab_cnae_blq;

    vr_arqhandl  utl_file.file_type;    --> Handle do arquivo aberto
    vr_arq_path  VARCHAR2(1000);        --> Diretorio que sera criado o relatorio
    vr_arq_temp  VARCHAR2(100);         --> Nome do arquivo Temporario

    vr_dslinha   VARCHAR2(4000);
    vr_count      NUMBER := 0;

    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);

    vr_dscritic  VARCHAR2(4000);
    vr_cdcritic  INTEGER;
    vr_tab_erro  gene0001.typ_tab_erro;

    vr_excerror  EXCEPTION;

    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;


  BEGIN

    -- Iniciar Variáveis
    vr_arq_path := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'arq');
    vr_arq_temp := 'CNAES_BLOQ.txt';

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    vr_texto_completo := NULL;

    FOR rw_cnae_blq IN cr_cnae_blq LOOP

      pc_escreve_xml( rw_cnae_blq.cdcnae     || ';' ||
                      rw_cnae_blq.dsmotivo   || ';' ||
                      rw_cnae_blq.dslicenca  || ';' ||
                      rw_cnae_blq.tpbloqueio || ';' ||
                      TO_CHAR(rw_cnae_blq.dtarquivo,'DD/MM/RRRR') || ';' ||
                      TO_CHAR(rw_cnae_blq.dtmvtolt,'DD/MM/RRRR') || chr(10) );

    END LOOP;

    pc_escreve_xml(' ',TRUE);
    -- SCTASK0038225 (Yuri - Mouts)
    -- Com a migração para versão Oracle 12C necessário alteração no procedimento de gerar arquivo
    --Criar o arquivo no diretorio especificado
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                 ,pr_caminho  => vr_arq_path
                                 ,pr_arquivo  => vr_arq_temp
                                 ,pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
       vr_dscritic := 'Problemas ao gerar o arquivo no servidor. ' || vr_dscritic;
       RAISE vr_excerror;
    END IF;

/*    DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_arq_path, vr_arq_temp, NLS_CHARSET_ID('UTF8'));*/
    -- Fim SCTASK38225
    --
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

    vr_dscritic := '';

    gene0002.pc_efetua_copia_pdf(pr_cdcooper => 3
                                ,pr_cdagenci => 1
                                ,pr_nrdcaixa => 100
                                ,pr_nmarqpdf => vr_arq_path ||'/'|| vr_arq_temp
                                ,pr_des_reto => vr_dscritic
                                ,pr_tab_erro => vr_tab_erro);

    IF vr_dscritic IS NOT NULL AND
       vr_dscritic <> 'OK' THEN
       vr_dscritic := 'Problemas ao efetuar copia do arquivo para o servidor de destino. ' || vr_dscritic;
       RAISE vr_excerror;
    END IF;

    pr_dsarquiv := vr_arq_path ||'/'|| vr_arq_temp;

  EXCEPTION
    WHEN vr_excerror THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral na rotina pc_exporta_arq_cnae: '||SQLERRM;
  END pc_exporta_arq_cnae;

  PROCEDURE pc_exporta_arq_cnae_web(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                   ,pr_xmllog     IN  VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml     IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro   OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_dsarquiv VARCHAR2(400);

    BEGIN

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
        RAISE vr_exc_saida;
      END IF;

      pc_exporta_arq_cnae(pr_cdcooper   => vr_cdcooper
                         ,pr_dsarquiv   => vr_dsarquiv
                         ,pr_cdcritic   => vr_cdcritic
                         ,pr_dscritic   => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados><dsarquiv>'||vr_dsarquiv||'</dsarquiv></Dados></Root>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0004.pc_exporta_arq_cnae_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_exporta_arq_cnae_web;

  PROCEDURE pc_verifica_cnae_blq(pr_cdcnae   IN tbcc_cnae_bloqueado.cdcnae%TYPE
                                ,pr_nrcpfcgc IN tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE --> Codigo do CNPJ
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

      -- Cursor sobre a tabela do CNAE
      CURSOR cr_cnae_bloqueado(pr_cdcnae tbcc_cnae_bloqueado.cdcnae%TYPE) IS
        SELECT tbcc_cnae_bloqueado.cdcnae
              ,tbcc_cnae_bloqueado.tpbloqueio
          FROM tbcc_cnae_bloqueado
         WHERE tbcc_cnae_bloqueado.cdcnae = pr_cdcnae;
      rw_cnae_bloqueado cr_cnae_bloqueado%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_posreg   PLS_INTEGER := 0;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

        OPEN cr_cnae_bloqueado(pr_cdcnae => pr_cdcnae);
        FETCH cr_cnae_bloqueado INTO rw_cnae_bloqueado;

        IF cr_cnae_bloqueado%NOTFOUND THEN
           CLOSE cr_cnae_bloqueado;

           -- Carrega os dados
           gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                  ,pr_texto_completo => vr_xml_temp
                                  ,pr_texto_novo     => '<bloqueado>3</bloqueado>');
        ELSE
           CLOSE cr_cnae_bloqueado;

           IF rw_cnae_bloqueado.tpbloqueio = 0 THEN
              -- Carrega os dados
              gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                     ,pr_texto_completo => vr_xml_temp
                                     ,pr_texto_novo     => '<bloqueado>0</bloqueado>'); --Restrito
           ELSE
              -- Carrega os dados
              gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                     ,pr_texto_completo => vr_xml_temp
                                     ,pr_texto_novo     => '<bloqueado>1</bloqueado>'); --Proibido
           END IF;

           /*grava tabela de bloqueio de conta*/
           BEGIN
             INSERT
               INTO tbcc_aberturas_bloqueadas(cdcooper, cdagenci,
                                              cdcnae, dtmvtolt,
                                              nrcpfcgc, tpbloqueio)
                                       VALUES(vr_cdcooper, vr_cdagenci,
                                              pr_cdcnae, SYSDATE,
                                              pr_nrcpfcgc, 1);

           EXCEPTION
             WHEN dup_val_on_index THEN
                RAISE vr_exc_saida;
             WHEN OTHERS THEN
                RAISE vr_exc_saida;
           END;

        END IF;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na busca do CNAE: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_verifica_cnae_blq;

  PROCEDURE pc_valida_cnae_restrito(pr_cdcnae       IN  tbcc_cnae_bloqueado.cdcnae%TYPE
                                   ,pr_flgrestrito  OUT INTEGER) IS
  BEGIN
    DECLARE
      CURSOR cr_cnae_res(pr_cdcnae tbcc_cnae_bloqueado.cdcnae%TYPE) IS
        SELECT 1
          FROM tbcc_cnae_bloqueado
         WHERE tbcc_cnae_bloqueado.cdcnae = pr_cdcnae
           AND tbcc_cnae_bloqueado.tpbloqueio = 0;

      rw_cnae_res cr_cnae_res%ROWTYPE;

      vr_exc_saida EXCEPTION;
    BEGIN

      pr_flgrestrito := 0; --OK

      OPEN cr_cnae_res(pr_cdcnae => pr_cdcnae);
      FETCH cr_cnae_res INTO rw_cnae_res;

      IF cr_cnae_res%NOTFOUND THEN
         CLOSE cr_cnae_res;
         RAISE vr_exc_saida;
      END IF;

      CLOSE cr_cnae_res;

      pr_flgrestrito := 1; --Restrito

    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
      WHEN OTHERS THEN
        ROLLBACK;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END pc_valida_cnae_restrito;

--#########################################################################################################
--#############                 CNPJ BLOQUEADOS                                                     #######
--#########################################################################################################
  PROCEDURE pc_inserir_cnpj_bloqueado(pr_inpessoa   IN tbcc_cnpjcpf_bloqueado.inpessoa%TYPE    --> PF/PJ
                                     ,pr_nrcpfcgc   IN tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE    --> Codigo do CNAE
                                     ,pr_dsnome     IN tbcc_cnpjcpf_bloqueado.dsnome%TYPE      --> Nome
                                     ,pr_dsmotivo   IN tbcc_cnpjcpf_bloqueado.dsmotivo%TYPE    --> Motivo da inclusao
                                     ,pr_dtarquivo  IN tbcc_cnpjcpf_bloqueado.dtarquivo%TYPE   --> Data do arquivo
                                     ,pr_tpinclusao IN tbcc_cnpjcpf_bloqueado.tpinclusao%TYPE  --> Tipo de inclusão (0-Manual, 1-Arquivo)
                                     ,pr_dtmvtolt   IN tbcc_cnpjcpf_bloqueado.dtmvtolt%TYPE    --> Data atual
                                     ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                  --> Codigo de critica
                                     ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS              --> Descricao da critica
  BEGIN
    DECLARE
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    BEGIN

      -- Inserir
      BEGIN
        INSERT
          INTO tbcc_cnpjcpf_bloqueado(inpessoa, nrcpfcgc, dsnome
                                     ,dsmotivo, dtarquivo
                                     ,dtmvtolt, tpinclusao)
                               VALUES(pr_inpessoa, pr_nrcpfcgc, pr_dsnome
                                     ,pr_dsmotivo, pr_dtarquivo
                                     ,pr_dtmvtolt, pr_tpinclusao);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          vr_cdcritic := 0;
          vr_dscritic := 'CNPJ ou CPF já cadastrado.';
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro geral em CADA0004.pc_inserir_cnpj_bloqueado: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0004.pc_inserir_cnpj_bloqueado: ' || SQLERRM;

    END;
  END pc_inserir_cnpj_bloqueado;

  PROCEDURE pc_atualizar_cnpj_bloqueado(pr_inpessoa   IN tbcc_cnpjcpf_bloqueado.inpessoa%TYPE    --> PF/PJ
                                       ,pr_nrcpfcgc   IN tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE    --> Codigo do CNAE
                                       ,pr_dsnome     IN tbcc_cnpjcpf_bloqueado.dsnome%TYPE      --> Nome
                                       ,pr_dsmotivo   IN tbcc_cnpjcpf_bloqueado.dsmotivo%TYPE    --> Motivo da inclusao
                                       ,pr_dtarquivo  IN tbcc_cnpjcpf_bloqueado.dtarquivo%TYPE   --> Data do arquivo
                                       ,pr_tpinclusao IN tbcc_cnpjcpf_bloqueado.tpinclusao%TYPE  --> Tipo de inclusão (0-Manual, 1-Arquivo)
                                       ,pr_dtmvtolt   IN tbcc_cnpjcpf_bloqueado.dtmvtolt%TYPE    --> Data atual
                                       ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                  --> Codigo de critica
                                       ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS              --> Descricao da critica
  BEGIN
    DECLARE

      CURSOR cr_cnpj_blq(pr_nrcpfcgc tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE) IS
        SELECT tbcc_cnpjcpf_bloqueado.nrcpfcgc
          FROM tbcc_cnpjcpf_bloqueado
         WHERE tbcc_cnpjcpf_bloqueado.nrcpfcgc = pr_nrcpfcgc;
      rw_cnpj_blq cr_cnpj_blq%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    BEGIN

      OPEN cr_cnpj_blq(pr_nrcpfcgc => pr_nrcpfcgc);
      FETCH cr_cnpj_blq INTO rw_cnpj_blq;

      IF cr_cnpj_blq%NOTFOUND THEN -->Nao disparar critica apenas nao atualiza
         CLOSE cr_cnpj_blq;
         vr_cdcritic := 0;
         vr_dscritic := '';
         RAISE vr_exc_saida;
      END IF;

      CLOSE cr_cnpj_blq;

      -- Update
      BEGIN
        UPDATE tbcc_cnpjcpf_bloqueado
           SET tbcc_cnpjcpf_bloqueado.dsnome     = pr_dsnome
              ,tbcc_cnpjcpf_bloqueado.dsmotivo   = pr_dsmotivo
              ,tbcc_cnpjcpf_bloqueado.dtarquivo  = pr_dtarquivo
              ,tbcc_cnpjcpf_bloqueado.dtmvtolt   = pr_dtmvtolt
              ,tbcc_cnpjcpf_bloqueado.tpinclusao = pr_tpinclusao
              ,tbcc_cnpjcpf_bloqueado.inpessoa   = pr_inpessoa
         WHERE tbcc_cnpjcpf_bloqueado.nrcpfcgc   = pr_nrcpfcgc;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro geral em CADA0004.pc_atualizar_cnpj_bloqueado: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0004.pc_atualizar_cnpj_bloqueado: ' || SQLERRM;

    END;
  END pc_atualizar_cnpj_bloqueado;

  PROCEDURE pc_excluir_cnpj_bloqueado(pr_nrcpfcgc   IN tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE    --> Codigo do CNPJ
                                     ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                  --> Codigo de critica
                                     ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS              --> Descricao da critica
  BEGIN
    DECLARE
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    BEGIN

      -- Excluir
      BEGIN
        DELETE FROM tbcc_cnpjcpf_bloqueado WHERE tbcc_cnpjcpf_bloqueado.nrcpfcgc = pr_nrcpfcgc;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro geral em CADA0004.pc_excluir_cnpj_bloqueado: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0004.pc_excluir_cnpj_bloqueado: ' || SQLERRM;

    END;
  END pc_excluir_cnpj_bloqueado;

  PROCEDURE pc_buscar_cnpj_bloqueado(pr_inpessoa IN tbcc_cnpjcpf_bloqueado.inpessoa%TYPE --> PF/PJ
                                    ,pr_nrcpfcgc IN tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE --> Codigo do CNPJ
                                    ,pr_dsnome   IN tbcc_cnpjcpf_bloqueado.dsnome%TYPE --> Nome do CNPJ
                                    ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                                    ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

      -- Cursor sobre a tabela do CNAE
      CURSOR cr_cnpj_bloqueado(pr_nrcpfcgc tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE
                              ,pr_dsnome tbcc_cnpjcpf_bloqueado.dsnome%TYPE) IS
        SELECT a.nrcpfcgc,
               gene0007.fn_caract_acento(a.dsnome) dsnome,
               gene0007.fn_caract_acento(a.dsmotivo) dsmotivo,
               a.tpinclusao,
               a.dtarquivo,
               a.dtmvtolt,
               a.inpessoa,
               count(1) over() retorno
          FROM tbcc_cnpjcpf_bloqueado a
         WHERE a.nrcpfcgc = decode(nvl(pr_nrcpfcgc,0),0,a.nrcpfcgc, pr_nrcpfcgc)
           AND a.inpessoa = decode(nvl(pr_inpessoa,0),0,a.inpessoa, pr_inpessoa)
           AND (trim(pr_dsnome) IS NULL
            OR  a.dsnome LIKE '%'||pr_dsnome||'%')
         ORDER BY a.dsnome;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_posreg   PLS_INTEGER := 0;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

        -- Loop sobre a tabela de CNAE
        FOR rw_cnpj_bloqueado IN cr_cnpj_bloqueado(pr_nrcpfcgc => pr_nrcpfcgc
                                                  ,pr_dsnome   => pr_dsnome)  LOOP

          -- Incrementa o contador de registros
          vr_posreg := vr_posreg + 1;

          -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
          IF vr_posreg = 1 THEN
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<CNPJ qtregist="' || rw_cnpj_bloqueado.retorno || '">');
          END IF;

          -- Enviar somente se a linha for superior a linha inicial
          IF nvl(pr_nriniseq,0) <= vr_posreg THEN

            -- Carrega os dados
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<inf>'||
                                                            '<nrcpfcgc>' || rw_cnpj_bloqueado.nrcpfcgc ||'</nrcpfcgc>'||
                                                            '<dsnome>' || rw_cnpj_bloqueado.dsnome ||'</dsnome>'||
                                                            '<dsmotivo>' || rw_cnpj_bloqueado.dsmotivo ||'</dsmotivo>'||
                                                            '<inpessoa>' || rw_cnpj_bloqueado.inpessoa ||'</inpessoa>'||
                                                            '<tpinclusao>' || rw_cnpj_bloqueado.tpinclusao ||'</tpinclusao>'||
                                                            '<dtmvtolt>' || TO_CHAR(rw_cnpj_bloqueado.dtmvtolt,'DD/MM/RRRR') ||'</dtmvtolt>'||
                                                            '<dtarquivo>' || TO_CHAR(rw_cnpj_bloqueado.dtarquivo,'DD/MM/RRRR') ||'</dtarquivo>'||
                                                         '</inf>');
            vr_contador := vr_contador + 1;
          END IF;

          -- Deve-se sair se o total de registros superar o total solicitado
          EXIT WHEN vr_contador > nvl(pr_nrregist,99999);

        END LOOP;

        -- Se nao possuir nenhum registro, envia a quantidade de registros zerada
        IF vr_posreg = 0 THEN
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<CNPJ qtregist="0">');
        END IF;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</CNPJ></Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na busca do CNPJ: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_buscar_cnpj_bloqueado;

  PROCEDURE pc_cria_cnpj_proibido_web(pr_inpessoa   IN  tbcc_cnpjcpf_bloqueado.inpessoa%TYPE
                                     ,pr_nrcpfcgc   IN  tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE
                                     ,pr_dsnome     IN  tbcc_cnpjcpf_bloqueado.dsnome%TYPE
                                     ,pr_dsmotivo   IN  tbcc_cnpjcpf_bloqueado.dsmotivo%TYPE
                                     ,pr_tpinclusao IN  tbcc_cnpjcpf_bloqueado.tpinclusao%TYPE
                                     ,pr_dtarquivo  IN  VARCHAR2
                                     ,pr_dtmvtolt   IN  VARCHAR2
                                     ,pr_xmllog     IN  VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml     IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                     ,pr_des_erro   OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_auxconta PLS_INTEGER := 0;
      vr_nmarqpdf VARCHAR2(500);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

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
        RAISE vr_exc_saida;
      END IF;

      -- Inserir
      pc_inserir_cnpj_bloqueado(pr_inpessoa   => pr_inpessoa
                               ,pr_nrcpfcgc   => pr_nrcpfcgc
                               ,pr_dsnome     => pr_dsnome
                               ,pr_dsmotivo   => pr_dsmotivo
                               ,pr_dtarquivo  => TO_DATE(pr_dtmvtolt,'DD/MM/RRRR')
                               ,pr_dtmvtolt   => TO_DATE(pr_dtmvtolt,'DD/MM/RRRR')
                               ,pr_tpinclusao => pr_tpinclusao
                               ,pr_cdcritic   => vr_cdcritic
                               ,pr_dscritic   => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0004.pc_cria_cnpj_proibido_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_cria_cnpj_proibido_web;

  PROCEDURE pc_exclui_cnpj_proibido_web(pr_nrcpfcgc   IN  tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE --> CNPJ ou CPF
                                       ,pr_xmllog     IN  VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml     IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

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
        RAISE vr_exc_saida;
      END IF;

      -- Inserir
      pc_excluir_cnpj_bloqueado(pr_nrcpfcgc   => pr_nrcpfcgc
                               ,pr_cdcritic   => vr_cdcritic
                               ,pr_dscritic   => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0004.pc_exclui_cnpj_proibido_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_exclui_cnpj_proibido_web;

  PROCEDURE pc_limpa_cnpj_proibido(pr_cdcritic   OUT PLS_INTEGER    --> Código da crítica
                                  ,pr_dscritic   OUT VARCHAR2) IS   --> Descrição da crítica

  BEGIN
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

    BEGIN

      BEGIN
        DELETE FROM tbcc_cnpjcpf_bloqueado;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE vr_exc_saida;
      END;

    EXCEPTION
      WHEN vr_exc_saida THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel limpar a tabela de CNPJ/CPF bloqueados.';

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em CADA0004.pc_limpa_cnpj_proibido: ' || SQLERRM;

        ROLLBACK;

    END;
  END pc_limpa_cnpj_proibido;

  /* Rotina para a validação do arquivo de folha - Através do IB */
  PROCEDURE pc_importa_arq_cnpj(pr_cdcooper  IN crapcop.cdcooper%TYPE
                               ,pr_dsarquiv  IN VARCHAR2
                               ,pr_dsdireto  IN VARCHAR2
                               ,pr_flglimpa  IN INTEGER
                               ,pr_dscritic  OUT VARCHAR2
                               ,pr_retxml    OUT CLOB) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_importa_arq_cnpj                  Antigo: Não há
  --  Sistema  : IB
  --  Sigla    : CRED
  --  Autor    : Tiago Machado flor - SUPERO
  --  Data     : SET/2015.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina para a validação e importacao do arquivo de cnpj
  --
  -- Alterações:
  ---------------------------------------------------------------------------------------------------------------

    -- Registros
    TYPE typ_reccritc IS RECORD (nrdlinha NUMBER
                                ,dscritic VARCHAR2(1000));
    TYPE typ_tbcritic IS TABLE OF typ_reccritc INDEX BY BINARY_INTEGER;
    vr_tbcritic    typ_tbcritic; -- Tabela de criticas encontradas na validação do arquivo

    -- Variaveis
    vr_excerror    EXCEPTION;

    vr_dsdireto    VARCHAR2(100);
    vr_dsdlinha    VARCHAR2(500);
    vr_dscrilot    VARCHAR2(500); -- Critica a ser replicada no arquivo
    vr_dscriarq    VARCHAR2(500); -- Critica a ser replicada no arquivo
    vr_cdcritic    INTEGER;
    vr_dscritic    VARCHAR2(500); -- Critica
    vr_typ_said    VARCHAR2(50); -- Critica
    vr_des_erro    VARCHAR2(500); -- Critica
    vr_dsalert     VARCHAR2(500); -- Critica
    vr_tpregist    NUMBER;
    vr_qtlinhas    NUMBER;
    vr_indice      INTEGER;

    vr_nrdconta    NUMBER;
    vr_nmarquiv    VARCHAR2(100); -- Nome do arquivo gerado para gravação dos dados

    vr_clitmxml    CLOB;
    vr_dsitmxml    VARCHAR2(32767);

    vr_retxml      XMLType;
    vr_dsauxml     varchar2(32767);

    vr_tab_linhas  gene0009.typ_tab_linhas;
    vr_cdprogra    VARCHAR2(50) := 'CADA0004.pc_importa_arq_cnpj';

    -- Procedure auxiliar para adicionar as criticas do arquivo
    PROCEDURE pc_add_critica(pr_dscritic IN VARCHAR2
                            ,pr_nrdlinha IN NUMBER) IS

      nrindice    NUMBER;

    BEGIN
      -- Indice para inclusão da crítica
      nrindice := vr_tbcritic.count() + 1;

      -- Inserir a critica no registro de memória
      vr_tbcritic(nrindice).nrdlinha := pr_nrdlinha;
      vr_tbcritic(nrindice).dscritic := pr_dscritic;

    END pc_add_critica;

  BEGIN

    -- Busca o diretório do upload do arquivo
    vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'upload');

    -- Realizar a cópia do arquivo
    GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||' '||pr_dsdireto||pr_dsarquiv||' S'
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => vr_des_erro);

      -- Testar erro
    IF vr_typ_said = 'ERR' THEN
      -- O comando shell executou com erro, gerar log e sair do processo
      vr_dscritic := 'Erro realizar o upload do arquivo: ' || vr_des_erro;
      RAISE vr_excerror;
    END IF;

    -- Verifica se o arquivo existe
    IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||pr_dsarquiv) THEN
      -- Retorno de erro
      vr_dscritic := 'Erro no upload do arquivo: '||REPLACE(vr_dsdireto,'/','-')||'-'||pr_dsarquiv;
      RAISE vr_excerror;
    END IF;

    -- Criar cabecalho do XML
    vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    --limpa temptable
    vr_tab_linhas.DELETE;
    -- Importar o arquivo utilizando o Layout, separado por Virgula
    gene0009.pc_importa_arq_layout(pr_nmlayout   => 'CNPJCPFBLQ'
                                  ,pr_dsdireto   => vr_dsdireto
                                  ,pr_nmarquiv   => pr_dsarquiv
                                  ,pr_dscritic   => vr_dscritic
                                  ,pr_tab_linhas => vr_tab_linhas);

    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_excerror;
    END IF;

    -- Se não possuir linhas - Gera log erros
    IF vr_tab_linhas.count = 0 THEN
       vr_dscritic := 'Arquivo ' || pr_dsarquiv || ' não possui conteúdo!';
       RAISE vr_excerror;
    END IF;

    -- Excluir o arquivo, pois desse ponto em diante irá trabalhar com o registro
    -- de memória. Em caso de erros o programa abortará e o usuário irá realizar
    -- novamente o envio do arquivo
    GENE0001.pc_OScommand_Shell('rm ' || vr_dsdireto || '/' || pr_dsarquiv);

    -- Se flglimpa = 1 entao devo limpar a tabela
    IF pr_flglimpa = 1 THEN
       pc_limpa_cnpj_proibido(pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

       IF vr_cdcritic > 0 OR
          vr_dscritic <> '' THEN
          RAISE vr_excerror;
       END IF;
    END IF;

    FOR vr_indice IN vr_tab_linhas.FIRST..vr_tab_linhas.LAST LOOP --LINHAS ARQUIVO

      IF vr_tab_linhas(vr_indice).exists('$ERRO$') THEN
         pc_add_critica(pr_dscritic => vr_tab_linhas(vr_indice)('$ERRO$').texto
                       ,pr_nrdlinha => vr_indice);
      ELSE
        pc_inserir_cnpj_bloqueado(pr_inpessoa   => vr_tab_linhas(vr_indice)('INPESSOA').numero
                                 ,pr_nrcpfcgc   => vr_tab_linhas(vr_indice)('NRCPFCGC').numero
                                 ,pr_dsnome     => vr_tab_linhas(vr_indice)('DSNOME').texto
                                 ,pr_dsmotivo   => vr_tab_linhas(vr_indice)('DSMOTIVO').texto
                                 ,pr_dtarquivo  => vr_tab_linhas(vr_indice)('DTARQUIVO').data
                                 ,pr_tpinclusao => 1 --via arq
                                 ,pr_dtmvtolt   => SYSDATE
                                 ,pr_cdcritic   => vr_cdcritic
                                 ,pr_dscritic   => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN

           -- se nao conseguir inserir tenta atualizar
           pc_atualizar_cnpj_bloqueado(pr_inpessoa   => vr_tab_linhas(vr_indice)('INPESSOA').numero
                                      ,pr_nrcpfcgc   => vr_tab_linhas(vr_indice)('NRCPFCGC').numero
                                      ,pr_dsnome     => vr_tab_linhas(vr_indice)('DSNOME').texto
                                      ,pr_dsmotivo   => vr_tab_linhas(vr_indice)('DSMOTIVO').texto
                                      ,pr_dtarquivo  => vr_tab_linhas(vr_indice)('DTARQUIVO').data
                                      ,pr_tpinclusao => 1 -- via arq
                                      ,pr_dtmvtolt   => SYSDATE
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_dscritic   => vr_dscritic);


           pc_add_critica(pr_dscritic => vr_dscritic
                         ,pr_nrdlinha => vr_indice);

        END IF;

      END IF;

    END LOOP;

    -- Se possui críticas a serem retornadas
    IF vr_tbcritic.COUNT() > 0 THEN
       vr_indice := 0;

       -- Recriar cabecalho do XML
       vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><criticas></criticas><arqcnpjs></arqcnpjs></Root>');
       -- Percorre todas as mensagens de alerta
       FOR vr_indice IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP

         -- Criar nodo filho
         vr_retxml := XMLTYPE.appendChildXML(vr_retxml
                                             ,'/Root/criticas'
                                             ,XMLTYPE('<critica>'
                                                    ||'    <nrdlinha>'||vr_tbcritic(vr_indice).nrdlinha||'</nrdlinha>'
                                                    ||'    <dscritic>'||vr_tbcritic(vr_indice).dscritic||'</dscritic>'
                                                    ||'</critica>'));

       END LOOP; -- Loop das críticas

    END IF;

    -- Converter o XML em CLOB e retornar
    pr_retxml := vr_retxml.getClobVal();

  EXCEPTION
    WHEN vr_excerror THEN
      pr_dscritic := vr_dscritic;

      vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros..' || pr_dscritic || '</Erro></Root>');
       -- Converter o XML
      pr_retxml := vr_retxml.getClobVal();
    WHEN OTHERS THEN
      GENE0001.pc_OScommand_Shell('rm ' || vr_dsdireto || '/' || pr_dsarquiv);

      pr_dscritic := 'Erro geral na rotina pc_importa_arq_cnpj: '||SQLERRM;

      vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
       -- Converter o XML
      pr_retxml := vr_retxml.getClobVal();

  END pc_importa_arq_cnpj;

  /* Rotina para importacao do arquivo de cnae para tela COCNAE Através do AyllosWeb */
  PROCEDURE pc_importa_arq_cnpj_web(pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                   ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo
                                   ,pr_flglimpa   IN INTEGER
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_importa_arq_cnpj_web                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Tiago Machado Flor
  --  Data     : Set/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina importacao arquivo cnae bloqueado
  --
  ---------------------------------------------------------------------------------------------------------------

    -- Variáveis
    vr_cdcooper    NUMBER;
    vr_nmdatela    VARCHAR2(25);
    vr_nmeacao     VARCHAR2(25);
    vr_cdagenci    VARCHAR2(25);
    vr_nrdcaixa    VARCHAR2(25);
    vr_idorigem    VARCHAR2(25);
    vr_cdoperad    VARCHAR2(25);
    vr_retxml      CLOB;

    vr_excerror    EXCEPTION;

    CURSOR cr_cnae_blq(pr_nrcpfcgc tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE) IS
      SELECT ROWID
        FROM tbcc_cnpjcpf_bloqueado
       WHERE tbcc_cnpjcpf_bloqueado.nrcpfcgc = pr_nrcpfcgc;

  BEGIN

    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excerror;
    END IF;

    -- Realiza a chamada da rotina
    pc_importa_arq_cnpj(pr_cdcooper => vr_cdcooper
                       ,pr_dsarquiv => pr_dsarquiv
                       ,pr_dsdireto => pr_dsdireto
                       ,pr_flglimpa => pr_flglimpa
                       ,pr_dscritic => pr_dscritic
                       ,pr_retxml   => vr_retxml);

    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excerror;
    END IF;

    -- Cria o XML de retorno
    pr_retxml := XMLType.createXML(vr_retxml);

  EXCEPTION
    WHEN vr_excerror THEN
      pr_des_erro := pr_dscritic;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros '||pr_dscritic||'</Erro></Root>');
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral na rotina pc_importa_arq_cnpj_web: '||SQLERRM;
      pr_des_erro := pr_dscritic;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
  END pc_importa_arq_cnpj_web;

  PROCEDURE pc_exporta_arq_cnpj(pr_cdcooper  IN crapcop.cdcooper%TYPE
                               ,pr_dsarquiv  OUT VARCHAR2
                               ,pr_cdcritic  IN INTEGER
                               ,pr_dscritic  OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_exporta_arq_cnpj                  Antigo: Não há
  --  Sistema  : IB
  --  Sigla    : CRED
  --  Autor    : Tiago Machado flor - SUPERO
  --  Data     : SET/2015.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina para a exportacao do arquivo de cnpj
  --
  -- Alterações:
  ---------------------------------------------------------------------------------------------------------------

    CURSOR cr_cnpj_blq IS
      SELECT *
        FROM tbcc_cnpjcpf_bloqueado;

    TYPE typ_tab_cnpj_blq IS TABLE OF VARCHAR2(1000)
      INDEX BY PLS_INTEGER;

    vr_tab_cnpj_blq typ_tab_cnpj_blq;

    vr_arqhandl  utl_file.file_type;    --> Handle do arquivo aberto
    vr_arq_path  VARCHAR2(1000);        --> Diretorio que sera criado o relatorio
    vr_arq_temp  VARCHAR2(100);         --> Nome do arquivo Temporario

    vr_dslinha   VARCHAR2(4000);
    vr_count      NUMBER := 0;

    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);

    vr_dscritic  VARCHAR2(4000);
    vr_cdcritic  INTEGER;
    vr_tab_erro  gene0001.typ_tab_erro;

    vr_excerror  EXCEPTION;

    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;


  BEGIN

    -- Iniciar Variáveis
    vr_arq_path := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'arq');
    vr_arq_temp := 'CNPJS_BLOQ.txt';

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    vr_texto_completo := NULL;

    FOR rw_cnpj_blq IN cr_cnpj_blq LOOP

      pc_escreve_xml( rw_cnpj_blq.inpessoa   || ';' ||
                      rw_cnpj_blq.nrcpfcgc   || ';' ||
                      rw_cnpj_blq.dsnome     || ';' ||
                      rw_cnpj_blq.dsmotivo   || ';' ||
                      rw_cnpj_blq.tpinclusao || ';' ||
                      TO_CHAR(rw_cnpj_blq.dtarquivo,'DD/MM/RRRR') || ';' ||
                      TO_CHAR(rw_cnpj_blq.dtmvtolt,'DD/MM/RRRR') || chr(10) );

    END LOOP;

    pc_escreve_xml(' ',TRUE);
    -- SCTASK0038225 (Yuri - Mouts)
    -- Com a migração para versão Oracle 12C necessário alteração no procedimento de gerar arquivo
    --Criar o arquivo no diretorio especificado
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                 ,pr_caminho  => vr_arq_path
                                 ,pr_arquivo  => vr_arq_temp
                                 ,pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
       vr_dscritic := 'Problemas ao gerar o arquivo no servidor. ' || vr_dscritic;
       RAISE vr_excerror;
    END IF;

/*  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_arq_path, vr_arq_temp, NLS_CHARSET_ID('UTF8'));*/
    -- Fim SCTASK0038225
    --
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

    vr_dscritic := '';

    gene0002.pc_efetua_copia_pdf(pr_cdcooper => 3
                                ,pr_cdagenci => 1
                                ,pr_nrdcaixa => 100
                                ,pr_nmarqpdf => vr_arq_path ||'/'|| vr_arq_temp
                                ,pr_des_reto => vr_dscritic
                                ,pr_tab_erro => vr_tab_erro);

    IF vr_dscritic IS NOT NULL AND
       vr_dscritic <> 'OK' THEN
       vr_dscritic := 'Problemas ao efetuar copia do arquivo para o servidor de destino. ' || vr_dscritic;
       RAISE vr_excerror;
    END IF;

    pr_dsarquiv := vr_arq_path ||'/'|| vr_arq_temp;

  EXCEPTION
    WHEN vr_excerror THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral na rotina pc_exporta_arq_cnpj: '||SQLERRM;
  END pc_exporta_arq_cnpj;

  PROCEDURE pc_exporta_arq_cnpj_web(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                   ,pr_xmllog     IN  VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml     IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro   OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_dsarquiv VARCHAR2(400);

    BEGIN

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
        RAISE vr_exc_saida;
      END IF;

      pc_exporta_arq_cnpj(pr_cdcooper   => vr_cdcooper
                         ,pr_dsarquiv   => vr_dsarquiv
                         ,pr_cdcritic   => vr_cdcritic
                         ,pr_dscritic   => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados><dsarquiv>'||vr_dsarquiv||'</dsarquiv></Dados></Root>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0004.pc_exporta_arq_cnpj_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_exporta_arq_cnpj_web;

  PROCEDURE pc_verifica_cnpj_blq(pr_inpessoa IN crapass.inpessoa%TYPE  --> Pessoa Fisica/ Pessoa Juridica
                                ,pr_nrcpfcgc IN tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE --> Codigo do CNPJ
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

      -- Cursor sobre a tabela do CNAE
      CURSOR cr_cnpj_bloqueado(pr_inpessoa crapass.inpessoa%TYPE
                              ,pr_nrcpfcgc tbcc_cnpjcpf_bloqueado.nrcpfcgc%TYPE) IS
        SELECT nrcpfcgc
          FROM tbcc_cnpjcpf_bloqueado
         WHERE tbcc_cnpjcpf_bloqueado.nrcpfcgc = pr_nrcpfcgc;
--           AND tbcc_cnpjcpf_bloqueado.inpessoa = pr_inpessoa
      rw_cnpj_bloqueado cr_cnpj_bloqueado%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_posreg   PLS_INTEGER := 0;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

        OPEN cr_cnpj_bloqueado(pr_inpessoa => pr_inpessoa
                              ,pr_nrcpfcgc => pr_nrcpfcgc);
        FETCH cr_cnpj_bloqueado INTO rw_cnpj_bloqueado;

        IF cr_cnpj_bloqueado%NOTFOUND THEN
           CLOSE cr_cnpj_bloqueado;

           -- Carrega os dados
           gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                  ,pr_texto_completo => vr_xml_temp
                                  ,pr_texto_novo     => '<bloqueado>NAO</bloqueado>');
        ELSE
           CLOSE cr_cnpj_bloqueado;

           -- Carrega os dados
           gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                  ,pr_texto_completo => vr_xml_temp
                                  ,pr_texto_novo     => '<bloqueado>SIM</bloqueado>');

           /*grava tabela de bloqueio de conta*/
           BEGIN
             INSERT
               INTO tbcc_aberturas_bloqueadas(cdcooper, cdagenci,
                                              nrcpfcgc, dtmvtolt,
                                              tpbloqueio)
                                       VALUES(vr_cdcooper, vr_cdagenci,
                                              pr_nrcpfcgc, SYSDATE,0);
           EXCEPTION
             WHEN dup_val_on_index THEN
                RAISE vr_exc_saida;
             WHEN OTHERS THEN
                RAISE vr_exc_saida;
           END;

        END IF;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na busca do CNPJ: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_verifica_cnpj_blq;

  PROCEDURE pc_atualiz_data_manut_fone
                        ( pr_cdcooper IN crapttl.cdcooper%TYPE  --> Codigo da cooperativa
                         ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da Conta
                         ,pr_cdcritic OUT INTEGER
                         ,pr_dscritic OUT VARCHAR2) IS
  /* ..........................................................................
    --
    --  Programa : pc_atualiz_data_manut_fone
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Guilherme/SUPERO
    --  Data     : Novembro/2016.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Atualizar a Data de Atualização de Telefone da Conta/Cooperado
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <----------------
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    CURSOR cr_crapass (p_cdcooper crapass.cdcooper%TYPE,
                       p_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = p_cdcooper
         AND ass.nrdconta = p_nrdconta;

    --------------> Variaveis <----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;
    vr_inpessoa INTEGER;

  BEGIN

    OPEN cr_crapass(p_cdcooper => pr_cdcooper
                   ,p_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO vr_inpessoa;
    -- Se não encontrar
    IF cr_crapass%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapass;
      vr_cdcritic := 0;
      vr_dscritic := 'Associado não encontrado!';
      RAISE vr_exc_erro;
    END IF;
    -- Fechar o cursor
    CLOSE cr_crapass;

    -- Leitura do calendário da cooperativa, para alguns procedimentos que precisam
    -- receber como parametro
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := 'Sistema sem data de movimento.';
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;


    IF  vr_inpessoa = 1 THEN
      -- PESSOA FISICA
      BEGIN
        UPDATE crapttl ttl
           SET ttl.dtatutel = rw_crapdat.dtmvtocd
         WHERE ttl.cdcooper = pr_cdcooper
           AND ttl.nrdconta = pr_nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro na atualização do telefone[TTL]: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    ELSE
      -- PESSOA JURIDICA
      BEGIN
         UPDATE crapjur jur
            SET jur.dtatutel = rw_crapdat.dtmvtocd
           WHERE jur.cdcooper = pr_cdcooper
            AND jur.nrdconta = pr_nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro na atualização do telefone[JUR]: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;

    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel atualizar dados pc_atualiz_data_manut_fone: '||SQLERRM;
  END pc_atualiz_data_manut_fone;


  PROCEDURE pc_verifica_atualiz_fone
                        ( pr_cdcooper IN crapttl.cdcooper%TYPE  --> Codigo da cooperativa
                         ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da Conta
                         ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencia do Titular
                         ,pr_cdcritic OUT INTEGER
                         ,pr_dscritic OUT VARCHAR2
                         ,pr_atualiza OUT VARCHAR2
                         ,pr_dsnrfone OUT VARCHAR2
                         ,pr_qtmeatel OUT INTEGER) IS          --> OK ou NOK
  /* ..........................................................................
    --
    --  Programa : pc_verifica_atualiz_fone
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Guilherme/SUPERO
    --  Data     : Novembro/2016.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Verifica se a conta necessita atualizar telefone
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <----------------
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    CURSOR cr_crapcop (p_cdcooper crapass.cdcooper%TYPE) IS
      SELECT NVL(cop.qtmeatel,0) qtmeatel
        FROM crapcop cop
       WHERE cop.cdcooper = p_cdcooper;

    CURSOR cr_ttl_jur (p_cdcooper crapass.cdcooper%TYPE,
                       p_nrdconta crapass.nrdconta%TYPE,
                       p_idseqttl crapttl.idseqttl%TYPE,
                       p_dtmvtolt crapdat.dtmvtolt%TYPE
                       ) IS
      SELECT 1            INPESSOA
            ,ttl.nrdconta
            ,ttl.dtatutel
            ,NVL( TRUNC((p_dtmvtolt - ttl.dtatutel)/ 30),999) DIF_DATA
        FROM crapttl ttl
       WHERE ttl.cdcooper = p_cdcooper
         AND ttl.nrdconta = p_nrdconta
         AND ttl.idseqttl = p_idseqttl
      UNION ALL
      SELECT 2            INPESSOA
            ,jur.nrdconta
            ,jur.dtatutel
            ,NVL( TRUNC((p_dtmvtolt - jur.dtatutel)/ 30),999) DIF_DATA
        FROM crapjur jur
       WHERE jur.cdcooper = p_cdcooper
         AND jur.nrdconta = p_nrdconta;
    rw_ttl_jur cr_ttl_jur%ROWTYPE;

    -- BUSCAR DATA DA REVISAO CADASTRAL
    CURSOR cr_crapalt (p_cdcooper crapass.cdcooper%TYPE,
                       p_nrdconta crapass.nrdconta%TYPE,
                       p_dtmvtolt crapdat.dtmvtolt%TYPE) IS
     SELECT alt.dsaltera
           ,alt.dtaltera
           ,nvl(trunc ( (p_dtmvtolt - alt.dtaltera)  / 30),999) DIF_DATA
       FROM crapalt alt
      WHERE alt.cdcooper = p_cdcooper
        AND alt.nrdconta = p_nrdconta
      ORDER BY alt.dtaltera DESC;

    -- BUSCAR DATA DE ADMISSAO ASSOCIADO
    CURSOR cr_crapass (p_cdcooper crapass.cdcooper%TYPE,
                       p_nrdconta crapass.nrdconta%TYPE,
                       p_dtmvtolt crapdat.dtmvtolt%TYPE) IS
     SELECT nvl(trunc ( (p_dtmvtolt - ass.dtadmiss)  / 30),999) DIF_DATA
       FROM crapass ass
      WHERE ass.cdcooper = p_cdcooper
        AND ass.nrdconta = p_nrdconta;

    -- BUSCAR O TELEFONE CADASTRADO
    CURSOR cr_craptfc (p_cdcooper crapass.cdcooper%TYPE,
                       p_nrdconta crapass.nrdconta%TYPE,
                       p_idseqttl crapttl.idseqttl%TYPE,
                       p_inpessoa crapass.inpessoa%TYPE ) IS
     SELECT p_inpessoa    inpessoa
           ,tfc.cdseqtfc
           ,'(' || gene0002.fn_mask(tfc.nrdddtfc,'99') || ') ' || DECODE(LENGTH(tfc.nrtelefo),8,'XXXX','XXXXX')  || '-' || SUBSTR(tfc.nrtelefo,-4) nr_fone_format
           ,DECODE(p_inpessoa,1,DECODE(tfc.tptelefo,2,1,1,2,3,3,4,4) ,(DECODE(tfc.tptelefo,3,1,2,2,1,3,4,4) )) nrordreq
       FROM craptfc tfc
      WHERE tfc.cdcooper = p_cdcooper
        AND tfc.nrdconta = p_nrdconta
        AND tfc.idseqttl = p_idseqttl
        AND tfc.idsittfc = 1 -- ATIVO
        --AND ((p_inpessoa = 1 AND tfc.tptelefo IN (1,2,4))
        --  OR (p_inpessoa = 2 AND tfc.tptelefo IN (1,2,3,4)))
       ORDER BY nrordreq -- DECODE(tfc.tptelefo,3,1,2,2,1,3,4,4)
               ,tfc.cdseqtfc DESC;
    rw_craptfc cr_craptfc%ROWTYPE;


    --------------> Variaveis <----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);

    vr_qtmeatel INTEGER:=0;
    vr_qtdifdat INTEGER; -- diferenca em meses da data
    vr_dtatutel DATE;
    vr_inpessoa INTEGER;

    vr_exc_erro EXCEPTION;
    vr_exc_sair EXCEPTION;

  BEGIN

    -- VERIFICAR PARAMETRO DA COOPERATIVA
    OPEN cr_crapcop(p_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO vr_qtmeatel;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperativa não encontrada!';
      RAISE vr_exc_erro;
    END IF;
    -- Fechar o cursor
    CLOSE cr_crapcop;

    pr_qtmeatel := vr_qtmeatel;


    -- SE COOP NAO CONFIGURADA, NAO PRECISA ATUALIZAR, RETORNA FALSO
    IF vr_qtmeatel = 0 THEN
      pr_atualiza := 'NAO';  -- NAO PRECISA ATUALIZAR TELEFONE
      pr_dsnrfone := '';
      -- APENAS SAI
      RAISE vr_exc_sair;
    END IF;


    -- Leitura do calendário da cooperativa, para alguns procedimentos que precisam
    -- receber como parametro
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := 'Sistema sem data de movimento.';
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;


    -- SE vr_qtmeatel É DIFERENTE DE ZERO, VERIFICA DATA ATUALIZACAO DA CONTA
    -- VERIFICAR TIPO PESSOA E DATA ATUALIZACAO
    OPEN cr_ttl_jur(p_cdcooper => pr_cdcooper
                   ,p_nrdconta => pr_nrdconta
                   ,p_idseqttl => pr_idseqttl
                   ,p_dtmvtolt => rw_crapdat.dtmvtocd);
    FETCH cr_ttl_jur INTO rw_ttl_jur;
    -- Se não encontrar
    IF cr_ttl_jur%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_ttl_jur;
      vr_cdcritic := 0;
      vr_dscritic := 'Associado não encontrado!';
      RAISE vr_exc_erro;
    END IF;
    -- Fechar o cursor
    CLOSE cr_ttl_jur;


    vr_dtatutel := rw_ttl_jur.dtatutel;
    vr_inpessoa := rw_ttl_jur.inpessoa;
    vr_qtdifdat := rw_ttl_jur.dif_data; -- Diferenca em meses da data do dia com a data da atualizacao

    -- SE A DATA É NULA, RETORNA 999, DEVE VERIFICAR ULTIMA REVISAO CADASTRAL
    IF vr_qtdifdat = 999 THEN
       FOR rw_crapalt IN cr_crapalt(p_cdcooper => pr_cdcooper
                                   ,p_nrdconta => pr_nrdconta
                                   ,p_dtmvtolt => rw_crapdat.dtmvtocd) LOOP

         IF (instr(lower(rw_crapalt.dsaltera), 'revisao cadastral') > 0) THEN
           -- SE ENCONTROU REVISAO, ARMAZENA DIFERENCA E SAI DO LOOP
           vr_qtdifdat := rw_crapalt.dif_data; -- Diferenca em meses da data do dia com a data da revisao
           EXIT; -- SAI DO LOOP/FOR
         END IF;
       END LOOP;


       /** SE A DATA CONTINUOU 999(NULA), BUSCA DTADMISS DO ASSOCIADO */
       IF vr_qtdifdat = 999 THEN
          OPEN cr_crapass(p_cdcooper => pr_cdcooper
                         ,p_nrdconta => pr_nrdconta
                         ,p_dtmvtolt => rw_crapdat.dtmvtocd);
          FETCH cr_crapass INTO vr_qtdifdat;
          -- Fechar o cursor
          CLOSE cr_crapass;
       END IF;

    END IF;


    -- SE DIF DE MESES FOR SUPERIOR AO PARAMETRO DA COOP,
    -- SOLICITA ALTERACAO TELEFONE
    IF vr_qtdifdat > vr_qtmeatel THEN

      -- BUSCA TELEFONE ATUAL DA CONTA
      OPEN cr_craptfc(p_cdcooper => pr_cdcooper
                     ,p_nrdconta => pr_nrdconta
                     ,p_idseqttl => pr_idseqttl
                     ,p_inpessoa => vr_inpessoa);
      FETCH cr_craptfc INTO rw_craptfc;
      -- Se não encontrar
      IF cr_craptfc%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craptfc;

        pr_atualiza := 'SIM';
        pr_dsnrfone := ''; -- SEM TELEFONE CADASTRADO
        RAISE vr_exc_sair;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craptfc;

      -- PRECISA ATUALIZAR TELEFONE
      pr_atualiza := 'SIM';
      pr_dsnrfone := rw_craptfc.nr_fone_format;

    ELSE
      -- NAO PRECISA ATUALIZAR TELEFONE
      pr_atualiza := 'NAO';
      pr_dsnrfone := '';
    END IF;

    pr_cdcritic := 0;
    pr_dscritic := '';

  EXCEPTION
    WHEN vr_exc_sair THEN
      -- Sair da procedure - Nao precisa atualizar
      pr_cdcritic := 0;
      pr_dscritic := '';

    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_atualiza := 'NAO';  -- NAO PRECISA ATUALIZAR TELEFONE
      pr_dsnrfone := '';

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel consultar dados telefone: '||SQLERRM;
      pr_atualiza := 'NAO';
      pr_dsnrfone := '';

  END pc_verifica_atualiz_fone;


  PROCEDURE pc_ib_verif_atualiz_fone(pr_cdcooper IN crapttl.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_nrdconta IN crapttl.nrdconta%TYPE  --> Numero da Conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencia do Titular
                                    ,pr_inpessoa IN crapttl.inpessoa%TYPE  --> Indicador PF/PJ
                                    ,pr_cdcritic OUT INTEGER
                                    ,pr_dscritic OUT VARCHAR2) IS
  /* ..........................................................................
    --
    --  Programa : pc_ib_verif_atualiz_fone
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Guilherme/SUPERO
    --  Data     : Novembro/2016.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --               EXCLUSIVO PARA CHAMADA INTERNET BANKING
    --
    --   Objetivo  : Efetua o processo de Verificar Atualização Telefone, Atualizar Data Telefone,
    --               Criar mensagem para o Cooperado no IB.
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <----------------
    -- Busca cooperativa
    CURSOR cr_crapcop(p_cdcooperc IN crapcop.cdcooper%TYPE)IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = p_cdcooperc;
    rw_crapcop cr_crapcop%ROWTYPE;



    -- BUSCAR O TELEFONE CADASTRADO
    CURSOR cr_craptfc (p_cdcooper crapass.cdcooper%TYPE,
                       p_nrdconta crapass.nrdconta%TYPE,
                       p_idseqttl crapttl.idseqttl%TYPE,
                       p_inpessoa crapttl.inpessoa%TYPE) IS
      SELECT *
        FROM (
               SELECT tfc.cdseqtfc
                     ,'(' || gene0002.fn_mask(tfc.nrdddtfc,'99') || ') ' || DECODE(LENGTH(tfc.nrtelefo),8,'XXXX','XXXXX')  || '-' || SUBSTR(tfc.nrtelefo,-4) nr_fone_format
                     ,DECODE(tfc.tptelefo,1,'RESIDENCIAL',2,'CELULAR',3,'COMERCIAL',4,'CONTATO') dstelefo
                     ,DECODE(p_inpessoa,1,DECODE(tfc.tptelefo,2,1,1,2,3,3,4,4) ,(DECODE(tfc.tptelefo,3,1,2,2,1,3,4,4) )) nrordreq
                     ,ROW_NUMBER() OVER (PARTITION BY tfc.tptelefo
                                             ORDER BY DECODE(tfc.tptelefo,3,1,2,2,1,3,4,4)
                                                     ,tfc.cdseqtfc DESC) nrseqreg
                 FROM craptfc tfc
                WHERE tfc.cdcooper = p_cdcooper
                  AND tfc.nrdconta = p_nrdconta
                  AND tfc.idseqttl = p_idseqttl
                  AND tfc.idsittfc = 1 -- ATIVO
                 ORDER BY nrordreq --DECODE(tfc.tptelefo,3,1,2,2,1,3,4,4)
                         ,tfc.cdseqtfc DESC
              ) tmp
         WHERE tmp.nrseqreg = 1; -- PEGAR APENAS O 1º TELEFONE DE CADA TIPO
    rw_craptfc cr_craptfc%ROWTYPE;

    --------------> Variaveis <----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_inpessoa INTEGER;
    vr_atualiza VARCHAR2(4);
    vr_dsnrfone VARCHAR(18);
    vr_qtmeatel INTEGER;
    vr_dsmensag VARCHAR2(1000);
    vr_lstfones VARCHAR2(200):='';

    vr_exc_erro EXCEPTION;

    -- Objetos para armazenar as variáveis da notificação
    vr_variaveis_notif NOTI0001.typ_variaveis_notif;
    vr_notif_origem   tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE;
    vr_notif_motivo   tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE;

  BEGIN

    -- Verifica cooperativa
    OPEN cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    IF cr_crapcop%NOTFOUND THEN
      -- Gera crítica
      vr_cdcritic := 794;
      -- Fecha cursor
      CLOSE cr_crapcop;
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    -- Fecha cursor
    CLOSE cr_crapcop;


    -- VERIFICAR SE A CONTA PRECISA ATUALIZAR O TELEFONE
    CADA0004.pc_verifica_atualiz_fone(pr_cdcooper => pr_cdcooper
                                    , pr_nrdconta => pr_nrdconta
                                    , pr_idseqttl => pr_idseqttl
                                    , pr_cdcritic => vr_cdcritic
                                    , pr_dscritic => vr_dscritic
                                    , pr_atualiza => vr_atualiza
                                    , pr_dsnrfone => vr_dsnrfone
                                    , pr_qtmeatel => vr_qtmeatel);
    -- SE DEU ERRO...
    IF vr_cdcritic <> 0
    OR vr_dscritic IS NOT NULL THEN

      -- APENAS SAI
      RAISE vr_exc_erro;

    ELSE -- NAO DEU ERRO.

      IF vr_atualiza = 'SIM' THEN
         -- SE PRECISA ATUALIZAR TELEFONE, ATUALIZA A DATA DE MANUTENÇÃO DO TELEFONE
         CADA0004.pc_atualiz_data_manut_fone(pr_cdcooper => pr_cdcooper
                                           , pr_nrdconta => pr_nrdconta
                                           , pr_cdcritic => vr_cdcritic
                                           , pr_dscritic => vr_dscritic);
         -- SE DEU ERRO...
         IF vr_cdcritic <> 0
         OR vr_dscritic IS NOT NULL THEN
           -- APENAS SAI
           RAISE vr_exc_erro;

         ELSE -- NAO DEU ERRO.

           -- MONTAR A LISTA DE TELEFONES DO COOPERADO
           FOR rw_craptfc IN cr_craptfc(p_cdcooper => pr_cdcooper
                                       ,p_nrdconta => pr_nrdconta
                                       ,p_idseqttl => pr_idseqttl
                                       ,p_inpessoa => pr_inpessoa) LOOP
             vr_lstfones := vr_lstfones || '</br>' ||
                            rw_craptfc.dstelefo || ': ' ||rw_craptfc.nr_fone_format;
           END LOOP;

           -- CRIAR MENSAGEM NA CAIXA DO COOPERADO NO IB
           IF vr_lstfones IS NULL THEN
             vr_dsmensag := 'Cooperado,' ||
                            '</br></br>' ||
                            'Identificamos que você NÃO possui telefones cadastrados em nossa '      ||
                            'base de contatos.'                                                      ||
                            '</br></br>' ||
                            'Estes telefones poderão ser utilizados para informar você sobre algum ' ||
                            'evento importante da sua cooperativa ou de sua conta.'                  ||
                            '</br></br>' ||
                            '<a style=''color: blue; font-weight: bold; text-decoration: underline;'''||
                            ' href=''meu_cadastro.php''>Clique aqui</a> '                            ||
                            'e informe seus telefones para contato.'                                 ||
                            '</br></br>' ||
                            'Em caso de dúvidas relacionadas a atualização cadastral, entre em '     ||
                            'contato com seu Posto de Atendimento ou através do SAC da cooperativa, '||
                            'pelo 0800 647 2200 ou e-mail sac@ailos.coop.br.';

             vr_notif_origem   := 7;
             vr_notif_motivo   := 1;

           ELSE
             vr_dsmensag := 'Cooperado,' ||
                            '</br></br>' ||
                            'Identificamos que você possui telefones cadastrados em nossa base de '  ||
                            'contatos, porém os números não são atualizados há mais de '             ||
                            to_char(vr_qtmeatel) || ' meses.'                                        ||
                            '</br></br>' ||
                            'Telefones cadastrados:'                                                 ||
                            vr_lstfones                                                              ||
                            '</br></br>' ||
                            'Caso os números estejam desatualizados, '                               ||
                            '<a style=''color: blue; font-weight: bold; text-decoration: underline;'''||
                            ' href=''meu_cadastro.php''>clique aqui</a> '                            ||
                            'e adicione seus novos contatos ou procure o Posto de Atendimento '      ||
                            'para atualizar seu cadastro.'                                           ||
                            '</br>' ||
                            'Em caso de dúvidas relacionadas a atualização cadastral, entre em '     ||
                            'contato pelo SAC 0800 647 2200 ou através do e-mail '                   ||
                            'sac@ailos.coop.br, todos os dias (incluindo domingos e feriados), '    ||
                            'das 6h às 22h.';

             vr_notif_origem   := 7;
             vr_notif_motivo   := 2;
             vr_variaveis_notif('#qtmeatel') := to_char(vr_qtmeatel);
             vr_variaveis_notif('#lstfones') := vr_lstfones;

           END IF;

           -- CRIAR A MENSAGEM NA CONTA DO COOPERADO
           gene0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_idseqttl => 1 -- SEMPRE PRO PRIMEIRO TITULAR
                                     ,pr_cdprogra => 'CADA0004'
                                     ,pr_inpriori => 0
                                     ,pr_dsdmensg => vr_dsmensag
                                     ,pr_dsdassun => 'Atualização de Telefone'
                                     ,pr_dsdremet => rw_crapcop.nmrescop
                                     ,pr_dsdplchv => 'Atualização de Telefone'
                                     ,pr_cdoperad => 996
                                     ,pr_cdcadmsg => 0
                                     ,pr_dscritic => vr_dscritic);

           IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_erro;
           END IF;

           COMMIT; -- COMMITAR A MENSAGEM NA BASE
           pr_dscritic := vr_dsmensag;
           --
           -- Cria uma notificação
           noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => vr_notif_origem
                                       ,pr_cdmotivo_mensagem => vr_notif_motivo
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => 1 -- fixo Primeiro titular
                                       ,pr_variaveis => vr_variaveis_notif);
           --

         END IF;

      END IF;

    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel consultar dados telefone: '||SQLERRM;

  END pc_ib_verif_atualiz_fone;
  /* verifica se pode imprimir a declaração de isenção de IOF */
  PROCEDURE pc_pode_impr_dec_pj_coop(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                    ,pr_nrdconta IN crapcop.nrdconta%TYPE --> Numero da Conta
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informac?es de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
    /* .............................................................................
        Programa: pc_pode_impr_dec_pj_coop
        Sistema : AYLLOS
        Sigla   : EMPR
        Autor   : Diogo (MoutS)
        Data    : Outubro/17.                    Ultima atualizacao: 11/10/2017
        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina de verificacao se pode imprimir a DECLARAÇÃO DE PESSOA JURíDICA COOPERATIVA
        Observacao: -----
        Alteracoes:
        ..............................................................................*/
  DECLARE
    --Variaveis
    vr_des_reto VARCHAR2(1);
    vr_err_efet INTEGER;
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    CURSOR cr_pode_imprimir(pr_cdcooper IN crapcop.cdcooper%TYPE
                 ,pr_nrdconta IN crapcop.nrdconta%TYPE) IS
      SELECT natjurid
      FROM crapjur
      WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta
                  AND natjurid = 2143;
    rw_pode_imprimir cr_pode_imprimir%ROWTYPE;
    BEGIN
      --Consulta
      OPEN cr_pode_imprimir(pr_cdcooper, pr_nrdconta);
      FETCH cr_pode_imprimir INTO rw_pode_imprimir;
      IF cr_pode_imprimir%FOUND THEN
        vr_des_reto := 'S';
      ELSE
        vr_des_reto := 'N';
      END IF;
      CLOSE cr_pode_imprimir;
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                   pr_tag_pai  => 'Dados',
                   pr_posicao  => 0,
                   pr_tag_nova => 'ConfereDados',
                   pr_tag_cont => vr_des_reto,
                   pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
        pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro Geral em Consulta de Declaração de Isenção de IOF: ' || SQLERRM;
        pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_pode_impr_dec_pj_coop;
  PROCEDURE pc_impr_dec_pj_coop_xml(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                   ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da conta
                                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE --> Numero do CPF
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS
        --> Erros do processo
        /* .............................................................................
           Programa: pc_imprime_declaracao_recursos_isencao_iof_xml
           Sistema : Conta-Corrente - Cooperativa de Credito
           Sigla   : CRED
           Autor   : Diogo (Mouts)
           Data    : Outubro/2017.                         Ultima atualizacao: 04/10/2017
           Dados referentes ao programa:
           Frequencia: Sempre que for chamado.
           Objetivo  : Efetuar a impressao da Declaração de Utilização de Recursos para Isenção de IOF

           Alteracoes: 19/02/2018 - Ajustes na geracao de pendencia de digitalizacao.
                                    PRJ366 (Odirlei-AMcom)

        ............................................................................. */
        -- Cursor com os dados do cooperado
        CURSOR cr_crapass IS
            SELECT crapass.nrdconta,
                   gene0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc, crapass.inpessoa) AS nrcpfcgc,
                   crapass.nrcpfcgc nrcpfcgc_sf,
                   crapass.nmprimtl,
                   crapenc.nrcepend,
                   crapenc.dsendere,
                   crapenc.nrendere,
                   crapenc.complend,
                   crapenc.nmbairro,
                   crapenc.nmcidade,
                   crapenc.cdufende,
                   crapenc.nrcxapst,
                   TO_CHAR(crapjur.dtiniatv, 'yyyy') AS dtiniatv
            FROM crapass
            LEFT JOIN crapjur ON crapjur.cdcooper = crapass.cdcooper AND crapjur.nrdconta = crapass.nrdconta
            LEFT JOIN crapenc
            ON crapenc.nrdconta = crapass.nrdconta
               AND crapenc.idseqttl = 1
               AND crapenc.cdseqinc = 1
               AND crapenc.cdcooper = pr_cdcooper
            --               AND crapenc.tpendass = 9
            WHERE crapass.nrdconta = pr_nrdconta
                  AND crapass.nrcpfcgc = pr_nrcpfcgc;
        rw_crapass cr_crapass%ROWTYPE;

        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
        vr_cdcritic PLS_INTEGER;
        vr_dscritic VARCHAR2(4000);
        -- Variaveis gerais
        vr_texto_completo VARCHAR2(32600); --> Variável para armazenar os dados do XML antes de incluir no CLOB
        vr_des_xml        CLOB; --> XML do relatorio
        vr_cdprogra       VARCHAR2(10) := 'EMPR0003'; --> Nome do programa
        rw_crapdat        btch0001.cr_crapdat%ROWTYPE; --> Cursor genérico de calendário
        vr_nom_direto     VARCHAR2(200); --> Diretório para gravação do arquivo
        vr_nmarqimp       VARCHAR2(50); --> nome do arquivo PDF
        vr_temp           VARCHAR2(1000); --> Temporária para gravação do texto XML

        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);

        -- variaveis de críticas
        vr_tab_erro  GENE0001.typ_tab_erro;
        vr_des_reto  VARCHAR2(10);
        vr_typ_saida VARCHAR2(3);
    BEGIN

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
        vr_dscritic := NULL;

        -- Leitura do calendário da cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
        --Informações do associado
        OPEN cr_crapass;
        FETCH cr_crapass
            INTO rw_crapass;
        CLOSE cr_crapass;
        vr_des_xml := NULL;
        --XML de envio
        vr_temp := '<?xml version="1.0" encoding="utf-8"?>' || '<associado>' || '<nrdconta>' ||
                   rw_crapass.nrdconta || '</nrdconta>' || '<nrcpfcgc>' || rw_crapass.nrcpfcgc ||
                   '</nrcpfcgc>' || '<nmprimtl>' || rw_crapass.nmprimtl || '</nmprimtl>' ||
                   '<nrcepend>' || rw_crapass.nrcepend || '</nrcepend>' || '<dsendere>' ||
                   rw_crapass.dsendere || '</dsendere>' || '<nrendere>' || rw_crapass.nrendere ||
                   '</nrendere>' || '<complend>' || rw_crapass.complend || '</complend>' ||
                   '<nmbairro>' || rw_crapass.nmbairro || '</nmbairro>' || '<nmcidade>' ||
                   rw_crapass.nmcidade || '</nmcidade>' || '<cdufende>' || rw_crapass.cdufende ||
                   '</cdufende>' || '<nrcxapst>' || rw_crapass.nrcxapst || '</nrcxapst>' ||
                   '<dtiniatv>' || rw_crapass.dtiniatv || '</dtiniatv>' ||
                   '</associado>';
        -- Inicializar o CLOB
        vr_des_xml := NULL;
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Escreve o XML no CLOB
        vr_texto_completo := NULL;
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, vr_temp, TRUE);
        -- Busca diretorio padrao da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                              ,
                                               pr_cdcooper => pr_cdcooper,
                                               pr_nmsubdir => 'arquivos');
        GENE0001.pc_OScommand_Shell(pr_des_comando => 'mkdir -p ' || vr_nom_direto);
        -- Solicita geracao do PDF
        vr_nmarqimp := '/dec_pj_coop_' || pr_nrdconta || pr_nrcpfcgc || '.pdf';
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,
                                    pr_cdprogra  => vr_cdprogra,
                                    pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                                    pr_dsxml     => vr_des_xml,
                                    pr_dsxmlnode => '/',
                                    pr_dsjasper  => 'dec_pessoa_juridica_cooperativa.jasper',
                                    pr_dsparams  => NULL,
                                    pr_dsarqsaid => vr_nom_direto || vr_nmarqimp,
                                    pr_flg_gerar => 'S',
                                    pr_qtcoluna  => 234,
                                    pr_sqcabrel  => 1,
                                    pr_flg_impri => 'S',
                                    pr_nmformul  => ' ',
                                    pr_nrcopias  => 1,
                                    pr_nrvergrl  => 1,
                                    pr_parser    => 'R' --> Seleciona o tipo do parser. "D" para VTD e "R" para Jasper padrão
                                   ,
                                    pr_des_erro  => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
            -- verifica retorno se houve erro
            RAISE vr_exc_saida; -- encerra programa
        END IF;
        -- copia o pdf do diretorio da cooperativa para servidor web
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper,
                                     pr_cdagenci => NULL,
                                     pr_nrdcaixa => NULL,
                                     pr_nmarqpdf => vr_nom_direto || vr_nmarqimp,
                                     pr_des_reto => vr_des_reto,
                                     pr_tab_erro => vr_tab_erro);
        -- caso apresente erro na operação
        IF nvl(vr_des_reto, 'OK') <> 'OK' THEN
            IF vr_tab_erro.COUNT > 0 THEN
                -- verifica pl-table se existe erros
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
                RAISE vr_exc_saida; -- encerra programa
            END IF;
        END IF;
        -- Remover relatorio do diretorio padrao da cooperativa
        gene0001.pc_OScommand(pr_typ_comando => 'S',
                              pr_des_comando => 'rm ' || vr_nom_direto || vr_nmarqimp,
                              pr_typ_saida   => vr_typ_saida,
                              pr_des_saida   => vr_dscritic);
        -- Se retornou erro
        IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT NULL THEN
            -- Concatena o erro que veio
            vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
            RAISE vr_exc_saida; -- encerra programa
        END IF;
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        vr_nmarqimp := substr(vr_nmarqimp, 2); -- retornar somente o nome do PDF sem a barra"/"
        -- Criar XML de retorno para uso na Web
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
                                       vr_nmarqimp || '</nmarqpdf>');

        --> Declaraçao PJ cooperativa
        DIGI0001.pc_gera_pend_digitalizacao( pr_cdcooper  => pr_cdcooper         --> Codigo da cooperativa
                                            ,pr_nrdconta  => pr_nrdconta         --> Nr. da conta
                                            ,pr_idseqttl  => 1                   --> Indicador de titular
                                            ,pr_nrcpfcgc  => rw_crapass.nrcpfcgc_sf --> Numero do CPF/CNPJ
                                            ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento
                                            ,pr_lstpdoct  => 56                  --> declaraçao PJ cooperativa                   --> lista de Tipo do documento separados por ;
                                            ,pr_cdoperad  => nvl(vr_cdoperad,' ')--> Codigo do operador
                                            ,pr_cdcritic  => vr_cdcritic         --> Codigo da critica
                                            ,pr_dscritic  => vr_dscritic);       --> Descricao da critica


        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

    EXCEPTION
        WHEN vr_exc_saida THEN
            -- Se foi retornado apenas código
            IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
                -- Buscar a descrição
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            END IF;
            -- Devolvemos código e critica encontradas das variaveis locais
            pr_cdcritic := NVL(vr_cdcritic, 0);
            pr_dscritic := vr_dscritic;
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                           upper(pr_dscritic) || '</Erro></Root>');
            ROLLBACK;
        WHEN OTHERS THEN
            -- Efetuar retorno do erro não tratado
            pr_cdcritic := 0;
            pr_dscritic := SQLERRM;
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                           upper(pr_dscritic) || '</Erro></Root>');
            ROLLBACK;
    END pc_impr_dec_pj_coop_xml;
  PROCEDURE pc_buscar_tbcota_devol (pr_cdcooper         IN  tbcotas_devolucao.cdcooper%TYPE --> Codigo da Cooperativa
                                   ,pr_nrdconta         IN  tbcotas_devolucao.nrdconta%TYPE --> Numero da conta
                                   ,pr_tpdevolucao      IN  tbcotas_devolucao.tpdevolucao%TYPE --> Indicador de forma de devolucao (1-Total / 2-Parcelado / 3-Sobras Cotas Demitido / 4-Sobras Deposito Demitido)
                                   ,pr_vlcapital        OUT tbcotas_devolucao.vlcapital%TYPE --> Valor Cotas ou Deposito
                                   ,pr_dtinicio_credito OUT tbcotas_devolucao.dtinicio_credito%TYPE --> Valor Cotas ou Deposito
                                   ,pr_vlpago           OUT tbcotas_devolucao.vlpago%TYPE --> Valor Cotas ou Deposito
                                   ,pr_cdcritic         OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                   ,pr_dscritic         OUT VARCHAR2)IS --> Descricao da critica

      CURSOR cr_tbcotas_devolucao IS
        select VLCAPITAL
              ,DTINICIO_CREDITO
              ,VLPAGO
          from TBCOTAS_DEVOLUCAO
         where CDCOOPER    = pr_cdcooper
           and NRDCONTA    = pr_nrdconta
           and TPDEVOLUCAO = pr_tpdevolucao;

      rw_tbcotas_devolucao cr_tbcotas_devolucao%ROWTYPE;

  BEGIN
    OPEN cr_tbcotas_devolucao;
    FETCH cr_tbcotas_devolucao
     INTO rw_tbcotas_devolucao;

    IF cr_tbcotas_devolucao%NOTFOUND THEN
      pr_cdcritic         := 0;
      pr_dscritic         := 'NAO EXISTE VALOR PARA DEVOLUCAO';
    ELSE
       IF rw_tbcotas_devolucao.dtinicio_credito is null THEN
          pr_cdcritic     := 0;
          pr_dscritic     := 'PAGAMENTO DEVE SER AUTORIZADO PELA OPCAO H DA TELA MATRIC';
          pr_vlcapital        := rw_tbcotas_devolucao.vlcapital;
          pr_dtinicio_credito := rw_tbcotas_devolucao.dtinicio_credito;
          pr_vlpago           := rw_tbcotas_devolucao.vlpago;
       ELSIF greatest(0,rw_tbcotas_devolucao.vlcapital - rw_tbcotas_devolucao.vlpago) = 0 THEN
        IF rw_tbcotas_devolucao.dtinicio_credito is not null THEN
          pr_cdcritic     := 0;
          pr_dscritic     := 'R$ '||rw_tbcotas_devolucao.vlcapital||' JA PAGO EM '||to_char(rw_tbcotas_devolucao.dtinicio_credito,'DD/MM/YYYY');
        ELSE
          pr_cdcritic     := 0;
          pr_dscritic     := 'NAO EXISTE VALOR PARA DEVOLUCAO';
        END IF;
    ELSE
      pr_vlcapital        := rw_tbcotas_devolucao.vlcapital;
      pr_dtinicio_credito := rw_tbcotas_devolucao.dtinicio_credito;
      pr_vlpago           := rw_tbcotas_devolucao.vlpago;
      pr_cdcritic         := null;
      pr_dscritic         := null;
    END IF;
    END IF;
    CLOSE cr_tbcotas_devolucao;

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      ROLLBACK;
  END pc_buscar_tbcota_devol;

  /* Rotina para buscar valores para devolver  */
  PROCEDURE pc_buscar_tbcota_devol_web(pr_nrdconta   IN  tbcotas_devolucao.nrdconta%TYPE --> Numero da conta
                                      ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                      ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_buscar_tbcota_devol_web                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Jonata - RKAM
  --  Data     : Dezembro / 2017.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina para buscar valores a devolver referete a sobras de cotas e sobras de depósito
  --
  ---------------------------------------------------------------------------------------------------------------

    CURSOR cr_tbcotas_devolucao(pr_cdcooper tbcotas_devolucao.cdcooper%TYPE
                               ,pr_nrdconta tbcotas_devolucao.nrdconta%TYPE
                               ,pr_tpdevolucao tbcotas_devolucao.tpdevolucao%TYPE) IS
    select VLCAPITAL
          ,DTINICIO_CREDITO
          ,VLPAGO
          ,(VLCAPITAL - VLPAGO) vldisponivel
      from TBCOTAS_DEVOLUCAO
     where CDCOOPER    = pr_cdcooper
       and NRDCONTA    = pr_nrdconta
       and TPDEVOLUCAO = pr_tpdevolucao;
    rw_tbcotas_devolucao cr_tbcotas_devolucao%ROWTYPE;

    -- Variáveis
    vr_cdcooper    NUMBER;
    vr_nmdatela    VARCHAR2(25);
    vr_nmeacao     VARCHAR2(25);
    vr_cdagenci    VARCHAR2(25);
    vr_nrdcaixa    VARCHAR2(25);
    vr_idorigem    VARCHAR2(25);
    vr_cdoperad    VARCHAR2(25);
    vr_retxml      CLOB;

    --------------> VARIAVEIS <-----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);

    vr_excerror    EXCEPTION;

    vr_vlcapital tbcotas_devolucao.vlcapital%TYPE := 0;
    vr_vlpago    tbcotas_devolucao.vlpago%TYPE := 0;
    vr_dtinicio_credito tbcotas_devolucao.dtinicio_credito%TYPE;
    vr_flgvalor  BOOLEAN := FALSE;

  BEGIN

    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excerror;
    END IF;

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Cotas', pr_tag_cont => null, pr_des_erro => vr_dscritic);

    --Busca valor de cotas a devolver
    OPEN cr_tbcotas_devolucao(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta         => pr_nrdconta
                             ,pr_tpdevolucao => 3);

    FETCH cr_tbcotas_devolucao
     INTO rw_tbcotas_devolucao;

    IF cr_tbcotas_devolucao%FOUND THEN

      vr_flgvalor := TRUE;

    END IF;

    CLOSE cr_tbcotas_devolucao;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cotas', pr_posicao => 0, pr_tag_nova => 'vldisponivel', pr_tag_cont => to_char(nvl(rw_tbcotas_devolucao.vldisponivel,0),'fm999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);

    IF rw_tbcotas_devolucao.dtinicio_credito IS NOT NULL THEN

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cotas', pr_posicao => 0, pr_tag_nova => 'dsdisponivel', pr_tag_cont => 'Capital R$ '||rw_tbcotas_devolucao.vlpago||' JA PAGO EM '||to_char(rw_tbcotas_devolucao.dtinicio_credito,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);

    END IF;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Depositos', pr_tag_cont => null, pr_des_erro => vr_dscritic);

    --Inicializa vaor do rowtype
    rw_tbcotas_devolucao:= NULL;

    --Busca valor de depósito a devolver
    OPEN cr_tbcotas_devolucao(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta         => pr_nrdconta
                             ,pr_tpdevolucao => 4);

    FETCH cr_tbcotas_devolucao
     INTO rw_tbcotas_devolucao;

    IF cr_tbcotas_devolucao%FOUND THEN

      vr_flgvalor := TRUE;

    END IF;

    CLOSE cr_tbcotas_devolucao;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Depositos', pr_posicao => 0, pr_tag_nova => 'vldisponivel', pr_tag_cont => to_char(nvl(rw_tbcotas_devolucao.vldisponivel,0),'fm999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);

    IF rw_tbcotas_devolucao.dtinicio_credito IS NOT NULL THEN
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Depositos', pr_posicao => 0, pr_tag_nova => 'dsdisponivel', pr_tag_cont => 'Depósito R$ '||rw_tbcotas_devolucao.vlpago||' JA PAGO EM '||to_char(rw_tbcotas_devolucao.dtinicio_credito,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);

    END IF;

    IF NOT vr_flgvalor THEN

      pr_cdcritic     := 0;
      pr_dscritic     := 'NAO EXISTE VALOR PARA DEVOLUCAO';

      RAISE vr_excerror;

    END IF;

  EXCEPTION
    WHEN vr_excerror THEN
      pr_des_erro := pr_dscritic;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros '||pr_dscritic||'</Erro></Root>');
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral na rotina pc_buscar_tbcota_devol_web: '||SQLERRM;
      pr_des_erro := pr_dscritic;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
  END pc_buscar_tbcota_devol_web;

  PROCEDURE pc_atualizar_tbcota_devol(pr_cdcooper       IN  tbcotas_devolucao.cdcooper%TYPE --> Codigo da Cooperativa
                                     ,pr_nrdconta       IN  tbcotas_devolucao.nrdconta%TYPE --> Numero da conta
                                     ,pr_tpdevolucao    IN  tbcotas_devolucao.tpdevolucao%TYPE --> Indicador de forma de devolucao (1-Total / 2-Parcelado / 3-Sobras Cotas Demitido / 4-Sobras Deposito Demitido)
                                     ,pr_vlpago         IN tbcotas_devolucao.vlpago%TYPE --> Valor Cotas ou Deposito
                                     ,pr_cdcritic       OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                     ,pr_dscritic       OUT VARCHAR2) IS --> Descricao da critica
  BEGIN
    pr_cdcritic       := null;
    pr_dscritic       := null;

    update TBCOTAS_DEVOLUCAO
       set VLPAGO      = VLPAGO + nvl(pr_vlpago,0),
         DTINICIO_CREDITO = trunc(SYSDATE)
     where CDCOOPER    = pr_cdcooper
       and NRDCONTA    = pr_nrdconta
       and TPDEVOLUCAO = pr_tpdevolucao;
    IF SQL%ROWCOUNT = 0 THEN
      pr_cdcritic     := 0;
      pr_dscritic     := 'NAO ENCONTROU REGISTRO PARA ATUALIZAR';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      ROLLBACK;
  END pc_atualizar_tbcota_devol;

  PROCEDURE pc_retorna_cartao_valido(pr_nrdconta IN crapcrm.nrdconta%TYPE  --> Código da opção
                                    ,pr_idtipcar IN INTEGER                --> Indica qual o cartao
                                    ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Indica o tipo de pessoa
                                                                             -- 1 = PF
                                                                             -- 2 = PJ
                                                                             -- 4 = PF, retornar somente os cartões do titular da conta
                                    ,pr_xmllog   IN VARCHAR2                --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS           --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_retorna_cartao_valido
    --  Sistema  : Rotinas para buscar cartao magnetico e cecred
    --  Sigla    : CRED
    --  Autor    : Mateus Zimmermann - Mouts
    --  Data     : Dezembro/2017.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar os cartoes da conta
    --
    --  Alteracoes:
    -- .............................................................................
  BEGIN
    DECLARE

      -- Cursor sobre a tabela de datas
      rw_crapdat  btch0001.cr_crapdat%ROWTYPE;

      CURSOR cr_crapcrm(pr_cdcooper IN crapcop.cdcooper%TYPE)IS
      SELECT crapcrm.nrcartao
        FROM crapcrm
       WHERE crapcrm.cdcooper = pr_cdcooper
         AND crapcrm.nrdconta = pr_nrdconta
         AND crapcrm.cdsitcar = 2
         AND crapcrm.dtvalcar > rw_crapdat.dtmvtolt
         AND crapcrm.tptitcar = CASE WHEN pr_inpessoa IN (1,4) THEN 1 ELSE crapcrm.tptitcar END
         AND crapcrm.tpusucar = CASE WHEN pr_inpessoa IN (4)   THEN 1 ELSE crapcrm.tpusucar END -- Somente cartão do titular da conta
         AND crapcrm.dtentcrm IS NOT NULL;
      rw_crapcrm cr_crapcrm%ROWTYPE;

      CURSOR cr_crawcrd(pr_cdcooper IN craptip.cdcooper%TYPE) IS
      SELECT crawcrd.nrcrcard
        FROM crawcrd
       WHERE crawcrd.cdcooper = pr_cdcooper
         AND crawcrd.nrdconta = pr_nrdconta
         AND crawcrd.insitcrd = 4
         AND crawcrd.dtentreg < rw_crapdat.dtmvtolt
         AND crawcrd.dtvalida > rw_crapdat.dtmvtolt
         AND (pr_inpessoa IN (1,2)
          OR (pr_inpessoa = 4 AND crawcrd.nrcpftit IN (SELECT a.nrcpfcgc -- Somente cartão do titular da conta
                                                         FROM crapass a
                                                        WHERE a.cdcooper = crawcrd.cdcooper
                                                          AND a.nrdconta = crawcrd.nrdconta)))
         AND crawcrd.dtcancel IS NULL;
      rw_crawcrd cr_crawcrd%ROWTYPE;

      -- Variaveis locais
      vr_cdoperad VARCHAR2(100);
      vr_cdcooper NUMBER;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_auxconta PLS_INTEGER := 0;
      vr_vlminimo NUMBER (25,2) := 0;
      vr_nrcartao crapcrm.nrcartao%TYPE;
      vr_nrcrcard crawcrd.nrcrcard%TYPE;

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;

      -- Variaveis de critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_exc_saida   EXCEPTION;

    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'MINCAP'
                                ,pr_action => null);

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      -- Busca a data do sistema
      OPEN btch0001.cr_crapdat(vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Cartao magnetico
      IF pr_idtipcar = 1 THEN

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        -- Loop sobre o cursor de busca de cartoes magnetico
        FOR rw_crapcrm IN cr_crapcrm(pr_cdcooper => vr_cdcooper) LOOP

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0        , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrcartao', pr_tag_cont => rw_crapcrm.nrcartao, pr_des_erro => vr_dscritic);

          vr_contador := vr_contador + 1;

        END LOOP;

      END IF;

      -- Cartao cecred
      IF pr_idtipcar = 2 THEN
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        -- Loop sobre o cursor de busca de cartoes cecred
        FOR rw_crawcrd IN cr_crawcrd(pr_cdcooper => vr_cdcooper) LOOP

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0        , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrcartao', pr_tag_cont => rw_crawcrd.nrcrcard, pr_des_erro => vr_dscritic);

          vr_contador := vr_contador + 1;

        END LOOP;

      END IF;

      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      pr_des_erro := 'OK';

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := pr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        cecred.pc_internal_exception(3);
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (CADA0004.pc_retorna_cartao_valido).';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;

    END;

  END pc_retorna_cartao_valido;

  PROCEDURE pc_busca_credito_config_categ(pr_cdcooper    IN TBCRD_CONFIG_CATEGORIA.CDCOOPER%TYPE
                                         ,pr_cdadmcrd    IN TBCRD_CONFIG_CATEGORIA.CDADMCRD%TYPE
                                         ,pr_tplimcrd    IN tbcrd_config_categoria.tplimcrd%TYPE DEFAULT 0
                                         ,pr_vllimite_minimo  OUT TBCRD_CONFIG_CATEGORIA.VLLIMITE_MINIMO%TYPE
                                         ,pr_vllimite_maximo  OUT TBCRD_CONFIG_CATEGORIA.VLLIMITE_MAXIMO%TYPE
                                         ,pr_diasdebito       OUT TBCRD_CONFIG_CATEGORIA.DSDIAS_DEBITO%TYPE
                                         ,pr_possui_registro  OUT NUMBER) IS

    CURSOR cur_config_categ IS
      SELECT tbcc.vllimite_minimo
            ,tbcc.vllimite_maximo
            ,tbcc.dsdias_debito
      FROM   TBCRD_CONFIG_CATEGORIA tbcc
      WHERE  tbcc.cdcooper = pr_cdcooper
         AND tbcc.cdadmcrd = pr_cdadmcrd
         AND tbcc.tplimcrd = pr_tplimcrd;

    vr_possui_registro    NUMBER:=0;

  BEGIN
    --
    pr_possui_registro := vr_possui_registro;
    --
    FOR r001 IN cur_config_categ LOOP
        pr_vllimite_minimo := r001.vllimite_minimo;
        pr_vllimite_maximo := r001.vllimite_maximo;
        pr_diasdebito      := r001.dsdias_debito;
        pr_possui_registro := 1;
    END LOOP;
    --
  END pc_busca_credito_config_categ;

PROCEDURE pc_obter_cartao_URA(pr_cdcooper IN crapcrm.cdcooper%TYPE  --> Código da cooperativa
                               ,pr_nrdconta IN crapcrm.nrdconta%TYPE  --> Código da opção
                               ,pr_nrcartao IN VARCHAR2 --crapcrm.nrcartao%TYPE  --> Número do cartão
                               ,pr_cdagenci OUT crapass.cdagenci%TYPE --> Agencia cooperado
                               ,pr_dtnascto OUT crapass.dtnasctl%TYPE --> Data nascimento cooperado
                               ,pr_idtipcar OUT NUMBER               --> Indica qual o cartao
                               ,pr_inpessoa OUT crapass.inpessoa%TYPE --> Indica o tipo de pessoa
                               ,pr_idsenlet OUT NUMBER -- Indica se existe senha de letras 1 = SIM 0 = NAO
                               ,pr_tpusucar OUT NUMBER  --> Usuário do cartão (Conta de pessoa física devolve o número do titular, conta pessoa jurídica devolve sempre "1" e cartão de operador devolve sempre "9")
                               ,pr_nrcpfcgc OUT crapass.nrcpfcgc%TYPE -->  Em caso de pessoa física é o CPF do titular que está utilizando o cartão, em caso se pessoa jurídica é o CNPJ
                               ,pr_nometitu OUT crapcrm.nmtitcrd%TYPE -->  Nome impresso no cartão
                               ,pr_dtexpira OUT crapcrm.dtvalcar%TYPE --> Data expiração cartão
                               ,pr_dtcancel OUT crapcrm.dtcancel%TYPE
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                               ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica) IS --> Data cancelamento cartão
      -- ..........................................................................
      --
      --  Programa : pc_obter_cartao_URA
      --  Sistema  : Rotinas para buscar cartao magnetico e cecred
      --  Sigla    : CRED
      --  Autor    : Rafael Muniz Monteiro - Mouts
      --  Data     : Julho/2018.                   Ultima atualizacao: --/--/----
      --
      --  Dados referentes ao programa:
      --
      --  Frequencia: Sempre que for chamado
      --  Objetivo  : Autenticar o cartão do cooperado via URA
      --
      --  Alteracoes:
      -- .............................................................................
    BEGIN
      DECLARE

        -- Cursor sobre a tabela de datas
        rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
        -- Busca cooperativa
        CURSOR cr_crapcop(pr_cdcooperc IN crapcop.cdcooper%TYPE)IS
          SELECT 1
            FROM crapcop cop
           WHERE cop.cdcooper = pr_cdcooperc;
        rw_crapcop cr_crapcop%ROWTYPE;
        -- Buscar cartão magnetico
        CURSOR cr_crapcrm(prc_cdcooper IN crapcop.cdcooper%TYPE
                         ,prc_nrdconta IN crapcrm.nrdconta%TYPE
                         ,prc_nrcartao IN VARCHAR2 --crapcrm.nrcartao%TYPE
                         ,prc_dtmvtolt IN crapdat.dtmvtolt%TYPE)IS
          SELECT crm.nrcartao,
                 crm.nmtitcrd,
                 crm.tpusucar,
                 crm.tptitcar,
                 crm.dtvalcar,
                 crm.dtcancel
            FROM crapcrm crm
           WHERE crm.cdcooper = prc_cdcooper
             AND crm.nrdconta = prc_nrdconta
             AND to_char(crm.nrcartao) LIKE prc_nrcartao
             AND crm.cdsitcar = 2
             AND crm.dtvalcar > prc_dtmvtolt
             AND crm.dtentcrm IS NOT NULL;
        rw_crapcrm cr_crapcrm%ROWTYPE;
        --
        CURSOR cr_crapass (prc_cdcooper crapass.cdcooper%TYPE,
                           prc_nrdconta crapass.nrdconta%TYPE)IS
          SELECT ass.nrdconta,
                 ass.inpessoa,
                 ass.nrcpfcgc
            FROM crapass ass
          WHERE ass.cdcooper = prc_cdcooper
            AND ass.nrdconta = prc_nrdconta;
        --
        CURSOR cr_crapttl (prc_cdcooper crapttl.cdcooper%TYPE,
                           prc_nrdconta crapttl.nrdconta%TYPE,
                           prc_idseqttl crapttl.idseqttl%TYPE)IS
         SELECT ttl.dtnasttl,
                ttl.nrcpfcgc
           FROM crapttl ttl
          WHERE ttl.cdcooper = prc_cdcooper
            AND ttl.nrdconta = prc_nrdconta
            AND ttl.idseqttl = prc_idseqttl;
        --
        CURSOR cr_crapttl1 (prc_cdcooper crapttl.cdcooper%TYPE,
                           prc_nrdconta crapttl.nrdconta%TYPE,
                           prc_nrcpfcgc crapttl.nrcpfcgc%TYPE)IS
         SELECT ttl.dtnasttl,
                ttl.idseqttl
           FROM crapttl ttl
          WHERE ttl.cdcooper = prc_cdcooper
            AND ttl.nrdconta = prc_nrdconta
            AND ttl.nrcpfcgc = prc_nrcpfcgc;
        --
        CURSOR cr_crawcrd(prc_cdcooper IN craptip.cdcooper%TYPE,
                          prc_nrdconta IN crapcrd.nrdconta%TYPE,
                          prc_nrcartao IN VARCHAR2/*crapcrd.nrcrcard%TYPE*/) IS
          SELECT p.nrcrcard,
                 p.nmtitcrd,
                 p.nrcpftit,
                 p.dtvalida,
                 p.dtcancel,
                 p.cdadmcrd
            FROM crapcrd p
                ,crawcrd w
           WHERE p.cdcooper = prc_cdcooper
             AND p.nrdconta = prc_nrdconta
             --AND p.nrcrcard = prc_nrcartao
             AND to_char(REPLACE(p.nrcrcard,',''')) LIKE prc_nrcartao
             AND p.cdadmcrd >= 10
             AND p.cdadmcrd <= 80
             AND w.cdcooper = p.cdcooper
             AND w.nrdconta = p.nrdconta
             AND w.nrctrcrd = p.nrctrcrd
             AND w.insitcrd IN(4,6);
        --
        -- administradora do cartao para verificar o tipo de conta
        CURSOR cr_crapadc (prc_cdcooper IN crapadc.cdcooper%TYPE,
                          prc_cdadmcrd IN crapadc.cdadmcrd%TYPE) IS
          SELECT tpctahab
            FROM crapadc
           WHERE crapadc.cdcooper = prc_cdcooper
             AND crapadc.cdadmcrd = prc_cdadmcrd;

        -- Variaveis locais
        vr_nrcpfcgc crapttl.nrcpfcgc%TYPE;
        vr_existe   NUMBER(1) := 0;
        vr_idseqttl crapttl.idseqttl%TYPE;

        -- Variaveis gerais
        vr_contador PLS_INTEGER := 0;

        -- Variaveis de critica
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic crapcri.dscritic%TYPE;
        vr_exc_saida   EXCEPTION;

      BEGIN
      vr_existe := 0;


        -- Validar a cooperativa
        OPEN cr_crapcop(pr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          pr_dscritic := 'Cooperativa nao existe';
          RAISE vr_exc_saida;
        END IF;
        -- Fecha cursor
        CLOSE cr_crapcop;

        pr_cdagenci := 0;
        vr_idseqttl := 0;
        pr_dtnascto := NULL;
        pr_idtipcar := 0;
        pr_inpessoa := 0;
        pr_idsenlet := 0;
        pr_tpusucar := 0;
        pr_nrcpfcgc := 0;
        pr_nometitu := '';
        pr_dtexpira := NULL;
        pr_dtcancel := NULL;
        pr_dscritic := '';
        -- Busca a data do sistema
        OPEN btch0001.cr_crapdat(pr_cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;

        -- Loop sobre o cursor de busca de cartoes magnetico
        FOR rw_crapcrm IN cr_crapcrm(prc_cdcooper => pr_cdcooper,
                                     prc_nrdconta => pr_nrdconta,
                                     prc_nrcartao => pr_nrcartao,
                                     prc_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
          --pr_idseqttl := rw_crapcrm.tpusucar;
          FOR rw_crapttl IN cr_crapttl(pr_cdcooper
                                      ,pr_nrdconta
                                      ,rw_crapcrm.tpusucar)LOOP

            pr_dtnascto := rw_crapttl.dtnasttl;
            vr_nrcpfcgc := rw_crapttl.nrcpfcgc;
          END LOOP;
          pr_idtipcar := 1; -- cartao magnetico
          pr_tpusucar := rw_crapcrm.tpusucar;

          -- Tipo da conta
          FOR rw_crapass IN cr_crapass(pr_cdcooper
                                      ,pr_nrdconta)LOOP

            pr_inpessoa := rw_crapass.inpessoa;

            IF rw_crapass.inpessoa = 1 THEN
              pr_nrcpfcgc := vr_nrcpfcgc;
            ELSE -- se nao o cnpj da conta
              pr_nrcpfcgc := rw_crapass.nrcpfcgc;
            END IF;
          END LOOP;

          -- Verificar se existe senha de letras seguranca
          pr_idsenlet := fn_verif_letras_seguranca(pr_cdcooper => pr_cdcooper,
                                                   pr_nrdconta => pr_nrdconta,
                                                   pr_idseqttl => pr_tpusucar);
          pr_nometitu := rw_crapcrm.nmtitcrd;


          pr_dtexpira := rw_crapcrm.dtvalcar;
          pr_dtcancel := rw_crapcrm.dtcancel;
          vr_existe := 1;
        END LOOP;
        --
        -- Loop sobre o cursor de busca de cartoes cecred
        IF vr_existe = 0 THEN
          FOR rw_crawcrd IN cr_crawcrd(prc_cdcooper => pr_cdcooper,
                                       prc_nrdconta => pr_nrdconta,
                                       prc_nrcartao => pr_nrcartao) LOOP

            vr_nrcpfcgc := rw_crawcrd.nrcpftit;
            FOR rw_crapttl1 IN cr_crapttl1(pr_cdcooper,
                                           pr_nrdconta,
                                           rw_crawcrd.nrcpftit)LOOP
              --pr_idseqttl := rw_crapttl1.idseqttl;
              vr_idseqttl := rw_crapttl1.idseqttl;
              pr_dtnascto := rw_crapttl1.dtnasttl;

            END LOOP;

            pr_idtipcar := 2; -- Cartao Credito

            -- Tipo da conta
            FOR rw_crapass IN cr_crapass(pr_cdcooper
                                        ,pr_nrdconta)LOOP

              pr_inpessoa := rw_crapass.inpessoa;

              IF rw_crapass.inpessoa = 1 THEN
                pr_nrcpfcgc := vr_nrcpfcgc;
              ELSE -- se nao o cnpj da conta
                pr_nrcpfcgc := rw_crapass.nrcpfcgc;
              END IF;
            END LOOP;
            /* Obtem administradora do cartao para verificar o tipo de conta */
            FOR rw_crapadc IN cr_crapadc(pr_cdcooper,
                                         rw_crawcrd.cdadmcrd)LOOP
              IF rw_crapadc.tpctahab = 1 THEN
                -- Conta Fisica
                pr_tpusucar := vr_idseqttl;
              ELSE
                -- Conta Juridica
                pr_tpusucar := 1;
              END IF;
            END LOOP;
            -- Verificar se existe senha de letras seguranca
            pr_idsenlet := fn_verif_letras_seguranca(pr_cdcooper => pr_cdcooper,
                                                     pr_nrdconta => pr_nrdconta,
                                                     pr_idseqttl => pr_tpusucar);
            pr_nometitu := rw_crawcrd.nmtitcrd;  -- Nome do titular cartao
            pr_dtexpira := rw_crawcrd.dtvalida;  -- Data de expiracao cartao
            pr_dtcancel := rw_crawcrd.dtcancel;  -- Data de cancelamento
            vr_existe := 1;

          END LOOP;
        END IF;

        IF vr_existe = 0 THEN
          -- 276 - Cartao nao existe.
          pr_cdcritic := 276;
          pr_dscritic := '276 - Cartao nao existe';
        END IF;

      EXCEPTION
        WHEN vr_exc_saida THEN
          NULL;
        WHEN OTHERS THEN
          --cecred.pc_internal_exception(3);
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral (CADA0004.pc_obter_cartao_URA). '||SQLERRM;

      END;

    END pc_obter_cartao_URA;


  PROCEDURE pc_bloquear_cartao_magnetico( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                         ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                         ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                         ,pr_nmdatela IN VARCHAR2  --> Nome da tela
                                         ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> sequencial do titular
                                         ,pr_dtmvtolt IN DATE                   --> Data do movimento
                                         ,pr_nrcartao IN VARCHAR2               --crapcrm.nrcartao%TYPE  --> Numero do cartão
                                         ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao

                                        ------ OUT ------
                                         ,pr_cdcritic  OUT PLS_INTEGER
                                         ,pr_dscritic  OUT VARCHAR2
                                         ,pr_des_reto  OUT VARCHAR2 ) IS           --> OK ou NOK


  /* ..........................................................................
    --
    --  Programa : pc_bloquear_cartao_magnetico        Antiga: b1wgen0032.p/bloquear-cartao-magnetico
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Rangel Decker (Amcom)
    --  Data     : Maio/2018.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para bloquear cartão magnetico do associado
    --
    --  Alteração :
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --> buscar cartoes magneticos
    CURSOR cr_crapcrm ( pr_cdcooper  crapcrm.cdcooper%TYPE,
                        pr_nrdconta  crapcrm.nrdconta%TYPE,
                        pr_nrcartao  crapcrm.nrcartao%TYPE) IS
      SELECT crapcrm.cdsitcar
            ,crapcrm.dtvalcar
            ,crapcrm.dtcancel
            ,crapcrm.nmtitcrd
            ,crapcrm.nrcartao
            ,crapcrm.tpusucar
            ,crapcrm.dtemscar
        FROM crapcrm
       WHERE crapcrm.cdcooper = pr_cdcooper
         AND crapcrm.nrdconta = pr_nrdconta
         AND crapcrm.nrcartao = pr_nrcartao;

    -- buscar operador
    CURSOR cr_crapope IS
      SELECT cddepart
        FROM crapope
       WHERE crapope.cdcooper = pr_cdcooper
         AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;

    --------------> VARIAVEIS <-----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(200);
    vr_tpcarcta INTEGER;
    vr_dssitcar VARCHAR2(200);
    vr_idx      INTEGER;
    vr_nrdrowid  ROWID;
    vr_rowid_log ROWID;
    vr_tab_erro gene0001.typ_tab_erro;



  BEGIN
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Bloquear cartao magnetico';


    --> buscar cartoes magneticos
    FOR rw_crapcrm IN cr_crapcrm ( pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrcartao => pr_nrcartao) LOOP

      -- se não estiver ativo e valido
      IF rw_crapcrm.cdsitcar <> 2  THEN
         vr_cdcritic:=538;
         vr_dscritic:=NULL;
         RAISE vr_exc_erro;
      END IF;

      BEGIN
        UPDATE crapcrm
        SET    crapcrm.cdsitcar = 4,
               crapcrm.dtcancel = pr_dtmvtolt,
               crapcrm.dttransa = pr_dtmvtolt,
               crapcrm.hrtransa = gene0002.fn_busca_time,
               crapcrm.cdoperad = pr_cdoperad
        WHERE  crapcrm.cdcooper  = pr_cdcooper
        AND    crapcrm.nrdconta  = pr_nrdconta
        AND    crapcrm.nrcartao  = pr_nrcartao;

      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel bloquear o cartao magnetico.' ||SQLERRM;
          RAISE vr_exc_erro;

      END;

    END LOOP; --> Fim Loop crpcrm

    -- Se foi solicitado log
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => vr_dsorigem --> Origem enviada
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => pr_dtmvtolt
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;
    COMMIT;
    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Gerar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      END IF;
      pr_des_reto := 'NOK';

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro pc_obtem_cartoes_magneticos:'||SQLERRM;
      -- Gerar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

        /** Numero do Cartao Magnetico **/
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                 ,pr_nmdcampo => 'nrcartao'
                                 ,pr_dsdadant => ' '
                                 ,pr_dsdadatu => gene0002.fn_mask(pr_nrcartao,'9999,9999,9999,9999'));

        /** Situacao do cartao **/
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                                  ,pr_nmdcampo => 'cdsitcar'
                                  ,pr_dsdadant => '2'
                                  ,pr_dsdadatu => '4');

      END IF;
      pr_des_reto := 'NOK';

  END pc_bloquear_cartao_magnetico;

  /*****************************************************************************/
  /**         Procedure para Salvar data da assinatura TA Online              **/
  /*****************************************************************************/
  PROCEDURE pc_salva_dtassele(pr_cdcooper  IN crapcrd.cdcooper%TYPE
                             ,pr_nrdconta  IN crapcrd.nrdconta%TYPE
                             ,pr_nrcrcard  IN VARCHAR2
                             ,pr_dscritic OUT VARCHAR2) IS
    /* ..........................................................................
    --
    --  Programa : pc_salva_dtassele
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Anderson Alan (Supero)
    --  Data     : Dezembro/2018.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para gravar data e hora no campo, visto que pelo
    --               progress estava gravando apenas a data.
    --
    --  Alteração :
    -- ..........................................................................*/

  BEGIN

    UPDATE crapcrd
       SET crapcrd.dtassele = SYSDATE
     WHERE crapcrd.cdcooper = pr_cdcooper
       AND crapcrd.nrdconta = pr_nrdconta
       AND crapcrd.nrcrcard = TO_NUMBER(pr_nrcrcard);

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina pc_salva_dtassele: '||SQLERRM;
  END pc_salva_dtassele;


  PROCEDURE pc_retorna_dados_entrg_crt_web(pr_cdcooper IN crapcrm.cdcooper%TYPE  --> Código da cooperativa
                                           ,pr_nrdconta IN crapcrm.nrdconta%TYPE  --> Código CONTA
                                           ,pr_nrctrcrd IN VARCHAR2 --crapcrm.nrcartao%TYPE  --> Número do cartão
                                           ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

  /* .............................................................................

      Programa: pc_retorna_dados_entrg_crt_web
      Sistema : CECRED
      Sigla   : CRD
      Autor   : Augusto (Supero)
      Data    : Fevereiro/2019                 Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Retorna informações da entrega do cartão

      Observacao: -----

      Alteracoes:
  ..............................................................................*/

  -- Tratamento de erros
  vr_cdcritic NUMBER := 0;
  vr_dscritic VARCHAR2(4000);
  vr_incrdent NUMBER := 0;
  vr_nmresage crapage.nmresage%TYPE;

  -- Variaveis locais
  vr_nrctrcrd_tit crawcrd.nrctrcrd%TYPE;
  vr_flgAdicional NUMBER := 0;
  vr_idtipoenvio tbcrd_endereco_entrega.idtipoenvio%TYPE;

  CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT decode(s.inpessoa, 1, 10, 9) idtipoenvio
      FROM crapass s
     WHERE s.cdcooper = pr_cdcooper
       AND s.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  CURSOR cr_busca_dados_entrega(pr_cdcooper tbcrd_endereco_entrega.cdcooper%TYPE
                               ,pr_nrdconta tbcrd_endereco_entrega.nrdconta%TYPE
                               ,pr_nrctrcrd tbcrd_endereco_entrega.nrctrcrd%TYPE) IS
    SELECT tbdom.dscodigo
          ,tbend.cdagenci
          ,tbend.nmlogradouro || ', ' || tbend.nrlogradouro ||
           nvl2(TRIM(tbend.dscomplemento), ', ' || tbend.dscomplemento || ' ', '') AS dsendere
          ,tbend.nmbairro
          ,tbend.nmcidade
          ,tbend.cdufende
          ,gene0002.fn_mask_cep(tbend.nrcep) AS nrcepend
          ,tbend.idtipoenvio
      FROM tbcrd_endereco_entrega tbend
          ,tbcrd_dominio_campo    tbdom
     WHERE tbend.idtipoenvio = tbdom.cddominio
       AND tbdom.nmdominio = 'TPENDERECOENTREGA'
       AND tbend.cdcooper = pr_cdcooper
       AND tbend.nrdconta = pr_nrdconta
       AND tbend.nrctrcrd = pr_nrctrcrd;
  rw_busca_dados_entrega  cr_busca_dados_entrega%ROWTYPE;

  CURSOR cr_crapage (pr_cdagenci crapage.cdagenci%TYPE) IS
    SELECT age.nmresage
      FROM crapage age
     WHERE age.cdcooper = pr_cdcooper
       AND age.cdagenci = pr_cdagenci;
  rw_crapage cr_crapage%ROWTYPE;

  CURSOR cr_cdadmcrd(pr_cdcooper crawcrd.cdcooper%TYPE
                    ,pr_nrctrcrd crawcrd.nrctrcrd%TYPE
                    ,pr_nrdconta crawcrd.nrdconta%TYPE) IS
    SELECT d.cdadmcrd
      FROM crawcrd d
     WHERE d.cdcooper = pr_cdcooper
       AND d.nrctrcrd = pr_nrctrcrd
       AND d.nrdconta = pr_nrdconta;
  rw_cdadmcrd cr_cdadmcrd%ROWTYPE;

  CURSOR cr_cartoes(pr_cdcooper crawcrd.cdcooper%TYPE
                   ,pr_cdadmcrd crawcrd.cdadmcrd%TYPE
                   ,pr_nrctrcrd crawcrd.nrctrcrd%TYPE
                   ,pr_nrdconta crawcrd.nrdconta%TYPE) IS
     SELECT d.nrctrcrd
       FROM crawcrd d
      WHERE d.cdcooper = pr_cdcooper
        AND d.cdadmcrd = pr_cdadmcrd
        AND d.nrctrcrd <> pr_nrctrcrd
        AND d.insitcrd NOT IN (5,6) -- bloqueado,cancelado
        AND d.nrdconta = pr_nrdconta;
  rw_cartoes cr_cartoes%ROWTYPE;

  BEGIN

    -- A principio dizemos que o proprio cartao é titular
    vr_nrctrcrd_tit := pr_nrctrcrd;

    -- Retornarmos a administradora do cartao
    OPEN cr_cdadmcrd(pr_cdcooper => pr_cdcooper
                  ,pr_nrctrcrd => pr_nrctrcrd
                  ,pr_nrdconta => pr_nrdconta);
    FETCH cr_cdadmcrd INTO rw_cdadmcrd;
    --
    IF cr_cdadmcrd%NOTFOUND THEN
      CLOSE cr_cdadmcrd;
      vr_dscritic := 'Proposta nao localizada.';
    END IF;
    CLOSE cr_cdadmcrd;

    -- Retornamos os cartoes da conta cartao que nao seja o cartao atual
    OPEN cr_cartoes(pr_cdcooper => pr_cdcooper
                   ,pr_cdadmcrd => nvl(rw_cdadmcrd.cdadmcrd, 0)
                   ,pr_nrctrcrd => pr_nrctrcrd
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_cartoes INTO rw_cartoes;
    -- Se encontrar significa que o cartao atual nao é titular
    IF cr_cartoes%FOUND THEN
       vr_nrctrcrd_tit := rw_cartoes.nrctrcrd;
       vr_flgAdicional := 1;
    END IF;
    --
    CLOSE cr_cartoes;

    --
    OPEN cr_busca_dados_entrega(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctrcrd => vr_nrctrcrd_tit);
    FETCH cr_busca_dados_entrega INTO rw_busca_dados_entrega;
    --
    IF cr_busca_dados_entrega%FOUND THEN
      vr_incrdent := 1;
      vr_idtipoenvio := rw_busca_dados_entrega.idtipoenvio;
      --
      IF NVL(rw_busca_dados_entrega.cdagenci, 0) > 0 THEN
         --
         OPEN cr_crapage(rw_busca_dados_entrega.cdagenci);
         FETCH cr_crapage INTO rw_crapage;
         CLOSE cr_crapage;
         --
         vr_nmresage := nvl(rw_crapage.nmresage, '');
         --
      END IF;
      --
    ELSE
      IF vr_flgAdicional = 1 THEN
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;
        vr_idtipoenvio := rw_crapass.idtipoenvio;
    END IF;
    END IF;
    --
    CLOSE cr_busca_dados_entrega;

    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root><Dados> ' ||
                                   '<incrdent>' || vr_incrdent || '</incrdent>' ||
                                   '<dstipend>' || nvl(rw_busca_dados_entrega.dscodigo, '') || '</dstipend>' ||
                                   '<dsendere>' || nvl(rw_busca_dados_entrega.dsendere, '') || '</dsendere>' ||
                                   '<dsbairro>' || nvl(rw_busca_dados_entrega.nmbairro, '') || '</dsbairro>' ||
                                   '<dscidade>' || nvl(rw_busca_dados_entrega.nmcidade, '') || '</dscidade>' ||
                                   '<nrcepend>' || nvl(rw_busca_dados_entrega.nrcepend, '') || '</nrcepend>' ||
                                   '<dsufende>' || nvl(rw_busca_dados_entrega.cdufende, '') || '</dsufende>' ||
                                   '<nmresage>' || nvl(vr_nmresage, '') || '</nmresage>' ||
                                   '<idtipoenvio>' || nvl(vr_idtipoenvio, 0) || '</idtipoenvio>' ||
                                   '<cdagenci>' || nvl(rw_busca_dados_entrega.cdagenci, 0) || '</cdagenci>' ||
                                   '<flgadicional>' || vr_flgAdicional || '</flgadicional>' ||
                                   '</Dados></Root>');
  EXCEPTION
      WHEN OTHERS THEN

          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral na rotina na procedure CADA0004.pc_retorna_dados_entrg_crt_web. Erro: ' || SQLERRM;
          pr_des_erro := 'NOK';
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                         pr_dscritic || '</Erro></Root>');

  END pc_retorna_dados_entrg_crt_web;
END CADA0004;
/
