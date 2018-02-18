CREATE OR REPLACE package este0003 is
/* --------------------------------------------------------------------------------------------------

      Programa : ESTE0003
      Sistema  : BO - CRÉDITO CONSIGNADO
      Sigla    : XXXX
      Autor    : Lindon Carlos Pecile - GFT-Brasil
      Data     : Fevereiro/2018.          Ultima atualizacao: 10/02/2018

      Dados referentes ao programa:

      Frequencia: Sempre que solicitado
      Objetivo  : BO - Rotinas para envio de informacoes para a Esteira de Credito

-----------------------------------------------------------------------------------------------------
         ATENCAO!    CONVERSAO PROGRESS - ORACLE
   ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-------------------------------------+--------------------------------------+
  | Rotina Progress   | Rotina Oracle PLSQL                                    |
  +-------------------------------------+--------------------------------------+
  |                   |                                                        |
  |                   |                                                        |
  |                   |                                                        |
  |                   |                                                        |
  |                   |                                                        |
  +-------------------------------------+--------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 01/MAR/2018 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - DANIEL       (CECRED)
   - LUIS FERNANDO         (GFT)
   - LINDON CARLOS PECILE  (GFT)
Alteracoes:
 - 000: [DD/MM/AAAA] NOME DO RESPONSÁVEL        (EMPRESA) : ALTERAÇÃO REALIZADA
.................................................................................................
 Declaração das Procedure para incluir  proposta ao motor
.................................................................................................*/

/* Tratamento de erro */
vr_des_erro VARCHAR2(4000);
vr_exc_erro EXCEPTION;

/* Descrição e código da critica */
vr_cdcritic crapcri.cdcritic%TYPE;
vr_dscritic VARCHAR2(4000);


  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_DataTempo_ibra (pr_data IN DATE) RETURN VARCHAR2;

PROCEDURE incluir_proposta_esteira(pr_cdcooper IN crawepr.cdcooper%TYPE,    -- Codigo que identifica a Cooperativa.
                                   pr_cdagenci IN craplim.cdagenci%TYPE,    -- Numero do PA ou Agência.
                                   pr_nrctrlim IN craplim.nrctrlim%TYPE,    -- Numero do Contrato do Limite.
                                   pr_cdoperad IN crapass.inpessoa%TYPE,    --Codigo do operador.
                                   pr_agenci IN craplim.cdagenci%TYPE,      -- Código da Agencia
                                   pr_cdageori IN craplim.cdageori%TYPE,    --Codigo da agencia original do registro.
                                   pr_tpctrlim IN crawepr.cdfinemp%TYPE,
                                   pr_idcobope IN crawepr.cdlcremp%TYPE,
                                   pr_nrdconta IN crawepr.nrdconta%TYPE,    --Numero da conta/dv do associado.
                                   pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,    --Data do movimento atual
                                   pr_nrctremp IN crawepr.nrctremp%TYPE,    --Numero da proposta de emprestimo
                                   pr_tpenvest IN OUT CHAR,                 --Tipo do envestimento I - inclusao Proposta
                                                                            --                     D - Derivacao Proposta
                                                                            --                     A - Alteracao Proposta
                                                                            --                     N - Alterar Numero Proposta
                                                                            --                     C - Cancelar Proposta
                                                                            --                     E - Efetivar Proposta
                                   pr_dsmensag OUT CHAR,                    --Descrição da mensagem
                                   pr_cdcritic IN OUT NUMBER,               --Código da critica.
                                   pr_dscritic IN OUT character);           --Código da critica.

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
                               pr_dsmetodo                 IN tbgen_webservice_aciona.dsmetodo%TYPE DEFAULT NULL,
                               pr_tpconteudo               IN tbgen_webservice_aciona.tpconteudo%TYPE DEFAULT NULL,  --tipo de retorno json/xml
                               pr_tpproduto                IN tbgen_webservice_aciona.tpproduto%TYPE DEFAULT NULL,  --Tipo de produto (0-Emprestimo|Financiamento / 1-Limite Credito / 2-Limite Desconto Cheque / 3-Limite Desconto Titulo)
                               pr_idacionamento            OUT tbgen_webservice_aciona.idacionamento%TYPE,
                               pr_dscritic                 OUT VARCHAR2);

PROCEDURE pc_consulta_acionamento_web(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Nr. Contrato
                                     ,pr_dtinicio IN VARCHAR2 -->
                                     ,pr_dtafinal IN VARCHAR2 -->
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);

PROCEDURE pc_consulta_acionamento(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrctrlim    IN craplim.nrctrlim%TYPE DEFAULT 0 --> Nr. do Contrato
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. da Conta
                                 ,pr_dtinicio    IN DATE DEFAULT NULL
                                 ,pr_dtafinal    IN DATE DEFAULT NULL
                                 ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Cód. Operador
                                 ,pr_cdcritic    OUT crapcri.cdcritic%TYPE --> Cód. da crítica
                                 ,pr_dscritic    OUT crapcri.dscritic%TYPE --> Descrição da crítica
                                 ,pr_tab_crawlim OUT TELA_CONPRO.typ_tab_crawepr);



PROCEDURE pc_obrigacao_analise_automatic(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cód. cooperativa
                                         ---- OUT ----
                                        ,pr_inobriga OUT VARCHAR2              -- Indicador de obrigaçao de análisa automática ('S' - Sim / 'N' - Nao)
                                        ,pr_cdcritic OUT PLS_INTEGER           -- Cód. da crítica
                                        ,pr_dscritic OUT VARCHAR2);            -- Desc. da crítica

PROCEDURE pc_verifica_regras_esteira (pr_cdcooper  IN craplim.cdcooper%TYPE,  -- Codigo da cooperativa
                                      pr_nrdconta  IN craplim.nrdconta%TYPE,  -- Numero da conta do cooperado
                                      pr_nrctrlim  IN craplim.nrctrlim%TYPE,  -- Numero do contrato de emprestimo
                                      pr_tpenvest  IN VARCHAR2 DEFAULT NULL,  -- Tipo de envio
                                      ---- OUT ----
                                      pr_cdcritic OUT NUMBER,                 -- Codigo da critica
                                      pr_dscritic OUT VARCHAR2);              -- Descricao da critica

PROCEDURE pc_incluir_proposta_est(pr_cdcooper  IN craplim.cdcooper%TYPE
                                 ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                 ,pr_cdorigem  IN INTEGER
                                 ,pr_nrdconta  IN craplim.nrdconta%TYPE
                                 ,pr_nrctrlim  IN craplim.nrctrlim%TYPE
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                 ,pr_nmarquiv  IN VARCHAR2
                                  ---- OUT ----
                                 ,pr_dsmensag OUT VARCHAR2
                                 ,pr_cdcritic OUT NUMBER
                                 ,pr_dscritic OUT VARCHAR2);

  --> Rotina responsavel por gerar a alteracao da proposta para a esteira
  procedure pc_alterar_proposta_est(pr_cdcooper  in craplim.cdcooper%type  --> Codigo da cooperativa
                                   ,pr_cdagenci  in crapage.cdagenci%type  --> Codigo da agencia
                                   ,pr_cdoperad  in crapope.cdoperad%type  --> codigo do operador
                                   ,pr_cdorigem  in integer                --> Origem da operacao
                                   ,pr_nrdconta  in craplim.nrdconta%type  --> Numero da conta do cooperado
                                   ,pr_nrctrlim  in craplim.nrctrlim%type  --> Numero da proposta de emprestimo
                                   ,pr_dtmvtolt  in crapdat.dtmvtolt%type  --> Data do movimento
                                   ,pr_flreiflx  in integer                --> Indica se deve reiniciar o fluxo de aprovacao na esteira
                                   ,pr_nmarquiv  in varchar2               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                   ---- OUT ----
                                   ,pr_cdcritic out number                 --> Codigo da critica
                                   ,pr_dscritic out varchar2               --> Descricao da critica
                                   );

  PROCEDURE pc_enviar_esteira (pr_cdcooper    IN crapcop.cdcooper%type  --> Codigo da cooperativa
                              ,pr_cdagenci    IN crapage.cdagenci%type  --> Codigo da agencia
                              ,pr_cdoperad    IN crapope.cdoperad%type  --> codigo do operador
                              ,pr_cdorigem    IN integer                --> Origem da operacao
                              ,pr_nrdconta    IN craplim.nrdconta%type  --> Numero da conta do cooperado
                              ,pr_nrctrlim    IN craplim.nrctrlim%type  --> Numero da proposta de emprestimo
                              ,pr_dtmvtolt    IN crapdat.dtmvtolt%type  --> Data do movimento
                              ,pr_comprecu    IN varchar2               --> Complemento do recuros da URI
                              ,pr_dsmetodo    IN varchar2               --> Descricao do metodo
                              ,pr_conteudo    IN clob                   --> Conteudo no Json para comunicacao
                              ,pr_dsoperacao  IN varchar2               --> Operacao realizada
                              ,pr_tpenvest    IN VARCHAR2 DEFAULT null  --> Tipo de envio, I-Inclusao C - Consultar(Get)
                              ,pr_dsprotocolo OUT varchar2              --> Protocolo retornado na requisição
                              ,pr_dscritic    OUT VARCHAR2 );

  -- Rotina para solicitar analises não respondidas via POST ou solicitar a proposta enviada
  PROCEDURE pc_solicita_retorno_analise(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_nrdconta IN craplim.nrdconta%TYPE
                                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                                       ,pr_dsprotoc IN craplim.dsprotoc%TYPE);

END ESTE0003;
/

