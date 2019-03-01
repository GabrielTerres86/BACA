CREATE OR REPLACE PACKAGE CECRED.TELA_CONSIG IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_CONSIG
  --  Sistema  : Rotinas focando nas funcionalidades da tela CONSIG
  --  Sigla    : TELA
  --  Autor    : CIS Corporate
  --  Data     : Setembro/2018.                   Ultima atualizacao: 11/09/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  : Agrupar rotinas que venham a ser utilizadas pela tela CONSIG.
  --
  -- Altera��o : 11/09/2018 Cria��o da package (CIS Corporate)
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Tipo que compreende o registro da tab. temporaria tt-proposta-epr */
  TYPE typ_reg_dados_emp_consig IS RECORD (
    cdcooper             crapemp.cdcooper%TYPE
   ,cdempres             crapemp.cdempres%TYPE
   ,nrdconta             crapemp.nrdconta%TYPE
   ,indconsignado        cecred.tbcadast_empresa_consig.indconsignado%TYPE
   ,nmextemp             crapemp.nmextemp%TYPE
   ,nmresemp             crapemp.nmresemp%TYPE
   ,tpmodconvenio        cecred.tbcadast_empresa_consig.tpmodconvenio%TYPE
   ,dtfchfol             crapemp.dtfchfol%TYPE
   ,dtativconsignado     cecred.tbcadast_empresa_consig.dtativconsignado%TYPE
   ,nrdialimiterepasse   cecred.tbcadast_empresa_consig.nrdialimiterepasse%TYPE
   ,indinterromper       cecred.tbcadast_empresa_consig.indinterromper%TYPE
   ,dtinterromper        DATE
   ,dsdemail             crapemp.dsdemail%TYPE
   ,dsdemailconsig       cecred.tbcadast_empresa_consig.dsdemailconsig%TYPE
   ,indalertaemailemp    cecred.tbcadast_empresa_consig.indalertaemailemp%TYPE
   ,indalertaemailconsig cecred.tbcadast_empresa_consig.indalertaemailconsig%TYPE
   ,rowid_emp_consig     urowid --> ROWID do registro.
   ,inpossuiconsig       NUMBER
   ,indautrepassecc      cecred.tbcadast_empresa_consig.indautrepassecc%TYPE
  );
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_dados_emp_consig IS TABLE OF typ_reg_dados_emp_consig INDEX BY BINARY_INTEGER;


  PROCEDURE pc_busca_empr_consig_web(pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL --> Nome da empresa
                                    ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL --> Nome reduzido da empresa
                                    ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1   --> Codigo da empresa (-1 todas)
                                    ,pr_cddopcao IN VARCHAR2 DEFAULT 'C'               --> Op��o da Tela C-Consultar, A-Alterar, H-Habilitar, D-Desabilitar
                                    ,pr_nriniseq IN INTEGER DEFAULT 0                  --> Pagina��o - Inicio de sequencia
                                    ,pr_nrregist IN INTEGER DEFAULT 0                  --> Pagina��o - N�mero de registros
                                    ,pr_xmllog   IN VARCHAR2                           --> XML com informa��es de LOG
                                     --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER                       --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2                          --> Descri��o da cr�tica
                                    ,pr_retxml   IN OUT NOCOPY xmltype                 --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2                          --> Erros do processo
                                    );

  PROCEDURE pc_busca_dados_empr_consig_car (
                                     pr_cdcooper IN crapemp.cdcooper%TYPE                  -- C�digo da Cooperativa
                                    ,pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL --> Nome da empresa
                                    ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL --> Nome reduzido da empresa
                                    ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1   --> Codigo da empresa (-1 todas)
                                    ,pr_cddopcao IN VARCHAR2 DEFAULT 'C'               --> Op��o da Tela C-Consultar, A-Alterar, H-Habilitar, D-Desabilitar
                                    ,pr_nriniseq IN INTEGER DEFAULT 0                  --> Pagina��o - Inicio de sequencia
                                    ,pr_nrregist IN INTEGER DEFAULT 0                  --> Pagina��o - N�mero de registros
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                    ,pr_idorigem IN NUMBER   -- C�digo de Origem
                                    ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                  --> OUT <--
                                 ,pr_clobxmlc   OUT CLOB                           -- Arquivo de retorno do XML
                                 ,pr_cdcritic OUT PLS_INTEGER                          --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2                             --> Descri��o da cr�tica
                                 );

  PROCEDURE pc_alterar_empr_consig_web(pr_cdempres                IN tbcadast_empresa_consig.cdempres%TYPE             --> codigo da empresa.
                                      ,pr_indconsignado        IN tbcadast_empresa_consig.indconsignado%TYPE        --> indicador de convenio de desconto consignado em folha de pagamento esta habilitado. 0 - desabilitado / 1 - habilitado.
                                      ,pr_dtativconsignado     IN VARCHAR2                                          --> data de habilitacao do convenio de desconto consignado.
                                      ,pr_tpmodconvenio        IN tbcadast_empresa_consig.tpmodconvenio%TYPE        --> tipo de modalidade de convenio (1 - privado, 2 . publico e 3 - inss).
                                      ,pr_nrdialimiterepasse   IN tbcadast_empresa_consig.nrdialimiterepasse%TYPE   --> dia limite para repasse. (de 1 a 31).
                                      ,pr_indautrepassecc      IN tbcadast_empresa_consig.indautrepassecc%TYPE      --> autorizar debito repasse em c/c. (0 - n�o autorizado / 1 - autorizado)
                                      ,pr_indinterromper       IN tbcadast_empresa_consig.indinterromper%TYPE       --> indicador de interrupcao de cobranca. (0 - n�o interromper / 1 - interromper)
                                      ,pr_dsdemailconsig       IN tbcadast_empresa_consig.dsdemailconsig%TYPE       --> e-mail de contato consignado da empresa.
                                      ,pr_indalertaemailemp    IN tbcadast_empresa_consig.indalertaemailemp%TYPE    --> indicador se deve receber alerta no e-mail da empresa (0 - nao receber / 1 - receber)
                                      ,pr_indalertaemailconsig IN tbcadast_empresa_consig.indalertaemailconsig%TYPE --> indicador se deve receber alerta no e-mail de contanto consignado da empresa (0 - nao receber / 1 - receber)
                                      ,pr_dtinterromper        IN VARCHAR2                                          --> data de interrupcao de cobranca.
                                      ,pr_dtfchfol             IN crapemp.dtfchfol%TYPE                             --> Dia do Fechamento da Folha
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2              --> Erros do processo
                                      );


  PROCEDURE pc_habilitar_empr_consig_web(pr_cdempres                IN tbcadast_empresa_consig.cdempres%TYPE             --> codigo da empresa.
                                        ,pr_indconsignado        IN tbcadast_empresa_consig.indconsignado%TYPE        --> indicador de convenio de desconto consignado em folha de pagamento esta habilitado. 0 - desabilitado / 1 - habilitado.
                                        ,pr_dtativconsignado     IN VARCHAR2                                          --> data de habilitacao do convenio de desconto consignado.
                                        ,pr_tpmodconvenio        IN tbcadast_empresa_consig.tpmodconvenio%TYPE        --> tipo de modalidade de convenio (1 - privado, 2 . publico e 3 - inss).
                                        ,pr_nrdialimiterepasse   IN tbcadast_empresa_consig.nrdialimiterepasse%TYPE   --> dia limite para repasse. (de 1 a 31).
                                        ,pr_indautrepassecc      IN tbcadast_empresa_consig.indautrepassecc%TYPE      --> autorizar debito repasse em c/c. (0 - n�o autorizado / 1 - autorizado)
                                        ,pr_indinterromper       IN tbcadast_empresa_consig.indinterromper%TYPE       --> indicador de interrupcao de cobranca. (0 - n�o interromper / 1 - interromper)
                                        ,pr_dsdemailconsig       IN tbcadast_empresa_consig.dsdemailconsig%TYPE       --> e-mail de contato consignado da empresa.
                                        ,pr_indalertaemailemp    IN tbcadast_empresa_consig.indalertaemailemp%TYPE    --> indicador se deve receber alerta no e-mail da empresa (0 - nao receber / 1 - receber)
                                        ,pr_indalertaemailconsig IN tbcadast_empresa_consig.indalertaemailconsig%TYPE --> indicador se deve receber alerta no e-mail de contanto consignado da empresa (0 - nao receber / 1 - receber)
                                        ,pr_dtinterromper        IN VARCHAR2                                          --> data de interrupcao de cobranca.
                                        ,pr_dtfchfol             IN crapemp.dtfchfol%TYPE                             --> Dia do Fechamento da Folha
                                        ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2              --> Erros do processo
                                        );


  PROCEDURE pc_desabilitar_empr_consig_web(pr_cdempres     IN tbcadast_empresa_consig.cdempres%TYPE --> codigo da empresa
                                          ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                          ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                          ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2              --> Erros do processo
                                          );
