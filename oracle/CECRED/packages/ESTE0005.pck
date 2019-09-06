CREATE OR REPLACE PACKAGE CECRED."ESTE0005" is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0005
      Sistema  : Rotinas de Cartões de Crédito/Débito que utilizam comunicação com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Paulo Roberto da Silva - Supero
      Data     : Fevereiro/2018.                   Ultima atualizacao: 11/02/2019

      Dados referentes ao programa:

      Objetivo  : Para solicitações e alterações de limites de credito de cartões utilizar a comunicação com O Motor e a Esteira de Crédito da IBRATAN.

      Alteracoes: 11/02/2019 - P442 - Mudança no teste de bloqueio ou não do PreAprovado (Marcos-Envolti)

  ---------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_verifica_regras_esteira (pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                        ---- OUT ----
                                        pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                        pr_dscritic OUT VARCHAR2);              --> Descricao da critica

  --> Rotina responsavel por montar o objeto json para analise
  PROCEDURE pc_gera_json_motor(pr_cdcooper   IN crapass.cdcooper%TYPE   --> Codigo da cooperativa
                              ,pr_cdagenci   IN crapass.cdagenci%TYPE   --> Codigo da agencia
                              ,pr_nrdconta   IN crapass.nrdconta%TYPE   --> Número da conta
                              ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE   --> Número do Contrato
                              ,pr_tpproces   IN VARCHAR2                --> Tipo Processo (I-Inclusão, A-Alteração)
                              ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Código Operador
                              ---- OUT ----
                              ,pr_dsjsonan  OUT NOCOPY json             --> Retorno do clob em modelo json com os dados para analise
                              ,pr_cdcritic  OUT NUMBER                  --> Codigo da critica
                              ,pr_dscritic  OUT VARCHAR2);              --> Descricao da critica

  --> Rotina responsavel por gerar a inclusao da proposta para o motor
  PROCEDURE pc_solicita_sugestao_mot (pr_cdcooper  IN crapcop.cdcooper%TYPE
                                     ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                     ,pr_cdorigem  IN INTEGER
                                     ,pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                     ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                     ,pr_tpproces  IN VARCHAR2 DEFAULT 'I'
                                     ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE DEFAULT NULL
                                     ---- OUT ----
                                     ,pr_dsmensag OUT VARCHAR2
                                     ,pr_cdcritic OUT NUMBER
                                     ,pr_dscritic OUT VARCHAR2);

  -- Rotina para solicitar analises não respondidas via POST ou solicitar a proposta enviada
  PROCEDURE pc_solicita_retorno_analise(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                                       ,pr_dsprotoc IN crawcrd.dsprotoc%TYPE);

  --> Rotina responsavel por gerar a inclusao da proposta para a esteira
  PROCEDURE pc_incluir_proposta_est (pr_cdcooper  IN crapcop.cdcooper%TYPE
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                    ,pr_cdorigem  IN INTEGER
                                    ,pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                    ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                    ,pr_nmarquiv  IN VARCHAR2
                                     ---- OUT ----
                                    ,pr_dsmensag OUT VARCHAR2
                                    ,pr_cdcritic OUT NUMBER
                                    ,pr_dscritic OUT VARCHAR2);

  --> Rotina responsavel por gerar a alteracao da proposta para a esteira
  PROCEDURE pc_alterar_proposta_est(pr_cdcooper  IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                    pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia
                                    pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                    pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                    pr_nrdconta  IN crawcrd.nrdconta%TYPE,  --> Numero da conta do cooperado
                                    pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE,  --> Numero da proposta de emprestimo
                                    pr_flreiflx  IN INTEGER,                --> Indica se deve reiniciar o fluxo de aprovacao na esteira (1-true, 0-false)
                                    pr_nmarquiv  IN VARCHAR2,            --> Nome do arquivo PDF
                                    ---- OUT ----
                                    pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                    pr_dscritic OUT VARCHAR2);              --> Descricao da critica

  --> Rotina responsavel por gerar efetivacao da proposta para a esteira
  PROCEDURE pc_efetivar_proposta_est( pr_cdcooper  IN crawcrd.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawcrd.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE,  --> Numero da proposta de cartao
                                      pr_nrctrest  IN crawcrd.nrctrcrd%TYPE DEFAULT NULL,    --> Numero do contrato original da esteira (tratamento limite credito)
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento
                                      pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de cartao de credito
                                      pr_tpregistro IN VARCHAR2,              --> Tipo de regitro I - Solicitação cartão, A - Alteração de Limite
                                      ---- OUT ----
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);
END ESTE0005;
/
CREATE OR REPLACE PACKAGE BODY CECRED."ESTE0005" IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0005
      Sistema  : Rotinas de Cartões de Crédito/Débito que utilizam comunicação com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Paulo Roberto da Silva
      Data     : Fevereiro/2018.                   Ultima atualizacao: 29/03/2019

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Para solicitações e alterações de limites de credito de cartões utilizar a comunicação com O Motor e a Esteira de Crédito da IBRATAN.

      Alteracoes: 03/09/2018 - P450 - Ajuste na tag causouPrejuizoCoop e criação da tag estaEmPrejuizoCoop
                               (Diego Simas/AMcom)

                  29/03/2019 - Ajustar cr_limatu pois estava buscando na ordem errada
                               na pc_incluir_proposta_est (Lucas Ranghetti PRB0040718)

                  18/04/2019 - P637 - Fazer a chamada da pc_gera_json_pessoa_ass da ESTE0002
                               (Luciano Kienolt - Supero)

                  06/06/2019 - incluido variavel vr_nrctrcrd_aux para passar na tela analise credito - PRJ438 - Paulo Martins

                  14/08/2019 - P450 - Inclusão do modeloRating na pc_gera_json_motor para informar o tipo de calculo que
                               Ibratan deve calcular e retornar do Rating definido na PARRAT
                               Luiz Otavio Olinger Momm - AMCOM

  ---------------------------------------------------------------------------------------------------------------*/

  -- Cursor generico de calendario
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  vr_nrctrcrd_aux crawcrd.nrctrcrd%TYPE;

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
        RETURN nvl(replace(vr_obj_content.get('descricao').to_char(),'"'),replace(vr_obj_content.get('data').to_char(),'"'));
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

  --> Rotina responsavel por gravar registro de log de acionamento
  PROCEDURE pc_grava_acionamento(pr_cdcooper                 IN tbgen_webservice_aciona.cdcooper%TYPE,
                                 pr_cdagenci                 IN tbgen_webservice_aciona.cdagenci_acionamento%TYPE,
                                 pr_cdoperad                 IN tbgen_webservice_aciona.cdoperad%TYPE,
                                 pr_cdorigem                 IN tbgen_webservice_aciona.cdorigem%TYPE,
                                 pr_nrctrprp                 IN tbgen_webservice_aciona.nrctrprp%TYPE,
                                 pr_nrdconta                 IN tbgen_webservice_aciona.nrdconta%TYPE,
                                 pr_tpacionamento            IN tbgen_webservice_aciona.tpacionamento%TYPE,
                                 pr_dsoperacao               IN tbgen_webservice_aciona.dsoperacao%TYPE,
                                 pr_dsuriservico             IN tbgen_webservice_aciona.dsuriservico%TYPE,
                                 pr_dtmvtolt                 IN tbgen_webservice_aciona.dtmvtolt%TYPE,
                                 pr_dhacionamento            IN tbgen_webservice_aciona.dhacionamento%TYPE DEFAULT SYSTIMESTAMP,
                                 pr_cdstatus_http            IN tbgen_webservice_aciona.cdstatus_http%TYPE,
                                 pr_dsconteudo_requisicao    IN tbgen_webservice_aciona.dsconteudo_requisicao%TYPE,
                                 pr_dsresposta_requisicao    IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE,
                                 pr_dsprotocolo              IN tbgen_webservice_aciona.dsprotocolo%TYPE DEFAULT NULL, -- Protocolo do Acionamento
                                 pr_dsmetodo                 IN VARCHAR2  DEFAULT NULL,
                                 pr_tpconteudo               IN NUMBER    DEFAULT NULL,  --tipo de retorno json/xml
                                 pr_tpproduto                IN NUMBER    DEFAULT 0,  --Tipo de produto (0-Emprestimo|Financiamento / 1-Limite Credito / 2-Limite Desconto Cheque / 3-Limite Desconto Titulo)
                                 pr_idacionamento           OUT tbgen_webservice_aciona.idacionamento%TYPE,
                                 pr_dscritic                OUT VARCHAR2) IS

  /* ..........................................................................

    Programa : pc_grava_acionamento
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Luis Fernando - GFT
    Data     : Fevereiro/2018.                   Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Grava registro de log de acionamento

    Alteração :

  ..........................................................................*/
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
  INSERT INTO tbgen_webservice_aciona
                ( cdcooper,
                  cdagenci_acionamento,
                  cdoperad,
                  cdorigem,
                  nrctrprp,
                  nrdconta,
                  tpacionamento,
                  dhacionamento,
                  dsoperacao,
                  dsuriservico,
                  dtmvtolt,
                  cdstatus_http,
                  dsconteudo_requisicao,
                  dsresposta_requisicao,
                  tpproduto,
                  dsprotocolo)
          VALUES( pr_cdcooper,        --cdcooper
                  pr_cdagenci,        -- cdagenci_acionamento,
                  pr_cdoperad,        -- cdoperad,
                  pr_cdorigem,        -- cdorigem
                  pr_nrctrprp,        -- nrctrprp
                  pr_nrdconta,        -- nrdconta
                  pr_tpacionamento,   -- tpacionamento
                  pr_dhacionamento,   -- dhacionamento
                  pr_dsoperacao,      -- dsoperacao
                  pr_dsuriservico,    -- dsuriservico
                  pr_dtmvtolt,        -- dtmvtolt
                  pr_cdstatus_http,   -- cdstatus_http
                  pr_dsconteudo_requisicao,
                  pr_dsresposta_requisicao, --dsresposta_requisicao
                  pr_tpproduto,
                  pr_dsprotocolo)     -- protocolo
           RETURNING tbgen_webservice_aciona.idacionamento INTO pr_idacionamento;

    --> Commit para garantir que guarde as informações do log de acionamento
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    pr_dscritic := 'Erro ao inserir tbgen_webservice_aciona: '||SQLERRM;
      ROLLBACK;
  END pc_grava_acionamento;

  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_DataTempo_ibra (pr_data IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(pr_data,'RRRR-MM-DD"T"HH24:MI:SS".000Z"');
  END fn_DataTempo_ibra;

  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_Data_ibra (pr_data IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(pr_data,'RRRR-MM-DD');
  END fn_Data_ibra;

  --> Funcao para remover acentos e caracteres especiais - copiado do TELA_INTEAS.pck
  --> Temporario ate que se adeque a forma de gravacao do acentos na justificativa
  FUNCTION fn_remove_caract_espec(pr_string IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REGEXP_REPLACE( gene0007.fn_caract_acento(pr_string,1,'#$&%¹²³ªº°*!?<>/\|',
                                                                 '                  ')
                          ,'[^a-zA-Z0-9Ç@:._ +,();=-]+',' ');
  END fn_remove_caract_espec;

  PROCEDURE pc_verifica_regras_esteira (pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                        ---- OUT ----
                                        pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                        pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................

    Programa : pc_verifica_regras_esteira
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Paulo Silva (Supero)
    Data     : Maio/2018.                   Ultima atualizacao: 04/05/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento para verificar as regras da esteira

    Alteração :

  ..........................................................................*/
    -----------> VARIÁVEIS <-----------
    vr_contige_este VARCHAR2(500);
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;

  BEGIN

    --> Verificar se a Esteira esta em contigencia para a cooperativa
    vr_contige_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                                  pr_cdcooper => pr_cdcooper,
                                                  pr_cdacesso => 'CONTIGENCIA_ESTEIRA_CRD');
    IF vr_contige_este IS NULL THEN
      vr_dscritic := 'Parametro CONTIGENCIA_ESTEIRA_CRD não encontrado.';
      RAISE vr_exc_erro;
    END IF;

    IF vr_contige_este = '1' THEN
      vr_dscritic := 'Atenção! A aprovação da proposta deve ser feita pela tela CMAPRV.';
      RAISE vr_exc_erro;
    END IF;

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

    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel verificar regras da Análise de Crédito: '||SQLERRM;
  END pc_verifica_regras_esteira;

  --Carregar parâmetros para uso na comunicação com a Ibratn
  PROCEDURE pc_carrega_param_ibra(pr_cdcooper       IN crapcop.cdcooper%TYPE,  -- Codigo da cooperativa
                                  pr_tpenvest       IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio C - Consultar(Get)
                                  pr_host           OUT VARCHAR2,               -- Host da esteira
                                  pr_recurso        OUT VARCHAR2,               -- URI da esteira
                                  pr_dsdirlog       OUT VARCHAR2,               -- Diretorio de log dos arquivos
                                  pr_autori         OUT VARCHAR2,               -- Chave de acesso
                                  pr_chave_aplica   OUT VARCHAR2,               -- App Key
                                  pr_dscritic       OUT VARCHAR2) IS


  /* ..........................................................................

    Programa : pc_carrega_param_ibra
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Paulo Silva (Supero)
    Data     : Abril/2018.                   Ultima atualizacao: 30/04/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Carregar parametros para uso na comunicacao com a esteira

    Alteração :

  ..........................................................................*/
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic NUMBER;

  BEGIN

    pc_verifica_regras_esteira(pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa
                               ---- OUT ----
                               pr_cdcritic => vr_cdcritic,   --> Codigo da critica
                               pr_dscritic => vr_dscritic);  --> Descricao da critica

    -- Se houve erro
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF;

    IF pr_tpenvest = 'M' THEN
      --> Buscar hots so webservice do motor
      pr_host := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                            pr_cdcooper => pr_cdcooper,
                                            pr_cdacesso => 'HOST_WEBSRV_MOTOR_IBRA');

      IF pr_host IS NULL THEN
        vr_dscritic := 'Parametro HOST_WEBSRV_MOTOR_IBRA não encontrado.';
        RAISE vr_exc_erro;
      END IF;

      --> Buscar recurso uri do motor
      pr_recurso := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                               pr_cdcooper => pr_cdcooper,
                                               pr_cdacesso => 'URI_WEBSRV_MOTOR_IBRA');

      IF pr_recurso IS NULL THEN
        vr_dscritic := 'Parametro URI_WEBSRV_MOTOR_IBRA não encontrado.';
        RAISE vr_exc_erro;
      END IF;

      --> Buscar chave de acesso do motor (Autorization é igual ao Consultas Automatizadas)
      pr_autori := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper =>  pr_cdcooper,
                                             pr_cdacesso => 'AUTORIZACAO_IBRATAN');
      IF pr_autori IS NULL THEN
        vr_dscritic := 'Parametro AUTORIZACAO_IBRATAN não encontrado.';
        RAISE vr_exc_erro;
      END IF;

      -- Concatenar o Prefixo
      pr_autori := 'CECRED'||lpad(pr_cdcooper,2,'0')||':'||pr_autori;

      -- Gerar Base 64
      pr_autori := 'Ibratan '||sspc0001.pc_encode_base64(pr_autori);

      --> Buscar chave de aplicação do motor
      pr_chave_aplica := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                                  pr_cdcooper => pr_cdcooper,
                                                  pr_cdacesso => 'KEY_WEBSRV_MOTOR_IBRA');

      IF pr_chave_aplica IS NULL THEN
        vr_dscritic := 'Parametro KEY_WEBSRV_MOTOR_IBRA não encontrado.';
        RAISE vr_exc_erro;
      END IF;

    ELSE

      --> Buscar hots so webservice da esteira
      pr_host := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                            pr_cdcooper => pr_cdcooper,
                                            pr_cdacesso => 'HOSWEBSRVCE_ESTEIRA_IBRA');

      IF pr_host IS NULL THEN
        vr_dscritic := 'Parametro HOSWEBSRVCE_ESTEIRA_IBRA não encontrado.';
        RAISE vr_exc_erro;
      END IF;

      --> Buscar recurso uri da esteira
      pr_recurso := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                               pr_cdcooper => pr_cdcooper,
                                               pr_cdacesso => 'URIWEBSRVCE_RECURSO_IBRA');

      IF pr_recurso IS NULL THEN
        vr_dscritic := 'Parametro URIWEBSRVCE_RECURSO_IBRA não encontrado.';
        RAISE vr_exc_erro;
      END IF;

      --> Buscar chave de acesso da esteira
      pr_autori := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                              pr_cdcooper => pr_cdcooper,
                                              pr_cdacesso => 'KEYWEBSRVCE_ESTEIRA_IBRA');

      IF pr_autori IS NULL THEN
        vr_dscritic := 'Parametro KEYWEBSRVCE_ESTEIRA_IBRA não encontrado.';
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

  --> Rotina responsavel em enviar dos dados para a esteira
  PROCEDURE pc_enviar_esteira ( pr_cdcooper    IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                pr_cdagenci    IN crapage.cdagenci%TYPE,  --> Codigo da agencia
                                pr_cdoperad    IN crapope.cdoperad%TYPE,  --> codigo do operador
                                pr_cdorigem    IN INTEGER,                --> Origem da operacao
                                pr_nrdconta    IN crawcrd.nrdconta%TYPE,  --> Numero da conta do cooperado
                                pr_nrctrcrd    IN crawcrd.nrctrcrd%TYPE,  --> Numero da proposta de emprestimo
                                pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE,  --> Data do movimento
                                pr_comprecu    IN VARCHAR2,               --> Complemento do recuros da URI
                                pr_dsmetodo    IN VARCHAR2,               --> Descricao do metodo
                                pr_conteudo    IN CLOB,                   --> Conteudo no Json para comunicacao
                                pr_dsoperacao  IN VARCHAR2,               --> Operacao realizada
                                pr_tpenvest    IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio
                                pr_dsprotocolo OUT VARCHAR2,              --> Protocolo retornado na requisição
                                pr_dscritic    OUT VARCHAR2 ) IS

    --Parametros
    vr_host_esteira  VARCHAR2(4000);
    vr_recurso_este  VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_autori_este   VARCHAR2(500);
    vr_chave_aplica  VARCHAR2(500);

    vr_dscritic      VARCHAR2(4000);
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;

    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;

    vr_idacionamento  tbgen_webservice_aciona.idacionamento%TYPE;

    vr_tab_split     gene0002.typ_split;
    vr_idx_split     VARCHAR2(1000);

  BEGIN

    -- Carregar parametros para a comunicacao com a esteira
    pc_carrega_param_ibra(pr_cdcooper      => pr_cdcooper,                   -- Codigo da cooperativa
                          pr_tpenvest      => pr_tpenvest,                   -- Tipo do Envio
                          pr_host          => vr_host_esteira,               -- Host da esteira
                          pr_recurso       => vr_recurso_este,               -- URI da esteira
                          pr_dsdirlog      => vr_dsdirlog    ,               -- Diretorio de log dos arquivos
                          pr_autori        => vr_autori_este  ,              -- Authorization
                          pr_chave_aplica  => vr_chave_aplica ,              -- Chave de acesso
                          pr_dscritic      => vr_dscritic    );

    IF vr_dscritic  IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Atribuir valores necessarios para comunicacao
    vr_request.service_uri := vr_host_esteira;
    vr_request.api_route := vr_recurso_este||pr_comprecu;
    vr_request.method    := pr_dsmetodo;
    vr_request.timeout   := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');

    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.headers('Authorization') := vr_autori_este;

    -- Se houver ApplicationKey
    IF vr_chave_aplica IS NOT NULL THEN
      vr_request.headers('ApplicationKey') := vr_chave_aplica;
    END IF;

    -- Para envio do Motor
    IF pr_tpenvest = 'M' THEN
      -- Incluiremos o Reply-To para devolução da Análise
      vr_request.headers('Reply-To') := gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_MOTOR_DEV_CRD');
    END IF;

    vr_request.content := pr_conteudo;

    -- Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'-- Este formato é o formato que deve ser passado, conforme alinhado com o Oscar
                               ,pr_dscritic          => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
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
                                  pr_dsuriservico          => vr_host_esteira||vr_recurso_este||pr_comprecu,
                                  pr_dtmvtolt              => pr_dtmvtolt,
                                  pr_cdstatus_http         => vr_response.status_code,
                                  pr_tpproduto             => 4, --Cartão de Crédito
                                  pr_dsconteudo_requisicao => pr_conteudo,
                                  pr_dsresposta_requisicao => '{"StatusMessage":"'||vr_response.status_message||'"'||CHR(13)||
                                                              ',"Headers":"'||RTRIM(LTRIM(vr_response.headers,'""'),'""')||'"'||CHR(13)||
                                                              ',"Content":'||vr_response.content||'}',
                                  pr_idacionamento         => vr_idacionamento,
                                  pr_dscritic              => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      --> Definir mensagem de critica
      CASE
        WHEN pr_dsmetodo = 'POST' THEN
          vr_dscritic_aux := 'Nao foi possivel enviar proposta para Analise de Credito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu IS NULL THEN
          vr_dscritic_aux := 'Nao foi possivel reenviar a proposta para Analise de Credito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/numeroProposta' THEN
          vr_dscritic_aux := 'Nao foi possivel alterar numero da proposta da Analise de Credito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/cancelar' THEN
          vr_dscritic_aux := 'Nao foi possivel excluir a proposta da Analise de Credito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/efetivar' THEN
          vr_dscritic_aux := 'Nao foi possivel enviar a efetivacao da proposta da Analise de Credito.';
        WHEN pr_dsmetodo = 'GET' THEN
          vr_dscritic_aux := 'Nao foi possivel solicitar o retorno da Análise Automatica de Credito.';
        ELSE
          vr_dscritic_aux := 'Nao foi possivel enviar informacoes para Análise de Crédito.';
        END CASE;

      IF vr_response.status_code = 400 THEN
        pr_dscritic := fn_retorna_critica('{"Content":'||vr_response.content||'}');

        IF pr_dscritic IS NULL THEN
          pr_dscritic := substr(gene0007.fn_convert_web_db(TO_CHAR(vr_response.content)),
                                instr(gene0007.fn_convert_web_db(TO_CHAR(vr_response.content)),'failed:')+7);
        END IF;

        IF pr_dscritic IS NOT NULL THEN
          -- Tratar mensagem específica de Fluxo Atacado:
          -- "Nao sera possivel enviar a proposta para analise. Classificacao de risco e endividamento fora dos parametros da cooperativa"
          IF pr_dscritic != 'Nao sera possivel enviar a proposta para analise. Classificacao de risco e endividamento fora dos parametros da cooperativa' THEN
            -- Mensagens diferentes dela terão o prefixo, somente ela não terá
            pr_dscritic := vr_dscritic_aux||' '||pr_dscritic;
          END IF;
        ELSE
          pr_dscritic := vr_dscritic_aux;
        END IF;

      ELSE
        pr_dscritic := vr_dscritic_aux;
      END IF;

    ELSE

    IF pr_tpenvest = 'M' AND pr_dsmetodo = 'POST' THEN
      --> Transformar texto em objeto json
      BEGIN

        -- Transformar os Headers em uma lista (\n é o separador)
        vr_tab_split := gene0002.fn_quebra_string(vr_response.headers,'\n');
        vr_idx_split  := vr_tab_split.FIRST;
        -- Iterar sobre todos os headers até encontrar o protocolo
        WHILE vr_idx_split IS NOT NULL AND pr_dsprotocolo IS NULL LOOP
          -- Testar se é o Location
          IF lower(vr_tab_split(vr_idx_split)) LIKE 'location%' THEN
            -- Extrair o final do atributo, ou seja, o conteúdo após a ultima barra
            pr_dsprotocolo := SUBSTR(vr_tab_split(vr_idx_split),INSTR(vr_tab_split(vr_idx_split),'/',-1)+1);
          END IF;
          -- Buscar proximo header
          vr_idx_split := vr_tab_split.NEXT(vr_idx_split);
        END LOOP;

        -- Se conseguiu encontrar Protocolo
        IF pr_dsprotocolo IS NOT NULL THEN
          -- Atualizar acionamento
          UPDATE tbgen_webservice_aciona
             SET dsprotocolo = pr_dsprotocolo
           WHERE idacionamento = vr_idacionamento;

      COMMIT;
        ELSE
          -- Gerar erro
          vr_dscritic := 'Nao foi possivel retornar Protocolo da Análise Automática de Crédito!';
          RAISE vr_exc_erro;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel retornar Protocolo de Análise Automática de Crédito!';
          RAISE vr_exc_erro;
      END;
    END IF;
    END IF;

    -- Pj 438 - Marcelo Telles Coelho - Mouts - 07/04/2019
    -- Startar job de atualização das informações da Tela Única
    IF pr_dscritic IS NULL AND pr_tpenvest <> 'M' -- Não foi chamada para Motor
    OR
       (pr_dscritic IS NULL AND pr_tpenvest IS NULL AND pr_dsoperacao = 'REENVIO DA PROPOSTA PARA ANALISE DE CREDITO')
    THEN
      tela_analise_credito.pc_job_dados_analise_credito(pr_cdcooper  => pr_cdcooper
                                                       ,pr_nrdconta  => pr_nrdconta
                                                       ,pr_tpproduto => 7 -- Cartão de Crédito
                                                       ,pr_nrctremp  => vr_nrctrcrd_aux --pr_nrctrcrd
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
      pr_dscritic := 'Não foi possivel enviar proposta para Análise de Crédito: '||SQLERRM;
  END pc_enviar_esteira;

  --> Buscar informações dos associados e gerar json
  PROCEDURE pc_gera_json_pessoa_ass(pr_cdcooper IN crapass.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_vlsalari IN NUMBER  DEFAULT 0
                                   ,pr_persocio IN NUMBER  DEFAULT 0
                                   ,pr_dtadmsoc IN DATE    DEFAULT NULL
                                   ,pr_dtvigpro IN DATE    DEFAULT NULL
                                   ,pr_dsjsonan OUT json
                                   ,pr_cdcritic OUT NUMBER
                                   ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* ..........................................................................

        Programa : pc_gera_json_pessoa_ass
        Sistema  : Conta-Corrente - Cooperativa de Credito
        Sigla    : CRED
        Autor    : Paulo Silva - Supero
        Data     : Fevereiro/2018.                    Ultima atualizacao: 23/02/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado
        Objetivo  : Rotina responsavel por buscar todas as informações cadastrais
                    e das operações da conta parametrizada.

        Alteração :
    ..........................................................................*/
    DECLARE
      -- Variáveis para exceções
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_exc_saida EXCEPTION;
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Declarar objetos Json necessários:
      vr_obj_generico  json := json();
      vr_obj_generic2  json := json();
      vr_obj_generic3  json := json();
      vr_lst_generic2  json_list := json_list();
      vr_lst_generic3  json_list := json_list();

      -- Variáveis auxiliares
      vr_tpcmpvrn      VARCHAR2(100);
      vr_dstextab      craptab.dstextab%TYPE;
      vr_nmseteco      craptab.dstextab%TYPE;
      vr_qtdopliq      VARCHAR2(10);
      vr_flliquid      BOOLEAN;
      vr_flprjcop      BOOLEAN;
      vr_fl800900      BOOLEAN;
      vr_vladtdep      crapsda.vllimcre%TYPE;
      vr_flggrupo      INTEGER;
      vr_nrdgrupo      crapgrp.nrdgrupo%TYPE;
      vr_gergrupo      VARCHAR2(100);
      vr_dsdrisgp      crapgrp.dsdrisgp%TYPE;
      vr_temcotas      BOOLEAN;
      vr_temdebaut     BOOLEAN;
      vr_vlsldtot      NUMBER;
      vr_ind           PLS_INTEGER;
      vr_vlsldapl      craprda.vlsdrdca%TYPE := 0;
      vr_vlsldrgt      NUMBER;
      vr_percenir      NUMBER;
      vr_vlsldppr      NUMBER;
      vr_flgativo      INTEGER;
      vr_nrctrhcj      NUMBER;
      vr_flgliber      INTEGER;
      vr_vltotccr      NUMBER;
      vr_vlendivi      NUMBER := 0;
      vr_ind_coresp    VARCHAR2(100);
      vr_qtprecal      NUMBER(10) := 0;
      vr_tot_vlsdeved  NUMBER(25, 10) := 0;
      vr_ava_vlsdeved  NUMBER(25, 10) := 0;
      vr_dtdpagto_atr  DATE;
      vr_tot_qtprecal  NUMBER := 0;
      vr_nratrmai      NUMBER(25,10);
      vr_vltotatr      NUMBER(25,10);
      vr_qtpclven      NUMBER;
      vr_qtpclatr      NUMBER;
      vr_qtpclpag      NUMBER;
      vr_tot_qtpclatr  NUMBER;
      vr_tot_qtpclpag  NUMBER;
      vr_idxempr       VARCHAR2(100);
      vr_dias          NUMBER;
      vr_inusatab      BOOLEAN;
      vr_dstextab_parempctl  craptab.dstextab%TYPE;
      vr_dstextab_digitaliza craptab.dstextab%TYPE;
      vr_qtregist      INTEGER;
      vr_vltotpre      NUMBER(25,2) := 0;
      vr_nrconbir      crapcbc.nrconbir%TYPE;
      vr_nrseqdet      crapcbd.nrseqdet%TYPE;
      vr_cdbircon      crapbir.cdbircon%TYPE;
      vr_dsbircon      crapbir.dsbircon%TYPE;
      vr_cdmodbir      crapmbr.cdmodbir%TYPE;
      vr_dsmodbir      crapmbr.dsmodbir%TYPE;
      vr_flsituac      VARCHAR2(100) := 'N';
      vr_vlmedfat      NUMBER;
      vr_qtmesest      crapprm.dsvlrprm%TYPE;
      vr_qtmeschq      crapprm.dsvlrprm%TYPE;
      vr_qthisemp      crapprm.dsvlrprm%TYPE;
      vr_qqdiacheq     NUMBER;
      vr_tab_estouros  risc0001.typ_tab_estouros;
      vr_dtiniest      DATE;
      vr_qtdiaat2      INTEGER := 0;
      vr_idcarga       tbepr_carga_pre_aprv.idcarga%TYPE;
      vr_maior_nratrmai NUMBER(25,10);
      vr_vlutiliz       NUMBER;
      vr_cont_SCR       NUMBER;
      vr_atrasoscr      BOOLEAN;
      vr_prejscr        BOOLEAN;
      vr_qtdiaatr       NUMBER;
      vr_inprejuz BOOLEAN;
      vr_flesprej BOOLEAN;
      vr_flemprej BOOLEAN;

      --PlTables auxiliares
      vr_tab_sald                extr0001.typ_tab_saldos;
      vr_tab_medias              extr0001.typ_tab_medias;
      vr_tab_comp_medias         extr0001.typ_tab_comp_medias;
      vr_tab_ocorren             cada0004.typ_tab_ocorren;
      vr_tab_saldo_rdca          apli0001.typ_tab_saldo_rdca;
      vr_tab_conta_bloq          apli0001.typ_tab_ctablq;
      vr_tab_craplpp             apli0001.typ_tab_craplpp;
      vr_tab_craplrg             apli0001.typ_tab_craplpp;
      vr_tab_resgate             apli0001.typ_tab_resgate;
      vr_tab_dados_rpp           apli0001.typ_tab_dados_rpp;
      vr_tab_cartoes             cada0004.typ_tab_cartoes;
      vr_tab_co_responsavel      empr0001.typ_tab_dados_epr;
      vr_tab_dados_epr           empr0001.typ_tab_dados_epr;

      --Tipo de registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Cursor para endereço
      CURSOR cr_crapenc(pr_tpendass crapenc.tpendass%TYPE) IS
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
           AND enc.tpendass = pr_tpendass
           AND enc.idseqttl = 1;
      rw_crapenc cr_crapenc%ROWTYPE;

      -- Cursor para telefones:
      CURSOR cr_craptfc IS
        SELECT tfc.tptelefo
              ,tfc.nrdddtfc
              ,tfc.nrtelefo
          FROM craptfc tfc
         WHERE tfc.cdcooper = pr_cdcooper
           AND tfc.nrdconta = pr_nrdconta
           AND tfc.idseqttl = 1
           AND tfc.tptelefo IN (1, 2, 3); /* Residencial, Celular e Comercial */

      -- Busca Email
      CURSOR cr_crapcem IS
        SELECT cem.dsdemail
          FROM crapcem cem
         WHERE cem.cdcooper = pr_cdcooper
           AND cem.nrdconta = pr_nrdconta
           AND cem.idseqttl = 1;
      vr_dsdemail crapcem.dsdemail%TYPE;

      -- Busca no cadastro do associado:
      CURSOR cr_crapass IS
        SELECT ass.nrdconta
              ,ass.nrcpfcgc
              ,ass.cdagenci
              ,ass.dtnasctl
              ,ass.nrmatric
              ,ass.cdtipcta
              ,ass.cdsitdct
              ,ass.dtcnsscr
              ,ass.inlbacen
              ,decode(ass.incadpos,1,'Nao Autorizado',2,'Autorizado','Cancelado') incadpos
              ,ass.dtelimin
              ,ass.inccfcop
              ,ass.dtcnsspc
              ,ass.dtdsdspc
              ,ass.inadimpl
              ,ass.cdsitdtl
              ,ass.inpessoa
              ,ass.dtcnscpf
              ,ass.cdsitcpf
              ,ass.cdclcnae
              ,ass.vllimcre
              ,ass.nmprimtl
              ,ass.dtmvtolt
              ,ass.dtadmiss
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Buscar informações do primeiro titular
      CURSOR cr_crapttl IS
        SELECT ttl.nmextttl
              ,ttl.dtcnscpf
              ,ttl.cdsitcpf
              ,ttl.tpdocttl
              ,ttl.nrdocttl
              ,org.cdorgao_expedidor cdoedttl
              ,ttl.dtnasttl
              ,ttl.cdsexotl
              ,ttl.tpnacion
              ,nac.dsnacion dsnacion
              ,ttl.dsnatura || '-' || ttl.cdufnatu dsnatura
              ,ttl.dthabmen
              ,ttl.cdestcvl
              ,ttl.cdgraupr
              ,ttl.cdfrmttl
              ,ttl.nmmaettl
              ,ttl.nmpaittl
              ,ttl.cdnatopc
              ,ttl.cdocpttl
              ,ttl.tpcttrab
              ,ttl.cdempres
              ,ttl.nrcpfemp
              ,ttl.dsproftl
              ,ttl.cdnvlcgo
              ,ttl.nrcadast
              ,ttl.cdturnos
              ,ttl.inpolexp
              ,ttl.dtadmemp
              ,ttl.vlsalari vlrendim
              ,ttl.vldrendi##1 + ttl.vldrendi##2 + ttl.vldrendi##3 +
               ttl.vldrendi##4 + ttl.vldrendi##5 + ttl.vldrendi##6 vroutrorn
              ,ttl.inhabmen
              ,ttl.grescola
              ,ass.dtcnsscr
              ,ass.inlbacen
              ,ass.incadpos
              ,ass.dtelimin
              ,ass.dtcnsspc
              ,ass.dtdsdspc
              ,ass.inadimpl
              ,ass.cdsitdtl
          FROM crapttl ttl
              ,crapass ass
              ,crapnac nac
              ,tbgen_orgao_expedidor org
         WHERE ttl.cdcooper = pr_cdcooper
           AND ttl.nrdconta = pr_nrdconta
           AND ttl.idseqttl = 1
           AND ass.cdcooper = ttl.cdcooper
           AND ass.nrdconta = ttl.nrdconta
           AND ttl.cdnacion = nac.cdnacion(+)
           AND ttl.idorgexp = org.idorgao_expedidor(+);
      rw_crapttl cr_crapttl%ROWTYPE;

      -- Buscar dados do titular pessoa juridical
      CURSOR cr_crapjur IS
        SELECT jur.nmextttl
              ,jur.nmfansia
              ,jur.natjurid
              ,jur.qtfilial
              ,jur.qtfuncio
              ,jur.cdseteco
              ,jur.cdrmativ
              ,jur.vlfatano
              ,jur.vlcaprea
              ,jur.dtregemp
              ,jur.nrregemp
              ,jur.orregemp
              ,jur.dtinsnum
              ,jur.nrinsmun
              ,jur.nrinsest
              ,jur.flgrefis
              ,jur.nrcdnire
              ,jur.dtiniatv
          FROM crapjur jur
         WHERE jur.cdcooper = pr_cdcooper
           AND jur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;

      -- Pré Aprovado Nao Liberado
      vr_flglibera_pre_aprv NUMBER := 0;

      -- Data Ultima Revisão Cadastral
      CURSOR cr_revisa IS
        SELECT MAX(crapalt.dtaltera)
          FROM crapalt
         WHERE crapalt.cdcooper = pr_cdcooper
           AND crapalt.nrdconta = pr_nrdconta
           AND crapalt.tpaltera = 1;
      vr_dtaltera DATE;

      -- Conta tem Alerta
      CURSOR cr_alerta IS
        SELECT 1
          FROM crapcrt
         WHERE nrcpfcgc = rw_crapass.nrcpfcgc
           AND cdsitreg = 1 --> Inserido
           AND dtexclus IS NULL;
      vr_indexis NUMBER;

      -- Quantidade de Dependentes
      CURSOR cr_depend IS
        SELECT COUNT(1)
          FROM crapdep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      vr_qtdepend NUMBER;

      -- Buscar descrição
      CURSOR cr_nature(pr_natjurid IN crapjur.natjurid%TYPE) IS
        SELECT gncdntj.dsnatjur
          FROM gncdntj
         WHERE gncdntj.cdnatjur = pr_natjurid;
      vr_dsnatjur gncdntj.dsnatjur%TYPE;

      -- Buscar descrição
      CURSOR cr_ramatv(pr_cdseteco IN gnrativ.cdseteco%TYPE
                      ,pr_cdrmativ IN gnrativ.cdrmativ%TYPE) IS
        SELECT gnrativ.nmrmativ
          FROM gnrativ
         WHERE gnrativ.cdseteco  = pr_cdseteco
           AND gnrativ.cdrmativ = pr_cdrmativ;
      vr_dsramatv gnrativ.nmrmativ%type;

      -- Buscar descrição
      CURSOR cr_cnae(pr_cdclcnae IN crapass.cdclcnae%TYPE) IS
        SELECT dscnae
          FROM tbgen_cnae
         WHERE cdcnae = pr_cdclcnae;
      vr_dscnae tbgen_cnae.dscnae%TYPE;

      -- Buscar informações de faturamento
      CURSOR cr_crapjfn IS
        SELECT jfn.perfatcl
              ,'01' || to_char(jfn.mesftbru##1, 'fm00') || to_char(jfn.anoftbru##1, 'fm0000') dtfatme1
              ,'01' || to_char(jfn.mesftbru##2, 'fm00') || to_char(jfn.anoftbru##2, 'fm0000') dtfatme2
              ,'01' || to_char(jfn.mesftbru##3, 'fm00') || to_char(jfn.anoftbru##3, 'fm0000') dtfatme3
              ,'01' || to_char(jfn.mesftbru##4, 'fm00') || to_char(jfn.anoftbru##4, 'fm0000') dtfatme4
              ,'01' || to_char(jfn.mesftbru##5, 'fm00') || to_char(jfn.anoftbru##5, 'fm0000') dtfatme5
              ,'01' || to_char(jfn.mesftbru##6, 'fm00') || to_char(jfn.anoftbru##6, 'fm0000') dtfatme6
              ,'01' || to_char(jfn.mesftbru##7, 'fm00') || to_char(jfn.anoftbru##7, 'fm0000') dtfatme7
              ,'01' || to_char(jfn.mesftbru##8, 'fm00') || to_char(jfn.anoftbru##8, 'fm0000') dtfatme8
              ,'01' || to_char(jfn.mesftbru##9, 'fm00') || to_char(jfn.anoftbru##9, 'fm0000') dtfatme9
              ,'01' || to_char(jfn.mesftbru##10, 'fm00') || to_char( jfn.anoftbru##10, 'fm0000') dtfatme10
              ,'01' || to_char(jfn.mesftbru##11, 'fm00') || to_char( jfn.anoftbru##11, 'fm0000') dtfatme11
              ,'01' || to_char(jfn.mesftbru##12, 'fm00') || to_char( jfn.anoftbru##12, 'fm0000') dtfatme12
              ,jfn.vlrftbru##1
              ,jfn.vlrftbru##2
              ,jfn.vlrftbru##3
              ,jfn.vlrftbru##4
              ,jfn.vlrftbru##5
              ,jfn.vlrftbru##6
              ,jfn.vlrftbru##7
              ,jfn.vlrftbru##8
              ,jfn.vlrftbru##9
              ,jfn.vlrftbru##10
              ,jfn.vlrftbru##11
              ,jfn.vlrftbru##12
              ,jfn.dtaltjfn##4
          FROM crapjfn jfn
         WHERE jfn.cdcooper = pr_cdcooper
           AND jfn.nrdconta = pr_nrdconta;
      rw_crapjfn cr_crapjfn%ROWTYPE;

      -- Buscar ultimas operações de Crédito Liquidadas
      CURSOR cr_crapepr IS
        SELECT epr.nrctremp
              ,epr.vlemprst
              ,epr.dtmvtolt
              ,epr.qtpreemp
              ,epr.vlpreemp
              ,epr.cdlcremp
              ,lcr.dslcremp
              ,epr.cdfinemp
              ,fin.dsfinemp
          FROM crapepr epr
              ,craplcr lcr
              ,crapfin fin
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.inliquid = 1 -- Somente liquidadas
           AND lcr.cdcooper = epr.cdcooper
           AND lcr.cdlcremp = epr.cdlcremp
           AND lcr.flglispr = 1 -- Somente as que listam na proposta
           AND fin.cdcooper = epr.cdcooper
           AND fin.cdfinemp = epr.cdfinemp
         ORDER BY epr.dtultpag DESC;

      -- Busca data da Liquidação
      CURSOR cr_dtliquid(pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT MAX(lem.dtmvtolt)
          FROM craplem lem
              ,craphis his
         WHERE lem.cdcooper = pr_cdcooper
           AND lem.nrdconta = pr_nrdconta
           AND lem.nrctremp = pr_nrctremp
           AND his.cdcooper = lem.cdcooper
           AND his.cdhistor = lem.cdhistor
           AND his.indebcre = 'C'; -- Lcto de Crecito
      vr_dtliquid DATE;

      -- Checar se esta proposta foi liquidada em novos contratos
      CURSOR cr_eprliquid(pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT 1
          FROM crawepr wpr2
         WHERE wpr2.cdcooper = pr_cdcooper
           AND wpr2.nrdconta = pr_nrdconta
           AND pr_nrctremp -- Contrato registro em loop
               IN (wpr2.nrctrliq##1
                  ,wpr2.nrctrliq##2
                  ,wpr2.nrctrliq##3
                  ,wpr2.nrctrliq##4
                  ,wpr2.nrctrliq##5
                  ,wpr2.nrctrliq##6
                  ,wpr2.nrctrliq##7
                  ,wpr2.nrctrliq##8
                  ,wpr2.nrctrliq##9
                  ,wpr2.nrctrliq##10);
      rw_eprliquid cr_eprliquid%ROWTYPE;

      -- Causou Prejuizo / Esta em Prejuizo
      -- PJ 450 - Diego Simas (AMcom)
      -- INICIO

      -- Cursor para encontrar o cpf/cnpj base do cooperado
      -- e encontrar todas as contas do cooperado atraves do seu CPF/CNPJ
      CURSOR cr_crapass_cpf_cnpj(pr_cdcooper IN crapass.cdcooper%TYPE
                                ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT nrdconta
        FROM crapass a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrcpfcnpj_base IN (SELECT nrcpfcnpj_base
                                    FROM crapass x
                                   WHERE x.cdcooper = a.cdcooper
                                     AND x.nrdconta = pr_nrdconta)
       ORDER BY nrdconta;
       rw_crapass_cpf_cnpj cr_crapass_cpf_cnpj%ROWTYPE;

      -- Verificar se o cooperado teve emprestimo com prejuizo
      -- ou se esta com emprestimo em prejuizo na Cooperativa
      CURSOR cr_crapepr_preju(pr_cdcooper IN crapepr.cdcooper%TYPE
                             ,pr_nrdconta IN crapepr.nrdconta%TYPE
                             ,pr_inliquid IN crapepr.inliquid%TYPE)IS
        SELECT 1
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.inprejuz = 1
           AND epr.inliquid = pr_inliquid;
      rw_crapepr_preju cr_crapepr_preju%ROWTYPE;

      --> Consultar se já houve prejuizo nessa conta do cooperado
      CURSOR cr_prejuizo(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                         pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
        SELECT 1
          FROM tbcc_prejuizo t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta;
      rw_prejuizo cr_prejuizo%ROWTYPE;

      -- FIM
      -- PJ 450 - Diego Simas (AMcom)
      -- Causou Prejuizo / Esta em Prejuizo

      -- Verificar se ha emprestimo nas linhas 800 e 900
      CURSOR cr_crapepr_800_900 IS
        SELECT 1
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.inliquid = 0
           AND epr.cdlcremp IN (800, 900);
      rw_crapepr_800_900 cr_crapepr_800_900%ROWTYPE;

      -- Buscar outras propostas em Andamento
      CURSOR cr_crawepr_outras IS
        SELECT SUM(wpr.vlemprst) vlsdeved
              ,SUM(wpr.vlpreemp) vlpreemp
          FROM crawepr wpr
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.insitapr = 1             -- Somente Aprovadas
           AND NOT EXISTS(SELECT 1
                           FROM crapepr epr
                          WHERE epr.cdcooper = wpr.cdcooper
                            AND epr.nrdconta = wpr.nrdconta
                            AND epr.nrctremp = wpr.nrctremp);
      rw_crawepr_outras cr_crawepr_outras%ROWTYPE;

      -- Buscar Contrato Limite Crédito
      CURSOR cr_craplim_chqesp IS
        SELECT lim.dtinivig
              ,lim.vllimite
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.insitlim = 2; -- Ativo
      rw_craplim_chqesp cr_craplim_chqesp%ROWTYPE;

      -- Buscar ultimas ocorrências de Cheques Devolvidos
      CURSOR cr_crapneg_cheq(pr_qtmeschq IN INTEGER) IS
        SELECT dtiniest
              ,vlestour
              ,cdobserv
              ,rownum
          FROM crapneg
         WHERE crapneg.cdcooper = pr_cdcooper
           AND crapneg.cdhisest = 1 /* Dev Cheques */
           AND crapneg.nrdconta = pr_nrdconta
           AND crapneg.dtiniest BETWEEN add_months(TRUNC(rw_crapdat.dtmvtolt),-pr_qtmeschq)
                                                   AND TRUNC(rw_crapdat.dtmvtolt)
         ORDER BY crapneg.dtiniest DESC;

      -- Buscar Saldo de Cotas
      CURSOR cr_crapcot IS
        SELECT vldcotas
          FROM crapcot
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      vr_vldcotas crapcot.vldcotas%TYPE;

      -- Busca se o cooperado tem plano de cotas ativo
      CURSOR cr_crappla IS
        SELECT 1
          FROM crappla
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdsitpla = 1;
      rw_crappla cr_crappla%ROWTYPE;

      -- Verificar se cooperado tem Debito Automático
      CURSOR cr_crapatr IS
        SELECT 1
          FROM crapatr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtfimatr IS NULL;
      rw_crapatr cr_crapatr%ROWTYPE;

      -- Buscar as informações do Arquivo SCR
      CURSOR cr_crapopf IS
        SELECT qtopesfn
              ,qtifssfn
              ,dtrefere
          FROM crapopf
         WHERE nrcpfcgc = rw_crapass.nrcpfcgc
         ORDER BY dtrefere DESC;
      rw_crapopf cr_crapopf%ROWTYPE;

      -- Na sequencia buscar os valores dos vencimentos
      CURSOR cr_crapvop(pr_nrcpfcgc in crapass.nrcpfcgc%type) IS
        SELECT SUM(vlvencto) vlopesfn
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 205 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vlopevnc
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 310 AND 330 THEN
                      vlvencto
                     ELSE
                      0
                   END) vlopeprj
              ,SUM(CASE
                     WHEN cdvencto = 130 THEN
                      vlvencto
                     ELSE
                      0
                   END) vlvcto130
          FROM crapvop
         WHERE nrcpfcgc = pr_nrcpfcgc
           AND dtrefere = rw_crapopf.dtrefere;
      rw_crapvop     cr_crapvop%ROWTYPE;

      -- Buscar todos os seguros da Conta do Cooperado
      CURSOR cr_crapseg IS
        SELECT DECODE(seg.tpseguro
                     ,1
                     ,'CASA'
                     ,11
                     ,'CASA'
                     ,2
                     ,'AUTO'
                     ,3
                     ,'VIDA'
                     ,4
                     ,'PRST'
                     ,'    ') dstipo
              ,wseg.vlseguro vlpremio
          FROM crapseg seg
              ,crapcsg csg
              ,crawseg wseg
         WHERE seg.cdcooper = csg.cdcooper
           AND seg.cdsegura = csg.cdsegura
           AND seg.cdcooper = pr_cdcooper
           AND seg.nrdconta = pr_nrdconta
           AND seg.cdcooper = wseg.cdcooper(+)
           AND seg.nrdconta = wseg.nrdconta(+)
           AND seg.nrctrseg = wseg.nrctrseg(+)
           AND seg.cdsitseg IN (1, 3, 11)
        UNION ALL
        SELECT DECODE(segnov.tpseguro
                     ,'C'
                     ,'CASA'
                     ,'A'
                     ,'AUTO'
                     ,'V'
                     ,'VIDA'
                     ,'G'
                     ,'VIDA'
                     ,'P'
                     ,'PRST'
                     ,'    ') dstipo
              ,segnov.vlpremio_total vlpremio
          FROM tbseg_contratos segnov
              ,crapcsg         csg
              ,tbseg_parceiro  par
         WHERE segnov.cdparceiro = par.cdparceiro
           AND segnov.cdcooper = csg.cdcooper
           AND segnov.cdsegura = csg.cdsegura
           AND segnov.cdcooper = pr_cdcooper
           AND segnov.nrdconta = pr_nrdconta
           AND segnov.indsituacao in('A','R','E')
           AND segnov.nrapolice > 0;

      -- Verificar se há bloqueio de aplicações na conta
      CURSOR cr_crapblj IS
        SELECT SUM(vlbloque)
          FROM crapblj
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdmodali = 2
           AND dtblqfim IS NULL;
      vr_vlbloque crapblj.vlbloque%TYPE;
      -- Verificar se há bloqueio de aplicações na conta
      CURSOR cr_crapblj_pp IS
        SELECT SUM(vlbloque)
          FROM crapblj
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdmodali > 2
           AND dtblqfim IS NULL;
      vr_vlbloque_pp crapblj.vlbloque%TYPE;

      -- Buscar contrato de desconto cheques
      CURSOR cr_craplim_chq IS
        SELECT dtinivig
              ,vllimite
          FROM craplim
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.nrdconta = pr_nrdconta
           AND craplim.tpctrlim = 2
           AND craplim.insitlim = 2; /* ATIVO */
      rw_craplim_chq cr_craplim_chq%ROWTYPE;

      -- Buscar borderôs ativos
      CURSOR cr_crapcdb(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT SUM(vlcheque) vlcheque
          FROM crapcdb
         WHERE crapcdb.cdcooper = pr_cdcooper
           AND crapcdb.nrdconta = pr_nrdconta
           AND crapcdb.insitchq = 2
           AND crapcdb.dtlibera > pr_dtmvtolt;
      rw_crapcdb cr_crapcdb%ROWTYPE;

      -- Buscar contrato de desconto titulos
      CURSOR cr_craplim_tit IS
        SELECT dtinivig
              ,vllimite
          FROM craplim
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.nrdconta = pr_nrdconta
           AND craplim.tpctrlim = 3
           AND craplim.insitlim = 2; /* ATIVO */
      rw_craplim_tit cr_craplim_tit%ROWTYPE;

      -- Buscar borderôs ativos
      CURSOR cr_craptdb(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT SUM(vltitulo) vltitulo
          FROM craptdb
         WHERE craptdb.cdcooper = pr_cdcooper
           AND craptdb.nrdconta = pr_nrdconta
           AND ((craptdb.insittit = 4) OR
               (craptdb.insittit = 2 AND
               craptdb.dtdpagto = pr_dtmvtolt));
      rw_craptdb cr_craptdb%ROWTYPE;

      -- Para PP, buscaremos no cadastro de parcelas a quantidade de parcelas pagas em atraso
      CURSOR cr_crappep_atraso(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                              ,pr_nrctremp IN crappep.nrctremp%TYPE
                              ,pr_qthisemp IN INTEGER) IS
        SELECT COUNT(1)
          FROM crappep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND dtultpag > dtvencto -- Paga depois do vencimento
           AND dtultpag >= add_months(pr_dtmvtolt, -pr_qthisemp) -- Nos ultimos XX meses
           AND inliquid = 1 -- Liquidadas
           AND vlpagmta > 0; -- Com multa

      -- Para as parcelas pagas também buscaremos no cadastro de parcelas
      CURSOR cr_crappep_pagtos(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                              ,pr_nrctremp IN crappep.nrctremp%TYPE
                              ,pr_qthisemp IN INTEGER) IS
        SELECT COUNT(1)
          FROM crappep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND dtultpag >= add_months(pr_dtmvtolt, -pr_qthisemp) -- Nos ultimos XX meses
           AND inliquid = 1 -- Liquidadas
           AND vlpagmta = 0; -- Sem multa

      -- Para TR, buscaremos nos lançamentos de pagtos a quantidade de lançamentos de Multa
      CURSOR cr_craplem_atraso(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                              ,pr_nrctremp IN craplem.nrctremp%TYPE
                              ,pr_qthisemp IN INTEGER) IS
        SELECT COUNT(1)
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND cdhistor = 443 -- Multa
           AND dtmvtolt >= add_months(pr_dtmvtolt, -pr_qthisemp); -- Nos ultimos XX meses

      -- Somar o valor pago nos ultimos 6 meses
      CURSOR cr_craplem_pago(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                            ,pr_nrctremp IN craplem.nrctremp%TYPE
                            ,pr_qthisemp IN INTEGER) IS
        SELECT nvl(SUM(vllanmto),0)
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND cdhistor NOT IN (99, 98, 443) -- Remover liberação, juros e Multa
           AND dtmvtolt >= add_months(pr_dtmvtolt, -pr_qthisemp) -- Nos ultimos XX meses
           AND vlpreemp > 0;
      vr_vlpclpag NUMBER(25,10);

      -- Busca dos bens do associado CURSOR cr_crapbem e vr_vlrtotbem
      CURSOR cr_crapbem IS
      SELECT SUM(vlrdobem)
        FROM crapbem
       WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND idseqttl = 1;
      vr_vltotbem NUMBER;


      -- Buscar saldos diarios dos associados
      CURSOR cr_crapsda (pr_cdcooper crapsda.cdcooper%type,
                         pr_nrdconta crapsda.nrdconta%type,
                         pr_dtiniest crapsda.dtmvtolt%type) IS
        SELECT vlsddisp,
               vllimcre
          FROM crapsda
         WHERE crapsda.cdcooper = pr_cdcooper
           AND crapsda.nrdconta = pr_nrdconta
           AND crapsda.dtmvtolt >= pr_dtiniest
          ORDER BY crapsda.dtmvtolt DESC;

      -- Cursor para verificar se o cooperado teve linha de credito no periodo
      CURSOR cr_craplim (pr_cdcooper craplim.cdcooper%TYPE,
                         pr_nrdconta craplim.nrdconta%TYPE,
                         pr_dtiniest craplim.dtinivig%TYPE) IS
        SELECT 1
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.insitlim IN (2,3)
           AND nvl(lim.dtfimvig,pr_dtiniest) >= pr_dtiniest;
      rw_craplim cr_craplim%ROWTYPE;

      --Verifica se é impossibilitado de negativação
      CURSOR cr_crapcyc (pr_cdcooper crapcyc.cdcooper%TYPE,
                         pr_nrdconta crapcyc.nrdconta%TYPE) IS
        SELECT 1
          FROM crapcyb cyb
          JOIN crapcyc cyc
            ON cyc.cdcooper = cyb.cdcooper
           AND cyc.cdorigem = cyb.cdorigem
           AND cyc.nrdconta = cyb.nrdconta
           AND cyc.nrctremp = cyb.nrctremp
         WHERE cyb.cdcooper = pr_cdcooper
           AND cyb.nrdconta = pr_nrdconta
           AND cyb.dtdbaixa is null
           AND cyc.flgehvip = 1 /* flag CIN */;
      rw_crapcyc cr_crapcyc%ROWTYPE;

      --Verifica se possui atraso no cartão
      CURSOR cr_crdalat (pr_cdcooper tbcrd_alerta_atraso.cdcooper%TYPE,
                         pr_nrdconta tbcrd_alerta_atraso.nrdconta%TYPE) IS
        SELECT qtdias_atraso
          FROM tbcrd_alerta_atraso
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crdalat cr_crdalat%ROWTYPE;

      --Busca informação cessão cartão
      CURSOR cr_crapepr_cessao (pr_cdcooper crapepr.cdcooper%TYPE,
                                pr_nrdconta crapepr.nrdconta%TYPE) IS
        SELECT MAX(dtmvtolt) as dtUltCessao,
               CASE WHEN MIN(epr.inliquid) = 0 /* Se existe contrato nao liquidado */
                    THEN 1
                    ELSE 0
                END AS flgTemCessaoAtiva
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.cdfinemp IN (SELECT fin.cdfinemp
                                  FROM crapfin fin
                                 WHERE fin.cdcooper = epr.cdcooper
                                   AND fin.tpfinali = 1 /* Cessao cartao */);
      rw_crapepr_cessao cr_crapepr_cessao%ROWTYPE;

      --Busca informação de Renegociação e Composição
      CURSOR cr_rencomp (pr_cdcooper crawepr.cdcooper%TYPE,
                         pr_nrdconta crawepr.nrdconta%TYPE,
                         pr_dtmovto  INTEGER) IS
        SELECT MAX(
               CASE WHEN wpr.idquapro = 3 /* Renegociacao */
                    THEN 1
                    ELSE 0
                 END) AS temRenegociacao,
               MAX(
               CASE WHEN wpr.idquapro = 4 /* Composicao */
                    THEN 1
                    ELSE 0
                 END) AS temComposicao
          FROM crawepr wpr
          JOIN crapepr epr /* Join para garantir que a proposta foi efetivada */
            ON epr.cdcooper = wpr.cdcooper
           AND epr.nrdconta = wpr.nrdconta
           AND epr.nrctremp = wpr.nrctremp
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND epr.dtmvtolt >= add_months(TRUNC(SYSDATE), -pr_dtmovto);
      rw_rencomp cr_rencomp%ROWTYPE;

      --Busca Dados SCPC
      CURSOR cr_crapspc(pr_dtinclus INTEGER) IS
        SELECT nrctremp
              ,nrctrspc
              ,dtvencto
              ,dtinclus
              ,dtdbaixa
              ,tpidenti
              ,cdorigem
              ,tpinsttu
              ,vldivida
          FROM crapspc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtinclus >= add_months(TRUNC(SYSDATE),-pr_dtinclus);
      rw_crapspc cr_crapspc%ROWTYPE;

    BEGIN
      --Verificar se a data existe
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        CLOSE btch0001.cr_crapdat;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Buscar informações cadastrais da conta
      OPEN cr_crapass;
      FETCH cr_crapass
        INTO rw_crapass;

      -- Se não encontrar registro
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        -- Sair acusando critica 9
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;

      --Verificar se usa tabela juros
      vr_dstextab:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TAXATABELA'
                                              ,pr_tpregist => 0);
      -- Se a primeira posição do campo
      -- dstextab for diferente de zero
      vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';

      -- Buscar saldo devedor
      empr0001.pc_saldo_devedor_epr (pr_cdcooper   => pr_cdcooper     --> Cooperativa conectada
                                    ,pr_cdagenci   => 1               --> Codigo da agencia
                                    ,pr_nrdcaixa   => 0               --> Numero do caixa
                                    ,pr_cdoperad   => '1'             --> Codigo do operador
                                    ,pr_nmdatela   => 'ATENDA'        --> Nome datela conectada
                                    ,pr_idorigem   => 1 /*Ayllos*/    --> Indicador da origem da chamada
                                    ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                    ,pr_idseqttl   => 1               --> Sequencia de titularidade da conta
                                    ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parametro (CRAPDAT)
                                    ,pr_nrctremp   => 0               --> Numero contrato emprestimo
                                    ,pr_cdprogra   => 'B1WGEN0001'    --> Programa conectado
                                    ,pr_inusatab   => vr_inusatab     --> Indicador de utilizacão da tabela
                                    ,pr_flgerlog   => 'N'             --> Gerar log S/N
                                    ,pr_vlsdeved   => vr_vlendivi     --> Saldo devedor calculado
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

        RAISE vr_exc_saida;
      END IF;

      -- Enviaremos os dados básicos encontrados na tabela
      IF rw_crapass.inpessoa = 1 THEN
        vr_obj_generico.put('documento', gene0002.fn_mask(rw_crapass.nrcpfcgc,'99999999999'));
      ELSE
        vr_obj_generico.put('documento', gene0002.fn_mask(rw_crapass.nrcpfcgc,'99999999999999'));
      END IF;

      -- Para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
        vr_obj_generico.put('tipoPessoa', 'FISICA');

        -- Buscar dados do titular
        OPEN cr_crapttl;
        FETCH cr_crapttl
          INTO rw_crapttl;
        CLOSE cr_crapttl;

        vr_obj_generico.put('nome', rw_crapttl.nmextttl);

        IF rw_crapttl.cdsexotl = 1 THEN
          vr_obj_generico.put('sexo', 'MASCULINO');
        ELSE
          vr_obj_generico.put('sexo', 'FEMININO');
        END IF;

        vr_obj_generico.put('dataNascimento',este0002.fn_data_ibra_motor(rw_crapass.dtnasctl));

        -- Se o Documento for RG
        IF rw_crapttl.tpdocttl = 'CI' THEN
          vr_obj_generico.put('rg', rw_crapttl.nrdocttl);
          vr_obj_generico.put('ufRg', rw_crapttl.cdoedttl);
        END IF;

        vr_obj_generico.put('nomeMae', rw_crapttl.nmmaettl);
        vr_obj_generico.put('nacionalidade'  ,rw_crapttl.dsnacion);

        -- Montar objeto profissao
        IF rw_crapttl.dsproftl <> ' ' THEN
          vr_obj_generic2 := json();
          vr_obj_generic2.put('titulo', rw_crapttl.dsproftl);
          vr_obj_generico.put('profissao', vr_obj_generic2);
        END IF;

        -- Buscar endereço residencial
        OPEN cr_crapenc(10);
        FETCH cr_crapenc
          INTO rw_crapenc;
        CLOSE cr_crapenc;

      ELSE

        vr_obj_generico.put('tipoPessoa', 'JURIDICA');

        -- Buscar dados da conta PJ
        OPEN cr_crapjur;
        FETCH cr_crapjur
          INTO rw_crapjur;
        CLOSE cr_crapjur;

        vr_obj_generico.put('razaoSocial', rw_crapjur.nmextttl);
        vr_obj_generico.put('dataFundacao',este0002.fn_Data_ibra_motor(rw_crapjur.dtiniatv));

        -- Buscar endereço comercial
        OPEN cr_crapenc(9);
        FETCH cr_crapenc
          INTO rw_crapenc;
        CLOSE cr_crapenc;

      END IF;

      -- Montar objeto Telefone para Telefones Celular/Residencial/Comercial
      vr_lst_generic2 := json_list();
      -- Criar objeto só para este telefone
      vr_obj_generic2 := json();
      -- Buscar todos os registros
      FOR rw_craptfc IN cr_craptfc LOOP
        -- Para pessoa Juridica sempre enviamos comercial
        IF rw_crapass.inpessoa = 2 THEN
          vr_obj_generic2.put('especie', 'COMERCIAL');
        ELSE
          -- Para pessoa Fisica temos de testar
          IF rw_craptfc.tptelefo = 3 THEN
            vr_obj_generic2.put('especie', 'COMERCIAL');
          ELSE
            vr_obj_generic2.put('especie', 'DOMICILIO');
          END IF;
        END IF;

        -- Celular
        IF rw_craptfc.tptelefo = 2 THEN
          vr_obj_generic2.put('tipo', 'MOVEL');
        ELSE
          vr_obj_generic2.put('tipo', 'FIXO');
        END IF;

        vr_obj_generic2.put('ddd', rw_craptfc.nrdddtfc);
        vr_obj_generic2.put('numero',este0002.fn_somente_numeros_telefone(rw_craptfc.nrtelefo));
        -- Adicionar telefone na lista
        vr_lst_generic2.append(vr_obj_generic2.to_json_value());
      END LOOP;

      -- Adicionar o array telefone no objeto
      vr_obj_generico.put('telefones', vr_lst_generic2);

      -- Montar objeto Endereco
      IF rw_crapenc.dsendere <> ' ' THEN
        vr_obj_generic2 := json();
        vr_obj_generic2.put('logradouro', rw_crapenc.dsendere);
        vr_obj_generic2.put('numero', rw_crapenc.nrendere);
        vr_obj_generic2.put('complemento', rw_crapenc.complend);
        vr_obj_generic2.put('bairro', rw_crapenc.nmbairro);
        vr_obj_generic2.put('cidade', rw_crapenc.nmcidade);
        vr_obj_generic2.put('uf', rw_crapenc.cdufende);
        vr_obj_generic2.put('cep', rw_crapenc.nrcepend);
        -- Adicionar o array endereco no objeto
        vr_obj_generico.put('endereco', vr_obj_generic2);
      END IF;

      -- Montar informações Adicionais
      vr_obj_generic2 := json();

      -- Conta
      vr_obj_generic2.put('conta', to_number(substr(pr_nrdconta,1,length(pr_nrdconta)-1)));
      vr_obj_generic2.put('contaDV', to_number(substr(pr_nrdconta,-1)));

      -- Agencia
      vr_obj_generic2.put('agenci', rw_crapass.cdagenci);

      -- Matricula
      vr_obj_generic2.put('matric', rw_crapass.nrmatric);

      -- Data Admissão Coop
      vr_obj_generic2.put('dataAdmissaoCoop', este0002.fn_data_ibra_motor(NVL(rw_crapass.dtmvtolt,rw_crapass.dtadmiss)));

      vr_obj_generic2.put('tipoConta', rw_crapass.cdtipcta);

      -- Situação da Conta
      vr_obj_generic2.put('situacaoConta', rw_crapass.cdsitdct);

      -- Email
      OPEN cr_crapcem;
      FETCH cr_crapcem INTO vr_dsdemail;
      CLOSE cr_crapcem;

      vr_obj_generic2.put('email',vr_dsdemail);

      -- Tipo do Imóvel
      IF rw_crapenc.incasprp <> 0 THEN
        vr_obj_generic2.put('tipoImovel',rw_crapenc.incasprp);
      END IF;

      -- Busca dos bens do associado CURSOR cr_crapbem e vr_vlrtotbem
      OPEN cr_crapbem;
      FETCH cr_crapbem
       INTO vr_vltotbem;
      CLOSE cr_crapbem;

      -- Se o titular possui bens
      vr_obj_generic2.put('valorTotalBens', este0001.fn_decimal_ibra(vr_vltotbem));

      -- Valor do Imovel (Somente quando não for alugado)
      IF rw_crapenc.vlalugue > 0 AND rw_crapenc.incasprp NOT IN (0, 3) THEN
        vr_obj_generic2.put('valorImovel',este0001.fn_decimal_ibra(rw_crapenc.vlalugue));
        vr_obj_generic2.put('valorAluguel',este0001.fn_decimal_ibra(0));
      ELSE
        -- Quando alugado enviaremos valor Aluguel
        vr_obj_generic2.put('valorImovel',este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('valorAluguel', este0001.fn_decimal_ibra(rw_crapenc.vlalugue));
      END IF;

      -- Data de Inicio de Residência
      IF rw_crapenc.dtinires IS NOT NULL THEN
        vr_obj_generic2.put('inicioResidImovel',este0002.fn_data_ibra_motor(rw_crapenc.dtinires));
      END IF;

      -- Caixa Postal
      IF rw_crapenc.nrcxapst <> 0 THEN
        vr_obj_generic2.put('caixaPostal', rw_crapenc.nrcxapst);
      END IF;

      -- PreAprovado
      vr_flglibera_pre_aprv := 0;

      -- Busca a carga ativa
      vr_idcarga := empr0002.fn_idcarga_pre_aprovado_cta(pr_cdcooper => pr_cdcooper
                                                        ,pr_nrdconta => pr_nrdconta);
      --  Caso nao possua carga ativa
      IF vr_idcarga > 0 THEN
          -- Verifica se existe Bloqueio em Conta
          vr_flglibera_pre_aprv := empr0002.fn_flg_preapv_liberado(pr_cdcooper,pr_nrdconta);
      END IF;

      vr_obj_generic2.put('liberaPreAprovad', (nvl(vr_flglibera_pre_aprv,0)=1));

      -- Data Consulta SCR
      IF rw_crapass.dtcnsscr IS NOT NULL THEN
        vr_obj_generic2.put('dataConsultaSCR',este0002.fn_data_ibra_motor(rw_crapass.dtcnsscr));
      END IF;

      -- CCF
      vr_obj_generic2.put('ccf', NVL(rw_crapass.inccfcop,0)=1);

      -- Cadastro Positivo
      vr_obj_generic2.put('cadastroPositivo',rw_crapass.incadpos);

      -- Data de demissão na Cooperativa
      IF rw_crapass.dtelimin IS NOT NULL THEN
        vr_obj_generic2.put('dataDemissao',este0002.fn_data_ibra_motor(rw_crapass.dtelimin));
      END IF;

      -- Data da consulta no SPC
      IF rw_crapass.dtcnsspc IS NOT NULL THEN
        vr_obj_generic2.put('dataConsultaSPC',este0002.fn_data_ibra_motor(rw_crapass.dtcnsspc));
      END IF;

      -- Data da inclusão no SPC pela cooperativa
      IF rw_crapass.dtdsdspc IS NOT NULL THEN
        vr_obj_generic2.put('dataInclusaoSPCpelaCoop',este0002.fn_data_ibra_motor(rw_crapass.dtdsdspc));
      END IF;

      -- Está no SPC(cooperativa)
      vr_obj_generic2.put('SPCpelaCoop',NVL(rw_crapass.inadimpl,0)=1);

      -- Está no SPC(outras IFs)
      sspc0001.pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrconbir => vr_nrconbir
                                     ,pr_nrseqdet => vr_nrseqdet);

      -- Se encontrar
      IF NVL(vr_nrconbir,0) > 0 AND NVL(vr_nrseqdet,0) > 0 THEN
        -- Buscar o detalhamento da consulta
        sspc0001.pc_verifica_situacao(pr_nrconbir => vr_nrconbir
                                     ,pr_nrseqdet => vr_nrseqdet
                                     ,pr_cdbircon => vr_cdbircon
                                     ,pr_dsbircon => vr_dsbircon
                                     ,pr_cdmodbir => vr_cdmodbir
                                     ,pr_dsmodbir => vr_dsmodbir
                                     ,pr_flsituac => vr_flsituac);
      END IF;

      vr_obj_generic2.put('SPCoutrasIFs',vr_flsituac='S');

      -- Conta tem Registro Contra Ordem
      vr_obj_generic2.put('estaDCTROR',(NVL(rw_crapass.cdsitdtl,0) = 2));

      --Alerta
      vr_indexis := 0;

      OPEN cr_alerta;
      FETCH cr_alerta
        INTO vr_indexis;
      CLOSE cr_alerta;

      vr_obj_generic2.put('estaALERTA', (vr_indexis=1));

      -- Data Ultima Revisão Cadastral
      OPEN cr_revisa;
      FETCH cr_revisa
        INTO vr_dtaltera;
      CLOSE cr_revisa;

      IF vr_dtaltera IS NOT NULL THEN
        vr_obj_generic2.put('dataUltimaRevCadast', este0002.fn_data_ibra_motor(vr_dtaltera));
      END IF;

      -- Causou Prejuizo / Esta em Prejuizo
      -- PJ 450 - Diego Simas (AMcom)
      -- INICIO

      vr_flesprej := FALSE;
      vr_flemprej := FALSE;

      FOR rw_crapass_cpf_cnpj
       IN cr_crapass_cpf_cnpj
         (pr_cdcooper => pr_cdcooper
         ,pr_nrdconta => pr_nrdconta) LOOP
          -- Para cada conta do associado cpf/cnpj
          -- verificamos se está em prejuízo de empréstimo e conta corrente
          -- ou se já causou prejuizo de emprestimo e conta corrente

          -- Está em Prejuizo na Cooperativa
          -- Emprestimo
          OPEN cr_crapepr_preju(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_crapass_cpf_cnpj.nrdconta
                               ,pr_inliquid => 0);
      FETCH cr_crapepr_preju
        INTO rw_crapepr_preju;

          IF cr_crapepr_preju%FOUND THEN
             vr_flemprej := TRUE;
      END IF;

      CLOSE cr_crapepr_preju;

          -- Conta Corrente
          vr_inprejuz := PREJ0003.fn_verifica_preju_conta(pr_cdcooper, rw_crapass_cpf_cnpj.nrdconta);
          IF vr_inprejuz = TRUE THEN
             vr_flemprej := TRUE;
          END IF;

          -- Esteve algum dia em Prejuizo na Cooperativa
          -- Emprestimo
          OPEN cr_crapepr_preju(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_crapass_cpf_cnpj.nrdconta
                               ,pr_inliquid => 1);
          FETCH cr_crapepr_preju
           INTO rw_crapepr_preju;

          IF cr_crapepr_preju%FOUND THEN
             vr_flesprej := TRUE;
          END IF;

          CLOSE cr_crapepr_preju;

          -- Conta Corrente
          OPEN cr_prejuizo(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapass_cpf_cnpj.nrdconta);
          FETCH cr_prejuizo
           INTO rw_prejuizo;

          IF cr_prejuizo%FOUND THEN
             vr_flesprej := TRUE;
          END IF;

          CLOSE cr_prejuizo;

      END LOOP;

      -- Enviar causouPrejuizoCoop
      vr_obj_generic2.put('causouPrejuizoCoop', vr_flesprej);
      -- Enviar estaEmPrejuizoCoop
      vr_obj_generic2.put('estaEmPrejuizoCoop', vr_flemprej);

      -- FIM
      -- PJ 450 - Diego Simas (AMcom)
      -- Causou Prejuizo / Esta em Prejuizo

      -- Verificar se ha emprestimo nas linhas 800 e 900
      OPEN cr_crapepr_800_900;
      FETCH cr_crapepr_800_900
        INTO rw_crapepr_800_900;

      IF cr_crapepr_800_900%FOUND THEN
        vr_fl800900 := TRUE;
      ELSE
        vr_fl800900 := FALSE;
      END IF;

      -- Enviar temLinha800e900
      vr_obj_generic2.put('temLinha800e900', vr_fl800900);

      -- Buscar o Saldo do Cooperado (Declarar vr_vladtdep)
      extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdagenci   => 1
                                 ,pr_nrdcaixa   => 1
                                 ,pr_cdoperad   => '1'
                                 ,pr_nrdconta   => pr_nrdconta
                                 ,pr_vllimcre   => rw_crapass.vllimcre
                                 ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                 ,pr_flgcrass   => FALSE
                                 ,pr_des_reto   => vr_des_reto
                                 ,pr_tab_sald   => vr_tab_sald
                                 ,pr_tab_erro   => vr_tab_erro);

      IF vr_tab_sald(0).vlsddisp < 0 THEN
        IF abs(vr_tab_sald(0).vlsddisp) > vr_tab_sald(0).vllimcre THEN
          vr_vladtdep := vr_tab_sald(0).vllimcre + vr_tab_sald(0).vlsddisp;
        ELSE
          vr_vladtdep := 0;
        END IF;
      ELSE
        vr_vladtdep := 0;
      END IF;

      -- Enviar o valorAdiantDeposit
      vr_obj_generic2.put('valorAdiantDeposit',este0001.fn_decimal_ibra(vr_vladtdep));

      /* Inicializar */
      vr_qqdiacheq := 0;

      -- Verificar se cooperado possui contrato de limite de credito no periodo
      OPEN cr_craplim( pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_dtiniest => vr_dtiniest);
      FETCH cr_craplim INTO rw_craplim;

      -- se não possuir contrato de limite de credito, não precisa
      -- verificar a sda
      IF cr_craplim%NOTFOUND THEN
        CLOSE cr_craplim;
      ELSE
        CLOSE cr_craplim;
        -- Varrer tabela de saldo do dia
        FOR rw_crapsda IN cr_crapsda ( pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => pr_nrdconta,
                                       pr_dtiniest => vr_dtiniest) LOOP

          -- se o saldo for negativo e o maior que o limite de credito
          IF rw_crapsda.vlsddisp < 0  AND
             rw_crapsda.vlsddisp >= (rw_crapsda.vllimcre*-1) THEN
            vr_qtdiaat2 := nvl(vr_qtdiaat2,0) + 1;
          ELSE
            -- armazenar maior data
            IF nvl(vr_qtdiaat2,0) > nvl(vr_qqdiacheq,0) THEN
              vr_qqdiacheq := nvl(vr_qtdiaat2,0);
            END IF;
            vr_qtdiaat2 := 0;
          END IF;

        END LOOP;
      END IF;

      IF vr_qqdiacheq = 0  THEN
        vr_qqdiacheq := vr_qtdiaat2;
      END IF;

      IF vr_qtdiaat2 > vr_qqdiacheq THEN
        vr_qqdiacheq := vr_qtdiaat2;
      END IF;

      -- Enviar informações de Cheque Especial
      vr_obj_generic2.put('quantDiasChequeEspecial', NVL(vr_qqdiacheq,0));

      -- Buscar Contrato Limite Crédito
      OPEN cr_craplim_chqesp;
      FETCH cr_craplim_chqesp
        INTO rw_craplim_chqesp;
      CLOSE cr_craplim_chqesp;

      -- Enviar as informações do limite de crédito (somente se houver limite de crédito)
      IF rw_craplim_chqesp.vllimite > 0 THEN
        vr_obj_generic2.put('dataContratoLimiteCred',este0002.fn_data_ibra_motor(rw_craplim_chqesp.dtinivig));
        vr_obj_generic2.put('limiteCredito',este0001.fn_decimal_ibra(rw_craplim_chqesp.vllimite));

        -- Enviar saldo utilizado do limite de crédito
        IF vr_tab_sald(0).vlsddisp < 0 THEN
          -- Se temos adiantamento a depositante
          IF vr_vladtdep < 0 THEN
            -- Estamos usando todo o limite
            vr_obj_generic2.put('saldoUtilizLimiteCredito',este0001.fn_decimal_ibra(rw_craplim_chqesp.vllimite));
          ELSE
            -- O Saldo negativo é o valor utilizado
            vr_obj_generic2.put('saldoUtilizLimiteCredito',este0001.fn_decimal_ibra(vr_tab_sald(0).vlsddisp));
          END IF;
        ELSE
          vr_obj_generic2.put('saldoUtilizLimiteCredito',este0001.fn_decimal_ibra(0));
        END IF;
      END IF;

      -- Acionar rotina de ocorrências na conta
      cada0004.pc_lista_ocorren(pr_cdcooper    => pr_cdcooper
                               ,pr_cdagenci    => 1
                               ,pr_nrdcaixa    => 1
                               ,pr_cdoperad    => '1'
                               ,pr_nrdconta    => pr_nrdconta
                               ,pr_rw_crapdat  => rw_crapdat
                               ,pr_idorigem    => 5
                               ,pr_idseqttl    => 1
                               ,pr_nmdatela    => 'ATENDA'
                               ,pr_flgerlog    => 'S'
                               ,pr_tab_ocorren => vr_tab_ocorren
                               ,pr_des_reto    => vr_des_reto
                               ,pr_tab_erro    => vr_tab_erro);

      IF vr_tab_ocorren.count > 0 THEN
        vr_obj_generic2.put('ratingAtivoConta', vr_tab_ocorren(vr_tab_ocorren.first).inrisctl);
        vr_obj_generic2.put('ratingConta', vr_tab_ocorren(vr_tab_ocorren.first).indrisco);
        vr_obj_generic2.put('riscoCooperado', NVL(trim(vr_tab_ocorren(vr_tab_ocorren.first).nivrisco),'A'));
      ELSE
        vr_obj_generic2.put('ratingAtivoConta', 'A');
        vr_obj_generic2.put('ratingConta', 'A');
        vr_obj_generic2.put('riscoCooperado', 'A');
      END IF;


      -- Buscar risco do grupo econômico (se existir)
      geco0001.pc_busca_grupo_associado(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_flggrupo => vr_flggrupo
                                       ,pr_nrdgrupo => vr_nrdgrupo
                                       ,pr_gergrupo => vr_gergrupo
                                       ,pr_dsdrisgp => vr_dsdrisgp);
      -- Se houver grupo
      IF vr_flggrupo = 1 THEN
        vr_obj_generic2.put('riscoGrupoEconomico', vr_dsdrisgp);
      END IF;

      -- Chamar rotina para busca das Médias da Conta Corrente
      extr0001.pc_carrega_medias(pr_cdcooper        => pr_cdcooper
                                ,pr_cdagenci        => 1
                                ,pr_nrdcaixa        => 1
                                ,pr_cdoperad        => '1'
                                ,pr_nrdconta        => pr_nrdconta
                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                ,pr_idorigem        => 5
                                ,pr_idseqttl        => 1
                                ,pr_nmdatela        => 'ATENDA'
                                ,pr_flgerlog        => 0
                                ,pr_tab_medias      => vr_tab_medias
                                ,pr_tab_comp_medias => vr_tab_comp_medias
                                ,pr_cdcritic        => vr_cdcritic
                                ,pr_dscritic        => vr_dscritic);

      -- Testar erros e se não houver, enviar os Saldos Médios
      IF vr_tab_comp_medias.count > 0 THEN
        vr_obj_generic2.put('saldoMedioAtual',este0001.fn_decimal_ibra(vr_tab_comp_medias(vr_tab_comp_medias.first).vltsddis));
        vr_obj_generic2.put('saldoMedioTrimes',este0001.fn_decimal_ibra(vr_tab_comp_medias(vr_tab_comp_medias.first).vlsmdtri));
        vr_obj_generic2.put('saldoMedioSemes',este0001.fn_decimal_ibra(vr_tab_comp_medias(vr_tab_comp_medias.first).vlsmdsem));
      ELSE
        vr_obj_generic2.put('saldoMedioAtual',este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('saldoMedioTrimes',este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('saldoMedioSemes',este0001.fn_decimal_ibra(0));
      END IF;

      -- Buscar Saldo de Cotas
      OPEN cr_crapcot;
      FETCH cr_crapcot
        INTO vr_vldcotas;
      CLOSE cr_crapcot;
      -- Enviar o saldo das cotas
      vr_obj_generic2.put('saldoCotas', este0001.fn_decimal_ibra(vr_vldcotas));

      -- Busca se o cooperado tem plano de cotas ativo
      OPEN cr_crappla;
      FETCH cr_crappla
        INTO rw_crappla;

      IF cr_crappla%FOUND THEN
        vr_temcotas := TRUE;
      ELSE
        vr_temcotas := FALSE;
      END IF;
      CLOSE cr_crappla;

      -- Enviar flag se tem Cotas
      vr_obj_generic2.put('temPlanoCotas', vr_temcotas);

      -- Buscar informações e Saldos das Aplicações
      apli0002.pc_obtem_dados_aplicacoes(pr_cdcooper       => pr_cdcooper --Codigo Cooperativa
                                        ,pr_cdagenci       => 1 --Codigo Agencia
                                        ,pr_nrdcaixa       => 1 --Numero do Caixa
                                        ,pr_cdoperad       => '1' --Codigo Operador
                                        ,pr_nmdatela       => 'ATENDA' --Nome da Tela
                                        ,pr_idorigem       => 5 --Origem dos Dados
                                        ,pr_nrdconta       => pr_nrdconta --Numero da Conta do Associado
                                        ,pr_idseqttl       => 1 --Sequencial do Titular
                                        ,pr_nraplica       => 0 --Numero da Aplicacao
                                        ,pr_cdprogra       => 'ATENDA' --Nome da Tela
                                        ,pr_flgerlog       => 0 /*FALSE*/ --Imprimir log
                                        ,pr_dtiniper       => NULL --Data Inicio periodo
                                        ,pr_dtfimper       => NULL --Data Final periodo
                                        ,pr_vlsldapl       => vr_vlsldtot --Saldo da Aplicacao
                                        ,pr_tab_saldo_rdca => vr_tab_saldo_rdca --Tipo de tabela com o saldo RDCA
                                        ,pr_des_reto       => vr_des_reto --Retorno OK ou NOK
                                        ,pr_tab_erro       => vr_tab_erro); --Tabela de Erros
      -- Se retornou erro
      IF vr_des_reto = 'NOK' THEN
        --Se possuir erro na PLTable
        IF vr_tab_erro.count > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_dscritic := 'Nao foi possivel carregar o aplicacoes.';
        END IF;

        -- Limpar tabela de erros
        vr_tab_erro.delete;

        RAISE vr_exc_saida;
      END IF;

      -- loop sobre a tabela de saldo
      vr_ind := vr_tab_saldo_rdca.first;
      WHILE vr_ind IS NOT NULL LOOP
        -- Somar o valor de resgate
        vr_vlsldapl := vr_vlsldapl + vr_tab_saldo_rdca(vr_ind).sldresga;
        vr_ind := vr_tab_saldo_rdca.next(vr_ind);
      END LOOP;

      --> Buscar saldo das aplicacoes
      apli0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                                        ,pr_cdoperad => 1 --> Código do Operador
                                        ,pr_nmdatela => 'ATENDA' --> Nome da Tela
                                        ,pr_idorigem => 5 --> AYLLOS WEB
                                        ,pr_nrdconta => pr_nrdconta --> Número da Conta
                                        ,pr_idseqttl => 1 --> Titular da Conta
                                        ,pr_nraplica => 0 --> Número da Aplicação / Parâmetro Opcional
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data de Movimento
                                        ,pr_cdprodut => 0 --> Código do Produto -–> Parâmetro Opcional
                                        ,pr_idblqrgt => 1 --> Identificador de Bloqueio de Resgate
                                        ,pr_idgerlog => 0 --> Identificador de Log (0 – Não / 1 – Sim)
                                        ,pr_vlsldtot => vr_vlsldtot --> Saldo Total da Aplicação
                                        ,pr_vlsldrgt => vr_vlsldrgt --> Saldo Total para Resgate
                                        ,pr_cdcritic => vr_cdcritic --> Código da crítica
                                        ,pr_dscritic => vr_dscritic); --> Descrição da crítica
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      vr_vlsldapl := vr_vlsldapl + vr_vlsldrgt;

      -- Verificar se há bloqueio de aplicações na conta
      OPEN cr_crapblj;
      FETCH cr_crapblj
        INTO vr_vlbloque;
      CLOSE cr_crapblj;

      -- Enviar informações das aplicações para o JSON
      vr_obj_generic2.put('temAplicacao',(nvl(vr_vlsldapl,0) > 0));
      vr_obj_generic2.put('temAplicacaoBloqueada',(nvl(vr_vlbloque,0) > 0));
      vr_obj_generic2.put('saldoDisponAplicacao',este0001.fn_decimal_ibra(GREATEST(0,nvl(vr_vlsldapl,0) - nvl(vr_vlbloque,0))));
      vr_obj_generic2.put('saldoTotalAplicacao',este0001.fn_decimal_ibra(vr_vlsldapl));

      -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
      vr_percenir:= gene0002.fn_char_para_number(tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                           ,pr_nmsistem => 'CRED'
                                                                           ,pr_tptabela => 'CONFIG'
                                                                           ,pr_cdempres => 0
                                                                           ,pr_cdacesso => 'PERCIRAPLI'
                                                                           ,pr_tpregist => 0));

      -- Buscar informações e Saldos das Poupanças Programadas
      apli0001.pc_consulta_poupanca(pr_cdcooper      => pr_cdcooper --> Cooperativa
                                   ,pr_cdagenci      => 1 --> Codigo da Agencia
                                   ,pr_nrdcaixa      => 1 --> Numero do caixa
                                   ,pr_cdoperad      => 1 --> Codigo do Operador
                                   ,pr_idorigem      => 5 --> Identificador da Origem
                                   ,pr_nrdconta      => pr_nrdconta --> Nro da conta associado
                                   ,pr_idseqttl      => 1 --> Identificador Sequencial
                                   ,pr_nrctrrpp      => 0 --> Contrato Poupanca Programada
                                   ,pr_dtmvtolt      => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dtmvtopr      => rw_crapdat.dtmvtopr --> Data do proximo movimento
                                   ,pr_inproces      => rw_crapdat.inproces --> Indicador de processo
                                   ,pr_cdprogra      => 'ATENDA' --> Nome do programa chamador
                                   ,pr_flgerlog      => FALSE --> Flag erro log
                                   ,pr_percenir      => vr_percenir --> % IR para Calculo Poupanca
                                   ,pr_tab_craptab   => vr_tab_conta_bloq --> Tipo de tabela de Conta Bloqueada
                                   ,pr_tab_craplpp   => vr_tab_craplpp --> Tipo de tabela com lancamento poupanca
                                   ,pr_tab_craplrg   => vr_tab_craplrg --> Tipo de tabela com resgates
                                   ,pr_tab_resgate   => vr_tab_resgate --> Tabela com valores dos resgates
                                   ,pr_vlsldrpp      => vr_vlsldppr --> Valor saldo poupanca programada
                                   ,pr_retorno       => vr_des_reto --> Descricao de erro ou sucesso OK/NOK
                                   ,pr_tab_dados_rpp => vr_tab_dados_rpp --> Poupancas Programadas
                                   ,pr_tab_erro      => vr_tab_erro); --> Saida com erros;
      --Se retornou erro
      IF vr_des_reto = 'NOK' THEN
        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;

        -- Limpar tabela de erros
        vr_tab_erro.delete;

        RAISE vr_exc_saida;
      END IF;

      -- Verificar se há bloqueio de aplicações na conta
      OPEN cr_crapblj_pp;
      FETCH cr_crapblj_pp
        INTO vr_vlbloque_pp;
      CLOSE cr_crapblj_pp;

      -- Enviar informações das aplicações para o JSON
      vr_obj_generic2.put('temPoupProgram',(nvl(vr_vlsldppr,0) > 0));
      vr_obj_generic2.put('temPoupProgamBloqueada',(nvl(vr_vlbloque_pp,0) > 0));
      vr_obj_generic2.put('saldoDisponPoupProgram',este0001.fn_decimal_ibra(GREATEST(0,nvl(vr_vlsldppr,0) - nvl(vr_vlbloque_pp,0))));
      vr_obj_generic2.put('saldoTotalPoupProgram',este0001.fn_decimal_ibra(nvl(vr_vlsldppr,0)));

      -- Verificar se cooperado tem Debito Automático
      OPEN cr_crapatr;
      FETCH cr_crapatr
        INTO rw_crapatr;

      IF cr_crapatr%FOUND THEN
        vr_temdebaut := TRUE;
      ELSE
        vr_temdebaut := FALSE;
      END IF;
      CLOSE cr_crapatr;

      -- Enviar flag se tem DebAutomático
      vr_obj_generic2.put('temDebaut', vr_temdebaut);

      --> Procedure para listar cartoes do cooperado
      cada0004.pc_lista_cartoes(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                               ,pr_cdagenci => 1 --> Codigo de agencia
                               ,pr_nrdcaixa => 1 --> Numero do caixa
                               ,pr_cdoperad => 1 --> Codigo do operador
                               ,pr_nrdconta => pr_nrdconta --> Numero da conta
                               ,pr_idorigem => 5 --> Identificado de oriem
                               ,pr_idseqttl => 1 --> sequencial do titular
                               ,pr_nmdatela => 'ATENDA' --> Nome da tela
                               ,pr_flgerlog => 'N' --> identificador se deve gerar log S-Sim e N-Nao
                               ,pr_flgzerar => 'N' --> Nao zerar limite
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data da cooperativa
                               ,pr_flgprcrd => 1 --> considerar apenas limite titular
                                ------ OUT ------
                               ,pr_flgativo    => vr_flgativo --> Retorna situação 1-ativo 2-inativo
                               ,pr_nrctrhcj    => vr_nrctrhcj --> Retorna numero do contrato
                               ,pr_flgliber    => vr_flgliber --> Retorna se esta liberado 1-sim 2-nao
                               ,pr_vltotccr    => vr_vltotccr --> retorna total de limite do cartao
                               ,pr_tab_cartoes => vr_tab_cartoes --> retorna temptable com os dados dos convenios
                               ,pr_des_reto    => vr_des_reto --> OK ou NOK
                               ,pr_tab_erro    => vr_tab_erro);

      -- Se houve retorno não Ok
      IF vr_des_reto = 'NOK' THEN
        -- Retornar a mensagem de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        -- Limpar tabela de erros
        vr_tab_erro.delete;
        RAISE vr_exc_saida;
      END IF;

      -- VArrer cartoes ate encontrar algum ativo
      IF vr_tab_cartoes.count > 0 THEN
        FOR vr_dx IN vr_tab_cartoes.first..vr_tab_cartoes.last LOOP
          IF vr_tab_cartoes(vr_dx).dssitcrd IN('Solic.','Liber.','Sol.2v','Prc.BB','Em uso','Sol.2v') THEN
            vr_flgativo := 1;
          END IF;
        END LOOP;
      END IF;

      -- ajustado para retornar o limite correto devido a erros na pc_lista_cartoes
      -- cartao segunda via, cartao adicional
      ccrd0001.pc_retorna_limite_conta (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_vllimtot => vr_vltotccr);

      -- Enviar flag de encontro e valor de Limite de Crédito
      vr_obj_generic2.put('temCartaoCredito',(vr_flgativo > 0));
      vr_obj_generic2.put('limiteCartaoCredito',este0001.fn_decimal_ibra(vr_vltotccr));

      -- Buscar as informações do Arquivo SCR
      OPEN cr_crapopf;
      FETCH cr_crapopf
        INTO rw_crapopf;

      IF cr_crapopf%FOUND THEN
        CLOSE cr_crapopf;

        -- Na sequencia buscar os valores dos vencimentos
        OPEN cr_crapvop(rw_crapass.nrcpfcgc);
        FETCH cr_crapvop
          INTO rw_crapvop;
        CLOSE cr_crapvop;

        -- Enfim, enviar as informações ao JSON
        vr_obj_generic2.put('conscrOpSFN',este0001.fn_decimal_ibra(rw_crapvop.vlopesfn));
        vr_obj_generic2.put('conscrOpVenc',este0001.fn_decimal_ibra(rw_crapvop.vlopevnc));
        vr_obj_generic2.put('conscrOpPrej',este0001.fn_decimal_ibra(rw_crapvop.vlopeprj));
        vr_obj_generic2.put('conscrQtOper',rw_crapopf.qtopesfn);
        vr_obj_generic2.put('conscrQtIFs',rw_crapopf.qtifssfn);
        vr_obj_generic2.put('conscr61a90',este0001.fn_decimal_ibra(rw_crapvop.vlvcto130));
      ELSE
        CLOSE cr_crapopf;

        -- Enfim, enviar as informações ao JSON
        vr_obj_generic2.put('conscrOpSFN',este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('conscrOpVenc',este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('conscrOpPrej',este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('conscrQtOper', 0);
        vr_obj_generic2.put('conscrQtIFs', 0);
        vr_obj_generic2.put('conscr61a90',este0001.fn_decimal_ibra(0));

      END IF;


      -- ajustado para retornar o limite correto devido a erros na pc_lista_cartoes
      -- cartao segunda via, cartao adicional
      ccrd0001.pc_retorna_limite_conta (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_vllimtot => vr_vltotccr);

      -- Então chamaremos a rotina para busca do endividamento total
      gene0005.pc_saldo_utiliza(pr_cdcooper    => pr_cdcooper
                               ,pr_tpdecons    => 3
                               ,pr_cdagenci    => 1
                               ,pr_nrdcaixa    => 1
                               ,pr_cdoperad    => 1
                               ,pr_nrdconta    => pr_nrdconta
                               ,pr_nrcpfcgc    => 0
                               ,pr_idseqttl    => 1
                               ,pr_idorigem    => 5
                               ,pr_dsctrliq    => null
                               ,pr_cdprogra    => 'ATENDA'
                               ,pr_tab_crapdat => rw_crapdat
                               ,pr_inusatab    => TRUE
                               ,pr_vlutiliz    => vr_vlutiliz
                               ,pr_cdcritic    => vr_cdcritic
                               ,pr_dscritic    => vr_dscritic);

      IF NVL(vr_cdcritic, 0) <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Se for erro 9, entao o associado esta com data de eliminacao preenchida.
        -- Neste caso nao deve dar erro, e sim considerar como valor zerado
        IF NVL(vr_cdcritic, 0) = 9 THEN
          vr_vlutiliz := 0;
          vr_cdcritic := 0;
          vr_dscritic := NULL;
        ELSE
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Enviar o saldo utilizado
      vr_obj_generic2.put('saldoDevedor', este0001.fn_decimal_ibra(vr_vlutiliz + vr_vltotccr));

      -- Buscar contrato de desconto cheques
      OPEN cr_craplim_chq;
      FETCH cr_craplim_chq
        INTO rw_craplim_chq;
      CLOSE cr_craplim_chq;

      -- Buscar borderôs ativos
      OPEN cr_crapcdb(rw_crapdat.dtmvtolt);
      FETCH cr_crapcdb
        INTO rw_crapcdb;
      CLOSE cr_crapcdb;

      -- Enviar informações do contrato de Cheque
      vr_obj_generic2.put('limiteDescCheq',este0001.fn_decimal_ibra(nvl(rw_craplim_chq.vllimite,0)));
      vr_obj_generic2.put('saldoUtilizDescCheq',este0001.fn_decimal_ibra(nvl(rw_crapcdb.vlcheque,0)));
      vr_obj_generic2.put('dataContrDescCheq',este0002.fn_data_ibra_motor(rw_craplim_chq.dtinivig));

      -- Buscar contrato de desconto titulos
      OPEN cr_craplim_tit;
      FETCH cr_craplim_tit
        INTO rw_craplim_tit;
      CLOSE cr_craplim_tit;

      -- Buscar borderôs ativos
      OPEN cr_craptdb(rw_crapdat.dtmvtolt);
      FETCH cr_craptdb
        INTO rw_craptdb;
      CLOSE cr_craptdb;

      -- Enviar informações do contrato de Cheque
      vr_obj_generic2.put('limiteDescTitul',este0001.fn_decimal_ibra(nvl(rw_craplim_tit.vllimite,0)));
      vr_obj_generic2.put('saldoUtilizDescTitul',este0001.fn_decimal_ibra(nvl(rw_craptdb.vltitulo,0)));
      vr_obj_generic2.put('dataContrDescTitul',este0002.fn_data_ibra_motor(rw_craplim_tit.dtinivig));

      -- Buscar outras propostas em Andamento
      OPEN cr_crawepr_outras;
      FETCH cr_crawepr_outras
        INTO rw_crawepr_outras;
      CLOSE cr_crawepr_outras;

      -- Propostas Em Andamento
      vr_obj_generic2.put('somaOperacoesAndamento',este0001.fn_decimal_ibra(nvl(rw_crawepr_outras.vlsdeved,0)));
      vr_obj_generic2.put('somaPrestacoesAndamento',este0001.fn_decimal_ibra(nvl(rw_crawepr_outras.vlpreemp,0)));

      -- Soma das Operações em Andamento
      vr_obj_generic2.put('somaOperacoes',este0001.fn_decimal_ibra(nvl(vr_vlendivi,0)));
      vr_obj_generic2.put('somaPrestacoes',este0001.fn_decimal_ibra(nvl(vr_vltotpre,0)));

      --Verificar se usa tabela juros
      vr_dstextab:= tabe0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);

      -- Se a primeira posição do campo dstextab for diferente de zero
      vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';

      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab_parempctl := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                         ,pr_nmsistem => 'CRED'
                                                         ,pr_tptabela => 'USUARI'
                                                         ,pr_cdempres => 11
                                                         ,pr_cdacesso => 'PAREMPCTL'
                                                         ,pr_tpregist => 01);

      -- busca o tipo de documento GED
      vr_dstextab_digitaliza := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                          ,pr_nmsistem => 'CRED'
                                                          ,pr_tptabela => 'GENERI'
                                                          ,pr_cdempres => 00
                                                          ,pr_cdacesso => 'DIGITALIZA'
                                                          ,pr_tpregist => 5);

      -- Buscar todos os contratos do Cooperado
      empr0001.pc_obtem_dados_empresti(pr_cdcooper       => pr_cdcooper --> Cooperativa conectada
                                      ,pr_cdagenci       => 1 --> Código da agência
                                      ,pr_nrdcaixa       => 1 --> Número do caixa
                                      ,pr_cdoperad       => '1' --> Código do operador
                                      ,pr_nmdatela       => 'EXTEMP' --> Nome datela conectada
                                      ,pr_idorigem       => 5 --> Indicador da origem da chamada
                                      ,pr_nrdconta       => pr_nrdconta --> Conta do associado
                                      ,pr_idseqttl       => 1 --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat     => rw_crapdat --> Vetor com dados de parâmetro (CRAPDAT)
                                      ,pr_dtcalcul       => NULL --> Data solicitada do calculo
                                      ,pr_nrctremp       => 0 --> Número contrato empréstimo
                                      ,pr_cdprogra       => 'ATENDA' --> Programa conectado
                                      ,pr_inusatab       => vr_inusatab --> Indicador de utilização da tabela de juros
                                      ,pr_flgerlog       => 'N' --> Gerar log S/N
                                      ,pr_flgcondc       => FALSE --> Mostrar emprestimos liq. s/ prejuizo
                                      ,pr_nmprimtl       => rw_crapass.nmprimtl --> Nome Primeiro Titular
                                      ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                                      ,pr_tab_digitaliza => vr_dstextab_digitaliza --> Dados tabela parametro
                                      ,pr_nriniseq       => 0 --> Numero inicial da paginacao
                                      ,pr_nrregist       => 0 --> Numero de registros por pagina
                                      ,pr_qtregist       => vr_qtregist --> Qtde total de registros
                                      ,pr_tab_dados_epr  => vr_tab_dados_epr --> Saida com os dados do empréstimo
                                      ,pr_des_reto       => vr_des_reto --> Retorno OK / NOK
                                      ,pr_tab_erro       => vr_tab_erro); --> Tabela com possíves erros

      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN

          vr_dscritic := 'Conta: ' || pr_nrdconta ||
                         ' nao possui emprestimo.: ' ||
                        -- concatenado a critica na versao oracle para tbm saber a causa de abortar o programa
                         vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_dscritic := 'Conta: ' || pr_nrdconta ||
                         ' nao possui emprestimo.';
        END IF;
        RAISE vr_exc_saida;
      END IF;

      -- Buscar parâmetro da quantidade de meses para encontro do histórico de empréstimos
      vr_qthisemp := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_EMPRES_CRD');

      -- Zerar variaveis auxiliares
      vr_nratrmai := 0;
      vr_vltotatr := 0;
      vr_qtpclven := 0;
      vr_qtpclatr := 0;
      vr_qtpclpag := 0;
      vr_tot_qtpclatr := 0;
      vr_tot_qtpclpag := 0;
      vr_maior_nratrmai := 0;

      -- varrer temptable de emprestimos
      vr_idxempr := vr_tab_dados_epr.first;
      WHILE vr_idxempr IS NOT NULL LOOP
        -- Para aqueles com saldo devedor
        IF vr_tab_dados_epr(vr_idxempr).vlsdeved > 0 THEN
          -- Chamar calculo de dias em atraso
          este0002.pc_calc_dias_atraso(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => vr_tab_dados_epr(vr_idxempr).nrctremp
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                      ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                      ,pr_tpemprst => vr_tab_dados_epr(vr_idxempr).tpemprst
                                      ,pr_qtmesdec => vr_tab_dados_epr(vr_idxempr).qtmesdec
                                      ,pr_dtdpagto => vr_tab_dados_epr(vr_idxempr).dtdpagto
                                      ,pr_qtprecal => vr_tab_dados_epr(vr_idxempr).qtprecal
                                      ,pr_flgpagto => vr_tab_dados_epr(vr_idxempr).flgpagto
                                      ,pr_qtdiaatr   => vr_dias
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_des_erro   => vr_dscritic);
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
            --Levantar Exceção
            RAISE vr_exc_saida;
          END IF;

          -- Se há atraso
          IF vr_dias > 0 THEN

            IF vr_dias > vr_maior_nratrmai THEN
              vr_maior_nratrmai := vr_dias;
            END IF;
            -- Acumular saldo em atraso
            vr_vltotatr := vr_vltotatr + vr_tab_dados_epr(vr_idxempr).vlpreapg
                                       + vr_tab_dados_epr(vr_idxempr).vlmrapar
                                       + vr_tab_dados_epr(vr_idxempr).vlmtapar;
            -- Meses em atraso
            vr_qtpclven := vr_qtpclven + CEIL(vr_dias/30);
          END IF;

        END IF;

        -- Calculo de Parcelas conforme tipo de empréstimo
        IF vr_tab_dados_epr(vr_idxempr).tpemprst = 1 THEN
          -- Para PP, buscaremos no cadastro de parcelas a quantidade de parcelas pagas em atraso
          OPEN cr_crappep_atraso(rw_crapdat.dtmvtolt
                                ,vr_tab_dados_epr(vr_idxempr).nrctremp
                                ,vr_qthisemp);
          FETCH cr_crappep_atraso
            INTO vr_qtpclatr;
          CLOSE cr_crappep_atraso;

          -- Para as parcelas pagas também buscaremos no cadastro de parcelas
          OPEN cr_crappep_pagtos(rw_crapdat.dtmvtolt
                                ,vr_tab_dados_epr(vr_idxempr).nrctremp
                                ,vr_qthisemp);
          FETCH cr_crappep_pagtos
            INTO vr_qtpclpag;
          CLOSE cr_crappep_pagtos;

        ELSE
          -- Para TR, buscaremos nos lançamentos de pagtos a quantidade de lançamentos de Multa
          OPEN cr_craplem_atraso(rw_crapdat.dtmvtolt
                                ,vr_tab_dados_epr(vr_idxempr).nrctremp
                                ,vr_qthisemp);
          FETCH cr_craplem_atraso
            INTO vr_qtpclatr;
          CLOSE cr_craplem_atraso;

          -- Somar o valor pago nos ultimos 6 meses
          OPEN cr_craplem_pago(rw_crapdat.dtmvtolt
                              ,vr_tab_dados_epr(vr_idxempr).nrctremp
                              ,vr_qthisemp);
          FETCH cr_craplem_pago
            INTO vr_vlpclpag;
          CLOSE cr_craplem_pago;
          -- Quantidade Parcelas paga é Valor Paga nos ultimos 6 meses / Valor da Parcela
          vr_qtpclpag := ROUND(vr_vlpclpag / vr_tab_dados_epr(vr_idxempr)
                               .vlpreemp);

          -- Descontar da quantidade paga a quantidade em atraso, pq mesmo tendo pago
          -- proporcionalmente o valor total da parcela, se teve multa no mês significa
          -- que foi pago após o vencimento
          vr_qtpclpag := vr_qtpclpag - vr_qtpclatr;

          -- Garantir que não fique negativo, portanto se for negativo trará zero.
          vr_qtpclpag := greatest(0, vr_qtpclpag);

        END IF;

        -- TOtalizar
        vr_tot_qtpclatr :=  vr_tot_qtpclatr + vr_qtpclatr;
        vr_tot_qtpclpag :=  vr_tot_qtpclpag + vr_qtpclpag;

        -- Buscar o próximo
        vr_idxempr := vr_tab_dados_epr.next(vr_idxempr);
      END LOOP;

      -- Busca maior atraso dentre os emprestimos do cooperado
      BEGIN
        SELECT MAX(ris.qtdiaatr) qtdiaatr
          INTO vr_nratrmai
          FROM crapris ris
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.nrdconta = pr_nrdconta
           AND ris.nrctremp = NVL(NULL,ris.nrctremp)
           AND ris.dtrefere >= add_months(rw_crapdat.dtmvtolt,-vr_qthisemp)
           AND ris.cdmodali in(299,499)
           AND ris.inddocto = 1;
      END;
      -- Enviar informações do atraso e parcelas calculadas para o JSON
      vr_obj_generic2.put('valorAtrasoEmprest',este0001.fn_decimal_ibra(vr_vltotatr));
      vr_obj_generic2.put('quantDiasMaiorAtrasoEmprest', vr_nratrmai);
      vr_obj_generic2.put('quantDiasAtrasoEmprest', vr_maior_nratrmai);
      vr_obj_generic2.put('quantParcelAtraso', vr_qtpclven);
      vr_obj_generic2.put('quantParcelPagas', vr_tot_qtpclpag);
      vr_obj_generic2.put('quantParcelPagasAtraso', vr_tot_qtpclatr);

      -- Verificar co-responsabilidade
      empr0003.pc_gera_co_responsavel(pr_cdcooper           => pr_cdcooper
                                     ,pr_cdagenci           => 1
                                     ,pr_nrdcaixa           => 1
                                     ,pr_cdoperad           => '1'
                                     ,pr_nmdatela           => 'ATENDA'
                                     ,pr_idorigem           => 5
                                     ,pr_cdprogra           => 'ATENDA'
                                     ,pr_nrdconta           => pr_nrdconta
                                     ,pr_idseqttl           => 1
                                     ,pr_dtcalcul           => rw_crapdat.dtmvtolt
                                     ,pr_flgerlog           => 'N'
                                     ,pr_vldscchq           => rw_craplim_chq.vllimite /* Valor Limite Cheques */
                                     ,pr_vlutlchq           => rw_crapcdb.vlcheque /* Valor utilizado Cheques */
                                     ,pr_vldctitu           => rw_craplim_tit.vllimite /* Valor Limite Titulos */
                                     ,pr_vlutitit           => rw_craptdb.vltitulo /* Valor utilizado Titulos */
                                     ,pr_tab_co_responsavel => vr_tab_co_responsavel
                                     ,pr_dscritic           => vr_dscritic
                                     ,pr_cdcritic           => vr_cdcritic);

      -- Testar possíveis erros no retorno prevendo já o formato convertido…
      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Loop para buscar todos os contratos em que o avalista é co-resposável
      vr_ind_coresp := vr_tab_co_responsavel.first;
      WHILE vr_ind_coresp IS NOT NULL LOOP

        /* Se Saldo Devedor Maior que Zero */
        IF vr_tab_co_responsavel(vr_ind_coresp).vlsdeved > 0 THEN

          -- Se ha pagamento a pagar
          IF NVL(vr_tab_co_responsavel(vr_ind_coresp).vlpreapg,0)
           + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlmrapar,0)
           + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlmtapar,0) > 0 THEN
           -- Acumular atraso
            vr_tot_qtprecal := vr_tot_qtprecal + 1;
            vr_ava_vlsdeved := vr_ava_vlsdeved + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlpreapg,0)
                                               + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlmrapar,0)
                                               + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlmtapar,0);

            -- Data do maior atraso.
            IF vr_dtdpagto_atr IS NULL THEN
              vr_dtdpagto_atr := vr_tab_co_responsavel(vr_ind_coresp).dtdpagto;
            ELSE
              IF vr_dtdpagto_atr > vr_tab_co_responsavel(vr_ind_coresp).dtdpagto THEN
                vr_dtdpagto_atr := vr_tab_co_responsavel(vr_ind_coresp).dtdpagto;
              END IF;
            END IF;

          END IF;
          /* Somar totais */
          vr_tot_vlsdeved := vr_tot_vlsdeved + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlsdeved,0);

        END IF;

        -- Buscar próximo registro
        vr_ind_coresp := vr_tab_co_responsavel.next(vr_ind_coresp);
      END LOOP;

      -- Enfim, enviar as informações para o JSON (Neste ponto voltamos a trazer código PLSQL)
      vr_obj_generic2.put('coopAvalista',(vr_tot_vlsdeved > 0));
      vr_obj_generic2.put('valorCoopAvalista',este0001.fn_decimal_ibra(vr_tot_vlsdeved));
      vr_obj_generic2.put('coopAvalistaAtraso',(vr_tot_qtprecal > 0));
      vr_obj_generic2.put('valorAvalistaAtraso',este0001.fn_decimal_ibra(vr_ava_vlsdeved));

      -- Montar objeto para OpCred
      vr_lst_generic3 := json_list();

      -- Lógica para retorno das ultimas operações de Crédito Liquidadas
      -- Primeiramente buscamos a quantidade de operações a serem enviadas
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PROPOSTEPR'
                                               ,pr_tpregist => 0);
      -- Conforme o tipo de pessoa
      IF rw_crapass.inpessoa = 1 THEN
        vr_qtdopliq := SUBSTR(vr_dstextab, 44, 3);
      ELSE
        vr_qtdopliq := SUBSTR(vr_dstextab, 52, 3);
      END IF;

      GENE0001.pc_set_modulo(pr_module => 'ESTE0005', pr_action => 'Risco '||pr_nrdconta);

      -- Efetuar laço para trazer todos os registros
      FOR rw_crapepr IN cr_crapepr LOOP

        -- Verificar a quantidade de registros já lidos, pois não poderá passer da quantidade parametrizada
        IF vr_qtdopliq < cr_crapepr%rowcount THEN
          EXIT;
        END IF;

        -- Busca data da Liquidação
        OPEN cr_dtliquid(rw_crapepr.nrctremp);
        FETCH cr_dtliquid
          INTO vr_dtliquid;
        CLOSE cr_dtliquid;

        GENE0001.pc_set_modulo(pr_module => 'ESTE0005', pr_action => pr_cdcooper||' '||pr_nrdconta||' '||rw_crapepr.nrctremp||' '||rw_crapepr.dtmvtolt);

        BEGIN
          SELECT MAX(ris.qtdiaatr) qtdiaatr
            INTO vr_qtdiaatr
            FROM crapris ris
           WHERE ris.cdcooper = pr_cdcooper
             AND ris.nrdconta = pr_nrdconta
             AND ris.nrctremp = NVL(rw_crapepr.nrctremp,ris.nrctremp)
             AND ris.dtrefere >= rw_crapepr.dtmvtolt
             AND ris.cdmodali in(299,499)
             AND ris.inddocto = 1;
        END;

        GENE0001.pc_set_modulo(pr_module => 'ESTE0005', pr_action => 'OI '||rw_crapepr.nrctremp||' data '||rw_crapepr.dtmvtolt);

        OPEN cr_eprliquid(rw_crapepr.nrctremp);
        FETCH cr_eprliquid
          INTO rw_eprliquid;

        IF cr_eprliquid%FOUND THEN
          vr_flliquid := TRUE;
        ELSE
          vr_flliquid := FALSE;
        END IF;
        CLOSE cr_eprliquid;

        -- Criar objeto para a operação e enviar suas informações
        vr_obj_generic3 := json();
        vr_obj_generic3.put('contratOpCred',gene0002.fn_mask_contrato(rw_crapepr.nrctremp));
        vr_obj_generic3.put('dataContratOpCred', este0002.fn_Data_ibra_motor(rw_crapepr.dtmvtolt));
        vr_obj_generic3.put('valorOpCred',este0001.fn_decimal_ibra(rw_crapepr.vlemprst));
        vr_obj_generic3.put('valorPrestOpCred',este0001.fn_decimal_ibra(rw_crapepr.vlpreemp));
        vr_obj_generic3.put('quantPrestOpCred',este0001.fn_decimal_ibra(rw_crapepr.qtpreemp));
        vr_obj_generic3.put('finalidadeOpCredCodigo', rw_crapepr.cdfinemp);
        vr_obj_generic3.put('finalidadeOpCredDescricao', rw_crapepr.dsfinemp);
        vr_obj_generic3.put('linhaOpCredCodigo', rw_crapepr.cdlcremp);
        vr_obj_generic3.put('linhaOpCredDescricao', rw_crapepr.dslcremp);
        vr_obj_generic3.put('liquidacaoOpCred', este0002.fn_Data_ibra_motor(vr_dtliquid));
        vr_obj_generic3.put('pontualidadeOpCred',este0002.fn_des_pontualidade(vr_qtdiaatr));
        vr_obj_generic3.put('atrasoOpCred',(nvl(vr_qtdiaatr,0) > 0));
        vr_obj_generic3.put('propostasLiquidOpCred', vr_flliquid);

        -- Adicionar Operação na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());

      END LOOP; -- Final da leitura das operações

      GENE0001.pc_set_modulo(pr_module => 'ESTE0005', pr_action => 'fim Risco '||pr_nrdconta);

      -- Adicionar o array OpCred no objeto informações adicionais
      vr_obj_generic2.put('opCred', vr_lst_generic3);

      -- Buscar parâmetro da quantidade de meses para busca dos Estouros/Adiantamentos
      vr_qtmesest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_EST_CRD');

      -- Montar objeto para Estrutura Estouros
      vr_lst_generic3 := json_list();


      /* Obter as informaões de estouro do cooperado */
      risc0001.pc_lista_estouros( pr_cdcooper      => pr_cdcooper     --> Codigo Cooperativa
                                 ,pr_cdoperad      => '1'             --> Operador conectado
                                 ,pr_nrdconta      => pr_nrdconta     --> Numero da Conta
                                 ,pr_idorigem      => 5               --> Identificador Origem
                                 ,pr_idseqttl      => 1               --> Sequencial do Titular
                                 ,pr_nmdatela      => 'RATI0001'      --> Nome da tela
                                 ,pr_dtmvtolt      => rw_crapdat.dtmvtolt --> Data do movimento
                                 ,pr_tab_estouros  => vr_tab_estouros --> Informações de estouro na conta
                                 ,pr_dscritic      => vr_dscritic);   --> Retorno de erro

      -- verificar se retornou critica
      IF vr_dscritic is not null THEN
        raise vr_exc_saida;
      END IF;

      /* Data do inicio do estouro a partir de um ano atras */
      vr_dtiniest := add_months(rw_crapdat.dtmvtolt, -vr_qtmesest);

      -- varrer temptable de estouro
      IF vr_tab_estouros.count > 0 THEN
        FOR I IN vr_tab_estouros.FIRST..vr_tab_estouros.LAST LOOP
          IF vr_tab_estouros(I).dtiniest >= vr_dtiniest AND vr_tab_estouros(I).cdhisest  = 'Estouro' THEN
            -- Para cada registro de Estouro, criar objeto para a operação e enviar suas informações
            vr_obj_generic3 := json();
            vr_obj_generic3.put('dataEstouro',este0002.fn_Data_ibra_motor(vr_tab_estouros(I).dtiniest));
            vr_obj_generic3.put('quantDiaEstouro', vr_tab_estouros(I).qtdiaest);
            vr_obj_generic3.put('valorEstouro',este0001.fn_decimal_ibra(vr_tab_estouros(I).vlestour));

            -- Adicionar Operação na lista
            vr_lst_generic3.append(vr_obj_generic3.to_json_value());
          END IF;
        END LOOP;
      END IF;

      -- Adicionar o array Estouros no objeto informações adicionais
      vr_obj_generic2.put('estouro', vr_lst_generic3);

      -- Montar objeto para CheqDevol
      vr_lst_generic3 := json_list();

      -- Buscar parâmetro da quantidade de meses para busca dos Estouros/Adiantamentos
      vr_qtmeschq := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DEVCHQ_CRD');

      -- Efetuar laço para trazer todos os registros
      FOR rw_negchq IN cr_crapneg_cheq(vr_qtmeschq) LOOP

        -- Criar objeto para a operação e enviar suas informações
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataCheqDevol',este0002.fn_data_ibra_motor(rw_negchq.dtiniest));
        vr_obj_generic3.put('valorCheqDevol',este0001.fn_decimal_ibra(rw_negchq.vlestour));
        vr_obj_generic3.put('alineaCheqDevol', rw_negchq.cdobserv);

        -- Adicionar Operação na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());

      END LOOP; -- Final da leitura das operações

      -- Adicionar o array CheqDevol no objeto informações adicionais
      vr_obj_generic2.put('cheqDevol', vr_lst_generic3);

      -- Montar objeto para seguro
      vr_lst_generic3 := json_list();

      -- Buscar todos os seguros da Conta do Cooperado
      -- Efetuar laço para trazer todos os registros
      FOR rw_crapseg IN cr_crapseg LOOP

        -- Criar objeto para a operação e enviar suas informações
        vr_obj_generic3 := json();
        vr_obj_generic3.put('tipoSeguro', rw_crapseg.dstipo);
        vr_obj_generic3.put('valorApoliceSeguro',este0001.fn_decimal_ibra(rw_crapseg.vlpremio));
        vr_obj_generic3.put('tipoPagtoSeguro', 'Debito Automático');

        -- Adicionar Operação na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());

      END LOOP; -- Final da leitura os seguros

      -- Adicionar o array seguro no objeto informações adicionais
      vr_obj_generic2.put('seguro', vr_lst_generic3);

      --Novos campos para Cartão de Crédito
      -- Verifica se é impossibilitado de negativação (CIN)
      OPEN cr_crapcyc( pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapcyc INTO rw_crapcyc;

      -- se não possuir contrato de limite de credito, não precisa
      -- verificar a sda
      IF cr_crapcyc%NOTFOUND THEN
        CLOSE cr_crapcyc;
        vr_obj_generic2.put('cin', FALSE);
      ELSE
        CLOSE cr_crapcyc;
        vr_obj_generic2.put('cin', TRUE);
      END IF;

      --Busca dias de atraso do cartão
      OPEN cr_crdalat(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crdalat INTO rw_crdalat ;

      IF cr_crdalat%NOTFOUND THEN
        CLOSE cr_crdalat;
        vr_obj_generic2.put('quantAtrasoCartaoCecred', 0);
      ELSE
        CLOSE cr_crdalat;
        vr_obj_generic2.put('quantAtrasoCartaoCecred', rw_crdalat.qtdias_atraso);
      END IF;

      --Parcela com maior atraso
      vr_obj_generic2.put('dataParcelaMaiorAtrasoAval', este0002.fn_data_ibra_motor(vr_dtdpagto_atr));

      --Busca informação cessão cartão
      OPEN cr_crapepr_cessao (pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta);
      FETCH cr_crapepr_cessao INTO rw_crapepr_cessao;

      IF cr_crapepr_cessao%NOTFOUND THEN
        CLOSE cr_crapepr_cessao;
      ELSE
        CLOSE cr_crapepr_cessao;
        vr_obj_generic2.put('dataOpCessaoCredito', este0002.fn_data_ibra_motor(rw_crapepr_cessao.dtultcessao));
        vr_obj_generic2.put('existeCessaoAtiva', nvl(rw_crapepr_cessao.flgtemcessaoativa,0)=1);
      END IF;

      --Busca informação de Renegociação e Composição
      OPEN cr_rencomp(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_dtmovto  => vr_qthisemp);
      FETCH cr_rencomp INTO rw_rencomp;

      IF cr_rencomp%NOTFOUND THEN
        CLOSE cr_rencomp;
        vr_obj_generic2.put('teveComposicao',false);
        vr_obj_generic2.put('teveRenegociacao',false);
      ELSE
        CLOSE cr_rencomp;
        IF rw_rencomp.temrenegociacao = 1 then
          vr_obj_generic2.put('teveRenegociacao',true);
        ELSE
          vr_obj_generic2.put('teveRenegociacao',false);
        END IF;
        IF rw_rencomp.temcomposicao = 1 THEN
          vr_obj_generic2.put('teveComposicao',true);
        ELSE
          vr_obj_generic2.put('teveComposicao',false);
        END IF;
      END IF;

      -- Montar objeto para Negativação Cyber
      vr_lst_generic3 := json_list();

      -- Buscar todos os dados do SPC
      -- Efetuar laço para trazer todos os registros
      FOR rw_crapspc IN cr_crapspc(pr_dtinclus => vr_qthisemp) LOOP

        -- Criar objeto para a operação e enviar suas informações
        vr_obj_generic3 := json();
        vr_obj_generic3.put('numeroContrato',rw_crapspc.nrctremp);
        vr_obj_generic3.put('numeroContratoSPC',rw_crapspc.nrctrspc);
        vr_obj_generic3.put('dataVencimento',este0002.fn_data_ibra_motor(rw_crapspc.dtvencto));
        vr_obj_generic3.put('dataInclusao',este0002.fn_data_ibra_motor(rw_crapspc.dtinclus));
        vr_obj_generic3.put('dataBaixa',este0002.fn_data_ibra_motor(rw_crapspc.dtdbaixa));
        vr_obj_generic3.put('tpIdentificacao',rw_crapspc.tpidenti);
        vr_obj_generic3.put('cdOrigem',rw_crapspc.cdorigem);
        vr_obj_generic3.put('tpInstituicao',rw_crapspc.tpinsttu);
        vr_obj_generic3.put('vlDivida',este0001.fn_decimal_ibra(rw_crapspc.vldivida));

        -- Adicionar Operação na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());

      END LOOP; -- Final da leitura das negativações

      -- Adicionar o array seguro no objeto informações adicionais
      vr_obj_generic2.put('negativacaoCyber', vr_lst_generic3);

      --Limpa variáveis SCR
      vr_cont_SCR := 0;
      vr_atrasoscr := FALSE;
      vr_prejscr := FALSE;

      -- Buscar as informações do Arquivo SCR
      FOR rw_crapopf IN cr_crapopf LOOP
        vr_cont_SCR := vr_cont_SCR + 1;

        -- Na sequencia buscar os valores dos vencimentos
        OPEN cr_crapvop(rw_crapass.nrcpfcgc);
        FETCH cr_crapvop
          INTO rw_crapvop;
        CLOSE cr_crapvop;

        IF rw_crapvop.vlopevnc > 0 THEN
           vr_atrasoscr := TRUE;
        END IF;

        IF rw_crapvop.vlopeprj > 0 THEN
          vr_prejscr := TRUE;
        END IF;

        IF vr_cont_SCR = 3 THEN
          EXIT;
        END IF;
      END LOOP;

      vr_obj_generic2.put('existeAtraso3BasesSCR',vr_atrasoscr);
      vr_obj_generic2.put('existePrej3BasesSCR',vr_prejscr);

      -- Somente para Pessoa Fisica
      IF rw_crapass.inpessoa = 1 THEN

        -- Data Consulta CPF
        IF rw_crapttl.dtcnscpf IS NOT NULL THEN
          vr_obj_generic2.put('dataConsultaCPF',este0002.fn_Data_ibra_motor(rw_crapttl.dtcnscpf));
        END IF;

        -- Situação CPF
        vr_obj_generic2.put('situacaoCPF',rw_crapttl.cdsitcpf);

        -- Naturalidade
        IF rw_crapttl.dsnatura <> ' ' THEN
          vr_obj_generic2.put('naturalidadeDescricao', rw_crapttl.dsnatura);
        END IF;

        -- Habilitação Menor
        vr_obj_generic2.put('reponsabiLegal',rw_crapttl.inhabmen);

        -- Data Emancipação
        IF rw_crapttl.dthabmen IS NOT NULL THEN
          vr_obj_generic2.put('dataEmancipa',este0002.fn_data_ibra_motor(rw_crapttl.dthabmen));
        END IF;

        -- Estado Civil
        IF rw_crapttl.cdestcvl <> 0 THEN
          vr_obj_generic2.put('estadoCivil',rw_crapttl.cdestcvl);
        END IF;

        -- Escolaridade
        IF rw_crapttl.grescola <> 0 THEN
          vr_obj_generic2.put('escolaridade',rw_crapttl.grescola);
        END IF;

        -- Curso Superior
        IF rw_crapttl.cdfrmttl <> 0 THEN
          vr_obj_generic2.put('cursoSuperiorCodigo',rw_crapttl.cdfrmttl);
          vr_obj_generic2.put('cursoSuperiorDescricao',este0002.fn_des_cdfrmttl(rw_crapttl.cdfrmttl));
        END IF;

        -- Nome Pai
        IF rw_crapttl.nmpaittl <> ' ' THEN
          vr_obj_generic2.put('nomePai', rw_crapttl.nmpaittl);
        END IF;

        -- Natureza Ocupação
        IF rw_crapttl.cdnatopc <> 0 THEN
          vr_obj_generic2.put('naturezaOcupacao',rw_crapttl.cdnatopc);
        END IF;

        -- Ocupação
        IF rw_crapttl.cdocpttl <> 0 THEN
          vr_obj_generic2.put('ocupacaoCodigo',rw_crapttl.cdocpttl);
          vr_obj_generic2.put('ocupacaoDescricao',este0002.fn_des_cdocupa(rw_crapttl.cdocpttl));
        END IF;

        -- Tipo Contrato de Trabalho
        IF rw_crapttl.tpcttrab <> 0 THEN
          vr_obj_generic2.put('tipoContratoTrabalho',rw_crapttl.tpcttrab);
        END IF;

        -- CNPJ Empresa
        IF rw_crapttl.nrcpfemp <> 0 THEN
          vr_obj_generic2.put('codCNPJEmpresa', rw_crapttl.nrcpfemp);
        END IF;

        -- Nivel Cargo
        IF rw_crapttl.cdnvlcgo <> 0 THEN
          vr_obj_generic2.put('nivelCargo',rw_crapttl.cdnvlcgo);
        END IF;

        -- Turno
        IF rw_crapttl.cdturnos <> 0 THEN
          vr_obj_generic2.put('turno',rw_crapttl.cdturnos);
        END IF;

        -- Pessoa Politicamente Exposta
        vr_obj_generic2.put('pessoaPoliticamenteExposta',(NVL(rw_crapttl.inpolexp,0)=1));

        -- Data Admissão
        IF rw_crapttl.dtadmemp IS NOT NULL THEN
          vr_obj_generic2.put('dataAdmissao',este0002.fn_data_ibra_motor(rw_crapttl.dtadmemp));
        END IF;

        -- Valor Rendimento
        IF pr_vlsalari > rw_crapttl.vlrendim THEN
          vr_obj_generic2.put('valorSalario',este0001.fn_decimal_ibra(pr_vlsalari));
        ELSE
          vr_obj_generic2.put('valorSalario',este0001.fn_decimal_ibra(rw_crapttl.vlrendim));
        END IF;

        -- Outros Rendimentos
        vr_obj_generic2.put('valorOutrosRendim',este0001.fn_decimal_ibra(rw_crapttl.vroutrorn));

        -- Tipo Comprovante de Renda
        IF rw_crapttl.cdnatopc = 8 THEN
          vr_tpcmpvrn := 'C';
        ELSIF rw_crapttl.tpcttrab = 1 THEN
          vr_tpcmpvrn := 'F';
        ELSIF rw_crapttl.tpcttrab = 4 THEN
          vr_tpcmpvrn := 'R';
        ELSE
          vr_tpcmpvrn := 'S';
        END IF;

        vr_obj_generic2.put('tipoComprovanteRenda', vr_tpcmpvrn);

        OPEN cr_depend;
        FETCH cr_depend
          INTO vr_qtdepend;
        CLOSE cr_depend;

        vr_obj_generic2.put('quantDependentes', vr_qtdepend);

        -- Data de Admissão Procuração
        IF pr_dtadmsoc IS NOT NULL THEN
          vr_obj_generic2.put('dataAdmissaoProcuracao' ,este0002.fn_data_ibra_motor(pr_dtadmsoc));
        END IF;

        -- Percentual Procuração
        IF pr_persocio IS NOT NULL THEN
          vr_obj_generic2.put('valorPercentualProcuracao' ,este0001.fn_decimal_ibra(pr_persocio));
        END IF;

        -- Data de Vigência Procuração
        IF pr_dtvigpro IS NOT NULL THEN
          vr_obj_generic2.put('dataVigenciaProcuracao' ,este0002.fn_data_ibra_motor(pr_dtvigpro));
        END IF;

      ELSE

        -- Nome Fantasia
        IF rw_crapjur.nmfansia <> ' ' THEN
          vr_obj_generic2.put('nomeFantasia', rw_crapjur.nmfansia);
        END IF;

        -- Data Consulta CNPJ
        IF rw_crapass.dtcnscpf IS NOT NULL THEN
          vr_obj_generic2.put('dataConsultaCNPJ',este0002.fn_data_ibra_motor(rw_crapass.dtcnscpf));
        END IF;

        -- Situação CNPJ
        vr_obj_generic2.put('situacaoCNPJ',rw_crapass.cdsitcpf);

        -- Natureza Juridica
        IF rw_crapjur.natjurid <> 0 THEN
          -- Buscar descrição
          OPEN cr_nature(rw_crapjur.natjurid);
          FETCH cr_nature
            INTO vr_dsnatjur;
          CLOSE cr_nature;

          vr_obj_generic2.put('naturezaJuridicaCodigo',rw_crapjur.natjurid);
          vr_obj_generic2.put('naturezaJuridicaDescricao',vr_dsnatjur);
        END IF;

        -- CNAE
        IF rw_crapass.cdclcnae <> 0 THEN
          -- Buscar descrição
          OPEN cr_cnae(rw_crapass.cdclcnae);
          FETCH cr_cnae
            INTO vr_dscnae;
          CLOSE cr_cnae;

          vr_obj_generic2.put('cnaeCodigo',rw_crapass.cdclcnae);
          vr_obj_generic2.put('cnaeDescricao',vr_dscnae);
        END IF;

        -- Quantidade Filiais
        vr_obj_generic2.put('quantFiliais', rw_crapjur.qtfilial);

        -- Quantidade Funcionários
        vr_obj_generic2.put('quantFuncionarios', rw_crapjur.qtfuncio);

        -- Setor Economico
        IF rw_crapjur.cdseteco <> 0 THEN

          -- Buscar descrição
          vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'SETORECONO'
                                                   ,pr_tpregist => rw_crapjur.cdseteco);
          -- Se Encontrou
          IF TRIM(vr_dstextab) IS NOT NULL THEN
            vr_nmseteco := vr_dstextab;
          ELSE
            vr_nmseteco := 'Nao Cadastrado';
          END IF;

          vr_obj_generic2.put('setorEconomicoCodigo',rw_crapjur.cdseteco);
          vr_obj_generic2.put('setorEconomicoDescricao',vr_nmseteco);
        END IF;

        -- Ramo Atividade
        IF rw_crapjur.cdseteco <> 0 AND rw_crapjur.cdrmativ <> 0 THEN
          -- Buscar descrição
          OPEN cr_ramatv(rw_crapjur.cdseteco
                        ,rw_crapjur.cdrmativ);
          FETCH cr_ramatv
            INTO vr_dsramatv;
          CLOSE cr_ramatv;

          vr_obj_generic2.put('ramoAtividadeCodigo',rw_crapjur.cdrmativ);
          vr_obj_generic2.put('ramoAtividadeDescricao',vr_dsramatv);
        END IF;

        -- Valor Faturamento Anual
        vr_obj_generic2.put('valorFaturamentoAnual',este0001.fn_decimal_ibra(rw_crapjur.vlfatano));

        -- Buscar faturamento médio mensal
        cada0001.pc_calcula_faturamento(pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => 1
                                       ,pr_nrdcaixa => 1
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_vlmedfat => vr_vlmedfat
                                       ,pr_tab_erro => vr_tab_erro
                                       ,pr_des_reto => vr_des_reto);

        -- Media Faturamento Anual
        vr_obj_generic2.put('mediaFaturamentoAnual', este0001.fn_decimal_ibra(round(vr_vlmedfat,0)));

        -- Capital Realizado
        vr_obj_generic2.put('capitalRealizado',este0001.fn_decimal_ibra(rw_crapjur.vlcaprea));

        -- Data de registro da empresa
        IF rw_crapjur.dtregemp IS NOT NULL THEN
          vr_obj_generic2.put('dataRegistroEmpresa',este0002.fn_Data_ibra_motor(rw_crapjur.dtregemp));
        END IF;

        -- Numero Registro Empresa
        IF rw_crapjur.nrregemp <> 0 THEN
          vr_obj_generic2.put('numeroRegistroEmpresa', rw_crapjur.nrregemp);
        END IF;

        -- Orgao de Registro da Empresa
        IF rw_crapjur.orregemp IS NOT NULL THEN
          vr_obj_generic2.put('orgaoRegistroEmpresa', rw_crapjur.orregemp);
        END IF;

        -- Data Inscrição Municipal
        IF rw_crapjur.dtinsnum IS NOT NULL THEN
          vr_obj_generic2.put('dataInscricMunicipal',este0002.fn_Data_ibra_motor(rw_crapjur.dtinsnum));
        END IF;

        -- Numero Inscrição Municipal
        IF rw_crapjur.nrinsmun <> 0 THEN
          vr_obj_generic2.put('numeroInscricMunicipal',rw_crapjur.nrinsmun);
        END IF;

        -- Numero Inscrição Estadual
        IF rw_crapjur.nrinsest <> 0 THEN
          vr_obj_generic2.put('numeroInscricEstadual', rw_crapjur.nrinsest);
        END IF;

        -- Participante REFIS
        vr_obj_generic2.put('optanteRefis',(nvl(rw_crapjur.flgrefis,0)=1));

        -- Buscar informações do Faturamento
        OPEN cr_crapjfn;
        FETCH cr_crapjfn
          INTO rw_crapjfn;
        CLOSE cr_crapjfn;

        -- Percentual faturamento cliente único
        IF rw_crapjfn.perfatcl <> 0 THEN
          vr_obj_generic2.put('percentFaturamenMaiorCliente',este0001.fn_decimal_ibra(rw_crapjfn.perfatcl));
        END IF;

        -- Numero Nire
        IF rw_crapjur.nrcdnire <> 0 THEN
          vr_obj_generic2.put('numeroNIRE', rw_crapjur.nrcdnire);
        END IF;

        -- Montar objeto para faturamentos
        vr_lst_generic3 := json_list();

        -- Criar objeto para mês 01
        IF rw_crapjfn.dtfatme1 <> '01000000' THEN
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes',este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme1,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes',este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##1));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;

        IF rw_crapjfn.dtfatme2 <> '01000000' THEN
          -- Criar objeto para mês 02
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes',este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme2,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes',este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##2));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;

        IF rw_crapjfn.dtfatme3 <> '01000000' THEN
          -- Criar objeto para mês 03
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes',este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme3,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes',este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##3));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;

        IF rw_crapjfn.dtfatme4 <> '01000000' THEN
          -- Criar objeto para mês 04
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes',este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme4,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes',este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##4));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;

        IF rw_crapjfn.dtfatme5 <> '01000000' THEN
          -- Criar objeto para mês 05
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes',este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme5,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes',este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##5));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;

        IF rw_crapjfn.dtfatme6 <> '01000000' THEN
          -- Criar objeto para mês 06
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes',este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme6,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes',este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##6));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;

        IF rw_crapjfn.dtfatme7 <> '01000000' THEN
          -- Criar objeto para mês 07
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes',este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme7,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes',este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##7));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;

        IF rw_crapjfn.dtfatme8 <> '01000000' THEN
          -- Criar objeto para mês 08
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes',este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme8,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes',este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##8));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;

        IF rw_crapjfn.dtfatme9 <> '01000000' THEN
          -- Criar objeto para mês 09
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes',este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme9,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes',este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##9));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;

        IF rw_crapjfn.dtfatme10 <> '01000000' THEN
          -- Criar objeto para mês 10
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes',este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme10,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes',este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##10));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;

        IF rw_crapjfn.dtfatme11 <> '01000000' THEN
          -- Criar objeto para mês 11
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes',este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme11,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes',este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##11));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;

        IF rw_crapjfn.dtfatme12 <> '01000000' THEN
          -- Criar objeto para mês 12
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes',este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme12,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes',este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##12));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;

        -- Adicionar o array de faturamentos no objeto informações adicionais
        vr_obj_generic2.put('faturamentoMes', vr_lst_generic3);

        -- Data Atualização Faturamento
        vr_obj_generic2.put('dataAtualizacaoFaturamento',este0002.fn_data_ibra_motor(rw_crapjfn.dtaltjfn##4));

      END IF;

      -- Enviar informações adicionais ao JSON
      vr_obj_generico.put('informacoesAdicionais', vr_obj_generic2);

      -- Ao final copiamos o json montado ao retornado
      pr_dsjsonan := vr_obj_generico;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        IF SQLCODE < 0 THEN
          -- Caso ocorra exception gerar o código do erro com a linha do erro
          vr_dscritic:= vr_dscritic ||
                        dbms_utility.format_error_backtrace;

        END IF;

        -- Montar a mensagem final do erro
        vr_dscritic:= 'Erro na montagem dos dados para análise automática da proposta (1): ' ||
                       vr_dscritic || ' -- SQLERRM: ' || SQLERRM;

        -- Remover as ASPAS que quebram o texto
        vr_dscritic:= replace(vr_dscritic,'"', '');
        vr_dscritic:= replace(vr_dscritic,'''','');
        -- Remover as quebras de linha
        vr_dscritic:= replace(vr_dscritic,chr(10),'');
        vr_dscritic:= replace(vr_dscritic,chr(13),'');

        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;
    END;
  END pc_gera_json_pessoa_ass;

  --> Busca informações de avalista de terceiros para gerar json
  PROCEDURE pc_gera_json_pessoa_avt ( pr_rw_crapavt  IN crapavt%ROWTYPE,        --> Dados do avalista
                                      ---- OUT ----
                                      pr_dsjsonavt OUT NOCOPY json,             --> Retorno do clob em modelo json dos dados do avalista
                                      pr_cdcritic  OUT NUMBER,                  --> Codigo da critica
                                      pr_dscritic  OUT VARCHAR2) IS             --> Descricao da critica
  /* ..........................................................................

      Programa : pc_gera_json_pessoa_avt
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva - Supero
      Data     : Fevereiro/2018.                   Ultima atualizacao: 23/02/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por montar o objeto json contendo
                  os dados do avalista terceiro.

      Alteração :

    ..........................................................................*/
    -----------> CURSORES <-----------
    -- Busca a Nacionalidade
    CURSOR cr_crapnac(pr_cdnacion IN crapnac.cdnacion%TYPE) IS
      SELECT crapnac.dsnacion
        FROM crapnac
       WHERE crapnac.cdnacion = pr_cdnacion;

    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Objeto json
    vr_obj_generico json := json();
    vr_obj_generic2 json := json();
    vr_lst_generic2 json_list := json_list();
    vr_inpessoa     crapass.inpessoa%TYPE;
    vr_stsnrcal     BOOLEAN;
    vr_dsnacion     crapnac.dsnacion%TYPE;

  BEGIN

    -- Validar o CPF/CNPJ para definir se é fisica ou jurídica
    gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_rw_crapavt.nrcpfcgc
                               ,pr_stsnrcal => vr_stsnrcal
                               ,pr_inpessoa => vr_inpessoa);

    -- Enviaremos os dados básicos encontrados na tabela
    IF vr_inpessoa = 1 THEN
      vr_obj_generico.put('documento'      ,gene0002.fn_mask(NVL(pr_rw_crapavt.nrcpfcgc,0),'99999999999'));
    ELSE
      vr_obj_generico.put('documento'      ,gene0002.fn_mask(NVL(pr_rw_crapavt.nrcpfcgc,0),'99999999999999'));
    END IF;

    -- Para Pessoas Fisicas
    IF vr_inpessoa = 1 THEN

      vr_obj_generico.put('tipoPessoa','FISICA');
      vr_obj_generico.put('nome'           ,pr_rw_crapavt.nmdavali);

      IF pr_rw_crapavt.cdsexcto = 1 THEN
        vr_obj_generico.put('sexo' ,'MASCULINO');
      ELSIF pr_rw_crapavt.cdsexcto = 2 THEN
        vr_obj_generico.put('sexo' ,'FEMININO');
      END IF;

      vr_obj_generico.put('dataNascimento' ,este0002.fn_data_ibra_motor(pr_rw_crapavt.dtnascto));

      -- Se o Documento for RG
      IF pr_rw_crapavt.tpdocava = 'CI' THEN
        vr_obj_generico.put('rg'  , pr_rw_crapavt.nrdocava);
        IF TRIM(pr_rw_crapavt.cdufddoc) IS NOT NULL THEN
          vr_obj_generico.put('ufRg', pr_rw_crapavt.cdufddoc);
        END IF;
      END IF;

      IF TRIM(replace(pr_rw_crapavt.nmmaecto,'.','')) IS NOT NULL THEN
        vr_obj_generico.put('nomeMae'      ,pr_rw_crapavt.nmmaecto);
      END IF;

      -- Busca a Nacionalidade
      vr_dsnacion := '';
      OPEN  cr_crapnac(pr_cdnacion => pr_rw_crapavt.cdnacion);
      FETCH cr_crapnac INTO vr_dsnacion;
      CLOSE cr_crapnac;

      vr_obj_generico.put('nacionalidade',vr_dsnacion);

      -- Montar objeto profissao
      IF pr_rw_crapavt.dsproftl <> ' ' THEN
        vr_obj_generic2 := json();
        vr_obj_generic2.put('titulo'   , pr_rw_crapavt.dsproftl);
        vr_obj_generic2.put('profissao', vr_obj_generico);
      END IF;

    ELSE
      vr_obj_generico.put('tipoPessoa'  ,'JURIDICA');
      vr_obj_generico.put('razaoSocial' ,pr_rw_crapavt.nmdavali);
      vr_obj_generico.put('dataFundacao',este0002.fn_data_ibra_motor(pr_rw_crapavt.dtnascto));
    END IF;

    -- Montar objeto Telefone para Telefone Residencial/Comercial
    IF pr_rw_crapavt.nrfonres <> ' ' THEN
      vr_lst_generic2 := json_list();
      -- Criar objeto só para este telefone
      vr_obj_generic2 := json();
      -- Montar Especie conforme tipo de Pessoa
      IF vr_inpessoa = 1 THEN
        vr_obj_generic2.put('especie', 'DOMICILIO');
      ELSE
        vr_obj_generic2.put('especie', 'COMERCIAL');
      END IF;

      vr_obj_generic2.put('numero', este0002.fn_somente_numeros_telefone(pr_rw_crapavt.nrfonres));
      -- Adicionar telefone na lista
      vr_lst_generic2.append(vr_obj_generic2.to_json_value());
      -- Adicionar o array telefone no objeto
      vr_obj_generico.put('telefones', vr_lst_generic2);
    END IF;

    -- Montar objeto Endereco
    IF pr_rw_crapavt.dsendres##1 <> ' ' THEN
      vr_obj_generic2 := json();

      vr_obj_generic2.put('logradouro'  , pr_rw_crapavt.dsendres##1);
      vr_obj_generic2.put('numero'      , pr_rw_crapavt.nrendere);
      vr_obj_generic2.put('complemento' , pr_rw_crapavt.complend);
      vr_obj_generic2.put('bairro'      , pr_rw_crapavt.dsendres##2);
      vr_obj_generic2.put('cidade'      , pr_rw_crapavt.nmcidade);
      vr_obj_generic2.put('uf'          , pr_rw_crapavt.cdufresd);
      vr_obj_generic2.put('cep'         , pr_rw_crapavt.nrcepend);

      vr_obj_generico.put('endereco', vr_obj_generic2);
     END IF;

     -- Montar informações Adicionais
     vr_obj_generic2 := json();

     -- Caixa Postal
     IF pr_rw_crapavt.nrcxapst <> 0 THEN
       vr_obj_generic2.put('caixaPostal', pr_rw_crapavt.nrcxapst);
     END IF;

     -- Somente para Pessoa Fisica
     IF vr_inpessoa = 1 THEN

       -- Nome Pai
       IF pr_rw_crapavt.nmpaicto NOT IN(' ','.') THEN
         vr_obj_generic2.put('nomePai', pr_rw_crapavt.nmpaicto);
       END IF;

       -- Estado Civil
       IF pr_rw_crapavt.cdestcvl <> 0 THEN
         vr_obj_generic2.put('estadoCivil', pr_rw_crapavt.cdestcvl);
       END IF;

       -- Email
       vr_obj_generic2.put('email', pr_rw_crapavt.dsdemail);

       -- Naturalidade
       IF pr_rw_crapavt.dsnatura <> ' ' THEN
         vr_obj_generic2.put('naturalidade', pr_rw_crapavt.dsnatura);
       END IF;

       -- Salario
       IF pr_rw_crapavt.vlrenmes <> 0 THEN
         vr_obj_generic2.put('valorSalario', este0001.fn_decimal_ibra(pr_rw_crapavt.vlrenmes));
       END IF;

       -- Outros Rendimentos
       IF pr_rw_crapavt. vloutren <> 0 THEN
         vr_obj_generic2.put('valorOutrosRendim', este0001.fn_decimal_ibra(pr_rw_crapavt.vloutren));
       END IF;

       -- Habilitação Menor
       IF pr_rw_crapavt.inhabmen > 0 THEN
         vr_obj_generic2.put('reponsabiLegal', pr_rw_crapavt.inhabmen);

         -- Data Emancipação
         IF pr_rw_crapavt.dthabmen IS NOT NULL THEN
           vr_obj_generic2.put('dataEmancipa' ,este0002.fn_Data_ibra_motor(pr_rw_crapavt.dthabmen));
         END IF;
       END IF;

       -- Data de Admissão Procuração
       IF pr_rw_crapavt.dtadmsoc IS NOT NULL THEN
         vr_obj_generic2.put('dataAdmissaoProcuracao' ,este0002.fn_Data_ibra_motor(pr_rw_crapavt.dtadmsoc));
       END IF;

       -- Percentual Procuração
       IF pr_rw_crapavt.persocio > 0 THEN
         vr_obj_generic2.put('valorPercentualProcuracao' ,Este0001.fn_Decimal_Ibra(pr_rw_crapavt.persocio));
       END IF;

       -- Data de Vigência Procuração
       IF pr_rw_crapavt.dtvalida IS NOT NULL THEN
         vr_obj_generic2.put('dataVigenciaProcuracao' ,este0002.fn_Data_ibra_motor(pr_rw_crapavt.dtvalida));
       END IF;

     ELSE
       -- Faturamento Annual – Rendimento MÊs + Outros * 12
       IF pr_rw_crapavt.vlrenmes + pr_rw_crapavt. vloutren <> 0 THEN
         vr_obj_generic2.put('valorFaturamentoAnual', este0001.fn_decimal_ibra((pr_rw_crapavt.vlrenmes + pr_rw_crapavt.vloutren)*12));
       END IF;

     END IF;

     -- Enviar informações adicionais ao JSON
     vr_obj_generico.put('informacoesAdicionais' ,vr_obj_generic2);

     -- Ao final copiamos o json montado ao retornado
     pr_dsjsonavt := vr_obj_generico;


  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao montar dados json avalista: '||SQLERRM;
  END pc_gera_json_pessoa_avt;

  --> Rotina responsavel por montar o objeto json para analise
  PROCEDURE pc_gera_json_motor(pr_cdcooper   IN crapass.cdcooper%TYPE   --> Codigo da cooperativa
                              ,pr_cdagenci   IN crapass.cdagenci%TYPE   --> Codigo da agência
                              ,pr_nrdconta   IN crapass.nrdconta%TYPE   --> Número da conta
                              ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE   --> Número da proposta do cartão
                              ,pr_tpproces   IN VARCHAR2                --> Tipo Processo (I-Inclusão, A-Alteração)
                              ,pr_cdoperad   IN crapope.cdoperad%TYPE
                              ---- OUT ----
                              ,pr_dsjsonan  OUT NOCOPY json             --> Retorno do clob em modelo json com os dados para analise
                              ,pr_cdcritic  OUT NUMBER                  --> Codigo da critica
                              ,pr_dscritic  OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................

      Programa : pc_gera_json_motor
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva - Supero
      Data     : Fevereiro/2018.                   Ultima atualizacao: 23/02/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por montar o objeto json para analise.

      Alteração :
                  05/06/2019 - P450 - Adicionada a variavel BiroScore no JSON de envio 
                               a Ibratan (Heckmann - AMcom)

                  05/08/2019 - P438 - Inclusão do atributo canalOrigem no Json para identificar 
                               a origem da operação de crédito no Motor. (Douglas Pagel / AMcom).

                  14/08/2019 - P450 - Inclusão do modeloRating na pc_gera_json_motor para informar o tipo de calculo que
                               Ibratan deve calcular e retornar do Rating definido na PARRAT
                               Luiz Otavio Olinger Momm - AMCOM

    ..........................................................................*/
    -----------> CURSORES <-----------
    -- Buscar quantidade de dias de reaproveitamento
    CURSOR cr_craprbi IS
      SELECT rbi.qtdiarpv
        FROM craprbi rbi
            ,crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND rbi.cdcooper = pr_cdcooper
         AND rbi.inpessoa = ass.inpessoa
         AND rbi.inprodut = 8;--Cartão de Crédito
    rw_craprbi cr_craprbi%ROWTYPE;

    -- Buscar PA do operador de envio da proposta
    CURSOR cr_crapope IS
      SELECT ope.cdpactra
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    vr_cdpactra crapope.cdpactra%TYPE;

    -- Buscar última data de consulta ao bacen
    CURSOR cr_crapopf IS
      SELECT max(opf.dtrefere) dtrefere
        FROM crapopf opf;
    rw_crapopf cr_crapopf%ROWTYPE;

    -- Buscar os dados do associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
            ,ass.nrcpfcgc
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Buscar dados titular
    CURSOR cr_crapttl(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ttl.dtnasttl
            ,ttl.inhabmen
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1;
    rw_crapttl cr_crapttl%rowtype;

    -- Buscar avalistas terceiros
    CURSOR cr_crapavt(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nrctrcrd crapavt.nrctremp%TYPE,
                      pr_tpctrato crapavt.tpctrato%TYPE,
                      pr_dsproftl crapavt.dsproftl%TYPE) IS
      SELECT crapavt.* --> necessario ser todos os campos pois envia como parametro
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.nrctremp = pr_nrctrcrd
         AND crapavt.tpctrato = pr_tpctrato
         AND (   pr_dsproftl IS NULL
               OR ( pr_dsproftl = 'SOCIO' AND dsproftl IN('SOCIO/PROPRIETARIO'
                                                         ,'SOCIO ADMINISTRADOR'
                                                         ,'DIRETOR/ADMINISTRADOR'
                                                         ,'SINDICO'
                                                         ,'ADMINISTRADOR'))
               OR ( pr_dsproftl = 'PROCURADOR' AND dsproftl LIKE UPPER('%PROCURADOR%'))
              );
    rw_crapavt cr_crapavt%ROWTYPE;

    --> Buscar cadastro do Conjuge:
    CURSOR cr_crapcje (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapcje.nrctacje
            ,crapcje.nmconjug
            ,crapcje.nrcpfcjg
            ,crapcje.dtnasccj
            ,crapcje.tpdoccje
            ,crapcje.nrdoccje
            ,crapcje.grescola
            ,crapcje.cdfrmttl
            ,crapcje.cdnatopc
            ,crapcje.cdocpcje
            ,crapcje.tpcttrab
            ,crapcje.dsproftl
            ,crapcje.cdnvlcgo
            ,crapcje.nrfonemp
            ,crapcje.nrramemp
            ,crapcje.cdturnos
            ,crapcje.dtadmemp
            ,crapcje.vlsalari
            ,crapcje.nrdocnpj
            ,crapcje.cdufdcje
       FROM crapcje
      WHERE crapcje.cdcooper = pr_cdcooper
        AND crapcje.nrdconta = pr_nrdconta
        AND crapcje.idseqttl = 1;
    rw_crapcje cr_crapcje%ROWTYPE;

    --> Buscar representante legal
    CURSOR cr_crapcrl (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapcrl.cdcooper
            ,crapcrl.nrctamen
            ,crapcrl.idseqmen
            ,crapcrl.nrdconta
            ,crapcrl.nrcpfcgc
            ,crapcrl.nmrespon
            ,org.cdorgao_expedidor dsorgemi
            ,crapcrl.cdufiden
            ,crapcrl.dtemiden
            ,crapcrl.dtnascin
            ,crapcrl.cddosexo
            ,crapcrl.cdestciv
            ,crapnac.dsnacion
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
            ,crapcrl.tpdeiden
            ,crapcrl.nridenti
            ,crapcrl.cdrlcrsp
        FROM crapcrl,
             crapnac,
             tbgen_orgao_expedidor org
       WHERE crapcrl.cdcooper = pr_cdcooper
         AND crapcrl.nrctamen = pr_nrdconta
         AND crapcrl.cdnacion = crapnac.cdnacion(+)
         AND crapcrl.idorgexp = org.idorgao_expedidor(+);

    -- Declarar cursor de participações societárias
    CURSOR cr_crapepa (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT cdcooper,
             nrdconta,
             nrdocsoc,
             nrctasoc,
             nmfansia,
             nrinsest,
             natjurid,
             dtiniatv,
             qtfilial,
             qtfuncio,
             dsendweb,
             cdseteco,
             cdmodali,
             cdrmativ,
             vledvmto,
             dtadmiss,
             dtmvtolt,
             persocio,
             nmprimtl
        FROM crapepa
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;

    -- Buscar descrição
    CURSOR cr_nature (pr_natjurid gncdntj.cdnatjur%TYPE) IS
      SELECT gncdntj.dsnatjur
        FROM gncdntj
       WHERE gncdntj.cdnatjur = pr_natjurid;
    rw_nature cr_nature%ROWTYPE;

    -- Buscar descrição
    CURSOR cr_gnrativ ( pr_cdseteco gnrativ.cdseteco%TYPE,
                        pr_cdrmativ gnrativ.cdrmativ%TYPE)IS
      SELECT gnrativ.nmrmativ
        FROM gnrativ
       WHERE gnrativ.cdseteco = pr_cdseteco
         AND gnrativ.cdrmativ = pr_cdrmativ;
    rw_gnrativ cr_gnrativ%ROWTYPE;


    -- Buscar os bens em garanita na Proposta
    CURSOR cr_crapbpr (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_nrctrcrd crapbpr.nrctrpro%TYPE ) IS
      SELECT crapbpr.dscatbem
            ,crapbpr.vlmerbem
            ,greatest(crapbpr.nranobem,crapbpr.nrmodbem) nranobem
            ,crapbpr.nrcpfbem
        FROM crapbpr
       WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.nrctrpro = pr_nrctrcrd
         AND crapbpr.tpctrpro = 90
         AND trim(crapbpr.dscatbem) is not NULL;

    --> Buscar se a conta é de Colaborador Cecred
    CURSOR cr_tbcolab(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS

      SELECT substr(lpad(col.cddcargo_vetor,7,'0'),5,3) cddcargo
        FROM tbcadast_colaborador col
       WHERE col.cdcooper = pr_cdcooper
         AND col.nrcpfcgc = pr_nrcpfcgc
         AND col.flgativo = 'A';

    CURSOR cr_crapprp IS
      SELECT prp.flgdocje
        FROM crapprp prp
       WHERE prp.cdcooper = pr_cdcooper
         AND prp.nrdconta = pr_nrdconta
         AND prp.nrctrato = pr_nrctrcrd
         AND prp.tpctrato = 90;
    rw_crapprp cr_crapprp%ROWTYPE;

    --Busca categorias de cartão
    CURSOR cr_catcrd(pr_tpctahab crapadc.tpctahab%TYPE
                    ,pr_tplimcrd tbcrd_config_categoria.tplimcrd%TYPE) IS
      SELECT tcc.cdadmcrd
            ,adc.nmadmcrd
            ,tcc.vllimite_minimo
            ,tcc.vllimite_maximo
        FROM crapadc adc
            ,tbcrd_config_categoria tcc
       WHERE tcc.cdcooper = pr_cdcooper
         AND tcc.tplimcrd = pr_tplimcrd
         AND adc.cdcooper = tcc.cdcooper
         AND adc.cdadmcrd = tcc.cdadmcrd
         AND adc.tpctahab = pr_tpctahab
         AND adc.insitadc = 0 --Normal
       ORDER BY tcc.cdadmcrd;
    rw_catcrd cr_catcrd%ROWTYPE;

    -- Busca a proposta original - caso alteracao de limite
    CURSOR cr_crawcrd (pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_nrdconta crapass.nrdconta%TYPE
                      ,pr_nrctrcrd crapcrd.nrctrcrd%TYPE) IS
     SELECT crd.nrcctitg -- conta cartao
           ,crd.vllimcrd -- limite atual
           ,crd.cdadmcrd -- cod adminstradora atual
           ,adc.nmadmcrd -- nome adminstradora tual
           ,crd.cdoperad
       FROM crawcrd crd
  LEFT JOIN crapadc adc
         ON adc.cdcooper = crd.cdcooper
        AND adc.cdadmcrd = crd.cdadmcrd
      WHERE crd.cdcooper = pr_cdcooper
        AND crd.nrdconta = pr_nrdconta
        AND crd.nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE;

    --Busca Patrimonio referencial da cooperativa
    CURSOR cr_tbcadast_cooperativa(pr_cdcooper INTEGER) IS
      SELECT vlpatrimonio_referencial
        FROM tbcadast_cooperativa
       WHERE cdcooper = pr_cdcooper;
    rw_tbcadast_cooperativa cr_tbcadast_cooperativa%ROWTYPE;

    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(500);
    vr_exc_erro EXCEPTION;

    -- Objeto json
    vr_obj_analise   json      := json();
    vr_obj_conjuge   json      := json();
    vr_obj_avalista  json      := json();
    vr_obj_responsav json      := json();
    vr_obj_socio     json      := json();
    vr_obj_particip  json      := json();
    vr_obj_procurad  json      := json();
    vr_obj_generico  json      := json();
    vr_obj_generic2  json      := json();
    vr_obj_generic3  json      := json();
    vr_lst_generico  json_list := json_list();
    vr_lst_generic2  json_list := json_list();
    vr_lst_generic3  json_list := json_list();

    vr_flavalis      BOOLEAN := FALSE;
    vr_flrespvl      BOOLEAN := FALSE;
    vr_flsocios      BOOLEAN := FALSE;
    vr_flpartic      BOOLEAN := FALSE;
    vr_flprocura     BOOLEAN := FALSE;
    vr_flgbens       BOOLEAN := FALSE;
    vr_nrdeanos      INTEGER;
    vr_nrdmeses      INTEGER;
    vr_dsdidade      VARCHAR2(100);
    vr_dstextab      craptab.dstextab%TYPE;
    vr_nmseteco      craptab.dstextab%TYPE;
    vr_flgcolab      BOOLEAN;
    vr_cddcargo      tbcadast_colaborador.cdcooper%TYPE;
    vr_qtdiarpv      INTEGER;
    vr_tplimcrd      NUMBER(1) := 0; -- 0-concessao, 1-alteracao
    vr_tpprodut      NUMBER(1) := 4; -- tipo produto

    vr_vlpatref      tbcadast_cooperativa.vlpatrimonio_referencial%TYPE;
    
    vr_cdorigem      NUMBER := 0;

  BEGIN

    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    /* O campo pr_nrctrcrd virá nulo no caso de Solicitação de Cartão.
       Só virá preenchido se for alteração de limite. */
    IF pr_tpproces = 'A' THEN
      vr_obj_analise.put('proposta', gene0002.fn_mask_contrato(pr_nrctrcrd));
    ELSE
      vr_obj_analise.put('proposta', gene0002.fn_mask_contrato(null));
    END IF;

    -- Buscar quantidade de dias de reaproveitamento
    OPEN cr_craprbi;
    FETCH cr_craprbi INTO rw_craprbi;

    -- Se encontrou
    IF cr_craprbi%FOUND THEN
      -- Buscar a coluna e multiplicar por 24 para chegarmos na quantidade de horas de reaproveitamento
      vr_qtdiarpv := rw_craprbi.qtdiarpv * 24;
    ELSE
      -- Se não encontrar consideramos 168 horas (7 dias)
      vr_qtdiarpv := 168;
    END IF;
    CLOSE cr_craprbi;

    -- Buscar PA do operador
    OPEN cr_crapope;
    FETCH cr_crapope INTO vr_cdpactra;
    CLOSE cr_crapope;

    OPEN cr_crapopf;
    FETCH cr_crapopf INTO rw_crapopf;
    IF cr_crapopf%NOTFOUND THEN
      CLOSE cr_crapopf;
      vr_dscritic := 'Data Base Bacen-SCR nao encontrada!';
      RAISE vr_exc_erro;
    ELSE
    CLOSE cr_crapopf;
    END IF;

    -- Montar os atributos de 'configuracoes'
    vr_obj_generico := json();
    vr_obj_generico.put('centroCusto', vr_cdpactra);
    vr_obj_generico.put('dataBaseBacen', to_char(rw_crapopf.dtrefere,'RRRRMM'));
    vr_obj_generico.put('horasReaproveitamento', vr_qtdiarpv);

    -- Adicionar o array configuracoes
    vr_obj_analise.put('configuracoes', vr_obj_generico);

    --> indicadoresCliente
    vr_obj_generico := json();

    vr_obj_generico.put('cooperativa', pr_cdcooper);
    vr_obj_generico.put('agenci', pr_cdagenci);

    /* 0 – CDC Diversos
       1 – CDC Veículos
       2 – Empréstimos /Financiamentos
       3 – Desconto Cheques
       4 – Desconto Títulos
       5 – Cartão de Crédito
       6 – Limite de Crédito) */

    vr_obj_generico.put('segmentoCodigo'    ,5);
    vr_obj_generico.put('segmentoDescricao' ,'Cartão de Crédito');

    IF pr_tpproces = 'I' THEN --Inclusão
      vr_obj_generico.put('tipoProduto','LM');
    ELSE --Alteração
      OPEN cr_crawcrd (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctrcrd => pr_nrctrcrd);
      FETCH cr_crawcrd INTO rw_crawcrd;
      CLOSE cr_crawcrd;

      --Para limites com 0 deve ir a política de concessão
      IF nvl(rw_crawcrd.vllimcrd,0) = 0 THEN
        vr_obj_generico.put('tipoProduto','LM');
      ELSE
      vr_obj_generico.put('tipoProduto','MJ');
    END IF;
    END IF;

    --Campos usados somente em Empréstimo, irão com valor em branco.
    -- Ajustes Anderson
    vr_obj_generico.put('valorEmprest',0);
    vr_obj_generico.put('valorParcela',0);
    vr_obj_generico.put('quantParcela',0);
    vr_obj_generico.put('primeiroVencto','');
    vr_obj_generico.put('finalidadeCodigo',0);
    vr_obj_generico.put('finalidadeDescricao','');
    vr_obj_generico.put('linhaCreditoCodigo',0);
    vr_obj_generico.put('linhaCreditoDescric','');
    vr_obj_generico.put('qualificaOperacaoCodigo',0);
    vr_obj_generico.put('qualificaOperacaoDescricao','');
    --Fim campos somente de Empréstimo

    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;

    IF rw_crapass.inpessoa = 1 THEN

      OPEN cr_crapprp;
      FETCH cr_crapprp INTO rw_crapprp;
      CLOSE cr_crapprp;

      vr_obj_generico.put('conjugeCoResponv',nvl(rw_crapprp.flgdocje,0)=1);

      -- Verificar se a conta é de colaborador do sistema Cecred
      vr_cddcargo := NULL;

      OPEN cr_tbcolab(pr_cdcooper => pr_cdcooper
                     ,pr_nrcpfcgc => rw_crapass.nrcpfcgc);
      FETCH cr_tbcolab INTO vr_cddcargo;

      IF cr_tbcolab%FOUND THEN
        vr_flgcolab := TRUE;
      ELSE
        vr_flgcolab := FALSE;
      END IF;
      CLOSE cr_tbcolab;

      vr_obj_generico.put('cooperadoColaborador',vr_flgcolab);

    END IF;

    --Campos usados somente em Empréstimo, irão com valor em branco.
    vr_obj_generico.put('operacao','');
    vr_obj_generico.put('renegociacao',FALSE);
    vr_obj_generico.put('tipoGarantiaCodigo','');
    vr_obj_generico.put('tipoGarantiaDescricao','');
    vr_obj_generico.put('debitoEm','');
    vr_obj_generico.put('valorTaxaMensal','');
    vr_obj_generico.put('liquidacao','');
    vr_obj_generico.put('valorPrestLiquidacao','');
    --Fim campos somente de Empréstimo

    -- Efetuar laço para trazer todos os registros
    FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrctrcrd => pr_nrctrcrd )  LOOP

      -- Indicar que encontrou
      vr_flgbens := TRUE;
      -- Para cada registro de Bem, criar objeto para a operação e enviar suas informações
      vr_lst_generic2 := json_list();
      vr_obj_generic2 := json();
      vr_obj_generic2.put('categoriaBem',     rw_crapbpr.dscatbem);
      vr_obj_generic2.put('valorGarantia',    este0001.fn_decimal_ibra(rw_crapbpr.vlmerbem));
      vr_obj_generic2.put('anoGarantia',      rw_crapbpr.nranobem);
      vr_obj_generic2.put('bemInterveniente', rw_crapbpr.nrcpfbem <> 0);

      -- Adicionar Bem na lista
      vr_lst_generic2.append(vr_obj_generic2.to_json_value());

    END LOOP; -- Final da leitura dos Bens

    -- Adicionar o array bemEmGarantia
    IF vr_flgbens THEN
      vr_obj_generico.put('bemEmGarantia', vr_lst_generic2);
    END IF;

    vr_obj_generico.put('BiroScore',rati0003.fn_tipo_biro(pr_cdcooper => pr_cdcooper));

    -- Se for I - Inclusao (ou seja, solicitacao de cartao) enviaremos em branco.
    IF pr_tpproces = 'I' THEN
      vr_obj_generico.put('limiteAtualCartaoCecred',0);
      vr_obj_generico.put('codigoCatAtualCartaoCecred',0);
      vr_obj_generico.put('descricaoCatAtualCartaoCecred','');
      vr_obj_generico.put('contaCartao',0);
      vr_tplimcrd := 0; -- concessao
    ELSE
      -- Se for A - Alteracao (ou seja, alteracao de limite) enviaremos os dados.
      OPEN cr_crawcrd (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctrcrd => pr_nrctrcrd);
      FETCH cr_crawcrd INTO rw_crawcrd;
      IF cr_crawcrd%FOUND THEN
        vr_obj_generico.put('limiteAtualCartaoCecred',este0001.fn_decimal_ibra(rw_crawcrd.vllimcrd));
        vr_obj_generico.put('codigoCatAtualCartaoCecred',rw_crawcrd.cdadmcrd);
        vr_obj_generico.put('descricaoCatAtualCartaoCecred',rw_crawcrd.nmadmcrd);
        vr_obj_generico.put('contaCartao',rw_crawcrd.nrcctitg);
      ELSE
        vr_obj_generico.put('limiteAtualCartaoCecred',0);
        vr_obj_generico.put('codigoCatAtualCartaoCecred',0);
        vr_obj_generico.put('descricaoCatAtualCartaoCecred','');
        vr_obj_generico.put('contaCartao',0);
      END IF;
      vr_tplimcrd := 1; -- alteracao
      CLOSE cr_crawcrd;
    END IF;

    -- Montar objeto Categoria Cartão Cecred
    vr_lst_generic3 := json_list();

    -- Buscar todos os dados do SPC
    -- Efetuar laço para trazer todos os registros
    FOR rw_catcrd IN cr_catcrd(pr_tpctahab => rw_crapass.inpessoa
                              ,pr_tplimcrd => vr_tplimcrd) LOOP

      -- Criar objeto para a operação e enviar suas informações
      vr_obj_generic3 := json();
      vr_obj_generic3.put('codigo',rw_catcrd.cdadmcrd);
      vr_obj_generic3.put('descricao',rw_catcrd.nmadmcrd);
      vr_obj_generic3.put('vlLimiteMinimo',este0001.fn_decimal_ibra(rw_catcrd.vllimite_minimo));
      vr_obj_generic3.put('vlLimiteMaximo',este0001.fn_decimal_ibra(rw_catcrd.vllimite_maximo));

      -- Adicionar Operação na lista
      vr_lst_generic3.append(vr_obj_generic3.to_json_value());

    END LOOP; -- Final da leitura das categorias

    -- Adicionar o array seguro no objeto informações adicionais
    vr_obj_generico.put('categoriasCartaoCecred', vr_lst_generic3);

    -- Buscar Patrimonio referencial da cooperativa
    OPEN cr_tbcadast_cooperativa(pr_cdcooper);
    FETCH cr_tbcadast_cooperativa INTO vr_vlpatref;

    IF cr_tbcadast_cooperativa%NOTFOUND THEN
      vr_vlpatref := 0;
    END IF;
    CLOSE cr_tbcadast_cooperativa;
    -- Incluir Patrimonio referencial da cooperativa
    vr_obj_generico.put('valorPatrimonioReferencial',ESTE0001.fn_decimal_ibra(vr_vlpatref));

    vr_cdorigem := CASE WHEN rw_crawcrd.cdoperad = '996' THEN 3 ELSE 5 END;
    
    vr_obj_generico.put('canalOrigem',vr_cdorigem);

    /* P450 - Rating modelo calculo */
    vr_obj_generico.put('modeloRating', RATI0003.fn_retorna_modelo_rating(pr_cdcooper));

    vr_obj_analise.put('indicadoresCliente', vr_obj_generico);

    este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctremp => NULL
                                    ,pr_dsjsonan => vr_obj_generico
                                    ,pr_tpprodut => vr_tpprodut
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

     -- Testar possíveis erros na rotina:
     IF nvl(vr_cdcritic,0) <> 0 OR
        trim(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

    -- Adicionar o JSON montado do Proponente no objeto principal
    vr_obj_analise.put('proponente',vr_obj_generico);

    --> Para Pessoa Fisica iremos buscar seu Conjuge
    IF rw_crapass.inpessoa = 1 THEN

      --> Buscar cadastro do Conjuge
      rw_crapcje := NULL;

      OPEN cr_crapcje( pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapcje INTO rw_crapcje;

      -- Se não encontrar
      IF cr_crapcje%NOTFOUND THEN
        -- apenas fechamos o cursor
        CLOSE cr_crapcje;
      ELSE
        -- Fechar o cursor e enviar
        CLOSE cr_crapcje;
        --> Se Conjuge for associado:
        IF rw_crapcje.nrctacje <> 0 THEN

          -- Passaremos a conta para montagem dos dados:
          este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapcje.nrctacje
                                 ,pr_nrctremp => NULL
                                 ,pr_vlsalari => rw_crapcje.vlsalari
                                 ,pr_dsjsonan => vr_obj_conjuge
                                 ,pr_tpprodut => vr_tpprodut
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Adicionar o JSON montado do Proponente no objeto principal
          vr_obj_analise.put('conjuge',vr_obj_conjuge);

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de conjugue
          vr_obj_conjuge.put('documento',gene0002.fn_mask(NVL(rw_crapcje.nrcpfcjg,0),'99999999999'));
          vr_obj_conjuge.put('tipoPessoa','FISICA');
          vr_obj_conjuge.put('nome',rw_crapcje.nmconjug);
          vr_obj_conjuge.put('dataNascimento',este0002.fn_Data_ibra_motor(rw_crapcje.dtnasccj));

          -- Se o Documento for RG
          IF rw_crapcje.tpdoccje = 'CI' THEN
            vr_obj_conjuge.put('rg', rw_crapcje.nrdoccje);
            vr_obj_conjuge.put('ufRg', rw_crapcje.cdufdcje);
          END IF;

          -- Montar objeto Telefone para Telefone Comercial
          IF rw_crapcje.nrfonemp <> ' ' THEN
            vr_lst_generic2 := json_list();
            -- Criar objeto só para este telefone
            vr_obj_generico := json();
            vr_obj_generico.put('especie', 'COMERCIAL');
            vr_obj_generico.put('numero', este0002.fn_somente_numeros_telefone(rw_crapcje.nrfonemp));
            -- Adicionar telefone na lista
            vr_lst_generic2.append(vr_obj_generico.to_json_value());
            -- Adicionar o array telefone no objeto Conjuge
            vr_obj_conjuge.put('telefones', vr_lst_generic2);

          END IF;

          -- Montar objeto profissao
          IF rw_crapcje.dsproftl <> ' ' THEN
            vr_obj_generico := json();
            vr_obj_generico.put('titulo'   , rw_crapcje.dsproftl);
            vr_obj_conjuge.put ('profissao', vr_obj_generico);
          END IF;

          -- Montar informações Adicionais
          vr_obj_generico := json();

          -- Escolaridade
          IF rw_crapcje.grescola <> 0 THEN
            vr_obj_generico.put('escolaridade', rw_crapcje.grescola);
          END IF;

          -- Curso Superior
          IF rw_crapcje.cdfrmttl <> 0 THEN
            vr_obj_generico.put('cursoSuperiorCodigo',rw_crapcje.cdfrmttl);
            vr_obj_generico.put('cursoSuperiorDescricao',este0002.fn_des_cdfrmttl(rw_crapcje.cdfrmttl));
          END IF;

          -- Natureza Ocupação
          IF rw_crapcje.cdnatopc <> 0 THEN
            vr_obj_generico.put('naturezaOcupacao', rw_crapcje.cdnatopc);
          END IF;

          -- Ocupação
          IF rw_crapcje.cdocpcje <> 0 THEN
            vr_obj_generico.put('ocupacaoCodigo',rw_crapcje.cdocpcje);
            vr_obj_generico.put('ocupacaoDescricao',este0002.fn_des_cdocupa(rw_crapcje.cdocpcje));
          END IF;

          -- Tipo Contrato de Trabalho
          IF rw_crapcje.tpcttrab <> 0 THEN
            vr_obj_generico.put('tipoContratoTrabalho', rw_crapcje.tpcttrab);
          END IF;

          -- CNPJ Empresa
          IF rw_crapcje.nrdocnpj <> 0 THEN
            vr_obj_generico.put('codCNPJEmpresa', rw_crapcje.nrdocnpj);
          END IF;

          -- Nivel Cargo
          IF rw_crapcje.cdnvlcgo <> 0 THEN
            vr_obj_generico.put('nivelCargo', rw_crapcje.cdnvlcgo);
          END IF;

          -- Turno
          IF rw_crapcje.cdturnos <> 0 THEN
            vr_obj_generico.put('turno', rw_crapcje.cdturnos);
          END IF;

          -- Data Admissão
          IF rw_crapcje.dtadmemp IS NOT NULL THEN
            vr_obj_generico.put('dataAdmissao', este0002.fn_Data_ibra_motor(rw_crapcje.dtadmemp));
          END IF;

          -- Salario
          IF rw_crapcje.vlsalari <> 0 THEN
            vr_obj_generico.put('valorSalario', ESTE0001.fn_decimal_ibra(rw_crapcje.vlsalari));
          END IF;

          -- Enviar informações adicionais ao JSON Conjuge
          vr_obj_conjuge.put('informacoesAdicionais' ,vr_obj_generico);

          -- Ao final adicionamos o json montado ao principal
          vr_obj_analise.put('conjuge' ,vr_obj_conjuge);
        END IF;

      END IF;

    END IF;

    --> BUSCAR AVALISTAS INTERNOS E EXTERNOS:
    -- Inicializar lista de Avalistas
    vr_lst_generico := json_list();

    --> Efetuar laço para retornar todos os registros disponíveis:
    FOR rw_crapavt IN cr_crapavt( pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctrcrd => pr_nrctrcrd
                                 ,pr_tpctrato => 4 --Cartáo
                                 ,pr_dsproftl => null) LOOP

      -- Setar flag para indicar que há avalista
      vr_flavalis := true;

      -- Enviaremos os dados básicos encontrados na tabela de avalistas terceiros
      pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                             ,pr_dsjsonavt  => vr_obj_avalista
                             ,pr_cdcritic   => vr_cdcritic
                             ,pr_dscritic   => vr_dscritic);
      -- Testar possíveis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());

    END LOOP; --> crapavt

    -- Enviar novo objeto de avalistas para dentro do objeto principal (Se houve encontro)
    IF vr_flavalis = true THEN
      vr_obj_analise.put('avalistas' , vr_lst_generico);
    END IF;

    --> Para pessoa física verificaremos necessidade de envio dos responsáveis legais:
    IF rw_crapass.inpessoa = 1 THEN

       -- Buscar dados titular
       OPEN cr_crapttl(pr_cdcooper,pr_nrdconta);
       FETCH cr_crapttl
        INTO rw_crapttl;
       CLOSE cr_crapttl;

       -- Inicializar idade
       vr_nrdeanos := 18;
       -- Se menor de idade
       IF rw_crapttl.inhabmen = 0  THEN
         -- Verifica a idade
         cada0001.pc_busca_idade(pr_dtnasctl => rw_crapttl.dtnasttl
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_nrdeanos => vr_nrdeanos
                                ,pr_nrdmeses => vr_nrdmeses
                                ,pr_dsdidade => vr_dsdidade
                                ,pr_des_erro => vr_dscritic);

         -- Verficia se ocorreram erros
         IF vr_dscritic IS NOT NULL THEN
           vr_nrdeanos := 18;
         END IF;
       END IF;

      -- Se menor de idade ou incapaz
      IF vr_nrdeanos < 18 OR rw_crapttl.inhabmen = 2 THEN

        -- Inicializar lista de Representantes
        vr_lst_generico := json_list();

        --> Efetuar laço para retornar todos os registros disponíveis
        FOR rw_crapcrl IN cr_crapcrl ( pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta ) LOOP
          -- Setar flag para indicar que há responsaveis
          vr_flrespvl := true;

          --> Se Responsável for associado
          IF rw_crapcrl.nrdconta <> 0 THEN
            -- Passaremos a conta para montagem dos dados:
            este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapcrl.nrdconta
                                   ,pr_nrctremp => NULL
                                   ,pr_dsjsonan => vr_obj_responsav
                                   ,pr_tpprodut => vr_tpprodut
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
            -- Testar possíveis erros na rotina:
            IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

            -- Adicionar o avalista montato na lista de avalistas
            vr_lst_generico.append(vr_obj_responsav.to_json_value());

         ELSE
           -- Enviaremos os dados básicos encontrados na tabela de responsável legal
           vr_obj_responsav.put('documento'      ,gene0002.fn_mask(NVL(rw_crapcrl.nrcpfcgc,0),'99999999999'));
           vr_obj_responsav.put('tipoPessoa'     ,'FISICA');
           vr_obj_responsav.put('nome'           ,rw_crapcrl.nmrespon);

           IF rw_crapcrl.cddosexo = 1 THEN
             vr_obj_responsav.put('sexo','MASCULINO');
           ELSE
             vr_obj_responsav.put('sexo','FEMININO');
           END IF;

           IF rw_crapcrl.dtnascin IS NOT NULL THEN
             vr_obj_responsav.put('dataNascimento' ,este0002.fn_data_ibra_motor(rw_crapcrl.dtnascin));
           END IF;

           IF rw_crapcrl.nmmaersp IS NOT NULL THEN
             vr_obj_responsav.put('nomeMae' ,rw_crapcrl.nmmaersp);
           END IF;

           vr_obj_responsav.put('nacionalidade'  ,rw_crapcrl.dsnacion);

           -- Se o Documento for RG
           IF rw_crapcrl.tpdeiden = 'CI' THEN
             vr_obj_responsav.put('rg', rw_crapcrl.nridenti);
             vr_obj_responsav.put('ufRg', rw_crapcrl.cdufiden);
           END IF;

           -- Montar objeto Endereco
           IF rw_crapcrl.dsendres <> ' ' THEN
             vr_obj_generico := json();

             vr_obj_generico.put('logradouro'  , rw_crapcrl.dsendres);
             vr_obj_generico.put('numero'      , rw_crapcrl.nrendres);
             vr_obj_generico.put('complemento' , rw_crapcrl.dscomres);
             vr_obj_generico.put('bairro'      , rw_crapcrl.dsbaires);
             vr_obj_generico.put('cidade'      , rw_crapcrl.dscidres);
             vr_obj_generico.put('uf'          , rw_crapcrl.dsdufres);
             vr_obj_generico.put('cep'         , rw_crapcrl.cdcepres);

             vr_obj_responsav.put('endereco', vr_obj_generico);
           END IF;

           -- Montar informações Adicionais
           vr_obj_generico := json();

           -- Nome Pai
           IF rw_crapcrl.nmpairsp <> ' ' THEN
             vr_obj_generico.put('nomePai', rw_crapcrl.nmpairsp);
           END IF;
           -- Estado Civil
           IF rw_crapcrl.cdestciv <> 0 THEN
             vr_obj_generico.put('estadoCivil', rw_crapcrl.cdestciv);
           END IF;
           -- Naturalidade
           IF rw_crapcrl.dsnatura <> ' ' THEN
             vr_obj_generico.put('naturalidade', rw_crapcrl.dsnatura);
           END IF;
           -- Caixa Postal
           IF rw_crapcrl. nrcxpost <> 0 THEN
             vr_obj_generico.put('caixaPostal', rw_crapcrl.nrcxpost);
           END IF;

           -- Enviar informações adicionais ao JSON Responsavel Leval
           vr_obj_responsav.put('informacoesAdicionais' ,vr_obj_generico);

           -- Adicionar o responsavel montato na lista de responsaveis
           vr_lst_generico.append(vr_obj_responsav.to_json_value());
         END IF;


        END LOOP; --> crapcrl

        -- Enviar novo objeto de responsaveis para dentro do objeto principal
        -- (Somente se encontramos)
        IF vr_flrespvl THEN
          vr_obj_analise.put('representantesLegais' ,vr_lst_generico);
        END IF;

      END IF;
    END IF; -- INPESSOA

    --> Para pessoa Jurídica buscaremos os sócios da Empresa:
    IF rw_crapass.inpessoa = 2 THEN

      -- Inicializar lista de Representantes
      vr_lst_generico := json_list();

      --> Efetuar laço para retornar todos os registros disponíveis:
      FOR rw_crapavt IN cr_crapavt( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctrcrd => 0
                                   ,pr_tpctrato => 6
                                   ,pr_dsproftl => 'SOCIO') LOOP

        -- Setar flag para indicar que há sócio
        vr_flsocios := true;
        -- Se socio for associado
        IF rw_crapavt.nrdctato > 0 THEN
          -- Passaremos a conta para montagem dos dados:
          este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapavt.nrdctato
                                 ,pr_nrctremp => NULL
                                 ,pr_dsjsonan => vr_obj_socio
                                 ,pr_persocio => rw_crapavt.persocio
                                 ,pr_dtadmsoc => rw_crapavt.dtadmsoc
                                 ,pr_dtvigpro => rw_crapavt.dtvalida
                                 ,pr_tpprodut => vr_tpprodut
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_socio.to_json_value());

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de socios
          pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                                 ,pr_dsjsonavt  => vr_obj_socio
                                 ,pr_cdcritic   => vr_cdcritic
                                 ,pr_dscritic   => vr_dscritic);
          -- Testar possíveis er ros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_socio.to_json_value());

        END IF;


      END LOOP; --Fim crapavt

      -- Enviar novo objeto de socios para dentro do objeto principal (Se houve encontro)
      IF vr_flsocios = true THEN
        vr_obj_analise.put('socios' ,vr_lst_generico);
      END IF;

      --> Busca das participações societárias
      -- Inicializar lista de Participações Societárias
      vr_lst_generico := json_list();

      --> Efetuar laço para retornar todos os registros disponíveis de participações:
      FOR rw_crapepa IN cr_crapepa( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta)  LOOP
        -- Setar flag para indicar que há participações
        vr_flpartic := true;
        -- Se socio for associado
        IF rw_crapepa.nrctasoc > 0 THEN
          -- Passaremos a conta para montagem dos dados:
          este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapepa.nrctasoc
                                 ,pr_nrctremp => NULL
                                 ,pr_persocio => rw_crapepa.persocio
                                 ,pr_dtadmsoc => rw_crapepa.dtadmiss
                                 ,pr_dtvigpro => to_date('31/12/9999','dd/mm/rrrr')
                                 ,pr_dsjsonan => vr_obj_particip
                                 ,pr_tpprodut => vr_tpprodut
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_particip.to_json_value());

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de Participações
          vr_obj_particip.put('documento'      ,gene0002.fn_mask(NVL(rw_crapepa.nrdocsoc,0),'99999999999999'));
          vr_obj_particip.put('tipoPessoa'     ,'JURIDICA');
          vr_obj_particip.put('razaoSocial'    ,rw_crapepa.nmprimtl);

          IF rw_crapepa.dtiniatv IS NOT NULL THEN
            vr_obj_particip.put('dataFundacao' ,este0002.fn_Data_ibra_motor(rw_crapepa.dtiniatv));
          END IF;

          -- Montar informações Adicionais
          vr_obj_generico := json();

          -- Conta
          vr_obj_generico.put('conta', to_number(substr(rw_crapepa.nrdconta,1,length(rw_crapepa.nrdconta)-1)));
          vr_obj_generico.put('contaDV', to_number(substr(rw_crapepa.nrdconta,-1)));

          IF INSTR(rw_crapepa.dsendweb,'@') > 0 THEN
            vr_obj_generico.put('email', rw_crapepa.dsendweb);
          END IF;

          -- Natureza Juridica
          IF rw_crapepa.natjurid <> 0 THEN
            --> Buscar descrição
            OPEN cr_nature(pr_natjurid => rw_crapepa.natjurid);
            FETCH cr_nature INTO rw_nature;
            CLOSE cr_nature;

            vr_obj_generico.put('naturezaJuridica', rw_crapepa.natjurid||'-'||rw_nature.dsnatjur);
          END IF;

          -- Quantidade Filiais
          vr_obj_generico.put('quantFiliais', rw_crapepa.qtfilial);

          -- Quantidade Funcionários
          vr_obj_generico.put('quantFuncionarios', rw_crapepa.qtfuncio);

          -- Ramo Atividade
          IF rw_crapepa.cdseteco <> 0 AND rw_crapepa.cdrmativ <> 0 THEN

            OPEN cr_gnrativ (pr_cdseteco => rw_crapepa.cdseteco,
                             pr_cdrmativ => rw_crapepa.cdrmativ );
            FETCH cr_gnrativ INTO rw_gnrativ;
            CLOSE cr_gnrativ;

            vr_obj_generico.put('ramoAtividade', rw_crapepa.cdrmativ ||'-'||rw_gnrativ.nmrmativ);
          END IF;

          -- Setor Economico
          IF rw_crapepa.cdseteco <> 0 THEN

            -- Buscar descrição
            vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'GENERI'
                                                     ,pr_cdempres => 0
                                                     ,pr_cdacesso => 'SETORECONO'
                                                     ,pr_tpregist => rw_crapepa.cdseteco);
            -- Se Encontrou
            IF TRIM(vr_dstextab) IS NOT NULL THEN
              vr_nmseteco := vr_dstextab;
            ELSE
              vr_nmseteco := 'Nao Cadastrado';
            END IF;
            vr_obj_generico.put('setorEconomico', rw_crapepa.cdseteco ||'-'|| vr_nmseteco);
          END IF;

          -- Numero Inscrição Estadual
          IF rw_crapepa.nrinsest <> 0 THEN
            vr_obj_generico.put('numeroInscricEstadual', rw_crapepa.nrinsest);
          END IF;

          -- Data de Vigência Procuração
          vr_obj_generico.put('dataVigenciaProcuracao' ,este0002.fn_data_ibra_motor(to_date('31/12/9999','dd/mm/rrrr')));

          -- Data de Admissão Procuração
          IF rw_crapepa.dtadmiss IS NOT NULL THEN
            vr_obj_generico.put('dataAdmissaoProcuracao' ,este0002.fn_data_ibra_motor(rw_crapepa.dtadmiss));
          END IF;

          -- Percentual Procuração
          IF rw_crapepa.persocio IS NOT NULL THEN
            vr_obj_generico.put('valorPercentualProcuracao' ,Este0001.fn_decimal_ibra(rw_crapepa.persocio));
          END IF;

          -- Enviar informações adicionais ao JSON Responsavel Leval
          vr_obj_particip.put('informacoesAdicionais' ,vr_obj_generico);

          -- Adicionar o responsavel montado na lista de participações
          vr_lst_generico.append(vr_obj_particip.to_json_value());

        END IF;

      END LOOP; --> fim crapepa

      -- Enviar novo objeto de participações para dentro do objeto principal (Se houve encontro)
      IF vr_flpartic = true THEN
        vr_obj_analise.put('participacoesSocietarias' ,vr_lst_generico);
      END IF;

    END IF; --> INPESSOA 2

    --> Busca dos procuradores:
    -- Inicializar lista de Representantes
    vr_lst_generico := json_list();

    -->Efetuar laço para retornar todos os registros disponíveis de Procuradores:
    FOR rw_crapavt IN cr_crapavt(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctrcrd => 0
                                ,pr_tpctrato => 6
                                ,pr_dsproftl => 'PROCURADOR') LOOP
      -- Setar flag para indicar que há sócio
      vr_flprocura := true;
      -- Se socio for associado
      IF rw_crapavt.nrdctato > 0 THEN
        -- Passaremos a conta para montagem dos dados:
        este0002.pc_gera_json_pessoa_ass ( pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapavt.nrdctato
                                          ,pr_nrctremp => NULL
                                          ,pr_dsjsonan => vr_obj_procurad
                                          ,pr_tpprodut => vr_tpprodut
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
        -- Testar possíveis erros na rotina:
        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Adicionar o responsavel montato na lista de responsaveis
        vr_lst_generico.append(vr_obj_procurad.to_json_value());

      ELSE
        -- Enviaremos os dados básicos encontrados na tabela de procuradores
        pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                               ,pr_dsjsonavt  => vr_obj_procurad
                               ,pr_cdcritic   => vr_cdcritic
                               ,pr_dscritic   => vr_dscritic);
        -- Testar possíveis erros na rotina:
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Adicionar o responsavel montato na lista de responsaveis
        vr_lst_generico.append(vr_obj_procurad.to_json_value());
      END IF;
    END LOOP;

    -- Enviar novo objeto de procuradores para dentro do objeto principal (Se houve encontro)
    IF vr_flprocura = true THEN
      vr_obj_analise.put('procuradores' ,vr_lst_generico);
    END IF;

    pr_dsjsonan := vr_obj_analise;

  EXCEPTION
    WHEN vr_exc_erro  THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      IF SQLCODE < 0 THEN
        -- Caso ocorra exception gerar o código do erro com a linha do erro
        vr_dscritic:= vr_dscritic ||
                      dbms_utility.format_error_backtrace;

      END IF;

      -- Montar a mensagem final do erro
      vr_dscritic:= 'Erro na montagem dos dados para análise automática da proposta (2): ' ||
                     vr_dscritic || ' -- SQLERRM: ' || SQLERRM;

      -- Remover as ASPAS que quebram o texto
      vr_dscritic:= replace(vr_dscritic,'"', '');
      vr_dscritic:= replace(vr_dscritic,'''','');
      -- Remover as quebras de linha
      vr_dscritic:= replace(vr_dscritic,chr(10),'');
      vr_dscritic:= replace(vr_dscritic,chr(13),'');

      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;

  END pc_gera_json_motor;

  --> Rotina responsavel por gerar a inclusao da proposta para a esteira
  PROCEDURE pc_solicita_sugestao_mot(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                    ,pr_cdorigem  IN INTEGER
                                    ,pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                    ,pr_tpproces  IN VARCHAR2 DEFAULT 'I'
                                    ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE DEFAULT NULL
                                     ---- OUT ----
                                    ,pr_dsmensag OUT VARCHAR2
                                    ,pr_cdcritic OUT NUMBER
                                    ,pr_dscritic OUT VARCHAR2) IS
    /* ..........................................................................

      Programa : pc_solicita_sugestao_mot
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva - Supero
      Data     : Fevereiro/2018.                   Ultima atualizacao: 22/02/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a inclusao da proposta para
      Alteração :

    ..........................................................................*/

    --Buscar informações do Associado
    CURSOR cr_crapass IS
      SELECT *
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Busca acionamentos de retorno de solicitacao de sugestão
    CURSOR cr_sugret(pr_dsprotocolo VARCHAR2) IS
      SELECT idacionamento
            ,dsconteudo_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND cdoperad = 'MOTOR'
         AND nrdconta = pr_nrdconta
         AND tpacionamento = 2 --> Apenas Retorno
         AND tpproduto = 4     --> Apenas Cartão de Crédito
         --AND ((pr_nrctrcrd IS NULL AND nrctrprp IS NULL) OR (nrctrprp = pr_nrctrcrd))
         AND dsprotocolo = pr_dsprotocolo;
    rw_sugret cr_sugret%ROWTYPE;

    --Busca caterogias de cartão
    CURSOR cr_catcrd(pr_cdcooper IN crapass.cdcooper%TYPE
                    ,pr_tpctahab crapadc.tpctahab%TYPE
                    ,pr_tplimcrd IN tbcrd_config_categoria.tplimcrd%TYPE) IS
      SELECT tcc.cdadmcrd
            ,adc.nmresadm
            ,tcc.vllimite_minimo
            ,tcc.vllimite_maximo
        FROM crapadc adc
            ,tbcrd_config_categoria tcc
       WHERE tcc.cdcooper = pr_cdcooper
         AND tcc.tplimcrd = pr_tplimcrd
         AND adc.cdcooper = tcc.cdcooper
         AND adc.cdadmcrd = tcc.cdadmcrd
         AND adc.tpctahab = pr_tpctahab
         AND adc.insitadc = 0 --Normal
       ORDER BY tcc.cdadmcrd;
    rw_catcrd cr_catcrd%ROWTYPE;

    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    vr_exc_cont EXCEPTION;

    --Arrays
    vr_obj_proposta      json := json();
    vr_obj_proposta_clob clob;

    vr_dsprotoc VARCHAR2(1000);
    vr_comprecu VARCHAR2(1000);
    vr_nrdrowid ROWID;

    -- Hora de Envio
    vr_hrenvest crawepr.hrenvest%TYPE;
    -- Quantidade de segundos de Espera
    vr_qtsegund NUMBER;
    -- Analise finalizada
    vr_flganlok BOOLEAN := FALSE;

    -- Objetos para retorno das mensagens
    vr_obj      cecred.json := json();
    vr_obj_anl  cecred.json := json();
    vr_obj_lst  cecred.json_list := json_list();
    vr_obj_msg  cecred.json := json();
    vr_obj_clob CLOB;
    vr_destipo  VARCHAR2(1000);
    vr_desmens  VARCHAR2(4000);
    vr_dsmensag VARCHAR2(32767);
    vr_contigencia VARCHAR2(4000);
    vr_temcrapass  VARCHAR2(1);
    vr_tplimcrd NUMERIC(1) := 0; -- 0=concessao, 1-alteracao

    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;

  BEGIN

    IF pr_tpproces='I' THEN
      vr_tplimcrd := 0; -- concessao
    ELSE
      vr_tplimcrd := 1; -- alteracao
    END IF;

    -- Buscar informações do Associado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%FOUND THEN
      CLOSE cr_crapass;

      vr_temcrapass := 'S';

      FOR rw_catcrd IN cr_catcrd(rw_crapass.cdcooper
                                ,rw_crapass.inpessoa
                                ,vr_tplimcrd) LOOP
        -- Criar objeto para a operação e enviar suas informações
        vr_obj_anl := json();
        vr_obj_anl.put('codigo',rw_catcrd.cdadmcrd);
        vr_obj_anl.put('descricao',rw_catcrd.nmresadm);
        vr_obj_anl.put('vlLimiteMinimo',rw_catcrd.vllimite_minimo);
        vr_obj_anl.put('vlLimiteMaximo',rw_catcrd.vllimite_maximo);

        -- Adicionar Operação na lista
        vr_obj_lst.append(vr_obj_anl.to_json_value());

      END LOOP; -- Final da leitura das categorias

      -- Adicionar o array seguro no objeto informações adicionais
      vr_obj.put('categoriasCartaoCecred', vr_obj_lst);

      -- Criar o CLOB para converter JSON para CLOB
      dbms_lob.createtemporary(vr_obj_clob, TRUE, dbms_lob.call);
      dbms_lob.open(vr_obj_clob, dbms_lob.lob_readwrite);
      json.to_clob(vr_obj,vr_obj_clob);
    ELSE
      CLOSE cr_crapass;

      vr_temcrapass := 'N';
    END IF;

    -- Verifica se está em contingência
    IF gene0001.fn_param_sistema('CRED',pr_cdcooper,'CONTIGENCIA_ESTEIRA_CRD') = 1 THEN
      -- Gravar o acionamento
      este0001.pc_grava_acionamento(pr_cdcooper                 => rw_crapass.cdcooper,
                                    pr_cdagenci                 => 1,
                                    pr_cdoperad                 => 'MOTOR',
                                    pr_cdorigem                 => pr_cdorigem,
                                    pr_nrctrprp                 => NULL,
                                    pr_nrdconta                 => rw_crapass.nrdconta,
                                    pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno
                                    pr_dsoperacao               => 'SOLICITAR SUGESTAO MOTOR - CONTIGENCIA',
                                    pr_dsuriservico             => NULL,
                                    pr_dtmvtolt                 => TRUNC(SYSDATE),
                                    pr_cdstatus_http            => 200,
                                    pr_dsconteudo_requisicao    => vr_obj_clob,
                                    pr_dsresposta_requisicao    => 'CONTIGENCIA',
                                    pr_dsprotocolo              => NULL,
                                    pr_idacionamento            => vr_idaciona,
                                    pr_dscritic                 => vr_dscritic,
                                    pr_tpproduto                => 4); --Cartão

      vr_contigencia := 'Serviço de analise de credito em contingencia. Processo sera realizado de forma manual.';
      raise vr_exc_cont;
    END IF;

    -- Verifica se está em contingência
    IF gene0001.fn_param_sistema('CRED',pr_cdcooper,'ANALISE_OBRIG_MOTOR_CRD') = 1 THEN

      IF vr_temcrapass = 'S' THEN

        -- Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          este0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                        pr_cdagenci              => pr_cdagenci,
                                        pr_cdoperad              => pr_cdoperad,
                                        pr_cdorigem              => pr_cdorigem,
                                        pr_nrctrprp              => null,
                                        pr_nrdconta              => pr_nrdconta,
                                        pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                        pr_dsoperacao            => 'INICIO SOLICITAR SUGESTÃO MOTOR',
                                        pr_dsuriservico          => NULL,
                                        pr_dtmvtolt              => pr_dtmvtolt,
                                        pr_cdstatus_http         => 0,
                                        pr_dsconteudo_requisicao => null,
                                        pr_dsresposta_requisicao => null,
                                        pr_tpproduto             => 4, --Cartão de Crédito
                                        pr_idacionamento         => vr_idaciona,
                                        pr_dscritic              => vr_dscritic);
        END IF;

        --> Gerar informações no padrao JSON da proposta do cartão
        pc_gera_json_motor(pr_cdcooper  => pr_cdcooper,         --> Codigo da cooperativa
                           pr_cdagenci  => pr_cdagenci,         --> Agência da Proposta
                           pr_nrdconta  => pr_nrdconta,         --> Numero da conta do cooperado
                           pr_nrctrcrd  => pr_nrctrcrd,         --> Numero da proposta do cartão
                           pr_tpproces  => pr_tpproces,         --> Tipo Processo (I-Inclusão, A-Alteração)
                           pr_cdoperad  => pr_cdoperad,
                           ---- OUT ----
                           pr_dsjsonan  => vr_obj_proposta,     --> Retorno do clob em modelo json das informações
                           pr_cdcritic  => vr_cdcritic,         --> Codigo da critica
                           pr_dscritic  => vr_dscritic);        --> Descricao da critica

        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        --> Efetuar montagem do nome do Fluxo de Análise Automatica conforme o tipo de pessoa da Proposta
        IF rw_crapass.inpessoa = 1 THEN
          vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
                                                                    ,pr_cdcooper
                                                                    ,'REGRA_ANL_IBRA_CRD')||'/start';
        ELSE
          vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
                                                                    ,pr_cdcooper
                                                                    ,'REGRA_ANL_IBRA_CRD_PJ')||'/start';
        END IF;

        -- Criar o CLOB para converter JSON para CLOB
        dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
        json.to_clob(vr_obj_proposta,vr_obj_proposta_clob);

        -- Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          este0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                        pr_cdagenci              => pr_cdagenci,
                                        pr_cdoperad              => pr_cdoperad,
                                        pr_cdorigem              => pr_cdorigem,
                                        pr_nrctrprp              => null,
                                        pr_nrdconta              => pr_nrdconta,
                                        pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                        pr_dsoperacao            => 'ANTES ENVIAR SOLICITACAO SUGESTAO',
                                        pr_dsuriservico          => NULL,
                                        pr_dtmvtolt              => pr_dtmvtolt,
                                        pr_cdstatus_http         => 0,
                                        pr_tpproduto             => 4, --Cartão de Crédito
                                        pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                                        pr_dsresposta_requisicao => null,
                                        pr_idacionamento         => vr_idaciona,
                                        pr_dscritic              => vr_dscritic);
        END IF;

        --> Enviar dados para Análise Automática Esteira (Motor)
        pc_enviar_esteira(pr_cdcooper    => pr_cdcooper,          --> Codigo da cooperativa
                          pr_cdagenci    => pr_cdagenci,          --> Codigo da agencia
                          pr_cdoperad    => pr_cdoperad,          --> codigo do operador
                          pr_cdorigem    => pr_cdorigem,          --> Origem da operacao
                          pr_nrdconta    => pr_nrdconta,          --> Numero da conta do cooperado
                          pr_nrctrcrd    => pr_nrctrcrd,          --> Numero da proposta do cartão
                          pr_dtmvtolt    => pr_dtmvtolt,          --> Data do movimento
                          pr_comprecu    => vr_comprecu,          --> Complemento do recuros da URI
                          pr_dsmetodo    => 'POST',               --> Descricao do metodo
                          pr_conteudo    => vr_obj_proposta_clob, --> Conteudo no Json para comunicacao
                          pr_dsoperacao  => 'SOLICITA SUGESTAO MOTOR',  --> Operação efetuada
                          pr_tpenvest    => 'M',                  --> Tipo de envio (Motor)
                          pr_dsprotocolo => vr_dsprotoc,          --> Protocolo gerado
                          pr_dscritic    => vr_dscritic);

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_obj_proposta_clob);
        dbms_lob.freetemporary(vr_obj_proposta_clob);

        -- verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        vr_hrenvest := to_char(SYSDATE,'sssss');

        -- Buscar a quantidade de segundos de espera pela Análise Automática
        vr_qtsegund := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'TIME_RESP_MOTOR_CRD'),30);

        -- Efetuar laço para esperarmos (N) segundos ou o termino da analise recebido via POST
        WHILE NOT vr_flganlok AND to_number(to_char(sysdate,'sssss')) - vr_hrenvest < vr_qtsegund LOOP

          -- Aguardar 0.5 segundo para evitar sobrecarga de processador
          sys.dbms_lock.sleep(0.5);

          --Verifica se já gravou o protocolo
          OPEN cr_sugret(pr_dsprotocolo => vr_dsprotoc);
          FETCH cr_sugret INTO rw_sugret;
          IF cr_sugret%FOUND THEN
            vr_flganlok := TRUE;
          END IF;
          CLOSE cr_sugret;
        END LOOP;

        -- Se chegarmos neste ponto e a analise não voltou OK signifca que houve timeout
        IF NOT vr_flganlok THEN
          -- Então acionaremos a rotina que solicita via GET o termino da análise
          -- e caso a mesma ainda não tenha terminado, a proposta será salva como Expirada
          pc_solicita_retorno_analise(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dsprotoc => vr_dsprotoc);
        END IF;

        --Reconsultar para ver se teve retorno
        OPEN cr_sugret(pr_dsprotocolo => vr_dsprotoc);
        FETCH cr_sugret INTO rw_sugret;
        IF cr_sugret%NOTFOUND THEN
          CLOSE cr_sugret;
          vr_dscritic := 'Tempo de retorno do Motor excedido. Favor refazer a operacao.';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_sugret;

          -- Processar as mensagens para adicionar ao retorno
          BEGIN
            -- Efetuar cast para JSON
            vr_obj := json(rw_sugret.dsconteudo_requisicao);
            --Se existe o objeto indicadoresGeradosRegra
            IF vr_obj.exist('resultadoAnaliseRegra') THEN
              pr_dsmensag := 'Resultado da Avaliacao: '|| gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('resultadoAnaliseRegra').to_char(),'"'),'"'),'\u','\')));
            END IF;
            -- Se existe o objeto de analise
            IF vr_obj.exist('analises') THEN
              vr_obj_anl := json(vr_obj.get('analises').to_char());
              -- Se existe a lista de mensagens
              IF vr_obj_anl.exist('mensagensDeAnalise') THEN
                vr_obj_lst := json_list(vr_obj_anl.get('mensagensDeAnalise').to_char());
                -- Para cada mensagem
                FOR vr_idx IN 1..vr_obj_lst.count() LOOP
                  BEGIN
                    vr_obj_msg := json( vr_obj_lst.get(vr_idx));

                    -- Se encontrar o atributo texto e tipo
                    IF vr_obj_msg.exist('texto') AND vr_obj_msg.exist('tipo') THEN
                      vr_desmens := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_msg.get('texto').to_char(),'"'),'"'),'\u','\')));
                      vr_destipo := REPLACE(RTRIM(LTRIM(vr_obj_msg.get('tipo').to_char(),'"'),'"'),'ERRO','REPROVAR');
                    END IF;

                    IF vr_destipo <> 'DETALHAMENTO' THEN
                       vr_dsmensag := vr_dsmensag || '<BR>['||vr_destipo||'] '||vr_desmens;
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      NULL; -- Ignorar essa linha
                  END;
                END LOOP;
              END IF;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              -- Ignorar se o conteudo nao for JSON não conseguiremos ler as mensagens
              null;
          END;

          -- Se nao encontrou mensagem
          IF vr_dsmensag IS NULL THEN
            -- Usar mensagem padrao
            vr_dsmensag := '<br>Obs: para acessar detalhes da decisao, acionar <b>[Detalhes Proposta]</b>';
          ELSE
            -- Gerar texto padrão
            vr_dsmensag := '<br>Detalhes da decisao:<br>###'|| vr_dsmensag;
          END IF;
          -- Concatenar ao retorno a mensagem montada
          pr_dsmensag := pr_dsmensag ||vr_dsmensag;
        END IF;

        -- Commitar o encerramento da rotina
        COMMIT;

      ELSE
        vr_dscritic := 'Não foram encontrados os dados do associado.';
      END IF;

      -- Se o DEBUG estiver habilitado
      IF vr_flgdebug = 'S' THEN
        --> Gravar dados log acionamento
        este0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                      pr_cdagenci              => pr_cdagenci,
                                      pr_cdoperad              => pr_cdoperad,
                                      pr_cdorigem              => pr_cdorigem,
                                      pr_nrctrprp              => null,
                                      pr_nrdconta              => pr_nrdconta,
                                      pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                      pr_dsoperacao            => 'TERMINO SOLICITACAO SUGESTAO MOTOR',
                                      pr_dsuriservico          => NULL,
                                      pr_dtmvtolt              => pr_dtmvtolt,
                                      pr_cdstatus_http         => 0,
                                      pr_tpproduto             => 4, --Cartão de Crédito
                                      pr_dsconteudo_requisicao => null,
                                      pr_dsresposta_requisicao => null,
                                      pr_idacionamento         => vr_idaciona,
                                      pr_dscritic              => vr_dscritic);
      END IF;

      -- Gerar informações do log
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => 'AIMARO'
                          ,pr_dstransa => 'Solicitação Sugestão Motor'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> FALSE
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      COMMIT;

    ELSE
      -- Gravar o acionamento
      este0001.pc_grava_acionamento(pr_cdcooper                 => rw_crapass.cdcooper,
                                    pr_cdagenci                 => 1,
                                    pr_cdoperad                 => 'MOTOR',
                                    pr_cdorigem                 => pr_cdorigem,
                                    pr_nrctrprp                 => NULL,
                                    pr_nrdconta                 => rw_crapass.nrdconta,
                                    pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno
                                    pr_dsoperacao               => 'SOLICITAR SUGESTAO MOTOR - CONTIGENCIA',
                                    pr_dsuriservico             => NULL,
                                    pr_dtmvtolt                 => TRUNC(SYSDATE),
                                    pr_cdstatus_http            => 200,
                                    pr_dsconteudo_requisicao    => vr_obj_clob,
                                    pr_dsresposta_requisicao    => 'CONTIGENCIA',
                                    pr_dsprotocolo              => NULL,
                                    pr_idacionamento            => vr_idaciona,
                                    pr_dscritic                 => vr_dscritic,
                                    pr_tpproduto                => 4); --Cartão

      vr_contigencia := 'Analise automatica de credito nao habilitada para esta cooperativa, a solicitacao deve seguir para a Esteira.';
      RAISE vr_exc_cont;
    END IF;

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

    WHEN vr_exc_cont THEN
      pr_dsmensag := vr_contigencia;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar inclusao da proposta de Análise de Crédito: '||SQLERRM;
  END pc_solicita_sugestao_mot;

  -- Rotina para solicitar analises não respondidas via POST ou solicitar a proposta enviada
  PROCEDURE pc_solicita_retorno_analise(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                                       ,pr_dsprotoc IN crawcrd.dsprotoc%TYPE) IS
    /* .........................................................................

    Programa : pc_solicita_retorno_analise
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Paulo Silva (Supero
    Data     : Maio/2018                    Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Tem como objetivo solicitar o retorno da analise no Motor
    Alteração :

  ..........................................................................*/

    -- Tratamento de exceções
    vr_exc_erro EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(10);

    -- Variáveis auxiliares
    vr_qtsegund      crapprm.dsvlrprm%TYPE;
    vr_host_esteira  VARCHAR2(4000);
    vr_recurso_este  VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_chave_aplica  VARCHAR2(500);
    vr_autori_este   VARCHAR2(500);
    vr_nrdrowid      ROWID;
    vr_dsresana      VARCHAR2(100);
    vr_dssitret      VARCHAR2(100);
    vr_xmllog        VARCHAR2(4000);
    vr_retxml        xmltype;
    vr_nmdcampo      VARCHAR2(100);

    -- Objeto json da proposta
    vr_obj_retorno     json := json();
    vr_request         json0001.typ_http_request;
    vr_response        json0001.typ_http_response;

    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100);
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;

    -- Cursores
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Cooperativas com análise automática obrigatória
    CURSOR cr_crapcop IS
      SELECT cdcooper
        FROM crapcop
       WHERE cdcooper = NVL(pr_cdcooper,cdcooper)
         AND flgativo = 1
         AND gene0001.fn_param_sistema('CRED',cdcooper,'ANALISE_OBRIG_MOTOR_CRD') = 1;

    -- Proposta sem retorno
    -- Busca acionamentos de retorno de solicitacao de sugestão
    CURSOR cr_sugret IS
      SELECT aci.idacionamento
            ,aci.dsconteudo_requisicao
            ,aci.cdagenci_acionamento
            ,TRUNC(aci.dhacionamento) dtacionamento
            ,TO_NUMBER(TO_CHAR(aci.dhacionamento,'sssss')) hracionamento
        FROM tbgen_webservice_aciona aci
       WHERE aci.cdcooper = pr_cdcooper
         AND aci.nrdconta = pr_nrdconta
         AND aci.tpacionamento = 1 --> Apenas Envio
         AND aci.cdorigem  = 5     --> Ayllos
         AND aci.tpproduto = 4     --> Apenas Cartão de Crédito
         --AND aci.nrctrprp IS NULL
         AND aci.dsprotocolo = pr_dsprotoc
         AND NOT EXISTS (SELECT ona.idacionamento
                           FROM tbgen_webservice_aciona ona
                          WHERE ona.cdcooper = pr_cdcooper
                            AND ona.cdoperad = 'MOTOR'
                            AND ona.nrdconta = pr_nrdconta
                            AND ona.tpacionamento = 2 --> Apenas Retorno
                            AND ona.cdorigem  = 9     --> Esteira
                            AND ona.tpproduto = 4     --> Apenas Cartão de Crédito
                            --AND ona.nrctrprp IS NULL
                            AND ona.dsprotocolo = pr_dsprotoc);
    rw_sugret cr_sugret%ROWTYPE;

  BEGIN

    -- Buscar todas as Coops com obrigatoriedade de Análise Automática
    FOR rw_crapcop IN cr_crapcop LOOP

      -- Buscar o tempo máximo de espera em segundos pela analise do motor
      vr_qtsegund := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'TIME_RESP_MOTOR_IBRA');

      --Verificar se a data existe
      OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_dscritic:= gene0001.fn_busca_critica(1);
        CLOSE btch0001.cr_crapdat;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Desde que não estejamos com processo em execução
      IF rw_crapdat.inproces = 1 THEN

        -- Buscar DEBUG ativo ou não
        vr_flgdebug := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'DEBUG_MOTOR_IBRA');

        -- Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          este0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,
                                        pr_cdagenci              => 1,
                                        pr_cdoperad              => '1',
                                        pr_cdorigem              => 5,
                                        pr_nrctrprp              => 0,
                                        pr_nrdconta              => 0,
                                        pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                        pr_dsoperacao            => 'INICIO SOLICITA RETORNOS',
                                        pr_dsuriservico          => NULL,
                                        pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                        pr_cdstatus_http         => 0,
                                        pr_dsconteudo_requisicao => null,
                                        pr_dsresposta_requisicao => null,
                                        pr_tpproduto             => 4, --Cartão de Crédito
                                        pr_idacionamento         => vr_idaciona,
                                        pr_dscritic              => vr_dscritic);
        END IF;

        -- Buscar todas as propostas enviadas para o motor e que ainda não tenham retorno
        FOR rw_sugret IN cr_sugret LOOP

          -- Carregar parametros para a comunicacao com a esteira
          pc_carrega_param_ibra(pr_cdcooper      => pr_cdcooper, -- Codigo da cooperativa
                                pr_tpenvest      => 'M',             -- Tipo de envio M - Motor
                                pr_host          => vr_host_esteira, -- Host da esteira
                                pr_recurso       => vr_recurso_este, -- URI da esteira
                                pr_dsdirlog      => vr_dsdirlog    , -- Diretorio de log dos arquivos
                                pr_autori        => vr_autori_este  ,              -- Authorization
                                pr_chave_aplica  => vr_chave_aplica ,              -- Chave de acesso
                                pr_dscritic      => vr_dscritic    );

          -- Se retornou crítica
          IF trim(vr_dscritic)  IS NOT NULL THEN
            -- Levantar exceção
            RAISE vr_exc_erro;
          END IF;

          vr_recurso_este := vr_recurso_este||'/instance/'||pr_dsprotoc;

          vr_request.service_uri := vr_host_esteira;
          vr_request.api_route   := vr_recurso_este;
          vr_request.method      := 'GET';
          vr_request.timeout     := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
          vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
          vr_request.headers('Authorization') := vr_autori_este;

          -- Se houver ApplicationKey
          IF vr_chave_aplica IS NOT NULL THEN
            vr_request.headers('ApplicationKey') := vr_chave_aplica;
          END IF;

          -- Se o DEBUG estiver habilitado
          IF vr_flgdebug = 'S' THEN
            --> Gravar dados log acionamento
            este0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,
                                          pr_cdagenci              => rw_sugret.cdagenci_acionamento,
                                          pr_cdoperad              => 'MOTOR',
                                          pr_cdorigem              => 5,
                                          pr_nrctrprp              => NULL,
                                          pr_nrdconta              => pr_nrdconta,
                                          pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                          pr_dsoperacao            => 'ANTES SOLICITA RETORNOS',
                                          pr_dsuriservico          => NULL,
                                          pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                          pr_cdstatus_http         => 0,
                                          pr_dsconteudo_requisicao => null,
                                          pr_dsresposta_requisicao => null,
                                          pr_tpproduto             => 4, --Cartão de Crédito
                                          pr_idacionamento         => vr_idaciona,
                                          pr_dscritic              => vr_dscritic);
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

          -- Iniciar status
          vr_dssitret := 'TEMPO ESGOTADO';

          -- HTTP 204 não tem conteúdo
          IF vr_response.status_code != 204 THEN
            -- Extrair dados de retorno
            vr_obj_retorno := json(vr_response.content);
            -- Resultado Analise Regra
            IF vr_obj_retorno.exist('resultadoAnaliseRegra') THEN
              vr_dsresana := ltrim(rtrim(vr_obj_retorno.get('resultadoAnaliseRegra').to_char(),'"'),'"');
              -- Montar a mensagem que será gravada no acionamento
              CASE lower(vr_dsresana)
                WHEN 'aprovar'  THEN vr_dssitret := 'APROVADO AUTOM.';
                WHEN 'reprovar' THEN vr_dssitret := 'REJEITADA AUTOM.';
                WHEN 'derivar'  THEN vr_dssitret := 'ANALISAR MANUAL';
                WHEN 'erro'     THEN vr_dssitret := 'ERRO';
                ELSE vr_dssitret := 'DESCONHECIDA';
              END CASE;
            END IF;
          END IF;
