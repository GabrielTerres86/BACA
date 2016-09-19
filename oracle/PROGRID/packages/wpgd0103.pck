CREATE OR REPLACE PACKAGE PROGRID.WPGD0103 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0103                     
  --  Sistema  : Rotinas para Parceiros Institucionais
  --  Sigla    : WPGD
  --  Autor    : Márcio José de Carvalho (RKAM)
  --  Data     : Maio/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Parceiros Institucionais
  --
  -- Alteracoes:   
  --
  ---------------------------------------------------------------------------------------------------------------


  -- Rotina geral de insert, update, select e delete da tela WPGD0103 na tabela crappri
  PROCEDURE pc_crappri(pr_cddopcao       IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqpri       IN crappri.nrseqpri%TYPE -->Sequencia de digitacao da Parceria Institucional
                      ,pr_nmprcins       IN crappri.nmprcins%TYPE -->Descrição da Parceria Institucional
                      ,pr_idsitpri       IN crappri.idsitpri%TYPE --> Situaçãoda parceria institucional
                      ,pr_nriniseq       IN PLS_INTEGER 
                      ,pr_qtregist       IN PLS_INTEGER 
                      ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro       OUT VARCHAR2);

END WPGD0103;
/

CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0103 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0103                     
  --  Sistema  : Rotinas para Parceiros Institucionais
  --  Sigla    : WPGD
  --  Autor    : Márcio José de Carvalho (RKAM)
  --  Data     : Maio/2015.                   Ultima atualizacao:  24/06/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Parceiros Institucionais
  --
  -- Alteracoes:  24/06/2015 - Ajustes para paginação e pesquisa (Vanessa)
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Rotina geral de insert, update, select e delete da tela WPGD0102 na tabela crappri
  PROCEDURE pc_crappri(pr_cddopcao       IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqpri       IN crappri.nrseqpri%TYPE -->Sequencia de digitacao da Parceria Institucional
                      ,pr_nmprcins       IN crappri.nmprcins%TYPE -->Descrição da Parceria Institucional
                      ,pr_idsitpri       IN crappri.idsitpri%TYPE --> Situaçãoda parceria institucional
                      ,pr_nriniseq       IN PLS_INTEGER 
                      ,pr_qtregist       IN PLS_INTEGER 
                      ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro       OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor sobre a tabela de temas
      CURSOR cr_crappri IS
         SELECT nrseqpri,
               UPPER(nmprcins) nmprcins,
               DECODE(pri.idsitpri, 'A', 'ATIVO', 'I', 'INATIVO', NULL) IDSITPRI,
               pri.cdoperad,
               pri.cdprogra,
               pri.dtatuali,
               ROW_NUMBER() OVER(ORDER BY 1, 2, 3, 4 DESC) nrdseque
          FROM crappri pri
         WHERE nrseqpri = NVL(pr_nrseqpri, nrseqpri)
           AND DECODE(pri.idsitpri, 'A', 'ATIVO', 'I', 'INATIVO', NULL) LIKE UPPER(pr_idsitpri) || '%' 
           AND UPPER(nmprcins) LIKE '%' || UPPER(pr_nmprcins) || '%'
         ORDER BY 1, 2, 3, 4 DESC;
                 
                 
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

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
      vr_nrseqpri crappri.nrseqpri%TYPE;
      VR_POSICAO  NUMBER:=0;
      VR_EXISTE_SUGESTAO  NUMBER:=0;
      VR_EXISTE_EVENTO  NUMBER:=0;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
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
      CASE pr_cddopcao

        WHEN 'A' THEN -- Alteracao
          BEGIN
            -- Atualizacao de registro de Parceiro Institucional
            UPDATE crappri
               SET 
                  nmprcins = pr_nmprcins,
                  idsitpri = pr_idsitpri,
                  cdoperad = vr_cdoperad,
                  cdprogra = vr_nmdatela,
                  dtatuali = sysdate
             WHERE nrseqpri = pr_nrseqpri;

          -- Verifica se houve problema na atualizacao do registro
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar crappri: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;

        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
           -- Loop sobre os Parceiros Institucionais do Progrid
          FOR rw_crappri IN cr_crappri LOOP
              IF ((pr_nriniseq <= rw_crappri.nrdseque)AND (rw_crappri.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqpri'      , pr_tag_cont => rw_crappri.nrseqpri                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmprcins'      , pr_tag_cont => rw_crappri.nmprcins                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idsitpri'      , pr_tag_cont => rw_crappri.idsitpri                       , pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad'      , pr_tag_cont => rw_crappri.cdoperad                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra'      , pr_tag_cont => rw_crappri.cdprogra                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali'      , pr_tag_cont => to_char(rw_crappri.dtatuali,'dd/mm/yyyy') , pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrsequen'      , pr_tag_cont => rw_crappri.nrdseque                            , pr_des_erro => vr_dscritic);  
                vr_contador := vr_contador + 1;
             END IF;
             vr_totregis := vr_totregis +1;    
          END LOOP;
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis'   , pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);           

        WHEN 'E' THEN -- Exclusao

          -- Efetua a exclusao do Parceiro Institucional
          --Validar se o tema não está associado a um evento ou sugestão .
          --Sugestao
          BEGIN
            SELECT 
                   1
              INTO 
                   VR_EXISTE_SUGESTAO
              FROM 
                   CRAPSDP CS
               WHERE 
                   CS.NRSEQPRI = pr_nrseqpri
                 AND ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VR_EXISTE_SUGESTAO:=0;
          END;
          --Evento
          BEGIN
            SELECT 
                   1
              INTO 
                   VR_EXISTE_EVENTO
              FROM 
                   CRAPEDP CE
               WHERE 
                   CE.NRSEQPRI = pr_nrseqpri
                 AND ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VR_EXISTE_EVENTO:=0;
          END;        
          --
          IF VR_EXISTE_SUGESTAO = 1 THEN
            vr_dscritic := 'Exclusao nao permitida. Esta Parceria Institucional esta associada a uma sugestao' ;
            RAISE vr_exc_saida;              
          ELSIF VR_EXISTE_EVENTO = 1 THEN
            vr_dscritic := 'Exclusao nao permitida. Esta Parceria Institucional esta associada a um evento' ;
            RAISE vr_exc_saida;             
          ELSE
            BEGIN
              DELETE crappri
               WHERE nrseqpri = pr_nrseqpri;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na exclusao de registros
                vr_dscritic := 'Erro ao excluir a Parceria Institucional.'||sqlerrm ;
                RAISE vr_exc_saida;
            END;
          END IF;

        WHEN 'I' THEN -- Inclusao
          -- Efetua a inclusao no cadastro de Parceiro Institucional
          vr_nrseqpri:=fn_sequence(pr_nmtabela => 'CRAPPRI', pr_nmdcampo => 'NRSEQPRI',pr_dsdchave => '0');
          BEGIN
            INSERT INTO crappri
                 (nrseqpri       ,
                  nmprcins       ,
                  idsitpri       ,
                  cdoperad       ,
                  cdprogra       ,
                  dtatuali                      
                  )
              VALUES
                 (vr_nrseqpri,
                  UPPER(pr_nmprcins),
                  pr_idsitpri,
                  vr_cdoperad,
                  vr_nmdatela,
                  sysdate                      
                  );

          -- Verifica se houve problema na insercao de registros
          EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Atencao: Este parceiro institucional já foi cadastrado. Favor verificar!';
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao inserir crappri: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;
            
          -- Retorna a sequencia criada
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><nrseqpri>' || vr_nrseqpri || '</nrseqpri></Root>');

      END CASE;

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
        pr_dscritic := 'Erro geral em crappri: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_crappri;

-----------------------------------------------------                       
END WPGD0103;
/