CREATE OR REPLACE package body este0003 is

  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_DataTempo_ibra (pr_data IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(pr_data,'RRRR-MM-DD"T"HH24:MI:SS".000Z"');
  END fn_DataTempo_ibra;

PROCEDURE pc_carrega_param_ibra(pr_cdcooper       IN crapcop.cdcooper%type  -- Codigo da cooperativa
                                 ,pr_nrdconta       IN crawepr.nrdconta%type  --> Numero da conta do cooperado
                                 ,pr_nrctrlim       IN craplim.nrctrlim%type  --> Numero da proposta de emprestimo
                                 ,pr_tpenvest       IN VARCHAR2 DEFAULT null  --> Tipo de envio C - Consultar(Get)
                                 ,pr_host_esteira  OUT varchar2               -- Host da esteira
                                 ,pr_recurso_este  OUT varchar2               -- URI da esteira
                                 ,pr_dsdirlog      OUT varchar2               -- Diretorio de log dos arquivos
                                 ,pr_autori_este   OUT varchar2               -- Chave de acesso
                                 ,pr_chave_aplica  OUT varchar2               -- App Key
                                 ,pr_dscritic      OUT VARCHAR2) IS


  /* ..........................................................................

    Programa : pc_carrega_param_ibra
    Sistema  :
    Sigla    : CRED
    Autor    : Paulo Penteado (GFT)
    Data     : Fevereiro/2018.                   Ultima atualizacao: 16/02/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Carregar parametros para uso na comunicacao com a esteira

    Alteração :

  ..........................................................................*/
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic NUMBER;

  BEGIN

    pc_verifica_regras_esteira (pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa
                                pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                                pr_nrctrlim  => pr_nrctrlim,  --> Numero da proposta de emprestimo
                                pr_tpenvest  => pr_tpenvest,  --> Tipo de envio C - Consultar(Get)
                                ---- OUT ----
                                pr_cdcritic => vr_cdcritic,                 --> Codigo da critica
                                pr_dscritic => vr_dscritic);            --> Descricao da critica

    -- Se houve erro
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF;

   IF pr_tpenvest = 'M' THEN
   --> Buscar hots so webservice do motor
   pr_host_esteira := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                          pr_cdcooper => pr_cdcooper,
                          pr_cdacesso => 'HOST_WEBSRV_MOTOR_IBRA');
   IF pr_host_esteira IS NULL THEN
    vr_dscritic := 'Parametro HOST_WEBSRV_MOTOR_IBRA não encontrado.';
    RAISE vr_exc_erro;
   END IF;

   --> Buscar recurso uri do motor
   pr_recurso_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                          pr_cdcooper => pr_cdcooper,
                          pr_cdacesso => 'URI_WEBSRV_MOTOR_IBRA');

   IF pr_recurso_este IS NULL THEN
    vr_dscritic := 'Parametro URI_WEBSRV_MOTOR_IBRA não encontrado.';
    RAISE vr_exc_erro;
   END IF;

   --> Buscar chave de acesso do motor (Autorization é igual ao Consultas Automatizadas)
   pr_autori_este := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                  pr_cdcooper =>  pr_cdcooper,
                                                  pr_cdacesso => 'AUTORIZACAO_IBRATAN');
      IF pr_autori_este IS NULL THEN
    vr_dscritic := 'Parametro AUTORIZACAO_IBRATAN não encontrado.';
    RAISE vr_exc_erro;
   END IF;

      -- Concatenar o Prefixo
      pr_autori_este := 'CECRED'||lpad(pr_cdcooper,2,'0')||':'||pr_autori_este;

      -- Gerar Base 64
      pr_autori_este := 'Ibratan '||sspc0001.pc_encode_base64(pr_autori_este);

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
   pr_host_esteira := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                          pr_cdcooper => pr_cdcooper,
                          pr_cdacesso => 'HOSWEBSRVCE_ESTEIRA_IBRA');
   IF pr_host_esteira IS NULL THEN
    vr_dscritic := 'Parametro HOSWEBSRVCE_ESTEIRA_IBRA não encontrado.';
    RAISE vr_exc_erro;
   END IF;

   --> Buscar recurso uri da esteira
   pr_recurso_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                          pr_cdcooper => pr_cdcooper,
                          pr_cdacesso => 'URIWEBSRVCE_RECURSO_IBRA');

   IF pr_recurso_este IS NULL THEN
    vr_dscritic := 'Parametro URIWEBSRVCE_RECURSO_IBRA não encontrado.';
    RAISE vr_exc_erro;
   END IF;

   --> Buscar chave de acesso da esteira
   pr_autori_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                          pr_cdcooper => pr_cdcooper,
                          pr_cdacesso => 'KEYWEBSRVCE_ESTEIRA_IBRA');

   IF pr_autori_este IS NULL THEN
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

  PROCEDURE incluir_proposta_esteira(pr_cdcooper IN crawepr.cdcooper%TYPE,    -- Codigo que identifica a Cooperativa.
                                     pr_cdagenci IN craplim.cdagenci%TYPE,    -- Numero do PA ou Agência.
                                     pr_nrctrlim IN craplim.nrctrlim%TYPE,    -- Numero do Contrato do Limite.
                                     pr_cdoperad IN crapass.inpessoa%TYPE,    --Codigo do operador.
                                     pr_agenci IN craplim.cdagenci%TYPE,      -- Código da Agencia
                                     pr_cdageori IN craplim.cdageori%TYPE,    --Codigo da agencia original do registro.
                                     pr_tpctrlim IN crawepr.cdfinemp%TYPE,
                                     pr_idcobope IN crawepr.cdlcremp%TYPE,
                                     pr_nrdconta IN crawepr.nrdconta%TYPE,    --Numero da conta/dv do associado.
                                     pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,    --Data do movimento atual
                                     pr_nrctremp IN crawepr.nrctremp%TYPE,    --Numero da proposta de emprestimo
                                     pr_tpenvest IN OUT CHAR,                 --Tipo do envestimento I - inclusao Proposta
                                                                              --                     D - Derivacao Proposta
                                                                              --                     A - Alteracao Proposta
                                                                              --                     N - Alterar Numero Proposta
                                                                              --                     C - Cancelar Proposta
                                                                              --                     E - Efetivar Proposta
                                     pr_dsmensag OUT CHAR,                    --Descrição da mensagem
                                     pr_cdcritic IN OUT NUMBER,               --Código da critica.
                                     pr_dscritic IN OUT character)IS           --Código da critica.) IS         --Código da critica.
-- DECLARE
    vr_dscritic CHARACTER :=  '';
    --vr_exc_erro CHARACTER :=  '';
    vr_dsmensag CHARACTER :=  '';
    vr_cdcritic NUMBER :=0;
    vr_inobriga CHARACTER :=  '';

    -- Declaraçao do cursor para busca do limite do contrato
    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE,
                      pr_nrdconta IN craplim.nrdconta%TYPE,
                      pr_cdageori IN craplim.cdageori%TYPE,
                      pr_cdoperad IN crapass.inpessoa%TYPE,
                      pr_tpctrlim IN craplim.tpctrlim%TYPE,
                      pr_idcobope IN craplim.cddlinha%TYPE,
                      pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
                      SELECT craplim.ROWID, cdcooper AS pr_cdcooper,
                             nrdconta AS pr_nrdconta, cdageori AS pr_cdageori,
                             cdoperad AS pr_cdoperad, tpctrlim AS pr_tpctrlim,
                             idcobope AS pr_idcobope, nrctrlim AS pr_nrctrlim,

                             craplim.*
                      FROM craplim
                      WHERE cdcooper = pr_cdcooper  AND cdagenci = pr_agenci AND cdageori  = pr_cdageori;

      -- Declaraçao da variavel tipo linha que receberá os dados selecionados
      rw_craplim cr_craplim%ROWTYPE;
      BEGIN
        vr_dsmensag := pr_dsmensag;
        vr_cdcritic := pr_cdcritic;
        vr_dscritic := pr_dscritic;

        -- Caso a proposta já tenha sido enviada para a Esteira iremos considerar uma Alteracao.
        -- Caso a proposta tenho sido reprovada pelo Motor, iremos considerar envio pois ela
        -- ainda nao foi a Esteira
        -- Se parametro de entrada for de Inclusao
        IF pr_tpenvest = 'I' THEN
          -- Localiza o limite de crédito na tabela de limites referente aos dados efltuado
            -- Busca do nome do associado
            -- Abertura do cursor para obter o dados do limite do contrato
            OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_cdageori => pr_cdageori,
                            pr_cdoperad => pr_cdoperad,
                            pr_tpctrlim => pr_tpctrlim,
                            pr_idcobope => pr_idcobope,
                            pr_nrctrlim => pr_nrctrlim);
            -- Atribuiçao dos dados selecionados para a variavel tipo linha.
            FETCH cr_craplim INTO rw_craplim;

            --Se um contrato nao for localizado
            IF cr_craplim%NOTFOUND THEN
              --Fechar Cursor do contrato
              CLOSE cr_craplim;
              --armazena a Mensagem Erro
              vr_dscritic:= 'Contrato nao encontrado.';
              --Sair
              --vr_exc_erro := 'Contrato nao encontrado.';
            ELSE
              vr_inobriga := 'N';
              -- Verificar se a proposta devera passar por analise automatica
              pc_obrigacao_analise_automatic(pr_cdcooper => pr_cdcooper
                                            ,pr_inobriga => vr_inobriga
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
             -- Se:
              --    1 - Jah houve envio para a Esteira
              --    2 - Nao precisar passar por Analise Automatica
              --    3 - Nao existir protocolo gravado

              IF (rw_craplim.dtenvest IS NOT NULL AND vr_inobriga <> 'S' AND (trim(rw_craplim.dsprotoc) IS NULL) ) THEN
                    -- Significa que a proposta jah foi para a Esteira,
                    -- entao devemos mandar um reinicio de Fluxo
                    pr_tpenvest := 'A';
              END IF;
              -- Verificar se a Esteira esta em contigencia
              pc_verifica_regras_esteira(pr_cdcooper => rw_craplim.pr_cdcooper
                                        ,pr_nrdconta => rw_craplim.pr_nrdconta
                                        ,pr_nrctrlim => rw_craplim.pr_nrctrlim
                                        ,pr_tpenvest => 'I'
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                 pr_dsmensag := 'NOK';
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
                 RETURN;
              END IF;

              /* Gerar impressao da proposta em PDF para as opcoes abaixo*/

              -- Chamar rotina de inclusao da proposta na Esteira
              /*pc_incluir_proposta_est(pr_cdcooper => pr_cdcooper,     -- pr_cdcooper
                                               pr_cdagenci => pr_cdagenci,     -- pr_cdagenci
                                               pr_cdoperad => pr_cdoperad,     -- pr_cdoperad
                                               pr_cdorigem => pr_cdageori,     -- pr_cdorigem
                                               pr_nrdconta => pr_nrdconta,     -- pr_nrdconta
                                               --cpr_nrctrlim => cpr_nrctrlim,     -- cpr_nrctrlim
                                               pr_nrctremp => pr_nrctremp,     -- cpr_nrctrlim
                                               pr_dtmvtolt => pr_dtmvtolt,     -- pr_dtmvtolt
                                               pr_nmarquiv => '',              -- pr_nmarquiv
                                               --out--------------
                                               pr_dsmensag => vr_dsmensag,     -- pr_dsmensag
                                               pr_cdcritic => vr_cdcritic,     -- pr_cdcritic
                                               pr_dscritic => vr_dscritic);    -- pr_dscritic*/
              --Fechar Cursor do contrato
              CLOSE cr_craplim;
            END IF;




          /*REMOVER*/
          vr_dsmensag:='Aprovada Automaticamente';



          pr_dsmensag := vr_dsmensag;
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;


      END IF;
END incluir_proposta_esteira;

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
                               pr_dsmetodo                 IN tbgen_webservice_aciona.dsmetodo%TYPE DEFAULT NULL,
                               pr_tpconteudo               IN tbgen_webservice_aciona.tpconteudo%TYPE DEFAULT NULL,  --tipo de retorno json/xml
                               pr_tpproduto                IN tbgen_webservice_aciona.tpproduto%TYPE DEFAULT NULL,  --Tipo de produto (0-Emprestimo|Financiamento / 1-Limite Credito / 2-Limite Desconto Cheque / 3-Limite Desconto Titulo)
                               pr_idacionamento           OUT tbgen_webservice_aciona.idacionamento%TYPE,
                               pr_dscritic                OUT VARCHAR2)IS

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
  INSERT INTO tbgen_webservice_aciona                                                                                     /*@TROCAR PARA CECRED.TBGEN_WEBSERVICE_ACIONA*/
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
                dsmetodo,
                tpconteudo,
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
                pr_dsmetodo,        -- dsmetodo
                pr_tpconteudo,      -- tpconteudo
                pr_tpproduto,       --tpproduto
                pr_dsprotocolo)     -- protocolo
         RETURNING tbgen_webservice_aciona.idacionamento INTO pr_idacionamento;

  --> Commit para garantir que guarde as informações do log de acionamento
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    pr_dscritic := 'Erro ao inserir tbgen_webservice_aciona: '||SQLERRM;
    ROLLBACK;
