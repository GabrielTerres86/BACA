CREATE OR REPLACE PACKAGE PROGRID.WPGD0107 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0107                     
  --  Sistema  : Rotinas para tela de Cadastro de Quantidade de Material p/ Divulgação
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Outubro/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Quantidade de Material p/ Divulgação
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0107 para aba RECURSO
  PROCEDURE pc_wpgd0107(pr_idevento IN crapqmd.idevento%TYPE --> Identificador de Evento(1 - Progrid / 2 - Assembléia)
                       ,pr_cdcopqtd IN crapqmd.cdcopqtd%TYPE --> Cooperativa da Qtd de Material
                       ,pr_nmrescop IN crapcop.nmrescop%TYPE --> Nome Cooperativa da Qtd de Material
                       ,pr_cdcooper IN crapqmd.cdcooper%TYPE --> Codigo da cooperativa do cadastro de recursos
                       ,pr_cdagenci IN crapqmd.cdagenci%TYPE --> Codigo do PA
                       ,pr_nmresage IN crapage.nmresage%TYPE --> Nome do PA
                       ,pr_dtanoage IN crapqmd.dtanoage%TYPE --> Ano da Agenda
                       ,pr_tpevento IN crapqmd.tpevento%TYPE --> Tipo do Evento
                       ,pr_dsevento IN VARCHAR2              --> Tipo de Evento
                       ,pr_qtrecnes IN crapqmd.qtrecnes%TYPE --> Quantidade de Material
                       ,pr_nrseqdig IN crapqmd.nrseqdig%TYPE --> Codigo do Recurso
                       ,pr_dsrecurs IN gnaprdp.dsrecurs%TYPE --> Descricao do Recurso
                       ,pr_dtanoori IN crapqmd.dtanoage%TYPE --> Ano de Origem p/ Copia
                       ,pr_dtanodes IN crapqmd.dtanoage%TYPE --> Ano de Destino p/ Copia
                       ,pr_nriniseq IN crapqmd.idevento%TYPE --> Registro inicial para pesquisa
                       ,pr_qtregist IN crapqmd.idevento%TYPE --> Quantidade de registros por pesquisa
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
  
  -- Rotina geral de consulta de fornecedores
  PROCEDURE pc_carrega_recurso(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);        --> Descricao do Erro

  -- Rotina geral de consulta de registros de tipos de eventos
  PROCEDURE pc_carrega_tipo_evento(pr_idevento crapqmd.idevento%TYPE --> Identificador de Evento(1 - Progrid / 2 - Assembléia)
                                  ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);        --> Descricao do Erro
END WPGD0107;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0107 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0107
  --  Sistema  : Rotinas para tela de Cadastro de Quantidade de Material p/ Divulgação
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Outubro/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Cadastro de Quantidade de Material p/ Divulgação.
  --
  -- Alteracoes:   
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral de insert, update, select e delete da tela WPGD0107
  PROCEDURE pc_wpgd0107(pr_idevento IN crapqmd.idevento%TYPE --> Identificador de Evento(1 - Progrid / 2 - Assembléia)
                       ,pr_cdcopqtd IN crapqmd.cdcopqtd%TYPE --> Cooperativa da Qtd de Material
                       ,pr_nmrescop IN crapcop.nmrescop%TYPE --> Nome Cooperativa da Qtd de Material
                       ,pr_cdcooper IN crapqmd.cdcooper%TYPE --> Codigo da cooperativa do cadastro de recursos
                       ,pr_cdagenci IN crapqmd.cdagenci%TYPE --> Codigo do PA
                       ,pr_nmresage IN crapage.nmresage%TYPE --> Nome do PA
                       ,pr_dtanoage IN crapqmd.dtanoage%TYPE --> Ano da Agenda
                       ,pr_tpevento IN crapqmd.tpevento%TYPE --> Tipo do Evento
                       ,pr_dsevento IN VARCHAR2              --> Tipo de Evento
                       ,pr_qtrecnes IN crapqmd.qtrecnes%TYPE --> Quantidade de Material
                       ,pr_nrseqdig IN crapqmd.nrseqdig%TYPE --> Codigo do Recurso
                       ,pr_dsrecurs IN gnaprdp.dsrecurs%TYPE --> Descricao do Recurso
                       ,pr_dtanoori IN crapqmd.dtanoage%TYPE --> Ano de Origem p/ Copia
                       ,pr_dtanodes IN crapqmd.dtanoage%TYPE --> Ano de Destino p/ Copia
                       ,pr_nriniseq IN crapqmd.idevento%TYPE --> Registro inicial para pesquisa
                       ,pr_qtregist IN crapqmd.idevento%TYPE --> Quantidade de registros por pesquisa
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro

      -- CURSORES
      
      -- Consulta Recursos
      CURSOR cr_crapqmd IS
        SELECT qmd.idevento AS idevento
              ,qmd.dtanoage AS dtanoage
              ,qmd.cdcopqtd AS cdcooper
              ,cop.nmrescop AS nmrescop
              ,qmd.cdagenci AS cdagenci
              ,age.nmresage AS nmresage
              ,qmd.tpevento AS tpevento
              ,DECODE(qmd.tpevento,1,'CURSO'
                                  ,2,'INTEGRACAO DE NOVOS SOCIOS'
                                  ,3,'GINCANA'
                                  ,4,'PALESTRA'
                                  ,5,'TEATRO'
                                  ,6,'OUTROS'
                                  ,9,'PROGRAMA'
                                  ,10,'EAD'
                                  ,11,'ENCONTRO DE NEGOCIOS (NOVO)') AS dsevento
              ,qmd.nrseqdig AS nrseqdig
              ,rdp.dsrecurs AS dsrecurs
              ,(qmd.cdcooper || ',' || qmd.nrseqdig) AS cdseqdig
              ,qmd.qtrecnes AS qtrecnes
              ,qmd.cdoperad AS cdoperad
              ,qmd.cdprogra AS cdprogra
              ,qmd.dtatuali AS dtatuali
              ,qmd.progress_recid AS progress_recid
              ,ROW_NUMBER() OVER(ORDER BY qmd.dtanoage DESC, cop.nmrescop ASC, age.nmresage ASC, rdp.dsrecurs ASC) AS nrdseque
          FROM crapqmd qmd
              ,crapcop cop
              ,crapage age
              ,gnaprdp rdp
         WHERE qmd.idevento = pr_idevento
           AND qmd.cdcopqtd = cop.cdcooper
           AND cop.cdcooper = age.cdcooper
           AND qmd.cdagenci = age.cdagenci
           AND age.flgdopgd = 1
           AND age.insitage = 1
           AND (qmd.cdcooper = rdp.cdcooper
            AND qmd.nrseqdig = rdp.nrseqdig
            AND rdp.idevento = pr_idevento)
           AND qmd.dtanoage = NVL(pr_dtanoage,dtanoage)
           AND ((UPPER(cop.nmrescop) LIKE '%' || UPPER(pr_nmrescop) || '%') OR pr_nmrescop IS NULL) 
           AND ((UPPER(age.nmresage) LIKE '%' || UPPER(pr_nmresage) || '%') OR pr_nmresage IS NULL) 
           AND ((UPPER(rdp.dsrecurs) LIKE '%' || UPPER(pr_dsrecurs) || '%') OR pr_dsrecurs IS NULL) 
           AND (DECODE(qmd.tpevento,1,'CURSO'
                                   ,2,'INTEGRACAO DE NOVOS SOCIOS'
                                   ,3,'GINCANA'
                                   ,4,'PALESTRA'
                                   ,5,'TEATRO'
                                   ,6,'OUTROS'
                                   ,9,'PROGRAMA'
                                   ,10,'EAD'
                                   ,11,'ENCONTRO DE NEGOCIOS (NOVO)')
                                   LIKE UPPER('%' || pr_dsevento || '%') OR pr_dsevento IS NULL)
      ORDER BY qmd.dtanoage DESC, cop.nmrescop ASC, age.nmresage ASC, rdp.dsrecurs ASC;    
 
      rw_crapqmd cr_crapqmd%ROWTYPE;
       
      -- Consulta de PA por cooperativas
      CURSOR cr_crapage IS
        SELECT age.cdcooper
              ,age.cdagenci 
              ,age.nmresage
         FROM crapage age
        WHERE age.cdcooper = NVL(pr_cdcopqtd,age.cdcooper)
          AND (age.cdagenci = pr_cdagenci OR pr_cdagenci = 0)
          AND age.cdagenci NOT IN(90,91)
          AND age.flgdopgd = 1
          AND age.insitage = 1
      ORDER BY age.cdcooper, age.nmresage;
   
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
      CASE vr_cddopcao

        WHEN 'A' THEN -- Alteracao
          IF pr_cdagenci = 0 THEN
            -- Loop sobre os PA's
            FOR rw_crapage IN cr_crapage LOOP
              BEGIN
                UPDATE crapqmd
                  SET qtrecnes = pr_qtrecnes
                     ,cdoperad = vr_cdoperad
                     ,cdprogra = vr_nmdatela
                     ,dtatuali = SYSDATE
                     ,cdcopope = vr_cdcooper 
                WHERE crapqmd.dtanoage = pr_dtanoage
                  AND crapqmd.cdcopqtd = pr_cdcopqtd
                  AND crapqmd.cdagenci = rw_crapage.cdagenci
                  AND crapqmd.tpevento = pr_tpevento
                  AND crapqmd.idevento = pr_idevento
                  AND crapqmd.cdcooper = pr_cdcooper
                  AND crapqmd.nrseqdig = pr_nrseqdig;
                             
                IF SQL%ROWCOUNT = 0 THEN
                   BEGIN
                      INSERT INTO
                          crapqmd(dtanoage
                                 ,cdcopqtd
                                 ,cdagenci
                                 ,tpevento
                                 ,idevento
                                 ,cdcooper
                                 ,nrseqdig
                                 ,qtrecnes
                                 ,cdoperad
                                 ,cdprogra
                                 ,dtatuali
                                 ,cdcopope 
                          )VALUES(pr_dtanoage
                                 ,pr_cdcopqtd
                                 ,rw_crapage.cdagenci
                                 ,pr_tpevento
                                 ,pr_idevento
                                 ,pr_cdcooper
                                 ,pr_nrseqdig
                                 ,pr_qtrecnes
                                 ,vr_cdoperad
                                 ,vr_nmdatela
                                 ,SYSDATE
                                 ,vr_cdcooper );
                                                 
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao inserir registro(CRAPQMD), PA: ' || TO_CHAR(rw_crapage.nmresage) || '. Erro: ' || SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                END IF;

              EXCEPTION
                WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atulizar registro(CRAPQMD). Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
              END;
            END LOOP;
          ELSE
            BEGIN
              UPDATE crapqmd
                SET qtrecnes = pr_qtrecnes
                   ,cdoperad = vr_cdoperad
                   ,cdprogra = vr_nmdatela
                   ,dtatuali = SYSDATE
                   ,cdcopope = vr_cdcooper 
              WHERE crapqmd.dtanoage = pr_dtanoage
                AND crapqmd.cdcopqtd = pr_cdcopqtd
                AND crapqmd.cdagenci = pr_cdagenci
                AND crapqmd.tpevento = pr_tpevento
                AND crapqmd.idevento = pr_idevento
                AND crapqmd.cdcooper = pr_cdcooper
                AND crapqmd.nrseqdig = pr_nrseqdig;
                           
              IF SQL%ROWCOUNT = 0 THEN
                 BEGIN
                    INSERT INTO
                        crapqmd(dtanoage
                               ,cdcopqtd
                               ,cdagenci
                               ,tpevento
                               ,idevento
                               ,cdcooper
                               ,nrseqdig
                               ,qtrecnes
                               ,cdoperad
                               ,cdprogra
                               ,dtatuali
                               ,cdcopope
                        )VALUES(pr_dtanoage
                               ,pr_cdcopqtd
                               ,pr_cdagenci
                               ,pr_tpevento
                               ,pr_idevento
                               ,pr_cdcooper
                               ,pr_nrseqdig
                               ,pr_qtrecnes
                               ,vr_cdoperad
                               ,vr_nmdatela
                               ,SYSDATE
                               ,vr_cdcooper);
                                               
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir registro(CRAPQMD). Erro: ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END IF;

            EXCEPTION
              WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atulizar registro(CRAPQMD). Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
            END;
          END IF;
          
        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

          FOR rw_crapqmd IN cr_crapqmd LOOP
                     
            IF ((pr_nriniseq <= rw_crapqmd.nrdseque) AND (rw_crapqmd.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                   
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idevento', pr_tag_cont => rw_crapqmd.idevento, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtanoage', pr_tag_cont => rw_crapqmd.dtanoage, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapqmd.cdcooper, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapqmd.nmrescop, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_crapqmd.cdagenci, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmresage', pr_tag_cont => rw_crapqmd.nmresage, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'tpevento', pr_tag_cont => rw_crapqmd.tpevento, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsevento', pr_tag_cont => rw_crapqmd.dsevento, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqdig', pr_tag_cont => rw_crapqmd.nrseqdig, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdseqdig', pr_tag_cont => rw_crapqmd.cdseqdig, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsrecurs', pr_tag_cont => rw_crapqmd.dsrecurs, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtrecnes', pr_tag_cont => rw_crapqmd.qtrecnes, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_crapqmd.cdoperad, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra', pr_tag_cont => rw_crapqmd.cdprogra, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali', pr_tag_cont => rw_crapqmd.dtatuali, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'progress_recid', pr_tag_cont => rw_crapqmd.progress_recid, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdseque', pr_tag_cont => rw_crapqmd.nrdseque, pr_des_erro => vr_dscritic);
              vr_contador := vr_contador + 1;
            END IF;

            vr_totregis := vr_totregis +1;

          END LOOP;

          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

      WHEN 'E' THEN -- Exclusao
        BEGIN
          DELETE
            FROM crapqmd
           WHERE crapqmd.dtanoage = pr_dtanoage
             AND crapqmd.cdcopqtd = pr_cdcopqtd
             AND crapqmd.cdagenci = pr_cdagenci
             AND crapqmd.tpevento = pr_tpevento
             AND crapqmd.idevento = pr_idevento
             AND crapqmd.cdcooper = pr_cdcooper
             AND crapqmd.nrseqdig = pr_nrseqdig;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro(CRAPQMD). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      WHEN 'CO' THEN -- COPIA DE INFORMACOES   
        BEGIN
          INSERT INTO
            crapqmd(dtanoage
                   ,cdcopqtd
                   ,cdagenci
                   ,tpevento
                   ,idevento
                   ,cdcooper
                   ,nrseqdig
                   ,qtrecnes
                   ,cdoperad
                   ,cdprogra
                   ,dtatuali
                   ,cdcopope
            )SELECT pr_dtanodes
                   ,qmd.cdcopqtd
                   ,qmd.cdagenci
                   ,qmd.tpevento
                   ,qmd.idevento
                   ,qmd.cdcooper
                   ,qmd.nrseqdig
                   ,qmd.qtrecnes
                   ,vr_cdoperad
                   ,vr_nmdatela
                   ,SYSDATE
                   ,vr_cdcooper 
               FROM crapqmd qmd
              WHERE qmd.dtanoage = pr_dtanoori
                AND NOT EXISTS(SELECT pr_dtanodes
                                     ,qmd.cdcopqtd
                                     ,qmd.cdagenci
                                     ,qmd.tpevento
                                     ,qmd.idevento
                                     ,qmd.cdcooper
                                     ,qmd.nrseqdig
                                     ,qmd.qtrecnes
                                     ,vr_cdoperad
                                     ,vr_nmdatela
                                     ,SYSDATE
                                     ,vr_cdcooper 
                                 FROM crapqmd qmd
                                WHERE qmd.dtanoage = pr_dtanodes);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao copiar registro(CRAPQMD). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
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
        pr_dscritic := 'Erro geral em PC_WPGD0107: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_wpgd0107;
             
  -- Rotina geral de consulta de recursos
  PROCEDURE pc_carrega_recurso(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS      --> Descricao do Erro
   
      -- Consulta Recursos
      CURSOR cr_gnaprdp IS
        SELECT rdp.idevento
              ,rdp.cdcooper
              ,rdp.nrseqdig
              ,UPPER(rdp.dsrecurs) AS dsrecurs
          FROM gnaprdp rdp
         WHERE rdp.idsitrec = 1
           AND rdp.cdtiprec = 2
           AND rdp.idevento = 1
        ORDER BY TRIM(UPPER(rdp.dsrecurs)) ASC; 

      rw_gnaprdp cr_gnaprdp%ROWTYPE;
    
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
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

      FOR rw_gnaprdp IN cr_gnaprdp LOOP
                                
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idevento',pr_tag_cont => rw_gnaprdp.idevento, pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper',pr_tag_cont => rw_gnaprdp.cdcooper, pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqdig',pr_tag_cont => rw_gnaprdp.nrseqdig, pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsrecurs',pr_tag_cont => rw_gnaprdp.dsrecurs, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;

      END LOOP;

      GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_contador , pr_des_erro => vr_dscritic);
  
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
        pr_dscritic := 'Erro geral em PC_CARREGA_RECURSO: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_carrega_recurso;    
   
  -- Rotina geral de consulta de registros de tipos de eventos
  PROCEDURE pc_carrega_tipo_evento(pr_idevento crapqmd.idevento%TYPE --> Identificador de Evento(1 - Progrid / 2 - Assembléia)
                                  ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS      --> Descricao do Erro
   
    
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

      vr_indexaux VARCHAR2(100);      

      vr_idsistem INTEGER;
      vr_contador INTEGER := 0;
      -- Variáveis locais
      vr_dstextab craptab.dstextab%TYPE;
      vr_paramemt gene0002.typ_split;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      /* Definição de tabela de memória que compreende as informacoes de tipos de eventos */

      TYPE typ_reg_tab IS
        RECORD(dstpeven craptab.dstextab%TYPE
              ,tpevento INTEGER);

      TYPE typ_tab_tab IS
        TABLE OF typ_reg_tab
        INDEX BY BINARY_INTEGER;

      TYPE typ_tab_tab_aux IS
        TABLE OF typ_reg_tab
        INDEX BY VARCHAR2(100);
  
      /* Vetor para armazenar as informações de tipos de eventos */
      vr_tab_tab typ_tab_tab;
      vr_tab_tab_aux typ_tab_tab_aux;
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
      
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'CONFIG'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'PGTPEVENTO'
                                               ,pr_tpregist => 0);

      vr_paramemt := gene0002.fn_quebra_string(pr_string  => vr_dstextab
                                              ,pr_delimit => ',');

                                                                                                 
      -- Itera sobre a string quebrada
      IF vr_paramemt.count > 0 THEN
        FOR idx IN 1 .. vr_paramemt.count LOOP
          IF MOD(idx,2) = 0 THEN
            CONTINUE;
          END IF;
         
          IF vr_paramemt(idx+1) IN (10,11) THEN
            CONTINUE;
          END IF;
          vr_tab_tab(vr_paramemt(idx+1)).dstpeven := vr_paramemt(idx);
          vr_tab_tab(vr_paramemt(idx+1)).tpevento := vr_paramemt(idx+1);
          
        END LOOP;
      END IF;

      IF pr_idevento = 1 THEN
        vr_tab_tab.DELETE(7);
        vr_tab_tab.DELETE(8);
      ELSE
        -- Leitura da tabela temporaria para retornar XML para a WEB
        FOR vr_contador IN vr_tab_tab.FIRST..vr_tab_tab.LAST LOOP

          IF vr_contador IN (7,8)THEN
            CONTINUE;
          END IF;
          
          vr_tab_tab.DELETE(vr_contador);

        END LOOP;
      END IF;

      FOR ind IN vr_tab_tab.FIRST..vr_tab_tab.LAST LOOP
        IF vr_tab_tab.EXISTS(ind) THEN
          vr_tab_tab_aux(vr_tab_tab(ind).dstpeven).dstpeven := vr_tab_tab(ind).dstpeven;
          vr_tab_tab_aux(vr_tab_tab(ind).dstpeven).tpevento := vr_tab_tab(ind).tpevento;
        END IF;
      END LOOP;
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');
      
      -- Percorre todas os registros de tipos de evento
      vr_indexaux := vr_tab_tab_aux.FIRST();
      vr_contador := 0;
      WHILE vr_indexaux IS NOT NULL LOOP
        
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'tpevento',pr_tag_cont => vr_tab_tab_aux(vr_indexaux).tpevento, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dstpeven',pr_tag_cont => vr_tab_tab_aux(vr_indexaux).dstpeven, pr_des_erro => vr_dscritic);

        vr_indexaux := vr_tab_tab_aux.NEXT(vr_indexaux);
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
        pr_dscritic := 'Erro geral em PC_CARREGA_TIPO_EVENTO: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_carrega_tipo_evento;

END WPGD0107;
/
