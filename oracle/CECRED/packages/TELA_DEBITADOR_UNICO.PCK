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

--------------------- INICIO HORARIOS -----------------------  
PROCEDURE pc_busca_debitador_horarios(-- pr_idhora_processamento IN TBGEN_DEBITADOR_HORARIO.idhora_processamento%TYPE -->Identificador unico do horario do processamento
                                     --, pr_dhprocessamento      OUT TBGEN_DEBITADOR_HORARIO.dhprocessamento%TYPE      -->Hora do processamento
                                      pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     , pr_des_erro OUT VARCHAR2);

PROCEDURE pc_inclui_debitador_horarios( pr_dhprocessamento      IN TBGEN_DEBITADOR_HORARIO.dhprocessamento%TYPE      -->Hora do processamento
                                      , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                      , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                      , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                      , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                      , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                      , pr_des_erro OUT VARCHAR2);   
 
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
PROCEDURE pc_busca_debitador_prioridades(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
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

PROCEDURE pc_exclui_debitador_prioridades(pr_nrprioridade IN TBGEN_DEBITADOR_PARAM.nrprioridade%TYPE -->Identificador unico da prioridade do processamento
                                        , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                        , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                        , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                        , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                        , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                        , pr_des_erro OUT VARCHAR2);
 
PROCEDURE pc_altera_debitador_prioridades(pr_nrprioridade IN TBGEN_DEBITADOR_PARAM.nrprioridade%TYPE -->Identificador unico da prioridade do processamento
                                        , pr_cdprocesso   IN TBGEN_DEBITADOR_PARAM.cdprocesso%TYPE -->Identificador unico do código do processo
                                        , pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                        , pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                        , pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                        , pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                        , pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                        , pr_des_erro OUT VARCHAR2);
---------------------------- FIM PRIORIDADES -----------------------------                                         


--------------------- INICIO HORARIOS PROCESSAMENTOS -----------------------  
PROCEDURE pc_busca_debitador_horarios_proc( pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                          , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                          , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          , pr_des_erro OUT VARCHAR2);

PROCEDURE pc_inclui_debitador_horarios_proc( pr_cdprocesso           IN TBGEN_DEBITADOR_HORARIO_PROC.cdprocesso%TYPE           -->Codigo de identificacao do processo
                                           , pr_idhora_processamento IN TBGEN_DEBITADOR_HORARIO_PROC.idhora_processamento%TYPE -->Identificador do horario do processamento
                                           , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                           , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                           , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                           , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                           , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                           , pr_des_erro OUT VARCHAR2);   
 
PROCEDURE pc_exclui_debitador_horarios_proc(pr_cdprocesso           IN TBGEN_DEBITADOR_HORARIO_PROC.cdprocesso%TYPE           -->Codigo de identificacao do processo
                                          , pr_idhora_processamento IN TBGEN_DEBITADOR_HORARIO_PROC.idhora_processamento%TYPE -->Identificador do horario do processamento
                                          , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                          , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                          , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                          , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                          , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                          , pr_des_erro OUT VARCHAR2);

----------------------- FIM HORARIOS PROCESSAMENTOS ------------------------


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
    CURSOR cr_dados_horarios --(pr_idhora_processamento TBGEN_DEBITADOR_HORARIO.idhora_processamento%TYPE -->Identificador unico do horario do processamento
                             --, pr_dhprocessamento      TBGEN_DEBITADOR_HORARIO.dhprocessamento%TYPE ) IS -->Hora do processamento 
                             IS
    SELECT h.idhora_processamento
         , to_char(h.dhprocessamento, 'HH24:MI') dhprocessamento
    FROM CECRED.TBGEN_DEBITADOR_HORARIO h
    --WHERE h.idhora_processamento = pr_idhora_processamento
    --  AND h.dhprocessamento      = pr_dhprocessamento
    ORDER BY h.dhprocessamento;  
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

    OPEN cr_dados_horarios; --(pr_idhora_processamento, pr_dhprocessamento);

    FETCH cr_dados_horarios INTO rw_dados_horarios;

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
                               pr_tag_pai  => 'Horarios',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'idhora_processamento',
                               pr_tag_cont => rw_dados_horarios.idhora_processamento,
                               pr_des_erro => pr_dscritic);

        -- Horário cadastrado
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Hora',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dhprocessamento',
                               pr_tag_cont => rw_dados_horarios.dhprocessamento,
                               pr_des_erro => pr_dscritic);

        vr_contador := vr_contador + 1;
    END LOOP;
    
    CLOSE cr_dados_horarios;

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


