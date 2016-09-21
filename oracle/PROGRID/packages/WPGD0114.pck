CREATE OR REPLACE PACKAGE PROGRID.WPGD0114 is
 ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0114                     
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Junho/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas gerais referente a tela WPGD0114
  --
  -- Alteracoes:   
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Rotina geral de insert, update, select e delete da tela WPGD0114
  PROCEDURE pc_wpgd0114(pr_idevento IN crapadp.idevento%TYPE --> Código do Id do evento
                       ,pr_cdcopori IN crapcop.cdcooper%TYPE --> Código da cooperativa de origem
                       ,pr_cdcopdes IN crapcop.cdcooper%TYPE --> Código da cooperativa de destino
                       ,pr_dtanoori IN crapadp.dtanoage%TYPE --> Ano da agenda de origem
                       ,pr_dtanodes IN crapadp.dtanoage%TYPE --> Ano da agenda de destino
                       ,pr_listeven IN VARCHAR2              --> Lista de Eventos Selecionados
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);
  
END WPGD0114;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0114 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0114                     
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Junho/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas gerais referente a tela WPGD0114
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Rotina geral de insert, update, select e delete da tela WPGD0114
  PROCEDURE pc_wpgd0114(pr_idevento IN crapadp.idevento%TYPE --> Código do Id do evento
                       ,pr_cdcopori IN crapcop.cdcooper%TYPE --> Código da cooperativa de origem
                       ,pr_cdcopdes IN crapcop.cdcooper%TYPE --> Código da cooperativa de destino
                       ,pr_dtanoori IN crapadp.dtanoage%TYPE --> Ano da agenda de origem
                       ,pr_dtanodes IN crapadp.dtanoage%TYPE --> Ano da agenda de destino
                       ,pr_listeven IN VARCHAR2              --> Lista de Eventos Selecionados
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS

    -- Cursor sobre a tabela de cidades origem
    CURSOR cr_crapadp IS
      SELECT adp.cdevento AS cdevento
            ,edp.nmevento AS nmevento
        FROM crapadp adp
        JOIN crapedp edp 
          ON edp.idevento = adp.idevento
         AND edp.cdevento = adp.cdevento
         AND edp.dtanoage = adp.dtanoage
         AND edp.cdcooper = adp.cdcooper
         AND edp.flgativo = 1 -- Ativo
       WHERE adp.cdcooper = pr_cdcopori
         AND adp.dtanoage = pr_dtanoori
         AND adp.idstaeve in(1,3,4,5,6) --(Confirmados) --1 - AGENDADO, 3 -TRANSFERIDO, 4 - ENCERRADO, 5 - REALIZADO e 6 - ACRESCIDO 
         -- evento da agenda de origem avaliação cadastrada
         and exists (SELECT 1 
                       FROM craprap r
                      WHERE r.idevento = adp.idevento
                        AND r.cdcooper = adp.cdcooper
                        AND r.cdagenci = adp.cdagenci
                        AND r.dtanoage = adp.dtanoage
                        AND r.cdevento = adp.cdevento
                        AND r.nrseqeve = adp.nrseqdig)           
    GROUP BY adp.cdevento, edp.nmevento
     INTERSECT --comuns aos parâmetros de origem e destino
        SELECT adp.cdevento
              ,edp.nmevento
          FROM crapadp adp
          JOIN crapedp edp
            ON edp.idevento = adp.idevento
           AND edp.cdevento = adp.cdevento
           AND edp.dtanoage = adp.dtanoage
           AND edp.cdcooper = adp.cdcooper
           AND edp.flgativo = 1 -- Ativo
         WHERE adp.cdcooper = pr_cdcopdes
           AND adp.dtanoage = pr_dtanodes
           AND adp.idstaeve IN(1,3,4,5,6) --(Confirmados) --1 - AGENDADO, 3 - TRANSFERIDO, 4 - ENCERRADO, 5 - REALIZADO e 6 - ACRESCIDO 
           -- evento da agenda de destino não possua avaliação cadastrada
           AND NOT EXISTS(SELECT 1 
                            FROM craprap r
                           WHERE r.idevento = adp.idevento
                             AND r.cdcooper = adp.cdcooper
                             AND r.cdagenci = adp.cdagenci
                             AND r.dtanoage = adp.dtanoage
                             AND r.cdevento = adp.cdevento
                             AND r.nrseqeve = adp.nrseqdig)
      GROUP BY adp.cdevento, edp.nmevento
      ORDER BY nmevento;

      rw_crapadp cr_crapadp%ROWTYPE;

      CURSOR cr_craprap_ori(pr_cdevento crapadp.cdevento%TYPE) IS
        SELECT r.*
          FROM craprap r
          WHERE r.idevento = pr_idevento
            AND r.cdcooper = pr_cdcopori --&cdcooper_origem
            AND r.dtanoage = pr_dtanoori--&dtanoage_origem
            AND r.cdevento = pr_cdevento /*IN (SELECT
regexp_substr(pr_listeven, '[^,;]+', 1, ROWNUM) N FROM dual
                     CONNECT BY LEVEL <= length(regexp_replace(pr_listeven,
'[^,;]+', '')) + 1) --c1.cdevento -- evento selecionado na tela*/
            --considerar o menor PA ativo
            AND r.nrseqeve = (SELECT MIN(r.nrseqeve)
                                FROM craprap r
                               WHERE r.idevento = pr_idevento
                                 AND r.cdcooper = pr_cdcopori --&cdcooper_origem
                                 AND r.dtanoage = pr_dtanoori --&dtanoage_origem
                                 AND r.cdevento = pr_cdevento);

      rw_craprap_ori cr_craprap_ori%ROWTYPE;

      CURSOR cr_craprap_des IS
      SELECT adp.idevento,
             adp.cdcooper,
             adp.cdagenci,
             adp.dtanoage,
             adp.cdevento,
             adp.nrseqdig
        FROM crapadp adp
       WHERE adp.cdcooper = pr_cdcopdes
         AND adp.dtanoage = pr_dtanodes
         AND adp.cdevento IN (SELECT regexp_substr(pr_listeven, '[^,;]+', 1, ROWNUM) N FROM dual
                     CONNECT BY LEVEL <= length(regexp_replace(pr_listeven, '[^,;]+', '')) + 1)
         AND adp.idstaeve IN(1,3,4,5,6) --(Confirmados) --1 - AGENDADO, 3 -TRANSFERIDO, 4 - ENCERRADO, 5 - REALIZADO e 6 - ACRESCIDO 
         -- evento da agenda de destino não possua avaliação cadastrada
         AND NOT EXISTS(SELECT 1 
                          FROM craprap r
                         WHERE r.idevento = adp.idevento
                           AND r.cdcooper = adp.cdcooper
                           AND r.cdagenci = adp.cdagenci
                           AND r.dtanoage = adp.dtanoage
                           AND r.cdevento = adp.cdevento
                           AND r.nrseqeve = adp.nrseqdig); 

      rw_craprap_des cr_craprap_des%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela craptel.nmdatela%TYPE;
      vr_nmdeacao crapaca.nmdeacao%TYPE;     
      vr_idcokses VARCHAR2(100);
      vr_idsistem craptel.idsistem%TYPE;
      vr_cddopcao VARCHAR2(100);

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
    
      prgd0001.pc_extrai_dados_prgd(pr_xml      => pr_retxml
                                   ,pr_cdcooper => vr_cdcooper
                                   ,pr_cdoperad => vr_cdoperad
                                   ,pr_nmdatela => vr_nmdatela
                                   ,pr_nmdeacao => vr_nmdeacao
                                   ,pr_idcokses => vr_idcokses
                                   ,pr_idsistem => vr_idsistem
                                   ,pr_cddopcao => vr_cddopcao
                                   ,pr_dscritic => vr_dscritic);

      -- Verifica se houve critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;                      
    
      -- Verifica o tipo de acao que sera executada
      CASE vr_cddopcao

        WHEN 'CE' THEN -- Carrega Eventos
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');  
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'Registros', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          -- Loop sobre os Temas do Progrid
          FOR rw_crapadp IN cr_crapadp LOOP
                 
            GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Registros'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

            GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapadp.cdevento, pr_des_erro => vr_dscritic);
            GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapadp.nmevento, pr_des_erro => vr_dscritic);  
            vr_contador := vr_contador + 1;              
          END LOOP;
            
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_contador, pr_des_erro => vr_dscritic);

        WHEN 'CO' THEN -- Cópia
          -- Para cada evento selecionado na tela fazer:
          -- Selecionar os eventos de destinho que receberão os itens de avaliação
          FOR rw_craprap_des IN cr_craprap_des LOOP
            --Selecionar na tabela de itens de avaliação do evento (CRAPRAP) os itens de avaliação cadastrados 
            -- para a agenda/cooperativa/evento de origem (considerar o menor PAativo);
            FOR rw_craprap_ori IN cr_craprap_ori(pr_cdevento => rw_craprap_des.cdevento) LOOP
              -- Gravar, para cada ocorrência do mesmo evento, para
              -- agenda/cooperativa de destino, as informações do item de avaliação
              -- (Importante:sem as quantidades informadas).
              BEGIN
                INSERT INTO craprap(idevento,
                                    cdcooper,
                                    cdagenci,
                                    dtanoage,
                                    cdevento,
                                    cditeava,
                                    cdgruava,
                                    qtavares,
                                    qtavaoti,
                                    qtavabom,
                                    qtavareg,
                                    qtavains,
                                    nrseqeve,
                                    dsobserv)
                VALUES(pr_idevento,
                       pr_cdcopdes,
                       rw_craprap_des.cdagenci,
                       pr_dtanodes,
                       rw_craprap_des.cdevento,
                       rw_craprap_ori.cditeava,
                       rw_craprap_ori.cdgruava,
                       0,--qtavares,
                       0,--qtavaoti,
                       0,--qtavabom,
                       0,--qtavareg,
                       0,--qtavains,
                       rw_craprap_des.nrseqdig, -- nrseqeve
                       ''); --dsobserv

              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  vr_dscritic := 'Registro de avaliação já existente. Evento: ' || rw_craprap_des.cdevento || '. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;

                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir registro de avaliacao. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;      
            END LOOP;
          END LOOP;
      END CASE;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em WPGD0114: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
 END PC_WPGD0114;  
  
END WPGD0114;
/
