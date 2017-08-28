CREATE OR REPLACE PACKAGE PROGRID.WPGD0118 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0118                     
  --  Sistema  : Rotinas para tela de Cadastro de Contatos do Progrid(WPGD0118)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Contatos do Progrid(WPGD0118)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0107 para aba RECURSO
  PROCEDURE pc_wpgd0118(pr_cdcooper IN craprcp.cdcoprcp%TYPE --> Cooperativa do Contato
                       ,pr_cdagenci IN craprcp.cdagenci%TYPE --> PA do Contato
                       ,pr_nmrespgd IN craprcp.nmrespgd%TYPE --> Nome do Responsavel pelo Progrid
                       ,pr_nmctopla IN craprcp.nmctopla%TYPE --> Nome do Contato de Plantao
                       ,pr_nrdddct1 IN craprcp.nrdddct1%TYPE --> DDD primeiro telefone de contato
                       ,pr_nrtelct1 IN craprcp.nrtelct1%TYPE --> Numero primeiro telefone de contato
                       ,pr_nrdddct2 IN craprcp.nrdddct2%TYPE --> DDD segundo telefone de contato
                       ,pr_nrtelct2 IN craprcp.nrtelct2%TYPE --> Numero segundo telefone de contato
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
  
END WPGD0118;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0118 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0118
  --  Sistema  : Rotinas para tela de Cadastro de Contatos do Progrid(WPGD0118)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Contatos do Progrid(WPGD0118)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral de insert, update, select e delete da tela WPGD0118
  PROCEDURE pc_wpgd0118(pr_cdcooper IN craprcp.cdcoprcp%TYPE --> Cooperativa do Contato
                       ,pr_cdagenci IN craprcp.cdagenci%TYPE --> PA do Contato
                       ,pr_nmrespgd IN craprcp.nmrespgd%TYPE --> Nome do Responsavel pelo Progrid
                       ,pr_nmctopla IN craprcp.nmctopla%TYPE --> Nome do Contato de Plantao
                       ,pr_nrdddct1 IN craprcp.nrdddct1%TYPE --> DDD primeiro telefone de contato
                       ,pr_nrtelct1 IN craprcp.nrtelct1%TYPE --> Numero primeiro telefone de contato
                       ,pr_nrdddct2 IN craprcp.nrdddct2%TYPE --> DDD segundo telefone de contato
                       ,pr_nrtelct2 IN craprcp.nrtelct2%TYPE --> Numero segundo telefone de contato
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
      -- Consulta de contatos do progrid
      CURSOR cr_craprcp(pr_cdcooper IN craprcp.cdcoprcp%TYPE
                       ,pr_cdagenci IN craprcp.cdagenci%TYPE
                       ,pr_nmrescop IN crapcop.nmrescop%TYPE                      
                       ,pr_nmresage IN crapage.nmresage%TYPE) IS
        SELECT rcp.cdcoprcp         AS cdcoprcp
              ,cop.nmrescop         AS nmrescop
              ,rcp.cdagenci         AS cdagenci
              ,age.nmresage         AS nmresage
              ,rcp.nmrespgd         AS nmrespgd
              ,rcp.nmctopla         AS nmctopla
              ,rcp.nrdddct1         AS nrdddct1
              ,rcp.nrtelct1         AS nrtelct1
              ,rcp.nrdddct2         AS nrdddct2
              ,rcp.nrtelct2         AS nrtelct2
              ,rcp.cdoperad         AS cdoperad
              ,rcp.cdprogra         AS cdprogra
              ,rcp.dtatuali         AS dtatuali
              ,rcp.progress_recid   AS progress_recid
              ,ROW_NUMBER() OVER(ORDER BY cop.nmrescop, age.nmresage) AS nrdseque
         FROM craprcp rcp,
              crapcop cop,
              crapage age
        WHERE (rcp.cdcoprcp = pr_cdcooper OR NVL(pr_cdcooper,0) = 0)
          AND (rcp.cdagenci = pr_cdagenci OR NVL(pr_cdagenci,0) = 0)
          AND cop.cdcooper = rcp.cdcoprcp
          AND age.cdcooper = cop.cdcooper
          AND age.cdagenci = rcp.cdagenci
          AND UPPER(age.nmresage) LIKE (UPPER(TRIM(pr_nmresage)))
          AND UPPER(cop.nmrescop) LIKE (UPPER(TRIM(pr_nmrescop)))
      ORDER BY cop.nmrescop, age.nmresage;
   
      rw_craprcp cr_craprcp%ROWTYPE;

      -- Consulta de PA por cooperativas
      CURSOR cr_crapage IS
        SELECT age.cdcooper
              ,age.cdagenci 
              ,age.nmresage
         FROM crapage age
        WHERE age.cdcooper = NVL(pr_cdcooper,age.cdcooper)
          AND (age.cdagenci = pr_cdagenci OR pr_cdagenci = 0)
          AND age.cdagenci NOT IN(90,91)
          AND age.flgdopgd = 1
          AND age.insitage IN (1,3) -- 1-Ativo ou 3-Temporariamente Indisponivel
      ORDER BY age.cdcooper, age.nmresage;

      rw_crapage cr_crapage%ROWTYPE;

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
          IF pr_cdagenci = 0 THEN
            -- Loop sobre os PA's
            FOR rw_crapage IN cr_crapage LOOP
              BEGIN
                UPDATE craprcp
                   SET nmrespgd = pr_nmrespgd
                      ,nmctopla = pr_nmctopla
                      ,nrdddct1 = pr_nrdddct1
                      ,nrtelct1 = pr_nrtelct1
                      ,nrdddct2 = pr_nrdddct2
                      ,nrtelct2 = pr_nrtelct2
                      ,cdoperad = vr_cdoperad
                      ,cdcopope = vr_cdcooper
                      ,cdprogra = UPPER(vr_nmdatela)
                      ,dtatuali = SYSDATE
                 WHERE craprcp.cdcoprcp = pr_cdcooper
                   AND craprcp.cdagenci = rw_crapage.cdagenci
                   ;
                             
                IF SQL%ROWCOUNT = 0 THEN
                   BEGIN
                      INSERT INTO
                          craprcp(cdcoprcp
                                 ,cdagenci
                                 ,nmrespgd
                                 ,nmctopla
                                 ,nrdddct1
                                 ,nrtelct1
                                 ,nrdddct2
                                 ,nrtelct2
                                 ,cdoperad
                                 ,cdcopope
                                 ,cdprogra
                                 ,dtatuali
                          )VALUES(pr_cdcooper
                                 ,rw_crapage.cdagenci
                                 ,pr_nmrespgd
                                 ,pr_nmctopla
                                 ,pr_nrdddct1
                                 ,pr_nrtelct1
                                 ,pr_nrdddct2
                                 ,pr_nrtelct2
                                 ,vr_cdoperad
                                 ,vr_cdcooper
                                 ,UPPER(vr_nmdatela)
                                 ,SYSDATE);
                                                 
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao inserir registro(CRAPRCP), PA: ' || UPPER(TO_CHAR(rw_crapage.nmresage)) || '. Erro: ' || SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                END IF;

              EXCEPTION
                WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar registro(CRAPRCP). PA: ' || TO_CHAR(rw_crapage.cdagenci) || '. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
              END;
            END LOOP;
          ELSE
            BEGIN
              UPDATE craprcp
                   SET nmrespgd = pr_nmrespgd
                      ,nmctopla = pr_nmctopla
                      ,nrdddct1 = pr_nrdddct1
                      ,nrtelct1 = pr_nrtelct1
                      ,nrdddct2 = pr_nrdddct2
                      ,nrtelct2 = pr_nrtelct2
                      ,cdoperad = vr_cdoperad
                      ,cdprogra = UPPER(vr_nmdatela)
                      ,dtatuali = SYSDATE
                      ,cdcopope = vr_cdcooper
                 WHERE craprcp.cdcoprcp = pr_cdcooper
                   AND craprcp.cdagenci = pr_cdagenci;
                           
              IF SQL%ROWCOUNT = 0 THEN
                 BEGIN
                    INSERT INTO
                          craprcp(cdcoprcp
                                 ,cdagenci
                                 ,nmrespgd
                                 ,nmctopla
                                 ,nrdddct1
                                 ,nrtelct1
                                 ,nrdddct2
                                 ,nrtelct2
                                 ,cdoperad
                                 ,cdcopope
                                 ,cdprogra
                                 ,dtatuali
                          )VALUES(pr_cdcooper
                                 ,pr_cdagenci
                                 ,pr_nmrespgd
                                 ,pr_nmctopla
                                 ,pr_nrdddct1
                                 ,pr_nrtelct1
                                 ,pr_nrdddct2
                                 ,pr_nrtelct2
                                 ,vr_cdoperad
                                 ,vr_cdcooper
                                 ,UPPER(vr_nmdatela)
                                 ,SYSDATE);
                                               
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir registro(CRAPRCP). Erro: ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END IF;

            EXCEPTION
              WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar registro(CRAPRCP). PA: ' || TO_CHAR(pr_cdagenci) || 'Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
            END;
          END IF;
          NULL;
        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

          FOR rw_craprcp IN cr_craprcp(pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_nmrescop => '%'||pr_nmrescop||'%'
                                      ,pr_nmresage => '%'||pr_nmresage||'%') LOOP
                     
            IF ((pr_nriniseq <= rw_craprcp.nrdseque) AND (rw_craprcp.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                   
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_craprcp.cdcoprcp, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => UPPER(rw_craprcp.nmrescop), pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_craprcp.cdagenci, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmresage', pr_tag_cont => UPPER(rw_craprcp.nmresage), pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrespgd', pr_tag_cont => rw_craprcp.nmrespgd, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmctopla', pr_tag_cont => rw_craprcp.nmctopla, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdddct1', pr_tag_cont => rw_craprcp.nrdddct1, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrtelct1', pr_tag_cont => TRIM(GENE0002.fn_mask(rw_craprcp.nrtelct1,'zzzzz-zzzz')), pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdddct2', pr_tag_cont => rw_craprcp.nrdddct2, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrtelct2', pr_tag_cont => TRIM(GENE0002.fn_mask(rw_craprcp.nrtelct2,'zzzzz-zzzz')), pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'numtele1', pr_tag_cont => TRIM(GENE0002.fn_mask(rw_craprcp.nrdddct1,'zz') || ' ' || GENE0002.fn_mask(rw_craprcp.nrtelct1,'zzzzz-zzzz')), pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'numtele2', pr_tag_cont => TRIM(GENE0002.fn_mask(rw_craprcp.nrdddct2,'zz') || ' ' || GENE0002.fn_mask(rw_craprcp.nrtelct2,'zzzzz-zzzz')), pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_craprcp.cdoperad, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra', pr_tag_cont => rw_craprcp.cdprogra, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali', pr_tag_cont => rw_craprcp.dtatuali, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdseque', pr_tag_cont => rw_craprcp.nrdseque, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'progress_recid', pr_tag_cont => rw_craprcp.progress_recid, pr_des_erro => vr_dscritic);
              vr_contador := vr_contador + 1;
            END IF;

            vr_totregis := vr_totregis +1;

          END LOOP;

          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

      WHEN 'E' THEN -- Exclusao
        BEGIN
          DELETE
            FROM craprcp
           WHERE craprcp.cdcoprcp = pr_cdcooper
             AND craprcp.cdagenci = pr_cdagenci;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPRCP). Erro: ' || SQLERRM;
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
        pr_dscritic := 'Erro geral em PC_WPGD0118: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_wpgd0118;

END WPGD0118;
/
