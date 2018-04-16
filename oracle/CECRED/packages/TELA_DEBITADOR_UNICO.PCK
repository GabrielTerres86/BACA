CREATE OR REPLACE PACKAGE CECRED.TELA_DEBITADOR_UNICO IS
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_DEBITADOR_UNICO
  --  Sistema  : DEBITADOR UNICO
  --  Sigla    : DEB
  --  Autor    : Fabio Adriano e Reginaldo (AMcom)
  --  Data     : Março/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações usadas na tela do debitador automatico
  --
  -- Alterado:
  --
  ---------------------------------------------------------------------------------------------------------------

PROCEDURE pc_grava_historico(pr_cdoperador        IN  tbgen_debitador_historico.cdoperador%TYPE        --> Código do operador
                           , pr_dscampo_alterado  IN  tbgen_debitador_historico.dscampo_alterado%TYPE  --> Campo alterado na operação
                           , pr_dsvalor_anterior  IN  tbgen_debitador_historico.dsvalor_anterior%TYPE  --> Valor anterior do campo
                           , pr_dsvalor_novo      IN  tbgen_debitador_historico.dsvalor_novo%TYPE      --> Novo valor do campo
                           , pr_cdprocesso        IN  tbgen_debitador_historico.cdprocesso%TYPE        --> Código do processo
                           , pr_tpoperacao        IN  tbgen_debitador_historico.tpoperacao%TYPE        --> Tipo de operação
                           , pr_tporigem          IN  tbgen_debitador_historico.tporigem%TYPE          --> Origem da operação
                           , pr_dscritic          OUT VARCHAR2);                                       --> Descrição da crítica
													 
PROCEDURE pc_busca_debitador_hist(pr_tporigem  IN tbgen_debitador_historico.tporigem%TYPE  --> Origem (0 ==> Todas, 1 ==> Cad. Horários, 2 ==> Cad. Prioridades, 3 ==> Exec. Emergenc.)
                                , pr_xmllog    IN VARCHAR2                                 --> XML com informações de LOG
                                , pr_cdcritic  OUT PLS_INTEGER                             --> Código da crítica
                                , pr_dscritic  OUT VARCHAR2                                --> Descrição da crítica
                                , pr_retxml    IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                , pr_nmdcampo  OUT VARCHAR2                                --> Nome do campo com erro
                                , pr_des_erro  OUT VARCHAR2);

--------------------- INICIO HORARIOS -----------------------
PROCEDURE pc_busca_debitador_horarios(-- pr_idhora_processamento IN TBGEN_DEBITADOR_HORARIO.idhora_processamento%TYPE -->Identificador unico do horario do processamento
                                     --, pr_dhprocessamento      OUT TBGEN_DEBITADOR_HORARIO.dhprocessamento%TYPE      -->Hora do processamento
                                      pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     , pr_des_erro OUT VARCHAR2);

PROCEDURE pc_inclui_debitador_horarios(pr_dhprocessamento      IN VARCHAR2      -->Hora do processamento
                                     , pr_xmllog          IN VARCHAR2           --> XML com informações de LOG
                                     , pr_cdcritic        OUT PLS_INTEGER       --> Código da crítica
                                     , pr_dscritic        OUT VARCHAR2          --> Descrição da crítica
                                     , pr_retxml          IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     , pr_nmdcampo        OUT VARCHAR2          --> Nome do campo com erro
                                     , pr_des_erro        OUT VARCHAR2 );

PROCEDURE pc_exclui_debitador_horarios(pr_idhora_processamento IN INTEGER            --> ID do horário a alterar
                                     , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                     , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                     , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                     , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                     , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                     , pr_des_erro OUT VARCHAR2);

PROCEDURE pc_altera_debitador_horarios(pr_idhora_processamento IN INTEGER            --> ID do horário a alterar
                                     , pr_dhprocessamento      IN VARCHAR2           --> Novo valor para o horário
                                     , pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                     , pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                     , pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                     , pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                     , pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                     , pr_des_erro OUT VARCHAR2);
----------------------- FIM HORARIOS ------------------------

------------------- INICIO PRIORIDADES -----------------------
PROCEDURE pc_busca_debitador_priori_res(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       , pr_des_erro OUT VARCHAR2);
																			 
PROCEDURE pc_busca_debitador_priori_comp(pr_idhora_processamento tbgen_debitador_horario.idhora_processamento%TYPE
	                                     , pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       , pr_des_erro OUT VARCHAR2);																			 

PROCEDURE pc_busca_debitador_processo(pr_nrprioridade IN TBGEN_DEBITADOR_PARAM.nrprioridade%TYPE -->Identificador unico da prioridade do processamento
                                    , pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2);
																		
PROCEDURE pc_ativa_debitador_processo(pr_cdprocesso IN tbgen_debitador_param.cdprocesso%TYPE   --> Código do processo a ativar
	                                  , pr_horarios IN VARCHAR2                                  --> Lista de horários a agendar para o processo
                                    , pr_xmllog    IN VARCHAR2                                 --> XML com informações de LOG
                                    , pr_cdcritic  OUT PLS_INTEGER                             --> Código da crítica
                                    , pr_dscritic  OUT VARCHAR2                                --> Descrição da crítica
                                    , pr_retxml    IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                    , pr_nmdcampo  OUT VARCHAR2                                --> Nome do campo com erro
                                    , pr_des_erro  OUT VARCHAR2);

PROCEDURE pc_exclui_debitador_prioridade(pr_nrprioridade IN TBGEN_DEBITADOR_PARAM.nrprioridade%TYPE -->Identificador unico da prioridade do processamento
                                        , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                        , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                        , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                        , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                        , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                        , pr_des_erro OUT VARCHAR2);
																				
PROCEDURE pc_desativa_debitador_processo(pr_cdprocesso IN tbgen_debitador_param.cdprocesso%TYPE   --> Código do processo a ativar
                                       , pr_xmllog    IN VARCHAR2                                 --> XML com informações de LOG
                                       , pr_cdcritic  OUT PLS_INTEGER                             --> Código da crítica
                                       , pr_dscritic  OUT VARCHAR2                                --> Descrição da crítica
                                       , pr_retxml    IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                       , pr_nmdcampo  OUT VARCHAR2                                --> Nome do campo com erro
                                       , pr_des_erro  OUT VARCHAR2);																				

PROCEDURE pc_redefine_debitador_priori(pr_nrprioridade IN TBGEN_DEBITADOR_PARAM.nrprioridade%TYPE -->Identificador unico da prioridade do processamento
                                     , pr_cdprocesso   IN TBGEN_DEBITADOR_PARAM.cdprocesso%TYPE -->Identificador unico do código do processo
                                     , pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                     , pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                     , pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                     , pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                     , pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                     , pr_des_erro OUT VARCHAR2);
---------------------------- FIM PRIORIDADES -----------------------------


--------------------- INICIO HORARIOS PROCESSAMENTOS -----------------------
PROCEDURE pc_busca_debitador_hr_proces( pr_cdprocesso tbgen_debitador_param.cdprocesso%TYPE  --> Código do processo
	                                    , pr_xmllog   IN VARCHAR2                              --> XML com informações de LOG
                                      , pr_cdcritic OUT PLS_INTEGER                          --> Código da crítica
                                      , pr_dscritic OUT VARCHAR2                             --> Descrição da crítica
                                      , pr_retxml   IN OUT NOCOPY XMLType                    --> Arquivo de retorno do XML
                                      , pr_nmdcampo OUT VARCHAR2                             --> Nome do campo com erro
                                      , pr_des_erro OUT VARCHAR2);
																			
PROCEDURE pc_busca_debitador_hr_exclus( pr_cdprocesso tbgen_debitador_param.cdprocesso%TYPE  --> Código do processo
	                                    , pr_xmllog   IN VARCHAR2                              --> XML com informações de LOG
                                      , pr_cdcritic OUT PLS_INTEGER                          --> Código da crítica
                                      , pr_dscritic OUT VARCHAR2                             --> Descrição da crítica
                                      , pr_retxml   IN OUT NOCOPY XMLType                    --> Arquivo de retorno do XML
                                      , pr_nmdcampo OUT VARCHAR2                             --> Nome do campo com erro
                                      , pr_des_erro OUT VARCHAR2);

PROCEDURE pc_inclui_debitador_hr_proces( pr_cdprocesso           IN TBGEN_DEBITADOR_HORARIO_PROC.cdprocesso%TYPE           -->Codigo de identificacao do processo
                                           , pr_idhora_processamento IN TBGEN_DEBITADOR_HORARIO_PROC.idhora_processamento%TYPE -->Identificador do horario do processamento
                                           , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                           , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                           , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                           , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                           , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                           , pr_des_erro OUT VARCHAR2);

PROCEDURE pc_exclui_debitador_hr_proces(pr_cdprocesso           IN TBGEN_DEBITADOR_HORARIO_PROC.cdprocesso%TYPE           -->Codigo de identificacao do processo
                                      , pr_horarios IN VARCHAR2                                 -->Identificador do horario do processamento
                                      , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                      , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                      , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                      , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                      , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                      , pr_des_erro OUT VARCHAR2);

