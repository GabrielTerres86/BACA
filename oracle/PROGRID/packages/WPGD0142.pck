CREATE OR REPLACE PACKAGE PROGRID.WPGD0142 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0142
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : 07/06/2017                   Ultima atualizacao:  
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Relatório de Fechamento de Inscrições
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------
  
  /* Procedure para listar os eventos para a tela de ficha de presença */
  PROCEDURE pc_lista_evento_wpgd0142(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                    ,pr_dtanoage IN crapeap.dtanoage%TYPE --> Ano do filtro
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro

  /* Rotina de procedimentos geral da tela de ficha de presença */
  PROCEDURE pc_wpgd0142(pr_dtanoage IN crapeap.dtanoage%TYPE --> Ano da Agenda
                       ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                       ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo da Agencia (PA)    
                       ,pr_cdevento IN crapeap.dtanoage%TYPE --> Código do Evento
                       ,pr_qtdlinha IN INTEGER               --> Quantidade de Linhas
                       ,pr_nmresfic IN crapfpa.nmresfic%TYPE --> Nome do Responsável pela Ficha
                       ,pr_nrdddres IN crapfpa.nrdddres%TYPE --> Número de DDD
                       ,pr_nrtelres IN crapfpa.nrtelres%TYPE --> Número de Telefone
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
END WPGD0142;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0142 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0140
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : 25/05/2017                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada 
  -- Objetivo  :
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  /* Procedure para listar os eventos para a tela de ficha de presença */
  PROCEDURE pc_lista_evento_wpgd0142(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                    ,pr_dtanoage IN crapeap.dtanoage%TYPE --> Ano do filtro
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- .........................................................................
    --
    --  Programa : pc_lista_evento_wpgd0142
    --  Sistema  : Rotinas para listar os eventos para a tela de ficha de inscricoes
    --  Sigla    : GENE
    --  Autor    : Jean Michel
    --  Data     : 06/06/2017                   Ultima Atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de eventos do sistema.
    --
    --
    -- .............................................................................
  BEGIN
    DECLARE

      -- Cursor sobre os eventos de inscricoes
      CURSOR cr_crapedp(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtanoage IN crapadp.dtanoage%TYPE) IS
        SELECT DISTINCT 
               adp.nrseqdig AS cdevento
              ,edp.nmevento || ' - ' || adp.dtinieve || ' - ' || TRIM(adp.dshroeve) AS nmevento
          FROM crapedp edp,
               crapadp adp
         WHERE edp.cdcooper = adp.cdcooper
           AND edp.dtanoage = adp.dtanoage 
           AND edp.cdevento = adp.cdevento
           AND edp.cdcooper = pr_cdcooper
           AND adp.cdagenci = 0
           AND adp.dtanoage = pr_dtanoage
           AND adp.idevento = 2
           AND adp.idstaeve NOT IN (2,4)
           AND edp.cdevento <> 0
           AND TRIM(edp.nmevento) IS NOT NULL
           AND edp.tpevento IN (7,12)   
         ORDER BY nmevento;
        
      rw_crapedp cr_crapedp%ROWTYPE;
      
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
          
    BEGIN          
     
      FOR rw_crapedp IN cr_crapedp(pr_cdcooper,pr_dtanoage) LOOP                                   
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp.cdevento, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp.nmevento, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;                              
      END LOOP;      
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0; 
        pr_des_erro := 'Erro geral em WPGD0142.pc_lista_evento_wpgd0142: ' || SQLERRM;
        pr_dscritic := 'Erro geral em WPGD0142.pc_lista_evento_wpgd0142: ' || SQLERRM;
    END;

  END pc_lista_evento_wpgd0142;

  /* Rotina de procedimentos geral da tela de ficha de presença */
  PROCEDURE pc_wpgd0142(pr_dtanoage IN crapeap.dtanoage%TYPE --> Ano da Agenda
                       ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                       ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo da Agencia (PA)    
                       ,pr_cdevento IN crapeap.dtanoage%TYPE --> Código do Evento
                       ,pr_qtdlinha IN INTEGER               --> Quantidade de Linhas
                       ,pr_nmresfic IN crapfpa.nmresfic%TYPE --> Nome do Responsável pela Ficha
                       ,pr_nrdddres IN crapfpa.nrdddres%TYPE --> Número de DDD
                       ,pr_nrtelres IN crapfpa.nrtelres%TYPE --> Número de Telefone
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- .........................................................................
    --
    --  Programa : pc_wpgd0142
    --  Sistema  : Rotina de procedimentos geral da tela de ficha de presença
    --  Sigla    : GENE
    --  Autor    : Jean Michel
    --  Data     : 08/06/2017                   Ultima Atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Grava informações de ficha de presença e retorna informações para impressão
    --
    --
    -- .............................................................................
  BEGIN
    DECLARE
       
      CURSOR cr_crapadp(pr_nrseqdig crapadp.nrseqdig%TYPE) IS
        SELECT edp.nmevento
              ,DECODE(edp.tpevento,7,'Assembleia Geral Ordinária',12,'Assembleia Geral Extraordinária','SEM TIPO') AS tpevento
              ,adp.dtinieve
              ,adp.dshroeve
              ,ldp.dslocali
              ,ldp.dsrefloc
              ,ldp.dsendloc
          FROM crapadp adp
              ,crapedp edp
              ,crapldp ldp
         WHERE edp.cdcooper = adp.cdcooper
           AND edp.dtanoage = adp.dtanoage 
           AND edp.cdevento = adp.cdevento
           AND adp.nrseqdig = pr_nrseqdig
           AND ldp.nrseqdig(+) = adp.cdlocali;

        rw_crapadp cr_crapadp%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela VARCHAR2(100);
      vr_nmdeacao VARCHAR2(100);
      vr_cddopcao VARCHAR2(100);
      vr_idcokses VARCHAR2(100);
      vr_idsistem crapadp.idevento%TYPE;

      -- Variaveis internas
      vr_contador INTEGER := 1;
      vr_qtdlinha INTEGER := 25;
      vr_nrficpre crapfpa.nrficpre%TYPE := 0;
      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);

    BEGIN          

      prgd0001.pc_extrai_dados_prgd(pr_xml     => pr_retxml
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
      
      LOOP

        IF vr_contador > ROUND(CEIL(pr_qtdlinha/vr_qtdlinha)) THEN
          EXIT;
        END IF;
        
        -- Insere registro de ficha cadastral
        BEGIN
          vr_nrficpre := fn_sequence(pr_nmtabela => 'CRAPFPA', pr_nmdcampo => 'NRFICPRE',pr_dsdchave => pr_cdevento);
          INSERT INTO crapfpa(nrseqdig, nrficpre, cdcopfic, cdagefic, nmresfic, nrdddres, nrtelres, dtgerfic, cdcopger, cdopeger)
            VALUES(pr_cdevento,vr_nrficpre,pr_cdcooper,pr_cdagenci,pr_nmresfic,pr_nrdddres,pr_nrtelres,SYSDATE,vr_cdcooper,vr_cdoperad);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro de Ficha de Presença. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        IF vr_contador = 1 THEN
          OPEN cr_crapadp(pr_nrseqdig => pr_cdevento);

          FETCH cr_crapadp INTO rw_crapadp;

          IF cr_crapadp%NOTFOUND THEN
            CLOSE cr_crapadp;
            vr_dscritic := 'Registro de evento inexistente';
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_crapadp;
          END IF;
          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nrficpre', pr_tag_cont => vr_nrficpre        , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapadp.nmevento, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'tpevento', pr_tag_cont => rw_crapadp.tpevento, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dtevento', pr_tag_cont => rw_crapadp.dtinieve, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'hrevento', pr_tag_cont => rw_crapadp.dshroeve, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dslocali', pr_tag_cont => rw_crapadp.dslocali, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dsrefloc', pr_tag_cont => rw_crapadp.dsrefloc, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dsendloc', pr_tag_cont => rw_crapadp.dsendloc, pr_des_erro => vr_dscritic);

        END IF;

        vr_contador := vr_contador + 1;

      END LOOP;

      COMMIT;

    EXCEPTION

      WHEN vr_exc_saida THEN
        pr_cdcritic := 0; 
        pr_des_erro := vr_dscritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := 0; 
        pr_des_erro := 'Erro geral em WPGD0140.pc_wpgd0142: ' || SQLERRM;
        pr_dscritic := 'Erro geral em WPGD0140.pc_wpgd0142: ' || SQLERRM;
        ROLLBACK;
    END;

  END pc_wpgd0142;

END WPGD0142;
/
