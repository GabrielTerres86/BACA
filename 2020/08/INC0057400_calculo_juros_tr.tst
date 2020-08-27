PL/SQL Developer Test script 3.0
1735
DECLARE
  --
  CURSOR cr_meses IS
    SELECT DISTINCT TRUNC(cal.data, 'MM') "DATA"
      FROM( SELECT( to_date(seq.mm || seq.yyyy, 'MM/YYYY')-1
                    -- Subtrai 1 por SEQ.NUM não começar em zero
                  ) + seq.num AS "DATA"
              FROM( SELECT RESULT NUM, 
                           to_char(( -- Data Mínima
                                    last_day(to_date('01/05/2020', 'DD/MM/YYYY'))
                                   ), 'MM') AS "MM",
                           to_char(( -- Data Mínima
                                    last_day(to_date('01/05/2020', 'DD/MM/YYYY'))
                                   ), 'YYYY') AS "YYYY"
                      FROM( SELECT ROWNUM RESULT 
                              FROM dual
                        CONNECT BY LEVEL <= (( -- Data Máxima
                                              last_day(TRUNC(SYSDATE, 'MM'))
                                              -
                                               -- Data Mínima
                                              last_day(to_date('01/05/2020', 'DD/MM/YYYY')) -- Sempre primeiro dia do mês
                                             ) + 1 -- Último dia do último ano
                                            )
                          ) -- Quantas sequências para gerar pelo MAX
                  ) seq
          ) cal
     WHERE TRUNC(cal.data, 'MM') < TRUNC(SYSDATE, 'MM')
     ORDER BY 1;
  --
  rw_meses cr_meses%ROWTYPE;
  --
	CURSOR cr_crapcop IS
	  SELECT cop.cdcooper
		  FROM crapcop cop
		 WHERE cop.flgativo = 1;
	--
	rw_crapcop cr_crapcop%ROWTYPE;
	--
  CURSOR cr_crapdat_atu(pr_cdcooper crapdat.cdcooper%type
                       ) IS
    SELECT dat.dtmvtolt
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  --
  rw_crapdat_atu cr_crapdat_atu%rowtype;
  --
  CURSOR cr_contas(pr_data DATE
	                ,pr_cdcooper crapepr.cdcooper%TYPE
									) IS
    SELECT epr.rowid
          ,epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.vlsdeved
          ,epr.inliquid
          ,epr.dtultpag
          ,epr.inprejuz
          ,epr.dtprejuz
          ,epr.qtprepag
          ,epr.vljuracu
          ,epr.cdlcremp
          ,epr.txjuremp
          ,epr.flgpagto
          ,epr.vlpreemp
          ,epr.dtmvtolt
          ,epr.nrdolote
          ,epr.cdbccxlt
          ,epr.cdagenci
          ,epr.cdfinemp
          ,epr.nrctaav1
          ,epr.nrctaav2
          ,epr.qtpreemp
          ,epr.vlemprst
          ,epr.qtmesdec
          ,epr.dtdpagto
          ,epr.flliqmen
          ,epr.qtprecal
          ,epr.dtinipag
          ,epr.cdempres
      FROM crapepr epr
     WHERE epr.tpemprst = 0
       AND epr.inliquid = 0
			 AND epr.cdcooper = pr_cdcooper
       --AND epr.nrdconta = 529621 -- RETIRAR
       AND NOT EXISTS(SELECT 1
                        FROM craplem lem
                       WHERE lem.cdcooper = epr.cdcooper
                         AND lem.nrdconta = epr.nrdconta
                         AND lem.nrctremp = epr.nrctremp
                         AND lem.cdhistor = 98
                         AND TRUNC(lem.dtmvtolt, 'MM') = TRUNC(pr_data, 'MM')
                     )
       AND EXISTS(SELECT 1
                    FROM craplem lem
                   WHERE lem.cdcooper = epr.cdcooper
                     AND lem.nrdconta = epr.nrdconta
                     AND lem.nrctremp = epr.nrctremp
                     AND lem.cdhistor IN(92, 95)
                     AND TRUNC(lem.dtmvtolt, 'MM') = TRUNC(pr_data, 'MM')
                 );
  --
  rw_contas cr_contas%ROWTYPE;
  --
  cursor cr_crapdat(pr_cdcooper crapdat.cdcooper%type
                   ,pr_dtmvtolt crapdat.dtmvtolt%type
                   ) is
    SELECT pr_dtmvtolt dtmvtolt
          ,gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => (pr_dtmvtolt + 1)
                                      ,pr_tipo     => 'P'
                                      ) dtmvtopr
          ,gene0005.fn_valida_dia_util(pr_cdcooper => 13
                                      ,pr_dtmvtolt => (pr_dtmvtolt - 1)
                                      ,pr_tipo     => 'A'
                                      ) dtmvtoan
          ,3 inproces
          ,dat.qtdiaute
          ,dat.cdprgant
          ,dat.dtmvtocd
          ,trunc(pr_dtmvtolt,'mm')               dtinimes -- Pri. Dia Mes Corr.
          ,trunc(Add_Months(pr_dtmvtolt,1),'mm') dtpridms -- Pri. Dia mes Seguinte
          ,last_day(add_months(pr_dtmvtolt,-1))  dtultdma -- Ult. Dia Mes Ant.
          ,last_day(pr_dtmvtolt)                 dtultdia -- Utl. Dia Mes Corr.
          ,null "rowid"
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  --
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  --
  vr_cdagenci CONSTANT PLS_INTEGER := 1;
  vr_cdbccxlt CONSTANT PLS_INTEGER := 100;
  -- Buscar as capas de lote para a cooperativa e data atual
  CURSOR cr_craplot(pr_nrdolote IN craplot.nrdolote%TYPE
                   ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                   ,pr_cdcooper IN craplot.cdcooper%TYPE
                   ) IS
    SELECT lot.cdcooper
		      ,lot.cdagenci
          ,lot.cdbccxlt
          ,lot.nrdolote
          ,lot.tplotmov
          ,lot.nrseqdig
          ,lot.vlinfodb
          ,lot.vlcompdb
          ,lot.qtinfoln
          ,lot.qtcompln
          ,lot.vlinfocr
          ,lot.vlcompcr
          ,lot.dtmvtolt
          ,rowid
      FROM craplot lot
     WHERE lot.cdcooper = pr_cdcooper
       AND lot.dtmvtolt = pr_dtmvtolt
       AND lot.cdagenci = vr_cdagenci
       AND lot.cdbccxlt = vr_cdbccxlt
       AND lot.nrdolote = pr_nrdolote;
  -- Criaremos um registro para cada tipo de lote utilizado
  rw_craplot_8360 cr_craplot%ROWTYPE; --> Lancamento de juros para o emprestimo

  -- Busca da moeda UFIR
  CURSOR cr_crapmfx(pr_cdcooper crapmfx.cdcooper%TYPE
                   ,pr_dtmvtolt crapmfx.dtmvtolt%TYPE
                   ) IS
    SELECT vlmoefix
      FROM crapmfx
     WHERE cdcooper = pr_cdcooper
       AND dtmvtolt = pr_dtmvtolt --rw_crapdat.dtmvtopr
       AND tpmoefix = 2; -- Ufir
  vr_vlmoefix crapmfx.vlmoefix%TYPE;
  -- Verificar se existe registro de microfilmagem do contrato
  CURSOR cr_crapmcr(pr_rw_crapepr cr_contas%ROWTYPE) IS
    SELECT rowid
      FROM crapmcr mcr
     WHERE mcr.cdcooper = pr_rw_crapepr.cdcooper
       AND mcr.dtmvtolt = pr_rw_crapepr.dtmvtolt
       AND mcr.cdagenci = pr_rw_crapepr.cdagenci
       AND mcr.cdbccxlt = pr_rw_crapepr.cdbccxlt
       AND mcr.nrdolote = pr_rw_crapepr.nrdolote
       AND mcr.nrdconta = pr_rw_crapepr.nrdconta
       AND mcr.nrcontra = pr_rw_crapepr.nrctremp
       AND mcr.tpctrmif = 1; -- Emprestimo
  vr_crapmcr_rowid rowid;
  -- Busca de registro de transferencia entre cooperativas
  CURSOR cr_craptco(pr_nrdconta IN craptco.nrdconta%TYPE
                   ,pr_cdcooper IN craptco.cdcooper%TYPE
                   ) IS
    SELECT 'S'
      FROM craptco tco
     WHERE tco.cdcooper = pr_cdcooper
       AND tco.nrdconta = pr_nrdconta
       AND tco.tpctatrf <> 3;
  vr_existco VARCHAR2(1);
  --
  vr_dtmvtolt date;
	--
	type typ_craplot is record(ds_rowid varchar2(100)
	                          ,cdcooper craplot.cdcooper%type
                            ,vlinfodb craplot.vlinfodb%type
                            ,vlcompdb craplot.vlcompdb%type
														,qtinfoln craplot.qtinfoln%type
														,qtcompln craplot.qtcompln%type
														,nrseqdig craplot.nrseqdig%type
                            );
  --
	type typ_tab_craplot is table of typ_craplot index by varchar2(100);
  vr_tab_craplot typ_tab_craplot;
  vr_indice_craplot varchar(100);
	--
	type typ_crapepr is record(ds_rowid varchar2(100)
	                          ,cdcooper crapepr.cdcooper%type
														,nrdconta crapepr.nrdconta%type
														,nrctremp crapepr.nrctremp%type
														,vlsdeved crapepr.vlsdeved%type
														,vljuracu crapepr.vljuracu%type
														,dstiporg varchar2(10)
                            );
  --
  type typ_tab_crapepr is table of typ_crapepr index by varchar2(100);
  vr_tab_crapepr typ_tab_crapepr;
  vr_indice_crapepr varchar(100);
  --
	type typ_crapcot is record(ds_rowid varchar2(100)
                            ,cdcooper crapcot.cdcooper%type
                            ,nrdconta crapcot.nrdconta%type
                            ,qtjurmfx crapcot.qtjurmfx%type
                            ,dstiporg varchar2(10)
                            );
  --
  type typ_tab_crapcot is table of typ_crapcot index by varchar2(100);
  vr_tab_crapcot typ_tab_crapcot;
  vr_indice_crapcot varchar(100);
	--
	type typ_craplem is record(cdcooper craplem.cdcooper%type
                            ,dtmvtolt craplem.dtmvtolt%type
                            ,cdagenci craplem.cdagenci%type
                            ,cdbccxlt craplem.cdbccxlt%type
                            ,nrdolote craplem.nrdolote%type
                            ,nrdconta craplem.nrdconta%type
                            ,nrctremp craplem.nrctremp%type
                            ,nrdocmto craplem.nrdocmto%type
                            ,cdhistor craplem.cdhistor%type
                            ,nrseqdig craplem.nrseqdig%type
                            ,vllanmto craplem.vllanmto%type
                            ,txjurepr craplem.txjurepr%type
                            ,dtpagemp craplem.dtpagemp%type
                            ,vlpreemp craplem.vlpreemp%type
                            );
  --
  type typ_tab_craplem is table of typ_craplem index by varchar2(100);
  vr_tab_craplem typ_tab_craplem;
  vr_indice_craplem varchar(100);
		
	-- Variáveis arquivos
	vr_texto_crapepr CLOB;
	vr_des_crapepr   CLOB;
	vr_texto_craplem CLOB;
	vr_des_craplem   CLOB;
	vr_texto_crapcot CLOB;
	vr_des_crapcot   CLOB;
	vr_texto_craplot CLOB;
	vr_des_craplot   CLOB;
	vr_texto_log     CLOB;
	vr_des_log       CLOB;
	vr_dsdireto      VARCHAR2(1000);
	vr_dscritic      crapcri.dscritic%type;
	
	vr_nrseqdig NUMBER;
	
  -- Processar a rotina de leitura de pagamentos do emprestimo.
  PROCEDURE pc_leitura_lem(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa
                          ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Código do programa corrente
                          ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de parâmetro (CRAPDAT)
                          ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Número da conta
                          ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero ctrato empréstimo
                          ,pr_dtcalcul   IN DATE --> Data para calculo do empréstimo
                          ,pr_diapagto   IN OUT INTEGER --> Dia para pagamento
                          ,pr_txdjuros   IN OUT crapepr.txjuremp%TYPE --> Taxa de juros aplicada
                          ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de prestações calculadas até momento
                          ,pr_qtprepag   IN OUT crapepr.qtprepag%TYPE --> Quantidade de prestações paga até momento
                          ,pr_vlprepag   IN OUT craplem.vllanmto%TYPE --> Valor acumulado pago no mês
                          ,pr_vljurmes   IN OUT crapepr.vljurmes%TYPE --> Juros no mês corrente
                          ,pr_vljuracu   IN OUT crapepr.vljuracu%TYPE --> Juros acumulados total
                          ,pr_vlsdeved   IN OUT crapepr.vlsdeved%TYPE --> Saldo devedor acumulado
                          ,pr_dtultpag   IN OUT crapepr.dtultpag%TYPE --> Ultimo dia de pagamento das prestações
                          ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Código da crítica tratada
                          ,pr_des_erro   OUT VARCHAR2) IS --> Descrição de critica tratada

  BEGIN
    --
    DECLARE
      -- Cursor para busca dos dados de empréstimo
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT epr.dtmvtolt
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.vlsdeved
              ,epr.vljuracu
              ,epr.dtultpag
              ,epr.inliquid
              ,epr.qtprepag
              ,epr.cdlcremp
              ,epr.txjuremp
              ,epr.cdempres
              ,epr.flgpagto
              ,epr.dtdpagto
              ,epr.vlpreemp
              ,epr.qtprecal
              ,epr.qtpreemp
              ,epr.qtmesdec
              ,epr.tpemprst
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
               AND epr.nrdconta = pr_nrdconta
               AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      -- Teste de existencia de empresa
       CURSOR cr_crapemp IS
        SELECT emp.flgpagto
              ,emp.flgpgtib
          FROM crapemp emp
         WHERE emp.cdcooper = pr_cdcooper
           AND emp.cdempres = rw_crapepr.cdempres;
      vr_flgpagto_emp crapemp.flgpagto%TYPE;
      vr_flgpgtib_emp crapemp.flgpgtib%TYPE;

      -- Variáveis auxiliares ao cálculo
      vr_dtmvtolt crapdat.dtmvtolt%TYPE; --> Data de movimento auxiliar
      vr_dtmesant crapdat.dtmvtolt%TYPE; --> Data do mês anterior ao movimento
      vr_flctamig BOOLEAN; --> Conta migrada entre cooperativas
      vr_nrdiacal INTEGER; --> Número de dias para o cálculo
      vr_nrdiames INTEGER; --> Número de dias para o cálculo no mês corrente
      vr_nrdiaprx INTEGER; --> Número de dias para o cálculo no próximo mês
      vr_inhst093 BOOLEAN; --> ???
      TYPE vr_tab_vlrpgmes IS TABLE OF crapepr.vlpreemp%TYPE INDEX BY BINARY_INTEGER;
      vr_vet_vlrpgmes vr_tab_vlrpgmes; --> Vetor e tipo para acumulo de pagamentos no mês
      vr_qtdpgmes     INTEGER; --> Indice de prestações
      vr_qtprepag     NUMBER(18, 4); --> Qtde paga de prestações no mês
      vr_exipgmes     BOOLEAN; --> Teste para busca no vetor de pagamentos
      vr_vljurmes     NUMBER; --> Juros no mês corrente
      vr_des_erro VARCHAR2(4000);
      vr_exc_erro EXCEPTION;
      -- Verificar se existe registro de conta transferida entre
      -- cooperativas com tipo de transferência = 1 (Conta Corrente)
      CURSOR cr_craptco IS
        SELECT 1
          FROM craptco tco
         WHERE tco.cdcopant = pr_cdcooper
               AND tco.nrctaant = rw_crapepr.nrdconta
               AND tco.tpctatrf = 1
               AND tco.flgativo = 1; --> True
      vr_ind_tco NUMBER(1);
      -- Buscar informações de pagamentos do empréstimos
      --   -> Enviado um tipo de histórico para busca a partir dele
      CURSOR cr_craplem_his(pr_cdhistor IN craplem.cdhistor%TYPE) IS
        SELECT 1
          FROM craplem lem
         WHERE lem.cdcooper = pr_cdcooper
               AND lem.nrdconta = rw_crapepr.nrdconta
               AND lem.nrctremp = rw_crapepr.nrctremp
               AND lem.cdhistor = pr_cdhistor;
      vr_fllemhis NUMBER;
      -- Buscar informações de pagamentos do empréstimos
      --   -> Enviando uma data para filtrar movimentos posteriores a mesma
      CURSOR cr_craplem(pr_dtmvtolt IN craplem.dtmvtolt%TYPE
                       ,pr_dtmesatu IN craplem.dtmvtolt%TYPE
                       ) IS
        SELECT /*+ INDEX (lem CRAPLEM##CRAPLEM6) */
         to_char(lem.dtmvtolt, 'dd') ddlanmto
        ,lem.dtmvtolt
        ,lem.cdhistor
        ,lem.vlpreemp
        ,lem.vllanmto
          FROM craplem lem
         WHERE lem.cdcooper = pr_cdcooper
               AND lem.nrdconta = rw_crapepr.nrdconta
               AND lem.nrctremp = rw_crapepr.nrctremp
               AND lem.dtmvtolt > pr_dtmvtolt
               and lem.dtmvtolt <= pr_dtmesatu
         ORDER BY lem.dtmvtolt
                 ,lem.cdhistor;
      rw_craplem cr_craplem%ROWTYPE;
    BEGIN
      -- Busca dos detalhes do empréstimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr
        INTO rw_crapepr;
      -- Se não encontrar informações
      IF cr_crapepr%NOTFOUND THEN
        -- Fechar o cursor pois teremos raise
        CLOSE cr_crapepr;
        -- Gerar erro com critica 356
        pr_cdcritic := 356;
        vr_des_erro := gene0001.fn_busca_critica(356);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor para continuar o processo
        CLOSE cr_crapepr;
      END IF;
      -- Busca flag de debito em conta da empresa
       OPEN cr_crapemp;
      FETCH cr_crapemp
        INTO vr_flgpagto_emp,vr_flgpgtib_emp;
      -- Se encontrou registro e o tipo de débito for Conta (0-False)
      IF cr_crapemp%FOUND
         AND (vr_flgpagto_emp = 0 OR vr_flgpgtib_emp = 0) THEN
        -- Desconsiderar o dia para pagamento enviado
        pr_diapagto := 0;
      END IF;
      CLOSE cr_crapemp;
      -- Se foi enviado dia para pagamento and o tipo de débito do empréstimo for Conta (0-False)
      IF pr_diapagto > 0
         AND rw_crapepr.flgpagto = 0 THEN
        -- Desconsiderar o dia enviado
        pr_diapagto := 0;
      END IF;
      -- Inciando variaveis auxiliares ao calculo --
      -- Data do processo inicia com a data enviada
      vr_dtmvtolt := pr_rw_crapdat.dtmvtolt;
      -- Flag de conta migrada
      vr_flctamig := FALSE;
      -- Mês anterior ao movimento
      vr_dtmesant := vr_dtmvtolt - to_char(vr_dtmvtolt, 'dd');
      -- Se a data de contratação do empréstimo estiver no mês corrente do movimento
      IF trunc(rw_crapepr.dtmvtolt, 'mm') = trunc(vr_dtmvtolt, 'mm') THEN
        -- Retornar o dia da data de contratação
        vr_nrdiacal := to_char(rw_crapepr.dtmvtolt, 'dd');
      ELSE
        -- Não há dias em atraso
        vr_nrdiacal := 0;
      END IF;
      --
      vr_inhst093 := FALSE;
      -- Zerar juros calculados, qtdes e valor pago no mês
      vr_vljurmes := 0;
      pr_vlprepag := 0;
      pr_qtprecal := 0;
      vr_qtprepag := 0;
      vr_qtdpgmes := 0;
      -- Se estiver rodando no Batch e é processo mensal
      IF pr_rw_crapdat.inproces > 2
         AND pr_cdprogra IN ('CRPS080', 'CRPS085', 'CRPS120') THEN
        -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes próximo dia
        IF TRUNC(vr_dtmvtolt, 'mm') <> TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
          -- Data de movimento e do mês anterior recebem o ultimo dia do mês
          -- corrente da data de movimento passada originalmente
          vr_dtmvtolt := pr_rw_crapdat.dtultdia;
          vr_dtmesant := pr_rw_crapdat.dtultdia;
          -- Zerar número de dias para cálculo
          vr_nrdiacal := 0;
        END IF;
      END IF;
      -- Se o empréstimo está liquidado e não existe saldo devedor
      IF rw_crapepr.inliquid = 1
         AND NVL(pr_vlsdeved, 0) = 0 THEN
        -- Verificar se existe registro de conta transferida entre
        -- cooperativas com tipo de transferência = 1 (Conta Corrente)
        OPEN cr_craptco;
        FETCH cr_craptco
          INTO vr_ind_tco;
        -- Se encontrar algum registro
        IF cr_craptco%FOUND THEN
          -- Verifica se existe o movimento 921 - zerado pela migracao
          OPEN cr_craplem_his(pr_cdhistor => 921);
          FETCH cr_craplem_his
            INTO vr_fllemhis;
          -- Se tiver encontrado
          IF cr_craplem_his%FOUND THEN
            -- Indica que a conta foi migrada
            vr_flctamig := TRUE;
          END IF;
          -- Limpar var e fechar cursor
          vr_fllemhis := NULL;
          CLOSE cr_craplem_his;
        END IF;
        CLOSE cr_craptco;
      END IF;
      -- Somente buscar os pagamentos se a conta não foi migrada
      IF NOT vr_flctamig THEN
        -- Buscar todos os pagamentos do empréstimo
        FOR rw_craplem IN cr_craplem(pr_dtmvtolt => vr_dtmesant
                                    ,pr_dtmesatu => vr_dtmvtolt
                                    ) LOOP

          -- Calcula percentual pago na prestacao e/ou acerto --

          -- Se o pagamento for de algum dos tipos abaixo
          ------ --------------------------------------------------
          --  88 ESTORNO PAGTO
          --  91 PG. EMPR. C/C
          --  92 PG. EMPR. CX.
          --  93 PG. EMPR. FP.
          --  94 DESC/ABON.EMP
          --  95 PG. EMPR. C/C
          -- 120 SOBRAS EMPR.
          -- 277 ESTORNO JUROS
          -- 349 TRF. PREJUIZO
          -- 353 TRANSF. COTAS
          -- 392 ABAT.CONCEDID
          -- 393 PAGTO AVALIST
          -- 507 EST.TRF.COTAS
          /*
            88 - ESTORNO DE PAGAMENTO DE EMPRESTIMO
            91 - PAGTO EMPRESTIMO C/C
            92 - PAGTO EMPRESTIMO EM CAIXA
            93 - PAGTO EMPRESTIMO EM FOLHA
            94 - DESCONTO E/OU ABONO CONCEDIDO NO EMPRESTIMO
            95 - PAGTO EMPRESTIMO C/C
            120 - SOBRAS DE EMPRESTIMOS
            277 - ESTORNO DE JUROS S/EMPR. E FINANC.
            349 - EMPRESTIMO TRANSFERIDO PARA PREJUIZO
            353 - PAGAMENTO DE EMPRESTIMO COM SAQUE DE CAPITAL
            392 - ABATIMENTO CONCEDIDO NO EMPRESTIMO
            393 - PAGAMENTO EMPRESTIMO PELO FIADOR/AVALISTA
            507 - ESTORNO DE TRANSFERENCIA DE COTAS
            2381 - TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO
            2396 - TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO
            2401 - TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO
            2402 - REVERSAO JUROS +60 EMPRESTIMO TR P/ PREJUIZO
            2406 - REVERSAO JUROS +60 FINANCIAMENTO TR P/ PREJUIZO
            2405 - TRANSFERENCIA EMP/ FIN TR SUSPEITA DE FRAUDE
            2403 - ESTORNO TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO
            2404 - ESTORNO DE REVERSAO JUROS +60 TR P/ PREJUIZO
            2407 - ESTORNO DE REVERSAO JUROS +60 TR P/ PREJUIZO
          */
          IF rw_craplem.cdhistor IN
             (88, 91, 92, 93, 94, 95, 120, 277, 349, 353, 392, 393, 507, 2381,2396,2401,2402,2406,2405) THEN
            -- Zerar quantidade paga
            vr_qtprepag := 0;
            -- Garantir que não haja divisão por zero
            IF rw_craplem.vlpreemp > 0 THEN
              -- Quantidade paga é a divisão do lançamento pelo valor da prestação
              vr_qtprepag := ROUND(rw_craplem.vllanmto /
                                   rw_craplem.vlpreemp
                                  ,4);
            END IF;
            -- Para os movimentos
            ------ --------------------------------------------------
            --  88 ESTORNO PAGTO
            -- 120 SOBRAS EMPR.
            -- 507 EST.TRF.COTAS
            IF rw_craplem.cdhistor IN (88, 120, 507) THEN
              -- Não considerar este pagamento para abatimento de prestações
              pr_qtprecal := pr_qtprecal - vr_qtprepag;
            ELSE
              -- Considera este pagamento para abatimento de prestações
              pr_qtprecal := pr_qtprecal + vr_qtprepag;
            END IF;
          END IF;
          -- Para os tipos de movimento abaixo:
          ------ --------------------------------------------------
          --  91 PG. EMPR. C/C
          --  92 PG. EMPR. CX.
          --  94 DESC/ABON.EMP
          -- 277 ESTORNO JUROS
          -- 349 TRF. PREJUIZO
          -- 353 TRANSF. COTAS
          -- 392 ABAT.CONCEDID
          -- 393 PAGTO AVALIST
          /*
           91 - PAGTO EMPRESTIMO C/C
           92 - PAGTO EMPRESTIMO EM CAIXA
           94 - DESCONTO E/OU ABONO CONCEDIDO NO EMPRESTIMO
           277 - ESTORNO DE JUROS S/EMPR. E FINANC.
           349 - EMPRESTIMO TRANSFERIDO PARA PREJUIZO
           353 - PAGAMENTO DE EMPRESTIMO COM SAQUE DE CAPITAL
           392 - ABATIMENTO CONCEDIDO NO EMPRESTIMO
           393 - PAGAMENTO EMPRESTIMO PELO FIADOR/AVALISTA
           2381 - TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO
           2396 - TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO
           2401 - TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO

          */
          IF rw_craplem.cdhistor IN (91, 92, 94, 277, 349, 353, 392, 393,  2381, 2396,2401,2402,2406,2405) THEN
            -- Guardar data do ultimo pagamento
            pr_dtultpag := rw_craplem.dtmvtolt;
            -- Se houver saldo devedor
            IF pr_vlsdeved > 0 THEN
              -- Se o dia para calculo for superior ao dia de lançamento do emprestimo
              IF vr_nrdiacal > rw_craplem.ddlanmto THEN
                -- Utilizar o valor de lançamento para calculo dos juros
                vr_vljurmes := vr_vljurmes +
                               (rw_craplem.vllanmto * pr_txdjuros *
                               (rw_craplem.ddlanmto - vr_nrdiacal));
              ELSE
                -- Utilizar o saldo devedor já acumulado
                vr_vljurmes := vr_vljurmes +
                               (pr_vlsdeved * pr_txdjuros *
                               (rw_craplem.ddlanmto - vr_nrdiacal));
              END IF;
            END IF;
            -- Atualizando nro do dia para calculo
            -- Caso o dia seja superior ao dia do pagamento
            IF vr_nrdiacal > rw_craplem.ddlanmto THEN
              -- Mantem o mesmo valor
              vr_nrdiacal := vr_nrdiacal;
            ELSE
              -- Utilizar o dia do empréstimo
              vr_nrdiacal := rw_craplem.ddlanmto;
            END IF;
            -- Diminuir saldo devedor
            pr_vlsdeved := NVL(pr_vlsdeved, 0) - rw_craplem.vllanmto;
            -- Acumular valor prestação pagos
            pr_vlprepag := pr_vlprepag + rw_craplem.vllanmto;
            -- Acumular número de pagamentos no mês
            vr_qtdpgmes := vr_qtdpgmes + 1;
            -- Incluir lançamento no vetor de pagamentos
            vr_vet_vlrpgmes(vr_qtdpgmes) := rw_craplem.vllanmto;
            -- Para os tipos abaixo relacionados
            -- --- --------------------------------------------------
            --  93 PG. EMPR. FP.
            --  95 PG. EMPR. C/C
          ELSIF rw_craplem.cdhistor IN (93, 95) THEN
            -- Guardar data do ultimo pagamento
            pr_dtultpag := rw_craplem.dtmvtolt;
            -- Se o dia do lançamento é superior ao dia de pagamento passado
            IF rw_craplem.ddlanmto > pr_diapagto THEN
              -- Se houver saldo devedor
              IF pr_vlsdeved > 0 THEN
                -- Acumular os juros
                vr_vljurmes := vr_vljurmes +
                               (pr_vlsdeved * pr_txdjuros *
                               (rw_craplem.ddlanmto - vr_nrdiacal));
                -- Dia calculo recebe o dia do lançamento
                vr_nrdiacal := rw_craplem.ddlanmto;
              ELSE
                -- Dia calculo recebe o dia do lançamento
                vr_nrdiacal := rw_craplem.ddlanmto;
              END IF;
            ELSE
              -- Se houver saldo devedor
              IF pr_vlsdeved > 0 THEN
                -- Acumular os juros
                vr_vljurmes := vr_vljurmes + (pr_vlsdeved * pr_txdjuros *
                               (pr_diapagto - vr_nrdiacal));
                -- Dia calculo recebe o dia do pagamento enviado
                vr_nrdiacal := pr_diapagto;
                -- ???
                vr_inhst093 := TRUE;
              ELSE
                -- Dia calculo recebe o dia do pagamento enviado
                vr_nrdiacal := pr_diapagto;
              END IF;
            END IF;
            -- Diminuir saldo devedor
            pr_vlsdeved := NVL(pr_vlsdeved, 0) - rw_craplem.vllanmto;
            -- Acumular valor prestação pagos
            pr_vlprepag := pr_vlprepag + rw_craplem.vllanmto;
            -- Acumular número de pagamentos no mês
            vr_qtdpgmes := vr_qtdpgmes + 1;
            -- Incluir lançamento no vetor de pagamentos
            vr_vet_vlrpgmes(vr_qtdpgmes) := rw_craplem.vllanmto;
            -- Para os tipos abaixo
            -- --- --------------------------------------------------
            --  88 ESTORNO PAGTO
            -- 395 SERV./TAXAS
            -- 441 JUROS S/ATRAS
            -- 443 MULTA S/ATRAS
            -- 507 EST.TRF.COTAS
          ELSIF rw_craplem.cdhistor IN (88, 395, 441, 443, 507,2403,2404,2407) THEN
            -- Se ainda houver saldo devedor
            IF pr_vlsdeved > 0 THEN
              -- Se o dia do lançamento for inferior ao dia de pagamento enviado
              IF rw_craplem.ddlanmto < pr_diapagto THEN
                -- Se o dia calculado for igual ao dia de pagamento enviado
                IF vr_nrdiacal = pr_diapagto THEN
                  -- Acumular os juros com base na taxa e na diferença entre o dia enviado e o do lançamento
                  vr_vljurmes := vr_vljurmes +
                                 (rw_craplem.vllanmto * pr_txdjuros *
                                 (pr_diapagto - rw_craplem.ddlanmto));
                ELSE
                  -- Acumular os juros com base na taxa e na diferença entre o dia o lançamento e o dia de cálculo
                  vr_vljurmes := vr_vljurmes +
                                 (pr_vlsdeved * pr_txdjuros *
                                 (rw_craplem.ddlanmto - vr_nrdiacal));
                  -- Utilizar como dia de cálculo o dia deste lançamento
                  vr_nrdiacal := rw_craplem.ddlanmto;
                END IF;
              ELSIF rw_craplem.ddlanmto > pr_diapagto THEN
                -- Calcular o juros
                vr_vljurmes := vr_vljurmes +
                               (pr_vlsdeved * pr_txdjuros *
                               (rw_craplem.ddlanmto - vr_nrdiacal));
                -- Dia para calculo recebe o dia deste lançamento
                vr_nrdiacal := rw_craplem.ddlanmto;
              END IF;
            ELSE
              -- Atualizando nro do dia para calculo
              -- Caso o dia seja superior ao dia do lançamento do pagamento
              IF vr_nrdiacal > rw_craplem.ddlanmto THEN
                -- Mantem o mesmo valor
                vr_nrdiacal := vr_nrdiacal;
              ELSE
                -- Utilizar o dia do empréstimo
                vr_nrdiacal := rw_craplem.ddlanmto;
              END IF;
            END IF;
            -- Para estornos abaixo relacionados
            -- --- --------------------------------------------------
            --  88 ESTORNO PAGTO
            -- 507 EST.TRF.COTAS
            IF rw_craplem.cdhistor IN (88, 507) THEN
              -- Não considerar este lançamento no valor pago
              pr_vlprepag := pr_vlprepag - rw_craplem.vllanmto;
              -- Se o valor ficar negativo
              IF pr_vlprepag < 0 THEN
                -- Então zera novamente
                pr_vlprepag := 0;
              END IF;
            END IF;
            -- Acumular o lançamento no saldo devedor
            pr_vlsdeved := pr_vlsdeved + rw_craplem.vllanmto;
            -- Testar se existe pagamento com o mesmo valor no vetor de pagamentos
            vr_exipgmes := FALSE;
            -- Ler o vetor de pagamentos
            FOR vr_aux IN 1 .. vr_qtdpgmes LOOP
              -- Se o valor do vetor é igual ao do pagamento
              IF vr_vet_vlrpgmes(vr_aux) = rw_craplem.vllanmto THEN
                -- Indica que encontrou o pagamento no vetor
                vr_exipgmes := TRUE;
              END IF;
            END LOOP;
            -- Se tiver encontrado
            IF vr_exipgmes THEN
              -- Se o pagamento não for dos estornos abaixo relacionados
              -- --- --------------------------------------------------
              --  88 ESTORNO PAGTO
              -- 507 EST.TRF.COTAS
              IF rw_craplem.cdhistor NOT IN (88, 507) THEN
                -- Diminuir do valor acumulado pago este pagamento
                IF pr_vlprepag >= rw_craplem.vllanmto THEN
                  pr_vlprepag := pr_vlprepag - rw_craplem.vllanmto;
                ELSE
                  pr_vlprepag := 0;
                END IF;
              END IF;
            END IF;
          END IF;
        END LOOP;
      END IF;
      --
      -- Se estiver rodando no Batch
      IF pr_rw_crapdat.inproces > 2 THEN
        -- Se o processo mensal
        IF pr_cdprogra IN ('CRPS080', 'CRPS085', 'CRPS120') THEN
          -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes próximo dia
          IF TRUNC(vr_dtmvtolt, 'mm') <>
             TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
            -- Zerar número de dias para cálculo
            vr_nrdiacal := 0;
          ELSE
            -- Dia para cálculo recebe o dia enviado - o dia dalculado
            vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
          END IF;
        ELSE
          --> Não é processo mensal
          -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes próximo dia
          IF TRUNC(vr_dtmvtolt, 'mm') <>
             TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
            -- Dia para calculo recebe o ultimo dia do mês - o dia calculado
            vr_nrdiacal := to_char(pr_rw_crapdat.dtultdia, 'dd') -
                           vr_nrdiacal;
          ELSE
            -- Dia para cálculo recebe o dia enviado - o dia dalculado
            vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
          END IF;
        END IF;
      ELSE
        -- Dia para cálculo recebe o dia enviado - o dia dalculado
        vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
      END IF;
      -- Se existir saldo devedor
      IF pr_vlsdeved > 0 THEN
        -- Sumarizar juros do mês
        vr_vljurmes := vr_vljurmes +
                       (pr_vlsdeved * pr_txdjuros * vr_nrdiacal);
      END IF;
      -- Quantidade de prestações pagas
      pr_qtprepag := TRUNC(pr_qtprecal);
      -- Zerar qtde dias para cálculo
      vr_nrdiacal := 0;
      -- Se foi enviado data para calculo e existe saldo devedor
      IF pr_dtcalcul IS NOT NULL
         AND pr_vlsdeved > 0 THEN
        -- Dias para calculo recebe a data para calculo - dia do movimento
        vr_nrdiacal := trunc(pr_dtcalcul - vr_dtmvtolt);
        -- Se foi enviada uma data para calculo posterior ao ultimo dia do mês corrente
        IF pr_dtcalcul > pr_rw_crapdat.dtultdia THEN
          -- Qtde dias para calculo de juros no mês corrente
          -- é a diferença entre o ultimo dia - data movimento
          vr_nrdiames := TO_NUMBER(TO_CHAR(pr_rw_crapdat.dtultdia, 'DD')) -
                         TO_NUMBER(TO_CHAR(vr_dtmvtolt, 'DD'));
          -- Qtde dias para calculo de juros no próximo mês
          -- é a diferente entre o total de dias - os dias do mês corrente
          vr_nrdiaprx := vr_nrdiacal - vr_nrdiames;
        ELSE
          --> Estamos no mesmo mês
          -- Quantidade de dias no mês recebe a quantidade de dias calculada
          vr_nrdiames := vr_nrdiacal;
          -- Não existe calculo para o próximo mês
          vr_nrdiaprx := 0;
        END IF;
        -- Acumular juros com o número de dias no mês corrente
        vr_vljurmes := vr_vljurmes +
                       (pr_vlsdeved * pr_txdjuros * vr_nrdiames);
        -- Se a data enviada for do próximo mês
        IF vr_nrdiaprx > 0 THEN
          -- Arredondar os juros calculados
          vr_vljurmes := ROUND(vr_vljurmes, 2);
          -- Acumular no saldo devedor do mês corrente os juros
          pr_vlsdeved := pr_vlsdeved + vr_vljurmes;
          -- Acumular no totalizador de juros o juros calculados
          pr_vljuracu := pr_vljuracu + vr_vljurmes;
          -- Novamente calculamos os juros, porém somente com base nos dias do próximo mês
          vr_vljurmes := (pr_vlsdeved * pr_txdjuros * vr_nrdiaprx);
        END IF;
        -- Se o dia da data enviada for inferior ao dia para pagamento enviado
        IF to_char(pr_dtcalcul, 'dd') < pr_diapagto THEN
          -- Dias para pagamento recebe essa diferença
          vr_nrdiacal := pr_diapagto - to_char(pr_dtcalcul, 'dd');
        ELSE
          -- Ainda não venceu
          vr_nrdiacal := 0;
        END IF;
      ELSE
        -- Se o dia para cálculo for anterior ao dia enviado para pagamento
        --  E Não pode ser processo batch
        --  E deve haver saldo devedor
        --  E não pode ser inhst093 - ???
        IF to_char(vr_dtmvtolt, 'dd') < pr_diapagto
           AND pr_rw_crapdat.inproces < 3
           AND pr_vlsdeved > 0
           AND NOT vr_inhst093 THEN
          -- Dia para calculo recebe o dia enviado - dia da data de movimento
          vr_nrdiacal := pr_diapagto - to_char(vr_dtmvtolt, 'dd');
        ELSE
          -- Dia para calculo permanece zerado
          vr_nrdiacal := 0;
        END IF;
      END IF;
      -- Calcula juros sobre a prest. quando a consulta é menor que o data pagto
      -- Se existe dias para calculo e a data de pagamento contratada é inferior ao ultimo dias do mês corrente
      IF vr_nrdiacal > 0
         AND rw_crapepr.dtdpagto <= pr_rw_crapdat.dtultdia THEN
        -- Se o saldo devedor for superior ao valor contratado de prestação
        IF pr_vlsdeved > rw_crapepr.vlpreemp THEN
          -- Juros no mês são baseados no valor contratado
          vr_vljurmes := vr_vljurmes +
                         (rw_crapepr.vlpreemp * pr_txdjuros * vr_nrdiacal);
        ELSE
          -- Juros no mês são baseados no saldo devedor
          vr_vljurmes := vr_vljurmes +
                         (pr_vlsdeved * pr_txdjuros * vr_nrdiacal);
        END IF;
      END IF;
      -- Arredondar juros no mês
      vr_vljurmes := ROUND(vr_vljurmes, 2);
      -- Acumular juros calculados
      pr_vljuracu := pr_vljuracu + vr_vljurmes;
      -- Incluir no saldo devedor os juros do mês
      pr_vlsdeved := pr_vlsdeved + vr_vljurmes;
      -- Se houver indicação de liquidação do empréstimo
      -- E ainda existe saldo devedor
      IF pr_vlsdeved > 0
         AND rw_crapepr.inliquid > 0 THEN
        -- Se estiver rodando o processo batch no programa crps078
        IF pr_rw_crapdat.inproces > 2
           AND pr_cdprogra = 'CRPS078' THEN
          -- Se os juros do mês forem iguais ou superiores ao saldo devedor
          IF vr_vljurmes >= pr_vlsdeved THEN
            -- Remover dos juros do mês e do juros acumulados o saldo devedor
            vr_vljurmes := vr_vljurmes - pr_vlsdeved;
            pr_vljuracu := pr_vljuracu - pr_vlsdeved;
            -- Zerar o saldo devedor
            pr_vlsdeved := 0;
          ELSE
            -- Gerar crítica
            vr_des_erro := 'ATENCAO: NAO FOI POSSIVEL ZERAR O SALDO - ' ||
                           ' CONTA = ' ||
                           gene0002.fn_mask_conta(rw_crapepr.nrdconta) ||
                           ' CONTRATO = ' ||
                           gene0002.fn_mask_contrato(rw_crapepr.nrctremp) ||
                           ' SALDO = ' ||
                           TO_CHAR(pr_vlsdeved, 'B999g990d00');
            RAISE vr_exc_erro;
          END IF;
        ELSE
          -- Remover dos juros do mês e do juros acumulados o saldo devedor
          vr_vljurmes := vr_vljurmes - pr_vlsdeved;
          pr_vljuracu := pr_vljuracu - pr_vlsdeved;
          -- Zerar o saldo devedor
          pr_vlsdeved := 0;
        END IF;
      END IF;
      -- Copiar para a saída os juros calculados
      pr_vljurmes := vr_vljurmes;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        pr_cdcritic := NVL(pr_cdcritic, 0);
        pr_des_erro := vr_des_erro;
      WHEN OTHERS THEN
        -- Montar mensagem com o sqlerrm pois ocorreu um erro crítico
        pr_cdcritic := NVL(pr_cdcritic, 0);
        pr_des_erro := 'Problemas no procedimento empr0001.pc_leitura_lem. Erro: ' ||
                       sqlerrm;
    END;
  END pc_leitura_lem;
	
  -- Subrotina para checar a existencia de lote cfme tipo passado
  PROCEDURE pc_cria_craplot(pr_dtmvtolt   IN craplot.dtmvtolt%TYPE
                           ,pr_nrdolote   IN craplot.nrdolote%TYPE
                           ,pr_tplotmov   IN craplot.tplotmov%TYPE
                           ,pr_cdcooper   IN craplot.cdcooper%TYPE
                           ,pr_rw_craplot IN OUT NOCOPY cr_craplot%ROWTYPE
                           ,pr_dscritic  OUT VARCHAR2) IS
  BEGIN
    -- Buscar as capas de lote cfme lote passado
    OPEN cr_craplot(pr_nrdolote => pr_nrdolote
                   ,pr_dtmvtolt => pr_dtmvtolt
                   ,pr_cdcooper => pr_cdcooper
                   );
    FETCH cr_craplot
     INTO pr_rw_craplot; --> Rowtype passado
    -- Se n?o tiver encontrado
    IF cr_craplot%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_craplot;
      -- Efetuar a inserc?o de um novo registro
      BEGIN
        INSERT INTO craplot(cdcooper
                           ,dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,tplotmov
                           ,nrseqdig
                           ,vlinfodb
                           ,vlcompdb
                           ,qtinfoln
                           ,qtcompln
                           ,vlinfocr
                           ,vlcompcr)
                     VALUES(pr_cdcooper
                           ,pr_dtmvtolt
                           ,vr_cdagenci
                           ,vr_cdbccxlt
                           ,pr_nrdolote --> Cfme enviado
                           ,pr_tplotmov --> Cfme enviado
                           ,0
                           ,0
                           ,0
                           ,0
                           ,0
                           ,0
                           ,0)
                   RETURNING cdcooper
									          ,dtmvtolt
                            ,cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,tplotmov
                            ,nrseqdig
                            ,rowid
                        INTO pr_rw_craplot.cdcooper
												    ,pr_rw_craplot.dtmvtolt
                            ,pr_rw_craplot.cdagenci
                            ,pr_rw_craplot.cdbccxlt
                            ,pr_rw_craplot.nrdolote
                            ,pr_rw_craplot.tplotmov
                            ,pr_rw_craplot.nrseqdig
                            ,pr_rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar erro e fazer rollback
          pr_dscritic := 'Erro ao inserir capas de lotes (craplot), lote: '||pr_nrdolote||'. Detalhes: '||sqlerrm;
      END;
			--
			IF NOT vr_tab_craplot.exists(pr_rw_craplot.cdcooper || pr_rw_craplot.rowid) THEN
				vr_tab_craplot(pr_rw_craplot.cdcooper || pr_rw_craplot.rowid).ds_rowid := pr_rw_craplot.rowid;
				vr_tab_craplot(pr_rw_craplot.cdcooper || pr_rw_craplot.rowid).cdcooper := pr_rw_craplot.cdcooper;
				vr_tab_craplot(pr_rw_craplot.cdcooper || pr_rw_craplot.rowid).vlinfodb := pr_rw_craplot.vlinfodb;
				vr_tab_craplot(pr_rw_craplot.cdcooper || pr_rw_craplot.rowid).vlcompdb := pr_rw_craplot.vlcompdb;
				vr_tab_craplot(pr_rw_craplot.cdcooper || pr_rw_craplot.rowid).qtinfoln := pr_rw_craplot.qtinfoln;
				vr_tab_craplot(pr_rw_craplot.cdcooper || pr_rw_craplot.rowid).qtcompln := pr_rw_craplot.qtcompln;
				vr_tab_craplot(pr_rw_craplot.cdcooper || pr_rw_craplot.rowid).nrseqdig := pr_rw_craplot.nrseqdig;
			END IF;
			--
    ELSE
      -- apenas fechar o cursor
      CLOSE cr_craplot;
    END IF;
  END pc_cria_craplot;
  --
  PROCEDURE pc_gera_lancto(pr_contas   IN cr_contas%ROWTYPE -- rw_crapepr
                          ,pr_crapdat  IN btch0001.rw_crapdat%TYPE -- rw_crapdat
                          ) IS
    -- Cursor lanctos
		CURSOR cr_craplem(pr_cdcooper craplem.cdcooper%TYPE
		                 ,pr_nrdconta craplem.nrdconta%TYPE
										 ,pr_nrctremp craplem.nrctremp%TYPE
										 ,pr_dtmvtolt craplem.dtmvtolt%TYPE
		                 ) IS
		  SELECT sum(lem.vllanmto) vllanmto
			      ,lem.cdhistor
			  FROM craplem lem
 			 WHERE lem.cdcooper = pr_cdcooper
			   AND lem.nrdconta = pr_nrdconta
				 AND lem.nrctremp = pr_nrctremp
				 AND lem.dtmvtolt >= pr_dtmvtolt
		GROUP BY lem.cdhistor;
		--
		rw_craplem cr_craplem%ROWTYPE;
		--
    vr_qtprepag     crapepr.qtprepag%TYPE;
    vr_vlprepag     craplem.vllanmto%TYPE;
    vr_vlsdeved     NUMBER(14,2);
    vr_vljuracu     crapepr.vljuracu%TYPE;
    vr_vljurmes     NUMBER(25,10);
    vr_dtultpag     crapepr.dtultpag%TYPE;
    vr_inliquid     PLS_INTEGER;
    vr_txdjuros     crapepr.txjuremp%TYPE;
    vr_vldabono     NUMBER;                 --> Valor do abono do emprestimo
    vr_vldsobra     NUMBER;                 --> Valor de sobra do emprestimo
    vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS078';
    vr_qtprecal_lem crapepr.qtprecal%TYPE;
    vr_tab_vldabono NUMBER;                 --> Leitura do valor do abono para emprestimos em atraso
    vr_dstextab     craptab.dstextab%TYPE;  --> Busca na craptab
    vr_nrctremp_migrado crawepr.nrctremp%type := 0;
    vr_tab_retorno  lanc0001.typ_reg_retorno;
    vr_incrineg     INTEGER;
    vr_qtmesdec     crapepr.qtmesdec%TYPE;  --> Meses decorridos do emprestimo
    vr_flliqmen     crapepr.flliqmen%TYPE;  --> Indica se o emprestimo foi liquidado no mensal.
    vr_qtcalneg     crapepr.qtprecal%TYPE;  --> Quantidade calculada de parcelas do emprestimo
    vr_qtprecal     crapepr.qtprecal%TYPE;  --> Quantidade calculada para atualizar a tabela
    vr_dtinipag     crapepr.dtinipag%TYPE;  --> Data de inicio do pagamento do emprestimo
    --
    vr_tab_diapagto NUMBER;  -- Dia de pagamento de emprestimo
    vr_tab_dtcalcul DATE;    -- Data de pagamento de emprestimo
    vr_tab_flgfolha BOOLEAN; -- Flag para desconto em folha
    vr_tab_ddmesnov INTEGER; -- Configurac?o para mes novo
    vr_dslinhas VARCHAR2(32767) := '000,';--> Linhas processadas do Restart (inicializada para evitar problemas com null)
    vr_des_reto VARCHAR2(3);
    vr_tab_erro GENE0001.typ_tab_erro;
    --
		vr_cdcooper crapepr.cdcooper%type;
		vr_nrdconta crapepr.nrdconta%type;
		vr_nrctremp crapepr.nrctremp%type;
		vr_vlsdeved_ant crapepr.vlsdeved%type;
		vr_vljuracu_ant crapepr.vljuracu%type;
		--
		vr_rowidcot varchar2(100);
    vr_qtjurmfx crapcot.qtjurmfx%type;
		--
    vr_cdcritic     crapcri.cdcritic%TYPE;
    vr_dscritic     crapcri.dscritic%TYPE;
    --
    vr_exc_undo     EXCEPTION;
		--
  BEGIN		
    -- Busca da moeda UFIR
    OPEN cr_crapmfx(pr_contas.cdcooper
                   ,pr_crapdat.dtmvtopr
                   );
    FETCH cr_crapmfx
     INTO vr_vlmoefix;
    -- Se n?o encontrar
    IF cr_crapmfx%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapmfx;
      -- Gerar critica 140
      vr_cdcritic := 140;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' da UFIR';
      RAISE vr_exc_undo;
    ELSE
      -- Apenas fechar e continuar o process
      CLOSE cr_crapmfx;
    END IF;
    -- Leitura do valor do abono para emprestimos em atraso
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_contas.cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'EMPRATRASO'
                                             ,pr_tpregist => 1);
    -- Se encontrar
    IF vr_dstextab IS NOT NULL THEN
      -- Converter o valor
      vr_tab_vldabono := NVL(gene0002.fn_char_para_number(vr_dstextab),0);
    ELSE
      -- N?o ha abono
      vr_tab_vldabono := 0;
    END IF;
    --
    IF pr_contas.vlsdeved = 0 AND pr_contas.inliquid = 1 AND pr_contas.dtultpag < trunc(pr_crapdat.dtmvtolt,'mm') THEN
      -- Processar o proximo registro
      RETURN;
    END IF;
    -- Se o emprestimo for de prejuizo e a data do prejuizo no mes anterior
    IF pr_contas.inprejuz > 0 AND pr_contas.dtprejuz < trunc(pr_crapdat.dtmvtolt,'mm') THEN
      -- Processar o proximo emprestimo
      RETURN;
    END IF;

    -- Buscar a configuracao de emprestimo cfme a empresa da conta
    empr0001.pc_config_empresti_empresa(pr_cdcooper => pr_contas.cdcooper  --> Codigo da Cooperativa
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --> Data atual
                                       ,pr_nrdconta => pr_contas.nrdconta  --> Numero da conta do emprestimo
                                       ,pr_cdempres => pr_contas.cdempres  --> Buscaremos a configurac?o cfme empresa do emprestimo e n?o do cadastro
                                       ,pr_dtcalcul => vr_tab_dtcalcul     --> Data calculada de pagamento
                                       ,pr_diapagto => vr_tab_diapagto     --> Dia de pagamento das parcelas
                                       ,pr_flgfolha => vr_tab_flgfolha     --> Flag de desconto em folha S/N
                                       ,pr_ddmesnov => vr_tab_ddmesnov     --> Configurac?o para mes novo
                                       ,pr_cdcritic => vr_cdcritic         --> Codigo do erro
                                       ,pr_des_erro => vr_dscritic);       --> Retorno de Erro
    -- Se houve erro na rotina
    IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
      -- Levantar excec?o
      RAISE vr_exc_undo;
    END IF;

    -- Inicialiazacao das variaves para a rotina de calculo
    vr_qtprepag := NVL(pr_contas.qtprepag,0);
    vr_vlprepag := 0;
    vr_vlsdeved := NVL(pr_contas.vlsdeved,0);
    vr_vljuracu := NVL(pr_contas.vljuracu,0);
    vr_vljurmes := 0;
    vr_dtultpag := pr_contas.dtultpag;
    vr_inliquid := pr_contas.inliquid;
		
		-- Cursor para gerar o saldo correto dentro do mês em processamento
		-- para gerar o valor correto de juros
    OPEN cr_craplem(pr_contas.cdcooper
                   ,pr_contas.nrdconta
                   ,pr_contas.nrctremp
                   ,pr_crapdat.dtmvtolt
                   );
    --
    LOOP
      --
      FETCH cr_craplem INTO rw_craplem;
      EXIT WHEN cr_craplem%NOTFOUND;
      --
      IF rw_craplem.cdhistor IN(92, 95) THEN -- PG. EMPR. CX.
				--
				vr_vlsdeved := nvl(vr_vlsdeved, 0) + rw_craplem.vllanmto;
				--
			ELSIF rw_craplem.cdhistor = 98 THEN -- JUROS EMPR.
				--
				vr_vlsdeved := nvl(vr_vlsdeved, 0) - rw_craplem.vllanmto;
				vr_vljuracu := nvl(vr_vljuracu, 0) - rw_craplem.vllanmto;
				--
			END IF;
      --
    END LOOP;
    --
    CLOSE cr_craplem;

    -- Usar taxa cadastrada no emprestimo
    vr_txdjuros := pr_contas.txjuremp;

    -- Zerar valores de abono e sobra
    vr_vldabono := 0;
    vr_vldsobra := 0;

    -- Chamar rotina de calculo externa
    pc_leitura_lem(pr_cdcooper    => pr_contas.cdcooper
									 ,pr_cdprogra    => vr_cdprogra
									 ,pr_rw_crapdat  => pr_crapdat
									 ,pr_nrdconta    => pr_contas.nrdconta
									 ,pr_nrctremp    => pr_contas.nrctremp
									 ,pr_dtcalcul    => null
									 ,pr_diapagto    => vr_tab_diapagto
									 ,pr_txdjuros    => vr_txdjuros
									 ,pr_qtprepag    => vr_qtprepag
									 ,pr_qtprecal    => vr_qtprecal_lem
									 ,pr_vlprepag    => vr_vlprepag
									 ,pr_vljuracu    => vr_vljuracu
									 ,pr_vljurmes    => vr_vljurmes
									 ,pr_vlsdeved    => vr_vlsdeved
									 ,pr_dtultpag    => vr_dtultpag
									 ,pr_cdcritic    => vr_cdcritic
									 ,pr_des_erro    => vr_dscritic);
    
	  --dbms_output.put_line( 'Saldo devedor: ' || vr_vlsdeved );    
    
    -- Se a rotina retornou com erro
    IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
      vr_dscritic := NULL;
      vr_cdcritic := 0;
      -- Gerar excec?o
      RAISE vr_exc_undo;
    END IF;
    -- Se o saldo retornar zerado
    IF vr_vlsdeved = 0 THEN
      -- Flegar indicador de liquidac?o
      vr_inliquid := 1;
    -- Sen?o, se o saldo devedor for inferior a zero
    ELSIF vr_vlsdeved < 0 THEN
			gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Saldo devedor negativo: ' || pr_contas.cdcooper || ', ' || pr_contas.nrdconta || ', ' || pr_contas.nrctremp || chr(10));
      -- Gerar sobra de emprestimo, zerar saldo devedor e flegar
      -- indicador de emprestimo liquidado
      vr_vldsobra := vr_vlsdeved * -1;
      vr_vlsdeved := 0;
      vr_inliquid := 1;
    ELSE -- (Saldo superior a zero)
      -- Se o ultimo pagamento e anterior a 60 dias
      -- e o saldo devedor e inferior ou igual ao valor
      -- parametrizado de abono
      IF vr_dtultpag + 60 < pr_crapdat.dtmvtolt AND vr_vlsdeved <= vr_tab_vldabono THEN
        -- Gerar abono para o emprestimo, zerar saldo devedor
        --  e flegar o indicador de emprestimo liquidado
        vr_vldabono := vr_vlsdeved;
        vr_dtultpag := pr_crapdat.dtmvtolt;
        vr_vlsdeved := 0;
        vr_inliquid := 1;
      END IF;
    END IF;

    -- Se o emprestimo estiver com indicador de liquidado e for debito em folha
    IF pr_contas.inliquid = 1 AND pr_contas.flgpagto = 1 THEN
			gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Contrato liquidado: ' || pr_contas.cdcooper || ', ' || pr_contas.nrdconta || ', ' || pr_contas.nrctremp || chr(10));
    END IF;

    -- Se houver juros negativos calculados
    IF vr_vljurmes < 0 THEN
			gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Juros negativo: ' || pr_contas.cdcooper || ', ' || pr_contas.nrdconta || ', ' || pr_contas.nrctremp || chr(10));
    -- Sen?o, se houver juros calculados
    ELSIF vr_vljurmes > 0 THEN
      -- Testar se ja retornado o registro de capas de lote para 0 8360
      IF rw_craplot_8360.rowid IS NULL THEN
        --
        open cr_crapdat_atu(pr_contas.cdcooper
                           );
        --
        fetch cr_crapdat_atu into rw_crapdat_atu;
        --
        close cr_crapdat_atu;
        -- Chamar rotina para busca-lo, e se n?o encontrar, ira crialo
        pc_cria_craplot(pr_dtmvtolt   => rw_crapdat_atu.dtmvtolt
                       ,pr_nrdolote   => 8360
                       ,pr_tplotmov   => 5
                       ,pr_cdcooper   => pr_contas.cdcooper
                       ,pr_rw_craplot => rw_craplot_8360
                       ,pr_dscritic   => vr_dscritic);
        -- Se houve retorno de erro
        IF vr_dscritic IS NOT NULL THEN
          -- Sair do processo
          RAISE vr_exc_undo;
        END IF;
      END IF;
      --
			IF NOT vr_tab_craplem.exists(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp) THEN
				vr_nrseqdig := vr_nrseqdig + 1;
        vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).cdcooper := pr_contas.cdcooper;
        vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).dtmvtolt := rw_craplot_8360.dtmvtolt;
        vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).cdagenci := rw_craplot_8360.cdagenci;
        vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).cdbccxlt := rw_craplot_8360.cdbccxlt;
				vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).nrdolote := rw_craplot_8360.nrdolote;
				vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).nrdconta := pr_contas.nrdconta;
				vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).nrctremp := pr_contas.nrctremp;
				vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).nrdocmto := pr_contas.nrctremp;
				vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).cdhistor := 98; --> Juros Emp.
				vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).nrseqdig := vr_nrseqdig;--rw_craplot_8360.nrseqdig;
				vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).vllanmto := vr_vljurmes;
				vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).txjurepr := vr_txdjuros;
				vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).dtpagemp := vr_tab_dtcalcul;
				vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).vlpreemp := 0;
			ELSE
					vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).vllanmto := 
					  nvl(vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).vllanmto,0) + vr_vljurmes;
					vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).dtpagemp := vr_tab_dtcalcul;
      END IF;
			-- Atualizar as informac?es no lote utilizado
			BEGIN
				UPDATE craplot
					 SET vlinfodb = vlinfodb + vr_vljurmes
							,vlcompdb = vlinfodb + vr_vljurmes
							,qtinfoln = vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).nrseqdig
							,qtcompln = vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).nrseqdig
							,nrseqdig = vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).nrseqdig
				 WHERE rowid = rw_craplot_8360.rowid;
				 --RETURNING nrseqdig INTO rw_craplot_8360.nrseqdig; -- Atualizamos a sequencia no rowtype
				 --rw_craplot_8360.nrseqdig := rw_craplot_8360.nrseqdig + 1;
				 --dbms_output.put_line('DEPOIS: ' || rw_craplot_8360.nrseqdig);
			EXCEPTION
				WHEN OTHERS THEN
					-- Gerar erro e fazer rollback
					vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot_8360.nrdolote||'. Detalhes: '||sqlerrm;
					RAISE vr_exc_undo;
			END;
			--
			IF vr_tab_craplot.exists(rw_craplot_8360.cdcooper || rw_craplot_8360.rowid) THEN
				vr_tab_craplot(rw_craplot_8360.cdcooper || rw_craplot_8360.rowid).vlinfodb := nvl(vr_tab_craplot(rw_craplot_8360.cdcooper || rw_craplot_8360.rowid).vlinfodb,0) + vr_vljurmes;
				vr_tab_craplot(rw_craplot_8360.cdcooper || rw_craplot_8360.rowid).vlcompdb := nvl(vr_tab_craplot(rw_craplot_8360.cdcooper || rw_craplot_8360.rowid).vlcompdb,0) + vr_vljurmes;
				vr_tab_craplot(rw_craplot_8360.cdcooper || rw_craplot_8360.rowid).qtinfoln := vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).nrseqdig;
				vr_tab_craplot(rw_craplot_8360.cdcooper || rw_craplot_8360.rowid).qtcompln := vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).nrseqdig;
				vr_tab_craplot(rw_craplot_8360.cdcooper || rw_craplot_8360.rowid).nrseqdig := vr_tab_craplem(pr_contas.cdcooper || to_char(rw_craplot_8360.dtmvtolt, 'ddmmyyyy') || pr_contas.nrdconta || pr_contas.nrctremp).nrseqdig;
			END IF;
			--
			select cot.rowid
						,cot.qtjurmfx
        into vr_rowidcot
            ,vr_qtjurmfx
			  from crapcot cot
			 where cot.cdcooper = pr_contas.cdcooper
			   and cot.nrdconta = pr_contas.nrdconta;
			--
			IF NOT vr_tab_crapcot.exists(vr_rowidcot || 'ANTES') THEN
        vr_tab_crapcot(vr_rowidcot || 'ANTES').ds_rowid := vr_rowidcot;
        vr_tab_crapcot(vr_rowidcot || 'ANTES').cdcooper := pr_contas.cdcooper;
        vr_tab_crapcot(vr_rowidcot || 'ANTES').nrdconta := pr_contas.nrdconta;
        vr_tab_crapcot(vr_rowidcot || 'ANTES').qtjurmfx := vr_qtjurmfx;
				vr_tab_crapcot(vr_rowidcot || 'ANTES').dstiporg := 'ANTES';
      END IF;
      -- Atualiza valor dos juros pagos em moeda fixa no crapcot
      BEGIN
        UPDATE crapcot
           SET qtjurmfx = NVL(qtjurmfx,0) + ROUND((vr_vljurmes / vr_vlmoefix),4)
         WHERE cdcooper = pr_contas.cdcooper
           AND nrdconta = pr_contas.nrdconta;
        -- Se n?o atualizou nenhum registro
        IF SQL%ROWCOUNT = 0 THEN
          -- Gerar erro 169 pois n?o existe o registro de cotas
          vr_cdcritic := 169;
          vr_dscritic := gene0001.fn_busca_critica(169) || ' - CONTA = '|| gene0002.fn_mask_conta(pr_contas.nrdconta);
          -- Retornar
          RAISE vr_exc_undo;
        END IF;
				--
				vr_tab_crapcot(vr_rowidcot || 'DEPOIS').ds_rowid := vr_rowidcot;
				vr_tab_crapcot(vr_rowidcot || 'DEPOIS').cdcooper := pr_contas.cdcooper;
				vr_tab_crapcot(vr_rowidcot || 'DEPOIS').nrdconta := pr_contas.nrdconta;
				vr_tab_crapcot(vr_rowidcot || 'DEPOIS').qtjurmfx := NVL(vr_qtjurmfx,0) + ROUND((vr_vljurmes / vr_vlmoefix),4);
				vr_tab_crapcot(vr_rowidcot || 'DEPOIS').dstiporg := 'DEPOIS';
				--
      EXCEPTION
        WHEN vr_exc_undo THEN
          -- Apensar chama-la novamente para o bloco exterior trata-la
          RAISE vr_exc_undo;
        WHEN OTHERS THEN
          -- Gerar erro e fazer rollback
          vr_dscritic := 'Erro ao atualizar juros na cota (crapcot), Conta: '||pr_contas.nrdconta||'. Detalhes: '||sqlerrm;
          RAISE vr_exc_undo;
      END;
    END IF;

    -- Cria lancamento de sobras para o emprestimo
    IF vr_vldsobra > 0 THEN
			gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Contrato com sobras: ' || pr_contas.cdcooper || ', ' || pr_contas.nrdconta || ', ' || pr_contas.nrctremp || chr(10));
    END IF;

    -- Se houve valor de abono
    IF vr_vldabono > 0 THEN
			gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Contrato com abono: ' || pr_contas.cdcooper || ', ' || pr_contas.nrdconta || ', ' || pr_contas.nrctremp || chr(10));
    END IF;

    -- Para contratos do mes corrente
    IF TRUNC(pr_contas.dtmvtolt,'mm') = TRUNC(pr_crapdat.dtmvtolt,'mm') THEN
      -- Inicializa os meses decorridos para os contratos do mes
      -- Para emprestimo em conta corrente
      IF pr_contas.flgpagto = 0 THEN
        -- Quantidade de meses decorrido e a diferenca inteira de meses
        -- entre o mes da data atual e o mes da data do primeiro pagamento
        -- do emprestimo
        -- Obs.: Utilizamos trunc(data,'mm') para usar o primeiro dia do mes
        --       para justamente considerar somente o mes no calculo, sen?o
        --       por ex 30/11 > 20/12 seria 0.6774 e n?o 1 mes
        vr_qtmesdec := months_between(trunc(pr_crapdat.dtmvtolt,'mm'),trunc(pr_contas.dtmvtolt,'mm'));
      ELSE
        -- Se o dia do pagamento emprestimo for superior ao dia de virada do mes da empresa
        IF to_char(pr_contas.dtmvtolt,'dd') >= vr_tab_ddmesnov THEN
          -- Mes novo
          vr_qtmesdec := -2;
        ELSE
          -- Normal
          vr_qtmesdec := -1;
        END IF;
      END IF;
    ELSE
      -- N?o e um contrato do mes corrente, portanto mantem o valor de meses decorridos
      vr_qtmesdec := pr_contas.qtmesdec;
    END IF;
    -- Incrementar a quantidade de meses decorrida encontrada acima
    vr_qtmesdec := vr_qtmesdec + 1;
    -- Se o emprestimo n?o estava liquidado e a flag de liquidac?o foi ativada
    IF pr_contas.inliquid = 0 AND vr_inliquid = 1 THEN
      -- Indica que o emprestimo foi liquidado no mensal.
      vr_flliqmen := 1;
    ELSE
      -- Mantemos o valor da tabela
      vr_flliqmen := pr_contas.flliqmen;
    END IF;
    -- Armazenar a diferenca do da quantidade de parcelas na tabela e da calculada
    vr_qtcalneg := pr_contas.qtprecal + vr_qtprecal_lem;
    -- Se a diferenca for inferior a zero
    IF vr_qtcalneg < 0 THEN
      -- Armazenaremos zero na quantidade calculada de parcelas
      vr_qtprecal := 0;
    ELSE
      -- Armazenaremos a diferenca calculada
      vr_qtprecal := vr_qtcalneg;
    END IF;
    -- Se decorreu-se apenas 1 mes
    IF vr_qtmesdec = 1 THEN
      -- Utilizaremos o primeiro dia do mes corrente
      vr_dtinipag := pr_crapdat.dtinimes;
    ELSE
      -- Manteremos a data de pagamento da tabela
      vr_dtinipag := pr_contas.dtinipag;
    END IF;
		--
		begin
			--
			select epr.cdcooper
			      ,epr.nrdconta
						,epr.nrctremp
						,epr.vlsdeved
						,epr.vljuracu
				into vr_cdcooper
				    ,vr_nrdconta
						,vr_nrctremp
						,vr_vlsdeved_ant
						,vr_vljuracu_ant
			  from crapepr epr
			 where epr.rowid = pr_contas.rowid;
			--
			IF NOT vr_tab_crapepr.exists(pr_contas.rowid || 'ANTES') THEN
        vr_tab_crapepr(pr_contas.rowid || 'ANTES').ds_rowid := pr_contas.rowid;
        vr_tab_crapepr(pr_contas.rowid || 'ANTES').cdcooper := vr_cdcooper;
        vr_tab_crapepr(pr_contas.rowid || 'ANTES').nrdconta := vr_nrdconta;
        vr_tab_crapepr(pr_contas.rowid || 'ANTES').nrctremp := vr_nrctremp;
        vr_tab_crapepr(pr_contas.rowid || 'ANTES').vlsdeved := vr_vlsdeved_ant;
        vr_tab_crapepr(pr_contas.rowid || 'ANTES').vljuracu := vr_vljuracu_ant;
				vr_tab_crapepr(pr_contas.rowid || 'ANTES').dstiporg := 'ANTES';
      END IF;
			--
		end;
    -- Enfim atualizaremos as informac?es na tabela de emprestimo
    BEGIN
      UPDATE crapepr
         SET vlsdeved = vr_vlsdeved
            ,vljuracu = vr_vljuracu
       WHERE rowid = pr_contas.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        -- Gerar erro e fazer rollback
        vr_dscritic := 'Erro ao atualizar o emprestimo (CRAPEPR).'
                    || '- Conta:'||pr_contas.nrdconta || ' CtrEmp:'||pr_contas.nrctremp
                    || '. Detalhes: '||sqlerrm;
        RAISE vr_exc_undo;
    END;
		--
		vr_tab_crapepr(pr_contas.rowid || 'DEPOIS').ds_rowid := pr_contas.rowid;
		vr_tab_crapepr(pr_contas.rowid || 'DEPOIS').cdcooper := vr_cdcooper;
		vr_tab_crapepr(pr_contas.rowid || 'DEPOIS').nrdconta := vr_nrdconta;
		vr_tab_crapepr(pr_contas.rowid || 'DEPOIS').nrctremp := vr_nrctremp;
		vr_tab_crapepr(pr_contas.rowid || 'DEPOIS').vlsdeved := vr_vlsdeved;
		vr_tab_crapepr(pr_contas.rowid || 'DEPOIS').vljuracu := vr_vljuracu;
		vr_tab_crapepr(pr_contas.rowid || 'DEPOIS').dstiporg := 'DEPOIS';
    -- Somente para emprestimos que foram liquidados neste processamento
    IF vr_inliquid = 1 THEN
			gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Contrato liquidado neste processo: ' || pr_contas.cdcooper || ', ' || pr_contas.nrdconta || ', ' || pr_contas.nrctremp || chr(10));
    END IF;

    -- Se a quantidade de meses calculada ficou negativa e foi zerada
    IF vr_qtcalneg < 0 THEN
			gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Quantidade de meses negativa ou zerada: ' || pr_contas.cdcooper || ', ' || pr_contas.nrdconta || ', ' || pr_contas.nrctremp || chr(10));
    END IF;

    -- Se ainda houver saldo devedor ao emprestimo
    IF vr_vlsdeved > 0 THEN
      -- Se a linha atual n?o estiver na lista de linhas para restart
      IF instr(vr_dslinhas,to_char(pr_contas.cdlcremp,'fm0000')||',') <= 0 THEN
        -- Adiciona-la
        vr_dslinhas := vr_dslinhas || to_char(pr_contas.cdlcremp,'fm0000') || ',';
      END IF;
    END IF;
    
    COMMIT;

  EXCEPTION
    WHEN vr_exc_undo THEN
      -- Se foi retornado apenas codigo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descric?o
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Erro: ' || vr_dscritic || chr(10));
      END IF;
      -- Desfazer transacoes desde o ultimo commit
      ROLLBACK;
  END pc_gera_lancto;
  --