----------------------- FIM HORARIOS PROCESSAMENTOS ------------------------

----------------------- INÍCIO EXECUÇÃO EMERGENCIAL ------------------------

PROCEDURE pc_executar_debitador_emergen(pr_processos IN VARCHAR2         --> Lista de processos a executar (separada por ";")
                                      , pr_xmllog    IN VARCHAR2                     --> XML com informações de LOG
                                      , pr_cdcritic  OUT PLS_INTEGER                 --> Código da crítica
                                      , pr_dscritic  OUT VARCHAR2                    --> Descrição da crítica
                                      , pr_retxml    IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                      , pr_nmdcampo  OUT VARCHAR2                    --> Nome do campo com erro
                                      , pr_des_erro  OUT VARCHAR2);

----------------------- FIM EXECUÇÃO EMERGENCIAL ------------------------

END TELA_DEBITADOR_UNICO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_DEBITADOR_UNICO IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_DEBITADOR_UNICO
  --  Sistema  : DEBITADOR UNICO
  --  Sigla    : DEB
  --  Autor    : Fabio Adriano e Reginaldo (AMcom)
  --  Data     : Março/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações usadas na tela do debitador automatico
  --
  -- Alterado:
  --
  ---------------------------------------------------------------------------------------------------------------

FUNCTION fn_obtem_proximo_id
    RETURN INTEGER AS vr_proximo_id INTEGER;

  ----->>> CURSORES <<<-----
	CURSOR cr_proximo_id IS
	SELECT (MAX(hor.idhora_processamento) + 1) proximo_id
	  FROM tbgen_debitador_horario hor;

BEGIN
	OPEN cr_proximo_id;
	FETCH cr_proximo_id INTO vr_proximo_id;

	IF cr_proximo_id%NOTFOUND THEN
		vr_proximo_id := 1;
	END IF;

	CLOSE cr_proximo_id;

	RETURN vr_proximo_id;
END fn_obtem_proximo_id;


PROCEDURE pc_grava_historico(pr_cdoperador        IN  tbgen_debitador_historico.cdoperador%TYPE        --> Código do operador
                           , pr_dscampo_alterado	IN  tbgen_debitador_historico.dscampo_alterado%TYPE  --> Campo alterado na operação
													 , pr_dsvalor_anterior  IN  tbgen_debitador_historico.dsvalor_anterior%TYPE  --> Valor anterior do campo
                           , pr_dsvalor_novo      IN  tbgen_debitador_historico.dsvalor_novo%TYPE      --> Novo valor do campo
                           , pr_cdprocesso        IN  tbgen_debitador_historico.cdprocesso%TYPE        --> Código do processo
                           , pr_tpoperacao        IN  tbgen_debitador_historico.tpoperacao%TYPE        --> Tipo de operação
                           , pr_tporigem          IN  tbgen_debitador_historico.tporigem%TYPE          --> Origem da operação
                           , pr_dscritic          OUT VARCHAR2                                         --> Descrição da crítica
                           ) IS