PROCEDURE pc_inclui_debitador_horarios(pr_dhprocessamento      IN TBGEN_DEBITADOR_HORARIO.dhprocessamento%TYPE      -->Hora do processamento
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
    
    vr_idhora_processamento INTEGER;    --> ID do novo registro
   
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
      
      -- Insere o novo horário na tabela
      INSERT 
        INTO tbgen_debitador_horario (
             idhora_processamento
           , dhprocessamento
        )
        VALUES (
             vr_idhora_processamento
           , to_date(pr_dhprocessamento, 'DD/MM/YYYY HH24:MI')
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
         SET dhprocessamento = to_date(pr_dhprocessamento, 'DD/MM/YYYY HH24:MI')
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
			
			-- Exclui o horário na tabela
			DELETE FROM tbgen_debitador_horario 
			 WHERE idhora_processamento = pr_idhora_processamento;
				
				pc_grava_historico(pr_cdoperador => vr_cdoperad
                         , pr_dscampo_alterado => 'dhprocessamento'
												 , pr_dsvalor_anterior => vr_dhprocessamento_ant
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
                               pr_tag_pai  => 'Horarios',
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
		  WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_horarios: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
			WHEN CHECK_CONSTRAINT_VIOLATED THEN 
				pr_dscritic := 'Erro na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_horarios: Há registros dependentes. Não é possível excluir.';
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
PROCEDURE pc_busca_debitador_prioridades(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
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
           p.nrprioridade
    FROM CECRED.TBGEN_DEBITADOR_PARAM p
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

    OPEN cr_dados_prioridades; 

    FETCH cr_dados_prioridades INTO rw_dados_prioridades;

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
    
    CLOSE cr_dados_prioridades;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_prioridades: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitador_prioridades: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_debitador_prioridades;

                                     
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
           p.nrprioridade
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

    OPEN cr_dados_prioridades; 

    FETCH cr_dados_prioridades INTO rw_dados_prioridades;

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
    
    CLOSE cr_dados_prioridades;

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


PROCEDURE pc_exclui_debitador_prioridades(pr_nrprioridade IN TBGEN_DEBITADOR_PARAM.nrprioridade%TYPE -->Identificador unico da prioridade do processamento
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
    SELECT p.cdprocesso 
         , p.dsprocesso        
         , p.indeb_sem_saldo   
         , p.indeb_parcial     
         , p.qtdias_repescagem 
           p.nrprioridade
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
END pc_exclui_debitador_prioridades;                                        

 
PROCEDURE pc_altera_debitador_prioridades(pr_nrprioridade IN TBGEN_DEBITADOR_PARAM.nrprioridade%TYPE -->Identificador unico da prioridade do processamento
                                        , pr_cdprocesso   IN TBGEN_DEBITADOR_PARAM.cdprocesso%TYPE -->Identificador unico do código do processo
                                        , pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                        , pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                        , pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                        , pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                        , pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                        , pr_des_erro OUT VARCHAR2) IS
                                       
    /* ............................................................................
        Programa: pc_altera_debitador_prioridades
        Sistema : Debitador Automático
        Sigla   : CECRED
        Autor   : Fabio Adriano 
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para alterar prioridades (processos) na tabela TBGEN_DEBITADOR_PARAM
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
    vr_nrprioridade_ant NUMBER(3);  --> Valor anterior do campo para o histórico
    
    -- Dados das prioridades (processos)
    CURSOR cr_dados_prioridades IS
    SELECT --p.cdprocesso 
         --, p.dsprocesso        
         --, p.indeb_sem_saldo   
         --, p.indeb_parcial     
         --, p.qtdias_repescagem 
           p.nrprioridade
    FROM CECRED.TBGEN_DEBITADOR_PARAM p
    where p.cdprocesso = pr_cdprocesso;  
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
                             pr_tag_pai  => 'Prioridades',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Prioridades',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
                              
      OPEN cr_dados_prioridades;
      FETCH cr_dados_prioridades INTO vr_nrprioridade_ant;
      
      IF cr_dados_prioridades%NOTFOUND THEN
        CLOSE cr_dados_prioridades;
        
        RAISE vr_exc_naocadastrado;
      END IF;
      
      CLOSE cr_dados_prioridades;
      
      -- Altera o horário na tabela
      UPDATE TBGEN_DEBITADOR_HORARIO_PROC 
         SET nrprioridade = pr_nrprioridade
       WHERE cdprocesso = pr_cdprocesso;
        
        pc_grava_historico(pr_cdoperador => vr_cdoperad
                         , pr_dscampo_alterado => 'nrprioridade'
                         , pr_dsvalor_anterior => vr_nrprioridade_ant
                         , pr_dsvalor_novo => pr_nrprioridade
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
                               pr_tag_pai  => 'Prioridades',
                               pr_posicao  => 0,
                               pr_tag_nova => 'alterado',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);
                              
   EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        pr_dscritic := 'Outro registro com a mesma prioridade já cadastrado. Não é possível alterar.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_DEBITADOR_UNICO - pc_altera_debitador_prioridades: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN vr_exc_naocadastrado THEN
        pr_dscritic := 'Erro na rotina da tela TELA_PARDBT - pc_altera_debitador_horarios: o ID informado não foi encontrado.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		 WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_altera_debitador_prioridades: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
				ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_altera_debitador_prioridades: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	 END; 
END pc_altera_debitador_prioridades;
                                        
---------------------------- FIM PRIORIDADES -----------------------------                                         


--------------------- INICIO HORARIOS PROCESSAMENTOS -----------------------  
PROCEDURE pc_busca_debitador_horarios_proc( pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                          , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                          , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
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
        Objetivo  : Rotina para buscar dados dos horários de processamentos
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

    -- Dados dos horarios proc
    CURSOR cr_dados_horarios_proc IS
    SELECT h.cdprocesso
         , h.idhora_processamento
    FROM CECRED.TBGEN_DEBITADOR_HORARIO_PROC h
    ORDER BY h.idhora_processamento;  
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
                           pr_tag_nova => 'Horarios Proc',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    OPEN cr_dados_horarios_proc; 

    FETCH cr_dados_horarios_proc INTO rw_dados_horarios_proc;

    -- Percorre os horários
    FOR rw_dados_horarios_proc
      IN cr_dados_horarios_proc LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Horarios Proc',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Horarios Proc',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        -- ID do registro
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Horarios Proc',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdprocesso',
                               pr_tag_cont => rw_dados_horarios_proc.cdprocesso,
                               pr_des_erro => pr_dscritic);

        -- Horário cadastrado
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Horarios Proc',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'idhora_processamento',
                               pr_tag_cont => rw_dados_horarios_proc.idhora_processamento,
                               pr_des_erro => pr_dscritic);

        vr_contador := vr_contador + 1;
    END LOOP;
    
    CLOSE cr_dados_horarios_proc;

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
END pc_busca_debitador_horarios_proc;

                                          

PROCEDURE pc_inclui_debitador_horarios_proc( pr_cdprocesso           IN TBGEN_DEBITADOR_HORARIO_PROC.cdprocesso%TYPE           -->Codigo de identificacao do processo
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
    
    vr_idhora_processamento INTEGER;    --> ID do novo registro
   
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
                              pr_tag_nova => 'Horarios Proc',
                              pr_tag_cont => NULL,
                              pr_des_erro => vr_dscritic);
                              
      -- Obtém o próximo ID para inserir na tabela                              
      vr_idhora_processamento := fn_obtem_proximo_id;
      
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
                         , pr_dsvalor_novo => pr_idhora_processamento
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
                               pr_tag_pai  => 'Horarios Proc',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inserido',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Horarios Proc',
                               pr_posicao  => 0,
                               pr_tag_nova => 'cdprocesso',
                               pr_tag_cont => pr_cdprocesso,
                               pr_des_erro => pr_dscritic);                       
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Horarios Proc',
                               pr_posicao  => 0,
                               pr_tag_nova => 'idhora_processamento',
                               pr_tag_cont => pr_idhora_processamento,
                               pr_des_erro => pr_dscritic);
                              
   EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        pr_dscritic := 'Horário Proc já cadastrado. Não é possível incluir novamente.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_PARDBT - pc_inclui_debitador_horarios_proc: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_PARDBT - pc_inclui_debitador_horarios_proc: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_inclui_debitador_horarios_proc: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   END; 
   
END pc_inclui_debitador_horarios_proc;
                                             
 
PROCEDURE pc_exclui_debitador_horarios_proc(pr_cdprocesso           IN TBGEN_DEBITADOR_HORARIO_PROC.cdprocesso%TYPE           -->Codigo de identificacao do processo
                                          , pr_idhora_processamento IN TBGEN_DEBITADOR_HORARIO_PROC.idhora_processamento%TYPE -->Identificador do horario do processamento
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
		
		vr_dhprocessamento_ant VARCHAR2(10);  --> Valor anterior do campo para o histórico
		
		-- Dados dos horarios proc
    CURSOR cr_dados_horarios_proc IS
    SELECT h.cdprocesso
         , h.idhora_processamento
    FROM CECRED.TBGEN_DEBITADOR_HORARIO_PROC h
    where h.cdprocesso = pr_cdprocesso
     and  h.idhora_processamento = pr_idhora_processamento
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
															pr_tag_pai  => 'Horarios Proc',
															pr_posicao  => 0,
															pr_tag_nova => 'Horarios Proc',
															pr_tag_cont => NULL,
															pr_des_erro => vr_dscritic);
															
			OPEN cr_dados_horarios_proc;
			FETCH cr_dados_horarios_proc INTO vr_dhprocessamento_ant;
			
			IF cr_dados_horarios_proc%NOTFOUND THEN
				CLOSE cr_dados_horarios_proc;
				
				RAISE vr_exc_naocadastrado;
			END IF;
			
			CLOSE cr_dados_horarios_proc;
			
			-- Exclui o horário na tabela
			DELETE FROM TBGEN_DEBITADOR_HORARIO_PROC 
			 WHERE cdprocesso = pr_cdprocesso
         and idhora_processamento = pr_idhora_processamento;
				
				pc_grava_historico(pr_cdoperador => vr_cdoperad
                         , pr_dscampo_alterado => 'idhora_processamento'
												 , pr_dsvalor_anterior => vr_dhprocessamento_ant
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
                               pr_tag_pai  => 'Horarios Proc',
                               pr_posicao  => 0,
                               pr_tag_nova => 'excluido',
                               pr_tag_cont => 'S',
                               pr_des_erro => pr_dscritic);
															
	 EXCEPTION
		  WHEN vr_exc_historico THEN
        pr_dscritic := 'Erro de gravação de histórico na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_horarios_proc: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		  WHEN vr_exc_naocadastrado THEN
        pr_dscritic := 'Erro na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_horarios_proc: o ID informado não foi encontrado.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		  WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_horarios_proc: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
			WHEN CHECK_CONSTRAINT_VIOLATED THEN 
				pr_dscritic := 'Erro na rotina da tela TELA_DEBITADOR_UNICO - pc_exclui_debitador_horarios_proc: Há registros dependentes. Não é possível excluir.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
				ROLLBACK;
        pr_dscritic := 'Erro não tratado na rotina da tela THEN - pc_exclui_debitador_horarios_proc: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	 END; 
END pc_exclui_debitador_horarios_proc;
                                          

----------------------- FIM HORARIOS PROCESSAMENTOS ------------------------

END TELA_DEBITADOR_UNICO;
/