BEGIN
  -- Inicializar o CLOB
	vr_texto_crapepr := NULL;
	vr_des_crapepr   := NULL;
	dbms_lob.createtemporary(vr_des_crapepr, TRUE);
	dbms_lob.open(vr_des_crapepr, dbms_lob.lob_readwrite);
	gene0002.pc_escreve_xml(vr_des_crapepr, vr_texto_crapepr, 'rowid;cdcooper;nrdconta;nrctremp;vlsdeved;vljuracu;dstiporg' || chr(10));
      
	vr_texto_craplem := NULL;
	vr_des_craplem   := NULL;
	dbms_lob.createtemporary(vr_des_craplem, TRUE);
	dbms_lob.open(vr_des_craplem, dbms_lob.lob_readwrite);
	gene0002.pc_escreve_xml(vr_des_craplem, vr_texto_craplem, 'cdcooper;dtmvtolt;cdagenci;cdbccxlt;nrdolote;nrdconta;nrctremp;nrdocmto;cdhistor;nrseqdig;vllanmto;txjurepr;dtpagemp;vlpreemp' || chr(10));
      
	vr_texto_crapcot := NULL;
	vr_des_crapcot   := NULL;
	dbms_lob.createtemporary(vr_des_crapcot, TRUE);
	dbms_lob.open(vr_des_crapcot, dbms_lob.lob_readwrite);
	gene0002.pc_escreve_xml(vr_des_crapcot, vr_texto_crapcot, 'rowid;cdcooper;nrdconta;qtjurmfx;dstiporg' || chr(10));
      
	vr_texto_craplot := NULL;
	vr_des_craplot   := NULL;
	dbms_lob.createtemporary(vr_des_craplot, TRUE);
	dbms_lob.open(vr_des_craplot, dbms_lob.lob_readwrite);
	gene0002.pc_escreve_xml(vr_des_craplot, vr_texto_craplot, 'rowid;cdcooper;vlinfodb;vlcompdb;qtinfoln;qtcompln;nrseqdig' || chr(10));
      
	vr_texto_log     := NULL;
	vr_des_log       := NULL;
	dbms_lob.createtemporary(vr_des_log, TRUE);
	dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);
	--
	OPEN cr_crapcop;
	--
	LOOP
		--
		FETCH cr_crapcop INTO rw_crapcop;
		EXIT WHEN cr_crapcop%NOTFOUND;
		--
		vr_nrseqdig := 0;
		rw_craplot_8360.rowid := NULL;
		--
		OPEN cr_meses;
		--
		LOOP
			--
			FETCH cr_meses INTO rw_meses;
			EXIT WHEN cr_meses%NOTFOUND;
			--
			OPEN cr_contas(rw_meses.data
										,rw_crapcop.cdcooper
										);
			--
			LOOP
				--
				FETCH cr_contas INTO rw_contas;
				EXIT WHEN cr_contas%NOTFOUND;
				--
				vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => rw_contas.cdcooper
																									,pr_dtmvtolt => LAST_DAY(rw_meses.data)
																									,pr_tipo     => 'A');
				--
				OPEN cr_crapdat(rw_contas.cdcooper
											 ,vr_dtmvtolt
											 );
				--
				FETCH cr_crapdat INTO rw_crapdat;
				--
				pc_gera_lancto(pr_contas   => rw_contas
											,pr_crapdat  => rw_crapdat
											);
				--
				CLOSE cr_crapdat;
				--
			END LOOP;
			--
			CLOSE cr_contas;
			--
		END LOOP;
		--
		CLOSE cr_meses;
		--
	END LOOP;
	--
	CLOSE cr_crapcop;
	--
	vr_indice_craplem := vr_tab_craplem.first;
  --
  WHILE vr_indice_craplem IS NOT NULL LOOP
		-- Cria lancamento de juros para o emprestimo
		BEGIN
			INSERT INTO craplem(cdcooper
												 ,dtmvtolt
												 ,cdagenci
												 ,cdbccxlt
												 ,nrdolote
												 ,nrdconta
												 ,nrctremp
												 ,nrdocmto
												 ,cdhistor
												 ,nrseqdig
												 ,vllanmto
												 ,txjurepr
												 ,dtpagemp
												 ,vlpreemp
												 )
									 VALUES(vr_tab_craplem(vr_indice_craplem).cdcooper
												 ,vr_tab_craplem(vr_indice_craplem).dtmvtolt
												 ,vr_tab_craplem(vr_indice_craplem).cdagenci
												 ,vr_tab_craplem(vr_indice_craplem).cdbccxlt
												 ,vr_tab_craplem(vr_indice_craplem).nrdolote
												 ,vr_tab_craplem(vr_indice_craplem).nrdconta
												 ,vr_tab_craplem(vr_indice_craplem).nrctremp
												 ,vr_tab_craplem(vr_indice_craplem).nrdocmto
												 ,vr_tab_craplem(vr_indice_craplem).cdhistor
												 ,vr_tab_craplem(vr_indice_craplem).nrseqdig
												 ,vr_tab_craplem(vr_indice_craplem).vllanmto
												 ,vr_tab_craplem(vr_indice_craplem).txjurepr
												 ,vr_tab_craplem(vr_indice_craplem).dtpagemp
												 ,vr_tab_craplem(vr_indice_craplem).vlpreemp
												 );
		  --
		EXCEPTION
			WHEN OTHERS THEN
				vr_dscritic := 'Erro ao criar lancamento de juros para o emprestimo (CRAPLEM) '
										|| '- Conta:'|| vr_tab_craplem(vr_indice_craplem).cdcooper || ' CtrEmp:'||vr_tab_craplem(vr_indice_craplem).nrctremp
										|| '. Detalhes: '||SQLERRM;
				gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, vr_dscritic || chr(10));
		END;
		--
		gene0002.pc_escreve_xml(vr_des_craplem, vr_texto_craplem, vr_tab_craplem(vr_indice_craplem).cdcooper                       || ';' ||
																															to_char(vr_tab_craplem(vr_indice_craplem).dtmvtolt,'dd/mm/yyyy') || ';' ||
																															vr_tab_craplem(vr_indice_craplem).cdagenci                       || ';' ||
																															vr_tab_craplem(vr_indice_craplem).cdbccxlt                       || ';' ||
																															vr_tab_craplem(vr_indice_craplem).nrdolote                       || ';' ||
																															vr_tab_craplem(vr_indice_craplem).nrdconta                       || ';' ||
																															vr_tab_craplem(vr_indice_craplem).nrctremp                       || ';' ||
																															vr_tab_craplem(vr_indice_craplem).nrdocmto                       || ';' ||
																															vr_tab_craplem(vr_indice_craplem).cdhistor                       || ';' ||
																															vr_tab_craplem(vr_indice_craplem).nrseqdig                       || ';' ||
																															to_char(vr_tab_craplem(vr_indice_craplem).vllanmto
																																		 ,'999999990D90'
																																		 ,'NLS_NUMERIC_CHARACTERS = '',.''')                       || ';' ||
																															to_char(vr_tab_craplem(vr_indice_craplem).txjurepr
																																		 ,'999999990D9999990'
																																		 ,'NLS_NUMERIC_CHARACTERS = '',.''')                       || ';' ||
																															to_char(vr_tab_craplem(vr_indice_craplem).dtpagemp,'dd/mm/yyyy') || ';' ||
																															vr_tab_craplem(vr_indice_craplem).vlpreemp || chr(10));
		--
    vr_indice_craplem := vr_tab_craplem.next(vr_indice_craplem);
    --
  END LOOP;
	--
	vr_indice_craplot := vr_tab_craplot.first;
	--
  WHILE vr_indice_craplot IS NOT NULL LOOP
		--
    gene0002.pc_escreve_xml(vr_des_craplot, vr_texto_craplot, vr_tab_craplot(vr_indice_craplot).ds_rowid         || ';' ||
		                                                          vr_tab_craplot(vr_indice_craplot).cdcooper         || ';' ||
		                                                          to_char(vr_tab_craplot(vr_indice_craplot).vlinfodb
																																		 ,'999999990D90'
																																		 ,'NLS_NUMERIC_CHARACTERS = '',.''')         || ';' ||
		                                                          to_char(vr_tab_craplot(vr_indice_craplot).vlcompdb
                                                                     ,'999999990D90'
                                                                     ,'NLS_NUMERIC_CHARACTERS = '',.''')         || ';' ||
																															vr_tab_craplot(vr_indice_craplot).qtinfoln         || ';' ||
																															vr_tab_craplot(vr_indice_craplot).qtcompln         || ';' ||
																															vr_tab_craplot(vr_indice_craplot).nrseqdig || chr(10));
    --
    vr_indice_craplot := vr_tab_craplot.next(vr_indice_craplot);
    --
  END LOOP;
	--
	vr_indice_crapepr := vr_tab_crapepr.first;
	--
	WHILE vr_indice_crapepr IS NOT NULL LOOP
		--
		gene0002.pc_escreve_xml(vr_des_crapepr, vr_texto_crapepr, vr_tab_crapepr(vr_indice_crapepr).ds_rowid         || ';' ||
		                                                          vr_tab_crapepr(vr_indice_crapepr).cdcooper         || ';' ||
																															vr_tab_crapepr(vr_indice_crapepr).nrdconta         || ';' ||
																															vr_tab_crapepr(vr_indice_crapepr).nrctremp         || ';' ||
																															to_char(vr_tab_crapepr(vr_indice_crapepr).vlsdeved
																															       ,'999999990D90'
                                                                     ,'NLS_NUMERIC_CHARACTERS = '',.''')         || ';' ||
																															to_char(vr_tab_crapepr(vr_indice_crapepr).vljuracu
																															       ,'999999990D90'
                                                                     ,'NLS_NUMERIC_CHARACTERS = '',.''')         || ';' ||
																															vr_tab_crapepr(vr_indice_crapepr).dstiporg || chr(10));
		vr_indice_crapepr := vr_tab_crapepr.next(vr_indice_crapepr);
		--
	END LOOP;
	--
  vr_indice_crapcot := vr_tab_crapcot.first;
  --
  WHILE vr_indice_crapcot IS NOT NULL LOOP
		--
    gene0002.pc_escreve_xml(vr_des_crapcot, vr_texto_crapcot, vr_tab_crapcot(vr_indice_crapcot).ds_rowid         || ';' ||
                                                              vr_tab_crapcot(vr_indice_crapcot).cdcooper         || ';' ||
                                                              vr_tab_crapcot(vr_indice_crapcot).nrdconta         || ';' ||
                                                              to_char(vr_tab_crapcot(vr_indice_crapcot).qtjurmfx
                                                                     ,'999999990D90'
                                                                     ,'NLS_NUMERIC_CHARACTERS = '',.''')         || ';' ||
                                                              vr_tab_crapcot(vr_indice_crapcot).dstiporg || chr(10));
    vr_indice_crapcot := vr_tab_crapcot.next(vr_indice_crapcot);
    --
  END LOOP;
	-- Fecha o arquivo
	gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, ' ' || chr(10),TRUE);
	vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/james';
	DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log, vr_dsdireto, 'log_ocorrencias.csv', NLS_CHARSET_ID('UTF8'));
	dbms_lob.close(vr_des_log);
	dbms_lob.freetemporary(vr_des_log);
	
	gene0002.pc_escreve_xml(vr_des_crapepr, vr_texto_crapepr, ' ' || chr(10),TRUE);
	vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/james';
	DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_crapepr, vr_dsdireto, 'log_crapepr.csv', NLS_CHARSET_ID('UTF8'));
	dbms_lob.close(vr_des_crapepr);
	dbms_lob.freetemporary(vr_des_crapepr);
	
	gene0002.pc_escreve_xml(vr_des_craplem, vr_texto_craplem, ' ' || chr(10),TRUE);
	vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/james';
	DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_craplem, vr_dsdireto, 'log_craplem.csv', NLS_CHARSET_ID('UTF8'));
	dbms_lob.close(vr_des_craplem);
	dbms_lob.freetemporary(vr_des_craplem);
	
	gene0002.pc_escreve_xml(vr_des_crapcot, vr_texto_crapcot, ' ' || chr(10),TRUE);
	vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/james';
	DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_crapcot, vr_dsdireto, 'log_crapcot.csv', NLS_CHARSET_ID('UTF8'));
	dbms_lob.close(vr_des_crapcot);
	dbms_lob.freetemporary(vr_des_crapcot);
	
	gene0002.pc_escreve_xml(vr_des_craplot, vr_texto_craplot, ' ' || chr(10),TRUE);
	vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/james';
	DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_craplot, vr_dsdireto, 'log_craplot.csv', NLS_CHARSET_ID('UTF8'));
	dbms_lob.close(vr_des_craplot);
	dbms_lob.freetemporary(vr_des_craplot);
  --
	COMMIT;
	--
END;
0
1
rw_meses.data