BEGIN
    /* ............................................................................
        Programa: pc_grava_historico
        Sistema : Debitador Automático
        Sigla   : CECRED
        Autor   : Fabio Adriano e Reginaldo (AMcom)
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para gravar histórico de operações na tabela
				            TBGEN_DEBITADOR_HISTORICO
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

   BEGIN
	    pr_dscritic := NULL;

		  INSERT
			  INTO tbgen_debitador_historico (
				    dhoperacao
					, cdoperador
					, dscampo_alterado
					, dsvalor_anterior
					, dsvalor_novo
					, cdprocesso
					, tpoperacao
					, tporigem
				)
				VALUES (
				    SYSDATE
					, pr_cdoperador
					, pr_dscampo_alterado
					, pr_dsvalor_anterior
					, pr_dsvalor_novo
					, pr_cdprocesso
					, pr_tpoperacao
					, pr_tporigem
				);

				COMMIT;
	 EXCEPTION
      WHEN OTHERS THEN
				pr_dscritic := 'Erro ao gravar histórico: ' || SQLERRM;
	 END;
END pc_grava_historico;

PROCEDURE pc_busca_debitador_hist(pr_tporigem  IN tbgen_debitador_historico.tporigem%TYPE  --> Origem (0 ==> Todas, 1 ==> Cad. Horários, 2 ==> Cad. Prioridades, 3 ==> Exec. Emergenc.)
                                , pr_xmllog    IN VARCHAR2                                 --> XML com informações de LOG
                                , pr_cdcritic  OUT PLS_INTEGER                             --> Código da crítica
                                , pr_dscritic  OUT VARCHAR2                                --> Descrição da crítica
                                , pr_retxml    IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                , pr_nmdcampo  OUT VARCHAR2                                --> Nome do campo com erro
                                , pr_des_erro  OUT VARCHAR2 ) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_debitador_hist
        Sistema : Debitador Automático
        Sigla   : CECRED
        Autor   : Reginaldo/AMcom
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar os históricos de operaçções da parametrização do Debitador Aumtomático
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_contador INTEGER := 0; -- Contador para inserção dos dados no XML

    ----------->>> CURSORES <<<--------

    -- Históricos de operações
    CURSOR cr_historicos IS
    SELECT to_char(his.dhoperacao, 'DD/MM/YYYY HH24:MI:SS') dhoperacao
         , his.cdoperador
         , his.dscampo_alterado
         , his.dsvalor_anterior
         , his.dsvalor_novo
         , his.cdprocesso
				 , his.tpoperacao
         , decode(his.tpoperacao
                , 1, 'Inclusão'
                , 2, 'Alteração'
                , 3, 'Exclusão'
                , 4, 'Ex. Emerg.') tipooperacao
         , decode(his.tporigem
                , 1, 'Cad. Prioridades'
                , 2, 'Cad. Horários'
                , 3, 'Exec. Emergenc.') tporigem
         , ope.nmoperad
				 , par.dsprocesso
      FROM tbgen_debitador_historico his
         , crapope ope
				 , tbgen_debitador_param par
     WHERE ope.cdcooper = vr_cdcooper
       AND ope.cdoperad = his.cdoperador
			 AND par.cdprocesso(+) = his.cdprocesso
       AND (pr_tporigem = 0 OR his.tporigem = pr_tporigem)
     ORDER BY his.dhoperacao DESC;
    rw_historicos cr_historicos%ROWTYPE;

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

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                            pr_tag_pai  => 'Root',
                            pr_posicao  => 0,
                            pr_tag_nova => 'Historicos',
                            pr_tag_cont => NULL,
                            pr_des_erro => vr_dscritic);

    -- Percorre os históricos de operações
    FOR rw_historicos IN cr_historicos LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Historicos',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Historico',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        -- Data e hora da operação
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Historico',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dhoperacao',
                               pr_tag_cont => rw_historicos.dhoperacao,
                               pr_des_erro => pr_dscritic);

        -- Código do operador
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Historico',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdoperador',
                               pr_tag_cont => rw_historicos.cdoperador,
                               pr_des_erro => pr_dscritic);
                               
        -- Nome do operador
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Historico',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nmoperad',
                               pr_tag_cont => rw_historicos.nmoperad,
                               pr_des_erro => pr_dscritic);
                               
        -- Campo alterado
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Historico',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dscampo_alterado',
                               pr_tag_cont => rw_historicos.dscampo_alterado,
                               pr_des_erro => pr_dscritic);
															 
				-- Valor anterior
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Historico',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsvalor_anterior',
                               pr_tag_cont => rw_historicos.dsvalor_anterior,
                               pr_des_erro => pr_dscritic);
															 
				-- Novo valor
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Historico',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsvalor_novo',
                               pr_tag_cont => rw_historicos.dsvalor_novo,
                               pr_des_erro => pr_dscritic);
															 
				-- Processo
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Historico',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdprocesso',
                               pr_tag_cont => rw_historicos.cdprocesso,
                               pr_des_erro => pr_dscritic);
															 
				-- Descrição do Processo
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Historico',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsprocesso',
                               pr_tag_cont => rw_historicos.dsprocesso,
                               pr_des_erro => pr_dscritic);
														
			  -- Tipo de operação (Inclusão, Alteração, Exclusão, Exec. Emergencial)
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Historico',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'tpoperacao',
                               pr_tag_cont => rw_historicos.tpoperacao,
                               pr_des_erro => pr_dscritic);
															 
				-- Tipo de operação (Inclusão, Alteração, Exclusão, Exec. Emergencial)
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Historico',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'tipooperacao',
                               pr_tag_cont => rw_historicos.tipooperacao,
                               pr_des_erro => pr_dscritic);
															 
				-- Origem (Cad. Horários, Cad. Prioridades, Exec. Emergencial)
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Historico',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'tporigem',
                               pr_tag_cont => rw_historicos.tporigem,
                               pr_des_erro => pr_dscritic);	

        vr_contador := vr_contador + 1;
    END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_PARDBT - pc_busca_debitador_hist: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_busca_debitador_hist: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_debitador_hist;


-------------------------- INICIO HORARIOS --------------------------

PROCEDURE pc_busca_debitador_horarios(--pr_idhora_processamento IN TBGEN_DEBITADOR_HORARIO.idhora_processamento%TYPE -->Identificador unico do horario do processamento
                                    --, pr_dhprocessamento      OUT TBGEN_DEBITADOR_HORARIO.dhprocessamento%TYPE      -->Hora do processamento
                                      pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                    , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_debitador_horario
        Sistema : CECRED
        Sigla   : DEB
        Autor   : Fabio Adriano e Reginaldo (AMcom)
        Data    : Marco/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para buscar dados dos horários de agendamentos
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_contcont INTEGER := 0; -- Contador para inserção dos dados no XML
    vr_contador INTEGER := 0;

    ----------->>> CURSORES <<<--------

    -- Dados dos horarios
    CURSOR cr_dados_horarios IS
    SELECT h.idhora_processamento
         , to_char(h.dhprocessamento, 'HH24:MI') dhprocessamento
    FROM CECRED.TBGEN_DEBITADOR_HORARIO h
    ORDER BY to_char(h.dhprocessamento, 'HH24:MI');
    rw_dados_horarios cr_dados_horarios%ROWTYPE;


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

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Horarios',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -- Percorre os horários
    FOR rw_dados_horarios
      IN cr_dados_horarios LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Horarios',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Horario',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        -- ID do registro
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Horario',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'idhora_processamento',
                               pr_tag_cont => rw_dados_horarios.idhora_processamento,
                               pr_des_erro => pr_dscritic);

        -- Horário cadastrado
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Horario',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dhprocessamento',
                               pr_tag_cont => rw_dados_horarios.dhprocessamento,
                               pr_des_erro => pr_dscritic);

        vr_contador := vr_contador + 1;
    END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_horarios: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_horarios: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_debitador_horarios;


PROCEDURE pc_inclui_debitador_horarios(pr_dhprocessamento      IN VARCHAR2      -->Hora do processamento
                                     , pr_xmllog          IN VARCHAR2           --> XML com informações de LOG
                                     , pr_cdcritic        OUT PLS_INTEGER       --> Código da crítica
                                     , pr_dscritic        OUT VARCHAR2          --> Descrição da crítica
                                     , pr_retxml          IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     , pr_nmdcampo        OUT VARCHAR2          --> Nome do campo com erro
                                     , pr_des_erro        OUT VARCHAR2 ) IS

    /* ............................................................................
        Programa: pc_insere_debitador_horarios
        Sistema : Debitador Automático
        Sigla   : CECRED
        Autor   : Fabio Adriano e Reginaldo (AMcom)
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para inserir novo horário na tabela TBGEN_DEBITADOR_HORARIO
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

BEGIN

DECLARE

    ----->>> VARIÁVEIS <<<-----

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    vr_exc_historico EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_idhora_processamento INTEGER;          --> ID do novo registro
		vr_hora_atual DATE;                       --> Guarda a hora atual do sistema para comparação
		vr_data_agendamento DATE;                 --> Data para a qual será criado o job de verificação do novo horário cadastrado
		vr_agendado_dia_seguinte BOOLEAN := FALSE; --> Indica se o job criado para o horário incluído rodará somente no dia seguinte

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

      -- Criar cabeçalho do XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                              pr_tag_pai  => 'Root',
                              pr_posicao  => 0,
                              pr_tag_nova => 'Dados',
                              pr_tag_cont => NULL,
                              pr_des_erro => vr_dscritic); 

      -- Obtém o próximo ID para inserir na tabela
      vr_idhora_processamento := fn_obtem_proximo_id;
			
			vr_data_agendamento := trunc(SYSDATE);
			
			IF to_date(to_char(vr_data_agendamento, 'DD/MM/YYYY') || ' ' || pr_dhprocessamento, 'DD/MM/YYYY HH24:MI') < SYSDATE THEN
				vr_data_agendamento := trunc(SYSDATE+1);
				vr_agendado_dia_seguinte := TRUE;
			END IF;

      -- Insere o novo horário na tabela
      INSERT
        INTO tbgen_debitador_horario (
             idhora_processamento
           , dhprocessamento
        )
        VALUES (
             vr_idhora_processamento
           , to_date(to_char(vr_data_agendamento, 'DD/MM/YYYY') || ' ' || pr_dhprocessamento, 'DD/MM/YYYY HH24:MI')
        );

        pc_grava_historico(pr_cdoperador => vr_cdoperad
                         , pr_dscampo_alterado => 'dhprocessamento'
                         , pr_dsvalor_anterior => NULL
                         , pr_dsvalor_novo => pr_dhprocessamento
                         , pr_cdprocesso => NULL
                         , pr_tpoperacao => 1
                         , pr_tporigem => 2
                         , pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_historico;
        END IF;

        COMMIT;

        -- Inclui dados no XML de retorno
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inserido',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'idhora_processamento',
                               pr_tag_cont => vr_idhora_processamento,
                               pr_des_erro => pr_dscritic);
															 
				IF vr_agendado_dia_seguinte THEN
					gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Dados',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'mensagem',
                                 pr_tag_cont => 'Horário incluído. Agendamento criado para o dia seguinte. Horário informado menor que hora atual do sistema.',
                                 pr_des_erro => pr_dscritic);
				ELSE
					gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Dados',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'mensagem',
                                 pr_tag_cont => 'Horário incluído. JOB agendado com sucesso.',
                                 pr_des_erro => pr_dscritic);
				END IF;
				

   EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        pr_dscritic := 'Horário já cadastrado. Não é possível incluir novamente.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_PARDBT - pc_insere_horario: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_PARDBT - pc_insere_horario: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_insere_horario: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   END;

END pc_inclui_debitador_horarios;


PROCEDURE pc_altera_debitador_horarios(pr_idhora_processamento IN INTEGER            --> ID do horário a alterar
                                     , pr_dhprocessamento      IN VARCHAR2           --> Novo valor para o horário
                                     , pr_xmllog               IN VARCHAR2           --> XML com informações de LOG
                                     , pr_cdcritic             OUT PLS_INTEGER       --> Código da crítica
                                     , pr_dscritic             OUT VARCHAR2          --> Descrição da crítica
                                     , pr_retxml               IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     , pr_nmdcampo             OUT VARCHAR2          --> Nome do campo com erro
                                     , pr_des_erro             OUT VARCHAR2 ) IS

    /* ............................................................................
        Programa: pc_altera_horario
        Sistema : Debitador Automático
        Sigla   : CECRED
        Autor   : Fabio Adriano e Reginaldo (AMcom)
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para inserir novo horário na tabela TBGEN_DEBITADOR_HORARIO
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

BEGIN

DECLARE

    ----->>> VARIÁVEIS <<<-----

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida         EXCEPTION;
    vr_exc_historico     EXCEPTION;
    vr_exc_naocadastrado EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_dhprocessamento_ant VARCHAR2(10);  --> Valor anterior do campo para o histórico

    ----->>> CURSORES <<<-----
    CURSOR cr_horarios IS
    SELECT to_char(hor.dhprocessamento, 'HH24:MI')
      FROM tbgen_debitador_horario hor
     WHERE hor.idhora_processamento = pr_idhora_processamento;

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

      -- Criar cabeçalho do XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      OPEN cr_horarios;
      FETCH cr_horarios INTO vr_dhprocessamento_ant;

      IF cr_horarios%NOTFOUND THEN
        CLOSE cr_horarios;

        RAISE vr_exc_naocadastrado;
      END IF;

      CLOSE cr_horarios;

      -- Altera o horário na tabela
      UPDATE tbgen_debitador_horario
         SET dhprocessamento = to_date('01/01/1900 ' || pr_dhprocessamento, 'DD/MM/YYYY HH24:MI')
       WHERE idhora_processamento = pr_idhora_processamento;

        pc_grava_historico(pr_cdoperador => vr_cdoperad
                         , pr_dscampo_alterado => 'dhprocessamento'
                         , pr_dsvalor_anterior => vr_dhprocessamento_ant
                         , pr_dsvalor_novo => pr_dhprocessamento
                         , pr_cdprocesso => NULL
                         , pr_tpoperacao => 2
                         , pr_tporigem => 2
                         , pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_historico;
        END IF;

        COMMIT;

        -- Inclui dados no XML de retorno
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'alterado',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);

   EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        pr_dscritic := 'Outro registro com o mesmo horário já cadastrado. Não é possível alterar.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_DEBITADOR_UNICO - pc_altera_debitador_horarios: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN vr_exc_naocadastrado THEN
        pr_dscritic := 'Erro na rotina da tela TELA_PARDBT - pc_altera_debitador_horarios: o ID informado não foi encontrado.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		 WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_altera_debitador_horarios: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
				ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_altera_debitador_horarios: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	 END;
END pc_altera_debitador_horarios;

PROCEDURE pc_exclui_debitador_horarios(pr_idhora_processamento IN INTEGER            --> ID do horário a alterar
                                     , pr_xmllog               IN VARCHAR2           --> XML com informações de LOG
                                     , pr_cdcritic             OUT PLS_INTEGER       --> Código da crítica
                                     , pr_dscritic             OUT VARCHAR2          --> Descrição da crítica
                                     , pr_retxml               IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     , pr_nmdcampo             OUT VARCHAR2          --> Nome do campo com erro
                                     , pr_des_erro             OUT VARCHAR2 ) IS

    /* ............................................................................
        Programa: pc_exclui_debitador_horarios
        Sistema : Debitador Unico
        Sigla   : CECRED
        Autor   : Fabio Adriano e Reginaldo (AMcom)
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para excluir horário na tabela TBGEN_DEBITADOR_HORARIO
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

BEGIN

DECLARE
    ----->>> VARIÁVEIS <<<-----

	  -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida         EXCEPTION;
		vr_exc_historico     EXCEPTION;
		vr_exc_naocadastrado EXCEPTION;
		vr_exc_foreignkey    EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

		vr_dhprocessamento_ant VARCHAR2(10);  --> Valor anterior do campo para o histórico
		vr_dependentes         INTEGER;  --> Quantidade de registros dependentes  

		----->>> CURSORES <<<-----
		
		-- Verificar se há registros dependentes
    CURSOR cr_agendamentos IS
		SELECT COUNT(1)
		  FROM tbgen_debitador_horario_proc hor
		 WHERE hor.idhora_processamento = pr_idhora_processamento;
		 
		-- Verificar se o id está cadastrado
		CURSOR cr_horarios IS
		SELECT to_char(hor.dhprocessamento, 'HH24:MI') dhprocessamento
		  FROM tbgen_debitador_horario hor
		 WHERE hor.idhora_processamento = pr_idhora_processamento;

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

			-- Criar cabeçalho do XML de retorno
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Root',
															pr_posicao  => 0,
															pr_tag_nova => 'Dados',
															pr_tag_cont => NULL,
															pr_des_erro => vr_dscritic);

			OPEN cr_horarios;
			FETCH cr_horarios INTO vr_dhprocessamento_ant;

			IF cr_horarios%NOTFOUND THEN
				CLOSE cr_horarios;

				RAISE vr_exc_naocadastrado;
			END IF;

			CLOSE cr_horarios;
			
			OPEN cr_agendamentos;
			FETCH cr_agendamentos INTO vr_dependentes;

			IF vr_dependentes > 0 THEN
				CLOSE cr_agendamentos;

				RAISE vr_exc_foreignkey;
			END IF;

			CLOSE cr_agendamentos;

			-- Exclui o horário na tabela
			DELETE FROM tbgen_debitador_horario
			 WHERE idhora_processamento = pr_idhora_processamento;

				pc_grava_historico(pr_cdoperador => vr_cdoperad
                         , pr_dscampo_alterado => 'horario'
												 , pr_dsvalor_anterior => '(' || pr_idhora_processamento || ' ) ' || vr_dhprocessamento_ant
												 , pr_dsvalor_novo => NULL
												 , pr_cdprocesso => NULL
												 , pr_tpoperacao => 3
												 , pr_tporigem => 2
	                       , pr_dscritic => vr_dscritic);

				IF vr_dscritic IS NOT NULL THEN
					RAISE vr_exc_historico;
				END IF;

				COMMIT;

				-- Inclui dados no XML de retorno
				gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'excluido',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);

	 EXCEPTION
		  WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_horarios: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		  WHEN vr_exc_naocadastrado THEN
        pr_dscritic := 'Erro na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_horarios: o ID informado não foi encontrado.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
			WHEN vr_exc_foreignkey THEN
        pr_dscritic := 'Erro na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_horarios: &lt;br&gt;Há agendamentos de processos vinculados ao horário.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');																					 
		  WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_horarios: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
				ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_exclui_debitador_horarios: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	 END;
END pc_exclui_debitador_horarios;

---------------------------- FIM HORARIOS-------------------------


----------------------- INICIO PRIORIDADES -----------------------
PROCEDURE pc_busca_debitador_priori_res(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_debitador_prioridades
        Sistema : CECRED
        Sigla   : DEB
        Autor   : Fabio Adriano
        Data    : Marco/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para buscar dados das prioridades (processos)
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_contcont INTEGER := 0; -- Contador para inserção dos dados no XML
    vr_contador INTEGER := 0;

    ----------->>> CURSORES <<<--------

    -- Dados das prioridades (processos)
    CURSOR cr_dados_prioridades IS
    SELECT p.cdprocesso
         , p.dsprocesso
         , p.indeb_sem_saldo
         , p.indeb_parcial
         , p.qtdias_repescagem
         , p.nrprioridade
      FROM tbgen_debitador_param p
		 WHERE p.nrprioridade IS NOT NULL
     ORDER BY p.nrprioridade;
    rw_dados_prioridades cr_dados_prioridades%ROWTYPE;


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

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Prioridades',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -- Percorre os horários
    FOR rw_dados_prioridades
      IN cr_dados_prioridades LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridades',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Prioridade',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - cdprocesso
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdprocesso',
                               pr_tag_cont => rw_dados_prioridades.cdprocesso,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - dsprocesso
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsprocesso',
                               pr_tag_cont => rw_dados_prioridades.dsprocesso,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - indeb_sem_saldo
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'indeb_sem_saldo',
                               pr_tag_cont => rw_dados_prioridades.indeb_sem_saldo,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - indeb_parcial
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'indeb_parcial',
                               pr_tag_cont => rw_dados_prioridades.indeb_parcial,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - qtdias_repescagem
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'qtdias_repescagem',
                               pr_tag_cont => rw_dados_prioridades.qtdias_repescagem,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - nrprioridade
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nrprioridade',
                               pr_tag_cont => rw_dados_prioridades.nrprioridade,
                               pr_des_erro => pr_dscritic);


        vr_contador := vr_contador + 1;
    END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_priori_res: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_priori_res: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_debitador_priori_res;


PROCEDURE pc_busca_debitador_priori_comp(pr_idhora_processamento tbgen_debitador_horario.idhora_processamento%TYPE
	                                     , pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_debitador_prioridades
        Sistema : CECRED
        Sigla   : DEB
        Autor   : Reginaldo Rubens da Silva
        Data    : Marco/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para buscar dados das prioridades (processos) incluindo 
				            horários de execução
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_contador_pr    INTEGER := 0;    -- Para inserção dos dados de prioridades no XML
		vr_contador_hr    INTEGER := 0;    -- Para inserção dos dados de horários de execução no XML  
		vr_max_prioridade NUMBER(3);       -- Maior valor de prioridade definido na tabela  

    ----------->>> CURSORES <<<--------

    -- Dados das prioridades (processos)
    CURSOR cr_dados_prioridades IS
    SELECT p.cdprocesso
         , p.dsprocesso
         , p.indeb_sem_saldo
         , p.indeb_parcial
         , p.qtdias_repescagem
         , p.nrprioridade
     FROM TBGEN_DEBITADOR_PARAM p
		WHERE pr_idhora_processamento = 0
		   OR p.cdprocesso IN (
			        SELECT cdprocesso
							  FROM tbgen_debitador_horario_proc h
							 WHERE h.idhora_processamento = pr_idhora_processamento	
			    )
    ORDER BY nvl(p.nrprioridade, 999); -- Força os inativos (sem prioridade definida) a ficar no final da lista
    rw_dados_prioridades cr_dados_prioridades%ROWTYPE;
		
		CURSOR cr_horarios_proc(pr_cdprocesso tbgen_debitador_horario_proc.cdprocesso%TYPE) IS
		SELECT hp.idhora_processamento
		     , to_char(hr.dhprocessamento, 'HH24:MI') dhprocessamento
		  FROM tbgen_debitador_horario_proc hp
			   , tbgen_debitador_horario hr
		 WHERE hp.cdprocesso = pr_cdprocesso
		   AND hr.idhora_processamento = hp.idhora_processamento
			 AND (pr_idhora_processamento = 0 OR hr.idhora_processamento = pr_idhora_processamento)
		 ORDER BY hr.dhprocessamento;
		rw_horarios_proc cr_horarios_proc%ROWTYPE;
		
		-- Recupera o maior valor definido para prioridade na tabela
		CURSOR cr_max_prioridade IS
		SELECT MAX(nrprioridade) max_prioridade
		  FROM tbgen_debitador_param;	

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

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Prioridades',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -- Percorre os horários
    FOR rw_dados_prioridades
      IN cr_dados_prioridades LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridades',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Prioridade',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - cdprocesso
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador_pr,
                               pr_tag_nova => 'cdprocesso',
                               pr_tag_cont => rw_dados_prioridades.cdprocesso,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - dsprocesso
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador_pr,
                               pr_tag_nova => 'dsprocesso',
                               pr_tag_cont => rw_dados_prioridades.dsprocesso,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - indeb_sem_saldo
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador_pr,
                               pr_tag_nova => 'indeb_sem_saldo',
                               pr_tag_cont => rw_dados_prioridades.indeb_sem_saldo,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - indeb_parcial
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador_pr,
                               pr_tag_nova => 'indeb_parcial',
                               pr_tag_cont => rw_dados_prioridades.indeb_parcial,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - qtdias_repescagem
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador_pr,
                               pr_tag_nova => 'qtdias_repescagem',
                               pr_tag_cont => rw_dados_prioridades.qtdias_repescagem,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - nrprioridade
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador_pr,
                               pr_tag_nova => 'nrprioridade',
                               pr_tag_cont => rw_dados_prioridades.nrprioridade,
                               pr_des_erro => pr_dscritic);
															 
        -- Prioridade (Processo) - nrprioridade
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridade',
                               pr_posicao  => vr_contador_pr,
                               pr_tag_nova => 'horarios',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);
															 
				FOR rw_horarios_proc 
					IN cr_horarios_proc(rw_dados_prioridades.cdprocesso) LOOP
					
					-- Horário de processamento
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'horarios',
                                 pr_posicao  => vr_contador_pr,
                                 pr_tag_nova => 'horario',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => pr_dscritic);
																 
					-- ID do horário
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'horario',
                                 pr_posicao  => vr_contador_hr,
                                 pr_tag_nova => 'idhora_processamento',
                                 pr_tag_cont => rw_horarios_proc.idhora_processamento,
                                 pr_des_erro => pr_dscritic);
																 
					-- Horário
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'horario',
                                 pr_posicao  => vr_contador_hr,
                                 pr_tag_nova => 'dhprocessamento',
                                 pr_tag_cont => rw_horarios_proc.dhprocessamento,
                                 pr_des_erro => pr_dscritic);
					
					vr_contador_hr := vr_contador_hr + 1;
				END LOOP;

        vr_contador_pr := vr_contador_pr + 1;
    END LOOP;
		
		OPEN cr_max_prioridade;
		FETCH cr_max_prioridade INTO vr_max_prioridade;
		CLOSE cr_max_prioridade;
		
		-- Horário de processamento
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Root',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'max_prioridade',
                                 pr_tag_cont => vr_max_prioridade,
                                 pr_des_erro => pr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_priori_comp: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_priori_comp: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_debitador_priori_comp;


PROCEDURE pc_busca_debitador_processo(pr_nrprioridade IN TBGEN_DEBITADOR_PARAM.nrprioridade%TYPE -->Identificador unico da prioridade do processamento
                                    , pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_debitador_processo
        Sistema : CECRED
        Sigla   : DEB
        Autor   : Fabio Adriano
        Data    : Marco/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para buscar dados de uma prioridade (processo)
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_contcont INTEGER := 0; -- Contador para inserção dos dados no XML
    vr_contador INTEGER := 0;

    ----------->>> CURSORES <<<--------

    -- Dados da prioridade (processo)
    CURSOR cr_dados_prioridades IS
    SELECT p.cdprocesso
         , p.dsprocesso
         , p.indeb_sem_saldo
         , p.indeb_parcial
         , p.qtdias_repescagem
         , p.nrprioridade
    FROM CECRED.TBGEN_DEBITADOR_PARAM p
    WHERE p.nrprioridade = pr_nrprioridade
    ORDER BY p.nrprioridade;
    rw_dados_prioridades cr_dados_prioridades%ROWTYPE;

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

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Prioridades',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -- Percorre os horários
    FOR rw_dados_prioridades
      IN cr_dados_prioridades LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridades',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Prioridade',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - cdprocesso
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridades',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdprocesso',
                               pr_tag_cont => rw_dados_prioridades.cdprocesso,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - dsprocesso
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridades',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsprocesso',
                               pr_tag_cont => rw_dados_prioridades.dsprocesso,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - indeb_sem_saldo
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridades',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'indeb_sem_saldo',
                               pr_tag_cont => rw_dados_prioridades.indeb_sem_saldo,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - indeb_parcial
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridades',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'indeb_parcial',
                               pr_tag_cont => rw_dados_prioridades.indeb_parcial,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - qtdias_repescagem
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridades',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'qtdias_repescagem',
                               pr_tag_cont => rw_dados_prioridades.qtdias_repescagem,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - nrprioridade
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridades',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nrprioridade',
                               pr_tag_cont => rw_dados_prioridades.nrprioridade,
                               pr_des_erro => pr_dscritic);


        vr_contador := vr_contador + 1;
    END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_processo: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_processo: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_debitador_processo;

PROCEDURE pc_ativa_debitador_processo(pr_cdprocesso IN tbgen_debitador_param.cdprocesso%TYPE   --> Código do processo a ativar
	                                  , pr_horarios IN VARCHAR2                                  --> Lista de horários a agendar para o processo
                                    , pr_xmllog    IN VARCHAR2                                 --> XML com informações de LOG
                                    , pr_cdcritic  OUT PLS_INTEGER                             --> Código da crítica
                                    , pr_dscritic  OUT VARCHAR2                                --> Descrição da crítica
                                    , pr_retxml    IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                    , pr_nmdcampo  OUT VARCHAR2                                --> Nome do campo com erro
                                    , pr_des_erro  OUT VARCHAR2) IS

    /* ............................................................................
        Programa: pc_ativa_debitador_processo
        Sistema : Debitador Unico
        Sigla   : CECRED
        Autor   : Reginaldo Rubens da Silva
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para criar JOB de execução emergencial dos processos
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

BEGIN
	
DECLARE
    ----->>> CURSORES <<<-----
		
		CURSOR cr_max_prioridade IS
		SELECT MAX(nrprioridade) max_prioridade
		  FROM tbgen_debitador_param;
			
		CURSOR cr_horario(pr_idhora_processamento NUMBER) IS
		SELECT to_char(hor.dhprocessamento, 'HH24:MI') dhprocessamento
		  FROM tbgen_debitador_horario hor
		 WHERE hor.idhora_processamento = pr_idhora_processamento;
			
    ----->>> VARIÁVEIS <<<-----

	  -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida         EXCEPTION;
		vr_exc_historico     EXCEPTION;
		vr_exc_naocadastrado EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

		vr_idhora_processamento  tbgen_debitador_horario.idhora_processamento%TYPE ;  --> Id do horário a inserir na tabela tbgen_debitador_horario_proc
		vr_max_prioridade        NUMBER(3);                                           --> Maior prioridade atribuída para processos na tabela
		vr_dhprocessamento       VARCHAR(5);                                          --> Horário para inclusão na tabela tbgen_debitador_historico
		
		l_count binary_integer;
    l_array dbms_utility.lname_array;

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
			
			-- Criar cabeçalho do XML de retorno
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Root',
															pr_posicao  => 0,
															pr_tag_nova => 'Dados',
															pr_tag_cont => NULL,
															pr_des_erro => vr_dscritic);
			
			OPEN cr_max_prioridade;
			FETCH cr_max_prioridade INTO vr_max_prioridade;
			CLOSE cr_max_prioridade;
			
			UPDATE tbgen_debitador_param
			   SET nrprioridade = vr_max_prioridade + 1
			 WHERE cdprocesso = pr_cdprocesso;
			 
			 
			pc_grava_historico(pr_cdoperador => vr_cdoperad
                       , pr_dscampo_alterado => 'nrprioridade'
											 , pr_dsvalor_anterior => NULL
											 , pr_dsvalor_novo => vr_max_prioridade + 1
											 , pr_cdprocesso => pr_cdprocesso
											 , pr_tpoperacao => 2
											 , pr_tporigem => 1
	                     , pr_dscritic => vr_dscritic);	 

       dbms_utility.comma_to_table(list   => pr_horarios
                                 , tablen => l_count
                                 , tab    => l_array);
																 
				FOR i IN 1 .. l_count
				LOOP
				    vr_idhora_processamento := to_number(substr(l_array(i), 2, length(l_array(i))-1));	
				
					  INSERT INTO tbgen_debitador_horario_proc hp (
						    cdprocesso
						  ,	idhora_processamento
						)
						VALUES (
						    pr_cdprocesso
						  , vr_idhora_processamento
						);
						
						OPEN cr_horario(vr_idhora_processamento);
						FETCH cr_horario INTO vr_dhprocessamento;
						CLOSE cr_horario;
						
				    pc_grava_historico(pr_cdoperador => vr_cdoperad
                             , pr_dscampo_alterado => 'idhora_processamento'
											     	 , pr_dsvalor_anterior => NULL
											    	 , pr_dsvalor_novo => vr_dhprocessamento
											    	 , pr_cdprocesso => pr_cdprocesso
											     	 , pr_tpoperacao => 1
											    	 , pr_tporigem => 1
	                           , pr_dscritic => vr_dscritic);	
				    
						
						IF vr_dscritic IS NOT NULL THEN
							RAISE vr_exc_historico;
						END IF;
				END LOOP;						

				COMMIT;

				-- Inclui dados no XML de retorno
				gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'processado',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);
															 
				-- Inclui dados no XML de retorno
				gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'nrprioridade',
                               pr_tag_cont => vr_max_prioridade + 1,
                               pr_des_erro => pr_dscritic);

	 EXCEPTION
		  WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_DEBITADOR_UNICO - pc_ativa_debitador_processo: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		  WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_ativa_debitador_processo: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
				ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_ativa_debitador_processo: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	 END;
END pc_ativa_debitador_processo;

PROCEDURE pc_desativa_debitador_processo(pr_cdprocesso IN tbgen_debitador_param.cdprocesso%TYPE   --> Código do processo a ativar
                                       , pr_xmllog    IN VARCHAR2                                 --> XML com informações de LOG
                                       , pr_cdcritic  OUT PLS_INTEGER                             --> Código da crítica
                                       , pr_dscritic  OUT VARCHAR2                                --> Descrição da crítica
                                       , pr_retxml    IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                       , pr_nmdcampo  OUT VARCHAR2                                --> Nome do campo com erro
                                       , pr_des_erro  OUT VARCHAR2) IS

    /* ............................................................................
        Programa: pc_desativa_debitador_processo
        Sistema : Debitador Unico
        Sigla   : CECRED
        Autor   : Reginaldo Rubens da Silva
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para criar JOB de execução emergencial dos processos
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

BEGIN
	
DECLARE	
    ----->>> CURSORES <<<-----

    CURSOR cr_prioridade IS
		SELECT nrprioridade
		  FROM tbgen_debitador_param
		 WHERE cdprocesso = pr_cdprocesso;
		 	
    ----->>> VARIÁVEIS <<<-----

	  -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida         EXCEPTION;
		vr_exc_historico     EXCEPTION;
		vr_exc_naocadastrado EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

		vr_prioridade_ant        NUMBER(3);                                           --> Prioridade anterior do processo que vai ser desativado
		
		l_count binary_integer;
    l_array dbms_utility.lname_array;

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
			
			-- Criar cabeçalho do XML de retorno
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Root',
															pr_posicao  => 0,
															pr_tag_nova => 'Dados',
															pr_tag_cont => NULL,
															pr_des_erro => vr_dscritic);
			
			OPEN cr_prioridade;
			FETCH cr_prioridade INTO vr_prioridade_ant;
			CLOSE cr_prioridade;
			
			UPDATE tbgen_debitador_param
			   SET nrprioridade = NULL
			 WHERE cdprocesso = pr_cdprocesso;
			 
			-- Reorganiza as prioridades 
			UPDATE tbgen_debitador_param
			   SET nrprioridade = nrprioridade - 1
			 WHERE nrprioridade > vr_prioridade_ant;	 
			 
			DELETE FROM tbgen_debitador_horario_proc
			 WHERE cdprocesso = pr_cdprocesso; 	 
			 
			 
			pc_grava_historico(pr_cdoperador => vr_cdoperad
                       , pr_dscampo_alterado => 'nrprioridade'
											 , pr_dsvalor_anterior => vr_prioridade_ant
											 , pr_dsvalor_novo => NULL
											 , pr_cdprocesso => pr_cdprocesso
											 , pr_tpoperacao => 2
											 , pr_tporigem => 1
	                     , pr_dscritic => vr_dscritic);	 			

				COMMIT;

				-- Inclui dados no XML de retorno
				gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'desativado',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);

	 EXCEPTION
		  WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_DEBITADOR_UNICO - pc_desativa_debitador_processo: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		  WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_desativa_debitador_processo: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
				ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_desativa_debitador_processo: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	 END;
END pc_desativa_debitador_processo;


PROCEDURE pc_exclui_debitador_prioridade(pr_nrprioridade IN TBGEN_DEBITADOR_PARAM.nrprioridade%TYPE -->Identificador unico da prioridade do processamento
                                        , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                        , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                        , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                        , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                        , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                        , pr_des_erro OUT VARCHAR2) IS

    /* ............................................................................
        Programa: pc_exclui_debitador_prioridades
        Sistema : Debitador Unico
        Sigla   : CECRED
        Autor   : Fabio Adriano
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para excluir prioridades (processos) na tabela TBGEN_DEBITADOR_PARAM
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

BEGIN

DECLARE
    CHECK_CONSTRAINT_VIOLATED EXCEPTION;
    PRAGMA EXCEPTION_INIT(CHECK_CONSTRAINT_VIOLATED, -2290);

    ----->>> VARIÁVEIS <<<-----

	  -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida         EXCEPTION;
		vr_exc_historico     EXCEPTION;
		vr_exc_naocadastrado EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

		vr_dsprocesso_ant VARCHAR2(300);  --> Valor anterior do campo para o histórico

     -- CURSOR - Dados da prioridade (processo)
    CURSOR cr_dados_prioridades IS
    SELECT p.dsprocesso
    FROM CECRED.TBGEN_DEBITADOR_PARAM p
    WHERE p.nrprioridade = pr_nrprioridade;
    rw_dados_prioridades cr_dados_prioridades%ROWTYPE;


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

			-- Criar cabeçalho do XML de retorno
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Root',
															pr_posicao  => 0,
															pr_tag_nova => 'Prioridades',
															pr_tag_cont => NULL,
															pr_des_erro => vr_dscritic);

			OPEN cr_dados_prioridades;
			FETCH cr_dados_prioridades INTO vr_dsprocesso_ant;

			IF cr_dados_prioridades%NOTFOUND THEN
				CLOSE cr_dados_prioridades;

				RAISE vr_exc_naocadastrado;
			END IF;

			CLOSE cr_dados_prioridades;

			-- Exclui a prioridade (processo) na tabela
			DELETE FROM TBGEN_DEBITADOR_PARAM
			 WHERE nrprioridade = pr_nrprioridade;

				pc_grava_historico(pr_cdoperador => vr_cdoperad
                         , pr_dscampo_alterado => 'dsprocesso'
												 , pr_dsvalor_anterior => vr_dsprocesso_ant
												 , pr_dsvalor_novo => NULL
												 , pr_cdprocesso => NULL
												 , pr_tpoperacao => 3
												 , pr_tporigem => 2
	                       , pr_dscritic => vr_dscritic);

				IF vr_dscritic IS NOT NULL THEN
					RAISE vr_exc_historico;
				END IF;

				COMMIT;

				-- Inclui dados no XML de retorno
				gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridades',
                               pr_posicao  => 0,
                               pr_tag_nova => 'excluido',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);

	 EXCEPTION
		  WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_prioridades: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		  WHEN vr_exc_naocadastrado THEN
        pr_dscritic := 'Erro na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_prioridades: o ID informado não foi encontrado.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		  WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_prioridades: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
			WHEN CHECK_CONSTRAINT_VIOLATED THEN
				pr_dscritic := 'Erro na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_prioridades: Há registros dependentes. Não é possível excluir.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
				ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_exclui_debitador_prioridades: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	 END;
END pc_exclui_debitador_prioridade;


PROCEDURE pc_redefine_debitador_priori(pr_nrprioridade IN TBGEN_DEBITADOR_PARAM.nrprioridade%TYPE -->Identificador unico da prioridade do processamento
                                     , pr_cdprocesso   IN TBGEN_DEBITADOR_PARAM.cdprocesso%TYPE -->Identificador unico do código do processo
                                     , pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                     , pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                     , pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                     , pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                     , pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                     , pr_des_erro OUT VARCHAR2) IS

    /* ............................................................................
        Programa: pc_redefine_debitador_priori
        Sistema : Debitador Automático
        Sigla   : CECRED
        Autor   : Fabio Adriano e Reginaldo Rubens da Silva
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para redefinir a prioridade de um processo na tabela TBGEN_DEBITADOR_PARAM
        Observacao: -----
        Alteracoes: 
    ..............................................................................*/

