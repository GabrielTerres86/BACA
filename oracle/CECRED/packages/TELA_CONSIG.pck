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
  -- Alteração : 11/09/2018 Criação da package (CIS Corporate)
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

  /* Tipo que compreende o registro da tab. temporaria tt-proposta-epr */
  TYPE typ_reg_dados_param_consig IS RECORD (
     idemprconsigparam   NUMBER
    ,cdempres            crapemp.cdempres%TYPE
    ,dtinclpropostade    VARCHAR2(10)
    ,dtinclpropostaate   VARCHAR2(10)
    ,dtenvioarquivo      VARCHAR2(10)
    ,dtvencimento        VARCHAR2(10)
  );
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_dados_param_consig IS TABLE OF typ_reg_dados_param_consig INDEX BY BINARY_INTEGER;


  PROCEDURE pc_busca_empr_consig_web(pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL --> Nome da empresa
                                    ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL --> Nome reduzido da empresa
                                    ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1   --> Codigo da empresa (-1 todas)
                                    ,pr_cddopcao IN VARCHAR2 DEFAULT 'C'               --> Opção da Tela C-Consultar, A-Alterar, H-Habilitar, D-Desabilitar
                                    ,pr_nriniseq IN INTEGER DEFAULT 0                  --> Paginação - Inicio de sequencia
                                    ,pr_nrregist IN INTEGER DEFAULT 0                  --> Paginação - Número de registros
                                    ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                     --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype                 --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2                          --> Erros do processo
                                    );

  PROCEDURE pc_busca_dados_empr_consig_car (
                                     pr_cdcooper IN crapemp.cdcooper%TYPE              --> Código da Cooperativa
                                    ,pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL --> Nome da empresa
                                    ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL --> Nome reduzido da empresa
                                    ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1   --> Codigo da empresa (-1 todas)
                                    ,pr_cddopcao IN VARCHAR2 DEFAULT 'C'               --> Opção da Tela C-Consultar, A-Alterar, H-Habilitar, D-Desabilitar
                                    ,pr_nriniseq IN INTEGER DEFAULT 0                  --> Paginação - Inicio de sequencia
                                    ,pr_nrregist IN INTEGER DEFAULT 0                  --> Paginação - Número de registros
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE              --> Nome da Tela
                                    ,pr_idorigem IN NUMBER                             --> Código de Origem
                                    ,pr_xmllog   IN VARCHAR2                           --> XML com informacoes de LOG
                                  --> OUT <--
                                    ,pr_clobxmlc   OUT CLOB                            --> Arquivo de retorno do XML
                                 ,pr_cdcritic OUT PLS_INTEGER                          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                             --> Descrição da crítica
                                 );

  PROCEDURE pc_alterar_empr_consig_web(pr_cdempres                IN tbcadast_empresa_consig.cdempres%TYPE             --> codigo da empresa.
                                      ,pr_indconsignado        IN tbcadast_empresa_consig.indconsignado%TYPE        --> indicador de convenio de desconto consignado em folha de pagamento esta habilitado. 0 - desabilitado / 1 - habilitado.
                                      ,pr_dtativconsignado     IN VARCHAR2                                          --> data de habilitacao do convenio de desconto consignado.
                                      ,pr_tpmodconvenio        IN tbcadast_empresa_consig.tpmodconvenio%TYPE        --> tipo de modalidade de convenio (1 - privado, 2 . publico e 3 - inss).
                                      ,pr_nrdialimiterepasse   IN tbcadast_empresa_consig.nrdialimiterepasse%TYPE   --> dia limite para repasse. (de 1 a 31).
                                      ,pr_indautrepassecc      IN tbcadast_empresa_consig.indautrepassecc%TYPE      --> autorizar debito repasse em c/c. (0 - não autorizado / 1 - autorizado)
                                      ,pr_indinterromper       IN tbcadast_empresa_consig.indinterromper%TYPE       --> indicador de interrupcao de cobranca. (0 - não interromper / 1 - interromper)
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
                                        ,pr_indautrepassecc      IN tbcadast_empresa_consig.indautrepassecc%TYPE      --> autorizar debito repasse em c/c. (0 - não autorizado / 1 - autorizado)
                                        ,pr_indinterromper       IN tbcadast_empresa_consig.indinterromper%TYPE       --> indicador de interrupcao de cobranca. (0 - não interromper / 1 - interromper)
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
  
  --Aterar/Inserir Parâmetros para Emprestimos Consignado por Empresa                                        
  PROCEDURE pc_inc_alt_param_consig_web( pr_idemprconsigparam  IN NUMBER   
                                        ,pr_cdempres           IN tbcadast_empresa_consig.cdempres%TYPE --> codigo da empresa
                                        ,pr_dtinclpropostade   IN VARCHAR2                              --> Data de inclusão da proposta De (DD/MM)
                                        ,pr_dtinclpropostaate  IN VARCHAR2                              --> Data de inclusão da proposta Até(DD/MM)
                                        ,pr_dtenvioarquivo     IN VARCHAR2                              --> Data do envio do arquivo (DD/MM)
                                        ,pr_dtvencimento       IN VARCHAR2                              --> Data do vencimento (DD/MM)
                                        -- campos padrões  
                                        ,pr_xmllog             IN VARCHAR2                              --> XML com informacoes de LOG
                                        ,pr_cdcritic          OUT PLS_INTEGER                           --> Codigo da critica
                                        ,pr_dscritic          OUT VARCHAR2                              --> Descricao da critica
                                        ,pr_retxml             IN OUT NOCOPY XMLType                    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo          OUT VARCHAR2                              --> Nome do campo com erro
                                        ,pr_des_erro          OUT VARCHAR2                              --> Erros do processo
                                        );
   
  --Excluir Parâmetros para Emprestimos Consignado por Empresa                                       
  PROCEDURE pc_excluir_param_consig_web( pr_idemprconsigparam   IN NUMBER   
                                        ,pr_cdempres            IN tbcadast_empresa_consig.cdempres%TYPE --> codigo da empresa
                                        -- campos padrões  
                                        ,pr_xmllog              IN VARCHAR2                              --> XML com informacoes de LOG
                                        ,pr_cdcritic           OUT PLS_INTEGER                           --> Codigo da critica
                                        ,pr_dscritic           OUT VARCHAR2                              --> Descricao da critica
                                        ,pr_retxml              IN OUT NOCOPY XMLType                    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo           OUT VARCHAR2                              --> Nome do campo com erro
                                        ,pr_des_erro           OUT VARCHAR2                              --> Erros do processo
                                        );  

                                         
  PROCEDURE pc_val_cooper_consignado_web( pr_cdcooper          IN NUMBER             --> codcooper
                                         -- campos padrões  
                                         ,pr_xmllog            IN VARCHAR2           --> XML com informacoes de LOG
                                         ,pr_cdcritic         OUT PLS_INTEGER        --> Codigo da critica
                                         ,pr_dscritic         OUT VARCHAR2           --> Descricao da critica
                                         ,pr_retxml            IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                         ,pr_nmdcampo         OUT VARCHAR2           --> Nome do campo com erro
                                         ,pr_des_erro         OUT VARCHAR2           --> Erros do processo
                                         ); 
                                         
  PROCEDURE pc_busca_param_consig_web(pr_cdempres           IN tbcadast_empresa_consig.cdempres%TYPE --> codigo da empresa-- campos padrões  
                                     ,pr_xmllog             IN VARCHAR2                              --> XML com informacoes de LOG
                                     ,pr_cdcritic          OUT PLS_INTEGER                           --> Codigo da critica
                                     ,pr_dscritic          OUT VARCHAR2                              --> Descricao da critica
                                     ,pr_retxml             IN OUT NOCOPY XMLType                    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo          OUT VARCHAR2                              --> Nome do campo com erro
                                     ,pr_des_erro          OUT VARCHAR2                              --> Erros do processo
                                     );   

  PROCEDURE pc_replicar_param_consig_web(pr_idemprconsigparam  IN NUMBER   
                                        ,pr_cdempres           IN tbcadast_empresa_consig.cdempres%TYPE --> codigo da empresa
                                        ,pr_dtinclpropostade   IN VARCHAR2                              --> Data de inclusão da proposta De (DD/MM)
                                        ,pr_dtinclpropostaate  IN VARCHAR2                              --> Data de inclusão da proposta Até(DD/MM)
                                        ,pr_dtenvioarquivo     IN VARCHAR2                              --> Data do envio do arquivo (DD/MM)
                                        ,pr_dtvencimento       IN VARCHAR2                              --> Data do vencimento (DD/MM)
                                         -- campos padrões  
                                        ,pr_xmllog             IN VARCHAR2                              --> XML com informacoes de LOG
                                        ,pr_cdcritic          OUT PLS_INTEGER                           --> Codigo da critica
                                        ,pr_dscritic          OUT VARCHAR2                              --> Descricao da critica
                                        ,pr_retxml             IN OUT NOCOPY XMLType                    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo          OUT VARCHAR2                              --> Nome do campo com erro
                                        ,pr_des_erro          OUT VARCHAR2                              --> Erros do processo
                                        );                                                                                                                                                              

  PROCEDURE pc_busca_dados_emp_fis (-- campos padrões  
                                    pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                   ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                   ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                   ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                   );                                                                                   
  
  PROCEDURE pc_validar_venctos_consig( pr_retxml      IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_cdcritic   OUT PLS_INTEGER        --> Codigo da critica
                                      ,pr_dscritic   OUT VARCHAR2           --> Descricao da critica
                                      ,pr_des_erro   OUT VARCHAR2           --> Erros do processo
                                      );

end TELA_CONSIG;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CONSIG IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_CONSIG
  --  Sistema  : Rotinas focando nas funcionalidades da tela CONSIG
  --  Sigla    : TELA
  --  Autor    : CIS Corporate
  --  Data     : Setembro/2018.                   Ultima atualizacao: 29/03/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  : Agrupar rotinas que venham a ser utilizadas pela tela CONSIG.
  --
  -- Alteração : 11/09/2018 Criação da package (CIS Corporate)
  --             
  -- Alteração : 26/03/2019 Criação das procedures:
  --                        - pc_validar_datas_consig_param
  --                        - pc_alt_empr_consig_param_web
  --                        - pc_inc_alt_param_consig
  --                        - pc_inc_alt_param_consig_web
  --                        - pc_excluir_param_consig_web
  --                        - pc_busca_param_consig
  --                        - pc_busca_param_consig_web
  --                        - pc_replicar_param_consig_web  (Fernanda Kelli - AMcom)
  --   
  --             29/03/2019 - Criação da rotina pc_busca_dados_emp_fis (Josiane Stiehler - AMcom)
  --
  --             04/04/2019 - Criação da rotina pc_validar_venctos_consig (Fernanda Kelli - AMcom)
  ---------------------------------------------------------------------------------------------------------------


  FUNCTION fn_convenio_empresa_consig(pr_cdcooper      IN crapemp.cdcooper%TYPE --> Código da Cooperativa
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

      Alteração : 11/09/2018 - Criação (CIS Corporate)

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

      Objetivo  : Valida se o dia informado está entre 1 e 31

      Alteração : 11/09/2018 - Criação (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/

    -- Variável de críticas
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
         pr_dscritic := 'Erro geral na rotina tela_consig.pc_validar_dia: '||SQLERRM;
  END pc_validar_dia;


  PROCEDURE pc_busca_empr_consig (pr_cdcooper IN crapemp.cdcooper%TYPE                 --> Código da Cooperativa
                                 ,pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL    --> Nome da empresa
                                 ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL    --> Nome reduzido da empresa
                                 ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1      --> Codigo da empresa (-1 todas)
                                 ,pr_cddopcao IN VARCHAR2 DEFAULT 'C'                  --> Opção da Tela C-Consultar, A-Alterar, H-Habilitar, D-Desabilitar
                                 ,pr_idorigem IN INTEGER                               --> Identificador Origem Chamada
                                 ,pr_nriniseq IN INTEGER DEFAULT 0                     --> Paginação - Inicio de sequencia
                                 ,pr_nrregist IN INTEGER DEFAULT 0                     --> Paginação - Número de registros
                                 --> OUT <--
                                 ,pr_qtregist OUT integer                              --> Quantidade de registros encontrados
                                 ,pr_tab_dados_emp_consig OUT typ_tab_dados_emp_consig --> Tabela de retorno
                                 ,pr_cdcritic OUT PLS_INTEGER                          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                             --> Descrição da crítica
                                 ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_busca_empr_consig
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Busca os dados da empresa para consignado

      Alteração : 11/09/2018 - Criação (CIS Corporate)

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
                 WHEN pr_cdempres is null THEN
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
             END = 1
         ORDER BY nmextemp;

      rw_empr_consig cr_empr_consig%ROWTYPE;

      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
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
            vr_dscritic := 'Empresa não habilitada para Consignado. Para habilitar utilize a opção H';
            RAISE vr_exc_erro;
          END IF;
        ELSIF pr_cddopcao = 'H' THEN
          IF fn_convenio_empresa_consig(pr_cdcooper      => pr_cdcooper
                                       ,pr_cdempres      => pr_cdempres
                                       ,pr_indconsignado => 1) THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Empresa já habilitada para Consignado. Para alterações, utilize a opção A';
            RAISE vr_exc_erro;
          END IF;
        ELSIF pr_cddopcao = 'D' THEN
          IF NOT(fn_convenio_empresa_consig(pr_cdcooper      => pr_cdcooper
                                           ,pr_cdempres      => pr_cdempres
                                           ,pr_indconsignado => 1)) THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Empresa não habilitada para Consignado, não é necessario desabilitar';
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF;

      -- Se encontrou por Código ou por Nome Fantasia ou por Razão Social, preencher a tab de retorno.
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
          /* busca a descriçao da crítica baseado no código */
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na tela_consig.pc_busca_empr_consig '||sqlerrm;
        pr_cdcritic := 0;
    END;
  END pc_busca_empr_consig;

  PROCEDURE pc_busca_empr_consig_web(pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL --> Nome da empresa
                                    ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL --> Nome reduzido da empresa
                                    ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1   --> Codigo da empresa (-1 todas)
                                    ,pr_cddopcao IN VARCHAR2 DEFAULT 'C'               --> Opção da Tela C-Consultar, A-Alterar, H-Habilitar, D-Desabilitar
                                    ,pr_nriniseq IN INTEGER DEFAULT 0                  --> Paginação - Inicio de sequencia
                                    ,pr_nrregist IN INTEGER DEFAULT 0                  --> Paginação - Número de registros
                                    ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                     --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
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

      Alteração : 11/09/2018 - Criação (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
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

      -- variáveis para armazenar as informaçoes em xml
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
      -- inicilizar as informaçoes do xml
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

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_erro THEN
           /*  se foi retornado apenas código */
           IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
               /* buscar a descriçao */
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
           /* montar descriçao de erro nao tratado */
             pr_dscritic := 'erro não tratado na empr0013.pc_obtem_dados_consignado_web ' ||SQLERRM;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_empr_consig_web;

  PROCEDURE pc_busca_dados_empr_consig_car (
                                     pr_cdcooper IN crapemp.cdcooper%TYPE                  -- Código da Cooperativa
                                    ,pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL --> Nome da empresa
                                    ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL --> Nome reduzido da empresa
                                    ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1   --> Codigo da empresa (-1 todas)
                                    ,pr_cddopcao IN VARCHAR2 DEFAULT 'C'               --> Opção da Tela C-Consultar, A-Alterar, H-Habilitar, D-Desabilitar
                                    ,pr_nriniseq IN INTEGER DEFAULT 0                  --> Paginação - Inicio de sequencia
                                    ,pr_nrregist IN INTEGER DEFAULT 0                  --> Paginação - Número de registros
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                    ,pr_idorigem IN NUMBER   -- Código de Origem
                                    ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                  --> OUT <--
                                 ,pr_clobxmlc   OUT CLOB                           -- Arquivo de retorno do XML
                                 ,pr_cdcritic OUT PLS_INTEGER                          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                             --> Descrição da crítica
                                 ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_busca_dados_empr_consig_car
      Sistema  : Ayllos
      Sigla    : CONSIG
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Retornar os dados de consignado para uma determinada empresa.

      Alteração : 11/09/2018 - Criação (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/
BEGIN
  DECLARE
    -- Variável de críticas
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
    -- Criar cabeçalho do XML
    dbms_lob.createtemporary(pr_clobxmlc, TRUE);
    dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML
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
      pr_cdcritic := null; -- não será utilizado
      pr_dscritic := 'Erro geral em pc_busca_dados_empr_consig_car: '||SQLERRM;

  END;
  END pc_busca_dados_empr_consig_car;


  PROCEDURE pc_alterar_empr_consig(pr_cdcooper             IN crapcop.cdcooper%TYPE                             --> Código da Cooperativa
                                  ,pr_cdempres                IN tbcadast_empresa_consig.cdempres%TYPE             --> codigo da empresa.
                                  ,pr_indconsignado        IN tbcadast_empresa_consig.indconsignado%TYPE        --> indicador de convenio de desconto consignado em folha de pagamento esta habilitado. 0 - desabilitado / 1 - habilitado.
                                  ,pr_dtativconsignado     IN tbcadast_empresa_consig.dtativconsignado%TYPE     --> data de habilitacao do convenio de desconto consignado.
                                  ,pr_tpmodconvenio        IN tbcadast_empresa_consig.tpmodconvenio%TYPE        --> tipo de modalidade de convenio (1 - privado, 2 . publico e 3 - inss).
                                  ,pr_nrdialimiterepasse   IN tbcadast_empresa_consig.nrdialimiterepasse%TYPE   --> dia limite para repasse. (de 1 a 31).
                                  ,pr_indautrepassecc      IN tbcadast_empresa_consig.indautrepassecc%TYPE      --> autorizar debito repasse em c/c. (0 - não autorizado / 1 - autorizado)
                                  ,pr_indinterromper       IN tbcadast_empresa_consig.indinterromper%TYPE       --> indicador de interrupcao de cobranca. (0 - não interromper / 1 - interromper)
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

      Objetivo  : Alterar as informações do convênio do Consignado

      Alteração : 11/09/2018 - Criação (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/

    -- Variável de críticas
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

    -- Caso ocorra alteração do Dia Fechamento Folha na tela CONSIG, esta deve ser refletida na tela CADEMP.
    UPDATE crapemp emp
       SET dtfchfol = nvl(pr_dtfchfol, dtfchfol)
     WHERE emp.cdempres = pr_cdempres
       AND emp.cdcooper = pr_cdcooper;

    pr_dsmensag := 'Convênio de consignado atualizado com sucesso.';

  EXCEPTION
    WHEN vr_exc_erro then
         IF  vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'Erro geral na rotina tela_consig.pc_alterar_empr_consig: '||SQLERRM;
  END pc_alterar_empr_consig;

  PROCEDURE pc_alterar_empr_consig_web(pr_cdempres                IN tbcadast_empresa_consig.cdempres%TYPE             --> codigo da empresa.
                                      ,pr_indconsignado        IN tbcadast_empresa_consig.indconsignado%TYPE        --> indicador de convenio de desconto consignado em folha de pagamento esta habilitado. 0 - desabilitado / 1 - habilitado.
                                      ,pr_dtativconsignado     IN VARCHAR2                                          --> data de habilitacao do convenio de desconto consignado.
                                      ,pr_tpmodconvenio        IN tbcadast_empresa_consig.tpmodconvenio%TYPE        --> tipo de modalidade de convenio (1 - privado, 2 . publico e 3 - inss).
                                      ,pr_nrdialimiterepasse   IN tbcadast_empresa_consig.nrdialimiterepasse%TYPE   --> dia limite para repasse. (de 1 a 31).
                                      ,pr_indautrepassecc      IN tbcadast_empresa_consig.indautrepassecc%TYPE      --> autorizar debito repasse em c/c. (0 - não autorizado / 1 - autorizado)
                                      ,pr_indinterromper       IN tbcadast_empresa_consig.indinterromper%TYPE       --> indicador de interrupcao de cobranca. (0 - não interromper / 1 - interromper)
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

      Objetivo  : Alterar as informações do convênio do Consignado

      Alteração : 11/09/2018 - Criação (CIS Corporate)

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
         pr_dscritic := 'Erro geral na rotina tela_consig.pc_alterar_empr_consig_web: '||SQLERRM;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;
  END pc_alterar_empr_consig_web;


  PROCEDURE pc_habilitar_empr_consig(pr_cdcooper             IN crapcop.cdcooper%TYPE                             --> Código da Cooperativa
                                    ,pr_cdempres                IN tbcadast_empresa_consig.cdempres%TYPE             --> codigo da empresa.
                                    ,pr_indconsignado        IN tbcadast_empresa_consig.indconsignado%TYPE        --> indicador de convenio de desconto consignado em folha de pagamento esta habilitado. 0 - desabilitado / 1 - habilitado.
                                    ,pr_dtativconsignado     IN tbcadast_empresa_consig.dtativconsignado%TYPE     --> data de habilitacao do convenio de desconto consignado.
                                    ,pr_tpmodconvenio        IN tbcadast_empresa_consig.tpmodconvenio%TYPE        --> tipo de modalidade de convenio (1 - privado, 2 . publico e 3 - inss).
                                    ,pr_nrdialimiterepasse   IN tbcadast_empresa_consig.nrdialimiterepasse%TYPE   --> dia limite para repasse. (de 1 a 31).
                                    ,pr_indautrepassecc      IN tbcadast_empresa_consig.indautrepassecc%TYPE      --> autorizar debito repasse em c/c. (0 - não autorizado / 1 - autorizado)
                                    ,pr_indinterromper       IN tbcadast_empresa_consig.indinterromper%TYPE       --> indicador de interrupcao de cobranca. (0 - não interromper / 1 - interromper)
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

      Objetivo  : Habilitar o convênio de consignado para uma empresa

      Alteração : 11/09/2018 - Criação (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/

    -- Variável de críticas
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

    -- Verifica se já existe um convenio de consignado cadastrado, se existir somente habilitar o mesmo, caso contrátio inserir um novo
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

      pr_dsmensag := 'Convênio de consignado habilitado com sucesso.';

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

      pr_dsmensag := 'Convênio de consignado criado com sucesso.';
    END IF;

    -- Caso ocorra alteração do Dia Fechamento Folha na tela CONSIG, esta deve ser refletida na tela CADEMP.
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
         pr_dscritic := 'Erro geral na rotina tela_consig.pc_habilitar_empr_consig: '||SQLERRM;
  END pc_habilitar_empr_consig;


  PROCEDURE pc_habilitar_empr_consig_web(pr_cdempres                IN tbcadast_empresa_consig.cdempres%TYPE             --> codigo da empresa.
                                        ,pr_indconsignado        IN tbcadast_empresa_consig.indconsignado%TYPE        --> indicador de convenio de desconto consignado em folha de pagamento esta habilitado. 0 - desabilitado / 1 - habilitado.
                                        ,pr_dtativconsignado     IN VARCHAR2                                          --> data de habilitacao do convenio de desconto consignado.
                                        ,pr_tpmodconvenio        IN tbcadast_empresa_consig.tpmodconvenio%TYPE        --> tipo de modalidade de convenio (1 - privado, 2 . publico e 3 - inss).
                                        ,pr_nrdialimiterepasse   IN tbcadast_empresa_consig.nrdialimiterepasse%TYPE   --> dia limite para repasse. (de 1 a 31).
                                        ,pr_indautrepassecc      IN tbcadast_empresa_consig.indautrepassecc%TYPE      --> autorizar debito repasse em c/c. (0 - não autorizado / 1 - autorizado)
                                        ,pr_indinterromper       IN tbcadast_empresa_consig.indinterromper%TYPE       --> indicador de interrupcao de cobranca. (0 - não interromper / 1 - interromper)
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

      Objetivo  : Habilitar o convênio de emprestimo de consignado

      Alteração : 11/09/2018 - Criação (CIS Corporate)

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
         pr_dscritic := 'Erro geral na rotina tela_consig.pc_habilitar_empr_consig_web: '||SQLERRM;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;
  END pc_habilitar_empr_consig_web;


  PROCEDURE pc_desabilitar_empr_consig(pr_cdcooper  IN crapcop.cdcooper%TYPE                 --> Código da Cooperativa
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

      Objetivo  : Desabilitar um convênio de emprestimo de consignado

      Alteração : 11/09/2018 - Criação (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/

    -- Variável de críticas
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

    pr_dsmensag := 'Convênio de consignado desabilitado com sucesso.';

  EXCEPTION
    WHEN vr_exc_erro then
         IF  vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'Erro geral na rotina tela_consig.pc_desabilitar_empr_consig: '||SQLERRM;
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

      Objetivo  : Desabilitar o convênio de emprestimo de consignado

      Alteração : 11/09/2018 - Criação (CIS Corporate)

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
         pr_dscritic := 'Erro geral na rotina tela_consig.pc_desabilitar_empr_consig_web: '||SQLERRM;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;
  END pc_desabilitar_empr_consig_web;

  PROCEDURE pc_validar_datas_consig_param(pr_cdempres   IN NUMBER
                                         ,pr_dscritic  OUT VARCHAR2   --> Descricao da critica
                                          ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_validar_datas_consig_param
      Sistema  : Aimaro
      Sigla    : CONSIG
      Autor    : Fernanda Kelli - AMcom
      Data     : 26/03/2019

      Objetivo : Verificar se falta algum dia do ano cadastrado nos parametros

      Alteração : 

    ----------------------------------------------------------------------------------------------------------*/

    -- Variável de críticas
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    
    vr_nrdia number := 0;
    vr_nrmes number := 0;

  BEGIN
    null;
 /* select trunc(pr_dtmmdd,'MM')
        ,last_day(pr_dtmmdd)
    from dual;*/
        
   -- vr_nrdia := to_char(pr_dtmmdd,'DD');
   -- vr_nrmes := to_char(pr_dtmmdd,'MM');
    
    /*IF nvl(pr_nrdia,0) <> 0 THEN
      IF NOT(pr_nrdia BETWEEN 1 AND 31) THEN
        vr_dscritic := 'O dia informado deve estar entre o intervalo de 1 a 31';
        RAISE vr_exc_erro;
      END IF;
    END IF;*/
    
  EXCEPTION
    WHEN vr_exc_erro then
         pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
         pr_dscritic := 'Erro geral na rotina tela_consig.pc_validar_datas_consig_param: '||SQLERRM;
  END pc_validar_datas_consig_param;
  
  PROCEDURE pc_inc_alt_param_consig( pr_cdcooper              IN NUMBER
                                    ,pr_cdempres              IN NUMBER  
                                    ,pr_cdoperad              IN VARCHAR2
                                    ,pr_idemprconsigparam     IN NUMBER
                                    ,pr_dtinclpropostade      IN VARCHAR2
                                    ,pr_dtinclpropostaate     IN VARCHAR2
                                    ,pr_dtenvioarquivo        IN VARCHAR2
                                    ,pr_dtvencimento          IN VARCHAR2
                                    ,pr_dsmensag             OUT VARCHAR2       --> Mensagem                                   --> Mensagem
                                    ,pr_cdcritic             OUT PLS_INTEGER    --> Codigo da critica                                    --> Codigo da critica
                                    ,pr_dscritic             OUT VARCHAR2       --> Descricao da critica                                      --> Descricao da critica
                                    ) IS
                                    
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_alt_empr_consig_param_web
      Sistema  : AIMARO
      Sigla    : CONSIG
      Autor    : Fernanda Kelli - AMcom
      Data     : 04/03/2019

      Objetivo : Alterar as informações do convênio do Consignado referente a
                 data de corte do vencimento da parcela, em relação à data de inclusão da proposta.

      Alteração : 

    ----------------------------------------------------------------------------------------------------------*/
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    
    vr_dtinclpropostade   DATE;
    vr_dtinclpropostaate  DATE;
    vr_dtenvioarquivo     DATE;
    vr_dtvencimento       DATE;
    vr_dtfchfol           crapemp.dtfchfol%type;
    vr_diaenvioarquivo    NUMBER;
    vr_idemprconsig       tbcadast_empresa_consig.idemprconsig%type; 
    
    vr_idemprconsigparam  NUMBER;
    
    cursor cr_param_consig(pr_idemprconsigparam in number) is
      select to_char(t.dtinclpropostade,'DD/MM') dtinclpropostade
            ,to_char(t.dtinclpropostaate,'DD/MM') dtinclpropostaate
            ,to_char(t.dtenvioarquivo,'DD/MM') dtenvioarquivo
            ,to_char(t.dtvencimento,'DD/MM') dtvencimento 
        from cecred.tbcadast_emp_consig_param  t
       where t.idemprconsigparam = pr_idemprconsigparam;
       
     rw_param_consig cr_param_consig%ROWTYPE; 
                          
  BEGIN
    
    pr_dsmensag := NULL;
    
    --Converter para data para verificar se tem alguma data inválida
    BEGIN
      vr_dtinclpropostade  := to_date(pr_dtinclpropostade||'/2999', 'DD/MM/RRRR');
      vr_dtinclpropostaate := to_date(pr_dtinclpropostaate||'/2999','DD/MM/RRRR');
      vr_dtenvioarquivo    := to_date(pr_dtenvioarquivo||'/2999',   'DD/MM/RRRR');
      vr_diaenvioarquivo   := substr(pr_dtenvioarquivo,0,2) ;                            
      vr_dtvencimento      := to_date(pr_dtvencimento||'/2999',     'DD/MM/RRRR');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Data invalida, deve ser utilizado o formato (DD/MM).';
        RAISE vr_exc_erro;
    END;
    
    --Regra: A data do campo envio do arquivo deverá ser igual ou maior que a data do campo até; 
    IF vr_dtenvioarquivo < vr_dtinclpropostaate THEN
      vr_dscritic := 'Data do envio do arquivo deve ser igual ou maior que a Data de inclusao da proposta Ate .  '|| sqlerrm;
      RAISE vr_exc_erro; 
    END IF;
    
    --Buscar a Dia de Fechamento da Folha
    SELECT p.dtfchfol
      INTO vr_dtfchfol
      FROM cecred.crapemp p
          ,cecred.tbcadast_empresa_consig tec
     WHERE tec.cdcooper = p.cdcooper
       AND tec.cdempres = p.cdempres
       AND tec.cdcooper = pr_cdcooper
       AND tec.cdempres = pr_cdempres;
    
    --Regra: O dia do envio do arquivo deverá ser igual ou menor que a da data cadastrada no campo “Dia fechamento folha”; 
    IF vr_diaenvioarquivo > vr_dtfchfol THEN
      vr_dscritic := 'Data do envio do arquivo deve ser igual ou menor a Data de fechamento da folha.  '|| sqlerrm;
      RAISE vr_exc_erro; 
    END IF;
    
    --Se for uma atualização
    IF nvl(pr_idemprconsigparam,0) > 0 THEN
      
      --recuperar os dados para fazer o log - OLD
      OPEN cr_param_consig(pr_idemprconsigparam);
      FETCH cr_param_consig INTO rw_param_consig;
      CLOSE cr_param_consig;
            
      UPDATE cecred.tbcadast_emp_consig_param consig_param
         SET consig_param.dtinclpropostade  = nvl(vr_dtinclpropostade, dtinclpropostade)
            ,consig_param.dtinclpropostaate = nvl(vr_dtinclpropostaate, dtinclpropostaate)
            ,consig_param.dtenvioarquivo    = nvl(vr_dtenvioarquivo, dtenvioarquivo)
            ,consig_param.dtvencimento      = nvl(vr_dtvencimento, dtvencimento)         
       WHERE consig_param.idemprconsigparam = pr_idemprconsigparam;
       
       vr_idemprconsigparam := pr_idemprconsigparam;
       
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 --  erro nao tratado 
                                ,pr_nmarqlog     => 'tela_consig.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| pr_cdoperad || ' - ' || 
                                                    'Alterou parametro do Emprestimo Consignado. ' || 
                                                    ' DtInclPropostaDe: OLD - '  ||rw_param_consig.dtinclpropostade  || ' NEW - '|| pr_dtinclpropostade  ||
                                                    ' DtInclPropostaAte: OLD -  '||rw_param_consig.Dtinclpropostaate || ' NEW - '|| pr_dtinclpropostaate ||
                                                    ' DtEnvioArquivo: OLD - '    ||rw_param_consig.Dtenvioarquivo    || ' NEW - '|| pr_dtenvioarquivo ||
                                                    ' DtVencimento: OLD - '      ||rw_param_consig.dtvencimento      || ' NEW - '|| pr_dtvencimento   ||'.');
                                                    
    --Se for para inserir          
    ELSE
      
      SELECT idemprconsig
        INTO vr_idemprconsig 
        FROM tbcadast_empresa_consig
       WHERE cdcooper = pr_cdcooper
         AND cdempres = pr_cdempres;      
      
      INSERT INTO tbcadast_emp_consig_param t
        (idemprconsig
        ,dtinclpropostade
        ,dtinclpropostaate 
        ,dtenvioarquivo 
        ,dtvencimento)
      VALUES
        (vr_idemprconsig
        ,vr_dtinclpropostade
        ,vr_dtinclpropostaate
        ,vr_dtenvioarquivo
        ,vr_dtvencimento)
        
        RETURNING idemprconsigparam
             INTO vr_idemprconsigparam; 
             
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 --  erro nao tratado 
                                ,pr_nmarqlog     => 'tela_consig.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| pr_cdoperad || ' - ' || 
                                                    'Inseriu parametro do Emprestimo Consignado. ' || 
                                                    ' DtInclPropostaDe: '  || pr_dtinclpropostade ||
                                                    ' DtInclPropostaAte: ' || pr_dtinclpropostaate ||
                                                    ' DtEnvioArquivo: '    || pr_dtenvioarquivo ||
                                                    ' DtVencimento: '      || pr_dtvencimento   ||'.');
                              
    END IF;
    
    pr_dsmensag := coalesce(vr_idemprconsigparam,0);

  EXCEPTION
    WHEN vr_exc_erro then
         IF  vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'Erro geral na rotina tela_consig.pc_alt_empr_consig_param: '||SQLERRM;
  END pc_inc_alt_param_consig;

  PROCEDURE pc_inc_alt_param_consig_web(pr_idemprconsigparam  IN NUMBER   
                                       ,pr_cdempres           IN tbcadast_empresa_consig.cdempres%TYPE --> codigo da empresa
                                       ,pr_dtinclpropostade   IN VARCHAR2 --Data de inclusão da proposta De (DD/MM)
                                       ,pr_dtinclpropostaate  IN VARCHAR2 --Data de inclusão da proposta Até(DD/MM)
                                       ,pr_dtenvioarquivo     IN VARCHAR2 --Data do envio do arquivo (DD/MM)
                                       ,pr_dtvencimento       IN VARCHAR2 --Data do vencimento (DD/MM)
                                       -- campos padrões  
                                       ,pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                       ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                       ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                       ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                       ) IS
  
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_alt_empr_consig_param_web
      Sistema  : AIMARO
      Sigla    : CONSIG
      Autor    : Fernanda Kelli - AMcom Sistemas de Informação
      Data     : 04/03/2019

      Objetivo : Alterar as informações do convênio do Consignado referente a
                 data de corte do vencimento da parcela, em relação à data de inclusão da proposta.

      Alteração : 

    ----------------------------------------------------------------------------------------------------------*/
    vr_dsmensag           VARCHAR2(4000);
    
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
  
    -- Extrai os dados vindos do XML pr_retxml na tabela 
    pr_des_erro := 'OK';
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper    --OUT
                            ,pr_nmdatela => vr_nmdatela    --OUT
                            ,pr_nmeacao  => vr_nmeacao     --OUT 
                            ,pr_cdagenci => vr_cdagenci    --OUT
                            ,pr_nrdcaixa => vr_nrdcaixa    --OUT
                            ,pr_idorigem => vr_idorigem    --OUT 
                            ,pr_cdoperad => vr_cdoperad    --OUT
                            ,pr_dscritic => vr_dscritic);
    IF  TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;
    
    --Inserir ou Alterar os Parâmetros para Emprestimos Consignado por Empresa   
    pc_inc_alt_param_consig(pr_cdcooper            => vr_cdcooper
                            ,pr_cdempres           => pr_cdempres
                            ,pr_cdoperad           => vr_cdoperad
                            ,pr_idemprconsigparam  => pr_idemprconsigparam                             
                            ,pr_dtinclpropostade   => pr_dtinclpropostade
                            ,pr_dtinclpropostaate  => pr_dtinclpropostaate
                            ,pr_dtenvioarquivo     => pr_dtenvioarquivo
                            ,pr_dtvencimento       => pr_dtvencimento
                            ,pr_dsmensag           => vr_dsmensag    --> Mensagem  
                            ,pr_cdcritic           => vr_cdcritic    --> Codigo da critica
                            ,pr_dscritic           => vr_dscritic ); --> Descricao da critica

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
         pr_dscritic := 'Erro geral na rotina tela_consig.pc_inc_alt_param_consig_web: '||SQLERRM;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;                                         
  END pc_inc_alt_param_consig_web;      
                       
  PROCEDURE pc_excluir_param_consig_web(pr_idemprconsigparam  IN NUMBER   --??? DEPOIS QUE A TABELA FOR CRIADA, SUBSTITUIR PELO CAMPO DA TABELA
                                       ,pr_cdempres     IN tbcadast_empresa_consig.cdempres%TYPE --> codigo da empresa
                                       -- campos padrões  
                                       ,pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                       ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                       ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                       ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                       )IS
   /*---------------------------------------------------------------------------------------------------------
      Programa : pc_busca_param_consig_web
      Sistema  : AIMARO
      Sigla    : CONSIG
      Autor    : Fernanda Kelli - AMcom Sistemas de Informação
      Data     : 05/03/2019

      Objetivo : Buscar as informações da tabela para retorna ao PHP.

      Alteração : 

    ----------------------------------------------------------------------------------------------------------*/
                                            
    vr_dsmensag           VARCHAR2(4000);
    
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
    
    cursor cr_param_consig(pr_idemprconsigparam in number) is
      select to_char(t.dtinclpropostade,'DD/MM') dtinclpropostade
            ,to_char(t.dtinclpropostaate,'DD/MM') dtinclpropostaate
            ,to_char(t.dtenvioarquivo,'DD/MM') dtenvioarquivo
            ,to_char(t.dtvencimento,'DD/MM') dtvencimento 
        from cecred.tbcadast_emp_consig_param  t
       where t.idemprconsigparam = pr_idemprconsigparam;
       
     rw_param_consig cr_param_consig%ROWTYPE;  
    
  BEGIN
  
    -- Extrai os dados vindos do XML pr_retxml na tabela 
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper    --OUT
                            ,pr_nmdatela => vr_nmdatela    --OUT
                            ,pr_nmeacao  => vr_nmeacao     --OUT 
                            ,pr_cdagenci => vr_cdagenci    --OUT
                            ,pr_nrdcaixa => vr_nrdcaixa    --OUT
                            ,pr_idorigem => vr_idorigem    --OUT 
                            ,pr_cdoperad => vr_cdoperad    --OUT
                            ,pr_dscritic => vr_dscritic);
    IF  TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;
    
    --recuperar os dados para fazer o log
    OPEN cr_param_consig(pr_idemprconsigparam);
    FETCH cr_param_consig INTO rw_param_consig;
    IF cr_param_consig%NOTFOUND THEN 
      CLOSE cr_param_consig;
    ELSE
      --Excluir os Parâmetros para Emprestimos Consignado por Empresa   
      BEGIN
        DELETE tbcadast_emp_consig_param
         WHERE idemprconsigparam = pr_idemprconsigparam;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao tentar excluir os parametros do Emprestimo Consignado.';
          RAISE vr_exc_erro;
      END; 
      
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 --  erro nao tratado 
                                ,pr_nmarqlog     => 'tela_consig.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    ' Excluiu parametro do Emprestimo Consignado. ' || 
                                                    ' DtInclPropostaDe: '  || rw_param_consig.dtinclpropostade ||
                                                    ' DtInclPropostaAte: ' || rw_param_consig.dtinclpropostaate ||
                                                    ' DtEnvioArquivo: '    || rw_param_consig.dtenvioarquivo ||
                                                    ' DtVencimento: '      || rw_param_consig.dtvencimento ||'.');
      
      CLOSE cr_param_consig; 
    END IF;
      
    pr_des_erro := 'OK';
    
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><dsmensag>'||vr_dsmensag||'</dsmensag></Root>');

    --Efetua commit das alterações       
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
         pr_dscritic := 'Erro geral na rotina tela_consig.pc_excluir_param_consig_web: '||SQLERRM;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK; 
  END pc_excluir_param_consig_web;
  
  PROCEDURE pc_val_cooper_consignado_web( pr_cdcooper  IN NUMBER   -- codcooper
                                         -- campos padrões  
                                         ,pr_xmllog           IN VARCHAR2              --> XML com informacoes de LOG
                                         ,pr_cdcritic        OUT PLS_INTEGER           --> Codigo da critica
                                         ,pr_dscritic        OUT VARCHAR2              --> Descricao da critica
                                         ,pr_retxml           IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo        OUT VARCHAR2              --> Nome do campo com erro
                                         ,pr_des_erro        OUT VARCHAR2              --> Erros do processo
                                         ) is
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    V_RET  crapprm.dsvlrprm%TYPE;
    
    -- Variaveis de dados vindos do XML pr_retxml
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;    
    
  BEGIN
    pr_nmdcampo := NULL;
    pr_des_erro := 'OK';
    
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

    
    gene0001.pc_param_sistema(pr_nmsistem => 'CRED'
                            ,pr_cdcooper  => pr_cdcooper 
                            ,pr_cdacesso  => 'COOPER_CONSIGNADO'
                            ,pr_dsvlrprm => V_RET);
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><dsmensag>'||V_RET||'</dsmensag></Root>');
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
    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina TELA_CONSIG.pc_val_cooper_consignado_web: '||SQLERRM;
      pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
  END; 
  
  PROCEDURE pc_busca_param_consig(pr_cdcooper               IN crapemp.cdcooper%TYPE                 --> Código da Cooperativa
                                 ,pr_cdempres               IN tbcadast_empresa_consig.cdempres%TYPE --> Codigo da empresa 
                                  --> OUT <--
                                 ,pr_qtregist               OUT integer                              --> Quantidade de registros encontrados
                                 ,pr_tab_dados_param_consig OUT typ_tab_dados_param_consig           --> Tabela de retorno
                                 ,pr_cdcritic               OUT PLS_INTEGER                          --> Código da crítica
                                 ,pr_dscritic               OUT VARCHAR2                             --> Descrição da crítica
                                 ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_busca_param_consig
      Sistema  : Aimaro
      Sigla    : CONSIG
      Autor    : Fernanda Kelli - AMcom Sistemas de Informação
      Data     : 06/03/2019

      Objetivo  : Buscar os Dados da 'Parâmetros para Emprestimos Consignado por Empresa' para retorna ao PHP.

      Alteração : 

    ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      CURSOR cr_param_consig IS
        SELECT idemprconsigparam,
               to_char(dtinclpropostade,'DD/MM')  dtinclpropostade,
               to_char(dtinclpropostaate,'DD/MM') dtinclpropostaate,
               to_char(dtenvioarquivo,'DD/MM')    dtenvioarquivo,
               to_char(dtvencimento,'DD/MM')      dtvencimento
          FROM cecred.tbcadast_emp_consig_param
         WHERE idemprconsig = ( SELECT idemprconsig
                                  FROM cecred.tbcadast_empresa_consig
                                 WHERE cdcooper = pr_cdcooper
                                   AND cdempres = pr_cdempres
                                );

      rw_param_consig cr_param_consig%ROWTYPE;

      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      vr_idtab number;
    BEGIN

      OPEN cr_param_consig;
      LOOP
        FETCH cr_param_consig INTO rw_param_consig;
        EXIT WHEN cr_param_consig%NOTFOUND;

        vr_idtab := pr_tab_dados_param_consig.count + 1;
       
        pr_tab_dados_param_consig(vr_idtab).idemprconsigparam    := rw_param_consig.idemprconsigparam;
        pr_tab_dados_param_consig(vr_idtab).cdempres             := pr_cdempres;
        pr_tab_dados_param_consig(vr_idtab).dtinclpropostade     := rw_param_consig.dtinclpropostade;
        pr_tab_dados_param_consig(vr_idtab).dtinclpropostaate    := rw_param_consig.dtinclpropostaate;
        pr_tab_dados_param_consig(vr_idtab).dtenvioarquivo       := rw_param_consig.dtenvioarquivo;
        pr_tab_dados_param_consig(vr_idtab).dtvencimento         := rw_param_consig.dtvencimento;
        
        pr_qtregist := nvl(pr_qtregist,0) + 1;
      END LOOP;
      CLOSE cr_param_consig;
    EXCEPTION
      WHEN vr_exc_erro THEN
        /* busca valores de critica predefinidos */
        IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
          /* busca a descriçao da crítica baseado no código */
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na tela_consig.pc_busca_param_consig '||sqlerrm;
        pr_cdcritic := 0;
    END;
  END pc_busca_param_consig;

  PROCEDURE pc_busca_param_consig_web(pr_cdempres           IN tbcadast_empresa_consig.cdempres%TYPE --> codigo da empresa
                                     -- campos padrões  
                                     ,pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                     ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                     ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                     ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                     ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                     ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_busca_param_consig_web
      Sistema  : AIMARO
      Sigla    : CONSIG
      Autor    : Fernanda Kelli - AMcom Sistemas de Informação
      Data     : 05/03/2019

      Objetivo : Buscar os Dados da 'Parâmetros para Emprestimos Consignado por Empresa' para retorna ao PHP.

      Alteração : 

    ----------------------------------------------------------------------------------------------------------*/
    BEGIN
    DECLARE
      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- variaveis de retorno
      vr_tab_dados_param_consig typ_tab_dados_param_consig;
      vr_qtregist         number;

      -- variaveis de entrada vindas no xml
      vr_cdcooper integer;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);

      -- variáveis para armazenar as informaçoes em xml
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

      tela_consig.pc_busca_param_consig( pr_cdcooper               => vr_cdcooper
                                                    ,pr_cdempres               => pr_cdempres
                                                     --> OUT <--
                                                    ,pr_qtregist               => vr_qtregist
                                                    ,pr_tab_dados_param_consig => vr_tab_dados_param_consig
                                                    ,pr_cdcritic               => vr_cdcritic
                                                    ,pr_dscritic               => vr_dscritic);                                 

      IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
          raise vr_exc_erro;
      END IF;

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="' || vr_qtregist ||'" >');

      -- ler os registros do consignado e incluir no xml
      vr_index := vr_tab_dados_param_consig.first;
      while vr_index is not null loop
            pc_escreve_xml('<inf>'||
                             '<idemprconsigparam>'||    vr_tab_dados_param_consig(vr_index).idemprconsigparam    ||'</idemprconsigparam>'||
                             '<dtinclpropostade>'||     vr_tab_dados_param_consig(vr_index).dtinclpropostade     ||'</dtinclpropostade>'||
                             '<dtinclpropostaate>'||    vr_tab_dados_param_consig(vr_index).dtinclpropostaate    ||'</dtinclpropostaate>'||
                             '<dtenvioarquivo>'||       vr_tab_dados_param_consig(vr_index).dtenvioarquivo       ||'</dtenvioarquivo>'||
                             '<dtvencimento>'||         vr_tab_dados_param_consig(vr_index).dtvencimento         ||'</dtvencimento>'||
                           '</inf>');
          /* buscar proximo */
          vr_index := vr_tab_dados_param_consig.next(vr_index);
      end loop;
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_erro THEN
           /*  se foi retornado apenas código */
           IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
               /* buscar a descriçao */
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
           /* montar descriçao de erro nao tratado */
             pr_dscritic := 'erro não tratado na tela_consig.pc_busca_param_consig_web ' ||SQLERRM;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_param_consig_web;
  
  PROCEDURE pc_replicar_param_consig_web(pr_idemprconsigparam  IN NUMBER   
                                        ,pr_cdempres           IN tbcadast_empresa_consig.cdempres%TYPE --> codigo da empresa
                                        ,pr_dtinclpropostade   IN VARCHAR2 --Data de inclusão da proposta De (DD/MM)
                                        ,pr_dtinclpropostaate  IN VARCHAR2 --Data de inclusão da proposta Até(DD/MM)
                                        ,pr_dtenvioarquivo     IN VARCHAR2 --Data do envio do arquivo (DD/MM)
                                        ,pr_dtvencimento       IN VARCHAR2 --Data do vencimento (DD/MM)
                                         -- campos padrões  
                                        ,pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                        ) IS
  
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_replicar_param_consig_web
      Sistema  : AIMARO
      Sigla    : CONSIG
      Autor    : Fernanda Kelli - AMcom Sistemas de Informação
      Data     : 07/03/2019

      Objetivo : Depois da inclusão do primeiro registro referente a parâmetrização da inclusão da Proposta 
                 do Consignado, será replicado para os demais mêses do Ano.
                 DT FECHAMENTO DA FOLHA = 25/03
                 DE     ATE     DT ARQUIVO   DT VENCIMENTO
                 16/01  15/02   15/02        12/03 

      Alteração : 

    ----------------------------------------------------------------------------------------------------------*/
    vr_dsmensag    VARCHAR2(4000);
    
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
    
  CURSOR cr_tbcadast_emp_consig_param(pr_cdcooper1 in number) IS
    SELECT to_char(dtinclpropostade,'MM')  mes_inicial_de
          ,to_char(dtinclpropostaate,'MM') mes_inicial_ate
          ,to_char(dtenvioarquivo,'MM')    mes_inicial_arq
          ,to_char(dtvencimento,'MM')      mes_inicial_venc  
          ,dtinclpropostade
          ,dtinclpropostaate
          ,dtenvioarquivo
          ,dtvencimento
    FROM cecred.tbcadast_emp_consig_param
   WHERE idemprconsig = ( SELECT idemprconsig
                            FROM cecred.tbcadast_empresa_consig
                           WHERE cdcooper = pr_cdcooper1
                             AND cdempres = pr_cdempres); 
                             
    rw_param     cr_tbcadast_emp_consig_param%ROWTYPE;
    vr_mes_novo_de   number;
    vr_mes_novo_ate  number;
    vr_mes_novo_arq  number;
    vr_mes_novo_venc number;            
    
  BEGIN
  
    -- Extrai os dados vindos do XML pr_retxml na tabela 
    pr_des_erro := 'OK';
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper    --OUT
                            ,pr_nmdatela => vr_nmdatela    --OUT
                            ,pr_nmeacao  => vr_nmeacao     --OUT 
                            ,pr_cdagenci => vr_cdagenci    --OUT
                            ,pr_nrdcaixa => vr_nrdcaixa    --OUT
                            ,pr_idorigem => vr_idorigem    --OUT 
                            ,pr_cdoperad => vr_cdoperad    --OUT
                            ,pr_dscritic => vr_dscritic);
    IF  TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;
    
    --Inserir ou Alterar os Parâmetros para Emprestimos Consignado por Empresa   
    pc_inc_alt_param_consig( pr_cdcooper           => vr_cdcooper
                            ,pr_cdempres           => pr_cdempres
                            ,pr_cdoperad           => vr_cdoperad
                            ,pr_idemprconsigparam  => pr_idemprconsigparam                             
                            ,pr_dtinclpropostade   => pr_dtinclpropostade
                            ,pr_dtinclpropostaate  => pr_dtinclpropostaate
                            ,pr_dtenvioarquivo     => pr_dtenvioarquivo
                            ,pr_dtvencimento       => pr_dtvencimento
                            ,pr_dsmensag           => vr_dsmensag    --> Mensagem  
                            ,pr_cdcritic           => vr_cdcritic    --> Codigo da critica
                            ,pr_dscritic           => vr_dscritic ); --> Descricao da critica

    IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    COMMIT;
    
    --Depois de Inserir a primeiro registro, fazer a replicação para os demais mêses do ano
    OPEN cr_tbcadast_emp_consig_param(vr_cdcooper);
    FETCH cr_tbcadast_emp_consig_param INTO rw_param;
    CLOSE cr_tbcadast_emp_consig_param;
    
    vr_mes_novo_de   := rw_param.mes_inicial_de;
    vr_mes_novo_ate  := rw_param.mes_inicial_ate;
    vr_mes_novo_arq  := rw_param.mes_inicial_arq;
    vr_mes_novo_venc := rw_param.mes_inicial_venc;
  
    FOR CONTADOR IN 1..11 LOOP
      
      --Mês de inclusão da proposta De (DD/MM)
      IF vr_mes_novo_de < 12 THEN
        vr_mes_novo_de := vr_mes_novo_de + 1;
      ELSIF vr_mes_novo_de = 12 THEN  
        vr_mes_novo_de := 1;
      ELSE
        vr_mes_novo_de := vr_mes_novo_de + 1;
      END IF;
      
      --Mês de inclusao da proposta Ate(DD/MM).
      IF vr_mes_novo_ate < 12 THEN
        vr_mes_novo_ate := vr_mes_novo_ate + 1;
      ELSIF vr_mes_novo_ate = 12 THEN  
        vr_mes_novo_ate := 1;
      ELSE
        vr_mes_novo_ate := vr_mes_novo_ate + 1;
      END IF;
      
      --Mês do envio do arquivo (DD/MM).
      IF vr_mes_novo_arq < 12 THEN
        vr_mes_novo_arq := vr_mes_novo_arq + 1;
      ELSIF vr_mes_novo_arq = 12 THEN  
        vr_mes_novo_arq := 1;
      ELSE
        vr_mes_novo_arq := vr_mes_novo_arq + 1;
      END IF;
      
      --Data do vencimento (DD/MM).
      IF vr_mes_novo_venc < 12 THEN
        vr_mes_novo_venc := vr_mes_novo_venc + 1;
      ELSIF vr_mes_novo_venc = 12 THEN  
        vr_mes_novo_venc := 1;
      ELSE
        vr_mes_novo_venc := vr_mes_novo_venc + 1;
      END IF;
          
      --DBMS_OUTPUT.put_line(CONTADOR||' '||to_char(rw_param.dtinclpropostade,'DD')||'/'|| LPAD(vr_mes_novo,2,'0')||'/'||to_char(rw_param.dtinclpropostade,'RRRR'));
      --Inserir ou Alterar os Parâmetros para Emprestimos Consignado por Empresa   
      pc_inc_alt_param_consig( pr_cdcooper           => vr_cdcooper
                              ,pr_cdempres           => pr_cdempres
                              ,pr_cdoperad           => vr_cdoperad
                              ,pr_idemprconsigparam  => pr_idemprconsigparam                             
                              ,pr_dtinclpropostade   => to_char(rw_param.dtinclpropostade,'DD') ||'/'|| LPAD(vr_mes_novo_de,2,'0')  
                              ,pr_dtinclpropostaate  => to_char(rw_param.dtinclpropostaate,'DD')||'/'|| LPAD(vr_mes_novo_ate,2,'0') --||'/'||to_char(rw_param.dtinclpropostaate,'RRRR') 
                              ,pr_dtenvioarquivo     => to_char(rw_param.dtenvioarquivo,'DD')   ||'/'|| LPAD(vr_mes_novo_arq,2,'0') --||'/'||to_char(rw_param.dtenvioarquivo,'RRRR') 
                              ,pr_dtvencimento       => to_char(rw_param.dtvencimento,'DD')     ||'/'|| LPAD(vr_mes_novo_venc,2,'0')--||'/'||to_char(rw_param.dtvencimento,'RRRR') 
                              ,pr_dsmensag           => vr_dsmensag    --> Mensagem  
                              ,pr_cdcritic           => vr_cdcritic    --> Codigo da critica
                              ,pr_dscritic           => vr_dscritic ); --> Descricao da critica

      IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END LOOP;
    
    COMMIT;
    
    --Preparar o Retorno de todas as linhas
    pc_busca_param_consig_web(pr_cdempres 
                              -- campos padrões  
                             ,pr_xmllog 
                             ,pr_cdcritic
                             ,pr_dscritic
                             ,pr_retxml  
                             ,pr_nmdcampo
                             ,pr_des_erro );
                                     
    --pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><dsmensag>'||vr_dsmensag||'</dsmensag></Root>');
    
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
         pr_dscritic := 'Erro geral na rotina tela_consig.pc_replicar_param_consig_web: '||SQLERRM;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;                                         
  END pc_replicar_param_consig_web;      
 
  PROCEDURE pc_busca_dados_emp_fis (-- campos padrões  
                                    pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                   ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                   ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                   ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                   ) IS
 
   /*---------------------------------------------------------------------------------------------------------
      Programa : pc_busca_dados_emp_fis
      Sistema  : AIMARO
      Sigla    : CONSIG
      Autor    : Josiane Stiehler - AMcom Sistemas de Informação
      Data     : 29/03/2019

      Objetivo : Recebe os dados da tela Consig e lê os dados da empresa e gera
                 XML com as duas informações retornando um XLM para tela CONSIG validar os dados na FIS.

      Alteração : 

    ----------------------------------------------------------------------------------------------------------*/

 BEGIN
    DECLARE
    
    /* Tratamento de erro */
    vr_exc_erro EXCEPTION;

    /* Descrição e código da critica */
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(10);

    -- variaveis de retorno
    vr_tab_dados_param_consig typ_tab_dados_param_consig;
    vr_qtregist         number;

    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);
    vr_cdempres tbcadast_empresa_consig.cdempres%TYPE; --> codigo da empresa

    vr_datainicio    varchar2(20);
    vr_indconsignado number(2);
    vr_tipoPadrao    varchar2(10);
    vr_idemprconsig  number;
    vr_qtdtotal      number;
    vr_nrvencto      number;
    vr_xmlvencto     varchar2(32600);
    
    vr_usuario       crapprm.dsvlrprm%type; 
    vr_senha         crapprm.dsvlrprm%type;
        
    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
    vr_index          varchar2(100);
    
    CURSOR cr_dados_consig (pr_cdcooper      IN crapemp.cdcooper%type,
                            pr_indconsignado IN tbcadast_empresa_consig.indconsignado%type) IS
    SELECT 'GRCONV' codTransacao,
           to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') dataHoraEnvio,
           e.cdcooper codpromotora,
           e.cdempres codconvenio,
           e.nrdocnpj numcnpjloja,
           decode(pr_indconsignado,0,sysdate,null) datafim,
           gene0007.fn_caract_acento (pr_texto    => e.nmresemp,
                                      pr_insubsti => 1) descnomeloja,
           gene0007.fn_caract_acento (pr_texto    => e.nmextemp,
                                      pr_insubsti => 1) descrazaoloja,
           e.nrcepend ceplogradouro,
           gene0007.fn_caract_acento (pr_texto    => e.dsendemp,
                                      pr_insubsti => 1) desclogradouro,
           e.nrendemp numlogradouro,
           gene0007.fn_caract_acento (pr_texto    => e.dscomple,
                                      pr_insubsti => 1) desccompllogradouro,
           gene0007.fn_caract_acento (pr_texto    => e.nmbairro,
                                      pr_insubsti => 1) descbairrologradouro,
           gene0007.fn_caract_acento (pr_texto    => e.nmcidade,
                                      pr_insubsti => 1) desccidadelogradouro,
           e.cdufdemp uflogradouro,
           47  dddloja,  ---- falta implementar na cdemp um novo campo só para DDD
           e.nrfonemp telloja,
           null descEmail,
           null descContatoLoja,  
           p.cdbcoctl codbanco,
           p.cdagectl codAgencia,
           e.nrdconta numConta,
           null numContaDigito,
           '1' tipoOperador
     FROM crapemp e,
          tbcadast_empresa_consig c,
          crapcop p
    WHERE e.cdcooper      = c.cdcooper
      AND e.cdempres      = c.cdempres
      AND e.cdcooper      = p.cdcooper
      AND e.cdcooper      = pr_cdcooper
      AND e.cdempres      = vr_cdempres;

     
     PROCEDURE pc_escreve_xml( pr_des_dados in varchar2
                            , pr_fecha_xml in boolean default false
                            ) is
    BEGIN
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
    END;
  

    BEGIN
      
      /*Validação do Range dos Vencimentos*/ 
      pc_validar_venctos_consig( pr_retxml   => pr_retxml   --IN
                                ,pr_cdcritic => vr_cdcritic --OUT
                                ,pr_dscritic => vr_dscritic --OUT
                                ,pr_des_erro => vr_des_erro --OUT
                                );

      IF vr_des_erro = 'NOK' THEN         
        raise vr_exc_erro;
      END IF;                          
    
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

      IF (nvl(vr_cdcritic,0) <> 0 OR  
          vr_dscritic IS NOT NULL) THEN
          raise vr_exc_erro;
      END IF;

      -- Extraindo os dados do XML que vem da tela CONSIG    
      vr_cdempres     := TRIM(pr_retxml.extract('/Root/dto/cdempres/text()').getstringval());      
      vr_datainicio   := TRIM(pr_retxml.extract('/Root/dto/datainicio/text()').getstringval());      
      vr_indconsignado:= TRIM(pr_retxml.extract('/Root/dto/indconsignado/text()').getstringval());      
      vr_tipoPadrao   := TRIM(pr_retxml.extract('/Root/dto/tipoPadrao/text()').getstringval());      
      vr_idemprconsig := TO_NUMBER(TRIM(pr_retxml.extract('/Root/dto/idemprconsig/text()').getstringval()));      
      vr_qtdtotal     := TO_NUMBER(TRIM(pr_retxml.extract('/Root/dto/vencimentos/total/text()').getstringval()));      

      
      vr_nrvencto := 0;
      vr_xmlvencto:= null;
      FOR x in 1 .. vr_qtdtotal
      LOOP
        vr_nrvencto:= vr_nrvencto + 1;
        vr_xmlvencto:=  vr_xmlvencto||
                        '<vencimento'||vr_nrvencto||'>'||
                          '<dataInicioValidade>'||to_char(sysdate,'dd/mm/yyyy')||'</dataInicioValidade>'||
                          '<diaMesDe>'||TRIM(pr_retxml.extract('/Root/dto/vencimentos/vencimento'||vr_nrvencto
                                      ||'/'||'diaMesDe/text()').getstringval())||'/1900'||'</diaMesDe>'||    
                          '<diaMesAte>'||TRIM(pr_retxml.extract('/Root/dto/vencimentos/vencimento'||vr_nrvencto
                                       ||'/'||'diaMesAte/text()').getstringval())||'/1900'||'</diaMesAte>'||    
                          '<diaMesEnvio>'||TRIM(pr_retxml.extract('/Root/dto/vencimentos/vencimento'||vr_nrvencto
                                         ||'/'||'diaMesEnvio/text()').getstringval())||'/1900'||'</diaMesEnvio>'||    
                          '<diaMesVencto>'||TRIM(pr_retxml.extract('/Root/dto/vencimentos/vencimento'||vr_nrvencto
                                          ||'/'||'diaMesVencto/text()').getstringval())||'/1900'||'</diaMesVencto>'||    
                          '<tipoDiavencto>DC</tipoDiavencto>'||
                          '<tipoAjuste>F</tipoAjuste>'||
                          '<qtdeVenctos>1</qtdeVenctos>'||
                        '</vencimento'||to_char(vr_nrvencto)||'>';
      END LOOP;
            
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
        '<root><dados qtregist="' || 1 ||'" >');

      -- verifica em qual banco de dados esta sendo executadO
      IF gene0001.fn_database_name = gene0001.fn_param_sistema('CRED',vr_cdcooper,'DB_NAME_PRODUC') THEN --> Produção
         -- busca usuário e senha do serviço com a FIS de PRODUÇÃO
         vr_usuario:= gene0001.fn_param_sistema('CRED',0,'USUARIO_FIS_PRD');
         vr_senha  := gene0001.fn_param_sistema('CRED',0,'SENHA_FIS_PRD');
      ELSE
         -- busca usuário e senha do serviço com a FIS de HOMOLOGAÇÃO
         vr_usuario:= gene0001.fn_param_sistema('CRED',0,'USUARIO_FIS_HML');
         vr_senha  := gene0001.fn_param_sistema('CRED',0,'SENHA_FIS_HML');
      END IF;
      
      
      -- ler os registros do consignado e incluir no xml
      FOR rw_dados_consig in cr_dados_consig (pr_cdcooper      => vr_cdcooper,
                                              pr_indconsignado => vr_idemprconsig)
      LOOP
        pc_escreve_xml('<gravaDadosConvenio>'||
                       '<dto>'||
                            '<codUsuario>'||vr_usuario||'</codUsuario>'||
                            '<codSenha>'||vr_senha||'</codSenha>'||
                            '<codTransacao>'||rw_dados_consig.codtransacao||'</codTransacao>'||
                            '<dataHoraEnvio>'||rw_dados_consig.datahoraenvio||'</dataHoraEnvio>'||
                            '<codPromotora>'||rw_dados_consig.codpromotora||'</codPromotora>'||
                            '<codConvenio>'||rw_dados_consig.codconvenio||'</codConvenio>'||
                            '<numCNPJLoja>'||rw_dados_consig.numcnpjloja||'</numCNPJLoja>'||
                            '<descNomeLoja>'||rw_dados_consig.descnomeloja||'</descNomeLoja>'||
                            '<descRazaoLoja>'||rw_dados_consig.descrazaoloja||'</descRazaoLoja>'||
                            '<dataInicio>'||vr_datainicio||'</dataInicio>'||
                            '<dataFim>'||rw_dados_consig.datafim||'</dataFim>'||
                            '<cepLogradouro>'||rw_dados_consig.ceplogradouro||'</cepLogradouro>'||
                            '<descLogradouro>'||rw_dados_consig.desclogradouro||'</descLogradouro>'||
                            '<numLogradouro>'||rw_dados_consig.numlogradouro||'</numLogradouro>'||
                            '<descComplementoLogradouro>'||rw_dados_consig.desccompllogradouro||'</descComplementoLogradouro>'||
                            '<descBairroLogradouro>'||rw_dados_consig.descbairrologradouro||'</descBairroLogradouro>'||
                            '<descCidadeLogradouro>'||rw_dados_consig.desccidadelogradouro||'</descCidadeLogradouro>'||
                            '<ufLogradouro>'||rw_dados_consig.uflogradouro||'</ufLogradouro>'||
                            '<dddLoja>'||rw_dados_consig.dddloja||'</dddLoja>'||
                            '<telLoja>'||rw_dados_consig.telloja||'</telLoja>'||
                            '<descEmail>'||rw_dados_consig.descemail||'</descEmail>'||
                            '<descContatoLoja>'||rw_dados_consig.desccontatoloja||'</descContatoLoja>'||
                            '<codbanco>'||rw_dados_consig.codbanco||'</codbanco>'||
                            '<codAgencia>'||rw_dados_consig.codagencia||'</codAgencia>'||
                            '<numConta>'||rw_dados_consig.numconta||'</numConta>'||
                            '<numContaDigito>'||rw_dados_consig.numcontadigito||'</numContaDigito>'||
                            '<tipoOperador>'||rw_dados_consig.tipooperador||'</tipoOperador>'||
                            '<tipoPadrao>'||vr_tipoPadrao||'</tipoPadrao>'||
                            vr_xmlvencto||
                          '</dto>'||                           
                       '</gravaDadosConvenio>');
                           
      END LOOP;
      
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_erro THEN
         /*  se foi retornado apenas código */
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             /* buscar a descriçao */
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
         /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro não tratado na tela_consig.pc_busca_param_consig_web ' ||SQLERRM;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_dados_emp_fis;
                                                  

  PROCEDURE pc_validar_venctos_consig( pr_retxml      IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_cdcritic   OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic   OUT VARCHAR2              --> Descricao da critica
                                      ,pr_des_erro   OUT VARCHAR2              --> Erros do processo
                                      ) IS
 /*---------------------------------------------------------------------------------------------------------
      Programa : pc_validar_venctos_consig
      Sistema  : AIMARO
      Sigla    : CONSIG
      Autor    : Fernanda Kelli de Oliveira - AMcom Sistemas de Informação
      Data     : 04/04/2019
  
      Objetivo : Recebe em XML os dados da tela Consig, lê o range vencimentos DE/ATE
                 e verifica se esta faltando algum dia do ano na parametrização do Grid. 
                 Ex.: 
                 DE         ATE
                 11/01      10/02
                 11/03      10/04
                 11/04      10/05
                 ...
                 11/12      10/01
  
      Alteração : 
  
  ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
    
    /* Tratamento de erro */
    vr_exc_erro EXCEPTION;

    /* Descrição e código da critica */
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    vr_nrvencto           NUMBER;
    vr_qtdtotal           NUMBER;
    vr_dtinclpropostade   DATE := NULL;
    vr_diaMesDe           VARCHAR2(10);
    vr_dtinclpropostaate  DATE := NULL;
    vr_diaMesAte           VARCHAR2(10);
    vr_dtate_ant          DATE := NULL;
        
    BEGIN

      pr_des_erro := 'OK';
      
      -- Extraindo os dados do XML o valor da tag <total>   
      vr_qtdtotal     := TO_NUMBER(TRIM(pr_retxml.extract('/Root/dto/vencimentos/total/text()').getstringval()));      

      vr_nrvencto := 0;
     -- vr_xmlvencto:= null;
      FOR x in 1 .. vr_qtdtotal LOOP
        vr_nrvencto:= vr_nrvencto + 1;  
        vr_diaMesDe  := TRIM(pr_retxml.extract('/Root/dto/vencimentos/vencimento'||vr_nrvencto||'/'||'diaMesDe/text()').getstringval());    
        vr_dtinclpropostade  := TO_DATE(vr_diaMesDe,'DD/MM');
        
        vr_diaMesAte := TRIM(pr_retxml.extract('/Root/dto/vencimentos/vencimento'||vr_nrvencto||'/'||'diaMesAte/text()').getstringval());
        vr_dtinclpropostaate := TO_DATE(vr_diaMesAte,'DD/MM');
        
        IF vr_nrvencto = 1 THEN
          vr_dtate_ant := vr_dtinclpropostaate;
        ELSIF vr_nrvencto > 1 THEN
          IF vr_dtate_ant + 1 <> vr_dtinclpropostade  THEN
            vr_dscritic := 'Nao esta completo o Grid de Vencimentos com todas os dias do Ano.';
            raise vr_exc_erro; 
          END IF;
          vr_dtate_ant := vr_dtinclpropostaate;           
        END IF;        
      END LOOP;      
    
    EXCEPTION
      WHEN vr_exc_erro THEN
         /*  se foi retornado apenas código */
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             /* buscar a descriçao */
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
         /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro não tratado na tela_consig.pc_validar_venctos_consig ' ||SQLERRM;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_validar_venctos_consig;
  
END TELA_CONSIG;
/
