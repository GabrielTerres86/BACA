CREATE OR REPLACE PACKAGE PROGRID.WPGD0113 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0113
  --  Sistema  : Rotinas para Cadastro de sugestão de produto 
  --  Sigla    : WPGD
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Junho/2016.                   Ultima atualizacao:  14/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Cadastro de sugestão de produto 
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_crappdp(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa logada
                      ,pr_cddopcao   IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqpdp   IN crappdp.nrseqpdp%TYPE --> Sequencia do cadastro
                      ,pr_dsprodut   IN crappdp.dsprodut%TYPE --> Descrição do Publico Alvo
                      ,pr_nriniseq   IN PLS_INTEGER           --> Sequencia inicial da busca
                      ,pr_qtregist   IN PLS_INTEGER           --> Qtd de registros da busca
                      ,pr_xmllog     IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                      ,pr_dscritic  OUT VARCHAR2              --> Descrição da crítica
                      ,pr_retxml IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                      ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                      ,pr_des_erro  OUT VARCHAR2);

END WPGD0113;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0113 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0113
  --  Sistema  : Rotinas para Cadastro de sugestão de produto 
  --  Sigla    : WPGD
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Junho/2016.                   Ultima atualizacao:  14/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Cadastro de sugestão de produto 
  --
  -- Alteracoes: 
  --
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0113 na tabela CRAPPDP
  PROCEDURE pc_crappdp(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa logada
                      ,pr_cddopcao       IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqpdp       IN crappdp.nrseqpdp%TYPE --> Sequencia do cadastro
                      ,pr_dsprodut       IN crappdp.dsprodut%TYPE --> Descrição do Publico Alvo
                      ,pr_nriniseq       IN PLS_INTEGER           --> Sequencia inicial da busca
                      ,pr_qtregist       IN PLS_INTEGER           --> Qtd de registros da busca
                      ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic      OUT PLS_INTEGER           --> Código da crítica
                      ,pr_dscritic      OUT VARCHAR2              --> Descrição da crítica
                      ,pr_retxml     IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                      ,pr_nmdcampo      OUT VARCHAR2              --> Nome do campo com erro
                      ,pr_des_erro      OUT VARCHAR2) IS          --> Erros do processo
  
    /* ..........................................................................
    --
    --  Programa : pc_crappdp
    --  Sistema  : Rotinas para tela cadastro de sugestão de produto
    --  Sigla    : WPGD
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Junho/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Rotina geral de insert, update, select e delete da tela WPGD0113 na tabela CRAPPDP
    --
    --  Alteracoes: 
    -- .............................................................................*/

      -- Buscar Sugestãoo de produtos
      CURSOR cr_crapdp IS
      SELECT pdp.nrseqpdp,
             pdp.dsprodut,
             pdp.cdoperad,
             pdp.cdprogra,
             pdp.dtatuali,
             ROW_NUMBER() OVER(ORDER BY 1, 2, 3, 4 DESC) nrdseque
        FROM crappdp pdp
       WHERE pdp.nrseqpdp = NVL(pr_nrseqpdp, nrseqpdp)
         AND UPPER(dsprodut) LIKE '%' || UPPER(pr_dsprodut) || '%'
    ORDER BY pdp.dsprodut;
                 
                 
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
      vr_nrseqpdp crappdp.nrseqpdp%TYPE;
      VR_EXISTE_PROPOSTA  NUMBER:=0;
      vr_nmevento crapedp.nmevento%TYPE;

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
            -- Atualizacao de cadastro de sugestao de produto
            UPDATE crappdp pdp
               SET pdp.dsprodut = upper(pr_dsprodut),
                   pdp.cdoperad = vr_cdoperad,
                   pdp.cdprogra = vr_nmdatela,
                   pdp.dtatuali = SYSDATE,
                   pdp.cdcopope = pr_cdcooper
             WHERE pdp.nrseqpdp = pr_nrseqpdp;

          -- Verifica se houve problema na atualizacao do registro
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar crappdp: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;
          
          -- Retorna a sequencia criada
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><nrseqpdp>' || pr_nrseqpdp || '</nrseqpdp></Root>');
          
        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
           -- Buscar sugestão de produtos
          FOR rw_crappdp IN cr_crapdp LOOP
              IF ((pr_nriniseq <= rw_crappdp.nrdseque)AND (rw_crappdp.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqpdp'      , pr_tag_cont => rw_crappdp.nrseqpdp                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsprodut'      , pr_tag_cont => rw_crappdp.dsprodut                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad'      , pr_tag_cont => rw_crappdp.cdoperad                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra'      , pr_tag_cont => rw_crappdp.cdprogra                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali'      , pr_tag_cont => to_char(rw_crappdp.dtatuali,'dd/mm/yyyy') , pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrsequen'      , pr_tag_cont => rw_crappdp.nrdseque                       , pr_des_erro => vr_dscritic);  
                vr_contador := vr_contador + 1;
             END IF;
             vr_totregis := vr_totregis +1;    
          END LOOP;
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis'   , pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);           

        WHEN 'E' THEN -- Exclusao

          
          --Verificar se produto não esta atrelado a algum evento
          BEGIN
            SELECT 1,
                   edp.nmevento
              INTO vr_existe_proposta,
                   vr_nmevento
              FROM crappde pde,
                   crapedp edp
             WHERE pde.idevento = edp.idevento
               AND pde.cdcooper = edp.cdcooper
               AND pde.dtanoage = edp.dtanoage
               AND pde.cdevento = edp.cdevento
               AND pde.nrseqpdp = pr_nrseqpdp
               AND rownum = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VR_EXISTE_PROPOSTA := 0;
              vr_nmevento        := NULL;
          END;

          IF VR_EXISTE_PROPOSTA = 1 THEN
            vr_dscritic := 'Exclusão não permitida. Sugestão de produto esta associada ao evento '||vr_nmevento||'.';
            RAISE vr_exc_saida;         
          ELSE
            BEGIN
              DELETE crappdp
               WHERE nrseqpdp = pr_nrseqpdp;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na exclusao de registros
                vr_dscritic := 'Erro ao excluir o sugestão de produto: '||sqlerrm ;
                RAISE vr_exc_saida;
            END;
          END IF;

        WHEN 'I' THEN -- Inclusao
          -- Efetua a inclusao no cadastro de sugestão de produto 
          vr_nrseqpdp := fn_sequence(pr_nmtabela => 'CRAPPDP', pr_nmdcampo => 'NRSEQPDP',pr_dsdchave => '0');
          BEGIN
            INSERT INTO crappdp
                 (nrseqpdp       ,
                  dsprodut       ,
                  cdoperad       ,
                  cdprogra       ,
                  dtatuali       ,
                  cdcopope               
                  )
              VALUES
                 (vr_nrseqpdp,
                  UPPER(pr_dsprodut),
                  vr_cdoperad,
                  vr_nmdatela,
                  SYSDATE,
                  pr_cdcooper                     
                  );

          -- Verifica se houve problema na insercao de registros
          EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Atenção: Esta sugestão de produto já foi cadastrada. Favor verificar!';
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao inserir crappap: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;
            
          -- Retorna a sequencia criada
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><nrseqpdp>' || vr_nrseqpdp || '</nrseqpdp></Root>');

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
        pr_dscritic := 'Erro geral em crappdp: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_crappdp;

-----------------------------------------------------                       
END WPGD0113;
/
