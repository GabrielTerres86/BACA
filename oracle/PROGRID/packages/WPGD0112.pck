CREATE OR REPLACE PACKAGE PROGRID.WPGD0112 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0112
  --  Sistema  : Rotinas para relatorio dos valores de custos dos eventos
  --  Sigla    : WPGD
  --  Autor    : Carlos Rafael Tanholi (CECRED)
  --  Data     : Marco/2016.                   Ultima atualizacao:  
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Custos dos Eventos do Progrid
  --
  -- Alteracoes: 30/08/2017 - Incluído filtro por Programas em ambas procedures, Prj. 322 (Jean Michel)
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- relatorio analitico
  PROCEDURE pc_relatorio_custos_orcados_a(pr_dtanoage IN crapagp.dtanoage%TYPE --> ano da agencia
                                         ,pr_cdcooper IN crapcop.cdcooper%TYPE --> codigo da cooperativa
                                         ,pr_cdagenci IN VARCHAR2              --> uma ou varias agencias
                                         ,pr_nrseqpgm IN crappgm.nrseqpgm%TYPE --> Código do Programa
                                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);
  
  -- relatorio sintetico
  PROCEDURE pc_relatorio_custos_orcados_s(pr_dtanoage IN crapagp.dtanoage%TYPE --> ano da agencia
                                         ,pr_cdcooper IN crapcop.cdcooper%TYPE --> codigo da cooperativa
                                         ,pr_cdagenci IN VARCHAR2              --> uma ou varias agencias
                                         ,pr_nrseqpgm IN crappgm.nrseqpgm%TYPE --> Código do Programa
                                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);           --> Erros do processo  

