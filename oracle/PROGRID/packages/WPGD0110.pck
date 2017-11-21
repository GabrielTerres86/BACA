CREATE OR REPLACE PACKAGE PROGRID.WPGD0110 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0110
  --  Sistema  : Rotinas para Sugestao de Eventos do Progrid
  --  Sigla    : WPGD
  --  Autor    : Carlos Rafael Tanholi (CECRED)
  --  Data     : Dezembro/2015.                   Ultima atualizacao:  31/08/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Sugestao de Eventos do Progrid
  --
  --  Alteracoes: 13/04/2016 - Criacao da procedure pc_lista_evento_dtsugest para 
  --                           carregamento dos eventos de filtro levando em consideracao 
  --                           os filtros de ano, cooperativa e agencia
  --                           (Carlos Rafael Tanholi).
  --
  --              31/05/2016 - Alteracao da procedure pc_lista_evento_dtsugest para 
  --                           carregar eventos apenas por Cooperativa e Ano.
  --                           (Carlos Rafael Tanholi).  
  --
  --              31/08/2017 - Inclusão do parâmetro pr_nrseqpgm, Prj. 322 (Jean Michel).
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_lista_sugestao_eventos(pr_dtanoage IN crapeap.dtanoage%TYPE --> Filtro de ANO
                                     ,pr_cdcooper IN VARCHAR2              --> Codigo da Cooperativa
                                     ,pr_cdagenci IN VARCHAR2              --> Codigo do PA               
                                     ,pr_nrseqpgm IN crapedp.nrseqpgm%TYPE --> Programa
                                     ,pr_cdevento IN VARCHAR2              --> Codigo do Evento
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);           --> Erros do processo  
                                     
  PROCEDURE pc_lista_evento_dtsugest(pr_cdcooper IN VARCHAR2              --> Codigo da Cooperativa
                                    ,pr_cdagenci IN VARCHAR2            	--> Codigo da Agencia (PA)    
                                    ,pr_dtanoage IN crapeap.dtanoage%TYPE --> Ano do filtro
                                    ,pr_nrseqpgm IN crapedp.nrseqpgm%TYPE --> Programa
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro                                     
END WPGD0110;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0110 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0110
  --  Sistema  : Rotinas para Sugestao de Eventos do Progrid
  --  Sigla    : WPGD
  --  Autor    : Carlos Rafael Tanholi (CECRED)
  --  Data     : Dezembro/2015.                   Ultima atualizacao:  31/08/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Sugestao de Eventos do Progrid
  --
  --  Alteracoes: 13/04/2016 - Criacao da procedure pc_lista_evento_dtsugest para 
  --                           carregamento dos eventos de filtro levando em consideracao 
  --                           os filtros de ano, cooperativa e agencia
  --                           (Carlos Rafael Tanholi).
  --
  --              31/05/2016 - Alteracao da procedure pc_lista_evento_dtsugest para 
  --                           carregar eventos apenas por Cooperativa e Ano.
  --                           (Carlos Rafael Tanholi).	            
  --
  --              05/07/2016 - Exibir ministrantes - PRJ229 - Melhorias OQS (Odirlei-AMcom)
  --
  --              31/08/2017 - Inclusão do parâmetro pr_nrseqpgm, Prj. 322 (Jean Michel).
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_lista_sugestao_eventos(pr_dtanoage IN crapeap.dtanoage%TYPE --> Filtro de ANO
                                     ,pr_cdcooper IN VARCHAR2              --> Codigo da Cooperativa
                                     ,pr_cdagenci IN VARCHAR2              --> Codigo do PA             	
                                     ,pr_nrseqpgm IN crapedp.nrseqpgm%TYPE --> Programa
                                     ,pr_cdevento IN VARCHAR2              --> Codigo do Evento
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo  
                                 
    BEGIN      
           
    /* .............................................................................

    Programa: pc_lista_sugestao_eventos
    Sistema : Progrid
    Sigla   : WPGD
    Autor   : Carlos Rafael Tanholi
    Data    : Dezembro/15.                    Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina de relatorio de sugestao de eventos Progrid.

    Observacao: -----

    Alteracoes: 05/07/2016 - Exibir ministrantes - PRJ229 - Melhorias OQS (Odirlei-AMcom)
                           
                31/08/2017 - Inclusão do parâmetro pr_nrseqpgm, Prj. 322 (Jean Michel).
    ..............................................................................*/   
                
    DECLARE
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_contador PLS_INTEGER := 0;  
      vr_lsminist VARCHAR2(4000);        
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;  
    
      -- cursor de listagem de eventos   
      CURSOR cr_relatorio(pr_dtanoage IN crapeap.dtanoage%TYPE
                         ,pr_cdcooper IN VARCHAR2
                         ,pr_cdagenci IN VARCHAR2
                         ,pr_cdevento IN VARCHAR2) IS    
                         
      SELECT DISTINCT       
             c.idevento, 
             c.dtanoage,
             c.cdcooper,
             cp.nmrescop,
             c.cdagenci,
             ca.nmresage,
             c.cdevento,
             ce.nmevento,
             cs.nrocoeve,
             cs.dsdatsug,
             --tratamento para campo hora com formato (1200,1545,1830)
             DECODE(cs.hrsugini, '2400', '24:00', to_char(to_date(LPAD(cs.hrsugini,4,'0'),'hh24mi'),'HH24:MI')) hrsugini,
             cs.dsdatop1,
             cs.dsdatop2,
             cs.dsobserv
      FROM crapeap c, 
           crapsde cs,
           crapcop cp,
           crapage ca,
           crapedp ce
      WHERE c.idevento = cs.idevento(+)
        AND c.cdcooper = cs.cdcooper(+)
        AND c.dtanoage = cs.dtanoage(+)
        AND c.cdevento = cs.cdevento(+)
        AND c.cdagenci = cs.cdagenci(+)
        AND cp.cdcooper = c.cdcooper
        AND ca.cdcooper = c.cdcooper
        AND ca.cdagenci = c.cdagenci
        AND ce.idevento = c.idevento
        AND ce.cdcooper = c.cdcooper
        AND ce.dtanoage = c.dtanoage
        AND ce.cdevento = c.cdevento
        AND ce.tpevento NOT IN(7,8,10,11,12,13,14,15,16)
        AND c.dtanoage = pr_dtanoage        
        AND c.flgevsel = 1        
        AND (ce.nrseqpgm = pr_nrseqpgm OR pr_nrseqpgm = 0)      
        AND (INSTR(','||pr_cdcooper||',', ','||c.cdcooper||',') > 0 OR pr_cdcooper = '0')
        AND (INSTR(','||pr_cdevento||',', ','||c.cdevento||',') > 0 OR pr_cdevento = '0')
        AND (INSTR(','||pr_cdagenci||',', ','||TO_CHAR(c.cdcooper||'|'||c.cdagenci)||',') > 0 OR pr_cdagenci = '0')
        AND       cs.hrsugini IS NOT NULL
     ORDER BY c.dtanoage,c.cdcooper,c.cdagenci,ce.nmevento,cs.nrocoeve;
    
      rw_relatorio cr_relatorio%ROWTYPE;

      --> Buscar facilitadores do evento
      CURSOR cr_gnapfep(pr_idevento  crapcdp.idevento%TYPE,
                        pr_cdcooper  crapcdp.cdcooper%TYPE,
                        pr_cdagenci  crapcdp.cdagenci%TYPE,
                        pr_dtanoage  crapcdp.dtanoage%TYPE,
                        pr_cdevento  crapcdp.cdevento%TYPE)IS
        SELECT fa.nmfacili
          FROM  crapcdp co
               ,gnfacep fp
               ,gnapfep fa
         WHERE co.idevento = pr_idevento
           AND co.cdcooper = pr_cdcooper
           AND co.cdagenci = pr_cdagenci
           AND co.dtanoage = pr_dtanoage
           AND co.cdevento = pr_cdevento
           AND co.tpcuseve = 1
           AND co.cdcuseve = 1
           AND co.idevento = fp.idevento(+)
           AND fp.cdcooper(+) = 0
           AND co.nrcpfcgc = fp.nrcpfcgc(+)
           AND UPPER(co.nrpropos) = UPPER(fp.nrpropos(+))
           AND fp.idevento = fa.idevento(+)
           AND fp.cdcooper = fa.cdcooper(+)
           AND fp.nrcpfcgc = fa.nrcpfcgc(+)
           AND fp.cdfacili = fa.cdfacili(+);
      
    
    BEGIN
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      OPEN cr_relatorio(pr_dtanoage => pr_dtanoage
                       ,pr_cdcooper => pr_cdcooper
                       ,pr_cdagenci => pr_cdagenci
                       ,pr_cdevento => pr_cdevento);
          
      LOOP
        FETCH cr_relatorio INTO rw_relatorio;
          
        -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
        EXIT WHEN cr_relatorio%NOTFOUND; 

        --> Buscar facilitadores do evento
        vr_lsminist := NULL;
        FOR rw_gnapfep IN cr_gnapfep (pr_idevento  => rw_relatorio.idevento,
                                      pr_cdcooper  => rw_relatorio.cdcooper,
                                      pr_cdagenci  => rw_relatorio.cdagenci,
                                      pr_dtanoage  => rw_relatorio.dtanoage,
                                      pr_cdevento  => rw_relatorio.cdevento) LOOP
                              
          IF vr_lsminist IS NOT NULL THEN
            vr_lsminist := vr_lsminist||',<br>'|| rw_gnapfep.nmfacili;
          ELSE
            vr_lsminist :=  rw_gnapfep.nmfacili;
          END IF;
        END LOOP;                      
              
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados',pr_posicao => 0          , pr_tag_nova => 'inf',      pr_tag_cont => NULL,                  pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'dtanoage', pr_tag_cont => rw_relatorio.dtanoage, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_relatorio.cdcooper, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_relatorio.nmrescop, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_relatorio.cdagenci, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'nmresage', pr_tag_cont => rw_relatorio.nmresage, pr_des_erro => vr_dscritic); 
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_relatorio.cdevento, pr_des_erro => vr_dscritic);                         
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_relatorio.nmevento, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'nrocoeve', pr_tag_cont => rw_relatorio.nrocoeve, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'dsdatsug', pr_tag_cont => rw_relatorio.dsdatsug, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'hrsugini', pr_tag_cont => rw_relatorio.hrsugini, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'dsdatop1', pr_tag_cont => rw_relatorio.dsdatop1, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'dsdatop2', pr_tag_cont => rw_relatorio.dsdatop2, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'dsobserv', pr_tag_cont => rw_relatorio.dsobserv, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'lsminist', pr_tag_cont => vr_lsminist          , pr_des_erro => vr_dscritic);
        
        vr_contador := vr_contador + 1;

      END LOOP;

    EXCEPTION

      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro Geral na Listagem Sugestoes de Eventos: ' || SQLERRM;
        
    END;                         
                                   
                    
  END pc_lista_sugestao_eventos;                                      



  /* Procedure para listar os eventos do sistema */
  PROCEDURE pc_lista_evento_dtsugest(pr_cdcooper IN VARCHAR2              --> Codigo da Cooperativa
                                    ,pr_cdagenci IN VARCHAR2            	--> Codigo da Agencia (PA)    
                                    ,pr_dtanoage IN crapeap.dtanoage%TYPE --> Ano do filtro
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- .........................................................................
    --
    --  Programa : pc_lista_evento
    --  Sistema  : Rotinas para listar os eventos do sistema por cooperativa, agencia e ano
    --  Sigla    : GENE
    --  Autor    : Carlos Rafael Tanholi
    --  Data     : Abril/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de eventos do sistema.
    --
    --
    -- .............................................................................
  BEGIN
    DECLARE

      -- Cursor sobre o cadastro de eventos
      CURSOR cr_crapedp IS
      SELECT cdevento, nmevento
        FROM crapedp
       WHERE (cdcooper = 0)
       ORDER BY nmevento;
        
      rw_crapedp cr_crapedp%ROWTYPE;


      -- Cursor sobre os eventos da agenda 
      CURSOR cr_crapedp_age IS
      SELECT DISTINCT edp.cdevento, edp.nmevento
        FROM crapedp edp,
             crapeap eap
       WHERE (edp.cdcooper = eap.cdcooper)
         AND (eap.cdevento = edp.cdevento)
         AND (edp.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
         AND (eap.cdagenci = pr_cdagenci OR pr_cdagenci = 0)
         AND (eap.dtanoage = pr_dtanoage OR pr_dtanoage = 0)
       ORDER BY edp.nmevento;
        
      rw_crapedp_age cr_crapedp_age%ROWTYPE;      
      
      -- Cursor sobre os eventos da agenda 
      CURSOR cr_crapedp_coop_age(pr_cdcoop_agenci IN VARCHAR2) IS
      SELECT DISTINCT ce.cdevento, ce.nmevento       
      FROM crapeap c, 
           crapsde cs,
           crapcop cp,
           crapage ca,
           crapedp ce
      WHERE c.idevento = cs.idevento(+)
        AND c.cdcooper = cs.cdcooper(+)
        AND c.dtanoage = cs.dtanoage(+)
        AND c.cdevento = cs.cdevento(+)
        AND c.cdagenci = cs.cdagenci(+)
        AND cp.cdcooper = c.cdcooper
        AND ca.cdcooper = c.cdcooper
        AND ca.cdagenci = c.cdagenci
        AND ce.idevento = c.idevento
        AND ce.cdcooper = c.cdcooper
        AND ce.dtanoage = c.dtanoage
        AND ce.cdevento = c.cdevento         
        AND ce.tpevento NOT IN(7,8,10,11,12,13,14,15,16)
        AND c.flgevsel = 1  
        AND cs.hrsugini IS NOT NULL                 
        AND (c.dtanoage = pr_dtanoage OR pr_dtanoage = 0)         
        AND (ce.cdcooper|| '|' ||c.cdagenci = pr_cdcoop_agenci OR (pr_cdcoop_agenci = '0' AND (INSTR(','||pr_cdcooper||',', ','||c.cdcooper||',') > 0) ) )
      ORDER BY ce.nmevento;
        
      rw_crapedp_coop_age cr_crapedp_coop_age%ROWTYPE;
      
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
      
      arr_agencias GENE0002.typ_split;      
      vr_cdcopage crapcop.cdcooper%TYPE;
    
    BEGIN
          
      IF ( pr_cdagenci <> '0' ) THEN

        IF ( instr(pr_cdagenci, '|') > 0 ) THEN
          
          arr_agencias := GENE0002.fn_quebra_string(pr_string => pr_cdagenci, pr_delimit => ',');           
          
          FOR vr_cdcopage IN arr_agencias.FIRST..arr_agencias.LAST LOOP    

            FOR rw_crapedp_coop_age IN cr_crapedp_coop_age(arr_agencias(vr_cdcopage)) LOOP

              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp_coop_age.cdevento, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp_coop_age.nmevento, pr_des_erro => vr_dscritic);
              vr_contador := vr_contador + 1;
                          
            END LOOP;
            
          END LOOP;      
          
        END IF;
      vr_contador := 0;
      ELSE 
        FOR rw_crapedp_coop_age IN cr_crapedp_coop_age(pr_cdagenci) LOOP

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp_coop_age.cdevento, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp_coop_age.nmevento, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;
                            
        END LOOP;      
      
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0; 
        pr_des_erro := 'Erro geral em WPGD0110.PC_LISTA_EVENTO_DTSUGEST: ' || SQLERRM;
        pr_dscritic := 'Erro geral em WPGD0110.PC_LISTA_EVENTO_DTSUGEST: ' || SQLERRM;
    END;

  END pc_lista_evento_dtsugest;


-----------------------------------------------------                       
END WPGD0110;
/
