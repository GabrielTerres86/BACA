CREATE OR REPLACE PROCEDURE CECRED.pc_crps660(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN
  /* .............................................................................

     Programa: pc_crps660 (Fontes/crps660.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Adriano
     Data    : Outubro/9999                     Ultima atualizacao: 19/07/2019

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : CENTRAL DE RISCO - ATUALIZACAO DADOS PARA 3040

     Alteracoes: 02/12/2014 - Conversão Progress >> PLSQL (Petter-Supero e Andrino-RKAM)
     
                 06/05/2014 - Correção na atribuição da vr_nrcpfcgc onde não havia
                              o substr para garantir o posicionamento correto na busca
                              da pltable de valores posterior (Marcos-Supero)
                              
                 01/07/2014 - Correção na utilização da exceção fimprg (Marcos-Supero) 
                 
                 13/11/2014 - Remoção da verificação do limite cancelado ou não antes de 
                              definir se as modalidades 301 - DscTit e 302 - DscChq terão
                              saída de operação - Agora o risco é individualizado por
                              borderô e não mais agrupado por limite. (Marcos-Supero)   
                              
                 08/12/2014 - Atualização da rotina de checagem de migração para 
                              desconsiderar riscos provenientes da Incorporação 
                              Concredi > Via e Credimil > SCR antes de 30/11/2014 
                              (Marcos-Supero)
                              
                 02/02/2015 - Ajustes nas rotinas de individualização para passar
                              a individualizar também os contrados de limite não
                              utilizado - inddocto = 3. Lembramos que os contratos
                              neste característica não acrescentam no total por CPF
                              mas quando individualizar o CPF por outros contratos,
                              o limite não utilizado também deve ser individualizado             
                              (Marcos-Supero)
                              
                 30/04/2015 - Correção para só considerar contratos efetivados ao buscar
                              se há uma liquidação do empréstimos (Marcos-Supero)   
                              
                 09/06/2015 - Ajuste na lógica de marcação de saída, quando o novo 
                              contrato está liquidado, não mais utilizaremos a informação
                              0305, mas sim a liquidação. (Marcos-Supero)                       
                              
                 23/06/2015 - Adicionado tratamento de risco para portabilidade de
								              crédito. (Reinert)
                              
                 25/11/2015 - Gravar os campos "dtprxpar, vlprxpar, qtparcel". (James)
                 
                 09/12/2015 - Ajuste para alimentar o campo crapris.dtvencop. (James)
                 
                 21/03/2016 - Ajuste para considerar se envia a operacao como individualizada.
                              Projeto 306 - Provisao de Cartao. (James)
                 
                 20/04/2016 - Ajuste para buscar o valor de individualizacao das operacoes
                              da tabela crapprm. (James).
                              
                 25/08/2016 - Ajuste na rotina pc_verifica_motivo_saida ao definir modalidade 
                              SD498470 (Odirlei-AMcom)              
                              
                 06/01/2016 - Ajuste para desprezar contas migradas da Transulcred para Transpocred antes da incorporação.
                              PRJ342 - Incorporação Transulcred (Odirlei-AMcom)                          
                              
                 16/05/2017 - P408 - Considerar riscos com inddocto = 5 - Garantias Prestadas
                              (Andrei-Mouts)
                 
                 04/07/2018 - P450 - Subtrair os Juros + 60 do valor total da dívida nos casos de empréstimos/ financiamentos 
				                      (cdorigem = 3) estejam em Prejuízo (innivris = 10) - Daniel(AMcom)

                 23/07/2018 - P442 - Individualização de operações BNDEs (Marcos-Envolti)    

                 04/09/2018 - P450 - Quando o Juros60 for maior que o valor da divida, enviar o valor da divida, 
                              senao subtrair do valor da divida o Juros60 para emprestimos em prejuizo. (P450 - Jaison)                              

                 10/10/2018 - P450 - Ajustes gerais no Juros60/ADP/Empr. (Guilherme/AMcom)

                 09/11/2018 - PJ450 - Inclusão de Limite NÃO Utilizado nas Informações Agregadas
                              (Renato Cordeiro - AMcom)

                 12/06/2019 - P450 - Correcao do comparativo de divida e juros60 (Guilherme/AMcom)

                 19/07/2019 - P450 - Ajuste verificação juros60 para BNDES (Guilherme/AMcom)
  
  ............................................................................ */

  DECLARE
    ------------------------- PL TABLE ---------------------------------------
    -- Estrutura para PL Table de CRAPRIS
    TYPE typ_reg_crapris IS
      RECORD(nrdconta crapris.nrdconta%TYPE
            ,dtrefere crapris.dtrefere%TYPE
            ,innivris crapris.innivris%TYPE
            ,qtdiaatr crapris.qtdiaatr%TYPE
            ,vldivida crapris.vldivida%TYPE
            ,vlvec180 crapris.vlvec180%TYPE
            ,vlvec360 crapris.vlvec360%TYPE
            ,vlvec999 crapris.vlvec999%TYPE
            ,vldiv060 crapris.vldiv060%TYPE
            ,vldiv180 crapris.vldiv180%TYPE
            ,vldiv360 crapris.vldiv360%TYPE
            ,vldiv999 crapris.vldiv999%TYPE
            ,vlprjano crapris.vlprjano%TYPE
            ,vlprjaan crapris.vlprjaan%TYPE
            ,inpessoa crapris.inpessoa%TYPE
            ,nrcpfcgc crapris.nrcpfcgc%TYPE
            ,vlprjant crapris.vlprjant%TYPE
            ,inddocto crapris.inddocto%TYPE
            ,cdmodali crapris.cdmodali%TYPE
            ,nrctremp crapris.nrctremp%TYPE
            ,nrseqctr crapris.nrseqctr%TYPE
            ,dtinictr crapris.dtinictr%TYPE
            ,cdorigem crapris.cdorigem%TYPE
            ,cdagenci crapris.cdagenci%TYPE
            ,innivori crapris.innivori%TYPE
            ,cdcooper crapris.cdcooper%TYPE
            ,vlprjm60 crapris.vlprjm60%TYPE
            ,dtdrisco crapris.dtdrisco%TYPE
            ,qtdriclq crapris.qtdriclq%TYPE
            ,nrdgrupo crapris.nrdgrupo%TYPE
            ,vljura60 crapris.vljura60%TYPE
            ,inindris crapris.inindris%TYPE
            ,cdinfadi crapris.cdinfadi%TYPE
            ,nrctrnov crapris.nrctrnov%TYPE
            ,flgindiv crapris.flgindiv%TYPE
            ,dtprxpar crapris.dtprxpar%TYPE
            ,vlprxpar crapris.vlprxpar%TYPE
            ,qtparcel crapris.qtparcel%TYPE
            ,dtvencop crapris.dtvencop%TYPE
            ,dsinfaux crapris.dsinfaux%TYPE);
    TYPE typ_tab_crapris    IS TABLE OF typ_reg_crapris INDEX BY VARCHAR2(31);
    TYPE typ_tab_crapris_n  IS TABLE OF typ_reg_crapris INDEX BY PLS_INTEGER;

    -- Estrutura da PL Table CRAPEPR
    TYPE typ_reg_crapepr IS
      RECORD(qtmesdec crapepr.qtmesdec%TYPE
            ,qtpreemp crapepr.qtpreemp%TYPE
            ,inliquid crapepr.inliquid%TYPE);
    TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY VARCHAR2(100);

    -- Estrutura de PL Table CRAWEPR
    TYPE typ_tab_crawepr IS TABLE OF crawepr.nrctremp%TYPE INDEX BY VARCHAR2(100);

    /* Estrutra de PL Table para tabela CRAPTCO */
    TYPE typ_tab_craptco 
      IS TABLE OF crapass.nrdconta%TYPE
        INDEX BY VARCHAR2(100);
    vr_tab_craptco typ_tab_craptco;
    
    /* Estrutura de PLTable para armazenar os Rowids de CRAPRIS para atualização */
    TYPE typ_tab_rowid
      IS TABLE OF ROWID
        INDEX BY PLS_INTEGER;
    vr_tab_rowid typ_tab_rowid;
    
    -- Estrutura da PL Table CRAPEBN
    TYPE typ_reg_crapebn IS
      RECORD(dtliquid crapebn.dtliquid%TYPE
            ,tpliquid crapebn.tpliquid%TYPE
            ,dtvctpro crapebn.dtvctpro%TYPE);
    TYPE typ_tab_crapebn IS TABLE OF typ_reg_crapebn INDEX BY VARCHAR2(100);
            

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Código do programa
    vr_cdprogra       CONSTANT crapprg.cdprogra%TYPE := 'CRPS660'; --> Nome do programa
    vr_nrctrnov       crawepr.nrctremp%TYPE;                       --> Número do contrato
    vr_contareg       PLS_INTEGER;                                 --> Número da conta
    vr_fltemris       BOOLEAN;                                     --> Flag de risco
    vr_dtrefere       DATE;                                        --> Data de referencia
    vr_tab_craprispl  typ_tab_crapris;                             --> PL Table
    vr_tab_crawepr    typ_tab_crawepr;                             --> Declaração de PL Table
    vr_ixcrapepr      VARCHAR2(100);                               --> Índice para PL Table
    vr_indcrapris     VARCHAR2(31);                                --> Indice para Pl Table CRAPRISPL
    vr_tab_crapepr    typ_tab_crapepr;                             --> Declaração de PL Table
    vr_dsparame       crapsol.dsparame%type;                       --> Parâmetro de execução
    vr_vlindivi       NUMBER(25,2);                                --> Valor para individualizar as operacoes
    vr_cdcooper       crapcop.cdcooper%TYPE;                       --> Codigo da Cooperativa
    vr_vljuro60       crapris.vljura60%TYPE := 0;


    
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;                                       --> Controle de saída para erros
    vr_exc_fimprg EXCEPTION;                                       --> Controle de saída para erros
    vr_cdcritic   PLS_INTEGER;                                     --> Código da crítica
    vr_dscritic   VARCHAR2(4000);                                  --> Descrição da crítica

    ------------------------------- CURSORES ----------------------------------------------------------
    -- Busca dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper)
         AND cop.flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Busca dados de parametros do sistema
    CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Código da cooperativa
      SELECT ct.dstextab
      FROM craptab ct
      WHERE ct.cdcooper = pr_cdcooper
        AND UPPER(ct.nmsistem) = 'CRED'
        AND UPPER(ct.tptabela) = 'USUARI'
        AND ct.cdempres = 11
        AND UPPER(ct.cdacesso) = 'RISCOBACEN'
        AND ct.tpregist = 0;
    rw_craptab cr_craptab%ROWTYPE;

    -- Buscar parametro da solicitação
    CURSOR cr_dsparame(pr_cdprogra  crapprg.cdprogra%TYPE) IS
      SELECT crapsol.dsparame
        FROM crapsol crapsol
           , crapprg crapprg
        WHERE crapsol.nrsolici = crapprg.nrsolici
          AND crapsol.cdcooper = crapprg.cdcooper
          AND crapprg.cdcooper = pr_cdcooper
          AND crapprg.cdprogra = pr_cdprogra
          AND crapsol.insitsol = 1;

    -- Busca cnpjs/cpfs a individualizar
    CURSOR cr_crapris(pr_cdcooper IN crapris.cdcooper%TYPE      --> Código da cooperativa
                     ,pr_dtrefere IN crapris.dtrefere%TYPE) IS  --> Data de referencia
      SELECT ci.rowid
            ,ci.vldivida
            ,ci.vljura60
            ,ci.vlsld59d
            ,decode(ci.inpessoa,2,SUBSTR(lpad(ci.nrcpfcgc,14,'0'), 1, 8),ci.nrcpfcgc) nrcpfcgc
            ,ci.nrdconta
            ,ci.nrctremp
            ,ci.cdorigem
            ,ci.innivris  
            ,ci.inddocto
            ,ci.cdmodali
            ,ci.cdinfadi
            ,ROW_NUMBER () OVER (PARTITION BY decode(ci.inpessoa,2,SUBSTR(lpad(ci.nrcpfcgc,14,'0'), 1, 8),ci.nrcpfcgc)
                                     ORDER BY decode(ci.inpessoa,2,SUBSTR(lpad(ci.nrcpfcgc,14,'0'), 1, 8),ci.nrcpfcgc)) nrseqctr
            ,COUNT(1)      OVER (PARTITION BY decode(ci.inpessoa,2,SUBSTR(lpad(ci.nrcpfcgc,14,'0'), 1, 8),ci.nrcpfcgc)) qtdcontr
      FROM crapris ci
      WHERE ci.cdcooper = pr_cdcooper
        AND ci.dtrefere = pr_dtrefere
        AND ci.inddocto IN(1,3,4,5)
      ORDER BY decode(ci.inpessoa,2,SUBSTR(lpad(ci.nrcpfcgc,14,'0'), 1, 8),ci.nrcpfcgc);

    vr_vldivida crapris.vldivida%TYPE;
    vr_vldivida_contrato crapris.vldivida%TYPE;
    
    
    -- Busca cnpjs/cpfs a individualizar origem BNDES
    -- Este cursor pode trazer as saídas, pois elas também serão individualizadas para o BNDEs
    CURSOR cr_crapris_BNDES(pr_dtrefere IN crapris.dtrefere%TYPE) IS  --> Data de referencia
      SELECT ris.rowid
            ,ris.vldivida
            ,ris.vljura60
            ,decode(ris.inpessoa,2,SUBSTR(lpad(ris.nrcpfcgc,14,'0'), 1, 8),ris.nrcpfcgc) nrcpfcgc
            ,ris.cdcooper
            ,ris.nrdconta
            ,ris.nrctremp
            ,ris.cdorigem
            ,ris.innivris 
            ,ris.inddocto
            ,ris.cdinfadi
            ,ris.cdmodali
            ,ris.vlsld59d
            ,ROW_NUMBER () OVER (PARTITION BY decode(ris.inpessoa,2,SUBSTR(lpad(ris.nrcpfcgc,14,'0'), 1, 8),ris.nrcpfcgc)
                                     ORDER BY decode(ris.inpessoa,2,SUBSTR(lpad(ris.nrcpfcgc,14,'0'), 1, 8),ris.nrcpfcgc)) nrseqctr
            ,COUNT(1)      OVER (PARTITION BY decode(ris.inpessoa,2,SUBSTR(lpad(ris.nrcpfcgc,14,'0'), 1, 8),ris.nrcpfcgc)) qtdcontr
      FROM crapris ris
      WHERE ris.dtrefere = pr_dtrefere
        AND ris.inddocto IN(1,2,5) -- Operações Ativas, Saidas, Cartão de Crédito e Garantias Prestadas
        AND ris.cdorigem in(1,3,7) -- Somente Limite, Empréstimos/Financiamentos e Garantias prestadas Coop
        AND ris.inpessoa IN (1,2)-- Deve ser CPF ou CNPJ
        AND ris.vldivida <> 0    -- Com divida
        AND (  ris.dsinfaux = 'BNDES'  
             OR (ris.cdorigem = 1 AND EXISTS(SELECT 1
                                               FROM craplim li
                                                   ,craplrt lr
                                              WHERE li.cdcooper = ris.cdcooper
                                                AND li.nrdconta = ris.nrdconta
                                                AND li.nrctrlim = ris.nrctremp
                                                AND li.cdcooper = lr.cdcooper
                                                AND li.cddlinha = lr.cddlinha
                                                AND lr.dsdlinha LIKE '%BNDES%'))
             OR (ris.cdorigem = 3 AND exists(select 1
                                              from crapepr ep
                                              join craplcr lc
                                                on lc.cdcooper = ep.cdcooper
                                               AND lc.cdlcremp = ep.cdlcremp                     
                                             WHERE ep.cdcooper = ris.cdcooper
                                               AND ep.nrdconta = ris.nrdconta
                                               AND ep.nrctremp = ris.nrctremp
                                               AND lc.dsorgrec IN ('MICROCREDITO PNMPO BNDES AILOS','MICROCREDITO PNMPO BNDES')))
             OR (ris.inddocto = 5 AND EXISTS(SELECT 1
                                              FROM tbrisco_provisgarant_prodt prd
                                                  ,tbrisco_provisgarant_movto mvt
                                             WHERE mvt.idproduto     = prd.idproduto
                                               AND mvt.idmovto_risco = ris.dsinfaux
                                               and prd.tparquivo     = 'Cartao_BNDES_BRDE'))
           )
      ORDER BY decode(ris.inpessoa,2,SUBSTR(lpad(ris.nrcpfcgc,14,'0'), 1, 8),ris.nrcpfcgc);


    /* Buscar dados do cadastro de empréstimos */
    CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE) IS
      SELECT ce.nrdconta
            ,ce.nrctremp
            ,ce.qtmesdec
            ,ce.qtpreemp
            ,ce.inliquid
      FROM crapepr ce
      WHERE ce.cdcooper = pr_cdcooper;

    /* Buscar dados das propostas de empréstimo */
    CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE) IS --> Código da cooperativa
      SELECT cw.nrdconta
            ,cw.nrctremp
            ,cw.nrctrliq##1
            ,cw.nrctrliq##2
            ,cw.nrctrliq##3
            ,cw.nrctrliq##4
            ,cw.nrctrliq##5
            ,cw.nrctrliq##6
            ,cw.nrctrliq##7
            ,cw.nrctrliq##8
            ,cw.nrctrliq##9
            ,cw.nrctrliq##10
      FROM crawepr cw
      WHERE cw.cdcooper = pr_cdcooper
        ORDER BY progress_recid DESC;


    /* Buscar dados das contas transferidas entre cooperativas - Utilizado para cooperativa 1 */
    CURSOR cr_craptco IS
      SELECT ct.nrctaant
            ,ct.nrdconta
      FROM craptco ct
      WHERE cdcooper   = 1
        AND cdcopant   = 2
        AND tpctatrf  <> 3
        AND cdageant IN (2,4,6,7,11);


    /* Buscar dados das contas transferidas entre cooperativas - Utilizado para cooperativa 16*/
    CURSOR cr_craptco_16 IS
      SELECT ct.nrctaant
            ,ct.nrdconta
      FROM craptco ct
      WHERE cdcooper = 16
        AND tpctatrf <> 3;
        
    /* Buscar dados das contas incorporadas - Concredi >> Via e Credimil >> SCR */
    CURSOR cr_craptco_inc(pr_cdcooper crapcop.cdcooper%TYPE
                         ,pr_cdcopant crapcop.cdcooper%TYPE) IS
      SELECT ct.nrctaant
            ,ct.nrdconta
      FROM craptco ct
      WHERE cdcooper = pr_cdcooper
        AND cdcopant = pr_cdcopant
        AND tpctatrf <> 3;

    ------------------------------- PROCEDURES INTERNAS ---------------------------------
    /* Processar conta de migração entre cooperativas */
    FUNCTION fn_verifica_conta_migracao(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE) --> Número da conta
                                                                               RETURN BOOLEAN IS
    BEGIN
      -- Validamos Apenas Via, AV, SCR e Tranpocred
      IF pr_cdcooper NOT IN(1,13,16,9) THEN
        -- OK
        RETURN TRUE;
      ELSE
        IF vr_tab_craptco.exists(LPAD(pr_cdcooper,03,'0')||LPAD(pr_nrdconta,15,'0')) THEN
          RETURN FALSE;
        ELSE
          -- Tudo OK até aqui, retornamos true
          RETURN TRUE;
        END IF;  
      END IF;
    END fn_verifica_conta_migracao;

    /* Verificar motivo da saída */
    PROCEDURE pc_verifica_motivo_saida(pr_cdcooper IN PLS_INTEGER              --> Código da cooperativa
                                      ,pr_dtrefere IN crapris.dtrefere%TYPE    --> Data de referência
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE    --> Número da conta
                                      ,pr_nrctremp IN crapris.nrctremp%TYPE    --> Contrato
                                      ,pr_cdmodali IN crapris.cdmodali%TYPE    --> Modalidade
                                      ,pr_cdorgris IN crapris.cdorigem%TYPE    --> Código de origem
                                      ,pr_tab_crapebn IN OUT NOCOPY typ_tab_crapebn  --> PL Table da tabela
                                      ,pr_dtultdma IN crapdat.dtultdma%TYPE     --> Ultimo dia do mes anterior
                                      ,pr_dtvencop IN crapris.dtvencop%TYPE     --> data de vencimento do risco
                                      ,pr_nrctrnov  OUT crawepr.nrctremp%TYPE   --> Contrato novo
                                      ,pr_cdinfadi  OUT VARCHAR2                --> Código de informação
                                      ,pr_des_erro  OUT VARCHAR2) IS            --> Saída de erro
    BEGIN
      DECLARE

        vr_ixcrapebn    VARCHAR2(100);   --> Índice para PL Table
        vr_exc_saida    EXCEPTION;       --> Controle de erros do processo
        
        /* Teste para verificar se o novo contrato está liquidado */
        CURSOR cr_crapris(pr_nrctremp IN crapris.nrctremp%TYPE) IS --> Novo empréstimo
          SELECT cr.flgindiv
            FROM crapris cr
           WHERE cr.cdcooper = pr_cdcooper
             AND cr.dtrefere = pr_dtrefere
             AND cr.nrdconta = pr_nrdconta
             AND cr.nrctremp = pr_nrctremp
             AND cr.inddocto = 1
             AND cr.cdorigem = 3
             AND cr.cdmodalI IN(0299,0499);
          vr_flgindiv crapris.flgindiv%TYPE;
					
				CURSOR cr_tbepr_portab (pr_nrctremp IN crapris.nrctremp%TYPE) IS --> Portabilidade de crédito
				  SELECT 1
					  FROM tbepr_portabilidade port
					 WHERE port.cdcooper = pr_cdcooper
					   AND port.nrdconta = pr_nrdconta
						 AND port.nrctremp = pr_nrctremp
						 AND port.tpoperacao = 2
						 AND port.dtliquidacao IS NOT NULL;
				rw_tbepr_portab cr_tbepr_portab%ROWTYPE;
				  
      BEGIN

        -- Valida situação da modalidade
        IF pr_cdmodali = 0299 OR pr_cdmodali = 0499 THEN
          -- Dados de empréstimo do BNDES
          vr_ixcrapebn := LPAD(pr_cdcooper, 3, '0') || LPAD(pr_nrdconta, 15, '0') || lpad(pr_nrctremp, 15, '0');
          IF pr_tab_crapebn.exists(vr_ixcrapebn) THEN

            -- Quando existir Liquidaçao por motivo de renovaçao , descobrir como identificar o
            -- número do NOVO contrato criado que originou a renovaçao, esta informaçao deve ser
            -- alimentada  no campo crapris.nrctrnov quando criar o registro crapris.indocmto = 2.
            -- Nao teremos por enquanto.
            IF pr_tab_crapebn(vr_ixcrapebn).tpliquid = 1 THEN /* pagamento */
              IF pr_tab_crapebn(vr_ixcrapebn).dtliquid IS NOT NULL THEN
                IF pr_tab_crapebn(vr_ixcrapebn).dtliquid < pr_tab_crapebn(vr_ixcrapebn).dtvctpro THEN
                  pr_cdinfadi := '0302';
                ELSE
                  pr_cdinfadi := '0301';
                END IF;

                -- Encerrar processo
                RETURN;
              END IF;
            END IF;
          ELSE
						
						-- Abre cursor de portabilidade de credito
						OPEN cr_tbepr_portab(pr_nrctremp => pr_nrctremp);
						FETCH cr_tbepr_portab INTO rw_tbepr_portab;
						
						-- Se exister algum registro é operação de portabilidade
						IF cr_tbepr_portab%FOUND THEN
							-- Grava motivo de operação liquidada por portabilidade
							pr_cdinfadi := '0311';
							CLOSE cr_tbepr_portab;			
							-- Encerrar processo				
							RETURN;
						ELSE
							-- Se não encontrou fecha o cursor e continua o programa
							CLOSE cr_tbepr_portab;
						END IF;

            -- Saída por renegociação (Se o contrato está a em alguma lista de liquidação)
            vr_ixcrapepr := LPAD(pr_nrdconta, 15, '0') || LPAD(REPLACE(pr_nrctremp, ',', ''), 30, '0');
            -- Testar se existe contrato que liquidou este
            IF vr_tab_crawepr.exists(vr_ixcrapepr) THEN
              -- Guardamos o novo contrato
              pr_nrctrnov := vr_tab_crawepr(vr_ixcrapepr);
              -- Devemos testar se o novo contrato está individualizado
              OPEN cr_crapris(pr_nrctremp => vr_tab_crawepr(vr_ixcrapepr));
              FETCH cr_crapris
               INTO vr_flgindiv;
              CLOSE cr_crapris;
              -- Somente se existir individualizado
              IF vr_flgindiv = 1 THEN
                -- Saída por renegociação, e enviamos o novo contrato
                pr_cdinfadi := '0305';
              ELSE
                -- Saída por baixa do limite de identificação (Operações abaixo de 1000);
                pr_cdinfadi := '0308';
              END IF;  
              -- Retornar processo
              RETURN;
            END IF;
            -- Testar liquidação
            vr_ixcrapepr := LPAD(pr_nrdconta, 15, '0') || LPAD(pr_nrctremp, 15, '0');
            IF vr_tab_crapepr.exists(vr_ixcrapepr) THEN
              -- Verifica volume mensal de emprétimos
              IF pr_dtultdma >= pr_dtvencop THEN
                pr_cdinfadi := '0301';
              ELSE
                pr_cdinfadi := '0302';
              END IF;
              -- Encerrar processo
              RETURN;
              
            END IF;
						
            -- Verifica código do risco
            IF pr_cdorgris = 1 THEN
              pr_cdinfadi := '0301';
              -- Encerrar processo
              RETURN;
            END IF;
          END IF;
        END IF;
        -- Valida desconto de cheque, de titulo
        IF pr_cdmodali IN(0302,0301) THEN
          pr_cdinfadi := '0301';          
          -- Encerrar processo
          RETURN;
        END IF;

        -- Outras saídas
        pr_cdinfadi := '0399';

      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'Erro em pc_verifica_motivo_saida: ' || SQLERRM;
      END;
    END pc_verifica_motivo_saida;

    /* Processar saída da operação */
    PROCEDURE pc_cria_saida_operacao(pr_cdcooper    IN PLS_INTEGER                 --> Código da cooperativa
                                    ,pr_dtrefere    IN DATE                        --> Data de referencia
                                    ,pr_rw_crapdat  IN btch0001.cr_crapdat%ROWTYPE --> Dados da crapdat
                                    ,pr_des_erro    OUT VARCHAR2) IS               --> Saída de erros
    BEGIN
      DECLARE
        vr_tab_crapebn typ_tab_crapebn;       --> PL Table para os emprestimos BNDES
        
        vr_tab_crapris typ_tab_crapris;          --> PL Table para os riscos
        vr_nrseqctr    PLS_INTEGER;              --> Número de contrato
        vr_cdinfadi    VARCHAR2(400);            --> Descrição do motivo
        vr_cdmodali    crapris.cdmodali%TYPE;    --> Modalidade
        vr_dtultdma    DATE;                     --> Última data
        vr_contareg    PLS_INTEGER := 1;         --> Contador para iteração
        vr_exc_erro    EXCEPTION;                --> Controle de saída de erros
        vr_idxcrapris  VARCHAR2(31);             --> Índice para PL Table
        vr_contcraptis PLS_INTEGER := 0;         --> Contador para o indice vr_idxcrapris
        vr_tab_crapris_n typ_tab_crapris_n;      --> Variavel que contera a mesma informacao que a pr_tab_crapris, porem com indice numero
        vr_idxcrapris_n  PLS_INTEGER := 0;       --> Indice da pl/table vr_tab_crapris_n

        /* Buscar dados do risco */
        CURSOR cr_crapris_mes_anterior(pr_cdcooper IN crapris.cdcooper%TYPE      --> Código da cooperativa
                                      ,pr_dtultdma IN crapris.dtrefere%TYPE) IS  --> Data de referencia
          SELECT cr.nrdconta
                ,cr.dtrefere
                ,cr.cdmodali
                ,cr.cdcooper
                ,cr.nrctremp
                ,cr.inddocto
                ,cr.cdorigem
                ,cr.innivris
                ,cr.qtdiaatr
                ,cr.vldivida
                ,cr.vlvec180
                ,cr.vlvec360
                ,cr.vlvec999
                ,cr.vldiv060
                ,cr.vldiv180
                ,cr.vldiv360
                ,cr.vldiv999
                ,cr.vlprjano
                ,cr.vlprjaan
                ,cr.inpessoa
                ,cr.nrcpfcgc
                ,cr.vlprjant
                ,cr.dtinictr
                ,cr.cdagenci
                ,cr.innivori
                ,cr.vlprjm60
                ,cr.dtdrisco
                ,cr.qtdriclq
                ,cr.nrdgrupo
                ,cr.vljura60
                ,cr.inindris
                ,cr.flgindiv
                ,cr.nrctrnov
                ,cr.cdinfadi
                ,cr.nrseqctr
                ,cr.dtprxpar
                ,cr.vlprxpar
                ,cr.qtparcel
                ,cr.dtvencop
                ,cr.dsinfaux
                ,cr.rowid
          FROM crapris cr
          WHERE cr.cdcooper = pr_cdcooper
            AND cr.dtrefere = pr_dtultdma
            AND cr.inddocto IN(1)
            AND cr.flgindiv = 1
            AND cr.cdmodali NOT IN(101,201)
          ORDER BY cr.nrdconta
                  ,cr.nrctremp
                  ,cr.nrseqctr;

        /* Buscar dados de risco para a PL Table */
        CURSOR cr_crapris_mes_atual(pr_dtrefere IN crapris.dtrefere%TYPE) IS
          SELECT nrdconta
                ,dtrefere
                ,innivris
                ,qtdiaatr
                ,vldivida
                ,vlvec180
                ,vlvec360
                ,vlvec999
                ,vldiv060
                ,vldiv180
                ,vldiv360
                ,vldiv999
                ,vlprjano
                ,vlprjaan
                ,inpessoa
                ,nrcpfcgc
                ,vlprjant
                ,inddocto
                ,cdmodali
                ,nrctremp
                ,nrseqctr
                ,dtinictr
                ,cdorigem
                ,cdagenci
                ,innivori
                ,cdcooper
                ,vlprjm60
                ,dtdrisco
                ,qtdriclq
                ,nrdgrupo
                ,vljura60
                ,inindris
                ,cdinfadi
                ,nrctrnov
                ,flgindiv
                ,dtprxpar
                ,vlprxpar
                ,qtparcel
                ,dtvencop
                ,dsinfaux
          FROM crapris ris
          WHERE ris.cdcooper = pr_cdcooper
            AND ris.dtrefere = pr_dtrefere
            AND ris.inddocto IN(1);
            
        /* Busca dados do cadastro de emprestimo BNDES */
        CURSOR cr_crapebn IS
          SELECT cn.dtliquid
                ,cn.tpliquid
                ,cn.dtvctpro
                ,cn.cdcooper
                ,cn.nrdconta
                ,cn.nrctremp
          FROM crapebn cn;

        /* Busca cadastro de Produtos de Risco Lançados Manualmente e que permitem saída de operação */
        CURSOR cr_prod IS
          SELECT prd.idproduto
            FROM tbrisco_provisgarant_prodt prd
           WHERE prd.flpermite_saida_operacao = 1;
        TYPE typ_reg_prod_com_saida IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
        vr_tab_prod_com_saida typ_reg_prod_com_saida;    
           
           
      BEGIN
        -- Inicializar variáveis
        vr_dtultdma := pr_dtrefere - TO_NUMBER(TO_CHAR(pr_dtrefere, 'DD'));
        vr_cdinfadi := '';
        vr_nrseqctr := 0;
        vr_cdmodali := 0;

        -- Carregar PL Table de empréstimos do BNDES
        FOR regs IN cr_crapebn LOOP
          vr_tab_crapebn(LPAD(regs.cdcooper, 3, '0') || LPAD(regs.nrdconta, 15, '0') || LPAD(regs.nrctremp, 15, '0')).dtliquid := regs.dtliquid;
          vr_tab_crapebn(LPAD(regs.cdcooper, 3, '0') || LPAD(regs.nrdconta, 15, '0') || LPAD(regs.nrctremp, 15, '0')).tpliquid := regs.tpliquid;
          vr_tab_crapebn(LPAD(regs.cdcooper, 3, '0') || LPAD(regs.nrdconta, 15, '0') || LPAD(regs.nrctremp, 15, '0')).dtvctpro := regs.dtvctpro;
        END LOOP;        

        -- Carregar pltables com produtos de Risco lançados manualmente e que permite saída de operação
        FOR rw_prod IN cr_prod LOOP
          vr_tab_prod_com_saida(rw_prod.idproduto) := 1;
        END LOOP;
        
        
        -- Carrega a pl/table de riscos
        FOR rw_craprispl IN cr_crapris_mes_atual(pr_dtrefere) LOOP
          vr_indcrapris := lpad(rw_craprispl.nrdconta,10,'0')||
                           lpad(rw_craprispl.innivris,5,'0') ||
                           lpad(rw_craprispl.nrctremp,10,'0')||
                           lpad(rw_craprispl.cdmodali,5,'0');
          vr_tab_craprispl(vr_indcrapris) := rw_craprispl;
        END LOOP;

        -- Executar consulta de riscos
        FOR rw_crapris IN cr_crapris_mes_anterior(pr_cdcooper => pr_cdcooper, pr_dtultdma => vr_dtultdma) LOOP
          -- Verifica migração/incorporação
          IF NOT fn_verifica_conta_migracao(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => rw_crapris.nrdconta) THEN
            CONTINUE;
          END IF;

          vr_fltemris := FALSE;
          vr_contareg := 1;

          -- Verificar riscos para determinar indicador
          LOOP
            EXIT WHEN vr_contareg > 10;

            -- Verificar modalidade
            IF rw_crapris.cdmodali = 0299 THEN
              vr_cdmodali := 0499;
            ELSE
              IF rw_crapris.cdmodali = 0499 THEN
                vr_cdmodali := 0299;
              ELSE
                vr_cdmodali := rw_crapris.cdmodali;
              END IF;
            END IF;

            -- Verifica se existe o risco
            IF vr_tab_craprispl.exists(lpad(rw_crapris.nrdconta,10,'0')||
                                       lpad(vr_contareg,5,'0') ||
                                       lpad(rw_crapris.nrctremp,10,'0')||
                                       lpad(rw_crapris.cdmodali,5,'0')) OR
               vr_tab_craprispl.exists(lpad(rw_crapris.nrdconta,10,'0')||
                                       lpad(vr_contareg,5,'0') ||
                                       lpad(rw_crapris.nrctremp,10,'0')||
                                       lpad(vr_cdmodali,5,'0')) THEN
              vr_fltemris := TRUE;
              EXIT;
            END IF;

            vr_contareg := vr_contareg + 1;
          END LOOP;

          -- Verifica o flag de risco
          IF NOT vr_fltemris THEN
            -- Sequencia do risco
            vr_nrseqctr := 1;

            -- Busca a sequencia
            -- Verifica se existe registro para o risco
            vr_idxcrapris := lpad(rw_crapris.nrdconta,10,'0') ||   -- nrdconta
                             to_char(pr_dtrefere,'YYYYMMDD')  ||   -- dtrefere
                             '00002'                          ||   -- inddocto
                             '00000000';                           -- contador
            vr_idxcrapris := vr_tab_crapris.next(vr_idxcrapris);

            WHILE vr_idxcrapris IS NOT NULL LOOP
              -- Verifica se existe registro
              IF vr_tab_crapris(vr_idxcrapris).nrdconta = rw_crapris.nrdconta AND
                 vr_tab_crapris(vr_idxcrapris).dtrefere = pr_dtrefere AND
                 vr_tab_crapris(vr_idxcrapris).inddocto = 2 THEN
                IF nvl(vr_tab_crapris(vr_idxcrapris).nrseqctr, 0) >= vr_nrseqctr THEN
                  vr_nrseqctr := nvl(vr_tab_crapris(vr_idxcrapris).nrseqctr, 0) + 1;
                END IF;
              ELSE
                EXIT;
              END IF;
              vr_idxcrapris := vr_tab_crapris.next(vr_idxcrapris);
            END LOOP;

            -- Verificar motivo da saída
            pc_verifica_motivo_saida(pr_cdcooper    => pr_cdcooper
                                    ,pr_dtrefere    => pr_dtrefere
                                    ,pr_nrdconta    => rw_crapris.nrdconta
                                    ,pr_nrctremp    => rw_crapris.nrctremp
                                    ,pr_cdmodali    => rw_crapris.cdmodali
                                    ,pr_cdorgris    => rw_crapris.cdorigem
                                    ,pr_tab_crapebn => vr_tab_crapebn
                                    ,pr_dtultdma    => pr_rw_crapdat.dtultdma
                                    ,pr_dtvencop    => rw_crapris.dtvencop
                                    ,pr_nrctrnov    => vr_nrctrnov
                                    ,pr_cdinfadi    => vr_cdinfadi
                                    ,pr_des_erro    => pr_des_erro);

            -- Verifica se ocorreram erros
            IF pr_des_erro <> 'OK' THEN
              RAISE vr_exc_erro;
            END IF;

            -- Criar registros na PL Table com base na tabela física
            vr_contcraptis := vr_contcraptis + 1;
            vr_idxcrapris := lpad(rw_crapris.nrdconta,10,'0') ||   -- nrdconta
                             to_char(pr_dtrefere,'YYYYMMDD')  ||   -- dtrefere
                             '00002'                          ||   -- inddocto
                             lpad(vr_contcraptis,8,'0');           -- contador
            vr_tab_crapris(vr_idxcrapris).nrdconta := rw_crapris.nrdconta;
            vr_tab_crapris(vr_idxcrapris).dtrefere := pr_dtrefere;
            vr_tab_crapris(vr_idxcrapris).innivris := rw_crapris.innivris;
            vr_tab_crapris(vr_idxcrapris).qtdiaatr := rw_crapris.qtdiaatr;
            vr_tab_crapris(vr_idxcrapris).vldivida := rw_crapris.vldivida;
            vr_tab_crapris(vr_idxcrapris).vlvec180 := rw_crapris.vlvec180;
            vr_tab_crapris(vr_idxcrapris).vlvec360 := rw_crapris.vlvec360;
            vr_tab_crapris(vr_idxcrapris).vlvec999 := rw_crapris.vlvec999;
            vr_tab_crapris(vr_idxcrapris).vldiv060 := rw_crapris.vldiv060;
            vr_tab_crapris(vr_idxcrapris).vldiv180 := rw_crapris.vldiv180;
            vr_tab_crapris(vr_idxcrapris).vldiv360 := rw_crapris.vldiv360;
            vr_tab_crapris(vr_idxcrapris).vldiv999 := rw_crapris.vldiv999;
            vr_tab_crapris(vr_idxcrapris).vlprjano := rw_crapris.vlprjano;
            vr_tab_crapris(vr_idxcrapris).vlprjaan := rw_crapris.vlprjaan;
            vr_tab_crapris(vr_idxcrapris).inpessoa := rw_crapris.inpessoa;
            vr_tab_crapris(vr_idxcrapris).nrcpfcgc := rw_crapris.nrcpfcgc;
            vr_tab_crapris(vr_idxcrapris).vlprjant := rw_crapris.vlprjant;
            vr_tab_crapris(vr_idxcrapris).inddocto := 2;
            vr_tab_crapris(vr_idxcrapris).cdmodali := rw_crapris.cdmodali;
            vr_tab_crapris(vr_idxcrapris).nrctremp := rw_crapris.nrctremp;
            vr_tab_crapris(vr_idxcrapris).nrseqctr := vr_nrseqctr;
            vr_tab_crapris(vr_idxcrapris).dtinictr := rw_crapris.dtinictr;
            vr_tab_crapris(vr_idxcrapris).cdorigem := rw_crapris.cdorigem;
            vr_tab_crapris(vr_idxcrapris).cdagenci := rw_crapris.cdagenci;
            vr_tab_crapris(vr_idxcrapris).innivori := rw_crapris.innivori;
            vr_tab_crapris(vr_idxcrapris).cdcooper := rw_crapris.cdcooper;
            vr_tab_crapris(vr_idxcrapris).vlprjm60 := rw_crapris.vlprjm60;
            vr_tab_crapris(vr_idxcrapris).dtdrisco := rw_crapris.dtdrisco;
            vr_tab_crapris(vr_idxcrapris).qtdriclq := rw_crapris.qtdriclq;
            vr_tab_crapris(vr_idxcrapris).nrdgrupo := rw_crapris.nrdgrupo;
            vr_tab_crapris(vr_idxcrapris).vljura60 := rw_crapris.vljura60;
            vr_tab_crapris(vr_idxcrapris).inindris := rw_crapris.inindris;
            vr_tab_crapris(vr_idxcrapris).cdinfadi := vr_cdinfadi;
            vr_tab_crapris(vr_idxcrapris).flgindiv := rw_crapris.flgindiv;
            vr_tab_crapris(vr_idxcrapris).dtprxpar := rw_crapris.dtprxpar;
            vr_tab_crapris(vr_idxcrapris).vlprxpar := rw_crapris.vlprxpar;
            vr_tab_crapris(vr_idxcrapris).qtparcel := rw_crapris.qtparcel;
            vr_tab_crapris(vr_idxcrapris).dtvencop := rw_crapris.dtvencop;
            vr_tab_crapris(vr_idxcrapris).dsinfaux := rw_crapris.dsinfaux;            

            IF vr_cdinfadi IN('0305','0308') THEN
              vr_tab_crapris(vr_idxcrapris).nrctrnov := vr_nrctrnov;
            ELSE
              vr_tab_crapris(vr_idxcrapris).nrctrnov := rw_crapris.nrctrnov;
            END IF;
          END IF;
        END LOOP;

        -- Executar consulta de riscos
        FOR rw_crapris IN cr_crapris_mes_anterior(pr_cdcooper => pr_cdcooper, pr_dtultdma => vr_dtultdma) LOOP
          -- Verifica migração/incorporação
          IF NOT fn_verifica_conta_migracao(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta  => rw_crapris.nrdconta) THEN
            CONTINUE;
          END IF;

          vr_fltemris := FALSE;
          vr_contareg := 1;

          -- Verificar riscos para determinar indicador
          LOOP
            EXIT WHEN vr_contareg > 10;

            -- Verificar modalidade
            IF rw_crapris.cdmodali = 0299 THEN
              vr_cdmodali := 0499;
            ELSE
              IF rw_crapris.cdmodali = 0499 THEN
                vr_cdmodali := 0299;
              ELSE
                vr_cdmodali := rw_crapris.cdmodali;
              END IF;
            END IF;

            vr_indcrapris := lpad(rw_crapris.nrdconta,10,'0')||
                           lpad(vr_contareg,5,'0') ||
                           lpad(rw_crapris.nrctremp,10,'0')||
                           lpad(rw_crapris.cdmodali,5,'0');
            IF vr_tab_craprispl.exists(vr_indcrapris) AND vr_tab_craprispl(vr_indcrapris).flgindiv = 0 THEN
              vr_fltemris := TRUE;
              EXIT;
            END IF;

            vr_indcrapris := lpad(rw_crapris.nrdconta,10,'0')||
                           lpad(vr_contareg,5,'0') ||
                           lpad(rw_crapris.nrctremp,10,'0')||
                           lpad(vr_cdmodali,5,'0');
            IF vr_tab_craprispl.exists(vr_indcrapris) AND vr_tab_craprispl(vr_indcrapris).flgindiv = 0 THEN
              vr_fltemris := TRUE;
              EXIT;
            END IF;

            vr_contareg := vr_contareg + 1;
          END LOOP;

          -- Verifica o flag de risco
          IF vr_fltemris THEN
            -- Sequencia do risco
            vr_nrseqctr := 1;

            -- Verifica se existe registro para o risco
            vr_idxcrapris := lpad(rw_crapris.nrdconta,10,'0') ||   -- nrdconta
                             to_char(pr_dtrefere,'YYYYMMDD')  ||   -- dtrefere
                             '00002'                          ||   -- inddocto
                             '00000000';                           -- contador
            vr_idxcrapris := vr_tab_crapris.next(vr_idxcrapris);
            WHILE vr_idxcrapris IS NOT NULL LOOP
              -- Verifica se existe registro
              IF vr_tab_crapris(vr_idxcrapris).nrdconta = rw_crapris.nrdconta AND
                 vr_tab_crapris(vr_idxcrapris).dtrefere = pr_dtrefere AND
                 vr_tab_crapris(vr_idxcrapris).inddocto = 2 THEN
                IF nvl(vr_tab_crapris(vr_idxcrapris).nrseqctr, 0) >= vr_nrseqctr THEN
                  vr_nrseqctr := nvl(vr_tab_crapris(vr_idxcrapris).nrseqctr, 0) + 1;
                END IF;
              ELSE
                EXIT;
              END IF;
              vr_idxcrapris := vr_tab_crapris.next(vr_idxcrapris);
            END LOOP;

            -- Criar registros na PL Table com base na tabela física
            vr_contcraptis := vr_contcraptis + 1;
            vr_idxcrapris := lpad(rw_crapris.nrdconta,10,'0') ||   -- nrdconta
                             to_char(pr_dtrefere,'YYYYMMDD')  ||   -- dtrefere
                             '00002'                          ||   -- inddocto
                             lpad(vr_contcraptis,8,'0');           -- contador
            vr_tab_crapris(vr_idxcrapris).nrdconta := vr_tab_craprispl(vr_indcrapris).nrdconta;
            vr_tab_crapris(vr_idxcrapris).dtrefere := pr_dtrefere;
            vr_tab_crapris(vr_idxcrapris).innivris := vr_tab_craprispl(vr_indcrapris).innivris;
            vr_tab_crapris(vr_idxcrapris).qtdiaatr := vr_tab_craprispl(vr_indcrapris).qtdiaatr;
            vr_tab_crapris(vr_idxcrapris).vldivida := vr_tab_craprispl(vr_indcrapris).vldivida;
            vr_tab_crapris(vr_idxcrapris).vlvec180 := vr_tab_craprispl(vr_indcrapris).vlvec180;
            vr_tab_crapris(vr_idxcrapris).vlvec360 := vr_tab_craprispl(vr_indcrapris).vlvec360;
            vr_tab_crapris(vr_idxcrapris).vlvec999 := vr_tab_craprispl(vr_indcrapris).vlvec999;
            vr_tab_crapris(vr_idxcrapris).vldiv060 := vr_tab_craprispl(vr_indcrapris).vldiv060;
            vr_tab_crapris(vr_idxcrapris).vldiv180 := vr_tab_craprispl(vr_indcrapris).vldiv180;
            vr_tab_crapris(vr_idxcrapris).vldiv360 := vr_tab_craprispl(vr_indcrapris).vldiv360;
            vr_tab_crapris(vr_idxcrapris).vldiv999 := vr_tab_craprispl(vr_indcrapris).vldiv999;
            vr_tab_crapris(vr_idxcrapris).vlprjano := vr_tab_craprispl(vr_indcrapris).vlprjano;
            vr_tab_crapris(vr_idxcrapris).vlprjaan := vr_tab_craprispl(vr_indcrapris).vlprjaan;
            vr_tab_crapris(vr_idxcrapris).inpessoa := vr_tab_craprispl(vr_indcrapris).inpessoa;
            vr_tab_crapris(vr_idxcrapris).nrcpfcgc := vr_tab_craprispl(vr_indcrapris).nrcpfcgc;
            vr_tab_crapris(vr_idxcrapris).vlprjant := vr_tab_craprispl(vr_indcrapris).vlprjant;
            vr_tab_crapris(vr_idxcrapris).inddocto := 2;
            vr_tab_crapris(vr_idxcrapris).cdmodali := vr_tab_craprispl(vr_indcrapris).cdmodali;
            vr_tab_crapris(vr_idxcrapris).nrctremp := vr_tab_craprispl(vr_indcrapris).nrctremp;
            vr_tab_crapris(vr_idxcrapris).nrseqctr := vr_nrseqctr;
            vr_tab_crapris(vr_idxcrapris).dtinictr := vr_tab_craprispl(vr_indcrapris).dtinictr;
            vr_tab_crapris(vr_idxcrapris).cdorigem := vr_tab_craprispl(vr_indcrapris).cdorigem;
            vr_tab_crapris(vr_idxcrapris).cdagenci := vr_tab_craprispl(vr_indcrapris).cdagenci;
            vr_tab_crapris(vr_idxcrapris).innivori := vr_tab_craprispl(vr_indcrapris).innivori;
            vr_tab_crapris(vr_idxcrapris).cdcooper := vr_tab_craprispl(vr_indcrapris).cdcooper;
            vr_tab_crapris(vr_idxcrapris).vlprjm60 := vr_tab_craprispl(vr_indcrapris).vlprjm60;
            vr_tab_crapris(vr_idxcrapris).dtdrisco := vr_tab_craprispl(vr_indcrapris).dtdrisco;
            vr_tab_crapris(vr_idxcrapris).qtdriclq := vr_tab_craprispl(vr_indcrapris).qtdriclq;
            vr_tab_crapris(vr_idxcrapris).nrdgrupo := vr_tab_craprispl(vr_indcrapris).nrdgrupo;
            vr_tab_crapris(vr_idxcrapris).vljura60 := vr_tab_craprispl(vr_indcrapris).vljura60;
            vr_tab_crapris(vr_idxcrapris).inindris := vr_tab_craprispl(vr_indcrapris).inindris;
            vr_tab_crapris(vr_idxcrapris).flgindiv := vr_tab_craprispl(vr_indcrapris).flgindiv;
            vr_tab_crapris(vr_idxcrapris).nrctrnov := vr_tab_craprispl(vr_indcrapris).nrctrnov;            
            vr_tab_crapris(vr_idxcrapris).dtprxpar := vr_tab_craprispl(vr_indcrapris).dtprxpar;
            vr_tab_crapris(vr_idxcrapris).vlprxpar := vr_tab_craprispl(vr_indcrapris).vlprxpar;
            vr_tab_crapris(vr_idxcrapris).qtparcel := vr_tab_craprispl(vr_indcrapris).qtparcel;
            vr_tab_crapris(vr_idxcrapris).dtvencop := vr_tab_craprispl(vr_indcrapris).dtvencop;
            vr_tab_crapris(vr_idxcrapris).dsinfaux := vr_tab_craprispl(vr_indcrapris).dsinfaux;            
            
                       /*0308 = Baixa por limite de identificacao.
                        Quando um risco do mes anterior passou de
                        individualizado para agregado no mes corrente.*/
            vr_tab_crapris(vr_idxcrapris).cdinfadi := '0308';
          END IF;
        END LOOP;

        -- Converte a pl/table para um indice numerico e sequencial
        vr_idxcrapris := vr_tab_crapris.first;
        WHILE vr_idxcrapris IS NOT NULL LOOP
          vr_idxcrapris_n := vr_idxcrapris_n + 1;
          vr_tab_crapris_n(vr_idxcrapris_n) := vr_tab_crapris(vr_idxcrapris);
          vr_idxcrapris := vr_tab_crapris.next(vr_idxcrapris);
        END LOOP;


        -- Gravar todos os registros da PL Table que coletou os dados
        BEGIN
          FORALL idx IN vr_tab_crapris_n.FIRST..vr_tab_crapris_n.LAST SAVE EXCEPTIONS
            INSERT INTO crapris(nrdconta
                               ,dtrefere
                               ,innivris
                               ,qtdiaatr
                               ,vldivida
                               ,vlvec180
                               ,vlvec360
                               ,vlvec999
                               ,vldiv060
                               ,vldiv180
                               ,vldiv360
                               ,vldiv999
                               ,vlprjano
                               ,vlprjaan
                               ,inpessoa
                               ,nrcpfcgc
                               ,vlprjant
                               ,inddocto
                               ,cdmodali
                               ,nrctremp
                               ,nrseqctr
                               ,dtinictr
                               ,cdorigem
                               ,cdagenci
                               ,innivori
                               ,cdcooper
                               ,vlprjm60
                               ,dtdrisco
                               ,qtdriclq
                               ,nrdgrupo
                               ,vljura60
                               ,inindris
                               ,cdinfadi
                               ,flgindiv
                               ,nrctrnov
                               ,dtprxpar
                               ,vlprxpar
                               ,qtparcel
                               ,dtvencop
                               ,dsinfaux)
              VALUES(vr_tab_crapris_n(idx).nrdconta
                    ,vr_tab_crapris_n(idx).dtrefere
                    ,vr_tab_crapris_n(idx).innivris
                    ,vr_tab_crapris_n(idx).qtdiaatr
                    ,vr_tab_crapris_n(idx).vldivida
                    ,vr_tab_crapris_n(idx).vlvec180
                    ,vr_tab_crapris_n(idx).vlvec360
                    ,vr_tab_crapris_n(idx).vlvec999
                    ,vr_tab_crapris_n(idx).vldiv060
                    ,vr_tab_crapris_n(idx).vldiv180
                    ,vr_tab_crapris_n(idx).vldiv360
                    ,vr_tab_crapris_n(idx).vldiv999
                    ,vr_tab_crapris_n(idx).vlprjano
                    ,vr_tab_crapris_n(idx).vlprjaan
                    ,vr_tab_crapris_n(idx).inpessoa
                    ,vr_tab_crapris_n(idx).nrcpfcgc
                    ,vr_tab_crapris_n(idx).vlprjant
                    ,vr_tab_crapris_n(idx).inddocto
                    ,vr_tab_crapris_n(idx).cdmodali
                    ,vr_tab_crapris_n(idx).nrctremp
                    ,vr_tab_crapris_n(idx).nrseqctr
                    ,vr_tab_crapris_n(idx).dtinictr
                    ,vr_tab_crapris_n(idx).cdorigem
                    ,vr_tab_crapris_n(idx).cdagenci
                    ,vr_tab_crapris_n(idx).innivori
                    ,vr_tab_crapris_n(idx).cdcooper
                    ,vr_tab_crapris_n(idx).vlprjm60
                    ,vr_tab_crapris_n(idx).dtdrisco
                    ,vr_tab_crapris_n(idx).qtdriclq
                    ,vr_tab_crapris_n(idx).nrdgrupo
                    ,vr_tab_crapris_n(idx).vljura60
                    ,vr_tab_crapris_n(idx).inindris
                    ,vr_tab_crapris_n(idx).cdinfadi
                    ,vr_tab_crapris_n(idx).flgindiv
                    ,vr_tab_crapris_n(idx).nrctrnov
                    ,vr_tab_crapris_n(idx).dtprxpar
                    ,vr_tab_crapris_n(idx).vlprxpar
                    ,vr_tab_crapris_n(idx).qtparcel
                    ,vr_tab_crapris_n(idx).dtvencop
                    ,vr_tab_crapris_n(idx).dsinfaux);
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro
            pr_des_erro := 'Erro ao inserir na tabela crapipm. '|| SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));

            RAISE vr_exc_erro;
        END;
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'Erro em pc_cria_saida_operacao: ' || pr_des_erro;
        WHEN OTHERS THEN
          pr_des_erro := 'Erro em pc_cria_saida_operacao: ' || SQLERRM;
      END;
    END pc_cria_saida_operacao;

  BEGIN
    --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper);
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

    -- Buscar a data do periodo no parametro
    OPEN  cr_dsparame(vr_cdprogra);
    FETCH cr_dsparame INTO vr_dsparame;
    CLOSE cr_dsparame;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    -- Buscar dados dos parâmetros de sistema
    OPEN cr_craptab(pr_cdcooper);
    FETCH cr_craptab INTO rw_craptab;

    -- Verficia se retornou registros para a tupla
    IF cr_craptab%NOTFOUND THEN
      CLOSE cr_craptab;
      vr_cdcritic := 55;

      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craptab;

      -- Verifica se substring de retorno atende a especificação
      IF SUBSTR(rw_craptab.dstextab, 1, 1) <> 1 THEN
        vr_cdcritic := 411;

        RAISE vr_exc_saida;
      END IF; 
    END IF;

    -- Atribui data
    vr_dtrefere := to_date(vr_dsparame, 'DD/MM/RRRR');

    -- Verifica se a data de referencia é nula
    IF vr_dtrefere IS NULL THEN
      vr_cdcritic := 013;

      RAISE vr_exc_saida;
    END IF;

    -- Valor para individualizar as operacoes
    vr_vlindivi := TO_NUMBER(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                      ,pr_cdcooper => 0
                                                      ,pr_cdacesso => 'VLR_INDIVIDUALIZAR_3040'));    

    -- Carregar PL Table de emprestimos
    FOR regs IN cr_crapepr(pr_cdcooper) LOOP
      vr_ixcrapepr := LPAD(regs.nrdconta, 15, '0') || LPAD(regs.nrctremp, 15, '0');
      vr_tab_crapepr(vr_ixcrapepr).qtmesdec := regs.qtmesdec;
      vr_tab_crapepr(vr_ixcrapepr).qtpreemp := regs.qtpreemp;
      vr_tab_crapepr(vr_ixcrapepr).inliquid := regs.inliquid;
    END LOOP;


    
    -- Quando execução Trimestral Cecred, carregaremos a CRAPTCO de todas as cooperativas migradas
    -- senão é carregado apenas a CRAPTCO da cooperativa em execução
    IF pr_cdcooper = 3 AND to_char(vr_dtrefere,'mm') IN ('03','06','09','12') THEN
      vr_cdcooper := 0;
    ELSE
      vr_cdcooper := pr_cdcooper;
    END IF; 
    
    -- Carrega as tabelas de contas transferidas da Viacredi e do AltoVale e SCRCred
    FOR rw_crapcop IN cr_crapcop(vr_cdcooper) LOOP
      IF rw_crapcop.cdcooper = 1 THEN
        -- Vindas da Acredicoop
        IF vr_dtrefere <= TO_DATE('31/12/2013', 'DD/MM/RRRR') THEN
          FOR regs IN cr_craptco LOOP
            vr_tab_craptco(lpad(rw_crapcop.cdcooper,3,'0')||LPAD(regs.nrdconta, 15, '0')) := regs.nrctaant;
          END LOOP;
        END IF;  
        -- Incorporação da Concredi 
        IF vr_dtrefere <= TO_DATE('30/11/2014', 'DD/MM/RRRR') THEN
          FOR regs IN cr_craptco_inc(rw_crapcop.cdcooper,4) LOOP
            vr_tab_craptco(lpad(rw_crapcop.cdcooper,3,'0')||LPAD(regs.nrdconta, 15, '0')) := regs.nrctaant;
          END LOOP;
        END IF;  
      -- Migração Via >> Altovale
      ELSIF rw_crapcop.cdcooper = 16 AND vr_dtrefere <= TO_DATE('31/12/2012', 'DD/MM/RRRR') THEN
        -- Vindas da Via
        FOR regs IN cr_craptco_16 LOOP
          vr_tab_craptco(lpad(rw_crapcop.cdcooper,3,'0')||LPAD(regs.nrdconta, 15, '0')) := regs.nrctaant;
        END LOOP;
      -- Incorporação da Credimil >> SCR
      ELSIF rw_crapcop.cdcooper = 13 AND vr_dtrefere <= TO_DATE('30/11/2014', 'DD/MM/RRRR') THEN
        -- Vindas da Credimil
        FOR regs IN cr_craptco_inc(rw_crapcop.cdcooper,15) LOOP
          vr_tab_craptco(lpad(rw_crapcop.cdcooper,3,'0')||LPAD(regs.nrdconta, 15, '0')) := regs.nrctaant;
        END LOOP;
      -- Incorporação da Transulcred >> Transpocred
      ELSIF rw_crapcop.cdcooper = 9 AND vr_dtrefere <= TO_DATE('31/12/2016', 'DD/MM/RRRR') THEN
        -- Vindas da Transulcred
        FOR regs IN cr_craptco_inc(rw_crapcop.cdcooper,17) LOOP
          vr_tab_craptco(lpad(rw_crapcop.cdcooper,3,'0')||LPAD(regs.nrdconta, 15, '0')) := regs.nrctaant;
        END LOOP;
      END IF;
    END LOOP;


    -- Carregar pl table de liquidações
    FOR regs IN cr_crawepr(pr_cdcooper) LOOP
      -- Somente considerar as propostas para empréstimos efetivados (CRAPEPR)
      -- e não liquidadas, pois temos casos onde o novo empréstimo é efetivado
      -- e liquidado no mesmo mês, e para o Bacen, o novo contrato nem é enviado
      IF vr_tab_crapepr.exists(LPAD(regs.nrdconta, 15, '0') || LPAD(regs.nrctremp, 15, '0')) AND vr_tab_crapepr(LPAD(regs.nrdconta, 15, '0') || LPAD(regs.nrctremp, 15, '0')).inliquid = 0 THEN
        vr_tab_crawepr(LPAD(regs.nrdconta, 15, '0') || LPAD(REPLACE(regs.nrctrliq##1, ',', ''), 30, '0')) := regs.nrctremp;
        vr_tab_crawepr(LPAD(regs.nrdconta, 15, '0') || LPAD(REPLACE(regs.nrctrliq##2, ',', ''), 30, '0')) := regs.nrctremp;
        vr_tab_crawepr(LPAD(regs.nrdconta, 15, '0') || LPAD(REPLACE(regs.nrctrliq##3, ',', ''), 30, '0')) := regs.nrctremp;
        vr_tab_crawepr(LPAD(regs.nrdconta, 15, '0') || LPAD(REPLACE(regs.nrctrliq##4, ',', ''), 30, '0')) := regs.nrctremp;
        vr_tab_crawepr(LPAD(regs.nrdconta, 15, '0') || LPAD(REPLACE(regs.nrctrliq##5, ',', ''), 30, '0')) := regs.nrctremp;
        vr_tab_crawepr(LPAD(regs.nrdconta, 15, '0') || LPAD(REPLACE(regs.nrctrliq##6, ',', ''), 30, '0')) := regs.nrctremp;
        vr_tab_crawepr(LPAD(regs.nrdconta, 15, '0') || LPAD(REPLACE(regs.nrctrliq##7, ',', ''), 30, '0')) := regs.nrctremp;
        vr_tab_crawepr(LPAD(regs.nrdconta, 15, '0') || LPAD(REPLACE(regs.nrctrliq##8, ',', ''), 30, '0')) := regs.nrctremp;
        vr_tab_crawepr(LPAD(regs.nrdconta, 15, '0') || LPAD(REPLACE(regs.nrctrliq##9, ',', ''), 30, '0')) := regs.nrctremp;
        vr_tab_crawepr(LPAD(regs.nrdconta, 15, '0') || LPAD(REPLACE(regs.nrctrliq##10, ',', ''), 30, '0')) := regs.nrctremp;
      END IF;  
    END LOOP;

    -- Acumular dívida por CPF
    FOR rw_crapris IN cr_crapris(pr_cdcooper, vr_dtrefere) LOOP
      -- Verifica migração/incorporação
      IF NOT fn_verifica_conta_migracao(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta  => rw_crapris.nrdconta) THEN
        CONTINUE;
      END IF;
      -- Reinicializar valor e pltable no primeiro registro do CPF/CNPJ
      IF rw_crapris.nrseqctr = 1 THEN
        vr_vldivida := 0;
        vr_tab_rowid.delete;
      END IF;  

      --zera valor da variavel divida nova
      vr_vldivida_contrato := 0;

      -- Acumular o valor da dívida (Somente para inddocto = 1, 4 e 5[desde que não tenha cdinfadi])
      IF rw_crapris.inddocto IN (1,3,4,5) AND nvl(rw_crapris.cdinfadi,' ') <> '0301'  THEN
        IF rw_crapris.cdmodali = 101 THEN -- ADP  -- Alterado para verificar pela modalidade de não pelo inddocto (Reginaldo/AMcom) 
          vr_vldivida_contrato :=  rw_crapris.vlsld59d;
        ELSE
          vr_vldivida_contrato := (rw_crapris.vldivida - rw_crapris.vljura60);
        END IF;      
      END IF;
      
      -- ***
      -- Subtrair os Juros + 60 do valor total da dívida nos casos de empréstimos/ financiamentos (cdorigem = 3)
      -- estejam em Prejuízo (innivris = 10)
      IF rw_crapris.cdorigem = 3
      AND rw_crapris.innivris = 10 THEN

        vr_vljuro60 := PREJ0001.fn_juros60_emprej(pr_cdcooper => pr_cdcooper
                                                                ,pr_nrdconta => rw_crapris.nrdconta
                                                 ,pr_nrctremp => rw_crapris.nrctremp);
        -- Se o valor da divida for maior que juros60
        -- Verifica divida nova
        IF vr_vldivida_contrato > vr_vljuro60 then
           vr_vldivida_contrato := vr_vldivida_contrato - vr_vljuro60;
        END IF; 

      END IF;              

      vr_vldivida := vr_vldivida + vr_vldivida_contrato;
      
      -- Adicionar este rowid a pltable
      vr_tab_rowid(vr_tab_rowid.count()+1) := rw_crapris.rowid;        
      -- Para o ultimo registro (Já acumulou todos os contratos do CPF)
      IF rw_crapris.nrseqctr = rw_crapris.qtdcontr THEN
        -- Individualizar caso valor acumulado >= a R$ 200,00
        IF vr_vldivida >= vr_vlindivi THEN
          -- Varrer pltable
          FOR vr_idx IN 1..vr_tab_rowid.count LOOP  
            BEGIN
              UPDATE crapris cr
                 SET cr.flgindiv = 1
              WHERE ROWID = vr_tab_rowid(vr_idx);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar CRAPRIS: ' ||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END LOOP;
        END IF;
      END IF;
    END LOOP;

    -- Executar procedimento de saída de operação
    pc_cria_saida_operacao(pr_cdcooper    => pr_cdcooper
                          ,pr_dtrefere    => vr_dtrefere
                          ,pr_rw_crapdat  => rw_crapdat
                          ,pr_des_erro    => vr_dscritic);

    -- Verifica se ocorreram erros
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
----======================================= BNDES ==============================================--
    -- Para execução Trimestral na Central 
    IF pr_cdcooper = 3
    AND to_char(vr_dtrefere, 'mm') IN ('03', '06', '09', '12') THEN
      -- Vamos buscar toda a central de risco de todas as Cooperativas com origem BNDES para individualizar as mesmas
      -- NEste cursor já estamos trazendo as saídas de operações, criadas na pc_cria_saida_operacao acima executada
      FOR rw_crapris IN cr_crapris_BNDES(vr_dtrefere) LOOP
        -- Reinicializar valor e pltable no primeiro registro do CPF/CNPJ
        IF rw_crapris.nrseqctr = 1 THEN
          vr_vldivida := 0;
          vr_tab_rowid.delete;
        END IF;  

        -- zera a variavel vr_vldivida_contrato
        vr_vldivida_contrato := 0;

        -- Verifica migração/incorporação
        IF NOT fn_verifica_conta_migracao(pr_cdcooper => rw_crapris.cdcooper
                                         ,pr_nrdconta => rw_crapris.nrdconta) THEN
          CONTINUE;
        END IF;
        -- Acumular o valor da dívida (Somente para inddocto = 1, 4 e 5[desde que não tenha cdinfadi])
        IF rw_crapris.inddocto IN (1,3,4,5) AND nvl(rw_crapris.cdinfadi,' ') <> '0301'  THEN
          IF rw_crapris.cdmodali = 101 THEN -- Alterado para verificar pela modalidade de não pelo inddocto (Reginaldo/AMcom) 
             vr_vldivida_contrato :=  rw_crapris.vlsld59d;
          ELSE
             vr_vldivida_contrato := (rw_crapris.vldivida - rw_crapris.vljura60);
          END IF;
        END IF;
        -- ***

        -- Subtrair os Juros + 60 do valor total da dívida nos casos de empréstimos/ financiamentos (cdorigem = 3)
        -- estejam em Prejuízo (innivris = 10)
        IF rw_crapris.cdorigem = 3
        AND rw_crapris.innivris = 10 THEN
          vr_vljuro60 := PREJ0001.fn_juros60_emprej(pr_cdcooper => rw_crapris.cdcooper,
                                                    pr_nrdconta => rw_crapris.nrdconta,
                                                    pr_nrctremp => rw_crapris.nrctremp);
          -- Se o valor da divida for maior que juros60
           IF vr_vldivida_contrato > vr_vljuro60 THEN
              vr_vldivida_contrato := vr_vldivida_contrato - vr_vljuro60;
           END IF;
        END IF; 

        vr_vldivida := vr_vldivida + vr_vldivida_contrato;

        -- Adicionar este rowid a pltable
        vr_tab_rowid(vr_tab_rowid.count()+1) := rw_crapris.rowid;        
        -- Para o ultimo registro (Já acumulou todos os contratos do CPF)
        IF rw_crapris.nrseqctr = rw_crapris.qtdcontr THEN
          -- Individualizar caso valor acumulado >= a R$ 200,00
          IF vr_vldivida >= vr_vlindivi THEN
            -- Varrer pltable
            FOR vr_idx IN 1..vr_tab_rowid.count LOOP  
              BEGIN
                UPDATE crapris cr
                   SET cr.flindbndes = 1
                WHERE ROWID = vr_tab_rowid(vr_idx);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar CRAPRIS quanto a individualização BNDES: ' ||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            END LOOP;
          END IF;
        END IF;
      END LOOP;      
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
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> ' || vr_dscritic );

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
END pc_crps660;
/
