PL/SQL Developer Test script 3.0
63
declare 
  vr_contador number;
  vr_dscritic varchar2(500);
  vr_excsaida EXCEPTION;  

  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0045502';
  vr_nmarqimp        VARCHAR2(100)  := 'INC0045502_ROLLBACK.txt';   
  vr_ind_arquiv      utl_file.file_type;
  
  cursor cr_seguros is
    SELECT ROWID
      FROM crapseg g
     WHERE g.cdsitseg = 1
       AND g.tpseguro = 4
       AND g.vlslddev > 60000
       AND g.dtcancel IS NULL
       AND g.idimpdps = 0;
  
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
  
  FOR rw_seguros IN cr_seguros LOOP
    
    vr_contador:= vr_contador + 1;       
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crapseg set idimpdps = 0 where rowid = '''|| rw_seguros.rowid ||''';');
  
    BEGIN
      UPDATE crapseg g 
         SET g.idimpdps = 1
       WHERE ROWID = rw_seguros.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar crapseg! rowid: '||
                       rw_seguros.rowid;
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
SUCESSO -> Registros atualizados: 208
5
0
