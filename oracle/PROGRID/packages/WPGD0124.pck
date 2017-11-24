CREATE OR REPLACE PACKAGE PROGRID.WPGD0124 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0124                     
  --  Sistema  : Rotinas para tela de Programas do Progrid
  --  Sigla    : WPGD
  --  Autor    : Jean Michel Deschamps
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

  -- Rotina geral de insert, update, select e delete da tela WPGD0124 na tabela crapcma
  PROCEDURE WPGD0124(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                    ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                    ,pr_nmrescop IN crapcop.nmrescop%TYPE --> Nome da Cooperativa
                    ,pr_nrseqcma IN crapcma.nrseqcma%TYPE --> Sequencia do componente da mesa
                    ,pr_nmcompon IN crapcma.nmcompon%TYPE --> Nome do Componente da Mesa
                    ,pr_dscarcom IN crapcma.dscarcom%TYPE --> Descricao do Cargo do Componente da Mesa
                    ,pr_idsitcma IN crapcma.idsitcma%TYPE --> Situação do Componente
                    ,pr_dssitcma IN VARCHAR2              --> Descrição da Situação do Componente
                    ,pr_nriniseq IN PLS_INTEGER           --> Registro inicial de consulta
                    ,pr_qtregist IN PLS_INTEGER           --> Quantidade de registros por consulta
                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                    ,pr_des_erro OUT VARCHAR2);           --> Descricao do erro

