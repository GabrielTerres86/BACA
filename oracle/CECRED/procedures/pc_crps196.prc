CREATE OR REPLACE PROCEDURE CECRED.pc_crps196 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  /* .............................................................................

     Programa: pc_crps196   (Fontes/crps196.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odair
     Data    : Maio/97                         Ultima atualizacao: 06/07/2018

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Atende a solicitacao 001.
                 Debitar em conta corrente referente aos convenios

     Alteracoes: 01/07/97 - Listar resumo final convenio 8 (Odair)

                 28/07/97 - Listar resumo final para todos os convenios (Odair).

                 27/08/97 - Alterado para tratar crapavs.flgproce (Deborah).

                 09/09/97 - Acerto no resumo do repasse. (Deborah).

                 06/11/97 - Desmembrar da parte de relatorios (Odair).

                 16/02/98 - Alterar data final do CPMF (Odair)

                 28/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                 21/05/98 - Tratar para descontar apenas integral (Odair).

                 29/06/98 - Alterado para NAO tratar o historico 289 (Edson).

                 04/06/1999 - Tratar CPMF (Deborah).

                 10/09/1999 - Desprezar se crapavs.flgproce for TRUE (Deborah).

                 26/03/2003 - Incluir tratamento da Concredi (Margarete).
                 
                 09/12/2003 - Tratamento erro evitando o duplicates no lcm (Ze).
                 
                 22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)

                 30/06/2005 - Alimentado campo cdcooper das tabelas craplot e
                              craplcm (Diego).

                 15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                              de inicio, tab_dtiniabo. Usa craplcm.dtrefere
                              com craprda.dtmvtolt para pegar se lancamento com
                              abono ou nao (Margarete).

                 10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
                 
                 16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                 
                 09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                              glb_cdcooper) no "find" da tabela CRAPHIS. 
                            - Kbase IT Solutions - Paulo Ricardo Maciel.
                            
                 19/10/2009 - Alteracao Codigo Historico (Kbase).                          
                 
                 21/12/2011 - Aumentado o format do campo cdhistor
                              de "999" para "9999" (Tiago).
                              
                 16/01/2014 - Inclusao de VALIDATE craplot e craplcm (Carlos)
                 
                 12/06/2014 - Alterado tipo da variavel aux_nrdocmto de INTE 
                              para DECI (Elton).
                              
                 26/03/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)             

				 24/04/2017 - Nao considerar valores bloqueados na composicao de saldo disponivel
				              Heitor (Mouts) - Melhoria 440         

                 06/07/2018 - PRJ450 - Regulatorios de Credito - Centralizacao do lancamento em conta corrente (Fabiano B. Dias - AMcom).
                 
                 10/10/2018 - Se a conta está em prejuizo e não foi possivel debitar 
                              gera lançamento futuro (Fabio Adriano - AMcom)
							  
  ............................................................................ */

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS196';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Busca Controle de convenio integrados por empresa.
    CURSOR cr_crapepc (pr_cdcooper crapepc.cdcooper%TYPE) IS
      SELECT crapepc.incvfol1
            ,crapepc.incvfol2 
            ,crapepc.dtcvfol2 
            ,crapepc.incvcta1
            ,crapepc.dtcvcta1
            ,crapepc.incvcta2
            ,crapepc.dtcvcta2
            ,crapepc.nrconven
            ,crapepc.cdempres
            ,crapepc.dtrefere
            ,crapepc.rowid
        FROM crapepc 
       WHERE crapepc.cdcooper = pr_cdcooper;
       
    -- Buscar convenios
    CURSOR cr_crapcnv (pr_cdcooper crapepc.cdcooper%TYPE,
                       pr_nrconven crapepc.nrconven%TYPE) IS
      SELECT crapcnv.indebcre
            ,crapcnv.inlimsld
            ,crapcnv.indescto
            ,crapcnv.nrconven
        FROM crapcnv
       WHERE crapcnv.cdcooper = pr_cdcooper
         AND crapcnv.nrconven = pr_nrconven;
    rw_crapcnv cr_crapcnv%ROWTYPE;     
    
    -- Buscar aviso de debito
    CURSOR cr_crapavs (pr_cdcooper crapepc.cdcooper%TYPE,
                       pr_nrconven crapepc.nrconven%TYPE,
                       pr_cdempres crapepc.cdempres%TYPE,
                       pr_dtrefere crapepc.dtrefere%TYPE) IS
      SELECT crapavs.tpdaviso,
             crapavs.nrdconta,
             crapavs.nrconven,
             crapavs.vllanmto,
             crapavs.vldebito,
             crapavs.nrdocmto,
             crapavs.cdhistor,
             crapavs.insitavs,
             crapavs.vlestdif,
             crapavs.flgproce,
             crapavs.rowid
        FROM crapavs
       WHERE crapavs.cdcooper = pr_cdcooper
         AND crapavs.nrconven = pr_nrconven
         AND crapavs.cdempcnv = pr_cdempres
         AND crapavs.dtrefere = pr_dtrefere
         AND crapavs.insitavs = 0 -- não debitado
         AND crapavs.flgproce = 0; -- nao processado
         
    -- Buscar saldo co cooperado
    CURSOR cr_crapsld (pr_cdcooper crapepc.cdcooper%TYPE,
                       pr_nrdconta crapavs.nrdconta%TYPE) IS
      SELECT crapsld.nrdconta,
             crapsld.vlsdblfp,
             crapsld.vlsdblpr,             
             crapsld.vlipmfpg,
             crapsld.vlsdbloq,
             crapsld.vlsddisp,
             crapsld.vlipmfap
      
        FROM crapsld
       WHERE crapsld.cdcooper = pr_cdcooper
         AND crapsld.nrdconta = pr_nrdconta;
    rw_crapsld cr_crapsld%ROWTYPE;     
    
    -- Buscar dados do cooperado
    CURSOR cr_crapass (pr_cdcooper crapepc.cdcooper%TYPE,
                       pr_nrdconta crapavs.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.vllimcre
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Buscar lançamentos do cooperado
    CURSOR cr_craplcm (pr_cdcooper crapepc.cdcooper%TYPE,
                       pr_nrdconta crapavs.nrdconta%TYPE,
                       pr_dtmvtolt craplcm.dtmvtolt%TYPE) IS
      SELECT /*+ INDEX_ASC(craplcm CRAPLCM##CRAPLCM2) */
             craplcm.cdhistor,
             craplcm.dtrefere,
             craplcm.vllanmto
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.nrdconta = pr_nrdconta
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdhistor <> 289;
         
    -- Buscar dados do historico
    CURSOR cr_craphis (pr_cdcooper crapepc.cdcooper%TYPE,
                       pr_cdhistor craplcm.cdhistor%TYPE) IS
      SELECT craphis.cdhistor,
             craphis.inhistor,
             craphis.indoipmf
        FROM craphis
       WHERE craphis.cdcooper = pr_cdcooper
         AND craphis.cdhistor = pr_cdhistor;
    rw_craphis cr_craphis%ROWTYPE;
    
    -- verificar lote
    CURSOR cr_craplot (pr_cdcooper crapepc.cdcooper%TYPE,
                       pr_dtmvtolt craplcm.dtmvtolt%TYPE) IS
      SELECT  craplot.cdagenci
             ,craplot.cdbccxlt
             ,craplot.nrdolote
             ,craplot.ROWID
             ,craplot.nrseqdig
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdagenci = 1
         AND craplot.cdbccxlt = 100
         AND craplot.nrdolote = 8462;
    rw_craplot cr_craplot%ROWTYPE;  
    
    -- verificar lancamento
    CURSOR cr_craplcm_2 (pr_cdcooper crapepc.cdcooper%TYPE,
                         pr_dtmvtolt craplcm.dtmvtolt%TYPE,
                         pr_cdagenci craplcm.cdagenci%TYPE,
                         pr_cdbccxlt craplcm.cdbccxlt%TYPE,
                         pr_nrdolote craplcm.nrdolote%TYPE,
                         pr_nrdconta craplcm.nrdctabb%TYPE,
                         pr_nrdocmto craplcm.nrdocmto%TYPE) IS
      SELECT /*+index (craplcm craplcm#craplcm1)*/
             craplcm.nrdctabb
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdagenci = pr_cdagenci
         AND craplcm.cdbccxlt = pr_cdbccxlt
         AND craplcm.nrdolote = pr_nrdolote
         AND craplcm.nrdctabb = pr_nrdconta
         AND craplcm.nrdocmto = pr_nrdocmto;
    rw_craplcm_2 cr_craplcm_2%ROWTYPE;
    
    -- verificar controle de convenios
    CURSOR cr_crapctc (pr_cdcooper crapepc.cdcooper%TYPE,
                       pr_nrconven crapepc.nrconven%TYPE,
                       pr_dtrefere crapepc.dtrefere%TYPE) IS
      SELECT crapctc.qtempres
            ,crapctc.dtresumo
            ,crapctc.rowid
        FROM crapctc
       WHERE crapctc.cdcooper = pr_cdcooper
         AND crapctc.nrconven = pr_nrconven
         AND crapctc.dtrefere = pr_dtrefere
         AND crapctc.cdempres = 0
         AND crapctc.cdhistor = 0;
    rw_crapctc cr_crapctc%ROWTYPE;     
                                            
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

    ------------------------------- VARIAVEIS -------------------------------
    --Variaveis do ipmf
    vr_tab_txcpmfcc  NUMBER:= 0;
    vr_tab_txrdcpmf  NUMBER:= 0;
    vr_tab_indabono  NUMBER:= 0;
    vr_tab_dtinipmf  DATE;
    vr_tab_dtfimpmf  DATE;
    vr_tab_dtiniabo  DATE;
    -- cariaveis de controle
    vr_intipdeb      INTEGER;
    vr_ant_nrdconta  crapass.nrdconta%TYPE := 0;
    vr_flgestou      BOOLEAN               := FALSE;
    vr_nrdocmto      craplcm.nrdocmto%TYPE;
    
    vr_vlsldtot      NUMBER;
    vr_vldescto      NUMBER;

    -- Tabela de retorno LANC0001 (PRJ450 06/07/2018).
    vr_tab_retorno   lanc0001.typ_reg_retorno;
    vr_incrineg      NUMBER;
	
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- procedimento para calcular o saldo do cooperado
    PROCEDURE pc_calcula_saldo (pr_cdcooper IN craplcm.cdcooper%TYPE,
                                pr_nrdconta IN craplcm.nrdconta%TYPE,
                                pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                                -- out
                                pr_vlsldtot OUT NUMBER,
                                pr_cdcritic OUT INTEGER,
                                pr_dscritic OUT VARCHAR2) IS
    
    ----------- variavei ---------
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_vlsldtot   NUMBER;
      vr_cdhistor   craphis.cdhistor%TYPE;
      vr_inhistor   craphis.inhistor%TYPE := 0;
      vr_indoipmf   craphis.indoipmf%TYPE := 0;
    
    BEGIN
      -- Buscar saldo co cooperado
      OPEN cr_crapsld (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapsld INTO rw_crapsld;
      
      -- verificar se localizou o saldo
      IF cr_crapsld%NOTFOUND THEN
        CLOSE cr_crapsld;
        -- gerar critica
        vr_cdcritic := 10;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                       ' Conta: '||gene0002.fn_mask_conta(pr_nrdconta);
        RAISE vr_exc_saida;
        
      ELSE
        CLOSE cr_crapsld;
      END IF;
      
      -- Buscar dados associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      
      -- verificar se localizou o saldo
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        -- gerar critica
        vr_cdcritic := 251;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                       ' Conta: '||gene0002.fn_mask_conta(pr_nrdconta);
        RAISE vr_exc_saida;
        
      ELSE
        CLOSE cr_crapass;
      END IF;
      
      -- somar valores do saldo
      vr_vlsldtot := nvl(rw_crapsld.vlsddisp,0) +
                     nvl(rw_crapass.vllimcre,0) - nvl(rw_crapsld.vlipmfap,0) -
                     nvl(rw_crapsld.vlipmfpg,0);
               
      -- listar lancamentos do cooperado     
      FOR rw_craplcm IN cr_craplcm (pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_dtmvtolt => pr_dtmvtolt) LOOP 
        -- verificar controle hist                             
        IF vr_cdhistor <> rw_craplcm.cdhistor THEN
          -- Buscar dados do historico
          OPEN cr_craphis (pr_cdcooper => pr_cdcooper,
                           pr_cdhistor => rw_craplcm.cdhistor); 
          FETCH cr_craphis INTO rw_craphis;
          
          IF cr_craphis%NOTFOUND THEN
            -- se nao localizar o historico, gerar log
            CLOSE cr_craphis;
            vr_cdcritic := 83;
            vr_dscritic := to_char(rw_craplcm.cdhistor,'99900')||
                           gene0001.fn_busca_critica(vr_cdcritic);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
            
            vr_cdhistor := rw_craplcm.cdhistor;
            vr_inhistor := 0;
            vr_indoipmf := 0;
            vr_cdcritic := 0;
            
          ELSE
            CLOSE cr_craphis;
            -- armazenar valores
            vr_cdhistor := rw_craphis.cdhistor;
            vr_inhistor := rw_craphis.inhistor;
            vr_indoipmf := rw_craphis.indoipmf;

            IF vr_tab_indabono = 0 AND  
               rw_craphis.cdhistor IN (0114,0127,0160,0177)THEN 
              vr_indoipmf := 1;
            END IF;               
          END IF; -- Fim IF cr_craphis%NOTFOUND
        END IF; -- Fim IF vr_cdhistor <> rw_craplcm.cdhistor
        
        IF vr_tab_indabono  = 0                   AND
           vr_tab_dtiniabo <= rw_craplcm.dtrefere AND
           rw_craplcm.cdhistor IN(186,187,498,500)THEN
          --descontar taxa 
          vr_vlsldtot := nvl(vr_vlsldtot,0) - (TRUNC((nvl(rw_craplcm.vllanmto,0) 
                                                     * nvl(vr_tab_txcpmfcc,0)),2));
        END IF;
        
        -- verificar funcao do hist.
        IF vr_inhistor IN (1) THEN
          /* Inicia tratamento CPMF */
          IF vr_indoipmf = 2 THEN
            -- incluir taxa
            vr_vlsldtot := nvl(vr_vlsldtot,0) + (TRUNC(nvl(rw_craplcm.vllanmto,0) 
                                                          *(1 + nvl(vr_tab_txcpmfcc,0) ),2));
          ELSE
            /* Termina tratamento CPMF */
            vr_vlsldtot := nvl(vr_vlsldtot,0) + nvl(rw_craplcm.vllanmto,0);
          END IF;           
        END IF;
        
        IF vr_inhistor IN (11) THEN

          /* Inicia tratamento CPMF */
          IF vr_indoipmf = 2  THEN
            --descontar taxa 
            vr_vlsldtot := nvl(vr_vlsldtot,0) - (TRUNC((nvl(rw_craplcm.vllanmto,0) *
                                                        nvl(vr_tab_txcpmfcc,0)),2));
          ELSE/* Termina tratamento CPMF */
            vr_vlsldtot := nvl(vr_vlsldtot,0) + nvl(rw_craplcm.vllanmto,0);
          END IF;
        END IF;    
                                
        
      END LOOP; /* Fim loop craplcm */           
      
      pr_vlsldtot := nvl(vr_vlsldtot,0);
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao buscar saldo da conta '||
                       gene0002.fn_mask_conta(pr_nrdconta)||' :'||SQLERRM;  
        
    END pc_calcula_saldo;

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
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
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    
    /* trecho nao necessario devido as datas serem antigas
    IF  glb_dtmvtolt > 01/22/1997 AND glb_dtmvtolt < 01/24/1999 THEN
      ASSIGN aux_cfrvipmf = glb_cfrvipmf
             aux_vlalipmf = glb_vlalipmf
    */
    
    -- Procedimento padrão de busca de informações de CPMF
    gene0005.pc_busca_cpmf(pr_cdcooper  => pr_cdcooper
                          ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                          ,pr_dtinipmf  => vr_tab_dtinipmf
                          ,pr_dtfimpmf  => vr_tab_dtfimpmf
                          ,pr_txcpmfcc  => vr_tab_txcpmfcc
                          ,pr_txrdcpmf  => vr_tab_txrdcpmf
                          ,pr_indabono  => vr_tab_indabono
                          ,pr_dtiniabo  => vr_tab_dtiniabo
                          ,pr_cdcritic  => vr_cdcritic
                          ,pr_dscritic  => vr_dscritic);
    -- Se retornou erro
    IF vr_dscritic IS NOT NULL THEN
      -- Encerra execução
      RAISE vr_exc_saida;
    END IF;
    
    -- buscar convenio integrados por empresa da cooperativa
    FOR rw_crapepc IN cr_crapepc(pr_cdcooper => pr_cdcooper) LOOP
      /* au_intipdeb = 0 = segundo debito referente folha
                      1 = primeiro debito referente conta
                      2 = segundo debito referente conta */
      -- Definir tipo de debito                
      IF rw_crapepc.incvfol1 = 2  AND  rw_crapepc.incvfol2 = 1 AND
         rw_crapepc.dtcvfol2 = rw_crapdat.dtmvtolt THEN
        vr_intipdeb := 0; -- segundo debito referente folha
      ELSIF rw_crapepc.incvcta1  = 1  AND  rw_crapepc.dtcvcta1 > rw_crapdat.dtmvtoan AND
           rw_crapepc.dtcvcta1 <= rw_crapdat.dtmvtolt THEN
        vr_intipdeb := 1; -- primeiro debito referente conta
      ELSIF rw_crapepc.incvcta1 = 2  AND  rw_crapepc.incvcta2 = 1  AND
           rw_crapepc.dtcvcta2 = rw_crapdat.dtmvtolt THEN
        vr_intipdeb := 2; -- segundo debito referente conta
      ELSE
        continue;
      END IF;     
      
      -- Inciar variaveis de controle
      vr_ant_nrdconta := 0;
      vr_flgestou     := FALSE;
      
      -- buscar convenio da empresa
      OPEN cr_crapcnv (pr_cdcooper => pr_cdcooper,
                       pr_nrconven => rw_crapepc.nrconven);
      FETCH cr_crapcnv INTO rw_crapcnv;
      -- se nao localizou convenio abortar programa
      IF cr_crapcnv%NOTFOUND THEN
        CLOSE cr_crapcnv;
        vr_cdcritic := 563;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                       to_char(rw_crapepc.nrconven,'fm999999000');
        RAISE vr_exc_saida;
        
      ELSE
        CLOSE cr_crapcnv;  
      END IF;
      
      -- se for credito não processa
      IF rw_crapcnv.indebcre = 'C' THEN
        -- buscar proximo
        continue;
      END IF; 
      
      -- listar avisos de debito
      FOR rw_crapavs IN cr_crapavs (pr_cdcooper => pr_cdcooper,
                                    pr_nrconven => rw_crapepc.nrconven,
                                    pr_cdempres => rw_crapepc.cdempres,
                                    pr_dtrefere => rw_crapepc.dtrefere) LOOP
        
        IF  vr_intipdeb = 0 THEN -- segundo debito referente folha
          IF rw_crapavs.tpdaviso <> 1 THEN -- e nao for desconto em folha
            continue;
          END IF;
        ELSIF rw_crapavs.tpdaviso <> 3 THEN
          continue;
        END IF; 
        
        /* Verifica se deve cobrar limitado ao saldo */
        IF rw_crapcnv.inlimsld = 1  THEN
          IF vr_ant_nrdconta <> rw_crapavs.nrdconta THEN
            vr_ant_nrdconta := rw_crapavs.nrdconta;
            
            -- procedimento para calcular o saldo do cooperado
            pc_calcula_saldo (pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => rw_crapavs.nrdconta,
                              pr_dtmvtolt => rw_crapdat.dtmvtolt,
                              -- out
                              pr_vlsldtot => vr_vlsldtot,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
                              
            -- verificar se retornou critica                  
            IF nvl(vr_cdcritic,0) <> 0 OR
               trim(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida; 
            END IF;    
          END IF;              
        ELSE
          vr_vlsldtot := 999999999;   
        END IF; -- Fim if rw_crapcnv.inlimsld
        
        /* Calcula o valor dos descontos */
        IF TRUNC((rw_crapavs.vllanmto - rw_crapavs.vldebito) *
                 (1 + vr_tab_txcpmfcc),2) <= vr_vlsldtot THEN
          vr_vldescto := rw_crapavs.vllanmto - rw_crapavs.vldebito;
        ELSE
          IF vr_vlsldtot > 0 THEN
            vr_vldescto := TRUNC(vr_vlsldtot * vr_tab_txrdcpmf,2);
          ELSE
            vr_vldescto := 0;
          END IF;     

          vr_flgestou := TRUE;
        END IF;
        
        /* tratar para descontar aviso apenas integral  Ex. associacao */
        IF vr_vldescto <> rw_crapavs.vllanmto  AND rw_crapcnv.indescto = 1 THEN
          vr_vldescto := 0;
        END IF;  
        
        IF vr_vldescto > 0 THEN
          -- localizar lote
          OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                           pr_dtmvtolt => rw_crapdat.dtmvtolt);
          FETCH cr_craplot INTO rw_craplot;
          IF cr_craplot%NOTFOUND THEN
            CLOSE cr_craplot;
            
            -- se nao localizou, criar o lote
            BEGIN
              INSERT INTO craplot
                         (craplot.dtmvtolt,
                          craplot.cdagenci,
                          craplot.cdbccxlt,
                          craplot.nrdolote,
                          craplot.tplotmov,
                          craplot.nrseqdig,
                          craplot.vlcompcr,
                          craplot.vlinfocr,
                          craplot.cdhistor,
                          craplot.cdoperad,
                          craplot.dtmvtopg,
                          craplot.cdcooper)
                   VALUES( rw_crapdat.dtmvtolt --craplot.dtmvtolt = 
                          ,1            --craplot.cdagenci = 
                          ,100          --craplot.cdbccxlt = 
                          ,8462         --craplot.nrdolote = 
                          ,1            --craplot.tplotmov = 
                          ,0            --craplot.nrseqdig = 
                          ,0            --craplot.vlcompcr = 
                          ,0            --craplot.vlinfocr = 
                          ,0            --craplot.cdhistor = 
                          ,'1'          --craplot.cdoperad = 
                          ,NULL         --craplot.dtmvtopg = 
                          ,pr_cdcooper  --craplot.cdcooper = 
                          )
              RETURNING craplot.ROWID,
                        craplot.cdagenci,
                        craplot.cdbccxlt,
                        craplot.nrdolote
                   INTO rw_craplot.ROWID,
                        rw_craplot.cdagenci,
                        rw_craplot.cdbccxlt,
                        rw_craplot.nrdolote;   
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar lote 8462: '||SQLERRM;
                RAISE vr_exc_saida;              
            END;
            
          ELSE
            CLOSE cr_craplot;
          END IF;
          
          vr_nrdocmto := rw_crapavs.nrdocmto;
          -- verificar se nrdocmto ja existe
          LOOP
            OPEN cr_craplcm_2 (pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt,
                               pr_cdagenci => rw_craplot.cdagenci,
                               pr_cdbccxlt => rw_craplot.cdbccxlt,
                               pr_nrdolote => rw_craplot.nrdolote,
                               pr_nrdconta => rw_crapavs.nrdconta,
                               pr_nrdocmto => vr_nrdocmto);
            FETCH cr_craplcm_2 INTO rw_craplcm_2;
            
            IF cr_craplcm_2%FOUND THEN
              CLOSE cr_craplcm_2;
              -- se localizou, gerar novo numero
              vr_nrdocmto := (vr_nrdocmto + 1000000);
            ELSE
              CLOSE cr_craplcm_2;
              -- se ainda nao existe o numero, sair do loop
              EXIT;
            END IF;
          END LOOP;
          
          -- atualizar o lote
          BEGIN
            UPDATE craplot
               SET craplot.nrseqdig = craplot.nrseqdig + 1,
                   craplot.qtcompln = craplot.qtcompln + 1,
                   craplot.qtinfoln = craplot.qtcompln + 1,
                   craplot.vlcompdb = craplot.vlcompdb + vr_vldescto,
                   craplot.vlinfodb = craplot.vlcompdb + vr_vldescto
             WHERE craplot.rowid = rw_craplot.rowid
             RETURNING craplot.nrseqdig
                  INTO rw_craplot.nrseqdig;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar lote 8462: '||SQLERRM;
              RAISE vr_exc_saida;    
          END;
          
          -- PRJ450 - 06/07/2018.
          lanc0001.pc_gerar_lancamento_conta (pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            , pr_cdagenci => rw_craplot.cdagenci
                                            , pr_cdbccxlt => rw_craplot.cdbccxlt
                                            , pr_nrdolote => rw_craplot.nrdolote
                                            , pr_nrdconta => rw_crapavs.nrdconta
                                            , pr_nrdocmto => vr_nrdocmto 
                                            , pr_cdhistor => rw_crapavs.cdhistor   
                                            , pr_nrseqdig => rw_craplot.nrseqdig
                                            , pr_vllanmto => vr_vldescto
                                            , pr_nrdctabb => rw_crapavs.nrdconta
                                            , pr_cdpesqbb => ' '
                                            --, pr_vldoipmf IN  craplcm.vldoipmf%TYPE default 0
                                            --, pr_nrautdoc IN  craplcm.nrautdoc%TYPE default 0
                                            --, pr_nrsequni IN  craplcm.nrsequni%TYPE default 0
                                            --, pr_cdbanchq => lt_d_nrbanori
                                            --, pr_cdcmpchq => lt_d_cdcmpori
                                            --, pr_cdagechq => lt_d_nrageori
                                            --, pr_nrctachq => lt_d_nrctarem
                                            --, pr_nrlotchq IN  craplcm.nrlotchq%TYPE default 0
                                            --, pr_sqlotchq => lt_d_nrsequen
                                            --, pr_dtrefere => rw_craprda.dtmvtolt
                                            --, pr_hrtransa => vr_hrtransa
                                            --, pr_cdoperad IN  craplcm.cdoperad%TYPE default ' '
                                            --, pr_dsidenti IN  craplcm.dsidenti%TYPE default ' '
                                            , pr_cdcooper => pr_cdcooper
                                            , pr_nrdctitg => to_char(rw_crapavs.nrdconta,'00000000')
                                            --, pr_dscedent IN  craplcm.dscedent%TYPE default ' '
                                            --, pr_cdcoptfn IN  craplcm.cdcoptfn%TYPE default 0
                                            --, pr_cdagetfn IN  craplcm.cdagetfn%TYPE default 0
                                            --, pr_nrterfin IN  craplcm.nrterfin%TYPE default 0
                                            --, pr_nrparepr IN  craplcm.nrparepr%TYPE default 0
                                            --, pr_nrseqava IN  craplcm.nrseqava%TYPE default 0
                                            --, pr_nraplica IN  craplcm.nraplica%TYPE default 0
                                            --, pr_cdorigem IN  craplcm.cdorigem%TYPE default 0
                                            --, pr_idlautom IN  craplcm.idlautom%TYPE default 0
                                            -------------------------------------------------
                                            -- Dados do lote (Opcional)
                                            -------------------------------------------------
                                            --, pr_inprolot  => 1 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                            --, pr_tplotmov  => 1
                                            , pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                            , pr_incrineg  => vr_incrineg      -- OUT Indicador de crítica de negócio
                                            , pr_cdcritic  => vr_cdcritic      -- OUT
                                            , pr_dscritic  => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)
					
          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
             -- Se vr_incrineg = 0, se trata de um erro de Banco de Dados e deve abortar a sua execução
             IF vr_incrineg = 0 THEN  
                vr_dscritic := 'Problemas ao criar lancamento:'||vr_dscritic;
              RAISE vr_exc_saida;    
             ELSE
                -- Neste caso se trata de uma crítica de Negócio e o lançamento não pode ser efetuado
                -- Para CREDITO: Utilizar o CONTINUE ou gerar uma mensagem de retorno(se for chamado por uma tela); 
                -- Para DEBITO: Será necessário identificar se a rotina ignora esta inconsistência(CONTINUE) ou se devemos tomar alguma ação(efetuar algum cancelamento por exemplo, gerar mensagem de retorno ou abortar o programa)
                --CONTINUE;  
                
                tela_lautom.pc_cria_lanc_futuro(pr_cdcooper => pr_cdcooper, 
                                                pr_nrdconta => rw_crapavs.nrdconta,
                                                pr_nrdctitg => gene0002.fn_mask(rw_crapavs.nrdconta,'99999999'), 
                                                pr_cdagenci => rw_craplot.cdagenci, 
                                                pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                                                pr_cdhistor => rw_crapavs.cdhistor,  
                                                pr_vllanaut => vr_vldescto,  
                                                pr_nrctremp => 0, 
                                                pr_dsorigem => 'BLQPREJU', 
                                                pr_dscritic => vr_dscritic);
                IF vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_saida;
                end if;
                
             END IF;  
          END IF;		  
		  
  
        END IF; -- Fim IF vr_vldescto > 0  
        
        vr_vlsldtot := vr_vlsldtot - TRUNC(vr_vldescto * (1 + vr_tab_txcpmfcc),2);
          
        -- atualizar informações da crapavs
        rw_crapavs.vldebito := rw_crapavs.vldebito +  vr_vldescto;
          
        IF vr_vldescto > 0 THEN
           -- verificar se todo o valor foi debitado
           IF rw_crapavs.vldebito = rw_crapavs.vllanmto THEN
             rw_crapavs.insitavs := 1;
             rw_crapavs.vlestdif := 0;
             rw_crapavs.flgproce := 1;
           ELSE
             rw_crapavs.insitavs := 0;
             rw_crapavs.vlestdif := rw_crapavs.vldebito - rw_crapavs.vllanmto;
           END IF;  
        ELSE
           rw_crapavs.vlestdif := rw_crapavs.vldebito - rw_crapavs.vllanmto;
        END IF;   
          
        IF vr_intipdeb IN (0       /* segundo debito da folha */
                          ,2)THEN  /* segundo debito em conta */
           rw_crapavs.flgproce := 1;
        END IF;   
          
        -- atualizar as informações na tabela
        BEGIN
          UPDATE crapavs
             SET crapavs.vldebito = rw_crapavs.vldebito,
                 crapavs.insitavs = rw_crapavs.insitavs,
                 crapavs.vlestdif = rw_crapavs.vlestdif,
                 crapavs.flgproce = rw_crapavs.flgproce
           WHERE crapavs.rowid = rw_crapavs.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar aviso de debito rowid '||rw_crapavs.rowid||' : '||SQLERRM;
            RAISE vr_exc_saida;   
        END;
                 
      END LOOP; -- Fim loop crapavs  
      
      -- atualizar informações da crapepc
      IF vr_intipdeb = 0 THEN /* Folha */
        rw_crapepc.incvfol2 := 2;
      ELSIF vr_intipdeb = 1 THEN /* 1 debito em conta */
        
        rw_crapepc.dtcvcta1 := rw_crapdat.dtmvtolt;
        rw_crapepc.incvcta1 := 2;
        
        IF vr_flgestou THEN
          rw_crapepc.incvcta2 := 1;
          rw_crapepc.dtcvcta2 := rw_crapdat.dtmvtopr;
        END IF;
      ELSE
        rw_crapepc.incvcta2 := 2;
      END IF;  
      
      -- atualizar tabela
      BEGIN
        UPDATE crapepc
           SET crapepc.incvfol2 = rw_crapepc.incvfol2,
               crapepc.dtcvcta1 = rw_crapepc.dtcvcta1,
               crapepc.incvcta1 = rw_crapepc.incvcta1,
               crapepc.incvcta2 = rw_crapepc.incvcta2,
               crapepc.dtcvcta2 = rw_crapepc.dtcvcta2
         WHERE crapepc.rowid = rw_crapepc.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapepc rowid '||rw_crapepc.rowid||' : '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      OPEN cr_crapctc (pr_cdcooper => pr_cdcooper,
                       pr_nrconven => rw_crapepc.nrconven,
                       pr_dtrefere => rw_crapepc.dtrefere);
      FETCH cr_crapctc INTO rw_crapctc;
      
      -- se nao localizou
      IF cr_crapctc%NOTFOUND THEN
        CLOSE cr_crapctc;
        vr_cdcritic := 563;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                       ' Convenio '||to_char(rw_crapcnv.nrconven,'000');
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapctc;
      END IF;
      
      IF rw_crapepc.dtcvcta2 <> rw_crapdat.dtmvtopr OR
         rw_crapepc.dtcvcta2 IS NULL THEN -- oracle não trata nulo como diferente
        rw_crapctc.qtempres := rw_crapctc.qtempres - 1;
      END IF;  
      
      -- se ja processou todas empresas
      IF rw_crapctc.qtempres = 0 THEN
        rw_crapctc.dtresumo := rw_crapdat.dtmvtolt;
      END IF;
      
      -- efetivar na tabela as alterações
      BEGIN
        UPDATE crapctc
           SET crapctc.qtempres = rw_crapctc.qtempres,
               crapctc.dtresumo = rw_crapctc.dtresumo
         WHERE crapctc.rowid = rw_crapctc.rowid;
         
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapepc rowid '||rw_crapepc.rowid||' : '||SQLERRM;
          RAISE vr_exc_saida;
      END;    
      
                          
    END LOOP; -- Fim loop crapepc

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

  END pc_crps196;
/

