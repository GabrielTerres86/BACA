CREATE OR REPLACE PACKAGE PROGRID.ASSE0001 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : ASSE0001
  --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web PROGRID
  --  Sigla    : ASSE
  --  Autor    : Jean Michel
  --  Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Criar interface e validações necessárias para intercambio de dados para o sistema PROGRID
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina de envio de email de data limite para informar a sugestão de datas para AGO e AGE.
  PROCEDURE pc_envia_email_dat_ago_age(pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da Crítica
                                      ,pr_dscritic OUT VARCHAR2);            --> Descrição da Crítica

  -- Rotina de envio de email de data de realização do evento
  PROCEDURE pc_envia_email_data_evento(pr_cdcooper  IN crapadp.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Código do PA
                                      ,pr_nmevento  IN crapedp.nmevento%TYPE --> Nome do Evento
                                      ,pr_dtinieve  IN crapadp.dtinieve%TYPE --> Data inicial do Evento
                                      ,pr_dtfimeve  IN crapadp.dtfineve %TYPE --> Data final do Evento
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da Crítica
                                      ,pr_dscritic OUT VARCHAR2);            --> Descrição da Crítica                                 
          
  -- Rotina de envio de email de quantidade de participantes previstos para o evento
  PROCEDURE pc_envia_email_qtd_part(pr_cdcooper  IN crapadp.cdcooper%TYPE --> Código da Cooperativa
                                   ,pr_cdagenci  IN crapadp.cdagenci%TYPE --> Código do PA
                                   ,pr_nmevento  IN crapedp.nmevento%TYPE --> Nome do Evento
                                   ,pr_qtturant  IN crapedp.qtmaxtur%TYPE --> Quantidade de Participantes Anterior
                                   ,pr_qtturatu  IN crapedp.qtmaxtur%TYPE --> Quantidade de Participantes Atual
                                   ,pr_dtinieve  IN crapadp.dtinieve%TYPE --> Data de Inicio de Evento
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da Crítica
                                   ,pr_dscritic OUT VARCHAR2);            --> Descrição da Crítica
       
  -- Rotina geral de calculo de custos de eventos assembleares
  PROCEDURE pc_calc_custo_eve_ass(pr_idevento IN crapadp.idevento%TYPE --> ID do Evento
                                 ,pr_cdcooper IN crapadp.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,pr_dtanoage IN crapadp.dtanoage%TYPE --> Ano Agenda
                                 ,pr_cdagenci IN crapadp.cdagenci%TYPE --> Codigo do PA
                                 ,pr_cdevento IN crapadp.cdevento%TYPE --> Codigo do Evento
                                 ,pr_nrseqdig IN crapadp.nrseqdig%TYPE --> Codigo do Evento
                                 ,pr_idcokses IN gnapses.idsessao%TYPE --> ID da sessao
                                 ,pr_dscritic OUT CLOB);               --> Descrição da crítica

  PROCEDURE pc_email_dat_ini_planej(pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Código da Crítica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descrição da Crítica
END ASSE0001;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.ASSE0001 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : ASSE0001
  --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web PROGRID
  --  Sigla    : ASSE0001
  --  Autor    : Jean Michel
  --  Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
  --
  --  Dados referentes ao programa:
  --
  --  Frequencia: Sempre que for solicitado
  --  Objetivo  : Package geral referente a eventos assembleares
  --
  --  Alteracoes: 
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina de envio de email de data limite para informar a sugestão de datas para AGO e AGE.
  PROCEDURE pc_envia_email_dat_ago_age(pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da Crítica
                                    	,pr_dscritic OUT VARCHAR2) IS          --> Descrição da Crítica
    -- ..........................................................................
    --
    --  Programa : pc_envia_email_dat_ago_age
    --  Sistema  : PROGRID
    --  Sigla    : ASSE
    --  Autor    : Jean Michel
    --  Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina de envio de email de data limite para informar a sugestão de datas para AGO e AGE.
    --
    --   Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      
      --------> CURSORES <--------
      -- Fazer um cursor na parâmetros do Progrid para o IDEVENTO = 2
      CURSOR cr_parametro IS
        SELECT g.cdcooper
              ,MAX(g.dtanoage) dtanoage
         FROM gnpapgd g
        WHERE g.idevento = 2
        GROUP BY g.cdcooper;

      rw_parametro cr_parametro%ROWTYPE;
        
      CURSOR cr_evento(pr_cdcooper IN NUMBER
                      ,pr_dtanoage IN NUMBER) IS 
        SELECT c.cdagenci 
          FROM crapagp c
         WHERE c.idevento = 2
           AND c.cdagenci = 0
           AND c.cdcooper = pr_cdcooper
           AND c.dtanoage = pr_dtanoage
           AND c.idstagen = 1;

      rw_evento cr_evento%ROWTYPE;

      CURSOR cr_crapppc(pr_cdcooper IN crapppc.cdcooper%TYPE
                       ,pr_dtanoage IN crapppc.dtanoage%TYPE) IS
        SELECT ppc.dtlimass
              ,ppc.dsemlsdf
          FROM crapppc ppc
         WHERE ppc.cdcooper = pr_cdcooper
           and ppc.dtanoage = pr_dtanoage;
      
      rw_crapppc cr_crapppc%ROWTYPE;

      -- Variaveis de erro e excessao
      vr_exc_null  EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(4000);
    
      -- Variaveis Locais
      vr_dtlimass date := NULL;
      vr_dsemlsdf varchar2(500):=0;   
      vr_dscorpo VARCHAR(4000) := '';

    BEGIN
        
      FOR rw_parametro IN cr_parametro LOOP
        -- Ler a tabela de agencias do progrid para verificar os eventos
        -- assembleares AGO/AGE não enviados ainda
        FOR rw_evento IN cr_evento(pr_cdcooper => rw_parametro.cdcooper
                                  ,pr_dtanoage => rw_parametro.dtanoage) LOOP

          --Ler a tabela de parâmetros do progrid para pegar a data limite
          OPEN cr_crapppc(pr_cdcooper => rw_parametro.cdcooper
                         ,pr_dtanoage => rw_parametro.dtanoage);

          FETCH cr_crapppc INTO rw_crapppc;               

          IF cr_crapppc%NOTFOUND THEN
            CLOSE cr_crapppc;
            vr_dtlimass := NULL;
            vr_dsemlsdf := '';
          ELSE
            CLOSE cr_crapppc;
            vr_dtlimass := rw_crapppc.dtlimass;
            vr_dsemlsdf := rw_crapppc.dsemlsdf;
          END IF;

          --Faz a validação nos ultimos 15 dias antes da data limite
          IF vr_dtlimass - trunc(sysdate) <= 15 and vr_dtlimass - TRUNC(SYSDATE) >0 THEN
            IF vr_dsemlsdf IS NOT NULL THEN
              -- Corpo do Email
              vr_dscorpo :=  '<b>ATENÇÃO!</b><br>' ||
                             '<br>A data limite para digitação das sugestões de datas para eventos AGO e AGE está se aproximando, ' ||
                             '<br>favor digitar estas sugestões de datas o mais rápido possível.' ||
                             '<br>' ||
                             '<br>A partir do dia : ' || TO_CHAR(vr_dtlimass,'dd/mm/RRRR') || ' , a digitação das sugestões de datas será bloqueada e ' ||
                             '<br>somente a equipe da OQS poderá fazer esta digitação.' ||
                             '<br><br>' ||
                             '<br>Att.' ||
                             '<br>Equipe OQS.';
                             
              -- Enviar e-mail dos dados deste sinistro
              gene0003.pc_solicita_email(pr_cdcooper        => rw_parametro.cdcooper         --> Código da Cooperativa 
                                        ,pr_cdprogra        => 'ASSE0001'                    --> Programa conectado
                                        ,pr_des_destino     => rw_crapppc.dsemlsdf           --> Um ou mais detinatários separados por ';' ou ','
                                        ,pr_des_assunto     => 'Sugestão de Datas AGO e AGE' --> Assunto do e-mail
                                        ,pr_des_corpo       => vr_dscorpo                    --> Corpo (conteudo) do e-mail
                                        ,pr_des_anexo       => NULL                          --> Um ou mais anexos separados por ';' ou ','
                                        ,pr_flg_remove_anex => NULL                          --> Remover os anexos passados
                                        ,pr_flg_log_batch   => NULL                          --> Incluir no log a informação do anexo?
                                        ,pr_flg_enviar      => 'S'                           --> Enviar o e-mail na hora
                                        ,pr_des_erro        => vr_dscritic) ;    
                                    
              -- Caso encontre alguma critica no envio do email                          
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
                            
            END IF;

          END IF;

        END LOOP;

      END LOOP;                       
      
    EXCEPTION
      WHEN vr_exc_null THEN
        NULL;
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral ASSE0001.PC_ENVIA_EMAIL_SEM_LOCAL: ' || SQLERRM;
    END;
  END pc_envia_email_dat_ago_age;

  -- Rotina de envio de email de data de realização do evento
  PROCEDURE pc_envia_email_data_evento(pr_cdcooper  IN crapadp.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Código do PA
                                      ,pr_nmevento  IN crapedp.nmevento%TYPE --> Nome do Evento
                                      ,pr_dtinieve  IN crapadp.dtinieve%TYPE --> Data inicial do Evento
                                      ,pr_dtfimeve  IN crapadp.dtfineve%TYPE --> Data final do Evento
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da Crítica
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da Crítica
    -- ..........................................................................
    --
    --  Programa : pc_envia_email_data_evento
    --  Sistema  : PROGRID
    --  Sigla    : ASSE
    --  Autor    : Jean Michel
    --  Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina irá rodar, somente para eventos Assembleares (CRAPADP.IDEVENTO = 2 )
    --               do tipo Pré-Assembléia e quando a data inicial (CRAPADP.DTINIEVE) 
    --               ou data final ( CRAPADP.DTFINEVE ) do evento for informada ou alterada.
    --
    --   Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      
      --------> CURSORES <--------
      -- Cursor para buscar a quantidade de dias e os endereços de email para envio 
      CURSOR cr_parametro IS
        SELECT cp.dsemlade
          FROM crapppc cp
         WHERE cp.idevento = 1
           AND cp.cdcooper = pr_cdcooper
           AND cp.dtanoage = (SELECT MAX(g.dtanoage)
                                FROM gnpapgd g
                               WHERE g.idevento = cp.idevento
                                 AND g.cdcooper = cp.cdcooper)
       ORDER BY cp.cdcooper;  
  
      rw_parametro cr_parametro%ROWTYPE; 

      CURSOR cr_crapage IS
        SELECT cop.nmrescop AS nmrescop
              ,NVL(age.nmresage,'TODOS') AS nmresage
        FROM crapcop cop
            ,crapage age
        WHERE cop.cdcooper = pr_cdcooper
          AND cop.cdcooper = age.cdcooper(+)
          AND age.cdagenci(+) = pr_cdagenci;

      rw_crapage cr_crapage%ROWTYPE;

      vr_dscorpo VARCHAR(4000) := ''; 

      -- Variaveis de erro e excessao
      vr_exc_null  EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(4000);
    
    BEGIN
    
      OPEN cr_parametro();

      FETCH cr_parametro INTO rw_parametro;

      IF cr_parametro%NOTFOUND THEN
        CLOSE cr_parametro;
        RAISE vr_exc_null;
      ELSE
        CLOSE cr_parametro;
      END IF;

      OPEN cr_crapage();

      FETCH cr_crapage INTO rw_crapage;

      IF cr_crapage%NOTFOUND THEN
        CLOSE cr_crapage;
        RAISE vr_exc_null;
      ELSE
        CLOSE cr_crapage;
      END IF;

      vr_dscorpo :=  '<b>ATENÇÃO!</b><br>' ||
                     '<br>Foi informada a data inicial e(ou) data final de realização do evento evento ' ||
                     pr_nmevento || ' do dia ' || TO_CHAR(pr_dtinieve,'dd/mm/RRRR') || ' da Cooperativa ' ||
                     rw_crapage.nmrescop || ' e do PA: ' || rw_crapage.nmresage || '.' ||
                     '<br><br>' ||
                     'Data Inicial: ' || TO_CHAR(pr_dtinieve,'dd/mm/RRRR') || ' Data Final: ' || TO_CHAR(pr_dtfimeve,'dd/mm/RRRR') || '.';

      -- Enviar e-mail dos dados deste sinistro
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper                                --> Código da Cooperativa 
                                ,pr_cdprogra        => 'ASSE0001'                                  --> Programa conectado
                                ,pr_des_destino     => rw_parametro.dsemlade                       --> Um ou mais detinatários separados por ';' ou ','
                                ,pr_des_assunto     => 'Alteração de Data de Realização do Evento' --> Assunto do e-mail
                                ,pr_des_corpo       => vr_dscorpo                                  --> Corpo (conteudo) do e-mail
                                ,pr_des_anexo       => NULL                                        --> Um ou mais anexos separados por ';' ou ','
                                ,pr_flg_remove_anex => NULL                                        --> Remover os anexos passados
                                ,pr_flg_log_batch   => NULL                                        --> Incluir no log a informação do anexo?
                                ,pr_flg_enviar      => 'S'                                         --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic) ;    
                              
      -- Caso encontre alguma critica no envio do email                          
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
     
    EXCEPTION
      WHEN vr_exc_null THEN
        NULL;
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral ASSE0001.PC_ENVIA_EMAIL_DATA_EVENTO: ' || SQLERRM;
    END;
  END pc_envia_email_data_evento;

	-- Rotina de envio de email de quantidade de participantes previstos para o evento
  PROCEDURE pc_envia_email_qtd_part(pr_cdcooper  IN crapadp.cdcooper%TYPE --> Código da Cooperativa
                                   ,pr_cdagenci  IN crapadp.cdagenci%TYPE --> Código do PA
                                   ,pr_nmevento  IN crapedp.nmevento%TYPE --> Nome do Evento
                                   ,pr_qtturant  IN crapedp.qtmaxtur%TYPE --> Quantidade de Participantes Anterior
                                   ,pr_qtturatu  IN crapedp.qtmaxtur%TYPE --> Quantidade de Participantes Atual
                                   ,pr_dtinieve  IN crapadp.dtinieve%TYPE --> Data de Inicio de Evento
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da Crítica
                                   ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da Crítica
    -- ..........................................................................
    --
    --  Programa : pc_envia_email_qtd_part
    --  Sistema  : PROGRID
    --  Sigla    : ASSE
    --  Autor    : Jean Michel
    --  Data     : Maio/2017.                   Ultima atualizacao: 05/05/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina irá rodar, somente para eventos assembleares (CRAPADP.IDEVENTO = 2 )
    --               e quando a quantidade de participantes previstos para o evento for informada ou 
    --               alterada (CRAPADP.QTPARPRE).
    --
    --   Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      
      --------> CURSORES <--------
      -- Cursor para buscar a quantidade de dias e os endereços de email para envio 
      CURSOR cr_parametro IS
        SELECT cp.dsemlaqp
          FROM crapppc cp
         WHERE cp.idevento = 1
           AND cp.cdcooper = pr_cdcooper
           AND TRIM(cp.dsemlaqp) IS NOT NULL
           AND cp.dtanoage = (SELECT MAX(g.dtanoage)
                                FROM gnpapgd g
                               WHERE g.idevento = cp.idevento
                                 AND g.cdcooper = cp.cdcooper)
       ORDER BY cp.cdcooper;  
  
      rw_parametro cr_parametro%ROWTYPE;

      CURSOR cr_crapage IS
        SELECT cop.nmrescop AS nmrescop
              ,NVL(age.nmresage,'TODOS') AS nmresage
        FROM crapcop cop
            ,crapage age
        WHERE cop.cdcooper = pr_cdcooper
          AND cop.cdcooper = age.cdcooper(+)
          AND age.cdagenci(+) = pr_cdagenci;

      rw_crapage cr_crapage%ROWTYPE;
                   
      vr_dscorpo VARCHAR(4000) := ''; 

      -- Variaveis de erro e excessao
      vr_exc_null  EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(4000);
    
    BEGIN
    
      OPEN cr_parametro();

      FETCH cr_parametro INTO rw_parametro;

      IF cr_parametro%NOTFOUND THEN
        CLOSE cr_parametro;
        RAISE vr_exc_null;
      ELSE
        CLOSE cr_parametro;
      END IF;

      OPEN cr_crapage();

      FETCH cr_crapage INTO rw_crapage;

      IF cr_crapage%NOTFOUND THEN
        CLOSE cr_crapage;
        RAISE vr_exc_null;
      ELSE
        CLOSE cr_crapage;
      END IF;    

      vr_dscorpo :=  '<b>ATENÇÃO!</b><br>' ||
                     '<br>Houve alteração na quantidade de participantes prevista para o evento ' ||
                     pr_nmevento || ' do dia (' || TO_CHAR(pr_dtinieve,'dd/mm/RRRR') || ') da Cooperativa ' ||
                     rw_crapage.nmrescop || ' e do PA ' || rw_crapage.nmresage || '.' ||
                     '<br><br>' ||  
                     'Quantidade Prevista Anterior: ' || TO_CHAR(pr_qtturant) || '.<br>' ||
                     'Quantidade Prevista Atual: ' || TO_CHAR(pr_qtturatu) || '.';

      -- Enviar e-mail dos dados deste sinistro
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper                                --> Código da Cooperativa 
                                ,pr_cdprogra        => 'ASSE0001'                                 --> Programa conectado
                                ,pr_des_destino     => rw_parametro.dsemlaqp                      --> Um ou mais detinatários separados por ';' ou ','
                                ,pr_des_assunto     => 'Alteração de Quantidade de Participantes' --> Assunto do e-mail
                                ,pr_des_corpo       => vr_dscorpo                                 --> Corpo (conteudo) do e-mail
                                ,pr_des_anexo       => NULL                                       --> Um ou mais anexos separados por ';' ou ','
                                ,pr_flg_remove_anex => NULL                                       --> Remover os anexos passados
                                ,pr_flg_log_batch   => NULL                                       --> Incluir no log a informação do anexo?
                                ,pr_flg_enviar      => 'S'                                        --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic) ;    
                              
      -- Caso encontre alguma critica no envio do email                          
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
     
    EXCEPTION
      WHEN vr_exc_null THEN
        NULL;
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral ASSE0001.pc_envia_email_qtd_part: ' || SQLERRM;
    END;
  END pc_envia_email_qtd_part;

  -- Rotina geral de calculo de custos de eventos assembleares
  PROCEDURE pc_calc_custo_eve_ass(pr_idevento IN crapadp.idevento%TYPE --> ID do Evento
                                 ,pr_cdcooper IN crapadp.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,pr_dtanoage IN crapadp.dtanoage%TYPE --> Ano Agenda
                                 ,pr_cdagenci IN crapadp.cdagenci%TYPE --> Codigo do PA
                                 ,pr_cdevento IN crapadp.cdevento%TYPE --> Codigo do Evento
                                 ,pr_nrseqdig IN crapadp.nrseqdig%TYPE --> Codigo do Evento
                                 ,pr_idcokses IN gnapses.idsessao%TYPE --> ID da sessao
                                 ,pr_dscritic OUT CLOB) IS             --> Descrição da crítica

    -- Consulta sessão do sistema     
    CURSOR cr_gnapses(pr_idcokses gnapses.idsessao%TYPE) IS
      SELECT ses.cdagenci, ses.nvoperad
        FROM gnapses ses
       WHERE ses.idsessao = pr_idcokses;
  
    rw_gnapses cr_gnapses%ROWTYPE;
       
    -- Consulta tipo do evento
    CURSOR cr_crapedp(pr_cdcooper crapedp.cdcooper%TYPE
                     ,pr_dtanoage crapedp.dtanoage%TYPE
                     ,pr_cdevento crapedp.cdevento%TYPE) IS

      SELECT edp.tpevento
        FROM crapedp edp
       WHERE edp.cdcooper = pr_cdcooper
         AND edp.dtanoage = pr_dtanoage
         AND edp.cdevento = pr_cdevento;
 
    rw_crapedp cr_crapedp%ROWTYPE;
        
    CURSOR cr_crapadp(pr_idevento crapadp.idevento%TYPE
                     ,pr_cdcooper crapadp.cdcooper%TYPE
                     ,pr_dtanoage crapadp.dtanoage%TYPE
                     ,pr_cdagenci crapadp.cdagenci%TYPE
                     ,pr_cdevento crapadp.cdevento%TYPE
                     ,pr_nrseqdig crapadp.nrseqdig%TYPE) IS

      SELECT adp.qtparpre
            ,adp.cdlocali
        FROM crapadp adp
       WHERE adp.idevento = pr_idevento
         AND adp.cdcooper = pr_cdcooper
         AND adp.dtanoage = pr_dtanoage
         AND adp.cdagenci = pr_cdagenci
         AND adp.cdevento = pr_cdevento
         AND adp.nrseqdig = pr_nrseqdig;

    rw_crapadp cr_crapadp%ROWTYPE;     
                  
    -- Consulta valor do local do evento
    CURSOR cr_crapldp(pr_idevento crapldp.idevento%TYPE
                     ,pr_cdcooper crapldp.cdcooper%TYPE
                     ,pr_cdagenci crapldp.cdagenci%TYPE
                     ,pr_nrseqdig crapldp.nrseqdig%TYPE) IS

      SELECT ldp.vldialoc AS vldialoc
        FROM crapldp ldp
       WHERE ldp.idevento = pr_idevento
         AND ldp.cdcooper = pr_cdcooper
         AND ldp.cdagenci = pr_cdagenci
         AND ldp.nrseqdig = pr_nrseqdig;

    rw_crapldp cr_crapldp%ROWTYPE;   

    -- Consulta os parametros por cooperativas
    CURSOR cr_crapppc(pr_idevento crapppc.idevento%TYPE
                     ,pr_cdcooper crapppc.cdcooper%TYPE
                     ,pr_dtanoage crapppc.dtanoage%TYPE
                     ,pr_cdcuseve crapcdp.cdcuseve%TYPE) IS

      SELECT DECODE(pr_cdcuseve,2,NVL(ppc.vlaluloc,0),3,ppc.vlporali,0) AS vlrporco
            ,NVL(ppc.vlporqui,0) AS vlporqui
        FROM crapppc ppc
       WHERE ppc.idevento = pr_idevento
         AND ppc.cdcooper = pr_cdcooper
         AND ppc.dtanoage = pr_dtanoage;

    rw_crapppc cr_crapppc%ROWTYPE;

    -- Consulta os parametros por regionais
    CURSOR cr_crapppr(pr_idevento crapppr.idevento%TYPE
                     ,pr_cdcooper crapppr.cdcooper%TYPE
                     ,pr_dtanoage crapppr.dtanoage%TYPE
                     ,pr_cdcuseve crapcdp.cdcuseve%TYPE) IS

      SELECT DECODE(pr_cdcuseve,2,NVL(ppr.vlaluloc,0),3,NVL(ppr.vlporali,0)) AS vlrporrg
        FROM crapppr ppr
       WHERE ppr.idevento = pr_idevento
         AND ppr.cdcooper = pr_cdcooper
         AND ppr.dtanoage = pr_dtanoage
         AND ppr.vlaluloc IS NOT NULL;

    rw_crapppr cr_crapppr%ROWTYPE;

    -- Consulta os parametros por pa
    CURSOR cr_crapppa(pr_idevento crapppa.idevento%TYPE
                     ,pr_cdcooper crapppa.cdcooper%TYPE
                     ,pr_dtanoage crapppa.dtanoage%TYPE
                     ,pr_cdagenci crapppa.cdagenci%TYPE
                     ,pr_cdcuseve crapcdp.cdcuseve%TYPE) IS

      SELECT DECODE(pr_cdcuseve,2,NVL(ppa.vlaluloc,0),3,NVL(ppa.vlporali,0)) AS vlrporpa
        FROM crapppa ppa
       WHERE ppa.idevento = pr_idevento
         AND ppa.cdcooper = pr_cdcooper
         AND ppa.dtanoage = pr_dtanoage
         AND ppa.cdagenci = pr_cdagenci
         AND ppa.vlaluloc IS NOT NULL;

    rw_crapppa cr_crapppa%ROWTYPE;

    -- Consulta de recursos do evento
    CURSOR cr_craprep(pr_idevento craprep.idevento%TYPE
                     ,pr_cdcooper craprep.cdcooper%TYPE
                     ,pr_cdevento craprep.cdevento%TYPE) IS

      SELECT rep.nrseqdig
            ,rep.qtreceve
            ,rep.qtgrppar
        FROM craprep rep
       WHERE rep.idevento = pr_idevento
         AND rep.cdcooper = pr_cdcooper
         AND rep.cdevento = pr_cdevento;

    rw_craprep cr_craprep%ROWTYPE;

    --
    CURSOR cr_gnaprdp_I(pr_idevento gnaprdp.idevento%TYPE
                       ,pr_cdcooper gnaprdp.cdcooper%TYPE
                       ,pr_idsitrec gnaprdp.idsitrec%TYPE
                       ,pr_nrseqdig gnaprdp.nrseqdig%TYPE) IS
      SELECT rdp.nrseqdig
            ,rdp.dsrecurs
        FROM gnaprdp rdp
       WHERE rdp.idevento = pr_idevento
         AND rdp.cdcooper = pr_cdcooper
         AND rdp.idsitrec = pr_idsitrec
         AND rdp.nrseqdig = pr_nrseqdig
         AND NVL(rdp.cdtiprec,0) = 0;

    rw_gnaprdp_I cr_gnaprdp_I%ROWTYPE;

    --
    CURSOR cr_gnaprdp_II(pr_idevento gnaprdp.idevento%TYPE
                        ,pr_cdcooper gnaprdp.cdcooper%TYPE
                        ,pr_idsitrec gnaprdp.idsitrec%TYPE
                        ,pr_nrseqdig gnaprdp.nrseqdig%TYPE
                        ,pr_cdtiprec VARCHAR2) IS

      SELECT rdp.nrseqdig
            ,rdp.dsrecurs
            ,rdp.idrecpor
        FROM gnaprdp rdp
       WHERE rdp.idevento = pr_idevento
         AND rdp.cdcooper = pr_cdcooper
         AND rdp.idsitrec = pr_idsitrec
         AND rdp.nrseqdig = pr_nrseqdig
         AND (gene0002.fn_existe_valor(pr_cdtiprec,
                                       to_char(rdp.cdtiprec),
                                       ',') = 'S');

    rw_gnaprdp_II cr_gnaprdp_II%ROWTYPE;

    CURSOR cr_crapvra_I(pr_idevento crapvra.idevento%TYPE
                       ,pr_cdcooper crapvra.idevento%TYPE
                       ,pr_nrseqdig crapvra.idevento%TYPE
                       ,pr_dtanoage crapvra.idevento%TYPE
                       ,pr_nrcpfcgc crapvra.idevento%TYPE) IS

      SELECT  NVL(vra.vlrecano,0) AS vlrecano
        FROM crapvra vra
       WHERE vra.idevento = pr_idevento
         AND vra.cdcooper = pr_cdcooper
         AND vra.nrseqdig = pr_nrseqdig
         AND vra.dtanoage = pr_dtanoage
         AND vra.nrcpfcgc = pr_nrcpfcgc;
    
    rw_crapvra_I cr_crapvra_I%ROWTYPE;

    CURSOR cr_crapvra_II(pr_idevento crapvra.idevento%TYPE
                        ,pr_cdcooper crapvra.idevento%TYPE
                        ,pr_nrseqdig crapvra.idevento%TYPE
                        ,pr_dtanoage crapvra.idevento%TYPE
                        ,pr_cdcopvlr crapvra.cdcopvlr%TYPE) IS

      SELECT  vra.vlrecano
        FROM crapvra vra
       WHERE vra.idevento = pr_idevento
         AND vra.cdcooper = pr_cdcooper
         AND vra.nrseqdig = pr_nrseqdig
         AND vra.dtanoage = pr_dtanoage
         AND vra.cdcopvlr = pr_cdcopvlr;

    rw_crapvra_II cr_crapvra_II%ROWTYPE; 

    CURSOR cr_craprpe(pr_idevento craprpe.idevento%TYPE
                     ,pr_cdcooper craprpe.cdcooper%TYPE
                     ,pr_cdevento craprpe.cdevento%TYPE
                     ,pr_cdagenci craprpe.cdagenci%TYPE
                     ,pr_cdcopage craprpe.cdcopage%TYPE) IS

      SELECT rpe.nrseqdig
            ,rpe.qtrecage
            ,rpe.qtgrppar
        FROM craprpe rpe
       WHERE rpe.idevento = pr_idevento 
         AND rpe.cdcooper = pr_cdcooper
         AND rpe.cdevento = pr_cdevento
         AND rpe.cdagenci = pr_cdagenci
         AND rpe.cdcopage = pr_cdcopage;

    rw_craprpe cr_craprpe%ROWTYPE;

     CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE
                      ,pr_cdagenci VARCHAR2) IS
    
      SELECT age.cdagenci, age.nmresage, age.cdufdcop, age.nmcidade
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.insitage IN (1,3) -- Ativo , Temporariamente Indisponivel
         AND age.flgdopgd = 1
         AND (pr_cdagenci = 0 OR age.cdagenci = pr_cdagenci)
       ORDER BY age.nmresage;
  
    rw_crapage cr_crapage%ROWTYPE;

    CURSOR cr_crapree(pr_nrsdieve crapree.nrsdieve%TYPE) IS
      SELECT ree.nrsdieve
            ,ree.nrsdirec
            ,ree.qtreceve
            ,ree.qtgrppar
        FROM crapree ree
       WHERE ree.nrsdieve = pr_nrsdieve;

    rw_crapree cr_crapree%ROWTYPE;
   
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(32000) := '';
    vr_flgerror BOOLEAN := FALSE;  
    vr_conterro INTEGER := 0;

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
  
    -- Variaveis Gerais
    vr_vlrecpor crapadp.vlmateve%TYPE;

    vr_vlhoneve crapadp.vlhoneve%TYPE;
    vr_vlloceve crapadp.vlloceve%TYPE;
    vr_vlalieve crapadp.vlalieve%TYPE;
    vr_vlmateve crapadp.vlmateve%TYPE;
    vr_vltraeve crapadp.vltraeve%TYPE;
    vr_vlbrieve crapadp.vlbrieve%TYPE;
    vr_vldiveve crapadp.vldiveve%TYPE;
    vr_vlouteve crapadp.vlouteve%TYPE;
    vr_vltereve crapadp.vltereve%TYPE;
    vr_vlreceve crapadp.vlreceve%TYPE;
  
    vr_cdlocali crapadp.cdlocali%TYPE;
  BEGIN
  
    -- Validação de Sessão
    OPEN cr_gnapses(pr_idcokses => pr_idcokses);
  
    FETCH cr_gnapses
      INTO rw_gnapses;
  
    IF cr_gnapses%NOTFOUND THEN
      CLOSE cr_gnapses;
      vr_dscritic := vr_dscritic || '#' || 'Erro de sessão: ID de sessão inválido.';
      vr_flgerror := TRUE;
      vr_conterro := vr_conterro + 1;
      IF vr_conterro = 10 THEN
        RAISE vr_exc_erro;        
      END IF;
    ELSE
      CLOSE cr_gnapses;
    END IF;

    -- Consulta o tipo evento
    OPEN cr_crapedp(pr_cdcooper => pr_cdcooper
                   ,pr_dtanoage => pr_dtanoage
                   ,pr_cdevento => pr_cdevento);

    FETCH cr_crapedp INTO rw_crapedp;

    IF cr_crapedp%NOTFOUND THEN
      CLOSE cr_crapedp;
      vr_dscritic := vr_dscritic || '#' || 'Evento principal não encontrado.';
      vr_flgerror := TRUE;
      vr_conterro := vr_conterro + 1;
      IF vr_conterro = 10 THEN
        RAISE vr_exc_erro;        
      END IF;
    ELSE
      CLOSE cr_crapedp;
    END IF;

    -- Consulta informações do evento
    OPEN cr_crapadp(pr_idevento => pr_idevento
                   ,pr_cdcooper => pr_cdcooper
                   ,pr_dtanoage => pr_dtanoage
                   ,pr_cdagenci => pr_cdagenci
                   ,pr_cdevento => pr_cdevento
                   ,pr_nrseqdig => pr_nrseqdig);

    FETCH cr_crapadp INTO rw_crapadp;

    IF cr_crapadp%NOTFOUND THEN
      CLOSE cr_crapadp;
      vr_dscritic := vr_dscritic || '#' || 'Evento não cadastrado.';
      vr_flgerror := TRUE;
      vr_conterro := vr_conterro + 1;
      IF vr_conterro = 10 THEN
        RAISE vr_exc_erro;        
      END IF;
    ELSE
      vr_cdlocali := rw_crapadp.cdlocali;
      CLOSE cr_crapadp;
    END IF;

    -- Consulta PA
    OPEN cr_crapage(pr_cdcooper => pr_cdcooper
                   ,pr_cdagenci => pr_cdagenci);

    FETCH cr_crapage INTO rw_crapage;

    IF cr_crapage%NOTFOUND THEN
      CLOSE cr_crapage;
      vr_dscritic := vr_dscritic || '#' || 'PA não cadastrado.';
      vr_flgerror := TRUE;
      vr_conterro := vr_conterro + 1;
      IF vr_conterro = 10 THEN
        RAISE vr_exc_erro;        
      END IF;
    ELSE
      CLOSE cr_crapage;
    END IF;

    -- Consulta valor do local do evento
    OPEN cr_crapldp(pr_idevento => 1
                   ,pr_cdcooper => pr_cdcooper 
                   ,pr_cdagenci => pr_cdagenci 
                   ,pr_nrseqdig => vr_cdlocali);
    
    FETCH cr_crapldp INTO rw_crapldp;

    IF cr_crapldp%NOTFOUND THEN
      CLOSE cr_crapldp;
      vr_vlloceve := 0;
    ELSE
      CLOSE cr_crapldp;
      vr_vlloceve := rw_crapldp.vldialoc;
    END IF;

    -- Verifica o tipo de evento
    IF rw_crapedp.tpevento = 7 OR
       rw_crapedp.tpevento = 12 THEN -- AGO/AGE
      
      -- Consulta custos de alimentação 
      OPEN cr_crapppc(pr_idevento => 1
                     ,pr_cdcooper => pr_cdcooper
                     ,pr_dtanoage => pr_dtanoage
                     ,pr_cdcuseve => 3);

      FETCH cr_crapppc INTO rw_crapppc;
               
      IF cr_crapppc%FOUND THEN
        CLOSE cr_crapppc;
        IF rw_crapppc.vlrporco IS NULL THEN
          vr_dscritic := vr_dscritic || '#' || 'Valor de Alimentação não cadastrado.';
          vr_flgerror := TRUE;
          vr_conterro := vr_conterro + 1;
          IF vr_conterro = 10 THEN
            RAISE vr_exc_erro;        
          END IF;
        ELSE
          vr_vlalieve := (rw_crapppc.vlrporco * rw_crapadp.qtparpre);
        END IF;
      ELSE
        CLOSE cr_crapppc;                
      END IF; 
    ELSE
      -- CALCULO DE ALIMENTACAO
      OPEN cr_crapppa(pr_idevento => 1
                     ,pr_cdcooper => pr_cdcooper
                     ,pr_dtanoage => pr_dtanoage
                     ,pr_cdagenci => pr_cdagenci
                     ,pr_cdcuseve => 3);

      FETCH cr_crapppa INTO rw_crapppa;
               
      IF cr_crapppa%FOUND THEN
        CLOSE cr_crapppa;
        vr_vlalieve := (NVL(rw_crapppa.vlrporpa,0) * NVL(rw_crapadp.qtparpre,0));
      ELSE
        CLOSE cr_crapppa;

        OPEN cr_crapppr(pr_idevento => 1
                       ,pr_cdcooper => pr_cdcooper
                       ,pr_dtanoage => pr_dtanoage
                       ,pr_cdcuseve => 3);

        FETCH cr_crapppr INTO rw_crapppr;
               
        IF cr_crapppr%FOUND THEN
          CLOSE cr_crapppr;
          vr_vlalieve := (NVL(rw_crapppr.vlrporrg,0) * NVL(rw_crapadp.qtparpre,0));
        ELSE
          CLOSE cr_crapppr;

          OPEN cr_crapppc(pr_idevento => 1
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_dtanoage => pr_dtanoage
                         ,pr_cdcuseve => 3);

          FETCH cr_crapppc INTO rw_crapppc;
               
          IF cr_crapppc%FOUND THEN
            CLOSE cr_crapppc;
            vr_vlalieve := (NVL(rw_crapppc.vlrporco,0) * NVL(rw_crapadp.qtparpre,0));
          ELSE
            CLOSE cr_crapppc; 
            vr_dscritic := vr_dscritic || '#' || 'Valor de alimentação não cadastrado.';
            vr_flgerror := TRUE;
            vr_conterro := vr_conterro + 1;
            IF vr_conterro = 10 THEN
              RAISE vr_exc_erro;        
            END IF;
          END IF;
        END IF;            
      END IF;               
      -- FIM CALCULO DE ALIMENTACAO
    END IF;    

    -- Materiais/Equipamentos
    -- RECURSOS POR EVENTO
    vr_vlmateve := 0;

    FOR rw_craprep IN cr_craprep(pr_idevento => pr_idevento
                                ,pr_cdcooper => 0
                                ,pr_cdevento => pr_cdevento) LOOP

      OPEN cr_gnaprdp_I(pr_idevento => pr_idevento            
                       ,pr_cdcooper => 0
                       ,pr_idsitrec => 1
                       ,pr_nrseqdig => rw_craprep.nrseqdig);

      FETCH cr_gnaprdp_I INTO rw_gnaprdp_I;
                                                     
      IF cr_gnaprdp_I%FOUND THEN               
        CLOSE cr_gnaprdp_I;
        vr_dscritic := vr_dscritic || '#' || 'O recurso por evento(' || UPPER(rw_gnaprdp_I.dsrecurs) || ') associado ao evento, não possui tipo de recurso cadastrado.';
        vr_flgerror := TRUE;
        vr_conterro := vr_conterro + 1;
        IF vr_conterro = 10 THEN
          RAISE vr_exc_erro;        
        END IF;
      ELSE
        CLOSE cr_gnaprdp_I;
      END IF;

      OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                       ,pr_cdcooper => 0
                       ,pr_idsitrec => 1
                       ,pr_nrseqdig => rw_craprep.nrseqdig
                       ,pr_cdtiprec => '3,4');

      FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
      IF cr_gnaprdp_II%NOTFOUND THEN               
        CLOSE cr_gnaprdp_II;
      ELSE
        CLOSE cr_gnaprdp_II;
                
        -- Busca o valor do Recurso por Ano
        OPEN cr_crapvra_II(pr_idevento => pr_idevento
                          ,pr_cdcooper => 0
                          ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                          ,pr_dtanoage => pr_dtanoage
                          ,pr_cdcopvlr => pr_cdcooper);

        FETCH cr_crapvra_II INTO rw_crapvra_II;

        IF cr_crapvra_II%NOTFOUND THEN
          CLOSE cr_crapvra_II;
          vr_dscritic := vr_dscritic || '#' || 'O recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') por evento associado ao evento, não possui valor cadastrado.';
          vr_flgerror := TRUE;
          vr_conterro := vr_conterro + 1;
          IF vr_conterro = 10 THEN
            RAISE vr_exc_erro;        
          END IF;
        ELSE
          CLOSE cr_crapvra_II;
          CASE rw_gnaprdp_II.idrecpor
            WHEN 1 THEN -- POR EVENTO
              IF NVL(rw_craprep.qtreceve,0) = 0 THEN
                  vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais por evento não cadastradas para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ').';
                  vr_flgerror := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                END IF;
              vr_vlrecpor := rw_craprep.qtreceve;
            WHEN 2 THEN -- POR PARTICIPANTES
              vr_vlrecpor := rw_crapadp.qtparpre;
            WHEN 3 THEN -- POR GRUPO DE PARTICIPANTES
              IF NVL(rw_craprep.qtreceve,0) = 0 OR NVL(rw_craprep.qtgrppar,0) = 0 THEN
                  vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais por grupo de participantes não cadastradas para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ').';
                  vr_flgerror := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                END IF;
                                
              BEGIN
                vr_vlrecpor := (NVL(rw_crapadp.qtparpre,0) / NVL(rw_craprep.qtgrppar,0)) * NVL(rw_craprep.qtreceve,0);
              EXCEPTION
                WHEN ZERO_DIVIDE THEN
                  vr_vlrecpor := (NVL(rw_crapadp.qtparpre,0) * NVL(rw_craprep.qtreceve,0));
                WHEN OTHERS THEN
                  vr_dscritic := vr_dscritic || '#' || 'Erro de Cálculo (Divisão por ZERO).';
                  vr_flgerror := TRUE;
              END;  


          END CASE;

          vr_vlmateve := vr_vlmateve + (NVL(vr_vlrecpor,0) * NVL(rw_crapvra_II.vlrecano,0));

        END IF;

      END IF;

    END LOOP;
    -- FIM POR EVENTO  

    -- RECURSOS POR PA
    FOR rw_craprpe IN cr_craprpe(pr_idevento => pr_idevento
                                ,pr_cdcooper => 0
                                ,pr_cdevento => pr_cdevento
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdcopage => pr_cdcooper) LOOP

      OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                       ,pr_cdcooper => 0
                       ,pr_idsitrec => 1
                       ,pr_nrseqdig => rw_craprpe.nrseqdig
                       ,pr_cdtiprec => '0');

      FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
      IF cr_gnaprdp_II%FOUND THEN               
        CLOSE cr_gnaprdp_II;
        vr_dscritic := vr_dscritic || '#' || 'O recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') do PA(' ||  UPPER(rw_crapage.nmresage) || ') associado ao evento, nao possui tipo de recurso cadastrado.';
        vr_flgerror := TRUE;
        vr_conterro := vr_conterro + 1;
        IF vr_conterro = 10 THEN
          RAISE vr_exc_erro;        
        END IF;
      ELSE
        CLOSE cr_gnaprdp_II;
      END IF;

      OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                       ,pr_cdcooper => 0
                       ,pr_idsitrec => 1
                       ,pr_nrseqdig => rw_craprpe.nrseqdig
                       ,pr_cdtiprec => '3,4');

      FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
      IF cr_gnaprdp_II%NOTFOUND THEN               
        CLOSE cr_gnaprdp_II;
      ELSE
        CLOSE cr_gnaprdp_II;

        -- Busca o valor do Recurso por Ano
        OPEN cr_crapvra_II(pr_idevento => pr_idevento
                          ,pr_cdcooper => 0
                          ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                          ,pr_dtanoage => pr_dtanoage
                          ,pr_cdcopvlr => pr_cdcooper);

        FETCH cr_crapvra_II INTO rw_crapvra_II;

        IF cr_crapvra_II%NOTFOUND THEN
          CLOSE cr_crapvra_II;
          vr_dscritic := vr_dscritic || '#' || 'O recurso do PA (' || UPPER(rw_gnaprdp_II.dsrecurs) || ') associado ao evento, não possui valor cadastrado.';
          vr_flgerror := TRUE;
          vr_conterro := vr_conterro + 1;
          IF vr_conterro = 10 THEN
            RAISE vr_exc_erro;        
          END IF;
        ELSE
          CLOSE cr_crapvra_II;

          CASE rw_gnaprdp_II.idrecpor
            WHEN 1 THEN -- POR EVENTO
              IF NVL(rw_craprpe.qtrecage,0) = 0 THEN
                  vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais não cadastradas por PA para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ').';
                  vr_flgerror := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                END IF;
              vr_vlrecpor := rw_craprpe.qtrecage;
            WHEN 2 THEN -- POR PARTICIPANTES
              vr_vlrecpor := rw_crapadp.qtparpre;
            WHEN 3 THEN -- POR GRUPO DE PARTICIPANTES
              IF NVL(rw_craprpe.qtrecage,0) = 0 OR NVL(rw_craprpe.qtgrppar,0) = 0 THEN
                vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais por PA não cadastradas para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ').';
                vr_flgerror := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              END IF;
            
            BEGIN
              vr_vlrecpor := (NVL(rw_crapadp.qtparpre,0) / NVL(rw_craprpe.qtgrppar,0)) * NVL(rw_craprpe.qtrecage,0);
            EXCEPTION
              WHEN ZERO_DIVIDE THEN
                vr_vlrecpor := (NVL(rw_crapadp.qtparpre,0) * NVL(rw_craprpe.qtrecage,0));
              WHEN OTHERS THEN
                vr_dscritic := vr_dscritic || '#' || 'Erro de Cálculo (Divisão por ZERO).';
                vr_flgerror := TRUE;
            END;            

          END CASE;

          vr_vlmateve := NVL(vr_vlmateve,0) + (NVL(vr_vlrecpor,0) * NVL(rw_crapvra_II.vlrecano,0));

        END IF;

      END IF;            

    END LOOP; -- FIM RECURSOS POR PA

    -- RECURSOS AGENDA ANUAL
    FOR rw_crapree IN cr_crapree(pr_nrsdieve => pr_nrseqdig) LOOP

      OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                       ,pr_cdcooper => 0
                       ,pr_idsitrec => 1
                       ,pr_nrseqdig => rw_crapree.nrsdirec
                       ,pr_cdtiprec => '0');

      FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
      IF cr_gnaprdp_II%FOUND THEN               
        CLOSE cr_gnaprdp_II;
        vr_dscritic := vr_dscritic || '#' || 'O recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') deste evento, nao possui tipo de recurso cadastrado.';
        vr_flgerror := TRUE;
        vr_conterro := vr_conterro + 1;
        IF vr_conterro = 10 THEN
          RAISE vr_exc_erro;        
        END IF;
      ELSE
        CLOSE cr_gnaprdp_II;
      END IF;

      OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                       ,pr_cdcooper => 0
                       ,pr_idsitrec => 1
                       ,pr_nrseqdig => rw_crapree.nrsdirec
                       ,pr_cdtiprec => '3,4');

      FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
      IF cr_gnaprdp_II%NOTFOUND THEN               
        CLOSE cr_gnaprdp_II;
      ELSE
        CLOSE cr_gnaprdp_II;

        -- Busca o valor do Recurso por Ano
        OPEN cr_crapvra_II(pr_idevento => pr_idevento
                          ,pr_cdcooper => 0
                          ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                          ,pr_dtanoage => pr_dtanoage
                          ,pr_cdcopvlr => pr_cdcooper);

        FETCH cr_crapvra_II INTO rw_crapvra_II;

        IF cr_crapvra_II%NOTFOUND THEN
          CLOSE cr_crapvra_II;
          vr_dscritic := vr_dscritic || '#' || 'O recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') deste evento, não possui valor cadastrado.';
          vr_flgerror := TRUE;
          vr_conterro := vr_conterro + 1;
          IF vr_conterro = 10 THEN
            RAISE vr_exc_erro;        
          END IF;
        ELSE
          CLOSE cr_crapvra_II;

          CASE rw_gnaprdp_II.idrecpor
            WHEN 1 THEN -- POR EVENTO
              IF NVL(rw_crapree.qtreceve,0) = 0 THEN
                  vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais não cadastradas para este recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ').';
                  vr_flgerror := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                END IF;
              vr_vlrecpor := rw_crapree.qtreceve;
            WHEN 2 THEN -- POR PARTICIPANTES
              vr_vlrecpor := rw_crapadp.qtparpre;
            WHEN 3 THEN -- POR GRUPO DE PARTICIPANTES
              IF NVL(rw_crapree.qtreceve,0) = 0 OR NVL(rw_crapree.qtgrppar,0) = 0 THEN
                vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais não cadastradas para este recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ').';
                vr_flgerror := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              END IF;
            
              BEGIN
                vr_vlrecpor := (NVL(rw_crapadp.qtparpre,0) / NVL(rw_crapree.qtgrppar,0)) * NVL(rw_crapree.qtreceve,0);
              EXCEPTION
                WHEN ZERO_DIVIDE THEN
                  vr_vlrecpor := (NVL(rw_craprep.qtgrppar,0) * NVL(rw_crapree.qtreceve,0));
                WHEN OTHERS THEN
                  vr_dscritic := vr_dscritic || '#' || 'Erro de Cálculo (Divisão por ZERO).';
                  vr_flgerror := TRUE;
              END;

          END CASE;

          vr_vlmateve := NVL(vr_vlmateve,0) + (NVL(vr_vlrecpor,0) * NVL(rw_crapvra_II.vlrecano,0));

        END IF;

      END IF;            

    END LOOP;
    -- FIM RECURSOS AGENDA ANUAL
    
    -- Recreação
    -- POR EVENTO
    FOR rw_craprep IN cr_craprep(pr_idevento => pr_idevento
                                ,pr_cdcooper => 0
                                ,pr_cdevento => pr_cdevento) LOOP

      OPEN cr_gnaprdp_I(pr_idevento => pr_idevento            
                       ,pr_cdcooper => 0
                       ,pr_idsitrec => 1
                       ,pr_nrseqdig => rw_craprep.nrseqdig);

      FETCH cr_gnaprdp_I INTO rw_gnaprdp_I;
                                                     
      IF cr_gnaprdp_I%FOUND THEN               
        CLOSE cr_gnaprdp_I;
        vr_dscritic := vr_dscritic || '#' || 'O recurso de recreação por evento(' || UPPER(rw_gnaprdp_I.dsrecurs) || ') associado ao evento, não possui tipo de recurso cadastrado.';
        vr_flgerror := TRUE;
        vr_conterro := vr_conterro + 1;
        IF vr_conterro = 10 THEN
          RAISE vr_exc_erro;        
        END IF;
      ELSE
        CLOSE cr_gnaprdp_I;
      END IF;

      OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                       ,pr_cdcooper => 0
                       ,pr_idsitrec => 1
                       ,pr_nrseqdig => rw_craprep.nrseqdig
                       ,pr_cdtiprec => '6');

      FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
      IF cr_gnaprdp_II%NOTFOUND THEN               
        CLOSE cr_gnaprdp_II;
      ELSE
        CLOSE cr_gnaprdp_II;
                
        -- Busca o valor do Recurso por Ano
        OPEN cr_crapvra_II(pr_idevento => pr_idevento
                          ,pr_cdcooper => 0
                          ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                          ,pr_dtanoage => pr_dtanoage
                          ,pr_cdcopvlr => pr_cdcooper);

        FETCH cr_crapvra_II INTO rw_crapvra_II;

        IF cr_crapvra_II%NOTFOUND THEN
          CLOSE cr_crapvra_II;
          vr_dscritic := vr_dscritic || '#' || 'O recurso de recreação(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') por evento associado ao evento, não possui valor cadastrado.';
          vr_flgerror := TRUE;
          vr_conterro := vr_conterro + 1;
          IF vr_conterro = 10 THEN
            RAISE vr_exc_erro;        
          END IF;
        ELSE
          CLOSE cr_crapvra_II;
          CASE rw_gnaprdp_II.idrecpor
            WHEN 1 THEN -- POR EVENTO
              IF NVL(rw_craprep.qtreceve,0) = 0 THEN
                  vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais de recreação por evento não cadastradas para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ').';
                  vr_flgerror := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                END IF;
              vr_vlrecpor := rw_craprep.qtreceve;
            WHEN 2 THEN -- POR PARTICIPANTES
              vr_vlrecpor := rw_crapadp.qtparpre;
            WHEN 3 THEN -- POR GRUPO DE PARTICIPANTES
              IF NVL(rw_craprep.qtreceve,0) = 0 OR NVL(rw_craprep.qtgrppar,0) = 0 THEN
                  vr_dscritic := vr_dscritic || '#' || 'Quantidades de recursos de recreação por grupo de participantes não cadastradas para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ').';
                  vr_flgerror := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                END IF;
                                
              BEGIN
                vr_vlrecpor := (NVL(rw_crapadp.qtparpre,0) / NVL(rw_craprep.qtgrppar,0)) * NVL(rw_craprep.qtreceve,0);
              EXCEPTION
                WHEN ZERO_DIVIDE THEN
                  vr_vlrecpor := (NVL(rw_crapadp.qtparpre,0) * NVL(rw_craprep.qtreceve,0));
                WHEN OTHERS THEN
                  vr_dscritic := vr_dscritic || '#' || 'Erro de Cálculo (Divisão por ZERO).';
                  vr_flgerror := TRUE;
              END;

          END CASE;

          vr_vlreceve := NVL(vr_vlreceve,0) + (NVL(vr_vlrecpor,0) * NVL(rw_crapvra_II.vlrecano,0));
          
        END IF;

      END IF;

    END LOOP;
    -- FIM POR EVENTO  

    -- RECURSOS POR PA
    FOR rw_craprpe IN cr_craprpe(pr_idevento => pr_idevento
                                ,pr_cdcooper => 0
                                ,pr_cdevento => pr_cdevento
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdcopage => pr_cdcooper) LOOP

      OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                       ,pr_cdcooper => 0
                       ,pr_idsitrec => 1
                       ,pr_nrseqdig => rw_craprpe.nrseqdig
                       ,pr_cdtiprec => '0');

      FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
      IF cr_gnaprdp_II%FOUND THEN               
        CLOSE cr_gnaprdp_II;
        vr_dscritic := vr_dscritic || '#' || 'O recurso de recreação(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') do PA(' ||  UPPER(rw_crapage.nmresage) || ') associado ao evento, nao possui tipo de recurso cadastrado.';
        vr_flgerror := TRUE;
        vr_conterro := vr_conterro + 1;
        IF vr_conterro = 10 THEN
          RAISE vr_exc_erro;        
        END IF;
      ELSE
        CLOSE cr_gnaprdp_II;
      END IF;

      OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                       ,pr_cdcooper => 0
                       ,pr_idsitrec => 1
                       ,pr_nrseqdig => rw_craprpe.nrseqdig
                       ,pr_cdtiprec => '6');

      FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
      IF cr_gnaprdp_II%NOTFOUND THEN               
        CLOSE cr_gnaprdp_II;
      ELSE
        CLOSE cr_gnaprdp_II;

        -- Busca o valor do Recurso por Ano
        OPEN cr_crapvra_II(pr_idevento => pr_idevento
                          ,pr_cdcooper => 0
                          ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                          ,pr_dtanoage => pr_dtanoage
                          ,pr_cdcopvlr => pr_cdcooper);

        FETCH cr_crapvra_II INTO rw_crapvra_II;

        IF cr_crapvra_II%NOTFOUND THEN
          CLOSE cr_crapvra_II;
          vr_dscritic := vr_dscritic || '#' || 'O recurso de recreação do PA (' || UPPER(rw_gnaprdp_II.dsrecurs) || ') associado ao evento, não possui valor cadastrado.';
          vr_flgerror := TRUE;
          vr_conterro := vr_conterro + 1;
          IF vr_conterro = 10 THEN
            RAISE vr_exc_erro;        
          END IF;
        ELSE
          CLOSE cr_crapvra_II;

          CASE rw_gnaprdp_II.idrecpor
            WHEN 1 THEN -- POR EVENTO
              IF NVL(rw_craprpe.qtrecage,0) = 0 THEN
                  vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais de recreação não cadastradas por PA para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ').';
                  vr_flgerror := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                END IF;
              vr_vlrecpor := rw_craprpe.qtrecage;
            WHEN 2 THEN -- POR PARTICIPANTES
              vr_vlrecpor := rw_crapadp.qtparpre;
            WHEN 3 THEN -- POR GRUPO DE PARTICIPANTES
              IF NVL(rw_craprpe.qtrecage,0) = 0 OR NVL(rw_craprpe.qtgrppar,0) = 0 THEN
                vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais de recreação por PA não cadastradas para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ').';
                vr_flgerror := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              END IF;
            
            BEGIN
              vr_vlrecpor := (NVL(rw_crapadp.qtparpre,0) / NVL(rw_craprpe.qtgrppar,0)) * NVL(rw_craprpe.qtrecage,0);
            EXCEPTION
              WHEN ZERO_DIVIDE THEN
                vr_vlrecpor := (NVL(rw_crapadp.qtparpre,0) * NVL(rw_craprpe.qtrecage,0));
              WHEN OTHERS THEN
                vr_dscritic := vr_dscritic || '#' || 'Erro de Cálculo (Divisão por ZERO).';
                vr_flgerror := TRUE;
            END;            

          END CASE;

          vr_vlreceve := NVL(vr_vlreceve,0) + (NVL(vr_vlrecpor,0) * NVL(rw_crapvra_II.vlrecano,0));

        END IF;

      END IF;            

    END LOOP; -- FIM RECURSOS POR PA

    -- RECURSOS AGENDA ANUAL
    FOR rw_crapree IN cr_crapree(pr_nrsdieve => pr_nrseqdig) LOOP

      OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                       ,pr_cdcooper => 0
                       ,pr_idsitrec => 1
                       ,pr_nrseqdig => rw_crapree.nrsdirec
                       ,pr_cdtiprec => '0');

      FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
      IF cr_gnaprdp_II%FOUND THEN               
        CLOSE cr_gnaprdp_II;
        vr_dscritic := vr_dscritic || '#' || 'O recurso de recreação(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') deste evento, nao possui tipo de recurso cadastrado.';
        vr_flgerror := TRUE;
        vr_conterro := vr_conterro + 1;
        IF vr_conterro = 10 THEN
          RAISE vr_exc_erro;        
        END IF;
      ELSE
        CLOSE cr_gnaprdp_II;
      END IF;

      OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                       ,pr_cdcooper => 0
                       ,pr_idsitrec => 1
                       ,pr_nrseqdig => rw_crapree.nrsdirec
                       ,pr_cdtiprec => '6');

      FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
      IF cr_gnaprdp_II%NOTFOUND THEN               
        CLOSE cr_gnaprdp_II;
      ELSE
        CLOSE cr_gnaprdp_II;

        -- Busca o valor do Recurso por Ano
        OPEN cr_crapvra_II(pr_idevento => pr_idevento
                          ,pr_cdcooper => 0
                          ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                          ,pr_dtanoage => pr_dtanoage
                          ,pr_cdcopvlr => pr_cdcooper);

        FETCH cr_crapvra_II INTO rw_crapvra_II;

        IF cr_crapvra_II%NOTFOUND THEN
          CLOSE cr_crapvra_II;
          vr_dscritic := vr_dscritic || '#' || 'O recurso de recreação (' || UPPER(rw_gnaprdp_II.dsrecurs) || ') deste evento, não possui valor cadastrado.';
          vr_flgerror := TRUE;
          vr_conterro := vr_conterro + 1;
          IF vr_conterro = 10 THEN
            RAISE vr_exc_erro;        
          END IF;
        ELSE
          CLOSE cr_crapvra_II;

          CASE rw_gnaprdp_II.idrecpor
            WHEN 1 THEN -- POR EVENTO
              IF NVL(rw_crapree.qtreceve,0) = 0 THEN
                  vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais de recreação não cadastradas para este recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ').';
                  vr_flgerror := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                END IF;
              vr_vlrecpor := rw_crapree.qtreceve;
            WHEN 2 THEN -- POR PARTICIPANTES
              vr_vlrecpor := rw_crapadp.qtparpre;
            WHEN 3 THEN -- POR GRUPO DE PARTICIPANTES
              IF NVL(rw_crapree.qtreceve,0) = 0 OR NVL(rw_crapree.qtgrppar,0) = 0 THEN
                vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais de recreação não cadastradas para este recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ').';
                vr_flgerror := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              END IF;
            
              BEGIN
                vr_vlrecpor := (NVL(rw_crapadp.qtparpre,0) / NVL(rw_crapree.qtgrppar,0)) * NVL(rw_crapree.qtreceve,0);
              EXCEPTION
                WHEN ZERO_DIVIDE THEN
                  vr_vlrecpor := (NVL(rw_crapree.qtgrppar,0) * NVL(rw_crapree.qtreceve,0));
                WHEN OTHERS THEN
                  vr_dscritic := vr_dscritic || '#' || 'Erro de Cálculo (Divisão por ZERO).';
                  vr_flgerror := TRUE;
              END;

          END CASE;

          vr_vlreceve := NVL(vr_vlreceve,0) + (NVL(vr_vlrecpor,0) * NVL(rw_crapvra_II.vlrecano,0));

        END IF;

      END IF;            

    END LOOP;
    -- FIM RECURSOS AGENDA ANUAL
    -- FIM RECREACAO

    BEGIN

      UPDATE crapadp
         SET crapadp.vlhoneve = NVL(vr_vlhoneve,0)
            ,crapadp.vlloceve = NVL(vr_vlloceve,0)
            ,crapadp.vlalieve = NVL(vr_vlalieve,0)
            ,crapadp.vlmateve = NVL(vr_vlmateve,0)
            ,crapadp.vltraeve = NVL(vr_vltraeve,0)
            ,crapadp.vlbrieve = NVL(vr_vlbrieve,0)
            ,crapadp.vldiveve = NVL(vr_vldiveve,0)
            ,crapadp.vlouteve = NVL(vr_vlouteve,0)
            ,crapadp.vltereve = NVL(vr_vltereve,0)
            ,crapadp.vlreceve = NVL(vr_vlreceve,0)
       WHERE crapadp.idevento = pr_idevento
         AND crapadp.cdcooper = pr_cdcooper
         AND crapadp.dtanoage = pr_dtanoage
         AND crapadp.cdagenci = pr_cdagenci
         AND crapadp.cdevento = pr_cdevento
         AND crapadp.nrseqdig = pr_nrseqdig;

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := vr_dscritic || '#' || 'Erro ao atualizar registro CRAPADP: ' || SQLERRM;
        vr_flgerror := TRUE;
        vr_conterro := vr_conterro + 1;
        IF vr_conterro = 10 THEN
          RAISE vr_exc_erro;        
        END IF;
    END;
             
    -- Se ocorreu algum erro não efetiva o calculo
    IF vr_flgerror THEN
      RAISE vr_exc_erro;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN    
      pr_dscritic := vr_dscritic;
      ROLLBACK;    
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em ASSE0001.pc_calc_custo_eve_ass: ' || SQLERRM;
      ROLLBACK;    
  END pc_calc_custo_eve_ass;

  PROCEDURE pc_email_dat_ini_planej(pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da Crítica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descrição da Crítica
    -- ..........................................................................
    --
    --  Programa : pc_email_dat_ini_planej
    --  Sistema  : PROGRID
    --  Sigla    : ASSE
    --  Autor    : Jean Michel
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Esta rotina irá rodar diariamente verificando se a data atual é 
    --              igual a data de início do planejamento. Se a data for igual um email
    --              será enviado para os PA’s participantes.
    --
    --  Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      
      --------> CURSORES <--------
      
      CURSOR cr_crapcop IS
       SELECT cop.cdcooper AS cdcooper
             ,age.cdagenci || '-' || age.nmresage AS nmresage
             ,age.dsdemail AS dsdemail
         FROM crapcop cop
             ,crapage age
             ,crappcc pcc
             ,crappcp pcp
        WHERE cop.flgativo = 1
          AND age.flgdopgd = 1
          AND cop.cdcooper = age.cdcooper
          AND cop.cdcooper = pcc.cdcooper
          AND pcc.cdcooper = pcp.cdcooper
          AND pcc.dtanoage = pcp.dtanoage
          AND age.cdagenci = pcp.cdagenci
          AND pcc.dtiniexe = TRUNC(SYSDATE)
          AND TRIM(age.dsdemail) IS NOT NULL;
    
      rw_crapcop cr_crapcop%ROWTYPE;
     
      -- Variaveis de erro e excessao
      vr_exc_null  EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic crapcri.dscritic%TYPE := '';
      
      -- Variaveis locais
      vr_nmresage VARCHAR(4000) := '';
      vr_dscorpo VARCHAR(4000) := '';
      
    BEGIN
    
      FOR rw_crapcop IN cr_crapcop LOOP
      
        vr_dscorpo := '<br>Prezado coordenador do PA ' || rw_crapcop.nmresage || '.' ||
                      '<br>Você e sua equipe precisam iniciar a execução do PROGRAMA COOPERACRIANÇA deste ano.' ||
                      '<br>É muito importante para o sucesso desse evento, que você verifique quais serão as ações, eventos e atividades.' ||
                      '<br><br>Consulte a OQS da sua sede para maiores informações.' ||
                      '<br><br>Atenciosamente<br>Equipe de OQS.';

        -- Enviar e-mail dos dados deste sinistro
        gene0003.pc_solicita_email(pr_cdcooper        => rw_crapcop.cdcooper                                      --> Código da Cooperativa 
                                  ,pr_cdprogra        => 'ASSE0001'                                       --> Programa conectado
                                  ,pr_des_destino     => rw_crapcop.dsdemail                              --> Um ou mais detinatários separados por ';' ou ','
                                  ,pr_des_assunto     => 'Início do Planejamento do Cooperacriança'       --> Assunto do e-mail
                                  ,pr_des_corpo       => vr_dscorpo                                       --> Corpo (conteudo) do e-mail
                                  ,pr_des_anexo       => NULL                                             --> Um ou mais anexos separados por ';' ou ','
                                  ,pr_flg_remove_anex => NULL                                             --> Remover os anexos passados
                                  ,pr_flg_log_batch   => NULL                                             --> Incluir no log a informação do anexo?
                                  ,pr_flg_enviar      => 'S'                                              --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic) ;    
                                
        -- Caso encontre alguma critica no envio do email                          
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
     
      END LOOP;

    EXCEPTION
      WHEN vr_exc_null THEN
        NULL;
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral ASSE0001.pc_email_dat_ini_planej: ' || SQLERRM;
    END;
  END pc_email_dat_ini_planej;

END ASSE0001;
/
