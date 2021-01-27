PL/SQL Developer Test script 3.0
56
declare 
  vr_contador number;
  vr_dscritic varchar2(500);
  vr_excsaida EXCEPTION;  
  vr_linha varchar2(2000);
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0069609';
  vr_nmarqimp        VARCHAR2(100)  := 'INC0069609_ROLLBACK.txt';   
  vr_ind_arquiv      utl_file.file_type;
  
  cursor cr_consorcios is
    select PROGRESS_RECID, rowid from crapcns where  flgativo = 1 and (qtparres = 0 OR dtcancel IS NOT NULL) ;
 
begin
  vr_contador:=0;  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica---*
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_excsaida;
  END IF;    
  
  FOR rw_consorcios IN cr_consorcios LOOP
    
    vr_contador:= vr_contador + 1;       
    vr_linha := 'update crapcns set flgativo = 1 where PROGRESS_RECID = '''|| rw_consorcios.PROGRESS_RECID ||''';';    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,  vr_linha);

    BEGIN
      update crapcns 
         set flgativo = 0 
       WHERE ROWID = rw_consorcios.rowid;
       
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar crapcns! rowid: '||
                       rw_consorcios.rowid;
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
SUCESSO -> Registros atualizados: 3
5
2
vr_nmdireto
vr_dscritic
