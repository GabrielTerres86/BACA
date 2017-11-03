CREATE OR REPLACE PACKAGE PROGRID.WPGD0105 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0105                     
  --  Sistema  : Rotinas para tela de Recursos
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Setembro/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Recursos
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0105 para aba RECURSO
  PROCEDURE pc_wpgd0105(pr_idevento IN crapppc.idevento%TYPE --> Identificador de Evento(1 - Progrid / 2 - Assembléia)	
                       ,pr_nrseqdig IN gnaprdp.nrseqdig%TYPE --> Codigo Sequencial de Recurso
                       ,pr_dsrecurs IN gnaprdp.dsrecurs%TYPE --> Descricao do Recurso
                       ,pr_cdtiprec IN gnaprdp.cdtiprec%TYPE --> Codigo do Tipo de Recurso
                       ,pr_dstiprec IN gnaprdp.dsrecurs%TYPE --> Descricao do Tipo de Recurso
                       ,pr_idrecpor IN gnaprdp.idrecpor%TYPE --> Codigo de Recurso POr
                       ,pr_dsrecpor IN gnaprdp.dsrecurs%TYPE --> Descricao de Recurso POr
                       ,pr_idsitrec IN gnaprdp.idsitrec%TYPE --> Id de situação do Recurso
                       ,pr_dssitrec IN gnaprdp.dsrecurs%TYPE --> Descricao de situação do Recurso
                       ,pr_reclembr IN gnaprdp.idsitrec%TYPE --> Situacao de Recurso LEMBRETE(0-Nao Validado/1-Validado)
                       ,pr_nriniseq IN PLS_INTEGER           --> Registro inicial para pesquisa
                       ,pr_qtregist IN PLS_INTEGER           --> Quantidade de registros por pesquisa
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0105 para aba VALOR ANO
  PROCEDURE pc_valor_ano(pr_idevento IN crapvra.idevento%TYPE --> Identificador de Evento(1 - Progrid / 2 - Assembléia)
                        ,pr_nrseqdig IN crapvra.nrseqdig%TYPE --> Codigo sequencial
                        ,pr_dtanoage IN crapvra.dtanoage%TYPE --> Data da agenda
                        ,pr_cdcopvlr IN crapvra.cdcopvlr%TYPE --> Codigo da cooperativa da qual se refere o valor do recurso
                        ,pr_nrcpfcgc IN crapvra.nrcpfcgc%TYPE --> Codigo do Fornecedor
                        ,pr_vlrecano IN crapvra.vlrecano%TYPE --> Valor Recurso Ano
                        ,pr_nriniseq IN PLS_INTEGER           --> Registro inicial para pesquisa
                        ,pr_qtregist IN PLS_INTEGER           --> Quantidade de registros por pesquisa
                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
                      
  -- Rotina geral de consulta de fornecedores
  PROCEDURE pc_carrega_fornecedor(pr_flgativo IN INTEGER               --> Flag ativo (1- ATIVO / 0-INATIVO)
                                 ,pr_idtipfor IN gnapfdp.idtipfor%TYPE --> Tipo de Fornecedor                
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);            --> Descricao do Erro
END WPGD0105;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0105 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0105
  --  Sistema  : Rotinas para tela de Recursos
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Setembro/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Recursos.
  --
  -- Alteracoes:   
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral de insert, update, select e delete da tela WPGD0105 para aba RECURSO
  PROCEDURE pc_wpgd0105(pr_idevento IN crapppc.idevento%TYPE --> Identificador de Evento(1 - Progrid / 2 - Assembléia)	
                       ,pr_nrseqdig IN gnaprdp.nrseqdig%TYPE --> Codigo Sequencial de Recurso
                       ,pr_dsrecurs IN gnaprdp.dsrecurs%TYPE --> Descricao do Recurso
                       ,pr_cdtiprec IN gnaprdp.cdtiprec%TYPE --> Codigo do Tipo de Recurso
                       ,pr_dstiprec IN gnaprdp.dsrecurs%TYPE --> Descricao do Tipo de Recurso
                       ,pr_idrecpor IN gnaprdp.idrecpor%TYPE --> Codigo de Recurso POr
                       ,pr_dsrecpor IN gnaprdp.dsrecurs%TYPE --> Descricao de Recurso POr
                       ,pr_idsitrec IN gnaprdp.idsitrec%TYPE --> Id de situação do Recurso
                       ,pr_dssitrec IN gnaprdp.dsrecurs%TYPE --> Descricao de situação do Recurso
                       ,pr_reclembr IN gnaprdp.idsitrec%TYPE --> Situacao de Recurso LEMBRETE(0-Nao Validado/1-Validado)
                       ,pr_nriniseq IN PLS_INTEGER           --> Registro inicial para pesquisa
                       ,pr_qtregist IN PLS_INTEGER           --> Quantidade de registros por pesquisa
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro

      -- CURSORES
      
      -- Consulta Recursos
      CURSOR cr_gnaprdp IS
        SELECT rdp.idevento
              ,rdp.cdcooper
              ,rdp.nrseqdig
              ,rdp.dsrecurs
              ,NVL(rdp.cdtiprec,0) AS cdtiprec
              ,DECODE(rdp.cdtiprec,1,'BRINDES',2,'DIVULGAÇÃO',3,'EQUIPAMENTOS',4,'MATERIAIS',5,'LEMBRETE',6,'RECREAÇÃO','') AS dstiprec
              ,NVL(rdp.idrecpor,0) AS idrecpor
              ,DECODE(rdp.idrecpor,1,'EVENTO',2,'PARTICIPANTE',3,'QTD GRUPO PARTIC','') AS dsrecpor              
              ,DECODE(rdp.idsitrec,'1','ATIVO','0','INATIVO','') AS dssitrec
              ,NVL(rdp.idsitrec,1) AS idsitrec
              ,ROW_NUMBER() OVER(ORDER BY rdp.idevento, rdp.dsrecurs, rdp.nrseqdig) nrdseque
          FROM gnaprdp rdp
        WHERE rdp.idevento = pr_idevento
          AND (rdp.nrseqdig = pr_nrseqdig OR pr_nrseqdig = 0)
          AND ((UPPER(rdp.dsrecurs) LIKE '%' || UPPER(pr_dsrecurs) || '%') OR pr_dsrecurs IS NULL)
          AND (rdp.cdtiprec = pr_cdtiprec OR pr_cdtiprec = 0)
          AND ((DECODE(rdp.cdtiprec,1,'BRINDES' 
                                  ,2,'DIVULGACAO'
                                  ,3,'EQUIPAMENTOS'
                                  ,4,'MATERIAIS'
                                  ,5,'LEMBRETE'
                                  ,6,'RECREACAO')
                                  LIKE REPLACE(REPLACE(UPPER('%' || pr_dstiprec || '%'),'Ç','C'),'Ã','A')) OR pr_dstiprec IS NULL)
          AND (DECODE(rdp.idrecpor,1,'EVENTO' 
                                   ,2,'PARTICIPANTE'
                                   ,3,'QTD GRUPO PARTIC')
                                   LIKE UPPER('%' || pr_dsrecpor || '%') OR pr_dsrecpor IS NULL)
          AND (DECODE(rdp.idsitrec,1,'ATIVO' 
                                   ,0,'INATIVO')
                                   LIKE UPPER('%' || pr_dssitrec || '%') OR pr_dssitrec IS NULL)
                       
        ORDER BY rdp.idevento, rdp.dsrecurs, rdp.nrseqdig; 
 
      rw_gnaprdp cr_gnaprdp%ROWTYPE;
    
      CURSOR cr_craprep IS
        SELECT COUNT(*) AS contador
          FROM craprep rep
          WHERE rep.idevento = pr_idevento
            AND rep.nrseqdig = pr_nrseqdig;
            
      rw_craprep cr_craprep%ROWTYPE;

      CURSOR cr_craprdf IS
        SELECT COUNT(*) AS contador
          FROM craprdf rdf
          WHERE rdf.idevento = pr_idevento
            AND rdf.nrseqdig = pr_nrseqdig;
            
      rw_craprdf cr_craprdf%ROWTYPE;

      CURSOR cr_craprpe IS
        SELECT COUNT(*) AS contador
          FROM craprpe rpe
          WHERE rpe.idevento = pr_idevento
            AND rpe.nrseqdig = pr_nrseqdig;
            
      rw_craprpe cr_craprpe%ROWTYPE;
      
      CURSOR cr_crapvra(pr_idevento crapvra.idevento%TYPE
                       ,pr_nrseqdig crapvra.nrseqdig%TYPE
                       ,pr_cdcooper crapvra.cdcooper%TYPE) IS

        SELECT *
          FROM crapvra vra
         WHERE vra.idevento = pr_idevento
           AND vra.nrseqdig = pr_nrseqdig
           AND vra.cdcooper = pr_cdcooper;
            
      rw_crapvra cr_crapvra%ROWTYPE;
      
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
      vr_nrseqdig gnaprdp.nrseqdig%TYPE;

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

          -- Verifica se tipo do recurso é LEMBRETE(5)
          IF pr_cdtiprec = 5 AND pr_reclembr = 0 THEN
            -- Consulta Valores cadastrados
            OPEN cr_crapvra(pr_idevento => pr_idevento
                           ,pr_nrseqdig => pr_nrseqdig
                           ,pr_cdcooper => 0);

            FETCH cr_crapvra INTO rw_crapvra;
               
            IF cr_crapvra%NOTFOUND THEN
              CLOSE cr_crapvra; 
            ELSE
              CLOSE cr_crapvra;
              vr_dscritic := 99999;  
              RAISE vr_exc_saida;            
            END IF;

          ELSIF pr_cdtiprec = 5 AND pr_reclembr = 1 THEN 
            BEGIN
              DELETE crapvra WHERE crapvra.idevento = pr_idevento
                               AND crapvra.nrseqdig = pr_nrseqdig;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar registro de valor(CRAPVRA). Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;
          
          BEGIN
            UPDATE gnaprdp
               SET gnaprdp.dsrecurs = UPPER(pr_dsrecurs)
                  ,gnaprdp.cdtiprec = pr_cdtiprec
                  ,gnaprdp.idrecpor = pr_idrecpor
                  ,gnaprdp.idsitrec = pr_idsitrec
             WHERE gnaprdp.cdcooper = 0
               AND gnaprdp.idevento = pr_idevento
               AND gnaprdp.nrseqdig = pr_nrseqdig;

             vr_nrseqdig := pr_nrseqdig;
  
             IF SQL%ROWCOUNT = 0 THEN
                 BEGIN
                    INSERT INTO
                        gnaprdp(dsrecurs
                               ,cdtiprec
                               ,idrecpor
                               ,cdcooper
                               ,idevento
                               ,nrseqdig
                               ,idsitrec
                        )VALUES(UPPER(pr_dsrecurs)
                               ,pr_cdtiprec
                               ,pr_idrecpor
                               ,0
                               ,pr_idevento
                               ,gnaprdp_seq.nextval
                               ,pr_idsitrec) RETURNING nrseqdig INTO vr_nrseqdig;
                                 
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir registro. Erro: ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
             END IF;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atulizar registro. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nrseqdig', pr_tag_cont => vr_nrseqdig , pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cdtiprec', pr_tag_cont => pr_cdtiprec , pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'idrecpor', pr_tag_cont => pr_idrecpor , pr_des_erro => vr_dscritic);

        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

          FOR rw_gnaprdp IN cr_gnaprdp LOOP
                     
            IF ((pr_nriniseq <= rw_gnaprdp.nrdseque) AND (rw_gnaprdp.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                   
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idevento', pr_tag_cont => rw_gnaprdp.idevento, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_gnaprdp.cdcooper, pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqdig', pr_tag_cont => rw_gnaprdp.nrseqdig, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsrecurs', pr_tag_cont => rw_gnaprdp.dsrecurs, pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdtiprec', pr_tag_cont => rw_gnaprdp.cdtiprec, pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dstiprec', pr_tag_cont => rw_gnaprdp.dstiprec, pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idrecpor', pr_tag_cont => rw_gnaprdp.idrecpor, pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsrecpor', pr_tag_cont => rw_gnaprdp.dsrecpor, pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idsitrec', pr_tag_cont => rw_gnaprdp.idsitrec, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dssitrec', pr_tag_cont => rw_gnaprdp.dssitrec, pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdseque', pr_tag_cont => rw_gnaprdp.nrdseque, pr_des_erro => vr_dscritic);  

              vr_contador := vr_contador + 1;
            END IF;

            vr_totregis := vr_totregis +1;

          END LOOP;

          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

        WHEN 'E' THEN -- Exclusao

          -- Busca por recurso associado a evento
          OPEN cr_craprep;

          FETCH cr_craprep INTO rw_craprep;

          IF rw_craprep.contador > 0 THEN
            CLOSE cr_craprep;
            vr_dscritic := 'Recurso associado ao um Evento.';
            RAISE vr_exc_saida;
          END IF;
          
          CLOSE cr_craprep;
          
          -- Busca por recurso associado a fornecedor
          OPEN cr_craprdf;

          FETCH cr_craprdf INTO rw_craprdf;

          IF rw_craprdf.contador > 0 THEN
            CLOSE cr_craprdf;
            vr_dscritic := 'Recurso associado ao um Fornecedor.';
            RAISE vr_exc_saida;
          END IF;

          CLOSE cr_craprdf;

          -- Busca por recurso associado a PA
          OPEN cr_craprpe;

          FETCH cr_craprpe INTO rw_craprpe;

          IF rw_craprpe.contador > 0 THEN
            CLOSE cr_craprpe;
            vr_dscritic := 'Recurso associado ao um PA.';
            RAISE vr_exc_saida;
          END IF;

          CLOSE cr_craprpe;

          BEGIN
              DELETE FROM gnaprdp WHERE gnaprdp.idevento = pr_idevento and gnaprdp.cdcooper = 0 AND gnaprdp.nrseqdig = pr_nrseqdig;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao excluir registro(GNAPRDP). Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          BEGIN
            DELETE
              FROM crapvra 
             WHERE crapvra.idevento = pr_idevento
               AND crapvra.nrseqdig = pr_nrseqdig;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao excluir registro(CRAPVRA). Erro: ' || SQLERRM;
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
        pr_dscritic := 'Erro geral em PC_WPGD0105: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_wpgd0105;
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0105 para aba VALOR ANO
  PROCEDURE pc_valor_ano(pr_idevento IN crapvra.idevento%TYPE --> Identificador de Evento(1 - Progrid / 2 - Assembléia)
                        ,pr_nrseqdig IN crapvra.nrseqdig%TYPE --> Codigo sequencial
                        ,pr_dtanoage IN crapvra.dtanoage%TYPE --> Data da agenda
                        ,pr_cdcopvlr IN crapvra.cdcopvlr%TYPE --> Codigo da cooperativa da qual se refere o valor do recurso
                        ,pr_nrcpfcgc IN crapvra.nrcpfcgc%TYPE --> Codigo do Fornecedor
                        ,pr_vlrecano IN crapvra.vlrecano%TYPE --> Valor Recurso Ano
                        ,pr_nriniseq IN PLS_INTEGER           --> Registro inicial para pesquisa
                        ,pr_qtregist IN PLS_INTEGER           --> Quantidade de registros por pesquisa
                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
   
      -- CURSORES
      CURSOR cr_crapvra IS
        SELECT vra.idevento
              ,vra.cdcooper
              ,vra.nrseqdig
              ,vra.dtanoage
              ,vra.cdcopvlr
              ,cop.nmrescop
              ,vra.nrcpfcgc
              ,fdp.nmfornec
              ,vra.vlrecano
              ,vra.cdoperad
              ,vra.cdprogra
              ,vra.dtatuali
              ,ROW_NUMBER() OVER(ORDER BY vra.dtanoage DESC, cop.nmrescop ASC, fdp.nmfornec ASC)AS nrdseque
              ,vra.progress_recid
          FROM crapvra vra
              ,crapcop cop
              ,gnapfdp fdp
          WHERE vra.cdcopvlr = cop.cdcooper (+)
            AND vra.nrcpfcgc = fdp.nrcpfcgc (+)
            AND (vra.nrseqdig = pr_nrseqdig OR pr_nrseqdig = 0)
          ORDER BY vra.dtanoage DESC, cop.nmrescop ASC, fdp.nmfornec ASC;

      rw_crapvra cr_crapvra%ROWTYPE;

      CURSOR cr_crapcop(pr_flgativo crapcop.flgativo%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
          FROM crapcop cop
         WHERE cop.flgativo = pr_flgativo;

      rw_crapcop cr_crapcop%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela VARCHAR2(100) := 'wpgd0105';
      vr_nmdeacao VARCHAR2(100);
      vr_cddopcao VARCHAR2(100);
      vr_idcokses VARCHAR2(100);
      vr_idsistem INTEGER;

      -- Variáveis locais
      vr_contador PLS_INTEGER := 0;
      vr_totregis PLS_INTEGER := 0;
      vr_ultregis PLS_INTEGER := 0;
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
          IF pr_cdcopvlr = 99 THEN -- Selecao de TODAS as cooperativas
            FOR rw_crapcop IN cr_crapcop(pr_flgativo => 1) LOOP
              BEGIN
                UPDATE crapvra
                   SET crapvra.vlrecano = pr_vlrecano
                      ,crapvra.cdoperad = vr_cdoperad
                      ,crapvra.cdprogra = vr_nmdatela
                      ,crapvra.dtatuali = SYSDATE
                      ,crapvra.cdcopope = vr_cdcooper
                   WHERE crapvra.idevento = pr_idevento
                     AND crapvra.cdcooper = 0
                     AND crapvra.nrseqdig = pr_nrseqdig
                     AND crapvra.dtanoage = pr_dtanoage
                     AND crapvra.cdcopvlr = rw_crapcop.cdcooper
                     AND crapvra.nrcpfcgc = pr_nrcpfcgc;

                IF SQL%ROWCOUNT = 0 THEN
                  BEGIN
                    INSERT INTO
                        crapvra(idevento
                               ,cdcooper
                               ,nrseqdig
                               ,dtanoage
                               ,cdcopvlr
                               ,nrcpfcgc
                               ,vlrecano
                               ,cdoperad
                               ,cdprogra
                               ,dtatuali
                               ,cdcopope)
                         VALUES(pr_idevento
                               ,0
                               ,pr_nrseqdig
                               ,pr_dtanoage
                               ,rw_crapcop.cdcooper
                               ,pr_nrcpfcgc
                               ,pr_vlrecano
                               ,vr_cdoperad
                               ,vr_nmdatela
                               ,SYSDATE
                               ,vr_cdcooper);
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao inserir registro na cooperativa: ' || rw_crapcop.nmrescop ||'. Erro: ' || SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                END IF;     

              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atulizar registro na cooperativa: ' || rw_crapcop.nmrescop || '. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;    
              END;
            END LOOP; 
          ELSE -- Unica cooperativa selecionada
            BEGIN
              UPDATE crapvra
                 SET crapvra.vlrecano = pr_vlrecano
                    ,crapvra.cdoperad = vr_cdoperad
                    ,crapvra.cdprogra = vr_nmdatela
                    ,crapvra.dtatuali = SYSDATE
                    ,crapvra.cdcopope = vr_cdcooper
                 WHERE crapvra.idevento = pr_idevento
                   AND crapvra.cdcooper = 0
                   AND crapvra.nrseqdig = pr_nrseqdig
                   AND crapvra.dtanoage = pr_dtanoage
                   AND crapvra.cdcopvlr = pr_cdcopvlr
                   AND crapvra.nrcpfcgc = pr_nrcpfcgc;

              IF SQL%ROWCOUNT = 0 THEN
                BEGIN
                  INSERT INTO
                      crapvra(idevento
                             ,cdcooper
                             ,nrseqdig
                             ,dtanoage
                             ,cdcopvlr
                             ,nrcpfcgc
                             ,vlrecano
                             ,cdoperad
                             ,cdprogra
                             ,dtatuali
                             ,cdcopope)
                       VALUES(pr_idevento
                             ,0
                             ,pr_nrseqdig
                             ,pr_dtanoage
                             ,pr_cdcopvlr
                             ,pr_nrcpfcgc
                             ,pr_vlrecano
                             ,vr_cdoperad
                             ,vr_nmdatela
                             ,SYSDATE
                             ,vr_cdcooper);
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir registro. Erro: ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END IF;     

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atulizar registro. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;    
            END;
          END IF;
          
        WHEN 'C' THEN -- Consulta
          
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> <Dados/>');

          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'Registros', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

          FOR rw_crapvra IN cr_crapvra LOOP
                    
            IF ((pr_nriniseq <= rw_crapvra.nrdseque)AND (rw_crapvra.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                    
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Registros', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idevento'      , pr_tag_cont => rw_crapvra.idevento                      , pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper'      , pr_tag_cont => rw_crapvra.cdcooper                      , pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqdig'      , pr_tag_cont => rw_crapvra.nrseqdig                      , pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtanoage'      , pr_tag_cont => rw_crapvra.dtanoage                      , pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcopvlr'      , pr_tag_cont => rw_crapvra.cdcopvlr                      , pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop'      , pr_tag_cont => rw_crapvra.nmrescop                      , pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgc'      , pr_tag_cont => rw_crapvra.nrcpfcgc                      , pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmfornec'      , pr_tag_cont => rw_crapvra.nmfornec                      , pr_des_erro => vr_dscritic);
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlrecano'      , pr_tag_cont => TO_CHAR(rw_crapvra.vlrecano,'fm999G9990D000','NLS_NUMERIC_CHARACTERS=,.'), pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad'      , pr_tag_cont => rw_crapvra.cdoperad                      , pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra'      , pr_tag_cont => rw_crapvra.cdprogra                      , pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali'      , pr_tag_cont => TO_CHAR(rw_crapvra.dtatuali,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);  
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'progress_recid', pr_tag_cont => rw_crapvra.progress_recid                , pr_des_erro => vr_dscritic);  
              vr_contador := vr_contador + 1;
            END IF;

            vr_totregis := vr_totregis + 1;

          END LOOP;
          
          IF (pr_nriniseq + (pr_qtregist - 1)) > vr_totregis THEN 
            vr_ultregis := vr_totregis;
          ELSE
            vr_ultregis := (pr_nriniseq + (pr_qtregist - 1));
          END IF;

          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'iniregis', pr_tag_cont => pr_nriniseq, pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'fimregis', pr_tag_cont => vr_ultregis, pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis, pr_des_erro => vr_dscritic);

        WHEN 'E' THEN -- Exclusao
          BEGIN
            DELETE
              FROM crapvra 
             WHERE crapvra.idevento = pr_idevento
               AND crapvra.cdcooper = 0
               AND crapvra.nrseqdig = pr_nrseqdig
               AND crapvra.dtanoage = pr_dtanoage
               AND crapvra.cdcopvlr = pr_cdcopvlr
               AND crapvra.nrcpfcgc = pr_nrcpfcgc;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao excluir registro. Erro: ' || SQLERRM;
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
        pr_dscritic := 'Erro geral em PC_VALOR_ANO: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_valor_ano; 
           
  -- Rotina geral de consulta de fornecedores
  PROCEDURE pc_carrega_fornecedor(pr_flgativo IN INTEGER               --> Flag ativo (1- ATIVO / 0-INATIVO)
                                 ,pr_idtipfor IN gnapfdp.idtipfor%TYPE --> Tipo de Fornecedor               
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
   
      -- Consulta Recursos
      CURSOR cr_gnapfdp (pr_idtipfor IN gnapfdp.idtipfor%TYPE)IS
        SELECT fdp.idevento
              ,fdp.cdcooper
              ,fdp.nrcpfcgc
              ,fdp.inpessoa
              ,fdp.nmfornec
              ,fdp.nmhompag
              ,fdp.dtforati
              ,fdp.dtforina
              ,fdp.dsendfor
              ,fdp.nmbaifor
              ,fdp.nrcepfor
              ,fdp.nmcidfor
              ,fdp.cdufforn
              ,fdp.cddddfor
              ,fdp.nrfonfor
              ,fdp.cddddfax
              ,fdp.nrfaxfor
              ,fdp.flgcoope
              ,fdp.nmcoofor
              ,fdp.dtultalt
              ,fdp.cdoperad
              ,fdp.dsobserv
              ,fdp.dsreffor
              ,fdp.progress_recid
          FROM gnapfdp fdp
          WHERE (fdp.idtipfor = pr_idtipfor OR pr_idtipfor = 0)
        ORDER BY fdp.nmfornec; 
 
      rw_gnapfdp cr_gnapfdp%ROWTYPE;
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela VARCHAR2(100) := 'wpgd0105';
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
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

      FOR rw_gnapfdp IN cr_gnapfdp(pr_idtipfor => pr_idtipfor) LOOP
                                
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idevento'      ,pr_tag_cont => rw_gnapfdp.idevento      , pr_des_erro => vr_dscritic);
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper'      ,pr_tag_cont => rw_gnapfdp.cdcooper      , pr_des_erro => vr_dscritic);  
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgc'      ,pr_tag_cont => rw_gnapfdp.nrcpfcgc      , pr_des_erro => vr_dscritic);
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'inpessoa'      ,pr_tag_cont => rw_gnapfdp.inpessoa      , pr_des_erro => vr_dscritic);  
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmfornec'      ,pr_tag_cont => rw_gnapfdp.nmfornec      , pr_des_erro => vr_dscritic);  
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmhompag'      ,pr_tag_cont => rw_gnapfdp.nmhompag      , pr_des_erro => vr_dscritic);  
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtforati'      ,pr_tag_cont => rw_gnapfdp.dtforati      , pr_des_erro => vr_dscritic);  
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtforina'      ,pr_tag_cont => rw_gnapfdp.dtforina      , pr_des_erro => vr_dscritic);  
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsendfor'      ,pr_tag_cont => rw_gnapfdp.dsendfor      , pr_des_erro => vr_dscritic);  
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmbaifor'      ,pr_tag_cont => rw_gnapfdp.nmbaifor      , pr_des_erro => vr_dscritic);
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrcepfor'      ,pr_tag_cont => rw_gnapfdp.nrcepfor      , pr_des_erro => vr_dscritic);
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmcidfor'      ,pr_tag_cont => rw_gnapfdp.nmcidfor      , pr_des_erro => vr_dscritic);
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdufforn'      ,pr_tag_cont => rw_gnapfdp.cdufforn      , pr_des_erro => vr_dscritic);  
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cddddfor'      ,pr_tag_cont => rw_gnapfdp.cddddfor      , pr_des_erro => vr_dscritic);
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrfonfor'      ,pr_tag_cont => rw_gnapfdp.nrfonfor      , pr_des_erro => vr_dscritic);  
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cddddfax'      ,pr_tag_cont => rw_gnapfdp.cddddfax      , pr_des_erro => vr_dscritic);  
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrfaxfor'      ,pr_tag_cont => rw_gnapfdp.nrfaxfor      , pr_des_erro => vr_dscritic);  
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgcoope'      ,pr_tag_cont => rw_gnapfdp.flgcoope      , pr_des_erro => vr_dscritic);  
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmcoofor'      ,pr_tag_cont => rw_gnapfdp.nmcoofor      , pr_des_erro => vr_dscritic);  
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtultalt'      ,pr_tag_cont => rw_gnapfdp.dtultalt      , pr_des_erro => vr_dscritic);  
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad'      ,pr_tag_cont => rw_gnapfdp.cdoperad      , pr_des_erro => vr_dscritic);
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsobserv'      ,pr_tag_cont => rw_gnapfdp.dsobserv      , pr_des_erro => vr_dscritic);
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsreffor'      ,pr_tag_cont => rw_gnapfdp.dsreffor      , pr_des_erro => vr_dscritic);
--          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'progress_recid',pr_tag_cont => rw_gnapfdp.progress_recid, pr_des_erro => vr_dscritic);

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
        pr_dscritic := 'Erro geral em PC_CARREGA_FORNECEDOR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_carrega_fornecedor;    
   
END WPGD0105;
/
