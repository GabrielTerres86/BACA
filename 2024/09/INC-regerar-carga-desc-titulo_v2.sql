declare

  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);


PROCEDURE gerarCargaDescontoTitulo(pr_cdcooper      IN crapris.cdcooper%TYPE
                                                                  ,pr_idcarga       IN INTEGER
                                                                  ,pr_idprglog      IN NUMBER                  --> identificador do log
                                                                  ,pr_dtrefere      IN crapdat.dtmvtolt%TYPE  --> Data de referencia
                                                                  ,pr_dtultdia      IN crapdat.dtultdia%TYPE  --> Data de referencia
                                                                  ,pr_cdcritic     OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                                                  ,pr_dscritic     OUT VARCHAR2) IS           --> Descricao da Critica
/* ............................................................................
   
   Autor      : Darlei Zillmer
   Data       : 04/04/2022
   Dominio    : Gestão de Risco
   Subdominio : Central de risco
   Objetivo   : Gerar carga das operações de desconto de cheque
   Alteracoes :
  
  ............................................................................ */
  
  ---> Variaveis <---
  vr_cdprograma VARCHAR2(25) := 'gerarCargaDescontoTitulo';
  vr_dtinproc   CONSTANT DATE         := SYSDATE;
  vr_dscomple   VARCHAR2(2000);
  vr_idprglog   NUMBER := pr_idprglog;
  
  vr_exc_erro   EXCEPTION;
  vr_cdcritic   NUMBER;
  vr_dscritic   VARCHAR2(4000);
  
  ---> Variaveis de Negocio <---
  vr_tab_oper   gestaoderisco.tiposDadosRiscos.typ_tab_central_opera;
  vr_tab_gara   gestaoderisco.tiposDadosRiscos.typ_tab_oper_garant;
  vr_tab_venc   gestaoderisco.tiposDadosRiscos.typ_tab_oper_vencim;
  vr_tab_aval   gestaoderisco.tiposDadosRiscos.typ_tab_ass_aval;
  vr_tab_info   gestaoderisco.tiposDadosRiscos.typ_tab_info_adicional;
  vr_tab_limi   gestaoderisco.tiposDadosRiscos.typ_tab_oper_limite;
  
  -- tabela auxiliar
  vr_tab_venc_aux   gestaoderisco.tiposDadosRiscos.typ_tab_aux_vencim;
  vr_tab_vri_acordo GESTAODERISCO.tiposDadosRiscos.typ_tab_crapvri;

  -- Suporte para operacoes de acordo
  vr_idx_venc   VARCHAR2(25);
  vr_idx_cont   PLS_INTEGER;
  vr_idx_desconto   VARCHAR2(25);
  vr_idx_vri        VARCHAR2(30);
  
  vr_ctacosif   gestaoderisco.tbrisco_carga_operacao.nrctacos%TYPE;
  vr_dsorgrec   gestaoderisco.tbrisco_carga_operacao.dsorgrec%TYPE;
  vr_cdmodali   INTEGER;  
  vr_nrtaxidx   gestaoderisco.tbrisco_carga_operacao.nrtaxidx%TYPE;
  vr_nrperidx   gestaoderisco.tbrisco_carga_operacao.nrperidx%TYPE;
  vr_nrvarcam   gestaoderisco.tbrisco_carga_operacao.nrvarcam%TYPE;
  vr_cepconce   gestaoderisco.tbrisco_carga_operacao.nrcepcon%TYPE;
  vr_nrtaxeft   gestaoderisco.tbrisco_carga_operacao.nrtaxeft%TYPE;
  vr_cdnatope   gestaoderisco.tbrisco_carga_operacao.cdnatope%TYPE;
  vr_dscaresp   gestaoderisco.tbrisco_carga_operacao.dscaresp%TYPE;
  vr_vlctrato   gestaoderisco.tbrisco_carga_operacao.vlcontrato%TYPE;
  vr_dtinivig   gestaoderisco.tbrisco_operacao_limite.dtfimvig%TYPE;
  vr_idoperacao gestaoderisco.tbrisco_carga_operacao.idcarga_operacao%TYPE;
  vr_cdvencto   gestaoderisco.tbrisco_operacao_vencimento.cdvencto%TYPE;
  vr_nrctaav1   craplim.nrctaav1%TYPE;
  vr_nrctaav2   craplim.nrctaav2%TYPE;
  vr_vljuros_suspenso  gestaoderisco.tbrisco_carga_operacao.vljuros_suspenso%TYPE;
  
  vr_cardbtitpf NUMBER;
  vr_cardbtitpj NUMBER;
  vr_cardbtit   NUMBER;
  vr_dstextab   craptab.dstextab%TYPE;
  vr_vlmratit   NUMBER;
  vr_vlsldtit   NUMBER;
  vr_valormora  NUMBER;
  vr_txdiaria   NUMBER; -- Taxa diária de juros de mora
  vr_dtmvtolt   crapdat.dtmvtolt%TYPE;
  vr_vlsrisco   NUMBER;
  vr_qtdiaatr   NUMBER;
  vr_vldjuros   NUMBER;
  vr_vldestit   NUMBER;
  vr_qtparcel   INTEGER; 
  vr_vlparcel   NUMBER;
  vr_vldivida   NUMBER;
  vr_vlprjbdt   NUMBER;
  vr_indocc     INTEGER;
  vr_vlprjano   NUMBER;
  vr_vlprjaan   NUMBER;
  vr_vlprjant   NUMBER;
  vr_dtmaxven   cecred.craptdb.dtvencto%TYPE;
  
  vr_tem_acordo_desc BOOLEAN;
  vr_qtdprazo        NUMBER;
  vr_tab_dstextab    gene0002.typ_split; 
  
  -- Valor da data parametro para verificar se calcula carencia
  vr_dt_param_carencia DATE;
  vr_dt_calc_carencia  crapprm.dsvlrprm%TYPE;
  vr_contados_log      NUMBER := 0;
  
  vr_reestrut   NUMBER := 0;
  vr_dtatvprobl VARCHAR2(100);
  vr_atvprobl   NUMBER := 0;
  vr_vlprxpar   crapris.vlprxpar%TYPE;  
  vr_dtprxpar   crapris.dtprxpar%TYPE;
  vr_risco_aux  PLS_INTEGER;            --> Nível de risco auxiliar 2
  
  ---> Cursores <---
  
  CURSOR cr_crapcob(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_dtrefere IN crapdat.dtmvtolt%TYPE) IS
    SELECT b.nrborder
          ,b.nrctrlim
          ,c.flgregis
          ,b.dtlibbdt
          ,t.nrdconta
          ,t.nrtitulo
          ,t.dtvencto
          ,t.vlliquid
          ,t.insittit
          ,t.dtdpagto
          ,t.cdbandoc
          ,t.nrdctabb
          ,t.nrcnvcob
          ,t.nrdocmto
          ,c.indpagto
          ,t.vljura60
          ,t.vltitulo
          ,t.vlsldtit
          ,b.flverbor
          ,t.vlmratit
          ,t.vlpagmra
          ,COUNT(1)      OVER (PARTITION BY b.nrborder,c.flgregis) qtd_max
          ,ROW_NUMBER () OVER (PARTITION BY b.nrborder,c.flgregis
                                   ORDER BY b.nrborder,c.flgregis) seq_atu
          ,CASE WHEN b.dtprejuz <= pr_dtrefere AND b.inprejuz = 1 THEN 1 ELSE 0 END inprejuz
          ,CASE WHEN b.dtprejuz <= pr_dtrefere AND b.inprejuz = 1 THEN b.dtprejuz ELSE NULL END dtprejuz
          ,t.vlsdprej AS vlsldatu -- Saldo atualizado
          ,a.inpessoa
          ,b.vltxmora
          ,t.dtultpag
          ,t.vlultmra
          ,(SELECT SUM(tdb.vltitulo)
              FROM craptdb tdb
             WHERE tdb.cdcooper = b.cdcooper
               AND tdb.nrdconta = b.nrdconta
               AND tdb.nrborder = b.nrborder
               AND tdb.nrctrlim = b.nrctrlim ) vltotal_bordero
      FROM crapbdt b, craptdb t, crapcob c, crapass a
     WHERE b.cdcooper = t.cdcooper
       AND b.nrdconta = t.nrdconta
       AND b.nrborder = t.nrborder
       AND c.cdcooper = t.cdcooper
       AND c.cdbandoc = t.cdbandoc
       AND c.nrdctabb = t.nrdctabb
       AND c.nrcnvcob = t.nrcnvcob
       AND c.nrdconta = t.nrdconta
       AND c.nrdocmto = t.nrdocmto
       AND a.cdcooper = b.cdcooper
       AND a.nrdconta = b.nrdconta
       AND b.cdcooper = pr_cdcooper
       AND t.dtlibbdt IS NOT NULL
       AND b.dtlibbdt <= pr_dtrefere
       AND ((t.vlsldtit > 0 AND (b.inprejuz = 0 OR (b.dtprejuz > pr_dtrefere AND b.inprejuz = 1))) OR
            (t.vlsdprej > 0 AND (b.inprejuz = 1 AND b.dtprejuz <= pr_dtrefere))) 
      ORDER BY b.nrborder
              ,c.flgregis
              ,b.progress_recid;
  rw_crapcob cr_crapcob%ROWTYPE;
  
  -- Busca contrato de limite de crédito
  CURSOR cr_craplim_credito(pr_cdcooper IN crapass.cdcooper%TYPE    
                           ,pr_nrdconta IN crapass.nrdconta%TYPE
                           ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
    SELECT lim.dtinivig
          ,lim.cddlinha
          ,lim.qtdiavig
          ,lim.tpctrlim
          ,lim.cdcooper
          ,lim.nrdconta
          ,lim.nrctrlim
          ,lim.nrctaav1
          ,lim.nrctaav2
          ,lim.vllimite
     FROM  craplim lim
    WHERE lim.cdcooper = pr_cdcooper
      AND lim.nrdconta = pr_nrdconta
      AND lim.nrctrlim = pr_nrctrlim
      AND lim.tpctrlim = 3;  --> Desconto de Titulos
  rw_craplim_credito cr_craplim_credito%ROWTYPE;
  
  -- Sumarizar a restituição no desconto de titulo
  CURSOR cr_crapljt_rest(pr_cdcooper IN crapass.cdcooper%TYPE  
                        ,pr_nrdconta IN crapljt.nrdconta%TYPE
                        ,pr_nrborder IN crapljt.nrborder%TYPE
                        ,pr_dtmvtolt IN crapljt.dtmvtolt%TYPE
                        ,pr_dtrefere IN crapljt.dtrefere%TYPE
                        ,pr_cdbandoc IN crapljt.cdbandoc%TYPE
                        ,pr_nrdctabb IN crapljt.nrdctabb%TYPE
                        ,pr_nrcnvcob IN crapljt.nrcnvcob%TYPE
                        ,pr_nrdocmto IN crapljt.nrdocmto%TYPE) IS
    SELECT NVL(SUM(vlrestit),0)
      FROM crapljt
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrborder = pr_nrborder
       AND dtmvtolt = pr_dtmvtolt
       AND dtrefere > pr_dtrefere -- Posterior a passada
       AND cdbandoc = pr_cdbandoc
       AND nrdctabb = pr_nrdctabb
       AND nrcnvcob = pr_nrcnvcob
       AND nrdocmto = pr_nrdocmto;
  vr_vlrestit crapljt.vlrestit%TYPE;
  
  -- Sumarizar os juros e a restituição no desconto de titulo
  CURSOR cr_crapljt_soma(pr_nrdconta IN crapljt.nrdconta%TYPE
                        ,pr_nrborder IN crapljt.nrborder%TYPE
                        ,pr_dtmvtolt IN crapljt.dtmvtolt%TYPE
                        ,pr_dtrefere IN crapljt.dtrefere%TYPE
                        ,pr_cdbandoc IN crapljt.cdbandoc%TYPE
                        ,pr_nrdctabb IN crapljt.nrdctabb%TYPE
                        ,pr_nrcnvcob IN crapljt.nrcnvcob%TYPE
                        ,pr_nrdocmto IN crapljt.nrdocmto%TYPE) IS
    SELECT NVL(SUM(vldjuros),0) + NVL(SUM(vlrestit),0)
      FROM crapljt
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrborder = pr_nrborder
       AND dtmvtolt = pr_dtmvtolt
       AND dtrefere < pr_dtrefere -- Inferior a passada
       AND cdbandoc = pr_cdbandoc
       AND nrdctabb = pr_nrdctabb
       AND nrcnvcob = pr_nrcnvcob
       AND nrdocmto = pr_nrdocmto;
  
  -- Busca o saldo do prejuízo original dos títulos
  CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
    SELECT SUM(tdb.vlsdprej + (tdb.vlttjmpr - tdb.vljura60) - (tdb.vlpgjmpr - tdb.vlpgjm60)) AS vlprejtotal
      FROM crapbdt bdt
     INNER JOIN craptdb tdb ON tdb.cdcooper = bdt.cdcooper 
                           AND tdb.nrborder = bdt.nrborder
                           AND tdb.nrdconta = bdt.nrdconta
     WHERE tdb.insittit = 4
       AND bdt.inprejuz = 1
       AND bdt.flverbor = 1
       AND bdt.cdcooper = pr_cdcooper
       AND bdt.nrborder = pr_nrborder;
  rw_craptdb cr_craptdb%ROWTYPE;
  
  CURSOR cr_cobertura(pr_cdcooper IN tbgar_cobertura_operacao.cdcooper%TYPE) IS
    SELECT nvl(c.idcobertura, 0) idcobertura
          ,nvl(c.inaplicacao_propria, 0) inaplicacao_propria
          ,nvl(c.inpoupanca_propria, 0) inpoupanca_propria
          ,c.cdcooper
          ,c.nrdconta
          ,c.nrcontrato
          ,c.tpcontrato
      FROM tbgar_cobertura_operacao c
     WHERE c.cdcooper   = pr_cdcooper
       AND c.insituacao = 1
       AND c.tpcontrato = 2; -- desconto de titulo
  TYPE typ_cobertura_bulk IS TABLE OF cr_cobertura%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_cobertura_bulk typ_cobertura_bulk;
  vr_idx_cobertura VARCHAR2(30);
  
  -- Desconto em titulos
 CURSOR cr_juros_desconto_titulo(pr_cdcooper tbrisco_juros_desconto_titulo.cdcooper%TYPE
                                ,pr_dtrefere tbrisco_juros_desconto_titulo.dtrefere%TYPE) IS
  SELECT cdcooper, dtrefere, vljura60, nrdconta, nrborder
    FROM tbrisco_juros_desconto_titulo
   WHERE cdcooper = pr_cdcooper
     AND dtrefere = pr_dtrefere;
   
  TYPE typ_juros_desconto_titulo_bulk IS TABLE OF cr_juros_desconto_titulo%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_juros_desconto_titulo IS TABLE OF cr_juros_desconto_titulo%ROWTYPE INDEX BY VARCHAR2(25);
  vr_tab_juros_desconto_titulo_bulk typ_juros_desconto_titulo_bulk;
  vr_tab_juros_desconto_titulo typ_juros_desconto_titulo;
  vr_idx_juros_desconto_titulo VARCHAR2(25);
   
  CURSOR cr_crapldc(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT txjurmor, cddlinha, tpdescto
      FROM crapldc
     WHERE crapldc.cdcooper = pr_cdcooper;
  
  TYPE typ_crapldc_bulk IS TABLE OF cr_crapldc%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_crapldc IS TABLE OF cr_crapldc%ROWTYPE INDEX BY VARCHAR2(20);
  vr_tab_crapldc_bulk typ_crapldc_bulk;
  vr_tab_crapldc typ_crapldc;
  vr_idx_crapldc VARCHAR2(20);
BEGIN

  GESTAODERISCO.gravaLogProcCentral(pr_cdcooper     => pr_cdcooper
                                   ,pr_cdprograma   => vr_cdprograma
                                   ,pr_dscritic     => 'Inicio da execucao: ' || vr_cdprograma
                                   ,pr_ind_tipo_log => 1);

  ----------> Inicio <------------
  
  vr_cdmodali := 301;
  
  -- Busca na tabela de parametros a data
  vr_dt_calc_carencia := gene0001.fn_param_sistema(pr_cdcooper => 0
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_cdacesso => 'DT_CALC_CARENCIA');
  -- Caso não ache o parametro ou a data do titulo seja menor que a data parametro, não se aplica os dias de carência.
  IF vr_dt_calc_carencia IS NULL THEN
    vr_cardbtitpj := 0;
    vr_cardbtitpf := 0;
  ELSE
    vr_dt_param_carencia := to_date(vr_dt_calc_carencia,'DD/MM/RRRR');
    --> Buscar valores do parametro
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'     
                                             ,pr_tptabela => 'USUARI'   
                                             ,pr_cdempres => 11         
                                             ,pr_cdacesso => 'LIMDESCTITCRPF' -- Cobrança Registrada - Pessoa Física
                                             ,pr_tpregist => 0);
    vr_tab_dstextab := gene0002.fn_quebra_string(pr_string => vr_dstextab
                                                ,pr_delimit => ';');
    IF vr_tab_dstextab.count() > 0 THEN
      vr_cardbtitpf := vr_tab_dstextab(32);
    END IF;
    
    --> Buscar valores do parametro
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'     
                                             ,pr_tptabela => 'USUARI'   
                                             ,pr_cdempres => 11         
                                             ,pr_cdacesso => 'LIMDESCTITCRPJ' -- Cobrança Registrada - Pessoa Jurídica
                                             ,pr_tpregist => 0);

    vr_tab_dstextab := gene0002.fn_quebra_string(pr_string => vr_dstextab
                                                ,pr_delimit => ';');
    IF vr_tab_dstextab.count() > 0 THEN
      vr_cardbtitpj := vr_tab_dstextab(32);
    END IF;
  END IF;
  
  gravarTempoCentral(pr_cdcooper => pr_cdcooper
                    ,pr_cdagenci => 0
                    ,pr_dsmensag => vr_cdprograma || ' - PASSO 01'
                    ,pr_dtinicio => SYSDATE);
                    
  vr_tab_cobertura_bulk.DELETE;
  --> Carregar temptable dos saldos das renegociações facilitadas
  OPEN cr_cobertura(pr_cdcooper => pr_cdcooper);
  FETCH cr_cobertura BULK COLLECT INTO vr_tab_cobertura_bulk;
  CLOSE cr_cobertura;

  IF vr_tab_cobertura_bulk.count > 0 THEN
    FOR idx IN vr_tab_cobertura_bulk.first .. vr_tab_cobertura_bulk.last LOOP
      vr_idx_cobertura := lpad(vr_tab_cobertura_bulk(idx).cdcooper,   5, '0') ||
                          lpad(vr_tab_cobertura_bulk(idx).nrdconta,   10, '0') || 
                          lpad(vr_tab_cobertura_bulk(idx).nrcontrato, 10, '0') ||
                          lpad(vr_tab_cobertura_bulk(idx).tpcontrato, 5, '0');
      IF NOT GESTAODERISCO.tiposdadosriscos.tab_cobertura_ope.exists(vr_idx_cobertura) THEN
        GESTAODERISCO.tiposdadosriscos.tab_cobertura_ope(vr_idx_cobertura).idcobertura         := vr_tab_cobertura_bulk(idx).idcobertura;
        GESTAODERISCO.tiposdadosriscos.tab_cobertura_ope(vr_idx_cobertura).inaplicacao_propria := vr_tab_cobertura_bulk(idx).inaplicacao_propria;
        GESTAODERISCO.tiposdadosriscos.tab_cobertura_ope(vr_idx_cobertura).inpoupanca_propria  := vr_tab_cobertura_bulk(idx).inpoupanca_propria;
      END IF;
    END LOOP;
  END IF;
  vr_tab_cobertura_bulk.DELETE;
  
  vr_tab_crapldc_bulk.delete;
  OPEN cr_crapldc(pr_cdcooper => pr_cdcooper);
  FETCH cr_crapldc BULK COLLECT INTO vr_tab_crapldc_bulk;
  CLOSE cr_crapldc;
  
  IF vr_tab_crapldc_bulk.count > 0 THEN
    FOR idx IN vr_tab_crapldc_bulk.first..vr_tab_crapldc_bulk.last LOOP
      vr_idx_crapldc := lpad(vr_tab_crapldc_bulk(idx).cddlinha,10,'0')
                     || lpad(vr_tab_crapldc_bulk(idx).tpdescto,10,'0');
      vr_tab_crapldc(vr_idx_crapldc) := vr_tab_crapldc_bulk(idx);
    END LOOP;
  END IF;
  
  vr_tab_juros_desconto_titulo_bulk.delete;
  OPEN cr_juros_desconto_titulo(pr_cdcooper => pr_cdcooper, pr_dtrefere => pr_dtrefere);
  FETCH cr_juros_desconto_titulo BULK COLLECT INTO vr_tab_juros_desconto_titulo_bulk;
  CLOSE cr_juros_desconto_titulo;
  
  IF vr_tab_juros_desconto_titulo_bulk.count > 0 THEN
    FOR idx IN vr_tab_juros_desconto_titulo_bulk.first..vr_tab_juros_desconto_titulo_bulk.last LOOP
      vr_idx_juros_desconto_titulo := lpad(vr_tab_juros_desconto_titulo_bulk(idx).cdcooper,5,'0')
                                   || lpad(vr_tab_juros_desconto_titulo_bulk(idx).nrdconta,10,'0') 
                                   || lpad(vr_tab_juros_desconto_titulo_bulk(idx).nrborder,10,'0');
      vr_tab_juros_desconto_titulo(vr_idx_juros_desconto_titulo) := vr_tab_juros_desconto_titulo_bulk(idx);
    END LOOP;
  ELSE
    -- Se nao encontrar no dia de referencia, pode ser uma mensal no fim de semana
    vr_tab_juros_desconto_titulo_bulk.delete;
    OPEN cr_juros_desconto_titulo(pr_cdcooper => pr_cdcooper, pr_dtrefere => pr_dtultdia);
    FETCH cr_juros_desconto_titulo BULK COLLECT INTO vr_tab_juros_desconto_titulo_bulk;
    CLOSE cr_juros_desconto_titulo;
    
    IF vr_tab_juros_desconto_titulo_bulk.count > 0 THEN
      FOR idx IN vr_tab_juros_desconto_titulo_bulk.first..vr_tab_juros_desconto_titulo_bulk.last LOOP
        vr_idx_juros_desconto_titulo := lpad(vr_tab_juros_desconto_titulo_bulk(idx).cdcooper,5,'0')
                                     || lpad(vr_tab_juros_desconto_titulo_bulk(idx).nrdconta,10,'0') 
                                     || lpad(vr_tab_juros_desconto_titulo_bulk(idx).nrborder,10,'0');
        vr_tab_juros_desconto_titulo(vr_idx_juros_desconto_titulo) := vr_tab_juros_desconto_titulo_bulk(idx);
      END LOOP;
    END IF;
  END IF;

  IF nvl(GESTAODERISCO.tiposDadosRiscos.tab_atraso_acordo.count, 0) = 0 THEN
     GESTAODERISCO.obterAtrasoAcordo(pr_cdcooper  => pr_cdcooper
                                    ,pr_dtrefere  => pr_dtrefere
                                    ,pr_cdcritic  => vr_cdcritic
                                    ,pr_dscritic  => vr_dscritic);
  END IF;

  gravarTempoCentral(pr_cdcooper => pr_cdcooper
                    ,pr_cdagenci => 0
                    ,pr_dsmensag => vr_cdprograma || ' - PASSO 02'
                    ,pr_dtinicio => SYSDATE);

  -- Busca dos borderos
  FOR rw_crapcob IN cr_crapcob (pr_cdcooper => pr_cdcooper
                               ,pr_dtrefere => pr_dtrefere) LOOP

    IF rw_crapcob.seq_atu = 1 THEN
      -- Sequencia da operacao
      vr_idoperacao := GESTAODERISCO.obterSequenciaOperacao;
      vr_tab_venc_aux.delete;
      vr_tab_vri_acordo.delete;
      vr_nrctaav1 := NULL;
      vr_nrctaav2 := NULL;
      vr_dsorgrec := NULL;
      vr_nrtaxidx := NULL;
      vr_nrperidx := NULL;
      vr_nrvarcam := NULL;
      vr_cepconce := NULL;
      vr_nrtaxeft := NULL;
      vr_cdnatope := NULL;
      vr_dscaresp := NULL;
      vr_vlctrato := 0;
      vr_cardbtit := NULL;
      vr_dtinivig := rw_crapcob.dtlibbdt;
      vr_vlsrisco := 0;
      vr_vldestit := 0;
      vr_qtdiaatr := 0;
      vr_vlprjant := 0;
      vr_vlprjaan := 0;
      vr_vlprjano := 0;
      vr_dtmaxven := rw_crapcob.dtvencto;
      vr_ctacosif := NULL;
      vr_vlsldtit := 0;
      vr_vlprxpar := 0; 
      vr_dtprxpar := NULL;
    END IF;
    
    vr_tem_acordo_desc := FALSE;
    GESTAODERISCO.tiposdadosriscos.idx_acordos := lpad(pr_cdcooper,5,0) ||
                                                  lpad(rw_crapcob.nrdconta,10,0) ||
                                                  lpad(4,5,0)                    ||
                                                  lpad(rw_crapcob.nrborder,10,0) ||
                                                  lpad(rw_crapcob.nrtitulo,5,0);
    IF  GESTAODERISCO.tiposdadosriscos.tab_acordos.exists(GESTAODERISCO.tiposdadosriscos.idx_acordos) THEN
      IF GESTAODERISCO.tiposdadosriscos.tab_acordos(GESTAODERISCO.tiposdadosriscos.idx_acordos).cdorigem = 4 AND 
         GESTAODERISCO.tiposdadosriscos.tab_acordos(GESTAODERISCO.tiposdadosriscos.idx_acordos).nrtitulo = rw_crapcob.nrtitulo AND 
         rw_crapcob.inprejuz = 0 THEN
        vr_tem_acordo_desc := TRUE;
      END IF;
    END IF;
    
    IF NOT (rw_crapcob.insittit = 2 AND (rw_crapcob.indpagto IN(1,3,4) OR (rw_crapcob.indpagto = 0 AND rw_crapcob.cdbandoc = 085))) THEN
      -- Acumular no valor do risco o valor líquido do titulo
      IF rw_crapcob.flverbor = 1 THEN
        
        IF rw_crapcob.dtvencto <= vr_dt_param_carencia THEN
          vr_cardbtit := 0;
        ELSE
          IF rw_crapcob.inpessoa = 1 THEN
            vr_cardbtit := vr_cardbtitpf;
          ELSE
            vr_cardbtit := vr_cardbtitpj;
          END IF;
        END IF;
        
        -- Não calcular juros caso esteja na carência
        IF gene0005.fn_valida_dia_util(pr_cdcooper, rw_crapcob.dtvencto + vr_cardbtit) >= pr_dtrefere THEN
          vr_vlmratit := 0;
        ELSE
          
          -- Calculo da taxa de mora diaria
          vr_txdiaria :=  (POWER((rw_crapcob.vltxmora / 100) + 1,(1 / 30)) - 1);

          vr_vlsldtit := rw_crapcob.vlsldtit;

          vr_valormora  := 0;
          IF (vr_vlsldtit > 0) THEN
            -- Verifica se houve algum pagamento parcial do saldo. Não deve considerar o período de carência para data do ultimo pagamento
            vr_dtmvtolt := (rw_crapcob.dtvencto + vr_cardbtit);
            IF rw_crapcob.dtultpag IS NOT NULL AND rw_crapcob.vlultmra > 0 THEN -- houve algum pagamento do saldo parcial
              vr_dtmvtolt   := rw_crapcob.dtultpag;
              vr_valormora  := rw_crapcob.vlultmra;
            END IF;
            -- Contemplar o tempo de carencia para não calcular os juros daquele período
            vr_valormora  := vr_valormora + NVL(ROUND(vr_vlsldtit * (pr_dtrefere - vr_dtmvtolt) * vr_txdiaria,2),0);
          END IF;
          vr_vlmratit := vr_valormora;
        END IF;
        
        vr_vlsrisco := (rw_crapcob.vlliquid - (rw_crapcob.vltitulo - rw_crapcob.vlsldtit) + (nvl(vr_vlmratit,0) - rw_crapcob.vlpagmra) - nvl(rw_crapcob.vljura60,0));--pagamento do titulo parcial
      ELSE
        vr_vlsrisco := rw_crapcob.vlliquid - nvl(rw_crapcob.vljura60,0);
      END IF;

      IF rw_crapcob.dtvencto > pr_dtrefere THEN
         vr_dtprxpar := LEAST(rw_crapcob.dtvencto,NVL(vr_dtprxpar,rw_crapcob.dtvencto));
      END IF;

      -- Se foi pago antecipado ele soma os juros restituidos como risco
      -- tambem pois o titulo ainda eh considerado em risco para a contabilidade
      IF  rw_crapcob.insittit = 2
      AND rw_crapcob.dtdpagto = pr_dtrefere
      AND rw_crapcob.dtvencto > pr_dtrefere THEN
        -- nos testes nenhum insittit diferente de 4 veio listado, se nao existir log, esse bloco deve ser retirado
        CECRED.pc_log_programa(pr_dstiplog      => 'O'
                              ,pr_cdcooper      => 0
                              ,pr_tpocorrencia  => 4 -- Mensagem
                              ,pr_cdprograma    => 'GERACAO DE CARGA DE DESCONTO DE TITULOS'
                              ,pr_tpexecucao    => 0 -- Outro
                              ,pr_dsmensagem    => 'Acompanhamento gerarCargaDescontoTitulo para verificar execução'
                              ,pr_idprglog      => vr_idprglog);
        -- Sumarizar os juros no desconto do titulo
        vr_vlrestit := 0;
        OPEN cr_crapljt_rest(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_crapcob.nrdconta
                            ,pr_nrborder => rw_crapcob.nrborder
                            ,pr_dtmvtolt => rw_crapcob.dtlibbdt
                            ,pr_dtrefere => pr_dtultdia -- Ultimo dia mês corrente
                            ,pr_cdbandoc => rw_crapcob.cdbandoc
                            ,pr_nrdctabb => rw_crapcob.nrdctabb
                            ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                            ,pr_nrdocmto => rw_crapcob.nrdocmto);
        FETCH cr_crapljt_rest INTO vr_vlrestit;
        CLOSE cr_crapljt_rest;
        -- Acumular ao valor do risco os juros encontrados
        vr_vlsrisco := vr_vlsrisco + nvl(vr_vlrestit,0);
      END IF;
      -- Sumarizar os juros e valor de restituição nos lançamentos de juros de titulos
      vr_vldjuros := 0;
      OPEN cr_crapljt_soma(pr_nrdconta => rw_crapcob.nrdconta
                          ,pr_nrborder => rw_crapcob.nrborder
                          ,pr_dtmvtolt => rw_crapcob.dtlibbdt
                          ,pr_dtrefere => pr_dtultdia + 1  -- Ultimo dia mês corrente + 1
                          ,pr_cdbandoc => rw_crapcob.cdbandoc
                          ,pr_nrdctabb => rw_crapcob.nrdctabb
                          ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                          ,pr_nrdocmto => rw_crapcob.nrdocmto);
      FETCH cr_crapljt_soma INTO vr_vldjuros;
      CLOSE cr_crapljt_soma;
      -- Acumular ao valor do risco os juros encontrados
      vr_vlsrisco := vr_vlsrisco + nvl(vr_vldjuros,0);
      -- Acumular o valor do risco atual para a variavel específica de desconto de titulos
      vr_vldestit := vr_vldestit + vr_vlsrisco;
      
      IF rw_crapcob.dtvencto BETWEEN trunc(add_months(pr_dtrefere,1),'mm') AND 
         last_day(add_months(pr_dtrefere,1)) THEN
         vr_vlprxpar := vr_vlprxpar + vr_vlsrisco;
      END IF;
      
      IF vr_tem_acordo_desc THEN -- APENAS QUANDO TEM ACORDO NO TITULO
        vr_qtparcel   := greatest(GESTAODERISCO.tiposdadosriscos.tab_acordos(GESTAODERISCO.tiposdadosriscos.idx_acordos).qtParcelas,1);
        vr_vlparcel   := nvl(vr_vlsrisco,0) / greatest(nvl(vr_qtparcel,0),1);
        -- Descontar o valor atual do contrato do total da divida.
        -- Será totalizado com o total dos vencimentos, abaixo
        vr_vldestit := nvl(vr_vldestit,0) - nvl(vr_vlsrisco,0);
        
        GESTAODERISCO.gerarVencimentosAcordoTitulo(pr_cdcooper      => pr_cdcooper
                                                  ,pr_nrdconta      => rw_crapcob.nrdconta
                                                  ,pr_nrctremp      => GESTAODERISCO.tiposdadosriscos.tab_acordos(GESTAODERISCO.tiposdadosriscos.idx_acordos).nrcontrato
                                                  ,pr_nracordo      => GESTAODERISCO.tiposdadosriscos.tab_acordos(GESTAODERISCO.tiposdadosriscos.idx_acordos).nracordo
                                                  ,pr_dtmvtolt      => pr_dtrefere
                                                  ,pr_vlrParcela    => vr_vlparcel
                                                  ,pr_vlrParcelaJ60 => vr_vlparcel
                                                  ,pr_nrborder      => rw_crapcob.nrborder
                                                  ,pr_tab_crapvri   => vr_tab_vri_acordo
                                                  ,pr_vldivida      => vr_vldivida
                                                  ,pr_vlprxpar      => vr_vlprxpar
                                                  ,pr_dtprxpar      => vr_dtprxpar
                                                  ,pr_cdcritic      => vr_cdcritic
                                                  ,pr_dscritic      => vr_dscritic);
        -- Testar retorno de erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Gerar erro e roolback
          RAISE vr_exc_erro;
        END IF;  
        
        vr_vldestit := nvl(vr_vldestit,0) + nvl(vr_vldivida, 0);
        
        GESTAODERISCO.tiposDadosRiscos.idx_atraso_acordo := lpad(pr_cdcooper, 5, '0') ||
                                                            lpad(rw_crapcob.nrdconta, 10, '0') ||
                                                            lpad(GESTAODERISCO.tiposdadosriscos.tab_acordos(GESTAODERISCO.tiposdadosriscos.idx_acordos).nracordo, 10, '0');
         
         IF GESTAODERISCO.tiposDadosRiscos.tab_atraso_acordo.exists(GESTAODERISCO.tiposDadosRiscos.idx_atraso_acordo) THEN
            IF nvl(vr_qtdiaatr,0) < GESTAODERISCO.tiposDadosRiscos.tab_atraso_acordo(GESTAODERISCO.tiposDadosRiscos.idx_atraso_acordo).qtdiaatr THEN
              vr_qtdiaatr := GESTAODERISCO.tiposDadosRiscos.tab_atraso_acordo(GESTAODERISCO.tiposDadosRiscos.idx_atraso_acordo).qtdiaatr;
            END IF;
         END IF; 
        
        
      ELSE
      
        vr_qtdprazo := rw_crapcob.dtvencto - pr_dtrefere;
        
        IF vr_qtdprazo <= 0 THEN
          IF vr_qtdprazo = 0 THEN
            vr_qtdprazo := -1;
          END IF;
         
          -- Se for atraso 
          IF vr_qtdprazo < 0 AND 
             vr_qtdiaatr < abs(vr_qtdprazo) THEN             
            vr_qtdiaatr := abs(vr_qtdprazo);
            
            END IF;
          
          END IF;
        
        IF vr_vlsrisco > 0 AND rw_crapcob.inprejuz = 0 THEN
          
          -- 
          vr_cdvencto := GESTAODERISCO.calcularCodigoVencimento(pr_diasvenc => vr_qtdprazo
                                                               ,pr_qtdiapre => vr_qtdprazo -- Enviar a mesma informaçao
                                                               ,pr_flgempre => TRUE);
          vr_idx_venc := lpad(rw_crapcob.nrdconta,10,'0')||
                         lpad(rw_crapcob.nrborder,10,'0') ||
                         lpad(vr_cdvencto, 5, '0');

          IF vr_tab_venc_aux.exists(vr_idx_venc) THEN
            vr_tab_venc_aux(vr_idx_venc).vlvalven := nvl(vr_tab_venc_aux(vr_idx_venc).vlvalven, 0) + nvl(vr_vlsrisco, 0);
          ELSE
            vr_tab_venc_aux(vr_idx_venc).cdvencto := vr_cdvencto;
            vr_tab_venc_aux(vr_idx_venc).vlvalven := nvl(vr_vlsrisco, 0);
          END IF;
        END IF;
      END IF;
    END IF;
    
    IF rw_crapcob.dtvencto > vr_dtmaxven OR vr_dtmaxven IS NULL THEN
       vr_dtmaxven := rw_crapcob.dtvencto;
    END IF;
    
    /*  Processar somente no ultimo registro do bordero   */    
    IF rw_crapcob.seq_atu = rw_crapcob.qtd_max AND vr_vldestit > 0 THEN
      
      DSCT0003.pc_calcula_risco_bordero(pr_cdcooper => pr_cdcooper
                                       ,pr_nrborder => rw_crapcob.nrborder
                                       ,pr_dsinrisc => vr_risco_aux
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
          gravarTempoCentral(pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => 0
                            ,pr_dsmensag => vr_cdprograma || ' - PASSO 03 => ' || nvl(rw_crapcob.nrborder,0)
                            ,pr_dtinicio => SYSDATE);
                            
        vr_cdcritic := 0;
        vr_dscritic := NULL;
      END IF;

      IF rw_crapcob.inprejuz = 1 THEN
        
        OPEN cr_craptdb(pr_cdcooper => pr_cdcooper
                       ,pr_nrborder => rw_crapcob.nrborder);
        FETCH cr_craptdb INTO rw_craptdb;
        CLOSE cr_craptdb;

        vr_vlprjbdt := nvl(rw_craptdb.vlprejtotal,0);
        -- Se a data do prejuízo for de um mês superior ao corrente
        IF trunc(rw_crapcob.dtprejuz,'mm') > trunc(pr_dtrefere,'mm') THEN
          -- Utilizamos fixo 50, pois a lógica Progress sempre chegava nesse valor para prejuizos futuros
          vr_indocc := 50;
        ELSE
          -- Retornar a quantidade de meses de diferença
          -- entre a data atual e a data do prejuizo, utilizamos
          -- trunc para considerar somente a diferença exata de meses
          -- do cálculo Oracle e somamos mais 1 inteiro
          vr_indocc := trunc(months_between(trunc(pr_dtrefere,'mm'),trunc(rw_crapcob.dtprejuz,'mm')))+1;
        END IF;
        -- já diminuindo o prejuízo os valores pagos somados na vr_vlrpagos
        IF vr_indocc <= 12 THEN
          vr_vlprjano := vr_vlprjbdt;
        ELSIF vr_indocc >= 13 AND vr_indocc <= 48 THEN
          vr_vlprjaan := vr_vlprjbdt;
        ELSE
          vr_vlprjant := vr_vlprjbdt;
        END IF;
        vr_vldestit := vr_vlprjbdt;
      END IF;

      /* Conta Cosif */
      IF GESTAODERISCO.tiposdadosriscos.cosif_prj_ativo = 1 AND rw_crapcob.inprejuz = 1 THEN
         -- Se está ativo o parametro COSIF PREJUIZO (CADPAR)
         vr_ctacosif := GESTAODERISCO.tiposdadosriscos.cosif_prejuizo;  -- Prejuizo tem prioridade (prejuizo > opecred > por modalidade)
      END IF;
        
      IF vr_ctacosif IS NULL THEN
      GESTAODERISCO.obterContaCosif(pr_cdcooper => pr_cdcooper
                                   ,pr_cdmodali => vr_cdmodali
                                   ,pr_inpessoa => rw_crapcob.inpessoa
                                   ,pr_ctacosif => vr_ctacosif);
      END IF; 
      
      
      -- Carregar contrato de limite de credito ativo
      OPEN cr_craplim_credito(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_crapcob.nrdconta
                             ,pr_nrctrlim => rw_crapcob.nrctrlim);
      FETCH cr_craplim_credito INTO rw_craplim_credito;
      IF cr_craplim_credito%FOUND THEN
        
        vr_nrctaav1 := rw_craplim_credito.nrctaav1;
        vr_nrctaav2 := rw_craplim_credito.nrctaav2;
        
        -- Busca sobre a tabela de linhas de credito rotativo
        vr_idx_crapldc := lpad(rw_craplim_credito.cddlinha,10,'0')
                       || lpad(3,10,'0');
        IF vr_tab_crapldc.exists(vr_idx_crapldc) THEN
          vr_nrtaxeft := ROUND((POWER(1 + (vr_tab_crapldc(vr_idx_crapldc).txjurmor / 100),12) - 1) * 100,2);
        ELSE
          vr_nrtaxeft := 0;                                       -- Taxa Efetiva Anual 
        END IF;
        
      ELSE 
        vr_nrtaxeft := 0;
      END IF;
      CLOSE cr_craplim_credito;
      
      vr_idx_desconto := lpad(pr_cdcooper,5,'0') 
                      || lpad(rw_crapcob.nrdconta,10,'0')
                      || lpad(rw_crapcob.nrborder,10,'0');
      vr_vljuros_suspenso := 0;
      IF vr_tab_juros_desconto_titulo.exists(vr_idx_desconto) THEN
        vr_vljuros_suspenso := vr_tab_juros_desconto_titulo(vr_idx_desconto).vljura60;
      END IF;
      
      /* Origem do Recurso */
      vr_dsorgrec := GESTAODERISCO.tiposDados3040.ct_dsorgrec;
      
      /* Taxa do Indexador / Percentual Indexador / Variacao Cambial / Cep Dependencia Concesssao Operacao / Taxa Efetiva Anual / Natureza da Operacao */
      vr_nrtaxidx := GESTAODERISCO.tiposDados3040.ct_nrtaxidx;  -- Taxa do Indexador
      vr_nrperidx := GESTAODERISCO.tiposDados3040.ct_nrperidx;  -- Percentual Indexador
      vr_nrvarcam := GESTAODERISCO.tiposDados3040.ct_nrvarcam;  -- Variacao Cambial
      vr_cdnatope := GESTAODERISCO.tiposDados3040.ct_cdnatope;  -- Natureza da Operacao
      vr_cepconce := GESTAODERISCO.tiposdadosriscos.nrcepsingular; -- Cep Dependencia Concesssao Operacao
      
      -- OPERACAO
      vr_tab_oper(vr_idoperacao).idcarga     := pr_idcarga;
      vr_tab_oper(vr_idoperacao).idoperacao  := vr_idoperacao;
      vr_tab_oper(vr_idoperacao).nrdconta    := rw_crapcob.nrdconta;
      vr_tab_oper(vr_idoperacao).nrcontrato  := rw_crapcob.nrborder;
      vr_tab_oper(vr_idoperacao).nrctacos    := vr_ctacosif;
      vr_tab_oper(vr_idoperacao).dsorgrec    := vr_dsorgrec;
      vr_tab_oper(vr_idoperacao).nrtaxidx    := vr_nrtaxidx;
      vr_tab_oper(vr_idoperacao).nrperidx    := vr_nrperidx;
      vr_tab_oper(vr_idoperacao).nrvarcam    := vr_nrvarcam;
      vr_tab_oper(vr_idoperacao).nrcepcon    := vr_cepconce;
      vr_tab_oper(vr_idoperacao).nrtaxeft    := vr_nrtaxeft;
      vr_tab_oper(vr_idoperacao).dtinictr    := vr_dtinivig;
      vr_tab_oper(vr_idoperacao).cdnatope    := vr_cdnatope;
      vr_tab_oper(vr_idoperacao).vlcontrato  := rw_crapcob.vltotal_bordero;
      vr_tab_oper(vr_idoperacao).inprejuz    := nvl(rw_crapcob.inprejuz, 0);
      vr_tab_oper(vr_idoperacao).qtdiaatr    := ABS(vr_qtdiaatr);
      vr_tab_oper(vr_idoperacao).vlliquid    := vr_vldestit - nvl(vr_vljuros_suspenso,0);
      vr_tab_oper(vr_idoperacao).qtdparcelas := 1;
      vr_tab_oper(vr_idoperacao).nrcontrato_principal := rw_crapcob.nrctrlim;
      vr_tab_oper(vr_idoperacao).tpcontrato  := 2; -- tipo bordero
      vr_tab_oper(vr_idoperacao).vljuros_suspenso  := nvl(vr_vljuros_suspenso,0);      
      vr_tab_oper(vr_idoperacao).dtvencimento := vr_dtmaxven;   
      vr_tab_oper(vr_idoperacao).vlproxima_parcela := vr_vlprxpar; 
      vr_tab_oper(vr_idoperacao).dtproxima_parcela := vr_dtprxpar; 
      
      -- Ler todos vencimentos da tabela auxiliar, gravar na tabela de inserção com id da operação
      IF vr_tab_venc_aux.COUNT > 0 THEN
        vr_idx_venc := vr_tab_venc_aux.FIRST;
        WHILE vr_idx_venc IS NOT NULL LOOP
          -- Verificar se o vencimento existe
          IF vr_tab_venc_aux.exists(vr_idx_venc) THEN
            vr_idx_cont := vr_tab_venc.count() + 1;
            vr_tab_venc(vr_idx_cont).idoperacao := vr_idoperacao;
            vr_tab_venc(vr_idx_cont).cdvencto   := vr_tab_venc_aux(vr_idx_venc).cdvencto;
            vr_tab_venc(vr_idx_cont).vlvalven   := vr_tab_venc_aux(vr_idx_venc).vlvalven;
          END IF;
          vr_idx_venc := vr_tab_venc_aux.NEXT(vr_idx_venc);
        END LOOP;
      END IF;
      
      IF vr_tem_acordo_desc THEN
        vr_idx_vri := vr_tab_vri_acordo.FIRST;
        WHILE vr_idx_vri IS NOT NULL LOOP
          
          vr_idx_cont := vr_tab_venc.count() + 1;
          vr_tab_venc(vr_idx_cont).idoperacao := vr_idoperacao;
          vr_tab_venc(vr_idx_cont).cdvencto   := vr_tab_vri_acordo(vr_idx_vri).cdvencto;
          vr_tab_venc(vr_idx_cont).vlvalven   := vr_tab_vri_acordo(vr_idx_vri).vldivida;
          
          vr_idx_vri := vr_tab_vri_acordo.NEXT(vr_idx_vri);
        END LOOP;
      END IF;

      IF rw_crapcob.inprejuz = 1 THEN
        -- Se existir valor prejuizo ano atual
        IF nvl(vr_vlprjano, 0) > 0 THEN
          vr_cdvencto := GESTAODERISCO.retornarVenctoRegraS29(pr_qtdiaatr => ABS(vr_qtdiaatr));
          vr_idx_cont := vr_tab_venc.count() + 1;
          vr_tab_venc(vr_idx_cont).idoperacao := vr_idoperacao;
          vr_tab_venc(vr_idx_cont).cdvencto   := vr_cdvencto;
          vr_tab_venc(vr_idx_cont).vlvalven   := vr_vlprjano;
        END IF;
        
        -- Se existir valor prejuizo ano anterior
        IF nvl(vr_vlprjaan, 0) > 0 THEN
          vr_cdvencto := GESTAODERISCO.retornarVenctoRegraS29(pr_qtdiaatr => ABS(vr_qtdiaatr));
          vr_idx_cont := vr_tab_venc.count() + 1;
          vr_tab_venc(vr_idx_cont).idoperacao := vr_idoperacao;
          vr_tab_venc(vr_idx_cont).cdvencto   := vr_cdvencto;
          vr_tab_venc(vr_idx_cont).vlvalven   := vr_vlprjaan;
        END IF;
        
        -- Se existir valor prejuizo anos anteriores
        IF nvl(vr_vlprjant, 0) > 0 THEN
          vr_cdvencto := GESTAODERISCO.retornarVenctoRegraS29(pr_qtdiaatr => ABS(vr_qtdiaatr));
          vr_idx_cont := vr_tab_venc.count() + 1;
          vr_tab_venc(vr_idx_cont).idoperacao := vr_idoperacao;
          vr_tab_venc(vr_idx_cont).cdvencto   := vr_cdvencto;
          vr_tab_venc(vr_idx_cont).vlvalven   := vr_vlprjant;
        END IF;
        
        vr_cdvencto := GESTAODERISCO.retornarVenctoRegraS29(pr_qtdiaatr => ABS(vr_qtdiaatr));
        IF vr_cdvencto = 330 THEN
           GESTAODERISCO.adicionarCaracteristica(pr_dscarori => vr_dscaresp
                                                ,pr_dscarnov => '11'
                                                ,pr_dscaralt => vr_dscaresp);
        END IF;

      END IF;
      
      GESTAODERISCO.retornarAtivoProblematico(pr_cdcooper   => pr_cdcooper
                                             ,pr_nrdconta   => rw_crapcob.nrdconta
                                             ,pr_nrctremp   => rw_crapcob.nrborder
                                             ,pr_atvprobl   => vr_atvprobl
                                             ,pr_idreestrut => vr_reestrut
                                             ,pr_dtatvprobl => vr_dtatvprobl);
      IF vr_atvprobl = 1 THEN
        -- Se identificou como Ativo Problemático, envia CaracEspecial = 19
        GESTAODERISCO.adicionarCaracteristica(pr_dscarori => vr_dscaresp
                                             ,pr_dscarnov => '19'
                                             ,pr_dscaralt => vr_dscaresp);
      END IF;
      
      /* GARANTIAS */
      IF nvl(vr_nrctaav1, 0) <> 0 OR (nvl(vr_nrctaav2, 0) <> 0 AND vr_nrctaav2 <> vr_nrctaav1) THEN
        GESTAODERISCO.obterGarantiasProduto(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => rw_crapcob.nrdconta
                                           ,pr_idoperac => vr_idoperacao
                                           ,pr_nrctaav1 => vr_nrctaav1
                                           ,pr_nrctaav2 => vr_nrctaav2
                                           ,pr_cdmodali => vr_cdmodali
                                           ,pr_dtrefere => pr_dtrefere
                                           ,pr_tab_aval => vr_tab_aval
                                           ,pr_tab_gara => vr_tab_gara
                                           ,pr_tab_info => vr_tab_info
                                           ,pr_dscritic => vr_dscritic);
        -- Testar retorno de erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Gerar erro e roolback
          RAISE vr_exc_erro;
        END IF;  
      END IF;
      
      vr_tab_oper(vr_idoperacao).dscaresp    := vr_dscaresp;
      
    END IF;
  END LOOP;
  
  gravarTempoCentral(pr_cdcooper => pr_cdcooper
                    ,pr_cdagenci => 0
                    ,pr_dsmensag => vr_cdprograma || ' - PASSO 06'
                    ,pr_dtinicio => SYSDATE);
                    
  ----> Gravar tabelas fisicas <---
  GESTAODERISCO.gravarCargaOperacao(pr_cdcooper => pr_cdcooper
                                   ,pr_idcarga  => pr_idcarga
                                   ,pr_tab_oper => vr_tab_oper
                                   ,pr_idprglog => vr_idprglog
                                   ,pr_dscritic => vr_dscritic);
  -- Testar retorno de erro
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Gerar erro e roolback
    RAISE vr_exc_erro;
  END IF;  
  
  GESTAODERISCO.gravarCargaLimite(pr_cdcooper => pr_cdcooper
                                 ,pr_tab_limi => vr_tab_limi
                                 ,pr_idprglog => vr_idprglog
                                 ,pr_dscritic => vr_dscritic);
  -- Testar retorno de erro
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Gerar erro e roolback
    RAISE vr_exc_erro;
  END IF;
  
  GESTAODERISCO.gravarCargaVencimento(pr_cdcooper => pr_cdcooper
                                     ,pr_tab_venc => vr_tab_venc
                                     ,pr_idprglog => vr_idprglog
                                     ,pr_dscritic => vr_dscritic);
  -- Testar retorno de erro
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Gerar erro e roolback
    RAISE vr_exc_erro;
  END IF;
  
  GESTAODERISCO.gravarCargaGarantia(pr_cdcooper => pr_cdcooper
                                   ,pr_tab_gara => vr_tab_gara
                                   ,pr_idprglog => vr_idprglog
                                   ,pr_dscritic => vr_dscritic);
  -- Testar retorno de erro
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Gerar erro e roolback
    RAISE vr_exc_erro;
  END IF;
  
  GESTAODERISCO.gravarInfoAdicional(pr_cdcooper => pr_cdcooper
                                   ,pr_tab_info => vr_tab_info
                                   ,pr_idprglog => vr_idprglog
                                   ,pr_dscritic => vr_dscritic);
  -- Testar retorno de erro
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Gerar erro e roolback
    RAISE vr_exc_erro;
  END IF;
  
  ----------> Fim Negocio Carga <------------         
  COMMIT;
  
  gravarTempoCentral(pr_cdcooper => pr_cdcooper
                    ,pr_cdagenci => 0
                    ,pr_dsmensag => 'Total ' || vr_cdprograma || ' Fim Carga'
                    ,pr_dtinicio => vr_dtinproc);
  
  GESTAODERISCO.gravaLogProcCentral(pr_cdcooper     => pr_cdcooper
                                   ,pr_cdprograma   => vr_cdprograma
                                   ,pr_dscritic     => 'Fim da execucao: ' || vr_cdprograma
                                   ,pr_ind_tipo_log => 1);
EXCEPTION 
  WHEN vr_exc_erro THEN
  
    -- Se foi retornado apenas codigo
    IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
      -- Buscar a descricao
      vr_dscritic := obterCritica(vr_cdcritic);
    END IF;
    -- Devolvemos codigo e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic ||': '||vr_dscomple;
    
    ROLLBACK;
    
    GESTAODERISCO.gravaLogProcCentral(pr_cdcooper     => pr_cdcooper
                                     ,pr_cdprograma   => vr_cdprograma
                                     ,pr_dscritic     => 'ERRO na execucao: ' || vr_cdprograma || ' - ' || pr_dscritic ||  ' - ' || dbms_utility.format_error_backtrace
                                     ,pr_ind_tipo_log => 2);    
  
  WHEN OTHERS THEN
    
    ROLLBACK;
                               
    pr_dscritic := 'Erro na : ' || vr_cdprograma || ': ' || SQLERRM;     
    
    sistema.excecaoInterna(pr_cdcooper => pr_cdcooper
                          ,pr_compleme => vr_dscomple || pr_dscritic);
    
    GESTAODERISCO.gravaLogProcCentral(pr_cdcooper     => pr_cdcooper
                                     ,pr_cdprograma   => vr_cdprograma
                                     ,pr_dscritic     => 'ERRO na execucao: ' || vr_cdprograma || ' - ' || SQLERRM ||  ' - ' || dbms_utility.format_error_backtrace
                                     ,pr_ind_tipo_log => 2);     
          
END gerarCargaDescontoTitulo;


procedure geraCargaCentral(pr_cdcooper  IN crapris.cdcooper%TYPE  --> Cooperativa
                                                          ,pr_flgexemp  IN BOOLEAN DEFAULT FALSE  --> Carregar tabelas referentes a emprestimos e executar programas (TR, PP, POS)
                                                          ,pr_flgbndes  IN BOOLEAN DEFAULT FALSE  --> Carregar tabelas referentes a emprestimos e executar programas (BNDES)
                                                          ,pr_flgexlim  IN BOOLEAN DEFAULT FALSE  --> Executar limite
                                                          ,pr_flgexadp  IN BOOLEAN DEFAULT FALSE  --> Executar ADP
                                                          ,pr_flgexddc  IN BOOLEAN DEFAULT FALSE  --> Executar Desconto de Cheque
                                                          ,pr_flgexddt  IN BOOLEAN DEFAULT FALSE  --> Executar Desconto de Titulo
                                                          ,pr_flgeximo  IN BOOLEAN DEFAULT FALSE  --> Executar Contratos Imobiliarios
                                                          ,pr_flgcarta  IN BOOLEAN DEFAULT FALSE  --> Executar Cartoes Bancoob / BB
                                                          ,pr_flggarpr  IN BOOLEAN DEFAULT FALSE  --> Executar Movimentos de Risco de Provisão e Garantia
                                                          ,pr_flgsaida  IN BOOLEAN DEFAULT FALSE  --> Executar Saidas
                                                          ,pr_dtrefere  IN crapdat.dtmvtolt%TYPE  --> Data de referencia principal
                                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                                          ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica

  vr_cdprograma VARCHAR2(25) := 'geraCargaCentral';
  vr_dtinproc   CONSTANT DATE         := SYSDATE;
  vr_dscomple   VARCHAR2(2000);
  vr_idprglog   NUMBER;
  
  vr_exc_erro     EXCEPTION;
  vr_cdcritic     NUMBER;
  vr_dscritic     VARCHAR2(4000);
  
  vr_idcarga    gestaoderisco.tbrisco_central_carga.idcentral_carga%TYPE;
  vr_tpprodut   gestaoderisco.tbrisco_central_carga.tpproduto%TYPE;
  
  vr_totaljobs  INTEGER := gestaoderisco.tiposdadosriscos.totaljobs;
  
  pr_rw_crapdat datascooperativa;
  vr_dtmvtolt   crapdat.dtmvtolt%TYPE;
  
  -- Marca a cadeia da central de risco com última data executada
  PROCEDURE pc_fim_cadeia_central_risco(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

    UPDATE CRAPPRM
       SET CRAPPRM.DSVLRPRM = TO_CHAR(pr_dtmvtolt, 'DD/MM/RRRR')
     WHERE NMSISTEM = 'CRED'
       AND CDCOOPER = pr_cdcooper
       AND CDACESSO = 'CADEIA_CENTRAL_RISCO';
    COMMIT;
        
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception();
  END pc_fim_cadeia_central_risco;
  
  --> Gerar log do processo de importação
  PROCEDURE pc_gera_log(pr_dscritic IN VARCHAR2
                       ,pr_ind_tipo_log IN INTEGER) IS

    vr_dscritic VARCHAR2(1000);
  BEGIN
    vr_dscritic := to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||' --> '||
                   pr_dscritic;

    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_cdprograma   => vr_cdprograma,
                               pr_ind_tipo_log => pr_ind_tipo_log,
                               pr_des_log      => vr_dscritic,
                               pr_nmarqlog     => 'proc_batch.log',
                               pr_flfinmsg     => 'N');


  END pc_gera_log;
BEGIN
  
  -- Calcular o calendario com base na data de referencia enviada
  GESTAODERISCO.obterCalendario(pr_cdcooper   => pr_cdcooper
                               ,pr_dtrefere   => pr_dtrefere
                               ,pr_rw_crapdat => pr_rw_crapdat
                               ,pr_cdcritic   => pr_cdcritic
                               ,pr_dscritic   => pr_dscritic);
  -- Testar retorno de erro
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Gerar erro e roolback
    RAISE vr_exc_erro;
  END IF;
  
  GESTAODERISCO.tiposdadosriscos.dsexecucao := 'crpsrid';
  IF to_char(pr_rw_crapdat.dtmvtolt,'mm') != to_char(pr_rw_crapdat.dtmvtopr,'mm') THEN 
    GESTAODERISCO.tiposdadosriscos.dsexecucao := 'crpsrim';
  END IF;
  
  vr_tpprodut := 0;  
  CASE TRUE
    WHEN pr_flgexemp THEN
      vr_tpprodut := 90;  -- Emprestimos (TR, PP, POS, BNDES)
    WHEN pr_flgbndes THEN
      vr_tpprodut := 95;  -- Emprestimos (BNDES)
    WHEN pr_flgexlim THEN
      vr_tpprodut := 1;   -- Limite de Crédito
    WHEN pr_flgexadp THEN
      vr_tpprodut := 10;  -- ADP
    WHEN pr_flgexddc THEN
      vr_tpprodut := 2;   -- Desconto de Cheque
    WHEN pr_flgexddt THEN
      vr_tpprodut := 3;   -- Desconto de Titulo
    WHEN pr_flgeximo THEN
      vr_tpprodut := 96;  -- Contratos Imobiliarios
    WHEN pr_flgcarta THEN
      vr_tpprodut := 97;  -- Cartoes Bancoob / BB
    WHEN pr_flggarpr THEN
      vr_tpprodut := 98;  -- Movimentos de Risco de Provisão e Garantia
  END CASE;
  
  GESTAODERISCO.gravarInicioCarga(pr_cdcooper => pr_cdcooper
                                 ,pr_tpprodut => vr_tpprodut
                                 ,pr_idcarga  => vr_idcarga
                                 ,pr_rw_crapdat => pr_rw_crapdat
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
  -- Testar retorno de erro
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Gerar erro e roolback
    RAISE vr_exc_erro;
  END IF;
  
  GESTAODERISCO.gravaLogProcCentral(pr_cdcooper     => pr_cdcooper
                                   ,pr_cdprograma   => vr_cdprograma
                                   ,pr_dscritic     => 'Inicio da carga da Central de Risco.'
                                   ,pr_ind_tipo_log => 1);
  
  -- Executar emprestimos
  IF pr_flgexemp THEN
    -- Se executar saidas
    IF pr_flgsaida THEN
      -- Gerar tabela de modalidades bacen necessarias para as saidas de emprestimos
      GESTAODERISCO.gerarModalidadesBacen(pr_cdcooper => pr_cdcooper
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Testar retorno de erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Gerar erro e roolback
        RAISE vr_exc_erro;
      END IF;
    END IF;
  END IF;
    
  GESTAODERISCO.obterTemporarias(pr_cdcooper => pr_cdcooper
                                ,pr_flgexemp => pr_flgexemp
                                ,pr_flgbndes => pr_flgbndes
                                ,pr_flgexlim => pr_flgexlim
                                ,pr_flgexadp => pr_flgexadp
                                ,pr_flgexddc => pr_flgexddc
                                ,pr_flgexddt => pr_flgexddt
                                ,pr_flgeximo => pr_flgeximo
                                ,pr_flgcarta => pr_flgcarta
                                ,pr_flggarpr => pr_flggarpr
                                ,pr_rw_crapdat => pr_rw_crapdat
                                ,pr_tpprodut => vr_tpprodut
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
  -- Testar retorno de erro
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Gerar erro e roolback
    RAISE vr_exc_erro;
  END IF;
  
  GESTAODERISCO.gravaLogProcCentral(pr_cdcooper     => pr_cdcooper
                                   ,pr_cdprograma   => vr_cdprograma
                                   ,pr_dscritic     => 'Iniciando carga da Central de Risco para o produto: ' || vr_tpprodut || '.'
                                   ,pr_ind_tipo_log => 1);
  
  -- Executar Limite tipo 1
  IF pr_flgexlim THEN
    GESTAODERISCO.gerarCargaLimiteCredito(pr_cdcooper => pr_cdcooper
                                         ,pr_idcarga  => vr_idcarga -- IN
                                         ,pr_idprglog => vr_idprglog
                                         ,pr_dtrefere => pr_rw_crapdat.dtmvtolt
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
    
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
  END IF;
  
  -- Executar ADP tipo 10
  IF pr_flgexadp THEN
    -- Na mensal
    IF to_char(pr_rw_crapdat.dtmvtolt,'mm') != to_char(pr_rw_crapdat.dtmvtopr,'mm') THEN 
      -- Se o ultimo dia do mes cair no final de semana, se nao for final de semana ja estara correto
      IF TO_CHAR(pr_rw_crapdat.dtultdia,'D') IN (1, 7) THEN -- 1 domingo 7 sabado
        -- Replica os juros do adp do ultimo dia util para ultimo dia do mes, para acompanhar a central de risco
        GESTAODERISCO.copiarJuroMensalADP(pr_cdcooper => pr_cdcooper
                                         ,pr_dtrefere => pr_rw_crapdat.dtmvtolt
                                         ,pr_dtultdia => pr_rw_crapdat.dtultdia
                                         ,pr_dscritic => vr_dscritic);
      END IF;
    END IF;
    GESTAODERISCO.gerarCargaADP(pr_cdcooper => pr_cdcooper
                               ,pr_idcarga  => vr_idcarga -- IN
                               ,pr_idprglog => vr_idprglog
                               ,pr_dtrefere => pr_rw_crapdat.dtmvtolt
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
    
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
  END IF;
  
  -- Executar Desconto de Cheque tipo 2
  IF pr_flgexddc THEN
    -- Na mensal
    vr_dtmvtolt := pr_rw_crapdat.dtmvtolt;
    IF to_char(pr_rw_crapdat.dtmvtolt,'mm') != to_char(pr_rw_crapdat.dtmvtopr,'mm') THEN 
      -- Se o ultimo dia do mes cair no final de semana, se nao for final de semana ja estara correto
      IF TO_CHAR(pr_rw_crapdat.dtultdia,'D') IN (1, 7) THEN -- 1 domingo 7 sabado
        vr_dtmvtolt := pr_rw_crapdat.dtultdia;
      END IF;
    END IF;
    GESTAODERISCO.gerarCargaDescontoCheque(pr_cdcooper => pr_cdcooper
                                          ,pr_idcarga  => vr_idcarga -- IN
                                          ,pr_idprglog => vr_idprglog
                                          ,pr_dtrefere => vr_dtmvtolt
                                          ,pr_dtultdia => pr_rw_crapdat.dtultdia
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
    
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
    --
    IF pr_flgsaida AND
       to_char(pr_rw_crapdat.dtmvtolt,'MM') <> to_char(pr_rw_crapdat.dtmvtopr,'MM') THEN
      GESTAODERISCO.gerarSaidasDescCheque(pr_cdcooper => pr_cdcooper
                                         ,pr_idcarga  => vr_idcarga -- IN
                                         ,pr_idprglog => vr_idprglog
                                         ,pr_dtrefere => pr_rw_crapdat.dtmvtolt
                                         ,pr_dtultdma => pr_rw_crapdat.dtultdma
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      
      -- Testar retorno de erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Gerar erro e roolback
        RAISE vr_exc_erro;
      END IF;
    END IF;
  END IF;
  
  -- Executar Desconto de Titulo tipo 3
  IF pr_flgexddt THEN
    vr_dtmvtolt := pr_rw_crapdat.dtmvtolt;
    IF to_char(pr_rw_crapdat.dtmvtolt,'mm') != to_char(pr_rw_crapdat.dtmvtopr,'mm') THEN 
      -- Se o ultimo dia do mes cair no final de semana, se nao for final de semana ja estara correto
      IF TO_CHAR(pr_rw_crapdat.dtultdia,'D') IN (1, 7) THEN -- 1 domingo 7 sabado
        vr_dtmvtolt := pr_rw_crapdat.dtultdia;
      END IF;
    END IF;
      gerarCargaDescontoTitulo(pr_cdcooper => pr_cdcooper
                              ,pr_idcarga  => vr_idcarga -- IN
                              ,pr_idprglog => vr_idprglog
                              ,pr_dtrefere => vr_dtmvtolt
                              ,pr_dtultdia => pr_rw_crapdat.dtultdia
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
    
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;

    --
    IF pr_flgsaida THEN
      GESTAODERISCO.gerarSaidasDescTitulo(pr_cdcooper => pr_cdcooper
                                         ,pr_idcarga  => vr_idcarga -- IN
                                         ,pr_idprglog => vr_idprglog
                                         ,pr_rw_crapdat => pr_rw_crapdat
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      
      -- Testar retorno de erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Gerar erro e roolback
        RAISE vr_exc_erro;
      END IF;
    END IF;
  END IF;
  
  -- Executar Imobiliario tipo 96
  IF pr_flgeximo THEN
    GESTAODERISCO.gerarCargaContratoImobiliario(pr_cdcooper => pr_cdcooper
                                               ,pr_idcarga  => vr_idcarga -- IN
                                               ,pr_idprglog => vr_idprglog
                                               ,pr_dtrefere => pr_rw_crapdat.dtmvtolt
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
    
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
    
    GESTAODERISCO.gerarSaidaContratoImobiliario(pr_cdcooper => pr_cdcooper
                                               ,pr_idcarga  => vr_idcarga -- IN
                                               ,pr_idprglog => vr_idprglog
                                               ,pr_dtrefere => pr_rw_crapdat.dtmvtolt
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
    
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
    
  END IF;
  
  -- BNDES tipo 95
  IF pr_flgbndes THEN
    
    -- Gera carga de acordos
    GESTAODERISCO.gerarCargaAcordos(pr_cdcooper   => pr_cdcooper
                                   ,pr_rw_crapdat => pr_rw_crapdat
                                   ,pr_cdcritic   => vr_cdcritic
                                   ,pr_dscritic   => vr_dscritic);
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
    
    GESTAODERISCO.gerarCargaEmprestimoBNDES(pr_cdcooper => pr_cdcooper
                                           ,pr_idcarga  => vr_idcarga -- IN
                                           ,pr_idprglog => vr_idprglog
                                           ,pr_dtrefere => pr_rw_crapdat.dtmvtolt
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
      
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
    --
    IF pr_flgsaida THEN
      GESTAODERISCO.gerarSaidasBndes(pr_cdcooper => pr_cdcooper
                                    ,pr_idcarga  => vr_idcarga -- IN
                                    ,pr_idprglog => vr_idprglog
                                    ,pr_dtrefere => pr_rw_crapdat.dtmvtolt
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      
      -- Testar retorno de erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Gerar erro e roolback
        RAISE vr_exc_erro;
      END IF;
    END IF;
  END IF;
  
  -- Executar emprestimos
  IF pr_flgexemp THEN
    -- Atualizar lancamentos de prejuizo
    GESTAODERISCO.atualizarLancamentosPrejuizo(pr_cdcooper => pr_cdcooper
                                              ,pr_rw_crapdat => pr_rw_crapdat
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);
                                                                      
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
    
    DELETE FROM gestaoderisco.TBRISCO_OPERACAOES_CONTROLE_PARALELO WHERE cdcooper = pr_cdcooper AND tpproduto = 90;
    COMMIT;
    
    --------------------------------  PREJUIZO  --------------------------------
    
    -- Configuracao de jobs do PREJ da cooperativa
    IF GESTAODERISCO.tiposdadosriscos.tab_job_cooperativa.exists(pr_cdcooper) THEN
      IF GESTAODERISCO.tiposdadosriscos.tab_job_cooperativa(pr_cdcooper).tab_job_coop.exists(GESTAODERISCO.tiposDadosRiscos.identiPrejuizo) THEN
        vr_totaljobs := nvl(GESTAODERISCO.tiposdadosriscos.tab_job_cooperativa(pr_cdcooper).tab_job_coop(GESTAODERISCO.tiposDadosRiscos.identiPrejuizo).qtdejobs, vr_totaljobs);
      END IF;
    END IF;
    
    INSERT INTO gestaoderisco.TBRISCO_OPERACAOES_CONTROLE_PARALELO (cdcooper, nrdconta, nrctremp, tpproduto, id_paralelo, tpemprst)
        SELECT e.cdcooper
              ,e.nrdconta
              ,e.nrctremp
              ,90
              ,mod(row_number() over (order by e.tpemprst),vr_totaljobs) rnk
              ,GESTAODERISCO.tiposDadosRiscos.identiPrejuizo
          FROM crapepr e
             , crawepr w
         WHERE w.cdcooper = e.cdcooper
           AND w.nrdconta = e.nrdconta
           AND w.nrctremp = e.nrctremp
           AND e.cdcooper = pr_cdcooper

           -- Ativo COM Prejuizo
           AND e.inprejuz = 1
           AND e.vlsdprej > 0
           AND e.tpemprst IN (1, 2); -- PP e POS
    COMMIT;
    
    -- Emprestimos em Prejuizo tipo 90 (PP e Pos)
    GESTAODERISCO.criarJobsParalelosEmprestimos(pr_cdcooper   => pr_cdcooper
                                               ,pr_idcarga    => vr_idcarga
                                               ,pr_tpemprst   => GESTAODERISCO.tiposDadosRiscos.identiPrejuizo
                                               ,pr_rw_crapdat => pr_rw_crapdat
                                               ,pr_dscritic   => vr_dscritic);
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
    
    --------------------------------  TR  --------------------------------
    
    -- Emprestimos TR tipo 90 (incluindo prejuizos TR)
    GESTAODERISCO.gerarCargaEmprestimoTR(pr_cdcooper => pr_cdcooper
                                        ,pr_idcarga  => vr_idcarga -- IN
                                        ,pr_idprglog => vr_idprglog
                                        ,pr_rw_crapdat => pr_rw_crapdat
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
    
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;

    --------------------------------  PRE FIXADO  --------------------------------
    
    -- Configuracao de jobs do PP da cooperativa
    IF GESTAODERISCO.tiposdadosriscos.tab_job_cooperativa.exists(pr_cdcooper) THEN
      IF GESTAODERISCO.tiposdadosriscos.tab_job_cooperativa(pr_cdcooper).tab_job_coop.exists(1) THEN
        vr_totaljobs := nvl(GESTAODERISCO.tiposdadosriscos.tab_job_cooperativa(pr_cdcooper).tab_job_coop(1).qtdejobs, vr_totaljobs);
      END IF;
    END IF;
    
    INSERT INTO gestaoderisco.TBRISCO_OPERACAOES_CONTROLE_PARALELO (cdcooper, nrdconta, nrctremp, tpproduto, id_paralelo, tpemprst)
        SELECT e.cdcooper
              ,e.nrdconta
              ,e.nrctremp
              ,90
              ,mod(row_number() over (order by e.tpemprst),vr_totaljobs) rnk
              ,e.tpemprst
          FROM crapepr e
             , crawepr w
         WHERE w.cdcooper = e.cdcooper
           AND w.nrdconta = e.nrdconta
           AND w.nrctremp = e.nrctremp
           AND e.cdcooper = pr_cdcooper

           -- Ativo Sem Prejuizo
           AND e.inliquid = 0 
           AND e.inprejuz = 0
           AND e.tpemprst IN (1) -- PP
           AND e.dtliquid IS NULL;
    COMMIT;
    
    -- Emprestimos PP tipo 90
    GESTAODERISCO.criarJobsParalelosEmprestimos(pr_cdcooper   => pr_cdcooper
                                               ,pr_idcarga    => vr_idcarga
                                               ,pr_tpemprst   => 1
                                               ,pr_rw_crapdat => pr_rw_crapdat
                                               ,pr_dscritic   => vr_dscritic);
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
    
    --------------------------------  POS FIXADO  --------------------------------
    
    -- Configuracao de jobs do POS da cooperativa
    IF GESTAODERISCO.tiposdadosriscos.tab_job_cooperativa.exists(pr_cdcooper) THEN
      IF GESTAODERISCO.tiposdadosriscos.tab_job_cooperativa(pr_cdcooper).tab_job_coop.exists(2) THEN
        vr_totaljobs := nvl(GESTAODERISCO.tiposdadosriscos.tab_job_cooperativa(pr_cdcooper).tab_job_coop(2).qtdejobs, vr_totaljobs);
      END IF;
    END IF;
    
    INSERT INTO gestaoderisco.TBRISCO_OPERACAOES_CONTROLE_PARALELO (cdcooper, nrdconta, nrctremp, tpproduto, id_paralelo, tpemprst)
        SELECT e.cdcooper
              ,e.nrdconta
              ,e.nrctremp
              ,90
              ,mod(row_number() over (order by e.tpemprst),vr_totaljobs) rnk
              ,e.tpemprst
          FROM crapepr e
             , crawepr w
         WHERE w.cdcooper = e.cdcooper
           AND w.nrdconta = e.nrdconta
           AND w.nrctremp = e.nrctremp
           AND e.cdcooper = pr_cdcooper

           -- Ativo Sem Prejuizo
           AND e.inliquid = 0 
           AND e.inprejuz = 0
           AND e.tpemprst IN (2) -- POS
           AND e.dtliquid IS NULL;
    COMMIT;
    
    -- Emprestimos Pos tipo 90
    GESTAODERISCO.criarJobsParalelosEmprestimos(pr_cdcooper   => pr_cdcooper
                                               ,pr_idcarga    => vr_idcarga
                                               ,pr_tpemprst   => 2
                                               ,pr_rw_crapdat => pr_rw_crapdat
                                               ,pr_dscritic   => vr_dscritic);
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
    
    --------------------------------  SAIDAS  --------------------------------
    
    -- 
    IF pr_flgsaida THEN
      GESTAODERISCO.gerarSaidasEmprestimos(pr_cdcooper => pr_cdcooper
                                          ,pr_idcarga  => vr_idcarga -- IN
                                          ,pr_idprglog => vr_idprglog
                                          ,pr_rw_crapdat => pr_rw_crapdat
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
      
      -- Testar retorno de erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Gerar erro e roolback
        RAISE vr_exc_erro;
      END IF;
    END IF;
    
    pc_fim_cadeia_central_risco(pr_dtrefere);
    
  END IF;
  
  -- Executar Cartoes Bancoob / BB
  IF pr_flgcarta THEN
    GESTAODERISCO.gerarCargaCartoes(pr_cdcooper => pr_cdcooper
                                   ,pr_idcarga  => vr_idcarga -- IN
                                   ,pr_idprglog => vr_idprglog
                                   ,pr_dtrefere => pr_dtrefere
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
  END IF;
  
  -- Executar Movimentos de Risco de Provisão e Garantia
  IF pr_flggarpr THEN
    GESTAODERISCO.gerarCargaProvisaoGarantia(pr_cdcooper => pr_cdcooper
                                            ,pr_idcarga  => vr_idcarga -- IN
                                            ,pr_dtrefere => pr_dtrefere
                                            ,pr_tpprodut => vr_tpprodut
                                            ,pr_idprglog => vr_idprglog
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_erro;
    END IF;
  END IF;
  
  GESTAODERISCO.gravarFimCarga(pr_cdcooper    => pr_cdcooper
                              ,pr_idcarga     => vr_idcarga
                              ,pr_cdcritic    => vr_cdcritic
                              ,pr_dscritic    => vr_dscritic);
  -- Testar retorno de erro
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Gerar erro e roolback
    RAISE vr_exc_erro;
  END IF;
    
  gravarTempoCentral( pr_cdcooper => pr_cdcooper,
                      pr_cdagenci => 0, 
                      pr_dsmensag => 'Total geraCargaCentral', 
                      pr_dtinicio => vr_dtinproc);

  GESTAODERISCO.gravaLogProcCentral(pr_cdcooper     => pr_cdcooper
                                   ,pr_cdprograma   => vr_cdprograma
                                   ,pr_dscritic     => 'Finalizando carga da Central de Risco para o produto: ' || vr_tpprodut || '.'
                                   ,pr_ind_tipo_log => 1);
  
  -- Finaliza o Processo
  COMMIT;
  
EXCEPTION 
  WHEN vr_exc_erro THEN
  
    -- Se foi retornado apenas codigo
    IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
      -- Buscar a descricao
      vr_dscritic := obterCritica(vr_cdcritic);
    END IF;
    -- Devolvemos codigo e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic ||': '||vr_dscomple;
    
    ROLLBACK;

    GESTAODERISCO.gravarErroCargaCentralRisco(pr_cdcooper => pr_cdcooper
                                             ,pr_idcarga  => vr_idcarga
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
    
    sistema.Gravarlogprograma(pr_cdcooper      => pr_cdcooper,
                              pr_ind_tipo_log  => 3, --Erro
                              pr_des_log       => to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||' --> '||vr_cdprograma||' --> PROGRAMA COM ERRO',
                              pr_cdprograma    => vr_cdprograma,
                              pr_tpexecucao    => 1);      
    
    GESTAODERISCO.gravaLogProcCentral(pr_cdcooper     => pr_cdcooper
                                     ,pr_cdprograma   => vr_cdprograma
                                     ,pr_dscritic     => 'ERRO ao finalizar carga da Central de Risco para o produto: ' || vr_tpprodut || ' - ' || vr_dscritic || ' - ' || dbms_utility.format_error_backtrace
                                     ,pr_ind_tipo_log => 2);
               
    COMMIT; -- commitar o log
  
  WHEN OTHERS THEN
    sistema.excecaoInterna(pr_cdcooper => pr_cdcooper, 
                           pr_compleme => vr_dscomple);
                           
    ROLLBACK;
                               
    pr_dscritic := 'Erro na geraCargaCentral: ' || SQLERRM || ' - ' || dbms_utility.format_error_backtrace;
    
    GESTAODERISCO.gravarErroCargaCentralRisco(pr_cdcooper => pr_cdcooper
                                             ,pr_idcarga  => vr_idcarga
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
     
    sistema.Gravarlogprograma(pr_cdcooper      => pr_cdcooper,
                              pr_ind_tipo_log  => 3, --Erro
                              pr_des_log       => to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||' --> '||vr_cdprograma||' --> PROGRAMA COM ERRO',
                              pr_cdprograma    => vr_cdprograma,
                              pr_tpexecucao    => 1);    

    GESTAODERISCO.gravaLogProcCentral(pr_cdcooper     => pr_cdcooper
                                     ,pr_cdprograma   => vr_cdprograma
                                     ,pr_dscritic     => 'ERRO ao finalizar carga da Central de Risco para o produto: ' || vr_tpprodut || ' - ' || SQLERRM || ' - ' || dbms_utility.format_error_backtrace
                                     ,pr_ind_tipo_log => 2);

    COMMIT; -- commitar o log
END geraCargaCentral;




begin


  geraCargaCentral(pr_cdcooper => 1
                                ,pr_flgexddt => TRUE
                                ,pr_flgsaida => TRUE
                                ,pr_dtrefere => to_date('30/09/2024','dd/mm/rrrr')
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

   IF nvl(vr_cdcritic,0) > 0 or TRIM(vr_dscritic) IS not NULL THEN
     dbms_output.put_line('vr_cdcritic: ' || vr_cdcritic || ' = ' || vr_dscritic);
     ROLLBACK;
   ELSE
     COMMIT;
   END IF;


end;
 