END pc_grava_acionamento;

PROCEDURE pc_obrigacao_analise_automatic(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cód. cooperativa
                                         ---- OUT ----
                                        ,pr_inobriga OUT VARCHAR2              -- Indicador de obrigaçao de análisa automática ('S' - Sim / 'N' - Nao)
                                        ,pr_cdcritic OUT PLS_INTEGER           -- Cód. da crítica
                                        ,pr_dscritic OUT VARCHAR2) IS          -- Desc. da crítica
/* .........................................................................
Programa : pc_obrigacao_analise_automatica
Sistema  :
Sigla    :
Autor    : Lindon Carlos Pecile (GFT - Brasil)
Data     : Fevereiro/2018                    Ultima atualizacao: --/--/----
Dados referentes ao programa:
Frequencia: Sempre que for chamado
Objetivo  : Tem como objetivo retornar positivo caso a proposta deverá passar
            por análise automática ou posteriormente manual na Esteira de Crédito
Alteraçao :
..........................................................................*/
/* DECLARE */
-- Verificaçao de finalidade pré-aprovada nas tabelas
--  creppre (Cadastro de Parametros de Regras.)
--  e crapfin (Cadastro de finalidades)


BEGIN
  -- OU Esteira está em contingencia
  -- OU a Cooperativa nao Obriga Análise Automática
  IF  GENE0001.FN_PARAM_SISTEMA('CRED',pr_cdcooper,'CONTIGENCIA_ESTEIRA_DESC') = 1 OR
      GENE0001.FN_PARAM_SISTEMA('CRED',pr_cdcooper,'ANALISE_OBRIG_MOTOR_DESC') = 0 THEN
      pr_inobriga := 'N';
  ELSE
      pr_inobriga := 'S';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro inesperado na rotina que verifica o tipo de análise da proposta: '||SQLERRM;
END pc_obrigacao_analise_automatic;


