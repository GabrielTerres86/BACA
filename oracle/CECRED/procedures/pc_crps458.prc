CREATE OR REPLACE PROCEDURE cecred.pc_crps458 (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Coop conectada
                                              ,pr_flgresta IN PLS_INTEGER            --> Indicador para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  /* ............................................................................
   Programa: PC_CRPS458 (Antigo Fontes/crps458.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes     
   Data    : Outubro/2005                    Ultima atualizacao: 16/11/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 001.
               Lancar tarifa cheques baixo valor                            

   Alteracoes: 10/12/2005 - Atualizar craplcm.nrdctitg (Magui). 
   
               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               26/10/2006 - Alterado para tratar Saques e Transferencias do 
                            cartao BB (Diego).
               
               05/01/2007 - Gerar lancamento tarifa apenas se taxa tarifa       
                            cadastrada(Mirtes)
                             
               22/03/2007 - Tratamento para historicos 313 e 340 (David).
               
               15/07/2010 - Incluir historicos 524 e 572 (Guilherme).
               
               16/05/2013 - Incluso nova estrutura para buscar valor tarifa
                            utilizando b1wgen0153, retirado procedure cria_lancamento
                            na craplcm e incluso lancamento pela procedure
                            cria_lan_auto_tarifa na craplat (Daniel).
               
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
  
               05/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel).
  
               11/08/2015 - Apontar log do vr_exc_fimprg para o proc_message (Lucas Ranghetti #306645)

               26/08/2015 - Alterado o parametro pr_cdpesqbb da procedure 
                            TARI0001.pc_cria_lan_auto_tarifa (Jean Michel).

               03/09/2015 - Incluido tratamento para cobranca de tarifas de
                            saques, Prj. Tarifas - 218 (Jean Michel). 
							
		       05/04/2016 - Inclusao de novos parametros pc_verifica_tarifa_operacao					            
							Prj. 218 - Tarifas (Jean Michel).

		       09/06/2016 - Chamar a procedure 'pc_verifica_tarifacao' mesmo 
			                quando vr_vltarsaq = 0 (Diego).

           16/11/2016 - #549653 Correção de tratamento de erros após a chamada da rotina 
                        pc_verifica_tarifa_operacao (Carlos)
  ............................................................................. */
  
  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Cursor genérico de calendário
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
  -- Cursor Leitura Lançamentos
  -- 50  - CHEQUE COMPENSADO BANCO DO BRASIL
  -- 56  - CHEQUE SALARIO COMPENSADO BANCO DO BRASIL
  -- 59  - CHEQUE DE TRANSFERENCIA COMPENSADO BANCO DO BRASIL
  -- 313 - CHEQUE COMPENSADO BANCOOB
  -- 340 - CHEQUE DE TRANSFERENCIA COMPENSADO BANCOOB
  -- 524 - SUA REMESSA CHEQUE COMPE CECRED
  -- 572 - SUA REMESSA CHEQUE DE TRANSFERENCIA COMPE CECRED
  -- 614 - SAQUE CARTAO BANCO DO BRASIL
  -- 668 - TRANSFERENCIA ENTRE CONTAS VIA CARTAO BB

  CURSOR cr_crablcm(pr_cdcooper IN craplcm.cdcooper%TYPE,
                    pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                    pr_vlchequb IN craplcm.vllanmto%TYPE) IS
    SELECT /*index (LCM CRAPLCM##CRAPLCM4)*/ 
           lcm.cdcooper, lcm.nrdconta
           ,( SELECT COUNT(1)  FROM craplcm lcm2
           WHERE lcm2.cdcooper = lcm.cdcooper
             AND lcm2.dtmvtolt = pr_dtmvtolt
             AND lcm2.nrdconta = lcm.nrdconta
             AND lcm2.vllanmto <= pr_vlchequb
             AND lcm2.cdhistor IN (50,56,59,313,340,524,572) ) qtd_qtcheque 
           ,( SELECT COUNT(1)  FROM craplcm lcm3
           WHERE lcm3.cdcooper = lcm.cdcooper
             AND lcm3.dtmvtolt = pr_dtmvtolt
             AND lcm3.nrdconta = lcm.nrdconta
             AND lcm3.cdhistor = 614 ) qtd_totsaque  
            ,( SELECT COUNT(1)  FROM craplcm lcm4
           WHERE lcm4.cdcooper = lcm.cdcooper
             AND lcm4.dtmvtolt = pr_dtmvtolt
             AND lcm4.nrdconta = lcm.nrdconta
             AND lcm4.cdhistor = 668 ) qtd_tottrans   
      FROM craplcm lcm
     WHERE lcm.cdcooper = pr_cdcooper
       AND lcm.dtmvtolt = pr_dtmvtolt
       AND lcm.cdhistor IN (50,56,59,313,340,524,572,614,668)        
       GROUP BY 
       lcm.cdcooper,
       lcm.nrdconta;
       
  -- Cursor Leitura Associado
  CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.inpessoa,
           crapass.nrdconta
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;  

  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS458';

  -- Rolbacks para erros, ignorar o resto do processo e rollback
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(4000);
  
  -- Tabela Temporaria
  vr_tab_erro GENE0001.typ_tab_erro;
  
  vr_vlchequb NUMBER := 0;
  vr_vltarchb NUMBER := 0;
  vr_vltarsaq NUMBER := 0;
  vr_vltrtran NUMBER := 0;
  vr_valor    NUMBER := 0;

  vr_dsconteu VARCHAR2(4000);
  
  vr_rowid    ROWID;
 
  -- Totalizadores
  vr_qtcheque NUMBER := 0;
  vr_totsaque NUMBER := 0;
  vr_tottrans NUMBER := 0;

  -- Variaveis Tarifa
  vr_cdhisest craphis.cdhistor%TYPE := 0;
  vr_dtdivulg DATE;
  vr_dtvigenc DATE;
  vr_cdfvlcop crapfco.cdfvlcop%TYPE := 0;
  vr_cdhistor craphis.cdhistor%TYPE := 0;
  vr_vltarifa crapfco.vltarifa%TYPE;
  
  vr_qtacobra INTEGER := 0;
  vr_fliseope INTEGER := 0;

  -- Valores Tarifa
  vr_cdbattar VARCHAR2(10);
    
  -- Listas utilizadas para carga de tarifas
  vr_lstarifa VARCHAR2(2000);
  
  -- Tabela temporaria para as tarifas
  TYPE typ_reg_tarifa IS
   RECORD(cdhistor crapfvl.cdhistor%TYPE
         ,cdfvlcop crapfvl.cdfaixav%TYPE
         ,vltarifa crapfco.vltarifa%TYPE);
  TYPE typ_tab_tarifa IS
    TABLE OF typ_reg_tarifa
      INDEX BY VARCHAR2(10);
      
  -- Vetor para armazenar os percentuais de risco
  vr_tab_tarifa typ_tab_tarifa;
    
BEGIN

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => NULL);
                              
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
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  -- Se não encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE BTCH0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic:= 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
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
  
  -- Processo de carga tarifas para Pl/Table
  vr_lstarifa := 'CHQBAIXOPJ;' || -- Emissão de Cheque de Baixo Valor PJ
                 'SAQCRTBBPF;' || -- Saque Cartão BB PF
                 'SAQCRTBBPJ;' || -- Saque Cartão BB PJ
                 'TRANSFBBPJ;' || -- Transferencia Cartão BB PJ
                 'TRANSFBBPF';    -- Transferencia Cartão BB PF
                               
  -- Popula a PL/TABLE de tarifas
  FOR ind IN 1..5 LOOP
     
    -- Inicializa as variaveis
    vr_cdhistor := 0;      
    vr_cdfvlcop := 0;
    vr_vltarifa := 0;
         
    -- Codigo da Tarifa
    vr_cdbattar := gene0002.fn_busca_entrada(ind,vr_lstarifa,';');
         
    -- Busca valor da tarifa
    TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                        ,pr_cdbattar => vr_cdbattar
                                        ,pr_vllanmto => 1
                                        ,pr_cdprogra => vr_cdprogra
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_cdhisest => vr_cdhisest
                                        ,pr_vltarifa => vr_vltarifa
                                        ,pr_dtdivulg => vr_dtdivulg
                                        ,pr_dtvigenc => vr_dtvigenc
                                        ,pr_cdfvlcop => vr_cdfvlcop
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_tab_erro => vr_tab_erro);
                                                      
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Se possui erro no vetor
      IF vr_tab_erro.Count() > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
      END IF;
      -- Envio centralizado de log de erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic || ' - ' || vr_cdbattar);
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
    END IF;
     
    -- Armazena Valores na PL/TABLE
    vr_tab_tarifa(vr_cdbattar).cdhistor := NVl(vr_cdhistor,0);
    vr_tab_tarifa(vr_cdbattar).cdfvlcop := NVL(vr_cdfvlcop,0);
    vr_tab_tarifa(vr_cdbattar).vltarifa := NVL(vr_vltarifa,0);
     
  END LOOP;
  
  -- Porcedure para Buscar Valor Limite para Cobranca de Tarifa Cheque Inferior
  TARI0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper,
                                         pr_cdbattar => 'VLCHQBAIXO',
                                         pr_dsconteu => vr_dsconteu,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic,
                                         pr_des_erro => vr_des_erro,
                                         pr_tab_erro => vr_tab_erro);
                                         
  -- Verifica se Houve Erro no Retorno
  IF vr_des_erro = 'NOK' THEN
    -- Envio Centralizado de Log de Erro
    IF vr_tab_erro.count > 0 THEN

      -- Recebe Fescrição do Erro
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic || ' - VLCHQBAIXO');
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
    END IF;
  END IF;
  
  -- Valor Limite Cheque
  vr_vlchequb := vr_dsconteu; 
       
    
  -- Verifica se possui valores de tarifa cadastrado, caso não tenha finaliza execução                                       
  IF (vr_tab_tarifa('CHQBAIXOPJ').vltarifa = 0 OR vr_vlchequb = 0)  AND
      vr_tab_tarifa('SAQCRTBBPF').vltarifa = 0 AND vr_tab_tarifa('SAQCRTBBPJ').vltarifa = 0 AND  
      vr_tab_tarifa('TRANSFBBPF').vltarifa = 0 AND vr_tab_tarifa('TRANSFBBPJ').vltarifa = 0 THEN
       
    vr_cdcritic:= 0;
    vr_dscritic:= 'Valor das Tarifas zerado. Execucao Finalizada.';
    RAISE vr_exc_fimprg;
  END IF;
    
  FOR rw_crablcm IN cr_crablcm( pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_vlchequb => vr_vlchequb) LOOP
                     
    vr_qtcheque := rw_crablcm.qtd_qtcheque;
    vr_totsaque := rw_crablcm.qtd_totsaque; 
    vr_tottrans := rw_crablcm.qtd_tottrans;   
    
    --Selecionar Dados Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => rw_crablcm.nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    --Se nao encontrou associado
    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic:= 9;
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                    gene0002.fn_mask(rw_crablcm.nrdconta,'zzzz.zzz.9');
      --Fechar Cursor
      CLOSE cr_crapass;
      
      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic);
                                                    
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := ' ';
    
      --Proximo Registro
      CONTINUE;
    END IF;
    
    --Fechar Cursor
    CLOSE cr_crapass;
    
    -- Pessoa Fisica 
    IF rw_crapass.inpessoa = 1 THEN
      vr_vltarchb := 0; -- Zera Valor Tarifa Cheque Abaixo (Conforme Progress)
      vr_vltarsaq := vr_tab_tarifa('SAQCRTBBPF').vltarifa;
      vr_vltrtran := vr_tab_tarifa('TRANSFBBPF').vltarifa;
    ELSE
      -- Pessoa Juridica
      vr_vltarchb := vr_tab_tarifa('CHQBAIXOPJ').vltarifa;
      vr_vltarsaq := vr_tab_tarifa('SAQCRTBBPJ').vltarifa;
      vr_vltrtran := vr_tab_tarifa('TRANSFBBPJ').vltarifa;
    END IF;
    
    -- Verificação se possui tarifas a cobrar. 
    IF (vr_qtcheque > 0 AND vr_vltarchb > 0)  OR
       (vr_totsaque > 0)  OR
       (vr_tottrans > 0 AND vr_vltrtran > 0) THEN
       
      -- Cobrança Tarifa Cheque Abaixo (Somente Pessoa Juridica)
      IF (vr_qtcheque > 0 AND vr_vltarchb > 0) THEN 
 
        -- Valor a ser Tarifado
        vr_valor := vr_qtcheque * vr_vltarchb;

        -- Pessoa Juridica
        vr_cdhistor := vr_tab_tarifa('CHQBAIXOPJ').cdhistor;
        vr_cdfvlcop := vr_tab_tarifa('CHQBAIXOPJ').cdfvlcop;
        
        -- Criar Lançamento automatico tarifa
        TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                        , pr_nrdconta     => rw_crablcm.nrdconta
                                        , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                        , pr_cdhistor     => vr_cdhistor
                                        , pr_vllanaut     => vr_valor
                                        , pr_cdoperad     => '1'
                                        , pr_cdagenci     => 1
                                        , pr_cdbccxlt     => 100
                                        , pr_nrdolote     => 10107
                                        , pr_tpdolote     => 1
                                        , pr_nrdocmto     => 0
                                        , pr_nrdctabb     => rw_crablcm.nrdconta
                                        , pr_nrdctitg     => gene0002.fn_mask(rw_crablcm.nrdconta,'99999999')
                                        , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')
                                        , pr_cdbanchq     => 0
                                        , pr_cdagechq     => 0
                                        , pr_nrctachq     => 0
                                        , pr_flgaviso     => FALSE
                                        , pr_tpdaviso     => 0
                                        , pr_cdfvlcop     => vr_cdfvlcop
                                        , pr_inproces     => rw_crapdat.inproces
                                        , pr_rowid_craplat=> vr_rowid
                                        , pr_tab_erro     => vr_tab_erro
                                        , pr_cdcritic     => vr_cdcritic
                                        , pr_dscritic     => vr_dscritic);
        -- Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui erro no vetor
          IF vr_tab_erro.Count > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao criar Lancamento tarifa.';
          END IF;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '||
                                                        gene0002.fn_mask_conta(rw_crablcm.nrdconta)||'- '
                                                     || vr_dscritic );
          -- Efetua Limpeza das variaveis de critica
          vr_cdcritic := 0;
          vr_dscritic := NULL;                                           
        END IF;
        
      END IF; -- Final Cobrança Tarifa Cheque Abaixo

      -- Cobrança Tarifa Saque Cartão
      IF vr_totsaque > 0 THEN

        FOR vr_contador IN 1..vr_totsaque LOOP
          TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => pr_cdcooper
                                              ,pr_cdoperad => '1'
                                              ,pr_cdagenci => 1
                                              ,pr_cdbccxlt => 100
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_cdprogra => 'CRPS458'
                                              ,pr_idorigem => 4
                                              ,pr_nrdconta => rw_crablcm.nrdconta
                                              ,pr_tipotari => 1
                                              ,pr_tipostaa => 0
                                              ,pr_qtoperac => 0
                                              ,pr_qtacobra => vr_qtacobra
                                              ,pr_fliseope => vr_fliseope
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);
          
          -- Se ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||
                                                          gene0002.fn_mask_conta(rw_crablcm.nrdconta)||'- '
                                                       || vr_dscritic );
            -- Efetua Limpeza das variaveis de critica
            vr_cdcritic := 0;
            vr_dscritic := NULL;                                           
          END IF;
        END LOOP;   
                             
      END IF; -- Cobrança Tarifa Saque Cartão
      
      IF vr_tottrans > 0 AND vr_vltrtran > 0 THEN
        
        -- Valor a ser Tarifado
        vr_valor := vr_tottrans * vr_vltrtran;
        
        --Pessoa Fisica
        IF rw_crapass.inpessoa = 1 THEN
          vr_cdhistor := vr_tab_tarifa('TRANSFBBPF').cdhistor;
          vr_cdfvlcop := vr_tab_tarifa('TRANSFBBPF').cdfvlcop;
        ELSE
        -- Pessoa Juridica
          vr_cdhistor := vr_tab_tarifa('TRANSFBBPJ').cdhistor;
          vr_cdfvlcop := vr_tab_tarifa('TRANSFBBPJ').cdfvlcop;
        END IF;
        
        -- Criar Lançamento Automatico Tarifa
        TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                        , pr_nrdconta     => rw_crablcm.nrdconta
                                        , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                        , pr_cdhistor     => vr_cdhistor
                                        , pr_vllanaut     => vr_valor
                                        , pr_cdoperad     => '1'
                                        , pr_cdagenci     => 1
                                        , pr_cdbccxlt     => 100
                                        , pr_nrdolote     => 10107
                                        , pr_tpdolote     => 1
                                        , pr_nrdocmto     => 0
                                        , pr_nrdctabb     => rw_crablcm.nrdconta
                                        , pr_nrdctitg     => gene0002.fn_mask(rw_crablcm.nrdconta,'99999999')
                                        , pr_cdpesqbb     => ''
                                        , pr_cdbanchq     => 0
                                        , pr_cdagechq     => 0
                                        , pr_nrctachq     => 0
                                        , pr_flgaviso     => FALSE
                                        , pr_tpdaviso     => 0
                                        , pr_cdfvlcop     => vr_cdfvlcop
                                        , pr_inproces     => rw_crapdat.inproces
                                        , pr_rowid_craplat=> vr_rowid
                                        , pr_tab_erro     => vr_tab_erro
                                        , pr_cdcritic     => vr_cdcritic
                                        , pr_dscritic     => vr_dscritic
                                        );
        -- Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui erro no vetor
          IF vr_tab_erro.Count > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
          END IF;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '||
                                                        gene0002.fn_mask_conta(rw_crablcm.nrdconta)||'- '
                                                     || vr_dscritic );
          -- Efetua Limpeza das variaveis de critica
          vr_cdcritic := 0;
          vr_dscritic := NULL;                                           
        END IF;
        
      END IF;                   
         
    END IF;   
    
  END LOOP; -- Fim Leitura Associados

  -- Processo OK, devemos chamar a fimprg
  BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informacoes no banco de dados
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_fimprg THEN

    -- Se retornou apenas o codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Busca Descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Se foi gerado critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

      -- Envio Centralizado de Log de Erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- ERRO TRATATO
                                 pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE'),
                                 pr_des_log      => to_char(sysdate, 'hh24:mi:ss') || ' -' || 
                                                    vr_cdprogra || ' --> ' || vr_dscritic);
                                 

    END IF;

    -- Chamos o pc_valida_fimprg para encerrar o processo sem parar a cadeia
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salva informações no Banco de Dados
   COMMIT;
      
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END pc_crps458;
/