/*
          --> Gravar dados log acionamento
          este0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                        pr_cdagenci              => rw_sugret.cdagenci_acionamento,
                                        pr_cdoperad              => 'MOTOR',
                                        pr_cdorigem              => 5, --Ayllos
                                        pr_nrctrprp              => NULL,
                                        pr_nrdconta              => pr_nrdconta,
                                        pr_tpacionamento         => 2,  -- 1 - Envio, 2 – Retorno
                                        pr_dsoperacao            => 'RETORNO ANALISE AUTOMATICA DE CREDITO - '||vr_dssitret,
                                        pr_dsuriservico          => vr_host_esteira||vr_recurso_este,
                                        pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                        pr_cdstatus_http         => vr_response.status_code,
                                        pr_dsconteudo_requisicao => vr_response.content,
                                        pr_dsresposta_requisicao => vr_dssitret,
                                        pr_tpproduto             => 4, --Cartão de Crédito
                                        pr_dsprotocolo           => pr_dsprotoc,
                                        pr_idacionamento         => vr_idacionamento,
                                        pr_dscritic              => vr_dscritic);

          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
*/
          IF vr_response.status_code NOT IN(200,204,429) THEN
            vr_dscritic := 'Não foi possivel consultar informações da Analise de Credito, '||
                           'favor entrar em contato com a equipe responsavel.  '||
                           '(Cod:'||vr_response.status_code||')';
            RAISE vr_exc_erro;
          END IF;

          -- Se recebemos o código diferente de 200
          IF vr_response.status_code != 200 THEN
            -- Checar expiração
            IF trunc(SYSDATE) > rw_sugret.dtacionamento
            OR to_number(to_char(SYSDATE, 'sssss')) - rw_sugret.hracionamento > vr_qtsegund THEN

              -- Gerar informações do log
              gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => 'MOTOR'
                                  ,pr_dscritic => ' '
                                  ,pr_dsorigem => 'AIMARO'
                                  ,pr_dstransa => 'Expiracao da Analise Automatica'
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1 --> FALSE
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => 'ESTEIRA'
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);

              -- Log de item
              gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'insitdec'
                                       ,pr_dsdadant => 1
                                       ,pr_dsdadatu => 7);

            END IF;

          ELSE

            -- Se o DEBUG estiver habilitado
            IF vr_flgdebug = 'S' THEN
              --> Gravar dados log acionamento
              este0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,
                                            pr_cdagenci              => rw_sugret.cdagenci_acionamento,
                                            pr_cdoperad              => 'MOTOR',
                                            pr_cdorigem              => 5,
                                            pr_nrctrprp              => NULL,
                                            pr_nrdconta              => pr_nrdconta,
                                            pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                            pr_dsoperacao            => 'ANTES PROCESSAMENTO RETORNO',
                                            pr_dsuriservico          => NULL,
                                            pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                            pr_cdstatus_http         => 0,
                                            pr_dsconteudo_requisicao => null,
                                            pr_dsresposta_requisicao => null,
                                            pr_idacionamento         => vr_idaciona,
                                            pr_dscritic              => vr_dscritic);
            END IF;

            -- Gravar o retorno e proceder com o restante do processo pós análise automática
            webs0001.pc_retorno_analise_cartao(pr_cdorigem => 5 /*Ayllos*/
                                              ,pr_dsrequis => vr_obj_retorno.to_char
                                              ,pr_namehost => vr_host_esteira||'/'||vr_recurso_este
                                              -- OUT (Não trataremos retorno de erro pois é tudo efetuado na rotina chamada)
                                              ,pr_xmllog   => vr_xmllog
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic
                                              ,pr_retxml   => vr_retxml
                                              ,pr_nmdcampo => vr_nmdcampo
                                              ,pr_des_erro => vr_des_erro );
          END IF;
          -- Efetuar commit
          COMMIT;
        END LOOP;
        -- Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          este0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,
                                        pr_cdagenci              => 1,
                                        pr_cdoperad              => '1',
                                        pr_cdorigem              => 5,
                                        pr_nrctrprp              => 0,
                                        pr_nrdconta              => 0,
                                        pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                        pr_dsoperacao            => 'TERMINO SOLICITA RETORNOS',
                                        pr_dsuriservico          => NULL,
                                        pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                        pr_cdstatus_http         => 0,
                                        pr_dsconteudo_requisicao => null,
                                        pr_dsresposta_requisicao => null,
                                        pr_idacionamento         => vr_idaciona,
                                        pr_dscritic              => vr_dscritic);
        END IF;
      END IF;
      -- Gravação para liberação do registro
      COMMIT;
    END LOOP;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;
      -- Gerar log
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                 ||' - ESTE0005 --> Erro ao solicitor retorno Protocolo '
                                                 ||pr_dsprotoc||': '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));

    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;
      -- Gerar log
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                 ||' - ESTE0005 --> Erro ao solicitor retorno Protocolo '
                                                 ||pr_dsprotoc||': '||sqlerrm,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
  END pc_solicita_retorno_analise;

  --> Rotina responsavel por gerar o objeto Json da proposta
  PROCEDURE pc_gera_json_proposta(pr_cdcooper  IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                  pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia
                                  pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operado
                                  pr_nrdconta  IN crawcrd.nrdconta%TYPE,  --> Numero da conta do cooperado
                                  pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE,  --> Numero da proposta de cartão
                                  pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta
                                  ---- OUT ----
                                  pr_proposta OUT json,                   --> Retorno do clob em modelo json da proposta do cartão
                                  pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                  pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................

      Programa : pc_gera_json_proposta
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva (Supero)
      Data     : Maio/2018.                   Ultima atualizacao: 01/11/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por realizar as leituras no sistema cecred a fim
                  de montar o objeto json contendo a proposta do cartão

      Alteração : 01/11/2018 - PJ345 - Ajustes para erro no envio dos arquivos (Rafael Faria - Supero)

                  05/08/2019 - P438 - Inclusão dos atributos canalCodigo e canalDescricao no Json para identificar 
                                a origem da operação de crédito na Esteira. (Douglas Pagel / AMcom). 

    ..........................................................................*/
    -----------> CURSORES <-----------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrdconta,
             ass.nmprimtl,
             ass.cdagenci,
             age.nmextage,
             ass.inpessoa,
             decode(ass.inpessoa,1,0,2,1) inpessoa_ibra,
             ass.nrcpfcgc
        FROM crapass ass,
             crapage age
       WHERE ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;


    --> Buscar dados da proposta do cartão
    CURSOR cr_crawcrd (pr_cdcooper crawcrd.cdcooper%TYPE,
                       pr_nrdconta crawcrd.nrdconta%TYPE,
                       pr_nrctrcrd crawcrd.nrctrcrd%TYPE)IS
      SELECT crd.nrctrcrd,
             crd.cdagenci,
             crd.dtmvtolt,
             crd.vllimcrd,
             crd.cdoperad,
             ope.nmoperad,
             crd.dtaprova,
             crd.nrcctitg,
             crd.dsjustif,
             crd.cdadmcrd,
             crd.inupgrad,
             crd.nrcpftit,
             crd.dsprotoc
        FROM crawcrd crd
   LEFT JOIN crapope ope
          ON ope.cdcooper = crd.cdcooper
         AND upper(ope.cdoperad) = upper(crd.cdoperad)
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE;

    --> Selecionar os associados da cooperativa por CPF/CGC
    CURSOR cr_crapass_cpfcgc(pr_cdcooper crapass.cdcooper%TYPE,
                             pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT cdcooper,
             nrdconta,
             flgcrdpa
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrcpfcgc = pr_nrcpfcgc -- CPF/CGC passado
         AND dtelimin IS NULL;

    --> Buscar valor de propostas pendentes
    CURSOR cr_crawepr_pend (pr_cdcooper crawepr.cdcooper%TYPE,
                            pr_nrdconta crawepr.nrdconta%TYPE) IS
      SELECT nvl(SUM(w.vlemprst),0) vlemprst
        FROM crawepr w
        JOIN craplcr l
          ON l.cdlcremp = w.cdlcremp
         AND l.cdcooper = w.cdcooper
       WHERE w.cdcooper = pr_cdcooper
         AND w.nrdconta = pr_nrdconta
         AND w.insitapr IN(1,3)        -- já estao aprovadas
         AND w.insitest NOT IN(4,5,6)  -- 4 - Expiradas 5 - Expiradas por decurso de prazo - PJ 438 - Márcio(Mouts) - 6 - Anulação -- PJ438 - Paulo Martins - Mouts
         AND NOT EXISTS ( SELECT 1
                            FROM crapepr p
                           WHERE w.cdcooper = p.cdcooper
                             AND w.nrdconta = p.nrdconta
                             AND w.nrctremp = p.nrctremp);

    rw_crawepr_pend cr_crawepr_pend%ROWTYPE;

    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad,
             ope.cdoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);

    rw_crapope cr_crapope%ROWTYPE;

    --> Buscar se a conta é de Colaborador Cecred
    CURSOR cr_tbcolab(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT substr(lpad(col.cddcargo_vetor,7,'0'),5,3) cddcargo
        FROM tbcadast_colaborador col
       WHERE col.cdcooper = pr_cdcooper
         AND col.nrcpfcgc = pr_nrcpfcgc
         AND col.flgativo = 'A';
    vr_flgcolab BOOLEAN;
    vr_cddcargo tbcadast_colaborador.cdcooper%TYPE;

    --> Calculo do faturamento PJ
    CURSOR cr_crapjfn(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT vlrftbru##1+vlrftbru##2+vlrftbru##3+vlrftbru##4+vlrftbru##5+vlrftbru##6
            +vlrftbru##7+vlrftbru##8+vlrftbru##9+vlrftbru##10+vlrftbru##11+vlrftbru##12 vltotfat
       FROM crapjfn
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta;
    rw_crapjfn cr_crapjfn%ROWTYPE;

    --Busca dados Alteração de Limite
    CURSOR cr_limatu (pr_nrcontacartao tbcrd_limite_atualiza.nrconta_cartao%TYPE) IS
      SELECT a.vllimite_alterado
            ,a.vllimite_anterior
            ,a.dsjustificativa
            ,a.dsprotocolo
            ,a.nrproposta_est
        FROM tbcrd_limite_atualiza a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.nrconta_cartao = pr_nrcontacartao
         AND a.nrctrcrd = pr_nrctrcrd
         AND a.tpsituacao = 6 -- em analise
         AND a.insitdec   = 1 -- Sem Aprovação
         AND a.dtalteracao = (select max(x.dtalteracao)
                                from tbcrd_limite_atualiza x
                               where a.cdcooper = x.cdcooper
                                 AND a.nrdconta = x.nrdconta
                                 AND a.nrctrcrd = x.nrctrcrd
                                 AND a.nrconta_cartao = x.nrconta_cartao
                                 AND a.nrproposta_est = x.nrproposta_est);
    rw_limatu cr_limatu%ROWTYPE;
    vr_vllimite_alterado tbcrd_limite_atualiza.vllimite_alterado%TYPE;

    --Cursor para buscar o ultimo registro do limite
    CURSOR cr_limultalt (pr_nrcontacartao tbcrd_limite_atualiza.nrconta_cartao%TYPE) IS
      SELECT a.vllimite_anterior
      FROM   tbcrd_limite_atualiza a
      WHERE  a.cdcooper = pr_cdcooper
      AND    a.nrdconta = pr_nrdconta
         AND a.nrconta_cartao = pr_nrcontacartao
         AND a.tpsituacao = 3 --Concluído com sucesso
      AND    ROWNUM = 1
      ORDER BY a.idatualizacao DESC;

    rw_limultalt   cr_limultalt%ROWTYPE;

    -- Busca descricao da categoria
    CURSOR cr_crapadc (pr_cdcooper  crapcop.cdcooper%TYPE,
                       pr_cdadmcrd  crapadc.cdadmcrd%TYPE) IS
      SELECT adc.nmresadm
        FROM crapadc adc
       WHERE adc.cdcooper = pr_cdcooper
         AND adc.cdadmcrd = pr_cdadmcrd;
    rw_crapadc cr_crapadc%ROWTYPE;

    -- Busca limite maximo
    CURSOR cr_tbcrd_config_categoria (pr_cdcooper tbcrd_config_categoria.cdcooper%TYPE
                                     ,pr_cdadmcrd tbcrd_config_categoria.cdadmcrd%TYPE
                                     ,pr_tplimcrd tbcrd_config_categoria.tplimcrd%TYPE) IS
    SELECT cat.vllimite_maximo
      FROM tbcrd_config_categoria cat
     WHERE cat.cdcooper = pr_cdcooper
       AND cat.cdadmcrd = pr_cdadmcrd
       AND cat.tplimcrd = pr_tplimcrd;
    rw_tbcrd_config_categoria cr_tbcrd_config_categoria%ROWTYPE;

    -- Busca categoria cartao atual que esta sendo upgraded
    CURSOR cr_cdadmcrd_uso (pr_cdcooper crapcop.cdcooper%TYPE
                           ,pr_nrdconta crapass.nrdconta%TYPE
                           ,pr_nrcctitg crawcrd.nrcctitg%TYPE
                           ,pr_nrcpftit crawcrd.nrcpftit%TYPE) IS
    SELECT crd.cdadmcrd
      FROM crawcrd crd
     WHERE crd.cdcooper = pr_cdcooper
       AND crd.nrdconta = pr_nrdconta
       AND crd.nrcctitg = pr_nrcctitg
       AND crd.insitcrd = 4 /* em uso */
       AND crd.nrcpftit = pr_nrcpftit
       AND crd.flgprcrd = 1 /* Primeiro titular */;
    rw_cdadmcrd_uso cr_cdadmcrd_uso%ROWTYPE;

    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(500);
    vr_exc_erro EXCEPTION;

    --Tipo de registro do tipo data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Objeto json da proposta
    vr_obj_proposta json := json();
    vr_obj_agencia  json := json();
    vr_obj_imagem   json := json();
    vr_lst_doctos   json_list := json_list();
    vr_json_valor   json_value;

    -- Variaveis auxiliares
    vr_data_aux     DATE := NULL;
    vr_dstextab     craptab.dstextab%TYPE;
    vr_inusatab     BOOLEAN;
    vr_vlutiliz     NUMBER;
    vr_vlprapne     NUMBER;
    vr_vllimdis     NUMBER;
    vr_vlparcel     NUMBER;
    vr_vldispon     NUMBER;
    vr_nmarquiv     VARCHAR2(1000);
    vr_imptermo     VARCHAR2(1000);
    vr_dsiduser     VARCHAR2(100);
    vr_dsprotoc     tbgen_webservice_aciona.dsprotocolo%TYPE;
    vr_dsdirarq     VARCHAR2(1000);
    vr_dscomando    VARCHAR2(1000);
    vr_vllimite     crawcrd.vllimcrd%TYPE;
    vr_tpprodut     VARCHAR2(2);
    vr_dsjustif     crawcrd.dsjustif%TYPE;
    vr_vlsugmot     crawcrd.vllimdlr%TYPE;
    vr_nrctrcrd     crawcrd.nrctrcrd%TYPE;
    vr_tplimcrd     NUMERIC(1) := 0; -- 0=concessao, 1=alteracao
    vr_cdorigem     NUMBER := 0;

    -- Hora da impressao
    vr_hrimpres NUMBER;
    -- Quantidade de segundos de espera
    vr_qtsegund NUMBER;
    -- Analise finalizada
    vr_flganlok boolean := FALSE;

    --- variavel cartoes
    vr_tab_cartoes             CADA0004.typ_tab_cartoes;
    vr_flgativo INTEGER;
    vr_nrctrhcj NUMBER;
    vr_flgliber INTEGER;
    vr_vltotccr NUMBER;
    vr_tab_erro GENE0001.typ_tab_erro;
    vr_des_erro VARCHAR2(10);
    vr_des_reto VARCHAR2(10);

  BEGIN

    --Verificar se a data existe
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE btch0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;

    --> Buscar dados da proposta
    OPEN cr_crawcrd(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrcrd => pr_nrctrcrd);
    FETCH cr_crawcrd INTO rw_crawcrd;

    -- Caso nao encontrar abortar proceso
    IF cr_crawcrd%NOTFOUND THEN
      CLOSE cr_crawcrd;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawcrd;

    -- Verifica se existe alteraçáo de limite
    OPEN cr_limatu(pr_nrcontacartao => rw_crawcrd.nrcctitg);
    FETCH cr_limatu INTO rw_limatu;
    IF cr_limatu%FOUND THEN
      vr_vllimite := rw_limatu.vllimite_alterado;
      vr_tpprodut := 'MJ';
      vr_dsjustif := rw_limatu.dsjustificativa;
      vr_dsprotoc := rw_limatu.dsprotocolo;
      vr_nrctrcrd := rw_limatu.nrproposta_est;
      IF vr_dsprotoc = '0' THEN
        vr_dsprotoc := null;
      END IF;
      vr_tplimcrd := 1; -- alteracao
    ELSE
      vr_vllimite := rw_crawcrd.vllimcrd;
      vr_tpprodut := 'LM';
      vr_dsjustif := rw_crawcrd.dsjustif;
      vr_dsprotoc := rw_crawcrd.dsprotoc;
      vr_nrctrcrd := pr_nrctrcrd;
    IF vr_dsprotoc = '0' THEN
        vr_dsprotoc := null;
      END IF;
      vr_tplimcrd := 0; -- concessao
    END IF;
    CLOSE cr_limatu;
    
    vr_nrctrcrd_aux := vr_nrctrcrd;
    
    OPEN cr_limultalt(pr_nrcontacartao => rw_crawcrd.nrcctitg);
    FETCH cr_limultalt INTO rw_limultalt;
    CLOSE cr_limultalt;

    --> Criar objeto json para agencia da proposta
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', pr_cdagenci);
    vr_obj_proposta.put('PA' ,vr_obj_agencia);
    vr_obj_agencia := json();

    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);
    vr_obj_proposta.put('cooperadoContaPA' ,vr_obj_agencia);

    -- Nr. conta sem o digito
    vr_obj_proposta.put('cooperadoContaNum',to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
    -- Somente o digito
    vr_obj_proposta.put('cooperadoContaDv' ,to_number(substr(rw_crapass.nrdconta,-1)));

    vr_obj_proposta.put('cooperadoNome'    , rw_crapass.nmprimtl);
    vr_obj_proposta.put('cooperadoTipoPessoa', rw_crapass.inpessoa_ibra);

    IF rw_crapass.inpessoa = 1 THEN
      vr_obj_proposta.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
    ELSE
      vr_obj_proposta.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
    END IF;

    vr_obj_proposta.put('numero'             , vr_nrctrcrd);
    vr_obj_proposta.put('valor'              , vr_vllimite);
    vr_obj_proposta.put('parcelaQuantidade'  , '');
    vr_obj_proposta.put('parcelaPrimeiroVencimento', '');
    vr_obj_proposta.put('parcelaValor'       , '');

    --> Data e hora da inclusao da proposta
    vr_data_aux := nvl(to_date(to_char(rw_crawcrd.dtmvtolt,'DD/MM/RRRR HH24:MI:SS'),'DD/MM/RRRR HH24:MI:SS'),
                       to_date(to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),'DD/MM/RRRR HH24:MI:SS'));
    vr_obj_proposta.put('dataHora',este0001.fn_datatempo_ibra(vr_data_aux));


    /* 0 – CDC Diversos
       1 – CDC Veículos
       2 – Empréstimos /Financiamentos
       3 – Desconto Cheques
       4 – Desconto Títulos
       5 – Cartão de Crédito
       6 – Limite de Crédito
       7 - Cartão de Crédito) */

    vr_obj_proposta.put('produtoCreditoSegmentoCodigo',7);
    vr_obj_proposta.put('produtoCreditoSegmentoDescricao','Cartao de Credito CECRED');
    vr_obj_proposta.put('linhaCreditoCodigo'    ,0);
    vr_obj_proposta.put('linhaCreditoDescricao' ,'');
    vr_obj_proposta.put('tipoProduto'           ,vr_tpprodut);
    vr_obj_proposta.put('tipoGarantiaCodigo'    ,'');
    vr_obj_proposta.put('tipoGarantiaDescricao' ,'');

    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapope;
    END IF;

    vr_obj_proposta.put('loginOperador',lower(rw_crapope.cdoperad));
    vr_obj_proposta.put('nomeOperador' ,rw_crapope.nmoperad );

    /*1-pre-aprovado, 2-analise manual, 3-nao conceder */
    vr_obj_proposta.put('parecerPreAnalise',0);

    -- retorna o limite dos cartoes do cooperado para todas as contas (usando a cada0004.lista_cartoes)
    ccrd0001.pc_retorna_limite_cooperado(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_vllimtot => vr_vltotccr);
    --Verificar se usa tabela juros
    vr_dstextab:= tabe0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'TAXATABELA'
                                             ,pr_tpregist => 0);
    -- Se a primeira posição do campo
    -- dstextab for diferente de zero
    vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';

    -- Busca endividamento do cooperado
    rati0001.pc_calcula_endividamento( pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                                      ,pr_cdagenci   => pr_cdagenci     --> Código da agência
                                      ,pr_nrdcaixa   => 0               --> Número do caixa
                                      ,pr_cdoperad   => pr_cdoperad     --> Código do operador
                                      ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parâmetro (CRAPDAT)
                                      ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                      ,pr_dsliquid   => null            --> Lista de contratos a liquidar
                                      ,pr_idseqttl   => 1               --> Sequencia de titularidade da conta
                                      ,pr_idorigem   => 1 /*AYLLOS*/    --> Indicador da origem da chamada
                                      ,pr_inusatab   => vr_inusatab     --> Indicador de utilização da tabela de juros
                                      ,pr_tpdecons   => 3               --> Tipo da consulta 3 - Considerar a data atual
                                      ,pr_vlutiliz   => vr_vlutiliz     --> Valor da dívida
                                      ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                                      ,pr_dscritic   => vr_dscritic);   --> Saída de erro
    -- Se houve erro
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF;

    vr_vllimdis := 0.0;
    vr_vlprapne := 0.0;

    FOR rw_crapass_cpfcgc IN cr_crapass_cpfcgc(pr_cdcooper => pr_cdcooper,
                                               pr_nrcpfcgc => rw_crapass.nrcpfcgc) LOOP

      rw_crawepr_pend := NULL;

      OPEN cr_crawepr_pend(pr_cdcooper => rw_crapass_cpfcgc.cdcooper,
                           pr_nrdconta => rw_crapass_cpfcgc.nrdconta);
      FETCH cr_crawepr_pend INTO rw_crawepr_pend;
      CLOSE cr_crawepr_pend;

      vr_vlprapne := nvl(rw_crawepr_pend.vlemprst, 0) + vr_vlprapne;

      --> Selecionar o saldo disponivel do pre-aprovado da conta em questão  da carga ativa
      IF rw_crapass_cpfcgc.flgcrdpa = 1 THEN
		-- Calcular o pre-aprovado disponível
        empr0002.pc_calc_pre_aprovad_sint_cta(pr_cdcooper => rw_crapass_cpfcgc.cdcooper
                                             ,pr_nrdconta => rw_crapass_cpfcgc.nrdconta
                                             ,pr_vlparcel => vr_vlparcel
                                             ,pr_vldispon => vr_vldispon
                                             ,pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
        END IF;
        -- Incrementar o disponível
        vr_vllimdis := nvl(vr_vldispon, 0) + vr_vllimdis;
      END IF;
    END LOOP;

    vr_obj_proposta.put('endividamentoContaValor',vr_vlutiliz+vr_vltotccr);
    vr_obj_proposta.put('propostasPendentesValor',este0001.fn_decimal_ibra(vr_vlprapne) );
    vr_obj_proposta.put('limiteCooperadoValor'   ,este0001.fn_decimal_ibra(nvl(vr_vllimdis,0)) );
    vr_obj_proposta.put('protocoloPolitica',vr_dsprotoc);

    -- Tratativa exclusiva para ambiente de homologacao, não deve existir o parametro "URI_WEBSRV_ESTEIRA_HOMOL"
    -- em ambiente produtivo
    IF (trim(gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_ESTEIRA_HOMOL')) IS NOT NULL) THEN
      vr_obj_proposta.put('ambienteTemp','true');
      vr_obj_proposta.put('urlRetornoTemp', gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_ESTEIRA_HOMOL') );
    END IF;


    --> Busca nome da categoria da proposta
    OPEN cr_crapadc (pr_cdcooper => pr_cdcooper
                    ,pr_cdadmcrd => rw_crawcrd.cdadmcrd);
    FETCH cr_crapadc INTO rw_crapadc;
    IF cr_crapadc%FOUND THEN
      vr_obj_proposta.put('categoriaNova',rw_crapadc.nmresadm);
    END IF;
    CLOSE cr_crapadc;

    -- Busca limite sugerido pelo motor
    ccrd0007.pc_busca_valor_sugerido_motor(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrctrcrd => rw_crawcrd.nrctrcrd
                                          ,pr_dsprotoc => vr_dsprotoc
                                          ,pr_vlsugmot => vr_vlsugmot
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
    IF (TRIM(vr_dscritic) IS NOT NULL OR vr_cdcritic > 0) THEN
      vr_vlsugmot := 0;
    END IF;
    vr_obj_proposta.put('valorLimiteMaximoPermitido',este0001.fn_decimal_ibra(vr_vlsugmot));

    -- Caso for alteracao de limite - majoracao
    IF (vr_tpprodut = 'MJ') then
      vr_obj_proposta.put('valorLimiteAtivo',este0001.fn_decimal_ibra(rw_crawcrd.vllimcrd));
      vr_obj_proposta.put('valorLimiteAnterior',este0001.fn_decimal_ibra(nvl(rw_limultalt.vllimite_anterior,0)));
    END IF;

    -- Busca limite maximo da categoria
    OPEN cr_tbcrd_config_categoria (pr_cdcooper => pr_cdcooper
                                   ,pr_cdadmcrd => rw_crawcrd.cdadmcrd
                                   ,pr_tplimcrd => vr_tplimcrd);
    FETCH cr_tbcrd_config_categoria INTO rw_tbcrd_config_categoria;
    IF cr_tbcrd_config_categoria%FOUND THEN
      vr_obj_proposta.put('valorLimiteCategoria',este0001.fn_decimal_ibra(rw_tbcrd_config_categoria.vllimite_maximo));
    END IF;
    CLOSE cr_tbcrd_config_categoria;

    IF (rw_crawcrd.inupgrad = 1) THEN
      --> Busca categoria anterior (caso upgrade)
      OPEN cr_cdadmcrd_uso (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrcctitg => rw_crawcrd.nrcctitg
                           ,pr_nrcpftit => rw_crawcrd.nrcpftit);
      FETCH cr_cdadmcrd_uso INTO rw_cdadmcrd_uso;
      IF cr_cdadmcrd_uso%FOUND THEN

        --> Busca descricao da categoria anterior
        OPEN cr_crapadc (pr_cdcooper => pr_cdcooper
                        ,pr_cdadmcrd => rw_cdadmcrd_uso.cdadmcrd);
        FETCH cr_crapadc INTO rw_crapadc;
        IF cr_crapadc%FOUND THEN
          vr_obj_proposta.put('categoriaAnterior',rw_crapadc.nmresadm);
        END IF;
        CLOSE cr_crapadc;

      END IF;
      CLOSE cr_cdadmcrd_uso;
    END IF;

    /* A esteira aceita no máximo 235 caracteres */
    vr_obj_proposta.put('justificativa',substr(fn_remove_caract_espec(vr_dsjustif),1,235));

    -- Copiar parâmetro
    vr_nmarquiv := pr_nmarquiv;

/* Ajustado Anderson. */
    -- Caso não tenhamos recebido o PDF
    IF vr_nmarquiv IS NULL THEN

      -- Gerar ID aleatório
      vr_nmarquiv := dbms_random.string('A', 27);

      IF rw_crapass.inpessoa = 1 THEN
        -- Chamar a rotina de impressao do termo de adesao
        ccrd0008.pc_impres_termo_adesao_pf(pr_cdcooper => pr_cdcooper            --> Código da Cooperativa
                                          ,pr_cdagecxa => pr_cdagenci            --> Código da agencia
                                          ,pr_nrdcaixa => 1                      --> Numero do caixa do operador
                                          ,pr_cdopecxa => pr_cdoperad            --> Código do Operador
                                          ,pr_nmdatela => 'ESTEIRA'              --> Nome da Tela
                                          ,pr_idorigem => 1                      --> Identificador de Origem
                                          ,pr_cdprogra => 'ATENDA'               --> Codigo do programa
                                          ,pr_nrdconta => pr_nrdconta            --> Número da Conta
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt    --> Data de Movimento
                                          ,pr_nrctrlim => rw_crawcrd.nrctrcrd    --> Proposta Contrato
                                          ,pr_flgerlog => 0                      --> Indicador se deve gerar log(0-nao, 1-sim)
                                          ,pr_nmarquiv => vr_nmarquiv            --> Id usuario
                                          --------> OUT <--------
                                          ,pr_nmarqpdf => vr_imptermo            --> Retornar quantidad de registros
                                          ,pr_cdcritic => vr_cdcritic            --> Código da crítica
                                          ,pr_dscritic => vr_dscritic);
      ELSE
        -- Chamar a rotina de impressao do termo de adesao
        ccrd0008.pc_impres_termo_adesao_pj(pr_cdcooper => pr_cdcooper            --> Código da Cooperativa
                                          ,pr_cdagecxa => pr_cdagenci            --> Código da agencia
                                          ,pr_nrdcaixa => 1                      --> Numero do caixa do operador
                                          ,pr_cdopecxa => pr_cdoperad            --> Código do Operador
                                          ,pr_nmdatela => 'ESTEIRA'              --> Nome da Tela
                                          ,pr_idorigem => 1                      --> Identificador de Origem
                                          ,pr_cdprogra => 'ATENDA'               --> Codigo do programa
                                          ,pr_nrdconta => pr_nrdconta            --> Número da Conta
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt    --> Data de Movimento
                                          ,pr_nrctrlim => rw_crawcrd.nrctrcrd    --> Proposta Contrato
                                          ,pr_flgerlog => 0                      --> Indicador se deve gerar log(0-nao, 1-sim)
                                          ,pr_nmarquiv => vr_nmarquiv            --> Id usuario
                                          --------> OUT <--------
                                          ,pr_nmarqpdf => vr_imptermo            --> Retornar quantidad de registros
                                          ,pr_cdcritic => vr_cdcritic            --> Código da crítica
                                          ,pr_dscritic => vr_dscritic);
      END IF;

      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
         vr_imptermo := null;
         vr_nmarquiv := null;
      ELSE

        -- Nome do PDF para gerar
        vr_nmarquiv := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_nmsubdir => '/rl')
                       ||'/'||vr_imptermo;

        vr_hrimpres := to_char(SYSDATE,'sssss');
        vr_qtsegund := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'TIME_RESP_IMP_TAPF'),30);
        vr_flganlok := false;

        -- Se o arquivo não existir
        IF NOT gene0001.fn_exis_arquivo(vr_nmarquiv) THEN
          -- caso nao achar esperar um pouco antes de zerar erro
          sys.dbms_lock.sleep(0.5);
          IF NOT gene0001.fn_exis_arquivo(vr_nmarquiv) THEN
          -- Remover o conteudo do nome do arquivo para não enviar
          vr_nmarquiv := null;
        END IF;
        END IF;
      END IF;
    END IF;

    IF vr_nmarquiv IS NOT NULL THEN
      -- Converter arquivo PDF para clob em base64 para enviar via json
      este0001.pc_arq_para_clob_base64(pr_nmarquiv       => vr_nmarquiv
                                      ,pr_json_value_arq => vr_json_valor
                                      ,pr_dscritic       => vr_dscritic);

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar objeto json para a imagem
      vr_obj_imagem.put('codigo'      ,'PROPOSTA_PDF');
      vr_obj_imagem.put('conteudo'    ,vr_json_valor);
      vr_obj_imagem.put('emissaoData' ,este0001.fn_data_ibra(SYSDATE));
      vr_obj_imagem.put('validadeData', '');

      -- incluir objeto imagem na proposta
      vr_lst_doctos.append(vr_obj_imagem.to_json_value());

      -- Caso o PDF tenha sido gerado nesta rotina
      IF vr_nmarquiv <> NVL(pr_nmarquiv,' ') THEN
        -- Temos de apagá-lo... Em outros casos o PDF é apagado na rotina chamadora
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmarquiv);
      END IF;
    END IF;

    -- Se encontrou PDF de análise Motor
    IF trim(vr_dsprotoc) IS NOT NULL THEN

      -- Diretorio para salvar
      vr_dsdirarq := gene0001.fn_diretorio (pr_tpdireto => 'C' --> usr/coop
                                           ,pr_cdcooper => 3
                                           ,pr_nmsubdir => '/log/webservices');

      -- Utilizar o protocolo para nome do arquivo
      vr_nmarquiv := vr_dsprotoc || '.pdf';

      -- Comando para download
      vr_dscomando := gene0001.fn_param_sistema('CRED',3,'SCRIPT_DOWNLOAD_PDF_ANL');

      -- Substituir o caminho do arquivo a ser baixado
      vr_dscomando := replace(vr_dscomando
                             ,'[local-name]'
                             ,vr_dsdirarq || '/' || vr_nmarquiv);

      -- Substiruir a URL para Download
      vr_dscomando := REPLACE(vr_dscomando
                             ,'[remote-name]'
                             ,gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'HOST_WEBSRV_MOTOR_IBRA')
                             ||gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'URI_WEBSRV_MOTOR_IBRA')
                             || '_result/' || vr_dsprotoc || '/pdf');

      -- Executar comando para Download
