CREATE OR REPLACE PACKAGE PROGRID.WPGD0106 is
 ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0106                     
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Vanessa Klein
  --  Data     : Setembro/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Cadastro de Distância Origem x Destino.
  --
  -- Alteracoes:   
  --
  ---------------------------------------------------------------------------------------------------------------
   -- Rotina geral de insert, update, select e delete da tela WPGD0106 na tabela CRAPPPA
  PROCEDURE pc_crapdod(pr_cddopcao        IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                         ,pr_cdcidori       IN crapdod.cdcidori%TYPE --> Código da Cidade de origem
                         ,pr_cdciddes       IN crapdod.cdciddes%TYPE --> Código da Cidade de Destino
                         ,pr_qtquidod       IN crapdod.qtquidod%TYPE --> Distancia em KM
                         ,pr_dscidade       IN crapmun.dscidade%TYPE --> Nome da cidade
                         ,pr_nriniseq       IN PLS_INTEGER           --> Incicio da Sequencia para paginação
                         ,pr_qtregist       IN PLS_INTEGER           --> Quantidade de Registros a serem mostrados na paginação
                         ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                         ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                         ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro       OUT VARCHAR2) ;
  
  -- Rotina que retornaEstados 
  PROCEDURE pc_retorna_estados(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2 );
                              
  -- Rotina que retorna Cidades                     
  PROCEDURE pc_retorna_cidades(pr_cdestado IN crapmun.cdestado%TYPE -->Identificacao do tipo de evento 1 - Progrid e 2 - Assembléia
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);
END WPGD0106;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0106 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0106                     
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Vanessa Klein
  --  Data     : Setembro/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Cadastro de Distância Origem x Destino.
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Rotina geral de insert, update, select e delete da tela WPGD0106 na tabela crapppa
 PROCEDURE pc_crapdod(pr_cddopcao        IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                     ,pr_cdcidori       IN crapdod.cdcidori%TYPE --> Código da Cidade de origem
                     ,pr_cdciddes       IN crapdod.cdciddes%TYPE --> Código da Cidade de Destino
                     ,pr_qtquidod       IN crapdod.qtquidod%TYPE --> Distancia em KM
                     ,pr_dscidade       IN crapmun.dscidade%TYPE --> Nome da cidade
                     ,pr_nriniseq       IN PLS_INTEGER           --> Incicio da Sequencia para paginação
                     ,pr_qtregist       IN PLS_INTEGER           --> Quantidade de Registros a serem mostrados na paginação
                     ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                     ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                     ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                     ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                     ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                     ,pr_des_erro       OUT VARCHAR2) IS          --> Erros do processo

    -- Cursor sobre a tabela de cidades origem
      CURSOR cr_crapdod_ori IS
       SELECT   mun.cdestado cdestori ,
          dod.cdcidori,
          mun.dscidade dscidori,
          (SELECT cdestado FROM crapmun WHERE  cdcidade = dod.cdciddes ) cdestdes,
          dod.cdciddes,
          (SELECT dscidade FROM crapmun WHERE  cdcidade = dod.cdciddes ) dsciddes,
          dod.qtquidod,
          ROW_NUMBER() OVER(ORDER BY 1, 2, 3, 4 DESC) nrdseque
       FROM crapdod dod
       INNER JOIN crapmun mun ON
              mun.cdcidade = dod.cdcidori 
       WHERE UPPER(dscidade) LIKE '%' || UPPER(pr_dscidade) || '%'
       ORDER BY dscidori, dsciddes ASC; 
       
       -- Cursor sobre a tabela de cidades destino
      CURSOR cr_crapdod_des IS
       SELECT mun.cdestado cdestdes  ,
              dod.cdciddes,
              mun.dscidade dsciddes,
              (SELECT cdestado FROM crapmun WHERE  cdcidade = dod.cdcidori ) cdestori,
              dod.cdcidori,
              (SELECT dscidade FROM crapmun WHERE  cdcidade = dod.cdcidori )dscidori ,
              dod.qtquidod,
              ROW_NUMBER() OVER(ORDER BY 1, 2, 3, 4 DESC) nrdseque
         FROM crapdod dod
   INNER JOIN crapmun mun ON
              mun.cdcidade = dod.cdciddes 
        WHERE UPPER(dscidade) LIKE '%' || UPPER(pr_dscidade) || '%'
     ORDER BY dscidori, dsciddes ASC;                  
                 
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
      VR_POSICAO  NUMBER:=0;
      VR_EXISTE   NUMBER:=0;
     
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      mesma_orig_dest  EXCEPTION;
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
            UPDATE crapdod
               SET 
                 qtquidod = pr_qtquidod,
                 cdoperad = vr_cdoperad,
                 cdprogra = vr_nmdatela,
                 dtatuali = SYSDATE,
                 cdcopope = vr_cdcooper
             WHERE cdcidori = pr_cdcidori
               AND cdciddes = pr_cdciddes;

          -- Verifica se houve problema na atualizacao do registro
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar crapdod: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;

        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
           -- Loop sobre os Origens Destino do Progrid pesquisa por cidade origem
          IF pr_cdcidori = 0 THEN 
              FOR rw_crapdod IN cr_crapdod_ori LOOP
                  IF ((pr_nriniseq <= rw_crapdod.nrdseque)AND (rw_crapdod.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cduforig'      , pr_tag_cont => rw_crapdod.cdestori                       , pr_des_erro => vr_dscritic);  
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcidori'      , pr_tag_cont => rw_crapdod.cdcidori                       , pr_des_erro => vr_dscritic);  
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmcidori'      , pr_tag_cont => rw_crapdod.dscidori                       , pr_des_erro => vr_dscritic);  
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdufdest'      , pr_tag_cont => rw_crapdod.cdestdes                       , pr_des_erro => vr_dscritic);
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdciddes'      , pr_tag_cont => rw_crapdod.cdciddes                       , pr_des_erro => vr_dscritic);  
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmciddes'      , pr_tag_cont => rw_crapdod.dsciddes                       , pr_des_erro => vr_dscritic);  
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtquidod'      , pr_tag_cont => rw_crapdod.qtquidod                       , pr_des_erro => vr_dscritic);  
                    vr_contador := vr_contador + 1;
                 END IF;
                 vr_totregis := vr_totregis +1;    
              END LOOP;
           ELSE -- Loop sobre os Origens Destino do Progrid pesquisa por cidade Destino
               FOR rw_crapdod IN cr_crapdod_des LOOP
                  IF ((pr_nriniseq <= rw_crapdod.nrdseque)AND (rw_crapdod.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cduforig'      , pr_tag_cont => rw_crapdod.cdestori                       , pr_des_erro => vr_dscritic);  
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcidori'      , pr_tag_cont => rw_crapdod.cdcidori                       , pr_des_erro => vr_dscritic);  
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmcidori'      , pr_tag_cont => rw_crapdod.dscidori                       , pr_des_erro => vr_dscritic);  
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdufdest'      , pr_tag_cont => rw_crapdod.cdestdes                       , pr_des_erro => vr_dscritic);
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdciddes'      , pr_tag_cont => rw_crapdod.cdciddes                       , pr_des_erro => vr_dscritic);  
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmciddes'      , pr_tag_cont => rw_crapdod.dsciddes                       , pr_des_erro => vr_dscritic);  
                    GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtquidod'      , pr_tag_cont => rw_crapdod.qtquidod                       , pr_des_erro => vr_dscritic);  
                    vr_contador := vr_contador + 1;
                 END IF;
                 vr_totregis := vr_totregis +1;    
              END LOOP;
           END IF;
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis'   , pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);           

        WHEN 'E' THEN -- Exclusao               
          -- Efetua a exclusao do  Distância Origem x Destino
          
            BEGIN
              DELETE crapdod
               WHERE cdcidori = pr_cdcidori
                 AND cdciddes = pr_cdciddes;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na exclusao de registros
                vr_dscritic := 'Erro ao excluir a  Distância Origem x Destino.'||sqlerrm ;
                RAISE vr_exc_saida;
            END;

        WHEN 'I' THEN -- Inclusao
         BEGIN
            SELECT COUNT(pr_cdcidori)
                   
              INTO 
                   VR_EXISTE
              FROM 
                   crapdod dod
             WHERE (cdcidori = pr_cdcidori
               AND cdciddes = pr_cdciddes) 
               OR (cdcidori = pr_cdciddes 
               AND cdciddes = pr_cdcidori);
                 
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VR_EXISTE:=0;
          END;        
          --
          BEGIN
          
            IF VR_EXISTE > 0 THEN
               RAISE dup_val_on_index; 
            END IF;
            
            IF pr_cdcidori = pr_cdciddes THEN
               RAISE mesma_orig_dest;
            END IF; 
            -- Efetua a inclusao no Cadastro Distância Origem x Destino
           
            INSERT INTO crapdod
                 (cdcidori ,
                  cdciddes ,
                  qtquidod ,
                  cdoperad ,
                  cdprogra ,
                  dtatuali,
                  cdcopope                                       
                  )
              VALUES
                 (pr_cdcidori,
                  pr_cdciddes,
                  pr_qtquidod,
                  vr_cdoperad,
                  vr_nmdatela,
                  SYSDATE,
                  vr_cdcooper                      
                  );

          -- Verifica se houve problema na insercao de registros
         EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Atenção: Esta Distância Origem x Destino já foi cadastrada. Favor verificar!';
              RAISE vr_exc_saida;
            WHEN mesma_orig_dest THEN
              vr_dscritic := 'Atenção: Não é permitido cadastrar a mesma cidade na Origem x Destino. Favor verificar!';
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao inserir crapdod: ' || sqlerrm;
              RAISE vr_exc_saida;
         END;
            
          -- Retorna a sequencia criada
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                         <Root><cdcidori>' || pr_cdcidori || '</cdcidori>
                                         <cdciddes>' || pr_cdciddes || '</cdciddes>
                                         </Root>');

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
 END pc_crapdod;  

   -- Rotina que retorna os estados  
  PROCEDURE pc_retorna_estados(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2 ) IS           

      -- Cursor sobre a tabela de Eixo Temático
      CURSOR cr_crapmun IS
             SELECT mun.cdestado
               FROM crapmun mun
           GROUP BY mun.cdestado
           ORDER BY mun.cdestado ASC;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      
      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
    
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
            -- Loop sobre os Eixos Temáticos
            FOR rw_crapmun IN cr_crapmun LOOP
                
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdestado'      , pr_tag_cont => rw_crapmun.cdestado                       , pr_des_erro => vr_dscritic);
                                 
              vr_contador := vr_contador + 1;
            END LOOP;
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
        pr_dscritic := 'Erro geral em GNAPETP: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                      
  END pc_retorna_estados; 
  
   -- Rotina que retorna cidades e estados  
  PROCEDURE pc_retorna_cidades(pr_cdestado IN crapmun.cdestado%TYPE --> Sigla do estado
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2 ) IS           

      -- Cursor sobre a tabela de Eixo Temático
      CURSOR cr_crapmun (pr_cdestado IN crapmun.cdestado%TYPE)IS
             SELECT mun.cdestado
                   ,mun.cdcidade
                   ,mun.dscidade
               FROM 
                    crapmun mun
               WHERE /*pr_cdestado = '0' OR */
                    mun.cdestado = NVL(pr_cdestado,cdestado)                  
               ORDER BY mun.dscidade ASC;
        rw_crapmun cr_crapmun%ROWTYPE;        
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      
      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
    
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
         -- Loop sobre os Eixos Temáticos
        FOR rw_crapmun IN cr_crapmun (pr_cdestado) LOOP
                
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdestado'      , pr_tag_cont => rw_crapmun.cdestado                       , pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcidade'      , pr_tag_cont => rw_crapmun.cdcidade                       , pr_des_erro => vr_dscritic);  
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dscidade'      , pr_tag_cont => rw_crapmun.dscidade                       , pr_des_erro => vr_dscritic);  
                                 
          vr_contador := vr_contador + 1;
        END LOOP;
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
        pr_dscritic := 'Erro geral em GNAPETP: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                      
  END pc_retorna_cidades; 
  
-----------------------------------------------------                       
END WPGD0106;
/
