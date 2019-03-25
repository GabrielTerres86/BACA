CREATE OR REPLACE PROCEDURE CECRED.pc_crps656(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN
  /* ..........................................................................

     Programa: PC_CRPS656   (Fontes/crps656.p)
     Sistema : CRIA/ATUALIZA PREJUIZO CYBER
     Sigla   : CRED
     Autor   : James Prust Junior
     Data    : Agosto/2013.                     Ultima atualizacao: 11/01/2019

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Atende a solicitacao 76. Ordem = 3.
                 Criar/Atualizar dados prejuizo na tabela crapcyb.

     Alteracoes: 02/10/2013 - Ajuste no campo qtmesdec para não gravar com valor
                              negativo.(James)

                 28/10/2013 - Ajuste para atualizar o valor do prejuizo
                              quando o contrato estiver liquidado (James)

                 14/11/2013 - Ajuste para nao atualizar as flag de judicial e
                              vip no cyber (James).

                 18/12/2013 -  Conversão Progress >> PLSQL (Petter-Supero)
                 
                 20/12/2013 - Ajuste para atualizar oValor do Prejuízo (James).
                 
                 17/01/2014 - Alteracao referente a integracao Progress X 
                              Dataserver Oracle 
                              Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                              
                 05/02/2014 - Ajuste de atualização de valores no CYBER. (James)
                
                 08/05/2014 - Ajuste no cursor cr_crapepr para buscar todos os emprestimos
                              que a cooperativa for diferente que a CECRED. (James)

                 23/10/2014 - Alteração no cursor "cr_crapcol" para filtrar somente
                              as cooperativas ativas campo "flgativo". (Jaison)
                              
                 14/08/2015 - Projeto Provisao. (James)

                 07/06/2017 - Ajuste da regra que define a origem a ser utilizada. Adequacao
                              da regra para que fique igual a regra existente no pc_crps280_i.
                              Heitor (Mouts) - Chamado 681595

                 15/07/2018 - Incluir dados de prejuizo no cursor de empréstimos
                              Renato Cordeiro (AMcom)

                 22/08/2018 - Correção para gravação dos dados da conta corrente
                              transferida para prejuízo.
                              P450 - Reginaldo/AMcom

                 17/12/2018 - Correção para saldo de prejuizo, apos realizar estorno 
                              do pagamento de prejuízo. (INC0025808 - Gabriel MoutS)
							  
                 11/01/2019 - Adicionado no cursor cr_crapepr uma union com select dos dados de
                              prejuizo do borderô de desconto de títulos (Paulo Penteado GFT)

  ............................................................................. */

  DECLARE
    ------------------------ PL Table ----------------------------
    -- Estrutura para PL Table da tabela CRAPEPR
    TYPE typ_reg_crapepr IS
      RECORD(cdcooper crapepr.cdcooper%TYPE
            ,nrdconta crapepr.nrdconta%TYPE
            ,nrctremp crapepr.nrctremp%TYPE
            ,cdlcremp crapepr.cdlcremp%TYPE
            ,dtprejuz crapepr.dtprejuz%TYPE
            ,vlsdprej crapepr.vlsdprej%TYPE
            ,cdfinemp crapepr.cdfinemp%TYPE
            ,dtmvtolt crapepr.dtmvtolt%TYPE
            ,vlemprst crapepr.vlemprst%TYPE
            ,qtpreemp crapepr.qtpreemp%TYPE
            ,tpdescto crapepr.tpdescto%TYPE
            ,flgpagto crapepr.flgpagto%TYPE
            ,inprejuz crapepr.inprejuz%TYPE
            ,qtmesdec crapepr.qtmesdec%TYPE
            ,inliquid crapepr.inliquid%TYPE
            ,vlsdeved crapepr.vlsdeved%TYPE
            ,qtprecal crapepr.qtprecal%TYPE
            ,vlpreemp crapepr.vlpreemp%TYPE
            ,txjuremp crapepr.txjuremp%TYPE
            ,txmensal crapepr.txmensal%TYPE
            ,cdoricyb NUMBER );
    TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY VARCHAR2(100);

    -- Estrutura para PL Table da tabela CRPACYB
    TYPE typ_reg_crapcyb IS
      RECORD(dtdpagto crapcyb.dtdpagto%TYPE);
    TYPE typ_tab_crapcyb IS TABLE OF typ_reg_crapcyb INDEX BY VARCHAR2(100);

    -- Estrutura para PL Table da tabela CRAPTAB
    TYPE typ_reg_craptab IS
      RECORD(dstextab craptab.dstextab%TYPE
            ,cdcooper craptab.cdcooper%TYPE);
    TYPE typ_tab_craptab IS TABLE OF typ_reg_craptab INDEX BY VARCHAR2(100);

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Código do programa
    vr_cdprogra        CONSTANT crapprg.cdprogra%TYPE := 'CRPS656';

    -- Tratamento de erros
    vr_exc_saida       EXCEPTION;
    vr_exc_fimprg      EXCEPTION;
    vr_cdcritic        PLS_INTEGER;
    vr_dscritic        VARCHAR2(4000);
    rw_crapdat         btch0001.cr_crapdat%ROWTYPE;
    rw_crapdatc        btch0001.cr_crapdat%ROWTYPE;

    ------------------------ VARIAVEIS DE NEGOCIO ----------------------------
    vr_cdorigem        PLS_INTEGER;                    --> Código de origem
    vr_contador        PLS_INTEGER := 0;               --> Contador de iteração
    vr_dtrefere        crapdat.dtultdma%TYPE := NULL;  --> Data de referência
    vr_vlrarras        crapris.vldivida%TYPE := 0;     --> Valor do arras
    vr_dsdrisco        dbms_sql.varchar2_table;        --> Descrição do risco
    vr_nivrisco        VARCHAR2(400);                  --> Risco
    vr_qtdiaris        PLS_INTEGER;                    --> Quantidade de dias
    vr_tab_crapepr     typ_tab_crapepr;                --> PL Table para a tabela CRAPEPR
    vr_tab_crapcyb     typ_tab_crapcyb;                --> PL Table para a tabela CRAPCYB
    vr_index           VARCHAR2(200);                  --> Índice para PL Table
    vr_rowidcyb        VARCHAR2(400);                  --> ROWID dos inserts na CRAPCYB
    vr_flagup          PLS_INTEGER;                    --> Controle de FLAG
    vr_craptabpro      typ_tab_craptab;                --> PL Table para CRAPTAB de provisão
    vr_craptabris      typ_tab_craptab;                --> PL Table para CRAPTAB de risco
    vr_indexpro        VARCHAR2(200);                  --> Indice para provisão
    vr_nrctares        crapass.nrdconta%TYPE;          --> Número da conta de restart
    vr_dsrestar        VARCHAR2(4000);                 --> String genérica com informações para restart
    vr_inrestar        PLS_INTEGER;                    --> Indicador de Restart
    vr_erro_exec       EXCEPTION;                      --> Controle de erros

		vr_dstextab craptab.dstextab%TYPE;
	  vr_pctaxpre NUMBER;
	  vr_valoraux NUMBER;
	  vr_txmensal NUMBER;

    ------------------------------- CURSORES ---------------------------------
    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

   /* Busca listagem das cooperativas */
   CURSOR cr_crapcol IS
     SELECT cop.cdcooper
       FROM crapcop cop
      WHERE cop.cdcooper <> 3
        AND cop.flgativo = 1
     ORDER BY cop.cdcooper;

   /* Busca contratos, contas e desconto de titulos em prejuízo por cooperativa */
   CURSOR cr_crapepr(pr_cdcooper IN crapcyb.cdcooper%TYPE) IS
     SELECT prej.cdcooper,
            prej.nrdconta,
            0 nrborder,
            prej.nrdconta          nrctremp,
            0                      cdlcremp,
            prej.dtinclusao        dtprejuz, --
            prej.vlsdprej + 
						prej.vljur60_ctneg +
			      prej.vljur60_lcred +
		        prej.vljuprej +
						nvl(sld.vliofmes,0) +
						PREJ0003.fn_juros_remun_prov(prej.cdcooper, prej.nrdconta) vlsdprej,
            0                      cdfinemp,
						sld.dtrisclq           dtmvtolt, --
            prej.vldivida_original vlemprst, --
            1                      qtpreemp, --
            0                      tpdescto, --
            0                      flgpagto, --
            1                      inprejuz,
            0                      qtmesdec, -- meses decorridos
            0                      inliquid, --
            0                      vlsdeved, --
            0                      qtprecal, -- qtd prestações pagas
            prej.vldivida_original vlpreemp, --
            0                      txjuremp, --
            0                      txmensal,
            1 cdoricyb
     FROM tbcc_prejuizo prej
         ,crapsld sld
        WHERE prej.dtliquidacao is NULL
				  AND sld.cdcooper = prej.cdcooper
					AND sld.nrdconta = prej.nrdconta
		  AND prej.cdcooper <> pr_cdcooper
     UNION
     SELECT cer.cdcooper
           ,cer.nrdconta
           ,0 nrborder
           ,cer.nrctremp
           ,cer.cdlcremp
           ,cer.dtprejuz
           ,cer.vlsdprej
           ,cer.cdfinemp
           ,cer.dtmvtolt
           ,cer.vlemprst
           ,cer.qtpreemp
           ,cer.tpdescto
           ,cer.flgpagto
           ,cer.inprejuz
           ,cer.qtmesdec
           ,cer.inliquid
           ,cer.vlsdeved
           ,cer.qtprecal
           ,cer.vlpreemp
           ,cer.txjuremp
           ,cer.txmensal
           ,3 cdoricyb
      FROM crapepr cer
      WHERE cer.inprejuz > 0
        AND cer.cdcooper <> pr_cdcooper
     
     UNION
     
     SELECT tdb.cdcooper
           ,tdb.nrdconta
           ,tdb.nrborder
           ,tcy.nrctrdsc nrctremp
           ,0 cdlcremp
           ,bdt.dtprejuz
           ,(tdb.vlsdprej + (tdb.vlttjmpr - tdb.vlpgjmpr)
                          + (tdb.vlttmupr - tdb.vlpgmupr)
                          + (tdb.vljraprj - tdb.vlpgjrpr)
                          + (tdb.vliofprj - tdb.vliofppr)) vlsdprej
           ,0 cdfinemp
           ,NVL(tdb.dtdpagto,tdb.dtdebito) dtmvtolt
           ,tdb.vltitulo vlemprst
           ,1 qtpreemp
           ,0 tpdescto
           ,0 flgpagto
           ,bdt.inprejuz
           ,0 qtmesdec
           ,0 inliquid
           ,0 vlsdeved
           ,0 qtprecal
           ,tdb.vltitulo vlpreemp
           ,ROUND(bdt.txmensal/30,7) txjuremp
           ,bdt.txmensal
           ,4 cdoricyb
       FROM tbdsct_titulo_cyber tcy
           ,craptdb tdb
           ,crapbdt bdt
      WHERE tcy.cdcooper = tdb.cdcooper
        AND tcy.nrdconta = tdb.nrdconta
        AND tcy.nrborder = tdb.nrborder
        AND tcy.nrtitulo = tdb.nrtitulo
        AND tdb.cdcooper = bdt.cdcooper
        AND tdb.nrdconta = bdt.nrdconta
        AND tdb.nrborder = bdt.nrborder
        AND bdt.inprejuz = 1
        AND bdt.cdcooper <> pr_cdcooper

     ORDER BY 1;

    /* Buscar todos os registros do sistema CYBER */
    CURSOR cr_crapcyt IS
      SELECT cyb.cdcooper
            ,cyb.cdorigem
            ,cyb.nrdconta
            ,cyb.nrctremp
            ,cyb.dtdpagto
        FROM crapcyb cyb
      ORDER BY cyb.cdcooper;

    /* Buscar dados da tabela de parâmetros para risco */
    CURSOR cr_craptab(pr_nmsistem IN craptab.nmsistem%TYPE
                     ,pr_tptabela IN craptab.tptabela%TYPE
                     ,pr_cdempres IN craptab.cdempres%TYPE
                     ,pr_cdacesso IN craptab.cdacesso%TYPE
                     ,pr_tpregist IN craptab.tpregist%TYPE) IS
      SELECT ctb.dstextab
            ,ctb.cdcooper
        FROM craptab ctb
       WHERE upper(ctb.nmsistem) = pr_nmsistem
         AND upper(ctb.tptabela) = pr_tptabela
         AND ctb.cdempres        = pr_cdempres
         AND upper(ctb.cdacesso) = pr_cdacesso
         AND ctb.tpregist        = NVL(pr_tpregist,ctb.tpregist)
      ORDER BY ctb.cdcooper;

    /* Buscar dados da central de risco considernado a data de referência, tipo do documento e o valor da dívida */
    CURSOR cr_crapris(pr_cdcooper IN crapris.cdcooper%TYPE
                     ,pr_nrdconta IN crapris.nrdconta%TYPE
                     ,pr_dtrefere IN crapris.dtrefere%TYPE
                     ,pr_vlrarras IN crapris.vldivida%TYPE) IS
      SELECT cris.innivris
            ,cris.dtdrisco
        FROM crapris cris
       WHERE cris.cdcooper = pr_cdcooper
         AND cris.nrdconta = pr_nrdconta
         AND cris.dtrefere = pr_dtrefere
         AND cris.inddocto = 1
         AND (pr_vlrarras IS NULL OR cris.vldivida > pr_vlrarras)
    ORDER BY cris.cdcooper DESC, cris.nrdconta DESC, cris.dtrefere DESC, cris.innivris DESC;
    rw_crapris cr_crapris%ROWTYPE;

    /* Buscar as informações para restart e Rowid para atualização posterior */
    CURSOR cr_crapres IS
      SELECT res.rowid
        FROM crapres res
       WHERE res.cdcooper = pr_cdcooper
         AND res.cdprogra = vr_cdprogra;
    rw_crapres cr_crapres%ROWTYPE;

  BEGIN
    --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;

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
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

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
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    -- Verifica processo de restart
    btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper
                              ,pr_cdprogra  => vr_cdprogra
                              ,pr_flgresta  => pr_flgresta
                              ,pr_nrctares  => vr_nrctares
                              ,pr_dsrestar  => vr_dsrestar
                              ,pr_inrestar  => vr_inrestar
                              ,pr_cdcritic  => vr_cdcritic
                              ,pr_des_erro  => vr_dscritic);

    -- Se encontrou erro, gerar exceção
    IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

		-- Buscar dados da TAB para extração da taxa de juros remuneratórios
     vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 8
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'PAREMPREST'
                                              ,pr_tpregist => 01);
     
     -- Extrai a taxa de juros remuneratórios cadastrada na tela TAB089                                              
		 vr_pctaxpre := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,121,6)),0);
		 --Calcular Juros
		 vr_valoraux    := 1 + (vr_pctaxpre / 100);
		 vr_txmensal := round(POWER(vr_valoraux, 30),2);

    vr_index := NULL;
    vr_contador := 0;
    -- Carregar dados da PL Table CRAPEPR
    FOR reg IN cr_crapepr(pr_cdcooper) LOOP
      -- Montar índice com demarcação de registro pai
      IF vr_index IS NULL THEN
        vr_index := LPAD(reg.cdcooper, 3, '0');
      ELSE
        IF LPAD(reg.cdcooper, 3, '0') <> vr_index THEN
          vr_contador := 0;
          vr_index := LPAD(reg.cdcooper, 3, '0');
        ELSE
          vr_contador := vr_contador + 1;
        END IF;
      END IF;
      
      -- Carregar valores na PL Table
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).cdcooper := reg.cdcooper;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).nrdconta := reg.nrdconta;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).nrctremp := reg.nrctremp;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).cdlcremp := reg.cdlcremp;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).dtprejuz := reg.dtprejuz;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).vlsdprej := reg.vlsdprej;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).cdfinemp := reg.cdfinemp;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).dtmvtolt := reg.dtmvtolt;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).vlemprst := reg.vlemprst;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).qtpreemp := reg.qtpreemp;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).tpdescto := reg.tpdescto;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).flgpagto := reg.flgpagto;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).inprejuz := reg.inprejuz;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).qtmesdec := reg.qtmesdec;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).inliquid := reg.inliquid;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).vlsdeved := reg.vlsdeved;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).qtprecal := reg.qtprecal;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).vlpreemp := reg.vlpreemp;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).cdoricyb := reg.cdoricyb;

			IF reg.nrdconta = reg.nrctremp AND reg.inprejuz = 1 THEN
				vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).txjuremp := vr_pctaxpre;
        vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).txmensal := vr_txmensal;
			ELSE
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).txjuremp := reg.txjuremp;
      vr_tab_crapepr(vr_index || LPAD(vr_contador, 10, '0')).txmensal := reg.txmensal;
			END IF;
    END LOOP;

    -- Carregar dados da PL Table CRAPCYB
    FOR reg IN cr_crapcyt LOOP
      vr_tab_crapcyb(LPAD(reg.cdcooper, 3, '0') ||
                     LPAD(reg.cdorigem, 5, '0') ||
                     LPAD(reg.nrdconta, 15, '0') ||
                     LPAD(reg.nrctremp, 15, '0')).dtdpagto := reg.dtdpagto;
    END LOOP;

    -- Carregar dados da PL Table CRAPTAB para provisão
    vr_contador := 0;
    vr_index := NULL;
    FOR reg IN cr_craptab(pr_nmsistem => 'CRED'
                         ,pr_tptabela => 'GENERI'
                         ,pr_cdempres => 0
                         ,pr_cdacesso => 'PROVISAOCL'
                         ,pr_tpregist => NULL) LOOP
                         
      -- Montar índice com demarcação de registro pai
      IF vr_index IS NULL THEN
        vr_index := LPAD(reg.cdcooper, 3, '0');
      ELSE
        IF LPAD(reg.cdcooper, 3, '0') <> vr_index THEN
          vr_contador := 0;
          vr_index := LPAD(reg.cdcooper, 3, '0');
        ELSE
          vr_contador := vr_contador + 1;
        END IF;
      END IF;
      
      -- Carregar valores
      vr_craptabpro(vr_index || LPAD(vr_contador, 10, '0')).dstextab := reg.dstextab;
      vr_craptabpro(vr_index || LPAD(vr_contador, 10, '0')).cdcooper := reg.cdcooper;
    END LOOP;

    -- Carregar dados da PL Table CRAPTAB para risco
    vr_contador := 0;
    vr_index := NULL;
    FOR reg IN cr_craptab(pr_nmsistem => 'CRED'
                         ,pr_tptabela => 'USUARI'
                         ,pr_cdempres => 11
                         ,pr_cdacesso => 'RISCOBACEN'
                         ,pr_tpregist => 0) LOOP
      -- Montar índice com demarcação de registro pai
      IF vr_index IS NULL THEN
        vr_index := LPAD(reg.cdcooper, 3, '0');
      ELSE
        IF LPAD(reg.cdcooper, 3, '0') <> vr_index THEN
          vr_contador := 0;
          vr_index := LPAD(reg.cdcooper, 3, '0');
        ELSE
          vr_contador := vr_contador + 1;
        END IF;
      END IF;

      -- Carregar valores
      vr_craptabris(vr_index|| LPAD(vr_contador, 10, '0')).dstextab := reg.dstextab;
      vr_craptabris(vr_index|| LPAD(vr_contador, 10, '0')).cdcooper := reg.cdcooper;
    END LOOP;

    -- Gerar listagem de cooperativas
    FOR rw_crapcol IN cr_crapcol LOOP
      -- Cria ponto de salvamento
      SAVEPOINT trans_1;

      -- Verifica se registro existe
      vr_index := LPAD(rw_crapcol.cdcooper, 3, '0') || LPAD('0', 10, '0');
      IF vr_tab_crapepr.exists(vr_index) THEN

        -- Iterar sob todos os registros daquela conta
        LOOP
          -- Controle de saído do LOOP
          EXIT WHEN vr_index IS NULL;

          -- Validar execução do pool do LOOP, pula execução pelo controle do número de conta
          IF vr_inrestar > 0 AND vr_tab_crapepr(vr_index).nrdconta < vr_nrctares THEN
            CONTINUE;
          END IF;

          IF ((vr_tab_crapepr(vr_index).cdcooper = 1) AND  /* 1 - Viacredi */
              (vr_tab_crapepr(vr_index).cdlcremp = 800 OR
               vr_tab_crapepr(vr_index).cdlcremp = 900 OR
               vr_tab_crapepr(vr_index).cdlcremp = 907 OR
               vr_tab_crapepr(vr_index).cdlcremp = 909)) THEN
            vr_cdorigem := 2; -- Desconto
          ELSIF ((vr_tab_crapepr(vr_index).cdcooper = 2)  AND /* 2 - Creditextil */
                 (vr_tab_crapepr(vr_index).cdlcremp = 850 OR
                  vr_tab_crapepr(vr_index).cdlcremp = 900)) THEN
            vr_cdorigem := 2; -- Desconto
          ELSIF ((vr_tab_crapepr(vr_index).cdcooper = 13) AND /* 13 - SCRCRED */
                 (vr_tab_crapepr(vr_index).cdlcremp = 800 OR
                  vr_tab_crapepr(vr_index).cdlcremp = 900 OR
                  vr_tab_crapepr(vr_index).cdlcremp = 903)) THEN
            vr_cdorigem := 2; -- Desconto
          ELSIF (((vr_tab_crapepr(vr_index).cdcooper <> 1) AND (vr_tab_crapepr(vr_index).cdcooper <> 2) AND (vr_tab_crapepr(vr_index).cdcooper <> 13)) AND
                  (vr_tab_crapepr(vr_index).cdlcremp = 800 OR
                   vr_tab_crapepr(vr_index).cdlcremp = 900)) THEN
            vr_cdorigem := 2; -- Desconto
          ELSIF vr_tab_crapepr(vr_index).cdoricyb = 4 THEN
            vr_cdorigem := 4; -- Borderô Desconto de Título
          ELSE
						IF vr_tab_crapepr(vr_index).nrdconta = vr_tab_crapepr(vr_index).nrctremp AND
							 vr_tab_crapepr(vr_index).cdlcremp = 0 THEN
							vr_cdorigem := 1;
						ELSE
            vr_cdorigem := 3;
          END IF;
          END IF;

          -- Validar dados para CRAPTAB de provisão
          vr_indexpro := LPAD(vr_tab_crapepr(vr_index).cdcooper, 3, '0') || LPAD('0', 10, '0');
          IF vr_craptabpro.exists(vr_indexpro) THEN
            -- Itera sobre os registros
            LOOP
              -- Controle de saída para o LOOP
              EXIT WHEN vr_indexpro IS NULL;

              -- Carrega variáveis com o valor para o código do risco e descrição do risco
              vr_contador              := SUBSTR(vr_craptabpro(vr_indexpro).dstextab, 12, 2);
              vr_dsdrisco(vr_contador) := TRIM(SUBSTR(vr_craptabpro(vr_indexpro).dstextab, 8, 3));

              -- Buscar próximo índice verificando se é de outra cooperativa
              IF vr_craptabpro.next(vr_indexpro) IS NOT NULL AND
                vr_craptabpro(vr_indexpro).cdcooper = vr_craptabpro(vr_craptabpro.next(vr_indexpro)).cdcooper THEN
                vr_indexpro := vr_craptabpro.next(vr_indexpro);
              ELSE
                vr_indexpro := NULL;
              END IF;
            END LOOP;
          END IF;

          -- Reinicia o nível do risco e a quantidade de dias para o risco
          vr_dsdrisco(10) := 'H';
          vr_nivrisco     := '';
          vr_qtdiaris     := 0;          
          
          -- Valida busca por dados de risco
          IF vr_craptabris.exists(LPAD(vr_tab_crapepr(vr_index).cdcooper, 3, '0') || LPAD('0', 10, '0')) THEN
            
            -- Buscar datas para a cooperativa de operação
            OPEN btch0001.cr_crapdat(pr_cdcooper => vr_tab_crapepr(vr_index).cdcooper);
            FETCH btch0001.cr_crapdat INTO rw_crapdatc;
            -- Captura valores de data e arras
            vr_dtrefere := rw_crapdatc.dtultdma;
            -- Vamo fechar o cursor
            CLOSE btch0001.cr_crapdat;
                
            vr_vlrarras := SUBSTR(vr_craptabris(LPAD(vr_tab_crapepr(vr_index).cdcooper, 3, '0') ||
                                                LPAD('0', 10, '0')).dstextab, 3, 9);

            -- Busca informações de risco
            OPEN cr_crapris(pr_cdcooper => vr_tab_crapepr(vr_index).cdcooper
                           ,pr_nrdconta => vr_tab_crapepr(vr_index).nrdconta
                           ,pr_dtrefere => vr_dtrefere
                           ,pr_vlrarras => vr_vlrarras);
                               
            FETCH cr_crapris INTO rw_crapris;
            -- Testa se a tupla retornou registros
            IF cr_crapris%FOUND THEN
              CLOSE cr_crapris;
              vr_nivrisco := vr_dsdrisco(rw_crapris.innivris);
              vr_qtdiaris := rw_crapdat.dtmvtolt - rw_crapris.dtdrisco;                  
            ELSE
              CLOSE cr_crapris; 
              -- Busca informações de risco
              OPEN cr_crapris(pr_cdcooper => vr_tab_crapepr(vr_index).cdcooper
                             ,pr_nrdconta => vr_tab_crapepr(vr_index).nrdconta
                             ,pr_dtrefere => vr_dtrefere
                             ,pr_vlrarras => NULL);
                                 
              FETCH cr_crapris INTO rw_crapris;
              -- Testa se a tupla retornou registros
              IF cr_crapris%FOUND THEN                    
                CLOSE cr_crapris;
                    
                /* Quando possuir operacao em Prejuizo, o risco da central sera H */
                IF rw_crapris.innivris = 10 THEN
                  vr_nivrisco := vr_dsdrisco(rw_crapris.innivris);
                ELSE
                  vr_nivrisco := vr_dsdrisco(2);
                END IF;                    
                    
                vr_qtdiaris := rw_crapdat.dtmvtolt - rw_crapris.dtdrisco;
              ELSE
                CLOSE cr_crapris;
              END IF;
                  
            END IF;
                
          END IF;
              
          -- Entrou em prejuizo no dia
          IF vr_tab_crapepr(vr_index).dtprejuz = rw_crapdat.dtmvtolt AND vr_tab_crapepr(vr_index).vlsdprej > 0 THEN
            -- Verificar sistema CYBER.
            -- Realiza o insert e se duplicar o índice único saí da iteração
            BEGIN
              -- Valida o tipo de desconto para acionar o flag
              IF vr_tab_crapepr(vr_index).tpdescto = 2 THEN
                vr_flagup := 1;
              ELSE
                vr_flagup := 0;
              END IF;

              -- Tenta inserir novo registro, caso levante a exceção para registros duplicados irá fazer apenas um UPDATE
              INSERT INTO crapcyb(cdcooper
                                 ,cdorigem
                                 ,nrdconta
                                 ,nrctremp
                                 ,cdagenci
                                 ,cdlcremp
                                 ,cdfinemp
                                 ,dtefetiv
                                 ,vlemprst                                
                                 ,qtpreemp
                                 ,flgconsg
                                 ,flgfolha
                                 ,dtdpagto
                                 ,dtmvtolt)
                VALUES(vr_tab_crapepr(vr_index).cdcooper
                      ,vr_cdorigem
                      ,vr_tab_crapepr(vr_index).nrdconta
                      ,vr_tab_crapepr(vr_index).nrctremp
                      ,0
                      ,vr_tab_crapepr(vr_index).cdlcremp
                      ,vr_tab_crapepr(vr_index).cdfinemp
                      ,vr_tab_crapepr(vr_index).dtmvtolt
                      ,vr_tab_crapepr(vr_index).vlemprst                      
                      ,vr_tab_crapepr(vr_index).qtpreemp
                      ,vr_flagup
                      ,vr_tab_crapepr(vr_index).flgpagto
                      ,rw_crapdat.dtmvtolt
                      ,rw_crapdat.dtmvtolt)
                RETURNING ROWID INTO vr_rowidcyb;

              -- Quando for prejuízo de conta então será feito a baixa do contrato e será enviado
              -- o novo contrato com data do primeiro contrato que é o do AD como sendo a data dtdpagto
              IF vr_tab_crapepr(vr_index).inprejuz = 1 AND vr_tab_crapepr(vr_index).cdlcremp = 100 THEN
                -- Verifica se a tupla retornou erro
                -- Realizar update se existir o registro
                IF vr_tab_crapcyb.exists(LPAD(vr_tab_crapepr(vr_index).cdcooper, 3, '0') ||
                                         LPAD('1', 5, '0') ||
                                         LPAD(vr_tab_crapepr(vr_index).nrdconta, 15, '0') ||
                                         LPAD(vr_tab_crapepr(vr_index).nrdconta, 15, '0')) THEN
                  BEGIN
                    -- Atualização do registro encontrado
                    UPDATE crapcyb cyb
                    SET cyb.dtdpagto = vr_tab_crapcyb(LPAD(vr_tab_crapepr(vr_index).cdcooper, 3, '0') ||
                                                      LPAD('1', 5, '0') ||
                                                      LPAD(vr_tab_crapepr(vr_index).nrdconta, 15, '0') ||
                                                      LPAD(vr_tab_crapepr(vr_index).nrdconta, 15, '0')).dtdpagto
                    WHERE cyb.rowid = vr_rowidcyb;
                  EXCEPTION
                    WHEN OTHERS THEN
                      pr_dscritic := 'Erro ao atualizar a tabela CRAPCYB: ' || SQLERRM;
                      RAISE vr_erro_exec;
                  END;
                ELSIF vr_tab_crapepr(vr_index).inprejuz = 1 AND vr_cdorigem IN (1,4) AND vr_tab_crapepr(vr_index).cdlcremp = 0 THEN
									BEGIN
                    -- Atualização do registro encontrado
                    UPDATE crapcyb cyb
                    SET cyb.dtdpagto = vr_tab_crapepr(vr_index).dtmvtolt
                    WHERE cyb.rowid = vr_rowidcyb;
                  EXCEPTION
                    WHEN OTHERS THEN
                      pr_dscritic := 'Erro ao atualizar a tabela CRAPCYB: ' || SQLERRM;
                      RAISE vr_erro_exec;
                  END;
                END IF;
              END IF;
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                NULL;
              WHEN vr_erro_exec THEN
                pr_cdcritic := 0;
                RAISE vr_exc_saida;
              WHEN OTHERS THEN
                pr_cdcritic := 0;
                pr_dscritic := 'Erro ao inserir dados na tabela CRAPCYB: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Consistir quantidade do mês
            BEGIN
              IF vr_tab_crapepr(vr_index).qtmesdec >= 0 THEN
                -- Atualiza quantidade de meses pelo registro da PL Table
                UPDATE crapcyb cyb
                   SET cyb.qtmesdec = vr_tab_crapepr(vr_index).qtmesdec
                 WHERE cyb.cdcooper = vr_tab_crapepr(vr_index).cdcooper
                   AND cyb.cdorigem = vr_cdorigem
                   AND cyb.nrdconta = vr_tab_crapepr(vr_index).nrdconta
                   AND cyb.nrctremp = vr_tab_crapepr(vr_index).nrctremp;
              ELSE
                -- Atualiza quantidade de meses para ZERO
                UPDATE crapcyb cyb
                   SET cyb.qtmesdec = 0
                 WHERE cyb.cdcooper = vr_tab_crapepr(vr_index).cdcooper
                   AND cyb.cdorigem = vr_cdorigem
                   AND cyb.nrdconta = vr_tab_crapepr(vr_index).nrdconta
                   AND cyb.nrctremp = vr_tab_crapepr(vr_index).nrctremp;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar valores na tabela CRAPCYB: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Consiste indicador de prejuízo
            IF vr_tab_crapepr(vr_index).inprejuz = 1 THEN
                            
              -- Atribuir valores do nível e quantidade de dias do risco
              BEGIN
                UPDATE crapcyb cyb
                   SET cyb.nivrisat = vr_nivrisco
                      ,cyb.qtdiaris = vr_qtdiaris
                 WHERE cyb.cdcooper = vr_tab_crapepr(vr_index).cdcooper
                   AND cyb.cdorigem = vr_cdorigem
                   AND cyb.nrdconta = vr_tab_crapepr(vr_index).nrdconta
                   AND cyb.nrctremp = vr_tab_crapepr(vr_index).nrctremp;
              EXCEPTION
                WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar valor na tabela CRAPCYB: ' || SQLERRM;
                RAISE vr_exc_saida;
              END;
            END IF;

            -- Atribuir flag para saldo devedor maior e igual a zero com liquidação zero
            IF vr_tab_crapepr(vr_index).inliquid  = 0 AND
               vr_tab_crapepr(vr_index).vlsdeved >= 0 AND
               vr_tab_crapepr(vr_index).qtprecal >= vr_tab_crapepr(vr_index).qtpreemp THEN
              vr_flagup := 1;
            ELSE
              vr_flagup := 0;
            END IF;

            -- Atualizar tabela do sistema CYBER com informações coletadas do risco e prejuízo calculado
            BEGIN
              UPDATE crapcyb cyb
                 SET cyb.vlsdevan = cyb.vlsdeved
                    ,cyb.vlsdeved = vr_tab_crapepr(vr_index).vlsdeved
                    ,cyb.qtprepag = vr_tab_crapepr(vr_index).qtprecal
                    ,cyb.txmensal = vr_tab_crapepr(vr_index).txmensal
                    ,cyb.txdiaria = vr_tab_crapepr(vr_index).txjuremp
                    ,cyb.dtprejuz = vr_tab_crapepr(vr_index).dtprejuz
                    ,cyb.vlpreemp = vr_tab_crapepr(vr_index).vlpreemp
                    ,cyb.flgpreju = vr_tab_crapepr(vr_index).inprejuz
                    ,cyb.vlsdprea = cyb.vlsdprej
                    ,cyb.vlsdprej = vr_tab_crapepr(vr_index).vlsdprej
                    ,cyb.vlprapga = cyb.vlpreapg
                    ,cyb.vlpreapg = 0
                    ,cyb.vlprepag = 0
                    ,cyb.qtpreatr = 0
                    ,cyb.vljura60 = 0
                    ,cyb.qtdiaatr = 0
                    ,cyb.vldespes = 0
                    ,cyb.vlperris = 0
                    ,cyb.dtdbaixa = null
                    ,cyb.flgresid = vr_flagup
               WHERE cyb.cdcooper = vr_tab_crapepr(vr_index).cdcooper
                 AND cyb.cdorigem = vr_cdorigem
                 AND cyb.nrdconta = vr_tab_crapepr(vr_index).nrdconta
                 AND cyb.nrctremp = vr_tab_crapepr(vr_index).nrctremp;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar dados na tabela CRAPCYB: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          ELSE
            -- Contrato do prejuizo foi liquidado
            IF vr_tab_crapepr(vr_index).dtprejuz < rw_crapdat.dtmvtolt THEN

              -- Atribuir flag para saldo devedor maior e igual a zero com liquidação zero
              IF vr_tab_crapepr(vr_index).inliquid  = 0 AND
                 vr_tab_crapepr(vr_index).vlsdeved >= 0 AND
                 vr_tab_crapepr(vr_index).qtprecal >= vr_tab_crapepr(vr_index).qtpreemp THEN
                vr_flagup := 1;
              ELSE
                vr_flagup := 0;
              END IF;
			  
              -- Fazer tratamento de baixas com estorno posterior (Gabriel)
              IF vr_tab_crapepr(vr_index).vlsdprej > 0 THEN

                BEGIN
                  UPDATE crapcyb cyb
                     SET cyb.dtdbaixa = NULL
                       , cyb.dtmancad = rw_crapdat.dtmvtolt
                       , cyb.dtmanavl = rw_crapdat.dtmvtolt
                       , cyb.dtmangar = rw_crapdat.dtmvtolt
                   WHERE cyb.cdcooper = vr_tab_crapepr(vr_index).cdcooper
                     AND cyb.cdorigem = vr_cdorigem /* Ou forcar origem 3? */
                   --AND cyb.cdorigem = 3
                     AND cyb.nrdconta = vr_tab_crapepr(vr_index).nrdconta
                     AND cyb.nrctremp = vr_tab_crapepr(vr_index).nrctremp
                     AND cyb.vlsdprej = 0          /* Se comentar aumenta um registro */
                     AND cyb.dtdbaixa IS NOT NULL; /* Ou forcar acima de 2018? */
                   --AND cyb.dtdbaixa > '01/01/2018'
                     
                EXCEPTION
                  WHEN OTHERS THEN
                    pr_dscritic := 'Erro ao atualizar na tabela CRAPCYB(1): ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
                
              END IF;    

              -- Atualizar valores do sistema CYBER com informações coletadas do risco e prejuízo calculado
              BEGIN
                UPDATE crapcyb cyb
                SET cyb.vlsdprea = cyb.vlsdprej
                   ,cyb.vlsdprej = vr_tab_crapepr(vr_index).vlsdprej
                   ,cyb.vlsdevan = cyb.vlsdeved
                   ,cyb.vlsdeved = vr_tab_crapepr(vr_index).vlsdeved
                   ,cyb.qtprepag = vr_tab_crapepr(vr_index).qtprecal
                   ,cyb.txmensal = vr_tab_crapepr(vr_index).txmensal
                   ,cyb.txdiaria = vr_tab_crapepr(vr_index).txjuremp
                   ,cyb.vlpreemp = vr_tab_crapepr(vr_index).vlpreemp
                   ,cyb.flgpreju = vr_tab_crapepr(vr_index).inprejuz
									 ,cyb.dtprejuz = vr_tab_crapepr(vr_index).dtprejuz
                   ,cyb.flgresid = vr_flagup
                   ,cyb.nivrisat = vr_nivrisco
                   ,cyb.qtdiaris = vr_qtdiaris
                WHERE cyb.cdcooper = vr_tab_crapepr(vr_index).cdcooper
                  AND cyb.cdorigem = vr_cdorigem
                  AND cyb.nrdconta = vr_tab_crapepr(vr_index).nrdconta
                  AND cyb.nrctremp = vr_tab_crapepr(vr_index).nrctremp
                  AND cyb.dtdbaixa IS NULL;
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao atualizar na tabela CRAPCYB: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;

              IF vr_tab_crapepr(vr_index).inprejuz = 1 AND vr_cdorigem IN (1,4) AND vr_tab_crapepr(vr_index).cdlcremp = 0 THEN
								UPDATE crapcyb cyb
                SET cyb.dtdpagto = vr_tab_crapepr(vr_index).dtmvtolt
                WHERE cyb.cdcooper = vr_tab_crapepr(vr_index).cdcooper
                  AND cyb.cdorigem = vr_cdorigem
                  AND cyb.nrdconta = vr_tab_crapepr(vr_index).nrdconta
                  AND cyb.nrctremp = vr_tab_crapepr(vr_index).nrctremp
                  AND cyb.dtdbaixa IS NULL;
            END IF;
            END IF;
          END IF;

          -- Somente se a flag de restart estiver ativa
          IF pr_flgresta = 1 THEN
            -- Buscar as informações para restart e Rowid para atualização posterior
            OPEN cr_crapres;
            FETCH cr_crapres INTO rw_crapres;

            -- Se não tiver encontrador
            IF cr_crapres%NOTFOUND THEN
              -- Fechar o cursor e gerar erro
              CLOSE cr_crapres;
              -- Volta dados gerados
              ROLLBACK TO SAVEPOINT trans_1;

              -- Montar mensagem de critica
              vr_cdcritic := 151;
              RAISE vr_exc_saida;
            ELSE
              -- Apenas fechar o cursor para continuar
              CLOSE cr_crapres;
            END IF;
          END IF;

          -- Somente se a flag de restart estiver ativa
          IF pr_flgresta = 1 THEN
            -- Atualizar a tabela de restart
            BEGIN
              UPDATE crapres res
                 SET res.nrdconta = vr_tab_crapepr(vr_index).nrdconta
                    ,res.dsrestar = vr_tab_crapepr(vr_index).nrctremp
               WHERE res.rowid = rw_crapres.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_cdcritic := 151;
                vr_dscritic := gene0001.fn_busca_critica(151) || ' - Conta:' || vr_tab_crapepr(vr_index).nrdconta ||
                               '. Detalhes: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            -- Finalmente efetua commit
            COMMIT;
          END IF;

          -- Gerar próximo índice
          IF vr_tab_crapepr.next(vr_index) IS NOT NULL AND
             vr_tab_crapepr(vr_index).cdcooper = vr_tab_crapepr(vr_tab_crapepr.next(vr_index)).cdcooper THEN
            vr_index := vr_tab_crapepr.next(vr_index);
          ELSE
            vr_index := NULL;
          END IF;
        END LOOP;
      END IF;
    END LOOP;

    -- Chamar rotina para eliminação do restart para evitarmos
    -- reprocessamento das empréstimos indevidamente
    btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                               ,pr_cdprogra => vr_cdprogra   --> Código do programa
                               ,pr_flgresta => pr_flgresta   --> Indicador de restart
                               ,pr_des_erro => vr_dscritic); --> Saída de erro

    -- Verifica se ocorreram erros
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------
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
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' || vr_dscritic );

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
      pr_dscritic := SQLERRM;

      -- Efetuar rollback
      ROLLBACK;
  END;
END pc_crps656;
/