PROCEDURE pc_verifica_regras_esteira (pr_cdcooper  IN craplim.cdcooper%TYPE,  -- Codigo da cooperativa
                                      pr_nrdconta  IN craplim.nrdconta%TYPE,  -- Numero da conta do cooperado
                                      pr_nrctrlim  IN craplim.nrctrlim%TYPE,  -- Numero do contrato de emprestimo
                                      pr_tpenvest  IN VARCHAR2 DEFAULT NULL,  -- Tipo de envio
                                      ---- OUT ----
                                      pr_cdcritic OUT NUMBER,                 -- Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS            -- Descricao da critica
/* ..........................................................................

    Programa : pc_verifica_regras_esteira
    Sistema  :
    Sigla    : CRED
    Autor    : Paulo Penteado GFT
    Data     : Fevereiro/2018.                   Ultima atualizacao: 16/02/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento para verificar as regras da esteira

    Alteração :

  ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_craplim is
      select lim.insitest
           , lim.cdopeapr
           , lim.insitapr
      from   craplim lim
      where  lim.cdcooper = pr_cdcooper
      and    lim.nrdconta = pr_nrdconta
      and    lim.nrctrlim = pr_nrctrlim;
    rw_craplim cr_craplim%ROWTYPE;

    vr_contige_este VARCHAR2(500);
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;

  BEGIN

    --> Verificar se a Esteira esta em contigencia para a cooperativa
    vr_contige_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                                  pr_cdcooper => pr_cdcooper,
                                                  pr_cdacesso => 'CONTIGENCIA_ESTEIRA_DESC');
    IF vr_contige_este IS NULL THEN
      vr_dscritic := 'Parametro CONTIGENCIA_ESTEIRA_DESC não encontrado.';
      RAISE vr_exc_erro;
    END IF;

    IF vr_contige_este = '1' THEN
      vr_dscritic := 'Atenção! ';--A aprovação da proposta deve ser feita pela tela CMAPRV.'; popd terminar essa frase
      RAISE vr_exc_erro;
    END IF;

    -- Para inclusão, alteração ou derivação
    IF nvl(pr_tpenvest,' ') IN ('I','A','D') THEN

      --> Buscar dados da proposta
      OPEN  cr_craplim;
      FETCH cr_craplim INTO rw_craplim;
      IF    cr_craplim%NOTFOUND THEN
            CLOSE cr_craplim;
            vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
            RAISE vr_exc_erro;
      END IF;

      -- Somente permitirá se ainda não enviada
      -- OU se foi Reprovada pelo Motor
      -- ou se houve Erro Conexão
      -- OU se foi enviada e recebemos a Derivação
      IF rw_craplim.insitest = 0
      OR (rw_craplim.insitest = 3 AND rw_craplim.insitapr = 2 AND rw_craplim.cdopeapr = 'MOTOR')
      OR (rw_craplim.insitest = 3 AND rw_craplim.insitapr = 6 AND pr_tpenvest = 'I')
      OR (rw_craplim.insitest = 3 AND rw_craplim.insitapr = 5) THEN
        -- Sair pois pode ser enviada
        RETURN;
      END IF;
      -- Não será possível enviar/reenviar para a Esteira
      vr_dscritic := 'A proposta não pode ser enviada para Análise de crédito, verifique a situação da proposta!';
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


PROCEDURE pc_incluir_proposta_est(pr_cdcooper  IN craplim.cdcooper%TYPE
                                 ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                 ,pr_cdorigem  IN INTEGER
                                 ,pr_nrdconta  IN craplim.nrdconta%TYPE
                                 ,pr_nrctrlim  IN craplim.nrctrlim%TYPE
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                 ,pr_nmarquiv  IN VARCHAR2
                                  ---- OUT ----
                                 ,pr_dsmensag OUT VARCHAR2
                                 ,pr_cdcritic OUT NUMBER
                                 ,pr_dscritic OUT VARCHAR2) IS
  /* ...........................................................................

    Programa : pc_incluir_proposta_est
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Março/2016.                   Ultima atualizacao: 13/07/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina responsavel por gerar a inclusao da proposta para a esteira
    Alteraçao :
                13/07/2017 - P337 - Ajustes para envio ao Motor - Marcos(Supero)

                15/12/2017 - P337 - SM - Ajustes no envio para retormar reinício
                             de fluxo (Marcos-Supero)
  ..........................................................................*/

  ----------- VARIAVEIS <-----------
  -- Tratamento de erros
  vr_cdcritic NUMBER := 0;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  vr_obj_proposta json := json();
  vr_obj_proposta_clob clob;

  vr_dsprotoc VARCHAR2(1000);
  vr_comprecu VARCHAR2(1000);

  -- Buscar informaçoes da Proposta
  CURSOR cr_craplim IS
    SELECT wpr.insitest, wpr.insitapr, wpr.cdopeapr, wpr.cdagenci,
           wpr.nrctaav1, wpr.nrctaav2,ass.inpessoa, wpr.dsprotoc,
           wpr.cddlinha, wpr.tpctrlim, wpr.rowid
       FROM craplim wpr, crapass ass
       WHERE wpr.cdcooper = ass.cdcooper
         AND wpr.nrdconta = ass.nrdconta
         AND wpr.cdcooper = pr_cdcooper
         AND wpr.nrdconta = pr_nrdconta
         AND wpr.nrctrlim = pr_nrctrlim;
  rw_craplim cr_craplim%ROWTYPE;

  -- Tipo Envio Esteira
  vr_tpenvest varchar2(1);

  -- Acionamentos de retorno
  cursor cr_aciona_retorno(pr_dsprotocolo varchar2) is
    select ac.dsconteudo_requisicao
    from   tbgen_webservice_aciona ac
    where  ac.cdcooper      = pr_cdcooper
    and    ac.nrdconta      = pr_nrdconta
    and    ac.nrctrprp      = pr_nrctrlim
    and    ac.dsprotocolo   = pr_dsprotocolo
    and    ac.tpacionamento = 2;
  -- Somente Retorno
  vr_dsconteudo_requisicao tbepr_acionamento.dsconteudo_requisicao%TYPE;

  -- Hora de Envio
  vr_hrenvest craplim.hrenvest%TYPE;
  -- Quantidade de segundos de Espera
  vr_qtsegund NUMBER;
  -- Analise finalizada
  vr_flganlok boolean := FALSE;

  -- Objetos para retorno das mensagens
  vr_obj     cecred.json := json();
  vr_obj_anl cecred.json := json();
  vr_obj_lst cecred.json_list := json_list();
  vr_obj_msg cecred.json := json();
  vr_destipo varchar2(1000);
  vr_desmens varchar2(4000);
  vr_dsmensag VARCHAR2(32767);
  vr_inobriga VARCHAR2(1);

  -- Variaveis para DEBUG
  vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
  vr_idaciona tbepr_acionamento.idacionamento%TYPE;

BEGIN

  -- Se o DEBUG estiver habilitado
  IF vr_flgdebug = 'S' THEN
    -- Gravar dados log acionamento
    pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                         pr_cdagenci              => pr_cdagenci,
                         pr_cdoperad              => pr_cdoperad,
                         pr_cdorigem              => pr_cdorigem,
                         pr_nrctrprp              => pr_nrctrlim,
                         pr_nrdconta              => pr_nrdconta,
                         pr_tpacionamento         => 0,  /* 0 - DEBUG */
                         pr_dsoperacao            => 'INICIO INCLUIR PROPOSTA',
                         pr_dsuriservico          => NULL,
                         pr_dtmvtolt              => pr_dtmvtolt,
                         pr_cdstatus_http         => 0,
                         pr_dsconteudo_requisicao => null,
                         pr_dsresposta_requisicao => null,
                         pr_idacionamento         => vr_idaciona,
                         pr_dscritic              => vr_dscritic);
    -- Sem tratamento de exceçao para DEBUG
    --IF TRIM(vr_dscritic) IS NOT NULL THEN
    --  RAISE vr_exc_erro;
    --END IF;
  END IF;

  -- Buscar informaçoes da proposta
  OPEN cr_craplim;
  FETCH cr_craplim INTO rw_craplim;
  CLOSE cr_craplim;

  -- Verificar se a Cooperativa/Linha/Finalidade Obriga a passagem pelo Motor
  pc_obrigacao_analise_automatic(pr_cdcooper => pr_cdcooper
                                ,pr_inobriga => vr_inobriga
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

  -- Se Obrigatorio e ainda nao Enviada ou Enviada mas com Erro Conexao
  IF vr_inobriga = 'S' AND (rw_craplim.insitest = 0 OR rw_craplim.insitapr = 6) THEN

    -- Gerar informaçoes no padrao JSON da proposta de emprestimo
    /*popd criar uma para lim?*/ESTE0002.pc_gera_json_analise(pr_cdcooper  => pr_cdcooper,         -- Codigo da cooperativa
                                  pr_cdagenci  => rw_craplim.cdagenci, -- Agencia da Proposta
                                  pr_nrdconta  => pr_nrdconta,         -- Numero da conta do cooperado
                                  --pr_nrctrlim  => pr_nrctrlim,       -- Numero da proposta de emprestimo
                                  pr_nrctremp => pr_nrctrlim,       -- Numero da proposta de emprestimo
                                  pr_nrctaav1  => rw_craplim.nrctaav1, -- Avalista 01
                                  pr_nrctaav2  => rw_craplim.nrctaav2, -- Avalista 02
                                  ---- OUT ----
                                  pr_dsjsonan  => vr_obj_proposta,     -- Retorno do clob em modelo json das informaçoes
                                  pr_cdcritic  => vr_cdcritic,         -- Codigo da critica
                                  pr_dscritic  => vr_dscritic);        -- Descricao da critica

    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Efetuar montagem do nome do Fluxo de Análise Automatica conforme o tipo de pessoa da Proposta
    IF rw_craplim.inpessoa = 1 THEN
      vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
                                                                ,pr_cdcooper
                                                                ,'REGRA_ANL_MOTOR_IBRA_PF')||'/start';
    ELSE
      vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
                                                                ,pr_cdcooper
                                                                ,'REGRA_ANL_MOTOR_IBRA_PJ')||'/start';
    END IF;


    -- Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_proposta,vr_obj_proposta_clob);

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      -- Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                           pr_cdagenci              => pr_cdagenci,
                           pr_cdoperad              => pr_cdoperad,
                           pr_cdorigem              => pr_cdorigem,
                           pr_nrctrprp              => pr_nrctrlim,
                           pr_nrdconta              => pr_nrdconta,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */
                           pr_dsoperacao            => 'ANTES ENVIAR PROPOSTA',
                           pr_dsuriservico          => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                           pr_dsresposta_requisicao => null,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceçao para DEBUG
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;

    -- Enviar dados para Análise Automática Esteira (Motor)
    pc_enviar_esteira(pr_cdcooper    => pr_cdcooper,          -- Codigo da cooperativa
                      pr_cdagenci    => pr_cdagenci,          -- Codigo da agencia
                      pr_cdoperad    => pr_cdoperad,          -- codigo do operador
                      pr_cdorigem    => pr_cdorigem,          -- Origem da operacao
                      pr_nrdconta    => pr_nrdconta,          -- Numero da conta do cooperado
                      pr_nrctrlim    => pr_nrctrlim,          -- Numero da proposta de emprestimo
                      pr_dtmvtolt    => pr_dtmvtolt,          -- Data do movimento
                      pr_comprecu    => vr_comprecu,          -- Complemento do recuros da URI
                      pr_dsmetodo    => 'POST',               -- Descricao do metodo
                      pr_conteudo    => vr_obj_proposta_clob,  -- Conteudo no Json para comunicacao
                      pr_dsoperacao  => 'ENVIO DA PROPOSTA PARA ANALISE AUTOMATICA DE CREDITO',  -- Operaçao efetuada
                      pr_tpenvest    => 'M',                  -- Tipo de envio (Motor)
                      pr_dsprotocolo => vr_dsprotoc,           -- Protocolo gerado
                      pr_dscritic    => vr_dscritic);

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_obj_proposta_clob);
    dbms_lob.freetemporary(vr_obj_proposta_clob);

    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Atualizar a proposta
    vr_hrenvest := to_char(SYSDATE,'sssss');
    BEGIN
      UPDATE craplim lim
         SET lim.insitest = 1, --  1 – Enviada para Analise
             lim.DTENVEST = trunc(SYSDATE),
             lim.HRENVEST = vr_hrenvest,
             lim.cdopeste = pr_cdoperad,
             lim.dsprotoc = nvl(vr_dsprotoc,' '),
             lim.insitapr = 0,
             lim.cdopeapr = NULL,
             lim.dtaprova = NULL,
             lim.hraprova = 0
       WHERE lim.rowid = rw_craplim.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da Análise Automática de Crédito: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Efetuar gravaçao
    COMMIT;

    -- Buscar a quantidade de segundos de espera pela Análise Automática
    vr_qtsegund := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'TIME_RESP_MOTOR_DESC'),30);

    -- Efetuar laço para esperarmos (N) segundos ou o termino da analise recebido via POST
    WHILE NOT vr_flganlok AND to_number(to_char(sysdate,'sssss')) - vr_hrenvest < vr_qtsegund LOOP

      -- Aguardar 0.5 segundo para evitar sobrecarga de processador
      sys.dbms_lock.sleep(0.5);

      -- Verificar se a analise jah finalizou
      OPEN cr_craplim;
      FETCH cr_craplim INTO rw_craplim;
      CLOSE cr_craplim;

      -- Se a proposta mudou de situaçao Esteira
      IF rw_craplim.insitest <> 1 THEN
        -- Indica que terminou a analise
        vr_flganlok := true;
      END IF;

    END LOOP;

    -- Se chegarmos neste ponto e a analise nao voltou OK signifca que houve timeout
    IF NOT vr_flganlok THEN
      -- Entao acionaremos a rotina que solicita via GET o termino da análise
      -- e caso a mesma ainda nao tenha terminado, a proposta será salva como Expirada
      pc_solicita_retorno_analise(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctrlim => pr_nrctrlim
                                 ,pr_dsprotoc => vr_dsprotoc);
    END IF;

    -- Reconsultar a situaçao esteira e parecer para retorno
    OPEN  cr_craplim;
    FETCH cr_craplim INTO rw_craplim;
    CLOSE cr_craplim;

    -- Se houve expiraçao
    IF rw_craplim.insitest = 1 THEN
      pr_dsmensag := 'Proposta permanece em <b>Processamento</b>...';
    ELSIF rw_craplim.insitest = 2 THEN
      pr_dsmensag := '<b>Avaliaçao Manual</b>';
    ELSIF rw_craplim.insitest = 3 THEN
      -- Conforme tipo de aprovacao
      IF rw_craplim.insitapr = 1 THEN
        pr_dsmensag := '<b>Aprovada</b>';
      ELSIF rw_craplim.insitapr = 2 THEN
        pr_dsmensag := '<b>Rejeitada</b>';
      ELSIF rw_craplim.insitapr IN(0,6) THEN
        pr_dsmensag := '<b>Erro</b> motor de crédito';
      ELSIF rw_craplim.insitapr = 3 THEN
        pr_dsmensag := '<b>Com Restricoes</b>';
      ELSIF rw_craplim.insitapr = 4 THEN
        pr_dsmensag := '<b>Refazer Proposta</b>';
      ELSIF rw_craplim.insitapr = 5 THEN
        pr_dsmensag := '<b>Avaliaçao Manual</b>';
      END IF;
    ELSIF rw_craplim.insitest = 4 THEN
      pr_dsmensag := '<b>Expirada</b> apos '||vr_qtsegund||' segundos de espera.';
    ELSE
      pr_dsmensag := '<b>Finalizada</b> com situaçao indefinida!';
    END IF;

    -- Gerar mensagem padrao:
    pr_dsmensag := 'Resultado da Avaliaçao: '||pr_dsmensag;

    -- Se houver protocolo e a analise foi encerrada ou derivada
    IF vr_dsprotoc IS NOT NULL AND rw_craplim.insitest in(2,3) THEN
      -- Buscar os detalhes do acionamento de retorno
      OPEN cr_aciona_retorno(vr_dsprotoc);
      FETCH cr_aciona_retorno
       INTO vr_dsconteudo_requisicao;
      -- Somente se encontrou
      IF cr_aciona_retorno%FOUND THEN
        CLOSE cr_aciona_retorno;
        -- Processar as mensagens para adicionar ao retorno
        BEGIN
          -- Efetuar cast para JSON
          vr_obj := json(vr_dsconteudo_requisicao);
          -- Se existe o objeto de analise
          IF vr_obj.exist('analises') THEN
            vr_obj_anl := json(vr_obj.get('analises').to_char());
            -- Se existe a lista de mensagens
            IF vr_obj_anl.exist('mensagensDeAnalise') THEN
              vr_obj_lst := json_list(vr_obj_anl.get('mensagensDeAnalise').to_char());
              -- Para cada mensagem
              for vr_idx in 1..vr_obj_lst.count() loop
                BEGIN
                  vr_obj_msg := json( vr_obj_lst.get(vr_idx));
                  -- Se encontrar o atributo texto e tipo
                  if vr_obj_msg.exist('texto') AND vr_obj_msg.exist('tipo') THEN
                    vr_desmens := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_msg.get('texto').to_char(),'"'),'"'),'\u','\')));
                    vr_destipo := REPLACE(RTRIM(LTRIM(vr_obj_msg.get('tipo').to_char(),'"'),'"'),'ERRO','REPROVAR');
                  end if;
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
            -- Ignorar se o conteudo nao for JSON nao conseguiremos ler as mensagens
            null;
        END;
      ELSE
        CLOSE cr_aciona_retorno;
      END IF;

      -- Se nao encontrou mensagem
      IF vr_dsmensag IS NULL THEN
        -- Usar mensagem padrao
        vr_dsmensag := '<br>Obs: para acessar detalhes da decisao, acionar <b>[Detalhes Proposta]</b>';
      ELSE
        -- Gerar texto padrao
        vr_dsmensag := '<br>Detalhes da decisao:<br>###'|| vr_dsmensag;
      END IF;
      -- Concatenar ao retorno a mensagem montada
      pr_dsmensag := pr_dsmensag ||vr_dsmensag;
    END IF;

    -- Commitar o encerramento da rotina
    COMMIT;

  ELSE

    -- Gerar informaçoes no padrao JSON da proposta de emprestimo
    /*popd migrar a pc_gera_json_proposta para desconto de títulos
    pc_gera_json_proposta(pr_cdcooper  => pr_cdcooper,  -- Codigo da cooperativa
                          pr_cdagenci  => pr_cdagenci,  -- Codigo da agencia
                          pr_cdoperad  => pr_cdoperad,  -- codigo do operado
                          pr_cdorigem  => pr_cdorigem,  -- Origem da operacao
                          pr_nrdconta  => pr_nrdconta,  -- Numero da conta do cooperado
                          cpr_nrctrlim  => cpr_nrctrlim,  -- Numero da proposta de emprestimo
                          pr_nmarquiv  => pr_nmarquiv,  -- Diretorio e nome do arquivo pdf da proposta de emprestimo
                          ---- OUT ----
                          pr_proposta  => vr_obj_proposta,  -- Retorno do clob em modelo json da proposta de emprestimo
                          pr_cdcritic  => vr_cdcritic,  -- Codigo da critica
                          pr_dscritic  => vr_dscritic); -- Descricao da critica*/

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Se origem veio do Motor/Esteira
    IF pr_cdorigem = 9 THEN
      -- É uma derivaçao
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
      -- Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                           pr_cdagenci              => pr_cdagenci,
                           pr_cdoperad              => pr_cdoperad,
                           pr_cdorigem              => pr_cdorigem,
                           pr_nrctrprp              => pr_nrctrlim,
                           pr_nrdconta              => pr_nrdconta,
                           pr_tpacionamento         => 0,  -- 0 - DEBUG
                           pr_dsoperacao            => 'ANTES ENVIAR PROPOSTA',
                           pr_dsuriservico          => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                           pr_dsresposta_requisicao => null,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceçao para DEBUG
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;

    -- Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,          -- Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,          -- Codigo da agencia
                        pr_cdoperad    => pr_cdoperad,          -- codigo do operador
                        pr_cdorigem    => pr_cdorigem,          -- Origem da operacao
                        pr_nrdconta    => pr_nrdconta,          -- Numero da conta do cooperado
                        pr_nrctrlim    => pr_nrctrlim,          -- Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,          -- Data do movimento
                        pr_comprecu    => NULL,                 -- Complemento do recuros da URI
                        pr_dsmetodo    => 'POST',               -- Descricao do metodo
                        pr_conteudo    => vr_obj_proposta_clob, -- Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DA PROPOSTA PARA ANALISE DE CREDITO',   -- Operacao realizada
                        pr_tpenvest    => vr_tpenvest,          -- Tipo de envio
                        pr_dsprotocolo => vr_dsprotoc,
                        pr_dscritic    => vr_dscritic);

    -- Caso tenhamos recebido critica de Proposta jah existente na Esteira
    IF lower(vr_dscritic) LIKE '%proposta%ja existente na esteira%' THEN

      -- Tentaremos enviar alteraçao com reinício de fluxo para a Esteira
      pc_alterar_proposta_est(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_cdoperad => pr_cdoperad
                             ,pr_cdorigem => pr_cdorigem
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctrlim => pr_nrctrlim
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_flreiflx => 1
                             ,pr_nmarquiv => pr_nmarquiv
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

    vr_hrenvest := to_char(SYSDATE,'sssss');

    -- Atualizar proposta
    BEGIN
      UPDATE craplim wpr
         SET wpr.insitest = 2, --  2 – Enviada para Analise Manual
             wpr.dtenvest = trunc(SYSDATE),
             wpr.hrenvest = vr_hrenvest,
             wpr.cdopeste = pr_cdoperad,
             wpr.dsprotoc = nvl(vr_dsprotoc,' '),
             wpr.insitapr = 0,
             wpr.cdopeapr = NULL,
             wpr.dtaprova = NULL,
             wpr.hraprova = 0
       WHERE wpr.rowid = rw_craplim.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio para Análise de Crédito: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    pr_dsmensag := 'Proposta Enviada para Analise Manual de Credito.';

    -- Efetuar gravaçao
    COMMIT;

  END IF;

  -- Se o DEBUG estiver habilitado
  IF vr_flgdebug = 'S' THEN
    -- Gravar dados log acionamento
    pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                         pr_cdagenci              => pr_cdagenci,
                         pr_cdoperad              => pr_cdoperad,
                         pr_cdorigem              => pr_cdorigem,
                         pr_nrctrprp              => pr_nrctrlim,
                         pr_nrdconta              => pr_nrdconta,
                         pr_tpacionamento         => 0,  -- 0 - DEBUG
                         pr_dsoperacao            => 'TERMINO INCLUIR PROPOSTA',
                         pr_dsuriservico          => NULL,
                         pr_dtmvtolt              => pr_dtmvtolt,
                         pr_cdstatus_http         => 0,
                         pr_dsconteudo_requisicao => null,
                         pr_dsresposta_requisicao => null,
                         pr_idacionamento         => vr_idaciona,
                         pr_dscritic              => vr_dscritic);
    -- Sem tratamento de exceçao para DEBUG
    --IF TRIM(vr_dscritic) IS NOT NULL THEN
    --  RAISE vr_exc_erro;
    --END IF;
  END IF;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN

    -- Buscar critica
    IF nvl(vr_cdcritic,0) > 0 AND
      TRIM(vr_dscritic) IS NULL THEN
      -- Busca descricao
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;

    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Nao foi possivel realizar inclusao da proposta de Análise de Crédito: '||SQLERRM;
