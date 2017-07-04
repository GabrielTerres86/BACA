CREATE OR REPLACE PROCEDURE CECRED.pc_crps638(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  /*..............................................................................

    Programa: pc_crps638                      Antigo: fontes/crps638.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Lunelli
    Data    : Fevereiro/2013                  Ultima Atualizacao : 05/04/2017

    Dados referente ao programa:

    Frequencia : Diario (Batch).
    Objetivo   : Convenios Sicredi - Relatório de Conciliaçao.
                 Chamado Softdesk 43337.

    Alteracoes : 06/05/2013 - Alteraçao para rodar em cada cooperativa (Lucas).

                 24/05/2013 - Tratamento DARFs (Lucas).

                 03/06/2013 - Correçao format vlrs totais (Lucas).

                 11/06/2013 - Somatória de multas e juros ao campo de
                              valor da fatura e melhorias em consultas
                              (Lucas).

                 14/06/2013 - Correçao listagem DARF SIMPLES (Lucas).

                 19/06/2013 - Quebra de listagem de convenios por segmto (Lucas).

                 24/06/2013 - Rel.636 Totalizaçao por Cooperativa (Lucas).

                 15/08/2013 - Incluir procedure tt-totais para totalizar por
                              convenios e ordenar pela quantidade total maior
                              para menor no rel636 (Lucas R.).

                 23/04/2014 - Alterar campo.crapscn.nrdiaflt por dsdianor
                              Softdesk 142529 (Lucas R.)

                 24/04/2014 - Inclusao de FIELDS para os for craplft e crapcop
                              (Lucas R.)

                 28/04/2014 - Inclusao de deb. automatico para os relatorios
                              crrl634,crrl635,crrl636 Softdesk 149911 (Lucas R.)

                 05/05/2014 - Ajustes migracao Oracle (Elton).

                 17/06/2014 - 135941 Correcao de quebra de pagina e inclusao do
                              campo vltardrf nos fields da crapcop, procedure
                              gera-rel-mensal-cecred (Carlos)

                 06/08/2014 - Ajustes de paginacao e espacamentos no relatorio
                              crrl636, nos totais de DEBITO AUTOMATICO e
                              TOTAL POR MEIO DE ARRECADACAO (Carlos)

                 29/12/2014 - #232620 Correcao na busca dos convenios que nao
                              sao de debito automatico com a inclusao da clausula
                              crapscn.dsoparre <> "E" (Carlos)

                 06/01/2015 - #232620 Correcao do totalizador de receita liquida
                              da cooperativa para deb automatico e totalizadores
                              gerais do relatorio 636 (Carlos)

                 24/02/2015 - Correçao na alimentaçao do campo 'tt-rel634.vltrfuni'
                              (Lunelli - SD 249805)

                 30/04/2015 - Proj. 186 -> Segregacao receita e tarifa em PF e PJ
                              Criacao do novo arquivo AAMMDD_CONVEN_SIC.txt
                              (Guilherme/SUPERO)

                 26/06/2015 - Incluir Format com negativo nos FORMs do rel634 no
                              campo vlrecliq (Lucas Ranghetti #299004)

                 06/07/2015 - Alterar calculo no meio de arrecadacao CAIXA no
                              acumulativo do campo tt-rel634.vlrecliq, pois estava
                              calculando a tarifa errada. (Lucas Ranghetti #302607)

                 21/09/2015 - Incluindo calculo de pagamentos GPS.
                              (André Santos - SUPERO)

                 04/12/2015 - Retirar trecho do codigo onde faz a reversao
                              (Lucas Ranghetti #326987 )

                 11/12/2015 - Adicionar sinal negativo nos campos tot_vlrliqpj e
                             vr_deb_vlrliqpj crrl635 (Lucas Ranghetti #371573 )

                 06/01/2016 - Retirado o valor referente a taxa de GPS do cabecalho
                              do arquivo que vai para o radar. (Lombardi #378512)

                 19/05/2016 - Adicionado negativo no format do f_totais_rel635
                              (Lucas Ranghetti #447067)

                 06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP
                              (Guilherme/SUPERO)

                 07/10/2016 - Alteração do diretório para geração de arquivo contábil.
                             P308 (Ricardo Linhares).

                 13/02/2017 - Conversão Progress para PLSQL (Jonata-MOUTs)
                 
                 31/03/2017 - Inclusão de novas colunas no reltório crrl635 e geração 
                              do arquivo AAMMDD_XX_DESPESASICREDI para o Radar/Martera
                              P307 - (Jonatas - Supero)

                 05/04/2017 - Inclusão do código da Cooperativa no arquivo Contab (Jonata-Mouts)
  ..............................................................................*/

  --------------------- ESTRUTURAS PARA OS RELATÓRIOS ---------------------

  -- Para relatorio 634/635
  TYPE tt_rel63X IS
    RECORD (cdempres    varchar2(10)
           ,tpmeiarr    char(1)
           ,nmconven    varchar2(100)
           ,dsmeiarr    varchar2(100)
           ,qtfatura    number(18)
           ,vltotfat    number(15,2)
           ,vlrecliq    number(15,2)
           ,vlrliqpf    number(15,2) -- Divisao PF/PJ
           ,vlrliqpj    number(15,2) -- Divisao PF/PJ
           ,vltottar    number(15,2)
           ,vltrfsic    number(15,2)
           ,vltrfsic_pf number(15,2)-- Divisao PF/PJ 
           ,vltrfsic_pj number(15,2)-- Divisao PF/PJ                      
           ,vlrtrfpf    number(15,2)-- Divisao PF/PJ
           ,vlrtrfpj    number(15,2)-- Divisao PF/PJ
           ,dsdianor    crapscn.dsdianor%TYPE
           ,nrrenorm    crapscn.nrrenorm%TYPE);
  -- Definicao do tipo de tabela que armazena registros do tipo acima detalhado
  TYPE tt_tab_rel63X IS
    TABLE OF tt_rel63X
      INDEX BY VARCHAR2(50); -- Nome EMpresa(35) + Canal(15)
  -- Mesmo tipo acima, porém precisamos dos registros ordenados por quantiodade de faturas desc 
  TYPE tt_tab_rel63X_qtdade IS
    TABLE OF tt_rel63X
      INDEX BY VARCHAR2(87); -- Id(Debaut ou não - 1) + Quantidade Faturas Empresa (18) + Nome EMpresa(35) + Quantidade Faturas do Canal (18) + Canal(15)
  -- Tipo para armazenar os totais por empresa
  TYPE tt_tot_empresa IS
    TABLE OF NUMBER
      INDEX BY VARCHAR2(10);
  -- Vetores para armazenar as informacoes dos relatórios 
  vr_tab_rel634        tt_tab_rel63X;
  vr_tab_rel635        tt_tab_rel63X;
  vr_tab_rel636        tt_tab_rel63X;
  vr_tab_rel636_qtdade tt_tab_rel63X_qtdade;
  vr_ind_rel63X varchar(50);
  vr_ind_rel636_qtdade varchar(87);
  vr_tab_tot_empresa   tt_tot_empresa; 
  
  -- Vetor para armazenar valores por agencia para o arquivo contabil 
  TYPE vr_vltrpapf IS TABLE OF NUMBER INDEX BY PLS_INTEGER; -- define o tipo do vetor
  TYPE vr_vltrpapj IS TABLE OF NUMBER INDEX BY PLS_INTEGER; -- define o tipo do vetor
  -- Vetores Relatorios
  vr_relvltrpapf vr_vltrpapf;
  vr_relvltrpapj vr_vltrpapj;
  
  -- Tipo para armazenar os associados 
  TYPE typ_reg_crapass IS
    RECORD (nrdconta crapass.nrdconta%TYPE
           ,cdagenci crapass.cdagenci%TYPE
           ,inpessoa crapass.inpessoa%TYPE);
  TYPE typ_tab_crapass IS
    TABLE OF typ_reg_crapass
      INDEX BY BINARY_INTEGER;
  vr_tab_crapass  typ_tab_crapass; 
  
  -- Vetor para armazenar valores por agencia para o arquivo contabil 
  TYPE vr_vltrfsic_pf IS TABLE OF NUMBER INDEX BY PLS_INTEGER; -- define o tipo do vetor
  TYPE vr_vltrfsic_pj IS TABLE OF NUMBER INDEX BY PLS_INTEGER; -- define o tipo do vetor
  -- Vetores Relatorios
  vr_tab_vltrfsic_pf vr_vltrfsic_pf;
  vr_tab_vltrfsic_pj vr_vltrfsic_pj; 
         
  
  ------------------------------- VARIAVEIS -------------------------------

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);


  -- Variável para armazenar as informações para os relatórios
  vr_caminho_coop VARCHAR2(1000);
  vr_caminho_dirX VARCHAR2(1000);
  vr_des_clb      CLOB;
  vr_des_txt      varchar2(32767);

  ---------------- Acumuladores ---------------------

  -- TOTAIS INTERNET
  vr_tpmeiarr_int    crapstn.tpmeiarr%type;
  vr_vltrfuni_int    crapstn.vltrfuni%type;
  vr_int_qttotfat    NUMBER;
  vr_int_vltotfat    number(15,2);
  vr_int_vlrecliq    number(15,2);
  vr_int_vltrfuni    number(15,2);
  vr_int_vltrfsic    number(15,2);
  vr_int_vlrliqpf    number(15,2);
  vr_int_vlrliqpj    number(15,2);
  vr_int_vlrtrfpf    number(15,2);
  vr_int_vlrtrfpj    number(15,2);
  vr_int_vltrfsic_pf number(15,2);
  vr_int_vltrfsic_pj number(15,2);

  -- TOTAIS CAIXA
  vr_tpmeiarr_cxa    crapstn.tpmeiarr%type;
  vr_vltrfuni_cxa    crapstn.vltrfuni%type;
  vr_cax_qttotfat    NUMBER;
  vr_cax_vltotfat    number(15,2);
  vr_cax_vlrecliq    number(15,2);
  vr_cax_vltrfuni    number(15,2);
  vr_cax_vltrfsic    number(15,2);
  vr_cax_vlrliqpf    number(15,2);
  vr_cax_vlrliqpj    number(15,2);
  vr_cax_vlrtrfpf    number(15,2);
  vr_cax_vlrtrfpj    number(15,2);
  vr_cax_vltrfsic_pf number(15,2);
  vr_cax_vltrfsic_pj number(15,2);  

  -- TOTAIS TAA
  vr_tpmeiarr_taa    crapstn.tpmeiarr%type;
  vr_vltrfuni_taa    crapstn.vltrfuni%type;
  vr_taa_qttotfat    NUMBER;
  vr_taa_vltotfat    number(15,2);
  vr_taa_vlrecliq    number(15,2);
  vr_taa_vltrfuni    number(15,2);
  vr_taa_vltrfsic    number(15,2);
  vr_taa_vlrliqpf    number(15,2);
  vr_taa_vlrliqpj    number(15,2);
  vr_taa_vlrtrfpf    number(15,2);
  vr_taa_vlrtrfpj    number(15,2);
  vr_taa_vltrfsic_pf number(15,2);
  vr_taa_vltrfsic_pj number(15,2);  

  -- TOTAIS DEB AUTOMATICO
  vr_deb_qttotfat    NUMBER;
  vr_deb_vltotfat    number(15,2);
  vr_deb_vlrecliq    number(15,2);
  vr_deb_vltrfuni    number(15,2);
  vr_deb_vltrfsic    number(15,2);
  vr_deb_vlrliqpf    number(15,2);
  vr_deb_vlrliqpj    number(15,2);
  vr_deb_vlrtrfpf    number(15,2);
  vr_deb_vlrtrfpj    number(15,2);
  vr_deb_vltrfsic_pf number(15,2);
  vr_deb_vltrfsic_pj number(15,2);  

  -- Outras variaveis
  vr_tot_qttotfat        NUMBER;
  vr_tot_vltrfuni        number(15,2);
  vr_tot_vltotfat        number(15,2);
  vr_tot_vlrecliq        number(15,2);
  vr_tot_vlrtrfpf        number(15,2);
  vr_tot_vlrtrfpf_semgps number(15,2);
  vr_tot_vlrliqpf        number(15,2);
  vr_tot_vlrtrfpj        number(15,2);
  vr_tot_vlrtrfpj_semgps number(15,2);
  vr_tot_vlrliqpj        number(15,2);
  vr_tot_vltrfsic        number(15,2);
  vr_tot_vltrfsic_pf     number(15,2);
  vr_tot_vltrfsic_pj     number(15,2);  


  -- GPS
  vr_dstextab     CRAPTAB.dstextab%TYPE;
  vr_aux_vltfcxcb number(15,2);
  vr_aux_vltfcxsb number(15,2);
  vr_aux_vlrtrfib number(15,2);
  vr_aux_vltargps number(15,2);
  vr_aux_dsempgps VARCHAR2(100);
  vr_aux_dsnomcnv VARCHAR2(100);
  vr_aux_tpmeiarr CHAR(1);
  vr_aux_dsmeiarr VARCHAR2(100);

  -- Auxiliares para o processamento 
  vr_dtmvtolt     DATE;
  vr_cdcooper     NUMBER;
  vr_aux_datainic DATE;
  vr_aux_datafina DATE;
  vr_aux_vltarfat NUMBER(15,2);

  -- Variaveis para o arquivo contabil
  vr_con_dtmvtolt       VARCHAR2(100);
  vr_aux_linhadet       VARCHAR2(150);
  vr_aux_nmarqdat       VARCHAR2(1000);

  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS638';

  ---------------------------------- CURSORES  ----------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.cdcooper
          ,cop.nmrescop
          ,cop.vltardrf
      FROM crapcop cop
     WHERE cop.cdcooper = DECODE(pr_cdcooper,0,cop.cdcooper,pr_cdcooper) -- Se passado zero, traz todas 
       AND cop.flgativo = 1; -- SOmente ativas

  --Selecionar informacoes dos associados
  CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE) IS
    SELECT  /*+ INDEX (crapass crapass##crapass7) */
          crapass.nrdconta
         ,crapass.cdagenci
         ,crapass.inpessoa
     FROM crapass crapass
    WHERE crapass.cdcooper = pr_cdcooper;
     
  -- Busca tarifas SICREDI
  CURSOR cr_crapthi(pr_cdcooper crapthi.Cdcooper%type
                   ,pr_cdhistor crapthi.cdhistor%type)is

    SELECT vltarifa
      FROM crapthi
     WHERE cdcooper = pr_cdcooper
       AND cdhistor = pr_cdhistor
       AND dsorigem = 'AYLLOS';
  vr_vltarifa_1154 crapthi.vltarifa%TYPE;
  vr_vltarifa_1019 crapthi.vltarifa%TYPE;
  vr_vltarifa_1414 crapthi.vltarifa%TYPE;

  -- Leitura dos convênios e DARFs
  CURSOR cr_craplft(pr_cdcooper crapcop.cdcooper%type
                   ,pr_dtmvtolt craplft.dtvencto%type) IS
    SELECT cdtribut
          ,cdempcon
          ,cdsegmto
          ,tpfatura
          ,vllanmto
          ,vlrmulta
          ,vlrjuros
          ,nrdconta
          ,cdagenci
          ,Count (1)
            OVER (PARTITION BY cdtribut,cdempcon,cdsegmto) qtdregis
          ,ROW_NUMBER ()
            OVER (PARTITION BY cdtribut,cdempcon,cdsegmto ORDER BY cdtribut,cdempcon,cdsegmto) nrseqreg
      FROM craplft
     WHERE cdcooper  = pr_cdcooper
       AND dtvencto  = pr_dtmvtolt
       AND insitfat  = 2
       AND cdhistor  = 1154 -- SICREDI
     ORDER BY cdtribut
             ,cdempcon
             ,cdsegmto;

  -- Busca da empresa da arrecadação
  CURSOR cr_crapscn(pr_cdempcon crapscn.cdempcon%type
                   ,pr_cdsegmto crapscn.cdsegmto%type) is
    SELECT cdempres
          ,dsnomcnv
          ,dsdianor
          ,nrrenorm
      FROM crapscn
     WHERE pr_cdempcon IN(cdempcon,cdempco2) -- Pode ser a primeira ou segunda
       AND cdsegmto = pr_cdsegmto
       AND dtencemp is null
       AND dsoparre <> 'E' -- DEBAUT
     ORDER BY DECODE(cdempcon,pr_cdempcon,1,2); -- Trazer primeiro os registros com cdempcon igual e depoois cdempco2
  rw_crapscn cr_crapscn%rowtype;

  -- Busca de tributo
  CURSOR cr_crapscn_tribut(pr_cdempres crapscn.cdempres%type) IS
    SELECT cdempres
          ,dsnomcnv
          ,dsdianor
          ,nrrenorm
      FROM crapscn
     WHERE cdempres = pr_cdempres;

  -- Configuração transação convênio Internet
  CURSOR cr_crapstn_inet(pr_cdempres crapstn.cdempres%type) IS
    SELECT tpmeiarr
          ,vltrfbru
          ,vltrfuni
          ,vltarifa
      FROM crapstn
     WHERE cdempres = pr_cdempres
       AND tpmeiarr = 'D'
       AND ( (cdempres = 'K0' AND cdtransa = '0XY')
            OR
             (cdempres = '147' AND cdtransa = '1CK')
            OR cdempres NOT IN('K0','147')
           );

  -- Configuração transação convenio Caixa ou TAA
  CURSOR cr_crapstn(pr_cdempres crapstn.cdempres%type
                   ,pr_tpmeiarr crapstn.tpmeiarr%type) IS
    SELECT tpmeiarr
          ,vltrfbru
          ,vltrfuni
          ,vltarifa
      FROM crapstn
     WHERE cdempres = pr_cdempres
       AND tpmeiarr = pr_tpmeiarr;
  rw_crapstn  cr_crapstn%rowtype;

  -- Busca dos lancamentos de Debito Automatico
  CURSOR cr_craplcm(pr_cdcooper craplcm.cdcooper%type
                   ,pr_dtmvtolt craplcm.dtmvtolt%type) is
    SELECT lau.cdempres
          ,lcm.nrdconta
          ,lcm.cdagenci
          ,lcm.vllanmto
          ,ROW_NUMBER ()
            OVER (PARTITION BY lau.cdempres ORDER BY lau.cdempres) nrseqreg
      FROM craplau lau
          ,craplcm lcm
     WHERE lcm.cdcooper = pr_cdcooper
       AND lcm.cdhistor = 1019
       AND lcm.dtmvtolt = pr_dtmvtolt
       AND lau.cdcooper = lcm.cdcooper
       AND lau.cdhistor = lcm.cdhistor
       AND lau.nrdocmto = lcm.nrdocmto
       AND lau.nrdconta = lcm.nrdconta
       AND lau.cdagenci = lcm.cdagenci
       AND lau.dtmvtopg = lcm.dtmvtolt
     ORDER BY lau.cdempres;

  -- Busca da empresa quando debito automatico
  CURSOR cr_crapscn_debaut(pr_cdempres crapscn.cdempres%type) IS
    SELECT scn.dsnomcnv
          ,scn.dsdianor
          ,scn.nrrenorm
          ,stn.tpmeiarr
          ,stn.vltrfuni
          ,scn.cdempres
      FROM crapscn scn
          ,crapstn stn
     WHERE scn.dsoparre = 'E'
       AND scn.cddmoden IN('A','C')
       AND scn.cdempres = pr_cdempres
       AND stn.tpmeiarr = 'E'
       AND scn.cdempres = stn.cdempres;
  rw_crapscn_debaut cr_crapscn_debaut%rowtype;

  -- Busca dos lancamentos de GPS
  CURSOR cr_craplgp(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_dtmvtolt craplgp.dtmvtolt%type) is
    SELECT lgp.cdcooper
          ,lgp.cdagenci
          ,lgp.tpdpagto
          ,lgp.vlrtotal
          ,lgp.inpesgps
          ,lgp.nrctapag
          ,ROW_NUMBER ()
            OVER (PARTITION BY lgp.cdcooper ORDER BY lgp.cdcooper) nrseqreg
      FROM craplgp lgp
     WHERE lgp.cdcooper <> 3
       AND lgp.cdcooper = pr_cdcooper -- Na central busca todas
       AND lgp.dtmvtolt = pr_dtmvtolt
       AND lgp.idsicred <> 0
       AND lgp.flgativo = 1
     ORDER BY lgp.cdcooper;

  ------------------------------- REGISTROS -------------------------------
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  ------------------------- PROCEDIMENTOS INTERNOS -----------------------------
  PROCEDURE pc_insere_tabrel(pr_dtmvtolt IN DATE
                            ,pr_nmconven VARCHAR2
                            ,pr_cdempres VARCHAR2
                            ,pr_tpmeiarr CHAR
                            ,pr_dsdianor crapscn.dsdianor%TYPE
                            ,pr_nrrenorm crapscn.nrrenorm%TYPE
                            ,pr_qtfatura NUMBER 
                            ,pr_vltotfat NUMBER
                            ,pr_vltrfuni crapstn.vltrfuni%TYPE
                            ,pr_vltarifa crapthi.vltarifa%TYPE
                            ,pr_dsmeiarr VARCHAR2
                            ,pr_nrdconta IN NUMBER default 0
                            ,pr_inpessoa IN NUMBER default 0
                            ,pr_cdagenci IN NUMBER DEFAULT 0) IS 
    -- Tipo de pessoa 
    vr_aux_inpessoa number;
    -- Agencia
    vr_aux_cdagenci NUMBER;
  BEGIN 
    -- Montar indice para gravação na(s) PLTABLE(s)
    vr_ind_rel63X := RPAD(pr_nmconven,35,' ')||RPAD(pr_dsmeiarr,15,' ');
    -- 634 emite somente o dial atual 
    IF rw_crapdat.dtmvtolt = pr_dtmvtolt THEN 
      -- Se já existe registro
      IF vr_tab_rel634.exists(vr_ind_rel63X) then
        -- Apenas acumularemos
        vr_tab_rel634(vr_ind_rel63X).qtfatura := vr_tab_rel634(vr_ind_rel63X).qtfatura + pr_qtfatura;
        vr_tab_rel634(vr_ind_rel63X).vltotfat := vr_tab_rel634(vr_ind_rel63X).vltotfat + pr_vltotfat;
        vr_tab_rel634(vr_ind_rel63X).vltottar := vr_tab_rel634(vr_ind_rel63X).vltottar + (pr_vltrfuni * pr_qtfatura);
        vr_tab_rel634(vr_ind_rel63X).vlrecliq := vr_tab_rel634(vr_ind_rel63X).vlrecliq + ((pr_vltrfuni * pr_qtfatura) - (pr_qtfatura * pr_vltarifa));
      ELSE
        -- Criar um registro no vetor de Rel634
        vr_tab_rel634(vr_ind_rel63X).nmconven := SUBSTR(pr_nmconven,1,30);
        vr_tab_rel634(vr_ind_rel63X).cdempres := pr_cdempres;
        vr_tab_rel634(vr_ind_rel63X).tpmeiarr := pr_tpmeiarr;
        vr_tab_rel634(vr_ind_rel63X).dsdianor := pr_dsdianor;
        vr_tab_rel634(vr_ind_rel63X).nrrenorm := pr_nrrenorm;
        vr_tab_rel634(vr_ind_rel63X).qtfatura := pr_qtfatura;
        vr_tab_rel634(vr_ind_rel63X).vltotfat := pr_vltotfat;
        vr_tab_rel634(vr_ind_rel63X).vltottar := (pr_vltrfuni * pr_qtfatura);
        vr_tab_rel634(vr_ind_rel63X).vlrecliq := vr_tab_rel634(vr_ind_rel63X).vltottar - (pr_qtfatura * pr_vltarifa);
        vr_tab_rel634(vr_ind_rel63X).dsmeiarr := substr(pr_dsmeiarr,1,8);
      END IF;
      -- Tarifa Sicredi 
      IF vr_tab_rel634(vr_ind_rel63X).vlrecliq < 0 THEN  
        vr_tab_rel634(vr_ind_rel63X).vltrfsic := vr_tab_rel634(vr_ind_rel63X).vltottar;
      ELSE 
        vr_tab_rel634(vr_ind_rel63X).vltrfsic := vr_tab_rel634(vr_ind_rel63X).vltottar - vr_tab_rel634(vr_ind_rel63X).vlrecliq;
      END IF; 
    END IF;
    -- 635 e 636 emite todos os dias do mês e somente é alimentada no processo mensal 
    IF TRUNC(rw_crapdat.dtmvtolt,'mm') <> TRUNC(rw_crapdat.dtmvtopr,'mm') THEN 
      -- 635 só é alimentada quando a execução não for na Central
      IF pr_cdcooper <> 3 THEN 
        -- Se já existe registro
        IF vr_tab_rel635.exists(vr_ind_rel63X) then
          -- Apenas acumularemos
          vr_tab_rel635(vr_ind_rel63X).qtfatura := vr_tab_rel635(vr_ind_rel63X).qtfatura + pr_qtfatura;
          vr_tab_rel635(vr_ind_rel63X).vltotfat := vr_tab_rel635(vr_ind_rel63X).vltotfat + pr_vltotfat;
          vr_tab_rel635(vr_ind_rel63X).vltottar := vr_tab_rel635(vr_ind_rel63X).vltottar + (pr_vltrfuni * pr_qtfatura);
          vr_tab_rel635(vr_ind_rel63X).vlrecliq := vr_tab_rel635(vr_ind_rel63X).vlrecliq + ((pr_vltrfuni * pr_qtfatura) - (pr_qtfatura * pr_vltarifa));
        ELSE
          -- Criar um registro no vetor de Rel635
          vr_tab_rel635(vr_ind_rel63X).nmconven := pr_nmconven;
          vr_tab_rel635(vr_ind_rel63X).cdempres := pr_cdempres;
          vr_tab_rel635(vr_ind_rel63X).tpmeiarr := pr_tpmeiarr;
          vr_tab_rel635(vr_ind_rel63X).dsdianor := pr_dsdianor;
          vr_tab_rel635(vr_ind_rel63X).nrrenorm := pr_nrrenorm;
          vr_tab_rel635(vr_ind_rel63X).qtfatura := pr_qtfatura;
          vr_tab_rel635(vr_ind_rel63X).vltotfat := pr_vltotfat;
          vr_tab_rel635(vr_ind_rel63X).vltottar := (pr_vltrfuni * pr_qtfatura);
          vr_tab_rel635(vr_ind_rel63X).vlrtrfpf := 0;
          vr_tab_rel635(vr_ind_rel63X).vlrtrfpj := 0; 
          vr_tab_rel635(vr_ind_rel63X).vlrecliq := vr_tab_rel635(vr_ind_rel63X).vltottar - (pr_qtfatura * pr_vltarifa);
          vr_tab_rel635(vr_ind_rel63X).vlrliqpf := 0; 
          vr_tab_rel635(vr_ind_rel63X).vlrliqpj := 0; 
          vr_tab_rel635(vr_ind_rel63X).dsmeiarr := pr_dsmeiarr;
          vr_tab_rel635(vr_ind_rel63X).vltrfsic_pf := 0;
          vr_tab_rel635(vr_ind_rel63X).vltrfsic_pj := 0;
        END IF;
        -- Tarifa Sicredi 
        IF vr_tab_rel635(vr_ind_rel63X).vlrecliq < 0 THEN  
          vr_tab_rel635(vr_ind_rel63X).vltrfsic := vr_tab_rel635(vr_ind_rel63X).vltottar;
        ELSE 
          vr_tab_rel635(vr_ind_rel63X).vltrfsic := vr_tab_rel635(vr_ind_rel63X).vltottar - vr_tab_rel635(vr_ind_rel63X).vlrecliq;
        END IF;      
        
        -- Tratamento PF / PJ 
        IF pr_inpessoa = 0 THEN 
          -- Buscaremos do cadastro do associado 
          IF vr_tab_crapass.EXISTS(pr_nrdconta) THEN 
            vr_aux_inpessoa := vr_tab_crapass(pr_nrdconta).inpessoa;
          ELSE 
            vr_aux_inpessoa := 1; -- Default 1 quando não encontrar 
          END IF;
        ELSE 
          -- Usaremos o tipo de pessoa passado 
          vr_aux_inpessoa := pr_inpessoa;
        END IF;
        -- Buscar agencia
        vr_aux_cdagenci := 0;
        IF vr_tab_crapass.exists(pr_nrdconta) THEN 
          vr_aux_cdagenci := vr_tab_crapass(pr_nrdconta).cdagenci;   
        ELSE
          -- Usaremos o gravado no registro do lançamento
          vr_aux_cdagenci := pr_cdagenci;
        END IF;
        
        -- Gravar conforme tipo de pessoa 
        IF vr_aux_inpessoa = 1 THEN
          -- Gravar nos campos de PF         
          vr_tab_rel635(vr_ind_rel63X).vlrtrfpf := vr_tab_rel635(vr_ind_rel63X).vlrtrfpf + (pr_vltrfuni * pr_qtfatura);
          vr_tab_rel635(vr_ind_rel63X).vlrliqpf := vr_tab_rel635(vr_ind_rel63X).vlrliqpf + (pr_vltrfuni * pr_qtfatura) - (pr_qtfatura * pr_vltarifa);
          
          IF vr_tab_rel635(vr_ind_rel63X).vlrliqpf < 0 THEN  
            vr_tab_rel635(vr_ind_rel63X).vltrfsic_pf := vr_tab_rel635(vr_ind_rel63X).vlrtrfpf;
          ELSE 
            vr_tab_rel635(vr_ind_rel63X).vltrfsic_pf := vr_tab_rel635(vr_ind_rel63X).vlrtrfpf - vr_tab_rel635(vr_ind_rel63X).vlrliqpf;
          END IF;  
                   
          
          --Acumular valor tarifa sicredi por pessoa fisica
          IF ((pr_vltrfuni * pr_qtfatura) - (pr_qtfatura * pr_vltarifa)) < 0 THEN
          
            IF NOT vr_tab_vltrfsic_pf.exists(vr_aux_cdagenci) THEN
              vr_tab_vltrfsic_pf(vr_aux_cdagenci) := pr_vltrfuni * pr_qtfatura;
            ELSE 
              vr_tab_vltrfsic_pf(vr_aux_cdagenci) := vr_tab_vltrfsic_pf(vr_aux_cdagenci) + (pr_vltrfuni * pr_qtfatura);
            END IF;
            
          ELSE
            
            IF NOT vr_tab_vltrfsic_pf.exists(vr_aux_cdagenci) THEN
              vr_tab_vltrfsic_pf(vr_aux_cdagenci) := (pr_vltrfuni * pr_qtfatura) - (((pr_vltrfuni * pr_qtfatura) - (pr_qtfatura * pr_vltarifa)));
            ELSE 
              vr_tab_vltrfsic_pf(vr_aux_cdagenci) := vr_tab_vltrfsic_pf(vr_aux_cdagenci) + ((pr_vltrfuni * pr_qtfatura) - (((pr_vltrfuni * pr_qtfatura) - (pr_qtfatura * pr_vltarifa))));
            END IF;

          END IF;          
          
          -- Tratar informações para o arquivo contabil quando não for GPS 
          IF SUBSTR(pr_nmconven,1,3) <> 'GPS' THEN           
            IF NOT vr_relvltrpapf.exists(vr_aux_cdagenci) THEN 
              -- Criar 
              vr_relvltrpapf(vr_aux_cdagenci) := pr_vltrfuni * pr_qtfatura;
            ELSE 
              -- Acumular 
              vr_relvltrpapf(vr_aux_cdagenci) := vr_relvltrpapf(vr_aux_cdagenci) + (pr_vltrfuni * pr_qtfatura);
            END IF;  
          END IF;  
        ELSE
          -- Gravar nos campos de PJ         
          vr_tab_rel635(vr_ind_rel63X).vlrtrfpj := vr_tab_rel635(vr_ind_rel63X).vlrtrfpj + (pr_vltrfuni * pr_qtfatura);
          vr_tab_rel635(vr_ind_rel63X).vlrliqpj := vr_tab_rel635(vr_ind_rel63X).vlrliqpj + (pr_vltrfuni * pr_qtfatura) - (pr_qtfatura * pr_vltarifa);

          IF vr_tab_rel635(vr_ind_rel63X).vlrliqpj < 0 THEN  
            vr_tab_rel635(vr_ind_rel63X).vltrfsic_pj := vr_tab_rel635(vr_ind_rel63X).vlrtrfpj;
          ELSE 
            vr_tab_rel635(vr_ind_rel63X).vltrfsic_pj := vr_tab_rel635(vr_ind_rel63X).vlrtrfpj - vr_tab_rel635(vr_ind_rel63X).vlrliqpj;
          END IF; 
          
          --Acumular valor tarifa sicredi por pessoa fisica
          IF ((pr_vltrfuni * pr_qtfatura) - (pr_qtfatura * pr_vltarifa)) < 0 THEN
          
            IF NOT vr_tab_vltrfsic_pj.exists(vr_aux_cdagenci) THEN
              vr_tab_vltrfsic_pj(vr_aux_cdagenci) := pr_vltrfuni * pr_qtfatura;
            ELSE 
              vr_tab_vltrfsic_pj(vr_aux_cdagenci) := vr_tab_vltrfsic_pj(vr_aux_cdagenci) + (pr_vltrfuni * pr_qtfatura);
            END IF;
            
          ELSE
            
            IF NOT vr_tab_vltrfsic_pj.exists(vr_aux_cdagenci) THEN
              vr_tab_vltrfsic_pj(vr_aux_cdagenci) := (pr_vltrfuni * pr_qtfatura) - (((pr_vltrfuni * pr_qtfatura) - (pr_qtfatura * pr_vltarifa)));
            ELSE 
              vr_tab_vltrfsic_pj(vr_aux_cdagenci) := vr_tab_vltrfsic_pj(vr_aux_cdagenci) + ((pr_vltrfuni * pr_qtfatura) - (((pr_vltrfuni * pr_qtfatura) - (pr_qtfatura * pr_vltarifa))));
            END IF;

          END IF; 
          
          -- Tratar informações para o arquivo contabil quando não for GPS 
          IF SUBSTR(pr_nmconven,1,3) <> 'GPS' THEN           
            IF NOT vr_relvltrpapj.exists(vr_aux_cdagenci) THEN 
              -- Criar 
              vr_relvltrpapj(vr_aux_cdagenci) := pr_vltrfuni * pr_qtfatura;
            ELSE 
              -- Acumular 
              vr_relvltrpapj(vr_aux_cdagenci) := vr_relvltrpapj(vr_aux_cdagenci) + (pr_vltrfuni * pr_qtfatura);
            END IF;  
          END IF;  
        END IF;
      ELSE
        -- 636 só é alimentado na execução mensal e na Cecred 
        -- Se já existe registro
        IF vr_tab_rel636.exists(vr_ind_rel63X) then
          -- Apenas acumularemos
          vr_tab_rel636(vr_ind_rel63X).qtfatura := vr_tab_rel636(vr_ind_rel63X).qtfatura + pr_qtfatura;
          vr_tab_rel636(vr_ind_rel63X).vltotfat := vr_tab_rel636(vr_ind_rel63X).vltotfat + pr_vltotfat;
          vr_tab_rel636(vr_ind_rel63X).vltottar := vr_tab_rel636(vr_ind_rel63X).vltottar + (pr_vltrfuni * pr_qtfatura);
          vr_tab_rel636(vr_ind_rel63X).vlrecliq := vr_tab_rel636(vr_ind_rel63X).vlrecliq + ((pr_vltrfuni * pr_qtfatura) - (pr_qtfatura * pr_vltarifa));
        ELSE
          -- Criar um registro no vetor de Rel636
          vr_tab_rel636(vr_ind_rel63X).nmconven := SUBSTR(pr_nmconven,1,30);
          vr_tab_rel636(vr_ind_rel63X).cdempres := pr_cdempres;
          vr_tab_rel636(vr_ind_rel63X).tpmeiarr := pr_tpmeiarr;
          vr_tab_rel636(vr_ind_rel63X).dsdianor := pr_dsdianor;
          vr_tab_rel636(vr_ind_rel63X).nrrenorm := pr_nrrenorm;
          vr_tab_rel636(vr_ind_rel63X).qtfatura := pr_qtfatura;
          vr_tab_rel636(vr_ind_rel63X).vltotfat := pr_vltotfat;
          vr_tab_rel636(vr_ind_rel63X).vltottar := (pr_vltrfuni * pr_qtfatura);
          vr_tab_rel636(vr_ind_rel63X).vlrecliq := vr_tab_rel636(vr_ind_rel63X).vltottar - (pr_qtfatura * pr_vltarifa);
          vr_tab_rel636(vr_ind_rel63X).dsmeiarr := substr(pr_dsmeiarr,1,8);
        END IF;
        -- Tarifa Sicredi 
        IF vr_tab_rel636(vr_ind_rel63X).vlrecliq < 0 THEN  
          vr_tab_rel636(vr_ind_rel63X).vltrfsic := vr_tab_rel636(vr_ind_rel63X).vltottar;
        ELSE 
          vr_tab_rel636(vr_ind_rel63X).vltrfsic := vr_tab_rel636(vr_ind_rel63X).vltottar - vr_tab_rel636(vr_ind_rel63X).vlrecliq;
        END IF;
        -- Acumular total da empresa
        IF vr_tab_tot_empresa.exists(pr_cdempres) THEN
          vr_tab_tot_empresa(pr_cdempres) := vr_tab_tot_empresa(pr_cdempres) + pr_qtfatura;
        ELSE
          vr_tab_tot_empresa(pr_cdempres) := pr_qtfatura;
        END IF;  
      END IF;  
    END IF;  
  END;
  

  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF nvl(vr_cdcritic,0) <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    --Carregar tabela memoria de associados somente quando a execução não for na Central
    --e também nao executar fora do processo mensal 
    IF pr_cdcooper <> 3 AND trunc(rw_crapdat.dtmvtolt,'mm') <> trunc(rw_crapdat.dtmvtopr,'mm') THEN 
      FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapass(rw_crapass.nrdconta).nrdconta := rw_crapass.nrdconta;
        vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
      END LOOP;
    END IF;  
    

    /* Tipos de Arrecadaçao SICREDI
       --> A - ATM
       --> B - Correspondente Bancário
       --> C - Caixa
       --> D - Internet Banking
       --> E - Debito Auto
       --> F - Arquivo de Pagamento (CNAB 240)  */

    -- Se processo mensal
    IF trunc(rw_crapdat.dtmvtolt,'mm') <> trunc(rw_crapdat.dtmvtopr,'mm') THEN 
      -- Iremos buscar todo o mês em questão 
      vr_aux_datainic := rw_crapdat.dtinimes;
      vr_aux_datafina := rw_crapdat.dtultdia;
    ELSE
      -- Iremos buscar somente o dia em questão 
      vr_aux_datainic := rw_crapdat.dtmvtolt;
      vr_aux_datafina := rw_crapdat.dtmvtolt;
    END IF;
    
    -- Na Central buscaremos todas as Cooperativas singulares
    IF pr_cdcooper = 3 THEN 
      vr_cdcooper := 0;
    ELSE 
      -- Do contrario buscamos somente a singular em execução
      vr_cdcooper := pr_cdcooper;
    END IF;
    
    -- Efetuar laço buscando todas as cooperativas (Quando execução Central)
    -- ou buscar somente a Cooperativa atual (QUando execução fora da Central)
    FOR rw_crapcop IN cr_crapcop(vr_cdcooper) LOOP
      
      -- Buscar tarifas SICREDI e DEBITO AUTOMATICO
      FOR rw_crapthi IN cr_crapthi(rw_crapcop.cdcooper,1154) LOOP
        vr_vltarifa_1154 := rw_crapthi.vltarifa;
      END LOOP;
      FOR rw_crapthi IN cr_crapthi(rw_crapcop.cdcooper,1019) LOOP
        vr_vltarifa_1019 := rw_crapthi.vltarifa;
      END LOOP;
    
      -- Efetuar laço do intervalo solicitado conforme calculo acima 
      vr_dtmvtolt := gene0005.fn_valida_dia_util(3,vr_aux_datainic);
      
      LOOP
        EXIT WHEN vr_dtmvtolt > vr_aux_datafina;  
      
        -- Leitura para Convenios e DARFs
        FOR rw_craplft IN cr_craplft(rw_crapcop.cdcooper
                                    ,vr_dtmvtolt) loop

          -- A cada quebra Tributo, Empresa ou Segmento
          IF rw_craplft.nrseqreg = 1 THEN
            -- Reiniciar contadores e valores cfme canal
            vr_tpmeiarr_int := null;
            vr_vltrfuni_int := 0;
            vr_tpmeiarr_taa := null;
            vr_vltrfuni_taa := 0;
            vr_tpmeiarr_cxa := null;
            vr_vltrfuni_cxa := 0;
            
            -- Busca cadastro da empresa / tributo
            IF rw_craplft.tpfatura <> 2 OR rw_craplft.cdempcon <> 0  THEN
              -- Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras
              OPEN cr_crapscn(rw_craplft.cdempcon
                             ,TO_CHAR(rw_craplft.cdsegmto));
              FETCH cr_crapscn
               INTO rw_crapscn;
              -- Se não encontrar
              IF cr_crapscn%notfound THEN
                CLOSE cr_crapscn;
                -- Ignorar o registro
                CONTINUE;
              ELSE
                CLOSE cr_crapscn;
              END IF;
            -- DARF SIMPLES
            ELSIF rw_craplft.cdtribut = '6106' THEN
              OPEN cr_crapscn_tribut('D0');
              FETCH cr_crapscn_tribut
               INTO rw_crapscn;
              -- Se não encontrar
              IF cr_crapscn_tribut%NOTFOUND THEN
                CLOSE cr_crapscn_tribut;
                -- Ignorar o registro
                CONTINUE;
              ELSE
                CLOSE cr_crapscn_tribut;
              END IF;
            -- DARF PRETO EUROPA
            ELSE
              OPEN cr_crapscn_tribut('A0');
              FETCH cr_crapscn_tribut
               INTO rw_crapscn;
              -- Se não encontrar
              IF cr_crapscn_tribut%NOTFOUND THEN
                CLOSE cr_crapscn_tribut;
                -- Ignorar o registro
                CONTINUE;
              ELSE
                CLOSE cr_crapscn_tribut;
              END IF;
            END IF; -- Fim Empresa/Tributos
            
            -- Busca configuração canal INTERNET
            OPEN cr_crapstn_inet(rw_crapscn.cdempres);
            FETCH cr_crapstn_inet
             INTO rw_crapstn;
            -- Se não encontrar
            IF cr_crapstn_inet%notfound THEN
              -- Apenas fechamos o cursor e prosseguimos
              CLOSE cr_crapstn_inet;
            ELSE
              CLOSE cr_crapstn_inet;
              -- Armazenamos
              vr_tpmeiarr_int := rw_crapstn.tpmeiarr;
              vr_vltrfuni_int := rw_crapstn.vltrfuni;
            END IF;  
            -- Busca configuração TAA 
            OPEN cr_crapstn(rw_crapscn.cdempres,'A');
            FETCH cr_crapstn
             INTO rw_crapstn;
            -- Se não encontrar
            IF cr_crapstn%notfound THEN
              -- Apenas fechamos o cursor e prosseguimos
              CLOSE cr_crapstn;
            ELSE
              CLOSE cr_crapstn;            
              -- Armazenamos
              vr_tpmeiarr_taa := rw_crapstn.tpmeiarr;
              vr_vltrfuni_taa := rw_crapstn.vltrfuni;
            END IF;  
            -- Busca configuração Caixa 
            OPEN cr_crapstn(rw_crapscn.cdempres,'C');
            FETCH cr_crapstn
             INTO rw_crapstn;
            -- Se não encontrar
            IF cr_crapstn%notfound THEN
              -- Apenas fechamos o cursor e prosseguimos
              CLOSE cr_crapstn;
            ELSE
              CLOSE cr_crapstn;
              -- Armazenamos
              vr_tpmeiarr_cxa := rw_crapstn.tpmeiarr;
              vr_vltrfuni_cxa := rw_crapstn.vltrfuni;
            END IF;
          END IF; -- Fim Mudança Quebra
          
          -- Se ler DARF NUMERADO ou DAS assumir tarifa de 0.16
          IF rw_craplft.tpfatura >= 1 THEN
            vr_aux_vltarfat := rw_crapcop.vltardrf; -- 0.16 era o valor antigo
          ELSE
            vr_aux_vltarfat := vr_vltarifa_1154;
          END IF;

          -- Armazenar os valores na pltable conforme o canal, 
          -- isso se houve encontro da configuração (CRAPSTN)
          IF rw_craplft.cdagenci = 90 AND vr_tpmeiarr_int IS NOT NULL THEN 
            -- Internet 
            pc_insere_tabrel(pr_dtmvtolt => vr_dtmvtolt
                            ,pr_nmconven => rw_crapscn.dsnomcnv
                            ,pr_cdempres => rw_crapscn.cdempres
                            ,pr_tpmeiarr => vr_tpmeiarr_int
                            ,pr_dsdianor => rw_crapscn.dsdianor
                            ,pr_nrrenorm => rw_crapscn.nrrenorm
                            ,pr_qtfatura => 1
                            ,pr_vltotfat => rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros
                            ,pr_vltrfuni => vr_vltrfuni_int
                            ,pr_vltarifa => vr_aux_vltarfat
                            ,pr_dsmeiarr => 'INTERNET'
                            ,pr_nrdconta => rw_craplft.nrdconta
                            ,pr_cdagenci => rw_craplft.cdagenci);
          ELSIF rw_craplft.cdagenci = 91 AND vr_tpmeiarr_taa IS NOT NULL THEN
            -- TAA
            pc_insere_tabrel(pr_dtmvtolt => vr_dtmvtolt
                            ,pr_nmconven => rw_crapscn.dsnomcnv
                            ,pr_cdempres => rw_crapscn.cdempres
                            ,pr_tpmeiarr => vr_tpmeiarr_taa
                            ,pr_dsdianor => rw_crapscn.dsdianor
                            ,pr_nrrenorm => rw_crapscn.nrrenorm
                            ,pr_qtfatura => 1
                            ,pr_vltotfat => rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros
                            ,pr_vltrfuni => vr_vltrfuni_taa
                            ,pr_vltarifa => vr_vltarifa_1154
                            ,pr_dsmeiarr => 'TAA'
                            ,pr_nrdconta => rw_craplft.nrdconta
                            ,pr_cdagenci => rw_craplft.cdagenci);
          ELSIF vr_tpmeiarr_cxa IS NOT NULL THEN 
            -- Caixa
            pc_insere_tabrel(pr_dtmvtolt => vr_dtmvtolt
                            ,pr_nmconven => rw_crapscn.dsnomcnv
                            ,pr_cdempres => rw_crapscn.cdempres
                            ,pr_tpmeiarr => vr_tpmeiarr_cxa
                            ,pr_dsdianor => rw_crapscn.dsdianor
                            ,pr_nrrenorm => rw_crapscn.nrrenorm
                            ,pr_qtfatura => 1
                            ,pr_vltotfat => rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros
                            ,pr_vltrfuni => vr_vltrfuni_cxa
                            ,pr_vltarifa => vr_aux_vltarfat
                            ,pr_dsmeiarr => 'CAIXA'
                            ,pr_nrdconta => rw_craplft.nrdconta
                            ,pr_cdagenci => rw_craplft.cdagenci);
          END IF;
        END LOOP; -- FOR EACH craplft

        -- Leitura dos lancamentos em Conta Corrente Debito Automatico
        FOR rw_craplcm IN cr_craplcm(rw_crapcop.cdcooper,
                                     vr_dtmvtolt) loop
          -- Somente no primeiro registro da Empresa
          IF rw_craplcm.nrseqreg = 1 THEN
            -- Garantir que a empresa seja de debito automatico
            OPEN cr_crapscn_debaut(rw_craplcm.cdempres);
            FETCH cr_crapscn_debaut
             INTO rw_crapscn_debaut;
            -- Somente se encontrou
            IF cr_crapscn_debaut%NOTFOUND THEN
              -- Limpar rowtype para evitar sujeira de registros anterior
              rw_crapscn_debaut := null;
            END IF;
            -- Fechar cursor
            CLOSE cr_crapscn_debaut;
          END IF;
                   
          -- Se houve encontro da CRAPSCN 
          IF rw_crapscn_debaut.cdempres IS NOT NULL THEN 
            -- Chamar rotina para gravação em pltable
            pc_insere_tabrel(pr_dtmvtolt => vr_dtmvtolt
                            ,pr_nmconven => rw_crapscn_debaut.dsnomcnv
                            ,pr_cdempres => rw_crapscn_debaut.cdempres
                            ,pr_tpmeiarr => 'E'
                            ,pr_dsdianor => rw_crapscn_debaut.dsdianor
                            ,pr_nrrenorm => rw_crapscn_debaut.nrrenorm
                            ,pr_qtfatura => 1
                            ,pr_vltotfat => rw_craplcm.vllanmto
                            ,pr_vltrfuni => rw_crapscn_debaut.vltrfuni
                            ,pr_vltarifa => vr_vltarifa_1019
                            ,pr_dsmeiarr => 'DEB. AUTOMATICO'
                            ,pr_nrdconta => rw_craplcm.nrdconta
                            ,pr_cdagenci => rw_craplcm.cdagenci);
          END IF;
        END LOOP;

        -- Busca de GPS
        FOR rw_craplgp IN cr_craplgp(rw_crapcop.cdcooper,vr_dtmvtolt) LOOP
          -- Somente no primeiro registro da Cooperativa
          IF rw_craplgp.nrseqreg = 1 THEN
            -- Buscar tarifa Sicredi
            FOR rw_crapthi IN cr_crapthi(rw_crapcop.cdcooper,1414) LOOP
              vr_vltarifa_1414 := rw_crapthi.vltarifa;
            END LOOP;
            -- Busca tarifa CAixa sem Codigo Barras
            vr_dstextab := TABE0001.fn_busca_dstextab(rw_craplgp.cdcooper
                                                     ,'CRED'
                                                     ,'GENERI'
                                                     ,00
                                                     ,'GPSCXASCOD'
                                                     ,0);
            -- Se encontrou
            IF vr_dstextab IS NOT NULL THEN
              vr_aux_vltfcxsb := to_number(vr_dstextab); -- Valor Tarifa Caixa Sem Cod.Barra
            ELSE
              vr_aux_vltfcxsb := 0;
            END IF;

            -- Busca tarifa CAixa Com Codigo Barras
            vr_dstextab := TABE0001.fn_busca_dstextab(rw_craplgp.cdcooper
                                                     ,'CRED'
                                                     ,'GENERI'
                                                     ,00
                                                     ,'GPSCXACCOD'
                                                     ,0);
            -- Se encontrou
            IF vr_dstextab IS NOT NULL THEN
              vr_aux_vltfcxcb := to_number(vr_dstextab); -- Valor Tarifa Caixa Com Cod Barra
            ELSE
              vr_aux_vltfcxcb := 0;
            END IF;

            -- Busca tarifa IBank
            vr_dstextab := TABE0001.fn_busca_dstextab(rw_craplgp.cdcooper
                                                     ,'CRED'
                                                     ,'GENERI'
                                                     ,00
                                                     ,'GPSINTBANK'
                                                     ,0);
            -- Se encontrou
            IF vr_dstextab IS NOT NULL THEN
              vr_aux_vlrtrfib := to_number(vr_dstextab); -- Valor Tarifa IB
            ELSE
              vr_aux_vlrtrfib := 0;
            END IF;

          END IF; -- Fim primeiro registro

          -- Inicializa Variaveis
          vr_aux_dsempgps := NULL;
          vr_aux_dsnomcnv := null;
          vr_aux_tpmeiarr := null;
          vr_aux_dsmeiarr := null;
          vr_aux_vltargps := 0;

          -- Se diferente Internet
          IF rw_craplgp.cdagenci <> 90 THEN
            -- Arrecadacao na Caixa
            vr_aux_tpmeiarr := 'C';
            vr_aux_dsmeiarr := 'CAIXA';
            -- Com Cod.Barras
            IF rw_craplgp.tpdpagto = 1 THEN
              vr_aux_vltargps := vr_aux_vltfcxcb;
            ELSE -- Sem Cod.Barras
              vr_aux_vltargps := vr_aux_vltfcxsb;
            END IF;
          ELSE -- INTERNET
            vr_aux_tpmeiarr := 'D';
            vr_aux_dsmeiarr := 'INTERNET';
            vr_aux_vltargps := vr_aux_vlrtrfib;
          END IF;
          -- Com Cod.Barras
          IF rw_craplgp.tpdpagto = 1 THEN
            vr_aux_dsempgps := 'GP1';
            vr_aux_dsnomcnv := 'GPS - COM COD.BARRAS';
          ELSE -- Sem Cod.Barras
            vr_aux_dsempgps := 'GP2';
            vr_aux_dsnomcnv := 'GPS - SEM COD.BARRAS';
          END IF;

          -- Chamar rotina para gravação em pltable
          pc_insere_tabrel(pr_dtmvtolt => vr_dtmvtolt
                          ,pr_nmconven => vr_aux_dsnomcnv
                          ,pr_cdempres => vr_aux_dsempgps
                          ,pr_tpmeiarr => vr_aux_tpmeiarr
                          ,pr_dsdianor => ''
                          ,pr_nrrenorm => 0
                          ,pr_qtfatura => 1
                          ,pr_vltotfat => rw_craplgp.vlrtotal
                          ,pr_vltrfuni => vr_aux_vltargps
                          ,pr_vltarifa => vr_vltarifa_1414
                          ,pr_dsmeiarr => vr_aux_dsmeiarr
                          ,pr_nrdconta => rw_craplgp.nrctapag
                          ,pr_inpessoa => rw_craplgp.inpesgps
                          ,pr_cdagenci => rw_craplgp.cdagenci);

        END LOOP; -- Fim do FOR - CRAPLGP
      
        -- Buscar proximo fia
        vr_dtmvtolt := gene0005.fn_valida_dia_util(3,vr_dtmvtolt + 1);
      END LOOP; -- Fim LOOP dias
    END LOOP; -- FIm LOOP Cooperativas 
    
    -- Apos acumulo das informações na temp-table, gerar relatório 634 se houver valores na tabela
    IF vr_tab_rel634.count() > 0 THEN 
      -- Zerar totalizadores
      vr_tot_vltotfat := 0;
      vr_tot_vltrfuni := 0;
      vr_tot_qttotfat := 0;
      vr_tot_vlrecliq := 0;
      vr_tot_vltrfsic := 0;
      -- internet
      vr_int_qttotfat := 0;
      vr_int_vltotfat := 0;
      vr_int_vlrecliq := 0;
      vr_int_vltrfuni := 0;
      vr_int_vltrfsic := 0;
      -- caixa
      vr_cax_qttotfat := 0;
      vr_cax_vltotfat := 0;
      vr_cax_vlrecliq := 0;
      vr_cax_vltrfuni := 0;
      vr_cax_vltrfsic := 0;
      -- taa
      vr_taa_qttotfat := 0;
      vr_taa_vltotfat := 0;
      vr_taa_vlrecliq := 0;
      vr_taa_vltrfuni := 0;
      vr_taa_vltrfsic := 0;
      -- deb automatico
      vr_deb_qttotfat := 0;
      vr_deb_vltotfat := 0;
      vr_deb_vlrecliq := 0;
      vr_deb_vltrfuni := 0;
      vr_deb_vltrfsic := 0;

      -- Busca o primeiro registro da temp-table
      vr_ind_rel63X := vr_tab_rel634.first;
      LOOP
        EXIT WHEN vr_ind_rel63X IS NULL;

        -- No primeiro registro
        IF vr_ind_rel63X = vr_tab_rel634.first THEN
          -- Inicializar o CLOB
          vr_des_clb := NULL;
          dbms_lob.createtemporary(vr_des_clb, TRUE);
          dbms_lob.open(vr_des_clb, dbms_lob.lob_readwrite);
          -- Inicilizar as informações do XML
          gene0002.pc_escreve_xml(vr_des_clb
                                 ,vr_des_txt
                                 ,'<?xml version="1.0" encoding="utf-8"?><crrl634>');
        END IF;

        -- Corrigir valores negativos
        IF vr_tab_rel634(vr_ind_rel63X).vltotfat < 0 THEN
          vr_tab_rel634(vr_ind_rel63X).vltotfat := 0;
        END IF;
        IF vr_tab_rel634(vr_ind_rel63X).vlrecliq < 0 THEN
          vr_tab_rel634(vr_ind_rel63X).vlrecliq := 0;
        END IF;
        IF vr_tab_rel634(vr_ind_rel63X).vltottar < 0 THEN
          vr_tab_rel634(vr_ind_rel63X).vltottar := 0;
        END IF;
        IF vr_tab_rel634(vr_ind_rel63X).vltrfsic < 0 THEN
          vr_tab_rel634(vr_ind_rel63X).vltrfsic := 0;
        END IF;

        -- TOTAIS INTERNET
        IF vr_tab_rel634(vr_ind_rel63X).tpmeiarr = 'D' THEN
          vr_int_vltrfuni := vr_int_vltrfuni + vr_tab_rel634(vr_ind_rel63X).vltottar;
          vr_int_vltrfsic := vr_int_vltrfsic + vr_tab_rel634(vr_ind_rel63X).vltrfsic;
          vr_int_vltotfat := vr_int_vltotfat + vr_tab_rel634(vr_ind_rel63X).vltotfat;
          vr_int_qttotfat := vr_int_qttotfat + vr_tab_rel634(vr_ind_rel63X).qtfatura;
          vr_int_vlrecliq := vr_int_vlrecliq + vr_tab_rel634(vr_ind_rel63X).vlrecliq;
        END IF;
        -- TOTAIS CAIXA
        IF vr_tab_rel634(vr_ind_rel63X).tpmeiarr = 'C' THEN
          vr_cax_vltrfuni := vr_cax_vltrfuni + vr_tab_rel634(vr_ind_rel63X).vltottar;
          vr_cax_vltrfsic := vr_cax_vltrfsic + vr_tab_rel634(vr_ind_rel63X).vltrfsic;
          vr_cax_vltotfat := vr_cax_vltotfat + vr_tab_rel634(vr_ind_rel63X).vltotfat;
          vr_cax_qttotfat := vr_cax_qttotfat + vr_tab_rel634(vr_ind_rel63X).qtfatura;
          vr_cax_vlrecliq := vr_cax_vlrecliq + vr_tab_rel634(vr_ind_rel63X).vlrecliq;
        END IF;
        -- TOTAIS TAA
        IF vr_tab_rel634(vr_ind_rel63X).tpmeiarr = 'A' THEN
          vr_taa_vltrfuni := vr_taa_vltrfuni + vr_tab_rel634(vr_ind_rel63X).vltottar;
          vr_taa_vltrfsic := vr_taa_vltrfsic + vr_tab_rel634(vr_ind_rel63X).vltrfsic;
          vr_taa_vltotfat := vr_taa_vltotfat + vr_tab_rel634(vr_ind_rel63X).vltotfat;
          vr_taa_qttotfat := vr_taa_qttotfat + vr_tab_rel634(vr_ind_rel63X).qtfatura;
          vr_taa_vlrecliq := vr_taa_vlrecliq + vr_tab_rel634(vr_ind_rel63X).vlrecliq;
        END IF;
        -- TOTAIS DEB AUTOMATICO
        IF vr_tab_rel634(vr_ind_rel63X).tpmeiarr = 'E' THEN
          vr_deb_vltrfuni := vr_deb_vltrfuni + vr_tab_rel634(vr_ind_rel63X).vltottar;
          vr_deb_vltrfsic := vr_deb_vltrfsic + vr_tab_rel634(vr_ind_rel63X).vltrfsic;
          vr_deb_vltotfat := vr_deb_vltotfat + vr_tab_rel634(vr_ind_rel63X).vltotfat;
          vr_deb_qttotfat := vr_deb_qttotfat + vr_tab_rel634(vr_ind_rel63X).qtfatura;
          vr_deb_vlrecliq := vr_deb_vlrecliq + vr_tab_rel634(vr_ind_rel63X).vlrecliq;
        END IF;
        
        -- Acumulo do TOTAL GERAL
        vr_tot_vltotfat := vr_tot_vltotfat + vr_tab_rel634(vr_ind_rel63X).vltotfat;
        vr_tot_vltrfsic := vr_tot_vltrfsic + vr_tab_rel634(vr_ind_rel63X).vltrfsic;
        vr_tot_vltrfuni := vr_tot_vltrfuni + vr_tab_rel634(vr_ind_rel63X).vltottar;
        vr_tot_qttotfat := vr_tot_qttotfat + vr_tab_rel634(vr_ind_rel63X).qtfatura;
        vr_tot_vlrecliq := vr_tot_vlrecliq + vr_tab_rel634(vr_ind_rel63X).vlrecliq;
        
        -- Enviar o registro para o XML
        gene0002.pc_escreve_xml(vr_des_clb
                               ,vr_des_txt
                               ,'<coluna>' ||
                                  '<nmconven>'||  vr_tab_rel634(vr_ind_rel63X).nmconven                                   ||'</nmconven>'||
                                  '<dsmeiarr>'||  vr_tab_rel634(vr_ind_rel63X).dsmeiarr                                   ||'</dsmeiarr>'||
                                  '<qttotfat>'||  nvl(vr_tab_rel634(vr_ind_rel63X).qtfatura,0)                                  ||'</qttotfat>'||
                                  '<vltotfat>'||to_char(nvl(vr_tab_rel634(vr_ind_rel63X).vltotfat,0),'fm999G999G999G999G990d00') ||'</vltotfat>'||
                                  '<vlrecliq>'||to_char(nvl(vr_tab_rel634(vr_ind_rel63X).vlrecliq,0),'fm999G999G999G999G990d00') ||'</vlrecliq>'||
                                  '<vltrfuni>'||to_char(nvl(vr_tab_rel634(vr_ind_rel63X).vltottar,0),'fm999G999G999G999G990d00') ||'</vltrfuni>'||
                                  '<vltrfsic>'||to_char(nvl(vr_tab_rel634(vr_ind_rel63X).vltrfsic,0),'fm999G999G999G999G990d00') ||'</vltrfsic>'||
                                  '<nrrenorm>'||  nvl(vr_tab_rel634(vr_ind_rel63X).nrrenorm,0)                                   ||'</nrrenorm>'||
                                  '<dsdianor>'||  vr_tab_rel634(vr_ind_rel63X).dsdianor                                   ||'</dsdianor>'||
                                '</coluna>');

        -- Posicionar proximo registro da pltable
        vr_ind_rel63X := vr_tab_rel634.next(vr_ind_rel63X);
      END LOOP;

      -- Enviar os totais para o XML
      gene0002.pc_escreve_xml(vr_des_clb
                             ,vr_des_txt
                             , '<totais>' ||
                                 '<int_vltrfuni>'   ||  to_char(nvl(vr_int_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</int_vltrfuni>'||
                                 '<int_vltotfat>'   ||  to_char(nvl(vr_int_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</int_vltotfat>'||
                                 '<int_qttotfat>'   ||  nvl(vr_int_qttotfat,0)                                                                                  ||'</int_qttotfat>'||
                                 '<int_vlrecliq>'   ||  to_char(nvl(vr_int_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</int_vlrecliq>'||
                                 '<int_vltrfsic>'   ||  to_char(nvl(vr_int_vltrfsic,0),'fm999G999G999G999G990d00')                                              ||'</int_vltrfsic>'||
                                 '<cax_vltrfuni>'   ||  to_char(nvl(vr_cax_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</cax_vltrfuni>'||
                                 '<cax_vltotfat>'   ||  to_char(nvl(vr_cax_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</cax_vltotfat>'||
                                 '<cax_qttotfat>'   ||  nvl(vr_cax_qttotfat,0)                                                                                  ||'</cax_qttotfat>'||
                                 '<cax_vlrecliq>'   ||  to_char(nvl(vr_cax_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</cax_vlrecliq>'||
                                 '<cax_vltrfsic>'   ||  to_char(nvl(vr_cax_vltrfsic,0),'fm999G999G999G999G990d00')                                              ||'</cax_vltrfsic>'||
                                 '<taa_vltrfuni>'   ||  to_char(nvl(vr_taa_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</taa_vltrfuni>'||
                                 '<taa_vltotfat>'   ||  to_char(nvl(vr_taa_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</taa_vltotfat>'||
                                 '<taa_qttotfat>'   ||  nvl(vr_taa_qttotfat,0)                                                                                  ||'</taa_qttotfat>'||
                                 '<taa_vlrecliq>'   ||  to_char(nvl(vr_taa_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</taa_vlrecliq>'||
                                 '<taa_vltrfsic>'   ||  to_char(nvl(vr_taa_vltrfsic,0),'fm999G999G999G999G990d00')                                              ||'</taa_vltrfsic>'||
                                 '<deb_vltrfuni>'   ||  to_char(nvl(vr_deb_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</deb_vltrfuni>'||
                                 '<deb_vltotfat>'   ||  to_char(nvl(vr_deb_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</deb_vltotfat>'||
                                 '<deb_qttotfat>'   ||  nvl(vr_deb_qttotfat,0)                                                                                  ||'</deb_qttotfat>'||
                                 '<deb_vlrecliq>'   ||  to_char(nvl(vr_deb_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</deb_vlrecliq>'||
                                 '<deb_vltrfsic>'   ||  to_char(nvl(vr_deb_vltrfsic,0),'fm999G999G999G999G990d00')                                              ||'</deb_vltrfsic>'||
                                 '<tot_vltrfuni>'   ||  to_char(nvl(vr_tot_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</tot_vltrfuni>'||
                                 '<tot_vltotfat>'   ||  to_char(nvl(vr_tot_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</tot_vltotfat>'||
                                 '<tot_qttotfat>'   ||  nvl(vr_tot_qttotfat,0)                                                                                  ||'</tot_qttotfat>'||
                                 '<tot_vlrecliq>'   ||  to_char(nvl(vr_tot_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</tot_vlrecliq>'||
                                 '<tot_vltrfsic>'   ||  to_char(nvl(vr_tot_vltrfsic,0),'fm999G999G999G999G990d00')                                              ||'</tot_vltrfsic>'||
                               '</totais>');
      -- Encerrar o XML
      gene0002.pc_escreve_xml(vr_des_clb
                             ,vr_des_txt
                             ,'</crrl634>'
                             ,true);

      --Buscar caminho da RL
      vr_caminho_coop := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper); --> Utilizaremos o rl

      -- Efetuar solicitação de geração de relatório --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_clb          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl634/coluna'          --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl634.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parametros
                                 ,pr_dsarqsaid => vr_caminho_coop||'/rl/crrl634.lst' --> Arquivo final
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_flg_gerar => 'N'                 --> gerar PDF
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_clb);
      dbms_lob.freetemporary(vr_des_clb);

      -- TEstar saida do relatorio
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar excecao
        raise vr_exc_saida;
      END IF;
    END IF;  

    -- Somente no processo mensal
    IF to_char(rw_crapdat.dtmvtolt,'mm') <> to_char(rw_crapdat.dtmvtopr,'mm') THEN

      -- Não gerar 635 e arquivo contabilização na Central 
      IF pr_cdcooper <> 3 THEN 
        -- Gera relatorio mensal, com base nos dados da pltable 635 se houver informações
        IF vr_tab_rel635.COUNT() > 0 THEN 
          -- Zerar totalizadores
          vr_tot_vltotfat        := 0;
          vr_tot_vltrfuni        := 0;
          vr_tot_qttotfat        := 0;
          vr_tot_vlrecliq        := 0;
          vr_tot_vltrfsic        := 0;
          vr_tot_vlrtrfpf        := 0;
          vr_tot_vlrtrfpf_semgps := 0;          
          vr_tot_vlrliqpf        := 0;
          vr_tot_vlrtrfpj        := 0;
          vr_tot_vlrtrfpj_semgps := 0;
          vr_tot_vlrliqpj        := 0;
          vr_tot_vltrfsic_pf     := 0;
          vr_tot_vltrfsic_pj     := 0;          
          -- internet
          vr_int_qttotfat    := 0;
          vr_int_vltotfat    := 0;
          vr_int_vlrecliq    := 0;
          vr_int_vltrfsic    := 0;
          vr_int_vltrfuni    := 0;
          vr_int_vlrliqpf    := 0;
          vr_int_vlrliqpj    := 0;
          vr_int_vlrtrfpf    := 0;
          vr_int_vlrtrfpj    := 0;
          vr_int_vltrfsic_pf := 0;
          vr_int_vltrfsic_pj := 0;
          -- caixa
          vr_cax_qttotfat    := 0;
          vr_cax_vltotfat    := 0;
          vr_cax_vlrecliq    := 0;
          vr_cax_vltrfsic    := 0;
          vr_cax_vltrfuni    := 0;
          vr_cax_vlrliqpf    := 0;
          vr_cax_vlrliqpj    := 0;
          vr_cax_vlrtrfpf    := 0;
          vr_cax_vlrtrfpj    := 0;
          vr_cax_vltrfsic_pf := 0;
          vr_cax_vltrfsic_pj := 0;          
          -- taa
          vr_taa_qttotfat    := 0;
          vr_taa_vltotfat    := 0;
          vr_taa_vlrecliq    := 0;
          vr_taa_vltrfsic    := 0;
          vr_taa_vltrfuni    := 0;
          vr_taa_vlrliqpf    := 0;
          vr_taa_vlrliqpj    := 0;
          vr_taa_vlrtrfpf    := 0;
          vr_taa_vlrtrfpj    := 0;
          vr_taa_vltrfsic_pf := 0;
          vr_taa_vltrfsic_pj := 0;          
          -- deb automatico
          vr_deb_qttotfat    := 0;
          vr_deb_vltotfat    := 0;
          vr_deb_vlrecliq    := 0;
          vr_deb_vltrfsic    := 0;
          vr_deb_vltrfuni    := 0;
          vr_deb_vlrliqpf    := 0;
          vr_deb_vlrliqpj    := 0;
          vr_deb_vlrtrfpf    := 0;
          vr_deb_vlrtrfpj    := 0;
          vr_deb_vltrfsic_pf := 0;
          vr_deb_vltrfsic_pj := 0;          

          -- Busca o primeiro registro da temp-table
          vr_ind_rel63X := vr_tab_rel635.first;
          LOOP
            EXIT WHEN vr_ind_rel63X IS NULL;

            -- No primeiro registro
            IF vr_ind_rel63X = vr_tab_rel635.first THEN
              -- Inicializar o CLOB
              vr_des_clb := NULL;
              dbms_lob.createtemporary(vr_des_clb, TRUE);
              dbms_lob.open(vr_des_clb, dbms_lob.lob_readwrite);
              -- Inicilizar as informações do XML
              gene0002.pc_escreve_xml(vr_des_clb
                                     ,vr_des_txt
                                     ,'<?xml version="1.0" encoding="utf-8"?><crrl635>');
            END IF;

            -- Corrigir valores negativos
            IF vr_tab_rel635(vr_ind_rel63X).vltotfat < 0 THEN
              vr_tab_rel635(vr_ind_rel63X).vltotfat := 0;
            END IF;
            IF vr_tab_rel635(vr_ind_rel63X).vlrecliq < 0 THEN
              vr_tab_rel635(vr_ind_rel63X).vlrecliq := 0;
            END IF;
            IF vr_tab_rel635(vr_ind_rel63X).vltottar < 0 THEN
              vr_tab_rel635(vr_ind_rel63X).vltottar := 0;
            END IF;
            IF vr_tab_rel635(vr_ind_rel63X).vlrtrfpf < 0 THEN
              vr_tab_rel635(vr_ind_rel63X).vlrtrfpf := 0;
            END IF;
            IF vr_tab_rel635(vr_ind_rel63X).vlrliqpf < 0 THEN
              vr_tab_rel635(vr_ind_rel63X).vlrliqpf := 0;
            END IF;
            IF vr_tab_rel635(vr_ind_rel63X).vlrtrfpj < 0 THEN
              vr_tab_rel635(vr_ind_rel63X).vlrtrfpj := 0;
            END IF;
            IF vr_tab_rel635(vr_ind_rel63X).vlrliqpj < 0 THEN
              vr_tab_rel635(vr_ind_rel63X).vlrliqpj := 0;
            END IF;
            IF vr_tab_rel635(vr_ind_rel63X).vltrfsic < 0 THEN
              vr_tab_rel635(vr_ind_rel63X).vltrfsic := 0;
            END IF;

            -- TOTAIS INTERNET
            IF vr_tab_rel635(vr_ind_rel63X).tpmeiarr = 'D' THEN
              vr_int_vltrfuni := vr_int_vltrfuni + vr_tab_rel635(vr_ind_rel63X).vltottar;
              vr_int_vltotfat := vr_int_vltotfat + vr_tab_rel635(vr_ind_rel63X).vltotfat;
              vr_int_qttotfat := vr_int_qttotfat + vr_tab_rel635(vr_ind_rel63X).qtfatura;
              vr_int_vlrecliq := vr_int_vlrecliq + vr_tab_rel635(vr_ind_rel63X).vlrecliq;
              vr_int_vltrfsic := vr_int_vltrfsic + vr_tab_rel635(vr_ind_rel63X).vltrfsic;
              -- Divisao PF/PJ
              vr_int_vlrtrfpf    := vr_int_vlrtrfpf    + vr_tab_rel635(vr_ind_rel63X).vlrtrfpf;
              vr_int_vlrliqpf    := vr_int_vlrliqpf    + vr_tab_rel635(vr_ind_rel63X).vlrliqpf;
              vr_int_vlrtrfpj    := vr_int_vlrtrfpj    + vr_tab_rel635(vr_ind_rel63X).vlrtrfpj;
              vr_int_vlrliqpj    := vr_int_vlrliqpj    + vr_tab_rel635(vr_ind_rel63X).vlrliqpj;
              vr_int_vltrfsic_pf := vr_int_vltrfsic_pf + vr_tab_rel635(vr_ind_rel63X).vltrfsic_pf; 
              vr_int_vltrfsic_pj := vr_int_vltrfsic_pj + vr_tab_rel635(vr_ind_rel63X).vltrfsic_pj;                                         
            END IF;
            -- TOTAIS CAIXA
            IF vr_tab_rel635(vr_ind_rel63X).tpmeiarr = 'C' THEN
              vr_cax_vltrfuni := vr_cax_vltrfuni + vr_tab_rel635(vr_ind_rel63X).vltottar;
              vr_cax_vltotfat := vr_cax_vltotfat + vr_tab_rel635(vr_ind_rel63X).vltotfat;
              vr_cax_qttotfat := vr_cax_qttotfat + vr_tab_rel635(vr_ind_rel63X).qtfatura;
              vr_cax_vlrecliq := vr_cax_vlrecliq + vr_tab_rel635(vr_ind_rel63X).vlrecliq;
              vr_cax_vltrfsic := vr_cax_vltrfsic + vr_tab_rel635(vr_ind_rel63X).vltrfsic;
              -- Divisao PF/PJ
              vr_cax_vlrtrfpf    := vr_cax_vlrtrfpf    + vr_tab_rel635(vr_ind_rel63X).vlrtrfpf;
              vr_cax_vlrliqpf    := vr_cax_vlrliqpf    + vr_tab_rel635(vr_ind_rel63X).vlrliqpf;
              vr_cax_vlrtrfpj    := vr_cax_vlrtrfpj    + vr_tab_rel635(vr_ind_rel63X).vlrtrfpj;
              vr_cax_vlrliqpj    := vr_cax_vlrliqpj    + vr_tab_rel635(vr_ind_rel63X).vlrliqpj;
              vr_cax_vltrfsic_pf := vr_cax_vltrfsic_pf + vr_tab_rel635(vr_ind_rel63X).vltrfsic_pf; 
              vr_cax_vltrfsic_pj := vr_cax_vltrfsic_pj + vr_tab_rel635(vr_ind_rel63X).vltrfsic_pj;               
            END IF;
            -- TOTAIS TAA
            IF vr_tab_rel635(vr_ind_rel63X).tpmeiarr = 'A' THEN
              vr_taa_vltrfuni := vr_taa_vltrfuni + vr_tab_rel635(vr_ind_rel63X).vltottar;
              vr_taa_vltotfat := vr_taa_vltotfat + vr_tab_rel635(vr_ind_rel63X).vltotfat;
              vr_taa_qttotfat := vr_taa_qttotfat + vr_tab_rel635(vr_ind_rel63X).qtfatura;
              vr_taa_vlrecliq := vr_taa_vlrecliq + vr_tab_rel635(vr_ind_rel63X).vlrecliq;
              vr_taa_vltrfsic := vr_taa_vltrfsic + vr_tab_rel635(vr_ind_rel63X).vltrfsic;
              -- Divisao PF/PJ
              vr_taa_vlrtrfpf    := vr_taa_vlrtrfpf    + vr_tab_rel635(vr_ind_rel63X).vlrtrfpf;
              vr_taa_vlrliqpf    := vr_taa_vlrliqpf    + vr_tab_rel635(vr_ind_rel63X).vlrliqpf;
              vr_taa_vlrtrfpj    := vr_taa_vlrtrfpj    + vr_tab_rel635(vr_ind_rel63X).vlrtrfpj;
              vr_taa_vlrliqpj    := vr_taa_vlrliqpj    + vr_tab_rel635(vr_ind_rel63X).vlrliqpj;
              vr_taa_vltrfsic_pf := vr_taa_vltrfsic_pf + vr_tab_rel635(vr_ind_rel63X).vltrfsic_pf; 
              vr_taa_vltrfsic_pj := vr_taa_vltrfsic_pj + vr_tab_rel635(vr_ind_rel63X).vltrfsic_pj;              
            END IF;
            -- TOTAIS DEB AUTOMATICO
            IF vr_tab_rel635(vr_ind_rel63X).tpmeiarr = 'E' THEN
              vr_deb_vltrfuni := vr_deb_vltrfuni + vr_tab_rel635(vr_ind_rel63X).vltottar;
              vr_deb_vltotfat := vr_deb_vltotfat + vr_tab_rel635(vr_ind_rel63X).vltotfat;
              vr_deb_qttotfat := vr_deb_qttotfat + vr_tab_rel635(vr_ind_rel63X).qtfatura;
              vr_deb_vlrecliq := vr_deb_vlrecliq + vr_tab_rel635(vr_ind_rel63X).vlrecliq;
              vr_deb_vltrfsic := vr_deb_vltrfsic + vr_tab_rel635(vr_ind_rel63X).vltrfsic;
              -- Divisao PF/PJ
              vr_deb_vlrtrfpf    := vr_deb_vlrtrfpf    + vr_tab_rel635(vr_ind_rel63X).vlrtrfpf;
              vr_deb_vlrliqpf    := vr_deb_vlrliqpf    + vr_tab_rel635(vr_ind_rel63X).vlrliqpf;
              vr_deb_vlrtrfpj    := vr_deb_vlrtrfpj    + vr_tab_rel635(vr_ind_rel63X).vlrtrfpj;
              vr_deb_vlrliqpj    := vr_deb_vlrliqpj    + vr_tab_rel635(vr_ind_rel63X).vlrliqpj;
              vr_deb_vltrfsic_pf := vr_deb_vltrfsic_pf + vr_tab_rel635(vr_ind_rel63X).vltrfsic_pf; 
              vr_deb_vltrfsic_pj := vr_deb_vltrfsic_pj + vr_tab_rel635(vr_ind_rel63X).vltrfsic_pj;              
            END IF;
            
            -- Acumulo do TOTAL GERAL
            vr_tot_vltotfat := vr_tot_vltotfat + vr_tab_rel635(vr_ind_rel63X).vltotfat;
            vr_tot_vltrfuni := vr_tot_vltrfuni + vr_tab_rel635(vr_ind_rel63X).vltottar;
            vr_tot_qttotfat := vr_tot_qttotfat + vr_tab_rel635(vr_ind_rel63X).qtfatura;
            vr_tot_vlrecliq := vr_tot_vlrecliq + vr_tab_rel635(vr_ind_rel63X).vlrecliq;
            vr_tot_vltrfsic := vr_tot_vltrfsic + vr_tab_rel635(vr_ind_rel63X).vltrfsic;
            -- Divisão PF/PJ 
            vr_tot_vlrtrfpf    := vr_tot_vlrtrfpf    + vr_tab_rel635(vr_ind_rel63X).vlrtrfpf;
            vr_tot_vlrliqpf    := vr_tot_vlrliqpf    + vr_tab_rel635(vr_ind_rel63X).vlrliqpf;
            vr_tot_vlrtrfpj    := vr_tot_vlrtrfpj    + vr_tab_rel635(vr_ind_rel63X).vlrtrfpj;
            vr_tot_vlrliqpj    := vr_tot_vlrliqpj    + vr_tab_rel635(vr_ind_rel63X).vlrliqpj;
            vr_tot_vltrfsic_pf := vr_tot_vltrfsic_pf + vr_tab_rel635(vr_ind_rel63X).vltrfsic_pf; 
            vr_tot_vltrfsic_pj := vr_tot_vltrfsic_pj + vr_tab_rel635(vr_ind_rel63X).vltrfsic_pj;            
            -- Valores sem GPS
            IF SUBSTR(vr_tab_rel635(vr_ind_rel63X).nmconven,1,3) <> 'GPS' THEN 
              vr_tot_vlrtrfpf_semgps := vr_tot_vlrtrfpf_semgps + vr_tab_rel635(vr_ind_rel63X).vlrtrfpf;
              vr_tot_vlrtrfpj_semgps := vr_tot_vlrtrfpj_semgps + vr_tab_rel635(vr_ind_rel63X).vlrtrfpj;
            END IF;
            
            -- Enviar o registro para o XML
            gene0002.pc_escreve_xml(vr_des_clb
                                   ,vr_des_txt
                                   ,'<coluna>'       ||
                                      '<nmconven>'   || vr_tab_rel635(vr_ind_rel63X).nmconven                                               ||'</nmconven>'||
                                      '<dsmeiarr>'   || vr_tab_rel635(vr_ind_rel63X).dsmeiarr                                               ||'</dsmeiarr>'||
                                      '<qttotfat>'   || nvl(vr_tab_rel635(vr_ind_rel63X).qtfatura,0)                                        ||'</qttotfat>'||
                                      '<vltotfat>'   || to_char(nvl(vr_tab_rel635(vr_ind_rel63X).vltotfat,0),'fm999G999G999G999G990d00')    ||'</vltotfat>'||
                                      '<vlrecliq>'   || to_char(nvl(vr_tab_rel635(vr_ind_rel63X).vlrecliq,0),'fm999G999G999G999G990d00')    ||'</vlrecliq>'||
                                      '<vltrfuni>'   || to_char(nvl(vr_tab_rel635(vr_ind_rel63X).vltottar,0),'fm999G999G999G999G990d00')    ||'</vltrfuni>'||
                                      '<vlrecliq_pf>'|| to_char(nvl(vr_tab_rel635(vr_ind_rel63X).vlrliqpf,0),'fm999G999G999G999G990d00')    ||'</vlrecliq_pf>'||
                                      '<vltrfuni_pf>'|| to_char(nvl(vr_tab_rel635(vr_ind_rel63X).vlrtrfpf,0),'fm999G999G999G999G990d00')    ||'</vltrfuni_pf>'||
                                      '<vlrecliq_pj>'|| to_char(nvl(vr_tab_rel635(vr_ind_rel63X).vlrliqpj,0),'fm999G999G999G999G990d00')    ||'</vlrecliq_pj>'||
                                      '<vltrfuni_pj>'|| to_char(nvl(vr_tab_rel635(vr_ind_rel63X).vlrtrfpj,0),'fm999G999G999G999G990d00')    ||'</vltrfuni_pj>'||
                                      '<vltrfsic>'   || to_char(nvl(vr_tab_rel635(vr_ind_rel63X).vltrfsic,0),'fm999G999G999G999G990d00')    ||'</vltrfsic>'||
                                      '<vltrfsic_pf>'|| to_char(nvl(vr_tab_rel635(vr_ind_rel63X).vltrfsic_pf,0),'fm999G999G999G999G990d00') ||'</vltrfsic_pf>'||
                                      '<vltrfsic_pj>'|| to_char(nvl(vr_tab_rel635(vr_ind_rel63X).vltrfsic_pj,0),'fm999G999G999G999G990d00') ||'</vltrfsic_pj>'||                                                                            
                                      '<nrrenorm>'   || nvl(vr_tab_rel635(vr_ind_rel63X).nrrenorm,0)                                        ||'</nrrenorm>'||
                                      '<dsdianor>'   || vr_tab_rel635(vr_ind_rel63X).dsdianor                                               ||'</dsdianor>'||
                                    '</coluna>');

            -- Posicionar proximo registro da pltable
            vr_ind_rel63X := vr_tab_rel635.next(vr_ind_rel63X);
          END LOOP;

          -- Enviar os totais para o XML
          gene0002.pc_escreve_xml(vr_des_clb
                                 ,vr_des_txt
                                 , '<totais>'            ||
                                     '<int_vltrfuni>'    ||  to_char(nvl(vr_int_vltrfuni,0),'fm999G999G999G999G990d00')            || '</int_vltrfuni>'    ||
                                     '<int_vltotfat>'    ||  to_char(nvl(vr_int_vltotfat,0),'fm999G999G999G999G990d00')            || '</int_vltotfat>'    ||
                                     '<int_qttotfat>'    ||  nvl(vr_int_qttotfat,0)                                                || '</int_qttotfat>'    ||
                                     '<int_vlrecliq>'    ||  to_char(nvl(vr_int_vlrecliq,0),'fm999G999G999G999G990d00')            || '</int_vlrecliq>'    ||
                                     '<int_vlrecliq_pf>' ||  to_char(nvl(vr_int_vlrliqpf,0),'fm999G999G999G999G990d00')            || '</int_vlrecliq_pf>' ||
                                     '<int_vlrecliq_pj>' ||  to_char(nvl(vr_int_vlrliqpj,0),'fm999G999G999G999G990d00')            || '</int_vlrecliq_pj>' ||
                                     '<int_vltrfuni_pf>' ||  to_char(nvl(vr_int_vlrtrfpf,0),'fm999G999G999G999G990d00')            || '</int_vltrfuni_pf>' ||
                                     '<int_vltrfuni_pj>' ||  to_char(nvl(vr_int_vlrtrfpj,0),'fm999G999G999G999G990d00')            || '</int_vltrfuni_pj>' ||
                                     '<int_vltrfsic>'    ||  to_char(nvl(vr_int_vltrfsic,0),'fm999G999G999G999G990d00')            || '</int_vltrfsic>'    ||
                                     '<int_vltrfsic_pf>' ||  to_char(nvl(vr_int_vltrfsic_pf,0),'fm999G999G999G999G990d00')         || '</int_vltrfsic_pf>' ||
                                     '<int_vltrfsic_pj>' ||  to_char(nvl(vr_int_vltrfsic_pj,0),'fm999G999G999G999G990d00')         || '</int_vltrfsic_pj>' ||                                                                          
                                     '<cax_vltrfuni>'    ||  to_char(nvl(vr_cax_vltrfuni,0),'fm999G999G999G999G990d00')            || '</cax_vltrfuni>'    ||
                                     '<cax_vltotfat>'    ||  to_char(nvl(vr_cax_vltotfat,0),'fm999G999G999G999G990d00')            || '</cax_vltotfat>'    ||
                                     '<cax_qttotfat>'    ||  nvl(vr_cax_qttotfat,0)                                                || '</cax_qttotfat>'    ||
                                     '<cax_vlrecliq>'    ||  to_char(nvl(vr_cax_vlrecliq,0),'fm999G999G999G999G990d00')            || '</cax_vlrecliq>'    ||
                                     '<cax_vlrecliq_pf>' ||  to_char(nvl(vr_cax_vlrliqpf,0),'fm999G999G999G999G990d00')            || '</cax_vlrecliq_pf>' ||
                                     '<cax_vlrecliq_pj>' ||  to_char(nvl(vr_cax_vlrliqpj,0),'fm999G999G999G999G990d00')            || '</cax_vlrecliq_pj>' ||
                                     '<cax_vltrfuni_pf>' ||  to_char(nvl(vr_cax_vlrtrfpf,0),'fm999G999G999G999G990d00')            || '</cax_vltrfuni_pf>' ||
                                     '<cax_vltrfuni_pj>' ||  to_char(nvl(vr_cax_vlrtrfpj,0),'fm999G999G999G999G990d00')            || '</cax_vltrfuni_pj>' ||
                                     '<cax_vltrfsic>'    ||  to_char(nvl(vr_cax_vltrfsic,0),'fm999G999G999G999G990d00')            || '</cax_vltrfsic>'    ||
                                     '<cax_vltrfsic_pf>' ||  to_char(nvl(vr_cax_vltrfsic_pf,0),'fm999G999G999G999G990d00')         || '</cax_vltrfsic_pf>' ||                                     
                                     '<cax_vltrfsic_pj>' ||  to_char(nvl(vr_cax_vltrfsic_pj,0),'fm999G999G999G999G990d00')         || '</cax_vltrfsic_pj>' ||                                     
                                     '<taa_vltrfuni>'    ||  to_char(nvl(vr_taa_vltrfuni,0),'fm999G999G999G999G990d00')            || '</taa_vltrfuni>'    ||
                                     '<taa_vltotfat>'    ||  to_char(nvl(vr_taa_vltotfat,0),'fm999G999G999G999G990d00')            || '</taa_vltotfat>'    ||
                                     '<taa_qttotfat>'    ||  nvl(vr_taa_qttotfat,0)                                                || '</taa_qttotfat>'    ||
                                     '<taa_vlrecliq>'    ||  to_char(nvl(vr_taa_vlrecliq,0),'fm999G999G999G999G990d00')            || '</taa_vlrecliq>'    ||
                                     '<taa_vlrecliq_pf>' ||  to_char(nvl(vr_taa_vlrliqpf,0),'fm999G999G999G999G990d00')            || '</taa_vlrecliq_pf>' ||
                                     '<taa_vlrecliq_pj>' ||  to_char(nvl(vr_taa_vlrliqpj,0),'fm999G999G999G999G990d00')            || '</taa_vlrecliq_pj>' ||
                                     '<taa_vltrfuni_pf>' ||  to_char(nvl(vr_taa_vlrtrfpf,0),'fm999G999G999G999G990d00')            || '</taa_vltrfuni_pf>' ||
                                     '<taa_vltrfuni_pj>' ||  to_char(nvl(vr_taa_vlrtrfpj,0),'fm999G999G999G999G990d00')            || '</taa_vltrfuni_pj>' ||
                                     '<taa_vltrfsic>'    ||  to_char(nvl(vr_taa_vltrfsic,0),'fm999G999G999G999G990d00')            || '</taa_vltrfsic>'    ||
                                     '<taa_vltrfsic_pf>' ||  to_char(nvl(vr_taa_vltrfsic_pf,0),'fm999G999G999G999G990d00')         || '</taa_vltrfsic_pf>' ||                                     
                                     '<taa_vltrfsic_pj>' ||  to_char(nvl(vr_taa_vltrfsic_pj,0),'fm999G999G999G999G990d00')         || '</taa_vltrfsic_pj>' ||                                     
                                     '<deb_vltrfuni>'    ||  to_char(nvl(vr_deb_vltrfuni,0),'fm999G999G999G999G990d00')            || '</deb_vltrfuni>'    ||
                                     '<deb_vltotfat>'    ||  to_char(nvl(vr_deb_vltotfat,0),'fm999G999G999G999G990d00')            || '</deb_vltotfat>'    ||
                                     '<deb_qttotfat>'    ||  nvl(vr_deb_qttotfat,0)                                                || '</deb_qttotfat>'    ||
                                     '<deb_vlrecliq>'    ||  to_char(nvl(vr_deb_vlrecliq,0),'fm999G999G999G999G990d00')            || '</deb_vlrecliq>'    ||
                                     '<deb_vlrecliq_pf>' ||  to_char(nvl(vr_deb_vlrliqpf,0),'fm999G999G999G999G990d00')            || '</deb_vlrecliq_pf>' ||
                                     '<deb_vlrecliq_pj>' ||  to_char(nvl(vr_deb_vlrliqpj,0),'fm999G999G999G999G990d00')            || '</deb_vlrecliq_pj>' ||
                                     '<deb_vltrfuni_pf>' ||  to_char(nvl(vr_deb_vlrtrfpf,0),'fm999G999G999G999G990d00')            || '</deb_vltrfuni_pf>' ||
                                     '<deb_vltrfuni_pj>' ||  to_char(nvl(vr_deb_vlrtrfpj,0),'fm999G999G999G999G990d00')            || '</deb_vltrfuni_pj>' ||
                                     '<deb_vltrfsic>'    ||  to_char(nvl(vr_deb_vltrfsic,0),'fm999G999G999G999G990d00')            || '</deb_vltrfsic>'    ||
                                     '<deb_vltrfsic_pf>' ||  to_char(nvl(vr_deb_vltrfsic_pf,0),'fm999G999G999G999G990d00')         || '</deb_vltrfsic_pf>' ||                                     
                                     '<deb_vltrfsic_pj>' ||  to_char(nvl(vr_deb_vltrfsic_pj,0),'fm999G999G999G999G990d00')         || '</deb_vltrfsic_pj>' ||                                     
                                     '<tot_vltrfuni>'    ||  to_char(nvl(vr_tot_vltrfuni,0),'fm999G999G999G999G990d00')            || '</tot_vltrfuni>'    ||
                                     '<tot_vltotfat>'    ||  to_char(nvl(vr_tot_vltotfat,0),'fm999G999G999G999G990d00')            || '</tot_vltotfat>'    ||
                                     '<tot_qttotfat>'    ||  nvl(vr_tot_qttotfat,0)                                                || '</tot_qttotfat>'    ||
                                     '<tot_vlrecliq>'    ||  to_char(nvl(vr_tot_vlrecliq,0),'fm999G999G999G999G990d00')            || '</tot_vlrecliq>'    ||
                                     '<tot_vlrecliq_pf>' ||  to_char(nvl(vr_tot_vlrliqpf,0),'fm999G999G999G999G990d00')            || '</tot_vlrecliq_pf>' ||
                                     '<tot_vlrecliq_pj>' ||  to_char(nvl(vr_tot_vlrliqpj,0),'fm999G999G999G999G990d00')            || '</tot_vlrecliq_pj>' ||
                                     '<tot_vltrfuni_pf>' ||  to_char(nvl(vr_tot_vlrtrfpf,0),'fm999G999G999G999G990d00')            || '</tot_vltrfuni_pf>' ||
                                     '<tot_vltrfuni_pj>' ||  to_char(nvl(vr_tot_vlrtrfpj,0),'fm999G999G999G999G990d00')            || '</tot_vltrfuni_pj>' ||
                                     '<tot_vltrfsic>'    ||  to_char(nvl(vr_tot_vltrfsic,0),'fm999G999G999G999G990d00')            || '</tot_vltrfsic>'    ||
                                     '<tot_vltrfsic_pf>' ||  to_char(nvl(vr_tot_vltrfsic_pf,0),'fm999G999G999G999G990d00')         || '</tot_vltrfsic_pf>' ||                                     
                                     '<tot_vltrfsic_pj>' ||  to_char(nvl(vr_tot_vltrfsic_pj,0),'fm999G999G999G999G990d00')         || '</tot_vltrfsic_pj>' ||                                     
                                   '</totais>');
          -- Encerrar o XML
          gene0002.pc_escreve_xml(vr_des_clb
                                 ,vr_des_txt
                                 ,'</crrl635>'
                                 ,true);

          --Buscar caminho da RL
          vr_caminho_coop := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                  ,pr_cdcooper => pr_cdcooper); --> Utilizaremos o rl

          -- Efetuar solicitação de geração de relatório --
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_clb          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl635/coluna'          --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl635.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                --> Sem parametros
                                     ,pr_dsarqsaid => vr_caminho_coop||'/rl/crrl635.lst' --> Arquivo final
                                     ,pr_qtcoluna  => 234                 --> 132 colunas
                                     ,pr_sqcabrel  => 2                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                     ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => '234dh'            --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                   --> Número de cópias
                                     ,pr_flg_gerar => 'N'                 --> gerar PDF
                                     ,pr_des_erro  => vr_dscritic);       --> Saída com erro

          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_des_clb);
          dbms_lob.freetemporary(vr_des_clb);

          -- TEstar saida do relatorio
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar excecao
            raise vr_exc_saida;
          END IF;


          ---------------------------------------------------------------------------------
          -------- Arquivo conciliacao Convenios "AAMMDD_CONVEN_SIC.txt" ------------------

          /* MODELO
                    70141128,281114,7255,7367,692.36,5210,"TARIFAS CONVENIO SICREDI  - COOPERADOS PESSOA FISICA"
                    001,482.44
                    002,64.19
                    090,120.27
                    091,25.46
                    70141201,011214,7367,7255,692.36,5210,"TARIFAS CONVENIO SICREDI  - COOPERADOS PESSOA FISICA"
                    001,482.44
                    002,64.19
                    090,120.27
                    091,25.46
                    70141128,281114,7255,7368,863.26,5210,"TARIFAS CONVENIO SICREDI - COOPERADOS PESSOA JURIDICA"
                    001,441.43
                    002,80.77
                    090,320.95
                    091,20.11
                    70141201,011214,7368,7255,863.26,5210,"TARIFAS CONVENIO SICREDI - COOPERADOS PESSOA JURIDICA"
                    001,441.43
                    002,80.77
                    090,320.95
                    091,20.11
          */
          ---------------------------------------------------------------------------------

          -- Somente será montado se houver valor tarifa fisica ou juridica
          IF NVL(vr_tot_vlrtrfpf_semgps,0) + NVL(vr_tot_vlrtrfpj_semgps,0) > 0 THEN

            vr_con_dtmvtolt := '70'||substr(to_char(rw_crapdat.dtmvtolt,'YYYY'),3,2)
                                   ||to_char(rw_crapdat.dtmvtolt,'MM')
                                   ||to_char(rw_crapdat.dtmvtolt,'DD');

            vr_aux_nmarqdat := '/contab/'||to_char(rw_crapdat.dtmvtolt,'RRMMDD')||'_'||lpad(pr_cdcooper,2,'0')||'_CONVEN_SIC.txt';

            -- Buscare diretorio X
            vr_caminho_dirX := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                        ,pr_cdcooper => pr_cdcooper
                                                        ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');

            -- Iniciar CLOB com os dados do arquivo
            vr_des_clb := NULL;
            dbms_lob.createtemporary(vr_des_clb, TRUE);
            dbms_lob.open(vr_des_clb, dbms_lob.lob_readwrite);

            -- Se há valor tarifa PF
            IF vr_tot_vlrtrfpf_semgps <> 0 THEN

              -- Montar cabeçalho do dia atual
              vr_aux_linhadet := vr_con_dtmvtolt || ','
                              || to_char(rw_crapdat.dtmvtolt,'DDMMYY') || ',7268,7376,'
                              || replace(TO_CHAR(vr_tot_vlrtrfpf_semgps,'fm999999999999990D00'),',','.')
                              || ',5210,' || '"TARIFAS CONVENIO SICREDI - COOPERADOS PESSOA FISICA"'
                              || chr(10);

              -- Enviar para o clob
              gene0002.pc_escreve_xml(vr_des_clb,vr_des_txt,vr_aux_linhadet);

              -- Enviar os dados dos PAs para o arquivo, duas vezes 
              FOR vr_i IN 1..2 LOOP
                FOR vr_idx IN vr_relvltrpapf.first..vr_relvltrpapf.last LOOP
                  -- Se existir o registro na tabela
                  IF vr_relvltrpapf.exists(vr_idx) THEN
                    -- Gerar a linha
                    vr_aux_linhadet := to_char(vr_idx,'fm000')|| ','
                                    || replace(to_char((vr_relvltrpapf(vr_idx)),'fm99999999990D00'),',','.')
                                    || chr(10);

                    -- Enviar para o clob
                    gene0002.pc_escreve_xml(vr_des_clb,vr_des_txt,vr_aux_linhadet);
                  END IF;
                END LOOP;
              END LOOP;
            END IF;

            -- Se há valor tarifa PJ
            IF vr_tot_vlrtrfpj_semgps <> 0 THEN

              -- Montar cabeçalho do dia atual
              vr_aux_linhadet := vr_con_dtmvtolt || ','
                              || to_char(rw_crapdat.dtmvtolt,'DDMMYY') || ',7268,7377,' 
                              || replace(TO_CHAR(vr_tot_vlrtrfpj_semgps,'fm999999999999990D00'),',','.')
                              || ',5210,' || '"TARIFAS CONVENIO SICREDI - COOPERADOS PESSOA JURIDICA"'
                              || chr(10);

              -- Enviar para o clob
              gene0002.pc_escreve_xml(vr_des_clb,vr_des_txt,vr_aux_linhadet);

              -- Enviar os dados dos PAs para o arquivo, duas vezes 
              FOR vr_i IN 1..2 LOOP
                FOR vr_idx IN vr_relvltrpapj.first..vr_relvltrpapj.last LOOP
                  -- Se existir o registro na tabela
                  IF vr_relvltrpapj.exists(vr_idx) THEN
                    -- Gerar a linha
                    vr_aux_linhadet := to_char(vr_idx,'fm000')|| ','
                                    || replace(to_char((vr_relvltrpapj(vr_idx)),'fm99999999990D00'),',','.')
                                    || chr(10);

                    -- Enviar para o clob
                    gene0002.pc_escreve_xml(vr_des_clb,vr_des_txt,vr_aux_linhadet);
                  END IF;
                END LOOP;
              END LOOP;  
              
            END IF;

            -- Mandar comando para copiar do CLOB todo o char pendente
            gene0002.pc_escreve_xml(vr_des_clb,vr_des_txt,' ',true);

            -- Ao final, solicita a geracao do arquivo
            GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper             --> Cooperativa conectada
                                               ,pr_cdprogra  => vr_cdprogra          --> Programa chamador
                                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --> Data do movimento atual
                                               ,pr_dsxml     => vr_des_clb          --> Arquivo XML de dados
                                               ,pr_dsarqsaid => vr_caminho_coop||vr_aux_nmarqdat  --> Path/Nome do arquivo PDF gerado
                                               ,pr_flg_impri => 'N'                  --> Chamar a impressão (Imprim.p)
                                               ,pr_flg_gerar => 'N'                  --> Gerar o arquivo na hora
                                               ,pr_nmformul  => '234dh'              --> Nome do formulário para impressão
                                               ,pr_nrcopias  => 1                    --> Número de cópias para impressão
                                               ,pr_dspathcop => vr_caminho_dirX      --> Lista sep. por ';' de diretórios a copiar o arquivo
                                               ,pr_fldoscop  => 'S'                  --> Flag para converter o arquivo gerado em DOS antes da cópia
                                               ,pr_des_erro  => vr_dscritic);        --> Retorno de Erro
            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_clb);
            dbms_lob.freetemporary(vr_des_clb);

            --Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;

          END IF;
          
          
          --Geração do arquivo contábil AAMMDD_XX_DESPESASICREDI.txt
          --Apenas gera o arquivo se possuir valores de tarifas sicredi
          IF NVL(vr_tot_vltrfsic_pf,0) + NVL(vr_tot_vltrfsic_pj,0) <> 0 THEN

            vr_con_dtmvtolt := '20'||to_char(rw_crapdat.dtmvtolt,'RRMMDD')||','||
                               to_char(rw_crapdat.dtmvtolt,'DDMMRR');

            vr_aux_nmarqdat := '/contab/'||to_char(rw_crapdat.dtmvtolt,'RRMMDD')||'_'||LPAD(pr_cdcooper,2,0)||'_DESPESASICREDI.txt';

            -- Buscare diretorio X
            vr_caminho_dirX := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                        ,pr_cdcooper => pr_cdcooper
                                                        ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');

            -- Iniciar CLOB com os dados do arquivo
            vr_des_clb := NULL;
            dbms_lob.createtemporary(vr_des_clb, TRUE);
            dbms_lob.open(vr_des_clb, dbms_lob.lob_readwrite);

            -- Se há valor tarifa PF
            IF nvl(vr_tot_vltrfsic_pf,0) <> 0 THEN

              -- Montar cabeçalho do dia atual
              vr_aux_linhadet := vr_con_dtmvtolt 
                              ||',8504,8535,'
                              || replace(TO_CHAR(vr_tot_vltrfsic_pf,'fm999999999999990D00'),',','.')
                              || ',5210,' || '"DESPESA ARRECADACAO SICREDI - PESSOA FISICA"'
                              || chr(10);

              -- Enviar para o clob
              gene0002.pc_escreve_xml(vr_des_clb,vr_des_txt,vr_aux_linhadet);

              -- Enviar os dados dos PAs para o arquivo, duas vezes 
              FOR vr_i IN 1..2 LOOP
                FOR vr_idx IN vr_tab_vltrfsic_pf.first..vr_tab_vltrfsic_pf.last LOOP
                  -- Se existir o registro na tabela
                  IF vr_tab_vltrfsic_pf.exists(vr_idx) THEN
                    -- Gerar a linha
                    vr_aux_linhadet := to_char(vr_idx,'fm000')|| ','
                                    || replace(to_char((vr_tab_vltrfsic_pf(vr_idx)),'fm99999999990D00'),',','.')
                                    || chr(10);

                    -- Enviar para o clob
                    gene0002.pc_escreve_xml(vr_des_clb,vr_des_txt,vr_aux_linhadet);
                  END IF;
                END LOOP;
              END LOOP;
            END IF;

            -- Se há valor tarifa PJ
            IF nvl(vr_tot_vltrfsic_pj,0) <> 0 THEN

              -- Montar cabeçalho do dia atual
              vr_aux_linhadet := vr_con_dtmvtolt 
                              || ',8508,8535,' 
                              || replace(TO_CHAR(vr_tot_vltrfsic_pj,'fm999999999999990D00'),',','.')
                              || ',5210,' || '"DESPESA ARRECADACAO SICREDI - PESSOA JURIDICA"'
                              || chr(10);

              -- Enviar para o clob
              gene0002.pc_escreve_xml(vr_des_clb,vr_des_txt,vr_aux_linhadet);

              -- Enviar os dados dos PAs para o arquivo, duas vezes 
              FOR vr_i IN 1..2 LOOP
                FOR vr_idx IN vr_tab_vltrfsic_pj.first..vr_tab_vltrfsic_pj.last LOOP
                  -- Se existir o registro na tabela
                  IF vr_tab_vltrfsic_pj.exists(vr_idx) THEN
                    -- Gerar a linha
                    vr_aux_linhadet := to_char(vr_idx,'fm000')|| ','
                                    || replace(to_char((vr_tab_vltrfsic_pj(vr_idx)),'fm99999999990D00'),',','.')
                                    || chr(10);

                    -- Enviar para o clob
                    gene0002.pc_escreve_xml(vr_des_clb,vr_des_txt,vr_aux_linhadet);
                  END IF;
                END LOOP;
              END LOOP;  
              
            END IF;

            -- Mandar comando para copiar do CLOB todo o char pendente
            gene0002.pc_escreve_xml(vr_des_clb,vr_des_txt,' ',true);

            -- Ao final, solicita a geracao do arquivo
            GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper             --> Cooperativa conectada
                                               ,pr_cdprogra  => vr_cdprogra          --> Programa chamador
                                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --> Data do movimento atual
                                               ,pr_dsxml     => vr_des_clb          --> Arquivo XML de dados
                                               ,pr_dsarqsaid => vr_caminho_coop||vr_aux_nmarqdat  --> Path/Nome do arquivo PDF gerado
                                               ,pr_flg_impri => 'N'                  --> Chamar a impressão (Imprim.p)
                                               ,pr_flg_gerar => 'N'                  --> Gerar o arquivo na hora
                                               ,pr_nmformul  => '234dh'              --> Nome do formulário para impressão
                                               ,pr_nrcopias  => 1                    --> Número de cópias para impressão
                                               ,pr_dspathcop => vr_caminho_dirX      --> Lista sep. por ';' de diretórios a copiar o arquivo
                                               ,pr_fldoscop  => 'S'                  --> Flag para converter o arquivo gerado em DOS antes da cópia
                                               ,pr_des_erro  => vr_dscritic);        --> Retorno de Erro
            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_clb);
            dbms_lob.freetemporary(vr_des_clb);

            --Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;

            
          END IF;
        END IF;  
      ELSE 
        -- Gera o rel636 apenas na Central se houver informações
        IF vr_tab_rel636.count() > 0 THEN 
          -- Temos de recriar a tabela 636 desta vez ordenando pela
          -- quantidade de faturas e separando os registros de DEBAUT
          -- pois eles são listados separadamente no relatorio
          
          vr_ind_rel63X := vr_tab_rel636.first;
          LOOP
            EXIT WHEN vr_ind_rel63X IS NULL;
            -- Criar novo indice incluindo no começo 
            -- 01 - ID PAra que DEBAUT fique no inicio
            -- 18 - Total de faturas da empresa
            -- 35 - Nome da empresa
            -- 18 - Total de faturas do canal
            -- 15 - Canal 
            IF vr_tab_rel636(vr_ind_rel63X).tpmeiarr = 'E' THEN 
              vr_ind_rel636_qtdade := 'D';
            ELSE
              vr_ind_rel636_qtdade := 'X';
            END IF;  
            -- Incluir o restante do indice 
            vr_ind_rel636_qtdade := vr_ind_rel636_qtdade 
                                 || to_char(vr_tab_tot_empresa(vr_tab_rel636(vr_ind_rel63X).cdempres)*100,'fm000000000000000000')
                                 || RPAD(vr_tab_rel636(vr_ind_rel63X).nmconven,35,' ')
                                 || to_char(vr_tab_rel636(vr_ind_rel63X).qtfatura*100,'fm000000000000000000')
                                 || RPAD(vr_tab_rel636(vr_ind_rel63X).dsmeiarr,15,' ');
            -- Enfim, criar o registro na tabela nova com base no registro antigo 
            vr_tab_rel636_qtdade(vr_ind_rel636_qtdade) := vr_tab_rel636(vr_ind_rel63X);
            -- Buscar o proximo registro
            vr_ind_rel63X := vr_tab_rel636.next(vr_ind_rel63X);
          END LOOP;
        
          -- Zerar totalizadores
          vr_tot_vltotfat := 0;
          vr_tot_vltrfuni := 0;
          vr_tot_qttotfat := 0;
          vr_tot_vlrecliq := 0;
          vr_tot_vltrfsic := 0;
          -- internet
          vr_int_qttotfat := 0;
          vr_int_vltotfat := 0;
          vr_int_vlrecliq := 0;
          vr_int_vltrfuni := 0;
          vr_int_vltrfsic := 0;
          -- caixa
          vr_cax_qttotfat := 0;
          vr_cax_vltotfat := 0;
          vr_cax_vlrecliq := 0;
          vr_cax_vltrfuni := 0;
          vr_cax_vltrfsic := 0;
          -- taa
          vr_taa_qttotfat := 0;
          vr_taa_vltotfat := 0;
          vr_taa_vlrecliq := 0;
          vr_taa_vltrfuni := 0;
          vr_taa_vltrfsic := 0;
          -- deb automatico
          vr_deb_qttotfat := 0;
          vr_deb_vltotfat := 0;
          vr_deb_vlrecliq := 0;
          vr_deb_vltrfuni := 0;
          vr_deb_vltrfsic := 0;

          -- Busca o primeiro registro da temp-table
          vr_ind_rel636_qtdade := vr_tab_rel636_qtdade.last;
          LOOP
            EXIT WHEN vr_ind_rel636_qtdade IS NULL;

            -- No primeiro registro
            IF vr_ind_rel636_qtdade = vr_tab_rel636_qtdade.last THEN
              -- Inicializar o CLOB
              vr_des_clb := NULL;
              dbms_lob.createtemporary(vr_des_clb, TRUE);
              dbms_lob.open(vr_des_clb, dbms_lob.lob_readwrite);
              -- Inicilizar as informações do XML
              gene0002.pc_escreve_xml(vr_des_clb
                                     ,vr_des_txt
                                     ,'<?xml version="1.0" encoding="utf-8"?><crrl636>');
            END IF;

            -- Corrigir valores negativos
            IF vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltotfat < 0 THEN
              vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltotfat := 0;
            END IF;
            IF vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vlrecliq < 0 THEN
              vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vlrecliq := 0;
            END IF;
            IF vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltottar < 0 THEN
              vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltottar := 0;
            END IF;
            IF vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltrfsic < 0 THEN
              vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltrfsic := 0;
            END IF;
            
            -- TOTAIS INTERNET
            IF vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).tpmeiarr = 'D' THEN
              vr_int_vltrfuni := vr_int_vltrfuni + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltottar;
              vr_int_vltrfsic := vr_int_vltrfsic + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltrfsic;
              vr_int_vltotfat := vr_int_vltotfat + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltotfat;
              vr_int_qttotfat := vr_int_qttotfat + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).qtfatura;
              vr_int_vlrecliq := vr_int_vlrecliq + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vlrecliq;
            END IF;
            -- TOTAIS CAIXA
            IF vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).tpmeiarr = 'C' THEN
              vr_cax_vltrfuni := vr_cax_vltrfuni + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltottar;
              vr_cax_vltrfsic := vr_cax_vltrfsic + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltrfsic;
              vr_cax_vltotfat := vr_cax_vltotfat + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltotfat;
              vr_cax_qttotfat := vr_cax_qttotfat + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).qtfatura;
              vr_cax_vlrecliq := vr_cax_vlrecliq + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vlrecliq;
            END IF;
            -- TOTAIS TAA
            IF vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).tpmeiarr = 'A' THEN
              vr_taa_vltrfuni := vr_taa_vltrfuni + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltottar;
              vr_taa_vltrfsic := vr_taa_vltrfsic + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltrfsic;
              vr_taa_vltotfat := vr_taa_vltotfat + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltotfat;
              vr_taa_qttotfat := vr_taa_qttotfat + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).qtfatura;
              vr_taa_vlrecliq := vr_taa_vlrecliq + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vlrecliq;
            END IF;
            -- TOTAIS DEB AUTOMATICO
            IF vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).tpmeiarr = 'E' THEN
              vr_deb_vltrfuni := vr_deb_vltrfuni + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltottar;
              vr_deb_vltrfsic := vr_deb_vltrfsic + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltrfsic;
              vr_deb_vltotfat := vr_deb_vltotfat + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltotfat;
              vr_deb_qttotfat := vr_deb_qttotfat + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).qtfatura;
              vr_deb_vlrecliq := vr_deb_vlrecliq + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vlrecliq;
            END IF;
            
            -- Acumulo do TOTAL GERAL
            vr_tot_vltotfat := vr_tot_vltotfat + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltotfat;
            vr_tot_vltrfsic := vr_tot_vltrfsic + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltrfsic;
            vr_tot_vltrfuni := vr_tot_vltrfuni + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltottar;
            vr_tot_qttotfat := vr_tot_qttotfat + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).qtfatura;
            vr_tot_vlrecliq := vr_tot_vlrecliq + vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vlrecliq;
            
            -- Enviar o registro para o XML
            gene0002.pc_escreve_xml(vr_des_clb
                                   ,vr_des_txt
                                   ,'<coluna>' ||
                                      '<nmconven>'||  vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).nmconven                                   ||'</nmconven>'||
                                      '<dsmeiarr>'||  vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).dsmeiarr                                   ||'</dsmeiarr>'||
                                      '<qttotfat>'||  nvl(vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).qtfatura,0)                                  ||'</qttotfat>'||
                                      '<vltotfat>'||to_char(nvl(vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltotfat,0),'fm999G999G999G999G990d00') ||'</vltotfat>'||
                                      '<vlrecliq>'||to_char(nvl(vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vlrecliq,0),'fm999G999G999G999G990d00') ||'</vlrecliq>'||
                                      '<vltrfuni>'||to_char(nvl(vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltottar,0),'fm999G999G999G999G990d00') ||'</vltrfuni>'||
                                      '<vltrfsic>'||to_char(nvl(vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).vltrfsic,0),'fm999G999G999G999G990d00') ||'</vltrfsic>'||
                                      '<nrrenorm>'||  nvl(vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).nrrenorm,0)                                   ||'</nrrenorm>'||
                                      '<dsdianor>'||  vr_tab_rel636_qtdade(vr_ind_rel636_qtdade).dsdianor                                   ||'</dsdianor>'||
                                    '</coluna>');
            -- Posicionar proximo registro da pltable
            vr_ind_rel636_qtdade := vr_tab_rel636_qtdade.prior(vr_ind_rel636_qtdade);
          END LOOP;

          -- Enviar os totais para o XML
          gene0002.pc_escreve_xml(vr_des_clb
                                 ,vr_des_txt
                                 , '<totais>' ||
                                     '<int_vltrfuni>'||  to_char(nvl(vr_int_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</int_vltrfuni>'||
                                     '<int_vltotfat>'||  to_char(nvl(vr_int_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</int_vltotfat>'||
                                     '<int_qttotfat>'||  nvl(vr_int_qttotfat,0)                                                                                  ||'</int_qttotfat>'||
                                     '<int_vlrecliq>'||  to_char(nvl(vr_int_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</int_vlrecliq>'||
                                     '<int_vltrfsic>'||  to_char(nvl(vr_int_vltrfsic,0),'fm999G999G999G999G990d00')                                              ||'</int_vltrfsic>'||
                                     '<cax_vltrfuni>'||  to_char(nvl(vr_cax_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</cax_vltrfuni>'||
                                     '<cax_vltotfat>'||  to_char(nvl(vr_cax_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</cax_vltotfat>'||
                                     '<cax_qttotfat>'||  nvl(vr_cax_qttotfat,0)                                                                                  ||'</cax_qttotfat>'||
                                     '<cax_vlrecliq>'||  to_char(nvl(vr_cax_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</cax_vlrecliq>'||
                                     '<cax_vltrfsic>'||  to_char(nvl(vr_cax_vltrfsic,0),'fm999G999G999G999G990d00')                                              ||'</cax_vltrfsic>'||
                                     '<taa_vltrfuni>'||  to_char(nvl(vr_taa_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</taa_vltrfuni>'||
                                     '<taa_vltotfat>'||  to_char(nvl(vr_taa_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</taa_vltotfat>'||
                                     '<taa_qttotfat>'||  nvl(vr_taa_qttotfat,0)                                                                                  ||'</taa_qttotfat>'||
                                     '<taa_vlrecliq>'||  to_char(nvl(vr_taa_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</taa_vlrecliq>'||
                                     '<taa_vltrfsic>'||  to_char(nvl(vr_taa_vltrfsic,0),'fm999G999G999G999G990d00')                                              ||'</taa_vltrfsic>'||
                                     '<deb_vltrfuni>'||  to_char(nvl(vr_deb_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</deb_vltrfuni>'||
                                     '<deb_vltotfat>'||  to_char(nvl(vr_deb_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</deb_vltotfat>'||
                                     '<deb_qttotfat>'||  nvl(vr_deb_qttotfat,0)                                                                                  ||'</deb_qttotfat>'||
                                     '<deb_vlrecliq>'||  to_char(nvl(vr_deb_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</deb_vlrecliq>'||
                                     '<deb_vltrfsic>'||  to_char(nvl(vr_deb_vltrfsic,0),'fm999G999G999G999G990d00')                                              ||'</deb_vltrfsic>'||
                                     '<tot_vltrfuni>'||  to_char(nvl(vr_tot_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</tot_vltrfuni>'||
                                     '<tot_vltotfat>'||  to_char(nvl(vr_tot_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</tot_vltotfat>'||
                                     '<tot_qttotfat>'||  nvl(vr_tot_qttotfat,0)                                                                                  ||'</tot_qttotfat>'||
                                     '<tot_vlrecliq>'||  to_char(nvl(vr_tot_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</tot_vlrecliq>'||
                                     '<tot_vltrfsic>'||  to_char(nvl(vr_tot_vltrfsic,0),'fm999G999G999G999G990d00')                                              ||'</tot_vltrfsic>'||
                                   '</totais>');
          -- Encerrar o XML
          gene0002.pc_escreve_xml(vr_des_clb
                                 ,vr_des_txt
                                 ,'</crrl636>'
                                 ,true);

          --Buscar caminho da RL
          vr_caminho_coop := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                  ,pr_cdcooper => pr_cdcooper); --> Utilizaremos o rl

          -- Efetuar solicitação de geração de relatório --
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_clb          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl636/coluna'          --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl636.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                --> Sem parametros
                                     ,pr_dsarqsaid => vr_caminho_coop||'/rl/crrl636.lst' --> Arquivo final
                                     ,pr_qtcoluna  => 132                 --> 132 colunas
                                     ,pr_sqcabrel  => 3                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                     ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                   --> Número de cópias
                                     ,pr_flg_gerar => 'N'                 --> gerar PDF
                                     ,pr_des_erro  => vr_dscritic);       --> Saída com erro

          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_des_clb);
          dbms_lob.freetemporary(vr_des_clb);

          -- TEstar saida do relatorio
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar excecao
            raise vr_exc_saida;
          END IF;
        END IF;  
      END IF;
    END IF; -- Somente na mensal

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
End pc_crps638;
/