END WPGD0124;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0124 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0124                     
  --  Sistema  : Rotinas para Programas do Progrid
  --  Sigla    : WPGD
  --  Autor    : Jean Michel Deschamps
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
  -- Rotina geral de insert, update, select e delete da tela WPGD0124 na tabela crapcma
  PROCEDURE WPGD0124(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                    ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                    ,pr_nmrescop IN crapcop.nmrescop%TYPE --> Nome da Cooperativa
                    ,pr_nrseqcma IN crapcma.nrseqcma%TYPE --> Sequencia do componente da mesa
                    ,pr_nmcompon IN crapcma.nmcompon%TYPE --> Nome do Componente da Mesa
                    ,pr_dscarcom IN crapcma.dscarcom%TYPE --> Descricao do Cargo do Componente da Mesa
                    ,pr_idsitcma IN crapcma.idsitcma%TYPE --> Situação do Componente
                    ,pr_dssitcma IN VARCHAR2              --> Descrição da Situação do Componente
                    ,pr_nriniseq IN PLS_INTEGER           --> Registro inicial de consulta
                    ,pr_qtregist IN PLS_INTEGER           --> Quantidade de registros por consulta
                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                    ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do erro

      -- Cursor sobre a tabela de programas do progrid
      CURSOR cr_crapcma IS
         SELECT cma.cdcooper
               ,cop.nmrescop
               ,cma.nrseqcma
               ,cma.nmcompon
               ,cma.dscarcom
               ,cma.idsitcma
               ,DECODE(cma.idsitcma,1,'ATIVO',0,'INATIVO') AS dssitcma
               ,cma.cdcopope
               ,cma.cdoperad
               ,cma.cdprogra
               ,cma.dtatuali
               ,cma.progress_recid
               ,ROW_NUMBER() OVER(ORDER BY cma.nmcompon, cma.dscarcom DESC) nrdseque
          FROM crapcma cma
              ,crapcop cop
          WHERE (UPPER(cma.nmcompon) LIKE '%' || UPPER(pr_nmcompon) || '%' OR pr_nmcompon IS NULL)
            AND (UPPER(cop.nmrescop) LIKE '%' || UPPER(pr_nmrescop) || '%' OR pr_nmrescop IS NULL)
            AND (UPPER(cma.dscarcom) LIKE '%' || UPPER(pr_dscarcom) || '%' OR pr_dscarcom IS NULL)
            AND (DECODE(cma.idsitcma,1,'ATIVO',0,'INATIVO') LIKE '%' || UPPER(pr_dssitcma) || '%' OR pr_dssitcma IS NULL)
            AND cma.cdcooper = cop.cdcooper
      ORDER BY cma.nmcompon
              ,cma.dscarcom;
      
      rw_crapcma cr_crapcma%ROWTYPE;

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

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_totregis PLS_INTEGER := 0;
      vr_nrseqcma crapcma.nrseqcma%TYPE;
      vr_existe_evento  NUMBER:=0;
      
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
    
      -- Verifica o tipo de acao que sera executada
      CASE pr_cddopcao

        WHEN 'A' THEN -- Alteracao
          BEGIN
            -- Atualizacao de registro de Progras do Progrid
            UPDATE crapcma
               SET crapcma.cdcooper = pr_cdcooper,
                   crapcma.nmcompon = UPPER(pr_nmcompon),
                   crapcma.dscarcom = UPPER(pr_dscarcom),
                   crapcma.idsitcma = pr_idsitcma,
                   crapcma.cdoperad = vr_cdoperad,
                   crapcma.cdcopope = vr_cdcooper,
                   crapcma.cdprogra = vr_nmdatela,
                   crapcma.dtatuali = SYSDATE
             WHERE crapcma.nrseqcma = pr_nrseqcma;

          -- Verifica se houve problema na atualizacao do registro
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar CRAPCMA: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;

        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
           -- Loop sobre os Parceiros Institucionais do Progrid
          FOR rw_crapcma IN cr_crapcma LOOP
              IF ((pr_nriniseq <= rw_crapcma.nrdseque)AND (rw_crapcma.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper'      , pr_tag_cont => rw_crapcma.cdcooper , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop'      , pr_tag_cont => rw_crapcma.nmrescop , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqcma'      , pr_tag_cont => rw_crapcma.nrseqcma , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmcompon'      , pr_tag_cont => rw_crapcma.nmcompon , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dscarcom'      , pr_tag_cont => rw_crapcma.dscarcom , pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idsitcma'      , pr_tag_cont => rw_crapcma.idsitcma , pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dssitcma'      , pr_tag_cont => rw_crapcma.dssitcma , pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcopope'      , pr_tag_cont => rw_crapcma.cdcopope , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad'      , pr_tag_cont => rw_crapcma.cdoperad , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra'      , pr_tag_cont => rw_crapcma.cdprogra , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali'      , pr_tag_cont => rw_crapcma.dtatuali , pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'progress_recid', pr_tag_cont => rw_crapcma.progress_recid , pr_des_erro => vr_dscritic);  
                vr_contador := vr_contador + 1;
             END IF;
             vr_totregis := vr_totregis +1;    
          END LOOP;
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis'   , pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);           

        WHEN 'E' THEN -- Exclusao
             
          --Evento
          BEGIN
            SELECT 1
              INTO vr_existe_evento
              FROM crapcmp cmp
               WHERE cmp.nrseqcma = pr_nrseqcma
                 AND rownum = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              vr_existe_evento:=0;
          END;        
          
          -- Verifica se existe evento associado ao programa
          IF vr_existe_evento = 1 THEN
            vr_dscritic := 'Exclusão não permitida. Este Componente da Mesa de Autoridade está associado a um evento.' ;
            RAISE vr_exc_saida;             
          ELSE
            BEGIN
              DELETE crapcma
               WHERE nrseqcma = pr_nrseqcma;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na exclusao de registros
                vr_dscritic := 'Erro ao excluir o Programa do Progrid. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;

        WHEN 'I' THEN -- Inclusao

          -- Efetua a inclusao no cadastro de Programa do Progrid
          vr_nrseqcma := fn_sequence(pr_nmtabela => 'CRAPPGM', pr_nmdcampo => 'NRSEQPGM',pr_dsdchave => '0');

          BEGIN
            INSERT INTO crapcma(cdcooper,nrseqcma, nmcompon, dscarcom, idsitcma, cdcopope, cdoperad, cdprogra, dtatuali)
              VALUES(pr_cdcooper,vr_nrseqcma,UPPER(pr_nmcompon), UPPER(pr_dscarcom), pr_idsitcma, vr_cdcooper, vr_cdoperad,vr_nmdatela, SYSDATE);

          -- Verifica se houve problema na insercao de registros
          EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Atencao: Este Componente já foi cadastrado. Favor verificar!';
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao inserir CRAPCMA: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;
            
          -- Retorna a sequencia criada
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><nrseqcma>' || TO_CHAR(vr_nrseqcma) || '</nrseqcma></Root>');

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
        pr_dscritic := 'Erro geral em WPGD0124: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END WPGD0124;

-----------------------------------------------------                       
END WPGD0124;
/