BEGIN

DECLARE

    ----->>> VARIÁVEIS <<<-----

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida         EXCEPTION;
    vr_exc_historico     EXCEPTION;
    vr_exc_naocadastrado EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_processo   tbgen_debitador_param.cdprocesso%TYPE;    --> Código do processo que trocará que prioridade com o passado no parâmetro
		vr_prioridade tbgen_debitador_param.nrprioridade%TYPE;  --> Prioridade atual do processo passado como parâmetro

    -- Identifica processo que já tem prioridade desejada definida para troca
    CURSOR cr_processo IS
    SELECT p.cdprocesso
    FROM CECRED.TBGEN_DEBITADOR_PARAM p
    where p.nrprioridade = pr_nrprioridade;
		
		-- Identifica a prioridade atual do processo passado como parâmetro
    CURSOR cr_prioridade IS
    SELECT p.nrprioridade
    FROM CECRED.TBGEN_DEBITADOR_PARAM p
    where p.cdprocesso = pr_cdprocesso;

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

      -- Criar cabeçalho do XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      OPEN cr_processo;
			FETCH cr_processo INTO vr_processo;
			CLOSE cr_processo;
			
			OPEN cr_prioridade;
			FETCH cr_prioridade INTO vr_prioridade;
			CLOSE cr_prioridade;
			
			-- Redefine prioridade temporário para processo que fará a troca (para evitar violação da UNIQUE KEY)
			UPDATE tbgen_debitador_param 
			   SET nrprioridade = 999
  		 WHERE cdprocesso = vr_processo;
			 
			-- Redefine a prioridade para o processo passado como parâmetro
			UPDATE tbgen_debitador_param
			   SET nrprioridade = pr_nrprioridade
			 WHERE cdprocesso = pr_cdprocesso;

      -- Altera a prioridade do processo
      UPDATE tbgen_debitador_param
         SET nrprioridade = pr_nrprioridade
       WHERE cdprocesso = pr_cdprocesso;
			 
			-- Concluir a troca 
			UPDATE tbgen_debitador_param
			   SET nrprioridade = vr_prioridade
			 WHERE cdprocesso = vr_processo;			

        pc_grava_historico(pr_cdoperador => vr_cdoperad
                         , pr_dscampo_alterado => 'nrprioridade'
                         , pr_dsvalor_anterior => vr_prioridade
                         , pr_dsvalor_novo => pr_nrprioridade
                         , pr_cdprocesso => pr_cdprocesso
                         , pr_tpoperacao => 2
                         , pr_tporigem => 1
                         , pr_dscritic => vr_dscritic);
												 
			  pc_grava_historico(pr_cdoperador => vr_cdoperad
                         , pr_dscampo_alterado => 'nrprioridade'
                         , pr_dsvalor_anterior => pr_nrprioridade
                         , pr_dsvalor_novo => vr_prioridade
                         , pr_cdprocesso => vr_processo
                         , pr_tpoperacao => 2
                         , pr_tporigem => 1
                         , pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_historico;
        END IF;

        COMMIT;

        -- Inclui dados no XML de retorno
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Prioridades',
                               pr_posicao  => 0,
                               pr_tag_nova => 'alterado',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);

   EXCEPTION
     WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_DEBITADOR_UNICO - pc_redefine_debitador_priori: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN vr_exc_naocadastrado THEN
        pr_dscritic := 'Erro na rotina da tela TELA_PARDBT - pc_redefine_debitador_priori: o ID do processo informado não foi encontrado.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		 WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_redefine_debitador_priori: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
				ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_redefine_debitador_priori: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	 END;
