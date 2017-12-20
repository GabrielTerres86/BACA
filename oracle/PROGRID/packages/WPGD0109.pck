CREATE OR REPLACE PACKAGE PROGRID.WPGD0109 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0109
  --  Sistema  : Rotinas para Eventos do Progrid
  --  Sigla    : WPGD
  --  Autor    : Carlos Rafael Tanholi (CECRED)
  --  Data     : Dezembro/2015.                   Ultima atualizacao:  02/12/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Eventos do Progrid
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_lista_eventos(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                            ,pr_cdeixtem IN gnapetp.cdeixtem%TYPE --> Codigo do Eixo
                            ,pr_nrseqtem IN craptem.nrseqtem%TYPE --> Numero do Tema
                            ,pr_nrseqpgm IN crapedp.nrseqpgm%TYPE --> Código do Programa
                            ,pr_cdevento IN crapedp.cdevento%TYPE --> Codigo do Evento
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Erros do processo  
                            
                            
  /* Procedure para listar os eixos do sistema */
  PROCEDURE pc_lista_eixo_grade(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro                            
                            
  /* Procedure para listar os temas do sistema */
  PROCEDURE pc_lista_tema_grade(pr_cdeixtem IN gnapetp.cdeixtem%TYPE --> Codigo do Eixo
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
                               
  /* Procedure para listar os eventos do sistema */                               
  PROCEDURE pc_lista_evento_grade(pr_cdeixtem IN gnapetp.cdeixtem%TYPE --> Codigo do Eixo
                                 ,pr_nrseqtem IN craptem.nrseqtem%TYPE --> Codigo do Tema
                                 ,pr_nrseqpgm IN crapedp.nrseqpgm%TYPE --> Código do Programa
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro                               
  
END WPGD0109;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0109 IS
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0109
  --  Sistema  : Rotinas para Eventos do Progrid
  --  Sigla    : WPGD
  --  Autor    : Carlos Rafael Tanholi (CECRED)
  --  Data     : Dezembro/2015.                   Ultima atualizacao:  02/12/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Eventos do Progrid
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_lista_eventos(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                            ,pr_cdeixtem IN gnapetp.cdeixtem%TYPE --> Codigo do Eixo
                            ,pr_nrseqtem IN craptem.nrseqtem%TYPE --> Numero do Tema
                            ,pr_nrseqpgm IN crapedp.nrseqpgm%TYPE --> Código do Programa
                            ,pr_cdevento IN crapedp.cdevento%TYPE --> Codigo do Evento
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo  
                                 
    BEGIN      
           
    /* .............................................................................

    Programa: pc_lista_eventos
    Sistema : Progrid
    Sigla   : WPGD
    Autor   : Carlos Rafael Tanholi
    Data    : Dezembro/15.                    Ultima atualizacao: 24/06/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina de relatorio de eventos Progrid.

    Observacao: -----

    Alteracoes: 24/06/2016 - Ajustado rotina para buscar o publico alvo da tabela CRAPPAE
                             PRJ229 - Melhorias OQS(Odirlei-AMcom)
    ..............................................................................*/   
                
    DECLARE
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_contador PLS_INTEGER := 0;          
      vr_dspubalv VARCHAR2(500);
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;  
    
      -- cursor de listagem de eventos   
      CURSOR cr_relatorio(pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_cdeixtem IN gnapetp.cdeixtem%TYPE
                         ,pr_nrseqtem IN craptem.nrseqtem%TYPE
                         ,pr_cdevento IN crapedp.cdevento%TYPE) IS    
                         
        SELECT DISTINCT c.idevento,
                        c.cdcooper,
                        c.dtanoage,
                        ge.dseixtem Eixo,
                        ct.dstemeix Tema,
                        Decode(c.tpevento, 1,'CURSO',
                                           2,'INTEGRACAO DE NOVOS SOCIOS',
                                           3,'GINCANA',
                                           4,'PALESTRA',
                                           5,'TEATRO',
                                           6,'OUTROS',
                                           7,'ASSEMBLEIA',
                                           8,'PRE-ASSEMBLEIA',
                                           9,'PROGRAMA',
                                          10,'EAD',
                                          11,'ENCONTRO DE NEGÓCIOS',
                                             'TIPO NÃO DEFINIDO') tipo,
                        c.cdevento,
                        c.nmevento,/*g.nrcpfcgc,g.nrpropos,g.dtvalpro,*/                        
                        c.qtmaxtur,
                        REPLACE(to_char(g.qtcarhor,'FM900D00'), '.', ':') qtcarhor
                  FROM crapedp c, gnappdp g, craptem ct, gnapetp ge
                 WHERE (c.cdcooper = 0)  
                   AND (ge.cdeixtem = pr_cdeixtem OR pr_cdeixtem = 0)
                   AND (ct.nrseqtem = pr_nrseqtem OR pr_nrseqtem = 0)
                   AND (g.cdevento = pr_cdevento OR pr_cdevento = 0)
                   AND c.dtanoage = 0 
                   AND c.flgativo = 1 
                   AND NVl(c.nrseqtem,0) <> 0
                   AND g.idevento = c.idevento 
                   AND g.cdcooper = c.cdcooper
                   AND g.cdevento = c.cdevento
                   AND g.dtvalpro >= trunc(sysdate)
                   AND ct.idevento = c.idevento
                   AND ct.cdcooper = c.cdcooper
                   AND ct.nrseqtem = c.nrseqtem
                   AND ge.idevento = ct.idevento
                   AND ge.cdcooper = ct.cdcooper
                   AND ge.cdeixtem = ct.cdeixtem 
                   AND (c.nrseqpgm = pr_nrseqpgm OR pr_nrseqpgm = 0 )
        ORDER BY ge.dseixtem ,ct.dstemeix,c.cdevento;
    
      rw_relatorio cr_relatorio%ROWTYPE;

      --> Buscar publico alvo do evento
      CURSOR cr_crappae (pr_idevento  crappae.idevento%TYPE,
                         pr_cdcooper  crappae.cdcooper%TYPE,
                         pr_dtanoage  crappae.dtanoage%TYPE,
                         pr_cdevento  crappae.cdevento%TYPE)IS
        SELECT pap.dspubalv
          FROM crappae pae,
               crappap pap
         WHERE pae.nrseqpap = pap.nrseqpap
           AND pae.idevento = pr_idevento
           AND pae.cdcooper = pr_cdcooper
           AND pae.dtanoage = pr_dtanoage
           AND pae.cdevento = pr_cdevento
           AND pae.nrseqpap = pap.nrseqpap
         ORDER BY pap.dspubalv;
    
    BEGIN
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      OPEN cr_relatorio(pr_cdcooper => pr_cdcooper
                       ,pr_cdeixtem => pr_cdeixtem
                       ,pr_nrseqtem => pr_nrseqtem 
                       ,pr_cdevento => pr_cdevento);
          
      LOOP
        FETCH cr_relatorio INTO rw_relatorio;
          
        -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
        EXIT WHEN cr_relatorio%NOTFOUND; 

        vr_dspubalv := NULL;
        --> Buscar publico alvo dos eventos
        FOR rw_crappae IN cr_crappae (pr_idevento  => rw_relatorio.idevento,
                                      pr_cdcooper  => rw_relatorio.cdcooper,
                                      pr_dtanoage  => rw_relatorio.dtanoage,
                                      pr_cdevento  => rw_relatorio.cdevento) LOOP
          IF vr_dspubalv IS NOT NULL THEN
            vr_dspubalv := vr_dspubalv ||', '||rw_crappae.dspubalv;
          ELSE
            vr_dspubalv := rw_crappae.dspubalv;
          END IF;
        END LOOP;                              
              
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados',pr_posicao => 0          , pr_tag_nova => 'inf',      pr_tag_cont => NULL,                  pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'eixo',     pr_tag_cont => rw_relatorio.eixo,     pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'tema',     pr_tag_cont => rw_relatorio.tema,     pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'tipo',     pr_tag_cont => rw_relatorio.tipo,     pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_relatorio.cdevento, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_relatorio.nmevento, pr_des_erro => vr_dscritic); 
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'dspubalv', pr_tag_cont => vr_dspubalv,           pr_des_erro => vr_dscritic);                         
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'qtmaxtur', pr_tag_cont => rw_relatorio.qtmaxtur, pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',  pr_posicao => vr_contador, pr_tag_nova => 'qtcarhor', pr_tag_cont => rw_relatorio.qtcarhor, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;

      END LOOP;

    EXCEPTION

      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro Geral na Listagem de Eventos: ' || SQLERRM;
        
    END;                         
                                   
                    
  END pc_lista_eventos;       
  
  
  
  
  /* Procedure para listar os eixos do sistema */
  PROCEDURE pc_lista_eixo_grade(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_eixo_grade
    --  Sistema  : Rotinas para listar os eixos do sistema
    --  Sigla    : GENE
    --  Autor    : Carlos Rafael Tanholi
    --  Data     : Marco/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de temas do sistema.
    --
    --  Alteracoes:
    --
    -- .............................................................................
  BEGIN
    DECLARE
      
      -- Cursor sobre o cadastro de eventos
      CURSOR cr_crapedp IS      
       SELECT DISTINCT ge.cdeixtem
                      ,ge.dseixtem
                  FROM crapedp c, 
                       gnappdp g, 
                       craptem ct, 
                       gnapetp ge
                 WHERE (c.cdcooper = 0)  
                   AND c.dtanoage = 0 
                   AND c.flgativo = 1 
                   AND NVl(c.nrseqtem,0) <> 0
                   AND g.idevento = c.idevento 
                   AND g.cdcooper = c.cdcooper
                   AND g.cdevento = c.cdevento
                   AND g.dtvalpro >= trunc(sysdate)
                   AND ct.idevento = c.idevento
                   AND ct.cdcooper = c.cdcooper
                   AND ct.nrseqtem = c.nrseqtem
                   AND ge.idevento = ct.idevento
                   AND ge.cdcooper = ct.cdcooper
                   AND ge.cdeixtem = ct.cdeixtem
	            ORDER BY ge.dseixtem; 
        
      rw_crapedp cr_crapedp%ROWTYPE;
      
      
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
    
    BEGIN
             
      FOR rw_crapedp IN cr_crapedp LOOP                  
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdeixtem', pr_tag_cont => rw_crapedp.cdeixtem, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dseixtem', pr_tag_cont => rw_crapedp.dseixtem, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
            
      END LOOP;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em PRGD0001.PC_LISTA_EIXO_GRADE: ' || SQLERRM;
        pr_dscritic := 'Erro geral em PRGD0001.PC_LISTA_EIXO_GRADE: ' || SQLERRM;
    END;

  END pc_lista_eixo_grade;
                                   

  /* Procedure para listar os temas do sistema */
  PROCEDURE pc_lista_tema_grade(pr_cdeixtem IN gnapetp.cdeixtem%TYPE --> Codigo do Eixo
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_tema_grade
    --  Sistema  : Rotinas para listar os temas do sistema por cooperativa e eixo
    --  Sigla    : GENE
    --  Autor    : Carlos Rafael Tanholi
    --  Data     : Marco/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de temas do sistema.
    --
    --  Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      
      -- Cursores
      CURSOR cr_craptem IS

        SELECT DISTINCT ct.nrseqtem,
                        ct.dstemeix                        
                  FROM crapedp c, 
                       gnappdp g, 
                       craptem ct, 
                       gnapetp ge
                 WHERE (c.cdcooper = 0)  
                   AND (ge.cdeixtem = pr_cdeixtem OR pr_cdeixtem = 0)
                   AND c.dtanoage = 0 
                   AND c.flgativo = 1 
                   AND NVl(c.nrseqtem,0) <> 0
                   AND g.idevento = c.idevento 
                   AND g.cdcooper = c.cdcooper
                   AND g.cdevento = c.cdevento
                   AND g.dtvalpro >= trunc(sysdate)
                   AND ct.idevento = c.idevento
                   AND ct.cdcooper = c.cdcooper
                   AND ct.nrseqtem = c.nrseqtem
                   AND ge.idevento = ct.idevento
                   AND ge.cdcooper = ct.cdcooper
                   AND ge.cdeixtem = ct.cdeixtem  
              ORDER BY ct.dstemeix;       
       
        
      rw_craptem cr_craptem%ROWTYPE;
        
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
      
    BEGIN
    
      FOR rw_craptem IN cr_craptem LOOP
          
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqtem', pr_tag_cont => rw_craptem.nrseqtem, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dstemeix', pr_tag_cont => rw_craptem.dstemeix, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
          
      END LOOP;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em PRGD0001.PC_LISTA_TEMA_GRADE: ' || SQLERRM;
        pr_dscritic := 'Erro geral em PRGD0001.PC_LISTA_TEMA_GRADE: ' || SQLERRM;
    END;

  END pc_lista_tema_grade;



  PROCEDURE pc_lista_evento_grade(pr_cdeixtem IN gnapetp.cdeixtem%TYPE --> Codigo do Eixo
                                 ,pr_nrseqtem IN craptem.nrseqtem%TYPE --> Codigo do Tema
                                 ,pr_nrseqpgm IN crapedp.nrseqpgm%TYPE --> Código do Programa
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_evento_grade
    --  Sistema  : Rotinas para listar os eventos do sistema eixo e tema
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
        SELECT DISTINCT c.cdevento,
                        c.nmevento
                  FROM crapedp c, 
                       gnappdp g, 
                       craptem ct, 
                       gnapetp ge
                 WHERE (c.cdcooper = 0)
                   AND c.dtanoage = 0 
                   AND c.flgativo = 1 
                   AND NVl(c.nrseqtem,0) <> 0
                   AND g.idevento = c.idevento 
                   AND g.cdcooper = c.cdcooper
                   AND g.cdevento = c.cdevento
                   AND g.dtvalpro >= trunc(sysdate)
                   AND ct.idevento = c.idevento
                   AND ct.cdcooper = c.cdcooper
                   AND ct.nrseqtem = c.nrseqtem
                   AND ge.idevento = ct.idevento
                   AND ge.cdcooper = ct.cdcooper
                   AND ge.cdeixtem = ct.cdeixtem  
                   AND (ge.cdeixtem = pr_cdeixtem OR pr_cdeixtem = 0)
                   AND (ct.nrseqtem = pr_nrseqtem OR pr_nrseqtem = 0)
                   AND (c.nrseqpgm = pr_nrseqpgm OR pr_nrseqpgm = 0)
              ORDER BY c.nmevento;         
      
      rw_crapedp cr_crapedp%ROWTYPE;
     
      
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
    
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
        pr_des_erro := 'Erro geral em PRGD0001.PC_LISTA_EVENTO_GRADE: ' || SQLERRM;
        pr_dscritic := 'Erro geral em PRGD0001.PC_LISTA_EVENTO_GRADE: ' || SQLERRM;
    END;

  END pc_lista_evento_grade;


-----------------------------------------------------                       
END WPGD0109;
/
