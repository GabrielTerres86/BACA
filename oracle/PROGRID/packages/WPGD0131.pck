CREATE OR REPLACE PACKAGE PROGRID.WPGD0131 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0131                     
  --  Sistema  : Rotinas para tela de Cadastro de ATA's(WPGD0131)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Maio/2017.                   Ultima Atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de ATA's(WPGD0131)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela cadastro de ATA's (WPGD0131)
  PROCEDURE pc_wpgd0131(pr_nrseqaea IN crapaea.nrseqaea%TYPE --> Sequencial de ATA
                       ,pr_nmataeve IN crapaea.nmataeve%TYPE --> Nome da ATA
                       ,pr_dsorgarq IN crapaea.dsorgarq%TYPE --> Origem do Arquivo
                       ,pr_idsitaea IN crapaea.idsitaea%TYPE --> Situação da ATA
                       ,pr_dssitaea IN crapaea.nmataeve%TYPE --> Descrição Situação da ATA
                       ,pr_nmarquiv IN crapaea.nmarquiv%TYPE --> Nome do Arquivo
                       ,pr_nriniseq IN crapqmd.idevento%TYPE --> Registro inicial para pesquisa
                       ,pr_qtregist IN crapqmd.idevento%TYPE --> Quantidade de registros por pesquisa
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
  
END WPGD0131;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0131 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0131
  --  Sistema  : Rotinas para tela de Cadastro de Contatos do Progrid(WPGD0131)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Contatos do Progrid(WPGD0131)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral de insert, update, select e delete da tela cadastro de ATA's (WPGD0131)
  PROCEDURE pc_wpgd0131(pr_nrseqaea IN crapaea.nrseqaea%TYPE --> Sequencial de ATA
                       ,pr_nmataeve IN crapaea.nmataeve%TYPE --> Nome da ATA
                       ,pr_dsorgarq IN crapaea.dsorgarq%TYPE --> Origem do Arquivo
                       ,pr_idsitaea IN crapaea.idsitaea%TYPE --> Situação da ATA
                       ,pr_dssitaea IN crapaea.nmataeve%TYPE --> Descrição Situação da ATA
                       ,pr_nmarquiv IN crapaea.nmarquiv%TYPE --> Nome do Arquivo
                       ,pr_nriniseq IN crapqmd.idevento%TYPE --> Registro inicial para pesquisa
                       ,pr_qtregist IN crapqmd.idevento%TYPE --> Quantidade de registros por pesquisa
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro

      -- CURSORES             
      -- Consulta de Ata's
      CURSOR cr_crapaea(pr_nmataeve IN crapaea.nmataeve%TYPE
                       ,pr_dssitaea IN crapaea.nmataeve%TYPE
                       ,pr_nmarquiv IN crapaea.nmarquiv%TYPE) IS
        SELECT aea.nrseqaea                                  AS nrseqaea
              ,aea.nmataeve                                  AS nmataeve
              ,aea.dsorgarq                                  AS dsorgarq
              ,aea.idsitaea                                  AS idsitaea
              ,DECODE(aea.idsitaea,0,'INATIVO',1,'ATIVO','') AS dssitaea
              ,aea.nmarquiv                                  AS nmarquiv
              ,aea.cdcopope                                  AS cdcopope 
              ,aea.cdoperad                                  AS cdoperad
              ,aea.cdprogra                                  AS cdprogra
              ,aea.dtatuali                                  AS dtatuali
              ,ROW_NUMBER() OVER(ORDER BY aea.nmataeve) AS nrdseque
         FROM crapaea aea
        WHERE (UPPER(aea.nmataeve) LIKE UPPER('%' || pr_nmataeve || '%') OR pr_nmataeve IS NULL)
          AND (DECODE(aea.idsitaea,0,'INATIVO',1,'ATIVO',NULL) LIKE UPPER('%' || pr_dssitaea || '%') OR pr_dssitaea IS NULL)
          AND (UPPER(aea.nmarquiv) LIKE UPPER('%' || pr_nmarquiv || '%') OR pr_nmarquiv IS NULL)
      ORDER BY aea.nmataeve;
   
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

        WHEN 'A' THEN -- Alteracao
          IF NVL(pr_nrseqaea,0) = 0 THEN -- Insere dados
            BEGIN
              INSERT INTO crapaea(
                nmataeve
               ,dsorgarq
               ,idsitaea
               ,nmarquiv
               ,cdcopope
               ,cdoperad
               ,cdprogra
               ,dtatuali)              
                VALUES(
                  pr_nmataeve                
                 ,pr_dsorgarq
                 ,pr_idsitaea
                 ,pr_nmarquiv
                 ,vr_cdcooper
                 ,vr_cdoperad
                 ,vr_nmdatela
                 ,SYSDATE);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir registro(CRAPAEA). Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          ELSE                            -- Atualiza dados
            BEGIN
              UPDATE crapaea
               SET crapaea.nmataeve = pr_nmataeve
                  ,crapaea.idsitaea = pr_idsitaea
                  ,crapaea.cdcopope = vr_cdcooper
                  ,crapaea.cdoperad = vr_cdoperad
                  ,crapaea.cdprogra = vr_nmdatela
                  ,crapaea.dtatuali = SYSDATE
              WHERE crapaea.nrseqaea = pr_nrseqaea;

              IF SQL%ROWCOUNT = 0 THEN
                BEGIN
                  INSERT INTO crapaea(
                    nmataeve
                   ,dsorgarq
                   ,idsitaea
                   ,nmarquiv
                   ,cdcopope
                   ,cdoperad
                   ,cdprogra
                   ,dtatuali)              
                    VALUES(
                      pr_nmataeve                
                     ,pr_dsorgarq
                     ,pr_idsitaea
                     ,pr_nmarquiv
                     ,vr_cdcooper
                     ,vr_cdoperad
                     ,vr_nmdatela
                     ,SYSDATE);
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir registro(CRAPAEA). Erro: ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar registro(CRAPAEA). Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;
          
        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

          FOR rw_crapaea IN cr_crapaea(pr_nmataeve => pr_nmataeve
                                      ,pr_dssitaea => pr_dssitaea
                                      ,pr_nmarquiv => pr_nmarquiv) LOOP
                     
            IF ((pr_nriniseq <= rw_crapaea.nrdseque) AND (rw_crapaea.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                   
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqaea', pr_tag_cont => rw_crapaea.nrseqaea, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmataeve', pr_tag_cont => rw_crapaea.nmataeve, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsorgarq', pr_tag_cont => rw_crapaea.dsorgarq, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsorigem', pr_tag_cont => REPLACE(rw_crapaea.dsorgarq,'\','\\'), pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsdirect', pr_tag_cont => REPLACE(rw_crapaea.dsorgarq,'\','\\'), pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idsitaea', pr_tag_cont => rw_crapaea.idsitaea, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dssitaea', pr_tag_cont => rw_crapaea.dssitaea, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmarquiv', pr_tag_cont => rw_crapaea.nmarquiv, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcopope', pr_tag_cont => rw_crapaea.cdcopope, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_crapaea.cdoperad, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra', pr_tag_cont => rw_crapaea.cdprogra, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali', pr_tag_cont => rw_crapaea.dtatuali, pr_des_erro => vr_dscritic);
              vr_contador := vr_contador + 1;
            END IF;

            vr_totregis := vr_totregis +1;

          END LOOP;

          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

      WHEN 'E' THEN -- Exclusao
        BEGIN
          DELETE
            FROM crapaea
           WHERE crapaea.nrseqaea = pr_nrseqaea;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPAEA). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
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
        pr_dscritic := 'Erro geral em PC_WPGD0131: ' || SQLERRM;
        pr_des_erro := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_wpgd0131;

END WPGD0131;
/
