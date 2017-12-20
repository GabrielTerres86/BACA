CREATE OR REPLACE PACKAGE PROGRID.WPGD0147 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0147                     
  --  Sistema  : Rotinas para tela de Cadastro de Sondagem CooperaCriança do Progrid(WPGD0147)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Agosto/2018.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Sondagem CooperaCriança do Progrid(WPGD0147)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0147
  PROCEDURE pc_wpgd0147(pr_dtanoage IN crapfsc.dtanoage%TYPE       --> Ano da Agenda
                       ,pr_cdcooper IN crapfsc.cdcooper%TYPE       --> Código da Cooperativa
                       ,pr_nmrescop IN crapcop.nmrescop%TYPE       --> Nome da Cooperativa
                       ,pr_cdagenci IN crapfsc.cdagenci%TYPE       --> Código do PA
                       ,pr_nmresage IN crapage.nmresage%TYPE       --> Nome do PA
                       ,pr_nminstit IN crapfsc.nminstit%TYPE       --> Nome da Instituição/Escola
                       ,pr_dsendins IN crapfsc.dsendins%TYPE       --> Endereço Completo
                       ,pr_nmpescon IN crapfsc.nmpescon%TYPE       --> Pessoa de Contato da Instituição/Escola
                       ,pr_nrdddtel IN crapfsc.nrdddtel%TYPE       --> DDD
                       ,pr_nrtelcon IN crapfsc.nrtelcon%TYPE       --> Telefone
                       ,pr_dsemlcon IN crapfsc.dsemlcon%TYPE       --> Email
                       ,pr_nmresson IN crapfsc.nmresson%TYPE       --> Responsável pelo Preenchimento da Sondagem
                       ,pr_datasuge IN VARCHAR2                    --> Datas de Sugestão do Evento
                       ,pr_turmasug IN VARCHAR2                    --> Turmas do Evento
                       ,pr_flgpalco IN crapfsc.flgpalco%TYPE       --> Palco
                       ,pr_dsmpalco IN crapfsc.dsmpalco%TYPE       --> Medida do Palco
                       ,pr_flgearef IN crapfsc.flgearef%TYPE       --> Espaço Amplo no Refeitório
                       ,pr_flgposqu IN crapfsc.flgposqu%TYPE       --> Quadra
                       ,pr_flgqucob IN crapfsc.flgqucob%TYPE       --> Quadra Coberta
                       ,pr_flgposge IN crapfsc.flgposge%TYPE       --> Ginásio de Esportes
                       ,pr_flgpospp IN crapfsc.flgpospp%TYPE       --> Pátio com Pedra Brita
                       ,pr_flgposmi IN crapfsc.flgposmi%TYPE       --> Microfone
                       ,pr_flgposcs IN crapfsc.flgposcs%TYPE       --> Caixa de Som
                       ,pr_dsobslre IN crapfsc.dsobslre%TYPE       --> Observações
                       ,pr_flgpcdia IN crapfsc.flgpcdia%TYPE       --> Diabetes
                       ,pr_qtcridia IN crapfsc.qtcridia%TYPE       --> Diabetes, Quantas?
                       ,pr_flgpcila IN crapfsc.flgpcila%TYPE       --> Intolerância a Lactose
                       ,pr_qtcriila IN crapfsc.qtcriila%TYPE       --> Intolerância a Lactose, Quantas?
                       ,pr_flgpcigl IN crapfsc.flgpcigl%TYPE       --> Intolerância a Glúten
                       ,pr_qtcriigl IN crapfsc.qtcriigl%TYPE       --> Intolerância a Glúten, Quantas?
                       ,pr_dsresali IN crapfsc.dsresali%TYPE       --> Outras Restrições Alimentares?
                       ,pr_flgpcdvi IN crapfsc.flgpcdvi%TYPE       --> Deficiência Visual?
                       ,pr_flgtspro IN crapfsc.flgtspro%TYPE       --> Tem 2º Professor?
                       ,pr_flgnmbra IN crapfsc.flgnmbra%TYPE       --> Necessita de material adaptado em Braile?
                       ,pr_flgpcdau IN crapfsc.flgpcdau%TYPE       --> Deficiência Auditiva?
                       ,pr_flgpilib IN crapfsc.flgpilib%TYPE       --> Possui Interprete de LIBRAS?
                       ,pr_flgpcdfi IN crapfsc.flgpcdfi%TYPE       --> Deficiência Física?
                       ,pr_flgucrod IN crapfsc.flgucrod%TYPE       --> Utiliza cadeira de rodas?
                       ,pr_dsnecace IN crapfsc.dsnecace%TYPE       --> Qual a necessidade de acessibilidade?
                       ,pr_dsoutdfi IN crapfsc.dsoutdfi%TYPE       --> Outras
                       ,pr_dsobsger IN crapfsc.dsobsger%TYPE       --> Observação Gerais
                       ,pr_idprogre IN VARCHAR2                    --> ROWID
                       ,pr_nriniseq IN INTEGER                     --> Sequência Inicial da Consulta    
                       ,pr_qtregist IN INTEGER                     --> Quantidade de Registros por Consulta
                       ,pr_xmllog   IN VARCHAR2                    --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2                   --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType          --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2                   --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);                 --> Descricao do Erro
  
