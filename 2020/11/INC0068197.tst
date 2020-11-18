PL/SQL Developer Test script 3.0
109
declare 
  vr_contador number;
  vr_dscritic varchar2(500);
  vr_excsaida EXCEPTION;  

  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0068197';
  vr_nmarqimp        VARCHAR2(100)  := 'INC0068197_ROLLBACK.txt';   
  vr_ind_arquiv      utl_file.file_type;
  
  vr_conta_deb number;
  
  cursor cr_agendamentos is
  select u.cdageban,
         u.nrdconta,
         u.progress_recid
    from craplau u 
   where u.cdcooper = 3 
     and dtmvtopg >= '19/11/2020' 
     and cdhistor in(3049) 
     and insitlau = 1;

cursor cr_crapcop (pr_cdagectl in crapcop.cdagectl%type) is
select p.cdcooper,
       p.nrdocnpj,
       p.nrctactl
  from crapcop p 
 where p.cdagectl = pr_cdagectl;
 rw_crapcop   cr_crapcop%rowtype;
 
 cursor cr_crapass (pr_cdcooper in crapcop.cdcooper%type,
                    pr_nrcpfcgc in crapass.nrcpfcgc%type,
                    pr_nrdconta in crapass.nrdconta%type) is
 select nrdconta 
   from crapass 
  where cdcooper = pr_cdcooper 
    and nrcpfcgc = pr_nrcpfcgc 
    and nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;
 
begin

  vr_contador:=0;
  
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
  
  FOR rw_agendamentos IN cr_agendamentos LOOP
    
    vr_contador:= vr_contador + 1;       
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update craplau set nrdconta = '||rw_agendamentos.nrdconta  
    ||' where rowid = '''|| rw_agendamentos.progress_recid ||''';');
  
  
   -- Busca dos detalhes do empréstimo
    OPEN cr_crapcop(pr_cdagectl => rw_agendamentos.cdageban);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar informações
    IF cr_crapcop%NOTFOUND THEN
      vr_dscritic := 'Erro ao buscar crapcop';
      RAISE vr_excsaida;
    end if;       
    close cr_crapcop;             
    OPEN cr_crapass(pr_cdcooper => 3,
                    pr_nrcpfcgc => rw_crapcop.nrdocnpj,
                    pr_nrdconta => rw_crapcop.nrctactl);
    FETCH cr_crapass INTO rw_crapass;
              
   IF cr_crapass%notfound THEN
      vr_dscritic := 'Erro ao buscar cr_crapass';
      RAISE vr_excsaida;
   END if;
   close cr_crapass;
   vr_conta_deb  := rw_crapass.nrdconta;     
  
    BEGIN
      UPDATE craplau 
         set nrdconta = vr_conta_deb
       WHERE progress_recid = rw_agendamentos.progress_recid;
       
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar craplau! progress_recid: '||
                       rw_agendamentos.progress_recid;
        RAISE vr_excsaida;
    END;
    
  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  commit;
  
  :vr_dscritic := 'SUCESSO -> Registros atualizados: '|| vr_contador;
EXCEPTION
  WHEN vr_excsaida then 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
end;
1
vr_dscritic
1
SUCESSO -> Registros atualizados: 12
5
0
