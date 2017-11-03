CREATE OR REPLACE PACKAGE PROGRID.WPGD0130 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0130
  --  Sistema  : Rotinas para tela de Programas do Progrid
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Fevereiro/2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Programas do Progrid WPGD0130
  --
  -- Alteracoes:   
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral da tela WPGD0130
  PROCEDURE WPGD0130(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                    ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo do PA
                    ,pr_dtanoage IN crapadp.dtanoage%TYPE --> Ano da Agenda
                    ,pr_listaeve IN VARCHAR2              --> Listagem de Eventos Aprovados e Reprovados
                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                    ,pr_des_erro OUT VARCHAR2);           --> Descricao do erro

END WPGD0130;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0130 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0130
  --  Sistema  : Rotinas para Programas do Progrid WPGD0130
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
  
  -- Rotina geral da tela WPGD0130
  PROCEDURE WPGD0130(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                    ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo do PA
                    ,pr_dtanoage IN crapadp.dtanoage%TYPE --> Ano da Agenda
                    ,pr_listaeve IN VARCHAR2              --> Listagem de Eventos Aprovados e Reprovados
                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                    ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do erro

      CURSOR cr_crapsie(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_cdagenci crapage.cdagenci%TYPE
                       ,pr_dtanoage crapadp.dtanoage%TYPE) IS
        SELECT c.nrsdipro AS nrsdipro
              ,ce1.nmevento||' - '||ca1.dtinieve||' - '||ca1.dshroeve AS nmsdipro
              ,c.nrsdiass AS nrsdiass
              ,ce2.nmevento||' - '||ca2.dtinieve||' - '||ca2.dshroeve AS nmsdiass
        FROM crapsie c,
             crapadp ca1,  -- Dados do Evento Progrid
             crapedp ce1,  -- Pegar nome do evento do Progrid
             crapadp ca2,  -- Dados do Evento Assemblear
             crapedp ce2   -- Pegar nome do evento do Assemblear
        WHERE c.idsitsol = 1 -- Pendente de análise
          AND ca1.nrseqdig = c.nrsdipro
          AND ca1.dtanoage = pr_dtanoage -- Parâmetro da tela
          AND ca1.cdcooper = pr_cdcooper -- Parâmetro da tela
          AND (ca1.cdagenci = pr_cdagenci OR pr_cdagenci = 0) -- Parâmetro da tela
          AND ce1.idevento = ca1.idevento
          AND ce1.cdcooper = ca1.cdcooper
          AND ce1.dtanoage = ca1.dtanoage
          AND ce1.cdevento = ca1.cdevento
          AND ca2.nrseqdig = c.nrsdiass
          AND ca2.dtanoage = pr_dtanoage -- Parâmetro da tela
          AND ca2.cdcooper = pr_cdcooper    -- Parâmetro da tela
          AND (ca2.cdagenci = pr_cdagenci OR pr_cdagenci = 0)  -- Parâmetro da tela
          AND ce2.idevento = ca2.idevento
          AND ce2.cdcooper = ca2.cdcooper
          AND ce2.dtanoage = ca2.dtanoage
          AND ce2.cdevento = ca2.cdevento
          ORDER BY 2;
      
      rw_crapsie cr_crapsie%ROWTYPE;

      CURSOR cr_crapadp(pr_idevento crapadp.idevento%TYPE
                       ,pr_cdcooper crapadp.cdcooper%TYPE
                       ,pr_nrseqdig crapadp.nrseqdig%TYPE) IS

        SELECT adp.idstaeve AS idstaeve
              ,edp.nmevento||' - '||adp.dtinieve||' - '||adp.dshroeve AS nmevento
              ,adp.cdevento
          FROM crapadp adp
              ,crapedp edp
         WHERE adp.idevento = pr_idevento
           AND edp.idevento = adp.idevento
           AND edp.cdcooper = adp.cdcooper
           AND edp.dtanoage = adp.dtanoage
           AND edp.cdevento = adp.cdevento
           AND adp.cdcooper = pr_cdcooper
           AND adp.nrseqdig = pr_nrseqdig;

      rw_crapadp cr_crapadp%ROWTYPE; 
      
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

      vr_contador INTEGER := 0;
      vr_nrsdipro crapsie.nrsdipro%TYPE := 0;
      vr_nrsdiass crapsie.nrsdiass%TYPE := 0;
      vr_idsitsol crapsie.idsitsol%TYPE := 0;

      vr_vet_eve gene0002.typ_split; -- Vetor Eventos
      vr_vet_eve_dados gene0002.typ_split; -- Vetor Dados Eventos

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
    
      IF UPPER(vr_cddopcao) = 'C' THEN
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');  
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'Registros', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        
        FOR rw_crapsie IN cr_crapsie(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_dtanoage => pr_dtanoage) LOOP                          
             gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Registros', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
             gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf'  , pr_posicao => vr_contador, pr_tag_nova => 'nrsdipro', pr_tag_cont => rw_crapsie.nrsdipro, pr_des_erro => vr_dscritic);
             gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf'  , pr_posicao => vr_contador, pr_tag_nova => 'nmsdipro', pr_tag_cont => rw_crapsie.nmsdipro, pr_des_erro => vr_dscritic);
             gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf'  , pr_posicao => vr_contador, pr_tag_nova => 'nrsdiass', pr_tag_cont => rw_crapsie.nrsdiass, pr_des_erro => vr_dscritic);
             gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf'  , pr_posicao => vr_contador, pr_tag_nova => 'nmsdiass', pr_tag_cont => rw_crapsie.nmsdiass, pr_des_erro => vr_dscritic);
             vr_contador := vr_contador + 1;
         END LOOP;
                    
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_contador, pr_des_erro => vr_dscritic);
         
      ELSIF UPPER(vr_cddopcao) = 'A' THEN
        
        vr_vet_eve := gene0002.fn_quebra_string(pr_listaeve, '|');    
        -- Varrre os eventos
        FOR i IN 1 .. vr_vet_eve.COUNT LOOP
          vr_vet_eve_dados := gene0002.fn_quebra_string(vr_vet_eve(i), ';');
          
          vr_nrsdipro := vr_vet_eve_dados(1);
          vr_nrsdiass := vr_vet_eve_dados(2);
          vr_idsitsol := vr_vet_eve_dados(3);

          IF vr_idsitsol = 0 THEN -- REPROVADOS
            
            BEGIN
              UPDATE crapsie
                 SET crapsie.idsitsol = 3 -- Reprovado
                    ,crapsie.dtanalis = SYSDATE
                    ,crapsie.cdcopana = vr_cdcooper
                    ,crapsie.cdopeana = vr_cdoperad
               WHERE crapsie.nrsdipro = vr_nrsdipro
                 AND crapsie.nrsdiass = vr_nrsdiass;
            EXCEPTION     
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar evento. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
               
          ELSIF vr_idsitsol = 1 THEN -- APROVADOS
            
            OPEN cr_crapadp(pr_idevento => 1
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_nrseqdig => vr_nrsdipro);

            FETCH cr_crapadp INTO rw_crapadp;

            IF cr_crapadp%NOTFOUND THEN
              CLOSE cr_crapadp;
              vr_dscritic := 'Erro ao consultar evento(1). Cod. Evento: ' || TO_CHAR(vr_nrsdipro);
              RAISE vr_exc_saida;
            ELSE
              CLOSE cr_crapadp;
            END IF;
                
            IF rw_crapadp.idstaeve <> 4 THEN
              vr_dscritic := 'Evento não esta encerrado. Evento: ' || rw_crapadp.nmevento;
              RAISE vr_exc_saida;
            END IF;

            -- Atualiza registro de evento Assemblear
            BEGIN
              UPDATE crapadp
                   SET crapadp.nrseqint = vr_nrsdipro
                 WHERE crapadp.cdcooper = vr_cdcooper
                   AND crapadp.nrseqdig = vr_nrsdiass;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar evento Assemblear(CRAPADP). Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Atualiza registro de evento Progrid
            BEGIN
              UPDATE crapadp
                   SET crapadp.nrseqint = vr_nrsdiass
                 WHERE crapadp.cdcooper = vr_cdcooper
                   AND crapadp.nrseqdig = vr_nrsdipro;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar evento Progrid(CRAPADP). Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Atualiza registro de análise de evento
            BEGIN
              UPDATE crapsie
                   SET crapsie.idsitsol = 2 -- Aprovado
                      ,crapsie.dtanalis = SYSDATE
                      ,crapsie.cdcopana = vr_cdcooper
                      ,crapsie.cdopeana = vr_cdoperad
                 WHERE crapsie.nrsdipro = vr_nrsdipro
                   AND crapsie.nrsdiass = vr_nrsdiass;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar evento(CRAPSIE). Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            OPEN cr_crapadp(pr_idevento => 2
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_nrseqdig => vr_nrsdiass);

            FETCH cr_crapadp INTO rw_crapadp;

            IF cr_crapadp%NOTFOUND THEN
              CLOSE cr_crapadp;
              vr_dscritic := 'Erro ao consultar evento(2). Cod. Evento: ' || TO_CHAR(vr_nrsdiass);
              RAISE vr_exc_saida;
            ELSE
              CLOSE cr_crapadp;
            END IF;

            -- Efetua cópia de inscrições para o evento
            BEGIN
              INSERT INTO crapidp(
                idevento
               ,cdcooper
               ,cdagenci
               ,dtanoage
               ,cdevento
               ,nrseqdig
               ,nrdconta
               ,cdgraupr
               ,nminseve
               ,dsdemail
               ,nrdddins
               ,nrtelins
               ,dtpreins
               ,dtconins
               ,dsobsins
               ,cdoperad
               ,idseqttl
               ,idstains
               ,tpinseve
               ,flgdispe
               ,qtfaleve
               ,nrseqeve
               ,cdageins
               ,dtemcert
               ,flginsin
               ,dtaltera
               ,cdopinsc
               ,flgimpor
               ,cdopeori
               ,cdageori
               ,dtinsori
               ,cdcopavl
               ,tpctrato
               ,nrctremp
               ,nrcpfcgc
               ,nrficpre)
              (SELECT
                  2
                 ,cdcooper
                 ,cdagenci
                 ,dtanoage
                 ,rw_crapadp.cdevento
                 ,nrseqidp.nextval
                 ,nrdconta
                 ,cdgraupr
                 ,nminseve
                 ,dsdemail
                 ,nrdddins
                 ,nrtelins
                 ,dtpreins
                 ,dtconins
                 ,dsobsins
                 ,cdoperad
                 ,idseqttl
                 ,idstains
                 ,tpinseve
                 ,flgdispe
                 ,qtfaleve
                 ,vr_nrsdiass
                 ,cdageins
                 ,dtemcert
                 ,flginsin
                 ,dtaltera
                 ,cdopinsc
                 ,flgimpor
                 ,cdopeori
                 ,cdageori
                 ,dtinsori
                 ,cdcopavl
                 ,tpctrato
                 ,nrctremp
                 ,nrcpfcgc
                 ,nrficpre
                FROM
                  crapidp
                WHERE crapidp.cdcooper = pr_cdcooper
                  AND crapidp.nrseqeve = vr_nrsdipro);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir registro de inscrição. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
                        
          END IF;

        END LOOP;

      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        
        IF vr_cdcritic > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          pr_dscritic := vr_dscritic;
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;        

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em WPGD0130: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END WPGD0130;

END WPGD0130;
/