END pc_redefine_debitador_priori;

---------------------------- FIM PRIORIDADES -----------------------------


--------------------- INICIO HORARIOS PROCESSAMENTOS -----------------------
PROCEDURE pc_busca_debitador_hr_proces( pr_cdprocesso tbgen_debitador_param.cdprocesso%TYPE  --> Código do processo
	                                    , pr_xmllog   IN VARCHAR2                              --> XML com informações de LOG
                                      , pr_cdcritic OUT PLS_INTEGER                          --> Código da crítica
                                      , pr_dscritic OUT VARCHAR2                             --> Descrição da crítica
                                      , pr_retxml   IN OUT NOCOPY XMLType                    --> Arquivo de retorno do XML
                                      , pr_nmdcampo OUT VARCHAR2                             --> Nome do campo com erro
                                      , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_debitador_horarios_proc
        Sistema : CECRED
        Sigla   : DEB
        Autor   : Fabio Adriano
        Data    : Marco/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para buscar dados dos horários que podem ser incluídos num processo
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_contador INTEGER := 0;

    ----------->>> CURSORES <<<--------

    -- Dados dos horarios proc
    CURSOR cr_dados_horarios_proc IS
    SELECT h.idhora_processamento
         , to_char(h.dhprocessamento, 'HH24:MI') dhprocessamento
      FROM tbgen_debitador_horario h
		 WHERE h.idhora_processamento NOT IN (
		          SELECT idhora_processamento
							  FROM tbgen_debitador_horario_proc
							 WHERE cdprocesso = pr_cdprocesso	
		       )
     ORDER BY to_char(h.dhprocessamento, 'HH24:MI');
    rw_dados_horarios_proc cr_dados_horarios_proc%ROWTYPE;


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

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Horarios',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -- Percorre os horários
    FOR rw_dados_horarios_proc
      IN cr_dados_horarios_proc LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Horarios',
                               pr_posicao  => 0,
                               pr_tag_nova => 'horario',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        -- ID do registro
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'horario',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'idhora_processamento',
                               pr_tag_cont => rw_dados_horarios_proc.idhora_processamento,
                               pr_des_erro => pr_dscritic);

        -- Horário cadastrado
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'horario',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dhprocessamento',
                               pr_tag_cont => rw_dados_horarios_proc.dhprocessamento,
                               pr_des_erro => pr_dscritic);

        vr_contador := vr_contador + 1;
    END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_horarios_proc: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_horarios_proc: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_debitador_hr_proces;

