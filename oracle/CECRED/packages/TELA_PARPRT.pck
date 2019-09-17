CREATE OR REPLACE PACKAGE CECRED.TELA_PARPRT IS

  /* .............................................................................
  
  Programa: pc_busca_param
  Sistema : Ayllos Web
  Autor   : Marcus Guilherme Kaefer
  Data    : Janeiro/2018                 Ultima atualizacao: 29/01/2018

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado

  Objetivo  : Rotina para buscar parametrizacao de Negativacao Serasa.

  Alteracoes: Adaptado script para contemplar os parametros da tela PARPRT
  ..............................................................................*/

  PROCEDURE pc_consulta_parprt(pr_cdcooper 				IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                          ,pr_xmllog   					IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic 					OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic 					OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   					IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo 					OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro 					OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_atualiza_parprt(pr_cdcooper 				IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
						   ,pr_qtlimitemin_tolerancia	IN TBCOBRAN_PARAM_PROTESTO.qtlimitemin_tolerancia%TYPE --> Limite minimo tolerancia (em dias) para envio de boleto para protesto
                           ,pr_qtlimitemax_tolerancia	IN TBCOBRAN_PARAM_PROTESTO.qtlimitemax_tolerancia%TYPE --> Limite maximo tolerancia (em dias) para envio de boleto para protesto
                           ,pr_hrenvio_arquivo      	IN VARCHAR2 --> Horario para envio do arquivo
                           ,pr_qtdias_cancelamento  	IN TBCOBRAN_PARAM_PROTESTO.qtdias_cancelamento%TYPE --> Quantidade de dias que para solicitar cancelamento
                           ,pr_flcancelamento         	IN TBCOBRAN_PARAM_PROTESTO.flcancelamento%TYPE --> Flag para definir se permite cancelamento quando boleto ja estiver em cartorio
                           ,pr_dsuf                   	IN TBCOBRAN_PARAM_PROTESTO.dsuf%TYPE --> Lista de UFs que autorizam exclusão
                           ,pr_dscnae                 	IN TBCOBRAN_PARAM_PROTESTO.dscnae%TYPE --> Lista de CNAEs não permitidos para protesto
                           ,pr_dsnegufds                IN TBCOBRAN_PARAM_PROTESTO.dsnegufds%TYPE --> UFs nao autorizadas a protestar boletos com DS
                           ,pr_xmllog                 	IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic               	OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic               	OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml                 	IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo               	OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro               	OUT VARCHAR2); --> Erros do processo
						   
  PROCEDURE pc_consulta_periodo_parprt (pr_cdcooper                 IN crapcop.cdcooper%TYPE
									   ,pr_qtlimitemin_tolerancia  OUT INTEGER
									   ,pr_qtlimitemax_tolerancia  OUT INTEGER
									   ,pr_des_erro                OUT VARCHAR2
									   ,pr_dscritic                OUT VARCHAR2);
									   
  PROCEDURE pc_consulta_ufs_parprt (pr_cdcooper                IN crapcop.cdcooper%TYPE
                                   ,pr_dsuf                    OUT VARCHAR2
                                   ,pr_des_erro                OUT VARCHAR2
                                   ,pr_dscritic                OUT VARCHAR2);

  PROCEDURE pc_validar_dsnegufds_parprt(pr_cdcooper    IN crapsab.cdcooper%TYPE
                                       ,pr_cdufsaca    IN crapsab.cdufsaca%TYPE
                                       ,pr_des_erro    OUT VARCHAR2
                                       ,pr_dscritic    OUT VARCHAR2);

END TELA_PARPRT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARPRT IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_PARPRT
  --  Sistema  : Aimaro Web
  --  Autor    : Marcus Guilherme Kaefer
  --  Data     : Janeiro - 2018                 Ultima atualizacao: 08/10/2018
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela PARPRT
  --
  -- Alteracoes: Adaptado script para contemplar os parametros da tela PARPRT
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_consulta_parprt(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                          ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_param
    Sistema : Aimaro Web
    Autor   : Marcus Guilherme Kaefer
    Data    : Janeiro/2018                 Ultima atualizacao: 08/10/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar parametrizacao de Negativacao Serasa.

    Alteracoes: Adaptado script para contemplar os parametros da tela PARPRT
  
                08/10/2018 - Inclusao de parametro dsnegufds referente às UFs nao autorizadas 
                             a protestar boletos com DS. (projeto "PRJ352 - Protesto" - 
                             Marcelo R. Kestring - Supero)

    ..............................................................................*/
    DECLARE

      -- Selecionar os dados da parametrizacao
      CURSOR cr_param(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT TBCOBRAN_PARAM_PROTESTO.dsuf,
               TBCOBRAN_PARAM_PROTESTO.dscnae,
               TO_CHAR(TO_DATE(TBCOBRAN_PARAM_PROTESTO.hrenvio_arquivo,'SSSSS'),'HH24:MI') hrenvio_arquivo,
               TBCOBRAN_PARAM_PROTESTO.qtlimitemin_tolerancia,
               TBCOBRAN_PARAM_PROTESTO.qtlimitemax_tolerancia,
               TBCOBRAN_PARAM_PROTESTO.qtdias_cancelamento,
               TBCOBRAN_PARAM_PROTESTO.flcancelamento,
               TBCOBRAN_PARAM_PROTESTO.dsnegufds
          FROM TBCOBRAN_PARAM_PROTESTO
         WHERE TBCOBRAN_PARAM_PROTESTO.cdcooper = pr_cdcooper;

      rw_param cr_param%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Cursor com os dados
      OPEN cr_param(pr_cdcooper => pr_cdcooper);
      FETCH cr_param INTO rw_param;
      CLOSE cr_param;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inf'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtlimitemin_tolerancia'
                            ,pr_tag_cont => rw_param.qtlimitemin_tolerancia
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtlimitemax_tolerancia'
                            ,pr_tag_cont => rw_param.qtlimitemax_tolerancia
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'hrenvio_arquivo'
                            ,pr_tag_cont => rw_param.hrenvio_arquivo
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdias_cancelamento'
                            ,pr_tag_cont => rw_param.qtdias_cancelamento
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flcancelamento'
                            ,pr_tag_cont => rw_param.flcancelamento
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dsuf'
                            ,pr_tag_cont => rw_param.dsuf
                            ,pr_des_erro => vr_dscritic);
                            
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dscnae'
                            ,pr_tag_cont => rw_param.dscnae
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dsnegufds'
                            ,pr_tag_cont => rw_param.dsnegufds
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARPRT: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_consulta_parprt;
  
  PROCEDURE pc_atualiza_parprt(pr_cdcooper 				    IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
						               ,pr_qtlimitemin_tolerancia	IN TBCOBRAN_PARAM_PROTESTO.qtlimitemin_tolerancia%TYPE --> Limite minimo tolerancia (em dias) para envio de boleto para protesto
                           ,pr_qtlimitemax_tolerancia	IN TBCOBRAN_PARAM_PROTESTO.qtlimitemax_tolerancia%TYPE --> Limite maximo tolerancia (em dias) para envio de boleto para protesto
                           ,pr_hrenvio_arquivo      	IN VARCHAR2 --> Horario para envio do arquivo
                           ,pr_qtdias_cancelamento  	IN TBCOBRAN_PARAM_PROTESTO.qtdias_cancelamento%TYPE --> Quantidade de dias que para solicitar cancelamento
                           ,pr_flcancelamento       	IN TBCOBRAN_PARAM_PROTESTO.flcancelamento%TYPE --> Flag para definir se permite cancelamento quando boleto ja estiver em cartorio
                           ,pr_dsuf                 	IN TBCOBRAN_PARAM_PROTESTO.dsuf%TYPE --> Lista de UFs que autorizam exclusão
                           ,pr_dscnae                 IN TBCOBRAN_PARAM_PROTESTO.dscnae%TYPE --> Lista de CNAEs não permitidos para protesto
                           ,pr_dsnegufds                IN TBCOBRAN_PARAM_PROTESTO.dsnegufds%TYPE --> UFs nao autorizadas a protestar boletos com DS
                           ,pr_xmllog                 IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic               OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic               OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml                 IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo               OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro               OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_atualiza_parprt
    Sistema : Aimaro Web
    Autor   : Marcus Guilherme Kaefer
    Data    : Janeiro/2018                 Ultima atualizacao: 08/10/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar parametrizacao de Negativacao Serasa.

    Alteracoes: Adaptado script para contemplar os parametros da tela PARPRT
  
                08/10/2018 - Inclusao de parametro dsnegufds referente às UFs nao autorizadas 
                             a protestar boletos com DS. (projeto "PRJ352 - Protesto" - 
                             Marcelo R. Kestring - Supero)

    ..............................................................................*/
    DECLARE

		  -- Selecionar os dados da parametrizacao
      CURSOR cr_param IS
        SELECT TBCOBRAN_PARAM_PROTESTO.hrenvio_arquivo
          FROM TBCOBRAN_PARAM_PROTESTO
         WHERE TBCOBRAN_PARAM_PROTESTO.cdcooper = 3; -- Central
      rw_param cr_param%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis gerais
      vr_hrenvio_arquivo tbcobran_param_protesto.hrenvio_arquivo%TYPE;

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Caso prazo minimo seja maior que o maximo
      IF pr_qtlimitemin_tolerancia > pr_qtlimitemax_tolerancia THEN
        vr_dscritic := 'Limite minimo deve ser menor que o limite maximo.';
        RAISE vr_exc_saida;
      END IF;

      IF pr_cdcooper <> 3 THEN
				-- Retorna o horario da Central e salva na vr_hrenvio_arquivo
				OPEN cr_param;
				FETCH cr_param INTO rw_param;
        CLOSE cr_param;

      BEGIN
					-- Inserir registro (considerando o horario da central)
        INSERT INTO TBCOBRAN_PARAM_PROTESTO
                   (TBCOBRAN_PARAM_PROTESTO.cdcooper
                   ,TBCOBRAN_PARAM_PROTESTO.qtlimitemin_tolerancia
                   ,TBCOBRAN_PARAM_PROTESTO.qtlimitemax_tolerancia
                   ,TBCOBRAN_PARAM_PROTESTO.hrenvio_arquivo
                   ,TBCOBRAN_PARAM_PROTESTO.qtdias_cancelamento
                   ,TBCOBRAN_PARAM_PROTESTO.flcancelamento
                   ,TBCOBRAN_PARAM_PROTESTO.dsuf
                   ,TBCOBRAN_PARAM_PROTESTO.dscnae
                   ,TBCOBRAN_PARAM_PROTESTO.dsnegufds
                   )
             VALUES(pr_cdcooper
                   ,pr_qtlimitemin_tolerancia
                   ,pr_qtlimitemax_tolerancia
										 ,nvl(rw_param.hrenvio_arquivo, 0)
                   ,pr_qtdias_cancelamento
                   ,pr_flcancelamento
                   ,pr_dsuf
                   ,pr_dscnae
                   ,pr_dsnegufds
                   );
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
						-- Se ja existe deve alterar (sem considerar o horario)
          BEGIN
            UPDATE TBCOBRAN_PARAM_PROTESTO
               SET TBCOBRAN_PARAM_PROTESTO.qtlimitemin_tolerancia = pr_qtlimitemin_tolerancia
                  ,TBCOBRAN_PARAM_PROTESTO.qtlimitemax_tolerancia = pr_qtlimitemax_tolerancia
                  ,TBCOBRAN_PARAM_PROTESTO.qtdias_cancelamento    = pr_qtdias_cancelamento
                  ,TBCOBRAN_PARAM_PROTESTO.flcancelamento         = pr_flcancelamento
             WHERE TBCOBRAN_PARAM_PROTESTO.cdcooper               = pr_cdcooper;

          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Problema ao atualizar parametros: ' || SQLERRM;
            RAISE vr_exc_saida;
          END;
      END;
      ELSE -- Se for a Central, reflete o horario e UFs para todas as cooperativas
        BEGIN
					UPDATE TBCOBRAN_PARAM_PROTESTO
						 SET TBCOBRAN_PARAM_PROTESTO.hrenvio_arquivo = TO_CHAR(TO_DATE(pr_hrenvio_arquivo,'HH24:MI'),'SSSSS')
								,TBCOBRAN_PARAM_PROTESTO.dsuf            = pr_dsuf
								,TBCOBRAN_PARAM_PROTESTO.dscnae          = pr_dscnae
								,TBCOBRAN_PARAM_PROTESTO.dsnegufds       = pr_dsnegufds;
			  EXCEPTION
					WHEN OTHERS THEN
					vr_dscritic := 'Problema ao atualizar parametros: ' || SQLERRM;
					RAISE vr_exc_saida;
				END;
      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARPRT: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_atualiza_parprt;
  
  /* ..........................................................................
	
	  Programa : pc_consulta_periodo_parprt
	  Sistema  : Conta-Corrente - Cooperativa de Credito
	  Sigla    : CRED
	  Autor    : André Clemer 
	  Data     : Março/2018.                   Ultima atualizacao: --/--/----
	
	  Dados referentes ao programa:
	
	  Frequencia: Sempre que for chamado
	  Objetivo  : Procedure para retornar o período de tolerância para protesto
	
	  Alteração :
	
	...........................................................................*/
 
  PROCEDURE pc_consulta_periodo_parprt (pr_cdcooper                 IN crapcop.cdcooper%TYPE
                                  ,pr_qtlimitemin_tolerancia  OUT INTEGER
                                  ,pr_qtlimitemax_tolerancia  OUT INTEGER
                                  ,pr_des_erro                OUT VARCHAR2
                                  ,pr_dscritic                OUT VARCHAR2) IS
  
    CURSOR cr_tbcobran_param_protesto(p_cdcooper IN crapcop.cdcooper%TYPE) IS    
      SELECT prt.dsuf
             , prt.dscnae
             , prt.qtlimitemin_tolerancia
             , prt.qtlimitemax_tolerancia
             , prt.qtdias_cancelamento
             , prt.flcancelamento
             , prt.hrenvio_arquivo
        FROM tbcobran_param_protesto prt
       WHERE prt.cdcooper = p_cdcooper;
       
    rw_tbcobran_param_protesto cr_tbcobran_param_protesto%ROWTYPE;  

    --Variaveis
    vr_dsuf                          VARCHAR2(5000);
    vr_dscnae                        VARCHAR2(5000);
    vr_qtlimitemin_tolerancia        VARCHAR2(5000);
    vr_qtlimitemax_tolerancia        VARCHAR2(5000);
    vr_qtdias_cancelamento           VARCHAR2(5000);
    vr_flcancelamento                VARCHAR2(5000);
    vr_hrenvio_arquivo               VARCHAR2(5000);
    
    --Variaveis de erro
    vr_exc_saida EXCEPTION;
    
  BEGIN
    
    --Buscando informacao do associado
    OPEN cr_tbcobran_param_protesto(pr_cdcooper);
      FETCH cr_tbcobran_param_protesto
       INTO rw_tbcobran_param_protesto;
      
      IF cr_tbcobran_param_protesto%NOTFOUND THEN
        CLOSE cr_tbcobran_param_protesto;
        pr_dscritic := 'Parametros não encontrados ou cooperativa não existe.';
        RAISE vr_exc_saida;
      END IF;
    CLOSE cr_tbcobran_param_protesto;
    
    vr_qtlimitemin_tolerancia := rw_tbcobran_param_protesto.qtlimitemin_tolerancia;
    vr_qtlimitemax_tolerancia := rw_tbcobran_param_protesto.qtlimitemax_tolerancia;
    vr_dsuf                   := rw_tbcobran_param_protesto.dsuf;
    vr_dscnae                 := rw_tbcobran_param_protesto.dscnae;
    vr_qtdias_cancelamento    := rw_tbcobran_param_protesto.qtdias_cancelamento;
    vr_flcancelamento         := rw_tbcobran_param_protesto.flcancelamento;
    vr_hrenvio_arquivo        := rw_tbcobran_param_protesto.hrenvio_arquivo;
    
    --Retorna dados
    pr_qtlimitemin_tolerancia := vr_qtlimitemin_tolerancia;
    pr_qtlimitemax_tolerancia := vr_qtlimitemax_tolerancia;
    
    --Retorna OK para a procedure
    pr_des_erro := 'OK';
    
  EXCEPTION   
     WHEN OTHERS THEN       
       pr_des_erro := 'NOK';
       
       IF pr_dscritic <> '' THEN
          pr_dscritic := 'Erro nao tratado na procedure TELA_PARPRT.pc_consulta_parprt_ib: ' || SQLERRM;
       END IF;
       
       --Caso de erro, retorna campos vazio
       vr_qtlimitemin_tolerancia := '';
       vr_qtlimitemax_tolerancia := '';
       vr_dsuf                   := '';
       vr_dscnae                 := '';
       vr_qtdias_cancelamento    := '';
       vr_flcancelamento         := '';
       vr_hrenvio_arquivo        := '';

       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 
                                 ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                 ,pr_des_log      => to_char(SYSDATE,
                                                    'hh24:mi:ss') ||
                                                    ' - ' || 'COBR0009' ||
                                                    ' --> ' || pr_dscritic);
    
  END pc_consulta_periodo_parprt;
  
  /* ..........................................................................
	
	  Programa : pc_consulta_ufs_parprt
	  Sistema  : Conta-Corrente - Cooperativa de Credito
	  Sigla    : CRED
	  Autor    : André Clemer 
	  Data     : Março/2018.                   Ultima atualizacao: --/--/----
	
	  Dados referentes ao programa:
	
	  Frequencia: Sempre que for chamado
	  Objetivo  : Procedure para retornar os ufs parametrizados para protesto
	
	  Alteração :
	
	...........................................................................*/
 
  PROCEDURE pc_consulta_ufs_parprt (pr_cdcooper                IN crapcop.cdcooper%TYPE
                                   ,pr_dsuf                    OUT VARCHAR2
                                   ,pr_des_erro                OUT VARCHAR2
                                   ,pr_dscritic                OUT VARCHAR2) IS
                                   
    vr_dsuf VARCHAR2(5000);
    
    --Variaveis de erro
    vr_exc_saida EXCEPTION;
    
  BEGIN
    
    SELECT tbcobran_param_protesto.dsuf
      INTO vr_dsuf
      FROM tbcobran_param_protesto
     WHERE tbcobran_param_protesto.cdcooper = pr_cdcooper;
     
    --Retorna dados
    pr_dsuf := vr_dsuf;
    
    --Retorna OK para a procedure
    pr_des_erro := 'OK';
    
  EXCEPTION   
     WHEN OTHERS THEN       
       pr_des_erro := 'NOK';
       
       IF pr_dscritic <> '' THEN
          pr_dscritic := 'Erro nao tratado na procedure TELA_PARPRT.pc_consulta_ufs_parprt: ' || SQLERRM;
       END IF;
       
       --Caso de erro, retorna campos vazio
       pr_dsuf := '';

       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 
                                 ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                 ,pr_des_log      => to_char(SYSDATE,
                                                    'hh24:mi:ss') ||
                                                    ' - ' || 'COBR0009' ||
                                                    ' --> ' || pr_dscritic);
    
  END pc_consulta_ufs_parprt;

/* ..........................................................................
  
    Programa : pc_validar_dsnegufds_parprt
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Anderson-Alan 
    Data     : Outubro/2018.                   Ultima atualizacao: --/--/----
  
    Dados referentes ao programa:
  
    Frequencia: Sempre que for chamado
    Objetivo  : Procedure para validar	Se houver emissão de boletos com protesto e com espécie de documento DS, cujo UF está na tela PARPRT pr_dsnegufds
  
    Alteração : --/--/---- 
  
  ...........................................................................*/
 
  PROCEDURE pc_validar_dsnegufds_parprt (pr_cdcooper                IN crapsab.cdcooper%TYPE
                                        ,pr_cdufsaca                IN crapsab.cdufsaca%TYPE
                                        ,pr_des_erro                OUT VARCHAR2
                                        ,pr_dscritic                OUT VARCHAR2) IS
    
    vr_dsnegufds tbcobran_param_protesto.dsnegufds%TYPE;
    
    --> Verificar se o uf saca é permitido protestar
    CURSOR cr_cdufsaca_dsnegufds(pr_cdcooper crapsab.cdcooper%TYPE,
                                 pr_cdufsaca crapsab.cdufsaca%TYPE) IS
      SELECT p.dsnegufds
        FROM tbcobran_param_protesto p
       WHERE p.cdcooper = pr_cdcooper
         AND p.dsnegufds NOT LIKE '%' || pr_cdufsaca || '%';
    
    --> seleciona os uf não permitidor para protestar
    CURSOR cr_dsnegufds(pr_cdcooper crapsab.cdcooper%TYPE) IS
      SELECT p.dsnegufds
        FROM tbcobran_param_protesto p
       WHERE p.cdcooper = pr_cdcooper;
    
    --Variaveis de erro
    vr_exc_saida EXCEPTION;
    
  BEGIN
    
    --Buscando informacao da uf e protesto
    OPEN cr_cdufsaca_dsnegufds(pr_cdcooper, pr_cdufsaca);
    FETCH cr_cdufsaca_dsnegufds INTO vr_dsnegufds;
      IF cr_cdufsaca_dsnegufds%NOTFOUND THEN
        CLOSE cr_cdufsaca_dsnegufds;
        
        --Buscando os uf não permitidos para protestar
        OPEN cr_dsnegufds(pr_cdcooper);
        FETCH cr_dsnegufds INTO vr_dsnegufds;
        CLOSE cr_dsnegufds;
        
        pr_dscritic := 'Não será possível concluir a emissão do boleto, não é permitido protesto com espécie de documento DS aos estados ' || vr_dsnegufds;
        RAISE vr_exc_saida;
      END IF;
    CLOSE cr_cdufsaca_dsnegufds;
    
    --Retorna OK para a procedure
    pr_des_erro := 'OK';
    
  EXCEPTION
     WHEN OTHERS THEN
       pr_des_erro := 'NOK';
       
       IF pr_dscritic <> '' THEN
          pr_dscritic := 'Erro nao tratado na procedure TELA_PARPRT.pc_validar_dsnegufds_parprt: ' || SQLERRM;
       END IF;
       
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 
                                 ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                 ,pr_des_log      => to_char(SYSDATE,
                                                    'hh24:mi:ss') ||
                                                    ' - ' || 'COBR0009' ||
                                                    ' --> ' || pr_dscritic);
    
  END pc_validar_dsnegufds_parprt;

END TELA_PARPRT;
/
