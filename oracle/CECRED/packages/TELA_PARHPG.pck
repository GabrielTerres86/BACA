CREATE OR REPLACE PACKAGE CECRED.TELA_PARHPG AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: TELA_PARHPG
--    Autor   : Douglas Quisinski
--    Data    : Abril/2016                      Ultima Atualizacao:  /  /
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da tela PARHPG (Parametrizacao de Horarios de Pagamento da COMPE)
--
--    Alteracoes:
--    
---------------------------------------------------------------------------------------------------------------

  -- Rotina para buscar as cooperativas
  PROCEDURE pc_busca_coop_parhpg(pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

  -- Rotina para buscar os horarios do PA SEDE da cooperativa selecionada
  PROCEDURE pc_busca_horarios_parhpg(pr_cdcooper   IN INTEGER            --> Codigo da Cooperativa
                                    ,pr_cddopcao   IN VARCHAR2           --> Codigo da Opcao
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
                                  
  -- Rotina para alterar os horarios de pagamentos/estornos das cooperativas
  PROCEDURE pc_altera_horario_parhpg(pr_cddopcao  IN VARCHAR2           --> Opcao
                                    ,pr_cdcooper  IN INTEGER            --> Codigo da Cooperativa (zero para todas)
                                    ,pr_hrsicatu  IN VARCHAR2           --> Atualizar Horario Pagamento SICREDI "S/N"
                                    ,pr_hrsicini  IN VARCHAR2           --> Horario Pagamento SICREDI - Inicial
                                    ,pr_hrsicfim  IN VARCHAR2           --> Horario Pagamento SICREDI - Final
                                    ,pr_hrtitatu  IN VARCHAR2           --> Atualizar Horario Pagamento TITULOS/FATURAS "S/N"
                                    ,pr_hrtitini  IN VARCHAR2           --> Horario Pagamento TITULOS/FATURAS - Inicial
                                    ,pr_hrtitfim  IN VARCHAR2           --> Horario Pagamento TITULOS/FATURAS - Final
                                    ,pr_hrnetatu  IN VARCHAR2           --> Atualizar Horario Pagamento INTERNET/MOBILE "S/N"
                                    ,pr_hrnetini  IN VARCHAR2           --> Horario Pagamento INTERNET/MOBILE - Inicial
                                    ,pr_hrnetfim  IN VARCHAR2           --> Horario Pagamento INTERNET/MOBILE - Final
                                    ,pr_hrtaaatu  IN VARCHAR2           --> Atualizar Horario Pagamento TAA "S/N"
                                    ,pr_hrtaaini  IN VARCHAR2           --> Horario Pagamento TAA - Inicial
                                    ,pr_hrtaafim  IN VARCHAR2           --> Horario Pagamento TAA - Final
                                    ,pr_hrgpsatu  IN VARCHAR2           --> Atualizar Horario Pagamento GPS "S/N"
                                    ,pr_hrgpsini  IN VARCHAR2           --> Horario Pagamento GPS - Inicial
                                    ,pr_hrgpsfim  IN VARCHAR2           --> Horario Pagamento GPS - Final
                                    ,pr_hrsiccau  IN VARCHAR2           --> Atualizar Horario Cancelamento Pagamento SICREDI "S/N"
                                    ,pr_hrsiccan  IN VARCHAR2           --> Horario Cancelamento Pagamento SICREDI
                                    ,pr_hrtitcau  IN VARCHAR2           --> Atualizar Horario Cancelamento Pagamento TITULOS/FATURAS "S/N"
                                    ,pr_hrtitcan  IN VARCHAR2           --> Horario Cancelamento Pagamento TITULOS/FATURAS
                                    ,pr_hrnetcau  IN VARCHAR2           --> Atualizar Horario Cancelamento Pagamento INTERNET/MOBILE "S/N"
                                    ,pr_hrnetcan  IN VARCHAR2           --> Horario Cancelamento Pagamento INTERNET/MOBILE
                                    ,pr_hrtaacau  IN VARCHAR2           --> Atualizar Horario Cancelamento Pagamento TAA "S/N"
                                    ,pr_hrtaacan  IN VARCHAR2           --> Horario Cancelamento Pagamento TAA
                                    ,pr_hrdiuatu  IN VARCHAR2           --> Atualizar Horario DEVOLUCAO DIURNA "S/N"
                                    ,pr_hrdiuini  IN VARCHAR2           --> Horario DEVOLUCAO DIURNA - Inicial
                                    ,pr_hrdiufim  IN VARCHAR2           --> Horario DEVOLUCAO DIURNA - Final
                                    ,pr_hrnotatu  IN VARCHAR2           --> Atualizar Horario DEVOLUCAO NOTURNA "S/N"
                                    ,pr_hrnotini  IN VARCHAR2           --> Horario DEVOLUCAO NOTURNA - Inicial
                                    ,pr_hrnotfim  IN VARCHAR2           --> Horario DEVOLUCAO NOTURNA - Final
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);         --> Erros do processo
END TELA_PARHPG;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARHPG AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: TELA_PARHPG
--    Autor   : Douglas Quisinski
--    Data    : Abril/2016                      Ultima Atualizacao:   /  /
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da tela PARHPG (Parametrizacao de Horarios de Pagamento da COMPE)
--
--    Alteracoes: 
--
---------------------------------------------------------------------------------------------------------------
  -- Rotina para buscar as cooperativas 
  PROCEDURE pc_busca_coop_parhpg(pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................
    Programa: pc_busca_coop_parhpg
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 18/04/2016                        Ultima atualizacao:   /  /

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as cooperativas ativas 

    Alteracoes:            
    ............................................................................. */
      CURSOR cr_crapcop IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
          FROM crapcop
         WHERE crapcop.cdcooper <> 3
           AND crapcop.flgativo = 1
      ORDER BY crapcop.cdcooper;
    BEGIN
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><cooperativas></cooperativas></Root>');
      
      pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                         ,'/Root/cooperativas'
                                         ,XMLTYPE('<cooperativa>'
                                                ||'  <cdcooper>0</cdcooper>'
                                                ||'  <nmrescop>TODAS</nmrescop>'
                                                ||'</cooperativa>'));
                                                  
      FOR rw_crapcop IN cr_crapcop LOOP
        -- Criar nodo filho
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/cooperativas'
                                            ,XMLTYPE('<cooperativa>'
                                                   ||'  <cdcooper>'||rw_crapcop.cdcooper||'</cdcooper>'
                                                   ||'  <nmrescop>'||UPPER(rw_crapcop.nmrescop)||'</nmrescop>'
                                                   ||'</cooperativa>'));
      END LOOP;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PARHPG.pc_busca_coop_parhpg): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_busca_coop_parhpg;

  -- Rotina para buscar os horarios do PA SEDE da cooperativa selecionada
  PROCEDURE pc_busca_horarios_parhpg(pr_cdcooper   IN INTEGER            --> Codigo da Cooperativa
                                    ,pr_cddopcao   IN VARCHAR2           --> Codigo da Opcao
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo

    /* .............................................................................
    Programa: pc_busca_horarios_parhpg
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 18/04/2016                        Ultima atualizacao:   /  /

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar os horarios de pagamento do PA SEDE da cooperativa selecionada
                Quando a cooperativa "0 - TODAS" for selecionada, carrega os dados do PA SEDE da VIACREDI

    Alteracoes:            
    ............................................................................. */
      -- Buscar as informacoes da cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE)IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.hrinigps
              ,cop.hrfimgps
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE; 

      -- Buscar o PA SEDE da cooperativa
      CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE)IS
        SELECT age.cdcooper
              ,age.cdagenci
              ,age.hrcancel
          FROM crapage age
         WHERE age.cdcooper = pr_cdcooper
           AND age.flgdsede = 1;
      rw_crapage cr_crapage%ROWTYPE; 
      
      -- Buscar o horario de cancelamento dos pagamentos na agencia
      CURSOR cr_crapage_can (pr_cdcooper IN crapage.cdcooper%TYPE
                            ,pr_cdagenci IN crapage.cdagenci%TYPE)IS
        SELECT age.cdcooper
              ,age.cdagenci
              ,age.hrcancel
          FROM crapage age
         WHERE age.cdcooper = pr_cdcooper
           AND age.cdagenci = pr_cdagenci;
      rw_crapage_can cr_crapage_can%ROWTYPE; 
      
      -- Variavies
      vr_cdcooper_pesq INTEGER;  
      vr_cdagenci_pesq INTEGER;
      vr_cdagenci_ib   INTEGER;
      vr_cdagenci_taa  INTEGER;
      vr_hrcancel      crapage.hrcancel%TYPE;
      vr_dstextab      craptab.dstextab%TYPE;
      
      -- CAMPOS - HORARIO DE PAGAMENTO 
      vr_hrsicini VARCHAR2(10); -- Hora Inicio - SICREDI
      vr_hrsicfim VARCHAR2(10); -- Hora Fim - SICREDI
      vr_hrtitini VARCHAR2(10); -- Hora Inicio - Titulo
      vr_hrtitfim VARCHAR2(10); -- Hora Fim - Titulo
      vr_hrnetini VARCHAR2(10); -- Hora Inicio - Internet
      vr_hrnetfim VARCHAR2(10); -- Hora Fim - Internet
      vr_hrtaaini VARCHAR2(10); -- Hora Inicio - TAA
      vr_hrtaafim VARCHAR2(10); -- Hora Fim - TAA
      vr_hrgpsini VARCHAR2(10); -- Hora Inicio - GPS
      vr_hrgpsfim VARCHAR2(10); -- Hora Fim - GPS
      -- CAMPOS - HORARIO DE ESTORNO DE PAGAMENTO
      vr_hrsiccan VARCHAR2(10); -- Hora Cancelamento - SICREDI
      vr_hrtitcan VARCHAR2(10); -- Hora Cancelamento - Titulo
      vr_hrnetcan VARCHAR2(10); -- Hora Cancelamento - Internet
      vr_hrtaacan VARCHAR2(10); -- Hora Cancelamento - TAA
      -- CAMPOS - DEVOLUCAO DE CHEQUE
      vr_hrvlbini VARCHAR2(10); -- Hora Inicio - Devolucao VLB
      vr_hrvlbfim VARCHAR2(10); -- Hora Fim - Devolucao VLB
      vr_hrdiuini VARCHAR2(10); -- Hora Inicio - Devolucao Diurno
      vr_hrdiufim VARCHAR2(10); -- Hora Fim - Devolucao Diurno
      vr_hrnotini VARCHAR2(10); -- Hora Inicio - Devolucao Noturno
      vr_hrnotfim VARCHAR2(10); -- Hora Fim - Devolucao Noturno
      
      -- Erros
      vr_exc_erro EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
    
    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PARHPG'
                                ,pr_action => null);
                                
      -- Verificar qual cooperativa foi selecionada
      IF pr_cdcooper = 0 THEN
        -- Se foi selecionado a cooperativa "TODAS", por padrao utiliza a VIACREDI
        vr_cdcooper_pesq:= 1;
      ELSE 
        vr_cdcooper_pesq:= pr_cdcooper;
      END IF;
      
      -- Verifica se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper  => vr_cdcooper_pesq);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;
      
      -- Buscar a Informacao do PA SEDE
      OPEN cr_crapage(pr_cdcooper  => vr_cdcooper_pesq);
      FETCH cr_crapage INTO rw_crapage;
      --Se nao encontrou
      IF cr_crapage%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapage;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Agencia SEDE da ' || rw_crapcop.nmrescop || ' nao encontrada.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapage;
      
      vr_cdagenci_pesq := rw_crapage.cdagenci;
      vr_cdagenci_ib   := 90;
      vr_cdagenci_taa  := 91;
      vr_hrcancel      := rw_crapage.hrcancel;
      
      -- Buscar os horarios do SICREDI
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper_pesq
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'HRPGSICRED'
                                               ,pr_tpregist => vr_cdagenci_pesq); -- PA SEDE
                                               
      IF TRIM(vr_dstextab) IS NOT NULL THEN                                      
        -- Hora Inicio - SICREDI
        vr_hrsicini := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(1,vr_dstextab,' '));
        -- Hora Fim - SICREDI
        vr_hrsicfim := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(2,vr_dstextab,' '));
        -- Hora Cancelamento - SICREDI
        vr_hrsiccan := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(3,vr_dstextab,' '));
      END IF;

      -- Buscar os horarios do Titulos/Faturas (Baseado na CADPAC)
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper_pesq
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'HRTRTITULO'
                                               ,pr_tpregist => vr_cdagenci_pesq); -- PA SEDE
                                               
      IF TRIM(vr_dstextab) IS NOT NULL THEN                                      
        -- Hora Inicio - Titulo
        IF TRIM(SUBSTR(vr_dstextab,9,5)) IS NULL THEN
          vr_hrtitini := '00:00';
        ELSE
          vr_hrtitini := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,9,5));
        END IF;
        -- Hora Fim - Titulo
        vr_hrtitfim := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,3,5));
        -- Hora Cancelamento - Titulo
        vr_hrtitcan := GENE0002.fn_converte_time_data(vr_hrcancel);
      END IF;

      -- Buscar os horarios da INTERNET
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper_pesq
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'HRTRTITULO'
                                               ,pr_tpregist => vr_cdagenci_ib); -- Internet/Mobile
      IF TRIM(vr_dstextab) IS NOT NULL THEN                                      
        -- Hora Inicio - Internet
        IF TRIM(SUBSTR(vr_dstextab,9,5)) IS NULL THEN
          vr_hrnetini := '00:00';
        ELSE
          vr_hrnetini := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,9,5));
        END IF;
        -- Hora Fim - Internet
        vr_hrnetfim := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,3,5));
      END IF;
      
      -- Buscar horario de cancelamento dos pagamentos para o Internet Bank
      OPEN cr_crapage_can(pr_cdcooper => vr_cdcooper_pesq
                         ,pr_cdagenci => vr_cdagenci_ib);
      FETCH cr_crapage_can INTO rw_crapage_can;
      IF cr_crapage_can%FOUND THEN
        -- Fecha Cursor
        CLOSE cr_crapage_can;
        -- Hora Cancelamento - Internet
        vr_hrnetcan := GENE0002.fn_converte_time_data(rw_crapage_can.hrcancel);
      ELSE 
        -- Fecha Cursor
        CLOSE cr_crapage_can;
      END IF;
      
      -- Buscar os horarios do TAA
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper_pesq
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'HRTRTITULO'
                                               ,pr_tpregist => vr_cdagenci_taa); -- TAA
      IF TRIM(vr_dstextab) IS NOT NULL THEN                                      
        -- Hora Inicio - TAA
        IF TRIM(SUBSTR(vr_dstextab,9,5)) IS NULL THEN
          vr_hrtaaini := '00:00';
        ELSE
          vr_hrtaaini := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,9,5));
        END IF;
        -- Hora Fim - TAA
        vr_hrtaafim := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,3,5));
      END IF;
      
      -- Buscar horario de cancelamento dos pagamentos para o Internet Bank
      OPEN cr_crapage_can(pr_cdcooper => vr_cdcooper_pesq
                         ,pr_cdagenci => vr_cdagenci_taa);
      FETCH cr_crapage_can INTO rw_crapage_can;
      IF cr_crapage_can%FOUND THEN
        -- Fecha Cursor
        CLOSE cr_crapage_can;
        -- Hora Cancelamento - TAA
        vr_hrtaacan := GENE0002.fn_converte_time_data(rw_crapage_can.hrcancel);
      ELSE 
        -- Fecha Cursor
        CLOSE cr_crapage_can;
      END IF;
      
      -- Hora Inicio - GPS
      vr_hrgpsini := GENE0002.fn_converte_time_data(rw_crapcop.hrinigps);
      -- Hora Fim - GPS
      vr_hrgpsfim := GENE0002.fn_converte_time_data(rw_crapcop.hrfimgps);
      
      -- Buscar as informacoes de devolucao de cheque (Baseado na TAB055)
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper_pesq
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'HRTRDEVOLU'
                                               ,pr_tpregist => 0);

      IF TRIM(vr_dstextab) IS NOT NULL THEN
        -- Hora Inicio - Devolucao VLB
        vr_hrvlbini := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(1,vr_dstextab,';'));
        -- Hora Fim - Devolucao VLB
        vr_hrvlbfim := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(2,vr_dstextab,';'));
        -- Hora Inicio - Devolucao Diurno
        vr_hrdiuini := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(3,vr_dstextab,';'));
        -- Hora Fim - Devolucao Diurno
        vr_hrdiufim := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(4,vr_dstextab,';'));
        -- Hora Inicio - Devolucao Noturno
        vr_hrnotini := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(5,vr_dstextab,';'));
        -- Hora Fim - Devolucao Noturno
        vr_hrnotfim := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(6,vr_dstextab,';'));
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                     '<Root>' ||
                                     '  <horarios>' ||
                                     '    <hrsicini>' || NVL(vr_hrsicini,'') || '</hrsicini>' || -- Hora Inicio - SICREDI
                                     '    <hrsicfim>' || NVL(vr_hrsicfim,'') || '</hrsicfim>' || -- Hora Fim - SICREDI
                                     '    <hrsiccan>' || NVL(vr_hrsiccan,'') || '</hrsiccan>' || -- Hora Cancelamento - SICREDI
                                     '    <hrtitini>' || NVL(vr_hrtitini,'') || '</hrtitini>' || -- Hora Inicio - Titulo
                                     '    <hrtitfim>' || NVL(vr_hrtitfim,'') || '</hrtitfim>' || -- Hora Fim - Titulo
                                     '    <hrtitcan>' || NVL(vr_hrtitcan,'') || '</hrtitcan>' || -- Hora Cancelamento - Titulo
                                     '    <hrnetini>' || NVL(vr_hrnetini,'') || '</hrnetini>' || -- Hora Inicio - Internet
                                     '    <hrnetfim>' || NVL(vr_hrnetfim,'') || '</hrnetfim>' || -- Hora Fim - Internet
                                     '    <hrnetcan>' || NVL(vr_hrnetcan,'') || '</hrnetcan>' || -- Hora Cancelamento - Internet
                                     '    <hrtaaini>' || NVL(vr_hrtaaini,'') || '</hrtaaini>' || -- Hora Inicio - TAA
                                     '    <hrtaafim>' || NVL(vr_hrtaafim,'') || '</hrtaafim>' || -- Hora Fim - TAA
                                     '    <hrtaacan>' || NVL(vr_hrtaacan,'') || '</hrtaacan>' || -- Hora Cancelamento - TAA
                                     '    <hrgpsini>' || NVL(vr_hrgpsini,'') || '</hrgpsini>' || -- Hora Inicio - GPS
                                     '    <hrgpsfim>' || NVL(vr_hrgpsfim,'') || '</hrgpsfim>' || -- Hora Fim - GPS
                                     '    <hrvlbini>' || NVL(vr_hrvlbini,'') || '</hrvlbini>' || -- Hora Inicio - Devolucao VLB
                                     '    <hrvlbfim>' || NVL(vr_hrvlbfim,'') || '</hrvlbfim>' || -- Hora Fim - Devolucao VLB
                                     '    <hrdiuini>' || NVL(vr_hrdiuini,'') || '</hrdiuini>' || -- Hora Inicio - Devolucao Diurno
                                     '    <hrdiufim>' || NVL(vr_hrdiufim,'') || '</hrdiufim>' || -- Hora Fim - Devolucao Diurno
                                     '    <hrnotini>' || NVL(vr_hrnotini,'') || '</hrnotini>' || -- Hora Inicio - Devolucao Noturno
                                     '    <hrnotfim>' || NVL(vr_hrnotfim,'') || '</hrnotfim>' || -- Hora Fim - Devolucao Noturno
                                     '  </horarios>' ||
                                     '</Root>');
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PARHPG.pc_busca_horarios_parhpg): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_busca_horarios_parhpg;

  -- Rotina para alterar os horarios de pagamentos/estornos do SICREDI
  PROCEDURE pc_altera_horario_sicredi(pr_cdcooper  IN INTEGER      --> Codigo da Cooperativa (zero para todas)
                                     ,pr_hrsicatu  IN VARCHAR2     --> Atualizar Horario Pagamento SICREDI "S/N"
                                     ,pr_hrsicini  IN VARCHAR2     --> Horario Pagamento SICREDI - Inicial
                                     ,pr_hrsicfim  IN VARCHAR2     --> Horario Pagamento SICREDI - Final
                                     ,pr_hrsiccau  IN VARCHAR2     --> Atualizar Horario Cancelamento Pagamento SICREDI "S/N"
                                     ,pr_hrsiccan  IN VARCHAR2     --> Horario Cancelamento Pagamento SICREDI
                                     ,pr_nmdcampo OUT VARCHAR2     --> Nome do campo com erro
                                     ,pr_cdcritic OUT PLS_INTEGER  --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica

    /* .............................................................................
    Programa: pc_altera_horario_sicredi
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 20/04/2016                        Ultima atualizacao: 01/06/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para alterar os horarios de pagamentos/estornos do SICREDI em todos os PAs
                Horario do SICREDI eh para todas os PAs

    Alteracoes: 01/06/2016 - Adicionado UPPER na leitura da craptab, para que seja utilizado 
                             o indice na pesquisa (Douglas - Chamado 454248)
    ............................................................................. */
    -- Parametros de horarios SICREDI -- COOPERATIVA
    CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT tab.cdcooper
            ,tab.nmsistem
            ,tab.tptabela
            ,tab.cdempres
            ,tab.cdacesso
            ,tab.tpregist
            ,tab.dstextab 
        FROM craptab tab
       WHERE ((tab.cdcooper > 0 AND pr_cdcooper = 0) OR tab.cdcooper = pr_cdcooper)
         AND tab.cdcooper <> 3 -- nao altera da CECRED
         AND UPPER(tab.nmsistem) = UPPER('CRED')
         AND UPPER(tab.tptabela) = UPPER('GENERI')
         AND tab.cdempres = 00
         AND UPPER(tab.cdacesso) = UPPER('HRPGSICRED')
         AND tab.tpregist > 0;

      -- Dados craptab
      vr_dstextab_aux craptab.dstextab%TYPE;
      vr_dstextab_new craptab.dstextab%TYPE;
      
      vr_hrsicini VARCHAR2(10); -- Hora Inicio - SICREDI
      vr_hrsicfim VARCHAR2(10); -- Hora Fim - SICREDI
      vr_hrsiccan VARCHAR2(10); -- Hora Cancelamento - SICREDI

      vr_hrinicio  VARCHAR2(5);
      vr_hrfinal   VARCHAR2(5);
      vr_hrcancela VARCHAR2(5);
      
      -- Erros
      vr_exc_erro EXCEPTION;
      vr_exit     EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
    
    BEGIN
      
      -- Verificar se atualiza o horario de pagamento e cancelamento
      IF pr_hrsicatu <> 'S' AND pr_hrsiccau <> 'S' THEN
        -- nao executa nada
        RAISE vr_exit;
      END IF;
    
      -- Converter a hora inicial em numerico
      BEGIN
        vr_hrinicio := TO_CHAR(TO_DATE(pr_hrsicini,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Pagamento SICREDI - Inicial invalido (' || pr_hrsicini || ')';
          pr_nmdcampo := 'hrsicini';
          RAISE vr_exc_erro;
      END;  
    
      -- Converter a hora final em numerico
      BEGIN
        vr_hrfinal := TO_CHAR(TO_DATE(pr_hrsicfim,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Pagamento SICREDI - Final invalido (' || pr_hrsicfim || ')';
          pr_nmdcampo := 'hrsicfim';
          RAISE vr_exc_erro;
      END;  
    
      -- Converter a hora cancelamento em numerico
      BEGIN
        vr_hrcancela := TO_CHAR(TO_DATE(pr_hrsiccan,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Cancelamento de Pagamento SICREDI invalido (' || pr_hrsiccan || ')';
          pr_nmdcampo := 'hrsiccan';
          RAISE vr_exc_erro;
      END;  
    
      FOR rw IN cr_craptab (pr_cdcooper => pr_cdcooper) LOOP
        -- Hora Inicio - SICREDI
        vr_hrsicini := GENE0002.fn_busca_entrada(1,rw.dstextab,' ');
        -- Hora Fim - SICREDI
        vr_hrsicfim := GENE0002.fn_busca_entrada(2,rw.dstextab,' ');
        -- Hora Cancelamento - SICREDI
        vr_hrsiccan := GENE0002.fn_busca_entrada(3,rw.dstextab,' ');
          
        -- Processo Manual - Sicredi
        vr_dstextab_aux := SUBSTR(rw.dstextab,19,3);

        -- Inicializa a novo valor
        vr_dstextab_new := '';
          
        -- Verificar se atualiza Horario Incial e Final de Pagamento SICREDI
        IF pr_hrsicatu = 'S' THEN
          vr_dstextab_new := vr_hrinicio || ' ' ||
                             vr_hrfinal  || ' ';
        ELSE
          -- Se nao atualizar, mantem os valores originais
          vr_dstextab_new := vr_hrsicini || ' ' ||
                             vr_hrsicfim || ' ';
        END IF;

        -- Verificar se atualiza Horario de CANCELAMENTO do Pagamento SICREDI
        IF pr_hrsiccau = 'S' THEN
          vr_dstextab_new := vr_dstextab_new || vr_hrcancela;
        ELSE
          -- Se nao atualizar, mantem os valores originais
          vr_dstextab_new := vr_dstextab_new || vr_hrsiccan;
        END IF;
          
        -- Completar ate o limite de 18 caracteres, pois o Processo manual SICREDI inicia na posicao 19
        vr_dstextab_new := RPAD(vr_dstextab_new,18,' ');
          
        -- Processo manual SICREDI inicia na posicao 19
        vr_dstextab_new := vr_dstextab_new || vr_dstextab_aux;
        
        UPDATE craptab tab
           SET tab.dstextab = vr_dstextab_new
         WHERE tab.cdcooper = rw.cdcooper
           AND UPPER(tab.nmsistem) = UPPER(rw.nmsistem)
           AND UPPER(tab.tptabela) = UPPER(rw.tptabela)
           AND tab.cdempres = rw.cdempres
           AND UPPER(tab.cdacesso) = UPPER(rw.cdacesso)
           AND tab.tpregist = rw.tpregist;
        
      END LOOP;
      
    EXCEPTION
      WHEN vr_exit THEN
        -- Nao executa nada, apenas controla saida sem execucao 
        NULL;
    
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PARHPG.pc_altera_horario_sicredi): ' || SQLERRM;
        ROLLBACK;
  END pc_altera_horario_sicredi;

  -- Rotina para alterar os horarios de pagamentos/estornos do TITULOS/FATURAS
  PROCEDURE pc_altera_horario_titulos(pr_cdcooper  IN INTEGER      --> Codigo da Cooperativa (zero para todas)
                                     ,pr_hrtitatu  IN VARCHAR2     --> Atualizar Horario Pagamento TITULOS/FATURAS "S/N"
                                     ,pr_hrtitini  IN VARCHAR2     --> Horario Pagamento TITULOS/FATURAS - Inicial
                                     ,pr_hrtitfim  IN VARCHAR2     --> Horario Pagamento TITULOS/FATURAS - Final
                                     ,pr_hrtitcau  IN VARCHAR2     --> Atualizar Horario Cancelamento Pagamento TITULOS/FATURAS "S/N"
                                     ,pr_hrtitcan  IN VARCHAR2     --> Horario Cancelamento Pagamento TITULOS/FATURAS
                                     ,pr_nmdcampo OUT VARCHAR2     --> Nome do campo com erro
                                     ,pr_cdcritic OUT PLS_INTEGER  --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica

    /* .............................................................................
    Programa: pc_altera_horario_titulos
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 20/04/2016                        Ultima atualizacao: 01/06/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para alterar os horarios de pagamentos/estornos de TITULOS/FATURAS em todos os PAs
                Horario de pagamento de TITULOS/FATURAS, atualiza todos os PAs, menos Internet(90) e TAA(91)

    Alteracoes: 01/06/2016 - Adicionado UPPER na leitura da craptab, para que seja utilizado 
                             o indice na pesquisa (Douglas - Chamado 454248)
    ............................................................................. */
    -- Parametros de horarios TITULOS/FATURAS -- COOPERATIVA
    CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT tab.cdcooper
            ,tab.nmsistem
            ,tab.tptabela
            ,tab.cdempres
            ,tab.cdacesso
            ,tab.tpregist
            ,tab.dstextab 
        FROM craptab tab
       WHERE ((tab.cdcooper > 0 AND pr_cdcooper = 0) OR tab.cdcooper = pr_cdcooper)
         AND tab.cdcooper <> 3 -- nao altera da CECRED
         AND UPPER(tab.nmsistem) = UPPER('CRED')
         AND UPPER(tab.tptabela) = UPPER('GENERI')
         AND tab.cdempres = 00
         AND UPPER(tab.cdacesso) = UPPER('HRTRTITULO')
         -- nao altera dados dos PAs 90 e 91
         AND tab.tpregist NOT IN (90,91);
         
    -- Agencias da cooperativa - Ignora PA 90 e 91
    CURSOR cr_crapage (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT age.cdcooper
            ,age.cdagenci
            ,age.hrcancel
        FROM crapage age
       WHERE ((age.cdcooper > 0 AND pr_cdcooper = 0) OR age.cdcooper = pr_cdcooper)
         AND age.cdcooper <> 3 -- nao altera da CECRED
         -- nao altera dados dos PAs 90 e 91
         AND age.cdagenci NOT IN (90,91);         

      -- Dados craptab
      vr_dstextab_new craptab.dstextab%TYPE;
      
      vr_hrinicio  VARCHAR2(5);
      vr_hrfinal   VARCHAR2(5);
      vr_hrcancela VARCHAR2(5);
      
      -- Erros
      vr_exc_erro EXCEPTION;
      vr_exit     EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
    
    BEGIN

      -- Verificar se atualiza o horario de pagamento e cancelamento
      IF pr_hrtitatu <> 'S' AND pr_hrtitcau <> 'S' THEN
        -- nao executa nada
        RAISE vr_exit;
      END IF;
    
      -- Converter a hora inicial em numerico
      BEGIN
        vr_hrinicio := TO_CHAR(TO_DATE(pr_hrtitini,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Pagamento TITULOS/FATURAS - Inicial invalido (' || pr_hrtitini || ')';
          pr_nmdcampo := 'hrtitini';
          RAISE vr_exc_erro;
      END;  
    
      -- Converter a hora final em numerico
      BEGIN
        vr_hrfinal := TO_CHAR(TO_DATE(pr_hrtitfim,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Pagamento TITULOS/FATURAS - Final invalido (' || pr_hrtitfim || ')';
          pr_nmdcampo := 'hrtitfim';
          RAISE vr_exc_erro;
      END;  
    
      -- Converter a hora cancelamento em numerico
      BEGIN
        vr_hrcancela := TO_CHAR(TO_DATE(pr_hrtitcan,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Cancelamento de Pagamento TITULOS/FATURAS invalido (' || pr_hrtitcan || ')';
          pr_nmdcampo := 'hrtitcan';
          RAISE vr_exc_erro;
      END;  

      -- Verificar se atualiza Horario Incial e Final de Pagamento TITULOS/FATURAS
      IF pr_hrtitatu = 'S' THEN
        FOR rw IN cr_craptab (pr_cdcooper => pr_cdcooper) LOOP
          -- Inicializa a novo valor
          vr_dstextab_new := SUBSTR(rw.dstextab, 1, 2) ||
                             -- Posicoes 3 ate 8 horario fim
                             vr_hrfinal || ' ' ||
                             -- Posicoes 9 ate 13 horario inicio
                             vr_hrinicio || ' ' ||
                             -- Concatenar o resto da informacao
                             -- Processo manual SICREDI
                             SUBSTR(rw.dstextab, 15, LENGTH(rw.dstextab));
          
          UPDATE craptab tab
             SET tab.dstextab = vr_dstextab_new
           WHERE tab.cdcooper = rw.cdcooper
             AND UPPER(tab.nmsistem) = UPPER(rw.nmsistem)
             AND UPPER(tab.tptabela) = UPPER(rw.tptabela)
             AND tab.cdempres = rw.cdempres
             AND UPPER(tab.cdacesso) = UPPER(rw.cdacesso)
             AND tab.tpregist = rw.tpregist;
          
        END LOOP;
      END IF;
    
      -- Verificar se atualiza Horario de Cancelamento de Pagamento TITULOS/FATURAS
      IF pr_hrtitcau = 'S' THEN
        -- Atualizar o horario de cancelamento que esta na crapage
        FOR rw IN cr_crapage(pr_cdcooper => pr_cdcooper) LOOP
          -- Atualizar
          UPDATE crapage age
             SET age.hrcancel = vr_hrcancela
           WHERE age.cdcooper = rw.cdcooper
             AND age.cdagenci = rw.cdagenci;
        END LOOP;
      END IF;

    EXCEPTION
      WHEN vr_exit THEN
        -- Nao executa nada, apenas controla saida sem execucao 
        NULL;
        
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PARHPG.pc_altera_horario_titulos): ' || SQLERRM;
        ROLLBACK;
  END pc_altera_horario_titulos;

  -- Rotina para alterar os horarios de pagamentos/estornos do INTERNET/MOBILE
  PROCEDURE pc_altera_horario_internet(pr_cdcooper  IN INTEGER      --> Codigo da Cooperativa (zero para todas)
                                      ,pr_hrnetatu  IN VARCHAR2     --> Atualizar Horario Pagamento INTERNET/MOBILE "S/N"
                                      ,pr_hrnetini  IN VARCHAR2     --> Horario Pagamento INTERNET/MOBILE - Inicial
                                      ,pr_hrnetfim  IN VARCHAR2     --> Horario Pagamento INTERNET/MOBILE - Final
                                      ,pr_hrnetcau  IN VARCHAR2     --> Atualizar Horario Cancelamento Pagamento INTERNET/MOBILE "S/N"
                                      ,pr_hrnetcan  IN VARCHAR2     --> Horario Cancelamento Pagamento INTERNET/MOBILE
                                      ,pr_nmdcampo OUT VARCHAR2     --> Nome do campo com erro
                                      ,pr_cdcritic OUT PLS_INTEGER  --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica

    /* .............................................................................
    Programa: pc_altera_horario_internet
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 20/04/2016                        Ultima atualizacao: 01/06/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para alterar os horarios de pagamentos/estornos de INTERNET/MOBILE apenas PA 90
                Horario de pagamento de INTERNET/MOBILE, atualiza apenas o PA 90 

    Alteracoes: 01/06/2016 - Adicionado UPPER na leitura da craptab, para que seja utilizado 
                             o indice na pesquisa (Douglas - Chamado 454248)
    ............................................................................. */
    -- Parametros de horarios INTERNET/MOBILE -- COOPERATIVA
    CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT tab.cdcooper
            ,tab.nmsistem
            ,tab.tptabela
            ,tab.cdempres
            ,tab.cdacesso
            ,tab.tpregist
            ,tab.dstextab 
        FROM craptab tab
       WHERE ((tab.cdcooper > 0 AND pr_cdcooper = 0) OR tab.cdcooper = pr_cdcooper)
         AND tab.cdcooper <> 3 -- nao altera da CECRED
         AND UPPER(tab.nmsistem) = UPPER('CRED')
         AND UPPER(tab.tptabela) = UPPER('GENERI')
         AND tab.cdempres = 00
         AND UPPER(tab.cdacesso) = UPPER('HRTRTITULO')
         -- apenas PA 90 
         AND tab.tpregist = 90;
         
    -- Agencias da cooperativa - Apenas INTERNET PA 90
    CURSOR cr_crapage (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT age.cdcooper
            ,age.cdagenci
            ,age.hrcancel
        FROM crapage age
       WHERE ((age.cdcooper > 0 AND pr_cdcooper = 0) OR age.cdcooper = pr_cdcooper)
         AND age.cdcooper <> 3 -- nao altera da CECRED
         -- apenas PA 90
         AND age.cdagenci = 90;

      -- Dados craptab
      vr_dstextab_new craptab.dstextab%TYPE;
      
      vr_hrinicio  VARCHAR2(5);
      vr_hrfinal   VARCHAR2(5);
      vr_hrcancela VARCHAR2(5);
      
      -- Erros
      vr_exc_erro EXCEPTION;
      vr_exit     EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
    
    BEGIN

      -- Verificar se atualiza o horario de pagamento e cancelamento
      IF pr_hrnetatu <> 'S' AND pr_hrnetcau <> 'S' THEN
        -- nao executa nada
        RAISE vr_exit;
      END IF;
    
      -- Converter a hora inicial em numerico
      BEGIN
        vr_hrinicio := TO_CHAR(TO_DATE(pr_hrnetini,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Pagamento INTERNET/MOBILE - Inicial invalido (' || pr_hrnetini || ')';
          pr_nmdcampo := 'hrnetini';
          RAISE vr_exc_erro;
      END;  
    
      -- Converter a hora final em numerico
      BEGIN
        vr_hrfinal := TO_CHAR(TO_DATE(pr_hrnetfim,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Pagamento INTERNET/MOBILE - Final invalido (' || pr_hrnetfim || ')';
          pr_nmdcampo := 'hrnetfim';
          RAISE vr_exc_erro;
      END;  
    
      -- Converter a hora cancelamento em numerico
      BEGIN
        vr_hrcancela := TO_CHAR(TO_DATE(pr_hrnetcan,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Cancelamento de Pagamento INTERNET/MOBILE invalido (' || pr_hrnetcan || ')';
          pr_nmdcampo := 'hrnetcan';
          RAISE vr_exc_erro;
      END;  

      -- Verificar se atualiza Horario Incial e Final de Pagamento INTERNET/MOBILE
      IF pr_hrnetatu = 'S' THEN
        FOR rw IN cr_craptab (pr_cdcooper => pr_cdcooper) LOOP
          -- Inicializa a novo valor
          vr_dstextab_new := SUBSTR(rw.dstextab, 1, 2) ||
                             -- Posicoes 3 ate 8 horario fim
                             vr_hrfinal || ' ' ||
                             -- Posicoes 9 ate 13 horario inicio
                             vr_hrinicio || ' ' ||
                             -- Concatenar o resto da informacao
                             -- Processo manual SICREDI
                             SUBSTR(rw.dstextab, 15, LENGTH(rw.dstextab));
          
          UPDATE craptab tab
             SET tab.dstextab = vr_dstextab_new
           WHERE tab.cdcooper = rw.cdcooper
             AND UPPER(tab.nmsistem) = UPPER(rw.nmsistem)
             AND UPPER(tab.tptabela) = UPPER(rw.tptabela)
             AND tab.cdempres = rw.cdempres
             AND UPPER(tab.cdacesso) = UPPER(rw.cdacesso)
             AND tab.tpregist = rw.tpregist;
          
        END LOOP;
      END IF;
    
      -- Verificar se atualiza Horario de Cancelamento de Pagamento INTERNET/MOBILE
      IF pr_hrnetcau = 'S' THEN
        -- Atualizar o horario de cancelamento que esta na crapage
        FOR rw IN cr_crapage(pr_cdcooper => pr_cdcooper) LOOP
          -- Atualizar
          UPDATE crapage age
             SET age.hrcancel = vr_hrcancela
           WHERE age.cdcooper = rw.cdcooper
             AND age.cdagenci = rw.cdagenci;
        END LOOP;
      END IF;

    EXCEPTION
      WHEN vr_exit THEN
        -- Nao executa nada, apenas controla saida sem execucao 
        NULL;
        
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PARHPG.pc_altera_horario_internet): ' || SQLERRM;
        ROLLBACK;
  END pc_altera_horario_internet;

  -- Rotina para alterar os horarios de pagamentos/estornos do TAA
  PROCEDURE pc_altera_horario_taa(pr_cdcooper  IN INTEGER      --> Codigo da Cooperativa (zero para todas)
                                 ,pr_hrtaaatu  IN VARCHAR2     --> Atualizar Horario Pagamento TAA "S/N"
                                 ,pr_hrtaaini  IN VARCHAR2     --> Horario Pagamento TAA - Inicial
                                 ,pr_hrtaafim  IN VARCHAR2     --> Horario Pagamento TAA - Final
                                 ,pr_hrtaacau  IN VARCHAR2     --> Atualizar Horario Cancelamento Pagamento TAA "S/N"
                                 ,pr_hrtaacan  IN VARCHAR2     --> Horario Cancelamento Pagamento TAA
                                 ,pr_nmdcampo OUT VARCHAR2     --> Nome do campo com erro
                                 ,pr_cdcritic OUT PLS_INTEGER  --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica

    /* .............................................................................
    Programa: pc_altera_horario_taa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 20/04/2016                        Ultima atualizacao: 01/06/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para alterar os horarios de pagamentos/estornos de TAA apenas PA 91
                Horario de pagamento de TAA, atualiza apenas o PA 91 

    Alteracoes: 01/06/2016 - Adicionado UPPER na leitura da craptab, para que seja utilizado 
                             o indice na pesquisa (Douglas - Chamado 454248)
    ............................................................................. */
    -- Parametros de horarios TAA -- COOPERATIVA
    CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT tab.cdcooper
            ,tab.nmsistem
            ,tab.tptabela
            ,tab.cdempres
            ,tab.cdacesso
            ,tab.tpregist
            ,tab.dstextab 
        FROM craptab tab
       WHERE ((tab.cdcooper > 0 AND pr_cdcooper = 0) OR tab.cdcooper = pr_cdcooper)
         AND tab.cdcooper <> 3 -- nao altera da CECRED
         AND UPPER(tab.nmsistem) = UPPER('CRED')
         AND UPPER(tab.tptabela) = UPPER('GENERI')
         AND tab.cdempres = 00
         AND UPPER(tab.cdacesso) = UPPER('HRTRTITULO')
         -- apenas PA 91 
         AND tab.tpregist = 91;
         
    -- Agencias da cooperativa - Apenas TAA PA 91
    CURSOR cr_crapage (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT age.cdcooper
            ,age.cdagenci
            ,age.hrcancel
        FROM crapage age
       WHERE ((age.cdcooper > 0 AND pr_cdcooper = 0) OR age.cdcooper = pr_cdcooper)
         AND age.cdcooper <> 3 -- nao altera da CECRED
         -- apenas PA 91
         AND age.cdagenci = 91;

      -- Dados craptab
      vr_dstextab_new craptab.dstextab%TYPE;
      
      vr_hrinicio  VARCHAR2(5);
      vr_hrfinal   VARCHAR2(5);
      vr_hrcancela VARCHAR2(5);
      
      -- Erros
      vr_exc_erro EXCEPTION;
      vr_exit     EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
    
    BEGIN
      
      -- Verificar se atualiza o horario de pagamento e cancelamento
      IF pr_hrtaaatu <> 'S' AND pr_hrtaacau <> 'S' THEN
        -- nao executa nada
        RAISE vr_exit;
      END IF;
    
      -- Converter a hora inicial em numerico
      BEGIN
        vr_hrinicio := TO_CHAR(TO_DATE(pr_hrtaaini,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Pagamento TAA - Inicial invalido (' || pr_hrtaaini || ')';
          pr_nmdcampo := 'hrtaaini';
          RAISE vr_exc_erro;
      END;  
    
      -- Converter a hora final em numerico
      BEGIN
        vr_hrfinal := TO_CHAR(TO_DATE(pr_hrtaafim,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Pagamento TAA - Final invalido (' || pr_hrtaafim || ')';
          pr_nmdcampo := 'hrtaafim';
          RAISE vr_exc_erro;
      END;  
    
      -- Converter a hora cancelamento em numerico
      BEGIN
        vr_hrcancela := TO_CHAR(TO_DATE(pr_hrtaacan,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Cancelamento de Pagamento TAA invalido (' || pr_hrtaacan || ')';
          pr_nmdcampo := 'hrtaacan';
          RAISE vr_exc_erro;
      END;  

      -- Verificar se atualiza Horario Incial e Final de Pagamento INTERNET/MOBILE
      IF pr_hrtaaatu = 'S' THEN
        FOR rw IN cr_craptab (pr_cdcooper => pr_cdcooper) LOOP
          -- Inicializa a novo valor
          vr_dstextab_new := SUBSTR(rw.dstextab, 1, 2) ||
                             -- Posicoes 3 ate 8 horario fim
                             vr_hrfinal || ' ' ||
                             -- Posicoes 9 ate 13 horario inicio
                             vr_hrinicio || ' ' ||
                             -- Concatenar o resto da informacao
                             -- Processo manual SICREDI
                             SUBSTR(rw.dstextab, 15, LENGTH(rw.dstextab));
          
          UPDATE craptab tab
             SET tab.dstextab = vr_dstextab_new
           WHERE tab.cdcooper = rw.cdcooper
             AND UPPER(tab.nmsistem) = UPPER(rw.nmsistem)
             AND UPPER(tab.tptabela) = UPPER(rw.tptabela)
             AND tab.cdempres = rw.cdempres
             AND UPPER(tab.cdacesso) = UPPER(rw.cdacesso)
             AND tab.tpregist = rw.tpregist;
          
        END LOOP;
      END IF;
    
      -- Verificar se atualiza Horario de Cancelamento de Pagamento INTERNET/MOBILE
      IF pr_hrtaacau = 'S' THEN
        -- Atualizar o horario de cancelamento que esta na crapage
        FOR rw IN cr_crapage(pr_cdcooper => pr_cdcooper) LOOP
          -- Atualizar
          UPDATE crapage age
             SET age.hrcancel = vr_hrcancela
           WHERE age.cdcooper = rw.cdcooper
             AND age.cdagenci = rw.cdagenci;
        END LOOP;
      END IF;

    EXCEPTION
      WHEN vr_exit THEN
        -- Nao executa nada, apenas controla saida sem execucao 
        NULL;
        
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PARHPG.pc_altera_horario_taa): ' || SQLERRM;
        ROLLBACK;
  END pc_altera_horario_taa;

  -- Rotina para alterar os horarios de pagamentos/estornos do GPS
  PROCEDURE pc_altera_horario_gps(pr_cdcooper  IN INTEGER      --> Codigo da Cooperativa (zero para todas)
                                 ,pr_hrgpsatu  IN VARCHAR2     --> Atualizar Horario Pagamento GPS "S/N"
                                 ,pr_hrgpsini  IN VARCHAR2     --> Horario Pagamento GPS - Inicial
                                 ,pr_hrgpsfim  IN VARCHAR2     --> Horario Pagamento GPS - Final
                                 ,pr_nmdcampo OUT VARCHAR2     --> Nome do campo com erro
                                 ,pr_cdcritic OUT PLS_INTEGER  --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica

    /* .............................................................................
    Programa: pc_altera_horario_gps
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 20/04/2016                        Ultima atualizacao:   /  /

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para alterar os horarios de pagamentos/estornos de GPS
                Horario de pagamento de GPS, eh armazenado na Cooperativa

    Alteracoes:            
    ............................................................................. */
    -- Dados da Cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.hrinigps
            ,cop.hrfimgps
        FROM crapcop cop
       WHERE ((cop.cdcooper > 0 AND pr_cdcooper = 0) OR cop.cdcooper = pr_cdcooper)
         AND cop.cdcooper <> 3; -- nao altera da CECRED
         
      -- Horarios
      vr_hrinicio  VARCHAR2(5);
      vr_hrfinal   VARCHAR2(5);
      
      -- Erros
      vr_exc_erro EXCEPTION;
      vr_exit     EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
    BEGIN

      -- Verificar se atualiza o horario de pagamento
      IF pr_hrgpsatu <> 'S' THEN
        -- nao executa nada
        RAISE vr_exit;
      END IF;
    
      -- Converter a hora inicial em numerico
      BEGIN
        vr_hrinicio := TO_CHAR(TO_DATE(pr_hrgpsini,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Pagamento GPS - Inicial invalido (' || pr_hrgpsini || ')';
          pr_nmdcampo := 'hrgpsini';
          RAISE vr_exc_erro;
      END;  
    
      -- Converter a hora final em numerico
      BEGIN
        vr_hrfinal := TO_CHAR(TO_DATE(pr_hrgpsfim,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario Pagamento GPS - Final invalido (' || pr_hrgpsfim || ')';
          pr_nmdcampo := 'hrgpsfim';
          RAISE vr_exc_erro;
      END;  

      -- Atualizar o horario da pagamento das guias de GPS na crapcop
      FOR rw IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP
        -- Atualizar
        UPDATE crapcop cop
           SET cop.hrinigps = vr_hrinicio
              ,cop.hrfimgps = vr_hrfinal
         WHERE cop.cdcooper = rw.cdcooper;
      END LOOP;
      
    EXCEPTION
      WHEN vr_exit THEN
        -- Nao executa nada, apenas controla saida sem execucao 
        NULL;

      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PARHPG.pc_altera_horario_gps): ' || SQLERRM;
        ROLLBACK;
  END pc_altera_horario_gps;
  
  -- Rotina para alterar os horarios de DEVOLUCOES
  PROCEDURE pc_altera_horario_devolucao(pr_cdcooper  IN INTEGER      --> Codigo da Cooperativa (zero para todas)
                                       ,pr_hrdiuatu  IN VARCHAR2     --> Atualizar Horario DEVOLUCAO DIURNA "S/N"
                                       ,pr_hrdiuini  IN VARCHAR2     --> Horario DEVOLUCAO DIURNA - Inicial
                                       ,pr_hrdiufim  IN VARCHAR2     --> Horario DEVOLUCAO DIURNA - Final
                                       ,pr_hrnotatu  IN VARCHAR2     --> Atualizar Horario DEVOLUCAO NOTURNA "S/N"
                                       ,pr_hrnotini  IN VARCHAR2     --> Horario DEVOLUCAO NOTURNA - Inicial
                                       ,pr_hrnotfim  IN VARCHAR2     --> Horario DEVOLUCAO NOTURNA - Final
                                       ,pr_nmdcampo OUT VARCHAR2     --> Nome do campo com erro
                                       ,pr_cdcritic OUT PLS_INTEGER  --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica

    /* .............................................................................
    Programa: pc_altera_horario_devolucao
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 20/04/2016                        Ultima atualizacao: 01/06/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para alterar os horarios de Devolucoes de Cheque
                Horario de devolucao de cheque, baseado na TAB055

    Alteracoes: 01/06/2016 - Adicionado UPPER na leitura da craptab, para que seja utilizado 
                             o indice na pesquisa (Douglas - Chamado 454248)
                             
                26/06/2017 - Retiradas validações VLB. PRJ367 (Lombardi)
    ............................................................................. */
    -- Parametros de horarios DEVOLUCAO de Cheque
    CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT tab.cdcooper
            ,tab.nmsistem
            ,tab.tptabela
            ,tab.cdempres
            ,tab.cdacesso
            ,tab.tpregist
            ,tab.dstextab 
        FROM craptab tab
       WHERE ((tab.cdcooper > 0 AND pr_cdcooper = 0) OR tab.cdcooper = pr_cdcooper)
         AND tab.cdcooper <> 3 -- nao altera da CECRED
         AND UPPER(tab.nmsistem) = UPPER('CRED')
         AND UPPER(tab.tptabela) = UPPER('GENERI')
         AND tab.cdempres = 00
         AND UPPER(tab.cdacesso) = UPPER('HRTRDEVOLU')
         AND tab.tpregist = 0;

      -- Dados craptab
      vr_dstextab craptab.dstextab%TYPE;
      
      vr_hrdiuini VARCHAR2(10); -- DEVOLUCAO DIURNA - Inicial
      vr_hrdiufim VARCHAR2(10); -- DEVOLUCAO DIURNA - Final
      vr_hrnotini VARCHAR2(10); -- DEVOLUCAO NOTURNA - Inicial
      vr_hrnotfim VARCHAR2(10); -- DEVOLUCAO NOTURNA - Final
      
      -- Erros
      vr_exc_erro EXCEPTION;
      vr_exit     EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
    
    BEGIN

      -- Verificar se atualiza o horario das devolucoes
      IF pr_hrdiuatu <> 'S' AND pr_hrnotatu <> 'S' THEN
        -- nao executa nada
        RAISE vr_exit;
      END IF;
      
      -- Converter a de DEVOLUCAO DIURNA inicial
      BEGIN
        vr_hrdiuini := TO_CHAR(TO_DATE(pr_hrdiuini,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario DEVOLUCAO DIURNA - Inicial invalido (' || pr_hrdiuini || ')';
          pr_nmdcampo := 'hrdiuini';
          RAISE vr_exc_erro;
      END;  

      -- Converter a de DEVOLUCAO DIURNA final
      BEGIN
        vr_hrdiufim := TO_CHAR(TO_DATE(pr_hrdiufim,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario DEVOLUCAO DIURNA - Final invalido (' || pr_hrdiufim || ')';
          pr_nmdcampo := 'hrdiufim';
          RAISE vr_exc_erro;
      END;  

      -- Converter a de DEVOLUCAO NOTURNA inicial
      BEGIN
        vr_hrnotini := TO_CHAR(TO_DATE(pr_hrnotini,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario DEVOLUCAO NOTURNA - Inicial invalido (' || pr_hrnotini || ')';
          pr_nmdcampo := 'hrnotini';
          RAISE vr_exc_erro;
      END;  

      -- Converter a de DEVOLUCAO NOTURNA final
      BEGIN
        vr_hrnotfim := TO_CHAR(TO_DATE(pr_hrnotfim,'HH24:MI'),'SSSSS');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Horario DEVOLUCAO NOTURNA - Final invalido (' || pr_hrnotfim || ')';
          pr_nmdcampo := 'hrnotfim';
          RAISE vr_exc_erro;
      END;  

      -- Percorrer todas as devolucoes
      FOR rw IN cr_craptab (pr_cdcooper => pr_cdcooper) LOOP
        -- Inicializa a novo valor
        vr_dstextab := '';
          
        -- Verificar se atualiza Horario DEVOLUCAO DIURNO
        IF pr_hrdiuatu = 'S' THEN
          vr_dstextab := vr_dstextab ||
                         vr_hrdiuini || ';' ||
                         vr_hrdiufim || ';';
        ELSE
          -- Se nao atualizar, mantem os valores originais
          vr_dstextab := vr_dstextab ||
                         GENE0002.fn_busca_entrada(3,rw.dstextab,';') || ';' || -- Hora Inicio - Devolucao Diurno
                         GENE0002.fn_busca_entrada(4,rw.dstextab,';') || ';';   -- Hora Fim - Devolucao Diurno
        END IF;

        -- Verificar se atualiza Horario DEVOLUCAO NOTURNO
        IF pr_hrnotatu = 'S' THEN
          vr_dstextab := vr_dstextab ||
                         vr_hrnotini || ';' ||
                         vr_hrnotfim || ';';
        ELSE
          -- Se nao atualizar, mantem os valores originais
          vr_dstextab := vr_dstextab ||
                         GENE0002.fn_busca_entrada(5,rw.dstextab,';') || ';' || -- Hora Inicio - Devolucao Noturno
                         GENE0002.fn_busca_entrada(6,rw.dstextab,';') || ';';   -- Hora Fim - Devolucao Noturno
        END IF;

        -- Atualizar a informacao
        UPDATE craptab tab
           SET tab.dstextab = vr_dstextab
         WHERE tab.cdcooper = rw.cdcooper
           AND UPPER(tab.nmsistem) = UPPER(rw.nmsistem)
           AND UPPER(tab.tptabela) = UPPER(rw.tptabela)
           AND tab.cdempres = rw.cdempres
           AND UPPER(tab.cdacesso) = UPPER(rw.cdacesso)
           AND tab.tpregist = rw.tpregist;
        
      END LOOP;
      
    EXCEPTION
      WHEN vr_exit THEN
        -- Nao executa nada, apenas controla saida sem execucao 
        NULL;
      
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PARHPG.pc_altera_horario_devolucao): ' || SQLERRM;
        ROLLBACK;
  END pc_altera_horario_devolucao;

  -- Rotina para alterar os horarios de pagamentos/estornos das cooperativas
  PROCEDURE pc_altera_horario_parhpg(pr_cddopcao  IN VARCHAR2           --> Opcao
                                    ,pr_cdcooper  IN INTEGER            --> Codigo da Cooperativa (zero para todas)
                                    ,pr_hrsicatu  IN VARCHAR2           --> Atualizar Horario Pagamento SICREDI "S/N"
                                    ,pr_hrsicini  IN VARCHAR2           --> Horario Pagamento SICREDI - Inicial
                                    ,pr_hrsicfim  IN VARCHAR2           --> Horario Pagamento SICREDI - Final
                                    ,pr_hrtitatu  IN VARCHAR2           --> Atualizar Horario Pagamento TITULOS/FATURAS "S/N"
                                    ,pr_hrtitini  IN VARCHAR2           --> Horario Pagamento TITULOS/FATURAS - Inicial
                                    ,pr_hrtitfim  IN VARCHAR2           --> Horario Pagamento TITULOS/FATURAS - Final
                                    ,pr_hrnetatu  IN VARCHAR2           --> Atualizar Horario Pagamento INTERNET/MOBILE "S/N"
                                    ,pr_hrnetini  IN VARCHAR2           --> Horario Pagamento INTERNET/MOBILE - Inicial
                                    ,pr_hrnetfim  IN VARCHAR2           --> Horario Pagamento INTERNET/MOBILE - Final
                                    ,pr_hrtaaatu  IN VARCHAR2           --> Atualizar Horario Pagamento TAA "S/N"
                                    ,pr_hrtaaini  IN VARCHAR2           --> Horario Pagamento TAA - Inicial
                                    ,pr_hrtaafim  IN VARCHAR2           --> Horario Pagamento TAA - Final
                                    ,pr_hrgpsatu  IN VARCHAR2           --> Atualizar Horario Pagamento GPS "S/N"
                                    ,pr_hrgpsini  IN VARCHAR2           --> Horario Pagamento GPS - Inicial
                                    ,pr_hrgpsfim  IN VARCHAR2           --> Horario Pagamento GPS - Final
                                    ,pr_hrsiccau  IN VARCHAR2           --> Atualizar Horario Cancelamento Pagamento SICREDI "S/N"
                                    ,pr_hrsiccan  IN VARCHAR2           --> Horario Cancelamento Pagamento SICREDI
                                    ,pr_hrtitcau  IN VARCHAR2           --> Atualizar Horario Cancelamento Pagamento TITULOS/FATURAS "S/N"
                                    ,pr_hrtitcan  IN VARCHAR2           --> Horario Cancelamento Pagamento TITULOS/FATURAS
                                    ,pr_hrnetcau  IN VARCHAR2           --> Atualizar Horario Cancelamento Pagamento INTERNET/MOBILE "S/N"
                                    ,pr_hrnetcan  IN VARCHAR2           --> Horario Cancelamento Pagamento INTERNET/MOBILE
                                    ,pr_hrtaacau  IN VARCHAR2           --> Atualizar Horario Cancelamento Pagamento TAA "S/N"
                                    ,pr_hrtaacan  IN VARCHAR2           --> Horario Cancelamento Pagamento TAA
                                    ,pr_hrdiuatu  IN VARCHAR2           --> Atualizar Horario DEVOLUCAO DIURNA "S/N"
                                    ,pr_hrdiuini  IN VARCHAR2           --> Horario DEVOLUCAO DIURNA - Inicial
                                    ,pr_hrdiufim  IN VARCHAR2           --> Horario DEVOLUCAO DIURNA - Final
                                    ,pr_hrnotatu  IN VARCHAR2           --> Atualizar Horario DEVOLUCAO NOTURNA "S/N"
                                    ,pr_hrnotini  IN VARCHAR2           --> Horario DEVOLUCAO NOTURNA - Inicial
                                    ,pr_hrnotfim  IN VARCHAR2           --> Horario DEVOLUCAO NOTURNA - Final
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo

    /* .............................................................................
    Programa: pc_altera_horario_parhpg
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 18/04/2016                        Ultima atualizacao:   /  /

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para alterar os horarios de pagamento da cooperativa selecionada
                Quando a cooperativa "0 - TODAS" for selecionada, alterar os horarios de todas as cooperativas

    Alteracoes:            
    
                24/11/2016 - Alteração para que o fonte realize a avaliação do departamento
                             pelo campo CDDEPART ao invés do DSDEPART. (Renato Darosci - Supero)
                               
                26/06/2017 - Retiradas validações VLB. PRJ367 (Lombardi)                               
    ............................................................................. */
      -- CURSORES -- 
      -- Buscar informacoes da cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%rowtype;
      
      -- Buscar informacoes do operador
      CURSOR cr_crapope (pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_cdoperad IN crapope.cdoperad%TYPE ) IS
        SELECT ope.cddepart
          FROM crapope ope
         WHERE ope.cdcooper = pr_cdcooper  
           AND ope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%rowtype;
    
      -- VARIAVEIS --
      -- Erros
      vr_exc_erro EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
    
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      -- dados para log
      vr_dscooper VARCHAR2(200);
    
    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PARHPG'
                                ,pr_action => null);
                                
      -- verificar se foi selecionado alguma cooperativa
      IF pr_cdcooper  = 0 THEN
        -- Mensagem de log para todas as cooperativas
        vr_dscooper := ' de TODAS as cooperativas.';
      ELSE
        -- Buscar informacoes do operador
        OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        
        -- caso nao encontrar o operador
        IF cr_crapcop%FOUND THEN 
          -- Fecha Cursor
          CLOSE cr_crapcop;
          -- Mensagem de log para a cooperativa selecionada
          vr_dscooper := ' da cooperativa ' || rw_crapcop.nmrescop;
        ELSE
          -- Se a cooperativa selecionada nao existir erro
          CLOSE cr_crapcop;
          vr_cdcritic:= 651;
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          pr_nmdcampo:= 'cdcooper';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
                                
      /* Extrai os dados */
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro                      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Buscar informacoes do operador
      OPEN cr_crapope (pr_cdcooper => vr_cdcooper,
                       pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      
      -- caso nao encontrar o operador
      IF cr_crapope%NOTFOUND THEN
        CLOSE cr_crapope;
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel encontrar o operador.';
        -- gerar critica e retornar ao programa chamador
        RAISE vr_exc_erro;
      ELSE 
        -- Fecha Cursor
        CLOSE cr_crapope;
      END IF;
    
      -- validar departamento, apenas TI e COMPE podem alterar os dados
      IF rw_crapope.cddepart NOT IN (4,20) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Voce nao tem permissao para realizar esta acao.';
        -- gerar critica e retornar ao programa chamador
        RAISE vr_exc_erro;      
      END IF;
    
      -- Atualizar os horarios de pagamento e estorno SICREDI
      pc_altera_horario_sicredi(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa (zero para todas)
                               ,pr_hrsicatu => pr_hrsicatu   --> Atualizar Horario Pagamento SICREDI "S/N"
                               ,pr_hrsicini => pr_hrsicini   --> Horario Pagamento SICREDI - Inicial
                               ,pr_hrsicfim => pr_hrsicfim   --> Horario Pagamento SICREDI - Final
                               ,pr_hrsiccau => pr_hrsiccau   --> Atualizar Horario Cancelamento Pagamento SICREDI "S/N"
                               ,pr_hrsiccan => pr_hrsiccan   --> Horario Cancelamento Pagamento SICREDI
                               ,pr_nmdcampo => pr_nmdcampo   --> Nome do campo com erro
                               ,pr_cdcritic => vr_cdcritic   --> Codigo da critica
                               ,pr_dscritic => vr_dscritic); --> Descricao da critica

      -- Verificar se ocorreu criticas durante a atualizacao de horarios do SICREDI
      IF NVL(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        -- Para o processo
        RAISE vr_exc_erro;   
      END IF; 
      
      -- Atualizar os horarios de pagamento e estorno TITULOS/FATURAS
      pc_altera_horario_titulos(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa (zero para todas)
                               ,pr_hrtitatu => pr_hrtitatu   --> Atualizar Horario Pagamento TITULOS/FATURAS "S/N"
                               ,pr_hrtitini => pr_hrtitini   --> Horario Pagamento TITULOS/FATURAS - Inicial
                               ,pr_hrtitfim => pr_hrtitfim   --> Horario Pagamento TITULOS/FATURAS - Final
                               ,pr_hrtitcau => pr_hrtitcau   --> Atualizar Horario Cancelamento Pagamento TITULOS/FATURAS "S/N"
                               ,pr_hrtitcan => pr_hrtitcan   --> Horario Cancelamento Pagamento TITULOS/FATURAS
                               ,pr_nmdcampo => pr_nmdcampo   --> Nome do campo com erro
                               ,pr_cdcritic => vr_cdcritic   --> Codigo da critica
                               ,pr_dscritic => vr_dscritic); --> Descricao da critica

      -- Verificar se ocorreu criticas durante a atualizacao de horarios do TITULOS/FATURAS
      IF NVL(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        -- Para o processo
        RAISE vr_exc_erro;   
      END IF; 

      -- Atualizar os horarios de pagamento e estorno INTERNET/MOBILE
      pc_altera_horario_internet(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa (zero para todas)
                                ,pr_hrnetatu => pr_hrnetatu   --> Atualizar Horario Pagamento INTERNET/MOBILE "S/N"
                                ,pr_hrnetini => pr_hrnetini   --> Horario Pagamento INTERNET/MOBILE - Inicial
                                ,pr_hrnetfim => pr_hrnetfim   --> Horario Pagamento INTERNET/MOBILE - Final
                                ,pr_hrnetcau => pr_hrnetcau   --> Atualizar Horario Cancelamento Pagamento INTERNET/MOBILE "S/N"
                                ,pr_hrnetcan => pr_hrnetcan   --> Horario Cancelamento Pagamento INTERNET/MOBILE
                                ,pr_nmdcampo => pr_nmdcampo   --> Nome do campo com erro
                                ,pr_cdcritic => vr_cdcritic   --> Codigo da critica
                                ,pr_dscritic => vr_dscritic); --> Descricao da critica

      -- Verificar se ocorreu criticas durante a atualizacao de horarios do INTERNET/MOBILE
      IF NVL(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        -- Para o processo
        RAISE vr_exc_erro;   
      END IF; 

      -- Atualizar os horarios de pagamento e estorno TAA
      pc_altera_horario_taa(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa (zero para todas)
                           ,pr_hrtaaatu => pr_hrtaaatu   --> Atualizar Horario Pagamento TAA "S/N"
                           ,pr_hrtaaini => pr_hrtaaini   --> Horario Pagamento TAA - Inicial
                           ,pr_hrtaafim => pr_hrtaafim   --> Horario Pagamento TAA - Final
                           ,pr_hrtaacau => pr_hrtaacau   --> Atualizar Horario Cancelamento Pagamento TAA "S/N"
                           ,pr_hrtaacan => pr_hrtaacan   --> Horario Cancelamento Pagamento TAA
                           ,pr_nmdcampo => pr_nmdcampo   --> Nome do campo com erro
                           ,pr_cdcritic => vr_cdcritic   --> Codigo da critica
                           ,pr_dscritic => vr_dscritic); --> Descricao da critica

      -- Verificar se ocorreu criticas durante a atualizacao de horarios do TAA
      IF NVL(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        -- Para o processo
        RAISE vr_exc_erro;   
      END IF; 

      -- Atualizar os horarios de pagamento e estorno GPS
      pc_altera_horario_gps(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa (zero para todas)
                           ,pr_hrgpsatu => pr_hrgpsatu   --> Atualizar Horario Pagamento GPS "S/N"
                           ,pr_hrgpsini => pr_hrgpsini   --> Horario Pagamento GPS - Inicial
                           ,pr_hrgpsfim => pr_hrgpsfim   --> Horario Pagamento GPS - Final
                           ,pr_nmdcampo => pr_nmdcampo   --> Nome do campo com erro
                           ,pr_cdcritic => vr_cdcritic   --> Codigo da critica
                           ,pr_dscritic => vr_dscritic); --> Descricao da critica

      -- Verificar se ocorreu criticas durante a atualizacao de horarios do GPS
      IF NVL(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        -- Para o processo
        RAISE vr_exc_erro;   
      END IF; 

      -- Atualizar os horarios de DEVOLUCAO de cheques
      pc_altera_horario_devolucao(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa (zero para todas)
                                 ,pr_hrdiuatu => pr_hrdiuatu   --> Atualizar Horario DEVOLUCAO DIURNA "S/N"
                                 ,pr_hrdiuini => pr_hrdiuini   --> Horario DEVOLUCAO DIURNA - Inicial
                                 ,pr_hrdiufim => pr_hrdiufim   --> Horario DEVOLUCAO DIURNA - Final
                                 ,pr_hrnotatu => pr_hrnotatu   --> Atualizar Horario DEVOLUCAO NOTURNA "S/N"
                                 ,pr_hrnotini => pr_hrnotini   --> Horario DEVOLUCAO NOTURNA - Inicial
                                 ,pr_hrnotfim => pr_hrnotfim   --> Horario DEVOLUCAO NOTURNA - Final
                                 ,pr_nmdcampo => pr_nmdcampo   --> Nome do campo com erro
                                 ,pr_cdcritic => vr_cdcritic   --> Codigo da critica
                                 ,pr_dscritic => vr_dscritic); --> Descricao da critica

      -- Verificar se ocorreu criticas durante a atualizacao de horarios de DEVOLUCAO
      IF NVL(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        -- Para o processo
        RAISE vr_exc_erro;   
      END IF; 

      -- Alterou Horario de Pagamento SICREDI
      IF pr_hrsicatu = 'S' THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'parhpg.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || vr_cdoperad ||
                                                    ' - Atualizou o Horario de Pagamentos Faturas SICREDI para:' ||
                                                    ' Inicio ' || pr_hrsicini || ' e Fim ' || pr_hrsicfim ||
                                                    ' para todos os PA''s' || vr_dscooper);
      END IF;

      -- Alterou Horario de Pagamento TITULOS/FATURAS
      IF pr_hrtitatu = 'S' THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'parhpg.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || vr_cdoperad ||
                                                    ' - Atualizou o Horario de Pagamentos Titulos/Faturas para:' ||
                                                    ' Inicio ' || pr_hrtitini || ' e Fim ' || pr_hrtitfim ||
                                                    ' para todos os PA''s' || vr_dscooper);
      END IF;

      -- Alterou Horario de Pagamento INTERNET/MOBILE
      IF pr_hrnetatu = 'S' THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'parhpg.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || vr_cdoperad ||
                                                    ' - Atualizou o Horario de Pagamentos Titulos/Faturas para:' ||
                                                    ' Inicio ' || pr_hrnetini || ' e Fim ' || pr_hrnetfim ||
                                                    ' para o PA 90 (Internet/Mobile)' || vr_dscooper);
      END IF;

      -- Alterou Horario de Pagamento TAA
      IF pr_hrtaaatu = 'S' THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'parhpg.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || vr_cdoperad ||
                                                    ' - Atualizou o Horario de Pagamentos Titulos/Faturas para:' ||
                                                    ' Inicio ' || pr_hrtaaini || ' e Fim ' || pr_hrtaafim ||
                                                    ' para o PA 91 (TAA)' || vr_dscooper);
      END IF;

      -- Alterou Horario de Pagamento GPS
      IF pr_hrgpsatu = 'S' THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'parhpg.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || vr_cdoperad ||
                                                    ' - Atualizou o Horario Pagamento GPS para:' ||
                                                    ' Inicio ' || pr_hrgpsini || ' e Fim ' || pr_hrgpsfim ||
                                                    vr_dscooper);
      END IF;

      -- Alterou Horario de Cancelamento Pagamento SICREDI
      IF pr_hrsiccau = 'S' THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'parhpg.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || vr_cdoperad ||
                                                    ' - Atualizou o Cancelamento pgto SICREDI para:' ||
                                                    pr_hrsiccan || 
                                                    ' para todos os PA''s' || vr_dscooper);
      END IF;

      -- Alterou Horario de Cancelamento Pagamento TITULOS/FATURAS
      IF pr_hrtitcau = 'S' THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'parhpg.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || vr_cdoperad ||
                                                    ' - Atualizou o Cancelamento de pagamentos para:' ||
                                                    pr_hrtitcan || 
                                                    ' para todos os PA''s' || vr_dscooper);
      END IF;

      -- Alterou Horario de Cancelamento Pagamento INTERNET/MOBILE
      IF pr_hrnetcau = 'S' THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'parhpg.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || vr_cdoperad ||
                                                    ' - Atualizou o Cancelamento de pagamentos para:' ||
                                                    pr_hrnetcan || 
                                                    ' para o PA 90 (Internet/Mobile)' || vr_dscooper);
      END IF;

      -- Alterou Horario de Cancelamento Pagamento TAA
      IF pr_hrtaacau = 'S' THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'parhpg.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || vr_cdoperad ||
                                                    ' - Atualizou o Cancelamento de pagamentos para:' ||
                                                    pr_hrtaacan || 
                                                    ' para o PA 91 (TAA)' || vr_dscooper);
      END IF;

      -- Alterou Horario de DEVOLUCAO DIURNA
      IF pr_hrdiuatu = 'S' THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'parhpg.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || vr_cdoperad ||
                                                    ' - Atualizou o Horario de DEVOLUCAO de Cheque DIURNA para:' ||
                                                    ' Inicio ' || pr_hrdiuini || ' e Fim ' || pr_hrdiufim ||
                                                    vr_dscooper);
      END IF;

      -- Alterou Horario de DEVOLUCAO NOTURNA
      IF pr_hrnotatu = 'S' THEN
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'parhpg.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || vr_cdoperad ||
                                                    ' - Atualizou o Horario de DEVOLUCAO de Cheque NOTURNA para:' ||
                                                    ' Inicio ' || pr_hrnotini || ' e Fim ' || pr_hrnotfim ||
                                                    vr_dscooper);
      END IF;
      
      -- Se chegou ao final
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_PARHPG.pc_altera_horario_parhpg): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_altera_horario_parhpg;

END TELA_PARHPG;
/