PROCEDURE pc_busca_debitador_hr_exclus( pr_cdprocesso tbgen_debitador_param.cdprocesso%TYPE  --> Código do processo
	                                    , pr_xmllog   IN VARCHAR2                              --> XML com informações de LOG
                                      , pr_cdcritic OUT PLS_INTEGER                          --> Código da crítica
                                      , pr_dscritic OUT VARCHAR2                             --> Descrição da crítica
                                      , pr_retxml   IN OUT NOCOPY XMLType                    --> Arquivo de retorno do XML
                                      , pr_nmdcampo OUT VARCHAR2                             --> Nome do campo com erro
                                      , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_debitador_hr_exclus
        Sistema : CECRED
        Sigla   : DEB
        Autor   : Fabio Adriano
        Data    : Marco/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para buscar dados dos horários que podem ser excluídos num processo
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_contador INTEGER := 0;

    ----------->>> CURSORES <<<--------

    -- Dados dos horarios proc
    CURSOR cr_dados_horarios_proc IS
    SELECT h.idhora_processamento
         , to_char(h.dhprocessamento, 'HH24:MI') dhprocessamento
      FROM tbgen_debitador_horario h
		 WHERE h.idhora_processamento IN (
		          SELECT idhora_processamento
							  FROM tbgen_debitador_horario_proc
							 WHERE cdprocesso = pr_cdprocesso	
		       )
     ORDER BY to_char(h.dhprocessamento, 'HH24:MI');
    rw_dados_horarios_proc cr_dados_horarios_proc%ROWTYPE;


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

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Horarios',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -- Percorre os horários
    FOR rw_dados_horarios_proc
      IN cr_dados_horarios_proc LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Horarios',
                               pr_posicao  => 0,
                               pr_tag_nova => 'horario',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        -- ID do registro
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'horario',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'idhora_processamento',
                               pr_tag_cont => rw_dados_horarios_proc.idhora_processamento,
                               pr_des_erro => pr_dscritic);

        -- Horário cadastrado
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'horario',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dhprocessamento',
                               pr_tag_cont => rw_dados_horarios_proc.dhprocessamento,
                               pr_des_erro => pr_dscritic);

        vr_contador := vr_contador + 1;
    END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debpc_busca_debitador_hr_exclusitador_horarios_proc: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_hr_exclus: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_debitador_hr_exclus;




