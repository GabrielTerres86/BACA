CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS362(pr_cdcooper  IN  crapcop.cdcooper%TYPE   --> Cooperativa
                                             ,pr_flgresta  IN PLS_INTEGER              --> Indicador de restart
                                             ,pr_stprogra  OUT PLS_INTEGER             --> Saída de termino da execução
                                             ,pr_infimsol  OUT PLS_INTEGER             --> Saída de termino da solicitação
                                             ,pr_cdcritic  OUT NUMBER                  --> Código crítica
                                             ,pr_dscritic  OUT VARCHAR2) IS            --> Descrição crítica
BEGIN
  /* ..........................................................................

   Programa: PC_CRPS362  (Antigo: Fontes/crps362.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Outubro/2003                        Ultima atualizacao: 22/09/2014

   Dados referentes ao programa:

   Frequencia: Diario. Paralelo.
   Objetivo  : Atende a solicitacao 88(Processa sempre dia anterior e nao roda
               no primeiro dia util do mes).
               Gerar cadastro de informacoes gerenciais(Diario). - p/agencia
               Ordem do programa na solicitacao 227.

   Alteracoes: 30/06/2005 - Alimentado campo cdcooper da tabela crapacc (Diego).

               29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapacc (Diego).

               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               03/03/2006 - Acerto em lancamentos (Diego).

               20/03/2006 - Ajustes para melhorar a performance (Edson).

               14/11/2006 - Otimizacao do programa e juncao do crps363
                            (Evandro).

               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                          - Contablizar desconto de titulos e juros do
                            desconto de titulos (Gabriel).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               08/03/2010 - Alteracao Historico (Gati)

               27/06/2011 - Consulta na crapltr desconsiderando alguns
                            historicos, pois, os lancamentos referentes aos
                            mesmos ja constam na craplcm. (Fabricio)

               26/04/2012 - Limpar variavel glb_cdcritic apos uso (David).

               05/06/2013 - Adicionados valores de multa e juros ao valor total
                            das faturas, para DARFs (Lucas)

               14/06/2013 - Conversão Progress >> PL/SQL (Oracle). Petter - Supero.

               09/08/2013 - Inclusão de teste na pr_flgresta antes de controlar
                            o restart (Marcos-Supero)

               25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)
                          - Limpar parametros de saida de critica no caso da
                            exceção vr_exc_fimprg (Marcos-Supero)

               06/01/2014 - Correção na chamada da last_day, removendo o to_char, pois isto
                            implicava em invalid_moth (Marcos-Supero)
														
							 22/09/2014 - Acrescentado leitura da tabela craplac. (Reinert)								

............................................................................. */
  DECLARE
    -- PL Table para manter dados sobre os PACs/empresa
    TYPE typ_reg_pac IS
      RECORD(cdagenci    PLS_INTEGER
            ,cdempres    PLS_INTEGER
            ,cod_hist    PLS_INTEGER
            ,vr_qtlanmto PLS_INTEGER
            ,vr_vllanmto NUMBER(25,10));
    TYPE typ_tab_pac IS TABLE OF typ_reg_pac INDEX BY VARCHAR2(25);

    -- PL Table para manter dados da tabela CRAPASS
    TYPE typ_reg_crapass IS
      RECORD(inpessoa crapass.inpessoa%TYPE
            ,cdagenci crapass.cdagenci%TYPE);
    TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY VARCHAR2(15);

    -- PL Table para manter dados da tabela CRAPTTL
    TYPE typ_reg_crapttl IS
      RECORD(cdempres crapttl.cdempres%TYPE);
    TYPE typ_tab_crapttl IS TABLE OF typ_reg_crapttl INDEX BY VARCHAR2(15);

    -- PL Table para manter dados da tabela CRAPTTL
    TYPE typ_reg_crapjur IS
      RECORD(cdempres crapjur.cdempres%TYPE);
    TYPE typ_tab_crapjur IS TABLE OF typ_reg_crapjur INDEX BY VARCHAR2(15);

    vr_cdlanmto     PLS_INTEGER;                 --> Código do lançamento
    vr_flgprimes    BOOLEAN;                     --> Flag de primeiro mês
    vr_vllanmto     NUMBER(25,10);               --> Valor lançamento
    vr_dtdiault     DATE;                        --> Data do último dia do mês
    vr_cdempres     PLS_INTEGER;                 --> Código empresa
    vr_tab_pac      typ_tab_pac;                 --> PL Table para manter dados do PAC
    vr_tab_emp      typ_tab_pac;                 --> PL Table para manter dados da empresa
    vr_tab_pac_fil  typ_tab_pac;                 --> PL Table para PAC´s filtrada por conta
    vr_tab_emp_fil  typ_tab_pac;                 --> PL Table para manter dados da empresa filtrados
    vr_exc_erro     EXCEPTION;                   --> Controle de erros
    rw_crapdat      btch0001.cr_crapdat%ROWTYPE; --> Tipo para receber o fetch de dados
    vr_exc_fim      EXCEPTION;                   --> Controle para finalizar processo
    vr_tab_crapass  typ_tab_crapass;             --> PL Table para manter os dados da CRAPASS
    vr_tab_crapttl  typ_tab_crapttl;             --> PL Table para manter os dados da CRAPTTL
    vr_tab_crapjur  typ_tab_crapjur;             --> PL Table para manter os dados da CRAPJUR
    vr_index        VARCHAR2(35);                --> Índice para a PL Table CRAPACC
    vr_nrctares     crapass.nrdconta%TYPE;       --> Número da conta de restart
    vr_dsrestar     VARCHAR2(4000);              --> String genérica com informações para restart
    vr_inrestar     INTEGER;                     --> Indicador de Restart
    vr_indpac       VARCHAR2(25);                --> Índice para a PL Table de PAC´s/empresa
    vr_saida        EXCEPTION;                   --> Controle de saída para exceção tratada

    /* Definições iniciais para a execução */
    vr_cdprogra    VARCHAR2(50) := 'CRPS362';   --> Nome do programa

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Busca dados dos associados */
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT ca.inpessoa
            ,ca.nrdconta
            ,ca.cdagenci
      FROM crapass ca
      WHERE ca.cdcooper = pr_cdcooper;

    /* Busca dados do cadastro dos titulares de conta */
    CURSOR cr_crapttl(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cl.cdempres
            ,cl.nrdconta
      FROM crapttl cl
      WHERE cl.cdcooper = pr_cdcooper
        AND cl.idseqttl = 1;

    /* Busca dados sobre os juros */
    CURSOR cr_crapjur(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cr.cdempres
            ,cr.nrdconta
      FROM crapjur cr
      WHERE cr.cdcooper = pr_cdcooper;

    /* Busca dados de lançamentos de depósitos a vista */
    CURSOR cr_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN craplcm.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT cm.nrdconta
            ,cm.cdhistor
            ,cm.vllanmto
      FROM craplcm cm
      WHERE cm.dtmvtolt = pr_dtmvtoan
        AND cm.nrdconta > 0
        AND cm.cdcooper = pr_cdcooper
      ORDER BY cm.CDCOOPER, cm.nrdconta, cm.DTMVTOLT, cm.CDHISTOR, cm.vllanmto;

    /* Busca dados de lançamentos de empréstimos */
    CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN craplem.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT ce.nrdconta
            ,ce.cdhistor
            ,ce.vllanmto
      FROM craplem ce
      WHERE ce.dtmvtolt = pr_dtmvtoan
        AND ce.cdcooper = pr_cdcooper
      ORDER BY ce.CDCOOPER, ce.nrdconta, ce.DTMVTOLT, ce.CDHISTOR, ce.vllanmto;

    /* Busca dados de lançamentos de cotas/capitais */
    CURSOR cr_craplct(pr_cdcooper IN craplct.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN craplct.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT ct.nrdconta
            ,ct.cdhistor
            ,ct.vllanmto
      FROM craplct ct
      WHERE ct.dtmvtolt = pr_dtmvtoan
        AND ct.cdcooper = pr_cdcooper
      ORDER BY ct.CDCOOPER, ct.nrdconta, ct.DTMVTOLT, ct.CDHISTOR, ct.vllanmto;

    /* Busca dados de lançamentos de aplicações RDCA */
    CURSOR cr_craplap(pr_cdcooper IN craplct.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN craplct.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT cp.nrdconta
            ,cp.cdhistor
            ,cp.vllanmto
      FROM craplap cp
      WHERE cp.dtmvtolt = pr_dtmvtoan
        AND cp.cdcooper = pr_cdcooper
      ORDER BY cp.CDCOOPER, cp.nrdconta, cp.DTMVTOLT, cp.CDHISTOR, cp.vllanmto;
			
		-- Busca dados de lançamentos de aplicações de captação
		CURSOR cr_craplac(pr_cdcooper IN crapcop.cdcooper%TYPE         -- Cód. cooper.
		                 ,pr_dtmvtoan IN crapdat.dtmvtolt%TYPE) IS     -- Data de movimento anterior
			SELECT lac.nrdconta
			      ,lac.cdhistor
						,lac.vllanmto
			 FROM craplac lac
			WHERE lac.dtmvtolt = pr_dtmvtoan
			  AND lac.cdcooper = pr_cdcooper
			ORDER BY lac.cdcooper, lac.nrdconta, lac.dtmvtolt, lac.cdhistor, lac.vllanmto;
										 
    /* Busca dados de lançamentos automáticos */
    CURSOR cr_craplau(pr_cdcooper IN craplct.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN craplct.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT cu.nrdconta
            ,cu.cdhistor
            ,cu.vllanaut
      FROM craplau cu
      WHERE cu.dtmvtolt = pr_dtmvtoan
        AND cu.cdcooper = pr_cdcooper
      ORDER BY cu.CDCOOPER, cu.nrdconta, cu.DTMVTOLT, cu.CDAGENCI, cu.CDBCCXLT, cu.NRDOLOTE, cu.NRSEQDIG, cu.vllanaut;

    /* Busca dados de lançamentos de cobrança */
    CURSOR cr_craplcb(pr_cdcooper IN craplcb.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN craplcb.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT cb.nrdconta
            ,cb.cdhistor
            ,cb.vllanmto
      FROM craplcb cb
      WHERE cb.dtmvtolt = pr_dtmvtoan
        AND cb.cdcooper = pr_cdcooper
      ORDER BY cb.CDCOOPER, cb.nrdconta, cb.DTMVTOLT, cb.CDAGENCI, cb.CDBCCXLT, cb.NRDOLOTE, cb.NRSEQDIG, cb.vllanmto;

    /* Busca dados de lançamentos de conta investimento */
    CURSOR cr_craplci(pr_cdcooper IN craplci.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN craplci.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT ci.nrdconta
            ,ci.cdhistor
            ,ci.vllanmto
      FROM craplci ci
      WHERE ci.dtmvtolt = pr_dtmvtoan
        AND ci.cdcooper = pr_cdcooper
      ORDER BY ci.CDCOOPER, ci.nrdconta, ci.DTMVTOLT, ci.CDAGENCI, ci.CDBCCXLT, ci.NRDOLOTE, ci.NRDCONTA, ci.NRDOCMTO, ci.vllanmto;

    /* Busca dados de lançamentos de poupança programada */
    CURSOR cr_craplpp(pr_cdcooper IN craplci.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN craplci.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT cp.nrdconta
            ,cp.cdhistor
            ,cp.vllanmto
      FROM craplpp cp
      WHERE cp.dtmvtolt = pr_dtmvtoan
        AND cp.cdcooper = pr_cdcooper
      ORDER BY cp.CDCOOPER, cp.nrdconta, cp.DTMVTOLT, cp.CDHISTOR, cp.vllanmto;

    /* Busca dados de transações de caixa e dispensers */
    CURSOR cr_crapltr(pr_cdcooper IN crapltr.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN crapltr.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT ct.nrdconta
            ,ct.cdhistor
            ,ct.vllanmto
      FROM crapltr ct
      WHERE ct.dtmvtolt = pr_dtmvtoan
        AND ct.cdcooper = pr_cdcooper
        AND ct.cdhistor NOT IN (316,375,376,377,767,918,920)
        AND ct.nrdconta > 0
      ORDER BY ct.CDCOOPER, ct.nrdconta, ct.DTMVTOLT, ct.NRSEQUNI, ct.vllanmto;

    /* Busca dados de lançamentos de custódia de cheques */
    CURSOR cr_crapcst(pr_cdcooper IN crapcst.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN crapcst.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT cs.nrdconta
            ,cs.vlcheque
      FROM crapcst cs
      WHERE cs.dtmvtolt = pr_dtmvtoan
        AND cs.cdcooper = pr_cdcooper
      ORDER BY cs.CDCOOPER, cs.nrdconta, cs.DTMVTOLT, cs.CDAGENCI, cs.CDBCCXLT, cs.NRDOLOTE, cs.NRSEQDIG, cs.vlcheque;

    /* Busca dados de cheques do bordero de descontos de cheques */
    CURSOR cr_crapcdb(pr_cdcooper IN crapcdb.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN crapcdb.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT cb.nrdconta
            ,cb.vlliquid
      FROM crapcdb cb
      WHERE cb.dtmvtolt = pr_dtmvtoan
        AND cb.cdcooper = pr_cdcooper
      ORDER BY cb.CDCOOPER, cb.nrdconta, cb.DTMVTOLT, cb.CDAGENCI, cb.CDBCCXLT, cb.NRDOLOTE, cb.NRSEQDIG, cb.vlliquid;

    /* Busca dados de cadastro de borderos de títulos */
    CURSOR cr_crapbdt(pr_cdcooper IN crapbdt.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtolt IN crapbdt.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT cd.nrdconta
            ,cd.nrborder
      FROM crapbdt cd
      WHERE cd.cdcooper = pr_cdcooper
        AND cd.dtmvtolt = pr_dtmvtolt
      ORDER BY cd.CDCOOPER, cd.nrdconta, cd.DTLIBBDT, cd.nrborder;

    /* Busca dados de títulos do bordero de descontos */
    CURSOR cr_craptdb(pr_cdcooper IN craptdb.cdcooper%TYPE     --> Cooperativa
                     ,pr_nrdconta IN craptdb.nrdconta%TYPE     --> Número da conta
                     ,pr_nrborder IN craptdb.nrborder%TYPE) IS --> Borderô
      SELECT cd.nrdconta
            ,cd.vlliquid
      FROM craptdb cd
      WHERE cd.cdcooper = pr_cdcooper
        AND cd.nrdconta = pr_nrdconta
        AND cd.nrborder = pr_nrborder
      ORDER BY cd.CDCOOPER, cd.nrdconta, cd.NRBORDER, cd.CDBANDOC, cd.NRDCTABB, cd.NRCNVCOB, cd.NRDOCMTO, cd.vlliquid;

    /* Busca dados de lançamentos de juros de descontos */
    CURSOR cr_crapljd(pr_cdcooper IN crapcdb.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN crapcdb.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT cj.vlrestit
            ,cj.nrdconta
      FROM crapljd cj
      WHERE cj.dtmvtolt = pr_dtmvtoan
        AND cj.cdcooper = pr_cdcooper
      ORDER BY cj.CDCOOPER, cj.nrdconta, cj.DTREFERE, cj.vlrestit;

    /* Busca dados de autenticações */
	  CURSOR cr_crapaut(pr_cdcooper IN crapcdb.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN crapcdb.dtmvtolt%TYPE) IS --> Data de movimento anterior
	    SELECT ct.cdagenci
	          ,ct.vldocmto
	    FROM crapaut ct
	    WHERE ct.dtmvtolt = pr_dtmvtoan
	      AND ct.cdcooper = pr_cdcooper
      ORDER BY ct.CDCOOPER, ct.cdagenci, ct.DTMVTOLT, ct.CDAGENCI, ct.CDHISTOR, ct.vldocmto;

    /* Busca dados de boletim de caixa para extra-sistema */
    CURSOR cr_craplcx(pr_cdcooper IN crapcdb.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN crapcdb.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT cx.cdagenci
            ,cx.cdhistor
            ,cx.vldocmto
      FROM craplcx cx
      WHERE cx.dtmvtolt = pr_dtmvtoan
        AND cx.cdcooper = pr_cdcooper
      ORDER BY cx.CDCOOPER, cx.cdagenci, cx.DTMVTOLT, cx.CDAGENCI, cx.NRDCAIXA, UPPER(cx.CDOPECXA), cx.NRDOCMTO, cx.vldocmto;

    /* Busca dados de lançamentos de faturas */
    CURSOR cr_craplft(pr_cdcooper IN crapcdb.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN crapcdb.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT (cf.vllanmto + cf.vlrmulta + cf.vlrjuros) vrl_total
            ,cf.cdhistor
            ,cf.cdagenci
      FROM craplft cf
      WHERE cf.dtmvtolt = pr_dtmvtoan
        AND cf.cdcooper = pr_cdcooper
      ORDER BY cf.CDCOOPER, cf.cdagenci, cf.DTMVTOLT, cf.CDAGENCI, cf.CDBCCXLT, cf.NRDOLOTE, cf.CDSEQFAT, cf.vllanmto, cf.vlrmulta, cf.vlrjuros;

    /* Busca dados de titulos */
    CURSOR cr_craptit(pr_cdcooper IN crapcdb.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN crapcdb.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT ci.cdagenci
            ,ci.vldpagto
      FROM craptit ci
      WHERE ci.dtmvtolt = pr_dtmvtoan
        AND ci.cdcooper = pr_cdcooper
      ORDER BY ci.CDCOOPER, ci.cdagenci, ci.DTMVTOLT, ci.CDAGENCI, ci.CDBCCXLT, ci.NRDOLOTE, UPPER(ci.DSCODBAR), ci.vldpagto;

    /* Busca dados de movimento do BBrasil */
    CURSOR cr_crapcbb(pr_cdcooper IN crapcdb.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtoan IN crapcdb.dtmvtolt%TYPE) IS --> Data de movimento anterior
      SELECT cb.flgrgatv
            ,cb.tpdocmto
            ,cb.cdagenci
            ,cb.valorpag
      FROM crapcbb cb
      WHERE cb.dtmvtolt = pr_dtmvtoan
        AND cb.cdcooper = pr_cdcooper
      ORDER BY cb.CDCOOPER, cb.cdagenci, cb.DTMVTOLT, cb.CDAGENCI, cb.CDBCCXLT, cb.NRDOLOTE, cb.FLGRGATV, UPPER(cb.CDBARRAS), cb.NRSEQUEN, cb.valorpag;

    /* Busca dados de informações gerenciais acumuladas */
    CURSOR cr_crapacc(pr_cdcooper IN crapacc.cdcooper%TYPE      --> Cooperativa
                     ,pr_dtrefere IN crapacc.dtrefere%TYPE      --> Data de referência
                     ,pr_cdagenci IN crapacc.cdagenci%TYPE      --> Código agência
                     ,pr_cdempres IN crapacc.cdempres%TYPE      --> Código empresa
                     ,pr_tpregist IN crapacc.tpregist%TYPE      --> Tipo de registro
                     ,pr_cdlanmto IN crapacc.cdlanmto%TYPE) IS  --> Código de lançamento
      SELECT cc.qtlanmto
            ,cc.vllanmto
            ,cc.rowid
            ,cc.cdagenci
            ,cc.dtrefere
            ,cc.cdempres
            ,cc.cdlanmto
            ,cc.cdcooper
            ,cc.tpregist
      FROM crapacc cc
      WHERE cc.cdcooper = pr_cdcooper
        AND cc.dtrefere = pr_dtrefere
        AND cc.cdagenci = pr_cdagenci
        AND cc.cdempres = pr_cdempres
        AND cc.tpregist = pr_tpregist
        AND cc.cdlanmto = pr_cdlanmto;
    rw_crapacc cr_crapacc%ROWTYPE;

    /* Busca dados da conexão e restart */
    CURSOR cr_crapres(pr_cdcooper IN crapcdb.cdcooper%TYPE     --> Cooperativa
                     ,pr_cdprogra IN crapres.cdprogra%TYPE) IS --> Código do programa
      SELECT cr.nrdconta
            ,cr.dsrestar
      FROM crapres cr
      WHERE cr.cdprogra = pr_cdprogra
        AND cr.cdcooper = pr_cdcooper;
    rw_crapres cr_crapres%ROWTYPE;

    /* Procedure para atualizar o controle de restart pelo número da conta */
    PROCEDURE pc_atualiza_restart(pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da conta
                                 ,pr_cdcooper IN crapcdb.cdcooper%TYPE  --> Cooperativa
                                 ,pr_tiporest IN VARCHAR2               --> Tipo de restart
                                 ,pr_cdprogra IN VARCHAR2) IS           --> Identificador do programa
    BEGIN
      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Atualiza o registro de restart
        UPDATE crapres
        SET nrdconta =  pr_nrdconta
           ,dsrestar = pr_tiporest
        WHERE cdprogra = pr_cdprogra
          AND cdcooper = pr_cdcooper;
      END IF;
    END pc_atualiza_restart;

    /* Cria os registros para as tabelas que tem numero da conta */
    PROCEDURE pc_gera_registro(pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da conta
                              ,pr_cdhistor IN craplcm.cdhistor%TYPE  --> Código de histórico
                              ,pr_vllanmto IN crapacc.vllanmto%TYPE  --> Valor lançamento
                              ,pr_cdagenci IN craplcm.cdagenci%TYPE  --> Código da agência
                              ,pr_empresa  IN BOOLEAN                --> Identifica se o registro é de empresa
                              ,pr_des_erro OUT VARCHAR2) IS          --> Saída de erros
    BEGIN
      DECLARE
        vr_index     VARCHAR2(25);          --> Índice para carregar PL Table
        vr_exe_erro  EXCEPTION;             --> Controle de exceção

      BEGIN
        -- Verifica se existe associado para a conta (somente para empresa)
        IF pr_empresa THEN
          IF vr_tab_crapass.exists(lpad(pr_nrdconta, 15, '0')) THEN
            -- Se o tipo da pessoa for 1
            IF vr_tab_crapass(lpad(pr_nrdconta, 15, '0')).inpessoa = 1 THEN
              -- Verifica se existe titular para a conta
              IF vr_tab_crapttl.exists(lpad(pr_nrdconta, 15, '0')) THEN
                -- Atribui valor de empresa
                vr_cdempres := vr_tab_crapttl(lpad(pr_nrdconta, 15, '0')).cdempres;
              END IF;
            ELSE
              -- Verifica se existe registro para juros
              IF vr_tab_crapjur.exists(lpad(pr_nrdconta, 15, '0')) THEN
                -- Atribui valor de empresa
                vr_cdempres := vr_tab_crapjur(lpad(pr_nrdconta, 15, '0')).cdempres;
              END IF;
            END IF;
          ELSE
            -- Montar crítica
            pr_cdcritic := 9;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
            
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')
                                                        ||' - '|| vr_cdprogra 
                                                        ||' --> '|| pr_dscritic
                                                        ||' - Conta: '|| pr_nrdconta );
            
            -- Limpa a critica
            pr_cdcritic := NULL;
            pr_dscritic := NULL;
                                                
            -- Encerra a execução do procedimento
            RETURN;
            
          END IF;

          -- Cria índice para a PL Table selectivo por tipo de lançamento
          vr_index := lpad(vr_tab_crapass(lpad(pr_nrdconta, 15, '0')).cdagenci, 10, '0') || lpad(pr_cdhistor, 15, '0');

          -- Se não existir registro cria PAC, senão atualiza
          IF NOT vr_tab_pac.exists(vr_index) THEN
            -- Cria registro
            vr_tab_pac(vr_index).cdagenci := vr_tab_crapass(lpad(pr_nrdconta, 15, '0')).cdagenci;
            vr_tab_pac(vr_index).cod_hist := pr_cdhistor;
            vr_tab_pac(vr_index).vr_qtlanmto := 1;
            vr_tab_pac(vr_index).vr_vllanmto := pr_vllanmto;
          ELSE
            -- Atualiza registros
            vr_tab_pac(vr_index).vr_qtlanmto := vr_tab_pac(vr_index).vr_qtlanmto + 1;
            vr_tab_pac(vr_index).vr_vllanmto := vr_tab_pac(vr_index).vr_vllanmto + pr_vllanmto;
          END IF;

          -- Cria índice para a PL Table selectivo por tipo de lançamento
          vr_index := lpad(vr_tab_crapass(lpad(pr_nrdconta, 15, '0')).cdagenci, 10, '0') || lpad('9999', 15, '0');

          -- Se não existir registro cria PAC, senão atualiza (para total)
          IF NOT vr_tab_pac.exists(vr_index) THEN
            -- Cria registro
            vr_tab_pac(vr_index).cdagenci := vr_tab_crapass(lpad(pr_nrdconta, 15, '0')).cdagenci;
            vr_tab_pac(vr_index).cod_hist := 9999;
            vr_tab_pac(vr_index).vr_qtlanmto := 1;
            vr_tab_pac(vr_index).vr_vllanmto := pr_vllanmto;
          ELSE
            -- Atualiza registros
            vr_tab_pac(vr_index).vr_qtlanmto := vr_tab_pac(vr_index).vr_qtlanmto + 1;
            vr_tab_pac(vr_index).vr_vllanmto := vr_tab_pac(vr_index).vr_vllanmto + pr_vllanmto;
          END IF;

          -- Cria índice para a PL Table
          vr_index := lpad(vr_cdempres, 10, '0') || lpad(pr_cdhistor, 15, '0');

          -- Se não existir registro cria empresa, senão atualiza
          IF NOT vr_tab_emp.exists(vr_index) THEN
            -- Cria registro
            vr_tab_emp(vr_index).cdempres := vr_cdempres;
            vr_tab_emp(vr_index).cod_hist := pr_cdhistor;
            vr_tab_emp(vr_index).vr_qtlanmto := 1;
            vr_tab_emp(vr_index).vr_vllanmto := pr_vllanmto;
          ELSE
            vr_tab_emp(vr_index).vr_qtlanmto := vr_tab_emp(vr_index).vr_qtlanmto + 1;
            vr_tab_emp(vr_index).vr_vllanmto := vr_tab_emp(vr_index).vr_vllanmto + pr_vllanmto;
          END IF;

          -- Cria índice para a PL Table
          vr_index := lpad(vr_cdempres, 10, '0') || lpad('9999', 15, '0');

          -- Se não existir registro cria empresa totalizadora, senão atualiza
          IF NOT vr_tab_emp.exists(vr_index) THEN
            -- Cria registro
            vr_tab_emp(vr_index).cdempres := vr_cdempres;
            vr_tab_emp(vr_index).cod_hist := 9999;
            vr_tab_emp(vr_index).vr_qtlanmto := 1;
            vr_tab_emp(vr_index).vr_vllanmto := pr_vllanmto;
          ELSE
            vr_tab_emp(vr_index).vr_qtlanmto := vr_tab_emp(vr_index).vr_qtlanmto + 1;
            vr_tab_emp(vr_index).vr_vllanmto := vr_tab_emp(vr_index).vr_vllanmto + pr_vllanmto;
          END IF;
        ELSE
          -- Definir índice
          vr_index := lpad(pr_cdagenci, 10, '0') || lpad(pr_cdhistor, 15, '0');

          -- Se não existir registro cria totalizador do PAC, senão atualiza
          IF NOT vr_tab_pac.exists(vr_index) THEN
            -- Cria registro
            vr_tab_pac(vr_index).cdagenci := pr_cdagenci;
            vr_tab_pac(vr_index).cod_hist := pr_cdhistor;
            vr_tab_pac(vr_index).vr_qtlanmto := 1;
            vr_tab_pac(vr_index).vr_vllanmto := pr_vllanmto;
          ELSE
            -- Atualiza registros
            vr_tab_pac(vr_index).vr_qtlanmto := vr_tab_pac(vr_index).vr_qtlanmto + 1;
            vr_tab_pac(vr_index).vr_vllanmto := vr_tab_pac(vr_index).vr_vllanmto + pr_vllanmto;
          END IF;

          -- Criar registro totalizador para PAC
          vr_index := lpad(pr_cdagenci, 10, '0') || lpad('9999', 15, '0');

           -- Se não existir registro cria totalizador do PAC, senão atualiza
          IF NOT vr_tab_pac.exists(vr_index) THEN
            -- Cria registro
            vr_tab_pac(vr_index).cdagenci := pr_cdagenci;
            vr_tab_pac(vr_index).cod_hist := 9999;
            vr_tab_pac(vr_index).vr_qtlanmto := 1;
            vr_tab_pac(vr_index).vr_vllanmto := pr_vllanmto;
          ELSE
            -- Atualiza registros
            vr_tab_pac(vr_index).vr_qtlanmto := vr_tab_pac(vr_index).vr_qtlanmto + 1;
            vr_tab_pac(vr_index).vr_vllanmto := vr_tab_pac(vr_index).vr_vllanmto + pr_vllanmto;
          END IF;
        END IF;
      EXCEPTION
        WHEN vr_exe_erro THEN
          NULL;
        WHEN OTHERS THEN
          pr_des_erro := 'Erro em PC_CRPS362 --> pc_gera_registro_cont: ' || SQLERRM;
      END;
    END pc_gera_registro;

  BEGIN
    -- Código do programa
    vr_cdprogra := 'CRPS362';

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS362'
                              ,pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      pr_cdcritic := 651;

      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => pr_cdcritic);

    -- Se a variavel de erro é <> 0
    IF pr_cdcritic <> 0 THEN
      -- Buscar descrição da crítica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      -- Envio centralizado de log de erro
      RAISE vr_exc_erro;
    END IF;

    --Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    --Posicionar no proximo registro
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    --Fechar Cursor
    CLOSE btch0001.cr_crapdat;

    -- Atribuir valor do cálculo de datas
    vr_dtdiault := rw_crapdat.dtultdia;

    -- Valida data para atribuir controle de execução
    IF to_char(rw_crapdat.dtmvtolt, 'MM') <> to_char(rw_crapdat.dtmvtoan, 'MM') THEN
      vr_flgprimes := TRUE;
    ELSE
      vr_flgprimes := FALSE;
    END IF;

    -- Tratamento e retorno de valores de restart
    btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper
                              ,pr_cdprogra  => vr_cdprogra
                              ,pr_flgresta  => pr_flgresta
                              ,pr_nrctares  => vr_nrctares
                              ,pr_dsrestar  => vr_dsrestar
                              ,pr_inrestar  => vr_inrestar
                              ,pr_cdcritic  => pr_cdcritic
                              ,pr_des_erro  => pr_dscritic);

    -- Executa processo se for outro mês
    IF vr_flgprimes THEN
      -- Eliminar informações de restart/execução
      btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_flgresta => pr_flgresta
                                 ,pr_des_erro => pr_dscritic);

      -- Testar saída de erro
      IF pr_dscritic IS NOT NULL THEN
        -- Sair do processo
        RAISE vr_exc_erro;
      END IF;

      RAISE vr_exc_fim;
    END IF;

    -- Carrega a PL Table da CRAPASS
    FOR rw_crapass IN cr_crapass(pr_cdcooper) LOOP
      vr_tab_crapass(lpad(rw_crapass.nrdconta, 15, '0')).inpessoa := rw_crapass.inpessoa;
      vr_tab_crapass(lpad(rw_crapass.nrdconta, 15, '0')).cdagenci := rw_crapass.cdagenci;
    END LOOP;

    -- Carrega a PL Table da CRAPTTL
    FOR rw_crapttl IN cr_crapttl(pr_cdcooper) LOOP
      vr_tab_crapttl(lpad(rw_crapttl.nrdconta, 15, '0')).cdempres := rw_crapttl.cdempres;
    END LOOP;

    -- Carrega a PL Table da CRAPJUR
    FOR rw_crapjur IN cr_crapjur(pr_cdcooper) LOOP
      vr_tab_crapjur(lpad(rw_crapjur.nrdconta, 15, '0')).cdempres := rw_crapjur.cdempres;
    END LOOP;

    -- Busca lançamentos de depósitos a vista
    FOR rw_craplcm IN cr_craplcm(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_craplcm.nrdconta
                      ,pr_cdhistor => rw_craplcm.cdhistor
                      ,pr_vllanmto => rw_craplcm.vllanmto
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca lançamentos de empréstimos
    FOR rw_craplem IN cr_craplem(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_craplem.nrdconta
                      ,pr_cdhistor => rw_craplem.cdhistor
                      ,pr_vllanmto => rw_craplem.vllanmto
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de cotas/capitais
    FOR rw_craplct IN cr_craplct(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_craplct.nrdconta
                      ,pr_cdhistor => rw_craplct.cdhistor
                      ,pr_vllanmto => rw_craplct.vllanmto
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de aplicações RDCA
    FOR rw_craplap IN cr_craplap(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_craplap.nrdconta
                      ,pr_cdhistor => rw_craplap.cdhistor
                      ,pr_vllanmto => rw_craplap.vllanmto
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de aplicações de captação
    FOR rw_craplac IN cr_craplac(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_craplac.nrdconta
                      ,pr_cdhistor => rw_craplac.cdhistor
                      ,pr_vllanmto => rw_craplac.vllanmto
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;
		
    -- Busca de lançamentos automáticos
    FOR rw_craplau IN cr_craplau(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_craplau.nrdconta
                      ,pr_cdhistor => rw_craplau.cdhistor
                      ,pr_vllanmto => rw_craplau.vllanaut
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de cobrança
    FOR rw_craplcb IN cr_craplcb(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_craplcb.nrdconta
                      ,pr_cdhistor => rw_craplcb.cdhistor
                      ,pr_vllanmto => rw_craplcb.vllanmto
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de conta investimento
    FOR rw_craplci IN cr_craplci(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_craplci.nrdconta
                      ,pr_cdhistor => rw_craplci.cdhistor
                      ,pr_vllanmto => rw_craplci.vllanmto
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de poupança programada
    FOR rw_craplpp IN cr_craplpp(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_craplpp.nrdconta
                      ,pr_cdhistor => rw_craplpp.cdhistor
                      ,pr_vllanmto => rw_craplpp.vllanmto
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de caixas e dispensers
    FOR rw_crapltr IN cr_crapltr(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_crapltr.nrdconta
                      ,pr_cdhistor => rw_crapltr.cdhistor
                      ,pr_vllanmto => rw_crapltr.vllanmto
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de custódia de cheques
    FOR rw_crapcst IN cr_crapcst(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_crapcst.nrdconta
                      ,pr_cdhistor => 997
                      ,pr_vllanmto => rw_crapcst.vlcheque
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de cheques do borderô de cheques
    FOR rw_crapcdb IN cr_crapcdb(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_crapcdb.nrdconta
                      ,pr_cdhistor => 996
                      ,pr_vllanmto => rw_crapcdb.vlliquid
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca os borderos de descontos
    FOR rw_crapbdt IN cr_crapbdt(pr_cdcooper, rw_crapdat.dtmvtolt) LOOP
      FOR rw_craptdb IN cr_craptdb(pr_cdcooper, rw_crapbdt.nrdconta, rw_crapbdt.nrborder) LOOP
        pc_gera_registro(pr_nrdconta => rw_craptdb.nrdconta
                        ,pr_cdhistor => 992
                        ,pr_vllanmto => rw_craptdb.vlliquid
                        ,pr_cdagenci => NULL
                        ,pr_empresa  => TRUE
                        ,pr_des_erro => pr_dscritic);

        -- Verifica se ocorreram erros
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        pc_gera_registro(pr_nrdconta => rw_craptdb.nrdconta
                        ,pr_cdhistor => 993
                        ,pr_vllanmto => rw_craptdb.vlliquid
                        ,pr_cdagenci => NULL
                        ,pr_empresa  => TRUE
                        ,pr_des_erro => pr_dscritic);

        -- Verifica se ocorreram erros
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END LOOP;
    END LOOP;

    -- Busca de lançamentos de descontos de juros de cheques
    FOR rw_crapljd IN cr_crapljd(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => rw_crapljd.nrdconta
                      ,pr_cdhistor => 998
                      ,pr_vllanmto => rw_crapljd.vlrestit
                      ,pr_cdagenci => NULL
                      ,pr_empresa  => TRUE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    /* Buscar dados somenta para PAC´s */
	  -- Busca de lançamentos de autenticações
    FOR rw_crapaut IN cr_crapaut(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => NULL
                      ,pr_cdhistor => 995
                      ,pr_vllanmto => rw_crapaut.vldocmto
                      ,pr_cdagenci => rw_crapaut.cdagenci
                      ,pr_empresa  => FALSE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de faturas
    FOR rw_craplcx IN cr_craplcx(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => NULL
                      ,pr_cdhistor => rw_craplcx.cdhistor
                      ,pr_vllanmto => rw_craplcx.vldocmto
                      ,pr_cdagenci => rw_craplcx.cdagenci
                      ,pr_empresa  => FALSE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de boletim de caixa para extra-sistema
    FOR rw_craplft IN cr_craplft(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => NULL
                      ,pr_cdhistor => rw_craplft.cdhistor
                      ,pr_vllanmto => rw_craplft.vrl_total
                      ,pr_cdagenci => rw_craplft.cdagenci
                      ,pr_empresa  => FALSE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de boletim de caixa para extra-sistema
    FOR rw_craptit IN cr_craptit(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      pc_gera_registro(pr_nrdconta => NULL
                      ,pr_cdhistor => 994
                      ,pr_vllanmto => rw_craptit.vldpagto
                      ,pr_cdagenci => rw_craptit.cdagenci
                      ,pr_empresa  => FALSE
                      ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    -- Busca de lançamentos de BBrasil
    FOR rw_crapcbb IN cr_crapcbb(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
      IF NOT rw_crapcbb.flgrgatv = 0 OR NOT rw_crapcbb.tpdocmto >= 3 THEN
        pc_gera_registro(pr_nrdconta => NULL
                        ,pr_cdhistor => 750
                        ,pr_vllanmto => rw_crapcbb.valorpag
                        ,pr_cdagenci => rw_crapcbb.cdagenci
                        ,pr_empresa  => FALSE
                        ,pr_des_erro => pr_dscritic);

        -- Verifica se ocorreram erros
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    END LOOP;

    -- Criação dos registros crapacc por PAC
    IF nvl(vr_dsrestar, '99999999') <> 'EMPRESA' THEN
      -- Filtrar registros por número de conta e carregar PL Table
      vr_indpac := vr_tab_pac.first;

      LOOP
        -- Finaliza quando não existir mais índices
        EXIT WHEN vr_indpac IS NULL;

        -- Filtra registros por número de conta
        IF nvl(vr_tab_pac(vr_indpac).cdagenci, 0) > vr_nrctares THEN
          vr_tab_pac_fil(vr_indpac).cdagenci := vr_tab_pac(vr_indpac).cdagenci;
          vr_tab_pac_fil(vr_indpac).cdempres := vr_tab_pac(vr_indpac).cdempres;
          vr_tab_pac_fil(vr_indpac).cod_hist := vr_tab_pac(vr_indpac).cod_hist;
          vr_tab_pac_fil(vr_indpac).vr_qtlanmto := vr_tab_pac(vr_indpac).vr_qtlanmto;
          vr_tab_pac_fil(vr_indpac).vr_vllanmto := vr_tab_pac(vr_indpac).vr_vllanmto;
        END IF;

        -- Busca próximo índece
        vr_indpac := vr_tab_pac.next(vr_indpac);
      END LOOP;

      -- Inicializar indice da PL Table de PAC´s filtrados
      vr_indpac := vr_tab_pac_fil.first;

      LOOP
        BEGIN
          -- Finaliza quando não existir mais índices
          EXIT WHEN vr_indpac IS NULL;

          -- Cria ponto de salvamento
          SAVEPOINT dados;

          -- Atribuir valor
          IF vr_tab_pac_fil(vr_indpac).cod_hist = 9999 THEN
            vr_cdlanmto := 0;
          ELSE
            vr_cdlanmto := vr_tab_pac_fil(vr_indpac).cod_hist;
          END IF;

          -- Valida valor de quantidade de lançamentos
          IF vr_tab_pac_fil(vr_indpac).vr_qtlanmto > 0 THEN
            OPEN cr_crapacc(pr_cdcooper, vr_dtdiault, vr_tab_pac_fil(vr_indpac).cdagenci, 0, 1, vr_cdlanmto);
            FETCH cr_crapacc INTO rw_crapacc;

            -- Verifica se a tupla retornou registros
            IF cr_crapacc%NOTFOUND THEN
              -- Insere valores
              BEGIN
                INSERT INTO crapacc(dtrefere, cdagenci, cdempres, tpregist, cdlanmto, cdcooper, qtlanmto, vllanmto)
                VALUES(vr_dtdiault, vr_tab_pac_fil(vr_indpac).cdagenci, 0, 1, vr_cdlanmto, pr_cdcooper, vr_tab_pac_fil(vr_indpac).vr_qtlanmto, vr_tab_pac_fil(vr_indpac).vr_vllanmto);
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao inserir dados tp. 1: ' || SQLERRM;
                  RAISE vr_saida;
              END;
            ELSE
              BEGIN
                UPDATE crapacc ac
                SET ac.qtlanmto = ac.qtlanmto + vr_tab_pac_fil(vr_indpac).vr_qtlanmto
                   ,ac.vllanmto = ac.vllanmto + vr_tab_pac_fil(vr_indpac).vr_vllanmto
                WHERE ac.cdcooper = pr_cdcooper
                  AND ac.dtrefere = vr_dtdiault
                  AND ac.cdagenci = vr_tab_pac_fil(vr_indpac).cdagenci
                  AND ac.cdempres = 0
                  AND ac.tpregist = 1
                  AND ac.cdlanmto = vr_cdlanmto;
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao atualizar dados tp. 1: ' || SQLERRM;
                  RAISE vr_saida;
              END;
            END IF;

            -- Fechar cursor
            CLOSE cr_crapacc;

            OPEN cr_crapacc(pr_cdcooper, vr_dtdiault,0, 0, 1, vr_cdlanmto);
            FETCH cr_crapacc INTO rw_crapacc;

            -- Verifica se a tupla retornou registros
            IF cr_crapacc%NOTFOUND THEN
              -- Insere valores
              BEGIN
                INSERT INTO crapacc(dtrefere, cdagenci, cdempres, tpregist, cdlanmto, cdcooper, qtlanmto, vllanmto)
                VALUES(vr_dtdiault, 0, 0, 1, vr_cdlanmto, pr_cdcooper, vr_tab_pac_fil(vr_indpac).vr_qtlanmto, vr_tab_pac_fil(vr_indpac).vr_vllanmto);
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao inserir dados tp. 2: ' || SQLERRM;
                  RAISE vr_saida;
              END;
            ELSE
              -- Atualiza valores
              BEGIN
                UPDATE crapacc ac
                SET ac.qtlanmto = ac.qtlanmto + vr_tab_pac_fil(vr_indpac).vr_qtlanmto
                   ,ac.vllanmto = ac.vllanmto + vr_tab_pac_fil(vr_indpac).vr_vllanmto
                WHERE ac.cdcooper = pr_cdcooper
                  AND ac.dtrefere = vr_dtdiault
                  AND ac.cdagenci = 0
                  AND ac.cdempres = 0
                  AND ac.tpregist = 1
                  AND ac.cdlanmto = vr_cdlanmto;
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao atualizar dados tp. 2: ' || SQLERRM;
                  RAISE vr_saida;
              END;
            END IF;

            -- Fechar cursor
            CLOSE cr_crapacc;
          END IF;

          -- Somente se a flag de restart estiver ativa
          IF pr_flgresta = 1 THEN
            -- Buscar dados da conexão e restart
            OPEN cr_crapres(pr_cdcooper, vr_cdprogra);
            FETCH cr_crapres INTO rw_crapres;

            IF cr_crapres%NOTFOUND THEN
              CLOSE cr_crapres;

              -- Gera crítica
              pr_cdcritic := 151;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

              RAISE vr_saida;
            ELSE
              CLOSE cr_crapres;
            END IF;
          END IF;

          -- Executa atualização da tabela de restart
          pc_atualiza_restart(pr_nrdconta => vr_tab_pac_fil(vr_indpac).cdagenci
                             ,pr_cdcooper => pr_cdcooper
                             ,pr_tiporest => 'PAC'
                             ,pr_cdprogra => vr_cdprogra);

          COMMIT;

          -- Busca próximo índice
          vr_indpac := vr_tab_pac_fil.next(vr_indpac);
        EXCEPTION
          WHEN vr_saida THEN
            -- Desfaz último ponto de salvamento
            ROLLBACK TO SAVEPOINT dados;

            RAISE vr_exc_erro;
          WHEN OTHERS THEN
            -- Desfaz último ponto de salvamento
            ROLLBACK TO SAVEPOINT dados;
        END;
      END LOOP;
    END IF;

    -- Primeiro registro
    vr_indpac :=  vr_tab_emp.first;

    LOOP
      -- Condição de saída da iteração
      EXIT WHEN vr_indpac IS NULL;

      -- Filtrar PL Table para criar registros por empresa
      IF nvl(vr_dsrestar, '999999') = 'PAC' OR vr_tab_emp(vr_indpac).cdempres > vr_nrctares THEN
        vr_tab_emp_fil(vr_indpac).cdempres := vr_tab_emp(vr_indpac).cdempres;
        vr_tab_emp_fil(vr_indpac).cdagenci := vr_tab_emp(vr_indpac).cdagenci;
        vr_tab_emp_fil(vr_indpac).cod_hist := vr_tab_emp(vr_indpac).cod_hist;
        vr_tab_emp_fil(vr_indpac).vr_qtlanmto := vr_tab_emp(vr_indpac).vr_qtlanmto;
        vr_tab_emp_fil(vr_indpac).vr_vllanmto := vr_tab_emp(vr_indpac).vr_vllanmto;
      END IF;

      -- Próximo registro
      vr_indpac := vr_tab_emp.next(vr_indpac);
    END LOOP;

    -- Criação dos registros CRAPACC por EMPRESA
    -- Primeiro registro
    vr_indpac :=  vr_tab_emp_fil.first;

    LOOP
      BEGIN
        -- Condição de saída da iteração
        EXIT WHEN vr_indpac IS NULL;

        -- Cria ponto de salvamento
        SAVEPOINT dados;

        -- Segmenta valor pelo código do histórico
        IF vr_tab_emp_fil(vr_indpac).cod_hist = 9999 THEN
          vr_cdlanmto := 0;
        ELSE
          vr_cdlanmto := vr_tab_emp_fil(vr_indpac).cod_hist;
        END IF;

        -- Valida valor da quantidade de lançamento
        IF vr_tab_emp_fil(vr_indpac).vr_qtlanmto > 0 THEN
          OPEN cr_crapacc(pr_cdcooper, vr_dtdiault, 0, vr_tab_emp_fil(vr_indpac).cdempres, 1, vr_cdlanmto);
          FETCH cr_crapacc INTO rw_crapacc;

          -- Verifica se a tupla retornou registro
          IF cr_crapacc%NOTFOUND THEN
            -- Cria registro
            BEGIN
              INSERT INTO crapacc(dtrefere, cdagenci, cdempres, tpregist, cdlanmto, cdcooper, qtlanmto, vllanmto)
              VALUES(vr_dtdiault, 0, vr_tab_emp_fil(vr_indpac).cdempres, 1, vr_cdlanmto, pr_cdcooper, vr_tab_emp_fil(vr_indpac).vr_qtlanmto, vr_tab_emp_fil(vr_indpac).vr_vllanmto);
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao inserir dados tp. 3: ' || SQLERRM;
                RAISE vr_saida;
            END;
          ELSE
            -- Atualiza registro
            BEGIN
              UPDATE crapacc ac
              SET ac.qtlanmto = ac.qtlanmto + vr_tab_emp_fil(vr_indpac).vr_qtlanmto
                 ,ac.vllanmto = ac.vllanmto + vr_tab_emp_fil(vr_indpac).vr_vllanmto
              WHERE ac.cdcooper = pr_cdcooper
                AND ac.dtrefere = vr_dtdiault
                AND ac.cdagenci = 0
                AND ac.cdempres = vr_tab_emp_fil(vr_indpac).cdempres
                AND ac.tpregist = 1
                AND ac.cdlanmto = vr_cdlanmto;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar dados tp. 3: ' || SQLERRM;
                RAISE vr_saida;
            END;
          END IF;

          -- Fechar cursor
          CLOSE cr_crapacc;

          OPEN cr_crapacc(pr_cdcooper, vr_dtdiault, 0, 9999, 1, vr_cdlanmto);
          FETCH cr_crapacc INTO rw_crapacc;

          -- Verifica se a tupla retornou registro
          IF cr_crapacc%NOTFOUND THEN
            -- Cria registro
            BEGIN
              INSERT INTO crapacc(dtrefere, cdagenci, cdempres, tpregist, cdlanmto, cdcooper, qtlanmto, vllanmto)
              VALUES(vr_dtdiault, 0, 9999, 1, vr_cdlanmto, pr_cdcooper, vr_tab_emp_fil(vr_indpac).vr_qtlanmto, vr_tab_emp_fil(vr_indpac).vr_vllanmto);
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao inserir dados tp. 4: ' || SQLERRM;
                RAISE vr_saida;
            END;
          ELSE
            -- Atualiza registro
            BEGIN
              UPDATE crapacc ac
              SET ac.qtlanmto = ac.qtlanmto + vr_tab_emp_fil(vr_indpac).vr_qtlanmto
                 ,ac.vllanmto = ac.vllanmto + vr_tab_emp_fil(vr_indpac).vr_vllanmto
              WHERE ac.cdcooper = pr_cdcooper
                AND ac.dtrefere = vr_dtdiault
                AND ac.cdagenci = 0
                AND ac.cdempres = 9999
                AND ac.tpregist = 1
                AND ac.cdlanmto = vr_cdlanmto;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar dados tp. 4: ' || SQLERRM;
                RAISE vr_saida;
            END;
          END IF;

          -- Fechar cursor
          CLOSE cr_crapacc;
        END IF;

        -- Somente se a flag de restart estiver ativa
        IF pr_flgresta = 1 THEN
          -- Buscar dados da conexão e restart
          OPEN cr_crapres(pr_cdcooper, vr_cdprogra);
          FETCH cr_crapres INTO rw_crapres;

          -- Verifica se a tupla retornou registros
          IF cr_crapres%NOTFOUND THEN
            CLOSE cr_crapres;

            -- Gera crítica
            pr_cdcritic := 151;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

            RAISE vr_saida;
          ELSE
            CLOSE cr_crapres;
          END IF;
        END IF;

        -- Atualizar tabela de restart
        pc_atualiza_restart(pr_nrdconta => vr_tab_emp_fil(vr_indpac).cdempres
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_tiporest => 'EMPRESA'
                           ,pr_cdprogra => vr_cdprogra);

        COMMIT;

        -- Próximo registro
        vr_indpac := vr_tab_emp_fil.next(vr_indpac);
      EXCEPTION
        WHEN vr_saida THEN
          -- Desfaz último ponto de salvamento
          ROLLBACK TO SAVEPOINT dados;

          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          -- Desfaz último ponto de salvamento
          ROLLBACK TO SAVEPOINT dados;

          pr_dscritic := 'Erro: ' || SQLERRM;

          RAISE  vr_exc_erro;
      END;
    END LOOP;

    -- Valida casos de crítica
    IF nvl(pr_cdcritic, 0) > 0 THEN
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    END IF;

    -- Testar saída de erro
    IF pr_dscritic IS NOT NULL THEN
      -- Sair do processo
      RAISE vr_exc_erro;
    END IF;

    -- Eliminar informações de restart/execução
    btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_flgresta => pr_flgresta
                               ,pr_des_erro => pr_dscritic);

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizada
    COMMIT;
  EXCEPTION
    WHEN vr_exc_fim THEN
      -- Se foi retornado apenas código
      IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;

      IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> '|| pr_dscritic );
      END IF;

      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Limpar variaveis de saida de critica pois eh um erro tratado
      pr_cdcritic := 0;
      pr_dscritic := null;

      -- Efetuar commit
      COMMIT;
    WHEN vr_exc_erro THEN
      -- Efetuar rollback
      ROLLBACK;

      -- Se foi retornado apenas código
      IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;

      -- Gerar crítica
      pr_cdcritic := 0;
    WHEN OTHERS THEN
      -- Efetuar rollback
      ROLLBACK;

      -- Gerar crítica
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
  END;
END PC_CRPS362;
/

