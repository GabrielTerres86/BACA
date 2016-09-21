CREATE OR REPLACE PACKAGE PROGRID.WPGD0108 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0108
  --  Sistema  : Rotinas para Publico Alvo
  --  Sigla    : WPGD
  --  Autor    : Carlos Rafael Tanholi (CECRED)
  --  Data     : Novembro/2015.                   Ultima atualizacao:  25/11/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Publico Alvo
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_crappap(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa logada
                      ,pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqpap IN crappap.nrseqpap%TYPE --> Sequencia de digitacao do Publico Alvo
                      ,pr_dspubalv IN crappap.dspubalv%TYPE --> Descrição do Publico Alvo
                      ,pr_nriniseq IN PLS_INTEGER 
                      ,pr_qtregist IN PLS_INTEGER 
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2);

END WPGD0108;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0108 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0108
  --  Sistema  : Rotinas para Publico Alvo
  --  Sigla    : WPGD
  --  Autor    : Carlos Rafael Tanholi (CECRED)
  --  Data     : Novembro/2015.                   Ultima atualizacao:  25/11/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Publico Alvo
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0108 na tabela CRAPPAP
  PROCEDURE pc_crappap(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa logada
                      ,pr_cddopcao       IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqpap       IN crappap.nrseqpap%TYPE --> Sequencia de digitacao do Publico Alvo
                      ,pr_dspubalv       IN crappap.dspubalv%TYPE --> Descrição do Publico Alvo
                      ,pr_nriniseq       IN PLS_INTEGER 
                      ,pr_qtregist       IN PLS_INTEGER 
                      ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro       OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor sobre a tabela de temas
      CURSOR cr_crappap IS
      SELECT pap.nrseqpap,
             UPPER(pap.dspubalv) dspubalv,
             pap.cdoperad,
             pap.cdprogra,
             pap.dtatuali,
             ROW_NUMBER() OVER(ORDER BY 1, 2, 3, 4 DESC) nrdseque
        FROM crappap pap
       WHERE nrseqpap = NVL(pr_nrseqpap, nrseqpap)
         AND UPPER(dspubalv) LIKE '%' || UPPER(pr_dspubalv) || '%'
    ORDER BY 2, 1, 3, 4 DESC;
                 
                 
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
      vr_nrseqpap crappap.nrseqpap%TYPE;
      VR_EXISTE_PROPOSTA  NUMBER:=0;

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
            UPDATE crappap
               SET dspubalv = pr_dspubalv,
                   cdoperad = vr_cdoperad,
                   cdprogra = vr_nmdatela,
                   dtatuali = SYSDATE,
                   cdcopope = pr_cdcooper
             WHERE nrseqpap = pr_nrseqpap;

          -- Verifica se houve problema na atualizacao do registro
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar crappap: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;

        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
           -- Loop sobre os Parceiros Institucionais do Progrid
          FOR rw_crappap IN cr_crappap LOOP
              IF ((pr_nriniseq <= rw_crappap.nrdseque)AND (rw_crappap.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqpap'      , pr_tag_cont => rw_crappap.nrseqpap                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dspubalv'      , pr_tag_cont => rw_crappap.dspubalv                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad'      , pr_tag_cont => rw_crappap.cdoperad                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra'      , pr_tag_cont => rw_crappap.cdprogra                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali'      , pr_tag_cont => to_char(rw_crappap.dtatuali,'dd/mm/yyyy') , pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrsequen'      , pr_tag_cont => rw_crappap.nrdseque                       , pr_des_erro => vr_dscritic);  
                vr_contador := vr_contador + 1;
             END IF;
             vr_totregis := vr_totregis +1;    
          END LOOP;
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis'   , pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);           

        WHEN 'E' THEN -- Exclusao

          -- Efetua a exclusao do Publico Alvo
          --Validar se o publico alvo está associado a uma proposta de fornecedor.
          BEGIN
            SELECT 
                   1
              INTO 
                   VR_EXISTE_PROPOSTA
              FROM 
                   GNAPPDP PDP
               WHERE 
                   PDP.NRSEQPAP = pr_nrseqpap
                 AND ROWNUM = 1;
                 
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VR_EXISTE_PROPOSTA := 0;
          END;

          IF VR_EXISTE_PROPOSTA = 1 THEN
            vr_dscritic := 'Exclusão não permitida. Este público alvo esta associado a uma proposta de fornecedor.';
            RAISE vr_exc_saida;         
          ELSE
            BEGIN
              DELETE crappap
               WHERE nrseqpap = pr_nrseqpap;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na exclusao de registros
                vr_dscritic := 'Erro ao excluir o público alvo.'||sqlerrm ;
                RAISE vr_exc_saida;
            END;
          END IF;

        WHEN 'I' THEN -- Inclusao
          -- Efetua a inclusao no cadastro de Parceiro Institucional
          vr_nrseqpap:=fn_sequence(pr_nmtabela => 'CRAPPAP', pr_nmdcampo => 'NRSEQPAP',pr_dsdchave => '0');
          BEGIN
            INSERT INTO crappap 
                 (nrseqpap       ,
                  dspubalv       ,
                  cdoperad       ,
                  cdprogra       ,
                  dtatuali       ,
                  cdcopope               
                  )
              VALUES
                 (vr_nrseqpap,
                  UPPER(pr_dspubalv),
                  vr_cdoperad,
                  vr_nmdatela,
                  SYSDATE,
                  pr_cdcooper                     
                  );

          -- Verifica se houve problema na insercao de registros
          EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Atenção: Este público alvo já foi cadastrado. Favor verificar!';
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao inserir crappap: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;
            
          -- Retorna a sequencia criada
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><nrseqpap>' || vr_nrseqpap || '</nrseqpap></Root>');

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
        pr_dscritic := 'Erro geral em crappap: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_crappap;

-----------------------------------------------------                       
END WPGD0108;
/
