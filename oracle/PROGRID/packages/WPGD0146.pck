CREATE OR REPLACE PACKAGE PROGRID.WPGD0146 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0147                     
  --  Sistema  : Rotinas para tela de Planejamento CooperaCriança do Progrid(WPGD0146)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Agosto/2018.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de planejamento CooperaCriança do Progrid(WPGD0146)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0146
  PROCEDURE PC_WPGD0146(pr_cdcooper IN crappcc.cdcooper%TYPE       --> Código da Cooperativa
                       ,pr_nmrescop IN crapcop.nmrescop%TYPE       --> Nome da Cooperativa
                       ,pr_dtanoage IN crappcc.dtanoage%TYPE       --> Ano da Agenda
                       ,pr_dtiniexe IN crappcc.dtiniexe%TYPE       --> Data de Início
                       ,pr_vlorcame IN crappcc.vlorcame%TYPE       --> Valor do Orcamento
                       ,pr_dsobserv IN crappcc.dsobserv%TYPE       --> Observações
                       ,pr_cdagenci IN VARCHAR2                    --> Array de PAs
                       ,pr_nriniseq IN INTEGER                     --> Sequência Inicial da Consulta    
                       ,pr_qtregist IN INTEGER                     --> Quantidade de Registros por Consulta
                       ,pr_xmllog   IN VARCHAR2                    --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2                   --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType          --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2                   --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);                 --> Descricao do Erro
  
