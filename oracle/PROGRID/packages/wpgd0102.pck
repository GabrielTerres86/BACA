CREATE OR REPLACE PACKAGE PROGRID.WPGD0102 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0102                     
  --  Sistema  : Rotinas para Temas por Eixo Temático
  --  Sigla    : WPGD
  --  Autor    : Márcio José de Carvalho (RKAM)
  --  Data     : Maio/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Temas por Eixo Temático.
  --
  -- Alteracoes:   
  --
  ---------------------------------------------------------------------------------------------------------------


  -- Rotina geral de insert, update, select e delete da tela WPGD0102 na tabela CRAPTEM
  PROCEDURE pc_craptem(pr_cddopcao       IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_idevento       IN craptem.idevento%TYPE -->Identificacao do tipo de evento 1 - Progrid e 2 - Assembléia
                      ,pr_cdcooper       IN craptem.cdcooper%TYPE -->Codigo que identifica a Cooperativa
                      ,pr_cdeixtem       IN craptem.cdeixtem%TYPE -->Identificacao do Eixo Tematico
                      ,pr_nrseqtem       IN craptem.nrseqtem%TYPE -->Sequencia de digitacao do tema
                      ,pr_dstemeix       IN craptem.dstemeix%TYPE -->Descrição do tema
                      ,pr_dseixtem       IN VARCHAR2              --> Eixo do tema
                      ,pr_dsrelava       IN VARCHAR2              --> Desc. Indicador de tema impresso no relatório de avaliação
                      ,pr_dsrespub       IN VARCHAR2              --> Desc. Indicador de Tema restrito para publicação                                    
                      ,pr_idrelava       IN craptem.idrelava%TYPE -->Indicador de tema impresso no relatório de avaliação S - Sim e N- Não
                      ,pr_idsittem       IN craptem.idsittem%TYPE -->Indicador da situacao do tema A - Ativo e N- Inativo
                      ,pr_idrespub       IN craptem.idrespub%TYPE -->Indicador de Tema restrito para publicação
                      ,pr_cdoperad       IN craptem.cdoperad%TYPE -->Código do operador que fez a manipulação do registro
                      ,pr_cdprogra       IN craptem.cdprogra%TYPE -->Código do programa que fez a manipulação do registro
                      ,pr_nriniseq       IN PLS_INTEGER 
                      ,pr_qtregist       IN PLS_INTEGER 
                      ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro       OUT VARCHAR2);
                      
  -- Rotina que retorna os Eixos Temáticos do Progrid
  PROCEDURE pc_retorna_eixo(pr_idevento IN craptem.idevento%TYPE -->Identificacao do tipo de evento 1 - Progrid e 2 - Assembléia
                           ,pr_cdcooper IN craptem.cdcooper%TYPE  --> Codigo da Cooperativa
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Erros do processo                     


END WPGD0102;
/

CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0102 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0102                     
  --  Sistema  : Rotinas para Temas por Eixo Temático
  --  Sigla    : WPGD
  --  Autor    : Márcio José de Carvalho (RKAM)
  --  Data     : Maio/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Temas por Eixo Temático.
  --
  -- Alteracoes:   
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Rotina geral de insert, update, select e delete da tela WPGD0102 na tabela CRAPTEM
  PROCEDURE pc_craptem(pr_cddopcao       IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_idevento       IN craptem.idevento%TYPE -->Identificacao do tipo de evento 1 - Progrid e 2 - Assembléia
                      ,pr_cdcooper       IN craptem.cdcooper%TYPE -->Codigo que identifica a Cooperativa
                      ,pr_cdeixtem       IN craptem.cdeixtem%TYPE -->Identificacao do Eixo Tematico
                      ,pr_nrseqtem       IN craptem.nrseqtem%TYPE -->Sequencia de digitacao do tema
                      ,pr_dstemeix       IN craptem.dstemeix%TYPE -->Descrição do tema           
                      ,pr_dseixtem       IN VARCHAR2              --> Eixo do tema
                      ,pr_dsrelava       IN VARCHAR2              --> Desc. Indicador de tema impresso no relatório de avaliação
                      ,pr_dsrespub       IN VARCHAR2              --> Desc. Indicador de Tema restrito para publicação                                    
                      ,pr_idrelava       IN craptem.idrelava%TYPE -->Indicador de tema impresso no relatório de avaliação S - Sim e N- Não                      
                      ,pr_idsittem       IN craptem.idsittem%TYPE -->Indicador da situacao do tema A - Ativo e N- Inativo
                      ,pr_idrespub       IN craptem.idrespub%TYPE -->Indicador de Tema restrito para publicação
                      ,pr_cdoperad       IN craptem.cdoperad%TYPE -->Código do operador que fez a manipulação do registro
                      ,pr_cdprogra       IN craptem.cdprogra%TYPE -->Código do programa que fez a manipulação do registro
                      ,pr_nriniseq       IN PLS_INTEGER 
                      ,pr_qtregist       IN PLS_INTEGER 
                      ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro       OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor sobre a tabela de temas
      CURSOR cr_craptem (p_dstemeix IN VARCHAR2
                        ,p_dseixtem IN VARCHAR2
                        ,p_dsrelava IN VARCHAR2
                        ,p_dsrespub IN VARCHAR2) IS
             SELECT
                    c.idevento       ,        
                    c.cdcooper       ,
                    c.cdeixtem       ,
                    UPPER(g.dseixtem) dseixtem      ,
                    c.nrseqtem       ,
                    UPPER(c.dstemeix) dstemeix,
                    decode(c.idrelava,'S','SIM','N','NÃO',null) idrelava      ,
                    decode(c.idsittem,'A','ATIVO','I','INATIVO',null)idsittem       ,
                    decode(c.idrespub,'S','SIM','N','NÃO',null) idrespub,
                    c.cdoperad       ,
                    c.cdprogra       ,
                    c.dtatuali       , 
                    ROW_NUMBER() OVER(ORDER BY 1, 2, 3, 4 DESC) nrdseque  
               FROM 
                    craptem c,
                    gnapetp g
               WHERE
                    c.idevento = NVL(pr_idevento,c.idevento) AND
                    c.cdcooper = NVL(pr_cdcooper,c.cdcooper) AND
                    c.cdeixtem = NVL(pr_cdeixtem,c.cdeixtem) AND
                    c.nrseqtem = NVL(pr_nrseqtem,c.nrseqtem) AND
                    UPPER(c.dstemeix) LIKE (UPPER(p_dstemeix))            AND 
                    UPPER(g.dseixtem) LIKE (UPPER(p_dseixtem))            AND
                    decode(c.idrelava,'S','SIM','N','NÃO',null) LIKE UPPER(p_dsrelava) AND
                    decode(c.idrespub,'S','SIM','N','NÃO',null) LIKE UPPER(p_dsrespub) AND
                    g.idevento = c.idevento                  AND
                    g.cdcooper = c.cdcooper                  AND
                    g.cdeixtem = c.cdeixtem
               ORDER BY 1,2,3,4,5;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

          
      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_totregis PLS_INTEGER := 0;
      vr_nrseqtem craptem.nrseqtem%TYPE;
      VR_EXISTE_SUGESTAO  NUMBER:=0;
      VR_EXISTE_EVENTO  NUMBER:=0;
      vr_dstemeix craptem.dstemeix%TYPE;
      
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
        vr_dstemeix := pr_dstemeix;

        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao

          WHEN 'A' THEN -- Alteracao
            BEGIN
              -- Atualizacao de registro de Temas
              UPDATE CRAPTEM
                 SET 
                    dstemeix = vr_dstemeix,
                    idrelava = pr_idrelava,
                    idsittem = pr_idsittem,
                    idrespub = pr_idrespub,
                    cdoperad = pr_cdoperad,
                    cdprogra = pr_cdprogra,
                    dtatuali = sysdate
               WHERE idevento = pr_idevento  AND 
                     cdcooper = pr_cdcooper  AND 
                     cdeixtem = pr_cdeixtem  AND 
                     nrseqtem = pr_nrseqtem;

            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao atualizar CRAPTEM: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');  

            -- Loop sobre os Temas do Progrid
            FOR rw_craptem IN cr_craptem('%'||pr_dstemeix||'%'
                                        ,'%'||pr_dseixtem||'%'
                                        ,'%'||pr_dsrelava||'%' 
                                        ,'%'||pr_dsrespub||'%') LOOP
                 
              IF ((pr_nriniseq <= rw_craptem.nrdseque)AND (rw_craptem.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN                      
                
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idevento'      , pr_tag_cont => rw_craptem.idevento                       , pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper'      , pr_tag_cont => rw_craptem.cdcooper                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdeixtem'      , pr_tag_cont => rw_craptem.cdeixtem                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dseixtem'      , pr_tag_cont => rw_craptem.dseixtem                       , pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqtem'      , pr_tag_cont => rw_craptem.nrseqtem                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dstemeix'      , pr_tag_cont => rw_craptem.dstemeix                       , pr_des_erro => vr_dscritic); 
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idrelava'      , pr_tag_cont => rw_craptem.idrelava                       , pr_des_erro => vr_dscritic);   
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idsittem'      , pr_tag_cont => rw_craptem.idsittem                       , pr_des_erro => vr_dscritic);                       
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idrespub'      , pr_tag_cont => rw_craptem.idrespub                       , pr_des_erro => vr_dscritic);                                     
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad'      , pr_tag_cont => rw_craptem.cdoperad                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra'      , pr_tag_cont => rw_craptem.cdprogra                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali'      , pr_tag_cont => to_char(rw_craptem.dtatuali,'dd/mm/yyyy') , pr_des_erro => vr_dscritic);
                vr_contador := vr_contador + 1;
                
              END IF;
              
              vr_totregis := vr_totregis +1;
              
            END LOOP;
            
            GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis'   , pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);


          WHEN 'E' THEN -- Exclusao

            -- Efetua a exclusao do tema           
            --Validar se o tema não está associado a um evento ou sugestão pré categorizada.
            -- Sugestão
            BEGIN
            SELECT 
                   1
              INTO 
                   VR_EXISTE_SUGESTAO
              FROM 
                   crapsdp cs
               WHERE 
                   cs.nrseqtem = pr_nrseqtem
                 AND rownum = 1;
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
                   crapedp ce
               WHERE 
                   ce.nrseqtem = pr_nrseqtem
                 AND rownum = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VR_EXISTE_EVENTO:=0;
          END;
           --
          IF VR_EXISTE_SUGESTAO = 1 THEN
            vr_dscritic := 'Exclusao nao permitida. Este Tema esta associada a uma sugestao' ;
            RAISE vr_exc_saida;              
          
          ELSIF VR_EXISTE_EVENTO = 1 THEN
            vr_dscritic := 'Exclusao nao permitida. Este Tema esta associada a um evento' ;
            RAISE vr_exc_saida;             
          
          ELSE       
            BEGIN
              DELETE craptem
               WHERE idevento = pr_idevento AND 
                     cdcooper = pr_cdcooper AND
                     cdeixtem = pr_cdeixtem AND
                     nrseqtem = pr_nrseqtem;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPTEM: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;
          END IF;
                 
          WHEN 'I' THEN -- Inclusao
            -- Efetua a inclusao no cadastro de tema
            vr_nrseqtem := fn_sequence(pr_nmtabela => 'CRAPTEM', pr_nmdcampo => 'NRSEQTEM',pr_dsdchave => '0');
            BEGIN
              INSERT INTO craptem
                   (idevento       ,        
                    cdcooper       ,
                    cdeixtem       ,
                    nrseqtem       ,
                    dstemeix       ,
                    idrelava       ,
                    idsittem       ,
                    idrespub       ,
                    cdoperad       ,
                    cdprogra       ,
                    dtatuali                      
                    )
                VALUES
                   (pr_idevento,        
                    pr_cdcooper,
                    pr_cdeixtem,
                    vr_nrseqtem,
                    UPPER(vr_dstemeix),
                    pr_idrelava,
                    pr_idsittem,
                    pr_idrespub,
                    pr_cdoperad,
                    pr_cdprogra,
                    sysdate                      
                    )
                 RETURNING nrseqtem INTO vr_nrseqtem;

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN dup_val_on_index THEN
                vr_dscritic := 'Atencao: Este tema já foi cadastrado. Favor verificar!';
                RAISE vr_exc_saida;
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao inserir CRAPTEM: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;
            
            -- Retorna a sequencia criada
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados><nrseqtem>' || vr_nrseqtem || '</nrseqtem></Dados></Root>');

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
        pr_dscritic := 'Erro geral em CRAPTEM: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_craptem;
  ------------------------------------------------------------
  -- Rotina que retorna os Eixos Temáticos do Progrid
  PROCEDURE pc_retorna_eixo(
                            pr_idevento IN craptem.idevento%TYPE -->Identificacao do tipo de evento 1 - Progrid e 2 - Assembléia
                           ,pr_cdcooper IN craptem.cdcooper%TYPE  --> Codigo da Cooperativa
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) is           --> Erros do processo   

      -- Cursor sobre a tabela de Eixo Temático
      CURSOR cr_GNAPETP IS
             SELECT
                    G.CDEIXTEM,
                    UPPER(G.DSEIXTEM)DSEIXTEM 
               FROM 
                    GNAPETP G
               WHERE
                    G.IDEVENTO = NVL(pr_idevento,idevento) AND
                    G.CDCOOPER = NVL(pr_cdcooper,cdcooper) AND
                    G.FLGATIVO = 1 -- Ativo
               ORDER BY 1,2;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      
      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
    
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
            -- Loop sobre os Eixos Temáticos
            FOR rw_GNAPETP IN cr_GNAPETP LOOP
                
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdeixtem'      , pr_tag_cont => rw_GNAPETP.CDEIXTEM                       , pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dseixtem'      , pr_tag_cont => rw_GNAPETP.DSEIXTEM                       , pr_des_erro => vr_dscritic);  
                                 
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
  END pc_retorna_eixo; 
-----------------------------------------------------                       
END WPGD0102;
/