END WPGD0112;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0112 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0112
  --  Sistema  : Rotinas para relatorio ANALITICO dos valores de custos dos eventos
  --  Sigla    : WPGD
  --  Autor    : Carlos Rafael Tanholi (CECRED)
  --  Data     : Marco/2016.                   Ultima atualizacao: 08/06/2016 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Custos dos Eventos ANALITICO
  --
  -- Alteracoes:  08/06/2016 - Ajustado rotina para apresentara a carga horaria com :
  --                           PRJ229 - Melhorias OQS (Odirlei-AMcom)
  --
  --              30/08/2017 - Incluído filtro por Programas em ambas procedures, Prj. 322 (Jean Michel)
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Gera relatório ANALITICO para a tela WPGD0112.
  PROCEDURE pc_relatorio_custos_orcados_a(pr_dtanoage IN crapagp.dtanoage%TYPE --> ano da agencia
                                         ,pr_cdcooper IN crapcop.cdcooper%TYPE --> codigo da cooperativa
                                         ,pr_cdagenci IN VARCHAR2              --> uma ou varias agencias
                                         ,pr_nrseqpgm IN crappgm.nrseqpgm%TYPE --> Código do Programa
                                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
                                      
  BEGIN
    
    /* .............................................................................

    Programa: pc_relatorio_custos_orcados_a
    Sistema : Progrid
    Sigla   : WPGD
    Autor   : Carlos Rafael Tanholi
    Data    : Marco/16.                    Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina que gera relatorio ANALITICO de custos orçados de eventos do Progrid.

    Observacao: -----

    Alteracoes:
    ..............................................................................*/    
  
  
  	DECLARE
    
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;        
      
      -- Variáveis para armazenar as informações em XML
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600);   
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela craptel.nmdatela%TYPE;
      vr_nmdeacao crapaca.nmdeacao%TYPE;     
      vr_idcokses VARCHAR2(100);
      vr_idsistem craptel.idsistem%TYPE;
      vr_cddopcao VARCHAR2(100);      
      
      --------------------------> CURSORES <-----------------------------
      
      -- Cursor de eventos presenciais
      CURSOR cr_evenpre(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtanoage IN crapagp.dtanoage%TYPE
                       ,pr_cdagenci IN VARCHAR2) IS    
                        
        select PA,Eixo,Tema,Evento,Carga_Horaria,Max_Tur N_De_Part,Qt_Ocorrencia Qt_Eventos,
               sum(Honorario) * Qt_Ocorrencia Honorario,
               sum(Local)* Qt_Ocorrencia local,
               sum(Alimentacao)* Qt_Ocorrencia Alimentacao,
               sum(Materiais)* Qt_Ocorrencia Materiais,
               sum(Transporte)* Qt_Ocorrencia Transporte,
               sum(Brindes)* Qt_Ocorrencia Brindes,
               sum(Divulgacao)* Qt_Ocorrencia Divulgacao,
               sum(Outros)* Qt_Ocorrencia Outros ,
               (sum(Honorario) + sum(Local) + sum(Alimentacao) + sum(Materiais) + sum(Transporte) + sum(Brindes) + sum(Divulgacao) + sum(Outros))* Qt_Ocorrencia Total 
        from(
        select PA,Eixo,Tema,Evento,Carga_Horaria,Max_Tur,Qt_Ocorrencia,
               decode(Nm_Custo,'Honorario',vlcuseve,0) Honorario,
               decode(Nm_Custo,'Local',vlcuseve,0) Local,
               decode(Nm_Custo,'Alimentacao',vlcuseve,0) Alimentacao,
               decode(Nm_Custo,'Materiais',vlcuseve,0) Materiais,
               decode(Nm_Custo,'Transporte',vlcuseve,0) Transporte,
               decode(Nm_Custo,'Brindes',vlcuseve,0) Brindes,
               decode(Nm_Custo,'Divulgacao',vlcuseve,0) Divulgacao,
               decode(Nm_Custo,'Outros',vlcuseve,0) Outros
        from(
        select ca.nmresage PA,ge.dseixtem Eixo,ct.dstemeix Tema,cp.nmevento Evento,REPLACE(REPLACE(to_char(gp.qtcarhor,'FM99900D00'),',',':'),'.',':')  Carga_Horaria,
               decode(decode(NVL(ce.qtmaxtur,0),0,nvl(cp.qtmaxtur,0),NVL(ce.qtmaxtur,0))
                             ,0,nvl(cp2.qtmaxtur,0),
                      decode(NVL(ce.qtmaxtur,0),0,nvl(cp.qtmaxtur,0),NVL(ce.qtmaxtur,0))
                     ) AS Max_Tur,
               decode(ce.qtocoeve,0,1,ce.qtocoeve) Qt_Ocorrencia,
               decode(cd.cdcuseve,1,'Honorario',2,'Local',3,'Alimentacao',4,'Materiais',5,'Transporte',6,'Brindes',7,'Divulgacao',8,'Outros') Nm_Custo,
               cd.vlcuseve
        from crapeap ce, 
             crapcop cc,
             crapage ca,
             crapcdp cd,
             crapedp cp,
             craptem ct,
             crapedp cp2,
             gnapetp ge,
             gnappdp gp     
        where 
            cc.cdcooper = ce.cdcooper
            and ca.cdcooper = ce.cdcooper
            and ca.cdagenci = ce.cdagenci
            and cd.idevento = ce.idevento
            and cd.cdcooper = ce.cdcooper
            and cd.dtanoage = ce.dtanoage
            and cd.cdagenci = ce.cdagenci
            and ce.flgevsel = 1 -- Eventos Selecionados
            and cd.cdevento = ce.cdevento
            and cd.tpcuseve = 1
            and cp.idevento = ce.idevento
            and cp.cdcooper = ce.cdcooper
            and cp.dtanoage = ce.dtanoage
            and cp.cdevento = ce.cdevento
            and (cp.nrseqpgm = pr_nrseqpgm OR pr_nrseqpgm = 0)
            --Evento Raiz
            and cp2.idevento = ce.idevento
            and cp2.cdcooper = 0
            and cp2.dtanoage = 0
            and cp2.cdevento = ce.cdevento
            and ct.nrseqtem(+) = cp2.nrseqtem
            and ge.idevento(+) = ct.idevento
            and ge.cdcooper(+) = ct.cdcooper
            and ge.cdeixtem(+) = ct.cdeixtem
            and gp.idevento(+) = cd.idevento
            and gp.cdcooper(+) = 0
            and gp.nrcpfcgc(+) = cd.nrcpfcgc
            and gp.nrpropos(+) = cd.nrpropos
            and ce.cdcooper(+) = pr_cdcooper 
            and ce.dtanoage = pr_dtanoage 
            AND (INSTR(','||pr_cdagenci||',', ','||TO_CHAR(cd.cdagenci)||',') > 0 OR pr_cdagenci = '0')                    
            )
        )
        group by PA,Eixo,Tema,Evento,Carga_Horaria,Max_Tur,Qt_Ocorrencia
        order by 1,2,3,4;          
     
    
    
      -- Cursor de evento EAD
      CURSOR cr_evenead(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtanoage IN crapagp.dtanoage%TYPE
                       ,pr_cdagenci IN VARCHAR2) IS
                       
        select ca.nmresage PA,
               ge.dseixtem Eixo,
               ct.dstemeix Tema,
               cp.nmevento Evento,
               cp.dscarhor Carga_Horaria,
               cd.qtpareve n_de_part,
               cd.qtocoeve qt_eventos,
               cd.vlporins valor_por_insc,
               cd.vldeseve valor_desenv,
               (cd.vlporins * cd.qtpareve * cd.qtocoeve) + cd.vldeseve Total
        from 
             crapage ca,
             CRAPCED cd,
             crapedp cp,
             craptem ct,
             gnapetp ge 
        where 
            ca.cdcooper = cd.cdcooper
        and ca.cdagenci = cd.cdagenci
        -- Evento Raiz
        and cp.idevento = cd.idevento
        and cp.cdcooper = 0
        and cp.dtanoage = 0
        and cp.cdevento = cd.cdevento
        and (cp.nrseqpgm = pr_nrseqpgm OR pr_nrseqpgm = 0)
        and ct.nrseqtem(+) = cp.nrseqtem
        and ge.idevento(+) = ct.idevento
        and ge.cdcooper(+) = ct.cdcooper
        and ge.cdeixtem(+) = ct.cdeixtem
        and cd.cdcooper = pr_cdcooper 
        and cd.dtanoage = pr_dtanoage 
        AND (INSTR(','||pr_cdagenci||',', ','||TO_CHAR(cd.cdagenci)||',') > 0 OR pr_cdagenci = '0')        
        order by 1,2,3,4;      
       
    
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

      pc_escreve_xml('<presencial>');      
      
      -- percorre os eventos presenciais
      FOR rw_evenpre IN cr_evenpre(pr_cdcooper, pr_dtanoage, pr_cdagenci) LOOP
          rw_evenpre.eixo  := gene0007.fn_caract_controle(rw_evenpre.eixo);
          rw_evenpre.tema  := gene0007.fn_caract_controle(rw_evenpre.tema);
          rw_evenpre.evento:= gene0007.fn_caract_controle(rw_evenpre.evento);
                                      
          pc_escreve_xml ('<evento pa="' || rw_evenpre.pa || '"' ||
                                 ' eixo="' || rw_evenpre.eixo || '"' ||
                                 ' tema="' || rw_evenpre.tema || '"' ||
                                 ' evento="' || replace(rw_evenpre.evento,'"','''' ) || '"' ||
                                 ' carga_horaria="' || rw_evenpre.carga_horaria || '"' ||
                                 ' n_de_part="' || rw_evenpre.n_de_part || '"' ||
                                 ' qt_eventos="' || rw_evenpre.qt_eventos || '"' ||
                                 ' honorario="' || rw_evenpre.honorario || '"' ||
                                 ' local="'     || rw_evenpre.local     || '"' ||
                                 ' alimentacao="' || rw_evenpre.alimentacao || '"' ||
                                 ' materiais="' || rw_evenpre.materiais || '"' ||
                                 ' transporte="' || rw_evenpre.transporte || '"' ||
                                 ' brindes="' || rw_evenpre.brindes || '"' ||
                                 ' divulgacao="' || rw_evenpre.divulgacao || '"' ||
                                 ' outros="' || rw_evenpre.outros || '"' ||
                                 ' total="' || rw_evenpre.total || '" >');
         
        pc_escreve_xml ('</evento>');

      END LOOP;    
    
      pc_escreve_xml('</presencial>');          
    
      pc_escreve_xml('<ead>');          
      
      -- percorre os eventos EAD
      FOR rw_evenead IN cr_evenead(pr_cdcooper, pr_dtanoage, pr_cdagenci) LOOP
          rw_evenead.eixo  := gene0007.fn_caract_controle(rw_evenead.eixo);
          rw_evenead.tema  := gene0007.fn_caract_controle(rw_evenead.tema);
          rw_evenead.evento:= gene0007.fn_caract_controle(rw_evenead.evento);
       
          pc_escreve_xml ('<evento pa="' || rw_evenead.pa || '"' ||
                                 ' eixo="' || rw_evenead.eixo || '"' ||
                                 ' tema="' || rw_evenead.tema || '"' ||
                                 ' evento="' || replace(rw_evenead.evento,'"','''') || '"' ||
                                 ' carga_horaria="' || rw_evenead.carga_horaria || '"' ||
                                 ' n_de_part="' || rw_evenead.n_de_part || '"' ||
                                 ' qt_eventos="' || rw_evenead.qt_eventos || '"' ||
                                 ' valor_por_insc="'|| rw_evenead.valor_por_insc || '"' ||
                                 ' valor_desenv="' || rw_evenead.valor_desenv || '"' ||
                                 ' total="' || rw_evenead.total || '" >');
         
        pc_escreve_xml ('</evento>');

      END LOOP;        
    
      pc_escreve_xml('</ead>');              
    
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
        pr_dscritic := 'Erro geral no relatório de custos orçados - analítico: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');      
    
    END;
        
  END pc_relatorio_custos_orcados_a;
  
  
  
  -- Gera relatório SINTETICO para a tela WPGD0112.
  PROCEDURE pc_relatorio_custos_orcados_s(pr_dtanoage IN crapagp.dtanoage%TYPE --> ano da agencia
                                         ,pr_cdcooper IN crapcop.cdcooper%TYPE --> codigo da cooperativa
                                         ,pr_cdagenci IN VARCHAR2              --> uma ou varias agencias
                                         ,pr_nrseqpgm IN crappgm.nrseqpgm%TYPE --> Código do Programa
                                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
                                      
  BEGIN
    
    /* .............................................................................

    Programa: pc_relatorio_custos_orcados_s
    Sistema : Progrid
    Sigla   : WPGD
    Autor   : Carlos Rafael Tanholi
    Data    : Marco/16.                    Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina que gera relatorio SINTETICO de custos orçados de eventos do Progrid.

    Observacao: -----

    Alteracoes:
    ..............................................................................*/    
  
  
  	DECLARE
    
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;        
      
      -- Variáveis para armazenar as informações em XML
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600);   
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela craptel.nmdatela%TYPE;
      vr_nmdeacao crapaca.nmdeacao%TYPE;     
      vr_idcokses VARCHAR2(100);
      vr_idsistem craptel.idsistem%TYPE;
      vr_cddopcao VARCHAR2(100);      
      
      --------------------------> CURSORES <-----------------------------
      
      -- Cursor de eventos presenciais
      CURSOR cr_evenpre(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtanoage IN crapagp.dtanoage%TYPE
                       ,pr_cdagenci IN VARCHAR2) IS    
                        
          select Eixo,Tema,Evento,sum(Qt_De_Eventos) Qt_Eventos,Participacao_Por_Evento,Investimento_Por_Evento,
                 sum(Qt_De_Eventos) * Participacao_Por_Evento Participacao_total_prevista,
                 sum(Qt_De_Eventos) * Investimento_Por_Evento Investimento_Total,
                 (sum(Qt_De_Eventos) * Investimento_Por_Evento) / (sum(Qt_De_Eventos) * Participacao_Por_Evento) Valor_Por_Pessoa
          from (
          select cd.cdagenci,ge.dseixtem Eixo,ct.dstemeix Tema,cp.nmevento Evento,
                 decode(ce.qtocoeve,0,1,ce.qtocoeve) Qt_De_Eventos,                 
                 decode(decode(NVL(ce.qtmaxtur,0),0,nvl(cp.qtmaxtur,0),NVL(ce.qtmaxtur,0))
                             ,0,nvl(cp2.qtmaxtur,0),
                        decode(NVL(ce.qtmaxtur,0),0,nvl(cp.qtmaxtur,0),NVL(ce.qtmaxtur,0))
                       ) AS Participacao_Por_Evento,
                 sum(
                 cd.vlcuseve
                 ) Investimento_Por_Evento
          from crapeap ce, 
               crapcdp cd,
               crapedp cp,
               craptem ct,
               crapedp cp2,
               gnapetp ge    
          where 
              cd.idevento = ce.idevento
          and cd.cdcooper = ce.cdcooper
          and cd.dtanoage = ce.dtanoage
          and cd.cdagenci = ce.cdagenci
          and ce.flgevsel = 1 -- Eventos Selecionados
          and cd.cdevento = ce.cdevento
          and cd.tpcuseve = 1
          and cp.idevento = ce.idevento
          and cp.cdcooper = ce.cdcooper
          and cp.dtanoage = ce.dtanoage
          and cp.cdevento = ce.cdevento
          and (cp.nrseqpgm = pr_nrseqpgm OR pr_nrseqpgm = 0)
          --Evento Raiz
          and cp2.idevento = ce.idevento
          and cp2.cdcooper = 0
          and cp2.dtanoage = 0
          and cp2.cdevento = ce.cdevento
          and ct.nrseqtem(+) = cp2.nrseqtem
          and ge.idevento(+) = ct.idevento
          and ge.cdcooper(+) = ct.cdcooper
          and ge.cdeixtem(+) = ct.cdeixtem
          and ce.cdcooper(+) = pr_cdcooper 
          and ce.dtanoage = pr_dtanoage
          AND (INSTR(','||pr_cdagenci||',', ','||TO_CHAR(ce.cdagenci)||',') > 0 OR pr_cdagenci = '0')                    
          group by cd.cdagenci,ge.dseixtem,ct.dstemeix,cp.nmevento,ce.qtocoeve,
                decode(decode(NVL(ce.qtmaxtur,0),0,nvl(cp.qtmaxtur,0),NVL(ce.qtmaxtur,0))
                             ,0,nvl(cp2.qtmaxtur,0),
                      decode(NVL(ce.qtmaxtur,0),0,nvl(cp.qtmaxtur,0),NVL(ce.qtmaxtur,0))
                       )
          )
          GROUP BY Eixo,Tema,Evento,Participacao_Por_Evento,Investimento_Por_Evento
          ORDER BY Eixo,Tema,Evento;
         
    
      -- Cursor de evento EAD
      CURSOR cr_evenead(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtanoage IN crapagp.dtanoage%TYPE
                       ,pr_cdagenci IN VARCHAR2) IS
                       
        select ge.dseixtem Eixo,
          ct.dstemeix Tema,
          upper(cp.nmevento) Evento,
          cp.dscarhor Carga_Horaria,
          sum((cd.qtpareve * cd.qtocoeve))  n_de_part,
          sum(cd.qtocoeve) Qt_eventos,
          sum((cd.vlporins * cd.qtpareve * cd.qtocoeve)) VL_INSCRICOES,
          sum(cd.vldeseve) Valor_Desenvolvimento,
          sum((cd.vlporins * cd.qtpareve * cd.qtocoeve) + cd.vldeseve) Total
        from 
          crapage ca,
          CRAPCED cd,
          crapedp cp,
          craptem ct,
          gnapetp ge 
        where ca.cdcooper = cd.cdcooper
          and ca.cdagenci = cd.cdagenci
          -- Evento Raiz
          and cp.idevento = cd.idevento
          and cp.cdcooper = 0
          and cp.dtanoage = 0
          and cp.cdevento = cd.cdevento
          and ct.nrseqtem(+) = cp.nrseqtem
          and ge.idevento(+) = ct.idevento
          and ge.cdcooper(+) = ct.cdcooper
          and ge.cdeixtem(+) = ct.cdeixtem
          and cd.cdcooper = pr_cdcooper
          and cd.dtanoage = pr_dtanoage
          and (INSTR(','||pr_cdagenci||',', ','||TO_CHAR(cd.cdagenci)||',') > 0 OR pr_cdagenci = '0')                         
          and (cp.nrseqpgm = pr_nrseqpgm OR pr_nrseqpgm = 0)
        group by ge.dseixtem, ct.dstemeix,cp.nmevento,cp.dscarhor 
        order by 1,2,3,4;      
       
    
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

      pc_escreve_xml('<presencial>');      
      
      -- percorre os eventos presenciais
      FOR rw_evenpre IN cr_evenpre(pr_cdcooper, pr_dtanoage, pr_cdagenci) LOOP
          rw_evenpre.eixo  := gene0007.fn_caract_controle(rw_evenpre.eixo);
          rw_evenpre.tema  := gene0007.fn_caract_controle(rw_evenpre.tema);
          rw_evenpre.evento:= gene0007.fn_caract_controle(rw_evenpre.evento);

          pc_escreve_xml ('<evento eixo="' || rw_evenpre.eixo || '"' ||
                                 ' tema="' || rw_evenpre.tema || '"' ||
                                 ' evento="' || replace(rw_evenpre.evento,'"','''' ) || '"' ||
                                 ' qt_eventos="' || rw_evenpre.qt_eventos || '"' ||
                                 ' participacao="' || rw_evenpre.Participacao_Por_Evento || '"' ||
                                 ' investimento="' || rw_evenpre.Investimento_Por_Evento || '"' ||
                                 ' participacao_total_prevista="' || rw_evenpre.Participacao_total_prevista || '"' ||
                                 ' investimento_total="' || rw_evenpre.Investimento_Total || '"' ||                                 
                                 ' valor_pessoa="' || rw_evenpre.Valor_Por_Pessoa || '" >');
         
        pc_escreve_xml ('</evento>');

      END LOOP;    
    
      pc_escreve_xml('</presencial>');          
    
    
      pc_escreve_xml('<ead>');      
          
      -- percorre os eventos EAD
      FOR rw_evenead IN cr_evenead(pr_cdcooper, pr_dtanoage, pr_cdagenci) LOOP
          rw_evenead.eixo  := gene0007.fn_caract_controle(rw_evenead.eixo);
          rw_evenead.tema  := gene0007.fn_caract_controle(rw_evenead.tema);
          rw_evenead.evento:= gene0007.fn_caract_controle(rw_evenead.evento);
        
          pc_escreve_xml ('<evento eixo="' || rw_evenead.eixo || '"' ||
                                 ' tema="' || rw_evenead.tema || '"' ||
                                 ' evento="' || replace(rw_evenead.evento,'"','''' ) || '"' ||
                                 ' carga_horaria="' || rw_evenead.carga_horaria || '"' ||
                                 ' n_de_part="' || rw_evenead.n_de_part || '"' ||
                                 ' qt_eventos="' || rw_evenead.qt_eventos || '"' ||
                                 ' vl_inscricoes="'|| rw_evenead.VL_INSCRICOES || '"' ||
                                 ' valor_desenv="' || rw_evenead.Valor_Desenvolvimento || '"' ||
                                 ' total="' || rw_evenead.total || '" >');
         
        pc_escreve_xml ('</evento>');

      END LOOP;        

      pc_escreve_xml('</ead>');      
    
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
        pr_dscritic := 'Erro geral no relatório de custos orçados - sintético: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');      
    
    END;
        
  END pc_relatorio_custos_orcados_s;  
  
  
END WPGD0112;
/
