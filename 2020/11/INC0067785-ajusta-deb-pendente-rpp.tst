PL/SQL Developer Test script 3.0
183
-- Created on 17/11/2020 by F0030794 
/* Verifica planos com saldo pendente para debito maior do que o valor da prestacao
   e ajusta para o valor de debito correto */
declare 

  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   varchar2(5000) := ' ';
  vr_total_proc  pls_integer := 0;
  vr_excsaida EXCEPTION;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0067785';
  vr_nmarqimp        VARCHAR2(100)  := 'log.txt';
  vr_nmarqimp2       VARCHAR2(100)  := 'sucesso.txt';
  vr_nmarqimp3       VARCHAR2(100)  := 'falha.txt';
  vr_nmarqimp4       VARCHAR2(100)  := 'backup.txt';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  vr_ind_arquiv3     utl_file.file_type;
  vr_ind_arquiv4     utl_file.file_type;
  
  cursor cr_craprpp IS
  select rpp.cdcooper, rpp.nrdconta, rpp.nrctrrpp, rpp.vlprerpp, rpp.vlsppant, rpp.dtdebito,
         nvl(
         (select sum(rac.vlaplica)
            from craprac rac
           where rac.cdcooper = rpp.cdcooper
             and rac.nrdconta = rpp.nrdconta
             and rac.nrctrrpp = rpp.nrctrrpp
             and rac.dtmvtolt >= rpp.dtdebito),0) vlaplica
        ,rpp.rowid
    from craprpp rpp
   where rpp.vlsppant > rpp.vlprerpp 
     and rpp.cdprodut > 1
     and rpp.dtaltrpp between '16/11/2020' and '17/11/2020';
  rw_craprpp cr_craprpp%ROWTYPE;

  vr_vlsppant_correto craprpp.vlsppant%TYPE;

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

BEGIN
  
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
    
  FOR rw_craprpp IN cr_craprpp LOOP
    loga('Ajustando plano: Cooper: '|| rw_craprpp.cdcooper || ' Conta: ' ||rw_craprpp.nrdconta || ' Plano: ' ||rw_craprpp.nrctrrpp);
        
    -- Gera backup com valor atual do campo - script de rollback
    backup('update craprpp set vlsppant = '|| replace(rw_craprpp.vlsppant,',','.') ||
           ' where craprpp.rowid = '''|| rw_craprpp.rowid ||''';');    
    
    -- Calcula o vlsppant correto.
    
    -- Se ja aplicou mais do que deveria
    IF rw_craprpp.vlaplica > rw_craprpp.vlprerpp THEN
      vr_vlsppant_correto := 0;  
    ELSE
      vr_vlsppant_correto := rw_craprpp.vlprerpp - rw_craprpp.vlaplica;
    END IF;
    
    -- So por precaucao - nao deveria cair aqui
    -- se caso o valor correto ainda seja maior que o valor de prestacao
    -- ou ele seja negativo.
    IF vr_vlsppant_correto > rw_craprpp.vlprerpp OR
       rw_craprpp.vlprerpp < 0 THEN
      vr_vlsppant_correto := 0;
    END IF;
    
    BEGIN
      UPDATE craprpp
         SET vlsppant      = vr_vlsppant_correto
       WHERE craprpp.rowid = rw_craprpp.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro atualizando craprpp! ! Cooper: '|| rw_craprpp.cdcooper || ' Conta: ' ||rw_craprpp.nrdconta || ' Plano: ' ||rw_craprpp.nrctrrpp || ' SQLERRM: ' || SQLERRM;
        loga(vr_dscritic);
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;
    
    sucesso('Plano ajustado com sucesso: Cooper: '|| rw_craprpp.cdcooper || ' Conta: ' ||rw_craprpp.nrdconta || ' Plano: ' ||rw_craprpp.nrctrrpp || ' Valor anterior: ' || rw_craprpp.vlsppant || ' Valor novo: ' ||vr_vlsppant_correto);

    vr_total_proc := vr_total_proc + 1;

    -- commit a cada 500 registros
    IF mod(vr_total_proc,500) = 0 THEN
      commit;
    END IF;

  END LOOP;
  
  COMMIT;

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
1
SUCESSO
5
2
vr_vlr_vencido
rw_crapsli.vlsddisp
