PL/SQL Developer Test script 3.0
63
declare 
  vr_contador number;
  vr_dscritic varchar2(500);
  vr_excsaida EXCEPTION;  

  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/RITM0080466';
  vr_nmarqimp        VARCHAR2(100)  := 'RITM0080466_ROLLBACK.txt';   
  vr_ind_arquiv      utl_file.file_type;
  
  cursor cr_crapass is
    SELECT s.*
      FROM crapass s
     WHERE s.cdcooper = 4
       AND s.dtdemiss IS NULL;
  
begin
  vr_contador:=0;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de cr�tica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_excsaida;
  END IF;
  
  FOR rw_crapass IN cr_crapass LOOP
    
    vr_contador:= vr_contador + 1;       
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crapass set dtdemiss = ''''' ||
                                                                    ',cdsitdct = '||rw_crapass.cdsitdct
                                  || ' where progress_recid = '''|| rw_crapass.progress_recid ||''';');
  
    BEGIN
      UPDATE crapass ass 
         SET ass.dtdemiss = '31/12/2014' -- Data da migra��o
            ,ass.cdsitdct = 4
       WHERE ass.progress_recid = rw_crapass.progress_recid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar crapass! progress_recid: '||
                       rw_crapass.progress_recid;
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
SUCESSO -> Registros atualizados: 4180
5
0
