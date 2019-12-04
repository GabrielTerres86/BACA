PL/SQL Developer Test script 3.0
303
-- Created on 28/10/2019 by F0030794 
/* A data fim nao pode considerar o mes corrente, pois caso contrario o total de rendimento do mes
   corrente sera considerado em duplicidade (baca + crps223) */
declare 

  pr_cdcooper   crapcop.cdcooper%TYPE := 1;
  pr_data_ini   date := to_date('01/01/2019','dd/mm/rrrr');
  pr_data_fim   date := to_date('30/11/2019','dd/mm/rrrr');
  
  vr_dscritic   varchar2(5000) := ' ';
  vr_tem_critica boolean := false;
  vr_excsaida EXCEPTION;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/PRB0041459';
  vr_nmarqimp        VARCHAR2(100)  := 'viacredi-log.txt';
  vr_nmarqimp2       VARCHAR2(100)  := 'viacredi-sucesso.txt';
  vr_nmarqimp3       VARCHAR2(100)  := 'viacredi-falha.txt';
  vr_nmarqimp4       VARCHAR2(100)  := 'viacredi-backup.txt';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  vr_ind_arquiv3     utl_file.file_type;
  vr_ind_arquiv4     utl_file.file_type;
  
  TYPE typ_tab_reg_lanctos IS
    TABLE OF NUMBER
    INDEX BY PLS_INTEGER;
                
  TYPE typ_reg_aplprog IS
    TABLE OF typ_tab_reg_lanctos
    INDEX BY VARCHAR(020);  -- COOPER(10) + CONTA(10)
        
  vr_tab_rend_aplprog typ_reg_aplprog;
  vr_idx  VARCHAR(020);
  vr_idx2 PLS_INTEGER;


  cursor cr_crapass IS
  select ass.cdcooper
        ,ass.nrdconta
        ,ass.inpessoa
    from crapass ass
   where ass.cdcooper = pr_cdcooper
     and exists (select 1 
                   from craprac rac
                  where rac.cdcooper = ass.cdcooper
                    and rac.nrdconta = ass.nrdconta);
  rw_crapass cr_crapass%ROWTYPE;

  cursor cr_crapcot(pr_cdcooper crapcop.cdcooper%TYPE,
                    pr_nrdconta crapass.nrdconta%TYPE) IS
   select /* coluna de rendimento total da poupanca/aplicacao programada */
          cot.vlrenrpp
          /* colunas de rendimento total por mes */
         ,cot.vlrentot##1,  cot.vlrentot##2, cot.vlrentot##3, cot.vlrentot##4, cot.vlrentot##5
         ,cot.vlrentot##6,  cot.vlrentot##7, cot.vlrentot##8, cot.vlrentot##9, cot.vlrentot##10
         ,cot.vlrentot##11, cot.vlrentot##12
         /* colunas de rendimento da poupanca/aplicacao progamada por mes */
         ,cot.vlrenrpp_ir##1,  cot.vlrenrpp_ir##2,  cot.vlrenrpp_ir##3, cot.vlrenrpp_ir##4, cot.vlrenrpp_ir##5
         ,cot.vlrenrpp_ir##6,  cot.vlrenrpp_ir##7,  cot.vlrenrpp_ir##8, cot.vlrenrpp_ir##9, cot.vlrenrpp_ir##10
         ,cot.vlrenrpp_ir##11, cot.vlrenrpp_ir##12
         
         ,cot.rowid
     from crapcot cot
    where cot.cdcooper = pr_cdcooper
      and cot.nrdconta = pr_nrdconta;
  rw_crapcot cr_crapcot%ROWTYPE;
    
  cursor cr_craplac(pr_cdcooper crapcop.cdcooper%TYPE) IS
  select lac.cdcooper, lac.nrdconta, lac.dtmvtolt, lac.vllanmto
    from craplac lac, craprac rac
   where rac.cdcooper = lac.cdcooper
     and rac.nrdconta = lac.nrdconta
     and rac.nraplica = lac.nraplica
     and rac.nrctrrpp > 0
     and lac.cdcooper = pr_cdcooper
     and lac.dtmvtolt between pr_data_ini and pr_data_fim
     and lac.cdhistor = 2749; -- Rendimento aplic. prog.
   rw_craplac cr_craplac%ROWTYPE;  
  
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
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
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
    
  loga('Inicio Carga Tabela Memoria');
  
  FOR rw_craplac IN cr_craplac(pr_cdcooper => pr_cdcooper) LOOP
    
    -- vr_tab_rend_aplprog(cooper + nrdconta)(mes) := valor
    vr_idx  := lpad(rw_craplac.cdcooper,10,'0')||lpad(rw_craplac.nrdconta,10,'0');    
    
    IF NOT vr_tab_rend_aplprog.exists(vr_idx) THEN
      vr_idx2 := 1;
      LOOP
        exit when vr_idx2 > 13;
        vr_tab_rend_aplprog(vr_idx)(vr_idx2) := 0;
        vr_idx2 := vr_idx2 + 1;
      END LOOP;
    END IF;
    
    vr_idx2 := extract(month from rw_craplac.dtmvtolt);
    
    vr_tab_rend_aplprog(vr_idx)(vr_idx2) := vr_tab_rend_aplprog(vr_idx)(vr_idx2) + rw_craplac.vllanmto;
    -- mes = 13 sera o total
    vr_tab_rend_aplprog(vr_idx)(13) := vr_tab_rend_aplprog(vr_idx)(13) + rw_craplac.vllanmto;
  END LOOP;
  
  loga('Inicio Processo');
  
  FOR rw_crapass IN cr_crapass LOOP
    loga('Ajustando conta: Cooper: '|| rw_crapass.cdcooper || ' Conta: ' ||rw_crapass.nrdconta || ' Pessoa: '|| rw_crapass.inpessoa);
    
    OPEN cr_crapcot(pr_cdcooper => rw_crapass.cdcooper,
                    pr_nrdconta => rw_crapass.nrdconta);
    FETCH cr_crapcot INTO rw_crapcot;
    IF cr_crapcot%NOTFOUND THEN
      CLOSE cr_crapcot;
      falha('CRAPCOT nao encontrado! Cooper: '|| rw_crapass.cdcooper || ' Conta: ' ||rw_crapass.nrdconta || ' Pessoa: '|| rw_crapass.inpessoa);
      CONTINUE;
    END IF;
    
    vr_idx  := lpad(rw_crapass.cdcooper,10,'0')||lpad(rw_crapass.nrdconta,10,'0');
        
    IF NOT vr_tab_rend_aplprog.exists(vr_idx) THEN
      CLOSE cr_crapcot;
      loga('Conta sem registro de rendimento! Cooper: '|| rw_crapass.cdcooper || ' Conta: ' ||rw_crapass.nrdconta || ' Pessoa: '|| rw_crapass.inpessoa || ' Valor: '|| replace(rw_crapcot.vlrenrpp,',','.'));
      CONTINUE;
    END IF;
    
    /* Verifica se precisa atualizar */
    IF (nvl(vr_tab_rend_aplprog(vr_idx)(13),0) <= 0) THEN
      CLOSE cr_crapcot;
      loga('Conta sem necessidade alteracao! Cooper: '|| rw_crapass.cdcooper || ' Conta: ' ||rw_crapass.nrdconta || ' Pessoa: '|| rw_crapass.inpessoa || ' Valor: '|| replace(rw_crapcot.vlrenrpp,',','.'));
      CONTINUE;
    END IF;
    
    --backup crapcot
    backup('update crapcot '  ||
            ' set vlrenrpp     = '|| replace(rw_crapcot.vlrenrpp,',','.') ||
               ' ,vlrentot##1  = '|| replace(rw_crapcot.vlrentot##1,',','.') ||
               ' ,vlrentot##2  = '|| replace(rw_crapcot.vlrentot##2,',','.') ||
               ' ,vlrentot##3  = '|| replace(rw_crapcot.vlrentot##3,',','.') ||
               ' ,vlrentot##4  = '|| replace(rw_crapcot.vlrentot##4,',','.') ||
               ' ,vlrentot##5  = '|| replace(rw_crapcot.vlrentot##5,',','.') ||
               ' ,vlrentot##6  = '|| replace(rw_crapcot.vlrentot##6,',','.') ||
               ' ,vlrentot##7  = '|| replace(rw_crapcot.vlrentot##7,',','.') ||
               ' ,vlrentot##8  = '|| replace(rw_crapcot.vlrentot##8,',','.') ||
               ' ,vlrentot##9  = '|| replace(rw_crapcot.vlrentot##9,',','.') ||
               ' ,vlrentot##10 = '|| replace(rw_crapcot.vlrentot##10,',','.') ||
               ' ,vlrentot##11 = '|| replace(rw_crapcot.vlrentot##11,',','.') ||
               ' ,vlrentot##12 = '|| replace(rw_crapcot.vlrentot##12,',','.') ||
               ' ,vlrenrpp_ir##1  = '|| replace(rw_crapcot.vlrenrpp_ir##1,',','.') ||
               ' ,vlrenrpp_ir##2  = '|| replace(rw_crapcot.vlrenrpp_ir##2,',','.') ||
               ' ,vlrenrpp_ir##3  = '|| replace(rw_crapcot.vlrenrpp_ir##3,',','.') ||
               ' ,vlrenrpp_ir##4  = '|| replace(rw_crapcot.vlrenrpp_ir##4,',','.') ||
               ' ,vlrenrpp_ir##5  = '|| replace(rw_crapcot.vlrenrpp_ir##5,',','.') ||
               ' ,vlrenrpp_ir##6  = '|| replace(rw_crapcot.vlrenrpp_ir##6,',','.') ||
               ' ,vlrenrpp_ir##7  = '|| replace(rw_crapcot.vlrenrpp_ir##7,',','.') ||
               ' ,vlrenrpp_ir##8  = '|| replace(rw_crapcot.vlrenrpp_ir##8,',','.') ||
               ' ,vlrenrpp_ir##9  = '|| replace(rw_crapcot.vlrenrpp_ir##9,',','.') ||
               ' ,vlrenrpp_ir##10 = '|| replace(rw_crapcot.vlrenrpp_ir##10,',','.') ||
               ' ,vlrenrpp_ir##11 = '|| replace(rw_crapcot.vlrenrpp_ir##11,',','.') ||
               ' ,vlrenrpp_ir##12 = '|| replace(rw_crapcot.vlrenrpp_ir##12,',','.') ||
           ' where rowid = '''|| rw_crapcot.rowid ||''';');
    BEGIN
      UPDATE crapcot
         SET vlrenrpp = vlrenrpp + vr_tab_rend_aplprog(vr_idx)(13)
            ,vlrentot##1  = vlrentot##1 + vr_tab_rend_aplprog(vr_idx)(1)
            ,vlrentot##2  = vlrentot##2 + vr_tab_rend_aplprog(vr_idx)(2)
            ,vlrentot##3  = vlrentot##3 + vr_tab_rend_aplprog(vr_idx)(3)
            ,vlrentot##4  = vlrentot##4 + vr_tab_rend_aplprog(vr_idx)(4)
            ,vlrentot##5  = vlrentot##5 + vr_tab_rend_aplprog(vr_idx)(5)
            ,vlrentot##6  = vlrentot##6 + vr_tab_rend_aplprog(vr_idx)(6)
            ,vlrentot##7  = vlrentot##7 + vr_tab_rend_aplprog(vr_idx)(7)
            ,vlrentot##8  = vlrentot##8 + vr_tab_rend_aplprog(vr_idx)(8)
            ,vlrentot##9  = vlrentot##9 + vr_tab_rend_aplprog(vr_idx)(9)
            ,vlrentot##10 = vlrentot##10 + vr_tab_rend_aplprog(vr_idx)(10)
            ,vlrentot##11 = vlrentot##11 + vr_tab_rend_aplprog(vr_idx)(11)
            ,vlrentot##12 = vlrentot##12 + vr_tab_rend_aplprog(vr_idx)(12)
            ,vlrenrpp_ir##1  = vlrenrpp_ir##1 + vr_tab_rend_aplprog(vr_idx)(1)
            ,vlrenrpp_ir##2  = vlrenrpp_ir##2 + vr_tab_rend_aplprog(vr_idx)(2)
            ,vlrenrpp_ir##3  = vlrenrpp_ir##3 + vr_tab_rend_aplprog(vr_idx)(3)
            ,vlrenrpp_ir##4  = vlrenrpp_ir##4 + vr_tab_rend_aplprog(vr_idx)(4)
            ,vlrenrpp_ir##5  = vlrenrpp_ir##5 + vr_tab_rend_aplprog(vr_idx)(5)
            ,vlrenrpp_ir##6  = vlrenrpp_ir##6 + vr_tab_rend_aplprog(vr_idx)(6)
            ,vlrenrpp_ir##7  = vlrenrpp_ir##7 + vr_tab_rend_aplprog(vr_idx)(7)
            ,vlrenrpp_ir##8  = vlrenrpp_ir##8 + vr_tab_rend_aplprog(vr_idx)(8)
            ,vlrenrpp_ir##9  = vlrenrpp_ir##9 + vr_tab_rend_aplprog(vr_idx)(9)
            ,vlrenrpp_ir##10 = vlrenrpp_ir##10 + vr_tab_rend_aplprog(vr_idx)(10)
            ,vlrenrpp_ir##11 = vlrenrpp_ir##11 + vr_tab_rend_aplprog(vr_idx)(11)
            ,vlrenrpp_ir##12 = vlrenrpp_ir##12 + vr_tab_rend_aplprog(vr_idx)(12)
       WHERE rowid = rw_crapcot.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        CLOSE cr_crapcot;
        vr_tem_critica := true;
        falha('Erro atualizando Crapcot! Cooper: '|| rw_crapass.cdcooper || ' Conta: ' ||rw_crapass.nrdconta || ' Pessoa: '|| rw_crapass.inpessoa || ' Valor: '|| replace(rw_crapcot.vlrenrpp,',','.') || ' Erro: '|| SQLERRM);
        RAISE vr_excsaida; 
    END;
    
    sucesso('Cooper: '|| rw_crapass.cdcooper || ' Conta: ' ||rw_crapass.nrdconta || ' Pessoa: '|| rw_crapass.inpessoa ||' Valor anterior: '|| rw_crapcot.vlrenrpp || ' Valor Adicionado: '|| vr_tab_rend_aplprog(vr_idx)(13) || ' Valor Rend. Total: ' || (rw_crapcot.vlrenrpp + vr_tab_rend_aplprog(vr_idx)(13)) );
        
    CLOSE cr_crapcot;

  END LOOP;
  
  loga('Fim do Processo com sucesso');
  
  IF vr_tem_critica THEN
    RAISE vr_excsaida;
  END IF;
  
  commit;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  

  :vr_dscritic := 'SUCESSO';
  
EXCEPTION
  WHEN vr_excsaida then 
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  
    
  WHEN OTHERS then
    loga(vr_dscritic);
    loga(SQLERRM);
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  
end;
1
vr_dscritic
0
5
0
