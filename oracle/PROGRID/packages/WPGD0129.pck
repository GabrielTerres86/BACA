CREATE OR REPLACE PACKAGE PROGRID.WPGD0129 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0129
  --  Sistema  : Rotinas para tela de Programas do Progrid
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Fevereiro/2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Programas do Progrid
  --
  -- Alteracoes:   
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral da tela WPGD0129
  PROCEDURE WPGD0129(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                    ,pr_nrsdiass IN crapadp.cdevento%TYPE --> Codigo do Evento Assemblear
                    ,pr_nrsdipro IN crapadp.cdevento%TYPE --> Codigo do Evento do Progrid
                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                    ,pr_des_erro OUT VARCHAR2);           --> Descricao do erro

  -- Procedure para listar os eventos do sistema
  PROCEDURE PC_CARREGA_EVENTOS(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo do PA
                              ,pr_dtanoage IN crapadp.dtanoage%TYPE --> Ano da Agenda
                              ,pr_idevento IN crapadp.idevento%TYPE --> Tipo do Evento(1-Progrid / 2-Assemblear)
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro  

END WPGD0129;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0129 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0129                     
  --  Sistema  : Rotinas para Programas do Progrid
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Fevereiro/2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Programas do Progrid
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral da tela WPGD0129
  PROCEDURE WPGD0129(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                    ,pr_nrsdiass IN crapadp.cdevento%TYPE --> Codigo do Evento Assemblear
                    ,pr_nrsdipro IN crapadp.cdevento%TYPE --> Codigo do Evento do Progrid
                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                    ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do erro

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela craptel.nmdatela%TYPE;
      vr_nmdeacao crapaca.nmdeacao%TYPE;     
      vr_idcokses VARCHAR2(100);
      vr_idsistem craptel.idsistem%TYPE;
      vr_cddopcao VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

    BEGIN
    
      PRGD0001.pc_extrai_dados_prgd(pr_xml      => pr_retxml
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
    
      BEGIN
        INSERT INTO crapsie(nrsdipro, nrsdiass, dtsolici, cdcopsol, cdopesol, idsitsol)
          VALUES(pr_nrsdipro, pr_nrsdiass, SYSDATE, pr_cdcooper, vr_cdoperad, 1);
      EXCEPTION
        WHEN dup_val_on_index THEN
         BEGIN
           UPDATE crapsie
             SET crapsie.dtsolici = SYSDATE
                ,crapsie.cdcopsol = pr_cdcooper
                ,crapsie.cdopesol = vr_cdoperad
                ,crapsie.idsitsol = 1
                ,crapsie.cdcopana = NULL
                ,crapsie.cdopeana = NULL
                ,crapsie.dtanalis = NULL
           WHERE crapsie.nrsdipro = pr_nrsdipro
             AND crapsie.nrsdiass = pr_nrsdiass;
         EXCEPTION
           WHEN OTHERS THEN
           vr_dscritic := 'Erro ao inserir registro de solicitação de integração. Erro: ' || SQLERRM;
           RAISE vr_exc_saida;
         END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro de solicitação de integração. Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      COMMIT;

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
        pr_dscritic := 'Erro geral em WPGD0129: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END WPGD0129;

  -- Procedure para listar os eventos do sistema
  PROCEDURE PC_CARREGA_EVENTOS(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo do PA
                              ,pr_dtanoage IN crapadp.dtanoage%TYPE --> Ano da Agenda
                              ,pr_idevento IN crapadp.idevento%TYPE --> Tipo do Evento(1-Progrid / 2-Assemblear)
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro  

    -- PROGRID
    CURSOR cr_crapedp_pro(pr_idevento crapeap.idevento%TYPE
                         ,pr_cdcooper crapeap.cdcooper%TYPE
                         ,pr_cdagenci crapeap.cdagenci%TYPE
                         ,pr_dtanoage crapeap.dtanoage%TYPE) IS

      SELECT ca.nrseqdig AS cdevento
            ,ce.nmevento||' - '||ca.dtinieve||' - '||ca.dshroeve AS nmevento
      
        FROM crapedp ce
            ,crapadp ca
       WHERE ce.idevento = pr_idevento
         AND ce.dtanoage = pr_dtanoage -- Parâmetro
         AND ce.cdcooper = pr_cdcooper -- Parâmetro
         AND ce.idperint = 1
         AND ce.flgativo = 1
         AND ce.tpevento NOT IN(10,11)  -- Nao buscar EAD
         AND ca.idevento = ce.idevento
         AND ca.cdcooper = ce.cdcooper
         AND ca.dtanoage = ce.dtanoage
         AND ca.cdevento = ce.cdevento
         AND (ca.cdagenci = pr_cdagenci OR pr_cdagenci = 0)  -- Parâmetro
         AND nvl(ca.nrseqint,0) = 0
         AND ca.idstaeve <> 2 -- Cancelado
         AND NOT EXISTS(SELECT 1
                          FROM crapsie cs
                         WHERE cs.nrsdipro = ca.nrseqdig
                           AND cs.idsitsol IN (1,2) -- 1 - Pendente 2 -Aprovado
             )
       ORDER BY ce.nmevento
               ,ca.dtinieve
               ,ca.dshroeve;

    -- ASSEMBLEAR
    CURSOR cr_crapedp_ass(pr_idevento crapeap.idevento%TYPE
                         ,pr_cdcooper crapeap.cdcooper%TYPE
                         ,pr_cdagenci crapeap.cdagenci%TYPE
                         ,pr_dtanoage crapeap.dtanoage%TYPE) IS

      SELECT ca.nrseqdig AS cdevento
            ,ce.nmevento||' - '||ca.dtinieve||' - '||ca.dshroeve AS nmevento
        FROM crapedp ce
            ,crapadp ca 
       WHERE ce.idevento = pr_idevento
         AND ce.dtanoage = pr_dtanoage -- Parâmetro
         AND ce.cdcooper = pr_cdcooper -- Parâmetro
         AND ce.flgativo = 1
         AND ce.tpevento NOT IN(10,11)  -- Não buscar EAD
         AND ce.tpevento in(8,13,14,15,16) -- Eventos do tipo Pré-Assembleia
         AND ca.idevento = ce.idevento
         AND ca.cdcooper = ce.cdcooper
         AND ca.dtanoage = ce.dtanoage
         AND ca.cdevento = ce.cdevento
         AND (ca.cdagenci = pr_cdagenci OR pr_cdagenci = 0) -- Parâmetro
         AND nvl(ca.nrseqint,0) = 0
         AND ca.idstaeve not in (2,4) -- 2 - Cancelado e 4 - Encerrado
         AND NOT EXISTS(SELECT 1
                          FROM crapsie cs
                         WHERE cs.nrsdiass = ca.nrseqdig
                           AND cs.idsitsol IN (1,2) -- 1 - Pendente 2 -Aprovado
                  )
      ORDER by ce.nmevento
              ,ca.dtinieve
              ,ca.dshroeve;

      rw_crapedp cr_crapedp_pro%ROWTYPE;

      -- Variaveis Locais
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic crapcri.dscritic%TYPE := '';
      vr_contador INTEGER := 0;

    BEGIN
    
      IF pr_idevento = 1 THEN
        FOR rw_crapedp IN cr_crapedp_pro(pr_idevento => pr_idevento
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_dtanoage => pr_dtanoage) LOOP
                          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf'  , pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp.cdevento, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf'  , pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp.nmevento, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;
                        
        END LOOP;
      ELSIF pr_idevento = 2 THEN
        FOR rw_crapedp IN cr_crapedp_ass(pr_idevento => pr_idevento
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_dtanoage => pr_dtanoage) LOOP
                          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf'  , pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp.cdevento, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf'  , pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp.nmevento, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;
                        
        END LOOP;
      END IF;

    EXCEPTION
      
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PC_CARREGA_EVENTOS: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END PC_CARREGA_EVENTOS;

END WPGD0129;
/
