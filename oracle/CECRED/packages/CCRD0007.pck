CREATE OR REPLACE PACKAGE CECRED."CCRD0007" is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : CCRD0007
      Sistema  : Rotinas de Cartões de Crédito/Débito que utilizam comunicação com o BANCOOB
      Sigla    : CCRD
      Autor    : Paulo Roberto da Silva - Supero
      Data     : Fevereiro/2018.                   Ultima atualizacao: 23/07/2018

      Dados referentes ao programa:

      Objetivo  : Para solicitações e alterações de limites de credito de cartões utilizar a comunicação com o Bancoob.

      Alteracoes: 23/07/2018 - Alteração na funcao fn_usa_bancoob_ws. Projeto 345(Lombardi).

  ---------------------------------------------------------------------------------------------------------------*/

  --> Verificar se usa o motor de credito para cartao
  FUNCTION fn_usa_motor_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN;

  --> Verificar se usa o esteira de credito para cartao
  FUNCTION fn_usa_esteira_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN;

  --> Verificar se usa o conexao bancoob via WS para solicitacao e alteracao de limite
  FUNCTION fn_usa_bancoob_ws(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_tpoperac IN VARCHAR2 DEFAULT 'S') RETURN BOOLEAN;

  --> Carregar parametros para uso na comunicacao com o Bancoob
  PROCEDURE pc_carrega_param_bancoob(pr_cdcooper       IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                     pr_tipo_ws        IN PLS_INTEGER,            --> Tipo WS
                                     pr_host           OUT VARCHAR2,              --> Host do Bancoob
                                     pr_recurso        OUT VARCHAR2,              --> URI da Bancoob
                                     pr_method         OUT VARCHAR2,              --> Method para requisicao
                                     pr_usrkey         OUT VARCHAR2,              --> Usuario para autenticacao no WS
                                     pr_dsdirlog       OUT VARCHAR2,              --> Diretorio de log dos arquivos
                                     pr_dscritic       OUT VARCHAR2);

  --> Rotina responsavel em enviar dos dados para o Bancoob
  PROCEDURE pc_enviar_bancoob ( pr_cdcooper    IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                pr_cdagenci    IN crapage.cdagenci%TYPE,  --> Codigo da agencia
                                pr_cdoperad    IN crapope.cdoperad%TYPE,  --> codigo do operador
                                pr_cdorigem    IN INTEGER,                --> Origem da operacao
                                pr_nrdconta    IN crawcrd.nrdconta%TYPE,  --> Numero da conta do cooperado
                                pr_nrctrcrd    IN crawcrd.nrctrcrd%TYPE,  --> Numero da proposta de cartão
                                pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE,  --> Data do movimento
                                pr_comprecu    IN VARCHAR2,               --> Complemento do recuros da URI
                                pr_dsmetodo    IN VARCHAR2,               --> Descricao do metodo
                                pr_conteudo    IN CLOB,                   --> Conteudo no Json para comunicacao
                                pr_dsoperacao  IN VARCHAR2,               --> Operacao realizada
                                pr_tipo_ws     IN PLS_INTEGER,            --> Tipo de WS Bancoob
                                pr_obj_get     IN JSON default null,      --> Json para envio GET
                                pr_dsprotocolo OUT VARCHAR2,              --> Protocolo retornado na requisição
                                pr_dscritic    OUT VARCHAR2,              --> Descrição da Crítica
                                pr_des_mensagem OUT VARCHAR2);            --> Mensagem de retorno

  --> Rotina responsável por criar o jason para envio ao Bancoob
  PROCEDURE pc_gera_json_bancoob (pr_cdcooper   IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                 ,pr_nrdconta   IN crawcrd.nrdconta%TYPE   --> Número da conta
                                 ,pr_nrctrcrd   IN crawcrd.nrctrcrd%TYPE   --> Número da proposta do cartão
                                 ---- OUT ----
                                 ,pr_dsjsonan  OUT NOCOPY json             --> Retorno do clob em modelo json com os dados
                                 ,pr_cdcritic  OUT NUMBER                  --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2);              --> Descricao da critica

  --> Rotina responsavel por solicitar cartão ao Bancoob via PL.
  PROCEDURE pc_solicitar_cartao_bancoob_pl(pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_cdagenci IN crapage.cdagenci%TYPE
                                          ,pr_cdoperad IN crapope.cdoperad%TYPE
                                          ,pr_idorigem IN NUMERIC
                                          ,pr_nrdconta IN crapass.nrdconta%TYPE
                                          ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                          ,pr_dscritic OUT crapcri.dscritic%TYPE);
  
  --> Rotina responsavel por solicitar cartão ao Bancoob
  PROCEDURE pc_solicitar_cartao_bancoob(pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr da conta
                                       ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr do contrato
                                       ,pr_dtmvtolt IN VARCHAR2              --> Data do movimento
                                       ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  --> Rotina responsavel por solicitar cartão ao Bancoob
  PROCEDURE pc_solicitar_cartao_bancoob_wb(pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr da conta
                                          ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr do contrato
                                          ,pr_dtmvtolt IN VARCHAR2              --> Data do movimento
                                          ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);            --> Erros do processo                                       
                                                                              
  --> Rotina para solicitar retorno do Bancoob
  PROCEDURE pc_solicita_retorno_bancoob(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_cdagenci IN crawcrd.cdagenci%TYPE
                                       ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                                       ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE
                                       ,pr_dsprotoc IN tbgen_webservice_aciona.dsprotocolo%TYPE
                                       ,pr_intipret IN VARCHAR2 DEFAULT 'I' --> Tipo de solicitacao de retorno (I - Inclusão de cartao, A - Alteracao de limite)
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2
                                       ,pr_des_mensagem OUT VARCHAR2);          --> Erros do processo

  PROCEDURE pc_solicita_retorno_bancoob_wb(pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                                          ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE
                                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                          
  --Solicita alteração de limite de crédito ao Bancoob
  PROCEDURE pc_alterar_cartao_bancoob(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
                                     ,pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr da conta
                                     ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr da conta
                                     ,pr_idorigem IN VARCHAR2              --> Origem
                                     ,pr_vllimite IN crawcrd.vllimdlr%TYPE --> Novo valor do limite
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequência Titular
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
  
  PROCEDURE pc_alterar_cartao_bancoob_wb(pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr da conta
                                        ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr do contrato
                                        ,pr_vllimite IN crawcrd.vllimdlr%TYPE --> Novo valor do limite
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequência Titular
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
  
  -- Busca sugestao do motor
  PROCEDURE pc_busca_valor_sugerido_motor(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo cooperativa                                        
                                         ,pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr da conta
                                         ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr da proposta
                                         ,pr_dsprotoc IN OUT tbgen_webservice_aciona.dsprotocolo%TYPE --> Protocolo do motor
                                         ,pr_vlsugmot OUT crawcrd.vllimcrd%TYPE --> Valor sugerido pelo motor
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica
END CCRD0007;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CCRD0007 IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : CCRD0007
      Sistema  : Rotinas de Cartões de Crédito/Débito que utilizam comunicação com o Bancoob
      Sigla    : CRED
      Autor    : Paulo Roberto da Silva
      Data     : Fevereiro/2018.                   Ultima atualizacao: 05/04/2019

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Para solicitações e alterações de limites de credito de cartões utilizar a comunicação com o Bancoob.

      Alteracoes: 23/07/2018 - Alteração na funcao fn_usa_bancoob_ws. Projeto 345(Lombardi).
       
                  05/04/2019 - Alterar a situação do cartão pra aprovado quando o bancoob
                               retornar critica na pc_solicita_retorno_bancoob 
                               (Lucas Ranghetti INC0011849)
  ---------------------------------------------------------------------------------------------------------------*/

  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
  SELECT cop.cdcooper
        ,cop.nmrescop
        ,cop.nrtelura
        ,cop.cdbcoctl
        ,cop.cdagectl
        ,cop.dsdircop
        ,cop.cdagebcb
    FROM crapcop cop
   WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Cursor generico de calendario
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  --> Extrair a descricao de critica do json de retorno
  FUNCTION fn_retorna_critica (pr_jsonreto IN VARCHAR2) RETURN VARCHAR2 IS
  /* ..........................................................................

    Programa : fn_retorna_critica
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Paulo Silva - Supero
    Data     : Fevereiro/2018.                   Ultima atualizacao: 23/02/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Extrair a descricao de critica do json de retorno

    Alteração :

  ..........................................................................*/

    vr_obj_retorno   json := json();
    vr_obj_content   json := json();
    vr_dsretorn      VARCHAR2(32000);
    vr_auxctrl       BOOLEAN := FALSE;
    vr_exc_erro      EXCEPTION;
    vr_json          BOOLEAN;
    vr_xml           xmltype;
  BEGIN

    vr_dsretorn := pr_jsonreto;

    --> Transformar texto em objeto json
    LOOP
      BEGIN
        vr_obj_retorno := json(vr_dsretorn);
        vr_json := TRUE; --> Marcar como um json valido
        EXIT;
      EXCEPTION
        WHEN OTHERS THEN
          --> Tentar ajustar json para tentar criar o objeto novamente
          IF vr_auxctrl = FALSE THEN
            vr_auxctrl := TRUE;
            vr_dsretorn := REPLACE(vr_dsretorn,'"StatusMessage"',',"StatusMessage"') ;
            vr_dsretorn := REPLACE(vr_dsretorn,'Bad Request','"Bad Request"') ;
            vr_dsretorn := '{'||vr_dsretorn||'}';
          ELSE
            vr_json := FALSE;
            EXIT;
          END IF;
      END;
    END LOOP;

    IF vr_json THEN
      --> buscar content
      IF vr_obj_retorno.exist('Content') THEN
        -- converter content em objeto
        vr_obj_content := json(vr_obj_retorno.get('Content').to_char());
        --> Extrair a critica encontrada
        RETURN replace(vr_obj_content.get('descricao').to_char(),'"');
      END IF;
    ELSE
      -- Verificar se é um xml(retorno da analise)
      BEGIN
        vr_xml := XMLType.createxml(pr_jsonreto);
        RETURN TRIM(vr_xml.extract('/Dados/inf/msg_detalhe/text()').getstringval());
      EXCEPTION
        WHEN OTHERS THEN
          RAISE vr_exc_erro;
      END;
    END IF;

    -- Senao conseguir extrair critica retorna null
    RETURN NULL;

  EXCEPTION
    -- Senao conseguir extrair critica retorna null
    WHEN vr_exc_erro THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION fn_usa_motor_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN IS
    vr_param varchar2(5);
  BEGIN

    /* Verifica se o motor está em contingencia */
    vr_param := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                          pr_cdcooper => pr_cdcooper,
                                          pr_cdacesso => 'ANALISE_OBRIG_MOTOR_CRD');
    IF (trim(vr_param) = '1')THEN
      RETURN FALSE;
    END IF;

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END;

  FUNCTION fn_usa_esteira_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN IS
    vr_param varchar2(5);
  BEGIN

    /* Verifica se a esteira está em contingencia */
    vr_param := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                          pr_cdcooper => pr_cdcooper,
                                          pr_cdacesso => 'CONTIGENCIA_ESTEIRA_CRD');
    IF (trim(vr_param) = '1')THEN
      RETURN FALSE;
    END IF;

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END;

  FUNCTION fn_usa_bancoob_ws(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_tpoperac IN VARCHAR2 DEFAULT 'S') RETURN BOOLEAN IS
    vr_param varchar2(5);
  BEGIN

    IF pr_tpoperac = 'R' OR pr_tpoperac = 'S' THEN
    /* Verifica se o bancoob está em contingencia */
    vr_param := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                          pr_cdcooper => pr_cdcooper,
                                          pr_cdacesso => 'BANCOOB_WS_CAD_CONTING');
      IF (trim(vr_param) = '0')THEN
        RETURN FALSE;
      END IF;
    END IF;
    
    IF pr_tpoperac = 'R' OR pr_tpoperac = 'L' THEN
      /* Verifica se o bancoob está em contingencia */
      vr_param := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                            pr_cdcooper => pr_cdcooper,
                                            pr_cdacesso => 'BANCOOB_WS_LIM_CONTING');
      IF (trim(vr_param) = '0')THEN
        RETURN FALSE;
      END IF;
    END IF;
    
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END;

  --> Altera situação da solicitação ao Bancoob
  PROCEDURE pc_altera_sit_cartao_bancoob(pr_cdcooper IN crawcrd.cdcooper%TYPE
                                        ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                                        ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE
                                        ,pr_nrseqcrd IN crawcrd.nrseqcrd%TYPE
                                        ,pr_insitcrd IN crawcrd.insitcrd%TYPE
                                        ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE DEFAULT NULL
                                        ,pr_nrcrcard IN crawcrd.nrcrcard%TYPE DEFAULT NULL
                                        ,pr_dscritic OUT VARCHAR2)IS

    BEGIN
      -- Atualiza registro de Proposta de Cartão de Crédito
      UPDATE crawcrd
         SET insitcrd = pr_insitcrd
           , nrseqcrd = nvl(pr_nrseqcrd,nrseqcrd)
           , dtsolici = trunc(SYSDATE)
           , nrcctitg = nvl(pr_nrcctitg, nrcctitg)
           , nrcrcard = nvl(pr_nrcrcard, nrcrcard)
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao atualizar situacao do cartao: '||SQLERRM;
  END pc_altera_sit_cartao_bancoob;
  
  --> Altera situação da alteração do limite de crédito
  --> Altera situação da alteração do limite de crédito
  PROCEDURE pc_altera_limite_proposta(pr_cdcooper IN crawcrd.cdcooper%TYPE
                                     ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                                     ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE
                                     ,pr_vllimite IN crawcrd.vllimcrd%TYPE
                                     ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE
                                     ,pr_idseqttl IN NUMBER
                                     ,pr_dscritic OUT VARCHAR2)IS

  BEGIN
    --Se Titular
    IF pr_idseqttl = 1 THEN
      BEGIN
        UPDATE tbcrd_conta_cartao
           SET vllimite_global = pr_vllimite
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrconta_cartao = pr_nrcctitg;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao atualizar novo limite global da conta cartao: '||SQLERRM;
      END;
      
      BEGIN
        -- Atualiza registro de Proposta de Cartão de Crédito
        UPDATE crawcrd wrd1
           SET wrd1.vllimcrd = pr_vllimite
         WHERE wrd1.cdcooper = pr_cdcooper
           AND wrd1.nrdconta = pr_nrdconta
           AND wrd1.nrcctitg = pr_nrcctitg
           AND wrd1.insitcrd IN (2,3,4)
           AND wrd1.vllimcrd = (SELECT wrd2.vllimcrd
                                  FROM crawcrd wrd2
                                 WHERE wrd2.cdcooper = wrd1.cdcooper
                                   AND wrd2.nrdconta = wrd1.nrdconta
                                   AND wrd2.nrctrcrd = pr_nrctrcrd
                                   AND wrd2.insitcrd IN (2,3,4)
                                   AND wrd2.nrcctitg = wrd1.nrcctitg
                                   AND wrd2.flgprcrd = 1);
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao atualizar novo limite do cartao: '||SQLERRM;
      END;
    ELSE
      BEGIN
        -- Atualiza registro de Proposta de Cartão de Crédito
        UPDATE crawcrd wrd1
           SET wrd1.vllimcrd = pr_vllimite
         WHERE wrd1.cdcooper = pr_cdcooper
           AND wrd1.nrdconta = pr_nrdconta
           AND wrd1.nrcctitg = pr_nrcctitg
           AND wrd1.insitcrd IN (2,3,4)
           AND wrd1.nrctrcrd = pr_nrctrcrd;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao atualizar novo limite do cartao: '||SQLERRM;
      END;
    END IF;
  END pc_altera_limite_proposta;

  --> Carregar parametros para uso na comunicacao com o Bancoob
  PROCEDURE pc_carrega_param_bancoob(pr_cdcooper       IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                     pr_tipo_ws        IN PLS_INTEGER,            --> Tipo WS
                                     pr_host           OUT VARCHAR2,              --> Host do Bancoob
                                     pr_recurso        OUT VARCHAR2,              --> URI da Bancoob
                                     pr_method         OUT VARCHAR2,              --> Method para requisicao
                                     pr_usrkey         OUT VARCHAR2,              --> Usuario para autenticacao no WS
                                     pr_dsdirlog       OUT VARCHAR2,              --> Diretorio de log dos arquivos
                                     pr_dscritic       OUT VARCHAR2) IS


  /* ..........................................................................

    Programa : pc_carrega_param_bancoob
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Paulo Silva - Supero
    Data     : Fevereiro/2018.                   Ultima atualizacao: 26/05/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Carregar parametros para uso na comunicacao com o Bancoob

    Alteração : 26/05/2018 Adequado funcionamento para nova versão WS Bancoob (Anderson).
    
                pr_tipo_ws = 0 - Versão antiga de WS
                pr_tipo_ws = 1 - Solicitação de Cartão
                pr_tipo_ws = 2 - Alteração de Limite Titular
                pr_tipo_ws = 3 - Alteração de Limite Adicional
                pr_tipo_ws = 4 - Consultar Dados do Portador
                pr_tipo_ws = 5 - Consultar Dados do Cartao
				pr_tipo_ws = 6 - Consultar de Protocolo

  ..........................................................................*/
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic NUMBER;

  BEGIN
    /* Se for versão antiga */
    IF pr_tipo_ws = 0 THEN
      --> Buscar hots so webservice do motor
      pr_host := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                            pr_cdcooper => pr_cdcooper,
                                            pr_cdacesso => 'HOST_WEBSRV_BANCOOB');
      IF pr_host IS NULL THEN
        vr_dscritic := 'Parametro HOST_WEBSRV_BANCOOB não encontrado.';
        RAISE vr_exc_erro;
      END IF;

      --> Buscar recurso uri do motor
      pr_recurso := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                               pr_cdcooper => pr_cdcooper,
                                               pr_cdacesso => 'URI_WEBSRV_BANCOOB');

      IF pr_recurso IS NULL THEN
        vr_dscritic := 'Parametro URI_WEBSRV_BANCOOB não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      pr_usrkey := '';
      pr_method  := '';      
    ELSE
       --> Buscar host do webservice
      pr_host := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                            pr_cdcooper => pr_cdcooper,
                                            pr_cdacesso => 'HOST_WEBSRV_BANCOOB_'||Lpad(pr_tipo_ws,2,'0'));
      IF pr_host IS NULL THEN
        vr_dscritic := 'Parametro HOST_WEBSRV_BANCOOB'||Lpad(pr_tipo_ws,2,'0')||' não encontrado.';
        RAISE vr_exc_erro;
      END IF;

      --> Buscar recurso uri do motor
      pr_recurso := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                               pr_cdcooper => pr_cdcooper,
                                               pr_cdacesso => 'URI_WEBSRV_BANCOOB_'||Lpad(pr_tipo_ws,2,'0'));

      IF pr_recurso IS NULL THEN
        vr_dscritic := 'Parametro URI_WEBSRV_BANCOOB'||Lpad(pr_tipo_ws,2,'0')||' não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      
      --> Buscar method do webservice
      pr_method := gene0001.fn_param_sistema  (pr_nmsistem => 'CRED',
                                               pr_cdcooper => pr_cdcooper,
                                               pr_cdacesso => 'MET_WEBSRV_BANCOOB_'||Lpad(pr_tipo_ws,2,'0'));

      IF pr_method IS NULL THEN
        vr_dscritic := 'Parametro MET_WEBSRV_BANCOOB'||Lpad(pr_tipo_ws,2,'0')||' não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      
      --> Buscar method do webservice
      pr_usrkey := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'USR_WEBSRV_BANCOOB_'||Lpad(pr_tipo_ws,2,'0'));

      IF pr_usrkey IS NULL THEN
        vr_dscritic := 'Parametro USR_WEBSRV_BANCOOB'||Lpad(pr_tipo_ws,2,'0')||' não encontrado.';
        RAISE vr_exc_erro;
      END IF;      
    
    END IF;

    --> Buscar diretorio do log
    pr_dsdirlog := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                         pr_cdcooper => 3,
                                         pr_nmsubdir => '/log/webservices' );

  EXCEPTION
    WHEN vr_exc_erro THEN
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel buscar parametros da estira: '||SQLERRM;
  END;

  --> Rotina responsavel em enviar os dados para o Bancoob
  PROCEDURE pc_enviar_bancoob ( pr_cdcooper    IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                pr_cdagenci    IN crapage.cdagenci%TYPE,  --> Codigo da agencia
                                pr_cdoperad    IN crapope.cdoperad%TYPE,  --> codigo do operador
                                pr_cdorigem    IN INTEGER,                --> Origem da operacao
                                pr_nrdconta    IN crawcrd.nrdconta%TYPE,  --> Numero da conta do cooperado
                                pr_nrctrcrd    IN crawcrd.nrctrcrd%TYPE,  --> Numero da proposta de cartão
                                pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE,  --> Data do movimento
                                pr_comprecu    IN VARCHAR2,               --> Complemento do recuros da URI
                                pr_dsmetodo    IN VARCHAR2,               --> Descricao do metodo
                                pr_conteudo    IN CLOB,                   --> Conteudo no Json para comunicacao
                                pr_dsoperacao  IN VARCHAR2,               --> Operacao realizada
                                pr_tipo_ws     IN PLS_INTEGER,
                                pr_obj_get     IN JSON default null,      --> Json para envio GET
                                pr_dsprotocolo OUT VARCHAR2,              --> Protocolo retornado na requisição
                                pr_dscritic    OUT VARCHAR2,
                                pr_des_mensagem OUT VARCHAR2) IS      --> Mensagem de retorno

    --Parametros
    vr_host          VARCHAR2(4000);
    vr_recurso       VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_usrkey        VARCHAR2(200);
    vr_method        VARCHAR2(100);

    vr_dscritic      VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;

    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;

    vr_idacionamento  tbgen_webservice_aciona.idacionamento%TYPE;

    vr_obj     cecred.json := json();

  BEGIN

    -- Carregar parametros para a comunicacao com o Bancoob
    pc_carrega_param_bancoob(pr_cdcooper      => pr_cdcooper,                   -- Codigo da cooperativa
                             pr_tipo_ws       => pr_tipo_ws,
                             pr_host          => vr_host,                       -- Host
                             pr_recurso       => vr_recurso,                    -- URI
                             pr_method        => vr_method,
                             pr_usrkey        => vr_usrkey,
                             pr_dsdirlog      => vr_dsdirlog,                   -- Diretorio de log dos arquivos
                             pr_dscritic      => vr_dscritic);

    IF vr_dscritic  IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Atribuir valores necessarios para comunicacao
    vr_request.service_uri := vr_host;
    vr_request.api_route   := vr_recurso;
    vr_request.method      := vr_method;
    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.headers('User-Key')     := vr_usrkey;
    
    IF vr_method = 'GET' THEN
      /* Melhorar esse processo de envio de parametros get */  
      IF pr_obj_get IS NOT NULL THEN
        IF pr_obj_get.exist('appOrigem') THEN
          vr_request.parameters('appOrigem') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(pr_obj_get.get('appOrigem').to_char(),'"'),'"'),'\u','\')));
        END IF;
        IF pr_obj_get.exist('protocolo') THEN
          vr_request.parameters('protocolo') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(pr_obj_get.get('protocolo').to_char(),'"'),'"'),'\u','\')));
        END IF;
        IF pr_obj_get.exist('numeroCuenta') THEN
          vr_request.parameters('numeroCuenta') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(pr_obj_get.get('numeroCuenta').to_char(),'"'),'"'),'\u','\')));
        END IF;
        IF pr_obj_get.exist('componente') THEN
          vr_request.parameters('componente')   := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(pr_obj_get.get('componente').to_char(),'"'),'"'),'\u','\')));
        END IF;
        IF pr_obj_get.exist('tipoConta') THEN
          vr_request.parameters('tipoConta') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(pr_obj_get.get('tipoConta').to_char(),'"'),'"'),'\u','\')));
        END IF;
        IF pr_obj_get.exist('idUsuario') THEN
          vr_request.parameters('idUsuario') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(pr_obj_get.get('idUsuario').to_char(),'"'),'"'),'\u','\')));
        END IF;      
      END IF;
    ELSE
      vr_request.content := pr_conteudo;
    END IF;	   

    -- Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'
                               ,pr_dscritic          => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      vr_dscritic := 'Nao foi possivel enviar solicitação para o Bancoob.';
    END IF;

    --> Transformar texto em objeto json
    BEGIN
      -- Efetuar cast para JSON
      vr_obj := json(vr_response.content);

      -- Se existe o objeto codRetorno
      IF vr_obj.exist('codRetorno') THEN
         pr_des_mensagem := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('codRetorno').to_char(),'"'),'"'),'\u','\')));
         pr_des_mensagem := pr_des_mensagem || ' - ' || gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('mensagemRetorno').to_char(),'"'),'"'),'\u','\')));
      END IF;

      -- Se existe o objeto de Numero Novidade
      IF vr_obj.exist('numeroNovidade') THEN
         pr_dsprotocolo := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('numeroNovidade').to_char(),'"'),'"'),'\u','\')));
      END IF;
        
      IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
        IF (vr_obj.exist('message')) then
           pr_des_mensagem := vr_response.status_code || ' - ' || gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('message').to_char(),'"'),'"'),'\u','\')));
        END IF;
      END IF;

      --> Gravar dados log acionamento
      este0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                    pr_cdagenci              => pr_cdagenci,
                                    pr_cdoperad              => pr_cdoperad,
                                    pr_cdorigem              => pr_cdorigem,
                                    pr_nrctrprp              => pr_nrctrcrd,
                                    pr_nrdconta              => pr_nrdconta,
                                    pr_tpacionamento         => 1,  /* 1 - Envio, 2 – Retorno */
                                    pr_dsoperacao            => pr_dsoperacao,
                                    pr_dsmetodo              => pr_dsmetodo,
                                    pr_tpproduto             => 4, --Cartão de Crédito
                                    pr_tpconteudo            => 1, --Jason
                                    pr_dsuriservico          => vr_host||'/'||vr_recurso||pr_comprecu,
                                    pr_dtmvtolt              => pr_dtmvtolt,
                                    pr_cdstatus_http         => vr_response.status_code,
                                    pr_dsprotocolo           => pr_dsprotocolo,
                                    pr_dsconteudo_requisicao => pr_conteudo,
                                    pr_dsresposta_requisicao => pr_des_mensagem,
                                    pr_idacionamento         => vr_idacionamento,
                                    pr_dscritic              => vr_dscritic);

      -- Se NÃO conseguiu encontrar Protocolo
      IF pr_dsprotocolo IS NULL THEN
        IF TRIM(vr_dscritic) IS NOT NULL THEN
           vr_dscritic := vr_dscritic||CHR(13)||'Nao foi possivel enviar solicitação ao Bancoob!' || ' ' ||pr_des_mensagem;
           RAISE vr_exc_erro;
        ELSE
          vr_dscritic := 'Nao foi possivel enviar solicitação ao Bancoob!' || ' ' ||pr_des_mensagem;
          RAISE vr_exc_erro;
        END IF;
      ELSE
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;

    -- Pj 438 - Marcelo Telles Coelho - Mouts - 07/04/2019
    -- Startar job de atualização das informações da Tela Única
    IF pr_dscritic IS NULL