PROCEDURE pc_inclui_debitador_hr_proces( pr_cdprocesso           IN TBGEN_DEBITADOR_HORARIO_PROC.cdprocesso%TYPE           -->Codigo de identificacao do processo
                                       , pr_idhora_processamento IN TBGEN_DEBITADOR_HORARIO_PROC.idhora_processamento%TYPE -->Identificador do horario do processamento
                                       , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                       , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                       , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                       , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                       , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                       , pr_des_erro OUT VARCHAR2) IS

    /* ............................................................................
        Programa: pc_inclui_debitador_horarios_proc
        Sistema : Debitador Automático
        Sigla   : CECRED
        Autor   : Fabio Adriano
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para inserir novo horário proc na tabela TBGEN_DEBITADOR_HORARIO_PROC
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

BEGIN

DECLARE
    ----->>> CURSORES <<<-----
		
		-- Busca horário para incluir no histórico
		CURSOR cr_horario IS
		SELECT to_char(hor.dhprocessamento, 'HH24:MI') dhprocessamento
		  FROM tbgen_debitador_horario hor
	   WHERE hor.idhora_processamento = pr_idhora_processamento;
		  
		-- Busca a prioridade do processo para reposicionamento em tela
		CURSOR cr_prioridade IS
		SELECT prc.nrprioridade
		  FROM tbgen_debitador_param prc
		 WHERE prc.cdprocesso = pr_cdprocesso;
		
    ----->>> VARIÁVEIS <<<-----

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    vr_exc_historico EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		vr_dhprocessamento  VARCHAR2(5);  -- Horário para inclusão no histórico
		vr_nrprioridade     NUMBER(3);    -- Prioridade do processo para reposicionamento em tela

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

      -- Criar cabeçalho do XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                              pr_tag_pai  => 'Root',
                              pr_posicao  => 0,
                              pr_tag_nova => 'Dados',
                              pr_tag_cont => NULL,
                              pr_des_erro => vr_dscritic);
															
			OPEN cr_horario;
			FETCH cr_horario INTO vr_dhprocessamento;
			CLOSE cr_horario;
			
			OPEN cr_prioridade;
			FETCH cr_prioridade INTO vr_nrprioridade;
			CLOSE cr_prioridade;

      -- Insere o novo horário Proc na tabela
      INSERT
        INTO TBGEN_DEBITADOR_HORARIO_PROC (
             cdprocesso
           , idhora_processamento
        )
        VALUES (
             pr_cdprocesso
           , pr_idhora_processamento
        );

        pc_grava_historico(pr_cdoperador => vr_cdoperad
                         , pr_dscampo_alterado => 'idhora_processamento'
                         , pr_dsvalor_anterior => NULL
                         , pr_dsvalor_novo => vr_dhprocessamento
                         , pr_cdprocesso => pr_cdprocesso
                         , pr_tpoperacao => 1
                         , pr_tporigem => 1
                         , pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_historico;
        END IF;

        COMMIT;

        -- Inclui dados no XML de retorno
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inserido',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'cdprocesso',
                               pr_tag_cont => pr_cdprocesso,
                               pr_des_erro => pr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'idhora_processamento',
                               pr_tag_cont => pr_idhora_processamento,
                               pr_des_erro => pr_dscritic);
															 
				gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'nrprioridade',
                               pr_tag_cont => vr_nrprioridade,
                               pr_des_erro => pr_dscritic);

   EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        pr_dscritic := 'Horário Proc já cadastrado. Não é possível incluir novamente.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_PARDBT - pc_inclui_debitador_hr_proces: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_PARDBT - pc_inclui_debitador_hr_proces: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_inclui_debitador_hr_proces: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   END;

END pc_inclui_debitador_hr_proces;


PROCEDURE pc_exclui_debitador_hr_proces(pr_cdprocesso           IN TBGEN_DEBITADOR_HORARIO_PROC.cdprocesso%TYPE           -->Codigo de identificacao do processo
                                      , pr_horarios IN VARCHAR2                                 -->Identificador do horario do processamento
                                      , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                      , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                      , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                      , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                      , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                      , pr_des_erro OUT VARCHAR2) IS

    /* ............................................................................
        Programa: pc_exclui_debitador_horarios_proc
        Sistema : Debitador Unico
        Sigla   : CECRED
        Autor   : Fabio Adriano
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para excluir horário proc na tabela TBGEN_DEBITADOR_HORARIO_PROC
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

BEGIN

DECLARE
    ----->>> CURSORES <<<-----
		
    -- Busca horário para incluir no histórico
		CURSOR cr_horario(pr_idhora_processamento tbgen_debitador_horario.idhora_processamento%TYPE) IS
		SELECT to_char(hor.dhprocessamento, 'HH24:MI') dhprocessamento
		  FROM tbgen_debitador_horario hor
	   WHERE hor.idhora_processamento = pr_idhora_processamento;
		 
		-- Busca a prioridade do processo para reposicionamento em tela
		CURSOR cr_prioridade IS
		SELECT prc.nrprioridade
		  FROM tbgen_debitador_param prc
		 WHERE prc.cdprocesso = pr_cdprocesso;	
		 
    ----->>> VARIÁVEIS <<<-----

	  -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida         EXCEPTION;
		vr_exc_historico     EXCEPTION;
		vr_exc_naocadastrado EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		vr_dhprocessamento VARCHAR2(5);  --> Horário para inclusão no histórico
		vr_idhora_processamento tbgen_debitador_horario.idhora_processamento%TYPE;
		vr_nrprioridade      NUMBER(3);    --> Prioridade do processo para reposicionamento em tela
		
		l_count binary_integer;
    l_array dbms_utility.lname_array;

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

			-- Criar cabeçalho do XML de retorno
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Root',
															pr_posicao  => 0,
															pr_tag_nova => 'Dados',
															pr_tag_cont => NULL,
															pr_des_erro => vr_dscritic);
			
			OPEN cr_prioridade;
			FETCH cr_prioridade INTO vr_nrprioridade;
			CLOSE cr_prioridade;

			dbms_utility.comma_to_table(list   => pr_horarios
                                 , tablen => l_count
                                 , tab    => l_array);
																 
				FOR i IN 1 .. l_count
				LOOP
				    vr_idhora_processamento := to_number(substr(l_array(i), 2, length(l_array(i))-1));	
						
						OPEN cr_horario(vr_idhora_processamento);
					  FETCH cr_horario INTO vr_dhprocessamento;
					  CLOSE cr_horario;      
				
					  DELETE FROM tbgen_debitador_horario_proc
						 WHERE cdprocesso = pr_cdprocesso
						   AND idhora_processamento = vr_idhora_processamento;
						
						OPEN cr_horario(vr_idhora_processamento);
						FETCH cr_horario INTO vr_dhprocessamento;
						CLOSE cr_horario;
						
				    pc_grava_historico(pr_cdoperador => vr_cdoperad
                             , pr_dscampo_alterado => 'idhora_processamento'
											     	 , pr_dsvalor_anterior => NULL
											    	 , pr_dsvalor_novo => vr_dhprocessamento
											    	 , pr_cdprocesso => pr_cdprocesso
											     	 , pr_tpoperacao => 3
											    	 , pr_tporigem => 1
	                           , pr_dscritic => vr_dscritic);	
				    
						
						IF vr_dscritic IS NOT NULL THEN
							RAISE vr_exc_historico;
						END IF;
				END LOOP;

				COMMIT;

				-- Inclui dados no XML de retorno
				gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'excluido',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);
															 
				-- Inclui dados no XML de retorno
				gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'nrprioridade',
                               pr_tag_cont => vr_nrprioridade,
                               pr_des_erro => pr_dscritic);
				

	 EXCEPTION
		  WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_hr_proces: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		  WHEN vr_exc_naocadastrado THEN
        pr_dscritic := 'Erro na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_horarios_proc: o ID informado não foi encontrado.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		  WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_hr_proces: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
				ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_exclui_debitador_hr_proces: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	 END;
END pc_exclui_debitador_hr_proces;


----------------------- FIM HORARIOS PROCESSAMENTOS ------------------------

----------------------- INÍCIO EXECUÇÃO EMERGENCIAL ------------------------

PROCEDURE pc_executar_debitador_emergen(pr_processos IN VARCHAR2         --> Lista de processos a executar (separada por ";")
                                      , pr_xmllog    IN VARCHAR2                     --> XML com informações de LOG
                                      , pr_cdcritic  OUT PLS_INTEGER                 --> Código da crítica
                                      , pr_dscritic  OUT VARCHAR2                    --> Descrição da crítica
                                      , pr_retxml    IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                      , pr_nmdcampo  OUT VARCHAR2                    --> Nome do campo com erro
                                      , pr_des_erro  OUT VARCHAR2) IS

    /* ............................................................................
        Programa: pc_executar_debitador_emergen
        Sistema : Debitador Unico
        Sigla   : CECRED
        Autor   : Reginaldo Rubens da Silva
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para criar JOB de execução emergencial dos processos
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

BEGIN
	
DECLARE
    ----->>> VARIÁVEIS <<<-----

	  -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida         EXCEPTION;
		vr_exc_historico     EXCEPTION;
		vr_exc_naocadastrado EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

		vr_dhprocessamento_ant VARCHAR2(10);  --> Valor anterior do campo para o histórico
		
		l_count binary_integer;
    l_array dbms_utility.lname_array;

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

			-- Criar cabeçalho do XML de retorno
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Root',
															pr_posicao  => 0,
															pr_tag_nova => 'Dados',
															pr_tag_cont => NULL,
															pr_des_erro => vr_dscritic);

       dbms_utility.comma_to_table(list   => pr_processos
                                 , tablen => l_count
                                 , tab    => l_array);
																 
				FOR i IN 1 .. l_count
				LOOP
					  /* INCLUIR CHAMADA DA CRIAÇÃO DO JOB PARA A EXECUÇÃO EMERGENCIAL DO PROCESSO */
						
				    pc_grava_historico(pr_cdoperador => vr_cdoperad
                             , pr_dscampo_alterado => 'exec_emergencial'
											     	 , pr_dsvalor_anterior => NULL
											    	 , pr_dsvalor_novo => NULL
											    	 , pr_cdprocesso => l_array(i) -- Processo
											     	 , pr_tpoperacao => 4
											    	 , pr_tporigem => 3
	                           , pr_dscritic => vr_dscritic);	
				
					
				END LOOP;		

				IF vr_dscritic IS NOT NULL THEN
					RAISE vr_exc_historico;
				END IF;

				COMMIT;

				-- Inclui dados no XML de retorno
				gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'processado',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);

	 EXCEPTION
		  WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_DEBITADOR_UNICO - pc_executar_debitador_emergen: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		  WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_executar_debitador_emergen: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
				ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_executar_debitador_emergen: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	 END;
END pc_executar_debitador_emergen;

----------------------- FIM EXECUÇÃO EMERGENCIAL ------------------------

END TELA_DEBITADOR_UNICO;
/
