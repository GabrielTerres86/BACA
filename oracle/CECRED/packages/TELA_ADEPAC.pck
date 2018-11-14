CREATE OR REPLACE PACKAGE CECRED.TELA_ADEPAC AS

  -- Definicao de TEMP TABLE para consulta do saldo de aplicacao RDCA
  TYPE typ_reg_tbtarif_pacotes IS
    RECORD(cdpacote            tbtarif_contas_pacote.cdpacote%TYPE           --> Codigo do pacote
          ,dspacote            tbtarif_pacotes.dspacote%TYPE                 --> Descricao do pacote
          ,dtinicio_vigencia   VARCHAR2(10)                                  --> Data de início da vigencia
          ,dtadesao            VARCHAR2(10)                                  --> Data de adesao do pacote
          ,flgsituacao         VARCHAR2(10)                                  --> Situacao do pacote
          ,dtcancelamento      VARCHAR2(10)                                  --> Data de cancelamento
          ,nrdiadebito         tbtarif_contas_pacote.nrdiadebito%TYPE        --> Dia do debito
          ,perdesconto_manual  tbtarif_contas_pacote.perdesconto_manual%TYPE --> % desconto manual
          ,qtdmeses_desconto   tbtarif_contas_pacote.qtdmeses_desconto%TYPE	 --> Qtd meses desconto
          ,cdreciprocidade     VARCHAR2(10)                                  --> Possui reciprocidade
          ,dtass_eletronica    VARCHAR2(20));                                --> Data assinatura eletronica
          
  -- Definicao de tipo de tabela para acumulo Aplicacoes
  TYPE typ_tab_tbtarif_pacotes IS
    TABLE OF typ_reg_tbtarif_pacotes
    INDEX BY BINARY_INTEGER;
     
  PROCEDURE pc_busca_pacotes_tarifas(pr_cdcooper        IN  crapcop.cdcooper%TYPE               --> Código da cooperativa
                                    ,pr_nrdconta        IN  crapass.nrdconta%TYPE               --> Numero da conta
                                    ,pr_nrregist        IN INTEGER                                --> Numero de Registros Exibidos
                                    ,pr_nrinireg        IN INTEGER                               --> Registro Inicial
                                    ,pr_qtregist        OUT INTEGER                             --> Quantidade de registros
                                    ,pr_tbtarif_pacotes OUT TELA_ADEPAC.typ_tab_tbtarif_pacotes --> Tabela com os dados de pacotes
                                    ,pr_cdcritic        OUT crapcri.cdcritic%TYPE               --> Código da crítica
                                    ,pr_dscritic        OUT crapcri.dscritic%TYPE);           --> Descrição da crítica             --> Descrição da crítica

  -- Rotina para consulta de pacotes de tarifas via AYLLOS WEB
  PROCEDURE pc_busca_pct_tar_web(pr_cdcooper IN  crapcop.cdcooper%TYPE        --> Descricao do Pacote de Tarifas     
                                ,pr_nrdconta IN  crapass.nrdconta%TYPE        --> Descricao do Pacote de Tarifas
                                ,pr_nrregist IN INTEGER                        --> Numero de Registros Exibidos
                                ,pr_nrinireg IN INTEGER                        --> Registro Inicial
                                ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);                   --> Saida OK/NOK
  
  /*Valida dados de reciprocidade para a conta*/
  PROCEDURE pc_validacoes_pct(pr_nrdconta IN crapass.nrdconta%TYPE --> numero da conta
                             ,pr_xmllog             IN VARCHAR2               --> XML com informações de LOG
                             ,pr_cdcritic           OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic           OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml             IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                             ,pr_nmdcampo           OUT VARCHAR2              --> Nome do Campo
                             ,pr_des_erro           OUT VARCHAR2);            --> Saida OK/NOK
  /*pesquisa de pacotes de tarifas*/
  PROCEDURE pc_pesq_pacotes(pr_cdpacote IN INTEGER
                           ,pr_dspacote IN VARCHAR2
                           ,pr_inpessoa IN crapass.inpessoa%TYPE
                           ,pr_nriniseq IN INTEGER            --> Registro inicial da listagem
                           ,pr_nrregist IN INTEGER            --> Numero de registros p/ paginaca
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);        --> Erros do processo
                           
  /*pesquisa de pacotes de tarifas*/
  PROCEDURE pc_valida_inclusao(pr_cdpacote           IN INTEGER               --> codigo do pacote
                              ,pr_dtdiadebito        IN INTEGER               --> Dia do debito
                              ,pr_perdesconto_manual IN INTEGER               --> % desconto manual
                              ,pr_qtdmeses_desconto  IN INTEGER               --> qtd de meses de desconto
                              ,pr_nrdconta           IN crapass.nrdconta%TYPE --> nr da conta
                              ,pr_xmllog             IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic           OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic           OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo           OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro           OUT VARCHAR2);           --> Erros do processo
  
  /*Verifica se o pacote esta cancelado*/
  PROCEDURE pc_incluir_pacote(pr_cdpacote           IN INTEGER               --> codigo do pacote
                             ,pr_dtdiadebito        IN INTEGER               --> Dia do debito
                             ,pr_perdesconto_manual IN INTEGER               --> % desconto manual
                             ,pr_qtdmeses_desconto  IN INTEGER               --> qtd de meses de desconto
                             ,pr_nrdconta           IN crapass.nrdconta%TYPE --> nr da conta
                             ,pr_idparame_reciproci IN INTEGER               --> codigo de reciprocidade
                             ,pr_idtipo_autorizacao IN VARCHAR2              --> tipo autorizacao (S=Senha, A=Assinatura)
                             ,pr_xmllog             IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic           OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic           OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml             IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                             ,pr_nmdcampo           OUT VARCHAR2             --> Nome do Campo
                             ,pr_des_erro           OUT VARCHAR2);           --> Saida OK/NOK
  
  /*Incluir pacote de tarifas*/
  PROCEDURE pc_verif_pct_cancel(pr_cdpacote IN INTEGER               --> codigo do pacote
                               ,pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
                               ,pr_dtadesao IN VARCHAR2              --> data de adesao do pacote
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK
   
  /*Cancelar pacote de tarifas*/
  PROCEDURE pc_cancela_pacote(pr_cdpacote IN INTEGER               --> codigo do pacote
                             ,pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
                             ,pr_dtadesao IN VARCHAR2              --> data de adesao do pacote
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                             ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK
  
  /*Cancelar pacote de tarifas*/
  PROCEDURE pc_altera_debito(pr_cdpacote    IN INTEGER               --> codigo do pacote
                            ,pr_nrdconta    IN crapass.nrdconta%TYPE --> nr da conta
                            ,pr_dtadesao    IN VARCHAR2              --> data de adesao do pacote
                            ,pr_dtdiadebito IN VARCHAR2              --> data de adesao do pacote
                            ,pr_xmllog      IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic    OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic    OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml      IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                            ,pr_nmdcampo    OUT VARCHAR2             --> Nome do Campo
                            ,pr_des_erro    OUT VARCHAR2);           --> Saida OK/NOK
                            
  /*Imprime extrato de reciprocidade*/
  PROCEDURE pc_extrato_reciproci(pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
		                            ,pr_dtadesao IN VARCHAR2              --> Data de adesão
                                ,pr_mesrefer IN VARCHAR2
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK
  
  /*Imprime indicadores de reciprocidade*/
  PROCEDURE pc_indicadores_reciproci(pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
		                                ,pr_dtadesao IN VARCHAR2              --> Data de adesão
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK
  
  /*Imprime adesao do pacote*/
  PROCEDURE pc_termo_adesao_pacote (pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
                                   ,pr_dtadesao IN VARCHAR2              --> dt da adesao do pacote
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK
  
  /*Imprime termo cancelamento do pacote*/
  PROCEDURE pc_termo_cancela_pacote (pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
                                    ,pr_dtadesao IN VARCHAR2              --> dt da adesao do pacote
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK
    
  /*Busca descrição do pacote*/
  PROCEDURE pc_busca_pacote(pr_cdpacote IN INTEGER            --> codigo do pacote
                           ,pr_inpessoa IN crapass.inpessoa%TYPE --> Tipo de pessoa
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2);        --> Saida OK/NOK
    
END TELA_ADEPAC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ADEPAC AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_ADEPAC
  --    Autor   : lucas Lombardi
  --    Data    : Marco/2016                   Ultima Atualizacao: 30/10/2018
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela ADEPAC (Ayllos Web)
  --
  --    Alteracoes:                              
  --    			
  --    30/10/2018 - Merge Changeset 26538 referente ao P435 - Tarifas Avulsas (Peter - Supero)
  ---------------------------------------------------------------------------------------------------------------
  
  /*Consulta tarifas*/
  PROCEDURE pc_busca_pacotes_tarifas(pr_cdcooper        IN  crapcop.cdcooper%TYPE               --> Código da cooperativa
                                    ,pr_nrdconta        IN  crapass.nrdconta%TYPE               --> Numero da conta
                                    ,pr_nrregist        IN INTEGER                                --> Numero de Registros Exibidos
                                    ,pr_nrinireg        IN INTEGER                               --> Registro Inicial
                                    ,pr_qtregist        OUT INTEGER                             --> Quantidade de registros
                                    ,pr_tbtarif_pacotes OUT TELA_ADEPAC.typ_tab_tbtarif_pacotes --> Tabela com os dados de pacotes
                                    ,pr_cdcritic        OUT crapcri.cdcritic%TYPE               --> Código da crítica
                                    ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS           --> Descrição da crítica

    /* .............................................................................
    Programa: pc_consulta_pacotes_tarifas
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar pacotes de tarifas
    
    Alteracoes: 
    ............................................................................. */
        
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes(pr_cdcooper IN  crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN  crapass.nrdconta%TYPE) IS
      SELECT tcp.cdpacote
            ,tp.dspacote
            ,tcp.dtinicio_vigencia
            ,tcp.flgsituacao
            ,tcp.dtcancelamento
            ,tcp.nrdiadebito
            ,tcp.perdesconto_manual
            ,tcp.qtdmeses_desconto
            ,tcp.cdreciprocidade
            ,tcp.dtadesao
            ,tcp.dtass_eletronica
        FROM tbtarif_contas_pacote tcp
            ,tbtarif_pacotes       tp
       WHERE tcp.nrdconta = pr_nrdconta
         AND tcp.cdcooper = pr_cdcooper
         AND tp.cdpacote = tcp.cdpacote
         ORDER BY tcp.dtadesao DESC;
    
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    vr_tbtarif_pacotes TELA_ADEPAC.typ_tab_tbtarif_pacotes;
    vr_ind_pacotes NUMBER(10);
    
    vr_nrregist NUMBER(10);
    vr_nrinireg NUMBER(10);

  BEGIN
      
    FOR rw_tbtarif_pacotes IN cr_tbtarif_pacotes(pr_cdcooper => pr_cdcooper   
                                                ,pr_nrdconta => pr_nrdconta) LOOP

      -- Buscar qual a quantidade atual de registros no vetor para posicionar na próxima
      vr_ind_pacotes := vr_tbtarif_pacotes.COUNT() + 1;
      -- Criar um registro no vetor
      vr_tbtarif_pacotes(vr_ind_pacotes).cdpacote           := rw_tbtarif_pacotes.cdpacote;
      vr_tbtarif_pacotes(vr_ind_pacotes).dspacote           := rw_tbtarif_pacotes.dspacote;

      IF rw_tbtarif_pacotes.flgsituacao = 1 AND rw_tbtarif_pacotes.dtcancelamento IS NULL THEN
         vr_tbtarif_pacotes(vr_ind_pacotes).flgsituacao     := 'Ativo';
      ELSE
         vr_tbtarif_pacotes(vr_ind_pacotes).flgsituacao     := 'Cancelado';
      END IF;

      vr_tbtarif_pacotes(vr_ind_pacotes).dtinicio_vigencia  := to_char(rw_tbtarif_pacotes.dtinicio_vigencia,'DD/MM/RRRR');
      
      vr_tbtarif_pacotes(vr_ind_pacotes).dtcancelamento     := to_char(rw_tbtarif_pacotes.dtcancelamento,'DD/MM/RRRR');
      
      vr_tbtarif_pacotes(vr_ind_pacotes).nrdiadebito        := rw_tbtarif_pacotes.nrdiadebito;
      
      vr_tbtarif_pacotes(vr_ind_pacotes).perdesconto_manual := rw_tbtarif_pacotes.perdesconto_manual;
      
      vr_tbtarif_pacotes(vr_ind_pacotes).qtdmeses_desconto  := rw_tbtarif_pacotes.qtdmeses_desconto;
      
      vr_tbtarif_pacotes(vr_ind_pacotes).cdreciprocidade := rw_tbtarif_pacotes.cdreciprocidade;
      
      vr_tbtarif_pacotes(vr_ind_pacotes).dtadesao := to_char(rw_tbtarif_pacotes.dtadesao,'DD/MM/RRRR');
      
      vr_tbtarif_pacotes(vr_ind_pacotes).dtass_eletronica := to_char(rw_tbtarif_pacotes.dtass_eletronica,'DD/MM/RRRR HH24:MI');
      
      vr_nrregist := vr_nrregist + 1;

    END LOOP;

    pr_tbtarif_pacotes := vr_tbtarif_pacotes;
    pr_qtregist        := vr_tbtarif_pacotes.COUNT();		

  EXCEPTION
    WHEN vr_exc_erro THEN
      
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      ROLLBACK;  

    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_CONSULTA_PACOTE_TARIFA --> ' || SQLERRM;
      
      ROLLBACK;
          
  END pc_busca_pacotes_tarifas;
 
  /*Consulta tarifas via Ayllos Web*/
  PROCEDURE pc_busca_pct_tar_web(pr_cdcooper IN  crapcop.cdcooper%TYPE        --> Descricao do Pacote de Tarifas     
                                ,pr_nrdconta IN  crapass.nrdconta%TYPE        --> Descricao do Pacote de Tarifas
                                ,pr_nrregist IN INTEGER                        --> Numero de Registros Exibidos
                                ,pr_nrinireg IN INTEGER                        --> Registro Inicial
                                ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2) IS                 --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_consult_pct_tar_web
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar pacote de tarifas via Ayllos Web
    
    Alteracoes: 
    ............................................................................. */
       
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_dstexto   VARCHAR2(32700);
    vr_clobxml   CLOB;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dstransa  VARCHAR2(1000) := 'Acesso rotina de servicos cooperativos';
    vr_nrdrowid  ROWID;
		      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    -- Gerais
    vr_auxconta INTEGER := 0;
    vr_qtregist INTEGER := 0;

    vr_tbtarif_pacotes TELA_ADEPAC.typ_tab_tbtarif_pacotes;

  BEGIN
  
    pr_des_erro := 'OK';
  
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
      RAISE vr_exc_erro;
    END IF;
    
    -- Leitura de pacote de tarifas
    TELA_ADEPAC.pc_busca_pacotes_tarifas(pr_cdcooper        => pr_cdcooper        --> Código da cooperativa
                                        ,pr_nrdconta        => pr_nrdconta        --> Numero da conta
                                        ,pr_nrregist        => pr_nrregist        --> Numero de Registros Exibidos
                                        ,pr_nrinireg        => pr_nrinireg        --> Registro Inicial
                                        ,pr_qtregist        => vr_qtregist        --> Quantidade de registros
                                        ,pr_tbtarif_pacotes => vr_tbtarif_pacotes --> Tabela com os dados de pacotes
                                        ,pr_cdcritic        => pr_cdcritic        --> Código da crítica
                                        ,pr_dscritic        => pr_dscritic);      --> Descrição da crítica         --> Descrição da crítica

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'regs', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtregist', pr_tag_cont => vr_qtregist, pr_des_erro => vr_dscritic);

    -- Para cada registro de tarifa
	  FOR vr_contador IN 1 .. vr_qtregist LOOP

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'regs', pr_posicao => 0, pr_tag_nova => 'reg', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => vr_contador - 1, pr_tag_nova => 'cdpacote',           pr_tag_cont => TO_CHAR(vr_tbtarif_pacotes(vr_contador).cdpacote),           pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => vr_contador - 1, pr_tag_nova => 'dspacote',           pr_tag_cont => TO_CHAR(vr_tbtarif_pacotes(vr_contador).dspacote),           pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => vr_contador - 1, pr_tag_nova => 'dtinicio_vigencia',  pr_tag_cont => TO_CHAR(vr_tbtarif_pacotes(vr_contador).dtinicio_vigencia),  pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => vr_contador - 1, pr_tag_nova => 'flgsituacao',        pr_tag_cont => TO_CHAR(vr_tbtarif_pacotes(vr_contador).flgsituacao),        pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => vr_contador - 1, pr_tag_nova => 'dtcancelamento',     pr_tag_cont => TO_CHAR(vr_tbtarif_pacotes(vr_contador).dtcancelamento),     pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => vr_contador - 1, pr_tag_nova => 'dtadesao',           pr_tag_cont => TO_CHAR(vr_tbtarif_pacotes(vr_contador).dtadesao),           pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => vr_contador - 1, pr_tag_nova => 'dtdiadebito',        pr_tag_cont => TO_CHAR(vr_tbtarif_pacotes(vr_contador).nrdiadebito),        pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => vr_contador - 1, pr_tag_nova => 'perdesconto_manual', pr_tag_cont => TO_CHAR(vr_tbtarif_pacotes(vr_contador).perdesconto_manual), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => vr_contador - 1, pr_tag_nova => 'qtdmeses_desconto',  pr_tag_cont => TO_CHAR(vr_tbtarif_pacotes(vr_contador).qtdmeses_desconto),  pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => vr_contador - 1, pr_tag_nova => 'cdreciprocidade',    pr_tag_cont => TO_CHAR(vr_tbtarif_pacotes(vr_contador).cdreciprocidade),    pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'reg', pr_posicao => vr_contador - 1, pr_tag_nova => 'dtass_eletronica',   pr_tag_cont => TO_CHAR(vr_tbtarif_pacotes(vr_contador).dtass_eletronica),   pr_des_erro => vr_dscritic);

    END LOOP;
    
		-- Gerar informacoes do log
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
        
    -- Efetua commit
    COMMIT;    
   
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_VUSCA_PCT_TAR_WEB: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_busca_pct_tar_web;
  
  /*Verifica se existe pacote ativo*/
  PROCEDURE pc_verifica_pct_ativo(pr_nrdconta IN  crapass.nrdconta%TYPE        --> Descricao do Pacote de Tarifas
                                 ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS                 --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_verifica_pct_ativo
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para verificar se existe algum pacote 
                ativo via Ayllos Web.
    
    Alteracoes: 
    ............................................................................. */
    
    CURSOR cr_tbtarif_contas_pacote (pr_cdcooper IN crapcop.cdcooper%TYPE
		                                ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      select 1
      FROM tbtarif_contas_pacote
      WHERE cdcooper = pr_cdcooper
			  AND nrdconta = pr_nrdconta
        AND flgsituacao = 1 
        AND dtcancelamento IS NULL;
    rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;
    
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_existe_pacote VARCHAR2(1);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    -- Gerais
    vr_auxconta INTEGER := 0;
    vr_qtregist INTEGER := 0;

    vr_tbtarif_pacotes TELA_ADEPAC.typ_tab_tbtarif_pacotes;

  BEGIN
  
    pr_des_erro := 'OK';
  
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
      RAISE vr_exc_erro;
    END IF;
    
    OPEN cr_tbtarif_contas_pacote (to_number(vr_cdcooper)
		                              ,pr_nrdconta);
    FETCH cr_tbtarif_contas_pacote INTO rw_tbtarif_contas_pacote;
    
    IF cr_tbtarif_contas_pacote%FOUND THEN
      vr_existe_pacote := 'S';
    ELSE
      vr_existe_pacote := 'N';
    END IF;
    CLOSE cr_tbtarif_contas_pacote;
    
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'existe_pacote', pr_tag_cont => vr_existe_pacote, pr_des_erro => vr_dscritic);

    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_VERIFICA_PCT_ATIVO: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_verifica_pct_ativo;
  
  /*Valida dados de reciprocidade para a conta*/
  PROCEDURE pc_validacoes_pct(pr_nrdconta IN crapass.nrdconta%TYPE --> numero da conta
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                             ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_validacoes_pct
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Faz validações de reciprocidade para a conta e verifica 
                se a cooperativa utiliza reciprocidade via Ayllos Web.
                    
    Alteracoes: 
    ............................................................................. */
    
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    CURSOR cr_tbtarif_contas_pacote (pr_cdcooper IN crapcop.cdcooper%TYPE
		                                ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT 1
        FROM tbtarif_contas_pacote
       WHERE cdcooper = pr_cdcooper
			   AND nrdconta = pr_nrdconta
         AND flgsituacao = 1 
         AND dtcancelamento IS NULL;
    rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;
    
    --Busca flag de reciprocidade da cooperativa
    CURSOR cr_busca_flrecpar(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT flrecpct
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
    rw_busca_flrecpar cr_busca_flrecpar%ROWTYPE;
    
    CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic          crapcri.cdcritic%TYPE;
    vr_dscritic          crapcri.dscritic%TYPE;
    vr_dtinicio_vigencia DATE;
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
  
    pr_des_erro := 'OK';
  
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
      RAISE vr_exc_erro;
    END IF;
    
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
    OPEN cr_tbtarif_contas_pacote (to_number(vr_cdcooper)
		                              ,pr_nrdconta);
    FETCH cr_tbtarif_contas_pacote INTO rw_tbtarif_contas_pacote;
    IF cr_tbtarif_contas_pacote%FOUND THEN
      vr_dscritic := 'Já existe Serviço Cooperativo ativo para esta conta.';
    RAISE vr_exc_erro;
    END IF;    
    CLOSE cr_tbtarif_contas_pacote;
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    --Busca flag de reciprocidade da cooperativa
    OPEN cr_busca_flrecpar(vr_cdcooper);
    FETCH cr_busca_flrecpar INTO rw_busca_flrecpar;
    IF cr_busca_flrecpar%FOUND THEN
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'flrecpct', pr_tag_cont => rw_busca_flrecpar.flrecpct, pr_des_erro => vr_dscritic);
    ELSE
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperativa não encontrada.';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_busca_flrecpar;
    pr_des_erro := 'OK';
    
    --Busca dados do associado
    OPEN cr_crapass (vr_cdcooper, pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%FOUND THEN
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inpessoa', pr_tag_cont => rw_crapass.inpessoa, pr_des_erro => vr_dscritic);
    ELSE
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;

    vr_dtinicio_vigencia := to_date('01/' || to_char(rw_crapdat.dtultdia + 8, 'MM/RRRR'), 'DD/MM/RRRR');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inivigen', pr_tag_cont => to_char(vr_dtinicio_vigencia, 'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_VALIDACOES_PCT ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_validacoes_pct;
  
  /*pesquisa de pacotes de tarifas*/
  PROCEDURE pc_pesq_pacotes(pr_cdpacote IN INTEGER
                           ,pr_dspacote IN VARCHAR2
                           ,pr_inpessoa IN crapass.inpessoa%TYPE
                           ,pr_nriniseq IN INTEGER               --> Registro inicial da listagem
                           ,pr_nrregist IN INTEGER               --> Numero de registros p/ paginaca
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_pesq_pacotes
    Sistema : Cobrança - Cooperativa de Credito
    Sigla   : COB
    Autor   : Lucas Lombardi
    Data    : Abril/16.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina pesquisa pacotes de tarifas

    Observacao: -----

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_pacotes_tarifa (pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                               ,pr_cdpacote IN INTEGER
                               ,pr_dspacote IN VARCHAR2
                               ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
        SELECT tp.cdpacote
              ,tp.dspacote
          FROM tbtarif_pacotes_coop tpc
              ,tbtarif_pacotes      tp
         WHERE tp.tppessoa = pr_inpessoa
           AND (tp.cdpacote = pr_cdpacote
            OR nvl(pr_cdpacote, 0) = 0)
           AND upper(tp.dspacote) LIKE upper('%' || pr_dspacote || '%')
           AND tpc.cdcooper = pr_cdcooper
           AND tpc.cdpacote = tp.cdpacote
           AND tpc.flgsituacao = 1
           AND trunc(tpc.dtinicio_vigencia) <= pr_dtmvtolt;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_contador INTEGER := 0; -- Contador p/ posicao no XML
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
      vr_flgresgi BOOLEAN := FALSE;

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Verifica se a cooperativa esta cadastrada
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      FOR rw_pacotes_tarifa IN cr_pacotes_tarifa(vr_cdcooper, rw_crapdat.dtmvtolt, pr_cdpacote, pr_dspacote, pr_inpessoa) LOOP

        vr_contador := vr_contador + 1;

        IF ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados',  pr_posicao  => 0,           pr_tag_nova => 'pacote',   pr_tag_cont => NULL,                                pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pacote', pr_posicao  => vr_auxconta, pr_tag_nova => 'cdpacote', pr_tag_cont => TO_CHAR(rw_pacotes_tarifa.cdpacote), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pacote', pr_posicao  => vr_auxconta, pr_tag_nova => 'dspacote', pr_tag_cont => TO_CHAR(rw_pacotes_tarifa.dspacote), pr_des_erro => vr_dscritic);

          vr_auxconta := vr_auxconta + 1;
        END IF;

        vr_flgresgi := TRUE;

      END LOOP;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Qtdregis',
                             pr_tag_cont => vr_contador,
                             pr_des_erro => vr_dscritic);

      IF NOT vr_flgresgi THEN
        vr_dscritic := 'Nenhum Servico localizado!';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
        pr_dscritic := 'Erro na TELA_ADEPAC.PC_PESQ_PACOTES: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_pesq_pacotes;
  
  /*pesquisa de pacotes de tarifas*/
  PROCEDURE pc_valida_inclusao(pr_cdpacote           IN INTEGER               --> codigo do pacote
                              ,pr_dtdiadebito        IN INTEGER               --> Dia do debito
                              ,pr_perdesconto_manual IN INTEGER               --> % desconto manual
                              ,pr_qtdmeses_desconto  IN INTEGER               --> qtd de meses de desconto
                              ,pr_nrdconta           IN crapass.nrdconta%TYPE --> nr da conta
                              ,pr_xmllog             IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic           OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic           OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo           OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro           OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_valida_inclusao
    Sistema : Cobrança - Cooperativa de Credito
    Sigla   : COB
    Autor   : Lucas Lombardi
    Data    : Abril/16.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Valida dados do formulario de inclusao de pacote.

    Observacao: -----

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      
	    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
		
      -- Busca pacotes de tarifas da conta
      CURSOR cr_tbtarif_contas_pacote (pr_nrdconta IN crapass.nrdconta%TYPE
                                      ,pr_cdpacote IN INTEGER
                                      ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT 1
          FROM tbtarif_contas_pacote
         WHERE nrdconta = pr_nrdconta
           AND cdpacote = pr_cdpacote
           AND cdcooper = pr_cdcooper;
      rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;

      -- Busca dados da cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT permaxde
              ,qtmaxmes
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
			--Busca dados do pacote
			CURSOR cr_dados_pacote (pr_cdcooper IN crapcop.cdcooper%TYPE
														 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
														 ,pr_cdpacote IN INTEGER) IS
				SELECT 1
					FROM tbtarif_pacotes_coop tpc
							,tbtarif_pacotes      tp
				 WHERE tp.tppessoa = (SELECT ass.inpessoa FROM crapass ass WHERE ass.cdcooper = pr_cdcooper
				                                                             AND ass.nrdconta = pr_nrdconta)
					 AND tp.cdpacote = pr_cdpacote
					 AND tpc.cdcooper = pr_cdcooper
					 AND tpc.cdpacote = tp.cdpacote
					 AND tpc.flgsituacao = 1
					 AND trunc(tpc.dtinicio_vigencia) <= pr_dtmvtolt;
      rw_dados_pacote cr_dados_pacote%ROWTYPE;      
			
      --Variaveis gerais
      vr_incluir VARCHAR2(1);
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
    BEGIN
		
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
			-- Verifica se a cooperativa esta cadastrada
			OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

			FETCH btch0001.cr_crapdat
				INTO rw_crapdat;
			-- Se não encontrar
			IF btch0001.cr_crapdat%NOTFOUND THEN
				-- Fechar o cursor pois haverá raise
				CLOSE btch0001.cr_crapdat;
				-- Montar mensagem de critica
				vr_cdcritic := 1;
				RAISE vr_exc_saida;
			ELSE
				-- Apenas fechar o cursor
				CLOSE btch0001.cr_crapdat;

			END IF;
		  
			-- Verificar se existe pacote de tarifas
			OPEN cr_dados_pacote(vr_cdcooper, rw_crapdat.dtmvtolt, pr_cdpacote);
			FETCH cr_dados_pacote INTO rw_dados_pacote;
			IF cr_dados_pacote%NOTFOUND THEN
				vr_dscritic := 'Serviço cooperativo não encontrado.';
				RAISE vr_exc_saida;
			END IF;
			
      -- Verifica se ja existe mesmo pacote cadastrado nessa conta
      OPEN cr_tbtarif_contas_pacote(pr_nrdconta, pr_cdpacote, to_number(vr_cdcooper));
      FETCH cr_tbtarif_contas_pacote INTO rw_tbtarif_contas_pacote;
      -- Se existir não pode preencher desconto manual
      IF cr_tbtarif_contas_pacote%FOUND AND pr_perdesconto_manual > 0 THEN
        vr_dscritic := 'Desconto manual não permitido! Cooperado já efetuou adesão deste serviço anteriormente.';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_tbtarif_contas_pacote;
      
      -- Busca parametros da cooperativa
      OPEN cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%FOUND THEN
        
        IF pr_perdesconto_manual > rw_crapcop.permaxde THEN
          vr_dscritic := 'Percentual de desconto manual excede o limite máximo parametrizado: ' || rw_crapcop.permaxde || '%.';
          RAISE vr_exc_saida;
        END IF;
        IF pr_qtdmeses_desconto > rw_crapcop.qtmaxmes THEN
          vr_dscritic := 'Qtd. de meses de desconto excede o limite máximo parametrizado: ' || rw_crapcop.qtmaxmes || ' meses.';
          RAISE vr_exc_saida;
        END IF;
      ELSE
        vr_dscritic := 'Cooperativa não encontrada!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapcop;
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      
      vr_incluir := 'S';
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'incluir', pr_tag_cont => vr_incluir, pr_des_erro => vr_dscritic);
      
    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
        pr_dscritic := 'Erro na TELA_ADEPAC.PC_VALIDA_INCLUSAO: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_valida_inclusao;
  
  /*Incluir pacote de tarifas*/
  PROCEDURE pc_incluir_pacote(pr_cdpacote           IN INTEGER               --> codigo do pacote
                             ,pr_dtdiadebito        IN INTEGER               --> Dia do debito
                             ,pr_perdesconto_manual IN INTEGER               --> % desconto manual
                             ,pr_qtdmeses_desconto  IN INTEGER               --> qtd de meses de desconto
                             ,pr_nrdconta           IN crapass.nrdconta%TYPE --> nr da conta
                             ,pr_idparame_reciproci IN INTEGER               --> codigo de reciprocidade
                             ,pr_idtipo_autorizacao IN VARCHAR2              --> tipo autorizacao (S=Senha, A=Assinatura)
                             ,pr_xmllog             IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic           OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic           OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml             IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                             ,pr_nmdcampo           OUT VARCHAR2             --> Nome do Campo
                             ,pr_des_erro           OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_incluir_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para incluir pacote de tarifas na conta do cooperado 
                via Ayllos Web
                    
    Alteracoes: 
    ............................................................................. */
    
    -- Busca valor da tarifa
    CURSOR cr_vltarifa (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdpacote IN tbtarif_pacotes_coop.cdpacote%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
      SELECT to_char(fco.vltarifa, 'fm999g999g999g990d00') vltarifa
        FROM tbtarif_pacotes tpac
            ,tbtarif_pacotes_coop tcoop
            ,crapfco fco
            ,crapfvl fvl
       WHERE tcoop.cdcooper = pr_cdcooper
         AND tcoop.cdpacote = pr_cdpacote
         AND tcoop.flgsituacao = 1
         AND tcoop.dtinicio_vigencia <= pr_dtmvtolt
         AND tpac.cdpacote = tcoop.cdpacote 
         AND tpac.tppessoa = pr_inpessoa
         AND fco.cdcooper = tcoop.cdcooper
         AND fco.cdfaixav = fvl.cdfaixav
         AND fco.flgvigen = 1
         AND fvl.cdtarifa = tpac.cdtarifa_lancamento;
    rw_vltarifa cr_vltarifa%ROWTYPE;
    
    -- Busca tipo de pessoa
    CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Cursor genérico de calendário
    rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;
    
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    --Variáveis auxiliares
    vr_existe_pacote      VARCHAR2(1);
    vr_dtinicio_vigencia  DATE;
    vr_idparame_reciproci tbrecip_parame_calculo.idparame_reciproci%TYPE;
    vr_indicador_geral    GENE0002.typ_split;
    vr_indicador_dados    GENE0002.typ_split;
    vr_dstransa           VARCHAR2(1000);
    vr_nrdrowid           ROWID;
    vr_flgfound           BOOLEAN;
    vr_dtass_eletronica   DATE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    vr_tbtarif_pacotes TELA_ADEPAC.typ_tab_tbtarif_pacotes;

  BEGIN
  
    pr_des_erro := 'OK';
  
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
      RAISE vr_exc_erro;
    END IF;
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    -- Pega o primeiro dia do proximo mes
    vr_dtinicio_vigencia := to_date('01/' || to_char(rw_crapdat.dtultdia + 8, 'MM/RRRR'), 'DD/MM/RRRR');
    
    -- Busca tipo de pessoa
    OPEN cr_crapass (vr_cdcooper,pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    vr_flgfound := cr_crapass%FOUND;
    CLOSE cr_crapass;
    
    -- Buscar valor da tarifa
    IF vr_flgfound THEN
      OPEN cr_vltarifa (pr_cdcooper => vr_cdcooper
                       ,pr_cdpacote => pr_cdpacote
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_inpessoa => rw_crapass.inpessoa);
      FETCH cr_vltarifa INTO rw_vltarifa;
      vr_flgfound := cr_vltarifa%FOUND;
      CLOSE cr_vltarifa;
      IF NOT vr_flgfound THEN
				vr_cdcritic := 0;
				vr_dscritic := 'Valor da tarifa não encontrado';
        RAISE vr_exc_erro;
      END IF;
    ELSE
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    
    vr_dstransa := 'Adesão serviços cooperativos';
    
    -- se assinatura for do tipo [S]enha eletronica, preencher a data da assinatura
    IF (UPPER(pr_idtipo_autorizacao) = 'S') THEN
      vr_dtass_eletronica := SYSDATE;
    ELSE
      vr_dtass_eletronica := NULL;
    END IF;

    --Insere novo pacote
    BEGIN
      INSERT INTO tbtarif_contas_pacote (cdcooper
                                        ,nrdconta
                                        ,cdpacote
                                        ,dtadesao
                                        ,dtinicio_vigencia
                                        ,nrdiadebito
                                        ,indorigem
                                        ,flgsituacao
                                        ,perdesconto_manual
                                        ,qtdmeses_desconto
                                        ,cdreciprocidade
                                        ,dtass_eletronica
                                        ,cdoperador_adesao
                                        ,dtcancelamento)
                                VALUES (vr_cdcooper
                                       ,pr_nrdconta
                                       ,pr_cdpacote
                                       ,rw_crapdat.dtmvtolt
                                       ,vr_dtinicio_vigencia
                                       ,pr_dtdiadebito
                                       ,1 -- Ayllos
                                       ,1 -- Ativo
                                       ,pr_perdesconto_manual
                                       ,pr_qtdmeses_desconto
                                       ,pr_idparame_reciproci
                                       ,vr_dtass_eletronica
                                       ,vr_cdoperad
                                       ,NULL);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir novo servico cooperativo. ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Gerar informacoes do log
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    
    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Codigo do servico'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => pr_cdpacote);
    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => rw_vltarifa.vltarifa);
    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Dia do debito'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => pr_dtdiadebito);
    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Inicio da vigencia'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => to_char(vr_dtinicio_vigencia,'DD/MM/RRRR'));

    IF (vr_dtass_eletronica IS NOT NULL) THEN
      -- Gerar informacoes do item
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                              ,pr_nmdcampo => 'Data da assinatura eletronica'
                              ,pr_dsdadant => NULL
                              ,pr_dsdadatu => to_char(vr_dtass_eletronica,'DD/MM/RRRR HH24:MI:SS'));
    END IF;
    
    -- Efetua commit
    COMMIT;
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_INCLUIR_PACOTE: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_incluir_pacote;

  /*Verifica se o pacote esta cancelado*/
  PROCEDURE pc_verif_pct_cancel(pr_cdpacote IN INTEGER               --> codigo do pacote
                               ,pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
                               ,pr_dtadesao IN VARCHAR2              --> data de adesao do pacote
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_verif_pct_cancel
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : verifica de o pacote esta cancelado para o cooperado 
                via Ayllos Web
                    
    Alteracoes: 
    ............................................................................. */
    
    -- Cursor genérico de calendário
    
    CURSOR cr_tbtarif_contas_pacote (pr_nrdconta IN crapass.nrdconta%TYPE
                                    ,pr_cdpacote IN INTEGER
                                    ,pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_dtadesao IN DATE) IS
      SELECT 1
        FROM tbtarif_contas_pacote
       WHERE nrdconta = pr_nrdconta
         AND cdpacote = pr_cdpacote
         AND cdcooper = pr_cdcooper
         AND trunc(dtadesao) = trunc(pr_dtadesao)
         AND dtcancelamento IS NOT NULL;
    rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;
      
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_cancelado VARCHAR2(1);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    vr_tbtarif_pacotes TELA_ADEPAC.typ_tab_tbtarif_pacotes;

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
      RAISE vr_exc_erro;
    END IF;
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    
    -- Verifica se o pacote esta cancelado
    OPEN cr_tbtarif_contas_pacote(pr_nrdconta, pr_cdpacote, vr_cdcooper, to_date(pr_dtadesao, 'DD/MM/RRRR'));
    FETCH cr_tbtarif_contas_pacote INTO rw_tbtarif_contas_pacote;
    IF cr_tbtarif_contas_pacote%FOUND THEN
      vr_cancelado := 'S';
    ELSE
      vr_cancelado := 'N';
    END IF;
    
    pr_des_erro := 'OK';
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cancelado', pr_tag_cont => vr_cancelado, pr_des_erro => vr_dscritic);
      
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_VERIF_PCT_CANCEL: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_verif_pct_cancel;
  
  /*Cancelar pacote de tarifas*/
  PROCEDURE pc_cancela_pacote(pr_cdpacote IN INTEGER               --> codigo do pacote
                             ,pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
                             ,pr_dtadesao IN VARCHAR2              --> data de adesao do pacote
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                             ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_cancela_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Cancela o pacote dxe tarifas do cooperado 
                via Ayllos Web
                    
    Alteracoes: 
    ............................................................................. */
    
    -- Cursor genérico de calendário
    rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;
    
    -- Buscar datas de adesao e cancelamento do pacote
    CURSOR cr_tbtarif_contas_pacote (pr_nrdconta IN crapass.nrdconta%TYPE
                                    ,pr_cdpacote IN INTEGER
                                    ,pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_dtadesao IN DATE) IS
      SELECT dtadesao
            ,dtcancelamento
        FROM tbtarif_contas_pacote
       WHERE nrdconta = pr_nrdconta
         AND cdpacote = pr_cdpacote
         AND cdcooper = pr_cdcooper
         AND trunc(dtadesao) = trunc(pr_dtadesao);
    rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;
      
    --- VARIAVEIS ---
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  crapcri.dscritic%TYPE;
    vr_cancelado VARCHAR2(1);
    vr_dstransa  VARCHAR2(1000);
    vr_nrdrowid ROWID;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(10);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
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
      RAISE vr_exc_erro;
    END IF;
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    
    -- busca dados do pacote
    OPEN cr_tbtarif_contas_pacote(pr_nrdconta, pr_cdpacote, vr_cdcooper, to_date(pr_dtadesao,'DD/MM/RRRR'));
    FETCH cr_tbtarif_contas_pacote INTO rw_tbtarif_contas_pacote;
    IF cr_tbtarif_contas_pacote%FOUND THEN
      -- Verifica se a data de adesão é igual a data do cancelamento
      IF trunc(rw_tbtarif_contas_pacote.dtadesao) = trunc(rw_crapdat.dtmvtolt) THEN
         
         vr_dstransa := 'Cancelamento do servico cooperativo';
      
         -- Se for deleta o registro
         BEGIN
          DELETE FROM tbtarif_contas_pacote
          WHERE cdpacote = pr_cdpacote
            AND nrdconta = pr_nrdconta
            AND cdcooper = vr_cdcooper
            AND trunc(dtadesao) = trunc(to_date(pr_dtadesao,'DD/MM/RRRR'));
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao deletar servico cooperativo.';
          RAISE vr_exc_erro;
        END;
        
        -- Gerar informacoes do log
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => ' '
                            ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'ATENDA'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
														
        -- Gerar informacoes do item
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Codigo do servico'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => to_char(pr_cdpacote));														
        
        -- Gerar informacoes do item
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Data de cancelamento'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR'));
                            
      ELSE
        
        vr_dstransa := 'Cancelamento de servico cooperativo';
                 
        -- Se não for seta a data de cancelamento para o dia atual
        BEGIN
          UPDATE tbtarif_contas_pacote
             SET dtcancelamento = trunc(rw_crapdat.dtmvtolt)
                ,cdoperador_cancela = vr_cdoperad
          WHERE cdpacote = pr_cdpacote
            AND nrdconta = pr_nrdconta
            AND cdcooper = vr_cdcooper
            AND trunc(dtadesao) = trunc(to_date(pr_dtadesao,'DD/MM/RRRR'));
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar pacote de tarifas.';
          RAISE vr_exc_erro;
        END;
        
        -- Gerar informacoes do log
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => ' '
                            ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'ATENDA'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
														
        -- Gerar informacoes do item
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Codigo do servico'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => to_char(pr_cdpacote));														
        
        -- Gerar informacoes do item
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Data de cancelamento'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR'));
        
      END IF;
    END IF;
    
    --Efetua commit
    COMMIT;
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_CANCELA_PACOTE: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_cancela_pacote;

  /*Alterar pacote de tarifas*/
  PROCEDURE pc_altera_debito(pr_cdpacote    IN INTEGER               --> codigo do pacote
                            ,pr_nrdconta    IN crapass.nrdconta%TYPE --> nr da conta
                            ,pr_dtadesao    IN VARCHAR2              --> data de adesao do pacote
                            ,pr_dtdiadebito IN VARCHAR2              --> data de adesao do pacote
                            ,pr_xmllog      IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic    OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic    OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml      IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                            ,pr_nmdcampo    OUT VARCHAR2             --> Nome do Campo
                            ,pr_des_erro    OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_altera_debito
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Altera dia do debito do pacote de tarifas do cooperado 
                via Ayllos Web
                    
    Alteracoes: 
    ............................................................................. */
    
    CURSOR cr_tbtarif_contas_pacote (pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE
                                    ,pr_cdpacote IN tbtarif_contas_pacote.cdpacote%TYPE
                                    ,pr_dtadesao IN VARCHAR2) IS
      SELECT nrdiadebito
        FROM tbtarif_contas_pacote
       WHERE cdpacote = pr_cdpacote
         AND nrdconta = pr_nrdconta
         AND cdcooper = pr_cdcooper
         AND trunc(dtadesao) = trunc(to_date(pr_dtadesao,'DD/MM/RRRR'));
    rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;
    
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_cancelado VARCHAR2(1);
    vr_dstransa  VARCHAR2(1000);
    vr_nrdrowid  ROWID;
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
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
      RAISE vr_exc_erro;
    END IF;
    
    OPEN cr_tbtarif_contas_pacote(vr_cdcooper, pr_nrdconta, pr_cdpacote, pr_dtadesao);
    FETCH cr_tbtarif_contas_pacote INTO rw_tbtarif_contas_pacote;
    
    vr_dstransa := 'Alteracao do dia do debito do servico cooperativo.';
    
    -- Se não for seta a data de cancelamento para o dia atual
    BEGIN
      UPDATE tbtarif_contas_pacote
         SET nrdiadebito = pr_dtdiadebito
       WHERE cdpacote = pr_cdpacote
         AND nrdconta = pr_nrdconta
         AND cdcooper = vr_cdcooper
         AND trunc(dtadesao) = trunc(to_date(pr_dtadesao,'DD/MM/RRRR'));
    EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := 'Erro ao alterar servico cooperativo.';
      RAISE vr_exc_erro;
    END;
    
    -- Gerar informacoes do log
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
        
    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Codigo do servico'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => pr_cdpacote);

    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Dia do debito'
                             ,pr_dsdadant => rw_tbtarif_contas_pacote.nrdiadebito
                             ,pr_dsdadatu => pr_dtdiadebito);
    CLOSE cr_tbtarif_contas_pacote;
    
    --Efetua commit
    COMMIT;
      
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados><Resultado>OK</Resultado></Dados></Root>');

    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_CANCELA_PACOTE: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_altera_debito;
  
  /*Imprime extrato de reciprocidade*/
  PROCEDURE pc_extrato_reciproci(pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
		                            ,pr_dtadesao IN VARCHAR2              --> Data de adesão
                                ,pr_mesrefer IN VARCHAR2
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_extrato_reciproci
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Gera relatorio de extrato de reciprocidade via Ayllos Web
                    
    Alteracoes: 
    ............................................................................. */
    
    --Busca dados do pacote
    CURSOR cr_dados_pacote (pr_nrdconta IN crapass.nrdconta%TYPE
                           ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
     SELECT (to_char(tp.cdpacote,'000') || ' - ' || gene0007.fn_caract_acento(tp.dspacote)) dspacote
           ,tcp.cdreciprocidade
           ,tp.cdtarifa_lancamento
           ,tcp.perdesconto_manual
					 ,tcp.dtinicio_vigencia
					 ,tcp.qtdmeses_desconto
					 ,tcp.cdpacote
       FROM tbtarif_contas_pacote tcp
           ,tbtarif_pacotes       tp
      WHERE tcp.nrdconta = pr_nrdconta
        AND tcp.cdcooper = pr_cdcooper
        AND tp.cdpacote = tcp.cdpacote
				AND TRUNC(tcp.dtadesao) = to_date(pr_dtadesao, 'DD/MM/RRRR');
    rw_dados_pacote cr_dados_pacote%ROWTYPE;
    
    --Busca dados da conta
    CURSOR cr_crapass (pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT nmprimtl
            ,inpessoa
        FROM crapass
       WHERE nrdconta = pr_nrdconta
         AND cdcooper = pr_cdcooper;
    rw_crapass cr_crapass%ROWTYPE;
    
    --Buscar dados das tarifas
    CURSOR cr_dados_tarifas (pr_cdcooper           IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta           IN crapass.nrdconta%TYPE
                            ,pr_inpessoa           IN crapass.inpessoa%TYPE
                            ,pr_mesrefer           IN VARCHAR2
                            ,pr_vltarpac           IN NUMBER
														,pr_cdpacote           IN tbtarif_contas_pacote.cdpacote%TYPE) IS
      SELECT ti.idindicador
            ,(to_char(ti.idindicador,'000') || ' - ' || ti.nmindicador) indicador
            ,decode(ti.tpindicador,'A','Adesão','Q','Quantidade','Moeda') tpindicador
            ,decode(ti.tpindicador, 'A', '-', RCIP0001.FN_FORMAT_VALOR_INDICADOR(pr_idindicador => ti.idindicador
                                                                                ,pr_vlaformatar => tpic.vlminimo)) vlminimo
					  ,decode(ti.tpindicador, 'A', '-', RCIP0001.FN_FORMAT_VALOR_INDICADOR(pr_idindicador => ti.idindicador
						                                                                    ,pr_vlaformatar => tpic.vlmaximo)) vlmaximo
						,to_char(tpic.perscore, 'fm990d00') descmax
						,tai.vlrealizado
            ,to_char((tai.perdesconto/100) * pr_vltarpac, 'fm999g999g990d00') vldesconto
        FROM tbrecip_parame_indica_calculo tpic
            ,tbrecip_indicador             ti
            ,tbrecip_apuracao              ta
            ,tbrecip_apuracao_indica       tai
						,tbtarif_contas_pacote         tcp
       WHERE tpic.idparame_reciproci = ta.idconfig_recipro
         AND ti.idindicador = tpic.idindicador
         AND ta.cdcooper = pr_cdcooper
         AND ta.nrdconta = pr_nrdconta
         AND ta.cdproduto = 26
         AND TO_NUMBER(ta.cdchave_produto) = pr_cdpacote
         AND to_char(ta.dtinicio_apuracao, 'MM/RRRR') = pr_mesrefer
         AND tai.idindicador = ti.idindicador
         AND tai.idapuracao_reciproci = ta.idapuracao_reciproci
         AND tcp.cdcooper = ta.cdcooper				 
				 AND tcp.nrdconta = ta.nrdconta
				 AND tcp.cdpacote = pr_cdpacote
				 AND TRUNC(tcp.dtadesao) = to_date(pr_dtadesao, 'DD/MM/RRRR')
		 		 AND tcp.cdreciprocidade = ta.idconfig_recipro;
    
    -- Busca valor da tarifa
		CURSOR cr_crapfco (pr_cdtarifa IN crapfvl.cdtarifa%TYPE
                      ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		  SELECT fco.vltarifa
		   FROM crapfco fco
			     ,crapfvl fvl
			WHERE fco.cdcooper = pr_cdcooper
			  AND fco.flgvigen = 1
				AND fvl.cdtarifa = pr_cdtarifa
				AND fco.cdfaixav = fvl.cdfaixav;
		rw_crapfco cr_crapfco%ROWTYPE;
    
    --- VARIAVEIS ---
    vr_titular         VARCHAR2(1000);
    vr_dspacote        VARCHAR2(1000);
    vr_vltarifa        NUMBER;
    vr_cdtarifa        crapfvl.cdtarifa%TYPE;
    vr_permanual       VARCHAR2(100);
    vr_vlpermanual     NUMBER;
    vr_contador        INTEGER;
    vr_vlrpago         NUMBER;
    vr_xml             CLOB;
    vr_texto_xml       VARCHAR2(32767);
    vr_caminho         VARCHAR2(100);
    vr_nom_arquivo     VARCHAR2(100);
    vr_dtmvtolt        crapdat.dtmvtolt%type;
    vr_comando         VARCHAR2(100);
    vr_nrdrowid        ROWID;
		vr_dtfimvig        DATE;
		vr_dtrefere        DATE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_des_reto VARCHAR2(100);
    vr_tab_erro gene0001.typ_tab_erro;
    
  BEGIN
    
	  --Informa acesso para exibir a formatação correta
	  gene0001.pc_informa_acesso(pr_module => 'TELA_ADEPAC');
	
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
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar a data do movimento
    OPEN  btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Carrega as variáveis
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
    
    --Busca 1º titular da conta
    OPEN cr_crapass (pr_nrdconta, vr_cdcooper);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%FOUND THEN
      vr_titular := rw_crapass.nmprimtl;
    ELSE
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    --Fecha cursor
    CLOSE cr_crapass;
    
    --Busca dados do pacote
    OPEN cr_dados_pacote (pr_nrdconta, vr_cdcooper);
    FETCH cr_dados_pacote INTO rw_dados_pacote;
    IF cr_dados_pacote%FOUND THEN
      vr_dspacote := rw_dados_pacote.dspacote;
      vr_cdtarifa := rw_dados_pacote.cdtarifa_lancamento;
			vr_dtfimvig := add_months(rw_dados_pacote.dtinicio_vigencia, rw_dados_pacote.qtdmeses_desconto);
			vr_dtrefere := to_date('01/' || pr_mesrefer, 'DD/MM/RRRR');			
			IF (vr_dtfimvig > vr_dtrefere)  THEN				
         vr_vlpermanual := nvl(rw_dados_pacote.perdesconto_manual,0);
		  ELSE
				 vr_vlpermanual := 0;
		  END IF;
    ELSE
      vr_dscritic := '';
      RAISE vr_exc_erro;
    END IF;
    --Fecha cursor
    CLOSE cr_dados_pacote;
    
    -- Busca valor da tarifa
    OPEN cr_crapfco (vr_cdtarifa, vr_cdcooper);
    FETCH cr_crapfco INTO rw_crapfco;
    IF cr_crapfco%FOUND THEN
      vr_vltarifa := rw_crapfco.vltarifa;
      vr_vlrpago := vr_vltarifa - (vr_vltarifa * (vr_vlpermanual/100));
      vr_permanual := to_char(vr_vltarifa * (vr_vlpermanual/100),'fm999g999g999g990d00') || ' (' || to_char(vr_vlpermanual, 'fm990d00') || ' %)';
    ELSE
      vr_dscritic := 'Valor da tarifa não cadastrado. Tarifa:  ' || vr_cdtarifa;
      RAISE vr_exc_erro;
    END IF;
    --Fecha Valor
    CLOSE cr_crapfco;
    
    -- Inicializa CLOB XML
    dbms_lob.createtemporary(vr_xml, TRUE);
    dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

    -- Popula XML
    gene0002.pc_escreve_xml(vr_xml,vr_texto_xml,
                           '<?xml version="1.0" encoding="utf-8"?>');
    
    vr_contador := 0;
    
    gene0002.pc_escreve_xml(vr_xml,vr_texto_xml,'<root><registros>');
    
    FOR rw_dados_tarifas IN cr_dados_tarifas (vr_cdcooper
                                             ,pr_nrdconta
                                             ,rw_crapass.inpessoa
                                             ,pr_mesrefer
                                             ,vr_vltarifa
																						 ,rw_dados_pacote.cdpacote) LOOP
																						       
      vr_vlrpago := vr_vlrpago - rw_dados_tarifas.vldesconto;		
			
      gene0002.pc_escreve_xml(vr_xml,vr_texto_xml,
                              '<reg>' ||
                                  '<indicador>'     || rw_dados_tarifas.indicador || '</indicador>' ||
                                  '<tpindicador>'   || rw_dados_tarifas.tpindicador || '</tpindicador>' ||
                                  '<vlminimo>'      || rw_dados_tarifas.vlminimo || '</vlminimo>' ||
                                  '<vlmaximo>'      || rw_dados_tarifas.vlmaximo || '</vlmaximo>' ||
                                  '<descmax>'       || rw_dados_tarifas.descmax || '</descmax>' ||
                                  '<vlrealizado>'   || RCIP0001.fn_format_valor_indicador(rw_dados_tarifas.idindicador,rw_dados_tarifas.vlrealizado) || '</vlrealizado>' ||
                                  '<vldesconto>'    || rw_dados_tarifas.vldesconto || '</vldesconto>' ||
                              '</reg>');
      
      vr_contador := vr_contador + 1;
      
    END LOOP;
    IF vr_contador = 0 THEN
      vr_dscritic := 'Sem movimentação para o período informado.';
      RAISE vr_exc_erro;
    END IF;
		
		-- Se o valor pago for menor que zero, recebeu o máximo de desconto
		IF (vr_vlrpago < 0) THEN
			-- Não tarifa
			vr_vlrpago := 0;
		END IF;
		
    gene0002.pc_escreve_xml(vr_xml,vr_texto_xml,
                           '</registros>' ||
                           '<conta>'           || gene0002.fn_mask_conta(pr_nrdconta) || '</conta>'   ||
                           '<titular> '        || vr_titular || '</titular>' ||
                           '<pacote>'          || vr_dspacote || '</pacote>'  ||
                           '<mes_referencia> ' || pr_mesrefer || '</mes_referencia>' ||
                           '<vltarifa> R$ '    || to_char(vr_vltarifa, 'fm999g999g999g990d00') || '</vltarifa>' ||
                           '<permanual> R$ '   || vr_permanual || '</permanual>' ||
                           '<vlrpago> R$ '     || to_char(vr_vlrpago, 'fm999g999g999g990d00')  || '</vlrpago>' ||
                           '</root>',TRUE);
                           
    vr_caminho := gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			                     ,pr_cdcooper => vr_cdcooper  --> Cooperativa
			                                 ,pr_nmsubdir => 'rl');       --> Raiz

    vr_nom_arquivo := pr_nrdconta || '.' || TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')|| 
		                  '.' || TO_CHAR(SYSTIMESTAMP,'SSSSSFF5') || 'extrato_reciprocidade.pdf';
    
    -- Solicitar impressao
    gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper      --> Cooperativa conectada
                               ,pr_cdprogra  => 'ADEPAC'         --> Programa chamador
                               ,pr_dtmvtolt  => vr_dtmvtolt      --> Data do movimento atual
                               ,pr_dsxml     => vr_xml           --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/root/registros/reg'       --> No base do XML para leitura dos dados
                               ,pr_dsjasper  => 'extrato_reciprocidade.jasper' --> Arquivo de layout do iReport
                               ,pr_dsparams  => NULL             --> Enviar como parametro apenas a agencia
                               ,pr_dsarqsaid => vr_caminho||'/'||vr_nom_arquivo --> Arquivo final com codigo da agencia
                               ,pr_qtcoluna  => 234              --> 132 colunas (Utilizado 234 para apresentar nome completo do relatório)
                               ,pr_flg_impri => 'S'              --> Chamar a impressao (Imprim.p)
                               ,pr_flg_gerar => 'S'              --> gerar na hora
                               ,pr_nmformul  => '132col'         --> Nome do formulario para impress?o
                               ,pr_nrcopias  => 1                --> Numero de copias
                               ,pr_cdrelato  => 715              --> Codigo do Relatorio
                               ,pr_des_erro  => vr_dscritic);    --> Saida com erro
    
    IF vr_dscritic != '' THEN
      RAISE vr_exc_erro;
    END IF;
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_xml);
    dbms_lob.freetemporary(vr_xml);
    
    --Enviar arquivo para Web
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_nmarqpdf => vr_caminho || '/' || vr_nom_arquivo
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);
    --Se ocorreu erro
    IF vr_des_reto = 'NOK' THEN
      --Se tem erro na tabela 
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_dscritic:= 'Erro ao enviar arquivo para web.';  
      END IF; 
      --Sair 
      RAISE vr_exc_erro;
    END IF;
        
    -- Comando para remover arquivo do rl
    vr_comando:= 'rm '||vr_caminho || '/' || vr_nom_arquivo||' 2>/dev/null';

    --Remover Arquivo pre-existente
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_des_reto
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_des_reto = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Gerar informacoes do log
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Geracao do extrato de reciprocidade.'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
        
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nmarquivo', pr_tag_cont => vr_nom_arquivo, pr_des_erro => vr_dscritic);
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_CANCELA_PACOTE: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_extrato_reciproci;
  
  /*Imprime termo de adesao do pacote*/
  PROCEDURE pc_termo_adesao_pacote (pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
                                   ,pr_dtadesao IN VARCHAR2              --> dt da adesao do pacote
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_termo_adesao_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Gera termo de adesao do pacote via Ayllos Web
                    
    Alteracoes: 
    ............................................................................. */
   
    --- VARIAVEIS ---
    vr_titular         VARCHAR2(1000);
    vr_dspacote        VARCHAR2(1000);
    vr_cdreciprocidade tbtarif_contas_pacote.cdreciprocidade%TYPE;
    vr_vltarifa        VARCHAR2(100);
    vr_cdtarifa        crapfvl.cdtarifa%TYPE;
    vr_permanual       VARCHAR2(100);
    vr_vlpermanual     NUMBER;
    vr_contador        INTEGER;
    vr_vlrpago         NUMBER;
    vr_xml             CLOB;
    vr_texto_xml       VARCHAR2(32767);
    vr_caminho         VARCHAR2(100);
    vr_nom_arquivo     VARCHAR2(100);
    vr_dtmvtolt        crapdat.dtmvtolt%type;
    vr_comando         VARCHAR2(100);
    vr_nrdrowid        ROWID;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_des_reto VARCHAR2(100);
    vr_tab_erro gene0001.typ_tab_erro;
    
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
      RAISE vr_exc_erro;
    END IF;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ADEPAC'
                              ,pr_action => null);
    
    tari0002.pc_cabeca_termos_pct_tar(pr_cdcooper => vr_cdcooper
                                     ,pr_dtadesao => pr_dtadesao
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_idseqttl => 1
                                     ,pr_tpdtermo => 1
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_clobxmlc => vr_xml
                                     ,pr_des_erro => vr_des_reto
                                     ,pr_dscritic => vr_dscritic);
																		 
		IF TRIM(vr_dscritic) IS NOT NULL THEN
			RAISE vr_exc_erro;
		END IF;
    
    vr_caminho := gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			                     ,pr_cdcooper => vr_cdcooper  --> Cooperativa
			                                 ,pr_nmsubdir => 'rl');       --> Raiz
        
    
    vr_nom_arquivo := pr_nrdconta || '.' || TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')|| 
		                  '.' || TO_CHAR(SYSTIMESTAMP,'SSSSSFF5') || 'termo_adesao_pct_tarifas.pdf';
    
    -- Solicitar impressao
    gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper      --> Cooperativa conectada
                               ,pr_cdprogra  => 'ADEPAC'         --> Programa chamador
                               ,pr_dtmvtolt  => vr_dtmvtolt      --> Data do movimento atual
                               ,pr_dsxml     => vr_xml           --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/cabecalho'       --> No base do XML para leitura dos dados
                               ,pr_dsjasper  => 'termo_adesao_pct_tarifas.jasper' --> Arquivo de layout do iReport
                               ,pr_dsparams  => NULL             --> Enviar como parametro apenas a agencia
                               ,pr_dsarqsaid => vr_caminho||'/'||vr_nom_arquivo --> Arquivo final com codigo da agencia
                               ,pr_qtcoluna  => 80               --> 132 colunas
                               ,pr_flg_impri => 'S'              --> Chamar a impressao (Imprim.p)
                               ,pr_flg_gerar => 'S'              --> gerar na hora
                               ,pr_nmformul  => '80col'          --> Nome do formulario para impress?o
                               ,pr_nrcopias  => 1                --> Numero de copias
                               ,pr_cdrelato  => 717              --> Codigo do Relatorio
                               ,pr_des_erro  => vr_dscritic);    --> Saida com erro
    
    IF vr_dscritic != '' THEN
      RAISE vr_exc_erro;
    END IF; 
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_xml);
    dbms_lob.freetemporary(vr_xml);
    
    --Enviar arquivo para Web
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_nmarqpdf => vr_caminho || '/' || vr_nom_arquivo
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);
    --Se ocorreu erro
    IF vr_des_reto = 'NOK' THEN
      --Se tem erro na tabela 
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_dscritic:= 'Erro ao enviar arquivo para web.';  
      END IF; 
      --Sair 
      RAISE vr_exc_erro;
    END IF;
        
    -- Comando para remover arquivo do rl
    vr_comando:= 'rm '||vr_caminho || '/' || vr_nom_arquivo||' 2>/dev/null';

    --Remover Arquivo pre-existente
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_des_reto
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_des_reto = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;
    
    
    -- Gerar informacoes do log
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Geracao do termo de adesao do servico cooperativo.'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nmarquivo', pr_tag_cont => vr_nom_arquivo, pr_des_erro => vr_dscritic);
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_TERMO_ADESAO_PACOTE: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_termo_adesao_pacote;
  
  /*Imprime termo cancelamento do pacote*/
  PROCEDURE pc_termo_cancela_pacote (pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
                                    ,pr_dtadesao IN VARCHAR2              --> dt da adesao do pacote
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_termo_cancela_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Gera termo cancelamento do pacote via Ayllos Web
                    
    Alteracoes: 
    ............................................................................. */
   
    --- VARIAVEIS ---
    vr_titular         VARCHAR2(1000);
    vr_dspacote        VARCHAR2(1000);
    vr_cdreciprocidade tbtarif_contas_pacote.cdreciprocidade%TYPE;
    vr_vltarifa        VARCHAR2(100);
    vr_cdtarifa        crapfvl.cdtarifa%TYPE;
    vr_permanual       VARCHAR2(100);
    vr_vlpermanual     NUMBER;
    vr_contador        INTEGER;
    vr_vlrpago         NUMBER;
    vr_xml             CLOB;
    vr_texto_xml       VARCHAR2(32767);
    vr_caminho         VARCHAR2(100);
    vr_nom_arquivo     VARCHAR2(100);
    vr_dtmvtolt        crapdat.dtmvtolt%type;
    vr_comando         VARCHAR2(100);
    vr_nrdrowid        ROWID;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_des_reto VARCHAR2(100);
    vr_tab_erro gene0001.typ_tab_erro;
    
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
      RAISE vr_exc_erro;
    END IF;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ADEPAC'
                              ,pr_action => null);
    
    tari0002.pc_cabeca_termos_pct_tar(pr_cdcooper => vr_cdcooper
                                     ,pr_dtadesao => pr_dtadesao
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_tpdtermo => 2
                                     ,pr_idseqttl => 1
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_clobxmlc => vr_xml
                                     ,pr_des_erro => vr_des_reto
                                     ,pr_dscritic => vr_dscritic);
																		 
		IF TRIM(vr_dscritic) IS NOT NULL THEN
			RAISE vr_exc_erro;
		END IF;																		 
    
    vr_caminho := gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			                     ,pr_cdcooper => vr_cdcooper  --> Cooperativa
			                                 ,pr_nmsubdir => 'rl');       --> Raiz    
    
    vr_nom_arquivo := pr_nrdconta || '.' || TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')|| 
		                  '.' || TO_CHAR(SYSTIMESTAMP,'SSSSSFF5') || 'termo_cancela_pct_tarifas.pdf';
    
    -- Solicitar impressao
    gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper      --> Cooperativa conectada
                               ,pr_cdprogra  => 'ADEPAC'         --> Programa chamador
                               ,pr_dtmvtolt  => vr_dtmvtolt      --> Data do movimento atual
                               ,pr_dsxml     => vr_xml           --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/cabecalho'       --> No base do XML para leitura dos dados
                               ,pr_dsjasper  => 'termo_cancela_pct_tarifas.jasper' --> Arquivo de layout do iReport
                               ,pr_dsparams  => NULL             --> Enviar como parametro apenas a agencia
                               ,pr_dsarqsaid => vr_caminho||'/'||vr_nom_arquivo --> Arquivo final com codigo da agencia
                               ,pr_qtcoluna  => 80               --> 132 colunas
                               ,pr_flg_impri => 'S'              --> Chamar a impressao (Imprim.p)
                               ,pr_flg_gerar => 'S'              --> gerar na hora
                               ,pr_nmformul  => '80col'          --> Nome do formulario para impress?o
                               ,pr_nrcopias  => 1                --> Numero de copias
                               ,pr_cdrelato  => 718              --> Codigo do Relatorio
                               ,pr_des_erro  => vr_dscritic);    --> Saida com erro
    
    IF vr_dscritic != '' THEN
      RAISE vr_exc_erro;
    END IF; 
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_xml);
    dbms_lob.freetemporary(vr_xml);
    
    --Enviar arquivo para Web
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_nmarqpdf => vr_caminho || '/' || vr_nom_arquivo
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);
    --Se ocorreu erro
    IF vr_des_reto = 'NOK' THEN
      --Se tem erro na tabela 
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_dscritic:= 'Erro ao enviar arquivo para web.';  
      END IF; 
      --Sair 
      RAISE vr_exc_erro;
    END IF;
        
    -- Comando para remover arquivo do rl
    vr_comando:= 'rm '||vr_caminho || '/' || vr_nom_arquivo||' 2>/dev/null';

    --Remover Arquivo pre-existente
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_des_reto
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_des_reto = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;
    
    
    -- Gerar informacoes do log
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Geracao do termo de cancelamento do servico.'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nmarquivo', pr_tag_cont => vr_nom_arquivo, pr_des_erro => vr_dscritic);
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_CANCELA_PACOTE: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_termo_cancela_pacote;
  
  /*Imprime indicadores de reciprocidade*/
  PROCEDURE pc_indicadores_reciproci(pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
		                                ,pr_dtadesao IN VARCHAR2                  --> Data de adesão
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_indicadores_reciproci
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Gera relatorio de indicadores de reciprocidade via Ayllos Web
                    
    Alteracoes: 
    ............................................................................. */
    
    --Busca dados do pacote
    CURSOR cr_dados_pacote (pr_nrdconta IN crapass.nrdconta%TYPE
                           ,pr_cdcooper IN crapcop.cdcooper%TYPE
													 ,pr_dtadesao IN DATE) IS
     SELECT (to_char(tp.cdpacote,'000') || ' - ' || gene0007.fn_caract_acento(tp.dspacote)) dspacote
           ,tcp.cdreciprocidade
           ,tp.cdtarifa_lancamento
       FROM tbtarif_contas_pacote tcp
           ,tbtarif_pacotes       tp
      WHERE tcp.nrdconta = pr_nrdconta
        AND tcp.cdcooper = pr_cdcooper
        AND tp.cdpacote = tcp.cdpacote
				AND TRUNC(tcp.dtadesao) = pr_dtadesao;
    rw_dados_pacote cr_dados_pacote%ROWTYPE;
    
    --Busca dados da conta
    CURSOR cr_crapass (pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT nmprimtl
        FROM crapass
       WHERE nrdconta = pr_nrdconta
         AND cdcooper = pr_cdcooper;
    rw_crapass cr_crapass%ROWTYPE;
    
    --Buscar dados das tarifas
    CURSOR cr_indicadores (pr_idparame_reciproci IN INTEGER) IS
      SELECT (to_char(ti.idindicador,'000') || ' - ' || ti.nmindicador) indicador
            ,decode(ti.tpindicador,'A','Adesão','Q','Quantidade','Moeda') tpindicador
						,decode(ti.tpindicador, 'A', '-', RCIP0001.FN_FORMAT_VALOR_INDICADOR(pr_idindicador => ti.idindicador
                                                                                ,pr_vlaformatar => tpic.vlminimo)) vlminimo
					  ,decode(ti.tpindicador, 'A', '-', RCIP0001.FN_FORMAT_VALOR_INDICADOR(pr_idindicador => ti.idindicador
						                                                                    ,pr_vlaformatar => tpic.vlmaximo)) vlmaximo
						,to_char(tpic.perscore, 'fm990d00') descmax
        FROM tbrecip_parame_indica_calculo tpic
            ,tbrecip_indicador             ti
       WHERE tpic.idparame_reciproci = pr_idparame_reciproci
         AND ti.idindicador = tpic.idindicador;
       
    
    --- VARIAVEIS ---
    vr_titular         VARCHAR2(1000);
    vr_dspacote        VARCHAR2(1000);
    vr_cdreciprocidade tbtarif_contas_pacote.cdreciprocidade%TYPE;
    vr_vltarifa        VARCHAR2(100);
    vr_cdtarifa        crapfvl.cdtarifa%TYPE;
    vr_permanual       VARCHAR2(100);
    vr_vlpermanual     NUMBER;
    vr_contador        INTEGER;
    vr_vlrpago         NUMBER;
    vr_xml             CLOB;
    vr_texto_xml       VARCHAR2(32767);
    vr_caminho         VARCHAR2(100);
    vr_nom_arquivo     VARCHAR2(100);
    vr_dtmvtolt        crapdat.dtmvtolt%type;
    vr_comando         VARCHAR2(100);
    vr_vlminimo        VARCHAR2(100);
    vr_vlmaximo        VARCHAR2(100);
    vr_nrdrowid        ROWID;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_des_reto VARCHAR2(100);
    vr_tab_erro gene0001.typ_tab_erro;
    
  BEGIN
    
	  --Informa acesso para exibir a formatação correta
	  gene0001.pc_informa_acesso(pr_module => 'TELA_ADEPAC');
	
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
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar a data do movimento
    OPEN  btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Carrega as variáveis
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
    
    --Busca 1º titular da conta
    OPEN cr_crapass (pr_nrdconta, vr_cdcooper);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%FOUND THEN
      vr_titular := rw_crapass.nmprimtl;
    ELSE
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    --Fecha cursor
    CLOSE cr_crapass;
    
    --Busca dados do pacote
    OPEN cr_dados_pacote (pr_nrdconta, vr_cdcooper, TO_DATE(pr_dtadesao, 'DD/MM/RRRR'));
    FETCH cr_dados_pacote INTO rw_dados_pacote;
    IF cr_dados_pacote%FOUND THEN
      vr_dspacote := rw_dados_pacote.dspacote;
      vr_cdreciprocidade := rw_dados_pacote.cdreciprocidade;
      vr_cdtarifa := rw_dados_pacote.cdtarifa_lancamento;
    ELSE
      vr_dscritic := '';
      RAISE vr_exc_erro;
    END IF;
    --Fecha cursor
    CLOSE cr_dados_pacote;
    
    -- Inicializa CLOB XML
    dbms_lob.createtemporary(vr_xml, TRUE);
    dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

    -- Popula XML
    gene0002.pc_escreve_xml(vr_xml,vr_texto_xml,
                           '<?xml version="1.0" encoding="utf-8"?>');
    
    gene0002.pc_escreve_xml(vr_xml,vr_texto_xml,'<root><registros>');
    
    FOR rw_indicadores IN cr_indicadores(vr_cdreciprocidade) LOOP
            
      gene0002.pc_escreve_xml(vr_xml,vr_texto_xml,
                              '<reg>' ||
                                  '<indicador>'     || rw_indicadores.indicador || '</indicador>' ||
                                  '<tpindicador>'   || rw_indicadores.tpindicador || '</tpindicador>' ||
                                  '<vlminimo>'      || rw_indicadores.vlminimo || '</vlminimo>' ||
                                  '<vlmaximo>'      || rw_indicadores.vlmaximo || '</vlmaximo>' ||
                                  '<descmax>'       || rw_indicadores.descmax || '</descmax>' ||
                              '</reg>');
      
    END LOOP;
    
    gene0002.pc_escreve_xml(vr_xml,vr_texto_xml,
                           '</registros>' ||
                           '<conta>'      || gene0002.fn_mask_conta(pr_nrdconta) || '</conta>'   ||
                           '<titular>'    || vr_titular || '</titular>' ||
                           '<pacote>'     || vr_dspacote || '</pacote>'  ||
                           '</root>',TRUE);
                           
    vr_caminho := gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			                     ,pr_cdcooper => vr_cdcooper  --> Cooperativa
			                                 ,pr_nmsubdir => 'rl');       --> Raiz
    
    vr_nom_arquivo := pr_nrdconta || '.' || TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')|| 
		                  '.' || TO_CHAR(SYSTIMESTAMP,'SSSSSFF5') || 'indicadores_reciprocidade.pdf';
    
    -- Solicitar impressao
    gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper      --> Cooperativa conectada
                               ,pr_cdprogra  => 'ADEPAC'         --> Programa chamador
                               ,pr_dtmvtolt  => vr_dtmvtolt      --> Data do movimento atual
                               ,pr_dsxml     => vr_xml           --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/root/registros/reg'       --> No base do XML para leitura dos dados
                               ,pr_dsjasper  => 'indicadores_reciprocidade.jasper' --> Arquivo de layout do iReport
                               ,pr_dsparams  => NULL             --> Enviar como parametro apenas a agencia
                               ,pr_dsarqsaid => vr_caminho||'/'||vr_nom_arquivo --> Arquivo final com codigo da agencia
                               ,pr_qtcoluna  => 234              --> 132 colunas (Utilizado 234 para apresentar nome completo do relatório)
                               ,pr_flg_impri => 'S'              --> Chamar a impressao (Imprim.p)
                               ,pr_flg_gerar => 'S'              --> gerar na hora
                               ,pr_nmformul  => '132col'         --> Nome do formulario para impress?o
                               ,pr_nrcopias  => 1                --> Numero de copias
                               ,pr_cdrelato  => 716              --> Codigo do Relatorio
                               ,pr_des_erro  => vr_dscritic);    --> Saida com erro
    
    IF vr_dscritic != '' THEN
      RAISE vr_exc_erro;
    END IF;
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_xml);
    dbms_lob.freetemporary(vr_xml);
    
    --Enviar arquivo para Web
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_nmarqpdf => vr_caminho || '/' || vr_nom_arquivo
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);
    --Se ocorreu erro
    IF vr_des_reto = 'NOK' THEN
      --Se tem erro na tabela 
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_dscritic:= 'Erro ao enviar arquivo para web.';  
      END IF; 
      --Sair 
      RAISE vr_exc_erro;
    END IF;
        
    -- Comando para remover arquivo do rl
    vr_comando:= 'rm '||vr_caminho || '/' || vr_nom_arquivo||' 2>/dev/null';

    --Remover Arquivo pre-existente
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_des_reto
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_des_reto = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Gerar informacoes do log
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Geracao do relatorio  de indicadores de reciprocidade do servico cooperativo.'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nmarquivo', pr_tag_cont => vr_nom_arquivo, pr_des_erro => vr_dscritic);
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_CANCELA_PACOTE: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_indicadores_reciproci;
  
  /*Busca descrição do pacote*/
  PROCEDURE pc_busca_pacote(pr_cdpacote IN INTEGER               --> codigo do pacote
                           ,pr_inpessoa IN crapass.inpessoa%TYPE --> Tipo de pessoa
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Busca descrição do pacote via Ayllos Web
                    
    Alteracoes: 
    ............................................................................. */
    
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    --Busca dados do pacote
    CURSOR cr_dados_pacote (pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                           ,pr_cdpacote IN INTEGER
                           ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
      SELECT tp.dspacote
        FROM tbtarif_pacotes_coop tpc
            ,tbtarif_pacotes      tp
       WHERE tp.tppessoa = pr_inpessoa
         AND (tp.cdpacote = pr_cdpacote
          OR nvl(pr_cdpacote, 0) = 0)
         AND tpc.cdcooper = pr_cdcooper
         AND tpc.cdpacote = tp.cdpacote
         AND tpc.flgsituacao = 1
         AND trunc(tpc.dtinicio_vigencia) <= pr_dtmvtolt;
         
    rw_dados_pacote cr_dados_pacote%ROWTYPE;
    
    --- VARIAVEIS ---
    vr_dspacote        VARCHAR2(1000);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
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
      RAISE vr_exc_erro;
    END IF;
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    OPEN cr_dados_pacote(vr_cdcooper, rw_crapdat.dtmvtolt, pr_cdpacote, pr_inpessoa);
    FETCH cr_dados_pacote INTO rw_dados_pacote;
    IF cr_dados_pacote%FOUND THEN
      vr_dspacote := rw_dados_pacote.dspacote;
    ELSE
      vr_dscritic := 'Serviço Cooperativo não encontrado.';
      RAISE vr_exc_erro;
    END IF;

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados><dspacote>' || vr_dspacote || '</dspacote></Dados>');
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_ADEPAC.PC_CANCELA_PACOTE: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_busca_pacote;
  
END TELA_ADEPAC;
/
