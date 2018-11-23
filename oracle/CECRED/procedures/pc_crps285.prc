CREATE OR REPLACE PROCEDURE CECRED.pc_crps285(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Coop conectada
                                      ,pr_flgresta IN PLS_INTEGER            --> Indicador para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  /* ............................................................................
   Programa: PC_CRPS285 (Antigo Fontes/crps285.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/2000.                     Ultima atualizacao: 25/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de tarifas Cheque Admin, Debito Conta.
                
   Alteracoes: 24/05/2002 - Alterado para tratar o historico 103 (DOC D).
                            Liberado a partir de 01/06/2002 (Edson).

               25/10/2002 - Alterado para tratar historicos 555 e 503 (TEDs)
                            a partir de 24/10/2002 (Deborah).

               01/11/2002 - Tratar tarifa de pre-deposito (Deborah).

               20/12/2002 - Tratar tarifa de cheque administrativo (Deborah).
               
               03/02/2003 - Acrescentar 2 digitos no PreDeposito (Ze Eduardo)
               
              31/03/2003 - Incluir o historico 153 da Comp da Concredi(Deborah)  
              12/04/2004 - Alterado p/obter tarifas tab.VLTARIFDIV(Mirtes)

              30/06/2005 - Alimentado campo cdcooper das tabelas craplot e 
                           craplcm (Diego).

              10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

              16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.  
              
              09/06/2008 - Incluído o mecanismo de pesquisa no "for each" na 
                           tabela CRAPHIS para buscar primeiro pela chave de
                           acesso (craphis.cdcooper = glb_cdcooper). 
                           - Kbase IT Solutions - Paulo Ricardo Maciel.
                           
              11/12/2008 - Isentar tarifa para Pessoa Fisica (Diego).
               
              08/01/2010 - Acrescentar historicos 469 e 572 na variavel
                           aux_lshistor (Guilherme/Precise)

              02/03/2010 - Alterar historicos 469 para 524 (Guilherme/Precise).
              
              08/07/2011 - Nao efetuar os lancamentos de doc/ted aqui.
                           Efetuar eles na rotina 20 do caixa Online (Gabriel).
                           
              22/11/2012 - Inclusao de tratamento de registro duplicado (Diego).
              
              19/03/2013 - Ajustes do Projeto de tarifas fase 2 - Grupo de 
                           Cheque (Lucas R.).
                           
              24/07/2013 - Alterado tratamento tarifa SPB "Pre-deposito" para
                           utilizar rotinas da b1wgen0153.p (Daniel)    
                           
              21/08/2013 - Alterado parametro dtmvtolt no lancamento tarifa (Daniel).    
                           
              11/10/2013 - Incluido parametro cdprogra nas procedures da 
                           b1wgen0153 que carregam dados de tarifas (Tiago).
                           
              20/01/2014 - Incluir VALIDATE craplcm, craplot (Lucas R.)
              
              12/02/2014 - Retirado "Return" quando havia chamada da b1wgen0153
                           e não devia abortar a execucao do programa (Tiago).
  
               09/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel)
  
               25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                            tari0001.pc_cria_lan_auto_tarifa, projeto de 
                            Tarifas-218(Jean Michel)
                           
              10/07/2018 - PRJ450 - Inclusao de chamada da LANC0001 para centralizar 
                           lancamentos na CRAPLCM (Teobaldo J, AMcom)

              06/08/2018 - PJ450 - TRatamento do nao pode debitar, crítica de negócio, 
                           após chamada da rotina de geraçao de lançamento em CONTA CORRENTE
                           (Renato Cordeiro - AMcom)
                           
              03/10/2018 - PJ450 - Elimina tratamento de NÃO PODE DEBITAR. A própria rotina LANC0001
                           já verifica se pode ou não debitar e executa a exceção quando volta INCRINEG=1
                           (Renato Cordeiro - AMcom)
                       
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
  
  -- Cursor Historicos
  CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE) IS
    SELECT his.cdhistor
      FROM craphis his
     WHERE his.cdcooper = pr_cdcooper 
       AND his.indebcta = 1            
       AND his.tplotmov = 1            
       AND his.cdhistor <> 33; -- Ent.Assist. 
    
  -- Cursor Lançamentos
  CURSOR cr_crablcm(pr_cdcooper IN craplot.cdcooper%TYPE,
                    pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                    pr_cdhistor VARCHAR2) IS
    SELECT  lcm.cdhistor
           ,lcm.vllanmto
           ,lcm.nrdconta
           ,lcm.nrdocmto
           ,ROW_NUMBER () OVER (PARTITION BY lcm.nrdconta ORDER BY lcm.nrdconta) nrseq
           ,COUNT(1) OVER (PARTITION BY lcm.nrdconta ORDER BY lcm.nrdconta) qtreg 
     FROM craplcm lcm
    WHERE lcm.cdcooper = pr_cdcooper
      AND lcm.dtmvtolt = pr_dtmvtolt
      AND pr_cdhistor LIKE ('%,'||lcm.cdhistor||',%') 
    ORDER BY lcm.cdcooper
            ,lcm.nrdconta; 
  rw_crablcm cr_crablcm%ROWTYPE;  
  
  -- Cursor Leitura Associado
  CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.inpessoa,
           crapass.nrdconta
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;    
  
  --Cursor que busca as Tarifas
  CURSOR cr_craptab(pr_cdcooper IN crapope.cdcooper%TYPE) IS
    SELECT /*+ index (tab CRAPTAB##CRAPTAB1)*/ 
           dstextab 
      FROM craptab tab
     WHERE tab.cdcooper        = pr_cdcooper  AND
           upper(tab.nmsistem) = 'CRED'       AND
           upper(tab.tptabela) = 'USUARI'     AND
           tab.cdempres        = '00'         AND
           upper(tab.cdacesso) = 'VLTARIFDIV' AND
           tab.tpregist        = 1; 
  rw_craptab cr_craptab%ROWTYPE;  
  
  --Selecionar Informacoes dos lotes
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                   ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                   ,pr_cdagenci IN craplot.cdagenci%TYPE
                   ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                   ,pr_nrdolote IN craplot.nrdolote%TYPE)  IS
  SELECT lot.dtmvtolt
        ,lot.cdagenci
        ,lot.cdbccxlt
        ,lot.nrdolote
        ,NVL(lot.nrseqdig,0) nrseqdig
        ,lot.cdcooper
        ,lot.tplotmov
        ,lot.vlinfodb
        ,lot.vlcompdb
        ,lot.qtinfoln
        ,lot.qtcompln
        ,lot.rowid
    FROM craplot lot
   WHERE lot.cdcooper = pr_cdcooper
     AND lot.dtmvtolt = pr_dtmvtolt
     AND lot.cdagenci = pr_cdagenci
     AND lot.cdbccxlt = pr_cdbccxlt
     AND lot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;
  
  -- Busca numero de documento do lançamento
  CURSOR cr_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE
                   ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                   ,pr_cdagenci IN craplcm.cdagenci%TYPE
                   ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                   ,pr_nrdolote IN craplcm.nrdolote%TYPE
                   ,pr_nrdctabb IN craplcm.nrdconta%TYPE
                   ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS     
    SELECT lcm.nrdocmto
      FROM craplcm lcm
     WHERE lcm.cdcooper = pr_cdcooper      
       AND lcm.dtmvtolt = pr_dtmvtolt
       AND lcm.cdagenci = pr_cdagenci
       AND lcm.cdbccxlt = pr_cdbccxlt
       AND lcm.nrdolote = pr_nrdolote
       AND lcm.nrdctabb = pr_nrdctabb
       AND lcm.nrdocmto = pr_nrdocmto;
  rw_craplcm cr_craplcm%ROWTYPE;     
  
  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS285';

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(4000);
  
  -- Tabela Temporaria
  vr_tab_erro GENE0001.typ_tab_erro;
  
  -- Rowid de retorno lançamento de tarifa
  vr_rowid    ROWID;
 
  -- Variaveis de tarifa
  vr_cdhistor craphis.cdhistor%TYPE;
  vr_cdhisest craphis.cdhistor%TYPE;
  vr_dtdivulg DATE;
  vr_dtvigenc DATE;
  vr_cdfvlcop crapfco.cdfvlcop%TYPE;
  vr_vltarifa crapfco.vltarifa%TYPE;
  vr_dsconteu VARCHAR2(200);
  
  -- Valores utilizados para Lançamento de Tarifa
  vr_cdhistor_chqadm craphis.cdhistor%TYPE;
  vr_cdfvlcop_chqadm crapfco.cdfvlcop%TYPE;
  vr_cdhistpf craphis.cdhistor%TYPE;
  vr_cdhistpj craphis.cdhistor%TYPE;
  vr_cdfvlcpf crapfco.cdfvlcop%TYPE;
  vr_cdfvlcpj crapfco.cdfvlcop%TYPE;
  
  -- Valores Tarifa
  vr_vlchqadm NUMBER := 0;
  vr_vldebcta NUMBER := 0;
  vr_vlpredep NUMBER := 0;
  vr_vltaripf NUMBER := 0;
  vr_vltaripj NUMBER := 0;
  vr_vltardeb NUMBER := 0;
  
  vr_vlminspb NUMBER := 0;
  vr_vlpercen NUMBER := 0;
  
  -- Sequencial Lançamento CRAPLCM
  vr_nrseqdig craplot.nrseqdig%TYPE;
  
  -- Listas utilizadas para carga de historicos
  vr_lsdebcta VARCHAR2(3000);
  vr_lspredep VARCHAR2(3000);
  vr_lschqadm VARCHAR2(3000);
  vr_lista_historico VARCHAR2(4000);
  
  --Variaveis de criticas / retorno
  vr_incrineg       INTEGER;
  vr_tab_retorno    LANC0001.typ_reg_retorno;
  
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
  
  -- Tabela que contem Tarifas - Cheque administrativo - Debito C/C
  
  --Busca as tarifas
  OPEN cr_craptab(pr_cdcooper => pr_cdcooper);
                        
  FETCH cr_craptab INTO rw_craptab;
  -- Se nao encontrar
  IF cr_craptab%NOTFOUND THEN
    vr_vltardeb := 0;              
    -- Fechar o cursor
    CLOSE cr_craptab;
    
    vr_cdcritic := 55; 
    vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      
    -- Gera Log
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro Tratado
                               pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                  ' -' || vr_cdprogra || ' --> '  ||
                                                  vr_dscritic || ' CRED-USUARI-00-VLTARIFDIV-001');
                                                    
    -- Efetua Limpeza das variaveis de critica
    vr_cdcritic := 0;
    vr_dscritic := ' ';
               
  ELSE
    vr_vltardeb := to_number(SUBSTR(rw_craptab.dstextab,40,12)); -- Tarifa Debito Conta
    -- Fechar o cursor
    CLOSE cr_craptab;             
  END IF;
  
  -- Valor minimo de cheque para cobrar tarifa SPB
  TARI0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper,
                                         pr_cdbattar => 'VLRCHEQSPB',
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
                                                    vr_dscritic || ' - VLRCHEQSPB');
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      
      -- Valor minimo de cheque para cobrar tarifa SPB
      vr_vlminspb := 0;
    END IF;
  ELSE
    -- Valor minimo de cheque para cobrar tarifa SPB
    vr_vlminspb := to_number(REPLACE(vr_dsconteu,'.',''));  
  END IF;
  
  -- Percentual Aplicavel a Tarifa SPB
  TARI0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper,
                                         pr_cdbattar => 'PERCHEQSPB',
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
                                                    vr_dscritic || ' - PERCHEQSPB');
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      
      -- Percentual Aplicavel a Tarifa SPB
      vr_vlpercen := 0;
    END IF;
  ELSE
    -- Percentual Aplicavel a Tarifa SPB
    vr_vlpercen := vr_dsconteu;  
  END IF;
  
  -- Busca valor da tarifa de Cheque Inferior - Pessoa Juridica
  TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                       ,pr_cdbattar => 'TARIFSPBPJ'
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
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || vr_dscritic || ' - TARIFSPBPJ');
    -- Efetua Limpeza das variaveis de critica
    vr_cdcritic := 0;
    vr_dscritic := NULL;                                           
  END IF;
  
  -- Lista de Historicos a serem Processados
  vr_lspredep := '50,56,59,103,153,313,340,355,358,524,572';
  vr_lschqadm := '55';
  
  -- Carrega Lista de Historicos com Debito em Conta
  FOR rw_craphis IN cr_craphis(pr_cdcooper => pr_cdcooper) LOOP
    
    vr_lsdebcta := vr_lsdebcta || to_char(rw_craphis.cdhistor) || ',';
  
  END LOOP;
  
  vr_lista_historico := ',' || vr_lspredep || ',' || vr_lschqadm || ',' || vr_lsdebcta;
  
  
  -- Ajusta Lista de Historicos
  vr_lsdebcta := ',' || vr_lsdebcta;
  vr_lspredep := ',' || vr_lspredep || ','; 
  
  
  -- Busca Valor da Tarifa de Cheque Administrativo - Pessoa Juridica
  TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                       ,pr_cdbattar => 'CHQADMINPJ'
                                       ,pr_vllanmto => 1
                                       ,pr_cdprogra => vr_cdprogra
                                       ,pr_cdhistor => vr_cdhistpj
                                       ,pr_cdhisest => vr_cdhisest
                                       ,pr_vltarifa => vr_vltaripj
                                       ,pr_dtdivulg => vr_dtdivulg
                                       ,pr_dtvigenc => vr_dtvigenc
                                       ,pr_cdfvlcop => vr_cdfvlcpj
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
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || vr_dscritic || ' - CHQADMINPJ');
    -- Efetua Limpeza das variaveis de critica
    vr_cdcritic := 0;
    vr_dscritic := NULL;                                           
  END IF;

  -- Busca Valor da Tarifa de Cheque Administrativo - Pessoa Fisica
  TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                       ,pr_cdbattar => 'CHQADMINPF'
                                       ,pr_vllanmto => 1
                                       ,pr_cdprogra => vr_cdprogra
                                       ,pr_cdhistor => vr_cdhistpf
                                       ,pr_cdhisest => vr_cdhisest
                                       ,pr_vltarifa => vr_vltaripf
                                       ,pr_dtdivulg => vr_dtdivulg
                                       ,pr_dtvigenc => vr_dtvigenc
                                       ,pr_cdfvlcop => vr_cdfvlcpf
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
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || vr_dscritic || ' - CHQADMINPF');
    -- Efetua Limpeza das variaveis de critica
    vr_cdcritic := 0;
    vr_dscritic := NULL;                                           
  END IF;
  
  -- Leitura dos Contrato de Desconto de Cheques
  FOR rw_crablcm IN cr_crablcm(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt,
                               pr_cdhistor => vr_lista_historico) LOOP
                          
    -- Sempre que for primeiro registro da conta inicializa as variaveis     
    IF rw_crablcm.nrseq = 1 THEN
      vr_vlchqadm := 0;
      vr_vldebcta := 0;
      vr_vlpredep := 0;
    END IF; 
    
    -- Selecionar Dados Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => rw_crablcm.nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- Se nao encontrou associado
    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic:= 9;
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                    gene0002.fn_mask(rw_crablcm.nrdconta,'zzzz.zzz.9');
      -- Fechar Cursor
      CLOSE cr_crapass;
      
      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic);
                                                    
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
    
      --Proximo Registro
      CONTINUE;
    END IF;
    
    --Fechar Cursor
    CLOSE cr_crapass;
  
    -- Tarifa Cheque Administrativo
    IF rw_crablcm.cdhistor LIKE vr_lschqadm THEN
    
      IF rw_crapass.inpessoa = 1 THEN
        -- Pessoa Fisica
        vr_vlchqadm := vr_vlchqadm + vr_vltaripf;
      ELSE
        -- Pessoa Juridica
        vr_vlchqadm := vr_vlchqadm + vr_vltaripj;
      END IF;   
      
    END IF;  
           
    -- Tarifa Debito Conta
    IF vr_lsdebcta LIKE ('%,'||rw_crablcm.cdhistor||',%') THEN
      vr_vldebcta := vr_vldebcta + vr_vltardeb;
    END IF; 
    
    -- Acumula DOC maiores de 50000 a partir de 06/11/2002
    IF vr_lspredep LIKE ('%,'||rw_crablcm.cdhistor||',%')  
       AND rw_crablcm.vllanmto >= vr_vlminspb THEN
          vr_vlpredep := vr_vlpredep + rw_crablcm.vllanmto;
       END IF;   
    
    
    -- Quando ultimo registro da conta efetua lançamentos
    IF rw_crablcm.nrseq = rw_crablcm.qtreg THEN
      
      IF rw_crapass.inpessoa = 2 THEN
        vr_vlpredep := TRUNC((vr_vlpredep * vr_vlpercen) /100,2);
      ELSE
        vr_vlpredep := 0;
      END IF;
               
      -- Caso valores zerados segue para proximo registro
      IF vr_vlpredep = 0 AND 
         vr_vlchqadm = 0 AND
         vr_vldebcta = 0 THEN
        CONTINUE;
      END IF;
      
      --Verificar se o lote existe
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_cdagenci => 1
                     ,pr_cdbccxlt => 100
                     ,pr_nrdolote => 8452);
      -- Posicionar no proximo registro
      FETCH cr_craplot INTO rw_craplot;
      -- Se encontrou registro
      IF cr_craplot%NOTFOUND THEN
       BEGIN
         --Inserir a capa do lote retornando informacoes para uso posterior
         INSERT INTO craplot (cdcooper
                             ,dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,tplotmov
                             ,nrseqdig)
                     VALUES  (pr_cdcooper
                             ,rw_crapdat.dtmvtolt
                             ,1
                             ,100
                             ,8452
                             ,1
                             ,0)
                     RETURNING cdcooper
                              ,dtmvtolt
                              ,cdagenci
                              ,cdbccxlt
                              ,nrdolote
                              ,tplotmov
                              ,nrseqdig
                              ,ROWID
                     INTO  rw_craplot.cdcooper
                          ,rw_craplot.dtmvtolt
                          ,rw_craplot.cdagenci
                          ,rw_craplot.cdbccxlt
                          ,rw_craplot.nrdolote
                          ,rw_craplot.tplotmov
                          ,rw_craplot.nrseqdig
                          ,rw_craplot.rowid;

       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao inserir na tabela craplot. '||SQLERRM;
           --Sair do programa
           RAISE vr_exc_saida;
       END;
      END IF;
      --Fechar Cursor
      CLOSE cr_craplot;
      
      vr_nrseqdig := rw_craplot.nrseqdig + 1;
         
      IF vr_vlpredep > 0 THEN
        
        -- Criar Lançamento automatico Tarifas
        TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                        , pr_nrdconta     => rw_crapass.nrdconta
                                        , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                        , pr_cdhistor     => vr_cdhistor
                                        , pr_vllanaut     => vr_vlpredep
                                        , pr_cdoperad     => '1'
                                        , pr_cdagenci     => 1
                                        , pr_cdbccxlt     => 100
                                        , pr_nrdolote     => 8452
                                        , pr_tpdolote     => 1
                                        , pr_nrdocmto     => 0
                                        , pr_nrdctabb     => rw_crapass.nrdconta
                                        , pr_nrdctitg     => gene0002.fn_mask(rw_crapass.nrdconta,'99999999')
                                        , pr_cdpesqbb     => ' '
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
            vr_dscritic:= 'Erro no lancamento Tarifa';
          END IF;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '||
                                                        gene0002.fn_mask_conta(rw_crapass.nrdconta)||'- '
                                                     || vr_dscritic );
          -- Limpa valores das variaveis de critica
          vr_cdcritic:= 0;
          vr_dscritic:= NULL;                                           
        END IF;
                    
      END IF;
             
      IF vr_vlchqadm > 0 AND rw_crapass.inpessoa <> 3 THEN
        
        IF rw_crapass.inpessoa = 1 THEN 
          vr_cdhistor_chqadm := vr_cdhistpf;
          vr_cdfvlcop_chqadm := vr_cdfvlcpf;
        ELSE
          vr_cdhistor_chqadm := vr_cdhistpj;
          vr_cdfvlcop_chqadm := vr_cdfvlcpj;
        END IF;
        
        -- Criar Lançamento automatico Tarifas Cheque Administrativo
        TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                        , pr_nrdconta     => rw_crapass.nrdconta
                                        , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                        , pr_cdhistor     => vr_cdhistor
                                        , pr_vllanaut     => vr_vlchqadm
                                        , pr_cdoperad     => '1'
                                        , pr_cdagenci     => 1
                                        , pr_cdbccxlt     => 100
                                        , pr_nrdolote     => 8452
                                        , pr_tpdolote     => 1
                                        , pr_nrdocmto     => 0
                                        , pr_nrdctabb     => rw_crapass.nrdconta
                                        , pr_nrdctitg     => gene0002.fn_mask(rw_crapass.nrdconta,'99999999')
                                        , pr_cdpesqbb     => 'Fato gerador tarifa:' || rw_crablcm.nrdocmto
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
            vr_dscritic:= 'Erro no lancamento Tarifa Cheque Administrativo';
          END IF;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '||
                                                        gene0002.fn_mask_conta(rw_crapass.nrdconta)||'- '
                                                     || vr_dscritic );
          -- Limpa valores das variaveis de critica
          vr_cdcritic:= 0;
          vr_dscritic:= NULL;                                           
        END IF;
                                        
      END IF; -- Fim Tarifas Cheque Administrativo
             
      IF vr_vldebcta > 0 THEN
        LOOP
          -- Verificar se numero de documento já foi utilizado
          OPEN cr_craplcm(pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => rw_craplot.dtmvtolt
                         ,pr_cdagenci => rw_craplot.cdagenci
                         ,pr_cdbccxlt => rw_craplot.cdbccxlt
                         ,pr_nrdolote => rw_craplot.nrdolote
                         ,pr_nrdctabb => rw_crablcm.nrdconta
                         ,pr_nrdocmto => vr_nrseqdig);
          --Posicionar no proximo registro
          FETCH cr_craplcm INTO rw_craplcm;
          
          IF cr_craplcm%FOUND THEN
            vr_nrseqdig := nvl(vr_nrseqdig,0) +1;
            continue;
            -- Fecha Cursor
            CLOSE cr_craplcm; 
          ELSE  
            -- Fecha Cursor
            CLOSE cr_craplcm;
          END IF;
          
          -- 10/07/2018 - Inserir Lancamento 
          LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                            ,pr_dtmvtolt => rw_craplot.dtmvtolt 
                                            ,pr_cdagenci => rw_craplot.cdagenci
                                            ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                            ,pr_nrdolote => rw_craplot.nrdolote 
                                            ,pr_nrdconta => rw_crablcm.nrdconta
                                            ,pr_nrdctabb => rw_crablcm.nrdconta
                                            ,pr_nrdctitg => gene0002.fn_mask(rw_crablcm.nrdconta,'99999999')
                                            ,pr_nrdocmto => vr_nrseqdig
                                            ,pr_cdhistor => 89          -- Tarifa de Debito em Conta Corrente manual
                                            ,pr_nrseqdig => vr_nrseqdig 
                                            ,pr_vllanmto => vr_vldebcta
                                            ,pr_inprolot => 0                    -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                            ,pr_tplotmov => 0                    -- Tipo Movimento 
                                            ,pr_cdcritic => vr_cdcritic          -- Codigo Erro
                                            ,pr_dscritic => vr_dscritic          -- Descricao Erro
                                            ,pr_incrineg => vr_incrineg          -- Indicador de crítica de negócio
                                            ,pr_tab_retorno => vr_tab_retorno    -- Registro com dados do retorno
                                            );

          -- Tratamento para critica. Regra se pode debitar tratada acima
          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
            IF vr_incrineg = 0 THEN -- Erro de sistema/BD
              vr_dscritic := 'Erro ao inserir lancamento na craplcm: '||vr_dscritic;
              RAISE vr_exc_saida;
            ELSE
              tela_lautom.pc_cria_lanc_futuro(pr_cdcooper => pr_cdcooper, 
                                              pr_nrdconta => rw_crablcm.nrdconta, 
                                              pr_nrdctitg => gene0002.fn_mask(rw_crablcm.nrdconta,'99999999'), 
                                              pr_cdagenci => rw_craplot.cdagenci, 
                                              pr_dtmvtolt => rw_craplot.dtmvtolt, 
                                              pr_cdhistor => 89, 
                                              pr_vllanaut => vr_vldebcta, 
                                              pr_nrctremp => 0, 
                                              pr_dsorigem => 'BLQPREJU', 
                                              pr_dscritic => vr_dscritic);
                IF vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_saida;
                end if;

            end if;
            
          END IF;
            
          --Atualizar capa do Lote
          BEGIN
            UPDATE craplot SET craplot.vlinfodb = NVL(rw_craplot.vlinfodb,0) + NVL(vr_vldebcta,0)
                              ,craplot.vlcompdb = NVL(rw_craplot.vlcompdb,0) + NVL(vr_vldebcta,0)
                              ,craplot.qtinfoln = NVL(rw_craplot.qtinfoln,0) + 1
                              ,craplot.qtcompln = NVL(rw_craplot.qtcompln,0) + 1
                              ,craplot.nrseqdig = NVL(vr_nrseqdig,0)
            WHERE craplot.ROWID = rw_craplot.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela craplot. '||SQLERRM;
              --Sair do programa
              RAISE vr_exc_saida;
          END;
          -- Se conseguiu inserir e alterar, deve sair do loop
          EXIT;
          
        END LOOP;
             
      END IF; -- Fim Tarifa  
      
    END IF; -- Final Lançamento por Conta   
  
  END LOOP;
 
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
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                    ' -' || vr_cdprogra || ' --> ' ||
                                                    vr_dscritic);

    END IF;

    -- Chamos o pc_valida_fimprg para encerrar o processo sem parar a cadeia
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salva informações no banco de dados
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
END pc_crps285;
/
