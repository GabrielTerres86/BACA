CREATE OR REPLACE PACKAGE CECRED.gene0005 IS
  /*---------------------------------------------------------------------------------------------------------------

    Programa : GENE0005
    Sistema  : Rotinas auxiliares para busca de informacõees do negocio
    Sigla    : GENE
    Autor    : Marcos Ernani Martini - Supero
    Data     : Maio/2013.                   Ultima atualizacao: 14/03/2018

   Dados referentes ao programa:

   Frequencia: -----
   Objetivo  : Centralizar rotinas auxiliares para buscas de informacões do negocio

   Observacoes: Conversao da function B1wgen0055.ValidaNome para PL/SQL -> pc_valida_nome
                (Jean Michel).

   Alterações: 20/03/2017 - Ajuste para disponibilizar as rotinas de validação de cpf e cnpj como públicas
                           (Adriano - SD 620221).
							 14/03/2018 - Ajuste na pc_saldo_utiliza para considerar contas em prejuízo

  ---------------------------------------------------------------------------------------------------------------*/

  -- Tipo tabela para comportar um registro com os dados de feriado
  TYPE typ_tab_feriado IS
    TABLE OF DATE
    INDEX BY BINARY_INTEGER;

  -- Vetor para armazenar as informacões dos feriados
  vr_tab_feriado typ_tab_feriado;

  /* Procedimento padrão de busca de informacões de CPMF */
  PROCEDURE pc_busca_cpmf(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                         ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                         ,pr_dtinipmf OUT DATE
                         ,pr_dtfimpmf OUT DATE
                         ,pr_txcpmfcc OUT NUMBER
                         ,pr_txrdcpmf OUT NUMBER
                         ,pr_indabono OUT INTEGER
                         ,pr_dtiniabo OUT DATE
                         ,pr_cdcritic OUT NUMBER
                         ,pr_dscritic OUT VARCHAR2);

  /* Procedimento padrão de busca de informacões de IOF */
  PROCEDURE pc_busca_iof (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                         ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                         ,pr_dtiniiof  OUT DATE                 --> Data Inicio IOF
                         ,pr_dtfimiof  OUT DATE                 --> Data Final IOF
                         ,pr_txccdiof  OUT NUMBER               --> Taxa iof
                         ,pr_cdcritic  OUT NUMBER               --> Codigo do erro
                         ,pr_dscritic  OUT VARCHAR2);           --> Retorno de erro

  /* Procedimento padrão de busca de informacões de IOF para Emprestimos */
  PROCEDURE pc_busca_iof_rdca (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                              ,pr_dtiniiof  OUT DATE                 --> Data Inicio IOF
                              ,pr_dtfimiof  OUT DATE                 --> Data Final IOF
                              ,pr_txiofrda  OUT NUMBER               --> Taxa iof rdca
                              ,pr_cdcritic  OUT NUMBER               --> Codigo do erro
                              ,pr_dscritic  OUT VARCHAR2);           --> Retorno de erro

  /* Programa para Buscar as Contas Centralizadoras do BBrasil. */
  FUNCTION fn_busca_conta_centralizadora (pr_cdcooper IN gnctace.cdcooper%TYPE     --> Cooperativa
                                         ,pr_tpregist IN gnctace.tpregist%TYPE)    --> Tipo de registro desejado
                                         RETURN VARCHAR2;

  /* Rotina responsavel por retornar a conta integracão com digito convertido */
  PROCEDURE pc_conta_itg_digito_zero (pr_nrdctitg IN crapass.nrdctitg%TYPE          --> Numero da conta integracão
                                     ,pr_ctpsqitg IN OUT NUMBER                     --> Numero da conta integracão com digito
                                     ,pr_des_erro IN OUT VARCHAR2);                 --> Retorno de Erro

  /* Rotina responsavel pela verificacão da conta integracão do associado */
  PROCEDURE pc_existe_conta_integracao (pr_cdcooper IN crapass.cdcooper%TYPE        --> Codigo da Cooperativa
                                       ,pr_ctpsqitg IN craplcm.nrdctabb%TYPE        --> Numero da conta integracão p/ pesquisa
                                       ,pr_nrdctitg OUT crapass.nrdctitg%TYPE       --> Numero da conta integracão com digito
                                       ,pr_nrctaass OUT crapass.nrdconta%TYPE       --> Numero da conta do associado
                                       ,pr_des_erro OUT VARCHAR2);                  --> Retorno de Erro

  /* Rotina responsavel por retornar a conta integracão com digito convertido */
  procedure pc_conta_itg_digito_x (pr_nrcalcul in number,
                                   pr_dscalcul out varchar2,
                                   pr_stsnrcal out number, -- 1 verdadeiro; 0 falso
                                   pr_cdcritic out crapcri.cdcritic%type,
                                   pr_dscritic out varchar2);

  /* Funcão para validar o digito verificador */
  FUNCTION fn_valida_digito_verificador(pr_nrdconta IN NUMBER) RETURN BOOLEAN;  --> Npumero da conta

  /* Calcular o valor utilizado (credito) do Associado */
  PROCEDURE pc_saldo_utiliza (pr_cdcooper IN crapcop.cdcooper%TYPE              --> Codigo da Cooperativa
                             ,pr_tpdecons IN PLS_INTEGER                        --> Tipo da consulta (Ver observacões da rotina)
                             ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT NULL --> Codigo da agencia
                             ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL --> Numero do caixa
                             ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL --> Codigo do operador
                             ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT NULL --> OU Consulta pela conta
                             ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE DEFAULT NULL --> OU Consulta pelo Numero do cpf ou cgc do associado
                             ,pr_idseqttl IN crapttl.idseqttl%TYPE DEFAULT NULL --> Sequencia de titularidade da conta
                             ,pr_idorigem IN INTEGER               DEFAULT NULL --> Indicador da origem da chamada
                             ,pr_dsctrliq IN VARCHAR2                           --> Numero do contrato de liquidacao
                             ,pr_cdprogra IN crapprg.cdprogra%TYPE              --> Codigo do programa chamador
                             ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE        --> Tipo de registro de datas
                             ,pr_inusatab IN BOOLEAN                            --> Indicador de utilizacão da tabela de juros
                             ,pr_vlutiliz OUT NUMBER                            --> Valor utilizado do credito
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Codigo de retorno da critica
                             ,pr_dscritic OUT VARCHAR2);                        --> Mensagem de retorno da critica

    /* Rotina para retorno de valores bloqueados judicialmente para o cooperado */
  PROCEDURE pc_retorna_valor_blqjud(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE --> CPF/CGC
                                   ,pr_cdtipmov IN PLS_INTEGER           --> Tipo do movimento
                                   ,pr_cdmodali IN PLS_INTEGER           --> Modalidade
                                   ,pr_dtmvtolt IN DATE                  --> Data atual
                                   ,pr_vlbloque OUT NUMBER               --> Valor bloqueado
                                   ,pr_vlresblq OUT NUMBER               --> Valor que falta bloquear
                                   ,pr_dscritic OUT VARCHAR2);           --> Erros encontrados no processo

  /* Funcão para validar se o dia e util e, se não for, retornar o proximo ou o anterior */
  function fn_valida_dia_util(pr_cdcooper in crapcop.cdcooper%type, --> Cooperativa conectada
                              pr_dtmvtolt in crapdat.dtmvtolt%type, --> Data do movimento
                              pr_tipo in varchar2 default 'P',       --> Tipo de busca (P = proximo, A = anterior)
                              pr_feriado IN BOOLEAN DEFAULT TRUE,     --> Considerar feriados
                              pr_excultdia IN BOOLEAN DEFAULT FALSE --Desconsiderar Feriado 31/12
                             ) RETURN DATE;

  /* Procedimento para validar se o dia e util e, se não for, retornar o proximo ou o anterior
     Chamada para ser utilizada no progress */
  PROCEDURE pc_valida_dia_util(pr_cdcooper  IN crapcop.cdcooper%type,     --> Cooperativa conectada
                               pr_dtmvtolt  IN OUT crapdat.dtmvtolt%type, --> Data do movimento
                               pr_tipo      IN varchar2 default 'P',      --> Tipo de busca (P = proximo, A = anterior)
                               pr_feriado   IN INTEGER DEFAULT 1,         --> Considerar feriados ( 0-False, 1-True)
                               pr_excultdia IN INTEGER DEFAULT 0 );       --> Desconsiderar Feriado 31/12 ( 0-False, 1-True)

  --Validar o cpf
  PROCEDURE pc_valida_cpf (pr_nrcalcul IN NUMBER --Numero a ser verificado
                          ,pr_stsnrcal OUT BOOLEAN); --Situacao

  --Validar o cnpj
  PROCEDURE pc_valida_cnpj (pr_nrcalcul IN NUMBER  --Numero a ser verificado
                           ,pr_stsnrcal OUT BOOLEAN); --Situacao

  /* Procedure para validar cpf ou cnpj */
  PROCEDURE pc_valida_cpf_cnpj (pr_nrcalcul IN NUMBER       --Numero a ser verificado
                               ,pr_stsnrcal OUT BOOLEAN     --Situacao
                               ,pr_inpessoa OUT INTEGER);   --Tipo Inscricao Cedente

  /* Funcao para retornar digito cnpj */
  FUNCTION fn_retorna_digito_cnpj (pr_nrcalcul IN NUMBER) RETURN NUMBER;  --Numero a ser verificado

  /* Funcao retorna o codigo da cooperativa a partir do numero da conta junto a CECRED*/
  FUNCTION fn_cdcooper_nrctactl (pr_nrctactl IN  crapcop.nrctactl%TYPE) RETURN NUMBER; -- Numero da conta junto a cecred

  /* retorna o codigo da ultima cooperativa cadastrada*/
  FUNCTION fn_ultima_cdcooper RETURN NUMBER;

  /* Calcular o dígito verificador da conta */
  FUNCTION fn_calc_digito(pr_nrcalcul IN OUT NUMBER                             --> Número da conta
                         ,pr_reqweb   IN BOOLEAN DEFAULT FALSE) RETURN BOOLEAN; --> Identificador se a requisição é da Web

  FUNCTION fn_dtfun(pr_dtcalcul IN DATE , -- data para ser calculada.
                    pr_qtdmeses IN NUMBER -- qtd de meses a ser somado ou diminuido da data informada no parametro.
                    ) RETURN DATE;

  /* Calcular nro de meses/dias recebendo como parametro data inicio e data fim */
  PROCEDURE pc_calc_mes(pr_datadini   IN DATE    --> Data base inicio
                       ,pr_datadfim   IN DATE    --> Data base fim
                       ,pr_qtdadmes  OUT NUMBER  --> Quantidade de meses
                       ,pr_qtdadias  OUT NUMBER);--> Quantidade de dias

   --retornar a parte inteira e decimal de um valor
  PROCEDURE pc_intdec(pr_vlcalcul IN NUMBER, --valor a ser quebrado
                      pr_vlintcal OUT NUMBER, -- retorna valor inteiro
                      pr_vldeccal OUT NUMBER,-- retorna valor decimal
                      pr_des_erro OUT VARCHAR2 --mensagem de erro
                      );

  /* Calcular uma data futura conforme parâmetros */
  FUNCTION fn_calc_data(pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                       ,pr_qtmesano  IN INTEGER               --> Quantidade a acumular
                       ,pr_tpmesano  IN VARCHAR2              --> Tipo Mes ou Ano
                       ,pr_des_erro  OUT VARCHAR2) RETURN DATE;

  /* Validar Nome */
  FUNCTION fn_valida_nome(pr_nomedttl IN VARCHAR2                   --> Nome para Validacao
                         ,pr_inpessoa IN crapass.inpessoa%TYPE      --> Tipo de Pessoa(1 - Fisica / 2 - Juridica / 3 - Conta Administrativa)
                         ,pr_des_erro  OUT VARCHAR2) RETURN BOOLEAN;--> Mensagem de erro / (Retorno TRUE -> OK, FALSE -> NOK)

  /* Retorna a data por extenso em portugues */
  FUNCTION fn_data_extenso (pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE) --> Data do movimento
                   RETURN VARCHAR2;

  /* Procedimento para busca de motivos */
  PROCEDURE pc_busca_motivos (pr_cdproduto  IN tbgen_motivo.cdproduto%TYPE --> Cod. Produto
		                     ,pr_clobxmlc  OUT CLOB                        --XML com informações de LOG
                             ,pr_des_erro  OUT VARCHAR2                    --> Status erro
                             ,pr_dscritic  OUT VARCHAR2);

  PROCEDURE pc_gera_inconsistencia(pr_cdcooper IN tbgen_inconsist.cdcooper%TYPE --> Codigo Cooperativa
                                  ,pr_iddgrupo IN tbgen_inconsist.idinconsist_grp%TYPE --> Codigo do Grupo
                                  ,pr_tpincons IN tbgen_inconsist.tpinconsist%TYPE --> Tipo (1-Aviso, 2-Erro)
                                  ,pr_dsregist IN tbgen_inconsist.dsregistro_referencia%TYPE --> Desc. do registro de referencia
                                  ,pr_dsincons IN tbgen_inconsist.dsinconsist%TYPE --> Descricao da inconsistencia
                                  ,pr_flg_enviar IN VARCHAR2 DEFAULT 'N'            --> Indicador para enviar o e-mail na hora
                                  ,pr_des_erro OUT VARCHAR2 --> Status erro
                                  ,pr_dscritic OUT VARCHAR2); --> Retorno de erro

  FUNCTION fn_calc_qtd_dias_uteis(pr_cdcooper IN crapcop.cdcooper%TYPE
 		                         ,pr_dtinical IN DATE  --> Data de inicio do cálculo
 		                         ,pr_dtfimcal IN DATE) --> Data final do cálculo
 							      RETURN INTEGER;

  FUNCTION fn_valida_depart_operad(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
	                              ,pr_cdoperad IN crapope.cdoperad%TYPE --> Operador
		                          ,pr_dsdepart IN VARCHAR2              --> Lista de departamentos separados por ;
		                          ,pr_flgnegac IN INTEGER DEFAULT 0)    --> Flag de negação dos departamentos parametrizados (NOT IN pr_dsdepart)
								  RETURN INTEGER;

  END gene0005;
