PL/SQL Developer Test script 3.0
105
-- Created on 30/01/2019 by F0030794 
declare 

  vr_dscritic   varchar2(5000) := ' ';
  vr_tem_critica boolean := false;
  vr_excsaida EXCEPTION;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0032174';
  vr_nmarqimp        VARCHAR2(100)  := 'log.txt';
  vr_ind_arquiv      utl_file.file_type;
  
  vr_vlsaldorpp      NUMERIC(25,8);


  cursor cr_craprda IS
select rda.cdcooper, rda.nrdconta, rda.nraplica, rda.vlsdrdca , rda.rowid
  from craprda  rda
  join crapass ass
    on ass.cdcooper = rda.cdcooper
   and ass.nrdconta = rda.nrdconta
   and ass.dtdemiss is null
 where tpaplica = 5 
   and incalmes = 1 
   and insaqtot = 0 
   and dtiniper between '01/01/2019' and '31/01/2019'
   and not exists (select 1  /* Este sub sql não representou diferença na qtd. rows - precaucao */
                     from craplap lap
                    where lap.cdcooper = rda.cdcooper
                      and lap.nrdconta = rda.nrdconta
                      and lap.nraplica = rda.nraplica
                      and lap.dtmvtolt = '31/01/2019'
                      and lap.cdhistor = 180) /* Provisão */
   and not exists (select 1  /* Este sub sql não representou diferença na qtd. rows - precaucao */
                     from craplap lap
                    where lap.cdcooper = rda.cdcooper
                      and lap.nrdconta = rda.nrdconta
                      and lap.nraplica = rda.nraplica
                      and lap.dtmvtolt between '01/02/2019' and '28/02/2019'
                      and lap.cdhistor = 179) /* Rendimento */
 order by rda.cdcooper, rda.nrdconta, rda.nraplica;
  rw_craprda cr_craprda%ROWTYPE;
  
  procedure loga(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
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
    
  loga('Inicio Processo');
    
  FOR rw_craprda IN cr_craprda LOOP
    loga('Ajustando: Cooper: '|| rw_craprda.cdcooper || ' Conta: ' ||rw_craprda.nrdconta || ' Aplica: '|| rw_craprda.nraplica);

    BEGIN
      UPDATE craprda
         SET incalmes = 0
       WHERE rowid = rw_craprda.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        loga('Erro atualizando! Cooper: '|| rw_craprda.cdcooper || ' Conta: ' ||rw_craprda.nrdconta || ' Aplica: '|| rw_craprda.nraplica || ' Erro: '|| SQLERRM);
        RAISE vr_excsaida;
    END;
    
    loga('  Sucesso: Cooper: '|| rw_craprda.cdcooper || ' Conta: ' ||rw_craprda.nrdconta || ' Aplica: '|| rw_craprda.nraplica|| ' ROWID: ' || rw_craprda.rowid);
    
  END LOOP;
  
  loga('Fim do Processo com sucesso');
  
  IF vr_tem_critica THEN
    RAISE vr_excsaida;
  END IF;
  
  commit;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  

  :vr_dscritic := 'SUCESSO';
  
EXCEPTION
  WHEN vr_excsaida then 
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    
  WHEN OTHERS then
    loga(vr_dscritic);
    loga(SQLERRM);
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
end;
0
0