END WPGD0146;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0146 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0146
  --  Sistema  : Rotinas para tela de Cadastro de Planejamento CooperaCriança do Progrid(WPGD0146)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Agosto/2017.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Planejamento do Progrid(WPGD0146)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Tipo de tabela de memoria para turmas de sugestões
  TYPE typ_reg_cdagenci IS
    RECORD (cdagenci crapage.cdagenci%TYPE
           ,nmresage crapage.nmresage%TYPE);

  TYPE typ_tab_cdagenci IS
    TABLE OF typ_reg_cdagenci
    INDEX BY VARCHAR2(25);

  -- Rotina geral de insert, update, select e delete da tela WPGD0147
  PROCEDURE pc_wpgd0146(pr_cdcooper IN crappcc.cdcooper%TYPE       --> Código da Cooperativa
                       ,pr_nmrescop IN crapcop.nmrescop%TYPE       --> Nome da Cooperativa
                       ,pr_dtanoage IN crappcc.dtanoage%TYPE       --> Ano da Agenda
                       ,pr_dtiniexe IN crappcc.dtiniexe%TYPE       --> Data de Início
                       ,pr_vlorcame IN crappcc.vlorcame%TYPE       --> Valor do Orcamento
                       ,pr_dsobserv IN crappcc.dsobserv%TYPE       --> Observações
                       ,pr_cdagenci IN VARCHAR2                    --> Array de PAs
                       ,pr_nriniseq IN INTEGER                     --> Sequência Inicial da Consulta    
                       ,pr_qtregist IN INTEGER                     --> Quantidade de Registros por Consulta
                       ,pr_xmllog   IN VARCHAR2                    --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2                   --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType          --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2                   --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS               --> Descricao do Erro

      CURSOR cr_crappcc(pr_cdcooper crappcc.cdcooper%TYPE
                       ,pr_dtanoage crappcc.dtanoage%TYPE) IS

        SELECT pcc.dtanoage
              ,pcc.cdcooper
              ,cop.nmrescop
              ,pcc.dtiniexe
              ,pcc.vlorcame
              ,pcc.dsobserv
              ,pcc.progress_recid AS idprogre
              ,ROW_NUMBER() OVER(ORDER BY 1 DESC, 3 ASC) nrdseque
          FROM crappcc pcc
              ,crapcop cop 
         WHERE pcc.cdcooper = cop.cdcooper
           AND (pcc.dtanoage = pr_dtanoage OR pr_dtanoage IS NULL)
           AND (pcc.cdcooper = pr_cdcooper OR pr_cdcooper IS NULL)
           AND (UPPER(cop.nmrescop) LIKE '%' || UPPER(pr_nmrescop) || '%' OR pr_nmrescop IS NULL)
           ORDER BY 1 DESC, 3 ASC;

      rw_crappcc cr_crappcc%ROWTYPE;
    
      CURSOR cr_crappcp(pr_dtanoage crapdfs.dtanoage%TYPE
                       ,pr_cdcooper crapdfs.cdcooper%TYPE) IS

        SELECT pcp.cdagenci
          FROM crappcp pcp
         WHERE pcp.dtanoage = pr_dtanoage
           AND pcp.cdcooper = pr_cdcooper;

      rw_crappcp cr_crappcp%ROWTYPE;

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
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis locais
      vr_totregis INTEGER := 0;
      vr_contador INTEGER := 0;

      -- Registro de PAs
      vr_cdagenci GENE0002.typ_split;
      vr_dsagenci VARCHAR2(4000) := '';

      -- Registro de PAs
      vr_tab_cdagenci typ_tab_cdagenci;
      ind_registro VARCHAR(25) := '';

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

      -- Validações
      IF vr_cddopcao <> 'C' THEN
        IF pr_dtanoage IS NULL OR pr_dtanoage = 0 THEN --> Ano da Agenda
          vr_dscritic := 'Informe a data de agenda.';
          RAISE vr_exc_saida;
        END IF;

        IF pr_cdcooper IS NULL OR pr_cdcooper = 0 THEN --> Código da Cooperativa
          vr_dscritic := 'Informe a Cooperativa.';
          RAISE vr_exc_saida;
        END IF;

        IF vr_cddopcao <> 'E' THEN
          IF TO_DATE(pr_dtiniexe) < TRUNC(SYSDATE) OR TRUNC(TO_DATE(pr_dtiniexe,'dd/mm/RRRR'),'RRRR') <> to_date('01/01/' || pr_dtanoage) OR TRIM(pr_dtiniexe) IS NULL THEN --> Data de Início
            vr_dscritic := 'Informe a Data de Início Válida.';
            RAISE vr_exc_saida;
          END IF;
          
          IF TRIM(pr_vlorcame) IS NULL OR pr_vlorcame = 0 THEN
            vr_dscritic := 'Informe o Valor do Orçamento.';
            RAISE vr_exc_saida;
          END IF;

          IF LENGTH(TRIM(pr_dsobserv)) > 1500 OR TRIM(pr_dsobserv) IS NULL THEN
            vr_dscritic := 'Informe uma Observação até 1500 caracteres.';
            RAISE vr_exc_saida;
          END IF;
        END IF;
      END IF;
      -- Fim Validações

      -- PAs
      vr_cdagenci := gene0002.fn_quebra_string(pr_string => pr_cdagenci,pr_delimit => ',');

      -- Dados de PAs
      IF NVL(vr_cdagenci.count(),0) > 0 THEN

        FOR ind_registro IN vr_cdagenci.FIRST..vr_cdagenci.LAST LOOP

          vr_tab_cdagenci(ind_registro).cdagenci := vr_cdagenci(ind_registro);

        END LOOP;
      END IF;

      -- Verifica o tipo de acao que sera executada
      CASE vr_cddopcao

        WHEN 'A' THEN -- Alteracao
          -- Atualização da Sondagem Principal
          BEGIN
            UPDATE crappcc
               SET crappcc.vlorcame = pr_vlorcame
                  ,crappcc.dtiniexe = pr_dtiniexe
                  ,crappcc.dsobserv = pr_dsobserv
                  ,crappcc.cdoperad = vr_cdoperad
                  ,crappcc.cdprogra = vr_nmdatela
                  ,crappcc.dtatuali = SYSDATE
             WHERE crappcc.dtanoage = pr_dtanoage
               AND crappcc.cdcooper = pr_cdcooper;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar registro(CRAPPCC). Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;                   
          -- Fim Atualização da Sondagem Principal
          
        WHEN 'I' THEN
          -- Inclusão da Sondagem Principal
          BEGIN
            INSERT INTO crappcc(dtanoage, cdcooper, dtiniexe, vlorcame, dsobserv, cdoperad, cdprogra, dtatuali)
            VALUES(pr_dtanoage, pr_cdcooper, TO_DATE(pr_dtiniexe,'dd/mm/RRRR'), pr_vlorcame, pr_dsobserv, vr_cdoperad, vr_nmdatela, SYSDATE);
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              vr_dscritic := 'Registro já inserido.';
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro(CRAPPCC). Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;  
        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

          -- Informações referente ao furmulário de sondagem
          FOR rw_crappcc IN cr_crappcc(pr_dtanoage => pr_dtanoage
                                      ,pr_cdcooper => pr_cdcooper) LOOP
                     
            IF ((pr_nriniseq <= rw_crappcc.nrdseque) AND (rw_crappcc.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                  
              -- Informações referente a PAs
              vr_dsagenci := '';
              FOR rw_crappcp IN cr_crappcp(pr_dtanoage => rw_crappcc.dtanoage
                                          ,pr_cdcooper => rw_crappcc.cdcooper) LOOP
                IF TRIM(vr_dsagenci) IS NULL THEN
                  vr_dsagenci := rw_crappcp.cdagenci;
                ELSE
                  vr_dsagenci := vr_dsagenci || '+' || rw_crappcp.cdagenci;
                END IF;
              END LOOP;


              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtanoage', pr_tag_cont => rw_crappcc.dtanoage, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooperPesquisa', pr_tag_cont => rw_crappcc.cdcooper, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crappcc.nmrescop, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsagenci', pr_tag_cont => vr_dsagenci, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtiniexe', pr_tag_cont => rw_crappcc.dtiniexe, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlorcame', pr_tag_cont => replace(replace(replace(TO_CHAR(rw_crappcc.vlorcame,'fm999G990D00'),'.','#'),',','.'),'#',','), pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsobserv', pr_tag_cont => rw_crappcc.dsobserv, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idprogre', pr_tag_cont => rw_crappcc.idprogre, pr_des_erro => vr_dscritic);

              vr_contador := vr_contador + 1;
            END IF;

            vr_totregis := vr_totregis +1;

          END LOOP;

          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

      WHEN 'E' THEN -- Exclusao
        
        BEGIN
          DELETE 
            FROM crappcp
           WHERE crappcp.dtanoage = pr_dtanoage
             AND crappcp.cdcooper = pr_cdcooper;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPPCP). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        BEGIN
          DELETE 
            FROM crappcc
           WHERE crappcc.dtanoage = pr_dtanoage
             AND crappcc.cdcooper = pr_cdcooper;
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir registro(CRAPPCC). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

      END CASE;
  
      IF UPPER(vr_cddopcao) = 'A' OR UPPER(vr_cddopcao) = 'I' THEN
        -- Inclusão de PAs
        -- Primeiramente deleta todos os registros existentes referentes a PAs

        BEGIN
          DELETE crappcp WHERE crappcp.dtanoage = pr_dtanoage
                           AND crappcp.cdcooper = pr_cdcooper;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao deletar registros de PAs(CRAPPCP). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- PAs
        ind_registro := vr_tab_cdagenci.FIRST;
        WHILE ind_registro IS NOT NULL LOOP
          BEGIN
            INSERT INTO crappcp(dtanoage, cdcooper, cdagenci, cdoperad, cdprogra, dtatuali)
              VALUES(pr_dtanoage, pr_cdcooper, vr_tab_cdagenci(ind_registro).cdagenci, vr_cdoperad, vr_nmdatela, SYSDATE);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registros de PAs(CRAPPCP). Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
          ind_registro := vr_tab_cdagenci.next(ind_registro);
        END LOOP;
        -- Fim Inclusão de PAs
       
      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PC_WPGD0146: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

  END pc_wpgd0146;

END WPGD0146;
/