/
CREATE OR REPLACE PACKAGE BODY CECRED.gene0005 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GENE0005
  --  Sistema  : Rotinas auxiliares para busca de informacões do negocio
  --  Sigla    : GENE
  --  Autor    : Marcos Ernani Martini - Supero
  --  Data     : Maio/2013.                   Ultima atualizacao: 24/11/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas auxiliares para buscas de informacões do negocio
  -- Alteracoes:
  --             04/01/2016 - Alteração na chamada da rotina extr0001.pc_obtem_saldo_dia
  --                          para passagem do parâmetro pr_tipo_busca, para melhoria
  --                          de performance.
  --                          Chamado 291693 (Heitor - RKAM)
  --
  --             30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
  --
  --             10/06/2016 - Ajuste para inlcuir UPPER na leitura da tabela
  --                          crapass em campos de indice que possuem UPPER
  --                          (Adriano - SD 463762).
  --
  --			       16/12/2016 - Alterações Referentes ao projeto 300. (Reinert)
  --
  --             20/03/2017 - Ajuste para disponibilizar as rotinas de validação de cpf e cnpj como públicas
  --                          (Adriano - SD 620221).
  --
  --             23/03/2017 - Criado procedure para verificar departamento do operador. (Reinert)
  --
  --             15/05/2017 - Correcao na fn_valida_dia_util para abortar execucao quando for passada uma data nula.
  --                          SD 670255.(Carlos Rafael Tanholi)
  --
  --             16/05/2017 - Alterada a rotina pc_saldo_utiliza para quando chamada pelo crps405 não efetuar
  --                          novo cálculo pois o saldo do contrato já foi calculado anteriormente (Rodrigo)
  --
  --             28/09/2017 - Incluir validação para caso o tamanho do cpf for maior
  --                          que 11 posições não aceite o cadastro do mesmo
  --                          (Lucas Ranghetti #717352)
  --
  --             24/11/2017 - Correção na consulta de bloqueios judiciais pc_retorna_valor_blqjud, para somar todas
  --                          as ocorrencias e retornar o valor correto. SD 800517 (Carlos Rafael Tanholi)
  ---------------------------------------------------------------------------------------------------------------

   -- Variaveis utilizadas na PC_CONSULTA_ITG_DIGITO_X
   vr_nrctacef       crapprm.dsvlrprm%TYPE;
   vr_nrctaint       crapprm.dsvlrprm%TYPE;

  /* Tratamento de erro */
  vr_des_erro   VARCHAR2(4000);
  vr_exc_erro   EXCEPTION;

  /* Erro em chamadas da pc_gera_erro */
  vr_des_reto VARCHAR2(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  /* Procedimento padrão de busca de informacões de CPMF */
  PROCEDURE pc_busca_cpmf(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                         ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                         ,pr_dtinipmf OUT DATE
                         ,pr_dtfimpmf OUT DATE
                         ,pr_txcpmfcc OUT NUMBER
                         ,pr_txrdcpmf OUT NUMBER
                         ,pr_indabono OUT INTEGER
                         ,pr_dtiniabo OUT DATE
                         ,pr_cdcritic OUT NUMBER
                         ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_busca_cpmf (Antigo Fontes/ipmf.p)
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Deborah/Edson
    --   Data    : Agosto/93.                          Ultima atualizacao: 13/11/2012
    --
    --   Dados referentes ao programa:
    --   Frequencia: Diario (on-line)
    --   Objetivo  : Mostrar a tela IPMF.
    --
    --   Alteracoes: 25/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
    --               12/11/2012 - Conversão Progress --> Oracle PLSQL (Marcos - Supero)
    -- .............................................................................
    DECLARE
      vr_dstextab craptab.dstextab%TYPE;
    BEGIN
      -- Buscar dados de CPMF na tabela de parametros
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'USUARI'
                     ,pr_cdempres => 11
                     ,pr_cdacesso => 'CTRCPMFCCR'
                                               ,pr_tpregist => 1);
      -- Se encontrar
      IF vr_dstextab IS NOT NULL THEN
        -- Povoar as informacões conforme as regras da versão anterior
        pr_dtinipmf := TO_DATE(SUBSTR(vr_dstextab,1,10),'DD/MM/YYYY');
        pr_dtfimpmf := TO_DATE(SUBSTR(vr_dstextab,12,10),'DD/MM/YYYY');
        IF pr_dtmvtolt >= pr_dtinipmf AND pr_dtmvtolt <= pr_dtfimpmf THEN
          pr_txcpmfcc := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,23,13));
          pr_txrdcpmf := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,38,13));
        ELSE
          pr_txcpmfcc := 0;
          pr_txrdcpmf := 1;
        END IF;
        pr_indabono := SUBSTR(vr_dstextab,51,1); /* 0 = abona 1 = nao abona */
        pr_dtiniabo := TO_DATE(SUBSTR(vr_dstextab,53,10)); /* data de inicio do abono */
      ELSE
        -- Montar retorno de erro
        pr_cdcritic := 641;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 641);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Problemas ao buscar Tabela CPMF para Cooperativa '||pr_cdcooper||'. Erro: '||sqlerrm;
    END;
  END pc_busca_cpmf;

  /* Procedimento padrão de busca de informacões de IOF */
  PROCEDURE pc_busca_iof (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                         ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                         ,pr_dtiniiof  OUT DATE                 --> Data Inicio IOF
                         ,pr_dtfimiof  OUT DATE                 --> Data Final IOF
                         ,pr_txccdiof  OUT NUMBER               --> Taxa iof
                         ,pr_cdcritic  OUT NUMBER               --> Codigo do erro
                         ,pr_dscritic  OUT VARCHAR2) IS         --> Retorno de erro
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_busca_iof     (Antigo includes/iof.i)
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Magui
    --   Data    : Janeiro/2008                    Ultima atualizacao: 03/01/2008
    --
    --   Dados referentes ao programa:
    --   Frequencia: Diario (on-line)
    --   Objetivo  : Mostrar a tela IOF.
    --
    --   Alteracoes:  29/01/2013 - Conversão Progress --> Oracle PLSQL (Alisson - Amcom)
    -- .............................................................................
    DECLARE
      vr_dstextab craptab.dstextab%TYPE;
    BEGIN
      --Inicializa variavel de erro
      pr_dscritic := NULL;
      -- Buscar dados de CPMF na tabela de parametros
       vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'USUARI'
                     ,pr_cdempres => 11
                     ,pr_cdacesso => 'VLIOFOPFIN'
                     ,pr_tpregist => 1);
      -- Se encontrar
      IF vr_dstextab IS NOT NULL THEN
        -- Povoar as informacões conforme as regras da versão anterior
        pr_dtiniiof := TO_DATE(SUBSTR(vr_dstextab,1,10),'DD/MM/YYYY');
        pr_dtfimiof := TO_DATE(SUBSTR(vr_dstextab,12,10),'DD/MM/YYYY');
        IF pr_dtmvtolt BETWEEN  pr_dtiniiof AND pr_dtfimiof THEN
          pr_txccdiof := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,23,14));
        ELSE
          pr_txccdiof := 0;
        END IF;
      ELSE
        -- Montar retorno de erro
        pr_cdcritic := 915;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 915);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Problemas ao buscar Tabela IOF para Cooperativa '||pr_cdcooper||'. Erro na GENE0005.pc_busca_iof: '||sqlerrm;
    END;
  END pc_busca_iof;

  /* Procedimento padrão de busca de informacões de IOF para Emprestimos */
  PROCEDURE pc_busca_iof_rdca (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                              ,pr_dtiniiof  OUT DATE                 --> Data Inicio IOF
                              ,pr_dtfimiof  OUT DATE                 --> Data Final IOF
                              ,pr_txiofrda  OUT NUMBER               --> Taxa iof rdca
                              ,pr_cdcritic  OUT NUMBER               --> Codigo do erro
                              ,pr_dscritic  OUT VARCHAR2) IS         --> Retorno de erro
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_busca_iof_rdca
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Alisson
    --   Data    : Abril/2015                    Ultima atualizacao: 09/04/2015
    --
    --   Dados referentes ao programa:
    --   Frequencia: Diario (on-line)
    --   Objetivo  : Buscar Informacoes IOF sobre Emprestimos.
    --
    --   Alteracoes:  09/04/2015 - Conversão Progress --> Oracle PLSQL (Alisson - Amcom)
    -- .............................................................................
    DECLARE
      -- Variaveis Locais
      vr_dstextab craptab.dstextab%TYPE;

      --Excecao
      vr_exc_erro EXCEPTION;

    BEGIN
      --Inicializa variavel de erro
      pr_cdcritic := 0;
      pr_dscritic := NULL;

      /*  Tabela com a taxa do IOF */
      vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'USUARI'
                                                ,pr_cdempres => 11
                                                ,pr_cdacesso => 'CTRIOFRDCA'
                                                ,pr_tpregist => 1);

      -- se nao encontrar o parametro, aborta a execucao
      IF TRIM(vr_dstextab) IS NULL THEN
        RAISE vr_exc_erro;
      END IF;

      --periodo inicial da iof
      pr_dtiniiof:= TO_DATE(SUBSTR(vr_dstextab,1,10), 'DD/MM/YYYY');
      --periodo final da iof
      pr_dtfimiof:= TO_DATE(SUBSTR(vr_dstextab,12,10), 'DD/MM/YYYY');

      --ajusta valor da tarifa de iof conforme periodo selecionado
      IF pr_dtmvtolt >= pr_dtiniiof AND
         pr_dtmvtolt <= pr_dtfimiof THEN
        pr_txiofrda:= TO_NUMBER(SUBSTR(vr_dstextab,23,16));
      ELSE
        pr_txiofrda:= 0;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Montar retorno de erro
        pr_cdcritic := 626;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 626);
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Problemas ao buscar Tabela IOF para Cooperativa '||pr_cdcooper||'. Erro na GENE0005.pc_busca_iof_rdca: '||sqlerrm;
    END;
  END pc_busca_iof_rdca;

  /* Programa para Buscar as Contas Centralizadoras do BBrasil. */
  FUNCTION fn_busca_conta_centralizadora (pr_cdcooper IN gnctace.cdcooper%TYPE     --> Cooperativa
                                         ,pr_tpregist IN gnctace.tpregist%TYPE)    --> Tipo de registro desejado
                                         RETURN VARCHAR2 IS
  BEGIN
/* .............................................................................
   Programa: fn_busca_conta_centralizadora       Antigo Fontes/ver_ctace.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : ZE
   Data    : Dezembro/2008                       Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Programa para Buscar as Contas Centralizadoras do BBrasil.

   Alteracoes: 21/01/2013 - Conversão Progress para PLSQL (Alisson/AMcom)


............................................................................. */


    DECLARE

      -- Selecionar informacoes das contas centralizadoras
      CURSOR cr_gnctace (pr_cdcooper IN gnctace.cdcooper%TYPE
                        ,pr_tpregist IN gnctace.tpregist%TYPE) IS
        SELECT gnctace.nrctacen
        FROM gnctace gnctace
        WHERE gnctace.cdcooper = pr_cdcooper
        AND   gnctace.cddbanco = 1
        AND   ((pr_tpregist <> 0  AND gnctace.tpregist = pr_tpregist) OR
               (pr_tpregist = 0)
              );
      vr_lscontas VARCHAR2(4000):= NULL;
    BEGIN

      IF pr_tpregist < 0 OR pr_tpregist > 4 THEN
        RETURN NULL;
      END IF;
      --Selecionar contas centralziadoras
      FOR rw_gnctace IN cr_gnctace (pr_cdcooper => pr_cdcooper
                                   ,pr_tpregist => pr_tpregist) LOOP
        vr_lscontas:= vr_lscontas||LTrim(RTrim(rw_gnctace.nrctacen))||',';
      END LOOP;

      --Retirar a ultima virgula do final da linha
      vr_lscontas:= SubStr(vr_lscontas,1,Length(vr_lscontas)-1);

      RETURN(vr_lscontas);
    END;

  END fn_busca_conta_centralizadora;

  /* Rotina responsavel por retornar o digito da conta integracão */
  PROCEDURE pc_conta_itg_digito_zero (pr_nrdctitg IN crapass.nrdctitg%TYPE
                                     ,pr_ctpsqitg IN OUT NUMBER
                                     ,pr_des_erro IN OUT VARCHAR2) IS
  BEGIN
