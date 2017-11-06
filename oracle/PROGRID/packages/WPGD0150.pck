CREATE OR REPLACE PACKAGE PROGRID.WPGD0150 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0150                     
  --  Sistema  : Rotinas para tela de Cadastro de Metas (WPGD0150)
  --  Sigla    : WPGD
  --  Autor    : ANDREI
  --  Data     : 27/09/2017.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Metas Assembleares)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0150
  PROCEDURE pc_wpgd0150(pr_dtanoage IN progrid.CRAPMEA.dtanoage%TYPE --> Ano da agenda da meta
                       ,pr_cdcooper IN progrid.CRAPMEA.cdcooper%TYPE --> Cooperativa da meta
                       ,pr_cdagenci IN progrid.CRAPMEA.cdagenci%TYPE --> PA da meta
                       ,pr_dsemlcon IN progrid.CRAPMEA.dsemlcon%TYPE --> Descricao do E-mail de Contato do responsavel pela meta
                       ,pr_qtsugoqs IN progrid.CRAPMEA.qtsugoqs%TYPE --> Quantidade da meta sugerida pela OQS
                       ,pr_dtenvage IN progrid.CRAPMEA.dtenvage%TYPE --> Data de envio do e-mail para o PA com a meta sugerira
                       ,pr_dtretage IN progrid.CRAPMEA.dtretage%TYPE --> Data de retorno do parecer do PA
                       ,pr_dsparage IN progrid.CRAPMEA.dsparage%TYPE --> Descricao do parecer do PA
                       ,pr_qtsugage IN progrid.CRAPMEA.qtsugage%TYPE --> Quantidade da meta sugerida pelo PA
                       ,pr_qtmetfim IN progrid.CRAPMEA.qtmetfim%TYPE --> Quantidade da meta final                       
                       ,pr_dtmetfim IN progrid.CRAPMEA.dtmetfim%TYPE --> Data da digitacao da meta final
                       ,pr_nriniseq IN crapqmd.idevento%TYPE --> Registro inicial para pesquisa
                       ,pr_qtregist IN crapqmd.idevento%TYPE --> Quantidade de registros por pesquisa
                       ,pr_nmrescop IN crapcop.nmrescop%TYPE --> Nome da Cooperativa Busca
                       ,pr_nmresage IN crapage.nmresage%TYPE --> Nome do PA Busca
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
  
END WPGD0150;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0150 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0150                     
  --  Sistema  : Rotinas para tela de Cadastro de Metas (WPGD0150)
  --  Sigla    : WPGD
  --  Autor    : ANDREI
  --  Data     : 27/09/2017.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Metas Assembleares)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0150
  PROCEDURE pc_wpgd0150(pr_dtanoage IN progrid.CRAPMEA.dtanoage%TYPE --> Ano da agenda da meta
                       ,pr_cdcooper IN progrid.CRAPMEA.cdcooper%TYPE --> Cooperativa da meta
                       ,pr_cdagenci IN progrid.CRAPMEA.cdagenci%TYPE --> PA da meta
                       ,pr_dsemlcon IN progrid.CRAPMEA.dsemlcon%TYPE --> Descricao do E-mail de Contato do responsavel pela meta
                       ,pr_qtsugoqs IN progrid.CRAPMEA.qtsugoqs%TYPE --> Quantidade da meta sugerida pela OQS
                       ,pr_dtenvage IN progrid.CRAPMEA.dtenvage%TYPE --> Data de envio do e-mail para o PA com a meta sugerira
                       ,pr_dtretage IN progrid.CRAPMEA.dtretage%TYPE --> Data de retorno do parecer do PA
                       ,pr_dsparage IN progrid.CRAPMEA.dsparage%TYPE --> Descricao do parecer do PA
                       ,pr_qtsugage IN progrid.CRAPMEA.qtsugage%TYPE --> Quantidade da meta sugerida pelo PA
                       ,pr_qtmetfim IN progrid.CRAPMEA.qtmetfim%TYPE --> Quantidade da meta final                       
                       ,pr_dtmetfim IN progrid.CRAPMEA.dtmetfim%TYPE --> Data da digitacao da meta final
                       ,pr_nriniseq IN crapqmd.idevento%TYPE --> Registro inicial para pesquisa
                       ,pr_qtregist IN crapqmd.idevento%TYPE --> Quantidade de registros por pesquisa
                       ,pr_nmrescop IN crapcop.nmrescop%TYPE --> Nome da Cooperativa Busca
                       ,pr_nmresage IN crapage.nmresage%TYPE --> Nome do PA Busca
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro

      -- CURSORES             
      -- Consulta das metas
      CURSOR cr_crapmea(pr_dtanoage in progrid.crapmea.dtanoage%TYPE
                       ,pr_cdcooper IN progrid.crapmea.cdcooper%TYPE
                       ,pr_cdagenci IN progrid.crapmea.cdagenci%TYPE) IS
        SELECT mea.dtanoage         AS dtanoage
              ,mea.cdcooper         AS cdcooper
              ,cop.nmrescop         AS nmrescop
              ,mea.cdagenci         AS cdagenci
              ,age.nmresage         AS nmresage
              ,mea.dsemlcon         AS dsemlcon
              ,mea.qtsugoqs         AS qtsugoqs
              ,mea.cdcopsug         AS cdcopsug
              ,mea.cdopesug         AS cdopesug
              ,mea.dtenvage         AS dtenvage
              ,mea.dtretage         AS dtretage
              ,mea.dsparage         AS dsparage
              ,mea.qtsugage         AS qtsugage
              ,mea.cdcopage         AS cdcopage
              ,mea.cdopeage         AS cdopeage
              ,mea.qtmetfim         AS qtmetfim     
              ,mea.dtmetfim         AS dtmetfim       
              ,mea.cdcopfim         AS cdcopfim
              ,mea.cdopefim         AS cdopefim 
              ,ROW_NUMBER() OVER(ORDER BY cop.nmrescop, age.nmresage) AS nrdseque
         FROM progrid.crapmea mea,
              crapcop cop,
              crapage age
        WHERE (mea.dtanoage = pr_dtanoage OR NVL(pr_dtanoage,0) = 0)
          AND (mea.cdcooper = pr_cdcooper OR NVL(pr_cdcooper,0) = 0)
          AND (mea.cdagenci = pr_cdagenci OR NVL(pr_cdagenci,0) = 0)
          AND cop.cdcooper = mea.cdcooper
          AND age.cdcooper = cop.cdcooper
          AND age.cdagenci = mea.cdagenci
          AND ((UPPER(cop.nmrescop) LIKE '%' || UPPER(pr_nmrescop) || '%') OR pr_nmrescop IS NULL) 
          AND ((UPPER(age.nmresage) LIKE '%' || UPPER(pr_nmresage) || '%') OR pr_nmresage IS NULL)           
      ORDER BY mea.dtanoage desc,nmrescop, age.nmresage;   
      rw_crapmea cr_crapmea%ROWTYPE;

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
      
      vr_dsdemail    crapage.dsdemail%TYPE;
      vr_texto_email VARCHAR2(4000) := NULL;
      vr_conteudo    VARCHAR2(4000) := NULL;
      vr_cdprogra    VARCHAR2(40) := 'WPGD0150';
      vr_idprglog    tbgen_prglog.idprglog%TYPE := 0;
      vr_nmresage    crapage.nmresage%TYPE;
      vr_nmrescop    crapage.nmresage%TYPE;   

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
          BEGIN
              select
                    trim(c.dsdemail),
                    c.nmresage,
                    cc.nmrescop
              into
                    vr_dsdemail,
                    vr_nmresage,
                    vr_nmrescop
              from 
                    crapage c,
                    crapcop cc
              where 
                    c.cdcooper  = pr_cdcooper
                and c.cdagenci  = pr_cdagenci
                and cc.cdcooper = c.cdcooper;
          EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := '0 - Erro ao selecionar registro(CRAPAGE), PA: ' || pr_cdagenci || '. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
          END;
          IF trim(vr_dsdemail) is null THEN
          -- Se não tiver e-mail cadastrado, sair sem salvar
             vr_dscritic := 'Favor cadastrar o E-mail para o PA: ' || vr_nmresage || '. Antes de cadastrar a meta!';
             RAISE vr_exc_saida;
          END IF;
          
          IF pr_qtsugoqs is not null and pr_dsparage is null and pr_qtmetfim is null THEN
            -- Está atualizando a quantidade sugerida pela OQS            
            BEGIN            
              UPDATE progrid.crapmea mea
                 SET mea.dsemlcon         = pr_dsemlcon
                    ,mea.qtsugoqs         = pr_qtsugoqs
                    ,mea.cdcopsug         = vr_cdcooper
                    ,mea.cdopesug         = vr_cdoperad
                    ,mea.dtenvage         = sysdate
               WHERE mea.dtanoage = pr_dtanoage
                 AND mea.cdcooper = pr_cdcooper
                 AND mea.cdagenci = pr_cdagenci;            
            EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := '1 - Erro ao alterar registro(CRAPMEA), PA: ' || pr_cdagenci || '. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
            END;   
            IF SQL%ROWCOUNT = 0 THEN
               BEGIN
                  INSERT INTO
              progrid.crapmea(dtanoage ,
                              cdcooper ,
                              cdagenci ,
                              dsemlcon ,
                              qtsugoqs ,
                              cdcopsug ,
                              cdopesug ,
                              dtenvage ,
                              dtretage ,
                              dsparage ,
                              qtsugage ,
                              cdcopage ,
                              cdopeage ,
                              qtmetfim ,
                              dtmetfim ,
                              cdcopfim ,
                              cdopefim
                      )VALUES(pr_dtanoage
                             ,pr_cdcooper
                             ,pr_cdagenci
                             ,pr_dsemlcon
                             ,pr_qtsugoqs
                             ,vr_cdcooper
                             ,vr_cdoperad 
                             ,sysdate
                             ,pr_dtretage
                             ,pr_dsparage
                             ,pr_qtsugage                                 
                             ,null
                             ,null
                             ,pr_qtmetfim 
                             ,pr_dtmetfim 
                             ,null 
                             ,null);                                                 
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir registro(CRAPMEA), PA: ' || pr_cdagenci || '. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
            END IF; 
            --
            -- Envia e-mail para o PA informando a digitação da meta sugerida
            vr_conteudo := '<b>ATENÇÃO!</b>' ||
                           '<br>A meta para os eventos assembleares do seu PA foi definida pela OQS.' ||
                           '<br>Verifique e dê seu parecer através da tela Parecer Meta PA.' || 
                           '<br><br>';
        
            vr_dscritic := NULL;
                                      
            gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                      ,pr_cdprogra        => 'ASSEMBLEIA'
                                      ,pr_des_destino     => vr_dsdemail
                                      ,pr_des_assunto     => 'Meta Eventos Assembleares - '||vr_nmrescop||'- '||vr_nmresage
                                      ,pr_des_corpo       => vr_conteudo
                                      ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                      ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                      ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                      ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                      ,pr_des_erro        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                             ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                             ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                              -- Parametros para Ocorrencia
                             ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                             ,pr_cdcriticidade => 1             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             ,pr_dsmensagem    => vr_dscritic||' '||Sqlerrm   --> dscritic       
                             ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                             ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)
            END IF;
