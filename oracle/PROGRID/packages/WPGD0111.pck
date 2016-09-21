CREATE OR REPLACE PACKAGE PROGRID.WPGD0111 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0111
  --  Sistema  : Rotinas para relatorio de eventos raiz
  --  Sigla    : WPGD
  --  Autor    : Carlos Rafael Tanholi (CECRED)
  --  Data     : Novembro/2015.                   Ultima atualizacao:  10/12/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para a tela WPGD0111 do Progrid.
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Gera relatório para a tela WPGD0111.
  PROCEDURE pc_lista_historico_eventos(pr_lstevent IN VARCHAR2          --> lista de eventos para o relatorio
                                      ,pr_xmllog   IN VARCHAR2          --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER      --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2         --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType--> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2         --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);       --> Erros do processo
                                      
  /* Procedure para listar os eventos do sistema */
  PROCEDURE pc_lista_eventos_raiz(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro                                      
END WPGD0111;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0111 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0111
  --  Sistema  : Rotinas para relatorio de eventos raiz
  --  Sigla    : WPGD
  --  Autor    : Carlos Rafael Tanholi (CECRED)
  --  Data     : Novembro/2015.                   Ultima atualizacao:  10/12/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Publico Alvo
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Gera relatório para a tela WPGD0111.
  PROCEDURE pc_lista_historico_eventos(pr_lstevent IN VARCHAR2            --> lista de eventos para o relatorio
                                      ,pr_xmllog   IN VARCHAR2            --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
      
      CURSOR cr_crapedp(pr_cdevento IN crapedp.cdevento%TYPE) IS
        select c.cdevento  cdevento
              ,c.nmevento  nmevento
              ,ct.nrseqtem nrseqtem
              ,ct.dstemeix dstemeix
              ,g.cdeixtem  cdeixtem
              ,g.dseixtem  dseixtem
              ,cp.nrseqpri nrseqpri
              ,cp.nmprcins nmprcins
              ,Decode(c.tpevento,1,'CURSO'
                                ,2,'INTEGRACAO DE NOVOS SOCIOS'
                                ,3,'GINCANA'
                                ,4,'PALESTRA'
                                ,5,'TEATRO'
                                ,6,'OUTROS'
                                ,7,'ASSEMBLEIA'
                                ,8,'PRE-ASSEMBLEIA'
                                ,9,'PROGRAMA'
                                ,10,'EAD'
                                ,11,'ENCONTRO DE NEGÓCIOS'
                                ,'TIPO NÃO DEFINIDO') tipo
              ,c.qtmaxtur qtmaxtur
              ,c.qtmintur qtmintur
              ,decode(c.tppartic,1,'ABERTO A COMUNIDADE'
                               ,2,'EXCLUSIVO A COOPERADOS'
                               ,3,'LIMITADO POR CONTA'
                               ,4,'EXCLUSIVO A COMUNIDADE'
                               ,5,'EAD'
                               ,'NÃO DEFINIDO') tppartic
              ,c.qtparcta qtparcta
              ,decode(c.flgcompr,0,'Não',1,'Sim') flgcompr
              ,decode(c.flgtdpac,0,'Não',1,'Sim') flgtdpac
              ,decode(c.flgcerti,0,'Não',1,'Sim') flgcerti
              ,decode(c.flgrestr,0,'Não',1,'Sim') flgrestr
              ,decode(c.flgativo,0,'Não',1,'Sim') flgativo
              ,decode(c.flgsorte,0,'Não',1,'Sim') flgsorte
              ,c.nridamin nridamin
              ,c.prfreque prfreque
              ,c.cdoperad cdoperad
              ,c.dsjustif dsjustif
              ,c.qtdiaeve qtdiaeve
              ,decode(c.idrespub,'N','Não','S','Sim') idrespub
         from crapedp c
             ,craptem ct
             ,gnapetp g 
             ,crappri cp
        where c.idevento = 1
          AND c.cdcooper = 0
          AND c.dtanoage = 0
          AND ct.nrseqtem(+) = c.nrseqtem
          AND g.cdeixtem(+) = ct.cdeixtem
          AND cp.nrseqpri(+) = c.nrseqpri
          AND c.cdevento = DECODE(pr_cdevento,0,c.cdevento,pr_cdevento);
          
      CURSOR cr_craphev (pr_cdevento IN craphev.cdevento%TYPE) IS
        SELECT to_char(ch.dtatuali, 'DD/MM/RRRR')||' - '||to_char(to_date(ch.hratuali,'SSSSS'),'HH:MM:SS') data 
              ,decode(nvl(a.COMMENTS,ch.nmdcampo),'FLGATIVO','Ativo',nvl(a.COMMENTS,ch.nmdcampo)) campo_alterado
              ,ch.dsantcmp valor_anterior
              ,ch.dsatucmp valor_atual
              ,co.cdoperad||'-'|| co.nmoperad operador
          FROM craphev ch
              ,all_col_comments a
              ,crapope co
         WHERE ch.idevento = 1
           AND ch.cdcooper = 0
           AND ch.dtanoage = 0
           AND a.TABLE_NAME(+) = 'CRAPEDP'
           AND a.COLUMN_NAME(+) = decode(ch.nmdcampo,'QTMIMTUR','QTMINTUR',ch.nmdcampo)
           AND co.cdcooper(+) = ch.cdcopope
           AND co.cdoperad(+) = ch.cdoperad
           AND ch.cdevento = pr_cdevento
         ORDER BY ch.dtatuali DESC,ch.hratuali DESC;
      
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
      
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;    
      vr_ind NUMBER;
      
      arr_eventos GENE0002.typ_split;
      
      -- Variáveis para armazenar as informações em XML
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600);
      ---------------------------> SUBROTINAS <--------------------------
      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                               pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
      BEGIN
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      END;      
      
      
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
      
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;

      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>');      
      
      arr_eventos := GENE0002.fn_quebra_string(pr_string => pr_lstevent, pr_delimit => ';');
      
     
      FOR vr_ind IN arr_eventos.FIRST..arr_eventos.LAST LOOP    
      
        FOR rw_crapedp IN cr_crapedp(arr_eventos(vr_ind)) LOOP
            pc_escreve_xml ('<evento cdevento="' || rw_crapedp.cdevento || '"' ||
                                   ' nmevento="' || rw_crapedp.nmevento || '"' ||
                                   ' nrseqtem="' || rw_crapedp.nrseqtem || '"' ||
                                   ' dstemeix="' || rw_crapedp.dstemeix || '"' ||
                                   ' cdeixtem="' || rw_crapedp.cdeixtem || '"' ||
                                   ' dseixtem="' || rw_crapedp.dseixtem || '"' ||
                                   ' nrseqpri="' || rw_crapedp.nrseqpri || '"' ||
                                   ' nmprcins="' || rw_crapedp.nmprcins || '"' ||
                                   ' tipo="'     || rw_crapedp.tipo     || '"' ||
                                   ' qtmaxtur="' || rw_crapedp.qtmaxtur || '"' ||
                                   ' qtmintur="' || rw_crapedp.qtmintur || '"' ||
                                   ' tppartic="' || rw_crapedp.tppartic || '"' ||
                                   ' qtparcta="' || rw_crapedp.qtparcta || '"' ||
                                   ' flgcompr="' || rw_crapedp.flgcompr || '"' ||
                                   ' flgtdpac="' || rw_crapedp.flgtdpac || '"' ||
                                   ' flgcerti="' || rw_crapedp.flgcerti || '"' ||
                                   ' flgrestr="' || rw_crapedp.flgrestr || '"' ||
                                   ' flgativo="' || rw_crapedp.flgativo || '"' ||
                                   ' flgsorte="' || rw_crapedp.flgsorte || '"' ||
                                   ' nridamin="' || rw_crapedp.nridamin || '"' ||
                                   ' prfreque="' || rw_crapedp.prfreque || '"' ||
                                   ' cdoperad="' || rw_crapedp.cdoperad || '"' ||
                                   ' dsjustif="' || rw_crapedp.dsjustif || '"' ||
                                   ' idrespub="' || rw_crapedp.idrespub || '"' ||
                                   ' qtdiaeve="' || rw_crapedp.qtdiaeve || '" >');
          
          FOR rw_craphev IN cr_craphev(rw_crapedp.cdevento) LOOP
              pc_escreve_xml ('<alteracoes>');        
                pc_escreve_xml ('<data>'           || rw_craphev.data           || '</data>');
                pc_escreve_xml ('<campo_alterado>' || rw_craphev.campo_alterado || '</campo_alterado>');
                pc_escreve_xml ('<valor_anterior>' || rw_craphev.valor_anterior || '</valor_anterior>');
                pc_escreve_xml ('<valor_atual>'    || rw_craphev.valor_atual    || '</valor_atual>');
                pc_escreve_xml ('<operador>'       || rw_craphev.operador       || '</operador>');
              pc_escreve_xml ('</alteracoes>');
          END LOOP;
          
          pc_escreve_xml ('</evento>');
          
        END LOOP;      
      END LOOP;            
      
      --> Descarregar buffer
      pc_escreve_xml ('</Root>',TRUE);

      pr_retxml := XMLType.createXML(vr_des_xml);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
 
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
  END pc_lista_historico_eventos;


  /* Procedure para listar os eventos do sistema */
  PROCEDURE pc_lista_eventos_raiz(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_eventos_raiz
    --  Sistema  : Rotinas para listar os eventos do progrid especificos para tela WPGD0111
    --  Sigla    : GENE
    --  Autor    : Carlos Rafael Tanholi
    --  Data     : Marco/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de eventos do sistema.
    --
    --  Alteracoes: 
    --
    -- .............................................................................
  BEGIN
    DECLARE
      
      -- Cursor sobre o cadastro de eventos
      CURSOR cr_crapedp IS
      SELECT cdevento, nmevento
          FROM crapedp
         WHERE cdcooper = 0
           AND crapedp.idevento = 1 -- PROGRID
      GROUP BY cdevento, nmevento
      ORDER BY nmevento;

      rw_crapedp cr_crapedp%ROWTYPE;
            
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
      
      arr_agencias GENE0002.typ_split;      
      vr_cdcopage crapcop.cdcooper%TYPE;
    
    BEGIN
          
      FOR rw_crapedp IN cr_crapedp LOOP                  
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp.cdevento, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp.nmevento, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
            
      END LOOP;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em WPGD0111.PC_LISTA_EVENTOS_RAIZ: ' || SQLERRM;
        pr_dscritic := 'Erro geral em WPGD0111.PC_LISTA_EVENTOS_RAIZ: ' || SQLERRM;
    END;

  END pc_lista_eventos_raiz;


-----------------------------------------------------                       
END WPGD0111;
/