/* .............................................................................
   Programa: pc_conta_itg_digito_zero        Antigo includes/proc_conta_integracao.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima atualizacao: 27/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Procedures para descobrir se existe conta integracao.

   Alteracoes: 10/11/2005 - Criada procedure Conta digito zero (Magui).

               12/01/2006 - Aceita conta inativa (Magui).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               04/02/2013 - Conversão Progress para PLSQL (Alisson/AMcom)


............................................................................. */
    DECLARE

      --Variaveis Locais
      vr_nrdctitg VARCHAR2(8);
      vr_nrdigitg VARCHAR2(1);
      --Variavel de Excecão
      vr_exc_saida EXCEPTION;
    BEGIN

      --Inicializar mensagem de erro
      pr_des_erro:= NULL;

      --Se a conta integracao nao estiver completa
      IF length(pr_nrdctitg) < 2 THEN
        --Levantar Excecão
        RAISE vr_exc_saida;
      END IF;

      --Extrair a conta sem o digito
      vr_nrdctitg:= SUBSTR(pr_nrdctitg,1,Length(pr_nrdctitg)-1);

      --Extrair o digito da conta passada como parametro
      vr_nrdigitg:= SUBSTR(pr_nrdctitg,Length(pr_nrdctitg),1);

      --Se o digito = X
      IF Upper(vr_nrdigitg) = 'X' THEN
        --Atribuir zero para o digito
        vr_nrdigitg:= '0';
      END IF;

      --Atribuir a variavel de conta integracao
      pr_ctpsqitg:= TO_NUMBER(vr_nrdctitg||vr_nrdigitg);

    EXCEPTION
      WHEN vr_exc_saida THEN
        --Atribuir a variavel de conta integracao
        pr_ctpsqitg:= NULL;
      WHEN OTHERS THEN
        pr_des_erro:= 'Erro na procedure gene0005.pc_conta_itg_digito_zero. '||SQLERRM;
    END;
  END pc_conta_itg_digito_zero;

  /* Rotina responsavel pela verificacão da conta integracão do associado */
  PROCEDURE pc_existe_conta_integracao (pr_cdcooper IN crapass.cdcooper%TYPE
                                       ,pr_ctpsqitg IN craplcm.nrdctabb%TYPE
                                       ,pr_nrdctitg OUT crapass.nrdctitg%TYPE
                                       ,pr_nrctaass OUT crapass.nrdconta%TYPE
                                       ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
/* .............................................................................
   Programa: pc_existe_conta_integracao      Antigo includes/proc_conta_integracao.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima atualizacao: 10/06/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Procedures para descobrir se existe conta integracao.

   Alteracoes: 10/11/2005 - Criada procedure Conta digito zero (Magui).

               12/01/2006 - Aceita conta inativa (Magui).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               04/02/2013 - Conversão Progress para PLSQL (Alisson/AMcom)

               15/05/2014 - Ajustado procedure pc_existe_conta_integracao
                            alterado verificacao tamanho da conta para 8
                            como é efetuado no Progress (Daniel)

               30/07/2014 - Ajustando uma tentativa de atribuir mais de
                           8 caracteres em uma variável declarada como
                           VARCHAR2(8). (André Santos - SUPERO)

               10/06/2016 - Ajuste para inlcuir UPPER na leitura da tabela
                            crapass em campos de indice que possuem UPPER
                            (Adriano - SD 463762).

............................................................................. */
    DECLARE

      --Selecionar dados do associado
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdctitg IN crapass.nrdctitg%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.cdtipcta
              ,crapass.flgctitg
        FROM crapass crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   UPPER(crapass.nrdctitg) = UPPER(pr_nrdctitg);
      rw_crapass cr_crapass%ROWTYPE;

      --Variaveis Locais
      vr_nrdctitg VARCHAR2(10);
      vr_nrdigitg VARCHAR2(1);

    BEGIN

      --Inicializar mensagem de erro
      pr_des_erro:= NULL;

      --Se o tamanho da conta <= 8 digitos
      IF LENGTH(pr_ctpsqitg) <= 8 THEN -- Estava 10 Daniel
        --Atribuir zero para a conta do associado
        pr_nrctaass:= 0;
        --Extrair a conta sem o digito
        vr_nrdctitg:= SUBSTR(to_char(pr_ctpsqitg,'00000000'),1,Length(to_char(pr_ctpsqitg,'00000000'))-1);
        --Extrair o digito da conta passada como parametro
        vr_nrdigitg:= SUBSTR(to_char(pr_ctpsqitg,'00000000'),Length(to_char(pr_ctpsqitg,'00000000')),1);

        --Atribuir o numero da conta integracao com o digito para o parametro de retorno
        pr_nrdctitg:= TRIM(vr_nrdctitg)||TRIM(vr_nrdigitg);

        --Selecionar informacoes do associado
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                        ,pr_nrdctitg => pr_nrdctitg);
        --Posicionar no primeiro registro
        FETCH cr_crapass INTO rw_crapass;
        --Se nao encontrou
        IF cr_crapass%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapass;
          --Atribuir o numero da conta integracao com o digito
          pr_nrdctitg:= TRIM(vr_nrdctitg)||'X';
          --Selecionar informacoes do associado
          OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                          ,pr_nrdctitg => pr_nrdctitg);
          --Posicionar no primeiro registro
          FETCH cr_crapass INTO rw_crapass;
          --Se nao encontrou
          IF cr_crapass%NOTFOUND THEN
            --Atribuir nulo para a conta integracao
            pr_nrdctitg:= NULL;
          ELSE
            --Retonar a conta do associado
            pr_nrctaass:= rw_crapass.nrdconta;
          END IF;
        ELSE
          --Retonar a conta do associado
          pr_nrctaass:= rw_crapass.nrdconta;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapass;
      END IF;

      --Se a conta integracao nao estiver nula
      IF pr_nrdctitg IS NOT NULL THEN
        --Se a conta for
        -- 1=NORMAL, 2=ESPECIAL, 3=NORMAL CONJUNTA, 4=ESPEC. CONJUNTA, 5=CHEQUE SALARIO, 6=CTA APLIC CONJ., 7=CTA APLIC INDIV,
        -- 8=NORMAL CONVENIO, 9=ESPEC. CONVENIO, 10=CONJ. CONVENIO, 11=CONJ.ESP.CONV.
        IF rw_crapass.cdtipcta BETWEEN 1 AND 11 THEN
          --Se a conta integracao nao for cadastrada e inativa
          IF rw_crapass.flgctitg NOT IN (2,3) THEN
            --Atribuir nulo para conta integracão
            pr_nrdctitg:= NULL;
          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro:= 'Erro na procedure gene0005.pc_existe_conta_integracao. '||SQLERRM;
    END;
  END pc_existe_conta_integracao;

  /* Rotina responsavel por retornar a conta integracão com digito convertido */
  procedure pc_conta_itg_digito_x (pr_nrcalcul in number,
                                   pr_dscalcul out varchar2,
                                   pr_stsnrcal out number, -- 1 verdadeiro; 0 falso
                                   pr_cdcritic out crapcri.cdcritic%type,
                                   pr_dscritic out varchar2) is
  /* .............................................................................

   Programa: GENE0005.pc_conta_itg_digito_x (Antigo Fontes/digbbx.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                         Ultima atualizacao: 01/04/13

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular e conferir o digito verificador pelo modulo onze.
               Disponibilizar nro calculado digito "X" (Mirtes)

   Alteracães: 22/02/2013 - Conversão Progress >> Oracle PLSQL (Daniel - Supero)

               01/04/2013 - Inclusão de comentarios e tratamento de excecão (Daniel - Supero)

  ............................................................................. */
    -- Variaveis auxiliares para calculo da conta
    vr_digito        number := 0;
    vr_posicao       number := 0;
    vr_peso          number := 9;
    vr_calculo       number := 0;
    vr_resto         number := 0;
    vr_nrcalcul      varchar2(10) := to_char(pr_nrcalcul);
    vr_nrcalcul_aux  number := pr_nrcalcul;

  begin
    -- Verifica se o parametro recebido e valido
    if length(vr_nrcalcul) < 2 or
       length(vr_nrcalcul) > 8 then
      pr_stsnrcal := 0;
      return;
    end if;

    -- verifica se existe conteudo nas variaveis de conta CONCREDI e CEF
    IF vr_nrctacef IS NULL THEN
      -- Buscar a conta da CONCREDI na CEF
      vr_nrctacef := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'CTA_CONCREDI_CEF');
      vr_nrctaint := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'CTA_INTEGRA_CEF');
    END IF;


    -- Executa primeiro passo do calculo do digito
    -- Passa por cada digito e soma o valor, de acordo com o peso de cada posicão
    for vr_posicao in reverse 1 .. (length(vr_nrcalcul) - 1) loop
      vr_calculo := vr_calculo + to_number(substr(vr_nrcalcul, vr_posicao, 1)) * vr_peso;
      vr_peso := vr_peso - 1;
      if vr_peso = 1 then
        vr_peso := 9;
	    end if;
    end loop;
    -- Calcula o ditigo a partir do valor encontrado no passo anterior
    vr_resto := mod(vr_calculo, 11);
    if vr_resto > 9 then
      vr_digito := 0;
    else
      vr_digito := vr_resto;
    end if;
    -- Verifica se o digito recebido como parametro e valido
    if (to_number(substr(vr_nrcalcul, length(vr_nrcalcul), 1))) <> vr_digito then
      pr_stsnrcal := 0;
    else
      pr_stsnrcal := 1;
    end if;
    -- Concatena o novo digito ao parametro recebido
    vr_nrcalcul_aux := to_number(substr(vr_nrcalcul, 1, length(vr_nrcalcul) - 1)||to_char(vr_digito));
    --
    /* Numero calculado com digito "X" */
    if vr_resto <= 9 then
      pr_dscalcul := substr(to_char(vr_nrcalcul_aux,'fm00000000'),1,7)||to_char(vr_digito,'fm9');
    else
      pr_dscalcul := substr(to_char(vr_nrcalcul_aux,'fm00000000'),1,7)||'X';
    end if;

    /* Trata conta da CONCREDI na CEF */
    if vr_nrcalcul_aux = vr_nrctacef then
      pr_dscalcul := vr_nrctaint;
      pr_stsnrcal := 1;
    end if;
  exception
    when others then
      pr_stsnrcal := 0;
      pr_cdcritic := 0;
      pr_dscritic := 'Erro GENE0005.pc_conta_itg_digito_x, ao calcular digito "X" pelo modulo 11: '||sqlerrm;
  end;

  /* Funcão para validar o digito verificador */
  FUNCTION fn_valida_digito_verificador(pr_nrdconta IN NUMBER) RETURN BOOLEAN IS  --> Npumero da conta
  -- ..........................................................................
  --
  --  Programa : fn_valida_digito_verificador (Antigo /generico/procedures/b1wgen0122.p --> ValidaDigFun)
  --  Sistema  : Rotinas para cadastros Web
  --  Sigla    : ---
  --  Autor    : Petter R. Villa Real  - Supero
  --  Data     : Maio/2013.                   Ultima atualizacao: --/--/----
  --
  --  Dados referentes ao programa:
  --
  --   Frequencia: Sempre que for chamado
  --   Objetivo  : Validar informacães do calculo do modulo 11 (Web).
  --
  --   Alteracoes: 29/05/2013 - Conversão Progress-Oracle. (Petter - Supero)
  -- .............................................................................
  BEGIN
    DECLARE
      vr_nrdconta     NUMBER := pr_nrdconta;   --> Numero da conta
      vr_vlresult     BOOLEAN := TRUE;         --> Resultado da validacão
      vr_retmodulo    BOOLEAN;                 --> Recebe retorno do calculo do modulo 11

    BEGIN
      -- Calcula o digito pelo modulo 11
      vr_retmodulo := gene0005.fn_calc_digito(pr_nrcalcul => vr_nrdconta
                                             ,pr_reqweb   => TRUE);

      -- Verifica se o retorno foi de erro
      IF vr_retmodulo = FALSE THEN
        vr_vlresult := FALSE;
      END IF;

      -- Verifica se houve diferenca entre o modulo 11
      IF vr_nrdconta <> pr_nrdconta THEN
        vr_vlresult := FALSE;
      END IF;

      -- Retorna resultado
      RETURN vr_vlresult;
    END;
  END fn_valida_digito_verificador;

  /* Calcular o valor utilizado (credito) do Associado */
  PROCEDURE pc_saldo_utiliza (pr_cdcooper IN crapcop.cdcooper%TYPE              --> Codigo da Cooperativa
                             ,pr_tpdecons IN PLS_INTEGER                        --> Tipo da consulta (Ver observacães da rotina)
                             ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT NULL --> Codigo da agencia
                             ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL --> Numero do caixa
                             ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL --> Codigo do operador
                             ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT NULL --> OU Consulta pela conta
                             ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE DEFAULT NULL --> OU Consulta pelo Numero do cpf ou cgc do associado
                             ,pr_idseqttl IN crapttl.idseqttl%TYPE DEFAULT NULL --> Sequencia de titularidade da conta
                             ,pr_idorigem IN INTEGER               DEFAULT NULL --> Indicador da origem da chamada
                             ,pr_dsctrliq IN VARCHAR2                           --> Numero do contrato de liquidacao
                             ,pr_cdprogra IN crapprg.cdprogra%TYPE              --> Codigo do programa chamador
                             ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE        --> Tipo de registro de datas
                             ,pr_inusatab IN BOOLEAN                            --> Indicador de utilizacão da tabela de juros
                             ,pr_vlutiliz OUT NUMBER                            --> Valor utilizado do credito
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Codigo de retorno da critica
                             ,pr_dscritic OUT VARCHAR2) IS                      --> Mensagem de retorno da critica
  BEGIN

  /* .............................................................................

   Programa: pc_saldo_utiliza                    Antigo: Fontes/saldo_utiliza.p e BO b1wgen9999 >> saldo_utiliza
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Julho/2004.                         Ultima atualizacao: 14/03/2018

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Calcular o valor utilizado (credito) do associado
               Compoe o valor utilizado:
               - saldo devedor dos emprestimos ate o dia
               - cheques do desconto de cheques que ainda nao foram compensados
               - limite de cheque especial do cooperado, total contratado
               - estouro da conta
               - titulos do desconto de titulos ainda em aberto

   Observacão : Como esta rotina e proveniente de dois fontes Progress distintos,
                criamos o parametro pr_tpdecons para de acordo com a chamada efetuar
                a busca diferenciada do saldo do emprestimo, portando quando:

                - pr_tpdecons = 1 - Indica a chamada e proveniente da rotina convertida da fontes/saldo_utiliza.p
                                    e a busca do saldo de emprestimo vem da pc_calc_saldo_epr

                - pr_tpdecons = 2 - Indica a chamada e proveniente da rotina convertida da bo b1wgen9999, procedure
                                    saldo_utiliza e a busca do emprestimo vem da empr0001.pc_saldo_devedor_epr

                - pr_tpdecons = 3 - Igual ao pr_tpdecons = 2, porem busca o saldo da conta atualizado, ao inves do
                                    saldo do fechamento do dia.

                Outra distincão com relacão ao tipo da chamada, e que os parametros: pr_cdagenci, pr_nrdcaixa,
                pr_cdoperad, pr_idseqttl e pr_idorigem são relavantes para o tipo de consulta 2

   Alteracoes: 30/07/2004 - Passado parametro quantidade prestacoes
                            calculadas(Mirtes)

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               03/07/2006 - Ajustes para melhorar performance (Edson).

               14/10/2008 - Incluir saldo devedor do desconto de titulos
                            (Gabriel).
               08/08/2012 - Comentado o codigo que considera o limite do cartao
                            de credito para composicao do saldo utilizado -
                            Rosangela

               03/06/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

               04/06/2013 - Ajuste na rotina para integrar as funcães da rotina
                            b1wgen9999.saldo-utiliza tambem convertida (Marcos - Supero)

               20/06/2013 - Rating BNDES (Marcos - Supero)

               04/10/2013 - Retirado insitctr = P no Ratinf do BNDES (Renato - Supero)

               07/01/2015 - Incluido possibilidade de buscar o saldo atual (Andrino - RKAM)

			         24/07/2017 - Incluido Replace de ';' para ',' na lista de contratos
			                a liquidar (Marcos-Supero)
							 
							 14/03/2018 - Alteração nos cursores para considerar também contas em prejuízo
							              Reginaldo (AMcom)
     ............................................................................. */

     DECLARE

       -- Definicao dos tipos de tabelas de memoria
       -- O tipo abaixo servira para armazernar numeros de
       -- conta a processar
       TYPE typ_tab_conta
         IS TABLE OF NUMBER
           INDEX BY PLS_INTEGER;
       -- Definicao das tabelas de memoria
       vr_tab_conta    typ_tab_conta;
       vr_tab_dsctrliq GENE0002.typ_split;
       -- Variaveis de Indice para vetores de memoria
       vr_index_conta INTEGER;

       --Tipo da tabela de saldos
       vr_tab_saldo EXTR0001.typ_tab_saldos;

       /* Cursores da rotina */

       -- Selecionar o limite de credito usando diretamente a conta ja passada
       CURSOR cr_crapass_cta IS
         SELECT cp.vllimcre
           FROM crapass cp
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta -- Conta solicitada
            AND ((SELECT max(inprejuz)
                      FROM crapepr epr
                     WHERE epr.cdcooper = cp.cdcooper
                       AND epr.nrdconta = cp.nrdconta
                       AND epr.inprejuz = 1
                       AND epr.vlsdprej > 0
                   ) = 1 OR dtelimin IS NULL);

       -- Selecionar os associados da cooperativa por CPF/CGC
       CURSOR cr_crapass_cpfcgc IS
         SELECT nrdconta
               ,vllimcre
           FROM crapass cp
          WHERE cdcooper = pr_cdcooper
            AND nrcpfcgc = pr_nrcpfcgc -- CPF/CGC passado
            AND ((SELECT max(inprejuz)
                      FROM crapepr epr
                     WHERE epr.cdcooper = cp.cdcooper
                       AND epr.nrdconta = cp.nrdconta
                       AND epr.inprejuz = 1
                       AND epr.vlsdprej > 0
                   ) = 1 OR dtelimin IS NULL);

       -- Selecionar informacoes dos emprestimos
       CURSOR cr_crapepr(pr_nrdconta IN crapepr.nrdconta%TYPE) IS
         SELECT nrctremp,
                vlsdeved,
                vlsdevat
           FROM crapepr
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta
            AND inliquid = 0; --> Não liquidados

       -- Sumarizar emprestimos ativos e emprestimos prejuizo (BNDES)
       CURSOR cr_crapebn(pr_nrdconta IN crapebn.nrdconta%TYPE) IS
         SELECT SUM(vlsdeved) vlsdeved
           FROM crapebn
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta
            AND insitctr IN('N','A');  -- Retirado 'P' - 04/10/2013 - Renato (Supero)

       -- Selecionar cadastro desconto bordero cheques
       CURSOR cr_crapcdb(pr_nrdconta IN crapcdb.nrdconta%TYPE
                        ,pr_insitchq IN crapcdb.insitchq%TYPE
                        ,pr_dtlibera IN crapcdb.dtlibera%TYPE) IS
         SELECT SUM(vlcheque) vlcheque
           FROM crapcdb
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta
            AND insitchq = pr_insitchq
            AND dtlibera > pr_dtlibera;

       -- Selecionar informacoes dos saldos diarios do associado
       CURSOR cr_crapsld(pr_nrdconta IN crapsld.nrdconta%TYPE) IS
         SELECT vlsddisp
           FROM crapsld
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta;
       rw_crapsld cr_crapsld%ROWTYPE;

       -- Selecionar informacoes dos titulos descontados
       CURSOR cr_craptdb(pr_nrdconta IN craptdb.nrdconta%TYPE
                        ,pr_dtdpagto IN craptdb.dtdpagto%TYPE) IS
         SELECT SUM(vltitulo) vltitulo
           FROM craptdb
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta
            AND (craptdb.insittit =  4 OR (insittit = 2 AND dtdpagto = pr_dtdpagto));

       -- Variaveis Locais
       vr_vlutiliz            NUMBER;
       vr_contaliq            NUMBER;
       vr_vlsdeved_epr        NUMBER;
       vr_vlsdeved_dschq      NUMBER;
       vr_vlsdeved_limite_cta NUMBER;
       vr_vlsdeved_conta      NUMBER;
       vr_vlsdeved_dstit      NUMBER;
       vr_vlsdeved_limite     NUMBER;
       vr_qtprecal_retorno    NUMBER;
       vr_vlsdeved            NUMBER;
       vr_flgvalid            BOOLEAN;
       vr_vltotpre            NUMBER;

       -- Variaveis para retorno de erro
       vr_cdcritic INTEGER;
       vr_des_erro VARCHAR2(4000);

     BEGIN
       -- Inicializar variaveis de erro
       pr_cdcritic := NULL;
       pr_dscritic := NULL;

       -- Inicializar valor utilizado
       vr_vlutiliz := 0;

       -- Se foi passada a conta
       IF pr_nrdconta IS NOT NULL THEN
         -- Buscar o limite de credito somente desta conta
         FOR rw_crapass IN cr_crapass_cta LOOP
           -- Gerar a conta passada no vetor
           vr_tab_conta(pr_nrdconta) := rw_crapass.vllimcre;
         END LOOP;
       ELSIF pr_nrcpfcgc IS NOT NULL THEN
         -- Buscar todas as contas do CPF/CGC
         FOR rw_crapass IN cr_crapass_cpfcgc LOOP
           --Carregar tabela memoria com a conta retornada por cpf/cnpj
           vr_tab_conta(rw_crapass.nrdconta) := rw_crapass.vllimcre;
         END LOOP;
       ELSE
         -- Gerar erro pois um dos dois deve ser enviado
         vr_cdcritic := 0;
         vr_des_erro := 'Informar Conta ou CPF/CGC para a rotina EMPR0001.pc_saldo_utiliza.';
         RAISE vr_exc_erro;
       END IF;

       -- Se a conta ou CPF/CGC não retornou nenhuma informacão ao vetor
       IF vr_tab_conta.count = 0 THEN
         -- Gerar critica 9
         vr_cdcritic := 9;
         RAISE vr_exc_erro;
       END IF;

       -- Se nao houver contas para liquidar
       IF Upper(pr_dsctrliq) != Upper('Sem liquidacoes') THEN
         -- Quantidade contas recebe numero entradas da string
         vr_tab_dsctrliq:= GENE0002.fn_quebra_string(pr_string  => replace(pr_dsctrliq,';',','), pr_delimit => ',');

         -- Se o vetor retornar vazio
         IF vr_tab_dsctrliq.Count=0 THEN
           vr_contaliq:= 0;
         ELSE
           vr_contaliq:= vr_tab_dsctrliq.Count;
         END IF;
       ELSE
         -- Zerar Quantidade contas
         vr_contaliq:= 0;
       END IF;

       -- Zerar variaveis para calculo saldo
       vr_vlsdeved_epr        := 0;
       vr_vlsdeved_dschq      := 0;
       vr_vlsdeved_limite     := 0;
       vr_vlsdeved_conta      := 0;
       vr_vlsdeved_limite_cta := 0;
       vr_vlsdeved_dstit      := 0;
       vr_vlsdeved            := 0;

       -- Posicionar ponteiro no primeiro registro da tabela de memoria
       vr_index_conta := vr_tab_conta.FIRST;
       WHILE vr_index_conta IS NOT NULL LOOP
         -- Selecionar informacoes dos emprestimos
         FOR rw_crapepr IN cr_crapepr (pr_nrdconta => vr_index_conta) LOOP
           -- Marcar flag como emprestimo valido
           vr_flgvalid := TRUE;
           -- Percorrer as contas em liquidacao
           FOR idx IN 1..vr_contaliq LOOP
             -- Se o numero do contrato estiver na lista
             IF rw_crapepr.nrctremp = To_Number(vr_tab_dsctrliq(idx)) THEN
               -- Marcar flag para desprezar
               vr_flgvalid := FALSE;
               --Sair loop
               EXIT;
             END IF;
           END LOOP;

           -- Somente continuar se o emprestimo estiver valido
           IF vr_flgvalid THEN
             -- Inicializar o saldo devedor
             vr_vlsdeved := 0;
             -- Calcular o saldo devedor do emprestimo cfme o tipo da chamada:
             -- PAra chamadas do tipo 1 (Proveniente da conversão da fontes/saldo_utiliza.p)
             IF pr_tpdecons = 1 THEN
               IF UPPER(pr_cdprogra) = 'CRPS405' THEN
                  vr_vlsdeved := rw_crapepr.vlsdevat;
               ELSE
               -- Utilizar a pc_calc_saldo_epr
               EMPR0001.pc_calc_saldo_epr(pr_cdcooper   => pr_cdcooper         --> Codigo da Cooperativa
                                         ,pr_rw_crapdat => pr_tab_crapdat      --> Vetor com dados de parametro (CRAPDAT)
                                         ,pr_cdprogra   => pr_cdprogra         --> Programa que solicitou o calculo
                                         ,pr_nrdconta   => vr_index_conta      --> Numero da conta do emprestimo
                                         ,pr_nrctremp   => rw_crapepr.nrctremp --> Numero do contrato do emprestimo
                                         ,pr_inusatab   => pr_inusatab         --> Indicador de utilizacão da tabela de juros
                                         ,pr_vlsdeved   => vr_vlsdeved         --> Saldo devedor do emprestimo
                                         ,pr_qtprecal   => vr_qtprecal_retorno --> Quantidade de parcelas do emprestimo
                                         ,pr_cdcritic   => vr_cdcritic         --> Codigo de critica encontrada
                                         ,pr_des_erro   => vr_des_erro);       --> Retorno de Erro

               -- Se ocorreu erro, gerar critica
               IF vr_cdcritic IS NOT NULL OR vr_des_erro IS NOT NULL THEN
                 -- Zerar saldo devedor
                 vr_vlsdeved := 0;
                 -- Gerar critica
                 RAISE vr_exc_erro;
               END IF;

			 END IF;
             ELSE --> E uma chamada provenitente da bo b1wgen9999, procedure saldo_utiliza
               -- Utilizaremos a pc_saldo_devedor_epr
               EMPR0001.pc_saldo_devedor_epr(pr_cdcooper   => pr_cdcooper           --> Cooperativa conectada
                                            ,pr_cdagenci   => pr_cdagenci         --> Codigo da agencia
                                            ,pr_nrdcaixa   => pr_nrdcaixa         --> Numero do caixa
                                            ,pr_cdoperad   => pr_cdoperad         --> Codigo do operador
                                            ,pr_nmdatela   => pr_cdprogra         --> Nome datela conectada
                                            ,pr_idorigem   => pr_idorigem         --> Indicador da origem da chamada
                                            ,pr_nrdconta   => vr_index_conta      --> Conta do associado
                                            ,pr_idseqttl   => pr_idseqttl         --> Sequencia de titularidade da conta
                                            ,pr_rw_crapdat => pr_tab_crapdat      --> Vetor com dados de parametro (CRAPDAT)
                                            ,pr_nrctremp   => rw_crapepr.nrctremp --> Numero contrato emprestimo
                                            ,pr_cdprogra   => pr_cdprogra         --> Programa conectado
                                            ,pr_inusatab   => pr_inusatab         --> Indicador de utilizacão da tabela
                                            ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                            ,pr_vlsdeved   => vr_vlsdeved         --> Saldo devedor calculado
                                            ,pr_vltotpre   => vr_vltotpre         --> Valor total das prestacães
                                            ,pr_qtprecal   => vr_qtprecal_retorno --> Parcelas calculadas
                                            ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                            ,pr_tab_erro   => vr_tab_erro);      --> Tabela com possives erros

               -- Se houve retorno de erro
               IF vr_des_reto = 'NOK' THEN
                 -- Extrair o codigo e critica de erro da tabela de erro
                 vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                 vr_des_erro := vr_tab_erro(vr_tab_erro.first).dscritic;
               END IF;
             END IF;
             -- Se o saldo devedor for negativo entao zerar
             IF vr_vlsdeved < 0 THEN
               vr_vlsdeved := 0;
             END IF;
             -- Acumular saldo devedor emprestimos
             vr_vlsdeved_epr := Nvl(vr_vlsdeved_epr,0) + Nvl(vr_vlsdeved,0);
           END IF;
         END LOOP; -- Fim leitura emprestimos

         -- Sumarizar emprestimos ativos e emprestimos prejuizo (BNDES)
         FOR rw_crapebn IN cr_crapebn(pr_nrdconta => vr_index_conta) LOOP
           -- Acumular o saldo encontrado no saldo de emprestimos
           vr_vlsdeved_epr := Nvl(vr_vlsdeved_epr,0) + Nvl(rw_crapebn.vlsdeved,0);
         END LOOP;

         -- Verificar cadastro desconto bordero cheques
         FOR rw_crapcdb IN cr_crapcdb(pr_nrdconta => vr_index_conta
                                     ,pr_insitchq => 2
                                     ,pr_dtlibera => pr_tab_crapdat.dtmvtolt) LOOP
           -- Acumular saldo devedor dos cheques
           vr_vlsdeved_dschq := Nvl(vr_vlsdeved_dschq,0) + Nvl(rw_crapcdb.vlcheque,0);
         END LOOP;

         -- Selecionar os valores dos titulos descontados
         FOR rw_craptdb IN cr_craptdb(pr_nrdconta => vr_index_conta
                                     ,pr_dtdpagto => pr_tab_crapdat.dtmvtolt) LOOP
           -- Acumular valor saldo titulos descontados
           vr_vlsdeved_dstit := Nvl(vr_vlsdeved_dstit,0) + Nvl(rw_craptdb.vltitulo,0);
         END LOOP;

         -- Se for para buscar o saldo do dia, utiliza a rotina EXTR0001.pc_obtem_saldo_dia
         IF pr_tpdecons = 3 THEN
           /** Busca o saldo atualizado **/
           EXTR0001.pc_obtem_saldo_dia (pr_cdcooper   => pr_cdcooper
                                       ,pr_rw_crapdat => pr_tab_crapdat
                                       ,pr_cdagenci   => pr_cdagenci
                                       ,pr_nrdcaixa   => pr_nrdcaixa
                                       ,pr_cdoperad   => pr_cdoperad
                                       ,pr_nrdconta   => vr_index_conta
                                       ,pr_vllimcre   => Nvl(vr_tab_conta(vr_index_conta),0)
                                       ,pr_dtrefere   => pr_tab_crapdat.dtmvtolt
                                       ,pr_tipo_busca => 'A' --Chamado 291693 (Heitor - RKAM)
                                       ,pr_des_reto   => vr_des_reto
                                       ,pr_tab_sald   => vr_tab_saldo
                                       ,pr_tab_erro   => vr_tab_erro);
           --Se ocorreu erro
           IF vr_des_reto = 'NOK' THEN
             -- Tenta buscar o erro no vetor de erro
             IF vr_tab_erro.COUNT > 0 THEN
               vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
               vr_des_erro:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||vr_index_conta;
             ELSE
               vr_cdcritic:= 0;
               vr_des_erro:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||vr_index_conta;
             END IF;
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;
           --Verificar o saldo retornado
           IF vr_tab_saldo.Count = 0 THEN
             --Montar mensagem erro
             vr_cdcritic:= 0;
             vr_des_erro:= 'Nao foi possivel consultar o saldo para a operacao.';
             --Levantar Excecao
             RAISE vr_exc_erro;
           ELSE
             rw_crapsld.vlsddisp := nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0);
           END IF;

         ELSE --pr_tpdecons <> 3

           -- Selecionar saldo diario do associado
           OPEN cr_crapsld(pr_nrdconta => vr_index_conta);
           -- Posicionar no primeiro registro
           FETCH cr_crapsld INTO rw_crapsld;
           -- Se não tiver encontrado
           IF cr_crapsld%NOTFOUND THEN
             -- Fechar o cursor e gerar critica 10
             CLOSE cr_crapsld;
             vr_cdcritic := 10;
             RAISE vr_exc_erro;
           ELSE
             -- Fechar Cursor e continuar
             CLOSE cr_crapsld;
           END IF;
         END IF;

         -- Determinar o limite do saldo devedor
         vr_vlsdeved_limite := Nvl(vr_vlsdeved_limite,0) + Nvl(vr_tab_conta(vr_index_conta),0);
         -- Determinar o limite da conta do associado
         vr_vlsdeved_limite_cta := Nvl(vr_tab_conta(vr_index_conta),0);
         -- Determinar o valor disponivel
         vr_vlsdeved := Nvl(rw_crapsld.vlsddisp,0);
         -- Se o valor do saldo devedor for positivo
         IF Nvl(vr_vlsdeved,0) > 0 THEN
           -- Zerar saldo devedor
           vr_vlsdeved:= 0;
         ELSIF Nvl(vr_vlsdeved,0) < 0 THEN
           -- Multiplicar o saldo devedor por -1
           vr_vlsdeved := vr_vlsdeved * -1;
           -- Se o saldo devedor maior limite conta
           IF vr_vlsdeved > vr_vlsdeved_limite_cta THEN
             -- Diminuir o limite da conta do saldo devedor
             vr_vlsdeved := Nvl(vr_vlsdeved,0) - Nvl(vr_vlsdeved_limite_cta,0);
           ELSE
             -- Zerar saldo devedor
             vr_vlsdeved:= 0;
           END IF;
         END IF;
         -- Determinar o saldo devedor da conta
         vr_vlsdeved_conta := Nvl(vr_vlsdeved_conta,0) + Nvl(vr_vlsdeved,0);

         --Posicionar no proximo registro do vetor
         vr_index_conta:= vr_tab_conta.NEXT(vr_index_conta);
       END LOOP;

       -- Retornar valor para parametro saida
       pr_vlutiliz := Nvl(vr_vlsdeved_epr,0) + Nvl(vr_vlsdeved_dschq,0)
                    + Nvl(vr_vlsdeved_limite,0) + Nvl(vr_vlsdeved_conta,0)
                    +  Nvl(vr_vlsdeved_dstit,0);
     EXCEPTION
       WHEN vr_exc_erro THEN
         -- Retornar texto e codigo do erro
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_des_erro;
       WHEN OTHERS THEN
         -- Gerar erro não tratado
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina GENE0005.pc_saldo_utiliza: '||sqlerrm;
     END;
   END pc_saldo_utiliza;

  /* Rotina para retorno de valores bloqueados judicialmente para o cooperado */
  PROCEDURE pc_retorna_valor_blqjud(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE --> CPF/CGC
                                   ,pr_cdtipmov IN PLS_INTEGER           --> Tipo do movimento
                                   ,pr_cdmodali IN PLS_INTEGER           --> Modalidade
                                   ,pr_dtmvtolt IN DATE                  --> Data atual
                                   ,pr_vlbloque OUT NUMBER               --> Valor bloqueado
                                   ,pr_vlresblq OUT NUMBER               --> Valor que falta bloquear
                                   ,pr_dscritic OUT VARCHAR2) IS         --> Erros encontrados no processo
  BEGIN
    /* .............................................................................

     Programa: pc_retorna_valor_blqjud (Antigo b1wgen0155>>retorna-valor-blqjud)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos(Supero)
     Data    : 04/06/2013                         Ultima atualizacao: 24/11/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Retornar o valor bloqueado e a bloquear do cooperado

     Observacães: pr_cdtipmov : 0-Todos / 1-Transf. / 2-Bloq Normal / 3-Blq Capital
                  pr_cdmodali : 0-Todos / 1-DEP VISTA / 2-APLICACAO / 3-POUP PRG. / 4-CAPITAL

     Alteracães: 04/11/2015 - Correção de conversão, tratar 0 como todos para cdmodali
                              identificado na conversão carrega_dados_atenda SD318820 (Odirlei-AMcom)

                 24/11/2017 - Correção na consulta de bloqueios judiciais, para somar todas as
                              ocorrencias e retornar o valor correto. SD 800517 (Carlos Rafael Tanholi)

    ............................................................................. */
    DECLARE
     -- Buscar das informacães de bloqueio judicial na conta
     CURSOR cr_crapblj IS
       SELECT SUM(vlbloque) AS vlbloque
             ,SUM(vlresblq) AS vlresblq
         FROM crapblj
        WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta
          AND (cdtipmov = pr_cdtipmov OR pr_cdtipmov = 0) -- 0 - Quanto todos
          AND (cdmodali = pr_cdmodali OR pr_cdmodali = 0) -- 0 - Quanto todos
          AND dtblqini <= pr_dtmvtolt
          AND dtblqfim IS NULL; -- SE Vazio ESTA ATIVO
      rw_crapblj cr_crapblj%ROWTYPE;
    BEGIN
      -- Buscar informacão na tabela
      OPEN cr_crapblj;
      FETCH cr_crapblj
       INTO rw_crapblj;
      -- Se encontrou informacão
      IF cr_crapblj%FOUND THEN
        -- Retornar as informacães da tabela
        pr_vlbloque := rw_crapblj.vlbloque;
        pr_vlresblq := rw_crapblj.vlresblq;
      ELSE
        -- Retornar zero
        pr_vlbloque := 0;
        pr_vlresblq := 0;
      END IF;
      -- Terminar fechando o cursor
      CLOSE cr_crapblj;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina GENE0005.pc_retorna_valor_blqjud. Detalhes: '||sqlerrm;
    END;
  END pc_retorna_valor_blqjud;

  /* Funcão para validar se o dia e util e, se não for, retornar o proximo ou o anterior */
  FUNCTION fn_valida_dia_util(pr_cdcooper in crapcop.cdcooper%type, --> Cooperativa conectada
                              pr_dtmvtolt in crapdat.dtmvtolt%type, --> Data do movimento
                              pr_tipo in varchar2 default 'P',      --> Tipo de busca (P = proximo, A = anterior)
                              pr_feriado IN BOOLEAN DEFAULT TRUE,   --> Considerar feriados
                              pr_excultdia IN BOOLEAN DEFAULT FALSE --> Desconsiderar Feriado 31/12
                             ) RETURN DATE IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_valida_dia_util
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Marcos (Supero)
    --   Data    : Janeiro/2013                          Ultima Atualizacao: 24/11/2015
    --
    --   Dados referentes ao programa:
    --   Frequencia: Sempre que chamado por outros programas.
    --   Objetivo  : Calcular se a data passada e util, e se não for
    --               retornar a proxima data util.
    --   Observacoes : 1 - Sabado e documento não são considerados uteis
    --                 2 - Dias cadastrados na CRAPFER não são considerados uteis
    --
    --   Alteracoes  : 06/03/2013 - Funcão tambem pode retornar o dia util anterior (Daniel)
    --
    --                 24/11/2015 - Alterado para não desconsiderar o ultimo dia do ano direto
    --                              ao popular a temptable, pois isso acarreta que em durante
    --                              toda a sessao (webspped é uma sessao unica o dia inteiro) será
    --                              considerado/desconsiderardo o ultimo dia do ano independente se passar o parametro
    --                            - Alterado para tratar o ultimo dia util do ano ao invez do ultimo dia do ano
    --                              devido a compe financeira utlizar o ultimo dia util do ano para o fechamento anual
    --                              SD 240181 (Odirlei-AMcom)
    --
    --                 15/05/2017 - Correcao para abortar execucao quando for passada uma data nula, evitando
    --                              que a rotina caia no loop infinito gerando atraso no processo. SD 670255.
    --                              (Carlos Rafael Tanholi)
    -- .............................................................................
    DECLARE
      -- Data auxiliar
      vr_dtmvtolt  crapdat.dtmvtolt%TYPE;
      vr_excultdia INTEGER;
      vr_dtultano  crapdat.dtmvtolt%TYPE;
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Buscar informacoes dos feriados
      CURSOR cr_crapfer (pr_excultdia IN INTEGER) IS
        SELECT fer.dtferiad
          FROM crapfer fer
         WHERE fer.cdcooper = pr_cdcooper;
      -- Indica pra tabela de feriados
      vr_index BINARY_INTEGER;
    BEGIN
      -- valida data nula
      IF pr_dtmvtolt IS NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Iniciar com a data passada removendo as horas
      vr_dtmvtolt := TRUNC(pr_dtmvtolt);

      --Verificar se Exclui ultimo dia ano dos feriados cadastrados
      IF pr_excultdia THEN
        vr_excultdia:= 1;
      ELSE
        vr_excultdia:= 0;
      END IF;

      -- Se a tabela de feriados estiver vazia
      IF vr_tab_feriado.COUNT = 0 THEN
        -- Alimentar vetor com os feriados
        vr_tab_feriado.DELETE;

        FOR rw_crapfer IN cr_crapfer (pr_excultdia => vr_excultdia)  LOOP
          --Montar o indice para o vetor
          vr_index := To_Number(To_Char(rw_crapfer.dtferiad,'YYYYMMDD'));
          --Atribuir o valor selecionado ao vetor
          vr_tab_feriado(vr_index):= rw_crapfer.dtferiad;
        END LOOP;
      END IF;
      -- Testes para garantir que seja util
      LOOP
        -- Montar a data em numero para busca no vetor de feriados
        vr_index := To_Number(To_Char(vr_dtmvtolt,'YYYYMMDD'));
        -- Sair se o dia não for sabado ou domingo e nem feriado
        IF pr_feriado AND
           (to_char(vr_dtmvtolt,'d') not in(1,7)) THEN
           IF not vr_tab_feriado.exists(vr_index) THEN
             --Sair
             EXIT;
           -- Verificar se deve desconsiderar o ultimo dia util do ano como feriado
           ELSIF vr_excultdia = 1 THEN
             -- Verificar qual o ultimo dia util do ano
             vr_dtultano := add_months(TRUNC(vr_dtmvtolt,'RRRR'),12)-1;
             vr_dtultano := gene0005.fn_valida_dia_util(pr_cdcooper => 1,
                                                        pr_dtmvtolt => vr_dtultano, pr_tipo => 'A',
                                                        pr_feriado => FALSE);

             --> se é o ultimo dia util do ano que esta sendo verificado
             --  entao pode sair e considerar como dia util inves de feriado
             IF (to_char(vr_tab_feriado(vr_index),'DDMM') = to_char(vr_dtultano,'DDMM')) THEN
               EXIT;
             END IF;
           END IF;
        ELSIF NOT pr_feriado AND to_char(vr_dtmvtolt,'d') not IN (1,7) THEN
          --Sair
          EXIT;
        END IF;
        -- Se não saiu e porque não e util, entao adiciona ou subtrai um dia
        if pr_tipo = 'A' then
          vr_dtmvtolt := vr_dtmvtolt - 1;
        else
          vr_dtmvtolt := vr_dtmvtolt + 1;
        end if;
      END LOOP;
      -- Retornar a data calculada
      RETURN vr_dtmvtolt;
    EXCEPTION
			WHEN vr_exc_saida THEN
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Processo normal
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - GENE0005 --> fn_valida_dia_util - Coop.: '||pr_cdcooper||' - Data inválida (NULL)');
        RETURN NULL;
      WHEN OTHERS THEN
        -- Iniciar LOG de execucão
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Processo normal
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - GENE0005 --> fn_valida_dia_util - Coop.: '||pr_cdcooper||' - Não foi possivel verificar data util para o dia: '||vr_dtmvtolt);
        RETURN null;
    END;
  END fn_valida_dia_util;

  /* Procedimento para validar se o dia e util e, se não for, retornar o proximo ou o anterior
     Chamada para ser utilizada no progress */
  PROCEDURE pc_valida_dia_util(pr_cdcooper  IN crapcop.cdcooper%type,     --> Cooperativa conectada
                               pr_dtmvtolt  IN OUT crapdat.dtmvtolt%type, --> Data do movimento
                               pr_tipo      IN varchar2 default 'P',      --> Tipo de busca (P = proximo, A = anterior)
                               pr_feriado   IN INTEGER DEFAULT 1,         --> Considerar feriados ( 0-False, 1-True)
                               pr_excultdia IN INTEGER DEFAULT 0 ) IS     --> Desconsiderar Feriado 31/12 ( 0-False, 1-True)


    -- ..........................................................................
    --
    --  Programa : pc_valida_dia_util
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Odirlei Busana(AMcom)
    --   Data    : maio/2015                          Ultima Atualizacao: 06/05/2015
    --
    --   Dados referentes ao programa:
    --   Frequencia: Sempre que chamado por outros programas.
    --   Objetivo  : Chamada para ser utilizada no progress
    --               Calcular se a data passada e util, e se não for
    --               retornar a proxima data util.
    --   Observacoes : 1 - Sabado e documento não são considerados uteis
    --                 2 - Dias cadastrados na CRAPFER não são considerados uteis
    --
    --   Alteracoes  :
    -- .............................................................................
  BEGIN
    pr_dtmvtolt := fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,       --> Cooperativa conectada
                                      pr_dtmvtolt  => pr_dtmvtolt,       --> Data do movimento
                                      pr_tipo      => pr_tipo,           --> Tipo de busca (P = proximo, A = anterior)
                                      pr_feriado   => (pr_feriado = 1),  --> Considerar feriados
                                      pr_excultdia => (pr_excultdia = 1) --> Desconsiderar Feriado 31/12
                                     );

  END pc_valida_dia_util;

      --Validar o cpf
  PROCEDURE pc_valida_cpf (pr_nrcalcul IN NUMBER --Numero a ser verificado
                          ,pr_stsnrcal OUT BOOLEAN) IS --Situacao
   /****************************************************************************************
       Programa : pc_valida_cpf
       Sistema  : Conta-Corrente - Cooperativa de Credito
       Sigla    : CRED
       Autor    : Alisson C. Berrido - Amcom
       Data     : Julho/2013.                                   Ultima Alteração: 28/09/2017

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado
       Objetivo  : Validar cpf informado

       Alterações: 28/09/2017 - Incluir validação para caso o tamanho do cpf for maior
                                que 11 posições não aceite o cadastro do mesmo
                                (Lucas Ranghetti #717352)
   *****************************************************************************************/
      BEGIN
        DECLARE
          --Variaveis Locais
          vr_nrdigito INTEGER:= 0;
          vr_nrposica INTEGER:= 0;
          vr_vlrdpeso INTEGER:= 2;
          vr_vlcalcul INTEGER:= 0;
          vr_vldresto INTEGER:= 0;
          vr_vlresult INTEGER:= 0;
        BEGIN
          IF LENGTH(pr_nrcalcul) < 5 OR
             LENGTH(pr_nrcalcul) > 11 OR
             pr_nrcalcul IN (11111111111,22222222222,33333333333,44444444444,55555555555,
                             66666666666,77777777777,88888888888,99999999999) THEN
            --Retornar com erro
        pr_stsnrcal := FALSE;
          ELSE
            --Inicializar variaveis calculo
            vr_vlrdpeso:= 9;
            vr_nrposica:= 0;
            vr_vlcalcul:= 0;

            --Calcular digito
            FOR vr_nrposica IN REVERSE 1..LENGTH(pr_nrcalcul) - 2 LOOP
              vr_vlcalcul:= vr_vlcalcul + (TO_NUMBER(SUBSTR(pr_nrcalcul,vr_nrposica,1)) * vr_vlrdpeso);
              --Diminuir peso
              vr_vlrdpeso:= vr_vlrdpeso-1;
            END LOOP;

            --Calcular resto modulo 11
            vr_vldresto:= Mod(vr_vlcalcul,11);

            IF  vr_vldresto = 10 THEN
              --Digito recebe zero
              vr_nrdigito:= 0;
            ELSE
              --Digito recebe resto
              vr_nrdigito:= vr_vldresto;
            END IF;

            vr_vlrdpeso:= 8;
            vr_vlcalcul:= vr_nrdigito * 9;

            --Calcular digito
            FOR vr_nrposica IN REVERSE 1..LENGTH(pr_nrcalcul) - 2 LOOP
              vr_vlcalcul:= vr_vlcalcul + (TO_NUMBER(SUBSTR(pr_nrcalcul,vr_nrposica,1)) * vr_vlrdpeso);
              --Diminuir peso
              vr_vlrdpeso:= vr_vlrdpeso-1;
            END LOOP;

            --Calcular resto modulo 11
            vr_vldresto:= Mod(vr_vlcalcul,11);

            IF  vr_vldresto = 10 THEN
              --Digito multiplicado 10
              vr_nrdigito:= vr_nrdigito * 10;
            ELSE
              --Digito recebe digito * 10 + resto
              vr_nrdigito:= (vr_nrdigito * 10) + vr_vldresto;
            END IF;

            --Comparar digito calculado com informado
            IF TO_NUMBER(SUBSTR(pr_nrcalcul,LENGTH(pr_nrcalcul) - 1,2)) <> vr_nrdigito  THEN
          pr_stsnrcal := FALSE;
            ELSE
          pr_stsnrcal := TRUE;
            END IF;

          END IF;
        END;
  END pc_valida_cpf;

      --Validar o cnpj
  PROCEDURE pc_valida_cnpj (pr_nrcalcul IN NUMBER  --Numero a ser verificado
                           ,pr_stsnrcal OUT BOOLEAN) IS --Situacao
      BEGIN
        DECLARE
          --Variaveis Locais
          vr_nrdigito INTEGER:= 0;
          vr_nrposica INTEGER:= 0;
          vr_vlrdpeso INTEGER:= 2;
          vr_vlcalcul INTEGER:= 0;
          vr_vldresto INTEGER:= 0;
          vr_vlresult INTEGER:= 0;
        BEGIN
          IF LENGTH(pr_nrcalcul) < 3 THEN
            --Retornar com erro
        pr_stsnrcal := FALSE;
          ELSE
            vr_vlcalcul:= TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),1,1)) * 2;
            vr_vlresult:= TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),2,1)) +
                          TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),4,1)) +
                          TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),6,1)) +
                          TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),1,1)) +
                          TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),2,1));
            vr_vlcalcul:= TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),3,1)) * 2;
            vr_vlresult:= vr_vlresult +
                          TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),1,1)) +
                          TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),2,1));
            vr_vlcalcul:= TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),5,1)) * 2;
            vr_vlresult:= vr_vlresult +
                          TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),1,1)) +
                          TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),2,1));
            vr_vlcalcul:= TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),7,1)) * 2;
            vr_vlresult:= vr_vlresult +
                          TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),1,1)) +
                          TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),2,1));
            vr_vldresto:= Mod(vr_vlresult,10);

            --Se valor resto for zero
            IF vr_vldresto = 0  THEN
              --Digito recebe resto
              vr_nrdigito:= vr_vldresto;
            ELSE
              vr_nrdigito:= 10 - vr_vldresto;
            END IF;
            --Zerar valor calculado
            vr_vlcalcul:= 0;

            --Calcular digito
            FOR vr_nrposica IN REVERSE 1..LENGTH(pr_nrcalcul) - 2 LOOP
              vr_vlcalcul:= vr_vlcalcul + (TO_NUMBER(SUBSTR(pr_nrcalcul,vr_nrposica,1)) * vr_vlrdpeso);
              --Incrementar peso
              vr_vlrdpeso:= vr_vlrdpeso+1;
              --Se peso > 9
              IF vr_vlrdpeso > 9 THEN
                vr_vlrdpeso:= 2;
              END IF;
            END LOOP;

            --Calcular resto modulo 11
            vr_vldresto:= Mod(vr_vlcalcul,11);

            IF  vr_vldresto < 2  THEN
              --Digito recebe zero
              vr_nrdigito:= 0;
            ELSE
              --Digito recebe 11 menos resto
              vr_nrdigito:= 11 - vr_vldresto;
            END IF;

            --Comparar digito calculado com informado
            IF TO_NUMBER(SUBSTR(pr_nrcalcul,LENGTH(pr_nrcalcul) - 1,1)) <> vr_nrdigito  THEN
          pr_stsnrcal := FALSE;
            END IF;

            vr_vlrdpeso:= 2;
            vr_vlcalcul:= 0;

            --Calcular digito
            FOR vr_nrposica IN REVERSE 1..LENGTH(pr_nrcalcul) - 1 LOOP
              vr_vlcalcul:= vr_vlcalcul + (TO_NUMBER(SUBSTR(pr_nrcalcul,vr_nrposica,1)) * vr_vlrdpeso);
              --Incrementar peso
              vr_vlrdpeso:= vr_vlrdpeso+1;
              --Se peso > 9
              IF vr_vlrdpeso > 9 THEN
                vr_vlrdpeso:= 2;
              END IF;
            END LOOP;

            --Calcular resto modulo 11
            vr_vldresto:= Mod(vr_vlcalcul,11);

            IF  vr_vldresto < 2  THEN
              --Digito recebe zero
              vr_nrdigito:= 0;
            ELSE
              --Digito recebe 11 menos resto
              vr_nrdigito:= 11 - vr_vldresto;
            END IF;

            --Comparar digito calculado com informado
            IF TO_NUMBER(SUBSTR(pr_nrcalcul,LENGTH(pr_nrcalcul),1)) <> vr_nrdigito  THEN
          pr_stsnrcal := FALSE;
            ELSE
              --Retornar Verdadeiro
          pr_stsnrcal := TRUE;
            END IF;

          END IF;

        END;

  END pc_valida_cnpj;

  /* Procedure para validar cpf ou cnpj */
  PROCEDURE pc_valida_cpf_cnpj (pr_nrcalcul IN NUMBER       --Numero a ser verificado
                               ,pr_stsnrcal OUT BOOLEAN     --Situacao
                               ,pr_inpessoa OUT INTEGER) IS --Tipo Inscricao Cedente
  BEGIN
    /* ..........................................................................

      Programa : pc_valida_cpf_cnpj            Antigo: b1wgen9999.p/valida-cpf-cnpj
      Sistema  : Rotinas genericas
      Sigla    : GENE
      Autor    : Alisson C. Berrido - Amcom
      Data     : Julho/2013.                   Ultima atualizacao: 20/03/2017

      Dados referentes ao programa:

       Frequencia: Sempre que for chamado
       Objetivo  : Validar cpf e cnpj informado

       Alteracoes: 19/07/2013 - Conversao Progress para Oracle - Alisson (AMcom)

                   20/03/2017 - Ajuste para disponibilizar as rotinas de validação de
                                cpf e cnpj como públicas
                               (Adriano - SD 620221).

     .............................................................................*/
    DECLARE
      --Variavel erro
      vr_flgok BOOLEAN;
      -- Variavel de retorno de erro
      vr_des_erro VARCHAR2(4000);
      -- Variavel de Excecao
      vr_exc_erro EXCEPTION;

    BEGIN
      --Inicializar variaveis retorno
      pr_stsnrcal:= FALSE;
      pr_inpessoa:= 1;
      --Se tamanho > 11 eh cnpj
      IF LENGTH(pr_nrcalcul) > 11 THEN
        --Pessoa juridica
        pr_inpessoa:= 2;

        --Validar CNPJ
        pc_valida_cnpj (pr_nrcalcul => pr_nrcalcul
                       ,pr_stsnrcal => pr_stsnrcal);

      ELSE
        --Pessoa Fisica
        pr_inpessoa:= 1;

        --Validar CPF
        pc_valida_cpf (pr_nrcalcul => pr_nrcalcul
                      ,pr_stsnrcal => pr_stsnrcal);

        --Se nao validou tentar como cnpj
        IF NOT pr_stsnrcal THEN
          --Validar CNPJ
          pc_valida_cnpj (pr_nrcalcul => pr_nrcalcul
                         ,pr_stsnrcal => pr_stsnrcal);
          --Se validou
          IF pr_stsnrcal THEN
            --Pessoa Juridica
            pr_inpessoa:= 2;
          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN --> Erro tratado
        -- Retornar erro
        pr_stsnrcal:= FALSE;
      WHEN OTHERS THEN -- Gerar log de erro
        -- Retornar o erro
        pr_stsnrcal:= FALSE;
    END;
  END pc_valida_cpf_cnpj;

  /* Funcao para retornar digito cnpj */
  FUNCTION fn_retorna_digito_cnpj (pr_nrcalcul IN NUMBER) RETURN NUMBER IS       --Numero a ser verificado
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_retorna_digito_cnpj            Antigo: b1wgen9998.p/retorna-digito-cnpj
    --  Sistema  : Rotinas genericas
    --  Sigla    : GENE
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Validar cpf e cnpj informado
    --
    --   Alteracoes: 06/08/2013 - Conversao Progress para Oracle - Alisson (AMcom)
    -- .............................................................................
    DECLARE
      --Variaveis Locais
      vr_nrdigit1 INTEGER:= 0;
      vr_nrdigit2 INTEGER:= 0;
      vr_nrposica INTEGER:= 0;
      vr_vlrdpeso INTEGER:= 2;
      vr_vlcalcul INTEGER:= 0;
      vr_vldresto INTEGER:= 0;
      vr_vlresult INTEGER:= 0;
      vr_nrcalcul NUMBER;

      -- Variavel de retorno de erro
      vr_des_erro VARCHAR2(4000);
      -- Variavel de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      IF LENGTH(pr_nrcalcul) < 3 OR LENGTH(pr_nrcalcul) > 12 THEN
        --Retornar OK
        RETURN(NULL);
      END IF;
      --Calcular Digito
      vr_vlcalcul:= TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),1,1)) * 2;
      vr_vlresult:= TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),2,1)) +
                    TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),4,1)) +
                    TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),6,1)) +
                    TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),1,1)) +
                    TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),2,1));
      vr_vlcalcul:= TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),3,1)) * 2;
      vr_vlresult:= vr_vlresult +
                    TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),1,1)) +
                    TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),2,1));
      vr_vlcalcul:= TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),5,1)) * 2;
      vr_vlresult:= vr_vlresult +
                    TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),1,1)) +
                    TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),2,1));
      vr_vlcalcul:= TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,'fm00000000000000'),7,1)) * 2;
      vr_vlresult:= vr_vlresult +
                    TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),1,1)) +
                    TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul),2,1));
      vr_vldresto:= Mod(vr_vlresult,10);

      --Se valor resto for zero
      IF vr_vldresto = 0  THEN
        --Digito recebe resto
        vr_nrdigit1:= vr_vldresto;
      ELSE
        vr_nrdigit1:= 10 - vr_vldresto;
      END IF;
      --Zerar valor calculado
      vr_vlcalcul:= 0;

      --Calcular digito
      FOR vr_nrposica IN REVERSE 1..LENGTH(pr_nrcalcul) LOOP
        vr_vlcalcul:= vr_vlcalcul + (TO_NUMBER(SUBSTR(pr_nrcalcul,vr_nrposica,1)) * vr_vlrdpeso);
        --Incrementar peso
        vr_vlrdpeso:= vr_vlrdpeso+1;
        --Se peso > 9
        IF vr_vlrdpeso > 9 THEN
           vr_vlrdpeso:= 2;
        END IF;
      END LOOP;
      --Calcular resto modulo 11
      vr_vldresto:= Mod(vr_vlcalcul,11);
      IF  vr_vldresto < 2  THEN
        --Digito recebe zero
        vr_nrdigit1:= 0;
      ELSE
        --Digito recebe 11 menos resto
        vr_nrdigit1:= 11 - vr_vldresto;
      END IF;

      vr_vlrdpeso:= 2;
      vr_nrposica:= 0;
      vr_vlcalcul:= 0;

      vr_nrcalcul:= TO_NUMBER(TO_CHAR(pr_nrcalcul) || TO_CHAR(vr_nrdigit1));

      --Calcular digito
      FOR vr_nrposica IN REVERSE 1..LENGTH(vr_nrcalcul) LOOP
        vr_vlcalcul:= vr_vlcalcul + (TO_NUMBER(SUBSTR(vr_nrcalcul,vr_nrposica,1)) * vr_vlrdpeso);
        --Incrementar peso
        vr_vlrdpeso:= vr_vlrdpeso+1;
        --Se peso > 9
        IF vr_vlrdpeso > 9 THEN
          vr_vlrdpeso:= 2;
        END IF;
      END LOOP;
      --Calcular resto modulo 11
      vr_vldresto:= Mod(vr_vlcalcul,11);
      IF  vr_vldresto < 2  THEN
        --Digito recebe zero
        vr_nrdigit2:= 0;
      ELSE
        --Digito recebe 11 menos resto
        vr_nrdigit2:= 11 - vr_vldresto;
      END IF;
      --retornar digitos
      RETURN(TO_NUMBER(TO_CHAR(vr_nrdigit1) || TO_CHAR(vr_nrdigit2)));

    EXCEPTION
      WHEN OTHERS THEN
        RETURN(NULL);
    END;
  END fn_retorna_digito_cnpj;

  /* Funcao retorna o codigo da cooperativa a partir do numero da conta junto a CECRED*/
  FUNCTION fn_cdcooper_nrctactl (pr_nrctactl IN  crapcop.nrctactl%TYPE) RETURN NUMBER IS -- Numero da conta junto a cecred
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_cdcooper_nrctactl            Antigo: fontes/util_cecred.p/p_cdcooper
    --  Sistema  : Rotinas genericas
    --  Sigla    : GENE
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Setembro/2013.                   Ultima atualizacao: 17/09/2013
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Diario (Batch).
    --   Objetivo  : retorna o codigo da cooperativa a partir do numero da conta junto a CECRED
    --
    --   Alteracoes: 17/09/2013 - Conversao Progress para Oracle - Odirlei (AMcom)
    -- .............................................................................
    DECLARE
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop
         WHERE crapcop.nrctactl = pr_nrctactl;
      rW_crapcop cr_crapcop%ROWTYPE;

    BEGIN
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        RETURN 0;
      ELSE
        CLOSE cr_crapcop;
        RETURN rw_crapcop.cdcooper;
      END IF;

    END;

  END fn_cdcooper_nrctactl;

  /* retorna o codigo da ultima cooperativa cadastrada*/
  FUNCTION fn_ultima_cdcooper RETURN NUMBER IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_ultima_cdcooper            Antigo: fontes/util_cecred.p/f_cdultimacoop
    --  Sistema  : Rotinas genericas
    --  Sigla    : GENE
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Setembro/2013.                   Ultima atualizacao: 17/09/2013
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Diario (Batch).
    --   Objetivo  : retorna o codigo da ultima cooperativa cadastrada - utilizado no programa crps383 - Faturas Bradesco
    --
    --   Alteracoes: 17/09/2013 - Conversao Progress para Oracle - Odirlei (AMcom)
    -- .............................................................................
    DECLARE
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop cop
         WHERE cop.cdcooper <> 3
           AND cop.progress_recid =
                   (SELECT MAX(cop1.progress_recid)
                      FROM crapcop cop1);
      rw_crapcop cr_crapcop%ROWTYPE;

    BEGIN
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        RETURN 0;
      ELSE
        CLOSE cr_crapcop;
        RETURN rw_crapcop.cdcooper;
      END IF;

    END;

  END fn_ultima_cdcooper;

  /* Calcular o dígito verificador da conta */
  FUNCTION fn_calc_digito(pr_nrcalcul IN OUT NUMBER                               --> Número da conta
                         ,pr_reqweb   IN BOOLEAN DEFAULT FALSE) RETURN BOOLEAN IS --> Identificador se a requisição é da Web
  BEGIN
    -- ..........................................................................
    -- Programa: fn_calc_digito                  Antigo: Fontes/digfun.p
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Deborah/Edson
    -- Data    : Setembro/91                     Ultima atualizacao: 09/12/2005
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que chamado por outros programas.
    -- Objetivo  : Calcular e conferir o digito verificador pelo modulo onze.
    --             Disponibilizar nro calculado digito "X" (Mirtes)
    --
    --   Alteracoes: 09/12/2005 - Eliminada variavel glb_nrcalcul_c (Magui)..
    --               13/12/2012 - Conversão Progress --> Oracle PLSQL (Alisson - AMcom)
    --               29/05/2013 - Incluído parâmetro e consistência para origem da Web (Petter - Supero)
    -- .............................................................................
    DECLARE
      --Variaveis Locais
      vr_digito   INTEGER:= 0;
      vr_posicao  INTEGER:= 0;
      vr_peso     INTEGER:= 9;
      vr_calculo  INTEGER:= 0;
      vr_resto    INTEGER:= 0;

    BEGIN
      -- Trata conta da CONCREDI na CEF
      IF pr_nrcalcul = gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'CTA_CONCREDI_CEF') AND pr_reqweb = FALSE THEN
        pr_nrcalcul:= 30035008;
        RETURN(TRUE);
      ELSIF pr_nrcalcul = gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'CTA_CONCREDI_CEF_INTEGRA') AND pr_reqweb = TRUE THEN
        RETURN(TRUE);
      END IF;

      -- Se o tamanho da conta for < 2
      IF LENGTH(pr_nrcalcul) < 2 THEN
        return(FALSE);
      END IF;

      -- Percorrer cada numero da conta ignorando o ultimo digito
      FOR idx IN REVERSE 1..(LENGTH(pr_nrcalcul)-1) LOOP
        vr_calculo:= vr_calculo + (TO_NUMBER(SUBSTR(pr_nrcalcul,idx,1)) * vr_peso);
        --Diminuir o peso para calcular proximo
        vr_peso:= vr_peso-1;
        IF vr_peso=1 THEN
          vr_peso:= 9;
        END IF;
      END LOOP;

      --Calcular o resto pelo Modulo 11
      vr_resto:= MOD(vr_calculo,11);

      --Atribuir o valor do resto para o digito
      IF vr_resto > 9 THEN
        vr_digito:= 0;
      ELSE
        vr_digito:= vr_resto;
      END IF;

      --Comparar o digito calculado com o do parametro
      IF vr_digito <> TO_NUMBER(SUBSTR(pr_nrcalcul,LENGTH(pr_nrcalcul),1)) THEN
        --Atribuir ao parametro o digito correto
        pr_nrcalcul:= TO_NUMBER(SUBSTR(pr_nrcalcul,1,LENGTH(pr_nrcalcul)-1)||vr_digito);
        RETURN(FALSE);
      ELSE
        RETURN(TRUE);
      END IF;
    END;
  END fn_calc_digito;

  FUNCTION fn_dtfun(pr_dtcalcul IN DATE , -- data para ser calculada.
                    pr_qtdmeses IN NUMBER -- qtd de meses a ser somado ou diminuido da data informada no parametro.
                    ) RETURN DATE IS
  BEGIN
  -- ..........................................................................
  --
  --  Programa : fn_dtfun (Fontes/datfun.p)
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Deborah/Edson
  --   Data    : Junho/1996                          Ultima Atualizacao:
  --
  --   Dados referentes ao programa:
  --   Frequencia: Sempre que chamado por outros programas.
  --   Objetivo  : Efetuar operacoes com datas.
  --   Observacoes : 1 - Sabado e documento não são considerados uteis
  --                 2 - Dias cadastrados na CRAPFER não são considerados uteis
  --
  --   Alteracoes  :
  -- .............................................................................
  DECLARE
    vr_ddcalcul  NUMBER;
    vr_mmcalcul  NUMBER;
    vr_aacalcul  NUMBER;
    vr_contador  NUMBER;
    vr_dtultdia  NUMBER;
    vr_dtcalcul  DATE;
    vr_dt_temp   VARCHAR2(25);

    BEGIN
      IF pr_qtdmeses > 0 THEN -- verifica se quantidade de meses a ser somado ou diminuido da data informada no panrametro é maior que zero.
        vr_ddcalcul := to_number(to_char(pr_dtcalcul,'dd'));-- dia da data informada no parametro
        vr_mmcalcul := to_number(to_char(pr_dtcalcul, 'mm')); -- mes da data informada no parametro
        vr_aacalcul := to_number(to_char(pr_dtcalcul, 'yyyy'));--ano da data informada no parametro.

        --contador para somar a quantidade de meses à data a ser calculada.
        FOR vr_contador IN 1.. pr_qtdmeses
        LOOP
          IF vr_mmcalcul = 12 THEN -- verifica se o mes calculado é dezembro(12)
             vr_mmcalcul := 1;--altera o mes calculado para janeiro(01)
             vr_aacalcul := vr_aacalcul + 1;--altera o ano calculado para o ano seguinte.
          ELSE
             vr_mmcalcul := vr_mmcalcul + 1;--altera o mes calculado para o próximo mes.
          END IF;
        END LOOP; -- fim do contador
        --transforma numeros em caracters e formata com zero no inicio caso nao tenha 2 caracteres cada variavel
        vr_dt_temp := LPAD(vr_mmcalcul,2,'0')||'01'||vr_aacalcul;
        vr_dtcalcul := to_date(vr_dt_temp, 'mm-dd-yyyy');  -- monta a data calculada
        vr_dtultdia := to_char(last_day(vr_dtcalcul),'dd');--busca o ultimo dia do mes referenta a data calculada

        IF vr_ddcalcul > vr_dtultdia THEN -- verifica se o dia da data a ser calculada é maior que o último dia do mes calculado
          vr_dt_temp := LPAD(vr_mmcalcul,2,'0')||LPAD(vr_dtultdia,2,'0')||vr_aacalcul;
          vr_dtcalcul := to_date(vr_dt_temp, 'mm-dd-yyyy');--calcula novamente a data utilizando o utlimo dia do mes calculado
        ELSE
          vr_dt_temp := LPAD(vr_mmcalcul,2,'0')||lpad(vr_ddcalcul,2,'0')||vr_aacalcul;
          vr_dtcalcul := to_date(vr_dt_temp, 'mm-dd-yyyy');  -- monta a data calculada
        END IF;

      ELSIF pr_qtdmeses < 0 THEN -- verifica se quantidade de meses a ser somado ou diminuido da data informada no panrametro é menor que zero.
        vr_ddcalcul := to_number(to_char(pr_dtcalcul,'dd'));-- dia da data informada no parametro
        vr_mmcalcul := to_number(to_char(pr_dtcalcul, 'mm')); -- mes da data informada no parametro
        vr_aacalcul := to_number(to_char(pr_dtcalcul, 'yyyy'));--ano da data informada no parametro.

        --contador para diminuir a quantidade de meses à data a ser calculada.
        FOR vr_contador IN 1.. pr_qtdmeses *(-1)
        LOOP
          IF vr_mmcalcul = 1 THEN -- verifica se o mes calculado é janeiro(1)
             vr_mmcalcul := 12;--altera mes calculado para dezembro(01)
             vr_aacalcul := vr_aacalcul - 1;--altera o ano calculado para o ano anterior
          ELSE
             vr_mmcalcul := vr_mmcalcul - 1;--altera o mes calculado para o mes anterior.
          END IF;
        END LOOP; -- fim do contador
        --transforma numeros em caracters e formata com zero no inicio caso nao tenha 2 caracteres cada variavel
        vr_dt_temp := LPAD(vr_mmcalcul,2,'0')||'01'||vr_aacalcul;
        vr_dtcalcul := to_date(vr_dt_temp, 'mm-dd-yyyy'); -- monta a data calculada
        vr_dtultdia := to_char(last_day(vr_dtcalcul),'dd');--busca o ultimo dia do mes referenta a data calculada

        IF vr_ddcalcul > vr_dtultdia THEN -- verifica se o dia da data a ser calculada é maior que o último dia do mes calculado
          vr_dt_temp := LPAD(vr_mmcalcul,2,'0')||LPAD(vr_dtultdia,2,'0')||vr_aacalcul;
          vr_dtcalcul := to_date(vr_dt_temp, 'mm-dd-yyyy');--calcula novamente a data utilizando o utlimo dia do mes calculado
        ELSE
          vr_dt_temp := LPAD(vr_mmcalcul,2,'0')||lpad(vr_ddcalcul,2,'0')||vr_aacalcul;
          vr_dtcalcul := to_date(vr_dt_temp, 'mm-dd-yyyy');  -- monta a data calculada
        END IF;
      END IF;
      RETURN vr_dtcalcul;--retorna a data calculada
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;


  END fn_dtfun;

  PROCEDURE pc_intdec(pr_vlcalcul IN NUMBER, --valor a ser quebrado
                      pr_vlintcal OUT NUMBER, -- retorna valor inteiro
                      pr_vldeccal OUT NUMBER, -- retorna valor decimal
                      pr_des_erro OUT VARCHAR2
                      )IS
    /* .............................................................................

       Programa: pc_intdec(Fontes/intdec.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Junho/96                     Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Devolver a parte inteira e decimal de um valor.

       Alteracoes:

    ............................................................................ */

  BEGIN
    -- Guardar somente a parte inteira do número, buscando do início do mesmo como texto até encontrar o "ponto".
    pr_vlintcal := to_number(SUBSTR(to_char(pr_vlcalcul, 'fm9999999990.9999'),1,INSTR(to_char(pr_vlcalcul,'fm9999999990.9999'),'.')-1));
    -- Guardar somente a parte decimal do número, buscando os valores apos o "ponto".
    pr_vldeccal := to_number(SUBSTR(to_char(pr_vlcalcul, 'fm9999999990.9000'),INSTR(to_char(pr_vlcalcul,'fm9999999990.9000'),'.')+1))/ 10000;

    IF pr_vlcalcul < 0 THEN -- verifica se o valor é negativo para forçar positivo
      pr_vlintcal := pr_vlintcal * -1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pr_des_erro:= 'Erro na procedure gene0005.pc_intdec. '||SQLERRM;
  END pc_intdec;

  /* Calcular nro de meses/dias recebendo como parametro data inicio e data fim */
  PROCEDURE pc_calc_mes(pr_datadini   IN DATE       --> Data base inicio
                       ,pr_datadfim   IN DATE       --> Data base fim
                       ,pr_qtdadmes  OUT NUMBER     --> Quantidade de meses
                       ,pr_qtdadias  OUT NUMBER) IS --> Quantidade de dias
  BEGIN
    /* .............................................................................

     Programa: pc_calc_mes (Antigo b1wgen0007.p)
     Autora  : Mirtes/Junior.
     Data    : 23/11/2005                     Ultima atualizacao: 11/01/2013

     Dados referentes ao programa:

     Objetivo  : Calcular nro de meses/dias recebendo como parametro
                 data inicio e data fim.

                 Adaptado de fontes/calcmes.p

     Alteracoes: 19/05/2006 - Incluido codigo da cooperativa nas leituras das
                              tabelas (Diego).

                 27/12/2007 - Retirada dos FINDs crapcop e crapdat, pois este nao
                              estava sendo necessario (Julio)

                 11/01/2013 - Conversão Progress >> Oracle PLSQL (Marcos - Supero)
       ............................................................................. */
    DECLARE
      -- Auxiliares para trabalhar com a fn_calc_data
      vr_dtdentra DATE;
      vr_dtdsaida DATE;
    BEGIN
      -- Inicializar contadores de diferença
      pr_qtdadmes := 0;
      pr_qtdadias := 0;
      -- Somente continuar se foi enviado a data inicial e final
      -- e se a data final for efetivamente maior que a data inicial
      IF pr_datadini IS NOT NULL AND pr_datadfim IS NOT NULL AND pr_datadini < pr_datadfim THEN
        -- Data de entrada baseia-se na data inicial enviada
        vr_dtdentra := pr_datadini;
        -- Já atribuir na quantidade de dias a diferença
        -- entre a data fim e a inicial, pois quando for menor que
        -- um mês, já teremos a quantidade de dias final
        pr_qtdadias := pr_datadfim - pr_datadini;
        -- Separa o próximo bloco em LOOP, pois faremos
        -- várias adição de meses sob a data base até
        -- chegar numa data posterior a enviada
        LOOP
          -- Adiciona um mês
          vr_dtdsaida := fn_calc_data(pr_dtmvtolt  => vr_dtdentra --> Data de entrada
                                     ,pr_qtmesano  => 1           --> 1 mês a acumular
                                     ,pr_tpmesano  => 'M'         --> Tipo Mes
                                     ,pr_des_erro  => vr_des_erro);
          -- Sair quando o acumulo de 1 mês a data base
          -- chegar em uma data posterior a final
          EXIT WHEN vr_dtdsaida > pr_datadfim;
          -- Utilizar como data de entrada a nova data
          vr_dtdentra := vr_dtdsaida;
          -- Acumular +1 Mês na contagem
          pr_qtdadmes := pr_qtdadmes + 1;
          -- Novamente diminuir da quantidade de dias a diferença
          -- entre a data fim e a inicial, pois quando for menor que
          -- um mês, já teremos a quantidade de dias final
          pr_qtdadias := pr_datadfim - vr_dtdsaida;
        END LOOP;
      END IF;
    END;
  END pc_calc_mes;

  /* Calcular uma data futura conforme parâmetros */
  FUNCTION fn_calc_data(pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                       ,pr_qtmesano  IN INTEGER               --> Quantidade a acumular
                       ,pr_tpmesano  IN VARCHAR2              --> Tipo Mes ou Ano
                       ,pr_des_erro OUT VARCHAR2) RETURN DATE IS
  BEGIN
    -- ..........................................................................
    --
    --   Programa : fn_calc_data (Antigo fontes/calcdata.p)
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Odair
    --   Data    : Abril/97                          Ultima Atualizacao: 13/11/2012
    --
    --   Dados referentes ao programa:
    --   Frequencia: Sempre que chamado por outros programas.
    --   Objetivo  : Calcular datas recebendo como parametro data base e
    --               se é para calcular meses(M) ou Anos (A)
    --               quantidade a frente.
    --
    --   Alteracoes: 12/11/2012 - Conversão Progress --> Oracle PLSQL (Marcos - Supero)
    -- .............................................................................
    DECLARE
      vr_dtinicio DATE;
      vr_dtfimqtd DATE;
      vr_mesrefer INTEGER;
      vr_anorefer INTEGER;
    BEGIN
      -- Se não foi informado um parâmetro correto
      IF pr_tpmesano NOT IN ('M','A') THEN
        -- Gerar erro
        pr_des_erro := 'TIPO DE PARAMETRO ERRADO';
        RETURN NULL;
      -- Se for mes e foi informado mais do que 11 meses
      ELSIF pr_tpmesano = 'M' AND pr_qtmesano > 11 THEN
        -- Gerar erro
        pr_des_erro := 'QUANTIDADE DE MESES DEVE ESTAR ENTRE 1 E 11';
        RETURN NULL;
      -- Se foi solicitado adição de anos
      ELSIF pr_tpmesano = 'A' THEN
        -- Se for 29/02
        IF to_char(pr_dtmvtolt,'dd') = '29' AND to_char(pr_dtmvtolt,'mm') = '02' THEN
          -- Considerar 01/03 do ano passado + qtde passada
          RETURN to_date('0103'||to_char(to_number(to_char(pr_dtmvtolt,'yyyy'))+pr_qtmesano),'ddmmyyyy');
        ELSE
          -- Considerar mesmo dia/mes passado e adicionar os anos enviados
          RETURN to_date(to_char(pr_dtmvtolt,'ddmm')||(to_char(pr_dtmvtolt,'yyyy')+pr_qtmesano),'ddmmyyyy');
        END IF;
      -- Senão é adição de meses
      ELSE
        -- Data de início recebe a data enviada - o dia da mesma
        vr_dtinicio := pr_dtmvtolt - to_char(pr_dtmvtolt,'dd');
        -- Mês de referência recebe o mês enviado + qtde enviada
        vr_mesrefer := to_number(to_char(pr_dtmvtolt,'mm')) + pr_qtmesano;
        -- Tratar troca de ano
        IF vr_mesrefer > 12 THEN
          -- Incrementar +1
          vr_anorefer := 1;
        ELSE
          -- Não incrementar
          vr_anorefer := 0;
        END IF;
        -- Tratar troca de mês
        IF vr_mesrefer > 12 THEN
          -- Decrementar 12 meses
          vr_mesrefer := vr_mesrefer - 12;
        END IF;
        -- Busca da data final para calcular a diferença com a enviada
        vr_dtfimqtd := to_date('01'||lpad(vr_mesrefer,2,'0')||to_char((to_number(to_char(pr_dtmvtolt,'yyyy'))+vr_anorefer)),'ddmmyyyy');
        -- Se for Fevereiro e foi passada dia 31
        IF vr_mesrefer = 2 AND to_char(pr_dtmvtolt,'dd') = 31 THEN
          -- Testar se é um ano bissexto
          IF to_number(to_char(vr_dtfimqtd,'yyyy')) MOD 4 = 0 THEN
            -- É um ano bissexto e devemos subtrair dois dias
            vr_dtfimqtd := vr_dtfimqtd - 2;
          ELSE
            -- Não é bissexto, subtraimos 3 dias
            vr_dtfimqtd := vr_dtfimqtd - 3;
          END IF;
        -- Se for Fevereiro e o dia for 30
        ELSIF vr_mesrefer = 2 AND to_char(pr_dtmvtolt,'dd') = 30 THEN
          -- Testar se é um ano bissexto
          IF to_number(to_char(vr_dtfimqtd,'yyyy')) MOD 4 = 0 THEN
            -- É um ano bissexto e devemos subtrair um dia
            vr_dtfimqtd := vr_dtfimqtd - 1;
          ELSE
            -- Não é bissexto, subtraimos 2 dias
            vr_dtfimqtd := vr_dtfimqtd - 2;
          END IF;
        ELSE --> Diminuir 1 dia da data encontrada
          vr_dtfimqtd := vr_dtfimqtd - 1;
        END IF;
        -- Calcular a data final
        RETURN (vr_dtfimqtd-vr_dtinicio) + pr_dtmvtolt;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Problemas ao buscar data no FN_CALC_DATA. '||chr(10)
                    || 'Parâmetros: pr_dtmvtolt => '||pr_dtmvtolt||chr(10)
                    || '            pr_qtmesano => '||pr_qtmesano||chr(10)
                    || '            pr_tpmesano => '||pr_tpmesano||chr(10)
                    || '      Erro: '||sqlerrm;
        RETURN null;
    END;
  END fn_calc_data;

  /* Validar Nome */
  FUNCTION fn_valida_nome(pr_nomedttl IN VARCHAR2                      --> Nome para Validacao
                         ,pr_inpessoa IN crapass.inpessoa%TYPE         --> Tipo de Pessoa(1 - Fisica / 2 - Juridica / 3 - Conta Administrativa)
                         ,pr_des_erro  OUT VARCHAR2) RETURN BOOLEAN IS --> Mensagem de erro / (Retorno TRUE -> OK, FALSE -> NOK)
  BEGIN
    -- ..........................................................................
    --
    --   Programa : fn_valida_nome (Antigo b1wgen0055.p/ValidaNome)
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Jean Michel
    --   Data    : Fevereiro/2016                          Ultima Atualizacao: 11/02/2012
    --
    --   Dados referentes ao programa:
    --   Frequencia: Sempre que chamado por outros programas.
    --   Objetivo  : Validacao de Nomes, nomes de PF nao podem conter numeros
    --
    --   Alteracoes: 12/11/2012 - Conversão Progress --> Oracle PLSQL (Jean Michel)
    --
    -- .............................................................................
    DECLARE

    BEGIN
      -- Verifica se nome enviado nao possui caracteres especiais
      IF regexp_instr(pr_nomedttl,'\=|\%|\&|\#|\+|\?|\/|\;|\[|\]|\!|\@|\$|\(|\)|\*|\||\\|\:|\<|\>|\~\{|\~\}|\~|\.|\,') > 0 THEN

          pr_des_erro := 'O Caracter ' ||
                         regexp_substr(pr_nomedttl,'\=|\%|\&|\#|\+|\?|\/|\;|\[|\]|\!|\@|\$|\(|\)|\*|\||\\|\:|\<|\>|\~{|\~}|\~|\.|\,') ||
                         ' nao permitido.';

          RETURN FALSE;

      END IF;

      -- Para nomes de pessoa fisicas, nao pode haver numeros
      IF pr_inpessoa = 1 THEN

        IF regexp_instr(pr_nomedttl,'\d') > 0 THEN

          pr_des_erro := 'Nao sao permitidos numeros no nome do titular';

          RETURN FALSE;

        END IF;

      END IF;

      RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Problemas ao validar parametro. Erro: ' || SQLERRM;
        RETURN NULL;
    END;

  END fn_valida_nome;

  /* Retorna a data por extenso em portugues */
  FUNCTION fn_data_extenso (pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE) --> Data do movimento
                   RETURN VARCHAR2 IS

    -- ..........................................................................
    --
    --  Programa : fn_data_extenso
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Odirlei Busana(AMcom)
    --   Data    : Julho/2016                          Ultima Atualizacao:
    --
    --   Dados referentes ao programa:
    --   Frequencia: Sempre que chamado por outros programas.
    --   Objetivo  : Retorna a data por extenso em portugues
    --               Exemplo: 26 de Julho de 2016
    --
    --
    --
    --   Alteracoes  :
    -- .............................................................................

    vr_dsdatext VARCHAR2(500);
  BEGIN

    vr_dsdatext := to_char(pr_dtmvtolt,'DD') ||' de '||
                   INITCAP(gene0001.vr_vet_nmmesano(to_char(pr_dtmvtolt,'MM')))|| ' de ' ||
                   to_char(SYSDATE,'RRRR');

    RETURN vr_dsdatext;

  END fn_data_extenso;

  PROCEDURE pc_busca_motivos (pr_cdproduto  IN tbgen_motivo.cdproduto%TYPE --> Cod. Produto
		                     ,pr_clobxmlc  OUT CLOB                        --XML com informações de LOG
                             ,pr_des_erro  OUT VARCHAR2                    --> Status erro
                             ,pr_dscritic  OUT VARCHAR2) IS                --> Retorno de erro
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_busca_motivos
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Lucas Lunelli
    --   Data    : Maio/2016                      Ultima atualizacao:
    --
    --   Dados referentes ao programa:
    --   Frequencia: Diario (on-line)
    --   Objetivo  : Procedimento para busca de motivos.
    --
    --   Alteracoes:
    -- .............................................................................
    DECLARE

		  -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de XML
      vr_xml_temp VARCHAR2(32767);

       CURSOR cr_tbgen_motivo(pr_cdproduto IN tbgen_motivo.cdproduto%TYPE) IS
         SELECT mot.idmotivo
				       ,mot.dsmotivo
           FROM tbgen_motivo mot
          WHERE cdproduto = pr_cdproduto;
       rw_tbgen_motivo cr_tbgen_motivo%ROWTYPE;

    BEGIN
      --Inicializa variavel de erro
      vr_dscritic := NULL;
			vr_cdcritic := 0;

      OPEN cr_tbgen_motivo(pr_cdproduto => pr_cdproduto);
      FETCH cr_tbgen_motivo INTO rw_tbgen_motivo;

      IF cr_tbgen_motivo%NOTFOUND THEN

				CLOSE cr_tbgen_motivo;

				vr_dscritic := 'Registros de Motivos nao encontrados para o produto.';
				RAISE vr_exc_saida;

      END IF;

			CLOSE cr_tbgen_motivo;

			-- Criar documento XML
			dbms_lob.createtemporary(pr_clobxmlc, TRUE);
			dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

			-- Insere o cabeçalho do XML
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
														 ,pr_texto_completo => vr_xml_temp
														 ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');

      FOR rw_tbgen_motivo IN cr_tbgen_motivo (pr_cdproduto => pr_cdproduto) LOOP

			-- Montar XML com registros de aplicação
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
														 ,pr_texto_completo => vr_xml_temp
														 ,pr_texto_novo     => '<motivos>'
																								||  '<idmotivo>' || NVL(TO_CHAR(rw_tbgen_motivo.idmotivo),'0') || '</idmotivo>'
																								||  '<dsmotivo>' || NVL(TO_CHAR(rw_tbgen_motivo.dsmotivo),' ') || '</dsmotivo>'
																								|| '</motivos>');
      END LOOP;

			-- Encerrar a tag raiz
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
														 ,pr_texto_completo => vr_xml_temp
														 ,pr_texto_novo     => '</root>'
														 ,pr_fecha_xml      => TRUE);
			pr_des_erro := 'OK';

    EXCEPTION
			WHEN vr_exc_saida THEN
        pr_des_erro := 'NOK';
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
      WHEN OTHERS THEN
        pr_dscritic := 'Problemas ao buscar Tabela de Motivos '||pr_cdproduto||'. Erro na GENE0005.pc_busca_motivos: '||sqlerrm;
    END;
  END pc_busca_motivos;


  PROCEDURE pc_gera_inconsistencia(pr_cdcooper   IN tbgen_inconsist.cdcooper%TYPE --> Codigo Cooperativa
                                  ,pr_iddgrupo   IN tbgen_inconsist.idinconsist_grp%TYPE --> Codigo do Grupo
                                  ,pr_tpincons   IN tbgen_inconsist.tpinconsist%TYPE --> Tipo (1-Aviso, 2-Erro)
                                  ,pr_dsregist   IN tbgen_inconsist.dsregistro_referencia%TYPE --> Desc. do registro de referencia
                                  ,pr_dsincons   IN tbgen_inconsist.dsinconsist%TYPE --> Descricao da inconsistencia
                                  ,pr_flg_enviar IN VARCHAR2 DEFAULT 'N'            --> Indicador para enviar o e-mail na hora
                                  ,pr_des_erro   OUT VARCHAR2 --> Status erro
                                  ,pr_dscritic   OUT VARCHAR2) IS --> Retorno de erro
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_gera_inconsistencia
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Jaison Fernando
    --   Data    : Novembro/2016                      Ultima atualizacao:
    --
    --   Dados referentes ao programa:
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedimento para cadastrar as inconsistencias.
    --
    --   Alteracoes:
    -- .............................................................................
    DECLARE

      -- Cursor para verificar se deve enviar email online
      CURSOR cr_inconsist_grp IS
        SELECT decode(pr_tpincons,1,'Alerta: ', 'Erro: ') || a.nminconsist_grp dscabecalho
          FROM tbgen_inconsist_grp a
         WHERE a.idinconsist_grp = pr_iddgrupo
           AND a.tpconfig_email <> 0 -- Deve ser diferente de NAO ENVIAR EMAIL
           AND a.tpconfig_email = decode(pr_tpincons,1, 2, -- Se o erro for de alerta, enviar somente se estiver configurado para ERROS E ALERTAS
                                                        a.tpconfig_email)
           AND a.tpperiodicidade_email = 1; -- Enviar email Online
      rw_inconsist_grp cr_inconsist_grp%ROWTYPE;

      -- Cursor para buscar o grupo de pessoas para recebimento do email
      CURSOR cr_inconsist_email IS
        SELECT a.dsendereco_email
          FROM tbgen_inconsist_email_grp a
         WHERE a.idinconsist_grp = pr_iddgrupo
           AND a.cdcooper = pr_cdcooper;

		  -- Cursor da data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis Gerais
      vr_idincons tbgen_inconsist_grp.idinconsist_grp%TYPE;
      vr_dsdesti VARCHAR2(4000);
      vr_dscorpo VARCHAR2(4000);

    BEGIN
      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Busca o proximo ID
      vr_idincons := fn_sequence(pr_nmtabela => 'tbgen_inconsist'
                                ,pr_nmdcampo => 'idinconsist'
                                ,pr_dsdchave => '0');

      BEGIN
        INSERT INTO tbgen_inconsist
                   (idinconsist
                   ,cdcooper
                   ,idinconsist_grp
                   ,tpinconsist
                   ,dhinconsist
                   ,dtmvtolt
                   ,dsregistro_referencia
                   ,tbgen_inconsist.dsinconsist)
             VALUES(vr_idincons
                   ,pr_cdcooper
                   ,pr_iddgrupo
                   ,pr_tpincons
                   ,SYSDATE
                   ,rw_crapdat.dtmvtolt
                   ,pr_dsregist
                   ,pr_dsincons);
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao incluir inconsistencia: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

      -- Rotina para verificacao de envio de email
      OPEN cr_inconsist_grp;
      FETCH cr_inconsist_grp INTO rw_inconsist_grp;
      IF cr_inconsist_grp%FOUND THEN

        -- Busca as pessoas para envio do email
        FOR rw_inconsist_email IN cr_inconsist_email LOOP
          IF vr_dsdesti IS NULL THEN
            vr_dsdesti := rw_inconsist_email.dsendereco_email;
          ELSE
            vr_dsdesti := vr_dsdesti ||';'||rw_inconsist_email.dsendereco_email;
          END IF;
        END LOOP;

        -- Se possuir destinatario deve enviar email
        IF vr_dsdesti IS NOT NULL THEN
          -- Monta o corpo do email
          vr_dscorpo := '<html><body>'||
                        '<b>Inconsistencia:</b> '|| pr_dsincons||'<br>'||
                        '<b>Registro de Referencia:</b> '||pr_dsregist||'<br>'||
                        '<b>Data/Hora Ocorrencia:</b> '||to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||
                        '</body></html>';

          -- Chama rotina para envio do e-mail
          gene0003.pc_solicita_email(pr_cdprogra        => 'GENE0005'
                                    ,pr_des_destino     => vr_dsdesti
                                    ,pr_des_assunto     => rw_inconsist_grp.dscabecalho
                                    ,pr_des_corpo       => vr_dscorpo
                                    ,pr_des_anexo       => NULL
                                    ,pr_flg_enviar      => pr_flg_enviar
                                    ,pr_des_erro        => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF; -- Fim da verificacao se possui destinatario
      END IF;
      CLOSE cr_inconsist_grp;

			pr_des_erro := 'OK';

    EXCEPTION
			WHEN vr_exc_saida THEN
        pr_des_erro := 'NOK';
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na GENE0005.pc_gera_inconsistencia: ' || SQLERRM;
    END;

  END pc_gera_inconsistencia;

  FUNCTION fn_calc_qtd_dias_uteis(pr_cdcooper IN crapcop.cdcooper%TYPE
		                             ,pr_dtinical IN DATE  --> Data de inicio do cálculo
		                             ,pr_dtfimcal IN DATE) --> Data final do cálculo
																 RETURN INTEGER IS
	BEGIN
		/* .............................................................................
   Programa: fn_calc_qtd_dias_uteis       Antigo B1wgen0009.p/calc_qtd_dias_uteis
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : Dezembro/2016                       Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Calcular a quantidade de dias úteis entre a data inicial e final

   Alteracoes:


   ............................................................................. */
    DECLARE
		  -- Quantidade de dias úteis
		  vr_qtdiasut NUMBER := -1; -- Consideramos a data atual D-0
			vr_dtrefere DATE;

		  -- Verificar se a data é um feriado
			CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE
			                 ,pr_dtrefere IN crapdat.dtmvtolt%TYPE) IS
        SELECT 1
				  FROM crapfer fer
				 WHERE fer.cdcooper = pr_cdcooper
				   AND fer.dtferiad = pr_dtrefere;
			rw_crapfer cr_crapfer%ROWTYPE;
    BEGIN
			-- Atribuir data de referência
			vr_dtrefere := pr_dtinical;
		  LOOP
			  EXIT WHEN vr_dtrefere > pr_dtfimcal;

				-- Se for sábado ou domingo
				IF to_char(vr_dtrefere, 'D') = 1 OR
					 to_char(vr_dtrefere, 'D') = 7 THEN
				  vr_dtrefere := vr_dtrefere + 1; -- Busca próxima data
					CONTINUE;
			  END IF;

				-- Verificar se a data é um feriado
				OPEN cr_crapfer(pr_cdcooper => pr_cdcooper
				               ,pr_dtrefere => vr_dtrefere);
				FETCH cr_crapfer INTO rw_crapfer;

			  IF cr_crapfer%FOUND THEN
					-- Fechar cursor
					CLOSE cr_crapfer;
				  vr_dtrefere := vr_dtrefere + 1; -- Busca próxima data
					CONTINUE;
				END IF;
				-- Fechar cursor
				CLOSE cr_crapfer;

				vr_qtdiasut := vr_qtdiasut + 1; -- Incrementa quantidade de dias úteis
			  vr_dtrefere := vr_dtrefere + 1; -- Busca próxima data

			END LOOP;

			RETURN vr_qtdiasut;

		END;
  END fn_calc_qtd_dias_uteis;

  FUNCTION fn_valida_depart_operad(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
		                              ,pr_cdoperad IN crapope.cdoperad%TYPE --> Operador
		                              ,pr_dsdepart IN VARCHAR2              --> Lista de departamentos separados por ;
																	,pr_flgnegac IN INTEGER DEFAULT 0)    --> Flag de negação dos departamentos parametrizados (NOT IN pr_dsdepart)
																  RETURN INTEGER IS
	BEGIN
		/* .............................................................................
   Programa: fn_valida_depart_operad
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : Fevereiro/2017                       Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Verificar se operador pertence a algum departamento parametrizado

   Alteracoes:


   ............................................................................. */
    DECLARE
		  -- Retorno do cursor
      vr_result NUMBER;

      -- Cursor para verificar se o operador está em algum dos departamentos parametrizados
			CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
											 ,pr_cdoperad IN crapope.cdoperad%TYPE
											 ,pr_dsdepart IN crapdpo.dsdepart%TYPE) IS
				SELECT 1
				FROM crapope ope
						,crapdpo dpo
				WHERE ope.cdcooper = pr_cdcooper
					AND upper(ope.cdoperad) = upper(pr_cdoperad)
					AND dpo.cdcooper = ope.cdcooper
					AND dpo.cddepart = ope.cddepart
					AND upper(dpo.dsdepart) IN (SELECT regexp_substr(upper(pr_dsdepart),'[^;]+', 1, LEVEL) FROM dual
													 CONNECT BY regexp_substr(upper(pr_dsdepart), '[^;]+', 1, LEVEL) IS NOT NULL);

      -- Cursor para verificar se o operador não está em algum dos departamentos parametrizados
			CURSOR cr_crapope_neg(pr_cdcooper IN crapope.cdcooper%TYPE
													 ,pr_cdoperad IN crapope.cdoperad%TYPE
													 ,pr_dsdepart IN crapdpo.dsdepart%TYPE) IS
				SELECT 1
				FROM crapope ope
						,crapdpo dpo
				WHERE ope.cdcooper = pr_cdcooper
					AND upper(ope.cdoperad) = upper(pr_cdoperad)
					AND dpo.cdcooper = ope.cdcooper
					AND dpo.cddepart = ope.cddepart
					AND upper(dpo.dsdepart) NOT IN (SELECT regexp_substr(upper(pr_dsdepart),'[^;]+', 1, LEVEL) FROM dual
													 CONNECT BY regexp_substr(upper(pr_dsdepart), '[^;]+', 1, LEVEL) IS NOT NULL);


    BEGIN
			-- Buscar por departamentos listados
      IF pr_flgnegac = 0 THEN
				-- Se retornou algum registro, operador está em algum departamento listado
				OPEN cr_crapope(pr_cdcooper => pr_cdcooper
											 ,pr_cdoperad => pr_cdoperad
											 ,pr_dsdepart => pr_dsdepart);
				FETCH cr_crapope INTO vr_result;
				-- Fechar cursor
				CLOSE cr_crapope;

			ELSE -- Buscar por departamentos NÃO listados
				-- Se retornou algum registro, operador NÃO está nos departamentos listados
				OPEN cr_crapope_neg(pr_cdcooper => pr_cdcooper
													 ,pr_cdoperad => pr_cdoperad
													 ,pr_dsdepart => pr_dsdepart);
				FETCH cr_crapope_neg INTO vr_result;
				-- Fechar cursor
				CLOSE cr_crapope_neg;
			END IF;

      RETURN NVL(vr_result, 0);
		END;
  END fn_valida_depart_operad;

END gene0005;
/