-- Fim envio e-mail
               
          ELSIF pr_dsparage is not null and pr_qtmetfim is not null THEN
          -- Está atualizando as informações da meta final 
            BEGIN
              UPDATE progrid.crapmea mea
               SET mea.qtmetfim         = pr_qtmetfim     
                  ,mea.dtmetfim         = sysdate
                  ,mea.cdcopfim         = vr_cdcooper
                  ,mea.cdopefim         = vr_cdoperad
             WHERE mea.dtanoage = pr_dtanoage
               AND mea.cdcooper = pr_cdcooper
               AND mea.cdagenci = pr_cdagenci;            
            EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := '3 - Erro ao alterar registro(CRAPMEA), PA: ' || pr_cdagenci || '. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
            END;
            --
            -- Envia e-mail para o PA informando a digitação da meta final
            vr_conteudo := '<b>ATENÇÃO!</b>' ||
                           '<br>A meta final ('||pr_qtmetfim||') para os eventos assembleares do seu PA foi definida pela OQS.' ||
                           '<br><br>';
        
            vr_dscritic := NULL;
                                      
            gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                      ,pr_cdprogra        => 'ASSEMBLEIA'
                                      ,pr_des_destino     => vr_dsdemail
                                      ,pr_des_assunto     => 'Meta Final Eventos Assembleares - '||vr_nmrescop||'- '||vr_nmresage
                                      ,pr_des_corpo       => vr_conteudo
                                      ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                      ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                      ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                      ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                      ,pr_des_erro        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                             ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                             ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                              -- Parametros para Ocorrencia
                             ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                             ,pr_cdcriticidade => 1             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             ,pr_dsmensagem    => vr_dscritic||' '||Sqlerrm   --> dscritic       
                             ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                             ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)
            END IF;
