PL/SQL Developer Test script 3.0
280
-- Created on 30/01/2019 by F0030794 
declare 

  pr_cdcooper   crapcop.cdcooper%TYPE := 1;
  pr_dtinform   date := to_date('31/12/2018','dd/mm/rrrr');
  
  vr_dscritic   varchar2(5000) := ' ';
  vr_tem_critica boolean := false;
  vr_excsaida EXCEPTION;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0031921';
  vr_nmarqimp        VARCHAR2(100)  := 'viacredi-log.txt';
  vr_nmarqimp2       VARCHAR2(100)  := 'viacredi-sucesso.txt';
  vr_nmarqimp3       VARCHAR2(100)  := 'viacredi-falha.txt';
  vr_nmarqimp4       VARCHAR2(100)  := 'viacredi-backup.txt';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  vr_ind_arquiv3     utl_file.file_type;
  vr_ind_arquiv4     utl_file.file_type;
  
  vr_vlsaldorpp      NUMERIC(25,8);

  cursor cr_crapass IS
  select ass.cdcooper
        ,ass.nrdconta
        ,ass.inpessoa
    from crapass ass
   where ass.cdcooper = pr_cdcooper
     and exists (select 1 
                   from craprac rac
                  where rac.cdcooper = ass.cdcooper
                    and rac.nrdconta = ass.nrdconta
                    and rac.dtmvtolt < to_date('01/01/2019','dd/mm/rrrr'));
  rw_crapass cr_crapass%ROWTYPE;

  cursor cr_crapdir(pr_cdcooper crapcop.cdcooper%TYPE,
                     pr_nrdconta crapass.nrdconta%TYPE) IS
   select dir.vlrenrpp
          /* colunas de rendimento total para backup */
         ,dir.vlrentot##1,  dir.vlrentot##2, dir.vlrentot##3, dir.vlrentot##4, dir.vlrentot##5
         ,dir.vlrentot##6,  dir.vlrentot##7, dir.vlrentot##8, dir.vlrentot##9, dir.vlrentot##10
         ,dir.vlrentot##11, dir.vlrentot##12
         /* colunas de rendimento rdca para recalculo do rendimento */
         ,dir.vlrenrda##1,  dir.vlrenrda##2,  dir.vlrenrda##3, dir.vlrenrda##4, dir.vlrenrda##5
         ,dir.vlrenrda##6,  dir.vlrenrda##7,  dir.vlrenrda##8, dir.vlrenrda##9, dir.vlrenrda##10
         ,dir.vlrenrda##11, dir.vlrenrda##12
         /* colunas de rendimento rdc para recalculo do rendimento */
         ,dir.vlrenrdc##1,  dir.vlrenrdc##2,  dir.vlrenrdc##3, dir.vlrenrdc##4, dir.vlrenrdc##5
         ,dir.vlrenrdc##6,  dir.vlrenrdc##7,  dir.vlrenrdc##8, dir.vlrenrdc##9, dir.vlrenrdc##10
         ,dir.vlrenrdc##11, dir.vlrenrdc##12
         /* colunas de abono ir para recalculo do rendimento */
         ,dir.vlabnapl_ir##1,  dir.vlabnapl_ir##2,  dir.vlabnapl_ir##3, dir.vlabnapl_ir##4, dir.vlabnapl_ir##5
         ,dir.vlabnapl_ir##6,  dir.vlabnapl_ir##7,  dir.vlabnapl_ir##8, dir.vlabnapl_ir##9, dir.vlabnapl_ir##10
         ,dir.vlabnapl_ir##11, dir.vlabnapl_ir##12
         
         ,dir.rowid
     from crapdir dir
    where dir.cdcooper = pr_cdcooper
      and dir.nrdconta = pr_nrdconta
      and dir.dtmvtolt = pr_dtinform;
  rw_crapdir cr_crapdir%ROWTYPE;

  cursor cr_valoratu(pr_cdcooper crapcop.cdcooper%TYPE,
                     pr_nrdconta crapass.nrdconta%TYPE) IS
  select SUM(decode(extract(month from dtmvtolt),1,vllanmto,0)) janeiro
        ,SUM(decode(extract(month from dtmvtolt),2,vllanmto,0)) fevereiro
        ,SUM(decode(extract(month from dtmvtolt),3,vllanmto,0)) marco
        ,SUM(decode(extract(month from dtmvtolt),4,vllanmto,0)) abril
        ,SUM(decode(extract(month from dtmvtolt),5,vllanmto,0)) maio
        ,SUM(decode(extract(month from dtmvtolt),6,vllanmto,0)) junho
        ,SUM(decode(extract(month from dtmvtolt),7,vllanmto,0)) julho
        ,SUM(decode(extract(month from dtmvtolt),8,vllanmto,0)) agosto
        ,SUM(decode(extract(month from dtmvtolt),9,vllanmto,0)) setembro
        ,SUM(decode(extract(month from dtmvtolt),10,vllanmto,0)) outubro
        ,SUM(decode(extract(month from dtmvtolt),11,vllanmto,0)) novembro
        ,SUM(decode(extract(month from dtmvtolt),12,vllanmto,0)) dezembro
        ,SUM(vllanmto) total
  from(
  select lpp.dtmvtolt, lpp.vllanmto
    from craplpp lpp
   where lpp.cdcooper = pr_cdcooper
     and lpp.nrdconta = pr_nrdconta
     and lpp.dtmvtolt between '01/01/2018' and '31/12/2018'
     and lpp.cdhistor = 151 -- Rendimento p. prog.
  union all
  select lac.dtmvtolt, lac.vllanmto
    from craplac lac, craprac rac
   where rac.cdcooper = lac.cdcooper
     and rac.nrdconta = lac.nrdconta
     and rac.nraplica = lac.nraplica
     and rac.nrctrrpp > 0
     and lac.cdcooper = pr_cdcooper
     and lac.nrdconta = pr_nrdconta
     and lac.dtmvtolt between '01/01/2018' and '31/12/2018'
     and lac.cdhistor = 2749 -- Rendimento aplic. prog.
  ) origem;
  rw_valoratu cr_valoratu%ROWTYPE;
  
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
    
  loga('Inicio Processo');
  
  FOR rw_crapass IN cr_crapass LOOP
    loga('Ajustando conta: Cooper: '|| rw_crapass.cdcooper || ' Conta: ' ||rw_crapass.nrdconta || ' Pessoa: '|| rw_crapass.inpessoa);
    
    OPEN cr_crapdir(pr_cdcooper => rw_crapass.cdcooper,
                    pr_nrdconta => rw_crapass.nrdconta);
    FETCH cr_crapdir INTO rw_crapdir;
    IF cr_crapdir%NOTFOUND THEN
      CLOSE cr_crapdir;
      falha('CRAPDIR nao encontrado! Cooper: '|| rw_crapass.cdcooper || ' Conta: ' ||rw_crapass.nrdconta || ' Pessoa: '|| rw_crapass.inpessoa);
      CONTINUE;
    END IF;
        
    OPEN cr_valoratu(pr_cdcooper => rw_crapass.cdcooper
                    ,pr_nrdconta => rw_crapass.nrdconta);
    FETCH cr_valoratu INTO rw_valoratu;
    IF cr_valoratu%NOTFOUND THEN
      CLOSE cr_valoratu;
      CLOSE cr_crapdir;
      falha('Valor Atualizado nao encontrado! Cooper: '|| rw_crapass.cdcooper || ' Conta: ' ||rw_crapass.nrdconta || ' Pessoa: '|| rw_crapass.inpessoa);
      CONTINUE;
    END IF;
        
    /* Verifica se precisa atualizar */
    IF (rw_crapdir.vlrenrpp = nvl(rw_valoratu.total,0)) THEN
      CLOSE cr_valoratu;
      CLOSE cr_crapdir;
      loga('Conta sem necessidade alteracao! Cooper: '|| rw_crapass.cdcooper || ' Conta: ' ||rw_crapass.nrdconta || ' Pessoa: '|| rw_crapass.inpessoa || ' Valor: '|| replace(rw_crapdir.vlrenrpp,',','.'));
      CONTINUE;
    END IF;
    
    --backup crapdir
    backup('update crapdir '  ||
            ' set vlrenrpp     = '|| replace(rw_crapdir.vlrenrpp,',','.') ||
               ' ,vlrentot##1  = '|| replace(rw_crapdir.vlrentot##1,',','.') ||
               ' ,vlrentot##2  = '|| replace(rw_crapdir.vlrentot##2,',','.') ||
               ' ,vlrentot##3  = '|| replace(rw_crapdir.vlrentot##3,',','.') ||
               ' ,vlrentot##4  = '|| replace(rw_crapdir.vlrentot##4,',','.') ||
               ' ,vlrentot##5  = '|| replace(rw_crapdir.vlrentot##5,',','.') ||
               ' ,vlrentot##6  = '|| replace(rw_crapdir.vlrentot##6,',','.') ||
               ' ,vlrentot##7  = '|| replace(rw_crapdir.vlrentot##7,',','.') ||
               ' ,vlrentot##8  = '|| replace(rw_crapdir.vlrentot##8,',','.') ||
               ' ,vlrentot##9  = '|| replace(rw_crapdir.vlrentot##9,',','.') ||
               ' ,vlrentot##10 = '|| replace(rw_crapdir.vlrentot##10,',','.') ||
               ' ,vlrentot##11 = '|| replace(rw_crapdir.vlrentot##11,',','.') ||
               ' ,vlrentot##12 = '|| replace(rw_crapdir.vlrentot##12,',','.') ||
           ' where rowid = '''|| rw_crapdir.rowid ||''';');
    BEGIN
      UPDATE crapdir
         SET vlrenrpp = rw_valoratu.total
            ,vlrentot##1  = rw_crapdir.vlrenrda##1  + rw_crapdir.vlabnapl_ir##1  + rw_crapdir.vlrenrdc##1  + rw_valoratu.janeiro
            ,vlrentot##2  = rw_crapdir.vlrenrda##2  + rw_crapdir.vlabnapl_ir##2  + rw_crapdir.vlrenrdc##2  + rw_valoratu.fevereiro
            ,vlrentot##3  = rw_crapdir.vlrenrda##3  + rw_crapdir.vlabnapl_ir##3  + rw_crapdir.vlrenrdc##3  + rw_valoratu.marco
            ,vlrentot##4  = rw_crapdir.vlrenrda##4  + rw_crapdir.vlabnapl_ir##4  + rw_crapdir.vlrenrdc##4  + rw_valoratu.abril
            ,vlrentot##5  = rw_crapdir.vlrenrda##5  + rw_crapdir.vlabnapl_ir##5  + rw_crapdir.vlrenrdc##5  + rw_valoratu.maio
            ,vlrentot##6  = rw_crapdir.vlrenrda##6  + rw_crapdir.vlabnapl_ir##6  + rw_crapdir.vlrenrdc##6  + rw_valoratu.junho
            ,vlrentot##7  = rw_crapdir.vlrenrda##7  + rw_crapdir.vlabnapl_ir##7  + rw_crapdir.vlrenrdc##7  + rw_valoratu.julho
            ,vlrentot##8  = rw_crapdir.vlrenrda##8  + rw_crapdir.vlabnapl_ir##8  + rw_crapdir.vlrenrdc##8  + rw_valoratu.agosto
            ,vlrentot##9  = rw_crapdir.vlrenrda##9  + rw_crapdir.vlabnapl_ir##9  + rw_crapdir.vlrenrdc##9  + rw_valoratu.setembro
            ,vlrentot##10 = rw_crapdir.vlrenrda##10 + rw_crapdir.vlabnapl_ir##10 + rw_crapdir.vlrenrdc##10 + rw_valoratu.outubro
            ,vlrentot##11 = rw_crapdir.vlrenrda##11 + rw_crapdir.vlabnapl_ir##11 + rw_crapdir.vlrenrdc##11 + rw_valoratu.novembro
            ,vlrentot##12 = rw_crapdir.vlrenrda##12 + rw_crapdir.vlabnapl_ir##12 + rw_crapdir.vlrenrdc##12 + rw_valoratu.dezembro
       WHERE rowid = rw_crapdir.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        CLOSE cr_valoratu;
        CLOSE cr_crapdir;
        vr_tem_critica := true;
        falha('Erro atualizando Crapdir! Cooper: '|| rw_crapass.cdcooper || ' Conta: ' ||rw_crapass.nrdconta || ' Pessoa: '|| rw_crapass.inpessoa || ' Valor: '|| replace(rw_crapdir.vlrenrpp,',','.') || ' Erro: '|| SQLERRM);
        RAISE vr_excsaida;
    END;
    
    sucesso('Cooper: '|| rw_crapass.cdcooper || ' Conta: ' ||rw_crapass.nrdconta || ' Pessoa: '|| rw_crapass.inpessoa ||' Valor anterior: '|| rw_crapdir.vlrenrpp || ' Valor Atualizado: '|| rw_valoratu.total);
    
    CLOSE cr_valoratu;
    CLOSE cr_crapdir;

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
