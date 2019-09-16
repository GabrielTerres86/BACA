CREATE OR REPLACE PACKAGE CECRED.TELA_MOVCMP IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_MOVCMP
  --  Sistema  : Rotinas focando nas funcionalidades da tela MOVCMP
  --  Sigla    : TELA
  --  Autor    : Jackson Barcellos AMcom
  --  Data     : 06/2019                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  : Agrupar rotinas que venham a ser utilizadas pela tela MOVCMP.
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------  

  /* Tipo Nossa Remessa*/
  TYPE typ_reg_nossa_remessa IS RECORD(
    cdcooper NUMBER,
    cdagenci NUMBER,
    tparquiv NUMBER,
    dtarquiv DATE,
    nmarquiv VARCHAR2(400),
    qtenviad NUMBER,
    vlenviad NUMBER,
    qtproces NUMBER,
    vlproces NUMBER,
    insituac NUMBER,
    dtevinst DATE,
    dtrtinst DATE);
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_nossa_remessa IS TABLE OF typ_reg_nossa_remessa INDEX BY BINARY_INTEGER;

  /* Tipo Sua Remessa*/
  TYPE typ_reg_sua_remessa IS RECORD(
    cdcooper NUMBER,
    tparquiv NUMBER,
    dtarquiv DATE,
    qtrecebd NUMBER,
    vlrecebd NUMBER,
    qtintegr NUMBER,
    vlintegr NUMBER,
    qtrejeit NUMBER,
    vlrejeit NUMBER);
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_sua_remessa IS TABLE OF typ_reg_sua_remessa INDEX BY BINARY_INTEGER;

  -- Procedure busca dados da minha remessa
  PROCEDURE PC_BUSCA_MREMESSA(pr_vcooper   IN NUMBER,
                              pr_tpremessa IN VARCHAR2,
                              pr_cdagenci  IN NUMBER,
                              pr_tparquivo IN NUMBER,
                              pr_dtinicial IN VARCHAR2,
                              pr_dtfinal   IN VARCHAR2,
                              pr_nriniseq  IN INTEGER DEFAULT 0,
                              pr_nrregist  IN INTEGER DEFAULT 0
                              -- campos padrões
                             ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);
