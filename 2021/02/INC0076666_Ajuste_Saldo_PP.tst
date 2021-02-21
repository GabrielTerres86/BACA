PL/SQL Developer Test script 3.0
147
declare 
  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   varchar2(5000) := ' ';
  vr_excsaida EXCEPTION;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0076666';
 -- vr_nmdireto        VARCHAR2(4000) := 'F://Documents/Testes/INC0076666';
  vr_nmarqimp        VARCHAR2(100)  := 'log.txt';
  vr_nmarqimp2       VARCHAR2(100)  := 'sucesso.txt';
  vr_nmarqimp3       VARCHAR2(100)  := 'falha.txt';
  vr_nmarqimp4       VARCHAR2(100)  := 'backup.txt';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  vr_ind_arquiv3     utl_file.file_type;
  vr_ind_arquiv4     utl_file.file_type;
  
  cursor cr_crapdir IS
     select dir.rowid, dir.nrdconta, dir.cdcooper, dir.vlsdrdpp
     from crapdir dir where dir.dtmvtolt = '31/12/2020' and dir.vlsdrdpp > 0;
  rw_crapdir cr_crapdir%ROWTYPE;

  vr_vlsppant_correto craprpp.vlsppant%TYPE;

  procedure loga(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, pr_msg);
  END;
    
  procedure sucesso(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
  END;
  
  procedure falha(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3, pr_msg);
    loga(pr_msg);
  END;
  
  procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
  END;

begin--Criar arquivo
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
  
  loga('Inicio Processo');
    
  FOR rw_crapdir IN cr_crapdir LOOP
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN        
      RAISE vr_excsaida;
    END IF;

    loga('Ajustando o saldo da poupança:  Cooper : ' || rw_crapdir.cdcooper || 
                                        ' Conta  : ' || rw_crapdir.nrdconta ||
                                        ' Valor  : ' || rw_crapdir.vlsdrdpp);
 
    -- Gera backup com valor atual do campo - script de rollback
    backup('update crapdir set vlsdrdpp = '|| rw_crapdir.vlsdrdpp ||
           ' where crapdir.rowid = '''|| rw_crapdir.rowid ||''';');    
    
    BEGIN
      /*  Zera o valor da coluna, pois não existe mais poupança ativa */
      UPDATE crapdir set vlsdrdpp = 0  --Zera o valor 
      where crapdir.rowid = rw_crapdir.rowid;      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := ' Erro atualizando crapdir!' || 
                       ' Cooper : ' || rw_crapdir.cdcooper || 
                       ' Conta  : ' || rw_crapdir.nrdconta ||
                       ' Valor  : ' || rw_crapdir.vlsdrdpp || ' SQLERRM: ' || SQLERRM;
        loga(vr_dscritic);
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;

    sucesso('Ajustado o saldo da poupança:  Cooper : ' || rw_crapdir.cdcooper || ' Conta  : ' || rw_crapdir.nrdconta);
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
0