end TELA_CONSIG;
/

CREATE OR REPLACE package body CECRED.TELA_CONSIG is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_CONSIG
  --  Sistema  : Rotinas focando nas funcionalidades da tela CONSIG
  --  Sigla    : TELA
  --  Autor    : CIS Corporate
  --  Data     : Setembro/2018.                   Ultima atualizacao: 11/09/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  : Agrupar rotinas que venham a ser utilizadas pela tela CONSIG.
  --
  -- Altera��o : 11/09/2018 Cria��o da package (CIS Corporate)
  --
  ---------------------------------------------------------------------------------------------------------------


  FUNCTION fn_convenio_empresa_consig(pr_cdcooper      IN crapemp.cdcooper%TYPE --> C�digo da Cooperativa
                                     ,pr_cdempres      IN crapemp.cdempres%TYPE --> Codigo da empresa
                                     ,pr_indconsignado IN tbcadast_empresa_consig.indconsignado%TYPE DEFAULT -1
                                     ) RETURN BOOLEAN IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : fn_convenio_empresa_consig
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Retornar se possui um convenio de consignado para uma determinada empresa.

      Altera��o : 11/09/2018 - Cria��o (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/
    CURSOR cr_consig IS
    SELECT tec.idemprconsig
      FROM cecred.tbcadast_empresa_consig tec
     WHERE tec.indconsignado = decode(pr_indconsignado, -1, tec.indconsignado, pr_indconsignado)
       AND tec.cdempres = pr_cdempres
       AND tec.cdcooper = pr_cdcooper;
    rw_consig cr_consig%ROWTYPE;

  BEGIN
    OPEN  cr_consig;
    FETCH cr_consig INTO rw_consig;
    IF cr_consig%FOUND THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
    CLOSE cr_consig;
  END fn_convenio_empresa_consig;


  PROCEDURE pc_validar_dia(pr_nrdia    IN NUMBER       --> Dia
                          ,pr_dscritic OUT VARCHAR2    --> Descricao da critica
                          ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_validar_dia
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Valida se o dia informado est� entre 1 e 31

      Altera��o : 11/09/2018 - Cria��o (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/

    -- Vari�vel de cr�ticas
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

  BEGIN
    IF nvl(pr_nrdia,0) <> 0 THEN
      IF NOT(pr_nrdia BETWEEN 1 AND 31) THEN
        vr_dscritic := 'O dia informado deve estar entre o intervalo de 1 a 31';
        RAISE vr_exc_erro;
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro then
         pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
         pr_dscritic := 'Erro geral na rotina TELA_CONSIG.pc_validar_dia: '||SQLERRM;
  END pc_validar_dia;


  PROCEDURE pc_busca_empr_consig (pr_cdcooper IN crapemp.cdcooper%TYPE                 --> C�digo da Cooperativa
                                 ,pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL    --> Nome da empresa
                                 ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL    --> Nome reduzido da empresa
                                 ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1      --> Codigo da empresa (-1 todas)
                                 ,pr_cddopcao IN VARCHAR2 DEFAULT 'C'                  --> Op��o da Tela C-Consultar, A-Alterar, H-Habilitar, D-Desabilitar
                                 ,pr_idorigem IN INTEGER                               --> Identificador Origem Chamada
                                 ,pr_nriniseq IN INTEGER DEFAULT 0                     --> Pagina��o - Inicio de sequencia
                                 ,pr_nrregist IN INTEGER DEFAULT 0                     --> Pagina��o - N�mero de registros
                                 --> OUT <--
                                 ,pr_qtregist OUT integer                              --> Quantidade de registros encontrados
                                 ,pr_tab_dados_emp_consig OUT typ_tab_dados_emp_consig --> Tabela de retorno
                                 ,pr_cdcritic OUT PLS_INTEGER                          --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2                             --> Descri��o da cr�tica
                                 ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_busca_empr_consig
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Busca os dados da empresa para consignado

      Altera��o : 11/09/2018 - Cria��o (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      CURSOR cr_empr_consig IS
      SELECT tmp.*
        FROM (
        SELECT row_number() OVER(ORDER BY tec.cdempres) /*rownum*/ numero_linha
              ,p.cdcooper
              ,p.cdempres
              ,p.nrdconta
              ,NVL(tec.indconsignado, 0) indconsignado --> Tabela Nova CONSIG.
              ,p.nmextemp   --> continua vindo da crapemp
              ,p.nmresemp   --> continua vindo da crapemp
              ,tec.tpmodconvenio --> Tabela Nova CONSIG.
              ,p.dtfchfol   --> continua vindo da crapemp
              ,CASE WHEN tec.indconsignado > 0 THEN tec.dtativconsignado ELSE NULL END dtativconsignado --> Tabela Nova CONSIG.
              ,tec.nrdialimiterepasse --> Tabela Nova CONSIG.
              ,tec.indautrepassecc --> Tabela Nova CONSIG.
              ,tec.indinterromper --> Tabela Nova CONSIG.
              ,tec.dtinterromper --> Tabela Nova CONSIG.
              ,p.dsdemail
              ,tec.dsdemailconsig --> Tabela Nova CONSIG.
              ,tec.indalertaemailemp --> Tabela Nova CONSIG.
              ,tec.indalertaemailconsig --> Tabela Nova CONSIG.
              ,tec.rowid      --> trocar pelo rowid da Tabela Nova CONSIG.
              ,CASE WHEN tec.idemprconsig > 0 THEN 1 ELSE 0 END inpossuiconsig
          FROM crapemp p
          LEFT JOIN cecred.tbcadast_empresa_consig tec
            ON tec.cdcooper = p.cdcooper
           AND tec.cdempres = p.cdempres
         WHERE p.cdcooper = pr_cdcooper
           AND CASE
                 WHEN pr_cdempres >= 0 AND p.cdempres = pr_cdempres THEN 1
                 WHEN pr_cdempres = -1 THEN
                   CASE
                     WHEN (pr_nmextemp IS NULL AND pr_nmresemp IS NULL) THEN 1
                     WHEN (pr_nmextemp IS NOT NULL AND (upper(p.nmextemp) LIKE '%'|| upper(pr_nmextemp) ||'%')) THEN 1
                     WHEN (pr_nmresemp IS NOT NULL AND (upper(p.nmresemp) LIKE '%'|| upper(pr_nmresemp) ||'%')) THEN 1
                     ELSE 0
                   END
                 ELSE 0
               END = 1
           ) tmp
      WHERE  CASE WHEN (pr_nriniseq + pr_nrregist) = 0 THEN 1
                  WHEN (pr_nriniseq + pr_nrregist) > 0 AND
                       numero_linha >= pr_nriniseq AND numero_linha < (pr_nriniseq + pr_nrregist) THEN 1
                  ELSE 0
             END = 1;

      rw_empr_consig cr_empr_consig%ROWTYPE;

      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descri��o e c�digo da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      vr_idtab number;
    BEGIN

      IF nvl(pr_cdempres,-1) > 0 THEN
        IF pr_cddopcao = 'A' THEN
          IF NOT(fn_convenio_empresa_consig(pr_cdcooper      => pr_cdcooper
                                           ,pr_cdempres      => pr_cdempres
                                           ,pr_indconsignado => 1)) THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Empresa n�o habilitada para Consignado. Para habilitar utilize a op��o H';
            RAISE vr_exc_erro;
          END IF;
        ELSIF pr_cddopcao = 'H' THEN
          IF fn_convenio_empresa_consig(pr_cdcooper      => pr_cdcooper
                                       ,pr_cdempres      => pr_cdempres
                                       ,pr_indconsignado => 1) THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Empresa j� habilitada para Consignado. Para altera��es, utilize a op��o A';
            RAISE vr_exc_erro;
          END IF;
        ELSIF pr_cddopcao = 'D' THEN
          IF NOT(fn_convenio_empresa_consig(pr_cdcooper      => pr_cdcooper
                                           ,pr_cdempres      => pr_cdempres
                                           ,pr_indconsignado => 1)) THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Empresa n�o habilitada para Consignado, n�o � necessario desabilitar';
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF;

      -- Se encontrou por C�digo ou por Nome Fantasia ou por Raz�o Social, preencher a tab de retorno.
      OPEN cr_empr_consig;
      LOOP
        FETCH cr_empr_consig INTO rw_empr_consig;
        EXIT WHEN cr_empr_consig%NOTFOUND;

        vr_idtab := pr_tab_dados_emp_consig.count + 1;

        pr_tab_dados_emp_consig(vr_idtab).cdcooper             := rw_empr_consig.cdcooper;
        pr_tab_dados_emp_consig(vr_idtab).cdempres             := rw_empr_consig.cdempres;
        pr_tab_dados_emp_consig(vr_idtab).nrdconta             := rw_empr_consig.nrdconta;
        pr_tab_dados_emp_consig(vr_idtab).indconsignado        := rw_empr_consig.indconsignado;
        pr_tab_dados_emp_consig(vr_idtab).nmextemp             := rw_empr_consig.nmextemp;
        pr_tab_dados_emp_consig(vr_idtab).nmresemp             := rw_empr_consig.nmresemp;
        pr_tab_dados_emp_consig(vr_idtab).tpmodconvenio        := rw_empr_consig.tpmodconvenio;
        pr_tab_dados_emp_consig(vr_idtab).dtfchfol             := rw_empr_consig.dtfchfol;
        pr_tab_dados_emp_consig(vr_idtab).dtativconsignado     := rw_empr_consig.dtativconsignado;
        pr_tab_dados_emp_consig(vr_idtab).nrdialimiterepasse   := rw_empr_consig.nrdialimiterepasse;
        pr_tab_dados_emp_consig(vr_idtab).indinterromper       := rw_empr_consig.indinterromper;
        pr_tab_dados_emp_consig(vr_idtab).dtinterromper        := rw_empr_consig.dtinterromper;
        pr_tab_dados_emp_consig(vr_idtab).dsdemail             := rw_empr_consig.dsdemail;
        pr_tab_dados_emp_consig(vr_idtab).dsdemailconsig       := rw_empr_consig.dsdemailconsig;
        pr_tab_dados_emp_consig(vr_idtab).indalertaemailemp    := rw_empr_consig.indalertaemailemp;
        pr_tab_dados_emp_consig(vr_idtab).indalertaemailconsig := rw_empr_consig.indalertaemailconsig;
        pr_tab_dados_emp_consig(vr_idtab).rowid_emp_consig     := rw_empr_consig.rowid;
        pr_tab_dados_emp_consig(vr_idtab).inpossuiconsig       := rw_empr_consig.inpossuiconsig;
        pr_tab_dados_emp_consig(vr_idtab).indautrepassecc      := rw_empr_consig.indautrepassecc;

        pr_qtregist := nvl(pr_qtregist,0) + 1;
      END LOOP;
      CLOSE cr_empr_consig;
    EXCEPTION
      WHEN vr_exc_erro THEN
        /* busca valores de critica predefinidos */
        IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
          /* busca a descri�ao da cr�tica baseado no c�digo */
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro n�o tratado na tela_consig.pc_busca_empr_consig '||sqlerrm;
        pr_cdcritic := 0;
    END;
  END pc_busca_empr_consig;

  PROCEDURE pc_busca_empr_consig_web(pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL --> Nome da empresa
                                    ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL --> Nome reduzido da empresa
                                    ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1   --> Codigo da empresa (-1 todas)
                                    ,pr_cddopcao IN VARCHAR2 DEFAULT 'C'               --> Op��o da Tela C-Consultar, A-Alterar, H-Habilitar, D-Desabilitar
                                    ,pr_nriniseq IN INTEGER DEFAULT 0                  --> Pagina��o - Inicio de sequencia
                                    ,pr_nrregist IN INTEGER DEFAULT 0                  --> Pagina��o - N�mero de registros
                                    ,pr_xmllog   IN VARCHAR2                           --> XML com informa��es de LOG
                                     --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER                       --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2                          --> Descri��o da cr�tica
                                    ,pr_retxml   IN OUT NOCOPY xmltype                 --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2                          --> Erros do processo
                                    ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_busca_empr_consig_web
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Busca os dados da empresa para consignado

      Altera��o : 11/09/2018 - Cria��o (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descri��o e c�digo da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- variaveis de retorno
      vr_tab_dados_emp_consig typ_tab_dados_emp_consig;
      vr_qtregist         number;

      -- variaveis de entrada vindas no xml
      vr_cdcooper integer;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);

      -- vari�veis para armazenar as informa�oes em xml
      vr_des_xml        clob;
      vr_texto_completo varchar2(32600);
      vr_index          varchar2(100);

      procedure pc_escreve_xml( pr_des_dados in varchar2
                              , pr_fecha_xml in boolean default false
                              ) is
      begin
          gene0002.pc_escreve_xml( vr_des_xml
                                 , vr_texto_completo
                                 , pr_des_dados
                                 , pr_fecha_xml );
      end;

    BEGIN
      pr_nmdcampo := NULL;
      pr_des_erro := 'OK';
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

      tela_consig.pc_busca_empr_consig(pr_cdcooper => vr_cdcooper
                                      ,pr_nmextemp => pr_nmextemp
                                      ,pr_nmresemp => pr_nmresemp
                                      ,pr_cdempres => pr_cdempres
                                      ,pr_cddopcao => pr_cddopcao
                                      ,pr_idorigem => vr_idorigem
                                      ,pr_nriniseq => pr_nriniseq
                                      ,pr_nrregist => pr_nrregist
                                      ,pr_qtregist => vr_qtregist
                                      ,pr_tab_dados_emp_consig => vr_tab_dados_emp_consig
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);

      IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
          raise vr_exc_erro;
      END IF;

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informa�oes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="' || vr_qtregist ||'" >');

      -- ler os registros de consignado e incluir no xml
      vr_index := vr_tab_dados_emp_consig.first;
      while vr_index is not null loop
            pc_escreve_xml('<inf>'||
                             '<cdcooper>'||             vr_tab_dados_emp_consig(vr_index).cdcooper             ||'</cdcooper>'||
                             '<cdempres>'||             vr_tab_dados_emp_consig(vr_index).cdempres             ||'</cdempres>'||
                             '<nrdconta>'||             vr_tab_dados_emp_consig(vr_index).nrdconta             ||'</nrdconta>'||
                             '<indconsignado>'||        vr_tab_dados_emp_consig(vr_index).indconsignado        ||'</indconsignado>'||
                             '<nmextemp>'||             vr_tab_dados_emp_consig(vr_index).nmextemp             ||'</nmextemp>'||
                             '<nmresemp>'||             vr_tab_dados_emp_consig(vr_index).nmresemp             ||'</nmresemp>'||
                             '<tpmodconvenio>'||        vr_tab_dados_emp_consig(vr_index).tpmodconvenio        ||'</tpmodconvenio>'||
                             '<dtfchfol>'||             vr_tab_dados_emp_consig(vr_index).dtfchfol             ||'</dtfchfol>'||
                             '<dtativconsignado>'||     to_char(vr_tab_dados_emp_consig(vr_index).dtativconsignado,'DD/MM/RRRR') ||'</dtativconsignado>'||
                             '<nrdialimiterepasse>'||   vr_tab_dados_emp_consig(vr_index).nrdialimiterepasse   ||'</nrdialimiterepasse>'||
                             '<indinterromper>'||       vr_tab_dados_emp_consig(vr_index).indinterromper       ||'</indinterromper>'||
                             '<dtinterromper>'||        to_char(vr_tab_dados_emp_consig(vr_index).dtinterromper,'DD/MM/RRRR') ||'</dtinterromper>'||
                             '<dsdemail>'||             vr_tab_dados_emp_consig(vr_index).dsdemail             ||'</dsdemail>'||
                             '<dsdemailconsig>'||       vr_tab_dados_emp_consig(vr_index).dsdemailconsig       ||'</dsdemailconsig>'||
                             '<indalertaemailemp>'||    vr_tab_dados_emp_consig(vr_index).indalertaemailemp    ||'</indalertaemailemp>'||
                             '<indalertaemailconsig>'|| vr_tab_dados_emp_consig(vr_index).indalertaemailconsig ||'</indalertaemailconsig>'||
                             '<rowid_emp_consig>'||     vr_tab_dados_emp_consig(vr_index).rowid_emp_consig     ||'</rowid_emp_consig>'||
                             '<inpossuiconsig>'||       vr_tab_dados_emp_consig(vr_index).inpossuiconsig       ||'</inpossuiconsig>'||
                             '<indautrepassecc>'||      vr_tab_dados_emp_consig(vr_index).indautrepassecc       ||'</indautrepassecc>'||
                           '</inf>');
          /* buscar proximo */
          vr_index := vr_tab_dados_emp_consig.next(vr_index);
      end loop;
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_erro THEN
           /*  se foi retornado apenas c�digo */
           IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           /* variavel de erro recebe erro ocorrido */
           pr_des_erro := 'NOK';
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
             pr_des_erro := 'NOK';
           /* montar descri�ao de erro nao tratado */
             pr_dscritic := 'erro n�o tratado na empr0013.pc_obtem_dados_consignado_web ' ||SQLERRM;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_empr_consig_web;

  PROCEDURE pc_busca_dados_empr_consig_car (
                                     pr_cdcooper IN crapemp.cdcooper%TYPE                  -- C�digo da Cooperativa
                                    ,pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL --> Nome da empresa
                                    ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL --> Nome reduzido da empresa
                                    ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1   --> Codigo da empresa (-1 todas)
                                    ,pr_cddopcao IN VARCHAR2 DEFAULT 'C'               --> Op��o da Tela C-Consultar, A-Alterar, H-Habilitar, D-Desabilitar
                                    ,pr_nriniseq IN INTEGER DEFAULT 0                  --> Pagina��o - Inicio de sequencia
                                    ,pr_nrregist IN INTEGER DEFAULT 0                  --> Pagina��o - N�mero de registros
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                    ,pr_idorigem IN NUMBER   -- C�digo de Origem
                                    ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                  --> OUT <--
                                 ,pr_clobxmlc   OUT CLOB                           -- Arquivo de retorno do XML
                                 ,pr_cdcritic OUT PLS_INTEGER                          --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2                             --> Descri��o da cr�tica
                                 ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_busca_dados_empr_consig_car
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Retornar os dados de consignado para uma determinada empresa.

      Altera��o : 11/09/2018 - Cria��o (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/
BEGIN
  DECLARE
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis auxiliares
    vr_exc_erro EXCEPTION;

    -- Variaveis de retorno
    vr_tab_dados_emp_consig tela_consig.typ_tab_dados_emp_consig;
    vr_qtregist NUMBER ;

    -- Variaveis de log
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem varchar2(100);

    -- Variaveis de XML
    vr_xml_temp VARCHAR2(32767);
    vr_index          varchar2(100);

  BEGIN
    -- Busca os dados da empresa de consignado
      tela_consig.pc_busca_empr_consig(pr_cdcooper => pr_cdcooper
                                      ,pr_nmextemp => NULL
                                      ,pr_nmresemp => NULL
                                      ,pr_cdempres => pr_cdempres
                                      ,pr_cddopcao => 'C'
                                      ,pr_idorigem => pr_idorigem
                                      ,pr_nriniseq => 0
                                      ,pr_nrregist => 0
                                      ,pr_qtregist => vr_qtregist
                                      ,pr_tab_dados_emp_consig => vr_tab_dados_emp_consig
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    -- Criar cabe�alho do XML
    dbms_lob.createtemporary(pr_clobxmlc, TRUE);
    dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabe�alho do XML
    gene0002.pc_escreve_xml (pr_xml            => pr_clobxmlc
                            ,pr_texto_completo => vr_xml_temp
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');

    IF vr_tab_dados_emp_consig.count >0 THEN
       FOR vr_index in vr_tab_dados_emp_consig.First .. vr_tab_dados_emp_consig.Last LOOP
           gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                  ,pr_texto_completo => vr_xml_temp
                                  ,pr_texto_novo     =>
                                  '<Registro>'||
                                 '<cdcooper>'||             vr_tab_dados_emp_consig(vr_index).cdcooper             ||'</cdcooper>'||
                                 '<cdempres>'||             vr_tab_dados_emp_consig(vr_index).cdempres             ||'</cdempres>'||
                                 '<nrdconta>'||             vr_tab_dados_emp_consig(vr_index).nrdconta             ||'</nrdconta>'||
                                 '<indconsignado>'||        vr_tab_dados_emp_consig(vr_index).indconsignado        ||'</indconsignado>'||
                                 '<nmextemp>'||             vr_tab_dados_emp_consig(vr_index).nmextemp             ||'</nmextemp>'||
                                 '<nmresemp>'||             vr_tab_dados_emp_consig(vr_index).nmresemp             ||'</nmresemp>'||
                                 '<tpmodconvenio>'||        vr_tab_dados_emp_consig(vr_index).tpmodconvenio        ||'</tpmodconvenio>'||
                                 '<dtfchfol>'||             vr_tab_dados_emp_consig(vr_index).dtfchfol             ||'</dtfchfol>'||
                                 '<dtativconsignado>'||     to_char(vr_tab_dados_emp_consig(vr_index).dtativconsignado,'DD/MM/RRRR') ||'</dtativconsignado>'||
                                 '<nrdialimiterepasse>'||   vr_tab_dados_emp_consig(vr_index).nrdialimiterepasse   ||'</nrdialimiterepasse>'||
                                 '<indinterromper>'||       vr_tab_dados_emp_consig(vr_index).indinterromper       ||'</indinterromper>'||
                                 '<dtinterromper>'||        to_char(vr_tab_dados_emp_consig(vr_index).dtinterromper,'DD/MM/RRRR') ||'</dtinterromper>'||
                                 '<dsdemail>'||             vr_tab_dados_emp_consig(vr_index).dsdemail             ||'</dsdemail>'||
                                 '<dsdemailconsig>'||       vr_tab_dados_emp_consig(vr_index).dsdemailconsig       ||'</dsdemailconsig>'||
                                 '<indalertaemailemp>'||    vr_tab_dados_emp_consig(vr_index).indalertaemailemp    ||'</indalertaemailemp>'||
                                 '<indalertaemailconsig>'|| vr_tab_dados_emp_consig(vr_index).indalertaemailconsig ||'</indalertaemailconsig>'||
                                 '<rowid_emp_consig>'||     vr_tab_dados_emp_consig(vr_index).rowid_emp_consig     ||'</rowid_emp_consig>'||
                                 '<inpossuiconsig>'||       vr_tab_dados_emp_consig(vr_index).inpossuiconsig       ||'</inpossuiconsig>'||
                                 '<indautrepassecc>'||      vr_tab_dados_emp_consig(vr_index).indautrepassecc       ||'</indautrepassecc>'||
                                  '</Registro>'
                                  );
       END LOOP;
    END IF;
       -- Encerrar a tag raiz
       gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Dados></Root>'
                               ,pr_fecha_xml      => TRUE);

  Exception
    When vr_exc_erro Then
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    When others Then
      pr_cdcritic := null; -- n�o ser� utilizado
      pr_dscritic := 'Erro geral em pc_busca_dados_empr_consig_car: '||SQLERRM;

  END;
  END pc_busca_dados_empr_consig_car;


  PROCEDURE pc_alterar_empr_consig(pr_cdcooper             IN crapcop.cdcooper%TYPE                             --> C�digo da Cooperativa
                                  ,pr_cdempres                IN tbcadast_empresa_consig.cdempres%TYPE             --> codigo da empresa.
                                  ,pr_indconsignado        IN tbcadast_empresa_consig.indconsignado%TYPE        --> indicador de convenio de desconto consignado em folha de pagamento esta habilitado. 0 - desabilitado / 1 - habilitado.
                                  ,pr_dtativconsignado     IN tbcadast_empresa_consig.dtativconsignado%TYPE     --> data de habilitacao do convenio de desconto consignado.
                                  ,pr_tpmodconvenio        IN tbcadast_empresa_consig.tpmodconvenio%TYPE        --> tipo de modalidade de convenio (1 - privado, 2 . publico e 3 - inss).
                                  ,pr_nrdialimiterepasse   IN tbcadast_empresa_consig.nrdialimiterepasse%TYPE   --> dia limite para repasse. (de 1 a 31).
                                  ,pr_indautrepassecc      IN tbcadast_empresa_consig.indautrepassecc%TYPE      --> autorizar debito repasse em c/c. (0 - n�o autorizado / 1 - autorizado)
                                  ,pr_indinterromper       IN tbcadast_empresa_consig.indinterromper%TYPE       --> indicador de interrupcao de cobranca. (0 - n�o interromper / 1 - interromper)
                                  ,pr_dsdemailconsig       IN tbcadast_empresa_consig.dsdemailconsig%TYPE       --> e-mail de contato consignado da empresa.
                                  ,pr_indalertaemailemp    IN tbcadast_empresa_consig.indalertaemailemp%TYPE    --> indicador se deve receber alerta no e-mail da empresa (0 - nao receber / 1 - receber)
                                  ,pr_indalertaemailconsig IN tbcadast_empresa_consig.indalertaemailconsig%TYPE --> indicador se deve receber alerta no e-mail de contanto consignado da empresa (0 - nao receber / 1 - receber)
                                  ,pr_dtinterromper        IN tbcadast_empresa_consig.dtinterromper%TYPE        --> data de interrupcao de cobranca.
                                  ,pr_dtfchfol             IN crapemp.dtfchfol%TYPE                             --> Dia do Fechamento da Folha
                                  ,pr_dsmensag             OUT VARCHAR2                                         --> Mensagem
                                  ,pr_cdcritic             OUT PLS_INTEGER                                      --> Codigo da critica
                                  ,pr_dscritic             OUT VARCHAR2                                         --> Descricao da critica
                                  ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_alterar_empr_consig
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Alterar as informa��es do conv�nio do Consignado

      Altera��o : 11/09/2018 - Cria��o (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

  BEGIN
    pr_dsmensag := NULL;

    pc_validar_dia(pr_nrdia    => pr_nrdialimiterepasse
                  ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    pc_validar_dia(pr_nrdia    => pr_dtfchfol
                  ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    UPDATE cecred.tbcadast_empresa_consig tec
       SET indconsignado        = pr_indconsignado
          ,dtativconsignado     = pr_dtativconsignado
          ,tpmodconvenio        = pr_tpmodconvenio
          ,nrdialimiterepasse   = pr_nrdialimiterepasse
          ,indautrepassecc      = pr_indautrepassecc
          ,dsdemailconsig       = pr_dsdemailconsig
          ,indalertaemailemp    = pr_indalertaemailemp
          ,indalertaemailconsig = pr_indalertaemailconsig
          ,indinterromper       = pr_indinterromper
          ,dtinterromper        = CASE WHEN pr_indinterromper = 1 THEN pr_dtinterromper ELSE NULL END
     WHERE tec.cdempres = pr_cdempres
       AND tec.cdcooper = pr_cdcooper;

    -- Caso ocorra altera��o do Dia Fechamento Folha na tela CONSIG, esta deve ser refletida na tela CADEMP.
    UPDATE crapemp emp
       SET dtfchfol = nvl(pr_dtfchfol, dtfchfol)
     WHERE emp.cdempres = pr_cdempres
       AND emp.cdcooper = pr_cdcooper;

    pr_dsmensag := 'Conv�nio de consignado atualizado com sucesso.';

  EXCEPTION
    WHEN vr_exc_erro then
         IF  vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'Erro geral na rotina TELA_CONSIG.pc_alterar_empr_consig: '||SQLERRM;
  END pc_alterar_empr_consig;

  PROCEDURE pc_alterar_empr_consig_web(pr_cdempres                IN tbcadast_empresa_consig.cdempres%TYPE             --> codigo da empresa.
                                      ,pr_indconsignado        IN tbcadast_empresa_consig.indconsignado%TYPE        --> indicador de convenio de desconto consignado em folha de pagamento esta habilitado. 0 - desabilitado / 1 - habilitado.
                                      ,pr_dtativconsignado     IN VARCHAR2                                          --> data de habilitacao do convenio de desconto consignado.
                                      ,pr_tpmodconvenio        IN tbcadast_empresa_consig.tpmodconvenio%TYPE        --> tipo de modalidade de convenio (1 - privado, 2 . publico e 3 - inss).
                                      ,pr_nrdialimiterepasse   IN tbcadast_empresa_consig.nrdialimiterepasse%TYPE   --> dia limite para repasse. (de 1 a 31).
                                      ,pr_indautrepassecc      IN tbcadast_empresa_consig.indautrepassecc%TYPE      --> autorizar debito repasse em c/c. (0 - n�o autorizado / 1 - autorizado)
                                      ,pr_indinterromper       IN tbcadast_empresa_consig.indinterromper%TYPE       --> indicador de interrupcao de cobranca. (0 - n�o interromper / 1 - interromper)
                                      ,pr_dsdemailconsig       IN tbcadast_empresa_consig.dsdemailconsig%TYPE       --> e-mail de contato consignado da empresa.
                                      ,pr_indalertaemailemp    IN tbcadast_empresa_consig.indalertaemailemp%TYPE    --> indicador se deve receber alerta no e-mail da empresa (0 - nao receber / 1 - receber)
                                      ,pr_indalertaemailconsig IN tbcadast_empresa_consig.indalertaemailconsig%TYPE --> indicador se deve receber alerta no e-mail de contanto consignado da empresa (0 - nao receber / 1 - receber)
                                      ,pr_dtinterromper        IN VARCHAR2                                          --> data de interrupcao de cobranca.
                                      ,pr_dtfchfol             IN crapemp.dtfchfol%TYPE                             --> Dia do Fechamento da Folha
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2              --> Erros do processo
                                      ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_alterar_empr_consig_web
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Agosto/2018

      Objetivo  : Alterar as informa��es do conv�nio do Consignado

      Altera��o : 11/09/2018 - Cria��o (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/
    vr_dtativconsignado tbcadast_empresa_consig.dtativconsignado%TYPE;
    vr_dtinterromper    tbcadast_empresa_consig.dtinterromper%TYPE;
    vr_dsmensag         VARCHAR2(4000);

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de dados vindos do XML pr_retxml
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

  BEGIN
    pr_nmdcampo := NULL;
    pr_des_erro := 'OK';

    BEGIN
      vr_dtinterromper := to_date(pr_dtinterromper,'DD/MM/RRRR');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Data Interrupcao Cobranca invalida';
        RAISE vr_exc_erro;
    END;

    BEGIN
      vr_dtativconsignado := to_date(pr_dtativconsignado,'DD/MM/RRRR');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Data Convenio Consignado invalida';
        RAISE vr_exc_erro;
    END;

    -- Extrai os dados vindos do XML pr_retxml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    IF  TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;

    pc_alterar_empr_consig(pr_cdcooper             => vr_cdcooper
                          ,pr_cdempres             => pr_cdempres
                          ,pr_indconsignado        => pr_indconsignado
                          ,pr_dtativconsignado     => vr_dtativconsignado
                          ,pr_tpmodconvenio        => pr_tpmodconvenio
                          ,pr_nrdialimiterepasse   => pr_nrdialimiterepasse
                          ,pr_indautrepassecc      => pr_indautrepassecc
                          ,pr_indinterromper       => pr_indinterromper
                          ,pr_dsdemailconsig       => pr_dsdemailconsig
                          ,pr_indalertaemailemp    => pr_indalertaemailemp
                          ,pr_indalertaemailconsig => pr_indalertaemailconsig
                          ,pr_dtinterromper        => vr_dtinterromper
                          ,pr_dtfchfol             => pr_dtfchfol
                          ,pr_dsmensag             => vr_dsmensag
                          ,pr_cdcritic             => vr_cdcritic
                          ,pr_dscritic             => vr_dscritic );

    IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><dsmensag>'||vr_dsmensag||'</dsmensag></Root>');

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
         IF  vr_cdcritic <> 0 THEN
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         END IF;
         pr_des_erro := 'NOK';
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;
    WHEN OTHERS THEN
         pr_des_erro := 'NOK';
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := 'Erro geral na rotina TELA_CONSIG.pc_alterar_empr_consig_web: '||SQLERRM;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;
  END pc_alterar_empr_consig_web;


  PROCEDURE pc_habilitar_empr_consig(pr_cdcooper             IN crapcop.cdcooper%TYPE                             --> C�digo da Cooperativa
                                    ,pr_cdempres                IN tbcadast_empresa_consig.cdempres%TYPE             --> codigo da empresa.
                                    ,pr_indconsignado        IN tbcadast_empresa_consig.indconsignado%TYPE        --> indicador de convenio de desconto consignado em folha de pagamento esta habilitado. 0 - desabilitado / 1 - habilitado.
                                    ,pr_dtativconsignado     IN tbcadast_empresa_consig.dtativconsignado%TYPE     --> data de habilitacao do convenio de desconto consignado.
                                    ,pr_tpmodconvenio        IN tbcadast_empresa_consig.tpmodconvenio%TYPE        --> tipo de modalidade de convenio (1 - privado, 2 . publico e 3 - inss).
                                    ,pr_nrdialimiterepasse   IN tbcadast_empresa_consig.nrdialimiterepasse%TYPE   --> dia limite para repasse. (de 1 a 31).
                                    ,pr_indautrepassecc      IN tbcadast_empresa_consig.indautrepassecc%TYPE      --> autorizar debito repasse em c/c. (0 - n�o autorizado / 1 - autorizado)
                                    ,pr_indinterromper       IN tbcadast_empresa_consig.indinterromper%TYPE       --> indicador de interrupcao de cobranca. (0 - n�o interromper / 1 - interromper)
                                    ,pr_dsdemailconsig       IN tbcadast_empresa_consig.dsdemailconsig%TYPE       --> e-mail de contato consignado da empresa.
                                    ,pr_indalertaemailemp    IN tbcadast_empresa_consig.indalertaemailemp%TYPE    --> indicador se deve receber alerta no e-mail da empresa (0 - nao receber / 1 - receber)
                                    ,pr_indalertaemailconsig IN tbcadast_empresa_consig.indalertaemailconsig%TYPE --> indicador se deve receber alerta no e-mail de contanto consignado da empresa (0 - nao receber / 1 - receber)
                                    ,pr_dtinterromper        IN tbcadast_empresa_consig.dtinterromper%TYPE        --> data de interrupcao de cobranca.
                                    ,pr_dtfchfol             IN crapemp.dtfchfol%TYPE                             --> Dia do Fechamento da Folha
                                    ,pr_dsmensag             OUT VARCHAR2                                         --> Mensagem
                                    ,pr_cdcritic             OUT PLS_INTEGER                                      --> Codigo da critica
                                    ,pr_dscritic             OUT VARCHAR2                                         --> Descricao da critica
                                    ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_habilitar_empr_consig
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Habilitar o conv�nio de consignado para uma empresa

      Altera��o : 11/09/2018 - Cria��o (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

  BEGIN
    pr_dsmensag := NULL;

    pc_validar_dia(pr_nrdia    => pr_nrdialimiterepasse
                  ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    pc_validar_dia(pr_nrdia    => pr_dtfchfol
                  ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Verifica se j� existe um convenio de consignado cadastrado, se existir somente habilitar o mesmo, caso contr�tio inserir um novo
    IF fn_convenio_empresa_consig(pr_cdcooper => pr_cdcooper
                                 ,pr_cdempres => pr_cdempres) THEN

      pc_alterar_empr_consig(pr_cdcooper             => pr_cdcooper
                            ,pr_cdempres             => pr_cdempres
                            ,pr_indconsignado        => 1
                            ,pr_dtativconsignado     => pr_dtativconsignado
                            ,pr_tpmodconvenio        => pr_tpmodconvenio
                            ,pr_nrdialimiterepasse   => pr_nrdialimiterepasse
                            ,pr_indautrepassecc      => pr_indautrepassecc
                            ,pr_indinterromper       => pr_indinterromper
                            ,pr_dsdemailconsig       => pr_dsdemailconsig
                            ,pr_indalertaemailemp    => pr_indalertaemailemp
                            ,pr_indalertaemailconsig => pr_indalertaemailconsig
                            ,pr_dtinterromper        => pr_dtinterromper
                            ,pr_dtfchfol             => pr_dtfchfol
                            ,pr_dsmensag             => pr_dsmensag
                            ,pr_cdcritic             => vr_cdcritic
                            ,pr_dscritic             => vr_dscritic );

      IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      pr_dsmensag := 'Conv�nio de consignado habilitado com sucesso.';

    ELSE
      INSERT INTO cecred.tbcadast_empresa_consig
             (/*01*/ cdcooper
             ,/*02*/ cdempres
             ,/*03*/ indconsignado
             ,/*04*/ dtativconsignado
             ,/*05*/ tpmodconvenio
             ,/*06*/ nrdialimiterepasse
             ,/*07*/ indautrepassecc
             ,/*08*/ dsdemailconsig
             ,/*09*/ indalertaemailemp
             ,/*10*/ indalertaemailconsig
             ,/*11*/ indinterromper
             ,/*12*/ dtinterromper)
      VALUES (/*01*/ pr_cdcooper
             ,/*02*/ pr_cdempres
             ,/*03*/ 1
             ,/*04*/ pr_dtativconsignado
             ,/*05*/ pr_tpmodconvenio
             ,/*06*/ pr_nrdialimiterepasse
             ,/*07*/ pr_indautrepassecc
             ,/*08*/ pr_dsdemailconsig
             ,/*09*/ pr_indalertaemailemp
             ,/*10*/ pr_indalertaemailconsig
             ,/*11*/ pr_indinterromper
             ,/*12*/ CASE WHEN pr_indinterromper = 1 THEN pr_dtinterromper ELSE NULL END);

      pr_dsmensag := 'Conv�nio de consignado criado com sucesso.';
    END IF;

    -- Caso ocorra altera��o do Dia Fechamento Folha na tela CONSIG, esta deve ser refletida na tela CADEMP.
    UPDATE crapemp emp
       SET dtfchfol = nvl(pr_dtfchfol, dtfchfol)
     WHERE emp.cdempres = pr_cdempres
       AND emp.cdcooper = pr_cdcooper;

  EXCEPTION
    WHEN vr_exc_erro then
         IF  vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'Erro geral na rotina TELA_CONSIG.pc_habilitar_empr_consig: '||SQLERRM;
  END pc_habilitar_empr_consig;


  PROCEDURE pc_habilitar_empr_consig_web(pr_cdempres                IN tbcadast_empresa_consig.cdempres%TYPE             --> codigo da empresa.
                                        ,pr_indconsignado        IN tbcadast_empresa_consig.indconsignado%TYPE        --> indicador de convenio de desconto consignado em folha de pagamento esta habilitado. 0 - desabilitado / 1 - habilitado.
                                        ,pr_dtativconsignado     IN VARCHAR2                                          --> data de habilitacao do convenio de desconto consignado.
                                        ,pr_tpmodconvenio        IN tbcadast_empresa_consig.tpmodconvenio%TYPE        --> tipo de modalidade de convenio (1 - privado, 2 . publico e 3 - inss).
                                        ,pr_nrdialimiterepasse   IN tbcadast_empresa_consig.nrdialimiterepasse%TYPE   --> dia limite para repasse. (de 1 a 31).
                                        ,pr_indautrepassecc      IN tbcadast_empresa_consig.indautrepassecc%TYPE      --> autorizar debito repasse em c/c. (0 - n�o autorizado / 1 - autorizado)
                                        ,pr_indinterromper       IN tbcadast_empresa_consig.indinterromper%TYPE       --> indicador de interrupcao de cobranca. (0 - n�o interromper / 1 - interromper)
                                        ,pr_dsdemailconsig       IN tbcadast_empresa_consig.dsdemailconsig%TYPE       --> e-mail de contato consignado da empresa.
                                        ,pr_indalertaemailemp    IN tbcadast_empresa_consig.indalertaemailemp%TYPE    --> indicador se deve receber alerta no e-mail da empresa (0 - nao receber / 1 - receber)
                                        ,pr_indalertaemailconsig IN tbcadast_empresa_consig.indalertaemailconsig%TYPE --> indicador se deve receber alerta no e-mail de contanto consignado da empresa (0 - nao receber / 1 - receber)
                                        ,pr_dtinterromper        IN VARCHAR2                                          --> data de interrupcao de cobranca.
                                        ,pr_dtfchfol             IN crapemp.dtfchfol%TYPE                             --> Dia do Fechamento da Folha
                                        ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2              --> Erros do processo
                                        ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_habilitar_empr_consig_web
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Agosto/2018

      Objetivo  : Habilitar o conv�nio de emprestimo de consignado

      Altera��o : 11/09/2018 - Cria��o (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/
    vr_dtativconsignado tbcadast_empresa_consig.dtativconsignado%TYPE;
    vr_dtinterromper    tbcadast_empresa_consig.dtinterromper%TYPE;
    vr_dsmensag         VARCHAR2(4000);

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de dados vindos do XML pr_retxml
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

  BEGIN
    pr_nmdcampo := NULL;
    pr_des_erro := 'OK';
    vr_dsmensag := NULL;

    BEGIN
      vr_dtinterromper := to_date(pr_dtinterromper,'DD/MM/RRRR');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Data Interrupcao Cobranca invalida';
        RAISE vr_exc_erro;
    END;

    BEGIN
      vr_dtativconsignado := to_date(pr_dtativconsignado,'DD/MM/RRRR');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Data Convenio Consignado invalida';
        RAISE vr_exc_erro;
    END;

    -- Extrai os dados vindos do XML pr_retxml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    IF  TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;

    pc_habilitar_empr_consig(pr_cdcooper             => vr_cdcooper
                            ,pr_cdempres             => pr_cdempres
                            ,pr_indconsignado        => pr_indconsignado
                            ,pr_dtativconsignado     => vr_dtativconsignado
                            ,pr_tpmodconvenio        => pr_tpmodconvenio
                            ,pr_nrdialimiterepasse   => pr_nrdialimiterepasse
                            ,pr_indautrepassecc      => pr_indautrepassecc
                            ,pr_indinterromper       => pr_indinterromper
                            ,pr_dsdemailconsig       => pr_dsdemailconsig
                            ,pr_indalertaemailemp    => pr_indalertaemailemp
                            ,pr_indalertaemailconsig => pr_indalertaemailconsig
                            ,pr_dtinterromper        => vr_dtinterromper
                            ,pr_dtfchfol             => pr_dtfchfol
                            ,pr_dsmensag             => vr_dsmensag
                            ,pr_cdcritic             => vr_cdcritic
                            ,pr_dscritic             => vr_dscritic );

    IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><dsmensag>'||vr_dsmensag||'</dsmensag></Root>');

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
         IF  vr_cdcritic <> 0 THEN
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         END IF;
         pr_des_erro := 'NOK';
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;
    WHEN OTHERS THEN
         pr_des_erro := 'NOK';
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := 'Erro geral na rotina TELA_CONSIG.pc_habilitar_empr_consig_web: '||SQLERRM;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;
  END pc_habilitar_empr_consig_web;


  PROCEDURE pc_desabilitar_empr_consig(pr_cdcooper  IN crapcop.cdcooper%TYPE                 --> C�digo da Cooperativa
                                      ,pr_cdempres     IN tbcadast_empresa_consig.cdempres%TYPE --> codigo da empresa
                                      ,pr_dsmensag OUT VARCHAR2                              --> Mensagem
                                      ,pr_cdcritic OUT PLS_INTEGER                           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2                              --> Descricao da critica
                                      ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_desabilitar_empr_consig
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Desabilitar um conv�nio de emprestimo de consignado

      Altera��o : 11/09/2018 - Cria��o (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

  BEGIN
    pr_dsmensag := NULL;

    UPDATE cecred.tbcadast_empresa_consig tec
       SET indconsignado = 0
     WHERE tec.cdempres = pr_cdempres
       AND tec.cdcooper = pr_cdcooper;

    pr_dsmensag := 'Conv�nio de consignado desabilitado com sucesso.';

  EXCEPTION
    WHEN vr_exc_erro then
         IF  vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'Erro geral na rotina TELA_CONSIG.pc_desabilitar_empr_consig: '||SQLERRM;
  END pc_desabilitar_empr_consig;


  PROCEDURE pc_desabilitar_empr_consig_web(pr_cdempres     IN tbcadast_empresa_consig.cdempres%TYPE --> codigo da empresa
                                          ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                          ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                          ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2              --> Erros do processo
                                          ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_desabilitar_empr_consig_web
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Desabilitar o conv�nio de emprestimo de consignado

      Altera��o : 11/09/2018 - Cria��o (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/
    vr_dsmensag VARCHAR2(4000);

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de dados vindos do XML pr_retxml
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

  BEGIN
    pr_nmdcampo := NULL;
    pr_des_erro := 'OK';
    -- Extrai os dados vindos do XML pr_retxml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    IF  TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;

    pc_desabilitar_empr_consig(pr_cdcooper => vr_cdcooper
                              ,pr_cdempres    => pr_cdempres
                              ,pr_dsmensag => vr_dsmensag
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic );

    IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><dsmensag>'||vr_dsmensag||'</dsmensag></Root>');

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
         IF  vr_cdcritic <> 0 THEN
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         END IF;
         pr_des_erro := 'NOK';
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;
    WHEN OTHERS THEN
         pr_des_erro := 'NOK';
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := 'Erro geral na rotina TELA_CONSIG.pc_desabilitar_empr_consig_web: '||SQLERRM;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;
  END pc_desabilitar_empr_consig_web;


end TELA_CONSIG;
/
