CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS782 (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                             ,pr_cdagenci IN crapage.cdagenci%TYPE      --> Codigo Agencia
                                             ,pr_nmdatela IN VARCHAR2                   --> Nome Tela
                                             ,pr_idparale IN crappar.idparale%TYPE      --> Indicador de processoparalelo
                                             ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                             ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT VARCHAR2) IS              --> Descricao da Critica
BEGIN

  /* .............................................................................

  Programa: PC_CRPS782
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Josiane Stiehler
  Data    : 03/07/2019                      Ultima atualizacao: 

  Dados referentes ao programa:

  Frequencia: Diaria
  Objetivo  : Atualizar o saldo das parcela e contratos do emprestimo consignado

  Alteracoes: 
			  
 ............................................................................. */

  DECLARE
    --Selecionar  contratos de emprestimo de consignado não liquidados
    CURSOR cr_crapepr  IS
     SELECT epr.cdcooper,
            epr.nrdconta,
            epr.nrctremp,
            epr.qtmesdec,
            epr.cdlcremp,
            epr.dtmvtolt,
            epr.cdagenci,
            epr.cdbccxlt,
            epr.nrdolote,
            epr.vlemprst,
            epr.qtpreemp,
            epr.nrctaav1,
            epr.nrctaav2,
            epr.cdfinemp
       FROM crapepr epr
      WHERE epr.tpemprst = 1 -- Price Pre Fixado
        AND epr.tpdescto = 2        
        AND epr.inliquid = 0; -- não liquidado
    rw_crapepr cr_crapepr%ROWTYPE;

    CURSOR cr_crappep (pr_cdcooper IN crappep.cdcooper%TYPE,
                       pr_nrdconta IN crappep.nrdconta%TYPE,
                       pr_nrctremp IN crappep.nrctremp%TYPE) IS
     SELECT pep.cdcooper,
            pep.nrdconta,
            pep.nrctremp,
            pep.nrparepr,
            pep.vlsdvpar,
            pep.dtvencto
       FROM crappep pep
      WHERE pep.cdcooper = pr_cdcooper
        AND pep.nrdconta = pr_nrdconta
        AND pep.nrctremp = pr_nrctremp
        AND pep.inliquid = 0 -- não liquidado
      ORDER BY pep.dtvencto asc;
    rw_crappep cr_crappep%ROWTYPE;

    -- Alterações na rotina para executar na cadeia noturna além do debitador
    CURSOR cr_tbgen_param_debit_unico IS
      SELECT tdp.inexec_cadeia_noturna,
             tdp.incontrole_exec_prog      
        FROM tbgen_debitador_param  tdp
       WHERE EXISTS (SELECT 1 
                       FROM tbgen_debitador_horario_proc  tdhp 
                      WHERE tdhp.cdprocesso = tdp.cdprocesso) --Programa deve estar associado a algum horário do Debitador Único        
         AND nrprioridade is not null --Programa deve ter prioridade informada
         AND cdprocesso = 'PC_CRPS782';    
    rw_tbgen_param_debit_unico cr_tbgen_param_debit_unico%ROWTYPE;

    -- Buscar o ultimo lançamento de juros
    CURSOR cr_craplem_carga (pr_cdcooper IN craplem.cdcooper%TYPE,
                             pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                             pr_cdagenci IN craplem.cdagenci%TYPE) IS
      SELECT 
         craplem.nrdconta,
         craplem.nrctremp,
         SUM(DECODE(craplem.cdhistor,
                        1044,
                        craplem.vllanmto,
                        1039,
                        craplem.vllanmto,
                        1045,
                        craplem.vllanmto,
                        1057,
                        craplem.vllanmto,
                        1716,
                        craplem.vllanmto * -1,
                        1707,
                        craplem.vllanmto * -1,
                        1714,
                        craplem.vllanmto * -1,
                        1705,
                        craplem.vllanmto * -1)) as vllanmto
       FROM craplem
           ,crapass
       WHERE craplem.cdcooper = crapass.cdcooper
         AND craplem.nrdconta = crapass.nrdconta
         AND craplem.cdcooper = pr_cdcooper
         AND crapass.cdagenci = decode(pr_cdagenci, 0, crapass.cdagenci, pr_cdagenci) -- Ligeirinho.
         AND craplem.nrdolote in (600012,600013,600031)
         AND craplem.cdhistor in (1044,1045,1039,1057,1716,1707,1714,1705)
         AND craplem.dtmvtolt between trunc(pr_dtmvtolt,'mm') and trunc(last_day(pr_dtmvtolt)) --> Mesmo ano e mês corrente
      GROUP BY craplem.nrdconta,craplem.nrctremp;

    CURSOR cr_consig_parcela (pr_dtmovimento tbepr_consig_parcelas_tmp.dtmovimento%TYPE) IS
     SELECT tcp.idseqparc,     
            tcp.cdcooper,      
            tcp.nrdconta,      
            tcp.nrctremp,      
            tcp.nrparcela,     
            tcp.dtmovimento,   
            tcp.dtgravacao,    
            tcp.vlsaldoparc,   
            tcp.vlmoraatraso,  
            tcp.vlmultaatraso, 
            tcp.vliofatraso,   
            tcp.vldescantec,   
            tcp.dtpagtoparc,   
            tcp.inparcelaliq,  
            tcp.instatusproces,
            tcp.dserroproces  
       FROM tbepr_consig_parcelas_tmp tcp
      WHERE tcp.dtmovimento = pr_dtmovimento;


    CURSOR cr_consig_contrato (pr_dtmovimento tbepr_consig_parcelas_tmp.dtmovimento%TYPE) IS
     SELECT tcc.idseqcontr,       
            tcc.cdcooper,         
            tcc.nrdconta,         
            tcc.nrctremp,        
            tcc.dtmovimento,      
            tcc.dtgravacao,       
            tcc.inclidesligado,   
            tcc.vliofepr,         
            tcc.vliofadic,        
            tcc.qtprestpagas,     
            tcc.vljuramesatu,     
            tcc.vljuramesant,     
            tcc.vlsdev_empratu_d0,
            tcc.vlsdev_empratu_d1,
            tcc.vljura60dias,     
            tcc.instatuscontr,    
            tcc.instatusproces,   
            tcc.dserroproces     
       FROM tbepr_consig_contrato_tmp tcc
      WHERE tcc.dtmovimento = pr_dtmovimento;

    CURSOR cr_consig_movimento (pr_dtmovimento tbepr_consig_parcelas_tmp.dtmovimento%TYPE) IS
      SELECT tcm.idseqmov,      
             tcm.cdcooper,      
             tcm.nrdconta,      
             tcm.nrctremp,      
             tcm.nrparcela,     
             tcm.dtmovimento,  
             tcm.dtgravacao,    
             tcm.vldebito,      
             tcm.vlcredito,     
             tcm.vlsaldo,       
             tcm.intplancamento,
             tcm.instatusproces,
             tcm.dserroproces,
             epr.txjuremp,
             epr.vlpreemp,
             pep.dtvencto,
             epr.dtrefjur        
        FROM tbepr_consig_movimento_tmp tcm,
             crapepr epr,
             crappep pep
       WHERE tcm.cdcooper    = pep.cdcooper
         AND tcm.nrdconta    = pep.nrdconta
         AND tcm.nrctremp    = pep.nrctremp
         AND tcm.nrparcela   = pep.nrparepr
         AND epr.cdcooper    = pep.cdcooper
         AND epr.nrdconta    = pep.nrdconta
         AND epr.nrctremp    = pep.nrctremp
         AND tcm.dtmovimento = pr_dtmovimento;
    
    CURSOR cr_craplcrepr (pr_cdcooper IN crapepr.cdcooper%TYPE,
                       pr_nrdconta IN crapepr.nrdconta%TYPE,
                       pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT lcr.dsoperac
      FROM craplcr lcr,
           crapepr epr
     WHERE epr.cdcooper = lcr.cdcooper
       AND epr.cdlcremp = lcr.cdlcremp
       AND epr.cdcooper = pr_cdcooper
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp;
    
    rw_craplcrepr cr_craplcrepr%ROWTYPE;

    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT ass.cdagenci
       FROM crapass ass    
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%ROWTYPE;        


    CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE,
                       pr_nrdconta IN craplcm.nrdconta%TYPE,
                       pr_nrctremp IN craplcm.cdpesqbb%TYPE,
                       pr_nrparepr IN craplcm.nrparepr%TYPE,
                       pr_vllanmto IN craplcm.vllanmto%TYPE) IS
    SELECT 1 vr_existe
      FROM craplcm lcm
     WHERE lcm.cdcooper = pr_cdcooper
       AND lcm.nrdconta = pr_nrdconta
       AND lcm.cdpesqbb = gene0002.fn_mask(pr_nrctremp, 'zz.zzz.zz9')
       AND lcm.nrparepr = pr_nrparepr
       AND lcm.vllanmto = pr_vllanmto;

    rw_craplcm cr_craplcm%ROWTYPE; 
    
    CURSOR cr_juros_rem (pr_cdcooper IN tbepr_consig_movimento_tmp.cdcooper%TYPE,
                         pr_nrdconta IN tbepr_consig_movimento_tmp.nrdconta%TYPE,
                         pr_nrctremp IN tbepr_consig_movimento_tmp.nrctremp%TYPE,
                         pr_nrparepr IN tbepr_consig_movimento_tmp.nrparcela%TYPE,
                         pr_dtrefjur IN tbepr_consig_movimento_tmp.dtmovimento%TYPE) IS
     SELECT SUM(nvl(tcm.vlsaldo,0)) vljurosrem    
       FROM tbepr_consig_movimento_tmp tcm
      WHERE tcm.cdcooper    = pr_cdcooper
        AND tcm.nrdconta    = pr_nrdconta
        AND tcm.nrctremp    = pr_nrctremp
        AND tcm.nrparcela   = pr_nrparepr
        AND tcm.dtmovimento > pr_dtrefjur
        AND tcm.intplancamento = 10; -- Lançamentos de Juros remuneratórios
        
   -- busca a data da ultima parcela liquidada
   CURSOR cr_ult_pagto (pr_cdcooper IN crappep.cdcooper%TYPE,
                        pr_nrdconta IN crappep.nrdconta%TYPE,
                        pr_nrctremp IN crappep.nrctremp%TYPE) IS
    SELECT max(pep.dtultpag) dtultpag
      FROM crappep pep
     WHERE pep.cdcooper = pr_cdcooper
       AND pep.nrdconta = pr_nrdconta
       AND pep.nrctremp = pr_nrctremp
       AND pep.inliquid = 1;-- liquidado     
    
    --Selecionar Linhas de Credito
    CURSOR cr_craplcr (pr_cdcooper IN craplcr.cdcooper%TYPE) IS
     SELECT craplcr.cdlcremp
       FROM craplcr
      WHERE craplcr.cdcooper = pr_cdcooper;
    
    --Selecionar Cotas
    CURSOR cr_crapcot (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE) IS
     SELECT crapcot.ROWID
       FROM crapcot
      WHERE crapcot.cdcooper = pr_cdcooper
        AND crapcot.nrdconta = pr_nrdconta;
       rw_crapcot cr_crapcot%ROWTYPE;
    
    --Selecionar Moedas
    CURSOR cr_crapmfx (pr_cdcooper IN crapmfx.cdcooper%TYPE
                      ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE
                      ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS
     SELECT mfx.cdcooper,
            mfx.vlmoefix
       FROM crapmfx mfx
      WHERE mfx.cdcooper = pr_cdcooper
        AND mfx.dtmvtolt = pr_dtmvtolt
        AND mfx.tpmoefix = pr_tpmoefix;
     rw_crapmfx cr_crapmfx%ROWTYPE;


     --Selecionar Registro de Microfilmagem
     CURSOR cr_crapmcr (pr_cdcooper IN crapmcr.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapmcr.dtmvtolt%TYPE
                       ,pr_cdagenci IN crapmcr.cdagenci%TYPE
                       ,pr_cdbccxlt IN crapmcr.cdbccxlt%TYPE
                       ,pr_nrdolote IN crapmcr.nrdolote%TYPE
                       ,pr_nrdconta IN crapmcr.nrdconta%TYPE
                       ,pr_nrcontra IN crapmcr.nrcontra%TYPE
                       ,pr_tpctrmif IN crapmcr.tpctrmif%TYPE) IS
     SELECT mcr.cdcooper
       FROM crapmcr mcr
      WHERE mcr.cdcooper = pr_cdcooper
        AND mcr.dtmvtolt = pr_dtmvtolt
        AND mcr.cdagenci = pr_cdagenci
        AND mcr.cdbccxlt = pr_cdbccxlt
        AND mcr.nrdolote = pr_nrdolote
        AND mcr.nrdconta = pr_nrdconta
        AND mcr.nrcontra = pr_nrcontra
        AND mcr.tpctrmif = pr_tpctrmif;
      rw_crapmcr cr_crapmcr%ROWTYPE;
       
    --Registro do tipo calendario
    rw_crapdat         BTCH0001.cr_crapdat%ROWTYPE;

    --Constantes
    vr_cdprogra        CONSTANT crapprg.cdprogra%TYPE:= 'CRPS782';

    --Variaveis para retorno de erro
    vr_cdcritic        INTEGER:= 0;
    vr_dscritic        VARCHAR2(4000);
    vr_idprglog        NUMBER;

    --Variaveis de Excecao
    vr_exc_saida       EXCEPTION;
    vr_gera_log        EXCEPTION;
    vr_gera_log_saldo  EXCEPTION;
    
    -- Debitador Unico
    vr_flultexe          NUMBER;
    vr_qtdexec           NUMBER;

    --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
    vr_idcontrole        tbgen_batch_controle.idcontrole%TYPE;  
    vr_idlog_ini_ger     tbgen_prglog.idprglog%TYPE;
    vr_idlog_ini_par     tbgen_prglog.idprglog%TYPE;    
    vr_tpexecucao        tbgen_prglog.tpexecucao%TYPE; 
    vr_qterro            NUMBER := 0;    

    -- Tipo utilizado para armazenar os dados da tabela do ODI
    TYPE typ_tbepr_consig_parcelas_tmp IS TABLE OF tbepr_consig_parcelas_tmp%ROWTYPE INDEX BY VARCHAR2(40);
    vr_tab_parcelas      typ_tbepr_consig_parcelas_tmp;
    vr_index_parcela     VARCHAR2(40);
    vr_index_crappep     VARCHAR2(40);

    TYPE typ_tbepr_consig_contrato_tmp IS TABLE OF tbepr_consig_contrato_tmp%ROWTYPE INDEX BY VARCHAR2(40);
    vr_tab_contrato      typ_tbepr_consig_contrato_tmp;
    vr_index_contrato    VARCHAR2(40);
    vr_index_crapepr     VARCHAR2(40);

    TYPE typ_tab_craplem IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
    vr_tab_craplem        typ_tab_craplem;
    vr_index_craplem      VARCHAR2(20);
    
    vr_tab_craplcr CADA0001.typ_tab_number;
    
    vr_dtmvtctr           tbepr_consig_contrato_tmp.dtmovimento%TYPE;
    vr_dtmvtpar           tbepr_consig_contrato_tmp.dtmovimento%TYPE;
    vr_vlsdvctr           crapepr.vlsdvctr%TYPE;
    vr_vlsdevat           crappep.vlsdvpar%TYPE;
    vr_vlpapgat           crappep.vlsdvpar%TYPE;
    vr_dtdpagto           crappep.dtvencto%TYPE;
    vr_vlprepag           crappep.vlsdvpar%TYPE;
    vr_floperac           Boolean;
    vr_cdhistor           craplem.cdhistor%TYPE;
    vr_nrdolote           craplem.nrdolote%TYPE;
    vr_cdoperad           crapope.cdoperad%TYPE:= '1';
    vr_cdorigem           craplem.cdorigem%TYPE;
    vr_jurosrem           craplem.vllanmto%TYPE;
    vr_nrparepr           crappep.nrparepr%TYPE;
    vr_dtultpag           crappep.dtultpag%TYPE;
    
    -- Funão para buscar o hsitórico do estorno
    FUNCTION fn_busca_hist_estorno (pr_cdcooper IN craphis.cdcooper%TYPE,
                                    pr_cdhistor IN craphis.cdhistor%TYPE) RETURN NUMBER IS
      CURSOR cr_craphis IS
       SELECT cdhisest
         FROM craphis
        WHERE craphis.cdcooper = pr_cdcooper
          AND craphis.cdhistor = pr_cdhistor;
          
      vr_cdhisest craphis.cdhisest%TYPE;
    BEGIN
      vr_cdhisest:= null;
      FOR rw_craphis IN cr_craphis
      LOOP
        vr_cdhisest:= rw_craphis.cdhisest;
      END LOOP;
      RETURN (vr_cdhisest);
    END;
    
  ---------------------------------------
  -- Inicio Bloco Principal PC_CRPS782
  ---------------------------------------
  BEGIN
   
    --Limpar parametros saida
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
   
     -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 0
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => vr_cdcritic);

  
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat 
    INTO rw_crapdat;
    
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
       -- Fechar o cursor pois havera raise
       CLOSE BTCH0001.cr_crapdat;
       -- Montar mensagem de critica
       vr_cdcritic:= 1;
       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       RAISE vr_exc_saida;
    ELSE
       -- Apenas fechar o cursor
       CLOSE BTCH0001.cr_crapdat;
    END IF;
  
    IF rw_crapdat.inproces > 1 THEN
       vr_tpexecucao:= 1; -- batch
       vr_dtmvtctr:= rw_crapdat.dtmvtolt;
       vr_dtmvtpar:= rw_crapdat.dtmvtolt;
    ELSE
       vr_tpexecucao:= 2; -- Job (debitador único)
       vr_dtmvtctr:= rw_crapdat.dtmvtoan;
       vr_dtmvtpar:= rw_crapdat.dtmvtolt;       
    END IF;
    
    --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    cecred.pc_log_programa(pr_dstiplog   => 'I',    
                           pr_cdprograma => vr_cdprogra,
                           pr_cdcooper   => pr_cdcooper, 
                           pr_tpexecucao => vr_tpexecucao,     -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_idprglog   => vr_idlog_ini_par); 
                           

    -- Verifica quantidade de execuções do programa durante o dia no Debitador Único
    gen_debitador_unico.pc_qt_hora_prg_debitador(pr_cdcooper   => pr_cdcooper   --Cooperativa
                                                ,pr_cdprocesso => 'PC_'||vr_cdprogra --Processo cadastrado na tela do Debitador (tbgen_debitadorparam)
                                                ,pr_ds_erro    => vr_dscritic); --Retorno de Erro/Crítica
    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;
    
    
    -- Buscar parâmetro de execução na cadeia noturna além do debitador único.
    -- Valida Programa do cadastro do Debitador
    OPEN cr_tbgen_param_debit_unico;
    FETCH cr_tbgen_param_debit_unico 
    INTO rw_tbgen_param_debit_unico;
    
    IF cr_tbgen_param_debit_unico%NOTFOUND THEN
      CLOSE cr_tbgen_param_debit_unico;
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao buscar parâmetro de indicador de execução do programa do debitor na cadeia noturna';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_tbgen_param_debit_unico;
    END IF;
    
    --> Verificar/controlar a execução.
    SICR0001.pc_controle_exec_deb (pr_cdcooper  => pr_cdcooper                 --> Código da coopertiva
                                  ,pr_cdtipope  => 'I'                         --> Tipo de operacao I-incrementar e C-Consultar
                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento
                                  ,pr_cdprogra  => vr_cdprogra                 --> Codigo do programa
                                  ,pr_flultexe  => vr_flultexe                 --> Retorna se é a ultima execução do procedimento
                                  ,pr_qtdexec   => vr_qtdexec                  --> Retorna a quantidade
                                  ,pr_cdcritic  => vr_cdcritic                 --> Codigo da critica de erro
                                  ,pr_dscritic  => vr_dscritic);               --> descrição do erro se ocorrer

    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_saida;
    ELSE
       COMMIT;
    END IF;
    -------------------------------------------------------------------------
    -- Inicio Atualização do Extrato de empréstimo do consignado - CRAPLEM
    ------------------------------------------------------------------------
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => 'CRPS782',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => 2,
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Incicio Atualização do extrato do empréstimo (craplem) PC_CRPS782 - INPROCES - '||rw_crapdat.inproces,
                    PR_IDPRGLOG           => vr_idprglog); 


    -- leitura dos movimentos da tabela do ODI
    FOR rw_consig_movimento IN cr_consig_movimento (rw_crapdat.dtmvtolt)
    LOOP
      BEGIN
        -- seleciona a linha de credito
        OPEN cr_craplcrepr(pr_cdcooper => rw_consig_movimento.cdcooper,
                           pr_nrdconta => rw_consig_movimento.nrdconta,
                           pr_nrctremp => rw_consig_movimento.nrctremp);
        FETCH cr_craplcrepr
        INTO rw_craplcrepr;
        -- Se não encontrar
        IF cr_craplcrepr%NOTFOUND THEN
           -- Fechar o cursor
           CLOSE cr_craplcrepr;
           -- Gerar erro
           vr_cdcritic := 1178;-- linha de credito não encontrada
           RAISE vr_gera_log;
        ELSE
           -- Fechar o cursor
           CLOSE cr_craplcrepr;
        END IF;
        vr_floperac := rw_craplcrepr.dsoperac = 'FINANCIAMENTO';
        
        -- seleciona agencia do cooperado
        OPEN cr_crapass(pr_cdcooper => rw_consig_movimento.cdcooper,
                        pr_nrdconta => rw_consig_movimento.nrdconta);
        FETCH cr_crapass
        INTO rw_crapass;
        -- Se não encontrar
        IF cr_crapass%NOTFOUND THEN
           -- Fechar o cursor
           CLOSE cr_crapass;
           -- Gerar erro
           vr_cdcritic := 1042;-- 1042 - Associado nao encontrado
           RAISE vr_gera_log;
        ELSE
           -- Fechar o cursor
           CLOSE cr_crapass;
        END IF;

        -- Verifica se o lançamento existe no Aimaro
        -- 20 - Consignado (efetuado na FIS), 5 - Aimaro WEB
        OPEN cr_craplcm(pr_cdcooper => rw_consig_movimento.cdcooper,
                        pr_nrdconta => rw_consig_movimento.nrdconta,
                        pr_nrctremp => rw_consig_movimento.nrctremp,
                        pr_nrparepr => rw_consig_movimento.nrparcela,
                        pr_vllanmto => rw_consig_movimento.vlsaldo);
        
        FETCH cr_craplcm
        INTO rw_craplcm;
        -- Se não encontrar
        IF cr_craplcm%NOTFOUND THEN
           vr_cdorigem:= 20; -- consignado
           CLOSE cr_craplcm;
        ELSE
           vr_cdorigem:= 5; --Aimaro web
           CLOSE cr_craplcm;
        END IF;
        
        --Selecionar Valor Moeda
        OPEN cr_crapmfx (pr_cdcooper => rw_consig_movimento.cdcooper
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_tpmoefix => 2);
       FETCH cr_crapmfx INTO rw_crapmfx;
       --Se nao encontrou
       IF cr_crapmfx%NOTFOUND THEN
         -- Montar mensagem de critica
         vr_cdcritic:= 140;
         vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Complementar mensagem
         vr_dscritic:= vr_dscritic ||' da UFIR.';
         RAISE vr_gera_log;
       END IF;
        
        -- os lançamentos 1,8 e 9 já são criados na efetivação da proposta (b1wgen0084.grava_efetivacao_proposta)
        -- 1 - Valor liberado para o cliente (Debito) 
        -- 8 - Valor de IOF cobrado (Credito)         
        -- 9 - Valor de TAC cobrada (Credito)      
        -- O lançamento do Juros remuneratórios (10), é somado e lançado somente no pagamento, no vencimento ou na mensal   
        vr_nrdolote:= 600013;
        vr_cdhistor:= null;
        IF rw_consig_movimento.intplancamento = 2 THEN  -- 2 - Valor de Pagamento - Valor Principal amortizada (Credito)
           vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1039 ELSE 1044 END;

        ELSIF rw_consig_movimento.intplancamento = 3 THEN  --3 - Valor de Pagamento - Valor Juros amortizado (Credito)
          null; -- pendnete
        ELSIF rw_consig_movimento.intplancamento = 4 THEN --4 - Valor de Pagamento de Juros de Mora por atraso (Debito)
           vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1078 ELSE 1077 END;
        
        ELSIF rw_consig_movimento.intplancamento = 5 THEN -- 5 - Valor de Pagamento de Multa por Atraso (Debito)
           vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1076 ELSE 1047 END;
        
        ELSIF rw_consig_movimento.intplancamento = 6 THEN -- 6 - Valor de Pagamento de IOF Atraso (Debito)
           vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 2312 ELSE 2311 END;

        ELSIF rw_consig_movimento.intplancamento = 7 THEN -- 7 - Valor de Desconto (Credito)
            vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1039 ELSE 1044 END;

        ELSIF rw_consig_movimento.intplancamento = 11 THEN -- 11 - Estorno Pagamento - Valor Principal amortizada (Credito)
            vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                 pr_cdhistor => CASE vr_floperac WHEN TRUE THEN 1039 ELSE 1044 END);

        ELSIF rw_consig_movimento.intplancamento = 12 THEN -- 12 - Estorno Pagamento - Valor Juros amortizado (Credito)
            --???? pendeNte
            null;
             
        ELSIF rw_consig_movimento.intplancamento = 13 THEN -- 13 - Estorno Pagamento - Juros de Mora (Credito)
            vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                 pr_cdhistor => CASE vr_floperac WHEN TRUE THEN 1078 ELSE 1077 END);
             
        ELSIF rw_consig_movimento.intplancamento = 14 THEN -- 14 - Estorno Pagamento - Multa (Credito)
            vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                 pr_cdhistor =>  CASE vr_floperac WHEN TRUE THEN 1076 ELSE 1047 END);
          
        ELSIF rw_consig_movimento.intplancamento = 15 THEN -- 15 - Estorno Pagamento - IOF Atraso (Credito)
            vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                 pr_cdhistor =>  CASE vr_floperac WHEN TRUE THEN 2312 ELSE 2311 END);
          
        ELSIF rw_consig_movimento.intplancamento = 16 THEN --  16 - Estorno Pagamento - Desconto Parcela (Debito)                         
            vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                 pr_cdhistor =>  CASE vr_floperac WHEN TRUE THEN 1039 ELSE 1044 END);
        ELSIF rw_consig_movimento.intplancamento IN (1,8,9,10) THEN
          -- os lançamentos 1,8 e 9 já são criados na efetivação da proposta (b1wgen0084.grava_efetivacao_proposta)
          -- o lançamento 10, é somado e lançado somente no pagamento, no vencimento ou na mensal
          vr_cdhistor:= NULL;
        END IF;
       
        -- Lançameto do juros remunerárorios
        -- ocorre no pagameto, no vencimento e na mensal
        IF (rw_consig_movimento.intplancamento = 2 OR -- Valor de Pagamento - Valor Principal amortizada
           (rw_consig_movimento.dtvencto     >  rw_crapdat.dtmvtoan 
            AND rw_consig_movimento.dtvencto <= rw_crapdat.dtmvtolt) OR -- vencimento
            trunc(rw_crapdat.dtmvtolt,'mm') <> trunc(rw_crapdat.dtmvtopr,'mm')) THEN -- mensal
            vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1038 ELSE 1037 END;
            
            vr_jurosrem:= 0;
            -- Busca os juros lançados 
            FOR rw_juros_rem IN cr_juros_rem (pr_cdcooper => rw_consig_movimento.cdcooper,
                                              pr_nrdconta => rw_consig_movimento.nrdconta,
                                              pr_nrctremp => rw_consig_movimento.nrctremp,
                                              pr_nrparepr => rw_consig_movimento.nrparcela,
                                              pr_dtrefjur => rw_consig_movimento.dtrefjur)
            LOOP
              vr_jurosrem:= rw_juros_rem.vljurosrem;
            END LOOP;                                            
            IF vr_jurosrem > 0 THEN 
              --Cria lancamento craplem e atualiza o seu lote */
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_consig_movimento.cdcooper --Codigo Cooperativa
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Emprestimo
                                              ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                              ,pr_cdbccxlt => 100 --Codigo Caixa
                                              ,pr_cdoperad => vr_cdoperad --Operador
                                              ,pr_cdpactra =>  rw_crapass.cdagenci --Posto Atendimento - - agencia do coperado crapass
                                              ,pr_tplotmov => 5 --Tipo movimento
                                              ,pr_nrdolote => vr_nrdolote --Numero Lote
                                              ,pr_nrdconta => rw_consig_movimento.nrdconta --Numero da Conta
                                              ,pr_cdhistor => vr_cdhistor --Codigo Historico
                                              ,pr_nrctremp => rw_consig_movimento.nrctremp --Numero Contrato
                                              ,pr_vllanmto => vr_jurosrem -- Valor do lançamento
                                              ,pr_dtpagemp => rw_crapdat.dtmvtolt --Data Pagamento Emprestimo
                                              ,pr_txjurepr => rw_consig_movimento.txjuremp --Taxa Juros Emprestimo
                                              ,pr_vlpreemp => rw_consig_movimento.vlpreemp --Valor Emprestimo
                                              ,pr_nrsequni => rw_consig_movimento.nrparcela --Numero Sequencia
                                              ,pr_nrparepr => rw_consig_movimento.nrparcela --Numero Parcelas Emprestimo
                                              ,pr_flgincre => TRUE --Indicador Credito
                                              ,pr_flgcredi => TRUE --Credito
                                              ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                              ,pr_cdorigem => vr_cdorigem
                                              ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                              ,pr_dscritic => vr_dscritic); --Descricao Erro
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR
                   vr_dscritic IS NOT NULL THEN
                  RAISE  vr_gera_log;
                END IF;
                
                -- Atualiza a data do lançamento do juros na crapepr
                BEGIN
                  UPDATE crapepr epr
                     SET epr.dtrefjur = rw_crapdat.dtmvtolt 
                   WHERE epr.cdcooper = rw_consig_movimento.cdcooper
                     AND epr.nrdconta = rw_consig_movimento.nrdconta
                     AND epr.nrctremp = rw_consig_movimento.nrctremp;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic:= 'Erro ao atualizar tabela CRAPEPR - '||SQLERRM;
                    RAISE vr_gera_log;
                END;
                
                --  Atualiza valor dos juros pagos em moeda fixa no crapcot 
                OPEN cr_crapcot (pr_cdcooper => rw_consig_movimento.cdcooper
                                ,pr_nrdconta => rw_consig_movimento.nrdconta);
                 --Proximo Registro
                 FETCH cr_crapcot INTO rw_crapcot;
                 --Se nao encontrou
                 IF cr_crapcot%NOTFOUND THEN
                   --Fechar Cursor
                   CLOSE cr_crapcot;
                   vr_cdcritic:= 169;
                   vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                   --Complementar Mensagem
                   vr_dscritic:= vr_dscritic||' - CONTA = '||gene0002.fn_mask(rw_crapepr.nrdconta,'zzzz.zz9.9');
                   RAISE vr_gera_log;
                 ELSE
                   --Fechar Cursor
                   CLOSE cr_crapcot;
                   --Atualizar tabela cotas
                   BEGIN
                     UPDATE crapcot cot
                        SET cot.qtjurmfx = nvl(cot.qtjurmfx,0) +
                                           ROUND(vr_jurosrem / rw_crapmfx.vlmoefix,4)
                      WHERE cot.rowid = rw_crapcot.rowid;
                   EXCEPTION
                     WHEN OTHERS THEN
                     vr_cdcritic:= 0;
                     vr_dscritic:= 'Erro ao atualizar tabela crapcot. '||SQLERRM;
                     --Levantar Excecao
                     RAISE vr_gera_log;
                   END;
                 END IF;
                
             END IF;         
        END IF; 
      
        IF vr_cdhistor IS NOT NULL THEN
           --Cria lancamento craplem e atualiza o seu lote */
           empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_consig_movimento.cdcooper --Codigo Cooperativa
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Emprestimo
                                          ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                          ,pr_cdbccxlt => 100 --Codigo Caixa
                                          ,pr_cdoperad => vr_cdoperad --Operador
                                          ,pr_cdpactra =>  rw_crapass.cdagenci --Posto Atendimento - - agencia do coperado crapass
                                          ,pr_tplotmov => 5 --Tipo movimento
                                          ,pr_nrdolote => vr_nrdolote --Numero Lote
                                          ,pr_nrdconta => rw_consig_movimento.nrdconta --Numero da Conta
                                          ,pr_cdhistor => vr_cdhistor --Codigo Historico
                                          ,pr_nrctremp => rw_consig_movimento.nrctremp --Numero Contrato
                                          ,pr_vllanmto => rw_consig_movimento.vlsaldo -- Valor do lançamento
                                          ,pr_dtpagemp => rw_crapdat.dtmvtolt --Data Pagamento Emprestimo
                                          ,pr_txjurepr => rw_consig_movimento.txjuremp --Taxa Juros Emprestimo
                                          ,pr_vlpreemp => rw_consig_movimento.vlpreemp --Valor Emprestimo
                                          ,pr_nrsequni => rw_consig_movimento.nrparcela --Numero Sequencia
                                          ,pr_nrparepr => rw_consig_movimento.nrparcela --Numero Parcelas Emprestimo
                                          ,pr_flgincre => TRUE --Indicador Credito
                                          ,pr_flgcredi => TRUE --Credito
                                          ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                          ,pr_cdorigem => vr_cdorigem
                                          ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                          ,pr_dscritic => vr_dscritic); --Descricao Erro
           --Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR
              vr_dscritic IS NOT NULL THEN
             RAISE vr_gera_log;
           END IF;
           
           -- Atualiza o valor pago da parcela se o movimento 
           -- for de pagamento e da origem 20 - Conignado (FIS)
           IF rw_consig_movimento.intplancamento IN ( 2,11) AND -- 2- pagamento principal, 11- Estorno do pagamento principal
              vr_cdorigem = 20 THEN -- Consignado (FIS)
               BEGIN
                 UPDATE crappep pep
                    SET pep.vlpagpar = nvl(pep.vlpagpar,0) +  
                                       (rw_consig_movimento.vlsaldo * decode(rw_consig_movimento.intplancamento,11,-1,1))
                  WHERE pep.cdcooper = rw_consig_movimento.cdcooper
                    AND pep.nrdconta = rw_consig_movimento.nrdconta
                    AND pep.nrctremp = rw_consig_movimento.nrctremp
                    AND pep.nrparepr = rw_consig_movimento.nrparcela;
               EXCEPTION
                 WHEN OTHERS THEN
                    vr_dscritic:= 'Erro ao atualizar crappep - '||sqlerrm;
                    RAISE vr_gera_log;
               END;
           END IF;
         END IF;
         COMMIT;
      EXCEPTION
        WHEN vr_gera_log THEN
          ROLLBACK;
          IF vr_cdcritic is NOT NULL AND
             vr_cdcritic <> 0 THEN
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;
          vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                           rw_consig_movimento.nrctremp||'/'||
                                           rw_consig_movimento.nrparcela||'/'||
                                           rw_consig_movimento.idseqmov||')';
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || vr_dscritic );
      END;
    END LOOP;-- fim do Loop dos movimentos
    -- gera log para futuros rastreios
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => 'CRPS782',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => 2,
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Fim Atualização do extrato do empréstimo (craplem) PC_CRPS782 - INPROCES - '||rw_crapdat.inproces,
                    PR_IDPRGLOG           => vr_idprglog); 
   -------------------------------------------------------------
   -- Fim da atualização do extrato do empréstimo do consignado
   -------------------------------------------------------------
   
   
   ------------------------------------------------------------
   -- Inicio da atualização do Saldo do empréstimo Consignado
   ------------------------------------------------------------
   
    -- gera log para futuros rastreios
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => 'CRPS782',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => 2,
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Inicio da carga das tabelas de saldo PC_CRPS782 - INPROCES - '||rw_crapdat.inproces,
                    PR_IDPRGLOG           => vr_idprglog); 
 
    -- Carregar tabela memoria total pago no mes
    FOR rw_craplem IN cr_craplem_carga (pr_cdcooper => pr_cdcooper,
                                        pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                        pr_cdagenci => pr_cdagenci) 
    LOOP
      --Montar Indice craplem
      vr_index_craplem := lpad(rw_craplem.nrdconta,10,'0')||lpad(rw_craplem.nrctremp,10,'0');                                  
      vr_tab_craplem(vr_index_craplem):= rw_craplem.vllanmto;    
    END LOOP;   
  
    -- carrega a tabela de memória do contrato
    FOR rw_consig_contrato IN cr_consig_contrato(pr_dtmovimento => vr_dtmvtctr) 
    LOOP
       --Montar Indice
       vr_index_contrato := lpad(rw_consig_contrato.cdcooper, 10, '0') ||
                            lpad(rw_consig_contrato.nrdconta, 10, '0') ||
                            lpad(rw_consig_contrato.nrctremp, 10, '0');
                            
       vr_tab_contrato(vr_index_contrato).idseqcontr        := rw_consig_contrato.idseqcontr;
       vr_tab_contrato(vr_index_contrato).cdcooper          := rw_consig_contrato.cdcooper;
       vr_tab_contrato(vr_index_contrato).nrdconta          := rw_consig_contrato.nrdconta;      
       vr_tab_contrato(vr_index_contrato).nrctremp          := rw_consig_contrato.nrctremp;     
       vr_tab_contrato(vr_index_contrato).dtmovimento       := rw_consig_contrato.dtmovimento;      
       vr_tab_contrato(vr_index_contrato).dtgravacao        := rw_consig_contrato.dtgravacao;      
       vr_tab_contrato(vr_index_contrato).inclidesligado    := rw_consig_contrato.inclidesligado;   
       vr_tab_contrato(vr_index_contrato).vliofepr          := rw_consig_contrato.vliofepr;   
       vr_tab_contrato(vr_index_contrato).vliofadic         := rw_consig_contrato.vliofadic;   
       vr_tab_contrato(vr_index_contrato).qtprestpagas      := rw_consig_contrato.qtprestpagas;   
       vr_tab_contrato(vr_index_contrato).vljuramesatu      := rw_consig_contrato.vljuramesatu;   
       vr_tab_contrato(vr_index_contrato).vljuramesant      := rw_consig_contrato.vljuramesant;   
       vr_tab_contrato(vr_index_contrato).vlsdev_empratu_d0 := rw_consig_contrato.vlsdev_empratu_d0;
       vr_tab_contrato(vr_index_contrato).vlsdev_empratu_d1 := rw_consig_contrato.vlsdev_empratu_d1;
       vr_tab_contrato(vr_index_contrato).vljura60dias      := rw_consig_contrato.vljura60dias; 
       vr_tab_contrato(vr_index_contrato).instatuscontr     := rw_consig_contrato.instatuscontr;
       vr_tab_contrato(vr_index_contrato).instatusproces    := rw_consig_contrato.instatusproces;
       vr_tab_contrato(vr_index_contrato).dserroproces      := rw_consig_contrato.dserroproces;
	  END LOOP;
       
    -- carrega a tabela de memória da parcela
    FOR rw_consig_parcela IN cr_consig_parcela(pr_dtmovimento => vr_dtmvtpar) 
    LOOP
      --Montar Indice
      vr_index_parcela := lpad(rw_consig_parcela.cdcooper, 10, '0') ||
                          lpad(rw_consig_parcela.nrdconta, 10, '0') ||
                          lpad(rw_consig_parcela.nrctremp, 10, '0') ||
                          lpad(rw_consig_parcela.nrparcela,10, '0');
      vr_tab_parcelas(vr_index_parcela).idseqparc     := rw_consig_parcela.idseqparc;
      vr_tab_parcelas(vr_index_parcela).cdcooper      := rw_consig_parcela.cdcooper;
      vr_tab_parcelas(vr_index_parcela).nrdconta      := rw_consig_parcela.nrdconta;
      vr_tab_parcelas(vr_index_parcela).nrctremp      := rw_consig_parcela.nrctremp;
      vr_tab_parcelas(vr_index_parcela).nrparcela     := rw_consig_parcela.nrparcela;
      vr_tab_parcelas(vr_index_parcela).dtmovimento   := rw_consig_parcela.dtmovimento;
      vr_tab_parcelas(vr_index_parcela).dtgravacao    := rw_consig_parcela.dtgravacao;
      vr_tab_parcelas(vr_index_parcela).vlsaldoparc   := rw_consig_parcela.vlsaldoparc;
      vr_tab_parcelas(vr_index_parcela).vlmoraatraso  := rw_consig_parcela.vlmoraatraso;
      vr_tab_parcelas(vr_index_parcela).vlmultaatraso := rw_consig_parcela.vlmultaatraso; 
      vr_tab_parcelas(vr_index_parcela).vliofatraso   := rw_consig_parcela.vliofatraso;
      vr_tab_parcelas(vr_index_parcela).vldescantec   := rw_consig_parcela.vldescantec;
      vr_tab_parcelas(vr_index_parcela).dtpagtoparc   := rw_consig_parcela.dtpagtoparc;
      vr_tab_parcelas(vr_index_parcela).inparcelaliq  := rw_consig_parcela.inparcelaliq;
      vr_tab_parcelas(vr_index_parcela).instatusproces:= rw_consig_parcela.instatusproces;
      vr_tab_parcelas(vr_index_parcela).dserroproces  := rw_consig_parcela.dserroproces;
	  END LOOP;
   
    --Carregar tabela linhas credito
    FOR rw_craplcr IN cr_craplcr (pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_craplcr(rw_craplcr.cdlcremp):= 0;
    END LOOP;
    
    --- gera log para futuros rastreios
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => 'CRPS782',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => 2,
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Fim da carga das tabelas de saldo PC_CRPS782 - INPROCES - '||rw_crapdat.inproces,
                    PR_IDPRGLOG           => vr_idprglog); 
                    
    --------------------------------------------
    -- Atualiza Saldos da parcela e do contrato
    --------------------------------------------
    -- gera log para futuros rastreios
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => 'CRPS782',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => 2,
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Inicio da atualização dos Saldos PC_CRPS782 - INPROCES - '||rw_crapdat.inproces,
                    PR_IDPRGLOG           => vr_idprglog); 

    vr_dtdpagto:= NULL; --inicializa a variável
    -- Lê os contratos do consignado não liquidados
    FOR rw_crapepr IN cr_crapepr 
    LOOP
      BEGIN
        vr_nrparepr:=null;
        -- leitura das parcelas não liquidadas do contrato consignado
        FOR rw_crappep IN cr_crappep (pr_cdcooper => rw_crapepr.cdcooper,
                                      pr_nrdconta => rw_crapepr.nrdconta,
                                      pr_nrctremp => rw_crapepr.nrctremp)
        LOOP
          --Montar Indice de acesso
          vr_index_crappep := lpad(rw_crappep.cdcooper, 10, '0') ||
                              lpad(rw_crappep.nrdconta, 10, '0') ||
                              lpad(rw_crappep.nrctremp, 10, '0') ||
                              lpad(rw_crappep.nrparepr, 10, '0');
          --Se nao encontrar a conta e contrato na tabela é problema
          IF NOT vr_tab_parcelas.EXISTS(vr_index_crappep) THEN
             vr_cdcritic := 1148; -- parcela não encontrada
             vr_nrparepr:= rw_crappep.nrparepr;
             RAISE vr_gera_log_saldo;
          ELSE
             BEGIN
                UPDATE crappep pep
                   SET pep.vlsdvatu = vr_tab_parcelas(vr_index_crappep).vlsaldoparc,  --  Saldo devedor atualizado da Parcela
                       pep.vljura60 = 0,                                              -- Juros de Parcelas em Atraso a mais de 60 dias
                       pep.vlmrapar = vr_tab_parcelas(vr_index_crappep).vlmoraatraso, -- Valor de juros pelo atraso no pagamento da parcela.  
                       pep.vlmtapar = vr_tab_parcelas(vr_index_crappep).vlmultaatraso,-- Valor da multa por atraso de pagamento da parcela.
                       pep.vliofcpl = vr_tab_parcelas(vr_index_crappep).vliofatraso,  -- Valor do IOF Complementar de atraso
                       pep.inliquid = vr_tab_parcelas(vr_index_crappep).inparcelaliq, -- Indicador se o emprestimo foi liquidado(0 – Em aberto, 1 – Liquidado)    
                       pep.dtultpag = vr_tab_parcelas(vr_index_crappep).dtpagtoparc   -- data do ultimo pagamento
                 WHERE pep.cdcooper = rw_crappep.cdcooper
                   AND pep.nrdconta = rw_crappep.nrdconta
                   AND pep.nrctremp = rw_crappep.nrctremp
                   AND pep.nrparepr = rw_crappep.nrparepr;
              EXCEPTION
                when others then
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao atualizar crappep: '||SQLERRM;
                  vr_nrparepr:= rw_crappep.nrparepr;
                  raise vr_gera_log_saldo;
              END;    
           END IF;
           vr_vlsdevat:= nvl(vr_vlsdevat,0) + nvl(rw_crappep.vlsdvpar,0);
           -- Calcula o valor da Prestacao a Pagar até o vencimento
           IF rw_crappep.dtvencto <= vr_dtmvtpar  THEN
              vr_vlpapgat := nvl(vr_vlpapgat,0) + nvl(rw_crappep.vlsdvpar,0);
           END IF;
           -- Busca o menor vencimento da parcela não liquidada
           IF vr_dtdpagto IS NULL THEN
              vr_dtdpagto:= rw_crappep.dtvencto;
           END IF;
           -- Montar Indice Lancamentos
           vr_index_craplem := lpad(rw_crapepr.nrdconta,10,'0')||lpad(rw_crapepr.nrctremp,10,'0');
        
           IF vr_tab_craplem.EXISTS(vr_index_craplem) THEN
              vr_vlprepag := NVL(vr_vlprepag,0) + NVL(vr_tab_craplem(vr_index_craplem),0);
           END IF; 
        END LOOP;  
      
        --Montar Indice de acesso
        vr_index_crapepr := lpad(rw_crapepr.cdcooper, 10, '0') ||
                            lpad(rw_crapepr.nrdconta, 10, '0') ||
                            lpad(rw_crapepr.nrctremp, 10, '0');
        --Se nao encontrar a conta e contrato na tabela é problema
        IF NOT vr_tab_contrato.EXISTS(vr_index_crapepr) THEN
           vr_cdcritic := 356; -- Contrato de emprestimo nao encontrado.
           RAISE vr_gera_log_saldo;
        ELSE
          IF rw_crapdat.inproces > 1 THEN
             vr_vlsdvctr:= vr_tab_contrato(vr_index_crapepr).vlsdev_empratu_d0;
          ELSE
             vr_vlsdvctr:= vr_tab_contrato(vr_index_crapepr).vlsdev_empratu_d1;
          END IF;
           -- Busca a data da última parcela paga
          FOR rw_ult_pagto IN cr_ult_pagto (pr_cdcooper => rw_crapepr.cdcooper,
                                            pr_nrdconta => rw_crapepr.nrdconta,
                                            pr_nrctremp => rw_crapepr.nrctremp) 
          LOOP
            vr_dtultpag:= rw_ult_pagto.dtultpag;
          END LOOP;  
          
          -- atualiza a tabela de contrato
          BEGIN
            UPDATE crapepr epr
               SET epr.dtdpagto = vr_dtdpagto,        -- Data do vencimento da primeira prestacao não liquidada.
                   epr.vlsdvctr = vr_vlsdevat,        -- Valor do saldo devedor contratado.
                   epr.qtlcalat = 0,                  -- Quantidade de lancamentos atualizados.
                   epr.qtpcalat = vr_tab_contrato(vr_index_crapepr).qtprestpagas, -- Quantidade de prestacoes calculadas atualizadas
                   epr.qtprecal = vr_tab_contrato(vr_index_crapepr).qtprestpagas, -- Quantidade de prestacoes calculadas atualizadas
                   epr.vlsdevat = vr_vlsdevat,         -- Valor do saldo devedor do emprestimo atualizado.
                   epr.vlpapgat = vr_vlpapgat,         -- Valor das prestacoes a pagar atualizadas.
                   epr.vlppagat = null,                -- Valor das prestacoes pagas atualizadas.
                   epr.qtmdecat = rw_crapepr.qtmesdec, -- Quantidade de meses decorridos atualizados.
                   epr.inliquid = decode(vr_tab_contrato(vr_index_crapepr).instatuscontr,2,1,0), -- indicador da liquidação (0 - não liquidado, 1- liquidado)
                   epr.dtliquid = vr_dtmvtctr,         -- data da liquidação
                   epr.dtultpag = vr_dtultpag,         -- data do último pagamento
                   epr.vlsdeved = vr_vlsdvctr,
                   epr.vljuracu = vr_tab_contrato(vr_index_crapepr).vljuramesant,
                   epr.vljurmes = vr_tab_contrato(vr_index_crapepr).vljuramesatu
             WHERE epr.cdcooper = rw_crapepr.cdcooper
               AND epr.nrdconta = rw_crapepr.nrdconta
               AND epr.nrctremp = rw_crapepr.nrctremp;
          EXCEPTION
            when others then
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar crapepr: '||SQLERRM;
              raise vr_gera_log_saldo;
          END;
           
          --verifica se a linha de credito ja foi atualizada
         IF vr_tab_craplcr(rw_crapepr.cdlcremp) = 0 AND nvl(vr_vlsdvctr,0) > 0 THEN
            --  Atualizacao do indicador de saldo devedor  */
            BEGIN
               UPDATE craplcr SET craplcr.flgsaldo = 1
                WHERE craplcr.cdcooper = rw_crapepr.cdcooper
                  AND craplcr.cdlcremp = rw_crapepr.cdlcremp;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar linha credito. '||SQLERRM;
                --Levantar Excecao
                RAISE vr_gera_log_saldo;
            END;
            --Marcar que ja atualizou essa linha Emprestimo
            vr_tab_craplcr(rw_crapepr.cdlcremp):= 1;
          END IF;
          
          --  Inicializa os meses decorridos para os contratos do mes
          IF to_char(rw_crapepr.dtmvtolt,'YYYYMM') = to_char(vr_dtmvtctr,'YYYYMM') THEN

           --  Criacao do registro para Microfilmagem dos Contratos 
           OPEN cr_crapmcr (pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => rw_crapepr.dtmvtolt
                           ,pr_cdagenci => rw_crapepr.cdagenci
                           ,pr_cdbccxlt => rw_crapepr.cdbccxlt
                           ,pr_nrdolote => rw_crapepr.nrdolote
                           ,pr_nrdconta => rw_crapepr.nrdconta
                           ,pr_nrcontra => rw_crapepr.nrctremp
                           ,pr_tpctrmif => 1); /*emprestimo*/
           FETCH cr_crapmcr INTO rw_crapmcr;
           --Se Encontrou
           IF cr_crapmcr%FOUND THEN
             --Fechar Cursor
             CLOSE cr_crapmcr;
             --Complementar Mensagem
             vr_dscritic:= 'ATENCAO: Contrato ja microfilmado. Conta: '||
                           gene0002.fn_mask(rw_crapepr.nrdconta,'zzzz.zzz9.9')||'  Contrato: '||
                           gene0002.fn_mask(rw_crapepr.nrctremp,'zz.zzz.zz9');
             RAISE vr_gera_log_saldo;  
           ELSE
             --Fechar Cursor
             CLOSE cr_crapmcr;
             --Inserir registro microfilmagem
             BEGIN
               INSERT INTO crapmcr mcr
                 (mcr.dtmvtolt
                 ,mcr.cdagenci
                 ,mcr.cdbccxlt
                 ,mcr.nrdolote
                 ,mcr.nrdconta
                 ,mcr.nrcontra
                 ,mcr.tpctrmif
                 ,mcr.vlcontra
                 ,mcr.qtpreemp
                 ,mcr.nrctaav1
                 ,mcr.nrctaav2
                 ,mcr.cdlcremp
                 ,mcr.cdfinemp
                 ,mcr.cdcooper)
               VALUES
                 (rw_crapepr.dtmvtolt
                 ,rw_crapepr.cdagenci
                 ,rw_crapepr.cdbccxlt
                 ,rw_crapepr.nrdolote
                 ,rw_crapepr.nrdconta
                 ,rw_crapepr.nrctremp
                 ,1
                 ,rw_crapepr.vlemprst
                 ,rw_crapepr.qtpreemp
                 ,nvl(rw_crapepr.nrctaav1,0)
                 ,nvl(rw_crapepr.nrctaav2,0)
                 ,rw_crapepr.cdlcremp
                 ,rw_crapepr.cdfinemp
                 ,pr_cdcooper);
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao inserir CRAPMCR: '||rw_crapepr.nrdconta||'-'||rw_crapepr.nrctremp||'. '||SQLERRM;
                 RAISE vr_gera_log_saldo;
             END;
           END IF;
         END IF;
        END IF;
        COMMIT;
     EXCEPTION
       WHEN vr_gera_log_saldo THEN
         ROLLBACK;
         IF vr_cdcritic is NOT NULL AND 
            vr_cdcritic <> 0 THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         END IF;
            vr_dscritic:= vr_dscritic||' ('||rw_crapepr.nrdconta||'/'||
                                            rw_crapepr.nrctremp||
                                            vr_nrparepr||')';
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
     END;
            
    END LOOP; -- fim do loop do contrato
    
    -- gera log para futuros rastreios
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => 'CRPS782',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => 2,
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Fim da atualização dos Saldos PC_CRPS782 - INPROCES - '||rw_crapdat.inproces,
                    PR_IDPRGLOG           => vr_idprglog); 

    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    --Limpar parametros
    pr_cdcritic:= 0;
    pr_dscritic:= NULL;
         
    --Grava data fim para o JOB na tabela de LOG 
    cecred.pc_log_programa(pr_dstiplog   => 'F',    
                           pr_cdprograma => vr_cdprogra,           
                           pr_cdcooper   => pr_cdcooper, 
                           pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_idprglog   => vr_idlog_ini_par,
                           pr_flgsucesso => 1);       

    

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic IS NOT NULL AND
         vr_cdcritic <> 0 THEN
         -- Buscar a descricao
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_cdcritic);
      END IF;
      
      -- Devolvemos codigo e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      IF vr_dscritic IS NOT NULL AND pr_cdagenci = 0 THEN
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
      END IF;
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper,
                                   pr_compleme => 'pr_cdcooper: ' || pr_cdcooper ||
                                                 ' pr_cdagenci: ' || pr_cdagenci ||
                                                 ' pr_nmdatela: ' || pr_nmdatela ||
                                                 ' pr_idparale: ' || pr_idparale);

      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

  END;
END PC_CRPS782;
/
