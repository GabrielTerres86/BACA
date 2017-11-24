CREATE OR REPLACE PACKAGE PROGRID.WPGD0122 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0122                     
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


  -- Rotina geral de insert, update, select e delete da tela WPGD0122 na tabela crappgm
  PROCEDURE WPGD0122(pr_cddopcao       IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                    ,pr_nrseqpgm       IN crappgm.nrseqpgm%TYPE -->Sequencia de digitacao da Parceria Institucional
                    ,pr_nmprogra       IN crappgm.nmprogra%TYPE -->Descrição da Parceria Institucional
                    ,pr_idsitpgm       IN VARCHAR2              --> Situaçãoda parceria institucional
                    ,pr_nriniseq       IN PLS_INTEGER           --> Registro inicial de consulta
                    ,pr_qtregist       IN PLS_INTEGER           --> Quantidade de registros por consulta
                    ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                    ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                    ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                    ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                    ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                    ,pr_des_erro       OUT VARCHAR2);           --> Descricao do erro

END WPGD0122;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0122 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0122                     
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
  -- Rotina geral de insert, update, select e delete da tela WPGD0122 na tabela crappgm
  PROCEDURE WPGD0122(pr_cddopcao       IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                    ,pr_nrseqpgm       IN crappgm.nrseqpgm%TYPE -->Sequencia de digitacao da Parceria Institucional
                    ,pr_nmprogra       IN crappgm.nmprogra%TYPE -->Descrição da Parceria Institucional
                    ,pr_idsitpgm       IN VARCHAR2              --> Situaçãoda parceria institucional
                    ,pr_nriniseq       IN PLS_INTEGER           --> Registro inicial de consulta
                    ,pr_qtregist       IN PLS_INTEGER           --> Quantidade de registros por consulta
                    ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                    ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                    ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                    ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                    ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                    ,pr_des_erro       OUT VARCHAR2) IS         --> Descricao do erro

      -- Cursor sobre a tabela de programas do progrid
      CURSOR cr_crappgm(pr_nrseqpgm crappgm.nrseqpgm%TYPE
                       ,pr_nmprogra crappgm.nmprogra%TYPE
                       ,pr_idsitpgm crappgm.nmprogra%TYPE) IS
         SELECT pgm.nrseqpgm,
               UPPER(nmprogra) nmprogra,
               pgm.idsitpgm,
               DECODE(pgm.idsitpgm,1,'ATIVO',0,'INATIVO') dssitpgm,
               pgm.cdoperad,
               pgm.cdprogra,
               pgm.dtatuali,
               ROW_NUMBER() OVER(ORDER BY 2, 3, 4 DESC) nrdseque
          FROM crappgm pgm
         WHERE pgm.nrseqpgm = NVL(pr_nrseqpgm, pgm.nrseqpgm)
           AND UPPER(pgm.nmprogra) LIKE '%' || UPPER(pr_nmprogra) || '%'
           AND DECODE(pgm.idsitpgm, 1, 'ATIVO', 0, 'INATIVO', NULL) LIKE '%' || UPPER(pr_idsitpgm) || '%' 
         ORDER BY 2, 3, 4 DESC;
       
      rw_crappgm cr_crappgm%ROWTYPE;
             
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
      vr_nrseqpgm crappgm.nrseqpgm%TYPE;
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
            UPDATE crappgm
               SET 
                  crappgm.nmprogra = UPPER(pr_nmprogra),
                  crappgm.idsitpgm = TO_NUMBER(pr_idsitpgm),
                  crappgm.cdcopope = vr_cdcooper,
                  crappgm.cdoperad = vr_cdoperad,
                  crappgm.cdprogra = vr_nmdatela,
                  crappgm.dtatuali = SYSDATE
             WHERE crappgm.nrseqpgm = pr_nrseqpgm;

          -- Verifica se houve problema na atualizacao do registro
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar CRAPPGM: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;

        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
           -- Loop sobre os Parceiros Institucionais do Progrid
          FOR rw_crappgm IN cr_crappgm(pr_nrseqpgm => pr_nrseqpgm
                                      ,pr_nmprogra => pr_nmprogra
                                      ,pr_idsitpgm => pr_idsitpgm) LOOP

              IF ((pr_nriniseq <= rw_crappgm.nrdseque) AND (rw_crappgm.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqpgm', pr_tag_cont => rw_crappgm.nrseqpgm                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmprogra', pr_tag_cont => rw_crappgm.nmprogra                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idsitpgm', pr_tag_cont => rw_crappgm.idsitpgm                       , pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dssitpgm', pr_tag_cont => rw_crappgm.dssitpgm                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_crappgm.cdoperad                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra', pr_tag_cont => rw_crappgm.cdprogra                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali', pr_tag_cont => to_char(rw_crappgm.dtatuali,'dd/mm/yyyy') , pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdseque', pr_tag_cont => rw_crappgm.nrdseque                       , pr_des_erro => vr_dscritic);  
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
              FROM crapedp ce
               WHERE ce.nrseqpgm = pr_nrseqpgm
                 AND rownum = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              vr_existe_evento:=0;
          END;        

          -- Verifica se existe evento associado ao programa
          IF vr_existe_evento = 1 THEN
            vr_dscritic := 'Exclusão não permitida. Este Programa do Progrid esta associado a um evento' ;
            RAISE vr_exc_saida;             
          ELSE
            BEGIN
              DELETE crappgm
               WHERE nrseqpgm = pr_nrseqpgm;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na exclusao de registros
                vr_dscritic := 'Erro ao excluir o Programa do Progrid. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;

        WHEN 'I' THEN -- Inclusao

          -- Efetua a inclusao no cadastro de Programa do Progrid
          vr_nrseqpgm := fn_sequence(pr_nmtabela => 'CRAPPGM', pr_nmdcampo => 'NRSEQPGM',pr_dsdchave => '0');

          BEGIN
            INSERT INTO crappgm(nrseqpgm, nmprogra, idsitpgm, cdcopope, cdoperad, cdprogra, dtatuali)
              VALUES(vr_nrseqpgm,UPPER(pr_nmprogra), TO_NUMBER(pr_idsitpgm), vr_cdcooper, vr_cdoperad,vr_nmdatela, SYSDATE);

          -- Verifica se houve problema na insercao de registros
          EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Atencão: Este Programa do Progrid já foi cadastrado. Favor verificar!';
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao inserir CRAPPGM: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;
            
          -- Retorna a sequencia criada
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><nrseqpgm>' || TO_CHAR(vr_nrseqpgm) || '</nrseqpgm></Root>');

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
        pr_dscritic := 'Erro geral em WPGD0122: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END WPGD0122;

-----------------------------------------------------                       
END WPGD0122;
/