--ATENCAO - EM PRODUCAO alterar para 'S' apenas
      --ATENCAO - caso ocorrer erro em HOMOL alterar para 'SR' para testar
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando);

      -- Se encontrou o arquivo
      IF gene0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq || '/' || vr_nmarquiv) THEN
        -- Converter arquivo PDF para clob em base64 para enviar via json
        este0001.pc_arq_para_clob_base64(pr_nmarquiv       => vr_dsdirarq || '/' || vr_nmarquiv
                                        ,pr_json_value_arq => vr_json_valor
                                        ,pr_dscritic       => vr_dscritic);

        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Gerar objeto json para a imagem
        vr_obj_imagem.put('codigo'      ,'RESULTADO_POLITICA');
        vr_obj_imagem.put('conteudo'    ,vr_json_valor);
        vr_obj_imagem.put('emissaoData' ,este0001.fn_data_ibra(SYSDATE));
        vr_obj_imagem.put('validadeData','');
        -- incluir objeto imagem na proposta
        vr_lst_doctos.append(vr_obj_imagem.to_json_value());

        -- Temos de apagá-lo... Em outros casos o PDF é apagado na rotina chamadora
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm ' || vr_dsdirarq || '/' || vr_nmarquiv);
      END IF;

    END IF;

    -- Incluiremos os documentos ao json principal
    IF json_ac.array_count(vr_lst_doctos) > 0  THEN
      vr_obj_proposta.put('documentos',vr_lst_doctos);
    END IF;

    vr_obj_proposta.put('contratoNumero',vr_nrctrcrd/*rw_crawcrd.nrctrcrd*/);

    -- Verificar se a conta é de colaborador do sistema Cecred
    vr_cddcargo := NULL;

    OPEN cr_tbcolab(pr_cdcooper => pr_cdcooper
                   ,pr_nrcpfcgc => rw_crapass.nrcpfcgc);
    FETCH cr_tbcolab INTO vr_cddcargo;

    IF cr_tbcolab%FOUND THEN
      vr_flgcolab := TRUE;
    ELSE
      vr_flgcolab := FALSE;
    END IF;
    CLOSE cr_tbcolab;

    -- Enviar tag indicando se é colaborador
    vr_obj_proposta.put('cooperadoColaborador',vr_flgcolab);

    -- Enviar o cargo somente se colaborador
    IF vr_flgcolab THEN
      vr_obj_proposta.put('codigoCargo',vr_cddcargo);
    END IF;

    -- Enviar nivel de risco no momento da criacao
    vr_obj_proposta.put('classificacaoRisco','');

    -- Enviar flag se a proposta é de renogociação
    vr_obj_proposta.put('renegociacao','');

    -- BUscar faturamento se pessoa Juridica
    IF rw_crapass.inpessoa = 2 THEN
      -- Buscar faturamento
      OPEN cr_crapjfn(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapjfn
       INTO rw_crapjfn;
      CLOSE cr_crapjfn;
      vr_obj_proposta.put('faturamentoAnual',este0001.fn_decimal_ibra(rw_crapjfn.vltotfat));
    END IF;

    vr_cdorigem := CASE WHEN rw_crawcrd.cdoperad = '996' THEN 3 ELSE 5 END;
   
    vr_obj_proposta.put('canalCodigo', vr_cdorigem);
    vr_obj_proposta.put('canalDescricao',gene0001.vr_vet_des_origens(vr_cdorigem));

    -- Devolver o objeto criado
    pr_proposta := vr_obj_proposta;

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

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel montar objeto proposta: '||SQLERRM;
  END pc_gera_json_proposta;

  --> Rotina responsavel por gerar a inclusao da proposta para a esteira
  PROCEDURE pc_incluir_proposta_est(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                   ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                   ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                   ,pr_cdorigem  IN INTEGER
                                   ,pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                   ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                   ,pr_nmarquiv  IN VARCHAR2
                                    ---- OUT ----
                                   ,pr_dsmensag OUT VARCHAR2
                                   ,pr_cdcritic OUT NUMBER
                                   ,pr_dscritic OUT VARCHAR2) IS
    /* ..........................................................................

      Programa : pc_incluir_proposta_est
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva (Supero)
      Data     : Maio/2018.                   Ultima atualizacao: 29/03/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a inclusao da proposta para a esteira

      Alteração : 28/11/2018 - PJ345 Ajustado o nome do arquivo (Rafael Faria - Supero)

                  29/03/2019 - Ajustar cr_limatu pois estava buscando na ordem errada
                               (Lucas Ranghetti PRB0040718)
    ..........................................................................*/

    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    vr_exc_cont EXCEPTION;
    vr_majoraca BOOLEAN := FALSE;

    vr_obj_proposta      json := json();
    vr_obj_proposta_clob CLOB;

    vr_dsprotoc VARCHAR2(1000);
    vr_dsmensag VARCHAR2(4000);
    vr_retxml   xmltype;
    vr_xmllog   VARCHAR2(32000);
    vr_nmdcampo VARCHAR2(4000);
    vr_vllimite NUMBER;
    vr_envia_esteira BOOLEAN := TRUE;

    -- Tipo Envio Esteira
    vr_tpenvest VARCHAR2(1);
    vr_nrdrowid ROWID;

    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;

    -- Buscar informações da Proposta
    CURSOR cr_crawcrd IS
      SELECT wpr.insitdec
            ,wpr.insitcrd
            ,wpr.dtaprova
            ,wpr.cdagenci
            ,wpr.nrctaav1
            ,wpr.nrctaav2
            ,ass.inpessoa
            ,wpr.dsprotoc
            ,wpr.nrcctitg
            ,wpr.inupgrad
            ,wpr.cdadmcrd
            ,wpr.vllimcrd
            ,wpr.rowid
        FROM crawcrd wpr
            ,crapass ass
       WHERE wpr.cdcooper = ass.cdcooper
         AND wpr.nrdconta = ass.nrdconta
         AND wpr.cdcooper = pr_cdcooper
         AND wpr.nrdconta = pr_nrdconta
         AND wpr.nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE;

    CURSOR cr_limatu IS
        SELECT a.rowid
              ,a.*
              ,crd.flgprcrd
          FROM tbcrd_limite_atualiza a
          JOIN crawcrd crd
            ON crd.cdcooper = a.cdcooper
           AND crd.nrdconta = a.nrdconta
           AND crd.nrctrcrd = pr_nrctrcrd
           AND crd.nrcctitg > 0 /* Se a proposta nao tem conta cartao
                                   ela nao foi pro bancoob, logo nao
                                   pode ter uma alteracao de limite */
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta
           AND a.tpsituacao = 6 --Em Análise
           AND a.insitdec IN (1,6)   -- Sem Aprovação, Refazer
           AND a.dtalteracao = (SELECT MAX(atu.dtalteracao)
                                    FROM tbcrd_limite_atualiza atu
                                   WHERE atu.cdcooper = a.cdcooper
                                     AND atu.nrdconta = a.nrdconta
                                     AND atu.nrconta_cartao = a.nrconta_cartao);
      rw_limatu cr_limatu%ROWTYPE;

  BEGIN

    -- Buscar informações da proposta
    OPEN cr_crawcrd;
    FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;

    /* Ajuste Anderson: Procedimento copiado do WEBS0001, para verificar
       se está sendo enviado alteracao de limite para a esteira.
       REVISAR DEPOIS DA ENTREGA 3 - precisamos de uma foma melhor de
       identificar isso. */
    vr_majoraca := FALSE;
    OPEN cr_limatu;
    FETCH cr_limatu INTO rw_limatu;
    IF cr_limatu%FOUND THEN
      vr_majoraca := TRUE;
    END IF;
    CLOSE cr_limatu;
   /* fim verificacao alteracao limite */

    pc_verifica_regras_esteira(pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa
                               ---- OUT ----
                               pr_cdcritic => vr_cdcritic,   --> Codigo da critica
                               pr_dscritic => vr_dscritic);  --> Descricao da critica

    vr_envia_esteira := TRUE;
    IF (nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL) THEN
      vr_envia_esteira := FALSE;
    ELSIF NOT vr_majoraca AND rw_crawcrd.vllimcrd=0 THEN
      vr_envia_esteira := FALSE;
    END IF;

    -- Se houve erro
    IF NOT vr_envia_esteira THEN
      IF NOT vr_majoraca THEN

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
                                            <idorigem>'|| pr_cdorigem ||'</idorigem>
                                            <cdoperad>'|| pr_cdoperad ||'</cdoperad>
                                          </params>
                                        </Root>');

        ccrd0007.pc_solicitar_cartao_bancoob(pr_nrdconta => pr_nrdconta
                                            ,pr_nrctrcrd => pr_nrctrcrd
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_xmllog   => vr_xmllog
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_retxml   => vr_retxml
                                            ,pr_nmdcampo => vr_nmdcampo
                                            ,pr_des_erro => vr_dsmensag);

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
        vr_vllimite := rw_limatu.vllimite_anterior;
        --Chama alteração de limite do cartão Bancoob
        ccrd0007.pc_alterar_cartao_bancoob(pr_cdcooper => pr_cdcooper
                                          ,pr_cdagenci => pr_cdagenci
                                          ,pr_cdoperad => pr_cdoperad
                                          ,pr_idorigem => pr_cdorigem
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrctrcrd => pr_nrctrcrd
                                          ,pr_vllimite => rw_limatu.vllimite_alterado
                                          ,pr_idseqttl => rw_limatu.flgprcrd
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic
                                          ,pr_des_erro => vr_dsmensag
                                          );

        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Levanta exceção
           RAISE vr_exc_erro;
        END IF;
      END IF;

      RAISE vr_exc_cont;
    END IF;

    --Verificar se a data existe
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE btch0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      este0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                    pr_cdagenci              => pr_cdagenci,
                                    pr_cdoperad              => pr_cdoperad,
                                    pr_cdorigem              => pr_cdorigem,
                                    pr_nrctrprp              => pr_nrctrcrd,
                                    pr_nrdconta              => pr_nrdconta,
                                    pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                    pr_dsoperacao            => 'INICIO INCLUIR PROPOSTA',
                                    pr_dsuriservico          => NULL,
                                    pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                    pr_cdstatus_http         => 0,
                                    pr_dsconteudo_requisicao => null,
                                    pr_dsresposta_requisicao => null,
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic);
    END IF;





    --> Gerar informações no padrao JSON da proposta do cartão
    pc_gera_json_proposta(pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa
                          pr_cdagenci  => pr_cdagenci,  --> Codigo da agencia
                          pr_cdoperad  => pr_cdoperad,  --> codigo do operado
                          pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                          pr_nrctrcrd  => pr_nrctrcrd,  --> Numero da proposta do cartão
                          pr_nmarquiv  => NULL,         --> Diretorio e nome do arquivo pdf da proposta
                          ---- OUT ----
                          pr_proposta  => vr_obj_proposta,  --> Retorno do clob em modelo json da proposta do cartão
                          pr_cdcritic  => vr_cdcritic,  --> Codigo da critica
                          pr_dscritic  => vr_dscritic); --> Descricao da critica

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Se origem veio do Motor/Esteira
    IF pr_cdorigem = 9 THEN
      -- É uma derivação
      vr_tpenvest := 'D';
    ELSE
      vr_tpenvest := 'I';
    END IF;

    -- Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_proposta,vr_obj_proposta_clob);

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      este0001.pc_grava_acionamento( pr_cdcooper              => pr_cdcooper,
                                     pr_cdagenci              => pr_cdagenci,
                                     pr_cdoperad              => pr_cdoperad,
                                     pr_cdorigem              => pr_cdorigem,
                                     pr_nrctrprp              => pr_nrctrcrd,
                                     pr_nrdconta              => pr_nrdconta,
                                     pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                     pr_dsoperacao            => 'ANTES ENVIAR PROPOSTA',
                                     pr_dsuriservico          => NULL,
                                     pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                     pr_cdstatus_http         => 0,
                                     pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                                     pr_dsresposta_requisicao => null,
                                     pr_idacionamento         => vr_idaciona,
                                     pr_dscritic              => vr_dscritic);
    END IF;

    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,          --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,          --> Codigo da agencia
                        pr_cdoperad    => pr_cdoperad,          --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,          --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,          --> Numero da conta do cooperado
                        pr_nrctrcrd    => pr_nrctrcrd,          --> Numero da proposta do cartão atual/antigo
                        pr_dtmvtolt    => rw_crapdat.dtmvtolt,          --> Data do movimento
                        pr_comprecu    => NULL,                 --> Complemento do recuros da URI
                        pr_dsmetodo    => 'POST',               --> Descricao do metodo
                        pr_conteudo    => vr_obj_proposta_clob, --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DA PROPOSTA PARA ANALISE DE CREDITO',   --> Operacao realizada
                        pr_tpenvest    => vr_tpenvest,          --> Tipo de envio
                        pr_dsprotocolo => vr_dsprotoc,
                        pr_dscritic    => vr_dscritic);

    -- Caso tenhamos recebido critica de Proposta jah existente na Esteira
    IF lower(vr_dscritic) LIKE '%proposta%ja existente na esteira%' THEN

      -- Tentaremos enviar alteração com reinício de fluxo para a Esteira
      ESTE0005.pc_alterar_proposta_est (pr_cdcooper => pr_cdcooper          --> Codigo da cooperativa
                                       ,pr_cdagenci => pr_cdagenci          --> Codigo da agencia
                                       ,pr_cdoperad => pr_cdoperad          --> codigo do operador
                                       ,pr_cdorigem => pr_cdorigem          --> Origem da operacao
                                       ,pr_nrdconta => pr_nrdconta          --> Numero da conta do cooperado
                                       ,pr_nrctrcrd => pr_nrctrcrd          --> Numero da proposta do cartão atual/antigo
                                       ,pr_flreiflx => 1                    --> Reiniciar o fluxo
                                       ,pr_nmarquiv => pr_nmarquiv          --> nome do arquivo PDF
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

      END IF;

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_obj_proposta_clob);
    dbms_lob.freetemporary(vr_obj_proposta_clob);

    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    /* Se nao for alteracao limite, vamos adequar a situacao da proposta
       Valido para solicitacao de cartao e upgrade */
    IF NOT vr_majoraca THEN

      IF rw_crawcrd.inupgrad = 1 THEN
        -- Caso for Upgrade, temos que atualizar toda as propostas, inclusive dos adicionais
        BEGIN
          UPDATE crawcrd wpr
             SET wpr.insitcrd = 1 -- Aprovado
                ,wpr.insitdec = 1 -- Sem Aprovacao
                ,wpr.dtenvest = trunc(sysdate)
           WHERE wpr.cdcooper = pr_cdcooper
             AND wpr.nrdconta = pr_nrdconta
             AND wpr.inupgrad = 1  /* flag upgrade */
             AND wpr.nrcctitg = rw_crawcrd.nrcctitg  /* mesma conta cartao */
             AND wpr.cdadmcrd = rw_crawcrd.cdadmcrd /* adminstradora */
             /* 1 - Sem aprovacao, 4 - Erro, 6 - Refazer */
             AND wpr.insitdec in (1,4,6);

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Nao foi possivel atualizar proposta apos envio para Análise de Crédito: '||SQLERRM;
            RAISE vr_exc_erro;
        END;

      ELSE
        -- IF por seguranca. Nao vamos alterar a situacao dos cartoes já existentes no bancoob
        -- soh deveria cair aqui se for solitacao de novo cartao.
        IF (rw_crawcrd.nrcctitg = 0) THEN
          BEGIN
            UPDATE crawcrd wpr
               SET wpr.insitcrd = 1 -- Aprovado
                  ,wpr.insitdec = 1 -- Sem Aprovacao
                  ,wpr.dtenvest = trunc(sysdate)
             WHERE wpr.rowid = rw_crawcrd.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel atualizar proposta apos envio para Análise de Crédito: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
      END IF;

      -- Gerar informações do log
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => 'AIMARO WEB'
                          ,pr_dstransa => 'Envio Proposta Analise Manual de Credito'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> FALSE
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      -- Log de item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'insitcrd'
                               ,pr_dsdadant => rw_crawcrd.insitcrd
                               ,pr_dsdadatu => 1);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'insitdec'
                               ,pr_dsdadant => rw_crawcrd.insitdec
                               ,pr_dsdadatu => 1);
    ELSE -- majoracao

      BEGIN
        UPDATE tbcrd_limite_atualiza tla
           SET dtenvest = trunc(sysdate)
         WHERE tla.rowid = rw_limatu.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel atualizar proposta apos envio para Análise de Crédito: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;

    pr_dsmensag := 'Proposta Enviada para Analise Manual de Credito.';

    -- Efetuar gravação
    COMMIT;

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      este0001.pc_grava_acionamento( pr_cdcooper              => pr_cdcooper,
                                     pr_cdagenci              => pr_cdagenci,
                                     pr_cdoperad              => pr_cdoperad,
                                     pr_cdorigem              => pr_cdorigem,
                                     pr_nrctrprp              => pr_nrctrcrd,
                                     pr_nrdconta              => pr_nrdconta,
                                     pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                     pr_dsoperacao            => 'TERMINO INCLUIR PROPOSTA',
                                     pr_dsuriservico          => NULL,
                                     pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                     pr_cdstatus_http         => 0,
                                     pr_dsconteudo_requisicao => null,
                                     pr_dsresposta_requisicao => null,
                                     pr_idacionamento         => vr_idaciona,
                                     pr_dscritic              => vr_dscritic);
    END IF;

    COMMIT;

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

      IF vr_majoraca THEN
        --Atualiza Histórico do Limite de Crédito
        tela_atenda_cartaocredito.pc_altera_limite_crd(pr_cdcooper => pr_cdcooper
                                                      ,pr_cdoperad => pr_cdoperad
                                                      ,pr_nrdconta => pr_nrdconta
                                                      ,pr_nrctrcrd => pr_nrctrcrd
                                                      ,pr_vllimite => vr_vllimite
                                                      ,pr_dsprotoc => vr_dsprotoc
                                                      ,pr_dsjustif => NULL
                                                      ,pr_flgtplim => 'A'
                                                      ,pr_idorigem => 5
                                                      ,pr_tpsituac => 4 --> Crítica
                                                      ,pr_insitdec => NULL
                                                      ,pr_nmdatela => NULL
                                                      ,pr_cdcritic => vr_cdcritic
                                                      ,pr_dscritic => vr_dscritic
                                                      ,pr_des_erro => vr_dsmensag
                                                      );
      END IF;
    WHEN vr_exc_cont THEN
      pr_dsmensag := vr_dsmensag;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar inclusao da proposta de Análise de Crédito: '||SQLERRM;
  END pc_incluir_proposta_est;

  --> Rotina responsavel por gerar a alteracao da proposta para a esteira
  PROCEDURE pc_alterar_proposta_est(pr_cdcooper  IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                    pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia
                                    pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                    pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                    pr_nrdconta  IN crawcrd.nrdconta%TYPE,  --> Numero da conta do cooperado
                                    pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE,  --> Numero da proposta de emprestimo
                                    pr_flreiflx  IN INTEGER,                --> Indica se deve reiniciar o fluxo de aprovacao na esteira (1-true, 0-false)
                                    pr_nmarquiv  IN VARCHAR2,            --> nome do arquivo PDF
                                    ---- OUT ----
                                    pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                    pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................

      Programa : pc_alterar_proposta_est
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva (Supero)
      Data     : Maio/2018.                   Ultima atualizacao: 28/11/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a alteracao da proposta para a esteira

      Alteração : 28/11/2018 - PJ345 Ajustado o nome do arquivo (Rafael Faria - Supero)

    ..........................................................................*/
    -----------> CURSORES <-----------

    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);

    rw_crapope cr_crapope%ROWTYPE;

   CURSOR cr_limatu IS
      SELECT a.rowid,a.*
        FROM tbcrd_limite_atualiza a
        JOIN crawcrd crd
          ON crd.cdcooper = a.cdcooper
         AND crd.nrdconta = a.nrdconta
         AND crd.nrctrcrd = pr_nrctrcrd
         AND crd.nrcctitg > 0 /* Se a proposta nao tem conta cartao
                                 ela nao foi pro bancoob, logo nao
                                 pode ter uma alteracao de limite */
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.tpsituacao = 6 --Em Análise
         AND a.insitdec IN (1,6)   -- Sem Aprovação, Refazer
         AND NOT EXISTS (SELECT 1
                           FROM tbcrd_limite_atualiza b
                          WHERE b.cdcooper = a.cdcooper
                            AND b.nrdconta = a.nrdconta
                            AND b.idatualizacao > a.idatualizacao);
    rw_limatu cr_limatu%ROWTYPE;

    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_dsmensag VARCHAR2(4000);
    vr_exc_erro EXCEPTION;

    -- Objeto json da proposta
    vr_obj_alter    json := json();
    vr_obj_proposta json := json();
    vr_obj_agencia  json := json();
    vr_dsprotocolo  VARCHAR2(1000);
    vr_obj_proposta_clob clob;
    vr_majoraca BOOLEAN := FALSE;

    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;

  BEGIN

    --Verificar se a data existe
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE btch0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      este0001.pc_grava_acionamento (pr_cdcooper              => pr_cdcooper,
                                     pr_cdagenci              => pr_cdagenci,
                                     pr_cdoperad              => pr_cdoperad,
                                     pr_cdorigem              => pr_cdorigem,
                                     pr_nrctrprp              => pr_nrctrcrd,
                                     pr_nrdconta              => pr_nrdconta,
                                     pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                     pr_dsoperacao            => 'INICIO ALTERAR PROPOSTA',
                                     pr_dsuriservico          => NULL,
                                     pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                     pr_cdstatus_http         => 0,
                                     pr_dsconteudo_requisicao => null,
                                     pr_dsresposta_requisicao => null,
                                     pr_idacionamento         => vr_idaciona,
                                     pr_dscritic              => vr_dscritic);
    END IF;

    --> Gerar informações no padrao JSON da proposta de emprestimo
    pc_gera_json_proposta(pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa
                          pr_cdagenci  => pr_cdagenci,  --> Codigo da agencia
                          pr_cdoperad  => pr_cdoperad,  --> codigo do operado
                          pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                          pr_nrctrcrd  => pr_nrctrcrd,  --> Numero da proposta do cartão
                          pr_nmarquiv  => NULL,         --> Diretorio e nome do arquivo pdf da proposta
                          ---- OUT ----
                          pr_proposta  => vr_obj_proposta,  --> Retorno do clob em modelo json da proposta do cartão
                          pr_cdcritic  => vr_cdcritic,  --> Codigo da critica
                          pr_dscritic  => vr_dscritic); --> Descricao da critica

    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapope;
    END IF;

    vr_majoraca := FALSE;
    OPEN cr_limatu;
    FETCH cr_limatu INTO rw_limatu;
    IF cr_limatu%FOUND THEN
      vr_majoraca := TRUE;
    END IF;
    CLOSE cr_limatu;
    -- Incluir objeto proposta
    vr_obj_alter.put('dadosAtualizados'      ,vr_obj_proposta);
    vr_obj_alter.put('operadorAlteracaoLogin',lower(pr_cdoperad));
    vr_obj_alter.put('operadorAlteracaoNome' ,rw_crapope.nmoperad) ;
    vr_obj_alter.put('dataHora'              ,este0001.fn_datatempo_ibra(SYSDATE)) ;
    vr_obj_alter.put('reiniciaFluxo'         ,(pr_flreiflx = 1) ) ;

    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'   , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'            , pr_cdagenci);
    vr_obj_alter.put('operadorAlteracaoPA'   , vr_obj_agencia);

    -- Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_alter,vr_obj_proposta_clob);

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      este0001.pc_grava_acionamento (pr_cdcooper              => pr_cdcooper,
                                     pr_cdagenci              => pr_cdagenci,
                                     pr_cdoperad              => pr_cdoperad,
                                     pr_cdorigem              => pr_cdorigem,
                                     pr_nrctrprp              => pr_nrctrcrd,
                                     pr_nrdconta              => pr_nrdconta,
                                     pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                     pr_dsoperacao            => 'ANTES ALTERAR PROPOSTA',
                                     pr_dsuriservico          => NULL,
                                     pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                     pr_cdstatus_http         => 0,
                                     pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                                     pr_dsresposta_requisicao => null,
                                     pr_idacionamento         => vr_idaciona,
                                     pr_dscritic              => vr_dscritic);
    END IF;

    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,          --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,          --> Codigo da agencia
                        pr_cdoperad    => pr_cdoperad,          --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,          --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,          --> Numero da conta do cooperado
                        pr_nrctrcrd    => pr_nrctrcrd,          --> Numero da proposta do cartão atual/antigo
                        pr_dtmvtolt    => rw_crapdat.dtmvtolt,          --> Data do movimento
                        pr_comprecu    => NULL,                 --> Complemento do recuros da URI
                        pr_dsmetodo    => 'PUT',                --> Descricao do metodo
                        pr_conteudo    => vr_obj_proposta_clob, --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'REENVIO DA PROPOSTA PARA ANALISE DE CREDITO', --> Operacao realizada
                        pr_dsprotocolo => vr_dsprotocolo,
                        pr_dscritic    => vr_dscritic);

    -- Se não houve erro
    IF vr_dscritic IS NULL THEN
      -- atualiza limite
      IF vr_majoraca THEN
        UPDATE tbcrd_limite_atualiza tla
           SET dtenvest = trunc(sysdate)
         WHERE tla.rowid = rw_limatu.rowid;
      ELSE
        --> Atualizar proposta
        BEGIN
          UPDATE crawcrd crd
             SET crd.dsprotoc = nvl(vr_dsprotocolo,crd.dsprotoc)
                ,crd.dtaprova = NULL
                ,crd.dtenvest = trunc(sysdate)
           WHERE crd.cdcooper = pr_cdcooper
             AND crd.nrdconta = pr_nrdconta
             AND crd.nrctrcrd = pr_nrctrcrd;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da Analise de Credito: '||SQLERRM;
        END;
      END IF;

    -- Caso tenhamos recebido critica de Proposta jah existente na Esteira
    ELSIF lower(vr_dscritic) LIKE '%proposta nao encontrada%' THEN

      -- Tentaremos enviar inclusão novamente na Esteira
      pc_incluir_proposta_est(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                             ,pr_cdagenci => pr_cdagenci --> Codigo da agencia
                             ,pr_cdoperad => pr_cdoperad --> codigo do operador
                             ,pr_cdorigem => pr_cdorigem --> Origem da operacao
                             ,pr_nrdconta => pr_nrdconta --> Numero da conta do cooperado
                             ,pr_nrctrcrd => pr_nrctrcrd --> Numero da proposta do cartão atual/antigo
                             ,pr_nmarquiv => pr_nmarquiv --> Nome do arquivo PDF
                             ,pr_dsmensag => vr_dsmensag
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

    END IF;

    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
        IF lower(vr_dscritic) LIKE '%efetuar a reanalise%limite de reanalises%proposta foi excedido%' THEN
           BEGIN
             UPDATE crawcrd
                SET insitcrd = 6 --Cancelado
                   ,flgprcrd = 0 --Nao eh mais o primeiro cartao
                   ,dtcancel = TRUNC(SYSDATE) -- Setar a data de cancelamento
              WHERE cdcooper = pr_cdcooper
                AND nrdconta = pr_nrdconta
                AND nrctrcrd = pr_nrctrcrd;
                vr_dscritic := 'Nao foi possivel efetuar a reanalise, pois o limite de reanalises desta proposta foi excedido.';
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao cancelar proposta.';
           END;
        END IF;
        RAISE vr_exc_erro;
    END IF;

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      este0001.pc_grava_acionamento (pr_cdcooper              => pr_cdcooper,
                                     pr_cdagenci              => pr_cdagenci,
                                     pr_cdoperad              => pr_cdoperad,
                                     pr_cdorigem              => pr_cdorigem,
                                     pr_nrctrprp              => pr_nrctrcrd,
                                     pr_nrdconta              => pr_nrdconta,
                                     pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                     pr_dsoperacao            => 'TERMINO ALTERAR PROPOSTA',
                                     pr_dsuriservico          => NULL,
                                     pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                     pr_cdstatus_http         => 0,
                                     pr_dsconteudo_requisicao => NULL,
                                     pr_dsresposta_requisicao => NULL,
                                     pr_idacionamento         => vr_idaciona,
                                     pr_dscritic              => vr_dscritic);
    END IF;

    COMMIT;

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

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar alteracao da proposta de Analise de Credito: '||SQLERRM;
  END pc_alterar_proposta_est;

--> Rotina responsavel por gerar efetivacao da proposta para a esteira
  PROCEDURE pc_efetivar_proposta_est( pr_cdcooper  IN crawcrd.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawcrd.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE,  --> Numero da proposta de cartao
                                      pr_nrctrest  IN crawcrd.nrctrcrd%TYPE DEFAULT NULL,    --> Numero do contrato original da esteira (tratamento limite credito)
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento
                                      pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de cartao de credito
                                      pr_tpregistro IN VARCHAR2,              --> Tipo de regitro I - Solicitação cartão, A - Alteração de Limite
                                      ---- OUT ----
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................

      Programa : pc_efetivar_proposta_est
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Carlos Lima(Supero)
      Data     : Junho/2018.                   Ultima atualizacao: 05/11/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a efetivacao da proposta para a esteira

      Alteração : 05/11/2018 - PJ345 - Ajustado dados enviados (Rafael Faria - Supero)

    ..........................................................................*/

    -----------> CURSORES <-----------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrdconta,
             ass.nmprimtl,
             ass.cdagenci,
             age.nmextage,
             ass.inpessoa,
             decode(ass.inpessoa,1,0,2,1) inpessoa_ibra,
             ass.nrcpfcgc

        FROM crapass ass,
             crapage age
       WHERE ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --> Buscar dados da proposta de cartao de credito
    CURSOR cr_crawcrd (pr_cdcooper crawcrd.cdcooper%TYPE,
                       pr_nrdconta crawcrd.nrdconta%TYPE,
                       pr_nrctrcrd crawcrd.nrctrcrd%TYPE)IS
      SELECT wcrd.nrctrcrd,
             wcrd.vllimcrd,
             wcrd.cdagenci,
             wcrd.cdagenci cdagenci_efet,
             wcrd.dtmvtolt,
             wcrd.dtpropos,
             wcrd.dtsolici,
             wcrd.cdoperad--- ver isso
        FROM crawcrd wcrd
       WHERE wcrd.cdcooper = pr_cdcooper
         AND wcrd.nrdconta = pr_nrdconta
         AND wcrd.nrctrcrd = pr_nrctrcrd;

    rw_crawcrd cr_crawcrd%ROWTYPE;

    CURSOR cr_limatu IS
      SELECT *
        FROM tbcrd_limite_atualiza a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.nrctrcrd = pr_nrctrcrd
         AND a.nrproposta_est = pr_nrctrest;
    rw_limatu cr_limatu%ROWTYPE;

    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad,
             ope.cdoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;

    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;

    -- Objeto json da proposta
    vr_obj_efetivar json := json();
    vr_obj_agencia  json := json();

    -- Auxiliares
    vr_dsprotocolo  VARCHAR2(1000);
    vr_nrctrprp     NUMBER(10);
    vr_cdagenci     crawcrd.cdagenci%TYPE;
    vr_dtsolici     crawcrd.dtsolici%TYPE;
    vr_vllimcrd     crawcrd.vllimcrd%TYPE;

    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;

  BEGIN

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                           pr_cdagenci              => pr_cdagenci,
                           pr_cdoperad              => pr_cdoperad,
                           pr_cdorigem              => pr_cdorigem,
                           pr_nrctrprp              => pr_nrctrcrd,
                           pr_nrdconta              => pr_nrdconta,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */
                           pr_dsoperacao            => 'INICIO EFETIVAR PROPOSTA',
                           pr_dsuriservico          => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
    END IF;

    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;

    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapope;
    END IF;

    IF pr_tpregistro = 'I' THEN
    --> Buscar dados da proposta de cartao de credito
    OPEN cr_crawcrd(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrcrd => pr_nrctrcrd);
    FETCH cr_crawcrd INTO rw_crawcrd;

    -- Caso nao encontrar abortar proceso
    IF cr_crawcrd%NOTFOUND THEN
      CLOSE cr_crawcrd;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawcrd;

      vr_nrctrprp := pr_nrctrcrd;
      vr_cdagenci := rw_crawcrd.cdagenci;
      vr_dtsolici := rw_crawcrd.dtsolici;
      vr_vllimcrd := rw_crawcrd.vllimcrd;

    ELSE
      OPEN cr_limatu;
      FETCH cr_limatu INTO rw_limatu;
      IF cr_limatu%FOUND THEN
        vr_nrctrprp := rw_limatu.nrproposta_est;
        vr_cdagenci := pr_cdagenci;
        vr_dtsolici := rw_limatu.dtretorno;
        vr_vllimcrd := rw_limatu.vllimite_alterado;
      ELSE
        vr_nrctrprp := pr_nrctrcrd;
        vr_cdagenci := pr_cdagenci;
        vr_dtsolici := pr_dtmvtolt;
      END IF;
      CLOSE cr_limatu;
    END IF;

    --> Criar objeto json para agencia da proposta
    /***************** VERIFICAR *********************/
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', vr_cdagenci);
    vr_obj_efetivar.put('PA' ,vr_obj_agencia);
    vr_obj_agencia := json();

    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);
    vr_obj_efetivar.put('cooperadoContaPA' ,vr_obj_agencia);
    vr_obj_agencia := json();

    -- Nr. conta sem o digito
    vr_obj_efetivar.put('cooperadoContaNum'      , to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
    -- Somente o digito
    vr_obj_efetivar.put('cooperadoContaDv'       , to_number(substr(rw_crapass.nrdconta,-1)));

    IF rw_crapass.inpessoa = 1 THEN
      vr_obj_efetivar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
    ELSE
      vr_obj_efetivar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
    END IF;

    vr_obj_efetivar.put('numero'                 , vr_nrctrprp);
    vr_obj_efetivar.put('operadorEfetivacaoLogin', lower(rw_crapope.cdoperad));
    vr_obj_efetivar.put('operadorEfetivacaoNome' , rw_crapope.nmoperad);
     --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'       , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'                , vr_cdagenci);
    vr_obj_efetivar.put('operadorEfetivacaoPA'   , vr_obj_agencia);
    vr_obj_efetivar.put('dataHora'               ,fn_DataTempo_ibra(COALESCE(vr_dtsolici, SYSDATE))) ;
    vr_obj_efetivar.put('contratoNumero'         , vr_nrctrprp);
    vr_obj_efetivar.put('valor'                  , vr_vllimcrd);
    vr_obj_efetivar.put('parcelaQuantidade'      , ''); -- TODO descomentar
    vr_obj_efetivar.put('parcelaPrimeiroVencimento' , '');
    vr_obj_efetivar.put('parcelaValor'           , ''); -- TODO descomentar
    vr_obj_efetivar.put('produtoCreditoSegmentoCodigo',7);
    vr_obj_efetivar.put('produtoCreditoSegmentoDescricao','Cartao de Credito CECRED');

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                           pr_cdagenci              => pr_cdagenci,
                           pr_cdoperad              => pr_cdoperad,
                           pr_cdorigem              => pr_cdorigem,
                           pr_nrctrprp              => pr_nrctrcrd,
                           pr_nrdconta              => pr_nrdconta,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */
                           pr_dsoperacao            => 'ANTES EFETIVAR PROPOSTA',
                           pr_dsuriservico          => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => vr_obj_efetivar.to_char,
                           pr_dsresposta_requisicao => null,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
    END IF;

    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,               --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,               --> Codigo da agencia
                        pr_cdoperad    => pr_cdoperad,               --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,               --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,               --> Numero da conta do cooperado
                        pr_nrctrcrd    => pr_nrctrcrd,               --> Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,               --> Data do movimento
                        pr_comprecu    => '/efetivar',               --> Complemento do recuros da URI
                        pr_dsmetodo    => 'PUT',                     --> Descricao do metodo
                        pr_conteudo    => vr_obj_efetivar.to_char,   --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DA EFETIVACAO DA PROPOSTA DE ANALISE DE CREDITO',       --> Operacao realizada
                        pr_dsprotocolo => vr_dsprotocolo,
                        pr_dscritic    => vr_dscritic);

    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

     --> Atualizar proposta
    IF pr_tpregistro = 'I' THEN

      BEGIN
        UPDATE crawcrd crd
           SET crd.insitdec = 8 -- Efetivado
              ,crd.dtenefes = trunc(sysdate)
         WHERE crd.cdcooper = pr_cdcooper
           AND crd.nrdconta = pr_nrdconta
           AND crd.nrctrcrd = pr_nrctrcrd;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da efetivacao de Analise de Credito: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

    ELSIF pr_tpregistro = 'A' THEN

      BEGIN
        UPDATE tbcrd_limite_atualiza
           SET insitdec   = 8 -- Efetivado
              ,dtenefes   = trunc(sysdate)
         WHERE tpsituacao = 3 -- Concluído com sucesso
        AND   cdcooper = pr_cdcooper
        AND   nrdconta = pr_nrdconta
        AND   nrctrcrd = pr_nrctrcrd;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel atualizar o limite da proposta apos envio da efetivacao de Analise de Credito: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

    END IF;

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                           pr_cdagenci              => pr_cdagenci,
                           pr_cdoperad              => pr_cdoperad,
                           pr_cdorigem              => pr_cdorigem,
                           pr_nrctrprp              => pr_nrctrcrd,
                           pr_nrdconta              => pr_nrdconta,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */
                           pr_dsoperacao            => 'TERMINO EFETIVAR PROPOSTA',
                           pr_dsuriservico          => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
    END IF;

    COMMIT;

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

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar efetivacao da proposta de Analise de Credito: '||SQLERRM;
  END pc_efetivar_proposta_est;

END ESTE0005;
/
