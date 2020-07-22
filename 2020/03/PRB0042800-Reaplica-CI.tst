PL/SQL Developer Test script 3.0
546
-- Created on 19/03/2020 by F0030794 
/* Verifica contas com saldo parado na conta investimento que seja proveniente
  de vencimento de plano de aplicacao programada e tenta reaplicar. */
declare 

  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   varchar2(5000) := ' ';
  vr_tem_critica boolean := false;
  vr_excsaida EXCEPTION;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/PRB0042800';
  vr_nmarqimp        VARCHAR2(100)  := 'log.txt';
  vr_nmarqimp2       VARCHAR2(100)  := 'sucesso.txt';
  vr_nmarqimp3       VARCHAR2(100)  := 'falha.txt';
  vr_nmarqimp4       VARCHAR2(100)  := 'backup.txt';
  vr_nmarqimp5       VARCHAR2(100)  := 'rollback.txt';
  vr_nmarqimp6       VARCHAR2(100)  := 'planos.txt';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  vr_ind_arquiv3     utl_file.file_type;
  vr_ind_arquiv4     utl_file.file_type;
  vr_ind_arquiv5     utl_file.file_type;
  vr_ind_arquiv6     utl_file.file_type;
  
  vr_tab_care APLI0005.typ_tab_care;
  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  vr_dsorigem VARCHAR2(500) := 'AIMARO,CAIXA,INTERNET,TAA,AIMARO WEB,URA';
  vr_nrdrowid ROWID;
  vr_nraplica NUMBER;

  cursor cr_saldoci IS
    select sli.cdcooper, sli.nrdconta, sli.vlsddisp
  from (
  select distinct rpp.cdcooper, rpp.nrdconta
    from craprpp rpp 
   where rpp.cdprodut = 1007 
     and rpp.cdsitrpp = 5 
     and exists (select 1 
                    from crapsli sli 
                   where sli.dtrefere = to_date('31/03/2020','dd/mm/rrrr') 
                     and sli.vlsddisp > 0 
                     and sli.cdcooper = rpp.cdcooper 
                     and sli.nrdconta = rpp.nrdconta)
  ) contas
  join crapsli sli
    on sli.dtrefere = to_date('31/03/2020','dd/mm/rrrr')
   and sli.vlsddisp > 0 
   and sli.cdcooper = contas.cdcooper 
   and sli.nrdconta = contas.nrdconta
  order by sli.cdcooper, sli.nrdconta;
  rw_saldoci cr_saldoci%ROWTYPE;
  
  cursor cr_craprpp_vcto IS
  select rpp.cdcooper, rpp.nrdconta, rpp.nrctrrpp, rpp.dtvctopp, rpp.cdprodut, rpp.cdbccxlt, 0 vlrvencido
        ,rpp.cdsitrpp, rpp.dtrnirpp, rpp.dtcancel
        ,rpp.dtdebito, rpp.rowid
    from craprpp rpp 
   where rpp.cdprodut = 1007 
     and rpp.cdsitrpp = 5;
  rw_craprpp_vcto cr_craprpp_vcto%rowtype;
  
  cursor cr_craplci(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN craplci.nrdconta%TYPE
                   ,pr_dtmvtolt IN craplci.dtmvtolt%TYPE) IS
   select sum(lci.vllanmto * decode(his.indebcre,'D',-1,1)) vltotal
    from craplci lci
    join craphis his
      on his.cdcooper = lci.cdcooper
     and his.cdhistor = lci.cdhistor
   where lci.cdcooper = pr_cdcooper
     and lci.nrdconta = pr_nrdconta
     and lci.dtmvtolt = pr_dtmvtolt;
  rw_craplci cr_craplci%rowtype;
  
  cursor cr_craprpp IS
  select rpp.cdcooper, rpp.nrdconta, rpp.nrctrrpp, 
         rpp.cdsitrpp, rpp.dtrnirpp, rpp.dtcancel, 
         rpp.dtdebito, rpp.dtvctopp, rpp.rowid
   from craprpp rpp
   where rpp.cdprodut = 1007 
     and rpp.cdsitrpp = 5
     and rpp.dtvctopp > rpp.dtmvtolt
     and not exists (select 1
                   from craprpp outro
                  where outro.cdcooper = rpp.cdcooper
                    and outro.nrdconta = rpp.nrdconta
                    and outro.nrctrrpp <> rpp.nrctrrpp
                    and outro.dtmvtolt > rpp.dtvctopp
                    and outro.cdprodut = 1007
                    and outro.cdsitrpp in (1,2,3,4))
   order by rpp.cdcooper, rpp.nrdconta;
  rw_craprpp cr_craprpp%ROWTYPE;
  
  TYPE typ_tab_reg_planos IS
    TABLE OF cr_craprpp_vcto%rowtype
    INDEX BY PLS_INTEGER;
                
  TYPE typ_reg_craprpp IS
    TABLE OF typ_tab_reg_planos
    INDEX BY VARCHAR(020);  -- COOPER(10) + CONTA(10)
        
  vr_tab_craprpp typ_reg_craprpp;
  vr_idx  VARCHAR(020);
  vr_idx2 PLS_INTEGER;
  vr_vlr_vencido NUMBER(15,2);
  vr_total_sim PLS_INTEGER := 0;
  vr_total_nao PLS_INTEGER := 0;

  procedure pc_carrega_memoria IS
  BEGIN
    FOR rw_craprpp_vcto IN cr_craprpp_vcto LOOP
      vr_idx  := lpad(rw_craprpp_vcto.cdcooper,10,'0')||lpad(rw_craprpp_vcto.nrdconta,10,'0');    
      vr_tab_craprpp(vr_idx)(rw_craprpp_vcto.nrctrrpp) := rw_craprpp_vcto;
    END LOOP;
  END;

  procedure loga(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
  END;
    
  procedure sucesso(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
  END;
  
  procedure falha(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
    loga(pr_msg);
  END;
  
  procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
  END;
      
  procedure backup2(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv5, pr_msg);
  END;
  
  procedure backup3(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv6, pr_msg);
  END;
  
  procedure atualiza_craprpp(pr_cdcooper IN craprpp.cdcooper%TYPE,
                             pr_nrdconta IN craprpp.nrdconta%TYPE,
                             pr_nrctrrpp IN craprpp.nrctrrpp%TYPE,
                             pr_cdsitrpp IN craprpp.cdsitrpp%TYPE,
                             pr_dtvctopp IN craprpp.dtvctopp%TYPE,
                             pr_dtdebito IN craprpp.dtdebito%TYPE,
                             pr_dtcancel IN craprpp.dtcancel%TYPE,
                             pr_dtrnirpp IN craprpp.dtrnirpp%TYPE,
                             pr_rowid    IN rowid,
                             pr_dscritic OUT varchar2) IS
    vr_cdsitrpp craprpp.cdsitrpp%TYPE;
    vr_dtvctopp craprpp.dtvctopp%TYPE := to_date('31/07/2020','dd/mm/rrrr');
    vr_dtdebito craprpp.dtdebito%TYPE;
  BEGIN
    loga('Ajustando plano: Cooper: '||pr_cdcooper || ' Conta: ' ||pr_nrdconta || ' Plano: '|| pr_nrctrrpp );
    
    -- Por padrao [1 - Ativo]
    vr_cdsitrpp := 1;
    
    IF pr_dtcancel is not null THEN
      -- se tem data de cancelamento - [3 - Cancelado]
      vr_cdsitrpp := 3;
    END IF;
    
    IF pr_dtrnirpp is not null  AND
       pr_dtrnirpp > SYSDATE THEN
      -- se tem data de reinicio e ainda nao chegou nessa data - [2 - Suspenso]
      vr_cdsitrpp := 2;
    END IF;
    
    vr_dtdebito := to_date(extract(day from pr_dtdebito) || '/' ||
                           extract(month from SYSDATE) || '/' ||
                           extract(year from SYSDATE),'dd/mm/rrrr');
    
    IF vr_dtdebito < SYSDATE THEN
      vr_dtdebito := ADD_MONTHS(vr_dtdebito,1);
    END IF;
    
    BEGIN
      UPDATE craprpp
         SET cdsitrpp = vr_cdsitrpp
            ,dtvctopp = vr_dtvctopp
            ,dtdebito = vr_dtdebito
       WHERE rowid = pr_rowid;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro alterando o plano - '|| pr_cdcooper || ' Conta: ' || pr_nrdconta || ' Plano: '|| pr_nrctrrpp || ' - ' || SQLERRM;
        RAISE vr_excsaida;
    END;
    
    backup3('update craprpp set cdsitrpp = '|| pr_cdsitrpp||
                             ', dtvctopp = to_date('''|| to_char(pr_dtvctopp,'dd/mm/rrrr') ||''',''dd/mm/rrrr'')'||
                             ', dtdebito = to_date('''|| to_char(pr_dtdebito,'dd/mm/rrrr') ||''',''dd/mm/rrrr'')'||
                   ' where rowid = '''|| pr_rowid || ''';');
    sucesso('Plano alterado: Cooper: '|| pr_cdcooper || ' Conta: ' ||pr_nrdconta || ' Plano: '|| pr_nrctrrpp || 
                          ' Vencimento de '  || to_char(pr_dtvctopp,'dd/mm/rrrr') || ' para ' || to_char(vr_dtvctopp,'dd/mm/rrrr')  ||
                          ' Data Debito de ' || to_char(pr_dtdebito,'dd/mm/rrrr') || ' para ' || to_char(vr_dtdebito,'dd/mm/rrrr')  || 
                          ' Situacao de ' || pr_cdsitrpp || ' para ' || vr_cdsitrpp);
  EXCEPTION
    WHEN OTHERS THEN
      IF nvl(pr_dscritic,' ') = ' ' THEN        
        pr_dscritic := 'Erro alterando o plano - '|| pr_cdcooper || ' Conta: ' || pr_nrdconta || ' Plano: '|| pr_nrctrrpp || ' - ' || SQLERRM;
      END IF;
  END;
  
begin
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp3       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv3     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp4       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv4     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp5       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv5     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
    --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp6       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv6     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
    
  loga('Inicio Carga Tabela Memoria');
  gene0001.pc_informa_acesso(pr_module => 'BACA-Reaplica-CI', pr_action => null);
  
  vr_total_nao := 0;
  vr_total_sim := 0;
  
  -- Carrega os planos em memoria
  pc_carrega_memoria;
  
  loga('Inicio Processo');
  
  backup2(
'declare 
  vr_tpcritic_apl crapcri.cdcritic%TYPE;
  vr_cdcritic_apl PLS_INTEGER := 0;
  vr_dscritic_apl VARCHAR2(4000) := NULL;
  vr_excsaida EXCEPTION;
begin
');
  
  FOR rw_saldoci IN cr_saldoci LOOP
    loga('Verificando conta: Cooper: '|| rw_saldoci.cdcooper || ' Conta: ' ||rw_saldoci.nrdconta );
    
    vr_idx  := lpad(rw_saldoci.cdcooper,10,'0')||lpad(rw_saldoci.nrdconta,10,'0');    
    IF NOT vr_tab_craprpp.exists(vr_idx) THEN
      loga('Nao encontrou plano vencido: Cooper: '|| rw_saldoci.cdcooper || ' Conta: ' ||rw_saldoci.nrdconta );
      falha('Nao encontrou plano vencido: Cooper: '|| rw_saldoci.cdcooper || ' Conta: ' ||rw_saldoci.nrdconta );
      vr_total_nao := vr_total_nao + 1;
      CONTINUE;
    END IF;
    
    /* loop passando por todos os planos e vendo se os lctos da data de vencimento somam o valor exato
       parado na conta */
    vr_vlr_vencido := 0;
    vr_idx2        := vr_tab_craprpp(vr_idx).FIRST;
    WHILE vr_idx2 IS NOT NULL LOOP
      
      rw_craprpp_vcto := vr_tab_craprpp(vr_idx)(vr_idx2);
      
      OPEN cr_craplci(pr_cdcooper => rw_craprpp_vcto.cdcooper
                     ,pr_nrdconta => rw_craprpp_vcto.nrdconta
                     ,pr_dtmvtolt => gene0005.fn_valida_dia_util(pr_cdcooper => rw_craprpp_vcto.cdcooper
                                                                ,pr_dtmvtolt => rw_craprpp_vcto.dtvctopp
                                                                ,pr_tipo => 'P'
                                                                ,pr_feriado => true
                                                                ,pr_excultdia => true));
      FETCH cr_craplci INTO rw_craplci;
      IF cr_craplci%FOUND THEN
        -- Carrega o valor vencido na temptable
        vr_tab_craprpp(vr_idx)(vr_idx2).vlrvencido := nvl(rw_craplci.vltotal,0);
        -- Armazena o total vencido na conta
        vr_vlr_vencido := vr_vlr_vencido + nvl(rw_craplci.vltotal,0);
      END IF;
      CLOSE cr_craplci;    
      
      -- Proximo plano
      vr_idx2 := vr_tab_craprpp.NEXT(vr_idx2);
    END LOOP;
    
    IF vr_vlr_vencido <> rw_saldoci.vlsddisp THEN
      loga('Valor em conta investimento NAO fecha com o valor vencido! Cooper: '|| rw_saldoci.cdcooper || ' Conta: ' ||rw_saldoci.nrdconta || ' Valor vencido: '|| vr_vlr_vencido || ' Valor CI: ' || rw_saldoci.vlsddisp);
      falha('Valor em conta investimento NAO fecha com o valor vencido! Cooper: '|| rw_saldoci.cdcooper || ' Conta: ' ||rw_saldoci.nrdconta || ' Valor vencido: '|| vr_vlr_vencido || ' Valor CI: ' || rw_saldoci.vlsddisp);
      vr_total_nao := vr_total_nao + 1;
      continue;
    END IF; 
    
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_craprpp_vcto.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      vr_cdcritic := 1;
      RAISE vr_excsaida;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    /* Passar pelos planos e reaplicar o valor da CI */
    vr_idx2        := vr_tab_craprpp(vr_idx).FIRST;
    WHILE vr_idx2 IS NOT NULL LOOP
      
      rw_craprpp_vcto := vr_tab_craprpp(vr_idx)(vr_idx2);
      
      apli0005.pc_obtem_carencias(pr_cdcooper => rw_craprpp_vcto.cdcooper   -- Codigo da Cooperativa
                                 ,pr_cdprodut => rw_craprpp_vcto.cdprodut   -- Codigo do Produto 
                                 ,pr_cdcritic => vr_cdcritic   -- Codigo da Critica
                                 ,pr_dscritic => vr_dscritic   -- Descricao da Critica
                                 ,pr_tab_care => vr_tab_care); -- Tabela com registros de Carencia do produto    

       IF vr_dscritic IS NULL THEN
           SAVEPOINT APLICA_BACA_APL_PROG;
           apli0005.pc_cadastra_aplic(pr_cdcooper => rw_craprpp_vcto.cdcooper,
                                      pr_cdoperad => '1',
                                      pr_nmdatela => 'CRPS145',
                                      pr_idorigem => 5,
                                      pr_nrdconta => rw_craprpp_vcto.nrdconta,
                                      pr_idseqttl => 1,
                                      pr_nrdcaixa => rw_craprpp_vcto.cdbccxlt,
                                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                      pr_cdprodut => rw_craprpp_vcto.cdprodut,
                                      pr_qtdiaapl => vr_tab_care(1).qtdiaprz,
                                      pr_dtvencto => rw_crapdat.dtmvtolt + vr_tab_care(1).qtdiaprz,
                                      pr_qtdiacar => vr_tab_care(1).qtdiacar,
                                      pr_qtdiaprz => vr_tab_care(1).qtdiaprz,
                                      pr_vlaplica => rw_craprpp_vcto.vlrvencido,
                                      pr_iddebcti => 1, -- origem do recurso CI
                                      pr_idorirec => 0,
                                      pr_idgerlog => 1,
                                      pr_nrctrrpp => rw_craprpp_vcto.nrctrrpp, -- Número da RPP
                                      pr_nraplica => vr_nraplica,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
          IF (vr_cdcritic IS NOT NULL) OR (vr_dscritic IS NOT NULL) THEN
            /* Se deu critica nessa conta, vamos desfazer o processo dela e logar */
            ROLLBACK TO APLICA_BACA_APL_PROG;
            loga('Erro ao aplicar! Cooper: '|| rw_craprpp_vcto.cdcooper || ' Conta: ' ||rw_craprpp_vcto.nrdconta || ' Valor vencido: '|| rw_craprpp_vcto.vlrvencido || ' ERRO: ' || vr_dscritic);
            GENE0001.pc_gera_log(pr_cdcooper => rw_craprpp_vcto.cdcooper
                                ,pr_cdoperad => '1'
                                ,pr_dscritic => vr_dscritic
                                ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => 5,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                                ,pr_dstransa => 'INCLUSAO APLICACAO PROGRAMADA - SCRIPT'
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 1 --> TRUE
                                ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'CRPS145'
                                ,pr_nrdconta => rw_craprpp_vcto.nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
            gene0001.pc_informa_acesso(pr_module => 'BACA-Reaplica-CI', pr_action => null);
            continue;
          END IF;
          gene0001.pc_informa_acesso(pr_module => 'BACA-Reaplica-CI', pr_action => null);
      ELSE
        loga('Erro ao buscar as taxas! Cooper: '|| rw_craprpp_vcto.cdcooper || ' Conta: ' ||rw_craprpp_vcto.nrdconta || ' Valor vencido: '|| rw_craprpp_vcto.vlrvencido || ' ERRO: ' || vr_dscritic);
        falha('Erro ao buscar as taxas! Cooper: '|| rw_craprpp_vcto.cdcooper || ' Conta: ' ||rw_craprpp_vcto.nrdconta || ' Valor vencido: '|| rw_craprpp_vcto.vlrvencido || ' ERRO: ' || vr_dscritic);
        continue;
      END IF;
      
      loga('Criou aplicacao! Cooper: '|| rw_craprpp_vcto.cdcooper || ' Conta: ' ||rw_craprpp_vcto.nrdconta || ' Plano: ' || rw_Craprpp_vcto.nrctrrpp ||' Aplica: '|| vr_nraplica ||' Valor: '|| rw_craprpp_vcto.vlrvencido);
      sucesso('Aplicacao criada - Cooper: '|| rw_craprpp_vcto.cdcooper || ' Conta: ' ||rw_craprpp_vcto.nrdconta || ' Plano: ' || rw_Craprpp_vcto.nrctrrpp ||' Aplica: '|| vr_nraplica ||' Valor: '|| rw_craprpp_vcto.vlrvencido);
      
      atualiza_craprpp(pr_cdcooper => rw_craprpp_vcto.cdcooper
                      ,pr_nrdconta => rw_craprpp_vcto.nrdconta
                      ,pr_nrctrrpp => rw_craprpp_vcto.nrctrrpp
                      ,pr_cdsitrpp => rw_craprpp_vcto.cdsitrpp
                      ,pr_dtvctopp => rw_craprpp_vcto.dtvctopp
                      ,pr_dtdebito => rw_craprpp_vcto.dtdebito
                      ,pr_dtcancel => rw_craprpp_vcto.dtcancel
                      ,pr_dtrnirpp => rw_craprpp_vcto.dtrnirpp
                      ,pr_rowid    => rw_craprpp_vcto.rowid
                      ,pr_dscritic => vr_dscritic);
      IF vr_dscritic <> ' ' THEN
        ROLLBACK TO APLICA_BACA_APL_PROG;
        loga(vr_dscritic);
        falha(vr_dscritic);
        continue;
      END IF;
      
      -- faz backup 1
      backup('update craprac set idsaqtot = 1, vlsldatl = 0, vlbasapl = 0 where cdcooper = '|| rw_craprpp_vcto.cdcooper || ' and nrdconta = '|| rw_craprpp_vcto.nrdconta || ' and nraplica = '|| vr_nraplica || ' and nrctrrpp = '|| rw_craprpp_vcto.nrctrrpp ||';');
      
      -- criar backup2 resgatando para CI
      backup2('  BEGIN ');
      backup2('    APLI0005.pc_efetua_resgate(pr_cdcooper => '||rw_craprpp_vcto.cdcooper||'
                                              ,pr_nrdconta => '||rw_craprpp_vcto.nrdconta||'
                                              ,pr_nraplica => '||vr_nraplica||'
                                              ,pr_vlresgat => '||to_char(rw_craprpp_vcto.vlrvencido,'fm99999999999.00')||'
                                              ,pr_idtiprgt => 2 /* resgate total */
                                              ,pr_dtresgat => to_date('''||to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')||''',''dd/mm/rrrr'')
                                              ,pr_nrseqrgt => 1
                                              ,pr_idrgtcti => 1 /* resgate para CI */
                                              ,pr_tpcritic => vr_tpcritic_apl
                                              ,pr_cdcritic => vr_cdcritic_apl
                                              ,pr_dscritic => vr_dscritic_apl);');
      backup2('  EXCEPTION 
    WHEN OTHERS THEN  
      vr_dscritic_apl := ''Cooper: '||rw_craprpp_vcto.cdcooper||' Conta: '||rw_craprpp_vcto.nrdconta||' Aplica: '||vr_nraplica||' deu erro: ''||vr_dscritic_apl'||';
      RAISE vr_excsaida;
  END;');
  
      -- commit a cada 500 registros
      IF mod(vr_total_sim,500) = 0 THEN
        commit;
      END IF;

      vr_total_sim := vr_total_sim + 1;
      -- Proximo plano
      vr_idx2 := vr_tab_craprpp.NEXT(vr_idx2);
    END LOOP;

  END LOOP;
  
  commit;
  
  loga('Inicio reativacao dos planos');
  
  FOR rw_craprpp IN cr_craprpp LOOP
    loga('Verificando conta: Cooper: '|| rw_craprpp.cdcooper || ' Conta: ' ||rw_craprpp.nrdconta || ' Plano: '|| rw_craprpp.nrctrrpp );
    
    atualiza_craprpp(pr_cdcooper => rw_craprpp.cdcooper
                    ,pr_nrdconta => rw_craprpp.nrdconta
                    ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                    ,pr_cdsitrpp => rw_craprpp.cdsitrpp
                    ,pr_dtvctopp => rw_craprpp.dtvctopp
                    ,pr_dtdebito => rw_craprpp.dtdebito
                    ,pr_dtcancel => rw_craprpp.dtcancel
                    ,pr_dtrnirpp => rw_craprpp.dtrnirpp
                    ,pr_rowid    => rw_craprpp.rowid
                    ,pr_dscritic => vr_dscritic);
    IF vr_dscritic <> ' ' THEN
      loga(vr_dscritic);
      falha(vr_dscritic);
      continue;
    END IF;
  END LOOP;  
  
  loga('Fim do Processo com sucesso');
  loga('Total deu certo: '|| vr_total_sim || ' - Total nao deu certo: '|| vr_total_nao);
    
  backup3('COMMIT;');
  
  backup2(' COMMIT;');  
  backup2('EXCEPTION');
  backup2('  WHEN OTHERS THEN ');
  backup2('    ROLLBACK;');
  backup2('    :vr_dscritic := vr_dscritic_apl;');
  backup2('END;');
  
  IF vr_tem_critica THEN
    RAISE vr_excsaida;
  END IF;
  
  commit;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv5); --> Handle do arquivo aberto; 
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv6); --> Handle do arquivo aberto;   

  :vr_dscritic := 'SUCESSO';
  
EXCEPTION
  WHEN vr_excsaida then 
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv5); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv6); --> Handle do arquivo aberto;  
    
  WHEN OTHERS then
    loga(vr_dscritic);
    loga(SQLERRM);
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv5); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv6); --> Handle do arquivo aberto;  
end;
1
vr_dscritic
1
SUCESSO
5
2
vr_vlr_vencido
rw_crapsli.vlsddisp
