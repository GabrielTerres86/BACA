PL/SQL Developer Test script 3.0
138
declare 

  vr_dscritic   varchar2(5000) := ' ';
  vr_tem_critica boolean := false;
  vr_excsaida EXCEPTION;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0011871';
  vr_random          PLS_INTEGER    := trunc(DBMS_RANDOM.value(0,1000));
  vr_nmarqimp        VARCHAR2(100)  := 'log'|| vr_random ||'.txt';
  vr_nmarqimp2       VARCHAR2(100)  := 'backup'|| vr_random ||'.txt';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  
  vr_vlsaldorpp      NUMERIC(25,8);
  vr_qtde            PLS_INTEGER    := 0;

  cursor cr_craprpp IS
  select cdcooper
        ,nrdconta
        ,nrctrrpp plano
        ,case cdsitrpp when 1 then 'Ativo' when 2 then 'Suspenso' end situacao
        ,dtdebito dtdebito_atual
        ,to_date(
         case when extract(day from dtdebito) = 31
              then '30/06/2019'
              else lpad(extract(day from dtdebito),2,'0') || '/' ||
                   case when to_date(extract(day from dtdebito)||'/'||extract(month from trunc(sysdate))||'/'||2019,'dd/mm/rrrr') <= trunc(sysdate)
                        then lpad(extract(month from trunc(sysdate))+1,2,'0')
                        else lpad(extract(month from trunc(sysdate)),2,'0')
                    end  || '/2019'
          end,'dd/mm/rrrr') dtdebito_novo
         ,craprpp.dtdebito
         ,craprpp.indebito
         ,craprpp.nrctrrpp
         ,craprpp.rowid
    from craprpp
   where cdsitrpp = 1
     and indebito = 1
     and cdprodut > 0
  order by cdcooper, nrdconta, nrctrrpp;
  rw_craprpp cr_craprpp%ROWTYPE;
  
  procedure loga(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
  END;
  
  procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
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
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto       --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF; 
  
  loga('Inicio Processo');
    
  FOR rw_craprpp IN cr_craprpp LOOP
    vr_qtde := vr_qtde + 1;
    loga('Ajustando: Cooper: '|| rw_craprpp.cdcooper || ' Conta: ' ||rw_craprpp.nrdconta || ' Plano: '|| rw_craprpp.nrctrrpp);

    backup('update craprpp set dtdebito = to_date('''|| to_char(rw_craprpp.dtdebito,'dd/mm/rrrr') ||''',''dd/mm/rrrr'')'||
                            ', indebito = '|| rw_craprpp.indebito ||
                       ' where craprpp.rowid = ''' || rw_craprpp.rowid||''';');
    
    BEGIN
      UPDATE craprpp
         SET indebito = 0
            ,dtdebito = rw_craprpp.dtdebito_novo
       WHERE ROWID = rw_craprpp.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        loga('Erro atualizando! Cooper: '|| rw_craprpp.cdcooper || ' Conta: ' ||rw_craprpp.nrdconta || ' Plano: '|| rw_craprpp.nrctrrpp || ' Erro: '|| SQLERRM);
        RAISE vr_excsaida;
    END;
    
    loga('  Sucesso: Cooper: '|| rw_craprpp.cdcooper || ' Conta: ' ||rw_craprpp.nrdconta || ' Plano: '|| rw_craprpp.nrctrrpp|| ' Data debito antiga: '|| to_char(rw_craprpp.dtdebito,'dd/mm/rrrr') || ' Data debito nova :'|| to_char(rw_craprpp.dtdebito_novo,'dd/mm/rrrr') ||  ' ROWID: ' || rw_craprpp.rowid);
    
    -- Commitar a cada 1000 registros
    -- para nao lockar os planos
    IF MOD(vr_qtde,1000) = 0 THEN
      backup('/* COMITOU AQUI '|| vr_qtde || ' registros  */');
      COMMIT;
    END IF;
    
  END LOOP;
  
  loga('Fim do Processo com sucesso');
  
  IF vr_tem_critica THEN
    RAISE vr_excsaida;
  END IF;
  
  backup('/* COMITOU AQUI '|| vr_qtde || ' registros  */');
  COMMIT;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  

  :vr_dscritic := 'SUCESSO';
  
EXCEPTION
  WHEN vr_excsaida then 
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    
  WHEN OTHERS then
    loga(vr_dscritic);
    loga(SQLERRM);
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
end;
1
vr_dscritic
1
SUCESSO
5
0
