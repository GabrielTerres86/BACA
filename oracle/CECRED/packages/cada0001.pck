CREATE OR REPLACE PACKAGE CECRED.CADA0001 is
  /*---------------------------------------------------------------------------------------------------------------

    Programa : CADA0001
    Sistema  : Rotinas para cadastros Web
    Sigla    : CADA
    Autor    : Petter R. Villa Real  - Supero
    Data     : Maio/2013.                   Ultima atualizacao: 22/06/2017
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Rotinas para manutenção (cadastro) dos dados para sistema Web/genérico
  
               10/11/2015 - Incluido o campo tt-crapavt.idrspleg, e incluido verificacao
                            na procedure pc_busca_dados_58 para verificar se o representante
                            é responsável legal pelo acesso aos canais de autoatendimento e SAC (Jean Michel).	             
  
               16/06/2016 - Correcao para o uso correto do indice da CRAPTAB em varias
                            procedures desta package. (Carlos Rafael Tanholi).   
  
               22/06/2017 - Ajustes para retirar as rotinas de consulta/inclusão de naciondalidade, pois
                            foi criado a tela CADNAC para genrenciar as nacionalidades
                            (Adriano - P339).
                                             
  ---------------------------------------------------------------------------------------------------------------*/

  --Tipo de Registro para os lançamentos
  TYPE typ_reg_lancamentos IS
    RECORD (cdtplanc   number,
            cdcooper   craplcm.cdcooper%type,
            cdcoptfn   craplcm.cdcoptfn%type,
            cdagetfn   craplcm.cdagetfn%type,
            nrdconta   craplcm.nrdconta%type,
            dstplanc   varchar2(30),
            tpconsul   varchar2(30),
            qtdecoop   NUMBER,
            qtdmovto   NUMBER,
            vlrtotal   NUMBER,
            vlrtarif   NUMBER);

  --Tipo de Registro Para Contatos - Pessoa Juridica
  TYPE typ_reg_contato_juridica IS
    RECORD (nrdctato crapavt.nrdctato%type
           ,nmdavali crapavt.nmdavali%type
           ,nrtelefo crapavt.nrtelefo%type
           ,dsdemail crapavt.dsdemail%type
           ,cddctato VARCHAR2(1000)
           ,nrdrowid ROWID);

  --Tipo de Registro para Empresas Participantes (b1wgen0080tt.i)
  TYPE typ_reg_crapepa IS
    RECORD (cdcooper crapepa.cdcooper%type
           ,nrdconta crapepa.nrdconta%type
           ,nrdocsoc crapepa.nrdocsoc%type
           ,nrctasoc crapepa.nrctasoc%type
           ,nmfansia crapepa.nmfansia%type
           ,nrinsest crapepa.nrinsest%type
           ,natjurid crapepa.natjurid%type
           ,dtiniatv crapepa.dtiniatv%type
           ,qtfilial crapepa.qtfilial%type
           ,qtfuncio crapepa.qtfuncio%type
           ,dsendweb crapepa.dsendweb%type
           ,cdseteco crapepa.cdseteco%type
           ,cdmodali crapepa.cdmodali%type
           ,cdrmativ crapepa.cdrmativ%type
           ,vledvmto crapepa.vledvmto%type
           ,dtadmiss crapepa.dtadmiss%type
           ,dtmvtolt crapepa.dtmvtolt%type
           ,persocio crapepa.persocio%type
           ,nmprimtl crapepa.nmprimtl%type
           ,cddconta VARCHAR2(1000)
           ,dsvalida VARCHAR2(1000)
           ,cdcpfcgc VARCHAR2(100)
           ,dsestcvl VARCHAR2(1000)
           ,nrdrowid ROWID
           ,nmseteco craptab.dstextab%type
           ,dsnatjur gncdntj.dsnatjur%type
           ,dsrmativ gnrativ.nmrmativ%type);
  --Tipo de Registro para Informacoes dos Avalistas (b1wgen0073tt.i)
  TYPE typ_reg_crapavt IS
    RECORD (nrdctato crapavt.nrdctato%type
           ,nmdavali crapavt.nmdavali%type
           ,nrtelefo crapavt.nrtelefo%type
           ,dsdemail crapavt.dsdemail%type
           ,dsdemiss BOOLEAN
           ,cdagenci crapavt.cdagenci%type
           ,nrcepend crapavt.nrcepend%type
           ,dsendere crapavt.dsendres##1%type
           ,nrendere crapavt.nrendere%type
           ,complend crapavt.complend%type
           ,nmbairro crapavt.nmbairro%type
           ,nmcidade crapavt.nmcidade%type
           ,cdufende VARCHAR2(2)
           ,nrcxapst crapavt.nrcxapst%type
           ,cddctato VARCHAR2(1000)
           ,nrdrowid ROWID);

  --Tipo de registro char
  TYPE typ_tab_char IS TABLE OF VARCHAR2(200) INDEX BY PLS_INTEGER;
  --Tipo de registro number
  TYPE typ_tab_number IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

  --Tipo de Registro para Avalistas (b1wgen0058tt.i)
  TYPE typ_reg_crapavt_58 IS
    RECORD (cdcooper crapavt.cdcooper%type
           ,cddconta VARCHAR2(100)
           ,dsvalida VARCHAR2(100)
           ,cdcpfcgc VARCHAR2(100)
           ,nrdrowid ROWID
           ,dsdrendi typ_tab_char
           ,nrdeanos INTEGER
           ,deletado BOOLEAN
           ,cddopcao VARCHAR2(100)
           ,dhinclus DATE
           ,cddctato VARCHAR2(100)
           ,dstipcta VARCHAR2(100)
           ,rowidavt ROWID
           ,dtmvtolt crapavt.dtmvtolt%type
           ,nmdavali crapavt.nmdavali%type
           ,tpdocava crapavt.tpdocava%type
           ,nrdocava crapavt.nrdocava%type
           ,cdoeddoc tbgen_orgao_expedidor.cdorgao_expedidor%TYPE
           ,cdufddoc crapavt.cdufddoc%type
           ,dtemddoc crapavt.dtemddoc%type
           ,dsproftl crapavt.dsproftl%type
           ,dtnascto crapavt.dtnascto%type
           ,cdsexcto crapavt.cdsexcto%type
           ,cdestcvl crapavt.cdestcvl%type
           ,dsestcvl VARCHAR2(100)
           ,cdnacion crapnac.cdnacion%type
           ,dsnacion crapnac.dsnacion%type
           ,dsnatura crapavt.dsnatura%type
           ,nmmaecto crapttl.nmmaettl%type
           ,nmpaicto crapttl.nmpaittl%type
           ,nrcepend crapavt.nrcepend%type
           ,dsendres typ_tab_char
           ,nrendere crapavt.nrendere%type
           ,complend crapavt.complend%type
           ,nmbairro crapavt.nmbairro%type
           ,nmcidade crapavt.nmcidade%type
           ,cdufresd crapavt.cdufresd%type
           ,nrcxapst crapavt.nrcxapst%type
           ,dtvalida crapavt.dtvalida%type
           ,dtadmsoc crapavt.dtadmsoc%type
           ,flgdepec crapavt.flgdepec%type
           ,persocio crapavt.persocio%type
           ,vledvmto crapavt.vledvmto%type
           ,inhabmen crapavt.inhabmen%type
           ,dthabmen crapavt.dthabmen%type
           ,dshabmen VARCHAR2(100)
           ,nrctremp crapavt.nrctremp%type
           ,nrdctato crapavt.nrdctato%type
           ,nrdconta crapavt.nrdconta%type
           ,nrcpfcgc crapavt.nrcpfcgc%type
           ,vloutren crapavt.vloutren%type
           ,dsoutren crapavt.dsoutren%type
           ,dsrelbem typ_tab_char
           ,persemon typ_tab_number
           ,qtprebem typ_tab_number
           ,vlprebem typ_tab_number
           ,vlrdobem typ_tab_number
           ,tpctrato crapavt.tpctrato%TYPE
           ,idrspleg INTEGER);

  --Tipo de Registro para Representantes Legais (b1wgen0072tt.i)
  TYPE typ_reg_crapcrl IS
    RECORD (cdcooper crapcrl.cdcooper%type
           ,nrctamen crapcrl.nrctamen%type
           ,nrcpfmen crapcrl.nrcpfmen%type
           ,idseqmen crapcrl.idseqmen%type
           ,nrdconta crapcrl.nrdconta%type
           ,nrcpfcgc crapcrl.nrcpfcgc%type
           ,nmrespon crapcrl.nmrespon%type
           ,dsorgemi tbgen_orgao_expedidor.cdorgao_expedidor%TYPE
           ,cdufiden crapcrl.cdufiden%type
           ,dtemiden crapcrl.dtemiden%type
           ,dtnascin crapcrl.dtnascin%type
           ,cddosexo crapcrl.cddosexo%type
           ,cdestciv crapcrl.cdestciv%type
           ,cdnacion crapnac.cdnacion%type
           ,dsnacion crapnac.dsnacion%type
           ,dsnatura crapcrl.dsnatura%type
           ,cdcepres crapcrl.cdcepres%type
           ,dsendres crapcrl.dsendres%type
           ,nrendres crapcrl.nrendres%type
           ,dscomres crapcrl.dscomres%type
           ,dsbaires crapcrl.dsbaires%type
           ,nrcxpost crapcrl.nrcxpost%type
           ,dscidres crapcrl.dscidres%type
           ,dsdufres crapcrl.dsdufres%type
           ,nmpairsp crapcrl.nmpairsp%type
           ,nmmaersp crapcrl.nmmaersp%type
           ,tpdeiden crapcrl.tpdeiden%type
           ,nridenti crapcrl.nridenti%type
           ,dtmvtolt crapcrl.dtmvtolt%type
           ,flgimpri crapcrl.flgimpri%type
           ,dsestcvl VARCHAR2(100)
           ,nrdrowid ROWID
           ,deletado BOOLEAN
           ,cddopcao VARCHAR2(1)
           ,cddctato crapass.nrdconta%type
           ,dtdenasc DATE
           ,cdhabmen INTEGER);

  --Tipo de Regisro de Bens
  TYPE typ_reg_bens IS
    RECORD (dsrelbem crapbem.dsrelbem%type
           ,persemon crapbem.persemon%type
           ,qtprebem crapbem.qtprebem%type
           ,vlprebem crapbem.vlprebem%type
           ,vlrdobem crapbem.vlrdobem%type
           ,cdsequen INTEGER
           ,cddopcao VARCHAR2(1)
           ,deletado BOOLEAN
           ,nrdrowid ROWID
           ,cpfdoben VARCHAR2(100));

  --Tipo de Regisro de associados (Edison-AMcom)
  TYPE typ_reg_crapass IS
    RECORD (nrdconta crapass.nrdconta%TYPE
           ,inpessoa crapass.inpessoa%TYPE
           ,nmprimtl crapass.nmprimtl%TYPE
           ,nrdrowid ROWID);

  --Tipo de Regisro de historicos (Edison-AMcom)
  TYPE typ_reg_craphis IS
    RECORD (cdhistor craphis.cdhistor%TYPE
           ,dshistor VARCHAR2(100)
           ,inhistor craphis.inhistor%TYPE
           ,indebcre craphis.indebcre%TYPE
           ,nrdrowid ROWID);

  --Tipo de Regisro de planos de capitalizacao (Edison-AMcom)
  --Obs.: O indice é varchar2 pois possui mais de uma coluna
  TYPE typ_reg_crappla IS
    RECORD ( nrdconta crappla.nrdconta%TYPE
            ,tpdplano crappla.tpdplano%TYPE
            ,cdsitpla crappla.cdsitpla%TYPE
            ,dtinipla crappla.dtinipla%TYPE
            ,dtultpag crappla.dtultpag%TYPE
            ,nrctrpla crappla.nrctrpla%TYPE
            ,qtprepag crappla.qtprepag%TYPE
            ,vlpagmes crappla.vlpagmes%TYPE
            ,vlprepag crappla.vlprepag%TYPE
            ,vlprepla crappla.vlprepla%TYPE
            ,dtcancel crappla.dtcancel%TYPE
            ,qtpremin crappla.qtpremin%TYPE
            ,qtpremax crappla.qtpremax%TYPE
            ,cdempres crappla.cdempres%TYPE
            ,indpagto crappla.indpagto%TYPE
            ,flgpagto crappla.flgpagto%TYPE
            ,dtdpagto crappla.dtdpagto%TYPE
            ,cdcooper crappla.cdcooper%TYPE
            ,cdoperad crappla.cdoperad%TYPE
            ,dsorigem crappla.dsorigem%TYPE
            ,dtmvtolt crappla.dtmvtolt%TYPE
            ,vlpenden crappla.vlpenden%TYPE
            ,nrdrowid ROWID);

  --Tipo de Regisro de lancamentos de cotas de capital (Edison-AMcom)
  --Obs.: O indice é varchar2 pois possui mais de uma coluna
  -------------------------------------------
  TYPE typ_reg_craplct IS
    RECORD ( cdagenci craplct.cdagenci%TYPE
            ,cdbccxlt craplct.cdbccxlt%TYPE
            ,nrdolote craplct.nrdolote%TYPE
            ,nrdconta craplct.nrdconta%TYPE
            ,nrdocmto craplct.nrdocmto%TYPE
            ,dtmvtolt craplct.dtmvtolt%TYPE
            ,cdhistor craplct.cdhistor%TYPE
            ,nrseqdig craplct.nrseqdig%TYPE
            ,vllanmto craplct.vllanmto%TYPE
            ,nrctrpla craplct.nrctrpla%TYPE
            ,qtlanmfx craplct.qtlanmfx%TYPE
            ,nrautdoc craplct.nrautdoc%TYPE
            ,nrsequni craplct.nrsequni%TYPE
            ,cdcooper craplct.cdcooper%TYPE
            ,dtlibera craplct.dtlibera%TYPE
            ,dtcrdcta craplct.dtcrdcta%TYPE
            ,sqnrdcta NUMBER --indica a sequencia do registro dentro da tabela temporaria
            ,qtnrdcta NUMBER --indica a quantidade de registros por conta
            ,nrdrowid ROWID);

  --Tipo de tabela de memoria para lancamentos de cotas de capital (Edison-AMcom)
  TYPE typ_tab_craplct IS TABLE OF typ_reg_craplct INDEX BY VARCHAR2(100);

  --Tipo de Registro de titulares da conta (Edison-AMcom)
  --Obs.: O indice é varchar2 pois possui mais de uma coluna
  -------------------------------------------
  TYPE typ_reg_crapttl IS
    RECORD ( cdcooper crapttl.cdcooper%TYPE
            ,nrdconta crapttl.nrdconta%TYPE
            ,idseqttl crapttl.idseqttl%TYPE
            ,cdempres crapttl.cdempres%TYPE
            ,nrdrowid ROWID);

  --Tipo de Registro de pessoa juridica (Edison-AMcom)
  --Obs.: O indice é varchar2 pois possui mais de uma coluna
  -------------------------------------------
  TYPE typ_reg_crapjur IS
    RECORD ( cdcooper crapjur.cdcooper%TYPE
            ,nrdconta crapjur.nrdconta%TYPE
            ,cdempres crapjur.cdempres%TYPE
            ,nrdrowid ROWID);

  --Tipo de Registro de cotas e recursos do associado (Edison-AMcom)
  --Obs.: O indice é varchar2 pois possui mais de uma coluna
  -------------------------------------------
  TYPE typ_reg_crapcot IS
    RECORD ( cdcooper crapcot.cdcooper%TYPE
            ,nrdconta crapcot.nrdconta%TYPE
            ,vlcotext crapcot.vlcotext%TYPE
            ,qtextmfx crapcot.qtextmfx%TYPE
            ,vlcotant crapcot.vlcotant%TYPE
            ,qtantmfx crapcot.qtantmfx%TYPE
            ,nrdrowid ROWID);

  --Tipo de registro para armazenar lancamentos
  TYPE typ_tab_craplcm IS TABLE OF craplcm%ROWTYPE INDEX BY VARCHAR2(100);

  --Tipo de Regisro de lancamentos de cotas de capital (Edison-AMcom)
  --utilizada para receber os lancamentos agrupados por conta
  -------------------------------------------------------------------
  TYPE typ_reg_grpconta IS
    RECORD (tabcraplct typ_tab_craplct
           ,tabcraplcm typ_tab_craplcm);

  --Tipo de tabela de memoria para armazenar os lançamentos
  TYPE typ_tab_lancamentos IS TABLE OF typ_reg_lancamentos INDEX BY VARCHAR2(38); --(3)cdtplanc + (10)cdcooper + (10)cdcoptfn + (5)cdagetfn +(10)nrdconta
  --Tipo de tabela de memoria para Contatos
  TYPE typ_tab_contato_juridica IS TABLE OF typ_reg_contato_juridica INDEX BY PLS_INTEGER;
  --Tipo de tabela de memoria para empresas participantes
  TYPE typ_tab_crapepa IS TABLE OF typ_reg_crapepa INDEX BY PLS_INTEGER;
  --Tipo de tabela de memoria para informacoes dos avalistas
  TYPE typ_tab_crapavt IS TABLE OF typ_reg_crapavt INDEX BY PLS_INTEGER;
  --Tipo de tabela de memoria para informacoes dos avalistas na b1wgen0058
  TYPE typ_tab_crapavt_58 IS TABLE OF typ_reg_crapavt_58 INDEX BY PLS_INTEGER;
  --Tipo de tabela para bens
  TYPE typ_tab_bens IS TABLE OF typ_reg_bens INDEX BY PLS_INTEGER;
  --Tipo de tabela de memoria para Representante Legal
  TYPE typ_tab_crapcrl IS TABLE OF typ_reg_crapcrl INDEX BY PLS_INTEGER;
  --Tipo de tabela de memoria para associados (Edison-AMcom)
  TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
  --Tipo de tabela de memoria para historicos (Edison-AMcom)
  TYPE typ_tab_craphis IS TABLE OF typ_reg_craphis INDEX BY PLS_INTEGER;
  --Tipo de tabela de memoria para planos de capitalizacao (Edison-AMcom)
  TYPE typ_tab_crappla IS TABLE OF typ_reg_crappla INDEX BY VARCHAR2(100);
  --Tipo de tabela de memoria para titulares da conta (Edison-AMcom)
  TYPE typ_tab_crapttl IS TABLE OF typ_reg_crapttl INDEX BY VARCHAR2(100);
  --Tipo de tabela de memoria para pessoa juridica (Edison-AMcom)
  TYPE typ_tab_crapjur IS TABLE OF typ_reg_crapjur INDEX BY PLS_INTEGER;
  --Tipo de tabela de memoria para cotas e recursos do associado (Edison-AMcom)
  TYPE typ_tab_crapcot IS TABLE OF typ_reg_crapcot INDEX BY PLS_INTEGER;
  --Tipo de tabela de memoria para lancamentos de cotas de capital (Edison-AMcom)
  TYPE typ_tab_grpconta IS TABLE OF typ_reg_grpconta INDEX BY PLS_INTEGER;
  --Tipo de registro para armazenar texto
  TYPE typ_tab_linha IS TABLE OF VARCHAR2(32000) INDEX BY PLS_INTEGER;

  /* Rotina responsavel por calcular a quantidade de anos e meses entre as datas */
  PROCEDURE pc_busca_idade (pr_dtnasctl IN crapdat.dtmvtolt%TYPE  --Data de Nascimento
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --Data da utilizacao atual
                           ,pr_flcomple IN NUMBER DEFAULT 0  --> Controle para validar o método de cálculo de datas
                           ,pr_nrdeanos OUT INTEGER               --Numero de Anos
                           ,pr_nrdmeses OUT INTEGER               --Numero de meses
                           ,pr_dsdidade OUT VARCHAR2              --Descricao da idade
                           ,pr_des_erro OUT VARCHAR2);            --Mensagem de Erro

  /* Rotina responsavel por Buscar o Motivo da demissao */
  PROCEDURE pc_busca_motivo_demissao (pr_cdcooper IN crapcop.cdcooper%TYPE  --Código Cooperativa
                                     ,pr_cdmotdem IN crapass.cdmotdem%TYPE  --Código Motivo Demissao
                                     ,pr_dsmotdem OUT VARCHAR2              --Descrição Motivo Demissao
                                     ,pr_cdcritic OUT INTEGER               --Codigo da Critica
                                     ,pr_des_erro OUT VARCHAR2);            --Mensagem de Erro

  /* Buscar as Contas Centralizadoras do BBrasil */
  PROCEDURE pc_BuscaCtaCe(pr_cdcooper IN NUMBER        --> Código da cooperativa
                         ,pr_tpregist IN NUMBER        --> Tipo do registro
                         ,pr_lscontas OUT VARCHAR2     --> Lista de contas
                         ,pr_dscritic OUT VARCHAR2     --> Descrição da crítica
                         ,pr_des_erro OUT VARCHAR2);   --> Descrição do erro

  /* Calcular digito 10 - BBrasil */
  PROCEDURE pc_digm10(pr_nrcalcul IN OUT NUMBER    --> Número para calculo
                     ,pr_nrdigito OUT PLS_INTEGER  --> Número do dígito
                     ,pr_stsnrcal OUT BOOLEAN      --> Retorno de execução de cálculo
                     ,pr_des_erro OUT VARCHAR2);   --> Retorno de erro

  /* Rotina gera temptable com os movimentos de saques da cooperativa */
  PROCEDURE pc_busca_movto_saque_cooper(pr_cdcooper  IN INTEGER  --> Código da cooperativo
                                       ,pr_cdcoptfn  IN INTEGER  --> Codigo que identifica a Cooperativa do Cash.
                                       ,pr_dtmvtoin  IN DATE     --> Data de movimento inicial
                                       ,pr_dtmvtofi  IN DATE     --> Data de movimento final
                                       ,pr_cdtplanc  IN INTEGER  --> Codigo do tipo de lançamento
                                       ,pr_dscritic OUT VARCHAR2 --> retorno da descrição de critica
                                       ,pr_tab_lancamentos OUT typ_tab_lancamentos);  --> Retorno da temptable com os lançamentos

  /* Buscar a Operacao */
  FUNCTION fn_busca_ocupacao (pr_cddocupa IN  crapttl.cdocpttl%type --> Código da ocupacao
                             ,pr_rsdocupa OUT VARCHAR2     --> Descricao Ocupacao
                             ,pr_cdcritic OUT INTEGER      --Codigo de erro
                             ,pr_dscritic OUT VARCHAR2)    --Retorno de Erro
                             RETURN BOOLEAN;

  /* Buscar a Habilitacao */
  FUNCTION fn_busca_habilitacao(pr_inhabmen IN  INTEGER   --> Código Habilitacao
                               ,pr_dshabmen OUT VARCHAR2  --> Descricao Habilitacao
                               ,pr_cdcritic OUT INTEGER   --Codigo de erro
                               ,pr_dscritic OUT VARCHAR2) --Retorno de Erro
                               RETURN BOOLEAN;

  /* Buscar o Estado Civil */
  FUNCTION fn_busca_estado_civil (pr_cdestcvl IN  INTEGER   --> Código Estado Civil
                                 ,pr_dsestcvl OUT VARCHAR2  --> Descricao Estado Civil
                                 ,pr_cdcritic OUT INTEGER   --Codigo de erro
                                 ,pr_dscritic OUT VARCHAR2) --Retorno de Erro
                                 RETURN BOOLEAN;

  /* Buscar os Contatos do Associado */
  PROCEDURE pc_obtem_contatos (pr_cdcooper IN crapcop.cdcooper%type --Codigo Cooperativa
                              ,pr_cdagenci IN crapass.cdagenci%type --Codigo Agencia
                              ,pr_nrdcaixa IN INTEGER               --Numero Caixa
                              ,pr_cdoperad IN VARCHAR2              --Codigo Operador
                              ,pr_nmdatela IN VARCHAR2              --Nome Tela
                              ,pr_idorigem IN INTEGER               --Origem da chamada
                              ,pr_nrdconta IN crapass.nrdconta%type --Numero da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%type --Sequencial Titular
                              ,pr_flgerlog IN BOOLEAN               --Erro no Log
                              ,pr_tab_contato_juridica OUT typ_tab_contato_juridica --Tabela Contato
                              ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erro
                              ,pr_cdcritic OUT INTEGER               --Codigo de erro
                              ,pr_dscritic OUT VARCHAR2);            --Retorno de Erro

  /* Procedure para verificar se o cooperado é primeiro titular em outra conta */
  PROCEDURE pc_busca_conta (pr_cdcooper IN crapcop.cdcooper%type --Codigo Cooperativa
                           ,pr_nrdconta IN crapass.nrdconta%type --Numero da Conta
                           ,pr_nrcpfcgc IN crapass.nrcpfcgc%type --Cpf/Cnpj da Conta
                           ,pr_idseqttl IN crapttl.idseqttl%type --Sequencial Titular
                           ,pr_nrctattl OUT crapass.nrdconta%type --Numero da Conta Titular
                           ,pr_msgconta OUT VARCHAR2              --Mensagem da Conta
                           ,pr_cdcritic OUT INTEGER               --Codigo de erro
                           ,pr_dscritic OUT VARCHAR2);            --Retorno de Erro

  /* Buscar dados dos avalistas do associado */
  PROCEDURE pc_busca_dados_73 (pr_cdcooper IN crapcop.cdcooper%type --Codigo Cooperativa
                              ,pr_cdagenci IN crapass.cdagenci%type --Codigo Agencia
                              ,pr_nrdcaixa IN INTEGER               --Numero Caixa
                              ,pr_cdoperad IN VARCHAR2              --Codigo Operador
                              ,pr_nmdatela IN VARCHAR2              --Nome Tela
                              ,pr_idorigem IN INTEGER               --Origem da chamada
                              ,pr_nrdconta IN crapass.nrdconta%type --Numero da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%type --Sequencial Titular
                              ,pr_flgerlog IN BOOLEAN               --Erro no Log
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%type --Data Movimento
                              ,pr_cddopcao IN VARCHAR2              --Codigo opcao
                              ,pr_nrdctato IN INTEGER               --Numero Contato
                              ,pr_nrdrowid IN ROWID                 --Rowid Empresa participante
                              ,pr_tab_crapavt OUT typ_tab_crapavt   --Tabela Avalistas
                              ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erro
                              ,pr_cdcritic OUT INTEGER              --Codigo de erro
                              ,pr_dscritic OUT VARCHAR2);           --Retorno de Erro

  /* Buscar dados dos representantes/procuradores */
  PROCEDURE pc_busca_dados_58 (pr_cdcooper IN crapcop.cdcooper%type  --Codigo Cooperativa
                              ,pr_cdagenci IN crapass.cdagenci%type  --Codigo Agencia
                              ,pr_nrdcaixa IN INTEGER                --Numero Caixa
                              ,pr_cdoperad IN VARCHAR2               --Codigo Operador
                              ,pr_nmdatela IN VARCHAR2               --Nome Tela
                              ,pr_idorigem IN INTEGER                --Origem da chamada
                              ,pr_nrdconta IN crapass.nrdconta%type  --Numero da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%type  --Sequencial Titular
                              ,pr_flgerlog IN BOOLEAN                --Erro no Log
                              ,pr_cddopcao IN VARCHAR2               --Codigo opcao
                              ,pr_nrdctato IN INTEGER                --Numero Contato
                              ,pr_nrcpfcto IN NUMBER                 --Numero Cpf Contato
                              ,pr_nrdrowid IN ROWID                  --Rowid Empresa participante
                              ,pr_tab_crapavt OUT typ_tab_crapavt_58   --Tabela Avalistas
                              ,pr_tab_bens OUT typ_tab_bens            --Tabela bens
                              ,pr_tab_erro OUT gene0001.typ_tab_erro   --Tabela Erro
                              ,pr_cdcritic OUT INTEGER                 --Codigo de erro
                              ,pr_dscritic OUT VARCHAR2);              --Retorno de Erro

  /* Buscar dados dos Responsaveis Legais do associado */
  PROCEDURE pc_busca_dados_72 (pr_cdcooper IN crapcop.cdcooper%type --Codigo Cooperativa
                              ,pr_cdagenci IN crapass.cdagenci%type --Codigo Agencia
                              ,pr_nrdcaixa IN INTEGER               --Numero Caixa
                              ,pr_cdoperad IN VARCHAR2              --Codigo Operador
                              ,pr_nmdatela IN VARCHAR2              --Nome Tela
                              ,pr_idorigem IN INTEGER               --Origem da chamada
                              ,pr_nrdconta IN crapass.nrdconta%type --Numero da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%type --Sequencial Titular
                              ,pr_flgerlog IN BOOLEAN               --Erro no Log
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%type --Data Movimento
                              ,pr_cddopcao IN VARCHAR2              --Codigo opcao
                              ,pr_nrdctato IN INTEGER               --Numero Contato
                              ,pr_nrcpfcto IN NUMBER                --Numero Cpf Contato
                              ,pr_nrdrowid IN ROWID                 --Rowid Responsavel
                              ,pr_cpfprocu IN NUMBER                --Cpf Procurador
                              ,pr_nmrotina IN VARCHAR2              --Nome da Rotina
                              ,pr_dtdenasc IN DATE                  --Data Nascimento
                              ,pr_cdhabmen IN INTEGER               --Codigo Habilitacao
                              ,pr_permalte IN BOOLEAN               --Flag Permanece/Altera
                              ,pr_menorida OUT BOOLEAN              --Flag Menor idade
                              ,pr_msgconta OUT VARCHAR2             --Mensagem Conta
                              ,pr_tab_crapcrl OUT typ_tab_crapcrl   --Tabela Representantes Legais
                              ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erro
                              ,pr_cdcritic OUT INTEGER              --Codigo de erro
                              ,pr_dscritic OUT VARCHAR2);           --Retorno de Erro

  /* Buscar os Dados das Empresas Participantes */
  PROCEDURE pc_busca_dados_80 (pr_cdcooper IN crapcop.cdcooper%type  --Codigo Cooperativa
                              ,pr_cdagenci IN crapass.cdagenci%type  --Codigo Agencia
                              ,pr_nrdcaixa IN INTEGER                --Numero Caixa
                              ,pr_cdoperad IN VARCHAR2               --Codigo Operador
                              ,pr_nmdatela IN VARCHAR2               --Nome Tela
                              ,pr_idorigem IN INTEGER                --Origem da chamada
                              ,pr_nrdconta IN crapass.nrdconta%type  --Numero da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%type  --Sequencial Titular
                              ,pr_flgerlog IN BOOLEAN                --Erro no Log
                              ,pr_cddopcao IN VARCHAR2               --Codigo opcao
                              ,pr_nrdctato IN INTEGER                --Numero Contato
                              ,pr_nrcpfcto IN NUMBER                 --Numero Cpf Contato
                              ,pr_nrdrowid IN ROWID                  --Rowid Empresa participante
                              ,pr_tab_crapepa OUT typ_tab_crapepa    --Tabela Empresa Paticipante
                              ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erro
                              ,pr_cdcritic OUT INTEGER               --Codigo de erro
                              ,pr_dscritic OUT VARCHAR2);            --Retorno de Erro

  /* Funçao para Retornar a Data em anos */
  FUNCTION fn_busca_idade (pr_dtnascto IN crapdat.dtmvtolt%type
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%type) RETURN INTEGER;

  /* Procedure para calcular o faturamento medio mensal das pessoas juridicas. */
  PROCEDURE pc_calcula_faturamento(pr_cdcooper IN crapcop.cdcooper%type  --Codigo Cooperativa
                                  ,pr_cdagenci IN crapass.cdagenci%type --Codigo Agencia
                                  ,pr_nrdcaixa IN INTEGER               --Numero Caixa
                                  ,pr_nrdconta IN crapass.nrdconta%type  --Numero da Conta
                                  ,pr_vlmedfat OUT NUMBER                --Valor medio faturamento
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erro
                                  ,pr_des_reto OUT VARCHAR2);            --Retorno (OK/NOK)

  /* Validar o operador migrado */
  PROCEDURE pc_valida_operador_migrado(pr_cdcooper   IN crapopm.cdcooper%TYPE     -- Código da Cooperativa
                                      ,pr_cdoperad   IN crapopm.cdoperad%TYPE     -- Código do operador
                                      ,pr_cdagenci   IN craperr.cdagenci%TYPE     -- Código da agencia
                                      ,pr_nrdconta   IN craptco.nrctaant%TYPE     -- Número da conta
                                      ,pr_tab_erro  OUT gene0001.typ_tab_erro);   -- Tabela Erro

  /* Procedure para realizar a gravacao dos dados das anotacoes */
  PROCEDURE pc_grava_dados (pr_cdcooper  IN crapcop.cdcooper%TYPE  -- Codigo Cooperativa
                           ,pr_cdoperad  IN crapobs.cdoperad%TYPE  -- Código do operador
                           ,pr_cdagenci  IN crapage.cdagenci%TYPE  -- Código da Agencia
                           ,pr_nrdcaixa  IN NUMBER                 -- Numero Caixa
                           ,pr_nmdatela  IN VARCHAR2               -- Nome da tela
                           ,pr_idorigem  IN NUMBER                 -- Indicador de origem
                           ,pr_nrdconta  IN crapass.nrdconta%TYPE  -- Número da Conta
                           ,pr_nrseqdig  IN crapobs.nrseqdig%TYPE  -- Sequencia de digitacao
                           ,pr_dsobserv  IN crapobs.dsobserv%TYPE  -- Observação
                           ,pr_flgprior  IN crapobs.flgprior%TYPE  -- Prioridade da observacao 
                           ,pr_cddopcao  IN VARCHAR2               -- Opção I - Incluir, A - Alterar e E - Excluir
                           ,pr_dtmvtolt  IN DATE                   -- Data da observação
                           ,pr_flgerlog IN BOOLEAN                 -- Erro no Log
                           ,pr_tab_erro OUT gene0001.typ_tab_erro  -- Tabela Erro
                           ,pr_cdcritic OUT INTEGER                -- Codigo de erro
                           ,pr_dscritic OUT VARCHAR2);             -- Retorno de Erro

  -- Listar cooperativa ayllosweb
  PROCEDURE pc_lista_cooperativas_web(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                     ,pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo         
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
                         
                                     

  --> Identificar Orgão Expedidor
  PROCEDURE pc_busca_id_orgao_expedidor (pr_cdorgao_expedidor   IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE, 
                                         pr_idorgao_expedidor  OUT tbgen_orgao_expedidor.idorgao_expedidor%TYPE, 
                                         pr_cdcritic           OUT INTEGER,
                                         pr_dscritic           OUT VARCHAR2);                                     
  --> Buscar dados Orgão Expedidor
  PROCEDURE pc_busca_orgao_expedidor (pr_idorgao_expedidor   IN tbgen_orgao_expedidor.idorgao_expedidor%TYPE, 
                                      pr_cdorgao_expedidor  OUT tbgen_orgao_expedidor.cdorgao_expedidor%TYPE, 
                                      pr_nmorgao_expedidor  OUT tbgen_orgao_expedidor.nmorgao_expedidor%TYPE, 
                                      pr_cdcritic           OUT INTEGER,
                                      pr_dscritic           OUT VARCHAR2);

END CADA0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0001 IS
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : CADA0001
    Sistema  : Rotinas para cadastros Web
    Sigla    : CADA
    Autor    : Petter R. Villa Real  - Supero
    Data     : Maio/2013.                   Ultima atualizacao: 22/06/2017
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Rotinas para manutenção (cadastro) dos dados para sistema Web/genérico
  
   Alteracoes: 02/06/2014 - Removido os campos cdestcvl e vlsalari da crapass e
                            adicionados na crapttl. Ajustes na "pc_busca_dados_cto_72",
                            "pc_busca_dados_cto_58", "pc_busca_dados_ass_58",
                            "pc_busca_dados_id_58" (Douglas - Chamado 131253)
  
               07/10/2015 - Alterado parametro pr_flcomple da pc_busca_idade para number 
                            (Lucas Ranghetti #340156)  
  
               10/11/2015 - Incluido o campo tt-crapavt.idrspleg, e incluido verificacao
                            na procedure pc_busca_dados_58 para verificar se o representante
                            é responsável legal pelo acesso aos canais de autoatendimento e SAC (Jean Michel).
  
               01/03/2016 - Adicionado SUBSTR na procedure pc_busca_dados_cto_72 para os campos 
                            nmrespon, nmpairsp, nmmaersp que são carregados da crapttl, e que 
                            possuem tamanho de campos diferentes (Douglas - Chamado 410909)
  
               16/06/2016 - Correcao para o uso correto do indice da CRAPTAB em varias
                            procedures desta package. (Carlos Rafael Tanholi).        
  
    			     25/04/2017 - Ajustes realizados:
                            - Retirar o uso de campos removidos da tabela crapass, crapttl, crapjur 
                            - Retirar as rotinas de consulta/inclusão de naciondalidade, pois
                              foi criado a tela CADNAC para genrenciar as nacionalidades
                            (Adriano - P339).
              
			  24/07/2017 - Alterar cdoedptl para idorgexp.
                           PRJ339-CRM  (Odirlei-AMcom)
	
  ---------------------------------------------------------------------------------------------------------------*/

  -- Type para os motivos de demissões
  TYPE tab_motdem IS TABLE OF craptab.dstextab%TYPE INDEX BY BINARY_INTEGER;
  vr_tbmotdem   tab_motdem;

  vr_dsnacion   crapnac.dsnacion%TYPE;

  -- Busca dos dados do associado
  CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.vllimcre
          ,crapass.nrcpfcgc
          ,crapass.inpessoa
          ,crapass.cdcooper
          ,crapass.cdagenci
          ,crapass.dtdemiss
          ,crapass.indnivel
          ,crapass.cdtipcta
          ,crapass.tpdocptl
          ,crapass.nrdocptl
          ,crapass.idorgexp
          ,crapass.cdufdptl
          ,crapass.dtemdptl
          ,crapass.dtnasctl
          ,crapass.cdsexotl
          ,crapass.cdnacion
    FROM crapass
    WHERE crapass.cdcooper = pr_cdcooper
    AND   crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  -- Busca a Nacionalidade
  CURSOR cr_crapnac(pr_cdnacion IN crapnac.cdnacion%TYPE) IS
    SELECT crapnac.dsnacion
      FROM crapnac
     WHERE crapnac.cdnacion = pr_cdnacion;

  --Selecionar Cadastro Tipos de natureja juridica
  CURSOR cr_gncdntj (pr_cdnatjur IN gncdntj.cdnatjur%type) IS
    SELECT gncdntj.dsnatjur
    FROM gncdntj
    WHERE gncdntj.cdnatjur = pr_cdnatjur;
  rw_gncdntj cr_gncdntj%ROWTYPE;

  --Selecionar Rumo Atividade
  CURSOR cr_gnrativ (pr_cdseteco IN gnrativ.cdseteco%type
                    ,pr_cdrmativ IN gnrativ.cdrmativ%type) IS
    SELECT gnrativ.nmrmativ
    FROM gnrativ
    WHERE gnrativ.cdseteco = pr_cdseteco
    AND   gnrativ.cdrmativ = pr_cdrmativ;
  rw_gnrativ cr_gnrativ%ROWTYPE;

  --Selecionar Email
  CURSOR cr_crapcem (pr_cdcooper IN crapcem.cdcooper%type
                    ,pr_nrdconta IN crapcem.nrdconta%type
                    ,pr_idseqttl IN crapcem.idseqttl%type
                    ,pr_cddemail IN crapcem.cddemail%type) IS
    SELECT crapcem.dsdemail
    FROM crapcem
    WHERE crapcem.cdcooper = pr_cdcooper
    AND   crapcem.nrdconta = pr_nrdconta
    AND   crapcem.idseqttl = pr_idseqttl
    AND   crapcem.cddemail = pr_cddemail;
  rw_crapcem cr_crapcem%ROWTYPE;

  --Selecionar Telefones
  CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%type
                    ,pr_nrdconta IN craptfc.nrdconta%type
                    ,pr_idseqttl IN craptfc.idseqttl%type
                    ,pr_cdseqtfc IN craptfc.cdseqtfc%type) IS
    SELECT craptfc.nrtelefo
    FROM craptfc
    WHERE craptfc.cdcooper = pr_cdcooper
    AND   craptfc.nrdconta = pr_nrdconta
    AND   craptfc.idseqttl = pr_idseqttl
    AND   craptfc.cdseqtfc = pr_cdseqtfc
    ORDER BY craptfc.progress_recid ASC;
  rw_craptfc cr_craptfc%ROWTYPE;

  --Selecionar Estado Civil
  CURSOR cr_gnetcvl (pr_cdestcvl IN gnetcvl.cdestcvl%type) IS
    SELECT gnetcvl.dsestcvl
          ,gnetcvl.rsestcvl
    FROM gnetcvl
    WHERE gnetcvl.cdestcvl = pr_cdestcvl;
  rw_gnetcvl cr_gnetcvl%ROWTYPE;

  /* Rotina responsavel por calcular a quantidade de anos e meses entre as datas */
  PROCEDURE pc_busca_idade (pr_dtnasctl IN crapdat.dtmvtolt%TYPE  --> Data de Nascimento
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data da utilizacao atual
                           ,pr_flcomple IN NUMBER DEFAULT 0  --> Controle para validar o método de cálculo de datas
                           ,pr_nrdeanos OUT INTEGER               --> Numero de Anos
                           ,pr_nrdmeses OUT INTEGER               --> Numero de meses
                           ,pr_dsdidade OUT VARCHAR2              --> Descricao da idade
                           ,pr_des_erro OUT VARCHAR2) IS          --> Mensagem de Erro
  BEGIN
  /* ..........................................................................

     Programa: pc_busca_idade                      Antigo: Fontes/idade.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Edson
     Data    : Setembro/97.                        Ultima Atualizacao: 07/10/2015

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Calcular a idade do associado em anos e meses.

                 ************************************************************************
                 Conforme acertado com o Guilherme Strube, foi criado o parâmetro
                 pr_flcomple com o valor default FALSE(0) que irá conduzir a rotina para o
                 cálculo de datas considerando todos os meses com 30 dias, conforme o
                 processo atual do Progress.
                 Caso o parâmetro pr_flcomple seja informado como TRUE(1) ele irá direcionar
                 a rotina para o cálculo de datas correto (considerando o número exato
                 de dias).
                 ************************************************************************

     Alteracoes: 25/03/98 - Tratamento para milenio e troca para V8 (Margarete).

                 12/03/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

                 12/11/2013 - Correção da descrição da data (acertar resto de meses).

                 13/11/2013 - Criar método conforme especificação do Progress e manter
                              processo conforme tratamento correto de datas.

                 07/10/2015 - Alterado parametro pr_flcomple para number (Lucas Ranghetti #340156)
  ............................................................................. */
    DECLARE
      --Variaveis Locais
      vr_exc_erro     EXCEPTION;           --> Controle de exception

    BEGIN
      --Inicializar variavel de erro
      pr_des_erro := NULL;

      --Se a data atual for menor que o nascimento
      IF pr_dtmvtolt < pr_dtnasctl THEN
        --Montar mensagem
        pr_dsdidade := 'NAO E POSSIVEL CALCULAR A IDADE.';
        pr_nrdeanos := 0;
        pr_nrdmeses := 0;
      ELSE
        IF pr_flcomple = 1 THEN -- TRUE
          -- Cálculo considerando datas reais conforme Oracle
          -- Calcular a quantidade de anos atraves do meses entre as datas dividido por 12
          pr_nrdeanos := TRUNC(Months_Between(pr_dtmvtolt,pr_dtnasctl) / 12, 0);

          -- Calcular a quantidade de meses buscando a quantidade de meses entre as datas
          pr_nrdmeses := Trunc(Months_Between(pr_dtmvtolt,pr_dtnasctl), 0);
          pr_nrdmeses := Nvl(pr_nrdmeses, 0) - (Nvl(pr_nrdeanos, 0) * 12);
        ELSE
          -- Cálculo considerando datas reais conforme Progress
          -- Calcular a quantidade de anos atraves do meses entre as datas dividido por 12
          pr_nrdeanos := trunc((pr_dtmvtolt - pr_dtnasctl) / 365, 0);

          -- Calcular a quantidade de meses buscando a quantidade de meses entre as datas
          pr_nrdmeses := trunc(MOD((pr_dtmvtolt - pr_dtnasctl), 365) / 30, 0);
        END IF;

        pr_dsdidade := pr_nrdeanos || ' anos';

        -- Montar string com descrição do tempo decorrido
        IF pr_nrdmeses > 0 THEN
          IF pr_nrdmeses = 1 THEN
            pr_dsdidade := pr_dsdidade || ' e ' || pr_nrdmeses || ' mes';
          ELSE
            pr_dsdidade := pr_dsdidade || ' e ' || pr_nrdmeses || ' meses';
          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro:= 'Erro na rotina CADA0001.pc_busca_idade: ' || SQLERRM;
    END;
  END;

  /* Funçao para Retornar a Data em anos */
  FUNCTION fn_busca_idade (pr_dtnascto IN crapdat.dtmvtolt%TYPE  --Data Nascimento
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%type) --Data Atual
  RETURN INTEGER IS
  BEGIN
  /* ..........................................................................

   Programa: fn_busca_idade             Antigo: includes/b1wgen0072.BuscaIdade
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014                            Ultima alteracao:

   Dados referentes ao programa:

   Frequencia: Quando for chamado
   Objetivo  : Retornar Idade em anos

   Alteracoes: 10/01/2014 - Conversao Progress -> Oracle - Alisson (AMcom)

  ............................................................................. */
    DECLARE
      --Variaveis Locais
      vr_nrdeanos INTEGER:= 0;
      vr_nrdmeses INTEGER:= 0;
      vr_dsdidade VARCHAR2(1000);
      vr_dscritic VARCHAR2(4000);
    BEGIN
      --Buscar Idade
      CADA0001.pc_busca_idade (pr_dtnasctl => pr_dtnascto   --Data de Nascimento
                              ,pr_dtmvtolt => pr_dtmvtolt   --Data da utilizacao atual
                              ,pr_flcomple => 0             --> Controle para validar o método de cálculo de datas
                              ,pr_nrdeanos => vr_nrdeanos   --Numero de Anos
                              ,pr_nrdmeses => vr_nrdmeses   --Numero de meses
                              ,pr_dsdidade => vr_dsdidade   --Descricao da idade
                              ,pr_des_erro => vr_dscritic); --Mensagem de Erro
      --Retornar Idade em anos
      RETURN(vr_nrdeanos);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN(NULL);
    END;
  END;

  /* Rotina Responsavel por Validar o Cpf/Cnpj */
  FUNCTION fn_valida_cpf (pr_nrcpfcgc IN VARCHAR2) RETURN BOOLEAN IS
  /* ..........................................................................

   Programa: fn_valida_cpf                           Antigo: b1wgen0072.p/ValidaCpf
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014                            Ultima alteracao:

   Dados referentes ao programa:

   Frequencia: Quando for Chamado
   Objetivo  : Validar Cpf/Cnpj

   Alteracoes: 10/01/2014 - Conversao Progress -> Oracle - Alisson (AMcom)

  ............................................................................. */
  BEGIN
    DECLARE
      vr_stsnrcal BOOLEAN;
      vr_inpessoa INTEGER;
    BEGIN
      /* Se houve erro na conversao para DEC, faz a critica */
      gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => To_Number(pr_nrcpfcgc) --Numero a ser verificado
                                  ,pr_stsnrcal => vr_stsnrcal     --Situacao
                                  ,pr_inpessoa => vr_inpessoa);   --Tipo Inscricao Cedente
      --Retornar resultado da validacao
      RETURN(vr_stsnrcal);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN(FALSE);
    END;
  END;


  /* Rotina responsavel por Buscar o Motivo da demissao */
  PROCEDURE pc_busca_motivo_demissao (pr_cdcooper IN crapcop.cdcooper%TYPE  --Código Cooperativa
                                     ,pr_cdmotdem IN crapass.cdmotdem%TYPE  --Código Motivo Demissao
                                     ,pr_dsmotdem OUT VARCHAR2              --Descrição Motivo Demissao
                                     ,pr_cdcritic OUT INTEGER               --Codigo da Critica
                                     ,pr_des_erro OUT VARCHAR2) IS          --Mensagem de Erro
  BEGIN
  /* ..........................................................................

   Programa: pc_busca_motivo_demissao             Antigo: fontes/le_motivo_demissao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Maio/2005                            Ultima alteracao: 27/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Le cadastro de motivos de demissao (saida de socio).

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               18/03/2013 - Convers¿o Progress -> Oracle - Alisson (AMcom)

               16/09/2013 - Altera¿¿o da rotina para trabalhar com registros de
                            memória,afim de melhorar a performance (Renato - Supero)
  ............................................................................. */
    DECLARE

      --Cursores Locais
      CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE
                        ,pr_nmsistem IN craptab.nmsistem%TYPE
                        ,pr_tptabela IN craptab.tptabela%TYPE
                        ,pr_cdempres IN craptab.cdempres%TYPE
                        ,pr_cdacesso IN craptab.cdacesso%TYPE
                        ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT craptab.tpregist
             , craptab.dstextab
        FROM craptab craptab
        WHERE craptab.cdcooper = pr_cdcooper
        AND   UPPER(craptab.nmsistem) = pr_nmsistem
        AND   UPPER(craptab.tptabela) = pr_tptabela
        AND   craptab.cdempres = pr_cdempres
        AND   UPPER(craptab.cdacesso) = pr_cdacesso
        AND   (craptab.tpregist = pr_tpregist OR pr_tpregist IS NULL);
      rw_craptab cr_craptab%ROWTYPE;

      --Variaveis Locais
      vr_exc_erro     EXCEPTION;
      -- Guardar registro dstextab
      vr_dstextab craptab.dstextab%TYPE;      

    BEGIN
      --Inicializar variavel de erro
      pr_cdcritic:= 0;
      pr_des_erro:= NULL;

      -- Se n¿o informar o motivo da demiss¿o
      IF pr_cdmotdem IS NULL THEN
        -- Limpar os dados em memória
        vr_tbmotdem.DELETE;
        -- Percorre os motivos de demiss¿o
        FOR rg_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper
                                    ,pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'GENERI'
                                    ,pr_cdempres => 0
                                    ,pr_cdacesso => 'MOTIVODEMI'
                                    ,pr_tpregist => NULL) LOOP
          -- Inclui o registro na memória
          vr_tbmotdem(rg_craptab.tpregist) := rg_craptab.dstextab;

        END LOOP;

      ELSIF NOT vr_tbmotdem.EXISTS(pr_cdmotdem) THEN
        --Se o codigo do motivo da demissao for zero ignora
        IF NVL(pr_cdmotdem,-1) <> 0 THEN

          -- Buscar configuração na tabela
          vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                          ,pr_nmsistem => 'CRED'
                          ,pr_tptabela => 'GENERI'
                          ,pr_cdempres => 0
                          ,pr_cdacesso => 'MOTIVODEMI'
                          ,pr_tpregist => pr_cdmotdem);

          --Se nao encontrou registro
          IF TRIM(vr_dstextab) IS NULL THEN
            --Retornar que nao encontrou
            pr_cdcritic:= 848;
            pr_dsmotdem:= 'MOTIVO NAO CADASTRADO';
          ELSE
            --Retornar o motivo encontrado
            pr_dsmotdem:= vr_dstextab;
          END IF;
          --Fechar Cursor
          CLOSE cr_craptab;
        END IF;
      ELSIF vr_tbmotdem.EXISTS(pr_cdmotdem) THEN
        -- Retorna a descrição do registro de memória
        pr_dsmotdem := vr_tbmotdem(pr_cdmotdem);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro:= 'Erro na rotina CADA0001.pc_busca_motivo_demissao. '||SQLERRM;
    END;
  END;

  /* Buscar as Contas Centralizadoras do BBrasil */
  PROCEDURE pc_BuscaCtaCe(pr_cdcooper IN NUMBER        --> Código da cooperativa
                         ,pr_tpregist IN NUMBER        --> Tipo do registro
                         ,pr_lscontas OUT VARCHAR2     --> Lista de contas
                         ,pr_dscritic OUT VARCHAR2     --> Descrição da crítica
                         ,pr_des_erro OUT VARCHAR2)IS  --> Descrição do erro
  /* .............................................................................

   Programa: pc_BuscaCtaCe              Antigo: b1wgen0060.p --> BuscaCtaCe
   Sistema : Web - Cooperativa de Credito
   Sigla   : CADA
   Autor   : David
   Data    : Maio/2013.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Buscar as Contas Centralizadoras do BBrasil.

   Alteracoes: 12/05/2013 - Convers¿o Progress >> Oracle (PLSQL) (Petter-Supero)

  ............................................................................. */
  BEGIN
    DECLARE
      vr_testa     EXCEPTION;         --> Controle de teste de vari¿veis

      /* Busca dados do cadastro BBrasil */
      CURSOR cr_gnctace(pr_cdcooper  IN NUMBER       --> Código da cooperativa
                       ,pr_tpregist  IN NUMBER) IS   --> Tipo do registro
        SELECT gn.nrctacen
              ,gn.cdcooper
              ,COUNT(1) OVER() contagem
        FROM gnctace gn
        WHERE gn.cdcooper = pr_cdcooper
          AND gn.cddbanco = 1
          AND gn.tpregist = decode(pr_tpregist, 0, gn.tpregist, pr_tpregist);

    BEGIN
      -- Inicializar vari¿veis
      pr_lscontas := '';

      -- Verifica valores para retorno TRUE
      IF pr_tpregist < 0 AND pr_tpregist > 4 THEN
        RAISE vr_testa;
      END IF;

      -- Iterar sobre a busca de contas
      FOR vr_gnctace IN cr_gnctace(pr_cdcooper, pr_tpregist) LOOP
        IF length(pr_lscontas) > 1 THEN
          pr_lscontas := pr_lscontas || ',';
        END IF;

        pr_lscontas := pr_lscontas || TRIM(vr_gnctace.nrctacen);
      END LOOP;

      -- Busca crítica
      IF length(pr_lscontas) < 1 THEN
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 393);
      END IF;
    EXCEPTION
      WHEN vr_testa THEN
        -- Apenas encerra execução
        NULL;
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em CADA0001.pc_BuscaCtaCe: ' || SQLERRM;
    END;
  END pc_BuscaCtaCe;

  /* Calcular digito 10 - BBrasil */
  PROCEDURE pc_digm10(pr_nrcalcul IN OUT NUMBER    --> Número para calculo
                     ,pr_nrdigito OUT PLS_INTEGER  --> Número do dígito
                     ,pr_stsnrcal OUT BOOLEAN      --> Retorno de execução de cálculo
                     ,pr_des_erro OUT VARCHAR2) IS --> Retorno de erro
  /* .............................................................................

   Programa: pc_digm10                Antigo: b1wgen9998.p --> digm10
   Sistema : Web - Cooperativa de Credito
   Sigla   : CADA
   Autor   : ---
   Data    : Maio/2013.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Calcular e conferir o digito verificador pelo modulo dez.

   Alteracoes: 22/05/2013 - Convers¿o Progress >> Oracle (PLSQL) (Petter-Supero)

  ............................................................................. */
  BEGIN
    DECLARE
      vr_digito    PLS_INTEGER := 0;    --> D¿gito
      vr_peso      PLS_INTEGER := 2;    --> Peso
      vr_calculo   PLS_INTEGER := 0;    --> Calculo
      vr_dezena    PLS_INTEGER := 0;    --> Valor dezena
      vr_resulta   PLS_INTEGER := 0;    --> Resultado
      vr_final     EXCEPTION;      --> Controle para finalizar aplica¿¿o

    BEGIN
      -- Verifica tamanho do n¿mero para cálculo
      IF length(to_char(pr_nrcalcul)) < 2 THEN
        pr_stsnrcal := FALSE;

        RAISE vr_final;
      END IF;

      -- Itera de forma reversa para o tamanho do n¿mero
      FOR vr_posicao IN REVERSE 1..length(to_char(pr_nrcalcul)) - 1 LOOP
        vr_resulta := gene0002.fn_char_para_number(substr(to_char(pr_nrcalcul), vr_posicao, 1)) * vr_peso;

        -- Verifica posi¿¿o dos resultados
        IF vr_resulta > 9 THEN
          vr_resulta := gene0002.fn_char_para_number(substr(to_char(vr_resulta, 'fm00'), 1, 1)) +
                         gene0002.fn_char_para_number(substr(to_char(vr_resulta, 'fm00'), 2, 1));
        END IF;

        -- Atribui novos valores para as variaveis
        vr_calculo := vr_calculo + vr_resulta;
        vr_peso := vr_peso - 1;

        -- Verifica valor do peso
        IF vr_peso = 0 THEN
          vr_peso := 2;
        END IF;
      END LOOP;

      -- Atribui valores para as vari¿veis
      vr_dezena := (gene0002.fn_char_para_number(substr(to_char(vr_calculo, 'fm000'), 1, 2)) + 1) * 10;
      vr_digito := vr_dezena - vr_calculo;

      -- Verifica valor do dígito
      IF vr_digito = 10 THEN
        vr_digito := 0;
      END IF;

      -- Compara dígito
      IF (gene0002.fn_char_para_number(substr(to_char(pr_nrcalcul), length(to_char(pr_nrcalcul)), 1))) <> vr_digito   THEN
        pr_stsnrcal := FALSE;
      ELSE
        pr_stsnrcal := TRUE;
      END IF;

      -- Atribui valores para as vari¿veis
      pr_nrcalcul := gene0002.fn_char_para_number(substr(to_char(pr_nrcalcul), 1, length(to_char(pr_nrcalcul)) - 1) || to_char(vr_digito));
      pr_nrdigito := vr_digito;
    EXCEPTION
      WHEN vr_final THEN
        -- Apenas finaliza execução
        NULL;
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em CADA0001.pc_digm10: ' || SQLERRM;
    END;
  END pc_digm10;

  /* Rotina gera temptable com os movimentos de saques da cooperativa */
  PROCEDURE pc_busca_movto_saque_cooper(pr_cdcooper  IN INTEGER  --> Código da cooperativo
                                       ,pr_cdcoptfn  IN INTEGER  --> Codigo que identifica a Cooperativa do Cash.
                                       ,pr_dtmvtoin  IN DATE     --> Data de movimento inicial
                                       ,pr_dtmvtofi  IN DATE     --> Data de movimento final
                                       ,pr_cdtplanc  IN INTEGER  --> Codigo do tipo de lançamento
                                       ,pr_dscritic OUT VARCHAR2 --> retorno da descrição de critica
                                       ,pr_tab_lancamentos OUT typ_tab_lancamentos) IS --> Retorno da temptable com os lançamentos
  /* .............................................................................

   Programa: pc_busca_movto_saque_cooper                Antigo: b1wgen0025.p\busca_movto_saque_cooperativa:
   Sistema : Web - Cooperativa de Credito
   Sigla   : CADA
   Autor   : Odirlei Busana (AMcom)
   Data    : novembro/2013.                        Ultima atualizacao:22/11/2013

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Gerar temptable com os movimentos de saques da cooperativa
               Utilizada em CRPS580/CRPS581/CASH.
                Consulta por:
                  - Saques feitos no meu TAA por outras Coops (par_cdcoptfn <> 0)
                  - Saques feitos por meus Assoc. em outras Coops (par_cdcooper <> 0)

   Alteracoes: 22/11/2013 - Conversção Progress >> Oracle (PLSQL) (Odirlei-AMcom)

  ............................................................................. */

    vr_idx varchar2(38);

    -- Buscar lançamentos de deposito avista da cooperativa cash
    CURSOR cr_craplcm IS
      SELECT cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta,
             vllanmto,
             cdhistor,
             ROW_NUMBER() OVER(PARTITION BY cdcooper, nrdconta
                               ORDER BY cdcooper, nrdconta) nrseq_conta
        FROM craplcm
       WHERE craplcm.cdcoptfn = pr_cdcoptfn
         AND craplcm.cdhistor in (918 -- SAQUE TAA
                                 ,920)-- EST.SAQUE TAA
         AND craplcm.dtmvtolt >= pr_dtmvtoin
         AND craplcm.dtmvtolt <= pr_dtmvtofi
         AND craplcm.cdcooper <> craplcm.cdcoptfn
       ORDER BY cdcooper, nrdconta;

    -- Buscar lançamentos de deposito avista da cooperativa
    CURSOR cr_craplcm_cop IS
      SELECT cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta,
             vllanmto,
             cdhistor,
             ROW_NUMBER() OVER(PARTITION BY cdcooper, nrdconta
                               ORDER BY cdcooper, nrdconta) nrseq_conta
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.cdhistor IN (918, -- SAQUE TAA
                                  920) -- EST.SAQUE TAA
         AND craplcm.dtmvtolt >= pr_dtmvtoin
         AND craplcm.dtmvtolt <= pr_dtmvtofi
         AND craplcm.cdcooper <> craplcm.cdcoptfn
         AND craplcm.cdcoptfn <> 0
       ORDER BY cdcooper, nrdconta;

  BEGIN

    /* Saques feitos no meu TAA por outras Coops     */
    IF pr_cdcoptfn <> 0 THEN
      --ler lançamentos
      FOR rw_craplcm IN cr_craplcm LOOP

        vr_idx := lpad(pr_cdtplanc,3,'0')||lpad(rw_craplcm.cdcooper,10,'0')||
                  lpad(rw_craplcm.cdcoptfn,10,'0')||lpad(rw_craplcm.cdagetfn,5,'0')||
                  lpad(rw_craplcm.nrdconta,10,'0');

        pr_tab_lancamentos(vr_idx).cdtplanc := pr_cdtplanc;
        pr_tab_lancamentos(vr_idx).cdcooper := rw_craplcm.cdcooper;
        pr_tab_lancamentos(vr_idx).cdcoptfn := rw_craplcm.cdcoptfn;
        pr_tab_lancamentos(vr_idx).cdagetfn := rw_craplcm.cdagetfn;
        pr_tab_lancamentos(vr_idx).nrdconta := rw_craplcm.nrdconta;
        pr_tab_lancamentos(vr_idx).qtdecoop := 1;
        pr_tab_lancamentos(vr_idx).dstplanc := 'Saque';
        pr_tab_lancamentos(vr_idx).tpconsul := 'TAA';

        IF rw_craplcm.cdhistor = 918 THEN /* SAQUE TAA */
          pr_tab_lancamentos(vr_idx).qtdmovto := NVL(pr_tab_lancamentos(vr_idx).qtdmovto,0) + 1;
          pr_tab_lancamentos(vr_idx).vlrtotal := NVL(pr_tab_lancamentos(vr_idx).vlrtotal,0) +
                                                 rw_craplcm.vllanmto;
        ELSE
          pr_tab_lancamentos(vr_idx).qtdmovto := NVL(pr_tab_lancamentos(vr_idx).qtdmovto,0) - 1;
          pr_tab_lancamentos(vr_idx).vlrtotal := NVL(pr_tab_lancamentos(vr_idx).vlrtotal,0) -
                                                 rw_craplcm.vllanmto;
        END IF;

      END LOOP; /* END do FOR EACH LCM */

    END IF; /* END do IF par_cdcoptfn */


    /* Saques feitos por meus Assoc. em outras Coops */
    IF pr_cdcooper <> 0 THEN
      --ler lançamentos
      FOR rw_craplcm IN cr_craplcm_cop LOOP

        -- Simular First-of
        IF rw_craplcm.nrseq_conta = 1 THEN
          vr_idx := lpad(pr_cdtplanc,3,'0')||lpad(rw_craplcm.cdcooper,10,'0')||
                    lpad(rw_craplcm.cdcoptfn,10,'0')||lpad(rw_craplcm.cdagetfn,5,'0')||
                    lpad(rw_craplcm.nrdconta,10,'0');

          IF NOT pr_tab_lancamentos.EXISTS(vr_idx) THEN
            pr_tab_lancamentos(vr_idx).cdtplanc := pr_cdtplanc;
            pr_tab_lancamentos(vr_idx).cdcooper := rw_craplcm.cdcooper;
            pr_tab_lancamentos(vr_idx).cdcoptfn := rw_craplcm.cdcoptfn;
            pr_tab_lancamentos(vr_idx).cdagetfn := rw_craplcm.cdagetfn;
            pr_tab_lancamentos(vr_idx).nrdconta := rw_craplcm.nrdconta;
            pr_tab_lancamentos(vr_idx).qtdecoop := 1;
            pr_tab_lancamentos(vr_idx).dstplanc := 'Saque';
            pr_tab_lancamentos(vr_idx).tpconsul := 'Outras Coop';
          END IF;
        END IF;

        IF rw_craplcm.cdhistor = 918 THEN /* SAQUE TAA */
          pr_tab_lancamentos(vr_idx).qtdmovto := NVL(pr_tab_lancamentos(vr_idx).qtdmovto,0) + 1;
          pr_tab_lancamentos(vr_idx).vlrtotal := NVL(pr_tab_lancamentos(vr_idx).vlrtotal,0) +
                                                 rw_craplcm.vllanmto;
        ELSE
          pr_tab_lancamentos(vr_idx).qtdmovto := NVL(pr_tab_lancamentos(vr_idx).qtdmovto,0) - 1;
          pr_tab_lancamentos(vr_idx).vlrtotal := NVL(pr_tab_lancamentos(vr_idx).vlrtotal,0) -
                                                 rw_craplcm.vllanmto;
        END IF;
      END LOOP; /* END do FOR EACH LCM */
    END IF; /* END do IF par_cdcooper */

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na CADA0001.pc_busca_movto_saque_cooper: '||SQLerrm;
  END pc_busca_movto_saque_cooper;

  /* Buscar a Ocupacao do Associado */
  FUNCTION fn_busca_ocupacao(pr_cddocupa IN  crapttl.cdocpttl%type --> Código da ocupacao
                            ,pr_rsdocupa OUT VARCHAR2     --> Descricao Ocupacao
                            ,pr_cdcritic OUT INTEGER      --C¿digo de erro
                            ,pr_dscritic OUT VARCHAR2)    --Retorno de Erro
                            RETURN BOOLEAN IS
  /* .............................................................................

   Programa: fn_busca_ocupacao                 Antigo: b1wgen0060.p --> BuscaOcupacao
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Buscar a ocupação

   Alteracoes: 07/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

  ............................................................................. */
  BEGIN
    DECLARE
      --Selecionar Ocupacao
      CURSOR cr_gncdocp (pr_cddocupa IN gncdocp.cdocupa%type) IS
        SELECT gncdocp.rsdocupa
        FROM gncdocp
        WHERE gncdocp.cdocupa = pr_cddocupa;
      rw_gncdocp cr_gncdocp%ROWTYPE;
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Selecionar Ocupacao
      OPEN cr_gncdocp (pr_cddocupa => pr_cddocupa);
      FETCH cr_gncdocp INTO rw_gncdocp;
      --Se nao encontrou
      IF cr_gncdocp%NOTFOUND THEN
        pr_rsdocupa:= 'NAO INFORMADO';
        pr_dscritic:= 'Ocupacao nao cadastrada: '||pr_cddocupa;
      ELSE
        pr_rsdocupa:= rw_gncdocp.rsdocupa;
      END IF;
      --Fechar Cursor
      CLOSE cr_gncdocp;
      --Retornar valor
      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.fn_busca_ocupacao: ' || SQLERRM;
        RETURN(FALSE);
    END;
  END fn_busca_ocupacao;

  /* Buscar a Habilitacao */
  FUNCTION fn_busca_habilitacao(pr_inhabmen IN  INTEGER      --> Código Habilitacao
                               ,pr_dshabmen OUT VARCHAR2     --> Descricao Habilitacao
                               ,pr_cdcritic OUT INTEGER      --C¿digo de erro
                               ,pr_dscritic OUT VARCHAR2)    --Retorno de Erro
                               RETURN BOOLEAN IS
  /* .............................................................................

   Programa: fn_busca_habilitacao                 Antigo: b1wgen0060.p --> BuscaOcupacao
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Buscar a Habilitacao

   Alteracoes: 07/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

  ............................................................................. */
  BEGIN
    DECLARE
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      CASE pr_inhabmen
        WHEN 1 THEN pr_dshabmen:= '- EMANCIPADO';
        WHEN 2 THEN pr_dshabmen:= '- INC. CIVIL';
        WHEN 0 THEN pr_dshabmen:= '- MENOR/MAIOR';
        ELSE
          pr_dscritic:= 'Habilitacao incorreta.';
          RETURN (FALSE);
      END CASE;
      --Retornar valor
      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.fn_busca_habilitacao: ' || SQLERRM;
        RETURN(FALSE);
    END;
  END fn_busca_habilitacao;

  /* Buscar o Estado Civil */
  FUNCTION fn_busca_estado_civil (pr_cdestcvl IN  INTEGER   --> Código Estado Civil
                                 ,pr_dsestcvl OUT VARCHAR2  --> Descricao Estado Civil
                                 ,pr_cdcritic OUT INTEGER   --Codigo de erro
                                 ,pr_dscritic OUT VARCHAR2) --Retorno de Erro
                                 RETURN BOOLEAN IS
  /* .............................................................................

   Programa: fn_busca_estado_civil                 Antigo: b1wgen0060.p --> BuscaEstadoCivil
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Buscar o estado civil

   Alteracoes: 07/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

  ............................................................................. */
  BEGIN
    DECLARE
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Selecionar Ocupacao
      OPEN cr_gnetcvl (pr_cdestcvl => pr_cdestcvl);
      FETCH cr_gnetcvl INTO rw_gnetcvl;
      --Se nao encontrou
      IF cr_gnetcvl%NOTFOUND THEN
        pr_dsestcvl:= 'NAO INFORMADO';
        pr_dscritic:= gene0001.fn_busca_critica(35);
      ELSE
        pr_dsestcvl:= rw_gnetcvl.dsestcvl;
      END IF;
      --Fechar Cursor
      CLOSE cr_gnetcvl;
      --Retornar valor
      RETURN (pr_dsestcvl <> 'NAO INFORMADO');
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.fn_busca_estado_civil: ' || SQLERRM;
        RETURN(FALSE);
    END;
  END fn_busca_estado_civil;

  /* Buscar os Contatos do Associado */
  PROCEDURE pc_obtem_contatos (pr_cdcooper IN crapcop.cdcooper%type --Codigo Cooperativa
                              ,pr_cdagenci IN crapass.cdagenci%type --Codigo Agencia
                              ,pr_nrdcaixa IN INTEGER               --Numero Caixa
                              ,pr_cdoperad IN VARCHAR2              --Codigo Operador
                              ,pr_nmdatela IN VARCHAR2              --Nome Tela
                              ,pr_idorigem IN INTEGER               --Origem da chamada
                              ,pr_nrdconta IN crapass.nrdconta%type --Numero da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%type --Sequencial Titular
                              ,pr_flgerlog IN BOOLEAN               --Erro no Log
                              ,pr_tab_contato_juridica OUT typ_tab_contato_juridica --Tabela Contato
                              ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erro
                              ,pr_cdcritic OUT INTEGER   --Codigo de erro
                              ,pr_dscritic OUT VARCHAR2) IS --Retorno de Erro
  /* .............................................................................

   Programa: pc_obtem_contatos                 Antigo: b1wgen0049.p --> obtem-contatos
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Buscar os contatos do associado

   Alteracoes: 07/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

               02/06/2014 - Ajuste - Retornar NOK para Critica 9, pois não
                            deve parar o processo ( Renato - Supero )
  ............................................................................. */
  BEGIN
    DECLARE
      --Selecionar Avalista
      CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%type
                        ,pr_nrdconta IN crapavt.nrdconta%type
                        ,pr_tpctrato IN crapavt.tpctrato%type) IS
        SELECT crapavt.nrdctato
              ,crapavt.nmdavali
              ,crapavt.nrtelefo
              ,crapavt.dsdemail
              ,crapavt.rowid
              ,row_number() over (PARTITION BY crapavt.nrdctato
                                  ORDER BY crapavt.cdcooper
                                          ,crapavt.tpctrato
                                          ,crapavt.nrdconta
                                          ,crapavt.nrctremp
                                          ,crapavt.nrcpfcgc) seqreg
              ,COUNT(1) over (PARTITION BY crapavt.nrdctato) totreg
        FROM crapavt crapavt
        WHERE crapavt.cdcooper = pr_cdcooper
        AND   crapavt.nrdconta = pr_nrdconta
        AND   crapavt.tpctrato = pr_tpctrato;
      rw_crapavt cr_crapavt%ROWTYPE;
      --Selecionar Telefone
      CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%type
                        ,pr_nrdconta IN craptfc.nrdconta%type
                        ,pr_idseqttl IN craptfc.idseqttl%type) IS
        SELECT craptfc.nrdddtfc
              ,craptfc.nrtelefo
        FROM craptfc
        WHERE craptfc.cdcooper = pr_cdcooper
        AND   craptfc.nrdconta = pr_nrdconta
        AND   craptfc.idseqttl = pr_idseqttl
        ORDER BY craptfc.progress_recid ASC;
      rw_craptfc cr_craptfc%ROWTYPE;
      --Variaveis Locais
      vr_index    INTEGER;
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Limpar tabelas
      pr_tab_erro.DELETE;
      pr_tab_contato_juridica.DELETE;

      --Buscar a origem
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      --Buscar Transacao
      vr_dstransa:= 'Obtem contatos do associado';

      --Buscar Avalistas
      FOR rw_crapavt IN cr_crapavt (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_tpctrato => 5) LOOP
        --Montar Indice
        vr_index:= pr_tab_contato_juridica.COUNT + 1;
        --Inserir contato
        pr_tab_contato_juridica(vr_index).cddctato:= gene0002.fn_mask_conta(rw_crapavt.nrdctato);
        pr_tab_contato_juridica(vr_index).nrdctato:= rw_crapavt.nrdctato;
        pr_tab_contato_juridica(vr_index).nmdavali:= rw_crapavt.nmdavali;
        pr_tab_contato_juridica(vr_index).nrtelefo:= rw_crapavt.nrtelefo;
        pr_tab_contato_juridica(vr_index).dsdemail:= rw_crapavt.dsdemail;
        pr_tab_contato_juridica(vr_index).nrdrowid:= rw_crapavt.rowid;
        --Se possui contato
        IF rw_crapavt.nrdctato > 0 THEN
          --Selecionar Associado
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_crapavt.nrdctato);
          FETCH cr_crapass INTO rw_crapass;
          --Se nao encontrou associado
          IF cr_crapass%NOTFOUND THEN
            vr_cdcritic:= 9;
            vr_dscritic:= NULL;
            --Fechar Cursor
            CLOSE cr_crapass;
            --Gerar Erro
            GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1 /** Sequencia **/
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
            --Se for para gerar log
            IF pr_flgerlog THEN
              --gerar log
              GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_dsorigem => vr_dsorigem
                                  ,pr_dstransa => vr_dstransa
                                  ,pr_dttransa => SYSDATE
                                  ,pr_flgtrans => 0
                                  ,pr_hrtransa => GENE0002.fn_busca_time
                                  ,pr_idseqttl => pr_idseqttl
                                  ,pr_nmdatela => pr_nmdatela
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);
            END IF;

            -- Retornar apenas NOK
            vr_cdcritic:= NULL;
            vr_dscritic:= 'NOK';

            --Retornar Erro
            RAISE vr_exc_erro;
          END IF;
          --Fechar Cursor
          IF cr_crapass%ISOPEN THEN
            CLOSE cr_crapass;
          END IF;
          /** Nome Avalista **/
          pr_tab_contato_juridica(vr_index).nmdavali:= substr(rw_crapass.nmprimtl,1,50);
          /** Telefone **/
          OPEN cr_craptfc (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapavt.nrdctato
                          ,pr_idseqttl => 1);
          FETCH cr_craptfc INTO rw_craptfc;
          --Se encontrou
          IF cr_craptfc%FOUND THEN
            pr_tab_contato_juridica(vr_index).nrtelefo:= rw_craptfc.nrtelefo;
          ELSE
            pr_tab_contato_juridica(vr_index).nrtelefo:= NULL;
          END IF;
          --Fechar Cursor
          CLOSE cr_craptfc;
          /** E-Mail **/
          OPEN cr_crapcem (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapavt.nrdctato
                          ,pr_idseqttl => 1
                          ,pr_cddemail => 1);
          FETCH cr_crapcem INTO rw_crapcem;
          --Se encontrou
          IF cr_crapcem%FOUND THEN
            pr_tab_contato_juridica(vr_index).dsdemail:= rw_crapcem.dsdemail;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapcem;
        END IF;
      END LOOP;
      --Se deve escrever no Log
      IF pr_flgerlog THEN
        --gerar log
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => SYSDATE
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_obtem_contatos: ' || SQLERRM;
    END;
  END pc_obtem_contatos;

  /* Procedure para verificar se o cooperado é primeiro titular em outra conta */
  PROCEDURE pc_busca_conta (pr_cdcooper IN crapcop.cdcooper%type  --Codigo Cooperativa
                           ,pr_nrdconta IN crapass.nrdconta%type  --Numero da Conta
                           ,pr_nrcpfcgc IN crapass.nrcpfcgc%type  --Cpf/Cnpj da Conta
                           ,pr_idseqttl IN crapttl.idseqttl%type  --Sequencial Titular
                           ,pr_nrctattl OUT crapass.nrdconta%type --Numero da Conta Titular
                           ,pr_msgconta OUT VARCHAR2              --Mensagem da Conta
                           ,pr_cdcritic OUT INTEGER               --Codigo de erro
                           ,pr_dscritic OUT VARCHAR2) IS          --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_conta                 Antigo: b1wgen0077.p --> Busca_Conta
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Procedure para verificar se o cooperado é primeiro titular em outra conta

   Alteracoes: 08/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

  ............................................................................. */
  BEGIN
    DECLARE
      /** Cursores Locais **/

      --Selecionar contas de titular do cpf/cnpj
      CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                        ,pr_nrcpfcgc IN crapttl.nrcpfcgc%type
                        ,pr_idseqttl IN crapttl.idseqttl%type) IS
        SELECT crapttl.cdcooper
              ,crapttl.nrdconta
        FROM crapttl
        WHERE crapttl.cdcooper  = pr_cdcooper
        AND   crapttl.nrcpfcgc  = pr_nrcpfcgc
        AND   crapttl.idseqttl  = pr_idseqttl;
      --Selecionar contas de titular do cpf/cnpj
      CURSOR cr_crapttl2 (pr_cdcooper IN crapttl.cdcooper%type
                         ,pr_nrcpfcgc IN crapttl.nrcpfcgc%type
                         ,pr_idseqttl IN crapttl.idseqttl%type
                         ,pr_nrdconta IN crapttl.nrdconta%type) IS
        SELECT crapttl.cdcooper
              ,crapttl.nrdconta
        FROM crapttl
        WHERE crapttl.cdcooper  = pr_cdcooper
        AND   crapttl.nrcpfcgc  = pr_nrcpfcgc
        AND   crapttl.idseqttl  = pr_idseqttl
        AND   crapttl.nrdconta  = pr_nrdconta;
      rw_crapttl2 cr_crapttl2%ROWTYPE;
      --Selecionar Dados Associado
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%type
                        ,pr_nrdconta IN crapass.nrdconta%type) IS
        SELECT crapass.cdcooper
              ,crapass.nrdconta
              ,crapass.cdtipcta
        FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrdconta = pr_nrdconta
        AND   crapass.dtdemiss IS NULL
        AND   crapass.cdtipcta NOT IN (6,7,17,18); /** Ignora conta aplicacao **/
      --Selecionar Historico alteracoes na crapass
      CURSOR cr_crapalt (pr_cdcooper IN crapass.cdcooper%type
                        ,pr_nrdconta IN crapass.nrdconta%type) IS
        SELECT crapalt.nrdconta
              ,crapalt.dtaltera
        FROM crapalt
        WHERE crapalt.cdcooper = pr_cdcooper
        AND   crapalt.nrdconta = pr_nrdconta
        ORDER BY crapalt.progress_recid DESC;
      rw_crapalt cr_crapalt%ROWTYPE;
      --Variaveis Locais
      vr_dtaltera DATE:= to_date('01/01/0001','DD/MM/YYYY');
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Selecionar contas do titular
      FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper
                                   ,pr_nrcpfcgc => pr_nrcpfcgc
                                   ,pr_idseqttl => 1) LOOP
        --Selecionar associado
        FOR rw_crapass IN cr_crapass (pr_cdcooper => rw_crapttl.cdcooper
                                     ,pr_nrdconta => rw_crapttl.nrdconta) LOOP
          --Selecionar Historico alteracoes na crapass
          OPEN cr_crapalt (pr_cdcooper => rw_crapass.cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta);
          --Primeiro registro
          FETCH cr_crapalt INTO rw_crapalt;
          --Se encontrou
          IF cr_crapalt%FOUND THEN
            IF  rw_crapalt.dtaltera > vr_dtaltera THEN
              --Retornar Conta do titular
              pr_nrctattl:= rw_crapalt.nrdconta;
              --Data Alteracao
              vr_dtaltera:= rw_crapalt.dtaltera;
            END IF;
          ELSE
            --Se a conta esa
            IF nvl(pr_nrctattl,0) = 0 THEN
              pr_nrctattl:= rw_crapass.nrdconta;
            END IF;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapalt;
        END LOOP; --cr_crapass
      END LOOP; --cr_crapttl

      --Selecionar titulares
      IF pr_idseqttl <> 1 THEN
        OPEN cr_crapttl2 (pr_cdcooper => pr_cdcooper
                         ,pr_nrcpfcgc => pr_nrcpfcgc
                         ,pr_idseqttl => 1
                         ,pr_nrdconta => pr_nrctattl);
        FETCH cr_crapttl2 INTO rw_crapttl2;
        --Se encontrou
        IF cr_crapttl2%FOUND THEN
          --Montar mensagem
          pr_msgconta:= 'Dados deste titular somente podem ser '||
                        'alterados na conta: '||gene0002.fn_mask_conta(rw_crapttl2.nrdconta);
        END IF;
        --Fechar Cursor
        CLOSE cr_crapttl2;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_conta: ' || SQLERRM;
    END;
  END pc_busca_conta;

  /* Buscar Dados Associado - b1wgen0080 */
  PROCEDURE pc_busca_dados_ass_80 (pr_cdcooper IN crapcop.cdcooper%type     --Codigo Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%type     --Numero da Conta
                                  ,pr_idseqttl IN crapttl.idseqttl%type     --Sequencial Titular
                                  ,pr_nrdctato IN INTEGER                   --Numero Contato
                                  ,pr_tab_crapepa IN OUT typ_tab_crapepa    --Tabela Empresa participante
                                  ,pr_cdcritic OUT INTEGER                  --Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2) IS             --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_ass_80                 Antigo: b1wgen0080.p --> Busca_Dados_Ass
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Procedure para buscar dados empresa participante pelo Associado

   Alteracoes: 08/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

  ............................................................................. */
  BEGIN
    DECLARE
      /** Cursores Locais **/

      --Selecionar dados pessoa juridica
      CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%type
                        ,pr_nrdconta IN crapjur.nrdconta%type) IS
        SELECT crapjur.natjurid
              ,crapjur.nmfansia
              ,crapjur.cdrmativ
              ,crapjur.dsendweb
              ,crapjur.qtfilial
              ,crapjur.qtfuncio
              ,crapjur.dtiniatv
              ,crapjur.cdseteco
        FROM crapjur
        WHERE crapjur.cdcooper = pr_cdcooper
        AND   crapjur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;
      --Selecionar Valor do endividamento
      CURSOR cr_crapsdv (pr_cdcooper IN crapsdv.cdcooper%type
                        ,pr_nrdconta IN crapsdv.nrdconta%type) IS
        SELECT nvl(sum(nvl(crapsdv.vldsaldo,0)),0) total
        FROM crapsdv
        WHERE crapsdv.cdcooper = pr_cdcooper
        AND   crapsdv.nrdconta = pr_nrdconta
        AND   crapsdv.tpdsaldo IN (1,2,3,6);
      --Selecionar Empresa Participante
      CURSOR cr_crapepa (pr_cdcooper IN crapepa.cdcooper%type
                        ,pr_nrdconta IN crapepa.nrdconta%type
                        ,pr_nrdocsoc IN crapepa.nrdocsoc%type) IS
        SELECT crapepa.nrctasoc
              ,crapepa.cdcooper
              ,crapepa.nrdconta
              ,crapepa.vledvmto
              ,crapepa.dtadmiss
              ,crapepa.persocio
              ,crapepa.rowid
        FROM crapepa
        WHERE crapepa.cdcooper = pr_cdcooper
        AND   crapepa.nrdconta = pr_nrdconta
        AND   crapepa.nrdocsoc = pr_nrdocsoc
        ORDER BY crapepa.progress_recid ASC;
      rw_crapepa cr_crapepa%ROWTYPE;

      --Variaveis Locais
      vr_gncdntj BOOLEAN;
      vr_index   INTEGER;
      --Tabela Memoria Erro
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
      -- Guardar registro dstextab
      vr_dstextab craptab.dstextab%TYPE;      
      
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Limpar tabela erro
      vr_tab_erro.DELETE;
      --Selecionar Associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdctato);
      FETCH cr_crapass INTO rw_crapass;
      --Se encontrou
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        --Mensagem Erro
        vr_dscritic:= 'Associado nao cadastrado';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      --Selecionar Dados Pessoa Juridica
      OPEN cr_crapjur (pr_cdcooper => rw_crapass.cdcooper
                      ,pr_nrdconta => rw_crapass.nrdconta);
      FETCH cr_crapjur INTO rw_crapjur;
      --Se nao Encontrou
      IF cr_crapjur%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapjur;
        --Mensagem Erro
        vr_dscritic:= 'Dados da pessoa Juridica nao encontrados';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapjur;
      --Selecionar Cadastro Tipos de natureja juridica
      OPEN cr_gncdntj (pr_cdnatjur => rw_crapjur.natjurid);
      FETCH cr_gncdntj INTO rw_gncdntj;
      --Se Encontrou
      vr_gncdntj:= cr_gncdntj%FOUND;
      --Fechar Cursor
      CLOSE cr_gncdntj;

      --Encontrar Proximo Indice
      vr_index:= pr_tab_crapepa.COUNT+1;
      --Inserir empresa participante
      pr_tab_crapepa(vr_index).cddconta:= gene0002.fn_mask_conta(rw_crapass.nrdconta);
      pr_tab_crapepa(vr_index).cdcooper:= pr_cdcooper;
      pr_tab_crapepa(vr_index).nrdocsoc:= rw_crapass.nrcpfcgc;
      pr_tab_crapepa(vr_index).nrctasoc:= rw_crapass.nrdconta;
      pr_tab_crapepa(vr_index).nmprimtl:= rw_crapass.nmprimtl;
      pr_tab_crapepa(vr_index).cdcpfcgc:= gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,2);
      pr_tab_crapepa(vr_index).nmfansia:= rw_crapjur.nmfansia;
      pr_tab_crapepa(vr_index).natjurid:= rw_crapjur.natjurid;
      IF vr_gncdntj THEN
        pr_tab_crapepa(vr_index).dsnatjur:= rw_gncdntj.dsnatjur;
      ELSE
        pr_tab_crapepa(vr_index).dsnatjur:= 'Nao Cadastrado';
      END IF;
      pr_tab_crapepa(vr_index).cdrmativ:= rw_crapjur.cdrmativ;
      pr_tab_crapepa(vr_index).dsendweb:= rw_crapjur.dsendweb;
      pr_tab_crapepa(vr_index).qtfilial:= rw_crapjur.qtfilial;
      pr_tab_crapepa(vr_index).qtfuncio:= rw_crapjur.qtfuncio;
      pr_tab_crapepa(vr_index).dtiniatv:= rw_crapjur.dtiniatv;
      pr_tab_crapepa(vr_index).cdseteco:= rw_crapjur.cdseteco;

      --Se possuir setor economico
      IF nvl(pr_tab_crapepa(vr_index).cdseteco,0) <> 0 THEN
        -- Buscar configuração na tabela
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                        ,pr_cdacesso => 'SETORECONO'
                        ,pr_tpregist => pr_tab_crapepa(vr_index).cdseteco);
        
        
        --Se Encontrou
        IF TRIM(vr_dstextab) IS NOT NULL THEN
          pr_tab_crapepa(vr_index).nmseteco:= vr_dstextab;
        ELSE
          pr_tab_crapepa(vr_index).nmseteco:= 'Nao Cadastrado';
        END IF;

      END IF;
      --Se possuir Codigo Rumo Atividade e Setor Economico
      IF nvl(pr_tab_crapepa(vr_index).cdrmativ,0) <> 0 AND
         nvl(pr_tab_crapepa(vr_index).cdseteco,0) <> 0 THEN
        --Selecionar Rumo Atividade
        OPEN cr_gnrativ (pr_cdseteco => pr_tab_crapepa(vr_index).cdseteco
                        ,pr_cdrmativ => pr_tab_crapepa(vr_index).cdrmativ);
        --Primeiro Registro
        FETCH cr_gnrativ INTO rw_gnrativ;
        --Se Encontrou
        IF cr_gnrativ%FOUND THEN
          pr_tab_crapepa(vr_index).dsrmativ:= rw_gnrativ.nmrmativ;
        ELSE
          pr_tab_crapepa(vr_index).dsrmativ:= 'Nao Cadastrado';
        END IF;
        --Fechar Cursor
        CLOSE cr_gnrativ;
      END IF;
      /* Valor do endividamento */
      OPEN cr_crapsdv (pr_cdcooper => rw_crapass.cdcooper
                      ,pr_nrdconta => rw_crapass.nrdconta);
      FETCH cr_crapsdv INTO pr_tab_crapepa(vr_index).vledvmto;
      --Fechar Cursor
      CLOSE cr_crapsdv;

      --Selecionar Empresa Participativa
      OPEN cr_crapepa (pr_cdcooper => rw_crapass.cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrdocsoc => rw_crapass.nrcpfcgc);
      FETCH cr_crapepa INTO rw_crapepa;
      --Se Encontrou
      IF cr_crapepa%FOUND THEN
        pr_tab_crapepa(vr_index).nrdrowid:= rw_crapepa.rowid;
        pr_tab_crapepa(vr_index).persocio:= rw_crapepa.persocio;
        pr_tab_crapepa(vr_index).dtadmiss:= rw_crapepa.dtadmiss;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapepa;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_ass_80: ' || SQLERRM;
    END;
  END pc_busca_dados_ass_80;

  /* Buscar Dados pelo ID - b1wgen0080 */
  PROCEDURE pc_busca_dados_id_80 (pr_cdcooper IN crapcop.cdcooper%type     --Codigo Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%type     --Numero da Conta
                                 ,pr_nrdrowid IN ROWID                     --Rowid Empresa participante
                                 ,pr_cddopcao IN VARCHAR2                  --Codigo opcao
                                 ,pr_tab_crapepa IN OUT typ_tab_crapepa    --Tabela Empresa participante
                                 ,pr_cdcritic OUT INTEGER                  --Codigo de erro
                                 ,pr_dscritic OUT VARCHAR2) IS             --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_id_80                 Antigo: b1wgen0080.p --> Busca_Dados_Id
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Procedure para buscar dados empresa participante pelo rowid

   Alteracoes: 08/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

  ............................................................................. */
  BEGIN
    DECLARE
      /** Cursores Locais **/
      --Selecionar Empresa Participante
      CURSOR cr_crabepa (pr_rowid IN ROWID) IS
        SELECT crapepa.*
              ,crapepa.rowid
        FROM crapepa
        WHERE crapepa.rowid = pr_rowid;
      rw_crabepa cr_crabepa%ROWTYPE;
      --Selecionar Empresa Participante
      CURSOR cr_craeepa (pr_cdcooper IN crapepa.cdcooper%type
                        ,pr_nrdconta IN crapepa.nrdconta%type
                        ,pr_rowid    IN ROWID) IS
        SELECT crapepa.nrctasoc
              ,crapepa.cdcooper
              ,crapepa.nrdconta
              ,crapepa.vledvmto
              ,crapepa.dtadmiss
              ,crapepa.persocio
        FROM crapepa
        WHERE crapepa.cdcooper = pr_cdcooper
        AND   crapepa.nrdconta = pr_nrdconta
        AND   crapepa.rowid <> pr_rowid;
      rw_craeepa cr_craeepa%ROWTYPE;
      --Selecionar Avalistas
      CURSOR cr_craeavt (pr_cdcooper IN crapavt.cdcooper%type
                        ,pr_tpctrato IN crapavt.tpctrato%type
                        ,pr_nrdconta IN crapavt.nrdconta%type) IS
        SELECT crapavt.cdcooper
        FROM crapavt
        WHERE  crapavt.cdcooper = pr_cdcooper
        AND    crapavt.tpctrato = pr_tpctrato
        AND    crapavt.nrdconta = pr_nrdconta
        AND    crapavt.persocio > 0;
      rw_craeavt cr_craeavt%ROWTYPE;
      --Selecionar Associados pessoa Juridica
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%type
                       ,pr_nrdconta IN crapass.nrdconta%type) IS
        SELECT crapass.nrdconta
        FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrdconta = pr_nrdconta
        AND   crapass.inpessoa > 1;
      rw_crapass cr_crapass%ROWTYPE;
      
      --Variaveis Locais
      vr_crapass  BOOLEAN;
      vr_craeepa  BOOLEAN;
      vr_craeavt  BOOLEAN;
      vr_index    INTEGER;
      --Tabela Memoria Erro
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro    EXCEPTION;
      vr_exc_buscaid EXCEPTION;
      -- Guardar registro dstextab
      vr_dstextab craptab.dstextab%TYPE;      
      
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Bloco BuscaId
      BEGIN
        --Limpar tabela erro
        vr_tab_erro.DELETE;
        --Selecionar Empresa Participante
        OPEN cr_crabepa (pr_rowid => pr_nrdrowid);
        FETCH cr_crabepa INTO rw_crabepa;
        --Se nao encontrou
        IF cr_crabepa%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crabepa;
          --Mensagem erro
          vr_dscritic:= 'Empresa participante nao encontrado';
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crabepa;
        --Selecionar Associado
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        --Se nao encontrou associado
        vr_crapass:= cr_crapass%FOUND;
        --Fechar Cursor
        CLOSE cr_crapass;
        /* Verifica se ha mais de um socio pra poder excluir */
        IF pr_cddopcao = 'E' AND vr_crapass THEN
          --Selecionar outras empresas
          OPEN cr_craeepa (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_rowid    => pr_nrdrowid);
          FETCH cr_craeepa INTO rw_craeepa;
          --Se Encontrou
          vr_craeepa:= cr_craeepa%FOUND;
          --Fechar Cursor
          CLOSE cr_craeepa;
          --Se nao encontrou empresa
          IF NOT vr_craeepa THEN
            --Selecionar Avalistas
            OPEN cr_craeavt (pr_cdcooper => pr_cdcooper
                            ,pr_tpctrato => 6 /*jur*/
                            ,pr_nrdconta => pr_nrdconta);
            FETCH cr_craeavt INTO rw_craeavt;
            --Se Encontrou
            vr_craeavt:= cr_craeavt%FOUND;
            --Fechar Cursor
            CLOSE cr_craeavt;
          END IF;
          --nao possui outras empresas e avalistas
          IF NOT vr_craeepa AND NOT vr_craeavt THEN
            --Montar mensagem
            vr_dscritic:= 'Eh obrigatorio o cadastro de no minimo um socio.';
            RAISE vr_exc_erro;
          END IF;
        END IF; --pr_cddopcao = 'E'

        /* Se for associado, pega os dados da crapass */
        IF nvl(rw_crabepa.nrctasoc,0) <> 0 THEN
          --Buscar dados Associado
          pc_busca_dados_ass_80 (pr_cdcooper    => rw_crabepa.cdcooper     --Codigo Cooperativa
                                ,pr_nrdconta    => rw_crabepa.nrdconta     --Numero da Conta
                                ,pr_idseqttl    => 0                       --Sequencial Titular
                                ,pr_nrdctato    => rw_crabepa.nrctasoc     --Numero Contato
                                ,pr_tab_crapepa => pr_tab_crapepa          --Tabela Empresa participante
                                ,pr_cdcritic    => vr_cdcritic             --Codigo de erro
                                ,pr_dscritic    => vr_dscritic);           --Retorno de Erro
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        ELSE
          --Inserir empresa participante
          vr_index:= pr_tab_crapepa.COUNT+1;
          --Buffer-Copy
          pr_tab_crapepa(vr_index).cdcooper:= rw_crabepa.cdcooper;
          pr_tab_crapepa(vr_index).nrdocsoc:= rw_crabepa.nrdocsoc;
          pr_tab_crapepa(vr_index).nrctasoc:= rw_crabepa.nrctasoc;
          pr_tab_crapepa(vr_index).nmfansia:= rw_crabepa.nmfansia;
          pr_tab_crapepa(vr_index).nrinsest:= rw_crabepa.nrinsest;
          pr_tab_crapepa(vr_index).natjurid:= rw_crabepa.natjurid;
          pr_tab_crapepa(vr_index).dtiniatv:= rw_crabepa.dtiniatv;
          pr_tab_crapepa(vr_index).qtfilial:= rw_crabepa.qtfilial;
          pr_tab_crapepa(vr_index).qtfuncio:= rw_crabepa.qtfuncio;
          pr_tab_crapepa(vr_index).dsendweb:= rw_crabepa.dsendweb;
          pr_tab_crapepa(vr_index).cdseteco:= rw_crabepa.cdseteco;
          pr_tab_crapepa(vr_index).cdmodali:= rw_crabepa.cdmodali;
          pr_tab_crapepa(vr_index).cdrmativ:= rw_crabepa.cdrmativ;
          pr_tab_crapepa(vr_index).vledvmto:= rw_crabepa.vledvmto;
          pr_tab_crapepa(vr_index).dtadmiss:= rw_crabepa.dtadmiss;
          pr_tab_crapepa(vr_index).dtmvtolt:= rw_crabepa.dtmvtolt;
          pr_tab_crapepa(vr_index).persocio:= rw_crabepa.persocio;
          pr_tab_crapepa(vr_index).nmprimtl:= rw_crabepa.nmprimtl;
          --Bloco para tratar erro
          BEGIN
            pr_tab_crapepa(vr_index).cddconta:= gene0002.fn_mask_conta(rw_crabepa.nrctasoc);
            pr_tab_crapepa(vr_index).nrdrowid:= rw_crabepa.rowid;
            pr_tab_crapepa(vr_index).vledvmto:= rw_crabepa.vledvmto;
            pr_tab_crapepa(vr_index).cdcpfcgc:= gene0002.fn_mask_cpf_cnpj(rw_crabepa.nrdocsoc,2);
          EXCEPTION
            WHEN OTHERS THEN
              --Mensagem erro
              vr_dscritic:= 'Erro de conversao. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
          --Selecionar Cadastro Tipos de natureja juridica
          OPEN cr_gncdntj (pr_cdnatjur => rw_crabepa.natjurid);
          FETCH cr_gncdntj INTO rw_gncdntj;
          --Se Encontrou
          IF cr_gncdntj%FOUND THEN
            pr_tab_crapepa(vr_index).dsnatjur:= rw_gncdntj.dsnatjur;
          ELSE
            pr_tab_crapepa(vr_index).dsnatjur:= 'Nao Cadastrado';
          END IF;
          --Fechar Cursor
          CLOSE cr_gncdntj;
          --Se possuir setor economico
          IF nvl(pr_tab_crapepa(vr_index).cdseteco,0) <> 0 THEN

            -- Buscar configuração na tabela
            vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'GENERI'
                                                     ,pr_cdempres => 0
                            ,pr_cdacesso => 'SETORECONO'
                            ,pr_tpregist => pr_tab_crapepa(vr_index).cdseteco);
            
            
            --Se Encontrou
            IF TRIM(vr_dstextab) IS NOT NULL THEN
              pr_tab_crapepa(vr_index).nmseteco:= vr_dstextab;
            ELSE
              pr_tab_crapepa(vr_index).nmseteco:= 'Nao Cadastrado';
            END IF;
          END IF;
          --Se possuir Codigo Rumo Atividade e Setor Economico
          IF nvl(pr_tab_crapepa(vr_index).cdrmativ,0) <> 0 AND
             nvl(pr_tab_crapepa(vr_index).cdseteco,0) <> 0 THEN
            --Selecionar Rumo Atividade
            OPEN cr_gnrativ (pr_cdseteco => pr_tab_crapepa(vr_index).cdseteco
                            ,pr_cdrmativ => pr_tab_crapepa(vr_index).cdrmativ);
            --Primeiro Registro
            FETCH cr_gnrativ INTO rw_gnrativ;
            --Se Encontrou
            IF cr_gnrativ%FOUND THEN
              pr_tab_crapepa(vr_index).dsrmativ:= rw_gnrativ.nmrmativ;
            ELSE
              pr_tab_crapepa(vr_index).dsrmativ:= 'Nao Cadastrado';
            END IF;
            --Fechar Cursor
            CLOSE cr_gnrativ;
          END IF;
        END IF;
        --Se Encontrou dados na tabela memoria
        IF pr_tab_crapepa.COUNT > 0 THEN
          pr_tab_crapepa(pr_tab_crapepa.LAST).dtadmiss:= rw_crabepa.dtadmiss;
          pr_tab_crapepa(pr_tab_crapepa.LAST).persocio:= rw_crabepa.persocio;
        END IF;
      EXCEPTION
        WHEN vr_exc_buscaid THEN
          NULL;
      END;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_id_80: ' || SQLERRM;
    END;
  END pc_busca_dados_id_80;


  /* Buscar Dados pelo Contato - b1wgen0080 */
  PROCEDURE pc_busca_dados_cto_80 (pr_cdcooper IN crapcop.cdcooper%type     --Codigo Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%type     --Numero da Conta
                                  ,pr_idseqttl IN crapttl.idseqttl%type     --Sequencial Titular
                                  ,pr_nrdctato IN INTEGER                   --Numero Contato
                                  ,pr_nrcpfcto IN NUMBER                    --Numero Cpf Contato
                                  ,pr_cddopcao IN VARCHAR2                  --Codigo opcao
                                  ,pr_tab_crapepa IN OUT typ_tab_crapepa    --Tabela Empresa participante
                                  ,pr_cdcritic OUT INTEGER                  --Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2) IS             --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_cto_80                 Antigo: b1wgen0080.p --> Busca_Dados_Cto
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Procedure para buscar dados empresa participante pelo Contato

   Alteracoes: 08/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

  ............................................................................. */
  BEGIN
    DECLARE
      /** Cursores Locais **/

      --Selecionar Empresa Participante
      CURSOR cr_crabepa (pr_cdcooper IN crapepa.cdcooper%type
                        ,pr_nrdconta IN crapepa.nrdconta%type
                        ,pr_nrdocsoc IN crapepa.nrdocsoc%type) IS
        SELECT crapepa.nrctasoc
              ,crapepa.cdcooper
              ,crapepa.nrdconta
              ,crapepa.vledvmto
              ,crapepa.dtadmiss
              ,crapepa.persocio
        FROM crapepa
        WHERE crapepa.cdcooper = pr_cdcooper
        AND   crapepa.nrdconta = pr_nrdconta
        AND   crapepa.nrdocsoc = pr_nrdocsoc;
      rw_crabepa cr_crabepa%ROWTYPE;
      --Selecionar Empresa Participante
      CURSOR cr_crabepa2 (pr_cdcooper IN crapepa.cdcooper%type
                         ,pr_nrdconta IN crapepa.nrdconta%type
                         ,pr_nrctasoc IN crapepa.nrctasoc%type) IS
        SELECT crapepa.nrctasoc
              ,crapepa.cdcooper
              ,crapepa.nrdconta
              ,crapepa.vledvmto
              ,crapepa.dtadmiss
              ,crapepa.persocio
        FROM crapepa
        WHERE crapepa.cdcooper = pr_cdcooper
        AND   crapepa.nrdconta = pr_nrdconta
        AND   crapepa.nrctasoc = pr_nrctasoc;
      rw_crabepa2 cr_crabepa2%ROWTYPE;
      --Selecionar Associado
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%type
                        ,pr_nrdconta IN crapass.nrdconta%type) IS
        SELECT crapass.cdcooper
              ,crapass.nrdconta
              ,crapass.nrcpfcgc
              ,crapass.inpessoa
        FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrdconta = pr_nrdconta
        ORDER BY crapass.progress_recid ASC;
      rw_crabass cr_crapass%ROWTYPE;
      --Selecionar Associado
      CURSOR cr_crapass2 (pr_cdcooper IN crapass.cdcooper%type
                         ,pr_nrcpfcgc IN crapass.nrcpfcgc%type) IS
        SELECT crapass.cdcooper
              ,crapass.nrdconta
              ,crapass.nrcpfcgc
              ,crapass.inpessoa
        FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrcpfcgc = pr_nrcpfcgc
        ORDER BY crapass.progress_recid ASC;

      --Variaveis Locais
      vr_crapass BOOLEAN;
      --Tabela Memoria Erro
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Limpar Tabela Memoria
      vr_tab_erro.DELETE;

      --Verificar Inclusao
      IF pr_cddopcao = 'I' THEN
        /* Busca se o procurador ja foi cadastrado - CPF */
        IF nvl(pr_nrcpfcto,0) <> 0 THEN
          --Selecionar outras empresas
          OPEN cr_crabepa (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdocsoc => pr_nrcpfcto);
          FETCH cr_crabepa INTO rw_crabepa;
          --Se Encontrou
          IF cr_crabepa%FOUND THEN
            --Fechar Cursor
            CLOSE cr_crabepa;
            vr_dscritic:= 'Participante ja cadastrado para o associado.';
            RAISE vr_exc_erro;
          END IF;
          --Fechar Cursor
          CLOSE cr_crabepa;
        END IF;
        /* Busca se o procurador ja foi cadastrado - NR.DA CONTA */
        IF nvl(pr_nrdctato,0) <> 0 THEN
          --Selecionar outras empresas
          OPEN cr_crabepa2 (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctasoc => pr_nrdctato);
          FETCH cr_crabepa2 INTO rw_crabepa2;
          --Se Encontrou
          IF cr_crabepa2%FOUND THEN
            --Fechar Cursor
            CLOSE cr_crabepa2;
            vr_dscritic:= 'Participante ja cadastrado para o associado.';
            RAISE vr_exc_erro;
          END IF;
          --Fechar Cursor
          CLOSE cr_crabepa2;
        END IF;
      END IF;
      /* efetua a busca tanto por nr da conta como por cpf */
      IF nvl(pr_nrdctato,0) <> 0 THEN
        --Selecionar Associado
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdctato);
        FETCH cr_crapass INTO rw_crabass;
        vr_crapass:= cr_crapass%FOUND;
        --Fechar Cursor
        CLOSE cr_crapass;
      ELSIF nvl(pr_nrcpfcto,0) <> 0 THEN
        --Selecionar Associado
        OPEN cr_crapass2 (pr_cdcooper => pr_cdcooper
                         ,pr_nrcpfcgc => pr_nrcpfcto);
        FETCH cr_crapass2 INTO rw_crabass;
        --Se achou
        vr_crapass:= cr_crapass2%FOUND;
        --Fechar Cursor
        CLOSE cr_crapass2;
      END IF;
      --Se Encontrou associado
      IF NOT vr_crapass THEN
        --Se contato preenchido
        IF nvl(pr_nrdctato,0) <> 0 THEN
          vr_cdcritic:= 9;
        END IF;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Verificar se participante é titular da conta
      IF pr_nrdconta = rw_crabass.nrdconta THEN
        vr_dscritic:= 'Titular da conta nao pode ser participante.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      /* somente pessoa juridica */
      IF rw_crabass.inpessoa = 1 THEN
        vr_cdcritic:= 331;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Buscar Dados Associados
      pc_busca_dados_ass_80 (pr_cdcooper    => rw_crabass.cdcooper --Codigo Cooperativa
                            ,pr_nrdconta    => pr_nrdconta         --Numero da Conta
                            ,pr_idseqttl    => pr_idseqttl         --Sequencial Titular
                            ,pr_nrdctato    => rw_crabass.nrdconta --Numero Contato
                            ,pr_tab_crapepa => pr_tab_crapepa      --Tabela Empresa participante
                            ,pr_cdcritic    => vr_cdcritic         --Codigo de erro
                            ,pr_dscritic    => vr_dscritic);       --Retorno de Erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_cto_80: ' || SQLERRM;
    END;
  END pc_busca_dados_cto_80;

  /* Buscar os Dados das Empresas Participantes */
  PROCEDURE pc_busca_dados_80 (pr_cdcooper IN crapcop.cdcooper%type  --Codigo Cooperativa
                              ,pr_cdagenci IN crapass.cdagenci%type  --Codigo Agencia
                              ,pr_nrdcaixa IN INTEGER                --Numero Caixa
                              ,pr_cdoperad IN VARCHAR2               --Codigo Operador
                              ,pr_nmdatela IN VARCHAR2               --Nome Tela
                              ,pr_idorigem IN INTEGER                --Origem da chamada
                              ,pr_nrdconta IN crapass.nrdconta%type  --Numero da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%type  --Sequencial Titular
                              ,pr_flgerlog IN BOOLEAN                --Erro no Log
                              ,pr_cddopcao IN VARCHAR2               --Codigo opcao
                              ,pr_nrdctato IN INTEGER                --Numero Contato
                              ,pr_nrcpfcto IN NUMBER                 --Numero Cpf Contato
                              ,pr_nrdrowid IN ROWID                  --Rowid Empresa participante
                              ,pr_tab_crapepa OUT typ_tab_crapepa    --Tabela Empresa Paticipante
                              ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erro
                              ,pr_cdcritic OUT INTEGER               --Codigo de erro
                              ,pr_dscritic OUT VARCHAR2) IS          --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_80                 Antigo: b1wgen0080.p --> Busca_Dados
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Buscar os contatos do associado

   Alteracoes: 07/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

  ............................................................................. */
  BEGIN
    DECLARE
      /* Cursores Locais */
      --Selecionar Empresas Participantes
      CURSOR cr_crapepa (pr_cdcooper IN crapepa.cdcooper%type
                        ,pr_nrdconta IN crapepa.nrdconta%type) IS
        SELECT crapepa.rowid
        FROM crapepa
        WHERE crapepa.cdcooper = pr_cdcooper
        AND   crapepa.nrdconta = pr_nrdconta;

      --Variaveis Locais
      vr_nrdrowid ROWID;
      vr_indtrans INTEGER;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      --Tabela memoria erros
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_cdcritic2 crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      vr_dscritic2 VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro   EXCEPTION;
      vr_exc_busca  EXCEPTION;
      vr_exc_filtro EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Limpar tabelas
      pr_tab_erro.DELETE;
      pr_tab_crapepa.DELETE;

      --Buscar a origem
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      --Buscar Transacao
      vr_dstransa:= 'Busca dados da empresa participante';

      --Bloco Busca
      BEGIN
        --Bloco Filtro
        BEGIN
          --Se o rowid da empresa foi informado
          IF pr_nrdrowid IS NOT NULL THEN
            --Buscar Dados pelo ID
            pc_busca_dados_id_80 (pr_cdcooper => pr_cdcooper     --Codigo Cooperativa
                                 ,pr_nrdconta => pr_nrdconta     --Numero da Conta
                                 ,pr_nrdrowid => pr_nrdrowid     --Rowid Empresa participante
                                 ,pr_cddopcao => pr_cddopcao     --Codigo opcao
                                 ,pr_tab_crapepa => pr_tab_crapepa --Tabela Empresas Participantes
                                 ,pr_cdcritic => vr_cdcritic     --Codigo de erro
                                 ,pr_dscritic => vr_dscritic);   --Retorno de Erro
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_filtro;
            END IF;
          ELSE
            --Numero contato e cpf contato preenchido
            IF nvl(pr_nrdctato,0) <> 0 OR nvl(pr_nrcpfcto,0) <> 0 THEN
              --Buscar Dados Empresa participante pela conta Contato
              pc_busca_dados_cto_80 (pr_cdcooper => pr_cdcooper     --Codigo Cooperativa
                                    ,pr_nrdconta => pr_nrdconta     --Numero da Conta
                                    ,pr_idseqttl => pr_idseqttl     --Sequencial Titular
                                    ,pr_nrdctato => pr_nrdctato     --Numero Contato
                                    ,pr_nrcpfcto => pr_nrcpfcto     --Numero Cpf Contato
                                    ,pr_cddopcao => pr_cddopcao     --Codigo opcao
                                    ,pr_tab_crapepa => pr_tab_crapepa    --Tabela Empresa participante
                                    ,pr_cdcritic => vr_cdcritic     --Codigo de erro
                                    ,pr_dscritic => vr_dscritic);   --Retorno de Erro
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_filtro;
              END IF;
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_filtro THEN
            NULL;
        END; --Filtro Busca
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_busca;
        END IF;
        --Opcao
        IF pr_cddopcao <> 'C' THEN
          RAISE vr_exc_busca;
        END IF;
        /* se encontrou registros na pesquisa [C], nao e preciso o for each */
        IF pr_tab_crapepa.count > 0 THEN
          RAISE vr_exc_busca;
        END IF;
        /* Carrega a lista de procuradores */
        FOR rw_crapepa IN cr_crapepa (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta) LOOP
          --Buscar Dados pelo ID
          pc_busca_dados_id_80 (pr_cdcooper => pr_cdcooper       --Codigo Cooperativa
                               ,pr_nrdconta => pr_nrdconta       --Numero da Conta
                               ,pr_nrdrowid => rw_crapepa.rowid  --Rowid Empresa participante
                               ,pr_cddopcao => pr_cddopcao       --Codigo opcao
                               ,pr_tab_crapepa => pr_tab_crapepa --Tabela Empresas Participantes
                               ,pr_cdcritic => vr_cdcritic       --Codigo de erro
                               ,pr_dscritic => vr_dscritic);     --Retorno de Erro
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_busca;
          END IF;
        END LOOP;
      EXCEPTION
        WHEN vr_exc_busca THEN
          NULL;
      END; --Busca

      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Gerar Erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => vr_cdcritic2
                             ,pr_dscritic => vr_dscritic2
                             ,pr_tab_erro => vr_tab_erro);
        --Se ocorreu erro
        IF vr_cdcritic2 IS NOT NULL OR vr_dscritic2 IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Marcar flag erro
        vr_indtrans:= 0;
      ELSE
        vr_indtrans:= 1;
      END IF;

      --Se deve escrever no Log
      IF pr_flgerlog AND pr_cddopcao = 'C' THEN
        --Gerar log
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => SYSDATE
                          ,pr_flgtrans => vr_indtrans
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_80: ' || SQLERRM;
    END;
  END pc_busca_dados_80;

  /* Buscar Dados pela Conta Contato - b1wgen0073 */
  PROCEDURE pc_busca_dados_cto_73 (pr_cdcooper IN crapcop.cdcooper%type     --Codigo Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%type     --Numero da Conta
                                  ,pr_nrctremp IN crapavt.nrctremp%type     --Numero Contrato Emprestimo
                                  ,pr_nrdctato IN INTEGER                   --Numero Conta Contato
                                  ,pr_cddopcao IN VARCHAR2                  --Codigo opcao
                                  ,pr_tab_crapavt IN OUT typ_tab_crapavt    --Tabela Avalistas
                                  ,pr_cdcritic OUT INTEGER                  --Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2) IS             --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_cto_73                 Antigo: b1wgen0073.p --> Busca_Dados_Cto
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Procedure para buscar dados empresa participante pela conta Contato

   Alteracoes: 09/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

  ............................................................................. */
  BEGIN
    DECLARE
      /** Cursores Locais **/
      --Selecionar Avalistas
      CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%type
                        ,pr_tpctrato IN crapavt.tpctrato%type
                        ,pr_nrdconta IN crapavt.nrdconta%type
                        ,pr_nrctremp IN crapavt.nrctremp%type
                        ,pr_nrdctato IN crapavt.nrdctato%type) IS
        SELECT crapavt.rowid
              ,crapavt.nrdctato
              ,crapavt.nmdavali
              ,crapavt.nrtelefo
              ,crapavt.dsdemail
        FROM crapavt
        WHERE crapavt.cdcooper = pr_cdcooper
        AND   crapavt.tpctrato = pr_tpctrato
        AND   crapavt.nrdconta = pr_nrdconta
        AND   crapavt.nrctremp = pr_nrctremp
        AND   crapavt.nrdctato = pr_nrdctato
        ORDER BY crapavt.progress_recid ASC;
      rw_crapavt cr_crapavt%ROWTYPE;
      --Selecionar Endereco
      CURSOR cr_crapenc (pr_cdcooper IN crapenc.cdcooper%type
                        ,pr_nrdconta IN crapenc.nrdconta%type
                        ,pr_idseqttl IN crapenc.idseqttl%type
                        ,pr_cdseqinc IN crapenc.cdseqinc%type) IS
        SELECT crapenc.nrcepend
              ,crapenc.dsendere
              ,crapenc.nrendere
              ,crapenc.complend
              ,crapenc.nmbairro
              ,crapenc.nmcidade
              ,crapenc.cdufende
              ,crapenc.nrcxapst
        FROM crapenc
        WHERE crapenc.cdcooper = pr_cdcooper
        AND   crapenc.nrdconta = pr_nrdconta
        AND   crapenc.idseqttl = pr_idseqttl
        AND   crapenc.cdseqinc = pr_cdseqinc;
      rw_crapenc cr_crapenc%ROWTYPE;

      --Variaveis Locais
      vr_index INTEGER;
      --Tabela Memoria Erro
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Limpar Tabela Memoria
      vr_tab_erro.DELETE;
      pr_tab_crapavt.DELETE;

      /* nao pode ter no mesmo nr. da conta do associado */
      IF pr_nrdctato = pr_nrdconta THEN
        vr_cdcritic:= 121;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      /* verificar se o resp.legal ja esta cadastrado */
      IF pr_cddopcao = 'I' AND nvl(pr_nrdctato,0) <> 0 THEN
        --Selecionar Avalista
        OPEN cr_crapavt (pr_cdcooper => pr_cdcooper
                        ,pr_tpctrato => 5 /*contato*/
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctremp => pr_nrctremp
                        ,pr_nrdctato => pr_nrdctato);
        FETCH cr_crapavt INTO rw_crapavt;
        --Se Encontrou
        IF cr_crapavt%FOUND THEN
          --Fechar Cursor
          CLOSE cr_crapavt;
          --Mensagem Erro
          vr_dscritic:= 'Contato ja existente para a conta';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapavt;
      END IF;
      --Selecionar Associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdctato);
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        vr_cdcritic:= 9;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      --Verificar cadastro incompleto
      IF rw_crapass.indnivel < 2 AND rw_crapass.cdtipcta > 7 THEN
        --Mensagem Critica
        vr_dscritic:= 'Contato com cadastro incompleto';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Encontrar proximo indice para tabela
      vr_index:= pr_tab_crapavt.count+1;
      /* Endereco */
      OPEN cr_crapenc (pr_cdcooper => rw_crapass.cdcooper
                      ,pr_nrdconta => rw_crapass.nrdconta
                      ,pr_idseqttl => 1
                      ,pr_cdseqinc => 1);
      FETCH cr_crapenc INTO rw_crapenc;
      --Se Encontrou
      IF cr_crapenc%FOUND THEN
        pr_tab_crapavt(vr_index).nrcepend:= rw_crapenc.nrcepend;
        pr_tab_crapavt(vr_index).dsendere:= rw_crapenc.dsendere;
        pr_tab_crapavt(vr_index).nrendere:= rw_crapenc.nrendere;
        pr_tab_crapavt(vr_index).complend:= rw_crapenc.complend;
        pr_tab_crapavt(vr_index).nmbairro:= rw_crapenc.nmbairro;
        pr_tab_crapavt(vr_index).nmcidade:= rw_crapenc.nmcidade;
        pr_tab_crapavt(vr_index).cdufende:= UPPER(rw_crapenc.cdufende);
        pr_tab_crapavt(vr_index).nrcxapst:= rw_crapenc.nrcxapst;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapenc;
      /* Telefones */
      OPEN cr_craptfc (pr_cdcooper => rw_crapass.cdcooper
                      ,pr_nrdconta => rw_crapass.nrdconta
                      ,pr_idseqttl => 1
                      ,pr_cdseqtfc => 1);
      FETCH cr_craptfc INTO rw_craptfc;
      --Se encontrou
      IF cr_craptfc%FOUND THEN
        pr_tab_crapavt(vr_index).nrtelefo:= rw_craptfc.nrtelefo;
      END IF;
      --Fechar Cursor
      CLOSE cr_craptfc;
      /* Emails */
      OPEN cr_crapcem (pr_cdcooper => rw_crapass.cdcooper
                      ,pr_nrdconta => rw_crapass.nrdconta
                      ,pr_idseqttl => 1
                      ,pr_cddemail => 1);
      FETCH cr_crapcem INTO rw_crapcem;
      --Se encontrou
      IF cr_crapcem%FOUND THEN
        pr_tab_crapavt(vr_index).dsdemail:= rw_crapcem.dsdemail;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcem;
      --Inserir dados na tabela
      pr_tab_crapavt(vr_index).nrdctato:= rw_crapass.nrdconta;
      pr_tab_crapavt(vr_index).nmdavali:= substr(rw_crapass.nmprimtl,1,50);

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_cto_73: ' || SQLERRM;
    END;
  END pc_busca_dados_cto_73;

  /* Buscar Dados pelo ID - b1wgen0073 */
  PROCEDURE pc_busca_dados_id_73 (pr_cdcooper IN crapcop.cdcooper%type     --Codigo Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%type     --Numero da Conta
                                 ,pr_nrctremp IN INTEGER                   --Numero Contrato Emprestimo
                                 ,pr_nrdrowid IN ROWID                     --Rowid Empresa participante
                                 ,pr_cddopcao IN VARCHAR2                  --Codigo opcao
                                 ,pr_tab_crapavt IN OUT typ_tab_crapavt    --Tabela Empresa participante
                                 ,pr_cdcritic OUT INTEGER                  --Codigo de erro
                                 ,pr_dscritic OUT VARCHAR2) IS             --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_id_73                 Antigo: b1wgen0073.p --> Busca_Dados_Id
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Procedure para buscar dados empresa participante pelo rowid

   Alteracoes: 08/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

  ............................................................................. */
  BEGIN
    DECLARE
      /** Cursores Locais **/
      CURSOR cr_crapavt (pr_rowid IN ROWID) IS
        SELECT crapavt.*
              ,crapavt.rowid
        FROM crapavt
        WHERE crapavt.rowid = pr_rowid;
      rw_crapavt cr_crapavt%ROWTYPE;
      --Selecionar Avalistas
      CURSOR cr_crapavt2 (pr_cdcooper IN crapavt.cdcooper%type
                         ,pr_nrdconta IN crapavt.nrdconta%type
                         ,pr_tpctrato IN crapavt.tpctrato%type
                         ,pr_nrctremp IN crapavt.nrctremp%type
                         ,pr_nrdctato IN crapavt.nrdctato%type
                         ,pr_rowid    IN ROWID) IS
        SELECT crapavt.cdcooper
        FROM crapavt
        WHERE crapavt.cdcooper = pr_cdcooper
        AND   crapavt.nrdconta = pr_nrdconta
        AND   crapavt.tpctrato = pr_tpctrato
        AND   crapavt.nrctremp = pr_nrctremp
        AND   crapavt.nrdctato <> pr_nrdctato
        AND   crapavt.rowid    <> pr_nrdrowid
        ORDER BY crapavt.progress_recid ASC;
      rw_crapavt2 cr_crapavt2%ROWTYPE;
      --Variaveis Locais
      vr_index    INTEGER;
      --Tabela Memoria Erro
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro    EXCEPTION;
      vr_exc_buscaid EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Limpar tabela erro
      vr_tab_erro.DELETE;
      --Selecionar Empresa Participante
      OPEN cr_crapavt (pr_rowid => pr_nrdrowid);
      FETCH cr_crapavt INTO rw_crapavt;
      --Se nao encontrou
      IF cr_crapavt%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapavt;
        --Mensagem erro
        vr_dscritic:= 'Contato nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapavt;
      --Se o contato nao estiver preenchido
      IF nvl(rw_crapavt.nrdctato,0) = 0 THEN
        --Inserir Contato
        vr_index:= pr_tab_crapavt.COUNT+1;
        --Gravar Informacoes
        pr_tab_crapavt(vr_index).nrdctato:= rw_crapavt.nrdctato;
        pr_tab_crapavt(vr_index).nmdavali:= rw_crapavt.nmdavali;
        pr_tab_crapavt(vr_index).nrcepend:= rw_crapavt.nrcepend;
        pr_tab_crapavt(vr_index).dsendere:= rw_crapavt.dsendres##1;
        pr_tab_crapavt(vr_index).nrendere:= rw_crapavt.nrendere;
        pr_tab_crapavt(vr_index).complend:= rw_crapavt.complend;
        pr_tab_crapavt(vr_index).nmbairro:= rw_crapavt.nmbairro;
        pr_tab_crapavt(vr_index).nmcidade:= rw_crapavt.nmcidade;
        pr_tab_crapavt(vr_index).cdufende:= upper(rw_crapavt.cdufresd);
        pr_tab_crapavt(vr_index).nrcxapst:= rw_crapavt.nrcxapst;
        pr_tab_crapavt(vr_index).nrtelefo:= rw_crapavt.nrtelefo;
        pr_tab_crapavt(vr_index).dsdemail:= rw_crapavt.dsdemail;
        pr_tab_crapavt(vr_index).nrdrowid:= rw_crapavt.rowid;
      ELSE
        --Verificar Opcao
        CASE pr_cddopcao
          WHEN 'A' THEN
            vr_dscritic:= 'Nao e possivel alterar um contato que e associado da cooperativa.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          WHEN 'E' THEN
            /* Para o 1o titular, verifica se existe mais contatos cooperados */
            IF rw_crapavt.nrctremp = 1 THEN
              OPEN cr_crapavt2 (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_tpctrato => 5
                               ,pr_nrctremp => pr_nrctremp
                               ,pr_nrdctato => 0
                               ,pr_rowid    => pr_nrdrowid);
              FETCH cr_crapavt2 INTO rw_crapavt2;
              --Se nao Encontou
              IF cr_crapavt2%NOTFOUND THEN
                --Fechar Cursor
                CLOSE cr_crapavt2;
                --Mensagem Erro
                vr_dscritic:= 'Deve existir pelo menos 1 contato cooperado';
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              --Fechar Cursor
              CLOSE cr_crapavt2;
            END IF;
          ELSE NULL;
        END CASE;
        --Buscar Dados pelo Contato
        pc_busca_dados_cto_73 (pr_cdcooper => rw_crapavt.cdcooper     --Codigo Cooperativa
                              ,pr_nrdconta => rw_crapavt.nrdconta     --Numero da Conta
                              ,pr_nrctremp => rw_crapavt.nrctremp     --Numero Contrato Emprestimo
                              ,pr_nrdctato => rw_crapavt.nrdctato     --Numero Contato
                              ,pr_cddopcao => pr_cddopcao             --Codigo opcao
                              ,pr_tab_crapavt => pr_tab_crapavt       --Tabela Avalistas
                              ,pr_cdcritic => vr_cdcritic             --Codigo de erro
                              ,pr_dscritic => vr_dscritic);           --Retorno de Erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Se a tabela de memoria possuir registros
      IF pr_tab_crapavt.COUNT > 0 THEN
        pr_tab_crapavt(pr_tab_crapavt.LAST).nrdrowid:= rw_crapavt.rowid;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_id_73: ' || SQLERRM;
    END;
  END pc_busca_dados_id_73;


  /* Buscar dados dos avalistas do associado */
  PROCEDURE pc_busca_dados_73 (pr_cdcooper IN crapcop.cdcooper%type --Codigo Cooperativa
                              ,pr_cdagenci IN crapass.cdagenci%type --Codigo Agencia
                              ,pr_nrdcaixa IN INTEGER               --Numero Caixa
                              ,pr_cdoperad IN VARCHAR2              --Codigo Operador
                              ,pr_nmdatela IN VARCHAR2              --Nome Tela
                              ,pr_idorigem IN INTEGER               --Origem da chamada
                              ,pr_nrdconta IN crapass.nrdconta%type --Numero da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%type --Sequencial Titular
                              ,pr_flgerlog IN BOOLEAN               --Erro no Log
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%type --Data Movimento
                              ,pr_cddopcao IN VARCHAR2              --Codigo opcao
                              ,pr_nrdctato IN INTEGER               --Numero Contato
                              ,pr_nrdrowid IN ROWID                 --Rowid Empresa participante
                              ,pr_tab_crapavt OUT typ_tab_crapavt   --Tabela Avalistas
                              ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erro
                              ,pr_cdcritic OUT INTEGER              --Codigo de erro
                              ,pr_dscritic OUT VARCHAR2) IS         --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_73                 Antigo: b1wgen0073.p --> Busca_Dados
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Buscar dados dos avalistas do associado

   Alteracoes: 09/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

  ............................................................................. */
  BEGIN
    DECLARE
      /* Cursores Locais */
      --Selecionar Avalistas
      CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%type
                        ,pr_tpctrato IN crapavt.tpctrato%type
                        ,pr_nrdconta IN crapavt.nrdconta%type
                        ,pr_nrctremp IN crapavt.nrctremp%type) IS
        SELECT crapavt.rowid
              ,crapavt.nrdctato
              ,crapavt.nmdavali
              ,crapavt.nrtelefo
              ,crapavt.dsdemail
        FROM crapavt
        WHERE crapavt.cdcooper = pr_cdcooper
        AND   crapavt.tpctrato = pr_tpctrato
        AND   crapavt.nrdconta = pr_nrdconta
        AND   crapavt.nrctremp = pr_nrctremp;
      --Variaveis Locais
      vr_nrdrowid ROWID;
      vr_index    INTEGER;
      vr_indtrans INTEGER;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      --Tabela memoria erros
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_cdcritic2 crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      vr_dscritic2 VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro   EXCEPTION;
      vr_exc_busca  EXCEPTION;
      vr_exc_filtro EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Limpar tabelas
      pr_tab_erro.DELETE;
      pr_tab_crapavt.DELETE;

      --Buscar a origem
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      --Buscar Transacao
      vr_dstransa:= 'Busca dados do Contato';

      --Bloco Busca
      BEGIN
        --Bloco Filtro
        BEGIN
          --Se o rowid do avalista foi informado
          IF pr_nrdrowid IS NOT NULL THEN
            --Buscar Dados pelo ID
            pc_busca_dados_id_73 (pr_cdcooper => pr_cdcooper     --Codigo Cooperativa
                                 ,pr_nrdconta => pr_nrdconta     --Numero da Conta
                                 ,pr_nrctremp => pr_idseqttl     --Sequencial Titular
                                 ,pr_nrdrowid => pr_nrdrowid     --Rowid Empresa participante
                                 ,pr_cddopcao => pr_cddopcao     --Codigo opcao
                                 ,pr_tab_crapavt => pr_tab_crapavt --Tabela Empresas Participantes
                                 ,pr_cdcritic => vr_cdcritic     --Codigo de erro
                                 ,pr_dscritic => vr_dscritic);   --Retorno de Erro
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_filtro;
            END IF;
          ELSE
            --Numero contato e cpf contato preenchido
            IF nvl(pr_nrdctato,0) <> 0 THEN
              --Buscar Dados pelo ID
              pc_busca_dados_cto_73 (pr_cdcooper => pr_cdcooper       --Codigo Cooperativa
                                    ,pr_nrdconta => pr_nrdconta       --Numero da Conta
                                    ,pr_nrctremp => pr_idseqttl       --Sequencial Titular
                                    ,pr_nrdctato => pr_nrdctato       --Numero Contato
                                    ,pr_cddopcao => pr_cddopcao       --Codigo opcao
                                    ,pr_tab_crapavt => pr_tab_crapavt --Tabela Empresa participante
                                    ,pr_cdcritic => vr_cdcritic       --Codigo de erro
                                    ,pr_dscritic => vr_dscritic);     --Retorno de Erro
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_filtro;
              END IF;
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_filtro THEN
            NULL;
        END; --Filtro Busca
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_busca;
        END IF;
        --Opcao
        IF pr_cddopcao <> 'C' THEN
          RAISE vr_exc_busca;
        END IF;

        /* Carrega a lista de contatos */
        FOR rw_crapavt IN cr_crapavt (pr_cdcooper => pr_cdcooper
                                     ,pr_tpctrato => 5 /*contato*/
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctremp => pr_idseqttl) LOOP
          --Incrementar Indice para tabela memoria
          vr_index:= pr_tab_crapavt.count+1;
          --Carregar tabela memoria
          pr_tab_crapavt(vr_index).cddctato:= gene0002.fn_mask_conta(rw_crapavt.nrdctato);
          pr_tab_crapavt(vr_index).nrdctato:= rw_crapavt.nrdctato;
          pr_tab_crapavt(vr_index).nmdavali:= rw_crapavt.nmdavali;
          pr_tab_crapavt(vr_index).nrtelefo:= rw_crapavt.nrtelefo;
          pr_tab_crapavt(vr_index).dsdemail:= rw_crapavt.dsdemail;
          pr_tab_crapavt(vr_index).dsdemiss:= FALSE;
          pr_tab_crapavt(vr_index).nrdrowid:= rw_crapavt.rowid;
          /* Se for associado, pega os dados da crapass */
          IF nvl(rw_crapavt.nrdctato,0) <> 0 THEN
            --Selecionar Associado
            OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_crapavt.nrdctato);
            FETCH cr_crapass INTO rw_crapass;
            --Se Encontrou
            IF cr_crapass%FOUND THEN
              --Nome Primeiro Titular
              pr_tab_crapavt(vr_index).nmdavali:= substr(rw_crapass.nmprimtl,1,50);
              --Se a Data Nao for nula
              IF rw_crapass.dtdemiss IS NOT NULL THEN
                pr_tab_crapavt(vr_index).dsdemiss:= TRUE;
              ELSE
                pr_tab_crapavt(vr_index).dsdemiss:= FALSE;
              END IF;
              /* Telefones */
              OPEN cr_craptfc (pr_cdcooper => rw_crapass.cdcooper
                              ,pr_nrdconta => rw_crapass.nrdconta
                              ,pr_idseqttl => 1
                              ,pr_cdseqtfc => 1);
              FETCH cr_craptfc INTO rw_craptfc;
              --Se encontrou
              IF cr_craptfc%FOUND THEN
                pr_tab_crapavt(vr_index).nrtelefo:= rw_craptfc.nrtelefo;
              ELSE
                pr_tab_crapavt(vr_index).nrtelefo:= NULL;
              END IF;
              --Fechar Cursor
              CLOSE cr_craptfc;
              /* Emails */
              OPEN cr_crapcem (pr_cdcooper => rw_crapass.cdcooper
                              ,pr_nrdconta => rw_crapass.nrdconta
                              ,pr_idseqttl => 1
                              ,pr_cddemail => 1);
              FETCH cr_crapcem INTO rw_crapcem;
              --Se encontrou
              IF cr_crapcem%FOUND THEN
                pr_tab_crapavt(vr_index).dsdemail:= rw_crapcem.dsdemail;
              END IF;
              --Fechar Cursor
              CLOSE cr_crapcem;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapass;
          END IF;
        END LOOP;
      EXCEPTION
        WHEN vr_exc_busca THEN
          NULL;
      END; --Busca

      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Gerar Erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => vr_cdcritic2
                             ,pr_dscritic => vr_dscritic2
                             ,pr_tab_erro => vr_tab_erro);
        --Se ocorreu erro
        IF vr_cdcritic2 IS NOT NULL OR vr_dscritic2 IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Marcar flag erro
        vr_indtrans:= 0;
      ELSE
        vr_indtrans:= 1;
      END IF;

      --Se deve escrever no Log
      IF pr_flgerlog AND pr_cddopcao = 'C' THEN
        --Gerar log
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => SYSDATE
                          ,pr_flgtrans => vr_indtrans
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_73, Conta: '||pr_nrdconta||'. Erro: ' || SQLERRM;
    END;
  END pc_busca_dados_73;

  /* Buscar Dados dos representantes legais pela conta Contato - b1wgen0072 */
  PROCEDURE pc_busca_dados_cto_72 (pr_cdcooper IN crapcop.cdcooper%type     --Codigo Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%type     --Numero da Conta
                                  ,pr_nrctremp IN crapavt.nrctremp%type     --Numero Contrato Emprestimo
                                  ,pr_nrdctato IN INTEGER                   --Numero Contato
                                  ,pr_nrcpfcto IN NUMBER                    --Numero Cpf Contato
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%type     --Data Movimento
                                  ,pr_cddopcao IN VARCHAR2                  --Codigo opcao
                                  ,pr_cpfprocu IN NUMBER                    --Cpf Procurador
                                  ,pr_verconta IN BOOLEAN                   --Verificar Conta
                                  ,pr_nmrotina IN VARCHAR2                  --Nome Rotina
                                  ,pr_tab_crapcrl IN OUT typ_tab_crapcrl    --Tabela Representantes Legais
                                  ,pr_cdcritic OUT INTEGER                  --Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2) IS             --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_cto_72                 Antigo: b1wgen0072.p --> Busca_Dados_Cto
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao: 24/07/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Procedure para buscar dados empresa participante pelo Contato

   Alteracoes: 09/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

               02/06/2014 - Removido os campos cdestcvl e vlsalari da crapass e
                            adicionados na crapttl. (Douglas - Chamado 131253)
                            
               01/03/2016 - Adicionado SUBSTR para os campos nmrespon, nmpairsp, nmmaersp
                            que são carregados da crapttl, e que possuem tamanho de campos
                            diferentes (Douglas - Chamado 410909)

               17/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 
               24/07/2017 - Alterar cdoedptl para idorgexp.
                            PRJ339-CRM  (Odirlei-AMcom)             

  ............................................................................. */
  BEGIN
    DECLARE
      --Cursores Locais
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%type
                        ,pr_nrdconta IN crapass.nrdconta%type) IS
        SELECT crapass.inpessoa
              ,crapass.cdtipcta
              ,crapass.dtdemiss
              ,crapass.nrdconta
              ,crapass.cdcooper
              ,crapass.nrcpfcgc
        FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrdconta = pr_nrdconta;
      --Selecionar associado pelo cpf
      CURSOR cr_crapass_cpf (pr_cdcooper IN crapass.cdcooper%type
                            ,pr_nrcpfcgc IN crapass.nrcpfcgc%type) IS
        SELECT crapass.inpessoa
              ,crapass.cdtipcta
              ,crapass.dtdemiss
              ,crapass.nrdconta
              ,crapass.cdcooper
              ,crapass.nrcpfcgc
        FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrcpfcgc = pr_nrcpfcgc
        ORDER BY crapass.progress_recid ASC;
      rw_crapass cr_crapass%ROWTYPE;
      --Selecionar contas de titular do cpf/cnpj
      CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                        ,pr_nrdconta IN crapttl.nrdconta%type
                        ,pr_idseqttl IN crapttl.idseqttl%type) IS
        SELECT crapttl.nmextttl
              ,crapttl.nrdocttl
              ,crapttl.idorgexp
              ,crapttl.cdufdttl
              ,crapttl.dtemdttl
              ,crapttl.dtnasttl
              ,crapttl.cdsexotl
              ,crapttl.cdestcvl
              ,crapttl.cdnacion
              ,crapttl.dsnatura
              ,crapttl.nmpaittl
              ,crapttl.nmmaettl
              ,crapttl.tpdocttl
        FROM crapttl
        WHERE crapttl.cdcooper  = pr_cdcooper
        AND   crapttl.nrdconta  = pr_nrdconta
        AND   crapttl.idseqttl  = pr_idseqttl
        ORDER BY crapttl.progress_recid ASC;
      rw_crapttl cr_crapttl%ROWTYPE;

      --Selecionar contas de titular do cpf/cnpj
      CURSOR cr_crapttl2 (pr_cdcooper IN crapttl.cdcooper%type
                         ,pr_nrdconta IN crapttl.nrdconta%type) IS
        SELECT crapttl.cdcooper
              ,crapttl.nrdconta
              ,crapttl.dtnasttl
              ,crapttl.inhabmen
              ,crapttl.nrcpfcgc
              ,crapttl.indnivel
        FROM crapttl
        WHERE crapttl.cdcooper  = pr_cdcooper
        AND   crapttl.nrdconta  = pr_nrdconta
        AND   crapttl.indnivel  <> 4;
      rw_crapttl2 cr_crapttl2%ROWTYPE;
      --Selecionar Endereco
      CURSOR cr_crapenc (pr_cdcooper IN crapenc.cdcooper%type
                        ,pr_nrdconta IN crapenc.nrdconta%type
                        ,pr_idseqttl IN crapenc.idseqttl%type
                        ,pr_cdseqinc IN crapenc.cdseqinc%TYPE
                        ,pr_tpendass IN crapenc.tpendass%type) IS
        SELECT crapenc.nrendere
              ,crapenc.complend
              ,crapenc.nrcepend
              ,crapenc.dsendere
              ,crapenc.nmbairro
              ,crapenc.nmcidade
              ,crapenc.cdufende
              ,crapenc.nrcxapst
        FROM crapenc
        WHERE crapenc.cdcooper = pr_cdcooper
        AND   crapenc.nrdconta = pr_nrdconta
        AND   crapenc.idseqttl = pr_idseqttl
        AND   crapenc.cdseqinc = pr_cdseqinc
        AND   crapenc.tpendass = pr_tpendass
        ORDER BY crapenc.progress_recid ASC;
      rw_crapenc cr_crapenc%ROWTYPE;
      --Selecionar representante legal
      CURSOR cr_crapcrl (pr_cdcooper IN crapcrl.cdcooper%type
                        ,pr_nrctamen IN crapcrl.nrctamen%type
                        ,pr_nrcpfmen IN crapcrl.nrcpfmen%type
                        ,pr_idseqmen IN crapcrl.idseqmen%type
                        ,pr_nrdconta IN crapcrl.nrdconta%type
                        ,pr_nrcpfcgc IN crapcrl.nrcpfcgc%type) IS
        SELECT crapcrl.cdcooper
        FROM crapcrl
        WHERE crapcrl.cdcooper = pr_cdcooper
        AND   crapcrl.nrctamen = pr_nrdconta
        AND   crapcrl.nrcpfmen = pr_cpfprocu
        AND   crapcrl.idseqmen = pr_nrctremp
        AND   crapcrl.nrdconta = pr_nrdctato
        AND   crapcrl.nrcpfcgc = pr_nrcpfcto;
      rw_crapcrl cr_crapcrl%ROWTYPE;
      --Variaveis Locais
      vr_flgsuces BOOLEAN;
      vr_crapass  BOOLEAN;
      vr_index    INTEGER;
      --Tabela memoria erros
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro   EXCEPTION;
      vr_exc_busca  EXCEPTION;
      vr_exc_filtro EXCEPTION;
      
      vr_nmorgexp   tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
      
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Limpar Tabela Memoria
      vr_tab_erro.DELETE;

      /* nao pode ter no mesmo nr. da conta do associado */
      IF pr_verconta THEN
        IF (Nvl(pr_nrdctato,0) <> 0 AND Nvl(pr_nrdconta,0) <> 0 AND
            pr_cddopcao <> 'E' AND Nvl(pr_nrdctato,0) = Nvl(pr_nrdconta,0)) THEN
          vr_cdcritic:= 121;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      /* verificar se o resp.legal ja esta cadastrado */
      IF pr_cddopcao = 'A' AND nvl(pr_nrdctato,0) <> 0 THEN
        --Selecionar Associado
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdctato);
        FETCH cr_crapass INTO rw_crapass;
        --Se Encontrou
        IF cr_crapass%FOUND THEN
          --Fechar Cursor
          CLOSE cr_crapass;
          --Mensagem Erro
          vr_dscritic:= 'Nao e permitido alterar dados do associado!';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapass;
      END IF;
      /* efetua a busca tanto por nr da conta como por cpf */
      IF Nvl(pr_nrdctato,0) <> 0  THEN
        --Selecionar Associado
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdctato);
        FETCH cr_crapass INTO rw_crapass;
        --Verificar se encontrou
        vr_crapass:= cr_crapass%FOUND;
        --Fechar Cursor
        CLOSE cr_crapass;
      ELSIF Nvl(pr_nrcpfcto,0) <> 0 THEN
        --Selecionar associado por cpf/cgc
        OPEN cr_crapass_cpf (pr_cdcooper => pr_cdcooper
                            ,pr_nrcpfcgc => pr_nrcpfcto);
        FETCH cr_crapass_cpf INTO rw_crapass;
        --Verificar se encontrou
        vr_crapass:=cr_crapass_cpf%FOUND;
        --Fechar Cursor
        CLOSE cr_crapass_cpf;
      END IF;
      --Verificar cadastro incompleto
      IF NOT vr_crapass THEN
        IF Nvl(pr_nrdctato,0) <> 0 THEN
          vr_cdcritic:= 9;
          RAISE vr_exc_erro;
        ELSIF (Nvl(pr_nrcpfcto,0) <> 0 AND Nvl(pr_cpfprocu,0) <> 0) AND
               Nvl(pr_nrcpfcto,0) = Nvl(pr_cpfprocu,0) THEN
          --Mensagem Critica
          vr_dscritic:= 'CPF do Responsavel deve ser diferente do CPF Repres./Procurador.';
        END IF;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Se for pessoa fisica
      IF rw_crapass.inpessoa <> 1 THEN
        vr_cdcritic:= 833;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Marcar Sucesso
      vr_flgsuces:= TRUE;

      --Tipo da Conta
      IF rw_crapass.cdtipcta >= 12 THEN
        --Selecionar Titulares
        OPEN cr_crapttl2 (pr_cdcooper => rw_crapass.cdcooper
                         ,pr_nrdconta => rw_crapass.nrdconta);
        FETCH cr_crapttl2 INTO rw_crapttl2;
        --Se Encontrou
        IF cr_crapttl2%FOUND THEN
          vr_flgsuces:= FALSE;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapttl2;
      END IF;
      --Se Nao obteve sucesso
      IF NOT vr_flgsuces AND rw_crapass.dtdemiss IS NULL AND rw_crapass.nrdconta <> Nvl(pr_nrdctato,0) THEN
        --Critica
        vr_cdcritic:= 830;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Criar Registro Representante Legal
      vr_index:= pr_tab_crapcrl.COUNT+1;
      --Inserir Representante Legal
      pr_tab_crapcrl(vr_index).cdcooper:= rw_crapass.cdcooper;
      pr_tab_crapcrl(vr_index).nrctamen:= pr_nrdconta;
      pr_tab_crapcrl(vr_index).nrcpfmen:= pr_cpfprocu;
      pr_tab_crapcrl(vr_index).nrdconta:= rw_crapass.nrdconta;
      pr_tab_crapcrl(vr_index).nrcpfcgc:= rw_crapass.nrcpfcgc;
      pr_tab_crapcrl(vr_index).idseqmen:= pr_nrctremp;
      pr_tab_crapcrl(vr_index).cddopcao:= pr_cddopcao;

      /* 1o. Titular */
      OPEN cr_crapttl (pr_cdcooper => rw_crapass.cdcooper
                      ,pr_nrdconta => rw_crapass.nrdconta
                      ,pr_idseqttl => 1);
      FETCH cr_crapttl INTO rw_crapttl;
      --Se Encontrou
      IF cr_crapttl%FOUND THEN
        -- Busca a Nacionalidade
        vr_dsnacion := '';
        OPEN  cr_crapnac(pr_cdnacion => rw_crapttl.cdnacion);
        FETCH cr_crapnac INTO vr_dsnacion;
        CLOSE cr_crapnac;

        pr_tab_crapcrl(vr_index).nmrespon:= SUBSTR(rw_crapttl.nmextttl,1,40);
        pr_tab_crapcrl(vr_index).nridenti:= rw_crapttl.nrdocttl;
        pr_tab_crapcrl(vr_index).cdufiden:= rw_crapttl.cdufdttl;
        pr_tab_crapcrl(vr_index).dtemiden:= rw_crapttl.dtemdttl;
        pr_tab_crapcrl(vr_index).dtnascin:= rw_crapttl.dtnasttl;
        pr_tab_crapcrl(vr_index).cddosexo:= rw_crapttl.cdsexotl;
        pr_tab_crapcrl(vr_index).cdestciv:= rw_crapttl.cdestcvl;
        pr_tab_crapcrl(vr_index).cdnacion:= rw_crapttl.cdnacion;
        pr_tab_crapcrl(vr_index).dsnacion:= vr_dsnacion;
        pr_tab_crapcrl(vr_index).dsnatura:= rw_crapttl.dsnatura;
        pr_tab_crapcrl(vr_index).nmpairsp:= SUBSTR(rw_crapttl.nmpaittl,1,64);
        pr_tab_crapcrl(vr_index).nmmaersp:= SUBSTR(rw_crapttl.nmmaettl,1,64);
        pr_tab_crapcrl(vr_index).tpdeiden:= rw_crapttl.tpdocttl;

        --> Buscar orgão expedidor
        pr_tab_crapcrl(vr_index).dsorgemi := NULL;
        cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapttl.idorgexp, 
                                          pr_cdorgao_expedidor => pr_tab_crapcrl(vr_index).dsorgemi, 
                                          pr_nmorgao_expedidor => vr_nmorgexp, 
                                          pr_cdcritic          => vr_cdcritic, 
                                          pr_dscritic          => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          pr_tab_crapcrl(vr_index).dsorgemi := 'NAO CADAST';
          vr_nmorgexp := NULL; 
        END IF; 

        /* validar a idade */
        IF cada0001.fn_Busca_Idade(pr_dtnascto => rw_crapttl.dtnasttl
                                  ,pr_dtmvtolt => pr_dtmvtolt) < 18 THEN
          --Numero Contato informado
          IF Nvl(pr_nrdctato,0) <> 0 THEN
            --Montar Critica
            vr_cdcritic:= 585;
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSIF Nvl(pr_nrcpfcto,0) <> 0 THEN
            --Montar Critica
            vr_cdcritic:= 806;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF; --cr_crapttl

      /* Endereco Residencial */
      OPEN cr_crapenc (pr_cdcooper => rw_crapass.cdcooper
                      ,pr_nrdconta => rw_crapass.nrdconta
                      ,pr_idseqttl => 1
                      ,pr_cdseqinc => 1
                      ,pr_tpendass => 10); /*Residencial*/
      FETCH cr_crapenc INTO rw_crapenc;
      --Se Encontrou
      IF cr_crapenc%FOUND THEN
        pr_tab_crapcrl(vr_index).nrendres:= rw_crapenc.nrendere;
        pr_tab_crapcrl(vr_index).dscomres:= rw_crapenc.complend;
        pr_tab_crapcrl(vr_index).cdcepres:= rw_crapenc.nrcepend;
        pr_tab_crapcrl(vr_index).dsendres:= rw_crapenc.dsendere;
        pr_tab_crapcrl(vr_index).dsbaires:= rw_crapenc.nmbairro;
        pr_tab_crapcrl(vr_index).dscidres:= rw_crapenc.nmcidade;
        pr_tab_crapcrl(vr_index).dsdufres:= rw_crapenc.cdufende;
        pr_tab_crapcrl(vr_index).nrcxpost:= rw_crapenc.nrcxapst;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapenc;

      /* Estado civil */
      OPEN cr_gnetcvl (pr_cdestcvl => pr_tab_crapcrl(vr_index).cdestciv);
      FETCH cr_gnetcvl INTO rw_gnetcvl;
      --Se Encontrou
      IF cr_gnetcvl%FOUND THEN
        --Descricao estado Civil
        pr_tab_crapcrl(vr_index).dsestcvl:= rw_gnetcvl.rsestcvl;
      END IF;
      --Fechar Cursor
      CLOSE cr_gnetcvl;

      --Checar Inclusao e Nome Rotina
      IF pr_cddopcao = 'I' AND pr_nmrotina = 'RESPONSAVEL LEGAL' THEN
        --Selecionar representante legal
        OPEN cr_crapcrl (pr_cdcooper => pr_cdcooper
                        ,pr_nrctamen => pr_nrdconta
                        ,pr_nrcpfmen => pr_cpfprocu
                        ,pr_idseqmen => pr_nrctremp
                        ,pr_nrdconta => pr_nrdctato
                        ,pr_nrcpfcgc => pr_nrcpfcto);
        FETCH cr_crapcrl INTO rw_crapcrl;
        --Se encontrou
        IF cr_crapcrl%FOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcrl;
          --Mensagem critica
          vr_dscritic:= 'Responsavel legal ja cadastrado.';
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapcrl;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_cto_72: ' || SQLERRM;
    END;
  END pc_busca_dados_cto_72;

  /* Buscar Dados Representantes Legais pelo ID - b1wgen0072 */
  PROCEDURE pc_busca_dados_id_72 (pr_cdcooper IN crapcop.cdcooper%type     --Codigo Cooperativa
                                 ,pr_nrdrowid IN ROWID                     --Rowid Representante Legal
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%type     --Data Movimento
                                 ,pr_cddopcao IN VARCHAR2                  --Codigo opcao
                                 ,pr_nmrotina IN VARCHAR2                  --Nome Rotina
                                 ,pr_tab_crapcrl IN OUT typ_tab_crapcrl    --Tabela Representantes Legais
                                 ,pr_cdcritic OUT INTEGER                  --Codigo de erro
                                 ,pr_dscritic OUT VARCHAR2) IS             --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_id_72                 Antigo: b1wgen0072.p --> Busca_Dados_Id
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao: 17/04/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Procedure para buscar dados empresa participante pelo rowid

   Alteracoes: 10/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

               17/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)

  ............................................................................. */
  BEGIN
    DECLARE
      /** Cursores Locais **/
      --Selecionar Representante Legal
      CURSOR cr_crapcrl (pr_rowid IN ROWID) IS
        SELECT crapcrl.*
              ,crapcrl.rowid
        FROM crapcrl
        WHERE crapcrl.ROWID = pr_rowid;
      rw_crapcrl cr_crapcrl%ROWTYPE;
      --Variaveis Locais
      vr_index    INTEGER;
      vr_flgcadas BOOLEAN:= FALSE;
      vr_nmorgexp tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
      --Tabela Memoria Erro
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro    EXCEPTION;
      vr_exc_buscaid EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Limpar tabela erro
      vr_tab_erro.DELETE;

      --Selecionar Empresa Participante
      OPEN cr_crapcrl (pr_rowid => pr_nrdrowid);
      FETCH cr_crapcrl INTO rw_crapcrl;
      --Se nao encontrou
      IF cr_crapcrl%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcrl;
        --Mensagem erro
        vr_dscritic:= 'Responsavel legal nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcrl;
      --Se o contato nao estiver preenchido
      IF nvl(rw_crapcrl.nrdconta,0) = 0 THEN
        --Selecionar Associado
        OPEN cr_crapass(pr_cdcooper => rw_crapcrl.cdcooper
                       ,pr_nrdconta => rw_crapcrl.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        --Se encontrou
        IF cr_crapass%FOUND THEN
          --Verificar opcao Alteracao
          IF pr_cddopcao = 'A' THEN
            --Fechar Cursor
            CLOSE cr_crapass;
            vr_dscritic:= 'Nao e permitido alterar dados do associado!';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          --Marcar Cadastro
          vr_flgcadas:= TRUE;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapass;
      END IF;

      --Se nao Cadastrado
      IF NOT vr_flgcadas THEN
        --Buscar proximo Indice
        vr_index:= pr_tab_crapcrl.COUNT+1;

        -- Busca a Nacionalidade
        vr_dsnacion := '';
        OPEN  cr_crapnac(pr_cdnacion => rw_crapcrl.cdnacion);
        FETCH cr_crapnac INTO vr_dsnacion;
        CLOSE cr_crapnac;

        --Inserir Representante Legal
        pr_tab_crapcrl(vr_index).cddopcao:= pr_cddopcao;
        pr_tab_crapcrl(vr_index).cdcooper:= rw_crapcrl.cdcooper;
        pr_tab_crapcrl(vr_index).nrctamen:= rw_crapcrl.nrctamen;
        pr_tab_crapcrl(vr_index).nrcpfmen:= rw_crapcrl.nrcpfmen;
        pr_tab_crapcrl(vr_index).idseqmen:= rw_crapcrl.idseqmen;
        pr_tab_crapcrl(vr_index).nrdconta:= rw_crapcrl.nrdconta;
        pr_tab_crapcrl(vr_index).nrcpfcgc:= rw_crapcrl.nrcpfcgc;
        pr_tab_crapcrl(vr_index).nmrespon:= rw_crapcrl.nmrespon;
        pr_tab_crapcrl(vr_index).nridenti:= rw_crapcrl.nridenti;
        pr_tab_crapcrl(vr_index).tpdeiden:= rw_crapcrl.tpdeiden;
        pr_tab_crapcrl(vr_index).cdufiden:= rw_crapcrl.cdufiden;
        pr_tab_crapcrl(vr_index).dtemiden:= rw_crapcrl.dtemiden;
        pr_tab_crapcrl(vr_index).dtnascin:= rw_crapcrl.dtnascin;
        pr_tab_crapcrl(vr_index).cddosexo:= rw_crapcrl.cddosexo;
        pr_tab_crapcrl(vr_index).cdestciv:= rw_crapcrl.cdestciv;
        pr_tab_crapcrl(vr_index).cdnacion:= rw_crapcrl.cdnacion;
        pr_tab_crapcrl(vr_index).dsnacion:= vr_dsnacion;
        pr_tab_crapcrl(vr_index).dsnatura:= rw_crapcrl.dsnatura;
        pr_tab_crapcrl(vr_index).cdcepres:= rw_crapcrl.cdcepres;
        pr_tab_crapcrl(vr_index).dsendres:= rw_crapcrl.dsendres;
        pr_tab_crapcrl(vr_index).nrendres:= rw_crapcrl.nrendres;
        pr_tab_crapcrl(vr_index).dscomres:= rw_crapcrl.dscomres;
        pr_tab_crapcrl(vr_index).dsbaires:= rw_crapcrl.dsbaires;
        pr_tab_crapcrl(vr_index).nrcxpost:= rw_crapcrl.nrcxpost;
        pr_tab_crapcrl(vr_index).dscidres:= rw_crapcrl.dscidres;
        pr_tab_crapcrl(vr_index).dsdufres:= rw_crapcrl.dsdufres;
        pr_tab_crapcrl(vr_index).nmpairsp:= rw_crapcrl.nmpairsp;
        pr_tab_crapcrl(vr_index).nmmaersp:= rw_crapcrl.nmmaersp;
        
        --> Buscar orgão expedidor
        pr_tab_crapcrl(vr_index).dsorgemi := NULL;
        cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapcrl.idorgexp, 
                                          pr_cdorgao_expedidor => pr_tab_crapcrl(vr_index).dsorgemi, 
                                          pr_nmorgao_expedidor => vr_nmorgexp, 
                                          pr_cdcritic          => vr_cdcritic, 
                                          pr_dscritic          => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          pr_tab_crapcrl(vr_index).dsorgemi := 'NAO CADAST';
          vr_nmorgexp := NULL; 
        END IF; 
        
        /* Estado civil */
        OPEN cr_gnetcvl (pr_cdestcvl => rw_crapcrl.cdestciv);
        FETCH cr_gnetcvl INTO rw_gnetcvl;
        --Se Encontrou
        IF cr_gnetcvl%FOUND THEN
          --Descricao estado Civil
          pr_tab_crapcrl(vr_index).dsestcvl:= rw_gnetcvl.rsestcvl;
        END IF;
        --Fechar Cursor
        CLOSE cr_gnetcvl;
      ELSE
        --Verificar opcao Alteracao
        IF pr_cddopcao = 'A' THEN
          vr_dscritic:= 'Nao e permitido alterar dados do associado!';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Buscar Dados
        pc_busca_dados_cto_72 (pr_cdcooper => rw_crapcrl.cdcooper   --Codigo Cooperativa
                              ,pr_nrdconta => rw_crapcrl.nrctamen   --Numero da Conta
                              ,pr_nrctremp => rw_crapcrl.idseqmen   --Numero Contrato Emprestimo
                              ,pr_nrdctato => rw_crapcrl.nrdconta   --Numero Contato
                              ,pr_nrcpfcto => rw_crapcrl.nrcpfcgc   --Numero Cpf Contato
                              ,pr_dtmvtolt => pr_dtmvtolt           --Data Movimento
                              ,pr_cddopcao => pr_cddopcao           --Codigo opcao
                              ,pr_cpfprocu => rw_crapcrl.nrcpfmen   --Cpf Procurador
                              ,pr_verconta => TRUE                  --Verificar Conta
                              ,pr_nmrotina => pr_nmrotina           --Nome Rotina
                              ,pr_tab_crapcrl => pr_tab_crapcrl     --Tabela Representantes Legais
                              ,pr_cdcritic => vr_cdcritic           --Codigo de erro
                              ,pr_dscritic => vr_dscritic);         --Retorno de Erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_id_72: ' || SQLERRM;
    END;
  END pc_busca_dados_id_72;


  /* Buscar dados dos Responsaveis Legais do associado */
  PROCEDURE pc_busca_dados_72 (pr_cdcooper IN crapcop.cdcooper%type --Codigo Cooperativa
                              ,pr_cdagenci IN crapass.cdagenci%type --Codigo Agencia
                              ,pr_nrdcaixa IN INTEGER               --Numero Caixa
                              ,pr_cdoperad IN VARCHAR2              --Codigo Operador
                              ,pr_nmdatela IN VARCHAR2              --Nome Tela
                              ,pr_idorigem IN INTEGER               --Origem da chamada
                              ,pr_nrdconta IN crapass.nrdconta%type --Numero da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%type --Sequencial Titular
                              ,pr_flgerlog IN BOOLEAN               --Erro no Log
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%type --Data Movimento
                              ,pr_cddopcao IN VARCHAR2              --Codigo opcao
                              ,pr_nrdctato IN INTEGER               --Numero Contato
                              ,pr_nrcpfcto IN NUMBER                --Numero Cpf Contato
                              ,pr_nrdrowid IN ROWID                 --Rowid Responsavel
                              ,pr_cpfprocu IN NUMBER                --Cpf Procurador
                              ,pr_nmrotina IN VARCHAR2              --Nome da Rotina
                              ,pr_dtdenasc IN DATE                  --Data Nascimento
                              ,pr_cdhabmen IN INTEGER               --Codigo Habilitacao
                              ,pr_permalte IN BOOLEAN               --Flag Permanece/Altera
                              ,pr_menorida OUT BOOLEAN              --Flag Menor idade
                              ,pr_msgconta OUT VARCHAR2             --Mensagem Conta
                              ,pr_tab_crapcrl OUT typ_tab_crapcrl   --Tabela Representantes Legais
                              ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erro
                              ,pr_cdcritic OUT INTEGER              --Codigo de erro
                              ,pr_dscritic OUT VARCHAR2) IS         --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_72                 Antigo: b1wgen0072.p --> Busca_Dados
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao: 17/04/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Buscar dados dos Responsaveis Legais do associado

   Alteracoes: 10/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

               17/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)

  ............................................................................. */
  BEGIN
    DECLARE
      /* Cursores Locais */
      --Selecionar contas de titular do cpf/cnpj
      CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                        ,pr_nrdconta IN crapttl.nrdconta%type
                        ,pr_idseqttl IN crapttl.idseqttl%type) IS
        SELECT crapttl.cdcooper
              ,crapttl.nrdconta
              ,crapttl.dtnasttl
              ,crapttl.inhabmen
              ,crapttl.nrcpfcgc
        FROM crapttl
        WHERE crapttl.cdcooper  = pr_cdcooper
        AND   crapttl.nrdconta  = pr_nrdconta
        AND   crapttl.idseqttl  = pr_idseqttl
        ORDER BY crapttl.progress_recid ASC;
      rw_crapttl cr_crapttl%ROWTYPE;
      --Selecionar Responsavel Legal
      CURSOR cr_crapcrl (pr_cdcooper IN crapcrl.cdcooper%type
                        ,pr_nrctamen IN crapcrl.nrctamen%type
                        ,pr_nrcpfmen IN crapcrl.nrcpfmen%type
                        ,pr_idseqmen IN crapcrl.idseqmen%type
                        ,pr_nrdrowid IN ROWID) IS
        SELECT crapcrl.cdcooper
        FROM crapcrl
        WHERE crapcrl.cdcooper = pr_cdcooper
        AND   crapcrl.nrctamen = pr_nrctamen
        AND   crapcrl.nrcpfmen = pr_nrcpfmen
        AND   crapcrl.idseqmen = pr_idseqmen
        AND   crapcrl.ROWID    <> pr_nrdrowid
        ORDER BY crapcrl.progress_recid ASC;
      rw_crapcrl cr_crapcrl%ROWTYPE;
      --Selecionar Responsavel Legal
      CURSOR cr_crapcrl2 (pr_cdcooper IN crapcrl.cdcooper%type
                         ,pr_nrctamen IN crapcrl.nrctamen%type
                         ,pr_nrcpfmen IN crapcrl.nrcpfmen%type
                         ,pr_idseqmen IN crapcrl.idseqmen%type) IS
        SELECT crapcrl.cdcooper
              ,crapcrl.nrctamen
              ,crapcrl.idseqmen
              ,crapcrl.nrdconta
              ,crapcrl.nrcpfcgc
              ,crapcrl.nrcpfmen
              ,crapcrl.nmrespon
              ,crapcrl.nridenti
              ,crapcrl.tpdeiden
              ,crapcrl.idorgexp
              ,crapcrl.cdufiden
              ,crapcrl.dtemiden
              ,crapcrl.dtnascin
              ,crapcrl.cddosexo
              ,crapcrl.cdestciv
              ,crapcrl.cdnacion
              ,crapcrl.dsnatura
              ,crapcrl.cdcepres
              ,crapcrl.dsendres
              ,crapcrl.nrendres
              ,crapcrl.dscomres
              ,crapcrl.dsbaires
              ,crapcrl.nrcxpost
              ,crapcrl.dscidres
              ,crapcrl.dsdufres
              ,crapcrl.nmpairsp
              ,crapcrl.nmmaersp
              ,crapcrl.rowid
        FROM crapcrl
        WHERE crapcrl.cdcooper = pr_cdcooper
        AND   crapcrl.nrctamen = pr_nrctamen
        AND   crapcrl.nrcpfmen = pr_nrcpfmen
        AND   crapcrl.idseqmen = pr_idseqmen;
      --Variaveis Locais
      vr_nrdrowid ROWID;
      vr_index    INTEGER;
      vr_idade    INTEGER;
      vr_indtrans INTEGER;
      vr_nrdconta INTEGER;
      vr_nrcpfcgc NUMBER;
      vr_nrcpfcto NUMBER;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nmorgexp tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
      
      --Tabela memoria erros
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_cdcritic2 crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      vr_dscritic2 VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro   EXCEPTION;
      vr_exc_busca  EXCEPTION;
      vr_exc_filtro EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Limpar tabelas
      pr_tab_erro.DELETE;
      pr_tab_crapcrl.DELETE;

      --Buscar a origem
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      --Buscar Transacao
      vr_dstransa:= 'Busca dados do Responsavel Legal';

      --Bloco Busca
      BEGIN
        --Nome Rotina
        IF pr_nmrotina IN ('Representante/Procurador','MATRIC') AND NOT pr_permalte THEN
          --Se foi informada a conta
          IF Nvl(pr_nrdconta,0) <> 0 THEN
            vr_dscritic:= 'Alteracoes devem ser realizadas na tela CONTAS.';
            --Sair da Busca
            RAISE vr_exc_busca;
          END IF;
        END IF;
        --Se foi informada a conta
        IF Nvl(pr_nrdconta,0) <> 0 THEN
          /* verifica se eh menor de idade */
          OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_idseqttl => pr_idseqttl);
          FETCH cr_crapttl INTO rw_crapttl;
          --Se Achou
          IF cr_crapttl%FOUND THEN
            --Verificar Mesma data Nascimento
            IF Trunc(pr_dtdenasc) = Trunc(rw_crapttl.dtnasttl) AND
               Upper(pr_nmrotina) = 'RESPONSAVEL LEGAL' THEN
              --Buscar Idade
              vr_idade:= CADA0001.fn_busca_idade (pr_dtnascto => rw_crapttl.dtnasttl
                                                 ,pr_dtmvtolt => pr_dtmvtolt);
              --Indicador Hab = Menor e Maior 18 anos ou habilitado
              IF (rw_crapttl.inhabmen = 0 AND vr_idade >= 18) OR rw_crapttl.inhabmen = 1 THEN
                --Marcar como maior idade
                pr_menorida:= FALSE;
              ELSE
                pr_menorida:= TRUE;
              END IF;
            ELSE
              --Buscar Idade
              vr_idade:= CADA0001.fn_busca_idade (pr_dtnascto => pr_dtdenasc
                                                 ,pr_dtmvtolt => pr_dtmvtolt);
              --Indicador Hab = Menor e Maior 18 anos ou habilitado
              IF (pr_cdhabmen = 0 AND vr_idade >= 18) OR pr_cdhabmen = 1 THEN
                --Marcar como maior idade
                pr_menorida:= FALSE;
              ELSE
                pr_menorida:= TRUE;
              END IF;
            END IF;
          ELSE
            --Buscar Idade
            vr_idade:= CADA0001.fn_busca_idade (pr_dtnascto => pr_dtdenasc
                                               ,pr_dtmvtolt => pr_dtmvtolt);
            --Indicador Hab = Menor e Maior 18 anos ou habilitado
            IF (pr_cdhabmen = 0 AND vr_idade >= 18) OR pr_cdhabmen = 1 THEN
              --Marcar como maior idade
              pr_menorida:= FALSE;
            ELSE
              pr_menorida:= TRUE;
            END IF;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapttl;
        ELSE
          --Buscar Idade
          vr_idade:= CADA0001.fn_busca_idade (pr_dtnascto => pr_dtdenasc
                                             ,pr_dtmvtolt => pr_dtmvtolt);
          --Indicador Hab = Menor e Maior 18 anos ou habilitado
          IF (pr_cdhabmen = 0 AND vr_idade >= 18) OR pr_cdhabmen = 1 THEN
            --Marcar como maior idade
            pr_menorida:= FALSE;
          ELSE
            pr_menorida:= TRUE;
          END IF;
        END IF;

        --Verificar se a conta está preenchida
        IF Nvl(pr_nrdconta,0) = 0 THEN
          vr_nrcpfcgc:= pr_cpfprocu;
        ELSE
          vr_nrcpfcgc:= 0;
        END IF;

        --Verifica se pode excluir
        IF pr_cddopcao = 'E' THEN
          /* Verifica se ha mais de um responsavel pra poder
                   excluir e permite que um maior de idade possa
                   excluir todos os responsaveis */
          --Selecionar Responsavel Legal
          OPEN cr_crapcrl (pr_cdcooper => pr_cdcooper
                          ,pr_nrctamen => pr_nrdconta
                          ,pr_nrcpfmen => vr_nrcpfcgc
                          ,pr_idseqmen => pr_idseqttl
                          ,pr_nrdrowid => pr_nrdrowid);
          FETCH cr_crapcrl INTO rw_crapcrl;
          --Se nao encontrou
          IF cr_crapcrl%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_crapcrl;
            --Marcar menor idade
            pr_menorida:= TRUE;
            --Mensagem Critica
            vr_dscritic:= 'Deve existir pelo menos um responsavel legal.';
            --Levantar Excecao
            RAISE vr_exc_busca;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapcrl;
        END IF;  --pr_cddopcao = 'E'

        --Bloco FiltroBusca
        BEGIN
          --Se o rowid do avalista foi informado
          IF pr_nrdrowid IS NOT NULL THEN
            --Buscar Dados pelo Representantes Legais pelo ROWID
            pc_busca_dados_id_72 (pr_cdcooper => pr_cdcooper     --Codigo Cooperativa
                                 ,pr_nrdrowid => pr_nrdrowid     --Rowid Representante Legal
                                 ,pr_dtmvtolt => pr_dtmvtolt     --Data Movimento
                                 ,pr_cddopcao => pr_cddopcao     --Codigo opcao
                                 ,pr_nmrotina => pr_nmrotina     --Nome Rotina
                                 ,pr_tab_crapcrl => pr_tab_crapcrl --Tabela Representantes Legais
                                 ,pr_cdcritic => vr_cdcritic       --Codigo de erro
                                 ,pr_dscritic => vr_dscritic);     --Retorno de Erro
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            --Sair da Busca
            RAISE vr_exc_busca;
          ELSE
            --Numero contato e cpf contato preenchido
            IF nvl(pr_nrdctato,0) <> 0 OR Nvl(pr_nrcpfcto,0) <> 0 THEN
              /* validar o cpf antes de fazer a busca */
              IF Nvl(pr_nrcpfcto,0) <> 0 AND NOT fn_valida_cpf (pr_nrcpfcgc => pr_nrcpfcto) THEN
                --Montar Critica
                vr_dscritic:= 'O CPF informado esta incorreto.';
                --Levantar Excecao
                RAISE vr_exc_busca;
              END IF;
              --Buscar Dados dos representantes legais pela Conta Contato
              pc_busca_dados_cto_72 (pr_cdcooper => pr_cdcooper       --Codigo Cooperativa
                                    ,pr_nrdconta => pr_nrdconta       --Numero da Conta
                                    ,pr_nrctremp => pr_idseqttl       --Sequencial Titular
                                    ,pr_nrdctato => pr_nrdctato       --Numero Contato
                                    ,pr_nrcpfcto => pr_nrcpfcto       --Numero Cpf Contato
                                    ,pr_dtmvtolt => pr_dtmvtolt       --Data Movimento
                                    ,pr_cddopcao => pr_cddopcao       --Codigo opcao
                                    ,pr_cpfprocu => pr_cpfprocu       --Cpf Procurador
                                    ,pr_verconta => TRUE              --Verificar Conta
                                    ,pr_nmrotina => pr_nmrotina       --Nome Rotina
                                    ,pr_tab_crapcrl => pr_tab_crapcrl --Tabela Representantes Legais
                                    ,pr_cdcritic => vr_cdcritic       --Codigo de erro
                                    ,pr_dscritic => vr_dscritic);     --Retorno de Erro
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              --Sair
              RAISE vr_exc_busca;
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_filtro THEN
            NULL;
        END; --Filtro Busca
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_busca;
        END IF;
        /* processar a busca/listagem */
        IF pr_cddopcao <> 'C' THEN
          RAISE vr_exc_busca;
        END IF;

        /* Carrega a lista de representantes legais */
        FOR rw_crapcrl IN cr_crapcrl2 (pr_cdcooper => pr_cdcooper
                                      ,pr_nrctamen => pr_nrdconta
                                      ,pr_nrcpfmen => vr_nrcpfcgc
                                      ,pr_idseqmen => pr_idseqttl) LOOP
          --Se a Conta estiver preenchida
          IF Nvl(rw_crapcrl.nrdconta,0) <> 0 THEN
            --Buscar Dados pelo Contato
            pc_busca_dados_cto_72 (pr_cdcooper => rw_crapcrl.cdcooper  --Codigo Cooperativa
                                  ,pr_nrdconta => rw_crapcrl.nrctamen  --Numero da Conta
                                  ,pr_nrctremp => rw_crapcrl.idseqmen  --Sequencial Titular
                                  ,pr_nrdctato => rw_crapcrl.nrdconta  --Numero Contato
                                  ,pr_nrcpfcto => rw_crapcrl.nrcpfcgc  --Numero Cpf Contato
                                  ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                  ,pr_cddopcao => pr_cddopcao          --Codigo opcao
                                  ,pr_cpfprocu => rw_crapcrl.nrcpfmen  --Cpf Procurador
                                  ,pr_verconta => FALSE                --Verificar Conta
                                  ,pr_nmrotina => pr_nmrotina          --Nome Rotina
                                  ,pr_tab_crapcrl => pr_tab_crapcrl    --Tabela Representantes Legais
                                  ,pr_cdcritic => vr_cdcritic          --Codigo de erro
                                  ,pr_dscritic => vr_dscritic);        --Retorno de Erro
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            -- Buscar o ultimo criado
            vr_index:= pr_tab_crapcrl.count;
            --Demais Informacoes
            pr_tab_crapcrl(vr_index).nrdrowid:= rw_crapcrl.rowid;
            pr_tab_crapcrl(vr_index).deletado:= FALSE;
            pr_tab_crapcrl(vr_index).cddopcao:= 'C';
          ELSE
            --Incrementar Indice para tabela memoria
            vr_index:= pr_tab_crapcrl.count+1;

            -- Busca a Nacionalidade
            vr_dsnacion := '';
            OPEN  cr_crapnac(pr_cdnacion => rw_crapcrl.cdnacion);
            FETCH cr_crapnac INTO vr_dsnacion;
            CLOSE cr_crapnac;

            --Carregar tabela memoria
            pr_tab_crapcrl(vr_index).cdcooper:= rw_crapcrl.cdcooper;
            pr_tab_crapcrl(vr_index).nrctamen:= rw_crapcrl.nrctamen;
            pr_tab_crapcrl(vr_index).nrcpfmen:= rw_crapcrl.nrcpfmen;
            pr_tab_crapcrl(vr_index).idseqmen:= rw_crapcrl.idseqmen;
            pr_tab_crapcrl(vr_index).nrdconta:= rw_crapcrl.nrdconta;
            pr_tab_crapcrl(vr_index).nrcpfcgc:= rw_crapcrl.nrcpfcgc;
            pr_tab_crapcrl(vr_index).nmrespon:= rw_crapcrl.nmrespon;
            pr_tab_crapcrl(vr_index).nridenti:= rw_crapcrl.nridenti;
            pr_tab_crapcrl(vr_index).tpdeiden:= rw_crapcrl.tpdeiden;
            pr_tab_crapcrl(vr_index).cdufiden:= rw_crapcrl.cdufiden;
            pr_tab_crapcrl(vr_index).dtemiden:= rw_crapcrl.dtemiden;
            pr_tab_crapcrl(vr_index).dtnascin:= rw_crapcrl.dtnascin;
            pr_tab_crapcrl(vr_index).cddosexo:= rw_crapcrl.cddosexo;
            pr_tab_crapcrl(vr_index).cdestciv:= rw_crapcrl.cdestciv;
            pr_tab_crapcrl(vr_index).cdnacion:= rw_crapcrl.cdnacion;
            pr_tab_crapcrl(vr_index).dsnacion:= vr_dsnacion;
            pr_tab_crapcrl(vr_index).dsnatura:= rw_crapcrl.dsnatura;
            pr_tab_crapcrl(vr_index).cdcepres:= rw_crapcrl.cdcepres;
            pr_tab_crapcrl(vr_index).dsendres:= rw_crapcrl.dsendres;
            pr_tab_crapcrl(vr_index).nrendres:= rw_crapcrl.nrendres;
            pr_tab_crapcrl(vr_index).dscomres:= rw_crapcrl.dscomres;
            pr_tab_crapcrl(vr_index).dsbaires:= rw_crapcrl.dsbaires;
            pr_tab_crapcrl(vr_index).nrcxpost:= rw_crapcrl.nrcxpost;
            pr_tab_crapcrl(vr_index).dscidres:= rw_crapcrl.dscidres;
            pr_tab_crapcrl(vr_index).dsdufres:= rw_crapcrl.dsdufres;
            pr_tab_crapcrl(vr_index).nmpairsp:= rw_crapcrl.nmpairsp;
            pr_tab_crapcrl(vr_index).nmmaersp:= rw_crapcrl.nmmaersp;
            
            --> Buscar orgão expedidor
            pr_tab_crapcrl(vr_index).dsorgemi := NULL;
            cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapcrl.idorgexp, 
                                              pr_cdorgao_expedidor => pr_tab_crapcrl(vr_index).dsorgemi, 
                                              pr_nmorgao_expedidor => vr_nmorgexp, 
                                              pr_cdcritic          => vr_cdcritic, 
                                              pr_dscritic          => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR 
               TRIM(vr_dscritic) IS NOT NULL THEN
              pr_tab_crapcrl(vr_index).dsorgemi := 'NAO CADAST';
              vr_nmorgexp := NULL; 
            END IF; 
            
            /* Estado civil */
            OPEN cr_gnetcvl (pr_cdestcvl => rw_crapcrl.cdestciv);
            FETCH cr_gnetcvl INTO rw_gnetcvl;
            --Se Encontrou
            IF cr_gnetcvl%FOUND THEN
              --Descricao estado Civil
              pr_tab_crapcrl(vr_index).dsestcvl:= rw_gnetcvl.rsestcvl;
            END IF;
            --Fechar Cursor
            CLOSE cr_gnetcvl;
            --Demais Informacoes
            pr_tab_crapcrl(vr_index).nrdrowid:= rw_crapcrl.rowid;
            pr_tab_crapcrl(vr_index).deletado:= FALSE;
            pr_tab_crapcrl(vr_index).cddopcao:= 'C';
          END IF;
        END LOOP;
        /*Alteraçao: Busco o CPF para usa como parametro na Busca_Conta*/
        OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_idseqttl => pr_idseqttl);
        FETCH cr_crapttl INTO rw_crapttl;
        --Se Achou
        IF cr_crapttl%FOUND THEN
          --Associar o cpf encontrado
          vr_nrcpfcto:= rw_crapttl.nrcpfcgc;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapttl;
        /*Alteraçao:  Rotina para controle/replicacao entre contas */
        CADA0001.pc_busca_conta (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                ,pr_nrcpfcgc => vr_nrcpfcto   --Numero Cpf
                                ,pr_idseqttl => pr_idseqttl   --Sequencial Titular
                                ,pr_nrctattl => vr_nrdconta   --Numero Conta
                                ,pr_msgconta => pr_msgconta   --Mensagem da conta
                                ,pr_cdcritic => vr_cdcritic   --Codigo Erro
                                ,pr_dscritic => vr_dscritic); --Descricao Erro

        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Sair da Busca
        RAISE vr_exc_busca;
      EXCEPTION
        WHEN vr_exc_busca THEN
          NULL;
      END; --Busca

      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Gerar Erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => vr_cdcritic2
                             ,pr_dscritic => vr_dscritic2
                             ,pr_tab_erro => vr_tab_erro);
        --Se ocorreu erro
        IF vr_cdcritic2 IS NOT NULL OR vr_dscritic2 IS NOT NULL THEN
          --Atualizar variavel erro
          vr_cdcritic:= vr_cdcritic2;
          vr_dscritic:= vr_dscritic2;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Marcar flag erro
        vr_indtrans:= 0;
      ELSE
        vr_indtrans:= 1;
      END IF;

      --Se deve escrever no Log
      IF pr_flgerlog AND pr_cddopcao = 'C' THEN
        --Gerar log
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => SYSDATE
                            ,pr_flgtrans => vr_indtrans
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_72: ' || SQLERRM;
    END;
  END pc_busca_dados_72;

  /* Buscar Dados do procurador - b1wgen0058 */
  PROCEDURE pc_busca_dados_ass_58 (pr_cdcooper IN crapcop.cdcooper%type     --Codigo Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%type     --Numero da Conta
                                  ,pr_idseqttl IN INTEGER                   --Numero Sequencial Titular
                                  ,pr_nrdctato IN INTEGER                   --Numero Contato
                                  ,pr_tab_crapavt IN OUT typ_tab_crapavt_58    --Tabela Avalistas
                                  ,pr_cdcritic OUT INTEGER                  --Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2) IS             --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_ass_58                 Antigo: b1wgen0058.p --> Busca_Dados_Ass
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao: 24/07/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Procedure para buscar dados do procurador

   Alteracoes: 13/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

               02/06/2014 - Removido os campos cdestcvl e vlsalari da crapass e
                            adicionados na crapttl. (Douglas - Chamado 131253)

               17/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)

               24/07/2017 - Alterar cdoedptl para idorgexp.
                            PRJ339-CRM  (Odirlei-AMcom) 

  ............................................................................. */
  BEGIN
    DECLARE
      --Cursores Locais

      --Selecionar contas de titular do cpf/cnpj
      CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                        ,pr_nrdconta IN crapttl.nrdconta%type
                        ,pr_idseqttl IN crapttl.idseqttl%type) IS
        SELECT crapttl.nmextttl
              ,crapttl.nrdocttl
              ,crapttl.idorgexp
              ,crapttl.cdufdttl
              ,crapttl.dtemdttl
              ,crapttl.dtnasttl
              ,crapttl.cdsexotl
              ,crapttl.cdestcvl
              ,crapttl.cdnacion
              ,crapttl.dsnatura
              ,crapttl.nmpaittl
              ,crapttl.nmmaettl
              ,crapttl.tpdocttl
              ,crapttl.inhabmen
              ,crapttl.dthabmen
              ,crapttl.idseqttl
        FROM crapttl
        WHERE crapttl.cdcooper  = pr_cdcooper
        AND   crapttl.nrdconta  = pr_nrdconta
        AND   crapttl.idseqttl  = pr_idseqttl
        ORDER BY crapttl.progress_recid ASC;
      rw_crapttl cr_crapttl%ROWTYPE;

      --Selecionar Endereco
      CURSOR cr_crapenc (pr_cdcooper IN crapenc.cdcooper%type
                        ,pr_nrdconta IN crapenc.nrdconta%type
                        ,pr_idseqttl IN crapenc.idseqttl%type
                        ,pr_cdseqinc IN crapenc.cdseqinc%TYPE
                        ,pr_tpendass IN crapenc.tpendass%type) IS
        SELECT crapenc.nrendere
              ,crapenc.complend
              ,crapenc.nrcepend
              ,crapenc.dsendere
              ,crapenc.nmbairro
              ,crapenc.nmcidade
              ,crapenc.cdufende
              ,crapenc.nrcxapst
        FROM crapenc
        WHERE crapenc.cdcooper = pr_cdcooper
        AND   crapenc.nrdconta = pr_nrdconta
        AND   crapenc.idseqttl = pr_idseqttl
        AND   crapenc.cdseqinc = pr_cdseqinc
        AND   crapenc.tpendass = pr_tpendass
        ORDER BY crapenc.progress_recid ASC;
      rw_crapenc cr_crapenc%ROWTYPE;
      --Selecionar Endividamento
      CURSOR cr_crapsdv (pr_cdcooper IN crapsdv.cdcooper%type
                        ,pr_nrdconta IN crapsdv.nrdconta%type) IS
        SELECT Nvl(Sum(Nvl(crapsdv.vldsaldo,0)),0)
        FROM crapsdv
        WHERE crapsdv.cdcooper = pr_cdcooper
        AND   crapsdv.nrdconta = pr_nrdconta
        AND   crapsdv.tpdsaldo IN (1,2,3,6);
      /* Primeiro bem do cooperado */
      CURSOR cr_crapbem (pr_cdcooper IN crapbem.cdcooper%type
                        ,pr_nrdconta IN crapbem.nrdconta%type
                        ,pr_idseqttl IN crapbem.idseqttl%type) IS
        SELECT crapbem.dsrelbem
        FROM crapbem
        WHERE crapbem.cdcooper = pr_cdcooper
        AND   crapbem.nrdconta = pr_nrdconta
        AND   crapbem.idseqttl = pr_idseqttl
        ORDER BY crapbem.progress_recid ASC;
      rw_crapbem cr_crapbem%ROWTYPE;
      --Selecionar Avalista
      CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%type
                        ,pr_tpctrato IN crapavt.tpctrato%type
                        ,pr_nrdconta IN crapavt.nrdconta%type
                        ,pr_nrctremp IN crapavt.nrctremp%type
                        ,pr_nrcpfcgc IN crapavt.nrcpfcgc%type) IS
        SELECT crapavt.rowid
              ,crapavt.dtvalida
              ,crapavt.dsproftl
              ,crapavt.persocio
              ,crapavt.flgdepec
              ,crapavt.vloutren
              ,crapavt.dsoutren
        FROM crapavt
        WHERE crapavt.cdcooper = pr_cdcooper
        AND   crapavt.tpctrato = pr_tpctrato
        AND   crapavt.nrdconta = pr_nrdconta
        AND   crapavt.nrctremp = pr_nrctremp
        AND   crapavt.nrcpfcgc = pr_nrcpfcgc
        ORDER BY crapavt.progress_recid ASC;
      rw_crapavt cr_crapavt%ROWTYPE;
      --Selecionar bens
      CURSOR cr_crapbem2 (pr_cdcooper IN crapbem.cdcooper%type
                         ,pr_nrdconta IN crapbem.nrdconta%type) IS
        SELECT crapbem.dsrelbem
              ,crapbem.persemon
              ,crapbem.qtprebem
              ,crapbem.vlprebem
              ,crapbem.vlrdobem
        FROM  crapbem
        WHERE crapbem.cdcooper = pr_cdcooper
        AND   crapbem.nrdconta = pr_nrdctato
        ORDER BY crapbem.idseqttl,crapbem.idseqbem;
      --Variaveis Locais
      vr_dsdidade VARCHAR2(1000);
      vr_nrdmeses INTEGER;
      vr_contador INTEGER;
      vr_flgerro  BOOLEAN;
      vr_index    INTEGER;
      vr_nmorgexp tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
      
      --Variaveis de erro
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro   EXCEPTION;
      vr_exc_busca  EXCEPTION;
      vr_exc_filtro EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Selecionar Associado
      FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdctato) LOOP
        --Selecionar titular
        OPEN cr_crapttl (pr_cdcooper => rw_crapass.cdcooper
                        ,pr_nrdconta => rw_crapass.nrdconta
                        ,pr_idseqttl => 1);
        FETCH cr_crapttl INTO rw_crapttl;
        --Se Encontrou
        IF cr_crapttl%FOUND THEN
          --Fechar Cursor
          CLOSE cr_crapttl;
          /* Endereco Residencial */
          OPEN cr_crapenc (pr_cdcooper => rw_crapass.cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta
                          ,pr_idseqttl => 1
                          ,pr_cdseqinc => 1
                          ,pr_tpendass => 10); /*Residencial*/
          FETCH cr_crapenc INTO rw_crapenc;
          --Verificar se Encontrou
          IF cr_crapenc%NOTFOUND THEN
            --Fechar Cursores
            CLOSE cr_crapenc;
            --Mensagem Critica
            vr_dscritic:= 'Endereco nao cadastrado.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapenc;

          -- Busca a Nacionalidade
          vr_dsnacion := '';
          OPEN  cr_crapnac(pr_cdnacion => rw_crapass.cdnacion);
          FETCH cr_crapnac INTO vr_dsnacion;
          CLOSE cr_crapnac;

          --Criar Avalista
          vr_index:= pr_tab_crapavt.Count+1;
          pr_tab_crapavt(vr_index).cddconta:= gene0002.fn_mask_conta(rw_crapass.nrdconta);
          pr_tab_crapavt(vr_index).cdcooper:= rw_crapass.cdcooper;
          pr_tab_crapavt(vr_index).nrdconta:= pr_nrdconta;
          pr_tab_crapavt(vr_index).nrcpfcgc:= rw_crapass.nrcpfcgc;
          pr_tab_crapavt(vr_index).nmdavali:= substr(rw_crapass.nmprimtl,1,50);
          pr_tab_crapavt(vr_index).tpdocava:= rw_crapass.tpdocptl;
          pr_tab_crapavt(vr_index).nrdocava:= rw_crapass.nrdocptl;
          pr_tab_crapavt(vr_index).cdufddoc:= rw_crapass.cdufdptl;
          pr_tab_crapavt(vr_index).dtemddoc:= rw_crapass.dtemdptl;
          pr_tab_crapavt(vr_index).dtnascto:= rw_crapass.dtnasctl;
          pr_tab_crapavt(vr_index).cdsexcto:= rw_crapass.cdsexotl;
          pr_tab_crapavt(vr_index).cdestcvl:= rw_crapttl.cdestcvl;
          pr_tab_crapavt(vr_index).cdnacion:= rw_crapass.cdnacion;
          pr_tab_crapavt(vr_index).dsnacion:= vr_dsnacion;
          pr_tab_crapavt(vr_index).dsnatura:= rw_crapttl.dsnatura;
          pr_tab_crapavt(vr_index).nmmaecto:= rw_crapttl.nmmaettl;
          pr_tab_crapavt(vr_index).nmpaicto:= rw_crapttl.nmpaittl;
          pr_tab_crapavt(vr_index).nrcepend:= rw_crapenc.nrcepend;
          pr_tab_crapavt(vr_index).dsendres(1):= rw_crapenc.dsendere;
          pr_tab_crapavt(vr_index).nrendere:= rw_crapenc.nrendere;
          pr_tab_crapavt(vr_index).complend:= rw_crapenc.complend;
          pr_tab_crapavt(vr_index).nmbairro:= rw_crapenc.nmbairro;
          pr_tab_crapavt(vr_index).nmcidade:= rw_crapenc.nmcidade;
          pr_tab_crapavt(vr_index).cdufresd:= rw_crapenc.cdufende;
          pr_tab_crapavt(vr_index).nrcxapst:= rw_crapenc.nrcxapst;
          pr_tab_crapavt(vr_index).nrdctato:= rw_crapass.nrdconta;
          pr_tab_crapavt(vr_index).cdcpfcgc:= gene0002.fn_mask(rw_crapass.nrcpfcgc,'99999999999');
          pr_tab_crapavt(vr_index).inhabmen:= rw_crapttl.inhabmen;
          pr_tab_crapavt(vr_index).dthabmen:= rw_crapttl.dthabmen;
          pr_tab_crapavt(vr_index).nrctremp:= rw_crapttl.idseqttl;
          pr_tab_crapavt(vr_index).tpctrato:= 6; /*Procuradores*/

          --> Buscar orgão expedidor
          pr_tab_crapavt(vr_index).cdoeddoc := NULL;
          cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapass.idorgexp, 
                                            pr_cdorgao_expedidor => pr_tab_crapavt(vr_index).cdoeddoc, 
                                            pr_nmorgao_expedidor => vr_nmorgexp, 
                                            pr_cdcritic          => vr_cdcritic, 
                                            pr_dscritic          => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR 
             TRIM(vr_dscritic) IS NOT NULL THEN
            pr_tab_crapavt(vr_index).cdoeddoc := 'NAO CADAST';
            vr_nmorgexp := NULL; 
          END IF; 

          /* validar pela procedure generica do b1wgen9999.p */
          pc_busca_idade (pr_dtnasctl => rw_crapass.dtnasctl  --Data de Nascimento
                         ,pr_dtmvtolt => SYSDATE              --Data da utilizacao atual
                         ,pr_flcomple => 0                --> Controle para validar o método de cálculo de datas
                         ,pr_nrdeanos => pr_tab_crapavt(vr_index).nrdeanos --Numero de Anos
                         ,pr_nrdmeses => vr_nrdmeses            --Numero de meses
                         ,pr_dsdidade => vr_dsdidade            --Descricao da idade
                         ,pr_des_erro => vr_dscritic);          --Mensagem de Erro

          /* Valor do endividamento */
          OPEN cr_crapsdv (pr_cdcooper => rw_crapass.cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta);
          FETCH cr_crapsdv INTO pr_tab_crapavt(vr_index).vledvmto;
          --Fechar Cursor
          CLOSE cr_crapsdv;
          /* Primeiro bem do cooperado */
          OPEN cr_crapbem (pr_cdcooper => rw_crapass.cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta
                          ,pr_idseqttl => 1);
          FETCH cr_crapbem INTO rw_crapbem;
          --Se Encontrou
          IF cr_crapbem%FOUND THEN
            pr_tab_crapavt(vr_index).dsrelbem(1):= rw_crapbem.dsrelbem;
          END IF;
          CLOSE cr_crapbem;
          --Selecionar Avalista
          OPEN cr_crapavt (pr_cdcooper => rw_crapass.cdcooper
                          ,pr_tpctrato => 6 /* jur */
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctremp => pr_idseqttl
                          ,pr_nrcpfcgc => rw_crapass.nrcpfcgc);
          FETCH cr_crapavt INTO rw_crapavt;
          --Se Encontrou
          IF cr_crapavt%FOUND THEN
            pr_tab_crapavt(vr_index).nrdrowid:= rw_crapavt.ROWID;
            pr_tab_crapavt(vr_index).rowidavt:= rw_crapavt.ROWID;
            pr_tab_crapavt(vr_index).dtvalida:= rw_crapavt.dtvalida;
            pr_tab_crapavt(vr_index).dsproftl:= rw_crapavt.dsproftl;
            pr_tab_crapavt(vr_index).persocio:= rw_crapavt.persocio;
            pr_tab_crapavt(vr_index).flgdepec:= rw_crapavt.flgdepec;
            pr_tab_crapavt(vr_index).vloutren:= rw_crapavt.vloutren;
            pr_tab_crapavt(vr_index).dsoutren:= rw_crapavt.dsoutren;
            --Verificar se é indeterminado
            IF rw_crapavt.dtvalida = To_Date('12/31/9999','MM/DD/YYYY') THEN
              pr_tab_crapavt(vr_index).dsvalida:= 'INDETERMI.';
            ELSE
              pr_tab_crapavt(vr_index).dsvalida:= To_Char(rw_crapavt.dtvalida,'DD/MM/YYYY');
            END IF;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapavt;
          --Buscar Habilitacao
          vr_flgerro:= CADA0001.fn_busca_habilitacao(pr_inhabmen => pr_tab_crapavt(vr_index).inhabmen  --> Código Habilitacao
                                                    ,pr_dshabmen => pr_tab_crapavt(vr_index).dshabmen  --> Descricao Habilitacao
                                                    ,pr_cdcritic => vr_cdcritic     --Codigo de erro
                                                    ,pr_dscritic => vr_dscritic);   --Retorno de Erro
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          --Buscar Estado Civil
          vr_flgerro:= CADA0001.fn_busca_estado_civil (pr_cdestcvl => pr_tab_crapavt(vr_index).cdestcvl  --> Código Estado Civil
                                                      ,pr_dsestcvl => pr_tab_crapavt(vr_index).dsestcvl  --> Descricao Estado Civil
                                                      ,pr_cdcritic => vr_cdcritic     --Codigo de erro
                                                      ,pr_dscritic => vr_dscritic);   --Retorno de Erro
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          --Inicializar Contador
          vr_contador:= 1;
          --Selecionar os Bens
          FOR rw_crapbem IN cr_crapbem2 (pr_cdcooper => pr_tab_crapavt(vr_index).cdcooper
                                        ,pr_nrdconta => pr_tab_crapavt(vr_index).nrdctato) LOOP
            --Inserir informacoes na tabela memoria
            pr_tab_crapavt(vr_index).dsrelbem(vr_contador):= rw_crapbem.dsrelbem;
            pr_tab_crapavt(vr_index).dsrelbem(vr_contador):= rw_crapbem.dsrelbem;
            pr_tab_crapavt(vr_index).persemon(vr_contador):= rw_crapbem.persemon;
            pr_tab_crapavt(vr_index).qtprebem(vr_contador):= rw_crapbem.qtprebem;
            pr_tab_crapavt(vr_index).vlprebem(vr_contador):= rw_crapbem.vlprebem;
            pr_tab_crapavt(vr_index).vlrdobem(vr_contador):= rw_crapbem.vlrdobem;
            --Incrementar Contador
            vr_contador:= vr_contador + 1;
            --Sair do LOOP
            IF vr_contador = 6 THEN
              EXIT;
            END IF;
          END LOOP;
        END IF;
        --Fechar Cursor
        IF cr_crapttl%ISOPEN THEN
          CLOSE cr_crapttl;
        END IF;
      END LOOP; --rw_crapass
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_ass_58: ' || SQLERRM;
    END;
  END pc_busca_dados_ass_58;

  /* Buscar Dados dos procuradores pelo Contato - b1wgen0058 */
  PROCEDURE pc_busca_dados_cto_58 (pr_cdcooper IN crapcop.cdcooper%type     --Codigo Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%type     --Numero da Conta
                                  ,pr_idseqttl IN INTEGER                   --Numero Contrato Emprestimo
                                  ,pr_nrdctato IN INTEGER                   --Numero Contato
                                  ,pr_nrcpfcto IN NUMBER                    --Numero Cpf Contato
                                  ,pr_cddopcao IN VARCHAR2                  --Codigo opcao
                                  ,pr_tab_crapavt IN OUT typ_tab_crapavt_58    --Tabela Avalistas
                                  ,pr_cdcritic OUT INTEGER                  --Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2) IS             --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_cto_58                 Antigo: b1wgen0058.p --> Busca_Dados_Cto
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao: 24/07/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Procedure para buscar dados dos procuradores pelo Contato

   Alteracoes: 09/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

               02/06/2014 - Removido os campos cdestcvl e vlsalari da crapass e
                            adicionados na crapttl. (Douglas - Chamado 131253)
                            
               21/11/2014 - Ajuste conforme procedimento é em progress(Odirlei-Amcom)             
               
               24/07/2017 - Alterar cdoedptl para idorgexp.
                            PRJ339-CRM  (Odirlei-AMcom)          
  ............................................................................. */
  BEGIN
    DECLARE
      --Cursores Locais
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%type
                        ,pr_nrdconta IN crapass.nrdconta%type
                        ,pr_inpessoa IN crapass.inpessoa%TYPE
                        ,pr_tipo     IN INTEGER) IS
        SELECT crapass.inpessoa
              ,crapass.cdtipcta
              ,crapass.dtdemiss
              ,crapass.nrdconta
              ,crapass.cdcooper
              ,crapass.nrcpfcgc
        FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrdconta = pr_nrdconta
        AND   ((pr_tipo = 1 AND crapass.inpessoa = pr_inpessoa) OR pr_tipo = 2);
      --Selecionar associado pelo cpf
      CURSOR cr_crapass_cpf (pr_cdcooper IN crapass.cdcooper%type
                            ,pr_nrcpfcgc IN crapass.nrcpfcgc%type) IS
        SELECT crapass.inpessoa
              ,crapass.cdtipcta
              ,crapass.dtdemiss
              ,crapass.nrdconta
              ,crapass.cdcooper
              ,crapass.nrcpfcgc
        FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrcpfcgc = pr_nrcpfcgc
        ORDER BY crapass.progress_recid ASC;
      rw_crapass cr_crapass%ROWTYPE;
      --Selecionar contas de titular do cpf/cnpj
      CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                        ,pr_nrdconta IN crapttl.nrdconta%type
                        ,pr_nrcpfcgc IN crapttl.nrcpfcgc%type) IS
        SELECT crapttl.nmextttl
              ,crapttl.nrdocttl
              ,crapttl.idorgexp
              ,crapttl.cdufdttl
              ,crapttl.dtemdttl
              ,crapttl.dtnasttl
              ,crapttl.cdsexotl
              ,crapttl.cdestcvl
              ,crapttl.cdnacion
              ,crapttl.dsnatura
              ,crapttl.nmpaittl
              ,crapttl.nmmaettl
              ,crapttl.tpdocttl
        FROM crapttl
        WHERE crapttl.cdcooper  = pr_cdcooper
        AND   crapttl.nrdconta  = pr_nrdconta
        AND   crapttl.nrcpfcgc  = pr_nrcpfcgc
        ORDER BY crapttl.progress_recid ASC;
      rw_crapttl cr_crapttl%ROWTYPE;

      --Variaveis Locais
      vr_crapass  BOOLEAN;
      --Tabela memoria erros
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro   EXCEPTION;
      vr_exc_busca  EXCEPTION;
      vr_exc_filtro EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Limpar Tabela Memoria
      vr_tab_erro.DELETE;

      --Selecionar Associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_inpessoa => 1 /*fisica*/
                      ,pr_tipo     => 1);
      FETCH cr_crapass INTO rw_crapass;
      --Se Encontrou
      IF cr_crapass%FOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        --Buscar Titular
        OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrcpfcgc => pr_nrcpfcto);
        FETCH cr_crapttl INTO rw_crapttl;
        --Se Encontrou
        IF cr_crapttl%FOUND THEN
          --Fechar Cursor
          CLOSE cr_crapttl;
          --Montar critica
          vr_dscritic:= 'Titular da conta nao pode ser procurador.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapttl;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      /* efetua a busca tanto por nr da conta como por cpf */
      IF Nvl(pr_nrdctato,0) <> 0  THEN
        --Selecionar Associado
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdctato
                        ,pr_inpessoa => NULL
                        ,pr_tipo     => 2);
        FETCH cr_crapass INTO rw_crapass;
        --Verificar se encontrou
        vr_crapass:= cr_crapass%FOUND;
        --Fechar Cursor
        CLOSE cr_crapass;
      ELSIF Nvl(pr_nrcpfcto,0) <> 0 THEN
        --Selecionar associado por cpf/cgc
        OPEN cr_crapass_cpf (pr_cdcooper => pr_cdcooper
                            ,pr_nrcpfcgc => pr_nrcpfcto);
        FETCH cr_crapass_cpf INTO rw_crapass;
        --Verificar se encontrou
        vr_crapass:=cr_crapass_cpf%FOUND;
        --Fechar Cursor
        CLOSE cr_crapass_cpf;
      END IF;
      --Verificar cadastro incompleto
      IF NOT vr_crapass THEN
        IF Nvl(pr_nrdctato,0) <> 0 THEN
          vr_cdcritic:= 9;
          RAISE vr_exc_erro;
        END IF;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Se conta for igual a do parametro -- Igual ao progress
      IF pr_nrdconta = rw_crapass.nrdconta THEN
        vr_dscritic:= 'Titular da conta nao pode ser procurador.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      /* somente pessoa fisica */
      IF rw_crapass.inpessoa != 1 THEN
        vr_cdcritic:= 833;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Buscar Dados Representante/procurador
      pc_busca_dados_ass_58 (pr_cdcooper => rw_crapass.cdcooper   --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta           --Numero da Conta
                            ,pr_idseqttl => pr_idseqttl           --Numero Sequencial Titular
                            ,pr_nrdctato => rw_crapass.nrdconta   --Numero Contato
                            ,pr_tab_crapavt => pr_tab_crapavt     --Tabela Representante/procurador
                            ,pr_cdcritic => vr_cdcritic           --Codigo de erro
                            ,pr_dscritic => vr_dscritic);         --Retorno de Erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_cto_58: ' || SQLERRM;
    END;
  END pc_busca_dados_cto_58;

  /* Buscar Dados dos procuradores pelo ID - b1wgen0058 */
  PROCEDURE pc_busca_dados_id_58 (pr_cdcooper IN crapcop.cdcooper%type     --Codigo Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%type     --Numero da Conta
                                 ,pr_nrdrowid IN ROWID                     --ROWID Avalista
                                 ,pr_cddopcao IN VARCHAR2                  --Codigo opcao
                                 ,pr_tab_crapavt IN OUT typ_tab_crapavt_58    --Tabela Avalistas
                                 ,pr_tab_bens    IN OUT typ_tab_bens       --Tabela Bens
                                 ,pr_cdcritic OUT INTEGER                  --Codigo de erro
                                 ,pr_dscritic OUT VARCHAR2) IS             --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_id_58                 Antigo: b1wgen0058.p --> Busca_Dados_id
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao: 24/07/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Procedure para buscar dados dos procuradores

   Alteracoes: 14/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

               02/06/2014 - Removido os campos cdestcvl e vlsalari da crapass e
                            adicionados na crapttl. (Douglas - Chamado 131253)

               17/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)

               24/07/2017 - Alterar cdoedptl para idorgexp.
                            PRJ339-CRM  (Odirlei-AMcom) 
  ............................................................................. */
  BEGIN
    DECLARE
      --Cursores Locais
      CURSOR cr_crapavt (pr_rowid IN ROWID) IS
        SELECT crapavt.*
              ,crapavt.rowid
        FROM crapavt
        WHERE crapavt.rowid = pr_rowid;
      rw_crabavt cr_crapavt%ROWTYPE;

      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%type
                        ,pr_nrdconta IN crapass.nrdconta%type
                        ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
        SELECT crapass.inpessoa
              ,crapass.cdtipcta
              ,crapass.dtdemiss
              ,crapass.nrdconta
              ,crapass.cdcooper
              ,crapass.nrcpfcgc
        FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrdconta = pr_nrdconta
        AND   crapass.inpessoa > pr_inpessoa;
      rw_crapass cr_crapass%ROWTYPE;
      --Selecionar Avalista
      CURSOR cr_craeavt (pr_cdcooper IN crapavt.cdcooper%type
                        ,pr_tpctrato IN crapavt.tpctrato%type
                        ,pr_nrdconta IN crapavt.nrdconta%type
                        ,pr_rowid    IN ROWID) IS
        SELECT crapavt.cdcooper
        FROM crapavt
        WHERE crapavt.cdcooper = pr_cdcooper
        AND   crapavt.tpctrato = pr_tpctrato
        AND   crapavt.nrdconta = pr_nrdconta
        AND   crapavt.ROWID    <> pr_rowid
        ORDER BY crapavt.progress_recid ASC;
      rw_craeavt cr_craeavt%ROWTYPE;
      --Selecionar Empresa Participante
      CURSOR cr_crapepa (pr_cdcooper IN crapepa.cdcooper%type
                        ,pr_nrdconta IN crapepa.nrdconta%type) IS
        SELECT crapepa.nrdconta
        FROM crapepa
        WHERE crapepa.cdcooper = pr_cdcooper
        AND   crapepa.nrdconta = pr_nrdconta
        ORDER BY crapepa.progress_recid ASC;
      rw_crapepa cr_crapepa%ROWTYPE;
      --Selecionar Informacoes Pessoa Juridica
      CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%type
                        ,pr_nrdconta IN crapjur.nrdconta%type) IS
        SELECT crapjur.nrdconta
              ,crapjur.natjurid
        FROM crapjur
        WHERE crapjur.cdcooper = pr_cdcooper
        AND   crapjur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;
      --Buscar tipos de natureja juridica
      CURSOR cr_gncdntj (pr_cdnatjur IN gncdntj.cdnatjur%type
                        ,pr_flgprsoc IN gncdntj.flgprsoc%type) IS
        SELECT gncdntj.cdnatjur
        FROM gncdntj
        WHERE gncdntj.cdnatjur = pr_cdnatjur
        AND   gncdntj.flgprsoc = pr_flgprsoc;
      rw_gncdntj cr_gncdntj%ROWTYPE;
      --Variaveis Locais
      vr_nrdmeses INTEGER;
      vr_dsdidade VARCHAR2(100);
      vr_index     INTEGER;
      vr_index_bem INTEGER;
      vr_flgerro   BOOLEAN;
      vr_nmorgexp  tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
      
      --Tabela memoria erros
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro   EXCEPTION;
      vr_exc_busca  EXCEPTION;
      vr_exc_filtro EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Limpar Tabela Memoria
      vr_tab_erro.DELETE;

      --Selecionar Avalista
      OPEN cr_crapavt (pr_rowid => pr_nrdrowid);
      FETCH cr_crapavt INTO rw_crabavt;
      --Se nao encontrou
      IF cr_crapavt%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapavt;
        vr_dscritic:= 'Representante/Procurador nao encontrado';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapavt;
      /* Verifica se ha mais de um procurador pra poder excluir */
      IF pr_cddopcao = 'E' THEN
        --Selecionar Associado
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_inpessoa => 1);
        FETCH cr_crapass INTO rw_crapass;
        --Se Encontrou
        IF cr_crapass%FOUND THEN
          --Selecionar Avalista
          OPEN cr_craeavt (pr_cdcooper => pr_cdcooper
                          ,pr_tpctrato => 6 /*juridica*/
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_rowid    => pr_nrdrowid);
          FETCH cr_craeavt INTO rw_craeavt;
          --Se nao encontrou
          IF cr_craeavt%NOTFOUND THEN
            --Selecionar Empresa Participante
            OPEN cr_crapepa (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta);
            FETCH cr_crapepa INTO rw_crapepa;
            --Se nao Encontrou
            IF cr_crapepa%NOTFOUND THEN
              --Selecionar Pessoa Juridica
              OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta);
              FETCH cr_crapjur INTO rw_crapjur;
              --Se Encontrou
              IF cr_crapjur%FOUND THEN
                --Buscar tipos de natureja juridica
                OPEN cr_gncdntj (pr_cdnatjur => rw_crapjur.natjurid
                                ,pr_flgprsoc => 1);
                FETCH cr_gncdntj INTO rw_gncdntj;
                --Se Encontrou
                IF cr_gncdntj%FOUND THEN
                  --Fechar Cursores
                  CLOSE cr_gncdntj;
                  CLOSE cr_crapjur;
                  CLOSE cr_crapepa;
                  CLOSE cr_craeavt;
                  CLOSE cr_crapass;
                  --Mensagem Erro
                  vr_dscritic:= 'Deve existir pelo menos um representante/procurador';
                  RAISE vr_exc_erro;
                END IF; --cr_gncdntj
                --Fechar Cursor
                CLOSE cr_gncdntj;
              END IF; --cr_crapjur
              --Fechar Cursor
              CLOSE cr_crapjur;
            END IF; --cr_crapepa
            --Fechar Cursor
            CLOSE cr_crapepa;
          END IF;  --cr_craeavt
          --Fechar Cursor
          CLOSE cr_craeavt;
        END IF; --cr_crapass
        --Fechar Cursor
        CLOSE cr_crapass;
      END IF;  --Exclusao
      /* Se for associado, pega os dados da crapass */
      IF  Nvl(rw_crabavt.nrdctato,0) <> 0 THEN
        --Buscar Dados Associado
        pc_busca_dados_ass_58 (pr_cdcooper => rw_crabavt.cdcooper   --Codigo Cooperativa
                              ,pr_nrdconta => rw_crabavt.nrdconta   --Numero da Conta
                              ,pr_idseqttl => rw_crabavt.nrctremp   --Numero Sequencial Titular
                              ,pr_nrdctato => rw_crabavt.nrdctato   --Numero Contato
                              ,pr_tab_crapavt => pr_tab_crapavt     --Tabela Avalistas
                              ,pr_cdcritic => vr_cdcritic           --Codigo de erro
                              ,pr_dscritic => vr_dscritic);         --Retorno de Erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      ELSE
        --Incrementar Indice
        vr_index:= pr_tab_crapavt.Count+1;

        -- Busca a Nacionalidade
        vr_dsnacion := '';
        OPEN  cr_crapnac(pr_cdnacion => rw_crabavt.cdnacion);
        FETCH cr_crapnac INTO vr_dsnacion;
        CLOSE cr_crapnac;

        --Criar tabela avalistascopiando dados da tabela
        pr_tab_crapavt(vr_index).cdcooper:= rw_crabavt.cdcooper;
        pr_tab_crapavt(vr_index).cdufddoc:= rw_crabavt.cdufddoc;
        pr_tab_crapavt(vr_index).cdsexcto:= rw_crabavt.cdsexcto;
        pr_tab_crapavt(vr_index).cdestcvl:= rw_crabavt.cdestcvl;
        pr_tab_crapavt(vr_index).complend:= rw_crabavt.complend;
        pr_tab_crapavt(vr_index).cdufresd:= rw_crabavt.cdufresd;
        pr_tab_crapavt(vr_index).dtmvtolt:= rw_crabavt.dtmvtolt;
        pr_tab_crapavt(vr_index).dtemddoc:= rw_crabavt.dtemddoc;
        pr_tab_crapavt(vr_index).dtvalida:= rw_crabavt.dtvalida;
        pr_tab_crapavt(vr_index).dtadmsoc:= rw_crabavt.dtadmsoc;
        pr_tab_crapavt(vr_index).dsproftl:= rw_crabavt.dsproftl;
        pr_tab_crapavt(vr_index).dtnascto:= rw_crabavt.dtnascto;
        pr_tab_crapavt(vr_index).cdnacion:= rw_crabavt.cdnacion;
        pr_tab_crapavt(vr_index).dsnacion:= vr_dsnacion;
        pr_tab_crapavt(vr_index).dsnatura:= rw_crabavt.dsnatura;
        pr_tab_crapavt(vr_index).dsendres(1):= rw_crabavt.dsendres##1;
        pr_tab_crapavt(vr_index).dsendres(2):= rw_crabavt.dsendres##2;
        pr_tab_crapavt(vr_index).dthabmen:= rw_crabavt.dthabmen;
        pr_tab_crapavt(vr_index).dsoutren:= rw_crabavt.dsoutren;
        pr_tab_crapavt(vr_index).dsrelbem(1):= rw_crabavt.dsrelbem##1;
        pr_tab_crapavt(vr_index).dsrelbem(2):= rw_crabavt.dsrelbem##2;
        pr_tab_crapavt(vr_index).dsrelbem(3):= rw_crabavt.dsrelbem##3;
        pr_tab_crapavt(vr_index).dsrelbem(4):= rw_crabavt.dsrelbem##4;
        pr_tab_crapavt(vr_index).dsrelbem(5):= rw_crabavt.dsrelbem##5;
        pr_tab_crapavt(vr_index).dsrelbem(6):= rw_crabavt.dsrelbem##6;
        pr_tab_crapavt(vr_index).flgdepec:= rw_crabavt.flgdepec;
        pr_tab_crapavt(vr_index).inhabmen:= rw_crabavt.inhabmen;
        pr_tab_crapavt(vr_index).nmdavali:= rw_crabavt.nmdavali;
        pr_tab_crapavt(vr_index).nrdocava:= rw_crabavt.nrdocava;
        pr_tab_crapavt(vr_index).nmmaecto:= rw_crabavt.nmmaecto;
        pr_tab_crapavt(vr_index).nmpaicto:= rw_crabavt.nmpaicto;
        pr_tab_crapavt(vr_index).nrcepend:= rw_crabavt.nrcepend;
        pr_tab_crapavt(vr_index).nrendere:= rw_crabavt.nrendere;
        pr_tab_crapavt(vr_index).nmbairro:= rw_crabavt.nmbairro;
        pr_tab_crapavt(vr_index).nmcidade:= rw_crabavt.nmcidade;
        pr_tab_crapavt(vr_index).nrcxapst:= rw_crabavt.nrcxapst;
        pr_tab_crapavt(vr_index).nrctremp:= rw_crabavt.nrctremp;
        pr_tab_crapavt(vr_index).nrdctato:= rw_crabavt.nrdctato;
        pr_tab_crapavt(vr_index).nrdconta:= rw_crabavt.nrdconta;
        pr_tab_crapavt(vr_index).nrcpfcgc:= rw_crabavt.nrcpfcgc;
        pr_tab_crapavt(vr_index).persocio:= rw_crabavt.persocio;
        pr_tab_crapavt(vr_index).persemon(1):= rw_crabavt.persemon##1;
        pr_tab_crapavt(vr_index).persemon(2):= rw_crabavt.persemon##2;
        pr_tab_crapavt(vr_index).persemon(3):= rw_crabavt.persemon##3;
        pr_tab_crapavt(vr_index).persemon(4):= rw_crabavt.persemon##4;
        pr_tab_crapavt(vr_index).persemon(5):= rw_crabavt.persemon##5;
        pr_tab_crapavt(vr_index).persemon(6):= rw_crabavt.persemon##6;
        pr_tab_crapavt(vr_index).qtprebem(1):= rw_crabavt.qtprebem##1;
        pr_tab_crapavt(vr_index).qtprebem(2):= rw_crabavt.qtprebem##2;
        pr_tab_crapavt(vr_index).qtprebem(3):= rw_crabavt.qtprebem##3;
        pr_tab_crapavt(vr_index).qtprebem(4):= rw_crabavt.qtprebem##4;
        pr_tab_crapavt(vr_index).qtprebem(5):= rw_crabavt.qtprebem##5;
        pr_tab_crapavt(vr_index).qtprebem(6):= rw_crabavt.qtprebem##6;
        pr_tab_crapavt(vr_index).tpdocava:= rw_crabavt.tpdocava;
        pr_tab_crapavt(vr_index).tpctrato:= rw_crabavt.tpctrato;
        pr_tab_crapavt(vr_index).vledvmto:= rw_crabavt.vledvmto;
        pr_tab_crapavt(vr_index).vloutren:= rw_crabavt.vloutren;
        pr_tab_crapavt(vr_index).vlprebem(1):= rw_crabavt.vlprebem##1;
        pr_tab_crapavt(vr_index).vlprebem(2):= rw_crabavt.vlprebem##2;
        pr_tab_crapavt(vr_index).vlprebem(3):= rw_crabavt.vlprebem##3;
        pr_tab_crapavt(vr_index).vlprebem(4):= rw_crabavt.vlprebem##4;
        pr_tab_crapavt(vr_index).vlprebem(5):= rw_crabavt.vlprebem##5;
        pr_tab_crapavt(vr_index).vlprebem(6):= rw_crabavt.vlprebem##6;
        pr_tab_crapavt(vr_index).vlrdobem(1):= rw_crabavt.vlrdobem##1;
        pr_tab_crapavt(vr_index).vlrdobem(2):= rw_crabavt.vlrdobem##2;
        pr_tab_crapavt(vr_index).vlrdobem(3):= rw_crabavt.vlrdobem##3;
        pr_tab_crapavt(vr_index).vlrdobem(4):= rw_crabavt.vlrdobem##4;
        pr_tab_crapavt(vr_index).vlrdobem(5):= rw_crabavt.vlrdobem##5;
        pr_tab_crapavt(vr_index).vlrdobem(6):= rw_crabavt.vlrdobem##6;
        pr_tab_crapavt(vr_index).cddconta:= '0';
        pr_tab_crapavt(vr_index).nrdrowid:= rw_crabavt.ROWID;
        pr_tab_crapavt(vr_index).rowidavt:= rw_crabavt.ROWID;
        pr_tab_crapavt(vr_index).vledvmto:= rw_crabavt.vledvmto;
        pr_tab_crapavt(vr_index).cdcpfcgc:= gene0002.fn_mask_cpf_cnpj(rw_crabavt.nrcpfcgc,1);

        --> Buscar orgão expedidor
        pr_tab_crapavt(vr_index).cdoeddoc := NULL;
        cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crabavt.idorgexp, 
                                          pr_cdorgao_expedidor => pr_tab_crapavt(vr_index).cdoeddoc, 
                                          pr_nmorgao_expedidor => vr_nmorgexp, 
                                          pr_cdcritic          => vr_cdcritic, 
                                          pr_dscritic          => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          pr_tab_crapavt(vr_index).cdoeddoc := 'NAO CADAST';
          vr_nmorgexp := NULL; 
        END IF;  

        /* validar pela procedure generica do b1wgen9999.p */
        pc_busca_idade (pr_dtnasctl => rw_crabavt.dtnascto    --Data de Nascimento
                       ,pr_dtmvtolt => SYSDATE                --Data da utilizacao atual
                       ,pr_flcomple => 0                  --> Controle para validar o método de cálculo de datas
                       ,pr_nrdeanos => pr_tab_crapavt(vr_index).nrdeanos --Numero de Anos
                       ,pr_nrdmeses => vr_nrdmeses            --Numero de meses
                       ,pr_dsdidade => vr_dsdidade            --Descricao da idade
                       ,pr_des_erro => vr_dscritic);          --Mensagem de Erro
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        --Buscar Habilitacao
        vr_flgerro:= CADA0001.fn_busca_habilitacao(pr_inhabmen => rw_crabavt.inhabmen                --> Código Habilitacao
                                                  ,pr_dshabmen => pr_tab_crapavt(vr_index).dshabmen  --> Descricao Habilitacao
                                                  ,pr_cdcritic => vr_cdcritic                        --> Codigo de erro
                                                  ,pr_dscritic => vr_dscritic);                      --> Retorno de Erro
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        --Buscar Estado Civil
        vr_flgerro:= CADA0001.fn_busca_estado_civil (pr_cdestcvl => pr_tab_crapavt(vr_index).cdestcvl  --> Código Estado Civil
                                                    ,pr_dsestcvl => pr_tab_crapavt(vr_index).dsestcvl  --> Descricao Estado Civil
                                                    ,pr_cdcritic => vr_cdcritic                        --> Codigo de erro
                                                    ,pr_dscritic => vr_dscritic);                      --> Retorno de Erro
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        --Verificar se é indeterminado
        IF rw_crabavt.dtvalida = To_Date('12/31/9999','MM/DD/YYYY') THEN
          pr_tab_crapavt(vr_index).dsvalida:= 'INDETERMI.';
        ELSE
          pr_tab_crapavt(vr_index).dsvalida:= To_Char(rw_crabavt.dtvalida,'DD/MM/YYYY');
        END IF;
        --Popular os Bens
        FOR idx IN 1..6 LOOP
          --Se a informacao estiver em branco ignora
          IF pr_tab_crapavt(vr_index).dsrelbem(idx) IS NOT NULL  THEN
            --Criar bens
            vr_index_bem:= pr_tab_bens.Count+1;
            pr_tab_bens(vr_index_bem).dsrelbem:= pr_tab_crapavt(vr_index).dsrelbem(idx);
            pr_tab_bens(vr_index_bem).persemon:= pr_tab_crapavt(vr_index).persemon(idx);
            pr_tab_bens(vr_index_bem).qtprebem:= pr_tab_crapavt(vr_index).qtprebem(idx);
            pr_tab_bens(vr_index_bem).vlprebem:= pr_tab_crapavt(vr_index).vlprebem(idx);
            pr_tab_bens(vr_index_bem).vlrdobem:= pr_tab_crapavt(vr_index).vlrdobem(idx);
            pr_tab_bens(vr_index_bem).cdsequen:= idx;
            pr_tab_bens(vr_index_bem).nrdrowid:= rw_crabavt.ROWID;
            pr_tab_bens(vr_index_bem).cddopcao:= pr_cddopcao;
            pr_tab_bens(vr_index_bem).cpfdoben:= pr_tab_crapavt(vr_index).nrcpfcgc;
          END IF;
        END LOOP;
      END IF;

      --Se possuir dados tabela
      IF pr_tab_crapavt.EXISTS(vr_index) THEN
        pr_tab_crapavt(vr_index).dtadmsoc:= rw_crabavt.dtadmsoc;
        pr_tab_crapavt(vr_index).cddopcao:= pr_cddopcao;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_id_58: ' || SQLERRM;
    END;
  END pc_busca_dados_id_58;

  /* Buscar dados dos representantes/procuradores */
  PROCEDURE pc_busca_dados_58 (pr_cdcooper IN crapcop.cdcooper%type  --Codigo Cooperativa
                              ,pr_cdagenci IN crapass.cdagenci%type  --Codigo Agencia
                              ,pr_nrdcaixa IN INTEGER                --Numero Caixa
                              ,pr_cdoperad IN VARCHAR2               --Codigo Operador
                              ,pr_nmdatela IN VARCHAR2               --Nome Tela
                              ,pr_idorigem IN INTEGER                --Origem da chamada
                              ,pr_nrdconta IN crapass.nrdconta%type  --Numero da Conta
                              ,pr_idseqttl IN crapttl.idseqttl%type  --Sequencial Titular
                              ,pr_flgerlog IN BOOLEAN                --Erro no Log
                              ,pr_cddopcao IN VARCHAR2               --Codigo opcao
                              ,pr_nrdctato IN INTEGER                --Numero Contato
                              ,pr_nrcpfcto IN NUMBER                 --Numero Cpf Contato
                              ,pr_nrdrowid IN ROWID                  --Rowid Empresa participante
                              ,pr_tab_crapavt OUT typ_tab_crapavt_58   --Tabela Avalistas
                              ,pr_tab_bens OUT typ_tab_bens            --Tabela bens
                              ,pr_tab_erro OUT gene0001.typ_tab_erro   --Tabela Erro
                              ,pr_cdcritic OUT INTEGER                 --Codigo de erro
                              ,pr_dscritic OUT VARCHAR2) IS            --Retorno de Erro
  /* .............................................................................

   Programa: pc_busca_dados_58                 Antigo: b1wgen0058.p --> Busca_Dados
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Alisson C. Berrido
   Data    : Janeiro/2014.                        Ultima atualizacao: 10/11/2015

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Buscar dados dos procuradores do associado

   Alteracoes: 09/01/2014 - Conversao Progress >> Oracle (PLSQL) (Alisson-AMcom)

               10/11/2015 - Incluido o campo tt-crapavt.idrspleg, para verificar
                            se o representante é responsável legal pelo acesso
                            aos canais de autoatendimento e SAC(Jean Michel).

  ............................................................................. */
  BEGIN
    DECLARE
      /* Cursores Locais */
      --Selecionar Avalistas
      CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%type
                        ,pr_tpctrato IN crapavt.tpctrato%type
                        ,pr_nrdconta IN crapavt.nrdconta%type
                        ,pr_nrctremp IN crapavt.nrctremp%type) IS
        SELECT crapavt.rowid
              ,crapavt.nrdctato
              ,crapavt.nmdavali
              ,crapavt.nrtelefo
              ,crapavt.dsdemail
              ,crapavt.cdcooper
              ,crapavt.nrdconta
              ,crapavt.nrcpfcgc
        FROM crapavt
        WHERE crapavt.cdcooper = pr_cdcooper
        AND   crapavt.tpctrato = pr_tpctrato
        AND   crapavt.nrdconta = pr_nrdconta
        AND   crapavt.nrctremp = pr_nrctremp;

      --Selecionar Associado
      CURSOR cr_crapass IS
        SELECT crapass.idastcjt
        FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
          AND crapass.nrdconta = pr_nrdconta;

      rw_crapass cr_crapass%ROWTYPE;

      -- Selecionar poderes
      CURSOR cr_crappod(pr_cdcooper IN crappod.cdcooper%TYPE
                       ,pr_nrdconta IN crappod.nrdconta%TYPE
                       ,pr_nrdctato IN crappod.nrctapro%TYPE
                       ,pr_nrcpfpro IN crappod.nrcpfpro%TYPE
                       ,pr_cddpoder IN crappod.cddpoder%TYPE) IS

      SELECT crappod.flgconju
        FROM crappod
       WHERE crappod.cdcooper = pr_cdcooper
         AND crappod.nrdconta = pr_nrdconta
         AND crappod.nrctapro = pr_nrdctato
         AND crappod.nrcpfpro = pr_nrcpfpro
         AND crappod.cddpoder = pr_cddpoder;

      rw_crappod cr_crappod%ROWTYPE;

      -- Selecionar senha de acesso
      CURSOR cr_crapsnh(pr_cdcooper IN crapsnh.cdcooper%TYPE
                       ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                       ,pr_idseqttl IN crapsnh.idseqttl%TYPE
                       ,pr_tpdsenha IN crapsnh.tpdsenha%TYPE
                       ,pr_nrcpfcgc IN crapsnh.nrcpfcgc%TYPE) IS

      SELECT crapsnh.cdcooper
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.idseqttl = pr_idseqttl
         AND crapsnh.tpdsenha = pr_tpdsenha
         AND crapsnh.nrcpfcgc = pr_nrcpfcgc;

      rw_crapsnh cr_crapsnh%ROWTYPE;

      --Variaveis Locais
      vr_nrdrowid ROWID;
      vr_indtrans INTEGER;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_indextmp INTEGER;
      --Tabela memoria erros
      vr_tab_erro gene0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_cdcritic2 crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      vr_dscritic2 VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro   EXCEPTION;
      vr_exc_busca  EXCEPTION;
      vr_exc_filtro EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Limpar tabelas
      pr_tab_erro.DELETE;
      pr_tab_crapavt.DELETE;

      --Buscar a origem
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      --Buscar Transacao
      vr_dstransa:= 'Busca dados do Representante/Procurador';

      -- Buscar dados do associado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;

      -- Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        vr_dscritic := '009 - Associado nao cadastrado.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;

      --Bloco Busca
      BEGIN
        --Bloco Filtro
        BEGIN
          --Se o rowid do avalista foi informado
          IF pr_nrdrowid IS NOT NULL THEN
            --Buscar Dados Representantes/Procuradores pelo ROWID
            pc_busca_dados_id_58 (pr_cdcooper => pr_cdcooper     --Codigo Cooperativa
                                 ,pr_nrdconta => pr_nrdconta     --Numero da Conta
                                 ,pr_nrdrowid => pr_nrdrowid     --Rowid Empresa participante
                                 ,pr_cddopcao => pr_cddopcao     --Codigo opcao
                                 ,pr_tab_crapavt => pr_tab_crapavt --Tabela Representantes/Procuradores
                                 ,pr_tab_bens    => pr_tab_bens    --Tabela Bens
                                 ,pr_cdcritic => vr_cdcritic     --Codigo de erro
                                 ,pr_dscritic => vr_dscritic);   --Retorno de Erro
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_filtro;
            END IF;


          ELSE
            --Numero contato ou cpf contato preenchido
            IF nvl(pr_nrdctato,0) <> 0 OR Nvl(pr_nrcpfcto,0) <> 0 THEN
              --Buscar Dados Representantes/Procuradores pela conta contato
              pc_busca_dados_cto_58 (pr_cdcooper => pr_cdcooper       --Codigo Cooperativa
                                    ,pr_nrdconta => pr_nrdconta       --Numero da Conta
                                    ,pr_idseqttl => pr_idseqttl       --Sequencial Titular
                                    ,pr_nrdctato => pr_nrdctato       --Numero Contato
                                    ,pr_nrcpfcto => pr_nrcpfcto       --Numero Cpf Contato
                                    ,pr_cddopcao => pr_cddopcao       --Codigo opcao
                                    ,pr_tab_crapavt => pr_tab_crapavt --Tabela Representantes/Procuradores
                                    ,pr_cdcritic => vr_cdcritic       --Codigo de erro
                                    ,pr_dscritic => vr_dscritic);     --Retorno de Erro
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_filtro;
              END IF;
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_filtro THEN
            NULL;
        END; --Filtro Busca
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_busca;
        END IF;
        --Opcao
        IF pr_cddopcao <> 'C' THEN
          RAISE vr_exc_busca;
        END IF;

        /* Carrega a lista de procuradores */
        FOR rw_crapavt IN cr_crapavt (pr_cdcooper => pr_cdcooper
                                     ,pr_tpctrato => 6 /*procuradores*/
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctremp => pr_idseqttl) LOOP
          --Buscar Dados pelo ID
          pc_busca_dados_id_58 (pr_cdcooper => pr_cdcooper     --Codigo Cooperativa
                               ,pr_nrdconta => pr_nrdconta     --Numero da Conta
                               ,pr_nrdrowid => rw_crapavt.rowid --Rowid Procurador
                               ,pr_cddopcao => pr_cddopcao     --Codigo opcao
                               ,pr_tab_crapavt => pr_tab_crapavt --Tabela Procuradores
                               ,pr_tab_bens    => pr_tab_bens    --Tabela Bens
                               ,pr_cdcritic => vr_cdcritic     --Codigo de erro
                               ,pr_dscritic => vr_dscritic);   --Retorno de Erro
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_busca;
          END IF;

          vr_indextmp := pr_tab_crapavt.LAST;

          /* Verifica de Ass. Conjunta JMD */
          IF rw_crapass.idastcjt = 1 THEN
            OPEN cr_crappod(pr_cdcooper => rw_crapavt.cdcooper
                           ,pr_nrdconta => rw_crapavt.nrdconta
                           ,pr_nrdctato => rw_crapavt.nrdctato
                           ,pr_nrcpfpro => rw_crapavt.nrcpfcgc
                           ,pr_cddpoder => 10);

            FETCH cr_crappod INTO rw_crappod;

            -- Se nao encontrar
            IF cr_crappod%NOTFOUND THEN
              pr_tab_crapavt(vr_indextmp).idrspleg := 0;
            ELSE
              pr_tab_crapavt(vr_indextmp).idrspleg := NVL(rw_crappod.flgconju,0);
            END IF;

            CLOSE cr_crappod;

          ELSE
            OPEN cr_crapsnh(pr_cdcooper => rw_crapavt.cdcooper
                           ,pr_nrdconta => rw_crapavt.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_tpdsenha => 1
                           ,pr_nrcpfcgc => rw_crapavt.nrcpfcgc);

            FETCH cr_crapsnh INTO rw_crapsnh;

            -- Se nao encontrar
            IF cr_crapsnh%NOTFOUND THEN
              CLOSE cr_crapsnh;
              pr_tab_crapavt(vr_indextmp).idrspleg := 0;
            ELSE
              pr_tab_crapavt(vr_indextmp).idrspleg := 1;
              CLOSE cr_crapsnh;
            END IF;
          END IF;
          /* Fim verifica de Ass. Conjunta JMD */

        END LOOP; --rw_crapavt
      EXCEPTION
        WHEN vr_exc_busca THEN
          NULL;
      END; --Busca

      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Gerar Erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        --Se ocorreu erro
        IF vr_cdcritic2 IS NOT NULL OR vr_dscritic2 IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Marcar flag erro
        vr_indtrans:= 0;
      ELSE
        vr_indtrans:= 1;
      END IF;

      --Se deve escrever no Log
      IF pr_flgerlog AND pr_cddopcao = 'C' THEN
        --Gerar log
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => SYSDATE
                            ,pr_flgtrans => vr_indtrans
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro em CADA0001.pc_busca_dados_58: ' || SQLERRM;
    END;
  END pc_busca_dados_58;

  /*  Procedure para calcular o faturamento medio mensal das pessoas juridicas. */
  PROCEDURE pc_calcula_faturamento(pr_cdcooper IN crapcop.cdcooper%type  -- Codigo Cooperativa
                                  ,pr_cdagenci IN crapass.cdagenci%type  -- Codigo Agencia
                                  ,pr_nrdcaixa IN INTEGER                -- Numero Caixa
                                  ,pr_nrdconta IN crapass.nrdconta%type  -- Numero da Conta
                                  ,pr_vlmedfat OUT NUMBER                -- Valor medio faturamento
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro -- Tabela Erro
                                  ,pr_des_reto OUT VARCHAR2) IS          -- Retorno (OK/NOK)
  BEGIN
    /* .............................................................................

     Programa: pc_calcula_faturamento                 Antigo: b1wgen9999.p --> calcula-faturamento
     Sistema : CRED
     Sigla   : CADA0001
     Autor   : Marcos E. Martini
     Data    : Agosto/2014.                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamada.
     Objetivo  : Procedure para calcular o faturamento medio mensal das pessoas juridicas.

     Alteracoes: 28/08/2014 - Conversao Progress >> Oracle (PLSQL) (Marcos-Supero)

    ............................................................................. */
    DECLARE
      -- Criticas
      vr_dscritic varchar2(4000);
      -- Busca do cadastro da PJ
      CURSOR cr_crapjfn IS
        SELECT -- somente utilizar o valor se mês de faturamento for dif. de zero
              (decode(mesftbru##1,0,0,vlrftbru##1) +
               decode(mesftbru##2,0,0,vlrftbru##2) +
               decode(mesftbru##3,0,0,vlrftbru##3) +
               decode(mesftbru##4,0,0,vlrftbru##4) +
               decode(mesftbru##5,0,0,vlrftbru##5) +
               decode(mesftbru##6,0,0,vlrftbru##6) +
               decode(mesftbru##7,0,0,vlrftbru##7) +
               decode(mesftbru##8,0,0,vlrftbru##8) +
               decode(mesftbru##9,0,0,vlrftbru##9) +
               decode(mesftbru##10,0,0,vlrftbru##10)+
               decode(mesftbru##11,0,0,vlrftbru##11)+
               decode(mesftbru##12,0,0,vlrftbru##12)) valormes

             ,(decode(mesftbru##1,0,0,1) +
               decode(mesftbru##2,0,0,1) +
               decode(mesftbru##3,0,0,1) +
               decode(mesftbru##4,0,0,1) +
               decode(mesftbru##5,0,0,1) +
               decode(mesftbru##6,0,0,1) +
               decode(mesftbru##7,0,0,1) +
               decode(mesftbru##8,0,0,1) +
               decode(mesftbru##9,0,0,1) +
               decode(mesftbru##10,0,0,1) +
               decode(mesftbru##11,0,0,1) +
               decode(mesftbru##12,0,0,1)) numermes

          FROM crapjfn
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapjfn cr_crapjfn%ROWTYPE;
      -- Variaveis para acumular o valor e quantidade de meses com valor
      vr_numermes PLS_INTEGER;
      vr_valormes NUMBER;
      -- Subrotina para retornar 1 se o valor passado é maior que zero
      FUNCTION fn_somase_valor_mes(pr_vlrmes## IN NUMBER) RETURN NUMBER IS
      BEGIN
        IF pr_vlrmes## <> 0 THEN
          -- Tem valor no mes, somar
          RETURN 1;
        ELSE
          RETURN 0;
        END IF;
      END;
    BEGIN
      -- Busca do cadastro da PJ
      OPEN cr_crapjfn;
      FETCH cr_crapjfn
       INTO rw_crapjfn;
      -- Se não encoutro
      IF cr_crapjfn%NOTFOUND THEN
        CLOSE cr_crapjfn;
        -- Gerar erro
        vr_dscritic := 'Registro de dados financeiros do cooperado nao encontrado';
        --Gerar Erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        pr_des_reto := 'NOK';
      ELSE
        CLOSE cr_crapjfn;

        -- Retornar valor acumulado / quantidade de meses com valor
        IF rw_crapjfn.numermes > 0 THEN
          pr_vlmedfat := rw_crapjfn.valormes / rw_crapjfn.numermes;
        END IF;
        pr_des_reto := 'OK';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro não tratado em CADA0001.pc_calcula_faturamento: ' || SQLERRM;
        --Gerar Erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        pr_des_reto := 'NOK';
    END;
  END pc_calcula_faturamento;

  -- Validar o operador migrado
  PROCEDURE pc_valida_operador_migrado(pr_cdcooper   IN crapopm.cdcooper%TYPE     -- Código da Cooperativa
                                      ,pr_cdoperad   IN crapopm.cdoperad%TYPE     -- Código do operador
                                      ,pr_cdagenci   IN craperr.cdagenci%TYPE     -- Código da agencia
                                      ,pr_nrdconta   IN craptco.nrctaant%TYPE     -- Número da conta
                                      ,pr_tab_erro  OUT gene0001.typ_tab_erro) IS -- Tabela Erro
  /* ..........................................................................................

   Programa: pc_valida_operador_migrado     Antigo: b1wgen9998.p --> valida_operador_migrado
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Renato Darosci
   Data    : Agosto/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Buscar dados e validar operadores migrados

   Alteracoes: 05/08/2014 - Conversao Progress >> Oracle (PLSQL) (Renato - Supero)

  .......................................................................................... */

    -- CURSORES
    -- Buscar operadores que foram migrados e podem acessar algumas telas na cooperativa antiga
    CURSOR cr_crapopm IS
      SELECT 1
        FROM crapopm
       WHERE (crapopm.cdopenov = pr_cdoperad
           OR crapopm.cdoperad = pr_cdoperad)
         AND crapopm.cdcopnov = 16
         AND crapopm.cdcooper = pr_cdcooper
         AND crapopm.flgativo = 1;

    -- Buscar contas transferidas entre cooperativas
    CURSOR cr_craptco IS
      SELECT 1
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcooper
         AND craptco.nrctaant = pr_nrdconta
         AND NVL(craptco.tpctatrf,-1) <> 3;

    -- Variáveis
    vr_cdcritic     CONSTANT NUMBER := 36;
    vr_dscritic     VARCHAR2(1000);
    vr_inregist     NUMBER;
    vr_opmigrad     BOOLEAN := FALSE;

  BEGIN

    -- Buscar os operadores migrados
    OPEN  cr_crapopm;
    FETCH cr_crapopm INTO vr_inregist;

    -- Verifica se encontrou registros
    IF cr_crapopm%FOUND THEN
      -- Setar o indicador para TRUE
      vr_opmigrad := TRUE;

      -- buscar contas transferidas
      OPEN  cr_craptco;
      FETCH cr_craptco INTO vr_inregist;

      -- Se não encontrar a conta...
      IF cr_craptco%NOTFOUND THEN
        -- Gerar Erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1      /** Sequencia **/
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

      END IF;

      -- Fecha cursor
      CLOSE cr_craptco;

    END IF;

    -- Fecha cursor
    CLOSE cr_crapopm;

  END pc_valida_operador_migrado;
  
  /* Procedure para realizar a gravacao dos dados das anotacoes */
  PROCEDURE pc_grava_dados (pr_cdcooper  IN crapcop.cdcooper%TYPE  -- Codigo Cooperativa
                           ,pr_cdoperad  IN crapobs.cdoperad%TYPE  -- Código do operador
                           ,pr_cdagenci  IN crapage.cdagenci%TYPE  -- Código da Agencia
                           ,pr_nrdcaixa  IN NUMBER                 -- Numero Caixa
                           ,pr_nmdatela  IN VARCHAR2               -- Nome da tela
                           ,pr_idorigem  IN NUMBER                 -- Indicador de origem
                           ,pr_nrdconta  IN crapass.nrdconta%TYPE  -- Número da Conta
                           ,pr_nrseqdig  IN crapobs.nrseqdig%TYPE  -- Sequencia de digitacao
                           ,pr_dsobserv  IN crapobs.dsobserv%TYPE  -- Observação
                           ,pr_flgprior  IN crapobs.flgprior%TYPE  -- Prioridade da observacao 
                           ,pr_cddopcao  IN VARCHAR2               -- Opção I - Incluir, A - Alterar e E - Excluir
                           ,pr_dtmvtolt  IN DATE                   -- Data da observação
                           ,pr_flgerlog  IN BOOLEAN                -- Erro no Log
                           ,pr_tab_erro OUT gene0001.typ_tab_erro  -- Tabela Erro
                           ,pr_cdcritic OUT INTEGER                -- Codigo de erro
                           ,pr_dscritic OUT VARCHAR2) IS           -- Retorno de Erro
                           
  /* .............................................................................

   Programa: pc_grava_dados                 Antigo: b1wgen0085.p --> Grava_Dados
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Renato Darosci
   Data    : Maio/2015.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Procedure para realizar a gravacao dos dados das anotacoes

   Alteracoes: 21/05/2015 - Conversao Progress >> Oracle (PLSQL) (Renato-Supero) 
   
               29/09/2015 - Correção na busca do próximo nrseqdig (Marcos-Supero)

  ............................................................................. */

    -- Cursores Locais
    -- Buscar informações da observação
    CURSOR cr_crapobs IS
      SELECT ROWID   dsdrowid
        FROM crapobs 
       WHERE crapobs.cdcooper = pr_cdcooper 
         AND crapobs.nrdconta = pr_nrdconta 
         AND crapobs.nrseqdig = pr_nrseqdig;
    rw_crapobs   cr_crapobs%ROWTYPE;
    
    -- Buscar o último nrseqdig ultilizado
    CURSOR cr_nrseqdig IS
      SELECT NVL(MAX(crapobs.nrseqdig),0)+1 nrseqdig
        FROM crapobs 
       WHERE crapobs.cdcooper = pr_cdcooper 
         AND crapobs.nrdconta = pr_nrdconta;
    
    --Variaveis Locais
    vr_nrseqdig        crapobs.nrseqdig%TYPE;
    vr_dsorigem        VARCHAR2(10);
    vr_dstransa        VARCHAR2(100);
    vr_nrdrowid        ROWID;
    
    --Variaveis de erro
    vr_cdcritic        crapcri.cdcritic%TYPE;
    vr_dscritic        VARCHAR2(4000);
      
    --Variaveis de Excecao
    vr_exc_erro        EXCEPTION;
    
  BEGIN
    
    --Inicializar parametros de erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;

    -- Descrição da origem
    vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
      
    -- Verifica a transação
    IF    pr_cddopcao = 'I' THEN
      vr_dstransa := 'Inclusao';
    ELSIF pr_cddopcao = 'A' THEN
      vr_dstransa := 'Alteracao';
    ELSE  
      vr_dstransa := 'Exclusao';
    END IF;

    -- Concatenar o restante da mensagem
    vr_dstransa := vr_dstransa||' de Anotacoes';

    -- Buscar o registro da observação
    OPEN  cr_crapobs;
    FETCH cr_crapobs INTO rw_crapobs;
    
    -- Se não encontrar registro
    IF cr_crapobs%NOTFOUND THEN
      -- Verifica se a opção é Inclusão
      IF pr_cddopcao = 'I' THEN
        -- Buscar o ultimo nrseqdig utilizado
        OPEN  cr_nrseqdig;
        FETCH cr_nrseqdig INTO vr_nrseqdig;
        -- Em caso de nenhum retorno
        IF cr_nrseqdig%NOTFOUND THEN
          vr_nrseqdig := 1; -- Assume o valor 1
        END IF;
        CLOSE cr_nrseqdig;

        -- Inserir o novo registro de observação
        BEGIN
          
          INSERT INTO crapobs
                    (nrdconta
                    ,dtmvtolt
                    ,nrseqdig
                    ,cdoperad
                    ,hrtransa
                    ,cdcooper)
             VALUES (pr_nrdconta              -- nrdconta
                    ,pr_dtmvtolt              -- dtmvtolt
                    ,vr_nrseqdig              -- nrseqdig
                    ,pr_cdoperad              -- cdoperad
                    ,GENE0002.fn_busca_time() -- hrtransa
                    ,pr_cdcooper)             -- cdcooper
             RETURNING ROWID INTO rw_crapobs.dsdrowid;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir CRAPOBS. '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      ELSE -- Se não encontrou e a operação é de alteração ou exclusão
        -- Retorna a critica
        vr_dscritic := 'Registro da anotacao nao foi encontrado.';
        RAISE vr_exc_erro;
      END IF;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_crapobs;
      
    -- Se estiver numa operação de exclusão
    IF pr_cddopcao = 'E' THEN
      -- Excluir o registro de observação
      BEGIN
        DELETE crapobs 
         WHERE ROWID = rw_crapobs.dsdrowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir CRAPOBS. '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    ELSE
      -- Atualizar os campos da observação 
      BEGIN
        UPDATE crapobs
           SET crapobs.dsobserv = UPPER(pr_dsobserv)
             , crapobs.flgprior = pr_flgprior
         WHERE ROWID = rw_crapobs.dsdrowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPOBS. '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Verifica se há erro
      IF  vr_dscritic IS NOT NULL OR vr_cdcritic > 0 THEN
        --Gerar Erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se for para gerar log
        IF pr_flgerlog THEN
          -- gerar log
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => SYSDATE
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => GENE0002.fn_busca_time
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;  
      END IF;
        
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic:= 0;
      pr_dscritic := 'Erro em CADA0001.pc_busca_conta: ' || SQLERRM;
  END pc_grava_dados;

  -- Listar cooperativa ayllosweb
  PROCEDURE pc_lista_cooperativas_web(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                     ,pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo         
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
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
    --  Alteracoes: 15/04/2016 - Replicar codigo para a CADA0001 para deixar a rotina generica e nao necessario 
    --                           criar para cada tela (Odirlei-AMcom)
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
        pr_des_erro := 'Erro geral em pc_lista_cooperativas_web: ' || SQLERRM;
        pr_dscritic := 'Erro geral em pc_lista_cooperativas_web: ' || SQLERRM;
    END;
  END pc_lista_cooperativas_web;
  
    
  
  --> Identificar Orgão Expedidor
  PROCEDURE pc_busca_id_orgao_expedidor (pr_cdorgao_expedidor   IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE, 
                                         pr_idorgao_expedidor  OUT tbgen_orgao_expedidor.idorgao_expedidor%TYPE, 
                                         pr_cdcritic           OUT INTEGER,
                                         pr_dscritic           OUT VARCHAR2)  IS

  
  /* .............................................................................

   Programa: pc_busca_id_orgao_expedidor
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Odirlei Busana(AMcom)
   Data    : Julho/2017.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Identificar o id da tabela tbgen_orgao_expedidor atraves do cdorgao_expedidor

   Alteracoes: 

  ............................................................................. */
  
    --> Buscar id do orgao expedidor
    CURSOR cr_orgexp IS
      SELECT org.idorgao_expedidor
        FROM tbgen_orgao_expedidor org
       WHERE UPPER(org.cdorgao_expedidor) = UPPER(pr_cdorgao_expedidor);
    rw_orgexp cr_orgexp%ROWTYPE;
    
    vr_exc_erro EXCEPTION;
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
  BEGIN
    
    rw_orgexp := NULL;
    --> Buscar id do orgao expedidor
    OPEN cr_orgexp;
    FETCH cr_orgexp INTO pr_idorgao_expedidor;
    
    IF cr_orgexp%NOTFOUND OR 
       nvl(pr_idorgao_expedidor,0) = 0 THEN
      CLOSE cr_orgexp; 
      vr_dscritic := 'Orgao Emissor nao cadastrado.';
      RAISE vr_exc_erro;       
    END IF;
    CLOSE cr_orgexp;
    
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao identificar orgao Emissor: '||SQLERRM;
    
  END pc_busca_id_orgao_expedidor;
  
  --> Buscar dados Orgão Expedidor
  PROCEDURE pc_busca_orgao_expedidor (pr_idorgao_expedidor   IN tbgen_orgao_expedidor.idorgao_expedidor%TYPE, 
                                      pr_cdorgao_expedidor  OUT tbgen_orgao_expedidor.cdorgao_expedidor%TYPE, 
                                      pr_nmorgao_expedidor  OUT tbgen_orgao_expedidor.nmorgao_expedidor%TYPE, 
                                      pr_cdcritic           OUT INTEGER,
                                      pr_dscritic           OUT VARCHAR2)  IS

  
  /* .............................................................................

   Programa: pc_busca_id_orgao_expedidor
   Sistema : CRED
   Sigla   : CADA0001
   Autor   : Odirlei Busana(AMcom)
   Data    : Julho/2017.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Identificar o id da tabela tbgen_orgao_expedidor atraves do cdorgao_expedidor

   Alteracoes: 

  ............................................................................. */
  
    --> Buscar id do orgao expedidor
    CURSOR cr_orgexp IS
      SELECT org.cdorgao_expedidor,
             org.nmorgao_expedidor
        FROM tbgen_orgao_expedidor org
       WHERE org.idorgao_expedidor = pr_idorgao_expedidor;
    rw_orgexp cr_orgexp%ROWTYPE;
    
    vr_exc_erro EXCEPTION;
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
  BEGIN
    
    rw_orgexp := NULL;
    --> Buscar id do orgao expedidor
    OPEN cr_orgexp;
    FETCH cr_orgexp INTO rw_orgexp;
    
    IF cr_orgexp%NOTFOUND THEN
       CLOSE cr_orgexp;
       vr_dscritic := 'Orgao Emissor nao cadastrado.';
       RAISE vr_exc_erro;       
    END IF;
    CLOSE cr_orgexp;
    
    pr_cdorgao_expedidor := rw_orgexp.cdorgao_expedidor;
    pr_nmorgao_expedidor := rw_orgexp.nmorgao_expedidor;
 
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao buscar orgao Emissor: '||SQLERRM;
    
  END pc_busca_orgao_expedidor;
    
  
END CADA0001;
/
