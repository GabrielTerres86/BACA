PL/SQL Developer Test script 3.0
193
declare 
  vr_contador number;
  vr_dscritic varchar2(500);
  vr_excsaida EXCEPTION;  

  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0068197';
  vr_nmarqimp        VARCHAR2(100)  := 'INC0068197_SALDO_ROLLBACK.txt';   
  vr_ind_arquiv      utl_file.file_type;
  
  vr_conta_deb number;
  vr_data_dia date;
  vr_achou_sda boolean;
  
  --- Busca lançamentos efetuados
  cursor cr_agendamentos is
  select u.cdageban,
         u.nrctadst,
         u.dtmvtopg,
         u.dtdebito,
         u.vllanaut,
         u.progress_recid
    from craplau u         
   where u.cdcooper = 3 
     and u.dtmvtopg >= '16/11/2020' 
     and u.cdhistor = 3049
     and u.insitlau = 2;
     
  -- Ver cooperativa
  cursor cr_crapcop (pr_cdagectl in crapcop.cdagectl%type) is
  select p.cdcooper
    from crapcop p 
   where p.cdagectl = pr_cdagectl;
   rw_crapcop   cr_crapcop%rowtype;
   
 --- lancamento na conta do cooeprado
 cursor cr_craplcm (pr_cdcooper in crapcop.cdcooper%type,
                    pr_dtmvtolt in craplcm.dtmvtolt%type,
                    pr_nrdconta in crapass.nrdconta%type,
                    pr_vllanmto in craplcm.vllanmto%type) is
 select dtmvtolt 
   from craplcm
  where cdcooper = pr_cdcooper 
    and dtmvtolt = pr_dtmvtolt 
    and nrdconta = pr_nrdconta
    and cdhistor = 3049
    and vllanmto = pr_vllanmto;
  rw_craplcm cr_craplcm%rowtype;
  
  --- Saldo diario
  cursor cr_crapsda (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtmvtolt in crapsda.dtmvtolt%type,
                     pr_nrdconta in crapsda.nrdconta%type) is
  select a.cdcooper,
         a.vlsddisp,
         a.progress_recid
    from crapsda a 
   where a.cdcooper = pr_cdcooper
     and a.dtmvtolt = pr_dtmvtolt
     and a.nrdconta = pr_nrdconta;
   rw_crapsda   cr_crapsda%rowtype; 
   
   ----- Saldo disponivel 
   cursor cr_crapsld (pr_cdcooper in crapcop.cdcooper%type,                    
                      pr_nrdconta in crapsda.nrdconta%type) is
    select d.cdcooper,
           d.vlsddisp,
           d.progress_recid
      from crapsld d
     where d.cdcooper = pr_cdcooper
       and d.nrdconta = pr_nrdconta;
     rw_crapsld   cr_crapsld%rowtype; 
 
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
    vr_data_dia:= rw_agendamentos.dtdebito;
  
   -- busca cooperativa baseado no cdagectl
    OPEN cr_crapcop(pr_cdagectl => rw_agendamentos.cdageban);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar informações
    IF cr_crapcop%NOTFOUND THEN
      vr_dscritic := 'Erro ao buscar crapcop';
      RAISE vr_excsaida;
    end if;       
    close cr_crapcop;      
           
    -- Validar se lançamento existe
    OPEN cr_craplcm(pr_cdcooper => rw_crapcop.cdcooper,
                    pr_dtmvtolt => rw_agendamentos.dtdebito,
                    pr_nrdconta => rw_agendamentos.nrctadst,
                    pr_vllanmto => rw_agendamentos.vllanaut);
    FETCH cr_craplcm INTO rw_craplcm;
              
    IF cr_craplcm%notfound THEN
      vr_dscritic := 'Erro ao buscar cr_craplcm';
      RAISE vr_excsaida;
    END if;
    close cr_craplcm;
   
    vr_achou_sda:= true;
    loop 
      exit when vr_achou_sda = false;
       -- Percorrer saldo diario
       open cr_crapsda (pr_cdcooper => rw_crapcop.cdcooper,
                        pr_dtmvtolt => vr_data_dia,
                        pr_nrdconta => rw_agendamentos.nrctadst);
       fetch cr_crapsda into rw_crapsda;
           
       IF cr_crapsda%notfound THEN
          vr_achou_sda:= false;
       else
         vr_achou_sda:= true;
               
         -- Salvar valor anterior
         gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crapsda set vlsddisp = '||rw_crapsda.vlsddisp  
                                       ||' where progress_recid = '''|| rw_crapsda.progress_recid ||''';');       
         -- Sensibilizar saldo do dia
         BEGIN
           UPDATE crapsda
             set vlsddisp = vlsddisp + rw_agendamentos.vllanaut
           WHERE progress_recid = rw_crapsda.progress_recid;
                     
         EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := 'Erro ao atualizar crapsda! progress_recid: '||
                           rw_crapsda.progress_recid;
             RAISE vr_excsaida;
         END;    
       END if;
       close cr_crapsda;

       -- Adiciona um dia
      vr_data_dia:= to_date(vr_data_dia,'dd/mm/rrrr') + 1;
    end loop;
   
    -- Validar se saldo existe para a conta
    OPEN cr_crapsld(pr_cdcooper => rw_crapcop.cdcooper,
                    pr_nrdconta => rw_agendamentos.nrctadst);
    FETCH cr_crapsld INTO rw_crapsld;
                  
    IF cr_crapsld%notfound THEN
      vr_dscritic := 'Erro ao buscar cr_crapsld';
      RAISE vr_excsaida;
    END if;
    close cr_crapsld;
       
    -- Salvar valor anterior
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crapsld set vlsddisp = '||rw_crapsld.vlsddisp  
                                  ||' where progress_recid = '''|| rw_crapsld.progress_recid ||''';');    
  
    -- Sensibilizar saldo
    BEGIN
     UPDATE crapsld
        set vlsddisp = vlsddisp + rw_agendamentos.vllanaut
      WHERE progress_recid = rw_crapsld.progress_recid;
             
    EXCEPTION
     WHEN OTHERS THEN
       vr_dscritic := 'Erro ao atualizar crapsld! progress_recid: '||
                      rw_crapsld.progress_recid;
       RAISE vr_excsaida;
    END;   
      
  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  commit;
  
  :vr_dscritic := 'SUCESSO -> Contas atualizadas: '|| vr_contador;
EXCEPTION
  WHEN vr_excsaida then 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
end;
1
vr_dscritic
1
SUCESSO -> Contas atualizadas: 0
5
0
