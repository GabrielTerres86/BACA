CREATE OR REPLACE PACKAGE PROGRID.WPGD0132 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0132                     
  --  Sistema  : Rotinas para tela de Cadastro de ATA's(WPGD0132)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Maio/2017.                   Ultima Atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Consulta de ATA's(WPGD0132)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de select da tela de cosnulta de ATA's (WPGD0132)
  PROCEDURE pc_wpgd0132(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);        --> Descricao do Erro
  
END WPGD0132;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0132 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0132
  --  Sistema  : Rotinas para tela de Cadastro de Contatos do Progrid(WPGD0132)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Contatos do Progrid(WPGD0132)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral de select da tela de consulta de ATA's (WPGD0132)
  PROCEDURE pc_WPGD0132(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS      --> Descricao do Erro

      -- CURSORES             
      -- Consulta de Ata's
      CURSOR cr_crapaea IS
        SELECT aea.nrseqaea       AS nrseqaea
              ,aea.nmataeve AS nmataeve
              ,aea.nmarquiv       AS nmarquiv
         FROM crapaea aea
        WHERE aea.idsitaea = 1 -- ATIVOS
      ORDER BY UPPER(nmataeve);
   
      rw_crapaea cr_crapaea%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela VARCHAR2(100);
      vr_nmdeacao VARCHAR2(100);
      vr_cddopcao VARCHAR2(100);
      vr_idcokses VARCHAR2(100);
      vr_idsistem INTEGER;

      -- Variáveis locais
      vr_contador PLS_INTEGER := 0;
      vr_totregis PLS_INTEGER := 0;
      vr_nriniseq PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
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
          
        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
         pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

           FOR rw_crapaea IN cr_crapaea LOOP
      
             gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
             gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqaea', pr_tag_cont => rw_crapaea.nrseqaea, pr_des_erro => vr_dscritic);
             gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmataeve', pr_tag_cont => rw_crapaea.nmataeve, pr_des_erro => vr_dscritic);
             gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmarquiv', pr_tag_cont => rw_crapaea.nmarquiv, pr_des_erro => vr_dscritic);
             vr_contador := vr_contador + 1;

           END LOOP;

      END CASE;
  
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        pr_des_erro := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PC_WPGD0132: ' || SQLERRM;
        pr_des_erro := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_WPGD0132;

END WPGD0132;
/
