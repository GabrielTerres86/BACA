CREATE OR REPLACE PACKAGE PROGRID.WPGD0126 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0126                     
  --  Sistema  : Rotinas para tela de Cadastro de Contatos do Progrid(WPGD0126)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Contatos do Progrid(WPGD0126)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0126
  PROCEDURE wpgd0126(pr_nrseqfea IN crapfea.nrseqfea%TYPE --> Codigo do Facilitador
                    ,pr_cdcooper IN crapfea.cdcooper%TYPE --> Cooperativa do Contato
                    ,pr_nmrescop IN crapcop.nmrescop%TYPE --> Nome da Cooperativa Busca
                    ,pr_nmfacili IN crapfea.nmfacili%TYPE --> Nome do Facilitador
                    ,pr_dscarfea IN crapfea.dscarfea%TYPE --> Cargo do Facilitador
                    ,pr_nrdddfea IN crapfea.nrdddfea%TYPE --> DDD Telefone de contato
                    ,pr_nrtelfea IN crapfea.nrtelfea%TYPE --> Telefone de contato
                    ,pr_idsitfea IN crapfea.idsitfea%TYPE --> Situacao do Facilitador(0-Inativo/1-Ativo)
                    ,pr_dssitfea IN VARCHAR2              --> Descricao de Situacao do Facilitador
                    ,pr_nriniseq IN PLS_INTEGER           --> Registro inicial para pesquisa
                    ,pr_qtregist IN PLS_INTEGER           --> Quantidade de registros por pesquisa
                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                    ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
  
END WPGD0126;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0126 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0126
  --  Sistema  : Rotinas para tela de Cadastro de Facilitadores de Assembleias(WPGD0126)
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Marco/2017.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Facilitadores de Assembleis (WPGD0126)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE wpgd0126(pr_nrseqfea IN crapfea.nrseqfea%TYPE --> Codigo do Facilitador
                    ,pr_cdcooper IN crapfea.cdcooper%TYPE --> Cooperativa do Contato
                    ,pr_nmrescop IN crapcop.nmrescop%TYPE --> Nome da Cooperativa Busca
                    ,pr_nmfacili IN crapfea.nmfacili%TYPE --> Nome do Facilitador
                    ,pr_dscarfea IN crapfea.dscarfea%TYPE --> Cargo do Facilitador
                    ,pr_nrdddfea IN crapfea.nrdddfea%TYPE --> DDD Telefone de contato
                    ,pr_nrtelfea IN crapfea.nrtelfea%TYPE --> Telefone de contato
                    ,pr_idsitfea IN crapfea.idsitfea%TYPE --> Situacao do Facilitador(0-Inativo/1-Ativo)
                    ,pr_dssitfea IN VARCHAR2              --> Descricao de Situacao do Facilitador
                    ,pr_nriniseq IN PLS_INTEGER           --> Registro inicial para pesquisa
                    ,pr_qtregist IN PLS_INTEGER           --> Quantidade de registros por pesquisa
                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                    ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro

      -- CURSORES             
      CURSOR cr_crapfea IS
        SELECT fea.nrseqfea
              ,fea.cdcooper
              ,cop.nmrescop
              ,fea.nmfacili
              ,fea.dscarfea
              ,fea.nrdddfea
              ,fea.nrtelfea
              ,TRIM('(' || fea.nrdddfea || ') ' || GENE0002.fn_mask(fea.nrtelfea,'zzzzz-zzzz')) AS dstelefo
              ,fea.idsitfea
              ,DECODE(fea.idsitfea,0,'INATIVO',1,'ATIVO') AS dssitfea
              ,ROW_NUMBER() OVER(ORDER BY 1, 2, 3, 4 DESC) nrdseque
          FROM crapfea fea
              ,crapcop cop
         WHERE fea.cdcooper = cop.cdcooper
           AND fea.nrseqfea = NVL(pr_nrseqfea, fea.nrseqfea)
           AND UPPER(cop.nmrescop) LIKE '%' || UPPER(pr_nmrescop) || '%'
           AND UPPER(fea.nmfacili) LIKE '%' || UPPER(pr_nmfacili) || '%'
           AND DECODE(fea.idsitfea,1,'ATIVO',0,'INATIVO',NULL) LIKE '%' || UPPER(pr_dssitfea) || '%'
         ORDER BY 3,4,5;

      rw_crapfea cr_crapfea%ROWTYPE;
      
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
      vr_existe_evento  NUMBER:=0;

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
          BEGIN
            UPDATE crapfea
               SET crapfea.cdcooper = pr_cdcooper
                  ,crapfea.nmfacili = UPPER(pr_nmfacili)
                  ,crapfea.dscarfea = UPPER(pr_dscarfea)
                  ,crapfea.nrdddfea = pr_nrdddfea
                  ,crapfea.nrtelfea = pr_nrtelfea
                  ,crapfea.idsitfea = pr_idsitfea
                  ,crapfea.cdcopope = vr_cdcooper
                  ,crapfea.cdoperad = vr_cdoperad
                  ,crapfea.cdprogra = vr_nmdatela
                  ,crapfea.dtatuali = SYSDATE
             WHERE crapfea.nrseqfea = pr_nrseqfea;

             IF SQL%ROWCOUNT = 0 THEN
               BEGIN
                 INSERT INTO crapfea(nrseqfea,cdcooper, nmfacili, dscarfea, nrdddfea, nrtelfea, idsitfea, cdcopope, cdoperad, cdprogra, dtatuali)
                   VALUES(CRAPFEA_SEQ.NEXTVAL,pr_cdcooper,UPPER(pr_nmfacili),UPPER(pr_dscarfea),pr_nrdddfea,pr_nrtelfea,pr_idsitfea,vr_cdcooper,vr_cdoperad,vr_nmdatela,SYSDATE);
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_dscritic := 'Erro ao cadastrar Facilitador.Erro:' || SQLERRM;
                   RAISE vr_exc_saida;
               END;
             END IF;              

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar de facilitador. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

          FOR rw_crapfea IN cr_crapfea LOOP
                     
            IF ((pr_nriniseq <= rw_crapfea.nrdseque) AND (rw_crapfea.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                   
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqfea', pr_tag_cont => rw_crapfea.nrseqfea, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapfea.cdcooper, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapfea.nmrescop, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmfacili', pr_tag_cont => rw_crapfea.nmfacili, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dscarfea', pr_tag_cont => rw_crapfea.dscarfea, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdddfea', pr_tag_cont => rw_crapfea.nrdddfea, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrtelfea', pr_tag_cont => rw_crapfea.nrtelfea, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dstelefo', pr_tag_cont => rw_crapfea.dstelefo, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idsitfea', pr_tag_cont => rw_crapfea.idsitfea, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dssitfea', pr_tag_cont => rw_crapfea.dssitfea, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdseque', pr_tag_cont => rw_crapfea.nrdseque, pr_des_erro => vr_dscritic);
              vr_contador := vr_contador + 1;
            END IF;

            vr_totregis := vr_totregis +1;

          END LOOP;

          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

      WHEN 'E' THEN -- Exclusao
        --Evento
          BEGIN
            SELECT 1
              INTO vr_existe_evento
              FROM crapadp adp
               WHERE adp.nrseqfea = pr_nrseqfea
                 AND rownum = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              vr_existe_evento:=0;
          END;        

          -- Verifica se existe evento associado ao programa
          IF vr_existe_evento = 1 THEN
            vr_dscritic := 'Exclusão não permitida. Este Facilitador esta associado a um evento.' ;
            RAISE vr_exc_saida; 
          ELSE
            BEGIN
              DELETE
                FROM crapfea
               WHERE crapfea.nrseqfea = pr_nrseqfea;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao excluir registro(CRAPFEA). Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;
        
      WHEN 'I' THEN -- Inclusao
        BEGIN
          INSERT INTO crapfea(cdcooper, nmfacili, dscarfea, nrdddfea, nrtelfea, idsitfea, cdcopope, cdoperad, cdprogra, dtatuali)
            VALUES(pr_cdcooper,UPPER(pr_nmfacili),UPPER(pr_dscarfea),pr_nrdddfea,pr_nrtelfea,pr_idsitfea,vr_cdcooper,vr_cdoperad,vr_nmdatela,SYSDATE);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao cadastrar Facilitador.Erro:' || SQLERRM;
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
        pr_dscritic := 'Erro geral em wpgd0126: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END wpgd0126;

END WPGD0126;
/