--    AND pr_tpenvest <> 'M' -- Não foi chamada para Motor
    THEN
      tela_analise_credito.pc_job_dados_analise_credito(pr_cdcooper  => pr_cdcooper
                                                       ,pr_nrdconta  => pr_nrdconta
                                                       ,pr_tpproduto => 7 -- Cartão de Crédito
                                                       ,pr_nrctremp  => pr_nrctrcrd
                                                       ,pr_dscritic  => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END IF;
    -- Fim Pj 438
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel enviar solicitação ao Bancoob: '||SQLERRM;
  END pc_enviar_bancoob;

  PROCEDURE pc_enviar_bancoob_alt(pr_cdcooper     IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                              pr_cdagenci     IN crapage.cdagenci%TYPE,  --> Codigo da agencia
                              pr_cdoperad     IN crapope.cdoperad%TYPE,  --> codigo do operador
                              pr_cdorigem     IN INTEGER,                --> Origem da operacao
                              pr_nrdconta     IN crawcrd.nrdconta%TYPE,  --> Numero da conta do cooperado
                              pr_nrctrcrd     IN crawcrd.nrctrcrd%TYPE,  --> Numero da proposta de cartão
                              pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE,  --> Data do movimento
                              pr_comprecu     IN VARCHAR2,               --> Complemento do recuros da URI
                              pr_dsmetodo     IN VARCHAR2,               --> Descricao do metodo
                              pr_conteudo     IN CLOB,                   --> Conteudo no Json para comunicacao
                              pr_dsoperacao   IN VARCHAR2,               --> Operacao realizada
                              pr_dsprotocolo  OUT VARCHAR2,              --> Protocolo retornado na requisição
                              pr_obj_conteudo IN OUT NOCOPY JSON,        --> Json com conteudo.
                              pr_dscritic     OUT VARCHAR2,              --> Mensagem de crítica
                              pr_des_mensagem OUT VARCHAR2) IS           --> Mensagem de retorno

    --Parametros
    vr_host           VARCHAR2(4000);
    vr_recurso        VARCHAR2(4000);
    vr_dsdirlog       VARCHAR2(500);
    vr_comprecu       VARCHAR2(500);
    vr_usrkey         VARCHAR2(200);
    vr_method         VARCHAR2(100);

    --Tratamento
    vr_dscritic       VARCHAR2(4000);
    vr_exc_erro       EXCEPTION;

    --Json
    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;
    vr_obj      cecred.json := json();
    
    --Gerais
    vr_idacionamento tbgen_webservice_aciona.idacionamento%TYPE;
    vr_tpacionamento tbgen_webservice_aciona.tpacionamento%TYPE;
    vr_dsprotocolo   tbgen_webservice_aciona.dsprotocolo%TYPE;
    
  BEGIN

    -- Carregar parametros para a comunicacao com o Bancoob
    pc_carrega_param_bancoob(pr_cdcooper      => pr_cdcooper,         -- Codigo da cooperativa
                             pr_tipo_ws       => 0, /* WS Antigo*/
                             pr_host          => vr_host,             -- Host do Bancoob
                             pr_recurso       => vr_recurso,          -- URI do Bancoob
                             pr_method        => vr_method,
                             pr_usrkey        => vr_usrkey,
                             pr_dsdirlog      => vr_dsdirlog    ,     -- Diretorio de log dos arquivos
                             pr_dscritic      => vr_dscritic    );

    IF vr_dscritic  IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Buscar hots so webservice do motor
    vr_comprecu := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                              pr_cdcooper => pr_cdcooper,
                                              pr_cdacesso => pr_comprecu);

    IF vr_comprecu IS NULL THEN
      vr_dscritic := 'Parametro '||pr_comprecu||' não encontrado.';
      RAISE vr_exc_erro;
    END IF;

    -- Atribuir valores necessarios para comunicacao
    vr_request.service_uri := vr_host;
    vr_request.api_route := vr_recurso||vr_comprecu;
    vr_request.method    := pr_dsmetodo;
    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';

    IF pr_dsmetodo = 'POST' THEN
      vr_request.content := pr_conteudo;
      
      vr_tpacionamento := 1; --Envio
    ELSIF pr_dsmetodo = 'GET' THEN
      --> Transformar texto em objeto json
      -- Efetuar cast para JSON
      vr_obj := json(pr_conteudo);
      
      --Armazena Protocolo de Consulta
      IF vr_obj.exist('protocolo') THEN
        vr_dsprotocolo := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('protocolo').to_char(),'"'),'"'),'\u','\')));
      END IF;
      
      vr_tpacionamento := 2; --Retorno
      
      vr_request.timeout     := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_BANCOOB');

      IF pr_comprecu = 'COMPL_URI_SOLIC_RETORNO' THEN --Solicita Retorno Bancoob
        vr_request.parameters('appOrigem') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('appOrigem').to_char(),'"'),'"'),'\u','\')));
        vr_request.parameters('protocolo') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('protocolo').to_char(),'"'),'"'),'\u','\')));
      ELSIF pr_comprecu = 'COMPL_URI_CONSDP_BANCOOB' THEN
        vr_request.parameters('appOrigem')    := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('appOrigem').to_char(),'"'),'"'),'\u','\')));
        vr_request.parameters('numeroCuenta') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('numeroCuenta').to_char(),'"'),'"'),'\u','\')));
        vr_request.parameters('componente')   := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('componente').to_char(),'"'),'"'),'\u','\')));
      ELSIF pr_comprecu = 'COMPL_URI_CONSAD_BANCOOB' THEN
        vr_request.parameters('appOrigem') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('appOrigem').to_char(),'"'),'"'),'\u','\')));
        vr_request.parameters('idUsuario') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('idUsuario').to_char(),'"'),'"'),'\u','\')));
        vr_request.parameters('tipoConta') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('tipoConta').to_char(),'"'),'"'),'\u','\')));
      ELSIF pr_comprecu = 'COMPL_URI_ALTLA_BANCOOB' THEN
        vr_request.parameters('idAdicional') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('idAdicional').to_char(),'"'),'"'),'\u','\')));
        vr_request.parameters('novoLimite') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('novoLimite').to_char(),'"'),'"'),'\u','\')));
        vr_request.parameters('idUsuario') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('idUsuario').to_char(),'"'),'"'),'\u','\')));
        vr_request.parameters('appOrigem') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('appOrigem').to_char(),'"'),'"'),'\u','\')));
        vr_request.parameters('tipoConta') := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('tipoConta').to_char(),'"'),'"'),'\u','\')));
      END IF;
    END IF;

    -- Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'
                               ,pr_dscritic          => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      vr_dscritic := 'Nao foi possivel enviar solicitação para o Bancoob.';
    END IF;

    --> Transformar texto em objeto json
    -- Efetuar cast para JSON
    vr_obj := json(vr_response.content);
    pr_obj_conteudo := vr_obj;

    -- Se existe o objeto codRetorno
    IF vr_obj.exist('codRetorno') THEN
       pr_des_mensagem := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('codRetorno').to_char(),'"'),'"'),'\u','\')));
    END IF;
      
    IF vr_obj.exist('mensagemRetorno') THEN
       pr_des_mensagem := pr_des_mensagem || ' - ' || gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('mensagemRetorno').to_char(),'"'),'"'),'\u','\')));
    END IF;

    -- Se existe o objeto de Numero Novidade
    IF vr_obj.exist('numeroNovidade') THEN
       pr_dsprotocolo := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('numeroNovidade').to_char(),'"'),'"'),'\u','\')));
    END IF;

    --> Gravar dados log acionamento
    este0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                  pr_cdagenci              => pr_cdagenci,
                                  pr_cdoperad              => pr_cdoperad,
                                  pr_cdorigem              => pr_cdorigem,
                                  pr_nrctrprp              => pr_nrctrcrd,
                                  pr_nrdconta              => pr_nrdconta,
                                  pr_tpacionamento         => vr_tpacionamento,
                                  pr_dsoperacao            => pr_dsoperacao,
                                  pr_dsmetodo              => pr_dsmetodo,
                                  pr_tpproduto             => 4, --Cartão de Crédito
                                  pr_tpconteudo            => 1, --Jason
                                  pr_dsuriservico          => vr_host||vr_recurso||vr_comprecu,
                                  pr_dtmvtolt              => pr_dtmvtolt,
                                  pr_cdstatus_http         => vr_response.status_code,
                                  pr_dsprotocolo           => NVL(pr_dsprotocolo,vr_dsprotocolo),
                                  pr_dsconteudo_requisicao => pr_conteudo,
                                  pr_dsresposta_requisicao => pr_des_mensagem,
                                  pr_idacionamento         => vr_idacionamento,
                                  pr_dscritic              => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;
    
    IF pr_dsmetodo = 'POST' THEN
      IF pr_dsprotocolo IS NULL THEN
        vr_dscritic := vr_dscritic||CHR(13)||'Nao foi possivel enviar solicitação ao Bancoob!' || ' ' ||pr_des_mensagem;
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- Pj 438 - Marcelo Telles Coelho - Mouts - 07/04/2019
    -- Startar job de atualização das informações da Tela Única
    IF pr_dscritic IS NULL
--    AND pr_tpenvest <> 'M' -- Não foi chamada para Motor
    THEN
      tela_analise_credito.pc_job_dados_analise_credito(pr_cdcooper  => pr_cdcooper
                                                       ,pr_nrdconta  => pr_nrdconta
                                                       ,pr_tpproduto => 7 -- Cartão de Crédito
                                                       ,pr_nrctremp  => pr_nrctrcrd
                                                       ,pr_dscritic  => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Fim Pj 438

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel enviar solicitação ao Bancoob: '||SQLERRM;
  END pc_enviar_bancoob_alt;

  --> Rotina responsavel em enviar os dados para o Bancoob
  PROCEDURE pc_enviar_bancoob_old ( pr_cdcooper    IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                pr_cdagenci    IN crapage.cdagenci%TYPE,  --> Codigo da agencia
                                pr_cdoperad    IN crapope.cdoperad%TYPE,  --> codigo do operador
                                pr_cdorigem    IN INTEGER,                --> Origem da operacao
                                pr_nrdconta    IN crawcrd.nrdconta%TYPE,  --> Numero da conta do cooperado
                                pr_nrctrcrd    IN crawcrd.nrctrcrd%TYPE,  --> Numero da proposta de cartão
                                pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE,  --> Data do movimento
                                pr_comprecu    IN VARCHAR2,               --> Complemento do recuros da URI
                                pr_dsmetodo    IN VARCHAR2,               --> Descricao do metodo
                                pr_conteudo    IN CLOB,                   --> Conteudo no Json para comunicacao
                                pr_dsoperacao  IN VARCHAR2,               --> Operacao realizada
                                pr_dsprotocolo OUT VARCHAR2,              --> Protocolo retornado na requisição
                                pr_dscritic    OUT VARCHAR2,
                                pr_des_mensagem OUT VARCHAR2) IS      --> Mensagem de retorno

    --Parametros
    vr_host          VARCHAR2(4000);
    vr_recurso       VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_usrkey        VARCHAR2(200);
    vr_method        VARCHAR2(100);

    vr_dscritic      VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;

    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;

    vr_idacionamento  tbgen_webservice_aciona.idacionamento%TYPE;

    vr_obj     cecred.json := json();

  BEGIN

    -- Carregar parametros para a comunicacao com o Bancoob
    pc_carrega_param_bancoob(pr_cdcooper      => pr_cdcooper,                   -- Codigo da cooperativa
                             pr_tipo_ws       => 0, /* WS Antigo */
                             pr_host          => vr_host,                       -- Host
                             pr_recurso       => vr_recurso,                    -- URI
                             pr_method        => vr_method,
                             pr_usrkey        => vr_usrkey,
                             pr_dsdirlog      => vr_dsdirlog,                   -- Diretorio de log dos arquivos
                             pr_dscritic      => vr_dscritic);

    IF vr_dscritic  IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Atribuir valores necessarios para comunicacao
    vr_request.service_uri := vr_host;
    vr_request.api_route := vr_recurso||'/altaDeContaCartao';
    vr_request.method    := pr_dsmetodo;
    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.content := pr_conteudo;

    -- Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'
                               ,pr_dscritic          => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      vr_dscritic := 'Nao foi possivel enviar solicitação para o Bancoob.';
    END IF;

    --> Transformar texto em objeto json
    BEGIN
      -- Efetuar cast para JSON
      vr_obj := json(vr_response.content);

      -- Se existe o objeto codRetorno
      IF vr_obj.exist('codRetorno') THEN
         pr_des_mensagem := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('codRetorno').to_char(),'"'),'"'),'\u','\')));
         pr_des_mensagem := pr_des_mensagem || ' - ' || gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('mensagemRetorno').to_char(),'"'),'"'),'\u','\')));
      END IF;

      -- Se existe o objeto de Numero Novidade
      IF vr_obj.exist('numeroNovidade') THEN
         pr_dsprotocolo := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('numeroNovidade').to_char(),'"'),'"'),'\u','\')));
      END IF;

      --> Gravar dados log acionamento
      este0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                    pr_cdagenci              => pr_cdagenci,
                                    pr_cdoperad              => pr_cdoperad,
                                    pr_cdorigem              => pr_cdorigem,
                                    pr_nrctrprp              => pr_nrctrcrd,
                                    pr_nrdconta              => pr_nrdconta,
                                    pr_tpacionamento         => 1,  /* 1 - Envio, 2 – Retorno */
                                    pr_dsoperacao            => pr_dsoperacao,
                                    pr_dsmetodo              => pr_dsmetodo,
                                    pr_tpproduto             => 4, --Cartão de Crédito
                                    pr_tpconteudo            => 1, --Jason
                                    pr_dsuriservico          => vr_host||vr_recurso||pr_comprecu,
                                    pr_dtmvtolt              => pr_dtmvtolt,
                                    pr_cdstatus_http         => vr_response.status_code,
                                    pr_dsprotocolo           => pr_dsprotocolo,
                                    pr_dsconteudo_requisicao => pr_conteudo,
                                    pr_dsresposta_requisicao => pr_des_mensagem,
                                    pr_idacionamento         => vr_idacionamento,
                                    pr_dscritic              => vr_dscritic);

      -- Se NÃO conseguiu encontrar Protocolo
      IF pr_dsprotocolo IS NULL THEN
        IF TRIM(vr_dscritic) IS NOT NULL THEN
           vr_dscritic := vr_dscritic||CHR(13)||'Nao foi possivel enviar solicitação ao Bancoob!' || ' ' ||pr_des_mensagem;
           RAISE vr_exc_erro;
        ELSE
          vr_dscritic := 'Nao foi possivel enviar solicitação ao Bancoob!' || ' ' ||pr_des_mensagem;
          RAISE vr_exc_erro;
        END IF;
      ELSE
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel enviar solicitação ao Bancoob: '||SQLERRM;
  END pc_enviar_bancoob_old;

  --> Rotina responsável por criar o jason para envio ao Bancoob
  PROCEDURE pc_gera_json_bancoob (pr_cdcooper   IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                 ,pr_nrdconta   IN crawcrd.nrdconta%TYPE   --> Número da conta
                                 ,pr_nrctrcrd   IN crawcrd.nrctrcrd%TYPE   --> Número da proposta do cartão
                                 ---- OUT ----
                                 ,pr_dsjsonan  OUT NOCOPY json             --> Retorno do clob em modelo json com os dados
                                 ,pr_cdcritic  OUT NUMBER                  --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2) IS            --> Descricao da critica

  /* ..........................................................................

      Programa : pc_gera_jason_bancoob
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva - Supero
      Data     : Fevereiro/2018.                   Ultima atualizacao: 23/02/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por montar o objeto json para envio ao Bancoob.

      Alteração :

    ..........................................................................*/

    ------------------------------- CURSORES ---------------------------------
    -- Busca listagem das cooperativas
    CURSOR cr_crapcol (pr_cdcooper crapcol.cdcooper%TYPE) IS
     SELECT cop.cdcooper
           ,cop.cdagectl
           ,cop.cdagebcb
     FROM crapcop cop
    WHERE cop.cdcooper = pr_cdcooper;

    -- Cursor genérico de calendário da Cooperativa em operação
    rw_crapdatc btch0001.cr_crapdat%ROWTYPE;

    -- cursor para busca de proposta de cartões do bancoob por conta
    -- para verificar se é o primeiro cartão bancoob adquirido pela empresa
    -- excluindo a proposta de cartão sendo processada em si
    CURSOR cr_crawcrd_flgprcrd (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE,
                                pr_nmbandei IN crapadc.nmbandei%TYPE) IS
      SELECT pcr.flgprcrd
        FROM crawcrd pcr
           , crapadc adc
       WHERE adc.cdcooper = pcr.cdcooper
         AND adc.cdadmcrd = pcr.cdadmcrd
         AND pcr.cdcooper =  pr_cdcooper
         AND pcr.nrdconta =  pr_nrdconta
         AND(pcr.cdadmcrd >= 10
         AND pcr.cdadmcrd <= 80)
         AND pcr.flgprcrd = 1
         AND pcr.nrctrcrd <> pr_nrctrcrd
         AND adc.nmbandei = pr_nmbandei;
    rw_crawcrd_flgprcrd cr_crawcrd_flgprcrd%ROWTYPE;

    -- cursor para busca de proposta de cartão aprovado e associado
    CURSOR cr_crawcrd (pr_cdcooper1 IN crapcop.cdcooper%TYPE,
                       pr_nrdconta1 IN crawcrd.nrdconta%TYPE,
                       pr_nrctrcrd1 IN crawcrd.nrctrcrd%TYPE) IS
      SELECT pcr.cdcooper
           , pcr.nrdconta
           , pcr.nrctrcrd
           , pcr.flgdebcc
           , pcr.tpdpagto
           , pcr.dddebito
           , pcr.vllimcrd
           , pcr.cdadmcrd
           , pcr.flgprcrd
           , pcr.nrcpftit
           , pcr.nmempcrd
           , pcr.nrcrcard
           , pcr.insitcrd
           , pcr.nmtitcrd
           , pcr.rowid
           , pcr.nrcctitg
           , pcr.cdgraupr
           , pcr.dtnasccr
           , pcr.flgdebit
           , ass.cdagenci
           , ass.nrempcrd
           , ass.inpessoa
           , ass.nrcpfcgc
           , age.cdagebcb
           , pcr.nrseqcrd
        FROM crawcrd pcr
            ,crapass ass
            ,crapage age
     WHERE pcr.cdcooper = pr_cdcooper1
       AND pcr.nrdconta = pr_nrdconta1
       AND pcr.nrctrcrd = pr_nrctrcrd1
       AND pcr.dtcancel IS NULL
       AND (pcr.cdadmcrd >= 10
            AND pcr.cdadmcrd <= 80)
