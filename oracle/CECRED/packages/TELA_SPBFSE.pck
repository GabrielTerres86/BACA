CREATE OR REPLACE PACKAGE CECRED.tela_spbfse AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_SPBFSE
  --    Autor   : Everton Souza - Mouts
  --    Data    : Julho/2018                      Ultima Atualizacao:   /  /
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Atender as necessidades da tela SPBFSE
  --                Construido para o Projeto 475
  --
  --    Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------


  PROCEDURE pc_busca_tbspb_fase(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_insere_tbspb_fase(pr_cdfase IN tbspb_fase_mensagem.cdfase%TYPE --> Codigo da fase da mensagem
                                ,pr_nmfase IN tbspb_fase_mensagem.nmfase%TYPE --> Nome da fase da mensagem
                                ,pr_idfase_controlada IN tbspb_fase_mensagem.idfase_controlada%TYPE --> Identificador de fase controlada (0-Nao / 1-Sim)
                                ,pr_cdfase_anterior IN tbspb_fase_mensagem.cdfase_anterior%TYPE     --> Codigo da fase anterior da mensagem
                                ,pr_qttempo_alerta IN tbspb_fase_mensagem.qttempo_alerta%TYPE       --> Quantidade de tempo em minutos para geracao de alerta
                                ,pr_qtmensagem_alerta IN tbspb_fase_mensagem.qtmensagem_alerta%TYPE --> Quantidade de mensagens fora do padrao para geracao de alerta
                                ,pr_idconversao IN tbspb_fase_mensagem.idconversao%TYPE             --> Identificador de fase de conversao de mensagem no JDSPB (0-Nao / 1-Sim)
                                ,pr_idreprocessa_mensagem IN tbspb_fase_mensagem.idreprocessa_mensagem %TYPE   --> Indica se a mensagem pode ser reprocessada (0=Nao, 1=Sim)
                                
																,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
																,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK


  PROCEDURE pc_atualiza_tbspb_fase(pr_cdfase IN tbspb_fase_mensagem.cdfase%TYPE --> Codigo da fase da mensagem
                                  ,pr_nmfase IN tbspb_fase_mensagem.nmfase%TYPE --> Nome da fase da mensagem
													 		    ,pr_idfase_controlada IN tbspb_fase_mensagem.idfase_controlada%TYPE --> Identificador de fase controlada (0-Nao / 1-Sim)
															  	,pr_cdfase_anterior IN tbspb_fase_mensagem.cdfase_anterior%TYPE     --> Codigo da fase anterior da mensagem
															  	,pr_qttempo_alerta IN tbspb_fase_mensagem.qttempo_alerta%TYPE       --> Quantidade de tempo em minutos para geracao de alerta
                                  ,pr_qtmensagem_alerta IN tbspb_fase_mensagem.qtmensagem_alerta%TYPE --> Quantidade de mensagens fora do padrao para geracao de alerta
			                            ,pr_idativo IN tbspb_fase_mensagem.idativo%TYPE --> Identificador de fase ativa (0-Nao / 1-Sim)
                                  ,pr_idconversao IN tbspb_fase_mensagem.idconversao%TYPE             --> Identificador de fase de conversao de mensagem no JDSPB (0-Nao / 1-Sim)
                                  ,pr_idreprocessa_mensagem IN tbspb_fase_mensagem.idreprocessa_mensagem %TYPE   --> Indica se a mensagem pode ser reprocessada (0=Nao, 1=Sim)

                                  ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK



END tela_spbfse;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_spbfse AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_SPBFSE
  --    Autor   : Everton Souza
  --    Data    : Julho/2018                   Ultima Atualizacao:
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela SPBFSE
  --
  --    Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------


  PROCEDURE pc_busca_tbspb_fase(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_tbspb_fase
    Sistema : Sistema Pagamentos Brasileiros - Cooperativa de Credito
    Sigla   : SPB
    Autor   : Everton Souza
    Data    : Julho/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as fases das mensagens SPB (tabela TBSPB_FASE_MENSAGEM)

    Alteracoes:
    ............................................................................. */

    --Cursor para pegar fases das mensagens SPB
    CURSOR cr_fase_msg IS
      SELECT a.cdfase,
             a.nmfase,
             a.idfase_controlada,
             a.cdfase_anterior,
             a.qttempo_alerta,
             a.qtmensagem_alerta,
             a.idativo,
             a.idconversao,
             to_char(a.dtultima_execucao,'DD/MM/YYYY HH24:MI:SS') dtultima_execucao,
             b.nmfase nmfaseanterior,
             a.idreprocessa_mensagem
        FROM tbspb_fase_mensagem a,
             tbspb_fase_mensagem b
       WHERE a.cdfase_anterior = b.cdfase(+)
       order by 1;

    rw_fase_msg cr_fase_msg%ROWTYPE;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis locais
    vr_contador INTEGER := 0;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN
    --
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    --
    -- Carregar arquivo com a tabela tbspb_fase_mensagem
    FOR rw_fase_msg in cr_fase_msg LOOP
      --Escrever no XML
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'fase',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'fase',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdfase',
                               pr_tag_cont => rw_fase_msg.cdfase,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'fase',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nmfase',
                               pr_tag_cont => rw_fase_msg.nmfase,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'fase',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'idfase_controlada',
                               pr_tag_cont => rw_fase_msg.idfase_controlada,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'fase',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdfase_anterior',
                               pr_tag_cont => rw_fase_msg.cdfase_anterior,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'fase',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nmfaseanterior',
                               pr_tag_cont => rw_fase_msg.nmfaseanterior,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'fase',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'qttempo_alerta',
                               pr_tag_cont => rw_fase_msg.qttempo_alerta,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'fase',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'qtmensagem_alerta',
                               pr_tag_cont => rw_fase_msg.qtmensagem_alerta,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'fase',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'idativo',
                               pr_tag_cont => rw_fase_msg.idativo,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'fase',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'idconversao',
                               pr_tag_cont => rw_fase_msg.idconversao,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'fase',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dtultima_execucao',
                               pr_tag_cont => rw_fase_msg.dtultima_execucao,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'fase',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'idreprocessa_mensagem',
                               pr_tag_cont => rw_fase_msg.idreprocessa_mensagem,
                               pr_des_erro => vr_dscritic);                               

        vr_contador := vr_contador + 1;
        --
    END LOOP;
    --
    pr_des_erro := 'OK';
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_SPBFSE.pc_busca_tbspb_fase --> ' ||SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_busca_tbspb_fase;


  PROCEDURE pc_insere_tbspb_fase(pr_cdfase IN tbspb_fase_mensagem.cdfase%TYPE --> Codigo da fase da mensagem
                                ,pr_nmfase IN tbspb_fase_mensagem.nmfase%TYPE --> Nome da fase da mensagem
													 		  ,pr_idfase_controlada IN tbspb_fase_mensagem.idfase_controlada%TYPE --> Identificador de fase controlada (0-Nao / 1-Sim)
																,pr_cdfase_anterior IN tbspb_fase_mensagem.cdfase_anterior%TYPE     --> Codigo da fase anterior da mensagem
																,pr_qttempo_alerta IN tbspb_fase_mensagem.qttempo_alerta%TYPE       --> Quantidade de tempo em minutos para geracao de alerta
                                ,pr_qtmensagem_alerta IN tbspb_fase_mensagem.qtmensagem_alerta%TYPE --> Quantidade de mensagens fora do padrao para geracao de alerta
                                ,pr_idconversao IN tbspb_fase_mensagem.idconversao%TYPE             --> Identificador de fase de conversao de mensagem no JDSPB (0-Nao / 1-Sim)
                                ,pr_idreprocessa_mensagem IN tbspb_fase_mensagem.idreprocessa_mensagem %TYPE   --> Indica se a mensagem pode ser reprocessada (0=Nao, 1=Sim)
                                
																,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
																,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_insere_tbspb_fase
    Sistema : Sistema Pagamentos Brasileiros - Cooperativa de Credito
    Sigla   : SPB
    Autor   : Everton Souza
    Data    : Julho/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para inserir as fases das mensagens SPB (tabela TBSPB_FASE_MENSAGEM)

    Alteracoes:
    ............................................................................. */

    CURSOR cr_fase_msg(pr_cdfase tbspb_fase_mensagem.cdfase%TYPE) IS
      SELECT *
        FROM tbspb_fase_mensagem
       WHERE cdfase = pr_cdfase;

    rw_fase_msg cr_fase_msg%ROWTYPE;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN
    --
    pr_des_erro := 'NOK';
    --
    IF pr_idfase_controlada = 1 THEN
      -- verifica fase anterior
      OPEN cr_fase_msg(pr_cdfase_anterior);
      FETCH cr_fase_msg INTO rw_fase_msg;

      -- Se não existe
      IF cr_fase_msg%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_fase_msg;
          -- Gera crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Para fase controlada a fase anterior precisa ser definida!';
          -- Levanta exceção
          RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
      CLOSE cr_fase_msg;
      --
      -- verifica tempo de alerta
      IF pr_qttempo_alerta = 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Para fase controlada o tempo de alerta não pode ser 0!';
        RAISE vr_exc_erro;
      END IF;
      --
      -- verifica quantidade de alerta
      IF pr_qtmensagem_alerta = 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Para fase controlada a quantidade de alerta não pode ser 0!';
        RAISE vr_exc_erro;
      END IF;
      --
    END IF;
    --
    BEGIN

    INSERT INTO tbspb_fase_mensagem
      (cdfase,
       nmfase,
       idfase_controlada,
       cdfase_anterior,
       qttempo_alerta,
       qtmensagem_alerta,
       idconversao,
       idativo,
       dtultima_execucao,
       idreprocessa_mensagem
      )
    VALUES
      (pr_cdfase,
       pr_nmfase,
       pr_idfase_controlada,
       pr_cdfase_anterior,
       pr_qttempo_alerta,
       pr_qtmensagem_alerta,
       pr_idconversao,
       1,
       null,
       pr_idreprocessa_mensagem
      );
    EXCEPTION
      WHEN dup_val_on_index THEN
         vr_cdcritic := 0;
         vr_dscritic := 'Registro ja existente!';
         RAISE vr_exc_erro;
      WHEN OTHERS THEN
         vr_cdcritic := 0;
         vr_dscritic := 'Erro ao inserir registro!';
         RAISE vr_exc_erro;
    END;


		-- Retornar código cadastrado
		pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																	 '<Root><Dados><cdfase>' || pr_cdfase || '</cdfase></Dados></Root>');

    --
    COMMIT;
    --
    pr_des_erro := 'OK';
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_SPBFSE.pc_insere_tbspb_fase --> ' ||
                     SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_insere_tbspb_fase;

  PROCEDURE pc_atualiza_tbspb_fase(pr_cdfase IN tbspb_fase_mensagem.cdfase%TYPE --> Codigo da fase da mensagem
                                  ,pr_nmfase IN tbspb_fase_mensagem.nmfase%TYPE --> Nome da fase da mensagem
													 		    ,pr_idfase_controlada IN tbspb_fase_mensagem.idfase_controlada%TYPE --> Identificador de fase controlada (0-Nao / 1-Sim)
															  	,pr_cdfase_anterior IN tbspb_fase_mensagem.cdfase_anterior%TYPE     --> Codigo da fase anterior da mensagem
															  	,pr_qttempo_alerta IN tbspb_fase_mensagem.qttempo_alerta%TYPE       --> Quantidade de tempo em minutos para geracao de alerta
                                  ,pr_qtmensagem_alerta IN tbspb_fase_mensagem.qtmensagem_alerta%TYPE --> Quantidade de mensagens fora do padrao para geracao de alerta
			                            ,pr_idativo IN tbspb_fase_mensagem.idativo%TYPE --> Identificador de fase ativa (0-Nao / 1-Sim)
                                  ,pr_idconversao IN tbspb_fase_mensagem.idconversao%TYPE             --> Identificador de fase de conversao de mensagem no JDSPB (0-Nao / 1-Sim)
                                  ,pr_idreprocessa_mensagem IN tbspb_fase_mensagem.idreprocessa_mensagem %TYPE   --> Indica se a mensagem pode ser reprocessada (0=Nao, 1=Sim)

                                  ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_atualiza_tbspb_fase
    Sistema : Sistema Pagamentos Brasileiros - Cooperativa de Credito
    Sigla   : SPB
    Autor   : Everton Souza
    Data    : Julho/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para atualizar as fases das mensagens SPB (tabela TBSPB_FASE_MENSAGEM)

    Alteracoes:
    ............................................................................. */

    CURSOR cr_fase_msg(pr_cdfase tbspb_fase_mensagem.cdfase%TYPE) IS
      SELECT *
        FROM tbspb_fase_mensagem
       WHERE cdfase = pr_cdfase;

    rw_fase_msg cr_fase_msg%ROWTYPE;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    pr_des_erro := 'NOK';

    -- Abre indicador
    OPEN cr_fase_msg(pr_cdfase);
    FETCH cr_fase_msg INTO rw_fase_msg;

    -- Se não existe
    IF cr_fase_msg%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_fase_msg;
        -- Gera crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Fase não encontrada!';
        -- Levanta exceção
        RAISE vr_exc_erro;
    END IF;

    -- Fecha cursor
    CLOSE cr_fase_msg;

    IF pr_idfase_controlada = 1 THEN
      --
      -- verifica fase anterior
      OPEN cr_fase_msg(pr_cdfase_anterior);
      FETCH cr_fase_msg INTO rw_fase_msg;

      -- Se não existe
      IF cr_fase_msg%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_fase_msg;
          -- Gera crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Para fase controlada a fase anterior precisa ser definida!';
          -- Levanta exceção
          RAISE vr_exc_erro;
      END IF;

      -- Fecha cursor
      CLOSE cr_fase_msg;
      --
      -- verifica tempo de alerta
      IF pr_qttempo_alerta = 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Para fase controlada o tempo de alerta não pode ser 0!';
        RAISE vr_exc_erro;
      END IF;
      --
      -- verifica quantidade de alerta
      IF pr_qtmensagem_alerta = 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Para fase controlada a quantidade de alerta não pode ser 0!';
        RAISE vr_exc_erro;
      END IF;
      --
    END IF;
    --
    BEGIN
    --
      UPDATE tbspb_fase_mensagem
         SET nmfase = pr_nmfase
            ,idfase_controlada = pr_idfase_controlada
            ,cdfase_anterior = pr_cdfase_anterior
            ,qttempo_alerta = pr_qttempo_alerta
            ,qtmensagem_alerta = pr_qtmensagem_alerta
            ,idativo = pr_idativo
            ,idconversao = pr_idconversao
            ,idreprocessa_mensagem = pr_idreprocessa_mensagem
       WHERE cdfase = pr_cdfase;
       --
    EXCEPTION
      WHEN OTHERS THEN
         vr_cdcritic := 0;
         vr_dscritic := 'Erro ao atualizar registro!'||SQLERRM;
         RAISE vr_exc_erro;
    END;

    IF SQL%ROWCOUNT = 0 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Registro não encontrado!';
      RAISE vr_exc_erro;
    END IF;
    --
    COMMIT;
    pr_des_erro := 'OK';
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_SPBFSE.pc_atualiza_tbspb_fase --> ' ||
                     SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');

  END pc_atualiza_tbspb_fase;


END tela_spbfse;
/
