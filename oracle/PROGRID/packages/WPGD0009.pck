CREATE OR REPLACE PACKAGE PROGRID.WPGD0009 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0009
  --  Sistema  : Rotinas para tela de Inscricoes
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Dezembro/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotinas para tela de Inscrições.
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Tabela de Status */
  TYPE typ_reg_status IS
    RECORD(cdstatus INTEGER
          ,dsstatus VARCHAR2(100));

  TYPE typ_tab_status IS
    TABLE OF typ_reg_status
    INDEX BY BINARY_INTEGER;
  /* Fim Tabela de Status */
  
  /* Tabela de Inscritos */
  TYPE typ_reg_inscritos IS
    RECORD(nminseve crapidp.nminseve%TYPE
          ,nmextttl crapttl.nmextttl%TYPE
          ,idseqttl crapidp.idseqttl%TYPE
          ,nrdconta crapidp.nrdconta%TYPE
          ,nrdddins crapidp.nrdddins%TYPE
          ,nrtelins crapidp.nrtelins%TYPE
          ,dsobsins crapidp.dsobsins%TYPE
          ,cdagenci crapidp.cdagenci%TYPE
          ,cdageins crapidp.cdageins%TYPE
          ,cdcooper crapidp.cdcooper%TYPE
          ,cdevento crapidp.cdevento%TYPE
          ,nrseqdig crapidp.nrseqdig%TYPE
          ,nrseqeve crapidp.nrseqeve%TYPE
          ,dtconins crapidp.dtconins%TYPE
          ,cdgraupr crapidp.cdgraupr%TYPE
          ,nmresage crapage.nmresage%TYPE
          ,idstains crapidp.idstains%TYPE
          ,dsstains VARCHAR2(100)
          ,nrdrowid VARCHAR2(100)
          ,progress crapidp.progress_recid%TYPE
          ,dtpreins crapidp.dtpreins%TYPE
          ,qtfaleve crapidp.qtfaleve%TYPE
          ,flginsin VARCHAR2(5)
          ,nrficpre crapidp.nrficpre%TYPE);

  TYPE typ_tab_inscritos IS
    TABLE OF typ_reg_inscritos
    INDEX BY BINARY_INTEGER;  
  /* Fim Tabela de Inscritos */

  -- Rotina geral de consulta de lista de inscritos
  PROCEDURE pc_lista_inscritos_car(pr_cdcooper  IN crapppc.cdcooper%TYPE   --> Codigo da Cooperativa
                                  ,pr_cdageins  IN crapidp.cdageins%TYPE   --> Codigo do PA
                                  ,pr_nminscri  IN crapidp.nminseve%TYPE   --> Nome do Inscrito
                                  ,pr_nrseqeve  IN crapidp.nrseqeve%TYPE   --> Sequencial de Evento
                                  ,pr_tpfiltro  IN INTEGER                 --> Tipo de Filtro
                                  ,pr_tpordena  IN INTEGER                 --> Tipo de Ordenacao
                                  ,pr_dtanoage  IN crapppc.dtanoage%TYPE   --> Ano Agenda
                                  ,pr_idevento  IN crapedp.idevento%TYPE   --> ID do Evento
                                  ,pr_nriniseq  IN INTEGER                 --> Registro inicial para pesquisa
                                  ,pr_nrficpre  IN crapidp.nrficpre%TYPE      --> Número de Ficha de Inscrição
                                  ,pr_qtdregis OUT INTEGER                 --> Quantidade de Registros Existentes
                                  ,pr_clobxmlc OUT CLOB                    --> XML com informações de LOG
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Código da crítica
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descrição da crítica

END WPGD0009;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0009 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0009
  --  Sistema  : Rotinas para tela de Inscricoes
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Janeiro/2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotinas para tela de inscricoes
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral de consulta de lista de inscritos
  PROCEDURE pc_lista_inscritos(pr_cdcooper       IN crapppc.cdcooper%TYPE      --> Codigo da Cooperativa
                              ,pr_cdageins       IN crapidp.cdageins%TYPE      --> Codigo do PA
                              ,pr_nminscri       IN crapidp.nminseve%TYPE      --> Nome do Inscrito
                              ,pr_nrseqeve       IN crapidp.nrseqeve%TYPE      --> Sequencial de Evento
                              ,pr_tpfiltro       IN INTEGER                    --> Tipo de Filtro
                              ,pr_tpordena       IN INTEGER                    --> Tipo de Ordenacao
                              ,pr_dtanoage       IN crapppc.dtanoage%TYPE      --> Ano Agenda
                              ,pr_idevento       IN crapedp.idevento%TYPE      --> ID do Evento
                              ,pr_nriniseq       IN INTEGER                    --> Registro inicial para pesquisa
                              ,pr_nrficpre       IN crapidp.nrficpre%TYPE      --> Número de Ficha de Inscrição
                              ,pr_qtdregis      OUT INTEGER                    --> Quantidade de Registros Existentes
                              ,pr_tab_status    OUT wpgd0009.typ_tab_status    --> Tabela de Status
                              ,pr_tab_inscritos OUT wpgd0009.typ_tab_inscritos --> Tabela de Inscritos
                              ,pr_cdcritic      OUT crapcri.cdcritic%TYPE      --> Código da crítica
                              ,pr_dscritic      OUT crapcri.dscritic%TYPE) IS  --> Descrição da crítica
    -- CURSORES 
    CURSOR cr_crapadp(pr_idevento crapadp.idevento%TYPE
                     ,pr_cdcooper crapadp.cdcooper%TYPE                    
                     ,pr_nrseqdig crapadp.nrseqdig%TYPE) IS

      SELECT adp.cdevento
        FROM crapadp adp
       WHERE adp.idevento = pr_idevento
         AND adp.cdcooper = pr_cdcooper
         AND adp.nrseqdig = pr_nrseqdig;

    rw_crapadp cr_crapadp%ROWTYPE;
     
    CURSOR cr_crapidp(pr_idevento crapidp.idevento%TYPE
                     ,pr_cdcooper crapidp.cdcooper%TYPE
                     ,pr_dtanoage crapidp.dtanoage%TYPE
                     ,pr_cdageins crapidp.cdageins%TYPE
                     ,pr_cdevento crapidp.cdevento%TYPE
                     ,pr_nrseqeve crapidp.nrseqeve%TYPE
                     ,pr_nminscri crapidp.nminseve%TYPE
                     ,pr_tpfiltro crapidp.idevento%TYPE
                     ,pr_tpordena crapidp.idevento%TYPE
                     ,pr_nrficpre crapidp.nrficpre%TYPE) IS
                     SELECT insc.*, 
ROW_NUMBER() OVER(ORDER BY DECODE(pr_tpordena,1,insc.nminseve,2,LPAD(insc.nrdconta,10,'0'),3,insc.dsstains,insc.nminseve)) nrdseque
FROM (
      SELECT idp.nminseve -- NAO RETIRAR ESSE CAMPO, IMPACTA NA ORDENACAO
            ,idp.nrdconta -- NAO RETIRAR ESSE CAMPO, IMPACTA NA ORDENACAO
            ,DECODE(idp.idstains,1,'Pendente',2,'Confirmado',3,'Desistente',4,'Excedente/Interessado',5,'Excluido','SEM STATUS') AS dsstains -- NAO RETIRAR ESSE CAMPO, IMPACTA NA ORDENACAO
            ,idp.idstains -- NAO RETIRAR ESSE CAMPO, IMPACTA NA ORDENACAO
            ,idp.dtconins
            ,idp.cdcooper            
            ,idp.idseqttl
            ,idp.flginsin
            ,idp.cdgraupr
            ,idp.nrdddins
            ,idp.nrtelins
            ,idp.dsobsins
            ,idp.cdagenci
            ,idp.cdageins
            ,idp.cdevento
            ,idp.nrseqdig
            ,idp.nrseqeve
            ,idp.dtpreins
            ,idp.qtfaleve
            ,idp.nrficpre
            ,idp.progress_recid
            ,ROWID AS cdrowid
        FROM crapidp idp
       WHERE idp.idevento = pr_idevento
         AND idp.cdcooper = pr_cdcooper
         AND idp.dtanoage = pr_dtanoage
         AND idp.cdevento = pr_cdevento
         AND idp.nrseqeve = pr_nrseqeve
         AND idp.cdageins = pr_cdageins
         AND ((
             ((pr_tpfiltro = 1
         AND UPPER(idp.nminseve) LIKE '%' || UPPER(pr_nminscri) || '%')
          OR (pr_tpfiltro = 2 AND (TO_CHAR(idp.nrdconta) = pr_nminscri OR pr_nminscri IS NULL)
          AND (idp.nrficpre = pr_nrficpre OR pr_nrficpre = 0))
             )
         AND pr_cdageins <> 0) 
          OR (
             UPPER(idp.nminseve) LIKE '%' || UPPER(pr_nminscri) || '%'
         AND (idp.nrficpre = pr_nrficpre OR pr_nrficpre = 0)
         AND pr_idevento = 2
         AND pr_cdageins = 0
         AND pr_nrseqeve <> 0 )
         )
    ORDER BY DECODE(pr_tpordena,1,idp.nminseve,2,LPAD(idp.nrdconta,10,'0'),3,dsstains,idp.nminseve)
            ,DECODE(pr_tpordena,3,idp.nminseve,0)) insc;

    rw_crapidp cr_crapidp%ROWTYPE;
    
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.cdcooper
            ,ass.cdagenci
            ,ass.nrdconta
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE
                     ,pr_nrdconta crapttl.nrdconta%TYPE
                     ,pr_idseqttl crapttl.idseqttl%TYPE) IS
      SELECT ttl.cdcooper
            ,ttl.nrdconta
            ,ttl.nmextttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl;
        
    rw_crapttl cr_crapttl%ROWTYPE;                 

    CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE
                     ,pr_cdagenci crapage.cdagenci%TYPE) IS
      SELECT age.nmresage
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;

    rw_crapage cr_crapage%ROWTYPE;

    -- Variável de críticas
    vr_dscritic VARCHAR2(32000) := '';
   
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis Locais
    vr_cdgraupr INTEGER := 0;
    vr_ind_care INTEGER := 0;
    vr_dtconins DATE := NULL;
    vr_flgcridp BOOLEAN := FALSE;
    vr_internet VARCHAR2(5) := '';
    vr_paramemt gene0002.typ_split;
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_nmextttl crapttl.nmextttl%TYPE := '';
    vr_dstextab craptab.dstextab%TYPE := '';
    vr_nmresage crapttl.nmextttl%TYPE := '';

    vr_qtregist INTEGER := 100; -- Quantidade de registros a serem listados
    vr_qtdregis INTEGER := 0; -- Quantidade de registros existentes

    -- Variaveis de Temp-Tables
    vr_tab_status WPGD0009.typ_tab_status;
    vr_tab_inscritos WPGD0009.typ_tab_inscritos;

  BEGIN

    vr_ind_care := 0;

    -- CONSULTAR O CODIGO DO EVENTO
    OPEN cr_crapadp(pr_idevento => pr_idevento
                   ,pr_cdcooper => pr_cdcooper
                   ,pr_nrseqdig => pr_nrseqeve);

    FETCH cr_crapadp INTO rw_crapadp;

    IF cr_crapadp%NOTFOUND THEN
      CLOSE cr_crapadp;
    ELSE
      CLOSE cr_crapadp;
    END IF;
 
    -- VINCULO 
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'VINCULOTTL'
                                             ,pr_tpregist => 0);
                                            
       
    FOR rw_crapidp IN cr_crapidp(pr_idevento => pr_idevento
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_dtanoage => pr_dtanoage
                                ,pr_cdageins => pr_cdageins
                                ,pr_cdevento => rw_crapadp.cdevento
                                ,pr_nrseqeve => pr_nrseqeve
                                ,pr_nminscri => pr_nminscri
                                ,pr_tpfiltro => pr_tpfiltro
                                ,pr_tpordena => pr_tpordena
                                ,pr_nrficpre => pr_nrficpre) LOOP

      IF NOT vr_flgcridp THEN
        vr_flgcridp := TRUE;
        IF NVL(vr_dstextab,'') IS NOT NULL AND NVL(vr_dstextab,'') <> '' THEN
          vr_cdgraupr := GENE0002.fn_busca_entrada(INSTR(vr_dstextab,NVL(rw_crapidp.cdgraupr,4)) - 1,vr_dstextab,',');
        END IF;
      END IF;
        
      vr_dtconins := NVL(rw_crapidp.dtconins,'');
      vr_nmextttl := 'Não encontrado';
      vr_nmresage := '';

      OPEN cr_crapttl(pr_cdcooper => rw_crapidp.cdcooper
                     ,pr_nrdconta => rw_crapidp.nrdconta
                     ,pr_idseqttl => rw_crapidp.idseqttl);

      FETCH cr_crapttl INTO rw_crapttl;               

      IF cr_crapttl%FOUND THEN

        vr_nmextttl := rw_crapttl.nmextttl;

        OPEN cr_crapass(pr_cdcooper => rw_crapttl.cdcooper
                       ,pr_nrdconta => rw_crapttl.nrdconta);

        FETCH cr_crapass INTO rw_crapass;

        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
        ELSE
          CLOSE cr_crapass;

          OPEN cr_crapage(pr_cdcooper => rw_crapass.cdcooper
                         ,pr_cdagenci => rw_crapass.cdagenci);

          FETCH cr_crapage INTO rw_crapage;

          IF cr_crapage%NOTFOUND THEN
            CLOSE cr_crapage;
          ELSE
            CLOSE cr_crapage;
            vr_nmresage := rw_crapage.nmresage;
          END IF;           

        END IF;            

      ELSE 

        OPEN cr_crapass(pr_cdcooper => rw_crapidp.cdcooper
                       ,pr_nrdconta => rw_crapidp.nrdconta);

        FETCH cr_crapass INTO rw_crapass;

        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
        ELSE
          CLOSE cr_crapass;

          OPEN cr_crapage(pr_cdcooper => rw_crapass.cdcooper
                         ,pr_cdagenci => rw_crapass.cdagenci);

          FETCH cr_crapage INTO rw_crapage;

          IF cr_crapage%NOTFOUND THEN
            CLOSE cr_crapage;
          ELSE
            CLOSE cr_crapage;
            vr_nmresage := rw_crapage.nmresage;
          END IF;

        END IF;
         
      END IF; -- CRAPTTL
       
      CLOSE cr_crapttl;

      vr_cdgraupr := 0;
        
      IF NVL(vr_dstextab,'') IS NOT NULL AND NVL(vr_dstextab,'') <> '' THEN
        vr_cdgraupr := GENE0002.fn_busca_entrada(INSTR(vr_dstextab,rw_crapidp.cdgraupr) - 1,vr_dstextab,',');
      END IF;                                       

      -- Verifica se a inscriçao foi feita pela internet
      IF rw_crapidp.flginsin = 1   THEN
        vr_internet := 'Sim';
      ELSE
        vr_internet := 'Não';
      END IF;

      -- Buscar qual a quantidade atual de registros no vetor para posicionar na próxima
      vr_ind_care := vr_tab_inscritos.COUNT() + 1;

      IF ((pr_nriniseq <= rw_crapidp.nrdseque)AND (rw_crapidp.nrdseque <= (pr_nriniseq + (vr_qtregist - 1)))) THEN

        -- Criar um registro na temp-table de inscritos
        vr_tab_inscritos(vr_ind_care).nminseve := rw_crapidp.nminseve;
        vr_tab_inscritos(vr_ind_care).nmextttl := vr_nmextttl;
        vr_tab_inscritos(vr_ind_care).idseqttl := rw_crapidp.idseqttl;
        vr_tab_inscritos(vr_ind_care).nrdconta := rw_crapidp.nrdconta;
        vr_tab_inscritos(vr_ind_care).nrdddins := rw_crapidp.nrdddins;
        vr_tab_inscritos(vr_ind_care).nrtelins := rw_crapidp.nrtelins;
        vr_tab_inscritos(vr_ind_care).dsobsins := rw_crapidp.dsobsins;
        vr_tab_inscritos(vr_ind_care).cdagenci := rw_crapidp.cdagenci;
        vr_tab_inscritos(vr_ind_care).cdageins := rw_crapidp.cdageins;
        vr_tab_inscritos(vr_ind_care).cdcooper := rw_crapidp.cdcooper;
        vr_tab_inscritos(vr_ind_care).cdevento := rw_crapidp.cdevento;
        vr_tab_inscritos(vr_ind_care).nrseqdig := rw_crapidp.nrseqdig;
        vr_tab_inscritos(vr_ind_care).nrseqeve := rw_crapidp.nrseqeve;
        vr_tab_inscritos(vr_ind_care).dtconins := TRUNC(vr_dtconins);
        vr_tab_inscritos(vr_ind_care).cdgraupr := vr_cdgraupr;
        vr_tab_inscritos(vr_ind_care).nmresage := vr_nmresage;
        vr_tab_inscritos(vr_ind_care).idstains := rw_crapidp.idstains;
        vr_tab_inscritos(vr_ind_care).dsstains := rw_crapidp.dsstains;
        vr_tab_inscritos(vr_ind_care).nrdrowid := rw_crapidp.cdrowid;
        vr_tab_inscritos(vr_ind_care).progress := rw_crapidp.progress_recid;
        vr_tab_inscritos(vr_ind_care).dtpreins := TRUNC(rw_crapidp.dtpreins);
        vr_tab_inscritos(vr_ind_care).qtfaleve := rw_crapidp.qtfaleve;
        vr_tab_inscritos(vr_ind_care).flginsin := vr_internet;
        vr_tab_inscritos(vr_ind_care).nrficpre := rw_crapidp.nrficpre;

      END IF;

      vr_qtdregis := vr_qtdregis + 1;

    END LOOP;

    pr_qtdregis := vr_qtdregis;

    -- VINCULO 
    vr_ind_care := 0;
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'CONFIG'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'PGSTINSCRI'
                                             ,pr_tpregist => 0);

    vr_paramemt := gene0002.fn_quebra_string(pr_string  => vr_dstextab
                                            ,pr_delimit => ',');
                                                                                                 
    -- Itera sobre a string quebrada
    IF vr_paramemt.count > 0 THEN
      FOR idx IN 1 .. vr_paramemt.count LOOP
        IF MOD(idx,2) = 0 THEN
          CONTINUE;
        END IF;
         
        IF vr_paramemt(idx+1) IN (3,5) THEN
          CONTINUE;
        END IF;
        
        -- Buscar qual a quantidade atual de registros no vetor para posicionar na próxima
        vr_ind_care := vr_tab_status.COUNT() + 1;

        -- Criar um registro na temp-table de status
        vr_tab_status(vr_ind_care).cdstatus := vr_paramemt(idx+1);
        vr_tab_status(vr_ind_care).dsstatus := vr_paramemt(idx);
          
      END LOOP;

    END IF;
    
    pr_tab_status := vr_tab_status;
    pr_tab_inscritos := vr_tab_inscritos;

  EXCEPTION
    WHEN vr_exc_saida THEN    
      IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;    
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em PC_WPGD0009.pc_lista_inscritos: ' || SQLERRM;
      ROLLBACK;    
  END pc_lista_inscritos;

  -- Rotina geral de consulta de lista de inscritos
  PROCEDURE pc_lista_inscritos_car(pr_cdcooper  IN crapppc.cdcooper%TYPE     --> Codigo da Cooperativa
                                  ,pr_cdageins  IN crapidp.cdageins%TYPE     --> Codigo do PA
                                  ,pr_nminscri  IN crapidp.nminseve%TYPE     --> Nome do Inscrito
                                  ,pr_nrseqeve  IN crapidp.nrseqeve%TYPE     --> Sequencial de Evento
                                  ,pr_tpfiltro  IN INTEGER                   --> Tipo de Filtro
                                  ,pr_tpordena  IN INTEGER                   --> Tipo de Ordenacao
                                  ,pr_dtanoage  IN crapppc.dtanoage%TYPE     --> Ano Agenda
                                  ,pr_idevento  IN crapedp.idevento%TYPE     --> ID do Evento
                                  ,pr_nriniseq  IN INTEGER                   --> Registro inicial para pesquisa
                                  ,pr_nrficpre  IN crapidp.nrficpre%TYPE     --> Número de Ficha de Inscrição
                                  ,pr_qtdregis OUT INTEGER                   --> Quantidade de Registros Existentes
                                  ,pr_clobxmlc OUT CLOB                      --> XML com informações de LOG
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descrição da crítica

  BEGIN

    /* .............................................................................

     Programa: pc_lista_inscritos_car
     Sistema : Progrid
     Sigla   : WPGD
     Autor   : Jean Michel
     Data    : Janeiro/2017.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de inscritos em eventos do Progrid

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_contador PLS_INTEGER := 0;
      
      -- Temp Table
      vr_tab_status    WPGD0009.typ_tab_status;
      vr_tab_inscritos WPGD0009.typ_tab_inscritos;

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
 
    BEGIN
      
      -- Cosnulta de inscritos em eventos do Progrid
      WPGD0009.pc_lista_inscritos(pr_cdcooper      => pr_cdcooper       --> Codigo da Cooperativa
                                 ,pr_cdageins      => pr_cdageins       --> Codigo do PA
                                 ,pr_nminscri      => TRIM(pr_nminscri) --> Nome do Inscrito
                                 ,pr_nrseqeve      => pr_nrseqeve       --> Sequencial de Evento
                                 ,pr_tpfiltro      => pr_tpfiltro       --> Tipo de Filtro
                                 ,pr_tpordena      => pr_tpordena       --> Tipo de Ordenacao
                                 ,pr_dtanoage      => pr_dtanoage       --> Ano Agenda
                                 ,pr_idevento      => pr_idevento       --> ID do Evento
                                 ,pr_nriniseq      => pr_nriniseq       --> Registro inicial para pesquisa
                                 ,pr_nrficpre      => pr_nrficpre       --> Número de Ficha de Inscrição
                                 ,pr_qtdregis      => pr_qtdregis       --> Quantidade de Registros Existentes
                                 ,pr_tab_status    => vr_tab_status     --> Tabela de Status
                                 ,pr_tab_inscritos => vr_tab_inscritos  --> Tabela de Inscritos
                                 ,pr_cdcritic      => vr_cdcritic       --> Código da crítica
                                 ,pr_dscritic      => vr_dscritic);     --> Descrição da crítica
      
      IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_tab_status.count > 0 THEN                       
        
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
        dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);       

        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>'); 

        -- STATUS                       
        -- Inicia a tag Status
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<status>' 
                               ,pr_fecha_xml      => TRUE);
                       
        FOR vr_contador IN vr_tab_status.FIRST..vr_tab_status.LAST LOOP

          -- Montar XML com registros de carencia
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                 ,pr_texto_completo => vr_xml_temp 
                                 ,pr_texto_novo     => '<status_inf>' 
                                                    || '<cdstatus>' || vr_tab_status(vr_contador).cdstatus || '</cdstatus>' 
                                                    || '<dsstatus>' || vr_tab_status(vr_contador).dsstatus || '</dsstatus>'
                                                    || '</status_inf>');
        END LOOP;

        -- Encerrar a tag Status 
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</status>' 
                               ,pr_fecha_xml      => TRUE);

      END IF;                       
      -- FIM STATUS                       

      -- INSCRITOS
      -- Inicia a tag Status
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<inscritos>' 
                             ,pr_fecha_xml      => TRUE);

      IF vr_tab_inscritos.count > 0 THEN
                       
        FOR vr_contador IN vr_tab_inscritos.FIRST..vr_tab_inscritos.LAST LOOP

          -- Montar XML com registros de carencia
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                 ,pr_texto_completo => vr_xml_temp 
                                 ,pr_texto_novo     => '<inscrito>' 
                                                    || '<nminseve>' || vr_tab_inscritos(vr_contador).nminseve || '</nminseve>'
                                                    || '<nmextttl>' || vr_tab_inscritos(vr_contador).nmextttl || '</nmextttl>'
                                                    || '<idseqttl>' || vr_tab_inscritos(vr_contador).idseqttl || '</idseqttl>'
                                                    || '<nrdconta>' || vr_tab_inscritos(vr_contador).nrdconta || '</nrdconta>'
                                                    || '<nrdddins>' || vr_tab_inscritos(vr_contador).nrdddins || '</nrdddins>'
                                                    || '<nrtelins>' || vr_tab_inscritos(vr_contador).nrtelins || '</nrtelins>'
                                                    || '<dsobsins>' || vr_tab_inscritos(vr_contador).dsobsins || '</dsobsins>'
                                                    || '<cdagenci>' || vr_tab_inscritos(vr_contador).cdagenci || '</cdagenci>'
                                                    || '<cdageins>' || vr_tab_inscritos(vr_contador).cdageins || '</cdageins>'
                                                    || '<cdcooper>' || vr_tab_inscritos(vr_contador).cdcooper || '</cdcooper>'
                                                    || '<cdevento>' || vr_tab_inscritos(vr_contador).cdevento || '</cdevento>'
                                                    || '<nrseqdig>' || vr_tab_inscritos(vr_contador).nrseqdig || '</nrseqdig>'
                                                    || '<nrseqeve>' || vr_tab_inscritos(vr_contador).nrseqeve || '</nrseqeve>'
                                                    || '<dtconins>' || vr_tab_inscritos(vr_contador).dtconins || '</dtconins>'
                                                    || '<cdgraupr>' || vr_tab_inscritos(vr_contador).cdgraupr || '</cdgraupr>'
                                                    || '<nmresage>' || vr_tab_inscritos(vr_contador).nmresage || '</nmresage>'
                                                    || '<idstains>' || vr_tab_inscritos(vr_contador).idstains || '</idstains>'
                                                    || '<dsstains>' || vr_tab_inscritos(vr_contador).dsstains || '</dsstains>'
                                                    || '<nrdrowid>' || vr_tab_inscritos(vr_contador).nrdrowid || '</nrdrowid>'
                                                    || '<progress>' || vr_tab_inscritos(vr_contador).progress || '</progress>'
                                                    || '<dtpreins>' || TO_CHAR(TO_DATE(vr_tab_inscritos(vr_contador).dtpreins)) || '</dtpreins>'
                                                    || '<qtfaleve>' || vr_tab_inscritos(vr_contador).qtfaleve || '</qtfaleve>'
                                                    || '<flginsin>' || vr_tab_inscritos(vr_contador).flginsin || '</flginsin>' 
                                                    || '<nrficpre>' || vr_tab_inscritos(vr_contador).nrficpre || '</nrficpre>'
                                                    || '</inscrito>');
        END LOOP;
        
      END IF; 

      -- Encerrar a tag Status 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</inscritos>' 
                             ,pr_fecha_xml      => TRUE);

      -- FIM INSCRITOS

      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</Dados>' 
                             ,pr_fecha_xml      => TRUE);
      
    EXCEPTION
      WHEN vr_exc_saida THEN

        IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
					vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Saldo WPGD0009.pc_lista_inscritos_car: ' || SQLERRM;
        ROLLBACK;
    END;

  END pc_lista_inscritos_car;

END WPGD0009;
/