-- Comentei pois não está funcionando adequadamente - Anderson 29/05/2018.
       AND pcr.insitcrd = 1            -- APROVADO
       AND ass.cdcooper = pcr.cdcooper
       AND ass.nrdconta = pcr.nrdconta
       AND ass.dtdemiss IS NULL
       AND age.cdcooper = ass.cdcooper
       AND age.cdagenci = ass.cdagenci
           -- Numero da conta utilizado para nao gerar linha de solicitacao de cartao adiciona quando eh
           -- UPGRADE/DOWNGRADE, DEVE ficar como primeiro campo no ORDER BY (Douglas - Chamado 441407)
     ORDER BY pcr.nrdconta
            , pcr.nrctrcrd;  -- Ordena por conta, para incluir no arquivo as contas agrupadas( Renato - Supero )
    rw_crawcrd cr_crawcrd%ROWTYPE;
/*
    -- cursor para busca de cartões ativos para verificação
    CURSOR cr_crapcrd_loop_alt (pr_cdcooper1 IN crapcop.cdcooper%TYPE,
                                pr_nrdconta1 IN crawcrd.nrdconta%TYPE,
                                pr_nrctrcrd1 IN crawcrd.nrctrcrd%TYPE) IS
      SELECT pcr.cdcooper
           , pcr.nrdconta
           , pcr.nrctrcrd
           , pcr.flgdebcc
           , pcr.tpdpagto
           , pcr.dddebito
           , pcr.vllimcrd
           , pcr.cdadmcrd
           , pcr.flgprcrd
           , pcr.nrcpftit
           , pcr.nmempcrd
           , pcr.nrcrcard
           , pcr.insitcrd
           , pcr.nmtitcrd
           , pcr.rowid
           , pcr.nrcctitg
           , pcr.cdgraupr
           , pcr.dtnasccr
           , pcr.flgdebit
           , ass.cdagenci
           , ass.nrempcrd
           , ass.inpessoa
           , ass.nrcpfcgc
           , age.cdagebcb
           , pcr.nrseqcrd
        FROM crawcrd pcr
            ,crapass ass
            ,crapage age
            ,crapcrd crd
       WHERE pcr.cdcooper = crd.cdcooper
         AND pcr.cdadmcrd = crd.cdadmcrd
         AND pcr.tpcartao = crd.tpcartao
         AND pcr.nrdconta = crd.nrdconta
         AND pcr.nrcrcard = crd.nrcrcard
         AND pcr.nrctrcrd = crd.nrctrcrd
         AND pcr.insitcrd IN (3,4) -- LIBERADOS E EM USO
         AND pcr.flgprcrd = 1 -- retorna apenas registro do cartao titular
         AND ass.cdcooper = pcr.cdcooper
         AND ass.nrdconta = pcr.nrdconta
         AND ass.dtdemiss IS NULL
         AND age.cdcooper = ass.cdcooper
         AND age.cdagenci = ass.cdagenci
         AND crd.dtcancel IS NULL
         AND crd.cdadmcrd BETWEEN 10 AND 80   -- somente o que foi BANCOOB ( MASTER )
         AND crd.cdcooper = pr_cdcooper1
         AND crd.nrdconta = pr_nrdconta1
         AND crd.nrctrcrd = pr_nrctrcrd1;
*/
    -- cursor para cooperado PF
    CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE,
                       pr_nrdconta IN crapttl.nrdconta%TYPE,
                       pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE) IS
    SELECT ttl.idseqttl
          ,ttl.nrcpfcgc
          ,ttl.vlsalari
          ,ttl.cdestcvl
          ,DECODE(ttl.cdsexotl,1,'2',2,'1','0') sexbancoob
          ,ttl.dtnasttl
          ,ttl.nrdocttl
          ,ttl.tpdocttl
          ,ttl.cdufdttl
          ,ttl.idorgexp
          ,ttl.nmextttl
          ,ttl.inpessoa
      FROM crapttl ttl
     WHERE ttl.cdcooper = pr_cdcooper
       AND ttl.nrdconta = pr_nrdconta
       AND ttl.nrcpfcgc = pr_nrcpfcgc;
    rw_crapttl cr_crapttl%ROWTYPE;

    -- cursor para cooperado PJ
    CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE,
                       pr_nrdconta IN crapjur.nrdconta%TYPE) IS
    SELECT jur.dtiniatv
          ,jur.nrinsest
          ,jur.nmextttl
          ,jur.tpregtrb
      FROM crapjur jur
     WHERE jur.cdcooper = pr_cdcooper
       AND jur.nrdconta = pr_nrdconta ;
    rw_crapjur cr_crapjur%ROWTYPE;

    -- cursor para encontrar dados do avalista de PJ
    CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%TYPE,
                       pr_nrdconta IN crapavt.nrdconta%TYPE,
                       pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
    SELECT avt.nrdconta
          ,NVL(ttl.tpdocttl,avt.tpdocava) tpdocava
          ,NVL(ttl.nmextttl,avt.nmdavali) nmdavali
          ,NVL(ttl.cdestcvl,avt.cdestcvl) cdestcvl
          ,avt.nrcpfcgc
          ,NVL(ttl.nrdocttl,avt.nrdocava) nrdocava
          ,NVL(ttl.idorgexp,avt.idorgexp) idorgexp
          ,NVL(ttl.cdufdttl,avt.cdufddoc) cdufddoc
          ,NVL(ttl.dtnasttl,avt.dtnascto) dtnascto
          ,DECODE(NVL(ttl.cdsexotl,avt.cdsexcto),1,'2',2,'1','0') sexbancoob
          ,NVL(ttl.inpessoa,DECODE(avt.inpessoa,0,1,avt.inpessoa)) inpessoa
      FROM crapttl ttl
         , crapavt avt
     WHERE ttl.cdcooper(+) = avt.cdcooper
       AND ttl.nrdconta(+) = avt.nrdctato
       AND avt.tpctrato = 6 -- Contrato pessoa juridica
       AND avt.cdcooper = pr_cdcooper
       AND avt.nrdconta = pr_nrdconta
       AND avt.nrcpfcgc = pr_nrcpfcgc ;
    rw_crapavt cr_crapavt%ROWTYPE;

    -- cursor para adquirir informações da Administradora do Cartão de Crédito
    CURSOR cr_crapadc (pr_cdcooper IN crapadc.cdcooper%TYPE,
                       pr_cdadmcrd IN crapadc.cdadmcrd%TYPE) IS
    SELECT adc.nrctamae
          ,adc.cdclasse
          ,adc.nmbandei
      FROM crapadc adc
     WHERE adc.cdcooper = pr_cdcooper
       AND adc.cdadmcrd = pr_cdadmcrd;
    rw_crapadc     cr_crapadc%ROWTYPE;
    rw_crapadc_crd cr_crapadc%ROWTYPE;

    -- cursor para Grupo de Afinidade
    CURSOR cr_crapacb (pr_cdcooper IN crapacb.cdcooper%TYPE,
                       pr_cdadmcrd IN crapacb.cdadmcrd%TYPE) IS
    SELECT acb.cdgrafin
      FROM crapacb acb
     WHERE acb.cdcooper = pr_cdcooper
       AND acb.cdadmcrd = pr_cdadmcrd;
    rw_crapacb     cr_crapacb%ROWTYPE;

    -- cursor para adquirir telefones do cooperado
    CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%TYPE,
                       pr_nrdconta IN craptfc.nrdconta%TYPE,
                       pr_tptelefo IN craptfc.tptelefo%TYPE) IS
    SELECT tfc.nrtelefo
          ,tfc.nrdddtfc
      FROM craptfc tfc
     WHERE tfc.cdcooper = pr_cdcooper
       AND tfc.nrdconta = pr_nrdconta
       AND tfc.tptelefo = pr_tptelefo;
    rw_craptfc cr_craptfc%ROWTYPE;

    -- cursor para endereco da agencia		
		CURSOR cr_end_agencia(pr_cdcooper IN crapenc.cdcooper%TYPE
											   ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
				SELECT crapage.dsendcop
							,crapage.nrendere
							,crapage.dscomple
							,crapage.nmbairro
							,crapage.nmcidade
							,crapage.cdufdcop
							,crapage.cdagenci
							,crapage.idcidade
							,crapage.nrcepend
							,crapage.dsendcop||decode(crapage.nrendere,0,null,','||crapage.nrendere) dsender_compl
					FROM crapage
				 WHERE crapage.cdcooper = pr_cdcooper
					 AND crapage.cdagenci = pr_cdagenci;
		rw_end_agencia cr_end_agencia%ROWTYPE;
		
		CURSOR cr_endereco_entrega(pr_cdcooper IN tbcrd_endereco_entrega.cdcooper%TYPE,
                               pr_nrdconta IN tbcrd_endereco_entrega.nrdconta%TYPE,
															 pr_nrctrcrd IN tbcrd_endereco_entrega.nrctrcrd%TYPE) IS
			SELECT tee.idtipoenvio
			      ,tee.cdagenci
				FROM tbcrd_endereco_entrega tee
			 WHERE tee.cdcooper = pr_cdcooper
				 AND tee.nrdconta = pr_nrdconta
				 AND tee.nrctrcrd = pr_nrctrcrd;
		rw_endereco_entrega cr_endereco_entrega%ROWTYPE;		

    -- cursor para adquirir endereço do cooperado
    CURSOR cr_crapenc (pr_cdcooper IN crapenc.cdcooper%TYPE,
                       pr_nrdconta IN crapenc.nrdconta%TYPE,
                       pr_tpendass IN crapenc.tpendass%TYPE) IS
    SELECT enc.nrcepend
          ,enc.nmcidade
          ,enc.nmbairro
          ,enc.cdufende
          ,enc.dsendere
          , decode(enc.nrendere,0,null,','||enc.nrendere) nrendere
          -- montar string com o endereço completo do associado
          ,enc.dsendere||
           decode(enc.nrendere,0,null,','||enc.nrendere) dsender_compl
          ,decode(nvl(trim(enc.cddbloco),'0'),'0',null,' bl-'||enc.cddbloco)||
           decode(nvl(trim(enc.nrdoapto),'0'),'0',null,' ap '||enc.nrdoapto) dsender_apbl
      FROM crapenc enc
     WHERE enc.cdcooper = pr_cdcooper
       AND enc.nrdconta = pr_nrdconta
       AND enc.tpendass = pr_tpendass;
    rw_crapenc cr_crapenc%ROWTYPE;

    -- Buscar as informações da conta do titular para incluir no cartão do adicional
    CURSOR cr_nrctaitg(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                       pr_nrdconta IN crawcrd.nrdconta%TYPE,
                       pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE) IS
      SELECT c.nrcctitg
        FROM crapttl  t
           , crawcrd  c
           , crawcrd  w
       WHERE w.nrcpftit = t.nrcpfcgc
         AND t.nrcpfcgc = c.nrcpftit
         AND t.idseqttl = 1 -- Titular
         AND t.nrdconta = c.nrdconta
         AND t.cdcooper = c.cdcooper
         AND c.cdadmcrd BETWEEN 10 AND 80
         AND c.cdadmcrd = w.cdadmcrd
         AND c.nrdconta = w.nrdconta
         AND c.cdcooper = w.cdcooper
         AND w.cdadmcrd = pr_cdadmcrd
         AND w.nrdconta = pr_nrdconta
         AND w.cdcooper = pr_cdcooper;
    rw_nrctaitg    cr_nrctaitg%ROWTYPE;

    -- Buscar as informações do primeiro cartão empresarial da conta
    CURSOR cr_nrctaitg_prcrd(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                             pr_nrdconta IN crawcrd.nrdconta%TYPE,
                             pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE) IS
      SELECT w.nrcctitg
        FROM crawcrd  w
       WHERE w.cdadmcrd = pr_cdadmcrd
         AND w.nrdconta = pr_nrdconta
         AND w.cdcooper = pr_cdcooper
         AND w.flgprcrd = 1;

    ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_nrctacrd   VARCHAR2(2000)  := 0;                              --> Nr. Conta Cartão para DETALHE (Tipo 1)
    vr_tpcntdeb   VARCHAR2(1)     := 0;                              --> Tipo de Contra Deb. para DETALHE (Tipo 1)
    vr_dstelres   VARCHAR2(2000)  := 0;                              --> Nr. Telefone Residencial
    vr_dstelcel   VARCHAR2(2000)  := 0;                              --> Nr. Telefone Celular
    vr_dstelcom   VARCHAR2(2000)  := 0;                              --> Nr. Telefone Comercial
    vr_dddresid   VARCHAR2(2000)  := 0;                              --> DDD Residencial
    vr_dddcelul   VARCHAR2(2000)  := 0;                              --> DDD Celular
    vr_dddcomer   VARCHAR2(2000)  := 0;                              --> DDD Comercial
    vr_titulari   VARCHAR2(4)     := 0;                              --> Titularidade
    vr_nrdocttl   VARCHAR2(200)   := 0;                              --> CI
    vr_idorgexp   INTEGER         := 0;                              --> Orgão Emissor da CI
    vr_cdufdttl   VARCHAR2(4)     := 0;                              --> UF da CI
    vr_nmdavali   VARCHAR2(2000);                                    --> Nome Avalista/Representante
    vr_flgprcrd   PLS_INTEGER;                                       --> Primeiro cartão da empresa (indiferente de cdadmcrd)
    vr_nrctarg1   NUMBER;                                            --> Número da conta do registro 1
    vr_tpdpagto   INTEGER;
    vr_dtnascto   DATE;
    vr_flaltafn   BOOLEAN := FALSE;
    vr_flctacrd   BOOLEAN := FALSE;
    vr_sexbancoob crapttl.cdsexotl%TYPE;
    vr_cdestcvl   crapavt.cdestcvl%TYPE;
    vr_nrcpfcgc   crapavt.nrcpfcgc%TYPE;
    vr_inpessoa   crapavt.inpessoa%TYPE;
    vr_cdprogra   VARCHAR2(30) := 'CCRD0007.PC_GERA_JASON_BANCOOB';
    vr_dscpfcgc   VARCHAR2(20);
    vr_cdbcobcb   NUMBER(10);
    vr_cdagebcb   crapcop.cdagebcb%TYPE;
    vr_nrdconta   crapass.nrdconta%TYPE;
    vr_cdorgexp   VARCHAR2(200);
    vr_nmorgexp   VARCHAR2(200);

    -- Upgrade no cartao do TITULAR 1
    vr_flupgrad   BOOLEAN := FALSE;
    vr_nrctaant   crapass.nrdconta%TYPE;

    -- Tratamento de erros
    vr_exc_saida        EXCEPTION;
    vr_cdcritic         PLS_INTEGER;
    vr_dscritic         VARCHAR2(4000);
    vr_exc_erro         EXCEPTION;
    vr_exc_loop_detalhe EXCEPTION;

    -- Objeto json
    vr_obj_cartao        json := json();
    vr_obj_pedir_cartao  json := json();
    vr_lst_cartao        json_list := json_list();

    vr_aux_dsendcom  VARCHAR2(50);

    ------------------------------- FUNCOES ---------------------------------
    FUNCTION fn_estado_civil_bancoob(pr_cdestcvl IN NUMBER) RETURN VARCHAR2 IS
      BEGIN
        DECLARE
        BEGIN
          CASE pr_cdestcvl
            WHEN 1 THEN RETURN '01'; /* Solteiro */
            WHEN 2 THEN RETURN '02'; /* Casado */

            WHEN 3 THEN RETURN '02'; /* Casado */
            WHEN 4 THEN RETURN '02'; /* Casado */
            WHEN 5 THEN RETURN '04'; /* Viuvo */
            WHEN 6 THEN RETURN '05'; /* Outros */
            WHEN 7 THEN RETURN '03'; /* Divorciado */
            WHEN 8 THEN RETURN '02'; /* Casado */
            ELSE        RETURN '00';
          END CASE;
         END;
    END fn_estado_civil_bancoob;

    PROCEDURE gera_VoReqAltaDeContaCartao (rw_crawcrd  IN OUT cr_crawcrd%ROWTYPE,
                                           rw_crapadc  IN cr_crapadc%ROWTYPE,
                                           pr_nmextttl IN VARCHAR2,
                                           pr_inpessoa IN NUMBER,
                                           pr_cdgrafin IN VARCHAR2,
                                           pr_VoReqAltaDeContaCartao OUT json) IS

        -- variáveis --
        vr_aux_dsendcom  VARCHAR2(50);
        vr_tpregtrb      crapjur.tpregtrb%TYPE;
        vr_cdbcobcb NUMBER(10);
        vr_cdagebcb crapage.cdagebcb%TYPE;
        vr_nrdconta crapass.nrdconta%TYPE;
				vr_tpendass crapenc.tpendass%TYPE;
				vr_cdagenci tbcrd_endereco_entrega.cdagenci%TYPE := 0;
				
				-- variaveis de endereço
				vr_dsendere VARCHAR2(60) := '';
				vr_dsender_apbl VARCHAR2(200) := NULL;
				vr_dsender_compl VARCHAR2(200) := '';
				vr_nrendere VARCHAR2(20) := '';
				vr_ufendere VARCHAR2(5) := '';
				vr_nmcidade VARCHAR2(50) := '';
				vr_nmbairro VARCHAR2(50) := '';
				vr_nrcepend VARCHAR2(15) := '';

        -- Objeto json
        vr_obj_VoReqAltaDeContaCartao    json := json();

      BEGIN
        BEGIN

          -- Cartao for Representantes "OUTROS" ou for somente credito
          IF rw_crawcrd.cdgraupr = 9 OR rw_crawcrd.flgdebit = 0 THEN
            vr_cdbcobcb := 000;
            vr_cdagebcb := 0;
            vr_nrdconta := 0;

          ELSE
            vr_cdbcobcb := 756;
            vr_cdagebcb := rw_crawcrd.cdagebcb;
            vr_nrdconta := rw_crawcrd.nrdconta;

          END IF;

				 /*
					Validar se existe registro na tbcrd_endereco_entrega pelo rw_crawcrd.nrctrcrd
					Se não houver segue a vida c/ cr_crapenc
					Se houver, enviamos o endereço da crapenc com crapenc.tpendass baseado na tbcrd_endereco_entrega.idtipoenvio
					*/
						
					IF pr_inpessoa = 1 THEN
						vr_tpendass := 10;
					ELSIF pr_inpessoa = 2 THEN
						vr_tpendass := 9;
					END IF;
					--
					OPEN cr_endereco_entrega(pr_cdcooper => rw_crawcrd.cdcooper,
																	 pr_nrdconta => rw_crawcrd.nrdconta,
																	 pr_nrctrcrd => pr_nrctrcrd);
					FETCH cr_endereco_entrega INTO rw_endereco_entrega;
					--
					IF cr_endereco_entrega%FOUND THEN
						vr_tpendass := rw_endereco_entrega.idtipoenvio;
						IF vr_tpendass IN (90, 91) THEN
							vr_cdagenci := nvl(rw_endereco_entrega.cdagenci, 0);
						END IF; 
						
					END IF;
					--
					CLOSE cr_endereco_entrega;

          IF vr_cdagenci > 0 THEN
						-- Busca endereço do PA
						OPEN cr_end_agencia(pr_cdcooper => rw_crawcrd.cdcooper,
						                    pr_cdagenci => vr_cdagenci);
						FETCH cr_end_agencia INTO rw_end_agencia;
						CLOSE cr_end_agencia;

						vr_dsender_compl := rw_end_agencia.dsender_compl;
						vr_nmbairro := rw_end_agencia.nmbairro;
						vr_nrcepend := rw_end_agencia.nrcepend;
						
						
					ELSE
          -- Busca Endereço do Cooperado
          OPEN cr_crapenc(pr_cdcooper => rw_crawcrd.cdcooper,
                          pr_nrdconta => rw_crawcrd.nrdconta,
														pr_tpendass => vr_tpendass);
          FETCH cr_crapenc INTO rw_crapenc;

          -- Se nao encontrar Endereço
          IF cr_crapenc%NOTFOUND THEN

            -- Fechar o cursor pois efetuaremos raise
            CLOSE cr_crapenc;
            -- Montar mensagem de critica
            vr_dscritic := 'Endereco nao encontrado. '                     ||
                           'Cooperativa: ' || TO_CHAR(rw_crawcrd.cdcooper) ||
                           ' Conta: ' || TO_CHAR(rw_crawcrd.nrdconta)      || '.';
            RAISE vr_exc_saida;
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapenc;
							
							vr_dsender_apbl := rw_crapenc.dsender_apbl;
							vr_dsender_compl := rw_crapenc.dsender_compl;
							vr_dsendere := rw_crapenc.dsendere;
							vr_nrendere := rw_crapenc.nrendere; 
							vr_ufendere := rw_crapenc.cdufende;
							vr_nmcidade := rw_crapenc.nmcidade;
							vr_nmbairro := rw_crapenc.nmbairro;
							vr_nrcepend := rw_crapenc.nrcepend;
							
							
          END IF;
					END IF;

          -- verificar quantos caracteres serão destinados ao endereço sd204641
          IF vr_dsender_apbl IS NULL THEN
            --usa os 50 caracteres para o endereço
						vr_aux_dsendcom := rpad(substr(vr_dsender_compl,1,50),50,' ');						
          ELSE
            -- separa 29 caracteres para endereço e 21 para complemento
            vr_aux_dsendcom := rpad((TRIM(substr(vr_dsendere,1,29)) || TRIM(substr(vr_nrendere,1,6)||substr(vr_dsender_apbl,1,15))),50,' ');
          END IF;

          -- Gerar código sequencial de controle para o contrato
          -- Se o nrseqcrd é null ou zero
          IF NVL(rw_crawcrd.nrseqcrd,0) = 0 THEN
            -- Buscar o próximo número da sequencia
            rw_crawcrd.nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(rw_crawcrd.cdcooper);
          END IF;

          -- Limpar as informações de telefone
          vr_dstelres := NULL;
          vr_dddresid := NULL;
          vr_dstelcel := NULL;
          vr_dddcelul := NULL;
          vr_dstelcom := NULL;
          vr_dddcomer := NULL;

          -- Busca Telefone Residencial do Cooperado
          OPEN cr_craptfc(pr_cdcooper => rw_crawcrd.cdcooper,
                          pr_nrdconta => rw_crawcrd.nrdconta,
                          pr_tptelefo => 1 /* Residencial */);
          FETCH cr_craptfc INTO rw_craptfc;

          -- Se encontrar Telefone Residencial
          IF cr_craptfc%FOUND THEN
            vr_dstelres := rw_craptfc.nrtelefo;
            vr_dddresid := rw_craptfc.nrdddtfc;
          ELSE
            vr_dstelres := 0;
            vr_dddresid := 0;
          END IF;

          -- fechar o cursor
          CLOSE cr_craptfc;

          -- Busca Telefone Celular do Cooperado
          OPEN cr_craptfc(pr_cdcooper => rw_crawcrd.cdcooper,
                          pr_nrdconta => rw_crawcrd.nrdconta,
                          pr_tptelefo => 2 /* Celular */);
          FETCH cr_craptfc INTO rw_craptfc;

          -- Se encontrar Telefone Celular
          IF cr_craptfc%FOUND THEN
            vr_dstelcel := rw_craptfc.nrtelefo;
            vr_dddcelul := rw_craptfc.nrdddtfc;
          ELSE
            vr_dstelcel := 0;
            vr_dddcelul := 0;
          END IF;

          -- fechar o cursor
          CLOSE cr_craptfc;

          -- Busca Telefone Comercial do Cooperado
          OPEN cr_craptfc(pr_cdcooper => rw_crawcrd.cdcooper,
                          pr_nrdconta => rw_crawcrd.nrdconta,
                          pr_tptelefo => 3 /* Comercial */);
          FETCH cr_craptfc INTO rw_craptfc;

          -- Se encontrar Comercial Celular
          IF cr_craptfc%FOUND THEN
            vr_dstelcom := rw_craptfc.nrtelefo;
            vr_dddcomer := rw_craptfc.nrdddtfc;
          ELSE
            vr_dstelcom := 0;
            vr_dddcomer := 0;
          END IF;

          -- fechar o cursor
          CLOSE cr_craptfc;

          -- Tp. Conta Debt.
          IF rw_crawcrd.flgdebcc = 0 THEN
            vr_tpcntdeb := '0';  /* Não Debita */
          ELSE
            vr_tpcntdeb := '1';  /* Debita C/C */
          END IF;

          -- Regra para quando o campo crawcrd.tpdpagto = 3 enviar "000".
          vr_tpdpagto := 0;

          IF rw_crawcrd.tpdpagto <> 3 THEN
            vr_tpdpagto := rw_crawcrd.tpdpagto;
          END IF;

          --Se é pessoa Jurídica
          IF pr_inpessoa = 2 THEN
            -- Busca Regime Tributário
            OPEN cr_crapjur(pr_cdcooper => rw_crawcrd.cdcooper,
                            pr_nrdconta => rw_crawcrd.nrdconta);
            FETCH cr_crapjur INTO rw_crapjur;

            -- Se encontrar
            IF cr_crapjur%FOUND THEN
              IF rw_crapjur.tpregtrb in (1,2) THEN /* Simples Nacional*/
                 vr_tpregtrb := 1;
              ELSE
                 vr_tpregtrb := 0;
              END IF;
            ELSE
              vr_tpregtrb := 0;
            END IF;

            -- fechar o cursor
            CLOSE cr_crapjur;
          END IF;

          -- Montar os atributos
          vr_obj_VoReqAltaDeContaCartao := json();

          vr_obj_VoReqAltaDeContaCartao.put('agenciaContaVinculada',vr_cdagebcb);
          vr_obj_VoReqAltaDeContaCartao.put('agenciaEmissor',rw_crapcop.cdagebcb);
          vr_obj_VoReqAltaDeContaCartao.put('appOrigem','5');
          vr_obj_VoReqAltaDeContaCartao.put('bairro', vr_nmbairro);
          vr_obj_VoReqAltaDeContaCartao.put('bancoContaVinculada',vr_cdbcobcb);
          vr_obj_VoReqAltaDeContaCartao.put('bin',rw_crapadc.nrctamae);
          vr_obj_VoReqAltaDeContaCartao.put('canalDeVendas',rw_crawcrd.cdagenci);
          vr_obj_VoReqAltaDeContaCartao.put('cep', vr_nrcepend);
          vr_obj_VoReqAltaDeContaCartao.put('contaVinculada',vr_nrdconta);
          vr_obj_VoReqAltaDeContaCartao.put('dddCelular',vr_dddcelul);
          vr_obj_VoReqAltaDeContaCartao.put('dddComercial',vr_dddcomer);
          vr_obj_VoReqAltaDeContaCartao.put('dddResidencial',vr_dddresid);
          vr_obj_VoReqAltaDeContaCartao.put('emissor',756);
          vr_obj_VoReqAltaDeContaCartao.put('endereco',vr_aux_dsendcom);
          vr_obj_VoReqAltaDeContaCartao.put('grupoAfinidade',pr_cdgrafin);
          vr_obj_VoReqAltaDeContaCartao.put('idUsuario','');
          vr_obj_VoReqAltaDeContaCartao.put('limiteCredito',rw_crawcrd.vllimcrd);
          vr_obj_VoReqAltaDeContaCartao.put('nomeCompleto',pr_nmextttl);
          vr_obj_VoReqAltaDeContaCartao.put('numeroContaDebito',rw_crawcrd.nrdconta);
          vr_obj_VoReqAltaDeContaCartao.put('numeroSocioLegado',rw_crawcrd.nrdconta);
          vr_obj_VoReqAltaDeContaCartao.put('pagoAutomatico',vr_tpdpagto);
          vr_obj_VoReqAltaDeContaCartao.put('participaSimplesNac',vr_tpregtrb);
          vr_obj_VoReqAltaDeContaCartao.put('patrimonio',0);
          vr_obj_VoReqAltaDeContaCartao.put('protocolo','');
          vr_obj_VoReqAltaDeContaCartao.put('renda',0);
          vr_obj_VoReqAltaDeContaCartao.put('telefoneCelular',vr_dstelcel);
          vr_obj_VoReqAltaDeContaCartao.put('telefoneComercial',vr_dstelcom);
          vr_obj_VoReqAltaDeContaCartao.put('telefoneResidencial',vr_dstelres);
          vr_obj_VoReqAltaDeContaCartao.put('timeout','');
          vr_obj_VoReqAltaDeContaCartao.put('tipoConta','');
          vr_obj_VoReqAltaDeContaCartao.put('usuario','CECRED');
          vr_obj_VoReqAltaDeContaCartao.put('vencimento',rw_crawcrd.dddebito);

          pr_VoReqAltaDeContaCartao := vr_obj_VoReqAltaDeContaCartao;

        END;
    END gera_VoReqAltaDeContaCartao;

    PROCEDURE gera_VoAltaCartao (rw_crawcrd  IN OUT cr_crawcrd%ROWTYPE,
                                 rw_crapcol  IN cr_crapcol%ROWTYPE,
                                 pr_nmextttl IN VARCHAR2,
                                 pc_nmtitcrd IN VARCHAR2,
                                 pr_dtnasttl IN VARCHAR2,
                                 pr_dssexotl IN VARCHAR2,
                                 pr_cdestcvl IN VARCHAR2,
                                 pr_nrcpfcgc IN VARCHAR2,
                                 pr_titulari IN VARCHAR2,
                                 pr_nrdocttl IN VARCHAR2,
                                 pr_idorgexp IN INTEGER,
                                 pr_cdufdttl IN VARCHAR2,
                                 pr_inpessoa IN crapass.inpessoa%TYPE) IS
      BEGIN
        DECLARE

          vr_inpessoa VARCHAR2(2);
          vr_dscpfcgc VARCHAR2(20);
          vr_cdbcobcb NUMBER(10);
          vr_cdagebcb crapcop.cdagebcb%TYPE;
          vr_nrdconta crapass.nrdconta%TYPE;
          vr_cdorgexp VARCHAR2(200);
          vr_nmorgexp VARCHAR2(200);
          vr_titulari BOOLEAN;

          -- Busca Email
          CURSOR cr_crapcem (pr_cdcooper crapcem.cdcooper%TYPE,
                             pr_nrdconta crapcem.nrdconta%TYPE
                             )IS
            SELECT cem.dsdemail
              FROM crapcem cem
             WHERE cem.cdcooper = pr_cdcooper
               AND cem.nrdconta = pr_nrdconta
               AND cem.idseqttl = 1;
          vr_dsdemail crapcem.dsdemail%TYPE;

        BEGIN

          IF pr_inpessoa = 1 THEN
            vr_inpessoa := '1';
            vr_dscpfcgc := LPAD(pr_nrcpfcgc,11,'0');
          ELSE
            vr_inpessoa := '3';
            vr_dscpfcgc := LPAD(pr_nrcpfcgc,14,'0');
          END IF;

          -- Gerar código sequencial de controle para o contrato
          -- Se o nrseqcrd é null ou zero
          IF NVL(rw_crawcrd.nrseqcrd,0) = 0 THEN
            -- Buscar o próximo número da sequencia
            rw_crawcrd.nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(rw_crawcrd.cdcooper);
          END IF;

          -- Cartao for Representantes "OUTROS" ou for somente credito
          IF rw_crawcrd.cdgraupr = 9 OR rw_crawcrd.flgdebit = 0 THEN
            vr_cdbcobcb := '000';
            vr_cdagebcb := 0;
            vr_nrdconta := 0;

          ELSE
            vr_cdbcobcb := '756';
            vr_cdagebcb := rw_crapcol.cdagebcb;
            vr_nrdconta := rw_crawcrd.nrdconta;

          END IF;

          --> Buscar orgão expedidor
          vr_cdorgexp := NULL;
          vr_nmorgexp := NULL;
          IF nvl(pr_idorgexp,0) > 0 THEN
            cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => pr_idorgexp,
                                              pr_cdorgao_expedidor => vr_cdorgexp,
                                              pr_nmorgao_expedidor => vr_nmorgexp,
                                              pr_cdcritic          => vr_cdcritic,
                                              pr_dscritic          => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              vr_cdorgexp := NULL;
            END IF;
          END IF;

          -- Busca E-mail
          OPEN cr_crapcem(pr_cdcooper => rw_crawcrd.cdcooper,
                          pr_nrdconta => rw_crawcrd.nrdconta);
          FETCH cr_crapcem INTO vr_dsdemail;

          -- fechar o cursor
          CLOSE cr_crapcem;

          --Se titular então TRUE
          IF pr_titulari = '1' THEN
            vr_titulari := TRUE;
          ELSE
            vr_titulari := FALSE;
          END IF;

          -- Montar os atributos
          vr_obj_cartao := json();

          vr_obj_cartao.put('agenciaContaVinculada',vr_cdagebcb);
          vr_obj_cartao.put('bancoContaVinculada',vr_cdbcobcb);
          vr_obj_cartao.put('contaVinculada',vr_nrdconta);
          vr_obj_cartao.put('dddCel',vr_dddcelul);
          vr_obj_cartao.put('telCel',vr_dstelcel);
          -- Documento
          vr_obj_cartao.put('documento', vr_dscpfcgc);
          vr_obj_cartao.put('dtNascimento',pr_dtnasttl);
          vr_obj_cartao.put('email',vr_dsdemail);
          -- Buscar dados do titular
          vr_obj_cartao.put('estadoCivil',pr_cdestcvl);
          vr_obj_cartao.put('identidade', pr_nrdocttl);
          vr_obj_cartao.put('tipoDocumento', vr_inpessoa);
          vr_obj_cartao.put('ufEmissor', pr_cdufdttl);
          vr_obj_cartao.put('orgaoEmissor',vr_cdorgexp);
          vr_obj_cartao.put('pinEmissor',' ');
          vr_obj_cartao.put('sexo', pr_dssexotl);
          vr_obj_cartao.put('titularidade',vr_titulari);
          vr_obj_cartao.put('limiteComponente',rw_crawcrd.vllimcrd);
          vr_obj_cartao.put('limiteCredito',rw_crawcrd.vllimcrd);
          vr_obj_cartao.put('nomeCompleto',pr_nmextttl);
          vr_obj_cartao.put('nomeImpressoCartao',pc_nmtitcrd);

        END;
    END gera_VoAltaCartao;

  BEGIN

    -- Busca dados da Cooperativa
    FOR rw_crapcol IN cr_crapcol(pr_cdcooper) LOOP

      -- Leitura do calendario da cooperativa do LOOP
      OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcol.cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdatc;

      -- Se nao encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
/*
      -- Processar alterações de dados dos Cooperados que possuem Cartão de Crédito
      FOR rw_crapcrd_loop_alt IN cr_crapcrd_loop_alt(rw_crapcol.cdcooper,
                                                     pr_nrdconta,
                                                     pr_nrctrcrd) LOOP

        -- Importante limpar os registros, para evitar dados inválidos
        rw_crapalt  := NULL;
        rw_altlimit := NULL;

        -- Busca alterações, após processar todas as inclusões
        OPEN cr_crapalt(pr_cdcooper => rw_crapcrd_loop_alt.cdcooper,
                        pr_nrdconta => rw_crapcrd_loop_alt.nrdconta,
                        pr_dtaltini => rw_crapdat.dtmvtoan,
                        pr_dtaltfim => rw_crapdat.dtmvtoan);
        FETCH cr_crapalt INTO rw_crapalt;

        -- Busca alterações de limite ainda pendentes de processamento
        OPEN  cr_altlimit(rw_crapcrd_loop_alt.cdcooper    -- pr_cdcooper
                         ,rw_crapcrd_loop_alt.nrdconta    -- pr_nrdconta
                         ,rw_crapcrd_loop_alt.nrcctitg);  -- pr_nrctacrd
        FETCH cr_altlimit INTO rw_altlimit;

        -- Se encontrar registro de alteração ou alteração de limite
        IF cr_crapalt%FOUND OR cr_altlimit%FOUND THEN

          -- Setar as variáveis de controle para FALSE
          vr_flaltafn := FALSE;
          vr_flalttpe := FALSE;
          vr_flaltcep := FALSE;
          vr_flalttfc := FALSE;

          -- Busca Administradora de Cartões
          OPEN cr_crapadc(pr_cdcooper => rw_crapcrd_loop_alt.cdcooper,
                          pr_cdadmcrd => rw_crapcrd_loop_alt.cdadmcrd);
          FETCH cr_crapadc INTO rw_crapadc;

          -- Se nao encontrar
          IF cr_crapadc%NOTFOUND THEN
            -- Fechar o cursor pois efetuaremos raise
            CLOSE cr_crapadc;
            CLOSE cr_crapalt;
            CLOSE cr_altlimit;
            -- Montar mensagem de critica
            vr_cdcritic := 605;
            RAISE vr_exc_saida;
          ELSE
            -- fechar o cursor
            CLOSE cr_crapadc;
          END IF;

          -- Busca Grupo de Afinidade
          OPEN cr_crapacb(pr_cdcooper => rw_crapcrd_loop_alt.cdcooper,
                          pr_cdadmcrd => rw_crapcrd_loop_alt.cdadmcrd);
          FETCH cr_crapacb INTO rw_crapacb;

          -- Se nao encontrar
          IF cr_crapacb%NOTFOUND THEN
            -- Fechar o cursor pois efetuaremos raise
            CLOSE cr_crapacb;
            CLOSE cr_crapalt;
            CLOSE cr_altlimit;
            -- Montar mensagem de critica
            vr_dscritic := 'Grupo de Afinidade nao encontrado para administradora ' ||
                           to_char(rw_crapcrd_loop_alt.cdadmcrd) || '.';
            RAISE vr_exc_saida;
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapacb;
          END IF;

          -- Verificar se houve alteração no grupo de afinidade - por PA
          -- a alteracao de PA deve ser a primeira, ou separado por virgula
          IF upper(rw_crapalt.dsaltera) LIKE 'PAC %'             OR
             upper(rw_crapalt.dsaltera) LIKE 'PA %'              OR
             upper(rw_crapalt.dsaltera) LIKE '%,PAC %'           OR
             upper(rw_crapalt.dsaltera) LIKE '%,PA %'            OR
             upper(rw_crapalt.dsaltera) LIKE '%, PAC %'          OR
             upper(rw_crapalt.dsaltera) LIKE '%, PA %'           THEN
            vr_flaltafn := TRUE;
          END IF;

          -- verificar se houve alteração no Bairro ou Rua
          IF upper(rw_crapalt.dsaltera) LIKE '%END.RES. 1.TTL%'   OR
             upper(rw_crapalt.dsaltera) LIKE '%ENDERECO 1.TTL%'   OR
             upper(rw_crapalt.dsaltera) LIKE '%NRO.END. 1.TTL%'   OR
             upper(rw_crapalt.dsaltera) LIKE '%NR.END. 1.TTL%'    OR
             upper(rw_crapalt.dsaltera) LIKE '%COMPLEM. 1.TTL%'   OR
             upper(rw_crapalt.dsaltera) LIKE '%COMPL.END. 1.TTL%' OR
             upper(rw_crapalt.dsaltera) LIKE '%APTO. 1.TTL%'      OR
             upper(rw_crapalt.dsaltera) LIKE '%BAIRRO 1.TTL%'     OR
             upper(rw_crapalt.dsaltera) LIKE '%END.RES.,%'        OR
             upper(rw_crapalt.dsaltera) LIKE '%BAIRRO,%'          OR
             upper(rw_crapalt.dsaltera) LIKE '%END.RES. COM.,%'   OR
             upper(rw_crapalt.dsaltera) LIKE '%NR.END. COM.,%'    OR
             upper(rw_crapalt.dsaltera) LIKE '%COMPLEM. COM.,%'   OR
             upper(rw_crapalt.dsaltera) LIKE '%BAIRRO COM.,%'     THEN
            vr_flalttpe := TRUE;
          END IF;

          -- Verificar se foi alterado Estado, cidade ou CEP
          IF upper(rw_crapalt.dsaltera) LIKE '%CEP 1.TTL%'        OR
             upper(rw_crapalt.dsaltera) LIKE '%CIDADE 1.TTL%'     OR
             upper(rw_crapalt.dsaltera) LIKE '%UF 1.TTL%'         OR
             upper(rw_crapalt.dsaltera) LIKE '%CIDADE,%'          OR
             upper(rw_crapalt.dsaltera) LIKE '%UF,%'              OR
             upper(rw_crapalt.dsaltera) LIKE '%CEP,%'             OR
             upper(rw_crapalt.dsaltera) LIKE '%CEP COM.,%'        OR
             upper(rw_crapalt.dsaltera) LIKE '%CIDADE COM.,%'     OR
             upper(rw_crapalt.dsaltera) LIKE '%UF COM.,%'         THEN
            vr_flaltcep := TRUE;
          END IF;

          -- Verificar se houve alteração do telefone do cooperado
          IF upper(rw_crapalt.dsaltera) LIKE '%TELEF.%' THEN
            vr_flalttfc := TRUE;
          END IF;

          -- Se há alteração de limite
          IF cr_altlimit%FOUND THEN
            -- Popula a variável com o novo limite proposto
            vr_vllimalt := rw_altlimit.vllimite;
          ELSE
            -- Envia nulo
            vr_vllimalt := NULL;
          END IF;

          -- Irá chamar a rotina para envio do registro, apenas se houver alguma alteração
          IF vr_flaltafn OR                 -- Alterado grupo de afinidade
             vr_flaltcep OR                 -- Alterado Estado, cidade ou CEP
             vr_flalttpe OR                 -- Alterado Bairro ou Rua
             vr_flalttfc OR                 -- Alterado telefone
             vr_vllimalt IS NOT NULL THEN   -- Alterado Limite

            -- LINHA RELATIVA AOS DADOS DA CONTA CARTAO (VoReqAltaDeContaCartao)
            gera_VoReqAltaDeContaCartao (rw_crapcrd_loop_alt,
                                         rw_crapadc,
                                         rw_crapcrd_loop_alt.nmtitcrd,
                                         rw_crapcrd_loop_alt.inpessoa,
                                         rw_crapacb.cdgrafin,
                                         vr_obj_pedir_cartao);

          END IF;

          -- Se há registro de alteração de limite
          IF cr_altlimit%FOUND THEN
            BEGIN
              -- Deve atualizar a situação do aumento de limite
              UPDATE tbcrd_limite_atualiza  t
                 SET tpsituacao = 2 -- Enviado ao Bancoob 
               WHERE ROWID = rw_altlimit.dsdrowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Montar mensagem de critica
                vr_dscritic := 'Erro ao atualizar solicitação de alteração de limite: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;

        END IF;

        -- fecha cursores
        CLOSE cr_crapalt;
        CLOSE cr_altlimit;

      END LOOP;
*/
      -- Executa LOOP em registro de Cartões para gravar DETALHE
      FOR rw_crawcrd IN cr_crawcrd(rw_crapcol.cdcooper,
                                   pr_nrdconta,
                                   pr_nrctrcrd) LOOP
        BEGIN

          -- Define Conta Cartão a cada iteração do cr_crawcrd
          vr_nrctacrd := '756' || TO_CHAR(lpad(rw_crapcol.cdagebcb,4,'0'));
          vr_flctacrd := FALSE; -- Não tem conta cartão, pois apenas definiu com a numeração padrão

          -- Zerar vars
          vr_nrdocttl := ' ';
          vr_idorgexp := NULL;
          vr_cdufdttl := ' ';
          vr_titulari := 0;

          -- Solicitacao de upgrade/downgrade no cartao do primeiro titular
          IF NVL(vr_nrctaant,0) <> rw_crawcrd.nrdconta THEN
            vr_flupgrad := FALSE;
            vr_nrctaant := rw_crawcrd.nrdconta;
          END IF;

          -- Busca Administradora de Cartões
          OPEN cr_crapadc(pr_cdcooper => rw_crawcrd.cdcooper,
                          pr_cdadmcrd => rw_crawcrd.cdadmcrd);
          FETCH cr_crapadc INTO rw_crapadc;

          -- Se nao encontrar
          IF cr_crapadc%NOTFOUND THEN
            -- Fechar o cursor pois efetuaremos raise
            CLOSE cr_crapadc;
            -- Montar mensagem de critica
            vr_cdcritic := 605;
            RAISE vr_exc_saida;
          ELSE
            -- fechar o cursor
            CLOSE cr_crapadc;
          END IF;

          -- Busca Grupo de Afinidade
          OPEN cr_crapacb(pr_cdcooper => rw_crawcrd.cdcooper,
                          pr_cdadmcrd => rw_crawcrd.cdadmcrd);
          FETCH cr_crapacb INTO rw_crapacb;

          -- Se nao encontrar
          IF cr_crapacb%NOTFOUND THEN
            -- Fechar o cursor pois efetuaremos raise
            CLOSE cr_crapacb;
            -- Montar mensagem de critica
            vr_dscritic := 'Grupo de Afinidade nao encontrado para administradora ' ||
                           to_char(rw_crawcrd.cdadmcrd) || '.';
            RAISE vr_exc_saida;
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapacb;
          END IF;

          -- se tratamos pessoa física
          IF rw_crawcrd.inpessoa = 1 THEN

            -- Busca registro pessoa física
            OPEN cr_crapttl(pr_cdcooper => rw_crawcrd.cdcooper,
                            pr_nrdconta => rw_crawcrd.nrdconta,
                            pr_nrcpfcgc => rw_crawcrd.nrcpftit);
            FETCH cr_crapttl INTO rw_crapttl;

            -- Se nao encontrar
            IF cr_crapttl%NOTFOUND THEN
              -- Fechar o cursor pois efetuaremos raise
              CLOSE cr_crapttl;
              -- Montar mensagem de critica
              vr_dscritic := 'Titular da conta nao encontrado: ' || rw_crawcrd.nrdconta ||
                             ' CPF: '                            || rw_crawcrd.nrcpftit ||
                             ' Coop: ' ||                           rw_crawcrd.cdcooper;
              RAISE vr_exc_loop_detalhe;
            ELSE
              -- Apenas fechar o cursor
              CLOSE cr_crapttl;
            END IF;

            -- Somente alimenta varíaveis com informações de Documento for Carteira de Identidade
            IF rw_crapttl.tpdocttl = 'CI' THEN
              vr_nrdocttl := rw_crapttl.nrdocttl;
              vr_idorgexp := rw_crapttl.idorgexp;
              vr_cdufdttl := rw_crapttl.cdufdttl;
            ELSE
              vr_nrdocttl := ' ';
              vr_idorgexp := NULL;
              vr_cdufdttl := ' ';
            END IF;

            -- Se for primeiro titular, cria registro de Conta Cartão
            IF rw_crapttl.idseqttl = 1 THEN

              -- Titularidade: Titular para Tp Registro 2.
              vr_titulari := '1';

              -- Setar variável que indica alteração
              vr_flaltafn := FALSE;

              -- Guarda o número da conta informado no registro tipo 1
              vr_nrctarg1 := rw_crawcrd.nrdconta;

              -- LINHA RELATIVA AOS DADOS DA CONTA CARTAO (VoReqAltaDeContaCartao)
              gera_VoReqAltaDeContaCartao (rw_crawcrd,
                                           rw_crapadc,
                                           rw_crapttl.nmextttl,
                                           rw_crawcrd.inpessoa,
                                           rw_crapacb.cdgrafin,
                                           vr_obj_pedir_cartao);

              -- Em caso de Upgrade/Downgrade, interrompe e passa para o próximo
              IF vr_flupgrad THEN

                -- Altera a situação do Cartão para 9 (Enviado Bancoob)
                pc_altera_sit_cartao_bancoob(pr_cdcooper => rw_crawcrd.cdcooper
                                            ,pr_nrdconta => rw_crawcrd.nrdconta
                                            ,pr_nrctrcrd => rw_crawcrd.nrctrcrd
                                            ,pr_nrseqcrd => rw_crawcrd.nrseqcrd
                                            ,pr_insitcrd => 9
                                            ,pr_dscritic => vr_dscritic);

                IF vr_dscritic IS NOT NULL THEN
                  raise vr_exc_saida;
                END IF;

                rw_crapadc_crd := NULL;
                CONTINUE;
              END IF;

            ELSE -- outros titulares

              -- Adicionar tratamento para quando for realizado Upgrade/Downgrade
              -- nao gerar as informacoes dos cartoes adicionais
              -- Verificar se o Tipo de Operacao eh a Modificacao de Conta Cartao (UPGRADE/DOWNGRADE)
              IF vr_flupgrad THEN
                -- Ignorar as informacoes e processar o proximo cartao
                CONTINUE;
              END IF;

              -- Incluir a conta do titular quando as informações forem de um cartão adicional
              -- Buscar a conta integração do titular
              OPEN  cr_nrctaitg(rw_crawcrd.cdcooper
                               ,rw_crawcrd.nrdconta
                               ,rw_crawcrd.cdadmcrd);
              FETCH cr_nrctaitg INTO rw_nrctaitg;
              -- Se encontrar registros
              IF cr_nrctaitg%FOUND AND NVL(rw_nrctaitg.nrcctitg,0) <> 0  THEN
                -- Usar a conta integração do titular
                vr_nrctacrd := rw_nrctaitg.nrcctitg;
                vr_flctacrd := TRUE; -- Indica que possui conta cartão
              END IF;
              CLOSE cr_nrctaitg;

              -- Se não for a mesma conta do registro 01 enviado, deve pular o registro
              IF NVL(vr_nrctarg1,0) <> NVL(rw_crawcrd.nrdconta,-1) THEN
                CONTINUE;
              END IF;

              -- Titularidade: Dependentes (idseqttl <> 1) para Tp Registro 2.
              vr_titulari := '2';

              -- LINHA RELATIVA AOS DADOS DA CONTA CARTAO (VoReqAltaDeContaCartao)
              gera_VoReqAltaDeContaCartao (rw_crawcrd,
                                           rw_crapadc,
                                           rw_crapttl.nmextttl,
                                           rw_crawcrd.inpessoa,
                                           rw_crapacb.cdgrafin,
                                           vr_obj_pedir_cartao);

            END IF;

            -- LINHA RELATIVA AOS DADOS DO CARTAO (gera_VoAltaCartao)
            gera_VoAltaCartao (rw_crawcrd,
                               rw_crapcol,
                               rw_crapttl.nmextttl,
                               rw_crawcrd.nmtitcrd, -- Nome embossado no cartão
                               TO_CHAR(rw_crapttl.dtnasttl,'DD/MM/YYYY'),
                               rw_crapttl.sexbancoob,
                               fn_estado_civil_bancoob(rw_crapttl.cdestcvl),
                               rw_crawcrd.nrcpftit,
                               vr_titulari,
                               vr_nrdocttl,
                               vr_idorgexp,
                               vr_cdufdttl,
                               rw_crapttl.inpessoa);

            vr_lst_cartao.append(vr_obj_cartao.to_json_value());

          ELSE -- se tratamos pessoa jurídica

            -- Busca registro de pessoa jurídica
            OPEN cr_crapjur(pr_cdcooper => rw_crawcrd.cdcooper,
                            pr_nrdconta => rw_crawcrd.nrdconta);
            FETCH cr_crapjur INTO rw_crapjur;

            -- Se nao encontrar
            IF cr_crapjur%NOTFOUND THEN
              -- Fechar o cursor pois efetuaremos raise
              CLOSE cr_crapjur;
              -- Montar mensagem de critica
              vr_dscritic := 'Empresa nao encontrada. Conta/DV: ' || rw_crawcrd.nrdconta;
              RAISE vr_exc_saida;
            ELSE
              -- Apenas fechar o cursor
              CLOSE cr_crapjur;
            END IF;

            -- Representante do tipo OUTROS
            IF rw_crawcrd.cdgraupr = 9 THEN
              vr_dtnascto   := rw_crawcrd.dtnasccr;
              vr_nrdocttl   := ' ';
              vr_idorgexp   := NULL;
              vr_cdufdttl   := ' ';
              vr_nmdavali   := rw_crawcrd.nmtitcrd;
              vr_sexbancoob := 0;
              vr_cdestcvl   := 0;
              vr_nrcpfcgc   := rw_crawcrd.nrcpftit;
              vr_inpessoa   := 1;

            ELSE
              -- Busca registro de representante para pessoa jurídica
              OPEN cr_crapavt(pr_cdcooper => rw_crawcrd.cdcooper,
                              pr_nrdconta => rw_crawcrd.nrdconta,
                              pr_nrcpfcgc => rw_crawcrd.nrcpftit);
              FETCH cr_crapavt INTO rw_crapavt;

              -- Se nao encontrar
              IF cr_crapavt%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE cr_crapavt;
                -- Montar mensagem de critica
                vr_dscritic := 'Representante nao encontrado. Conta/DV: ' || rw_crawcrd.nrdconta ||
                               ' CPF: '                                   || rw_crawcrd.nrcpftit ||
                               ' Coop: '                                  || rw_crawcrd.cdcooper ;
                RAISE vr_exc_loop_detalhe;
              ELSE
                -- Data nascimento representante
                vr_dtnascto := rw_crapavt.dtnascto;

                -- Apenas fechar o cursor
                CLOSE cr_crapavt;
              END IF;

              -- Somente alimenta varíaveis com informações de Documento for Carteira de Identidade
              IF rw_crapavt.tpdocava = 'CI' THEN
                vr_nrdocttl := rw_crapavt.nrdocava;
                vr_idorgexp := rw_crapavt.idorgexp;
                vr_cdufdttl := rw_crapavt.cdufddoc;
                vr_nmdavali := rw_crapavt.nmdavali;
              ELSE
                vr_nrdocttl := ' ';
                vr_idorgexp := NULL;
                vr_cdufdttl := ' ';
                vr_nmdavali := rw_crapavt.nmdavali;
              END IF;

              -- Assume a data de nascimento
              vr_dtnascto   := rw_crapavt.dtnascto;
              vr_sexbancoob := rw_crapavt.sexbancoob;
              vr_cdestcvl   := rw_crapavt.cdestcvl;
              vr_nrcpfcgc   := rw_crapavt.nrcpfcgc;
              vr_inpessoa   := rw_crapavt.inpessoa;

            END IF;

            -- Buscar a conta integração do titular
            OPEN  cr_nrctaitg_prcrd(rw_crawcrd.cdcooper
                                   ,rw_crawcrd.nrdconta
                                   ,rw_crawcrd.cdadmcrd);
            FETCH cr_nrctaitg_prcrd INTO rw_nrctaitg;
            -- Se encontrar registros
            IF cr_nrctaitg_prcrd%FOUND AND NVL(rw_nrctaitg.nrcctitg,0) <> 0 THEN
              -- Usar a conta integração do titular
              vr_nrctacrd := rw_nrctaitg.nrcctitg;
              vr_flctacrd := TRUE; -- Indica que possui conta cartão
            END IF;
            CLOSE cr_nrctaitg_prcrd;

            -- Verifica se é o primeiro cartão bancoob da empresa (indiferente da adminsitradora)
            OPEN cr_crawcrd_flgprcrd(pr_cdcooper => rw_crawcrd.cdcooper,
                                     pr_nrdconta => rw_crawcrd.nrdconta,
                                     pr_nrctrcrd => rw_crawcrd.nrctrcrd,
                                     pr_nmbandei => rw_crapadc.nmbandei);
            FETCH cr_crawcrd_flgprcrd INTO rw_crawcrd_flgprcrd;

            IF cr_crawcrd_flgprcrd%FOUND THEN
               vr_flgprcrd := 0; -- Não é o primeiro
            ELSE
               vr_flgprcrd := 1; -- É o primeiro cartão Bancoob
            END IF;

            -- fecha cursor
            CLOSE cr_crawcrd_flgprcrd;

            -- Verifica se é o primeiro cartão Bancoob adquirido
            IF vr_flgprcrd = 1 THEN

              -- LINHA RELATIVA AOS DADOS DA CONTA CARTAO (VoReqAltaDeContaCartao)
              gera_VoReqAltaDeContaCartao (rw_crawcrd,
                                           rw_crapadc,
                                           rw_crapjur.nmextttl,
                                           rw_crawcrd.inpessoa,
                                           rw_crapacb.cdgrafin,
                                           vr_obj_pedir_cartao);

              -- Titularidade: Titular para Tp Registro 2
              vr_titulari := '1';

              -- Envia registro tipo 2 com dados da empresa uma única vez
              -- LINHA RELATIVA AOS DADOS DO CARTAO (VoAltaCartao)
              gera_VoAltaCartao (rw_crawcrd,
                                 rw_crapcol,
                                 rw_crapjur.nmextttl,
                                 rw_crawcrd.nmempcrd,  -- Nome embossado no cartão
                                 TO_CHAR(rw_crapjur.dtiniatv,'DD/MM/YYYY'),
                                 '0',  -- Não informado
                                 '00', -- Não informado
                                 rw_crawcrd.nrcpfcgc,
                                 vr_titulari,
                                 rw_crapjur.nrinsest,
                                 NULL,
                                 ' ',
                                 2); -- Pessoa Juridica

              vr_lst_cartao.append(vr_obj_cartao.to_json_value()); --Paulo 23/8

            ELSE

              -- LINHA RELATIVA AOS DADOS DA CONTA CARTAO (VoReqAltaDeContaCartao)
              gera_VoReqAltaDeContaCartao (rw_crawcrd,
                                           rw_crapadc,
                                           vr_nmdavali,
                                           rw_crawcrd.inpessoa,
                                           rw_crapacb.cdgrafin,
                                           vr_obj_pedir_cartao);
            END IF;--Paulo 23/8
              -- Titularidade: Dependentes para Tp Registro 2
              vr_titulari := '2';

              -- Envia registro tipo 2 com dados do solicitante do cartão
              -- LINHA RELATIVA AOS DADOS DO CARTAO (VoAltaCartao)
              gera_VoAltaCartao (rw_crawcrd,
                                 rw_crapcol,
                                 vr_nmdavali,
                                 rw_crawcrd.nmtitcrd, -- Nome embossado no cartão
                                 TO_CHAR(vr_dtnascto,'DD/MM/YYYY'),
                                 vr_sexbancoob,
                                 fn_estado_civil_bancoob(vr_cdestcvl),
                                 vr_nrcpfcgc,
                                 vr_titulari,
                                 vr_nrdocttl,
                                 vr_idorgexp,
                                 vr_cdufdttl,
                                 vr_inpessoa);

            vr_lst_cartao.append(vr_obj_cartao.to_json_value()); --Paulo 23/8

          END IF;

          -- Altera a situação do Cartão para 9 (Enviado Bancoob)
          pc_altera_sit_cartao_bancoob(pr_cdcooper => rw_crawcrd.cdcooper
                                      ,pr_nrdconta => rw_crawcrd.nrdconta
                                      ,pr_nrctrcrd => rw_crawcrd.nrctrcrd
                                      ,pr_nrseqcrd => rw_crawcrd.nrseqcrd
                                      ,pr_insitcrd => 9
                                      ,pr_dscritic => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;

        EXCEPTION
          WHEN vr_exc_loop_detalhe THEN
            IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); -- Buscar a descrição
            END IF;

            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Programa roda para todas as coops. Por isto fixo cecred (3)
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                          || vr_cdprogra || ' --> '
                                                                          || vr_dscritic );
            END IF;
          WHEN OTHERS THEN
            -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
            vr_dscritic := 'Problema ao montar json de cartoes solicitados - ' || sqlerrm;
            RAISE vr_exc_saida;
        END;

      END LOOP;

    END LOOP;

    vr_obj_pedir_cartao.put('cartoes',vr_lst_cartao);
    pr_dsjsonan := vr_obj_pedir_cartao;

  EXCEPTION
    WHEN vr_exc_erro  THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                    || vr_cdprogra || ' --> '
                                                                    || vr_dscritic );
      END IF;

      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;

    WHEN vr_exc_loop_detalhe THEN
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); -- Buscar a descrição
      END IF;

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Programa roda para todas as coops. Por isto fixo cecred (3)
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                    || vr_cdprogra || ' --> '
                                                                    || vr_dscritic );
      END IF;

    WHEN OTHERS THEN
      IF SQLCODE < 0 THEN
        -- Caso ocorra exception gerar o código do erro com a linha do erro
        vr_dscritic:= vr_dscritic || dbms_utility.format_error_backtrace;

      END IF;

      -- Montar a mensagem final do erro
      vr_dscritic:= 'Erro na montagem dos dados para envio ao Bancoob (2): ' ||
                     vr_dscritic || ' -- SQLERRM: ' || SQLERRM;

      -- Remover as ASPAS que quebram o texto
      vr_dscritic:= replace(vr_dscritic,'"', '');
      vr_dscritic:= replace(vr_dscritic,'''','');
      -- Remover as quebras de linha
      vr_dscritic:= replace(vr_dscritic,chr(10),'');
      vr_dscritic:= replace(vr_dscritic,chr(13),'');

      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;

  END pc_gera_json_bancoob;

  PROCEDURE pc_solicitar_cartao_bancoob_pl(pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_cdagenci IN crapage.cdagenci%TYPE
                                          ,pr_cdoperad IN crapope.cdoperad%TYPE
                                          ,pr_idorigem IN NUMERIC
                                          ,pr_nrdconta IN crapass.nrdconta%TYPE
                                          ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                          ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    
    vr_xmllog     VARCHAR2(32000);
    vr_nmdcampo   VARCHAR2(100);
    vr_des_erro   VARCHAR2(100);
    vr_retxml     xmltype;
    
    -- Cursor genérico de calendário
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    
  BEGIN
    
    vr_retxml := xmltype.createXML('<?xml version="1.0" encoding="WINDOWS-1252"?>
                                    <Root>
                                      <Dados>
                                        <nrdconta>'|| pr_nrdconta ||'</nrdconta>
                                        <nrctrcrd>'|| pr_nrctrcrd ||'</nrctrcrd>
                                        <dtmvtolt>'|| rw_crapdat.dtmvtolt ||'</dtmvtolt>
                                      </Dados>
                                      <params>
                                        <nmprogra>CCRD0007</nmprogra>
                                        <nmeacao>SOLICITAR_CARTAO_BANCOOB</nmeacao>
                                        <cdcooper>'|| pr_cdcooper ||'</cdcooper>
                                        <cdagenci>'|| pr_cdagenci ||'</cdagenci>
                                        <nrdcaixa>0</nrdcaixa>
                                        <idorigem>'|| pr_idorigem ||'</idorigem>
                                        <cdoperad>'|| pr_cdoperad ||'</cdoperad>
                                      </params>
                                    </Root>');    
  
    CCRD0007.pc_solicitar_cartao_bancoob(pr_nrdconta => pr_nrdconta
                                        ,pr_nrctrcrd => pr_nrctrcrd
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_xmllog   => vr_xmllog
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_retxml   => vr_retxml
                                        ,pr_nmdcampo => vr_nmdcampo
                                        ,pr_des_erro => vr_des_erro);
    
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= 'CCRD0007.pc_solicitar_cartao_bancoob_pl => Erro na solicitacao de cartao ao Bancoob: '|| SQLERRM;
      END IF;
      vr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;      
      
  END pc_solicitar_cartao_bancoob_pl;

  --> Rotina responsavel por solicitar cartão ao Bancoob
  PROCEDURE pc_solicitar_cartao_bancoob(pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr da conta
                                       ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr do contrato
                                       ,pr_dtmvtolt IN VARCHAR2              --> Data do movimento
                                       ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2              --> Erros do processo
                                       ) IS

    /* ..........................................................................

      Programa : pc_solicitar_cartao_bancoob
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva
      Data     : Fevereiro/2018.                   Ultima atualizacao: 26/02/2018
      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a inclusao da proposta para o Bancoob
      Alteração :

    ..........................................................................*/

    ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CCRD0007';       --> Código do programa
    vr_dtmvtolt   DATE := to_date(pr_dtmvtolt,'DD/MM/YYYY');
    vr_hrenvban   NUMBER;
    vr_qtsegund   NUMBER;
    vr_flganlok   BOOLEAN := FALSE;

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Cursor genérico de calendário
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;

    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_exc_continua EXCEPTION;

    vr_obj_cartao      json := json();
    vr_obj_cartao_clob clob;

    vr_dsprotoc VARCHAR2(1000);
    vr_comprecu VARCHAR2(1000);
    vr_des_mensagem VARCHAR2(4000);

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Busca acionamentos de retorno de solicitacao de cartão do Bancoob
    CURSOR cr_retbancoob(pr_cdcooper    tbgen_webservice_aciona.cdcooper%TYPE
                        ,pr_dsprotocolo tbgen_webservice_aciona.dsprotocolo%TYPE) IS
      SELECT idacionamento
            ,dsconteudo_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND cdoperad = 'BANCOOB'
         AND nrdconta = pr_nrdconta
         AND tpacionamento = 2 --> Apenas Retorno
         AND cdorigem  = 5     --> Esteira
         AND tpproduto = 4     --> Apenas Cartão de Crédito
         AND nrctrprp  = pr_nrctrcrd
         AND dsprotocolo = pr_dsprotocolo
         AND TO_CHAR(dsresposta_requisicao) NOT LIKE '%não foi processado%';
    rw_retbancoob cr_retbancoob%ROWTYPE;
    
    cursor cr_crawcrd (pr_cdcooper crawcrd.cdcooper%type
                      ,pr_nrdconta crawcrd.nrdconta%type
                      ,pr_nrctrcrd crawcrd.nrctrcrd%type) is
    select flgprcrd
      from crawcrd d
     where d.cdcooper = pr_cdcooper
       and d.nrdconta = pr_nrdconta 
       and d.nrctrcrd = pr_nrctrcrd;
     rw_crawcrd cr_crawcrd%rowtype;

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

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
       RAISE vr_exc_saida;
    END IF;

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => vr_cdprogra
                              ,pr_action => vr_nmeacao);

    --Verifica se está em contingência
    IF fn_usa_bancoob_ws(pr_cdcooper => vr_cdcooper
                        ,pr_tpoperac => 'S') THEN -- Solicitar cartao
      vr_dscritic := 'Bancoob está em contingência. A solicitação será enviada no processo noturno.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    -- Se nao encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crawcrd (pr_cdcooper => vr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrctrcrd => pr_nrctrcrd);
    FETCH cr_crawcrd INTO rw_crawcrd;

    -- Se nao encontrar
    IF cr_crawcrd%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crawcrd;
      -- Montar mensagem de critica
      vr_cdcritic:= 0;
      vr_dscritic:= 'Proposta nao encontrada!';
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crawcrd;
      -- Se não for primeiro titular não deve solicitar via API
      if rw_crawcrd.flgprcrd = 0 then
        RAISE vr_exc_continua;
      end if;
    END IF;

    --> Gerar informações no padrao JSON da solicitação do cartão
    pc_gera_json_bancoob (pr_cdcooper   => vr_cdcooper      --> Codigo da cooperativa
                         ,pr_nrdconta   => pr_nrdconta      --> Número do caixa
                         ,pr_nrctrcrd   => pr_nrctrcrd      --> Número da proposta do cartão
                         ---- OUT ----
                         ,pr_dsjsonan   => vr_obj_cartao    --> Retorno do clob em modelo json com os dados para analise
                         ,pr_cdcritic   => vr_cdcritic      --> Codigo da critica
                         ,pr_dscritic   => vr_dscritic);    --> Descricao da critica

    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_cartao_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_cartao_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_cartao,vr_obj_cartao_clob);

     pc_enviar_bancoob ( pr_cdcooper    => vr_cdcooper,  --> Codigo da cooperativa
                        pr_cdagenci    => vr_cdagenci,  --> Codigo da agencia
                        pr_cdoperad    => vr_cdoperad,  --> codigo do operador
                        pr_cdorigem    => vr_idorigem,  --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,  --> Numero da conta do cooperado
                        pr_nrctrcrd    => pr_nrctrcrd,  --> Numero da proposta de cartão
                        pr_dtmvtolt    => vr_dtmvtolt,  --> Data do movimento
                        pr_comprecu    => vr_comprecu,  --> Complemento do recuros da URI
                        pr_dsmetodo    => 'POST',       --> Descricao do metodo
                        pr_conteudo    => vr_obj_cartao_clob,                     --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DA SOLICITACAO CARTAO BANCOOB',  --> Operacao realizada
                        pr_tipo_ws     => 1, /* Solicitacao de Cartao */
                        pr_dsprotocolo => vr_dsprotoc,                            --> Protocolo retornado na requisição
                        pr_dscritic    => vr_dscritic,
                        pr_des_mensagem => vr_des_mensagem);

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_obj_cartao_clob);
    dbms_lob.freetemporary(vr_obj_cartao_clob);

    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    COMMIT;

    vr_hrenvban := to_char(SYSDATE,'sssss');

    -- Buscar a quantidade de segundos de espera pelo retorno do Bancoob
    vr_qtsegund := NVL(gene0001.fn_param_sistema('CRED',vr_cdcooper,'TIMEOUT_CONEXAO_BANCOOB'),30);

    -- Efetuar laço para esperarmos (N) segundos ou o termino da analise recebido via POST
    WHILE NOT vr_flganlok AND TO_NUMBER(TO_CHAR(SYSDATE,'sssss')) - vr_hrenvban < vr_qtsegund LOOP

      -- Aguardar 0.5 segundo para evitar sobrecarga de processador
      sys.dbms_lock.sleep(0.5);

      --Verifica se já gravou o protocolo
      OPEN cr_retbancoob(pr_cdcooper    => vr_cdcooper
                        ,pr_dsprotocolo => vr_dsprotoc);
      FETCH cr_retbancoob INTO rw_retbancoob;

      IF cr_retbancoob%FOUND THEN
        vr_flganlok := TRUE;
        CLOSE cr_retbancoob;
      ELSE
        CLOSE cr_retbancoob;
        --Solicita retorno do Bancoob
        pc_solicita_retorno_bancoob(pr_cdcooper => vr_cdcooper
                                   ,pr_cdagenci => vr_cdagenci
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctrcrd => pr_nrctrcrd
                                   ,pr_dsprotoc => vr_dsprotoc
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_des_mensagem => pr_des_erro);

        -- verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    END LOOP;
    
    IF NOT vr_flganlok THEN
      vr_dscritic := 'O tempo de envio ao Bancoob excedeu. Favor tentar novamente.';
      RAISE vr_exc_erro;
    END IF;

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'mensagem',
                           pr_tag_cont => pr_des_erro,
                           pr_des_erro => vr_dscritic);

  EXCEPTION
    when vr_exc_continua then
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN vr_exc_erro THEN

      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := NVL(vr_des_mensagem,'NOK');

      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar a solicitação do cartão ao Bancoob: '||SQLERRM;
      pr_des_erro := NVL(vr_des_mensagem,'NOK');

      ROLLBACK;

  END pc_solicitar_cartao_bancoob;

  PROCEDURE pc_solicitar_cartao_bancoob_wb(pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr da conta
                                          ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr do contrato
                                          ,pr_dtmvtolt IN VARCHAR2              --> Data do movimento
                                          ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2 ) IS         --> Erros do processo

    -- Tratamento de exceções
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);

    vr_idx pls_integer;
  BEGIN
      vr_idx:= 0;

      /*  todo - tratar xml e chamar a funcao de solicitar cartao
          todo - controlar xml para retornar erro para o web */

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
      -- Desfazer alterações
      ROLLBACK;

  END pc_solicitar_cartao_bancoob_wb;

  --> Rotina para solicitar retorno do Bancoob
  PROCEDURE pc_solicita_retorno_bancoob(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_cdagenci IN crawcrd.cdagenci%TYPE
                                       ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                                       ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE
                                       ,pr_dsprotoc IN tbgen_webservice_aciona.dsprotocolo%TYPE
                                       ,pr_intipret IN VARCHAR2 DEFAULT 'I' --> Tipo de solicitacao de retorno (I - Inclusão de cartao, A - Alteracao de limite)
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2
                                       ,pr_des_mensagem OUT VARCHAR2) IS         --> Erros do processo
    /* .........................................................................

    Programa : pc_solicita_retorno_bancoob
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Paulo Silva
    Data     : Março/2018                    Ultima atualizacao: 05/04/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para solicitar retorno do Bancoob

    Alteração : 05/04/2019 - Alterar a situação do cartão pra aprovado quando o bancoob
                             retornar critica (Lucas Ranghetti INC0011849)

  ..........................................................................*/


    -- Tratamento de exceções
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic_aux VARCHAR2(4000);

    -- Variáveis auxiliares
    vr_host          VARCHAR2(4000);
    vr_recurso       VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_idacionamento tbgen_webservice_aciona.idacionamento%TYPE;
    vr_dssitret      VARCHAR2(100);
    vr_resultado     VARCHAR2(100);
    vr_dsprotoc      crawcrd.dsprotoc%TYPE;
    vr_usrkey        VARCHAR2(200);
    vr_method        VARCHAR2(100);
    vr_conta_cartao  VARCHAR2(100);
    vr_idusuario     VARCHAR2(100);
    vr_idusuario2    VARCHAR2(100);
    vr_nrcartao      VARCHAR2(100);

    vr_obj_retorno json      := json();
    vr_obj_lst     json_list := json_list();
    vr_request     json0001.typ_http_request;
    vr_request2    json0001.typ_http_request;
    vr_response    json0001.typ_http_response;

    -- Cursores
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Busca acionamentos de retorno de solicitacao de cartão do Bancoob
    CURSOR cr_retbancoob IS
      SELECT idacionamento
            ,dsconteudo_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND cdoperad = 'BANCOOB'
         AND nrdconta = pr_nrdconta
         AND tpacionamento = 2 --> Apenas Retorno
         AND cdorigem  = 5     --> Esteira
         AND tpproduto = 4     --> Apenas Cartão de Crédito
         AND nrctrprp  = pr_nrctrcrd
         AND dsprotocolo = pr_dsprotoc;
    rw_retbancoob cr_retbancoob%ROWTYPE;

   -- Feito como pragma para salvar a alteração da situação do cartão em caso de erro
   procedure pc_atualiza_situacao (pr_cdcooper in crapcop.cdcooper%type,
                                   pr_nrdconta in crapass.nrdconta%type,
                                   pr_nrctrcrd in crawcrd.nrctrcrd%type,
                                   pr_dscritic out varchar2) is
     
      pragma autonomous_transaction;
      begin
        -- Se receber crítica volta para o status de Aprovado para ajustar ou Cancelar a proposta
        -- Altera a situação do Cartão para 1 (Aprovado)
        pc_altera_sit_cartao_bancoob(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctrcrd => pr_nrctrcrd
                                    ,pr_nrseqcrd => NULL
                                    ,pr_insitcrd => 1
                                    ,pr_dscritic => pr_dscritic);
        commit;
      end;

  BEGIN

    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_dscritic:= gene0001.fn_busca_critica(1);
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Desde que não estejamos com processo em execução
    IF rw_crapdat.inproces = 1  THEN

      -- Capturar o protocolo do contrato para apresentar na crítica caso ocorra algum erro
      vr_dsprotoc := pr_dsprotoc;

      -- Carregar parametros para a comunicacao com o Bancoob
      pc_carrega_param_bancoob(pr_cdcooper      => pr_cdcooper,         -- Codigo da cooperativa
                               pr_tipo_ws       => 6, /* WS Consultar Protocolo */
                               pr_host          => vr_host,             -- Host do Bancoob
                               pr_recurso       => vr_recurso,          -- URI do Bancoob
                               pr_method        => vr_method,
                               pr_usrkey        => vr_usrkey,
                               pr_dsdirlog      => vr_dsdirlog    ,     -- Diretorio de log dos arquivos
                               pr_dscritic      => vr_dscritic    );
      -- Se retornou crítica
      IF trim(vr_dscritic)  IS NOT NULL THEN
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;

      vr_request.service_uri := vr_host;
      vr_request.api_route   := vr_recurso;
      vr_request.method      := vr_method;
      vr_request.timeout     := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_BANCOOB');
      vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
      vr_request.headers('User-Key')     := vr_usrkey;

      vr_request.parameters('appOrigem') := '5'; --Ayllos Web
      vr_request.parameters('protocolo') := pr_dsprotoc;

      -- Disparo do REQUEST
      json0001.pc_executa_ws_json(pr_request           => vr_request
                                 ,pr_response          => vr_response
                                 ,pr_diretorio_log     => vr_dsdirlog
                                 ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'
                                 ,pr_dscritic          => vr_dscritic);
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Extrair dados de retorno
      vr_obj_retorno := json(vr_response.content);

      -- Iniciar status
      vr_dssitret := 'TEMPO ESGOTADO';

      -- Resultado
      IF vr_obj_retorno.exist('resultado') THEN
        vr_resultado := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_retorno.get('resultado').to_char(),'"'),'"'),'\u','\')));
      END IF;

      -- Resultado
      IF vr_obj_retorno.exist('descErroResult') THEN
        vr_dssitret := vr_resultado ||' - '|| gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_retorno.get('descErroResult').to_char(),'"'),'"'),'\u','\')));
        vr_dscritic_aux := vr_dssitret;
        
          -- Se receber crítica volta para o status de Aprovado para ajustar ou Cancelar a proposta
          -- Altera a situação do Cartão para 1 (Aprovado)
          pc_atualiza_situacao(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrctrcrd => pr_nrctrcrd                                      
                              ,pr_dscritic => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL THEN
          raise vr_exc_erro;
        END IF;
        
      ELSE
        vr_dssitret := vr_resultado;
      END IF;

      --Verifica se já gravou o protocolo
      OPEN cr_retbancoob;
      FETCH cr_retbancoob INTO rw_retbancoob;

      IF cr_retbancoob%FOUND THEN
        CLOSE cr_retbancoob;

        BEGIN
          UPDATE tbgen_webservice_aciona
             SET dsresposta_requisicao = vr_dssitret
                ,dhacionamento = SYSTIMESTAMP
           WHERE idacionamento = rw_retbancoob.idacionamento;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar retorno do Bancoob. Erro: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        --> Commitar para não perdermos o retorno. No pc_grava_acionamento seria comitado.
        COMMIT;
      ELSE
        CLOSE cr_retbancoob;
        --> Gravar dados log acionamento
        este0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                      pr_cdagenci              => pr_cdagenci,
                                      pr_cdoperad              => 'BANCOOB',
                                      pr_cdorigem              => 5, /*Ayllos*/
                                      pr_nrctrprp              => pr_nrctrcrd,
                                      pr_nrdconta              => pr_nrdconta,
                                      pr_tpacionamento         => 2,  /* 1 - Envio, 2 – Retorno */
                                      pr_tpproduto             => 4, --Cartão de Crédito
                                      pr_tpconteudo            => 1, --Jason
                                      pr_dsoperacao            => 'RETORNO SOLICITACAO BANCOOB',
                                      pr_dsuriservico          => vr_host||'/'||vr_recurso,
                                      pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                      pr_cdstatus_http         => vr_response.status_code,
                                      pr_dsconteudo_requisicao => vr_response.content,
                                      pr_dsresposta_requisicao => vr_dssitret,
                                      pr_dsprotocolo           => pr_dsprotoc,
                                      pr_idacionamento         => vr_idacionamento,
                                      pr_dscritic              => vr_dscritic);

        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      IF vr_response.status_code NOT IN(200,204,429) THEN
        vr_dscritic := 'Não foi possivel consultar informações da solicitação do Bancoob, '||
                       'favor entrar em contato com a equipe responsavel.  '||
                       '(Cod:'||vr_response.status_code||')';
        RAISE vr_exc_erro;
      END IF;

      IF vr_dscritic_aux IS NOT NULL THEN
        vr_dscritic := vr_dscritic_aux;
        RAISE vr_exc_erro;
      END IF;

      /* Vamos verificar se gravou com sucesso, para buscar os
         dados do cartao e conta cartao gerados no Bancoob.
         Resultado esperado "resultado": "1 - Processado com sucesso!" */
      IF TRIM(SUBSTR(vr_resultado,1,2)) = '1' AND
         pr_intipret = 'I' /* Inclusao de cartao */ THEN
      
        BEGIN
          /* Procedimento de busca da conta cartao e numero do cartao
             ficara comentado ate que a Cabal libere o acesso ao
             servico de consulta dados do cartao em producao   */
        
          IF NOT vr_obj_retorno.exist('numeroConta') THEN  
            vr_dscritic := 'Nao foi encontrado conta cartao no retorno do Bancoob';
            RAISE vr_exc_erro;
          END IF;
          vr_conta_cartao := vr_obj_retorno.get('numeroConta').to_char();
          
          vr_obj_lst   := json_list(vr_obj_retorno.get('componentes').to_char());

         -- ajustado para quando e PJ ele gera um cartao ficticio e o segundo e o original
         IF json_ac.array_count(vr_obj_lst) > 1  THEN
           --vr_idusuario  := json(vr_obj_lst.get(1).to_char()).get('idComponente').to_char();
           --vr_idusuario2 := json(vr_obj_lst.get(2).to_char()).get('idComponente').to_char();
           vr_idusuario  := json(vr_obj_lst.get(2).to_char()).get('idComponente').to_char();
         ELSE
           vr_idusuario := json(vr_obj_lst.get(1).to_char()).get('idComponente').to_char();
         END IF;
          
          --======== Agora vamos buscar os dados do cartao gerado bancoob =========
          pc_carrega_param_bancoob(pr_cdcooper      => pr_cdcooper, -- Codigo da cooperativa
                                   pr_tipo_ws       => 5, -- Consultar Dados do Cartao
                                   pr_host          => vr_host,     -- Host do Bancoob
                                   pr_recurso       => vr_recurso,  -- URI do Bancoob
                                   pr_method        => vr_method,
                                   pr_usrkey        => vr_usrkey,
                                   pr_dsdirlog      => vr_dsdirlog, -- Diretorio de log dos arquivos
                                   pr_dscritic      => vr_dscritic );
          -- Se retornou crítica
          IF trim(vr_dscritic)  IS NOT NULL THEN
            -- Levantar exceção
            RAISE vr_exc_erro;
          END IF;
          
          -- Atribuir valores necessarios para comunicacao
          vr_request2.service_uri := vr_host;
          vr_request2.api_route   := vr_recurso;
          vr_request2.method      := vr_method;
          vr_request2.headers('Content-Type') := 'application/json; charset=UTF-8';
          vr_request2.headers('User-Key')     := vr_usrkey;
          vr_request2.content := '{ "appOrigem": "5",
                                    "idComponente": '||vr_idusuario||'
                                  }';

          -- Disparo do REQUEST
          json0001.pc_executa_ws_json(pr_request           => vr_request2
                                     ,pr_response          => vr_response
                                     ,pr_diretorio_log     => vr_dsdirlog
                                     ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'
                                     ,pr_dscritic          => vr_dscritic);

          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
            vr_dscritic := 'Nao foi possivel buscar os dados do portador do Bancoob.';
            RAISE vr_exc_erro;
          END IF;
          
          -- Extrair dados de retorno
          vr_obj_retorno := json(vr_response.content);
          
          IF NOT vr_obj_retorno.exist('cartao') THEN  
            vr_dscritic := 'Nao foram encontrados dados do cartao no retorno do Bancoob';
            RAISE vr_exc_erro;
          END IF;
          -- Troca os caracteres * por 0 (zero), referente a mascara do cartao.
          vr_nrcartao := trim(replace(replace(vr_obj_retorno.get('cartao').to_char(),'*','0'),'"',''));

          -- Altera a situação do Cartão para 2 (Solicitado)
          pc_altera_sit_cartao_bancoob(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctrcrd => pr_nrctrcrd
                                      ,pr_nrseqcrd => NULL
                                      ,pr_insitcrd => 2
                                      ,pr_nrcctitg => vr_conta_cartao
                                      ,pr_nrcrcard => vr_nrcartao
                                      ,pr_dscritic => vr_dscritic);
                                      
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_erro;
          END IF;

          /* Vamos atualizar a conta cartao */
          ccrd0003.pc_insere_conta_cartao(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrconta_cartao => vr_conta_cartao
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
            
        EXCEPTION
          WHEN OTHERS THEN
            IF TRIM(vr_dscritic) IS NULL THEN
               vr_dscritic:= 'Erro na busca dos dados gerados pelo Bancoob: '|| SQLERRM;
            END IF;
            RAISE vr_exc_erro;
        END;
      ELSIF pr_intipret = 'I' THEN
        -- Se receber crítica volta para o status de Aprovado para ajustar ou Cancelar a proposta
        -- Altera a situação do Cartão para 1 (Aprovado)
        pc_altera_sit_cartao_bancoob(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctrcrd => pr_nrctrcrd
                                    ,pr_nrseqcrd => NULL
                                    ,pr_insitcrd => 1
                                    ,pr_dscritic => vr_dscritic);
                                   
        IF vr_dscritic IS NOT NULL THEN
          raise vr_exc_erro;
        END IF;
      
      END IF;
      
      pr_des_mensagem := vr_dssitret;

    END IF;

    -- Gravação para liberação do registro
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      pr_des_mensagem := 'NOK';
      -- Desfazer alterações
      ROLLBACK;
      -- Gerar log
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                 ||' - CCRD0007 --> Erro ao solicitor retorno Protocolo '
                                                 ||vr_dsprotoc||': '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
      pr_des_mensagem := 'NOK';
      -- Desfazer alterações
      ROLLBACK;
      -- Gerar log
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                 ||' - CCRD0007 --> Erro ao solicitor retorno Protocolo '
                                                 ||vr_dsprotoc||': '||sqlerrm,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
  END pc_solicita_retorno_bancoob;


  PROCEDURE pc_solicita_retorno_bancoob_wb(pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                                          ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE
                                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_intipret VARCHAR2(1);

    vr_dsprotoc tbgen_webservice_aciona.dsprotocolo%TYPE;

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic NUMBER;

    CURSOR cr_tbgen_webservice_aciona (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                       pr_nrdconta IN crapass.nrdconta%TYPE,
                                       pr_nrctrprp IN crawcrd.nrctrcrd%TYPE) IS
    SELECT aci.dsprotocolo
          ,aci.dsoperacao
      FROM tbgen_webservice_aciona aci
     WHERE aci.cdcooper = pr_cdcooper
       AND aci.nrdconta = pr_nrdconta
       AND aci.nrctrprp = pr_nrctrprp
       AND aci.cdoperad = 'BANCOOB'
  ORDER BY aci.idacionamento DESC;
  rw_tbgen_webservice_aciona cr_tbgen_webservice_aciona%ROWTYPE;

    vr_dsmensag VARCHAR2(4000);
  BEGIN

    --Verifica se está em contingência
    IF fn_usa_bancoob_ws(pr_cdcooper => pr_cdcooper
                        ,pr_tpoperac => 'R') THEN -- Retorno
      vr_dscritic := 'Bancoob está em contingência. A solicitação será enviada no processo noturno.';
      RAISE vr_exc_erro;
    END IF;
    
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

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
       RAISE vr_exc_erro;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    --Busca protocolo
    OPEN cr_tbgen_webservice_aciona(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctrprp => pr_nrctrcrd);
    FETCH cr_tbgen_webservice_aciona INTO rw_tbgen_webservice_aciona;
    IF cr_tbgen_webservice_aciona%NOTFOUND THEN
       CLOSE cr_tbgen_webservice_aciona;
       vr_cdcritic := 0;
       vr_dscritic := 'Registro de Protocolo nao encontrado!';
       RAISE vr_exc_erro;
    END IF;
    IF trim(rw_tbgen_webservice_aciona.dsprotocolo) IS NULL THEN
       CLOSE cr_tbgen_webservice_aciona;
       vr_cdcritic := 0;
       vr_dscritic := 'Descricao de Protocolo nao encontrada!';
       RAISE vr_exc_erro;
    END IF;
    CLOSE cr_tbgen_webservice_aciona;
    vr_dsprotoc := rw_tbgen_webservice_aciona.dsprotocolo;

    IF (rw_tbgen_webservice_aciona.dsoperacao LIKE '%SOLICITACAO CARTAO%') OR
       (rw_tbgen_webservice_aciona.dsoperacao LIKE '%SOLICITACAO BANCOOB%') THEN
      vr_intipret := 'I';
    ELSE
      vr_intipret := 'A';
    END IF;

    --Solicita retorno do Bancoob
    pc_solicita_retorno_bancoob(pr_cdcooper => vr_cdcooper
                               ,pr_cdagenci => vr_cdagenci
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctrcrd => pr_nrctrcrd
                               ,pr_dsprotoc => vr_dsprotoc
                               ,pr_intipret => vr_intipret
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_des_mensagem => vr_dsmensag);

    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;


    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'mensagem',
                           pr_tag_cont => vr_dsmensag,
                           pr_des_erro => vr_dscritic);
  EXCEPTION
    WHEN vr_exc_erro THEN
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar a busca do retorno do cartão ao Bancoob: '||SQLERRM;

      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_solicita_retorno_bancoob_wb;

  --Solicita alteração de limite de crédito ao Bancoob
  PROCEDURE pc_alterar_cartao_bancoob(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
                                     ,pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr da conta
                                     ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr da conta
                                     ,pr_idorigem IN VARCHAR2              --> Origem
                                     ,pr_vllimite IN crawcrd.vllimdlr%TYPE --> Novo valor do limite
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequência Titular
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    
    /* ..........................................................................

      Programa : pc_alterar_cartao_bancoob
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva
      Data     : Maio/2018.                   Ultima atualizacao: 12/05/2018
      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Solicita alteração de limite de crédito ao Bancoob
      Alteração : 30/07/2018 - Paulo Silva (Supero) - Ajuste nas mensagens de retorno.

    ..........................................................................*/
    
    -- Tratamento de exceções
    vr_exc_erro     EXCEPTION;
    vr_cdcritic     PLS_INTEGER;
    vr_dscritic     VARCHAR2(4000);
    vr_des_mensagem VARCHAR2(4000);
    
        -- Objeto json
    vr_obj_conteudo     json := json();
    vr_obj_lst          json_list := json_list();
    vr_obj_adicional    json := json();
    vr_obj_titular      json := json();
    vr_obj_titular_clob CLOB;
	vr_obj_conteudo_clob CLOB;
    
    --Variáveis Gerais
    vr_dsprotoc VARCHAR2(4000);
    vr_hrenvban NUMBER;
    vr_qtsegund NUMBER;
    vr_flganlok BOOLEAN := FALSE;
    vr_idusuari VARCHAR2(4000);
    vr_idadicio VARCHAR2(4000);
    vr_nrcartao VARCHAR2(4000);
    vr_flgcrd   BOOLEAN := FALSE;
    vr_sucesso  VARCHAR2(4000);
    vr_flgtplim VARCHAR2(1);
    
    --Busca conta cartão
    CURSOR cr_crawcrd is
      SELECT wrd.nrcctitg
            ,crd.nrcrcard
			,wrd.vllimcrd
            ,wrd.cdoperad
        FROM crapcrd crd
            ,crawcrd wrd
       WHERE wrd.cdcooper = pr_cdcooper
         AND wrd.nrdconta = pr_nrdconta
         AND wrd.nrctrcrd = pr_nrctrcrd
         AND wrd.cdcooper = crd.cdcooper
         AND wrd.nrdconta = crd.nrdconta
         AND wrd.nrctrcrd = crd.nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
    -- Busca acionamentos de retorno de solicitacao de cartão do Bancoob
    CURSOR cr_retbancoob(pr_cdcooper    tbgen_webservice_aciona.cdcooper%TYPE
                        ,pr_dsprotocolo tbgen_webservice_aciona.dsprotocolo%TYPE) IS
      SELECT idacionamento
            ,dsconteudo_requisicao
			,dsresposta_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND cdoperad = 'BANCOOB'
         AND nrdconta = pr_nrdconta
         AND tpacionamento = 2 --> Apenas Retorno
         AND cdorigem  = 5     --> Bancoob
         AND tpproduto = 4     --> Apenas Cartão de Crédito
         AND nrctrprp  = pr_nrctrcrd
         AND dsprotocolo = pr_dsprotocolo;
         /* AND TO_CHAR(dsresposta_requisicao) = '1 - Processado com sucesso!'; */
    rw_retbancoob cr_retbancoob%ROWTYPE;
    
  BEGIN
    
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
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
    
    OPEN cr_crawcrd;
    FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;
    
    --Se for titular
    IF pr_idseqttl = 1 THEN
    
      vr_flgtplim := 'G';
    
      -- Montar os atributos
      vr_obj_titular := json();
        
      vr_obj_titular.put('appOrigem' ,5 /* CECRED */);
      vr_obj_titular.put('conta'     ,rw_crawcrd.nrcctitg);
      vr_obj_titular.put('novoLimite',pr_vllimite);
      vr_obj_titular.put('usuario'   ,'CECRED');
      
       -- Criar o CLOB para converter JSON para CLOB
      dbms_lob.createtemporary(vr_obj_titular_clob, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_obj_titular_clob, dbms_lob.lob_readwrite);
      json.to_clob(vr_obj_titular,vr_obj_titular_clob);

      -- Chama o webservice do Bancoob
      pc_enviar_bancoob(pr_cdcooper     => pr_cdcooper,          --> Codigo da cooperativa
                        pr_cdagenci     => pr_cdagenci,          --> Codigo da agencia
                        pr_cdoperad     => pr_cdoperad,          --> codigo do operador
                        pr_cdorigem     => pr_idorigem,          --> Origem da operacao
                        pr_nrdconta     => pr_nrdconta,          --> Numero da conta do cooperado
                        pr_nrctrcrd     => pr_nrctrcrd,          --> Numero da proposta de cartão
                        pr_dtmvtolt     => rw_crapdat.dtmvtolt,  --> Data do movimento
                        --pr_comprecu     => 'COMPL_URI_ALTLT_BANCOOB',--> Complemento do recuros da URI
                        pr_comprecu     => NULL,                 --> Complemento do recuros da URI
                        pr_dsmetodo     => 'POST',               --> Descricao do metodo
                        pr_conteudo     => vr_obj_titular_clob,  --> Conteudo no Json para comunicacao
                        pr_dsoperacao   => 'ENVIO ALTERACAO LIMITE TITULAR BANCOOB',  --> Operacao realizada
                        pr_tipo_ws      => 2,                    --> WS - Alteracao Limite Titular
                        pr_dsprotocolo  => vr_dsprotoc,          --> Protocolo retornado na requisição
                        pr_dscritic     => vr_dscritic,
                        pr_des_mensagem => vr_des_mensagem);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_obj_titular_clob);
      dbms_lob.freetemporary(vr_obj_titular_clob);
      
      --Atualiza Histórico do Limite de Crédito
      tela_atenda_cartaocredito.pc_altera_limite_crd(pr_cdcooper => pr_cdcooper
                                                    ,pr_cdoperad => pr_cdoperad
                                                    ,pr_nrdconta => pr_nrdconta
                                                    ,pr_nrctrcrd => pr_nrctrcrd
                                                    ,pr_vllimite => pr_vllimite
                                                    ,pr_dsprotoc => vr_dsprotoc
                                                    ,pr_dsjustif => NULL
                                                    ,pr_flgtplim => vr_flgtplim
                                                    ,pr_idorigem => 15--Bancoob
                                                    ,pr_tpsituac => 2 --> Enviado ao Bancoob
                                                    ,pr_insitdec => NULL
                                                    ,pr_nmdatela => NULL
                                                    ,pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic
                                                    ,pr_des_erro => vr_des_mensagem
                                                    );
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      vr_hrenvban := to_char(SYSDATE,'sssss');
      
      -- Buscar a quantidade de segundos de espera pelo retorno do Bancoob
      vr_qtsegund := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'TIMEOUT_CONEXAO_BANCOOB'),30);
      
      -- Efetuar laço para esperarmos (N) segundos ou o termino da analise recebido via POST
      WHILE NOT vr_flganlok AND TO_NUMBER(TO_CHAR(SYSDATE,'sssss')) - vr_hrenvban < vr_qtsegund LOOP

        -- Aguardar 0.5 segundo para evitar sobrecarga de processador
        sys.dbms_lock.sleep(0.5);

        --Verifica se já gravou o protocolo
        OPEN cr_retbancoob(pr_cdcooper    => pr_cdcooper
                          ,pr_dsprotocolo => vr_dsprotoc);
        FETCH cr_retbancoob INTO rw_retbancoob;

        IF cr_retbancoob%FOUND THEN
          CLOSE cr_retbancoob;
          
          IF UPPER(TO_CHAR(rw_retbancoob.dsresposta_requisicao)) LIKE '%SUCESSO%' THEN
             vr_flganlok := TRUE;
          ELSE
            vr_dscritic := TO_CHAR(rw_retbancoob.dsresposta_requisicao);
            RAISE vr_exc_erro;
          END IF;
        ELSE
          CLOSE cr_retbancoob;
                    
          --Solicita retorno do Bancoob
          pc_solicita_retorno_bancoob(pr_cdcooper     => pr_cdcooper
                                     ,pr_cdagenci     => pr_cdagenci
                                     ,pr_nrdconta     => pr_nrdconta
                                     ,pr_nrctrcrd     => pr_nrctrcrd
                                     ,pr_dsprotoc     => vr_dsprotoc
                                     ,pr_intipret     => 'A'
                                     ,pr_cdcritic     => vr_cdcritic
                                     ,pr_dscritic     => vr_dscritic
                                     ,pr_des_mensagem => vr_des_mensagem);
          -- verificar se retornou critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END LOOP;
	  
	    IF NOT vr_flganlok THEN
        vr_dscritic := 'O tempo de envio do ao Bancoob excedeu. Favor tentar novamente.';
        RAISE vr_exc_erro;
      END IF;

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      ELSE
        pc_altera_limite_proposta(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctrcrd => pr_nrctrcrd
                                 ,pr_vllimite => pr_vllimite
                                 ,pr_nrcctitg => rw_crawcrd.nrcctitg
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
        --Atualiza Histórico do Limite de Crédito
        tela_atenda_cartaocredito.pc_altera_limite_crd(pr_cdcooper => pr_cdcooper
                                                      ,pr_cdoperad => pr_cdoperad
                                                      ,pr_nrdconta => pr_nrdconta
                                                      ,pr_nrctrcrd => pr_nrctrcrd
                                                      ,pr_vllimite => pr_vllimite
                                                      ,pr_dsprotoc => vr_dsprotoc
                                                      ,pr_dsjustif => NULL
                                                      ,pr_flgtplim => vr_flgtplim
                                                      ,pr_idorigem => 15--Bancoob
                                                      ,pr_tpsituac => 3 --> Concluído com Sucesso
                                                      ,pr_insitdec => NULL
                                                      ,pr_nmdatela => NULL
                                                      ,pr_cdcritic => vr_cdcritic
                                                      ,pr_dscritic => vr_dscritic
                                                      ,pr_des_erro => vr_des_mensagem
                                                      );
        
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        vr_des_mensagem := 'Alteração realizada com sucesso.';
      END IF;
    ELSE
      
      vr_flgtplim := 'A';
      
      --Monta consulta Dados Portador
      --Monta Json Conteúdo
      vr_obj_conteudo := json();
      
      vr_obj_conteudo.put('appOrigem'   ,pr_idorigem);
      vr_obj_conteudo.put('numeroCuenta',rw_crawcrd.nrcctitg);
      vr_obj_conteudo.put('componente'  ,'01');

	  -- Criar o CLOB para converter JSON para CLOB
      dbms_lob.createtemporary(vr_obj_conteudo_clob, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_obj_conteudo_clob, dbms_lob.lob_readwrite);
      json.to_clob(vr_obj_conteudo,vr_obj_conteudo_clob);

      --Consulta Dados Portador
      pc_enviar_bancoob_alt(pr_cdcooper     => pr_cdcooper,  --> Codigo da cooperativa
                        pr_cdagenci     => pr_cdagenci,  --> Codigo da agencia
                        pr_cdoperad     => pr_cdoperad,  --> codigo do operador
                        pr_cdorigem     => pr_idorigem,  --> Origem da operacao
                        pr_nrdconta     => pr_nrdconta,  --> Numero da conta do cooperado
                        pr_nrctrcrd     => pr_nrctrcrd,  --> Numero da proposta de cartão
                        pr_dtmvtolt     => rw_crapdat.dtmvtolt,           --> Data do movimento
                        pr_comprecu     => 'COMPL_URI_CONSDP_BANCOOB',     --> Complemento do recuros da URI
                        pr_dsmetodo     => 'GET',        --> Descricao do metodo
                        pr_conteudo     => vr_obj_conteudo_clob,         --> Conteudo no Json para comunicacao
                        pr_dsoperacao   => 'CONSULTA DADOS PORTADOR BANCOOB', --> Operacao realizada
                        pr_dsprotocolo  => vr_dsprotoc,                   --> Protocolo retornado na requisição
                        pr_obj_conteudo => vr_obj_conteudo,
                        pr_dscritic     => vr_dscritic,
                        pr_des_mensagem => vr_des_mensagem);
						
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_obj_conteudo_clob);
      dbms_lob.freetemporary(vr_obj_conteudo_clob);

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Código Retorno
      IF vr_obj_conteudo.exist('codRetorno') THEN
        vr_dscritic := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_conteudo.get('codRetorno').to_char(),'"'),'"'),'\u','\')));
      END IF;
        
      -- Mensagem Retorno
      IF vr_obj_conteudo.exist('mensagemRetorno') THEN
        vr_dscritic := vr_dscritic ||' - '|| gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_conteudo.get('mensagemRetorno').to_char(),'"'),'"'),'\u','\')));
      END IF;
      
      -- ID Usuário
      IF vr_obj_conteudo.exist('idUsuario') THEN
        vr_idusuari := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_conteudo.get('idUsuario').to_char(),'"'),'"'),'\u','\')));
      END IF;
      
      IF vr_dscritic LIKE '%500%' THEN
        RAISE vr_exc_erro;
      END IF;
      
      --Monta consulta Adicionais
      --Monta Json Conteúdo
      vr_obj_conteudo := json();
     
      vr_obj_conteudo.put('appOrigem',pr_idorigem);
      vr_obj_conteudo.put('idUsuario',vr_idusuari);
      vr_obj_conteudo.put('tipoConta','1');

      -- Criar o CLOB para converter JSON para CLOB
      dbms_lob.createtemporary(vr_obj_conteudo_clob, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_obj_conteudo_clob, dbms_lob.lob_readwrite);
      json.to_clob(vr_obj_conteudo,vr_obj_conteudo_clob);

      --Consulta Adicionais
      pc_enviar_bancoob_alt(pr_cdcooper     => pr_cdcooper,  --> Codigo da cooperativa
                        pr_cdagenci     => pr_cdagenci,  --> Codigo da agencia
                        pr_cdoperad     => pr_cdoperad,  --> codigo do operador
                        pr_cdorigem     => pr_idorigem,  --> Origem da operacao
                        pr_nrdconta     => pr_nrdconta,  --> Numero da conta do cooperado
                        pr_nrctrcrd     => pr_nrctrcrd,  --> Numero da proposta de cartão
                        pr_dtmvtolt     => rw_crapdat.dtmvtolt,           --> Data do movimento
                        pr_comprecu     => 'COMPL_URI_CONSAD_BANCOOB',     --> Complemento do recuros da URI
                        pr_dsmetodo     => 'GET',        --> Descricao do metodo
                        pr_conteudo     => vr_obj_conteudo_clob,         --> Conteudo no Json para comunicacao
                        pr_dsoperacao   => 'CONSULTA ADICIONAIS BANCOOB', --> Operacao realizada
                        pr_dsprotocolo  => vr_dsprotoc,                   --> Protocolo retornado na requisição
                        pr_obj_conteudo => vr_obj_conteudo,
                        pr_dscritic     => vr_dscritic,
                        pr_des_mensagem => vr_des_mensagem);
	  
	  -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_obj_conteudo_clob);
      dbms_lob.freetemporary(vr_obj_conteudo_clob);
	  

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Código Retorno
      IF vr_obj_conteudo.exist('codRetorno') THEN
        pr_des_erro := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_conteudo.get('codRetorno').to_char(),'"'),'"'),'\u','\')));
      END IF;
        
      -- Mensagem Retorno
      IF vr_obj_conteudo.exist('mensagemRetorno') THEN
        pr_des_erro := pr_des_erro ||' - '|| gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_conteudo.get('mensagemRetorno').to_char(),'"'),'"'),'\u','\')));
      END IF;
      
      -- Lista Adicionais
      IF vr_obj_conteudo.exist('listAdicionais') THEN
        vr_obj_lst := json_list(vr_obj_conteudo.get('listAdicionais').to_char());
        
        -- Para cada adicional
        FOR vr_idx IN 1..vr_obj_lst.count() LOOP
          BEGIN
            vr_obj_adicional := json(vr_obj_lst.get(vr_idx));
                  
            -- Se encontrar o atributo id
            IF vr_obj_adicional.exist('id') THEN
              vr_idadicio := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_adicional.get('id').to_char(),'"'),'"'),'\u','\')));
            END IF;
            
            -- Se encontrar o atributo nroMascarado
            IF vr_obj_adicional.exist('nroMascarado') THEN
              vr_nrcartao := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_adicional.get('nroMascarado').to_char(),'"'),'"'),'\u','\')));
            END IF;
            
            IF substr(vr_nrcartao,1,instr(vr_nrcartao,'*')-1)||'%'||substr(vr_nrcartao,instr(vr_nrcartao,'*',-1)+1) =
               substr(rw_crawcrd.nrcrcard,1,instr(vr_nrcartao,'*')-1)||'%'||substr(rw_crawcrd.nrcrcard,instr(vr_nrcartao,'*',-1)+1) THEN
              vr_flgcrd := TRUE;
            END IF;
                  
          EXCEPTION
            WHEN OTHERS THEN
              NULL; -- Ignorar essa linha
          END;
        END LOOP;
      END IF;
      
      --Monta consulta Adicionais
      --Monta Json Conteúdo
      vr_obj_conteudo := json();
     
      vr_obj_conteudo.put('idAdicional',vr_idadicio);
      vr_obj_conteudo.put('novoLimite' ,pr_vllimite);
      vr_obj_conteudo.put('idUsuario'  ,vr_idusuari);
      vr_obj_conteudo.put('appOrigem'  ,pr_idorigem);
      vr_obj_conteudo.put('tipoConta'  ,'1');

      -- Criar o CLOB para converter JSON para CLOB
      dbms_lob.createtemporary(vr_obj_conteudo_clob, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_obj_conteudo_clob, dbms_lob.lob_readwrite);
      json.to_clob(vr_obj_conteudo,vr_obj_conteudo_clob);

      --Consulta Adicionais
      pc_enviar_bancoob_alt(pr_cdcooper     => pr_cdcooper,  --> Codigo da cooperativa
                        pr_cdagenci     => pr_cdagenci,  --> Codigo da agencia
                        pr_cdoperad     => pr_cdoperad,  --> codigo do operador
                        pr_cdorigem     => pr_idorigem,  --> Origem da operacao
                        pr_nrdconta     => pr_nrdconta,  --> Numero da conta do cooperado
                        pr_nrctrcrd     => pr_nrctrcrd,  --> Numero da proposta de cartão
                        pr_dtmvtolt     => rw_crapdat.dtmvtolt,           --> Data do movimento
                        pr_comprecu     => 'COMPL_URI_ALTLA_BANCOOB',     --> Complemento do recuros da URI
                        pr_dsmetodo     => 'GET',        --> Descricao do metodo
                        pr_conteudo     => vr_obj_conteudo_clob,         --> Conteudo no Json para comunicacao
                        pr_dsoperacao   => 'SOLICITA ALTERACAO LIMITE BANCOOB', --> Operacao realizada
                        pr_dsprotocolo  => vr_dsprotoc,                   --> Protocolo retornado na requisição
                        pr_obj_conteudo => vr_obj_conteudo,
                        pr_dscritic     => vr_dscritic,
                        pr_des_mensagem => vr_des_mensagem);
						
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_obj_conteudo_clob);
      dbms_lob.freetemporary(vr_obj_conteudo_clob);

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      --Atualiza Histórico do Limite de Crédito
      tela_atenda_cartaocredito.pc_altera_limite_crd(pr_cdcooper => pr_cdcooper
                                                    ,pr_cdoperad => pr_cdoperad
                                                    ,pr_nrdconta => pr_nrdconta
                                                    ,pr_nrctrcrd => pr_nrctrcrd
                                                    ,pr_vllimite => pr_vllimite
                                                    ,pr_dsprotoc => vr_dsprotoc
                                                    ,pr_dsjustif => NULL
                                                    ,pr_flgtplim => vr_flgtplim
                                                    ,pr_idorigem => 15--Bancoob
                                                    ,pr_tpsituac => 2 --> Enviado ao Bancoob
                                                    ,pr_insitdec => NULL
                                                    ,pr_nmdatela => NULL
                                                    ,pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic
                                                    ,pr_des_erro => vr_des_mensagem
                                                    );
      
	    IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Código Retorno
      IF vr_obj_conteudo.exist('codRetorno') THEN
        pr_des_erro := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_conteudo.get('codRetorno').to_char(),'"'),'"'),'\u','\')));
      END IF;
        
      -- Mensagem Retorno
      IF vr_obj_conteudo.exist('mensagemRetorno') THEN
        pr_des_erro := pr_des_erro ||' - '|| gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_conteudo.get('mensagemRetorno').to_char(),'"'),'"'),'\u','\')));
      END IF;
      
      IF vr_obj_conteudo.exist('sucesso') THEN
        vr_sucesso := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_conteudo.get('sucesso').to_char(),'"'),'"'),'\u','\')));
      END IF;
      
      -- Se existe o objeto de Numero Novidade
      IF vr_obj_conteudo.exist('numeroNovidade') THEN
        vr_dsprotoc := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_conteudo.get('numeroNovidade').to_char(),'"'),'"'),'\u','\')));
      END IF;
      
      IF upper(vr_sucesso) = 'TRUE' THEN
        --Solicita retorno do Bancoob
        pc_solicita_retorno_bancoob(pr_cdcooper     => pr_cdcooper
                                   ,pr_cdagenci     => pr_cdagenci
                                   ,pr_nrdconta     => pr_nrdconta
                                   ,pr_nrctrcrd     => pr_nrctrcrd
                                   ,pr_dsprotoc     => vr_dsprotoc
                                   ,pr_intipret     => 'A'
                                   ,pr_cdcritic     => vr_cdcritic
                                   ,pr_dscritic     => vr_dscritic
                                   ,pr_des_mensagem => vr_des_mensagem);
        -- verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
        pc_altera_limite_proposta(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctrcrd => pr_nrctrcrd
                                 ,pr_vllimite => pr_vllimite
                                 ,pr_nrcctitg => rw_crawcrd.nrcctitg
								                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_dscritic => vr_dscritic);
        
        pr_des_erro := 'OK';
		
		    --Atualiza Histórico do Limite de Crédito
        tela_atenda_cartaocredito.pc_altera_limite_crd(pr_cdcooper => pr_cdcooper
                                                      ,pr_cdoperad => pr_cdoperad
                                                      ,pr_nrdconta => pr_nrdconta
                                                      ,pr_nrctrcrd => pr_nrctrcrd
                                                      ,pr_vllimite => pr_vllimite
                                                      ,pr_dsprotoc => vr_dsprotoc
                                                      ,pr_dsjustif => NULL
                                                      ,pr_flgtplim => vr_flgtplim
                                                      ,pr_idorigem => 15--Bancoob
                                                      ,pr_tpsituac => 3 --> Concluído com Sucesso
                                                      ,pr_insitdec => NULL
                                                      ,pr_nmdatela => NULL
                                                      ,pr_cdcritic => vr_cdcritic
                                                      ,pr_dscritic => vr_dscritic
                                                      ,pr_des_erro => vr_des_mensagem
                                                      );

        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
        vr_dscritic := pr_des_erro;
        RAISE vr_exc_erro;
      END IF;
    END IF;

    COMMIT;    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
	  
	  --Atualiza Histórico do Limite de Crédito
      tela_atenda_cartaocredito.pc_altera_limite_crd(pr_cdcooper => pr_cdcooper
                                                    ,pr_cdoperad => pr_cdoperad
                                                    ,pr_nrdconta => pr_nrdconta
                                                    ,pr_nrctrcrd => pr_nrctrcrd
                                                    ,pr_vllimite => pr_vllimite
                                                    ,pr_dsprotoc => vr_dsprotoc
                                                    ,pr_dsjustif => NULL
                                                    ,pr_flgtplim => vr_flgtplim
                                                    ,pr_idorigem => 15--Bancoob
                                                    ,pr_tpsituac => 4 --> Crítica
                                                    ,pr_insitdec => NULL
                                                    ,pr_nmdatela => NULL
                                                    ,pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic
                                                    ,pr_des_erro => vr_des_mensagem
                                                    );
      
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar a solicitação de alteração do cartão no Bancoob: '||SQLERRM;
      pr_des_erro := 'NOK';

      --Atualiza Histórico do Limite de Crédito
      tela_atenda_cartaocredito.pc_altera_limite_crd(pr_cdcooper => pr_cdcooper
                                                    ,pr_cdoperad => pr_cdoperad
                                                    ,pr_nrdconta => pr_nrdconta
                                                    ,pr_nrctrcrd => pr_nrctrcrd
                                                    ,pr_vllimite => pr_vllimite
                                                    ,pr_dsprotoc => vr_dsprotoc
                                                    ,pr_dsjustif => NULL
                                                    ,pr_flgtplim => vr_flgtplim
                                                    ,pr_idorigem => 15--Bancoob
                                                    ,pr_tpsituac => 4 --> Crítica
                                                    ,pr_insitdec => NULL
                                                    ,pr_nmdatela => NULL
                                                    ,pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic
                                                    ,pr_des_erro => vr_des_mensagem
                                                    );
      ROLLBACK;
  END pc_alterar_cartao_bancoob;
  
  --Chamada solicitação cartão Bancoob via Web
  PROCEDURE pc_alterar_cartao_bancoob_wb(pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr da conta
                                        ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr do contrato
                                        ,pr_vllimite IN crawcrd.vllimdlr%TYPE --> Novo valor do limite
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequência Titular
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2 ) IS        --> Erros do processo
  
  /* ..........................................................................

      Programa : pc_alterar_cartao_bancoob_wb
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva
      Data     : Maio/2018.                   Ultima atualizacao: 12/05/2018
      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a inclusao da proposta para o Bancoob
      Alteração :

    ..........................................................................*/
  
    -- Tratamento de exceções
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic NUMBER;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CCRD0007';       --> Código do programa
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
                             
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
       RAISE vr_exc_erro; 
    END IF;
                             
    -- Incluir nome do modulo logado
    gene0001.pc_informa_acesso(pr_module => vr_cdprogra
                              ,pr_action => vr_nmeacao);
  
    --Verifica se está em contingência
    IF fn_usa_bancoob_ws(pr_cdcooper => vr_cdcooper
                        ,pr_tpoperac => 'L') THEN -- Alteracao do limite
      vr_dscritic := 'Bancoob está em contingência. A solicitação será enviada no processo noturno.';
      RAISE vr_exc_erro;
    END IF;
  
    --Chama alteração de limite do cartão Bancoob
    pc_alterar_cartao_bancoob(pr_cdcooper => vr_cdcooper
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_idorigem => vr_idorigem
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctrcrd => pr_nrctrcrd
                             ,pr_vllimite => pr_vllimite
                             ,pr_idseqttl => pr_idseqttl
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_des_erro => pr_des_erro
                             );
                               
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
       RAISE vr_exc_erro; 
    END IF;
    
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'mensagem',
                           pr_tag_cont => pr_des_erro,
                           pr_des_erro => vr_dscritic);
      
      
  EXCEPTION
    WHEN vr_exc_erro THEN
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar a alteração de limite do cartão ao Bancoob: '||SQLERRM;
      
      ROLLBACK;
      
  END pc_alterar_cartao_bancoob_wb;
  
  PROCEDURE pc_busca_valor_sugerido_motor(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo cooperativa                                        
                                         ,pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr da conta
                                         ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr da proposta
                                         ,pr_dsprotoc IN OUT tbgen_webservice_aciona.dsprotocolo%TYPE --> Protocolo do motor
                                         ,pr_vlsugmot OUT crawcrd.vllimcrd%TYPE --> Valor sugerido pelo motor
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
   
   vr_exc_saida  EXCEPTION; 
   vr_dscritic   VARCHAR2(4000);
   vr_cdcritic   NUMBER := 0;
   
   vr_vllimsug  NUMBER;
   vr_codcateg  VARCHAR2(400);
   
   vr_obj       cecred.json := json();
   vr_obj_lst   json_list := json_list();
   vr_obj_crd   cecred.json := json();
   vr_obj_anl   cecred.json := json();
  
   CURSOR cr_aciona (pr_dsprotoc tbgen_webservice_aciona.dsprotocolo%TYPE) IS
     SELECT *
       FROM tbgen_webservice_aciona web
      WHERE web.dsprotocolo = pr_dsprotoc
      ORDER BY web.idacionamento desc;
     rw_aciona cr_aciona%ROWTYPE;
     
   CURSOR cr_crawcrd (pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE
                     ,pr_nrctrcrd crawcrd.nrctrcrd%TYPE) IS
     SELECT crd.cdadmcrd
       FROM crawcrd crd
      WHERE crd.cdcooper = pr_cdcooper
        AND crd.nrdconta = pr_nrdconta
        AND crd.nrctrcrd = pr_nrctrcrd;
   rw_crawcrd cr_crawcrd%ROWTYPE;
  BEGIN
    
    OPEN cr_crawcrd (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrctrcrd => pr_nrctrcrd);
    FETCH cr_crawcrd INTO rw_crawcrd;
    IF cr_crawcrd%NOTFOUND THEN
      vr_dscritic := 'Proposta '||pr_nrctrcrd||'nao encontrada';
      RAISE vr_exc_saida;
    END IF;
  
    IF (TRIM(pr_dsprotoc) IS NOT NULL) THEN
      -- Se veio o protocolo eh tudo mais facil.
      OPEN cr_aciona(pr_dsprotoc => pr_dsprotoc);
      FETCH cr_aciona INTO rw_aciona;
      IF cr_aciona%NOTFOUND THEN
        CLOSE cr_aciona;
        vr_dscritic := 'Protocolo '|| pr_dsprotoc ||' não localizado!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_aciona;
      
      BEGIN
        vr_obj := json(rw_aciona.dsconteudo_requisicao);
        vr_obj_anl := json(vr_obj.get('indicadoresGeradosRegra').to_char());
        vr_obj_lst := json_list(vr_obj_anl.get('sugestaoCartaoCecred').to_char());
              
        FOR vr_idx IN 1..vr_obj_lst.count() LOOP
          vr_obj_crd := json( vr_obj_lst.get(vr_idx));
          vr_codcateg := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_crd.get('codigoCategoria').to_char(),'"'),'"'),'\u','\')));
                  
          IF vr_codcateg = rw_crawcrd.cdadmcrd THEN
            vr_vllimsug := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_crd.get('vlLimite').to_char(),'"'),'"'),'\u','\')));
            EXIT;
          END IF;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Falha na busca do valor sugerido pelo Motor: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      --> Carrega o resultado da busca do JSON.
      pr_vlsugmot := vr_vllimsug;
      
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := 'Não foi possivel encontrar o valor sugerido do Motor: '||SQLERRM;
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;    
    
  END pc_busca_valor_sugerido_motor;

END CCRD0007;
/