END WPGD0147;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0147 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0147
  --  Sistema  : Rotinas para tela de Cadastro de Sondagem CooperaCriança do Progrid(WPGD0147)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Agosto/2017.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Sondagem do Progrid(WPGD0147)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Tipo de tabela de memoria para turmas de sugestões
  TYPE typ_reg_datas IS
    RECORD (dtsugeve crapdfs.dtsugeve%TYPE
           ,hrinieve crapdfs.hrinieve%TYPE
           ,hrfimeve crapdfs.hrfimeve%TYPE
           ,hriniint crapdfs.hriniint%TYPE
           ,hrfimint crapdfs.hrfimint%TYPE);

  TYPE typ_tab_datas IS
    TABLE OF typ_reg_datas
    INDEX BY VARCHAR2(25);

  -- Tipo de tabela de memoria para turmas de sugestões
  TYPE typ_reg_turmas IS
    RECORD (idserief craptfs.idserief%TYPE
           ,qtcrimat craptfs.qtcrimat%TYPE
           ,qtpromat craptfs.qtpromat%TYPE
           ,qtcrives craptfs.qtcrives%TYPE
           ,qtproves craptfs.qtproves%TYPE
           ,qtcrinot craptfs.qtcrinot%TYPE
           ,qtpronot craptfs.qtpronot%TYPE);

  TYPE typ_tab_turmas IS
    TABLE OF typ_reg_turmas
    INDEX BY VARCHAR2(25);

  -- Rotina geral de insert, update, select e delete da tela WPGD0147
  PROCEDURE pc_wpgd0147(pr_dtanoage IN crapfsc.dtanoage%TYPE       --> Ano da Agenda
                       ,pr_cdcooper IN crapfsc.cdcooper%TYPE       --> Código da Cooperativa
                       ,pr_nmrescop IN crapcop.nmrescop%TYPE       --> Nome da Cooperativa
                       ,pr_cdagenci IN crapfsc.cdagenci%TYPE       --> Código do PA
                       ,pr_nmresage IN crapage.nmresage%TYPE       --> Nome do PA
                       ,pr_nminstit IN crapfsc.nminstit%TYPE       --> Nome da Instituição/Escola
                       ,pr_dsendins IN crapfsc.dsendins%TYPE       --> Endereço Completo
                       ,pr_nmpescon IN crapfsc.nmpescon%TYPE       --> Pessoa de Contato da Instituição/Escola
                       ,pr_nrdddtel IN crapfsc.nrdddtel%TYPE       --> DDD
                       ,pr_nrtelcon IN crapfsc.nrtelcon%TYPE       --> Telefone
                       ,pr_dsemlcon IN crapfsc.dsemlcon%TYPE       --> Email
                       ,pr_nmresson IN crapfsc.nmresson%TYPE       --> Responsável pelo Preenchimento da Sondagem
                       ,pr_datasuge IN VARCHAR2                    --> Datas de Sugestão do Evento
                       ,pr_turmasug IN VARCHAR2                    --> Turmas do Evento
                       ,pr_flgpalco IN crapfsc.flgpalco%TYPE       --> Palco
                       ,pr_dsmpalco IN crapfsc.dsmpalco%TYPE       --> Medida do Palco
                       ,pr_flgearef IN crapfsc.flgearef%TYPE       --> Espaço Amplo no Refeitório
                       ,pr_flgposqu IN crapfsc.flgposqu%TYPE       --> Quadra
                       ,pr_flgqucob IN crapfsc.flgqucob%TYPE       --> Quadra Coberta
                       ,pr_flgposge IN crapfsc.flgposge%TYPE       --> Ginásio de Esportes
                       ,pr_flgpospp IN crapfsc.flgpospp%TYPE       --> Pátio com Pedra Brita
                       ,pr_flgposmi IN crapfsc.flgposmi%TYPE       --> Microfone
                       ,pr_flgposcs IN crapfsc.flgposcs%TYPE       --> Caixa de Som
                       ,pr_dsobslre IN crapfsc.dsobslre%TYPE       --> Observações
                       ,pr_flgpcdia IN crapfsc.flgpcdia%TYPE       --> Diabetes
                       ,pr_qtcridia IN crapfsc.qtcridia%TYPE       --> Diabetes, Quantas?
                       ,pr_flgpcila IN crapfsc.flgpcila%TYPE       --> Intolerância a Lactose
                       ,pr_qtcriila IN crapfsc.qtcriila%TYPE       --> Intolerância a Lactose, Quantas?
                       ,pr_flgpcigl IN crapfsc.flgpcigl%TYPE       --> Intolerância a Glúten
                       ,pr_qtcriigl IN crapfsc.qtcriigl%TYPE       --> Intolerância a Glúten, Quantas?
                       ,pr_dsresali IN crapfsc.dsresali%TYPE       --> Outras Restrições Alimentares?
                       ,pr_flgpcdvi IN crapfsc.flgpcdvi%TYPE       --> Deficiência Visual?
                       ,pr_flgtspro IN crapfsc.flgtspro%TYPE       --> Tem 2º Professor?
                       ,pr_flgnmbra IN crapfsc.flgnmbra%TYPE       --> Necessita de material adaptado em Braile?
                       ,pr_flgpcdau IN crapfsc.flgpcdau%TYPE       --> Deficiência Auditiva?
                       ,pr_flgpilib IN crapfsc.flgpilib%TYPE       --> Possui Interprete de LIBRAS?
                       ,pr_flgpcdfi IN crapfsc.flgpcdfi%TYPE       --> Deficiência Física?
                       ,pr_flgucrod IN crapfsc.flgucrod%TYPE       --> Utiliza cadeira de rodas?
                       ,pr_dsnecace IN crapfsc.dsnecace%TYPE       --> Qual a necessidade de acessibilidade?
                       ,pr_dsoutdfi IN crapfsc.dsoutdfi%TYPE       --> Outras
                       ,pr_dsobsger IN crapfsc.dsobsger%TYPE       --> Observação Gerais
                       ,pr_idprogre IN VARCHAR2                    --> ROWID
                       ,pr_nriniseq IN INTEGER                     --> Sequência Inicial da Consulta    
                       ,pr_qtregist IN INTEGER                     --> Quantidade de Registros por Consulta
                       ,pr_xmllog   IN VARCHAR2                    --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2                   --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType          --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2                   --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS               --> Descricao do Erro

      CURSOR cr_crapfsc(pr_dtanoage crapfsc.dtanoage%TYPE
                       ,pr_cdcooper crapfsc.cdcooper%TYPE
                       ,pr_cdagenci crapfsc.cdagenci%TYPE) IS

        SELECT fsc.dtanoage
              ,fsc.cdcooper
              ,cop.nmrescop
              ,fsc.cdagenci
              ,age.nmresage
              ,fsc.nminstit
              ,fsc.dsendins
              ,fsc.nmpescon
              ,fsc.nrdddtel
              ,fsc.nrtelcon
              ,fsc.dsemlcon
              ,fsc.nmresson
              ,fsc.flgpalco
              ,fsc.dsmpalco
              ,fsc.flgearef
              ,fsc.flgposqu
              ,fsc.flgqucob
              ,fsc.flgposge
              ,fsc.flgpospp
              ,fsc.flgposmi
              ,fsc.flgposcs
              ,fsc.dsobslre
              ,fsc.flgpcdia
              ,fsc.qtcridia
              ,fsc.flgpcila
              ,fsc.qtcriila
              ,fsc.flgpcigl
              ,fsc.qtcriigl
              ,fsc.dsresali
              ,fsc.flgpcdvi
              ,fsc.flgtspro
              ,fsc.flgnmbra
              ,fsc.flgpcdau
              ,fsc.flgpilib
              ,fsc.flgpcdfi
              ,fsc.dsnecace
              ,fsc.flgucrod
              ,fsc.dsoutdfi
              ,fsc.dsobsger
              ,fsc.dtterpre
              ,fsc.ROWID AS idprogre
              ,ROW_NUMBER() OVER(ORDER BY 1, 3, 5) nrdseque
          FROM crapfsc fsc
              ,crapcop cop
              ,crapage age 
         WHERE fsc.cdcooper = cop.cdcooper
           AND cop.cdcooper = age.cdcooper
           AND fsc.cdagenci = age.cdagenci
           AND (fsc.dtanoage = pr_dtanoage OR pr_dtanoage IS NULL)
           AND (fsc.cdcooper = pr_cdcooper OR pr_cdcooper IS NULL)
           AND (fsc.cdagenci = pr_cdagenci OR pr_cdagenci IS NULL)
           AND (UPPER(cop.nmrescop) LIKE '%' || UPPER(pr_nmrescop) || '%' OR pr_nmrescop IS NULL)
           AND (UPPER(age.nmresage) LIKE '%' || UPPER(pr_nmresage) || '%' OR pr_nmresage IS NULL)
           ORDER BY 1 DESC, 3, 5;

      rw_crapfsc cr_crapfsc%ROWTYPE;
    
      CURSOR cr_crapdfs(pr_dtanoage crapdfs.dtanoage%TYPE
                       ,pr_cdcooper crapdfs.cdcooper%TYPE
                       ,pr_cdagenci crapdfs.cdagenci%TYPE) IS

        SELECT TO_CHAR(dfs.dtsugeve,'DD/MM/RRRR') || ';' || TRIM(GENE0002.fn_mask(NVL(dfs.hrinieve,0),'99:99'))
                                                  || ';' || TRIM(GENE0002.fn_mask(NVL(dfs.hrfimeve,0),'99:99'))
                                                  || ';' || TRIM(GENE0002.fn_mask(NVL(dfs.hriniint,0),'99:99'))
                                                  || ';' || TRIM(GENE0002.fn_mask(NVL(dfs.hrfimint,0),'99:99')) AS dtsugeve
          FROM crapdfs dfs
         WHERE dfs.dtanoage = pr_dtanoage
           AND dfs.cdcooper = pr_cdcooper
           AND dfs.cdagenci = pr_cdagenci;

      rw_crapdfs cr_crapdfs%ROWTYPE;

      CURSOR cr_craptfs(pr_dtanoage craptfs.dtanoage%TYPE
                       ,pr_cdcooper craptfs.cdcooper%TYPE
                       ,pr_cdagenci craptfs.cdagenci%TYPE) IS

        SELECT tfs.idserief || ';' || tfs.qtcrimat || ';' || tfs.qtpromat || ';' || tfs.qtcrives || ';' || tfs.qtproves || ';' || tfs.qtcrinot || ';' || tfs.qtpronot AS idserief
          FROM craptfs tfs
         WHERE tfs.dtanoage = pr_dtanoage
           AND tfs.cdcooper = pr_cdcooper
           AND tfs.cdagenci = pr_cdagenci;

      rw_craptfs cr_craptfs%ROWTYPE; 

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

      vr_datas_sugestao GENE0002.typ_split;
      vr_turma_sugestao GENE0002.typ_split;

      -- Tabela de Datas de Sugestões
      vr_datas_sugestao_reg GENE0002.typ_split;
      -- Tabela de Turmas Participantes
      vr_turma_sugestao_reg GENE0002.typ_split;

      vr_tab_dados_datas typ_tab_datas;
      vr_tab_dados_turmas typ_tab_turmas;

      vr_datasuge VARCHAR2(4000) := '';
      vr_turmasug VARCHAR2(4000) := '';

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
          
        IF pr_cdagenci IS NULL OR pr_cdagenci = 0 THEN --> Código do PA
          vr_dscritic := 'Informe o PA.';
          RAISE vr_exc_saida;
        END IF;

        IF TRIM(pr_nminstit) IS NULL THEN --> Nome da Instituição/Escola
          vr_dscritic := 'Informe o Nome da Instituição/Escola.';
          RAISE vr_exc_saida;
        END IF;
    
        IF TRIM(pr_dsendins) IS NULL THEN --> Endereço Completo
          vr_dscritic := 'Informe o Endereço.';
          RAISE vr_exc_saida;
        END IF;  
          
        IF TRIM(pr_nmpescon) IS NULL THEN --> Pessoa de Contato da Instituição/Escola
          vr_dscritic := 'Informe o Pessoa de Contato da Instituição/Escola.';
          RAISE vr_exc_saida;
        END IF;

        IF pr_nrdddtel = 0 OR TRIM(pr_nrdddtel) IS NULL THEN --> DDD
          vr_dscritic := 'Informe o DDD.';
          RAISE vr_exc_saida;
        END IF;

        IF pr_nrtelcon = 0 OR TRIM(pr_nrtelcon) IS NULL THEN --> Telefone
          vr_dscritic := 'Informe o Telefone de Contato.';
          RAISE vr_exc_saida;
        END IF;

        IF TRIM(pr_dsemlcon) IS NULL THEN --> Email
          vr_dscritic := 'Informe o E-mail de Contato.';
          RAISE vr_exc_saida;
        END IF;

        IF TRIM(pr_nmresson) IS NULL THEN --> Responsável pelo Preenchimento da Sondagem
          vr_dscritic := 'Informe o Responsável pelo Preenchimento da Sondagem.';
          RAISE vr_exc_saida;
        END IF;

        IF pr_flgpalco = 1 AND pr_dsmpalco IS NULL THEN --> Medida do Palco
          vr_dscritic := 'Informe a medida do Palco.';
          RAISE vr_exc_saida;
        END IF;

      END IF;
      -- Fim Validações

      -- Datas de Sugestão do Evento
      vr_datas_sugestao := gene0002.fn_quebra_string(pr_string => pr_datasuge,pr_delimit => '#');

      -- Dados de Datas de Sugestão
      IF NVL(vr_datas_sugestao.count(),0) > 0 THEN

        FOR ind_registro IN vr_datas_sugestao.FIRST..vr_datas_sugestao.LAST LOOP

          vr_datas_sugestao_reg := gene0002.fn_quebra_string(pr_string => vr_datas_sugestao(ind_registro),pr_delimit => '|');

          IF TO_DATE(vr_datas_sugestao_reg(1)) < TRUNC(SYSDATE) THEN
            vr_dscritic := 'Informe uma data de sugestão maior ou igual a data atual.';
            RAISE vr_exc_saida;
          END IF;
          vr_tab_dados_datas(ind_registro).dtsugeve := vr_datas_sugestao_reg(1);
          vr_tab_dados_datas(ind_registro).hrinieve := vr_datas_sugestao_reg(2);
          vr_tab_dados_datas(ind_registro).hrfimeve := vr_datas_sugestao_reg(3);
          vr_tab_dados_datas(ind_registro).hriniint := vr_datas_sugestao_reg(4);
          vr_tab_dados_datas(ind_registro).hrfimint := vr_datas_sugestao_reg(5);

        END LOOP;
      END IF;

      -- Turmas de Sugestão do Evento
      vr_turma_sugestao := gene0002.fn_quebra_string(pr_string => pr_turmasug,pr_delimit => '#');
      
      -- Dados de Turmas de Sugestão
      IF NVL(vr_turma_sugestao.count(),0) > 0 THEN

        FOR ind_registro IN vr_turma_sugestao.FIRST..vr_turma_sugestao.LAST LOOP

          vr_turma_sugestao_reg := gene0002.fn_quebra_string(pr_string => vr_turma_sugestao(ind_registro),pr_delimit => '|');

          vr_tab_dados_turmas(ind_registro).idserief := vr_turma_sugestao_reg(1);
          vr_tab_dados_turmas(ind_registro).qtcrimat := vr_turma_sugestao_reg(2);
          vr_tab_dados_turmas(ind_registro).qtpromat := vr_turma_sugestao_reg(3);
          vr_tab_dados_turmas(ind_registro).qtcrives := vr_turma_sugestao_reg(4);
          vr_tab_dados_turmas(ind_registro).qtproves := vr_turma_sugestao_reg(5);
          vr_tab_dados_turmas(ind_registro).qtcrinot := vr_turma_sugestao_reg(6);
          vr_tab_dados_turmas(ind_registro).qtpronot := vr_turma_sugestao_reg(7);

        END LOOP;
      END IF;

      -- Verifica o tipo de acao que sera executada
      CASE 

        WHEN vr_cddopcao = 'A' OR vr_cddopcao = 'I' THEN -- Alteracao

          -- Inclusão da Sondagem Principal
          BEGIN
            INSERT INTO crapfsc(dtanoage, cdcooper, cdagenci, nminstit
                               ,dsendins, nmpescon, nrdddtel, nrtelcon
                               ,dsemlcon, nmresson, flgpalco, dsmpalco
                               ,flgearef, flgposqu, flgqucob, flgposge
                               ,flgpospp, flgposmi, flgposcs, dsobslre
                               ,flgpcdia, qtcridia, flgpcila, qtcriila
                               ,flgpcigl, qtcriigl, dsresali, flgpcdvi
                               ,flgtspro, flgnmbra, flgpcdau, flgpilib
                               ,flgpcdfi, dsnecace, flgucrod, dsoutdfi
                               ,dsobsger, cdoperad, cdprogra, dtatuali)
            VALUES(pr_dtanoage, pr_cdcooper, pr_cdagenci, pr_nminstit
                  ,pr_dsendins, pr_nmpescon, pr_nrdddtel, pr_nrtelcon
                  ,pr_dsemlcon, pr_nmresson, pr_flgpalco, pr_dsmpalco
                  ,pr_flgearef, pr_flgposqu, pr_flgqucob, pr_flgposge
                  ,pr_flgpospp, pr_flgposmi, pr_flgposcs, pr_dsobslre
                  ,pr_flgpcdia, pr_qtcridia, pr_flgpcila, pr_qtcriila
                  ,pr_flgpcigl, pr_qtcriigl, pr_dsresali, pr_flgpcdvi
                  ,pr_flgtspro, pr_flgnmbra, pr_flgpcdau, pr_flgpilib
                  ,pr_flgpcdfi, pr_dsnecace, pr_flgucrod, pr_dsoutdfi
                  ,pr_dsobsger, vr_cdoperad, vr_nmdatela, SYSDATE);
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              /* UPDATE */
              -- Atualização da Sondagem Principal
              BEGIN
                UPDATE crapfsc
                   SET crapfsc.nminstit = pr_nminstit
                      ,crapfsc.dsendins = pr_dsendins
                      ,crapfsc.nmpescon = pr_nmpescon
                      ,crapfsc.nrdddtel = pr_nrdddtel
                      ,crapfsc.nrtelcon = pr_nrtelcon
                      ,crapfsc.dsemlcon = pr_dsemlcon
                      ,crapfsc.nmresson = pr_nmresson
                      ,crapfsc.flgpalco = pr_flgpalco
                      ,crapfsc.dsmpalco = pr_dsmpalco
                      ,crapfsc.flgearef = pr_flgearef
                      ,crapfsc.flgposqu = pr_flgposqu
                      ,crapfsc.flgqucob = pr_flgqucob
                      ,crapfsc.flgposge = pr_flgposge
                      ,crapfsc.flgpospp = pr_flgpospp
                      ,crapfsc.flgposmi = pr_flgposmi
                      ,crapfsc.flgposcs = pr_flgposcs
                      ,crapfsc.dsobslre = pr_dsobslre
                      ,crapfsc.flgpcdia = pr_flgpcdia
                      ,crapfsc.qtcridia = pr_qtcridia
                      ,crapfsc.flgpcila = pr_flgpcila
                      ,crapfsc.qtcriila = pr_qtcriila
                      ,crapfsc.flgpcigl = pr_flgpcigl
                      ,crapfsc.qtcriigl = pr_qtcriigl
                      ,crapfsc.dsresali = pr_dsresali
                      ,crapfsc.flgpcdvi = pr_flgpcdvi
                      ,crapfsc.flgtspro = pr_flgtspro
                      ,crapfsc.flgnmbra = pr_flgnmbra
                      ,crapfsc.flgpcdau = pr_flgpcdau
                      ,crapfsc.flgpilib = pr_flgpilib
                      ,crapfsc.flgpcdfi = pr_flgpcdfi
                      ,crapfsc.dsnecace = pr_dsnecace
                      ,crapfsc.flgucrod = pr_flgucrod
                      ,crapfsc.dsoutdfi = pr_dsoutdfi
                      ,crapfsc.dsobsger = pr_dsobsger
                      ,crapfsc.cdoperad = vr_cdoperad
                      ,crapfsc.cdprogra = vr_nmdatela
                      ,crapfsc.dtatuali = SYSDATE
                 WHERE crapfsc.dtanoage = pr_dtanoage
                   AND crapfsc.cdcooper = pr_cdcooper
                   AND crapfsc.cdagenci = pr_cdagenci;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar registro(CRAPFSC). Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
              /* FIM UPDATE */
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro(CRAPFSC). Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
                      
          -- Fim Atualização da Sondagem Principal
           
        WHEN vr_cddopcao = 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

          -- Informações referente ao furmulário de sondagem
          FOR rw_crapfsc IN cr_crapfsc(pr_dtanoage => pr_dtanoage
                                      ,pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci) LOOP
                     
            IF ((pr_nriniseq <= rw_crapfsc.nrdseque) AND (rw_crapfsc.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                  
              -- Informações referente a datas da sondagem
              vr_datasuge := '';
              FOR rw_crapdfs IN cr_crapdfs(pr_dtanoage => rw_crapfsc.dtanoage
                                          ,pr_cdcooper => rw_crapfsc.cdcooper
                                          ,pr_cdagenci => rw_crapfsc.cdagenci) LOOP
                IF vr_datasuge IS NULL THEN
                  vr_datasuge := rw_crapdfs.dtsugeve;
                ELSE
                  vr_datasuge := vr_datasuge || '+' || rw_crapdfs.dtsugeve;
                END IF;
              END LOOP;

              -- Informações referente a turmas da sondagem
              vr_turmasug := '';
              FOR rw_craptfs IN cr_craptfs(pr_dtanoage => rw_crapfsc.dtanoage
                                          ,pr_cdcooper => rw_crapfsc.cdcooper
                                          ,pr_cdagenci => rw_crapfsc.cdagenci) LOOP
                
                IF vr_turmasug IS NULL THEN
                  vr_turmasug := rw_craptfs.idserief;
                ELSE
                  vr_turmasug := vr_turmasug || '+' || rw_craptfs.idserief;
                END IF;
              END LOOP;

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtanoage', pr_tag_cont => rw_crapfsc.dtanoage, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooperPesquisa', pr_tag_cont => rw_crapfsc.cdcooper, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapfsc.nmrescop, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdagenciPesquisa', pr_tag_cont => rw_crapfsc.cdagenci, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmresage', pr_tag_cont => rw_crapfsc.nmresage, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nminstit', pr_tag_cont => rw_crapfsc.nminstit, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsendins', pr_tag_cont => rw_crapfsc.dsendins, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmpescon', pr_tag_cont => rw_crapfsc.nmpescon, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdddtel', pr_tag_cont => TRIM(GENE0002.fn_mask(rw_crapfsc.nrdddtel,'zz')), pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrtelcon', pr_tag_cont => TRIM(GENE0002.fn_mask(rw_crapfsc.nrtelcon,'z9999-9999')), pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsemlcon', pr_tag_cont => rw_crapfsc.dsemlcon, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmresson', pr_tag_cont => rw_crapfsc.nmresson, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgpalco', pr_tag_cont => rw_crapfsc.flgpalco, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsmpalco', pr_tag_cont => rw_crapfsc.dsmpalco, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgearef', pr_tag_cont => rw_crapfsc.flgearef, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgposqu', pr_tag_cont => rw_crapfsc.flgposqu, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgqucob', pr_tag_cont => rw_crapfsc.flgqucob, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgposge', pr_tag_cont => rw_crapfsc.flgposge, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgpospp', pr_tag_cont => rw_crapfsc.flgpospp, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgposmi', pr_tag_cont => rw_crapfsc.flgposmi, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgposcs', pr_tag_cont => rw_crapfsc.flgposcs, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsobslre', pr_tag_cont => rw_crapfsc.dsobslre, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgpcdia', pr_tag_cont => rw_crapfsc.flgpcdia, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtcridia', pr_tag_cont => rw_crapfsc.qtcridia, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgpcila', pr_tag_cont => rw_crapfsc.flgpcila, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtcriila', pr_tag_cont => rw_crapfsc.qtcriila, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgpcigl', pr_tag_cont => rw_crapfsc.flgpcigl, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtcriigl', pr_tag_cont => rw_crapfsc.qtcriigl, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsresali', pr_tag_cont => rw_crapfsc.dsresali, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgpcdvi', pr_tag_cont => rw_crapfsc.flgpcdvi, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgtspro', pr_tag_cont => rw_crapfsc.flgtspro, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgnmbra', pr_tag_cont => rw_crapfsc.flgnmbra, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgpcdau', pr_tag_cont => rw_crapfsc.flgpcdau, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgpilib', pr_tag_cont => rw_crapfsc.flgpilib, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgpcdfi', pr_tag_cont => rw_crapfsc.flgpcdfi, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsnecace', pr_tag_cont => rw_crapfsc.dsnecace, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgucrod', pr_tag_cont => rw_crapfsc.flgucrod, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsoutdfi', pr_tag_cont => rw_crapfsc.dsoutdfi, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsobsger', pr_tag_cont => rw_crapfsc.dsobsger, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtterpre', pr_tag_cont => rw_crapfsc.dtterpre, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idprogre', pr_tag_cont => rw_crapfsc.idprogre, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'datasuge', pr_tag_cont => vr_datasuge, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'turmasug', pr_tag_cont => vr_turmasug, pr_des_erro => vr_dscritic);

              vr_contador := vr_contador + 1;
            END IF;

            vr_totregis := vr_totregis +1;

          END LOOP;

          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

      WHEN vr_cddopcao = 'E' THEN -- Exclusao
        BEGIN
          DELETE 
            FROM crapdfs
           WHERE crapdfs.dtanoage = pr_dtanoage
             AND crapdfs.cdcooper = pr_cdcooper
             AND crapdfs.cdagenci = pr_cdagenci;
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir registro(CRAPDFS). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        BEGIN
          DELETE 
            FROM craptfs
           WHERE craptfs.dtanoage = pr_dtanoage
             AND craptfs.cdcooper = pr_cdcooper
             AND craptfs.cdagenci = pr_cdagenci;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPTFS). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        BEGIN
          DELETE 
            FROM crapfsc
           WHERE crapfsc.dtanoage = pr_dtanoage
             AND crapfsc.cdcooper = pr_cdcooper
             AND crapfsc.cdagenci = pr_cdagenci;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPFSC). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

      END CASE;
  
      IF UPPER(vr_cddopcao) = 'A' OR UPPER(vr_cddopcao) = 'I' THEN
        -- Inclusão de Datas da Sondagem
        -- Primeiramente deleta todos os registros existentes referentes as datas
        BEGIN
          DELETE crapdfs WHERE crapdfs.dtanoage = pr_dtanoage
                           AND crapdfs.cdcooper = pr_cdcooper
                           AND crapdfs.cdagenci = pr_cdagenci;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao deletar registros de datas do evento(CRAPDFS). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
  
        -- Datas
        FOR ind_registro IN vr_tab_dados_datas.FIRST..vr_tab_dados_datas.LAST LOOP
          IF vr_tab_dados_datas(ind_registro).hrinieve >= vr_tab_dados_datas(ind_registro).hrfimeve THEN
            vr_dscritic := 'Hora de início do evento maior ou igual que hora final do evento.';
            RAISE vr_exc_saida;
          END IF;

          IF vr_tab_dados_datas(ind_registro).hriniint >= vr_tab_dados_datas(ind_registro).hrfimint AND 
             vr_tab_dados_datas(ind_registro).hriniint <> '00:00' AND vr_tab_dados_datas(ind_registro).hrfimint <> '00:00' THEN
            vr_dscritic := 'Hora de início de intervalo do evento maior ou igual que hora final de intervalo do evento.';
            RAISE vr_exc_saida;
          END IF;

          BEGIN
            INSERT INTO crapdfs(dtanoage, cdcooper, cdagenci, dtsugeve, hrinieve, hrfimeve
                               ,hriniint, hrfimint, cdoperad, cdprogra, dtatuali)
              VALUES(pr_dtanoage, pr_cdcooper, pr_cdagenci, vr_tab_dados_datas(ind_registro).dtsugeve
                    ,vr_tab_dados_datas(ind_registro).hrinieve, vr_tab_dados_datas(ind_registro).hrfimeve
                    ,vr_tab_dados_datas(ind_registro).hriniint, vr_tab_dados_datas(ind_registro).hrfimint
                    ,vr_cdoperad, vr_nmdatela, SYSDATE);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registros de datas do evento(CRAPDFS). Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END LOOP;
        -- Fim Inclusão de Datas da Sondagem
          
        -- Inclusão de Turmas da Sondagem
        -- Primeiramente deleta todos os registros existentes referentes as turmas
        BEGIN
          DELETE craptfs WHERE craptfs.dtanoage = pr_dtanoage
                           AND craptfs.cdcooper = pr_cdcooper
                           AND craptfs.cdagenci = pr_cdagenci;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao deletar registros de turmas do evento(CRAPDFS). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
          
        -- Turmas
        FOR ind_registro IN vr_tab_dados_turmas.FIRST..vr_tab_dados_turmas.LAST LOOP
          BEGIN
            INSERT INTO craptfs(dtanoage, cdcooper, cdagenci, idserief, qtcrimat, qtpromat, qtcrives
                               ,qtproves, qtcrinot, qtpronot, cdoperad, cdprogra, dtatuali)
              VALUES(pr_dtanoage, pr_cdcooper, pr_cdagenci, vr_tab_dados_turmas(ind_registro).idserief
                    ,NVL(vr_tab_dados_turmas(ind_registro).qtcrimat,0),NVL(vr_tab_dados_turmas(ind_registro).qtpromat,0)
                    ,NVL(vr_tab_dados_turmas(ind_registro).qtcrives,0),NVL(vr_tab_dados_turmas(ind_registro).qtproves,0)
                    ,NVL(vr_tab_dados_turmas(ind_registro).qtcrinot,0),NVL(vr_tab_dados_turmas(ind_registro).qtpronot,0)
                    ,vr_cdoperad, vr_nmdatela, SYSDATE);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registros de turmas do evento(CRAPTFS). Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END LOOP;  
        -- Fim Inclusão de Turmas da Sondagem
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

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PC_WPGD0147: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_wpgd0147;

END WPGD0147;
/