END TELA_MOVCMP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_MOVCMP IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_MOVCMP
  --  Sistema  : Rotinas focando nas funcionalidades da tela MOVCMP
  --  Sigla    : TELA
  --  Autor    : Jackson Barcellos AMcom
  --  Data     : 06/2019                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  : Agrupar rotinas que venham a ser utilizadas pela tela MOVCMP.
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------  

  -- Procedure busca dados da minha remessa
  PROCEDURE PC_BUSCA_MREMESSA(pr_vcooper   IN NUMBER,
                              pr_tpremessa IN VARCHAR2,
                              pr_cdagenci  IN NUMBER,
                              pr_tparquivo IN NUMBER,
                              pr_dtinicial IN VARCHAR2,
                              pr_dtfinal   IN VARCHAR2,
                              pr_nriniseq  IN INTEGER DEFAULT 0,
                              pr_nrregist  IN INTEGER DEFAULT 0
                              -- campos padrões
                             ,
                              pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                             ,
                              pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                             ,
                              pr_dscritic OUT VARCHAR2 --> Descricao da critica
                             ,
                              pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,
                              pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,
                              pr_des_erro OUT VARCHAR2) is
    /*
      --  Projeto  : 565_1
      --  Programa : pc_busca_mremessa
      --  Sistema  : AIMARO.
      --  Sigla    : COMPENSACAO
      --  Autor    : Jackson Barcellos
      --  Data     : Maio/2019.                   Ultima atualizacao: 
      --
      --  Dados referentes ao programa:
      --
      --   Frequencia: Sempre que for chamado
      --   Objetivo  : Buscar dados de compensacao nossa remessa e sua remessa.
      --
      --   Alteracoes: 
    */
  BEGIN
    DECLARE
    
      -- cursor nossa remessa
      CURSOR cr_nr IS
        select cdcooper,
               nmrescop,
               cdagenci,
               tparquiv,
               DECODE(tparquiv,1,'DEV. DIURNA',2,'DEV. FR. E IMP.',3,'COMPEL',4,'TITULOS','NA') dsarquiv,
               dtarquiv,
               nmarquiv,
               qtenviad,
               vlenviad,
               qtproces,
               vlproces,
               insituac,
               dtevinst,
               dtrtinst,
               qtregist
          from (select r.cdcooper,
                       cop.nmrescop,
                       r.cdagenci,
                       r.tparquiv,
                       r.dtarquiv,
                       r.nmarquiv,
                       r.qtenviad,
                       r.vlenviad,
                       r.qtproces,
                       r.vlproces,
                       r.insituac,
                       r.dtevinst,
                       r.dtrtinst,                      
                       COUNT(1) OVER (PARTITION BY 1) qtregist,
                       COUNT(1) OVER (PARTITION BY 1 ORDER BY cop.nmrescop, r.tparquiv, r.dtarquiv, r.nmarquiv ) linha
                  from tbcompe_nossaremessa r
                 inner join crapcop cop
                    on cop.cdcooper = r.cdcooper
                 WHERE  (r.cdcooper = pr_vcooper OR pr_vcooper = 0) 
                       AND (r.tparquiv = pr_tparquivo OR pr_tparquivo = 0) 
                       AND (trunc(r.dtarquiv) between to_date(pr_dtinicial,'DD/MM/YYYY') and nvl(to_date(pr_dtfinal,'DD/MM/YYYY'),to_date(trunc(sysdate),'DD/MM/YYYY')))
                       AND (r.cdagenci = pr_cdagenci OR pr_cdagenci = 0)
                 ORDER BY cop.nmrescop, r.tparquiv, r.dtarquiv, r.nmarquiv)
         WHERE linha BETWEEN pr_nriniseq AND pr_nriniseq + pr_nrregist;
    
      -- cursor sua remessa    
      CURSOR cr_sr IS        
        select cdcooper,
               nmrescop,
               tparquiv,
               DECODE(tparquiv,1,'DEVOLU',2,'DOCTOS',3,'COMPEL',4,'TITULOS','NA') dsarquiv,
               dtarquiv,
               nmarqrec,
               qtrecebd,
               vlrecebd,
               qtintegr,
               vlintegr,
               qtrejeit,
               vlrejeit,
               qtregist
          from (select r.cdcooper,
                       cop.nmrescop,
                       r.tparquiv,
                       r.dtarquiv,
                       nmarqrec,
                       r.qtrecebd,
                       r.vlrecebd,
                       r.qtintegr,
                       r.vlintegr,
                       r.qtrejeit,
                       r.vlrejeit,
                       COUNT(1) OVER (PARTITION BY 1) qtregist,
                       COUNT(1) OVER (PARTITION BY 1 ORDER BY cop.nmrescop, r.tparquiv, r.dtarquiv ) linha
                  from tbcompe_suaremessa r
                 inner join crapcop cop
                    on cop.cdcooper = r.cdcooper
                 WHERE (r.cdcooper = pr_vcooper OR pr_vcooper = 0) 
                       AND (r.tparquiv = pr_tparquivo OR pr_tparquivo = 0) 
                       AND (trunc(r.dtarquiv) between to_date(pr_dtinicial,'DD/MM/YYYY') and nvl(to_date(pr_dtfinal,'DD/MM/YYYY'),to_date(trunc(sysdate),'DD/MM/YYYY')))
                 ORDER BY cop.nmrescop, r.tparquiv, r.dtarquiv)
         WHERE linha BETWEEN pr_nriniseq AND pr_nriniseq + pr_nrregist;
    
      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;
    
      /* Descrição e código da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
    
      -- variaveis de retorno
      rw_cr_nr             cr_nr%ROWTYPE;
      rw_cr_sr             cr_sr%ROWTYPE;
      vr_tab_nossa_remessa typ_tab_nossa_remessa;
      vr_tab_sua_remessa   typ_tab_sua_remessa;
      vr_qtregist          number;
    
      -- variaveis de entrada vindas no xml
      vr_cdcooper integer;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);
    
      -- variáveis para armazenar as informaçoes em xml
      vr_des_xml        clob;
      vr_texto_completo varchar2(32600);
      vr_index          varchar2(100);
    
      -- variaveis auxiliares
      aux NUMBER := 0;
    
      -- procedure para escrever o xml
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml,
                                vr_texto_completo,
                                pr_des_dados,
                                pr_fecha_xml);
      end;
    
    BEGIN
    
      pr_nmdcampo := NULL;
      pr_des_erro := 'OK';
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      IF (nvl(vr_cdcritic, 0) <> 0 OR vr_dscritic IS NOT NULL) THEN
        raise vr_exc_erro;
      END IF;
    
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;
    
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>' ||
                       '<root>');
    
      IF (pr_tpremessa = 'nr') THEN
      
        OPEN cr_nr;      
         
          LOOP FETCH cr_nr INTO rw_cr_nr;
            EXIT WHEN cr_nr%NOTFOUND;
            IF (vr_qtregist is null) THEN
              vr_qtregist := rw_cr_nr.qtregist;
              pc_escreve_xml('<dados qtregist="' || vr_qtregist || '" >',true);
            END IF;
            pc_escreve_xml('<inf>' || 
                              '<cdcooper>' || rw_cr_nr.cdcooper || '</cdcooper>' || 
                              '<nmrescop>' || rw_cr_nr.nmrescop || '</nmrescop>' ||
                              '<cdagenci>' || rw_cr_nr.cdagenci || '</cdagenci>' ||
                              '<tparquiv>' || rw_cr_nr.tparquiv || '</tparquiv>' || 
                              '<dsarquiv>' || rw_cr_nr.dsarquiv || '</dsarquiv>' ||                               
                              '<dtarquiv>' || rw_cr_nr.dtarquiv || '</dtarquiv>' ||
                              '<nmarquiv>' || rw_cr_nr.nmarquiv || '</nmarquiv>' || 
                              '<qtenviad>' || rw_cr_nr.qtenviad || '</qtenviad>' ||
                              '<vlenviad>' || rw_cr_nr.vlenviad || '</vlenviad>' || 
                              '<qtproces>' || rw_cr_nr.qtproces || '</qtproces>' ||
                              '<vlproces>' || rw_cr_nr.vlproces || '</vlproces>' || 
                              '<insituac>' || rw_cr_nr.insituac || '</insituac>' ||
                              --'<dssituac>' || rw_cr_nr.dssituac || '</dssituac>' ||
                              '<dtevinst>' || rw_cr_nr.dtevinst || '</dtevinst>' || 
                              '<dtrtinst>' || rw_cr_nr.dtrtinst || '</dtrtinst>' || 
                           '</inf>');
          END LOOP;   
          IF (vr_qtregist is null) THEN
             vr_qtregist := 0;
             pc_escreve_xml('<dados qtregist="' || vr_qtregist || '" >',true);
          END IF;   
          pc_escreve_xml('</dados>', true);
          CLOSE cr_nr;
      ELSIF (pr_tpremessa = 'sr') THEN
        OPEN cr_sr;
        LOOP FETCH cr_sr INTO rw_cr_sr;
          EXIT WHEN cr_sr%NOTFOUND;
          IF (vr_qtregist is null) THEN
              vr_qtregist := rw_cr_sr.qtregist;
              pc_escreve_xml('<dados qtregist="' || vr_qtregist || '" >',true);
          END IF;
          pc_escreve_xml('<inf>' || 
                            '<cdcooper>' || rw_cr_sr.cdcooper || '</cdcooper>' || 
                            '<nmrescop>' || rw_cr_sr.nmrescop || '</nmrescop>' ||                            
                            '<tparquiv>' || rw_cr_sr.tparquiv || '</tparquiv>' ||
                            '<dsarquiv>' || rw_cr_sr.dsarquiv || '</dsarquiv>' ||                            
                            '<dtarquiv>' || rw_cr_sr.dtarquiv || '</dtarquiv>' ||
                            '<nmarqrec>' || rw_cr_sr.nmarqrec || '</nmarqrec>' ||                             
                            '<qtrecebd>' || rw_cr_sr.qtrecebd || '</qtrecebd>' ||
                            '<vlrecebd>' || rw_cr_sr.vlrecebd || '</vlrecebd>' || 
                            '<qtintegr>' || rw_cr_sr.qtintegr || '</qtintegr>' ||
                            '<vlintegr>' || rw_cr_sr.vlintegr || '</vlintegr>' || 
                            '<qtrejeit>' || rw_cr_sr.qtrejeit || '</qtrejeit>' ||
                            '<vlrejeit>' || rw_cr_sr.vlrejeit || '</vlrejeit>' || 
                          '</inf>');
        END LOOP;
        IF (vr_qtregist is null) THEN
           vr_qtregist := 0;
           pc_escreve_xml('<dados qtregist="' || vr_qtregist || '" >',true);
        END IF; 
        pc_escreve_xml('</dados>', true);
        CLOSE cr_sr;
      
      ELSE
        pc_escreve_xml('<Erro>Tipo de remessa invalido!</Erro>', true);
      END IF;
    
      pc_escreve_xml('</root>', true);
      pr_retxml := xmltype.createxml(vr_des_xml);
    
      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        /*  se foi retornado apenas código */
        IF nvl(vr_cdcritic, 0) > 0 AND vr_dscritic IS NULL THEN
          /* buscar a descriçao */
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        /* variavel de erro recebe erro ocorrido */
        pr_des_erro := 'NOK';
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        /* montar descriçao de erro nao tratado */
        pr_dscritic := 'erro não tratado na tela_movcmp.pc_busca_mremessa ' ||
                       SQLERRM;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
    END;
  END PC_BUSCA_MREMESSA;
END TELA_MOVCMP;
/
