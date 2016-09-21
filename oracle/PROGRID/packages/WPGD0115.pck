CREATE OR REPLACE PACKAGE PROGRID.WPGD0115 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0115
  --  Sistema  : Rotinas para geração Relatório de Material de Divulgação
  --  Sigla    : WPGD
  --  Autor    : Vanessa Klein
  --  Data     : Junho/2016.                   Ultima atualizacao:  15/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para geração Relatório de Pendências de Eventos
  --
  -- Alteracoes: 
  --
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geração do relatorio da tela WPGD0115 - Relatório de Material de Divulgação 
  PROCEDURE pc_relat_wpgd0115( pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa informada
                              ,pr_dtanoage       IN crapadp.dtanoage%TYPE --> Ano da agenda informado
                              ,pr_cdagenci       IN crapadp.cdagenci%TYPE --> Codigo da Agencia Informada
                              ,pr_cdevento       IN crapadp.cdevento%TYPE --> Codigo do Evento informado
                              ,pr_dtinieve       VARCHAR2                 --> Data inicial informada
                              ,pr_dtfimeve       VARCHAR2                 --> Data final informada
                              ,pr_flgsemdt       IN VARCHAR2
                              ,pr_nriniseq       IN PLS_INTEGER           --> Sequencia inicial da busca
                              ,pr_qtregist       IN PLS_INTEGER           --> Qtd de registros da busca
                              ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic      OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic      OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml     IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                              ,pr_nmdcampo      OUT VARCHAR2              --> Nome do campo com erro
                              ,pr_des_erro      OUT VARCHAR2) ;          --> Erros do processo
            
 /* Procedure para listar os eventos do sistema */
  PROCEDURE pc_lista_eventos(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                           ,pr_cdagenci IN VARCHAR2              --> Codigo da Agencia (PA)    
                           ,pr_dtanoage IN crapedp.dtanoage%TYPE --> Ano da Agenda
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro    
                           
END WPGD0115;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0115 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0115
  --  Sistema  : Rotinas para geração Relatório de Material de Divulgação
  --  Sigla    : WPGD
  --  Autor    : Vanessa Klein
  --  Data     : Junho/2016.                   Ultima atualizacao:  15/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para geração Relatório de Pendências de Eventos
  --
  -- Alteracoes: 
  --
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geração do relatorio da tela WPGD0115 - Relatório de Material de Divulgação 
  PROCEDURE pc_relat_wpgd0115( pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa informada
                              ,pr_dtanoage       IN crapadp.dtanoage%TYPE --> Ano da agenda informado
                              ,pr_cdagenci       IN crapadp.cdagenci%TYPE --> Codigo da Agencia Informada
                              ,pr_cdevento       IN crapadp.cdevento%TYPE --> Codigo do Evento informado
                              ,pr_dtinieve       IN VARCHAR2              --> Data inicial informada
                              ,pr_dtfimeve       IN VARCHAR2              --> Data final informada
                              ,pr_flgsemdt       IN VARCHAR2
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
    --  Programa : pc_relat_WPGD0115
    --  Sistema  : Rotinas para tela cadastro de sugestão de produto
    --  Sigla    : WPGD
    --  Autor    : Vanessa Klein
    --  Data     : Junho/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Rotina geração do relatorio da tela WPGD0115 - Relatório de Pendências de Eventos 
    --
    --  Alteracoes: 
    -- .............................................................................*/

      -- Buscar eventos
      CURSOR cr_evento is
        SELECT  c.idevento,c.cdcooper,c.dtanoage,c.cdagenci,c.nrseqdig,c.cdevento,
                ca.nmresage nmresage, 
                ce.nmevento nmevento, 
                c.cdlocali  cdlocali, 
                c.dshroeve  dshroeve,
                c.dtinieve  dtinieve,
                c.dtfineve  dtfineve
        FROM crapadp c,
             crapage ca,
             crapedp ce
        WHERE
              -- Agencia
              ca.cdcooper = c.cdcooper
          AND ca.cdagenci = c.cdagenci
              -- Evento
          AND ce.idevento = c.idevento
          AND ce.cdcooper = c.cdcooper
          AND ce.dtanoage = c.dtanoage
          AND ce.cdevento = c.cdevento
          AND ce.flgativo = 1 -- Ativo  
          AND c.idevento  = 1
          AND c.idstaeve in(1,3,6) --  1 - AGENDADO,3 - TRANSFERIDO,6 - ,ACRESCIDO
          AND ce.tpevento NOT IN (10,11)  -- Ignorar eventos EAD
          AND c.dtanoage = pr_dtanoage -- Parâmetros do Relatório
          AND c.cdcooper = pr_cdcooper -- Parâmetros do Relatório
          AND (c.cdagenci = pr_cdagenci OR pr_cdagenci = 0) -- Parâmetros do Relatório -- Ter opção de Todos
          AND (c.cdevento = pr_cdevento OR pr_cdevento = 0) -- Parâmetros do Relatório -- Ter opção de Todos
          AND c.dtinieve >= to_date(pr_dtinieve,'DD/MM/YYYY') -- Parâmetros do Relatório
          AND c.dtfineve <= to_date(pr_dtfimeve,'DD/MM/YYYY') -- Parâmetros do Relatório
        UNION ALL           
         SELECT c.idevento,c.cdcooper,c.dtanoage,c.cdagenci,c.nrseqdig,c.cdevento,
                ca.nmresage nmresage, 
                ce.nmevento nmevento, 
                c.cdlocali  cdlocali, 
                c.dshroeve  dshroeve,
                c.dtinieve  dtinieve,
                c.dtfineve  dtfineve
          FROM crapadp c,
               crapage ca,
               crapedp ce
        WHERE ca.cdcooper = c.cdcooper
          AND ca.cdagenci = c.cdagenci
          AND ce.idevento = c.idevento
          AND ce.cdcooper = c.cdcooper
          AND ce.dtanoage = c.dtanoage
          AND ce.cdevento = c.cdevento
          AND ce.flgativo = 1 -- Ativo
          AND c.idevento = 1
          AND c.idstaeve in(1,3,6) --  1 -> AGENDADO,3 -> TRANSFERIDO,6 -> ACRESCIDO
          AND ce.tpevento NOT IN (10,11)  -- Ignorar eventos EAD
          AND c.dtanoage = pr_dtanoage -- Parâmetros do Relatório
          AND c.cdcooper = pr_cdcooper -- Parâmetros do Relatório
          AND (c.cdagenci = pr_cdagenci OR pr_cdagenci = 0) -- Parâmetros do Relatório -- Ter opção de Todos
          AND (c.cdevento = pr_cdevento OR pr_cdevento = 0) -- Parâmetros do Relatório -- Ter opção de Todos
          AND ( c.dtinieve IS NULL OR c.dtfineve IS NULL)
          AND c.nrmeseve >= 01
          AND c.nrmeseve <= 12
          AND 'S' = pr_flgsemdt
          ORDER BY 7,8;
          rw_evento cr_evento%ROWTYPE;  
      --> Fornecedor e Proposta
      CURSOR cr_proposta_fornecedor( pr_idevento   IN crapcdp.idevento%TYPE, 
                                     pr_cdcooper   IN crapcdp.cdcooper%TYPE,
                                     pr_cdagenci   IN crapcdp.cdagenci%TYPE, 
                                     pr_cdevento   IN crapcdp.cdevento%TYPE, 
                                     pr_dtanoage   IN crapcdp.dtanoage%TYPE) IS
         SELECT
             decode(cc.nrcpfcgc,0,null,cc.nrcpfcgc)   nrcpfcgc, -- fornecedor
             decode(cc.nrpropos,'0',null,cc.nrpropos) nrpropos, -- proposta
             decode(cc.nrdocfmd,0,null,cc.nrdocfmd)   nrdocfmd  -- fornecedor divulgação
      
        FROM crapcdp cc
        WHERE cc.idevento = pr_idevento
          and cc.cdcooper = pr_cdcooper
          and cc.cdagenci = pr_cdagenci
          and cc.dtanoage = pr_dtanoage
          and cc.cdevento = pr_cdevento
          and cc.cdcuseve = 1;
       rw_proposta_fornecedor cr_proposta_fornecedor%ROWTYPE; 
               
      --> buscar Nome do fornecedor
      CURSOR cr_nmfornec(pr_nrcpfcgc   GNAPFDP.NRCPFCGC%TYPE) IS                               
        SELECT substr(F.NMFORNEC,1,20) NMFORNEC          
          FROM GNAPFDP F
         WHERE F.NRCPFCGC = pr_nrcpfcgc;
      rw_nmfornec cr_nmfornec%ROWTYPE;
      
      -- Recursos do Evento
      CURSOR cr_recursos(pr_idevento   IN crapcdp.idevento%TYPE, 
                         pr_cdevento   IN crapcdp.cdevento%TYPE) IS                          
        SELECT
             COUNT(0) AS qtreceve
        FROM
             craprep cr,
             gnaprdp g
        WHERE g.idevento = cr.idevento
          AND g.cdcooper = cr.cdcooper
          AND g.nrseqdig = cr.nrseqdig
          AND g.idsitrec = 1
          AND g.cdtiprec <> 2 -- Não Pegar Mat de Divulgação
          AND cr.idevento = pr_idevento 
          AND cr.cdcooper = 0 
          AND cr.cdevento = pr_cdevento;                 
       rw_recursos cr_recursos%ROWTYPE;                  
      
       -- Recursos do PA
      CURSOR cr_recursos_pa(pr_idevento   IN crapcdp.idevento%TYPE, 
                            pr_cdcooper   IN crapcdp.cdcooper%TYPE,
                            pr_cdagenci   IN crapcdp.cdagenci%TYPE, 
                            pr_cdevento   IN crapcdp.cdevento%TYPE) IS
          SELECT COUNT(*) qtdrecpa
            FROM craprpe cp,
                 gnaprdp g
           WHERE g.idevento = cp.idevento
             AND g.cdcooper = cp.cdcooper
             AND g.nrseqdig = cp.nrseqdig
             AND g.idsitrec = 1
             AND g.cdtiprec <> 2 -- Não Pegar Mat de Divulgação
             AND cp.idevento = pr_idevento 
             AND cp.cdcooper = 0 
             AND cp.cdcopage = pr_cdcooper 
             AND cp.cdagenci = pr_cdagenci 
             AND cp.cdevento = pr_cdevento;
       rw_recursos_pa cr_recursos_pa%ROWTYPE;
       
      -- Recursos do Fornecedor
      CURSOR cr_recursos_fornec(pr_idevento  IN craprdf.idevento%TYPE, 
                                pr_nrcpfcgc  IN craprdf.nrcpfcgc%TYPE, 
                                pr_dspropos  IN craprdf.dspropos%TYPE) IS
         SELECT COUNT(*) qtrecfor
           FROM craprdf cf,
                gnaprdp g
          WHERE g.idevento = cf.idevento
            and g.cdcooper = cf.cdcooper
            and g.nrseqdig = cf.nrseqdig
            and g.idsitrec = 1
            and g.cdtiprec <> 2 -- Não Pegar Mat de Divulgação
            and cf.idevento = pr_idevento 
            and cf.cdcooper = 0 
            and cf.nrcpfcgc = pr_nrcpfcgc 
            and cf.dspropos = pr_dspropos;
       rw_recursos_fornec cr_recursos_fornec%ROWTYPE; 
                          
       -- Avaliação
       CURSOR cr_avaliacao(pr_idevento   IN craprap.idevento%TYPE, 
                           pr_cdcooper   IN craprap.cdcooper%TYPE,
                           pr_cdagenci   IN craprap.cdagenci%TYPE,
                           pr_dtanoage   IN craprap.dtanoage%TYPE, 
                           pr_cdevento   IN craprap.cdevento%TYPE,                          
                           pr_nrseqdig   IN craprap.nrseqeve%TYPE) IS                   
          SELECT
             COUNT(*) qtavalia       
            FROM CRAPRAP cx
           WHERE cx.idevento = pr_idevento 
             AND cx.cdcooper = pr_cdcooper 
             AND cx.cdagenci = pr_cdagenci 
             AND cx.dtanoage = pr_dtanoage 
             AND cx.cdevento = pr_cdevento 
             AND cx.nrseqeve = pr_nrseqdig;                
         rw_avaliacao cr_avaliacao%ROWTYPE;                 
         -- Recursos do Evento - Divulgacao   WW_QT_REC_FORNEC               
          CURSOR cr_recursos_divulg(pr_idevento   IN crapcdp.idevento%TYPE, 
                                    pr_cdevento   IN crapcdp.cdevento%TYPE) IS
                                    
            SELECT COUNT(*) qtrecevediv           
             FROM craprep cr,
                  gnaprdp g
            WHERE g.idevento = cr.idevento
              AND g.cdcooper = cr.cdcooper
              AND g.nrseqdig = cr.nrseqdig
              AND g.idsitrec = 1
              AND g.cdtiprec = 2 -- Divulgação
              AND cr.idevento = pr_idevento 
              AND cr.cdcooper = 0 
              AND cr.cdevento = pr_cdevento;  
         rw_recursos_divulg cr_recursos_divulg%ROWTYPE;
         -- Recursos do PA - Divulgação
         CURSOR cr_recursos_pa_divulg(pr_idevento  IN craprap.idevento%TYPE, 
                                      pr_cdcooper   IN craprap.cdcooper%TYPE,
                                      pr_cdagenci   IN craprap.cdagenci%TYPE,
                                      pr_dtanoage   IN craprap.dtanoage%TYPE, 
                                      pr_cdevento   IN craprap.cdevento%TYPE) IS
                 
              SELECT COUNT(*) qtrecpadiv       
                FROM craprpe cp,
                     gnaprdp g
               WHERE g.idevento  = cp.idevento
                 and g.cdcooper  = cp.cdcooper
                 and g.nrseqdig  = cp.nrseqdig
                 and g.idsitrec  = 1
                 and g.cdtiprec  = 2 -- Divulgação
                 and cp.idevento = pr_idevento 
                 and cp.cdcooper = 0 
                 and cp.cdcopage = pr_cdcooper 
                 and cp.cdagenci = pr_cdagenci 
                 and cp.cdevento = pr_cdevento;           
         rw_recursos_pa_divulg cr_recursos_pa_divulg%ROWTYPE;              
      -- Recursos do Fornecedor- Divulgação
      CURSOR cr_recursos_fornec_divulg(pr_idevento  IN craprdf.idevento%TYPE, 
                                       pr_nrcpfcgc  IN craprdf.nrcpfcgc%TYPE, 
                                       pr_dspropos  IN craprdf.dspropos%TYPE) IS
      
          SELECT COUNT(*) qtrecfornecdiv
            FROM craprdf cf,
                 gnaprdp g
           WHERE g.idevento = cf.idevento
             and g.cdcooper = cf.cdcooper
             and g.nrseqdig = cf.nrseqdig
             and g.idsitrec = 1
             and g.cdtiprec = 2 -- Divulgação
             and cf.idevento = pr_idevento 
             and cf.cdcooper = 0 
             and cf.nrcpfcgc = pr_nrcpfcgc 
             and cf.dspropos = pr_dspropos;
      rw_recursos_fornec_divulg cr_recursos_fornec_divulg%ROWTYPE;
       ---------------------------- ESTRUTURAS DE REGISTRO ----------------------
       TYPE typ_tab_reg_relat IS RECORD
          (evtpend         VARCHAR(1),
           cdagenci        crapage.cdagenci%TYPE,
           nmresage        crapage.nmresage%TYPE,
           nmevento        VARCHAR2(100),
           nmlocali        VARCHAR2(100),
           dshroeve        VARCHAR2(100),
           dtinieve        crapadp.dtinieve%TYPE,
           dtfineve        crapadp.dtfineve%TYPE,
           nmfornec        gnapfdp.nmfornec%TYPE,
           nrdocfmd        gnapfdp.nmfornec%TYPE,
           proposta        crapcdp.nrpropos%TYPE,
           qtreceve        NUMBER(5),
           qtdrecpa        NUMBER(5),    
           qtrecfor        NUMBER(5),
           qtavalia        NUMBER(5),
           qtrecevediv     NUMBER(5),
           qtrecpadiv      NUMBER(5),
           qtrecfornecdiv  NUMBER(5));
      TYPE typ_tab_relat IS

       TABLE OF typ_tab_reg_relat
       INDEX BY BINARY_INTEGER;          
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
      vr_index    PLS_INTEGER := 0;  
      
     -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      
      -- Variáveis para armazenar as informações em XML
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600); 
      vr_tab_relat typ_tab_relat;
      ---------------------------> SUBROTINAS <--------------------------
      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                               pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
      BEGIN
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      END;
    
    --inicio  
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
      
         
      FOR rw_evento in cr_evento LOOP
        
        vr_index := vr_index +1;
        vr_tab_relat(vr_index).evtpend  :='N';
        vr_tab_relat(vr_index).cdagenci := rw_evento.cdagenci;
        vr_tab_relat(vr_index).nmresage := rw_evento.nmresage;
        vr_tab_relat(vr_index).nmevento := rw_evento.nmevento;
        vr_tab_relat(vr_index).nmlocali := rw_evento.cdlocali;
        vr_tab_relat(vr_index).dshroeve := rw_evento.dshroeve;
        vr_tab_relat(vr_index).dtinieve := rw_evento.dtinieve;
        vr_tab_relat(vr_index).dtfineve := rw_evento.dtfineve;      
        
               
        -- local Indefinido
        IF nvl(rw_evento.cdlocali,0) = 0 THEN
          vr_tab_relat(vr_index).evtpend :='S';
        END IF;
        -- Horário Indefinido
        IF rw_evento.dshroeve IS NULL THEN
           vr_tab_relat(vr_index).evtpend :='S';
        END IF;   
        -- Data de Início Indefinida
        IF rw_evento.dtinieve IS NULL THEN
           vr_tab_relat(vr_index).evtpend :='S';
        END IF; 
        -- Data de Fim Indefinida
        IF rw_evento.dtfineve IS NULL THEN
           vr_tab_relat(vr_index).evtpend :='S';
        END IF;
       
       -- Fornecedor e Proposta
       OPEN cr_proposta_fornecedor(pr_idevento => rw_evento.idevento
                                  ,pr_cdcooper => rw_evento.cdcooper
                                  ,pr_cdagenci => rw_evento.cdagenci
                                  ,pr_cdevento => rw_evento.cdevento
                                  ,pr_dtanoage => rw_evento.dtanoage);
       FETCH cr_proposta_fornecedor INTO rw_proposta_fornecedor;
       IF cr_proposta_fornecedor%NOTFOUND THEN      
          vr_tab_relat(vr_index).evtpend :='S';
       ELSE
           vr_tab_relat(vr_index).proposta := rw_proposta_fornecedor.nrpropos;
           vr_tab_relat(vr_index).nrdocfmd := to_char(rw_proposta_fornecedor.nrdocfmd);
           
           OPEN cr_nmfornec(pr_nrcpfcgc =>  rw_proposta_fornecedor.nrcpfcgc);
           FETCH cr_nmfornec INTO rw_nmfornec;
           IF cr_nmfornec%NOTFOUND THEN      
              vr_tab_relat(vr_index).nmfornec := to_char(rw_proposta_fornecedor.nrcpfcgc);
           ELSE
              vr_tab_relat(vr_index).nmfornec := rw_nmfornec.nmfornec;
           END IF; 
           CLOSE cr_nmfornec;      
       END IF;
       CLOSE cr_proposta_fornecedor;
      
      --Recursos do Evento
      OPEN cr_recursos(pr_idevento => rw_evento.idevento, 
                        pr_cdevento => rw_evento.cdevento);
      FETCH cr_recursos INTO rw_recursos;
                           
       IF cr_recursos%NOTFOUND THEN      
          vr_tab_relat(vr_index).qtreceve := 0;
          vr_tab_relat(vr_index).evtpend  :='S';
       ELSE 
          vr_tab_relat(vr_index).qtreceve := rw_recursos.qtreceve;
          IF rw_recursos.qtreceve = 0 THEN
             vr_tab_relat(vr_index).evtpend  :='S';
          END IF; 
       END IF;
       CLOSE cr_recursos;
      
       -- Recursos do PA 
       OPEN cr_recursos_pa(pr_idevento    => rw_evento.idevento,  
                           pr_cdcooper   => rw_evento.cdcooper,
                           pr_cdagenci   => rw_evento.cdagenci, 
                           pr_cdevento   => rw_evento.cdevento);
       FETCH cr_recursos_pa INTO rw_recursos_pa;
       
       IF cr_recursos_pa%NOTFOUND THEN      
          vr_tab_relat(vr_index).qtdrecpa := 0;
          vr_tab_relat(vr_index).evtpend  :='S';
       ELSE 
          vr_tab_relat(vr_index).qtdrecpa := rw_recursos_pa.qtdrecpa;
          IF rw_recursos_pa.qtdrecpa = 0 THEN
             vr_tab_relat(vr_index).evtpend  :='S';
          END IF; 
       END IF;
       CLOSE cr_recursos_pa; 
       
       -- Recursos do Fornecedor 
       OPEN cr_recursos_fornec(pr_idevento  => rw_evento.idevento, 
                               pr_nrcpfcgc  => rw_proposta_fornecedor.nrcpfcgc, 
                               pr_dspropos  => rw_proposta_fornecedor.nrpropos);
       FETCH cr_recursos_fornec INTO rw_recursos_fornec;
       
       IF cr_recursos_fornec%NOTFOUND THEN      
          vr_tab_relat(vr_index).qtrecfor := 0;
          vr_tab_relat(vr_index).evtpend  :='S';
       ELSE 
          vr_tab_relat(vr_index).qtrecfor := rw_recursos_fornec.qtrecfor;
          IF rw_recursos_fornec.qtrecfor = 0 THEN
             vr_tab_relat(vr_index).evtpend  :='S';
          END IF; 
       END IF;
       CLOSE cr_recursos_fornec;
        -- Avaliação
        OPEN cr_avaliacao(pr_idevento => rw_evento.idevento, 
                          pr_cdcooper => rw_evento.cdcooper,
                          pr_cdagenci => rw_evento.cdagenci,
                          pr_dtanoage => rw_evento.dtanoage, 
                          pr_cdevento => rw_evento.cdevento,                          
                          pr_nrseqdig => rw_evento.nrseqdig);
        FETCH cr_avaliacao INTO rw_avaliacao;
        IF cr_avaliacao%NOTFOUND THEN
            vr_tab_relat(vr_index).qtavalia := 0;
            vr_tab_relat(vr_index).evtpend  :='S';
        ELSE 
            vr_tab_relat(vr_index).qtavalia := rw_avaliacao.qtavalia;
            IF rw_avaliacao.qtavalia = 0 THEN
               vr_tab_relat(vr_index).evtpend  :='S';
            END IF; 
        END IF;                      
        CLOSE cr_avaliacao;
        -- Recursos do Evento - Divulgacao
        OPEN cr_recursos_divulg(pr_idevento => rw_evento.idevento, 
                                pr_cdevento => rw_evento.cdevento);
        FETCH cr_recursos_divulg INTO rw_recursos_divulg;
        
        IF cr_recursos_divulg%NOTFOUND THEN
            vr_tab_relat(vr_index).qtrecevediv := 0;
            vr_tab_relat(vr_index).evtpend  :='S';
        ELSE 
            vr_tab_relat(vr_index).qtrecevediv := rw_recursos_divulg.qtrecevediv;
            IF rw_recursos_divulg.qtrecevediv = 0 THEN
               vr_tab_relat(vr_index).evtpend  :='S';
            END IF; 
        END IF;
        CLOSE cr_recursos_divulg;
        -- Recursos do PA - Divulgação
        OPEN cr_recursos_pa_divulg(pr_idevento =>  rw_evento.idevento, 
                                   pr_cdcooper =>  rw_evento.cdcooper,
                                   pr_cdagenci =>  rw_evento.cdagenci,
                                   pr_dtanoage =>  rw_evento.dtanoage, 
                                   pr_cdevento =>  rw_evento.cdevento);
        FETCH cr_recursos_pa_divulg INTO rw_recursos_pa_divulg;
        
        IF cr_recursos_pa_divulg%NOTFOUND THEN
            vr_tab_relat(vr_index).qtrecevediv := 0;
            vr_tab_relat(vr_index).evtpend  :='S';
        ELSE 
            vr_tab_relat(vr_index).qtrecpadiv := rw_recursos_pa_divulg.qtrecpadiv;
            IF rw_recursos_pa_divulg.qtrecpadiv = 0 THEN
               vr_tab_relat(vr_index).evtpend  :='S';
            END IF; 
        END IF;
        CLOSE cr_recursos_pa_divulg;
        -- Recursos do Fornecedor- Divulgação
        OPEN cr_recursos_fornec_divulg(pr_idevento => rw_evento.idevento, 
                                       pr_nrcpfcgc => rw_proposta_fornecedor.nrcpfcgc, 
                                       pr_dspropos => rw_proposta_fornecedor.nrpropos);        
        FETCH cr_recursos_fornec_divulg INTO rw_recursos_fornec_divulg;
        
        IF cr_recursos_fornec_divulg%NOTFOUND THEN
            vr_tab_relat(vr_index).qtrecfornecdiv := 0;
            vr_tab_relat(vr_index).evtpend  :='S';
        ELSE 
            vr_tab_relat(vr_index).qtrecfornecdiv := rw_recursos_fornec_divulg.qtrecfornecdiv;
            IF rw_recursos_fornec_divulg.qtrecfornecdiv = 0 THEN
               vr_tab_relat(vr_index).evtpend  :='S';
            END IF; 
        END IF;
         CLOSE cr_recursos_fornec_divulg;                                          
      END LOOP;
      
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;

      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>'); 
      
      vr_index := vr_tab_relat.first;  
         

      WHILE vr_index IS NOT NULL LOOP
       IF vr_tab_relat(vr_index).evtpend = 'S' THEN
           pc_escreve_xml('<eventos>  '||  
                          ' <vr_index>'|| vr_index ||'</vr_index>   '||    
                          ' <cdagenci>'|| vr_tab_relat(vr_index).cdagenci ||'</cdagenci>   '||    
                          ' <nmresage>'|| vr_tab_relat(vr_index).nmresage ||'</nmresage>   '||       
                          ' <nmevento>'|| upper(vr_tab_relat(vr_index).nmevento) ||'</nmevento>   '||
                          ' <nmlocali>'|| vr_tab_relat(vr_index).nmlocali ||'</nmlocali>   '|| 
                          ' <dshroeve><![CDATA['|| NVL(vr_tab_relat(vr_index).dshroeve,'&nbsp;') ||']]></dshroeve>   '|| 
                          ' <dtinieve><![CDATA['|| NVL(to_char(vr_tab_relat(vr_index).dtinieve,'DD/MM/YYYY'),'&nbsp;') ||']]></dtinieve>   '|| 
                          ' <dtfineve><![CDATA['|| NVL(to_char(vr_tab_relat(vr_index).dtfineve,'DD/MM/YYYY'),'&nbsp;') ||']]></dtfineve>   '||  
                          ' <nmfornec><![CDATA['|| NVL(vr_tab_relat(vr_index).nmfornec,'&nbsp;') ||']]></nmfornec> '||         
                          ' <nmfordiv><![CDATA['|| NVL(vr_tab_relat(vr_index).nrdocfmd,'&nbsp;') ||']]></nmfordiv>   '||
                          ' <proposta><![CDATA['|| NVL(TRIM(vr_tab_relat(vr_index).proposta),'&nbsp;') ||']]></proposta>   '||
                          ' <qtreceve>'|| NVL(vr_tab_relat(vr_index).qtreceve,0) ||'</qtreceve>   '|| 
                          ' <qtdrecpa>'|| NVL(vr_tab_relat(vr_index).qtdrecpa,0) ||'</qtdrecpa>   '|| 
                          ' <qtrecfor>'|| NVL(vr_tab_relat(vr_index).qtrecfor,0) ||'</qtrecfor>   '||  
                          ' <qtavalia>'|| NVL(vr_tab_relat(vr_index).qtavalia,0) ||'</qtavalia>   '|| 
                          ' <qtrecevediv>'||  NVL(vr_tab_relat(vr_index).qtrecevediv,0) ||'</qtrecevediv>   '||  
                          ' <qtrecpadiv>'||  NVL(vr_tab_relat(vr_index).qtrecpadiv,0) ||'</qtrecpadiv>   '||  
                          ' <qtrecfornecdiv>'||  NVL(vr_tab_relat(vr_index).qtrecfornecdiv,0) ||'</qtrecfornecdiv>   '||        
                          ' </eventos>'); 
              
         END IF;
         -- buscar proximo
            vr_index := vr_tab_relat.next(vr_index);   
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
        pr_dscritic := 'Erro ao gerar relatório: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_relat_wpgd0115;

 
 /* Procedure para listar os eventos do sistema */
  PROCEDURE pc_lista_eventos(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                           ,pr_cdagenci IN VARCHAR2            	 --> Codigo da Agencia (PA)    
                           ,pr_dtanoage IN crapedp.dtanoage%TYPE --> Ano da Agenda
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_eventos
    --  Sistema  : Rotinas para listar os eventos do sistema por cooperativa, pa, dtanoage
    --  Sigla    : WPGD0115
    --  Autor    : Vanessa Klein
    --  Data     : Junho/2016.                   Ultima atualizacao: 21/06/2016
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de eventos liberados na agenda.
    --
    --  Alteracoes: 
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
         AND (eap.dtanoage = edp.dtanoage)
         AND (edp.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
         AND (eap.cdagenci = pr_cdagenci OR pr_cdagenci = 0)
         AND (eap.dtanoage = pr_dtanoage)
         AND edp.idevento = 1
         AND edp.tpevento <> 10
         AND edp.tpevento <> 11
         AND eap.flgevsel = 1
       ORDER BY edp.nmevento;
        
      rw_crapedp_age cr_crapedp_age%ROWTYPE;
       
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
      
      arr_agencias GENE0002.typ_split;      
      vr_cdcopage crapcop.cdcooper%TYPE;
    
    BEGIN
        
      FOR rw_crapedp_age IN cr_crapedp_age LOOP
                        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp_age.cdevento, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp_age.nmevento, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
                      
      END LOOP;
               
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em WPGD0115.PC_LISTA_EVENTO: ' || SQLERRM;
        pr_dscritic := 'Erro geral em WPGD0115.PC_LISTA_EVENTO: ' || SQLERRM;
    END;

  END pc_lista_eventos;
-----------------------------------------------------                       
END WPGD0115;
/