END pc_incluir_proposta_est;

  --> Rotina responsavel por gerar a alteracao da proposta para a esteira
  procedure pc_alterar_proposta_est(pr_cdcooper  in craplim.cdcooper%type  --> Codigo da cooperativa
                                   ,pr_cdagenci  in crapage.cdagenci%type  --> Codigo da agencia
                                   ,pr_cdoperad  in crapope.cdoperad%type  --> codigo do operador
                                   ,pr_cdorigem  in integer                --> Origem da operacao
                                   ,pr_nrdconta  in craplim.nrdconta%type  --> Numero da conta do cooperado
                                   ,pr_nrctrlim  in craplim.nrctrlim%type  --> Numero da proposta de emprestimo
                                   ,pr_dtmvtolt  in crapdat.dtmvtolt%type  --> Data do movimento
                                   ,pr_flreiflx  in integer                --> Indica se deve reiniciar o fluxo de aprovacao na esteira
                                   ,pr_nmarquiv  in varchar2               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                   ---- OUT ----
                                   ,pr_cdcritic out number                 --> Codigo da critica
                                   ,pr_dscritic out varchar2               --> Descricao da critica
                                   ) is
    /* ..........................................................................

      Programa : pc_alterar_proposta_est
      Sistema  :
      Sigla    : CRED
      Autor    : Paulo Penteado (GFT)
      Data     : Fevereiro/2018.                   Ultima atualizacao: 17/02/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a alteracao da proposta para a esteira
      Alteração :

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

    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbepr_acionamento.idacionamento%TYPE;

  BEGIN

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                           pr_cdagenci              => pr_cdagenci,
                           pr_cdoperad              => pr_cdoperad,
                           pr_cdorigem              => pr_cdorigem,
                           pr_nrctrprp              => pr_nrctrlim,
                           pr_nrdconta              => pr_nrdconta,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */
                           pr_dsoperacao            => 'INICIO ALTERAR PROPOSTA',
                           pr_dsuriservico          => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;

    --> Gerar informações no padrao JSON da proposta de emprestimo
    /*popd migrar a pc_gera_json_proposta para desconto de títulos
    pc_gera_json_proposta(pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa
                          pr_cdagenci  => pr_cdagenci,  --> Codigo da agencia
                          pr_cdoperad  => pr_cdoperad,  --> codigo do operado
                          pr_cdorigem  => pr_cdorigem,  --> Origem da operacao
                          pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                          pr_nrctremp  => pr_nrctremp,  --> Numero da proposta de emprestimo
                          pr_nmarquiv  => pr_nmarquiv,  --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                          ---- OUT ----
                          pr_proposta  => vr_obj_proposta,  --> Retorno do clob em modelo json da proposta de emprestimo
                          pr_cdcritic  => vr_cdcritic,  --> Codigo da critica
                          pr_dscritic  => vr_dscritic); --> Descricao da critica*/

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

    -- Incluir objeto proposta
    vr_obj_alter.put('dadosAtualizados'      ,vr_obj_proposta);
    vr_obj_alter.put('operadorAlteracaoLogin',lower(pr_cdoperad));
    vr_obj_alter.put('operadorAlteracaoNome' ,rw_crapope.nmoperad) ;
    vr_obj_alter.put('dataHora'              ,fn_DataTempo_ibra(SYSDATE)) ;
    vr_obj_alter.put('reiniciaFluxo'         ,(pr_flreiflx = 1) ) ;

    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'   , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'            , pr_cdagenci);
    vr_obj_alter.put('operadorAlteracaoPA'      , vr_obj_agencia);

    -- Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_alter,vr_obj_proposta_clob);

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                           pr_cdagenci              => pr_cdagenci,
                           pr_cdoperad              => pr_cdoperad,
                           pr_cdorigem              => pr_cdorigem,
                           pr_nrctrprp              => pr_nrctrlim,
                           pr_nrdconta              => pr_nrdconta,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */
                           pr_dsoperacao            => 'ANTES ALTERAR PROPOSTA',
                           pr_dsuriservico          => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                           pr_dsresposta_requisicao => null,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;

    --> Enviar dados para Esteira
    pc_enviar_esteira(pr_cdcooper    => pr_cdcooper
                     ,pr_cdagenci    => pr_cdagenci
                     ,pr_cdoperad    => pr_cdoperad
                     ,pr_cdorigem    => pr_cdorigem
                     ,pr_nrdconta    => pr_nrdconta
                     ,pr_nrctrlim    => pr_nrctrlim
                     ,pr_dtmvtolt    => pr_dtmvtolt
                     ,pr_comprecu    => null
                     ,pr_dsmetodo    => 'PUT'
                     ,pr_conteudo    => vr_obj_proposta_clob
                     ,pr_dsoperacao  => 'REENVIO DA PROPOSTA PARA ANALISE DE CREDITO'
                     ,pr_dsprotocolo => vr_dsprotocolo
                     ,pr_dscritic    => vr_dscritic);

    -- Se não houve erro
    IF vr_dscritic IS NULL THEN

    --> Atualizar proposta
    begin
      update craplim lim
      set    lim.insitest = 2 -->  2 – Reenviado para Analise
            ,lim.dtenvest = trunc(sysdate)
            ,lim.hrenvest = to_char(sysdate,'sssss')
            ,lim.cdopeste = pr_cdoperad
            ,lim.dsprotoc = nvl(vr_dsprotocolo,' ')
            ,lim.insitapr = 0
            ,lim.cdopeapr = null
            ,lim.dtaprova = null
            ,lim.hraprova = 0
      where  lim.cdcooper = pr_cdcooper
      and    lim.nrdconta = pr_nrdconta
      and    lim.nrctrlim = pr_nrctrlim;
    exception
      when others then
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da Analise de Credito: '||sqlerrm;
    end;


    -- Caso tenhamos recebido critica de Proposta jah existente na Esteira
    ELSIF lower(vr_dscritic) LIKE '%proposta nao encontrada%' THEN

      -- Tentaremos enviar inclusão novamente na Esteira
      pc_incluir_proposta_est(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_cdoperad => pr_cdoperad
                             ,pr_cdorigem => pr_cdorigem
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctrlim => pr_nrctrlim
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_nmarquiv => NULL
                             ,pr_dsmensag => vr_dsmensag
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
    END IF;

    -- verificar se retornou critica
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;


    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                           pr_cdagenci              => pr_cdagenci,
                           pr_cdoperad              => pr_cdoperad,
                           pr_cdorigem              => pr_cdorigem,
                           pr_nrctrprp              => pr_nrctrlim,
                           pr_nrdconta              => pr_nrdconta,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */
                           pr_dsoperacao            => 'TERMINO ALTERAR PROPOSTA',
                           pr_dsuriservico          => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
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

 -- Rotina responsavel em enviar dos dados para a esteira
  PROCEDURE pc_enviar_esteira (pr_cdcooper    IN crapcop.cdcooper%type  --> Codigo da cooperativa
                              ,pr_cdagenci    IN crapage.cdagenci%type  --> Codigo da agencia
                              ,pr_cdoperad    IN crapope.cdoperad%type  --> codigo do operador
                              ,pr_cdorigem    IN integer                --> Origem da operacao
                              ,pr_nrdconta    IN craplim.nrdconta%type  --> Numero da conta do cooperado
                              ,pr_nrctrlim    IN craplim.nrctrlim%type  --> Numero da proposta de emprestimo
                              ,pr_dtmvtolt    IN crapdat.dtmvtolt%type  --> Data do movimento
                              ,pr_comprecu    IN varchar2               --> Complemento do recuros da URI
                              ,pr_dsmetodo    IN varchar2               --> Descricao do metodo
                              ,pr_conteudo    IN clob                   --> Conteudo no Json para comunicacao
                              ,pr_dsoperacao  IN varchar2               --> Operacao realizada
                              ,pr_tpenvest    IN VARCHAR2 DEFAULT null  --> Tipo de envio, I-Inclusao C - Consultar(Get)
                              ,pr_dsprotocolo OUT varchar2              --> Protocolo retornado na requisição
                              ,pr_dscritic    OUT VARCHAR2  ) IS

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

    vr_idacionamento  tbepr_acionamento.idacionamento%TYPE;

    vr_tab_split     gene0002.typ_split;
    vr_idx_split     VARCHAR2(1000);

  BEGIN

    -- Carregar parametros para a comunicacao com a esteira
    pc_carrega_param_ibra(pr_cdcooper     => pr_cdcooper
                         ,pr_nrdconta     => pr_nrdconta
                         ,pr_nrctrlim     => pr_nrctrlim
                         ,pr_tpenvest     => pr_tpenvest
                         ,pr_host_esteira => vr_host_esteira
                         ,pr_recurso_este => vr_recurso_este
                         ,pr_dsdirlog     => vr_dsdirlog
                         ,pr_autori_este  => vr_autori_este
                         ,pr_chave_aplica => vr_chave_aplica
                         ,pr_dscritic     => vr_dscritic);

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
      vr_request.headers('Reply-To') := gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_MOTOR_DEVOLUC');
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
    pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                         pr_cdagenci              => pr_cdagenci,
                         pr_cdoperad              => pr_cdoperad,
                         pr_cdorigem              => pr_cdorigem,
                         pr_nrctrprp              => pr_nrctrlim,
                         pr_nrdconta              => pr_nrdconta,
                         pr_tpacionamento         => 1,  /* 1 - Envio, 2 – Retorno */
                         pr_dsoperacao            => pr_dsoperacao,
                         pr_dsuriservico          => vr_host_esteira||vr_recurso_este||pr_comprecu,
                         pr_dtmvtolt              => pr_dtmvtolt,
                         pr_cdstatus_http         => vr_response.status_code,
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
          vr_dscritic_aux := 'Nao foi possivel enviar proposta para Análise de Credito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu IS NULL THEN
          vr_dscritic_aux := 'Nao foi possivel reenviar a proposta para Análise de Crédito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/numeroProposta' THEN
          vr_dscritic_aux := 'Nao foi possivel alterar numero da proposta da Análise de Crédito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/cancelar' THEN
          vr_dscritic_aux := 'Nao foi possivel excluir a proposta da Análise de Crédito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/efetivar' THEN
          vr_dscritic_aux := 'Nao foi possivel enviar a efetivacao da proposta da Análise de Crédito.';
        WHEN pr_dsmetodo = 'GET' THEN
          vr_dscritic_aux := 'Nao foi possivel solicitar o retorno da Análise Automática de Crédito.';
        ELSE
          vr_dscritic_aux := 'Nao foi possivel enviar informacoes para Análise de Crédito.';
        END CASE;

      IF vr_response.status_code = 400 THEN
        pr_dscritic := este0001.fn_retorna_critica('{"Content":'||vr_response.content||'}');

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

    END IF;

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

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel enviar proposta para Análise de Crédito: '||SQLERRM;
  END pc_enviar_esteira;

  -- Rotina para solicitar analises não respondidas via POST ou solicitar a proposta enviada
   PROCEDURE pc_solicita_retorno_analise(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_nrdconta IN craplim.nrdconta%TYPE
                                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                                       ,pr_dsprotoc IN craplim.dsprotoc%TYPE) IS
    /* .........................................................................

    Programa : pc_solicita_retorno_analise
    Sistema  :
    Sigla    : CRED
    Autor    : Paulo Penteado (GFT)
    Data     : Fevereiro/2018                    Ultima atualizacao: 17/02/2018

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
    vr_qtsegund crapprm.dsvlrprm%TYPE;
  vr_host_esteira  VARCHAR2(4000);
  vr_recurso_este  VARCHAR2(4000);
  vr_dsdirlog      VARCHAR2(500);
  vr_chave_aplica  VARCHAR2(500);
  vr_autori_este   VARCHAR2(500);
    vr_idacionamento tbepr_acionamento.idacionamento%TYPE;
   vr_nrdrowid ROWID;
    vr_dsresana VARCHAR2(100);
  vr_dssitret VARCHAR2(100);
    vr_indrisco VARCHAR2(100);
    vr_nrnotrat VARCHAR2(100);
    vr_nrinfcad VARCHAR2(100);
    vr_nrliquid VARCHAR2(100);
    vr_nrgarope VARCHAR2(100);
    vr_nrparlvr VARCHAR2(100);
    vr_nrperger VARCHAR2(100);
  vr_datscore VARCHAR2(100);
  vr_desscore VARCHAR2(100);
  vr_xmllog   VARCHAR2(4000);
    vr_retxml   xmltype;
  vr_nmdcampo VARCHAR2(100);

   vr_dsprotoc crawepr.dsprotoc%TYPE;

  -- Objeto json da proposta
  vr_obj_proposta json := json();
    vr_obj_retorno json := json();
  vr_obj_indicadores json := json();
  vr_request  json0001.typ_http_request;
  vr_response json0001.typ_http_response;

   -- Cursores
   rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  -- Cooperativas com análise automática obrigatória
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE cdcooper = NVL(pr_cdcooper,cdcooper)
       AND flgativo = 1
       AND GENE0001.FN_PARAM_SISTEMA('CRED',cdcooper,'ANALISE_OBRIG_MOTOR_DESC') = 1;

    -- Proposta sem retorno
    CURSOR cr_craplim is
    select lim.cdcooper
          ,lim.nrdconta
          ,lim.nrctrlim
          ,lim.dsprotoc
          ,lim.dtenvest
          ,lim.hrenvest
          ,lim.insitest
          ,lim.cdagenci
          ,lim.insitapr
          ,null dtenvmot -- popd, verificar se temos que criar o campo data e hora de envio ao motor ou usar uma tabela crawlim igual ao emprestimo crapwepr
          ,null hrenvmot -- popd, verificar se temos que criar o campo data e hora de envio ao motor ou usar uma tabela crawlim igual ao emprestimo crapwepr
          ,lim.rowid
    from   craplim lim
    WHERE  lim.cdcooper = pr_cdcooper
    AND    lim.nrdconta = pr_nrdconta
    AND    lim.nrctrlim = pr_nrctrlim
    AND    lim.dsprotoc = pr_dsprotoc
    AND    lim.insitest = 1;-- Enviadas para Analise Automática

    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100);
    vr_idaciona tbepr_acionamento.idacionamento%TYPE;

  BEGIN
    -- Buscar todas as Coops com obrigatoriedade de Análise Automática
  FOR rw_crapcop IN cr_crapcop LOOP

    -- Buscar o tempo máximo de espera em segundos pela analise do motor
      vr_qtsegund := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'TIME_RESP_MOTOR_DESC');

      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
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

      -- Desde que não estejamos com processo em execução ou o dia util
      IF rw_crapdat.inproces = 1 /*AND trunc(SYSDATE) = rw_crapdat.dtmvtolt */ THEN

        -- Buscar DEBUG ativo ou não
        vr_flgdebug := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'DEBUG_MOTOR_IBRA');

        -- Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,
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
                               pr_idacionamento         => vr_idaciona,
                               pr_dscritic              => vr_dscritic);
          -- Sem tratamento de exceção para DEBUG
          --IF TRIM(vr_dscritic) IS NOT NULL THEN
          --  RAISE vr_exc_erro;
          --END IF;
        END IF;

        -- Buscar todas as propostas enviadas para o motor e que ainda não tenham retorno
        FOR rw_craplim IN cr_craplim LOOP

          -- Capturar o protocolo do contrato para apresentar na crítica caso ocorra algum erro
          vr_dsprotoc := rw_craplim.dsprotoc;
          -- Carregar parametros para a comunicacao com a esteira
          pc_carrega_param_ibra(pr_cdcooper      => rw_craplim.cdcooper -- Codigo da cooperativa
                               ,pr_nrdconta      => rw_craplim.nrdconta -- Numero da conta do cooperado
                               ,pr_nrctrlim      => rw_craplim.nrctrlim -- Numero da proposta de emprestimo
                               ,pr_tpenvest      => 'M'                 -- Tipo de envio M - Motor
                               ,pr_host_esteira  => vr_host_esteira     -- Host da esteira
                               ,pr_recurso_este  => vr_recurso_este     -- URI da esteira
                               ,pr_dsdirlog      => vr_dsdirlog         -- Diretorio de log dos arquivos
                               ,pr_autori_este   => vr_autori_este      -- Authorization
                               ,pr_chave_aplica  => vr_chave_aplica     -- Chave de acesso
                               ,pr_dscritic      => vr_dscritic    );
          -- Se retornou crítica
          IF trim(vr_dscritic)  IS NOT NULL THEN
            -- Levantar exceção
            RAISE vr_exc_erro;
          END IF;

          vr_recurso_este := vr_recurso_este||'/instance/'||rw_craplim.dsprotoc;

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
            pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,
                                 pr_cdagenci              => rw_craplim.cdagenci,
                                 pr_cdoperad              => 'MOTOR',
                                 pr_cdorigem              => 5,
                                 pr_nrctrprp              => rw_craplim.nrctrlim,
                                 pr_nrdconta              => rw_craplim.nrdconta,
                                 pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                 pr_dsoperacao            => 'ANTES SOLICITA RETORNOS',
                                 pr_dsuriservico          => NULL,
                                 pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                 pr_cdstatus_http         => 0,
                                 pr_dsconteudo_requisicao => null,
                                 pr_dsresposta_requisicao => null,
                                 pr_idacionamento         => vr_idaciona,
                                 pr_dscritic              => vr_dscritic);
            -- Sem tratamento de exceção para DEBUG
            --IF TRIM(vr_dscritic) IS NOT NULL THEN
            --  RAISE vr_exc_erro;
            --END IF;
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

          --> Gravar dados log acionamento
          pc_grava_acionamento(pr_cdcooper              => rw_craplim.cdcooper,
                               pr_cdagenci              => rw_craplim.cdagenci,
                               pr_cdoperad              => 'MOTOR',
                               pr_cdorigem              => 5, /*Ayllos*/
                               pr_nrctrprp              => rw_craplim.nrctrlim,
                               pr_nrdconta              => rw_craplim.nrdconta,
                               pr_tpacionamento         => 2,  /* 1 - Envio, 2 – Retorno */
                               pr_dsoperacao            => 'RETORNO ANALISE AUTOMATICA DE CREDITO - '||vr_dssitret,
                               pr_dsuriservico          => vr_host_esteira||vr_recurso_este,
                               pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                               pr_cdstatus_http         => vr_response.status_code,
                               pr_dsconteudo_requisicao => vr_response.content,
                               pr_dsresposta_requisicao => null,
                               pr_dsprotocolo           => rw_craplim.dsprotoc,
                               pr_idacionamento         => vr_idacionamento,
                               pr_dscritic              => vr_dscritic);

          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          IF vr_response.status_code NOT IN(200,204,429) THEN
            vr_dscritic := 'Não foi possivel consultar informações da Analise de Credito, '||
                           'favor entrar em contato com a equipe responsavel.  '||
                           '(Cod:'||vr_response.status_code||')';
            RAISE vr_exc_erro;
          END IF;

          -- Se recebemos o código diferente de 200
          IF vr_response.status_code != 200 THEN
            -- Checar expiração
            IF trunc(SYSDATE) > rw_craplim.dtenvmot
            OR to_number(to_char(SYSDATE, 'sssss')) - rw_craplim.hrenvmot > vr_qtsegund THEN
              BEGIN
                UPDATE craplim lim
                   SET lim.insitest = 3 --> Analise Finalizada
                      ,lim.insitapr = 6 --> Erro na análise
                 WHERE lim.rowid = rw_craplim.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro na expiracao da analise automatica: '||sqlerrm;
                  RAISE vr_exc_erro;
              END;

              -- Gerar informações do log
              GENE0001.pc_gera_log(pr_cdcooper => rw_craplim.cdcooper
                                  ,pr_cdoperad => 'MOTOR'
                                  ,pr_dscritic => ' '
                                  ,pr_dsorigem => 'AYLLOS'
                                  ,pr_dstransa => 'Expiracao da Analise Automatica'
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1 --> FALSE
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => 'ESTEIRA'
                                  ,pr_nrdconta => rw_craplim.nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);

              -- Log de item
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'insitest'
                                       ,pr_dsdadant => rw_craplim.insitest
                                       ,pr_dsdadatu => 3);
              -- Log de item
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'insitapr'
                                       ,pr_dsdadant => rw_craplim.insitapr
                                       ,pr_dsdadatu => 5);
            END IF;

          ELSE

            -- Buscar IndicadoresCliente
            IF vr_obj_retorno.exist('indicadoresGeradosRegra') THEN

              vr_obj_indicadores := json(vr_obj_retorno.get('indicadoresGeradosRegra'));

              -- Nivel Risco Calculado --
              IF vr_obj_indicadores.exist('nivelRisco') THEN
                vr_indrisco := ltrim(rtrim(vr_obj_indicadores.get('nivelRisco').to_char(),'"'),'"');
              END IF;

              -- Rating Calculado --
              IF vr_obj_indicadores.exist('notaRating') THEN
                vr_nrnotrat := ltrim(rtrim(vr_obj_indicadores.get('notaRating').to_char(),'"'),'"');
              END IF;

              -- Informação Cadastral --
              IF vr_obj_indicadores.exist('informacaoCadastral') THEN
                vr_nrinfcad := ltrim(rtrim(vr_obj_indicadores.get('informacaoCadastral').to_char(),'"'),'"');
              END IF;

              -- Liquidez --
              IF vr_obj_indicadores.exist('liquidez') THEN
                vr_nrliquid := ltrim(rtrim(vr_obj_indicadores.get('liquidez').to_char(),'"'),'"');
              END IF;

              -- Garantia --
              IF vr_obj_indicadores.exist('garantia') THEN
                vr_nrgarope := ltrim(rtrim(vr_obj_indicadores.get('garantia').to_char(),'"'),'"');
              END IF;

              -- Patrimônio Pessoal Livre --
              IF vr_obj_indicadores.exist('patrimonioPessoalLivre') THEN
                vr_nrparlvr := ltrim(rtrim(vr_obj_indicadores.get('patrimonioPessoalLivre').to_char(),'"'),'"');
              END IF;

              -- Percepção Geral Empresa --
              IF vr_obj_indicadores.exist('percepcaoGeralEmpresa') THEN
                vr_nrperger := ltrim(rtrim(vr_obj_indicadores.get('percepcaoGeralEmpresa').to_char(),'"'),'"');
              END IF;

              -- Score Boa Vista --
              IF vr_obj_indicadores.exist('descricaoScoreBVS') THEN
                vr_desscore := ltrim(rtrim(vr_obj_indicadores.get('descricaoScoreBVS').to_char(),'"'),'"');
              END IF;

              -- Data Score Boa Vista --
              IF vr_obj_indicadores.exist('dataScoreBVS') THEN
                vr_datscore := ltrim(rtrim(vr_obj_indicadores.get('dataScoreBVS').to_char(),'"'),'"');
              END IF;

            END IF;

            -- Se o DEBUG estiver habilitado
            IF vr_flgdebug = 'S' THEN
              --> Gravar dados log acionamento
              pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,
                                   pr_cdagenci              => rw_craplim.cdagenci,
                                   pr_cdoperad              => 'MOTOR',
                                   pr_cdorigem              => 5,
                                   pr_nrctrprp              => rw_craplim.nrctrlim,
                                   pr_nrdconta              => rw_craplim.nrdconta,
                                   pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                   pr_dsoperacao            => 'ANTES PROCESSAMENTO RETORNO',
                                   pr_dsuriservico          => NULL,
                                   pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                   pr_cdstatus_http         => 0,
                                   pr_dsconteudo_requisicao => null,
                                   pr_dsresposta_requisicao => null,
                                   pr_idacionamento         => vr_idaciona,
                                   pr_dscritic              => vr_dscritic);
              -- Sem tratamento de exceção para DEBUG
              --IF TRIM(vr_dscritic) IS NOT NULL THEN
              --  RAISE vr_exc_erro;
              --END IF;
            END IF;

            -- Gravar o retorno e proceder com o restante do processo pós análise automática
            /*popd temq ue migrar a pc_retorno_analise_proposta para desconto de titulos*/
            WEBS0001.pc_retorno_analise_proposta(pr_cdorigem => 5 /*Ayllos*/
                                                ,pr_dsprotoc => rw_craplim.dsprotoc
                                                ,pr_nrtransa => vr_idacionamento
                                                ,pr_dsresana => vr_dsresana
                                                ,pr_indrisco => vr_indrisco
                                                ,pr_nrnotrat => vr_nrnotrat
                                                ,pr_nrinfcad => vr_nrinfcad
                                                ,pr_nrliquid => vr_nrliquid
                                                ,pr_nrgarope => vr_nrgarope
                                                ,pr_nrparlvr => vr_nrparlvr
                                                ,pr_nrperger => vr_nrperger
                                                ,pr_desscore => vr_desscore
                                                ,pr_datscore => vr_datscore
                                                ,pr_dsrequis => vr_obj_proposta.to_char
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
          pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,
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
          -- Sem tratamento de exceção para DEBUG
          --IF TRIM(vr_dscritic) IS NOT NULL THEN
          --  RAISE vr_exc_erro;
          --END IF;
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
                                                 ||' - ESTE0001 --> Erro ao solicitor retorno Protocolo '
                                                 ||vr_dsprotoc||': '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));

    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;
      -- Gerar log
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                 ||' - ESTE0001 --> Erro ao solicitor retorno Protocolo '
                                                 ||vr_dsprotoc||': '||sqlerrm,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
  END pc_solicita_retorno_analise;

  PROCEDURE pc_consulta_acionamento_web(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Nr. Contrato
                                       ,pr_dtinicio IN VARCHAR2 -->
                                       ,pr_dtafinal IN VARCHAR2 -->
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_proposta_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel Zimmermann
        Data    : Março/16.                    Ultima atualizacao: 12/06/2017

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para enviar consultar proposta de emprestimo

        Observacao: -----

        Alteracoes: 12/06/2017 - Retornar o protocolo. (Jaison/Marcos - PRJ337)
    ..............................................................................*/
  BEGIN
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- PL/Table
      vr_tab_crawlim TELA_CONPRO.typ_tab_crawepr; -- PL/Table com os dados retornados da procedure
      vr_ind_crawlim INTEGER := 0; -- Indice para a PL/Table retornada da procedure

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_dtinicio DATE;
      vr_dtafinal DATE;

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

      vr_dtinicio := to_date(pr_dtinicio, 'DD/MM/RRRR');
      vr_dtafinal := to_date(pr_dtafinal, 'DD/MM/RRRR');

      pc_consulta_acionamento(pr_cdcooper    => vr_cdcooper,

                              pr_nrctrlim    => pr_nrctrlim,
                              pr_nrdconta    => pr_nrdconta,
                              pr_dtinicio    => vr_dtinicio,
                              pr_dtafinal    => vr_dtafinal,
                              pr_cdoperad    => vr_cdoperad,
                              pr_cdcritic    => vr_cdcritic,
                              pr_dscritic    => vr_dscritic,
                              pr_tab_crawlim => vr_tab_crawlim);
      -- Se retornou alguma crítica
      IF vr_cdcritic <> 0 OR
         vr_dscritic IS NOT NULL THEN
        -- Levantar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Se PL/Table possuir algum registro
      IF vr_tab_crawlim.count() > 0 THEN
        -- Atribui registro inicial como indice
        vr_ind_crawlim := vr_tab_crawlim.FIRST;
        -- Se existe registro com o indice inicial
        IF vr_tab_crawlim.exists(vr_ind_crawlim) THEN
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Root',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'Dados',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);

          LOOP
            -- Insere as tags
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'Dados',
                                   pr_posicao  => 0,
                                   pr_tag_nova => 'inf',
                                   pr_tag_cont => NULL,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'acionamento',
                                   pr_tag_cont => vr_tab_crawlim(vr_ind_crawlim).acionamento,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'parecer_esteira',
                                   pr_tag_cont => vr_tab_crawlim(vr_ind_crawlim).cdagenci,
                                   pr_des_erro => vr_dscritic);
            IF vr_tab_crawlim(vr_ind_crawlim).cdoperad LIKE '%Esteira%' THEN

              gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                     pr_tag_pai  => 'inf',
                                     pr_posicao  => vr_auxconta,
                                     pr_tag_nova => 'cdoperad',
                                     pr_tag_cont => 'Esteira',
                                     pr_des_erro => vr_dscritic);
            ELSE
              gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                     pr_tag_pai  => 'inf',
                                     pr_posicao  => vr_auxconta,
                                     pr_tag_nova => 'cdoperad',
                                     pr_tag_cont => TRIM(vr_tab_crawlim(vr_ind_crawlim).cdoperad),
                                     pr_des_erro => vr_dscritic);
            END IF;
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'operacao',
                                   pr_tag_cont => TRIM(vr_tab_crawlim(vr_ind_crawlim).operacao),
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'dtmvtolt',
                                   pr_tag_cont => TRIM(vr_tab_crawlim(vr_ind_crawlim).dtmvtolt),
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'retorno',
                                   pr_tag_cont => vr_tab_crawlim(vr_ind_crawlim).retorno,
                                   pr_des_erro => vr_dscritic);

            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nrctrprp',
                                   pr_tag_cont => vr_tab_crawlim(vr_ind_crawlim).nrctrprp,
                                   pr_des_erro => vr_dscritic);

            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nmagenci',
                                   pr_tag_cont => vr_tab_crawlim(vr_ind_crawlim).nmagenci,
                                   pr_des_erro => vr_dscritic);

            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'dsprotocolo',
                                   pr_tag_cont => vr_tab_crawlim(vr_ind_crawlim).dsprotocolo,
                                   pr_des_erro => vr_dscritic);

            -- Sai do loop se for o último registro ou se chegar no número de registros solicitados
            EXIT WHEN(vr_ind_crawlim = vr_tab_crawlim.LAST);

            -- Busca próximo indice
            vr_ind_crawlim := vr_tab_crawlim.NEXT(vr_ind_crawlim);
            vr_auxconta    := vr_auxconta + 1;

          END LOOP;
          -- Quantidade total de registros
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Root',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'Qtdregis',
                                 pr_tag_cont => vr_tab_crawlim.count(),
                                 pr_des_erro => vr_dscritic);
        END IF;
      ELSE
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Dados nao encontrados!';
        -- Levanta exceção
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

        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_consulta_acionamento_web;

  PROCEDURE pc_consulta_acionamento(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrctrlim    IN craplim.nrctrlim%TYPE DEFAULT 0 --> Nr. do Contrato
                                   ,pr_nrdconta    IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. da Conta
                                   ,pr_dtinicio    IN DATE DEFAULT NULL
                                   ,pr_dtafinal    IN DATE DEFAULT NULL
                                   ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Cód. Operador
                                   ,pr_cdcritic    OUT crapcri.cdcritic%TYPE --> Cód. da crítica
                                   ,pr_dscritic    OUT crapcri.dscritic%TYPE --> Descrição da crítica
                                   ,pr_tab_crawlim OUT TELA_CONPRO.typ_tab_crawepr) IS --> Pl/Table com os dados de cobrança de emprestimos
  BEGIN
    /* .............................................................................

      Programa: pc_consulta_acionamento
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Daniel Zimmermann
      Data    : Março/16.                    Ultima atualizacao: 12/06/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a busca propostas emprestimo

      Observacao: -----

      Alteracoes: 12/06/2017 - Retornar o protocolo. (Jaison/Marcos - PRJ337)
    ..............................................................................*/
    DECLARE
      ----------------------------- VARIAVEIS ---------------------------------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_ind_crawlim INTEGER := 0;

      ---------------------------- CURSORES -----------------------------------
      CURSOR cr_cratblim IS
        SELECT A.Idacionamento Acionamento,
               A.CDCOOPER cdcooper,
               A.NRDCONTA nrdconta,
               A.Nrctrprp nrctrprp,
               INITCAP(TO_CHAR(A.CDAGENCI_ACIONAMENTO) || ' - ' || P.NMRESAGE) nmagenci,
               upper(a.cdoperad) cdoperad,
               INITCAP(TO_CHAR(A.CDOPERAD) || ' - ' ||
                       INITCAP((SUBSTR(TRIM(REPLACE(REPLACE(O.NMOPERAD, 'CECRED', ' '), '-', ' ')),
                                       1,
                                       INSTR(TRIM(REPLACE(REPLACE(O.NMOPERAD, 'CECRED', ' '),
                                                          '-',
                                                          ' ')),
                                             ' ') - 1)))) nmoperad,
               INITCAP(A.DSOPERACAO) operacao,
               A.DHACIONAMENTO dtmvtolt,
               a.dsuriservico,
               a.dsresposta_requisicao,
               a.cdstatus_http,
               a.tpacionamento,
               decode(a.tpacionamento,2,a.dsprotocolo,NULL) dsprotocolo

          FROM tbgen_webservice_aciona a

          LEFT JOIN crapope o
            ON o.cdcooper = a.cdcooper
           AND upper(o.cdoperad) = upper(a.cdoperad)

          LEFT JOIN crapass b
            ON b.cdcooper = a.cdcooper
           AND b.nrdconta = a.nrdconta

          LEFT JOIN crapage P
            ON a.cdcooper = p.cdcooper
           AND a.cdagenci_acionamento = p.cdagenci

         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta
           AND ( a.nrctrprp = pr_nrctrlim OR pr_nrctrlim = 0)
           AND trunc(a.DHACIONAMENTO) >= pr_dtinicio
           AND trunc(a.DHACIONAMENTO) <= pr_dtafinal
           AND a.tpacionamento IN(1,2)
           AND a.tpproduto = 3
     ORDER BY a.DHACIONAMENTO DESC;
      rw_crawlim cr_cratblim%ROWTYPE;

     -- Descritivo Retorno
     vr_dsretorno VARCHAR2(1000);

    BEGIN

      ---------------------------------- VALIDACOES INICIAIS --------------------------

      -- Gera exceção se informar data de inicio e não informar data final e vice-versa
      IF pr_dtinicio IS NULL THEN
        -- Monta Crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Data Inicial deve ser informada.';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      IF pr_dtafinal IS NULL THEN
        -- Monta Crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Data Final deve ser informada.';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      IF pr_dtafinal < pr_dtinicio THEN
        -- Monta Crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Data Final deve ser superior a Data Inicial.';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      -- Abre cursor para atribuir os registros encontrados na PL/Table
      FOR rw_crawlim IN cr_cratblim LOOP

        -- Incrementa contador para utilizar como indice da PL/Table
        vr_ind_crawlim := vr_ind_crawlim + 1;

        -- pr_tab_cde(vr_ind_cde).cdcooper := rw_crapcob.cdcooper;
        pr_tab_crawlim(vr_ind_crawlim).acionamento := rw_crawlim.acionamento;
        pr_tab_crawlim(vr_ind_crawlim).nmagenci := substr(rw_crawlim.nmagenci,1,100);
        pr_tab_crawlim(vr_ind_crawlim).cdoperad := rw_crawlim.nmoperad;
        pr_tab_crawlim(vr_ind_crawlim).operacao := substr(rw_crawlim.operacao,1,100);
        pr_tab_crawlim(vr_ind_crawlim).dtmvtolt := to_char(rw_crawlim.dtmvtolt,
                                                           'DD/MM/YYYY hh24:mi:ss');

        vr_dscritic := NULL;
        IF rw_crawlim.CDSTATUS_HTTP = 400 THEN
          vr_dscritic := substr(ESTE0001.fn_retorna_critica(rw_crawlim.DSRESPOSTA_REQUISICAO),1,150);
        END IF;
        -- Se encontramos critica
        IF vr_dscritic IS NOT NULL THEN
          -- Retornaremos a mesma
          vr_dsretorno := vr_dscritic;
        ELSE
          -- Erros HTTP
          IF rw_crawlim.CDSTATUS_HTTP = 401 THEN
            vr_dsretorno := 'Credencias de acesso ao WebService Ibratan inválidas.';
          ELSIF rw_crawlim.CDSTATUS_HTTP = 403 THEN
            vr_dsretorno := 'Sem permissão de acesso ao Webservice Ibratan.';
          ELSIF rw_crawlim.CDSTATUS_HTTP = 404 THEN
            vr_dsretorno := 'Recurso não encontrado no WebService Ibratan não existe.';
          ELSIF rw_crawlim.CDSTATUS_HTTP = 412 THEN
            vr_dsretorno := 'Parâmetros do WebService Ibratan inválidos.';
          ELSIF rw_crawlim.CDSTATUS_HTTP = 429 THEN
            vr_dsretorno := 'Muitas requisições de retorno da Análise Automática da esteira.';
          ELSIF rw_crawlim.CDSTATUS_HTTP BETWEEN 400 AND 499 THEN
            vr_dsretorno := 'Valor do(s) parâmetro(s) WebService inválidos.';
          ELSIF rw_crawlim.CDSTATUS_HTTP BETWEEN 500 AND 599 THEN
            vr_dsretorno := 'Falha na comunicação com serviço Ibratan.';
          ELSE
            -- Tratar envios e retornos
            IF rw_crawlim.CDSTATUS_HTTP = 200 THEN
              IF INSTR(rw_crawlim.dsuriservico, 'cancelar') > 0 THEN
                vr_dsretorno := 'Cancelamento da proposta enviado com sucesso para esteira.';
              ELSIF INSTR(rw_crawlim.dsuriservico, 'efetivar') > 0 THEN
                vr_dsretorno := 'Proposta efetivada foi enviada para esteira com sucesso.';
              ELSIF INSTR(rw_crawlim.dsuriservico, 'numeroProposta') > 0 THEN
                vr_dsretorno := 'Número da proposta foi enviado para esteira com sucesso.';
              ELSIF rw_crawlim.cdoperad = 'MOTOR' THEN
                vr_dsretorno := 'Retorno da analise automatica da esteira recebido com sucesso.';
              ELSIF rw_crawlim.tpacionamento = 1 THEN
                vr_dsretorno := 'Proposta reenviada para esteira com sucesso.';
              END IF;
            ELSIF rw_crawlim.CDSTATUS_HTTP = 201 THEN
              vr_dsretorno := 'Proposta enviada para analise manual da esteira com sucesso.';
            ELSIF rw_crawlim.CDSTATUS_HTTP = 202 THEN
              -- Se foi no envio
              IF rw_crawlim.tpacionamento = 1 THEN
                vr_dsretorno := 'Proposta enviada para analise automatica da esteira com sucesso.';
              ELSE
                vr_dsretorno := 'Retorno da analise automatica da esteira recebido com sucesso.';
              END IF;
            ELSIF rw_crawlim.CDSTATUS_HTTP = 204 THEN
              vr_dsretorno := 'Proposta em processo de analise automatica da esteira.';
            END IF;
          END IF;
        END IF;

        pr_tab_crawlim(vr_ind_crawlim).retorno := substr(vr_dsretorno,1,150);
        pr_tab_crawlim(vr_ind_crawlim).nrctrprp := rw_crawlim.nrctrprp;
        pr_tab_crawlim(vr_ind_crawlim).dsprotocolo := rw_crawlim.dsprotocolo;


      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se possui código de crítica e não foi informado a descrição
        IF vr_cdcritic <> 0 AND
           TRIM(vr_dscritic) IS NULL THEN
          -- Busca descrição da crítica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Atribui exceção para os parametros de crítica
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Atribui exceção para os parametros de crítica
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na TELA_CONPRO.pc_consulta_acionamento: ' || SQLERRM;

    END;
  END pc_consulta_acionamento;


END ESTE0003;
/