-- Fim envio e-mail

          END IF;          
          
    WHEN 'C' THEN -- Consulta
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');
           FOR rw_crapmea IN cr_crapmea(pr_dtanoage => pr_dtanoage
                                      ,pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci) LOOP
                     
            IF ((pr_nriniseq <= rw_crapmea.nrdseque) AND (rw_crapmea.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                   
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtanoage', pr_tag_cont => rw_crapmea.dtanoage, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapmea.cdcooper, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => UPPER(rw_crapmea.nmrescop), pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_crapmea.cdagenci, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmresage', pr_tag_cont => UPPER(rw_crapmea.nmresage), pr_des_erro => vr_dscritic); 
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsemlcon', pr_tag_cont => rw_crapmea.dsemlcon, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtsugoqs', pr_tag_cont => rw_crapmea.qtsugoqs, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcopsug', pr_tag_cont => rw_crapmea.cdcopsug, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdopesug', pr_tag_cont => rw_crapmea.cdopesug, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtenvage', pr_tag_cont => rw_crapmea.dtenvage, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtretage', pr_tag_cont => rw_crapmea.dtretage, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsparage', pr_tag_cont => rw_crapmea.dsparage, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtsugage', pr_tag_cont => rw_crapmea.qtsugage, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcopage', pr_tag_cont => rw_crapmea.cdcopage, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdopeage', pr_tag_cont => rw_crapmea.cdopeage, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtmetfim', pr_tag_cont => rw_crapmea.qtmetfim, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtmetfim', pr_tag_cont => rw_crapmea.dtmetfim, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcopfim', pr_tag_cont => rw_crapmea.cdcopfim, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdopefim', pr_tag_cont => rw_crapmea.cdopefim, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdseque', pr_tag_cont => rw_crapmea.nrdseque, pr_des_erro => vr_dscritic);
              vr_contador := vr_contador + 1;
            END IF;

            vr_totregis := vr_totregis +1;

          END LOOP;

          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

      WHEN 'E' THEN -- Exclusao
        BEGIN
          DELETE
            FROM progrid.crapmea mea
           WHERE mea.dtanoage = pr_dtanoage
             AND mea.cdcooper = pr_cdcooper
             AND mea.cdagenci = pr_cdagenci;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPMEA). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END CASE;
  
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
        pr_dscritic := 'Erro geral em PC_WPGD0150: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_wpgd0150;

END WPGD0150;
/
